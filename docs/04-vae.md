# VAE decode — still on the CPU

VAE decode on the GPU does not work. It runs on the CPU (`--cpu-vae`), which
costs roughly **15 s of the 33 s** per image.

This is not a performance choice. It is the compute bug, and the VAE is where it
happens to land in a normal ComfyUI pipeline.

---

## What fails

Every dtype:

| flag | failing call |
|---|---|
| default (bf16) | `hipblasGemmEx`, `HIPBLAS_STATUS_INTERNAL_ERROR` |
| `--fp16-vae` | `rocblas_gemm_ex`, same |
| `--fp32-vae` | `hipblasSgemm`, same |

Five attempts, five failures, two of which took the machine down.

---

## What the VAE actually asks for

Derived on the CPU (zero GPU risk) by running the decoder with a hook on every
matrix op, then **cross-checked** against a real GPU run at 256px:

```
512px   gemm_ex NT  M=4096 N=4096 K=512   f16    17.2 GFLOP
        gemm_ex     M=512  N=4096 K=4096  f16    17.2 GFLOP
256px   gemm_ex NT  M=1024 N=1024 K=512   f16     1.1 GFLOP
```

Only **two** GEMMs — the self-attention in the decoder's middle block. Token
count is `(px/8)²`: 1024 at 256px, 4096 at 512px. `K=512` is the VAE channel
count and does not scale with resolution.

The 256px prediction was confirmed exactly in the rocBLAS trace:
`-m 1024 -n 1024 -k 512`, `f16_r`, `--transposeA N --transposeB T`.

---

## It is not the GEMM

The exact failing shape runs fine in isolation:

```
4096x4096x512 NT fp16   2.760 ms   6.22 TFLOP/s   0 faults
1024x1024x512 NT fp16   0.515 ms   2.09 TFLOP/s   0 faults
```

Measured through torch with our gfx1013 library, no override.

And the **whole VAE decode at 512px** works standalone on the GPU: 262 modules,
fp16, output `(1, 3, 512, 512)`, zero faults.

It only fails inside the pipeline — after other heavy GPU work has run.

Which is the general bug: [01-the-bug.md](01-the-bug.md).

---

## Not a Tensile coverage gap

An obvious theory was that the gfx1013 kernel library lacks solutions for the
large GEMM. It does not:

```
Cijk_Ailk_Bljk_HHS_BH.yaml (NT/half)
  2289 size entries
  M up to 3,818,566   N up to 193,600   K up to 500,000
  928 entries with M or N >= 4096
  3 entries with exactly M=4096 N=4096
```

Tensile also selects by nearest neighbour, so a missing exact size would never
produce an error anyway.

---

## Tiled decode: deliberately not used

`VAEDecodeTiled` with a small tile size would keep the VAE on the GPU by
splitting it into 256px-sized pieces — which we know work. It was prepared and
**not run**, by choice: it hides the bug instead of fixing it.

If you just want images and don't care, it is a one-node change.

---

## What might actually fix it

**More UMA.** The board was set to 4 GB. At 512px the UNet (1639 MB), CLIP
(236 MB) and VAE (319 MB) all compete, and ComfyUI shuffles them on and off the
GPU. With 6 or 8 GB the VAE could stay resident and never need a second load
phase. **Untested** — this is the most promising cheap experiment left.

**Root cause.** See [01-the-bug.md](01-the-bug.md).
