#!/usr/bin/env python3
"""A cura vem de PRESSAO DE EVICCAO ou do MESMO PA? Discrimina.

O que ficou aberto no doc 23
----------------------------
O acesso do segundo processo cura a traducao do primeiro (3 de 3). Mas o filho
fazia so uma coisa: abrir o handle IPC do PA aliasado e ler ELE. Duas
explicacoes sobram:

  pressao   qualquer acesso do filho insere traducoes novas na mesma estrutura
            pequena (UTCL1) e despeja a entrada velha por evicao
  mesmo-PA  algo especifico de tocar o MESMO endereco fisico por outro
            mapeamento (probe/snoop por PA)

Aqui o filho faz as coisas EM ORDEM, e o pai reamostra a pagina errada entre
cada uma:

  A  filho iniciou HIP e alocou 64 MiB proprios (mapeamento, zero acesso)
  B  filho LEU 1 pagina do buffer proprio       <- uma insercao, PA alheio
  C  filho leu 32 paginas do buffer proprio     <- pressao de eviccao
  D  filho abriu o IPC e leu o PA aliasado      <- so agora o mesmo-PA
  E  filho saiu

Leitura:
  cura em B ou C  -> eviccao generica; a entrada velha mora numa estrutura
                     pequena o bastante para trafego alheio despejar (UTCL1)
  cura so em D    -> acoplamento por PA; mecanismo diferente do assumido
  nao cura        -> a cura do doc 23 dependia da combinacao abrir+ler dali

Ressalva de contexto: este boot roda com bc250_l2_force_miss=7 (braco B do doc
22). O UTCL2 nao guarda traducao nenhuma, entao qualquer staleness aqui e
UTCL1 puro. E exatamente o isolamento que se quer para esta pergunta.
"""
import ctypes
import os
import struct
import subprocess
import sys
import time

PAG = 2 << 20
MAGIC = 0x5A5A_0000_0000_0000
D2H = 2
IPC_HANDLE_SIZE = 64
IPC_LAZY = 1
K = 20

OUT = os.path.expanduser("~/bc250-grimoire/cura_por_pressao.result")
HPATH = os.path.expanduser("~/bc250-grimoire/.cp_handles")
SINAL = os.path.expanduser("~/bc250-grimoire/.cp_sinal")


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


def ler(hip, base, off):
    buf = (ctypes.c_ubyte * 8)()
    if hip.hipMemcpy(buf, ctypes.c_void_p(base + off),
                     ctypes.c_size_t(8), D2H) != 0:
        return None
    v = struct.unpack("<Q", bytes(buf))[0]
    if (v >> 48) != 0x5A5A:
        return None
    return ((v >> 20) & 0xFFF, v & 0xFFFFF)


def sinal(v):
    open(SINAL, "w").write(v)


def espera(alvo, limite=120):
    t0 = time.time()
    while time.time() - t0 < limite:
        try:
            if open(SINAL).read().strip() == alvo:
                return True
        except OSError:
            pass
        time.sleep(0.05)
    return False


# ----------------------------------------------------------------- filho
if "--filho" in sys.argv:
    hip = carregar_hip()
    TAMF = 64 << 20
    meu = ctypes.c_void_p()
    if hip.hipMalloc(ctypes.byref(meu), ctypes.c_size_t(TAMF)) != 0:
        sinal("erro-malloc")
        sys.exit(1)
    sinal("A-alocou")
    espera("vai-B")
    # B: UMA leitura de pagina propria (uma insercao de traducao)
    buf = (ctypes.c_ubyte * 8)()
    hip.hipMemcpy(buf, meu, ctypes.c_size_t(8), D2H)
    sinal("B-leu-1")
    espera("vai-C")
    # C: 32 paginas proprias (pressao de eviccao)
    for pg in range(1, 32):
        hip.hipMemcpy(buf, ctypes.c_void_p(meu.value + pg * PAG),
                      ctypes.c_size_t(8), D2H)
    sinal("C-leu-32")
    espera("vai-D")
    # D: so agora o mesmo-PA, via IPC
    d = open(HPATH, "rb").read()
    h = Handle()
    ctypes.memmove(ctypes.byref(h), d[:64], 64)
    off = struct.unpack("<Q", d[64:72])[0]
    p = ctypes.c_void_p()
    r = hip.hipIpcOpenMemHandle(ctypes.byref(p), h, IPC_LAZY)
    if r != 0:
        sinal(f"erro-open-{r}")
        sys.exit(1)
    got = ler(hip, p.value, off)
    hip.hipIpcCloseMemHandle(ctypes.c_void_p(p.value))
    sinal(f"D-leu-ipc {got[0] if got else -1} {got[1] if got else -1}")
    espera("vai-E")
    sys.exit(0)


# ------------------------------------------------------------------- pai
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n")
    _f.flush()
    os.fsync(_f.fileno())
    print(s, flush=True)


import torch  # noqa: E402

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

# so paginas deterministicas (20/20) valem
maus = []
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        e = 0
        for _ in range(K):
            got = ler(hip, p.value, off)
            if got and got != (k, pag):
                e += 1
        if e == K:
            maus.append((k, pag))
        elif e:
            say(f"  {rot}p{pag}: INTERMITENTE {e}/{K} -- fora")

if not maus:
    say("  execucao LIMPA -- rode de novo")
    sys.exit(0)
say(f"  {len(maus)} pagina(s) deterministicas: " +
    ", ".join(f"{blocos[k][0]}p{p}" for k, p in maus))


def amostra(rot):
    err, det = 0, []
    for k, pag in maus:
        e = 0
        for _ in range(K):
            got = ler(hip, blocos[k][1].value, pag * PAG)
            if got and got != (k, pag):
                e += 1
        det.append(f"{e}/{K}")
        if e == K:
            err += 1
    say(f"    {rot:<46} {err}/{len(maus)} ainda 100% erradas  [{' '.join(det)}]")
    return err


k0, pag0 = maus[0]
h = Handle()
ck(hip.hipIpcGetMemHandle(ctypes.byref(h), blocos[k0][1]), "GetMemHandle")
open(HPATH, "wb").write(bytes(h.reserved) + struct.pack("<Q", pag0 * PAG))

say("")
amostra("base (antes do filho)")
sinal("comeca")
filho = subprocess.Popen([sys.executable, os.path.abspath(__file__), "--filho"],
                         stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
if not espera("A-alocou"):
    say(f"  filho nao alocou: {filho.stderr.read().decode()[:300]}")
    filho.kill()
    sys.exit(3)
say("")
say("  A: filho vivo, 64 MiB alocados, ZERO acesso")
eA = amostra("apos mapear (sem acesso)")

sinal("vai-B")
espera("B-leu-1")
say("")
say("  B: filho leu UMA pagina do buffer PROPRIO")
eB = amostra("apos 1 acesso a PA alheio")

sinal("vai-C")
espera("C-leu-32")
say("")
say("  C: filho leu 32 paginas do buffer PROPRIO")
eC = amostra("apos 32 acessos a PA alheio")

sinal("vai-D")
t0 = time.time()
while time.time() - t0 < 120 and not open(SINAL).read().startswith("D-leu-ipc"):
    time.sleep(0.05)
lido = open(SINAL).read().split()
certo = len(lido) == 3 and (int(lido[1]), int(lido[2])) == (k0, pag0)
say("")
say(f"  D: filho abriu IPC e leu o MESMO PA -> viu bloco {lido[1]} pag {lido[2]}"
    f" ({'CERTO' if certo else 'ERRADO'})")
eD = amostra("apos acesso ao mesmo PA")

sinal("vai-E")
filho.wait(timeout=60)
say("")
say("  E: filho saiu")
eE = amostra("apos teardown")

say("")
n = len(maus)
say(f"  trajetoria ({n} paginas): base={n} -> A={eA} -> B={eB} -> C={eC} "
    f"-> D={eD} -> E={eE}")
for rot, e in (("A mapear", eA), ("B 1-acesso-alheio", eB),
               ("C 32-acessos-alheios", eC), ("D mesmo-PA", eD),
               ("E teardown", eE)):
    if e == 0:
        say(f"  >>> CUROU EM: {rot}")
        break
else:
    say("  >>> NAO CUROU em etapa nenhuma")
