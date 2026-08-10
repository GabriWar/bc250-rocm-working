#!/usr/bin/env python3
"""Runs the ComfyUI pipeline step by step and finds the exact operation that breaks.

Reason (2026-08-05): with the SDMA patch applied, bc250_conv_fix became
unnecessary, but WITHOUT bc250_warmup generation dies with hipErrorIllegalAddress
on a clean boot, as the first GPU load. So there is a defect left beyond the H2D
copy, and the 90-kernel warmup still compensates for it.

The warmup does nothing exotic -- 90 elementary operations (count_nonzero, sum,
mean, max, min, argmax, norm, matmul, conv) in fp32 and fp16. If running those
early avoids the crash, then what breaks is one of those first operations in a
still-cold context.

This script reproduces the pipeline without going through the ComfyUI server and
without the node graph, and intercepts every aten call with TorchDispatchMode.
Each operation is written to disk with fsync BEFORE executing, so if the machine
hangs the last line of the file is exactly the guilty one.

Running WITHOUT warmup is like the boot's FIRST GPU load:
    BC250_WARMUP=0 trace_pipeline.py

Check beforehand that `dmesg | grep -c "page fault"` is zero.
"""
import os
import sys
import time

import torch
from torch.utils._python_dispatch import TorchDispatchMode

OUT = os.path.expanduser("~/bc250-grimoire/trace_pipeline.result")
_f = open(OUT, "w", buffering=1)
_n = 0
_fase = "inicio"


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())


def forma(a):
    if isinstance(a, torch.Tensor):
        return f"{tuple(a.shape)}:{str(a.dtype)[6:]}:{a.device.type}"
    return None


class Tracer(TorchDispatchMode):
    def __torch_dispatch__(self, func, types, args=(), kwargs=None):
        global _n
        _n += 1
        ins = [s for s in (forma(a) for a in args) if s]
        say(f"{_n:6d} [{_fase:12s}] ANTES  {str(func):44s} {' '.join(ins[:3])}")
        out = func(*args, **(kwargs or {}))
        if isinstance(out, torch.Tensor) and out.is_cuda:
            torch.cuda.synchronize()
            mau = ""
            if out.numel() and out.dtype.is_floating_point:
                if not bool(torch.isfinite(out).all()):
                    mau = "   <<< NaN/Inf"
            say(f"{_n:6d} [{_fase:12s}] DEPOIS {str(func):44s} -> {tuple(out.shape)}{mau}")
        return out


say(f"warmup={os.environ.get('BC250_WARMUP','1')}  "
    f"skip_sdma0={open('/sys/module/amdgpu/parameters/bc250_skip_sdma0').read().strip()}")
say("")

sys.path.insert(0, "/home/gabriwar/ComfyUI")
import comfy.sd            # noqa: E402
import comfy.sample        # noqa: E402
import comfy.samplers      # noqa: E402

CK = "/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"

_fase = "load"
say(f"=== {_fase}: carregando checkpoint (ainda sem tracer) ===")
t = time.time()
modelo, clip, vae = comfy.sd.load_checkpoint_guess_config(
    CK, output_vae=True, output_clip=True)[:3]
say(f"    carregado em {time.time()-t:.1f}s")
say("")

torch.manual_seed(111)

with Tracer():
    _fase = "clip"
    say(f"=== {_fase}: encode do prompt ===")
    pos = clip.encode_from_tokens_scheduled(clip.tokenize("a photo of a cat"))
    neg = clip.encode_from_tokens_scheduled(clip.tokenize(""))

    _fase = "latente"
    say(f"=== {_fase}: latente vazio ===")
    lat = {"samples": torch.zeros([1, 4, 64, 64], device="cpu")}

    _fase = "sampler"
    say(f"=== {_fase}: 4 passos (suficiente para pegar o crash) ===")
    ruido = comfy.sample.prepare_noise(lat["samples"], 111)
    saida = comfy.sample.sample(
        modelo, ruido, 4, 8.0, "euler", "normal", pos, neg,
        lat["samples"], denoise=1.0)

    _fase = "vae"
    say(f"=== {_fase}: decode ===")
    img = vae.decode(saida)

say("")
say(f"COMPLETO: {tuple(img.shape)}  operacoes={_n}")
say(f"finito: {bool(torch.isfinite(img).all())}")
say("FIM")
