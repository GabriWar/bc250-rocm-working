#!/usr/bin/env python3
"""Traces every ROCclr sub-copy and cross-references where the data actually landed.

What is already known (measured, not assumed)
---------------------------------------------
In a burst of uploads without sync, the ENTIRE content of one tensor shows up
inside the destination buffer of ANOTHER tensor of the same burst, at source
offset 0:

    cycle1 c=320 h=64 @0x7fc1cba9a000, wrong from element 733184 on
      -> absolute address 0x7fc1cbC00000 (2 MiB aligned)
      -> content = offset 0 of c=64 h=64, all 262144 elements

It is not stale memory: the destination was pre-marked with NaN and came back
without a single NaN. Someone wrote valid data in the wrong place.

What this script decides
------------------------
ROCclr logs every sub-copy with destination, source and size:

    HSA Copy copy_engine=.., dst=0x.., src=0x.., size=.., wait_event=0x..,
             completion_signal=0x..

  - if there is a line with dst = address of the stray write, the runtime ISSUED
    the copy to the wrong place -> software defect, fixable in clr
  - if every dst is right, the copy was issued correctly and the data came out
    of the wrong place -> either the staging slot (the `src`) was rewritten
    before the DMA read it, or the hardware delivered it wrong

The `src` is the address of the staging slot. If two in-flight copies share the
same `src`, the slot collision shows up directly in the log.

Each cycle emits an upload of unique size as a marker, to slice up the log.
"""
import os
import subprocess
import sys

import torch

DEV = "cuda"
LOG = os.path.expanduser("~/bc250-grimoire/copy_trace.log")
OUT = os.path.expanduser("~/bc250-grimoire/copy_trace.result")
_f = open(OUT, "w", buffering=1)


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


def marcador(n_bytes):
    """Upload of unique size: becomes a recognizable line in the ROCclr log."""
    t = torch.zeros(n_bytes // 2, dtype=torch.float16)
    g = t.to(DEV)
    torch.cuda.synchronize()
    return n_bytes


say(f"log do ROCclr em {LOG}")
say(f"AMD_LOG_LEVEL={os.environ.get('AMD_LOG_LEVEL')} "
    f"AMD_LOG_MASK={os.environ.get('AMD_LOG_MASK')}")
say("")
aquecer()

torch.manual_seed(0)
for ciclo in range(1, 6):
    mk = 1000000 + ciclo * 2000       # unique size per cycle
    marcador(mk)
    say(f"########## ciclo {ciclo}  marcador size={mk} ##########")

    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        gpu.append(x.to(DEV))          # burst, no sync between uploads
    torch.cuda.synchronize()

    for (h, c, x), xg in zip(cpu, gpu):
        say(f"  c={c} h={h} bytes={x.numel()*2} "
            f"cpu=0x{x.data_ptr():x} gpu=0x{xg.data_ptr():x}")

    for (h, c, x), xg in zip(cpu, gpu):
        volta = xg.cpu()
        dif = (volta != x)
        nd = int(dif.sum())
        if not nd:
            continue
        idx = torch.nonzero(dif.flatten()).flatten()
        i0 = int(idx[0])
        abs_a = xg.data_ptr() + i0 * 2
        say(f"  !! CORROMPIDO c={c} h={h}: {nd} errados a partir de {i0}")
        say(f"     extravio em 0x{abs_a:x}  (base 0x{xg.data_ptr():x} + {i0*2} B)")
        # which tensor it came from
        import numpy as np
        w = volta.flatten()[i0:i0 + 64].view(torch.int16).numpy()
        for hh, cc, xx in cpu:
            s = xx.flatten().view(torch.int16).numpy()
            for j in np.flatnonzero(s == w[0]):
                if j + 64 <= len(s) and np.array_equal(s[j:j + 64], w):
                    say(f"     conteudo = offset {int(j)} de c={cc} h={hh} "
                        f"(cpu=0x{xx.data_ptr():x})")
                    break
say("FIM")
