# 28 — The SDMA0 boot message is not a lost interrupt

> **Measured and closed, 2026-08-08.** Both halves of this document are now
> confirmed on hardware, and the boot message is fixed. Instrumenting the trap
> handler directly shows the SDMA0 interrupt vector arriving — 13 of them in the
> first seconds, `cid=8 src=224` — so it was never lost. And the readback proves
> the window: `SDMA0_CNTL antes=0x000400e2 depois=0x000400e3`, bit 0 clear
> before the write. Writing `TRAP_ENABLE` early in `gfx_resume` takes the
> fallback message from 2-3 per boot, in 4 consecutive boots, to **zero**.
> The IH routing hypotheses are dead too: rings 1 and 2 read `base=0 cntl=0`.
> See the tail of this document and `patches/bc250-sdma-trap-instrumentation.patch`.

Every cold boot on this board logs, before any workload runs:

```
amdgpu 0000:01:00.0: Fence fallback timer expired on ring sdma0
amdgpu 0000:01:00.0: Fence fallback timer expired on ring sdma0
```

Twice, always. `sdma1` has never produced it. This was read for months as
"SDMA0's completion interrupt is lost on this silicon", and
`patches/bc250-kfd-skip-sdma0.patch` was written on that basis.

The reading is probably wrong, and three of the arguments used to support it
were mistakes. This document records both.

## What the message actually proves

`amdgpu_fence_fallback()` only warns when `amdgpu_fence_process()` found an
**already completed** fence. So the work finished and no interrupt arrived.
The engine is not stuck. That part holds.

But "no interrupt arrived" has two explanations, and the boot timing separates
them:

`TRAP_ENABLE` in `SDMA0_CNTL` is written by exactly one function,
`sdma_v5_0_set_trap_irq_state()`, reached only from `amdgpu_irq_get()`, reached
only from `amdgpu_fence_driver_hw_init()` — which runs **after
`amdgpu_device_ip_init()` returns in full**. The reset value of `SDMA0_CNTL` is
`0x000000c2`, so bit 0 (`TRAP_ENABLE`) starts at **0**.

Inside `ip_init`, `amdgpu_ttm_set_buffer_funcs_status(adev, true)` switches TTM
on, and `amdgpu_amdkfd_device_init()` then allocates and clears buffer objects.
`adev->mman.buffer_funcs_ring = &adev->sdma.instance[0].ring`, so all of that
runs on SDMA0. Fences are emitted, the engine executes them, and **no interrupt
vector is generated because the trap is still physically disabled**. 500 ms
later — `AMDGPU_FENCE_JIFFIES_TIMEOUT = HZ/2` with `CONFIG_HZ=1000` — the
fallback timer wakes the waiter. The measured gap between the two messages is
504–505 ms in every boot checked.

So: **nothing was lost. Nothing was generated.**

The asymmetry against SDMA1 is one of *traffic*, not of silicon. In that window
only SDMA0 receives work with a waiter, because it is the `buffer_funcs_ring`.
SDMA1 emitted one fence in its entire life.

Supporting measurement: **28 minutes of uptime under load, zero further
fallbacks.** SDMA0 carries every TTM blit. If its trap were lost in steady
state, dmesg would be full of this line.

## Three claims this repository got wrong

1. **"The trap IV never reaches `amdgpu_irq_dispatch`."** This was inference
   presented as measurement. `amdgpu_irq_dispatch` **prints nothing on the
   success path**; the `dev_dbg` statements enabled via
   `dyndbg="file amdgpu_irq.c +p"` fire only for an *unregistered* client or
   source id. With client 8 and source 224 both registered, a delivered IV
   passes in complete silence. Zero debug lines eliminated exactly one
   possibility: discard due to an unregistered id. Nothing more.

2. **`ih1.ring_size = 0` was read backwards.** It does not disable IH rings 1
   and 2 — it makes Linux **ignore** them. `navi10_ih_toggle_interrupts()` and
   the loop in `navi10_ih_irq_init()` are both guarded by
   `if (ih[i]->ring_size)`, and the driver never even fills in the RING1/RING2
   register offsets. That is precisely the condition under which an IV routed to
   ring 1 would vanish without trace. It was used to *eliminate* a hypothesis it
   actually supports.

3. **`IP_VERSION(5, 0, 2)` is wrong.** The hardware reports **5.0.1** via
   `/sys/class/drm/card1/device/ip_discovery/die/0/SDMA0/0/`. 5.0.2 is Navi14.
   The version is the selector in `sdma_v5_0_init_golden_registers()`, so any
   analysis assuming 5.0.2 was reading the wrong branch. (The golden settings
   applied are still the correct `golden_settings_sdma_cyan_skillfish`.)

Also worth recording: `navi10_ih.c` never writes **any** IH routing or filtering
register — no `IH_CLIENT_CFG`, `IH_CID_REMAP`, `IH_INT_DROP_*`,
`IH_STORM_CLIENT_LIST_CNTL` or `IH_INT_FLOOD_CNTL`. Whatever the PS5 boot ROM
programmed into those registers is still live under Linux.

## The consequence for `bc250_skip_sdma0`

Fixing the boot message would **not** let that patch be dropped.

The patch exists because of the *user queue* hang: `HSA_ENABLE_SDMA=1` spins at
199% CPU with no progress, hours into a session, with the trap demonstrably
enabled and delivering. That is a different failure from the boot-time
messages, and this repository had been treating them as one.

The user-queue symptom has a detail that points somewhere worse: the spin is in
state **R**, not S. State R is a busy-poll on memory, not a sleep waiting on a
KFD event. If the fence completed and its value *landed in memory*, the poll
would have seen it. That suggests the completion write does not land on the
SDMA0 user-queue path — a **data path** problem, not an interrupt problem. It
fits the other measured symptom: a batch of host→device copies reported done
early with exactly one 2 MiB chunk missing (`1048576` fp16 elements, first bad
index a multiple of that).

That is the thing worth investigating next, and it is not what the boot message
is about.

## Two real driver bugs found along the way

Neither explains the symptom; both are worth fixing.

**`sdma_v5_0_enable(adev, false)` stops the wrong engine.** It calls
`sdma_v5_0_gfx_stop(adev, 1 << inst_mask)`. With `inst_mask = GENMASK(1,0) = 3`,
`1 << 3 = 8`, so `for_each_inst(i, 8)` runs exactly once with `i = 3` — and
`sdma_v5_0_get_reg_offset()` only adds an offset when `instance == 1`, so `i = 3`
lands on **instance 0's** registers. The result: the stop path zeroes SDMA0's
ring and IB registers and **never stops SDMA1**. This is present upstream;
`sdma_v5_2.c` passes `inst_mask` correctly.

**`sdma_v5_0_soft_reset()` is an empty stub** (`/* todo */`) and
`sdma_v5_0_start()` resets nothing, while `sdma_v5_2_start()` does a GRBM soft
reset of each engine before unhalting. The per-engine helper
`sdma_v5_0_soft_reset_engine()` already exists in v5_0 — it is simply never
called from start. This is the most direct explanation for a fact measured here:

```
rmmod amdgpu && modprobe amdgpu
  -> ring sdma0 test failed (-110)
  -> hw_init of IP block <sdma_v5_0> failed -110
  -> Fatal error during GPU init / probe failed with error -110
```

**Warm reload of amdgpu does not work on this board.** Cold boot, the SDMA0 ring
test passes. Warm, it times out and the whole probe fails. Any experiment that
touches GPU init therefore costs a reboot, which is worth knowing before
planning one.


---

## Measured: the interrupt arrives, and the message is fixed

The diagnostic that settles it logs inside `sdma_v5_0_process_trap_irq()`
itself — after dispatch, so a line appearing means the vector was delivered —
with a **separate budget per instance**, because a shared counter lets SDMA1
traffic exhaust it and turns SDMA0's silence into something indistinguishable
from absence. That is the same reading error this document already retracts
once.

```
BC-250 ih ring0: base=0x00006090 cntl=0x403301a1 rptr=0x00000000 wptr=0x00000000
BC-250 ih ring1: base=0x00000000 cntl=0x00000000 rptr=0x00000000 wptr=0x00000000
BC-250 ih ring2: base=0x00000000 cntl=0x00000000
BC-250 ih drop:  cntl=0xffffffff dest=0xffffffff storm=0x00000000
BC-250 sdma0: SDMA0_CNTL antes=0x000400e2 depois=0x000400e3 TRAP_ENABLE=1
BC-250 sdma1: SDMA0_CNTL antes=0x000400e2 depois=0x000400e3 TRAP_ENABLE=1
BC-250 sdma iv: cid=8 src=224 ring=0 vmid=0 pasid=0 data0=0x0 (#1 na inst 0)
... 13 lines with cid=8, 1 with cid=9
```

| question | answer |
|---|---|
| Does the SDMA0 trap IV reach the driver? | **Yes.** 13 vectors, `cid=8 src=224` |
| Was `TRAP_ENABLE` really off during init? | **Yes.** `antes` ends in `e2` — bit 0 clear |
| Does closing that window fix the boot message? | **Yes.** 2–3 per boot → **0** |
| Is an IV hiding in IH ring 1 or 2? | No. Both read `base=0 cntl=0` |
| Is the console's boot ROM dropping interrupts? | No — the vectors arrive |

On `ih drop` reading `0xffffffff`: that is **not** read here as "drop enabled on
every bit". A register returning all-ones is usually one the ASIC does not
implement, and `storm` beside it reads a plausible `0`. More decisively, the
vectors are arriving, so nothing is being dropped whatever that value means.

The 13-to-1 split between the instances is the traffic asymmetry this document
predicted: SDMA0 is `buffer_funcs_ring`, SDMA1 gets almost nothing.

### What this leaves

`bc250_skip_sdma0` exists for the **user queue** hang, and this measurement was
taken with `bc250_skip_sdma0=1` — so it observed the *kernel* ring, not the path
that hangs. The interrupt being healthy there does narrow it: whatever hangs the
user queue, it is not a missing trap on this engine.

That points where the 199%-CPU busy-poll in state **R** already pointed — at the
completion write not landing in memory. The next measurement is the same trace
with `amdgpu.bc250_skip_sdma0=0`, which costs a boot and no rebuild.
