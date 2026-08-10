#!/usr/bin/env python3
"""Full matrix: who writes x who reads, block by block.

Why the matrix is needed
------------------------
Every previous test measured a single pair, and each pair alone is ambiguous:

    CPU writes -> CPU reads    correct     (host mappings consistent with each other)
    GPU writes -> GPU reads    wrong       (the aliasing)
    GPU writes -> CPU reads    divergent   (one block: GPU reads right, CPU reads ZERO)

That "CPU reads ZERO" is what changes everything: it is not stale data from
another buffer, it is the content of a freshly cleared BO. For that pointer, the
CPU mapping and the GPU mapping resolve to DIFFERENT physical memory. And I never
verified that both sides point at the same place -- only that the CPU mappings
were consistent with each other.

Already ruled out as a cause: BO eviction/movement by TTM. There are 12288 MiB of
VRAM with 19 MiB in use, and evict_vram and evict_gtt are both zero.

The four phases
---------------
    1. CPU writes V1, CPU reads    control: do the host mappings match?
    2. GPU reads (hipMemcpy D2H)   does the GPU see what the CPU wrote?
    3. GPU writes V2 (hipMemset)
    4. CPU reads                   does the CPU see what the GPU wrote?

    divergence in phase 2   -> CPU and GPU read different physical memory
    phase 2 ok, 4 diverges  -> the GPU write does not reach memory (cache)

hipMemcpy D2H also reads through the GPU (it uses SDMA/blit), so it serves as
"read by the GPU". The CPU read is direct on the mapped pointer.
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


# Writes into the kernel trace so that this process's addresses show up
# INTERLEAVED with the amdgpu events. Correlating through separate files
# already led me to compare one trace against another run's repro; this way trace
# and reproducer become a single artifact, with guaranteed temporal ordering.
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
    """Which block did this byte come from, if any."""
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
