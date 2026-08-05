# Performance, and what limits it

Everything here was measured on the reference board at **1500 MHz** (the
governor was not enabled for these numbers).

---

## Theoretical peak

40 CU / 20 WGP, 2 SIMD32 per CU, 32 lanes, 2 flops per FMA:

| condition | peak |
|---|---|
| fp32 @ 1.5 GHz | 7.68 TFLOP/s |
| fp16 **packed** @ 1.5 GHz | 15.36 TFLOP/s |
| fp32 @ 2.05 GHz | 10.5 TFLOP/s |
| fp16 packed @ 2.05 GHz | 21.0 TFLOP/s |

Which peak applies depends on whether the kernel's inner loop uses packed FMA.
On this stack, **it does not** — see below. So the applicable ceiling is
**7.68 TFLOP/s**.

## Measured

Through torch, with our gfx1013 library, no override:

| shape | time | throughput | % of 7.68 |
|---|---|---|---|
| 1024×1024×512 NT fp16 | 0.515 ms | 2.09 TFLOP/s | 27% |
| 4096×4096×512 NT fp16 | 2.760 ms | 6.22 TFLOP/s | **81%** |

Memory bandwidth is **not** the constraint:

| shape | traffic | arithmetic intensity |
|---|---|---|
| 1024×1024×512 | 4.2 MB @ 8.1 GB/s | 256 FLOP/byte |
| 4096×4096×512 | 41.9 MB @ 15.2 GB/s | 410 FLOP/byte |

## Why the large GEMM is at 81% and the small one at 27%

The small GEMM is dominated by fixed per-launch cost — 0.5 ms is short enough
that dispatch overhead matters. Our environment makes that worse on purpose:

```
HIP_LAUNCH_BLOCKING=1
AMD_SERIALIZE_KERNEL=3
AMD_SERIALIZE_COPY=3
```

These serialize everything and sync on every launch. They are carried for
stability, so part of the "distance from peak" on small kernels is the price of
that, not kernel inefficiency.

Occupancy also plays in: with 20 WGPs, a 1024×1024 problem produces few tiles
per WGP and the edges go idle.

---

## Packed fp16: present in the file, absent from the loop

Disassembling a generated half kernel
(`Cijk_Ailk_Bljk_HHS_BH_MT64x64x16_SN_K1.s`), whole-file counts:

```
v_pk_fma          49    packed — 2 fp16 per operation
v_fma_mix_f32     64    fp16 in, fp32 accumulate — fp32 rate
v_dot2c_f32_f16    1    macro only; the capability is False on gfx1013
```

That looks like packed is in use. It is not — those `v_pk_fma` are in
prologue/epilogue. In the **hot loop**, which sets the rate:

```
v_fma_mix_f32     32
v_dot2c_f32_f16    1
v_fmac_f32         1
packed in loop:  0/34 = 0%
```

**Lesson: count the loop, not the file.** Whole-file instruction histograms
mislead badly for performance work.

The loop is `v_fma_mix_f32` because `HighPrecisionAccumulate` is on — fp32
accumulate for numerical quality, which is the rocBLAS default. Turning it off
would let the loop use `v_pk_fma_f16` and roughly double the rate, at the cost
of accumulating in fp16.

**That is a numerical trade, not a tuning knob.** Worth testing with image
comparison, not just a throughput number. Untested here.

---

## The GPU timer returns garbage

Tensile's benchmark client times kernels with the GPU timer by default. On this
board that produces nonsense:

```
solution      Cijk_Ailk_Bljk_SB_MT64x64x16_SN_K1
validation    PASSED            <- the kernel computed correctly
time-us       -1.91442e+09      <- negative time
gflops        -1.75272e-05
```

Negative time gives negative GFLOP/s, and Tensile discards the solution as
invalid — so a kernel that *worked* gets thrown away.

Switching to the host timer fixes it:

```
KernelTime: False        ->  use-gpu-timer=False

time-us       46.349
gflops        723.952
validation    PASSED
```

**Accuracy caveat:** the host timer measures wall time including launch
overhead. For ranking solutions against each other that is consistent — all pay
the same cost — but on fast kernels the fixed cost compresses differences and
can invert the ranking. Mitigation (not applied): raise `EnqueuesPerSync` from 1
to ~100 so the fixed cost divides by N.

---

## Telemetry is incomplete, and it breaks tools

`rocm-smi` throws partway through collection:

```
GPU[0] : Temperature (Sensor edge) (C): 50.0
Exception caught: map::at
GPU[0] : sclk clock level: 1: (1500Mhz)
GPU[0] : Current Socket Graphics Package Power (W): 61.107
```

This surfaces in three separate places in Tensile:

1. **`std::stoi` with no try/catch** in `ResultFileReporter.cpp` — an empty
   telemetry string throws `std::invalid_argument`, uncaught, and the whole
   client aborts with SIGABRT. Fixed by
   [patch 03](../patches/03-tensile-client-safestoi.patch).
2. **The GPU timer**, above.
3. **Winner selection** uses `PerformanceMetric: DeviceEfficiency`, which needs
   clock and power. Both come back zero, so no winner is elected and the logic
   file ends up with an empty solution list — `No valid solutions found`. Still
   unsolved.

Anyone trying to tune Tensile on this board will hit all three.

---

## bfloat16 does not work

Measured directly: a 64×64 bf16 matmul fails in **all four** transpose
combinations with `RuntimeError`, while fp16 and fp32 pass in the same process.

```
[bc250-blas] bfloat16/NN: AcceleratorError
[bc250-blas] bfloat16/NT: AcceleratorError
[bc250-blas] bfloat16/TN: AcceleratorError
[bc250-blas] bfloat16/TT: AcceleratorError
```

This matters because ComfyUI loads the VAE in bf16 by default. It is independent
of the ordering bug — bf16 fails even as the first operation.

---

## Wave debugging is unavailable

`rocm-dbgapi` refuses the architecture outright:

```
warning: os_agent_id 33508 (`Device 1002:13fe.00'): architecture gfx1013 not supported.
warning: AMD GPU gpu_id 33508's firmware version 144 not supported
warning: AMDGPU precise memory access reporting could not be enabled.
```

There is no `info wavefronts` command, and `set amdgpu precise-memory on` is
accepted but silently ineffective.

This is worth stating plainly because it explains a lot: **nobody can debug
waves on this chip with the standard tooling.** Every root-cause attempt is
limited to what the runtime logs and what dmesg reports.

Reading GPU registers from userspace via `/sys/kernel/debug/dri/*/amdgpu_regs`
**hangs the machine** — tried, do not repeat.

---

## Where the headroom actually is

In order of return:

| | gain | cost |
|---|---|---|
| clock 1500 → 2050 MHz | **×1.37** | nothing to compile; ~190 W vs ~59 W |
| `HighPrecisionAccumulate: False` | up to **×2** | fp16 accumulation — numerical quality |
| Tensile tile tuning | +0.5 to 1 TFLOP/s | hours of tuning; obstacle 7 unsolved |

Note that end-to-end image time will not scale with GEMM throughput. Of the 33 s
per image, roughly 17 s is the sampler and ~15 s is the CPU VAE decode.
Doubling GEMM rate does not halve the image time.
