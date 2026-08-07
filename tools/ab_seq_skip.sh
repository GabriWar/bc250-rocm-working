#!/bin/bash
# A/B focado: o contador de sequencia pula metade das invalidacoes de TLB.
# Isso importa?
#
# O que se mede
# -------------
# amdgpu_vm_flush_compute_tlb() descarta o flush quando kfd_last_flushed_seq
# ja e igual a tlb_seq. Com bc250_tlb_trace=1 medimos a proporcao real nesta
# placa: 20 PULADO para 20 FLUSH -- metade das invalidacoes pedidas nunca
# acontece. Entao o botao tem alavanca, e o A/B nao e vazio.
#
#   braco A (padrao)          no_seq_skip=0   metade dos flushes descartada
#   braco B (mais flush)      no_seq_skip=1   nenhum descartado
#
# Por que agora, e nao antes
# --------------------------
# 85 de 87 offsets onde a corrupcao COMECA sao multiplos exatos de 2 MiB --
# a granularidade de pagina grande, o mesmo incr=2097152 das PTEs. Corrupcao
# alinhada a pagina nao e corrida; e pagina inteira mapeada errado. A leitura
# que encaixa e entrada de TLB velha para uma pagina de 2 MiB.
#
# Leitura do resultado
# --------------------
#   B < A   entrada de TLB velha: invalidar mais resolve, e o defeito e de
#           invalidacao que nao chega
#   B > A   a errata do Navi 1x: o flush concorrente com a traducao E o
#           perigo, e invalidar mais piora
#   B = A   nenhum dos dois; o defeito nao esta no caminho de invalidacao
#
# Desenho: ordem contrabalanceada em blocos de 4 (A B B A), nunca alternada --
# nesta placa a primeira carga de GPU de um boot difere das seguintes, e
# alternar daria a um braco todas as posicoes impares.
#
# Metrica: blocos pisados por execucao (0..12), nao so sujo/limpo. Contagem
# tem mais poder estatistico que binario com o N que da para rodar.

set -u
P=/sys/module/amdgpu/parameters
REPS=${1:-10}                       # execucoes POR BRACO
LOG=/home/gabriwar/bc250-grimoire/ab_seq_skip.historico
REPRO=/home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

for k in bc250_tlb_no_seq_skip bc250_tlb_trace; do
    [ -e "$P/$k" ] || { echo "ABORTADO: $P/$k nao existe -- modulo sem instrumentacao"; exit 1; }
done

set_arm() {   # $1 = 0 ou 1
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

    # se a GPU comecou a faultar, parar: os dados dali para frente nao valem
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
