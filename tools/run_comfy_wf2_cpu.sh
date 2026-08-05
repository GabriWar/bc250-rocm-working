#!/bin/bash
ulimit -c 0   # coredump pos-fault de GPU trava a maquina
set -u
R=/home/gabriwar/bc250-grimoire/rocm-test
L=$R/comfy-wf2-cpuvae.log
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
grep -q "To see the GUI" "$L" || { echo "### SERVIDOR NAO SUBIU ###" >>"$L"; exit 1; }

MARK=$(wc -l < "$L")          # so olhamos DEPOIS daqui
echo "### SERVIDOR OK, enfileirando (MARK=$MARK) ###" >>"$L"
curl -s -X POST -H 'Content-Type: application/json' -d @"$R/wf2.json" \
     http://127.0.0.1:8188/prompt >>"$L" 2>&1
echo "" >> "$L"

for i in $(seq 1 400); do
  if ls /home/gabriwar/ComfyUI/output/bc250_elaborado*.png >/dev/null 2>&1; then
    echo "### IMAGEM GERADA ###" >>"$L"; break; fi
  TAIL=$(tail -n +$((MARK+1)) "$L")
  if echo "$TAIL" | grep -qiE "Memory access fault|aborting with error|HSA_STATUS_ERROR"; then
    echo "### FALHA GPU ###" >>"$L"; break; fi
  if echo "$TAIL" | grep -qiE "Exception during processing|HIPBLAS_STATUS|out of memory|illegal memory"; then
    echo "### ERRO NA GERACAO ###" >>"$L"; break; fi
  kill -0 $PID 2>/dev/null || { echo "### PROCESSO MORREU ###" >>"$L"; break; }
  sleep 3
done
echo "### FIM (loop=$i) ###" >>"$L"
sleep 2
for p in $(/usr/bin/pgrep -f "[m]ain.py --listen"); do kill -9 "$p" 2>/dev/null; done
