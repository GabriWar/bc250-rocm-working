#!/usr/bin/env python3
"""Does the GPU fail on WRITE or on READ?

What is already measured
------------------------
Two live hipMalloc blocks, distinct BOs in /proc/pid/maps, that the GPU treats as
the same memory. Reproduces in ~83% of runs. Survives forced TLB invalidation and
rewriting. Does not change with vm_update_mode 3 (tables written by the CPU) or 0
(written by SDMA): 10/12 against 5/6.

The hole in what I was measuring
--------------------------------
So far the pairs were always homogeneous:

    CPU writes  -> CPU reads    correct
    GPU writes  -> GPU reads    wrong

That does not separate write from read. The crossed case is missing, and it
decides:

    GPU writes  -> CPU reads    if the CPU sees the RIGHT value in the block, the
                                GPU's write went to the right physical place and
                                what fails is the GPU's READ path
                                if the CPU sees the WRONG value, the GPU's write
                                went to the wrong place

The CPU read is done directly on the mapped pointer (the same VA), without going
through hipMemcpy -- hipMemcpy uses SDMA/blit and therefore reads through the
GPU, which is precisely the path under suspicion.
"""
import ctypes
import os
import sys

import numpy as np

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/escrita_ou_leitura.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


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

boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say("=" * 70)
say(f"boot={boot} pid={os.getpid()} vm_update_mode="
    f"{open('/sys/module/amdgpu/parameters/vm_update_mode').read().strip()}")
aquecer()

for _ in range(3):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append(p)
    for p in tmp:
        ck(hip.hipFree(p), "hipFree")

blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada} {t}B", p, t))

# the GPU writes a unique value into each block
for k, (rot, p, t) in enumerate(blocos):
    ck(hip.hipMemset(p, ctypes.c_int(k + 1), ctypes.c_size_t(t)), "hipMemset")
ck(hip.hipDeviceSynchronize(), "sync")

achou = 0
for k, (rot, p, t) in enumerate(blocos):
    esperado = k + 1

    # read 1: from the CPU, directly on the mapped pointer
    cpu = np.frombuffer((ctypes.c_ubyte * t).from_address(p.value), dtype=np.uint8)
    d_cpu = cpu != esperado
    n_cpu = int(d_cpu.sum())

    # read 2: via hipMemcpy, which uses SDMA/blit and therefore reads through the GPU
    buf = (ctypes.c_ubyte * t)()
    ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(t), D2H), "hipMemcpy")
    gpu = np.frombuffer(buf, dtype=np.uint8)
    d_gpu = gpu != esperado
    n_gpu = int(d_gpu.sum())

    if not (n_cpu or n_gpu):
        continue
    achou += 1

    def quem(arr, d):
        i0 = int(np.argmax(d))
        o = int(arr[i0]) - 1
        return (blocos[o][0] if 0 <= o < len(blocos) else f"byte {int(arr[i0])}"), i0

    say(f"  {rot} @0x{p.value:x} esperado={esperado}")
    if n_cpu:
        q, i0 = quem(cpu, d_cpu)
        say(f"    CPU  le errado: {n_cpu} bytes de \"{q}\" a partir de {i0}")
    else:
        say(f"    CPU  le CERTO")
    if n_gpu:
        q, i0 = quem(gpu, d_gpu)
        say(f"    GPU  le errado: {n_gpu} bytes de \"{q}\" a partir de {i0}")
    else:
        say(f"    GPU  le CERTO")

    if n_gpu and not n_cpu:
        say("    => a escrita da GPU foi para o lugar CERTO; quem erra e a LEITURA")
    elif n_cpu and n_gpu:
        say("    => a escrita da GPU foi para o lugar ERRADO")
    elif n_cpu and not n_gpu:
        say("    => so a CPU ve errado -- inesperado, checar coerencia de cache")

if not achou:
    say("  execucao limpa")
for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
