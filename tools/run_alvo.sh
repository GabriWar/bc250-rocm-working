#!/bin/bash
# ComfyUI in the configuration we WANT: VAE on the GPU and no warmup.
#
# Context
# -------
# The VAE on the GPU and the warmup are not two problems, they are the same one.
# The VAE works on its own on the GPU (262 modules, 512px, zero faults) and the
# GEMM it uses works in isolation (6.22 TFLOP/s). It only fails INSIDE the
# pipeline, after other heavy GPU work -- which is exactly the trigger condition
# of the aliasing documented in docs/17. HIPBLAS_STATUS_INTERNAL_ERROR is rocBLAS
# finding its own internal structures mangled.
#
# The bet here is the allocator: the trigger requires allocation and kernel
# execution INTERLEAVED (allocation only 0/3, kernel only 0/3, both 3/3). With
# expandable_segments PyTorch reserves a large virtual range and grows inside it
# via VMM, instead of mapping and unmapping blocks all the time.
#
# Measured in the reproducer: 4/4 dirty without, 1/4 with. But that test allocates
# the blocks with raw hipMalloc, outside PyTorch's allocator -- so there
# expandable_segments only affected the warmup. In ComfyUI EVERYTHING goes through
# the allocator, so the effect may be much larger. Or none. That is what this
# script measures.
# Usage: run_alvo.sh <vae> <warmup> <alloc>
#   vae     cpu | fp16 | fp32 | bf16
#   warmup  0 | 1
#   alloc   pad | exp
set -u
R=/home/gabriwar/bc250-grimoire/rocm-test
mkdir -p "$R"
VAE=${1:-fp16}; WARM=${2:-0}; ALLOC=${3:-exp}
L=$R/alvo.log; RES=$R/alvo.result
: > "$L"

source /etc/profile.d/bc250-rocm.sh
export BC250_CONV_FIX=${BC250_CONV_FIX:-1}
export BC250_WARMUP=$WARM
[ "$ALLOC" = "exp" ] && export PYTORCH_HIP_ALLOC_CONF=expandable_segments:True \
                     || unset PYTORCH_HIP_ALLOC_CONF

case "$VAE" in
  cpu)  FLAG=--cpu-vae ;;
  fp16) FLAG=--fp16-vae ;;
  fp32) FLAG=--fp32-vae ;;
  bf16) FLAG=--bf16-vae ;;
esac

echo "cfg vae=$VAE warmup=$WARM alloc=$ALLOC flag=$FLAG" | tee -a "$RES"

cd /home/gabriwar/ComfyUI || exit 1
./venv-gfx1013/bin/python main.py --listen 127.0.0.1 --port 8188 $FLAG >>"$L" 2>&1 &
PID=$!
for i in $(seq 1 240); do
    grep -q "To see the GUI" "$L" && break
    kill -0 $PID 2>/dev/null || { echo "  MORREU_NO_BOOT"; exit 1; }
    sleep 1
done
grep -q "To see the GUI" "$L" || { echo "  NAO_SUBIU"; kill -9 $PID 2>/dev/null; exit 1; }

find /home/gabriwar/ComfyUI/output -name 'bc250_alvo*' -delete 2>/dev/null
OK=0; FALHOU=0
for s in 111 222; do
    python3 -c "
import json
w=json.load(open('$R/wf2.json'))
w['prompt']['5']['inputs']['seed']=$s
w['prompt']['7']['inputs']['filename_prefix']='bc250_alvo_$s'
print(json.dumps(w))" > "$R/wf_alvo_$s.json"
    T0=$(date +%s.%N)
    curl -s -X POST -H 'Content-Type: application/json' -d @"$R/wf_alvo_$s.json" \
         http://127.0.0.1:8188/prompt >/dev/null 2>&1
    ERRO=""
    for i in $(seq 1 400); do
        ls /home/gabriwar/ComfyUI/output/bc250_alvo_${s}_*.png >/dev/null 2>&1 && break
        if grep -qiE 'illegal memory access|hipErrorIllegalAddress|AcceleratorError|HSA_STATUS_ERROR|out of memory|INTERNAL_ERROR' "$L" 2>/dev/null; then
            ERRO=$(grep -ioE 'illegal memory access|hipErrorIllegalAddress|AcceleratorError|HSA_STATUS_ERROR[A-Z_]*|out of memory|[A-Z_]*INTERNAL_ERROR' "$L" | head -1)
            break
        fi
        kill -0 $PID 2>/dev/null || { ERRO="processo morreu"; break; }
        sleep 1
    done
    DT=$(python3 -c "print(f'{$(date +%s.%N)-$T0:.1f}')")
    if [ -n "$ERRO" ]; then
        echo "  seed=$s FALHOU em ${DT}s: $ERRO" | tee -a "$RES"; FALHOU=$((FALHOU+1))
    else
        # image valid by pixel statistics, not by existing:
        # corrupted gives std ~10 and ~2000 colors, good gives std ~75 and ~100k
        PIX=$(python3 -c "
from PIL import Image; import numpy as np, glob
f=sorted(glob.glob('/home/gabriwar/ComfyUI/output/bc250_alvo_${s}_*.png'))
a=np.array(Image.open(f[0]).convert('RGB'))
print(f'std={a.std():.1f} cores={len(np.unique(a.reshape(-1,3),axis=0))}')" 2>/dev/null)
        echo "  seed=$s OK em ${DT}s  $PIX" | tee -a "$RES"; OK=$((OK+1))
    fi
done
kill -9 $PID 2>/dev/null
for p in $(pgrep -f '[m]ain.py --listen'); do kill -9 "$p" 2>/dev/null; done
echo "  resultado: $OK ok, $FALHOU falhas" | tee -a "$RES"
