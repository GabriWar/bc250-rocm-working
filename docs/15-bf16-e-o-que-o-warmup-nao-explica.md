# bf16 mata o VAE na GPU, e o warmup continua sem veredito

Medido 2026-08-05/06, com o patch `bc250_skip_sdma0` ativo. Este documento
registra tanto o que foi isolado quanto três erros de método meus, porque os
erros custaram mais tempo que os achados.

---

## O pipeline inteiro, operação por operação

[`tools/trace_pipeline.py`](../tools/trace_pipeline.py) roda o pipeline do
ComfyUI sem o servidor e sem o grafo de nós — checkpoint, encode do CLIP,
sampler, decode do VAE — com `TorchDispatchMode` gravando cada chamada `aten`
em disco com `fsync` **antes** de executar. Se a máquina cair, a última linha
é a culpada.

Boot limpo, `page fault == 0`, primeira carga de GPU, sem warmup:

```
clip      5.485 operacoes    passou
sampler  16.340 operacoes    passou inteiro (4 passos)
vae         ~15 operacoes    MORREU

12155 [vae] ANTES  aten.convolution.default  (1,4,64,64):bfloat16:cuda
                                             (4,4,1,1):bfloat16:cuda
                                             (4,):bfloat16:cuda
      <sem DEPOIS>
```

A primeira convolução do decoder, um 1×1 sobre o latente, em **bfloat16**.
22.832 linhas gravadas, e `bfloat16` aparece **zero vezes** antes da fase do
VAE — o pipeline inteiro roda em fp16/fp32 até ali.

Isso reconfirma, por um terceiro caminho, o que já sabíamos:

- O tracer de 2026-08-05 pegou o VAE morrendo na operação 7 de 519, em
  `aten.mm.default` bf16.
- A comunidade russa mediu `clpeak --vulkan` nesta placa:
  `VK_KHR_shader_bfloat16 / shaderBFloat16Type not supported`.

A gfx1013 **não tem bf16 em hardware**. O ROCm não reporta isso, só morre — sem
erro, sem fault, o processo para.

Fix: `--fp16-vae`. Necessário, e não é contorno de bug nosso — é capacidade
ausente.

---

## Três erros meus nesta sequência

### 1. Atribuí ao warmup uma diferença que era de caminho

Rodei o `run_bench2.sh` (que usa `--cpu-vae`) sem warmup, deu
`hipErrorIllegalAddress`. Depois rodei o `trace_pipeline.py` (que **não** usa
`--cpu-vae`) sem warmup, e morreu em bf16. Concluí que a evidência do warmup
estava confundida por dtype.

**Errado, e a correção também estava errada.** As duas rodadas do bench usavam
`--cpu-vae` nos dois braços, então o VAE nunca subia para a GPU e bf16 nunca
entrava em nenhum deles. Aquela comparação era limpa quanto a dtype. O bf16 que
o tracer achou é um problema *diferente*, num caminho que o bench nem exercita.

Ou seja: errei ao atribuir, e depois errei de novo ao "corrigir".

### 2. Confundi alternar com contrabalancear

Montei o A/B do warmup na ordem `0, 1, 0, 1` e afirmei que isso removia o
efeito de posição. Não remove:

```
posicao 1 -> braco 0    <- a posicao especial (primeiro processo do boot)
posicao 2 -> braco 1
posicao 3 -> braco 0
posicao 4 -> braco 1
```

O braço `0` fica com **todas** as posições ímpares, incluindo a primeira. Se o
primeiro processo do boot se comporta diferente — e neste board se comporta —
esse efeito cai inteiro no braço que eu queria medir. Para contrabalancear de
verdade a ordem precisa ser `0,1,1,0` ou `1,0,0,1`.

### 3. Deixei o braço que falha envenenar o que não falha

O braço `WARMUP=0` pendura e deixa `page fault` no dmesg. As rodadas seguintes
da mesma bateria — inclusive o braço `WARMUP=1` — rodam sobre esse contexto
sujo. A regra de conferir `page fault == 0` antes de cada medida já estava
escrita neste repo desde 2026-08-05, e eu montei uma bateria que a viola por
construção.

Ainda: o `timeout 400` do bench faz cada falha por hang custar quase 7 minutos
de relógio, em vez de detectar o erro no log e sair.

---

## Estado dos contornos de userspace

Com o patch de SDMA ativo:

| contorno | veredito | evidência |
|---|---|---|
| `bc250_conv_fix.py` | **dispensável** | geração com e sem dá tamanhos idênticos ao KB e `std` na segunda casa |
| `bc250_no_empty_cache.py` | inconclusivo | seed 222 byte-idêntica, seed 111 mudou |
| `bc250_warmup.py` | **inconclusivo** | n=1 por braço, e as tentativas de refazer com n=2 saíram comprometidas |
| `--fp16-vae` | **necessário** | sem ele, bf16 mata na 1ª conv do decoder |

O warmup não menciona `dtype` de modelo, nem `model_management`, nem VAE — ele
só cria tensores próprios e roda 90 operações elementares em fp32 e fp16. Então
o que ele compensa, se compensa, não é o bf16.

---

## Como refazer o teste do warmup direito

1. **Um boot por medida** enquanto o braço que falha deixar `page fault`. Sem
   isso o braço seguinte mede envenenamento.
2. **Ordem contrabalanceada** entre boots: `0,1` num par, `1,0` no outro.
3. **Detecção de erro no log** em vez de `timeout 400`, para uma falha custar
   segundos e não sete minutos.
4. `--fp16-vae` ou `--cpu-vae` igual nos dois braços, para bf16 não entrar.

Enquanto isso não for feito, a afirmação "o warmup é necessário" tem uma única
observação por trás e não deve ser tratada como estabelecida.
