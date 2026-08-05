#!/bin/bash
ulimit -c 0
set -u
R=/home/gabriwar/bc250-grimoire/rocm-test
L=$R/comfy-multigen.log
: > "$L"
source /etc/profile.d/bc250-rocm.sh
cd /home/gabriwar/ComfyUI
./venv-gfx1013/bin/python main.py --listen 127.0.0.1 --port 8188 --cpu-vae >>"$L" 2>&1 &
PID=$!
for i in $(seq 1 240); do
  grep -q "To see the GUI" "$L" && break
  kill -0 $PID 2>/dev/null || { echo "### MORREU NO BOOT ###" >>"$L"; exit 1; }
  sleep 1
done
grep -q "To see the GUI" "$L" || { echo "### NAO SUBIU ###" >>"$L"; exit 1; }
MARK=$(wc -l < "$L")
echo "### SERVIDOR OK (MARK=$MARK) ###" >>"$L"

# enfileira 5 geracoes com seeds distintos
for s in 101 202 303 404 505; do
  python3 -c "
import json,sys
w=json.load(open('$R/wf2.json'))
w['prompt']['5']['inputs']['seed']=$s
w['prompt']['7']['inputs']['filename_prefix']='bc250_multi_$s'
print(json.dumps(w))" > /tmp/wf_$s.json
  curl -s -X POST -H 'Content-Type: application/json' -d @/tmp/wf_$s.json \
       http://127.0.0.1:8188/prompt >/dev/null 2>&1
  echo "### ENFILEIRADO seed=$s ###" >>"$L"
done

# espera as 5 terminarem (ou falha)
for i in $(seq 1 600); do
  N=$(ls /home/gabriwar/ComfyUI/output/bc250_multi_*.png 2>/dev/null | wc -l)
  [ "$N" -ge 5 ] && { echo "### 5 IMAGENS PRONTAS ###" >>"$L"; break; }
  TAIL=$(tail -n +$((MARK+1)) "$L")
  echo "$TAIL" | grep -qiE "Memory access fault|aborting with error" && { echo "### FALHA GPU ###" >>"$L"; break; }
  kill -0 $PID 2>/dev/null || { echo "### MORREU ###" >>"$L"; break; }
  sleep 3
done
echo "### FIM ###" >>"$L"
sleep 2
for p in $(/usr/bin/pgrep -f "[m]ain.py --listen"); do kill -9 "$p" 2>/dev/null; done
