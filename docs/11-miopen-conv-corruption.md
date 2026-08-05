# MIOpen's conv2d returns wrong numbers on gfx1013

The single most consequential finding on this board. `conv2d` through MIOpen
silently returns numerically wrong data — no error, no fault, no crash — while
every other operation family tested is correct.

Measured 2026-08-05, on a freshly booted machine, as the first GPU load.

---

## The measurement

Successive `conv2d` calls in one process, each checked against a CPU reference:

```
[ 1] c= 64 h= 32 err=2.889e-04
[ 2] c=320 h= 32 err=2.420e-04
...
[ 6] c=320 h= 48 err=1.068e+01  WRONG
[ 8] c=320 h= 56 err=3.443e-04          <- recovers
[12] c=320 h= 72 err=1.000e+00  WRONG
[14] c=320 h= 80 err=4.092e-04          <- recovers again
[16] c=320 h= 88 err=1.000e+00  WRONG
[18..24]                        WRONG
[25] c= 64 h=128 err=2.517e-04          <- and one still passes
12/26 wrong, first at op 6
```

Correct results land at ~3e-04 (fp16). Wrong results land at 1e-1 to `inf`.
`err=1.000e+00` means the output is all zeros.

Reproducer: [`tools/repro_inproc.py`](../tools/repro_inproc.py). Independent
runs give `8/26`, `12/26`, `12/26`, `9/26`, `10/26` — the onset moves between op
6 and op 12, the failure does not.

It **alternates**: fails, recovers, fails again, and only later stops
recovering. Not simple monotonic degradation.

---

## Isolation: only conv2d

Same in-process pattern, one operation family per run:

| family | wrong |
|---|---|
| `matmul` (rocBLAS/Tensile, built natively for gfx1013) | **0/26** |
| elementwise (torch's own kernels) | **0/26** |
| `unfold` / im2col alone | **0/26** |
| im2col + GEMM by hand (conv reimplemented) | **0/26** |
| **`conv2d` via MIOpen** | **12/26** |

Reimplementing the convolution by hand — same maths, same amount of GPU work,
same queue — is correct. Only MIOpen's path is wrong.

**This rules out a hardware defect.** If the silicon could not do this work,
the hand-rolled version would fail too.

---

## Controls

| control | result | rules out |
|---|---|---|
| CPU 1-thread vs multi-thread reference | `0.000e+00` | bad reference |
| GPU fp32 vs CPU fp32 | `8.2e-07` | — |
| fp32 wrong / fp16 wrong, 52 ops | 10 / 9 (+7 NaN) | precision, fp16-specific kernel |
| fp16 overflow | max 279 of 65504 | overflow |
| same shape repeated 200x | 0/200 wrong | accumulation, thermal |
| `h=160` with nothing before it | passes | the shape itself |
| serialization env vars | no change | stream ordering race |
| 48 short processes, same shape | no failure | driver state across processes |
| 86 processes, one distinct shape each | no failure | JIT count across processes |

fp32 failing as often as fp16 is the important one: this is not arithmetic
precision and not one bad half-precision kernel.

---

## Which MIOpen solver

`MIOPEN_ENABLE_LOGGING=1` shows `GemmFwdRest` as the chosen solver — im2col
followed by a rocBLAS GEMM. Disabling that solver family:

| configuration | wrong |
|---|---|
| default | 12–14/26 |
| `MIOPEN_DEBUG_CONV_GEMM=0` | **1/26** |
| `MIOPEN_DEBUG_CONV_GEMM=0 MIOPEN_DEBUG_CONV_FFT=0` | 1/26 |
| `MIOPEN_DEBUG_CONV_GEMM=0 MIOPEN_DEBUG_CONV_WINOGRAD=0` | 4/26 |
| `MIOPEN_DEBUG_CONV_GEMM=0` + WINOGRAD + IMPLICIT off | 3/26 |
| **the monkey-patch below** | **0/26** |

No environment-only configuration reaches zero. Turning off more algorithms
makes it *worse*, because the fallbacks have problems of their own.

### Two distinct effects

Running the same shape list three times in one process:

```
pass 1 (kernels being loaded)   12/26 wrong
pass 2 (kernels already loaded)  8/26 wrong
pass 3 (kernels already loaded)  8/26 wrong   <- exactly the same 8 shapes
```

Passes 2 and 3 are identical. So there are two things stacked:

- **8 shapes whose generated kernel is simply wrong** — deterministic
- **4 extra failures during first load** — code-object loading

The deterministic part dominates.

### Why this is unsurprising

MIOpen ships 84 tuning database files. **None of them is for gfx1013.**

```
$ ls /opt/rocm/share/miopen/db/ | grep -oE 'gfx[0-9]+' | sort -u
gfx1030 gfx803 gfx900 gfx906 gfx908 gfx90878 gfx942 gfx950
```

The nearest RDNA entry is gfx1030 — RDNA2, not RDNA1. Every convolution kernel
here is JIT-compiled from generic heuristics with no validation data for this
architecture. By contrast rocBLAS/Tensile and torch are built ahead of time
*for* gfx1013, and both are correct.

---

## The workaround

[`comfyui/bc250_conv_fix.py`](../comfyui/bc250_conv_fix.py) replaces
`F.conv2d` with im2col + GEMM through torch's own kernels. MIOpen already
chooses that algorithm (`GemmFwdRest`); this just runs it through code that
works.

| | before | after |
|---|---|---|
| conv2d, isolated | 12/26 wrong | **0/26** |
| sampler | 1.53 it/s | **1.80 it/s** |
| generation, 512×512 | 37.3 s / 31.2 s | 38.2 s / 31.3 s |

Cost is nil — MIOpen was doing the same algorithm anyway:

```
c=320 h= 64   conv2d 1.68 ms   im2col+GEMM 1.72 ms
c=320 h=128   conv2d 6.32 ms   im2col+GEMM 6.52 ms
c=640 h= 32   conv2d 2.63 ms   im2col+GEMM 2.67 ms
```

**Generated images change.** Since the previous path was returning wrong data
some of the time, output before this patch was consistently — deterministically
— wrong. Determinism is not correctness.

### Memory guard

im2col materialises a `(cin·kh·kw) × (ho·wo)` matrix. At UNet resolution that
is ~24 MB; at VAE resolution (512×512, 256 channels) it is 1152 MB, which does
not fit in a 4 GB carve-out. Above `BC250_CONV_FIX_MAX_MB` (192 by default) the
patch falls back to MIOpen — worse correctness, but the alternative is taking
the machine down.

### A tiling attempt that failed

Slicing im2col by output rows, so nothing ever falls back to MIOpen, produced
**correct numbers in isolation** (peak 1152 MB → ~670 MB) and then **crashed
the machine reproducibly** during a full generation:

```
no patch at all      38.25 s / 34.29 s   fine
with tiling          crash               reproducible
with simple fallback 38.16 s / 31.32 s   fine
```

Reverted. Cause not investigated — possibly the allocation pattern of the
per-slice `torch.cat`. Recorded so nobody re-derives it.

---

## What is still broken

GPU VAE decode still fails, now further along than before — the sampler
completes and it dies at `Requested to load AutoencoderKL`.

Every VAE operation tested **in isolation, at its real shapes, passes**:
`conv2d` at all six decoder shapes (including the 1152 MB ones), `group_norm`,
`interpolate`, `silu`, and `sdpa` at 4096×512. The failure only appears in the
full sequence.

So there is at least one more problem, and it is not a single broken operation
— it is the same in-process accumulation, which the conv patch reduces but does
not eliminate.

---

## Method notes, learned the hard way

- **Confirm the baseline fails in the same boot** before and after any A/B. A
  test whose baseline passes has no power. Two A/Bs were wasted this way.
- **Passing in isolation says nothing about the full pipeline.** The tiling
  change and the three-shape reproducer both looked good in isolation and were
  wrong in practice.
- **Check `dmesg | grep -c "page fault"` is zero before each run.** After a
  fault the GPU context is poisoned and every subsequent run fails regardless
  of what you changed.
- **Write results to disk with `fsync` per line.** Anything that can hang the
  host will eat terminal output.
