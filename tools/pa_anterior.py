#!/usr/bin/env python3
"""THE BIRTH PROOF: was the delivered PA ever that VA's translation before?

The question
------------
It is measured (doc 23) that the error follows the VA, not the PA: the same
physical memory read through a second mapping comes back correct while the first
one fails 20/20. That proves the failure is in the translation. But it does not
say WHICH translation.

Two possibilities still fit:

  stale      the entry holds the PREVIOUS mapping of that VA. It was born in the
             hipFree that did not invalidate. Fix: invalidate on unmap.
  wrong tag  the PA was never a valid translation of that VA -- the entry answers
             a VA that is not its own. A different defect, a different fix, and
             invalidating on unmap would NOT solve it.

Doc 17 collected 2266 (expected PA, delivered PA) pairs. None of them was
compared against the PA that the SAME VA had in the previous generation. That is
the comparison that separates the two.

The method
----------
  1  churn phase: allocate, and for each page ask the driver for the PA
     (bc250_ptwalk).  ->  GENERATION 0 map:  VA -> PA
     free everything
  2  allocate again (the allocator tends to reuse the same VAs), write
     markers, and ask for the PA again.  ->  GENERATION 1 map:  VA -> PA
  3  find the deterministically wrong pages (20 reads)
  4  for each one, at the VA v that delivered it (block j, page p):

        PA_should = GEN1[v]                      what the table says today
        PA_used   = GEN1[VA of (j,p)]            where the delivered data lives
        PA_before = GEN0[v]                      what that VA pointed at before

     PA_used == PA_before  ->  STALE ENTRY, proven
     PA_used != PA_before  ->  not stale; the entry answers someone else's VA

Usage:
    pa_anterior.py --formato    dumps ONE walk, to calibrate the parser
    pa_anterior.py              the experiment
"""
import ctypes
import os
import re
import struct
import subprocess
import sys

PAG = 2 << 20
MAGIC = 0x5A5A_0000_0000_0000
D2H = 2
K = 20

OUT = os.path.expanduser("~/bc250-grimoire/pa_anterior.result")


def root(cmd):
    return subprocess.run(
        ["python3", os.path.expanduser("~/bc250-grimoire/hooks/asroot.py"),
         "-c", cmd], capture_output=True, text=True, timeout=60)


def achar_walk():
    r = root("ls -d /sys/kernel/debug/dri/*/bc250_ptwalk 2>/dev/null | head -1")
    c = r.stdout.strip()
    if not c:
        raise SystemExit("bc250_ptwalk ausente -- modulo sem instrumentacao")
    return c


WALK = achar_walk()


def caminhar(pid, va):
    """Raw text of the driver's walk for (pid, va)."""
    return caminhar_lote(pid, [va]).get(va, "")


def caminhar_lote(pid, vas):
    """Walks several VAs in a single root invocation.

    The previous version spent TWO invocations (su + pty) per VA. Covering the
    warmup, which creates dozens of mappings, was unfeasible that way -- and the
    lack of that coverage was exactly what prevented deciding whether the
    'foreign' entries came from unrecorded generations.
    """
    if not vas:
        return {}
    linhas = []
    for va in vas:
        linhas.append(f"echo '{pid:x} {va:x}' > {WALK}")
        linhas.append(f"echo '@@@VA {va:x}'")
        linhas.append(f"cat {WALK}")
    r = root(" ; ".join(linhas))
    out, atual, buf = {}, None, []
    for ln in r.stdout.splitlines():
        if ln.startswith("@@@VA "):
            if atual is not None:
                out[atual] = "\n".join(buf)
            atual = int(ln.split()[1], 16)
            buf = []
        elif atual is not None:
            buf.append(ln)
    if atual is not None:
        out[atual] = "\n".join(buf)
    return out


# Accepted PA patterns, in order of preference. There are several because the
# instrument's format changed between versions and guessing went wrong before; if
# none matches, the script stops instead of inventing a number.
PADROES = [
    # 'PA final' is the REAL content of the PTE -- that is what the table tells the
    # GPU to use. 'PA the driver SHOULD have written' is the computed reference, and
    # it only coincides while the PTE is correct; to build the VA->PA map of each
    # generation what counts is the content, not the reference.
    r'PA final\s*=\s*(0x[0-9a-f]+)',
    r'PA (?:que o driver DEVERIA ter escrito|the driver should have written)\s*:?\s*(0x[0-9a-f]+)',
    r'fragmento fisico\s+(0x[0-9a-f]+)',
    r'physical fragment\s+(0x[0-9a-f]+)',
    r'folha.*?addr=(0x[0-9a-f]+)',
    r'\bPTE\b.*?addr=(0x[0-9a-f]+)',
]


def extrai_pa(texto):
    for p in PADROES:
        m = re.search(p, texto, re.I)
        if m:
            return int(m.group(1), 16), p
    return None, None


if "--formato" in sys.argv:
    import torch
    hip = ctypes.CDLL("libamdhip64.so")
    hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
    p = ctypes.c_void_p()
    hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(8 << 20))
    torch.zeros(1, device="cuda")
    txt = caminhar(os.getpid(), p.value)
    print(txt)
    pa, pad = extrai_pa(txt)
    print(f"\n  >>> PA extraido: {hex(pa) if pa else 'NENHUM PADRAO CASOU'}")
    if pad:
        print(f"  >>> padrao usado: {pad}")
    sys.exit(0)


_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno()); print(s, flush=True)


import torch  # noqa: E402
DEV = "cuda"
TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                          ctypes.c_size_t, ctypes.c_int]
PID = os.getpid()


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


def aquecer(hist=None, cada=6):
    """Warmup, now with the torch allocator's generations recorded."""
    import torch.nn.functional as F
    n = 0
    for _ in range(2):
        for h in range(32, 136, 8):
            for c in (64, 320):
                x = torch.randn(1, c, h, h, dtype=torch.float16)
                w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
                n += 1
                if hist is not None and n % cada == 0:
                    torch.cuda.synchronize()
                    for va, pa in mapear_vas(vas_do_torch()).items():
                        h_ = hist.setdefault(va, [])
                        if not h_ or h_[-1][1] != pa:
                            h_.append((f"aq{n}", pa))
    torch.cuda.synchronize()


def mapear_vas(vas, rotulo=None):
    """VA -> PA for a list of VAs, in batch."""
    m, falhas = {}, 0
    for i in range(0, len(vas), 32):
        for va, txt in caminhar_lote(PID, vas[i:i + 32]).items():
            pa, _ = extrai_pa(txt)
            if pa is None:
                falhas += 1
            else:
                m[va] = pa
    if rotulo:
        say(f"    {rotulo}: {len(m)} VAs mapeadas, {falhas} sem PA")
    return m


def mapear_geracao(blocos, rotulo):
    vas = [p.value + pag * PAG
           for _rot, p, t in blocos
           for pag in range((t + PAG - 1) // PAG)]
    return mapear_vas(vas, rotulo)


def vas_do_torch():
    """2 MiB VAs of the segments PyTorch's allocator is holding right now.

    The warmup allocates and frees dozens of tensors; without this, any stale
    entry born there was classified as 'foreign' for lack of data, and a negative
    result was worth nothing.
    """
    try:
        seg = torch.cuda.memory_snapshot()
    except Exception:
        return []
    vas = []
    for s_ in seg:
        base, tam = s_.get("address", 0), s_.get("total_size", 0)
        if not base:
            continue
        ini = base & ~(PAG - 1)
        for va in range(ini, base + tam, PAG):
            vas.append(va)
    return sorted(set(vas))


say("")
say("=" * 74)
say(f"boot={open('/proc/sys/kernel/random/boot_id').read().strip()[:8]} pid={PID}")

# ALL generations per VA, not just the last, and now including the warmup.
# Two previous versions got the coverage wrong: the first used ger0.update(),
# which only kept the last churn round; the second kept all 3 rounds but ignored
# the warmup, which creates dozens of mappings through torch's allocator. In both
# cases a stale entry born outside the coverage came out classified as
# "foreign" -- and a negative result was worth nothing.
ger0 = {}          # va -> [(label, pa), ...]

say("  fase 0: aquecimento, registrando as geracoes do alocador do torch")
aquecer(ger0)
say(f"    aquecimento: {len(ger0)} VAs vistas, "
    f"{sum(len(v) for v in ger0.values())} geracoes")

say("  fase 1: churn, registrando VA -> PA")
for rodada in range(3):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append((f"c{rodada}_{t}", p, t))
    m = mapear_geracao(tmp, f"  churn rodada {rodada}")
    for va, pa in m.items():
        h_ = ger0.setdefault(va, [])
        if not h_ or h_[-1][1] != pa:
            h_.append((f"r{rodada}", pa))
    for _, p, _t in tmp:
        ck(hip.hipFree(p), "hipFree")

# --- GENERATION 1: the final allocations ---
say("  fase 2: geracao 1 (final), registrando VA -> PA")
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
ger1 = mapear_geracao(blocos, "  geracao 1")

reusadas = set(ger0) & set(ger1)
say(f"  VAs reusadas entre as geracoes: {len(reusadas)} de {len(ger1)}")
if not reusadas:
    say("  >>> NENHUMA VA reusada. Sem reuso nao pode existir entrada obsoleta,")
    say("  >>> e se ainda assim houver divergencia, ela NAO e obsoleta.")

# --- deterministically wrong pages ---
say("  fase 3: classificando paginas (20 leituras cada)")
maus = []
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        e, alvo = 0, None
        for _ in range(K):
            got = ler(p.value, off)
            if got and got != (k, pag):
                e += 1
                alvo = got
        if e == K:
            maus.append((k, pag, alvo))
        elif e:
            say(f"    {rot}p{pag}: INTERMITENTE {e}/{K} -- fora")

if not maus:
    say("  execucao LIMPA -- rode de novo ate sujar")
    sys.exit(0)

say("")
say(f"  fase 4: veredito, {len(maus)} pagina(s)")
obsoleta = alheia = indecidivel = 0
for k, pag, (kj, pj) in maus:
    va = blocos[k][1].value + pag * PAG
    if kj >= len(blocos):
        say(f"    {blocos[k][0]}p{pag}: bloco entregue {kj} fora da faixa -- pulando")
        continue
    va_j = blocos[kj][1].value + pj * PAG
    pa_deveria = ger1.get(va)
    pa_usado = ger1.get(va_j)
    hist = ger0.get(va, [])
    pa_antes = hist[-1][1] if hist else None
    say(f"    {blocos[k][0]}p{pag}  VA=0x{va:x}")
    say(f"      deveria (tabela hoje) : {hex(pa_deveria) if pa_deveria else '?'}")
    say(f"      usado   (dado veio de): {hex(pa_usado) if pa_usado else '?'}"
        f"  = {blocos[kj][0]}p{pj}")
    if hist:
        say(f"      antes   (mesma VA, {len(hist)} geracoes): " +
            ", ".join(f"{r}={hex(a)}" for r, a in hist[-6:]))
    else:
        say("      antes   : VA nao existia em nenhuma rodada de churn")
    # also: does the used PA match the PA of ANY VA in ANY round?
    onde = [(v, r, a) for v, h in ger0.items() for r, a in h if a == pa_usado]
    if onde:
        say("      o PA usado ja foi de: " +
            ", ".join(f"VA=0x{v:x} {r}" for v, r, a in onde[:4]))
    else:
        say("      o PA usado NAO aparece em nenhuma rodada de churn")
    if pa_usado is None or pa_antes is None:
        say("      -> INDECIDIVEL")
        indecidivel += 1
    elif pa_usado in [a for _, a in hist]:
        r = [rr for rr, a in hist if a == pa_usado][0]
        say(f"      -> ENTRADA OBSOLETA (o PA usado e o desta VA em {r})")
        obsoleta += 1
    else:
        say("      -> NAO obsoleta: este PA nunca foi traducao desta VA")
        alheia += 1

say("")
say(f"  obsoletas={obsoleta}  alheias={alheia}  indecidiveis={indecidivel}")
if obsoleta and not alheia:
    say("  >>> A GPU traduz pelo mapeamento da geracao anterior daquela VA.")
    say("  >>> Nascimento: o hipFree que nao invalidou. Invalidar no unmap resolve.")
elif alheia and not obsoleta:
    say("  >>> O PA nunca foi traducao daquela VA. NAO e entrada obsoleta --")
    say("  >>> a entrada responde a uma VA que nao e a dela. Invalidar no unmap")
    say("  >>> nao resolveria, e o alvo muda.")
elif obsoleta and alheia:
    say("  >>> MISTO. Os dois mecanismos aparecem; nenhum sozinho explica.")
