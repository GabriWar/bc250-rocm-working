# Hipotese: e a TRANSICAO entre fases pesadas que quebra.
# Teste: sincronizar + esvaziar o cache do alocador entre cada fase.
import sys, os, torch
sys.path.insert(0,"/home/gabriwar/ComfyUI")
C="/home/gabriwar/bc250-grimoire/rocm-test/fl_crumb.txt"
_f=open(C,"a",buffering=1)
def say(s):
    _f.write(s+"\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)

def barreira(tag):
    torch.cuda.synchronize()
    torch.cuda.empty_cache()
    torch.cuda.synchronize()
    say(f"~~ barreira {tag}: vram={torch.cuda.memory_allocated()//1048576}MB "
        f"reservada={torch.cuda.memory_reserved()//1048576}MB")

say("A_start")
import comfy.sd, comfy.model_management as mm, folder_paths, nodes
ck="/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
model, clip, vae = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=True,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[:3]
say("B_checkpoint_ok"); barreira("pos-load")

vm = vae.first_stage_model; vm.half().to('cuda')
say("C_vae_gpu"); barreira("pos-vae-gpu")

x = torch.zeros(1,4,64,64, device='cuda', dtype=torch.float16)
with torch.no_grad(): out = vm.decode(x)
torch.cuda.synchronize(); say(f"D_DECODE_OK_{tuple(out.shape)}")
del x, out
barreira("pos-decode")

pos = nodes.CLIPTextEncode().encode(clip, "a red cube on a table")[0]
say("E_CLIP1_OK"); barreira("pos-clip1")
neg = nodes.CLIPTextEncode().encode(clip, "blurry")[0]
say("F_CLIP2_OK"); barreira("pos-clip2")

mm.load_models_gpu([model]); say("G_unet_gpu"); barreira("pos-unet")

lat = nodes.EmptyLatentImage().generate(512,512,1)[0]
o = nodes.KSampler().sample(model,42,4,7.0,"euler","normal",pos,neg,lat,denoise=1.0)[0]
torch.cuda.synchronize(); say("H_SAMPLER_OK"); barreira("pos-sampler")

with torch.no_grad(): img = vm.decode(o["samples"].to('cuda').half())
torch.cuda.synchronize(); say(f"I_DECODE_FINAL_OK_{tuple(img.shape)}")
say("Z_TUDO_PASSOU")
