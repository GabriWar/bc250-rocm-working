import ctypes, sys, time, os
sys.argv=['x']
exec(open('/home/gabriwar/bc250-rocm-working/tools/sdma_engine_ab.py').read().split('def main()')[0])
hsa.hsa_init(); declarar()
ags={"cpu":None,"gpu":None}
def va(a,_):
    t=ctypes.c_int(0); hsa.hsa_agent_get_info(a,17,ctypes.byref(t))
    if t.value==1 and ags["gpu"] is None: ags["gpu"]=Agent(a.handle)
    elif t.value==0 and ags["cpu"] is None: ags["cpu"]=Agent(a.handle)
    return 0
hsa.hsa_iterate_agents(AGENT_CB(va),None)
pl={"cpu":None,"gpu":None}
def mk(q,want):
    def cb(p,_):
        seg=ctypes.c_int(0); hsa.hsa_amd_memory_pool_get_info(p,0,ctypes.byref(seg))
        fl=ctypes.c_uint32(0); hsa.hsa_amd_memory_pool_get_info(p,1,ctypes.byref(fl))
        if seg.value==0 and fl.value==want and pl[q] is None: pl[q]=Pool(p.handle)
        return 0
    return cb
hsa.hsa_amd_agent_iterate_memory_pools(ags["cpu"],POOL_CB(mk("cpu",0x2)),None)
hsa.hsa_amd_agent_iterate_memory_pools(ags["gpu"],POOL_CB(mk("gpu",0x4)),None)
N=4*1024*1024
h=ctypes.c_void_p(); d=ctypes.c_void_p()
hsa.hsa_amd_memory_pool_allocate(pl["cpu"],ctypes.c_size_t(N),0,ctypes.byref(h))
hsa.hsa_amd_memory_pool_allocate(pl["gpu"],ctypes.c_size_t(N),0,ctypes.byref(d))
hsa.hsa_amd_agents_allow_access(1,(Agent*1)(ags["gpu"]),None,h)
hsa.hsa_amd_agents_allow_access(1,(Agent*1)(ags["cpu"]),None,d)
# control: GENERIC async_copy, letting ROCr pick the path
hsa.hsa_amd_memory_async_copy.argtypes=[ctypes.c_void_p,Agent,ctypes.c_void_p,Agent,
    ctypes.c_size_t,ctypes.c_uint32,ctypes.c_void_p,Signal]
hsa.hsa_amd_memory_async_copy.restype=ctypes.c_int
for rot in ("generico",):
    ctypes.memset(h,0x5A,N); ctypes.memset(d,0xAB,N)
    sig=Signal(); hsa.hsa_signal_create(ctypes.c_int64(1),0,None,ctypes.byref(sig))
    r=hsa.hsa_amd_memory_async_copy(d,ags["gpu"],h,ags["cpu"],ctypes.c_size_t(N),0,None,sig)
    t0=time.perf_counter()
    while time.perf_counter()-t0<5 and hsa.hsa_signal_load_scacquire(sig)!=0: pass
    buf=ctypes.create_string_buffer(N); ctypes.memmove(buf,d,N)
    print(f"  [{rot}] SDMA={os.environ.get('HSA_ENABLE_SDMA','?')} ret={r} signal={hsa.hsa_signal_load_scacquire(sig)} "
          f"copiados={buf.raw.count(b'\x5a')}/{N} em {time.perf_counter()-t0:.2f}s")
