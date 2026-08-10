#!/usr/bin/env python3
"""Traces EVERY aten operation of the VAE decode up to the one that hangs.

Uses TorchDispatchMode, which intercepts every call at the aten level. Each
operation is written to disk with fsync BEFORE executing, so if the machine hangs
the last line of the file is exactly the guilty operation.

It also validates numerically on the output when that is cheap, to catch silent
corruption beyond hangs.

Output: ~/bc250-grimoire/trace_vae.result
Usage:  trace_vae.py [gpu|cpu]
"""
import os
import sys
import torch
from torch.utils._python_dispatch import TorchDispatchMode

OUT = os.path.expanduser("~/bc250-grimoire/trace_vae_fp16.result")
f = open(OUT, "w", buffering=1)
_n = 0


def say(s):
    f.write(s + "\n")
    f.flush()
    os.fsync(f.fileno())


def shape_of(a):
    if isinstance(a, torch.Tensor):
        return f"{tuple(a.shape)}:{str(a.dtype)[6:]}"
    if isinstance(a, (list, tuple)) and a and isinstance(a[0], torch.Tensor):
        return f"[{len(a)}x{tuple(a[0].shape)}]"
    return None


class Tracer(TorchDispatchMode):
    def __torch_dispatch__(self, func, types, args=(), kwargs=None):
        global _n
        _n += 1
        nome = str(func)
        ins = [s for s in (shape_of(a) for a in args) if s]
        say(f"{_n:6d} ANTES  {nome:44s} {' '.join(ins[:3])}")
        out = func(*args, **(kwargs or {}))
        # synchronize so that a hang shows up HERE and not in some later op
        if isinstance(out, torch.Tensor) and out.is_cuda:
            torch.cuda.synchronize()
            bad = ""
            if out.numel() and out.dtype.is_floating_point:
                fin = torch.isfinite(out)
                if not bool(fin.all()):
                    bad = "  <<< NaN/Inf NA SAIDA"
            say(f"{_n:6d} DEPOIS {nome:44s} -> {tuple(out.shape)}{bad}")
        return out


modo = sys.argv[1] if len(sys.argv) > 1 else "gpu"
dev = "cuda" if modo == "gpu" else "cpu"

sys.path.insert(0, "/home/gabriwar/ComfyUI")
import comfy.sd  # noqa: E402

say(f"modo={modo} device={dev}")
ck = "/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
say("carregando checkpoint...")
out = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=False)
vae = out[2]
say(f"vae carregado: {type(vae).__name__}")

torch.manual_seed(0)
lat = torch.randn(1, 4, 64, 64, dtype=torch.float16)
say(f"latente {tuple(lat.shape)} -> decode em {dev}")
say("")

vae.first_stage_model.to(dev)
vae.first_stage_model.to(torch.float16)   # force fp16: bf16 is known to be broken here
x = lat.to(dev).to(next(vae.first_stage_model.parameters()).dtype)

with Tracer():
    img = vae.first_stage_model.decode(x)

say("")
say(f"DECODE COMPLETO: {tuple(img.shape)}  ops={_n}")
say(f"finito: {bool(torch.isfinite(img).all())}")
