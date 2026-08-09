# 29 — The SDMA firmware is the bug

AMD published `cyan_skillfish2_sdma.bin` once, on 2021-11-12, in a commit titled
*"amdgpu: add cyan skillfish firmware from 21.40"*. It has never been touched
since — one commit, in the entire history of the file, and the copy in
`linux-firmware` today is byte-identical to the one shipped here.

That blob does not drive the SDMA user-queue path. Replace it with any other
SDMA 5.0 firmware and SDMA works.

## The measurement

A copy queued through HSA, with the completion signal polled directly from
memory rather than waited on, so nothing depends on an interrupt
([`tools/sdma_copy_ab.py`](../tools/sdma_copy_ab.py)):

| firmware | `HSA_ENABLE_SDMA=1` | runs |
|---|---|---|
| `cyan_skillfish2` `0x34` | **0 of 4194304 bytes**, signal never drops, 5 s timeout | 3 |
| `navi10` `0x23` | 4194304 / 4194304 in 0.04 s | 3 |
| `navi12` `0x2c` | 4194304 / 4194304 in 0.04 s | 3 |

Per engine, requested explicitly with
`hsa_amd_memory_async_copy_on_engine()` ([`tools/sdma_engine_ab.py`](../tools/sdma_engine_ab.py)):

| | with `0x34` | with `0x2c` |
|---|---|---|
| SDMA0 | signal never drops in 8 s, 0 bytes | drops in **0.005 s**, data correct |
| SDMA1 | signal never drops in 8 s, 0 bytes | drops in **0.005 s**, data correct |

All `n=3`, deterministic, no intermediate outcomes.

Real workload, `HSA_ENABLE_SDMA=1`, five 16 MiB round trips: with `0x34` the
process hangs at ROCr init at 100% CPU in state **R** and never prints a line;
with `0x2c` all five complete, `torch.equal` true on every one.

Bandwidth, 128 MiB host-to-device, best of 5, `n=3` interleaved:

| | best | throughput |
|---|---|---|
| `HSA_ENABLE_SDMA=0` (blit kernels) | 19.5–20.4 ms | ~6400 MiB/s |
| `HSA_ENABLE_SDMA=1` (SDMA, fixed firmware) | 16.2–16.9 ms | **~7700 MiB/s** |

**+20%**, consistent across all three repetitions.

## What this overturns

`patches/bc250-kfd-skip-sdma0.patch` steered KFD user queues off engine 0 on the
premise that engine 1 was healthy. **Both engines were equally dead**, for the
same reason, and the patch could never have worked. It is removed.

It also resolves something this repository had recorded without explanation:
neoney wrote `clr-prefer-sdma1` — which only avoids engine 0 — and kept
`HSA_ENABLE_SDMA=0` anyway. That looked inconsistent. It was not: steering to
engine 1 does not help when engine 1 runs the same broken microcode.

Independent corroboration, from the BC-250 Discord, predating this measurement:

> *"SDMA appears to be basically all kinds of broken for host <-> VRAM"* — anrp
>
> *"running on the kernel sdma ring works but software sdma ring does not"* —
> HPC Cluster Architect

The second matches this exactly: the kernel ring keeps delivering trap
interrupts — 26 of them were logged during a hang — while the user queue copies
nothing.

## The driver has expected eight working RLC queues since 2018

`drm/amdgpu: add sdma fw loading support for cyan_skillfish` landed 2018-12-18 —
three years before the firmware blob was published. It looks for two names:

```c
case CHIP_CYAN_SKILLFISH:
	if (adev->apu_flags & AMD_APU_IS_CYAN_SKILLFISH2)
		chip_name = "cyan_skillfish2";
	else
		chip_name = "cyan_skillfish";
```

Only the `2` variants were ever published; `cyan_skillfish_sdma.bin` does not
exist in `linux-firmware`.

The golden settings added the next day, 2018-12-19, program
`mmSDMA0_RLC0_RB_WPTR_POLL_CNTL` through `mmSDMA0_RLC7_RB_WPTR_POLL_CNTL` —
all eight RLC queues, one line each, for both engines.

So the driver has configured eight user queues on this chip since 2018. The
firmware AMD shipped three years later does not drive them. This is not a part
that was designed without SDMA user queues.

## Signature checking does not happen

Three different chips' firmware ran on this board. If the RSA signature at
`0x8200`–`0x83ff` were validated, `navi12`'s — signed for navi12 — would have
been rejected on load. It was not, and it works. That is an empirical result,
not a reading of the load path.

The headers are structurally identical, which is why the swap is safe:

| | `cyan_skillfish2` | `navi12` |
|---|---|---|
| file size | 33792 | 33792 |
| **IP version** | **5.0** | **5.0** |
| ucode size / offset | 33536 / 256 | 33536 / 256 |
| ucode version | `0x34` | `0x2c` |

## How far the analysis got, and where it stopped

Disassembled with [`ida-f32`](https://github.com/gabriwar/ida-f32)'s standalone
`f32dis.py` — 8192 instructions each, 100% decode, zero unknowns.

**What is established.** The broken firmware never touches 24 registers that
both working firmwares do. Those 24 are three registers repeated across eight
groups with a stride of `0x180` bytes — and `0x180` bytes is `0x60` dwords,
exactly the stride between `mmSDMA0_RLC0_RB_CNTL` (`0x140`) and
`mmSDMA0_RLC1_RB_CNTL` (`0x1a0`). Eight groups, eight RLC queues. RLC queues are
user queues. A `grep` for those offsets under **any** base register finds
nothing in the broken build.

**What is not established, and blocks a patch.** Three separate attempts to
localise the change all failed, each for its own reason:

- **byte diff** — every pair of these firmwares differs by 34–53%, and the
  broken one sits ~53% from all three working ones. There is no near neighbour.
- **instruction alignment** — both handlers contain exactly 2207 useful
  instructions, but only 12.1% share a mnemonic at the same index. The
  compiler rescheduled.
- **packet framing** — the disassembler's `PKT_*` labels are internal, not
  driver-visible opcodes. The driver emits SDMA opcodes 0 through 17; there is
  no `0xf0`.

Without an alignment there is no insertion point, and a patch at a guessed
address inside a DMA engine is not an experiment.

Two readings were made and retracted along the way, both worth recording because
they would have produced a broken patch:

- `std r1, reg[...]` was read as "write the value in r1". It is not. In this ISA
  **`r1` is a magic register: reading it pulls the next dword from the command
  queue** (`ida-f32/f32.py:765`). Those instructions consume packet payload.
  Transplanting them would have desynchronised the command stream — worse than
  the bug.
- The sequence was called an init routine. It sits under a `PKT_` label, and
  those are internal firmware labels, not the boot path.

## What to report upstream

The useful sentence for AMD, who have the source: *the SDMA firmware published
for cyan_skillfish2 does not operate the RLC (user) queue registers; the navi12
firmware does, and runs correctly on the same silicon.*

## Reproducing

```sh
cd /usr/lib/firmware/amdgpu
sudo cp -a cyan_skillfish2_sdma.bin.zst  cyan_skillfish2_sdma.bin.zst.ORIG
sudo cp -a cyan_skillfish2_sdma1.bin.zst cyan_skillfish2_sdma1.bin.zst.ORIG
sudo cp navi12_sdma.bin.zst  cyan_skillfish2_sdma.bin.zst
sudo cp navi12_sdma1.bin.zst cyan_skillfish2_sdma1.bin.zst
sudo reboot
```

No kernel rebuild, and no initramfs regeneration — `amdgpu.ko` is not in the
initramfs here, so the firmware is read from `/usr/lib/firmware` after
switch_root. Revert by copying the `.ORIG` files back.

Caveat worth stating plainly: running another chip's firmware is outside
anything AMD supports. Same IP version, same layout, and the measurements are
clean — but it has not been run for days under sustained load.
