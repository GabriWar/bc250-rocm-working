# The corrupted instruction-fetch address

When the compute bug surfaces as a page fault rather than a HIP error, the
faulting address has a very specific shape. This file collects everything
measured about it.

Whether "bit flip" is the right name is unclear — the data looks more like an
**uninitialized register** than a flipped bit. Both readings are laid out below.

---

## The faults

Nine page faults collected across different boots, ASLR active:

| address | high byte | low 20 bits | client |
|---|---|---|---|
| `0xffb5506bb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0xffe8464bb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0xff14126bb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0xff550dabb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0xff26f76bb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0xfffd1e6bb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0xff64aa2bb000` | `0xff` | `0xbb000` | SQC (inst) |
| `0x81cf24049000` | `0x81` | `0x49000` | SQC (inst) |
| `0x1f837bd19000` | `0x1f` | `0x19000` | SQC (inst) |

**7 of 9 share the high byte `0xff` and identical low bits `0xbb000`.**

Across separate boots, with address-space randomisation on. That is not noise.

Full dmesg shape, identical every time:

```
[gfxhub] page fault (src_id:0 ring:88 vmid:8)
  from client 0x1b (UTCL2)
  GCVM_L2_PROTECTION_FAULT_STATUS: 0x008012B0
  Faulty UTCL2 client ID: SQC (inst) (0x9)
  MORE_FAULTS: 0x0   WALKER_ERROR: 0x0
  PERMISSION_FAULTS: 0xb   MAPPING_ERROR: 0x0   RW: 0x0
```

`SQC (inst)` is the sequencer **instruction** cache. The GPU faulted fetching
shader code, not data. `RW: 0x0` — a read.

---

## Why `COMPUTE_PGM_HI` is the suspect

The shader program address is split across two registers:

```
COMPUTE_PGM_LO  (0x1bac)   address bits [39:8]
COMPUTE_PGM_HI  (0x1bad)   address bits [47:40]   DATA_MASK = 0x000000FF
```

`COMPUTE_PGM_HI` is exactly 8 bits wide and holds exactly the byte that is
wrong. `COMPUTE_PGM_LO` holds the 40 low bits — the ones that stay plausible.

The MEC firmware itself confirms this split. Disassembled from
`cyan_skillfish2_mec.bin` (identical in `navi10_mec.bin`):

```
lsrd r12, r11, #40           ; bits [47:40]
lsrd r11, r11, #8            ; bits [39:8]
stw  r11, reg[r0, #0x2e0c]   ; COMPUTE_PGM_LO
stw  r12, reg[r0, #0x2e0d]   ; COMPUTE_PGM_HI
```

An unwritten or all-ones `PGM_HI` combined with a correct `PGM_LO` produces
exactly `0xff` + correct low bits — which is what 7 of 9 faults look like.

Substituting `0x7f` for the high byte gives addresses in the process's normal
range:

```
0xffb5506bb000  ->  0x7fb5506bb000
0xff64aa2bb000  ->  0x7f64aa2bb000
0x1f837bd19000  ->  0x7f837bd19000
```

---

## Where this was wrongly dismissed

Mid-session this hypothesis was discarded on a bad argument, twice:

**Bad argument 1.** The "corrected" address was compared against the
`kernel_obj` values from AQL packets and found hundreds of MB away, so it
"couldn't be a code address".

That comparison is invalid. `kernel_obj` points at the **kernel descriptor**,
not the entry point — the code starts at
`kernel_obj + kernel_code_entry_byte_offset`, a 64-bit field inside the
descriptor. The right comparison was never made.

**Bad argument 2.** The corrected address was checked against `/proc/pid/maps`
and found inside a mapped `/dev/dri/renderD128` region — presented as
confirmation. It isn't: **85% of that address range is mapped** in this process,
so landing in a mapping carries almost no information. Measured, not assumed.

Also worth recording: at one corrected address the memory contained fp16 values
with mean +0.00004 and stdev 0.059, all within ±0.25 — a textbook neural-network
weight distribution, not shader code. That argues against that particular
address being a code location, but it was one sample and the descriptor mistake
above was never corrected for.

---

## What would settle it

Read `COMPUTE_PGM_LO/HI` at fault time.

**Do not** read them from userspace via `/sys/kernel/debug/dri/*/amdgpu_regs`.
That was tried and **hung the machine**.

The viable path: since `amdgpu` is being patched anyway, add a `dev_err` in the
page-fault handler that reads both registers and prints them. If `PGM_HI` reads
`0xFF` at fault time, the root cause is identified and the question becomes why
it is never programmed on this silicon.

---

## What this is not

**Not a firmware bug.** The MEC firmware writes both registers, at two sites,
with code byte-identical to navi10's. Re-measured with an aligned diff:
98.49% identical, zero divergent register accesses. An earlier analysis claiming
76.5% similarity and missing `0x2E0C/0x2E0D` writes was an artifact of a
byte-offset diff mistaking shifted code for absent code.

**Not memory corruption in the packet.** The AQL packet of a failing dispatch
carried `kernel_obj=0x7f21c2a2a540` — an ordinary, uncorrupted address. Whatever
goes wrong happens after the runtime hands the packet over.
