# BC-250 (gfx1013) — ROCm/HIP runtime
# Config validada 2026-08-04: 400 tensores / 1218 MB em 2.0s, zero page fault.
# Descoberta no Discord da comunidade (neoney, anrp, wtfuzz).

# Limiar a partir do qual o ROCr usa memoria pinned na transferencia.
# SEM isto: trava carregando modelo ("layer loading hanging").
export GPU_PINNED_MIN_XFER_SIZE=16384

# SDMA esta quebrado para host<->VRAM nesta placa (anrp).
# ATENCAO: a doc antiga dizia =1. Estava ERRADO. Todos que fizeram
# funcionar usam =0.
export HSA_ENABLE_SDMA=0

export AMD_DIRECT_DISPATCH=0
export GPU_MAX_HW_QUEUES=1
export TORCH_BLAS_PREFER_HIPBLASLT=0   # hipBLASLt nao tem kernels gfx1013

# MKL: torch linkado contra .so.2, sistema tem .so.3.
# ldconfig nao resolve (indexa por SONAME), entao vai por caminho.
_m=/home/gabriwar/ComfyUI/venv-gfx1013/mkl-compat
[ -d "$_m" ] && export LD_LIBRARY_PATH="${_m}:/opt/intel/oneapi/mkl/latest/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
unset _m

# Serializacao: ainda NECESSARIA. Sem ela: 1 falha em 3 rodadas (2026-08-04).
# Fecha a janela da corrida do sinal EOP do MEC. Custa paralelismo.
export HIP_LAUNCH_BLOCKING=1
export AMD_SERIALIZE_KERNEL=3
export AMD_SERIALIZE_COPY=3
