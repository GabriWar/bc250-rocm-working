# Warms up the type x transposition matrix BEFORE anything else, then repeats the
# test that failed: VAE decode -> CLIP encode.
import sys, os, torch
sys.path.insert(0,"/home/gabriwar/ComfyUI")
C="/home/gabriwar/bc250-grimoire/rocm-test/bf_crumb.txt"
_f=open(C,"a",buffering=1)
def say(s):
    _f.write(s+"\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)

say("A_start")
# --- BLAS warmup: 12 combinations ---
n=0
for dt in (torch.float16, torch.bfloat16, torch.float32):
    for nome, fn in (("NN", lambda a,b: a@b), ("NT", lambda a,b: a@b.T),
                     ("TN", lambda a,b: a.T@b), ("TT", lambda a,b: a.T@b.T)):
        try:
            a=torch.randn(64,64,device='cuda',dtype=dt); b=torch.randn(64,64,device='cuda',dtype=dt)
            fn(a,b); torch.cuda.synchronize(); n+=1; del a,b
        except Exception as e: say(f"WARM_{dt}_{nome}_FALHOU_{type(e).__name__}")
say(f"B_warmup_blas_{n}_combos")

import comfy.sd, comfy.model_management as mm, folder_paths, nodes
ck="/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
model, clip, vae = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=True,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[:3]
say("C_checkpoint_ok")
vm = vae.first_stage_model; vm.half().to('cuda')
say("D_vae_na_gpu")

x = torch.zeros(1,4,64,64, device='cuda', dtype=torch.float16)
with torch.no_grad(): out = vm.decode(x)
torch.cuda.synchronize(); say(f"E_DECODE_OK_{tuple(out.shape)}"); del x,out

pos = nodes.CLIPTextEncode().encode(clip, "a red cube on a table")[0]
say("F_CLIP_OK")
mm.load_models_gpu([model]); say("G_unet_gpu_ok")
lat = nodes.EmptyLatentImage().generate(512,512,1)[0]
neg = nodes.CLIPTextEncode().encode(clip, "blurry")[0]
o = nodes.KSampler().sample(model,42,4,7.0,"euler","normal",pos,neg,lat,denoise=1.0)[0]
torch.cuda.synchronize(); say("H_SAMPLER_OK")
with torch.no_grad(): img = vm.decode(o["samples"].to('cuda').half())
torch.cuda.synchronize(); say(f"I_DECODE_FINAL_OK_{tuple(img.shape)}")
say("Z_TUDO_PASSOU")
