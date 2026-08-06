# ComfyUI funcionando: sem warmup, VAE na GPU, e o Z-Image rodando

Medido em 2026-08-06, depois da investigação de [17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md).
Este documento **substitui a conclusão prática** de
[03-warmup.md](03-warmup.md) e [04-vae.md](04-vae.md): o warmup deixou de ser
necessário e o VAE roda na GPU.

---

## A configuração que funciona

```
SD 1.5 (cyberrealistic_final.safetensors)
    --fp16-vae          VAE na GPU
    BC250_WARMUP=0      sem warmup
    BC250_CONV_FIX=1
```

Sete execuções, todas válidas e **byte-idênticas entre si**:

```
seed=111   37.5s / 41.7s / 39.0s / 38.7s   std=74.4  cores=117077
seed=222   14.1s / 14.2s / 14.5s           std=75.2  cores=90173
```

A primeira execução de cada servidor carrega o modelo; a segunda é o tempo real.
**14 s para 24 steps a 512×512**, com o VAE na GPU. Antes eram 33 s com
`--cpu-vae`, dos quais ~15 s eram só o VAE na CPU.

Zero page faults em todas.

---

## Z-Image Turbo, o modelo da comunidade

Modelo do print que circula no grupo: `z-image-turbo-Q5_K_S.gguf` (4,9 GB) com
`Qwen3-4B-Instruct-2507-Q5_K_S.gguf` como encoder e `ae.safetensors` como VAE.

Precisa de [`ComfyUI-GGUF`](https://github.com/city96/ComfyUI-GGUF) (city96),
que traz `UnetLoaderGGUF` e `CLIPLoaderGGUF`.

### A escada de dtype

O Z-Image herda de `Lumina2` e declara:

```python
supported_inference_dtypes = [torch.bfloat16, torch.float32]
memory_usage_factor = 2.8
latent_format = latent_formats.Flux      # 16 canais
```

Três tentativas, três resultados diferentes:

| dtype | resultado |
|---|---|
| bf16 (padrão) | **falha** — `HIPBLAS_STATUS_INTERNAL_ERROR`, `HIP_R_16BF` nos três operandos |
| fp16 (`--fp16-unet --fp16-vae`) | **lixo silencioso** — termina sem erro, `std=0.0`, uma cor |
| fp32 (`--fp32-unet --fp32-vae`) | **funciona** — `std=59.8`, 71.427 cores |

O fp16 é o caso perigoso: exit code zero, sem page fault, sem exceção, e imagem
chapada. Só a estatística de pixel pega. bf16 tem a mesma faixa dinâmica do
fp32 com menos mantissa; fp16 satura em 65504 e as ativações do modelo estouram.

**fp32 tem suporte nativo completo nesta placa.** Não é fallback por falta de
suporte — é o dtype correto que restou. O que falta no silício é bf16, e só ele.

### Medida

```
amostragem   25 s   ->  3.23 s/step   (8 steps, euler, simple, CFG 1, 512x512)
carregamento 79 s   ->  uma vez por sessao, nao por imagem
```

Para referência, o print da outra BC-250 marcava 35,1 s para os mesmos 8 steps —
provavelmente com servidor quente. Mesmo em fp32, que é o dtype mais caro
possível, **3,23 s/step contra 4,39 s/step**.

O mesmo hardware faz **0,59 s/step** em SD 1.5 com fp16. A diferença de 5× é a
precisão que o modelo exige, não a placa.

### Workflow

[`../../bc250-grimoire/rocm-test/wf_zimage.json`](../tools/) — três diferenças
obrigatórias em relação ao print, documentadas dentro do próprio arquivo:

- **`scheduler = simple`**, não `discrete`. O `discrete` não existe nesta versão
  do ComfyUI (43c64b63).
- **`EmptySD3LatentImage`**, não `EmptyLatentImage`. Latent format do Flux, 16
  canais; o nó do SD 1.5 entrega 4.
- **`type = qwen_image`** no `CLIPLoaderGGUF`. A lista não tem `z_image`, mas o
  ComfyUI detecta pelo state dict (`TEModel.QWEN3_4B` → `z_image.te`).

---

## Travar o clock em 2000 MHz

`power_dpm_force_performance_level` **não funciona nesta placa** — a SMU recusa,
e o dmesg diz por quê:

```
amdgpu: Failed to set performance level 2
amdgpu: Unsupported clock type
amdgpu: Invalid sclk! Valid sclk range: 1000MHz - 2000Mhz
```

O caminho é o `cyan-skillfish-governor-smu`, que fala com a SMU direto. Mas o
binário `cyan-skillfish-performance-mode --fixed-frequency` é só cliente D-Bus, e
o serviço sobe com `D-Bus service listening disabled in configuration`.

O que funciona é a config, em `/etc/cyan-skillfish-governor-smu/config.toml`,
**antes** do primeiro `[[safe-points]]` (em TOML tudo que segue um
array-of-tables pertence a ele):

```toml
[frequency-range]
min = 2000
max = 2000
```

Assim ele nasce travado, sem janela de governo livre. Resultado:

```
antes   1500 MHz   831 mV   53 °C   63 W
depois  2000 MHz   924 mV   55 °C   77 W
```

O serviço está `disabled` — não sobe no boot. `systemctl enable` para persistir.

---

## O que mudou, e o que eu não sei

O stack **não** mudou: ComfyUI de março, torch de 3 de agosto, ROCm de junho.
Os docs 03 e 04 foram escritos ontem, neste mesmo stack. Então a virada veio de
configuração nossa.

O candidato concreto é o **`vm_fragment_size`**. O arquivo de boot dizia `9`
(fragmentos de 2 MiB), mas o kernel rodando tinha `4` (64 KiB) — divergência que
já existia antes de hoje. Hoje o `4` foi fixado no arquivo.

Isso importa porque toda a corrupção de [17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md)
aparece em granularidade de página grande: mapeamentos alinhados em 2 MiB, PTEs
com `incr=2097152`, corrupção em blocos de 512 KiB a 6 MiB.

**É hipótese, não conclusão.** Não há registro do cmdline de ontem, e é o oitavo
candidato do dia — sete morreram, dois deles depois de terem sido apresentados
como conserto. O A/B é barato: dois boots e ~12 execuções de
`tools/hipmalloc_cru.py`.

---

## Retratações

**`expandable_segments` nunca esteve ativo.** O log do ComfyUI mostra:

```
UserWarning: expandable_segments not supported on this platform
  (HIPAllocatorConfig.h:40)
```

Nosso PyTorch é build local e não tem a feature compilada. A medida de 4/4 sujas
contra 1/4 que foi apresentada como efeito dele era variação — a variável estava
sendo ignorada nos dois braços.

**O `--fp16-vae` do doc 04 aparece como falho**, mas hoje funcionou. A diferença
não foi identificada; ver a seção acima.

---

## Ferramentas

| arquivo | o que faz |
|---|---|
| `tools/run_alvo.sh` | ComfyUI com VAE/warmup/alocador parametrizados |
| `tools/run_wf.sh` | roda um workflow arbitrário e valida por estatística de pixel |
| `~/bc250-grimoire/post_discord.sh` | posta o resultado no webhook do grupo |

O detector de erro dos dois runners só olha o log **a partir da submissão** — o
boot do ComfyUI imprime `Failed to import comfy_kitchen` e
`No module named torchaudio`, que são ruído conhecido e faziam o teste abortar
em 0,0 s sem esperar a imagem.

Imagem válida é validada por estatística, não por existir: corrompida dá
`std ~10` e ~2000 cores, boa dá `std ~75` e ~100k.
