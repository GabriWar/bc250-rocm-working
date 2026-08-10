#!/usr/bin/env python3
"""Do two live allocations occupy the same device memory?

Where the suspicion comes from
------------------------------
Measuring on three legs (comparison on the GPU + both buffers brought back), a
relation showed up that no race hypothesis explains: the wrong data appears at
the BASE of the victim buffer and comes from an ARBITRARY offset of another
tensor.

    victim 0x7f2945a00000  <- offset 1425408 of c=320 h=104  (= 2850816 B)
    victim 0x7f2947000000  <- offset  196608 of c=320 h=112  (=  393216 B)

And, decisively: buffers that do not even take part in the burst are hit. A
tensor uploaded with sync, sitting still in memory, comes back with another one's
content.

If two tensors share an address, writing to one necessarily writes to the other,
and the relation becomes exactly `victim_base = other_base + N`. No race, no lost
signal, no staging needed: it is arithmetic.

What this script does
---------------------
1. Allocates the way the real workload allocates, with frees and reuse.
2. At each step, checks whether any pair of LIVE tensors has overlapping
   [ptr, ptr+bytes) ranges.
3. Confirms it in practice: writes a pattern into each live tensor and checks
   whether writing to one changes another.

Step 3 matters because PyTorch's pointer is virtual; overlap can exist in the
mapping without showing up in pointer arithmetic, and vice versa. Writing and
reading is the proof that does not depend on interpretation.
"""
import os

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/sobreposicao.result")
_f = open(OUT, "a", buffering=1)


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


def sobrepostos(vivos):
    """Pairs whose address ranges intersect."""
    r = []
    it = [(rot, t.data_ptr(), t.numel() * t.element_size()) for rot, t in vivos]
    for i in range(len(it)):
        for j in range(i + 1, len(it)):
            (ra, a, na), (rb, b, nb) = it[i], it[j]
            if a < b + nb and b < a + na:
                r.append((ra, a, na, rb, b, nb))
    return r


boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say("=" * 70)
say(f"boot={boot} pid={os.getpid()}")
aquecer()
torch.manual_seed(0)

achou_aritmetico = 0
achou_pratico = 0
for ciclo in (1, 2, 3, 4, 5):
    vivos = []
    for rodada in ("ref", "raj"):
        for h, c in ALVOS:
            x = torch.randn(1, c, h, h, dtype=torch.float16)
            g = x.to(DEV)
            if rodada == "ref":
                torch.cuda.synchronize()
            vivos.append((f"{rodada} c={c} h={h}", g))
    torch.cuda.synchronize()

    for ra, a, na, rb, b, nb in sobrepostos(vivos):
        achou_aritmetico += 1
        say(f"  ciclo{ciclo} SOBREPOSICAO DE ENDERECO: {ra} @0x{a:x}+{na} "
            f"x {rb} @0x{b:x}+{nb}  (delta {b-a:+d} B)")

    # practical proof: each live tensor gets a unique value; if writing to one
    # of them changes another, they really share memory
    for k, (rot, t) in enumerate(vivos):
        t.fill_(float(k + 1) / 64.0)
    torch.cuda.synchronize()
    for k, (rot, t) in enumerate(vivos):
        esperado = float(k + 1) / 64.0
        errados = int((t != esperado).sum())
        if errados:
            achou_pratico += 1
            v = t.flatten()
            i0 = int(torch.nonzero((v != esperado).flatten()).flatten()[0])
            outro = int(round(float(v[i0]) * 64.0)) - 1
            quem = vivos[outro][0] if 0 <= outro < len(vivos) else f"valor {float(v[i0])}"
            say(f"  ciclo{ciclo} PISADO NA PRATICA: {rot} @0x{t.data_ptr():x} "
                f"tem {errados} elementos de \"{quem}\" a partir de {i0} "
                f"(0x{t.data_ptr()+i0*2:x})")

say(f"  resumo: {achou_aritmetico} sobreposicoes de endereco, "
    f"{achou_pratico} tensores pisados na pratica")
say("FIM")
