#!/usr/bin/env python3
"""Intercalar computacao com copia device->host corrompe?

Achado em 2026-08-05: duas baterias identicas em shapes e aquecimento deram
11 erros de 18 e depois 0 de 18. A unica diferenca era que na primeira o
im2col rodava ENTRE copias D2H, e na segunda toda computacao vinha antes de
qualquer copia.

Importa porque este env tem HSA_ENABLE_SDMA=0. Sem SDMA a copia D2H nao usa
engine de DMA: vira um kernel de blit despachado na fila de compute. Entao
intercalar copia com computacao e intercalar dois kernels na mesma fila.

A: computa tudo, depois copia tudo      (sem intercalar)
B: computa, copia, computa, copia...    (intercalado)

Mesmas operacoes e mesma quantidade nos dois. So muda a intercalacao.
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/interleave_ab.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

def rel(a,b): return (a-b).abs().max().item()/max(b.abs().max().item(),1e-6)
def im2col(xg,wg):
    n,cin,hi,wi=xg.shape; cout=wg.shape[0]
    return (wg.reshape(cout,-1)@F.unfold(xg,(3,3),padding=1)).reshape(n,cout,hi,wi)

alvos=[(112,320),(128,320),(104,320),(96,320),(64,320),(64,64)]
sweep=[(h,c) for h in range(32,136,8) for c in (64,320)]
say("aquecendo...")
for _ in range(2):
    for h,c in sweep:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize(); say("")

def prep():
    dados=[]
    for h,c in alvos:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        dados.append((h,c,x,w,x.to(d),w.to(d),F.conv2d(x.float(),w.float(),padding=1)))
    return dados

for ciclo in (1,2,3):
    for modo in ("A","B"):
        dados=prep()
        if modo=="A":
            # computa TUDO primeiro
            res=[(im2col(xg,wg), F.conv2d(xg,wg,padding=1)) for _,_,_,_,xg,wg,_ in dados]
            torch.cuda.synchronize()
            saida=[(i.cpu().float(), g.cpu().float()) for i,g in res]
        else:
            # intercala: computa um, copia, computa outro, copia...
            saida=[]
            for _,_,_,_,xg,wg,_ in dados:
                i=im2col(xg,wg); torch.cuda.synchronize(); ic=i.cpu().float()
                g=F.conv2d(xg,wg,padding=1); torch.cuda.synchronize(); gc=g.cpu().float()
                saida.append((ic,gc))
        ruins=[]
        for (h,c,_,_,_,_,ref),(ic,gc) in zip(dados,saida):
            ei,eg=rel(ic,ref),rel(gc,ref)
            if ei>1e-2 or ei!=ei: ruins.append(f"im2col c={c} h={h} ({ei:.2e})")
            if eg>1e-2 or eg!=eg: ruins.append(f"conv   c={c} h={h} ({eg:.2e})")
        rot="tudo computa, depois copia" if modo=="A" else "INTERCALADO compute/copia"
        say(f"  ciclo {ciclo}  {modo}  {rot:28s}  erros={len(ruins)}")
        for r in ruins: say(f"        {r}")
say("")
say("se B erra e A nao, o gatilho e intercalar copia D2H com computacao")
say("FIM")
