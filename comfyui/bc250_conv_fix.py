# BC-250 (gfx1013): replaces MIOpen's conv2d with im2col + GEMM.
#
# REASON, measured 2026-08-05 on a clean boot, first GPU load:
#
#   operation family             wrong
#   ---------------------------  -------
#   matmul (rocBLAS/Tensile)       0/26
#   elementwise (torch kernels)    0/26
#   unfold / im2col                0/26
#   im2col + GEMM manual           0/26
#   conv2d via MIOpen             12/26   <- first error on the 6th operation
#
# In other words: it is not the compute queue, not the dispatch size, not
# precision (fp32 breaks the same way), not the allocator. It is the MIOpen
# convolution path specifically. MIOpen has no tuning database for gfx1013
# (84 db files, zero for this architecture), so it JIT-compiles from generic
# heuristics and the result comes out wrong without reporting any error.
#
# MIOpen itself already picks the GemmFwdRest solver for these shapes, which is
# im2col + GEMM. This patch does the same thing through torch kernels.
#
# MEASURED COST: none.
#   c=320 h= 64   conv2d 1.68ms   im2col+mm 1.72ms
#   c=320 h=128   conv2d 6.32ms   im2col+mm 6.52ms
#   c=640 h= 32   conv2d 2.63ms   im2col+mm 2.67ms
#
# Disable with BC250_CONV_FIX=0.

import os

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}

if os.environ.get("BC250_CONV_FIX", "1") != "0":
    try:
        import torch
        import torch.nn.functional as F

        _orig_conv2d = F.conv2d

        # Ceiling for the im2col intermediate matrix, in MB.
        # im2col materializes (cin*kh*kw) x (ho*wo). In the UNet the latent is 64x64 and
        # that gives ~24 MB, but the VAE decodes at 512x512: 128 channels x 9 x
        # 512 x 512 = 604 MB in fp16. On a board with 4 GB of UMA that takes the
        # machine down -- it happened on 2026-08-05 before this guard existed.
        # Above the ceiling, fall back to MIOpen's conv2d: worse correction, but
        # the alternative is hanging the host.
        _MAX_COLS_MB = int(os.environ.get("BC250_CONV_FIX_MAX_MB", "192"))

        def _conv2d_im2col(input, weight, bias=None, stride=1, padding=0,
                           dilation=1, groups=1):
            # Off the GPU, or in cases im2col does not cover well, use the original.
            if (not input.is_cuda) or groups != 1 or input.dim() != 4:
                return _orig_conv2d(input, weight, bias, stride, padding,
                                    dilation, groups)

            def pair(v):
                return (v, v) if isinstance(v, int) else tuple(v)

            st, pd, dl = pair(stride), pair(padding), pair(dilation)
            n, cin, hi, wi = input.shape
            cout, _, kh, kw = weight.shape

            ho = (hi + 2 * pd[0] - dl[0] * (kh - 1) - 1) // st[0] + 1
            wo = (wi + 2 * pd[1] - dl[1] * (kw - 1) - 1) // st[1] + 1

            # Above the ceiling, fall back to MIOpen's conv2d.
            #
            # DISCARDED ATTEMPT (2026-08-05): slicing the im2col by row ranges,
            # so MIOpen would never be used. The numeric result stayed correct
            # in isolated tests (peak went from 1152 MB down to ~670 MB),
            # but a full ComfyUI generation started TAKING THE MACHINE DOWN
            # reproducibly, while the version with this simple fallback
            # runs in 37.7s/29.3s. A/B: no patch 38.2/34.3 ok, with slicing
            # crash, with simple fallback 37.7/29.3 ok. Never investigated why
            # -- probably torch.cat's per-range allocation pattern.
            cols_mb = (n * cin * kh * kw * ho * wo *
                       input.element_size()) / (1024 * 1024)
            if cols_mb > _MAX_COLS_MB:
                return _orig_conv2d(input, weight, bias, stride, padding,
                                    dilation, groups)

            cols = F.unfold(input, (kh, kw), dilation=dl, padding=pd, stride=st)
            out = weight.reshape(cout, -1) @ cols          # (n, cout, ho*wo)
            out = out.reshape(n, cout, ho, wo)
            if bias is not None:
                out = out + bias.reshape(1, -1, 1, 1)
            return out

        F.conv2d = _conv2d_im2col
        torch.nn.functional.conv2d = _conv2d_im2col
        print("[bc250-conv-fix] conv2d -> im2col+GEMM (contorna MIOpen)", flush=True)
    except Exception as e:
        print(f"[bc250-conv-fix] FALHOU, mantendo conv2d original: "
              f"{type(e).__name__}: {e}", flush=True)
