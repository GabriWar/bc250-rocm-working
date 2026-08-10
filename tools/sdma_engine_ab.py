#!/usr/bin/env python3
"""Does SDMA0's completion write reach memory? A/B against SDMA1.

The question
------------
With HSA_ENABLE_SDMA=1 and user queues released for engine 0, ROCr hangs spinning
at 100% CPU in state R. State R is a memory busy-poll, not sleeping on an
interrupt -- so the absence of an interrupt there proves nothing: the runtime may
simply never have asked for one.

What that distinction hides is the question that matters: does the copy finish
and the completion write NOT reach memory (data path), or does the copy never
start (command path)? No polling or interrupt scheme saves the first case.

How it is measured
------------------
hsa_amd_memory_async_copy_on_engine() takes the engine as a parameter, so the
SAME copy can be queued on engine 0 and on engine 1 and compared. The completion
signal is read straight from memory in a loop, with a timestamp, instead of
waiting -- that way the 1 -> 0 transition can be seen happening (or not) without
depending on an interrupt.

Beyond the signal, the DESTINATION BUFFER is checked. Together they separate
three outcomes that look identical from outside:

    signal drops, data correct      the engine works
    signal drops, data wrong        completed too early; this is the 2 MiB bug
    signal does not drop, data correct  the copy ran and only completion was lost
    signal does not drop, data wrong    the copy never happened

Usage:
    sdma_engine_ab.py [size_mib] [timeout_s]
"""
import ctypes
import sys
import time

MIB = int(sys.argv[1]) if len(sys.argv) > 1 else 16
TIMEOUT = float(sys.argv[2]) if len(sys.argv) > 2 else 10.0
N = MIB * 1024 * 1024

hsa = ctypes.CDLL("libhsa-runtime64.so.1")

HSA_STATUS_SUCCESS = 0
HSA_DEVICE_TYPE_GPU = 1
HSA_DEVICE_TYPE_CPU = 0
HSA_AGENT_INFO_DEVICE = 17
HSA_AMD_SDMA_ENGINE_0 = 1
HSA_AMD_SDMA_ENGINE_1 = 2
# hsa_amd_memory_pool_info_t
POOL_SEGMENT = 0
POOL_GLOBAL_FLAGS = 1
POOL_SIZE = 2
POOL_ALLOC_ALLOWED = 5
SEGMENT_GLOBAL = 0
FLAG_FINE_GRAINED = 2


class Agent(ctypes.Structure):
    _fields_ = [("handle", ctypes.c_uint64)]


class Pool(ctypes.Structure):
    _fields_ = [("handle", ctypes.c_uint64)]


class Signal(ctypes.Structure):
    _fields_ = [("handle", ctypes.c_uint64)]


AGENT_CB = ctypes.CFUNCTYPE(ctypes.c_int, Agent, ctypes.c_void_p)
POOL_CB = ctypes.CFUNCTYPE(ctypes.c_int, Pool, ctypes.c_void_p)


def check(r, o):
    if r != HSA_STATUS_SUCCESS:
        raise RuntimeError(f"{o} devolveu {r}")


def declarar():
    """Without argtypes, ctypes passes struct-by-value wrong on x86-64 and the
    call is accepted but does nothing -- which is how the first version of this
    script failed even the good engine. If the control fails, it is the
    instrument that broke.
    """
    hsa.hsa_agent_get_info.argtypes = [Agent, ctypes.c_int, ctypes.c_void_p]
    hsa.hsa_amd_memory_pool_get_info.argtypes = [Pool, ctypes.c_int, ctypes.c_void_p]
    hsa.hsa_amd_agent_iterate_memory_pools.argtypes = [Agent, POOL_CB, ctypes.c_void_p]
    hsa.hsa_amd_memory_pool_allocate.argtypes = [Pool, ctypes.c_size_t,
                                                 ctypes.c_uint32,
                                                 ctypes.POINTER(ctypes.c_void_p)]
    hsa.hsa_amd_memory_pool_free.argtypes = [ctypes.c_void_p]
    hsa.hsa_amd_agents_allow_access.argtypes = [ctypes.c_uint32,
                                                ctypes.POINTER(Agent),
                                                ctypes.c_void_p, ctypes.c_void_p]
    hsa.hsa_signal_create.argtypes = [ctypes.c_int64, ctypes.c_uint32,
                                      ctypes.POINTER(Agent),
                                      ctypes.POINTER(Signal)]
    hsa.hsa_signal_destroy.argtypes = [Signal]
    hsa.hsa_signal_load_scacquire.argtypes = [Signal]
    hsa.hsa_signal_load_scacquire.restype = ctypes.c_int64
    hsa.hsa_amd_memory_async_copy_on_engine.argtypes = [
        ctypes.c_void_p, Agent,          # dst, dst_agent
        ctypes.c_void_p, Agent,          # src, src_agent
        ctypes.c_size_t,                 # size
        ctypes.c_uint32, ctypes.c_void_p,  # num_dep_signals, dep_signals
        Signal,                          # completion_signal
        ctypes.c_int,                    # engine_id
        ctypes.c_bool]                   # force_copy_on_sdma
    hsa.hsa_amd_memory_async_copy_on_engine.restype = ctypes.c_int


def main():
    check(hsa.hsa_init(), "hsa_init")
    declarar()

    agentes = {"cpu": None, "gpu": None}

    def ver_agente(a, _):
        t = ctypes.c_int(0)
        hsa.hsa_agent_get_info(a, HSA_AGENT_INFO_DEVICE, ctypes.byref(t))
        if t.value == HSA_DEVICE_TYPE_GPU and agentes["gpu"] is None:
            agentes["gpu"] = Agent(a.handle)
        elif t.value == HSA_DEVICE_TYPE_CPU and agentes["cpu"] is None:
            agentes["cpu"] = Agent(a.handle)
        return HSA_STATUS_SUCCESS

    check(hsa.hsa_iterate_agents(AGENT_CB(ver_agente), None), "iterate_agents")
    if not agentes["gpu"] or not agentes["cpu"]:
        raise RuntimeError("nao achei agente de CPU e GPU")

    pools = {"cpu": None, "gpu": None}
    tam = {"cpu": 0, "gpu": 0}

    def achar_pool(qual):
        def cb(p, _):
            seg = ctypes.c_int(0)
            hsa.hsa_amd_memory_pool_get_info(p, POOL_SEGMENT, ctypes.byref(seg))
            ok = ctypes.c_bool(False)
            hsa.hsa_amd_memory_pool_get_info(p, POOL_ALLOC_ALLOWED, ctypes.byref(ok))
            if seg.value == SEGMENT_GLOBAL and ok.value:
                sz = ctypes.c_size_t(0)
                hsa.hsa_amd_memory_pool_get_info(p, POOL_SIZE, ctypes.byref(sz))
                if sz.value > tam[qual]:
                    tam[qual] = sz.value
                    pools[qual] = Pool(p.handle)
            return HSA_STATUS_SUCCESS
        return cb

    for qual in ("cpu", "gpu"):
        check(hsa.hsa_amd_agent_iterate_memory_pools(
            agentes[qual], POOL_CB(achar_pool(qual)), None), f"pools {qual}")

    host = ctypes.c_void_p()
    dev = ctypes.c_void_p()
    check(hsa.hsa_amd_memory_pool_allocate(pools["cpu"], ctypes.c_size_t(N),
                                           0, ctypes.byref(host)), "alloc host")
    check(hsa.hsa_amd_memory_pool_allocate(pools["gpu"], ctypes.c_size_t(N),
                                           0, ctypes.byref(dev)), "alloc dev")

    lista = (Agent * 1)(agentes["gpu"])
    hsa.hsa_amd_agents_allow_access(1, lista, None, host)

    # recognizable pattern: byte i = i % 251. Prime, so any shifted or
    # repeated block shows up in the comparison.
    padrao = bytes((i % 251) for i in range(256)) * (N // 256)
    ctypes.memmove(host, padrao, N)

    print(f"  buffer {MIB} MiB, timeout {TIMEOUT}s por engine")

    for nome, eng in (("SDMA0", HSA_AMD_SDMA_ENGINE_0),
                      ("SDMA1", HSA_AMD_SDMA_ENGINE_1)):
        # destination dirtied on purpose: if the copy does not run, the data will not
        # match by accident
        ctypes.memset(dev, 0xAB, N)

        sig = Signal()
        check(hsa.hsa_signal_create(ctypes.c_int64(1), 0, None,
                                    ctypes.byref(sig)), "signal_create")

        t0 = time.perf_counter()
        r = hsa.hsa_amd_memory_async_copy_on_engine(
            dev, agentes["gpu"], host, agentes["cpu"], ctypes.c_size_t(N),
            0, None, sig, ctypes.c_int(eng), ctypes.c_bool(True))
        if r != HSA_STATUS_SUCCESS:
            print(f"  {nome}: async_copy_on_engine recusou ({r}) -- engine indisponivel?")
            hsa.hsa_signal_destroy(sig)
            continue

        # DIRECT read loop on the signal. We do not use hsa_signal_wait because
        # it may sleep waiting for an interrupt, and that is exactly what we
        # want out of the equation.
        caiu = False
        leituras = 0
        while time.perf_counter() - t0 < TIMEOUT:
            v = hsa.hsa_signal_load_scacquire(sig)
            leituras += 1
            if v == 0:
                caiu = True
                break
        dt = time.perf_counter() - t0

        # did the destination buffer arrive whole?
        volta = ctypes.create_string_buffer(N)
        ctypes.memmove(volta, dev, N)
        iguais = volta.raw == padrao
        difs = 0 if iguais else sum(1 for a, b in zip(volta.raw, padrao) if a != b)

        print(f"  {nome}: signal {'CAIU' if caiu else 'NAO CAIU'} em {dt:.3f}s "
              f"({leituras} leituras) | dados {'ok' if iguais else f'ERRADOS ({difs} bytes)'}")
        hsa.hsa_signal_destroy(sig)

    hsa.hsa_amd_memory_pool_free(host)
    hsa.hsa_amd_memory_pool_free(dev)
    hsa.hsa_shut_down()


if __name__ == "__main__":
    main()
