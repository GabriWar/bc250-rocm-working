# The core bug — still unsolved

This is the thing that makes the BC-250 look like it can't run compute. It is
**not solved**. The warmup avoids it; nobody knows why it works.

---

## The invariant

Everything else we thought was the cause turned out to be wrong. What survived
every test:

> **The first heavy GPU phase works. The next one fails.**

Not the operation. Not the data type. Not the size. Not the kernel. The *order*.

Proved by inverting it:

| order | what fails |
|---|---|
| VAE decode → CLIP encode | the **CLIP** encode |
| CLIP encode → VAE decode | the **VAE** decode |
| UNet sampler → VAE decode | the **VAE** decode |
| 130 warmup kernels → `a.T @ b` fp16 64×64 | the **matmul** |

Same operations, different order, failure follows the second position.

---

## Every failure point we recorded

All different calls, all "the second heavy thing":

| log | call that failed | phase |
|---|---|---|
| `comfy-hws.log` | `hipblasGemmEx` | VAE decode (bf16) |
| `comfy-wf2.log` | `rocblas_gemm_ex` | VAE decode (fp16) |
| `comfy-wf2-fp32.log` | `hipblasSgemm` | VAE decode (fp32) |
| `vae_ad.log` | `hipblasSgemm`, `ops.py:351` | CLIP encode (`linear`) |
| `blas_first.log` | `sigmoid_kernel_cuda` | CLIP `quick_gelu` |
| ComfyUI, no warmup | `count_nonzero` → `reduce_kernel` | `samplers.py:967` |

GEMM, elementwise, reduction — three different kernel classes. It is not about
BLAS.

---

## The best evidence we have

The failing dispatch, with the full AQL packet dumped by the runtime:

```
Kernel Name: at::native::vectorized_elementwise_kernel<4, sigmoid_kernel_cuda...>
VGPU=0x7f2298000c80 SWq=0x7f2467b76000, HWq=0x7f23ac600000, id=1
  Dispatch Header = 0xb02 (type=2, barrier=1, acquire=1, release=1), setup=0
  grid=[59136, 1, 1], workgroup=[256, 1, 1]
  private_seg_size=0, group_seg_size=0
  kernel_obj=0x7f21c2a2a540, kernarg_address=0x7f23a6400000
  completion_signal=0x0
  rptr=4324, wptr=4326
```

Reading it:

- **It is a plain elementwise kernel.** `torch.sigmoid` inside CLIP's
  `quick_gelu`. Not BLAS, not a new code object.
- **Modest dispatch.** `59136 = 77 × 768` — CLIP's hidden state. 231 workgroups.
- **`kernel_obj` is correct.** `0x7f21c2a2a540`, an ordinary address. No
  corruption in the packet the runtime produced.
- **`completion_signal=0x0`** — dispatched fire-and-forget, with no completion
  signal.

That last line is the strongest open lead. It also reconnects with an April
investigation on the same board which concluded the MEC's completion-signal
delivery is unreliable — dispatches without a signal are the ones that vanish.

`AMD_SERIALIZE_KERNEL=3`, `HIP_LAUNCH_BLOCKING=1` and `AMD_SERIALIZE_COPY=3`
were **all active** and the dispatch still went out with no signal. Those
variables do not force completion signals, contrary to what earlier notes on
this board assumed.

---

## The page-fault signature

When it surfaces as a page fault rather than a HIP error, the pattern is very
consistent — 9 faults collected:

```
[gfxhub] page fault (src_id:0 ring:88 vmid:8)
  from client 0x1b (UTCL2)
  GCVM_L2_PROTECTION_FAULT_STATUS: 0x008012B0
  Faulty UTCL2 client ID: SQC (inst) (0x9)       <- INSTRUCTION fetch
  WALKER_ERROR: 0x0   MAPPING_ERROR: 0x0
  PERMISSION_FAULTS: 0xb   RW: 0x0
```

`SQC (inst)` means the GPU faulted **fetching shader instructions**, not data.

The addresses:

```
address            high byte   low 20 bits
0xffb5506bb000        0xff       0xbb000
0xffe8464bb000        0xff       0xbb000
0xff14126bb000        0xff       0xbb000
0xff550dabb000        0xff       0xbb000
0xff26f76bb000        0xff       0xbb000
0xfffd1e6bb000        0xff       0xbb000
0xff64aa2bb000        0xff       0xbb000
0x81cf24049000        0x81       0x49000
0x1f837bd19000        0x1f       0x19000
```

**7 of 9 have high byte `0xff` and identical low bits `0xbb000`**, across
different boots with ASLR active.

`0xff` looks less like a flipped bit and more like an **uninitialized value** —
all-ones. And `COMPUTE_PGM_HI` is exactly the 8-bit register holding address
bits [47:40] of the shader program:

```
COMPUTE_PGM_LO  (0x1bac)  address bits [39:8]
COMPUTE_PGM_HI  (0x1bad)  address bits [47:40]   DATA_MASK = 0x000000FF
```

An unwritten or all-ones `PGM_HI` combined with a correct `PGM_LO` would produce
exactly `0xff` + correct low bits.

**Caveat, stated plainly:** this hypothesis was dismissed mid-session on a
flawed argument — the "corrected" address was compared against `kernel_obj`
values and found far away. That comparison was invalid: `kernel_obj` is the
address of the *kernel descriptor*, not the code entry point (which is
`kernel_obj + kernel_code_entry_byte_offset`). The hypothesis deserves a proper
test.

### The test that would settle it

Read `COMPUTE_PGM_LO/HI` at fault time. Reading them from userspace via
`/sys/kernel/debug/dri/*/amdgpu_regs` **hung the machine** — do not.

The viable path: add a `dev_err` to amdgpu's page-fault handler that reads the
registers and prints them. The driver is already being patched anyway. If
`PGM_HI` reads `0xFF` at fault time, the root cause is identified.

---

## Not the MEC firmware

An earlier analysis of this board claimed `cyan_skillfish2_mec.bin` differs
substantially from `navi10_mec.bin` and doesn't program the compute program
address. **Both claims are wrong.**

Re-measured with an aligned diff (padding removed, branch targets normalized):

| earlier claim | actual |
|---|---|
| 76.5% identical | **98.49% identical** |
| ~12,000 divergent instructions | **2,779** aligned, 820 non-branch |
| cyan doesn't write 0x2E0C/0x2E0D | **it does — byte-identical code** |

Both firmwares write `COMPUTE_PGM_LO/HI` at two sites each, with identical
instruction sequences. The earlier "missing" finding came from a byte-offset
diff that mistook *shifted* code for *absent* code — cyan's second site sits at
`0x0dd04`, just below the analyzed window, while navi10's is at `0x0e344`,
inside it. A 0x640-byte shift, not different logic.

The code, identical in both:

```
ldw  r11, reg[r0, #0xf84c]   ; low dword of base address
ldw  r12, reg[r0, #0xf84d]   ; high dword
lsld r12, r12, #32
orrd r11, r12, r11           ; assemble 64-bit address
mov  r12, #0x40000
addd r11, r11, r12
addd r11, r11, #0x1000
ldw  r12, reg[r0, #0x2980]
lsld r12, r12, #24
addd r11, r12, r11
lsrd r12, r11, #40           ; bits [47:40]  -> COMPUTE_PGM_HI
lsrd r11, r11, #8            ; bits [39:8]   -> COMPUTE_PGM_LO
stw  r11, reg[r0, #0x2e0c]
stw  r12, reg[r0, #0x2e0d]
```

This also confirms the register semantics independently.

---

## Minimal reproducer: not found yet

We tried to shrink the reproducer to something that runs in seconds. It did not
reproduce:

```
130 warmup kernels (256×256 tensors) then a.T @ b fp16 64×64  ->  PASSES
```

But the same shape **does** fail inside ComfyUI after its warmups run. The
difference is something we have not isolated — probably total allocated memory
or total work volume, both untested at the time of writing.

Getting a fast reproducer is the single highest-value next step: the current
loop is a 5-minute ComfyUI run per hypothesis.

`tools/repro_min.py` is the scaffold; it takes a kernel count and reports
whether a trivial matmul survives.

---

## Open questions

1. Why does the runtime emit `completion_signal=0x0`, and can it be forced to
   always attach a signal?
2. What does `COMPUTE_PGM_HI` actually contain at fault time?
3. What is the missing variable that makes the small reproducer pass while
   ComfyUI fails?
4. Why does a warmup help at all? The "late code object loading" explanation was
   the working theory for most of a day and does not survive the evidence — a
   warmup that loads code objects early made things *worse*, and the failing
   dispatch had a perfectly good `kernel_obj`.
