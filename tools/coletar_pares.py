#!/usr/bin/env python3
"""Collects the (expected PA, delivered PA) pairs of the GPU aliasing at scale.

Why at scale
------------
With few samples two invariants showed up that vanished once n grew:

  batch 1 (6 samples)  the DELIVERED PA was always 0x176000000 or 0x176800000
  batch 2 (2 samples)  the EXPECTED PA was always 0x170000000, delivered varied

The two readings contradict each other, and each one alone would have justified a
different patch -- physical page reservation in one, nothing in the other. Also
refuted, with 4 runs per arm: VA range reuse is not the trigger (1/4 against 2/4).

So what is missing is volume, not one more hypothesis. This script exists to
answer whether there is ANY invariant in the pairs, not to test a hunch.

How it got fast without losing integrity
----------------------------------------
The old cost was ~160 s per sample: 40 s of warmup, ~110 s scanning the 12 GiB
of VRAM and ~10 s of test. The scans served to calibrate the FB base and to
prove that physical memory holds the right data -- already done, 11 of 11 blocks
matched, base 0x170000000.

Here:
  - the full scan runs ONCE per process, on the first cycle, only to confirm the
    base. If it does not confirm, the process aborts instead of producing data
    under the wrong frame of reference.
  - the warmup runs ONCE and applies to every cycle.
  - each subsequent cycle costs seconds: allocate, mark, read, record, free.

The trace is cleared every cycle, so the PTE-to-block attribution has no
generation ambiguity -- the mistake that already made me read one run's trace
against another run's repro.

Output: one line per pair, in ~/bc250-grimoire/pares.tsv
    cycle  block  size  va  expected_pa  delivered_block  delivered_pa
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
    # The memory is write-combining: writing 8 bytes and syncing the GPU does NOT
    # guarantee the marker reached memory -- hipDeviceSynchronize does not flush
    # the CPU's WC buffer. The first version of this script did exactly that and
    # produced 7 "divergences" in ALL 40 cycles, always in the same blocks and in a
    # closed ring: each block saw the marker of the previous generation of that
    # address. 1889 pairs of pure artifact.
    #
    # Two safeguards: fill 4 KiB per page, which forces the WC buffer to flush, and
    # VERIFY from the CPU that the marker is there before asking the GPU. A block
    # that does not pass is discarded instead of becoming a pair.
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

    # PA of each block. The trace was cleared this cycle, so only one mapping
    # generation exists and there is no ambiguity about which entry belongs to whom.
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
        # integrity anchor: confirms the FB base once per process
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
        # only counts if the source also had its marker confirmed by the CPU
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
    # Scan on the FIRST TWO cycles, not just the first. Cycle 1 (with the
    # scan) gives zero divergences and the following ones give 10 -- either the scan
    # changes something, or the divergence of cycles 2+ is an artifact of my
    # marker writing. Comparing the two under the same verification decides it.
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
