#!/usr/bin/env python3
"""O dado se estraga na SUBIDA ou na VOLTA?

Por que a pergunta existe
-------------------------
Todo o diagnostico ate aqui media `x.to(cuda)` seguido de `.cpu()` e comparava
no host. Isso nao separa as duas metades. O trace do ROCclr mostrou por que
importa: H2D e D2H usam o MESMO pool de 4 slots de staging de 1 MiB.

    COPY dst=0x7fd591d9a000 <- stg=0x7fd6b6300000   upload, LE do slot
    COPY dst=0x7fd6b6300000 <- stg=0x7fd5a7600000   leitura, ESCREVE no slot

Entao "o conteudo do tensor Y apareceu no tensor X" e compativel com as duas
historias, e o teste da marca NaN tambem nao decide: se a leitura entregar o
staging de outra operacao, tambem nao volta NaN nenhum.

Como este teste decide
----------------------
1. Sobe cada tensor com sync a cada upload. Esse caminho nunca corrompeu em
   nenhuma configuracao ja testada, entao serve de referencia.
2. Sobe os MESMOS dados de novo, em rajada, sem sync.
3. Compara os dois DENTRO da GPU. So um escalar atravessa o barramento.
4. Compara tambem trazendo de volta, do jeito antigo.

    diferenca na GPU > 0   -> a memoria do dispositivo esta errada: e a SUBIDA
    diferenca na GPU = 0   -> o dispositivo esta certo e so a VOLTA mente

Um cuidado: o escalar da contagem tambem viaja por D2H. Mas sao 8 bytes numa
copia isolada, e um valor extraviado dificilmente seria uma contagem plausivel.
Para reduzir ainda mais, a contagem e lida depois de um sync.
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
    # referencia: um upload por vez, com sync -- caminho que nunca corrompeu
    ref = []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        g = x.to(DEV)
        torch.cuda.synchronize()
        ref.append((h, c, x, g))

    # rajada: mesmo dado, sem sync entre uploads
    raj = [x.to(DEV) for (h, c, x, g) in ref]
    torch.cuda.synchronize()

    for (h, c, x, g), b in zip(ref, raj):
        # TRES pernas, nao duas. Com so `b vs g` na GPU e `b vs x` no host nao
        # da para saber QUAL dos dois uploads errou -- a primeira versao deste
        # teste tinha esse furo e produziu "na_gpu>0 com no_host=0", que sozinho
        # nao distingue "referencia errada" de "comparacao na GPU errada".
        n1 = (b != g).sum(); torch.cuda.synchronize(); n1 = int(n1)
        n2 = (b != g).sum(); torch.cuda.synchronize(); n2 = int(n2)  # repete
        hb = int((b.cpu() != x).sum())    # rajada, vista do host
        hg = int((g.cpu() != x).sum())    # referencia, vista do host
        if not (n1 or n2 or hb or hg):
            continue
        # ATENCAO ao rotulo: `g` foi subido com sync mas depois ficou parado na
        # memoria durante a rajada inteira. hg>0 e compativel com "subiu errado"
        # E com "foi atropelado depois". Nao da para rotular sem achar a origem
        # do dado errado, entao e isso que se faz aqui.
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
