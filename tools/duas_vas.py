#!/usr/bin/env python3
"""E MESMO a traducao? Le a MESMA memoria fisica por uma SEGUNDA VA.

A pergunta
----------
O doc 22 elimina tudo no caminho VA->PA menos o TLB. Mas existe um candidato que
produz sintoma IDENTICO sem envolver traducao nenhuma:

  A) TLB              a GPU resolve VA->PA errado          indexado por VA
  B) cache de dados   o PA esta certo, o L2 serve a linha   indexado por PA
                      de outro PA (colisao de tag)

Os dois dao: PTE correta, memoria correta, GPU entregando dado de outro bloco
vivo. O doc 17 refutou o L2 nao escrevendo de volta -- nao refutou colisao de
tag na leitura. E os dois grupos de endereco medidos la (0x171-0x173 na base da
VRAM e 0x469-0x46f no topo, separados por 0x518000000) tem exatamente a forma de
um tag truncado.

A diferenca entre A e B e o eixo. Entao: pegar uma pagina que a GPU entrega
errada, abrir a MESMA memoria fisica num segundo processo via hipIpc -- o que da
uma VA diferente para o mesmo PA -- e ler de novo.

  le CERTO pela VA2      -> o erro acompanha a VA  -> TRADUCAO (A)
  le o MESMO ERRADO      -> o erro acompanha o PA  -> CACHE DE DADOS (B)

Nos dois casos a resposta e util, e uma das duas hipoteses morre.

Ressalva de leitura
-------------------
O segundo processo tem VA diferente E VMID diferente. Se ele ler certo, nao da
para separar "outra VA" de "outro VMID" -- mas as duas apontam para traducao, e
nenhuma para cache de dados. O desfecho ambiguo nao existe: so o "leu certo"
tem duas explicacoes, e elas concordam no que importa.

Controles
---------
1. uma pagina que NAO divergiu, lida pela VA2: tem de vir certa. Se nao vier, o
   mapeamento IPC esta quebrado e o resto e descartado.
2. a mesma pagina divergente relida pela VA1 no fim: tem de continuar errada. Se
   tiver se curado sozinha, a comparacao nao vale.

Uso:
    duas_vas.py            processo pai (o unico que se roda a mao)
    duas_vas.py --filho    interno, chamado pelo pai
"""
import ctypes
import os
import struct
import subprocess
import sys

PAG = 2 << 20
MAGIC = 0x5A5A_0000_0000_0000
D2H = 2
IPC_HANDLE_SIZE = 64
IPC_LAZY_ENABLE_PEER_ACCESS = 1

OUT = os.path.expanduser("~/bc250-grimoire/duas_vas.result")


class Handle(ctypes.Structure):
    _fields_ = [("reserved", ctypes.c_byte * IPC_HANDLE_SIZE)]


def carregar_hip():
    hip = ctypes.CDLL("libamdhip64.so")
    hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
    hip.hipFree.argtypes = [ctypes.c_void_p]
    hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                              ctypes.c_size_t, ctypes.c_int]
    hip.hipIpcGetMemHandle.argtypes = [ctypes.POINTER(Handle), ctypes.c_void_p]
    hip.hipIpcOpenMemHandle.argtypes = [ctypes.POINTER(ctypes.c_void_p),
                                        Handle, ctypes.c_uint]
    hip.hipIpcCloseMemHandle.argtypes = [ctypes.c_void_p]
    return hip


def ler_pagina(hip, base, off):
    """Le 8 bytes pela GPU no offset dado."""
    buf = (ctypes.c_ubyte * 8)()
    r = hip.hipMemcpy(buf, ctypes.c_void_p(base + off), ctypes.c_size_t(8), D2H)
    if r != 0:
        return None, f"hipMemcpy falhou: {r}"
    v = struct.unpack("<Q", bytes(buf))[0]
    if (v >> 48) != 0x5A5A:
        return None, f"sem marcador: 0x{v:016x}"
    return ((v >> 20) & 0xFFF, v & 0xFFFFF), None


# ----------------------------------------------------------------- filho
if "--filho" in sys.argv:
    hip = carregar_hip()
    dados = open(os.environ["DV_HANDLES"], "rb").read()
    # formato: por entrada, 64 bytes de handle + offset (8) + rotulo (16)
    saida = []
    n = len(dados) // (IPC_HANDLE_SIZE + 8 + 16)
    for i in range(n):
        b = dados[i * 88:(i + 1) * 88]
        h = Handle()
        ctypes.memmove(ctypes.byref(h), b[:64], 64)
        off = struct.unpack("<Q", b[64:72])[0]
        rot = b[72:88].rstrip(b"\0").decode()
        p = ctypes.c_void_p()
        r = hip.hipIpcOpenMemHandle(ctypes.byref(p), h,
                                    IPC_LAZY_ENABLE_PEER_ACCESS)
        if r != 0:
            saida.append(f"{rot}\tERRO_OPEN\t{r}")
            continue
        got, err = ler_pagina(hip, p.value, off)
        if err:
            saida.append(f"{rot}\tERRO_LEITURA\t{err}")
        else:
            saida.append(f"{rot}\tOK\t{got[0]}\t{got[1]}\t0x{p.value:x}")
        hip.hipIpcCloseMemHandle(ctypes.c_void_p(p.value))
    open(os.environ["DV_SAIDA"], "w").write("\n".join(saida))
    sys.exit(0)


# ------------------------------------------------------------------- pai
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n")
    _f.flush()
    os.fsync(_f.fileno())
    print(s, flush=True)


import torch  # noqa: E402  (so no pai; o filho nao precisa)

DEV = "cuda"
TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

hip = carregar_hip()


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou: {r}")


def aquecer():
    import torch.nn.functional as F
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    torch.cuda.synchronize()


say("")
say("=" * 74)
say(f"boot={open('/proc/sys/kernel/random/boot_id').read().strip()[:8]} pid={os.getpid()}")

aquecer()
for _ in range(3):
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

for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 <= t:
            ctypes.memmove(p.value + off,
                           struct.pack("<Q", MAGIC | (k << 20) | pag), 8)
ck(hip.hipDeviceSynchronize(), "sync")

# Classificacao com K leituras, nao com uma.
# Medido em tools/oscila.py: por pagina o comportamento e DETERMINISTICO
# (200/200 ou 0/200), mas existem paginas intermitentes e paginas que curam
# sozinhas. Rotular com uma leitura poe uma intermitente no controle -- ja
# aconteceu, e inverteu a conclusao. So paginas 20/20 erradas entram no teste,
# porque so nelas a comparacao VA1 x VA2 significa alguma coisa.
K = 20
say(f"  --- lendo tudo pela VA original (VA1), {K}x por pagina ---")
maus, bom = [], None
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        errs, alvo = 0, None
        for _ in range(K):
            got, err = ler_pagina(hip, p.value, off)
            if err:
                continue
            if got != (k, pag):
                errs += 1
                alvo = got
        if errs == K:
            maus.append((k, pag, alvo))
            say(f"    {rot} pag {pag}: {K}/{K} erradas, sempre bloco {alvo[0]} pag {alvo[1]}")
        elif errs == 0 and bom is None:
            bom = (k, pag)
        elif errs:
            say(f"    {rot} pag {pag}: INTERMITENTE {errs}/{K} -- fora do teste")

if not maus:
    say("    execucao LIMPA -- nada a comparar. Rode de novo ate sujar.")
    sys.exit(0)
say(f"    {len(maus)} paginas divergentes")

# monta os handles: o controle (pagina boa) e ate 4 divergentes
alvos = []
if bom:
    alvos.append(("CONTROLE", bom[0], bom[1]))
for k, pag, got in maus[:4]:
    alvos.append((f"FALHA{k}p{pag}", k, pag))

buf = b""
for rot, k, pag in alvos:
    h = Handle()
    r = hip.hipIpcGetMemHandle(ctypes.byref(h), blocos[k][1])
    if r != 0:
        say(f"    hipIpcGetMemHandle falhou para {rot}: {r}")
        say("    -> IPC indisponivel nesta placa; este teste nao se aplica")
        sys.exit(2)
    buf += bytes(h.reserved) + struct.pack("<Q", pag * PAG) \
        + rot.encode().ljust(16, b"\0")

hpath = os.path.expanduser("~/bc250-grimoire/.dv_handles")
spath = os.path.expanduser("~/bc250-grimoire/.dv_saida")
open(hpath, "wb").write(buf)

say("")
say("  --- segundo processo: MESMO PA, VA diferente (VA2) ---")
env = dict(os.environ, DV_HANDLES=hpath, DV_SAIDA=spath)
r = subprocess.run([sys.executable, os.path.abspath(__file__), "--filho"],
                   env=env, capture_output=True, text=True, timeout=300)
if r.returncode != 0:
    say(f"    filho falhou (rc={r.returncode}): {r.stderr.strip()[:400]}")
    sys.exit(3)

res = {}
for ln in open(spath).read().splitlines():
    c = ln.split("\t")
    res[c[0]] = c[1:]

esperado = {rot: (k, pag) for rot, k, pag in alvos}
ctrl_ok = None
veredito = []
for rot, k, pag in alvos:
    c = res.get(rot)
    if not c or c[0] != "OK":
        say(f"    {rot}: {c}")
        if rot == "CONTROLE":
            ctrl_ok = False
        continue
    got = (int(c[1]), int(c[2]))
    certo = got == (k, pag)
    say(f"    {rot}: VA2=0x{c[3]} entregou bloco {got[0]} pag {got[1]}"
        f"  ({'CERTO' if certo else 'ERRADO'})")
    if rot == "CONTROLE":
        ctrl_ok = certo
    else:
        veredito.append(certo)

say("")
if ctrl_ok is not True:
    say("  CONTROLE FALHOU -- o mapeamento IPC nao le nem uma pagina boa.")
    say("  Nada aqui vale. Instrumento descartado.")
    sys.exit(4)

# controle 2: a VA1 ainda erra?
say(f"  --- controle 2: a VA1 ainda erra, em {K} leituras? ---")
ainda = 0
for k, pag, got0 in maus[:4]:
    e = 0
    for _ in range(K):
        got, err = ler_pagina(hip, blocos[k][1].value, pag * PAG)
        if not err and got != (k, pag):
            e += 1
    say(f"    {blocos[k][0]}p{pag}: {e}/{K} erradas pela VA1")
    if e == K:
        ainda += 1
say(f"    {ainda} de {len(maus[:4])} continuam 100% erradas pela VA1")
if ainda == 0:
    say("    as paginas se curaram sozinhas -- a comparacao nao vale")
    sys.exit(5)

say("")
if all(veredito):
    say("  >>> VA2 le CERTO o que a VA1 le errado.")
    say("  >>> O erro acompanha a VA, nao o endereco fisico.")
    say("  >>> E TRADUCAO. O cache de dados esta inocente.")
elif not any(veredito):
    say("  >>> VA2 le o MESMO ERRADO que a VA1.")
    say("  >>> O erro acompanha o endereco fisico, nao a VA.")
    say("  >>> NAO e traducao. O alvo e o cache de dados / o proprio PA.")
else:
    say(f"  >>> MISTO: {sum(veredito)} de {len(veredito)} certas pela VA2.")
    say("  >>> Sem veredito com este n. Repetir.")
