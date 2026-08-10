#!/usr/bin/env python3
"""Which operation returned the wrong number: the conv, the cast, or im2col+GEMM?

Context (2026-08-05)
--------------------
Comparing `F.conv2d`'s output two ways, for c=320 h=128 after warmup, gave this:

    compared ON THE GPU against im2col+GEMM   error 1.293e+00   wrong
    copied and compared against the CPU       error 3.770e-04   right

Since the second one is right, the conv's output is right and what lied was the
GPU side of the comparison. But that path bundles TWO operations the host
comparison does not use:

    1. F.unfold + matmul in fp32 on the GPU   (the reference)
    2. g.float()  -- the fp16->fp32 cast ON THE GPU

This matters because (1) is exactly the path of bc250_conv_fix.py, which the repo
presents as a fix. If it is wrong, it is not a fix, just another failure mode.

What this script measures
-------------------------
Four numbers per shape, arranged so each one indicts one operation:

    conv      = |g.cpu().float()  - cpu_ref|   raw fp16 copy, cast on the CPU
                -> MIOpen's conv alone, with no GPU cast in between

    cast      = |g.float().cpu()  - g.cpu().float()|
                -> both paths start from the SAME buffer; if they differ, the
                   fp16->fp32 cast on the GPU is wrong. Any value above zero is
                   already a defect, not rounding.

    im2col    = |unfold_matmul(gpu).cpu() - cpu_ref|
                -> the bc250_conv_fix path, brought to the host BEFORE
                   comparing, so it does not inherit the cast's error

    conv~im2col = |g.cpu().float() - unfold_matmul(gpu).cpu()|
                -> the two GPU paths against each other

Reading:
    only `conv` large       -> MIOpen got it wrong
    only `im2col` large     -> the patch got it wrong; it is not a fix
    only `cast` large       -> the fp16->fp32 cast on the GPU got it wrong
    conv and im2col large   -> not a specific path, it is further down

Usage
-----
    qual_mentiu.py limpo          # NO warmup: first load of the boot
    qual_mentiu.py sujo           # with warmup, 3 repetitions
    qual_mentiu.py sujo 5         # with warmup, 5 repetitions

Agreed protocol: after each reboot, one `limpo` run and then a few `sujo` ones,
repeating over 3 boots, to separate what comes from accumulated state from what
comes from the operation.

Each run APPENDS to the history in ~/bc250-grimoire/qual_mentiu.historico,
tagged with the boot_id, the uptime and the page fault count at the start. That
way the cross-boot pattern lives in a single file.
"""
import os
import subprocess
import sys
import time

import torch
import torch.nn.functional as F

DEV = "cuda"
TOL = 1e-2
HIST = os.path.expanduser("~/bc250-grimoire/qual_mentiu.historico")
_f = open(HIST, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def sh(cmd):
    try:
        return subprocess.run(cmd, shell=True, capture_output=True,
                              text=True, timeout=10).stdout.strip()
    except Exception:
        return "?"


def rel(a, b):
    """Error relative to the reference's maximum, the same criterion as the rest of the repo."""
    return (a - b).abs().max().item() / max(b.abs().max().item(), 1e-6)


def im2col_fp32(xg, wg):
    """im2col + GEMM promoting to fp32. NOT what the patch does -- a GEMM in
    fp32 uses different rocBLAS kernels than the fp16 ones."""
    n, cin, hi, wi = xg.shape
    cout = wg.shape[0]
    cols = F.unfold(xg, (3, 3), padding=1)
    o = wg.reshape(cout, -1).float() @ cols.float()
    return o.reshape(n, cout, hi, wi)


def im2col_fp16(xg, wg):
    """Exactly what bc250_conv_fix.py does: everything in fp16, no promotion.

    Copied from the body of _conv2d_im2col for the 3x3 stride 1 padding 1 case,
    which is what these shapes use. If this one fails, the patch is not a fix."""
    n, cin, hi, wi = xg.shape
    cout = wg.shape[0]
    cols = F.unfold(xg, (3, 3), padding=1)
    o = wg.reshape(cout, -1) @ cols
    return o.reshape(n, cout, hi, wi)


modo = sys.argv[1] if len(sys.argv) > 1 else "sujo"
reps = int(sys.argv[2]) if len(sys.argv) > 2 else (1 if modo == "limpo" else 3)

alvos = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]
sweep = [(h, c) for h in range(32, 136, 8) for c in (64, 320)]

boot = sh("cat /proc/sys/kernel/random/boot_id")[:8]
faults = sh("printf 'grdg\\n' | sudo -S dmesg 2>/dev/null | grep -ci 'page fault'")

torch.manual_seed(0)
say("")
say("=" * 78)
say(f"modo={modo}  reps={reps}  boot={boot}  uptime={sh('uptime -p')}  "
    f"faults_no_inicio={faults}  {time.strftime('%Y-%m-%d %H:%M:%S')}")
say("=" * 78)

if modo == "limpo":
    say("sem aquecimento: esta e a primeira carga de GPU deste processo")
else:
    say("aquecendo 2 passadas do sweep de 26 shapes (e quando o conjunto de")
    say("falhas estabiliza)")
    for _ in range(2):
        for h, c in sweep:
            x = torch.randn(1, c, h, h, dtype=torch.float16)
            w = torch.randn(c, c, 3, 3, dtype=torch.float16)
            _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()
say("")

cab = (f"  {'shape':>12}  {'conv':>10}  {'cast':>10}  {'im2col16':>10}  "
       f"{'im2col32':>10}  {'1o':>4}  veredito")
resumo = {"CONV": 0, "CAST": 0, "IM2COL16": 0, "IM2COL32": 0, "ok": 0}

for rep in range(1, reps + 1):
    say(f"--- {modo} rep {rep}/{reps} ---")
    say(cab)
    for h, c in alvos:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        w = torch.randn(c, c, 3, 3, dtype=torch.float16)
        xg, wg = x.to(DEV), w.to(DEV)

        # ALTERNATING ORDER. Always running conv first and im2col second would make the
        # second inherit any positional poisoning, and I would be measuring order
        # while believing I was measuring operation. The `1o` column says which one
        # was launched first in this measurement.
        conv_primeiro = (rep + alvos.index((h, c))) % 2 == 0

        if conv_primeiro:
            g = F.conv2d(xg, wg, padding=1); torch.cuda.synchronize()
            r16 = im2col_fp16(xg, wg); r32 = im2col_fp32(xg, wg)
        else:
            r16 = im2col_fp16(xg, wg); r32 = im2col_fp32(xg, wg)
            torch.cuda.synchronize()
            g = F.conv2d(xg, wg, padding=1)
        torch.cuda.synchronize()

        cpu_ref = F.conv2d(x.float(), w.float(), padding=1)

        g_puro = g.cpu().float()      # copy the fp16, cast on the CPU
        g_cast = g.float().cpu()      # cast on the GPU, then copy
        i16 = r16.cpu().float()       # the patch, exactly
        i32 = r32.cpu()               # promoted variant

        e_conv = rel(g_puro, cpu_ref)
        e_cast = (g_cast - g_puro).abs().max().item()
        e_i16 = rel(i16, cpu_ref)
        e_i32 = rel(i32, cpu_ref)

        # nan is never "ok": any comparison with nan is false, so a `> TOL`
        # swallows the worst possible failure. It happened in the first batch.
        def falhou(e):
            return (not (e == e)) or e > TOL

        ruins = []
        if falhou(e_conv):
            ruins.append("CONV")
        if falhou(e_cast) or e_cast > 0:
            ruins.append("CAST")
        if falhou(e_i16):
            ruins.append("IM2COL16")
        if falhou(e_i32):
            ruins.append("IM2COL32")
        for r in ruins:
            resumo[r] += 1
        if not ruins:
            resumo["ok"] += 1
        say(f"  c={c:3d} h={h:3d}  {e_conv:10.3e}  {e_cast:10.3e}  "
            f"{e_i16:10.3e}  {e_i32:10.3e}  {"conv" if conv_primeiro else "im2c":>4}  {"+".join(ruins) if ruins else "ok"}")
    say("")

n = reps * len(alvos)
say(f"RESUMO {modo} boot={boot}: de {n} medidas -> "
    f"CONV {resumo['CONV']}  CAST {resumo['CAST']}  IM2COL16 {resumo['IM2COL16']}  IM2COL32 {resumo['IM2COL32']}  "
    f"limpas {resumo['ok']}")
say("FIM")
