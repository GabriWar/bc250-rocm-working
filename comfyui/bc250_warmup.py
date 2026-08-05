# BC-250 (gfx1013): aquecimento de code objects.
#
# Motivo: nesta placa, um code object carregado TARDE — depois do modelo e de
# muita alocacao de GPU — produz busca de instrucao em endereco invalido
# (page fault com cliente SQC (inst), byte alto 0xff).
#
# Estabelecido por A/B na mesma boot em 2026-08-04:
#   count_nonzero aquecido no inicio -> passa
#   count_nonzero so no fim          -> illegal memory access
#
# HIP_ENABLE_DEFERRED_LOADING=0 seria a correcao natural, mas segfaulta nesta
# build do ROCm. Entao aquecemos na mao, cedo, antes de qualquer modelo entrar.

import os, sys, traceback

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}

if os.environ.get("BC250_WARMUP", "1") != "0":
    try:
        import torch
        if torch.cuda.is_available():
            d = 'cuda'
            ok = fail = 0
            def w(nome, fn):
                global ok, fail
                try:
                    fn(); torch.cuda.synchronize(); ok += 1
                except Exception as e:
                    fail += 1
                    print(f"[bc250-warmup] {nome}: {type(e).__name__}", file=sys.stderr)

            for dt in (torch.float32, torch.float16):
                a = torch.randn(256, 256, device=d, dtype=dt)
                b = torch.randn(256, 256, device=d, dtype=dt)
                c = torch.randn(1, 8, 32, 32, device=d, dtype=dt)
                k = torch.randn(8, 8, 3, 3, device=d, dtype=dt)
                F = torch.nn.functional
                t = str(dt).split('.')[-1]
                # reducoes — count_nonzero e a que quebrava o KSampler
                w(f"count_nonzero/{t}", lambda: torch.count_nonzero(a))
                w(f"sum/{t}",           lambda: a.sum())
                w(f"mean/{t}",          lambda: a.mean())
                w(f"max/{t}",           lambda: a.max())
                w(f"min/{t}",           lambda: a.min())
                w(f"argmax/{t}",        lambda: a.argmax())
                w(f"norm/{t}",          lambda: a.float().norm())
                w(f"cumsum/{t}",        lambda: torch.cumsum(a.flatten(), 0))
                w(f"sort/{t}",          lambda: torch.sort(a.flatten()))
                w(f"any/{t}",           lambda: (a > 0).any())
                w(f"all/{t}",           lambda: (a > 0).all())
                w(f"nonzero/{t}",       lambda: (a > 3).nonzero())
                # elementwise
                for nome, fn in (("exp", torch.exp), ("sqrt", lambda x: torch.sqrt(x.abs())),
                                 ("sigmoid", torch.sigmoid), ("tanh", torch.tanh),
                                 ("sin", torch.sin), ("cos", torch.cos),
                                 ("floor", torch.floor), ("ceil", torch.ceil),
                                 ("frac", torch.frac), ("neg", torch.neg),
                                 ("log", lambda x: torch.log(x.abs() + 1))):
                    w(f"{nome}/{t}", lambda fn=fn: fn(a))
                w(f"clamp/{t}",   lambda: a.clamp(-1, 1))
                w(f"where/{t}",   lambda: torch.where(a > 0, a, -a))
                w(f"pow/{t}",     lambda: a.abs() ** 2.5)
                w(f"add/{t}",     lambda: a + b)
                w(f"mul/{t}",     lambda: a * b)
                w(f"div/{t}",     lambda: a / (b.abs() + 1))
                w(f"eq/{t}",      lambda: a == b)
                # blas / nn
                w(f"matmul/{t}",  lambda: a @ b)
                w(f"bmm/{t}",     lambda: torch.bmm(a.unsqueeze(0), b.unsqueeze(0)))
                w(f"conv2d/{t}",  lambda: F.conv2d(c, k, padding=1))
                w(f"softmax/{t}", lambda: torch.softmax(a, -1))
                w(f"layernorm/{t}", lambda: F.layer_norm(a, (256,)))
                w(f"groupnorm/{t}", lambda: F.group_norm(c, 4))
                w(f"silu/{t}",    lambda: F.silu(a))
                w(f"gelu/{t}",    lambda: F.gelu(a))
                w(f"sdpa/{t}",    lambda: F.scaled_dot_product_attention(
                       a.unsqueeze(0).unsqueeze(0), a.unsqueeze(0).unsqueeze(0), a.unsqueeze(0).unsqueeze(0)))
                w(f"interp/{t}",  lambda: F.interpolate(c, scale_factor=2))
                w(f"pad/{t}",     lambda: F.pad(c, (1, 1, 1, 1)))
                w(f"cat/{t}",     lambda: torch.cat([a, a], 0))
                w(f"transpose/{t}", lambda: a.t().contiguous())
                w(f"randlike/{t}",  lambda: torch.randn_like(a))
                del a, b, c, k
            # int64 — count_nonzero devolve int64
            i = torch.ones(4096, device=d, dtype=torch.int64)
            w("i64_sum", lambda: i.sum())
            w("i64_max", lambda: i.max())
            del i
            torch.cuda.empty_cache()
            print(f"[bc250-warmup] {ok} kernels aquecidos, {fail} falharam", file=sys.stderr)
    except Exception:
        print("[bc250-warmup] aquecimento falhou:", file=sys.stderr)
        traceback.print_exc()
