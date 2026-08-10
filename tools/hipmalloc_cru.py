#!/usr/bin/env python3
"""Is the aliasing in PyTorch's allocator or below it?

Measured before (sobreposicao.py, 6 out of 9 runs)
--------------------------------------------------
Two LIVE tensors, with different data_ptr and disjoint ranges, share memory:
filling one changes the other, across the whole tensor.

    ref c=320 h=104 @0x7efcdf000000  3461120 elements of "raj c=320 h=104"
    ref c=320 h=96  @0x7efcdf69a000  2949120 elements of "raj c=320 h=96"

Always between allocations of the SAME size, and whichever is filled last wins.
This happens with kernels and copies fully serialized (HIP_LAUNCH_BLOCKING=1,
AMD_SERIALIZE_KERNEL=3, AMD_SERIALIZE_COPY=3), so it is not a race.

And it happens with `fill_`, a compute kernel. It does not go through DMA,
staging, SDMA or MIOpen -- the whole copy path I had been investigating is out.

The remaining question
----------------------
Does PyTorch's allocator hand out the same block twice, or does it request
distinct blocks and whatever is below it (HIP / KFD / page tables) map both to
the same place?

This script skips PyTorch's allocator and calls hipMalloc directly via ctypes,
after warming up with PyTorch to reach the same state.

    aliasing with raw hipMalloc  -> the defect is below PyTorch
    no aliasing                  -> PyTorch's block cache is the culprit
"""
import ctypes
import os
import sys

import numpy as np

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/hipmalloc_cru.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


H2D, D2H = 1, 2
hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemset.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_size_t]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]
hip.hipDeviceSynchronize.argtypes = []


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou com codigo {r}")


def aquecer(modo="tudo"):
    """The warmup does two things at once: it allocates a lot and runs kernels.

    With no warmup at all the aliasing does not show up (0 of 6). With it, 5 of 6.
    To find out WHICH of the two halves causes it, each mode does only one:

      alloc  allocates and frees the same shapes, with no kernel at all
      conv   runs conv2d over pre-allocated buffers, allocating nothing new
      tudo   both, as it was before
    """
    import torch.nn.functional as F
    if modo in ("alloc", "tudo"):
        for _ in range(2):
            for h in range(32, 136, 8):
                for c in (64, 320):
                    x = torch.randn(1, c, h, h, dtype=torch.float16)
                    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                    xg, wg = x.to(DEV), w.to(DEV)
                    if modo == "tudo":
                        _ = F.conv2d(xg, wg, padding=1)
    if modo == "orig":
        # EXACTLY the original warmup. In the refactor I started holding the device
        # tensors in names (xg, wg), which keeps them alive until the next
        # assignment -- two live sets at peak instead of one. That alone made the
        # aliasing vanish, so the allocation pattern matters and the
        # alloc-vs-conv comparison is only valid against this reference.
        for _ in range(2):
            for h in range(32, 136, 8):
                for c in (64, 320):
                    x = torch.randn(1, c, h, h, dtype=torch.float16)
                    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                    _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    if modo == "so-alloc":
        # SAME allocations as orig, SAME lifetimes, zero kernels.
        # conv2d also allocates the output (padding=1, stride=1 -> same shape as the
        # input), so it goes here as torch.empty to make the allocation pattern
        # match. The previous attempt failed by holding the device tensors in
        # names that survived the iteration: two live sets at peak instead of one,
        # and the aliasing vanished. Here they live and die the same way.
        for _ in range(2):
            for h in range(32, 136, 8):
                for c in (64, 320):
                    x = torch.randn(1, c, h, h, dtype=torch.float16)
                    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                    a = x.to(DEV); b = w.to(DEV)
                    o = torch.empty(1, c, h, h, dtype=torch.float16, device=DEV)
                    del a, b, o
    if modo == "so-kernel":
        # SAME number of kernels, ZERO new allocation: everything is pre-allocated
        # and the operations are in-place.
        xg = torch.randn(1, 320, 112, 112, dtype=torch.float16, device=DEV)
        wg = torch.randn(320, 320, 3, 3, dtype=torch.float16, device=DEV)
        for _ in range(2 * 13 * 2 * 3):
            xg.mul_(1.0001)
            wg.mul_(0.9999)
    torch.cuda.synchronize()


# sizes equal to the reproducer's tensors, in bytes
TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say("=" * 70)
say(f"boot={boot} pid={os.getpid()}")

# Second argument: warm up or not. With churn=0 the aliasing still showed up 3/3,
# so it is not the free path. But PyTorch's warmup still runs before, and since
# the start of the investigation it is known that with no prior GPU activity
# nothing corrupts. This is the missing discriminator.
MODO = sys.argv[2] if len(sys.argv) > 2 else "tudo"
if MODO != "sem-aquecer":
    aquecer(MODO)
    say(f"  aquecimento modo={MODO}; agora hipMalloc cru")
else:
    torch.zeros(1, device=DEV); torch.cuda.synchronize()   # only creates the context
    say("  SEM aquecimento; so o contexto de HIP inicializado")

# How many allocate-and-free rounds before the test. The suspicion is that the
# trap is armed HERE: freed pages going back to a new VA without the matching
# TLB invalidation. If there is no aliasing with 0 rounds, the defect is in the
# unmap path, not the map path.
CHURN = int(sys.argv[1]) if len(sys.argv) > 1 else 3
say(f"  rodadas de alocar-e-liberar antes do teste: {CHURN}")
for _ in range(CHURN):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append(p)
    for p in tmp:
        ck(hip.hipFree(p), "hipFree")

# two rounds of the same shapes, all alive at the same time
blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada} {t}B", p, t))

for rot, p_, n_ in blocos:
    say(f"  BLOCO {rot} @0x{p_.value:x} +{n_}")

# arithmetic overlap of the pointers
for i in range(len(blocos)):
    for j in range(i + 1, len(blocos)):
        (ra, a, na), (rb, b, nb) = blocos[i], blocos[j]
        if a.value < b.value + nb and b.value < a.value + na:
            say(f"  SOBREPOSICAO ARITMETICA: {ra} @0x{a.value:x} x {rb} @0x{b.value:x}")

# each block gets a unique byte
for k, (rot, p, t) in enumerate(blocos):
    ck(hip.hipMemset(p, ctypes.c_int(k + 1), ctypes.c_size_t(t)), "hipMemset")
ck(hip.hipDeviceSynchronize(), "hipDeviceSynchronize")

# and read it back
ruins = 0
for k, (rot, p, t) in enumerate(blocos):
    buf = (ctypes.c_ubyte * t)()
    ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(t), D2H), "hipMemcpy D2H")
    esperado = k + 1
    # a memoryview of a ctypes array has format "<B" and does not index directly
    # here; frombuffer sees the same bytes without copying and still counts vectorized
    mv = np.frombuffer(buf, dtype=np.uint8)
    if mv[0] != esperado or mv[t - 1] != esperado:
        d = mv != esperado
        ruim = int(d.sum())
        i0 = int(np.argmax(d))
        outro = int(mv[i0]) - 1
        quem = blocos[outro][0] if 0 <= outro < len(blocos) else f"byte {int(mv[i0])}"
        ruins += 1
        say(f"  PISADO: {rot} @0x{p.value:x} tem {ruim} bytes de \"{quem}\" "
            f"a partir de {i0} (0x{p.value + i0:x})")

say(f"  resumo: {ruins} de {len(blocos)} blocos de hipMalloc cru pisados")

# ---- phase 2: is the PTE wrong in memory, or is only the translation cache stale?
#
# If the written PTE is correct and the problem is the GPU translating through a
# stale cached entry, then forcing an invalidation and REWRITING should get the
# block right. If the PTE itself is wrong, rewriting keeps failing.
#
# A hipMalloc/hipFree pair goes through KFD map/unmap, which calls kfd_flush_tlb.
# That is the process invalidation path available from outside the kernel.
if ruins:
    say("  ---- fase 2: forca invalidacao e reescreve ----")
    lixo = []
    for _ in range(6):
        q = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(q), ctypes.c_size_t(4 << 20)), "hipMalloc(flush)")
        lixo.append(q)
    for q in lixo:
        ck(hip.hipFree(q), "hipFree(flush)")
    ck(hip.hipDeviceSynchronize(), "sync pos-flush")

    recuperados = 0
    ainda = 0
    for k, (rot, pp, t) in enumerate(blocos):
        novo = ((k + 1) * 7) % 251 + 1        # a different value from phase 1
        ck(hip.hipMemset(pp, ctypes.c_int(novo), ctypes.c_size_t(t)), "hipMemset(2)")
    ck(hip.hipDeviceSynchronize(), "sync")
    for k, (rot, pp, t) in enumerate(blocos):
        novo = ((k + 1) * 7) % 251 + 1
        buf2 = (ctypes.c_ubyte * t)()
        ck(hip.hipMemcpy(buf2, pp, ctypes.c_size_t(t), D2H), "hipMemcpy(2)")
        a2 = np.frombuffer(buf2, dtype=np.uint8)
        d2 = a2 != novo
        if int(d2.sum()):
            ainda += 1
            i0 = int(np.argmax(d2))
            say(f"    AINDA ERRADO: {rot} {int(d2.sum())} bytes, valor {int(a2[i0])} "
                f"(esperado {novo}) a partir de {i0}")
        else:
            recuperados += 1
    say(f"    apos invalidacao forcada: {ainda} blocos ainda errados, "
        f"{recuperados} corretos")
    if ainda == 0:
        say("    => a PTE na memoria estava CERTA: o defeito e de INVALIDACAO")
    else:
        say("    => reescrever nao resolveu: a PTE gravada esta ERRADA")

# Third argument "segurar": keeps the blocks ALIVE and waits, so that
# /sys/kernel/debug/dri/*/amdgpu_vm_info can be read with the mapping still
# up. Without it debugfs comes out empty: it only shows VMs of live processes.
# This stops inferring the mapping from content and starts reading the table.
if ruins and len(sys.argv) > 3 and sys.argv[3] == "cpu":
    # Under KFD the address is unified: the hipMalloc pointer is also mapped for
    # the CPU. That separates the layers once and for all.
    #
    #   CPU also sees the aliasing  -> both VAs point at the same physical
    #                                 memory in the host mapping: the defect
    #                                 is in the mmap/BO allocation
    #   only the GPU sees it        -> the host mapping is right and the GPU
    #                                 page tables (GPUVM) are the ones that
    #                                 are wrong
    say("  ===== quem ve o aliasing: CPU ou so a GPU? =====")
    for ln in open(f"/proc/{os.getpid()}/maps"):
        try:
            ini = int(ln.split("-")[0], 16)
        except ValueError:
            continue
        for rot, pp, t in blocos:
            if ini == pp.value:
                say(f"    {rot} @0x{pp.value:x} -> {ln.rstrip()}")

    # writes from the CPU into each block and reads back from the CPU
    for k, (rot, pp, t) in enumerate(blocos):
        ctypes.memset(pp, 200 + k, t)
    for k, (rot, pp, t) in enumerate(blocos):
        arr = np.frombuffer((ctypes.c_ubyte * t).from_address(pp.value), dtype=np.uint8)
        esperado = (200 + k) & 0xFF
        d = arr != esperado
        if int(d.sum()):
            i0 = int(np.argmax(d))
            outro = int(arr[i0]) - 200
            quem = blocos[outro][0] if 0 <= outro < len(blocos) else f"byte {int(arr[i0])}"
            say(f"    CPU TAMBEM VE: {rot} @0x{pp.value:x} tem {int(d.sum())} bytes "
                f"de \"{quem}\" a partir de {i0}")
    say("    (se nao apareceu nenhuma linha 'CPU TAMBEM VE', so a GPU aliasa)")

if ruins and len(sys.argv) > 3 and sys.argv[3] == "segurar":
    # the process itself dumps debugfs while holding the blocks: coordinating
    # that through the shell requires waiting on a flag file, and the wait is fragile
    import subprocess
    say(f"  lendo amdgpu_vm_info com os blocos ainda mapeados (pid {os.getpid()})")
    for d in ("1", "128"):
        for arq in ("amdgpu_vm_info", "amdgpu_gem_info"):
            r = subprocess.run(["sudo", "-S", "cat", f"/sys/kernel/debug/dri/{d}/{arq}"],
                               input="grdg\n", capture_output=True, text=True)
            saida = r.stdout.strip()
            if not saida:
                continue
            say(f"  ===== dri/{d}/{arq} ({len(saida.splitlines())} linhas) =====")
            for ln in saida.splitlines():
                say("    " + ln)

for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
