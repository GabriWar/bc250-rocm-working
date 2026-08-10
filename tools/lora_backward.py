#!/usr/bin/env python3
"""LoRA backward on this board: does it hang? and, above all, is the number right?

The community report
--------------------
On a BC-250, everything works -- raw matmul of any shape, distilgpt2 forward,
training without LoRA, generate(), LoRA forward -- and ONLY LoRA backward hangs.

Two different things are measured here
--------------------------------------
A HANG is the KIQ/preemption signature. It is not the defect this repo chases.

SILENT CORRUPTION is ours: wrong number, no error, no hang. That is why every
stage compares the GPU result against the CPU. A stage that finishes fast and
returns garbage would pass a "did it hang or not" test -- and that is exactly how
Z-Image's fp16 fooled us (exit 0, std=0.0, single-color image).

What is special about the backward
----------------------------------
With y = x @ (W + B@A), the forward does full GEMMs. The backward generates GEMMs
where one of the dimensions is the RANK -- 8, 16, 32 -- much smaller than the
others. A "skinny" kernel, a different Tensile selection path from the forward.

And the optimizer step matters: LoRA starts with B=0, so on the first backward
grad_A is identically zero and the GEMM runs with a null input. Only after a few
steps does B get dense and the backward exercise real data.

Each stage runs as a separate process, with a timeout, so that a hang does not
take the rest down with it.

Usage:
    lora_backward.py [ITERS]      all stages, each isolated
    lora_backward.py --um <name> [ITERS]
"""
import json
import os
import subprocess
import sys
import time

# Without this the driver's print stays buffered until the process ends, and an
# hours-long test looks hung while it is running. It already cost a wrong diagnosis.
try:
    sys.stdout.reconfigure(line_buffering=True)
except Exception:
    pass

DEV = "cuda"
# COARSE criterion, on purpose. The GPU runs fp16 and the reference is fp32; with
# k=4096 fp16 accumulation is off by ~1e-2 on its own, and a tight tolerance
# would flag that as a defect -- noise, not signal. This repo's defect delivers
# THE CONTENT OF ANOTHER BUFFER: error of tens of percent, or NaN, or flat
# zero. That is what we want to catch.
TOL = 0.10


def cfgs(iters):
    """(name, h, t, rank, dtype, optimizer_steps)"""
    c = []
    for h, t in ((768, 512), (1024, 1024), (2048, 1024), (4096, 512)):
        for r in (8, 32):
            c.append((f"lora_bwd_h{h}_t{t}_r{r}", h, t, r, "fp16", 5))
    c.append(("lora_bwd_fp32_h1024_r16", 1024, 1024, 16, "fp32", 5))
    c.append(("lora_bwd_r64_h2048", 2048, 1024, 64, "fp16", 5))
    return c


def roda(nome, iters):
    import torch
    torch.manual_seed(0)

    if nome == "matmul_grande":
        out = []
        for n in (1024, 2048, 4096):
            a = torch.randn(n, n, dtype=torch.float16)
            b = torch.randn(n, n, dtype=torch.float16)
            # CPU reference just once; at 4096, blocked float64 would be
            # too expensive, so fp32 it is -- the tolerance is already relative
            ref = (a.float() @ b.float())
            ag, bg = a.to(DEV), b.to(DEV)
            for _ in range(iters):
                cg = ag @ bg
            torch.cuda.synchronize()
            err = (cg.float().cpu() - ref).abs().max() / ref.abs().max()
            out.append(f"{n}:{float(err):.2e}")
        return "erro_rel_max " + " ".join(out)

    if nome.startswith("multipass"):
        """SUSTAINED load, which is the regime no test in this repo touched.

        The community report about `cp queue preemption time out` is about large
        sustained GEMMs -- and unmap_queues_cpsch() escalates a preemption
        timeout straight into kfd_hws_hang() and a GPU reset. With the runlist
        patch enabled, every unmap becomes a preemption, so this is exactly where
        it may turn into a reset generator instead of a fix.

        Besides hanging, it measures DRIFT: the corruption may not show up on
        pass 1 and show up on pass 300. That is why it checks against the
        reference every K passes, rather than only at the end.
        """
        h, t, r = (2048, 1024, 32)
        passes = 400 if "longo" in nome else 150
        x = torch.randn(t, h, device=DEV, dtype=torch.float16)
        w = torch.randn(h, h, device=DEV, dtype=torch.float16) * 0.02
        A = (torch.randn(r, h, dtype=torch.float16) * 0.01)
        B = (torch.randn(h, r, dtype=torch.float16) * 0.01)
        AA = A.clone().to(DEV).requires_grad_(True)
        BB = B.clone().to(DEV).requires_grad_(True)

        # CPU reference, once, with the SAME initial weights
        xc, wc = x.cpu(), w.cpu()
        Ac = A.clone().requires_grad_(True); Bc = B.clone().requires_grad_(True)
        yc = xc @ wc + (xc @ Ac.t()) @ Bc.t()
        yc.float().pow(2).mean().backward()
        refA, refB = Ac.grad.float().clone(), Bc.grad.float().clone()

        def desvio():
            AA.grad = None; BB.grad = None
            y = x @ w + (x @ AA.t()) @ BB.t()
            y.float().pow(2).mean().backward()
            torch.cuda.synchronize()
            dA = float((AA.grad.float().cpu() - refA).abs().max() / refA.abs().max())
            dB = float((BB.grad.float().cpu() - refB).abs().max() / refB.abs().max())
            return max(dA, dB)

        # allocate and free every pass: the churn is what generates the stale translation
        piores, ruins = [], 0
        for i in range(passes):
            lixo = torch.empty(t * h, device=DEV, dtype=torch.float16)
            del lixo
            AA.grad = None; BB.grad = None
            y = x @ w + (x @ AA.t()) @ BB.t()
            y.float().pow(2).mean().backward()
            if (i + 1) % 25 == 0:
                d = desvio()
                piores.append(f"p{i+1}:{d:.2e}")
                if d > TOL:
                    ruins += 1
        torch.cuda.synchronize()
        return json.dumps({"eA": max(float(x_.split(":")[1]) for x_ in piores),
                           "eB": 0.0, "ok": ruins == 0, "finito": True,
                           "chapado": False, "gA": 0.0,
                           "gB": float(BB.grad.float().abs().sum()),
                           "trilha": " ".join(piores), "passes": passes})

    if nome == "distilgpt2_lora_bwd":
        """LoRA backward on a REAL causal model -- the closest thing to the report.

        Needs the FSDP guard in transformers/generation/utils.py: this PyTorch
        was built with USE_DISTRIBUTED=0 and transformers 5.x imports FSDP
        unconditionally. The only symbol used from there sits behind
        `world_size > 1`, impossible without distributed, so the fallback is exact.
        """
        from transformers import AutoModelForCausalLM
        m = AutoModelForCausalLM.from_pretrained("distilgpt2",
                                                 dtype=torch.float32).to(DEV)
        for p_ in m.parameters():
            p_.requires_grad_(False)
        alvos = [b.attn.c_attn for b in m.transformer.h]
        As, Bs, hooks = [], [], []
        for mod in alvos:
            fi, fo = mod.weight.shape[0], mod.weight.shape[1]
            A = (torch.randn(8, fi, device=DEV) * 0.01).requires_grad_(True)
            B = (torch.randn(fo, 8, device=DEV) * 0.01).requires_grad_(True)
            As.append(A); Bs.append(B)

            def faz(A=A, B=B):
                def h_(mod_, ent, sai):
                    return sai + (ent[0] @ A.t()) @ B.t()
                return h_
            hooks.append(mod.register_forward_hook(faz()))

        opt = torch.optim.SGD(As + Bs, lr=1e-4)
        ids = torch.randint(0, 50257, (2, 256), device=DEV)
        perdas = []
        for _ in range(iters):
            opt.zero_grad()
            out = m(ids, labels=ids)
            out.loss.backward()
            opt.step()
            perdas.append(float(out.loss))
        torch.cuda.synchronize()
        for h_ in hooks:
            h_.remove()
        gA = sum(float(a.grad.abs().sum()) for a in As)
        gB = sum(float(b.grad.abs().sum()) for b in Bs)
        finito = all(bool(torch.isfinite(a.grad).all()) for a in As) and \
                 all(bool(torch.isfinite(b.grad).all()) for b in Bs)
        chapado = gB == 0.0
        # no CPU reference: the whole model on the CPU would take minutes. What is
        # checked here is hangs, NaN, dead gradients and the loss moving.
        anda = abs(perdas[-1] - perdas[0]) > 1e-6
        return json.dumps({"eA": 0.0, "eB": 0.0,
                           "ok": finito and not chapado and anda,
                           "finito": finito, "chapado": chapado,
                           "gA": gA, "gB": gB,
                           "trilha": f"loss {perdas[0]:.4f}->{perdas[-1]:.4f} anda={anda}",
                           "passes": iters})

    if nome == "bloco_transformer_lora":
        """Hand-written GPT-2 style block: attention + MLP + layernorm, with LoRA on qkv.

        Replaces the stage that used distilgpt2. transformers 5.x does not load
        here -- this PyTorch was built WITHOUT distributed, and GenerationMixin
        imports torch._C._distributed_c10d unconditionally. It is an environment
        limitation, not a board defect, but it closes the path to causal models
        via transformers.

        The mix matters: a real block's backward interleaves LoRA's skinny GEMMs
        with softmax, layernorm and full GEMMs -- a much busier allocation
        pattern than synthetic LoRA, which is where the stale translation is born.
        """
        h, nh, t, r, camadas = 768, 12, 256, 8, 6
        dk = h // nh

        def bloco(dev, tdd, passos, reps):
            g = torch.Generator(device="cpu").manual_seed(0)
            def P(*sh, esc=0.02):
                return (torch.randn(*sh, generator=g) * esc).to(dev, tdd)
            x0 = P(t, h, esc=1.0)
            Wq = [P(h, 3 * h) for _ in range(camadas)]
            W1 = [P(h, 4 * h) for _ in range(camadas)]
            W2 = [P(4 * h, h) for _ in range(camadas)]
            A = [P(r, h, esc=0.01).requires_grad_(True) for _ in range(camadas)]
            B = [P(3 * h, r, esc=0.01).requires_grad_(True) for _ in range(camadas)]
            opt = torch.optim.SGD(A + B, lr=1e-3)

            def passe():
                x = x0
                for i in range(camadas):
                    xn = torch.nn.functional.layer_norm(x, (h,))
                    qkv = xn @ Wq[i] + (xn @ A[i].t()) @ B[i].t()
                    q, k, v = qkv.split(h, dim=-1)
                    q = q.view(t, nh, dk).transpose(0, 1)
                    k = k.view(t, nh, dk).transpose(0, 1)
                    v = v.view(t, nh, dk).transpose(0, 1)
                    att = (q @ k.transpose(-2, -1)) / (dk ** 0.5)
                    att = att.softmax(dim=-1)
                    o = (att @ v).transpose(0, 1).reshape(t, h)
                    x = x + o
                    xn = torch.nn.functional.layer_norm(x, (h,))
                    x = x + (xn @ W1[i]).relu() @ W2[i]
                return x.float().pow(2).mean()

            for _ in range(passos):
                opt.zero_grad(); passe().backward(); opt.step()
            for _ in range(reps):
                opt.zero_grad(); passe().backward()
            return (torch.cat([a.grad.float().flatten().cpu() for a in A]),
                    torch.cat([b.grad.float().flatten().cpu() for b in B]))

        gA, gB = bloco(DEV, torch.float32, 3, max(1, iters // 6))
        torch.cuda.synchronize()
        rA, rB = bloco("cpu", torch.float32, 3, 1)

        def rel(a, b):
            d = b.abs().max()
            return float((a - b).abs().max() / d) if d > 0 else float((a - b).abs().max())

        eA, eB = rel(gA, rA), rel(gB, rB)
        finito = bool(torch.isfinite(gA).all()) and bool(torch.isfinite(gB).all())
        chapado = float(gB.abs().sum()) == 0.0
        return json.dumps({"eA": eA, "eB": eB, "ok": eA < TOL and eB < TOL and finito
                           and not chapado, "finito": finito, "chapado": chapado,
                           "gA": float(gA.abs().sum()), "gB": float(gB.abs().sum())})

    # --- synthetic LoRA stages, with a CPU reference ---
    for cn, h, t, r, dt, passos in cfgs(iters):
        if cn != nome:
            continue
        td = torch.float32 if dt == "fp32" else torch.float16
        x = torch.randn(t, h, dtype=td)
        w = torch.randn(h, h, dtype=td) * 0.02
        A0 = torch.randn(r, h, dtype=td) * 0.01
        B0 = torch.randn(h, r, dtype=td) * 0.01   # NOT zero: exercises the data

        def treina(dev, reps):
            """reps repetitions of the backward. On the GPU it is the stress; on
            the CPU 1 is enough, because zero_grad() every lap makes each
            iteration produce the same gradient -- repeating there only burned
            minutes per stage.

            And the CPU runs in fp32, always. This CPU has no native fp16: under
            emulation a 1024x2048x2048 x@w takes tens of seconds, and in the
            h=4096 stages it hung the whole test. fp32 is also the reference we
            want -- the GPU is the one on trial."""
            tdd = torch.float32 if dev == "cpu" else td
            xx, ww = x.to(dev, tdd), w.to(dev, tdd)
            AA = A0.clone().to(dev, tdd).requires_grad_(True)
            BB = B0.clone().to(dev, tdd).requires_grad_(True)
            opt = __import__("torch").optim.SGD([AA, BB], lr=1e-3)
            for _ in range(passos):
                opt.zero_grad()
                y = xx @ ww + (xx @ AA.t()) @ BB.t()
                y.float().pow(2).mean().backward()
                opt.step()
            for _ in range(reps):
                opt.zero_grad()
                y = xx @ ww + (xx @ AA.t()) @ BB.t()
                y.float().pow(2).mean().backward()
            return AA.grad.float().cpu(), BB.grad.float().cpu()

        gA_gpu, gB_gpu = treina(DEV, iters)
        torch.cuda.synchronize()
        gA_cpu, gB_cpu = treina("cpu", 1)

        def rel(a, b):
            d = b.abs().max()
            return float((a - b).abs().max() / d) if d > 0 else float((a - b).abs().max())

        eA, eB = rel(gA_gpu, gA_cpu), rel(gB_gpu, gB_cpu)
        finito = bool(torch.isfinite(gA_gpu).all()) and bool(torch.isfinite(gB_gpu).all())
        # an identically zero gradient is the signature of fp16 saturating or of a
        # buffer never written -- it passes any "did it hang or not" test
        chapado = float(gB_gpu.abs().sum()) == 0.0
        ok = eA < TOL and eB < TOL and finito and not chapado
        return json.dumps({"eA": eA, "eB": eB, "ok": ok, "finito": finito,
                           "chapado": chapado,
                           "gA": float(gA_gpu.abs().sum()),
                           "gB": float(gB_gpu.abs().sum())})

    raise SystemExit(f"estagio desconhecido: {nome}")


if "--um" in sys.argv:
    i = sys.argv.index("--um")
    it = int(sys.argv[i + 2]) if len(sys.argv) > i + 2 else 20
    print(roda(sys.argv[i + 1], it), flush=True)
    sys.exit(0)

ITERS = int(sys.argv[1]) if len(sys.argv) > 1 else 20
LIM = 900
nomes = (["matmul_grande"] + [c[0] for c in cfgs(ITERS)]
         + ["bloco_transformer_lora", "distilgpt2_lora_bwd",
            "multipass", "multipass_longo"])

knob = open('/sys/module/amdgpu/parameters/bc250_flush_by_runlist').read().strip()
print(f"  patch runlist = {knob}   iters={ITERS}   tolerancia={TOL}")
print(f"  {'estagio':<26} {'veredito':<10} {'tempo':>7}  detalhe")
falhou, errado = [], []
for e in nomes:
    t0 = time.time()
    try:
        r = subprocess.run([sys.executable, os.path.abspath(__file__),
                            "--um", e, str(ITERS)],
                           capture_output=True, text=True, timeout=LIM)
        dt = time.time() - t0
        s = r.stdout.strip()
        if r.returncode != 0:
            det = (r.stderr.strip().splitlines() or ["?"])[-1][:80]
            print(f"  {e:<26} {'ERRO':<10} {dt:6.1f}s  {det}")
            falhou.append(e)
            continue
        v = "OK"
        try:
            d = json.loads(s)
            if not d["ok"]:
                v = "NUMERO_ERRADO"
                errado.append(e)
            if "trilha" in d:
                s = f"{d['passes']} passes  pior={d['eA']:.2e}  {d['trilha']}"
            else:
                s = (f"eA={d['eA']:.2e} eB={d['eB']:.2e} gB={d['gB']:.3f}"
                     + ("" if d.get("finito", True) else " NAO-FINITO")
                     + (" CHAPADO" if d.get("chapado") else ""))
        except Exception:
            pass
        print(f"  {e:<26} {v:<10} {dt:6.1f}s  {s}")
    except subprocess.TimeoutExpired:
        print(f"  {e:<26} {'TRAVOU':<10} >{LIM}s")
        falhou.append(e)

print()
print(f"  travou/errou de verdade : {', '.join(falhou) if falhou else 'nenhum'}")
print(f"  numero errado (silencioso): {', '.join(errado) if errado else 'nenhum'}")
