#!/usr/bin/env python3
"""Qual operacao devolveu numero errado: a conv, o cast, ou o im2col+GEMM?

Contexto (2026-08-05)
---------------------
Comparando a saida de `F.conv2d` de duas formas, para c=320 h=128 depois de
aquecer, deu isto:

    comparada NA GPU contra im2col+GEMM     erro 1.293e+00   errado
    copiada e comparada contra a CPU        erro 3.770e-04   certo

Como a segunda esta certa, a saida da conv esta certa e quem mentiu foi o lado
GPU da comparacao. Mas aquele caminho junta DUAS operacoes que a comparacao no
host nao usa:

    1. F.unfold + matmul em fp32 na GPU   (a referencia)
    2. g.float()  -- o cast fp16->fp32 NA GPU

Isso importa porque (1) e exatamente o caminho do bc250_conv_fix.py, que o
repo apresenta como correcao. Se ele erra, nao e correcao, e so outro modo de
falha.

O que este script mede
----------------------
Quatro numeros por shape, montados para que cada um acuse uma operacao:

    conv      = |g.cpu().float()  - cpu_ref|   copia fp16 crua, cast na CPU
                -> a conv do MIOpen sozinha, sem cast de GPU no meio

    cast      = |g.float().cpu()  - g.cpu().float()|
                -> os dois caminhos partem do MESMO buffer; se diferem, o
                   cast fp16->fp32 na GPU esta errado. Qualquer valor acima de
                   zero ja e defeito, nao arredondamento.

    im2col    = |unfold_matmul(gpu).cpu() - cpu_ref|
                -> o caminho do bc250_conv_fix, trazido ao host ANTES de
                   comparar, para nao herdar o erro do cast

    conv~im2col = |g.cpu().float() - unfold_matmul(gpu).cpu()|
                -> os dois caminhos de GPU entre si

Leitura:
    so `conv` grande        -> MIOpen errou
    so `im2col` grande      -> o patch errou; ele nao e correcao
    so `cast` grande        -> o cast fp16->fp32 na GPU errou
    conv e im2col grandes   -> nao e caminho especifico, e mais embaixo

Uso
---
    qual_mentiu.py limpo          # SEM aquecimento: primeira carga do boot
    qual_mentiu.py sujo           # com aquecimento, 3 repeticoes
    qual_mentiu.py sujo 5         # com aquecimento, 5 repeticoes

Protocolo combinado: depois de cada reboot, uma rodada `limpo` e depois
algumas `sujo`, repetindo por 3 boots, para separar o que e do estado
acumulado do que e da operacao.

Cada execucao ANEXA ao historico em ~/bc250-grimoire/qual_mentiu.historico,
marcada com o boot_id, o uptime e a contagem de page faults no inicio. Assim o
padrao entre boots fica num arquivo so.
"""
import os
import subprocess
import sys
import time

import torch
import torch.nn.functional as F

DEV = "cuda"
TOL = 1e-2
HIST = os.path.expanduser("~/bc250-grimoire/qual_mentiu.historico")
_f = open(HIST, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def sh(cmd):
    try:
        return subprocess.run(cmd, shell=True, capture_output=True,
                              text=True, timeout=10).stdout.strip()
    except Exception:
        return "?"


def rel(a, b):
    """Erro relativo ao maximo da referencia, o mesmo criterio do resto do repo."""
    return (a - b).abs().max().item() / max(b.abs().max().item(), 1e-6)


def im2col_fp32(xg, wg):
    """im2col + GEMM promovendo para fp32. NAO e o que o patch faz -- o GEMM
    em fp32 usa kernels rocBLAS diferentes dos de fp16."""
    n, cin, hi, wi = xg.shape
    cout = wg.shape[0]
    cols = F.unfold(xg, (3, 3), padding=1)
    o = wg.reshape(cout, -1).float() @ cols.float()
    return o.reshape(n, cout, hi, wi)


def im2col_fp16(xg, wg):
    """Exatamente o que bc250_conv_fix.py faz: tudo em fp16, sem promover.

    Copiado do corpo de _conv2d_im2col para o caso 3x3 stride 1 padding 1, que
    e o que estes shapes usam. Se este errar, o patch nao e correcao."""
    n, cin, hi, wi = xg.shape
    cout = wg.shape[0]
    cols = F.unfold(xg, (3, 3), padding=1)
    o = wg.reshape(cout, -1) @ cols
    return o.reshape(n, cout, hi, wi)


modo = sys.argv[1] if len(sys.argv) > 1 else "sujo"
reps = int(sys.argv[2]) if len(sys.argv) > 2 else (1 if modo == "limpo" else 3)

alvos = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]
sweep = [(h, c) for h in range(32, 136, 8) for c in (64, 320)]

boot = sh("cat /proc/sys/kernel/random/boot_id")[:8]
faults = sh("printf 'grdg\\n' | sudo -S dmesg 2>/dev/null | grep -ci 'page fault'")

torch.manual_seed(0)
say("")
say("=" * 78)
say(f"modo={modo}  reps={reps}  boot={boot}  uptime={sh('uptime -p')}  "
    f"faults_no_inicio={faults}  {time.strftime('%Y-%m-%d %H:%M:%S')}")
say("=" * 78)

if modo == "limpo":
    say("sem aquecimento: esta e a primeira carga de GPU deste processo")
else:
    say("aquecendo 2 passadas do sweep de 26 shapes (e quando o conjunto de")
    say("falhas estabiliza)")
    for _ in range(2):
        for h, c in sweep:
            x = torch.randn(1, c, h, h, dtype=torch.float16)
            w = torch.randn(c, c, 3, 3, dtype=torch.float16)
            _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()
say("")

cab = (f"  {'shape':>12}  {'conv':>10}  {'cast':>10}  {'im2col16':>10}  "
       f"{'im2col32':>10}  {'1o':>4}  veredito")
resumo = {"CONV": 0, "CAST": 0, "IM2COL16": 0, "IM2COL32": 0, "ok": 0}

for rep in range(1, reps + 1):
    say(f"--- {modo} rep {rep}/{reps} ---")
    say(cab)
    for h, c in alvos:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        w = torch.randn(c, c, 3, 3, dtype=torch.float16)
        xg, wg = x.to(DEV), w.to(DEV)

        # ORDEM ALTERNADA. Rodar sempre conv primeiro e im2col depois faria o
        # segundo herdar qualquer envenenamento por posicao, e eu estaria
        # medindo ordem enquanto acreditava estar medindo operacao. A coluna
        # `1o` diz quem foi lancado primeiro nesta medida.
        conv_primeiro = (rep + alvos.index((h, c))) % 2 == 0

        if conv_primeiro:
            g = F.conv2d(xg, wg, padding=1); torch.cuda.synchronize()
            r16 = im2col_fp16(xg, wg); r32 = im2col_fp32(xg, wg)
        else:
            r16 = im2col_fp16(xg, wg); r32 = im2col_fp32(xg, wg)
            torch.cuda.synchronize()
            g = F.conv2d(xg, wg, padding=1)
        torch.cuda.synchronize()

        cpu_ref = F.conv2d(x.float(), w.float(), padding=1)

        g_puro = g.cpu().float()      # copia o fp16, cast na CPU
        g_cast = g.float().cpu()      # cast na GPU, depois copia
        i16 = r16.cpu().float()       # o patch, exatamente
        i32 = r32.cpu()               # variante promovida

        e_conv = rel(g_puro, cpu_ref)
        e_cast = (g_cast - g_puro).abs().max().item()
        e_i16 = rel(i16, cpu_ref)
        e_i32 = rel(i32, cpu_ref)

        # nan nunca e "ok": qualquer comparacao com nan e falsa, entao um
        # `> TOL` engole a pior falha possivel. Aconteceu na primeira bateria.
        def falhou(e):
            return (not (e == e)) or e > TOL

        ruins = []
        if falhou(e_conv):
            ruins.append("CONV")
        if falhou(e_cast) or e_cast > 0:
            ruins.append("CAST")
        if falhou(e_i16):
            ruins.append("IM2COL16")
        if falhou(e_i32):
            ruins.append("IM2COL32")
        for r in ruins:
            resumo[r] += 1
        if not ruins:
            resumo["ok"] += 1
        say(f"  c={c:3d} h={h:3d}  {e_conv:10.3e}  {e_cast:10.3e}  "
            f"{e_i16:10.3e}  {e_i32:10.3e}  {"conv" if conv_primeiro else "im2c":>4}  {"+".join(ruins) if ruins else "ok"}")
    say("")

n = reps * len(alvos)
say(f"RESUMO {modo} boot={boot}: de {n} medidas -> "
    f"CONV {resumo['CONV']}  CAST {resumo['CAST']}  IM2COL16 {resumo['IM2COL16']}  IM2COL32 {resumo['IM2COL32']}  "
    f"limpas {resumo['ok']}")
say("FIM")
