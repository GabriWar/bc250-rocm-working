#!/bin/bash
# A/B de bc250_flush_mapped_vmids contra o reprodutor de aliasing de tabelas de
# pagina (tools/hipmalloc_cru.py).
#
# Hipotese
# --------
# Com o parametro em 0, gmc_v10_0_flush_gpu_tlb sai pelo atalho da linha 24 e
# submete a invalidacao de TLB pela fila KIQ:
#
#   if (!(bc250_flush_mapped_vmids && device == BC250) &&
#       adev->gfx.kiq[0].ring.sched.ready && !adev->enable_mes && ...) {
#           amdgpu_gmc_fw_reg_write_reg_wait(adev, req, ack, inv_req, 1 << vmid, ...);
#           return;
#   }
#
# O proprio driver ja registra que KIQ trava nesta placa
# (flush_pasid_uses_kiq = false, "gfx1013/BC-250: KIQ TLB flush wedges").
# Se a submissao nao completa mas a funcao retorna, a GPU segue traduzindo pela
# entrada antiga -- que e exatamente o que o reprodutor mede: dois VAs vivos,
# BOs distintos, mesma memoria fisica, e so a GPU ve.
#
# Com o parametro em 1, o codigo pula o KIQ e invalida por MMIO direto.
#
# Desenho
# -------
# O parametro e 0644, entao alterna sem reboot. O fenomeno e por PROCESSO
# (bimodal: um processo ou aliasa em todos os ciclos ou em nenhum), entao cada
# execucao e um ensaio independente e o A/B no mesmo boot e mais forte que entre
# boots: elimina a variacao de boot inteira.
#
# Ordem contrabalanceada `1 0 0 1 1 0 0 1 1 0 0 1`, nao alternada: alternar daria
# a um braco todas as posicoes impares, e nesta placa a primeira carga de GPU de
# um boot se comporta diferente das seguintes.
#
# Referencia sem patch, medida antes deste script, mesmo boot:
#   bc250_flush_mapped_vmids=0  ->  6 de 6 execucoes com aliasing

P=/sys/module/amdgpu/parameters/bc250_flush_mapped_vmids
H=/home/gabriwar/bc250-grimoire/ab_flush_vmids.historico
ORDEM="1 0 0 1 1 0 0 1 1 0 0 1"

S() { printf 'grdg\n' | sudo -S "$@" 2>/dev/null; }

BOOT=$(cut -c1-8 /proc/sys/kernel/random/boot_id)
echo "boot=$BOOT  $(uptime -p)" | tee -a "$H"
echo "faults no inicio: $(S dmesg | grep -ci 'page fault')" | tee -a "$H"

cd /home/gabriwar/ComfyUI || exit 1
source /etc/profile.d/bc250-rocm.sh

i=0
for W in $ORDEM; do
    i=$((i + 1))
    # CUIDADO: S() faz `printf senha | sudo -S ...`, entao ele SEMPRE substitui o
    # stdin. `echo "$W" | S tee "$P"` nao funciona -- o tee recebe a senha, nao o
    # valor, e o parametro fica inalterado sem erro nenhum visivel.
    S sh -c "echo $W > $P"
    LIDO=$(cat "$P")
    if [ "$LIDO" != "$W" ]; then
        echo "  ABORTADO na execucao $i: pedi $W, o modulo ficou em $LIDO" | tee -a "$H"
        exit 1
    fi

    FA=$(S dmesg | grep -ci 'page fault')
    OUT=$(timeout 600 ./venv-gfx1013/bin/python \
            /home/gabriwar/bc250-rocm-working/tools/hipmalloc_cru.py 3 orig 2>&1)
    N=$(echo "$OUT" | grep -oE 'resumo: [0-9]+' | grep -oE '[0-9]+')
    FD=$(S dmesg | grep -ci 'page fault')
    [ -z "$N" ] && N="ERRO"

    echo "exec=$i flush_mapped_vmids=$W blocos_aliasados=$N faults=$FA->$FD boot=$BOOT" \
        | tee -a "$H"
done

echo "---- resumo (boot $BOOT) ----" | tee -a "$H"
for W in 0 1; do
    L=$(grep "boot=$BOOT" "$H" | grep "flush_mapped_vmids=$W")
    T=$(echo "$L" | grep -c 'blocos_aliasados=')
    SUJOS=$(echo "$L" | grep -cE 'blocos_aliasados=[1-9]')
    DET=$(echo "$L" | grep -oE 'blocos_aliasados=[0-9]+' | cut -d= -f2 | tr '\n' ' ')
    echo "  =$W: $SUJOS de $T execucoes com aliasing   [$DET]" | tee -a "$H"
done
