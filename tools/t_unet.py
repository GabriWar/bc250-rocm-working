# Forward do UNet direto, com hook em cada submodulo.
# O ultimo breadcrumb diz exatamente qual modulo estava executando no fault.
import sys, os, torch
sys.path.insert(0, "/home/gabriwar/ComfyUI")
CRUMB = "/home/gabriwar/bc250-grimoire/rocm-test/u_crumb.txt"
_f = open(CRUMB, "a", buffering=1)
def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())

say("A_start")
import comfy.sd, comfy.model_management as mm, folder_paths
say("A_import_ok")

ck = "/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
say("B_load_start")
model = comfy.sd.load_checkpoint_guess_config(ck, output_vae=False, output_clip=False,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[0]
say("B_load_ok")

say("C_gpu_start"); mm.load_models_gpu([model]); say("C_gpu_ok")

unet = model.model.diffusion_model
dev  = model.load_device
dt   = model.model.get_dtype()
say(f"C_dtype_{dt}_dev_{dev}")

# hook em cada submodulo folha e em cada bloco de topo
n = 0
for name, mod in unet.named_modules():
    if name == "": continue
    def mk(nm, cls):
        def h(m, i): say(f"M::{nm}::{cls}")
        return h
    mod.register_forward_pre_hook(mk(name, type(mod).__name__))
    n += 1
say(f"D_hooks_{n}")

x = torch.randn(1, 4, 32, 32, device=dev, dtype=dt)
t = torch.tensor([999.0], device=dev, dtype=dt)
c = torch.randn(1, 77, 768, device=dev, dtype=dt)
say("E_tensors_ok")

say("F_forward_start")
with torch.no_grad():
    out = unet(x, t, context=c)
torch.cuda.synchronize()
say(f"F_forward_OK_{tuple(out.shape)}")
say("Z_ALL_OK")
