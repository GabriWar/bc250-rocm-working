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
| 2 — + VAE shapes | 39.56s | 34.36s | OK, **neutral** |
| 3 — + BLAS type×transpose | — | — | **died at startup** |

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
