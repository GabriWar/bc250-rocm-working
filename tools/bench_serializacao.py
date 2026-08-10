#!/usr/bin/env python3
"""How much do the five serialization flags left in the environment cost?

Why this exists
---------------
/etc/profile.d/bc250-rocm.sh removed five variables on 2026-08-05 and restored
them "temporarily" for a bisect, the same day. They stayed:

    GPU_MAX_HW_QUEUES=1  HIP_LAUNCH_BLOCKING=1  AMD_SERIALIZE_KERNEL=3
    AMD_SERIALIZE_COPY=3  AMD_DIRECT_DISPATCH=0

They were restored BEFORE the runlist patch existed, i.e. they compensated for a
defect that today has a root-cause fix. The file itself already doubted them:
the dispatch with completion_signal=0x0 showed up WITH all three enabled.

What is measured
----------------
A kernel profile similar to diffusion: many small kernels in sequence, which is
exactly the regime where HIP_LAUNCH_BLOCKING hurts. Deliberately not a real
model -- a model would bring allocation and loading variance that would hide the
effect.

Each run returns time AND a correctness verdict. A flag that speeds things up and
brings the defect back is useless, so time alone decides nothing.

Usage:
    bench_serializacao.py <condition-name>
"""
import json
import os
import sys
import time

import torch

NOME = sys.argv[1] if len(sys.argv) > 1 else "sem-nome"
PASSOS = int(os.environ.get("BENCH_PASSOS", "40"))
DEV = "cuda"


def bloco(x, w1, w2, k):
    """One step with the mix of operations a real UNet performs."""
    x = torch.nn.functional.conv2d(x, k, padding=1)
    x = torch.nn.functional.silu(x)
    b, c, h, wd = x.shape
    t = x.reshape(b, c, h * wd).transpose(1, 2)
    t = torch.softmax(t @ w1, dim=-1) @ w2
    t = t.transpose(1, 2).reshape(b, c, h, wd)
    return x + t


def main():
    torch.manual_seed(1234)
    x0 = torch.randn(1, 64, 64, 64, device=DEV)
    k = torch.randn(64, 64, 3, 3, device=DEV) * 0.02
    w1 = torch.randn(64, 64, device=DEV) * 0.05
    w2 = torch.randn(64, 64, device=DEV) * 0.05

    # warmup outside the measurement: the first run pays for kernel compilation
    x = x0.clone()
    for _ in range(5):
        x = bloco(x, w1, w2, k)
    torch.cuda.synchronize()

    x = x0.clone()
    t0 = time.perf_counter()
    for _ in range(PASSOS):
        x = bloco(x, w1, w2, k)
    torch.cuda.synchronize()
    dt = time.perf_counter() - t0

    # correctness: gross failures only. A different number is not a problem here;
    # NaN, infinity or flat output are.
    f = x.float()
    finito = bool(torch.isfinite(f).all())
    desvio = float(f.std())
    chapado = desvio < 1e-6
    ok = finito and not chapado

    print(json.dumps({
        "condicao": NOME,
        "passos": PASSOS,
        "segundos": round(dt, 4),
        "ms_por_passo": round(dt * 1000 / PASSOS, 3),
        "finito": finito,
        "desvio": round(desvio, 6),
        "ok": ok,
        "flags": {v: os.environ.get(v, "<nao definida>") for v in (
            "HIP_LAUNCH_BLOCKING", "AMD_SERIALIZE_KERNEL", "AMD_SERIALIZE_COPY",
            "AMD_DIRECT_DISPATCH", "GPU_MAX_HW_QUEUES")},
    }))


if __name__ == "__main__":
    main()
