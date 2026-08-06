#!/bin/bash
# A/B do bc250_no_empty_cache: duas medidas por boot, analise primaria na primeira.
#
# Pergunta: com o patch de SDMA aplicado, o no_empty_cache ainda importa?
#
# Desenho
# -------
# Cada boot rende DUAS medidas, uma de cada braco:
#
#   posicao 1  -> braco da ordem contrabalanceada  1 0 0 1 1 0
#   posicao 2  -> o braco complementar
#
# ANALISE PRIMARIA: so as medidas de posicao 1. Todas na mesma condicao --
# primeira carga de GPU de um boot limpo -- entao posicao nao e variavel ali.
# E a ordem entre boots e contrabalanceada, nao alternada: `1 0 0 1 1 0` da a
# cada braco posicoes impares e pares. Alternar (`1 0 1 0`) deixaria um braco
# com todas as impares, inclusive a primeira, e neste board a primeira medida
# de um boot se comporta diferente.
#
# SECUNDARIA: as medidas de posicao 2, como dado exploratorio. Elas carregam o
# efeito de posicao, que foi medido e e real: na bateria do h2d_check, a run 1
# de cada boot dava 0/3 corrompidos e as seguintes 3/3, com ZERO page fault em
# todas. Posicao no boot e variavel propria, nao sujeira.
#
# Como a posicao 2 tambem sai contrabalanceada (`0 1 1 0 0 1`), comparar
# primaria com secundaria diz se a posicao importa para ESTA medida. Se o mesmo
# braco der o mesmo resultado nas duas posicoes, da para juntar tudo.
#
# Regras herdadas da investigacao (2026-08-05/06):
#   - aborta se `page fault != 0`: mediria envenenamento, nao a hipotese
#   - aborta se sobrou ComfyUI orfao na porta: ja se disfarcou de falha de GPU
#   - imagem valida e validada por estatistica de pixel, nao por existir:
#     corrompida da std ~10 e ~2000 cores, boa da std ~75 e ~100k
#
# Fixo nos dois bracos: BC250_CONV_FIX=0, BC250_WARMUP=1.
#
# Uso: rodar DUAS vezes depois de cada boot. O script descobre sozinho em que
# medida e em que posicao esta.

H=/home/gabriwar/bc250-grimoire/ab_no_empty_cache.historico
R=/home/gabriwar/bc250-grimoire/rocm-test
ORDEM="1 0 0 1 1 0"
BOOTS=6

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

BOOT=$(cat /proc/sys/kernel/random/boot_id | cut -c1-8)
touch "$H"

# CUIDADO: `grep -c` imprime a contagem E retorna exit 1 quando ela e zero.
# Escrever `$(grep -c ... || echo 0)` faz o fallback disparar por cima, e a
# variavel vira duas linhas ("0\n0"), quebrando todo `[ "$v" -eq ... ]` depois.
# Isso ja aconteceu aqui: os testes erraram com "integer expected", o fluxo caiu
# no ramo errado, e o script rodou o braco errado na posicao errada.
# grep -c sempre imprime um numero, entao nao precisa de fallback nenhum.
NP1=$(grep -c 'pos=1' "$H" 2>/dev/null)
JA=$(grep -c "boot=$BOOT" "$H" 2>/dev/null)

if [ "$JA" -ge 2 ]; then
    echo "  este boot ja tem 2 medidas. Reboote para o proximo."
    grep "boot=$BOOT" "$H" | sed 's/^/    /'
    exit 0
fi

if [ "$JA" -eq 0 ]; then
    POS=1
    IDX=$((NP1 + 1))
    [ "$IDX" -gt "$BOOTS" ] && { echo "  bateria completa. Rode com 'resumo'."; exit 0; }
    W=$(echo $ORDEM | cut -d' ' -f$IDX)
else
    POS=2
    # complementar do que ja rodou neste boot
    ANT=$(grep "boot=$BOOT" "$H" | grep -oE 'NEC=[01]' | head -1 | cut -d= -f2)
    W=$((1 - ANT))
    IDX=$(grep "boot=$BOOT" "$H" | grep -oE 'medida=[0-9]+' | head -1 | cut -d= -f2)
fi

FA=$(S dmesg | grep -ci 'page fault')
GUARD=$(cat /sys/module/amdgpu/parameters/bc250_dead_gpu_guard 2>/dev/null)
SKIP=$(cat /sys/module/amdgpu/parameters/bc250_skip_sdma0 2>/dev/null)

echo "  boot $IDX de $BOOTS   posicao $POS   NO_EMPTY_CACHE=$W   ($BOOT)"
echo "  faults=$FA  dead_gpu_guard=$GUARD  skip_sdma0=$SKIP  $(uptime -p)"

[ "$FA" != "0" ] && { echo "  ABORTADO: page fault != 0"; exit 1; }
[ "$(pgrep -cf '[m]ain.py --listen')" != "0" ] && { echo "  ABORTADO: ComfyUI orfao"; exit 1; }

cd /home/gabriwar/bc250-rocm-working/tools || exit 1
find /home/gabriwar/ComfyUI/output -name 'bc250_bench*' -delete 2>/dev/null
T0=$(date +%s)
BC250_CONV_FIX=0 BC250_WARMUP=1 BC250_NO_EMPTY_CACHE=$W \
    timeout 420 bash run_bench2.sh >/dev/null 2>&1
DT=$(($(date +%s) - T0))

IMG=$(ls /home/gabriwar/ComfyUI/output/bc250_bench_*.png 2>/dev/null | wc -l)
LINHA=$(grep -E '^(FIM|FALHOU)' "$R/bench2.result" 2>/dev/null | head -1)

PIX=$(python3 - <<'PY' 2>/dev/null
from PIL import Image
import numpy as np, glob, os
fs = sorted(glob.glob('/home/gabriwar/ComfyUI/output/bc250_bench_*.png'))
if not fs:
    print("sem-imagem")
else:
    print(" ".join(
        f"{os.path.getsize(f)//1024}KB/std{np.array(Image.open(f).convert('RGB')).std():.1f}"
        f"/{len(np.unique(np.array(Image.open(f).convert('RGB')).reshape(-1,3),axis=0))}cores"
        for f in fs))
PY
)

VER="FALHOU"
[ "$IMG" -ge 2 ] && echo "$PIX" | grep -qE 'std(4[0-9]|[5-9][0-9]|[0-9]{3})' && VER="OK"

echo "medida=$IDX pos=$POS boot=$BOOT NEC=$W $VER ${DT}s img=$IMG | $LINHA | $PIX" >> "$H"
sync
tail -1 "$H" | sed 's/^/  /'

for p in $(pgrep -f '[m]ain.py --listen'); do kill -9 "$p" 2>/dev/null; done

echo
echo "  faults depois: $(S dmesg | grep -ci 'page fault')"
S dmesg | grep -i 'BC-250: GPU' | tail -2 | sed 's/^/  GUARDA: /'
echo
if [ "$POS" = "1" ]; then
    echo "  agora rode DE NOVO neste mesmo boot para a posicao 2 (NEC=$((1 - W)))"
else
    echo "  boot $IDX completo. Reboote para o boot $((IDX + 1)) de $BOOTS."
fi
