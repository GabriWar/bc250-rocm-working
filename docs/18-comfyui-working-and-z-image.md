# ComfyUI without the warmup, VAE on the GPU, and Z-Image running

Measured 2026-08-06, after the investigation in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md). This **supersedes the
practical conclusion** of [03-warmup.md](03-warmup.md) and [04-vae.md](04-vae.md):
the warmup is no longer needed and the VAE runs on the GPU.

---

## SD 1.5: the configuration that works

```
cyberrealistic_final.safetensors
    --fp16-vae          VAE on the GPU
    BC250_WARMUP=0      no warmup
    BC250_CONV_FIX=1
```

Seven runs, every one valid and **byte-identical to each other**:

```
seed=111   37.5s / 41.7s / 39.0s / 38.7s   std=74.4  colors=117077
seed=222   14.1s / 14.2s / 14.5s           std=75.2  colors=90173
```

The first run of each server loads the model; the second is the real number.
**14 s for 24 steps at 512×512** with the VAE on the GPU, against 33 s with
`--cpu-vae`, of which ~15 s was the VAE alone on the CPU.

Zero page faults across all of them.

![SD 1.5 with the VAE on the GPU](../proof/sd15-gpu-vae-512x512.png)

### The GPU VAE is correct, not just faster

Same seed, same workflow, same latent — one decoded on the CPU, one on the GPU:

| | |
|---|---|
| pixels differing | 171,558 of 262,144 |
| **mean difference** | **0.729 / 255** |
| max difference on any channel | 86 |

Visually identical. The differences are per-pixel numerical noise, exactly what
fp32 against fp16 produces. Compare
[`proof/coffee-512x512.png`](../proof/coffee-512x512.png) (CPU VAE) with
[`proof/sd15-gpu-vae-512x512.png`](../proof/sd15-gpu-vae-512x512.png) (GPU VAE).

---

## Z-Image Turbo

The model circulating in the community: `z-image-turbo-Q5_K_S.gguf` (4.9 GB) with
`Qwen3-4B-Instruct-2507-Q5_K_S.gguf` as the text encoder and `ae.safetensors` as
the VAE. Needs [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF), which
brings `UnetLoaderGGUF` and `CLIPLoaderGGUF`.

![Z-Image Turbo in fp32](../proof/z-image-turbo-512x512.png)

### The dtype ladder

Z-Image inherits from `Lumina2` and declares:

```python
supported_inference_dtypes = [torch.bfloat16, torch.float32]
memory_usage_factor = 2.8
latent_format = latent_formats.Flux      # 16 channels
```

Three attempts, three different outcomes:

| dtype | result |
|---|---|
| bf16 (default) | **fails** — `HIPBLAS_STATUS_INTERNAL_ERROR`, `HIP_R_16BF` on all three operands |
| fp16 (`--fp16-unet --fp16-vae`) | **silent garbage** — finishes with no error, `std=0.0`, one colour |
| fp32 (`--fp32-unet --fp32-vae`) | **works** — `std=59.8`, 71,427 colours |

fp16 is the dangerous one: exit code zero, no page fault, no exception, and a
flat image. Only the pixel statistics catch it. bf16 has the same dynamic range
as fp32 with fewer mantissa bits; fp16 saturates at 65504 and this model's
activations overflow it.

**fp32 has full native support on this board.** It is not a fallback for missing
support — it is the correct dtype that remained. What the silicon lacks is bf16,
and only bf16.

### Measurement

```
sampling   25 s   ->  3.23 s/step   (8 steps, euler, simple, CFG 1, 512x512)
loading    79 s   ->  once per session, not per image
```

For reference, another BC-250 in the community posted 35.1 s for the same 8
steps, most likely on a warm server. Even in fp32, the most expensive dtype
available, **3.23 s/step against 4.39 s/step**.

The same hardware does **0.59 s/step** on SD 1.5 in fp16. That 5× gap is the
precision this model demands, not the board.

### Workflow

[`data-wf-zimage.json`](data-wf-zimage.json) — three mandatory differences from
what the community posts, each documented inside the file:

- **`scheduler = simple`**, not `discrete`. `discrete` does not exist in this
  ComfyUI (43c64b63).
- **`EmptySD3LatentImage`**, not `EmptyLatentImage`. Flux latent format, 16
  channels; the SD 1.5 node hands back 4.
- **`type = qwen_image`** on `CLIPLoaderGGUF`. The list has no `z_image`, but
  ComfyUI detects the encoder from the state dict
  (`TEModel.QWEN3_4B` → `z_image.te`), so the field is only a hint.

---

## Locking the GPU clock at 2000 MHz

`power_dpm_force_performance_level` **does not work on this board**. The SMU
refuses it and the kernel says why:

```
amdgpu: Failed to set performance level 2
amdgpu: Unsupported clock type
amdgpu: Invalid sclk! Valid sclk range: 1000MHz - 2000Mhz
```

The path is `cyan-skillfish-governor-smu`, which talks to the SMU directly. But
`cyan-skillfish-performance-mode --fixed-frequency` is only a D-Bus client, and
the service starts with `D-Bus service listening disabled in configuration`.

What works is the config, in `/etc/cyan-skillfish-governor-smu/config.toml`,
placed **before** the first `[[safe-points]]` — in TOML everything following an
array-of-tables belongs to it:

```toml
[frequency-range]
min = 2000
max = 2000
```

That starts locked, with no window of free governing:

```
before   1500 MHz   831 mV   53 °C   63 W
after    2000 MHz   924 mV   55 °C   77 W
```

The service ships `disabled`, so it does not start at boot. `systemctl enable`
to persist.

---

## What changed, and what I do not know

The stack did **not** change: ComfyUI from March, torch from 3 August, ROCm from
June. Docs 03 and 04 were written the day before, on this same stack. So the
turnaround came from our own configuration.

The concrete candidate is **`vm_fragment_size`**. The boot entry said `9`
(2 MiB fragments) while the running kernel had `4` (64 KiB) — a divergence that
predates today. Today the `4` was pinned in the file.

It matters because all the corruption in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md) shows up at large-page
granularity: mappings aligned and sized in 2 MiB, PTEs with `incr=2097152`,
corruption in blocks from 512 KiB to 6 MiB.

**This is a hypothesis, not a conclusion.** There is no record of yesterday's
cmdline, and it is the eighth candidate of the day — seven died, two of them
after being presented as the fix. The A/B is cheap: two boots and ~12 runs of
`tools/hipmalloc_cru.py`.

---

## Retractions

**`expandable_segments` was never active.** The ComfyUI log says so:

```
UserWarning: expandable_segments not supported on this platform
  (HIPAllocatorConfig.h:40)
```

Our PyTorch is a local build without that feature compiled in. The 4/4 dirty
against 1/4 that was presented as its effect was variance — the variable was
being ignored on both arms.

**`--fp16-vae` appears as failing in doc 04**, yet worked today. The difference
was not identified; see the section above.

---

## Tools

| file | what it does |
|---|---|
| [`tools/run_alvo.sh`](../tools/run_alvo.sh) | ComfyUI with VAE, warmup and allocator parameterised |
| [`tools/run_wf.sh`](../tools/run_wf.sh) | runs an arbitrary workflow, validates by pixel statistics |

The error detector in both only reads the log **from submission onward** —
ComfyUI's boot prints `Failed to import comfy_kitchen` and
`No module named torchaudio`, which are known noise and made the test abort at
0.0 s without waiting for the image.

A valid image is validated by statistics, never by existing: a corrupted one
gives `std ~10` and ~2000 colours, a good one `std ~75` and ~100k.
