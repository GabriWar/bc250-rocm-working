#!/usr/bin/env python3
"""Can the process heal its OWN wrong translation?

Context
-------
cura_por_pressao.py measured: ONE access by ANOTHER process to its own buffer
heals the first one's wrong translation (B on the trajectory, 2 of 2 runs).
Mapping without accessing does not heal.

But "the first access by another process" carries two things at once:

  press   new translation insertions into the same small structure (eviction)
  swap    the first activation of another process by the hardware scheduler
          -- a real context switch on the CUs, where the firmware may
          invalidate TLBs through its own internal path

Here the parent itself generates the pressure, with no new process at all:

  base  bad page confirmed 20/20
  P1    parent allocates 64 MiB and writes markers (host; no GPU)
  P2    parent reads 1 page of the new buffer via GPU
  P3    parent reads all 32 pages via GPU
  P4    parent runs a small conv2d (a real compute dispatch)

Reading:
  heals at P2/P3 -> capacity eviction; any new traffic heals it, and the
                    persistence of 200/200 came from always reading the same
                    pages. Location: small structure, UTCL1.
  heals at P4    -> compute dispatch heals, blit does not -- a different
                    insertion path (SQC/TCP vs blit), still eviction.
  never heals    -> the process's own pressure is NOT enough; the trigger is the
                    ACTIVATION OF ANOTHER process. The firmware has an
                    invalidation path that works, exercised on the swap -- and no
                    amount of self-traffic clears an entry of its own VMID.
"""
import ctypes
import os
import struct
import sys

PAG = 2 << 20
MAGIC = 0x5A5A_0000_0000_0000
D2H = 2
K = 20

OUT = os.path.expanduser("~/bc250-grimoire/cura_propria.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n")
    _f.flush()
    os.fsync(_f.fileno())
    print(s, flush=True)


hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                          ctypes.c_size_t, ctypes.c_int]

import torch  # noqa: E402
DEV = "cuda"
TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou: {r}")


def ler(base, off):
    buf = (ctypes.c_ubyte * 8)()
    if hip.hipMemcpy(buf, ctypes.c_void_p(base + off),
                     ctypes.c_size_t(8), D2H) != 0:
        return None
    v = struct.unpack("<Q", bytes(buf))[0]
    if (v >> 48) != 0x5A5A:
        return None
    return ((v >> 20) & 0xFFF, v & 0xFFFFF)


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

maus = []
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        e = 0
        for _ in range(K):
            got = ler(p.value, off)
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
            got = ler(blocos[k][1].value, pag * PAG)
            if got and got != (k, pag):
                e += 1
        det.append(f"{e}/{K}")
        if e == K:
            err += 1
    say(f"    {rot:<46} {err}/{len(maus)} ainda 100% erradas  [{' '.join(det)}]")
    return err


say("")
amostra("base")

# P1: map its own, no GPU
novo = ctypes.c_void_p()
ck(hip.hipMalloc(ctypes.byref(novo), ctypes.c_size_t(64 << 20)), "hipMalloc(64M)")
for pg in range(32):
    ctypes.memmove(novo.value + pg * PAG, struct.pack("<Q", MAGIC | 0xFFF00000 | pg), 8)
say("")
say("  P1: pai alocou 64 MiB e escreveu marcadores (host, sem GPU)")
e1 = amostra("apos mapear proprio")

# P2: 1 own page via GPU
buf = (ctypes.c_ubyte * 8)()
hip.hipMemcpy(buf, novo, ctypes.c_size_t(8), D2H)
say("")
say("  P2: pai leu 1 pagina do buffer novo via GPU")
e2 = amostra("apos 1 acesso proprio")

# P3: 32 own pages via GPU
for pg in range(1, 32):
    hip.hipMemcpy(buf, ctypes.c_void_p(novo.value + pg * PAG),
                  ctypes.c_size_t(8), D2H)
say("")
say("  P3: pai leu as 32 paginas via GPU")
e3 = amostra("apos 32 acessos proprios")

# P4: a real compute dispatch
import torch.nn.functional as F  # noqa: E402
x = torch.randn(1, 64, 64, 64, dtype=torch.float16).to(DEV)
w = torch.randn(64, 64, 3, 3, dtype=torch.float16).to(DEV)
_ = F.conv2d(x, w, padding=1)
torch.cuda.synchronize()
say("")
say("  P4: pai rodou um conv2d (dispatch de compute)")
e4 = amostra("apos dispatch de compute proprio")

say("")
n = len(maus)
say(f"  trajetoria ({n} paginas): base={n} -> P1={e1} -> P2={e2} -> P3={e3} -> P4={e4}")
for rot, e in (("P1 mapear-proprio", e1), ("P2 1-acesso-proprio", e2),
               ("P3 32-acessos-proprios", e3), ("P4 compute-proprio", e4)):
    if e == 0:
        say(f"  >>> CUROU EM: {rot}")
        break
else:
    say("  >>> NAO CUROU: pressao propria nao basta -- o gatilho e a ativacao")
    say("  >>> de OUTRO processo. O firmware tem invalidacao que funciona.")
