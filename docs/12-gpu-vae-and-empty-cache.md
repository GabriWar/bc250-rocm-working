> **SUPERSEDIDO 2026-08-06.** A atribuição deste documento está errada. A causa
> real está em [17-a-gpu-le-fora-da-propria-tabela-de-pagina.md](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md):
> a GPU lê memória física diferente da que a própria tabela de página dela
> aponta. O que segue fica como histórico de investigação.

# GPU VAE decode, and why `empty_cache()` was breaking it

VAE decode on the GPU was the longest-standing open problem on this board. It is
solved. The cause was not the VAE, not its shapes, and not the compute queue —
it was `torch.cuda.empty_cache()` corrupting exactly the next operation.

Measured 2026-08-05. Result: **19.26 s** per 512×512 image, down from 38.16 s
with the VAE on CPU.

---

## The measurement

VAE decode validated against a CPU reference by relative error — not by
`torch.isfinite()`, which is the mistake that cost two false positives here
(uniform garbage is also finite):

```
before anything                    err=1.257e-02  OK
with UNet resident on GPU          err=1.257e-02  OK
unload UNet + empty_cache()        err=6.075e-01  CORRUPT
next decode                        err=1.257e-02  OK
```

**Exactly one operation comes out poisoned after `empty_cache()`, and the one
after it is fine.**

ComfyUI calls `soft_empty_cache()` — which is `synchronize()` + `empty_cache()`
+ `ipc_collect()` — from five places in `comfy/model_management.py`, all of them
on model unload. The only model swap in the middle of a generation is
sampler → VAE. So the VAE was always the poisoned operation and the UNet never
was. It was positional, not architectural.

This also explains an earlier observation that did not fit anywhere:
`empty_cache()` between `conv2d` calls escalated the failure from wrong numbers
to `HSA_STATUS_ERROR_ILLEGAL_INSTRUCTION` (`code: 0x2a`).

---

## The other two blockers, in order

Before reaching the `empty_cache` problem, two things had to be cleared.

### bfloat16 dies at operation 7 of 519

ComfyUI loads the VAE in `bfloat16` by default. The decode dies immediately —
no error, no fault, the process simply stops. [`tools/trace_ops.py`](../tools/trace_ops.py)
pinned it exactly:

```
7 ANTES  aten.mm.default   (4096, 4):bfloat16  (4, 4):bfloat16
         <- no matching "DEPOIS". died here.
```

That is operation 7 of the 519 the decode performs. bf16 was already known
broken on this board (fails in all four transpose combinations); what was
missing was knowing the VAE hit it seven ops in.

Fix: `--fp16-vae`.

### MIOpen's conv2d returns wrong numbers

See [11-miopen-conv-corruption.md](11-miopen-conv-corruption.md). The VAE is
convolution-dominated, so it is hit harder than the UNet.

Fix: [`comfyui/bc250_conv_fix.py`](../comfyui/bc250_conv_fix.py).

---

## The recipe

Three custom nodes plus one flag:

```
comfyui/bc250_warmup.py           ~90 kernels at startup
comfyui/bc250_conv_fix.py         conv2d -> im2col+GEMM
comfyui/bc250_no_empty_cache.py   neutralise soft_empty_cache
```

```bash
python main.py --listen 127.0.0.1 --port 8188 --fp16-vae
```

No `--cpu-vae`.

| | CPU VAE | GPU VAE |
|---|---|---|
| generation, 512×512, 24 steps | 38.16 s | **19.26 s** |
| VAE decode alone | ~15 s | **0.60 s** warm |
| output PNG | 480 KB | 362 KB |
| pixel std / unique colours | — | 81.0 / 75,824 |

For comparison, a corrupted decode produces 30 KB, std 10.0, 1,989 colours.
Those numbers are worth checking after any change here — the failure mode is
silent, so file size and standard deviation are the cheapest tripwires.

---

## Cost and caveat of `bc250_no_empty_cache.py`

Memory is not returned to the driver between model swaps. On a 4 GB UMA
carve-out that can OOM in workflows that swap models frequently. Disable with
`BC250_NO_EMPTY_CACHE=0` if that happens.

The node keeps the `torch.cuda.synchronize()` — that part is cheap and
occasionally necessary. Only the release back to the driver is removed.

---

## Method note

Two false positives were reported during this investigation before the
validation was tightened:

- A decode was called successful because it completed in 28.90 s and produced a
  file. The file was 30 KB of near-uniform noise.
- A decode was called successful because `torch.isfinite(img).all()` was true.
  It was — the output was uniform garbage.

Both would have been caught by comparing against a CPU reference, which is what
every other test in this repo already did. The lesson generalises: on this
board, **completing without error is not evidence of correctness**. Compare
numerically or do not claim it works.
