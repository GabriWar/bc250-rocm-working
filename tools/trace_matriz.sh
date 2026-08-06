#!/bin/bash
# Captura os eventos de VM do amdgpu junto com marcadores do proprio reprodutor.
# So tracepoints de baixa frequencia: o set_ptes (938 eventos, dentro do laco de
# escrita de PTE) fez o fenomeno sumir em 6 de 6 execucoes.
T=/sys/kernel/tracing
O=/home/gabriwar/bc250-grimoire/trace_matriz
S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }
mkdir -p "$O"
S sh -c "echo 16384 > $T/buffer_size_kb"
# set_ptes e o unico que rende addr= (o endereco fisico gravado na entrada), mas
# sem filtro sao ~938 eventos dentro do laco de escrita de PTE e o fenomeno some
# (6 de 6 limpas). O filtro por incr==2MiB deixa so as entradas de pagina grande,
# que sao as que cobrem nossos blocos, e derruba o volume.
S sh -c "echo 'incr == 2097152' > $T/events/amdgpu/amdgpu_vm_set_ptes/filter"
for e in amdgpu_vm_update_ptes amdgpu_vm_bo_mapping amdgpu_vm_bo_unmap amdgpu_vm_set_ptes; do
    S sh -c "echo 1 > $T/events/amdgpu/$e/enable"
done
S chmod 666 $T/trace_marker
cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh
for i in 1 2 3 4 5 6; do
    S sh -c "echo > $T/trace"; S sh -c "echo 1 > $T/tracing_on"
    R=$(timeout 600 ./venv-gfx1013/bin/python \
          /home/gabriwar/bc250-rocm-working/tools/matriz_cpu_gpu.py 2>&1)
    S sh -c "echo 0 > $T/tracing_on"
    if echo "$R" | grep -qE '=> CPU e GPU|=> a escrita'; then
        S sh -c "cat $T/trace" > "$O/trace.txt"
        echo "$R" > "$O/repro.txt"
        echo "$R" | grep -E 'RESUMO|=>|bytes errados' | sed 's/^/  /'
        echo "  trace: $(wc -l < "$O/trace.txt") linhas"
        break
    fi
    echo "  exec $i limpa"
done
for e in amdgpu_vm_update_ptes amdgpu_vm_bo_mapping amdgpu_vm_bo_unmap amdgpu_vm_set_ptes; do
    S sh -c "echo 0 > $T/events/amdgpu/$e/enable"
done
S sh -c "echo 0 > $T/events/amdgpu/amdgpu_vm_set_ptes/filter"
S sh -c "echo 1024 > $T/buffer_size_kb"
