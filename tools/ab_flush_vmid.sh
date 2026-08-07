#!/bin/bash
# A/B do probe: invalidar o VMID CERTO faz a corrupcao sumir?
#
# O que se mede
# -------------
# Nesta placa a varredura por PASID de gmc_v10_0_flush_gpu_tlb_pasid() nunca
# acha VMID nenhum -- 80 de 80 entradas do ATC invalidas em repouso, 20 de 20
# flushes atingindo zero VMIDs sob carga. O TLB de compute nunca e invalidado.
#
# O VMID real existe e e legivel: CP_HQD_VMID, o 4o dword de cada bloco de fila
# em /sys/kernel/debug/kfd/hqds. Medido VMID 8, estavel, e determinístico por
# gmc_v10_0.c:1229 (first_kfd_vmid = 8).
#
#   braco A (padrao)   bc250_flush_vmid=0   nada e invalidado
#   braco B (probe)    bc250_flush_vmid=8   o VMID de compute e invalidado
#
# Leitura pre-registrada
# ----------------------
#   B=0/10 sujas contra A~7/10   causa raiz confirmada e o conserto e este
#   B=1-2/10 contra A~7/10       mecanismo dominante confirmado, residuo de ordem
#   B=A                          invalidacao sai de cena; o alvo desce abaixo
#                                da traducao
#
# Por que este script tem guarda de KIQ
# -------------------------------------
# A primeira tentativa deste probe derrubou a GPU: sem desviar do KIQ, o flush
# forcado entra por amdgpu_gmc_fw_reg_write_reg_wait(), o KIQ desta placa trava
# com INVALIDATE_TLBS, sao 13 s de timeout, "failed to write reg 28b4 wait reg
# 28c6", e o sdma0 morre atras. O desvio agora e automatico no driver
# (bc250_flush_vmid entra na condicao que ja existia para
# bc250_flush_mapped_vmids), mas se ele falhar este script PARA na hora em vez
# de insistir e resetar a placa dez vezes.
#
# Desenho: ordem contrabalanceada em blocos de 4 (A B B A), nunca alternada.
# Metrica: blocos pisados por execucao (0..12), nao so sujo/limpo.

set -u
P=/sys/module/amdgpu/parameters
REPS=${1:-10}                       # execucoes POR BRACO
ALVO=${2:-8}                        # VMID do braco B
LOG=/home/gabriwar/bc250-grimoire/ab_flush_vmid.historico
REPRO=/home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

for k in bc250_flush_vmid bc250_tlb_trace; do
    [ -e "$P/$k" ] || { echo "ABORTADO: $P/$k nao existe -- modulo sem instrumentacao"; exit 1; }
done

set_arm() {   # $1 = valor de bc250_flush_vmid
    S sh -c "echo $1 > $P/bc250_flush_vmid"
    LIDO=$(cat "$P/bc250_flush_vmid")
    [ "$LIDO" = "$1" ] || { echo "ABORTADO: pedi $1, modulo ficou $LIDO"; exit 1; }
}

# a saude da placa: qualquer uma destas assinaturas significa que o desvio do
# KIQ nao pegou, e continuar so vai resetar a GPU repetidamente
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
