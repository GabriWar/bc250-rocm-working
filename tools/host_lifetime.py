#!/usr/bin/env python3
"""Does the corruption depend on the lifetime of the SOURCE buffer on the host?

How the question came up
------------------------
Running plant_pattern.py twice, same boot, same load:

  version that FREES the source tensors each cycle   5 of 5 cycles corrupted
  version that HOLDS them all alive (`fontes` list)  0 of 5

The only difference between the two was accumulating the tensors in a list for a
later search -- that is, no longer returning host memory to the allocator.

Why that would be causal
------------------------
In clr/rocclr/device/rocm/rocblit.cpp the H2D path has two variants. In the
staged one, data is copied into an intermediate buffer before the DMA. In the
pinned one, there is no copy: the DMA reads `hostSrc` directly. In both cases the
function returns without waiting for completion -- unlike D2H, which calls
`gpu().Barriers().WaitCurrent()`.

If the host frees and reuses those pages before the DMA finishes, the GPU reads
the new content. That would explain what no previous hypothesis explained:

  - wrong values with a distribution IDENTICAL to the correct one (std 1.0,
    range +-3.9), because they are randn from another tensor, not garbage
  - a destination pre-marked with NaN comes back with NO NaN at all: someone
    wrote there, the copy did happen
  - the wrong stretch does not match any offset of the tensor itself

Design
------
One process per arm, six processes, same boot. Counterbalanced order
`H F F H H F` so that no arm gets only the early positions -- on this board a
process's first GPU load behaves differently from the following ones, so
alternating (`H F H F`) would give every odd position to a single arm.

  HOLD  keeps every source alive until the process ends
  FREE  rebinds each cycle, returning the memory to the allocator

Everything else is identical, including the seed. Usage: host_lifetime.py HOLD|FREE
"""
import os
import sys

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/host_lifetime.historico")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


ALVOS = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]
CICLOS = 5


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


braco = sys.argv[1]
assert braco in ("HOLD", "FREE")
boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]

aquecer()
torch.manual_seed(0)

segurados = []       # only fed in the HOLD arm
ruins = 0
detalhe = []
for ciclo in range(1, CICLOS + 1):
    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        if braco == "HOLD":
            segurados.append(x)
        gpu.append(x.to(DEV))                 # burst, no sync between uploads
    torch.cuda.synchronize()

    for (h, c, x), xg in zip(cpu, gpu):
        nd = int((xg.cpu() != x).sum())
        # the address goes along: the data says the outcome is decided at the start
        # of the process and does not change, so the suspicion now is the RANGE the
        # allocator handed out, not the moment of the copy
        detalhe.append(f"c{ciclo}:{c}x{h}@0x{xg.data_ptr():x}={nd}")
        if nd:
            ruins += 1
    # in the FREE arm, `cpu` and `gpu` are rebound on the next lap and the host
    # memory goes back to the allocator; in HOLD, `segurados` keeps everything alive

say(f"braco={braco} boot={boot} pid={os.getpid()} ruins={ruins}/{CICLOS*len(ALVOS)} "
    f"segurados={len(segurados)} | {' '.join(detalhe) if detalhe else 'limpo'}")
