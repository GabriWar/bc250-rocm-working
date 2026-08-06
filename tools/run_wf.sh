#!/bin/bash
# Roda um workflow arbitrario no ComfyUI e reporta tempo, erro e estatistica de
# pixel. Generalizacao do run_alvo.sh, que tinha o workflow fixo.
#
# Imagem valida e validada por estatistica, nao por existir: corrompida da
# std ~10 e ~2000 cores, boa da std ~75 e ~100k.
set -u
WF=${1:?workflow json}; VAE=${2:-auto}; WARM=${3:-0}; ALLOC=${4:-exp}; UNET=${5:-auto}
R=/home/gabriwar/bc250-grimoire/rocm-test; L=$R/wf.log
: > "$L"
source /etc/profile.d/bc250-rocm.sh
export BC250_CONV_FIX=${BC250_CONV_FIX:-1} BC250_WARMUP=$WARM
[ "$ALLOC" = "exp" ] && export PYTORCH_HIP_ALLOC_CONF=expandable_segments:True || unset PYTORCH_HIP_ALLOC_CONF
case "$VAE" in auto) F="" ;; cpu) F=--cpu-vae ;; *) F=--${VAE}-vae ;; esac
# --fp16-unet tem prioridade absoluta em unet_dtype(): retorna torch.float16
# antes de qualquer heuristica, ignorando o supported_inference_dtypes do
# modelo. O Z-Image declara [bfloat16, float32] e esta placa nao tem bf16.
case "$UNET" in auto) ;; *) F="$F --${UNET}-unet" ;; esac
echo "  wf=$(basename $WF) vae=$VAE unet=$UNET warmup=$WARM alloc=$ALLOC"

cd /home/gabriwar/ComfyUI || exit 1
./venv-gfx1013/bin/python main.py --listen 127.0.0.1 --port 8188 $F >>"$L" 2>&1 &
PID=$!
for i in $(seq 1 300); do
    grep -q "To see the GUI" "$L" && break
    kill -0 $PID 2>/dev/null || { echo "  MORREU_NO_BOOT"; tail -15 "$L" | sed 's/^/    /'; exit 1; }
    sleep 1
done
grep -q "To see the GUI" "$L" || { echo "  NAO_SUBIU"; tail -15 "$L" | sed 's/^/    /'; kill -9 $PID; exit 1; }

find /home/gabriwar/ComfyUI/output -name 'bc250_zimage*' -delete 2>/dev/null
python3 -c "
import json,sys
w=json.load(open('$WF'))
print(json.dumps({'prompt': w.get('prompt', w)}))" > "$R/_wf_run.json"
# So olhar o log a partir daqui: o boot do ComfyUI ja imprime
# "Failed to import comfy_kitchen" e "No module named torchaudio", que sao
# ruido conhecido e faziam o detector abortar em 0.0s sem esperar a imagem.
BASE=$(wc -l < "$L")
T0=$(date +%s.%N)
curl -s -X POST -H 'Content-Type: application/json' -d @"$R/_wf_run.json" \
     http://127.0.0.1:8188/prompt 2>&1 | head -c 300 | sed 's/^/    resposta: /'
echo
ERRO=""
for i in $(seq 1 900); do
    ls /home/gabriwar/ComfyUI/output/bc250_zimage*.png >/dev/null 2>&1 && break
    NOVO=$(tail -n +$((BASE+1)) "$L" 2>/dev/null | grep -iE 'Traceback|Error|illegal memory|HSA_STATUS|out of memory|INTERNAL_ERROR' \
           | grep -viE 'comfy_kitchen|torchaudio|fp8 and fp4')
    if [ -n "$NOVO" ]; then
        ERRO=$(echo "$NOVO" | head -3 | tr '\n' '|')
        break
    fi
    kill -0 $PID 2>/dev/null || { ERRO="processo morreu"; break; }
    sleep 1
done
DT=$(python3 -c "print(f'{$(date +%s.%N)-$T0:.1f}')")
if [ -n "$ERRO" ]; then
    echo "  FALHOU em ${DT}s"
    echo "$ERRO" | fold -w 110 | sed 's/^/    /'
    echo "  --- log ---"; tail -25 "$L" | sed 's/^/    /'
else
    echo "  OK em ${DT}s"
    python3 -c "
from PIL import Image; import numpy as np, glob
f=sorted(glob.glob('/home/gabriwar/ComfyUI/output/bc250_zimage*.png'))
a=np.array(Image.open(f[0]).convert('RGB'))
print(f'    {f[0].split(\"/\")[-1]}  std={a.std():.1f} cores={len(np.unique(a.reshape(-1,3),axis=0))}')" 2>/dev/null
fi
kill -9 $PID 2>/dev/null
for p in $(pgrep -f '[m]ain.py --listen'); do kill -9 "$p" 2>/dev/null; done
