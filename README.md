# Stable Diffusion on the AMD BC-250 (gfx1013)

**Working ComfyUI image generation on an AMD BC-250 mining board.**

![512x512 generated on a BC-250](proof/coffee-512x512.png)

512×512, SD 1.5, 24 steps (DPM++ 2M / Karras), **14 seconds** per image on a
warm server, VAE on the GPU and no warmup. Generated on the board this repo is
about. Z-Image Turbo runs too — see [Results](#results).

> **Companion repo:** [**bc250-core-cu-unlock**](https://github.com/GabriWar/bc250-core-cu-unlock)
> — unlocks the hidden silicon on this board: **8 CPU cores** instead of 6 and
> **40 GPU compute units** instead of 24. The dormant cores are not fused off,
> only masked by a writable SMU register. Ships a custom BIOS with **every menu
> option unlocked** plus the extra cores, so the settings are there without
> flipping anything at runtime. Measured +26.9% on 7-zip at stock clocks.

---

## What this is

The BC-250 is a PS5 APU (Oberon, `gfx1013` / "Cyan Skillfish") sold as a mining
board. ROCm nominally runs on it; heavy compute does not — every attempt hits a
GPU fault, and often takes the whole machine down with it.

**The core defect is a virtual-to-physical translation fault, and as of
2026-08-07 there is a patch that stops it from being generated.** The GPU
resolves a virtual address to different physical memory than its own page tables
specify — specifically, to whatever that same address mapped to in an *earlier*
generation, because `hipFree` asks for a TLB invalidation that this board never
performs. Rebuilding the runlist on unmap makes the firmware invalidate for
real: **13 of 18 dirty runs become 0 of 18**, p = 3.7 × 10⁻⁶.

See [24 — Flushing the compute TLB by rebuilding the runlist](docs/24-flushing-the-tlb-by-rebuilding-the-runlist.md)
and [`patches/bc250-flush-tlb-by-runlist.patch`](patches/bc250-flush-tlb-by-runlist.patch).

It is **not finished**: heavier workloads and preemption under sustained load
are untested, and the patch currently rebuilds the runlist on every unmap when
only the reused-VA case needs it — there is real performance still to recover.
Everything else in this repo is either a workaround for the defect, or a
measurement that narrowed it down. See
[the open problem](#the-open-problem-the-gpu-resolves-va-to-the-wrong-pa).

This repo documents getting Stable Diffusion working on one, with:

- every patch, config and artifact needed to reproduce it
- **two kernel patches**, one of which is a NULL-deref fix for upstream `amdgpu`
- what we measured, including the parts that are still broken
- the hypotheses we **refuted**, with the evidence that killed them

Everything here was measured on real hardware across several sessions
(2026-08-04). Where something is assumed rather than measured, it says so.

---

## The core defect: the GPU resolves VA to the wrong PA

**This was the main defect on this board. As of 2026-08-07 the mechanism is
measured end to end and there is a patch that stops it from being generated.**

> **The chain, every link measured:**
> `hipFree` unmaps and asks for a TLB invalidation → the invalidation never
> happens, because `gmc_v10_0_flush_gpu_tlb_pasid()` searches
> `mmATC_VMID*_PASID_MAPPING`, which gfx10 under hardware scheduling never
> writes → `hipMalloc` reuses the same virtual address with new physical
> memory → the GPU keeps translating through the **previous generation's**
> mapping of that address.
>
> The last link is direct, not inferred: for **15 of 15 failing pages across 3
> runs**, the physical address the GPU used is exactly what that same VA
> pointed to earlier. See [docs/24](docs/24-flushing-the-tlb-by-rebuilding-the-runlist.md),
> [docs/23](docs/23-it-is-the-translation.md), [docs/22](docs/22-the-page-table-cache-is-innocent.md).

A virtual address handed to the GPU resolves to physical memory that is not the
one its own page tables point at. Two live `hipMalloc` allocations — distinct
buffer objects, disjoint virtual ranges — come out sharing memory as far as the
GPU is concerned. Writing one changes the other.

Measured 2026-08-06. It is **not** MIOpen, not the copy path, and not any
software layer. Full write-up in
[docs/17](docs/17-a-gpu-le-fora-da-propria-tabela-de-pagina.md).

### The CPU reads correctly. The GPU does not.

Same pointer, same moment, four phases:

| phase | who writes | who reads | result |
|---|---|---|---|
| 1 | CPU | CPU | **correct** — host mappings are self-consistent |
| 2 | CPU | GPU | **wrong** — GPU returns another block's data |
| 3 | GPU | CPU | **wrong** — CPU still sees its own earlier value |
| 4 | GPU | GPU | **wrong** — consistently another block's memory |

The CPU is never affected, in either direction. `/proc/pid/maps` shows the two
allocations at different offsets into `/dev/dri/renderD128` — different BOs,
different physical memory — and the CPU honors that. The GPU does not.

### Four independent observers of the same address

| observer | path | result |
|---|---|---|
| PTE the driver wrote | `amdgpu_vm_set_ptes` tracepoint | **correct** |
| PTE sitting in memory | physical read of VRAM | **correct** |
| data at the PA that PTE points to | `debugfs/dri/1/amdgpu_vram`, no VA involved | **correct** |
| what the GPU delivers | page table → PA | **wrong** |

The page tables are right, the physical memory is right, and the GPU still
returns something else. The FB base calibrated at `0x170000000` against 11 of 11
blocks, which validates the method and not just the failing case.

### What triggers it

| condition | effect |
|---|---|
| no prior GPU activity | 0 of 6 runs |
| with prior GPU activity | 5 of 6 |
| allocation only, no kernels | 0 of 3 |
| kernels only, no new allocation | 0 of 3 |
| allocation and kernels interleaved | 3 of 3 |
| full serialization (`HIP_LAUNCH_BLOCKING=1`, `AMD_SERIALIZE_*=3`) | reproduces unchanged |
| **`bc250_flush_by_runlist=1`** | **0 of 18** — against 13 of 18 stock, p = 3.7e-06 |

It needs both halves. It reproduces with everything serialized, so it is **not a
race**. Per process the outcome is bimodal — a process either aliases on nearly
every cycle or on none — and once established it is deterministic and survives a
forced TLB invalidation.

### Reproducer and tools

[`tools/hipmalloc_cru.py`](tools/hipmalloc_cru.py) — ~2 minutes, hits in roughly
83% of runs. No PyTorch in the test itself: raw `hipMalloc`, `hipMemset`,
`hipDeviceSynchronize` and `hipMemcpy` through `ctypes`. PyTorch only warms the
GPU into the state where the defect appears.

```
hipmalloc_cru.py <churn rounds> <warmup mode> [cpu|segurar]
   warmup modes: orig | so-alloc | so-kernel | sem-aquecer
```

| tool | what it decides |
|---|---|
| [`tools/matriz_cpu_gpu.py`](tools/matriz_cpu_gpu.py) | the who-writes × who-reads matrix above, block by block |
| [`tools/triangular_fisico.py`](tools/triangular_fisico.py) | triangulates VA / GPU / physical address, calibrates the FB base |
| [`tools/coletar_pares.py`](tools/coletar_pares.py) | scale collection of (expected PA, delivered PA) pairs |
| [`tools/sobreposicao.py`](tools/sobreposicao.py) | detects the aliasing with PyTorch tensors instead of raw HIP |
| [`tools/quem_erra_escrita_ou_leitura.py`](tools/quem_erra_escrita_ou_leitura.py) | separates a bad write from a bad read |
| [`tools/trace_matriz.sh`](tools/trace_matriz.sh) | captures amdgpu VM tracepoints alongside the reproducer |
| [`tools/ab_flush_vmids.sh`](tools/ab_flush_vmids.sh) | A/B of `bc250_flush_mapped_vmids` — **measured a no-op here**: its guard is the same empty ATC query |
| [`tools/pa_anterior.py`](tools/pa_anterior.py) | was the delivered PA ever *this VA's* translation? the proof of birth |
| [`tools/cura_propria.py`](tools/cura_propria.py) | can a process repair its own bad translation? (no) |
| [`tools/cura_por_pressao.py`](tools/cura_por_pressao.py) | eviction pressure, or coupling to the same PA? |
| [`tools/oscila.py`](tools/oscila.py) | per-read or per-page — classifies with 20 reads, never one |
| [`tools/run_wf.sh`](tools/run_wf.sh) | runs a ComfyUI workflow and validates output by pixel statistics |

Two root-only helpers live outside the repo, in `~/bc250-grimoire/`, because
`/sys/kernel/debug/dri/1/amdgpu_vram` is root-readable only: `varrer_vram.py`
finds which physical offset a marker actually lives at, and `varrer_ptes.py`
finds the page-table entries pointing at a given PA.

A valid image is validated by pixel statistics, never by existing: a corrupted
one gives `std ~10` and ~2000 colors, a good one `std ~75` and ~100k.

### Thirteen hypotheses, each killed by its own measurement

MIOpen · the compute queue · ROCclr staging and its size · SDMA · races between
transfers · host buffer lifetime · the PyTorch allocator · the host mapping ·
`bc250_flush_mapped_vmids` (5/6 vs 5/6, counterbalanced, same boot) ·
`vm_update_mode` CPU vs SDMA (10/12 vs 5/6) · TTM eviction (12288 MB VRAM, 19 MB
in use, both evict counters at zero) · the page tables themselves · L2 writeback.

None of these fell to argument. Each has the number that killed it in
[docs/17](docs/17-a-gpu-le-fora-da-propria-tabela-de-pagina.md).

### The fix, and what it still owes

`bc250_flush_by_runlist=1` rebuilds the runlist on unmap. A process cannot clear
its own bad translation — 60 re-reads, 32 fresh pages and a compute dispatch all
leave the page 20/20 wrong — but the activation of a *second* process clears it
instantly. That activation is a runlist rebuild, and it is the only invalidation
that works on this silicon: both MMIO routes go unacknowledged and stall the
translation unit.

```
stock     13/18 dirty
runlist    0/18 dirty      Fisher exact, one-tailed: p = 3.7e-06
```

36 runs counterbalanced inside a single boot, each stamped with its own
`execute_queues_cpsch` count from ftrace. Raw ComfyUI + Z-Image Turbo, with no
conv fix and no warmup, generates a valid image in 97 s with 287 forced runlist
cycles and zero board errors.

**Still owed:** preemption under sustained heavy GEMM is untested — an outside
report describes `cp queue preemption time out` on this board, and
`unmap_queues_cpsch()` escalates that straight to a GPU reset. And the patch
rebuilds the runlist on *every* unmap when only the reused-VA case can produce a
stale entry, so there is real performance to recover.

**Superseded by the above:** 2266 (expected PA, delivered PA) pairs were once
collected looking for an address invariant and none was found — raw data in
[`docs/data-pares-aliasing.tsv`](docs/data-pares-aliasing.tsv). There is no
invariant because the delivered address is not a function of the current one: it
is the *previous* translation of the same VA. VA non-reuse was also written off
at the time, on 1 of 4 against 2 of 4 — an n that decides nothing, and worth
revisiting now that the mechanism is known.

### A lead that did not survive

The BC-250 community briefly circulated a ROCm setup guide listing two kernel
patches. One is `flush_pasid_uses_kiq = false`, which this repo already carries.
The other changed a golden register to
`mmGB_ADDR_CONFIG = 0x00100044`. `GB_ADDR_CONFIG` computes pipe interleave and
shader-engine address swizzle, so a wrong engine count there would produce
exactly this signature.

**The author retracted it four days later**, saying the stock `0x00000044` is
correct and the change was his mistake. Recorded here so nobody else chases it.
This repo keeps the stock value.

The one untested angle left is a VRAM size sweep: the corruption rate tracked
VRAM size in early measurements — 20.4% at 512 MB, 15.7% at 4 GB, 12.0% at
12 GB — and nothing has explained that yet.

### Reported by others, not verified here

Other BC-250 owners report that this used to work on an **older kernel and an
older ROCm**, and that KIQ exit handling moved from software to firmware between
kernel versions. If either holds, the fault is a regression with a bisectable
first-bad-commit rather than a property of the silicon — which would change the
whole approach.

We have not tested any of it. Collected in
[docs/19](docs/19-community-reports-untested.md), with what it would take to
check each claim.

---

## Results

### SD 1.5 — no warmup, VAE on the GPU

| | |
|---|---|
| Resolution | 512×512 |
| Model | SD 1.5 (`cyberrealistic_final`) |
| Sampler | DPM++ 2M, Karras, 24 steps |
| VAE | **on the GPU** (`--fp16-vae`) |
| Warmup | **none** (`BC250_WARMUP=0`) |
| Wall clock, warm server | **14.1 / 14.2 / 14.5 s** |
| Wall clock, cold server | 37.5 / 41.7 / 39.0 / 38.7 s (model load) |
| Page faults / GPU resets | 0 |

Seven runs, all valid, byte-identical within each seed. Against 33 s with
`--cpu-vae`, of which ~15 s was the VAE alone on the CPU.

The GPU VAE is correct, not just faster: same seed decoded on CPU and on GPU
differs by a **mean of 0.729 / 255**. Compare
[`proof/coffee-512x512.png`](proof/coffee-512x512.png) (CPU) against
[`proof/sd15-gpu-vae-512x512.png`](proof/sd15-gpu-vae-512x512.png) (GPU).

### Z-Image Turbo

![Z-Image Turbo on a BC-250](proof/z-image-turbo-512x512.png)

| | |
|---|---|
| Model | `z-image-turbo-Q5_K_S.gguf` + `Qwen3-4B-Instruct-2507-Q5_K_S.gguf` |
| Sampler | euler, simple, CFG 1, 8 steps, 512×512 |
| dtype | **fp32 forced** — bf16 errors out, fp16 returns a flat image |
| Sampling | **25 s → 3.23 s/step** |

Another BC-250 in the community posted 4.39 s/step for the same 8 steps. Note
this is fp32, the most expensive dtype this silicon supports — **bf16 does not
exist here at all**, and fp16 fails silently on this model with exit code zero
and `std=0.0`.

Setup, dtype ladder and the 2000 MHz clock lock in
[docs/18](docs/18-comfyui-working-and-z-image.md).

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
4. ~~**A GPU warmup at startup**~~ — **no longer required.** It was a workaround
   for the translation fault; with `bc250_flush_by_runlist=1`, a raw run with
   `BC250_WARMUP=0` and no conv fix produces a valid image. Do not add warmups:
   `bc250_vae_warmup` was measured to be actively harmful. Superseded text:
   ~90 kernels touched before any model loads.
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
patches/      kernel and userspace patches, as applicable diffs
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
| [01-the-bug.md](docs/01-the-bug.md) | the core compute bug — **root cause found, see 24** |
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
| [13-naive-solver-and-measurement.md](docs/13-naive-solver-and-measurement.md) | the naive solver, and how it was measured |
| [14-h2d-copy-corruption.md](docs/14-h2d-copy-corruption.md) | host-to-device copy corruption — attribution later superseded by 17 |
| [15-bf16-e-o-que-o-warmup-nao-explica.md](docs/15-bf16-e-o-que-o-warmup-nao-explica.md) | bf16 kills the VAE on the first conv; what the warmup does not explain |
| [16-wgp-registers-vem-do-vbios.md](docs/16-wgp-registers-vem-do-vbios.md) | the WGP registers already come unlocked from the VBIOS |
| **[17-a-gpu-le-fora-da-propria-tabela-de-pagina.md](docs/17-a-gpu-le-fora-da-propria-tabela-de-pagina.md)** | **the GPU reads outside its own page table — the defect stated properly** |
| [18-comfyui-working-and-z-image.md](docs/18-comfyui-working-and-z-image.md) | ComfyUI without warmup, VAE on the GPU, Z-Image Turbo |
| [19-community-reports-untested.md](docs/19-community-reports-untested.md) | community reports, none verified here |
| [20-why-the-compute-path-is-uncovered.md](docs/20-why-the-compute-path-is-uncovered.md) | why the compute path is uncovered — **superseded by 21, retracted in place** |
| [21-the-compute-tlb-is-never-invalidated.md](docs/21-the-compute-tlb-is-never-invalidated.md) | the compute TLB is never invalidated |
| [22-the-page-table-cache-is-innocent.md](docs/22-the-page-table-cache-is-innocent.md) | the L2 page-table cache is innocent; forcing invalidation stalls the board |
| [23-it-is-the-translation.md](docs/23-it-is-the-translation.md) | it is the translation, measured — a second mapping reads the same memory correctly |
| **[24-flushing-the-tlb-by-rebuilding-the-runlist.md](docs/24-flushing-the-tlb-by-rebuilding-the-runlist.md)** | **the fix: rebuild the runlist on unmap. 13/18 dirty → 0/18** |
| [25-exact-stack-as-measured.md](docs/25-exact-stack-as-measured.md) | the exact stack this was measured on — kernel, ROCm, PyTorch, every patch |
| [26-the-other-bc250-patch-set.md](docs/26-the-other-bc250-patch-set.md) | DryhoppedIPA's Vulkan patch set: what it confirms, where we disagree, what we want to borrow |
| **[27-the-serialization-flags-do-nothing.md](docs/27-the-serialization-flags-do-nothing.md)** | **the five serialization env vars provide no protection; the runlist patch is what holds. 0/16 vs 5/6** |
| [28-the-sdma0-boot-message-is-not-a-lost-interrupt.md](docs/28-the-sdma0-boot-message-is-not-a-lost-interrupt.md) | the SDMA0 boot warning is an init-order artifact, not lost silicon — and three claims this repo got wrong |
| **[29-the-sdma-firmware-is-the-bug.md](docs/29-the-sdma-firmware-is-the-bug.md)** | **AMD's cyan_skillfish2 SDMA firmware never drives the user queues. navi12's does. 0 bytes → 4 MiB, +20% H2D** |

## Other people's work, vendored

[`third_party/bc250-gfx1013-fix/`](third_party/bc250-gfx1013-fix/) is a verbatim
snapshot of [DryhoppedIPA/bc250-gfx1013-fix](https://github.com/DryhoppedIPA/bc250-gfx1013-fix)
at commit `65ef06ddc4d1`, kept so those patches survive if the upstream repository
goes away. It is **not our work**: kernel patches GPL-2.0, everything else MIT,
licence text and attribution intact. See its `PROVENANCE.md`, and read
[docs/26](docs/26-the-other-bc250-patch-set.md) before applying any of it on top of
ours — one of its patches edits the same function we do.

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

**Understood, as of 2026-08-07:** the root cause. `hipFree` asks for a TLB
invalidation this board never performs, so a reused virtual address keeps
translating through its previous mapping — measured directly on 15 of 15 failing
pages. `bc250_flush_by_runlist=1` stops it being generated.

The paragraph below is the pre-2026-08-07 state, kept because the warmup story it
describes was the first clue.

**Was not understood:** the root cause. We know *that* the first heavy GPU phase
works and the next one fails, and *that* a warmup avoids it. We do not know
*why*. Six explanations were proposed and refuted during this session; they are
all in [07-refuted.md](docs/07-refuted.md) so nobody has to rediscover them.

~~The most promising open lead~~ — **superseded by the measured mechanism
above.** It is in [01-the-bug.md](docs/01-the-bug.md): the AQL
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
