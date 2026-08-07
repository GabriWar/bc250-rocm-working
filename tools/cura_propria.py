#!/usr/bin/env python3
"""O PROPRIO processo consegue curar a sua traducao errada?

Contexto
--------
cura_por_pressao.py mediu: UM acesso de OUTRO processo ao buffer dele proprio
cura a traducao errada do primeiro (B na trajetoria, 2 de 2 rodadas). Mapear
sem acessar nao cura.

Mas o "primeiro acesso de outro processo" carrega duas coisas ao mesmo tempo:

  press   insercoes de traducao novas na mesma estrutura pequena (eviccao)
  troca   a primeira ativacao de outro processo pelo escalonador de hardware
          -- uma troca de contexto real nos CUs, onde o firmware pode
          invalidar TLBs por um caminho interno proprio

Aqui o PROPRIO pai gera a pressao, sem processo novo nenhum:

  base  pagina errada confirmada 20/20
  P1    pai aloca 64 MiB novos e escreve marcadores (host; sem GPU)
  P2    pai le 1 pagina do buffer novo via GPU
  P3    pai le as 32 paginas via GPU
  P4    pai roda um conv2d pequeno (dispatch de compute de verdade)

Leitura:
  cura em P2/P3  -> eviccao por capacidade; qualquer trafego novo cura, e a
                    persistencia dos 200/200 vinha de ler sempre as mesmas
                    paginas. Localizacao: estrutura pequena, UTCL1.
  cura em P4     -> dispatch de compute cura, blit nao -- caminho de insercao
                    diferente (SQC/TCP vs blit), ainda eviccao.
  nao cura       -> pressao do proprio processo NAO basta; o gatilho e a
                    ATIVACAO DE OUTRO processo. O firmware tem um caminho de
                    invalidacao que funciona, exercitado na troca -- e nenhuma
                    quantidade de trafego proprio limpa uma entrada do proprio
                    VMID.
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

# P1: mapear proprio, sem GPU
novo = ctypes.c_void_p()
ck(hip.hipMalloc(ctypes.byref(novo), ctypes.c_size_t(64 << 20)), "hipMalloc(64M)")
for pg in range(32):
    ctypes.memmove(novo.value + pg * PAG, struct.pack("<Q", MAGIC | 0xFFF00000 | pg), 8)
say("")
say("  P1: pai alocou 64 MiB e escreveu marcadores (host, sem GPU)")
e1 = amostra("apos mapear proprio")

# P2: 1 pagina propria via GPU
buf = (ctypes.c_ubyte * 8)()
hip.hipMemcpy(buf, novo, ctypes.c_size_t(8), D2H)
say("")
say("  P2: pai leu 1 pagina do buffer novo via GPU")
e2 = amostra("apos 1 acesso proprio")

# P3: 32 paginas proprias via GPU
for pg in range(1, 32):
    hip.hipMemcpy(buf, ctypes.c_void_p(novo.value + pg * PAG),
                  ctypes.c_size_t(8), D2H)
say("")
say("  P3: pai leu as 32 paginas via GPU")
e3 = amostra("apos 32 acessos proprios")

# P4: dispatch de compute de verdade
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
