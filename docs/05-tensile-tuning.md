# Tensile tuning on gfx1013

Nobody had tuned Tensile on this board. This documents **why**: seven obstacles
between Tensile and a valid measurement, six of them solved here.

The tuning itself was **not run** — the numbers below explain why it was
deprioritised.

---

## The seven obstacles

| # | obstacle | cause | fix |
|---|---|---|---|
| 1 | `tensile-client` missing | earlier builds used Tensile only as a kernel generator | build `Tensile/Source` with cmake |
| 2 | `total vgpr: 305 not in [0, 256]` | tile sizes inherited from navi21 (RDNA2) exceed gfx1013 (RDNA1) registers | limit `ThreadTile` to 4x4 / 4x8 / 8x8 |
| 3 | `ThreadTile not a multiple of VectorWidth` | shrinking tiles left `VectorWidth: [4,8]` incompatible | `[1,2,4]`; half requires >= 2 |
| 4 | `TensileLibrary.dat: Got empty plain scalar` → segfault | client built for YAML, generator emits msgpack | `-DTensile_LIBRARY_FORMAT=msgpack -DTENSILE_USE_MSGPACK=ON` |
| 5 | `what(): stoi` → SIGABRT | `rocm-smi` throws `Exception caught: map::at` here; telemetry comes back empty and `ResultFileReporter.cpp` calls `std::stoi` with no try/catch | [patch 03](../patches/03-tensile-client-safestoi.patch) |
| 6 | `time-us = -1.91442e+09` | the GPU timer returns garbage on this board | `KernelTime: False` → `use-gpu-timer=False` |
| 7 | `No valid solutions found` | winner selection uses `PerformanceMetric: DeviceEfficiency`, which needs clock and power — zeroed here | **unsolved** |

Obstacles 5, 6 and 7 are the same root cause showing up in three places: the
BC-250 does not expose complete GPU telemetry.

---

## What works now

With 1-6 fixed, a minimal run produces a real measurement:

```
solution      Cijk_Ailk_Bljk_SB_MT64x64x16_SN_K1
validation    PASSED
time-us       46.349
gflops        723.952
```

Kernels are generated, compiled for gfx1013, executed, **numerically validated**
and timed. Only the final aggregation still fails.

Configs: [`tools/tensile-configs/`](../tools/tensile-configs/) — five configs
covering 85 shapes profiled from a real SD run.

---

## Measurement accuracy

`use-gpu-timer=False` measures wall time including launch overhead. For
*comparing solutions* that is consistent — all pay the same cost. But on fast
kernels the fixed cost compresses differences and can invert the ranking.

Mitigation, not applied yet: raise `EnqueuesPerSync` (currently 1) to ~100 so
the fixed cost is divided by N.

---

## Why tuning was deprioritised

### Theoretical peak

40 CU (20 WGP) × 2 SIMD32 × 32 lanes × 2 flops:

| condition | peak |
|---|---|
| fp32 @ 1.5 GHz | 7.68 TFLOP/s |
| fp16 packed @ 1.5 GHz | 15.36 TFLOP/s |
| fp32 @ 2.05 GHz | 10.5 TFLOP/s |

### Measured

```
1024x1024x512 NT f16   2.09 TFLOP/s
4096x4096x512 NT f16   6.22 TFLOP/s
```

Memory is not the constraint: arithmetic intensity of 256 and 410 FLOP/byte,
traffic of 8 and 15 GB/s.

### The hot loop

Disassembling a generated half kernel, whole-file counts mislead:

```
v_pk_fma          49    packed, 2 fp16 per op
v_fma_mix_f32     64    fp16 in, fp32 accumulate — fp32 rate
```

In the **hot loop**, which is what sets the rate:

```
v_fma_mix_f32     32
v_dot2c_f32_f16    1
v_fmac_f32         1
packed in loop:  0/34 = 0%
```

The `v_pk_fma` instructions are in prologue/epilogue. The loop is 100%
`v_fma_mix_f32`.

**So the applicable ceiling is 7.68 TFLOP/s, and 6.22 is 81% of it.** Tile
tuning cannot go much past that.

### Where the headroom actually is

```
1  clock 1500 -> 2050 MHz          x1.37, no compilation at all
2  HighPrecisionAccumulate: False  up to 2x — makes the loop use v_pk_fma_f16,
                                   but accumulates in fp16: a numerical
                                   quality trade, needs image comparison
3  tile tuning                     +0.5 to 1 TFLOP/s
```

Item 2 is where the TFLOP/s are, and it is not a tuning problem.

---

## gfx1013 capabilities vs navi21

| capability | gfx1013 | gfx1030 |
|---|---|---|
| `v_dot2_f32_f16` | **False** | True |
| `v_dot2c_f32_f16` | **False** | True |
| `v_pk_fma_f16` | **True** | — |
| `HasWMMA` / `HasMFMA` | False | False |

No dot products, but packed FMA is present. Different things — easy to conflate.

---

## Profiling data

[`tools/profiling/`](../tools/profiling/) holds the real GEMM trace from a
512x512 SD run: **10,860 calls, 81 distinct shapes**, 98.2% fp16.

Hottest:
```
TN    320 x 8192 x  320   720 calls
TN    640 x 2048 x  640   720
TN   1280 x  512 x 1280   720
NN     64 x 1280 x 11520  576
NN   4096 x  320 x  320   480
```

Heaviest (GFLOP per call):
```
NN  1024 x 1280 x 11520   30.2
NN  4096 x  640 x  5760   30.2
NN  1024 x  640 x 17280   22.6
```

`K` reaches 23040 — large reductions, typical of implicit convolution.
