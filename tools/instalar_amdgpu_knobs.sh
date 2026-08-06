#!/bin/bash
# Instala o amdgpu recompilado (com as chaves de diagnostico de TLB) e recarrega
# o modulo SEM reboot.
#
# Da para recarregar porque agora o amdgpu esta com 0 referencias e nao ha
# display server rodando. Se isso mudar, o `modprobe -r` falha e o script para
# antes de mexer em qualquer coisa.
#
# As chaves nascem todas em 0, entao o modulo novo se comporta como o antigo ate
# alguem liga-las. O A/B fica em tools/ab_tlb_knobs.sh.
#
# Uso:
#   instalar_amdgpu_knobs.sh            instala e recarrega
#   instalar_amdgpu_knobs.sh rollback   volta o modulo salvo e recarrega

set -u
S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

SRC=/home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1
KO="$SRC/drivers/gpu/drm/amd/amdgpu/amdgpu.ko"
DST="/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.zst"
BAK="/home/gabriwar/bc250-grimoire/amdgpu.ko.zst.antes-das-chaves"

# Os parametros de modulo vem da cmdline no boot. Num reload por modprobe eles
# NAO sao reaplicados sozinhos, entao sao extraidos daqui e repassados na mao --
# esquecer isso faria o modulo subir com gttsize e vm_update_mode default, e o
# A/B mediria outra maquina.
PARAMS=$(tr ' ' '\n' < /proc/cmdline | sed -n 's/^amdgpu\.//p' | tr '\n' ' ')

recarregar() {
    echo "  parametros que serao repassados: $PARAMS"
    USADO=$(lsmod | awk '/^amdgpu/{print $3}')
    if [ "${USADO:-0}" != "0" ]; then
        echo "  ABORTADO: amdgpu tem $USADO usuarios; feche o que estiver usando a GPU"
        exit 1
    fi
    S depmod -a
    S modprobe -r amdgpu || { echo "  ABORTADO: modprobe -r falhou"; exit 1; }
    # shellcheck disable=SC2086
    S modprobe amdgpu $PARAMS || { echo "  FALHOU ao carregar; tente o rollback"; exit 1; }
    echo "  carregado: $(cat /sys/module/amdgpu/version 2>/dev/null || echo ok)"
    for p in bc250_tlb_all_hub bc250_tlb_no_seq_skip bc250_tlb_extra_types bc250_tlb_trace; do
        v=$(cat "/sys/module/amdgpu/parameters/$p" 2>/dev/null)
        printf '    %-24s %s\n' "$p" "${v:-AUSENTE}"
    done
}

if [ "${1:-}" = "rollback" ]; then
    [ -f "$BAK" ] || { echo "  sem backup em $BAK"; exit 1; }
    S cp "$BAK" "$DST"
    recarregar
    exit 0
fi

[ -f "$KO" ] || { echo "  $KO nao existe -- o build terminou?"; exit 1; }

echo "  conferindo se o modulo novo tem as chaves:"
FALTOU=0
for p in bc250_tlb_all_hub bc250_tlb_no_seq_skip bc250_tlb_extra_types bc250_tlb_trace; do
    if modinfo "$KO" 2>/dev/null | grep -q "parm: *$p"; then
        echo "    ok  $p"
    else
        echo "    FALTOU  $p"; FALTOU=1
    fi
done
[ "$FALTOU" = "1" ] && { echo "  ABORTADO: o .ko nao tem as chaves"; exit 1; }

[ -f "$BAK" ] || { S cp "$DST" "$BAK" && echo "  backup do modulo atual em $BAK"; }

TMP=$(mktemp -d /home/gabriwar/bc250-grimoire/koXXXX)
cp "$KO" "$TMP/amdgpu.ko"
S strip --strip-debug "$TMP/amdgpu.ko"
zstd -q -f -19 "$TMP/amdgpu.ko" -o "$TMP/amdgpu.ko.zst"
echo "  novo modulo: $(du -h "$TMP/amdgpu.ko.zst" | cut -f1)"
S cp "$TMP/amdgpu.ko.zst" "$DST"
rm -rf "$TMP"

recarregar
