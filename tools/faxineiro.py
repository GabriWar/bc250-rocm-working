#!/usr/bin/env python3
"""Process that pings the GPU periodically to clear stale translations.

Why this should work
--------------------
Measured in cura_por_pressao.py + cura_propria.py:

  - the process itself cannot heal its own wrong translation: 32 new
    accesses and a compute dispatch do not evict the entry (20/20 wrong
    before and after)
  - ONE access by ANOTHER process heals it immediately (0/20), and mapping
    without accessing does not heal

In other words: a process activation by the hardware scheduler triggers an
internal firmware invalidation that unmap never triggers. This process exists to
trigger that invalidation on purpose, at regular intervals.

Modes:
    faxineiro.py persistente [ms]   one process, pings every ms (default 200)
    faxineiro.py nasce-e-morre [s]  spawns a NEW process every s (default 2)
                                    -- in case co-execution does not clear and
                                    only a NEW process activation does
"""
import ctypes
import os
import subprocess
import sys
import time

D2H = 2


def pinga_para_sempre(intervalo_ms):
    hip = ctypes.CDLL("libamdhip64.so")
    hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
    hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                              ctypes.c_size_t, ctypes.c_int]
    p = ctypes.c_void_p()
    if hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(4 << 20)) != 0:
        sys.exit(1)
    buf = (ctypes.c_ubyte * 8)()
    print(f"faxineiro persistente pid={os.getpid()} a cada {intervalo_ms} ms",
          flush=True)
    while True:
        hip.hipMemcpy(buf, p, ctypes.c_size_t(8), D2H)
        time.sleep(intervalo_ms / 1000.0)


def um_ping():
    hip = ctypes.CDLL("libamdhip64.so")
    hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
    hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                              ctypes.c_size_t, ctypes.c_int]
    p = ctypes.c_void_p()
    hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(4 << 20))
    buf = (ctypes.c_ubyte * 8)()
    hip.hipMemcpy(buf, p, ctypes.c_size_t(8), D2H)


def nasce_e_morre(intervalo_s):
    print(f"faxineiro nasce-e-morre pid={os.getpid()} a cada {intervalo_s} s",
          flush=True)
    while True:
        subprocess.run([sys.executable, os.path.abspath(__file__), "--um-ping"],
                       timeout=120)
        time.sleep(intervalo_s)


if __name__ == "__main__":
    if "--um-ping" in sys.argv:
        um_ping()
    elif len(sys.argv) > 1 and sys.argv[1] == "nasce-e-morre":
        nasce_e_morre(float(sys.argv[2]) if len(sys.argv) > 2 else 2.0)
    else:
        ms = float(sys.argv[2]) if len(sys.argv) > 2 else 200.0
        pinga_para_sempre(ms)
