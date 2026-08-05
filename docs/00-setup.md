# Setup — reproducing this

Every step here was verified by A/B on real hardware. Where a step is optional
or unverified, it says so.

---

## Reference system

```
board     AMD BC-250 (PS5 Oberon APU), 40 CU / 20 WGP
GPU       gfx1013:xnack-  "Cyan Skillfish"   PCI 1002:13fe
kernel    7.0.12-1-cachyos-bore-lto-bc250    (CachyOS, BC-250 patches)
ROCm      7.2.4
torch     2.10.0a0+git911aa98   built for gfx1013
tv        0.25.0+8ac84ee
HIP       7.2.26043
python    3.14.5
```

---

## 1. BIOS: UMA Frame Buffer = 4 GB

**Required.** The board ships with a small UMA carve-out (512 MB seen here).
SD 1.5 needs ~2 GB resident for the UNet alone.

```
BIOS → UMA Frame Buffer Size → 4G
```

Confirm from Linux:

```
$ sudo dmesg | grep "Detected VRAM"
amdgpu 0000:01:00.0: [drm] Detected VRAM RAM=4096M, BAR=4096M
```

**Likely tunable further.** 4 GB is what we ran; we did not test 6 or 8 GB. More
UMA would let the VAE stay resident alongside the UNet and might change the VAE
situation entirely. Untested — if you try it, the result is worth reporting.

---

## 2. Kernel patches

Two patches. The first is required, the second strongly recommended.

### 2a. `flush_pasid_uses_kiq = false` — REQUIRED

[`patches/02-amdgpu-flush-pasid-kiq.patch`](../patches/02-amdgpu-flush-pasid-kiq.patch)

Without it, the KIQ fence times out and the GPU wedges beyond recovery:

```
amdgpu: timeout waiting for kiq fence
amdgpu: TLB flush failed for PASID 5
amdgpu: The cp might be in an unrecoverable state due to an
        unsuccessful queues preemption
amdgpu: GPU reset begin!
amdgpu: [drm:amdgpu_ring_test_helper] *ERROR* ring sdma1 test failed (-110)
amdgpu: resume of IP block <sdma_v5_0> failed -110
```

> **A note on this patch.** During this session it was twice dismissed as
> unnecessary — first as a "no-op", then as "incomplete" — based on reading the
> code rather than testing it. Both readings were wrong. The A/B is
> unambiguous: stock module wedges the GPU, patched module runs a full pipeline
> clean, reverting reproduces the failure. **Test, don't reason.**

Credit: **neoney**, BC-250 community.

### 2b. NULL guard in `amdgpu_ttm_tt_unpopulate` — RECOMMENDED

[`patches/01-amdgpu-ttm-null-check.patch`](../patches/01-amdgpu-ttm-null-check.patch)

`amdgpu_ttm_tt_unpopulate()` walks `ttm->pages[]` and writes
`pages[i]->mapping` with no NULL check. When a GPU command aborts midway the BO
is left partially populated, and cleanup dereferences NULL:

```
RIP: amdgpu_ttm_tt_unpopulate+0x77/0xd0 [amdgpu]
CR2: 0000000000000018
RCX: 0000000000000000
Kernel panic - not syncing: Fatal exception
```

`CR2=0x18` is the offset of `struct page::mapping` — confirming `pages[i]` was
NULL.

This turned every compute fault into a **hard machine hang**: four in one
session, with unclean shutdowns and lost files. With the guard, the process dies
and the machine keeps running.

The missing check is upstream code, not distro-specific.

### Building

```bash
cd linux-cachyos-bore/src/cachyos-7.0.12-1
patch -p1 < patches/01-amdgpu-ttm-null-check.patch
patch -p1 < patches/02-amdgpu-flush-pasid-kiq.patch
make LLVM=1 -j$(nproc) M=drivers/gpu/drm/amd/amdgpu modules

llvm-strip --strip-debug drivers/gpu/drm/amd/amdgpu/amdgpu.ko
zstd -19 drivers/gpu/drm/amd/amdgpu/amdgpu.ko -o amdgpu.ko.zst
sudo cp amdgpu.ko.zst /lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/
sudo depmod -a
sudo mkinitcpio -p <your-kernel-preset>     # module lives in the initramfs
```

**Verify the right module is loaded** after reboot — `srcversion` must match:

```bash
cat /sys/module/amdgpu/srcversion
sudo modinfo /lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.zst | grep srcversion
```

A prebuilt module for this exact kernel is in
[`artifacts/amdgpu.ko.zst`](../artifacts/amdgpu.ko.zst) — only useful if your
`vermagic` matches.

> Do **not** try to tell the patched module apart by parameter count. Both
> stock and patched CachyOS modules expose 99 parameters — the extras come from
> the distro's own BC-250 patches, not ours. And C comments never reach the
> binary, so grepping for the patch comment proves nothing. Use `srcversion`.

---

## 3. Kernel command line

What we ran (rEFInd stanza):

```
split_lock_detect=off pcie_aspm=off transparent_hugepage=madvise
amdgpu.ppfeaturemask=0xfffd3fff amdgpu.vm_fragment_size=9
amdgpu.vm_update_mode=3 amdgpu.noretry=1
amdgpu.gttsize=13156 ttm.pages_limit=3367936
mitigations=off clearcpuid=514 nmi_watchdog=0 audit=0
workqueue.power_efficient=0
```

**Do not set `amdgpu.sched_policy=2`.** We tried it. It does not help — it
*replaces* one failure mode with another (`cp queue preemption time out`,
`Failed to quiesce KFD`, `Resetting wave fronts (nocpsch)`). Removed.

---

## 4. rocBLAS / Tensile kernels for gfx1013 — REQUIRED

Stock ROCm ships no gfx1013 Tensile kernels. Without them **even a 512×512
`matmul` core-dumps** — rocBLAS tries to load `TensileLibrary_lazy_gfx942.dat`
and dies.

Verified by removing the 80 files and watching it crash, then restoring.

Prebuilt: [`artifacts/rocblas-gfx1013/`](../artifacts/rocblas-gfx1013/) — 80
files, 21 MB.

```bash
sudo cp artifacts/rocblas-gfx1013/* /opt/rocm/lib/rocblas/library/
```

Building them from source requires seven source changes to Tensile — the
architecture is not supported at all otherwise. All seven are documented with
the exact edits in [09-building-tensile.md](09-building-tensile.md).

> These logic files were translated from **navi21** (gfx1030, RDNA2) — the wrong
> architecture family for gfx1013 (RDNA1). They work, but the tuning parameters
> are not right for this chip. rocBLAS 7.2 ships no RDNA1 logic to copy from.

---

## 5. MIOpen — use the system one

Do **not** use a custom MIOpen build. Ours (from March) broke `conv2d`
outright, and `ldconfig` silently resurrects it on every `pacman -S`:

```bash
# after any package install, check:
readlink /opt/rocm/lib/libMIOpen.so.1
# must point at libMIOpen.so.1.0 (the packaged ~1.5 GB one),
# NOT at a custom libMIOpen.so.1.0.gfx1013
```

The permanent fix is to move any custom build out of `/opt/rocm/lib` so
`ldconfig` has nothing to pick.

---

## 6. Runtime environment

[`config/bc250-rocm.sh`](../config/bc250-rocm.sh) → install as
`/etc/profile.d/bc250-rocm.sh`:

```bash
export GPU_PINNED_MIN_XFER_SIZE=16384   # without this, model loading hangs
export HSA_ENABLE_SDMA=0                # SDMA is broken host<->VRAM here
export AMD_DIRECT_DISPATCH=0
export GPU_MAX_HW_QUEUES=1
export TORCH_BLAS_PREFER_HIPBLASLT=0    # no gfx1013 kernels in hipBLASLt
export HIP_LAUNCH_BLOCKING=1
export AMD_SERIALIZE_KERNEL=3
export AMD_SERIALIZE_COPY=3
```

> The last three are carried for stability, but **measurement shows they do not
> do what was assumed**: a dispatch still went out with `completion_signal=0x0`
> while all three were active. They also cost real performance on small kernels.
> Their value is unproven — they are kept because removing them was never
> tested, not because they were shown to help.

---

## 7. ComfyUI warmup node — REQUIRED

Copy [`comfyui/bc250_warmup.py`](../comfyui/bc250_warmup.py) into
`ComfyUI/custom_nodes/`. It touches ~90 kernels at startup, before any model
loads.

Without it the sampler fails reliably. With it, 6/6 generations succeeded.

Disable with `BC250_WARMUP=0`.

> **Do not add more warmups.** We wrote two more and measured them: both are
> harmful. The VAE-shape warmup retains ~40 tensors and never frees them,
> dropping usable VRAM from 8789 MB to 2245 MB — the sampler then hangs at step
> 0/24 and takes the machine down. (It was first recorded as "neutral" on
> 2026-08-04; that was corrected on 2026-08-05 with a three-point measurement,
> see [03-warmup.md](03-warmup.md).) The BLAS type×transpose warmup is
> *actively harmful* too — it
> triggers the bug during startup and poisons the GPU context so ComfyUI never
> comes up. Stacking warmups increases the chance of tripping the bug, because
> each one is more heavy GPU work before the real work. See
> [03-warmup.md](03-warmup.md).

---

## 8. Run with `--cpu-vae`

```bash
python main.py --listen 127.0.0.1 --port 8188 --cpu-vae
```

VAE decode on the GPU still fails — in bf16, fp16 and fp32 alike. CPU decode
costs roughly 15 s of the 33 s total. See [04-vae.md](04-vae.md).

---

## 9. Optional: GPU clock governor

Default is 1500 MHz with 2000+ available — about 33% of compute left on the
table. `power_dpm_force_performance_level` is **not writable** on this board;
the path is `cyan-skillfish-governor-smu`. See [06-governor.md](06-governor.md).

Not included in the measured results above — those were all at 1500 MHz.

---

## Verifying it works

```bash
cd tools
bash run_bench2.sh        # 2 generations, prints wall clock per image
```

Expect roughly 40 s cold and 33 s warm, with `page fault` and `GPU reset` at 0:

```bash
sudo dmesg | grep -ci "page fault"
sudo dmesg | grep -ci "GPU reset"
```
