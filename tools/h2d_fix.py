#!/usr/bin/env python3
"""Candidate fixes for the H2D burst upload corruption.

Established 2026-08-05: uploading several large tensors without syncing between
them, exactly one 2 MiB block (2^20 fp16 elements) of one of them does not
arrive. No conv, no MIOpen, no kernel: it is the host->device copy.

Candidates:
  base            as it stands today (HSA_ENABLE_SDMA=0)
  pinned          pinned host memory, which avoids the staging buffer
  nonblock        .to(device, non_blocking=True) with pinned memory
Repeated several times because the failure is intermittent.

HSA_ENABLE_SDMA=1 cannot be tested here: it is read at runtime init, so it needs
a new process with the variable already set.
"""
import os, sys, torch
d="cuda"
out=open(os.path.expanduser("~/bc250-grimoire/h2d_fix.result"),"a",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

modo=sys.argv[1] if len(sys.argv)>1 else "base"
sdma=os.environ.get("HSA_ENABLE_SDMA","(nao setada)")
say(f"=== modo={modo}  HSA_ENABLE_SDMA={sdma} ===")
alvos=[(112,320),(128,320),(104,320),(96,320),(64,320),(64,64)]

torch.manual_seed(0)

# MANDATORY WARMUP. The first version of this script skipped it and gave 0
# corrupted out of 48 uploads in base mode -- which would have made me conclude
# that `pinned` fixes something that was not even broken. h2d_check.py, which
# does reproduce, runs 2 passes of the conv2d sweep first. Upload corruption
# needs accumulated GPU work beforehand; without it, every mode passes.
import torch.nn.functional as F
_sweep=[(h,c) for h in range(32,136,8) for c in (64,320)]
say("  aquecendo (2 passadas de 26 conv2d) -- sem isso nada reproduz")
for _ in range(2):
    for h,c in _sweep:
        _x=torch.randn(1,c,h,h,dtype=torch.float16)
        _w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(_x.to(d),_w.to(d),padding=1)
torch.cuda.synchronize()

total_ruins=0
for ciclo in range(1,9):
    cpu=[]; gpu=[]
    for h,c in alvos:
        x=torch.randn(1,c,h,h,dtype=torch.float16)
        if modo in ("pinned","nonblock"):
            x=x.pin_memory()
        cpu.append((h,c,x))
        gpu.append(x.to(d, non_blocking=(modo=="nonblock")))
    torch.cuda.synchronize()
    ruins=[]
    for (h,c,x),xg in zip(cpu,gpu):
        dif=int((xg.cpu()!=x).sum())
        if dif: ruins.append(f"c={c} h={h}: {dif}")
    total_ruins+=len(ruins)
    say(f"  ciclo {ciclo}: {len(ruins)} tensores corrompidos"
        + ("   " + "  ".join(ruins) if ruins else ""))
say(f"  TOTAL {modo}: {total_ruins} corrompidos em 8 ciclos x 6 tensores")
say("")
