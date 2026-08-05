# Building rocBLAS/Tensile for gfx1013

Stock ROCm has no gfx1013 support in Tensile — the architecture is not in the
supported list, so the build simply skips it. Seven source changes are needed
before it will emit kernels for this chip.

Prebuilt output is in [`artifacts/rocblas-gfx1013/`](../artifacts/rocblas-gfx1013/)
if you just want the kernels. This file is for rebuilding them.

---

## The seven changes

### 1. `Tensile/Common.py` — add the ISA

Around line 251, in the supported-ISA tuple:

```python
(10,1,0), (10,1,1), (10,1,2), (10,1,3), (10,3,0), (10,3,1), (10,3,2),
                              ^^^^^^^^ add this
```

### 2. `Tensile/Common.py` — map the architecture name

Around line 326:

```python
'gfx1010':'navi10', 'gfx1011':'navi12', 'gfx1012':'navi14', 'gfx1013':'cyan_skillfish',
                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^ add this
```

The name on the right becomes the `ScheduleName` and the logic directory name.

### 3. `Tensile/AsmCaps.py` — declare the capabilities

Add a `(10, 1, 3)` block. The values that matter, and differ from RDNA2:

```
    'HasAtomicAdd': False,
    'HasDirectToLdsDest': False,
    'HasMFMA': False,
    'HasMFMA_b8': False,
    'HasMFMA_bf16_1k': False,
    'HasMFMA_bf16_original': False,
    'HasMFMA_constSrc': False,
    'HasMFMA_f64': False,
    'HasMFMA_f8': False,
    'HasMFMA_i8_908': False,
    'HasMFMA_i8_940': False,
    'HasMFMA_vgpr': False,
    'HasMFMA_xf32': False,
    'HasWMMA': False,
    'v_dot2_f32_f16': False,
    'v_dot2c_f32_f16': False,
    'v_fma_mix_f32': True,
    'v_pk_fma_f16': True,
    'v_pk_fmac_f16': False},
```

**Getting these wrong is not cosmetic.** gfx1013 has **no dot-product
instructions** but **does** have packed FMA. Declaring dot products available
makes Tensile emit `v_dot2_f32_f16`, which this chip cannot execute — you get
`HSA_STATUS_ERROR_ILLEGAL_INSTRUCTION` at runtime.

| capability | gfx1013 | gfx1030 (navi21) |
|---|---|---|
| `v_dot2_f32_f16` | **False** | True |
| `v_dot2c_f32_f16` | **False** | True |
| `v_pk_fma_f16` | **True** | — |
| `HasWMMA` / `HasMFMA` | False | False |

### 4. `Tensile/Source/lib/include/Tensile/AMDGPU.hpp`

Add the enum value and its string:

```cpp
gfx1013 = 1013,
...
case AMDGPU::Processor::gfx1013:
    return "gfx1013";
```

### 5. `Tensile/Source/lib/include/Tensile/PlaceholderLibrary.hpp`

Add to `LazyLoadingInit` and its name mapping:

```cpp
gfx1013,
...
case LazyLoadingInit::gfx1013:
    return "TensileLibrary_*_gfx1013";
```

### 6. `Tensile/Source/lib/include/Tensile/Serialization/Predicates.hpp`

Add the deserialization case:

```cpp
iot::enumCase(io, value, "gfx1013", AMDGPU::Processor::gfx1013);
```

### 7. `Tensile/Source/cmake/TensileSupportedArchitectures.cmake`

Add `"gfx1013"` to the architecture list.

> Note: this file exists in three places in the tree
> (`Tensile/Source/cmake/`, `next-cmake/cmake/`, `build/lib/Tensile/Source/cmake/`).
> Patch the one your build actually consumes, and pass
> `-DCMAKE_MODULE_PATH=<path>/Tensile/Source/cmake` so cmake finds it.

---

## Logic files

Tensile needs per-architecture "logic" files describing which kernel solves
which problem size. rocBLAS 7.2 ships **no RDNA1 logic at all** — the
`asm_full` directory has navi21 and RDNA3+, nothing older.

Ours were translated from **navi21** (gfx1030, RDNA2):

```bash
for f in Logic/asm_full/navi21/navi21_*.yaml; do
  sed -e 's/^- navi21$/- cyan_skillfish/' \
      -e 's/^- gfx1030$/- gfx1013/' \
      -e 's/ISA: \[10, 3, 0\]/ISA: [10, 1, 3]/g' \
      "$f" > "Logic/asm_full/cyan_skillfish/$(basename $f | sed 's/^navi21_/cyan_skillfish_/')"
done
```

Then remove the 8 `*I8II*` files — int8 fails with
`Assembly doesn't support I8` on this ISA. **Move them outside
`Logic/asm_full/` entirely**; Tensile scans recursively, so a "disabled"
subdirectory inside it still gets read.

Result: 24 logic files, producing 12 `.co` and 13 `.dat` in the installed
library.

> **This is architecturally wrong and known to be so.** navi21 is RDNA2;
> gfx1013 is RDNA1. Tile sizes, LDS budgets and register counts differ. The
> kernels work, but the tuning parameters are not right for this chip — see
> [05-tensile-tuning.md](05-tensile-tuning.md), obstacle 2, where navi21 tiles
> blow the 256-VGPR budget.

---

## Matched pair

The rocBLAS `.so` and the Tensile data **must come from the same build**. Mixing
a library from one build with kernels from another produces failures that look
like hardware faults.

---

## Verifying the kernels are actually used

With `AMD_LOG_LEVEL=5`, dispatched kernel names carry the ISA:

```
ShaderName : Cijk_Alik_Bljk_SB_MT16x16x8_..._ISA1013_...
                                              ^^^^^^^ ours
```

A single CLIP text-encode showed 84 such dispatches.

Quick sanity check that they are load-bearing: move
`/opt/rocm/lib/rocblas/library/*gfx1013*` aside and run any `matmul`. It
core-dumps — rocBLAS falls through to `TensileLibrary_lazy_gfx942.dat` and dies.
