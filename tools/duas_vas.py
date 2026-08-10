#!/usr/bin/env python3
"""Is it REALLY the translation? Read the SAME physical memory via a SECOND VA.

The question
------------
Doc 22 rules out everything in the VA->PA path except the TLB. But there is a
candidate that produces an IDENTICAL symptom without involving translation at all:

  A) TLB          the GPU resolves VA->PA wrong          indexed by VA
  B) data cache   the PA is right, the L2 serves the      indexed by PA
                  line of another PA (tag collision)

Both give: correct PTE, correct memory, GPU delivering data from another live
block. Doc 17 refuted the L2 not writing back -- it did not refute tag collision
on read. And the two address groups measured there (0x171-0x173 at the base of
VRAM and 0x469-0x46f at the top, separated by 0x518000000) have exactly the shape
of a truncated tag.

The difference between A and B is the axis. So: take a page the GPU delivers
wrong, open the SAME physical memory in a second process via hipIpc -- which
gives a different VA for the same PA -- and read it again.

  reads CORRECT via VA2  -> the error follows the VA  -> TRANSLATION (A)
  reads the SAME WRONG   -> the error follows the PA  -> DATA CACHE (B)

Either way the answer is useful, and one of the two hypotheses dies.

Reading caveat
--------------
The second process has a different VA AND a different VMID. If it reads
correctly, there is no way to separate "another VA" from "another VMID" -- but
both point at translation, and neither at data cache. There is no ambiguous
outcome: only "read correctly" has two explanations, and they agree on what
matters.

Controls
--------
1. a page that did NOT diverge, read via VA2: must come back correct. If it does
   not, the IPC mapping is broken and the rest is discarded.
2. the same divergent page re-read via VA1 at the end: must still be wrong. If it
   healed on its own, the comparison is void.

Usage:
    duas_vas.py            parent process (the only one run by hand)
    duas_vas.py --filho    internal, spawned by the parent
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
    """Reads 8 bytes through the GPU at the given offset."""
    buf = (ctypes.c_ubyte * 8)()
    r = hip.hipMemcpy(buf, ctypes.c_void_p(base + off), ctypes.c_size_t(8), D2H)
    if r != 0:
        return None, f"hipMemcpy falhou: {r}"
    v = struct.unpack("<Q", bytes(buf))[0]
    if (v >> 48) != 0x5A5A:
        return None, f"sem marcador: 0x{v:016x}"
    return ((v >> 20) & 0xFFF, v & 0xFFFFF), None


# ----------------------------------------------------------------- child
if "--filho" in sys.argv:
    hip = carregar_hip()
    dados = open(os.environ["DV_HANDLES"], "rb").read()
    # layout: per entry, 64 bytes of handle + offset (8) + label (16)
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


# ------------------------------------------------------------------ parent
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n")
    _f.flush()
    os.fsync(_f.fileno())
    print(s, flush=True)


import torch  # noqa: E402  (parent only; the child does not need it)

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

# Classification with K reads, not with one.
# Measured in tools/oscila.py: per page the behavior is DETERMINISTIC
# (200/200 or 0/200), but there are intermittent pages and pages that heal on
# their own. Labeling with a single read puts an intermittent one in the control
# -- it already happened, and it inverted the conclusion. Only pages wrong 20/20
# enter the test, because only there does the VA1 x VA2 comparison mean anything.
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

# builds the handles: the control (good page) plus up to 4 divergent ones
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

# control 2: does VA1 still fail?
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
