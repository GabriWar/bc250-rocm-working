#!/usr/bin/env python3
"""Candidatos a correcao da corrupcao de upload H2D em rajada.

Estabelecido 2026-08-05: subindo varios tensores grandes sem sincronizar entre
eles, exatamente um bloco de 2 MiB (2^20 elementos fp16) de um deles nao chega.
Sem conv, sem MIOpen, sem kernel: e a copia host->device.

Candidatos:
  base            como esta hoje (HSA_ENABLE_SDMA=0)
  pinned          memoria pinada no host, que evita o buffer de staging
  nonblock        .to(device, non_blocking=True) com memoria pinada
Repetido varias vezes porque a falha e intermitente.

HSA_ENABLE_SDMA=1 nao da para testar aqui: e lido na inicializacao do runtime,
entao precisa de processo novo com a variavel ja setada.
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

# AQUECIMENTO OBRIGATORIO. A primeira versao deste script pulava isso e deu 0
# corrompidos em 48 uploads no modo base -- o que teria me feito concluir que
# `pinned` corrige algo que nem estava quebrado. O h2d_check.py, que reproduz,
# roda 2 passadas do sweep de conv2d antes. A corrupcao de upload precisa de
# trabalho de GPU acumulado antes; sem ele, todos os modos passam.
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
