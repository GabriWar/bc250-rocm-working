#!/bin/bash
# Captures the real PTE writes during the aliasing reproducer and shows two VA
# ranges receiving the same physical address.
#
# Why this is the right test now
# ------------------------------
# It is already measured that the wrong association SURVIVES a forced TLB
# invalidation: after hipMalloc/hipFree (which goes through kfd_flush_tlb) and a
# rewrite, the block still holds the other one's value. So it is not a stale
# translation cache -- the page table entry itself points at the wrong memory.
#
# With vm_update_mode=3 the CPU is what writes the PTEs (amdgpu_vm_cpu_update),
# and the amdgpu_vm_update_ptes tracepoint already exists in the running kernel:
# it gives the VA range (start, end), the increment, the flags and the dst[]
# vector with the destination physical addresses. Nothing needs recompiling.
#
# The reproducer prints the aliased VAs; cross-referencing with the trace shows
# whether the two ranges received the same dst.

T=/sys/kernel/tracing
OUT=/home/gabriwar/bc250-grimoire/trace_ptes
S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

mkdir -p "$OUT"

# Large buffer so no event is lost: dump at the end, no concurrent pipe.
S sh -c "echo 8192 > $T/buffer_size_kb"
S sh -c "echo 0 > $T/tracing_on"
S sh -c "echo > $T/trace"
S sh -c "echo 1 > $T/events/amdgpu/amdgpu_vm_update_ptes/enable"
# set_ptes is the only one whose print fmt renders addr=, the destination physical
# address. update_ptes's dst[] is __data_loc and comes out empty in ftrace's text.
S sh -c "echo 1 > $T/events/amdgpu/amdgpu_vm_set_ptes/enable"
S sh -c "echo 1 > $T/events/amdgpu/amdgpu_vm_bo_mapping/enable"
S sh -c "echo 1 > $T/events/amdgpu/amdgpu_vm_bo_unmap/enable"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh

for i in 1 2 3 4 5 6; do
    S sh -c "echo > $T/trace"
    S sh -c "echo 1 > $T/tracing_on"
    R=$(timeout 600 ./venv-gfx1013/bin/python \
          /home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py 3 orig 2>&1)
    S sh -c "echo 0 > $T/tracing_on"

    if echo "$R" | grep -q 'PISADO'; then
        echo "$R" | grep -E 'PISADO|resumo|=>' | sed 's/^/  /'
        S sh -c "cat $T/trace" > "$OUT/trace.txt"
        echo "$R" > "$OUT/repro.txt"
        echo "  trace: $(wc -l < "$OUT/trace.txt") linhas em $OUT/trace.txt"
        break
    fi
    echo "  tentativa $i limpa"
done

S sh -c "echo 0 > $T/events/amdgpu/amdgpu_vm_update_ptes/enable"
S sh -c "echo 0 > $T/events/amdgpu/amdgpu_vm_set_ptes/enable"
S sh -c "echo 0 > $T/events/amdgpu/amdgpu_vm_bo_mapping/enable"
S sh -c "echo 0 > $T/events/amdgpu/amdgpu_vm_bo_unmap/enable"
S sh -c "echo 1024 > $T/buffer_size_kb"
