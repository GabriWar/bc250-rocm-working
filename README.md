# Stable Diffusion on the AMD BC-250 (gfx1013)

**Working ComfyUI image generation on an AMD BC-250 mining board.**

![512x512 generated on a BC-250](proof/coffee-512x512.png)

512×512, SD 1.5, 24 steps (DPM++ 2M / Karras), **33 seconds** per image on a
warm server. Generated on the board this repo is about.

---

## What this is

The BC-250 is a PS5 APU (Oberon, `gfx1013` / "Cyan Skillfish") sold as a mining
board. ROCm nominally runs on it; heavy compute does not — every attempt hits a
GPU fault, and often takes the whole machine down with it.

This repo documents getting Stable Diffusion working on one, with:

- every patch, config and artifact needed to reproduce it
- **two kernel patches**, one of which is a NULL-deref fix for upstream `amdgpu`
- what we measured, including the parts that are still broken
- the hypotheses we **refuted**, with the evidence that killed them

Everything here was measured on real hardware in one session
(2026-08-04). Where something is assumed rather than measured, it says so.

---

## Results

| | |
|---|---|
| Resolution | 512×512 |
| Model | SD 1.5 (`cyberrealistic_final`) |
| Sampler | DPM++ 2M, Karras, 24 steps |
| Sampler throughput | **1.53 it/s** |
| Wall clock, cold server | 40–54 s |
| Wall clock, warm server | **31–34 s** (19.3 s with GPU VAE) |
| Page faults / GPU resets | 0 |

Reproduced across 6 generations. Output is byte-size identical across runs with
the same seed.

Raw GEMM performance, measured through torch:

| shape | time | throughput |
|---|---|---|
| 1024×1024×512 NT fp16 | 0.515 ms | 2.09 TFLOP/s |
| 4096×4096×512 NT fp16 | 2.760 ms | 6.22 TFLOP/s |

Theoretical peak is 7.68 TFLOP/s at 1.5 GHz for the accumulate mode these
kernels actually use — so the large GEMM is at **81% of the applicable ceiling**.
Full breakdown, including why the GPU timer returns negative numbers and why
bfloat16 doesn't work at all, in
[docs/10-performance-and-limits.md](docs/10-performance-and-limits.md).

---

## Open: the GPU reads outside its own page tables

Measured 2026-08-06. The corruption that made every heavy workload unreliable is
**not** in MIOpen, the copy path, or any software layer — all of them were ruled
out by direct measurement. Full write-up in
[docs/17](docs/17-a-gpu-le-fora-da-propria-tabela-de-pagina.md).

Four independent observers of the same address, at the same moment:

| observer | path | result |
|---|---|---|
| PTE the driver wrote | `amdgpu_vm_set_ptes` tracepoint | **correct** |
| PTE sitting in memory | physical read of VRAM | **correct** |
| data at the PA that PTE points to | `debugfs/dri/1/amdgpu_vram`, no VA involved | **correct** |
| what the GPU delivers | page table → PA | **wrong** |

Two live `hipMalloc` allocations, distinct BOs, disjoint virtual addresses, are
treated by the GPU as the same memory. The CPU is never affected and stays
self-consistent throughout. Reproducer in
[`tools/hipmalloc_cru.py`](tools/hipmalloc_cru.py), ~2 minutes, hits in roughly
83% of runs.

Thirteen hypotheses were killed, each by its own measurement, not by argument —
MIOpen, the compute queue, ROCclr staging and its size, SDMA, races between
transfers, host buffer lifetime, the PyTorch allocator, the host mapping,
`bc250_flush_mapped_vmids`, `vm_update_mode`, TTM eviction, the page tables
themselves, and L2 writeback.

**No fix yet.** A scale collection of 2266 (expected PA, delivered PA) pairs
found no address invariant — see
[`docs/data-pares-aliasing.tsv`](docs/data-pares-aliasing.tsv) for the raw data
if you want to look for what we missed. Page retirement and VA non-reuse both
died on measurement.

### A lead that did not survive

The BC-250 community briefly circulated a ROCm setup guide listing two kernel
patches. One is `flush_pasid_uses_kiq = false`, which this repo already carries.
The other changed a golden register:

```c
SOC15_REG_GOLDEN_VALUE(GC, 0, mmGB_ADDR_CONFIG, 0x0c1800ff, 0x00100044),
```

`GB_ADDR_CONFIG` is what the GPU uses to compute addresses — pipe interleave,
shader-engine swizzle, bank distribution — and bit 20 of that delta lands in
`NUM_SHADER_ENGINES`. A wrong engine count there would make distinct addresses
collide on one physical location, which matches the signature above and would
explain why only the GPU sees it.

**The author retracted it four days later**, saying the stock `0x00000044` is
correct and the change was his mistake. Recorded here so nobody else chases it.
This repo keeps the stock value.

**So there is no current lead.** The remaining untested angle is a VRAM size
sweep — the corruption rate tracked VRAM size in early measurements (20.4% at
512 MB, 15.7% at 4 GB, 12.0% at 12 GB), and nothing has explained that yet.

---

## The short version

Five things are required. Miss any one and it fails.

1. **BIOS: UMA Frame Buffer = 4 GB.** The default carve-out is far too small for
   SD 1.5. Probably tunable higher — untested, and 6-8 GB might change the VAE
   situation entirely.
2. **Patched `amdgpu` module** — `flush_pasid_uses_kiq = false`. Without it the
   KIQ fence times out, the CP wedges and the GPU reset fails to restore SDMA.
3. **rocBLAS/Tensile kernels built for gfx1013** — without them even a plain
   `matmul` core-dumps.
4. **A GPU warmup at startup** — ~90 kernels touched before any model loads.
   Without it the sampler fails reliably. Do *not* add more warmups.
5. **VAE decode on the GPU** — use `--fp16-vae`, not `--cpu-vae`. Needs the two
   patches below. See [docs/12-gpu-vae-and-empty-cache.md](docs/12-gpu-vae-and-empty-cache.md).

Plus two strongly recommended:

6. **The conv2d patch** — `comfyui/bc250_conv_fix.py`. MIOpen's convolution
   returns numerically wrong data on this chip, silently, with no error. See
   [docs/11-miopen-conv-corruption.md](docs/11-miopen-conv-corruption.md).
7. **The empty_cache patch** — `comfyui/bc250_no_empty_cache.py`.
   `torch.cuda.empty_cache()` corrupts exactly the next GPU operation, which is
   why VAE decode failed and the UNet never did.
8. **`amdgpu_ttm.c` NULL check** — turns machine-killing kernel panics into
   ordinary process errors.

Full instructions: [docs/00-setup.md](docs/00-setup.md).

---

## Repository layout

```
docs/         what we learned, one topic per file
patches/      three patches, as applicable diffs
artifacts/    the compiled module + rocBLAS gfx1013 kernels
comfyui/      the warmup node and workflows
config/       environment and governor configs
tools/        reproducible test scripts and profiling data
proof/        generated images
```

---

## Documentation

| file | topic |
|---|---|
| [00-setup.md](docs/00-setup.md) | how to reproduce, step by step |
| [01-the-bug.md](docs/01-the-bug.md) | the core compute bug, still unsolved |
| [02-kernel-patches.md](docs/02-kernel-patches.md) | both kernel patches, with the traces |
| [03-warmup.md](docs/03-warmup.md) | the warmup workaround, and its limits |
| [04-vae.md](docs/04-vae.md) | why VAE decode still needs the CPU |
| [05-tensile-tuning.md](docs/05-tensile-tuning.md) | 7 obstacles to tuning Tensile here |
| [06-governor.md](docs/06-governor.md) | clock governor, 1500 → 2050 MHz |
| [07-refuted.md](docs/07-refuted.md) | hypotheses we killed, and how |
| [08-address-corruption.md](docs/08-address-corruption.md) | the corrupted instruction-fetch address |
| [09-building-tensile.md](docs/09-building-tensile.md) | the 7 source changes that make Tensile emit gfx1013 kernels |
| [10-performance-and-limits.md](docs/10-performance-and-limits.md) | TFLOP/s, the broken GPU timer, telemetry, bf16, wave debugging |
| [11-miopen-conv-corruption.md](docs/11-miopen-conv-corruption.md) | **MIOpen's conv2d silently returns wrong numbers — and the fix** |
| [12-gpu-vae-and-empty-cache.md](docs/12-gpu-vae-and-empty-cache.md) | **GPU VAE decode working — `empty_cache()` was corrupting the next op** |

---

## Status: honest version

> **Correctness warning.** MIOpen's `conv2d` returns wrong numbers on this chip
> without reporting any error. Anything generated before applying
> `comfyui/bc250_conv_fix.py` was consistently — and therefore convincingly —
> wrong. See [docs/11-miopen-conv-corruption.md](docs/11-miopen-conv-corruption.md).

**Works:** image generation, reproducibly, at usable speed.

**Does not work:**
- bfloat16 — fails in all four transpose combinations
- Tensile tuning — infrastructure fixed, tuning itself not run

**Not understood:** the root cause. We know *that* the first heavy GPU phase
works and the next one fails, and *that* a warmup avoids it. We do not know
*why*. Six explanations were proposed and refuted during this session; they are
all in [07-refuted.md](docs/07-refuted.md) so nobody has to rediscover them.

The most promising open lead is in [01-the-bug.md](docs/01-the-bug.md): the AQL
packet of a failing dispatch has `completion_signal=0x0`.

---

## Credits

- **neoney** (BC-250 community).
- **Fabi** (BC-250 community).
- **nightcarnage** (BC-250 community).
- **GabriWar** (BC-250 community).

## License

Patches to Linux and Tensile inherit their upstream licenses (GPL-2.0 and MIT
respectively). Everything original here is MIT.
