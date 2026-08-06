#!/usr/bin/env python3
"""Rastreia cada sub-copia do ROCclr e cruza com onde o dado realmente caiu.

O que ja se sabe (medido, nao suposto)
--------------------------------------
Numa rajada de uploads sem sync, o conteudo INTEIRO de um tensor aparece dentro
do buffer de destino de OUTRO tensor da mesma rajada, no offset 0 da origem:

    ciclo1 c=320 h=64 @0x7fc1cba9a000, errado a partir do elemento 733184
      -> endereco absoluto 0x7fc1cbC00000 (2 MiB alinhado)
      -> conteudo = offset 0 de c=64 h=64, os 262144 elementos completos

Nao e memoria velha: o destino foi pre-marcado com NaN e voltou sem nenhum NaN.
Alguem escreveu dado valido no lugar errado.

O que este script decide
------------------------
O ROCclr loga cada sub-copia com destino, origem e tamanho:

    HSA Copy copy_engine=.., dst=0x.., src=0x.., size=.., wait_event=0x..,
             completion_signal=0x..

  - se existir uma linha com dst = endereco do extravio, o runtime EMITIU a
    copia no lugar errado -> defeito de software, da para consertar no clr
  - se todos os dst estiverem certos, a copia foi emitida certa e o dado saiu
    do lugar errado -> ou o slot de staging (o `src`) foi reescrito antes do
    DMA ler, ou o hardware entregou fora

O `src` e o endereco do slot de staging. Se duas copias em voo compartilharem o
mesmo `src`, a colisao de slot fica visivel direto no log.

Cada ciclo emite um upload de tamanho unico como marcador, para fatiar o log.
"""
import os
import subprocess
import sys

import torch

DEV = "cuda"
LOG = os.path.expanduser("~/bc250-grimoire/copy_trace.log")
OUT = os.path.expanduser("~/bc250-grimoire/copy_trace.result")
_f = open(OUT, "w", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


ALVOS = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


def marcador(n_bytes):
    """Upload de tamanho unico: vira uma linha reconhecivel no log do ROCclr."""
    t = torch.zeros(n_bytes // 2, dtype=torch.float16)
    g = t.to(DEV)
    torch.cuda.synchronize()
    return n_bytes


say(f"log do ROCclr em {LOG}")
say(f"AMD_LOG_LEVEL={os.environ.get('AMD_LOG_LEVEL')} "
    f"AMD_LOG_MASK={os.environ.get('AMD_LOG_MASK')}")
say("")
aquecer()

torch.manual_seed(0)
for ciclo in range(1, 6):
    mk = 1000000 + ciclo * 2000       # tamanho unico por ciclo
    marcador(mk)
    say(f"########## ciclo {ciclo}  marcador size={mk} ##########")

    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        gpu.append(x.to(DEV))          # rajada, sem sync entre uploads
    torch.cuda.synchronize()

    for (h, c, x), xg in zip(cpu, gpu):
        say(f"  c={c} h={h} bytes={x.numel()*2} "
            f"cpu=0x{x.data_ptr():x} gpu=0x{xg.data_ptr():x}")

    for (h, c, x), xg in zip(cpu, gpu):
        volta = xg.cpu()
        dif = (volta != x)
        nd = int(dif.sum())
        if not nd:
            continue
        idx = torch.nonzero(dif.flatten()).flatten()
        i0 = int(idx[0])
        abs_a = xg.data_ptr() + i0 * 2
        say(f"  !! CORROMPIDO c={c} h={h}: {nd} errados a partir de {i0}")
        say(f"     extravio em 0x{abs_a:x}  (base 0x{xg.data_ptr():x} + {i0*2} B)")
        # de qual tensor veio
        import numpy as np
        w = volta.flatten()[i0:i0 + 64].view(torch.int16).numpy()
        for hh, cc, xx in cpu:
            s = xx.flatten().view(torch.int16).numpy()
            for j in np.flatnonzero(s == w[0]):
                if j + 64 <= len(s) and np.array_equal(s[j:j + 64], w):
                    say(f"     conteudo = offset {int(j)} de c={cc} h={hh} "
                        f"(cpu=0x{xx.data_ptr():x})")
                    break
say("FIM")
