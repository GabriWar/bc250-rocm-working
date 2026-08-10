#!/usr/bin/env python3
"""For each page the GPU delivers wrong, asks the DRIVER what the page table
hierarchy actually says for that VA.

Why this script exists
----------------------
Doc 17 concludes that the tables are correct and that the GPU reads outside them.
That conclusion underpins everything that came after -- and it was drawn by
checking the PTE at offset 0 of each block, while the corruption starts at the
tail: 85 of 87 offsets where it begins are exact multiples of 2 MiB, and in one
measured case the block fails from offset 4 MiB to the end.

Checking from outside is imprecise. With vm_update_mode=3 the tracepoint's `pe`
field is a KERNEL virtual address (amdgpu_vm_cpu.c:87), not physical, and
scanning the 12 GiB of VRAM for the value does not say which VA each slot belongs
to. So the walk moved inside the driver, where the pointers are real:

    /sys/kernel/debug/dri/1/bc250_ptwalk

What the signature already suggests
-----------------------------------
With a per-PAGE marker (rather than per block) this showed up:

    A8028160 page 0 -> page 0 of A2621440    (A2621440 has 2 pages)
    A8028160 page 1 -> page 1 of A2621440
    A8028160 page 2 -> page 0 of A5898240
    A8028160 page 3 -> page 1 of A5898240

One block's 4 pages consume ALL the pages of another and then the first ones of a
third, in order. That has the shape of walking the wrong page list while writing
the PTEs -- not of a cache missing nor of a single corrupted entry.

How to read the result
----------------------
  leaf points at another BO's PA -> page table content: KERNEL
  leaf correct                   -> the GPU reads outside the table: below it
  pending invalidation           -> the GPU may be on a previous translation

The control is querying a page that did NOT diverge: if its walk makes no sense,
the instrument is lying and the rest is discarded.
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
    """The device's debugfs node changes name between boots: sometimes it is the
    numeric minor (dri/1), sometimes the PCI address (dri/0000:01:00.0).
    Searching avoids silence when the fixed path does not exist -- and silence
    was read as 'empty result' once."""
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
    """Asks the driver for the hierarchy of this VA."""
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

# --- the search key is the PID, not the PASID ---
# The BIOS disables SVM on this board ("SVM disabled (by BIOS) in MSR_VM_CR") and
# KFD reports pasid=0 in /sys/class/kfd/kfd/proc/<pid>/pasid, so the driver's
# pasid xarray never finds a compute process's VM. The driver resolves it through
# KFD's own path starting from the PID.
pasid = os.getpid()
kfd_pasid = "?"
try:
    kfd_pasid = open(f"/sys/class/kfd/kfd/proc/{os.getpid()}/pasid").read().strip()
except Exception:
    pass
say(f"  PID {pasid} (o KFD reporta pasid={kfd_pasid}, por isso a busca e por PID)")

# --- which pages does the GPU deliver wrong ---
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

# --- control: does the walk of a GOOD page make sense? ---
if bom:
    k, pag = bom
    va = blocos[k][1].value + pag * PAG
    say("")
    say(f"  ############ CONTROLE: {blocos[k][0]} pagina {pag} (SEM divergencia) ############")
    say(f"  VA 0x{va:x}")
    for ln in caminhar(pasid, va).splitlines():
        say("  " + ln)

# --- and now the failing ones ---
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
