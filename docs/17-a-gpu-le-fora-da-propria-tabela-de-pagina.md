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

**`sudo -S` engolindo stdin.** `printf senha | sudo -S tee arquivo` faz o `tee`
receber a senha, não o valor. Aconteceu duas vezes, as duas silenciosas porque
o `2>/dev/null` escondia o erro. A forma correta é `sudo -S sh -c "echo v > f"`
ou um arquivo de script.

**Correlacionar artefatos de execuções diferentes.** O `trace.txt` e o
`repro.txt` salvos vinham de rodadas distintas do runner, e eu comparei
endereços de um com eventos do outro. Resolvido fazendo o reprodutor imprimir
os próprios endereços no arquivo gravado junto com o trace.

---

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

### Próximos passos, em ordem

1. **Varrer o tamanho de VRAM na BIOS medindo a taxa** com o reprodutor de 2
   minutos, n≥3 por tamanho. Taxa acompanhando o tamanho de forma sistemática ⇒
   configuração, e o caminho vira registrador/VBIOS. Taxa constante ⇒ silício.
2. Se der configuração, procurar os registradores de endereçamento de memória
   (interleave de canal, aperture, harvest) pelo mesmo método usado em
   [16-wgp-registers-vem-do-vbios.md](16-wgp-registers-vem-do-vbios.md).
3. Se for silício, o contorno conhecido é evitar o gatilho: um alocador que
   nunca reusa faixa de endereço virtual dentro do processo. Custa memória
   virtual, que sobra. É contorno, não conserto.

---

## Correções necessárias fora deste repositório

O issue 6313 do ROCm tem três comentários atribuindo o defeito ao MIOpen. Está
errado e precisa de retratação.
