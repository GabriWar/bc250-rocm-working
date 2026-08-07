#!/usr/bin/env python3
"""A PTE da faixa que FALHA aponta para onde? (nao a da base do bloco)

O buraco que este script fecha
------------------------------
O doc 17 conclui que as tabelas de pagina estao corretas e que portanto a GPU le
FORA delas -- e todo o resto da investigacao foi construido em cima disso,
inclusive duas hipoteses de invalidacao que ja cairam por medicao.

Mas o triangular_fisico.py, que sustenta essa conclusao, so olha o offset 0:

    linha 166   hipMemcpy(buf, p, 8, D2H)      le 8 bytes na BASE do bloco
    linha 187   pg = p.value >> 12             casa a PTE da PRIMEIRA pagina
    linha 302   alvos = {pa[k] ...}            varre atras dos PAs BASE

E a corrupcao nao comeca na base. Nos dados de matriz_cpu_gpu:

    A 8028160B: 3833856 de 8028160 bytes errados, a partir de 4194304

8028160 - 4194304 = 3833856. Erra do offset de 4 MiB ate o fim do bloco, e os
primeiros 4 MiB estao certos. Ou seja: a PTE que foi conferida e justamente a da
regiao que FUNCIONA. A PTE da regiao que falha nunca foi lida.

Alem disso, 85 de 87 offsets onde a corrupcao comeca sao multiplos exatos de
2 MiB -- a granularidade de pagina grande, o mesmo incr=2097152 das PTEs.

Como este script fecha
----------------------
1. marcador por PAGINA, nao por bloco: cada pagina de 2 MiB recebe
   MAGIC | (bloco << 20) | pagina. Assim uma leitura identifica de qual pagina
   de qual bloco o dado veio, e nao so de qual bloco.
2. le pela GPU TODAS as paginas de todos os blocos.
3. para cada pagina divergente, usa o campo `pe` do tracepoint -- que e o
   endereco fisico da propria entrada de tabela -- para ler os BYTES REAIS da
   PTE daquela pagina. Sem varrer 12 GiB: pe + indice*8.

Leitura do resultado
--------------------
  PTE da pagina que falha aponta para o bloco errado
      -> o defeito e CONTEUDO DE TABELA DE PAGINA. O doc 17 inverte, e isso e
         software, corrigivel.
  PTE da pagina que falha esta correta
      -> a GPU realmente le fora da propria tabela, e o alvo passa a ser o
         caminho de acesso abaixo dela.

Controle embutido: a mesma leitura e feita para uma pagina que NAO divergiu. Se
a PTE dela nao conferir, a leitura fisica esta sob referencial errado e o
resultado inteiro e descartado.
"""
import ctypes
import os
import re
import struct
import subprocess

import torch

DEV = "cuda"
D2H = 2
TRC = "/sys/kernel/tracing"
VRAM_DBG = "/sys/kernel/debug/dri/1/amdgpu_vram"
OUT = os.path.expanduser("~/bc250-grimoire/pte_do_rabo.result")
PAG = 2 << 20                      # 2 MiB, a granularidade que os dados apontam
MAGIC = 0x5A5A_0000_0000_0000
MASC_PA = 0x0000FFFFFFFFF000       # bits 47:12 da PTE guardam o endereco fisico

_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def root(cmd):
    return subprocess.run(["sudo", "-S"] + cmd, input="grdg\n",
                          capture_output=True, text=True).stdout


def ler_fisico(off, n=8):
    """Le n bytes da VRAM pelo ENDERECO FISICO, sem passar por VA nenhum."""
    r = root(["python3", "-c",
              "import os,sys;fd=os.open('%s',os.O_RDONLY);"
              "sys.stdout.write(os.pread(fd,%d,%d).hex())" % (VRAM_DBG, n, off)])
    try:
        return bytes.fromhex(r.strip())
    except ValueError:
        return b""


hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou: {r}")


def aquecer():
    # identico ao dos outros reprodutores -- amarrar tensores de device a nomes
    # faz o aliasing sumir, entao a forma aqui nao e estetica
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

say("")
say("=" * 72)
say(f"boot={open('/proc/sys/kernel/random/boot_id').read().strip()[:8]} pid={os.getpid()}")

for e in ("amdgpu_vm_update_ptes", "amdgpu_vm_set_ptes"):
    root(["sh", "-c", f"echo 1 > {TRC}/events/amdgpu/{e}/enable"])
# o filtro evita as 938 entradas por execucao que, sem ele, perturbam o fenomeno
root(["sh", "-c", f"echo 'incr == {PAG}' > {TRC}/events/amdgpu/amdgpu_vm_set_ptes/filter"])
root(["sh", "-c", f"echo 32768 > {TRC}/buffer_size_kb"])
root(["sh", "-c", f"echo > {TRC}/trace"])
root(["sh", "-c", f"echo 1 > {TRC}/tracing_on"])

aquecer()
for _ in range(3):                                  # rotatividade: cria e libera
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append(p)
    for p in tmp:
        ck(hip.hipFree(p), "hipFree")

blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada}{t}", p, t))

# marcador POR PAGINA: identifica bloco E pagina, nao so bloco
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 <= t:
            ctypes.memmove(p.value + off, struct.pack("<Q", MAGIC | (k << 20) | pag), 8)
ck(hip.hipDeviceSynchronize(), "sync")

root(["sh", "-c", f"echo 0 > {TRC}/tracing_on"])
trace = root(["cat", f"{TRC}/trace"])

# --- a GPU entrega a pagina certa? ---
say("  --- lendo TODAS as paginas pela GPU (nao so a base) ---")
divergentes = []       # (k, pag, k_origem, pag_origem)
total_pag = 0
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        total_pag += 1
        buf = (ctypes.c_ubyte * 8)()
        ck(hip.hipMemcpy(buf, ctypes.c_void_p(p.value + off),
                         ctypes.c_size_t(8), D2H), "hipMemcpy")
        got = struct.unpack("<Q", bytes(buf))[0]
        if (got >> 48) != 0x5A5A:
            continue
        ko, pago = (got >> 20) & 0xFFF, got & 0xFFFFF
        if (ko, pago) != (k, pag):
            divergentes.append((k, pag, ko, pago))
            say(f"    {rot} pagina {pag} (offset {off} = {off/2**20:.0f} MiB): "
                f"entregou pagina {pago} do bloco {ko}"
                f"{' (' + blocos[ko][0] + ')' if ko < len(blocos) else ''}")
say(f"    {len(divergentes)} paginas divergentes de {total_pag} lidas")

# --- do trace: para cada pagina de VA, qual PTE e qual PA o driver programou ---
# update_ptes da a faixa de VA; o set_ptes seguinte da pe (endereco fisico da
# entrada), addr (PA destino), incr e count.
mapas = []      # (va_pg_inicial, pe, addr, incr, count)
pend = None
for ln in trace.splitlines():
    m = re.search(r'update_ptes: .*start:0x([0-9a-f]+) end:0x([0-9a-f]+), flags:0x([0-9a-f]+)', ln)
    if m:
        pend = int(m.group(1), 16); continue
    m = re.search(r'set_ptes: pe=([0-9a-f]+), addr=([0-9a-f]+), incr=(\d+), flags=([0-9a-f]+), count=(\d+)', ln)
    if m and pend is not None:
        mapas.append((pend, int(m.group(1), 16), int(m.group(2), 16),
                      int(m.group(3)), int(m.group(5))))
        pend = None
say(f"  --- {len(mapas)} mapeamentos de 2 MiB capturados no trace ---")


def pte_de(va):
    """Devolve (endereco fisico da PTE, PA que o driver mandou) para este VA."""
    pg = va >> 12
    for start, pe, addr, incr, count in reversed(mapas):
        n_pg = incr >> 12
        if start <= pg < start + count * n_pg:
            i = (pg - start) // n_pg
            return pe + i * 8, addr + i * incr
    return None, None


# --- calibra a base do FB e VALIDA lendo a PTE de uma pagina que NAO divergiu ---
BASE = 0x170000000
say(f"  --- controle: PTE de uma pagina SEM divergencia (base do FB 0x{BASE:x}) ---")
ok_controle = False
maus = {(k, pag) for k, pag, _, _ in divergentes}
for k, (rot, p, t) in enumerate(blocos):
    if ok_controle:
        break
    for pag in range((t + PAG - 1) // PAG):
        if (k, pag) in maus:
            continue
        slot, esperado = pte_de(p.value + pag * PAG)
        if slot is None:
            continue
        raw = ler_fisico(slot - BASE)
        if len(raw) != 8:
            continue
        val = struct.unpack("<Q", raw)[0]
        bate = (val & MASC_PA) == (esperado & MASC_PA)
        say(f"    {rot} pagina {pag}: slot 0x{slot:x} vale 0x{val:x}, "
            f"driver mandou 0x{esperado:x} -> {'CONFERE' if bate else 'NAO confere'}")
        if bate:
            ok_controle = True
        break

if not ok_controle:
    say("    >>> CONTROLE FALHOU: a leitura fisica nao reproduz nem uma PTE boa.")
    say("    >>> Referencial errado (base do FB ou semantica de pe). Resultado DESCARTADO.")
else:
    say("  --- a PTE da pagina que FALHOU (o que nunca foi lido) ---")
    for k, pag, ko, pago in divergentes:
        rot = blocos[k][0]
        va = blocos[k][1].value + pag * PAG
        slot, esperado = pte_de(va)
        if slot is None:
            say(f"    {rot} pagina {pag}: sem mapeamento no trace para VA 0x{va:x}")
            continue
        raw = ler_fisico(slot - BASE)
        if len(raw) != 8:
            say(f"    {rot} pagina {pag}: falha ao ler a PTE em 0x{slot:x}")
            continue
        val = struct.unpack("<Q", raw)[0]
        real_pa = val & MASC_PA

        # de quem e o PA que a PTE realmente contem?
        dono = None
        for kk, (rr, pp, tt) in enumerate(blocos):
            for gg in range((tt + PAG - 1) // PAG):
                _, pa_kk = pte_de(pp.value + gg * PAG)
                if pa_kk is not None and (pa_kk & MASC_PA) == real_pa:
                    dono = (rr, gg)
                    break
            if dono:
                break

        say(f"    {rot} pagina {pag}  (entregou pagina {pago} do bloco {ko})")
        say(f"      driver mandou : PA 0x{esperado:x}")
        say(f"      PTE na memoria: 0x{val:x}  -> PA 0x{real_pa:x}  (valida={val & 1})")
        if (esperado & MASC_PA) == real_pa:
            say("      => a PTE desta pagina esta CORRETA")
            say("      => a GPU le fora da propria tabela: defeito ABAIXO dela")
        else:
            say(f"      => a PTE desta pagina esta ERRADA, aponta para {dono or 'PA desconhecido'}")
            say("      => o defeito e CONTEUDO DE TABELA DE PAGINA (software)")

for e in ("amdgpu_vm_update_ptes", "amdgpu_vm_set_ptes"):
    root(["sh", "-c", f"echo 0 > {TRC}/events/amdgpu/{e}/enable"])
for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
