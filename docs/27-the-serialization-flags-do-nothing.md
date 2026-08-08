# 27 — The serialization flags do nothing, and the runlist patch is what holds

Five environment variables had been carried since before the defect had an
explanation:

```sh
HIP_LAUNCH_BLOCKING=1  AMD_SERIALIZE_KERNEL=3  AMD_SERIALIZE_COPY=3
AMD_DIRECT_DISPATCH=0  GPU_MAX_HW_QUEUES=1
```

`config/bc250-rocm.sh` claimed they were **"ainda NECESSARIA"**, citing one
failure in three runs without them on 2026-08-04. They are removed as of
2026-08-08. This is the measurement.

## Why the obvious test says nothing

The first attempt was the obvious one: run the aliasing detector with and
without the flags, with the runlist patch on. 16 runs, 8 per arm:

| arm | runs | corrupted |
|---|---:|---:|
| with the five flags | 8 | 0 |
| without them | 8 | 0 |

Zero on both sides, plus 4 runs of the LoRA-backward suite per arm, all clean,
and no board errors of any kind.

That result is worth nothing on its own. **Both arms were clean, so the test had
no power to discriminate.** It cannot separate "the flags do nothing" from "the
runlist patch is suppressing the defect on both sides". Absence of an event in
the control group is not a control.

## The test that discriminates

Turn the defect back on — `bc250_flush_by_runlist=0` — and ask the question
where it has an answer. Same detector, 8 runs, interleaved `A B B A B A A B`:

| arm | runs with data | corrupted | tensors clobbered | crashes |
|---|---:|---:|---:|---:|
| **with** the five flags | 3 | 2 | 35 &nbsp;`[16, 0, 19]` | 0 |
| **without** them | 3 | 3 | 25 &nbsp;`[13, 11, 1]` | 1 |

Both arms corrupt, in the same order of magnitude. The arm *with* the flags
clobbered more tensors, which is noise on an already-intermittent defect — the
rate has drifted from 6/10 to 1/6 in a single day before, and run 6 came out
clean here despite being unprotected.

The conclusion is not about which arm is worse. It is that **there is no
protective effect at all**.

Two honest notes on these numbers:

- Run 4 (with-flags arm) exited `1` and produced no parseable line. It died in a
  way the log filter did not capture, so that arm has 3 usable runs, not 4. The
  missing datum is not filled in.
- `n=3` per arm is too few to claim a difference *between* the arms. It is
  enough to claim that **both** corrupt, which was the question.

## What actually holds the board

Same detector, same machine, same day:

| condition | runs | corrupted | tensors clobbered |
|---|---:|---:|---:|
| `bc250_flush_by_runlist=1` | 16 | **0** | **0** |
| `bc250_flush_by_runlist=0` | 6 (+1 crash) | **5** | **60** |

With the patch armed and working — ftrace counted **3721** calls to
`kfd_bc250_flush_by_runlist` and 4152 to `execute_queues_cpsch` across the heavy
suite — the board did not corrupt a single tensor, and logged zero ring
timeouts, resets, page faults or coredumps.

The runlist rebuild is not a palliative and it is not luck. It is the thing
keeping this board correct.

## They are not a performance problem either

A microbenchmark of tiny kernels showed the flags costing **2.7×**:

| condition | ms/step (3 runs) | mean |
|---|---|---:|
| serialized | 0.543 / 0.451 / 0.436 | 0.477 |
| free | 0.162 / 0.200 / 0.160 | 0.174 |

That number does not survive contact with a real workload, and it should not
have been expected to. With tensors that small the measurement is dominated by
**dispatch overhead**, which is exactly what `HIP_LAUNCH_BLOCKING` charges for —
and exactly what disappears once the GPU is actually busy.

ComfyUI, CyberRealistic, 512×768 → 768×1152 hires, fixed seed, n=3 per arm:

| arm | seconds per image | mean |
|---|---|---:|
| with the flags | 99.4 / 112.6 / 123.6 | 111.9 |
| without them | 100.2 / 122.6 / 99.8 | 107.5 |

The means differ by 4.4 s. The spread *inside* each arm is 25 s. **That is
noise, not a difference.** All six images hashed identically
(`bcf6767142fe5e02`), which also rules out corruption in the generated output.

So the case for removing them is not speed. It is that they never did what the
comment claimed, and configuration that does nothing is debt.

## Correction to how this was counted

The detector prints:

```
resumo: 0 sobreposicoes de endereco, 16 tensores pisados na pratica
```

The first number is pointer arithmetic — do two live tensors' address ranges
overlap. The second is ground truth — write a pattern into each live tensor and
check whether writing one changed another. **They are not the same thing**, and
the second is the one that matters: the PyTorch pointer is virtual, so an
overlap can exist in the mapping without showing up in the arithmetic.

The first tally of these runs read the wrong field and reported the with-flags
arm as clean when it had 16 clobbered tensors. In every earlier run both numbers
were 0, so the bug was invisible until they diverged. Tables above use the
correct field.

## What this does not settle

Whether the flags ever protected against something *else* — a different failure
mode, on a different stack, at a different time. The 2026-08-04 note recorded one
failure in three runs without them, and that observation is not being called
wrong; it predates the runlist patch and was never repeated. If instability
returns, this block is the first suspect, and it should be reintroduced **one at
a time**, not all five together.
