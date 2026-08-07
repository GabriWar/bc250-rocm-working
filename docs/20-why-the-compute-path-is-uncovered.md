# Why the compute path is uncovered by an errata the graphics path is protected from

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
