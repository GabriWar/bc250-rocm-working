#!/usr/bin/env python3
"""Mede a TAXA de conv2d errado, nao a contagem. Substitui repro_inproc.py
para validar patches.

Por que existe
-------------
O repro_inproc.py roda 26 shapes e reporta quantos erraram. Em 04-05/ago isso
dava 8-14 de 26 de forma consistente. Em 05/ago a noite passou a dar 0-6 de 26,
com o baseline variando de 0 a 5 entre rodadas identicas.

Com essa variancia um teste de 26 amostras nao consegue distinguir "o patch
corrigiu" de "deu sorte". Varias conclusoes tiradas naquele dia -- inclusive
resultados negativos que eu reportei como se fossem definitivos -- nao tinham
poder estatistico nenhum.

Aqui a saida e uma taxa com intervalo de confianca, sobre algumas centenas de
operacoes. Assim da para dizer se dois estados diferem de verdade.

Uso
---
    repro_rate.py [n_repeticoes]      padrao 8 -> 208 operacoes

Saida: contagem, taxa, IC 95% (Wilson), e a primeira operacao que errou.
Grava em disco com fsync a cada bloco, entao um travamento deixa rastro.
"""
import math
import os
import sys
import time

import torch
import torch.nn.functional as F

DEV = "cuda"
TOL = 1e-2
OUT = os.path.expanduser("~/bc250-grimoire/repro_rate.result")

_f = open(OUT, "w", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def wilson(k, n, z=1.96):
    """IC de Wilson: honesto perto de 0, ao contrario do intervalo normal."""
    if n == 0:
        return (0.0, 0.0)
    p = k / n
    d = 1 + z * z / n
    c = (p + z * z / (2 * n)) / d
    hw = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
    return (max(0.0, c - hw), min(1.0, c + hw))


def conv_err(h, c):
    x = torch.randn(1, c, h, h, dtype=torch.float16)
    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
    g = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()
    r = F.conv2d(x.float(), w.float(), padding=1)
    return (g.float().cpu() - r).abs().max().item() / max(r.abs().max().item(), 1e-6)


reps = int(sys.argv[1]) if len(sys.argv) > 1 else 8
# mesmos shapes do repro_inproc, repetidos: mantem comparabilidade com o
# historico e ao mesmo tempo da amostra suficiente
shapes = [(h, c) for h in range(32, 136, 8) for c in (64, 320)]

torch.manual_seed(0)
say(f"{len(shapes)} shapes x {reps} repeticoes = {len(shapes)*reps} operacoes")
say(f"criterio: err_rel > {TOL:g} contra referencia de CPU em fp32")
say("")

n = bad = 0
primeiro = None
t0 = time.time()
for rep in range(1, reps + 1):
    rep_bad = 0
    for h, c in shapes:
        n += 1
        try:
            e = conv_err(h, c)
        except Exception as exc:
            say(f"  op {n}: EXCECAO {type(exc).__name__}: {exc}")
            raise
        if e > TOL:
            bad += 1
            rep_bad += 1
            if primeiro is None:
                primeiro = n
    lo, hi = wilson(bad, n)
    say(f"  rep {rep}/{reps}: +{rep_bad:2d} erradas   acumulado {bad:3d}/{n:3d} "
        f"= {100*bad/n:5.2f}%  IC95 [{100*lo:5.2f}, {100*hi:5.2f}]"
        f"   {time.time()-t0:5.1f}s")

lo, hi = wilson(bad, n)
say("")
say(f"TAXA {100*bad/n:.2f}%   IC95 [{100*lo:.2f}%, {100*hi:.2f}%]   {bad}/{n}")
say(f"primeira operacao errada: {primeiro}")
say("")
say("Para comparar dois estados, olhe se os IC95 se sobrepoem. Se sobrepoem,")
say("a diferenca nao esta demonstrada -- por mais convidativa que a media seja.")
say("FIM")
