#!/usr/bin/env python3
"""Is the tensor that went up to the GPU the same one I sent?

Found on 2026-08-05: in "compute everything then copy" mode, conv and im2col
return the SAME relative error, down to the third decimal. Two different
algorithms only coincide like that if they read the same wrong input -- which
points at the host->device upload, not at the compute.

This env has HSA_ENABLE_SDMA=0, so an H2D copy does not use a DMA engine: it is
a blit kernel on the compute queue.

Here: upload, bring it back, compare byte by byte. No conv kernel in between.
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
import subprocess,time,sys
out=open(os.path.expanduser("~/bc250-grimoire/h2d_check.historico"),"a",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

alvos=[(112,320),(128,320),(104,320),(96,320),(64,320),(64,64)]
sweep=[(h,c) for h in range(32,136,8) for c in (64,320)]
_sh=lambda c:(subprocess.run(c,shell=True,capture_output=True,text=True,timeout=10).stdout.strip() or "?")
_rot=sys.argv[1] if len(sys.argv)>1 else "?"
say("")
say("="*70)
say(f"rotulo={_rot}  boot={_sh('cat /proc/sys/kernel/random/boot_id')[:8]}  "
    f"{_sh('uptime -p')}  faults={_sh(chr(34)+'printf grdg | sudo -S dmesg 2>/dev/null | grep -ci \'page fault\''+chr(34))}  "
    f"{time.strftime('%H:%M:%S')}")
say("="*70)
say("aquecendo...")
for _ in range(2):
    for h,c in sweep:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize(); say("")

for ciclo in (1,2,3):
    say(f"--- ciclo {ciclo} ---")

    # mode A: all uploads in a burst, no sync between them
    say("  A: uploads em rajada, sync so no fim")
    cpu=[]; gpu=[]
    for h,c in alvos:
        x=torch.randn(1,c,h,h,dtype=torch.float16)
        cpu.append((h,c,x)); gpu.append(x.to(d))
    torch.cuda.synchronize()
    for (h,c,x),xg in zip(cpu,gpu):
        volta=xg.cpu()
        dif=int((volta!=x).sum())
        if dif:
            idx=torch.nonzero((volta!=x).flatten()).flatten()
            say(f"     c={c:3d} h={h:3d}  {dif}/{x.numel()} elementos DIFERENTES"
                f"  primeiro no indice {int(idx[0])}")
        else:
            say(f"     c={c:3d} h={h:3d}  identico")

    # mode B: one upload at a time, with sync
    say("  B: um upload por vez, sync a cada um")
    for h,c in alvos:
        x=torch.randn(1,c,h,h,dtype=torch.float16)
        xg=x.to(d); torch.cuda.synchronize()
        dif=int((xg.cpu()!=x).sum())
        say(f"     c={c:3d} h={h:3d}  {'identico' if dif==0 else str(dif)+' DIFERENTES'}")
    say("")
say("FIM")
