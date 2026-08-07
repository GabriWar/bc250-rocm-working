#!/usr/bin/env python3
"""O erro e por LEITURA ou por PAGINA? Caracteriza a intermitencia.

O achado que motiva
-------------------
tools/quando_cura.py mediu a mesma pagina divergente seis vezes seguidas, sem
alocar nada entre as leituras, e ela oscilou: errado, certo, errado, certo,
certo, certo.

Cache nao faz isso. Entrada de TLB velha, tag colidido e linha de tabela velha
sao todos DETERMINISTICOS -- errariam em toda leitura ate alguem invalidar. Uma
oscilacao por leitura nao vem de nenhum deles.

Mas seis amostras nao decidem nada, e havia um furo obvio: e se o caminho de
leitura estiver instavel para TUDO, inclusive paginas boas?

O que se mede
-------------
Para cada pagina divergente e para um numero igual de paginas boas, N leituras
independentes da MESMA pagina, intercaladas. Intercalar importa: se as boas
fossem todas lidas antes das ruins, qualquer deriva no tempo viraria diferenca
entre os grupos.

Leitura do resultado
--------------------
  ruins ~0%, boas 0%     nao reproduziu; a divergencia foi de uma leitura so
  ruins >0%, boas 0%     o erro e por leitura, mas so em certos enderecos.
                         Nao e cache. E transiente no caminho de endereco.
  ruins ~100%, boas 0%   e deterministico depois de tudo, e a oscilacao de
                         quando_cura.py precisa de outra explicacao
  boas >0%               o proprio caminho de leitura e instavel, e nenhuma
                         medida anterior deste projeto que usou hipMemcpy para
                         decidir "certo/errado" vale sem revisao
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

# CLASSIFICACAO POR K LEITURAS, nao por uma.
# A versao anterior rotulava com UMA leitura. Uma pagina que erra metade das
# vezes tinha 50% de chance de entrar no grupo de controle, e entrou -- o
# controle vinha contaminado e a conclusao saiu invertida.
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

# controle: paginas que acertaram nas K leituras da classificacao, espalhadas
passo = max(1, len(boas) // max(1, len(ruins)))
boas = boas[::passo][:max(2, len(ruins))]

say(f"  {len(ruins)} pagina(s) divergente(s), {len(boas)} de controle")
say("  " + ", ".join(f"RUIM {blocos[k][0]}p{p}" for k, p in ruins))
say("  " + ", ".join(f"BOA  {blocos[k][0]}p{p}" for k, p in boas))
say("")

cnt = {("R", k, p): 0 for k, p in ruins}
cnt.update({("B", k, p): 0 for k, p in boas})
vistos = {c: {} for c in cnt}

# intercalado: uma volta le todas as ruins e todas as boas, na mesma volta
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
