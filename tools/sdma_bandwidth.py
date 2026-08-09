import torch, time, os, sys
N=64*1024*1024   # 128 MiB em fp16
h=torch.randn(N, dtype=torch.float16)
d=h.to('cuda'); torch.cuda.synchronize()          # aquece
t=[]
for _ in range(5):
    t0=time.perf_counter(); d=h.to('cuda'); torch.cuda.synchronize(); t.append(time.perf_counter()-t0)
mb=(N*2)/2**20
best=min(t)
print(f"  SDMA={os.environ.get('HSA_ENABLE_SDMA','?')}  H2D {mb:.0f} MiB: melhor {best*1000:.1f}ms = {mb/best:.0f} MiB/s   (5 rodadas)")
