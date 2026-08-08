# Retornos dos agentes — investigacao SDMA0 (2026-08-08)

Extraido de `agentes/journal.jsonl`. 86 achados, 30 propostas, 18 veredictos de cetico.
Transcricao completa de cada agente nos `agentes/agent-*.jsonl`.

## a6435f5c088e48680  (angulo: Tornar o SDMA0 usavel mesmo se o trap IRQ for perdido no silicio: polling barato de fence, piggyback no ISR existente, e a via de eventos do KFD. Tudo lido na arvore em /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1.)
### Achados
- **[lido-no-codigo]** O fallback timer e de HZ/2 e o kernel roda HZ=1000. Ou seja, a latencia pior-caso de qualquer fence do ring sdma0 hoje e 500 ms, nao um hang. E um timer_list comum, por-ring, ja alocado.
  - evidencia: `drivers/gpu/drm/amd/amdgpu/amdgpu.h:279 `#define AMDGPU_FENCE_JIFFIES_TIMEOUT (HZ / 2)`; amdgpu_fence.c:203-207 (mod_timer); amdgpu_fence.c:479 (timer_setup por ring); /boot/config-7.0.12-1: CONFIG_HZ=1000`
- **[lido-no-codigo]** O fallback timer so e armado quando alguem faz enable_signaling na fence, e so e re-armado dentro de amdgpu_fence_process se ainda houver fence pendente. Nao ha timer periodico rodando de graca. Encurtar o periodo custa CPU apenas enquanto o sdma0 tem trabalho nao sinalizado com waiter ativo.
  - evidencia: `amdgpu_fence.c:844-850 (amdgpu_fence_enable_signaling -> schedule_fallback se !timer_pending); amdgpu_fence.c:232-234 (re-arma so se seq != sync_seq)`
- **[lido-no-codigo]** CRITICO: amdgpu_fence_read() le de ring->fence_drv.cpu_addr, que aponta para adev->wb.wb, um BO criado em AMDGPU_GEM_DOMAIN_GTT. Isso e RAM do host, nao BAR. Portanto fazer polling da fence do sdma0 pelo CPU NAO e leitura MMIO, nao gera transacao PCIe e nao pode pendurar a CPU no fabric. A restricao dura de MMIO nao se aplica a esse caminho.
  - evidencia: `amdgpu_fence.c:79-90 (le *drv->cpu_addr); amdgpu_ring.c:317-320 (fence_cpu_addr = amdgpu_ring_get_cpu_addr); amdgpu_ring.c:229-230 (`&ring->adev->wb.wb[offset]`); amdgpu_device.c:1737-1740 (`amdgpu_bo_create_kernel(..., AMDGPU_GEM_DOMAIN_GTT, &adev->wb.wb_obj, ...)`)`
- **[lido-no-codigo]** sdma_v5_0_process_trap_irq DESCARTA silenciosamente qualquer IV do cliente SDMA0 cujo entry->ring_id nao seja 0. Os cases 1, 2 e 3 sao comentarios `/* XXX compute */` vazios e a funcao retorna 0 sem imprimir nada. A evidencia de dyndbg em amdgpu_irq.c NAO exclui esta hipotese: um IV descartado aqui e um IV que chegou, foi despachado e nao gerou nenhuma mensagem.
  - evidencia: `sdma_v5_0.c:1694-1738, especificamente 1706-1718: `case SOC15_IH_CLIENTID_SDMA0: switch (entry->ring_id) { case 0: amdgpu_fence_process(...); break; case 1: /* XXX compute */ break; ... }``
- **[lido-no-codigo]** ih_soft NAO serve como detector de conclusao. Ele nao tem hardware por tras: navi10_ih_get_wptr trata ih_soft lendo *ih->wptr_cpu (escrito pelo CPU) e navi10_ih_set_rptr retorna imediatamente para ih_soft. amdgpu_irq_delegate so copia um IV que o CPU ja tem em maos e agenda um work. Ele resolve RE-DESPACHO, nunca DETECCAO.
  - evidencia: `amdgpu_irq.c:543-551 (amdgpu_irq_delegate -> amdgpu_ih_ring_write + schedule_work); navi10_ih.c:412-418 (comentario explicito 'ih_soft ring doesn't have any backing hardware registers'); navi10_ih.c:493-494 (set_rptr retorna cedo)`
- **[lido-no-codigo]** ih_soft EXISTE e esta habilitado neste chip (ao contrario de ih1/ih2 que tem ring_size=0). Um IV sintetico injetado nele passa por amdgpu_irq_dispatch normalmente.
  - evidencia: `navi10_ih.c:583-585 (`adev->irq.ih1.ring_size = 0; adev->irq.ih2.ring_size = 0;`) vs navi10_ih.c:586 (`amdgpu_ih_ring_init(adev, &adev->irq.ih_soft, IH_SW_RING_SIZE, true)`) e navi10_ih.c:373-374 (`ih_soft.enabled = true`)`
- **[lido-no-codigo]** Um IV de trap SDMA0 injetado por ih_soft alimentaria TANTO o caminho de fence do amdgpu QUANTO o caminho de eventos do KFD. sdma_v5_0_process_trap_irq retorna 0, entao `handled` fica false em amdgpu_irq_dispatch e o IV e repassado a amdgpu_amdkfd_interrupt.
  - evidencia: `sdma_v5_0.c:1738 (`return 0`); amdgpu_irq.c:513-518 (`else if (r) handled = true;`) e amdgpu_irq.c:527-528 (`if (!handled) amdgpu_amdkfd_interrupt(adev, entry.iv_entry);`)`
- **[lido-no-codigo]** ACHADO MAIS UTIL PARA O KFD: kfd_signal_event_interrupt com valid_id_bits == 0 pula a busca por partial id e faz uma VARREDURA EXAUSTIVA da signal page, sinalizando todo evento cujo slot ja tem valor != UNSIGNALED_EVENT_SLOT. Como o trabalho do SDMA0 TERMINA e a escrita de fence LANDA em memoria, essa varredura acorda corretamente os eventos concluidos sem precisar de nenhum IV. E um caminho ja existente e testado na arvore, usado como fallback quando o partial id nao bate.
  - evidencia: `amdkfd/kfd_events.c:726-784, em especial 743 (`if (valid_id_bits) ev = lookup_signaled_event_by_partial_id(...)`) e 747-778 (bloco `else if (p->signal_page)` que varre slots e chama set_event_from_interrupt)`
- **[lido-no-codigo]** O KFD hoje so chama isso a partir do IV de trap, com valid_id_bits=28 hardcoded. Sem o IV do SDMA0, nada nunca dispara a varredura.
  - evidencia: `amdkfd/kfd_int_process_v10.c:346-347 (`if (source_id == SOC15_INTSRC_SDMA_TRAP) kfd_signal_event_interrupt(pasid, context_id0 & 0xfffffff, 28);`)`
- **[lido-no-codigo]** Existe uma fonte de interrupcao ALTERNATIVA do SDMA0 nunca testada aqui: SDMA0_CNTL.CTXEMPTY_INT_ENABLE (bit 0x1c), que gera o src_id 243 (SDMA_CTXEMPTY). O driver hoje so escreve TRAP_ENABLE (bit 0). Se o problema for especifico do gerador de trap e nao da rota do cliente SDMA0 inteira, esse bit entrega conclusao por outro caminho.
  - evidencia: `include/asic_reg/gc/gc_10_1_0_sh_mask.h:100 e :113 (CTXEMPTY_INT_ENABLE shift 0x1c / mask 0x10000000L); include/ivsrcid/sdma0/irqsrcs_sdma0_5_0.h: `SDMA0_5_0__SRCID__SDMA_CTXEMPTY 243`; sdma_v5_0.c:1673-1691 (set_trap_irq_state so mexe em TRAP_ENABLE)`
- **[inferido]** O teste de dyndbg NAO prova que a rota de IV do cliente SDMA0 esta morta para todos os src_ids. Ele prova apenas que nenhum src_id NAO REGISTRADO do SDMA0 apareceu. Como CTXEMPTY_INT_ENABLE esta desligado por default, o hardware nunca teria gerado esse IV de qualquer forma. O experimento CTXEMPTY e informacao genuinamente nova.
  - evidencia: `sdma_v5_0.c:1673-1691 nunca seta CTXEMPTY_INT_ENABLE; amdgpu_irq.c:505-527 so imprime para src/client desconhecidos`
- **[inferido]** TENSAO NAO RESOLVIDA que vale citar em voz alta: para o ring do kernel, a fence COMPLETA em memoria (por isso amdgpu_fence_fallback avisa). Mas no caso HSA_ENABLE_SDMA=1 o userspace gira a 199% em estado R. Se o ROCm estivesse dormindo no ioctl de evento estaria em S; girar em R significa busy-poll em memoria. Se o valor de conclusao landasse em memoria, o busy-poll TERIA visto. Isso sugere que na fila de USUARIO do SDMA0 a escrita de fence tambem nao landa, o que seria um problema diferente e mais grave que IRQ perdido. E testavel do userspace, sem reboot.
  - evidencia: `amdkfd/kfd_events.c:1030 (`timeout = schedule_timeout(timeout)` -- espera dormindo, nao girando); contraste com a medicao de 199% CPU em estado R fornecida no briefing`
- **[lido-no-codigo]** O sdma0 e o buffer_funcs_ring (todo blit de TTM) e participa dos vm_pte_scheds. Qualquer correcao por polling precisa cobrir esses dois, nao so o KFD.
  - evidencia: `sdma_v5_0.c:2051 (`adev->mman.buffer_funcs_ring = &adev->sdma.instance[0].ring;`); sdma_v5_0.c:2069 (`adev->vm_manager.vm_pte_scheds[i] = ...`)`
- **[lido-no-codigo]** amdgpu_ih_process ja e chamado a cada IRQ da GPU e drena o anel 0. Qualquer interrupcao (vblank, EOP do gfx, trap do sdma1) e uma oportunidade gratuita de checar a fence do sdma0.
  - evidencia: `amdgpu_irq.c:200-213 (amdgpu_irq_handler -> amdgpu_ih_process); amdgpu_ih.c:208-247 (laco de drenagem)`
- **[lido-no-codigo]** RECOMENDACAO DE METODO: por causa de 'reload a quente falha, todo teste custa reboot', todos os experimentos abaixo devem ser module_param 0644 (grava em runtime), no modelo do bc250_tlb_extra_types que ja existe nesta arvore. Um unico build e um unico reboot passam a cobrir uma matriz inteira de configuracoes.
  - evidencia: `amdgpu_gmc.c:776-778 (`int bc250_tlb_extra_types; module_param(bc250_tlb_extra_types, int, 0644);`) -- precedente ja no repo, 0644 e nao 0444`

### Propostas
- **P0 -- Parar de descartar IVs do SDMA0 com ring_id != 0, e imprimir o que chega** — 1 reboot(s), risco baixo
  - mecanismo: sdma_v5_0_process_trap_irq (sdma_v5_0.c:1706-1718) so chama amdgpu_fence_process para ring_id==0; ring_id 1..3 caem em cases vazios e a funcao retorna 0 sem log nenhum. Se o SDMA0 do Oberon reportar ring_id diferente do SDMA1 (encoding de fila RLC/paging, ou campo com lixo), o IV CHEGA, e despachado, e some sem deixar rastro -- exatamente o quadro observado. Isso reconcilia 'zero mensagens de dyndbg' com 'fence nunca processada' sem exigir que o silicio esteja quebrado.
  - mudanca: sdma_v5_0.c, em sdma_v5_0_process_trap_irq (linha 1694):

    dev_info_ratelimited(adev->dev,
        "SDMA IV: client=%u src=%u ring=%u vmid=%u d0=0x%08x d1=0x%08x\n",
        entry->client_id, entry->src_id, entry->ring_id,
        entry->vmid, entry->src_data[0], entry->src_data[1]);

    switch (entry->client_id) {
    case SOC15_IH_CLIENTID_SDMA0:
        amdgpu_fence_process(&adev->sdma.instance[0].ring);
        break;
    case SOC15_IH_CLIENTID_SDMA1:
        amdgpu_fence_process(&adev->sdma.instance[1].ring);
        break;
    }
    return 0;

Ou seja: apagar o switch interno de ring_id. Chamar amdgpu_fence_process no ring do kernel para um IV de fila RLC e inofensivo -- a funcao so le a fence em RAM e nao sinaliza nada se seq nao mudou (amdgpu_fence.c:236-237).
  - teste: Boot frio. `dmesg | grep 'SDMA IV'`. Se aparecerem linhas com client=<SDMA0> e ring != 0, o IRQ NAO esta perdido -- esta sendo jogado fora pelo driver, e o bug acabou. Se so aparecerem linhas do SDMA1 e o 'Fence fallback timer expired on ring sdma0' continuar, a hipotese esta refutada de forma definitiva e o IV realmente nao chega. Sinal exato: presenca ou ausencia de qualquer linha 'SDMA IV: client=<id do SDMA0>'.
- **P1 -- Periodo de fallback timer por-ring, curto so no sdma0 (workaround por polling, assumido)** — 1 reboot(s), risco baixo
  - mecanismo: Nao conserta o IRQ. Troca a latencia de deteccao de 500 ms (HZ/2 com HZ=1000, amdgpu.h:279) por 1-2 ms, para o ring de kernel do sdma0 -- que e o buffer_funcs_ring de TODO blit do TTM (sdma_v5_0.c:2051). A deteccao e uma leitura de RAM do host (adev->wb em GTT), nao MMIO, entao nao viola a restricao dura e nao pode pendurar a CPU.
  - mudanca: 1) amdgpu_ring.h, struct amdgpu_fence_driver (linha ~118-132): adicionar `unsigned int fallback_period;` depois de fallback_timer.
2) amdgpu_fence.c:203-207:

    mod_timer(&ring->fence_drv.fallback_timer,
              jiffies + (ring->fence_drv.fallback_period ?:
                         AMDGPU_FENCE_JIFFIES_TIMEOUT));

3) amdgpu_fence.c:479 (init_ring): `ring->fence_drv.fallback_period = AMDGPU_FENCE_JIFFIES_TIMEOUT;`
4) sdma_v5_0.c, em sdma_v5_0_sw_init, depois do amdgpu_ring_init da instancia 0, com module_param `int bc250_sdma0_fallback_ms = 0;` (0644):

    if (i == 0 && bc250_sdma0_fallback_ms)
        ring->fence_drv.fallback_period =
            max(1u, msecs_to_jiffies(bc250_sdma0_fallback_ms));

Custo medido, nao chutado: o timer so roda enquanto ha fence do sdma0 nao sinalizada COM waiter (amdgpu_fence.c:844-850 arma; 232-234 re-arma). Cada disparo e uma leitura de RAM + um atomic_cmpxchg + timer_delete, ordem de 1-2 us. A 1 ms de periodo isso e no maximo ~0,2% de um core, e apenas durante trabalho pendente. Comparar com os 199% de CPU atuais e comparar peras com bananas: os 199% sao do caminho de fila de USUARIO do KFD, que esta proposta NAO toca (ver P3).
  - teste: Runtime, sem reboot depois do primeiro: `echo 1 > /sys/module/amdgpu/parameters/bc250_sdma0_fallback_ms`. Depois medir uma sequencia de moves de TTM (alocar/evictar BOs grandes, ou trocar de resolucao) e cronometrar. Sinal exato: as mensagens 'Fence fallback timer expired on ring sdma0' continuam aparecendo (isso e esperado e correto), mas o intervalo entre submissao e conclusao cai de ~500 ms para <2 ms. Medir com ftrace em amdgpu_fence_emit/dma_fence_signal, ou simplesmente cronometrar N moves.
- **P2 -- Piggyback: checar a fence do sdma0 no fim de todo IRQ da GPU** — 0 reboot(s), risco baixo
  - mecanismo: Complementa P1 e cobre o buraco dele: o timer so ajuda quando ha waiter, e a 1 ms ainda paga latencia. amdgpu_irq_handler ja roda a cada IRQ do dispositivo (amdgpu_irq.c:206). Toda interrupcao nao relacionada -- vblank, EOP do gfx, trap do SDMA1 que FUNCIONA -- vira uma checagem gratuita da fence do sdma0. Sob carga a latencia efetiva vai para perto de zero; parado, o P1 segura o limite.
  - mudanca: amdgpu_irq.c, em amdgpu_irq_handler logo apos a linha 206, guardado por module_param 0644 `bc250_sdma0_isr_poll`:

    ret = amdgpu_ih_process(adev, &adev->irq.ih);
    if (bc250_sdma0_isr_poll && adev->sdma.num_instances &&
        adev->sdma.instance[0].ring.fence_drv.initialized)
        amdgpu_fence_process(&adev->sdma.instance[0].ring);

Custo: uma leitura de RAM e um cmpxchg por interrupcao, em hardirq. Sub-microsegundo. amdgpu_fence_process ja e chamada de contexto de interrupcao em dezenas de drivers da arvore (sdma_v5_0.c:1709, gfx_v10_0.c:9247, etc), entao o contexto e legitimo.
  - teste: Runtime. Com um `glxgears` ou qualquer coisa gerando vblank/EOP, ligar `bc250_sdma0_isr_poll=1` e repetir a medicao de latencia do P1. Sinal exato: as mensagens 'Fence fallback timer expired on ring sdma0' devem PARAR de aparecer (porque o ISR processou a fence antes do timer disparar, e amdgpu_fence_fallback so avisa quando ele proprio encontra a fence -- amdgpu_fence.c:283-286). Sumico da mensagem = confirmado. Mensagem persistindo = a GPU nao esta gerando interrupcao nenhuma naquele intervalo.
- **P3 -- ESTE e o que permite remover bc250_skip_sdma0: varredura exaustiva da signal page do KFD** — 1 reboot(s), risco medio
  - mecanismo: Reusa um caminho que JA EXISTE e ja e exercitado na arvore. kfd_signal_event_interrupt(pasid, X, 0) com valid_id_bits==0 ignora o partial id e varre a signal page inteira, sinalizando todo evento cujo slot ja tem valor de conclusao (kfd_events.c:743-778). Como o trabalho do SDMA0 TERMINA e a escrita de fence landa em memoria, a varredura acorda os eventos certos sem nenhum IV. Isso remove a unica razao pela qual as filas de usuario do SDMA0 precisam ser evitadas -- e portanto devolve os slots de fila.
  - mudanca: amdkfd/kfd_events.c, no laco de espera de kfd_wait_on_events (linhas 997-1032), com module_param 0644 `bc250_kfd_poll_ms`:

    if (timeout <= 0)
        break;

    if (bc250_kfd_poll_ms) {
        long slice = msecs_to_jiffies(bc250_kfd_poll_ms);
        timeout -= slice - schedule_timeout(min(timeout, slice));
        __set_current_state(TASK_RUNNING);
        kfd_signal_event_interrupt(p->pasid, 0, 0);
    } else {
        timeout = schedule_timeout(timeout);
    }

(ajustar a contabilidade do timeout com cuidado; e o unico ponto delicado. Verificar tambem o nome do campo pasid em struct kfd_process nesta versao -- kfd_events.c:736 usa kfd_lookup_process_by_pasid(pasid, NULL), entao o pasid tem que vir de onde o chamador ja o tem.)

Custo: uma varredura por bc250_kfd_poll_ms, so enquanto um processo esta dormindo esperando evento. Com poucos eventos e um walk do event_idr (kfd_events.c:763-770), microsegundos. A 1 ms de periodo, <<1% de um core -- contra os 199% de hoje.

ADMISSAO EXPLICITA: isto e um workaround por polling, nao a entrega do IRQ. Satisfaz o criterio 'conclusao detectada de forma confiavel e barata' que o objetivo permite, e o custo esta quantificado acima.
  - teste: PRE-REQUISITO SEM REBOOT, faca primeiro: com bc250_skip_sdma0=1 ainda ativo, rodar o caso HSA_ENABLE_SDMA=1 e checar se o processo fica em R (busy-poll) ou em S (dormindo no ioctl) via /proc/<pid>/stat e /proc/<pid>/wchan. Se estiver em R a 199%, P3 NAO vai ajudar -- significa que o userspace nem chega a dormir no evento, e a conclusao provavelmente nao esta landando em memoria na fila de usuario, o que e um bug diferente. Se estiver em S dentro de kfd_wait_on_events, P3 e o conserto exato.
Depois do build: boot com bc250_skip_sdma0=0, `echo 1 > /sys/module/amdgpu/parameters/bc250_kfd_poll_ms`, rodar HSA_ENABLE_SDMA=1. Sinal exato: a copia enfileirada no SDMA0 completa e o chamador retorna em vez de girar; CPU do processo cai de 199% para perto de zero durante a espera.
- **P4 -- Fonte de interrupcao alternativa: SDMA0_CNTL.CTXEMPTY_INT_ENABLE** — 1 reboot(s), risco medio
  - mecanismo: Unica proposta aqui que poderia entregar um IRQ DE VERDADE em vez de polling. O driver so escreve TRAP_ENABLE (bit 0) em SDMA0_CNTL (sdma_v5_0.c:1673-1691). O mesmo registrador tem CTXEMPTY_INT_ENABLE (bit 0x1c), que gera o src_id 243 quando a engine esvazia o contexto. Se o defeito for do gerador de trap especificamente, e nao da rota de IV do cliente SDMA0 inteira, esse bit entrega 'terminei' por outro src_id -- e ai basta chamar amdgpu_fence_process. Se nem esse IV chegar, esta provado que a rota de IV do cliente SDMA0 esta morta por completo, o que hoje NAO esta provado (o teste de dyndbg nao podia ver isso, porque com o bit desligado o hardware nunca gerou o IV).
  - mudanca: 1) sdma_v5_0.c, sw_init: registrar o src novo:
    amdgpu_irq_add_id(adev, SOC15_IH_CLIENTID_SDMA0,
                      SDMA0_5_0__SRCID__SDMA_CTXEMPTY, &adev->sdma.trap_irq);
(mesmo irq_src; o process ja discrimina por client_id apos P0)
2) sdma_v5_0.c, sdma_v5_0_set_trap_irq_state (linha 1673), com module_param 0644 `bc250_sdma0_ctxempty`:
    if (bc250_sdma0_ctxempty && type == AMDGPU_SDMA_IRQ_INSTANCE0)
        sdma_cntl = REG_SET_FIELD(sdma_cntl, SDMA0_CNTL,
                                  CTXEMPTY_INT_ENABLE, 1);
3) O dev_info_ratelimited do P0 ja mostra src_id, entao nao precisa de log extra.
Escrita de MMIO a partir do contexto do driver, permitida pelas restricoes. NAO exige reinit da GPU se feita via amdgpu_irq_update, mas o caminho mais simples e setar no hw_init -- ai custa o reboot.
  - teste: Boot frio com amdgpu.bc250_sdma0_ctxempty=1. Sinal exato: aparecer no dmesg qualquer linha do P0 com src=243 e client=<SDMA0>. Se aparecer: a rota de IV do cliente SDMA0 esta VIVA, so o trap esta quebrado, e existe conserto por IRQ real (nao polling) -- prossiga por ai e descarte P1/P2/P3. Se NAO aparecer nenhuma linha src=243 do SDMA0 enquanto o SDMA1 continua funcionando normal: fica provado que a rota inteira de IV do cliente SDMA0 esta morta no silicio, e P1+P2+P3 passam a ser a resposta final. Os dois resultados sao informacao dura -- e por isso este experimento tem a melhor razao informacao/reboot da lista.
- **P5 -- CONSIDERADAS E REJEITADAS (registrado para nao serem re-tentadas)** — 0 reboot(s), risco baixo
  - mecanismo: (a) Injetar o IV de conclusao do SDMA0 por ih_soft: NAO FUNCIONA como conserto. ih_soft nao tem hardware por tras (navi10_ih.c:412-418 diz isso literalmente; set_rptr retorna cedo em :493). amdgpu_irq_delegate (amdgpu_irq.c:543-551) so re-despacha um IV que o CPU JA TEM. Voce ainda precisa de um gatilho para saber que a copia terminou -- e se voce ja tem esse gatilho (o polling do P1/P2), nao precisa do ih_soft. Ele so ganharia utilidade como VEICULO se voce quisesse que a deteccao por polling tambem alimentasse o KFD sem tocar em kfd_events.c: nesse caso amdgpu_irq_delegate com um IV sintetico de client SDMA0/src 224 faria o dispatch normal e cairia em amdgpu_amdkfd_interrupt (amdgpu_irq.c:527-528, porque process retorna 0). Mas voce nao sabe o pasid nem o context_id para preencher, e o P3 chega no mesmo lugar direto e mais barato.
(b) Encadear SDMA1 como notificador do SDMA0 via SDMA_OP_POLL_REGMEM (opcode 8, vega10_sdma_pkt_open.h:33) seguido de SDMA_OP_TRAP: tecnicamente possivel e o trap do SDMA1 funciona, mas prende a engine 1 girando num poll de hardware, dobra as submissoes, e trava a engine 1 para sempre se o SDMA0 nao completar. Pior que um timer de 1 ms em todos os eixos.
(c) Bit de 'interrupt on completion' no proprio pacote FENCE: NAO EXISTE. sdma_v5_0_ring_emit_fence (sdma_v5_0.c:523-553) emite SDMA_OP_FENCE e depois, separadamente, um SDMA_OP_TRAP quando AMDGPU_FENCE_FLAG_INT esta setado. O formato do pacote FENCE nao tem campo de interrupcao. A unica via de interrupcao por pacote e o TRAP.
  - mudanca: Nenhuma. Este item existe para fechar becos sem saida.
  - teste: N/A -- rejeicao baseada em leitura de codigo, nao em medicao.

## accd8d8a1d7168af4  (angulo: TRAP_ENABLE e ordem de inicializacao — hipotese CONFIRMADA, mas com um desfecho que inverte o diagnostico: o IRQ do SDMA0 nao se perde no boot, ele ainda nao esta habilitado. Consequencia: a mensagem de fence fallback e um falso positivo e deve sair da pilha de evidencias do problema real do KFD.)
### Achados
- **[lido-no-codigo]** Ninguem habilita o TRAP_ENABLE do SDMA durante o hw_init. amdgpu_fence_driver_start_ring() so grava ponteiros e marca initialized=true; nao chama amdgpu_irq_get(). O unico amdgpu_irq_get() do trap_irq esta em amdgpu_fence_driver_hw_init(), que itera adev->rings[] e chama amdgpu_irq_get(adev, ring->fence_drv.irq_src, ring->fence_drv.irq_type).
  - evidencia: `amdgpu_fence.c:427-452 (start_ring, sem irq_get) e amdgpu_fence.c:639-654 (hw_init -> amdgpu_irq_get). amdgpu_ring.c:346 chama start_ring de dentro de amdgpu_ring_init.`
- **[lido-no-codigo]** No caminho de boot frio, amdgpu_fence_driver_hw_init() so roda DEPOIS de amdgpu_device_ip_init() retornar inteiro. Ou seja: sdma_v5_0_hw_init, sdma_v5_0_start, gfx_resume, ring test, init dos schedulers, amdgpu_ttm_set_buffer_funcs_status(true) e amdgpu_amdkfd_device_init() TODOS rodam com SDMA0_CNTL.TRAP_ENABLE = 0.
  - evidencia: `amdgpu_device.c:4746 (r = amdgpu_device_ip_init(adev)) seguido de amdgpu_device.c:4753 (amdgpu_fence_driver_hw_init(adev)) e :4756 (dev_info "SE %d, SH per SE ..."). Dentro de ip_init: :3157 init_schedulers, :3161-3163 amdgpu_ttm_set_buffer_funcs_status(adev, true), :3167 amdgpu_amdkfd_device_init(adev).`
- **[lido-no-codigo]** O timer de fallback so e armado quando alguem pede sinalizacao numa fence (dma_fence wait). Nao e armado pelo ring test. Logo o ring test do sdma0, que passa em boot frio, nunca produziria a mensagem — e realmente nao produz.
  - evidencia: `amdgpu_fence.c:844-848 (amdgpu_fence_enable_signaling -> amdgpu_fence_schedule_fallback) e amdgpu_fence.c:883 (.enable_signaling). sdma_v5_0.c:1012-1058 (ring_test_ring faz polling em adev->wb.wb[], sem fence).`
- **[lido-no-codigo]** AMDGPU_FENCE_JIFFIES_TIMEOUT = HZ/2 e este kernel tem CONFIG_HZ=1000, ou seja fallback = 500 ms. As duas mensagens de boot estao separadas por exatamente 504 ms e 505 ms — a assinatura de dois waits consecutivos resolvidos pelo timer, nao pelo IRQ.
  - evidencia: `amdgpu.h:279 (#define AMDGPU_FENCE_JIFFIES_TIMEOUT (HZ / 2)); .config:554 CONFIG_HZ=1000; dmesg boot atual: [10.946015] e [11.450086].`
- **[lido-no-codigo]** MEDIDO, n=4 boots: SEMPRE exatamente 2 mensagens, e a segunda cai 0,5 a 1,5 ms ANTES do dev_info de amdgpu_device.c:4756 — isto e, imediatamente antes de amdgpu_fence_driver_hw_init(). Boot atual: 10.946015 / 11.450086, com "BC-250: user SDMA queues restricted to engines 1..1" em 11.450658 e "SE 2, SH per SE 2" em 11.451538. Boot -1: 12.835 / 13.339 -> 13.3405. Boot -2: 173.450 / 173.955 -> 173.956. Boot -3: 10.370 / 10.874 -> 10.8757.
  - evidencia: `journalctl -k -b {0,-1,-2,-3} -o short-monotonic. O print "restricted to engines" e de kfd_device_queue_manager.c:196, ou seja roda dentro de amdgpu_amdkfd_device_init (amdgpu_device.c:3167), ainda dentro de ip_init.`
- **[inferido]** A primeira mensagem (10.946015) e seguida 260 us depois por "kfd kfd: Allocated 3969056 bytes on gart" (10.946275), e a segunda (11.450086) por "Virtual CRAT table created for GPU" (11.451147). Isto e: as alocacoes GART do KFD estavam BLOQUEADAS esperando uma fence do sdma0 e destravaram no instante exato em que o timer de fallback a sinalizou.
  - evidencia: `dmesg boot atual, linhas 1260-1268. Caminho: amdgpu_amdkfd_alloc_gtt_mem -> TTM move -> amdgpu_copy_buffer no adev->mman.buffer_funcs_ring (= sdma0) -> dma_fence_wait.`
- **[lido-no-codigo]** CONTRADIZ UM FATO DADO. A premissa "o trabalho terminou e a INTERRUPCAO se perdeu" nao vale para as mensagens de boot. amdgpu_fence_fallback() de fato so avisa quando achou fence completa, mas nesse instante o TRAP_ENABLE do SDMA0 ainda e 0 — a interrupcao nunca foi ligada, entao nao ha nada de perdido. A engine executou certo e nao havia quem avisasse.
  - evidencia: `Cruzamento de amdgpu_device.c:4746 vs :4753 com os timestamps acima. Nenhuma escrita de TRAP_ENABLE ocorre antes disso: unica escrita e sdma_v5_0_set_trap_irq_state (sdma_v5_0.c:1673-1691), chamada so via src->funcs->set a partir de amdgpu_irq_update (amdgpu_irq.c:562-582).`
- **[lido-no-codigo]** CONTRADIZ UMA ELIMINACAO DADA. "Zero linhas de Unregistered/Invalid com dyndbg em amdgpu_irq.c" NAO prova que o IV nao chega. amdgpu_irq_dispatch() nao imprime absolutamente nada no caminho de sucesso: quando a source existe, ele vai direto para src->funcs->process() sem dev_dbg. Os tres dev_dbg existentes cobrem apenas client_id invalido, src_id invalido e source nao registrada.
  - evidencia: `amdgpu_irq.c:497-524. O ramo de sucesso e o `else if ((src = adev->irq.client[client_id].sources[src_id]))` em :513-519 — so tem dev_err em caso de r<0.`
- **[lido-no-codigo]** O IRQ de trap do SDMA0 FUNCIONA depois do init. Nesta maquina, 10 min de uptime com desktop: sdma0 tem Last emitted = 0x0d e Last signaled = 0x0d, e apenas 2 mensagens de fallback no boot inteiro (as duas pre-trap-enable). As fences 3..13 do sdma0 foram sinalizadas sem o timer disparar. 26749 interrupcoes MSI-X no vetor do amdgpu.
  - evidencia: `/sys/kernel/debug/dri/1/amdgpu_fence_info (ring 10 sdma0: signaled 0x0000000d / emitted 0x0000000d; ring 11 sdma1: 0x01/0x01); /proc/interrupts linha 58 PCI-MSIX-0000:01:00.0 amdgpu = 26749; journalctl -k -b | grep -c 'fallback timer expired' = 2.`
- **[inferido]** A assimetria sdma0 vs sdma1 no boot e ARTEFATO, nao sintoma. adev->mman.buffer_funcs_ring = sdma0, entao na janela entre buffer_funcs_status(true) (amdgpu_device.c:3163) e fence_driver_hw_init (:4753) so o sdma0 recebe trabalho com fence esperada. Ninguem espera fence no sdma1 nessa janela — por isso ele nunca aparece. Coerente com o fence_info: sdma1 emitiu 1 fence a vida toda.
  - evidencia: `sdma_v5_0.c:1370 sdma_v5_0_set_buffer_funcs(adev); amdgpu_device.c:3161-3163; amdgpu_fence_info mostrando sdma1 emitted=0x01.`
- **[lido-no-codigo]** Nenhuma das suspeitas de clobber se sustenta. (a) golden_settings_sdma_cyan_skillfish nao toca mmSDMA0_CNTL/mmSDMA1_CNTL — so CHICKEN_BITS, GB_ADDR_CONFIG, *_WPTR_POLL_CNTL e UTCL1_PAGE; alem disso e aplicado no inicio do hw_init, muito antes do trap. (b) sdma_v5_0_ctx_switch_enable e read-modify-write (RREG32 -> REG_SET_FIELD AUTO_CTXSW_ENABLE -> WREG32), preserva TRAP_ENABLE. (c) O bloco UTC_L1_ENABLE/MIDCMD_PREEMPT_ENABLE do gfx_resume_instance tambem e RMW. (d) Tudo isso e simetrico entre instancia 0 e 1 (mesmo laco for i).
  - evidencia: `sdma_v5_0.c:207-236 (golden array), :1466 (init_golden_registers no topo do hw_init), :629-643 (ctx_switch RMW), :791-798 (gfx_resume RMW), :1673-1691 (set_trap_irq_state RMW simetrico).`
- **[lido-no-codigo]** Se alguem quiser habilitar o trap cedo, e seguro: amdgpu_irq_dispatch nao consulta src->enabled_types antes de chamar process(). Um IV que chegue antes do amdgpu_irq_get sera processado normalmente por sdma_v5_0_process_trap_irq -> amdgpu_fence_process.
  - evidencia: `amdgpu_irq.c:513-519 (dispatch chama process direto); amdgpu_irq.c:626-640 (enabled_types so controla a escrita no hardware).`
- **[inferido]** Filas de USUARIO do KFD no SDMA nao passam por sdma_v5_0_process_trap_irq de forma util: para ring_id 1..3 o handler nao faz nada e retorna 0, o que deixa handled=false e faz amdgpu_irq_dispatch repassar o IV para amdgpu_amdkfd_interrupt(). Ou seja, o sintoma de userspace (HSA_ENABLE_SDMA=1 girando) depende do caminho do KFD, nao do SDMA0_CNTL.TRAP_ENABLE — que ja esta ligado e comprovadamente entregando.
  - evidencia: `sdma_v5_0.c:1694-1740 (cases 1/2/3 vazios, return 0); amdgpu_irq.c:526-528 (if (!handled) amdgpu_amdkfd_interrupt).`

### Propostas
- **Fechar a questao com custo zero: amdgpu_test_ib pelo debugfs** — 0 reboot(s), risco baixo
  - mecanismo: amdgpu_ib_ring_tests() roda um IB em TODOS os rings, inclusive sdma0 e sdma1, e faz dma_fence_wait_timeout — o que arma o fallback timer (amdgpu_fence.c:844-848). Se o trap do SDMA0 estivesse morto depois do init, este teste geraria uma nova linha 'Fence fallback timer expired on ring sdma0' ~500 ms depois. Isto decide, sem reboot, se ha ou nao IRQ perdido em regime normal — que e a pergunta que a mensagem de boot fez todo mundo responder errado.
  - mudanca: Nenhuma mudanca de codigo. Executar:

  sudo dmesg -C   # ou anotar o timestamp atual
  sudo cat /sys/kernel/debug/dri/1/amdgpu_test_ib
  sleep 2
  sudo dmesg | grep -c 'fallback timer expired'

O arquivo ja existe: amdgpu_debugfs.c:2157 debugfs_create_file("amdgpu_test_ib", 0400, root, adev, &amdgpu_debugfs_test_ib_fops); handler em amdgpu_debugfs.c:1639-1692.
  - teste: Sinal que REFUTA a tese de IRQ perdido: saida 'ib ring tests passed.' e ZERO novas linhas de fallback. Sinal que CONFIRMA IRQ perdido em regime: aparece 'Fence fallback timer expired on ring sdma0' (e nao sdma1) logo apos o teste. Repetir 3x conforme a regra de n>=3.
- **Segunda confirmacao sem reboot: forcar trafego TTM no sdma0 e olhar o contador de fences** — 0 reboot(s), risco baixo
  - mecanismo: buffer_funcs_ring e o sdma0 (sdma_v5_0.c:1370). Forcar evicao de VRAM gera varias copias no sdma0 com fence esperada. Se o trap estiver entregando, o sdma0 avanca dezenas de fences sem nenhuma mensagem de fallback; se estiver perdido, cada wait custa 500 ms e loga.
  - mudanca: Nenhuma mudanca de codigo:

  sudo cat /sys/kernel/debug/dri/1/amdgpu_fence_info | grep -A2 'sdma0'
  echo 1 | sudo tee /sys/kernel/debug/dri/1/amdgpu_evict_vram
  sudo cat /sys/kernel/debug/dri/1/amdgpu_fence_info | grep -A2 'sdma0'
  sudo dmesg | tail -20

(amdgpu_debugfs_evict_vram existe em amdgpu_debugfs.c, logo apos test_ib.) Nota: amdgpu_fence_info NAO faz MMIO — le adev->wb / fence_drv.cpu_addr (amdgpu_fence.c:890-930). Respeita a restricao dura.
  - teste: Delta de 'Last emitted' do sdma0 grande e 'Last signaled' igual a 'Last emitted', com zero linhas novas de fallback => IRQ entregando. Qualquer linha de fallback nova => IRQ realmente perdido em regime, e ai a hipotese de ordem morre e sobra hardware/IH.
- **Patch: habilitar TRAP_ENABLE dentro do gfx_resume, em vez de esperar o fim do amdgpu_device_init** — 1 reboot(s), risco baixo
  - mecanismo: Elimina a janela em que amdgpu_amdkfd_device_init espera fences do sdma0 sem trap ligado. Deterministicamente devolve ~1,0 s de boot (2 x 500 ms medidos em 4 boots) e apaga a mensagem que vem envenenando o diagnostico. NAO e correcao do problema do KFD — e higiene de evidencia + boot mais rapido. Digo isso explicitamente para nao vender gato por lebre.
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c, dentro de sdma_v5_0_gfx_resume_instance, no bloco de linhas 791-798:

		temp = RREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_CNTL));
		temp = REG_SET_FIELD(temp, SDMA0_CNTL, UTC_L1_ENABLE, 1);
		temp = REG_SET_FIELD(temp, SDMA0_CNTL, MIDCMD_PREEMPT_ENABLE, 1);
+		/* amdgpu_fence_driver_hw_init() so liga o trap no fim de
+		 * amdgpu_device_init() (amdgpu_device.c:4753), depois de
+		 * amdgpu_amdkfd_device_init() (:3167) ja ter esperado fences
+		 * neste ring. Ligar aqui e seguro: amdgpu_irq_dispatch nao
+		 * consulta enabled_types (amdgpu_irq.c:513). */
+		temp = REG_SET_FIELD(temp, SDMA0_CNTL, TRAP_ENABLE, 1);
		WREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_CNTL), temp);

Variante mais 'upstream' (mas mexe em codigo generico de todas as ASICs): mover amdgpu_fence_driver_hw_init(adev) de amdgpu_device.c:4753 para dentro de amdgpu_device_ip_init, entre :3163 (buffer_funcs_status true) e :3167 (amdkfd_device_init). Prefiro a versao local do sdma_v5_0 por risco menor.
  - teste: Boot e `journalctl -k -b | grep -c 'fallback timer expired'`. Esperado: 0 (era exatamente 2 em 4/4 boots). Confirmar tambem que o delta entre 'irq initialized.' e 'SE 2, SH per SE 2' encolhe ~1,0 s. Rodar 3 boots. Se ainda aparecer fallback DEPOIS do patch, ai sim existe perda real de IRQ e a hipotese de ordem cai.
- **O reboot que vale: contadores por (client_id, ring_id) no trap do SDMA + readback de SDMA0/1_CNTL, com bc250_skip_sdma0 DESLIGADO** — 1 reboot(s), risco medio
  - mecanismo: Ataca o objetivo real. Hoje nao se sabe se, durante o travamento com HSA_ENABLE_SDMA=1, o IV do SDMA0 chega e o KFD e que nao entrega o evento, ou se o IV realmente some. A eliminacao anterior via dyndbg nao responde isso porque o caminho de sucesso do amdgpu_irq_dispatch e mudo (amdgpu_irq.c:513-519). Contadores no proprio handler respondem direto. E o readback de SDMA0_CNTL a partir do contexto do driver mata de vez qualquer residuo da hipotese de clobber, sem violar a proibicao de MMIO cru do userspace.
  - mudanca: 1) sdma_v5_0.c, no topo de sdma_v5_0_process_trap_irq (linha 1694), antes do switch:

+	if (entry->client_id == SOC15_IH_CLIENTID_SDMA0 ||
+	    entry->client_id == SOC15_IH_CLIENTID_SDMA1) {
+		unsigned e = (entry->client_id == SOC15_IH_CLIENTID_SDMA0) ? 0 : 1;
+		atomic_inc(&bc250_sdma_trap_cnt[e][entry->ring_id & 7]);
+	}

com `static atomic_t bc250_sdma_trap_cnt[2][8];` no topo do arquivo e um accessor exportado.

2) amdgpu_debugfs.c, ao lado do bc250_ptwalk ja existente (:2151), um arquivo `bc250_sdma_irq` que imprime a matriz 2x8 de contadores E o valor cru de mmSDMA0_CNTL das duas instancias lido de dentro do driver (RREG32 em contexto de driver e permitido pelas suas restricoes), decodificando TRAP_ENABLE/UTC_L1_ENABLE/AUTO_CTXSW_ENABLE.

3) Neste mesmo boot, remover amdgpu.bc250_skip_sdma0=1 da linha de comando, para que as filas de usuario do KFD voltem a cair na engine 0 e o bug seja reproduzivel.
  - teste: Com a maquina bootada assim, ler `bc250_sdma_irq` (baseline), rodar o repro HSA_ENABLE_SDMA=1 de outra sessao/ssh, e reler durante o giro de 199% CPU. Tres desfechos, todos conclusivos:
(a) contador de SDMA0 com ring_id>0 SOBE enquanto o userspace gira => o IV chega, a perda e a jusante, no KFD (kfd_int_process_v10 / entrega de evento). Proximo angulo deixa de ser SDMA e passa a ser KFD.
(b) contador de SDMA0 fica ZERO enquanto o de SDMA1 sobe na mesma carga => perda real por engine; e ai o readback de TRAP_ENABLE no mesmo arquivo diz se e o bit ou o caminho de IV.
(c) TRAP_ENABLE do SDMA0 lido como 0 nesse instante => existe sim alguem limpando o bit em regime, e a caca vira bisect de quem escreve SDMA0_CNTL.
Rodar 3 repeticoes do repro dentro do mesmo boot (nao custa reboot extra).

## a1f6d6fae15161855  (angulo: Doorbell e roteamento do IH: como o IV do trap do SDMA chega (ou nao) ao anel de IH no gfx10.1 / cyan skillfish (gfx1013), e onde existe uma assimetria por instancia entre SDMA0 (client 8) e SDMA1 (client 9).)
### Achados
- **[lido-no-codigo]** O doorbell NAO pode explicar o IRQ perdido. Doorbell e caminho de SUBMISSAO (CPU -> wptr da engine), nao de conclusao. Como o ring test do sdma0 PASSA em boot frio, o doorbell do sdma0 esta comprovadamente funcionando. Nenhum registrador de doorbell participa da entrega do IV.
  - evidencia: `/home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1/drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c:376-392 (sdma_v5_0_ring_set_wptr -> WDOORBELL64(ring->doorbell_index, ring->wptr << 2)); sdma_v5_0.c:523-553 (emit_fence escreve SDMA_OP_FENCE + SDMA_OP_TRAP; o TRAP e o que gera o IV, sem envolvimento do doorbell)`
- **[lido-no-codigo]** Nao ha sobreposicao nem range de tamanho zero entre os doorbells de SDMA0 e SDMA1. sdma_engine[0]=0x100 e sdma_engine[1]=0x10A (qword); ring->doorbell_index = idx<<1 => 0x200 (inst0) e 0x214 (inst1) em dwords; sdma_v5_0_gfx_resume passa doorbell_size=20 HARDCODED para as duas instancias. Logo inst0 cobre dword [0x200,0x213] e inst1 [0x214,0x227] — adjacentes, sem overlap. Os campos do BIF comportam os valores (OFFSET = bits 2..11, 10 bits, max 0x3FF; SIZE = bits 16..20, 5 bits, max 31).
  - evidencia: `amdgpu_doorbell.h:210-213; nv.c:580-582 (nv_init_doorbell_index) e nv.c:593 (sdma_doorbell_range=20); sdma_v5_0.c:1406-1413; sdma_v5_0.c:782-783; nbio_v2_3.c:108-132; /home/gabriwar/.../drivers/gpu/drm/amd/include/asic_reg/nbio/nbio_2_3_sh_mask.h:2210-2218`
- **[lido-no-codigo]** O doorbell do IH (0x178<<1 = 0x2F0, SIZE=2) tambem nao colide com as faixas de SDMA. nbio_v2_3_ih_doorbell_range grava BIF_IH_DOORBELL_RANGE com OFFSET=doorbell_index e SIZE=2.
  - evidencia: `amdgpu_doorbell.h:215 (AMDGPU_NAVI10_DOORBELL_IH = 0x178); navi10_ih.c:578; nbio_v2_3.c:186-204`
- **[lido-no-codigo]** ACHADO PRINCIPAL — a evidencia do dyndbg NAO prova que o IV do SDMA0 nao chegou. amdgpu_irq_dispatch so imprime quando o client_id/src_id e DESCONHECIDO. Se o IV chega com um par (client_id, src_id) registrado, o dispatch chama src->funcs->process() em SILENCIO ABSOLUTO — nenhuma linha de dev_dbg em amdgpu_irq.c. Portanto 'zero linhas de Unregistered/Invalid' e compativel com 'o IV chegou e foi descartado depois'.
  - evidencia: `amdgpu_irq.c:497-525 — os tres dev_dbg cobrem apenas client_id>=MAX, src_id>=MAX, sources==NULL e sources[src_id]==NULL; o ramo bem-sucedido (linha 513-520) nao imprime nada`
- **[lido-no-codigo]** Existe um caminho de DESCARTE SILENCIOSO dentro do proprio handler do SDMA: se o IV chega com client_id=SDMA0 mas ring_id != 0, o switch cai em 'case 1/2/3' que sao comentarios vazios e nada e sinalizado. Nao ha default, nao ha print. O unico print do handler e um DRM_DEBUG (controlado por drm.debug, NAO por dyndbg em amdgpu_irq.c), entao a instrumentacao usada ate agora nao veria nada.
  - evidencia: `sdma_v5_0.c:1694-1740 (process_trap_irq); em particular 1707-1720: case 1/2/3 vazios; sdma_v5_0.c:1698 DRM_DEBUG("IH: SDMA trap")`
- **[inferido]** Segundo caminho de descarte silencioso: SDMA0 e SDMA1 registram o MESMO src_id (224) no MESMO amdgpu_irq_src (adev->sdma.trap_irq), diferindo so pelo client_id (8 vs 9). Se o SDMA0 do APU de PS5 emitir IVs com client_id=9 (aliasing/troca feita pelo firmware do console), o dispatch acha o source registrado, chama o handler, o handler acredita ser SDMA1 e chama amdgpu_fence_process(&sdma.instance[1].ring) — que nao tem fence pendente e retorna false sem imprimir nada. O sdma0 nunca e sinalizado, e nenhum debug aparece em lugar nenhum.
  - evidencia: `sdma_v5_0.c:1388-1400 (amdgpu_irq_add_id para SOC15_IH_CLIENTID_SDMA0 e SDMA1, mesmo &adev->sdma.trap_irq); include/ivsrcid/sdma0/irqsrcs_sdma0_5_0.h:32 e include/ivsrcid/sdma1/irqsrcs_sdma1_5_0.h:32 — ambos SRCID 224; include/soc15_ih_clientid.h:40-41 (SDMA0=0x08, SDMA1=0x09)`
- **[lido-no-codigo]** O driver navi10_ih.c NUNCA programa os controles de storm/flood/credito do IH. Grep por STORM, FLOOD, CREDIT_ERROR e CLIENT_CFG em navi10_ih.c retorna ZERO ocorrencias. Ou seja: o que quer que o firmware do PS5 tenha deixado em mmIH_STORM_CLIENT_LIST_CNTL, mmIH_INT_FLOOD_CNTL e mmIH_CLIENT_CFG_DATA continua vivo depois do init do Linux.
  - evidencia: `grep -n 'STORM|FLOOD|CREDIT_ERROR|CLIENT_CFG' /home/gabriwar/.../amdgpu/navi10_ih.c => sem saida; por contraste amdgpu/ih_v6_0.c:358-365 faz RMW em regIH_STORM_CLIENT_LIST_CNTL e regIH_INT_FLOOD_CNTL`
- **[lido-no-codigo]** Esses registros dao um botao de assimetria POR CLIENTE, exatamente na granularidade do sintoma: IH_STORM_CLIENT_LIST_CNTL tem CLIENT8_IS_STORM_CLIENT no bit 8 (=SDMA0) e CLIENT9 no bit 9 (=SDMA1); IH_CLIENT_CREDIT_ERROR tem CLIENT_8_ERROR no bit 8 e CLIENT_9_ERROR no bit 9. Cliente marcado como storm + FLOOD_CNTL_ENABLE=1 sofre descarte de IVs; o registro IH_INT_FLOOD_STATUS guarda INT_DROPPED, INT_DROP_CNT e FIRST_DROP_INT_CLIENT_ID/SOURCE_ID — ou seja, o hardware ja registra QUEM foi descartado, e isso e legivel do contexto do driver.
  - evidencia: `include/asic_reg/oss/osssys_5_0_0_offset.h:200-225 (mmIH_INT_FLOOD_CNTL 0x00d5, mmIH_INT_FLOOD_STATUS 0x00d9, mmIH_STORM_CLIENT_LIST_CNTL 0x00da, mmIH_CLIENT_CREDIT_ERROR 0x00e1); osssys_5_0_0_sh_mask.h:512-522 (campos de IH_INT_FLOOD_STATUS), :491-496 (IH_INT_FLOOD_CNTL), :526-556 (CLIENTn_IS_STORM_CLIENT), :690-735 (CLIENT_n_ERROR)`
- **[inferido]** O gfx10.1 tem uma tabela de configuracao de cliente do IH acessivel por indice: mmIH_CLIENT_CFG (TOTAL_CLIENT_NUM), mmIH_CLIENT_CFG_INDEX, mmIH_CLIENT_CFG_DATA, com campos CREDIT_RETURN_ADDR, CLIENT_TYPE, RING_ID e OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID. O psp_v3_1 escreve nessa tabela em outra ASIC, o que prova que ela e programavel por entrada. O amdgpu no navi1x nunca a le nem escreve. Um firmware de console pode ter particionado essa tabela (ex.: RING_ID=1 para o cliente 8, apontando o SDMA0 para um anel de IH que no Linux tem ring_size=0).
  - evidencia: `include/asic_reg/oss/osssys_5_0_0_offset.h:290-295; osssys_4_0_1_sh_mask.h:1089-1105 (campos de IH_CLIENT_CFG_DATA); amdgpu/psp_v3_1.c:161-176 (uso real de REG_SET_FIELD IH_CLIENT_CFG_DATA CLIENT_TYPE/RING_ID/CREDIT_RETURN_ADDR)`
- **[inferido]** Se o cliente 8 estiver roteado para o anel 1 ou 2 do IH, os IVs somem sem rastro: navi10_ih_sw_init zera ih1.ring_size e ih2.ring_size, e navi10_ih_toggle_interrupts/irq_init pulam qualquer anel com ring_size==0. Isso confirma o fato ja medido pelo usuario, mas mostra que a combinacao 'IH_CLIENT_CFG_DATA.RING_ID != 0 para o cliente 8' + 'aneis 1/2 desabilitados' produz exatamente o sintoma observado.
  - evidencia: `navi10_ih.c:580-581 (ih1.ring_size=0, ih2.ring_size=0); navi10_ih.c:196-212 (toggle so mexe em ih[i] com ring_size); navi10_ih.c:345-352 (enable_ring so para ring_size != 0)`
- **[inferido]** O mecanismo de force-update de wptr para self-interrupt NAO esta ativo neste chip (retorna cedo porque OSSSYS < 5.0.3), entao nao ha nada de IH_CNTL2/IH_RB_CNTL_RING1 mexendo aqui. Elimina essa via.
  - evidencia: `navi10_ih.c:105-111 (return se amdgpu_ip_version(OSSSYS) < IP_VERSION(5,0,3)); amdgpu_discovery.c:2904 mostra OSSSYS=IP_VERSION(5,0,1) para o caminho non-SKILLFISH2; para o BC-250 (SKILLFISH2) a versao vem da discovery e o usuario reporta 5.0.2 — em ambos os casos < 5.0.3`
- **[lido-no-codigo]** Nao existe assimetria nos registradores golden nem no CNTL. golden_settings_sdma_cyan_skillfish tem os MESMOS registradores para SDMA0 e SDMA1 e nenhum deles e SDMA0_CNTL. Todas as escritas em mmSDMA0_CNTL sao read-modify-write, entao TRAP_ENABLE nao e clobbado por gfx_resume nem por ctx_switch_enable.
  - evidencia: `sdma_v5_0.c:187-215 (golden simetrico, sem SDMA0_CNTL); sdma_v5_0.c:793-798 (RMW UTC_L1_ENABLE/MIDCMD_PREEMPT_ENABLE); sdma_v5_0.c:629-643 (RMW AUTO_CTXSW); sdma_v5_0.c:1673-1692 (RMW TRAP_ENABLE)`
- **[lido-no-codigo]** O timer de fallback so e armado quando alguem ESPERA na fence (amdgpu_fence_enable_signaling), com periodo fixo global de HZ/2 = 500 ms. Isso explica por que a mensagem aparece so 2-3 vezes por boot (so quando ha wait) e da o custo exato de um contorno baseado em polling: ate 500 ms de latencia por fence do sdma0.
  - evidencia: `amdgpu_fence.c:845-848 (arma no enable_signaling); amdgpu_fence.c:203-206 (mod_timer com AMDGPU_FENCE_JIFFIES_TIMEOUT); amdgpu.h:279 (#define AMDGPU_FENCE_JIFFIES_TIMEOUT (HZ/2)); amdgpu_fence.c:278-287 (o dev_warn so sai se amdgpu_fence_process retornou true)`
- **[lido-no-codigo]** Todo IV de SDMA e reencaminhado ao KFD porque process_trap_irq sempre retorna 0 (handled=false). Nao e causa do bug, mas significa que o anel de interrupcao do KFD ve os IVs do SDMA e poderia ser usado como segundo ponto de observacao sem tocar no caminho do amdgpu.
  - evidencia: `sdma_v5_0.c:1739 (return 0 incondicional); amdgpu_irq.c:518-529 (handled so vira true se r>0; senao amdgpu_amdkfd_interrupt)`
- **[lido-no-codigo]** CONTRADICAO EXPLICITA COM UM FATO DADO: o briefing afirma 'O IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch. Nao e descarte por id desconhecido.' A segunda metade esta certa; a primeira nao esta demonstrada. Descarte por id CONHECIDO (ring_id != 0, ou client_id aliasado para 9) e 100% silencioso no dyndbg de amdgpu_irq.c. Minhas propostas 1 e 2 tratam justamente disso.
  - evidencia: `amdgpu_irq.c:513-520 (ramo bem sucedido sem print) + sdma_v5_0.c:1705-1738 (switch sem default)`

### Propostas
- **Boot instrumentado unico que fecha o espaco de hipoteses do IH (diagnostico, zero mudanca de comportamento)** — 1 reboot(s), risco baixo
  - mecanismo: Separa de uma vez 'o IV nunca chega ao anel de IH' de 'o IV chega e e descartado por ring_id/client_id', e ao mesmo tempo le os registradores de storm/flood/credito/roteamento do IH que o navi10_ih.c nunca toca e que o firmware do PS5 pode ter particionado. Todas as leituras sao MMIO a partir do contexto do driver, permitidas.
  - mudanca: Arquivo /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1/drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c, em sdma_v5_0_process_trap_irq (linha 1694):

  static atomic_t sdma_iv_log = ATOMIC_INIT(64);
  if (atomic_dec_if_positive(&sdma_iv_log) >= 0)
      dev_info(adev->dev, "SDMA IV: client=%u src=%u ring_id=%u vmid=%u pasid=%u d0=%08x d1=%08x\n",
               entry->client_id, entry->src_id, entry->ring_id,
               entry->vmid, entry->pasid, entry->src_data[0], entry->src_data[1]);

e adicionar em AMBOS os switch(entry->ring_id) um:
      default: dev_warn_ratelimited(adev->dev, "SDMA trap DESCARTADO client=%u ring_id=%u\n", entry->client_id, entry->ring_id); break;
(e trocar os 'case 1/2/3' vazios por esse mesmo warn, senao continuam silenciosos).

Arquivo .../amdgpu/navi10_ih.c: nova funcao navi10_ih_dump_state(adev, const char *when) chamada (a) no fim de navi10_ih_irq_init (linha ~377) e (b) de um delayed_work agendado para +8 s. Dump:
  RREG32_SOC15(OSSSYS,0,mmIH_STORM_CLIENT_LIST_CNTL)
  RREG32_SOC15(OSSSYS,0,mmIH_INT_FLOOD_CNTL)
  RREG32_SOC15(OSSSYS,0,mmIH_INT_FLOOD_STATUS)   /* INT_DROPPED bit30, INT_DROP_CNT[7:0], FIRST_DROP_INT_CLIENT_ID[15:8], FIRST_DROP_INT_SOURCE_ID[23:16] */
  RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CREDIT_ERROR) /* bit 8 = SDMA0, bit 9 = SDMA1 */
  RREG32_SOC15(OSSSYS,0,mmIH_LIMIT_INT_RATE_CNTL)
  RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG)          /* TOTAL_CLIENT_NUM */
  para n em 0..TOTAL_CLIENT_NUM-1: WREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_INDEX,n); dump RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_DATA)
  RREG32_SOC15(NBIO,0,mmBIF_SDMA0_DOORBELL_RANGE / mmBIF_SDMA1_DOORBELL_RANGE / mmBIF_IH_DOORBELL_RANGE)
  RREG32(sdma_v5_0_get_reg_offset(adev,0,mmSDMA0_CNTL)) e idem instancia 1  /* comparar TRAP_ENABLE */

Tudo atras de um module_param(bc250_ih_debug, int, 0644) para poder ligar/desligar sem reboot.
  - teste: Um boot frio normal, dmesg. Sinais decisivos: (1) se aparecer 'SDMA IV: client=8 ... ring_id=N' com N!=0 -> descarte por ring_id, va para a proposta 2; (2) se aparecerem IVs client=9 em numero maior do que o trafego real do sdma1 e NENHUM client=8 -> aliasing de client_id, proposta 2 tambem resolve; (3) se NENHUM IV de client 8 ou 9 aparecer no momento do fallback, mas IH_INT_FLOOD_STATUS trouxer INT_DROPPED=1 com FIRST_DROP_INT_CLIENT_ID=8, ou IH_CLIENT_CREDIT_ERROR com bit 8 setado, ou IH_STORM_CLIENT_LIST_CNTL com bit 8 setado e bit 9 limpo -> proposta 3; (4) se a entrada 8 de IH_CLIENT_CFG_DATA diferir da entrada 9 em RING_ID ou CREDIT_RETURN_ADDR -> proposta 4. Se nada disso aparecer e os IVs de sdma1 forem visiveis mas os de sdma0 nao, o IV realmente morre antes do IH e este angulo esta esgotado.
- **Tornar o handler de trap do SDMA nao-perdedor (ring_id e client_id tolerantes)** — 1 reboot(s), risco baixo
  - mecanismo: Se o IV chega ao dispatch mas e jogado fora pelo switch de ring_id (case 1/2/3 vazios) ou e atribuido a instancia errada por aliasing de client_id, chamar amdgpu_fence_process nas duas instancias resolve. amdgpu_fence_process e idempotente e barato: le a seq do writeback e sai se nao mudou (amdgpu_fence.c:218-235), entao chamar espuriamente nao tem efeito colateral.
  - mudanca: .../amdgpu/sdma_v5_0.c, sdma_v5_0_process_trap_irq (1694-1740). Substituir os dois switch aninhados por:

  static int bc250_sdma_trap_broadcast = 1; /* module_param 0644 */
  if (entry->client_id == SOC15_IH_CLIENTID_SDMA0 ||
      entry->client_id == SOC15_IH_CLIENTID_SDMA1) {
      int inst = (entry->client_id == SOC15_IH_CLIENTID_SDMA0) ? 0 : 1;
      if (entry->ring_id == 0 || bc250_sdma_trap_broadcast)
          amdgpu_fence_process(&adev->sdma.instance[inst].ring);
      if (bc250_sdma_trap_broadcast) {
          int other = 1 - inst;
          if (other < adev->sdma.num_instances)
              amdgpu_fence_process(&adev->sdma.instance[other].ring);
      }
  }

Custo: no maximo duas leituras de memoria de writeback por IV de SDMA, so quando o param esta ligado.
  - teste: Mesmo boot da proposta 1 se ambas forem no mesmo modulo. Sinal: as linhas 'Fence fallback timer expired on ring sdma0' desaparecem do boot frio. Contraprova: escrever 0 em /sys/module/amdgpu/parameters/bc250_sdma_trap_broadcast em runtime e forcar trafego no sdma0 (ex.: mover BOs grandes) — as mensagens de fallback devem voltar. Isso da confirmacao e refutacao no MESMO boot.
- **Limpar a configuracao de storm/flood/credito do IH deixada pelo firmware do PS5** — 1 reboot(s), risco baixo
  - mecanismo: navi10_ih.c nunca escreve mmIH_STORM_CLIENT_LIST_CNTL, mmIH_INT_FLOOD_CNTL nem mmIH_CLIENT_CREDIT_ERROR, entao o estado do firmware do console sobrevive ao init do Linux. Um cliente marcado como storm com FLOOD_CNTL_ENABLE=1 tem IVs descartados pelo IH; um erro de credito latch-ado no cliente 8 faz o IH parar de aceitar IVs daquele cliente. Ambos sao por-cliente, o que casa exatamente com 'SDMA0 sempre perde, SDMA1 nunca perde'.
  - mudanca: .../amdgpu/navi10_ih.c, dentro de navi10_ih_irq_init, logo apos adev->nbio.funcs->ih_control(adev) (linha ~329) e antes de habilitar as interrupcoes:

  if (bc250_ih_unstorm) {   /* module_param 0644, default 0 */
      u32 t;
      /* zera a lista de storm clients */
      WREG32_SOC15(OSSSYS, 0, mmIH_STORM_CLIENT_LIST_CNTL, 0);
      /* desliga flood control e pulsa CLEAR_INT_FLOOD_STATUS */
      t = RREG32_SOC15(OSSSYS, 0, mmIH_INT_FLOOD_CNTL);
      t = REG_SET_FIELD(t, IH_INT_FLOOD_CNTL, FLOOD_CNTL_ENABLE, 0);
      t = REG_SET_FIELD(t, IH_INT_FLOOD_CNTL, CLEAR_INT_FLOOD_STATUS, 1);
      WREG32_SOC15(OSSSYS, 0, mmIH_INT_FLOOD_CNTL, t);
      t = REG_SET_FIELD(t, IH_INT_FLOOD_CNTL, CLEAR_INT_FLOOD_STATUS, 0);
      WREG32_SOC15(OSSSYS, 0, mmIH_INT_FLOOD_CNTL, t);
      /* limpa erros de credito latch-ados */
      WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CREDIT_ERROR, IH_CLIENT_CREDIT_ERROR__CLEAR_MASK);
      WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CREDIT_ERROR, 0);
      /* desliga rate limit */
      t = RREG32_SOC15(OSSSYS, 0, mmIH_LIMIT_INT_RATE_CNTL);
      t = REG_SET_FIELD(t, IH_LIMIT_INT_RATE_CNTL, LIMIT_ENABLE, 0);
      WREG32_SOC15(OSSSYS, 0, mmIH_LIMIT_INT_RATE_CNTL, t);
  }

O param precisa ser lido no boot (afeta o irq_init), entao vale 0444 ou aceitar que so vale no proximo boot.
  - teste: Boot com amdgpu.bc250_ih_unstorm=1 e com o dump da proposta 1 ativo. Sinal de confirmacao: os valores 'antes' do dump mostravam bit 8 setado em IH_STORM_CLIENT_LIST_CNTL ou em IH_CLIENT_CREDIT_ERROR, e apos a limpeza as mensagens de fallback do sdma0 somem. Refutacao: valores antes ja eram zero nesses bits -> hipotese morta, nao gastar mais reboots nela. Combinar com a proposta 1 no mesmo modulo para nao gastar reboot extra.
- **Reprogramar a entrada do cliente 8 na tabela IH_CLIENT_CFG para espelhar a do cliente 9** — 1 reboot(s), risco medio
  - mecanismo: IH_CLIENT_CFG_DATA carrega, por cliente, CREDIT_RETURN_ADDR, CLIENT_TYPE, RING_ID e OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID. Um RING_ID != 0 no cliente 8 manda os IVs do SDMA0 para o anel 1 ou 2 do IH, que no Linux tem ring_size = 0 e nunca e habilitado nem lido — os IVs desaparecem exatamente como observado, com o SDMA1 (RING_ID 0) funcionando. Um CREDIT_RETURN_ADDR errado faz o cliente ficar sem creditos apos os primeiros IVs, o que tambem casa com '2 a 3 fallbacks e depois nada'.
  - mudanca: .../amdgpu/navi10_ih.c, em navi10_ih_irq_init, apos ih_control e antes de habilitar interrupcoes, atras de module_param bc250_ih_fixup_client8:

  WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_INDEX, SOC15_IH_CLIENTID_SDMA1);
  ref = RREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_DATA);
  WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_INDEX, SOC15_IH_CLIENTID_SDMA0);
  cur = RREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_DATA);
  dev_info(adev->dev, "IH client cfg: sdma0=%08x sdma1=%08x\n", cur, ref);
  /* copia so os campos de roteamento, preservando CREDIT_RETURN_ADDR do cliente 8 */
  cur = REG_SET_FIELD(cur, IH_CLIENT_CFG_DATA, RING_ID,
                      REG_GET_FIELD(ref, IH_CLIENT_CFG_DATA, RING_ID));
  cur = REG_SET_FIELD(cur, IH_CLIENT_CFG_DATA, CLIENT_TYPE,
                      REG_GET_FIELD(ref, IH_CLIENT_CFG_DATA, CLIENT_TYPE));
  cur = REG_SET_FIELD(cur, IH_CLIENT_CFG_DATA, OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID, 0);
  WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_DATA, cur);

OBS: os defines de campo de IH_CLIENT_CFG_DATA estao em osssys_4_0_1_sh_mask.h e nao em osssys_5_0_0_sh_mask.h; o offset do registrador esta em osssys_5_0_0_offset.h:290-295. Vai precisar de defines locais ou de shift/mask manual (CREDIT_RETURN_ADDR [16:0], CLIENT_TYPE [19:18], RING_ID [21:20], VF_RB_SELECT [23:22], OVERWRITE [24]) — confirmar contra o layout de 5.0 antes de escrever, ou fazer so a LEITURA no primeiro boot (proposta 1) e so escrever no segundo.
  - teste: So executar depois que a proposta 1 mostrar que a entrada do cliente 8 difere da do cliente 9. Sinal: dmesg imprime sdma0=... sdma1=... com RING_ID diferente, e apos a copia os fallbacks do sdma0 somem. Refutacao: as duas entradas ja eram identicas -> a tabela nao e a causa e essa proposta deve ser abandonada sem gastar mais reboot.
- **Fallback por anel com periodo curto (contorno assumido, sem depender do IRQ)** — 1 reboot(s), risco baixo
  - mecanismo: NAO conserta o IRQ; torna o sdma0 utilizavel por polling barato. Hoje o periodo e global e fixo em HZ/2 = 500 ms (amdgpu.h:279), o que faz cada fence do sdma0 esperar ate meio segundo. Tornando o periodo por anel e curto so no sdma0, a engine volta a ser usavel para o ring do kernel (TTM buffer moves, PTE updates) com latencia limitada e medida.
  - mudanca: Em .../amdgpu/amdgpu_ring.h adicionar 'unsigned long fallback_period;' em struct amdgpu_fence_driver. Em .../amdgpu/amdgpu_fence.c:203-206 trocar por:
  mod_timer(&ring->fence_drv.fallback_timer,
            jiffies + (ring->fence_drv.fallback_period ?: AMDGPU_FENCE_JIFFIES_TIMEOUT));
Em amdgpu_fence.c:479 (amdgpu_fence_driver_init_ring) inicializar fallback_period = 0. Em .../amdgpu/sdma_v5_0.c, apos amdgpu_ring_init da instancia 0, setar
  if (i == 0 && bc250_sdma0_fast_fallback)
      ring->fence_drv.fallback_period = msecs_to_jiffies(bc250_sdma0_fast_fallback);
com module_param(bc250_sdma0_fast_fallback, int, 0644), default 0 (comportamento atual).
Alem disso, silenciar o dev_warn de amdgpu_fence.c:284-286 para esse anel (dev_dbg) senao o dmesg vira spam.
LIMITACAO A DIZER EM VOZ ALTA: isso cobre APENAS as fences do ring do kernel. As filas de USUARIO do KFD (HSA_ENABLE_SDMA=1, o caso de 199% de CPU girando) nao usam amdgpu_fence e NAO sao consertadas por isto. Para elas o bc250_skip_sdma0 continuaria necessario.
  - teste: Boot com o param default 0, medir tempo de N copias grandes via TTM (ex.: alocar e mover BOs de 256 MiB, 3 repeticoes) e contar as linhas de fallback. Depois escrever 2 (ms) em /sys/module/amdgpu/parameters/bc250_sdma0_fast_fallback em runtime e repetir as 3 medicoes. Sinal: mesma vazao, latencia por lote caindo de ~500 ms para ~2 ms, e nenhuma regressao no sdma1. Tudo no mesmo boot, sem reinit de GPU.

## a289dca51aefefb2d  (angulo: Firmware e carga de ucode do SDMA: qual blob vai para qual instancia, por qual caminho (PSP vs direto), e onde um erro de carga pode ser engolido. Li sdma_v5_0.c, amdgpu_sdma.c, amdgpu_ucode.c, amdgpu_psp.c, psp_gfx_if.h na arvore em /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1, e cruzei com o estado real da maquina (debugfs amdgpu_firmware_info, ip_discovery em sysfs, blobs em /lib/firmware, journalctl -b -k). Resultado curto: o mapeamento instancia->arquivo esta CORRETO e nao ha caminho de heranca entre as instancias; mas o SDMA0 desta placa e carregado exclusivamente pela PSP, sdma_v5_0_load_microcode() nunca executa, existe um caminho real de engolir falha de carga em bare-metal, e o SDMA0 e literalmente o PRIMEIRO GFX_CMD_ID_LOAD_IP_FW do boot inteiro. Isso ultimo e a assimetria mais forte que sobrou depois de o codigo generico ter sido provado simetrico.)
### Achados
- **[lido-no-codigo]** CONTRADICAO COM O BLOCO DE FATOS: o SDMA desta placa NAO e IP_VERSION(5,0,2), e IP_VERSION(5,0,1). Isso importa porque amdgpu_ucode_ip_version_decode mapeia 5.0.1 -> "cyan_skillfish2_sdma" e 5.0.2 -> "navi14_sdma". Se fosse mesmo 5.0.2 a placa estaria carregando firmware de navi14. Nao esta (ver achado seguinte). Se alguma conclusao sua depender de 5.0.2, ela esta errada na premissa.
  - evidencia: `/sys/class/drm/card1/device/ip_discovery/die/0/SDMA0/0/{major,minor,revision} = 5 / 0 / 1 (idem SDMA1); drivers/gpu/drm/amd/amdgpu/amdgpu_ucode.c:1325-1328 (case IP_VERSION(5,0,1) -> "cyan_skillfish2_sdma"; case IP_VERSION(5,0,2) -> "navi14_sdma")`
- **[lido-no-codigo]** O firmware realmente carregado em runtime e o cyan_skillfish2, nao navi14, nas DUAS instancias. SDMA0 e SDMA1 reportam feature 50 e fw 0x34; os blobs cyan carregam ucode_version 0x34 e feature 0x32(=50), os navi14 carregam 0x29. Ambos os headers foram parseados com sucesso (senao amdgpu_sdma_init_inst_ctx teria devolvido -EINVAL e o probe teria morrido).
  - evidencia: `/sys/kernel/debug/dri/0000:01:00.0/amdgpu_firmware_info -> "SDMA0 feature version: 50, firmware version: 0x00000034" e "SDMA1 feature version: 50, firmware version: 0x00000034"; header dos blobs em /lib/firmware/amdgpu/cyan_skillfish2_sdma{,1}.bin.zst: ucode_version=0x34 @0x10, feature=0x32 @0x20; navi14_sdma{,1}: 0x29. amdgpu_sdma.c:150-186 (amdgpu_sdma_init_inst_ctx)`
- **[lido-no-codigo]** O mapeamento instancia -> nome de arquivo esta CORRETO e nao ha swap possivel: instancia 0 pede "amdgpu/<prefix>.bin", instancia !=0 pede "amdgpu/<prefix><instance>.bin". Nao existe indirecao, tabela ou off-by-one.
  - evidencia: `amdgpu_sdma.c:213-222 (if (instance == 0) amdgpu_ucode_request(..., "amdgpu/%s.bin", ucode_prefix); else ... "amdgpu/%s%d.bin", ucode_prefix, instance)`
- **[lido-no-codigo]** NAO existe caminho onde a instancia 0 herda o firmware da 1 nem vice-versa. O unico mecanismo de heranca (o memcpy que replica instance[0] para as demais) so roda com duplicate=true, e sdma_v5_0 sempre chama com duplicate=false. Ou seja, esse bloco e codigo morto neste chip.
  - evidencia: `sdma_v5_0.c:290-301 (sdma_v5_0_init_microcode chama amdgpu_sdma_init_microcode(adev, i, false) em loop); amdgpu_sdma.c:239-244 (if (duplicate) { memcpy(&instance[i], &instance[0], ...) })`
- **[inferido]** Os dois blobs sao o MESMO codigo de ucode. Diferem em apenas 274 bytes de 33792, em 4 regioes: 0x1c-0x1f (crc32 do header), 0x100-0x10f (16 bytes de preambulo), 0x158 (um unico byte: 0x25 no _sdma.bin, 0x26 no _sdma1.bin), e 0x8300-0x83ff (bloco final de 256 bytes, tamanho de assinatura RSA-2048). O par navi14_sdma/navi14_sdma1 tem EXATAMENTE o mesmo padrao (277 bytes, mesmo 0x25/0x26 em 0x158). Interpretacao: o byte 0x158 e a tag de instancia/engine embutida no ucode; o resto e o envelope cripto que muda porque o texto claro mudou 1 byte.
  - evidencia: `cmp -l e xxd sobre /var/tmp/sdmafw/*.bin (descompactados de /lib/firmware/amdgpu/*.zst): runs de diferenca [0x1c-0x1f],[0x100-0x10f],[0x158],[0x8300-0x83ff]; byte @0x158 = 0x25 (cyan _sdma e navi14 _sdma) vs 0x26 (ambos _sdma1)`
- **[lido-no-codigo]** GAP DE INSTRUMENTACAO: nem debugfs, nem sysfs, nem o ioctl AMDGPU_INFO_FW_VERSION conseguem distinguir "instancia 0 recebeu cyan_skillfish2_sdma.bin" de "instancia 0 recebeu cyan_skillfish2_sdma1.bin", porque os dois blobs tem ucode_version e feature_version IDENTICOS (0x34 / 50). O unico discriminante e o crc32 do header (0xf2f45029 vs 0xdb3e0be6) ou o sha256 do arquivo, e nenhum dos dois e exposto em lugar nenhum.
  - evidencia: `amdgpu_kms.c:323-328 (case AMDGPU_INFO_FW_SDMA: so devolve fw_version e feature_version); amdgpu_kms.c:1908-1917 (print do debugfs); crc32 lido do header dos blobs @0x1c`
- **[lido-no-codigo]** ACHADO CENTRAL DO ANGULO: nesta placa load_type = AMDGPU_FW_LOAD_PSP, logo sdma_v5_0_load_microcode() NUNCA e executada. O ucode do SDMA nao e escrito por MMIO pelo driver; ele so chega as engines via comando GFX_CMD_ID_LOAD_IP_FW para a PSP. Derivacao: amdgpu_fw_load_type default = -1 (truthy) e o device 0x13FE seta AMD_APU_IS_CYAN_SKILLFISH2, entao o case CHIP_CYAN_SKILLFISH devolve PSP.
  - evidencia: `amdgpu_drv.c:165 (int amdgpu_fw_load_type = -1); amdgpu_device.c:2220-2223 (device 0x13FE || 0x143F -> apu_flags |= AMD_APU_IS_CYAN_SKILLFISH2); amdgpu_ucode.c:584-589 (case CHIP_CYAN_SKILLFISH: if (!(load_type && apu_flags & AMD_APU_IS_CYAN_SKILLFISH2)) return DIRECT; else return PSP); sdma_v5_0.c:940 (if (adev->firmware.load_type == AMDGPU_FW_LOAD_DIRECT) r = sdma_v5_0_load_microcode(adev))`
- **[lido-no-codigo]** A PSP esta mesmo no caminho em runtime: o IP block psp_v11_0_8 e detectado e a TMR e reservada antes do SDMA subir. E o proprio 'Fence fallback timer expired on ring sdma0' aparece logo depois, ainda dentro do ip_init.
  - evidencia: `journalctl -b -k: 'detected ip block number 3 <psp_v11_0_8> (psp)', 'detected ip block number 7 <sdma_v5_0_0> (sdma_v5_0)', 'reserve 0x400000 from 0xf6ff800000 for PSP TMR' (18:35:09), depois 'Fence fallback timer expired on ring sdma0' x2 (18:35:10 e 18:35:11)`
- **[lido-no-codigo]** Os UCODE_IDs usados sao AMDGPU_UCODE_ID_SDMA0 -> GFX_FW_TYPE_SDMA0 (=9) e AMDGPU_UCODE_ID_SDMA1 -> GFX_FW_TYPE_SDMA1 (=10). Este e o UNICO ponto de todo o caminho de firmware onde os dois lados divergem por valor. O comentario do proprio header anota o tipo 9 como 'VG + RV' e o 10 como 'VG' (anotacao de plataforma, nao contrato) — e para NV existem tipos SDMA0_JT=31 / SDMA1_JT=32 e SDMA0_PG_CONTEXT=40 / SDMA1_PG_CONTEXT=41 que este driver nunca usa.
  - evidencia: `amdgpu_psp.c:2637-2646 (amdgpu_psp_get_fw_type); psp_gfx_if.h:218-219, 240-241, 249-250`
- **[lido-no-codigo]** EXISTE SIM um caminho de erro engolido, e ele e generico (nao por instancia): em bare-metal, se a PSP responder com resp.status != 0 a um LOAD_IP_FW, psp_cmd_submit_buf apenas emite dev_warn e RETORNA 0. So retorna -EINVAL se amdgpu_sriov_vf() (falso aqui) ou se estourou o timeout. Isto e, uma falha de carga que a PSP *responda* nao derruba o hw_init.
  - evidencia: `amdgpu_psp.c:759-777: 'if (!skip_unsupport && (psp->cmd_buf_mem->resp.status || !timeout) && !ras_intr) { ... dev_warn(...) ... if ((ucode && amdgpu_sriov_vf(psp->adev)) || !timeout) { ret = -EINVAL; goto exit; } }'`
- **[lido-no-codigo]** MAS esse caminho nao esta disparando nesta maquina: zero ocorrencias de 'failed to load ucode' em 7 dias de logs. Cuidado com o que isso prova: o buffer de comando e zerado antes do submit (amdgpu_psp.c:717), entao 'a PSP escreveu status 0' e 'a PSP nunca escreveu resp' sao INDISTINGUIVEIS pelo warning. O que da pra afirmar e que a fence bateu (senao timeout==0 -> -EINVAL -> probe falharia, e o probe nao falha em boot frio).
  - evidencia: `journalctl -k --since '-7 days' | grep -c 'failed to load ucode' -> 0; amdgpu_psp.c:717 (memset(psp->cmd_buf_mem, 0, PSP_CMD_BUFFER_SIZE)); amdgpu_psp.c:730-741 (loop de espera da fence)`
- **[inferido]** HIPOTESE MAIS FORTE DESTE ANGULO: o SDMA0 e o PRIMEIRO GFX_CMD_ID_LOAD_IP_FW do boot inteiro. AMDGPU_UCODE_ID_CAP=0 mas psp.cap_fw e NULL nesta placa (o debugfs nao imprime a linha CAP), entao ucode[0].fw==NULL e fw_load_skip_check pula; psp_load_p2s_table retorna cedo por !ucode->fw; autoload_supported=false para MP0 IP 11.0.8, entao o psp_load_smu_fw antecipado nao roda. O indice 1 = AMDGPU_UCODE_ID_SDMA0 e o primeiro a chegar na PSP. Isso da uma explicacao de assimetria que NAO exige nenhuma assimetria no codigo do driver (que ja foi provado simetrico): se a PSP desta placa perde/ignora o primeiro LOAD_IP_FW apos o SETUP_TMR, a vitima e sempre e exatamente o SDMA0.
  - evidencia: `amdgpu_ucode.h:480-481 (CAP=0, SDMA0=1, SDMA1=2); amdgpu_psp.c:3006-3010 (fw_load_skip_check: if (!ucode->fw || !ucode->ucode_size) return true); amdgpu_psp.c:2964 (psp_load_p2s_table: if (!ucode->fw ...) return 0); amdgpu_psp.c:239-245 (IP_VERSION(11,0,8) -> psp_v11_0_8_set_psp_funcs, autoload_supported = false); amdgpu_psp.c:3066-3105 (loop de psp_load_non_psp_fw); amdgpu_kms.c: bloco CAP so imprime 'if (adev->psp.cap_fw)' e nao apareceu no debugfs`
- **[lido-no-codigo]** Nao ha hazard de ordem entre a leitura do firmware e o upload pela PSP: sdma_v5_0_init_microcode roda em EARLY_INIT, portanto antes de qualquer sw_init/hw_init, e portanto muito antes de psp_hw_init/amdgpu_ucode_init_bo. E amdgpu_ucode_init_single_fw nao tem case para SDMA0/SDMA1 v1 — os dois caem no mesmo default (ucode_size = header->ucode_size_bytes, endereco = data + ucode_array_offset_bytes). Simetrico.
  - evidencia: `sdma_v5_0.c:1360-1373 (sdma_v5_0_early_init chama sdma_v5_0_init_microcode); amdgpu_device.c: amdgpu_device_ip_init faz sw_init/hw_init depois do early_init de todos os blocos; amdgpu_ucode.c:1200-1215 (amdgpu_ucode_init_bo); amdgpu_ucode_init_single_fw nao lista AMDGPU_UCODE_ID_SDMA0/1 no switch do ramo PSP`
- **[lido-no-codigo]** O kernel rodando tem CONFIG_FW_LOADER_DEBUG=y, o que da uma forma de provar exatamente qual arquivo foi entregue em cada request, com sha256, SEM build e SEM MMIO. sha256 de referencia (dos blobs descompactados): cyan_skillfish2_sdma.bin = 15d0d3626da7f2513f03b13bb7e02eeeeccab276276ae27d0b6067b5f25e9e95, cyan_skillfish2_sdma1.bin = bd1c0b0f6a6a4f17ede034f2c844b6553fc444e08915c7bb500c09fde59d6255.
  - evidencia: `zcat /proc/config.gz | grep FW_LOADER -> CONFIG_FW_LOADER=y, CONFIG_FW_LOADER_DEBUG=y; drivers/base/firmware_loader/main.c:806-817 (fw_log_firmware_info -> dev_dbg(device, "Loaded FW: %s, sha256: %*phN\n", ...)); main.c:569 e main.c:582 ('Loading firmware from %s' / 'direct-loading %s'); sha256sum sobre /var/tmp/sdmafw/*.bin`
- **[inferido]** CONCLUSAO HONESTA DO ANGULO: nao encontrei prova de que a instancia 0 receba o ucode errado. O caminho de nome, de versao e de estrutura esta correto e simetrico. O que este angulo entrega e (a) a constatacao de que o SDMA0 desta placa depende 100% da PSP, sem nenhum fallback de escrita direta, (b) um caminho real de falha silenciosa que hoje NAO esta acionado, e (c) uma hipotese de ordenacao (SDMA0 = primeira LOAD_IP_FW do boot) que e a unica assimetria estrutural que sobra depois de o driver ter sido provado simetrico.
  - evidencia: `sintese dos achados acima`

### Propostas
- **P1 - Provar qual blob foi para qual request, sem build e sem MMIO (dyndbg no firmware loader)** — 1 reboot(s), risco baixo
  - mecanismo: Nao explica o IRQ perdido por si so; ELIMINA (ou confirma) de forma definitiva a hipotese 'instancia 0 recebeu o blob errado'. Como os dois blobs cyan tem ucode_version e feature identicos, nenhuma interface exposta hoje distingue os dois; o log do firmware_loader imprime o nome do arquivo E o sha256 do conteudo, o que fecha o buraco. E o experimento mais barato de todos: zero build, e pode ser empilhado no mesmo reboot de qualquer outro teste.
  - mudanca: Nenhuma mudanca de codigo. Adicionar a linha de comando do kernel (no boot entry, sem tornar permanente ate confirmar):

  dyndbg="file drivers/base/firmware_loader/main.c +p"

Opcionalmente restringir o ruido com:
  dyndbg="func fw_log_firmware_info +p; func fw_get_filesystem_firmware +p"
  - teste: Depois do boot:
  journalctl -b -k | grep -E 'Loading firmware from|Loaded FW: amdgpu/.*sdma'
Esperado (caminho correto): duas linhas 'Loaded FW:', na ordem instancia 0 depois instancia 1, com
  amdgpu/cyan_skillfish2_sdma.bin  sha256 15d0d3626da7f2513f03b13bb7e02eeeeccab276276ae27d0b6067b5f25e9e95
  amdgpu/cyan_skillfish2_sdma1.bin sha256 bd1c0b0f6a6a4f17ede034f2c844b6553fc444e08915c7bb500c09fde59d6255
SINAL QUE CONFIRMA UM BUG DE FIRMWARE: qualquer navi14_sdma*, qualquer ordem invertida, qualquer sha256 que nao bata, ou apenas UM arquivo pedido em vez de dois.
SINAL QUE REFUTA: exatamente os dois sha256 acima, nessa ordem. Nesse caso o angulo de 'blob errado' morre e sobra so o caminho PSP (P2/P3/P4).
- **P2 - Build de instrumentacao pura: o que a PSP responde para cada SDMA** — 1 reboot(s), risco baixo
  - mecanismo: psp_cmd_submit_buf so avisa se resp.status != 0, e o buffer de resposta e zerado antes do submit — logo 'PSP respondeu sucesso' e 'PSP nunca escreveu a resposta' sao hoje indistinguiveis. Alem disso a PSP devolve em resp.fw_addr_lo/hi o endereco onde colocou o ucode dentro da TMR: se o SDMA0 voltar com fw_addr zero (ou igual ao do SDMA1) e o SDMA1 nao, isso e a prova direta de que o ucode do SDMA0 nunca foi aplicado — e um ucode nao aplicado explica perfeitamente uma engine que executa o copy (o hardware base funciona) mas nunca emite o trap de conclusao.
  - mudanca: drivers/gpu/drm/amd/amdgpu/amdgpu_psp.c, dentro de psp_execute_ip_fw_load (linha ~2927), logo apos psp_cmd_submit_buf:

  dev_info(psp->adev->dev,
     "bc250-fwload: ucode=%s id=%d fw_type=%d size=%u mc=0x%llx ret=%d resp.status=0x%X resp.fw_addr=0x%08X%08X\n",
     amdgpu_ucode_name(ucode->ucode_id), ucode->ucode_id,
     cmd->cmd.cmd_load_ip_fw.fw_type, ucode->ucode_size,
     (unsigned long long)ucode->mc_addr, ret,
     cmd->resp.status, cmd->resp.fw_addr_hi, cmd->resp.fw_addr_lo);

E em drivers/gpu/drm/amd/amdgpu/amdgpu_sdma.c, ao fim do bloco de sucesso de amdgpu_sdma_init_microcode (apos amdgpu_sdma_init_inst_ctx, linha ~237):

  { const struct common_firmware_header *h = (const void *)adev->sdma.instance[instance].fw->data;
    dev_info(adev->dev, "bc250-fw: sdma inst=%u prefix=%s size=%zu ucode_ver=0x%x feat=%u crc32=0x%08x\n",
       instance, ucode_prefix, adev->sdma.instance[instance].fw->size,
       adev->sdma.instance[instance].fw_version,
       adev->sdma.instance[instance].feature_version,
       le32_to_cpu(h->crc32)); }

Zero mudanca de comportamento. Build incremental so do modulo amdgpu.
  - teste: journalctl -b -k | grep bc250-fw
CRC32 esperado: instancia 0 -> 0xf2f45029, instancia 1 -> 0xdb3e0be6. Se vierem trocados ou iguais, e o blob errado (e P1 ja teria pego).
SINAL QUE CONFIRMA 'PSP nao aplicou o SDMA0': resp.fw_addr do SDMA0 vem 0x0000000000000000 enquanto o do SDMA1 vem nao-zero; ou resp.status do SDMA0 != 0 (que hoje seria engolido em silencio porque nao e SR-IOV).
SINAL QUE REFUTA: os dois SDMA voltam com resp.status=0 e fw_addr distintos e nao-zero. Nesse caso a PSP fez o que devia e o problema esta a jusante do firmware.
Recomendo bundlar P2, P3 e P4 no MESMO build, com P3 e P4 atras de module params default-off — assim um build serve tres reboots.
- **P3 - Pre-carregar o SDMA0 duas vezes (testa 'a primeira LOAD_IP_FW e perdida')** — 1 reboot(s), risco baixo
  - mecanismo: O SDMA0 e literalmente o primeiro GFX_CMD_ID_LOAD_IP_FW do boot (CAP nulo, P2S nulo, autoload desligado no MP0 11.0.8). Se a PSP desta placa engole/ignora o primeiro LOAD_IP_FW depois do SETUP_TMR — quirk classico de 'primeiro comando perdido' —, a vitima e sempre e exatamente o SDMA0, e nunca o SDMA1. Isso explica uma assimetria 100% deterministica em todo boot frio SEM exigir nenhuma assimetria no codigo do driver, que ja foi verificado linha a linha como simetrico. Uma carga sacrificial extra absorve o comando perdido e a segunda carga (a do loop normal) pega.
  - mudanca: drivers/gpu/drm/amd/amdgpu/amdgpu_psp.c, em psp_load_non_psp_fw (linha ~3050), logo antes do for principal e depois de psp_load_p2s_table:

  static int bc250_psp_sdma0_double;
  module_param(bc250_psp_sdma0_double, int, 0444);
  MODULE_PARM_DESC(bc250_psp_sdma0_double,
      "BC-250: submete o ucode do SDMA0 uma vez a mais antes do loop de carga");
  ...
  if (bc250_psp_sdma0_double) {
      struct amdgpu_firmware_info *u0 = &adev->firmware.ucode[AMDGPU_UCODE_ID_SDMA0];
      if (u0->fw && u0->ucode_size) {
          int r0 = psp_execute_ip_fw_load(psp, u0);
          dev_info(adev->dev, "bc250: presubmit SDMA0 ret=%d\n", r0);
      }
  }

Nao altera a ordem relativa de nada; so acrescenta um submit idempotente antes.
  - teste: Bootar com amdgpu.bc250_psp_sdma0_double=1 e olhar:
  journalctl -b -k | grep -c 'Fence fallback timer expired on ring sdma0'
SINAL QUE CONFIRMA: a contagem cai de 2-3 para 0 (e continua 0 em 3 boots frios independentes — n>=3, n=1 nao vale). Se confirmar, o passo seguinte e remover bc250_skip_sdma0 e repetir HSA_ENABLE_SDMA=1 para ver se a copia enfileirada no SDMA0 sinaliza.
SINAL QUE REFUTA: a contagem continua 2-3. Nesse caso 'primeira LOAD_IP_FW perdida' esta morto e P4 vira o proximo teste.
Sempre 3 boots por condicao antes de declarar qualquer coisa.
- **P4 - Inverter a ordem de carga SDMA1 antes de SDMA0 (teste discriminante de ordem vs engine)** — 1 reboot(s), risco medio
  - mecanismo: Complementar de P3 e mais decisivo. Se o defeito e da POSICAO na sequencia de comandos da PSP (primeiro LOAD_IP_FW), inverter a ordem faz o 'Fence fallback timer expired' MIGRAR de sdma0 para sdma1. Se o defeito e da ENGINE 0 em si (silicio, roteamento de IV, o que for), a mensagem fica onde esta, em sdma0, independentemente da ordem. Nenhum outro experimento separa essas duas hipoteses com um unico bit tao limpo.
  - mudanca: Mesmo arquivo/funcao de P3, mas em vez do pre-submit, pular os dois SDMA no loop principal e carrega-los explicitamente na ordem invertida antes dele:

  static int bc250_psp_sdma_order;   /* 0 = normal, 1 = SDMA1 primeiro */
  module_param(bc250_psp_sdma_order, int, 0444);
  ...
  if (bc250_psp_sdma_order == 1) {
      struct amdgpu_firmware_info *u1 = &adev->firmware.ucode[AMDGPU_UCODE_ID_SDMA1];
      struct amdgpu_firmware_info *u0 = &adev->firmware.ucode[AMDGPU_UCODE_ID_SDMA0];
      if (u1->fw && u1->ucode_size) psp_execute_ip_fw_load(psp, u1);
      if (u0->fw && u0->ucode_size) psp_execute_ip_fw_load(psp, u0);
  }
  /* e dentro do for principal: */
  if (bc250_psp_sdma_order == 1 &&
      (ucode->ucode_id == AMDGPU_UCODE_ID_SDMA0 ||
       ucode->ucode_id == AMDGPU_UCODE_ID_SDMA1))
          continue;

autoload_supported e false neste MP0 (amdgpu_psp.c:239-245), entao nao ha o gatilho de rlc autoload dependente de ordem para se preocupar; os blocos GFX/RLC mantem a ordem original.
  - teste: Bootar com amdgpu.bc250_psp_sdma_order=1.
SINAL 'E ORDEM, NAO E A ENGINE': a mensagem passa a ser 'Fence fallback timer expired on ring sdma1' e o sdma0 fica limpo. Isso derruba de vez a tese de defeito de silicio da engine 0 e move o alvo para o protocolo com a PSP.
SINAL 'E A ENGINE 0': continua 'ring sdma0', mesma contagem, ordem irrelevante.
SINAL BONUS: se NENHUM dos dois reclamar, o defeito e da posicao absoluta (primeiro comando) e nao do par — combina com P3.
3 boots frios por condicao.
- **P5 - Forcar carga DIRETA (MMIO) do ucode do SDMA, ignorando a PSP** — 1 reboot(s), risco alto
  - mecanismo: Esta e a unica proposta que ataca o problema em vez de so medi-lo, e e uma correcao de verdade se a hipotese PSP estiver certa. Hoje sdma_v5_0_load_microcode() e codigo morto nesta placa (gate em sdma_v5_0.c:940). Se a PSP nao esta aplicando o ucode do SDMA0, escrever o ucode diretamente em SDMA0_UCODE_ADDR/DATA com a F32 parada substitui o que a PSP deveria ter feito, de forma simetrica para as duas instancias — e o codigo para isso ja existe e ja e simetrico. AVISO EXPLICITO: e uma alteracao de mecanismo de init, nao um contorno de trafego; se funcionar, resolve o pedido do usuario (remover bc250_skip_sdma0).
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c, em sdma_v5_0_start (linha ~938):

  static int bc250_sdma_direct_ucode;
  module_param(bc250_sdma_direct_ucode, int, 0444);
  MODULE_PARM_DESC(bc250_sdma_direct_ucode,
      "BC-250: escreve o ucode do SDMA por MMIO mesmo com load_type=PSP");
  ...
  if (adev->firmware.load_type == AMDGPU_FW_LOAD_DIRECT ||
      bc250_sdma_direct_ucode) {
          r = sdma_v5_0_load_microcode(adev);
          if (r) return r;
  }

Nao mexer em amdgpu_fw_load_type=0 pela linha de comando: aquele parametro trocaria o load_type de TUDO (GFX, SMU, RLC) de uma vez e provavelmente derruba o probe inteiro sem isolar nada. Este patch e cirurgico: so o SDMA.
  - teste: Bootar com amdgpu.bc250_sdma_direct_ucode=1.
SINAL DE SUCESSO: zero 'Fence fallback timer expired on ring sdma0' em 3 boots frios; depois disso, bootar SEM amdgpu.bc250_skip_sdma0 e rodar HSA_ENABLE_SDMA=1 numa copia grande — a copia deve completar e sinalizar, sem os 199% de CPU em spin.
SINAL DE FALHA ESPERADO E BENIGNO: 'ring sdma0 test failed (-110)' + 'hw_init of IP block <sdma_v5_0> failed -110' + 'probe with driver amdgpu failed with error -110' — exatamente a assinatura que o reload a quente ja produz. Isso e informativo (diz que a escrita direta de ucode nao pega neste silicio, coerente com o comentario da AMD em sdma_v5_0.c:288-289 'emulation only, won't work on real chip').
RECUPERACAO: como e module param de linha de comando, basta bootar sem ele. MAS: se o probe do amdgpu falhar voce perde o display, entao faca este teste com acesso por ssh garantido ou com a entrada de boot editavel no menu do bootloader, nunca com o param gravado como default. Este e o unico dos cinco testes que pode te deixar sem tela.

### [REFUTADA] P1 -- Periodo de fallback timer por-ring, curto so no sdma0
- O mecanismo e tecnicamente real e nao viola nenhuma restricao dura -- todos os simbolos foram verificados na arvore (AMDGPU_FENCE_JIFFIES_TIMEOUT em amdgpu.h:279; mod_timer em amdgpu_fence.c:205-206; fallback_timer em amdgpu_ring.h:128; timer_setup em amdgpu_fence.c:479; re-arme em 232-234; enable_signaling em 844-848; buffer_funcs_ring em sdma_v5_0.c:2051). E a alegacao de que a deteccao nao e MMIO se confirma: amdgpu_fence_read (amdgpu_fence.c:79-90) le *drv->cpu_addr, que vem do wb alocado em AMDGPU_GEM_DOMAIN_GTT (amdgpu_device.c:1737-1738), ou seja RAM do host. Nada inventado.

O que mata a proposta e a premissa de impacto e o plano de teste.

(1) IMPACTO INFLADO, CONTRADITO POR MEDICAO. O journal deste boot tem EXATAMENTE duas ocorrencias: 10.946015 e 11.450086 (delta 504 ms = HZ/2, o segundo e o re-arme da linha 232-234). Contagem no boot inteiro = 2, com 15 minutos de uptime e desktop rodando. Zero "callbacks suppressed" -- dev_warn nao e ratelimited, entao nao ha mensagem escondida. Como amdgpu_fence_fallback so imprime quando amdgpu_fence_process retorna true (fence realmente completa), e como toda espera de TTM/drm_sched passa por enable_signaling e portanto arma o timer, um IRQ perdido com dependente bloqueado SEMPRE geraria uma mensagem. Logo o IRQ do sdma0 NAO esta perdido de forma persistente: ele se perde 2 vezes numa janela de 500 ms logo apos "irq initialized." (10.166 s) e funciona pelo resto do boot. Milhares de blits de TTM ocorreram depois sem um unico fallback. O ganho real nao e "TODO blit do TTM" como a proposta afirma -- e ~1 segundo de latencia unica no boot.

(2) O TESTE NAO FUNCIONA. O item 4 le bc250_sdma0_fallback_ms dentro de sdma_v5_0_sw_init (loop em sdma_v5_0.c:1401-1417), que roda uma unica vez no probe. Escrever em /sys/module/amdgpu/parameters/... em runtime altera a variavel do modulo mas ninguem a rele, entao o valor de fence_drv.fallback_period nao muda. E reload a quente e impossivel nesta placa (ring sdma0 test failed -110). O "Runtime, sem reboot depois do primeiro" e falso: e um reboot por valor.

(3) O TESTE NAO DISTINGUE. Mesmo com um knob que funcionasse em runtime, nao ha o que medir depois do boot: zero eventos de fallback apos 11.45 s. Cronometrar N moves de TTM daria numeros identicos com e sem patch, porque esses moves ja completam por IRQ normal em microssegundos. O sinal proposto ("intervalo cai de ~500 ms para <2 ms") seria indistinguivel de "o patch nao fez nada".

(4) NAO EXPLICA A ASSIMETRIA sdma0 vs sdma1 -- admitido pela propria proposta, que se declara workaround escopado por parametro. Isso sozinho eu nao trataria como fatal, mas somado a (1)(2)(3) nao justifica gastar um reboot na forma escrita.

Nit de compilacao: max(1u, msecs_to_jiffies(...)) mistura unsigned int com unsigned long.
- correcao sugerida: A proposta e recuperavel com custo de exatamente um reboot, desde que se corrija a alegacao de beneficio e o metodo de teste.

A) Reformular o beneficio com honestidade: P1 nao acelera "todo blit do TTM". Ele elimina os ~1,0 s de stall unico no boot (dois fallbacks de 504 ms cada, em 10.946 e 11.450 neste boot). Isso e um ganho pequeno mas real e de risco quase nulo. Se o parent estiver priorizando por impacto, P1 desce muito na lista.

B) Trocar o knob de sysfs por parametro de linha de comando. A unica janela em que o patch faz diferenca (10,4-11,5 s) acontece ANTES de o userspace poder escrever no sysfs, entao um knob de runtime e inutil por construcao. Use amdgpu.bc250_sdma0_fallback_ms=1 no cmdline. Se quiser manter ajuste em runtime de verdade, nao copie o valor em sw_init: leia o module_param diretamente dentro de amdgpu_fence_schedule_fallback, com um teste de que o ring e o sdma0 (por exemplo comparando ring == adev->mman.buffer_funcs_ring, ou marcando um bool no amdgpu_ring no sw_init e lendo o param a cada arme). Assim o valor passa a valer sem reprobe -- mas note que isso ainda nao ajuda o teste, so a ergonomia.

C) Substituir o teste por um que discrimina, e que ja e gratuito: os proprios timestamps das duas mensagens em dmesg. Criterio de sucesso, com amdgpu.bc250_sdma0_fallback_ms=1:
   - as DUAS mensagens "Fence fallback timer expired on ring sdma0" continuam presentes (esperado, o IRQ segue perdido);
   - o delta entre elas cai de ~504 ms para ~1-2 ms;
   - a primeira mensagem antecipa de ~10,95 s para ~10,45 s, e a ultima de ~11,45 s para ~10,45 s.
   Falha = timestamps inalterados. Isso e binario, nao precisa de ftrace, nao precisa de instrumentacao, e nao confunde com nada, porque nenhum outro caminho move esses dois timestamps especificos. Rodar 3 boots por condicao (com e sem o param) para respeitar o minimo de repeticoes.

D) Nao gastar um reboot dedicado. O patch e ~6 linhas e nao toca init de GPU; deve pegar carona no proximo rebuild do modulo amdgpu que for feito por outro motivo, e o criterio (C) se avalia de graca no dmesg do boot seguinte.

E) Nit: usar max_t(unsigned int, 1, msecs_to_jiffies(bc250_sdma0_fallback_ms)) em vez de max(1u, ...). E o ternario "?:" do item 2 vira codigo morto se o item 3 sempre inicializa fallback_period -- manter um dos dois, nao os dois.

### [REFUTADA] Forcar evicao de VRAM e ler amdgpu_fence_info como segunda confirmacao do trap perdido no SDMA0
- REFUTADA como escrita. Quatro problemas, dois deles fatais, todos verificados na arvore em /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1.

(1) FATAL — o criterio positivo e auto-realizavel. amdgpu_fence.c:891-903, amdgpu_debugfs_fence_info_show() chama amdgpu_fence_process(ring) em TODO ring antes de imprimir. amdgpu_fence_process (amdgpu_fence.c:220) le o seq da WB e avanca/sinaliza tudo que ja completou. Portanto "Last signaled == Last emitted" e verdade por construcao no instante do cat, com ou sem interrupcao. Somando a isso o proprio fallback timer, que varre tudo em <=500 ms, os contadores de fence NAO conseguem distinguir "IRQ entregou" de "IRQ perdido, mas o timer/o cat limparam". A proposta declara exatamente esse igual como evidencia de IRQ funcionando; esse criterio e sempre verdadeiro. Pior: fence_process faz timer_delete(&fence_drv.fallback_timer) na entrada e so rearma se seq != sync_seq, ou seja, o cat de "antes" mexe no estado do timer que voce quer medir.

(2) FATAL na pratica — o comando nao executa nada. amdgpu_debugfs.c:2153 cria "amdgpu_evict_vram" com modo 0400, e amdgpu_debugfs.c:1783 faz DEFINE_DEBUGFS_ATTRIBUTE(amdgpu_evict_vram_fops, amdgpu_debugfs_evict_vram, NULL, "%lld\n") — o set e NULL. `echo 1 | sudo tee` falha com EACCES no open (0400) e falharia de novo em simple_attr_write. Zero copia e gerada. Como o resto do teste le ausencia de linha de fallback como "IRQ ok", esse erro produz um FALSO NEGATIVO que mataria a hipotese certa. O gatilho e um READ, nao um write.

(3) A contagem esperada esta mecanicamente errada. "cada wait custa 500 ms e loga" e falso: existe UM fallback_timer por ring (amdgpu_fence.c:479) e uma unica expiracao percorre o backlog inteiro no do/while sinalizando todas as fences, emitindo exatamente UM dev_warn (amdgpu_fence.c:281-287). Dezenas de fences perdidas dao ~1 linha, nao dezenas. Alem disso o timer so e armado em amdgpu_fence_enable_signaling (amdgpu_fence.c:846) — fence de evicao que so vai para a resv e nunca recebe enable_signaling nunca arma o timer e nunca loga, mesmo com IRQ 100% morto. Ausencia de linha nao e evidencia de entrega.

(4) Sem braco de controle e sem medida de volume. buffer_funcs_ring e fixo no sdma0, entao a evicao gera ~zero trafego no sdma1: voce mede o sdma0 sem condicao pareada no sdma1, que e justamente a assimetria em investigacao. E ttm_resource_manager_evict_all (ttm_resource.c:580) retorna 0/errno, nao bytes — o cat imprime "0" e voce nao sabe se moveu 2 GB ou nada. Num sistema com compositor vivo o loop ttm_bo_evict_first pode retornar -EBUSY cedo tendo evicado quase nada.

(5) Custo escondido: a proposta se vende como "sem reboot", mas evicao em massa na engine que perde conclusao pode estourar timeout de scheduler/TTM e escalar para amdgpu_gpu_recover — e reinit do sdma0 nesta placa e o caminho ja documentado como fatal ("ring sdma0 test failed (-110)" / "Fatal error during GPU init"). No caso ruim o teste custa o reboot que dizia economizar.

Nao contradiz nenhum FATO MEDIDO, mas e amplamente redundante: os fatos ja registram 2-3 fallbacks no sdma0 em todo boot frio e o spin infinito com HSA_ENABLE_SDMA=1 (199% CPU, minutos) ja e perda de sinalizacao em regime, muito depois da init. A "hipotese de ordem" ja esta em serio apuro sem gastar este teste.
- correcao sugerida: Se quiser insistir na versao sem reboot, ela vira outra coisa:

1. Trocar o gatilho por leitura: `sudo cat /sys/kernel/debug/dri/N/amdgpu_evict_vram` (modo 0400, set==NULL). Conferir o dri index antes — nao chutar 1.
2. Descartar completamente os contadores de fence como criterio. O unico canal confiavel e o dmesg. NAO fazer o cat de amdgpu_fence_info antes: ele chama amdgpu_fence_process e perturba o timer. Se quiser um numero, ler fence_info UMA vez, depois de tudo, e trata-lo so como "houve trafego", nunca como prova de entrega de IRQ.
3. Atribuicao temporal: rodar `sudo dmesg -w` num terminal separado (ou registrar o timestamp do ultimo kmsg antes) e so contar linhas de fallback que aparecam 0-2 s depois do cat. `dmesg | tail -20` nao separa isso do ruido de boot.
4. Medir volume independentemente: antes/depois de `amdgpu_vram_mm` ou `ttm_resource_manager_usage` via /sys/kernel/debug/dri/N/amdgpu_vram_mm, para saber se alguma copia realmente aconteceu. Sem isso o resultado negativo e ininterpretavel.

Mas o experimento que vale o reboot e outro, e e estritamente melhor por informacao-por-reboot: instrumentar o handler, nao inferir do timer. Um rebuild so do modulo amdgpu (~5 min, viavel dentro das restricoes) que adicione dois contadores atomicos incrementados em sdma_v5_0_process_trap_irq (por instancia, indexados por entry->client_id/src_id) e expostos em debugfs/sysfs — sem MMIO, respeita a restricao dura. No mesmo build, um module param para forcar mman.buffer_funcs_ring = sdma1, dando o braco de controle pareado que falta. Com esse instrumento, qualquer carga (inclusive a evicao) vira decisiva: IVs chegando para sdma1 e nao para sdma0 sob carga identica prova a assimetria em regime, e o contador zerado no sdma0 localiza a perda entre o hardware/IH e o dispatch, coisa que o fallback timer nunca vai conseguir dizer.

### [REFUTADA] P0 -- Parar de descartar IVs do SDMA0 com ring_id != 0, e imprimir o que chega
- A HIPOTESE sobrevive; a EXECUCAO nao. Verifiquei tudo na arvore e nenhum simbolo foi inventado: sdma_v5_0_process_trap_irq esta em sdma_v5_0.c:1694, o switch aninhado de ring_id com case 1/2/3 vazios esta em 1706-1718, amdgpu_fence_process realmente retorna false em seq==last_seq (amdgpu_fence.c), SOC15_IH_CLIENTID_SDMA0/1 = 0x08/0x09 ambos registrados com SRCID__SDMA_TRAP=224.

EM VOZ ALTA, COMO PEDIDO: um item da lista de FATOS nao e um fato, e uma inferencia nao suportada. O brief afirma "=> O IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch". Li amdgpu_irq_dispatch (amdgpu_irq.c:497-525): so os tres ramos de FALHA imprimem (Invalid client_id, Invalid src_id, Unregistered interrupt). O ramo de sucesso -- client_id valido, src_id valido, source registrada -- faz src->funcs->process() e nao imprime NADA. Logo "zero linhas de dyndbg" e perfeitamente compativel com o IV chegando, sendo despachado normalmente, e morrendo dentro do case 1: vazio. Essa inferencia precisa ser rebaixada a observacao. A proposta esta certa sobre a lacuna que ataca.

Mesmo assim ela falha por tres motivos independentes:

1. FATAL AO TESTE -- dev_info_ratelimited destroi o sinal negativo. DEFAULT_RATELIMIT_BURST=10 por 5*HZ (include/linux/ratelimit_types.h), e os IVs das DUAS instancias passam por esse UNICO call site. Pelo proprio brief sao apenas 2-3 traps perdidos do SDMA0 por boot; o trafego do SDMA1 come o orcamento do burst e suprime justamente as linhas que interessam. A proposta declara que ausencia de linha do SDMA0 e "refutacao definitiva" -- e exatamente o inverso. Sob ratelimit, ausencia nao prova nada, e o reboot e gasto para um resultado ininterpretavel.

2. CONFUNDIMENTO -- a sonda e a mudanca de comportamento vem no mesmo patch. Apagar o switch de ring_id faz amdgpu_fence_process rodar em IVs de fila RLC/paging, e essa funcao faz "if (timer_delete(&ring->fence_drv.fallback_timer) && seq != sync_seq) amdgpu_fence_schedule_fallback(ring);". Cada chamada espuria deleta e re-arma o fallback timer do ring do kernel, empurrando-o para frente. Ou seja: "Fence fallback timer expired on ring sdma0" pode SUMIR porque o timer foi inanido, nao porque algo foi consertado. O criterio de sucesso da proposta e contaminado pela propria proposta.

3. DESNECESSARIO -- o tracepoint ja existe. amdgpu_irq_dispatch ja chama trace_amdgpu_iv(ih - &adev->irq.ih, &entry) em amdgpu_irq.c:491, A MONTANTE de todo filtro, e TRACE_EVENT(amdgpu_iv) (amdgpu_trace.h:76-108) grava client_id, src_id, ring_id, vmid, pasid e src_data[0..3] -- superconjunto estrito do dev_info proposto, sem ratelimit e em ring buffer em vez de console. Zero build, zero reboot.

Sobre a assimetria: "encoding RLC/paging ou campo com lixo" nao e mecanismo. As duas engines emitem o mesmo SDMA_OP_TRAP + INT_CONTEXT(0) da fila 0 pelo mesmo sdma_v5_0_ring_emit_fence (sdma_v5_0.c:546-551), entao qualquer divergencia de ring_id tem de nascer na engine ou no firmware. Existe exatamente um candidato nao-vazio que a proposta nunca cita: as instancias carregam BLOBS DE FIRMWARE DIFERENTES (cyan_skillfish2_sdma.bin vs cyan_skillfish2_sdma1.bin). Isso salva a hipotese de ser puramente post-hoc -- por isso mato a execucao, nao a ideia.
- correcao sugerida: NAO GASTE REBOOT NENHUM. A pergunta central -- "que ring_id o IV de trap do SDMA0 carrega?" -- e respondivel agora, em runtime, sem build e sem reboot.

PASSO 0 (custo zero, fazer primeiro): a perda de IRQ reproduz em runtime, nao so no boot -- o proprio brief mede HSA_ENABLE_SDMA=1 girando a 199% de CPU. E adev->mman.buffer_funcs_ring = sdma.instance[0].ring, entao qualquer movimentacao de buffer do TTM ja dirige a engine 0. Entao:

  cd /sys/kernel/debug/tracing
  echo 32768 > buffer_size_kb
  echo 1 > events/amdgpu/amdgpu_iv/enable
  # gerar trafego leve de buffer (nada de carga pesada de GPU nessa placa)
  cat trace | grep -E 'client_id:(8|9)'

Leitura do resultado:
  - linhas com client_id:8 e ring != 0  -> HIPOTESE CONFIRMADA, o IV chega e o driver joga fora. Bug resolvido, zero reboots.
  - client_id:8 aparece com ring:0 mas a fence nao anda -> hipotese refutada, e voce ganhou um fato novo e mais forte.
  - client_id:9 aparece e client_id:8 NUNCA aparece -> hipotese refutada, o IV realmente nao chega. Tambem zero reboots.
Em qualquer um dos tres casos voce aprende de graca o encoding real de ring_id na instancia que FUNCIONA, que e a linha de base que hoje ninguem tem.

PASSO 1 (so se o passo 0 vier vazio, 1 reboot, ainda sem rebuild): botar na cmdline
  trace_event=amdgpu:amdgpu_iv trace_buf_size=32M
e ler o buffer depois do boot. Cobre a janela dos 10.9s do fallback sem tocar em uma linha de codigo e sem risco de quebrar o init do amdgpu.

PASSO 2 (so se ainda precisar de codigo): entao sim patch, mas com tres correcoes obrigatorias em relacao a proposta:
  a) NAO usar dev_info_ratelimited. Usar contadores atomicos por (client_id, ring_id) expostos em debugfs, ou um dev_info incondicional limitado pelas N primeiras ocorrencias DE CADA client_id separadamente -- nunca um burst compartilhado entre as duas instancias.
  b) SO A SONDA. Manter o switch de ring_id intacto. Nao chamar amdgpu_fence_process em nada novo. Assim "Fence fallback timer expired on ring sdma0" continua sendo um sinal limpo, nao perturbado pelo re-arme do fallback_timer.
  c) So depois que a sonda mostrar ring != 0 para client_id:8, ai sim um segundo build removendo o switch -- ja com a resposta na mao, e com o criterio de sucesso agora nao-confundido.

Regra geral que a proposta violou: sonda e correcao nunca no mesmo boot. E antes de qualquer build, checar se o kernel ja instrumenta aquilo -- neste caso ja instrumentava.

### [REFUTADA] P2 -- Piggyback: checar a fence do sdma0 no fim de todo IRQ da GPU
- REFUTADA. Nao por invencao de simbolo (o codigo confere), mas porque o teste proposto mede uma quantidade que JA E ZERO no baseline, e porque o mecanismo nao tem em que pegar carona na unica janela onde o bug e observado.

1) SIMBOLOS: todos conferem, nao e essa a refutacao.
- amdgpu_irq.c:206 e exatamente `ret = amdgpu_ih_process(adev, &adev->irq.ih);` dentro de amdgpu_irq_handler.
- amdgpu_ring.h:125 tem `bool initialized` em struct amdgpu_fence_driver.
- amdgpu_fence.c:220 `bool amdgpu_fence_process(struct amdgpu_ring *ring)` retorna true so quando avancou o seq.
- amdgpu_fence.c:278-287 amdgpu_fence_fallback so faz dev_warn se amdgpu_fence_process retornou true. Confere.
- sdma_v5_0.c:1709 e gfx_v10_0.c:9247 chamam amdgpu_fence_process de contexto de IRQ. Confere.
- amdgpu_fence_read (amdgpu_fence.c:79-90) le `*drv->cpu_addr` (slot de writeback em RAM), NAO MMIO. A proposta nao viola a restricao dura de MMIO. Custo em hardirq e realmente trivial.

2) O TESTE NAO DISTINGUE NADA -- refutacao principal.
Medi os 4 ultimos boots desta maquina (journalctl -k -b 0/-1/-2/-3):
  boot 0: 2 mensagens, 18:35:10 e 18:35:11 -- dentro de amdgpu_device_ip_init, entre "cp_resume" e "kfd added device"
  boot -1: 2   boot -2: 2   boot -3: 2
Zero ocorrencias depois disso. Boot 0 tem 16 min de uptime com desktop rodando e a mensagem NUNCA aparece em runtime.
O sinal proposto e "com glxgears, ligar o param e as mensagens devem PARAR de aparecer". Elas ja nao aparecem. Ligar o param e ver zero mensagem e o resultado esperado tanto se P2 funcionar quanto se P2 for um no-op completo. Isso e um teste infalsificavel.

3) O TESTE NAO E "RUNTIME" para o evento real.
As unicas 2 ocorrencias acontecem durante o probe do modulo, antes do KFD subir. Um module_param 0644 escrito depois do boot nao pode influenciar algo que ja aconteceu. Para afetar aquelas 2 mensagens o param precisa estar setado no load do modulo -- e reload a quente do amdgpu e FATAL nesta placa (ring sdma0 test failed -110, fato medido). Logo o teste custa um reboot, ao contrario do que a proposta afirma.

4) O MECANISMO NAO TEM EM QUE PEGAR CARONA NA JANELA DO BUG.
As 2 mensagens caem entre cp_resume e o registro do no KFD. Nesse instante: nenhum cliente de userspace, nenhum CRTC habilitado (vblank IRQ so e armado com refcount do DRM > 0), nenhuma submissao de gfx alem dos proprios ring/IB tests. A fonte de "interrupcoes nao relacionadas gratuitas" que P2 pressupoe simplesmente nao existe exatamente onde o sintoma existe. A premissa "sob carga a latencia vai a zero" e verdadeira, mas no boot nao ha carga.

5) O TIMER SO EXISTE SE ALGUEM ESPERA -- confound extra.
amdgpu_fence_emit NAO arma o fallback timer. Ele so e armado por amdgpu_fence_enable_signaling (amdgpu_fence.c:844-848), ou seja quando alguem faz dma_fence_wait/add_callback, e re-armado dentro do proprio amdgpu_fence_process (linha 232-234). Sem waiter em fence do sdma0, nao ha timer, nao ha mensagem, independente de quantos IRQs se percam. "Mensagem sumiu" pode significar apenas "ninguem esperou nada nessa engine". Confound direto do sinal.

6) EFEITO COLATERAL QUE PIORA O INSTRUMENTO.
amdgpu_fence_process faz `if (timer_delete(&fallback_timer) && seq != sync_seq) amdgpu_fence_schedule_fallback(ring)`. Chamando isso a cada IRQ do dispositivo, com trabalho pendente no sdma0, o deadline de 500 ms (AMDGPU_FENCE_JIFFIES_TIMEOUT = HZ/2, amdgpu.h:279) e empurrado indefinidamente sob qualquer fluxo de IRQ. P2 destroi justamente o unico sinal diagnostico que voces tem hoje para essa engine.

7) NAO ATACA NENHUMA DAS CONSEQUENCIAS MEDIDAS EM USERSPACE.
- HSA_ENABLE_SDMA=1 girando a 199% de CPU e fila de USUARIO do KFD, que nao usa amdgpu_fence de jeito nenhum. amdgpu_fence_process(&adev->sdma.instance[0].ring) mexe so no fence_drv do anel do KERNEL (wb slot). Efeito zero sobre o spin do ROCr.
- O bloco de 2 MiB faltando com HSA_ENABLE_SDMA=0 e caminho de blit kernel/gfx, nem passa por sdma0.
Ou seja: o ganho real de P2 e reduzir a latencia de 2 fences por boot, de ~500 ms para ~0. Cerca de 1 segundo de boot. Nao vale um reboot.

8) NAO EXPLICA A ASSIMETRIA.
P2 e simetrico por construcao e nem tenta explicar por que sdma1 nunca perde IV e sdma0 sempre perde. E paliativo puro, aplicado em cima de um paliativo que ja existe (o fallback timer, que ja garante corretude -- a prova disso e a propria mensagem, que so sai quando o polling encontrou a fence completa).

Se a sua conclusao exigir que a mensagem apareca em runtime nesta maquina, ela contradiz o que acabei de medir em 4 boots.
- correcao sugerida: Se for insistir nessa linha, trocar sinal-por-ausencia por sinal-por-contagem, e criar um repro de runtime ANTES de gastar reboot:

A) SINAL POSITIVO, nao ausencia. No lugar de "a mensagem sumiu", instrumentar quem assinou cada fence do sdma0. Tres contadores atomicos por anel, expostos em debugfs (0444, leitura de RAM, sem MMIO):
   - sdma0_signaled_by_trap  (incrementado em sdma_v5_0_process_trap_irq quando amdgpu_fence_process retorna true)
   - sdma0_signaled_by_piggyback (o retorno true da chamada nova em amdgpu_irq_handler)
   - sdma0_signaled_by_fallback (retorno true dentro de amdgpu_fence_fallback)
   Fazer o mesmo para sdma1 como controle. Resultado interpretavel: piggyback > 0 significa que ele resgatou IRQ realmente perdido; piggyback == 0 significa que P2 e no-op e voce sabe disso sem ambiguidade. E o par trap-vs-fallback por instancia quantifica a assimetria pela primeira vez em numero, nao em mensagem de log.

B) BASELINE DE RUNTIME PRIMEIRO, sem reboot. Existe debugfs `amdgpu_test_ib` (amdgpu_debugfs.c:2157, amdgpu_debugfs_test_ib_show em :1640) que roda amdgpu_ib_ring_tests com os schedulers parkados, sem reinit de IP. Isso emite fence no sdma0 COM waiter, que e a condicao que arma o fallback timer. Ler esse arquivo N vezes (minimo 3x3 conforme a regra de repeticao) e contar as mensagens no dmesg. Se a mensagem aparecer de forma reproduzivel ai, voce ganhou um repro de runtime e o teste de P2 passa a ser de fato runtime-only para metade das perguntas. Se NAO aparecer, P2 esta morto sem custar reboot nenhum.

C) SE FOR AO REBOOT, maximizar informacao. Nao gastar um boot so com bc250_sdma0_isr_poll. Empacotar no mesmo modulo, todos com module_param na cmdline: os contadores de (A), um log one-shot com o delta de tempo entre emissao e assinatura de cada fence do sdma0 nas primeiras N fences, e o P1 (fallback encurtado) atras de param separado. Assim um unico boot responde: (i) quantos IVs do sdma0 se perdem de fato, (ii) se ha algum IRQ da GPU chegando na janela do probe para o piggyback aproveitar, (iii) quanto o P1 sozinho ja resolve.

D) NAO empurrar o fallback timer. Se o piggyback for mesmo implementado, ele nao deve chamar amdgpu_fence_process cru, porque isso re-arma o timer e apaga o diagnostico. Fazer uma variante que so le o seq e, se avancou, entao sim processa -- deixando o timer intacto quando nao ha nada novo.

### [SOBREVIVEU] Patch: habilitar TRAP_ENABLE dentro do gfx_resume, em vez de esperar o fim do amdgpu_device_init
- Tentei matar e não consegui. Pior: os logs que já estão na máquina confirmam a premissa antes mesmo do patch.

DECLARAÇÃO OBRIGATÓRIA DE CONTRADIÇÃO
Esta proposta exige que a segunda metade de um FATO listado esteja ERRADA. O fato diz: "amdgpu_fence_fallback() só avisa quando amdgpu_fence_process() encontrou uma fence JÁ COMPLETA. Ou seja: o trabalho terminou e a INTERRUPÇÃO se perdeu." A primeira frase (mecânica do código) está certa. A segunda (a inferência) está errada para as ocorrências de BOOT: nenhuma interrupção se perdeu, nenhuma foi sequer gerada, porque TRAP_ENABLE ainda era 0. A mensagem de boot é artefato de ordem de init, não evidência de perda de IRQ. Isso não toca o sintoma de runtime (HSA_ENABLE_SDMA=1 girando), que continua sem explicação.

1. CONTRADIZ FATO MEDIDO? Não.
- "ZERO linhas de Unregistered/Invalid client_id" com dyndbg: perfeitamente consistente com trap desligado (não há IV algum), tanto quanto com IV perdido. Não discrimina.
- "O IV do trap do SDMA0 NÃO chega ao amdgpu_irq_dispatch": literalmente verdadeiro nos dois cenários.
- "Em boot frio o ring test do sdma0 PASSA": esperado — sdma_v5_0_ring_test_ring faz polling em memória, não usa IRQ, e roda dentro de hw_init, muito antes de :4753.
- "Código simétrico entre instância 0 e 1": continua verdade, e é justamente por isso que o mecanismo funciona (ver item 2).

2. EXPLICA A ASSIMETRIA? Sim, e sem inventar assimetria de hardware.
A janela sem trap afeta as DUAS instâncias igualmente. Mas só a sdma0 recebe submissão de kernel nessa janela, porque adev->mman.buffer_funcs_ring = &adev->sdma.instance[0].ring (fato já medido). Sem fence pendente na sdma1, amdgpu_fence_schedule_fallback() nem chega a armar o fallback_timer dela. Logo: assimetria da MENSAGEM explicada por assimetria de USO, que já está na lista de fatos. Nada de hardware precisa ser assimétrico.

3. CÓDIGO — conferi linha a linha na árvore /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1. Zero símbolo inventado:
- sdma_v5_0_gfx_resume_instance(): existe, sdma_v5_0.c:688. O bloco citado é real: RREG32 mmSDMA0_CNTL em :793, UTC_L1_ENABLE em :794, MIDCMD_PREEMPT_ENABLE em :797, WREG32 em :798. O ponto de inserção está certo.
- Campo SDMA0_CNTL.TRAP_ENABLE: real, usado em sdma_v5_0_set_trap_irq_state() (:1686) com o mesmo REG_SET_FIELD.
- amdgpu_device.c:3163 = amdgpu_ttm_set_buffer_funcs_status(adev, true); :3167 = amdgpu_amdkfd_device_init(adev); :4753 = amdgpu_fence_driver_hw_init(adev), logo antes do dev_info "SE %d, SH per SE %d". Números EXATOS.
- amdgpu_irq_dispatch() não consulta enabled_types: confirmado. O corpo só testa client_id, src_id, adev->irq.virq[], client[].sources[] e chama src->funcs->process direto. A afirmação do comentário do patch está correta (embora eu não fixaria o número de linha 513, ver item 6 das sugestões).
- Quem liga TRAP_ENABLE? Grep de amdgpu_irq_get sobre sdma.trap_irq: sdma_v6_0.c e sdma_v7_0.c têm chamadas próprias; sdma_v5_0.c NÃO TEM NENHUMA. Ou seja, o único caminho que escreve TRAP_ENABLE=1 neste chip é amdgpu_fence_driver_hw_init() -> amdgpu_irq_get(), em :4753. A janela alegada existe mesmo e é a única.
- amdgpu_fence_need_ring_interrupt_restore() retorna !(adev->in_s0ix && is_gfx_power_domain); in_s0ix é false no boot, então o irq_get realmente roda (não é um caminho morto).
- Nada entre gfx_resume e :4753 desliga o trap: amdgpu_irq_disable_all só aparece em device.c:4929 (fini) e :7392 (shutdown); amdgpu_irq_gpu_reset_resume_helper só em :5594/:6019 (reset). Caminho de probe limpo.
- AMDGPU_FENCE_JIFFIES_TIMEOUT = (HZ/2), amdgpu.h:279. Bate com os 500 ms alegados.

4. O TESTE DISCRIMINA? Sim — e a premissa já está confirmada de graça. Rodei journalctl nos 3 boots disponíveis:
  boot 0: fallback 10.946015 e 11.450086 (Δ=504 ms), "SE 2, SH per SE 2" 11.451538
  boot -1: fallback 12.835044 e 13.339175 (Δ=504 ms), SE 13.340807
  boot -2: fallback 173.450076 e 173.955028 (Δ=505 ms), SE 173.956139
Em 3/3: exatamente 2 fallbacks, ambos ESTRITAMENTE ANTES do dev_info que vem logo depois de amdgpu_fence_driver_hw_init. E o Δ entre eles é 504-505 ms, ou seja, um período inteiro de fallback cada — não é coincidência, é o timer sendo o único despertador. O encaixe no KFD é cirúrgico: o primeiro fallback é imediatamente seguido de "kfd kfd: Allocated 3969056 bytes on gart" e o segundo imediatamente seguido de "Topology: Add GPU node" + "kfd kfd: added device 1002:13fe". Isto é exatamente a janela :3167 que a proposta descreve.
Não vejo confundidor. amdgpu_fence_fallback() só imprime se amdgpu_fence_process() retornar true; se o trap funcionar, o handler processa antes e o timer, ao disparar, acha nada e cala. Então:
  - 0 fallbacks depois do patch => a mensagem de boot era artefato de ordem, e o diagnóstico que vinha guiando a investigação está envenenado. Ganha-se ~1,0 s de boot de brinde.
  - ainda 2 fallbacks depois do patch => primeira evidência DURA de perda real de IV na sdma0 com trap comprovadamente ligado. Esse braço vale sozinho os 3 boots.
Os dois resultados são informativos. É um teste honesto.

VEREDITO: sobrevive. A proposta é modesta, se auto-rotula corretamente como higiene de evidência e não como cura, e é a única coisa na mesa que limpa o sinal antes de gastar reboot em hipóteses mais caras. Aprovo — com as modificações do campo seguinte, que aumentam bastante o retorno por reboot sem custar build extra.
- correcao sugerida: Sobrevive, então isto são melhorias, não conserto. Todas cabem no MESMO build e aumentam a informação por reboot:

1. TORNE PARÂMETRO DE MÓDULO, não hardcode. Ex.: amdgpu.bc250_early_sdma_trap (default 1), no mesmo estilo dos bc250_skip_sdma0/bc250_dead_gpu_guard já existentes. Assim um único build de ~5 min entrega os DOIS braços do experimento em 2 reboots, em vez de exigir rebuild pra voltar atrás. Dado o custo de build nesta máquina (3,5 GB de RAM), isso é o item mais valioso da lista.

2. READBACK DO SDMA0_CNTL, logo depois do WREG32, por instância. Uma linha de dev_info a partir do contexto do driver (permitido; a proibição é MMIO cru de userspace):
   dev_info(adev->dev, "sdma%d CNTL after resume = 0x%08x\n", i, RREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_CNTL)));
   Custo zero, e se a instância 0 ler de volta TRAP_ENABLE=0 enquanto a 1 lê 1, você achou a PRIMEIRA assimetria de hardware real da investigação — coisa que nenhum outro experimento proposto até agora conseguiria mostrar.

3. CONTADOR DE TRAP POR INSTÂNCIA. Um adev->sdma.instance[i] trap count incrementado em sdma_v5_0_process_trap_irq() e impresso uma vez no fim de sdma_v5_0_hw_init (ou dev_info_ratelimited direto no handler). Isso separa, no MESMO reboot, "trap ligado e chegando" de "trap ligado e IV ainda sumindo". Sem isso, contar fallback=0 confirma o mecanismo mas não prova que IVs da sdma0 chegam — só prova que alguém acordou o waiter.

4. MÉTRICA DE TEMPO: use o DELTA "irq initialized." -> "SE %d, SH per SE %d", nunca timestamps absolutos. Medido hoje: 10.167729 -> 11.451538 = 1.284 s. Esperado pós-patch: ~0,28 s. Absoluto não serve: o boot -2 teve o probe inteiro em t=173 s (modprobe tardio), o que faria comparação de tempos absolutos parecer regressão.

5. CRITÉRIO DE ACEITE MAIS DURO que "grep -c". Use tambem: os fallbacks, se sobrarem, ainda caem ANTES do "SE 2, SH per SE 2"? Se sobrarem mas agora aparecerem DEPOIS, mudou de fenômeno e a leitura é outra.

6. NO COMENTÁRIO DO PATCH, não fixe "amdgpu_irq.c:513". Escreva "ver amdgpu_irq_dispatch(), que despacha por client_id/src_id sem consultar src->enabled_types". A afirmação está correta, mas número de linha apodrece no próximo rebase e vira desinformação no próximo ciclo de diagnóstico.

7. DECLARE O RAIO DE ALCANCE no commit: sdma_v5_0.c também serve navi10/navi14/navi12, e o loop liga o trap nas DUAS instâncias. Ligar nas duas é o certo para o experimento (mantém a simetria e não introduz um viés novo), mas precisa estar escrito, senão vira surpresa se isso um dia for pra upstream.

8. NÃO gaste reboot só pra "confirmar a ordem" — isso já está confirmado nos 3 boots do journal atual (fallbacks estritamente antes do "SE 2, SH per SE 2", Δ de 504-505 ms entre eles, encaixados no KFD init). Venda os 3 boots pelo braço de FALSIFICAÇÃO: descobrir se o fallback persiste com o trap comprovadamente ligado. É esse resultado que ninguém tem hoje.

## a02d6284ff18724d5  (angulo: Diferenca contra chips irmaos: comparacao campo-a-campo de sdma_v5_0.c (navi10/14/12 vs cyan skillfish) e de sdma_v5_0.c vs sdma_v5_2.c, mais comparacao binaria dos dois firmwares SDMA e checagem do que a tabela de discovery realmente reporta nesta placa. Arvore lida: /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1)
### Achados
- **[lido-no-codigo]** CONTRADICAO COM UM FATO DADO: o SDMA desta placa NAO e IP_VERSION(5,0,2). A tabela de discovery do proprio hardware reporta SDMA0 = SDMA1 = 5.0.1. 5.0.2 e Navi14. Isso importa porque e exatamente o seletor que decide qual golden register set e aplicado: 5.0.1 cai em golden_settings_sdma_cyan_skillfish; 5.0.2 cairia em golden_settings_sdma_5 + golden_settings_sdma_nv14 e o chip nunca veria os valores cyan de UTCL1_PAGE nem de GB_ADDR_CONFIG. Toda analise que dependa de '5,0,2' esta olhando o ramo errado do switch.
  - evidencia: `/sys/class/drm/card1/device/ip_discovery/die/0/SDMA0/0/{major,minor,revision} = 5/0/1 (idem SDMA1/0); sdma_v5_0.c:238 switch (amdgpu_ip_version(adev, SDMA0_HWIP, 0)); sdma_v5_0.c:268 case IP_VERSION(5, 0, 1) -> golden_settings_sdma_cyan_skillfish; sdma_v5_0.c:247 case IP_VERSION(5, 0, 2) -> golden_settings_sdma_5 + nv14`
- **[lido-no-codigo]** A BC-250 e CYAN_SKILLFISH2 e portanto passa pelo ramo de DISCOVERY, nao pelo ramo hardcoded. Confirmado em runtime: o ip block smu_v11_0 so e adicionado para IP_VERSION(11,0,8) quando AMD_APU_IS_CYAN_SKILLFISH2 esta setado, e o boot loga 'SMU is initialized successfully!'. Consequencia: sdma.num_instances, sdma_mask e as bases de registrador vem da ROM de discovery, nao das linhas hardcoded 2899-2916.
  - evidencia: `amdgpu_discovery.c:2887-2896 (case CHIP_CYAN_SKILLFISH / if apu_flags & AMD_APU_IS_CYAN_SKILLFISH2 -> amdgpu_discovery_reg_base_init); amdgpu_discovery.c:2216-2218; journalctl -k: 'amdgpu 0000:01:00.0: SMU is initialized successfully!'`
- **[lido-no-codigo]** MICROCODIGO ELIMINADO COMO CAUSA (custo: zero reboots). cyan_skillfish2_sdma.bin e cyan_skillfish2_sdma1.bin sao 33792 bytes cada, mesma ucode_version (52) e mesma feature_version (50), e diferem em apenas 4 regioes: 0x1c-0x1f (CRC32 do header), 0x100-0x10f (hash de 16 bytes antes do magic '$PS1'), 0x158 (UM byte: 0x25 vs 0x26 -- o id de tipo de ucode do PSP) e 0x8300-0x83ff (assinatura RSA de 256 bytes). O CODIGO em si e byte-identico. Logo a hipotese 'a engine 0 roda firmware diferente/pior que a engine 1' esta MORTA -- a geracao do IV de trap e funcao do F32, e os dois F32 rodam o mesmo binario.
  - evidencia: `zstd -dc /lib/firmware/amdgpu/cyan_skillfish2_sdma{,1}.bin.zst; cmp -l -> 274 bytes diferentes agrupados em 0x1c-0x1f, 0x100-0x10f, 0x158, 0x8300-0x83ff; sha256 15d0d362.. vs bd1c0b0f..`
- **[lido-no-codigo]** O UNICO registrador com diferenca SEMANTICA entre o golden set do cyan skillfish e o dos irmaos navi e mmSDMA0/1_UTCL1_PAGE. Decodificando campo a campo: bits 10 (USE_PT_SNOOP=1), 11 (USE_IO=1), 12-13 (RD_L2_POLICY=1), 14-15 (WR_L2_POLICY=1) e 16-21 (DMA_PAGE_SIZE=0x0c) sao IDENTICOS nos dois. A unica diferenca real e o bit 22, USE_BC: cyan grava 1, navi grava 0. Alem disso a mascara cyan (0x007fffff) exclui o bit 23 ADDR_IS_PA, ou seja deixa ele como o boot ROM do PS5 tiver deixado, enquanto navi (0x00ffffff) o zera explicitamente. O default de reset e 0x000c5c20, com bit 23 = 0.
  - evidencia: `sdma_v5_0.c:201 e :215 (0x007fffff, 0x004c5c00) vs sdma_v5_0.c:130 e :142 (0x00ffffff, 0x000c5c00); gc/gc_10_1_0_sh_mask.h:640-659 (USE_BC_MASK 0x00400000 bit 22, ADDR_IS_PA_MASK 0x00800000 bit 23, DMA_PAGE_SIZE 0x003F0000); gc/gc_10_1_0_default.h mmSDMA0_UTCL1_PAGE_DEFAULT = 0x000c5c20`
- **[inferido]** UTCL1_PAGE nao pode explicar um IV de trap perdido. Esse registrador so controla o caminho de TRADUCAO DE ENDERECO das leituras/escritas de dados da SDMA (snoop, IO, politica de L2, tamanho de pagina, PA vs VA). Quem porta o gate de geracao de interrupcao e o bit 0 de SDMA0_CNTL (TRAP_ENABLE), registrador totalmente diferente. USE_BC=1 e um candidato plausivel para CORRUPCAO/perda de dados em copia (que e outro sintoma medido), nao para IRQ perdido.
  - evidencia: `gc/gc_10_1_0_sh_mask.h: SDMA0_CNTL__TRAP_ENABLE__SHIFT = 0x0 (registrador mmSDMA0_CNTL = 0x001c) vs mmSDMA0_UTCL1_PAGE = 0x0048; sdma_v5_0.c:1673-1692 (unico escritor de TRAP_ENABLE)`
- **[lido-no-codigo]** BUG REAL E ASSIMETRICO NO CODIGO 'GENERICO', contradizendo a premissa de que o driver e simetrico entre instancia 0 e 1: sdma_v5_0_enable(adev,false) chama sdma_v5_0_gfx_stop(adev, 1 << inst_mask). Com num_instances=2, inst_mask = GENMASK(1,0) = 0b11 = 3, logo 1<<3 = 8. for_each_inst(i, 8) itera EXATAMENTE UMA vez, com i = 3. E sdma_v5_0_get_reg_offset(adev, 3, X) devolve o endereco da INSTANCIA 0, porque o codigo so soma SDMA1_REG_OFFSET quando instance == 1. Resultado: o caminho de 'stop' zera RB_ENABLE e IB_ENABLE da SDMA0 achando que e a instancia 3, e NUNCA para a SDMA1. sdma_v5_2.c passa inst_mask correto. Confirmado presente no upstream torvalds/master, nao e corrupcao local.
  - evidencia: `sdma_v5_0.c:662-666 (inst_mask = GENMASK(...); sdma_v5_0_gfx_stop(adev, 1 << inst_mask)); sdma_v5_0.c:563-576 (for_each_inst); sdma_v5_0.c:218-234 (get_reg_offset: 'if (instance == 1)' apenas); amdgpu.h:1485-1487 (for_each_inst); sdma_v5_2.c equivalente passa inst_mask; verificado em raw.githubusercontent.com/torvalds/linux/master/drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c`
- **[lido-no-codigo]** CORREÇÃO DO v5_2 QUE NUNCA VOLTOU PARA O v5_0 (a mais relevante para o custo de teste): sdma_v5_2_start() faz um GRBM soft reset de cada engine ANTES de dar unhalt e resume. sdma_v5_0_soft_reset() e um stub literal ('/* todo */ return 0;'), e sdma_v5_0_start() nao reseta nada. O helper por engine JA EXISTE no v5_0 (sdma_v5_0_soft_reset_engine, usado so pelo reset de fila). Isso e a explicacao mais direta para 'rmmod ok, modprobe -> ring sdma0 test failed (-110)': em boot frio o boot ROM do PS5 deixa a engine num estado que o unhalt aceita; depois de um ciclo de uso, sem soft reset, ela nao volta.
  - evidencia: `sdma_v5_0.c:1528-1533 (stub); sdma_v5_0.c:1330-1352 (sdma_v5_0_soft_reset_engine existe); sdma_v5_0.c:927-958 (start sem reset); sdma_v5_2.c:817 e sdma_v5_2.c:845 (sdma_v5_2_soft_reset(ip_block) dentro do start); confirmado upstream`
- **[lido-no-codigo]** OUTRA CORREÇÃO DO v5_2 NAO BACKPORTADA, mas que NAO se aplica aqui: sdma_v5_2 tem ring begin_use/end_use chamando amdgpu_gfx_off_ctrl para proibir GFXOFF enquanto a SDMA esta ativa (comentario explicito: 'SDMA seems to miss doorbells when entering PG'), e um write direto de RB_WPTR para IP_VERSION(5,2,1). sdma_v5_0 nao tem nada disso, e o cyan skillfish e o UNICO APU atendido por sdma_v5_0.c (os outros tres sao dGPUs). PORTEM: nesta placa GFXOFF esta desligado por dois caminhos independentes -- nv.c zera cg_flags e pg_flags para IP_VERSION(10,1,3), e a cmdline tem amdgpu.ppfeaturemask=0xfffd3fff que limpa PP_GFXOFF_MASK (0x8000). Entao essa hipotese esta ELIMINADA para este alvo.
  - evidencia: `sdma_v5_2.c:227-240 e :1832-1860 e :1952-1953; sdma_v5_0.c nao tem begin_use/end_use em sdma_v5_0_ring_funcs; nv.c:866-871 (case IP_VERSION(10,1,3)/(10,1,4): cg_flags = 0; pg_flags = 0); /proc/cmdline amdgpu.ppfeaturemask=0xfffd3fff (bits limpos 0x2C000 = OVERDRIVE|GFXOFF|STUTTER)`
- **[inferido]** BURACO NA EVIDENCIA EXISTENTE, e provavelmente A explicacao do sintoma de boot: TRAP_ENABLE (bit 0 de SDMA0_CNTL) tem valor de reset 0 e o UNICO lugar que o liga e sdma_v5_0_set_trap_irq_state, chamado por amdgpu_irq_get de dentro de amdgpu_fence_driver_hw_init. Essa funcao roda DEPOIS que amdgpu_device_ip_init retorna (amdgpu_device.c:4746 depois :4753). Mas o TTM ja passa a usar a engine no FIM do proprio ip_init (amdgpu_device.c:3161-3163 liga buffer_funcs) e logo em seguida, ainda dentro de ip_init, amdgpu_amdkfd_device_init (amdgpu_device.c:3167) aloca e limpa BOs. Como buffer_funcs_ring E a sdma0, existe uma janela em que fences com AMDGPU_FENCE_FLAG_INT sao emitidas na sdma0 com o TRAP fisicamente desabilitado: o pacote TRAP executa, a fence e escrita, nenhum IV e gerado, e 0,5s depois o fallback avisa. Numero esperado de avisos: um punhado -- bate com os '2 a 3'. E a sdma1 e MUDA nessa janela porque nao tem trafego nenhum (nao e buffer_funcs_ring e ainda nao existe VM). Ou seja: a assimetria pode ser de TRAFEGO, nao de hardware.
  - evidencia: `gc/gc_10_1_0_default.h mmSDMA0_CNTL_DEFAULT = 0x000000c2 (bit0 = 0); sdma_v5_0.c:1673-1692; amdgpu_fence.c:639-654 (fence_driver_hw_init -> amdgpu_irq_get); amdgpu_device.c:4746 (ip_init) e :4753 (fence_driver_hw_init); amdgpu_device.c:3161-3163 e :3167; amdgpu_fence.c:278-287 (mensagem 'Fence fallback timer expired on ring %s')`
- **[lido-no-codigo]** O 'zero linhas do dyndbg em amdgpu_irq.c' NAO prova que o IV nao chegou. sdma_v5_0_process_trap_irq descarta SILENCIOSAMENTE qualquer IV com entry->ring_id em {1,2,3} (comentarios '/* XXX compute */' e '/* XXX page queue*/' com corpo vazio) e tambem qualquer client_id fora de SDMA0/SDMA1 (o switch nao tem default). Nenhum desses caminhos imprime coisa alguma, e nenhum deles esta em amdgpu_irq.c. O unico print do handler e um DRM_DEBUG em sdma_v5_0.c, que o dyndbg 'file amdgpu_irq.c +p' nao habilita.
  - evidencia: `sdma_v5_0.c:1694-1739 (switch client_id / switch ring_id, cases 1,2,3 vazios, sem default); sdma_v5_0.c:1698 DRM_DEBUG("IH: SDMA trap\n")`
- **[lido-no-codigo]** Diferencas restantes entre o golden set cyan e os dos irmaos, todas benignas para IRQ: o cyan e o unico dos quatro que programa mmSDMA0/1_GB_ADDR_CONFIG e _GB_ADDR_CONFIG_READ (0x001877ff / 0x00000044), igual ao que o navi12 faz num set separado; CHICKEN_BITS e todos os RB_WPTR_POLL_CNTL sao identicos aos do navi. Nao ha nenhum registrador de interrupcao no golden set de nenhum dos chips.
  - evidencia: `sdma_v5_0.c:187-216 vs :118-143 e :178-185`
- **[lido-no-codigo]** Nao ha roteamento de cliente de IH por chip que pudesse desviar so o SDMA0: navi10_ih.c so registra um client id proprio (SOC15_IH_CLIENTID_IH) e nao possui tabela IH_CLIENT_CFG. Os ids sao fixos: SDMA0 = 0x08, SDMA1 = 0x09, e o SRCID de trap e 224 (0xE0) para AMBOS. Ou seja, client_id e a UNICA coisa que distingue os dois IVs de trap.
  - evidencia: `navi10_ih.c:559 (unico amdgpu_irq_add_id); include/soc15_ih_clientid.h:41-42; include/ivsrcid/sdma0/irqsrcs_sdma0_5_0.h e sdma1/irqsrcs_sdma1_5_0.h: SRCID__SDMA_TRAP = 224 nos dois`

### Propostas
- **Boot instrumentado unico que decide entre 'IV nunca chega' e 'IV chega e e descartado' e ainda datilografa a janela do TRAP_ENABLE** — 1 reboot(s), risco baixo
  - mecanismo: Hoje nao existe evidencia que separe tres mundos muito diferentes: (a) o IV de trap do SDMA0 realmente nunca e gerado; (b) ele e gerado, chega em sdma_v5_0_process_trap_irq e e descartado em silencio porque entry->ring_id != 0 (sdma_v5_0.c:1707-1720, cases vazios); (c) ele e gerado corretamente mas as fences que dispararam o fallback foram emitidas ANTES de TRAP_ENABLE ser ligado, na janela entre amdgpu_device.c:3163 (buffer_funcs ligado) e amdgpu_device.c:4753 (amdgpu_fence_driver_hw_init -> amdgpu_irq_get -> TRAP_ENABLE=1). O dyndbg em amdgpu_irq.c e cego para (b) e (c). Prints a partir do driver sao permitidos pelas restricoes.
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c, tres pontos:

1) topo de sdma_v5_0_process_trap_irq (linha 1698):
    dev_info_ratelimited(adev->dev,
        "sdma trap IV: client=%u src=%u ring_id=%u vmid=%u data0=0x%x\n",
        entry->client_id, entry->src_id, entry->ring_id,
        entry->vmid, entry->src_data[0]);

2) em sdma_v5_0_set_trap_irq_state (linha 1688), logo depois do WREG32:
    dev_info(adev->dev, "sdma trap_irq_state: type=%u state=%d reg=0x%x wrote=0x%x readback=0x%x\n",
             type, state, reg_offset, sdma_cntl, RREG32(reg_offset));

3) no fim de sdma_v5_0_gfx_resume_instance (antes do return da linha 838):
    dev_info(adev->dev, "sdma%d resumed: CNTL=0x%08x UTCL1_PAGE=0x%08x UTCL1_CNTL=0x%08x\n", i,
             RREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_CNTL)),
             RREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_UTCL1_PAGE)),
             RREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_UTCL1_CNTL)));

Sao leituras a partir do contexto do driver, nao MMIO cru de userspace. Build incremental so do modulo amdgpu.
  - teste: Boot frio, depois 'journalctl -k -b 0 | grep -E "sdma trap|sdma[01] resumed|Fence fallback"' e olhar a ORDEM dos timestamps.
- Se TODAS as linhas 'Fence fallback ... sdma0' vierem ANTES da linha 'trap_irq_state: type=0 state=1', a causa e a janela (c): o caminho de IRQ do SDMA0 esta SAO, os avisos de boot sao cosmeticos, e bc250_skip_sdma0 pode ser removido sem mais nada. Esse e o desfecho que atende ao pedido do usuario com custo zero.
- Se aparecerem linhas 'sdma trap IV: client=8' com ring_id != 0, a causa e o descarte silencioso e a correcao e roteamento no switch.
- Se DEPOIS de 'trap_irq_state: type=0 state=1 ... readback' com bit0=1 nunca aparecer nenhum 'client=8' enquanto aparecem 'client=9', ai sim o IV se perde de verdade no hardware e o problema muda de categoria.
- Bonus do ponto 3: o readback de CNTL das duas instancias mostra se TRAP_ENABLE/UTC_L1_ENABLE ficaram simetricos, e o de UTCL1_PAGE mostra se o bit 22 (USE_BC) do golden cyan sobreviveu ao 'temp &= 0xFF0FFF' de sdma_v5_0.c:809.
- **Backportar o soft reset do sdma_v5_2 para o sdma_v5_0_start (devolve o reload a quente e converte reboots em modprobes)** — 1 reboot(s), risco medio
  - mecanismo: sdma_v5_2_start() da um GRBM soft reset em cada engine antes do unhalt (sdma_v5_2.c:845); sdma_v5_0_soft_reset() e um stub vazio (sdma_v5_0.c:1528-1533) e sdma_v5_0_start() nao reseta nada. Em boot frio o estado deixado pelo boot ROM do PS5 e aceito; depois de um ciclo de uso a engine 0 nao volta e o ring test estoura em -110. O helper por engine ja existe no arquivo (sdma_v5_0_soft_reset_engine, linha 1330) e ja usa GRBM_SOFT_RESET.SOFT_RESET_SDMA0 << instance_id, entao a mudanca e mecanica.
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c:

- substituir o stub da linha 1528 por:

  static int sdma_v5_0_soft_reset(struct amdgpu_ip_block *ip_block)
  {
          struct amdgpu_device *adev = ip_block->adev;
          int i;

          for (i = 0; i < adev->sdma.num_instances; i++) {
                  sdma_v5_0_soft_reset_engine(adev, i);
                  udelay(50);
          }
          return 0;
  }

- mover a definicao de sdma_v5_0_soft_reset para antes de sdma_v5_0_start (ou declarar prototipo) e, em sdma_v5_0_start (linha ~946), inserir antes de sdma_v5_0_enable(adev, true):

          ip_block = amdgpu_device_ip_get_ip_block(adev, AMD_IP_BLOCK_TYPE_SDMA);
          if (!ip_block)
                  return -EINVAL;
          sdma_v5_0_soft_reset(ip_block);

  exatamente como sdma_v5_2.c:838-845.
  - teste: Sinal primario, sem carga de GPU: apos o boot, 'rmmod amdgpu' e 'modprobe amdgpu'. Sucesso = nao aparece 'ring sdma0 test failed (-110)' nem 'hw_init of IP block <sdma_v5_0> failed'. Falha = mesma mensagem de hoje, e a hipotese cai. Repetir 3x (n=3) porque o resultado e o proprio criterio de reprodutibilidade das proximas rodadas. Se passar, TODA experiencia seguinte de init de SDMA passa a custar um modprobe em vez de um reboot -- e o maior ganho de informacao por reboot disponivel neste alvo.
- **Corrigir sdma_v5_0_enable: '1 << inst_mask' -> 'inst_mask' (bug que so bate na instancia 0)** — 0 reboot(s), risco baixo
  - mecanismo: Com num_instances=2, 1<<GENMASK(1,0) = 8; for_each_inst(i,8) roda so com i=3; e get_reg_offset(adev,3,X) devolve os enderecos da INSTANCIA 0 porque so 'instance == 1' soma offset. Entao todo caminho de parada (hw_fini, suspend, e o ramo SRIOV do start) desabilita RB_ENABLE/IB_ENABLE da SDMA0 achando que e a instancia 3, e deixa a SDMA1 rodando com o RB apontando para memoria que vai ser liberada. Nao explica os avisos do boot frio (nesse caminho enable(false) nao e chamado), mas e uma assimetria real instancia-0-only no codigo dito simetrico, e um candidato direto para o estado sujo que faz o reload a quente falhar.
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c:664
-		sdma_v5_0_gfx_stop(adev, 1 << inst_mask);
+		sdma_v5_0_gfx_stop(adev, inst_mask);

Uma linha. Deve ser empacotada junto com a proposta 2 (mesmo build, mesmo reboot) porque as duas atacam o mesmo caminho de parada/religa.
  - teste: Com a proposta 2 aplicada, o teste e o mesmo ciclo rmmod/modprobe. Para atribuir credito separadamente, adicionar um dev_info em sdma_v5_0_gfx_stop imprimindo 'i' e o offset resolvido: antes da correcao imprime i=3 uma vez; depois imprime i=0 e i=1. Se o reload so passar com AMBAS as mudancas, reportar como par; se passar so com a 2, esta continua valendo como correcao de higiene.
- **Ligar TRAP_ENABLE no fim do gfx_resume da instancia, em vez de esperar amdgpu_fence_driver_hw_init** — 1 reboot(s), risco baixo
  - mecanismo: Se a proposta 1 confirmar o desfecho (c), o SDMA0 esta com o trap fisicamente desligado durante toda a janela [amdgpu_device.c:3163 .. :4753], que e exatamente onde a KFD init faz suas copias. Ligar o bit ja no resume da engine fecha a janela. E idempotente: amdgpu_irq_get depois vai reescrever o mesmo bit via sdma_v5_0_set_trap_irq_state, e amdgpu_irq_put no hw_fini continua desligando. Nao mexe em nenhuma ordem de init de IP.
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c, dentro do bloco 'if (!amdgpu_sriov_vf(adev))' que ja faz RMW em SDMA0_CNTL (linhas 791-798), acrescentar TRAP_ENABLE ao mesmo RMW:

 		temp = RREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_CNTL));
 		temp = REG_SET_FIELD(temp, SDMA0_CNTL, UTC_L1_ENABLE, 1);
 		temp = REG_SET_FIELD(temp, SDMA0_CNTL, MIDCMD_PREEMPT_ENABLE, 1);
+		/* close the window where TTM/KFD already uses sdma0 as
+		 * buffer_funcs_ring but amdgpu_fence_driver_hw_init has not
+		 * run yet, so no trap IV would ever be generated */
+		temp = REG_SET_FIELD(temp, SDMA0_CNTL, TRAP_ENABLE, 1);
 		WREG32(sdma_v5_0_get_reg_offset(adev, i, mmSDMA0_CNTL), temp);

So aplicar DEPOIS que a proposta 1 confirmar o desfecho (c). Se a proposta 1 mostrar (a), esta mudanca e inutil e deve ser descartada.
  - teste: Boot frio e 'journalctl -k -b 0 | grep "Fence fallback"'. Sucesso = ZERO ocorrencias de 'Fence fallback timer expired on ring sdma0' (hoje sao 2-3, em todo boot, deterministicamente). n=3 boots. Se os avisos sumirem, o IV do SDMA0 esta comprovadamente sendo entregue e o passo seguinte e remover amdgpu.bc250_skip_sdma0=1 e repetir HSA_ENABLE_SDMA=1 para ver se a copia enfileirada na engine 0 passa a sinalizar. Se os avisos persistirem apos o readback confirmar bit0=1, a hipotese (c) cai e sobra (a).
- **Alinhar mmSDMA0/1_UTCL1_PAGE com o valor dos irmaos navi (zerar USE_BC) -- ataca a CORRUPCAO de copia, nao o IRQ** — 1 reboot(s), risco medio
  - mecanismo: Unica diferenca semantica de golden register entre cyan skillfish e navi: bit 22 USE_BC = 1 no cyan, 0 no navi (sdma_v5_0.c:201/:215 vs :130/:142), mais o bit 23 ADDR_IS_PA que o cyan deixa intocado por causa da mascara 0x007fffff enquanto o navi zera. Esses bits governam o caminho de traducao de endereco das leituras/escritas de DADOS da SDMA. Eles NAO podem produzir nem suprimir um IV de trap. Mas sao candidatos plausiveis para o outro sintoma medido -- um pedaco de 2 MiB faltando numa copia grande host->device -- que e exatamente uma falha de traducao/coerencia, nao de sinalizacao. Estou propondo isto explicitamente como teste do sintoma de DADOS, para nao contaminar a conta do IRQ.
  - mudanca: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c:201 e :215, em golden_settings_sdma_cyan_skillfish:
-	SOC15_REG_GOLDEN_VALUE(GC, 0, mmSDMA0_UTCL1_PAGE, 0x007fffff, 0x004c5c00),
+	SOC15_REG_GOLDEN_VALUE(GC, 0, mmSDMA0_UTCL1_PAGE, 0x00ffffff, 0x000c5c00),
(idem mmSDMA1_UTCL1_PAGE)

OBS: nao mexer em sdma_v5_0.c:809 ('temp &= 0xFF0FFF'), que preserva os bits 22/23 -- e por isso que o valor golden sobrevive ate o fim do resume.
  - teste: So faz sentido rodar DEPOIS que o IRQ estiver resolvido e com bc250_skip_sdma0 removido, senao nao ha trafego de usuario na engine 0 para medir. Sinal: repetir o lote de copias grandes host->device com HSA_ENABLE_SDMA=1 e verificar byte a byte o buffer de destino. Sucesso = nenhum bloco de 2 MiB faltando em 3 repeticoes. Falha/regressao = qualquer 'ring sdma0 test failed' no boot, ou page faults novos do UTCL1 no dmesg -- nesse caso reverter. Antes disso, o log do ponto 3 da proposta 1 ja diz de graca qual valor UTCL1_PAGE as duas engines estao realmente carregando, o que confirma ou nega que o golden cyan chegou ao hardware.

### [REFUTADA] amdgpu_test_ib via debugfs para decidir "IRQ perdido em regime" no sdma0
- O mecanismo esta CORRETO no papel — conferi simbolo por simbolo na arvore /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1 e nada foi inventado: amdgpu_debugfs.c:1640 amdgpu_debugfs_test_ib_show, :1781 DEFINE_SHOW_ATTRIBUTE, :2157 debugfs_create_file("amdgpu_test_ib", 0400); amdgpu_fence.c:846-847 amdgpu_fence_enable_signaling arma o fallback; :283-286 amdgpu_fence_fallback so avisa se amdgpu_fence_process retornou true; amdgpu_fence.c:131 amdgpu_fence_emit sempre faz OR de AMDGPU_FENCE_FLAG_INT (logo o trap E emitido); sdma_v5_0_ring_test_ib usa dma_fence_wait_timeout com tmo = AMDGPU_IB_TEST_TIMEOUT = 1000 ms (amdgpu_ib.c:38,414) contra AMDGPU_FENCE_JIFFIES_TIMEOUT = HZ/2 (amdgpu.h:279) — ou seja, o fallback dispararia ANTES do timeout do teste, exatamente como a proposta diz. Mesmo assim ela morre por tres motivos.

1) "CUSTO ZERO" E FALSO. amdgpu_ib_ring_tests testa TODOS os rings prontos, nao so os sdma, e em amdgpu_ib.c:467 faz `ring->sched.ready = false` PERMANENTEMENTE em qualquer ring que falhe, e em :471-474 faz `adev->accel_working = false` se o ring que falhar for o gfx[0]. Numa placa que ja demonstrou "ring sdma0 test failed (-110)" quando reinicializada, a hipotese de o IB test do sdma0 falhar nao e remota. Se falhar, voce perde em definitivo o buffer_funcs_ring (sdma0 = todas as copias do TTM) no meio da sessao, sem reload possivel — custo real: exatamente 1 reboot, o que a proposta prometia economizar, mais uma sessao corrompida. Alem disso o handler faz drm_sched_wqueue_stop em todos os rings (amdgpu_debugfs.c:1656-1663) e segura down_write(reset_domain->sem): desktop congelado por ate ~1 s por ring com o compositor vivo.

2) O RESULTADO NEGATIVO JA ESTA DETERMINADO PELA EVIDENCIA QUE VOCE JA TEM, DE GRACA. Todo job que passa pelo drm_sched instala dma_fence_add_callback na hw fence (scheduler/sched_main.c:1273) -> __dma_fence_enable_signaling -> amdgpu_fence_enable_signaling -> ARMA O MESMO fallback timer. adev->mman.buffer_funcs_ring = sdma0 e a mman.entity e uma entity de drm_sched, entao toda movimentacao/limpeza de buffer do TTM em regime arma o timer do sdma0. Se o trap do sdma0 continuasse perdido depois do init, o dmesg estaria VOMITANDO "Fence fallback timer expired on ring sdma0" durante uso normal — e o fato medido diz que sao 2 a 3 linhas, so no boot, nunca mais. Ou seja: para o ring de KERNEL do sdma0, a tese de "IRQ perdido em regime" ja esta praticamente refutada sem gastar nada. O teste proposto so re-executa, com risco, um experimento cujo resultado o log ja entregou. (Ressalva honesta: amdgpu.vm_update_mode=3 tira as atualizacoes de page table do SDMA, entao a metade "vm_pte_scheds" do argumento nao vale; sobra a metade do TTM, que basta.)

3) UM "PASSED, ZERO FALLBACKS" SERIA UM FALSO ATESTADO DE SAUDE PARA O BUG QUE REALMENTE DOI. O sintoma de userspace medido (HSA_ENABLE_SDMA=1 girando a 199% de CPU, e o pedaco de 2 MiB faltando) vem de FILA DE USUARIO do KFD, nao do ring de kernel. Em sdma_v5_0_process_trap_irq o driver so chama amdgpu_fence_process para `entry->ring_id == 0`; ring_id 1, 2 e 3 caem em `/* XXX compute */` e nao fazem NADA. amdgpu_test_ib exercita unicamente o ring_id 0. Logo o teste nao pode confirmar nem refutar nada sobre o caminho que quebra na pratica — ele responde uma pergunta adjacente e corre o risco de encerrar a investigacao com a conclusao errada.

Bonus (nao decisivo, mas mostra que a proposta nao foi conferida contra ESTA arvore): o caminho esta errado. drm_debugfs.c:406 cria o diretorio com `debugfs_create_dir(dev->unique, drm_debugfs_root)` e :443 aponta minor->debugfs_root para ele, entao neste kernel e /sys/kernel/debug/dri/0000:01:00.0/, nao /sys/kernel/debug/dri/1/.

Sobre a assimetria: a proposta e diagnostico, nao correcao, entao nao precisa explicar por que a instancia 1 funciona — mas tambem nao ajuda a localizar, porque o desfecho esperado (ambos passam, zero fallback) nao discrimina nada.
- correcao sugerida: Trocar o poke ativo por duas leituras passivas que custam literalmente nada, nao submetem trabalho a GPU, nao param scheduler nenhum e nao encostam em MMIO cru de userspace:

(a) Contagem em regime, com n>=3 boots: depois de uma sessao com uso pesado de GPU (jogo, alguns minutos de compositor), `journalctl -k -b | grep -c 'fallback timer expired'` e `journalctl -k -b | grep 'fallback timer expired'`. Se o total continuar sendo so as 2-3 linhas do boot, com timestamps todos < ~11 s, a tese de "IRQ perdido em regime no ring de kernel do sdma0" esta morta — porque cada job do TTM no sdma0 rearma o mesmo timer (sched_main.c:1273 -> amdgpu_fence.c:846).

(b) Provar que houve trafego no sdma0 depois do boot, para o item (a) nao ser um argumento vazio: `sudo cat /sys/kernel/debug/dri/0000:01:00.0/amdgpu_fence_info` (criado em amdgpu_fence.c:991, modo 0444). Ele imprime "Last signaled fence" e "Last emitted" por ring (amdgpu_fence.c:905-914). Ler duas vezes, com um jogo/carga de GPU entre as leituras. Se o "Last emitted" do sdma0 subiu bastante e "Last signaled" acompanhou, e o contador de (a) nao mexeu: encerrado, o trap do sdma0 funciona depois do init e o problema e restrito a janela de inicializacao e/ou as filas de usuario do KFD. Se o "Last emitted" do sdma0 NAO se mexer, (a) nao prova nada e ai sim faz sentido pensar num provocador — mas um que toque so o sdma0, nunca o gfx.

Observacao: amdgpu_fence_info chama amdgpu_fence_process (amdgpu_fence.c:902), que so le a fence em memoria WB via amdgpu_fence_read — sem MMIO, sem submissao, seguro.

Se depois disso ainda quiserem o teste ativo, ele so e defensavel com: caminho corrigido para /sys/kernel/debug/dri/0000:01:00.0/amdgpu_test_ib, executado de um TTY sem compositor, ciente de que uma falha marca ring->sched.ready = false para o resto da sessao (amdgpu_ib.c:467) e que falha no gfx[0] derruba accel_working (amdgpu_ib.c:473) — e sem chamar isso de custo zero. E, mesmo passando, ele nao diz nada sobre as filas de usuario do KFD (ring_id 1-3 nao sao tratados em sdma_v5_0_process_trap_irq).

### [REFUTADA] Limpar storm/flood/credito do IH deixado pelo firmware do PS5
- Simbolos OK e assimetria OK, mas o mecanismo alegado nao produz o sintoma medido, e o criterio de refutacao e invalido.

(1) Simbolos: todos existem e sao alcancaveis. navi10_ih.c ja inclui oss/osssys_5_0_0_offset.h e _sh_mask.h. mmIH_STORM_CLIENT_LIST_CNTL=0x00da, mmIH_INT_FLOOD_CNTL=0x00d5, mmIH_CLIENT_CREDIT_ERROR=0x00e1, mmIH_LIMIT_INT_RATE_CNTL=0x00cd. Campos FLOOD_CNTL_ENABLE (bit 3), CLEAR_INT_FLOOD_STATUS (bit 4), IH_CLIENT_CREDIT_ERROR__CLEAR_MASK (0x1), LIMIT_ENABLE (bit 0) existem. Nenhuma invencao. Nao refuto por aqui.

(2) A premissa "navi10_ih.c nunca escreve esses regs" e VERDADEIRA e verificada: os unicos WREG32_SOC15(OSSSYS,...) do arquivo sao mmIH_RB_CNTL_RING1 (l.127), mmIH_RB_CNTL_RING2 (l.137), mmIH_CNTL2 (l.140), mmIH_CHICKEN_Sienna_Cichlid (l.340), mmIH_CHICKEN (l.346), mmIH_CLK_CTRL (l.665). E nao ha golden settings de OSSSYS em nv.c. Nao refuto por aqui.

(3) A assimetria E explicada estruturalmente: SOC15_IH_CLIENTID_SDMA0=0x08 e SDMA1=0x09 (soc15_ih_clientid.h:41-42), e ambos os regs sao bitfields por cliente com CLIENT8_IS_STORM_CLIENT_MASK=0x100 vs CLIENT9=0x200, e CLIENT_8_ERROR_MASK=0x100 vs CLIENT_9_ERROR_MASK=0x200. Um bit de diferenca explica SDMA0 perde / SDMA1 nunca. Essa e a parte forte e nao refuto ela.

(4) REFUTACAO PRINCIPAL - o mecanismo e occupancy-gated e o sintoma nao tem occupancy. IH_INT_FLOOD_CNTL__HIGHWATER e um campo de 3 bits (mask 0x00000007L): e um limiar de OCUPACAO do anel do IH. Descarte de storm client so ocorre acima do highwater. O fato medido e perda de IV em TODO boot frio, ANTES DE QUALQUER CARGA, com o anel do IH praticamente vazio, e com taxa de perda de ~100% (as 2-3 primeiras fences do sdma0, todas perdidas). Anel vazio nao floda. Alem disso, IH_STORM_CLIENT_LIST_CNTL sozinho, no uso documentado pela propria AMD (comentario em ih_v6_0.c:368-376), serve para ATRASAR o MSI via IH_MSI_STORM_CTRL.DELAY, nao para descartar o IV - e mmIH_MSI_STORM_CTRL NAO EXISTE em osssys_5_0_0 (grep vazio no offset e no sh_mask). Ou seja, a proposta mexe em metade de um mecanismo cujo par nem existe nesta geracao.

(5) REFUTACAO DO TESTE - o criterio de kill e invalido para metade das proprias hipoteses. IH_CLIENT_CREDIT_ERROR e status LATCH-ADO EM RUNTIME. O dump roda dentro de navi10_ih_irq_init (~10.166s medidos); os fallbacks do sdma0 saem em ~10.945s. Ler CLIENT_8_ERROR=0 as 10.166s nao diz nada sobre um erro de credito que so latcharia quando o SDMA0 emitir o IV, ~0.8s depois. O criterio declarado ("valores antes ja eram zero -> hipotese morta, nao gastar mais reboots") mataria uma hipotese viva com evidencia ruim, de forma permanente. Isso e pior do que gastar o reboot.

(6) Confundidor: sao 4 escritas cegas num bloco so. Se os fallbacks sumirem, nao se sabe qual delas foi. E a proposta ainda zera IH_CLIENT_CREDIT_ERROR no init sem nunca reler depois, ou seja, apaga a testemunha e nao volta pra olhar.

(7) A proposta ignora o registrador que faz exatamente o que a hipotese precisa: mmIH_INT_DROP_CNTL (0x018e) com INT_DROP_EN (bit 0), CLIENT_ID_MATCH_EN (bit 1), SOURCE_ID_MATCH_EN (bit 2), INT_DROPPED (bit 16), mais mmIH_INT_DROP_MATCH_VALUE0/1 (0x018f/0x0190) e mmIH_INT_DROP_MATCH_MASK0/1 (0x0191/0x0192). Filtro de descarte por client_id INCONDICIONAL, nao depende de ocupacao, tambem nunca escrito por navi10_ih.c. Esse sim casa com "sempre perde, desde boot frio, sem carga".

Conclusao: a CLASSE de hipotese (estado de filtro por cliente deixado pelo firmware do console) continua sendo a melhor explicacao estrutural da assimetria e nao contradiz nenhum fato medido. Mas ESTA proposta especifica aponta para os registradores errados e propoe um teste que nao distingue. Refutada como escrita.
- correcao sugerida: Trocar de "escrever as apostas" para "ler a testemunha", no mesmo reboot, e so depois escrever.

PASSO 1 (leitura pura, custo zero de risco, mesmo reboot do dump da proposta 1). O registrador que responde a pergunta inteira ja existe: mmIH_INT_FLOOD_STATUS (0x00d9), com INT_DROP_CNT (bits 0-7), FIRST_DROP_INT_CLIENT_ID (bits 8-15), FIRST_DROP_INT_SOURCE_ID (bits 16-23), INT_DROPPED (bit 30). Complementos: mmIH_RB0_INT_FLOOD_STATUS (0x00d6, RB_INT_DROPPED bit 31), mmIH_INT_DROP_CNTL (0x018e, INT_DROPPED bit 16), mmIH_CREDIT_STATUS (0x00e5), mmIH_INT_FLAGS (0x00dc), mmIH_LAST_INT_INFO0/1/2 (0x00dd/de/df).

Se FIRST_DROP_INT_CLIENT_ID == 0x08 e INT_DROPPED == 1, a hipotese esta CONFIRMADA de forma direta, sem escrever nada. Se INT_DROP_CNT == 0 e INT_DROPPED == 0 depois dos fallbacks, o IH nao esta descartando nada e TODA a classe morre de vez.

PASSO 2 (o ponto de leitura importa, e a proposta erra ele). Nao basta ler em navi10_ih_irq_init (~10.166s). Os fallbacks saem em ~10.945s. Ler os status DEPOIS do evento. Sem MMIO de userspace (proibido nesta placa), entao fazer dentro do driver: acrescentar um print tardio no contexto do proprio driver, por exemplo em amdgpu_fence_fallback / amdgpu_fence_process quando ring->funcs->type == AMDGPU_RING_TYPE_SDMA, ou um delayed_work de ~2s agendado no fim de navi10_ih_irq_init que despeja o bloco de status. Assim se compara "config no init" (proposta 1) contra "status apos a perda" (isto), no MESMO boot.

PASSO 3 (so se o passo 1/2 confirmar). Ai sim escrever, mas so o registrador que o status apontar, uma coisa de cada vez, para nao ter confundidor de 4 escritas.

MUDANCAS ESPECIFICAS NA PROPOSTA, se mesmo assim for aplicar:
- Incluir mmIH_INT_DROP_CNTL no dump e na limpeza. E o unico descarte por client_id incondicional deste bloco e e o candidato que realmente casa com "perde com anel vazio". Limpar assim: WREG32_SOC15(OSSSYS, 0, mmIH_INT_DROP_CNTL, 0); e zerar mmIH_INT_DROP_MATCH_VALUE0/1 e mmIH_INT_DROP_MATCH_MASK0/1.
- REMOVER o criterio de refutacao "valores antes ja eram zero -> hipotese morta". E invalido para IH_CLIENT_CREDIT_ERROR e IH_INT_FLOOD_STATUS, que latcham depois do init. O criterio correto de morte e: INT_DROP_CNT==0 e INT_DROPPED==0 e IH_INT_DROP_CNTL.INT_DROPPED==0 LIDOS APOS os fallbacks do sdma0.
- Baixar a expectativa em IH_STORM_CLIENT_LIST_CNTL e IH_INT_FLOOD_CNTL: sao occupancy-gated (HIGHWATER, 3 bits) e nao explicam perda de 100% num anel vazio. Manter a limpeza deles e barato, mas nao contar como o mecanismo.
- IH_LIMIT_INT_RATE_CNTL: manter, mas e o candidato mais fraco dos quatro. Rate limit e global, nao por cliente, entao nao explica a assimetria de jeito nenhum. Se ele for a causa, sdma1 tambem perderia.
- module_param: 0644 esta errado dado que so vale em irq_init. Usar 0444. E lembrar que params do amdgpu sao declarados em amdgpu_drv.c (module_param_named + MODULE_PARM_DESC) e precisam de extern em amdgpu.h; o snippet nao mostra esse plumbing.

### [SOBREVIVEU] Boot instrumentado unico do IH — sobrevive, mas 3 dos 4 criterios de decisao estao quebrados como escritos
- CONTRADIZ UM "FATO"? Nao — mas expoe que um deles e inferencia, nao medicao, e eu digo isso em voz alta: o bullet "=> O IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch" NAO esta provado. Li amdgpu_irq.c: em amdgpu_irq_dispatch o caminho de sucesso (`src = adev->irq.client[client_id].sources[src_id]` -> `src->funcs->process(...)`) NAO imprime absolutamente nada, e os tres dev_dbg ("Invalid client_id", "Invalid src_id", "Unregistered interrupt") so disparam para ids nao registrados. Com client_id=8 (SOC15_IH_CLIENTID_SDMA0, confirmado 0x08 em include/soc15_ih_clientid.h:41) e src_id=224 registrados, o IV atravessa o dyndbg em silencio absoluto e cai em sdma_v5_0_process_trap_irq, onde os `case 1/2/3` vazios e a AUSENCIA de `default` no switch(entry->ring_id) o descartam sem uma linha de log. Ou seja: a evidencia de zero dev_dbg e 100% compativel com "o IV chega e e comido silenciosamente". A proposta ataca exatamente essa lacuna. Isso e o argumento mais forte a favor dela.

ASSIMETRIA: e diagnostico, nao correcao — nao precisa explicar por que a inst.1 funciona, precisa produzir sinal assimetrico. Produz: IV por client 8 vs 9, bit 8 vs bit 9 em IH_CLIENT_CREDIT_ERROR, CLIENT8 vs CLIENT9_IS_STORM_CLIENT, entradas 8 vs 9 de IH_CLIENT_CFG_DATA, SDMA0_CNTL das duas instancias.

SIMBOLOS (todos verificados no proprio tree /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1, que e o tree correto — bc250_dead_gpu_guard em gmc_v10_0.c:68 e bc250_skip_sdma0 em kfd_device_queue_manager.c:165 estao la, e amdgpu.ko esta buildado): mmIH_STORM_CLIENT_LIST_CNTL, mmIH_INT_FLOOD_CNTL, mmIH_INT_FLOOD_STATUS, mmIH_CLIENT_CREDIT_ERROR, mmIH_LIMIT_INT_RATE_CNTL, mmIH_CLIENT_CFG, mmIH_CLIENT_CFG_INDEX, mmIH_CLIENT_CFG_DATA — todos presentes em include/asic_reg/oss/osssys_5_0_0_offset.h (navi10_ih.c ja inclui esse header, linha 29). Campos batem: INT_DROPPED shift 0x1e (bit30, a proposta acertou), INT_DROP_CNT[7:0], FIRST_DROP_INT_CLIENT_ID[15:8], FIRST_DROP_INT_SOURCE_ID[23:16]; CLIENT_8_ERROR bit 8 / CLIENT_9_ERROR bit 9; CLIENT8/9_IS_STORM_CLIENT bits 8/9; IH_CLIENT_CFG__TOTAL_CLIENT_NUM[4:0]; IH_CLIENT_CFG_DATA__RING_ID[21:20] e CREDIT_RETURN_ADDR[17:0]. NBIO: mmBIF_SDMA0_DOORBELL_RANGE (0x01d0) e mmBIF_IH_DOORBELL_RANGE (0x01d2) existem em nbio_2_3_offset.h (nv.c usa nbio_v2_3) e cyan_skillfish_reg_init.c popula NBIO_HWIP e OSSSYS_HWIP. atomic_dec_if_positive tem a semantica alegada (retorna v-1; so armazena se >=0), logo o gate `>= 0` da exatamente 64 logs. Zero simbolo inventado.

O TESTE DISTINGUE? Parcialmente. Criterio (1) e decisivo e limpo. Criterios (2), (3-parcial) e (4) estao quebrados como escritos — ver correcao. Nao vale gastar o reboot sem consertar, porque tres dos quatro ramos retornariam "inconclusivo" disfarcado de "refutado", e a proposta terminaria com o falso veredito "o IV morre antes do IH, angulo esgotado".

BONUS que reduz o custo: o tracepoint amdgpu:amdgpu_iv ja existe em amdgpu_trace.h e ja carrega client_id, src_id, ring_id, vmid, pasid e src_data[0..3], emitido em amdgpu_irq_dispatch ANTES de qualquer filtragem. Todo o criterio (1) e obtivel sem recompilar. Como modprobe a quente falha (-110), so da pra ligar via cmdline; ponha `trace_event=amdgpu:amdgpu_iv trace_buf_size=8M` no MESMO boot como rede de seguranca redundante — custo zero.

OVERFLOW ja esta coberto: navi10_ih_get_wptr faz dev_warn incondicional de "ring buffer overflow"; como isso nunca apareceu no dmesg, perda em massa por overflow do anel de IH ja esta excluida. Nao adicione dump de RB_OVERFLOW.
- correcao sugerida: Cinco consertos obrigatorios antes de queimar o reboot.

1) ORCAMENTO DE LOG POR CLIENTE (senao o teste se auto-sabota). Um unico contador de 64 compartilhado deixa o trafego de sdma1 — que e o caso NAO interessante e potencialmente abundante durante o boot — esgotar o orcamento antes do IV de client=8 que voce esta cacando. Use dois contadores: `static atomic_t log8 = ATOMIC_INIT(64), log9 = ATOMIC_INIT(16);` e escolha pelo entry->client_id.

2) CRITERIO (2) E INDECIDIVEL COMO ESCRITO. "IVs client=9 em numero maior do que o trafego real do sdma1" — nao ha ground truth de trafego real na instrumentacao proposta, e o pacote TRAP do SDMA nao carrega discriminante de instancia (sdma_v5_0_ring_emit_fence emite INT_CONTEXT(0), entao src_data nao distingue). Conserte com contadores + comparacao contra as fences realmente emitidas: mantenha `atomic_t iv_count[2]` incrementado em TODO IV de client 8/9, e no dump de +8 s imprima, para i em 0..1, `iv_count[i]` ao lado de `adev->sdma.instance[i].ring.fence_drv.sync_seq` e `atomic_read(&...->last_seq)`. Aliasing fica decisivo: iv_count[8]==0 e iv_count[9] ~= sync_seq(ring0)+sync_seq(ring1).

3) CRITERIO (4) TEM FALSO NEGATIVO EMBUTIDO. Em ASIC com PSP a tabela de client cfg historicamente nao e escrita por MMIO direto — o precedente in-tree e psp_v3_1_reroute_ih (psp_v3_1.c:155), que roteia clientes via MP0_SMN_C2PMSG_69/70 + GFX_CTRL_CMD_ID_GBR_IH_SET em vez de tocar mmIH_CLIENT_CFG_INDEX/DATA. Se as entradas 8 e 9 lerem ambas 0x00000000 ou 0xffffffff, isso e "porta nao legivel pelo host", NAO "simetrico". Escreva o criterio assim explicitamente. Alem disso nao assuma indice==client_id (nao provado; ambos sao 5 bits, e plausivel, so isso) e nao itere ate TOTAL_CLIENT_NUM-1 — se esse campo ler 0 o loop nao roda e voce volta de maos vazias sem perceber. Itere 0..31 fixo e imprima TOTAL_CLIENT_NUM so como informativo.

4) MOVA A UNICA ESCRITA PARA DEPOIS DA FALHA. WREG32 em mmIH_CLIENT_CFG_INDEX e o unico write do patch inteiro. Nao o execute no fim de navi10_ih_irq_init: a falha ocorre ~0,8 s depois (irq init 10,166 s, fallback 10,945 s) e voce estaria mexendo numa porta de config do IH dentro da janela exata sob estudo. Faca o walk da tabela SOMENTE no delayed_work de +8 s (~18 s, ja pos-falha). O dump em ih_irq_init fica so com as leituras (baseline de FLOOD/CREDIT/STORM/RATE/doorbell/SDMA0_CNTL das duas instancias).

5) DEFAULT DO PARAM. `bc250_ih_debug` tem que default 1 (ou ir no cmdline), senao o reboot e desperdicado — tudo que importa acontece no boot. Melhor ainda: troque module_param por module_param_cb com um .set que dispara o dump na hora; ai o mesmo boot serve pra post-mortem depois de provocar a falha com carga, em vez de so a foto de +8 s.

E acrescente `trace_event=amdgpu:amdgpu_iv trace_buf_size=8M` ao cmdline do mesmo boot. Redundancia gratis: se o dev_info em contexto de IRQ perder algo, o ftrace pega, e o tracepoint ve TODOS os clientes, nao so 8 e 9.

### [REFUTADA] Handler de trap "tolerante" (broadcast de amdgpu_fence_process nas duas instancias do SDMA)
- REFUTADA em quatro frentes. (Checagem de simbolos primeiro: tudo que a proposta cita EXISTE e faz o que ela diz. sdma_v5_0_process_trap_irq esta em sdma_v5_0.c:1694-1740 com exatamente os dois switch aninhados (client_id 1705, ring_id 1707/1723, cases 1/2/3 vazios). amdgpu_fence_process esta em amdgpu_fence.c:220 (a proposta disse 218, irrelevante). SOC15_IH_CLIENTID_SDMA0/1, buffer_funcs_ring = instance[0].ring (sdma_v5_0.c:2051) e vm_pte_scheds com todas as instancias (2069) conferem. Nao ha invencao de simbolo. Morre pelo resto.)

1) ASSIMETRIA — metade do mecanismo morre na hora. O ramo "ring_id caiu no case 1/2/3 vazio" e RIGOROSAMENTE simetrico: linhas 1707-1720 e 1723-1736 sao o mesmo codigo, o mesmo switch, os mesmos cases vazios, para SDMA0 e SDMA1. Se esse fosse o dreno, o sdma1 perderia IRQ exatamente igual. Nao perde (fato medido: sdma1 nunca, em nenhum boot). Esse ramo nao explica nada. Sobra so o ramo de aliasing de client_id.

2) O RAMO SOBREVIVENTE CONTRADIZ UM FATO MEDIDO. Aliasing de client_id significa que o IV do sdma0 CHEGA ao amdgpu_irq_dispatch, so que rotulado como SDMA1. Isso contradiz frontalmente "=> O IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch". Digo em voz alta, como pedido: a proposta so tem chance de estar certa se essa conclusao estiver errada. E ela PODE estar — li amdgpu_irq.c:497-525 e os dev_dbg so disparam para client_id >= MAX, src_id >= MAX, client sem sources, ou source nao registrada; um IV com client_id SDMA1 valido e src_id registrado e despachado em SILENCIO, sem nenhuma linha de debug. Ou seja, o dyndbg zerado NAO distingue "IV nunca chegou" de "IV chegou com o rotulo errado". Mas a conclusao correta disso e MEDIR qual dos dois e, nao aplicar um patch que so funciona num dos casos e que nao te diz em qual voce esta.

3) BUG DE ROTEAMENTO E DETERMINISTICO; O SINTOMA NAO E. Aliasing de client_id ou drop por ring_id derruba 100% dos traps do sdma0 pelo boot inteiro. O sdma0 e o buffer_funcs_ring: TODA copia de TTM passa nele, o boot inteiro e depois dele. Com perda total, cada dma_fence_wait arma o fallback (amdgpu_fence_enable_signaling, amdgpu_fence.c:844-848, HZ/2 = 0,5 s) e cada expiracao com fence completa imprime o dev_warn (amdgpu_fence.c:277-286, SEM rate limit). Isso seria uma enxurrada de warnings proporcional ao trafego de TTM, nao "2 a 3 vezes no boot e silencio". A contagem observada e incompativel com um dreno deterministico de roteamento — ela cheira a janela de inicializacao (ordem de habilitacao de IRQ/TRAP_ENABLE/MSI), nao a switch mal escrito. Nota adicional: com amdgpu.vm_update_mode=3 as tabelas de pagina sao atualizadas por CPU (amdgpu_vm.c:2939-2950 + use_cpu_for_update), entao o ring de kernel do sdma1 e praticamente OCIOSO — parte da "assimetria" pode ser so ausencia de trafego, o que enfraquece ainda mais a base do argumento.

4) O TESTE NAO DISCRIMINA — este e o golpe fatal, porque custa um reboot. (a) amdgpu_fence_process NAO e o "le a seq e sai" que a proposta afirma. Toda chamada, inclusive a espuria, executa `if (timer_delete(&ring->fence_drv.fallback_timer) && seq != sync_seq) amdgpu_fence_schedule_fallback(ring)` (amdgpu_fence.c:232-234). Traduzindo: cada chamada espuria no ring sdma0, com fence AINDA pendente, MATA e REARMA o timer de fallback, empurrando o prazo de 0,5 s para frente. Basta qualquer fluxo de IVs de SDMA (traps do sdma1, ou traps do proprio sdma0 com ring_id 1/2/3 vindos de filas RLC/KFD) a menos de 0,5 s de intervalo para que a mensagem SUMA sem que hipotese nenhuma tenha sido confirmada — sumico por adiamento de timer, nao por conserto de roteamento. O sinal de sucesso alegado ("as linhas somem do boot frio") e produzido igualmente pela hipotese nula. (b) A contraprova e pior. O sintoma e, pelos proprios fatos, exclusivo de boot frio "antes de qualquer carga", 2-3 ocorrencias, e nunca foi demonstrado reproduzivel em runtime. Escrever 0 no param e "mover BOs grandes" nao garante nada: o warning so aparece se a fence for emitida no sdma0, alguem esperar nela (enable_signaling), o HW completar, e nenhum outro fence_process ocorrer na janela de 0,5 s. Se as mensagens nao voltarem, voce nao sabe se foi o patch ou se voce simplesmente nao reproduziu a condicao de boot. "Confirmacao e refutacao no MESMO boot" e falso. (c) Detalhe de implementacao que tambem esta errado: `static int` declarado dentro do corpo da funcao nao pode virar module_param — module_param_named exige escopo de arquivo, senao nao existe /sys/module/amdgpu/parameters/bc250_sdma_trap_broadcast nenhum e a contraprova nem roda.

Resumo: a metade simetrica do mecanismo esta morta, a metade viva exige derrubar um fato medido sem trazer evidencia nova, a assinatura temporal do sintoma e incompativel com bug de roteamento, e o experimento retorna o mesmo resultado sob a hipotese nula. Isso e um mascarador de sintoma vendido como diagnostico, e custa um reboot.
- correcao sugerida: Transformar o mesmo reboot em MEDICAO, nao em conserto. Concretamente:

(0) ANTES de qualquer reboot, checagem de graca: `journalctl -b -k | grep -c "Fence fallback"` e o mesmo em boots anteriores (`-b -1`, `-b -2`), mais um teste de carga de TTM em runtime (alocar/mover VRAM ate forcar eviccao) observando se a mensagem reaparece. Se o warning NUNCA aparece depois do boot apesar de o sdma0 ser o buffer_funcs_ring, dreno deterministico de roteamento ja esta excluido sem gastar reboot nenhum, e a proposta morre de graca.

(1) Se ainda quiser gastar o reboot, instrumente em vez de corrigir. Em sdma_v5_0_process_trap_irq, antes dos switch, contar em arrays estaticos indexados por [client_id do SDMA][ring_id] todos os IVs recebidos, e contar separadamente quantas chamadas a amdgpu_fence_process retornaram true por instancia. Expor via debugfs ou um module_param readonly de leitura (arquivo-escopo, nao dentro da funcao). Zero MMIO — sao campos do IV que ja estao em memoria, entao nao viola a restricao dura. Adicionar tambem um dump de fence_drv.sync_seq vs atomic_read(last_seq) dos dois rings.

(2) Leitura do resultado, que agora e discriminante de verdade:
 - contador de SDMA1/ring0 anormalmente alto E last_seq do sdma1 sem avancar => aliasing de client_id CONFIRMADO. So NESTE caso o broadcast e a correcao certa, e ai ele vira um one-liner obvio.
 - contadores de SDMA0 em qualquer ring_id ~= 0 enquanto as fences do sdma0 completam (sync_seq avanca, last_seq so anda via fallback) => o IV realmente nao chega; o bug esta a montante (TRAP_ENABLE/SDMA0_CNTL, roteamento do IH, MSI, doorbell) e o broadcast e inutil por construcao. Confirma o fato medido e mata a proposta com dado, nao com argumento.
 - contadores de SDMA0 com ring_id 1/2/3 nao-zero enquanto ring_id 0 e zero => ai sim o case vazio importa, e voce conserta o case certo em vez de espalhar.

(3) Pode-se levar o codigo do broadcast no mesmo modulo, mas com default 0 (desligado), e explicitamente como WORKAROUND, nunca como evidencia: proibido aceitar "o warning sumiu" como confirmacao, justamente por causa do rearme do fallback_timer em amdgpu_fence.c:232-234. O criterio de aceitacao passa a ser o contador, e o unico ganho funcional que vale medir e o comportamento com HSA_ENABLE_SDMA=1 (que hoje gira a 199% de CPU) — se o broadcast nao destravar isso, ele nao esta consertando nada, so silenciando o dmesg.

### [REFUTADA] P3 - Pre-carregar o SDMA0 duas vezes (testa "a primeira LOAD_IP_FW e perdida")
- REFUTADA. A proposta e bem pesquisada (nenhum simbolo inventado), mas o mecanismo esta na camada errada e colide com fatos medidos.

1) MECANISMO CONTRADIZ O SINTOMA MEDIDO. "LOAD_IP_FW perdida" = ucode do SDMA0 nao carregado = engine incapaz de executar QUALQUER pacote. Essa falha ja tem assinatura documentada nesta placa: "ring sdma0 test failed (-110)" no reload a quente. Em boot frio o ring test do sdma0 PASSA e o trabalho COMPLETA (amdgpu_fence_fallback so avisa sobre fence JA COMPLETA). Logo o ucode do SDMA0 esta provadamente carregado e rodando. O mecanismo preve engine morta; o sintoma e engine viva com IV perdido. Nao ha como as duas coisas serem a mesma.

2) REFUTACAO NO PROTOCOLO PSP. psp_cmd_submit_buf (amdgpu_psp.c:705) faz polling da fence do PSP; em timeout retorna -EINVAL, que sobe por psp_load_non_psp_fw -> psp_hw_init -> "Fatal error during GPU init". O boot passa, entao nenhum comando foi "engolido" no anel. E qualquer resp.status != 0 emite dev_warn "failed to load ucode SDMA0(0x1)". Grep em 30 dias de journal: 0 ocorrencias de "failed to load ucode" e 0 de "psp gfx command ... failed". Ou seja, o PSP ACKou o LOAD_IP_FW do SDMA0 com status 0. Para a hipotese sobreviver, o PSP teria que escrever a fence E reportar sucesso E nao fazer nada — epiciclo nao falsificavel.

3) NAO E O PRIMEIRO COMANDO. psp_hw_start ja submete comandos de anel antes de psp_load_non_psp_fw (bootloader loads + psp_tmr_load / SETUP_TMR; o "reserve 0x400000 ... for PSP TMR" aparece no log). Se falhassem, psp_hw_start retorna erro e o probe morre. Entao "PSP come o primeiro comando" ja esta morto; a proposta precisa estreitar para "come o primeiro LOAD_IP_FW especificamente", restricao ad hoc sem precedente citado.

4) NAO TOCA NA ASSIMETRIA REAL. Mesmo concedendo o mecanismo, carregar firmware duas vezes nao mexe em NADA do caminho de IV: client_id/src_id no amdgpu_irq_add_id, anel do IH (navi10_ih), nem TRAP_ENABLE — que e escrito por sdma_v5_0_set_trap_irq_state DEPOIS do hw_init, pelo driver, nao pelo PSP. O fato medido e que o IV do trap do SDMA0 nao chega ao amdgpu_irq_dispatch. Recarregar ucode nao e um caminho causal ate ai.

5) CHECAGEM DE SIMBOLOS (tudo existe, credito onde e devido): psp_load_non_psp_fw em amdgpu_psp.c:3050, psp_load_p2s_table chamado em :3064 imediatamente antes do for; psp_execute_ip_fw_load e nao-static (:2927); struct amdgpu_firmware_info tem .fw e .ucode_size (amdgpu_ucode.h:585-599); adev->firmware.ucode[] e indexado por AMDGPU_UCODE_ID (array[AMDGPU_UCODE_ID_MAXIMUM], :602); AMDGPU_UCODE_ID_CAP=0 (so SRIOV) e AMDGPU_UCODE_ID_SDMA0=1, entao SDMA0 realmente e a primeira entrada nao pulada por fw_load_skip_check nesta ASIC; e o load type aqui e mesmo AMDGPU_FW_LOAD_PSP (amdgpu_ucode.c:585-590 + amdgpu_device.c:2223, device 0x13FE -> AMD_APU_IS_CYAN_SKILLFISH2, amdgpu_fw_load_type default -1 e truthy). A premissa estrutural esta certa. So nao explica o sintoma.

6) DEFEITOS MENORES: o static + module_param() + MODULE_PARM_DESC no snippet estao DENTRO do corpo da funcao; a convencao (e os params bc250 que ja existem, gmc_v10_0.c:68-70) e escopo de arquivo. E falta gate por adev->pdev->device == BC250_PCI_DEVICE_ID.

7) CUSTO/RISCO vs INFORMACAO: 3 reboots + rebuild do modulo para testar uma hipotese que ja e incompativel com "engine completa o trabalho". E um duplo LOAD_IP_FW pode, no pior caso, travar o anel do PSP -> probe -110 -> GPU inutil no boot -> mais um reboot. Risco assimetrico para ganho informacional ~zero.

Nota: o READOUT do teste em si e ok — a contagem e deterministica (medi 2 em cada um dos 3 ultimos boots: 0, -1, -2), entao 0 vs 2 seria distinguivel. O problema nao e o teste, e a hipotese.
- correcao sugerida: Nao gaste reboot para perguntar "a carga se perdeu?". Ha duas versoes muito melhores, e uma delas e de graca.

(A) VERSAO GRATIS DA MESMA PERGUNTA, ZERO RISCO — se voce quer mesmo descartar a camada PSP, nao submeta nada a mais: apenas MEÇA. Depois do for em psp_load_non_psp_fw (amdgpu_psp.c:3114), imprima o retorno do PSP para as duas instancias:

  for (i = AMDGPU_UCODE_ID_SDMA0; i <= AMDGPU_UCODE_ID_SDMA1; i++)
      dev_info(adev->dev, "bc250: %s tmr_mc=%08x:%08x size=%u\n",
               amdgpu_ucode_name(i),
               adev->firmware.ucode[i].tmr_mc_addr_hi,
               adev->firmware.ucode[i].tmr_mc_addr_lo,
               adev->firmware.ucode[i].ucode_size);

psp_cmd_submit_buf grava resp.fw_addr_lo/hi de volta em ucode->tmr_mc_addr_*. Se o SDMA0 voltar 0/lixo e o SDMA1 voltar endereco sao, ai sim existe evidencia de carga ignorada e P3 ressuscita com base real. Se os dois voltarem sanos, a camada PSP esta encerrada definitivamente. Isso e printk puro, nao muda ordem nem estado, e pode PEGAR CARONA em qualquer outro reboot que voce ja for gastar.

(B) O TESTE QUE MERECE O REBOOT — a evidencia aponta para entrega de IV, nao para ucode. E existe um buraco real na evidencia atual: o dyndbg em amdgpu_irq.c so prova que nenhum IV foi REJEITADO como client_id/src_id desconhecido. Ele NAO prova que o IV do trap do SDMA0 nao chegou tagueado como um cliente VALIDO porem ERRADO (ex.: chegando como SOC15_IH_CLIENTID_SDMA1, ou com ring_id/vmid divergente), caso em que ele seria consumido silenciosamente pelo handler errado, produzindo exatamente zero linhas de "Invalid client_id" e ainda assim perdendo a fence do sdma0. Instrumente o decode, nao o dispatch: no amdgpu_ih_process / navi10_ih_decode_iv, logue por N iteracoes iniciais (contador limitado, ~200 entradas, para nao inundar) client_id, src_id, ring_id e vmid de TODO IV visto durante o init, e compare o IV de trap do SDMA1 (que funciona) com o que aparece — ou nao — para o SDMA0. Isso e leitura a partir do contexto do driver (permitido), custa 1 reboot, nao mexe em init de GPU, nao tem risco de wedge, e responde a pergunta binaria certa: "o IV do SDMA0 existe no anel e esta mal tagueado" vs "o IV nunca e gerado". Os dois desfechos podam metade da arvore de hipoteses; P3 no melhor caso poda um galho ja morto.

Se for rodar (B), embarque (A) junto no mesmo modulo — um reboot, duas respostas.

### [REFUTADA] P2 - Build de instrumentacao pura: o que a PSP responde para cada SDMA
- Os simbolos todos existem e o patch compila — nao e invencao. Verifiquei em /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1/drivers/gpu/drm/amd/amdgpu/: psp_execute_ip_fw_load em amdgpu_psp.c:2927 (usa acquire_psp_cmd_buf + psp_prep_load_ip_fw_cmd_buf + psp_cmd_submit_buf), psp_cmd_submit_buf faz "memcpy(&cmd->resp, &psp->cmd_buf_mem->resp, sizeof(struct psp_gfx_resp))" em amdgpu_psp.c:770, entao ler cmd->resp DEPOIS do submit e valido; amdgpu_ucode_name() existe (amdgpu_ucode.c:600); cmd->cmd.cmd_load_ip_fw.fw_type, resp.status, resp.fw_addr_lo/hi existem; ucode_prefix e instance estao em escopo em amdgpu_sdma_init_microcode; common_firmware_header tem crc32. Load type e mesmo PSP: pdev 0x13FE seta AMD_APU_IS_CYAN_SKILLFISH2 (amdgpu_device.c:2223), amdgpu_ucode_get_load_type retorna AMDGPU_FW_LOAD_PSP (amdgpu_ucode.c:585-590), e o log deste boot mostra "detected ip block number 3 <psp_v11_0_8>" e "reserve 0x400000 from 0xf6ff800000 for PSP TMR". Ate os CRCs esperados batem: extrai /lib/firmware/amdgpu/cyan_skillfish2_sdma{,1}.bin.zst e o campo hdr.crc32 e exatamente 0xf2f45029 e 0xdb3e0be6. Ou seja, quem escreveu conferiu.

Mesmo assim REFUTO, por tres motivos.

(1) ERRO DE FATO NA PREMISSA CENTRAL. A proposta afirma que resp.status != 0 "hoje seria engolido em silencio porque nao e SR-IOV". Falso. Em amdgpu_psp.c:773-786 o bloco "if (!skip_unsupport && (psp->cmd_buf_mem->resp.status || !timeout) && !ras_intr)" dispara DOIS dev_warn incondicionalmente: "failed to load ucode %s(0x%X)" com o nome do ucode (SDMA0) e "psp gfx command LOAD_IP_FW(0x%X) failed and response status is (0x%X)". O amdgpu_sriov_vf() so decide se RETORNA -EINVAL, nao se imprime. skip_unsupport tambem exige sriov. Conclusao: se a PSP tivesse devolvido status != 0 para o SDMA0, isso ja estaria no journal de todo boot. Rodei o grep no boot atual e nao ha nenhuma dessas linhas. Portanto "resp.status do SDMA0 != 0" ja esta REFUTADO com dado existente, custo zero reboots. Metade do sinal-que-confirma nasce morto.

(2) A SEGUNDA HUNK E 100% REDUNDANTE, EM DOBRO. (a) Os CRCs eu acabei de tirar do disco sem tocar no kernel — inclusive os dois blobs sao mesmo distintos (payload crc 0xfe02efe4 vs 0xd7c8b42b, ucode_ver 0x34 nos dois). (b) O driver JA imprime isso: psp_print_fw_hdr (amdgpu_psp.c:2858) e chamado para cada AMDGPU_UCODE_ID_SDMA0..7 imediatamente antes de psp_execute_ip_fw_load em psp_load_non_psp_fw, e amdgpu_ucode_print_sdma_hdr -> amdgpu_ucode_print_common_hdr ja faz DRM_DEBUG("crc32: 0x%08x") e ucode_version e feature_version. Basta dyndbg em amdgpu_ucode.c, sem build. Gastar linha de patch nisso e desperdicio.

(3) O UNICO BIT NOVO — fw_addr — TEM ALTA CHANCE DE SER INCONCLUSIVO, E A PROPOSTA NAO PREVE ESSE DESFECHO. Em toda a arvore, tmr_mc_addr_lo so e CONSUMIDO por VCN/UVD/VCE (vcn_v4_0.c, uvd_v7_0.c, vce_v4_0.c). Nenhum caminho de SDMA le esse campo. Nao ha evidencia de que a PSP preencha fw_addr para GFX_FW_TYPE_SDMA0/1; o normal e vir 0 para tudo que nao e VCN. Se os dois vierem 0x0 — desfecho provavel — a proposta nao confirma nem refuta nada, e o reboot rende zero. O criterio de refutacao exigido ("os dois com fw_addr distintos e nao-zero") assume que a PSP popula o campo, o que nao esta demonstrado.

E o mecanismo alegado contradiz um FATO MEDIDO. "Ucode nao aplicado" nao explica o sintoma: em boot frio o ring test do sdma0 PASSA. O ring test enfileira um pacote SDMA_OP_WRITE e le a memoria de volta — decodificar esse pacote e trabalho do microcodigo. Uma engine sem ucode aplicado nao completa ring test, nao copia buffer, e nao chega perto de "trabalho terminou, so a interrupcao se perdeu". Para salvar a hipotese seria preciso postular um ucode residual do boot da PS5 que faz copias perfeitas mas nunca levanta trap — uma afirmacao muito mais estreita e sem nenhum apoio, nao a que a proposta faz ("ucode nunca foi aplicado ... explica perfeitamente").

Zero risco de comportamento, sim. Mas o valor esperado da hunk 1 e baixo e o da hunk 2 e nulo, e um dos dois sinais de confirmacao ja esta refutado de graca.
- correcao sugerida: Da para salvar SE reescrever o alvo. O que nenhum check de userspace consegue dar, e que vale reboot, nao e o CRC do ARQUIVO nem o fw_addr: e o CRC da COPIA ENCENADA que a PSP realmente le. amdgpu_ucode_init_bo (amdgpu_ucode.c) copia cada ucode para o fw_pri_bo via amdgpu_ucode_init_single_fw, deixando ucode->kaddr (ponteiro linear kernel) e ucode->mc_addr (endereco que vai no comando). struct amdgpu_firmware_info tem os dois campos (amdgpu_ucode.h:589-600). Se o staging do SDMA0 estiver errado — dois entries apontando para o mesmo blob, tamanho errado, copia truncada — o arquivo em /lib/firmware fica perfeito e o CRC do header tambem, e mesmo assim a PSP carrega lixo. Esse e um modo de falha real e assimetrico que nenhuma das duas hunks propostas detecta.

Patch corrigido, uma hunk so, em psp_execute_ip_fw_load (amdgpu_psp.c:2927), DEPOIS do psp_cmd_submit_buf:

  if (ucode->ucode_id >= AMDGPU_UCODE_ID_SDMA0 &&
      ucode->ucode_id <= AMDGPU_UCODE_ID_SDMA1)
      dev_info(psp->adev->dev,
        "bc250-fwload: %s fw_type=%d size=%u mc=0x%llx kaddr=%p staged_crc=0x%08x file_crc=0x%08x ret=%d status=0x%X fw_addr=0x%08X%08X\n",
        amdgpu_ucode_name(ucode->ucode_id),
        cmd->cmd.cmd_load_ip_fw.fw_type, ucode->ucode_size,
        (unsigned long long)ucode->mc_addr, ucode->kaddr,
        ucode->kaddr ? crc32_le(~0, ucode->kaddr, ucode->ucode_size) ^ ~0u : 0,
        le32_to_cpu(((const struct common_firmware_header *)ucode->fw->data)->crc32),
        ret, cmd->resp.status,
        cmd->resp.fw_addr_hi, cmd->resp.fw_addr_lo);

(precisa de #include <linux/crc32.h>; nao ler MMIO, so memoria de sistema — respeita a restricao dura).

Mudancas em relacao a proposta original:
- JOGA FORA a hunk de amdgpu_sdma.c inteira. Redundante com psp_print_fw_hdr + dyndbg e com o que ja da pra ler do disco. Zero linhas de patch para isso.
- PARA de tratar resp.status como sinal novo: ja sabemos que e 0, pelo dev_warn ausente no journal atual. Mantem no print so como confirmacao barata, nao como criterio.
- fw_addr vira SECUNDARIO, com o desfecho "ambos 0" declarado de antemao como INCONCLUSIVO (nao como refutacao).
- staged_crc vira o criterio PRIMARIO. Criterio explicito, decidido antes do reboot:
    * staged_crc(SDMA0) != staged_crc(SDMA1) e ambos consistentes com blobs distintos, mc_addr distintos e alinhados por PAGE_SIZE, ucode_size igual (33536 esperado, header ucode_size_bytes dos dois blobs) => o staging esta certo, a PSP recebeu o blob certo, e a hipotese "ucode do SDMA0 nao foi aplicado" morre. P2 vira REFUTACAO limpa e util.
    * staged_crc iguais, ou SDMA0 com kaddr NULL, ou size zero => achou de verdade, e ai vale seguir.
- Bundlar com P3/P4 no mesmo build continua certo, e agora a hunk custa ~10 linhas em vez de dois arquivos.

Antes de queimar o reboot, rodar de graca: verificar que o initramfs (/boot/initramfs-linux-cachyos-bore-lto-bc250.img) carrega os mesmos dois blobs que /lib/firmware — se o initramfs tiver um sdma.bin velho, o CRC do header ja explica tudo sem patch nenhum.

## a53add560e3ea5bd8  (angulo: HARVEST, FUSIVEIS E PARTICIONAMENTO DO PS5)
### Achados
- **[lido-no-codigo]** O IP do SDMA neste board eh IP_VERSION(5,0,1), NAO (5,0,2). A briefing esta errada nesse ponto. 5,0,2 eh NAVI14 segundo o proprio comentario da AMD. Consequencia: sdma_v5_0_init_golden_registers cai no case correto e aplica golden_settings_sdma_cyan_skillfish. Se fosse mesmo 5,0,2 ele aplicaria golden_settings_sdma_5 + nv14 (settings de Navi14) e isso sozinho ja seria um bug -- entao vale registrar que essa pista nao existe.
  - evidencia: `/sys/class/drm/card1/device/ip_discovery/die/0/SDMA0/0/{major,minor,revision} = 5/0/1 (idem SDMA1). Blob cru: hw_id=42 e hw_id=43, ambos v=5.0.1. Comentario AMD: drivers/gpu/drm/amd/amdkfd/kfd_device.c:91 'case IP_VERSION(5, 0, 1):/* CYAN_SKILLFISH */' e :92 'case IP_VERSION(5, 0, 2):/* NAVI14 */'. Golden settings: drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c:267-271`
- **[lido-no-codigo]** NAO existe harvest de SDMA0 em lugar nenhum. Despejei o blob de discovery cru (debugfs, sem MMIO) e parseei: as entradas SDMA0 (hw_id=42) e SDMA1 (hw_id=43) tem o nibble de harvest = 0x0 e instance_number = 0, com base_address IDENTICOS (0x1260, 0xA000, 0x02402C00 -- ou seja, o bloco fica dentro do GC). A tabela HARVEST_INFO existe (offset 964, size 136, assinatura 0x56524148 valida) e esta VAZIA: todos os 32 slots com hw_id=0.
  - evidencia: `cp /sys/kernel/debug/dri/1/amdgpu_discovery + parse: 'HARVEST table sig=56524148 ver=0' sem nenhuma entrada; 'hw_id= 42 inst=0 nba=3 v=5.0.1 harv=0x0 addrs=[0x1260,0xa000,0x2402c00]' e identico para hw_id=43. Structs: drivers/gpu/drm/amd/include/discovery.h:355-369`
- **[lido-no-codigo]** Mais forte ainda: neste chip o driver NEM SEQUER LE qualquer informacao de harvest. amdgpu_discovery_harvest_ip tem um if que exige GC >= IP_VERSION(10,2,0) OU ihdr_ver > 2 para ler a harvest table; aqui GC=10.1.3 e ihdr version=2, entao cai no ramo legado, que so chama read_harvest_bit_per_ip para uma allowlist de 3 PCI IDs (0x731E/0x7340/0x7360). 0x13FE nao esta la. Resultado: nem read_harvest_bit_per_ip nem read_from_harvest_table rodam. Harvest/fusivel de discovery esta 100% ELIMINADO como causa.
  - evidencia: `drivers/gpu/drm/amd/amdgpu/amdgpu_discovery.c:1602-1617 (condicao + allowlist de device ids). ihdr version=2 lido do blob; GC=10.1.3 via sysfs ip_discovery.`
- **[lido-no-codigo]** O valor 'harvest=0x0' que aparece no sysfs ip_discovery NAO eh o bit cru do blob -- eh DERIVADO de adev->sdma.sdma_mask. Nao use ele como evidencia. (No blob cru o bit tambem eh 0, entao a conclusao coincide, mas por caminhos diferentes.)
  - evidencia: `amdgpu_discovery.c:1084-1113 amdgpu_discovery_get_harvest_info(): 'harvest = ((1 << inst) & adev->sdma.sdma_mask) == 0'; chamado em :1192-1193 para preencher ip_hw_instance->harvest exposto em :893`
- **[lido-no-codigo]** Bug real (provavelmente inerte aqui, mas registro): adev->sdma.sdma_mask fica = 0x1 com num_instances = 2. Motivo: as duas entradas de discovery (hw_id 42 e 43) tem instance_number = 0, e o codigo faz 'sdma_mask |= (1U << ip->instance_number)' para ambas -- ou seja, seta o bit 0 duas vezes. Nada em sdma_v5_0.c consulta sdma_mask, entao nao gera o sintoma; mas amdgpu_ip_map_init popula ip_map.dev_inst[SDMA0_HWIP] a partir dele, ficando [0]=0 e [1..]=-1.
  - evidencia: `amdgpu_discovery.c:1474-1486 (incremento de num_instances + or do mask); amdgpu_ip.c:82-95 amdgpu_ip_map_init; consumidores de sdma_mask: apenas aqua_vanjaram.c:535-540, soc_v1_0.c:830, sdma_v7_1.c:748 -- nenhum no caminho gfx10/sdma_v5_0`
- **[lido-no-codigo]** nv_reg_base_init NAO EXISTE mais nesta arvore. O caminho de base de registrador para o 13FE eh amdgpu_discovery_reg_base_init (porque 0x13FE seta AMD_APU_IS_CYAN_SKILLFISH2). cyan_skillfish_reg_base_init() so roda para os device ids CS 'nao-2' e nem eh usado aqui. E ele mapeia reg_offset[SDMA0_HWIP] e [SDMA1_HWIP] ambos para GC_BASE -- simetrico, sem assimetria.
  - evidencia: `grep 'static int nv_reg_base_init' drivers/gpu/drm/amd/amdgpu/nv.c => vazio. amdgpu_device.c:2219-2223 (13FE => AMD_APU_IS_CYAN_SKILLFISH2); amdgpu_discovery.c:2887-2896 (ramo CS2 chama amdgpu_discovery_reg_base_init); cyan_skillfish_reg_init.c:48-49`
- **[lido-no-codigo]** ACHADO PRINCIPAL, e ele CONTRADIZ a briefing: a afirmacao 'o IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch' NAO esta provada. amdgpu_irq_dispatch nao imprime NADA quando o dispatch da certo -- as quatro mensagens dev_dbg so existem nos caminhos de rejeicao. Um IV que chega, encontra client 8 registrado, encontra src 224 registrado, e eh entregue a sdma_v5_0_process_trap_irq produz silencio absoluto em amdgpu_irq.c. O dyndbg 'file amdgpu_irq.c +p' nao cobre isso.
  - evidencia: `amdgpu_irq.c:497-525. Note tambem que a briefing lista 3 mensagens mas existe uma quarta em :522 ('Unregistered interrupt src_id: %d of client_id:%d') que aparentemente nao foi checada.`
- **[lido-no-codigo]** E existe um dreno SILENCIOSO logo depois: sdma_v5_0_process_trap_irq faz switch(entry->client_id) SEM default, e dentro switch(entry->ring_id) tambem SEM default. entry->ring_id eh um campo de 8 bits. Se o trap do SDMA0 chegar com ring_id fora de 0..3 -- ou com ring_id 1/2/3 -- a funcao retorna 0 sem chamar amdgpu_fence_process e sem imprimir nada. A fence fica sem sinalizar ate o fallback de 500ms. Isso reproduz o sintoma medido EXATAMENTE, incluindo a ausencia total de log.
  - evidencia: `sdma_v5_0.c:1694-1739 (switch sem default nos dois niveis); decodificacao do ring_id: amdgpu_ih.c:282 'entry->ring_id = (dw[0] >> 16) & 0xff'; o unico print do handler eh DRM_DEBUG em sdma_v5_0.c:1698, que fica em OUTRO arquivo -- fora do filtro dyndbg usado`
- **[lido-no-codigo]** SEGUNDO ACHADO, tambem contradiz a briefing: 'nao esta parado num anel que ninguem le' esta invertido. adev->irq.ih1.ring_size=0 e ih2.ring_size=0 sao decisoes de SOFTWARE que fazem o driver PULAR esses aneis em todo lugar -- ele nunca os configura E NUNCA OS DESLIGA no hardware. navi10_ih_toggle_interrupts e navi10_ih_irq_init iteram sobre {ih, ih1, ih2} com 'if (ih[i]->ring_size)'. Logo, o que o firmware do PS5 deixou em IH_RB_CNTL_RING1/RING2 (base, enable) permanece intacto sob Linux.
  - evidencia: `navi10_ih.c:580-581 (ring_size=0); navi10_ih.c:198-206 toggle_interrupts com guarda 'if (ih[i]->ring_size)'; navi10_ih.c:319-325 irq_init com a mesma guarda; navi10_ih.c:62-86 init_register_offset so preenche os regs de RING1/RING2 se ring_size != 0`
- **[lido-no-codigo]** E o que decide para QUAL anel de IH cada cliente vai eh uma tabela indexada em hardware, IH_CLIENT_CFG_INDEX/IH_CLIENT_CFG_DATA, com campo RING_ID[21:20], VF_RB_SELECT[23:22] e OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID[24]. O amdgpu NUNCA escreve essa tabela em OSSSYS 5.x -- grep na arvore inteira: as unicas escritas de client cfg estao em psp_v3_1.c (Vega) e ih_v6_0/v6_1/v7_0.c (regIH_RING1_CLIENT_CFG_*, outro registrador, outra geracao). Igualmente nunca escritos: IH_CID_REMAP_INDEX/DATA (remapeamento de client id), IH_INT_DROP_CNTL + INT_DROP_MATCH_VALUE0/1 + MATCH_MASK0/1 (filtro de descarte por client_id/source_id/vf_id/context_id em hardware) e IH_STORM_CLIENT_LIST_CNTL.
  - evidencia: `osssys_5_0_0_offset.h:290-294 (mmIH_CLIENT_CFG/INDEX/DATA), :304-313 (mmIH_INT_DROP_CNTL, MATCH_VALUE0/1, MATCH_MASK0/1), :210 (mmIH_STORM_CLIENT_LIST_CNTL), :296-299 (mmIH_CID_REMAP_INDEX/DATA); campos em osssys_5_0_0_sh_mask.h:1137-1149 e :1180-1194. grep -rn 'INT_DROP|STORM_CLIENT|IH_CLIENT_CFG' drivers/gpu/drm/amd/amdgpu/ => zero hits em navi10_ih.c`
- **[lido-no-codigo]** Reforco: force_update_wptr_for_self_int(), a UNICA funcao de navi10_ih.c que mexeria em IH_RB_CNTL_RING1/RING2 fora da guarda de ring_size, retorna imediatamente porque exige OSSSYS >= IP_VERSION(5,0,3) e aqui OSSSYS = 5.0.1. Ou seja: nesta placa, NENHUMA linha do amdgpu escreve qualquer registrador de roteamento/filtragem de cliente do IH. Tudo o que o boot ROM do PS5 programou sobrevive intacto.
  - evidencia: `navi10_ih.c:110-111 'if (amdgpu_ip_version(adev, OSSSYS_HWIP, 0) < IP_VERSION(5, 0, 3)) return;'; OSSSYS=5.0.1 via /sys/class/drm/card1/device/ip_discovery/die/0/OSSSYS/0/`
- **[lido-no-codigo]** PRECEDENTE DIRETO para 'firmware do PS5 deixou registrador de runtime em estado de console': o duggasco/bc250-40cu-unlock mostra que o corte de 40->24 CU no BC-250 NAO esta em fusivel nem na discovery -- esta em dois registradores de runtime (CC_GC_SHADER_ARRAY_CONFIG 0xfff80000 e SPI_PG_ENABLE_STATIC_WGP_MASK 0x7) que o firmware escreve e o amdgpu nunca reescreve. Citacao do repo: 'the harvested CUs have power, clocks, and matching CGTS config -- they were disabled by firmware policy, not silicon defects'. Eu CONFIRMEI o lado da discovery na minha maquina: a GC table do blob diz gc_num_se=2, sa_per_se=2, wgp0_per_sa=3, wgp1_per_sa=2 => 2*2*5 = 20 WGP = 40 CU. A discovery declara 40; o registrador de runtime gateia para 24.
  - evidencia: `https://github.com/duggasco/bc250-40cu-unlock (docs/technical-report.md); parse local da GC table @offset 864 do amdgpu_discovery: campos [0x2,0x3,0x2,0x8,...,0x2(sa_per_se)] contra o layout de drivers/gpu/drm/amd/include/discovery.h:176-198`
- **[inferido]** Assimetria analoga ja documentada no mesmo silicio: o gfx1013 tem a fila compute-only quebrada e o Mesa 25.1 detecta gfx1013 e desabilita a compute queue por padrao. Ou seja, ja ha precedente de 'o segundo caminho de fila de hardware nao entrega' neste chip, contornado no userspace em vez de diagnosticado. Isso eh leitura de doc de terceiro, nao do codigo desta arvore.
  - evidencia: `https://elektricm.github.io/amd-bc250-docs/drivers/radv/ e notas de release do Mesa 25.1`
- **[inferido]** Pesquisa na comunidade: NINGUEM diagnosticou a causa raiz. O que existe eh so contorno. ROCm issue #6313 (BC-250 freeze) mostra 'ring sdma0 timeout' / 'Starting sdma0 ring reset' mas o relator nao propoe patch nem analise, e o assignee nao respondeu com diagnostico. Nao consegui achar indexado nem o repositorio 'DryhoppedIPA/bc250-gfx1013-fix' nem o patch do neoney 'clr-prefer-sdma1' -- as buscas so devolveram os docs do elektricm e o duggasco. O consenso publico eh HSA_ENABLE_SDMA=0.
  - evidencia: `https://github.com/ROCm/ROCm/issues/6313 (fetch: 'the reporter does not propose any kernel patches or technical root-cause analysis'); buscas por neoney/DryhoppedIPA sem resultado`
- **[especulacao]** Sobre o console: no PS5 o Oberon roda com particionamento entre o SO do console e o jogo. Uma engine SDMA reservada ao lado 'seguro'/OS teria suas interrupcoes roteadas para outro anel de IH ou para outra funcao (VF), programado pelo boot ROM em IH_CLIENT_CFG_DATA.RING_ID / VF_RB_SELECT / OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID, ou filtrado em IH_INT_DROP_*. Nao tenho NENHUMA evidencia direta disso. Eh hipotese que casa com todos os fatos medidos e que eh barata de testar. Nao trate como fato ate o dump do experimento P1.
  - evidencia: `hipotese; ancorada nos achados sobre navi10_ih.c:110-111, :198-206, :319-325, :580-581 e na ausencia de qualquer escrita de IH_CLIENT_CFG/CID_REMAP/INT_DROP na arvore`
- **[lido-no-codigo]** Detalhe que fecha o quadro do sintoma em userspace: sdma_v5_0_process_trap_irq SEMPRE retorna 0, entao amdgpu_irq_dispatch nunca marca handled=true e todo IV de SDMA vai tambem para amdgpu_amdkfd_interrupt. As filas de USUARIO do KFD nao usam amdgpu_fence, entao o fallback timer de 500ms nao as cobre -- por isso HSA_ENABLE_SDMA=1 gira para sempre (199% CPU) enquanto o ring do kernel 'so' fica lento. Isso eh consistente tanto com IV perdido quanto com IV chegando e sendo dropado no switch.
  - evidencia: `amdgpu_irq.c:513-529 (handled/amdgpu_amdkfd_interrupt); sdma_v5_0.c:1739 'return 0'; amdgpu.h:279 '#define AMDGPU_FENCE_JIFFIES_TIMEOUT (HZ / 2)'; amdgpu_fence.c:203-206 e :278-287`

### Propostas
- **P1 -- Um unico build que eh ao mesmo tempo instrumentacao decisiva e patch candidato (fazer primeiro)** — 1 reboot(s), risco baixo
  - mecanismo: Ataca as duas contradicoes que encontrei na briefing. (a) Se o IV do SDMA0 CHEGA mas morre no switch sem default de sdma_v5_0_process_trap_irq (sdma_v5_0.c:1694-1739), o arm default corrige o bug NO MESMO BOOT e o log diz qual ring_id era. Nenhuma mensagem existente do driver poderia ter revelado isso: amdgpu_irq.c so fala nos caminhos de rejeicao, e o unico print do handler eh um DRM_DEBUG noutro arquivo, fora do filtro dyndbg usado ate agora. (b) Se o IV realmente nao chega, o dump one-shot do estado de roteamento do IH -- tabela IH_CLIENT_CFG (RING_ID por cliente), IH_CID_REMAP, filtro IH_INT_DROP_*, storm list, e o estado real de RING1/RING2 -- mostra qual registrador o firmware do PS5 deixou fora do padrao. O amdgpu nao escreve NENHUM desses nesta placa (navi10_ih.c:110-111 mata a unica funcao que chegaria perto), entao tudo ali eh estado herdado do boot ROM do console. Esse eh exatamente o mesmo mecanismo do corte de 40->24 CU documentado pelo duggasco: politica de firmware em registrador de runtime, nao fusivel.
  - mudanca: Dois arquivos, um build de modulo.

(A) drivers/gpu/drm/amd/amdgpu/sdma_v5_0.c -- em sdma_v5_0_process_trap_irq, logo apos o drm_WARN_ON_ONCE:

  static int bc250_sdma_iv_trace = 64;
  module_param(bc250_sdma_iv_trace, int, 0644);

  if (bc250_sdma_iv_trace > 0) {
          bc250_sdma_iv_trace--;
          dev_info(adev->dev,
            "SDMA IV: cid=%u sid=%u ring_id=%u vmid=%u vmid_src=%u pasid=%u node=%u d=%08x %08x %08x %08x\n",
            entry->client_id, entry->src_id, entry->ring_id, entry->vmid,
            entry->vmid_src, entry->pasid, entry->node_id,
            entry->src_data[0], entry->src_data[1],
            entry->src_data[2], entry->src_data[3]);
  }

e, dentro de cada switch(entry->ring_id), trocar o silencio por um arm que loga E sinaliza:

  default:
          dev_warn_once(adev->dev, "SDMA%d trap ring_id=%u inesperado, sinalizando ring gfx\n", N, entry->ring_id);
          amdgpu_fence_process(&adev->sdma.instance[N].ring);
          break;

(N = 0 no case SOC15_IH_CLIENTID_SDMA0, N = 1 no case SDMA1). Tambem trocar os cases 1/2/3 vazios ("XXX compute"/"XXX page queue") pelo mesmo tratamento: essas filas nao sao criadas por este driver, entao um amdgpu_fence_process extra ali eh idempotente e inofensivo. E acrescentar um default no switch(entry->client_id) com dev_warn_once.

(B) drivers/gpu/drm/amd/amdgpu/navi10_ih.c -- funcao nova chamada no fim de navi10_ih_irq_init, antes do return 0:

  static void bc250_dump_ih_routing(struct amdgpu_device *adev)
  {
    static bool done; u32 v; int i;
    if (done || adev->pdev->device != 0x13FE) return;
    done = true;
    v = RREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG);
    dev_info(adev->dev, "IH_CLIENT_CFG=%08x total=%u\n", v, v & IH_CLIENT_CFG__TOTAL_CLIENT_NUM_MASK);
    for (i = 0; i < 32; i++) {
      WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_INDEX, i);
      v = RREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_DATA);
      dev_info(adev->dev, "IH_CLIENT_CFG[%02d]=%08x ring=%u vfrb=%u ovr=%u type=%u iface=%u credit=%05x\n", i, v,
        (v & IH_CLIENT_CFG_DATA__RING_ID_MASK) >> IH_CLIENT_CFG_DATA__RING_ID__SHIFT,
        (v & IH_CLIENT_CFG_DATA__VF_RB_SELECT_MASK) >> IH_CLIENT_CFG_DATA__VF_RB_SELECT__SHIFT,
        (v & IH_CLIENT_CFG_DATA__OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID_MASK) >> IH_CLIENT_CFG_DATA__OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID__SHIFT,
        (v & IH_CLIENT_CFG_DATA__CLIENT_TYPE_MASK) >> IH_CLIENT_CFG_DATA__CLIENT_TYPE__SHIFT,
        (v & IH_CLIENT_CFG_DATA__INTERFACE_TYPE_MASK) >> IH_CLIENT_CFG_DATA__INTERFACE_TYPE__SHIFT,
        v & IH_CLIENT_CFG_DATA__CREDIT_RETURN_ADDR_MASK);
    }
    for (i = 0; i < 32; i++) {
      WREG32_SOC15(OSSSYS, 0, mmIH_CID_REMAP_INDEX, i);
      dev_info(adev->dev, "IH_CID_REMAP[%02d]=%08x\n", i, RREG32_SOC15(OSSSYS, 0, mmIH_CID_REMAP_DATA));
    }
    dev_info(adev->dev, "IH_INT_DROP_CNTL=%08x v0=%08x v1=%08x m0=%08x m1=%08x\n",
      RREG32_SOC15(OSSSYS,0,mmIH_INT_DROP_CNTL), RREG32_SOC15(OSSSYS,0,mmIH_INT_DROP_MATCH_VALUE0),
      RREG32_SOC15(OSSSYS,0,mmIH_INT_DROP_MATCH_VALUE1), RREG32_SOC15(OSSSYS,0,mmIH_INT_DROP_MATCH_MASK0),
      RREG32_SOC15(OSSSYS,0,mmIH_INT_DROP_MATCH_MASK1));
    dev_info(adev->dev, "IH_STORM=%08x FLOOD_CNTL=%08x RB0F=%08x RB1F=%08x RB2F=%08x CREDIT_ERR=%08x\n",
      RREG32_SOC15(OSSSYS,0,mmIH_STORM_CLIENT_LIST_CNTL), RREG32_SOC15(OSSSYS,0,mmIH_INT_FLOOD_CNTL),
      RREG32_SOC15(OSSSYS,0,mmIH_RB0_INT_FLOOD_STATUS), RREG32_SOC15(OSSSYS,0,mmIH_RB1_INT_FLOOD_STATUS),
      RREG32_SOC15(OSSSYS,0,mmIH_RB2_INT_FLOOD_STATUS), RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CREDIT_ERROR));
    dev_info(adev->dev, "RING1 cntl=%08x base=%08x wptr=%08x rptr=%08x | RING2 cntl=%08x base=%08x wptr=%08x rptr=%08x\n",
      RREG32_SOC15(OSSSYS,0,mmIH_RB_CNTL_RING1), RREG32_SOC15(OSSSYS,0,mmIH_RB_BASE_RING1),
      RREG32_SOC15(OSSSYS,0,mmIH_RB_WPTR_RING1), RREG32_SOC15(OSSSYS,0,mmIH_RB_RPTR_RING1),
      RREG32_SOC15(OSSSYS,0,mmIH_RB_CNTL_RING2), RREG32_SOC15(OSSSYS,0,mmIH_RB_BASE_RING2),
      RREG32_SOC15(OSSSYS,0,mmIH_RB_WPTR_RING2), RREG32_SOC15(OSSSYS,0,mmIH_RB_RPTR_RING2));
  }

navi10_ih.c ja inclui oss/osssys_5_0_0_offset.h e _sh_mask.h (linhas 29-30), entao nao falta header. Nesse boot, TIRAR amdgpu.bc250_skip_sdma0=1 da cmdline para o SDMA0 ser realmente exercitado.
  - teste: Um boot frio, ler o dmesg.

SINAL A -- aparecem linhas 'SDMA IV: cid=8 ...' e/ou 'trap ring_id=N inesperado': o IV CHEGAVA e estava sendo dropado no switch. A briefing esta errada e o patch ja eh o fix. Confirmacao: 'Fence fallback timer expired on ring sdma0' some do boot inteiro. Anotar o ring_id observado.
SINAL B -- ZERO linhas com cid=8, mas linhas com cid=9 aparecem para o sdma1: o IV realmente nao chega. Ir para o dump. Se alguma entrada de IH_CLIENT_CFG tiver ring=1/2, ou ovr=1, ou vfrb!=0 enquanto as demais estao zeradas, achamos o culpado -> P2. Se IH_INT_DROP_CNTL tiver bit0 (INT_DROP_EN) setado -> P3. Se RING1/RING2 vierem com cntl de RB_ENABLE e base nao-zero, isso ja prova por si que o firmware deixou aneis vivos que o Linux ignora.
SINAL C -- zero cid=8 E dump todo limpo (client cfg uniforme, drop desabilitado, ring1/2 zerados): o trap nao esta sendo gerado pela engine, e nenhum mecanismo deste angulo explica. Ir para P4.

Risco a declarar: o dump escreve em IH_CLIENT_CFG_INDEX e IH_CID_REMAP_INDEX (janelas indexadas de OSSSYS). Sao escritas de contexto de driver com a GPU viva, nao leitura crua de MMIO do userspace -- dentro da restricao. Se quiser risco zero no primeiro boot, corte os dois loops indexados e mantenha so os regs diretos (DROP/STORM/RING1/RING2); o sinal fica mais fraco mas a parte (A) continua valendo integralmente.
- **P2 -- Forcar RING_ID=0 (e zerar overwrite/VF select) na tabela IH_CLIENT_CFG** — 2 reboot(s), risco medio
  - mecanismo: O amdgpu neste chip so le o anel 0 do IH e deixa ih1/ih2 com ring_size=0, o que significa que ele nem configura NEM DESLIGA os aneis 1 e 2 no hardware (navi10_ih.c:198-206 e :319-325 usam a guarda 'if (ih[i]->ring_size)'). Se o boot ROM do PS5 programou a entrada de cliente do SDMA0 com RING_ID=1 ou 2 -- plausivel se essa engine pertencia ao lado OS do console -- o IV eh escrito num buffer que o Linux nunca le e nunca desabilitou. Zero mensagem em qualquer lugar do driver, que eh exatamente o que se observa. Como o driver assume que TUDO chega no anel 0, forcar RING_ID=0 em todas as entradas eh semanticamente correto para este driver, nao apenas um hack pro SDMA0.
  - mudanca: Em navi10_ih.c, no fim de navi10_ih_irq_init, guardado por adev->pdev->device == 0x13FE e por um module_param novo bc250_ih_force_ring0 (default 0):

  for (i = 0; i < 32; i++) {
          WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_INDEX, i);
          v = RREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_DATA);
          n = v & ~(IH_CLIENT_CFG_DATA__RING_ID_MASK |
                    IH_CLIENT_CFG_DATA__VF_RB_SELECT_MASK |
                    IH_CLIENT_CFG_DATA__OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID_MASK);
          if (n != v) {
                  WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_INDEX, i);
                  WREG32_SOC15(OSSSYS, 0, mmIH_CLIENT_CFG_DATA, n);
                  dev_info(adev->dev, "IH_CLIENT_CFG[%02d] %08x -> %08x\n", i, v, n);
          }
  }

Se o dump de P1 identificar UMA entrada especifica divergente, prefira reescrever so ela ('if (i != idx) continue;') para nao mexer no que ja funciona. Atencao: o indice dessa tabela eh o ordinal de porta do cliente no IH, nao necessariamente igual ao SOC15_IH_CLIENTID (SDMA0=8); por isso o criterio de identificacao eh 'a entrada que difere de todas as outras', nao 'a entrada 8'.
  - teste: Boot com bc250_ih_force_ring0=1 e SEM bc250_skip_sdma0. Sucesso: as linhas 'SDMA IV: cid=8' passam a aparecer e 'Fence fallback timer expired on ring sdma0' desaparece do boot. Refutacao: o dmesg mostra 'IH_CLIENT_CFG[..] X -> Y' (prova de que o registrador foi mesmo alterado) e o fallback do sdma0 continua identico -- entao roteamento de anel nao era a causa. Contraste obrigatorio: mesmo build com bc250_ih_force_ring0=0, para ter as duas condicoes no mesmo binario. Pela regra n>=3, 3 boots por condicao antes de declarar qualquer coisa, e reportar os 3.
- **P3 -- Limpar o filtro de descarte de interrupcao em hardware (IH_INT_DROP_*) e o storm client list** — 2 reboot(s), risco medio
  - mecanismo: OSSSYS 5.0 tem um filtro que casa client_id/source_id/vf_id/context_id e DESCARTA o IV antes de escrever no anel (IH_INT_DROP_CNTL bit0 INT_DROP_EN, com CLIENT_ID_MATCH_EN/SOURCE_ID_MATCH_EN e os pares MATCH_VALUE/MATCH_MASK -- osssys_5_0_0_sh_mask.h:1180-1194). O amdgpu nunca escreve nada disso em geracao 5.0. Se o console usava esse filtro para suprimir os traps de uma engine reservada, o resultado eh precisamente 'a engine termina o trabalho e o host nunca ve nada', sem log em lugar nenhum, porque o descarte acontece ANTES do anel. IH_STORM_CLIENT_LIST_CNTL eh o mesmo tipo de risco: cliente marcado como storm client pode ter interrupcoes suprimidas por rate limit.
  - mudanca: Mesmo ponto (fim de navi10_ih_irq_init, guarda 0x13FE), module_param separado bc250_ih_clear_filters:

  WREG32_SOC15(OSSSYS, 0, mmIH_INT_DROP_CNTL, 0);
  WREG32_SOC15(OSSSYS, 0, mmIH_INT_DROP_MATCH_MASK0, 0);
  WREG32_SOC15(OSSSYS, 0, mmIH_INT_DROP_MATCH_MASK1, 0);
  WREG32_SOC15(OSSSYS, 0, mmIH_STORM_CLIENT_LIST_CNTL, 0);

So faz sentido se o dump de P1 mostrar INT_DROP_EN=1 ou bits setados no storm list. Se o dump ja vier zerado, PULE -- nao gaste reboot. Colocar no MESMO build de P2 com param independente, para que P2 e P3 custem apenas boots, nao compilacoes novas.
  - teste: Condicional ao dump de P1. Se aplicavel: boot com bc250_ih_clear_filters=1 vs =0, sem bc250_skip_sdma0, 3 boots cada. Sinal de sucesso: aparecimento das linhas 'SDMA IV: cid=8' e sumico do fallback do sdma0. Sinal de refutacao: filtro comprovadamente zerado (reler no proprio dump apos a escrita) e sintoma inalterado.
- **P4 -- Se o trap realmente nao existe: deteccao de conclusao sem IRQ. Isto eh CONTORNO, nao fix, e nao atende o criterio pedido** — 2 reboot(s), risco baixo
  - mecanismo: Se P1/P2/P3 refutarem tudo, sobra a hipotese de que a engine nao emite o trap. Ai nao ha correcao de roteamento possivel e a saida barata eh polling. O SDMA ja escreve o RPTR de volta em memoria (mmSDMA0_GFX_RB_RPTR_ADDR_LO/HI, sdma_v5_0.c:742-744) e amdgpu_fence_process ja le a seq da fence por writeback -- a informacao ESTA na memoria, so falta alguem olhar mais cedo. Hoje quem olha eh o fallback_timer, com periodo fixo de 500 ms (amdgpu.h:279).
  - mudanca: Tornar o intervalo de fallback por-ring: acrescentar 'unsigned long fallback_interval' em struct amdgpu_fence_driver, inicializar com AMDGPU_FENCE_JIFFIES_TIMEOUT junto do timer_setup em amdgpu_fence.c:479, usar esse campo em amdgpu_fence_schedule_fallback (amdgpu_fence.c:205-206), e em sdma_v5_0_sw_init setar, so para instance[0] e so no 13FE, algo como usecs_to_jiffies(200) ou 1 jiffy. Custo: um mod_timer por submissao no sdma0, que ja eh pago hoje; muda so a frequencia de expiracao.

SER EXPLICITO SOBRE O LIMITE, porque o usuario pediu fix e nao contorno: isto conserta APENAS o ring de kernel do sdma0 (blits do TTM, updates de PTE). NAO conserta as filas de usuario do KFD, que nao usam amdgpu_fence e por isso giram a 199% de CPU. Com P4 sozinho o bc250_skip_sdma0=1 NAO pode ser removido, que era justamente o criterio de sucesso. So considerar se P1-P3 falharem, e nesse caso a investigacao migra para o handler de interrupcao do KFD.
  - teste: Boot sem bc250_skip_sdma0, com o intervalo curto. Medir: (1) contagem de 'Fence fallback timer expired on ring sdma0' por boot -- deve SUBIR (mais expiracoes, cada uma util) com a latencia caindo; (2) tempo de uma copia grande host->device com HSA_ENABLE_SDMA=0 como proxy de throughput do TTM; (3) confirmar que HSA_ENABLE_SDMA=1 CONTINUA girando -- se continuar, esta comprovado que P4 nao atende o objetivo e o resultado deve ser reportado como tal. 3 repeticoes por condicao, reportar as 3.
- **P5 -- Higiene de custo zero, pega carona em qualquer build: sdma_mask coerente** — 0 reboot(s), risco baixo
  - mecanismo: Nao explica o IRQ perdido e eu nao estou dizendo que explica. Mas hoje adev->sdma.sdma_mask = 0x1 com num_instances = 2, porque as duas entradas de discovery declaram instance_number = 0 e o codigo faz 'sdma_mask |= (1U << ip->instance_number)' duas vezes no bit 0. Isso deixa ip_map.dev_inst[SDMA0_HWIP][1] = -1 e faz o campo 'harvest' do sysfs mentir sobre o SDMA1 (ele eh derivado do mask, amdgpu_discovery.c:1107). Voce VAI depurar olhando esses valores em algum momento; melhor que nao mintam.
  - mudanca: Em amdgpu_discovery.c, no ramo CHIP_CYAN_SKILLFISH/CS2 (por volta de :2887-2896), depois de amdgpu_discovery_reg_base_init:

  if (adev->sdma.num_instances && adev->sdma.sdma_mask == 1)
          adev->sdma.sdma_mask = (1U << adev->sdma.num_instances) - 1;

Zero efeito funcional em sdma_v5_0.c -- nenhum consumidor de sdma_mask esta no caminho gfx10 (so aqua_vanjaram.c, soc_v1_0.c e sdma_v7_1.c) -- apenas alinha os metadados.
  - teste: Sem reboot dedicado: pegar carona em qualquer boot de P1/P2/P3 e conferir que /sys/class/drm/card1/device/ip_discovery/die/0/SDMA1/0/harvest continua 0x0 e que nada regride (ring test do sdma1 passando, nenhum erro novo no dmesg). Se algo quebrar, o mask era consumido em algum lugar que eu nao achei -- reverter na hora.

### [REFUTADA] P1 - dyndbg no firmware_loader para provar qual blob foi para qual instancia do SDMA
- REFUTADA por redundancia total: o resultado do experimento ja e conhecido com certeza, sem reboot, sem build e sem MMIO. Eu o resolvi durante esta revisao.

1) MECANICA: esta correta, nao inventou simbolo. Verifiquei na arvore /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1:
   - drivers/base/firmware_loader/main.c:811 fw_log_firmware_info() -> sha256(fw->data, fw->size) + dev_dbg("Loaded FW: %s, sha256: ...") em :816.
   - main.c:569 dev_dbg("Loading firmware from %s") esta dentro de fw_get_filesystem_firmware() (comeca em :489), entao o filtro "func" opcional tambem e valido.
   - Kernel rodando tem CONFIG_FW_LOADER_DEBUG=y, CONFIG_CRYPTO_SHA256=y, CONFIG_DYNAMIC_DEBUG=y. firmware_loader e builtin, entao dyndbg= puro na cmdline funciona.
   - O sha256 logado e o do conteudo DESCOMPACTADO (o log e chamado depois do assign_fw, main.c:911), e os blobs no disco sao .zst. Os dois hashes esperados batem exatamente com o descompactado: cyan_skillfish2_sdma.bin -> 15d0d362..., cyan_skillfish2_sdma1.bin -> bd1c0b0f... Confirmado.
   Ou seja: o experimento roda e imprime o que a proposta diz. O problema nao e esse.

2) O RESULTADO JA ESTA DETERMINADO, SEM GASTAR NADA:
   a) Nome do arquivo: amdgpu_sdma_init_microcode() (amdgpu_sdma.c) monta o nome com um if/else literal: instance==0 -> "amdgpu/%s.bin", senao "amdgpu/%s%d.bin". Nao ha tabela, nem indexacao de array, nem nada que possa trocar 0 por 1. sdma_v5_0_init_microcode() chama em loop sequencial i=0,1. A troca de blobs entre instancias e estruturalmente impossivel.
   b) O prefixo vem de amdgpu_ucode_legacy_naming(SDMA0_HWIP). IP 5.0.1 -> "cyan_skillfish2_sdma"; IP 5.0.2 -> "navi14_sdma".
   c) LI O IP VERSION REAL DESTA MAQUINA, via sysfs (sem MMIO, sem reboot): /sys/class/drm/card1/device/ip_discovery/die/0/SDMA0/0/ -> major=5 minor=0 revision=1, e SDMA1 idem. Logo o prefixo e cyan_skillfish2_sdma. O ramo navi14 e inalcancavel.
   d) CONFIRMACAO INDEPENDENTE do blob realmente carregado NESTE boot: /sys/kernel/debug/dri/0000:01:00.0/amdgpu_firmware_info -> "SDMA0 feature version: 50, firmware version: 0x00000034" e "SDMA1 ... 0x00000034". Parseei os headers: cyan_skillfish2_sdma{,1}.bin tem ucode_version=0x34; navi14_sdma{,1}.bin tem 0x29. Familia cyan confirmada nas duas instancias.
   O ramo "SINAL QUE CONFIRMA UM BUG DE FIRMWARE" e inatingivel: navi14 esta excluido (c+d), ordem invertida e impossivel (a), "apenas UM arquivo" e impossivel (o loop falharia o probe inteiro), sha diferente e excluido pelos hashes do disco. O experimento so pode sair no ramo "REFUTA". Custo em bits de informacao: zero.

3) NAO EXPLICA A ASSIMETRIA, E NAO PODE: o prefixo e compartilhado pelas duas instancias. Blob errado seria errado para AS DUAS engines, e sdma1 funciona. O unico cenario assimetrico (0 recebe o blob de 1) esta morto pelo item 2a.

4) FATO DA LISTA QUE ESTA ERRADO (dizendo em voz alta, como pedido): a lista afirma "IP_VERSION(5,0,2)" para o SDMA deste chip. Nesta maquina o SDMA e 5.0.1, medido no ip_discovery via sysfs. 5.0.2 e navi14. Isso importava: amdgpu_ucode_legacy_naming mapeia 5,0,2 -> "navi14_sdma", e navi14_sdma.bin.zst e navi14_sdma1.bin.zst ESTAO instalados em /lib/firmware/amdgpu neste host. Se o fato estivesse certo, o driver teria carregado silenciosamente a familia errada e o P1 seria excelente. Nao esta certo, e o debugfs (0x34) confirma que a familia carregada e a cyan.

Observacao de brinde para os proximos experimentos: no mesmo debugfs, SOS e ASD reportam feature/firmware version 0 - nao ha firmware de PSP carregado nesta placa. Qualquer proposta P2/P3/P4 que assuma "o caminho PSP" precisa provar primeiro que load_type nao e AMDGPU_FW_LOAD_DIRECT, senao ja nasce refutada tambem.
- correcao sugerida: Nao gastar slot de cmdline nem reboot com o P1. O angulo "blob errado" ja morreu com os dados acima (ip_discovery=5.0.1, debugfs SDMA0/SDMA1=0x34, if/else literal no nome, sha256 dos blobs do disco batendo).

Se sobrar duvida sobre o unico furo restante - o initramfs poder conter uma copia diferente dos blobs cyan - feche OFFLINE, sem reboot:
  sudo lsinitcpio -x /boot/initramfs-linux-cachyos-bore.img -- 'usr/lib/firmware/amdgpu/cyan_skillfish2_sdma*'  (ou bsdcpio) e sha256sum no que sair, comparando com 15d0d362... / bd1c0b0f...
Mesmo isso e quase supérfluo: o 0x34 do debugfs ja exclui a familia navi14.

Se ainda assim quiser log em runtime, empilhe APENAS
  dyndbg="func fw_log_firmware_info +p"
nunca o "+p" no arquivo inteiro - o file-wide liga tambem "Loading firmware from" para todo blob do sistema (microcode, wifi, bt, ~20 blobs de GPU) e nao adiciona um bit sequer. E que isso nao desloque nenhum experimento real da fila.

O experimento de firmware que VALERIA o reboot e o inverso do P1: em vez de auditar a contabilidade, perturbar causalmente. Trocar uma linha em amdgpu_sdma_init_microcode() para a instancia 0 pedir "cyan_skillfish2_sdma1.bin" (e/ou a 1 pedir o .bin), rebuildar so o modulo amdgpu (~5 min) e ver para onde o "Fence fallback timer expired" migra:
  - se o fallback continuar em sdma0 -> o conteudo do blob e irrelevante, a assimetria e de hardware/IRQ routing, e todo o eixo firmware morre de vez;
  - se o fallback migrar para sdma1 -> o blob e causal, e ai sim ha algo a perseguir.
Os dois blobs diferem em 274 dos 33792 bytes (mesmo tamanho, mesmo ucode_version 0x34, mesmo feature 8192, CRC diferente: 0xf2f45029 vs 0xdb3e0be6), entao a troca e uma perturbacao real e assimetrica por construcao. Um build de modulo + um reboot, e devolve uma resposta causal em vez de um recibo.

### [REFUTADA] Bug real, mas com a polaridade invertida: o patch não muda nenhuma escrita dirigida à SDMA0
- CONFERÊNCIA DE CÓDIGO (tudo existe, nada inventado):
- sdma_v5_0.c:662-665 é literalmente `inst_mask = GENMASK(adev->sdma.num_instances - 1, 0);` seguido de `sdma_v5_0_gfx_stop(adev, 1 << inst_mask);`. Confirmado.
- for_each_inst está em amdgpu.h:1485 e é `for (i = ffs(inst_mask); i-- != 0; i = ffs(inst_mask & BIT_MASK_UPPER(i + 1)))`. Com máscara 8: ffs(8)=4, i-- → corpo roda uma vez com i=3, depois ffs(8 & ~0xF)=0 encerra. Aritmética da proposta confirmada.
- sdma_v5_0_get_reg_offset (linha 218) só soma SDMA1_REG_OFFSET (0x600) / SDMA1_HYP_DEC_REG_OFFSET (0x20) quando `instance == 1`. i=3 cai no else → endereços da INSTÂNCIA 0. Confirmado.
- É bug genuíno e único deste arquivo: sdma_v5_2.c:513 no sítio análogo escreve `sdma_v5_2_gfx_stop(adev, inst_mask);` — sem o shift. O patch alinha v5_0 com v5_2. Grep de `1 << inst_mask` na árvore inteira do amdgpu retorna só essa linha.

ISSO CONTRADIZ UM FATO MEDIDO, e digo em voz alta: o fato "o código do driver é SIMÉTRICO entre instância 0 e 1, verificado linha a linha" está ERRADO. A auditoria linha-a-linha passou batido pela linha 664. A proposta está certa nesse ponto.

MAS A PROPOSTA MORRE EM DOIS PONTOS INDEPENDENTES:

1) A ASSIMETRIA APONTA PARA O LADO ERRADO. Com o bug, gfx_stop limpa RB_ENABLE/IB_ENABLE da instância 0 (acidentalmente correto, via aliasing) e PULA a instância 1. A vítima do bug é a SDMA1, não a SDMA0 — o código como está é mais atencioso com a 0, não menos. Se esse bug gerasse um defeito instância-específico, a engine quebrada seria a SDMA1. Medido: a SDMA1 é a limpa, em todo boot, e a SDMA0 é a que perde IRQ. A proposta não só "não explica" o fallback timer — ela prediz a polaridade oposta.

2) FATAL PARA A ALEGAÇÃO DO RELOAD A QUENTE: o patch não altera UMA ÚNICA escrita dirigida à SDMA0. Antes: RB_ENABLE/IB_ENABLE da instância 0 zerados. Depois: RB_ENABLE/IB_ENABLE da instância 0 zerados, bit a bit idênticos, mais os da instância 1. O estado de teardown da SDMA0 no rmmod é literalmente o mesmo com e sem o patch. Ou seja, a proposta se vende como "candidato direto para o estado sujo que faz o reload falhar" sendo que o reload falha em `ring sdma0 test failed (-110)` e o patch não toca no que a SDMA0 deixa para trás. Qualquer efeito precisa passar por contaminação cruzada da SDMA1 — que é uma SEGUNDA hipótese, não declarada e não testada.

3) O MECANISMO ESTÁ IMPRECISO. "deixa a SDMA1 rodando com o RB apontando para memória que vai ser liberada" é falso como escrito: logo depois do gfx_stop, o mesmo sdma_v5_0_enable(false) roda um `for (i = 0; i < num_instances; i++)` CORRETO que seta F32_CNTL.HALT=1 nas DUAS instâncias. A SDMA1 fica halted, não rodando. O resíduo é só o bit RB_ENABLE/IB_ENABLE (e WPTR_POLL) ficarem setados, e isso só vira perigo no próximo enable(true) — que em sdma_v5_0_start desalta as duas ANTES do gfx_resume reprogramar a instância 1. Essa é uma hipótese defensável, mas é outra hipótese.

4) O TESTE NÃO DISCRIMINA. Empacotado com a proposta 2, no mesmo build e mesmo reboot, o sinal de passa/falha é compartilhado — eles próprios admitem. O dev_info proposto imprime i=3 antes e i=0,i=1 depois: isso prova que o compilador funciona, não que a hipótese está certa. O desfecho mais provável (reload da BC-250 falha por N motivos além deste) é zero informação por um reboot do usuário.

Detalhe de contexto que colhi e que joga A FAVOR da versão forte da hipótese, para ser justo: nv_need_reset_on_init() (nv.c:542) retorna false imediatamente para AMD_IS_APU. Então NÃO há reset de ASIC no probe da BC-250 e o estado de registrador da SDMA1 realmente sobrevive ao rmmod/modprobe. A hipótese "RB stale da SDMA1" é fisicamente possível. Ela só não é o que a proposta escreveu, e não é sobre a SDMA0.
- correcao sugerida: Não matar o patch — matar a alegação causal. Reclassificar de "correção para o SDMA0" para "correção de higiene, custo zero, alinha v5_0 com v5_2", e aplicar as três regras:

(a) NÃO gastar reboot com ele. Ele entra de carona em qualquer build que já vá acontecer por outro motivo. Se o par 1+2 fizer o reload passar, o crédito é da proposta 2 por padrão, porque a 1 comprovadamente não altera nenhuma escrita à SDMA0 — a 1 só ganha crédito se o experimento (b) confirmar antes.

(b) O experimento que realmente discrimina (custo zero em reboots, é só print, e leitura de MMIO de dentro do driver é permitida — a proibição é userspace): no topo de sdma_v5_0_start, ANTES de qualquer escrita, um dev_info lendo mmSDMA0_GFX_RB_CNTL das duas instâncias e imprimindo o bit RB_ENABLE e o RB_BASE/RB_BASE_HI de cada uma. Predições falsificáveis:
  - boot frio: RB_ENABLE=0 nas duas (reset default) → consistente com o ring test da sdma0 passar;
  - modprobe após rmmod, SEM o patch: RB_ENABLE=0 na inst 0 e RB_ENABLE=1 na inst 1, com RB_BASE apontando para o BO da sessão anterior.
Se o reload a quente mostrar RB_ENABLE=0 também na instância 1, a história do estado sujo morre inteira e o patch é pura higiene, sem nenhuma relação com o -110. Esse print custa o mesmo reboot que já se ia gastar com a proposta 2.

(c) Corrigir o texto do mecanismo antes de qualquer commit message: a SDMA1 NÃO fica "rodando" — fica halted por F32_CNTL.HALT, com RB_ENABLE/WPTR_POLL residuais que só armam no próximo unhalt. E deixar registrado que o bug prejudica a instância 1, não a 0, para não contaminar a próxima rodada de hipóteses sobre o fallback timer da sdma0.

Também vale corrigir o fato medido na base de conhecimento: "o código do driver é simétrico entre instância 0 e 1, verificado linha a linha" precisa virar "simétrico exceto sdma_v5_0.c:664, que é assimétrico a FAVOR da instância 0" — senão a próxima auditoria repete o mesmo erro.

### [REFUTADA] Backportar o soft reset do sdma_v5_2 para o sdma_v5_0_start (devolve o reload a quente e converte reboots em modprobes)
- CHECAGEM DE CÓDIGO (passou, isso não é a refutação): todos os símbolos existem e batem linha a linha. sdma_v5_0_soft_reset é stub vazio em sdma_v5_0.c:1528-1533; sdma_v5_0_soft_reset_engine existe em 1330-1352 e faz RMW em mmGRBM_SOFT_RESET via RREG32_SOC15(GC,0,...) com grbm_soft_reset <<= instance_id; sdma_v5_2.c:790-801 e 841-845 são exatamente como descrito; sdma_v5_0_start está em 927-958 sem reset nenhum. Conferi gc_10_1_0_sh_mask.h:5742-5743: SOFT_RESET_SDMA0__SHIFT=0x17 e SOFT_RESET_SDMA1__SHIFT=0x18 são adjacentes, então o "<< instance_id" acerta o bit certo. Zero invenção de símbolo. A proposta é mecanicamente executável.

REFUTAÇÃO 1 — O MECANISMO É DESMENTIDO PELO PRÓPRIO ARQUIVO. sdma_v5_0.c atende IP_VERSION(5,0,0), (5,0,1), (5,0,2) e (5,0,3) (amdgpu_discovery.c:2092-2095), ou seja navi10/navi14/navi12 e o cyan skillfish compartilham ESTE start() sem soft reset. rmmod/modprobe amdgpu em navi10 é rotina e funciona. Se "faltar o soft reset em v5_0_start" fosse causa suficiente do -110 no reload, TODA navi10 do mundo falharia no segundo modprobe. Não falham. Logo a ausência do reset não é a causa do -110 no BC-250 — é apenas uma diferença cosmética entre dois arquivos, elevada a hipótese causal por analogia. Isso é cargo cult, não mecanismo. A causa muito mais provável é a que já é conhecida deste alvo: o Oberon do PS5 não tem caminho de reinit (PSP/SMU/boot ROM one-shot, sem BACO/mode1/mode2), e o estado de boot ROM é consumível uma vez só. Um GRBM soft reset da SDMA não devolve nada disso.

REFUTAÇÃO 2 — A ASSIMETRIA ALEGADA NO RELOAD NÃO EXISTE COMO EVIDÊNCIA. A proposta afirma "depois de um ciclo de uso a engine 0 não volta". Mas sdma_v5_0_gfx_resume (linha ~848) é um loop que faz `r = sdma_v5_0_gfx_resume_instance(adev,i,false); if (r) return r;` — retorna na PRIMEIRA instância que falha. A sdma1 NUNCA chega a ser ring-testada no reload. "ring sdma0 test failed" significa apenas "a instância 0 é a primeira do loop", não "a 1 passou". Não há um único dado dizendo que o reload é assimétrico. E a mudança proposta é um for sobre num_instances — perfeitamente simétrica. Pelo critério 2, ela não explica nem a assimetria real (fallback timer só na sdma0) nem a assimetria que ela mesma inventa.

REFUTAÇÃO 3 — CUSTO ASSIMÉTRICO: A PATCH MEXE NO ÚNICO CAMINHO QUE HOJE FUNCIONA. sdma_v5_0_start é o único start; é chamado por sdma_v5_0_hw_init (1461-1468) e por sdma_v5_0_resume. Inserir o reset ali muda TAMBÉM o boot frio, que hoje é o estado bom conhecido (ring test passa; só o IRQ some). Pior: confirmei que no BC-250 firmware.load_type é PSP, não DIRECT — amdgpu_ucode.c:585-590, CHIP_CYAN_SKILLFISH com AMD_APU_IS_CYAN_SKILLFISH2 e amdgpu_fw_load_type=-1 (default, amdgpu_drv.c:165, truthy) cai em AMDGPU_FW_LOAD_PSP. Então o branch DIRECT/load_microcode de sdma_v5_0_start é PULADO, e o soft reset proposto seria a primeira coisa a tocar a engine depois do ucode carregado pelo PSP, sem nenhum caminho de recarga dentro do start. Em v5_2 isso empiricamente sobrevive, mas em v5_2 não há um boot ROM de PS5 no meio. Aposta-se o único init funcional contra uma hipótese já refutada pelo ponto 1. Downside assimétrico num alvo onde cada tentativa custa reboot. E de quebra vira confounder permanente de todo experimento futuro sobre o fallback timer.

REFUTAÇÃO 4 — O TESTE NÃO DISCRIMINA. Critério "não aparece 'ring sdma0 test failed (-110)'" é ausência de string, e ausência de string é atingível por falha ANTES do SDMA (psp/gmc/gfx abortando hw_init mais cedo), o que seria lido como sucesso. Além disso não há grupo de controle: o fato "reload falha" está registrado com n=1, violando a própria regra de n>=3 do usuário. Sem baseline de 3 ciclos rmmod/modprobe não-patcheados na MESMA sessão, um modprobe que passe não prova causalidade — prova que naquele boot deu certo.

REFUTAÇÃO 5 — O PAYOFF É PARCIALMENTE ILUSÓRIO. O sintoma em estudo é de BOOT FRIO ("em TODO boot frio, antes de qualquer carga"). Mesmo que o reload volte, um modprobe com soft reset injetado produz um estado de init diferente do deixado pelo boot ROM. Se o fallback timer não reproduzir depois do modprobe, o loop rápido não serve para estudar o bug — e descobrir isso custa, adivinha, um reboot. A proposta não tem critério para essa validação.

DEFEITO MENOR (não é a refutação, mas mostra a cópia irrefletida): o trecho inserido usa `ip_block` sem declarar `struct amdgpu_ip_block *ip_block;` nos locais de sdma_v5_0_start, e faz amdgpu_device_ip_get_ip_block só para extrair adev — que já está em mãos — introduzindo um retorno -EINVAL novo e gratuito no caminho de init.
- correcao sugerida: Não gastar reboot com isto na forma proposta. Se quiser salvar a ideia, ela precisa virar experimento barato, opt-in e com controle:

1) PRIMEIRO, DE GRAÇA, SEM REBOOT: capturar o dmesg COMPLETO de 3 ciclos rmmod/modprobe no boot atual (o fato "reload falha" está com n=1). O que interessa é o que vem ANTES do "ring sdma0 test failed": psp, gmc, ih e gfx passaram? O ring test da GFX passou? Se a GFX também falhar ou o PSP reclamar, a hipótese SDMA-local morre na hora e nenhum patch é necessário para saber. Isso sozinho pode encerrar a discussão sem custo.

2) SE E SÓ SE o SDMA for comprovadamente a primeira falha: gatear a mudança atrás de module param, nunca incondicional. Ex.: `bc250_sdma_soft_reset` default 0, e em sdma_v5_0_start `if (bc250_sdma_soft_reset) for (i=0;i<adev->sdma.num_instances;i++) { sdma_v5_0_soft_reset_engine(adev,i); udelay(50); }` — chamando o helper direto, sem a cerimônia do amdgpu_device_ip_get_ip_block e sem o -EINVAL novo. Assim o boot frio fica byte-idêntico ao de hoje por padrão, o baseline é preservado, e o experimento é ativado com `modprobe amdgpu bc250_sdma_soft_reset=1` — zero reboots extras e zero confounder nos experimentos do fallback timer.

3) Adicionar um param separado para reset por instância (bitmask), já que só assim o teste consegue distinguir "reset da 0 resolve" de "reset da 1 resolve" de "precisa das duas" — é a única versão do experimento que produz informação sobre assimetria.

4) Critério de sucesso POSITIVO, não ausência de string: modprobe retorna 0, aparecem os ring tests OK de sdma0 E sdma1, /dev/dri/card* volta, e um glxinfo/vulkaninfo leve responde. n=3 no mesmo boot, alternando param=0 (deve falhar) e param=1 (deve passar) — sem esse par alternado não há controle.

5) Antes de declarar "agora reboot virou modprobe": verificar que o "Fence fallback timer expired on ring sdma0" REAPARECE após um modprobe bem-sucedido. Se não reaparecer, o loop rápido não reproduz o bug alvo e o ganho alegado não existe.

### [REFUTADA] Boot instrumentado unico para separar (a) IV nunca chega / (b) IV descartado / (c) janela do TRAP_ENABLE
- O INSTRUMENTO e honesto, a ARVORE DE DECISAO nao. Nada aqui contradiz os fatos medidos e nao ha simbolo inventado — conferi linha a linha em /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1/: sdma_v5_0.c:1688 e mesmo o WREG32 de set_trap_irq_state, :1698 e mesmo o topo do corpo de process_trap_irq, :1707-1720 sao mesmo os cases vazios, :809 e mesmo `temp &= 0xFF0FFF`, :838 e mesmo `return amdgpu_ring_test_helper(ring);`, e sdma_v5_0_gfx_resume_instance(adev, int i, bool restore) tem mesmo o parametro `i` (compila). amdgpu_device.c:3162 (amdgpu_ttm_set_buffer_funcs_status true, dentro de ip_init) e :4753 (amdgpu_fence_driver_hw_init, que so ai chama amdgpu_irq_get) confirmam que a janela (c) existe de fato na ordem do codigo, e ela e assimetrica por construcao (buffer_funcs_ring = sdma0 apenas). Ate ai a proposta e boa. O que a mata:

1) O MUNDO (b) NAO EXISTE, E O "CONSERTO" DELE E DESTRUTIVO. amdgpu_irq_dispatch (amdgpu_irq.c) faz `if (!handled) amdgpu_amdkfd_interrupt(adev, entry.iv_entry);`, e handled so vira true quando src->funcs->process retorna >0. sdma_v5_0_process_trap_irq retorna 0 SEMPRE (sdma_v5_0.c:1739). Logo TODO IV de SDMA, inclusive ring_id!=0, e repassado ao KFD. Os cases `/* XXX compute */` vazios nao sao descarte silencioso, sao o comportamento correto: aquelas filas sao do KFD e sinalizam por evento do KFD, nao por amdgpu_fence_process. A "correcao e roteamento no switch" proposta chamaria amdgpu_fence_process(&adev->sdma.instance[0].ring) a partir de um IV de fila de compute — sinalizaria fences do ring do KERNEL que nao completaram. Isso e corrupcao, nao conserto. Um terco da arvore de decisao aponta para um patch nocivo.

2) O DISCRIMINADOR DE (c) E LOGICAMENTE FURADO. O warning nao sai no emit. Em amdgpu_fence.c o fallback_timer e armado por amdgpu_fence_enable_signaling (linha 846-847) e rearmado dentro de amdgpu_fence_process (232-234), com AMDGPU_FENCE_JIFFIES_TIMEOUT = HZ/2 (amdgpu.h:279). O timestamp do "Fence fallback timer expired" e >=500 ms DEPOIS de alguem ter esperado a fence, nao o instante do emit. Entao uma fence emitida 100 ms antes do TRAP_ENABLE imprime o warning 400 ms DEPOIS da linha trap_irq_state — e a regra escrita ("se TODAS vierem ANTES") classificaria isso como "nao e a janela". A direcao positiva e valida, a negativa e falso-negativo garantido. E exatamente a regra que a proposta vende como o desfecho de custo zero.

3) O RATELIMIT COMPARTILHADO ENVENENA O TESTE DE (a). dev_info_ratelimited tem estado ESTATICO POR CALLSITE, e aqui client=8 e client=9 saem do mesmo callsite. A terceira regra ("nunca aparece client=8 enquanto aparecem client=9") e literalmente o artefato que um ratelimiter compartilhado fabrica quando a sdma1 esta movimentada. Ausencia de client=8 vira nao-evidencia. Ainda: sdma0 e o buffer_funcs_ring, ou seja carrega TODO blit de TTM — e o printk sai de contexto de hard IRQ (navi10_ih chama amdgpu_ih_process direto do handler), perturbando justamente a temporizacao da corrida que se quer medir.

4) O PREMIO ANUNCIADO CONTRADIZ FATO MEDIDO. "Se (c): o caminho de IRQ do SDMA0 esta SAO e bc250_skip_sdma0 pode ser removido sem mais nada." bc250_skip_sdma0 vive em amdkfd/kfd_device_queue_manager.c:165 e existe por causa do travamento medido em USERSPACE com HSA_ENABLE_SDMA=1 (199% de CPU, copia completa e nunca sinaliza), horas depois do TRAP_ENABLE ja estar ligado. Uma explicacao de janela de boot nao diz nada sobre isso e nao autoriza remover o contorno. Seguir a regra como escrita levaria o usuario a arrancar um workaround que a evidencia diz ser load-bearing.

5) O "BONUS" ESTA ERRADO DUAS VEZES E NAO CUSTA REBOOT NENHUM. (i) golden_settings_sdma_cyan_skillfish so e programado sob IP_VERSION(5,0,1) (sdma_v5_0.c, case em ~:266). O fato medido diz que este chip e IP_VERSION(5,0,2), que cai em golden_settings_sdma_5 + nv14 — onde mmSDMA0_UTCL1_PAGE recebe 0x00ffffff/0x000c5c00, com USE_BC = 0. O "bit 22 do golden cyan" nunca e escrito nesta placa. (ii) Mesmo se fosse: SDMA0_UTCL1_PAGE__USE_BC_MASK = 0x00400000 (gc_10_1_0_sh_mask.h:658) e 0xFF0FFF = 0x00FF0FFF preserva os bits 16-23. USE_BC sobrevive a mascara por construcao — resposta estatica, zero reboots. E a tabela golden e simetrica SDMA0/SDMA1 de qualquer jeito, entao nunca poderia explicar a assimetria. Alem disso o print 3 le mmSDMA0_CNTL no fim de gfx_resume_instance, ou seja ANTES de amdgpu_fence_driver_hw_init: TRAP_ENABLE vai sair 0 nas duas instancias em todo boot, o que e exatamente a coluna que ele se propunha a comparar.

Resumindo: 3 das 4 regras de leitura estao erradas, uma delas prescreve um patch que corrompe fences, e a conclusao vendida como "custo zero" ja e contradita por medida existente. Isso nao merece um reboot na forma atual.
- correcao sugerida: Da pra salvar, e fica ate melhor, com o mesmo unico reboot. Mudancas:

A) MATE O PRINT 3. Ele le CNTL antes de TRAP_ENABLE existir e a parte de UTCL1_PAGE ja esta respondida estaticamente (USE_BC=0 via golden_settings_sdma_5, preservado pela mascara). Se ainda quiser a comparacao de simetria, mova UM print para logo depois do laco de amdgpu_fence_driver_hw_init (amdgpu_device.c:4753), imprimindo mmSDMA0_CNTL das duas instancias — ali o bit TRAP_ENABLE finalmente significa alguma coisa.

B) TROQUE O RATELIMIT COMPARTILHADO POR CONTADOR POR INSTANCIA. Dentro de process_trap_irq, dois callsites separados (um em cada case de client_id) ou um contador estatico por client_id limitando as primeiras ~64 linhas de cada. Assim "nao apareceu client=8" vira evidencia de verdade em vez de artefato do supressor.

C) ADICIONE O DADO QUE FALTA — O MARCO DE SEQ NO MOMENTO DO ENABLE. Este e o conserto real do discriminador de (c). Em amdgpu_fence_driver_hw_init, logo antes/depois do amdgpu_irq_get de cada ring, um dev_info com ring->name, ring->fence_drv.sync_seq e atomic_read(&ring->fence_drv.last_seq). E em amdgpu_fence_fallback (amdgpu_fence.c:278) acrescente seq/last_seq ao dev_warn existente. Com isso a classificacao deixa de depender de ordem de timestamp (que carrega o offset de HZ/2 e mente): fallback com seq <= o marco = artefato da janela, PROVADO; fallback com seq > o marco = perda real de IV depois do enable, PROVADO. Custa dois prints e elimina o falso-negativo.

D) REESCREVA A REGRA DE (b). Se aparecer client=8 com ring_id!=0, a leitura correta e "traps de fila do KFD chegam normalmente e seguem para amdgpu_amdkfd_interrupt pelo fallthrough de handled==false" — ou seja, o caminho de IV da SDMA0 esta vivo. Nao e para mexer no switch. Se a intencao e investigar as filas de KFD, o print tem que ir em kfd_interrupt.c / kfd_int_process_v10 (ou equivalente neste tree), nao no handler do amdgpu.

E) PROIBIDO CONCLUIR "REMOVER bc250_skip_sdma0" DESTE BOOT. Qualquer que seja o desfecho, o travamento de userspace com HSA_ENABLE_SDMA=1 e pos-enable e nao e tocado por este experimento. A remocao do contorno exige um segundo teste, deliberado, com o roteiro de n>=3 repeticoes.

F) CHECKLIST OPERACIONAL ANTES DE REBOOTAR (senao o reboot e desperdicado): amdgpu e MODULO e o mkinitcpio desta maquina usa os hooks autodetect+modconf. Confirme se amdgpu.ko.zst esta dentro da initramfs em uso; se estiver, so copiar para /lib/modules nao basta — tem que regerar a initramfs, ou o boot carrega o modulo velho e nenhum dos prints aparece. Antes de reiniciar, valide tambem que o modulo novo tem os simbolos: `modinfo` no .ko e um `strings amdgpu.ko | grep "sdma trap IV"`.

### [SOBREVIVEU] P2 -- Forcar RING_ID=0 na tabela IH_CLIENT_CFG (navi10_ih)
- SOBREVIVE aos quatro ataques, mas o teste como escrito e fraco.

1) Nao contradiz nenhum fato medido.

2) Explica a assimetria. SOC15_IH_CLIENTID_SDMA0 = 0x08 e SDMA1 = 0x09 sao clientes DISTINTOS (drivers/gpu/drm/amd/include/soc15_ih_clientid.h:41-42), logo entradas distintas na tabela. Uma divergencia por entrada e causa legitimamente assimetrica. Isso mata a maioria das propostas e esta nao morre aqui.

3) Nenhum simbolo inventado. Conferido em /home/gabriwar/linux-cachyos-build/linux-cachyos-bore/src/cachyos-7.0.12-1:
   - navi10_ih.c inclui exatamente oss/osssys_5_0_0_offset.h e _sh_mask.h (linhas 29-30).
   - mmIH_CLIENT_CFG_INDEX 0x0188 / mmIH_CLIENT_CFG_DATA 0x0189, ambos BASE_IDX 0 (osssys_5_0_0_offset.h:292-295). SOC15_REG_OFFSET(OSSSYS,0,...) resolve.
   - IH_CLIENT_CFG_DATA__RING_ID_MASK 0x00300000, __VF_RB_SELECT_MASK 0x00C00000, __OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID_MASK 0x01000000 (osssys_5_0_0_sh_mask.h:1146-1148). Todos existem.
   - A premissa do buraco esta confirmada em codigo: navi10_ih_sw_init faz literalmente adev->irq.ih1.ring_size = 0 e ih2.ring_size = 0 (navi10_ih.c:580-581), e tanto navi10_ih_toggle_interrupts (:203) quanto o loop de enable em navi10_ih_irq_init (:353) usam if (ih[i]->ring_size). Os aneis 1 e 2 realmente nao sao nem configurados nem desligados pelo Linux.
   - Semantica de RING_ID confirmada por psp_v3_1_reroute_ih (psp_v3_1.c:155-183): comentario "Change IH ring for VMC" + RING_ID=1, que e o mecanismo conhecido de mandar retry fault pro ih1. RING_ID = seletor de RB do IH, nao campo do cookie.
   - Respeita a restricao dura: tudo e RREG32/WREG32 de dentro do driver, zero MMIO de userspace.

4) AQUI ESTA O PROBLEMA, e por isso as correcoes sao obrigatorias:

   a) O criterio de refutacao e falsificavel pelo lado errado. O print "IH_CLIENT_CFG[..] X -> Y" imprime o valor PRETENDIDO, nao o valor efetivo. Se a tabela for read-only ou trancada por PSP, a escrita some em silencio, o print sai igual, o fallback continua, e voce conclui "roteamento nao era a causa" -- conclusao falsa. Agravante: em TODA a arvore amdgpu nao existe UMA escrita MMIO direta em mmIH_CLIENT_CFG_INDEX/DATA. O unico lugar que mexe nessa tabela e psp_v3_1.c, e mesmo la a AMD vai por mailbox do PSP (GFX_CTRL_CMD_ID_GBR_IH_SET), nao por MMIO. Nao prova que e RO, mas e um sinal forte o suficiente pra exigir read-back.

   b) Se a tabela ja estiver toda com RING_ID=0 (plausivel, ja que todos os outros clientes funcionam), o codigo nao imprime nada e nao faz nada. Reboot gasto num resultado indistinguivel de "apliquei e nao adiantou".

   c) O loop escreve as em indices 0..31 as cegas sem respeitar IH_CLIENT_CFG.TOTAL_CLIENT_NUM (5 bits, osssys_5_0_0_sh_mask.h:1133). Mexer em slot indefinido numa placa onde reload a quente ja falha com -110 nao vale o risco.

   d) "no fim de navi10_ih_irq_init" e depois de navi10_ih_toggle_interrupts(adev, true). Reprogramar roteamento com o IH ja vivo e corrida gratuita.

AVISO OBRIGATORIO -- um dos "fatos" e inferencia, nao medicao. O item "O IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch" NAO esta provado pelo dyndbg. Li amdgpu_irq_dispatch (amdgpu_irq.c): ela nao emite print NENHUM no caminho de sucesso -- so nos ramos Invalid client_id / Invalid src_id / Unregistered. E sdma_v5_0_process_trap_irq (sdma_v5_0.c) faz switch (entry->client_id) e depois switch (entry->ring_id), onde case 1/2/3 sao "/* XXX compute */" com break vazio. Ou seja: um IV com client_id=8, src_id de trap e ring_id != 0 seria despachado com sucesso, cairia num break vazio, nao chamaria amdgpu_fence_process, e produziria ZERO mensagem em qualquer lugar -- exatamente o sintoma observado. O dyndbg so eliminou descarte por id desconhecido; nao eliminou descarte silencioso dentro do handler. P2 nao e a unica explicacao do "silencio total". (Detalhe curioso: limpar OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID conserta essa variante tambem, por acidente -- mas o criterio de sucesso de P2 nao distingue as duas.)
- correcao sugerida: Manter a proposta, mas exigir estas 5 mudancas antes de gastar reboot:

1. FUNDIR P1 EM P2. Dump incondicional ANTES de modificar, sempre, mesmo com bc250_ih_force_ring0=0. Um reboot passa a produzir dump + resultado em vez de dois reboots:

   n_clients = RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG) & IH_CLIENT_CFG__TOTAL_CLIENT_NUM_MASK;
   dev_info(adev->dev, "IH_CLIENT_CFG TOTAL_CLIENT_NUM=%u\n", n_clients);
   for (i = 0; i < n_clients && i < 32; i++) {
           WREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_INDEX,i);
           v = RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_DATA);
           dev_info(adev->dev, "IH_CLIENT_CFG[%02d]=%08x ring=%u vf=%u ovr=%u type=%u\n",
                    i, v,
                    (v & IH_CLIENT_CFG_DATA__RING_ID_MASK) >> IH_CLIENT_CFG_DATA__RING_ID__SHIFT,
                    (v & IH_CLIENT_CFG_DATA__VF_RB_SELECT_MASK) >> IH_CLIENT_CFG_DATA__VF_RB_SELECT__SHIFT,
                    (v & IH_CLIENT_CFG_DATA__OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID_MASK) >> IH_CLIENT_CFG_DATA__OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID__SHIFT,
                    (v & IH_CLIENT_CFG_DATA__CLIENT_TYPE_MASK) >> IH_CLIENT_CFG_DATA__CLIENT_TYPE__SHIFT);
   }

2. LIMITAR ao TOTAL_CLIENT_NUM lido do hardware (ja acima). Nada de 0..31 as cegas.

3. READ-BACK OBRIGATORIO depois de cada escrita, e imprimir o valor LIDO, nao o pretendido:

   WREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_INDEX,i);
   WREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_DATA,n);
   WREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_INDEX,i);
   rb = RREG32_SOC15(OSSSYS,0,mmIH_CLIENT_CFG_DATA);
   dev_info(adev->dev, "IH_CLIENT_CFG[%02d] %08x -> want %08x got %08x %s\n",
            i, v, n, rb, rb == n ? "OK" : "WRITE-IGNORED");

   Sem isso o experimento nao consegue distinguir "roteamento nao era a causa" de "a tabela nem aceitou minha escrita". Se sair WRITE-IGNORED, a via MMIO direta esta morta e a alternativa e o caminho PSP (GFX_CTRL_CMD_ID_GBR_IH_SET), como em psp_v3_1_reroute_ih.

4. MOVER o bloco pra ANTES de navi10_ih_toggle_interrupts(adev, true) em navi10_ih_irq_init (ou seja, logo depois do loop de navi10_ih_enable_ring, ~navi10_ih.c:359), nao no fim da funcao. Nao reprogramar roteamento com o IH ja ligado.

5. DISCRIMINADOR DA HIPOTESE CONCORRENTE, no mesmo boot e sem custo extra. Adicionar em sdma_v5_0_process_trap_irq, na PRIMEIRA linha, antes de qualquer switch:

   dev_info_ratelimited(adev->dev, "SDMA IV: cid=%u src=%u ring_id=%u vmid=%u\n",
                        entry->client_id, entry->src_id, entry->ring_id, entry->vmid);

   Isto e o que fecha o caso, porque as tres saidas sao mutuamente exclusivas:
   - nenhuma linha com cid=8 aparece  -> o IV realmente nao chega. Premissa de P2 confirmada; ai o resultado do force_ring0 vale alguma coisa.
   - aparecem linhas cid=8 ring_id!=0 -> P2 esta REFUTADA na raiz: o IV sempre chegou no anel 0, foi despachado com sucesso, e morreu no case vazio "/* XXX compute */" de sdma_v5_0_process_trap_irq. A correcao passa a ser trivial (tratar ring_id!=0, ou entender por que a engine 0 reporta ring_id errado) e nao mexe em IH nenhum.
   - aparecem linhas cid=8 ring_id==0 e o fallback some -> P2 funcionou.

Com essas 5 mudancas o experimento vira: 3 boots com bc250_ih_force_ring0=0 e 3 com =1, mesmo binario, e o par (dump, SDMA IV) responde tanto P2 quanto a hipotese concorrente. Sem elas, especialmente sem a 3 e a 5, e um reboot que pode produzir uma refutacao falsa.

### [SOBREVIVEU] P3 — Limpar IH_INT_DROP_* e IH_STORM_CLIENT_LIST_CNTL
- Nao consegui refutar. Auditoria de simbolos passou inteira: mmIH_INT_DROP_CNTL (0x018e), MATCH_VALUE0/1 (0x018f/0x0190), MATCH_MASK0/1 (0x0191/0x0192) e mmIH_STORM_CLIENT_LIST_CNTL (0x00da) existem em osssys_5_0_0_offset.h; os campos INT_DROP_EN/CLIENT_ID_MATCH_EN/SOURCE_ID_MATCH_EN/INT_DROPPED existem em osssys_5_0_0_sh_mask.h:1180-1198; CLIENT_ID_MATCH_VALUE ocupa bits [7:0] de MATCH_VALUE0. grep em drivers/gpu/drm/amd/amdgpu/ confirma ZERO escritas nesses registradores em navi10_ih.c (unicos hits sao ih_v6_0/v6_1/v7_0 setando CLIENT18_IS_STORM_CLIENT) -- a alegacao central "amdgpu nunca programa isso em gen 5.0" e verdadeira. OSSSYS do cyan skillfish e IP_VERSION(5,0,1) (amdgpu_discovery.c:2904) com reg_offset[OSSSYS_HWIP]=OSSSYS_BASE 0x10A0 (cyan_skillfish_reg_init.c:48), e navi10_ih.c inclui justamente osssys_5_0_0_offset.h, entao WREG32_SOC15(OSSSYS,0,...) e a forma correta e os offsets sao os do silicio certo. navi10_ih_irq_init existe (navi10_ih.c:317-377) e o fim dela e um ponto valido: o filtro age no momento da entrega do IV, e o fallback do sdma0 ocorre em ~10.9s, bem depois do irq_init em ~10.1s.

CRITERIO 2 (assimetria) -- PASSA, e essa e a forca desta proposta. SOC15_IH_CLIENTID_SDMA0=0x08 e SDMA1=0x09 (soc15_ih_clientid.h:41-42). O filtro tem CLIENT_ID_MATCH_EN e um CLIENT_ID_MATCH_VALUE de 8 bits, ou seja, ele consegue casar exatamente uma engine e deixar a outra passar. Diferente de propostas que mexem em algo global, esta tem um mecanismo nativo de assimetria por instancia. Idem para o storm list, onde o bit index e o proprio client id (CLIENT8 vs CLIENT9 existem no header).

CRITERIO 1 (contradicao com fatos) -- PASSA. Descarte no OSSSYS antes da escrita no anel produz precisamente o quadro medido: wptr nao avanca, nao ha MSI, nada aparece no dyndbg de amdgpu_irq.c (nem "Unregistered client_id", porque o IV nunca chega ao dispatch), e a fence e encontrada JA COMPLETA pelo fallback. O ring test passar a frio tambem e compativel, porque ring test faz polling de memoria e nao depende de IRQ. E compativel com HSA_ENABLE_SDMA=1 girando para sempre (perda de 100%, nao intermitente).

CRITERIO 4 (teste) -- PASSA com ressalva. O sinal de refutacao e limpo: se o dump pos-escrita le zero e o fallback do sdma0 continua, o filtro esta descartado como causa e nao ha explicacao alternativa que confunda. Custo real e ZERO reboots extras, porque a proposta se auto-gateia no dump de P1.

Os defeitos que achei sao de execucao, nao de mecanismo, e estao no campo de correcao. O maior deles e que escrever MATCH_MASK=0 e perigoso, e que o gate "se o dump vier zerado, pule" pode dar falso negativo dependendo de QUANDO o dump e tirado.
- correcao sugerida: 1) NAO escreva MATCH_MASK0/MASK1 = 0. Semantica de mascara e "quais bits participam da comparacao": mask=0 significa nenhum bit comparado, ou seja, CASA COM TUDO. Se por qualquer motivo a escrita de IH_INT_DROP_CNTL=0 nao pegar (firewall de registrador -- ver IH_CHICKEN__REG_FIREWALL_ENABLE no mesmo header -- ou re-arme posterior por PSP/SMU) e as mascaras pegarem, voce acabou de armar um "descartar TODA interrupcao da GPU". Isso e um boot morto sem console grafico, custando reboot em modo de recuperacao. Escreva SOMENTE mmIH_INT_DROP_CNTL = 0. Isso ja e suficiente, porque INT_DROP_EN=0 desliga o comparador inteiro. Se quiser cinto e suspensorio, escreva CNTL=0, depois releia CNTL, e so mexa nas mascaras se a releitura confirmar EN=0 -- e mesmo assim use 0xFFFFFFFF, nunca 0.

2) Separe o storm list em outro parametro, ou corte fora. IH_STORM_CLIENT_LIST_CNTL marca um cliente como sujeito a rate limit sob congestionamento; ele nao suprime 2-3 interrupcoes isoladas num IH ocioso em boot frio. navi10_ih.c nao programa nenhum IH_INT_FLOOD_CNTL nem nada correlato, entao nao ha sequer o resto da maquinaria de storm configurada. Juntar as duas escritas no mesmo module_param destroi a atribuicao: se o sintoma mudar, voce nao sabe qual registrador fez. Deixe bc250_ih_clear_filters mexendo so no INT_DROP.

3) Aperte o gate de P1 e conserte o timing dele. O gate atual ("so faz sentido se o dump mostrar INT_DROP_EN=1") desperdica o bit 16, INT_DROPPED (mascara 0x00010000), que e um status pegajoso de "este filtro ja descartou alguma coisa". A leitura decisiva e: INT_DROP_EN=1 E INT_DROPPED=1 -> prossiga. INT_DROP_EN=1 mas INT_DROPPED=0 -> filtro armado mas nunca disparou, P3 esta REFUTADA sem gastar reboot. Tudo zerado -> pule, como a proposta ja diz. MAS: isso so vale se o dump for tirado DEPOIS do momento em que as interrupcoes se perdem. Se P1 dumpar apenas dentro de navi10_ih_irq_init (~10.1s) e o fallback do sdma0 acontecer as ~10.9s, INT_DROPPED vai ler 0 mesmo que o filtro seja o culpado, e voce descarta a hipotese certa por artefato de timing. Exija que P1 tire o dump em DOIS momentos: um no fim de navi10_ih_irq_init e outro tardio (delayed_work de ~30s apos o probe, ou direto dentro de amdgpu_fence_fallback quando ring == sdma0). Sem o dump tardio o gate de P3 nao e confiavel.

4) Checagem gratuita antes de qualquer reboot, que pode matar P3 de graca: se o descarte fosse em hardware por client_id=8, a perda seria 100% e permanente, entao TODO trabalho do kernel na sdma0 dependeria do fallback timer. Como adev->mman.buffer_funcs_ring aponta para sdma.instance[0] e vm_pte_scheds inclui a instancia 0, uma sessao de jogo ou qualquer carga pesada de TTM deveria gerar um fluxo continuo de "Fence fallback timer expired on ring sdma0", nao apenas as 2-3 linhas de boot. Rode journalctl -b -g "fallback timer" apos uma sessao de uso normal ja registrada. Se existirem SO as 2-3 linhas de boot e nenhuma sob carga, a supressao nao e total e P3 cai sem custar reboot nenhum.

5) Atribuicao no teste: com P2 e P3 no mesmo build, fixe explicitamente o parametro de P2 em 0 durante os 3 boots de P3 (e vice-versa). O sinal de sucesso citado ("aparecimento de SDMA IV: cid=8") depende do print instrumentado de P2 estar compilado -- garanta que esse print seja incondicional ou tenha param proprio de instrumentacao, separado do param de correcao de P2, senao voce nao consegue rodar P3 sem ligar P2.

### [SOBREVIVEU] P1 -- instrumentacao decisiva + patch candidato (default arm no switch de ring_id + dump one-shot do roteamento do IH)
- SOBREVIVE, mas exige uma correcao de compilacao obrigatoria e duas de metodo.

1. CONTRADIZ UM FATO MEDIDO? Nao contradiz nenhuma MEDICAO, mas exige que uma INFERENCIA da briefing esteja errada, e digo isso em voz alta: o bullet "navi10_ih_sw_init faz ih1.ring_size=0 e ih2.ring_size=0 => Nao esta parado num anel que ninguem le" e um non-sequitur. O fato e real (navi10_ih.c:580-581). A conclusao e o inverso do correto. Verifiquei no codigo: navi10_ih_init_register_offset (navi10_ih.c:66-88) guarda os offsets de ih1/ih2 atras de if (ring_size), entao o amdgpu nem registra os enderecos de RING1/RING2; navi10_ih_irq_init (linha 353) pula navi10_ih_enable_ring para eles; navi10_ih_toggle_interrupts (linhas 53-77) tambem pula. O Linux NUNCA habilita NEM DESABILITA RING1/RING2 -- eles ficam com o que o boot ROM do PS5 deixou. ring_size=0 e exatamente a condicao sob a qual um IV roteado para o ring 1 desaparece sem rastro. A briefing eliminou essa hipotese com raciocinio invalido, e o dump de P1 a testa diretamente.

Sobre a hipotese (a): tambem nao contradiz nada. Verifiquei amdgpu_irq_dispatch em amdgpu_irq.c -- o caminho de SUCESSO (src->funcs->process) NAO imprime nada. So os quatro dev_dbg de rejeicao imprimem. Logo o experimento dyndbg "file amdgpu_irq.c +p" e logicamente incapaz de distinguir "IV chegou e foi dispatchado para o buraco silencioso do switch" de "IV nunca chegou". A briefing afirma "=> O IV do trap do SDMA0 NAO chega ao amdgpu_irq_dispatch" -- essa conclusao nao e suportada pela evidencia apresentada. P1 e o primeiro teste que realmente separa os dois.

2. EXPLICA A ASSIMETRIA? Sim, nos dois ramos. (a) SDMA0 reportando ring_id != 0 enquanto SDMA1 reporta 0 e assimetrico por construcao e invisivel em qualquer log atual. (b) IH_CLIENT_CFG[8] (SOC15_IH_CLIENTID_SDMA0 = 0x08, confirmado em include/soc15_ih_clientid.h:41) roteando para RING_ID=1 enquanto IH_CLIENT_CFG[9] (SDMA1 = 0x09) roteia para 0 e uma assimetria per-client em estado herdado de firmware -- exatamente o tipo de coisa que o codigo simetrico do driver nao poderia consertar nem revelar. Isso e consistente com o fato ja medido de que a assimetria NAO esta no codigo generico.

3. SIMBOLOS INVENTADOS? ZERO. Conferi um a um contra a arvore.
   - sdma_v5_0_process_trap_irq: o switch(client_id) sem default e os dois switch(ring_id) com cases 1/2/3 vazios ("XXX compute"/"XXX page queue") e sem default estao exatamente como descrito. drm_WARN_ON_ONCE e o DRM_DEBUG("IH: SDMA trap") tambem.
   - Os 22 offsets mm* (IH_CLIENT_CFG, _INDEX, _DATA, IH_CID_REMAP_INDEX/_DATA, IH_INT_DROP_CNTL/MATCH_VALUE0/1/MASK0/1, IH_STORM_CLIENT_LIST_CNTL, IH_INT_FLOOD_CNTL, IH_RB0/1/2_INT_FLOOD_STATUS, IH_CLIENT_CREDIT_ERROR, IH_RB_{CNTL,BASE,WPTR,RPTR}_RING1/2) TODOS existem em drivers/gpu/drm/amd/include/asic_reg/oss/osssys_5_0_0_offset.h, com seus _BASE_IDX.
   - As 8 macros de campo IH_CLIENT_CFG_DATA__{RING_ID,VF_RB_SELECT,OVERWRITE_RING_ID_WITH_ACTIVE_FCN_ID,CLIENT_TYPE,INTERFACE_TYPE,CREDIT_RETURN_ADDR}_{MASK,__SHIFT} e IH_CLIENT_CFG__TOTAL_CLIENT_NUM_MASK existem em osssys_5_0_0_sh_mask.h:1138-1149. RING_ID__SHIFT=0x14, MASK=0x00300000 -> campo de 2 bits, ring 0..3 representavel.
   - navi10_ih.c ja inclui oss/osssys_5_0_0_offset.h e _sh_mask.h (linhas 29-30). Correto, nao falta header.
   - A alegacao "o amdgpu nao escreve NENHUM desses nesta placa" e VERDADEIRA: grep em drivers/gpu/drm/amd/amdgpu/*.c so acha IH_CLIENT_CFG em psp_v3_1.c (Vega, outro ASIC) e IH_STORM_CLIENT_LIST_CNTL em ih_v6_0/v6_1/v7_0 (chips posteriores). Nada toca nesses regs no caminho navi10_ih. Estado 100% herdado do console.
   - bc250_skip_sdma0 existe de verdade (kfd_device_queue_manager.c:165) e so gateia fila de USUARIO do KFD, como a briefing diz.
   - Unica imprecisao: a atribuicao "navi10_ih.c:110-111 mata a unica funcao que chegaria perto" aponta para o early-return de force_update_wptr_for_self_int (gate IP_VERSION < 5,0,3), que mexe em IH_CNTL2/RB_CNTL_RING1/2, nao em IH_CLIENT_CFG. Numero de linha errado, mas a afirmacao substantiva ("ninguem escreve") e independentemente verdadeira. Nao e invencao, e sloppiness de citacao.

4. DEFEITO QUE QUEBRA O BUILD (nao refuta, mas TEM que ser corrigido antes do reboot): a proposta coloca module_param(bc250_sdma_iv_trace, int, 0644) DENTRO do corpo de sdma_v5_0_process_trap_irq. module_param -> param_check_int -> __param_check (include/linux/moduleparam.h:436-437) expande para "static inline type __always_unused *__check_##name(void) { return(p); }" -- uma DEFINICAO DE FUNCAO com storage class static. GCC recusa: "invalid storage class for function". Compilacao falha. Trivial de consertar (escopo de arquivo), mas se for buildado como escrito o usuario gasta 5 min de compilacao e nao gasta o reboot -- entao e barato, mas e um bug real.

5. O TESTE DISTINGUE? Sim, com uma ressalva. SINAL A (o default dispara + o fallback some) so pode acontecer se o IV chegou; SINAL B (zero cid=8, cid=9 presente) so pode acontecer se nao chegou. Sao mutuamente exclusivos e ambos observaveis no mesmo boot. Nao ha confusao com outra coisa. Ressalva: o contador unico bc250_sdma_iv_trace=64 e COMPARTILHADO entre os dois ramos de client_id; se o sdma1 (ou qualquer storm) queimar os 64 slots primeiro, voce ve zero cid=8 por exaustao de orcamento e le isso como SINAL B falsamente.

6. SEGURANCA DO "FIX": chamar amdgpu_fence_process espuriamente nos cases 1/2/3 e no default e de fato inofensivo -- a funcao le a seq real da fence do writeback e so sinaliza o que genuinamente terminou; e literalmente o que o fallback timer ja faz. Idempotente, como a proposta alega. Confirmado.

7. RISCO DE MMIO: os RREG32/WREG32_SOC15 sao de contexto de driver com a GPU viva, dentro de navi10_ih_irq_init, depois do pci_set_master. Nao e leitura crua de userspace. Dentro da restricao dura declarada. As escritas nas janelas indexadas (CLIENT_CFG_INDEX / CID_REMAP_INDEX) sao o unico ponto novo, e ninguem mais no driver usa essas janelas neste ASIC, entao nao ha corrida.
- correcao sugerida: Sobrevive, mas NAO buildar como escrito. Tres correcoes antes de gastar o reboot:

(1) OBRIGATORIA -- move o module_param para escopo de arquivo. Em sdma_v5_0.c, junto dos outros params no topo do arquivo (fora de qualquer funcao):

    static int bc250_sdma_iv_trace = 64;
    module_param(bc250_sdma_iv_trace, int, 0644);
    MODULE_PARM_DESC(bc250_sdma_iv_trace, "BC250: numero de IVs de trap SDMA a logar (default 64)");

Dentro de sdma_v5_0_process_trap_irq fica so o "if (bc250_sdma_iv_trace > 0) { bc250_sdma_iv_trace--; dev_info(...); }". Como esta na proposta o GCC aborta com "invalid storage class for function '__check_bc250_sdma_iv_trace'" porque param_check_int expande para uma definicao de funcao aninhada (moduleparam.h:436-437).

(2) OBRIGATORIA -- separa o orcamento de trace por instancia, senao SINAL B tem falso positivo por exaustao:

    static int bc250_sdma_iv_trace[2] = { 32, 32 };
    module_param_array(bc250_sdma_iv_trace, int, NULL, 0644);

e indexa por (entry->client_id == SOC15_IH_CLIENTID_SDMA0) ? 0 : 1. Assim "zero linhas cid=8" so pode significar "nenhum IV do SDMA0 chegou", nunca "o sdma1 comeu o orcamento". Sem isso SINAL B nao e conclusivo.

(3) OBRIGATORIA -- NAO tire amdgpu.bc250_skip_sdma0=1 da cmdline neste boot. E risco puro sem ganho: o fato medido diz que o fallback do sdma0 acontece em TODO boot frio "antes de qualquer carga", em ~10.9s, com o param JA ATIVO -- porque o ring do proprio kernel continua na sdma0 independente do param (que so gateia fila de usuario do KFD, kfd_device_queue_manager.c:185). O sinal que voce quer ja aparece com skip_sdma0=1. Tirar so devolve as filas de usuario do KFD para a engine quebrada, com o risco medido de girar em 199% de CPU sem progresso, e ainda polui o trace com IVs de KFD depois do login que podem ser lidos erroneamente como confirmacao de SIGNAL A.

(4) RECOMENDADA -- adiciona um marcador de sanidade no dump para provar que a funcao rodou mesmo quando tudo vier limpo, senao SINAL C fica ambiguo entre "dump limpo" e "dump nao executou": um dev_info("BC250 IH dump: begin/end") em volta. Barato e mata a unica ambiguidade que sobra.

(5) OPCIONAL -- mantem os dois loops indexados. O risco alegado e baixo e e o unico caminho para a evidencia que importa (RING_ID per-client). Mas se quiser blindar, ordena o dump: primeiro os regs diretos (DROP/STORM/RING1/RING2), depois os loops -- assim se algo pendurar nos loops voce ja tem a parte que responde "o firmware deixou aneis vivos?" no dmesg, que por si so ja falsifica ou confirma a inferencia ruim da briefing.

Observacao de merito a registrar junto do resultado: o valor real de P1 nao e (a), e (b). A briefing eliminou o roteamento para RING1/RING2 com um argumento invalido -- ring_size=0 nao prova que o hardware nao roteia para la, prova o oposto (o Linux nem inicializa os offsets desses aneis, navi10_ih.c:66-88, e nem os desabilita, linhas 53-77). Se P1 for cortado, corte (a) e mantenha (b).
