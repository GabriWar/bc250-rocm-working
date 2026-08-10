# BC-250 (gfx1013): neutralizes ComfyUI's soft_empty_cache().
#
# MEASURED 2026-08-05, VAE decode validated against the CPU (err_rel, not
# "is finite"):
#
#   before everything                 err=1.257e-02  OK
#   with the UNet resident on the GPU err=1.257e-02  OK
#   unload UNet + empty_cache         err=6.075e-01  CORRUPTED
#   next decode                       err=1.257e-02  OK
#
# Exactly ONE operation comes out poisoned after empty_cache(), and it goes back
# to normal on the next one. ComfyUI calls soft_empty_cache() at 5 points in
# model_management.py, all of them on model unload -- including between the
# sampler and the VAE. Hence the 30 KB image with stddev 10 instead of 480 KB.
#
# Matches another finding from the same day: torch.cuda.empty_cache() between
# conv2d escalated to HSA_STATUS_ERROR_ILLEGAL_INSTRUCTION (code 0x2a).
#
# The decode itself is correct and stable: 5/5 runs with err=1.257e-02 and 0.60s
# warm, against ~15s on the CPU.
#
# COST: memory is not returned to the driver between model swaps. On a board
# with 4 GB of UMA this can lead to OOM in workflows that swap models a lot.
# If that happens, disable with BC250_NO_EMPTY_CACHE=0.

import os

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}

if os.environ.get("BC250_NO_EMPTY_CACHE", "1") != "0":
    try:
        import comfy.model_management as mm

        _orig = mm.soft_empty_cache

        def _noop(force=False):
            # Keeps the synchronize (cheap and sometimes necessary), but does not
            # return memory to the driver, which is what corrupts the next
            # operation on this board.
            try:
                import torch
                if torch.cuda.is_available():
                    torch.cuda.synchronize()
            except Exception:
                pass

        mm.soft_empty_cache = _noop
        print("[bc250-no-empty-cache] soft_empty_cache neutralizado "
              "(empty_cache corrompe a operacao seguinte)", flush=True)
    except Exception as e:
        print(f"[bc250-no-empty-cache] FALHOU: {type(e).__name__}: {e}",
              flush=True)
