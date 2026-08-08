#!/usr/bin/env python3
"""Quanto custam as cinco flags de serializacao que ficaram no ambiente?

Por que existe
--------------
/etc/profile.d/bc250-rocm.sh removeu cinco variaveis em 2026-08-05 e as
restaurou "temporariamente" para um bisect, no mesmo dia. Elas ficaram:

    GPU_MAX_HW_QUEUES=1  HIP_LAUNCH_BLOCKING=1  AMD_SERIALIZE_KERNEL=3
    AMD_SERIALIZE_COPY=3  AMD_DIRECT_DISPATCH=0

Foram restauradas ANTES de o patch de runlist existir, ou seja, compensavam um
defeito que hoje tem correcao de causa raiz. O proprio arquivo ja duvidava
delas: o dispatch com completion_signal=0x0 apareceu COM as tres ativas.

O que se mede
-------------
Perfil de kernel parecido com difusao: muitos kernels pequenos em sequencia,
que e exatamente o regime onde HIP_LAUNCH_BLOCKING pesa. Nao e um modelo real
de proposito -- um modelo traria variancia de alocacao e carregamento que
esconderia o efeito.

Cada rodada devolve tempo E um veredito de corretude. Uma flag que acelera e
traz o defeito de volta nao serve, entao o tempo sozinho nao decide nada.

Uso:
    bench_serializacao.py <nome-da-condicao>
"""
import json
import os
import sys
import time

import torch

NOME = sys.argv[1] if len(sys.argv) > 1 else "sem-nome"
PASSOS = int(os.environ.get("BENCH_PASSOS", "40"))
DEV = "cuda"


def bloco(x, w1, w2, k):
    """Um passo com a mistura de operacoes que uma UNet faz de verdade."""
    x = torch.nn.functional.conv2d(x, k, padding=1)
    x = torch.nn.functional.silu(x)
    b, c, h, wd = x.shape
    t = x.reshape(b, c, h * wd).transpose(1, 2)
    t = torch.softmax(t @ w1, dim=-1) @ w2
    t = t.transpose(1, 2).reshape(b, c, h, wd)
    return x + t


def main():
    torch.manual_seed(1234)
    x0 = torch.randn(1, 64, 64, 64, device=DEV)
    k = torch.randn(64, 64, 3, 3, device=DEV) * 0.02
    w1 = torch.randn(64, 64, device=DEV) * 0.05
    w2 = torch.randn(64, 64, device=DEV) * 0.05

    # aquecimento fora da medicao: primeira execucao paga compilacao de kernel
    x = x0.clone()
    for _ in range(5):
        x = bloco(x, w1, w2, k)
    torch.cuda.synchronize()

    x = x0.clone()
    t0 = time.perf_counter()
    for _ in range(PASSOS):
        x = bloco(x, w1, w2, k)
    torch.cuda.synchronize()
    dt = time.perf_counter() - t0

    # corretude: falha grosseira apenas. Numero diferente nao e problema aqui;
    # NaN, infinito ou saida chapada sao.
    f = x.float()
    finito = bool(torch.isfinite(f).all())
    desvio = float(f.std())
    chapado = desvio < 1e-6
    ok = finito and not chapado

    print(json.dumps({
        "condicao": NOME,
        "passos": PASSOS,
        "segundos": round(dt, 4),
        "ms_por_passo": round(dt * 1000 / PASSOS, 3),
        "finito": finito,
        "desvio": round(desvio, 6),
        "ok": ok,
        "flags": {v: os.environ.get(v, "<nao definida>") for v in (
            "HIP_LAUNCH_BLOCKING", "AMD_SERIALIZE_KERNEL", "AMD_SERIALIZE_COPY",
            "AMD_DIRECT_DISPATCH", "GPU_MAX_HW_QUEUES")},
    }))


if __name__ == "__main__":
    main()
