# Depois da 1a passada, exatamente 5 shapes erram em toda repeticao.
# Quais sao, e o conjunto e o mesmo entre repeticoes?
import torch, torch.nn.functional as F, os
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/quais5.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

shapes=[(h,c) for h in range(32,136,8) for c in (64,320)]
conj=[]
for rep in range(1,7):
    ruins=[]
    for i,(h,c) in enumerate(shapes,1):
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        g=F.conv2d(x.to(d),w.to(d),padding=1); torch.cuda.synchronize()
        r=F.conv2d(x.float(),w.float(),padding=1)
        e=(g.float().cpu()-r).abs().max().item()/max(r.abs().max().item(),1e-6)
        if e>1e-2: ruins.append((i,c,h,e))
    conj.append(set((c,h) for _,c,h,_ in ruins))
    say(f"rep {rep}: {len(ruins)} erradas")
    for i,c,h,e in ruins:
        say(f"   op{i:3d}  c={c:3d} h={h:3d}  out={h*h:6d}  ho*wo*k={h*h*c:9d}  err={e:.3e}")

say("")
base=conj[1] if len(conj)>1 else conj[0]
say(f"conjunto da rep2: {sorted(base)}")
for j,s in enumerate(conj[1:],2):
    say(f"  rep{j} identico a rep2: {s==base}")
