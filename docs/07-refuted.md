# Refuted hypotheses

Six explanations were proposed and killed by measurement in one session. They
are recorded so nobody spends a day rediscovering them.

---

## 1. "The MEC firmware doesn't program the shader address"

**Claim:** `cyan_skillfish2_mec.bin` diverges from `navi10_mec.bin` and omits
writes to `0x2E0C/0x2E0D` (`COMPUTE_PGM_LO/HI`) in the HQD setup region.

**Refuted by** disassembling both and diffing with alignment:

| earlier claim | measured |
|---|---|
| 76.5% identical | **98.49%** |
| ~12,000 divergent instructions | **2,779** aligned, 820 non-branch |
| cyan omits the writes | **both write them, byte-identical** |

Both firmwares write the registers at two sites each. The "missing" finding came
from a byte-offset diff that mistook *shifted* code for *absent* code — cyan's
second site is at `0x0dd04`, just below the analysed window; navi10's is at
`0x0e344`, inside it. A 0x640-byte shift.

The aligned diff shows **zero** divergent register accesses in the whole
firmware. The differences are padding (`431 nop` only in cyan) and branch
targets displaced by that padding.

---

## 2. "`count_nonzero` / `reduce_kernel` is the broken operation"

**Claim:** the sampler dies in `torch.count_nonzero` at `samplers.py:967`, so
that reduction is broken.

**Refuted:** it passes in isolation, all dtypes and shapes, including the exact
`(1,4,32,32)` fp16 case. It also passes after loading the UNet.

It fails only after a CLIP encode has run. The operation is innocent; the
ordering is the problem.

---

## 3. "The 4096x4096x512 GEMM is too big / not covered"

**Claim:** the VAE dies on a large GEMM the gfx1013 Tensile library doesn't
cover.

**Refuted twice:**

- The library covers it: 2289 size entries, M up to 3,818,566, three entries at
  exactly M=4096 N=4096. Tensile also selects by nearest neighbour, so a missing
  size cannot produce an error.
- The exact shape runs fine: **2.760 ms, 6.22 TFLOP/s, zero faults**, measured
  through torch with our library.

---

## 4. "Tuning Tensile will enable GPU VAE"

**Refuted** by 3 above, plus: the whole VAE decode at 512px works standalone on
the GPU (262 modules, zero faults). It only fails inside the pipeline.

Different problem entirely. Tuning is a performance question; the VAE is the
ordering bug.

---

## 5. "There's a 2x waiting in enabling packed fp16"

**Claim:** the kernels don't use `v_pk_fma_f16`, so half the hardware is idle.

**Refuted** by disassembling a generated half kernel. Packed *is* emitted — 49
occurrences. But in the **hot loop** it is 0/34: the loop is entirely
`v_fma_mix_f32`, driven by `HighPrecisionAccumulate`.

There is no free 2x. There is a *numerical trade* — turning HPA off would use
packed and roughly double the rate, at the cost of fp16 accumulation.

Also: whole-file instruction counts are misleading. Count the loop.

---

## 6. "Late code object loading is the mechanism"

**Claim:** a code object loaded late — after heavy allocation — gets a corrupted
address, so loading them early fixes it. This was the working theory for most of
the session and it explains the warmup.

**Weakened badly by:**

- a warmup that deliberately loads rocBLAS code objects early (the type ×
  transpose matrix) made things **worse** — it triggers the bug during startup
  and poisons the context
- the failing dispatch's AQL packet had a **correct** `kernel_obj`
  (`0x7f21c2a2a540`) — nothing corrupted in what the runtime produced
- failures appear in plain elementwise kernels (`sigmoid`), not only in
  newly-loaded ones

The warmup still works. The explanation for *why* does not.

---

## Also tried, also didn't work

| attempt | result |
|---|---|
| `amdgpu.sched_policy=2` (NO_HWS) | replaces the failure mode: `cp queue preemption time out`, `Failed to quiesce KFD`, `Resetting wave fronts (nocpsch)` |
| `HIP_ENABLE_DEFERRED_LOADING=0` | segfaults on a trivial torch program |
| `GPU_FORCE_QUEUE_PROFILING=1` | **worse** — hard crash with no traceback |
| `synchronize` + `empty_cache` between phases | fails at the same point |
| patching `count_nonzero` to run on CPU | passes that line, dies at the next one |
| `rocgdb` / wave debugging | `rocm-dbgapi`: *"architecture gfx1013 not supported"* |
| reading registers via `amdgpu_regs` | **hung the machine** |
| custom MIOpen build (March) | broke `conv2d`; the packaged one works |
| stacking extra warmups | see [03-warmup.md](03-warmup.md) — one is harmful |

---

## Method notes

Things that produced false results during the session, worth guarding against:

- **`kernel_obj` is not the code address.** It points at the kernel *descriptor*;
  the entry point is `kernel_obj + kernel_code_entry_byte_offset`. A comparison
  against `kernel_obj` was used to kill a hypothesis, wrongly.
- **"Falls inside a mapping" proves little.** 85% of the relevant address range
  was mapped in the test process. Measure the density before treating a hit as
  evidence.
- **Whole-file instruction counts mislead** for performance. Count the hot loop.
- **C comments never reach the binary.** Grepping a `.ko` for a patch comment
  proves nothing; use `srcversion`.
- **Parameter count doesn't identify a module.** Stock and patched CachyOS
  amdgpu both expose 99 parameters.
- **`pgrep -c` / `pkill -f` match the shell running them.** Filter on
  `/proc/PID/comm`.
