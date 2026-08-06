#!/usr/bin/env python3
"""A memoria da GPU guarda o que foi escrito? Sem kernel de conv no meio.

Motivo (2026-08-05): correlacionando ponteiro de device com erro de conv2d,
c=320 h=112 erra sempre, e escreve ~1 MB alem de onde c=320 h=104 -- que
compartilha a mesma base e acerta. Isso prediz uma regiao ruim.

Aqui e escrita e leitura pura: padrao conhecido, sincroniza, le de volta,
compara. Se falhar, o defeito e a memoria e nenhum kernel esta envolvido.
"""
import os, torch
d="cuda"
out=open(os.path.expanduser("~/bc250-grimoire/mem_scan.result"),"w",buffering=1)
def say(s):
    out.write(s+"\n"); out.flush(); os.fsync(out.fileno()); print(s,flush=True)

free,total=torch.cuda.mem_get_info()
say(f"VRAM livre {free/2**20:.0f} MB de {total/2**20:.0f} MB")
say("")
CH=64*2**20  # 64 MB por bloco
n=CH//4
total_ruim=0
blocos=[]
say("escrevendo padrao conhecido e lendo de volta, bloco a bloco:")
for i in range(12):
    try:
        t=torch.empty(n, dtype=torch.int32, device=d)
    except RuntimeError as e:
        say(f"  bloco {i}: sem memoria, parando ({type(e).__name__})"); break
    base=t.data_ptr()
    # padrao dependente do indice: pega bit preso, bit trocado e endereco errado
    ref=torch.arange(n, dtype=torch.int32, device=d) ^ 0x5A5A5A5A
    t.copy_(ref); torch.cuda.synchronize()
    dif=(t!=ref)
    nb=int(dif.sum())
    total_ruim+=nb
    marca="   <<< CORROMPIDO" if nb else ""
    say(f"  bloco {i:2d}  base=0x{base:x}  {n} palavras  ruins={nb}{marca}")
    if nb:
        idx=torch.nonzero(dif).flatten()[:5].tolist()
        for j in idx:
            say(f"        offset {j*4} (0x{base+j*4:x}): "
                f"esperado 0x{int(ref[j])&0xffffffff:08x} "
                f"obtido 0x{int(t[j])&0xffffffff:08x}")
    blocos.append(t)  # segura a referencia para nao reciclar

say("")
say(f"total de palavras corrompidas: {total_ruim}")
say("")
say("segunda passada: reler os MESMOS blocos, sem reescrever")
for i,t in enumerate(blocos):
    ref=torch.arange(n, dtype=torch.int32, device=d) ^ 0x5A5A5A5A
    nb=int((t!=ref).sum())
    if nb: say(f"  bloco {i:2d}: {nb} ruins na releitura  <<<")
say("  (nada acima = os dados permaneceram integros)")
say("FIM")
