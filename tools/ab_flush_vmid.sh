#!/bin/bash
# Probe A/B: does invalidating the RIGHT VMID make the corruption go away?
#
# What is measured
# ----------------
# On this board the PASID scan in gmc_v10_0_flush_gpu_tlb_pasid() never finds
# any VMID -- 80 of 80 ATC entries invalid at rest, 20 of 20 flushes hitting
# zero VMIDs under load. The compute TLB is never invalidated.
#
# The real VMID exists and is readable: CP_HQD_VMID, the 4th dword of each queue
# block in /sys/kernel/debug/kfd/hqds. Measured VMID 8, stable, and deterministic
# by gmc_v10_0.c:1229 (first_kfd_vmid = 8).
#
#   arm A (default)   bc250_flush_vmid=0   nothing is invalidated
#   arm B (probe)     bc250_flush_vmid=8   the compute VMID is invalidated
#
# Pre-registered reading
# ----------------------
#   B=0/10 dirty against A~7/10  root cause confirmed and this is the fix
#   B=1-2/10 against A~7/10      dominant mechanism confirmed, ordering residue
#   B=A                          invalidation is out; the target moves below
#                                translation
#
# Why this script has a KIQ guard
# -------------------------------
# The first attempt at this probe took the GPU down: without bypassing the KIQ,
# a forced flush goes through amdgpu_gmc_fw_reg_write_reg_wait(), this board's KIQ
# hangs on INVALIDATE_TLBS, that is 13 s of timeout, "failed to write reg 28b4
# wait reg 28c6", and sdma0 dies behind it. The bypass is now automatic in the
# driver (bc250_flush_vmid joins the condition that already existed for
# bc250_flush_mapped_vmids), but if it fails this script STOPS immediately instead
# of insisting and resetting the board ten times.
#
# Design: counterbalanced order in blocks of 4 (A B B A), never alternating.
# Metric: blocks clobbered per run (0..12), not just dirty/clean.

set -u
P=/sys/module/amdgpu/parameters
REPS=${1:-10}                       # runs PER ARM
ALVO=${2:-8}                        # VMID of arm B
LOG=/home/gabriwar/bc250-grimoire/ab_flush_vmid.historico
REPRO=/home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

for k in bc250_flush_vmid bc250_tlb_trace; do
    [ -e "$P/$k" ] || { echo "ABORTADO: $P/$k nao existe -- modulo sem instrumentacao"; exit 1; }
done

set_arm() {   # $1 = value of bc250_flush_vmid
    S sh -c "echo $1 > $P/bc250_flush_vmid"
    LIDO=$(cat "$P/bc250_flush_vmid")
    [ "$LIDO" = "$1" ] || { echo "ABORTADO: pedi $1, modulo ficou $LIDO"; exit 1; }
}

# board health: any of these signatures means the KIQ bypass did not take
# effect, and continuing will only reset the GPU over and over
saude() { S dmesg | grep -ciE 'failed to write reg|ring .* timeout|ring reset|coredump'; }

S sh -c "echo 1 > $P/bc250_tlb_trace"
BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)
BASE=$(saude)
echo "boot=$BOOT reps=$REPS por braco alvo=VMID$ALVO saude_inicial=$BASE inicio=$(date '+%H:%M:%S')" | tee -a "$LOG"

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
        B) set_arm "$ALVO" ;;
    esac

    HA=$(saude)
    FA=$(S dmesg | grep -ci 'page fault')
    OUT=$(timeout 600 ./venv-gfx1013/bin/python "$REPRO" 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+$')
    FD=$(S dmesg | grep -ci 'page fault')
    HD=$(saude)
    [ -z "$N" ] && N="ERRO"

    echo "exec=$i braco=$BRACO pisados=$N faults=$FA->$FD saude=$HA->$HD boot=$BOOT" | tee -a "$LOG"

    if [ "$HD" -gt "$HA" ]; then
        echo "  ABORTADO na execucao $i: a placa registrou timeout/reset." | tee -a "$LOG"
        echo "  O desvio do KIQ nao esta pegando -- parando antes de resetar de novo." | tee -a "$LOG"
        S dmesg | grep -E 'failed to write reg|ring .* timeout|kiq' | tail -5 | sed 's/^/    /' | tee -a "$LOG"
        set_arm 0
        exit 2
    fi
    [ "$FD" -gt "$FA" ] && echo "  AVISO: page fault na execucao $i" | tee -a "$LOG"
done

set_arm 0

echo "---- resumo (boot $BOOT) ----" | tee -a "$LOG"
for BRACO in A B; do
    L=$(grep "boot=$BOOT" "$LOG" | grep "braco=$BRACO ")
    T=$(echo "$L" | grep -c 'pisados=')
    DET=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
    SUJOS=$(echo "$L" | grep -cE 'pisados=[1-9]')
    TOT=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | awk '{s+=$1} END{print s+0}')
    NOME=$([ "$BRACO" = "A" ] && echo "padrao (nada invalidado)" || echo "probe (VMID $ALVO invalidado)")
    printf '  %-32s %s/%s execucoes sujas   %s blocos no total   [%s]\n' \
        "$NOME" "$SUJOS" "$T" "$TOT" "$DET" | tee -a "$LOG"
done
echo "fim=$(date '+%H:%M:%S')" | tee -a "$LOG"
