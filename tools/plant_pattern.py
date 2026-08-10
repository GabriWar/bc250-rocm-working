#!/usr/bin/env python3
"""Where does the wrong data come from? Plant an IMPOSSIBLE mark and read the tag.

History of the hypotheses about the origin of the wrong data, all of them fallen:

  "old convolution output"          never verified directly
  "next chunk of the transfer"      refuted: does not match any offset of the
                                    tensor itself (+-8 MiB, 64 KiB stride)
  "staging buffer recycling"        refuted: 16 and 64 MiB chunks, far above the
                                    largest tensor, did not change the corruption

And the first version of THIS script was wrong too, in two ways:

  1. The mark sat in the high 4 bits, base 7 -> range 7..14. In fp16 bit 15 is
     the sign, so EVERY negative value falls in 8..F. The "marks found"
     (8,9,10,11,12) were just the negatives: they added up to exactly half the
     wrong elements, which is the fraction of negatives in a normal.
  2. The 8 buffers were created and deleted one at a time, so the allocator
     always handed back the SAME address and only the last pattern survived.

Corrected version
-----------------
The mark is now an fp16 NaN: exponent 11111 with a non-zero mantissa. `randn`
never produces NaN, so any NaN in the wrong region is unambiguous proof -- there
is no legitimate value range that could collide.

    value = 0x7C00 | (buffer << 7) | (block & 0x7F)

    bits 14..10  exponent 11111  -> NaN, impossible in randn
    bits  9..7   which planted buffer (0..7)
    bits  6..0   which 4096-element block inside it

And the buffers are kept ALIVE at the same time before being freed, so they take
distinct addresses.

Built-in negative control: counts how many NaN exist in the CORRECT data. It has
to be zero; if it is not, the detection is broken again.
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
    """int16 where every element is an fp16 NaN encoding buffer and block.

    0x7C00 = exponent 11111, mantissa 0 -> that is infinity, not NaN. The mantissa
    is only non-zero when (buf<<7)|block != 0, and the pair (0,0) exists. Force
    bit 0 on so that EVERY element is a real NaN, and shift the block field one
    bit left so it does not collide with that bit.
    """
    idx = torch.arange(n, dtype=torch.int32)
    v = 0x7C00 | ((buf & 0x7) << 8) | (((idx // BLOCO) & 0x7F) << 1) | 1
    return v.to(torch.int16)


def procurar(volta, i0, fontes):
    """Does the wrong stretch exist, exactly, in some source tensor already seen?

    The previous version scanned offsets on a 64 KiB grid inside the tensor
    itself -- if the source were ANOTHER tensor, or an offset off the grid, it
    slipped through. Here the search is exhaustive and matches bit for bit: it
    takes the first indices where the value matches and only then compares the
    whole window.

    Compares as int16 because in fp16 `nan != nan` would break the equality.
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


REG = []   # (label, address, bytes) of EVERY allocation made in this process


def registrar(rot, t):
    REG.append((rot, t.data_ptr(), t.numel() * t.element_size()))


def quem_mora_em(a):
    """Which allocations have occupied this address? Includes already freed blocks.

    The question is whether the address where the stray data landed was the
    destination of an EARLIER transfer. If it was, the write used a stale address
    -- and the defect is a descriptor/kernarg recycled before completion, not a
    data race.
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
    """Marks the blocks the batch will reuse, with the SAME shapes.

    Planting into arbitrarily sized buffers is useless: PyTorch's allocator hands
    out blocks by size class, so the burst would grab blocks that were never
    marked. Worse, allocating and freeing an extra 64 MiB changes the allocator
    state enough for the corruption to vanish -- which is what happened on the
    first attempt: 0 corrupted in 3 cycles, a test with no signal at all.

    Here the shapes are identical to the batch's (int16 of n elements occupies the
    same bytes as fp16 of n elements), with a sync on each upload so the mark
    arrives intact. On free, those exact blocks go back to the cache and the next
    burst gets them back.
    """
    ms, addrs = [], []
    for i, (h, c) in enumerate(ALVOS):
        p = marca(i, c * h * h).to(DEV)
        torch.cuda.synchronize()              # the mark has to arrive correct
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
fontes = []          # every source tensor seen so far, for the exhaustive search
for ciclo in (1, 2, 3, 4, 5):
    plantados = plantar()

    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        fontes.append((f"ciclo{ciclo} c={c} h={h}", x))
        g = x.to(DEV)                         # burst, no sync between uploads
        registrar(f"ciclo{ciclo} c={c} h={h}", g)
        gpu.append(g)
    torch.cuda.synchronize()

    marcado = {g.data_ptr() for g, a in zip(gpu, plantados) if g.data_ptr() == a}
    say(f"  ciclo{ciclo}: {len(marcado)}/{len(ALVOS)} tensores cairam em bloco marcado")

    for (h, c, x), xg in zip(cpu, gpu):
        total_nan_correto += int(torch.isnan(x).sum())   # negative control
        volta = xg.cpu()
        dif = (volta != x)
        nd = int(dif.sum())
        if nd == 0:
            continue
        idx = torch.nonzero(dif.flatten()).flatten()
        errados = volta.flatten()[idx]
        nan = torch.isnan(errados)
        nnan = int(nan.sum())
        # CRITICAL: the argument "no NaN => not stale memory" only holds if THIS
        # block was marked. Without that, the absence of NaN says nothing.
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
            # ABSOLUTE address where the stray data ended up
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
