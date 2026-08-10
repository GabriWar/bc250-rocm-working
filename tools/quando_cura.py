#!/usr/bin/env python3
"""The aliasing heals itself. When, exactly?

Why this script exists
----------------------
Doc 17 claims that the aliasing, once established, is deterministic and persists
-- "forced TLB invalidation and rewriting do not recover the block".

tools/duas_vas.py contradicted that by accident. The sequence was:

    read VA1 -> wrong
    hipIpcGetMemHandle
    child process opens the same PA through another VA, reads, closes, exits
    read VA1 -> RIGHT

Some step in there healed it. Since the child read correctly, it stayed ambiguous
whether it read correctly because its VA is good (translation) or because by the
time it read it had already healed.

This script resamples VA1 at EVERY step, so each wrong->right transition is
trapped between two adjacent reads.

Measured steps
--------------
    0  right after finding the divergent ones, N reads in a row
       (if it already oscillates here, it is not "persistent" even with IPC in
        the middle, and the rest of the experiment is about something else)
    1  after hipIpcGetMemHandle, with no new process at all
    2  with the child ALIVE, after it opened the handle but BEFORE it read
    3  with the child ALIVE, after it has read
    4  after the child closed the handle and exited

What each answer means
----------------------
    heals at 0  not persistent; re-reading alone solves it, and doc 17's premise
                falls entirely
    heals at 1  taking the handle already touches the mapping (the driver redoes PTEs)
    heals at 2  opening the same BO in a second VM is the trigger
    heals at 3  the READ by the other VM is the trigger
    heals at 4  the process exit -- KFD teardown -- is the trigger

Any of them is a candidate mitigation, and all are cheap to apply compared to
poking at hardware that does not respond.
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
RELEITURAS = 5

OUT = os.path.expanduser("~/bc250-grimoire/quando_cura.result")
HPATH = os.path.expanduser("~/bc250-grimoire/.qc_handles")
SINAL = os.path.expanduser("~/bc250-grimoire/.qc_sinal")


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


def espera(caminho, alvo, limite=60):
    t0 = time.time()
    while time.time() - t0 < limite:
        try:
            if open(caminho).read().strip() == alvo:
                return True
        except OSError:
            pass
        time.sleep(0.05)
    return False


# ----------------------------------------------------------------- child
if "--filho" in sys.argv:
    hip = carregar_hip()
    d = open(HPATH, "rb").read()
    h = Handle()
    ctypes.memmove(ctypes.byref(h), d[:64], 64)
    off = struct.unpack("<Q", d[64:72])[0]
    p = ctypes.c_void_p()
    r = hip.hipIpcOpenMemHandle(ctypes.byref(p), h, IPC_LAZY)
    if r != 0:
        open(SINAL, "w").write(f"erro-open-{r}")
        sys.exit(1)
    open(SINAL, "w").write("abriu")          # step 2: parent measures now
    espera(SINAL, "pode-ler")
    got = ler(hip, p.value, off)
    open(SINAL, "w").write(f"leu {got[0] if got else -1} {got[1] if got else -1}")
    espera(SINAL, "pode-sair")
    hip.hipIpcCloseMemHandle(ctypes.c_void_p(p.value))
    open(SINAL, "w").write("saiu")
    sys.exit(0)


# ------------------------------------------------------------------ parent
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

# Only DETERMINISTIC pages get in. Measured in tools/oscila.py: there are
# intermittent pages, and one of them -- labeled by a single read -- made this
# script bail out at step 0 concluding "heals just by re-reading", which was true
# for that page and false for the phenomenon.
K = 20
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
            say(f"  {rot}p{pag}: INTERMITENTE {e}/{K} -- fora do teste")

if not maus:
    say("  execucao LIMPA -- rode de novo ate sujar")
    sys.exit(0)
say(f"  {len(maus)} paginas divergentes: " +
    ", ".join(f"{blocos[k][0]}p{pag}" for k, pag in maus))


def amostra(rotulo):
    """How many of the divergent ones still fail on ALL K reads?

    A single read would make a partially healed page look either healed or
    intact, depending on luck."""
    err = 0
    det = []
    for k, pag in maus:
        e = 0
        for _ in range(K):
            got = ler(hip, blocos[k][1].value, pag * PAG)
            if got and got != (k, pag):
                e += 1
        det.append(f"{e}/{K}")
        if e == K:
            err += 1
    say(f"    {rotulo:<40} {err}/{len(maus)} ainda 100% erradas  [{' '.join(det)}]")
    return err


say("")
say(f"  etapa 0: {RELEITURAS} releituras seguidas, sem fazer mais nada")
e0 = [amostra(f"releitura {i+1}") for i in range(3)]
if e0[-1] == 0:
    say("")
    say("  >>> CUROU SO DE RELER. Nao e persistente.")
    say("  >>> A premissa do doc 17 (deterministico e persiste) cai aqui,")
    say("  >>> e nada do resto do experimento e necessario.")
    sys.exit(0)

k0, pag0 = maus[0]
h = Handle()
ck(hip.hipIpcGetMemHandle(ctypes.byref(h), blocos[k0][1]), "hipIpcGetMemHandle")
open(HPATH, "wb").write(bytes(h.reserved) + struct.pack("<Q", pag0 * PAG))
say("")
say("  etapa 1: depois de hipIpcGetMemHandle, sem processo novo")
e1 = amostra("apos GetMemHandle")

open(SINAL, "w").write("comeca")
filho = subprocess.Popen([sys.executable, os.path.abspath(__file__), "--filho"],
                         stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
if not espera(SINAL, "abriu"):
    say(f"    filho nao abriu o handle: {filho.stderr.read().decode()[:300]}")
    filho.kill()
    sys.exit(3)
say("")
say("  etapa 2: filho VIVO, handle aberto, ainda NAO leu")
e2 = amostra("com o segundo VM mapeado")

open(SINAL, "w").write("pode-ler")
t0 = time.time()
while time.time() - t0 < 60 and not open(SINAL).read().startswith("leu"):
    time.sleep(0.05)
lido = open(SINAL).read().split()
say("")
say(f"  etapa 3: filho VIVO, ja leu -> ele viu bloco {lido[1]} pag {lido[2]}"
    f"  ({'CERTO' if (int(lido[1]), int(lido[2])) == (k0, pag0) else 'ERRADO'})")
e3 = amostra("apos a leitura pelo segundo VM")

open(SINAL, "w").write("pode-sair")
filho.wait(timeout=60)
say("")
say("  etapa 4: filho fechou o handle e saiu")
e4 = amostra("apos teardown do segundo processo")

say("")
n = len(maus)
seq = [("0 releitura", e0[-1]), ("1 GetMemHandle", e1), ("2 mapeado", e2),
       ("3 lido", e3), ("4 saiu", e4)]
say(f"  trajetoria (de {n} paginas erradas): " +
    " -> ".join(f"{r}={v}" for r, v in seq))
cura = next((r for r, v in seq if v == 0), None)
if cura:
    say(f"  >>> CUROU NA ETAPA: {cura}")
else:
    say("  >>> NAO CUROU em nenhuma etapa. duas_vas.py curou por outro motivo,")
    say("  >>> e o que muda entre os dois scripts precisa ser isolado.")
