#!/usr/bin/env python3
"""A corrupcao depende do tempo de vida do buffer de ORIGEM no host?

Como a pergunta apareceu
------------------------
Rodando plant_pattern.py duas vezes, mesmo boot, mesma carga:

  versao que LIBERA os tensores de origem a cada ciclo   5 de 5 ciclos corromperam
  versao que SEGURA todos vivos (lista `fontes`)         0 de 5

A unica diferenca entre as duas era acumular os tensores numa lista para busca
posterior -- ou seja, deixar de devolver a memoria de host ao alocador.

Por que isso seria causal
-------------------------
Em clr/rocclr/device/rocm/rocblit.cpp o H2D tem dois caminhos. No staged, o dado
e copiado para um buffer intermediario antes do DMA. No pinado, nao ha copia: o
DMA le `hostSrc` diretamente. Nos dois casos a funcao retorna sem esperar a
conclusao -- diferente do D2H, que chama `gpu().Barriers().WaitCurrent()`.

Se o host liberar e reusar aquelas paginas antes do DMA terminar, a GPU le o
conteudo novo. Isso explicaria o que nenhuma hipotese anterior explicou:

  - valores errados com distribuicao IDENTICA a correta (std 1.0, faixa +-3.9),
    porque sao randn de outro tensor, nao lixo
  - destino pre-marcado com NaN volta SEM NaN nenhum: alguem escreveu ali, a
    copia nao deixou de acontecer
  - o trecho errado nao casa com nenhum offset do proprio tensor

Desenho
-------
Um processo por braco, seis processos, mesmo boot. Ordem contrabalanceada
`H F F H H F` para que nenhum braco fique so com as posicoes iniciais -- nesta
placa a primeira carga de GPU de um processo se comporta diferente das
seguintes, entao alternar (`H F H F`) daria todas as posicoes impares a um
braco so.

  HOLD  guarda toda origem viva ate o fim do processo
  FREE  rebind a cada ciclo, devolvendo a memoria ao alocador

Tudo o mais e identico, inclusive a semente. Uso:  host_lifetime.py HOLD|FREE
"""
import os
import sys

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/host_lifetime.historico")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


ALVOS = [(112, 320), (128, 320), (104, 320), (96, 320), (64, 320), (64, 64)]
CICLOS = 5


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


braco = sys.argv[1]
assert braco in ("HOLD", "FREE")
boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]

aquecer()
torch.manual_seed(0)

segurados = []       # so alimentado no braco HOLD
ruins = 0
detalhe = []
for ciclo in range(1, CICLOS + 1):
    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        if braco == "HOLD":
            segurados.append(x)
        gpu.append(x.to(DEV))                 # rajada, sem sync entre uploads
    torch.cuda.synchronize()

    for (h, c, x), xg in zip(cpu, gpu):
        nd = int((xg.cpu() != x).sum())
        # o endereco vai junto: os dados dizem que a sorte e decidida no inicio
        # do processo e nao muda, entao a suspeita agora e a FAIXA que o
        # alocador entregou, nao o instante da copia
        detalhe.append(f"c{ciclo}:{c}x{h}@0x{xg.data_ptr():x}={nd}")
        if nd:
            ruins += 1
    # no braco FREE, `cpu` e `gpu` sao rebindados na proxima volta e a memoria
    # de host volta para o alocador; no HOLD, `segurados` mantem tudo vivo

say(f"braco={braco} boot={boot} pid={os.getpid()} ruins={ruins}/{CICLOS*len(ALVOS)} "
    f"segurados={len(segurados)} | {' '.join(detalhe) if detalhe else 'limpo'}")
