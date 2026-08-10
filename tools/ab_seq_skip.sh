#!/bin/bash
# Focused A/B: the sequence counter skips half the TLB invalidations.
# Does that matter?
#
# What is measured
# ----------------
# amdgpu_vm_flush_compute_tlb() drops the flush when kfd_last_flushed_seq is
# already equal to tlb_seq. With bc250_tlb_trace=1 we measured the real ratio on
# this board: 20 SKIPPED to 20 FLUSH -- half the requested invalidations never
# happen. So the knob has leverage, and the A/B is not empty.
#
#   arm A (default)         no_seq_skip=0   half the flushes dropped
#   arm B (more flushing)   no_seq_skip=1   none dropped
#
# Why now, and not before
# -----------------------
# 85 of 87 offsets where the corruption BEGINS are exact multiples of 2 MiB --
# the large-page granularity, the same incr=2097152 as the PTEs. Page-aligned
# corruption is not a race; it is a whole page mapped wrong. The reading that
# fits is a stale TLB entry for a 2 MiB page.
#
# Reading the result
# ------------------
#   B < A   stale TLB entry: flushing more solves it, and the defect is an
#           invalidation that does not arrive
#   B > A   the Navi 1x erratum: a flush concurrent with translation IS the
#           danger, and flushing more makes it worse
#   B = A   neither one; the defect is not in the invalidation path
#
# Design: counterbalanced order in blocks of 4 (A B B A), never alternating --
# on this board a boot's first GPU load differs from the following ones, and
# alternating would give one arm all the odd positions.
#
# Metric: blocks clobbered per run (0..12), not just dirty/clean. A count has
# more statistical power than a binary at the N we can afford to run.

set -u
P=/sys/module/amdgpu/parameters
REPS=${1:-10}                       # runs PER ARM
LOG=/home/gabriwar/bc250-grimoire/ab_seq_skip.historico
REPRO=/home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

for k in bc250_tlb_no_seq_skip bc250_tlb_trace; do
    [ -e "$P/$k" ] || { echo "ABORTADO: $P/$k nao existe -- modulo sem instrumentacao"; exit 1; }
done

set_arm() {   # $1 = 0 or 1
    S sh -c "echo $1 > $P/bc250_tlb_no_seq_skip"
    LIDO=$(cat "$P/bc250_tlb_no_seq_skip")
    [ "$LIDO" = "$1" ] || { echo "ABORTADO: pedi $1, modulo ficou $LIDO"; exit 1; }
}

BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)
echo "boot=$BOOT reps=$REPS por braco  inicio=$(date '+%H:%M:%S')" | tee -a "$LOG"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh 2>/dev/null

ORDEM=""
for _ in $(seq 1 "$REPS"); do ORDEM="$ORDEM A B B A"; done

i=0
for BRACO in $ORDEM; do
    i=$((i + 1))
    [ "$i" -gt $((REPS * 2)) ] && break
    case "$BRACO" in
        A) set_arm 0 ;;
        B) set_arm 1 ;;
    esac

    FA=$(S dmesg | grep -ci 'page fault')
    OUT=$(timeout 600 ./venv-gfx1013/bin/python "$REPRO" 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+$')
    FD=$(S dmesg | grep -ci 'page fault')
    [ -z "$N" ] && N="ERRO"

    echo "exec=$i braco=$BRACO pisados=$N faults=$FA->$FD boot=$BOOT" | tee -a "$LOG"

    # if the GPU started faulting, stop: the data from there on is worthless
    if [ "$FD" -gt "$FA" ]; then
        echo "  AVISO: page fault durante a execucao $i -- resultados seguintes suspeitos" | tee -a "$LOG"
    fi
done

set_arm 0

echo "---- resumo (boot $BOOT) ----" | tee -a "$LOG"
for BRACO in A B; do
    L=$(grep "boot=$BOOT" "$LOG" | grep "braco=$BRACO ")
    T=$(echo "$L" | grep -c 'pisados=')
    DET=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
    SUJOS=$(echo "$L" | grep -cE 'pisados=[1-9]')
    TOT=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | awk '{s+=$1} END{print s+0}')
    NOME=$([ "$BRACO" = "A" ] && echo "padrao (metade pulada)" || echo "no_seq_skip=1 (nenhuma pulada)")
    printf '  %-30s %s/%s execucoes sujas   %s blocos no total   [%s]\n' \
        "$NOME" "$SUJOS" "$T" "$TOT" "$DET" | tee -a "$LOG"
done
echo "fim=$(date '+%H:%M:%S')" | tee -a "$LOG"
