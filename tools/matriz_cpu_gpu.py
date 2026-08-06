#!/usr/bin/env python3
"""Matriz completa: quem escreve x quem le, bloco a bloco.

Por que precisa da matriz
-------------------------
Cada teste anterior mediu um par so, e cada par sozinho e ambiguo:

    CPU escreve -> CPU le    correto      (mapeamentos de host consistentes entre si)
    GPU escreve -> GPU le    errado       (o aliasing)
    GPU escreve -> CPU le    divergente   (um bloco: GPU le certo, CPU le ZERO)

Aquele "CPU le ZERO" e o que muda tudo: nao e dado velho de outro buffer, e
conteudo de BO recem-limpo. Para aquele ponteiro, o mapeamento da CPU e o da GPU
resolvem para memoria fisica DIFERENTE. E eu nunca verifiquei que os dois lados
apontam para o mesmo lugar -- so que os mapeamentos de CPU eram consistentes
entre si.

Ja descartado como causa: evicção/movimento de BO por TTM. Sao 12288 MiB de VRAM
com 19 MiB em uso, e evict_vram e evict_gtt estao os dois em zero.

As quatro fases
---------------
    1. CPU escreve V1, CPU le      controle: os mapeamentos de host batem?
    2. GPU le (hipMemcpy D2H)      a GPU enxerga o que a CPU escreveu?
    3. GPU escreve V2 (hipMemset)
    4. CPU le                      a CPU enxerga o que a GPU escreveu?

    divergencia na fase 2  -> CPU e GPU leem memoria fisica diferente
    fase 2 ok e 4 diverge  -> a escrita da GPU nao chega a memoria (cache)

hipMemcpy D2H tambem le pela GPU (usa SDMA/blit), entao serve como "leitura da
GPU". A leitura da CPU e direta no ponteiro mapeado.
"""
import ctypes
import os

import numpy as np

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/matriz_cpu_gpu.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


# Escreve no trace do kernel para que os enderecos deste processo apareçam
# INTERCALADOS com os eventos do amdgpu. Correlacionar por arquivos separados
# ja me levou a comparar um trace com o repro de outra execucao; assim trace e
# reprodutor viram um artefato so, com a ordem temporal garantida.
try:
    _mk = open("/sys/kernel/tracing/trace_marker", "w")
except OSError:
    _mk = None


def marcar(s):
    if _mk:
        _mk.write(s + "\n"); _mk.flush()
    say("  # " + s)


D2H = 2
hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemset.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_size_t]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou com codigo {r}")


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

say("")
say("=" * 70)
say(f"boot={open('/proc/sys/kernel/random/boot_id').read().strip()[:8]} pid={os.getpid()}")
aquecer()

for _ in range(3):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append(p)
    for p in tmp:
        ck(hip.hipFree(p), "hipFree")

marcar("REPRO: fim da rotatividade, comecando as alocacoes do teste")
blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada} {t}B", p, t))
        marcar(f"REPRO: bloco {rodada} {t}B va=0x{p.value:x} pag=0x{p.value>>12:x} "
               f"fim_pag=0x{(p.value+t+4095)>>12:x}")
marcar("REPRO: todas as 12 alocacoes feitas")


def ver_cpu(p, t):
    return np.frombuffer((ctypes.c_ubyte * t).from_address(p.value), dtype=np.uint8)


def ver_gpu(p, t):
    buf = (ctypes.c_ubyte * t)()
    ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(t), D2H), "hipMemcpy")
    return np.frombuffer(buf, dtype=np.uint8)


def quem(v):
    """De qual bloco esse byte veio, se de algum."""
    for base, rot in ((10, "V1"), (100, "V2")):
        k = int(v) - base
        if 0 <= k < len(blocos):
            return f"{blocos[k][0]}({rot})"
    return f"byte {int(v)}"


def conferir(fase, leitor, valores):
    ruins = 0
    for k, (rot, p, t) in enumerate(blocos):
        arr = leitor(p, t)
        d = arr != valores[k]
        n = int(d.sum())
        if not n:
            continue
        ruins += 1
        i0 = int(np.argmax(d))
        say(f"    {rot}: {n} de {t} bytes errados, viu \"{quem(arr[i0])}\" "
            f"(esperado {valores[k]}) a partir de {i0}")
    say(f"  fase {fase}: {ruins} de {len(blocos)} blocos divergentes")
    marcar(f"REPRO: fim da fase {fase}, {ruins} divergentes")
    return ruins


V1 = [10 + k for k in range(len(blocos))]
V2 = [100 + k for k in range(len(blocos))]

marcar("REPRO: comeca fase 1")
say("  --- fase 1: CPU escreve, CPU le (controle) ---")
for k, (rot, p, t) in enumerate(blocos):
    ctypes.memset(p, V1[k], t)
r1 = conferir(1, ver_cpu, V1)

say("  --- fase 2: a GPU enxerga o que a CPU escreveu? ---")
ck(hip.hipDeviceSynchronize(), "sync")
r2 = conferir(2, ver_gpu, V1)

say("  --- fase 3+4: GPU escreve, CPU le ---")
for k, (rot, p, t) in enumerate(blocos):
    ck(hip.hipMemset(p, ctypes.c_int(V2[k]), ctypes.c_size_t(t)), "hipMemset")
ck(hip.hipDeviceSynchronize(), "sync")
r4 = conferir(4, ver_cpu, V2)

say("  --- fase 5: e a GPU relendo o que ela mesma escreveu ---")
r5 = conferir(5, ver_gpu, V2)

say("")
say(f"  RESUMO  cpu->cpu={r1}  cpu->gpu={r2}  gpu->cpu={r4}  gpu->gpu={r5}")
if r2:
    say("  => CPU e GPU leem memoria fisica DIFERENTE (divergencia de mapeamento)")
elif r4 and not r2:
    say("  => a escrita da GPU nao chega a memoria visivel pela CPU (cache)")
elif not (r1 or r2 or r4 or r5):
    say("  => execucao limpa")

for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
