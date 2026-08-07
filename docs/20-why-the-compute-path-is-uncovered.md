# Why the compute path is uncovered by an errata the graphics path is protected from

> **SUPERSEDED by [21](21-the-compute-tlb-is-never-invalidated.md).** The
> question this page opened — is the compute path exposed because its
> invalidation is unordered? — was answered by measurement, and the answer is
> different: on this board the compute TLB is **never invalidated at all**.
> The VMID to PASID table the invalidation depends on is empty, so the sweep
> matches nothing and returns. Ordering was never the issue; there is nothing
> to order. Keep this page for the path analysis, which stands.
>
> **RETRACTION, added after further source reading.** The addendum at the bottom
> of this page originally claimed that the `|| vmid` test in
> `amdgpu_gmc_flush_gpu_tlb()` was a *regression* that removed protection from
> user VMIDs, and proposed a patch to relax it. **That was wrong, and the patch
> would have made things worse.** The SDMA workaround cannot invalidate a
> specific user VMID at all — it ignores its own `vmid` argument. `|| vmid` is a
> correctness guard, not a narrowing. Details in
> [What the retraction changes](#what-the-retraction-changes) below. The
> graphics-versus-compute asymmetry described in the body still stands; the
> proposed fix does not.

Source analysis, done on the kernel this board actually runs
(`7.0.12-1-cachyos-bore-lto-bc250`). **No measurement here** — this is a reading
of the driver, prompted by a community report that Vulkan compute runs clean on
this silicon while ROCm does not (see
[19](19-community-reports-untested.md), section 1.5).

It produces a mechanism that fits everything in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md), and — more usefully — it
says the A/B we already ran was pointed the wrong way.

---

## The two paths never meet until very late

ROCm and Vulkan do not use two doors into the same allocator. They use two
allocators.

| | Vulkan / RADV | ROCm / HIP |
|---|---|---|
| device node | `/dev/dri/renderD*` | `/dev/kfd` |
| alloc ioctl | `amdgpu_gem_create` + `amdgpu_gem_va_ioctl` | `kfd_ioctl_alloc_memory_of_gpu` |
| memory manager | `amdgpu_gem.c` → `amdgpu_vm.c` | `amdgpu_amdkfd_gpuvm.c`, 3269 lines of its own |
| PTE flags | `gmc_v10_0_get_vm_pte` → `MTYPE_NC` | **same function, same `MTYPE_NC`** |
| TLB invalidation | `amdgpu_ring_emit_vm_flush` | `gmc_v10_0_flush_gpu_tlb_pasid` |

The fourth row matters: **the PTE flags are identical**. Both paths land in
`gmc_v10_0_get_vm_pte` and both take the `AMDGPU_VM_MTYPE_DEFAULT` branch to
`MTYPE_NC`. Whatever separates them, it is not cacheability or coherency
attributes on the mapping.

The fifth row is where they part, and it is the whole of this document.

## The errata

`amdgpu_gmc.c:743`, verbatim from the driver:

```c
/* The SDMA on Navi 1x has a bug which can theoretically result in memory
 * corruption if an invalidation happens at the same time as an VA
 * translation. Avoid this by doing the invalidation from the SDMA
 * itself at least for GART.
 */
```

Read that against doc 17's finding — the GPU resolving a VA to memory its own
page tables do not describe — and it is the same sentence written twice.

The workaround is real, and it is **enabled for our hardware**:

```c
/* gfxhub_v2_0.c:475 */
hub->sdma_invalidation_workaround = true;
```

## Who the workaround actually covers

`amdgpu_gmc.c:719`:

```c
if (!hub->sdma_invalidation_workaround || vmid ||
    !adev->mman.buffer_funcs_enabled || !adev->ib_pool_ready ||
    !ring->sched.ready) {
        /* ... plain register-write invalidation ... */
        return;
}
/* ... SDMA-based invalidation, the actual workaround ... */
```

`|| vmid` — **any non-zero VMID short-circuits to the unprotected path.** The
workaround only ever runs for VMID 0, which is the kernel's own GART. The
comment says so outright: *"at least for GART"*.

Every user process, graphics or compute, runs on VMID ≥ 1. None of them are
covered.

## So why would Vulkan be clean?

Because "uncovered by the workaround" and "exposed to the hazard" are not the
same thing. The hazard is an invalidation **concurrent with** a translation.
The two paths differ in exactly that:

**Graphics** — `amdgpu_vm.c:830`:

```c
amdgpu_ring_emit_vm_flush(ring, job->vmid, job->vm_pd_addr);
```

The invalidation is a **packet written into the command stream**. It is ordered
against the work on that ring by construction. The ring cannot be translating
for a draw that comes after a flush packet it has not reached yet.

**Compute** — `gmc_v10_0.c:385`, reached from
`gmc_v10_0_flush_gpu_tlb_pasid`:

```c
amdgpu_gmc_fw_reg_write_reg_wait(adev, req, ack, inv_req, ...);
```

The invalidation is an **MMIO register write issued by the host**, asynchronous
to whatever the CUs are doing at that instant. Nothing orders it against
in-flight translations.

And note `gmc_v10_0_flush_gpu_tlb_pasid` calls the low-level
`gmc_v10_0_flush_gpu_tlb` directly, in a loop over VMIDs — it does not go
through `amdgpu_gmc_flush_gpu_tlb` at all, so it never even reaches the guard
above. The compute path is not merely excluded by `|| vmid`; it is on a
different function that has no workaround in it to be excluded from.

That is a coherent mechanism for "Vulkan clean, ROCm dirty" without either
observation having to be wrong.

## This says our earlier A/B was pointed backwards

[`tools/ab_tlb_knobs.sh`](../tools/ab_tlb_knobs.sh) tested three knobs —
`all_hub`, `no_seq_skip`, `extra_types` — and none of them changed the
corruption rate. Every one of those knobs makes the driver invalidate **more**.

If the errata is the mechanism, more invalidation is more exposure, not less.
The knobs were asking "does insufficient flushing cause this?" when the errata
says the flush itself is the hazard. A null result there does not clear the TLB
path — it was never the question the errata poses.

The test that discriminates runs the other way: **invalidate less, or serialize
it**. Concretely, one of

- suppress the asynchronous process-wide flush entirely for a run and see
  whether the aliasing rate drops (correctness elsewhere will suffer; this is a
  diagnostic, not a fix),
- or route the compute invalidation through the same SDMA-based path the
  workaround uses for GART, which is what the errata says to do.

## It also survives what doc 17 already ruled out

Doc 17 shows the corruption reproduces under `HIP_LAUNCH_BLOCKING=1`,
`AMD_SERIALIZE_KERNEL=3` and `AMD_SERIALIZE_COPY=3`, and concludes it is not a
race. That conclusion stands and does not contradict this.

Those variables serialize **host-side submission** — one kernel dispatched and
waited on before the next. They do nothing to order a host MMIO register write
against address translation happening inside the GPU. A hazard between the
invalidation engine and the translation path is invisible to every one of them.

Likewise, doc 17's finding that the trigger needs allocation and kernel
execution **interleaved** — each alone gives 0 of 3 — is what this mechanism
predicts. Allocation is what causes a mapping change, which is what causes an
invalidation. Execution is what causes translation. The hazard needs both, at
the same time. Neither half alone can produce it.

## Status, and what this is not

**Not verified.** This is source reading plus one secondhand Vulkan result. In
particular:

- We have not run Vulkan compute on this board at all.
- The errata says "theoretically", and AMD shipped a workaround only for GART,
  which may mean they judged the user-VMID exposure to be negligible — or may
  mean nobody tested this silicon.
- Doc 17 collected 2266 pairs and found no address invariant. This mechanism
  does not predict one, which is consistent, but consistency is not evidence.

What makes it worth acting on is that it is the first hypothesis that explains
the interleaving requirement, the failure of the flush knobs, and the reported
Vulkan/ROCm asymmetry with a single cause, and it comes with a test that has
not been run.

## Next

1. Port the allocation-plus-dispatch churn from
   [`tools/hipmalloc_cru.py`](../tools/hipmalloc_cru.py) to a Vulkan compute
   path and run it the same number of times. This checks the community claim
   under a workload that actually contains doc 17's trigger, instead of a
   verifier that allocates once.
2. Run the flush knobs in the **subtractive** direction described above.
3. If both point the same way, the fix to try is routing compute invalidation
   through the SDMA path rather than the register path.

---

# Addendum — the 5.10 comparison, and what it changes

Source fetched from `git.kernel.org` at tag `v5.10` and compared against the
tree we run. This is still source reading, not measurement, but it is no longer
one-sided: the two kernels can be diffed directly, and they differ in exactly
the place this document predicted.

## The errata is older than the narrowing

The errata comment exists in 5.10 too, at `gmc_v10_0.c:323` — one revision
earlier in wording:

```c
/* 5.10 */
/* The SDMA on Navi has a bug which can theoretically result in memory
 * corruption if an invalidation happens at the same time as an VA
 * translation. Avoid this by doing the invalidation from the SDMA
 * itself.
 */
```

```c
/* 7.0 */
/* The SDMA on Navi 1x has a bug ... Avoid this by doing the invalidation
 * from the SDMA itself at least for GART.
 */
```

`at least for GART` is new. It is the comment admitting a narrowing.

## The guard is the regression

5.10, `gmc_v10_0.c:314` — the condition that falls back to the unprotected
register-write path:

```c
if (!adev->mman.buffer_funcs_enabled ||
    !adev->ib_pool_ready ||
    amdgpu_in_reset(adev) ||
    ring->sched.ready == false) {
```

**No VMID test.** Every VMID on the GFXHUB got the SDMA-based invalidation.

7.0, `amdgpu_gmc.c:719`:

```c
if (!hub->sdma_invalidation_workaround || vmid ||
    !adev->mman.buffer_funcs_enabled || !adev->ib_pool_ready ||
    !ring->sched.ready) {
```

`|| vmid` was added. Protection went from *all VMIDs* to *VMID 0 only* — from
every user process to none of them.

## And 5.10's primary compute path was ordered anyway

`gmc_v10_0_flush_gpu_tlb_pasid` in 5.10 does not start with a VMID loop. It
starts with KIQ:

```c
if (amdgpu_emu_mode == 0 && ring->sched.ready) {
        kiq->pmf->kiq_invalidate_tlbs(ring, pasid, flush_type, all_hub);
        r = amdgpu_fence_emit_polling(ring, &seq, MAX_KIQ_REG_WAIT);
        amdgpu_ring_commit(ring);
        r = amdgpu_fence_wait_polling(ring, seq, adev->usec_timeout);
        return 0;
}
/* only if KIQ is unavailable: loop VMIDs -> gmc_v10_0_flush_gpu_tlb */
```

That is an invalidation **packet on a ring, with a fence waited on** — ordered,
like the graphics path. The VMID loop was the fallback, and even the fallback
landed in the SDMA workaround because of the missing `|| vmid`.

So in 5.10, compute invalidation was ordered by one of two mechanisms. Neither
was a bare asynchronous MMIO write.

## Where that leaves us

| mechanism | 5.10 | this board, today |
|---|---|---|
| KIQ ring, fenced | primary | **disabled by our own patch** |
| SDMA workaround | all VMIDs | **VMID 0 only** (upstream narrowed it) |
| bare MMIO register write | emulation fallback only | **the only one left** |

Both of 5.10's ordered paths are gone, and they were removed by two unrelated
decisions that happen to compose badly:

1. Upstream added `|| vmid`, excluding user VMIDs from the workaround.
2. We set `flush_pasid_uses_kiq = false`, because KIQ `INVALIDATE_TLBS` wedges
   on this silicon — see [02-kernel-patches.md](02-kernel-patches.md). That
   patch is not optional; without it the CP wedges and GPU reset fails to
   restore SDMA.

Our own patch is half of the exposure. It is still the right patch — but it
solves a hang by moving us onto the path an errata says can corrupt memory, and
upstream had already removed the guard rail from that path.

This is also a mechanism for the community claim in
[19](19-community-reports-untested.md) section 1.1 that an older kernel worked,
without that claim needing to be about "memory being mapped differently" at all.

## The patch this suggests

Restore 5.10's coverage without restoring KIQ — drop the VMID exclusion, or
gate it to this device:

```c
/* amdgpu_gmc.c, amdgpu_gmc_flush_gpu_tlb() */
-       if (!hub->sdma_invalidation_workaround || vmid ||
+       bool bc250 = adev->pdev->device == BC250_PCI_DEVICE_ID;
+
+       if (!hub->sdma_invalidation_workaround || (vmid && !bc250) ||
            !adev->mman.buffer_funcs_enabled || !adev->ib_pool_ready ||
            !ring->sched.ready) {
```

That routes compute invalidation for user VMIDs back through the SDMA-submitted
path — the thing the errata explicitly tells you to do — while leaving KIQ
disabled.

Cost to check: one small patch, one module rebuild, then twelve runs of
`tools/hipmalloc_cru.py` against twelve on the current module. No new tooling.

**Predictions, so this is falsifiable:**

- If the mechanism is right, the aliasing rate should drop sharply, and the
  subtractive knob test in the section above should also reduce it.
- If the rate does not move, the errata is not our mechanism, and doc 17's
  conclusion stands unchanged — the exposure is real but is not what bites us.

Either outcome is worth the rebuild. This is the first hypothesis in this repo
that came with a specific upstream change, a specific line, and a patch small
enough to be wrong cheaply.

---

# What the retraction changes

## The mistake

The SDMA workaround block in `amdgpu_gmc_flush_gpu_tlb()` is this, in full:

```c
job->vm_pd_addr = amdgpu_gmc_pd_addr(adev->gart.bo);
job->vm_needs_flush = true;
job->ibs->ptr[job->ibs->length_dw++] = ring->funcs->nop;
amdgpu_ring_pad_ib(ring, &job->ibs[0]);
fence = amdgpu_job_submit(job);
dma_fence_wait(fence, false);
```

**The function's `vmid`, `vmhub` and `flush_type` arguments appear nowhere in
it.** It submits a NOP on the SDMA ring with `vm_needs_flush` set and
`vm_pd_addr` pointing at the GART page directory. What gets invalidated is the
VMID that kernel job runs under — VMID 0 — regardless of what the caller asked
for.

Compare the register path a few lines above, which does thread it through:

```c
adev->gmc.gmc_funcs->flush_gpu_tlb(adev, vmid, vmhub, flush_type);
```

So `|| vmid` is not upstream taking protection away. It is upstream saying: this
mechanism can only ever flush VMID 0, so anything else must take the path that
actually targets the VMID it was given.

The patch this page originally proposed would have routed user-VMID
invalidations into a function that flushes VMID 0 instead. Those VMIDs would
then never be invalidated at all — stale translations left live in the TLB.
That is a correctness bug, and plausibly a *worse* one than what we have.

## What the 5.10 comparison actually shows

The same code exists in 5.10 without the `vmid` test, so in 5.10 a call to
invalidate VMID *N* on the GFXHUB submitted an SDMA NOP that flushed VMID 0 and
left *N* alone. That is not "5.10 protected every VMID". It is **5.10 silently
skipping user-VMID invalidations** on that path.

It mattered less there because it was the fallback: 5.10's primary compute path
was KIQ (`kiq_invalidate_tlbs`, a packet on a ring with a fence waited on),
which does target the PASID correctly. The broken fallback only ran when KIQ was
unavailable.

So the honest version of the 5.10 story is the reverse of what was written here:
upstream **fixed** a missing-invalidation bug by adding `|| vmid`, and our
current kernel invalidates user VMIDs correctly where 5.10's fallback did not.

## What still stands

- The two paths really are separate allocators, and the PTE flags really are
  identical. Nothing about the mapping attributes distinguishes them.
- Graphics really does emit its invalidation inline in the command stream via
  `amdgpu_ring_emit_vm_flush`, and compute really does it with an asynchronous
  host MMIO write. That asymmetry is real and remains the most plausible reason
  a Vulkan workload could be clean where a HIP one is not.
- The errata is real and enabled for our GFXHUB.
- The observation that `ab_tlb_knobs.sh` only ever tested *more* invalidation
  still holds, and a subtractive test is still unrun.

## What no longer stands

- `|| vmid` as a regression. It is a fix.
- The proposed patch. Withdrawn; it would cause missing invalidations.
- "Route compute invalidation through the SDMA workaround" as a fix direction.
  That mechanism cannot target a user VMID, so there is nothing to route into.

## Where that leaves the fix space

If the hazard is invalidation concurrent with translation, the fix has to be an
invalidation that is **ordered against GPU work and targets a specific VMID**.
In this driver there is exactly one such mechanism, and it is KIQ — a packet on
a ring, fenced, addressed by PASID. Which is the thing we had to disable,
because `INVALIDATE_TLBS` wedges this silicon
([02-kernel-patches.md](02-kernel-patches.md)).

So the question this analysis actually leaves is narrower and less comfortable
than the one it started with: **why does KIQ `INVALIDATE_TLBS` wedge on this
board, and can that be fixed instead of bypassed?** Every ordered invalidation
mechanism the driver has runs through it.

That is a harder question than patching a guard, and it is not answered here.

## Method note

This page was written, published, and then found wrong within the same session,
by reading the twenty lines below the ones that had been read the first time.
The claim was checkable the whole time and was not checked before publishing.
Recorded because this repo has now had to retract three leads, and the pattern
in all three is the same: a mechanism that explained the symptom was accepted
before it was traced to the end.

---

# The three invalidation mechanisms, enumerated

Continued source reading after the retraction, to replace the wrong model with a
verified one. All three act on the same invalidation registers of the same hub;
they differ in who writes them and what they can address.

| | ring-emitted | host MMIO | KIQ packet |
|---|---|---|---|
| function | `gmc_v10_0_emit_flush_gpu_tlb` | `gmc_v10_0_flush_gpu_tlb` | `gfx10_kiq_invalidate_tlbs` |
| written by | the ring, as packets | the host, as MMIO | CP/MEC firmware |
| addressed by | **VMID** (`1 << vmid`) | **VMID** | **PASID** |
| ordered with GPU work | **yes**, it is in the command stream | **no** | yes, it is a ring packet |
| invalidation engine | the ring's own, 0–13 | **17**, dedicated | 11 (the KIQ ring's) |
| used by | graphics, and any job with `vm_needs_flush` | the KFD/compute path | what we had to disable |
| state here | works | works, but unordered | **wedges this silicon** |

Two things fall out of this table that were not obvious before.

**Engine collision is ruled out.** `gmc_v10_0_flush_gpu_tlb` hard-codes
`const unsigned int eng = 17`, and this boot assigns rings engines 0 through 13:

```
ring gfx_0.0.0    uses VM inv eng 0     ring comp_1.3.1  uses VM inv eng 10
ring comp_1.0.0   uses VM inv eng 1     ring kiq_0.2.1.0 uses VM inv eng 11
...                                     ring sdma0/1     uses VM inv eng 12/13
```

The host has a dedicated engine that no ring touches. Whatever the host-issued
invalidation does, it is not stomping a ring's invalidation registers. That was
worth checking and it is a clean negative.

**The ring-emitted path is the one to want, and we cannot reach it.** It is
ordered *and* VMID-targeted *and* needs no firmware PASID lookup — it is
strictly the best of the three. But it only exists as packets inside a ring
submission, and a KFD process's queues are user queues managed by the hardware
scheduler, not amdgpu rings the kernel can append to. There is no job to hang
the flush packets on.

KIQ is the mechanism AMD designed for exactly this gap — invalidate another
context's TLB, ordered, from the kernel — and it is a 2-dword packet whose
entire semantics live in MEC firmware:

```c
amdgpu_ring_write(ring, PACKET3(PACKET3_INVALIDATE_TLBS, 0));
amdgpu_ring_write(ring, DST_SEL(dst_sel) | ALL_HUB(all_hub) |
                        PASID(pasid) | FLUSH_TYPE(flush_type));
```

The driver contributes nothing but the request. If this board's MEC firmware —
a PS5-derived build — mishandles that packet, there is no driver-side fix, only
a bypass. Which is what `flush_pasid_uses_kiq = false` is.

## Where the evidence actually points, and where it does not

Being explicit, because this page has already been wrong once.

Doc 17 established, by measurement: the page tables are correct in physical
memory, the CPU reads the right data, forced TLB invalidation does not help, and
the corruption survives full host-side serialisation.

"Forced invalidation does not help" is uncomfortable for **both** invalidation
stories. If translations were stale, more invalidation should help — it did not.
If invalidation racing translation were the hazard, the picture is at least
consistent, but only because the knobs tested addition rather than subtraction.

So the honest position after this study is narrower than when the page opened:

- The **structure** is now verified — separate allocators, identical PTE flags,
  three invalidation mechanisms with the properties tabulated above.
- The **cause** is not. Nothing here promotes concurrent-invalidation from
  plausible to demonstrated, and one attempt to act on it was withdrawn.
- The cheapest remaining discriminator is still the one never run: the
  subtractive flush test, and a Vulkan port of the reproducer.

A caution for whoever runs those: the module currently loaded does **not**
export the `bc250_tlb_*` parameters that exist in the source tree, so the tree
and the running module are not the same build. Any A/B has to start by
rebuilding both arms from one tree, or it is measuring the build and not the
knob.
