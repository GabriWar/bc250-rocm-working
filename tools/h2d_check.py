#!/usr/bin/env python3
"""O tensor que subiu para a GPU e o mesmo que eu mandei?

Achado em 2026-08-05: no modo "computa tudo depois copia", conv e im2col
devolvem o MESMO erro relativo, ate a terceira casa. Dois algoritmos
diferentes so coincidem assim se lerem a mesma entrada errada -- o que aponta
para o upload host->device, nao para o calculo.

Este env tem HSA_ENABLE_SDMA=0, entao copia H2D nao usa engine de DMA: e um
kernel de blit na fila de compute.

Aqui: sobe, traz de volta, compara byte a byte. Sem kernel de conv no meio.
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/h2d_check.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

alvos=[(112,320),(128,320),(104,320),(96,320),(64,320),(64,64)]
sweep=[(h,c) for h in range(32,136,8) for c in (64,320)]
say("aquecendo...")
for _ in range(2):
    for h,c in sweep:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize(); say("")

for ciclo in (1,2,3):
    say(f"--- ciclo {ciclo} ---")

    # modo A: todos os uploads em rajada, sem sync entre eles
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

    # modo B: um upload por vez, com sync
    say("  B: um upload por vez, sync a cada um")
    for h,c in alvos:
        x=torch.randn(1,c,h,h,dtype=torch.float16)
        xg=x.to(d); torch.cuda.synchronize()
        dif=int((xg.cpu()!=x).sum())
        say(f"     c={c:3d} h={h:3d}  {'identico' if dif==0 else str(dif)+' DIFERENTES'}")
    say("")
say("FIM")
