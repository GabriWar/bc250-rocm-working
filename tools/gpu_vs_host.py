#!/usr/bin/env python3
"""O erro esta no CALCULO ou na COPIA de volta para o host?

Ate aqui: c=320 h=112 erra 43% dos elementos, espalhados por todos os 320
canais, em faixas contiguas dentro de cada canal. Memoria pura passa 768 MB
sem uma palavra corrompida. Kernel e ISA corretos.

Faixas contiguas alinhadas a blocos cheiram a escrita que nao ficou visivel,
nao a aritmetica errada. E este env desliga o SDMA (HSA_ENABLE_SDMA=0), entao
a copia device->host segue um caminho alternativo.

Aqui a mesma saida e comparada de duas formas:
  A) inteiramente NA GPU, contra referencia im2col+GEMM (que mede 0/26)
  B) copiada para o host e comparada com a CPU

A pequeno e B grande -> o calculo esta certo e a copia corrompe
A e B grandes iguais -> o calculo esta errado mesmo
"""
import os, torch, torch.nn.functional as F
d="cuda"; torch.manual_seed(0)
out=open(os.path.expanduser("~/bc250-grimoire/gpu_vs_host.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

def ref_na_gpu(xg, wg):
    """conv por im2col+GEMM, o caminho que mede 0/26. Fica tudo na GPU."""
    n,cin,hi,wi = xg.shape; cout = wg.shape[0]
    cols = F.unfold(xg, (3,3), padding=1)
    o = (wg.reshape(cout,-1).float() @ cols.float())
    return o.reshape(n,cout,hi,wi)

shapes=[(h,c) for h in range(32,136,8) for c in (64,320)]
say("aquecendo...")
for rep in range(2):
    for h,c in shapes:
        x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
        _=F.conv2d(x.to(d),w.to(d),padding=1)
torch.cuda.synchronize()
say("")
say("  shape          A: erro na GPU     B: erro pos-copia   veredito")

for h,c in [(112,320),(104,320),(64,64),(128,320)]:
    x=torch.randn(1,c,h,h,dtype=torch.float16); w=torch.randn(c,c,3,3,dtype=torch.float16)
    xg,wg=x.to(d),w.to(d)
    g=F.conv2d(xg,wg,padding=1); torch.cuda.synchronize()

    # A: tudo na GPU
    rg=ref_na_gpu(xg,wg)
    ea=((g.float()-rg).abs().max()/rg.abs().max().clamp(min=1e-6)).item()

    # B: copia para o host e compara com a CPU
    gc=g.float().cpu()
    rc=F.conv2d(x.float(),w.float(),padding=1)
    eb=(gc-rc).abs().max().item()/max(rc.abs().max().item(),1e-6)

    # C: segunda copia do MESMO buffer -- as duas copias concordam entre si?
    gc2=g.float().cpu()
    ec=(gc-gc2).abs().max().item()

    v = "COPIA" if (ea<1e-2 and eb>1e-2) else ("CALCULO" if eb>1e-2 else "ok")
    say(f"  c={c:3d} h={h:3d}   {ea:.3e}         {eb:.3e}         {v}")
    if ec>0:
        say(f"                duas copias do MESMO buffer diferem entre si: {ec:.3e}")
say("")
say("A pequeno + B grande = calculo certo, copia corrompe")
say("FIM")
