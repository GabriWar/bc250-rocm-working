# BC-250 (gfx1013): neutraliza soft_empty_cache() do ComfyUI.
#
# MEDIDO 2026-08-05, decode do VAE validado contra a CPU (err_rel, nao
# "e finito"):
#
#   antes de tudo                     err=1.257e-02  OK
#   com o UNet residente na GPU       err=1.257e-02  OK
#   descarregar UNet + empty_cache    err=6.075e-01  CORROMPIDO
#   decode seguinte                   err=1.257e-02  OK
#
# Exatamente UMA operacao sai envenenada depois de empty_cache(), e volta ao
# normal na proxima. O ComfyUI chama soft_empty_cache() em 5 pontos do
# model_management.py, todos ao descarregar modelo -- inclusive entre o
# sampler e o VAE. Dai a imagem de 30 KB com desvio 10 em vez de 480 KB.
#
# Bate com outro achado do mesmo dia: torch.cuda.empty_cache() entre conv2d
# escalava para HSA_STATUS_ERROR_ILLEGAL_INSTRUCTION (code 0x2a).
#
# O decode em si e correto e estavel: 5/5 rodadas com err=1.257e-02 e 0.60s
# quente, contra ~15s na CPU.
#
# CUSTO: a memoria nao volta para o driver entre trocas de modelo. Numa placa
# com 4 GB de UMA isso pode levar a OOM em workflows que trocam muito de
# modelo. Se isso acontecer, desligue com BC250_NO_EMPTY_CACHE=0.

import os

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}

if os.environ.get("BC250_NO_EMPTY_CACHE", "1") != "0":
    try:
        import comfy.model_management as mm

        _orig = mm.soft_empty_cache

        def _noop(force=False):
            # Mantem o synchronize (barato e as vezes necessario), mas nao
            # devolve memoria ao driver, que e o que corrompe a operacao
            # seguinte nesta placa.
            try:
                import torch
                if torch.cuda.is_available():
                    torch.cuda.synchronize()
            except Exception:
                pass

        mm.soft_empty_cache = _noop
        print("[bc250-no-empty-cache] soft_empty_cache neutralizado "
              "(empty_cache corrompe a operacao seguinte)", flush=True)
    except Exception as e:
        print(f"[bc250-no-empty-cache] FALHOU: {type(e).__name__}: {e}",
              flush=True)
