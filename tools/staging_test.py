#!/usr/bin/env python3
"""A corrupcao de H2D vem da reciclagem do buffer de staging do ROCclr?

Achado lendo o fonte (clr/rocclr/device/rocm/rocblit.cpp e rocvirtual.cpp):

  hsaCopyStagedOrPinned, caminho D2H:
      rocrCopyBuffer(...)
      gpu().Barriers().WaitCurrent();          <-- ESPERA antes de tocar o staging
      memcpy(hostDst + copyOffset, stagingBuffer, copysize);

  hsaCopyStagedOrPinned, caminho H2D:
      memcpy(stagingBuffer, hostSrc + copyOffset, copysize);
      rocrCopyBuffer(...)                      <-- assincrono
      // laco volta e faz memcpy no MESMO staging, sem esperar

A protecao do H2D e indireta, em ManagedBuffer::Acquire: pool de 4 chunks de
1 MiB em round-robin, com barreira ao encher um chunk e espera do sinal do
proximo. O caminho rapido do Acquire nao espera nada -- so avanca um offset.

Ou seja, tudo depende da barreira ordenar contra as copias em voo e do sinal
refletir conclusao real. Nesta placa as duas coisas sao suspeitas: todo boot
registra "Fence fallback timer expired on ring sdma0", que so aparece quando o
trabalho terminou e a interrupcao se perdeu.

Se a hipotese estiver certa, o dado errado nao e lixo nem saida antiga de
convolucao: e o CHUNK SEGUINTE da propria transferencia, que sobrescreveu o
staging antes da GPU ler. Mesma distribuicao, magnitude coerente, nenhum zero
-- exatamente o que medimos.

Este script faz duas coisas:

  TESTE 1  varia GPU_STAGING_BUFFER_SIZE. Se transferencias couberem num chunk
           so, nao ha reciclagem e nao deveria haver corrupcao. Rodado por fora,
           via env, ver staging_ab.sh.

  TESTE 2  quando detecta corrupcao, procura o conteudo errado DENTRO do proprio
           tensor de origem, em outros offsets. Se o dado em K for o que
           pertence a K +- N, e prova direta de reciclagem de staging.
"""
import os
import sys

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/staging_test.result")
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


def de_onde_veio(orig, volta, ruins):
    """A regiao errada contem dado de outro offset do MESMO tensor?

    Compara o trecho corrompido contra o proprio tensor de origem deslocado.
    Se casar num deslocamento D, o staging entregou o pedaco de outro chunk.
    """
    o = orig.flatten()
    v = volta.flatten()
    i0 = int(ruins[0])
    n = min(4096, int(ruins[-1]) - i0 + 1)
    if n < 64:
        return None
    trecho = v[i0:i0 + n]
    # varre deslocamentos em multiplos de 64 KiB ate +-8 MiB
    passo = 32768
    for d in range(-256, 257):
        if d == 0:
            continue
        j = i0 + d * passo
        if j < 0 or j + n > o.numel():
            continue
        if torch.equal(trecho, o[j:j + n]):
            return d * passo
    return None


def rodada(rotulo):
    torch.manual_seed(0)
    cpu, gpu = [], []
    for h, c in ALVOS:
        x = torch.randn(1, c, h, h, dtype=torch.float16)
        cpu.append((h, c, x))
        gpu.append(x.to(DEV))          # rajada, sem sync entre uploads
    torch.cuda.synchronize()

    achou = 0
    for (h, c, x), xg in zip(cpu, gpu):
        volta = xg.cpu()
        dif = (volta != x)
        nd = int(dif.sum())
        if nd == 0:
            continue
        achou += 1
        idx = torch.nonzero(dif.flatten()).flatten()
        desloc = de_onde_veio(x, volta, idx)
        say(f"  [{rotulo}] c={c} h={h}: {nd} elementos errados, "
            f"primeiro em {int(idx[0])}")
        if desloc is not None:
            say(f"      >>> o conteudo errado E o dado do offset {int(idx[0])+desloc} "
                f"do MESMO tensor (deslocamento {desloc:+d} = {desloc*2/1024:+.0f} KiB)")
            say(f"      >>> PROVA de reciclagem de staging")
        else:
            say(f"      nao casou com nenhum offset do proprio tensor "
                f"(±8 MiB, passo 64 KiB) -- o dado vem de outro lugar")
    return achou


rot = sys.argv[1] if len(sys.argv) > 1 else "?"
say("")
say("=" * 74)
say(f"rotulo={rot}  GPU_STAGING_BUFFER_SIZE={os.environ.get('GPU_STAGING_BUFFER_SIZE','(nao setada -> 1 MiB)')}")
say("=" * 74)
say("aquecendo...")
aquecer()
tot = 0
for i in range(1, 4):
    tot += rodada(f"{rot}/ciclo{i}")
say(f"  {rot}: {tot} tensores corrompidos em 3 ciclos x 6 tensores")
