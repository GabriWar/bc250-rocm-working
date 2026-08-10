#!/bin/bash
# A/B of bc250_no_empty_cache: two measurements per boot, primary analysis on the first.
#
# Question: with the SDMA patch applied, does no_empty_cache still matter?
#
# Design
# ------
# Each boot yields TWO measurements, one per arm:
#
#   position 1  -> arm from the counterbalanced order  1 0 0 1 1 0
#   position 2  -> the complementary arm
#
# PRIMARY ANALYSIS: position 1 measurements only. All under the same condition --
# first GPU load of a clean boot -- so position is not a variable there.
# And the order across boots is counterbalanced, not alternating: `1 0 0 1 1 0`
# gives each arm both odd and even positions. Alternating (`1 0 1 0`) would give
# one arm all the odd ones, including the first, and on this board a boot's first
# measurement behaves differently.
#
# SECONDARY: position 2 measurements, as exploratory data. They carry the
# position effect, which was measured and is real: in the h2d_check batch, run 1
# of each boot gave 0/3 corrupted and the following ones 3/3, with ZERO page
# faults in all of them. Position within the boot is a variable of its own, not noise.
#
# Since position 2 also comes out counterbalanced (`0 1 1 0 0 1`), comparing
# primary against secondary says whether position matters for THIS measurement. If
# the same arm gives the same result in both positions, everything can be pooled.
#
# Rules inherited from the investigation (2026-08-05/06):
#   - abort if `page fault != 0`: it would measure poisoning, not the hypothesis
#   - abort if an orphan ComfyUI is left on the port: it has already masqueraded
#     as a GPU failure
#   - a valid image is validated by pixel statistics, not by existing:
#     corrupted gives std ~10 and ~2000 colors, good gives std ~75 and ~100k
# Fixed in both arms: BC250_CONV_FIX=0, BC250_WARMUP=1.
#
# Usage: run TWICE after each boot. The script figures out on its own which
# measurement and which position it is on.

H=/home/gabriwar/bc250-grimoire/ab_no_empty_cache.historico
R=/home/gabriwar/bc250-grimoire/rocm-test
ORDEM="1 0 0 1 1 0"
BOOTS=6

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

BOOT=$(cat /proc/sys/kernel/random/boot_id | cut -c1-8)
touch "$H"

# CAREFUL: `grep -c` prints the count AND returns exit 1 when it is zero.
# Writing `$(grep -c ... || echo 0)` makes the fallback fire on top, and the
# variable becomes two lines ("0\n0"), breaking every later `[ "$v" -eq ... ]`.
# This already happened here: the tests failed with "integer expected", the flow
# took the wrong branch, and the script ran the wrong arm in the wrong position.
# grep -c always prints a number, so no fallback is needed at all.
NP1=$(grep -c 'pos=1' "$H" 2>/dev/null)
JA=$(grep -c "boot=$BOOT" "$H" 2>/dev/null)

if [ "$JA" -ge 2 ]; then
    echo "  este boot ja tem 2 medidas. Reboote para o proximo."
    grep "boot=$BOOT" "$H" | sed 's/^/    /'
    exit 0
fi

if [ "$JA" -eq 0 ]; then
    POS=1
    IDX=$((NP1 + 1))
    [ "$IDX" -gt "$BOOTS" ] && { echo "  bateria completa. Rode com 'resumo'."; exit 0; }
    W=$(echo $ORDEM | cut -d' ' -f$IDX)
else
    POS=2
    # the complement of what already ran in this boot
    ANT=$(grep "boot=$BOOT" "$H" | grep -oE 'NEC=[01]' | head -1 | cut -d= -f2)
    W=$((1 - ANT))
    IDX=$(grep "boot=$BOOT" "$H" | grep -oE 'medida=[0-9]+' | head -1 | cut -d= -f2)
fi

FA=$(S dmesg | grep -ci 'page fault')
GUARD=$(cat /sys/module/amdgpu/parameters/bc250_dead_gpu_guard 2>/dev/null)
SKIP=$(cat /sys/module/amdgpu/parameters/bc250_skip_sdma0 2>/dev/null)

echo "  boot $IDX de $BOOTS   posicao $POS   NO_EMPTY_CACHE=$W   ($BOOT)"
echo "  faults=$FA  dead_gpu_guard=$GUARD  skip_sdma0=$SKIP  $(uptime -p)"

[ "$FA" != "0" ] && { echo "  ABORTADO: page fault != 0"; exit 1; }
[ "$(pgrep -cf '[m]ain.py --listen')" != "0" ] && { echo "  ABORTADO: ComfyUI orfao"; exit 1; }

cd /home/gabriwar/bc250-rocm-working/tools || exit 1
find /home/gabriwar/ComfyUI/output -name 'bc250_bench*' -delete 2>/dev/null
T0=$(date +%s)
BC250_CONV_FIX=0 BC250_WARMUP=1 BC250_NO_EMPTY_CACHE=$W \
    timeout 420 bash run_bench2.sh >/dev/null 2>&1
DT=$(($(date +%s) - T0))

IMG=$(ls /home/gabriwar/ComfyUI/output/bc250_bench_*.png 2>/dev/null | wc -l)
LINHA=$(grep -E '^(FIM|FALHOU)' "$R/bench2.result" 2>/dev/null | head -1)

PIX=$(python3 - <<'PY' 2>/dev/null
from PIL import Image
import numpy as np, glob, os
fs = sorted(glob.glob('/home/gabriwar/ComfyUI/output/bc250_bench_*.png'))
if not fs:
    print("sem-imagem")
else:
    print(" ".join(
        f"{os.path.getsize(f)//1024}KB/std{np.array(Image.open(f).convert('RGB')).std():.1f}"
        f"/{len(np.unique(np.array(Image.open(f).convert('RGB')).reshape(-1,3),axis=0))}cores"
        for f in fs))
PY
)

VER="FALHOU"
[ "$IMG" -ge 2 ] && echo "$PIX" | grep -qE 'std(4[0-9]|[5-9][0-9]|[0-9]{3})' && VER="OK"

echo "medida=$IDX pos=$POS boot=$BOOT NEC=$W $VER ${DT}s img=$IMG | $LINHA | $PIX" >> "$H"
sync
tail -1 "$H" | sed 's/^/  /'

for p in $(pgrep -f '[m]ain.py --listen'); do kill -9 "$p" 2>/dev/null; done

echo
echo "  faults depois: $(S dmesg | grep -ci 'page fault')"
S dmesg | grep -i 'BC-250: GPU' | tail -2 | sed 's/^/  GUARDA: /'
echo
if [ "$POS" = "1" ]; then
    echo "  agora rode DE NOVO neste mesmo boot para a posicao 2 (NEC=$((1 - W)))"
else
    echo "  boot $IDX completo. Reboote para o boot $((IDX + 1)) de $BOOTS."
fi
