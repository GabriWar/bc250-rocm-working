#!/bin/bash
# Is the L2's PAGE TABLE LINE cache the one delivering the wrong translation?
#
# What this test decides
# ----------------------
# The VA->PA path inside the GPU has TWO caches, and until now they were treated
# as one:
#
#   VA -> UTCL1/UTCL2 ....... cache of finished TRANSLATIONS          [TLB]
#          -> miss -> walker
#              -> reads PDE1/PDE0/PTE from memory
#                  -> those reads go through the TABLE LINE cache in the L2
#                      -> PA
#
# FORCE_MISS kills ONLY the lower one: it forces the walker to re-read the entry
# from memory on every translation. The TLB is untouched. So the result localizes
# the breakage:
#   rate drops to ~0  -> the walker was reading a wrong table line. The breakage
#                        is in the PDE/PTE fetch: below the TLB, above memory.
#   rate unchanged    -> the walker's fetch is fine. That leaves the TLB: a stale
#                        VA->PA entry or a colliding tag, above the walker.
#
# The lower side is already closed by an earlier measurement (doc 17): data read
# directly at the physical address, with no VA at all, is correct. So "below
# memory" is not a candidate, and the two halves above are the only ones left.
#
# Why arm C exists
# ----------------
# Our pages are 2 MiB, i.e. BIGK. Arm C enables only
# L2_CACHE_4K_FORCE_MISS, which does NOT touch our pages. If the corruption also
# disappears in C, then nothing was fixed -- only the timing changed, and the
# optimistic reading of the other arms dies before becoming a conclusion. Without
# that control the test is worthless.
#
# Usage
# -----
# This test CANNOT be run as an A/B in the same boot: the parameters are 0444,
# read only at init. Each arm is a boot with a different command line.
#
#   ab_l2_force_miss.sh <reps>     measures the arm matching the CURRENT cmdline
#
# Arms, in the order they should be run:
#
#   A  (no parameter)                        base, expected ~7/10 dirty
#   B  amdgpu.bc250_l2_force_miss=7          sledgehammer: 4K + BIGK + PDE
#   C  amdgpu.bc250_l2_force_miss=1          NEGATIVE CONTROL: 4K only
#   D  amdgpu.bc250_l2_force_miss=2          BIGK only, the one that really matters
#   E  amdgpu.bc250_l2_pde0_tag_mode=1       tag collision, zero cost
#
# Reading:
#   B clean, C dirty  -> the page table cache is the cause. Move on to D and E.
#   B clean, C clean  -> timing artifact. Nothing proven, hypothesis unsupported.
#   B dirty           -> the hypothesis dies here. The target moves up to the TLB.

set -u
REPS=${1:-10}
LOG=/home/gabriwar/bc250-grimoire/ab_l2_force_miss.historico
REPRO=/home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

P=/sys/module/amdgpu/parameters
for k in bc250_l2_force_miss bc250_l2_pde0_tag_mode bc250_l2_disable_bigk_opt; do
    [ -e "$P/$k" ] || { echo "ABORTADO: $P/$k nao existe -- modulo antigo"; exit 1; }
done

FM=$(cat $P/bc250_l2_force_miss)
TM=$(cat $P/bc250_l2_pde0_tag_mode)
BK=$(cat $P/bc250_l2_disable_bigk_opt)

case "$FM:$TM:$BK" in
    0:-1:0) BRACO="A base" ;;
    7:-1:0) BRACO="B marreta(4K+BIGK+PDE)" ;;
    1:-1:0) BRACO="C CONTROLE-NEGATIVO(so 4K)" ;;
    2:-1:0) BRACO="D so-BIGK" ;;
    0:1:0)  BRACO="E tag_mode=1" ;;
    *)      BRACO="? fm=$FM tm=$TM bk=$BK" ;;
esac

# the driver only prints the confirmation line when some knob is enabled
CONFIRMA=$(S dmesg | grep -c 'BC-250 L2/')
BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)

echo "" | tee -a "$LOG"
echo "boot=$BOOT braco=$BRACO fm=$FM tm=$TM bk=$BK reps=$REPS inicio=$(date '+%H:%M:%S')" | tee -a "$LOG"
if [ "$FM" != "0" ] && [ "$CONFIRMA" = "0" ]; then
    echo "  ABORTADO: force_miss=$FM mas o driver nao imprimiu 'BC-250 L2/'." | tee -a "$LOG"
    echo "  O parametro nao chegou ao init -- nada depois disto valeria." | tee -a "$LOG"
    exit 1
fi
S dmesg | grep 'BC-250 L2/' | tail -2 | sed 's/^/  /' | tee -a "$LOG"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh 2>/dev/null

saude() { S dmesg | grep -ciE 'ring .* timeout|ring reset|coredump|Timeout waiting for VM flush'; }

for i in $(seq 1 "$REPS"); do
    HA=$(saude)
    OUT=$(timeout 600 ./venv-gfx1013/bin/python "$REPRO" 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+$')
    HD=$(saude)
    [ -z "$N" ] && N="ERRO"
    echo "exec=$i braco=$BRACO pisados=$N saude=$HA->$HD boot=$BOOT" | tee -a "$LOG"
    if [ "$HD" -gt "$HA" ]; then
        echo "  ABORTADO na execucao $i: a placa registrou timeout/reset." | tee -a "$LOG"
        exit 2
    fi
done

L=$(grep "boot=$BOOT" "$LOG" | grep 'pisados=')
T=$(echo "$L" | grep -c 'pisados=')
SUJOS=$(echo "$L" | grep -cE 'pisados=[1-9]')
TOT=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | awk '{s+=$1} END{print s+0}')
DET=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
echo "---- $BRACO: $SUJOS/$T execucoes sujas, $TOT blocos no total  [$DET]" | tee -a "$LOG"
echo "fim=$(date '+%H:%M:%S')" | tee -a "$LOG"
