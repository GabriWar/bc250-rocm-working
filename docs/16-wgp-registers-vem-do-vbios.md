# Os registradores de WGP já vêm abertos do VBIOS — não há o que fazer no BIOS

Medido 2026-08-06. Leitura direta dos três registradores do unlock de 40 CU em
vários pontos de `gfx_v10_0_hw_init()`, em boot morno e em cold boot completo.

A comunidade não tem esse dado: o `umr` falha exatamente nesses offsets na
BC-250 (relato no grupo russo: *"Failed to read
cyan_skillfish.gfx1013.mmSPI_PG_ENABLE_STATIC_WGP_MASK with umr"*).

---

## Como foi medido

Patch de diagnóstico, só leitura — `RREG32` + `dev_info`, sem mudar
comportamento. Três pontos de `gfx_v10_0_hw_init()`:

```
gfx_v10_0_constants_init(adev);
  -> ponto 1: antes de qualquer coisa nossa
r = gfx_v10_0_rlc_resume(adev);
  -> ponto 2: o firmware do RLC ja subiu
r = gfx_v10_0_cp_resume(adev);
  -> ponto 3: MEC/CP ja subiram
...
gfx_v10_0_get_cu_info(...)   <- onde o unlock escreve, DEPOIS de tudo isso
```

Offsets (de `gc_10_1_0_offset.h`):

```
mmCC_GC_SHADER_ARRAY_CONFIG        0x100f
mmSPI_PG_ENABLE_STATIC_WGP_MASK    0x1277
mmRLC_PG_ALWAYS_ON_WGP_MASK        0x4c53
```

---

## Resultado

Boot morno e **cold boot completo** (desligado da tomada) dão exatamente o
mesmo, nos três pontos:

```
apos constants_init   CC=0xffe00000  SPI=0x0000001f  RLC=0x0000001f
apos rlc_resume       CC=0xffe00000  SPI=0x0000001f  RLC=0x0000001f
apos cp_resume        CC=0xffe00000  SPI=0x0000001f  RLC=0x0000001f
```

Três conclusões, todas diretas:

### 1. O RLC não sobrescreve nada

Idênticos antes e depois de `rlc_resume` e de `cp_resume`. O comentário do
próprio driver — *"init golden registers and rlc resume may override some
registers"* — não se aplica a estes três. Mover a escrita do unlock para antes
do `rlc_resume` seria seguro, se houvesse motivo.

### 2. O VBIOS já entrega `SPI` e `RLC` abertos

`0x1f` já está lá no `constants_init`, que roda **antes** do nosso código. E
sobrevive a um cold boot, o que descarta resíduo do boot anterior. Logo vem do
POST.

**Isso responde a pergunta de bakear o unlock no BIOS: já está bakeado.** O
firmware da BC-250 abre o gate do SPI para os 5 WGPs e marca todos como
always-on de fábrica. Não há o que editar.

### 3. Só o `CC` é realmente alterado por nós

`CC_GC_SHADER_ARRAY_CONFIG` lê `0xffe00000` — a máscara de harvest — em todos os
pontos, inclusive depois de o unlock escrever zero nele. É sombreado por
fusível: a escrita muda a enumeração, a leitura devolve o fusível. Por isso o
`active_cu_number` sai 40 mesmo com o registrador lendo a máscara.

---

## O que isso derruba

**A escrita de `RLC_PG_ALWAYS_ON_WGP_MASK` no nosso unlock é redundante.**
Escreve `0x1f` num registrador que já vale `0x1f`.

Isso contradiz o mecanismo que o project-ariel usa para justificar o patch 16
(`16-cu-unlock-cc-spi-safe-no-rlc.patch`):

> *Escrever `RLC_PG_ALWAYS_ON_WGP_MASK` com o firmware do RLC rodando faz a
> máquina de bring-up por WGP ativar os WGPs 3-4 (...) o RLC trava esperando um
> ACK que nunca chega, causando travamento do sistema no primeiro lançamento de
> rocBLAS / HSA.*

Nesta placa a escrita não muda o valor, e o valor já estava `0x1f` quando o RLC
subiu. Então o patch 16 provavelmente é um no-op aqui, e os travamentos duros
que medimos (3 de 3, reprodutíveis, sem rastro no dmesg) têm outra causa.

Ressalva honesta: não testamos o patch 16. O que está medido é que a premissa
dele não se sustenta *nesta* placa com *este* VBIOS (P5.00, 05/03/2022). Placas
com VBIOS diferente podem entregar `0x7` e aí a escrita passa a importar — que é
provavelmente o caso da placa em que eles observaram o stall.

**E retiro uma coisa que eu disse entre as duas medições.** No boot morno,
vendo `0x1f` antes do nosso código, concluí que os registradores persistiam
entre boots e que portanto "boot limpo" nunca foi limpo. O cold boot mostrou que
não é persistência, é o POST. Os boots limpos eram limpos.

---

## Estado dos três registradores nesta placa, para referência

| registrador | offset | valor | origem |
|---|---|---|---|
| `CC_GC_SHADER_ARRAY_CONFIG` | `0x100f` | `0xffe00000` | fusível (leitura sempre devolve o fusível) |
| `SPI_PG_ENABLE_STATIC_WGP_MASK` | `0x1277` | `0x1f` | VBIOS, no POST |
| `RLC_PG_ALWAYS_ON_WGP_MASK` | `0x4c53` | `0x1f` | VBIOS, no POST |

Hardware: BC-250, BIOS P5.00 05/03/2022, kernel 7.0.12-1-cachyos-bore-lto-bc250.
