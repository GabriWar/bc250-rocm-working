#!/usr/bin/env python3
"""Triangula o mesmo dado por tres caminhos independentes.

O que ja esta estabelecido
--------------------------
A GPU le e escreve consistentemente a memoria de outro bloco; a CPU e coerente
consigo mesma e nao e afetada. Reproduz em ~83% das execucoes. E o trace das
escritas de PTE mostra que as tabelas de pagina estao CORRETAS: cada bloco
recebe cobertura exata do tamanho dele, com enderecos fisicos coerentes, e as
faixas de blocos diferentes nao se cruzam.

Ja excluidos, cada um com medida propria: MIOpen, fila de compute, staging do
ROCclr e seu tamanho, SDMA, corrida entre transferencias, tempo de vida do
buffer de host, alocador do PyTorch, mapeamento de host, bc250_flush_mapped_vmids
(5/6 vs 5/6), vm_update_mode CPU vs SDMA (10/12 vs 5/6), evicção por TTM, e as
proprias tabelas de pagina.

A pergunta que sobra
--------------------
Se a PTE aponta para o endereco fisico certo e a GPU ainda le outra coisa, o
defeito esta ABAIXO da tabela de pagina. Para provar isso falta um terceiro
observador: ler a memoria pelo ENDERECO FISICO, sem passar por VA nenhum.

O debugfs amdgpu_vram faz exatamente isso -- o offset de leitura e endereco de
VRAM. Entao para o mesmo bloco:

    CPU pelo VA      o que o BO realmente contem
    GPU pelo VA      o que a GPU entrega (sabidamente errado as vezes)
    CPU pelo PA      o que existe no endereco fisico que a PTE aponta

    PA contem o dado do bloco   -> a PTE esta certa e a GPU le fora dela:
                                   defeito abaixo da tabela (controlador/L2)
    PA contem dado de OUTRO     -> a PTE aponta para o BO errado apesar de a
                                   analise de faixas nao ter mostrado cruzamento

Calibracao da base
------------------
O `addr` da PTE e endereco de MC, nao offset de VRAM: em gmc_v10,
vram_base_offset = gfxhub.get_mc_fb_offset(). Em vez de deduzir a formula, a
base e descoberta empiricamente -- um bloco que NAO diverge tem que conter o
proprio marcador no PA dele, e a base que faz isso acontecer e a certa.
"""
import ctypes
import os
import re
import sys
import struct
import subprocess

import numpy as np

import torch

DEV = "cuda"
D2H = 2
TRC = "/sys/kernel/tracing"
OUT = os.path.expanduser("~/bc250-grimoire/triangular.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def root(cmd):
    return subprocess.run(["sudo", "-S"] + cmd, input="grdg\n",
                          capture_output=True, text=True).stdout


def root_bin(cmd):
    return subprocess.run(["sudo", "-S"] + cmd, input=b"grdg\n",
                          capture_output=True).stdout


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
VRAM = 12288 * 1024 * 1024

say("")
say("=" * 70)
say(f"boot={open('/proc/sys/kernel/random/boot_id').read().strip()[:8]} pid={os.getpid()}")

for e in ("amdgpu_vm_update_ptes", "amdgpu_vm_set_ptes"):
    root(["sh", "-c", f"echo 1 > {TRC}/events/amdgpu/{e}/enable"])
root(["sh", "-c", f"echo 'incr == 2097152' > {TRC}/events/amdgpu/amdgpu_vm_set_ptes/filter"])
root(["sh", "-c", f"echo 16384 > {TRC}/buffer_size_kb"])
root(["sh", "-c", f"echo > {TRC}/trace"])
root(["sh", "-c", f"echo 1 > {TRC}/tracing_on"])

aquecer()
# Terceiro modo, "vaVirgem": em vez de liberar a rotatividade, ela e MANTIDA
# viva. Assim o alocador de VA do ROCr nao tem faixa liberada para reciclar e os
# blocos de teste caem em enderecos virtuais nunca usados antes.
#
# Isso separa o que o discriminador anterior nao separou. Aquele comparava o PA
# entregue com o historico do proprio VA, mas 0x176000000 aparece no historico de
# quase todo VA -- e um PA reciclado o tempo todo, porque a rotatividade aloca as
# mesmas formas na mesma ordem. "Ja foi deste VA" era quase sempre verdade por
# acaso.
#
#   VA virgem e limpo    -> o perigo e o reuso de VA (traducao velha)
#   VA virgem e corrompe -> o endereco fisico e que aliasa
VIRGEM = len(sys.argv) > 3 and sys.argv[3] == "vaVirgem"
segurados = []
for _ in range(3):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        tmp.append(p)
    if VIRGEM:
        segurados.extend(tmp)
    else:
        for p in tmp:
            ck(hip.hipFree(p), "hipFree")
say(f"  modo de VA: {'VIRGEM (rotatividade segurada)' if VIRGEM else 'reusado (rotatividade liberada)'}")

blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada}{t}", p, t))

# marcador de 8 bytes unico por bloco, escrito pela CPU no inicio de cada
# pagina de 2 MiB -- assim qualquer leitura fisica de 2 MiB alinhada o encontra
MAGIC = 0x5A5A0000_00000000
for k, (rot, p, t) in enumerate(blocos):
    ctypes.memset(p, 0xAA, min(t, 4096))
    for off in range(0, t, 2 << 20):
        ctypes.memmove(p.value + off, struct.pack("<Q", MAGIC | k), 8)
ck(hip.hipDeviceSynchronize(), "sync")

root(["sh", "-c", f"echo 0 > {TRC}/tracing_on"])
trace = root(["cat", f"{TRC}/trace"])

# --- o que a GPU entrega para cada bloco ---
say("  --- o que a GPU entrega, pelo VA ---")
divergentes = []
for k, (rot, p, t) in enumerate(blocos):
    buf = (ctypes.c_ubyte * 8)()
    ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(8), D2H), "hipMemcpy")
    got = struct.unpack("<Q", bytes(buf))[0]
    dono = got - MAGIC if (got >> 48) == 0x5A5A else None
    if dono != k:
        divergentes.append(k)
        say(f"    {rot}: GPU viu marcador de bloco {dono} (esperado {k})")
if not divergentes:
    say("    todos coerentes -- execucao limpa")

# --- PA de cada bloco, do trace ---
pa = {}
seq = []
pend = None
for ln in trace.splitlines():
    m = re.search(r'update_ptes: .*start:0x([0-9a-f]+) end:0x([0-9a-f]+), flags:0x([0-9a-f]+)', ln)
    if m:
        pend = (int(m.group(1), 16), int(m.group(3), 16)); continue
    m = re.search(r'set_ptes: pe=([0-9a-f]+), addr=([0-9a-f]+)', ln)
    if m and pend:
        seq.append((pend[0], pend[1], int(m.group(2), 16))); pend = None
for k, (rot, p, t) in enumerate(blocos):
    pg = p.value >> 12
    cand = [a for s, fl, a in seq if s == pg and (fl & 1)]
    if cand:
        pa[k] = cand[-1]

say(f"  --- PA do inicio de {len(pa)} de {len(blocos)} blocos ---")

# --- calibra a base lendo VRAM por endereco fisico ---
# Varre a VRAM inteira nos offsets alinhados em 2 MiB procurando os marcadores.
# Isso dispensa descobrir a base do FB: em vez de converter o `addr` da PTE em
# offset, descobre-se empiricamente ONDE cada bloco realmente mora, e a base cai
# como subproduto (base = addr_da_pte - offset_encontrado).
say("  --- varrendo a VRAM pelos marcadores (6144 leituras de 8 bytes) ---")
achados = {}
r = root(["python3", os.path.expanduser("~/bc250-grimoire/varrer_vram.py"),
          hex(MAGIC), str(VRAM)])
for ln in r.splitlines():
    m = re.match(r'(\d+) ([0-9a-f]+)', ln)
    if m:
        achados.setdefault(int(m.group(1)), []).append(int(m.group(2), 16))
say(f"    marcadores encontrados: {len(achados)} blocos distintos")

bases = {}
for k, offs in sorted(achados.items()):
    if k in pa:
        for o in offs:
            bases.setdefault(pa[k] - o, []).append(k)
if bases:
    b, quem_ok = max(bases.items(), key=lambda kv: len(kv[1]))
    say(f"    base do FB: 0x{b:x}  (confere em {len(quem_ok)} de {len(pa)} blocos)")
else:
    b = None

# A varredura fisica confirmou onde o dado esta. Reler pela GPU AGORA fecha o
# unico buraco que sobrava: se a escrita da CPU (memoria write-combining) so
# tivesse chegado a memoria depois da primeira leitura, a GPU teria lido dado
# velho em vez de lugar errado. Se continuar errado com o dado comprovadamente
# na memoria, essa explicacao cai.
say("  --- releitura pela GPU, apos a varredura confirmar a memoria ---")
for k in list(divergentes):
    buf = (ctypes.c_ubyte * 8)()
    ck(hip.hipMemcpy(buf, blocos[k][1], ctypes.c_size_t(8), D2H), "hipMemcpy(2)")
    got = struct.unpack("<Q", bytes(buf))[0]
    dono = got - MAGIC if (got >> 48) == 0x5A5A else None
    say(f"    {blocos[k][0]}: GPU agora ve marcador {dono} (esperado {k}) "
        f"[bruto 0x{got:x}]")
    if dono == k:
        say("      => acertou na segunda: era ordenacao de escrita da CPU, nao lugar errado")

# ---- relacao em BITS entre o PA que a PTE manda e o PA de onde o dado veio ----
# Se o defeito for de decodificacao de endereco (interleave de canal, linha de
# endereco presa, hash do data fabric), o par certo-x-entregue tem relacao fixa:
# XOR com poucos bits, ou sempre os mesmos bits. Se for aleatorio, nao e decode.
# O PA entregue e sempre 0x176000000 ou 0x176800000, enquanto os esperados se
# espalham. Duas explicacoes preveem isso:
#
#   (a) esses enderecos fisicos aliasam de verdade -> reservar as paginas resolve
#   (b) a GPU usa uma traducao VELHA daquele mesmo VA, de uma geracao anterior da
#       rotatividade, presa numa cache que o flush de TLB nao alcanca. Como o
#       alocador e deterministico, a geracao anterior cai sempre no mesmo PA.
#
# O que separa: o PA entregue esta entre os que ESTE VA ja apontou antes?
say("  --- o PA entregue e uma traducao antiga deste mesmo VA? ---")
hist = {}
for k, (rot, p_, t_) in enumerate(blocos):
    pg = p_.value >> 12
    hist[k] = [a for s_, fl_, a in seq if s_ == pg and (fl_ & 1)]
say("  --- relacao de bits entre esperado e entregue ---")
for k in divergentes:
    if k not in pa:
        continue
    buf = (ctypes.c_ubyte * 8)()
    ck(hip.hipMemcpy(buf, blocos[k][1], ctypes.c_size_t(8), D2H), "hipMemcpy(3)")
    got = struct.unpack("<Q", bytes(buf))[0]
    outro = got - MAGIC if (got >> 48) == 0x5A5A else None
    if outro is None or outro not in pa:
        say(f"    {blocos[k][0]}: entregou 0x{got:x}, sem bloco identificavel")
        continue
    pe, pd = pa[k], pa[outro]
    x = pe ^ pd
    say(f"    {blocos[k][0]}: esperado PA 0x{pe:x}  entregue PA 0x{pd:x}")
    say(f"      XOR = 0x{x:x}  ({bin(x).count('1')} bits)  bits: "
        f"{[i for i in range(48) if x >> i & 1]}")
    say(f"      diferenca = {pd - pe:+d} (0x{abs(pd-pe):x})")
    ger = hist.get(k, [])
    say(f"      geracoes anteriores deste VA: {[hex(a) for a in ger]}")
    if pd in ger:
        say(f"      >>> 0x{pd:x} JA FOI o PA deste VA: e traducao velha, nao alias fisico")
    else:
        say(f"      >>> 0x{pd:x} NUNCA foi o PA deste VA: o endereco fisico e que aliasa")

say("  --- triangulacao ---")
for k in divergentes:
    off_real = achados.get(k, [])
    esperado = (pa[k] - b) if (b is not None and k in pa) else None
    say(f"    {blocos[k][0]}: PTE aponta 0x{pa.get(k, 0):x}"
        f"{f' -> offset 0x{esperado:x}' if esperado is not None else ''}")
    say(f"      o dado deste bloco esta de fato em: "
        f"{[hex(o) for o in off_real] or 'NAO ENCONTRADO'}")
    if esperado is not None and off_real:
        if esperado in off_real:
            say("      => a PTE aponta para o lugar CERTO e a GPU le fora dele:")
            say("      => defeito ABAIXO da tabela de pagina")
        else:
            dono = [kk for kk, oo in achados.items() if esperado in oo]
            say(f"      => a PTE aponta para onde mora o bloco {dono or '?'}:")
            say("      => a entrada de tabela de pagina esta errada")

# ---- le os BYTES REAIS da tabela de pagina ----
# Ate aqui foi verificado o que o driver ESCREVEU (via tracepoint), nao o que
# esta na memoria no momento do acesso. As tabelas moram na mesma VRAM: se a
# corrupcao as atinge, as escritas apareceriam corretas enquanto o hardware le
# uma entrada estragada. Este bloco fecha esse furo.
if divergentes and b is not None:
    say("  --- lendo os bytes reais das PTEs (varredura de 12 GiB, ~100 s) ---")
    alvos = sorted({pa[k] for k in pa})
    r = root(["python3", os.path.expanduser("~/bc250-grimoire/varrer_ptes.py"),
              ",".join(f"{a:x}" for a in alvos)])
    slots = {}
    for ln in r.splitlines():
        m = re.match(r'([0-9a-f]+) ([0-9a-f]+)', ln)
        if m:
            slots[int(m.group(1), 16)] = int(m.group(2), 16)
    say(f"    entradas encontradas apontando para PAs conhecidos: {len(slots)}")

    MASC = 0x0000FFFFFFFFF000
    # de qual bloco e cada entrada achada
    de_quem = {}
    for off, val in slots.items():
        for k, a in pa.items():
            if (val & MASC) == (a & MASC):
                de_quem.setdefault(k, []).append((off, val))

    for k in divergentes:
        if k not in pa:
            continue
        meus = de_quem.get(k, [])
        say(f"    {blocos[k][0]}: PTE deveria valer addr=0x{pa[k]:x}")
        say(f"      entradas na memoria apontando para esse PA: {len(meus)}")
        for off, val in meus[:4]:
            say(f"        slot 0x{off:x} = 0x{val:x}")
        if not meus:
            say("      => NENHUMA entrada na memoria aponta para o PA que o driver")
            say("      => escreveu: a tabela de pagina foi CORROMPIDA depois da escrita")
        else:
            # vizinhos no mesmo bloco de 4 KiB: cobrem VAs adjacentes
            off0 = meus[0][0]
            tab = off0 & ~0xFFF
            idx = (off0 - tab) // 8
            say(f"      tabela em 0x{tab:x}, esta entrada e o indice {idx}")
            viz = root(["python3", "-c",
                        "import os,struct,sys;fd=os.open('/sys/kernel/debug/dri/1/amdgpu_vram',os.O_RDONLY);"
                        f"d=os.pread(fd,4096,{tab});"
                        "print(' '.join(f'{v:x}' for v in struct.unpack('<512Q',d)))"])
            vs = [int(x, 16) for x in viz.split()] if viz.strip() else []
            if vs:
                vals = [v for v in vs if v & 1]
                say(f"      entradas validas nessa tabela: {len(vals)} de 512")
                dup = {}
                for i, v in enumerate(vs):
                    if v & 1:
                        dup.setdefault(v & MASC, []).append(i)
                rep = {a: ii for a, ii in dup.items() if len(ii) > 1}
                if rep:
                    say(f"      >>> {len(rep)} enderecos fisicos aparecem em MAIS DE UMA entrada:")
                    for a, ii in list(rep.items())[:5]:
                        say(f"            PA 0x{a:x} nos indices {ii}")
                else:
                    say("      nenhum PA repetido nessa tabela")

for e in ("amdgpu_vm_update_ptes", "amdgpu_vm_set_ptes"):
    root(["sh", "-c", f"echo 0 > {TRC}/events/amdgpu/{e}/enable"])
for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
