#!/usr/bin/env python3
"""De onde vem o dado errado? Planta marca IMPOSSIVEL e le a etiqueta.

Historico das hipoteses sobre a origem do dado errado, todas caidas:

  "saida antiga de convolucao"      nunca verificado direto
  "chunk seguinte da transferencia" refutado: nao casa com nenhum offset do
                                    proprio tensor (+-8 MiB, passo 64 KiB)
  "reciclagem do buffer de staging" refutado: chunk de 16 e 64 MiB, muito acima
                                    do maior tensor, nao mudou a corrupcao

E a primeira versao DESTE script tambem estava errada, de dois jeitos:

  1. A marca ficava nos 4 bits altos, base 7 -> faixa 7..14. Em fp16 o bit 15 e
     o sinal, entao TODO valor negativo cai em 8..F. As "marcas encontradas"
     (8,9,10,11,12) eram so os negativos: somavam exatamente metade dos
     elementos errados, que e a fracao de negativos numa normal.
  2. Os 8 buffers eram criados e deletados um por vez, entao o alocador
     devolvia sempre o MESMO endereco e so o ultimo padrao sobrevivia.

Versao corrigida
----------------
A marca agora e NaN de fp16: expoente 11111 com mantissa nao nula. `randn` nunca
produz NaN, entao qualquer NaN na regiao errada e prova sem ambiguidade -- nao
existe faixa de valor legitimo que colida.

    valor = 0x7C00 | (buffer << 7) | (bloco & 0x7F)

    bits 14..10  expoente 11111  -> NaN, impossivel em randn
    bits  9..7   qual buffer plantado (0..7)
    bits  6..0   qual bloco de 4096 elementos dentro dele

E os buffers sao mantidos VIVOS ao mesmo tempo antes de liberar, para ocuparem
enderecos distintos.

Controle negativo embutido: conta quantos NaN existem no dado CORRETO. Tem que
ser zero; se nao for, a deteccao esta furada de novo.
"""
import os
from collections import Counter

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/plant_pattern.result")
_f = open(OUT, "w", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


ALVOS = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]
NBUF = 8
BLOCO = 4096


def marca(buf, n):
    """int16 onde cada elemento e um NaN de fp16 codificando buffer e bloco.

    0x7C00 = expoente 11111, mantissa 0 -> isso e infinito, nao NaN. A mantissa
    so fica nao nula quando (buf<<7)|bloco != 0, e o par (0,0) existe. Forca o
    bit 0 ligado para que TODO elemento seja NaN de verdade, e desloca o campo
    de bloco um bit para a esquerda para nao colidir com esse bit.
    """
    idx = torch.arange(n, dtype=torch.int32)
    v = 0x7C00 | ((buf & 0x7) << 8) | (((idx // BLOCO) & 0x7F) << 1) | 1
    return v.to(torch.int16)


def procurar(volta, i0, fontes):
    """O trecho errado existe, exato, em algum tensor de origem ja visto?

    A versao anterior varria deslocamentos numa grade de 64 KiB dentro do proprio
    tensor -- se a origem fosse OUTRO tensor, ou um offset fora da grade, passava
    batido. Aqui a busca e exaustiva e casa bit a bit: pega os primeiros indices
    onde o valor bate e so entao compara a janela inteira.

    Compara como int16 porque em fp16 `nan != nan` estragaria a igualdade.
    """
    import numpy as np
    JAN = 64
    w = volta.flatten()[i0:i0 + JAN].view(torch.int16).numpy()
    if len(w) < JAN:
        return []
    achados = []
    for rot, x in fontes:
        s = x.flatten().view(torch.int16).numpy()
        for j in np.flatnonzero(s == w[0]):
            if j + JAN <= len(s) and np.array_equal(s[j:j + JAN], w):
                d = int(j) - i0
                achados.append(f"o dado errado E o offset {int(j)} de {rot} "
                               f"(deslocamento {d:+d} elem = {d*2/1024:+.1f} KiB)")
                break
    return achados


REG = []   # (rotulo, endereco, bytes) de TODA alocacao ja feita neste processo


def registrar(rot, t):
    REG.append((rot, t.data_ptr(), t.numel() * t.element_size()))


def quem_mora_em(a):
    """Que alocacoes ja ocuparam este endereco? Inclui blocos ja liberados.

    A pergunta e se o endereco onde o dado extraviado caiu foi destino de uma
    transferencia ANTERIOR. Se for, a escrita usou um endereco obsoleto -- e o
    defeito e descritor/kernarg reciclado antes da conclusao, nao corrida de
    dado.
    """
    out = []
    for rot, base, n in REG:
        if base <= a < base + n:
            out.append(f"{rot} @0x{base:x} (+{a-base} B de {n} B)")
        elif a == base:
            out.append(f"{rot} @0x{base:x} (inicio exato)")
    return out


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


def plantar():
    """Marca os blocos que o lote vai reusar, com as MESMAS formas.

    Plantar em buffers de tamanho arbitrario nao serve: o alocador do PyTorch
    entrega blocos por classe de tamanho, entao a rajada pegaria blocos que
    nunca foram marcados. Pior, alocar e liberar 64 MiB extras muda o estado do
    alocador o bastante para a corrupcao sumir -- foi o que aconteceu na
    primeira tentativa: 0 corrompidos em 3 ciclos, teste sem sinal nenhum.

    Aqui as formas sao identicas as do lote (int16 de n elementos ocupa os
    mesmos bytes que fp16 de n elementos), com sync a cada upload para que a
    marca chegue integra. Ao liberar, esses blocos exatos voltam para o cache e
    a rajada seguinte os recebe de volta.
    """
    ms, addrs = [], []
    for i, (h, c) in enumerate(ALVOS):
        p = marca(i, c * h * h).to(DEV)
        torch.cuda.synchronize()              # marca tem que chegar correta
        registrar(f"MARCA c={c} h={h}", p)
        ms.append(p)
        addrs.append(p.data_ptr())
    del ms
    return addrs


say("aquecendo (sem isso nada corrompe)")
aquecer()
say("")

torch.manual_seed(0)
total_nan_correto = 0
fontes = []          # todo tensor de origem ja visto, para a busca exaustiva
for ciclo in (1, 2, 3, 4, 5):
    plantados = plantar()

    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        fontes.append((f"ciclo{ciclo} c={c} h={h}", x))
        g = x.to(DEV)                         # rajada, sem sync entre uploads
        registrar(f"ciclo{ciclo} c={c} h={h}", g)
        gpu.append(g)
    torch.cuda.synchronize()

    marcado = {g.data_ptr() for g, a in zip(gpu, plantados) if g.data_ptr() == a}
    say(f"  ciclo{ciclo}: {len(marcado)}/{len(ALVOS)} tensores cairam em bloco marcado")

    for (h, c, x), xg in zip(cpu, gpu):
        total_nan_correto += int(torch.isnan(x).sum())   # controle negativo
        volta = xg.cpu()
        dif = (volta != x)
        nd = int(dif.sum())
        if nd == 0:
            continue
        idx = torch.nonzero(dif.flatten()).flatten()
        errados = volta.flatten()[idx]
        nan = torch.isnan(errados)
        nnan = int(nan.sum())
        # CRITICO: o argumento "sem NaN => nao e memoria velha" so vale se ESTE
        # bloco estava marcado. Sem isso, ausencia de NaN nao diz nada.
        est = "MARCADO" if xg.data_ptr() in marcado else "nao-marcado (teste cego)"
        say(f"  ciclo{ciclo} c={c} h={h}: {nd} errados, primeiro em {int(idx[0])}, "
            f"ptr=0x{xg.data_ptr():x} [{est}]")
        if nnan == 0:
            f32 = errados.float()
            cor = x.flatten()[idx].float()
            if xg.data_ptr() in marcado:
                say(f"      NENHUM NaN e o bloco ESTAVA marcado -> o dado errado nao e")
                say(f"      memoria velha: alguem ESCREVEU valores plausiveis ali")
            else:
                say(f"      sem NaN, mas o bloco nao estava marcado -- inconclusivo")
            say(f"      errado:  min={f32.min():.3f} max={f32.max():.3f} std={f32.std():.3f}")
            say(f"      correto: min={cor.min():.3f} max={cor.max():.3f} std={cor.std():.3f}")
            # endereco ABSOLUTO onde o dado extraviado foi parar
            abs_a = xg.data_ptr() + int(idx[0]) * 2
            al = "".join("2MiB" if abs_a % (2<<20) == 0 else
                         "1MiB" if abs_a % (1<<20) == 0 else
                         "64KiB" if abs_a % (1<<16) == 0 else
                         "4KiB" if abs_a % (1<<12) == 0 else "nao alinhado" for _ in [0])
            say(f"      destino do extravio: 0x{abs_a:x}  (alinhamento: {al})")
            for m in quem_mora_em(abs_a):
                say(f"      esse endereco ja foi: {m}")
            achado = procurar(volta, int(idx[0]), fontes)
            for a in achado:
                say(f"      >>> {a}")
            if not achado:
                say(f"      o trecho errado nao existe em NENHUM dos {len(fontes)} "
                    f"tensores de origem ja vistos")
        else:
            u = errados.view(torch.int16)[nan].to(torch.int32) & 0xFFFF
            bufs = ((u >> 7) & 0x7).tolist()
            blocos = (u & 0x7F).tolist()
            say(f"      >>> {nnan} de {nd} sao NaN = MARCA PLANTADA ({100*nnan/nd:.1f}%)")
            say(f"      >>> buffers de origem: {dict(Counter(bufs).most_common(4))}")
            say(f"      >>> blocos de origem:  {sorted(set(blocos))[:10]}")

say("")
say(f"controle negativo: NaN no dado CORRETO = {total_nan_correto} (tem que ser 0)")
say("FIM")
