#!/usr/bin/env python3
"""Os erros estao organizados por CANAL DE SAIDA (= workgroup)?

O naive conv do MIOpen lanca um workgroup por canal de saida:
    bid = blockIdx.x;  ik = bid % k_per_group;  ...  p_out += ik * ho * wo;
Entao c=320 sao 320 workgroups e c=64 sao 64. So c=320 falha.

Se workgroups nao executam, canais INTEIROS ficam com o conteudo anterior do
buffer -- que nao e zero, e lixo do tensor que ocupava aquela memoria. Foi por
procurar zeros que eu descartei essa hipotese antes, e o teste estava errado.
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/dropped_wg.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

shapes=[(h,c) for h in range(32,136,8) for c in (64,320)]
say("aquecendo ate o conjunto de falhas estabilizar...")
for rep in range(2):
    for h,c in shapes:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize()
say("")

for h,c in [(112,320),(104,320),(128,320),(64,64)]:
    x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
    g=F.conv2d(x.to(d),w.to(d),padding=1); torch.cuda.synchronize()
    gc=g.float().cpu(); r=F.conv2d(x.float(),w.float(),padding=1)
    scale=max(r.abs().max().item(),1e-6)
    bad=((gc-r).abs()/scale > 1e-2).reshape(c,-1)   # (canais, pixels)
    porcanal=bad.sum(1); pix=bad.shape[1]
    nafet=int((porcanal>0).sum()); ninteiro=int((porcanal==pix).sum())
    tot=int(bad.sum())
    say(f"c={c:3d} h={h:3d}: {tot}/{bad.numel()} elementos errados "
        f"({100*tot/bad.numel():.1f}%)")
    if tot==0:
        say("           correto"); say(""); continue
    say(f"           canais afetados: {nafet}/{c}")
    say(f"           canais INTEIRAMENTE errados: {ninteiro}/{c}")
    say(f"           canais parcialmente errados: {nafet-ninteiro}")
    ch=torch.nonzero(porcanal>0).flatten().tolist()
    say(f"           indices dos canais afetados: {ch[:16]}"
        f"{' ...' if len(ch)>16 else ''}")
    if ch:
        d0=[ch[i+1]-ch[i] for i in range(len(ch)-1)]
        say(f"           espacamento entre eles: {sorted(set(d0))[:8]}")
    say("")
say("leitura: canais INTEIROS errados = workgroup nao executou")
say("         erro espalhado dentro dos canais = calculo errado")
say("FIM")
