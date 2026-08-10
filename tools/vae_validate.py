#!/usr/bin/env python3
"""Validates the VAE decode on the GPU AGAINST THE CPU, not just against 'is finite'.

Mistake made on 2026-08-05: I used `torch.isfinite(img).all()` as the success
criterion. Nearly uniform garbage is finite too. The decode "passed" both in
isolation and in ComfyUI and produced an image with standard deviation 10
(expected 25+) and 1,989 unique colors, in a 30 KB PNG against the normal 480 KB.

Here: same latent on the GPU and on the CPU, direct numeric comparison.

Output: ~/bc250-grimoire/vae_validate.result
"""
import os
import sys
import time
import torch

OUT = os.path.expanduser("~/bc250-grimoire/vae_validate.result")
f = open(OUT, "w", buffering=1)


def say(s):
    f.write(s + "\n")
    f.flush()
    os.fsync(f.fileno())
    print(s, flush=True)


sys.path.insert(0, "/home/gabriwar/ComfyUI/custom_nodes")
if os.environ.get("BC250_CONV_FIX", "1") != "0":
    import bc250_conv_fix  # noqa: F401
sys.path.insert(0, "/home/gabriwar/ComfyUI")
import comfy.sd  # noqa: E402

ck = "/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
o = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=False)
vae = o[2]
m = vae.first_stage_model

torch.manual_seed(0)
lat = torch.randn(1, 4, 64, 64, dtype=torch.float32)

say("referencia na CPU (fp32)")
m.to("cpu").to(torch.float32)
t = time.time()
ref = m.decode(lat)
say(f"  cpu: {tuple(ref.shape)}  {time.time()-t:.1f}s  "
    f"min={ref.min():.3f} max={ref.max():.3f} std={ref.std():.4f}")
say("")

say("GPU fp16, 3 rodadas, comparadas com a CPU")
m.to("cuda").to(torch.float16)
x = lat.to("cuda").to(torch.float16)
for i in range(3):
    t = time.time()
    g = m.decode(x)
    torch.cuda.synchronize()
    dt = time.time() - t
    gc = g.float().cpu()
    err = (gc - ref).abs().max().item() / max(ref.abs().max().item(), 1e-6)
    say(f"  rodada {i+1}: {dt:5.2f}s  err_rel={err:.3e}  "
        f"std={gc.std():.4f} (ref {ref.std():.4f})  "
        f"{'OK' if err < 5e-2 else 'CORROMPIDO'}")

say("")
say("criterio: err_rel < 5e-2. 'finito' NAO e criterio.")
