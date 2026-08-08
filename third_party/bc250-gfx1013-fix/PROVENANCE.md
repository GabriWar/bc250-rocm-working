# Provenance

This directory is a **verbatim, unmodified snapshot of someone else's work**. It is
not ours. It is vendored here so the patches survive if the upstream repository is
deleted, made private, force-pushed, or rewritten.

| | |
|---|---|
| Upstream | <https://github.com/DryhoppedIPA/bc250-gfx1013-fix> |
| Author | DryhoppedIPA |
| Commit pinned | `65ef06ddc4d110b6758f5bc2d4e677efc155d7bc` |
| Commit date | 2026-08-08 16:55:58 UTC |
| Commit subject | `status.sh: include recent amdgpu kernel log lines in bug-report output` |
| Tree hash | `12acc503914fd77ddd213cd7895253690d476316` |
| Upstream version | 0.2.0-alpha (`VERSION`) |
| Snapshot taken | 2026-08-08 |
| Snapshot source | `https://github.com/DryhoppedIPA/bc250-gfx1013-fix/archive/65ef06ddc4d110b6758f5bc2d4e677efc155d7bc.tar.gz` |

The upstream repository had exactly two commits at snapshot time, both dated
2026-08-08: `d3e6dc062c34` (initial, "BC-250 GFX1013 compute queue fix, 0.2.0-alpha")
and the pinned `65ef06ddc4d1`. Pinning the SHA rather than a branch name is the whole
point: `main` can move or vanish, a commit hash cannot be quietly altered.

## What was changed

Nothing. Every file is byte-for-byte upstream, plus two files that did not exist
there:

- `PROVENANCE.md` — this file.
- `SHA256SUMS` — checksums of every other file, so the snapshot can be verified
  against upstream by anyone who still has access to it.

There was no `.git` directory to remove: GitHub's `archive/<sha>.tar.gz` ships the
tree without history. Verified after extraction rather than assumed.

To check this snapshot is faithful:

```sh
cd third_party/bc250-gfx1013-fix
sha256sum -c SHA256SUMS
```

## Licensing

Upstream's own terms, reproduced here unchanged in `LICENSE`, `LICENSES.md`,
`LICENSES/` and `NOTICE.md`:

- **Kernel patches** (`patches/kernel/`): GPL-2.0-only, being derived from amdgpu.
- **Everything else**: MIT.

Both licenses permit redistribution provided attribution and license text travel
with the code. They do, in full, in this directory. Nothing here is relicensed and
nothing here is claimed as our work.

`patches/kernel/40cu-bc250-unlock.patch` is itself vendored by upstream from a third
project, [duggasco/bc250-40cu-unlock](https://github.com/duggasco/bc250-40cu-unlock),
and is credited as such in upstream's README. Credit for it belongs to duggasco.

## Relationship to this repository

Different subsystem, different defect. Upstream targets **Vulkan async compute** —
the ACE rings, through RADV and Mesa; its headline result is game frame rate. This
repository targets **KFD/HSA compute** — ROCm and PyTorch. Neither fix substitutes
for the other, and the two have not been run together.

The overlap, the corroboration, and one concrete disagreement are written up in
[`docs/26-the-other-bc250-patch-set.md`](../../docs/26-the-other-bc250-patch-set.md).

**Do not apply these patches on top of ours without reading that document first.**
`patches/kernel/v33/0003-gfx1013-scoped-pasid-type0.patch` edits the same function in
`gmc_v10_0.c` that we edit, and will conflict.
