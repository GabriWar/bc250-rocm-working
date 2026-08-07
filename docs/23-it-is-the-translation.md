# It is the translation, measured — and an access through a second mapping repairs it

Measured 2026-08-07. This is the first **direct** measurement that the fault is
in address translation rather than in the data path. Everything before this was
elimination; this is observation.

It also **retracts** two things from
[17](17-a-gpu-le-fora-da-propria-tabela-de-pagina.md).

---

## The measurement

A page that the GPU delivers wrong is read again through a **second mapping of
the same physical memory**, created in another process with
`hipIpcGetMemHandle` / `hipIpcOpenMemHandle`. The first mapping is re-sampled at
every step, so each transition is trapped between two adjacent observations.

```
stage 0   60 re-reads through VA1, nothing else done ....  20/20 wrong, stable
stage 1   after hipIpcGetMemHandle ......................  20/20 wrong
stage 2   child mapped the same BO, has NOT read yet ....  20/20 wrong
stage 3   child READS through VA2 .......................  child reads CORRECT
                                                            VA1 -> 0/20
stage 4   child closed the handle and exited ............  0/20
```

Three independent runs, same trajectory every time. One run had two divergent
pages; both healed at the same stage.

## What it proves

**At stage 2, the first mapping is verifiably wrong — 20 reads out of 20 — and
the second mapping reads the same physical memory correctly.**

The error follows the **virtual address**, not the physical address.

That exonerates the data path. If the GPU's L2 were serving a wrong line for
that physical address — the tag-collision hypothesis that
[22](22-the-page-table-cache-is-innocent.md) left open — the second mapping
would read the same wrong bytes. It does not.

Combined with doc 22, which eliminated the walker's fetch of PDE/PTE, and with
doc 17's four observers (PTE written correct, PTE in memory correct, data at the
physical address correct), the fault is located:

> **The GPU resolves this virtual address to the wrong physical address.**
> Not the tables, not the walker's fetch, not the data cache, not memory.

**Caveat, stated plainly:** the second process differs from the first in *two*
ways — different VA and different VMID. This measurement cannot separate them.
Both are translation-side, so the conclusion above holds either way, but "which
of the two" is open.

## And an access through a second mapping repairs it

Stage 2 versus stage 3 is the other half of the result, and it is sharp:

- **Mapping the same BO into a second VM changes nothing.** Still 20/20 wrong.
- **Accessing it through that mapping repairs the first VM's translation
  immediately.** 20/20 → 0/20.

The repair is not caused by the mapping, the handle, or the process teardown. It
is caused by the **access**.

This is the first thing found that reliably clears the fault, and it costs a
read from another process. Whether it can be turned into a usable mitigation —
and whether a cheaper trigger has the same effect — is the obvious next
question.

---

## Retractions

### "Once established, it is deterministic and persists"

Doc 17 states that the aliasing persists once established, and that *"forced TLB
invalidation and rewriting do not recover the block"*. The recovery above
contradicts the second half directly: an ordinary read from another process
recovers it, every time.

### The oscillation reading, and the method error behind it

An intermediate measurement here reported that a divergent page **oscillated**
across consecutive re-reads — wrong, right, wrong, right — and that was written
up as "not a cache, because a cache would be consistent". **That was wrong, and
the cause was a flaw in the instrument.**

Pages were being classified as good or bad from a **single read**. Measured
properly, with 20 reads per page:

```
38 pages:   2 always wrong (200/200)   1 sometimes wrong   35 never wrong
control (pages correct in 20/20):  0 errors in 600 reads
```

Per page the behaviour is **deterministic** — 200/200 or 0/200, never a coin
flip. What exists alongside it is a smaller population of genuinely
intermittent pages, and *those* are what a single read misclassifies. One of
them landed in the control group and produced a reading of "even good pages
fail", which is false: the read path is solid, 0 errors in 600 control reads.

**The rule that comes out of this:** on this hardware a page cannot be labelled
good from one read. Every tool in this repository that classifies a page by a
single sample is suspect, and the two written today
(`tools/oscila.py`, `tools/quando_cura.py`, `tools/duas_vas.py`) now use 20.

### What survives of the "deterministic" claim

The alias target is **fixed per page**: a page that fails delivers the same
`(block, page)` every time, across 200 reads. Two examples measured in the same
run:

```
A8028160p0    200/200 wrong, always (6, 2)
A10485760p4   200/200 wrong, always (6, 0)
```

Block 6 is the round-B block of the **same size** as block 0 — the round-A/round-B
pairing doc 17 describes.

---

## Tools

| tool | what it decides |
|---|---|
| [`tools/duas_vas.py`](../tools/duas_vas.py) | same physical memory through a second VA — VA-indexed or PA-indexed |
| [`tools/quando_cura.py`](../tools/quando_cura.py) | which step of the sequence repairs the fault |
| [`tools/oscila.py`](../tools/oscila.py) | per-read or per-page; classifies with 20 reads and keeps a real control |

All three refuse to draw a conclusion when their controls fail: `duas_vas.py`
discards the run if the second mapping cannot read a known-good page, and if the
divergent page healed before the comparison; `quando_cura.py` only admits pages
that are wrong in 20 of 20.

## Next

1. **Find the cheapest trigger that repairs a translation.** The access from a
   second process works; a second mapping alone does not. Somewhere between
   those two is the smallest sufficient action, and it may be reachable from
   inside one process.
2. **Separate VA from VMID.** A second mapping in the *same* process, if it can
   be built, would decide which of the two the fault follows.
3. Re-read the fixed alias pairing (round A ↔ round B, same size) against the
   VA layout now that translation is confirmed as the location.
