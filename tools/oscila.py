#!/usr/bin/env python3
"""Is the error per READ or per PAGE? Characterizes the intermittency.

The finding that motivates this
-------------------------------
tools/quando_cura.py measured the same divergent page six times in a row, with no
allocation between reads, and it oscillated: wrong, right, wrong, right, right,
right.

Caches do not do that. A stale TLB entry, a collided tag and a stale table line
are all DETERMINISTIC -- they would fail on every read until someone invalidates.
A per-read oscillation comes from none of them.

But six samples decide nothing, and there was an obvious hole: what if the read
path is unstable for EVERYTHING, good pages included?

What is measured
----------------
For each divergent page and for an equal number of good pages, N independent
reads of the SAME page, interleaved. Interleaving matters: if the good ones were
all read before the bad ones, any drift over time would look like a difference
between the groups.

Reading the result
------------------
  bad ~0%, good 0%      did not reproduce; the divergence was a single read
  bad >0%, good 0%      the error is per read, but only at certain addresses.
                        Not a cache. A transient in the address path.
  bad ~100%, good 0%    it is deterministic after all, and quando_cura.py's
                        oscillation needs another explanation
  good >0%              the read path itself is unstable, and no earlier
                        measurement in this project that used hipMemcpy to decide
                        "right/wrong" is valid without review
"""
import ctypes
import os
import struct
import sys

PAG = 2 << 20
MAGIC = 0x5A5A_0000_0000_0000
D2H = 2
N = int(sys.argv[1]) if len(sys.argv) > 1 else 200

OUT = os.path.expanduser("~/bc250-grimoire/oscila.result")
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
say(f"boot={open('/proc/sys/kernel/random/boot_id').read().strip()[:8]} "
    f"pid={os.getpid()} N={N} leituras por pagina")

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

# CLASSIFICATION BY K READS, not by one.
# The previous version labeled with ONE read. A page that fails half the
# time had a 50% chance of landing in the control group, and it did -- the
# control came contaminated and the conclusion came out inverted.
K = 20
todas = []
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        err = 0
        alvo = {}
        for _ in range(K):
            got = ler(p.value, off)
            if got is None:
                continue
            if got != (k, pag):
                err += 1
                alvo[got] = alvo.get(got, 0) + 1
        todas.append((k, pag, err, alvo))

sempre  = [(k, p) for k, p, e, a in todas if e == K]
nunca   = [(k, p) for k, p, e, a in todas if e == 0]
asvezes = [(k, p, e, a) for k, p, e, a in todas if 0 < e < K]

say(f"  classificacao com {K} leituras por pagina, {len(todas)} paginas:")
say(f"    sempre erradas:      {len(sempre)}")
say(f"    as vezes erradas:    {len(asvezes)}")
say(f"    nunca erradas:       {len(nunca)}")
for k, p, e, a in asvezes:
    alv = sorted(a.items(), key=lambda x: -x[1])
    say(f"      INTERMITENTE {blocos[k][0]}p{p}: {e}/{K}, alvos {alv}")
say("")

ruins = sempre + [(k, p) for k, p, e, a in asvezes]
boas = nunca

if not ruins:
    say("  execucao LIMPA -- rode de novo ate sujar")
    sys.exit(0)

# control: pages that passed the K classification reads, spread out
passo = max(1, len(boas) // max(1, len(ruins)))
boas = boas[::passo][:max(2, len(ruins))]

say(f"  {len(ruins)} pagina(s) divergente(s), {len(boas)} de controle")
say("  " + ", ".join(f"RUIM {blocos[k][0]}p{p}" for k, p in ruins))
say("  " + ", ".join(f"BOA  {blocos[k][0]}p{p}" for k, p in boas))
say("")

cnt = {("R", k, p): 0 for k, p in ruins}
cnt.update({("B", k, p): 0 for k, p in boas})
vistos = {c: {} for c in cnt}

# interleaved: one lap reads all the bad and all the good ones, in the same lap
for _ in range(N):
    for tag, lista in (("R", ruins), ("B", boas)):
        for k, p in lista:
            got = ler(blocos[k][1].value, p * PAG)
            if got is None:
                continue
            if got != (k, p):
                cnt[(tag, k, p)] += 1
                vistos[(tag, k, p)][got] = vistos[(tag, k, p)].get(got, 0) + 1

say(f"  --- {N} leituras por pagina, intercaladas ---")
tot_r = tot_b = 0
for (tag, k, p), n in sorted(cnt.items()):
    pct = 100.0 * n / N
    nome = "RUIM" if tag == "R" else "BOA "
    extra = ""
    if vistos[(tag, k, p)]:
        alvo = sorted(vistos[(tag, k, p)].items(), key=lambda x: -x[1])[0]
        extra = f"   entregou {alvo[0]} em {alvo[1]} delas"
    say(f"    {nome} {blocos[k][0]:>10}p{p}  {n:4d}/{N}  {pct:5.1f}% erradas{extra}")
    if tag == "R":
        tot_r += n
    else:
        tot_b += n

say("")
say(f"  divergentes: {tot_r}/{len(ruins)*N} = {100.0*tot_r/(len(ruins)*N):.1f}%")
say(f"  controle:    {tot_b}/{len(boas)*N} = "
    f"{100.0*tot_b/max(1,len(boas)*N):.1f}%")
say("")
if tot_b > 0:
    say("  >>> PAGINAS BOAS TAMBEM ERRAM. O caminho de leitura e instavel por si,")
    say("  >>> e toda medida deste projeto que usou hipMemcpy para decidir")
    say("  >>> certo/errado precisa ser revista.")
elif tot_r == 0:
    say("  >>> Nao reproduziu na releitura: a divergencia foi de uma leitura so.")
elif tot_r >= len(ruins) * N * 0.95:
    say("  >>> Deterministico. A oscilacao de quando_cura.py precisa de outra")
    say("  >>> explicacao -- provavelmente algo entre as amostras dele.")
else:
    say("  >>> INTERMITENTE, e so em certos enderecos. Nao e cache:")
    say("  >>> cache erraria sempre. E transiente no caminho de endereco.")
