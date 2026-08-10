#!/bin/bash
# A/B of the TLB invalidation diagnostic knobs against the page table aliasing
# reproducer (tools/hipmalloc_cru.py).
#
# What is measured
# ----------------
# Two live hipMalloc allocations, distinct BOs in /proc/pid/maps, that the GPU
# sees as the same memory. The CPU writes and reads both ranges with no
# divergence. Reproduces in 6 of 6 runs; requires allocation and kernel execution
# interleaved, each half alone gives 0 of 3.
#
# The knobs
# ---------
#   all_hub      also invalidates the MMHUB. Cyan Skillfish is an APU but gets
#                AMDGPU_FAMILY_NV, and the list that enables all_hub has only AI and RV.
#   no_seq_skip  does not skip the flush based on the sequence counter.
#   extra_types  also issues type 2 and type 0 flushes.
#   (all three)  everything together, in case no single one is enough.
#
# Reading the result
# ------------------
#   some knob zeroes the aliasing  -> the defect is INVALIDATION, and the patch
#                                     belongs in the flush path
#   nothing changes                -> the written PTE is already wrong, and the
#                                     problem is page table WRITING
#
# Design: counterbalanced order, never alternating -- on this board a boot's first
# GPU load differs from the following ones, and alternating would give one arm all
# the odd positions. Baseline (everything off) enters as an arm of its own,
# measured alongside and not from memory.

P=/sys/module/amdgpu/parameters
H=/home/gabriwar/bc250-grimoire/ab_tlb_knobs.historico
REPS=${1:-3}

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

set_knobs() {   # all_hub no_seq_skip extra_types
    S sh -c "echo $1 > $P/bc250_tlb_all_hub"
    S sh -c "echo $2 > $P/bc250_tlb_no_seq_skip"
    S sh -c "echo $3 > $P/bc250_tlb_extra_types"
    LIDO="$(cat $P/bc250_tlb_all_hub)$(cat $P/bc250_tlb_no_seq_skip)$(cat $P/bc250_tlb_extra_types)"
    [ "$LIDO" = "$1$2$3" ] || { echo "  ABORTADO: pedi $1$2$3, modulo ficou $LIDO"; exit 1; }
}

for k in bc250_tlb_all_hub bc250_tlb_no_seq_skip bc250_tlb_extra_types; do
    [ -e "$P/$k" ] || { echo "  ABORTADO: $P/$k nao existe -- modulo novo nao carregado"; exit 1; }
done

BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)
echo "boot=$BOOT reps=$REPS  $(uptime -p)" | tee -a "$H"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh

# counterbalanced order of the four arms
ORDEM="base allhub noseq extra extra noseq allhub base base allhub noseq extra"
i=0
for BRACO in $ORDEM; do
    i=$((i + 1))
    [ "$i" -gt $((REPS * 4)) ] && break
    case "$BRACO" in
        base)   set_knobs 0 0 0 ;;
        allhub) set_knobs 1 0 0 ;;
        noseq)  set_knobs 0 1 0 ;;
        extra)  set_knobs 0 0 1 ;;
    esac

    FA=$(S dmesg | grep -ci 'page fault')
    OUT=$(timeout 600 ./venv-gfx1013/bin/python \
            /home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+')
    FD=$(S dmesg | grep -ci 'page fault')
    [ -z "$N" ] && N="ERRO"

    echo "exec=$i braco=$BRACO aliasados=$N faults=$FA->$FD boot=$BOOT" | tee -a "$H"
done

set_knobs 0 0 0
echo "---- resumo (boot $BOOT) ----" | tee -a "$H"
for BRACO in base allhub noseq extra; do
    L=$(grep "boot=$BOOT" "$H" | grep "braco=$BRACO ")
    T=$(echo "$L" | grep -c 'aliasados=')
    SUJOS=$(echo "$L" | grep -cE 'aliasados=[1-9]')
    DET=$(echo "$L" | grep -oE 'aliasados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
    printf '  %-7s %s de %s com aliasing   [%s]\n' "$BRACO" "$SUJOS" "$T" "$DET" | tee -a "$H"
done
