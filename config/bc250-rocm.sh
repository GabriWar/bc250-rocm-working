# BC-250 (gfx1013) — ROCm/HIP runtime
# Config validated 2026-08-04: 400 tensors / 1218 MB in 2.0s, zero page faults.
# Discovered on the community Discord (neoney, anrp, wtfuzz).

# Threshold above which ROCr uses pinned memory for the transfer.
# WITHOUT this: hangs while loading the model ("layer loading hanging").
export GPU_PINNED_MIN_XFER_SIZE=16384

# SDMA is broken for host<->VRAM on this board (anrp).
# WARNING: the old docs said =1. That was WRONG. Everyone who got it
# working uses =0.
export HSA_ENABLE_SDMA=0

export TORCH_BLAS_PREFER_HIPBLASLT=0   # hipBLASLt has no gfx1013 kernels

# MKL: torch is linked against .so.2, the system has .so.3.
# ldconfig does not resolve it (it indexes by SONAME), so go by path.
_m=/home/gabriwar/ComfyUI/venv-gfx1013/mkl-compat
[ -d "$_m" ] && export LD_LIBRARY_PATH="${_m}:/opt/intel/oneapi/mkl/latest/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
unset _m

# --- REMOVED on 2026-08-08, with measurements (see docs/27) ---
#
#   HIP_LAUNCH_BLOCKING=1  AMD_SERIALIZE_KERNEL=3  AMD_SERIALIZE_COPY=3
#   AMD_DIRECT_DISPATCH=0  GPU_MAX_HW_QUEUES=1
#
# The docs said "still REQUIRED: without it, 1 failure in 3 runs". Tested with the
# defect EXPOSED (bc250_flush_by_runlist=0), which is the only condition where the
# question has an answer:
#
#   with the flags: 3 runs, 2 corrupted, 35 tensors clobbered
#   without them:   3 runs, 3 corrupted, 25 tensors clobbered, 1 crash
#
# It corrupts on both sides, in the same order of magnitude. They do not protect.
# With the runlist patch enabled: 16 runs, 0 corrupted, on both sides.
# What holds this board together is the runlist, not the serialization.
#
# They neither speed up nor slow down a real workload: cyberrealistic hires, n=3,
# 111.9s with against 107.5s without, with 25s spread inside each arm.
# (A tiny kernel microbenchmark showed 2.7x, but there what dominates is
# dispatch overhead, which disappears once the GPU is actually busy.)
