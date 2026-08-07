#!/usr/bin/env python3
"""LoRA backward nesta placa: trava? e, sobretudo, da o numero certo?

O relato da comunidade
----------------------
Numa BC-250, tudo funciona -- matmul cru de qualquer formato, distilgpt2
forward, treino sem LoRA, generate(), LoRA forward -- e SO o LoRA backward
trava.

Duas coisas diferentes sendo medidas aqui
-----------------------------------------
TRAVA e a assinatura do KIQ/preempcao. Nao e o defeito que este repo persegue.

CORRUPCAO SILENCIOSA e o nosso: numero errado, sem erro, sem trava. Por isso
cada estagio compara o resultado da GPU com o da CPU. Um estagio que termina
rapido e devolve lixo passaria num teste de "travou ou nao" -- e foi exatamente
assim que o fp16 do Z-Image enganou (exit 0, std=0.0, imagem de uma cor so).

O que o backward tem de especial
--------------------------------
Com y = x @ (W + B@A), o forward faz GEMMs cheias. O backward gera GEMMs em que
uma das dimensoes e o RANK -- 8, 16, 32 -- muito menor que as outras. Kernel
"magro", caminho de selecao do Tensile diferente do forward.

E o passo de otimizador importa: LoRA inicia com B=0, entao no primeiro
backward grad_A e identicamente zero e a GEMM roda com entrada nula. So depois
de alguns passos B fica denso e o backward exercita os dados de verdade.

Cada estagio roda como processo separado, com timeout, para que uma trava nao
leve o resto junto.

Uso:
    lora_backward.py [ITERS]      todos os estagios, cada um isolado
    lora_backward.py --um <nome> [ITERS]
"""
import json
import os
import subprocess
import sys
import time

# Sem isto o print do driver fica no buffer ate o processo terminar, e um teste
# de horas parece travado enquanto anda. Ja custou um diagnostico errado.
try:
    sys.stdout.reconfigure(line_buffering=True)
except Exception:
    pass

DEV = "cuda"
# Criterio GROSSEIRO, de proposito. A GPU roda fp16 e a referencia e fp32; com
# k=4096 o acumulo em fp16 erra ~1e-2 por si so, e uma tolerancia apertada
# marcaria isso como defeito -- ruido, nao sinal. O defeito deste repo entrega
# o CONTEUDO DE OUTRO BUFFER: erro de dezenas de por cento, ou NaN, ou zero
# chapado. E isso que se quer pegar.
TOL = 0.10


def cfgs(iters):
    """(nome, h, t, rank, dtype, passos_de_otimizador)"""
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
            # referencia na CPU uma vez so; em 4096 usa float64 por blocos seria
            # caro demais, entao fp32 mesmo -- a tolerancia ja e relativa
            ref = (a.float() @ b.float())
            ag, bg = a.to(DEV), b.to(DEV)
            for _ in range(iters):
                cg = ag @ bg
            torch.cuda.synchronize()
            err = (cg.float().cpu() - ref).abs().max() / ref.abs().max()
            out.append(f"{n}:{float(err):.2e}")
        return "erro_rel_max " + " ".join(out)

    if nome.startswith("multipass"):
        """Carga SUSTENTADA, que e o regime que nenhum teste deste repo tocou.

        O relato da comunidade sobre `cp queue preemption time out` e sobre
        GEMM grande e sustentado -- e unmap_queues_cpsch() escala um timeout de
        preempcao direto para kfd_hws_hang() e reset da GPU. Com o patch do
        runlist ligado, cada unmap vira uma preempcao, entao e exatamente aqui
        que ele pode virar gerador de reset em vez de conserto.

        Alem de travar, mede DERIVA: a corrupcao pode nao aparecer no passe 1 e
        aparecer no passe 300. Por isso confere contra a referencia a cada K
        passes, em vez de so no fim.
        """
        h, t, r = (2048, 1024, 32)
        passes = 400 if "longo" in nome else 150
        x = torch.randn(t, h, device=DEV, dtype=torch.float16)
        w = torch.randn(h, h, device=DEV, dtype=torch.float16) * 0.02
        A = (torch.randn(r, h, dtype=torch.float16) * 0.01)
        B = (torch.randn(h, r, dtype=torch.float16) * 0.01)
        AA = A.clone().to(DEV).requires_grad_(True)
        BB = B.clone().to(DEV).requires_grad_(True)

        # referencia na CPU, uma vez, com os MESMOS pesos iniciais
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

        # aloca e libera a cada passe: e o churn que gera a traducao obsoleta
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

    if nome == "bloco_transformer_lora":
        """Bloco estilo GPT-2 na mao: atencao + MLP + layernorm, com LoRA no qkv.

        Substitui o estagio que usava distilgpt2. O transformers 5.x nao carrega
        aqui -- este PyTorch foi compilado SEM distributed, e o GenerationMixin
        importa torch._C._distributed_c10d incondicionalmente. E limitacao do
        ambiente, nao defeito da placa, mas fecha o caminho para modelos causais
        via transformers.

        A mistura importa: o backward de um bloco real intercala GEMMs magras do
        LoRA com softmax, layernorm e GEMMs cheias -- padrao de alocacao bem mais
        movimentado que o LoRA sintetico, que e onde a traducao obsoleta nasce.
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

    # --- estagios de LoRA sintetico, com referencia na CPU ---
    for cn, h, t, r, dt, passos in cfgs(iters):
        if cn != nome:
            continue
        td = torch.float32 if dt == "fp32" else torch.float16
        x = torch.randn(t, h, dtype=td)
        w = torch.randn(h, h, dtype=td) * 0.02
        A0 = torch.randn(r, h, dtype=td) * 0.01
        B0 = torch.randn(h, r, dtype=td) * 0.01   # NAO zero: exercita os dados

        def treina(dev, reps):
            """reps repeticoes do backward. Na GPU e o estresse; na CPU basta 1,
            porque zero_grad() a cada volta faz toda iteracao produzir o mesmo
            gradiente -- repetir la so gastava minutos por estagio.

            E a CPU roda em fp32, sempre. Esta CPU nao tem fp16 nativo: em
            emulacao um x@w de 1024x2048x2048 leva dezenas de segundos, e nos
            estagios de h=4096 travava o teste inteiro. fp32 tambem e a
            referencia que se quer -- a GPU e que esta sendo julgada."""
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
        # gradiente identicamente zero e a assinatura do fp16 saturando ou do
        # buffer nunca escrito -- passa em qualquer teste de "travou ou nao"
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
         + ["bloco_transformer_lora", "multipass", "multipass_longo"])

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
