# MINIMAL REPRODUCER of the ordering bug on the BC-250.
# Warms up N kernels, then does a trivial matmul. No model, no ComfyUI.
# Usage: repro_min.py [N_WARMUP_KERNELS]
import sys, os, time, torch
import torch.nn.functional as F

N = int(sys.argv[1]) if len(sys.argv) > 1 else 130
C = "/home/gabriwar/bc250-grimoire/rocm-test/rm_crumb.txt"
_f = open(C, "a", buffering=1)
def say(s):
    _f.write(s+"\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)

t0 = time.time()
say(f"A_start alvo={N}_kernels")

# --- phase 1: warm up N assorted kernels ---
feitos = 0
a32 = torch.randn(256,256, device='cuda')
c   = torch.randn(1,8,32,32, device='cuda')
k   = torch.randn(8,8,3,3, device='cuda')
ops = [
    lambda: torch.relu(a32), lambda: torch.sigmoid(a32), lambda: torch.tanh(a32),
    lambda: torch.exp(a32), lambda: torch.sqrt(a32.abs()), lambda: torch.sin(a32),
    lambda: torch.cos(a32), lambda: torch.floor(a32), lambda: torch.ceil(a32),
    lambda: torch.frac(a32), lambda: a32.clamp(-1,1), lambda: torch.where(a32>0,a32,-a32),
    lambda: a32.sum(), lambda: a32.mean(), lambda: a32.max(), lambda: a32.min(),
    lambda: a32.argmax(), lambda: torch.count_nonzero(a32), lambda: torch.cumsum(a32.flatten(),0),
    lambda: torch.sort(a32.flatten()), lambda: torch.softmax(a32,-1),
    lambda: F.layer_norm(a32,(256,)), lambda: F.group_norm(c,4), lambda: F.silu(a32),
    lambda: F.gelu(a32), lambda: F.conv2d(c,k,padding=1), lambda: F.interpolate(c,scale_factor=2),
    lambda: F.pad(c,(1,1,1,1)), lambda: torch.cat([a32,a32],0), lambda: a32.t().contiguous(),
]
i = 0
while feitos < N:
    try:
        ops[i % len(ops)](); torch.cuda.synchronize(); feitos += 1
    except Exception as e:
        say(f"AQUEC_FALHOU_em_{feitos}_{type(e).__name__}"); break
    i += 1
say(f"B_aquecidos={feitos} t={time.time()-t0:.1f}s")

# --- phase 2: the test -- trivial matmul, all 4 transpositions ---
falhou = None
for dt in (torch.float16, torch.float32):
    tn = str(dt).split('.')[-1]
    for nome, fn in (("NN", lambda x,y: x@y), ("NT", lambda x,y: x@y.T),
                     ("TN", lambda x,y: x.T@y), ("TT", lambda x,y: x.T@y.T)):
        try:
            x = torch.randn(64,64, device='cuda', dtype=dt)
            y = torch.randn(64,64, device='cuda', dtype=dt)
            fn(x,y); torch.cuda.synchronize()
            say(f"OK   {tn}/{nome}")
            del x,y
        except Exception as e:
            say(f"FALHA {tn}/{nome}: {type(e).__name__}: {str(e)[:70]}")
            falhou = f"{tn}/{nome}"; break
    if falhou: break

say(f"Z_RESULTADO={'REPRODUZIU_em_'+falhou if falhou else 'NAO_REPRODUZIU'} t={time.time()-t0:.1f}s")
