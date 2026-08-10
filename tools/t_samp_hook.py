# KSampler cfg=1.0 steps=1 WITH per-module hooks.
# If the last crumb is M::something -> fault inside the UNet.
# If it is an S_* marker -> fault outside the UNet (euler / cond batching).
import sys, os, torch
sys.path.insert(0, "/home/gabriwar/ComfyUI")
CRUMB = "/home/gabriwar/bc250-grimoire/rocm-test/sh_crumb.txt"
_f = open(CRUMB, "a", buffering=1)
def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())

say("A_start")
import comfy.sd, comfy.model_management as mm, folder_paths, nodes
say("A_import_ok")

ck = "/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
say("B_load_start")
model, clip, vae = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=True,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[:3]
say("B_load_ok")

say("C_encode_start")
pos = nodes.CLIPTextEncode().encode(clip, "a red cube on a table")[0]
neg = nodes.CLIPTextEncode().encode(clip, "blurry")[0]
say("C_encode_ok")

lat = nodes.EmptyLatentImage().generate(256, 256, 1)[0]
say("D_latent_ok")

say("E_hook_start")
unet = model.model.diffusion_model
n = 0
for name, mod in unet.named_modules():
    if name == "": continue
    def mk(nm, cls):
        def h(m, i): say(f"M::{nm}::{cls}")
        return h
    mod.register_forward_pre_hook(mk(name, type(mod).__name__)); n += 1
say(f"E_hooks_{n}")

say("S_sample_start")
out = nodes.KSampler().sample(model, 42, 1, 1.0, "euler", "normal", pos, neg, lat, denoise=1.0)[0]
torch.cuda.synchronize()
say("S_sample_OK")
say("Z_ALL_OK")
