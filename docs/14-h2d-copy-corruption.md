# The corruption is in the host-to-device copy, not in any kernel

Measured 2026-08-05. This supersedes the attribution in
[11-miopen-conv-corruption.md](11-miopen-conv-corruption.md), which blames
MIOpen. MIOpen is not the culprit.

---

## What was measured

Upload tensors to the GPU, read them straight back, compare. No convolution,
no MIOpen, no kernel of ours — `x.to("cuda")` and `.cpu()`, byte for byte.

```
A: uploads em rajada, sync so no fim
   c=320 h=112  1048434/4014080 elementos DIFERENTES  primeiro no indice 0
   c=320 h=128  1048471/5242880 elementos DIFERENTES  primeiro no indice 1048576
   c=320 h=128  1048461/5242880 elementos DIFERENTES  primeiro no indice 1048576

B: um upload por vez, sync a cada um
   todos identicos, 48/48
```

`1048576 = 2^20`. In fp16 that is exactly **2 MiB**, and the first bad index is
always a multiple of it. **One 2 MiB chunk of a large transfer never lands**
when several copies are queued without synchronisation between them. The ~140
elements short of the full 2^20 are values that happened to match by chance in
random data.

Requires prior GPU activity: with no warmup, 48/48 uploads are clean. The first
version of `tools/h2d_fix.py` omitted the warmup and reported zero corruption
for every mitigation — which would have "proved" a fix for something that was
not broken in that run.

---

## Why this explains everything that did not fit

| observation | explanation |
|---|---|
| conv and im2col produce the *same* wrong value, to three digits | both compute correctly on the same corrupted input |
| only `c=320` fails, `c=64` never | `c=64 h=64` is 512 KB — one chunk, never split |
| serialisation env vars appear to help | they force one copy at a time |
| VAE breaks right after a model unload | a model swap is a burst of copies |
| ComfyUI fails where isolated tests pass | isolated tests do not batch uploads |
| `empty_cache()` poisons exactly the next operation | same mechanism |
| the failing shape set is stable within a session, different across sessions | it follows allocation, not the shape |

Two GPU paths giving *identical* wrong answers was the tell. Different
algorithms do not coincide to three significant figures unless they are reading
the same bad data.

---

## The mechanism: lost completion signalling on SDMA0

At every boot, before any workload:

```
amdgpu 0000:01:00.0: Fence fallback timer expired on ring sdma0
amdgpu 0000:01:00.0: Fence fallback timer expired on ring sdma0
amdgpu 0000:01:00.0: ring sdma0 uses VM inv eng 12 on hub 0
amdgpu 0000:01:00.0: ring sdma1 uses VM inv eng 13 on hub 0
```

`amdgpu_fence_fallback()` warns *only* when `amdgpu_fence_process()` found an
already-completed fence. So the transfer finished and **the interrupt was
lost** — SDMA0 is not stuck, it is silent. SDMA1 never produces the warning.

That is one defect with two faces:

- `HSA_ENABLE_SDMA=1` — the copy completes, nothing signals, the caller spins.
  Measured: 199% CPU, state `R`, no progress for minutes on a warmup that takes
  seconds otherwise.
- `HSA_ENABLE_SDMA=0` — blit-kernel fallback, completion signalling unreliable
  the same way, so a batched copy is treated as done early and loses a chunk.

We had been running the second because the first hangs. Both are broken.

---

## Mitigations that do not work

48 uploads each, with warmup, one process at a time:

| | corrupted |
|---|---|
| baseline | 9 |
| pinned host memory | **16** |
| `non_blocking=True` + pinned | 8 |
| `HSA_ENABLE_SDMA=1` | never completes |

Pinned memory is *worse*, which argues the staging buffer is not the problem.
Nothing in userspace fixes it.

---

## The patch

[`patches/bc250-kfd-skip-sdma0.patch`](../patches/bc250-kfd-skip-sdma0.patch)
keeps user SDMA queues off engine 0 inside KFD.

`allocate_sdma_queue()` takes the first free bit and derives the engine as
`sdma_id % num_engines`, so with two engines the even ids land on engine 0 and
the first queue of every process goes there. Clearing those bits leaves engine
0 to the kernel's own ring.

Costs half the SDMA queue slots. Behind `amdgpu.bc250_skip_sdma0=1`, default
off, so it can be A/B tested against the same build.

neoney's `clr-prefer-sdma1` does the same steering in ROCclr. Doing it in KFD
covers every client and survives a ROCm rebuild.

**Not yet validated.** Written from the diagnosis above; the module has not
been built or booted with it.

---

## What this means for `bc250_conv_fix.py`

The patch routes `conv2d` around MIOpen and measured 12/26 → 0/26 at the time.
That measurement was real, but the attribution was wrong: on a clean boot as
first GPU load, MIOpen's `conv2d` was correct on all six target shapes while
the im2col+GEMM path failed on three.

It should not be presented as a correctness fix until re-measured against the
SDMA patch. If the copy is what corrupts, neither path was ever wrong.

---

## Method notes worth keeping

**Order confound.** A batch that always ran `conv` first and `im2col` second
reported 11 im2col failures out of 18. Alternating the order gave 0 out of 18.
The real difference turned out to be something else entirely — whether GPU work
was batched before the copies — but the lesson stands: if two things are always
measured in the same order, the second one carries the blame.

**`nan` is not `ok`.** Every comparison against `nan` is false, so a
`if err > TOL` verdict silently passes the worst possible result. One row read
`nan nan nan nan ok` before this was fixed.

**Concurrent processes.** Two GPU processes overlapped during one battery
because a backgrounded run never exited. Those numbers were discarded.
