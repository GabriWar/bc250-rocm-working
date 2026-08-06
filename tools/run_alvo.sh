#!/bin/bash
# ComfyUI na configuracao que a gente QUER: VAE na GPU e sem warmup.
#
# Contexto
# --------
# O VAE na GPU e o warmup nao sao dois problemas, sao o mesmo. O VAE funciona
# sozinho na GPU (262 modulos, 512px, zero faults) e a GEMM que ele usa funciona
# isolada (6,22 TFLOP/s). Ele so falha DENTRO do pipeline, depois de outro
# trabalho pesado de GPU -- que e exatamente a condicao de gatilho do aliasing
# documentado em docs/17. O HIPBLAS_STATUS_INTERNAL_ERROR e o rocBLAS achando as
# proprias estruturas internas estragadas.
#
# A aposta aqui e o alocador: o gatilho exige alocacao e execucao de kernel
# INTERCALADAS (so alocacao 0/3, so kernel 0/3, as duas 3/3). Com
# expandable_segments o PyTorch reserva uma faixa virtual grande e cresce dentro
# dela por VMM, em vez de mapear e desmapear blocos o tempo todo.
#
# Medido no reprodutor: 4/4 sujas sem, 1/4 com. Mas aquele teste aloca os blocos
# com hipMalloc cru, fora do alocador do PyTorch -- entao la o expandable_segments
# so afetou o aquecimento. No ComfyUI TUDO passa pelo alocador, entao o efeito
# pode ser bem maior. Ou nenhum. E o que este script mede.
#
# Uso: run_alvo.sh <vae> <warmup> <alloc>
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
        # imagem valida por estatistica de pixel, nao por existir:
        # corrompida da std ~10 e ~2000 cores, boa da std ~75 e ~100k
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
