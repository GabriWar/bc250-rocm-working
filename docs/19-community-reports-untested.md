# Community reports — none of this is verified here

Other BC-250 owners have reported the following. **Nothing on this page was
reproduced or measured on our board.** It is recorded because several items bear
directly on the open problem in
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md), and because a lead we
never test is a lead we will keep re-deriving.

Treat every line as a claim to check, not as a finding. This repo has already
had to retract two leads that arrived this way.

---

# Part 1 — bearing on the translation fault

## 1.1 It is reported to have worked on an older kernel and older ROCm

The strongest claim, and the one most worth testing. A user who rebuilt a HIP
workload for gfx1013 on a current stack could not get it to run, and reported
that the same work had run on an older distribution with an older kernel and an
older ROCm.

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
is weaker than the claim above it, and the two come from different people.

### The exact version, and where to get it

This is the only claim on the page that came with a version string, which is
what makes it the one worth acting on:

```
image   hiveos-0.6-217-stable
kernel  5.10.0-hiveos  #110.hiveos.220411
```

The images are still online at `download.hiveos.farm/history/`, and there is a
May 2022 snapshot in the Internet Archive of
`hiveos-0.6-217-stable@220423.img.xz`. An older `hiveos-0.6-212-stable@211201`
from December 2021 was also named as an alternative.

Mind the date mismatch: the kernel reported as tested is built `220411`, while
the retrievable image is stamped `220423`. Probably the same kernel, but check
`uname -a` after booting rather than assuming.

### Why this is not a one-variable test

Booting a 2022 kernel changes far more than the memory-mapping path. That kernel
predates everything this board depends on here:

| | on 5.10.0-hiveos |
|---|---|
| `flush_pasid_uses_kiq = false` | absent — but possibly unnecessary, see 1.2 |
| 40-CU unlock | absent, so 24 CUs |
| `cyan-skillfish-governor-smu` | absent, so no clock control |
| GPU telemetry patches | absent |
| ROCm | whatever that era shipped |

So a clean result on that kernel does **not** by itself mean "the kernel is the
variable" — it could equally be the CU count, the clock behaviour, or the ROCm
version. It is still the right first move, because a *dirty* result kills the
whole hypothesis cheaply, and a clean one earns the follow-up work of narrowing
which of those five things mattered.

**Untested.** We have never run this board on an older kernel or an older ROCm.

## 1.2 KIQ handling is reported to have moved from software to firmware

A comparison of an old mining-distribution kernel against a current one reported
that the older kernel handled KIQ exits **in software**, while the newer one
hands them to **firmware**.

If true, it is a plausible mechanism for 1.1, and it explains why
`flush_pasid_uses_kiq = false` — the patch this repo already carries, see
[02-kernel-patches.md](02-kernel-patches.md) — is needed at all: it forces the
software path back.

**Untested.** We have not diffed the two kernels ourselves.

## 1.3 ROCm has a documented history of breaking this GPU family

The most specific version history anyone has offered, quoted secondhand:

- **ROCm 5.2** is described as the "last known good" version for RDNA 1 cards.
- **ROCm 5.3 through 6.0** broke `gfx101*` support; it was **fixed again in 6.1**.
- **After 6.1** there are said to be significant performance regressions for this
  target that were not present in 5.2.

There is an upstream discussion thread on the ROCm performance regression
(`ROCm/ROCm` discussion 4030) which may or may not cover Cyan Skillfish.

This is the same shape as 1.1 but on the userspace side, and it suggests that if
we do bisect, holding userspace fixed while moving the kernel may not isolate
anything — both halves have their own regression history.

**Untested.**

## 1.4 The same fault signature appears outside our stack

A stock board — 6 CPU cores, 20 CUs visible, no unlock — running a standard
OpenCL benchmark produced:

```
Memory access fault by GPU node-1 on address 0x7f9b65201000.
Reason: Page not present or supervisor privilege.
```

No PyTorch, no ComfyUI, no HIP — plain OpenCL through ROCm.

Corroboration rather than a lead: it argues the fault is not an artefact of our
stack, our unlock, or our build. Consistent with doc 17, where four independent
observers agree and only the GPU disagrees.

**Not reproduced here** — we have not run OpenCL on this board.

## 1.5 Vulkan compute is reported clean, and that is a discriminator

The most interesting item on this page after 1.1. A Vulkan compute verifier run
on a 40-CU board:

```
device=AMD BC-250 (RADV GFX1013) queue_family=0 elements=16777216 passes=3
pass=0  errors=0  int_errors=0  fp_errors=0
pass=1  errors=0  int_errors=0  fp_errors=0
pass=2  errors=0  int_errors=0  fp_errors=0
summary total_checked=100663296 errors=0 int_errors=0 fp_errors=0
```

**100 million elements checked, zero errors.**

If that holds, the fault is not "the GPU cannot address memory correctly" in
general — it is specific to how the ROCm/HIP path allocates, maps, or reaches
memory, and the Vulkan/RADV path does something different that avoids it. That
is a much narrower target than what doc 17 currently describes, and it is
directly testable: run the same shape of allocation-plus-dispatch churn as
`tools/hipmalloc_cru.py` through Vulkan and see whether it stays clean.

The caveat is that a verifier which allocates once and dispatches three times is
not the same workload as doc 17's reproducer, which specifically needs
**allocation and kernel execution interleaved** — each alone gives 0 of 3. A
clean result may mean the path is fine, or may mean the trigger was never
present. Do not read it as exoneration of Vulkan until the workloads match.

**Untested here.** The source-level reading of *why* the two paths could
differ is in [20](20-why-the-compute-path-is-uncovered.md), and it turns out to
reframe an A/B we already ran.

## 1.6 Blender Cycles reportedly runs, and still crashes intermittently

A user who applied the same KIQ patch independently reports that Blender Cycles
runs on this board **on the shader path only** — HIP yes, HIP RT no — and that
it still crashed intermittently.

The intermittent crash is the interesting half: a completely different
application, a different code path, the same patch, still failing occasionally.
That is the behaviour doc 17 describes — bimodal per process, not a race, no
invariant found across 2266 collected pairs.

Worth asking whether the crash is random **with a fixed scene**. If the same
input crashes only sometimes, it is our signature and becomes a second
reproducer in an unrelated application.

**Untested.** We have not run Blender on this board.

---

# Part 2 — bearing on performance and build

## 2.1 No ROCm library ships a build config for gfx1013

Reported, and it matches what this repo has run into independently:

> none of the rocm libraries have build configs for gfx1013 in any of the
> versions I checked, but they have gfx1010-1012

The workaround everyone converges on is to build for **gfx1010** and run with
`HSA_OVERRIDE_GFX_VERSION=10.1.0`, on the reasoning that the gfx1013 ISA is a
superset of gfx1010. Also reported: **do not** build gfx1030 code for it, which
is a different ISA and which some toolchains will default to.

This is the direct explanation for two open items in this repo — tuning Tensile
for gfx1013, and the MIOpen `im2col` path. We are not tuning a target the
libraries know about; we are running gfx1010 kernels on gfx1013 silicon.

Separately reported: the gfx1013 assembler instruction set is RDNA 1 with
ray-tracing instructions added on top. That is consistent with the superset
claim.

**Partially corroborated here** — this repo already builds this way. The claim
that *no* version has gfx1013 configs is the untested part.

## 2.2 bf16 is absent, confirmed through a second API

Doc 18 records `HIPBLAS_STATUS_INTERNAL_ERROR` on `HIP_R_16BF` through ROCm. A
Vulkan capability probe on a 40-CU board reports the same absence from the other
side:

```
BF16 compute bf16xbf16+fp32
  bf16 : [unsupported] VK_KHR_shader_bfloat16 / shaderBFloat16Type not supported
```

And, more sweepingly, **every cooperative-matrix path is missing**:

```
coopmat_fp32     : [unsupported] no 16x16x16 property
coopmat_fp16     : [unsupported] no 16x16x16 property
coopmat_bf16     : [unsupported] no 16x16x16 property
coopmat_fp8_e4m3 : [unsupported]
coopmat_fp8_e5m2 : [unsupported]
coopmat_int8     : [unsupported] no 16x16x{16,32} property
```

There are no matrix cores on this silicon, in any precision. A separate Vulkan
probe independently reports `fp16-matrix = 0.00 GFLOPS`.

This is not a limitation to work around — it is the ceiling. Doc 18's conclusion
that fp32 is the correct dtype for Z-Image, not a fallback, is reinforced by it.

## 2.3 Independent clpeak numbers, on boards with more CUs than ours previously had

Two runs worth keeping as reference points. OpenCL, 20 CUs:

```
float    7194 GFLOPS      half     7573 GFLOPS
float4   7551             half2   15000          <- packed math, 2x
double    475             mp(fp16xfp16+fp32) 3794
int      1523 GOPS
char     7554 GOPS        char2    4176          <- FALLS, no vectorised 8-bit
INT8 dot-product : [unsupported] cl_khr_integer_dot_product not supported
```

Vulkan, 40 CUs:

```
float    7614 GFLOPS      half2   15129 GFLOPS
double    475             int      1304 GOPS
global memory bandwidth  ~400 GB/s (float4)
transfer h2d / d2h       ~198 GB/s
kernel launch latency    dispatch 16.6 us, roundtrip 29.9 us
```

Note fp32 barely moves between 20 CUs and 40 CUs (7194 → 7614). Either these are
clock-bound rather than CU-bound at this shape, or the extra CUs are not being
fed — worth knowing before attributing any speedup to the unlock.

The `char` against `char2` inversion reproduces the int8 finding this repo
already recorded, on a different board and a different API: `half2` doubles,
`char2` falls. There is no vectorised 8-bit path, and OpenCL reports the
dot-product extension as flatly unsupported.

## 2.4 A modprobe tweak reported to expose ~15 GB

Not about the fault, but the most immediately actionable thing on this page:

```
# /etc/modprobe.d/increase_amd_memory.conf
options ttm pages_limit=3959290 page_pool_size=3959290
```

3959290 pages × 4 KiB ≈ 15.1 GiB. A further ~1 GB is said to be eaten by the
kernel on top of that.

Worth testing for two independent reasons. It would let larger models run — but
more interesting to us, **VRAM size is the last untested variable in doc 17**:
the corruption rate tracked it (20.4% at 512 MB, 15.7% at 4 GB, 12.0% at 12 GB)
and nothing has explained the trend.

Careful, though: this raises TTM's system-memory pool, which is not the same
thing as the BIOS UMA carve-out that doc 17's measurements varied. They may not
be the same axis at all, and reading them as one would be exactly the kind of
mistake this repo has had to retract before.

**Untested.**

## 2.5 Not ours — a separate llama.cpp bug

Recorded only so it does not get mistaken for the above. A HIP build of
llama.cpp on gfx1013 aborts with:

```
GGML_ASSERT(max_blocks_per_sm > 0) failed
ggml/src/ggml-cuda/template-instances/../fattn-common.cuh:1110
```

An occupancy calculation returning zero for this target in the flash-attention
kernel — an application-level bug, unrelated to address translation. It produces
a clean assert, not corrupted data.

---

# What to test, in order

**First: 1.5, Vulkan against HIP.** It is the cheapest test with the highest
information content, it needs no reboot, and it splits the problem in half
whichever way it lands. Port the allocation-plus-dispatch churn from
`tools/hipmalloc_cru.py` to a Vulkan compute path and run it the same number of
times. If Vulkan stays clean under a workload that actually matches doc 17's
trigger, the fault is in the ROCm path and not the silicon's addressing.

**Second: 1.1, the older kernel.** The cheap version does not need an old
distribution — keep our userspace and boot an older kernel, then run
`tools/hipmalloc_cru.py`, the ~2 minute reproducer at ~83% hit rate documented
in [17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md). Twelve runs on each
kernel, per the three-repetitions-minimum rule this repo uses everywhere else.
If the older kernel comes back clean, bisect the amdgpu memory-mapping path.

The reproducer is what makes any of this worth doing. Every report above is
somebody's impression that things did or did not work; `hipmalloc_cru.py` turns
that into a number on the same scale we already have for the current kernel. A
clean result there is evidence. "It felt more stable" is not.

**Third: 2.4**, a one-line modprobe change, reversible by deleting a file.

**Fourth: 2.1**, which is not a test but a correction to how we think about
[05-tensile-tuning.md](05-tensile-tuning.md) — we have been tuning a target the
libraries do not have configs for.

**Cannot be tested as written:** 1.3 names ROCm versions but we have no record
of which our results came from; 1.2 needs the two kernel trees side by side.
