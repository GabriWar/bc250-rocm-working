#!/bin/bash
# A/B of bc250_flush_mapped_vmids against the page table aliasing reproducer
# (tools/hipmalloc_cru.py).
#
# Hypothesis
# ----------
# With the parameter at 0, gmc_v10_0_flush_gpu_tlb takes the shortcut on line 24
# and submits the TLB invalidation through the KIQ queue:
#
#   if (!(bc250_flush_mapped_vmids && device == BC250) &&
#       adev->gfx.kiq[0].ring.sched.ready && !adev->enable_mes && ...) {
#           amdgpu_gmc_fw_reg_write_reg_wait(adev, req, ack, inv_req, 1 << vmid, ...);
#           return;
#   }
#
# The driver itself already records that KIQ hangs on this board
# (flush_pasid_uses_kiq = false, "gfx1013/BC-250: KIQ TLB flush wedges").
# If the submission never completes but the function returns, the GPU keeps
# translating through the old entry -- which is exactly what the reproducer
# measures: two live VAs, distinct BOs, same physical memory, and only the GPU sees it.
#
# With the parameter at 1, the code skips the KIQ and invalidates via direct MMIO.
#
# Design
# ------
# The parameter is 0644, so it can be toggled without a reboot. The phenomenon is
# per PROCESS (bimodal: a process either aliases on every cycle or on none), so
# each run is an independent trial and an A/B in the same boot is stronger than
# across boots: it eliminates whole-boot variation.
#
# Counterbalanced order `1 0 0 1 1 0 0 1 1 0 0 1`, not alternating: alternating
# would give one arm all the odd positions, and on this board a boot's first GPU
# load behaves differently from the following ones.
#
# Unpatched reference, measured before this script, same boot:
#   bc250_flush_mapped_vmids=0  ->  6 of 6 runs with aliasing

P=/sys/module/amdgpu/parameters/bc250_flush_mapped_vmids
H=/home/gabriwar/bc250-grimoire/ab_flush_vmids.historico
ORDEM="1 0 0 1 1 0 0 1 1 0 0 1"

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)
echo "boot=$BOOT  $(uptime -p)" | tee -a "$H"
echo "faults no inicio: $(S dmesg | grep -ci 'page fault')" | tee -a "$H"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh

i=0
for W in $ORDEM; do
    i=$((i + 1))
    # CAREFUL: S() does `printf password | sudo -S ...`, so it ALWAYS replaces
    # stdin. `echo "$W" | S tee "$P"` does not work -- tee receives the password,
    # not the value, and the parameter stays unchanged with no visible error.
    S sh -c "echo $W > $P"
    LIDO=$(cat "$P")
    if [ "$LIDO" != "$W" ]; then
        echo "  ABORTADO na execucao $i: pedi $W, o modulo ficou em $LIDO" | tee -a "$H"
        exit 1
    fi

    FA=$(S dmesg | grep -ci 'page fault')
    OUT=$(timeout 600 ./venv-gfx1013/bin/python \
            /home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+')
    FD=$(S dmesg | grep -ci 'page fault')
    [ -z "$N" ] && N="ERRO"

    echo "exec=$i flush_mapped_vmids=$W blocos_aliasados=$N faults=$FA->$FD boot=$BOOT" \
        | tee -a "$H"
done

echo "---- resumo (boot $BOOT) ----" | tee -a "$H"
for W in 0 1; do
    L=$(grep "boot=$BOOT" "$H" | grep "flush_mapped_vmids=$W")
    T=$(echo "$L" | grep -c 'blocos_aliasados=')
    SUJOS=$(echo "$L" | grep -cE 'blocos_aliasados=[1-9]')
    DET=$(echo "$L" | grep -oE 'blocos_aliasados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
    echo "  =$W: $SUJOS de $T execucoes com aliasing   [$DET]" | tee -a "$H"
done
