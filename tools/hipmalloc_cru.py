#!/usr/bin/env python3
"""O aliasing esta no alocador do PyTorch ou abaixo dele?

Medido antes (sobreposicao.py, 6 de 9 execucoes)
------------------------------------------------
Dois tensores VIVOS, com data_ptr diferentes e intervalos disjuntos, compartilham
memoria: preencher um muda o outro, no tensor inteiro.

    ref c=320 h=104 @0x7efcdf000000  3461120 elementos de "raj c=320 h=104"
    ref c=320 h=96  @0x7efcdf69a000  2949120 elementos de "raj c=320 h=96"

Sempre entre alocacoes do MESMO tamanho, e o preenchido por ultimo vence. Isso
acontece com kernels e copias totalmente serializados (HIP_LAUNCH_BLOCKING=1,
AMD_SERIALIZE_KERNEL=3, AMD_SERIALIZE_COPY=3), entao nao e corrida.

E acontece com `fill_`, um kernel de compute. Nao passa por DMA, staging, SDMA
nem MIOpen -- todo o caminho de copia que eu vinha investigando esta fora.

A pergunta que sobra
--------------------
O alocador do PyTorch entrega o mesmo bloco duas vezes, ou ele pede blocos
distintos e o que esta abaixo (HIP / KFD / tabelas de pagina) mapeia os dois no
mesmo lugar?

Este script pula o alocador do PyTorch e chama hipMalloc direto por ctypes,
depois de aquecer com PyTorch para chegar no mesmo estado.

    aliasing com hipMalloc cru  -> o defeito esta abaixo do PyTorch
    sem aliasing                -> o cache de blocos do PyTorch e o culpado
"""
import ctypes
import os
import sys

import numpy as np

import torch

DEV = "cuda"
OUT = os.path.expanduser("~/bc250-grimoire/hipmalloc_cru.result")
_f = open(OUT, "a", buffering=1)


def say(s):
    _f.write(s + "\n"); _f.flush(); os.fsync(_f.fileno())
    print(s, flush=True)


H2D, D2H = 1, 2
hip = ctypes.CDLL("libamdhip64.so")
hip.hipMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
hip.hipFree.argtypes = [ctypes.c_void_p]
hip.hipMemset.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_size_t]
hip.hipMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]
hip.hipDeviceSynchronize.argtypes = []


def ck(r, o):
    if r != 0:
        raise RuntimeError(f"{o} falhou com codigo {r}")


def aquecer(modo="tudo"):
    """O aquecimento faz duas coisas juntas: aloca muito e executa kernels.

    Sem aquecimento nenhum o aliasing nao aparece (0 de 6). Com ele, 5 de 6.
    Para saber QUAL das duas metades causa, cada modo faz so uma:

      alloc  aloca e libera as mesmas formas, sem nenhum kernel
      conv   roda conv2d sobre buffers pre-alocados, sem alocar nada novo
      tudo   as duas, como era antes
    """
    import torch.nn.functional as F
    if modo in ("alloc", "tudo"):
        for _ in range(2):
            for h in range(32, 136, 8):
                for c in (64, 320):
                    x = torch.randn(1, c, h, h, dtype=torch.float16)
                    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                    xg, wg = x.to(DEV), w.to(DEV)
                    if modo == "tudo":
                        _ = F.conv2d(xg, wg, padding=1)
    if modo == "orig":
        # EXATAMENTE o aquecimento original. No refactor eu passei a guardar os
        # tensores de device em nomes (xg, wg), o que os mantem vivos ate a
        # proxima atribuicao -- dois conjuntos vivos em pico em vez de um. Isso
        # sozinho fez o aliasing sumir, entao o padrao de alocacao importa e a
        # comparacao alloc-vs-conv so vale contra esta referencia.
        for _ in range(2):
            for h in range(32, 136, 8):
                for c in (64, 320):
                    x = torch.randn(1, c, h, h, dtype=torch.float16)
                    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                    _ = F.conv2d(x.to(DEV), w.to(DEV), padding=1)
    if modo == "so-alloc":
        # MESMAS alocacoes do orig, MESMO tempo de vida, zero kernel.
        # O conv2d aloca tambem a saida (padding=1, stride=1 -> mesma forma da
        # entrada), entao ela entra aqui como torch.empty para o padrao de
        # alocacao bater. A tentativa anterior falhou por guardar os tensores de
        # device em nomes que sobreviviam a iteracao: dois conjuntos vivos em
        # pico em vez de um, e o aliasing sumia. Aqui vive e morre igual.
        for _ in range(2):
            for h in range(32, 136, 8):
                for c in (64, 320):
                    x = torch.randn(1, c, h, h, dtype=torch.float16)
                    w = torch.randn(c, c, 3, 3, dtype=torch.float16)
                    a = x.to(DEV); b = w.to(DEV)
                    o = torch.empty(1, c, h, h, dtype=torch.float16, device=DEV)
                    del a, b, o
    if modo == "so-kernel":
        # MESMA quantidade de kernels, ZERO alocacao nova: tudo pre-alocado e
        # as operacoes sao in-place.
        xg = torch.randn(1, 320, 112, 112, dtype=torch.float16, device=DEV)
        wg = torch.randn(320, 320, 3, 3, dtype=torch.float16, device=DEV)
        for _ in range(2 * 13 * 2 * 3):
            xg.mul_(1.0001)
            wg.mul_(0.9999)
    torch.cuda.synchronize()


# tamanhos iguais aos tensores do reprodutor, em bytes
TAM = [320*112*112*2, 320*128*128*2, 320*104*104*2,
       320*96*96*2,   320*64*64*2,   64*64*64*2]

boot = open("/proc/sys/kernel/random/boot_id").read().strip()[:8]
say("")
say("=" * 70)
say(f"boot={boot} pid={os.getpid()}")

# Segundo argumento: aquecer ou nao. Com churn=0 o aliasing ainda apareceu 3/3,
# entao nao e o caminho de liberacao. Mas o aquecimento do PyTorch continua
# antes, e desde o inicio da investigacao se sabe que sem atividade previa de
# GPU nada corrompe. Este e o discriminador que falta.
MODO = sys.argv[2] if len(sys.argv) > 2 else "tudo"
if MODO != "sem-aquecer":
    aquecer(MODO)
    say(f"  aquecimento modo={MODO}; agora hipMalloc cru")
else:
    torch.zeros(1, device=DEV); torch.cuda.synchronize()   # so cria o contexto
    say("  SEM aquecimento; so o contexto de HIP inicializado")

# Quantas rodadas de alocar-e-liberar antes do teste. A suspeita e que a
# armadilha seja armada AQUI: paginas liberadas voltando para um VA novo sem a
# invalidacao de TLB correspondente. Se com 0 rodadas nao houver aliasing, o
# defeito esta no caminho de unmap, nao no de map.
CHURN = int(sys.argv[1]) if len(sys.argv) > 1 else 3
say(f"  rodadas de alocar-e-liberar antes do teste: {CHURN}")
for _ in range(CHURN):
    tmp = []
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc(churn)")
        tmp.append(p)
    for p in tmp:
        ck(hip.hipFree(p), "hipFree")

# duas rodadas das mesmas formas, todas vivas ao mesmo tempo
blocos = []
for rodada in ("A", "B"):
    for t in TAM:
        p = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(p), ctypes.c_size_t(t)), "hipMalloc")
        blocos.append((f"{rodada} {t}B", p, t))

for rot, p_, n_ in blocos:
    say(f"  BLOCO {rot} @0x{p_.value:x} +{n_}")

# sobreposicao aritmetica dos ponteiros
for i in range(len(blocos)):
    for j in range(i + 1, len(blocos)):
        (ra, a, na), (rb, b, nb) = blocos[i], blocos[j]
        if a.value < b.value + nb and b.value < a.value + na:
            say(f"  SOBREPOSICAO ARITMETICA: {ra} @0x{a.value:x} x {rb} @0x{b.value:x}")

# cada bloco recebe um byte unico
for k, (rot, p, t) in enumerate(blocos):
    ck(hip.hipMemset(p, ctypes.c_int(k + 1), ctypes.c_size_t(t)), "hipMemset")
ck(hip.hipDeviceSynchronize(), "hipDeviceSynchronize")

# e volta pra conferir
ruins = 0
for k, (rot, p, t) in enumerate(blocos):
    buf = (ctypes.c_ubyte * t)()
    ck(hip.hipMemcpy(buf, p, ctypes.c_size_t(t), D2H), "hipMemcpy D2H")
    esperado = k + 1
    # memoryview de array ctypes tem formato "<B" e nao indexa direto aqui;
    # frombuffer ve os mesmos bytes sem copiar e ainda conta vetorizado
    mv = np.frombuffer(buf, dtype=np.uint8)
    if mv[0] != esperado or mv[t - 1] != esperado:
        d = mv != esperado
        ruim = int(d.sum())
        i0 = int(np.argmax(d))
        outro = int(mv[i0]) - 1
        quem = blocos[outro][0] if 0 <= outro < len(blocos) else f"byte {int(mv[i0])}"
        ruins += 1
        say(f"  PISADO: {rot} @0x{p.value:x} tem {ruim} bytes de \"{quem}\" "
            f"a partir de {i0} (0x{p.value + i0:x})")

say(f"  resumo: {ruins} de {len(blocos)} blocos de hipMalloc cru pisados")

# ---- fase 2: a PTE esta errada na memoria, ou so a cache de traducao esta velha?
#
# Se a PTE gravada estiver correta e o problema for a GPU traduzir por uma
# entrada em cache antiga, entao forcar uma invalidacao e REESCREVER deve
# acertar o bloco. Se a PTE em si estiver errada, reescrever continua errando.
#
# Um par hipMalloc/hipFree passa por KFD map/unmap, que chama kfd_flush_tlb.
# E o caminho de invalidacao de processo disponivel de fora do kernel.
if ruins:
    say("  ---- fase 2: forca invalidacao e reescreve ----")
    lixo = []
    for _ in range(6):
        q = ctypes.c_void_p()
        ck(hip.hipMalloc(ctypes.byref(q), ctypes.c_size_t(4 << 20)), "hipMalloc(flush)")
        lixo.append(q)
    for q in lixo:
        ck(hip.hipFree(q), "hipFree(flush)")
    ck(hip.hipDeviceSynchronize(), "sync pos-flush")

    recuperados = 0
    ainda = 0
    for k, (rot, pp, t) in enumerate(blocos):
        novo = ((k + 1) * 7) % 251 + 1        # valor diferente do da fase 1
        ck(hip.hipMemset(pp, ctypes.c_int(novo), ctypes.c_size_t(t)), "hipMemset(2)")
    ck(hip.hipDeviceSynchronize(), "sync")
    for k, (rot, pp, t) in enumerate(blocos):
        novo = ((k + 1) * 7) % 251 + 1
        buf2 = (ctypes.c_ubyte * t)()
        ck(hip.hipMemcpy(buf2, pp, ctypes.c_size_t(t), D2H), "hipMemcpy(2)")
        a2 = np.frombuffer(buf2, dtype=np.uint8)
        d2 = a2 != novo
        if int(d2.sum()):
            ainda += 1
            i0 = int(np.argmax(d2))
            say(f"    AINDA ERRADO: {rot} {int(d2.sum())} bytes, valor {int(a2[i0])} "
                f"(esperado {novo}) a partir de {i0}")
        else:
            recuperados += 1
    say(f"    apos invalidacao forcada: {ainda} blocos ainda errados, "
        f"{recuperados} corretos")
    if ainda == 0:
        say("    => a PTE na memoria estava CERTA: o defeito e de INVALIDACAO")
    else:
        say("    => reescrever nao resolveu: a PTE gravada esta ERRADA")

# Terceiro argumento "segurar": mantem os blocos VIVOS e espera, para que
# /sys/kernel/debug/dri/*/amdgpu_vm_info possa ser lido com o mapeamento ainda
# montado. Sem isso o debugfs sai vazio: ele so mostra VMs de processos ativos.
# Assim para de inferir mapeamento pelo conteudo e passa a ler a tabela.
if ruins and len(sys.argv) > 3 and sys.argv[3] == "cpu":
    # No KFD o endereco e unificado: o ponteiro do hipMalloc tambem esta mapeado
    # para a CPU. Isso separa as camadas de vez.
    #
    #   CPU tambem ve o aliasing  -> as duas VAs apontam para a mesma memoria
    #                                fisica no mapeamento de host: o defeito
    #                                esta no mmap/alocacao de BO
    #   so a GPU ve               -> o mapeamento de host esta certo e as
    #                                tabelas de pagina da GPU (GPUVM) e que
    #                                estao erradas
    say("  ===== quem ve o aliasing: CPU ou so a GPU? =====")
    for ln in open(f"/proc/{os.getpid()}/maps"):
        try:
            ini = int(ln.split("-")[0], 16)
        except ValueError:
            continue
        for rot, pp, t in blocos:
            if ini == pp.value:
                say(f"    {rot} @0x{pp.value:x} -> {ln.rstrip()}")

    # escreve pela CPU em cada bloco e le pela CPU
    for k, (rot, pp, t) in enumerate(blocos):
        ctypes.memset(pp, 200 + k, t)
    for k, (rot, pp, t) in enumerate(blocos):
        arr = np.frombuffer((ctypes.c_ubyte * t).from_address(pp.value), dtype=np.uint8)
        esperado = (200 + k) & 0xFF
        d = arr != esperado
        if int(d.sum()):
            i0 = int(np.argmax(d))
            outro = int(arr[i0]) - 200
            quem = blocos[outro][0] if 0 <= outro < len(blocos) else f"byte {int(arr[i0])}"
            say(f"    CPU TAMBEM VE: {rot} @0x{pp.value:x} tem {int(d.sum())} bytes "
                f"de \"{quem}\" a partir de {i0}")
    say("    (se nao apareceu nenhuma linha 'CPU TAMBEM VE', so a GPU aliasa)")

if ruins and len(sys.argv) > 3 and sys.argv[3] == "segurar":
    # o proprio processo dumpa o debugfs enquanto segura os blocos: coordenar
    # isso pelo shell exige esperar por um arquivo-sinal, e a espera e fragil
    import subprocess
    say(f"  lendo amdgpu_vm_info com os blocos ainda mapeados (pid {os.getpid()})")
    for d in ("1", "128"):
        for arq in ("amdgpu_vm_info", "amdgpu_gem_info"):
            r = subprocess.run(["sudo", "-S", "cat", f"/sys/kernel/debug/dri/{d}/{arq}"],
                               input="grdg\n", capture_output=True, text=True)
            saida = r.stdout.strip()
            if not saida:
                continue
            say(f"  ===== dri/{d}/{arq} ({len(saida.splitlines())} linhas) =====")
            for ln in saida.splitlines():
                say("    " + ln)

for rot, p, t in blocos:
    hip.hipFree(p)
say("FIM")
