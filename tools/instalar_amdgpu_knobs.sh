#!/bin/bash
# Installs the rebuilt amdgpu (with the TLB diagnostic knobs) and reloads the
# module WITHOUT a reboot.
#
# Reloading is possible because amdgpu now has 0 references and no display server
# is running. If that changes, `modprobe -r` fails and the script stops before
# touching anything.
#
# The knobs all start at 0, so the new module behaves like the old one until
# someone enables them. The A/B lives in tools/ab_tlb_knobs.sh.
#
# Usage:
#   instalar_amdgpu_knobs.sh            installs and reloads
#   instalar_amdgpu_knobs.sh rollback   restores the saved module and reloads

set -u
S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

SRC=/home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1
KO="$SRC/drivers/gpu/drm/amd/amdgpu/amdgpu.ko"
DST="/lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.zst"
BAK="/home/gabriwar/bc250-grimoire/amdgpu.ko.zst.antes-das-chaves"

# Module parameters come from the boot cmdline. On a modprobe reload they are
# NOT reapplied on their own, so they are extracted here and passed by hand --
# forgetting this would bring the module up with default gttsize and
# vm_update_mode, and the A/B would be measuring a different machine.
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
