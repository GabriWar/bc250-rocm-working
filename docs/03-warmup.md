> **SUPERSEDIDO 2026-08-06.** O warmup deixou de ser necessário: sete
> execuções sem ele, todas válidas e byte-idênticas. Ver
> [18-comfyui-working-and-z-image.md](18-comfyui-working-and-z-image.md).

# The warmup

A ComfyUI custom node that touches ~90 GPU kernels at startup, before any model
is loaded. Without it, the sampler fails reliably. With it, generation works.

[`comfyui/bc250_warmup.py`](../comfyui/bc250_warmup.py) — disable with
`BC250_WARMUP=0`.

---

## What it does

For fp32 and fp16, it runs one tiny instance of each of:

- reductions: `count_nonzero`, `sum`, `mean`, `max`, `min`, `argmax`, `norm`,
  `cumsum`, `sort`, `any`, `all`, `nonzero`
- elementwise: `exp`, `sqrt`, `sigmoid`, `tanh`, `sin`, `cos`, `floor`, `ceil`,
  `frac`, `neg`, `log`, `clamp`, `where`, `pow`, `add`, `mul`, `div`, `eq`
- BLAS/NN: `matmul`, `bmm`, `conv2d`, `softmax`, `layer_norm`, `group_norm`,
  `silu`, `gelu`, `sdpa`, `interpolate`, `pad`, `cat`, `transpose`, `randn_like`
- plus int64 `sum` and `max`

~90 kernels, about a second.

---

## Evidence it works

A/B on the same boot:

| | result |
|---|---|
| `count_nonzero` called at process start | passes, then everything after it passes |
| `count_nonzero` called only at the end | `illegal memory access` |

Everything else identical — same model, same encode, same UNet on GPU, same
tensor.

In ComfyUI: 6 generations with the warmup, all clean. Without it, the sampler
failed every time.

---

## Do not stack warmups

Three warmups were written. Measured:

| warmups active | 1st (cold) | 2nd (warm) | result |
|---|---|---|---|
| 1 — general | 42.22s | 33.16s | OK |
| 2 — + VAE shapes | 39.56s | 34.36s | OK on 2026-08-04 — **later shown harmful, see below** |
| 3 — + BLAS type×transpose | — | — | **died at startup** |

> **Correction, 2026-08-05.** The "neutral" verdict on the VAE warmup was
> wrong. It holds ~40 VAE-shaped tensors and never frees them, which cuts
> usable VRAM by roughly 6.5 GB. Re-measured on a clean boot, same kernel and
> environment in all three rows:
>
> | warmups | usable VRAM reported by ComfyUI | result |
> |---|---|---|
> | 0 | 8787 MB | `illegal memory access` after 6.36 s, sampler never starts |
> | **1** | **8789 MB** | **37.27 s / 31.22 s — works** |
> | 2 | **2245 MB** | sampler hangs at step 0/24, machine hard-hangs |
>
> This confirms the main warmup is required and refutes the second being
> neutral. The VAE warmup starves the sampler of memory rather than doing
> anything to the ordering bug.
>
> It cost roughly six hard hangs before being identified, because each hang
> poisons the GPU context and makes *every* subsequent run fail — including
> runs with the configuration already reverted. That sent a bisect chasing four
> innocent variables (`flush_mapped_vmids`, `keep_kfd_vram`, the clock range,
> `amd_iommu=off`) whose measurements are therefore void.
>
> **Operational rule that follows:** check `dmesg | grep -c "page fault"` is
> zero before every run, and reboot if it is not. Otherwise you are measuring
> context poisoning, not your hypothesis.

---

## How much warmup is needed? There is a window

Another BC-250 user (Fabi) reached a working ComfyUI setup with a *three
operation* prewarm instead of a kernel sweep — context touch, one H2D copy, one
matmul. Worth testing, since every extra warmup kernel is more heavy GPU work
before the real work, which is the trigger we are trying to avoid.

Tested on 2026-08-05, same boot, `page fault` verified zero before the run:

| warmup | result |
|---|---|
| none | `illegal memory access` after 6.36 s, sampler never starts |
| **3 ops** (context + H2D copy + matmul) | **`illegal memory access`, no image, sampler never starts** |
| **~90 kernels** (this node) | **works — 37.27 s / 31.22 s** |
| ~130 kernels (this node + VAE warmup) | starved of VRAM, hangs at step 0/24 |

So the volume is load-bearing, not padding, and there is a **window**: too
little fails, too much fails. ~90 sits inside it.

The three-operation approach comes from a different stack — PyTorch 2.5.1 with
`HSA_OVERRIDE_GFX_VERSION=10.1.0` (gfx1010 spoof), a GGUF model, and
`--force-fp32`. It does not transfer to native gfx1013 with fp16.

The BLAS warmup walks the (dtype × transposeA × transposeB) matrix to force
every rocBLAS code object to load early. It **causes** the bug instead of
preventing it:

```
[bc250-warmup]      90 kernels warmed, 0 failed
[bc250-vae-warmup]  40 VAE kernels warmed, 0 failed
[bc250-blas]        float16/NN  ok
                    float16/NT  ok
                    float16/TN  RuntimeError: illegal memory access   <- breaks
                    everything after  AcceleratorError
                    2 warmed, 12 failed
```

After the first error every subsequent operation fails — the GPU context is
poisoned — and ComfyUI never finishes starting.

Telling detail: the same 8 fp16+fp32 combinations **passed** when the BLAS
warmup ran first in a clean process. Here it runs after 130 kernels are already
warm. That is the same ordering effect as the main bug, reproduced *inside the
warmup itself*.

### Why stacking hurts

Each warmup is more heavy GPU work *before* the real work. If the trigger is
"the second heavy phase fails", adding phases raises the odds of tripping it.

The 6 successful generations all used **one** warmup.

---

## Why does it work at all?

**Unknown.** This is a workaround with a measured effect and no established
mechanism.

The working theory for most of a day was "a code object loaded late fails, so
load them early". The evidence does not support it:

- the BLAS warmup loads code objects early and made things *worse*
- the failing dispatch had a correct `kernel_obj` — no corruption in the packet
- failures appear in plain elementwise kernels, not only freshly loaded ones

So the warmup may not be "loading code objects" at all. What it actually settles
is an open question — see [01-the-bug.md](01-the-bug.md).
