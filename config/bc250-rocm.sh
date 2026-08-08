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

export TORCH_BLAS_PREFER_HIPBLASLT=0   # hipBLASLt nao tem kernels gfx1013

# MKL: torch linkado contra .so.2, sistema tem .so.3.
# ldconfig nao resolve (indexa por SONAME), entao vai por caminho.
_m=/home/gabriwar/ComfyUI/venv-gfx1013/mkl-compat
[ -d "$_m" ] && export LD_LIBRARY_PATH="${_m}:/opt/intel/oneapi/mkl/latest/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
unset _m

# --- REMOVIDAS em 2026-08-08, com medicao (ver docs/27) ---
#
#   HIP_LAUNCH_BLOCKING=1  AMD_SERIALIZE_KERNEL=3  AMD_SERIALIZE_COPY=3
#   AMD_DIRECT_DISPATCH=0  GPU_MAX_HW_QUEUES=1
#
# A doc dizia "ainda NECESSARIA: sem ela, 1 falha em 3 rodadas". Testado com o
# defeito EXPOSTO (bc250_flush_by_runlist=0), que e a unica condicao onde a
# pergunta tem resposta:
#
#   com as flags: 3 rodadas, 2 corrompidas, 35 tensores pisados
#   sem as flags: 3 rodadas, 3 corrompidas, 25 tensores pisados, 1 crash
#
# Corrompe dos dois lados, na mesma ordem de grandeza. Nao protegem.
# Com o patch de runlist ligado: 16 rodadas, 0 corrompidas, dos dois lados.
# Quem segura esta placa e o runlist, nao a serializacao.
#
# Nao aceleram nem desaceleram carga real: cyberrealistic hires, n=3,
# 111,9s com contra 107,5s sem, com dispersao de 25s dentro de cada braco.
# (Um microbenchmark de kernel minusculo mostrava 2,7x, mas ali o que domina e
# overhead de dispatch, que some quando a GPU esta de fato ocupada.)
