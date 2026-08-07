#!/usr/bin/env python3
"""Processo que pinga a GPU periodicamente para limpar traducoes velhas.

Por que isso deveria funcionar
------------------------------
Medido em cura_por_pressao.py + cura_propria.py:

  - o PROPRIO processo nao consegue curar a propria traducao errada: 32
    acessos novos e um dispatch de compute nao despejam a entrada (20/20
    errada antes e depois)
  - UM acesso de OUTRO processo cura na hora (0/20), e mapear sem acessar
    nao cura

Ou seja: a ativacao de um processo pelo escalonador de hardware dispara uma
invalidacao interna do firmware que o unmap nunca dispara. Este processo
existe para disparar essa invalidacao de proposito, de tempos em tempos.

Modos:
    faxineiro.py persistente [ms]   um processo, pinga a cada ms (default 200)
    faxineiro.py nasce-e-morre [s]  spawna um processo NOVO a cada s (default 2)
                                    -- caso a co-execucao nao limpe e so a
                                    ativacao de processo NOVO limpe
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
