# Bisection of the 512px VAE decode on the GPU, with a per-submodule hook.
# NO ROCBLAS_LAYER -- the heavy logging is what hung the machine, not the decode.
import sys, os, torch
sys.argv = [sys.argv[0]]
sys.path.insert(0,"/home/gabriwar/ComfyUI")
C="/home/gabriwar/bc250-grimoire/rocm-test/vb_crumb.txt"
_f=open(C,"a",buffering=1)
def say(s):
    _f.write(s+"\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)

say("A_start")
import comfy.sd, folder_paths
ck="/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
vae = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=False,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[2]
say("B_vae_carregado")

m = vae.first_stage_model
m.half().to('cuda')                      # fp16 on the GPU, the way --fp16-vae does it
say("C_vae_na_gpu_fp16")

n = 0
for name, mod in m.named_modules():
    if name == "": continue
    def mk(nm, cls):
        def h(mm, i):
            shp = tuple(i[0].shape) if i and hasattr(i[0],'shape') else '?'
            say(f"M::{nm}::{cls}::{shp}")
        return h
    mod.register_forward_pre_hook(mk(name, type(mod).__name__)); n += 1
say(f"D_hooks_{n}")

for px in (256, 512):
    lat = px // 8
    say(f"E_{px}px_start")
    x = torch.zeros(1, 4, lat, lat, device='cuda', dtype=torch.float16)
    try:
        with torch.no_grad():
            out = m.decode(x)
        torch.cuda.synchronize()
        say(f"E_{px}px_OK_{tuple(out.shape)}")
    except Exception as e:
        say(f"E_{px}px_FALHOU_{type(e).__name__}_{str(e)[:120]}")
        break
say("Z_FIM")
