#!/usr/bin/env python3
"""Triangulates the same data through three independent paths.

What is already established
---------------------------
The GPU consistently reads and writes another block's memory; the CPU is coherent
with itself and is not affected. Reproduces in ~83% of runs. And the trace of PTE
writes shows the page tables are CORRECT: each block gets coverage of exactly its
size, with coherent physical addresses, and the ranges of different blocks do not
intersect.

Already excluded, each with its own measurement: MIOpen, the compute queue,
ROCclr staging and its size, SDMA, races between transfers, host buffer lifetime,
PyTorch's allocator, host mapping, bc250_flush_mapped_vmids (5/6 vs 5/6),
vm_update_mode CPU vs SDMA (10/12 vs 5/6), TTM eviction, and the page tables
themselves.

The remaining question
----------------------
If the PTE points at the right physical address and the GPU still reads something
else, the defect is BELOW the page table. To prove that, a third observer is
missing: reading memory by PHYSICAL ADDRESS, without going through any VA.

The amdgpu_vram debugfs does exactly that -- the read offset is a VRAM address. So
for the same block:

    CPU via VA      what the BO actually contains
    GPU via VA      what the GPU delivers (known to be wrong sometimes)
    CPU via PA      what exists at the physical address the PTE points at

    PA holds the block's data  -> the PTE is right and the GPU reads outside it:
                                  defect below the table (controller/L2)
    PA holds ANOTHER's data    -> the PTE points at the wrong BO despite the range
                                  analysis showing no intersection

Base calibration
----------------
The PTE's `addr` is an MC address, not a VRAM offset: in gmc_v10,
vram_base_offset = gfxhub.get_mc_fb_offset(). Instead of deriving the formula, the
base is discovered empirically -- a block that does NOT diverge must contain its
own marker at its PA, and the base that makes that happen is the right one.
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
# Third mode, "vaVirgem": instead of freeing the churn, it is KEPT
# alive. That way ROCr's VA allocator has no freed range to recycle and the test
# blocks land at virtual addresses never used before.
#
# This separates what the previous discriminator did not. That one compared the
# delivered PA against the VA's own history, but 0x176000000 shows up in the
# history of almost every VA -- it is a PA recycled all the time, because the
# churn allocates the same shapes in the same order. "It was already this VA's"
# was almost always true by accident.
#
#   virgin VA is clean     -> the danger is VA reuse (stale translation)
#   virgin VA corrupts     -> it is the physical address that aliases
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

# unique 8-byte marker per block, written by the CPU at the start of each
# 2 MiB page -- that way any 2 MiB-aligned physical read finds it
MAGIC = 0x5A5A0000_00000000
for k, (rot, p, t) in enumerate(blocos):
    ctypes.memset(p, 0xAA, min(t, 4096))
    for off in range(0, t, 2 << 20):
        ctypes.memmove(p.value + off, struct.pack("<Q", MAGIC | k), 8)
ck(hip.hipDeviceSynchronize(), "sync")

root(["sh", "-c", f"echo 0 > {TRC}/tracing_on"])
trace = root(["cat", f"{TRC}/trace"])

# --- what the GPU delivers for each block ---
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

# --- PA of each block, from the trace ---
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

# --- calibrates the base by reading VRAM by physical address ---
# Scans the whole VRAM at 2 MiB-aligned offsets looking for the markers.
# That removes the need to figure out the FB base: instead of converting the PTE's
# `addr` into an offset, it empirically discovers WHERE each block really lives,
# and the base falls out as a by-product (base = pte_addr - found_offset).
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

# The physical scan confirmed where the data is. Re-reading through the GPU NOW
# closes the only remaining hole: if the CPU's write (write-combining memory) had
# only reached memory after the first read, the GPU would have read stale data
# instead of the wrong place. If it stays wrong with the data provably in memory,
# that explanation falls.
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

# ---- BIT relation between the PA the PTE points at and the PA the data came from ----
# If the defect is address decoding (channel interleave, stuck address line,
# data fabric hash), the correct-vs-delivered pair has a fixed relation:
# XOR with few bits, or always the same bits. If it is random, it is not decode.
# The delivered PA is always 0x176000000 or 0x176800000, while the expected ones
# are spread out. Two explanations predict that:
#
#   (a) those physical addresses really do alias -> reserving the pages fixes it
#   (b) the GPU uses a STALE translation of that same VA, from a previous churn
#       generation, stuck in a cache the TLB flush does not reach. Since the
#       allocator is deterministic, the previous generation always lands on the same PA.
#
# What separates them: is the delivered PA among the ones THIS VA pointed at before?
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

# ---- read the REAL BYTES of the page table ----
# So far what was verified is what the driver WROTE (via tracepoint), not what is
# in memory at the time of access. The tables live in the same VRAM: if the
# corruption reaches them, the writes would look correct while the hardware reads
# a mangled entry. This block closes that hole.
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
    # which block each found entry belongs to
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
            # neighbors in the same 4 KiB block: they cover adjacent VAs
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
