# The exact stack, as measured

Every version, patch and setting on the machine that produced the results in
this repository. Collected from the running system on 2026-08-07, not from
memory — each line came out of `/proc`, `/sys`, `pacman -Q` or the source tree.

If you are trying to reproduce something here and it behaves differently, this
is the page to diff against.

---

## Hardware, with both unlocks active

```
CPU     AMD BC-250 (PS5 Oberon APU)
        8 cores / 16 threads      <- unlocked, stock is 6
        800 - 3200 MHz

GPU     gfx1013 "Cyan Skillfish"
        SE 2, SH per SE 2, CU per SH 10, active_cu_number 40   <- unlocked, stock is 24
        simd_count 80, simd_per_cu 2
        max_engine_clk 2000 MHz

VRAM    12288M   0x000000F400000000 - 0x000000F6FFFFFFFF
        BAR 12288M (full-size BAR, no 256M window)
```

Both unlocks come from the companion repository
[bc250-core-cu-unlock](https://github.com/GabriWar/bc250-core-cu-unlock) — the
dormant cores are not fused off, only masked by a writable SMU register, and it
ships a BIOS with them enabled. **Everything below was measured with 40 CU and
8 cores active.** Results on a stock 24 CU / 6 core board may differ, and none
of the numbers here have been re-measured on one.

---

## Kernel

```
7.0.12-1-cachyos-bore-lto-bc250
amdgpu srcversion 84ED75F8EA3B9E26CF22A9A
built with: make CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1 KBUILD_MODPOST_WARN=1
```

### Command line, verbatim

```
split_lock_detect=off pcie_aspm=off transparent_hugepage=madvise
amdgpu.ppfeaturemask=0xfffd3fff
amdgpu.vm_fragment_size=4
amdgpu.vm_update_mode=3
amdgpu.noretry=1
amdgpu.gttsize=1024
ttm.pages_limit=262144
amdgpu.bc250_skip_sdma0=1
amdgpu.bc250_dead_gpu_guard=1
mitigations=off clearcpuid=514 nmi_watchdog=0 audit=0
workqueue.power_efficient=0
zswap.enabled=0 zswap.max_pool_percent=20 zswap.compressor=lz4
rw rootflags=subvol=/@ root=UUID=...
```

Two of these matter more than they look:

- **`amdgpu.vm_update_mode=3`** — the CPU writes the page tables for both
  graphics and compute. Much of the investigation depends on this, because it
  is what makes the tables readable and verifiable from the host.
- **`amdgpu.vm_fragment_size=4`** — changing it changes the page-table fragment
  size, and the defect has 2 MiB granularity. Measurements taken at a different
  value are not comparable.

There are boot entries in `refind.conf` that differ in these. Check
`/proc/cmdline`, not the config file — they drifted apart once and it silently
changed six parameters at a time.

### amdgpu changes, by file

Not a clean patch series; this is an instrumented tree. Reference counts of
`bc250` mentions per file, so you can see where the weight is:

| file | mentions | what lives there |
|---|---|---|
| `gmc_v10_0.c` | 40 | TLB invalidation, the KIQ gates, the dead-GPU guard, the VMID/ATC dump |
| `gfxhub_v2_0.c` | 25 | L2 page-table cache knobs (`FORCE_MISS`, PDE0 tag mode) |
| `gfx_v10_0.c` | 18 | `COMPUTE_PGM_LO/HI` dump on page fault |
| `amdgpu_vm_pt.c` | 16 | the debugfs page-table walker |
| `kfd_device_queue_manager.c` | 15 | **the runlist flush — the actual fix** |
| `amdgpu_vm.c` | 13 | flush tracing, sequence-counter knob |
| `mmhub_v2_0.c` | 12 | the same L2 knobs, MMHUB side (SDMA reaches memory here) |
| `amdgpu_ttm.c` | 5 | NULL check, `apu_prefer_gtt` knob |
| `kfd_chardev.c` | 1 | the one call site of the runlist flush |
| `kfd_device_queue_manager.h` | 2 | its declaration |
| `amdgpu_amdkfd_gpuvm.c` | 1 | PID → VM lookup for the walker |

### Module parameters, and what is actually on

All default to 0/off. Only three are set here:

| parameter | value | why |
|---|---|---|
| `bc250_flush_by_runlist` | **1** | **the fix.** Rebuilds the runlist on unmap so the firmware invalidates the compute TLB. See [24](24-flushing-the-tlb-by-rebuilding-the-runlist.md) |
| `bc250_skip_sdma0` | **1** | SDMA0 wedges on the host→device path |
| `bc250_dead_gpu_guard` | **1** | aborts a TLB flush when MMIO reads return all-ones. On this board a read from a dead GPU does not fail — it hangs the CPU on the internal fabric, which has no completion timeout |
| `bc250_cc_write_mode` | 3 | read-only, set at init |
| everything else | 0 / -1 | diagnostic knobs, off |

The full list: `bc250_cc_write_mode`, `bc250_dead_gpu_guard`,
`bc250_dump_pgm`, `bc250_flush_by_runlist`, `bc250_flush_mapped_vmids`,
`bc250_keep_kfd_vram`, `bc250_l2_disable_bigk_opt`, `bc250_l2_force_miss`,
`bc250_l2_pde0_tag_mode`, `bc250_skip_sdma0`, `bc250_tlb_all_hub`,
`bc250_tlb_extra_types`, `bc250_tlb_no_seq_skip`, `bc250_tlb_trace`.

Two of them are **measured no-ops on this board** and are kept only so the
measurement is reproducible: `bc250_flush_mapped_vmids` (its guard is the ATC
query, which never matches) and `bc250_tlb_extra_types`
(`get_invalidate_req()` already sets every `INVALIDATE_L2_*` bit).

---

## ROCm

```
ROCm             7.2.4
rocblas          7.2.4-2
hip-runtime-amd  7.2.4-1.1
rocm-core        7.2.4-1.1
miopen-hip       7.2.4-1
comgr            2:7.2.4-1
hsa-rocr         7.2.4-1.1
```

**No patches to ROCm itself.** What is not stock is rocBLAS's *kernel library*:
80 `gfx1013` files in `/opt/rocm/lib/rocblas/library`, built from Tensile with
gfx1013 added to the architecture lists. Without them a plain matmul aborts with
`Cannot find CO in the bundle ... for ISA: amdgcn-amd-amdhsa--gfx1013:xnack-`.

The build is in [09-building-tensile.md](09-building-tensile.md); a copy of the
result is in `artifacts/rocblas-gfx1013`. The same change is in flight upstream
as ROCm/rocm-libraries#8838, which is independent of this repository.

---

## PyTorch

```
torch    2.10.0a0+git911aa98
hip      7.2.26043
arch     ['gfx1013']         <- built for it natively, no HSA_OVERRIDE
python   3.14.5
```

**No patches to PyTorch.** It is a from-source build targeting gfx1013. There is
no `HSA_OVERRIDE_GFX_VERSION` anywhere — the board reports gfx1013 and the whole
stack is built for gfx1013.

---

## Environment (`/etc/profile.d/bc250-rocm.sh`)

```sh
export GPU_PINNED_MIN_XFER_SIZE=16384
export HSA_ENABLE_SDMA=0
export TORCH_BLAS_PREFER_HIPBLASLT=0
```

**Updated 2026-08-08.** Five more variables used to be here —
`GPU_MAX_HW_QUEUES=1`, `HIP_LAUNCH_BLOCKING=1`, `AMD_SERIALIZE_KERNEL=3`,
`AMD_SERIALIZE_COPY=3`, `AMD_DIRECT_DISPATCH=0` — carried as workarounds from
before the defect had an explanation. They are gone. Measured with the defect
exposed (`bc250_flush_by_runlist=0`), both arms corrupt in the same order of
magnitude: 35 tensors clobbered with them, 25 without. They provide no
protection, and they change nothing measurable on a real workload. See
[27](27-the-serialization-flags-do-nothing.md).

---

## ComfyUI

```
ComfyUI 43c64b63  (2026-03-04)
custom nodes: ComfyUI-GGUF, ComfyUI-Impact-Pack, ComfyUI-Impact-Subpack,
              ComfyUI_IPAdapter_plus, comfyui_controlnet_aux
```

Three BC-250 nodes live in `comfyui/` and are loaded from `custom_nodes/`:

| node | status |
|---|---|
| `bc250_conv_fix.py` | worked around MIOpen conv2d returning wrong numbers. **A raw run with it disabled now produces a valid image** — see below |
| `bc250_no_empty_cache.py` | `torch.cuda.empty_cache()` corrupted exactly the next GPU operation |
| `bc250_warmup.py` | **no longer needed.** `bc250_vae_warmup` specifically was measured to be harmful, not neutral |

---

## The exact run that produced the current result

Z-Image Turbo, deliberately raw — no conv fix, no warmup, no expandable
segments:

```sh
BC250_CONV_FIX=0 tools/run_wf.sh docs/data-wf-zimage.json fp32 0 noexp fp32
```

with `amdgpu.bc250_flush_by_runlist=1`:

```
OK in 97.0s
bc250_zimage_00001_.png   std=59.8   colours=71427
287 forced runlist cycles (ftrace)
0 board errors
```

`std=59.8 / 71427 colours` is the same signature doc 18 recorded for a valid
fp32 Z-Image. A corrupted one gives std ~10 and ~2000 colours; the fp16 failure
mode gives std=0.0 and one colour with exit code zero, which is why output is
validated by pixel statistics and never by the file existing.

`fp32` is not a workaround here: this silicon has **no bf16 at all**, and fp16
saturates on this model. fp32 is the correct dtype that remained.

### Models

```
models/diffusion_models/z-image-turbo-Q5_K_S.gguf        4.9 GB
models/text_encoders/Qwen3-4B-Instruct-2507-Q5_K_S.gguf
models/vae/ae.safetensors
```

---

## Governor

`cyan-skillfish-governor-smu.service`, enabled at boot, currently on the gaming
curve:

```toml
[gpu-usage]        fix-metrics = true, method = "busy-flag", flush-every = 10
[timing.intervals] sample = 500, adjust = 200_000
[timing.ramp-rates] normal = 1, burst = 50
[timing]           burst-samples = 60, down-events = 5
[frequency-thresholds] adjust = 10
[load-target]      upper = 0.80, lower = 0.65
```

A benchmark lock at a fixed 2000 MHz is kept at
`~/bc250-grimoire/config/governor-smu-benchmark-lock.toml`. **Timing numbers in
this repository were taken under the locked profile**, not this curve — a
governor that ramps makes wall-clock comparisons between runs unreliable.

---

## What would invalidate a comparison against this

Learned the hard way, each one after it had already produced a wrong reading:

1. **The corruption rate drifts across a session.** The identical arm measured
   6/10 in the morning and 1/6 in the afternoon, same command line, same binary.
   Only arms interleaved inside a single boot, counterbalanced, are comparable.
2. **`/proc/cmdline` is the truth, not the bootloader config.** They drifted
   apart here and a reboot would have silently changed six parameters at once,
   including `vm_fragment_size`.
3. **A page cannot be classified from a single read.** There is a population of
   intermittent pages; one read misclassifies them, and doing so inverted a
   conclusion twice in one day.
4. **A knob being set is not the knob doing something.** Prove it with a counter
   placed *after* the work — `dev_info_once` before a loop, and
   `kfd_last_flushed_seq` updated before the attempt, both report success while
   nothing happens.
