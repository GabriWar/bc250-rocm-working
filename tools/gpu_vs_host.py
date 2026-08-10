#!/usr/bin/env python3
"""Is the error in the COMPUTE or in the COPY back to the host?

So far: c=320 h=112 gets 43% of the elements wrong, spread across all 320
channels, in contiguous ranges within each channel. Pure memory passes 768 MB
without a single corrupted word. Kernel and ISA are correct.

Contiguous, block-aligned ranges smell like a write that never became visible,
not like wrong arithmetic. And this env disables SDMA (HSA_ENABLE_SDMA=0), so
the device->host copy takes an alternative path.

Here the same output is compared two ways:
  A) entirely ON THE GPU, against an im2col+GEMM reference (which measures 0/26)
  B) copied to the host and compared with the CPU

A small and B large -> the compute is right and the copy corrupts
A and B both large   -> the compute really is wrong
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/gpu_vs_host.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

def ref_na_gpu(xg, wg):
    """conv via im2col+GEMM, the path that measures 0/26. Everything stays on the GPU."""
    n,cin,hi,wi = xg.shape; cout = wg.shape[0]
    cols = F.unfold(xg, (3,3), padding=1)
    o = (wg.reshape(cout,-1).float() @ cols.float())
    return o.reshape(n,cout,hi,wi)

shapes=[(h,c) for h in range(32,136,8) for c in (64,320)]
say("aquecendo...")
for rep in range(2):
    for h,c in shapes:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize()
say("")
say("  shape          A: erro na GPU     B: erro pos-copia   veredito")

for h,c in [(112,320),(104,320),(64,64),(128,320)]:
    x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
    xg,wg=x.to(d),w.to(d)
    g=F.conv2d(xg,wg,padding=1); torch.cuda.synchronize()

    # A: everything on the GPU
    rg=ref_na_gpu(xg,wg)
    ea=((g.float()-rg).abs().max()/rg.abs().max().clamp(min=1e-6)).item()

    # B: copy to the host and compare with the CPU
    gc=g.float().cpu()
    rc=F.conv2d(x.float(),w.float(),padding=1)
    eb=(gc-rc).abs().max().item()/max(rc.abs().max().item(),1e-6)

    # C: second copy of the SAME buffer -- do the two copies agree with each other?
    gc2=g.float().cpu()
    ec=(gc-gc2).abs().max().item()

    v = "COPIA" if (ea<1e-2 and eb>1e-2) else ("CALCULO" if eb>1e-2 else "ok")
    say(f"  c={c:3d} h={h:3d}   {ea:.3e}         {eb:.3e}         {v}")
    if ec>0:
        say(f"                duas copias do MESMO buffer diferem entre si: {ec:.3e}")
say("")
say("A pequeno + B grande = calculo certo, copia corrompe")
say("FIM")
