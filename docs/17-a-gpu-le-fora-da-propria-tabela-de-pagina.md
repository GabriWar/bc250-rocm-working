# A GPU lê fora da própria tabela de página

Medido em 2026-08-06. Este documento **substitui** a atribuição de
[11-miopen-conv-corruption.md](11-miopen-conv-corruption.md),
[12-gpu-vae-and-empty-cache.md](12-gpu-vae-and-empty-cache.md) e
[14-h2d-copy-corruption.md](14-h2d-copy-corruption.md). Nenhum dos três aponta
para a causa certa.

---

## O que o defeito é, de fato

Duas alocações **vivas** de `hipMalloc`, com BOs distintos e endereços virtuais
disjuntos, são tratadas pela GPU como a mesma memória. Escrever numa muda o
conteúdo da outra. A CPU não é afetada e permanece coerente consigo mesma o
tempo todo.

Não é corrupção de bits, não é dado perdido, não é lixo. É dado **real e válido
de outro buffer**, aparecendo íntegro no lugar errado — por isso a distribuição
dos valores errados sempre bateu com a dos corretos (`std` 1.0, faixa ±3.9,
nunca zero), e por isso conv e im2col davam o *mesmo* resultado errado: os dois
liam a mesma entrada aliasada.

### Condições

| condição | efeito |
|---|---|
| sem atividade prévia de GPU | 0 de 6 execuções |
| com atividade prévia | 5 de 6 |
| só alocação, sem kernel | 0 de 3 |
| só kernel, sem alocação nova | 0 de 3 |
| alocação e kernel intercalados | 3 de 3 |
| serialização total (`HIP_LAUNCH_BLOCKING=1`, `AMD_SERIALIZE_*=3`) | reproduz igual |

Precisa das duas metades. E acontece com tudo serializado, então **não é
corrida entre operações**.

O resultado é **bimodal por processo**: um processo ou aliasa em praticamente
todos os ciclos, ou em nenhum. Uma vez estabelecido, é determinístico e
persiste — invalidação forçada de TLB e reescrita não recuperam o bloco.

---

## Reprodutor

[`tools/hipmalloc_cru.py`](../tools/hipmalloc_cru.py) — ~2 minutos, acerta em
~83% das execuções (10 de 12 numa bateria, 5 de 6 em outra).

Não usa PyTorch para o teste em si: chama `hipMalloc`, `hipMemset`,
`hipDeviceSynchronize` e `hipMemcpy` direto por `ctypes`. O PyTorch entra só no
aquecimento, para chegar ao estado onde o defeito aparece.

```
hipmalloc_cru.py <rodadas_de_churn> <modo_de_aquecimento> [cpu|segurar]

modos: orig | so-alloc | so-kernel | sem-aquecer
```

Ferramentas de apoio, todas em `tools/`:

| arquivo | o que decide |
|---|---|
| `matriz_cpu_gpu.py` | matriz quem-escreve × quem-lê, bloco a bloco |
| `triangular_fisico.py` | triangulação VA / GPU / endereço físico |
| `sobreposicao.py` | detecta aliasing com tensores do PyTorch |
| `quem_erra_escrita_ou_leitura.py` | separa erro de escrita de erro de leitura |
| `trace_matriz.sh` | captura tracepoints de VM do amdgpu junto do reprodutor |
| `ab_flush_vmids.sh` | A/B contrabalanceado de `bc250_flush_mapped_vmids` |
| `coletar_pares.py` | coleta em escala de pares (PA esperado, PA entregue) |

Os 2266 pares coletados estão em
[`data-pares-aliasing.tsv`](data-pares-aliasing.tsv):
`ciclo, bloco, tamanho, VA, PA esperado, bloco entregue, PA entregue`.

E dois auxiliares em `~/bc250-grimoire/`, que rodam como root porque
`/sys/kernel/debug/dri/1/amdgpu_vram` é só-root:

| arquivo | o que faz |
|---|---|
| `varrer_vram.py` | acha em que offset físico cada marcador realmente mora |
| `varrer_ptes.py` | acha as entradas de tabela que apontam para PAs dados |

---

## A evidência central: quatro observadores, um endereço

Para o mesmo bloco, no mesmo instante:

| observador | caminho | resultado |
|---|---|---|
| PTE que o driver escreveu | tracepoint `amdgpu_vm_set_ptes` | **correta** |
| PTE que está na memória | leitura física da VRAM | **correta** |
| dado no PA que a PTE aponta | `debugfs/dri/1/amdgpu_vram`, sem VA nenhum | **correto** |
| o que a GPU entrega | tabela de página → PA | **errado** |

A tabela de página que a GPU usa foi lida do tracepoint `amdgpu_vm_set_ptes`:

```
A6922240:  PTE aponta offset 0x4000000
           dado do bloco esta fisicamente em 0x4000000, 0x4200000, 0x4400000, 0x4600000
           GPU entrega o marcador do bloco 6

A10485760: PTE aponta offset 0x5800000
           dado do bloco esta em 0x5800000, 0x5a00000, 0x5c00000, 0x5e00000, 0xf800000
           GPU entrega 0x0
```

A base do FB calibrou em **0x170000000, conferindo em 11 de 11 blocos** — o que
valida o método inteiro, não só o caso que interessa.

A releitura pela GPU foi refeita **depois** da varredura física confirmar o
conteúdo da memória, e continuou errada. Isso elimina a explicação de ordenação
de escrita da CPU em memória write-combining.

### Os bytes reais da entrada

O tracepoint mostra o que o driver *escreveu*. Como as tabelas moram na mesma
VRAM, uma corrupção nelas apareceria como escrita correta e leitura estragada.
Verificado direto, lendo o slot na memória física:

```
A8028160:  driver escreveu addr=0x46f000000
           slot 0x2fffcec50 na VRAM = 0x4000046f000561
                                         ^^^^^^^
           campo de endereco (bits 47:12) = 0x46f000000
```

A entrada na memória aponta para o endereço certo. E a tabela inteira onde ela
mora foi varrida: 104 entradas válidas de 512, **nenhum endereço físico
repetido**.

**PTE escrita correta, PTE na memória correta, memória física correta, GPU
errada.** Não sobrou camada de software errada.

---

## O que foi refutado, e com que medida

Cada linha caiu por medição própria, não por argumento.

| hipótese | o que a matou |
|---|---|
| MIOpen gera conv errado | reproduz com `fill_` e `hipMemset`, sem MIOpen |
| fila de compute defeituosa | refutado antes; e reproduz por SDMA também |
| staging do ROCclr | chunk de 1 / 16 / 64 MiB → 2 / 4 / 2 tensores; sem efeito |
| SDMA | reproduz com kernel de compute puro |
| corrida entre transferências | reproduz com kernels e cópias totalmente serializados |
| tempo de vida do buffer de host | HOLD 8/0/5 contra FREE 0/5/0 — sem diferença |
| alocador do PyTorch | reproduz com `hipMalloc` cru |
| mapeamento de host | CPU escreve e lê certo nas duas direções; `/proc/maps` mostra BOs distintos |
| `bc250_flush_mapped_vmids` | A/B contrabalanceado, mesmo boot: 5/6 contra 5/6 |
| `vm_update_mode` (CPU × SDMA) | 10/12 contra 5/6 — quem escreve as PTEs não importa |
| evicção/movimento de BO por TTM | 12288 MiB de VRAM, 19 MiB em uso, `evict_vram` e `evict_gtt` em 0 |
| tabelas de página | cobertura exata por bloco, faixas físicas sem cruzamento |
| cache L2 da GPU não escrevendo de volta | leitura física confirma o dado na memória; GPU segue errada |

---

## Erros de método cometidos nesta investigação

Registrados porque quase todos produziram um "achei" falso antes de serem
pegos, e o padrão se repete.

**Filtro literal em vez de numérico.** Um `grep` por `7fae39a00` e `7fae3a200`
sugeriu um buraco de 4 MiB sem escrita de PTE no meio de um mapeamento. A peça
do meio existia — ela só não continha nenhuma das duas strings. Refeito por
interseção de faixa: cobertura completa, sem buraco.

**Janela de tempo arbitrária.** Agrupar eventos por `t > tmax - 0.01` juntou
várias gerações de mapeamento e mostrou um bloco de 6 MiB com 32 MiB de faixas
físicas, produzindo dezenas de "cruzamentos" que eram memória de BO já
liberado. Corrigido colhendo para trás a partir do último MAP.

**Rótulo que carrega conclusão.** Chamar `host(g!=x)>0` de "o upload com sync
corrompeu" ignorava que aquele buffer ficou parado na memória durante a rajada
inteira e podia ter sido atropelado depois. O dado não distinguia os dois casos;
o rótulo fingia que sim.

**Duas mudanças ao mesmo tempo.** Ligar o tracepoint `set_ptes` e adicionar 12
`say()` com `fsync` na mesma rodada, e o fenômeno sumir, não diz qual dos dois
causou. Separados depois: a impressão é inofensiva, o tracepoint sem filtro é
que perturba (938 eventos dentro do laço de escrita de PTE).

**Leitura de MMIO cru numa placa que trava.** Montar o endereço de
`mmMM_ATC_L2_MISC_CG` e ler por `amdgpu_regs` pendurou a máquina, exigindo reset
físico. O risco estava documentado no nosso próprio `bc250_dead_gpu_guard`, e o
próprio driver evita esses registradores neste chip. O erro mais caro da
investigação, e o mais evitável.

**`sudo -S` engolindo stdin.** `printf senha | sudo -S tee arquivo` faz o `tee`
receber a senha, não o valor. Aconteceu duas vezes, as duas silenciosas porque
o `2>/dev/null` escondia o erro. A forma correta é `sudo -S sh -c "echo v > f"`
ou um arquivo de script.

**Correlacionar artefatos de execuções diferentes.** O `trace.txt` e o
`repro.txt` salvos vinham de rodadas distintas do runner, e eu comparei
endereços de um com eventos do outro. Resolvido fazendo o reprodutor imprimir
os próprios endereços no arquivo gravado junto com o trace.

---

## A busca por invariante de endereço (2266 pares)

Com poucas amostras apareceram duas leituras que se contradiziam: numa o PA
ENTREGUE era sempre `0x176000000`/`0x176800000`, noutra o PA ESPERADO era sempre
`0x170000000`. Cada uma sozinha teria justificado um patch diferente. Então foi
montada uma coleta em escala (`tools/coletar_pares.py`), 6 processos × 40
ciclos, com âncora física nos dois primeiros ciclos de cada processo.

**Duas armadilhas do próprio instrumento, pegas antes de virarem conclusão:**

A primeira versão escrevia 8 bytes por página de 2 MiB em memória
write-combining e sincronizava só a GPU. `hipDeviceSynchronize` não descarrega
buffer de WC da CPU, então a GPU lia o marcador da geração anterior daquele
endereço. Produziu 7 "divergências" em todos os 40 ciclos, sempre nos mesmos
blocos e em anel fechado — 1889 pares de puro artefato. O sinal foi a
regularidade: o fenômeno real é bimodal, constante assim é bug de medida.

Corrigido com duas travas: encher 4 KiB por página, o que força o WC a
descarregar, e **conferir pela CPU** que o marcador está lá antes de perguntar à
GPU. Depois disso a taxa continuou alta (10 de 12 blocos por ciclo), o que
levantou a segunda suspeita — mas a varredura física no ciclo 2 confirmou os
marcadores no offset que a PTE aponta. As divergências são reais; a rotatividade
apertada é que empurra a taxa para cima.

**O resultado, com 2266 pares:**

```
bits(27,28,32,34) = (1,1,1,1)   1794   79.2%
bits(27,28,32,34) = (0,0,0,0)    472   20.8%
```

Quatro bits que nunca viram parcialmente pareciam assinatura de decodificação de
endereço. **Não são.** A forma forte da hipótese — `A` aliasa com
`A ^ 0x518000000` — falha: o parceiro aparece em 4 de 17 endereços e só 2
aliasam mutuamente.

Os 17 endereços formam dois grupos, um no começo da janela de VRAM
(`0x171`–`0x173`, offsets de 16 a 56 MiB) e outro no topo (`0x469`–`0x46f`,
~11,9 GiB). A máscara `0x518000000` é exatamente o que separa um grupo do outro.
Então "os quatro bits viram juntos" é só outra forma de dizer "o dado veio do
outro extremo da VRAM" — consequência de a distribuição ser bimodal, não causa.

**Não há invariante de endereço.** Sem ela caem as duas rotas de conserto que
pareciam abertas: reserva de página física e ajuste de configuração de
interleave.

## Clockgating do hub de memória: linha encerrada, e o custo

O `gmc_v10_0_get_clockgating_state` tem um caso especial que pula o gfx1013:

```c
if (amdgpu_ip_version(adev, GC_HWIP, 0) == IP_VERSION(10, 1, 3) ||
    amdgpu_ip_version(adev, GC_HWIP, 0) == IP_VERSION(10, 1, 4))
	return;                       // pula MMHUB e ATHUB
```

Foram três leituras desse trecho, e só a terceira é a certa.

A primeira: "pula porque `cg_flags = 0` torna a leitura inútil". A segunda,
invertida: "pula escondendo clockgating que o firmware ligou e o driver não
gerencia" — que teria sido o mesmo padrão dos registradores de WGP.

**A terceira veio de travar a máquina.** Ler `mmMM_ATC_L2_MISC_CG` e
`mmDAGB0_CNTL_MISC2` por MMIO cru pendura a CPU. O caso especial é *proteção*,
não descuido — e o mesmo motivo do nosso `bc250_dead_gpu_guard`: nesta placa uma
leitura de MMIO não falha, ela trava no fabric interno, que não tem timeout de
conclusão.

Isso encerra a linha por completo:

- ler os registradores trava
- patchear o kernel para permitir travaria igual, só que dentro do driver
- e não há o que desligar: `nv.c` declara `adev->cg_flags = 0` para
  `IP_VERSION(10, 1, 3)`, então `mmhub_v2_0_update_medium_grain_clock_gating`
  retorna logo na primeira linha e o clockgating do hub **nunca é ligado**

Como consequência, `amdgpu.cg_mask` também é inócuo aqui: ele só faz
`adev->cg_flags &= amdgpu_cg_mask`, e mascarar zero dá zero.

**Regra que fica:** nada de leitura de MMIO cru nesta placa. `amdgpu_regs` e
`/dev/mem` estão fora. O `bc250_dead_gpu_guard` protege o caminho que o driver
controla, não ferramenta externa.

## Chaves de diagnóstico que continuam sem teste

Escritas em `amdgpu_vm.c` e `amdgpu_gmc.c`, todas default 0 e `0644`, mas o
build foi interrompido antes do link — o `.ko` instalado ainda é o antigo.

| chave | estado |
|---|---|
| `bc250_tlb_extra_types` | **morta**: `get_invalidate_req` já liga `INVALIDATE_L2_PTES/PDE0/PDE1/PDE2` em toda invalidação |
| `bc250_tlb_all_hub` | **sem teste** |
| `bc250_tlb_no_seq_skip` | **sem teste** |
| `bc250_tlb_trace` | instrumentação |

O `all_hub` é o mais interessante dos dois vivos. Em
`amdgpu_vm_flush_compute_tlb`, `all_hub` só vira verdadeiro para
`AMDGPU_FAMILY_AI` e `_RV`. Cyan Skillfish é APU mas recebe
`AMDGPU_FAMILY_NV`, então fica falso e **só o GFXHUB é invalidado**. O MMHUB,
por onde o SDMA acessa memória, nunca recebe invalidação em mudança de VM de
processo — e boa parte das medidas de "o que a GPU entrega" passou por
`hipMemcpy`, que é SDMA.

O `no_seq_skip` remove o `atomic64_xchg(&vm->kfd_last_flushed_seq, tlb_seq) ==
tlb_seq`, que pula o flush inteiro quando o contador não mudou.

Ambas são de uma linha e, sendo `0644`, permitem A/B no mesmo boot depois de
carregar o módulo.

## O que ainda não foi verificado

**Se o defeito é de configuração ou de silício.** É a única pergunta viva, e a
distinção é decisiva: configuração é registrador, e registrador é código.

Duas ressalvas menores de escopo, nenhuma delas alternativa à conclusão:

- a "leitura pela GPU" da triangulação usa `hipMemcpy`, que passa por SDMA. Os
  testes com `fill_` e `hipMemset` cobrem o caminho de compute e dão o mesmo
  resultado, mas os dois compartilham as mesmas tabelas.
- a varredura física acha a tabela procurando entradas que apontem para PAs
  conhecidos. Se uma entrada estivesse corrompida *e* apontasse para outro PA
  conhecido, ela seria atribuída ao bloco errado. A checagem de PA repetido
  dentro da tabela cobre esse caso e deu negativo.

---

## Para onde isso aponta

O defeito está **abaixo da tabela de página**, no caminho de tradução e acesso
da própria GPU. Driver, ROCm, PyTorch e o conteúdo das tabelas na memória estão
todos corretos — todos foram medidos, nenhum foi assumido.

Consequência prática: **não existe patch de lógica que conserte isso**, porque
não existe lógica errada. Qualquer conserto por software teria que ser
configuração de hardware, não código de driver.

Isso divide em dois, e só um é fatal:

- **configuração de memória** (interleave de canal, bits de endereço, tamanho de
  aperture, harvest) — escrita por firmware e driver no init, portanto alcançável
  por código, mesma natureza do desbloqueio de WGP de
  [16-wgp-registers-vem-do-vbios.md](16-wgp-registers-vem-do-vbios.md)
- **silício** (tag de L2 truncando bits, controlador de memória) — sem conserto
  por software

O que favorece configuração é a taxa acompanhar o tamanho da VRAM:

```
512 MB   20.4%
4 GB     15.7%
12 GB    12.0%
```

Arquivado antes como indicativo por causa dos intervalos sobrepostos. Sob a
leitura de endereçamento físico, uma taxa que varia com o tamanho de uma janela
escolhida por firmware é assinatura de configuração, não de defeito fixo de
célula.

Contexto que reforça: é um APU de PS5 com GDDR6 unificada, cuja configuração de
memória foi montada para um sistema que não roda aqui, e que nunca foi auditada
para compute com endereço virtual reusado.

### Rotas de conserto que morreram

| rota | o que a matou |
|---|---|
| reservar páginas físicas ruins | não há conjunto fixo: 17 endereços, todos legítimos, aliasando entre si |
| não reusar faixa de VA | 1 de 4 contra 2 de 4, sem diferença |
| emitir tipos extras de flush de TLB | `get_invalidate_req` já liga `INVALIDATE_L2_PTES/PDE0/PDE1/PDE2` em toda invalidação |
| ajustar interleave por registrador | depende de invariante de endereço, que não existe |

### Próximos passos, em ordem

1. **Varrer o tamanho de VRAM na BIOS medindo a taxa**, n≥3 por tamanho. É a
   última pista de configuração que sobrou, vinda da observação antiga de que a
   taxa acompanha o tamanho (20,4% em 512 MB, 15,7% em 4 GB, 12,0% em 12 GB).
2. Se a taxa não acompanhar, encerrar a busca por conserto e ir para
   **detecção**: a visão da CPU está sempre correta, então dá para verificar
   integridade depois de subir dado e refazer o que vier errado. Caro, mas
   confiável, e não depende de entender o hardware.

### Sobre o método

Cinco candidatos dissolveram sob escrutínio no mesmo dia — aliasing físico fixo,
reuso de VA, tipos extras de flush, delta constante e a invariante de bits.
Todos pareciam sólidos na primeira amostra. O padrão que se repete é que n
pequeno produz estrutura aparente, e a estrutura some quando o n cresce.
Nenhuma conclusão daqui deve ser escrita em patch sem repetir a medida com
volume.

---

## Correções necessárias fora deste repositório

O issue 6313 do ROCm tem três comentários atribuindo o defeito ao MIOpen. Está
errado e precisa de retratação.
