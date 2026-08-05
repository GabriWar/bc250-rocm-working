# O VAE decode funciona ANTES do sampler e falha DEPOIS?
# Se sim, isola o gatilho no que o sampler faz.
import sys, os, torch
sys.path.insert(0,"/home/gabriwar/ComfyUI")
C="/home/gabriwar/bc250-grimoire/rocm-test/ad_crumb.txt"
_f=open(C,"a",buffering=1)
def say(s):
    _f.write(s+"\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)

def decode(m, tag):
    try:
        x = torch.zeros(1,4,64,64, device='cuda', dtype=torch.float16)
        with torch.no_grad(): out = m.decode(x)
        torch.cuda.synchronize()
        say(f"DECODE_{tag}_OK_{tuple(out.shape)}")
        del x, out; return True
    except Exception as e:
        say(f"DECODE_{tag}_FALHOU_{type(e).__name__}_{str(e)[:110]}")
        return False

say("A_start")
import comfy.sd, comfy.model_management as mm, folder_paths, nodes
ck="/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
model, clip, vae = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=True,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[:3]
say("B_checkpoint_ok")

vm = vae.first_stage_model
vm.half().to('cuda')
say("C_vae_na_gpu")

# 1) ANTES de qualquer coisa pesada
if not decode(vm, "ANTES"): say("Z_FIM"); sys.exit(2)

# 2) CLIP encode
pos = nodes.CLIPTextEncode().encode(clip, "a red cube on a table")[0]
neg = nodes.CLIPTextEncode().encode(clip, "blurry")[0]
say("D_clip_encode_ok")
if not decode(vm, "POS_CLIP"): say("Z_FIM"); sys.exit(2)

# 3) UNet na GPU
mm.load_models_gpu([model])
say("E_unet_gpu_ok")
if not decode(vm, "POS_UNET_LOAD"): say("Z_FIM"); sys.exit(2)

# 4) sampler com N passos crescentes
lat = nodes.EmptyLatentImage().generate(512,512,1)[0]
ks = nodes.KSampler()
for n in (1, 4, 12, 24):
    say(f"F_sampler_{n}_start")
    out = ks.sample(model, 42, n, 7.0, "euler", "normal", pos, neg, lat, denoise=1.0)[0]
    torch.cuda.synchronize()
    say(f"F_sampler_{n}_ok")
    if not decode(vm, f"POS_SAMPLER_{n}"): say("Z_FIM"); sys.exit(2)

say("Z_TUDO_PASSOU")
