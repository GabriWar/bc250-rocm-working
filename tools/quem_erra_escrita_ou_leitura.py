#!/usr/bin/env python3
"""A GPU erra ao ESCREVER ou ao LER?

O que ja esta medido
--------------------
Dois blocos de hipMalloc vivos, BOs distintos em /proc/pid/maps, que a GPU trata
como a mesma memoria. Reproduz em ~83% das execucoes. Sobrevive a invalidacao
forcada de TLB e a reescrita. Nao muda com vm_update_mode 3 (tabelas escritas
pela CPU) nem 0 (escritas por SDMA): 10/12 contra 5/6.

O buraco no que eu media
------------------------
Ate agora foram sempre pares homogeneos:

    CPU escreve  -> CPU le    correto
    GPU escreve  -> GPU le    errado

Isso nao separa escrita de leitura. Falta o cruzado, e ele decide:

    GPU escreve  -> CPU le    se a CPU ver o valor CERTO no bloco, a escrita
                              da GPU foi para o lugar fisico certo e quem erra
                              e o caminho de LEITURA da GPU
                              se a CPU ver o valor ERRADO, a escrita da GPU foi
                              para o lugar errado

A leitura pela CPU e feita direto no ponteiro mapeado (o mesmo VA), sem passar
por hipMemcpy -- hipMemcpy usa SDMA/blit e portanto le pela GPU, que e
justamente o caminho sob suspeita.
"""
import ctypes
import os
import sys

import numpy as np

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/escrita_ou_leitura.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


D2H = 2
hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemset.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_size_t]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou com codigo {r}")


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say("=" * 70)
say(f"boot={boot} pid={os.getpid()} vm_update_mode="
    f"{open('/sys/module/amdgpu/parameters/vm_update_mode').read().strip()}")
aquecer()

for _ in range(3):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append(p)
    for p in tmp:
        ck(hip.hipFree(p), "hipFree")

blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada} {t}B", p, t))

# a GPU escreve um valor unico em cada bloco
for k, (rot, p, t) in enumerate(blocos):
    ck(hip.hipMemset(p, ctypes.c_int(k + 1), ctypes.c_size_t(t)), "hipMemset")
ck(hip.hipDeviceSynchronize(), "sync")

achou = 0
for k, (rot, p, t) in enumerate(blocos):
    esperado = k + 1

    # leitura 1: pela CPU, direto no ponteiro mapeado
    cpu = np.frombuffer((ctypes.c_ubyte * t).from_address(p.value), dtype=np.uint8)
    d_cpu = cpu != esperado
    n_cpu = int(d_cpu.sum())

    # leitura 2: por hipMemcpy, que usa SDMA/blit e portanto le pela GPU
    buf = (ctypes.c_ubyte * t)()
    ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(t), D2H), "hipMemcpy")
    gpu = np.frombuffer(buf, dtype=np.uint8)
    d_gpu = gpu != esperado
    n_gpu = int(d_gpu.sum())

    if not (n_cpu or n_gpu):
        continue
    achou += 1

    def quem(arr, d):
        i0 = int(np.argmax(d))
        o = int(arr[i0]) - 1
        return (blocos[o][0] if 0 <= o < len(blocos) else f"byte {int(arr[i0])}"), i0

    say(f"  {rot} @0x{p.value:x} esperado={esperado}")
    if n_cpu:
        q, i0 = quem(cpu, d_cpu)
        say(f"    CPU  le errado: {n_cpu} bytes de \"{q}\" a partir de {i0}")
    else:
        say(f"    CPU  le CERTO")
    if n_gpu:
        q, i0 = quem(gpu, d_gpu)
        say(f"    GPU  le errado: {n_gpu} bytes de \"{q}\" a partir de {i0}")
    else:
        say(f"    GPU  le CERTO")

    if n_gpu and not n_cpu:
        say("    => a escrita da GPU foi para o lugar CERTO; quem erra e a LEITURA")
    elif n_cpu and n_gpu:
        say("    => a escrita da GPU foi para o lugar ERRADO")
    elif n_cpu and not n_gpu:
        say("    => so a CPU ve errado -- inesperado, checar coerencia de cache")

if not achou:
    say("  execucao limpa")
for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
