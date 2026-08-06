#!/usr/bin/env python3
"""Duas alocacoes vivas ocupam a mesma memoria de dispositivo?

De onde vem a suspeita
----------------------
Medindo com tres pernas (comparacao na GPU + volta dos dois buffers), apareceu
uma relacao que nenhuma hipotese de corrida explica: o dado errado aparece na
BASE do buffer vitima e vem de um offset ARBITRARIO de outro tensor.

    vitima 0x7f2945a00000  <- offset 1425408 de c=320 h=104  (= 2850816 B)
    vitima 0x7f2947000000  <- offset  196608 de c=320 h=112  (=  393216 B)

E, decisivo: buffers que nem participam da rajada sao atingidos. Um tensor
subido com sync, parado na memoria, volta com o conteudo de outro.

Se dois tensores compartilham endereco, escrever em um necessariamente escreve
no outro, e a relacao vira exatamente `vitima_base = outro_base + N`. Nao
precisa de corrida, de sinal perdido nem de staging: e aritmetica.

O que este script faz
---------------------
1. Aloca como a carga real aloca, com liberacao e reuso.
2. A cada passo, confere se algum par de tensores VIVOS tem intervalo
   [ptr, ptr+bytes) sobreposto.
3. Confirma na pratica: escreve um padrao em cada tensor vivo e verifica se
   escrever num deles altera outro.

O passo 3 importa porque o ponteiro do PyTorch e virtual; sobreposicao pode
existir no mapeamento sem aparecer na aritmetica de ponteiro, e vice-versa.
Escrever e ler e a prova que nao depende de interpretacao.
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
    """Pares cujos intervalos de endereco se cruzam."""
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

    # prova pratica: cada tensor vivo recebe um valor unico; se escrever num
    # deles muda outro, compartilham memoria de verdade
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
