#!/usr/bin/env python3
"""Coleta em escala os pares (PA esperado, PA entregue) do aliasing da GPU.

Por que em escala
-----------------
Com poucas amostras apareceram duas invariantes que sumiram quando o n cresceu:

  bateria 1 (6 amostras)  o PA ENTREGUE era sempre 0x176000000 ou 0x176800000
  bateria 2 (2 amostras)  o PA ESPERADO era sempre 0x170000000, entregues variados

As duas leituras se contradizem, e cada uma sozinha teria justificado um patch
diferente -- reserva de pagina fisica numa, nada na outra. Refutado tambem, com
4 execucoes por braco: reuso de faixa de VA nao e o gatilho (1/4 contra 2/4).

Entao o que falta e volume, nao mais uma hipotese. Este script existe para
responder se existe ALGUMA invariante nos pares, e nao para testar um palpite.

Como ficou rapido sem perder integridade
---------------------------------------
O custo antigo era ~160 s por amostra: 40 s de aquecimento, ~110 s varrendo os
12 GiB de VRAM e ~10 s de teste. As varreduras serviam para calibrar a base do
FB e provar que a memoria fisica contem o dado certo -- ja feito, fechou em 11
de 11 blocos, base 0x170000000.

Aqui:
  - a varredura completa roda UMA vez por processo, no primeiro ciclo, so para
    confirmar a base. Se nao confirmar, o processo aborta em vez de produzir
    dado sob referencial errado.
  - o aquecimento roda UMA vez e vale para todos os ciclos.
  - cada ciclo seguinte custa segundos: aloca, marca, le, registra, libera.

O trace e limpo a cada ciclo, entao a atribuicao de PTE a bloco fica sem
ambiguidade de geracao -- o erro que ja me fez ler o trace de uma execucao
contra o repro de outra.

Saida: uma linha por par, em ~/bc250-grimoire/pares.tsv
    ciclo  bloco  tam  va  pa_esperado  bloco_entregue  pa_entregue
"""
import ctypes
import os
import re
import struct
import subprocess
import sys

import numpy as np

import torch

DEV = "cuda"
D2H = 2
TRC = "/sys/kernel/tracing"
VRAM = 12288 * 1024 * 1024
BASE_ESPERADA = 0x170000000
PARES = os.path.expanduser("~/bc250-grimoire/pares.tsv")
LOG = os.path.expanduser("~/bc250-grimoire/coletar_pares.result")

CICLOS = int(sys.argv[1]) if len(sys.argv) > 1 else 40

_f = open(LOG, "a", buffering=1)
_p = open(PARES, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush()
    print(s, flush=True)


def root(cmd):
    return subprocess.run(["sudo", "-S"] + cmd, input="grdg\n",
                          capture_output=True, text=True).stdout


hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]
hip.hipDeviceSynchronize.argtypes = []


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou: {r}")


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]
MAGIC = 0x5A5A0000_00000000

for e in ("amdgpu_vm_update_ptes", "amdgpu_vm_set_ptes"):
    root(["sh", "-c", f"echo 1 > {TRC}/events/amdgpu/{e}/enable"])
root(["sh", "-c", f"echo 'incr == 2097152' > {TRC}/events/amdgpu/amdgpu_vm_set_ptes/filter"])
root(["sh", "-c", f"echo 4096 > {TRC}/buffer_size_kb"])

boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say(f"=== boot={boot} pid={os.getpid()} ciclos={CICLOS} ===")
aquecer()
say("  aquecido")


def um_ciclo(n, com_varredura):
    root(["sh", "-c", f"echo > {TRC}/trace"])
    root(["sh", "-c", f"echo 1 > {TRC}/tracing_on"])

    blocos = []
    for rodada in ("A", "B"):
        for t in TAM:
            p = ctypes.c_void_p()
            ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
            blocos.append((f"{rodada}{t}", p, t))
    # A memoria e write-combining: escrever 8 bytes e sincronizar a GPU NAO
    # garante que o marcador chegou na memoria -- hipDeviceSynchronize nao
    # descarrega buffer de WC da CPU. A primeira versao deste script fazia
    # exatamente isso e produziu 7 "divergencias" em TODOS os 40 ciclos, sempre
    # nos mesmos blocos e em anel fechado: cada bloco via o marcador da geracao
    # anterior daquele endereco. 1889 pares de puro artefato.
    #
    # Duas travas: encher 4 KiB por pagina, o que forca o WC a descarregar, e
    # CONFERIR pela CPU que o marcador esta la antes de perguntar a GPU. Bloco
    # que nao passar e descartado em vez de virar par.
    marca = {}
    for k, (rot, p, t) in enumerate(blocos):
        for off in range(0, t, 2 << 20):
            ctypes.memset(p.value + off, 0xAA, min(4096, t - off))
            ctypes.memmove(p.value + off, struct.pack("<Q", MAGIC | k), 8)
    ck(hip.hipDeviceSynchronize(), "sync")
    descartados = 0
    for k, (rot, p, t) in enumerate(blocos):
        v = struct.unpack("<Q", bytes((ctypes.c_ubyte * 8).from_address(p.value)))[0]
        marca[k] = (v == (MAGIC | k))
        if not marca[k]:
            descartados += 1

    root(["sh", "-c", f"echo 0 > {TRC}/tracing_on"])
    trace = root(["cat", f"{TRC}/trace"])

    # PA de cada bloco. O trace foi limpo neste ciclo, entao so existe uma
    # geracao de mapeamento e nao ha ambiguidade de qual entrada e de quem.
    seq = []
    pend = None
    for ln in trace.splitlines():
        m = re.search(r'update_ptes: .*start:0x([0-9a-f]+) .*flags:0x([0-9a-f]+)', ln)
        if m:
            pend = (int(m.group(1), 16), int(m.group(2), 16)); continue
        m = re.search(r'set_ptes: pe=([0-9a-f]+), addr=([0-9a-f]+)', ln)
        if m and pend:
            seq.append((pend[0], pend[1], int(m.group(2), 16))); pend = None
    pa = {}
    for k, (rot, p, t) in enumerate(blocos):
        c = [a for s, fl, a in seq if s == (p.value >> 12) and (fl & 1)]
        if c:
            pa[k] = c[-1]

    if com_varredura:
        # ancora de integridade: confirma a base do FB uma vez por processo
        r = root(["python3", os.path.expanduser("~/bc250-grimoire/varrer_vram.py"),
                  hex(MAGIC), str(VRAM)])
        ach = {}
        for ln in r.splitlines():
            m = re.match(r'(\d+) ([0-9a-f]+)', ln)
            if m:
                ach.setdefault(int(m.group(1)), []).append(int(m.group(2), 16))
        bases = {}
        for k, offs in ach.items():
            if k in pa:
                for o in offs:
                    bases.setdefault(pa[k] - o, []).append(k)
        if not bases:
            say("  ABORTADO: varredura nao achou marcador nenhum"); return None
        b, quem = max(bases.items(), key=lambda kv: len(kv[1]))
        say(f"  ciclo {n} ancora: base=0x{b:x} confere em {len(quem)} de {len(pa)} blocos")
        faltam = [blocos[k][0] for k in pa if k not in quem]
        if faltam:
            say(f"  ciclo {n}: blocos cujo marcador NAO esta no PA da PTE: {faltam}")
        if b != BASE_ESPERADA:
            say(f"  ABORTADO: base 0x{b:x} != esperada 0x{BASE_ESPERADA:x}")
            return None

    if descartados:
        say(f"  ciclo {n}: {descartados} blocos sem marcador confirmado, descartados")
    achados = 0
    for k, (rot, p, t) in enumerate(blocos):
        if not marca[k]:
            continue
        buf = (ctypes.c_ubyte * 8)()
        ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(8), D2H), "hipMemcpy")
        got = struct.unpack("<Q", bytes(buf))[0]
        outro = got - MAGIC if (got >> 48) == 0x5A5A else None
        if outro == k:
            continue
        # so conta se a origem tambem teve marcador confirmado pela CPU
        if outro is not None and outro < len(blocos) and not marca.get(outro, False):
            continue
        achados += 1
        pe = pa.get(k)
        pd = pa.get(outro) if outro is not None else None
        _p.write(f"{n}\t{rot}\t{t}\t0x{p.value:x}\t"
                 f"{'0x%x' % pe if pe else '?'}\t"
                 f"{blocos[outro][0] if outro is not None and outro < len(blocos) else '?'}\t"
                 f"{'0x%x' % pd if pd else '?'}\n")
        _p.flush()

    for rot, p, t in blocos:
        hip.hipFree(p)
    return achados


ok = 0
for n in range(1, CICLOS + 1):
    # Varredura nos DOIS primeiros ciclos, nao so no primeiro. O ciclo 1 (com
    # varredura) da zero divergencias e os seguintes dao 10 -- ou a varredura
    # muda alguma coisa, ou a divergencia dos ciclos 2+ e artefato da minha
    # escrita de marcador. Comparar os dois com a mesma verificacao decide.
    r = um_ciclo(n, com_varredura=(n <= 2))
    if r is None:
        break
    ok += 1
    if r:
        say(f"  ciclo {n}: {r} pares")

say(f"  {ok} ciclos completos; pares acumulados em {PARES}")
for e in ("amdgpu_vm_update_ptes", "amdgpu_vm_set_ptes"):
    root(["sh", "-c", f"echo 0 > {TRC}/events/amdgpu/{e}/enable"])
say("FIM")
