# Kernel patches

Two patches to `amdgpu`. One is required to use the GPU for compute at all; the
other stops the machine from dying when compute fails.

---

## 1. `flush_pasid_uses_kiq = false`  — REQUIRED

[`patches/02-amdgpu-flush-pasid-kiq.patch`](../patches/02-amdgpu-flush-pasid-kiq.patch)

`gmc_v10_0.c`, in `gmc_v10_0_hw_init()`:

```c
-	adev->gmc.flush_pasid_uses_kiq = !amdgpu_emu_mode;
+	adev->gmc.flush_pasid_uses_kiq = false;
```

### What happens without it

```
[143.9] amdgpu: timeout waiting for kiq fence
[143.9] amdgpu: TLB flush failed for PASID 5.
[156.9] amdgpu: timeout waiting for kiq fence
[165.9] amdgpu: qcm fence wait loop timeout expired
[165.9] amdgpu: The cp might be in an unrecoverable state due to an
                unsuccessful queues preemption
[165.9] amdgpu: process pid 2685 DQM create queue type 0 failed. ret -62
[165.9] amdgpu: GPU reset begin!. Source: 4
[170.0] amdgpu: MODE1 reset
[170.2] amdgpu: Timeout waiting for VM flush hub: 0!
[170.2] amdgpu: VRAM is lost due to GPU reset!
[170.7] amdgpu: [drm:amdgpu_ring_test_helper] *ERROR* ring sdma1 test failed (-110)
[170.7] amdgpu: resume of IP block <sdma_v5_0> failed -110
[170.7] amdgpu: GPU reset end with ret = -110
```

The GPU reset runs but **SDMA never comes back**. The card is present but dead
until reboot.

### Evidence

A/B, same machine, same session, both directions:

| module | result |
|---|---|
| patched | full SD pipeline, 2 images, 0 errors |
| **stock** | kiq fence timeout → CP unrecoverable → GPU reset → SDMA -110 |
| patched again | full pipeline again, same timings, 0 errors |

`srcversion` verified on each boot to confirm which module was actually loaded.

### A cautionary note

This patch was dismissed twice during the session before being tested:

- first as a "no-op", because `gmc_v10_0_flush_gpu_tlb()` has its own KIQ
  shortcut, so disabling the PASID path *looked* pointless;
- then as "incomplete", for the same reason.

Both readings were code-reading, not measurement. Both were wrong. The A/B
settled it in one reboot.

Credit: **neoney**, BC-250 community.

---

## 2. NULL guard in `amdgpu_ttm_tt_unpopulate`  — RECOMMENDED

[`patches/01-amdgpu-ttm-null-check.patch`](../patches/01-amdgpu-ttm-null-check.patch)

`amdgpu_ttm.c`:

```c
 	for (i = 0; i < ttm->num_pages; ++i)
-		ttm->pages[i]->mapping = NULL;
+		if (ttm->pages[i])
+			ttm->pages[i]->mapping = NULL;
```

### The panic

```
RIP: 0010:amdgpu_ttm_tt_unpopulate+0x77/0xd0 [amdgpu]
CR2: 0000000000000018
RAX: 0000000000000000  RBX: ffff8c72d0b6e180  RCX: 0000000000000000
Kernel panic - not syncing: Fatal exception
```

The faulting instruction:

```
48 8b 0b                  mov  (%rbx), %rcx           ; rcx = ttm->pages
48 8b 0c c1               mov  (%rcx,%rax,8), %rcx    ; rcx = pages[i]
48 c7 41 10 00 00 00 00   movq $0, 0x10(%rcx)         <- panic
```

`RCX = 0` → `pages[i]` is NULL. `struct page::mapping` sits at offset `0x18`,
and `CR2 = 0x18` confirms it: this is `NULL->mapping`.

### Why it matters

The compute bug makes GPU commands fail. A failed command can leave a buffer
object **partially populated**. On cleanup, TTM walks the page array and hits
the NULL — and the kernel dies.

So every compute fault had a chance of taking the whole machine with it. Four
hard hangs in one session, with unclean shutdowns, lost log files and truncated
scripts.

With the guard: the process dies, the machine lives.

### Status

Regression tested — image generation unaffected, byte-identical output:

| module | 1st (cold) | 2nd (warm) | images |
|---|---|---|---|
| original | 54.33s | 33.23s | 394900 / 379372 |
| original (2nd run) | 40.79s | 31.36s | 394900 / 379372 |
| **with TTM patch** | 42.22s | 33.16s | 394900 / 379372 |

Afterwards, a run that produced 2 page faults left the machine **up** —
`Kernel panic: 0`, uptime intact. Before the patch, faults during heavy work
frequently took the box down.

Two faults is an indication, not a proof. But it is the first time in the
session the machine survived them.

The missing NULL check is upstream code and probably worth reporting there.
