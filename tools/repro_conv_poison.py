#!/usr/bin/env python3
"""
Minimal reproducer for the gfx1013 compute defect — 15 seconds, no crash.

Two conv2d shapes run in sequence (128x128 then 136x136) leave the GPU in a
state where every subsequent conv2d returns numerically wrong results — off by
tens of percent, not rounding.

Nothing crashes. No page fault. No HIP error. The GPU just returns garbage and
reports success. That is what makes this defect so hard to see from the
application side.

    128 -> 136 -> 160    WRONG   (~3e-1 relative error)
    128 -> 136 -> 144    WRONG
    128 -> 136 -> 192    WRONG   (192 alone is fine)

    128 -> 160           ok
    136 -> 160           ok      (neither shape alone poisons anything)
    96  -> 112 -> 160    ok      (not just "three distinct shapes")
    64  -> 96  -> 128    ok
    160 -> 176 -> 192    ok

Controls already run (2026-08-05), all clean:
  - CPU single-thread vs multi-thread reference: 0.000e+00 (reference is sound)
  - GPU fp32 vs CPU fp32: 8.2e-07 (fp32 path agrees)
  - no fp16 overflow (max magnitude 279 of 65504)
  - same shape repeated 200x: 0/200 wrong (it is not accumulation or heat)

Context: Mesa disabled the compute queue on this chip in commit 7271b8ee
("BC250 is known to have non-functional compute queue"), and ROCm/ROCm#6313
reports the same class of failure. This script gives that defect a cheap,
deterministic, numerical signal instead of an intermittent hang.

Usage:  python3 repro_conv_poison.py [seq]
        python3 repro_conv_poison.py 128,136,160
"""
import sys
import torch
import torch.nn.functional as F

DEV = "cuda"
TOL = 1e-2          # real errors are ~3e-1; correct results are ~4e-4
CHANNELS = 320      # SD 1.5 UNet width


def conv_error(h):
    """Run one conv2d on GPU and on CPU, return max relative difference."""
    x = torch.randn(1, CHANNELS, h, h, dtype=torch.float16)
    w = torch.randn(CHANNELS, CHANNELS, 3, 3, dtype=torch.float16)
    gpu = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()
    cpu = F.conv2d(x.float(), w.float(), padding=1)
    return (gpu.float().cpu() - cpu).abs().max().item() / max(
        cpu.abs().max().item(), 1e-6)


def main():
    if not torch.cuda.is_available():
        sys.exit("no GPU visible to torch")

    seq = [int(v) for v in (sys.argv[1] if len(sys.argv) > 1
                            else "128,136,160").split(",")]
    torch.manual_seed(0)

    print(f"device: {torch.cuda.get_device_name(0)}")
    print(f"sequence: {' -> '.join(str(s) for s in seq)}\n")

    bad = 0
    for i, h in enumerate(seq):
        err = conv_error(h)
        wrong = err > TOL
        bad += wrong
        print(f"  [{i}] conv2d {CHANNELS}->{CHANNELS} @{h}x{h}"
              f"   rel_err={err:.3e}   {'WRONG' if wrong else 'ok'}")

    print()
    if bad:
        print(f"REPRODUCED — {bad} of {len(seq)} dispatches returned wrong data "
              f"while reporting success")
        return 1
    print("not reproduced with this sequence")
    return 0


if __name__ == "__main__":
    sys.exit(main())
