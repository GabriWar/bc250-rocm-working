#!/usr/bin/env python3
"""Progressive corruption within a single process on gfx1013.

Successive conv2d calls in one process degrade: after a handful of ops the
results stop matching a CPU reference, and it gets worse from there. Nothing
crashes and no error is reported.

Usage: python3 repro_inproc.py
Exit 1 if corruption was observed.
"""
import sys, torch, torch.nn.functional as F
DEV, TOL = "cuda", 1e-2

def conv_err(h, c):
    x = torch.randn(1, c, h, h, dtype=torch.float16)
    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
    g = F.conv2d(x.to(DEV), w.to(DEV), padding=1); torch.cuda.synchronize()
    r = F.conv2d(x.float(), w.float(), padding=1)
    return (g.float().cpu() - r).abs().max().item() / max(r.abs().max().item(), 1e-6)

torch.manual_seed(0)
first, n, bad = None, 0, 0
for h in range(32, 136, 8):
    for c in (64, 320):
        n += 1
        e = conv_err(h, c)
        if e > TOL:
            bad += 1
            if first is None: first = n
        print(f"[{n:2d}] c={c:3d} h={h:3d} err={e:.3e}{'  WRONG' if e > TOL else ''}")
print(f"\n{bad}/{n} wrong, first at op {first}")
sys.exit(1 if bad else 0)
