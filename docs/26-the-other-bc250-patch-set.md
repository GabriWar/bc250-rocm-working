# 26 — The other BC-250 patch set, and where it meets ours

On 2026-08-08, `DryhoppedIPA` published
[bc250-gfx1013-fix](https://github.com/DryhoppedIPA/bc250-gfx1013-fix): three kernel
patches and three Mesa patches for this same board. A snapshot of it, pinned at
commit `65ef06ddc4d1`, is vendored in
[`third_party/bc250-gfx1013-fix/`](../third_party/bc250-gfx1013-fix/) with full
attribution and licence text — see that directory's `PROVENANCE.md`.

This document is our reading of it: what it fixes, what it confirms of ours, where
we think one of its claims does not hold, and the one idea in it that is directly
useful to a problem we are stuck on.

## The word "compute" means two different things

The repository's title is "compute queue fix", which reads like our territory. It
is not.

| | that patch set | this one |
|---|---|---|
| Subsystem | Vulkan async compute — the ACE rings, via RADV/Mesa | KFD / HSA compute — ROCm, PyTorch |
| Userspace | Mesa 26.2.0-rc3 | ROCm 6.x, PyTorch built for gfx1013 |
| Symptom fixed | corrupt frames, queue wedges | silently wrong tensors, hangs |
| Headline result | Cyberpunk 2077 1440p, +25% FPS | valid image out of ComfyUI, 13/18 dirty → 0/18 |

Neither substitutes for the other, and we have not run them together. A machine
wanting both needs both.

## Their finding, which is good and is not ours

The core of their Mesa patch is one line:

```c
info->has_async_compute_threadgroup_bug = info->family == CHIP_ICELAND ||
                                          info->family == CHIP_TONGA ||
                                          info->family == CHIP_GFX1013;
```

RADV has carried this workaround since GCN3 (Iceland, Tonga, 2015): async compute
dispatches in threadgroup-dimension mode with `PARTIAL_TG_EN` mis-execute, so those
dispatches are switched to thread-dimension mode. GFX1013 has the same defect and
was never added to the list.

The consequence they draw is the interesting part: the corruption everyone attributed
to "compute queues are broken on this chip" came from **RADV's own internal copy
shaders**, which use exactly that encoding — not from application shaders. That
explains why the queue was disabled wholesale rather than debugged.

That is a clean result on a stack we do not touch.

## What it independently confirms of ours

Their `patches/kernel/v33/0003-gfx1013-scoped-pasid-type0.patch` contains:

```c
-	if (adev->gfx.kiq[0].ring.sched.ready && !adev->enable_mes &&
+	if (!gfx1013_pasid_path &&
+	    adev->gfx.kiq[0].ring.sched.ready && !adev->enable_mes &&
```

That is the **second KIQ gate** — the one inside `gmc_v10_0_flush_gpu_tlb()` itself,
distinct from `adev->gmc.flush_pasid_uses_kiq` which the known community patch
targets. Doc 21 documents it as the reason that community patch is not sufficient on
its own. Two parties finding the same gate independently is worth more than either
finding it alone.

Their patch `0001` is the `flush_pasid_uses_kiq` half, scoped to `IP_VERSION(10,1,3)`
instead of by PCI device id. Same idea as the patch we already carry, cleaner scoping.

## Where we think it does not do what it says

Everything patches `0001` and `0003` change lives **inside the body of the VMID loop**
in `gmc_v10_0_flush_gpu_tlb_pasid()`. Neither patch touches the loop's entry
condition, which is unchanged upstream code:

```c
for (vmid = 1; vmid < AMDGPU_NUM_VMID; vmid++) {
	bool valid;

	valid = gmc_v10_0_get_atc_vmid_pasid_mapping_info(adev, vmid, &queried);
	if (!valid || queried != pasid)
		continue;
	...          /* <- everything both patches modify is below this line */
```

`valid` comes from reading `mmATC_VMID0_PASID_MAPPING + vmid`. As traced in doc 21
(and corrected there), the only gfx10 writer of that register,
`kgd_set_pasid_vmid_mapping()`, is reachable only through
`allocate_vmid()` → `create_queue_nocpsch()`. Under hardware scheduling —
`sched_policy = 0`, which both that board and this one run — queues are created via
`create_queue_cpsch()`, which never calls it.

Measured here: **20 of 20 invalidation attempts matched zero VMIDs**, and the same
empty table was reported independently on separate hardware.

If that holds on their board too, the loop body never executes and patches `0001`
and `0003` cannot affect anything. Which would mean their measured gain comes from
the Mesa series plus `0002` (the GFXOFF guard around compute idle, a real and
independent behavioural change) — not from the PASID work.

We have not tested this on their configuration and are not asserting it. It is cheap
to settle: a `printk` immediately after the `continue`, or

```sh
echo 'file gmc_v10_0.c +p' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

and one boot. If the loop body is entered, we are wrong and want to know.

One caveat in our own favour is worth stating: their target is graphics, where
`flush_gpu_tlb_pasid` is reached through `amdgpu_vm_handle_fault()` (retry faults)
rather than through `kfd_flush_tlb()`. The register is still not written for graphics
VMIDs — gfx10's `gmc_v10_0_emit_pasid_mapping()` writes `mmIH_VMID_0_LUT`, a
different register — so we expect the same empty table, but that is reasoning, not a
measurement.

## The idea in it that is useful to us

Patch `0003` does two things on the MMIO path that we never tried:

```c
+	if (gfx1013_pasid_path && vmhub == AMDGPU_GFXHUB(0) &&
+	    flush_type == 2)
+		flush_type = 0;
+
+	use_semaphore = gmc_v10_0_use_invalidate_semaphore(adev, vmhub) ||
+		(gfx1013_pasid_path && vmhub == AMDGPU_GFXHUB(0));
```

1. **Downgrade `flush_type` 2 → 0** on the GFXHUB.
2. **Force the invalidation semaphore on** for the GFXHUB. Upstream never does this:

```c
static bool gmc_v10_0_use_invalidate_semaphore(struct amdgpu_device *adev,
				       uint32_t vmhub)
{
	return ((vmhub == AMDGPU_MMHUB0(0)) &&
		(!amdgpu_sriov_vf(adev)));
}
```

`AMDGPU_GFXHUB(0) != AMDGPU_MMHUB0(0)`, so on the GFXHUB the semaphore is always off.

This lands exactly on where we stopped. Doc 22 records that forcing invalidation
fails both ways: through KIQ, `failed to write reg 28b4 wait reg 28c6` after 13 s;
through MMIO, `Timeout waiting for VM flush hub: 0!` after 172 ms **with no ACK
ever arriving**. Both of those were run with the default flush type and the default
(off) semaphore, because we had no reason to question either.

If the hub acknowledges under type 0 with the semaphore held, then direct
invalidation is possible on this chip after all — and that would be cheaper than
what we ship. Our fix rebuilds the runlist on *every* unmap, when only
reused-VA cases need it; doc 24 lists that as the open performance debt. A working
targeted invalidation would retire it.

This is a hypothesis with a clear negative result available. It is queued as its own
experiment; results will land in their own document, whichever way they go.

## If you are considering running both

- `install.sh` is Fedora-specific by its own admission — dnf, BLS boot entries,
  dracut, `grub2-editenv`. This machine is CachyOS.
- `0003-gfx1013-scoped-pasid-type0.patch` rewrites `gmc_v10_0_flush_gpu_tlb()` into
  an `_internal` variant. We modify the same function. **They will conflict**, and
  the merge has to be done by hand and understood, not forced.
- Their README is explicit: do not install the Mesa half on an unpatched kernel; it
  hangs.
- The 40-CU unlock they vendor is
  [duggasco/bc250-40cu-unlock](https://github.com/duggasco/bc250-40cu-unlock), which
  this machine already runs. Do not install it twice.
