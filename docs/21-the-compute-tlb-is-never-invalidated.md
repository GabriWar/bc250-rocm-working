# The compute TLB on this board is never invalidated

> **Continued, and partly corrected, in [22](22-the-page-table-cache-is-innocent.md).** The probe this page ends
> with never answered its question: forcing the invalidation does not
> complete on this hardware, on either route, and stalls the translation
> unit. The "unmapped VMIDs do not ACK" explanation below is retracted
> there. The core measurement -- zero VMIDs ever invalidated -- stands, and
> has since been reproduced on separate hardware.

Measured 2026-08-07, from inside the driver. This is the first mechanism that
accounts for every observation in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md) without any of them having
to be wrong, and it **supersedes the conclusions of
[20](20-why-the-compute-path-is-uncovered.md)**, which are retracted there.

---

## The measurement

A debugfs interface was added to amdgpu that walks the page-table hierarchy for
a given `(pid, VA)` from inside the driver, where the pointers are real —
[`patches/bc250-ptwalk-instrumentation.patch`](../patches/bc250-ptwalk-instrumentation.patch)
and [`patches/bc250-vmid-dump.patch`](../patches/bc250-vmid-dump.patch). Raw
output of 14 runs in
[`data/data-ptwalk-walks.txt`](../data/data-ptwalk-walks.txt).

Two things came out of it.

### 1. No VMID is ever invalidated

The dump of the hardware's VMID→PASID table, on every query:

```
  vmid  0  ATC=INVAL  pasid=0x0  pd=0x0
  vmid  1  ATC=INVAL  pasid=0x0  pd=0x0
  ...
  vmid 15  ATC=INVAL  pasid=0x0  pd=0x0
  >>> VMIDs whose ATC entry matches our PASID: 0
```

**80 VMID lines across 5 dumps. Every single one invalid. Zero valid entries.**

That dump is taken with the process **quiesced**, which leaves an obvious
objection: what if the firmware binds a VMID only while work is in flight, and
the table is populated exactly when it matters? A snapshot at rest would not
show it.

So the count was also taken **inside the invalidation itself**, at the moment
the flush runs, during a reproducer run that came back dirty (1 of 12 blocks
stomped):

```
BC-250 tlb: pasid=0xa tipo=2 -> 0 VMID(s) invalidados      (x20)

  20 flushes issued during real work
  20 of them hitting zero VMIDs
```

Both measurements agree, and the second is taken at the only moment that counts.
The table is not empty because we looked at the wrong time.

`gmc_v10_0_flush_gpu_tlb_pasid()` is the only TLB invalidation the compute path
has. It works by asking the hardware which VMID holds our PASID:

```c
for (vmid = 1; vmid < AMDGPU_NUM_VMID; vmid++) {
	valid = gmc_v10_0_get_atc_vmid_pasid_mapping_info(adev, vmid, &queried);
	if (!valid || queried != pasid)
		continue;
	gmc_v10_0_flush_gpu_tlb(adev, vmid, AMDGPU_GFXHUB(0), flush_type);
}
```

With the table empty, that loop sweeps all sixteen VMIDs, matches nothing, and
returns. **It invalidates nothing, every time.**

### 2. The page tables are correct at the pages that fail

For each failing page, the walk computes what the driver *should* have written,
using the same call the driver itself uses when writing PTEs
(`amdgpu_res_first()` over the BO's real physical fragments — `amdgpu_vm.c:1210`):

```
>>> offset in BO 0x400000 -> physical fragment 0x2edc00000 (mem_type=2)
>>> PA the driver should have written: 0x45dc00000
>>> VERDICT: the PTE is CORRECT.
```

Every verdict came back CORRECT, including the control — a page that did **not**
diverge. The control is what validates the method: if a page the GPU delivered
correctly had shown a wrong PTE, the instrument would be lying and the rest
discarded.

---

## Why the table is empty

Not a fault. It is empty by construction on this path.

A writer for `mmATC_VMID0_PASID_MAPPING` **does** exist on gfx10:
`kgd_set_pasid_vmid_mapping()` in `amdgpu_amdkfd_gfx_v10.c`. The register is not
missing support. It is on a code path this board never takes.

Follow the only chain that reaches it:

```
kgd_set_pasid_vmid_mapping()          amdgpu_amdkfd_gfx_v10.c
  <- set_pasid_vmid_mapping()         kfd_device_queue_manager.c:49
  <- allocate_vmid()                  kfd_device_queue_manager.c:673, called at :698
  <- create_queue_nocpsch()           kfd_device_queue_manager.c:763, calls at :782
```

`create_queue_cpsch()` — the CP-scheduling twin, `kfd_device_queue_manager.c:2126`
— never calls `allocate_vmid()`, so it never reaches the write.

This board runs `sched_policy = 0`, hardware scheduling: every user queue is
created through `create_queue_cpsch`. Under HWS the firmware assigns VMIDs and
the driver never programs the mapping registers. So the table the PASID-based
invalidation depends on is never populated.

> **Correction.** An earlier revision of this document claimed the register was
> written only in `amdgpu_amdkfd_gfx_v7.c` / `_v8.c` and merely read on gfx10.
> That is wrong — the gfx10 writer above exists. The measured result (zero VMIDs
> matched, 20/20) and the conclusion are unchanged; only the mechanism is stated
> correctly now. It matters because "the code is missing" and "the code is on the
> non-HWS path" imply different fixes.

### Our own workaround was blocked by the same hole

`bc250_flush_mapped_vmids` exists precisely to stop trusting the PASID query.
But its loop opens with:

```c
if (!gmc_v10_0_get_atc_vmid_pasid_mapping_info(adev, vmid, &queried))
	continue;
```

The same query. With every VMID reporting invalid, that branch also invalidates
nothing. That is why it measured as no-effect (5/6 against 5/6) — the workaround
was disabled by the defect it was written to work around.

### And the counter says it worked

`amdgpu_vm.c:1757`, in `amdgpu_vm_flush_compute_tlb()`:

```c
if (atomic64_xchg(&vm->kfd_last_flushed_seq, tlb_seq) == tlb_seq && ...)
	return 0;
...
r = amdgpu_gmc_flush_gpu_tlb_pasid(adev, vm->pasid, flush_type, ...);
```

The sequence counter is updated **before** the invalidation is attempted. So
`tlb_seq == kfd_last_flushed_seq` means "we entered the flush function", not "a
VMID was invalidated". 43 walks reported the counter up to date; the same runs
invalidated zero VMIDs.

**Measuring that counter measures bookkeeping, not effect.** An earlier version
of this investigation read it as effect and concluded invalidation was not the
mechanism. That was wrong.

---

## What it explains

| observation | fits |
|---|---|
| PTE correct at every failing page | yes — the tables were updated; the TLB never learned |
| 2 MiB granularity, 85 of 87 start-offsets | yes — the size of a large-page TLB entry |
| whole block substituted, constant page offset, 9 of 12 cases | yes — the previous mapping of that VA range |
| doubling real invalidations changed nothing (p=0.78) | **yes — twice zero is zero** |
| the CPU never fails on its own | yes — different MMU |
| reproduces through SDMA too | yes — shares UTCL2, equally never invalidated |
| needs allocation and kernel execution interleaved | yes — allocation changes the mapping, execution uses the stale entry |
| survives `HIP_LAUNCH_BLOCKING` and `AMD_SERIALIZE_*` | yes — those order host submission, not a translation cache |

The A/B in [`tools/ab_seq_skip.sh`](../tools/ab_seq_skip.sh) doubled the number
of invalidation *requests* — verified 2× leverage, 20 skipped against 20 issued —
and moved nothing. That was read at the time as evidence against the
invalidation path. It is the opposite: with zero invalidations landing, doubling
the requests cannot change anything.

---

## Proven, and inferred

**Proven by measurement:**

- Zero VMIDs match, on every query. 80 of 80 ATC entries invalid.
- The PTE is correct at every failing page, by the driver's own computation,
  with a control page validating the method.
- The sequence counter is updated before the attempt, so it cannot report
  effect.

**Inferred:** that the stale TLB entry is what the GPU reads. It is the only
mechanism left that fits, but it is an inference, not a measurement.

**The test that closes it:** invalidate all VMIDs unconditionally, ignoring the
empty query. If the corruption disappears, the inference is proven and the
defect is fixed. If it does not, this page joins the retraction list.

Caveat on n: the exact-PA verdict only existed in the last build, so it covers 5
walks. The VMID dump covers 5 queries, 80 lines. Both are small, but the ATC
result is structural rather than statistical — it is explained by source that
never writes those registers on this generation, so it is not expected to vary.

---

## What this retires

| hypothesis | how it died |
|---|---|
| Navi 1x errata, invalidation concurrent with translation | doc 20, retracted there; and there is no invalidation to be concurrent with |
| page-table content wrong | every verdict CORRECT, with control |
| page-table structure corrupted | 43 coherent walks |
| invalidation merely late or skipped | it is not late — it never happens |
| driver assigning the same PA to two live BOs | 0 of 40 cycles, doc 17 data |

---

## The fix to try

The driver cannot know which VMID belongs to a KFD process, because under HWS
nothing tells it. When the query yields nothing, the correct action is to
invalidate every VMID rather than none:

```c
/* gmc_v10_0_flush_gpu_tlb_pasid(): if no VMID claims this PASID, the
 * ATC table is empty -- which on gfx10 + HWS is the normal state, since
 * nothing programs mmATC_VMID*_PASID_MAPPING. Invalidating nothing leaves
 * stale translations behind. Invalidate all of them instead.
 */
```

Heavier than necessary, and correct. It is a few lines, and it is falsifiable
in one A/B against the reproducer we already have.

---

# Addendum — where the VMID actually is, and why "invalidate everything" fails

Two follow-up measurements, both zero-cost, that turn the bind into a plan.

## Invalidating every VMID does not work — *for the wrong reason*

> **RETRACTED.** This section originally concluded that invalidating all VMIDs
> fails because an unmapped VMID never acknowledges. That explanation is wrong.
> The real cause is KIQ, it applies equally to *mapped* VMIDs, and it says
> nothing about whether invalidating all sixteen is viable. See
> [Every forced invalidation was going through a wedged KIQ](#every-forced-invalidation-was-going-through-a-wedged-kiq)
> below.

The obvious response to "the sweep matches nothing" is to stop matching and
invalidate all sixteen. Measured, and it fails:

```
amdgpu 0000:01:00.0: failed to write reg 28b4 wait reg 28c6      (x14)
```

The reproducer, normally ~2 minutes, was still running at 3:07 when it was
killed. The failure is real; the explanation given for it was not.

## Every forced invalidation was going through a wedged KIQ

The probe below was run with `bc250_flush_vmid=8` — a VMID confirmed *mapped*
by `hqds`, with two live compute queues on it. It failed identically:

```
09:20:26  BC-250 tlb: FLUSH pasid=10 tipo=2 all_hub=0 seq=2
          (13 seconds)
09:20:39  failed to write reg 28b4 wait reg 28c6
09:20:39  BC-250 tlb: pasid=0xa -> VMID 8 invalidado (alvo fixo)
09:20:41  ring sdma0 timeout, signaled seq=280, emitted seq=282
09:20:41  ring kiq_0.2.1.0 test failed (-110)          -> GPU reset
```

A mapped VMID timing out the same way as an unmapped one kills the
"unmapped VMIDs never ACK" story. `0x28b4` and `0x28c6` are
`vm_inv_eng0_req`/`_ack` + `eng_distance * 17` on the GFXHUB, so this is our
flush and no other.

The actual cause is one condition in `gmc_v10_0_flush_gpu_tlb()`:

```c
if (!(bc250_flush_mapped_vmids && adev->pdev->device == BC250_PCI_DEVICE_ID) &&
    adev->gfx.kiq[0].ring.sched.ready && !adev->enable_mes && ...) {
        amdgpu_gmc_fw_reg_write_reg_wait(adev, req, ack, inv_req, 1 << vmid, ...);
        return;   /* KIQ */
}
```

Unless `bc250_flush_mapped_vmids` is set, every invalidation goes through KIQ —
and **this board's KIQ wedges on `INVALIDATE_TLBS`**, which is the reason that
knob exists at all. The path had never been exercised before, because the PASID
sweep never found a VMID to invalidate. The first thing to actually call it was
our own probe.

So the guard on the ATC query is **not** load-bearing the way this document
claimed. Invalidating all sixteen VMIDs may well be viable; it has never been
tested off the KIQ path. Both experiments have to be re-run with KIQ bypassed
before either result means anything.

## The VMID is discoverable, and it is not in any of the places the driver looks

| source | has it? |
|---|---|
| `mmATC_VMID*_PASID_MAPPING` (what the flush queries) | no — its gfx10 writer sits on the non-HWS path only; we run HWS |
| `dqm->vmid_pasid[]` (KFD's software table) | no — only filled by `create_queue_nocpsch`; we run HWS |
| `q->properties.vmid` | no — `kfd_priv.h:526` says "Not relevant for user mode queues in cp scheduling" |
| **`CP_HQD_VMID`, in the hardware queue descriptor** | **yes** |

`/sys/kernel/debug/kfd/hqds` already dumps every HQD, and `CP_HQD_VMID` is the
fourth dword of each queue's block (`mmCP_MQD_BASE_ADDR + 3`, the dump starts at
`mmCP_MQD_BASE_ADDR`). Sampled four times across one reproducer run that
corrupted:

```
t=20s  VMIDs in use: {0: 23 queues, 8: 2 queues}
t=45s  same          CP Pipe 0 Queue 2 = vmid 8
t=70s  same          CP Pipe 1 Queue 2 = vmid 8
t=95s  same
```

Two compute queues on **VMID 8**, stable for the whole run. The other 23 are the
kernel's, idle, on VMID 0.

So the information exists in hardware and is readable without patching
anything. It is simply not where `gmc_v10_0_flush_gpu_tlb_pasid()` looks.

## `bc250_flush_vmid` is a probe, not a fix

The parameter added here invalidates one hardcoded VMID when the query finds
nothing. It exists to answer one question — does invalidating the right VMID
stop the corruption? — before any engineering is spent on discovering it
properly.

It is wrong as a fix, in three ways:

- with two HIP processes, each gets its own VMID; it would invalidate only one
- if the firmware picks a different VMID, it points at nothing
- a flush requested for process A would invalidate whatever VMID is configured,
  which may belong to process B

**If the probe pays**, the real fix is to have KFD record the VMID once, after
`map_queues_cpsch` succeeds, into `q->properties.vmid` — the field that already
exists and sits unused under HWS. Then the flush walks the process's queues and
uses a stored value, with no MMIO on the hot path and correct behaviour for any
number of processes.

**If the probe does not pay**, none of that engineering is worth doing, and the
inference in this document joins the retraction list.

## This is probably not a BC-250 bug

The chain — PASID invalidation falls back to a register sweep, the sweep needs a
table, and that table is only populated outside HWS — is generic to gfx10. What
is specific to this board is that KIQ, the path AMD intended (the firmware
resolves the PASID), wedges here, so we disabled it and landed on the fallback.

Any gfx10 running HWS with KIQ unavailable would have the same silent hole.
Worth reporting upstream if the probe confirms it.
