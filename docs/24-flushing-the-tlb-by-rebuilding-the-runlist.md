# Flushing the compute TLB by rebuilding the runlist

Measured 2026-08-07. The first change that stops the corruption from being
generated: **13 of 18 dirty runs become 0 of 18**, counterbalanced within a
single boot, p = 3.7 × 10⁻⁶.

It is **not finished**. What is proven, what is not, and what is left to tune
are all below.

---

## Where the defect is born

```
1  VA→PA1 mapped and used         translation enters the TLB
2  hipFree → unmap → flush asked  <- THE PATCH ACTS HERE
3  the flush invalidates nothing  <- the wrong translation is born here
4  hipMalloc reuses the VA → PA2  new PTEs, correct in memory
5  access → hits the old entry    the symptom
```

Step 3 is measured, not assumed. `gmc_v10_0_flush_gpu_tlb_pasid()` sweeps VMIDs
looking for one that claims the PASID, using `mmATC_VMID*_PASID_MAPPING` —
a register that on gfx10 under HWS is **never written**. 20 of 20 flushes hit
zero VMIDs here, and the same `0 VMID(s) flushed` was independently reproduced
on separate hardware (doc 22).

Forcing it through MMIO does not work either: neither the KIQ route nor the
direct register route is acknowledged, and the attempt stalls the translation
unit and resets the GPU (doc 22, section 1).

## Why the runlist

Doc 23 measured something that turns out to be the way in:

| action | effect on a page that is 20/20 wrong |
|---|---|
| the process re-reads it, 60 times | still 20/20 wrong |
| the process touches 32 new pages | still 20/20 wrong |
| the process runs a compute dispatch | still 20/20 wrong |
| **another process accesses the GPU** | **0/20 — repaired** |
| another process maps the BO but does *not* access it | still 20/20 wrong |

A process cannot clear its own bad translation. The activation of a *second*
process clears it instantly. That activation is a **runlist change**: the
hardware scheduler preempts the queues, rebuilds the runlist and reassigns
VMIDs — and it must invalidate, or a process would inherit the previous one's
translations along with its VMID.

So an invalidation that works does exist on this silicon. It is simply not
reachable through any of the routes the driver uses. `execute_queues_cpsch()`
asks for exactly that cycle.

## The patch

`kfd_bc250_flush_by_runlist()` in `kfd_device_queue_manager.c`, called from the
unmap ioctl in `kfd_chardev.c`, behind `bc250_flush_by_runlist` (`0644`).

### The safety constraint that shaped it

The function takes `dqm_lock`. `kfd_flush_tlb()` **cannot** call it:
`restore_process_queues_nocpsch()` already holds that lock, and so do
`allocate_vmid()` / `deallocate_vmid()`. A deadlock there hangs the machine, not
just the GPU.

The only call site is therefore the unmap ioctl, which holds `p->mutex` and not
`dqm_lock` — the same order `pqm_create_queue()` already uses. The wrapper also
returns early if the device is not a BC-250, if there is no `dqm`, or if
scheduling is not hardware-managed.

### Validated before measuring anything

Turning a knob on and comparing rates without proving the new code runs is the
exact error this project criticised in an outside report. The counts here come
from the kernel's own function profiler (ftrace), not from a `printk`:

| | knob off | knob on |
|---|---|---|
| `kfd_bc250_flush_by_runlist` | 68 | 62 |
| **`execute_queues_cpsch`** | **6** | **68** |
| board errors | 0 → 0 | 0 → 0 |
| wall time | 7–9 s | 8 s |

62 extra forced preemptions, zero timeouts, zero `hws hang`, zero resets.

This mattered because an outside report describes larger GEMMs on this board
wedging with `cp queue preemption time out` — and `unmap_queues_cpsch()` escalates
a preemption timeout straight to `kfd_hws_hang()` and a GPU reset. At this load
it does not happen. At heavier loads it is **untested**.

## The result

36 runs, same boot, counterbalanced `0 1 1 0` blocks, each run stamped with its
own `execute_queues_cpsch` count so there is no ambiguity about which arm it was:

```
stock     13/18 dirty   [1 1 0 1 0 0 1 1 1 0 2 1 1 1 1 1 1 0]   72%
runlist    0/18 dirty   [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]    0%

Fisher exact, one-tailed: p = 3.7e-06
```

Same-boot counterbalancing is not cosmetic here. Earlier the same day, arm A
measured 6/10 in the morning and 1/6 in the afternoon on an identical command
line — **the base rate drifts across a session**, so no comparison between
measurements taken hours apart is valid. Only interleaved blocks are.

---

## What is not settled

### 1. ~~The mechanism is not confirmed~~ — it is now

`tools/pa_anterior.py` asks whether the delivered physical address was *ever*
this VA's translation. With full generation coverage:

```
run 1:  stale=4  foreign=0
run 2:  stale=6  foreign=0
run 3:  stale=5  foreign=0
        15 of 15 pages, three runs, zero exceptions
```

```
A8028160p0   should be 0x46f000000   delivered 0x45a000000   warmup gen = 0x45a000000
A8028160p1   should be 0x46f200000   delivered 0x45a200000   warmup gen = 0x45a200000
A8028160p2   should be 0x46f400000   delivered 0x45a400000   warmup gen = 0x45a400000
A8028160p3   should be 0x46f600000   delivered 0x45a600000   warmup gen = 0x45a600000
```

**The GPU translates through the previous generation's mapping of that VA**, and
the moment of birth is the `hipFree` whose invalidation never happened. The
patch acts at exactly that point, for exactly that reason.

#### How this was nearly reported backwards, twice

The first two versions of the instrument said the opposite — 1 stale against 8
"foreign" — and both times the cause was coverage, not a second mechanism:

1. The map used `dict.update()`, which overwrites. With 3 churn rounds only
   round 2 survived, so a PA matching round 0 or 1 was labelled "foreign".
2. Fixed, it still recorded only the churn. `aquecer()` runs ~52 conv2d before
   it, creating dozens of mappings through PyTorch's caching allocator at VAs
   that were never recorded. Every "foreign" verdict came from there — with
   `torch.cuda.memory_snapshot()` feeding the map, all of them resolve to
   `aq24`, a warmup generation.

**The asymmetry that should have been stated up front:** with partial coverage a
*positive* ("this PA was this VA's translation") is sound, and a *negative*
carries no information at all. Both wrong readings came from treating a negative
as evidence.

### 2. The real workload is untested

The reproducer allocates and frees with raw `hipMalloc`/`hipFree`. ComfyUI
allocates through PyTorch's caching allocator, under much heavier load. Zeroing
the reproducer does not prove zeroing ComfyUI.

### 3. Preemption under sustained heavy load is untested

See above — this is the failure mode an outside report describes, and it is the
one that would turn this patch from a fix into a reset generator.

### 4. Performance is unmeasured, and there is room

The patch rebuilds the runlist on **every** unmap: 68 per reproducer run, against
6 in normal operation. No cost was measurable at this load (8 s against 7–9 s),
but that is a null observation on a light workload, not a performance study.

There is obvious room to tune:

- **coalesce** — one cycle per batch of unmaps instead of one per unmap
- **only cycle when a VA range is actually being reused**, which is the only case
  that can produce a stale entry at all
- **cheaper trigger** — the measurement in doc 23 says an *access* from another
  context repairs, and a mapping alone does not. Somewhere between those two
  there may be a smaller sufficient action than a full runlist rebuild

With the mechanism now settled, all three are on the table. The second is the
most promising: a runlist rebuild is only needed when a VA range is about to be
reused, which is a small fraction of unmaps.

---

## Files

| file | what it is |
|---|---|
| [`patches/bc250-flush-tlb-by-runlist.patch`](../patches/bc250-flush-tlb-by-runlist.patch) | the patch |
| [`tools/pa_anterior.py`](../tools/pa_anterior.py) | was the delivered PA ever this VA's translation? |
| [`tools/cura_por_pressao.py`](../tools/cura_por_pressao.py) | eviction pressure or same-PA coupling? |
| [`tools/cura_propria.py`](../tools/cura_propria.py) | can a process repair its own translation? (no) |
| [`tools/oscila.py`](../tools/oscila.py) | per-read or per-page; classifies with 20 reads |
| [`data/data-ab-runlist.txt`](../data/data-ab-runlist.txt) | the 36 runs |
