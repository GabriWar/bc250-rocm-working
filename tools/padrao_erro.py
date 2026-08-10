#!/usr/bin/env python3
"""INSIDE a channel, which pixels fail?

Established: c=320 h=112 gets 43.3% of the elements wrong, spread across ALL 320
channels, with no channel entirely wrong. So every workgroup did execute.

The naive conv loop is:
    for(tid = threadIdx.x; tid < ho*wo; tid += blockDim.x)
with ho*wo = 12544. If blockDim=256, that is 49 iterations per thread.

  wrong contiguous at the end -> the loop ended early
  wrong every 256             -> a specific loop iteration
  wrong by lane range         -> a specific thread/wave
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/padrao_erro.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

shapes=[(h,c) for h in range(32,136,8) for c in (64,320)]
for rep in range(2):
    for h,c in shapes:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize()

h,c=112,320
x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
g=F.conv2d(x.to(d),w.to(d),padding=1); torch.cuda.synchronize()
gc=g.float().cpu(); r=F.conv2d(x.float(),w.float(),padding=1)
scale=max(r.abs().max().item(),1e-6)
bad=((gc-r).abs()/scale > 1e-2).reshape(c,-1)
pix=bad.shape[1]
say(f"c={c} h={h}  pixels por canal = {pix} = {h}x{h}")
say(f"errados totais: {int(bad.sum())} ({100*bad.float().mean():.1f}%)")
say("")

b0=bad[0]
idx=torch.nonzero(b0).flatten()
say(f"canal 0: {len(idx)}/{pix} errados")
if len(idx):
    say(f"  primeiro pixel errado: {int(idx[0])}   ultimo: {int(idx[-1])}")
    say(f"  contiguo do primeiro ao ultimo? "
        f"{'sim' if len(idx)==int(idx[-1])-int(idx[0])+1 else 'nao'}")
    for BD in (64,128,256,512):
        m=torch.zeros(BD,dtype=torch.long)
        for j in idx.tolist(): m[j%BD]+=1
        ativos=int((m>0).sum())
        say(f"  agrupando por tid%{BD:3d}: {ativos}/{BD} posicoes atingidas"
            f"{'   <<< SO ALGUMAS' if ativos<BD else ''}")
    it=256
    porit=[int(b0[k*it:(k+1)*it].sum()) for k in range(pix//it+1)]
    say(f"  errados por bloco de {it} pixels (iteracao do laco):")
    say("    " + " ".join(f"{v:3d}" for v in porit))
say("")
say("mesma analise no canal 1 e no 160, para ver se o padrao se repete:")
for ch in (1,160):
    bb=bad[ch]; ii=torch.nonzero(bb).flatten()
    if len(ii)==0: say(f"  canal {ch}: 0 errados"); continue
    porit=[int(bb[k*256:(k+1)*256].sum()) for k in range(pix//256+1)]
    say(f"  canal {ch:3d}: {len(ii)} errados, primeiro {int(ii[0])}, "
        f"por bloco: {' '.join(str(v) for v in porit)}")
say("FIM")
