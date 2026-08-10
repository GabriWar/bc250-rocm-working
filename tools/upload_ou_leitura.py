#!/usr/bin/env python3
"""Does the data get corrupted on the way UP or on the way BACK?

Why the question exists
-----------------------
Every diagnosis so far measured `x.to(cuda)` followed by `.cpu()` and compared on
the host. That does not separate the two halves. The ROCclr trace showed why it
matters: H2D and D2H use the SAME pool of 4 staging slots of 1 MiB.

    COPY dst=0x7fd591d9a000 <- stg=0x7fd6b6300000   upload, READS from the slot
    COPY dst=0x7fd6b6300000 <- stg=0x7fd5a7600000   readback, WRITES to the slot

So "tensor Y's content showed up in tensor X" is compatible with both stories,
and the NaN mark test does not decide either: if the readback delivers another
operation's staging, no NaN comes back either.

How this test decides
---------------------
1. Uploads each tensor with a sync per upload. That path never corrupted in any
   configuration tested so far, so it serves as the reference.
2. Uploads the SAME data again, in a burst, without sync.
3. Compares the two INSIDE the GPU. Only a scalar crosses the bus.
4. Also compares by bringing them back, the old way.

    difference on the GPU > 0   -> device memory is wrong: it is the way UP
    difference on the GPU = 0   -> the device is right and only the way BACK lies

One caveat: the count scalar also travels via D2H. But it is 8 bytes in an
isolated copy, and a stray value would hardly be a plausible count. To reduce it
further, the count is read after a sync.
"""
import os

import numpy as np
import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/upload_ou_leitura.result")
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


boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say("=" * 70)
say(f"boot={boot} pid={os.getpid()}")
aquecer()
torch.manual_seed(0)

for ciclo in (1, 2, 3, 4, 5):
    # reference: one upload at a time, with sync -- the path that never corrupted
    ref = []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        g = x.to(DEV)
        torch.cuda.synchronize()
        ref.append((h, c, x, g))

    # burst: same data, no sync between uploads
    raj = [x.to(DEV) for (h, c, x, g) in ref]
    torch.cuda.synchronize()

    for (h, c, x, g), b in zip(ref, raj):
        # THREE legs, not two. With only `b vs g` on the GPU and `b vs x` on the host
        # there is no way to know WHICH of the two uploads failed -- the first version of
        # this test had that hole and produced "na_gpu>0 with no_host=0", which alone
        # does not distinguish "wrong reference" from "wrong comparison on the GPU".
        n1 = (b != g).sum(); torch.cuda.synchronize(); n1 = int(n1)
        n2 = (b != g).sum(); torch.cuda.synchronize(); n2 = int(n2)  # repeat
        hb = int((b.cpu() != x).sum())    # burst, as seen from the host
        hg = int((g.cpu() != x).sum())    # reference, as seen from the host
        if not (n1 or n2 or hb or hg):
            continue
        # MIND the label: `g` was uploaded with sync but then sat still in
        # memory for the entire burst. hg>0 is compatible with "uploaded wrong"
        # AND with "run over afterwards". There is no way to label it without finding
        # the origin of the wrong data, so that is what is done here.
        say(f"  ciclo{ciclo} c={c} h={h}: gpu(b!=g)={n1}/{n2} "
            f"host(b!=x)={hb} host(g!=x)={hg}")
        for rot, vt in (("rajada", b), ("referencia", g)):
            vv = vt.cpu()
            d = (vv != x)
            if not int(d.sum()):
                continue
            i0 = int(torch.nonzero(d.flatten()).flatten()[0])
            w = vv.flatten()[i0:i0+64].view(torch.int16).numpy()
            say(f"      {rot}: errado a partir de {i0}, "
                f"endereco 0x{vt.data_ptr()+i0*2:x}")
            achou = False
            for hh, cc, xx, _g in ref:
                sr = xx.flatten().view(torch.int16).numpy()
                for j in np.flatnonzero(sr == w[0]):
                    if j+64 <= len(sr) and np.array_equal(sr[j:j+64], w):
                        say(f"      >>> conteudo = offset {int(j)} de c={cc} h={hh}"
                            f"{' (ele mesmo)' if (hh,cc)==(h,c) else ' -- ATROPELADO por outro tensor'}")
                        achou = True; break
                if achou: break
            if not achou:
                say(f"      >>> nao veio de nenhum tensor deste ciclo")
say("FIM")
