#!/usr/bin/env python3
"""Does the H2D corruption come from ROCclr's staging buffer recycling?

Found by reading the source (clr/rocclr/device/rocm/rocblit.cpp and rocvirtual.cpp):

  hsaCopyStagedOrPinned, D2H path:
      rocrCopyBuffer(...)
      gpu().Barriers().WaitCurrent();          <-- WAITS before touching staging
      memcpy(hostDst + copyOffset, stagingBuffer, copysize);

  hsaCopyStagedOrPinned, H2D path:
      memcpy(stagingBuffer, hostSrc + copyOffset, copysize);
      rocrCopyBuffer(...)                      <-- asynchronous
      // the loop comes back and memcpys into the SAME staging, without waiting

The H2D protection is indirect, in ManagedBuffer::Acquire: a pool of 4 chunks of
1 MiB in round-robin, with a barrier when a chunk fills up and a wait on the next
one's signal. Acquire's fast path waits for nothing -- it just advances an offset.

In other words, everything depends on the barrier ordering against the in-flight
copies and on the signal reflecting real completion. On this board both are
suspect: every boot logs "Fence fallback timer expired on ring sdma0", which only
shows up when the work finished and the interrupt was lost.

If the hypothesis is right, the wrong data is neither garbage nor old convolution
output: it is the NEXT CHUNK of the transfer itself, which overwrote staging
before the GPU read it. Same distribution, coherent magnitude, no zeros -- exactly
what we measured.

This script does two things:

  TEST 1  varies GPU_STAGING_BUFFER_SIZE. If transfers fit in a single chunk,
          there is no recycling and there should be no corruption. Driven from
          outside, via env, see staging_ab.sh.

  TEST 2  when it detects corruption, it looks for the wrong content INSIDE the
          source tensor itself, at other offsets. If the data at K is what
          belongs at K +- N, that is direct proof of staging recycling.
"""
import os
import sys

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/staging_test.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


ALVOS = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


def de_onde_veio(orig, volta, ruins):
    """Does the wrong region contain data from another offset of the SAME tensor?

    Compares the corrupted stretch against the source tensor itself, shifted.
    If it matches at a shift D, staging delivered another chunk's piece.
    """
    o = orig.flatten()
    v = volta.flatten()
    i0 = int(ruins[0])
    n = min(4096, int(ruins[-1]) - i0 + 1)
    if n < 64:
        return None
    trecho = v[i0:i0 + n]
    # sweeps shifts in multiples of 64 KiB up to +-8 MiB
    passo = 32768
    for d in range(-256, 257):
        if d == 0:
            continue
        j = i0 + d * passo
        if j < 0 or j + n > o.numel():
            continue
        if torch.equal(trecho, o[j:j + n]):
            return d * passo
    return None


def rodada(rotulo):
    torch.manual_seed(0)
    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        gpu.append(x.to(DEV))          # burst, no sync between uploads
    torch.cuda.synchronize()

    achou = 0
    for (h, c, x), xg in zip(cpu, gpu):
        volta = xg.cpu()
        dif = (volta != x)
        nd = int(dif.sum())
        if nd == 0:
            continue
        achou += 1
        idx = torch.nonzero(dif.flatten()).flatten()
        desloc = de_onde_veio(x, volta, idx)
        say(f"  [{rotulo}] c={c} h={h}: {nd} elementos errados, "
            f"primeiro em {int(idx[0])}")
        if desloc is not None:
            say(f"      >>> o conteudo errado E o dado do offset {int(idx[0])+desloc} "
                f"do MESMO tensor (deslocamento {desloc:+d} = {desloc*2/1024:+.0f} KiB)")
            say(f"      >>> PROVA de reciclagem de staging")
        else:
            say(f"      nao casou com nenhum offset do proprio tensor "
                f"(±8 MiB, passo 64 KiB) -- o dado vem de outro lugar")
    return achou


rot = sys.argv[1] if len(sys.argv) > 1 else "?"
say("")
say("=" * 74)
say(f"rotulo={rot}  GPU_STAGING_BUFFER_SIZE={os.environ.get('GPU_STAGING_BUFFER_SIZE','(nao setada -> 1 MiB)')}")
say("=" * 74)
say("aquecendo...")
aquecer()
tot = 0
for i in range(1, 4):
    tot += rodada(f"{rot}/ciclo{i}")
say(f"  {rot}: {tot} tensores corrompidos em 3 ciclos x 6 tensores")
