# Reproduces the VAE's GEMM through torch -- the same path SD takes.
# NT = A[M,K] @ B[N,K].T
import sys, os, time, torch
C="/home/gabriwar/bc250-grimoire/rocm-test/gp_crumb.txt"
def say(s):
    print(s, flush=True)
    with open(C,"a") as f: f.write(s+"\n"); f.flush(); os.fsync(f.fileno())

M,N,K = (int(x) for x in sys.argv[1:4])
say(f"ALVO NT M={M} N={N} K={K} f16")
a = torch.randn(M, K, device='cuda', dtype=torch.float16)
b = torch.randn(N, K, device='cuda', dtype=torch.float16)
say("alocado")
try:
    c = a @ b.T
    torch.cuda.synchronize()
    say(f"OK saida={tuple(c.shape)}")
    # measurement
    for _ in range(3): c = a @ b.T
    torch.cuda.synchronize()
    t0=time.time()
    n=10
    for _ in range(n): c = a @ b.T
    torch.cuda.synchronize()
    dt=(time.time()-t0)/n
    say(f"TEMPO {dt*1000:.3f} ms   {2*M*N*K/dt/1e12:.3f} TFLOP/s")
except Exception as e:
    say(f"FALHOU {type(e).__name__}: {str(e)[:200]}")
say("FIM")
