# Varre as variaveis candidatas: memoria alocada e volume de trabalho.
import sys, os, time, torch
import torch.nn.functional as F
C="/home/gabriwar/bc250-grimoire/rocm-test/rs_crumb.txt"
_f=open(C,"a",buffering=1)
def say(s):
    _f.write(s+"\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)

MB   = int(sys.argv[1])   # MB residentes antes do teste
TAM  = int(sys.argv[2])   # lado das matrizes do aquecimento
ITER = int(sys.argv[3])   # quantas iteracoes de trabalho

say(f"A_start mem={MB}MB tam={TAM} iter={ITER}")
t0=time.time()

# ocupa memoria
blobs=[]
try:
    for _ in range(max(0, MB//64)):
        blobs.append(torch.empty(64*1024*1024//2, device='cuda', dtype=torch.float16))
    torch.cuda.synchronize()
except Exception as e:
    say(f"ALLOC_FALHOU_{type(e).__name__}")
say(f"B_mem alocada={torch.cuda.memory_allocated()//1048576}MB")

# trabalho pesado
a=torch.randn(TAM,TAM,device='cuda',dtype=torch.float16)
b=torch.randn(TAM,TAM,device='cuda',dtype=torch.float16)
try:
    for _ in range(ITER):
        c=a@b; c=torch.softmax(c,-1); c=F.silu(c)
    torch.cuda.synchronize()
    say(f"C_trabalho ok t={time.time()-t0:.1f}s")
except Exception as e:
    say(f"C_trabalho_FALHOU_{type(e).__name__}"); say("Z_FIM"); sys.exit(2)
del a,b,c

# o teste
falhou=None
for dt in (torch.float16, torch.float32):
    tn=str(dt).split('.')[-1]
    for nome,fn in (("NN",lambda x,y:x@y),("NT",lambda x,y:x@y.T),
                    ("TN",lambda x,y:x.T@y),("TT",lambda x,y:x.T@y.T)):
        try:
            x=torch.randn(64,64,device='cuda',dtype=dt); y=torch.randn(64,64,device='cuda',dtype=dt)
            fn(x,y); torch.cuda.synchronize(); del x,y
        except Exception as e:
            say(f"FALHA {tn}/{nome}: {type(e).__name__}"); falhou=f"{tn}/{nome}"; break
    if falhou: break
say(f"Z_RESULTADO={'REPRODUZIU_'+falhou if falhou else 'NAO'} t={time.time()-t0:.1f}s")
