# The failing solver is the naive one — and three earlier conclusions were wrong

Measured 2026-08-05, late session. This document exists as much to retract
things as to add them.

---

## The solver is `ConvDirectNaiveConvFwd`, not `GemmFwdRest`

Run with `MIOPEN_ENABLE_LOGGING=1 MIOPEN_LOG_LEVEL=6` across the 26-shape
sweep, every single solver mention — 78 of them — is the same:

```
Solver ConvDirectNaiveConvFwd registered as find 1.0 best
for miopenConvolutionFwdAlgoDirect
```

One solver, one code path, for all 26 shapes. 23 correct, 3 wrong.

This matters because [11-miopen-conv-corruption.md](11-miopen-conv-corruption.md)
attributes the corruption to `GemmFwdRest` on the strength of
`MIOPEN_DEBUG_CONV_GEMM=0` dropping errors from ~12/26 to ~1/26. That
measurement stands, but the attribution does not: the GEMM solver is not being
selected at all now. Whatever that flag was doing, it was not disabling the
solver in use.

With no gfx1013 tuning database (84 db files, none for this architecture),
MIOpen falls back to its reference kernel and stays there.

---

## Two hypotheses killed by reading the source

### "A new code object is loaded per shape"

Dead. `naive_conv_fwd_nchw` takes the dimensions as **runtime arguments**:

```c
naive_conv_fwd_nchw(..., int hi, int wi, int n, int k_per_group,
                    int c_per_group, int ho, int wo, int sy, int sx, ...)
```

One kernel, compiled once, parameterised at launch. A new shape does not
produce a new code object on this path. Measured: 0.1 s per novel shape, no
JIT delay. Every argument built on late code-object loading has to be rebuilt.

### "The kernel or its codegen is wrong"

Both look correct.

The source does all address arithmetic in `size_t`, and the kernel has no LDS,
no barriers, and no cross-thread communication — one block per output channel,
each thread accumulating independently.

The generated ISA is correct too. Compiling `MIOpenIm2d2Col.cpp` standalone for
three targets:

```
                gfx1013  gfx1012  gfx1030
s_barrier             1        1        1
ds_write              1        1        1
global_load           1        1        1
s_waitcnt_vscnt       5        5        0
```

`gfx1013` is identical to `gfx1012` throughout, and the ordering is right:

```
global_load_ushort v2, v[1:2], off   <- load
s_waitcnt vmcnt(0)                   <- wait for it
ds_write_b16 v3, v2                  <- then write LDS
s_waitcnt lgkmcnt(0)                 <- drain LDS
s_barrier                            <- then barrier
```

No missing synchronisation. `s_waitcnt_vscnt` differing on gfx1030 is an
RDNA1/RDNA2 difference, not a defect.

---

## The 26-shape reproducer is too small to validate anything

`tools/repro_inproc.py` reports a count out of 26. On 2026-08-04 that count was
a steady 8–14. By the evening of 2026-08-05 the same script on the same board
gave **0, 1, 3, 3, 5, 6** across identical runs.

Every negative result reported that evening — the codegen flag sweep, the CK
barrier flags, `WAVE64_NOWGP` — was measured against a baseline whose own range
was 0 to 5. None of them had the power to detect anything. They are
inconclusive, not negative.

[`tools/repro_rate.py`](../tools/repro_rate.py) replaces it: same shapes, more
repetitions, and the output is a rate with a Wilson confidence interval.

```
156 operations, 26 s
TAXA 16.67%   IC95 [11.63%, 23.30%]   26/156
```

**Rule that follows: compare confidence intervals, not means.** If they
overlap, the difference is not demonstrated.

---

## What the failure actually looks like

Per-repetition breakdown over six passes of the same 26 shapes in one process:

| rep | wrong | which |
|---|---|---|
| 1 | 3 | c=64 h=104, c=320 h=104, c=320 h=128 |
| 2 | 0 | — |
| 3 | 4 | c=320 h=64, 72, 80, 96 |
| 4 | 5 | c=320 h=64, 72, 80, 96, 128 |
| 5 | 5 | same five |
| 6 | 5 | same five |

Two things stand out.

**It converges.** After three passes the set is stable and repeats exactly.
It does not degrade without bound.

**The set is not a property of the shape.** Earlier the same day, on a
different boot, the failing set was `h=104` at both channel counts. Here it is
five different shapes, all at `c=320`. A wrong kernel fails on the same inputs
every time; this does not.

Session-stable but not shape-stable points away from the kernel and toward
allocation: a bad region that the allocator happens to reuse. That is
consistent with the process-scoped behaviour below, and it is the open lead.

The discriminating test — are the wrong elements contiguous in memory
(allocation) or scattered (compute)? — died with a page fault before producing
output. Not yet answered.

---

## Why this is software and not damaged silicon

Three independent measurements:

- **It resets on process exit.** 48 short processes in a row: clean. 86
  processes, one distinct shape each: clean. Inside a single process: fails
  from the sixth operation. Damaged silicon does not heal at `exit()`.
- **The same arithmetic is correct through other kernels.** Hand-rolled
  im2col + GEMM: 0/26. `matmul`, elementwise, `unfold`: 0/26 each.
- **Vulkan compute on the same board** checks 100,663,296 elements with zero
  errors (community measurement, `clpeak`-adjacent verifier).

The hardware can compute this correctly. Something on the ROCm path stops it.

---

## Correction on the serialisation variables

`docs/01-the-bug.md` and the environment carry five variables — `GPU_MAX_HW_QUEUES`,
`HIP_LAUNCH_BLOCKING`, `AMD_SERIALIZE_KERNEL`, `AMD_SERIALIZE_COPY`,
`AMD_DIRECT_DISPATCH`. A sweep on 2026-08-05 concluded they made no difference.

That sweep was invalid. It ran `env AMD_SERIALIZE_KERNEL=3 python repro` on top
of a profile that **already exported the same variable**, so it compared
serialisation against serialisation. The five identical results were one
configuration measured five times.

Retested with `env -u` to actually remove them, interleaved, cache cleared:

| rep | with | without |
|---|---|---|
| 1 | 6/26 | 0/26 |
| 2 | 4/26 | 5/26 |
| 3 | 4/26 | 0/26 |

Suggestive that serialisation is *worse*, which is the opposite of the usual
intuition — but n=3 with the ranges overlapping. Not demonstrated. Redo with
`repro_rate.py`.
