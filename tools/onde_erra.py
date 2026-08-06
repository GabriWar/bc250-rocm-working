# Os elementos errados sao CONTIGUOS (memoria ruim) ou ESPALHADOS (calculo)?
import torch, torch.nn.functional as F, os
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/onde_erra.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

shapes=[(h,c) for h in range(32,136,8) for c in (64,320)]
# aquece ate o conjunto estabilizar (reps 1-3), como medido
for rep in range(3):
    for h,c in shapes:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize()
say("aquecido (3 passadas). agora dissecando os que erram.")
say("")

for h,c in [(64,320),(96,320),(128,320),(64,64)]:
    x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
    g=F.conv2d(x.to(d),w.to(d),padding=1); torch.cuda.synchronize()
    g=g.float().cpu(); r=F.conv2d(x.float(),w.float(),padding=1)
    scale=max(r.abs().max().item(),1e-6)
    err=(g-r).abs()/scale
    bad=(err>1e-2)
    nb=int(bad.sum())
    if nb==0:
        say(f"c={c:3d} h={h:3d}: 0 errados de {bad.numel()}  -> ok"); continue
    flat=bad.flatten(); idx=torch.nonzero(flat).flatten()
    # quantos blocos contiguos formam os elementos errados?
    saltos=int((idx[1:]-idx[:-1] != 1).sum())+1 if len(idx)>1 else 1
    # erram canais inteiros de saida?
    porcanal=bad.reshape(c,-1).sum(1)
    canais_afetados=int((porcanal>0).sum())
    canais_totais=int((porcanal==bad.reshape(c,-1).shape[1]).sum())
    say(f"c={c:3d} h={h:3d}: {nb}/{bad.numel()} errados ({100*nb/bad.numel():.1f}%)")
    say(f"          primeiro indice {int(idx[0])}, ultimo {int(idx[-1])}")
    say(f"          blocos contiguos: {saltos}")
    say(f"          canais de saida afetados: {canais_afetados}/{c}  "
        f"(inteiramente errados: {canais_totais})")
    say(f"          valor obtido nos errados: min={g.flatten()[idx].min():.3f} "
        f"max={g.flatten()[idx].max():.3f} | esperado min={r.min():.3f} max={r.max():.3f}")
    zeros=int((g.flatten()[idx]==0).sum())
    say(f"          quantos sao exatamente zero: {zeros}/{nb}")
    say("")
