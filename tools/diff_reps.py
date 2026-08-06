#!/usr/bin/env python3
"""O que muda entre a primeira e a segunda passada?

Medido em 2026-08-05: rodando os mesmos 26 shapes varias vezes no mesmo
processo, o numero de erros vai 3, 0, 4, 5, 5, 5 -- converge para um conjunto
fixo de cinco, todos c=320. Mas o conjunto muda entre sessoes, o que nao e
compativel com "o kernel calcula errado para esses shapes".

A hipotese restante e alocacao: uma regiao ruim que o alocador do torch passa a
reusar depois da primeira passada. Este script testa isso diretamente,
registrando o ponteiro de device de cada tensor ao lado do erro.

Se os que erram compartilharem faixa de endereco, e alocacao.
Se os endereços forem indistinguiveis dos que acertam, nao e.

Saida: ~/bc250-grimoire/diff_reps.result (fsync por linha) e um resumo no fim.
"""
import os

import torch
import torch.nn.functional as F

DEV = "cuda"
TOL = 1e-2
_f = open(os.path.expanduser("~/bc250-grimoire/diff_reps.result"), "w", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def mb(x):
    return x / (1024 * 1024)


shapes = [(h, c) for h in range(32, 136, 8) for c in (64, 320)]
torch.manual_seed(0)

say("por operacao: ponteiro de device do input, do peso e da saida, mais o erro")
say("a pergunta: os que erram caem numa faixa de endereco propria?")
say("")

registros = []  # (rep, op, c, h, in_ptr, w_ptr, out_ptr, err)

for rep in range(1, 5):
    say(f"=== rep {rep} ===")
    say(f"  antes: alocado {mb(torch.cuda.memory_allocated()):8.1f} MB   "
        f"reservado {mb(torch.cuda.memory_reserved()):8.1f} MB")
    ruins = []
    for op, (h, c) in enumerate(shapes, 1):
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        w = torch.randn(c, c, 3, 3, dtype=torch.float16)
        xg, wg = x.to(DEV), w.to(DEV)
        g = F.conv2d(xg, wg, padding=1)
        torch.cuda.synchronize()
        r = F.conv2d(x.float(), w.float(), padding=1)
        e = (g.float().cpu() - r).abs().max().item() / max(r.abs().max().item(), 1e-6)
        registros.append((rep, op, c, h, xg.data_ptr(), wg.data_ptr(), g.data_ptr(), e))
        if e > TOL:
            ruins.append((op, c, h, e))
            say(f"    ERRADO op{op:3d} c={c:3d} h={h:3d}  err={e:.3e}  "
                f"in=0x{xg.data_ptr():x} out=0x{g.data_ptr():x}")
    say(f"  depois: alocado {mb(torch.cuda.memory_allocated()):8.1f} MB   "
        f"reservado {mb(torch.cuda.memory_reserved()):8.1f} MB   erradas={len(ruins)}")
    say("")

say("=== os enderecos separam certo de errado? ===")
bons = [r for r in registros if r[7] <= TOL]
maus = [r for r in registros if r[7] > TOL]
say(f"  {len(bons)} corretas, {len(maus)} erradas")
if maus:
    for nome, idx in (("saida", 6), ("input", 4), ("peso", 5)):
        pb = [r[idx] for r in bons]
        pm = [r[idx] for r in maus]
        say(f"  {nome}:")
        say(f"    corretas  0x{min(pb):x} .. 0x{max(pb):x}  ({len(set(pb))} distintos)")
        say(f"    erradas   0x{min(pm):x} .. 0x{max(pm):x}  ({len(set(pm))} distintos)")
        fora = [p for p in pm if p < min(pb) or p > max(pb)]
        say(f"    erradas fora da faixa das corretas: {len(fora)}/{len(pm)}")
    say("")
    say("  mesmos shapes, endereco por repeticao:")
    chaves = sorted({(r[2], r[3]) for r in maus})
    for c, h in chaves:
        linhas = [r for r in registros if (r[2], r[3]) == (c, h)]
        det = "  ".join(f"r{r[0]}:0x{r[6]:x}{'*' if r[7] > TOL else ''}" for r in linhas)
        say(f"    c={c:3d} h={h:3d}  {det}")
    say("")
    say("  (* = errou nessa repeticao)")
    say("  se o mesmo shape muda de endereco E so erra em alguns, e alocacao.")
    say("  se erra sempre, independente do endereco, nao e.")
say("FIM")
