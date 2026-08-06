# The corruption is in the host-to-device copy, not in any kernel

Measured 2026-08-05. This supersedes the attribution in
[11-miopen-conv-corruption.md](11-miopen-conv-corruption.md), which blames
MIOpen. MIOpen is not the culprit.

---

## What was measured

Upload tensors to the GPU, read them straight back, compare. No convolution,
no MIOpen, no kernel of ours — `x.to("cuda")` and `.cpu()`, byte for byte.

```
A: uploads em rajada, sync so no fim
   c=320 h=112  1048434/4014080 elementos DIFERENTES  primeiro no indice 0
   c=320 h=128  1048471/5242880 elementos DIFERENTES  primeiro no indice 1048576
   c=320 h=128  1048461/5242880 elementos DIFERENTES  primeiro no indice 1048576

B: um upload por vez, sync a cada um
   todos identicos, 48/48
```

`1048576 = 2^20`. In fp16 that is exactly **2 MiB**, and the first bad index is
always a multiple of it. **One 2 MiB chunk of a large transfer never lands**
when several copies are queued without synchronisation between them. The ~140
elements short of the full 2^20 are values that happened to match by chance in
random data.

Requires prior GPU activity: with no warmup, 48/48 uploads are clean. The first
version of `tools/h2d_fix.py` omitted the warmup and reported zero corruption
for every mitigation — which would have "proved" a fix for something that was
not broken in that run.

---

## Why this explains everything that did not fit

| observation | explanation |
|---|---|
| conv and im2col produce the *same* wrong value, to three digits | both compute correctly on the same corrupted input |
| only `c=320` fails, `c=64` never | `c=64 h=64` is 512 KB — one chunk, never split |
| serialisation env vars appear to help | they force one copy at a time |
| VAE breaks right after a model unload | a model swap is a burst of copies |
| ComfyUI fails where isolated tests pass | isolated tests do not batch uploads |
| `empty_cache()` poisons exactly the next operation | same mechanism |
| the failing shape set is stable within a session, different across sessions | it follows allocation, not the shape |

Two GPU paths giving *identical* wrong answers was the tell. Different
algorithms do not coincide to three significant figures unless they are reading
the same bad data.

---

## The mechanism: lost completion signalling on SDMA0

At every boot, before any workload:

```
amdgpu 0000:01:00.0: Fence fallback timer expired on ring sdma0
amdgpu 0000:01:00.0: Fence fallback timer expired on ring sdma0
amdgpu 0000:01:00.0: ring sdma0 uses VM inv eng 12 on hub 0
amdgpu 0000:01:00.0: ring sdma1 uses VM inv eng 13 on hub 0
```

`amdgpu_fence_fallback()` warns *only* when `amdgpu_fence_process()` found an
already-completed fence. So the transfer finished and **the interrupt was
lost** — SDMA0 is not stuck, it is silent. SDMA1 never produces the warning.

That is one defect with two faces:

- `HSA_ENABLE_SDMA=1` — the copy completes, nothing signals, the caller spins.
  Measured: 199% CPU, state `R`, no progress for minutes on a warmup that takes
  seconds otherwise.
- `HSA_ENABLE_SDMA=0` — blit-kernel fallback, completion signalling unreliable
  the same way, so a batched copy is treated as done early and loses a chunk.

We had been running the second because the first hangs. Both are broken.

---

## Mitigations that do not work

48 uploads each, with warmup, one process at a time:

| | corrupted |
|---|---|
| baseline | 9 |
| pinned host memory | **16** |
| `non_blocking=True` + pinned | 8 |
| `HSA_ENABLE_SDMA=1` | never completes |

Pinned memory is *worse*, which argues the staging buffer is not the problem.
Nothing in userspace fixes it.

---

## The patch

[`patches/bc250-kfd-skip-sdma0.patch`](../patches/bc250-kfd-skip-sdma0.patch)
keeps user SDMA queues off engine 0 inside KFD.

`allocate_sdma_queue()` takes the first free bit and derives the engine as
`sdma_id % num_engines`, so with two engines the even ids land on engine 0 and
the first queue of every process goes there. Clearing those bits leaves engine
0 to the kernel's own ring.

Costs half the SDMA queue slots. Behind `amdgpu.bc250_skip_sdma0=1`, default
off, so it can be A/B tested against the same build.

neoney's `clr-prefer-sdma1` does the same steering in ROCclr. Doing it in KFD
covers every client and survives a ROCm rebuild.

**RETRATADO 2026-08-06 -- ver o aviso no fim deste documento. O que segue neste bloco esta ERRADO e fica registrado apenas como historico.**

**~~VALIDADO 2026-08-05.~~** Compilado com clang (`make LLVM=1`), instalado,
bootado com `amdgpu.bc250_skip_sdma0=1`. O dmesg confirma que o codigo novo
executou, nao apenas que o parametro foi lido:

```
amdgpu 0000:01:00.0: BC-250: user SDMA queues restricted to engines 1..1
```

Resultado, descartando a primeira execucao de cada boot:

| | execucoes que corromperam |
|---|---|
| sem patch (baseline, boot e441f60c) | 3 de 3 |
| sem patch (controle, boot 7109b76f) | 2 de 3 |
| **com patch (boot 8d8d783b)** | **0 de 5** |

18 ciclos com o patch, nenhum corrompido. Com taxa de 5/6 no controle, cinco
execucoes limpas por acaso tem probabilidade ~0.01%.

O controle tambem confirmou que o rebuild e neutro: `ctrlB-run3` saiu
byte-identica ao baseline (1048434 / 1048471 / 1048461), entao o modulo novo
com o patch desligado se comporta como o antigo.

### Uma previsao minha que estava errada

Eu previ que o patch NAO pegaria, argumentando que com `HSA_ENABLE_SDMA=0` o
ROCr estaria no caminho de blit e nao usaria filas de SDMA de usuario. Pegou.
Ou seja, `HSA_ENABLE_SDMA=0` nao impede o ROCr de alocar fila de SDMA pelo KFD
-- e a primeira fila de cada processo caia no engine 0.

Isso tambem explica por que nenhuma mitigacao de userspace funcionou: memoria
pinada, `non_blocking` e tamanho de staging mexem em *como* pedir a copia,
enquanto o defeito estava em *qual engine* atendia.

---

## What this means for `bc250_conv_fix.py`

The patch routes `conv2d` around MIOpen and measured 12/26 → 0/26 at the time.
That measurement was real, but the attribution was wrong: on a clean boot as
first GPU load, MIOpen's `conv2d` was correct on all six target shapes while
the im2col+GEMM path failed on three.

It should not be presented as a correctness fix until re-measured against the
SDMA patch. If the copy is what corrupts, neither path was ever wrong.

---

## Method notes worth keeping

**Order confound.** A batch that always ran `conv` first and `im2col` second
reported 11 im2col failures out of 18. Alternating the order gave 0 out of 18.
The real difference turned out to be something else entirely — whether GPU work
was batched before the copies — but the lesson stands: if two things are always
measured in the same order, the second one carries the blame.

**`nan` is not `ok`.** Every comparison against `nan` is false, so a
`if err > TOL` verdict silently passes the worst possible result. One row read
`nan nan nan nan ok` before this was fixed.

**Concurrent processes.** Two GPU processes overlapped during one battery
because a backgrounded run never exited. Those numbers were discarded.

---

## Baseline reproduzível (2026-08-05, boot e441f60c)

Quatro processos seguidos, mesmo boot, `tools/h2d_check.py`:

| run | corrompidos (modo A) | observação |
|---|---|---|
| 1 | 0 de 3 ciclos | primeiro processo do boot |
| 2 | 3 de 3 | |
| 3 | 3 de 3 | offset 2097152 em vez de 1048576 |
| 4 | 3 de 3 | **byte-idêntica à run 2** |

Modo B (sync a cada upload): **0 falhas em 12 ciclos**.

Run 2 e run 4 coincidem até a unidade — mesmos tensores, mesmos offsets, mesmas
contagens (1048434 / 1048471 / 1048461). O defeito é determinístico dado o mesmo
estado.

O primeiro processo de cada boot passa limpo mesmo com aquecimento. Ou seja o
estado que habilita a falha **atravessa processos**, ao contrário da corrupção
de conv2d medida antes, que não atravessava. Pergunta aberta: são dois
mecanismos ou o mesmo visto de dois ângulos.

**Ressalva sobre o determinismo.** A tabela acima, de um boot so, sugeria que
toda execucao pos-primeira falha. O boot de controle desmentiu: deu 0 3 3 0.
Somando os dois boots sem patch, 5 de 6 execuções corromperam -- e quando
corrompem e sempre 3 de 3 ciclos, nunca parcial. E binario por execucao.

Por isso o braco com patch usou 6 execucoes e nao 3.

**Como usar isto para validar um patch:** descartar a primeira execucao do
boot, usar pelo menos 6 execucoes por braco, e comparar quantas execucoes
corromperam -- nao quantos ciclos. Sem descartar a primeira, o teste mede o
estado limpo e nao a hipotese.

**O tamanho do bloco perdido varia.** Alem dos ~2^20 elementos (2 MiB), o boot
7109b76f produziu ~2^18 (512 KiB). O que se mantem e o *inicio*: sempre num
multiplo exato de 2^20. Alinhamento fixo, tamanho variavel -- o que enfraquece
a leitura de "buffer de staging de tamanho fixo" que este documento sugeria.

---

## Os contornos de userspace depois do patch (2026-08-05, boot 8d8d783b)

Geração 512×512, 2 seeds, validada por estatística de pixel:

| configuração | seed 111 | seed 222 |
|---|---|---|
| com `conv_fix` | 385KB std=74.41 cores=117062 | 370KB std=75.15 cores=90181 |
| sem `conv_fix` | 385KB std=74.47 cores=116995 | 370KB std=74.84 cores=89809 |
| sem `conv_fix` e sem `no_empty_cache` | **395KB std=73.64 cores=105545** | 370KB std=74.84 cores=89809 |

**`bc250_conv_fix.py` é dispensável.** Com o patch de SDMA, a conv do MIOpen dá
o mesmo resultado que o im2col — tamanhos idênticos ao KB, `std` batendo na
segunda casa. Confirma que os dois caminhos sempre computaram certo, sobre
entrada corrompida.

**`bc250_no_empty_cache.py` é inconclusivo.** A seed 222 saiu byte-idêntica; a
seed 111 mudou (10 KB a mais, 10% menos cores únicas). As duas continuam
saudáveis pelo critério grosseiro, mas mudou — e `empty_cache()` é exatamente o
gatilho de rajada de cópias.

Estatística de pixel não distingue "um pouco errado" de "legitimamente
diferente". Para resolver: repetir a mesma seed várias vezes e ver se ela é
estável em si mesma, ou comparar contra a mesma seed rodada inteira na CPU.


---

# RETRATACAO (2026-08-06): o patch de SDMA nao corrige a corrupcao

O bloco "VALIDADO" acima esta errado. Ele afirma que com
`amdgpu.bc250_skip_sdma0=1` foram "0 corrompidos em 18 ciclos", com ~0.01% de
chance de ser sorte. **Nao foi isso que os dados mostram.**

Contando o mesmo arquivo de historico corretamente, as seis execucoes com o
patch LIGADO (`skip1-run1` a `skip1-run6`, boot 8d8d783b) corromperam:

```
skip1-run1   3 corrupcoes
skip1-run2   1
skip1-run3   4
skip1-run4   3
skip1-run5   3
skip1-run6   3
             --
             17 corrupcoes em 108 oportunidades = 15.7%
```

Que e indistinguivel do estado sem o patch.

## Como o erro aconteceu

O contador usava ancora de fim de linha:

```bash
awk '/rotulo=skip1-run'"$r"'$/{f=1;next} /^rotulo=/{f=0} f&&/DIFERENTES/{c++}'
```

A linha do historico e `rotulo=skip1-run1  boot=8d8d783b  up 1 minute ...`, ou
seja continua depois do rotulo. Com o `$`, o padrao nunca casa, a flag nunca
liga, e o `END` imprime `0` para todas as execucoes. Vi seis zeros seguidos e
declarei vitoria sem abrir o arquivo bruto -- que listava as corrupcoes o tempo
todo, algumas byte-identicas as do baseline.

O mesmo bug reapareceu em 2026-08-06 medindo carve-out de VRAM, e dessa vez foi
pego porque eu imprimi o detalhe junto com a contagem.

## O que continua valendo neste documento

- A caracterizacao da corrupcao: rajada de uploads sem sync perde um bloco;
  tamanhos observados de 512 KiB a 2.5 MiB; offsets em geral multiplos de 2^20,
  mas nao sempre (visto 733184).
- **O modo B -- sync a cada upload -- nunca corrompeu em nenhuma configuracao
  testada.** Esse e o unico resultado que sobreviveu a tudo: VRAM de 512 MB a
  12 GB, GTT de 1 GB a 12.85 GB, com e sem patches.
- O diagnostico do SDMA0 (IRQ de conclusao perdida, `Fence fallback timer`) e
  leitura direta do dmesg e continua valendo como observacao. O que nao vale e
  a conclusao de que desviar as filas de usuario do engine 0 conserta a
  corrupcao.

## Taxa por carve-out de VRAM (2026-08-06)

Cada execucao = 3 ciclos x 6 tensores no modo A = 18 oportunidades.

| VRAM | execucoes | corrompidos | taxa | IC95 |
|---|---|---|---|---|
| 512 MB | 3 | 11/54 | 20.4% | [11.8%, 32.9%] |
| 4 GB | 6 | 17/108 | 15.7% | [10.1%, 23.8%] |
| 12 GB | 6 | 13/108 | 12.0% | [7.2%, 19.5%] |

Tendencia monotonica, mas os tres intervalos se sobrepoem: indicio, nao
demonstrado. E a comparacao 12 GB contra as outras e confundida, porque nesse
ponto o `gttsize` tambem mudou (13156 -> 1024). O par limpo e 512 MB contra
4 GB, mesma configuracao de GTT.
