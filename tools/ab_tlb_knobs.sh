#!/bin/bash
# A/B das chaves de diagnostico de invalidacao de TLB contra o reprodutor de
# aliasing de tabelas de pagina (tools/hipmalloc_cru.py).
#
# O que se mede
# -------------
# Duas alocacoes de hipMalloc vivas, BOs distintos em /proc/pid/maps, que a GPU
# ve como a mesma memoria. A CPU escreve e le as duas faixas sem divergencia.
# Reproduz em 6 de 6 execucoes; exige alocacao e execucao de kernel
# intercaladas, cada metade sozinha da 0 de 3.
#
# As chaves
# ---------
#   all_hub      invalida tambem o MMHUB. Cyan Skillfish e APU mas recebe
#                AMDGPU_FAMILY_NV, e a lista que liga all_hub tem so AI e RV.
#   no_seq_skip  nao pula o flush pelo contador de sequencia.
#   extra_types  emite tambem os flushes tipo 2 e 0.
#   (as tres)    tudo junto, para o caso de nenhuma isolada bastar.
#
# Leitura do resultado
# --------------------
#   alguma chave zera o aliasing  -> o defeito e de INVALIDACAO, e o patch mora
#                                    no caminho de flush
#   nenhuma muda nada             -> a PTE gravada ja esta errada, e o problema
#                                    e de ESCRITA de tabela de pagina
#
# Desenho: ordem contrabalanceada, nunca alternada -- nesta placa a primeira
# carga de GPU de um boot difere das seguintes, e alternar daria a um braco
# todas as posicoes impares. Baseline (tudo desligado) entra como um braco
# proprio, medido junto e nao de memoria.

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

# ordem contrabalanceada dos quatro bracos
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
