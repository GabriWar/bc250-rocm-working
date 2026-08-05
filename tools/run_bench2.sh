#!/bin/bash
ulimit -c 0
set -u
R=/home/gabriwar/bc250-grimoire/rocm-test
L=$R/bench2.log
RES=$R/bench2.result
: > "$L"; : > "$RES"
source /etc/profile.d/bc250-rocm.sh
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
  # espera essa imagem aparecer
  for i in $(seq 1 400); do
    ls /home/gabriwar/ComfyUI/output/bc250_bench_${s}_*.png >/dev/null 2>&1 && break
    kill -0 $PID 2>/dev/null || break
    sleep 1
  done
  T1=$(date +%s.%N)
  if ls /home/gabriwar/ComfyUI/output/bc250_bench_${s}_*.png >/dev/null 2>&1; then
    echo "FIM seed=$s $T1 wall=$(python3 -c "print(f'{$T1-$T0:.2f}')")" >>"$RES"
  else
    echo "FALHOU seed=$s" >>"$RES"; break
  fi
done
echo "TERMINADO" >>"$RES"
for p in $(/usr/bin/pgrep -f "[m]ain.py --listen"); do kill -9 "$p" 2>/dev/null; done
