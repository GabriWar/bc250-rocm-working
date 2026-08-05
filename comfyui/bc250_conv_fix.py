# BC-250 (gfx1013): substitui conv2d do MIOpen por im2col + GEMM.
#
# MOTIVO, medido em 2026-08-05 em boot limpo, primeira carga de GPU:
#
#   familia de operacao          errados
#   ---------------------------  -------
#   matmul (rocBLAS/Tensile)       0/26
#   elementwise (kernels torch)    0/26
#   unfold / im2col                0/26
#   im2col + GEMM manual           0/26
#   conv2d via MIOpen             12/26   <- primeiro erro na 6a operacao
#
# Ou seja: nao e a fila de compute, nao e o tamanho do dispatch, nao e
# precisao (fp32 quebra igual), nao e o alocador. E o caminho de convolucao
# do MIOpen especificamente. O MIOpen nao tem banco de tuning pra gfx1013
# (84 arquivos de db, zero pra esta arquitetura), entao compila em JIT por
# heuristica generica e o resultado sai errado sem reportar erro nenhum.
#
# O proprio MIOpen ja escolhe o solver GemmFwdRest para estes shapes, que e
# im2col + GEMM. Este patch faz a mesma coisa pelos kernels do torch.
#
# CUSTO medido: nenhum.
#   c=320 h= 64   conv2d 1.68ms   im2col+mm 1.72ms
#   c=320 h=128   conv2d 6.32ms   im2col+mm 6.52ms
#   c=640 h= 32   conv2d 2.63ms   im2col+mm 2.67ms
#
# Desligar com BC250_CONV_FIX=0.

import os

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}

if os.environ.get("BC250_CONV_FIX", "1") != "0":
    try:
        import torch
        import torch.nn.functional as F

        _orig_conv2d = F.conv2d

        # Teto para a matriz intermediaria do im2col, em MB.
        # im2col materializa (cin*kh*kw) x (ho*wo). No UNet o latente e 64x64 e
        # isso da ~24 MB, mas o VAE decodifica em 512x512: 128 canais x 9 x
        # 512 x 512 = 604 MB em fp16. Numa placa com 4 GB de UMA isso derruba a
        # maquina -- aconteceu em 2026-08-05 antes desta guarda existir.
        # Acima do teto, cai de volta no conv2d do MIOpen: pior correcao, mas
        # a alternativa e travar o host.
        _MAX_COLS_MB = int(os.environ.get("BC250_CONV_FIX_MAX_MB", "192"))

        def _conv2d_im2col(input, weight, bias=None, stride=1, padding=0,
                           dilation=1, groups=1):
            # Fora da GPU, ou em casos que o im2col nao cobre bem, usa o original.
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

            # Acima do teto, cai de volta no conv2d do MIOpen.
            #
            # TENTATIVA DESCARTADA (2026-08-05): fatiar o im2col por faixas de
            # linhas, para nunca usar o MIOpen. O resultado numerico ficava
            # correto nos testes isolados (pico de 1152 MB caiu para ~670 MB),
            # mas a geracao completa do ComfyUI passou a DERRUBAR A MAQUINA de
            # forma reprodutivel, enquanto a versao com este fallback simples
            # roda em 37.7s/29.3s. A/B: sem patch 38.2/34.3 ok, com fatiamento
            # crash, com fallback simples 37.7/29.3 ok. Nao investiguei por que
            # -- provavelmente o padrao de alocacao do torch.cat por faixa.
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
