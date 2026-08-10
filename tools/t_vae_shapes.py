# Derives the VAE decode's GEMM shapes WITHOUT touching the GPU.
# Runs the decode on CPU with a hook on every matrix op.
import sys, os, json, torch
sys.argv = [sys.argv[0], "--cpu"]
sys.path.insert(0,"/home/gabriwar/ComfyUI")
OUT="/home/gabriwar/bc250-grimoire/rocm-test"
shapes = []

class Rec(torch.overrides.TorchFunctionMode):
    def __torch_function__(self, func, types, args=(), kwargs=None):
        kwargs = kwargs or {}
        r = func(*args, **kwargs)
        n = getattr(func, "__name__", str(func))
        if n in ("matmul","bmm","mm","baddbmm","linear","addmm","einsum","scaled_dot_product_attention"):
            try:
                a, b = args[0], args[1]
                if hasattr(a,"shape") and hasattr(b,"shape"):
                    shapes.append({"op":n,"a":list(a.shape),"b":list(b.shape),
                                   "out":list(r.shape) if hasattr(r,"shape") else None,
                                   "dtype":str(a.dtype).split('.')[-1]})
            except Exception:
                pass
        return r

import comfy.sd, folder_paths
ck="/home/gabriwar/ComfyUI/models/checkpoints/cyberrealistic_final.safetensors"
print("carregando VAE...", flush=True)
vae = comfy.sd.load_checkpoint_guess_config(ck, output_vae=True, output_clip=False,
        embedding_directory=folder_paths.get_folder_paths("embeddings"))[2]
print("VAE carregado", flush=True)

res = {}
for px in (256, 512):
    lat = px // 8
    shapes.clear()
    m = vae.first_stage_model
    m.float()  # fp32: identical shapes, CPU much faster
    dt = torch.float32
    x = torch.zeros(1, 4, lat, lat, dtype=dt)
    with torch.no_grad(), Rec():
        try:
            m.to('cpu')
            out = m.decode(x)
            print(f"{px}px decode OK -> {tuple(out.shape)}", flush=True)
        except Exception as e:
            print(f"{px}px decode falhou: {type(e).__name__}: {e}", flush=True)
    res[px] = list(shapes)
    print(f"{px}px: {len(shapes)} ops de matriz", flush=True)

json.dump(res, open(f"{OUT}/vae_shapes.json","w"), indent=1)
print("salvo vae_shapes.json", flush=True)
