#!/bin/bash
# Captura as escritas reais de PTE durante o reprodutor de aliasing e mostra
# duas faixas de VA recebendo o mesmo endereco fisico.
#
# Por que este e o teste certo agora
# ----------------------------------
# Ja esta medido que a associacao errada SOBREVIVE a uma invalidacao forcada de
# TLB: apos hipMalloc/hipFree (que passa por kfd_flush_tlb) e reescrever, o
# bloco continua com o valor do outro. Logo nao e cache de traducao velha -- a
# entrada de tabela de pagina em si aponta para a memoria fisica errada.
#
# Com vm_update_mode=3 quem escreve as PTEs e a CPU (amdgpu_vm_cpu_update), e o
# tracepoint amdgpu_vm_update_ptes ja existe no kernel em uso: da a faixa de VA
# (start, end), o incremento, as flags e o vetor dst[] com os enderecos fisicos
# de destino. Nao precisa recompilar nada.
#
# O reprodutor imprime os VAs aliasados; o cruzamento com o trace mostra se as
# duas faixas receberam o mesmo dst.

T=/sys/kernel/tracing
OUT=/home/gabriwar/bc250-grimoire/trace_ptes
S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

mkdir -p "$OUT"

# Buffer grande para nao perder evento: dump no fim, sem pipe concorrente.
S sh -c "echo 8192 > $T/buffer_size_kb"
S sh -c "echo 0 > $T/tracing_on"
S sh -c "echo > $T/trace"
S sh -c "echo 1 > $T/events/amdgpu/amdgpu_vm_update_ptes/enable"
# set_ptes e o unico cujo print fmt renderiza addr=, o endereco fisico de
# destino. O dst[] do update_ptes e __data_loc e sai vazio no texto do ftrace.
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
