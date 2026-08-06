# Community reports — none of this is verified here

Other BC-250 owners have reported the following. **Nothing on this page was
reproduced or measured on our board.** It is recorded because several items bear
directly on the open problem in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md), and because a lead we
never test is a lead we will keep re-deriving.

Treat every line as a claim to check, not as a finding. This repo has already
had to retract two leads that arrived this way.

---

## 1. It is reported to have worked on an older kernel and older ROCm

The strongest claim, and the one most worth testing. A user who rebuilt a
HIP workload for gfx1013 on a current stack could not get it to run, and
reported that the same work had run on an older distribution with an older
kernel and an older ROCm.

The stated reason was that RDNA 1 support was dropped and, this being an APU,
**memory is now mapped differently**.

Why this matters: that is the same layer our fault lives in. Doc 17 concludes
the GPU resolves a VA to physical memory its own page tables do not describe. If
an older stack does not do that, the defect is a **regression** with a bisectable
first-bad-commit, not a permanent property of the silicon — which would change
the entire approach from "work around it" to "find what changed".

A separate report names versions, which makes this checkable instead of vague:

| stack | reported behaviour |
|---|---|
| `5.10.0-hiveos #110.hiveos.220411` (a 2022 mining distribution) | ROCm reported the memory size correctly, and it **did not hang immediately** |
| Ubuntu 25.04, `6.14.0-33-generic` | the compute queue is said to work, but possibly not enough on its own |

Note the hedge in the first row — "did not hang immediately" is not "worked". It
is weaker than the claim above it, and both come from different people.

**Untested.** We have never run this board on an older kernel or an older ROCm.

## 1b. Driver and ROCm versions are reported to be coupled and fragile

From the same direction: that the driver has to be a specific version because
"newer ones broke it", and that ROCm version against supported PyTorch version
is its own compatibility puzzle.

This is consistent with item 1 but too vague to act on — no version is named.
Recorded so that if we do bisect, we remember the userspace may need to move
with the kernel rather than staying fixed.

**Untested, and unfalsifiable as stated.**

## 2. KIQ handling is reported to have moved from software to firmware

Separately, a comparison of an old mining-distribution kernel against a current
one reported that the older kernel handled KIQ exits **in software**, while the
newer one hands them to **firmware**.

If true, it is a plausible mechanism for item 1 and it explains why
`flush_pasid_uses_kiq = false` — the patch this repo already carries, see
[02-kernel-patches.md](02-kernel-patches.md) — is needed at all: forcing the
software path back.

**Untested.** We have not diffed the two kernels ourselves.

## 3. The same fault signature appears outside our stack

A stock board — 6 CPU cores, 20 CUs visible, no unlock — running a standard
OpenCL benchmark produced:

```
Memory access fault by GPU node-1 on address 0x7f9b65201000.
Reason: Page not present or supervisor privilege.
```

No PyTorch, no ComfyUI, no HIP — plain OpenCL through ROCm.

This one is corroboration rather than a lead: it argues the fault is not an
artefact of our stack, our unlock, or our build. Consistent with everything in
doc 17, where four independent observers agree and only the GPU disagrees.

**Not reproduced here** — we have not run OpenCL on this board.

## 4. Blender Cycles reportedly runs, and still crashes intermittently

A user who applied the same KIQ patch independently reports that Blender Cycles
runs on this board **on the shader path only** — HIP yes, HIP RT no — and that
it still crashed intermittently.

The intermittent crash is the interesting half. It is a completely different
application, on a different code path, with the same patch, still failing
occasionally. That is the behaviour doc 17 describes: bimodal per process,
not a race, no invariant found across 2266 collected pairs.

Worth asking whoever reports this whether the crash is random **with a fixed
scene** — if the same input crashes only sometimes, it is our signature and
becomes a second reproducer in an unrelated application.

**Untested.** We have not run Blender on this board.

## 5. A modprobe tweak reported to expose ~15 GB

Not about the fault, but the most immediately actionable thing on this page.
Raising TTM's page limit is reported to make roughly 15 GB usable, against the
board's default carve-out:

```
# /etc/modprobe.d/increase_amd_memory.conf
options ttm pages_limit=3959290 page_pool_size=3959290
```

3959290 pages × 4 KiB ≈ 15.1 GiB. A further ~1 GB is said to be eaten by the
kernel on top of that.

This is worth testing for two independent reasons. It would let larger models
run — but more interesting to us, **VRAM size is the last untested variable in
doc 17**: the corruption rate tracked it (20.4% at 512 MB, 15.7% at 4 GB, 12.0%
at 12 GB) and nothing has explained the trend. Pushing the limit up is another
point on that curve.

Careful, though: this raises TTM's system-memory pool, which is not the same
thing as the BIOS UMA carve-out that doc 17's measurements varied. They may not
be the same axis at all, and reading them as one would be exactly the kind of
mistake this repo has had to retract before.

**Untested.**

## 6. Not ours — a separate llama.cpp bug

Recorded only so it does not get mistaken for the above. A HIP build of
llama.cpp on gfx1013 aborts with:

```
GGML_ASSERT(max_blocks_per_sm > 0) failed
ggml/src/ggml-cuda/template-instances/../fattn-common.cuh:1110
```

That is an occupancy calculation returning zero for this target in the flash
attention kernel — an application-level bug, unrelated to address translation.
It produces a clean assert, not corrupted data.

---

## What to test first

Item 1, by a wide margin. It is the only claim that, if it holds, changes the
shape of the problem instead of adding another symptom to it.

The cheap version does not need an old distribution: keep our userspace and boot
an older kernel, then run `tools/hipmalloc_cru.py` — the ~2 minute reproducer at
~83% hit rate documented in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md). Twelve runs on each
kernel, per the three-repetitions-minimum rule this repo uses everywhere else.

The reproducer is what makes this worth doing at all. Every report above is
somebody's impression that things did or did not work; `hipmalloc_cru.py` turns
that into a number on the same scale we already have for the current kernel. A
clean result there is evidence. "It felt more stable" is not.

If the older kernel comes back clean, the next step is a bisect of the amdgpu
memory-mapping path between the two.

Second priority is item 5, which is a one-line modprobe change and reversible by
deleting a file — cheap enough that there is no reason to leave it untested.

Item 1b cannot be tested as written until somebody names a version.
