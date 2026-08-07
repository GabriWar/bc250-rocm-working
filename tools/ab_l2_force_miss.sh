#!/bin/bash
# O cache de LINHAS DE TABELA DE PAGINA do L2 e quem entrega a traducao errada?
#
# O que este teste decide
# -----------------------
# O caminho VA->PA dentro da GPU tem DOIS caches, e ate agora foram tratados
# como um so:
#
#   VA -> UTCL1/UTCL2 ....... cache de TRADUCOES prontas          [TLB]
#          -> miss -> walker
#              -> le PDE1/PDE0/PTE da memoria
#                  -> essas leituras passam pelo cache de LINHAS DE TABELA no L2
#                      -> PA
#
# FORCE_MISS mata SO o de baixo: obriga o walker a reler a entrada da memoria em
# toda traducao. O TLB fica intocado. Entao o resultado localiza a quebra:
#
#   taxa cai para ~0  -> o walker lia linha de tabela errada. A quebra esta na
#                        busca de PDE/PTE: abaixo do TLB, acima da memoria.
#   taxa nao muda     -> a busca do walker esta boa. Sobra o TLB: entrada VA->PA
#                        velha ou com tag colidindo, acima do walker.
#
# O lado de baixo ja esta fechado por medicao anterior (doc 17): o dado lido
# direto no endereco fisico, sem VA nenhuma, esta correto. Entao "abaixo da
# memoria" nao e candidato, e as duas metades acima sao as unicas que restam.
#
# Por que o braco C existe
# ------------------------
# Nossas paginas sao de 2 MiB, ou seja BIGK. O braco C liga so
# L2_CACHE_4K_FORCE_MISS, que NAO toca nas nossas paginas. Se a corrupcao sumir
# tambem em C, entao nada foi consertado -- so o timing mudou, e a leitura
# otimista dos outros bracos morre antes de virar conclusao. Sem esse controle o
# teste nao vale.
#
# Uso
# ---
# Este teste NAO da para rodar como A/B no mesmo boot: os parametros sao 0444,
# lidos so no init. Cada braco e um boot com uma linha de comando diferente.
#
#   ab_l2_force_miss.sh <reps>     mede o braco correspondente a cmdline ATUAL
#
# Bracos, na ordem em que devem ser rodados:
#
#   A  (sem parametro)                       base, esperado ~7/10 sujo
#   B  amdgpu.bc250_l2_force_miss=7          marreta: 4K + BIGK + PDE
#   C  amdgpu.bc250_l2_force_miss=1          CONTROLE NEGATIVO: so 4K
#   D  amdgpu.bc250_l2_force_miss=2          so BIGK, o que importa de verdade
#   E  amdgpu.bc250_l2_pde0_tag_mode=1       colisao de tag, custo zero
#
# Leitura:
#   B limpo, C sujo   -> o cache de tabela de pagina e a causa. Segue para D e E.
#   B limpo, C limpo  -> artefato de timing. Nada provado, hipotese sem suporte.
#   B sujo            -> a hipotese morre aqui. O alvo sobe para o TLB.

set -u
REPS=${1:-10}
LOG=/home/gabriwar/bc250-grimoire/ab_l2_force_miss.historico
REPRO=/home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

P=/sys/module/amdgpu/parameters
for k in bc250_l2_force_miss bc250_l2_pde0_tag_mode bc250_l2_disable_bigk_opt; do
    [ -e "$P/$k" ] || { echo "ABORTADO: $P/$k nao existe -- modulo antigo"; exit 1; }
done

FM=$(cat $P/bc250_l2_force_miss)
TM=$(cat $P/bc250_l2_pde0_tag_mode)
BK=$(cat $P/bc250_l2_disable_bigk_opt)

case "$FM:$TM:$BK" in
    0:-1:0) BRACO="A base" ;;
    7:-1:0) BRACO="B marreta(4K+BIGK+PDE)" ;;
    1:-1:0) BRACO="C CONTROLE-NEGATIVO(so 4K)" ;;
    2:-1:0) BRACO="D so-BIGK" ;;
    0:1:0)  BRACO="E tag_mode=1" ;;
    *)      BRACO="? fm=$FM tm=$TM bk=$BK" ;;
esac

# o driver so imprime a linha de confirmacao quando algum botao esta ligado
CONFIRMA=$(S dmesg | grep -c 'BC-250 L2/')
BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)

echo "" | tee -a "$LOG"
echo "boot=$BOOT braco=$BRACO fm=$FM tm=$TM bk=$BK reps=$REPS inicio=$(date '+%H:%M:%S')" | tee -a "$LOG"
if [ "$FM" != "0" ] && [ "$CONFIRMA" = "0" ]; then
    echo "  ABORTADO: force_miss=$FM mas o driver nao imprimiu 'BC-250 L2/'." | tee -a "$LOG"
    echo "  O parametro nao chegou ao init -- nada depois disto valeria." | tee -a "$LOG"
    exit 1
fi
S dmesg | grep 'BC-250 L2/' | tail -2 | sed 's/^/  /' | tee -a "$LOG"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh 2>/dev/null

saude() { S dmesg | grep -ciE 'ring .* timeout|ring reset|coredump|Timeout waiting for VM flush'; }

for i in $(seq 1 "$REPS"); do
    HA=$(saude)
    OUT=$(timeout 600 ./venv-gfx1013/bin/python "$REPRO" 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+$')
    HD=$(saude)
    [ -z "$N" ] && N="ERRO"
    echo "exec=$i braco=$BRACO pisados=$N saude=$HA->$HD boot=$BOOT" | tee -a "$LOG"
    if [ "$HD" -gt "$HA" ]; then
        echo "  ABORTADO na execucao $i: a placa registrou timeout/reset." | tee -a "$LOG"
        exit 2
    fi
done

L=$(grep "boot=$BOOT" "$LOG" | grep 'pisados=')
T=$(echo "$L" | grep -c 'pisados=')
SUJOS=$(echo "$L" | grep -cE 'pisados=[1-9]')
TOT=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | awk '{s+=$1} END{print s+0}')
DET=$(echo "$L" | grep -oE 'pisados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
echo "---- $BRACO: $SUJOS/$T execucoes sujas, $TOT blocos no total  [$DET]" | tee -a "$LOG"
echo "fim=$(date '+%H:%M:%S')" | tee -a "$LOG"
