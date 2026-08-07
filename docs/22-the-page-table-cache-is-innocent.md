# The page-table cache is innocent, and the TLB is the last one standing

Measured 2026-08-07. This document closes the invalidation line opened in
[21](21-the-compute-tlb-is-never-invalidated.md), corrects two claims made
there, and eliminates one of the two remaining halves of the VA→PA path.

---

## Summary

| finding | status |
|---|---|
| Forcing invalidation of a **mapped** VMID hangs the board, on both routes | measured |
| The "unmapped VMIDs don't ACK" explanation in doc 21 | **retracted** — it was KIQ both times |
| `flush_pasid_uses_kiq = false` does **not** cover the inner KIQ gate | measured, and independently reported |
| At the hang: no translation fault anywhere; SDMA blocked, not busy | measured, from a coredump |
| `IS_XNACK` lives in `XNACK1`, not `XNACK0` | **retracted** decode, redone |
| **`FORCE_MISS` on the L2 page-table cache does not fix the corruption** | **measured, 6/10** |
| The only remaining candidate is the TLB itself | by elimination |

---

## 1. Forcing invalidation hangs the board — on every route

Doc 21 ended with a probe: invalidate the VMID the hardware actually uses
(VMID 8, read from `CP_HQD_VMID`) and see whether the corruption stops. The
probe never got to answer that question, because the invalidation itself does
not complete.

**First attempt, via KIQ:**

```
09:20:26  BC-250 tlb: FLUSH pasid=10 tipo=2 all_hub=0 seq=2
          (13 seconds)
09:20:39  failed to write reg 28b4 wait reg 28c6
09:20:41  ring sdma0 timeout / coredump / ring kiq_0.2.1.0 test failed (-110)
```

`0x28b4`/`0x28c6` are `vm_inv_eng0_req`/`_ack` + `eng_distance * 17` on the
GFXHUB — our flush and no other.

### The gate nobody had found

This board already sets `adev->gmc.flush_pasid_uses_kiq = false`. That was
supposed to keep TLB flushes off KIQ. It does not, because there is a **second,
independent** KIQ gate inside `gmc_v10_0_flush_gpu_tlb()`:

```c
if (!(bc250_flush_mapped_vmids && adev->pdev->device == BC250_PCI_DEVICE_ID) &&
    adev->gfx.kiq[0].ring.sched.ready && !adev->enable_mes && ...) {
        amdgpu_gmc_fw_reg_write_reg_wait(adev, req, ack, inv_req, 1 << vmid, ...);
        return;   /* KIQ */
}
```

The community patch that sets `flush_pasid_uses_kiq = false` only covers the
outer one. Nobody had noticed because the inner path was **dead code on this
board**: the PASID sweep never finds a VMID, so `gmc_v10_0_flush_gpu_tlb()` is
never reached with a user VMID. Our probe was the first thing to wake it.

A separate community patch guards this same gate with
`adev->pdev->device != 0x13fe`, arrived at independently. That half is correct.

**Second attempt, with KIQ bypassed:**

```
607.823597  invalidation of VMID 8 requested, GFXHUB engine 17
607.996026  Timeout waiting for VM flush hub: 0!   (172 ms, no ACK)
   ~608.12  next SDMA job starts
610.124562  that job never completed -> GPU reset
```

`sdma_timeout` is 2 s, so the job that died started **after** the failed flush.

### Retraction

Doc 21 explained the earlier `bc250_flush_all_vmids` failure as *"an unmapped
VMID never acknowledges"*. **That is wrong.** VMID 8 is mapped — confirmed by
`CP_HQD_VMID`, two live compute queues, stable across a whole run — and it fails
identically. Both failures were KIQ. The ATC guard in the community's
`flush_mapped_vmids` patch is therefore not load-bearing the way doc 21 claimed.

---

## 2. What the coredump says about the hang

Captured with a watchdog installed for the purpose (see
[Tooling](#tooling)), because `devcoredump` deletes itself after a few minutes
and the first one was lost.

**No translation fault, anywhere:**

```
GCVM_L2_PROTECTION_FAULT_STATUS  0x0
page fault reported at            0x0   (status 0x0 -- a placeholder, not a fault)
IS_XNACK on all four SDMA XNACK registers  0
```

**SDMA is blocked, not busy:**

```
mmSDMA0_STATUS_REG = 0x46dc7042
  IDLE=0  PACKET_READY=1  EX_IDLE=0     has work, not executing
  MC_WR_IDLE=1  MC_RD_IDLE=1            and no memory traffic at all
mmSDMA0_GFX_IB_SUB_REMAIN = 0xc         stopped mid-IB
mmSDMA0_GFX_RB_RPTR = 0x37c  !=  RB_WPTR = 0x400
```

A unit with a packet ready and both memory interfaces idle is waiting on
translation, not working.

**Honest limit:** the causal link between the failed invalidation and the SDMA
hang is temporal, not proven. SDMA completed one more job ~130 ms *after* the
flush gave up. The ordering is firm; the mechanism is inferred. The coredump
does not expose `GCVM_INVALIDATE_ENG17_REQ/ACK`, so whether the request stayed
pending is unmeasured.

### Retraction: the XNACK decode

An earlier reading of these registers decoded `IS_XNACK` out of
`SDMA0_UTCL1_RD_XNACK0`. Wrong register. Per `gc_10_1_0_sh_mask.h`, `XNACK0` is
`XNACK_FAULT_ADDR_LO` in its entirety; `IS_XNACK` is in **`XNACK1`**, bits
26–27. What had been dismissed as "residual garbage address bits" is the fault
address. Redone with the right field layout — the conclusion survived, but it
had been resting on the wrong register:

```
reg             ADDR (hi:lo)     VMID  VECTOR   IS_XNACK
SDMA0 inst0 RD  0x0:0011ecf0     0     0x484b   0
SDMA0 inst0 WR  0x0:0011ecf0     0     0xd4d5   0
SDMA0 inst1 RD  0x0:0011b900     0     0x181b   0
SDMA0 inst1 WR  0x0:0011ecf0     0     0x2c2d   0
```

---

## 3. The measurement that matters: the page-table cache is innocent

### The hypothesis

The VA→PA path inside the GPU has **two** distinct caches, and this
investigation had been treating them as one:

```
VA
 └─ UTCL1 / UTCL2 .......... cache of finished translations        [TLB]
     └─ miss -> walker
         └─ reads PDE1, PDE0, PTE from memory
             └─ those reads go through the L2 page-table line cache
                 └─ PA
```

A page-table block (PTB) is ordinary memory: it is freed and reallocated. If the
physical address of an old PTB is reused by a new one, the CPU writes the new
PTEs there (`vm_update_mode=3`), but the L2 could still serve the **old lines**
at that address. The walker would then read the previous generation's table.

That hypothesis fit an unusual amount:

- whole blocks resolving to other blocks' pages, in order, with a constant page
  offset — the layout of the old PTB
- bimodal per process, deterministic, persistent — depends on where this
  process's PTBs landed, and nothing ever evicts those lines
- the rate tracking VRAM size (20.4% at 512 MB, 15.7% at 4 GB, 12.0% at 12 GB) —
  less VRAM, more physical reuse of PTB addresses

### The test

`GCVM_L2_CNTL3` and `MMVM_L2_CNTL3` carry `FORCE_MISS` bits for exactly this
cache. `FORCE_MISS` makes it miss every time, re-reading the entry from memory
on every translation. **It requires no invalidation** — which is what makes it
usable here, where invalidation hangs the board.

Added as `bc250_l2_force_miss` (bitmask: 1 = 4K, 2 = BIGK, 4 = PDE), applied to
**both hubs**, since SDMA reaches memory through MMHUB and the corruption
reproduces through SDMA too.

Confirmed active in the register, not just in the parameter:

```
BC-250 L2/GFXHUB: force_miss=0x7 tag_mode=-1 bigk_opt_off=0 -> GCVM_L2_CNTL3=0xf0130009
BC-250 L2/MMHUB:  force_miss=0x7 -> MMVM_L2_CNTL3=0xf0130009
                                       bits 28, 29, 30 all set
```

### The result

```
0 0 1 1 2 1 1 0 1 0     ->  6 of 10 runs dirty, 7 blocks total
```

The prediction was **zero**. Baseline is ~7/10.

**The L2 page-table cache is not the source.** The walker re-reads PDE and PTE
from memory on every translation, memory is known correct, and the GPU still
delivers the wrong address.

This does not need a same-boot baseline arm to read: the hypothesis predicted
the absence of corruption, and the corruption is still there.

---

## 4. Where the defect is, by elimination

Every other stage of VA→PA now has its own measurement:

| stage | verdict | evidence |
|---|---|---|
| PTE the driver writes | correct | `amdgpu_vm_set_ptes` tracepoint |
| PTE in memory | correct | physical read of VRAM |
| data at the PA the PTE points to | correct | read with no VA involved |
| walker logic | does not err | `WALKER_ERROR=0x0`, `MAPPING_ERROR=0x0` |
| **walker's fetch of PDE/PTE** | **innocent** | **this test, 6/10 with the cache off** |
| translation refused | never happened | `IS_XNACK=0` ×4, fault status `0x0` |

One place is left: the **TLB** — UTCL1/UTCL2, the cache of finished
translations. It is the only point in the path that can return a PA without
consulting anything already verified.

It is also the only candidate that explains the fact nothing else ever fit:
**bimodal per process, deterministic, persistent**. A wrong TLB entry does not
heal — the same VA keeps hitting the same wrong entry for the life of the
process.

Combined with section 1, the two halves are one story:

> The TLB holds a translation it should not. The only mechanism that would
> correct that — invalidation — never runs on this board, and when forced does
> not complete and stalls the translation unit.

Those may be the same silicon defect seen from two sides.

### Caveat on the elimination

"PTE is correct" was measured by walking the tables **with the CPU**. That
proves memory is correct; it does not prove that what the GPU's walker reads is
correct. Section 3 is what closes that gap — with the cache forced to miss, the
walker must read memory, and memory is correct. The elimination rests on those
two together, not on the CPU-side walk alone.

### What is still not proven

That the wrong PA is a translation which was **ever valid** for that VA. The
2266 collected pairs record (expected PA, delivered PA) but were never checked
against that VA's *earlier* PAs. Until that is measured, "stale entry" and
"mis-tagged entry" are both open, and they imply different fixes.

---

## 5. On a community stress-test report claiming the flush works

A report circulated showing an aliasing stress test passing with the
mapped-VMID patch active: 4 concurrent workers, 200 iterations, 16 MB private
buffers per worker, "Cross-VMID corruptions: 0", "GPU errors in dmesg: 0", and
`BC-250: directly invalidating mapped VMIDs` as proof the patch is live.

Three independent gaps, none of which make the report dishonest — they make it
uninformative about this defect:

1. **`dev_info_once` prints before the loop.** It fires whether or not a single
   VMID is invalidated. Measured here with a counter placed *after* the loop:
   **20 of 20 flushes hitting zero VMIDs**, with that exact line in the log.
   This is the same error as reading `kfd_last_flushed_seq` as proof of effect.
2. **The metric is not this defect.** This bug is one process, one VMID, two
   live allocations of that same process aliasing each other. A cross-VMID
   counter reads 0 on it either way. And it is silent — valid data from another
   buffer arriving intact in the wrong place, not bits flipping, so
   "0 GPU errors in dmesg" measures nothing.
3. **The workload is in the regime that does not trigger.** Buffers allocated
   once and reused for 200 iterations is "kernels without new allocation",
   measured at **0 of 3**. Allocation and kernel execution must be interleaved.

There is also no baseline arm: without showing the same test dirty *without* the
patch, "ALL CLEAN" carries no information about the patch.

**The one line that would make it decisive** is a counter after the loop. If
that board reports > 0 VMIDs invalidated, its ATC table is populated where ours
is empty — and, more importantly, its hardware *completes* an invalidation that
ours stalls on. That would be the most informative outside datapoint so far.

### The counter was run, and it agrees

A follow-up report did exactly that, on a different machine, and reported:

```
0 VMID(s) flushed        -- the PASID check finds no mappings
```

**This is the single most useful outside datapoint so far.** The empty
VMID→PASID table is not a property of this machine or this configuration — it
reproduces on separate hardware. That closes the last opening for "our board is
simply misconfigured": nothing programs `mmATC_VMID*_PASID_MAPPING` on gfx10
under HWS, anywhere.

The same report concludes that the protection comes from the KIQ guard rather
than from the all-VMID flush. That is correct about **what it protects
against** — KIQ wedging, and the hangs and resets that follow. It is not
evidence about the aliasing defect, because the stress test used cannot observe
it: 5 rounds of 4–5 s covering 4000 worker-iterations leaves no room for the
allocate-and-free churn the trigger requires, and the metric counts cross-VMID
corruption and dmesg errors, neither of which this defect produces.

Two different real properties, measured with one test: the board is **stable**
with the KIQ guard, and separately it still **aliases**. Nothing in either
report contradicts the other.

---

## Tooling

`bc250-devcd-watch` — a system service that captures the amdgpu coredump before
it self-deletes, and kills the test process on the **first** crash signature in
the kernel log rather than waiting for the dump to appear. On the occurrence
measured here that is a 2.1 s difference in how long the reproducer hangs in
`dma_fence_default_wait` with a dead GPU.

The kill is deliberately narrow: only processes that have `/dev/kfd` open **and**
match the test paths. Validated both ways — kills the target within the same
second, and left a matching-cmdline process without `/dev/kfd` alive 3 of 3.

`tools/ab_l2_force_miss.sh` — measures whichever arm the current command line
selected, and **aborts** if `force_miss` is set but the driver never printed its
confirmation line, since nothing after that would mean anything.

## What was removed

`bc250_flush_vmid` and `bc250_flush_all_vmids` are gone from the tree. They
force an invalidation this board cannot complete, and every use ended in a GPU
reset. The measurements they produced are recorded above; the parameters
themselves are a loaded gun.
