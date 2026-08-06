#!/bin/bash
ulimit -c 0
set -u
R=/home/gabriwar/bc250-grimoire/rocm-test
L=$R/bench2.log
RES=$R/bench2.result
: > "$L"; : > "$RES"
source /etc/profile.d/bc250-rocm.sh
export BC250_CONV_FIX=${BC250_CONV_FIX:-1}
cd /home/gabriwar/ComfyUI
./venv-gfx1013/bin/python main.py --listen 127.0.0.1 --port 8188 --cpu-vae >>"$L" 2>&1 &
PID=$!
for i in $(seq 1 240); do
  grep -q "To see the GUI" "$L" && break
  kill -0 $PID 2>/dev/null || { echo "MORREU_NO_BOOT" >>"$RES"; exit 1; }
  sleep 1
done
grep -q "To see the GUI" "$L" || { echo "NAO_SUBIU" >>"$RES"; exit 1; }
echo "SERVIDOR_OK $(date +%s.%N)" >>"$RES"

for s in 111 222; do
  python3 -c "
import json
w=json.load(open('$R/wf2.json'))
w['prompt']['5']['inputs']['seed']=$s
w['prompt']['7']['inputs']['filename_prefix']='bc250_bench_$s'
print(json.dumps(w))" > /tmp/wfb_$s.json
  T0=$(date +%s.%N)
  echo "INICIO seed=$s $T0" >>"$RES"
  curl -s -X POST -H 'Content-Type: application/json' -d @/tmp/wfb_$s.json \
       http://127.0.0.1:8188/prompt >/dev/null 2>&1
  # Espera a imagem aparecer OU o erro de GPU no log.
  #
  # Antes isto so olhava o arquivo de saida e esperava os 400 segundos inteiros.
  # Numa configuracao que falha por erro de GPU o erro aparece no log em menos de
  # um minuto, entao cada falha custava ~7 minutos de relogio a toa. Numa bateria
  # A/B de varias rodadas isso vira meia hora parada. Agora sai assim que houver
  # veredito, nos dois sentidos.
  ERRO=""
  for i in $(seq 1 400); do
    ls /home/gabriwar/ComfyUI/output/bc250_bench_${s}_*.png >/dev/null 2>&1 && break
    if grep -qiE 'illegal memory access|hipErrorIllegalAddress|AcceleratorError|HSA_STATUS_ERROR|out of memory' "$L" 2>/dev/null; then
      ERRO=$(grep -ioE 'illegal memory access|hipErrorIllegalAddress|AcceleratorError|HSA_STATUS_ERROR[A-Z_]*|out of memory' "$L" 2>/dev/null | head -1)
      break
    fi
    kill -0 $PID 2>/dev/null || { ERRO="processo morreu"; break; }
    sleep 1
  done
  T1=$(date +%s.%N)
  W=$(python3 -c "print(f'{$T1-$T0:.2f}')")
  if ls /home/gabriwar/ComfyUI/output/bc250_bench_${s}_*.png >/dev/null 2>&1; then
    echo "FIM seed=$s $T1 wall=$W" >>"$RES"
  else
    echo "FALHOU seed=$s wall=$W motivo=${ERRO:-timeout}" >>"$RES"; break
  fi
done
echo "TERMINADO" >>"$RES"
for p in $(/usr/bin/pgrep -f "[m]ain.py --listen"); do kill -9 "$p" 2>/dev/null; done
