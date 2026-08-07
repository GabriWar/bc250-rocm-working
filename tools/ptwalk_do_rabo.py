#!/usr/bin/env python3
"""Para cada pagina que a GPU entrega errado, pergunta ao DRIVER o que a
hierarquia de tabelas de pagina realmente diz para aquele VA.

Por que este script existe
--------------------------
O doc 17 conclui que as tabelas estao corretas e que a GPU le fora delas. Essa
conclusao sustenta tudo que veio depois -- e foi tirada conferindo a PTE do
offset 0 de cada bloco, enquanto a corrupcao comeca no rabo: 85 de 87 offsets
onde ela comeca sao multiplos exatos de 2 MiB, e num caso medido o bloco erra
do offset 4 MiB ate o fim.

Conferir de fora e impreciso. Com vm_update_mode=3 o campo `pe` do tracepoint e
endereco virtual de KERNEL (amdgpu_vm_cpu.c:87), nao fisico, e varrer os 12 GiB
de VRAM atras do valor nao diz a qual VA cada slot pertence. Por isso a
caminhada foi para dentro do driver, onde os ponteiros sao reais:

    /sys/kernel/debug/dri/1/bc250_ptwalk

O que a assinatura ja sugere
----------------------------
Com marcador por PAGINA (e nao por bloco) apareceu isto:

    A8028160 pagina 0 -> pagina 0 de A2621440    (A2621440 tem 2 paginas)
    A8028160 pagina 1 -> pagina 1 de A2621440
    A8028160 pagina 2 -> pagina 0 de A5898240
    A8028160 pagina 3 -> pagina 1 de A5898240

As 4 paginas de um bloco consomem TODAS as paginas de outro e depois as
primeiras de um terceiro, em ordem. Isso tem o formato de quem percorreu a
lista de paginas errada ao escrever as PTEs -- nao de cache errando nem de
entrada solta corrompida.

Como ler o resultado
--------------------
  folha aponta PA de outro BO   -> conteudo de tabela de pagina: KERNEL
  folha correta                 -> a GPU le fora da tabela: abaixo dela
  invalidacao pendente          -> a GPU pode estar em traducao anterior

O controle e a consulta de uma pagina que NAO divergiu: se a caminhada dela nao
fizer sentido, o instrumento esta mentindo e o resto e descartado.
"""
import ctypes
import os
import struct
import subprocess
import sys

import torch

DEV = "cuda"
D2H = 2
PAG = 2 << 20
MAGIC = 0x5A5A_0000_0000_0000
def _achar_walk():
    """O no de debugfs do dispositivo muda de nome entre boots: ora e o minor
    numerico (dri/1), ora o endereco PCI (dri/0000:01:00.0). Procurar evita
    silencio quando o caminho fixo nao existe -- e silencio foi lido como
    'resultado vazio' uma vez."""
    r = subprocess.run(["sudo", "-S", "sh", "-c",
                        "ls -d /sys/kernel/debug/dri/*/bc250_ptwalk 2>/dev/null | head -1"],
                       input="grdg\n", capture_output=True, text=True)
    c = r.stdout.strip()
    if not c:
        raise SystemExit("bc250_ptwalk nao encontrado em /sys/kernel/debug/dri/*/ "
                         "-- modulo instrumentado nao esta carregado")
    return c


WALK = None
OUT = os.path.expanduser("~/bc250-grimoire/ptwalk_do_rabo.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


def root(cmd):
    return subprocess.run(["sudo", "-S"] + cmd, input="grdg\n",
                          capture_output=True, text=True)


WALK = _achar_walk()


def caminhar(pasid, va):
    """Pergunta ao driver a hierarquia para este VA."""
    w = root(["sh", "-c", f"echo '{pasid:x} {va:x}' > {WALK}"])
    if w.returncode:
        return f"!! falha ao escrever em {WALK}: {w.stderr.strip()}"
    r = root(["cat", WALK])
    return r.stdout if r.stdout.strip() else f"!! leitura vazia de {WALK} (rc={r.returncode}) {r.stderr.strip()}"


hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]


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


TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

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
            ctypes.memmove(p.value + off, struct.pack("<Q", MAGIC | (k << 20) | pag), 8)
ck(hip.hipDeviceSynchronize(), "sync")

# --- a chave da busca e o PID, nao o PASID ---
# O BIOS desliga SVM nesta placa ("SVM disabled (by BIOS) in MSR_VM_CR") e o KFD
# reporta pasid=0 em /sys/class/kfd/kfd/proc/<pid>/pasid, entao a xarray de
# pasids do driver nunca acha a VM de um processo de compute. O driver resolve
# pelo caminho do proprio KFD a partir do PID.
pasid = os.getpid()
kfd_pasid = "?"
try:
    kfd_pasid = open(f"/sys/class/kfd/kfd/proc/{os.getpid()}/pasid").read().strip()
except Exception:
    pass
say(f"  PID {pasid} (o KFD reporta pasid={kfd_pasid}, por isso a busca e por PID)")

# --- quais paginas a GPU entrega erradas ---
say("  --- lendo todas as paginas pela GPU ---")
maus, bom = [], None
for k, (rot, p, t) in enumerate(blocos):
    for pag in range((t + PAG - 1) // PAG):
        off = pag * PAG
        if off + 8 > t:
            continue
        buf = (ctypes.c_ubyte * 8)()
        ck(hip.hipMemcpy(buf, ctypes.c_void_p(p.value + off),
                         ctypes.c_size_t(8), D2H), "hipMemcpy")
        got = struct.unpack("<Q", bytes(buf))[0]
        if (got >> 48) != 0x5A5A:
            continue
        ko, pago = (got >> 20) & 0xFFF, got & 0xFFFFF
        if (ko, pago) != (k, pag):
            maus.append((k, pag, ko, pago))
            say(f"    {rot} pag {pag} (offset {off/2**20:.0f} MiB): "
                f"entregou pag {pago} do bloco {ko}"
                f"{' (' + blocos[ko][0] + ')' if ko < len(blocos) else ''}")
        elif bom is None:
            bom = (k, pag)

if not maus:
    say("    execucao LIMPA -- nada a investigar nesta rodada")
    say("    (o gatilho e probabilistico; rode de novo ate sujar)")
else:
    say(f"    {len(maus)} paginas divergentes")

# --- controle: a caminhada de uma pagina BOA faz sentido? ---
if bom:
    k, pag = bom
    va = blocos[k][1].value + pag * PAG
    say("")
    say(f"  ############ CONTROLE: {blocos[k][0]} pagina {pag} (SEM divergencia) ############")
    say(f"  VA 0x{va:x}")
    for ln in caminhar(pasid, va).splitlines():
        say("  " + ln)

# --- e agora as que falharam ---
for k, pag, ko, pago in maus:
    va = blocos[k][1].value + pag * PAG
    say("")
    say(f"  ############ FALHA: {blocos[k][0]} pagina {pag} ############")
    say(f"  VA 0x{va:x}  -- a GPU entregou a pagina {pago} do bloco "
        f"{blocos[ko][0] if ko < len(blocos) else ko}")
    if ko < len(blocos):
        say(f"  (esse bloco vive em VA 0x{blocos[ko][1].value:x}, "
            f"a pagina entregue seria VA 0x{blocos[ko][1].value + pago * PAG:x})")
    for ln in caminhar(pasid, va).splitlines():
        say("  " + ln)

for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
