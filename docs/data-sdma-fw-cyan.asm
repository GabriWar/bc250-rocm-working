
PKT_0x0:
  00000:    save       r8, #0x10e4
  00004:    setned     r14, r1, #0x8d6b
  00008:    seteq      r8, r10, #0x3b65
  0000c:    ext03      r3, r12, #0x73c0
  00010:    seteq      r4, r5, #0x5024  ; b=3
  00014:    nop
  00018:    nop
  0001c:    nop
  00020:    nop
  00024:    nop
  00028:    nop
  0002c:    nop
  00030:    nop
  00034:    nop
  00038:    lsld       r1, r6, #0xb830  ; b=2
  0003c:    cbnz       r5, True
  00040:    mov        r14, #0xffae  ; rs=r12
  00044:    b.29       True   ; r8, r8
  00048:    nop
  0004c:    nop
  00050:    nop
  00054:    nop
  00058:    nop
  0005c:    nop
  00060:    nop
  00064:    ext3f      r15, r15, #0xffff
  00068:    nop
  0006c:    nop
  00070:    nop
  00074:    nop
  00078:    nop
  0007c:    nop
  00080:    nop
  00084:    nop
  00088:    nop
  0008c:    nop
  00090:    nop
  00094:    nop
  00098:    nop
  0009c:    nop
  000a0:    nop
  000a4:    nop
  000a8:    nop
  000ac:    nop
  000b0:    nop
  000b4:    nop
  000b8:    nop
  000bc:    nop
  000c0:    nop
  000c4:    nop
  000c8:    nop
  000cc:    nop
  000d0:    dw         0x84e7bf36  #rs=3 rd=9 rx=14 a=0x21 b=0x3, imm=0xbf36
  000d4:    b.2c       True   ; r12, r6
  000d8:    ldw.e      r4, [r8, #0x144a]
_PKT_0x0_0:
  000dc:    sub        r12, r2, #0x73ab
  000e0:    ext3d      r4, r0, #0xa0ec
  000e4:    ext03      r1, r7, #0x55cb
  000e8:    orrd       r1, r9, #0x9b41  ; b=1
  000ec:    sub        r7, r14, #0x169e  ; b=2
  000f0:    nop
  000f4:    nop
  000f8:    nop
  000fc:    nop
  00100:    nop
  00104:    std        r1, [r0, #0x30]
  00108:    std        r1, [r0, #0xfa]
  0010c:    nop
  00110:    nop
  00114:    ldd        r3, reg[r0, #0x5b44]
  00118:    and        r6, r3, #0xffffffff
  0011c:    stw        r6, reg[r0, #0x5b44]
  00120:    std        r1, [r0, #0x9b]
  00124:    std        r1, [r0, #0x9a]
  00128:    mov        r12, #0x4a2c
  0012c:    stw        r12, [r0, #0x6b]
  00130:    stw        r0, [r0, #0x64]
_PKT_0x0_1:
  00134:    ldd        r6, reg[r12, #0x0]
  00138:    and        r3, r6, #0xfffff801
  0013c:    cbz        r3, _PKT_0x0_1
  00140:    stw        r0, [r0, #0x30]
  00144:    nop
  00148:    nop
  0014c:    stw        r0, [r0, #0x76]
_PKT_0x0_2:
  00150:    stw        r0, [r0, #0x75]
  00154:    stw        r0, [r0, #0x85]
  00158:    std        r0, [r0, #0x9b]
  0015c:    std        r0, [r0, #0x9a]
  00160:    ldd        r6, reg[r0, #0x5abc]
  00164:    cbz        r6, _PKT_0x0_3
  00168:    stw        r0, [r0, #0x42]
_PKT_0x0_3:
  0016c:    stw        r0, [r0, #0x6b]
  00170:    std        r1, [r0, #0x30]
  00174:    ldd        r3, reg[r0, #0x5b44]
  00178:    orr        r6, r3, #0x0
  0017c:    stw        r6, reg[r0, #0x5b44]
  00180:    ldd        r10, reg[r0, #0x4acc]
_PKT_0x0_4:
  00184:    orr        r11, r10, #0x2
  00188:    cbnz       r11, _NOP_1

PKT_0x0:
  0018c:    std        r0, [r0, #0xfa]
  00190:    dw         0x840013c6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13c6
  00194:    dw         0x840013b8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13b8
  00198:    std        r1, [r0, #0x108]
  0019c:    ldd        r10, reg[r0, #0x5b50]
  001a0:    and        r6, r10, #0xfffff001
  001a4:    cbz        r6, _PKT_0x0_0
  001a8:    mov        r10, #0x2
  001ac:    stw        r10, [r0, #0x104]
_PKT_0x0_0:
  001b0:    ldd        r6, reg[r0, #0x7c]
  001b4:    and        r5, r6, #0xf800ffff
  001b8:    cbnz       r5, _PKT_0xf0_153
  001bc:    stw        r0, [r0, #0x6b]
  001c0:    dw         0x840013ad  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13ad
  001c4:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  001c8:    ldd        r5, reg[r0, #0x5a80]
  001cc:    and        r6, r5, #0xfffff001
  001d0:    cbz        r6, _PKT_0xf0_11
  001d4:    ldd        r6, reg[r0, #0xfc]
  001d8:    cbnz       r6, _PKT_0xf0_197
_PKT_0x0_1:
  001dc:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  001e0:    nop
  001e4:    ldd        r3, reg[r0, #0xc8]
  001e8:    cbz        r3, _PKT_0x0_2
  001ec:    stw        r0, [r0, #0xc2]
  001f0:    ldd        r6, [r0, #0xc9]
  001f4:    cbnz       r6, _PKT_0xf0_14
  001f8:    stw        r0, [r0, #0xc7]
  001fc:    and        r4, r3, #0xfffff001
  00200:    cbnz       r4, _INDIRECT_BUFFER_END_2
  00204:    and        r4, r3, #0xffffe003
  00208:    cbnz       r4, _DISPATCH_DIRECT_0
  0020c:    and        r4, r3, #0xffff800f
  00210:    cbnz       r4, _SET_BASE_11
  00214:    and        r4, r3, #0xfff800ff
  00218:    cbnz       r4, _DISPATCH_INDIRECT_0
  0021c:    and        r4, r3, #0xf800ffff
  00220:    cbnz       r4, _REG_RMW_2
_PKT_0x0_2:
  00224:    ldd        r6, reg[r0, #0x7c]
  00228:    and        r5, r6, #0xf800ffff
  0022c:    cbnz       r5, _PKT_0xf0_153
  00230:    ldd        r4, reg[r0, #0x5ac0]
  00234:    cbz        r4, _PKT_0x0_4
  00238:    ldd        r4, reg[r0, #0x5b40]
_PKT_0x0_3:
  0023c:    and        r4, r4, #0xfffff001
  00240:    cbz        r4, _PKT_0xa0_3
  00244:    nop
  00248:    b          _PKT_0xf0_117  
_PKT_0x0_4:
  0024c:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  00250:    ldd        r14, reg[r0, #0x6c]
  00254:    and        r14, r14, #0xffd30fff
  00258:    cbnz       r14, _PKT_0xf0_38
  0025c:    ldd        r10, reg[r0, #0x4af0]
  00260:    cbz        r10, _PKT_0xf0_11
  00264:    ldd        r6, reg[r0, #0x4a14]
  00268:    lsr        r3, r6, #12
  0026c:    and        r10, r3, #0xfffff201
  00270:    and        r3, r10, #0x2001
  00274:    cbz        r3, _PKT_0x0_5
  00278:    b          _PKT_0xf0_2  
  0027c:    nop
_PKT_0x0_5:
  00280:    std        r0, [r0, #0x99]
_PKT_0x0_6:
  00284:    hwop       r2, r1, #0x0
  00288:    b.28       PKT_0x0   ; r0, r0
  0028c:    stw        r0, [r0, #0x62]
  00290:    lsr        r3, r2, #16
  00294:    stw        r3, reg[r0, #0x5ac0]
  00298:    std        r1, [r0, #0x81]
_PKT_0x0_7:
  0029c:    stw        r3, [r0, #0x81]
  002a0:    stw        r0, [r0, #0x7e]
  002a4:    cbz        r2, _PKT_0x0_4
_PKT_0x0_8:
  002a8:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  002ac:    ldd        r3, reg[r0, #0x6c]
  002b0:    and        r3, r3, #0xffd30fff
  002b4:    cbnz       r3, _PKT_0xf0_38
  002b8:    ldd        r4, reg[r0, #0x5ac0]
  002bc:    cbnz       r4, _PKT_0x0_8
  002c0:    b          _PKT_0xf0_2  
_PKT_0x0_9:
  002c4:    ldd        r10, reg[r0, #0x4a14]

NOP:
  002c8:    and        r10, r10, #0xffffe003
  002cc:    cbz        r10, _PKT_0x0_9
  002d0:    ldd        r10, reg[r0, #0x4acc]
  002d4:    cbz        r10, _NOP_0
  002d8:    and        r10, r13, #0xfc007fff
  002dc:    cbnz       r10, _NOP_1
_NOP_0:
  002e0:    btab

_NOP_1:
  002e4:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  002e8:    ldd        r6, reg[r0, #0x4a14]
  002ec:    lsr        r10, r6, #25
  002f0:    and        r6, r10, #0xfffff001
  002f4:    cbz        r6, _NOP_1
  002f8:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  002fc:    std        r1, [r0, #0x7d]
  00300:    std        r0, [r0, #0xca]
  00304:    std        r0, [r0, #0xcb]
  00308:    nop
  0030c:    std        r0, [r0, #0x7d]
  00310:    mov        r2, #0xe5
  00314:    stw        r2, [r0, #0x50]
  00318:    std        r2, reg[r0, #0x4acc]
  0031c:    b          _PKT_0xf0_87  
  00320:    lsr        r10, r2, #31
  00324:    and        r14, r10, #0xfffff001
  00328:    cbz        r14, _NOP_2
  0032c:    b          _PKT_0x0_3  
  00330:    lsr        r10, r2, #30
  00334:    and        r14, r10, #0xfffff001
  00338:    cbz        r14, _NOP_2
  0033c:    lsr        r10, r2, #18
  00340:    and        r14, r10, #0xfffff001
  00344:    cbz        r14, _NOP_2
  00348:    ldd        r10, reg[r0, #0x4bcc]
  0034c:    lsr        r14, r10, #24
  00350:    orr        r10, r14, #0x2
  00354:    cbz        r10, _NOP_2
  00358:    ldd        r10, reg[r0, #0x5b04]
  0035c:    and        r14, r10, #0xffff800f
  00360:    cbnz       r14, _NOP_2
  00364:    mov        r10, #0x1
  00368:    btab

_NOP_2:
  0036c:    mov        r10, #0x0
  00370:    btab

  00374:    stw        r0, [r0, #0x77]
  00378:    std        r1, [r0, #0xf1]
  0037c:    stw        r0, [r0, #0x62]
  00380:    btab

  00384:    lsr        r4, r2, #31
  00388:    cbz        r4, _INDIRECT_BUFFER_END_0
  0038c:    b          _PKT_0x0_7  
  00390:    lsr        r4, r2, #30
  00394:    and        r4, r4, #0xfffff001
  00398:    cbz        r4, _INDIRECT_BUFFER_END_0
  0039c:    ldd        r3, reg[r0, #0x4bcc]

INDIRECT_BUFFER_END:
  003a0:    lsr        r4, r3, #24
  003a4:    orr        r3, r4, #0x2
  003a8:    lsr        r4, r2, #16
  003ac:    and        r4, r4, #0xfffff001
  003b0:    eor        r5, r4, r0
  003b4:    hwop       r3, r5, #0x6
  003b8:    cbz        r3, _INDIRECT_BUFFER_END_0
  003bc:    nop
  003c0:    std        r3, [r0, #0xee]
_INDIRECT_BUFFER_END_0:
  003c4:    btab

  003c8:    dw         0x840000a4  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa4
  003cc:    stw        r2, [r0, #0x0]
  003d0:    lsr        r10, r2, #18
  003d4:    and        r10, r10, #0xfffff001
  003d8:    lsr        r11, r2, #12
  003dc:    and        r11, r11, #0xfffff001
  003e0:    eor        r11, r11, r0
  003e4:    hwop       r10, r11, #0x6
  003e8:    lsr        r11, r2, #27
  003ec:    eor        r11, r11, r0
  003f0:    hwop       r10, r11, #0x6
  003f4:    stw        r10, reg[r0, #0x4acc]
  003f8:    nop
  003fc:    hwop       r13, r1, #0x0
  00400:    stw        r13, [r0, #0x1]
  00404:    add        r13, r13, #0x1
  00408:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  0040c:    stw        r1, [r0, #0xb]
  00410:    hwop       r13, r1, #0x0
  00414:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00418:    stw        r13, [r0, #0x2]
  0041c:    stw        r1, [r0, #0x3]
  00420:    hwop       r13, r1, #0x0
  00424:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00428:    stw        r13, [r0, #0x4]
  0042c:    stw        r1, [r0, #0x5]
  00430:    mov        r14, #0x7
  00434:    lsr        r4, r2, #27
  00438:    and        r4, r4, #0xfffff001
  0043c:    cbnz       r4, _INDIRECT_BUFFER_END_1
  00440:    and        r5, r4, #0xfff800ff
  00444:    cbnz       r5, _INDIRECT_BUFFER_END_2
  00448:    ldd        r6, reg[r0, #0x49f4]
  0044c:    lsr        r6, r6, #16
  00450:    and        r7, r6, #0xfffff001
  00454:    cbz        r7, _INDIRECT_BUFFER_END_2
  00458:    and        r8, r6, #0xffffe003
  0045c:    cbz        r8, _INDIRECT_BUFFER_END_2
  00460:    stw        r0, [r0, #0xc0]
  00464:    ldd        r6, [r0, #0xc9]
  00468:    cbz        r6, _INDIRECT_BUFFER_END_2
  0046c:    std        r1, [r0, #0xc1]
  00470:    b          _PKT_0xf0_0  
_INDIRECT_BUFFER_END_1:
  00474:    hwop       r13, r1, #0x0
  00478:    stw        r13, [r0, #0x15]
  0047c:    stw        r1, [r0, #0x16]
  00480:    add        r14, r14, #0x2
_INDIRECT_BUFFER_END_2:
  00484:    dw         0x8400008c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x8c
  00488:    cbnz       r10, _INDIRECT_BUFFER_END_3
  0048c:    stw        r0, [r0, #0xff]
_INDIRECT_BUFFER_END_3:
  00490:    stw        r14, [r0, #0x81]
  00494:    cbz        r10, _PKT_0xf0_8
  00498:    dw         0x8400009d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x9d
  0049c:    b          _PKT_0xf0_0  
  004a0:    mov        r9, #0xf884
  004a4:    lsl        r9, r9, #2
  004a8:    ldd        r6, reg[r9, #0x0]
  004ac:    lsr        r7, r6, #31
  004b0:    cbnz       r7, _PKT_0x18_4
  004b4:    ldd        r13, reg[r0, #0x4a14]
  004b8:    and        r14, r13, #0xfffff810
  004bc:    lsr        r13, r14, #9
  004c0:    eor        r6, r13, r0
  004c4:    ldd        r13, reg[r0, #0x5aa8]
  004c8:    lsr        r14, r13, #31
  004cc:    hwop       r6, r6, #0x7
  004d0:    lsl        r13, r6, #31
  004d4:    lsr        r6, r13, #31
  004d8:    cbz        r6, _PKT_0x18_4
  004dc:    stw        r2, [r0, #0x0]
  004e0:    stw        r2, [r0, #0xef]
  004e4:    hwop       r8, r1, #0x0
  004e8:    stw        r8, [r0, #0x1]
  004ec:    hwop       r3, r1, #0x0
  004f0:    stw        r3, [r0, #0xb]
  004f4:    lsr        r4, r3, #23
  004f8:    and        r4, r4, #0xfffff001
  004fc:    hwop       r5, r6, #0x6
  00500:    cbz        r5, _INDIRECT_BUFFER_END_4
  00504:    nop
_INDIRECT_BUFFER_END_4:
  00508:    lsr        r4, r3, #31
  0050c:    and        r4, r4, #0xfffff001
  00510:    hwop       r5, r6, #0x6
  00514:    cbz        r5, _INDIRECT_BUFFER_END_5
  00518:    nop
_INDIRECT_BUFFER_END_5:
  0051c:    hwop       r3, r1, #0x0
  00520:    hwop       r4, r1, #0x0
  00524:    stw        r3, [r0, #0x2]
  00528:    stw        r4, [r0, #0x3]
  0052c:    stw        r1, [r0, #0x4]
  00530:    stw        r1, [r0, #0x5]
  00534:    and        r5, r3, #0xffffffff
  00538:    hwop       r5, r8, #0x0
  0053c:    ldd        r6, reg[r0, #0x4a20]
  00540:    and        r7, r6, #0xffffc007
  00544:    add        r7, r7, #0x10
  00548:    lsl        r8, r5, r7
  0054c:    sub        r9, r7, #0xc
  00550:    mov        r10, #0x1
  00554:    hwop       r7, r10, #0x3
  00558:    lsld       r6, r4, #32
  0055c:    hwop       r5, r6, #0x20
  00560:    lsrd       r6, r5, #12
  00564:    lsr        r5, r6, #4
  00568:    lsl        r6, r5, #4
  0056c:    stw        r0, [r0, #0xff]
  00570:    stw        r0, [r0, #0xd5]
  00574:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
_INDIRECT_BUFFER_END_6:
  00578:    std        r3, [r0, #0xd3]
  0057c:    ldd        r9, reg[r0, #0x14c]
  00580:    lsld       r10, r9, #2
  00584:    ldd        r13, unk[r10, #0x0]
  00588:    nop
  0058c:    and        r10, r13, #0xfffff001
  00590:    cbz        r10, _INDIRECT_BUFFER_END_6
_INDIRECT_BUFFER_END_7:
  00594:    ldd        r9, reg[r0, #0x144]
  00598:    lsld       r10, r9, #2
  0059c:    ldd        r12, unk[r10, #0x0]
  005a0:    nop
  005a4:    and        r11, r12, #0xfffff001
  005a8:    cbz        r11, _INDIRECT_BUFFER_END_7
_INDIRECT_BUFFER_END_8:
  005ac:    dw         0x8400016c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x16c
  005b0:    ldd        r9, reg[r0, #0x148]
  005b4:    stw        r9, [r0, #0x5b]
  005b8:    ldd        r10, reg[r0, #0x4a80]
  005bc:    and        r10, r10, #0xfffc007f
  005c0:    cbnz       r10, _INDIRECT_BUFFER_END_8
  005c4:    stw        r3, [r0, #0x5c]
  005c8:    dw         0x84000159  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x159
_INDIRECT_BUFFER_END_9:
  005cc:    dw         0x8400016c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x16c
  005d0:    ldd        r9, reg[r0, #0x140]
  005d4:    stw        r9, [r0, #0x5b]
  005d8:    ldd        r10, reg[r0, #0x4a80]
  005dc:    and        r10, r10, #0xfffc007f
  005e0:    cbnz       r10, _INDIRECT_BUFFER_END_9
  005e4:    stw        r3, [r0, #0x5c]
  005e8:    dw         0x84000159  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x159
_INDIRECT_BUFFER_END_10:
  005ec:    std        r3, [r0, #0xd3]

PKT_0x18:
  005f0:    ldd        r9, reg[r0, #0x14c]
  005f4:    lsld       r10, r9, #2
  005f8:    ldd        r13, unk[r10, #0x0]
  005fc:    nop
  00600:    and        r10, r13, #0xfffff001
  00604:    cbz        r10, _INDIRECT_BUFFER_END_10
  00608:    mov        r12, #0x0
_PKT_0x18_0:
  0060c:    ldd        r9, reg[r0, #0x144]
  00610:    lsl        r10, r9, #2
  00614:    ldd        r11, unk[r10, #0x0]
  00618:    nop
  0061c:    and        r10, r11, #0xfffff001
  00620:    cbz        r10, _PKT_0x18_0
  00624:    std        r1, [r0, #0xf3]
  00628:    std        r0, [r0, #0xf3]
  0062c:    hwop       r12, r13, #0x7
  00630:    hwop       r11, r12, #0x7
  00634:    stw        r11, [r0, #0xe2]
  00638:    cbz        r8, _PKT_0x18_2
  0063c:    hwop       r6, r6, #0x20
_PKT_0x18_1:
  00640:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  00644:    ldd        r13, [r0, #0xe3]
  00648:    nop
  0064c:    cbnz       r13, _PKT_0x18_1
  00650:    nop
  00654:    sub        r8, r8, #0x1
  00658:    b          _INDIRECT_BUFFER_END_1  
_PKT_0x18_2:
  0065c:    std        r7, [r0, #0x81]
  00660:    b          _PKT_0xf0_0  
  00664:    nop
  00668:    nop
  0066c:    nop
_PKT_0x18_3:
  00670:    ldd        r9, reg[r0, #0x4a14]
  00674:    lsr        r10, r9, #14
  00678:    and        r9, r10, #0xfffff001
  0067c:    cbz        r9, _PKT_0x18_3
  00680:    btab

_PKT_0x18_4:
  00684:    hwop       r2, r1, #0x0
  00688:    hwop       r2, r1, #0x0
  0068c:    hwop       r2, r1, #0x0
  00690:    hwop       r2, r1, #0x0
  00694:    hwop       r2, r1, #0x0
  00698:    hwop       r2, r1, #0x0
  0069c:    std        r7, [r0, #0x81]
  006a0:    mov        r9, #0x7
  006a4:    lsl        r9, r9, #2
  006a8:    dw         0x840001e4  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1e4
  006ac:    b          _PKT_0xf0_0  
  006b0:    lsr        r10, r6, #4
  006b4:    lsl        r14, r10, #4
  006b8:    lsld       r9, r14, #12
  006bc:    add        r10, r9, #0x0
  006c0:    lsrd       r14, r9, #32
  006c4:    std        r1, [r0, #0xbe]
  006c8:    stw        r10, [r0, #0xb9]
  006cc:    stw        r14, [r0, #0xba]
  006d0:    ldd        r10, [r0, #0xbb]
  006d4:    ldd        r14, [r0, #0xbf]
  006d8:    lsld       r9, r14, #32
  006dc:    hwop       r9, r9, #0x20
  006e0:    lsrd       r10, r9, #16
  006e4:    lsld       r14, r10, #4
  006e8:    add        r3, r14, #0x1
_PKT_0x18_5:
  006ec:    btab

  006f0:    mov        r9, #0xf884
  006f4:    lsl        r9, r9, #2
  006f8:    ldd        r6, reg[r9, #0x0]
  006fc:    lsr        r7, r6, #31
  00700:    ldd        r13, reg[r0, #0x4a14]
  00704:    and        r14, r13, #0xfffff810
  00708:    lsr        r13, r14, #9
  0070c:    cbz        r13, _PKT_0x18_6
  00710:    ldd        r10, reg[r0, #0x5ab0]
  00714:    nop
  00718:    stw        r10, reg[r0, #0x5ba8]
  0071c:    b          _PKT_0x18_1  
_PKT_0x18_6:
  00720:    ldd        r10, reg[r0, #0x5a8c]
  00724:    nop
  00728:    stw        r10, reg[r0, #0x5ba8]
  0072c:    nop
  00730:    ldd        r10, reg[r0, #0x5a90]
  00734:    nop
  00738:    stw        r10, reg[r0, #0x5bac]
  0073c:    nop
  00740:    eor        r6, r13, r0
  00744:    ldd        r13, reg[r0, #0x5aa8]
  00748:    lsr        r14, r13, #31
  0074c:    hwop       r6, r6, #0x7
_PKT_0x18_7:
  00750:    lsl        r13, r6, #31
  00754:    lsr        r6, r13, #31
  00758:    stw        r2, [r0, #0x0]
  0075c:    hwop       r3, r1, #0x0
  00760:    lsr        r13, r3, #24
  00764:    lsl        r14, r3, #8
  00768:    lsr        r3, r14, #8
  0076c:    stw        r3, [r0, #0x1]
  00770:    hwop       r3, r1, #0x0
  00774:    cbz        r6, _PKT_0x18_11
  00778:    lsr        r14, r3, #20
  0077c:    and        r14, r14, #0xfffff001
  00780:    eor        r14, r14, r0
  00784:    lsr        r12, r3, #23
  00788:    and        r12, r12, #0xfffff001
  0078c:    hwop       r12, r14, #0x6
  00790:    hwop       r12, r12, #0x6
  00794:    cbnz       r12, _PKT_0x18_11
  00798:    lsr        r14, r3, #28
  0079c:    and        r14, r14, #0xfffff001
  007a0:    eor        r14, r14, r0
  007a4:    lsr        r12, r3, #31
  007a8:    and        r12, r12, #0xfffff001
  007ac:    hwop       r12, r14, #0x6
  007b0:    hwop       r12, r12, #0x6
  007b4:    cbnz       r12, _PKT_0x18_11
  007b8:    stw        r3, [r0, #0xb]
  007bc:    mov        r14, #0x7
  007c0:    stw        r14, [r0, #0x81]
  007c4:    lsr        r4, r3, #23
  007c8:    and        r4, r4, #0xfffff001
  007cc:    hwop       r5, r6, #0x6
  007d0:    cbz        r5, _PKT_0x18_8
  007d4:    nop
_PKT_0x18_8:
  007d8:    lsr        r4, r3, #31
  007dc:    and        r4, r4, #0xfffff001
  007e0:    hwop       r5, r6, #0x6
  007e4:    cbz        r5, _PKT_0x18_9
  007e8:    nop
_PKT_0x18_9:
  007ec:    stw        r1, [r0, #0x2]
  007f0:    stw        r1, [r0, #0x3]
  007f4:    stw        r1, [r0, #0x4]
  007f8:    stw        r1, [r0, #0x5]
  007fc:    stw        r0, [r0, #0xff]
  00800:    std        r0, [r0, #0xfd]
  00804:    nop
  00808:    sub        r13, r13, #0x1
_PKT_0x18_10:
  0080c:    dw         0x840001f7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1f7
  00810:    ldd        r6, reg[r0, #0x4a14]
  00814:    nop
  00818:    lsr        r3, r6, #25
  0081c:    and        r4, r3, #0xfffff001
  00820:    cbz        r4, _PKT_0x18_10
  00824:    nop
  00828:    std        r4, [r0, #0x81]
  0082c:    add        r13, r13, #0x1
  00830:    cbz        r13, _PKT_0xf0_11
  00834:    sub        r13, r13, #0x1
  00838:    b          _PKT_0x18_5  
  0083c:    nop
  00840:    hwop       r2, r1, #0x0
  00844:    hwop       r2, r1, #0x0
_PKT_0x18_11:
  00848:    add        r14, r13, #0x0
  0084c:    lsl        r14, r14, #4
  00850:    hwop       r2, r1, #0x0
  00854:    hwop       r2, r1, #0x0
  00858:    hwop       r2, r1, #0x0
  0085c:    hwop       r2, r1, #0x0
  00860:    cbz        r13, _PKT_0x18_12
  00864:    nop
  00868:    sub        r13, r13, #0x1
  0086c:    std        r4, [r0, #0x81]
  00870:    b          _PKT_0x18_7  
  00874:    nop
_PKT_0x18_12:
  00878:    std        r7, [r0, #0x81]
  0087c:    mov        r9, #0x7
  00880:    lsl        r9, r9, #2
  00884:    hwop       r9, r14, #0x0
  00888:    dw         0x840001e4  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1e4
  0088c:    b          _PKT_0xf0_0  
  00890:    std        r1, [r0, #0xf1]
  00894:    ldd        r6, reg[r0, #0x4a14]
  00898:    and        r10, r6, #0xfffff810
  0089c:    cbnz       r10, _PKT_0x18_13
  008a0:    ldd        r6, reg[r0, #0x5a8c]
  008a4:    nop
  008a8:    ldd        r7, reg[r0, #0x5a90]
  008ac:    nop
  008b0:    lsld       r5, r7, #32
  008b4:    hwop       r7, r5, #0x20
  008b8:    hwop       r5, r7, #0x20
  008bc:    stw        r5, reg[r0, #0x5a8c]
  008c0:    lsrd       r7, r5, #32
  008c4:    stw        r7, reg[r0, #0x5a90]
  008c8:    btab

_PKT_0x18_13:
  008cc:    ldd        r6, reg[r0, #0x5ab0]
  008d0:    hwop       r7, r6, #0x0
_PKT_0x18_14:
  008d4:    stw        r7, reg[r0, #0x5ab0]
  008d8:    btab

  008dc:    ldd        r15, reg[r0, #0x6c]
  008e0:    and        r15, r15, #0xffd30fff
  008e4:    cbnz       r15, SET_BASE
  008e8:    btab


SET_BASE:
  008ec:    ldd        r13, reg[r0, #0x4a14]
  008f0:    and        r14, r13, #0xfffff810
  008f4:    lsr        r13, r14, #9
  008f8:    cbz        r13, _SET_BASE_0
  008fc:    ldd        r10, reg[r0, #0x5ba8]
  00900:    nop
  00904:    stw        r10, reg[r0, #0x5ab0]
  00908:    std        r0, reg[r0, #0x5ba8]
  0090c:    b          _PKT_0xf0_28  
_SET_BASE_0:
  00910:    ldd        r10, reg[r0, #0x5ba8]
  00914:    nop
  00918:    stw        r10, reg[r0, #0x5a8c]
  0091c:    nop
  00920:    ldd        r10, reg[r0, #0x5bac]
  00924:    nop
  00928:    stw        r10, reg[r0, #0x5a90]
  0092c:    std        r0, reg[r0, #0x5ba8]
  00930:    std        r0, reg[r0, #0x5bac]
  00934:    b          _PKT_0xf0_28  
  00938:    lsr        r13, r3, #3
  0093c:    and        r13, r13, #0x7fffffff
  00940:    setne      r15, r13, #0x3
  00944:    cbz        r15, _SET_BASE_1
  00948:    mov        r13, #0x100
  0094c:    lsl        r13, r13, r12
  00950:    b          _PKT_0x18_14  
_SET_BASE_1:
  00954:    setne      r15, r13, #0x7
  00958:    cbz        r15, _SET_BASE_2
  0095c:    mov        r13, #0x1000
  00960:    lsl        r13, r13, r12
  00964:    b          _PKT_0x18_14  
_SET_BASE_2:
  00968:    setne      r15, r13, #0xb
  0096c:    cbz        r15, _SET_BASE_3
  00970:    mov        r13, #0x1
  00974:    lsl        r13, r13, #16
  00978:    lsl        r13, r13, r12
  0097c:    b          _PKT_0x18_14  
_SET_BASE_3:
  00980:    setne      r15, r13, #0xf
  00984:    cbz        r15, _SET_BASE_4
  00988:    btab

_SET_BASE_4:
  0098c:    setne      r15, r13, #0x13
  00990:    cbz        r15, _SET_BASE_5
  00994:    mov        r13, #0x1
  00998:    lsl        r13, r13, #16
  0099c:    lsl        r13, r13, r12
  009a0:    b          _PKT_0x18_14  
_SET_BASE_5:
  009a4:    setne      r15, r13, #0x17
  009a8:    cbz        r15, _SET_BASE_6
  009ac:    mov        r13, #0x1000
  009b0:    lsl        r13, r13, r12
  009b4:    b          _PKT_0x18_14  
_SET_BASE_6:
  009b8:    setne      r15, r13, #0x1b
  009bc:    cbz        r15, _SET_BASE_7
  009c0:    mov        r13, #0x1
  009c4:    lsl        r13, r13, #16
  009c8:    lsl        r13, r13, r12
  009cc:    b          _PKT_0x18_14  
_SET_BASE_7:
  009d0:    btab

  009d4:    lsr        r13, r13, #1
  009d8:    setgt      r15, r11, r13
  009dc:    cbz        r15, _SET_BASE_8
  009e0:    nop
  009e4:    std        r1, reg[r0, #0x5ba8]
_SET_BASE_8:
  009e8:    btab

  009ec:    dw         0x840000a4  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa4
  009f0:    stw        r2, [r0, #0x0]
  009f4:    lsr        r10, r2, #18
  009f8:    and        r10, r10, #0xfffff001
  009fc:    lsr        r11, r2, #12
  00a00:    and        r11, r11, #0xfffff001
  00a04:    eor        r11, r11, r0
  00a08:    hwop       r10, r11, #0x6
  00a0c:    lsr        r11, r2, #27
  00a10:    eor        r11, r11, r0
  00a14:    hwop       r10, r11, #0x6
  00a18:    lsr        r11, r2, #26
  00a1c:    and        r11, r11, #0xfffff001
  00a20:    eor        r11, r11, r0
  00a24:    hwop       r10, r11, #0x6
  00a28:    stw        r10, reg[r0, #0x4acc]
  00a2c:    nop
  00a30:    stw        r1, [r0, #0x4]
  00a34:    stw        r1, [r0, #0x5]
  00a38:    mov        r14, #0xd
  00a3c:    lsr        r4, r2, #26
  00a40:    and        r4, r4, #0xffffc007
  00a44:    cbz        r4, _SET_BASE_9
  00a48:    stw        r1, [r0, #0x15]
  00a4c:    stw        r1, [r0, #0x16]
  00a50:    add        r14, r14, #0x3
_SET_BASE_9:
  00a54:    hwop       r13, r1, #0x0
  00a58:    stw        r13, [r0, #0x6]
  00a5c:    add        r13, r13, #0x1
  00a60:    hwop       r12, r1, #0x0
  00a64:    stw        r12, [r0, #0x7]
  00a68:    and        r12, r12, #0xffffffff
  00a6c:    add        r12, r12, #0x1
  00a70:    subd       r11, r12, r13
  00a74:    hwop       r3, r1, #0x0
  00a78:    stw        r3, [r0, #0x8]
  00a7c:    and        r12, r3, #0xfffc007f
  00a80:    dw         0x8400020e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x20e
  00a84:    stw        r11, [r0, #0x18]
  00a88:    hwop       r3, r1, #0x0
  00a8c:    stw        r3, [r0, #0x9]
  00a90:    and        r7, r3, #0xffffffff
  00a94:    lsr        r6, r3, #16
  00a98:    hwop       r13, r7, #0x23
  00a9c:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00aa0:    hwop       r3, r1, #0x0
  00aa4:    and        r12, r3, #0xffffffff
  00aa8:    stw        r3, [r0, #0xa]
  00aac:    cbz        r4, _SET_BASE_10
  00ab0:    hwop       r3, r1, #0x0
_SET_BASE_10:
  00ab4:    stw        r3, [r0, #0xb]
  00ab8:    hwop       r3, r1, #0x0
  00abc:    lsld       r5, r1, #32
  00ac0:    hwop       r3, r5, #0x20
  00ac4:    hwop       r5, r1, #0x0
  00ac8:    stw        r5, [r0, #0x10]
  00acc:    addd       r11, r5, #0x1
  00ad0:    subd       r8, r11, r6
  00ad4:    hwop       r9, r8, #0x20
  00ad8:    hwop       r7, r1, #0x0
  00adc:    stw        r7, [r0, #0xd]
  00ae0:    addd       r6, r7, #0x1
  00ae4:    subd       r7, r12, r6
  00ae8:    hwop       r8, r7, #0x20
  00aec:    hwop       r13, r8, #0x20
  00af0:    stw        r13, [r0, #0x2]
  00af4:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00af8:    lsrd       r13, r13, #32
  00afc:    stw        r13, [r0, #0x3]
  00b00:    hwop       r13, r1, #0x0
  00b04:    stw        r13, [r0, #0x1]
  00b08:    add        r13, r13, #0x1
  00b0c:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00b10:    cbnz       r4, _SET_BASE_11
  00b14:    and        r5, r4, #0xf800ffff
  00b18:    cbnz       r5, _SET_BASE_11
  00b1c:    ldd        r6, reg[r0, #0x49f4]
  00b20:    lsr        r6, r6, #16
  00b24:    and        r7, r6, #0xfffff001
  00b28:    cbz        r7, _SET_BASE_11
  00b2c:    and        r8, r6, #0xffffe003
  00b30:    cbz        r8, _SET_BASE_11
  00b34:    stw        r0, [r0, #0xc0]
  00b38:    ldd        r6, [r0, #0xc9]
  00b3c:    cbz        r6, _SET_BASE_11
  00b40:    std        r4, [r0, #0xc1]
  00b44:    b          _PKT_0xf0_0  
_SET_BASE_11:
  00b48:    dw         0x8400008c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x8c
  00b4c:    cbnz       r10, _SET_BASE_12
  00b50:    stw        r0, [r0, #0xff]
_SET_BASE_12:
  00b54:    stw        r14, [r0, #0x81]
  00b58:    cbz        r10, _PKT_0xf0_8
  00b5c:    dw         0x8400009d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x9d
  00b60:    b          _PKT_0xf0_0  
  00b64:    stw        r2, [r0, #0x0]
  00b68:    stw        r1, [r0, #0x4]
  00b6c:    stw        r1, [r0, #0x5]
  00b70:    mov        r14, #0xd
  00b74:    lsr        r4, r2, #26

INDEX_BUFFER_SIZE:
  00b78:    and        r4, r4, #0xffffc007
  00b7c:    cbz        r4, _INDEX_BUFFER_SIZE_0
  00b80:    stw        r1, [r0, #0x15]
  00b84:    stw        r1, [r0, #0x16]
  00b88:    add        r14, r14, #0x3
_INDEX_BUFFER_SIZE_0:
  00b8c:    hwop       r13, r1, #0x0
  00b90:    stw        r13, [r0, #0x6]
  00b94:    add        r13, r13, #0x1
  00b98:    hwop       r12, r1, #0x0
  00b9c:    stw        r12, [r0, #0x7]
  00ba0:    and        r12, r12, #0xffffffff
  00ba4:    add        r12, r12, #0x1
  00ba8:    subd       r11, r12, r13
  00bac:    stw        r11, [r0, #0x18]
  00bb0:    hwop       r3, r1, #0x0
  00bb4:    stw        r3, [r0, #0x8]
  00bb8:    and        r12, r3, #0xfffc007f
  00bbc:    dw         0x8400020e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x20e
  00bc0:    hwop       r3, r1, #0x0
  00bc4:    stw        r3, [r0, #0x9]
  00bc8:    and        r7, r3, #0xffffffff
  00bcc:    lsr        r6, r3, #16
  00bd0:    hwop       r13, r7, #0x23
  00bd4:    hwop       r3, r1, #0x0
  00bd8:    and        r12, r3, #0xffffffff
  00bdc:    stw        r3, [r0, #0xa]
  00be0:    cbz        r4, _INDEX_BUFFER_SIZE_1
  00be4:    hwop       r3, r1, #0x0
_INDEX_BUFFER_SIZE_1:
  00be8:    stw        r3, [r0, #0xb]
  00bec:    hwop       r3, r1, #0x0
  00bf0:    lsld       r5, r1, #32
  00bf4:    hwop       r3, r5, #0x20
  00bf8:    hwop       r5, r1, #0x0
  00bfc:    stw        r5, [r0, #0x10]
  00c00:    addd       r11, r5, #0x1
  00c04:    subd       r8, r11, r6
  00c08:    hwop       r9, r8, #0x20

PKT_0x14:
  00c0c:    hwop       r7, r1, #0x0
  00c10:    stw        r7, [r0, #0xd]
  00c14:    addd       r6, r7, #0x1
  00c18:    subd       r7, r12, r6
  00c1c:    hwop       r8, r7, #0x20
  00c20:    hwop       r10, r8, #0x20
  00c24:    stw        r10, [r0, #0x2]
  00c28:    lsrd       r10, r10, #32
  00c2c:    stw        r10, [r0, #0x3]
  00c30:    stw        r1, [r0, #0x1]
  00c34:    cbnz       r4, _SET_BASE_11
  00c38:    and        r5, r4, #0xf800ffff
  00c3c:    cbnz       r5, _SET_BASE_11
  00c40:    ldd        r6, reg[r0, #0x49f4]
  00c44:    lsr        r6, r6, #16
  00c48:    and        r7, r6, #0xfffff001
  00c4c:    cbz        r7, _SET_BASE_11
  00c50:    and        r8, r6, #0xffffe003
  00c54:    cbz        r8, _SET_BASE_11
  00c58:    stw        r0, [r0, #0xc0]
  00c5c:    ldd        r6, [r0, #0xc9]
  00c60:    cbz        r6, _PKT_0x14_0
  00c64:    std        r4, [r0, #0xc1]
  00c68:    b          _PKT_0xf0_0  
_PKT_0x14_0:
  00c6c:    stw        r0, [r0, #0xff]
  00c70:    stw        r14, [r0, #0x81]
  00c74:    b          _PKT_0xf0_0  
  00c78:    stw        r2, [r0, #0x0]
  00c7c:    hwop       r3, r1, #0x0

PKT_0x8a31:
  00c80:    and        r7, r3, #0xfffffff
  00c84:    cbz        r7, _PKT_0x8a31_0
  00c88:    stw        r0, [r0, #0x66]
_PKT_0x8a31_0:
  00c8c:    lsld       r4, r1, #32
  00c90:    hwop       r5, r4, #0x20
  00c94:    hwop       r3, r1, #0x0
  00c98:    stw        r3, [r0, #0x13]
  00c9c:    lsr        r6, r3, #4
  00ca0:    lsl        r6, r6, #4
  00ca4:    and        r7, r3, #0xfc007fff
  00ca8:    stw        r1, [r0, #0x1]
  00cac:    hwop       r4, r1, #0x0
  00cb0:    add        r4, r4, #0x1
  00cb4:    stw        r4, [r0, #0xa]
  00cb8:    stw        r4, [r0, #0xb]
  00cbc:    and        r4, r4, #0xffffffff
  00cc0:    hwop       r8, r1, #0x0
  00cc4:    lsld       r9, r1, #32
  00cc8:    hwop       r10, r9, #0x20
  00ccc:    subd       r11, r4, r6
  00cd0:    hwop       r12, r11, #0x20
  00cd4:    lsl        r12, r12, #2
  00cd8:    hwop       r13, r12, #0x20
  00cdc:    stw        r13, [r0, #0x4]
  00ce0:    lsrd       r13, r13, #32
  00ce4:    stw        r13, [r0, #0x5]
  00ce8:    subd       r11, r4, r3
  00cec:    lsl        r14, r11, #2
  00cf0:    hwop       r12, r14, #0x20
  00cf4:    stw        r12, [r0, #0x2]
  00cf8:    lsrd       r12, r12, #32
  00cfc:    stw        r12, [r0, #0x3]
  00d00:    stw        r0, [r0, #0xff]
  00d04:    std        r8, [r0, #0x81]
  00d08:    b          _PKT_0xf0_0  
  00d0c:    stw        r2, [r0, #0x0]
  00d10:    lsr        r10, r2, #18
  00d14:    and        r10, r10, #0xfffff001
  00d18:    lsr        r11, r2, #12
  00d1c:    and        r11, r11, #0xfffff001
  00d20:    eor        r11, r11, r0
  00d24:    hwop       r10, r11, #0x6
  00d28:    stw        r10, reg[r0, #0x4acc]
  00d2c:    nop
  00d30:    lsr        r9, r2, #29
  00d34:    hwop       r3, r1, #0x0
  00d38:    lsld       r4, r1, #32
  00d3c:    hwop       r13, r4, #0x20
  00d40:    hwop       r3, r1, #0x0
  00d44:    stw        r3, [r0, #0x9]
  00d48:    and        r7, r3, #0xffffffff
  00d4c:    lsr        r6, r3, #16
  00d50:    hwop       r3, r1, #0x0
  00d54:    stw        r3, [r0, #0xa]
  00d58:    and        r5, r3, #0xffffffff
  00d5c:    lsr        r4, r3, #13
  00d60:    add        r10, r4, #0x1
  00d64:    hwop       r8, r13, #0x20
  00d68:    hwop       r11, r10, #0x20
  00d6c:    hwop       r13, r10, #0x23
  00d70:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00d74:    hwop       r13, r8, #0x20
  00d78:    hwop       r10, r11, #0x20
  00d7c:    subd       r8, r6, r10
  00d80:    hwop       r11, r1, #0x0
  00d84:    stw        r11, [r0, #0x7]
  00d88:    stw        r11, [r0, #0x18]
  00d8c:    addd       r14, r11, #0x1

DISPATCH_DIRECT:
  00d90:    subd       r12, r5, r14
  00d94:    hwop       r4, r8, #0x20
  00d98:    hwop       r5, r7, #0x20
  00d9c:    hwop       r6, r5, #0x23
  00da0:    hwop       r13, r6, #0x20
  00da4:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00da8:    stw        r13, [r0, #0x2]
  00dac:    lsrd       r13, r13, #32
  00db0:    stw        r13, [r0, #0x3]
  00db4:    hwop       r3, r1, #0x0
  00db8:    lsld       r4, r1, #32
  00dbc:    hwop       r13, r4, #0x20
  00dc0:    hwop       r3, r1, #0x0
  00dc4:    stw        r3, [r0, #0xf]
  00dc8:    and        r7, r3, #0xffffffff
  00dcc:    lsr        r6, r3, #16
  00dd0:    hwop       r3, r1, #0x0
  00dd4:    stw        r3, [r0, #0x10]
  00dd8:    and        r5, r3, #0xffffffff
  00ddc:    lsr        r4, r3, #13
  00de0:    add        r4, r4, #0x1
  00de4:    hwop       r8, r13, #0x20
  00de8:    hwop       r11, r10, #0x20
  00dec:    hwop       r13, r4, #0x23
  00df0:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00df4:    hwop       r13, r8, #0x20
  00df8:    hwop       r10, r11, #0x20
  00dfc:    subd       r8, r6, r4
  00e00:    hwop       r11, r1, #0x0
  00e04:    stw        r11, [r0, #0xd]
  00e08:    stw        r11, [r0, #0x19]
  00e0c:    addd       r11, r11, #0x1
  00e10:    subd       r12, r5, r11
  00e14:    hwop       r6, r8, #0x20
  00e18:    hwop       r5, r7, #0x20
  00e1c:    hwop       r8, r5, #0x23
  00e20:    hwop       r13, r8, #0x20
  00e24:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00e28:    stw        r13, [r0, #0x4]
  00e2c:    lsrd       r13, r13, #32
  00e30:    stw        r13, [r0, #0x5]
  00e34:    hwop       r3, r1, #0x0
  00e38:    stw        r3, [r0, #0x11]
  00e3c:    and        r13, r3, #0xffffffff
  00e40:    add        r13, r13, #0x1
  00e44:    hwop       r13, r13, #0x23
  00e48:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00e4c:    hwop       r5, r1, #0x0
  00e50:    stw        r5, [r0, #0x12]
  00e54:    stw        r5, [r0, #0xb]
  00e58:    ldd        r6, reg[r0, #0x49f4]
  00e5c:    lsr        r6, r6, #16
  00e60:    and        r7, r6, #0xfffff001
  00e64:    cbz        r7, _DISPATCH_DIRECT_0
  00e68:    and        r8, r6, #0xffffe003
  00e6c:    cbz        r8, _DISPATCH_DIRECT_0
  00e70:    stw        r0, [r0, #0xc0]
  00e74:    ldd        r6, [r0, #0xc9]
  00e78:    cbz        r6, _DISPATCH_DIRECT_0
  00e7c:    std        r2, [r0, #0xc1]
  00e80:    b          _PKT_0xf0_0  
_DISPATCH_DIRECT_0:
  00e84:    stw        r0, [r0, #0xff]
  00e88:    std        r13, [r0, #0x81]
  00e8c:    b          _PKT_0xf0_0  
  00e90:    stw        r2, [r0, #0x0]
  00e94:    lsr        r10, r2, #18
  00e98:    and        r10, r10, #0xfffff001
  00e9c:    lsr        r11, r2, #12
  00ea0:    and        r11, r11, #0xfffff001
  00ea4:    eor        r11, r11, r0
  00ea8:    hwop       r10, r11, #0x6
  00eac:    stw        r10, reg[r0, #0x4acc]
  00eb0:    nop
  00eb4:    stw        r1, [r0, #0x4]
  00eb8:    stw        r1, [r0, #0x5]
  00ebc:    hwop       r3, r1, #0x0
  00ec0:    stw        r3, [r0, #0x9]
  00ec4:    and        r7, r3, #0xffffffff
  00ec8:    lsr        r6, r3, #16
  00ecc:    hwop       r3, r1, #0x0
  00ed0:    and        r8, r3, #0xffffffff
  00ed4:    stw        r8, [r0, #0xa]
  00ed8:    lsr        r3, r3, #16
  00edc:    and        r4, r3, #0xffffffff
  00ee0:    stw        r4, [r0, #0x6]
  00ee4:    add        r13, r4, #0x1
  00ee8:    hwop       r12, r1, #0x0
  00eec:    stw        r12, [r0, #0x7]
_DISPATCH_DIRECT_1:
  00ef0:    and        r12, r12, #0xffffffff
  00ef4:    add        r12, r12, #0x1
  00ef8:    subd       r11, r12, r13
  00efc:    hwop       r3, r1, #0x0
  00f00:    stw        r3, [r0, #0x8]
  00f04:    and        r9, r3, #0xfffc007f
  00f08:    hwop       r12, r9, #0x0
  00f0c:    dw         0x8400020e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x20e
  00f10:    stw        r11, [r0, #0x18]
  00f14:    hwop       r13, r7, #0x23
  00f18:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  00f1c:    lsr        r14, r2, #31
  00f20:    cbz        r14, _DISPATCH_DIRECT_7
  00f24:    lsr        r14, r2, #12
  00f28:    and        r14, r14, #0xfffff001
  00f2c:    cbnz       r14, _DISPATCH_DIRECT_7
  00f30:    ldd        r14, reg[r0, #0x49f4]
  00f34:    lsr        r14, r14, #18
  00f38:    and        r14, r14, #0xfffff001
  00f3c:    lsr        r11, r2, #19
  00f40:    and        r11, r11, #0xfffff001
  00f44:    hwop       r14, r14, #0x7
  00f48:    cbz        r14, _DISPATCH_DIRECT_7
  00f4c:    lsr        r5, r3, #3
  00f50:    and        r11, r5, #0xffffc007
  00f54:    lsr        r5, r5, #7
  00f58:    and        r12, r5, #0xfffff001
  00f5c:    cbz        r12, _DISPATCH_DIRECT_6
  00f60:    and        r14, r11, #0x2
  00f64:    hwop       r11, r0, #0x0
  00f68:    cbnz       r11, _DISPATCH_DIRECT_2
  00f6c:    mov        r14, #0x7
  00f70:    mov        r15, #0x3
  00f74:    mov        r12, #0x7
  00f78:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_2:
  00f7c:    sub        r11, r11, #0x1
  00f80:    cbnz       r11, _DISPATCH_DIRECT_3
  00f84:    mov        r14, #0x3
  00f88:    mov        r15, #0x3
  00f8c:    mov        r12, #0x7
  00f90:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_3:
  00f94:    sub        r11, r11, #0x1
  00f98:    cbnz       r11, _DISPATCH_DIRECT_4
  00f9c:    mov        r14, #0x3
  00fa0:    mov        r15, #0x3
  00fa4:    mov        r12, #0x3
  00fa8:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_4:
  00fac:    sub        r11, r11, #0x1
  00fb0:    cbnz       r11, _DISPATCH_DIRECT_5
  00fb4:    mov        r14, #0x3
  00fb8:    mov        r15, #0x1
  00fbc:    mov        r12, #0x3
  00fc0:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_5:
  00fc4:    mov        r14, #0x1
  00fc8:    mov        r15, #0x1
  00fcc:    mov        r12, #0x3
  00fd0:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_6:
  00fd4:    lsr        r3, r9, #1
  00fd8:    and        r4, r9, #0xfffff001
  00fdc:    hwop       r4, r3, #0x0
  00fe0:    mov        r5, #0xf
  00fe4:    lsl        r14, r5, r3
  00fe8:    lsl        r15, r5, r4
  00fec:    mov        r12, #0x0
  00ff0:    hwop       r14, r7, #0x6
  00ff4:    hwop       r15, r6, #0x6
  00ff8:    hwop       r12, r8, #0x6
_DISPATCH_DIRECT_7:
  00ffc:    hwop       r3, r1, #0x0
  01000:    lsld       r4, r1, #32
  01004:    hwop       r13, r4, #0x20
  01008:    hwop       r3, r1, #0x0
  0100c:    stw        r3, [r0, #0xf]
  01010:    and        r7, r3, #0xffffffff
  01014:    lsr        r6, r3, #16
  01018:    hwop       r3, r1, #0x0
  0101c:    stw        r3, [r0, #0x10]
  01020:    and        r8, r3, #0xffffffff
  01024:    lsr        r10, r3, #16
  01028:    add        r10, r10, #0x1
  0102c:    hwop       r11, r13, #0x20
  01030:    hwop       r4, r10, #0x20
  01034:    hwop       r13, r10, #0x23
  01038:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  0103c:    hwop       r13, r11, #0x20
  01040:    hwop       r10, r4, #0x20
  01044:    hwop       r11, r1, #0x0
  01048:    stw        r11, [r0, #0xd]
  0104c:    addd       r11, r11, #0x1
  01050:    subd       r12, r12, r11
  01054:    subd       r15, r15, r10
  01058:    hwop       r12, r12, #0x20
  0105c:    hwop       r12, r12, #0x20
  01060:    hwop       r15, r12, #0x23
  01064:    subd       r4, r8, r11
  01068:    subd       r5, r6, r10
  0106c:    hwop       r12, r5, #0x20
  01070:    hwop       r11, r7, #0x20
  01074:    hwop       r10, r11, #0x23
  01078:    hwop       r13, r10, #0x20
  0107c:    stw        r13, [r0, #0x179]
  01080:    lsrd       r4, r13, #32
  01084:    stw        r4, [r0, #0x17a]
  01088:    lsr        r14, r2, #31
  0108c:    cbz        r14, _DISPATCH_DIRECT_8
  01090:    lsr        r14, r2, #12
  01094:    and        r14, r14, #0xfffff001
  01098:    cbnz       r14, _DISPATCH_DIRECT_8
  0109c:    ldd        r14, reg[r0, #0x49f4]
  010a0:    lsr        r14, r14, #18
  010a4:    and        r14, r14, #0xfffff001
  010a8:    lsr        r11, r2, #19
  010ac:    and        r11, r11, #0xfffff001
  010b0:    hwop       r14, r14, #0x7
  010b4:    cbz        r14, _DISPATCH_DIRECT_8
  010b8:    hwop       r13, r13, #0x21
_DISPATCH_DIRECT_8:
  010bc:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  010c0:    stw        r13, [r0, #0x2]
  010c4:    lsrd       r13, r13, #32
  010c8:    stw        r13, [r0, #0x3]
  010cc:    add        r13, r15, #0x0
  010d0:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  010d4:    hwop       r13, r1, #0x0
  010d8:    stw        r13, [r0, #0x11]
  010dc:    and        r13, r13, #0xffffffff
  010e0:    add        r13, r13, #0x1
  010e4:    hwop       r13, r13, #0x3
  010e8:    dw         0x84000071  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71
  010ec:    hwop       r3, r1, #0x0
  010f0:    stw        r3, [r0, #0x12]
  010f4:    stw        r3, [r0, #0xb]
  010f8:    lsr        r3, r2, #19
  010fc:    and        r3, r3, #0xfffff001
  01100:    mov        r14, #0xe
  01104:    cbz        r3, _DISPATCH_DIRECT_9
  01108:    stw        r1, [r0, #0x15]
  0110c:    stw        r1, [r0, #0x16]
  01110:    stw        r1, [r0, #0x1c]
  01114:    add        r14, r14, #0x3
_DISPATCH_DIRECT_9:
  01118:    ldd        r6, reg[r0, #0x49f4]
  0111c:    lsr        r6, r6, #16
  01120:    and        r7, r6, #0xfffff001

DISPATCH_INDIRECT:
  01124:    cbz        r7, _DISPATCH_INDIRECT_0
  01128:    and        r8, r6, #0xffffe003
  0112c:    cbz        r8, _DISPATCH_INDIRECT_0
  01130:    stw        r0, [r0, #0xc0]
  01134:    ldd        r6, [r0, #0xc9]
  01138:    cbz        r6, _DISPATCH_INDIRECT_0
  0113c:    std        r8, [r0, #0xc1]
  01140:    b          _PKT_0xf0_0  
_DISPATCH_INDIRECT_0:
  01144:    stw        r0, [r0, #0xff]
  01148:    stw        r14, [r0, #0x81]
  0114c:    dw         0x84000415  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x415
  01150:    b          _PKT_0xf0_0  
  01154:    lsr        r10, r2, #19
  01158:    cbz        r10, _PKT_0xf0_8
_DISPATCH_INDIRECT_1:
  0115c:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  01160:    ldd        r6, reg[r0, #0x4a14]
  01164:    lsr        r6, r6, #25
  01168:    and        r10, r6, #0xfffff001
  0116c:    cbz        r10, _DISPATCH_INDIRECT_1
  01170:    dw         0x84000425  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x425
  01174:    ldd        r6, reg[r0, #0x4a14]
  01178:    and        r10, r6, #0xfffff810
  0117c:    cbz        r10, _DISPATCH_INDIRECT_2
  01180:    ldd        r6, reg[r0, #0x5aa8]
  01184:    and        r10, r6, #0xfffff808
  01188:    cbnz       r10, _DISPATCH_INDIRECT_2
  0118c:    std        r0, [r0, #0xca]
_DISPATCH_INDIRECT_2:
  01190:    btab

  01194:    stw        r0, [r0, #0x62]
  01198:    nop
  0119c:    ldd        r6, reg[r0, #0x4a14]
  011a0:    and        r10, r6, #0xfffff810
  011a4:    cbnz       r10, _DISPATCH_INDIRECT_3
  011a8:    and        r10, r6, #0xffff800f
  011ac:    cbnz       r10, _DISPATCH_INDIRECT_6
_DISPATCH_INDIRECT_3:
  011b0:    std        r1, [r0, #0x9b]
  011b4:    std        r1, [r0, #0x9a]
  011b8:    std        r1, [r0, #0x99]
_DISPATCH_INDIRECT_4:
  011bc:    ldd        r6, reg[r0, #0x84]
  011c0:    cbnz       r6, _DISPATCH_INDIRECT_4
  011c4:    dw         0x84000dc7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc7
  011c8:    mov        r12, #0x4a2c
  011cc:    stw        r12, [r0, #0x6b]
  011d0:    stw        r0, [r0, #0x64]
_DISPATCH_INDIRECT_5:
  011d4:    ldd        r6, reg[r12, #0x0]
  011d8:    and        r3, r6, #0xfffff801
  011dc:    cbz        r3, _DISPATCH_INDIRECT_5
  011e0:    stw        r0, [r0, #0x30]
  011e4:    dw         0x84000dc7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc7
  011e8:    stw        r0, [r0, #0x76]
  011ec:    stw        r0, [r0, #0x6b]
  011f0:    std        r1, [r0, #0x30]
  011f4:    ldd        r3, reg[r0, #0x5b44]
  011f8:    add        r4, r3, #0x1
  011fc:    stw        r4, reg[r0, #0x5b44]
  01200:    stw        r0, [r0, #0x85]
  01204:    stw        r3, reg[r0, #0x5b44]
  01208:    stw        r0, [r0, #0x9b]
  0120c:    std        r0, [r0, #0x9a]
  01210:    std        r0, [r0, #0x99]
  01214:    ldd        r5, reg[r0, #0x5abc]
  01218:    cbz        r5, _DISPATCH_INDIRECT_6
  0121c:    stw        r0, [r0, #0x42]
_DISPATCH_INDIRECT_6:
  01220:    btab

  01224:    stw        r2, [r0, #0x0]
  01228:    stw        r1, [r0, #0x2]
  0122c:    stw        r1, [r0, #0x3]
  01230:    stw        r1, [r0, #0x9]
  01234:    hwop       r3, r1, #0x0
  01238:    and        r4, r3, #0xffffffff

SET_PREDICATION:
  0123c:    stw        r4, [r0, #0xa]
  01240:    lsr        r3, r3, #16
  01244:    and        r4, r3, #0xffffffff
  01248:    stw        r4, [r0, #0x6]
  0124c:    add        r13, r4, #0x1
  01250:    hwop       r12, r1, #0x0
  01254:    stw        r12, [r0, #0x7]
  01258:    and        r12, r12, #0xffffffff
  0125c:    add        r12, r12, #0x1
  01260:    subd       r11, r12, r13
  01264:    hwop       r3, r1, #0x0
  01268:    stw        r3, [r0, #0x8]
  0126c:    and        r12, r3, #0xfffc007f
  01270:    dw         0x8400020e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x20e
  01274:    stw        r11, [r0, #0x18]
  01278:    stw        r1, [r0, #0x4]
  0127c:    stw        r1, [r0, #0x5]

REG_RMW:
  01280:    stw        r1, [r0, #0xf]
  01284:    hwop       r3, r1, #0x0
  01288:    and        r4, r3, #0xffffffff
  0128c:    stw        r4, [r0, #0x10]
  01290:    lsr        r3, r3, #16
  01294:    and        r4, r3, #0xffffffff
  01298:    stw        r4, [r0, #0xc]
  0129c:    add        r13, r4, #0x1
  012a0:    hwop       r12, r1, #0x0
  012a4:    stw        r12, [r0, #0xd]
  012a8:    and        r12, r12, #0xffffffff
  012ac:    add        r12, r12, #0x1
  012b0:    subd       r11, r12, r13
  012b4:    hwop       r3, r1, #0x0
  012b8:    stw        r3, [r0, #0xe]
  012bc:    and        r12, r3, #0xfffc007f
  012c0:    dw         0x8400020e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x20e
  012c4:    stw        r11, [r0, #0x19]
  012c8:    stw        r1, [r0, #0x11]
  012cc:    hwop       r3, r1, #0x0
  012d0:    stw        r3, [r0, #0x12]
  012d4:    stw        r3, [r0, #0xb]
  012d8:    lsr        r3, r2, #19
  012dc:    and        r3, r3, #0xfffff001
  012e0:    mov        r14, #0xf
  012e4:    cbz        r3, _REG_RMW_1
  012e8:    stw        r1, [r0, #0x15]
_REG_RMW_0:
  012ec:    stw        r1, [r0, #0x16]
  012f0:    stw        r1, [r0, #0x1c]
  012f4:    add        r14, r14, #0x3
_REG_RMW_1:
  012f8:    ldd        r6, reg[r0, #0x49f4]
  012fc:    lsr        r6, r6, #16
  01300:    and        r7, r6, #0xfffff001
  01304:    cbz        r7, _REG_RMW_2
  01308:    and        r8, r6, #0xffffe003
  0130c:    cbz        r8, _REG_RMW_2
  01310:    stw        r0, [r0, #0xc0]
  01314:    ldd        r6, [r0, #0xc9]
  01318:    cbz        r6, _REG_RMW_2
  0131c:    mov        r9, #0x1
  01320:    lsl        r9, r9, #4
  01324:    stw        r9, [r0, #0xc1]
  01328:    b          _PKT_0xf0_0  
_REG_RMW_2:
  0132c:    stw        r0, [r0, #0xff]
  01330:    stw        r14, [r0, #0x81]
  01334:    dw         0x84000415  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x415
  01338:    b          _PKT_0xf0_0  
  0133c:    dw         0x840000a1  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa1
  01340:    stw        r2, [r0, #0x0]
  01344:    mov        r13, #0x4
  01348:    stw        r1, [r0, #0x4]
  0134c:    stw        r1, [r0, #0x5]
  01350:    hwop       r3, r1, #0x0
  01354:    lsl        r4, r3, #12
  01358:    lsr        r5, r4, #12
  0135c:    hwop       r13, r13, #0x20
  01360:    add        r13, r13, #0x1
  01364:    stw        r13, [r0, #0x81]
  01368:    lsr        r12, r3, #8
  0136c:    stw        r12, [r0, #0xb]
  01370:    lsl        r11, r5, #2
  01374:    stw        r11, [r0, #0x1]
  01378:    mov        r7, #0x10
  0137c:    b          _REG_RMW_0  
  01380:    dw         0x840000a1  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa1
  01384:    stw        r2, [r0, #0x0]
  01388:    mov        r13, #0x9
  0138c:    stw        r1, [r0, #0x4]
  01390:    stw        r1, [r0, #0x5]
  01394:    hwop       r13, r1, #0x0
_REG_RMW_3:
  01398:    stw        r13, [r0, #0x6]
  0139c:    add        r13, r13, #0x1
  013a0:    hwop       r12, r1, #0x0
  013a4:    stw        r12, [r0, #0x7]
  013a8:    and        r12, r12, #0xffffffff
  013ac:    add        r12, r12, #0x1
  013b0:    subd       r11, r12, r13
  013b4:    stw        r11, [r0, #0x18]
  013b8:    stw        r1, [r0, #0x8]
  013bc:    stw        r1, [r0, #0x9]
  013c0:    hwop       r3, r1, #0x0
  013c4:    stw        r3, [r0, #0xa]
  013c8:    stw        r3, [r0, #0xb]
  013cc:    hwop       r3, r1, #0x0
  013d0:    lsl        r4, r3, #2
  013d4:    stw        r4, [r0, #0x1]
  013d8:    hwop       r13, r13, #0x20
  013dc:    add        r13, r13, #0x1
  013e0:    stw        r13, [r0, #0x81]
  013e4:    lsl        r11, r3, #2
  013e8:    mov        r7, #0x24
  013ec:    std        r2, [r0, #0xed]
  013f0:    ldd        r6, reg[r0, #0x4a14]
  013f4:    and        r10, r6, #0xfffff810
  013f8:    cbnz       r10, _PKT_0x38d7_0
  013fc:    ldd        r5, reg[r0, #0x5a88]
  01400:    lsld       r4, r5, #32
  01404:    ldd        r3, reg[r0, #0x5a84]
  01408:    hwop       r3, r3, #0x20
  0140c:    ldd        r5, reg[r0, #0x5a90]
  01410:    lsld       r5, r5, #32
  01414:    ldd        r4, reg[r0, #0x5a8c]
  01418:    hwop       r4, r5, #0x20
  0141c:    hwop       r4, r4, #0x20
  01420:    ldd        r7, reg[r0, #0x5a80]
  01424:    and        r8, r7, #0x7fffffff
  01428:    lsr        r7, r8, #1
  0142c:    mov        r8, #0x4
  01430:    hwop       r7, r8, #0x3
  01434:    sub        r9, r7, #0x1
  01438:    hwop       r4, r4, #0x6
  0143c:    lsld       r5, r3, #8
  01440:    hwop       r5, r5, #0x20
  01444:    lsrd       r3, r5, #32
  01448:    stw        r5, [r0, #0x2]
  0144c:    stw        r3, [r0, #0x3]

PKT_0x59f1:
  01450:    mov        r3, #0x1
_PKT_0x59f1_0:
  01454:    stw        r3, mem[r0, #0x67]

PKT_0x38d7:
  01458:    b          _REG_RMW_3  
_PKT_0x38d7_0:
  0145c:    ldd        r3, reg[r0, #0x5ab4]
  01460:    nop
  01464:    ldd        r6, reg[r0, #0x5ab8]
  01468:    nop
  0146c:    ldd        r9, reg[r0, #0x5ab0]
  01470:    nop
  01474:    hwop       r4, r9, #0x20
  01478:    hwop       r5, r3, #0x20
  0147c:    lsrd       r7, r5, #32
  01480:    hwop       r6, r6, #0x0
  01484:    stw        r5, [r0, #0x2]
  01488:    stw        r6, [r0, #0x3]
  0148c:    std        r1, [r0, #0x6d]
  01490:    std        r1, [r0, #0x6e]
  01494:    hwop       r7, r0, #0x0
  01498:    lsr        r10, r2, #31
  0149c:    and        r10, r10, #0xfffff001
  014a0:    cbz        r10, _PKT_0x38d7_2
_PKT_0x38d7_1:
  014a4:    ldd        r14, reg[r0, #0x5b00]
  014a8:    nop
  014ac:    stw        r14, reg[r0, #0x4ad0]
  014b0:    nop
_PKT_0x38d7_2:
  014b4:    dw         0x84000088  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x88
  014b8:    cbnz       r10, _PKT_0x38d7_3
  014bc:    stw        r0, [r0, #0xff]
_PKT_0x38d7_3:
  014c0:    std        r1, [r0, #0x9b]
_PKT_0x38d7_4:
  014c4:    dw         0x84000d42  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd42
  014c8:    ldd        r14, reg[r0, #0x6c]
  014cc:    and        r10, r14, #0xffd30fff
  014d0:    cbnz       r10, _STRMOUT_BUFFER_UPDATE_0
  014d4:    ldd        r12, reg[r0, #0x49f0]
  014d8:    lsr        r10, r12, #5
  014dc:    and        r12, r10, #0xfffff001
  014e0:    cbz        r12, _PKT_0x31_0
  014e4:    and        r10, r14, #0xfffff001
  014e8:    cbz        r10, _PKT_0x31_0
  014ec:    lsr        r12, r2, #31
  014f0:    and        r12, r12, #0xfffff001
  014f4:    cbnz       r12, _PKT_0x31_0
  014f8:    ldd        r10, reg[r0, #0x5ba4]
  014fc:    and        r12, r10, #0xfffff001
  01500:    cbz        r12, _STRMOUT_BUFFER_UPDATE_0

PKT_0x31:
  01504:    lsr        r12, r10, #8
  01508:    and        r12, r12, #0xfffff001
  0150c:    cbnz       r10, _STRMOUT_BUFFER_UPDATE_0
_PKT_0x31_0:
  01510:    ldd        r6, reg[r0, #0x4a14]
  01514:    lsr        r6, r6, #25
  01518:    and        r10, r6, #0xfffff001
  0151c:    cbz        r10, _PKT_0x38d7_4
  01520:    stw        r0, [r0, #0x62]
  01524:    std        r0, [r0, #0xed]
  01528:    ldd        r6, reg[r0, #0x4a14]
  0152c:    and        r10, r6, #0xfffff810
  01530:    cbnz       r10, _PKT_0x31_1
  01534:    mov        r10, #0x4a08
  01538:    stw        r0, mem[r0, #0x67]
  0153c:    mov        r8, #0x5a8c
  01540:    ldd        r4, reg[r8, #0x0]
  01544:    b          _PKT_0x59f1_0  
_PKT_0x31_1:
  01548:    mov        r8, #0x5ab0
  0154c:    ldd        r4, reg[r8, #0x0]
  01550:    mov        r10, #0x4a0c
  01554:    lsl        r11, r11, #8
  01558:    lsr        r11, r11, #8
  0155c:    addd       r11, r11, #0x4
  01560:    ldd        r6, reg[r10, #0x0]
  01564:    hwop       r3, r4, #0x0

INDIRECT_BUFFER_32:
  01568:    hwop       r14, r6, #0x0
  0156c:    setgt      r12, r6, r4
  01570:    cbz        r12, _INDIRECT_BUFFER_32_0
  01574:    hwop       r14, r6, #0x0
_INDIRECT_BUFFER_32_0:
  01578:    mul        r12, r3, r14
  0157c:    cbnz       r12, _INDIRECT_BUFFER_32_1
  01580:    hwop       r2, r11, #0x0
  01584:    b          _PKT_0x38d7_1  
_INDIRECT_BUFFER_32_1:
  01588:    hwop       r13, r3, #0x0
  0158c:    stw        r13, reg[r10, #0x0]
  01590:    add        r2, r3, r6

INDIRECT_BUFFER_CONST:
  01594:    hwop       r2, r4, #0x0
  01598:    hwop       r13, r2, #0x0
  0159c:    stw        r13, reg[r8, #0x0]
  015a0:    add        r2, r14, r4
  015a4:    lsr        r2, r2, #2
  015a8:    stw        r2, reg[r0, #0x5ac0]
  015ac:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
_INDIRECT_BUFFER_CONST_0:
  015b0:    ldd        r10, reg[r0, #0x6c]
  015b4:    and        r10, r10, #0xffd30fff
  015b8:    cbnz       r10, _STRMOUT_BUFFER_UPDATE_0
  015bc:    ldd        r4, reg[r0, #0x5ac0]

STRMOUT_BUFFER_UPDATE:
  015c0:    cbnz       r4, _INDIRECT_BUFFER_CONST_0
  015c4:    stw        r0, [r0, #0x9b]
  015c8:    std        r0, [r0, #0x6d]
  015cc:    b          _PKT_0xf0_2  
  015d0:    nop
_STRMOUT_BUFFER_UPDATE_0:
  015d4:    lsr        r10, r2, #31
  015d8:    and        r10, r10, #0xfffff001
  015dc:    cbz        r10, _DRAW_INDEX_OFFSET_2_0
  015e0:    ldd        r6, reg[r0, #0x4ad0]
  015e4:    nop
  015e8:    stw        r6, reg[r0, #0x5b00]

DRAW_INDEX_OFFSET_2:
  015ec:    nop
  015f0:    stw        r0, reg[r0, #0x5ba4]
  015f4:    nop
_DRAW_INDEX_OFFSET_2_0:
  015f8:    stw        r0, [r0, #0x9b]
  015fc:    std        r0, [r0, #0x6d]
  01600:    b          _PKT_0xf0_28  
  01604:    dw         0x84000d88  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd88
_DRAW_INDEX_OFFSET_2_1:
  01608:    ldd        r3, reg[r0, #0x4a18]

DRAW_PREAMBLE:
  0160c:    lsr        r4, r3, #16

COPY_DATA:
  01610:    and        r4, r4, #0xfffff001
  01614:    cbnz       r4, _DRAW_INDEX_OFFSET_2_1
  01618:    std        r9, [r0, #0x81]
  0161c:    stw        r2, [r0, #0x200]
  01620:    stw        r1, [r0, #0x201]
  01624:    stw        r1, [r0, #0x202]
  01628:    stw        r1, [r0, #0x203]
  0162c:    stw        r1, [r0, #0x204]
  01630:    stw        r1, [r0, #0x205]
  01634:    stw        r1, [r0, #0x206]
  01638:    stw        r1, [r0, #0x207]
  0163c:    stw        r1, [r0, #0x208]
  01640:    std        r1, [r0, #0x22d]
  01644:    hwop       r6, r2, #0x0
  01648:    lsr        r6, r6, #30
  0164c:    and        r6, r6, #0xffffc007
  01650:    orr        r7, r6, #0x1
  01654:    cbz        r7, _COPY_DATA_1
_COPY_DATA_0:
  01658:    ldd        r5, reg[r0, #0x16c]
  0165c:    cbz        r5, _COPY_DATA_0
  01660:    std        r1, [r0, #0x209]
_COPY_DATA_1:
  01664:    b          _PKT_0xf0_2  
  01668:    dw         0x84000d88  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd88
  0166c:    std        r5, [r0, #0x81]
  01670:    stw        r2, [r0, #0x210]
  01674:    stw        r1, [r0, #0x211]
  01678:    stw        r1, [r0, #0x212]
  0167c:    stw        r1, [r0, #0x213]
  01680:    stw        r1, [r0, #0x214]
_COPY_DATA_2:
  01684:    ldd        r5, reg[r0, #0x16c]
  01688:    cbz        r5, _COPY_DATA_2
  0168c:    std        r1, [r0, #0x215]
  01690:    b          _PKT_0xf0_2  
  01694:    dw         0x84000d88  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd88
  01698:    std        r1, [r0, #0x81]
  0169c:    stw        r2, [r0, #0x219]
  016a0:    hwop       r6, r2, #0x0
  016a4:    lsr        r6, r6, #30
  016a8:    and        r6, r6, #0xfffff001
  016ac:    cbz        r6, _PKT_0xf0_11
_COPY_DATA_3:
  016b0:    ldd        r5, reg[r0, #0x16c]
  016b4:    cbz        r5, _COPY_DATA_3
  016b8:    std        r1, [r0, #0x220]
  016bc:    b          _PKT_0xf0_2  
  016c0:    dw         0x84000d8c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd8c
  016c4:    std        r5, [r0, #0x81]
  016c8:    stw        r2, [r0, #0x221]
  016cc:    stw        r1, [r0, #0x222]
  016d0:    stw        r1, [r0, #0x223]
  016d4:    stw        r1, [r0, #0x224]
  016d8:    stw        r1, [r0, #0x225]
_COPY_DATA_4:
  016dc:    ldd        r5, reg[r0, #0x16c]
  016e0:    cbz        r5, _COPY_DATA_4
  016e4:    std        r1, [r0, #0x226]
  016e8:    b          _PKT_0xf0_2  
  016ec:    dw         0x84000d8c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd8c
  016f0:    std        r2, [r0, #0x81]
  016f4:    stw        r2, [r0, #0x216]
  016f8:    stw        r1, [r0, #0x217]
_COPY_DATA_5:
  016fc:    ldd        r5, reg[r0, #0x16c]
  01700:    cbz        r5, _COPY_DATA_5
_COPY_DATA_6:
  01704:    std        r1, [r0, #0x218]
  01708:    b          _PKT_0xf0_2  
  0170c:    b          _PKT_0xf0_2  
  01710:    std        r6, [r0, #0x81]
  01714:    ldd        r6, reg[r0, #0x5aa8]
  01718:    and        r12, r6, #0xfffff001
  0171c:    stw        r0, [r0, #0x7e]
  01720:    cbz        r12, _PKT_0x70_3
  01724:    and        r3, r6, #0xffffffff
  01728:    lsr        r4, r2, #16

DMA_DATA:
  0172c:    lsl        r5, r4, #16
  01730:    hwop       r7, r5, #0x7
  01734:    stw        r7, reg[r0, #0x5aa8]
  01738:    stw        r1, reg[r0, #0x5ab4]
  0173c:    nop
  01740:    stw        r1, reg[r0, #0x5ab8]
  01744:    stw        r0, reg[r0, #0x5ab0]
  01748:    hwop       r12, r1, #0x0
  0174c:    stw        r12, reg[r0, #0x5abc]
  01750:    stw        r0, [r0, #0x3c]
  01754:    hwop       r3, r1, #0x0
  01758:    hwop       r4, r1, #0x0
  0175c:    stw        r0, [r0, #0x85]
  01760:    stw        r3, reg[r0, #0x5b30]
  01764:    stw        r4, reg[r0, #0x5b34]
  01768:    stw        r0, [r0, #0x8a]
  0176c:    stw        r0, [r0, #0x7f]
  01770:    hwop       r10, r3, #0x7
  01774:    cbz        r10, _PKT_0x70_2
  01778:    lsld       r6, r4, #32
  0177c:    hwop       r6, r6, #0x20
  01780:    mov        r9, #0x5ab0
  01784:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22

LOAD_CONFIG_REG:
  01788:    cbz        r5, _PKT_0x70_0
  0178c:    mov        r9, #0x5b00
  01790:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22
  01794:    mov        r9, #0x5b04
  01798:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22
  0179c:    mov        r9, #0x5b08
  017a0:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22
  017a4:    mov        r9, #0x5b0c
  017a8:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22
  017ac:    mov        r9, #0x5b10
  017b0:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22

PKT_0x70:
  017b4:    mov        r9, #0x5b14
  017b8:    dw         0x84000f22  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf22
  017bc:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
_PKT_0x70_0:
  017c0:    std        r1, [r0, #0xfd]
  017c4:    lsl        r12, r12, #2
  017c8:    std        r1, mem[r0, #0x43]
  017cc:    std        r4, mem[r0, #0x44]
  017d0:    mov        r10, #0x10
  017d4:    stw        r10, mem[r0, #0x23]
  017d8:    stw        r3, mem[r0, #0x45]
  017dc:    stw        r0, mem[r0, #0x48]
  017e0:    stw        r0, mem[r0, #0x47]
  017e4:    stw        r4, mem[r0, #0x46]
  017e8:    stw        r0, [r0, #0x62]
  017ec:    std        r0, [r0, #0xfd]
_PKT_0x70_1:
  017f0:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  017f4:    ldd        r6, reg[r0, #0x4a14]
  017f8:    lsr        r6, r6, #25
  017fc:    and        r4, r6, #0xfffff001
  01800:    cbz        r4, _PKT_0x70_1
_PKT_0x70_2:
  01804:    stw        r0, [r0, #0x42]
  01808:    b          _PKT_0x0_0  
_PKT_0x70_3:
  0180c:    hwop       r2, r1, #0x0
  01810:    hwop       r2, r1, #0x0
  01814:    hwop       r2, r1, #0x0
  01818:    hwop       r2, r1, #0x0
  0181c:    hwop       r2, r1, #0x0
  01820:    std        r1, [r0, #0x8b]
  01824:    stw        r0, [r0, #0x62]
  01828:    b          _PKT_0xf0_2  
  0182c:    std        r1, mem[r0, #0x43]
  01830:    std        r4, mem[r0, #0x44]
  01834:    stw        r2, mem[r0, #0x25]
  01838:    lsr        r3, r2, #16
  0183c:    and        r3, r3, #0xfffc007f
  01840:    add        r3, r3, #0x10
  01844:    stw        r3, mem[r0, #0x117]
  01848:    lsr        r3, r2, #24
  0184c:    and        r3, r3, #0xffffc007
  01850:    add        r3, r3, #0x10
  01854:    stw        r3, mem[r0, #0x118]
  01858:    lsr        r2, r1, #2
  0185c:    lsl        r2, r2, #2
  01860:    stw        r2, mem[r0, #0x45]
  01864:    hwop       r3, r1, #0x0
  01868:    ldd        r6, reg[r0, #0x49f0]
  0186c:    and        r10, r6, #0xf800ffff

INCREMENT_CE_COUNTER:
  01870:    lsr        r10, r10, #3
  01874:    stw        r10, mem[r0, #0x47]
  01878:    stw        r1, mem[r0, #0x48]
  0187c:    stw        r3, mem[r0, #0x46]
  01880:    std        r4, [r0, #0x81]
  01884:    b          _PKT_0xf0_2  
  01888:    ldd        r6, reg[r0, #0x49f0]
  0188c:    hwop       r3, r1, #0x0
  01890:    std        r2, [r0, #0x81]
  01894:    and        r10, r6, #0xfffff001
  01898:    cbz        r10, _INCREMENT_CE_COUNTER_0
  0189c:    mov        r2, #0xe0
  018a0:    stw        r2, [r0, #0x50]
  018a4:    stw        r3, [r0, #0x51]
  018a8:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
_INCREMENT_CE_COUNTER_0:
  018ac:    stw        r0, [r0, #0x62]
  018b0:    b          _PKT_0xf0_2  
  018b4:    stw        r2, [r0, #0x55]
  018b8:    std        r3, [r0, #0x81]
  018bc:    lsr        r3, r2, #30
  018c0:    and        r3, r3, #0xfffff001
  018c4:    stw        r1, [r0, #0x56]
  018c8:    stw        r1, [r0, #0x57]
_INCREMENT_CE_COUNTER_1:
  018cc:    ldd        r6, reg[r0, #0x4a14]
  018d0:    nop
  018d4:    and        r10, r6, #0xfffff810
  018d8:    cbz        r10, _INCREMENT_CE_COUNTER_2
  018dc:    nop
  018e0:    ldd        r6, reg[r0, #0x80]
  018e4:    nop
  018e8:    cbnz       r6, _PKT_0xf0_121
  018ec:    nop
_INCREMENT_CE_COUNTER_2:
  018f0:    nop
  018f4:    ldd        r5, [r0, #0x58]
  018f8:    nop
  018fc:    sub        r6, r5, #0x3
  01900:    cbz        r6, _INCREMENT_CE_COUNTER_4
  01904:    sub        r7, r5, #0x1
  01908:    cbz        r7, _INCREMENT_CE_COUNTER_3
  0190c:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  01910:    dw         0x84000d42  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd42
  01914:    dw         0x840013d6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13d6
  01918:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  0191c:    ldd        r6, reg[r0, #0x6c]
  01920:    and        r4, r6, #0xff001fff
  01924:    cbnz       r4, _PKT_0xf0_38
  01928:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  0192c:    ldd        r7, [r0, #0x59]
  01930:    cbz        r7, _INCREMENT_CE_COUNTER_1
  01934:    mov        r2, #0xe2
  01938:    stw        r2, [r0, #0x50]
  0193c:    mov        r3, #0x1
  01940:    stw        r3, [r0, #0x65]
  01944:    mov        r2, #0xffff
  01948:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  0194c:    b          _PKT_0xf0_87  
_INCREMENT_CE_COUNTER_3:
  01950:    mov        r2, #0xdd
  01954:    stw        r2, [r0, #0x50]
  01958:    mov        r4, #0x5
  0195c:    stw        r4, [r0, #0x65]
  01960:    mov        r2, #0xffff
  01964:    b          _PKT_0xf0_44  
_INCREMENT_CE_COUNTER_4:
  01968:    stw        r0, [r0, #0x62]
  0196c:    b          _PKT_0xf0_2  
  01970:    hwop       r3, r1, #0x0
  01974:    stw        r3, reg[r0, #0x4f80]
  01978:    nop
  0197c:    hwop       r3, r1, #0x0
  01980:    stw        r3, reg[r0, #0x4f84]
  01984:    nop
  01988:    hwop       r3, r1, #0x0
  0198c:    lsr        r4, r3, #16
  01990:    and        r4, r4, #0x7fffffff
  01994:    stw        r4, reg[r0, #0x4f88]
  01998:    nop
  0199c:    and        r4, r3, #0xffffffff
  019a0:    stw        r4, reg[r0, #0x4f8c]
  019a4:    nop
  019a8:    lsr        r4, r3, #21
  019ac:    and        r4, r4, #0xfffff001
  019b0:    lsr        r5, r3, #22
  019b4:    and        r5, r5, #0xfffff001
  019b8:    mov        r3, #0x1
  019bc:    lsl        r3, r3, #16
  019c0:    mov        r6, #0xa6e4
  019c4:    hwop       r6, r6, #0x0
  019c8:    mov        r7, #0xa709
  019cc:    hwop       r7, r7, #0x0
  019d0:    mov        r8, #0xa70a
  019d4:    hwop       r8, r8, #0x0
  019d8:    mov        r9, #0x28a4
  019dc:    mov        r10, #0x28c9
  019e0:    mov        r11, #0x28ca
  019e4:    ldd        r14, reg[r0, #0x4a60]
  019e8:    and        r13, r14, #0xffffc007
  019ec:    cbz        r13, _PKT_0x71_0
  019f0:    mov        r3, #0x1
  019f4:    lsl        r3, r3, #16
  019f8:    mov        r6, #0xa6e7
  019fc:    hwop       r6, r6, #0x0

PKT_0x71:
  01a00:    mov        r7, #0xa70f
  01a04:    hwop       r7, r7, #0x0
  01a08:    mov        r8, #0xa710
  01a0c:    hwop       r8, r8, #0x0
  01a10:    mov        r9, #0x28a7
  01a14:    mov        r10, #0x28cf
  01a18:    mov        r11, #0x28d0
_PKT_0x71_0:
  01a1c:    cbz        r5, _PKT_0xd5fc_0
  01a20:    ldd        r3, reg[r0, #0x4f84]
  01a24:    hwop       r13, r7, #0x0
  01a28:    dw         0x8400067b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x67b
  01a2c:    ldd        r3, reg[r0, #0x4f88]
  01a30:    hwop       r13, r8, #0x0

PKT_0xd5fc:
  01a34:    dw         0x8400067b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x67b
  01a38:    ldd        r3, reg[r0, #0x4f80]
  01a3c:    hwop       r13, r6, #0x0
  01a40:    dw         0x8400067b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x67b
_PKT_0xd5fc_0:
  01a44:    cbz        r4, _PKT_0xd5fc_1
  01a48:    ldd        r3, reg[r0, #0x4f84]
  01a4c:    hwop       r13, r10, #0x0
  01a50:    dw         0x8400067b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x67b
  01a54:    ldd        r3, reg[r0, #0x4f88]
  01a58:    hwop       r13, r11, #0x0
  01a5c:    dw         0x8400067b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x67b
  01a60:    ldd        r3, reg[r0, #0x4f80]
  01a64:    hwop       r13, r9, #0x0
  01a68:    dw         0x8400067b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x67b
_PKT_0xd5fc_1:
  01a6c:    mov        r3, #0x6
  01a70:    lsl        r3, r3, #16

WRITE_CONST_RAM:
  01a74:    mov        r6, #0x9bd8
  01a78:    hwop       r6, r6, #0x0
  01a7c:    mov        r7, #0xa2d8
  01a80:    ldd        r14, reg[r0, #0x4a60]
  01a84:    and        r13, r14, #0xffffc007
  01a88:    cbz        r13, _WRITE_CONST_RAM_0
  01a8c:    mov        r3, #0x6
  01a90:    lsl        r3, r3, #16
  01a94:    mov        r6, #0x9be4
  01a98:    hwop       r6, r6, #0x0
  01a9c:    mov        r7, #0xa2e4
_WRITE_CONST_RAM_0:
  01aa0:    cbz        r5, _WRITE_CONST_RAM_1
  01aa4:    hwop       r8, r6, #0x0
  01aa8:    dw         0x84000672  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x672
  01aac:    nop
_WRITE_CONST_RAM_1:
  01ab0:    cbz        r4, _PKT_0x82_0

PKT_0x82:
  01ab4:    hwop       r8, r7, #0x0
  01ab8:    dw         0x84000672  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x672
  01abc:    nop
_PKT_0x82_0:
  01ac0:    std        r4, [r0, #0x81]
  01ac4:    b          _PKT_0xf0_2  
  01ac8:    ldd        r3, reg[r0, #0x4f8c]
_PKT_0x82_1:
  01acc:    std        r15, [r0, #0xd1]
  01ad0:    ldd        r12, unk[r8, #0x0]
  01ad4:    nop
  01ad8:    dw         0x84000fe2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe2
  01adc:    and        r13, r12, #0xffffffff
  01ae0:    seteq      r14, r13, r3
  01ae4:    cbz        r14, _PKT_0x82_1
  01ae8:    btab

  01aec:    std        r15, [r0, #0xd1]
  01af0:    stw        r13, [r0, #0x5b]
  01af4:    stw        r3, [r0, #0x5c]
  01af8:    dw         0x84000fe2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe2
  01afc:    btab

  01b00:    hwop       r3, r1, #0x0
  01b04:    hwop       r4, r1, #0x0
_PKT_0x82_2:
  01b08:    lsld       r10, r4, #32
  01b0c:    hwop       r11, r10, #0x20
  01b10:    addd       r10, r11, #0x4
  01b14:    hwop       r5, r10, #0x0
  01b18:    lsrd       r6, r10, #32
  01b1c:    stw        r3, mem[r0, #0x52]
  01b20:    stw        r4, mem[r0, #0x53]
  01b24:    ldd        r12, mem[r0, #0x0]
  01b28:    nop
  01b2c:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  01b30:    nop
  01b34:    nop
  01b38:    lsld       r14, r13, #32
  01b3c:    hwop       r14, r14, #0x20
  01b40:    addd       r14, r14, #0x1
  01b44:    hwop       r12, r14, #0x0
  01b48:    lsrd       r13, r14, #32
  01b4c:    std        r1, mem[r0, #0x43]
  01b50:    std        r4, mem[r0, #0x44]
_PKT_0x82_3:
  01b54:    std        r0, mem[r0, #0x47]
  01b58:    stw        r3, mem[r0, #0x45]
  01b5c:    stw        r12, mem[r0, #0x48]
  01b60:    stw        r4, mem[r0, #0x46]
  01b64:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  01b68:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  01b6c:    std        r3, [r0, #0x81]
  01b70:    b          _PKT_0xf0_2  
  01b74:    std        r3, [r0, #0xd3]
  01b78:    hwop       r3, r1, #0x0
  01b7c:    hwop       r4, r1, #0x0
  01b80:    hwop       r5, r1, #0x0
  01b84:    ldd        r6, unk[r3, #0x0]
  01b88:    nop
  01b8c:    nop
  01b90:    std        r1, mem[r0, #0x43]
  01b94:    std        r4, mem[r0, #0x44]
  01b98:    nop
  01b9c:    stw        r4, mem[r0, #0x45]
  01ba0:    stw        r6, mem[r0, #0x48]
  01ba4:    stw        r0, mem[r0, #0x47]
  01ba8:    stw        r5, mem[r0, #0x46]
  01bac:    std        r4, [r0, #0x81]
  01bb0:    b          _PKT_0xf0_2  
  01bb4:    mov        r9, #0xf884
  01bb8:    lsl        r9, r9, #2
  01bbc:    ldd        r12, reg[r9, #0x0]
  01bc0:    lsr        r13, r12, #31
  01bc4:    cbnz       r13, _LOAD_CONST_RAM_3
  01bc8:    lsr        r10, r2, #16
  01bcc:    orr        r11, r10, #0x0
  01bd0:    cbnz       r11, _PKT_0x82_4
  01bd4:    orr        r11, r10, #0x1
  01bd8:    cbnz       r11, _PKT_0x82_5
  01bdc:    orr        r11, r10, #0x2
  01be0:    cbnz       r11, _PKT_0x82_7
  01be4:    b          _PKT_0x82_6  
_PKT_0x82_4:
  01be8:    mov        r10, #0x14c
  01bec:    mov        r11, #0x148
  01bf0:    b          _PKT_0x82_2  
_PKT_0x82_5:
  01bf4:    mov        r10, #0x154
  01bf8:    mov        r11, #0x150
_PKT_0x82_6:
  01bfc:    b          _PKT_0x82_2  
_PKT_0x82_7:
  01c00:    mov        r10, #0x144
  01c04:    mov        r11, #0x140
  01c08:    mov        r2, #0x0
  01c0c:    ldd        r12, reg[r10, #0x0]
  01c10:    mov        r5, #0x0
  01c14:    ldd        r13, reg[r11, #0x0]
  01c18:    mov        r8, #0x0
  01c1c:    hwop       r3, r1, #0x0
  01c20:    hwop       r4, r1, #0x0
  01c24:    lsld       r6, r4, #32
  01c28:    hwop       r6, r6, #0x20
  01c2c:    hwop       r4, r1, #0x0
  01c30:    add        r3, r4, #0x0
  01c34:    ldd        r4, reg[r0, #0x4a20]
  01c38:    and        r4, r4, #0xffffc007
  01c3c:    add        r7, r4, #0x4
  01c40:    mov        r14, #0x1
  01c44:    hwop       r4, r14, #0x3
  01c48:    hwop       r7, r1, #0x0
  01c4c:    std        r3, [r0, #0xd3]
  01c50:    stw        r0, [r0, #0xd5]
_PKT_0x82_8:
  01c54:    lsld       r11, r12, #2
  01c58:    ldd        r10, unk[r11, #0x0]

LOAD_CONST_RAM:
  01c5c:    nop
  01c60:    and        r9, r10, #0xfffff001
  01c64:    cbz        r9, _PKT_0x82_8
  01c68:    dw         0x84000707  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x707
  01c6c:    ldd        r9, reg[r0, #0x4a80]
  01c70:    and        r9, r9, #0xfffff001
  01c74:    cbnz       r9, _PKT_0x82_8
  01c78:    stw        r13, [r0, #0x5b]
  01c7c:    stw        r14, [r0, #0x5c]
  01c80:    hwop       r3, r3, #0x20
  01c84:    dw         0x84000159  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x159
  01c88:    lsld       r11, r12, #2
_LOAD_CONST_RAM_0:
  01c8c:    ldd        r10, unk[r11, #0x0]
  01c90:    nop
  01c94:    and        r9, r10, #0xfffff001
  01c98:    cbz        r9, _LOAD_CONST_RAM_0
  01c9c:    nop
  01ca0:    std        r1, [r0, #0xf3]
  01ca4:    std        r0, [r0, #0xf3]
  01ca8:    lsr        r11, r10, #1
  01cac:    and        r10, r11, #0xfffff001
  01cb0:    and        r9, r2, #0x7fffffff
  01cb4:    hwop       r11, r10, #0x3
  01cb8:    hwop       r5, r5, #0x0
  01cbc:    add        r2, r2, #0x1
  01cc0:    seteq      r11, r2, r7
  01cc4:    cbnz       r11, _LOAD_CONST_RAM_2
  01cc8:    and        r10, r2, #0xfffc007f
  01ccc:    cbnz       r10, _LOAD_CONST_RAM_1
  01cd0:    lsl        r11, r8, #1
  01cd4:    add        r8, r11, #0x1
_LOAD_CONST_RAM_1:
  01cd8:    and        r11, r2, #0x7fffffff
  01cdc:    cbnz       r11, _PKT_0x82_8
  01ce0:    dw         0x84000f83  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf83
  01ce4:    mov        r5, #0x0
  01ce8:    mov        r8, #0x0
  01cec:    b          _PKT_0x82_3  
_LOAD_CONST_RAM_2:
  01cf0:    lsl        r11, r8, #1
  01cf4:    add        r8, r11, #0x1
  01cf8:    dw         0x84000f83  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf83
  01cfc:    std        r5, [r0, #0x81]
  01d00:    b          _PKT_0xf0_2  
_LOAD_CONST_RAM_3:
  01d04:    hwop       r2, r1, #0x0
  01d08:    hwop       r2, r1, #0x0
  01d0c:    hwop       r2, r1, #0x0
  01d10:    hwop       r2, r1, #0x0
  01d14:    std        r5, [r0, #0x81]
  01d18:    b          _PKT_0xf0_2  
  01d1c:    lsr        r10, r3, #4
  01d20:    lsl        r14, r10, #4
  01d24:    lsld       r9, r14, #12
  01d28:    add        r10, r9, #0x0
_LOAD_CONST_RAM_4:
  01d2c:    lsrd       r14, r9, #32
  01d30:    std        r1, [r0, #0xbe]
  01d34:    stw        r10, [r0, #0xb9]
  01d38:    stw        r14, [r0, #0xba]
  01d3c:    ldd        r10, [r0, #0xbb]
  01d40:    ldd        r14, [r0, #0xbf]
  01d44:    lsld       r9, r14, #32
  01d48:    hwop       r9, r9, #0x20
  01d4c:    lsrd       r10, r9, #16
  01d50:    lsld       r14, r10, #4
  01d54:    add        r14, r14, #0x3
  01d58:    btab

  01d5c:    lsr        r10, r2, #26
  01d60:    and        r7, r10, #0xfffff001
  01d64:    lsr        r11, r2, #31
  01d68:    eor        r10, r11, r0
  01d6c:    hwop       r6, r7, #0x6
  01d70:    lsr        r2, r2, #28
  01d74:    and        r13, r2, #0xfffc007f
  01d78:    stw        r13, [r0, #0x71]
  01d7c:    hwop       r4, r1, #0x0
  01d80:    hwop       r5, r1, #0x0
  01d84:    hwop       r7, r1, #0x0
  01d88:    stw        r7, [r0, #0x73]
  01d8c:    stw        r1, [r0, #0x72]
  01d90:    std        r6, [r0, #0x81]
  01d94:    std        r3, [r0, #0xd3]
  01d98:    hwop       r9, r1, #0x0
  01d9c:    and        r8, r9, #0xffffffff
  01da0:    lsr        r3, r9, #16
  01da4:    cbz        r3, _LOAD_CONST_RAM_5
  01da8:    addd       r3, r3, #0x1
_LOAD_CONST_RAM_5:
  01dac:    setgt      r12, r8, #0x3
  01db0:    lsl        r8, r8, #2
  01db4:    cbnz       r12, _LOAD_CONST_RAM_6
  01db8:    mov        r8, #0x10
_LOAD_CONST_RAM_6:
  01dbc:    mov        r9, #0x1
  01dc0:    cbz        r6, _LOAD_CONST_RAM_7
  01dc4:    lsr        r14, r5, #20
  01dc8:    lsl        r14, r14, #20
  01dcc:    lsl        r10, r5, #12
  01dd0:    lsr        r10, r10, #12
  01dd4:    lsr        r10, r10, #2
  01dd8:    hwop       r10, r10, #0x0
  01ddc:    mov        r2, #0xf
  01de0:    lsl        r2, r2, #28
  01de4:    dw         0x84000a24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa24
_LOAD_CONST_RAM_7:
  01de8:    ldd        r14, reg[r0, #0x49f4]
  01dec:    mov        r12, #0x1
  01df0:    lsl        r12, r12, #20
  01df4:    hwop       r14, r14, #0x27

DUMP_CONST_RAM:
  01df8:    stw        r14, reg[r0, #0x49f4]
_DUMP_CONST_RAM_0:
  01dfc:    sub        r9, r9, #0x1
  01e00:    cbnz       r9, _DUMP_CONST_RAM_0
  01e04:    cbnz       r11, _DUMP_CONST_RAM_1
  01e08:    stw        r0, [r0, #0x74]
  01e0c:    std        r15, [r0, #0xd1]
  01e10:    ldd        r12, unk[r4, #0x0]
  01e14:    b          _LOAD_CONST_RAM_4  
_DUMP_CONST_RAM_1:
  01e18:    stw        r4, mem[r0, #0x52]
  01e1c:    stw        r5, mem[r0, #0x53]
  01e20:    stw        r0, [r0, #0x74]
  01e24:    nop
  01e28:    ldd        r12, mem[r0, #0x0]
  01e2c:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  01e30:    dw         0x84000d42  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd42
  01e34:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  01e38:    cbnz       r12, _DUMP_CONST_RAM_4
  01e3c:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  01e40:    ldd        r14, reg[r0, #0x6c]
  01e44:    and        r14, r14, #0xfffff001
  01e48:    cbnz       r14, _PKT_0xf0_38
  01e4c:    dw         0x840013d6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13d6
  01e50:    cbz        r11, _DUMP_CONST_RAM_2
  01e54:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  01e58:    ldd        r14, reg[r0, #0x6c]
  01e5c:    and        r14, r14, #0xffffe003
  01e60:    cbnz       r14, _PKT_0xf0_38
_DUMP_CONST_RAM_2:
  01e64:    hwop       r9, r8, #0x0
  01e68:    cbz        r3, _DUMP_CONST_RAM_3
  01e6c:    ldd        r14, reg[r0, #0x49f4]
  01e70:    lsr        r10, r14, #20
  01e74:    and        r14, r10, #0xfffff001
  01e78:    cbz        r14, _DUMP_CONST_RAM_6
  01e7c:    lsr        r10, r3, #12
  01e80:    sub        r10, r10, #0x1
  01e84:    cbz        r10, _DUMP_CONST_RAM_0
  01e88:    subd       r3, r3, #0x1
  01e8c:    cbnz       r3, _DUMP_CONST_RAM_0
_DUMP_CONST_RAM_3:
  01e90:    mov        r2, #0xf6
  01e94:    stw        r2, [r0, #0x50]
  01e98:    mov        r3, #0x2
  01e9c:    stw        r3, [r0, #0x65]
  01ea0:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  01ea4:    dw         0x84000777  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x777
  01ea8:    b          _PKT_0xf0_87  
_DUMP_CONST_RAM_4:
  01eac:    cbz        r6, _DUMP_CONST_RAM_6
  01eb0:    lsr        r14, r4, #20
  01eb4:    lsl        r14, r14, #20
  01eb8:    lsl        r10, r4, #12
  01ebc:    lsr        r10, r10, #12
  01ec0:    lsr        r10, r10, #2
  01ec4:    hwop       r10, r10, #0x0
_DUMP_CONST_RAM_5:
  01ec8:    mov        r2, #0xf
  01ecc:    lsl        r2, r2, #28
  01ed0:    dw         0x84000a24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa24
_DUMP_CONST_RAM_6:
  01ed4:    dw         0x84000777  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x777
  01ed8:    b          _PKT_0xf0_2  
  01edc:    ldd        r11, reg[r0, #0x49f4]
  01ee0:    mov        r12, #0x1
  01ee4:    lsl        r14, r12, #20
  01ee8:    eor        r12, r14, r0
  01eec:    hwop       r14, r11, #0x6
  01ef0:    stw        r14, reg[r0, #0x49f4]
  01ef4:    btab

  01ef8:    stw        r0, reg[r0, #0x4f94]
  01efc:    nop
  01f00:    lsr        r11, r2, #31
  01f04:    hwop       r3, r1, #0x0
  01f08:    cbnz       r11, _DUMP_CONST_RAM_7
  01f0c:    nop
  01f10:    stw        r3, reg[r0, #0x4f80]
  01f14:    nop
  01f18:    nop
  01f1c:    stw        r3, reg[r0, #0x4f84]
  01f20:    nop
  01f24:    nop
  01f28:    stw        r3, reg[r0, #0x4f88]
  01f2c:    nop
  01f30:    nop
  01f34:    stw        r3, reg[r0, #0x4f8c]
  01f38:    nop
  01f3c:    nop
  01f40:    stw        r3, reg[r0, #0x5100]
  01f44:    nop
  01f48:    nop
  01f4c:    stw        r3, reg[r0, #0x5104]
  01f50:    nop
  01f54:    nop
  01f58:    stw        r3, reg[r0, #0x5108]
  01f5c:    nop
  01f60:    nop
  01f64:    stw        r3, reg[r0, #0x510c]
  01f68:    nop
  01f6c:    nop
_DUMP_CONST_RAM_7:
  01f70:    hwop       r4, r1, #0x0
  01f74:    hwop       r5, r1, #0x0
  01f78:    lsld       r6, r5, #32
  01f7c:    hwop       r6, r6, #0x20
  01f80:    hwop       r4, r1, #0x0
  01f84:    hwop       r5, r1, #0x0
  01f88:    lsld       r7, r5, #32
  01f8c:    hwop       r7, r7, #0x20
  01f90:    hwop       r4, r1, #0x0
  01f94:    hwop       r5, r1, #0x0
  01f98:    lsld       r8, r5, #32
  01f9c:    hwop       r8, r8, #0x20
  01fa0:    hwop       r4, r1, #0x0
  01fa4:    hwop       r5, r1, #0x0
  01fa8:    lsld       r9, r5, #32
  01fac:    hwop       r9, r9, #0x20
  01fb0:    hwop       r13, r1, #0x0
  01fb4:    hwop       r14, r1, #0x0
  01fb8:    lsld       r12, r14, #32
  01fbc:    hwop       r13, r13, #0x20
  01fc0:    hwop       r2, r1, #0x0
  01fc4:    std        r13, [r0, #0x81]
_DUMP_CONST_RAM_8:
  01fc8:    cbz        r11, _DUMP_CONST_RAM_11
  01fcc:    hwop       r4, r8, #0x0
  01fd0:    lsrd       r5, r8, #32
  01fd4:    and        r10, r4, #0x7fffffff
  01fd8:    cbnz       r10, _DUMP_CONST_RAM_11
_DUMP_CONST_RAM_9:
  01fdc:    cbz        r10, _DUMP_CONST_RAM_10
  01fe0:    std        r3, mem[r0, #0x37]
_DUMP_CONST_RAM_10:
  01fe4:    stw        r4, mem[r0, #0x52]
  01fe8:    stw        r5, mem[r0, #0x53]
  01fec:    nop
  01ff0:    nop
  01ff4:    ldd        r3, mem[r0, #0x0]
  01ff8:    nop
  01ffc:    std        r0, mem[r0, #0x37]
  02000:    dw         0x84000801  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x801
  02004:    stw        r3, reg[r12, #0x0]
  02008:    nop
  0200c:    cbnz       r10, _DUMP_CONST_RAM_9
_DUMP_CONST_RAM_11:
  02010:    hwop       r4, r6, #0x0
  02014:    lsrd       r5, r6, #32
  02018:    and        r10, r4, #0x7fffffff
_DUMP_CONST_RAM_12:
  0201c:    cbz        r10, _DUMP_CONST_RAM_13
  02020:    std        r3, mem[r0, #0x37]
_DUMP_CONST_RAM_13:
  02024:    stw        r4, mem[r0, #0x52]
  02028:    stw        r5, mem[r0, #0x53]
  0202c:    nop
  02030:    nop
  02034:    ldd        r2, mem[r0, #0x0]
  02038:    nop
  0203c:    std        r0, mem[r0, #0x37]
  02040:    dw         0x84000801  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x801

PKT_0xf0:
  02044:    ldd        r3, reg[r12, #0x0]
  02048:    nop
  0204c:    nop
  02050:    seteq      r12, r2, r3
  02054:    ldd        r4, reg[r0, #0x4f94]
  02058:    nop
  0205c:    add        r5, r4, #0x1
  02060:    stw        r5, reg[r0, #0x4f94]
  02064:    nop
  02068:    cbnz       r12, _PKT_0x90_1
  0206c:    mov        r14, #0x0

PKT_0x90:
  02070:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  02074:    hwop       r14, r6, #0x0
  02078:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  0207c:    lsrd       r14, r6, #32
  02080:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  02084:    hwop       r14, r2, #0x0
  02088:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  0208c:    cbz        r11, _PKT_0xf0_11
  02090:    hwop       r14, r8, #0x0
  02094:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  02098:    lsrd       r14, r8, #32
  0209c:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  020a0:    hwop       r14, r3, #0x0
_PKT_0x90_0:
  020a4:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  020a8:    b          _PKT_0xf0_2  
_PKT_0x90_1:
  020ac:    addd       r6, r6, #0x4
  020b0:    addd       r8, r8, #0x4
  020b4:    mul        r14, r6, r7
  020b8:    cbnz       r14, _PKT_0x90_2
  020bc:    cbz        r11, _DUMP_CONST_RAM_8
  020c0:    mul        r14, r8, r9
  020c4:    cbnz       r14, _PKT_0x90_2
  020c8:    b          _DUMP_CONST_RAM_5  
_PKT_0x90_2:
  020cc:    mov        r14, #0x1
  020d0:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  020d4:    b          _PKT_0xf0_2  
  020d8:    hwop       r4, r13, #0x0
  020dc:    lsrd       r5, r13, #32
  020e0:    std        r1, mem[r0, #0x43]
  020e4:    std        r4, mem[r0, #0x44]
  020e8:    nop
  020ec:    stw        r4, mem[r0, #0x45]
  020f0:    stw        r14, mem[r0, #0x48]
  020f4:    stw        r0, mem[r0, #0x47]

PKT_0xa0:
  020f8:    stw        r5, mem[r0, #0x46]
  020fc:    addd       r13, r13, #0x4
  02100:    btab

  02104:    lsr        r12, r10, #4
  02108:    cbnz       r12, _PKT_0xa0_0
  0210c:    mov        r12, #0x4f80
  02110:    b          _DUMP_CONST_RAM_12  
  02114:    nop
_PKT_0xa0_0:
  02118:    mov        r12, #0x5100
  0211c:    and        r14, r10, #0xfc007fff
  02120:    hwop       r12, r12, #0x0
  02124:    lsld       r14, r5, #32
  02128:    hwop       r14, r14, #0x20
  0212c:    addd       r14, r14, #0x4
  02130:    hwop       r4, r14, #0x0
  02134:    lsrd       r5, r14, #32
  02138:    and        r10, r4, #0x7fffffff
  0213c:    btab

  02140:    nop
  02144:    lsr        r13, r2, #16
  02148:    and        r14, r13, #0xffffffff
  0214c:    ldd        r11, reg[r0, #0x4a50]
  02150:    and        r12, r11, #0xffffffff
  02154:    hwop       r4, r12, #0x6
  02158:    orr        r3, r4, r0
  0215c:    eor        r2, r3, r0
  02160:    and        r2, r2, #0xfffff001
  02164:    hwop       r5, r1, #0x0
  02168:    std        r2, [r0, #0x81]
  0216c:    b          _PKT_0x90_0  
  02170:    hwop       r3, r1, #0x0
  02174:    stw        r3, mem[r0, #0x52]
  02178:    hwop       r4, r1, #0x0
  0217c:    stw        r4, mem[r0, #0x53]
_PKT_0xa0_1:
  02180:    nop
  02184:    hwop       r5, r1, #0x0
  02188:    ldd        r4, mem[r0, #0x0]
  0218c:    setgt      r2, r4, r5
  02190:    hwop       r5, r1, #0x0
  02194:    ldd        r6, reg[r0, #0x4a14]
  02198:    and        r8, r6, #0xfffff810
  0219c:    cbnz       r8, _PKT_0xa0_2
  021a0:    stw        r5, reg[r0, #0x5b3c]
_PKT_0xa0_2:
  021a4:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  021a8:    stw        r0, [r0, #0x62]
  021ac:    cbz        r2, _PKT_0xa0_5
  021b0:    stw        r5, reg[r0, #0x5ac0]
  021b4:    hwop       r4, r5, #0x0
_PKT_0xa0_3:
  021b8:    ldd        r7, reg[r0, #0x6c]
  021bc:    and        r7, r7, #0xfffffd20
  021c0:    cbnz       r7, _PKT_0xf0_38
  021c4:    hwop       r5, r4, #0x0
  021c8:    ldd        r4, reg[r0, #0x5ac0]
  021cc:    add        r7, r5, r4
  021d0:    cbnz       r7, _PKT_0xa0_3
  021d4:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  021d8:    stw        r0, [r0, #0x62]
  021dc:    ldd        r6, reg[r0, #0x6c]
  021e0:    and        r3, r6, #0xfffff001
  021e4:    cbnz       r3, _PKT_0xf0_38
  021e8:    cbnz       r8, _PKT_0xa0_4
  021ec:    stw        r4, reg[r0, #0x5b3c]
_PKT_0xa0_4:
  021f0:    cbnz       r4, _PKT_0xa0_3
_PKT_0xa0_5:
  021f4:    b          _PKT_0xf0_2  
  021f8:    std        r1, [r0, #0x9b]
_PKT_0xa0_6:
  021fc:    ldd        r12, reg[r0, #0x6c]
  02200:    and        r12, r12, #0xffd30fff
  02204:    cbnz       r12, _PKT_0xf0_38
  02208:    ldd        r3, reg[r0, #0x84]
  0220c:    cbnz       r3, _PKT_0xa0_6
  02210:    lsr        r3, r2, #18
  02214:    stw        r3, [r0, #0xee]
  02218:    lsr        r10, r2, #25
  0221c:    and        r11, r10, #0xffffffff
  02220:    lsr        r10, r2, #16
  02224:    and        r14, r10, #0xfffff001
_PKT_0xa0_7:
  02228:    orr        r3, r11, #0x8
  0222c:    orr        r12, r11, #0x28
  02230:    hwop       r3, r12, #0x7
  02234:    hwop       r14, r3, #0x6
  02238:    orr        r12, r11, #0x48
  0223c:    hwop       r3, r12, #0x7
  02240:    orr        r12, r11, #0x68
  02244:    hwop       r3, r12, #0x7
  02248:    eor        r12, r11, #0x20
  0224c:    lsr        r10, r2, #30
  02250:    and        r9, r10, #0xfffff001
  02254:    hwop       r13, r12, #0x6
_PKT_0xa0_8:
  02258:    hwop       r4, r1, #0x0
  0225c:    hwop       r5, r1, #0x0
  02260:    hwop       r6, r1, #0x0
  02264:    hwop       r7, r1, #0x0
  02268:    hwop       r8, r1, #0x0
  0226c:    hwop       r9, r1, #0x0
  02270:    hwop       r10, r1, #0x0
  02274:    and        r10, r10, #0xffffffff
  02278:    std        r8, [r0, #0x81]
  0227c:    cbz        r11, _PKT_0xb1_1
_PKT_0xa0_9:
  02280:    std        r5, mem[r0, #0x43]
  02284:    stw        r11, mem[r0, #0xa7]
  02288:    stw        r13, mem[r0, #0xa1]
  0228c:    stw        r3, mem[r0, #0xa2]
  02290:    std        r0, mem[r0, #0x47]
  02294:    stw        r4, mem[r0, #0x45]
  02298:    stw        r8, mem[r0, #0xa3]
  0229c:    stw        r9, mem[r0, #0xa9]
  022a0:    stw        r6, mem[r0, #0xa5]
  022a4:    stw        r7, mem[r0, #0xa6]
  022a8:    stw        r4, mem[r0, #0x52]
  022ac:    stw        r5, mem[r0, #0x53]
  022b0:    stw        r5, mem[r0, #0x46]
  022b4:    cbz        r14, _PKT_0xb0_1

PKT_0xb0:
  022b8:    stw        r13, [r0, #0xaa]
  022bc:    stw        r8, [r0, #0xab]
  022c0:    stw        r9, [r0, #0xad]
  022c4:    stw        r0, [r0, #0xae]
  022c8:    ldd        r12, mem[r0, #0x0]
  022cc:    stw        r0, [r0, #0xbd]
  022d0:    lsl        r2, r10, #3
  022d4:    cbz        r12, _PKT_0xb0_0
  022d8:    b          _PKT_0xa0_7  
_PKT_0xb0_0:
  022dc:    ldd        r12, [r0, #0xaf]
  022e0:    cbnz       r12, _PKT_0xb1_0
  022e4:    dw         0x840008a2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x8a2
  022e8:    cbz        r2, _PKT_0xa0_9
  022ec:    sub        r2, r2, #0x1
  022f0:    cbnz       r2, _PKT_0xb0_0
  022f4:    dw         0x840008a2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x8a2
  022f8:    b          _PKT_0xa0_1  
_PKT_0xb0_1:
  022fc:    lsr        r6, r11, #6
  02300:    eor        r7, r6, r0
  02304:    and        r6, r7, #0xfffff001
  02308:    hwop       r8, r6, #0x6
  0230c:    cbz        r8, _PKT_0xb1_1
  02310:    ldd        r6, mem[r0, #0x0]
  02314:    nop
  02318:    ldd        r12, reg[r0, #0x6c]
  0231c:    and        r12, r12, #0xffd30fff
  02320:    cbnz       r12, _PKT_0xb1_3
  02324:    stw        r0, [r0, #0xbd]
  02328:    ldd        r4, reg[r0, #0x4a64]
  0232c:    lsr        r5, r4, #31

PKT_0xb1:
  02330:    and        r4, r5, #0xfffff001
  02334:    cbz        r4, _PKT_0xb1_1
  02338:    dw         0x840008a2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x8a2
  0233c:    mov        r2, #0xd9
  02340:    stw        r2, [r0, #0x50]
  02344:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
  02348:    b          _PKT_0xa0_8  
_PKT_0xb1_0:
  0234c:    mov        r2, #0xda
  02350:    stw        r2, [r0, #0x50]
  02354:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
_PKT_0xb1_1:
  02358:    dw         0x840008a2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x8a2
  0235c:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  02360:    ldd        r6, reg[r0, #0x4a14]
_PKT_0xb1_2:
  02364:    lsr        r3, r6, #13
  02368:    and        r4, r3, #0xfffff001
  0236c:    cbz        r4, _PKT_0xb1_1
  02370:    stw        r0, mem[r0, #0xa2]
  02374:    stw        r0, [r0, #0x77]
  02378:    stw        r0, [r0, #0xee]
  0237c:    stw        r0, [r0, #0x62]
  02380:    stw        r0, [r0, #0x9b]
  02384:    b          _PKT_0xf0_2  
  02388:    ldd        r12, reg[r0, #0x6c]
  0238c:    and        r12, r12, #0xff800fff
  02390:    cbnz       r12, _PKT_0xb1_3
  02394:    ldd        r12, reg[r0, #0x6c]
  02398:    and        r12, r12, #0xfffffd30
  0239c:    cbz        r12, _PKT_0xb1_4
_PKT_0xb1_3:
  023a0:    stw        r0, [r0, #0x77]
  023a4:    stw        r0, [r0, #0xee]
  023a8:    stw        r0, [r0, #0x9b]
  023ac:    b          _PKT_0xf0_28  
_PKT_0xb1_4:
  023b0:    btab

  023b4:    nop
  023b8:    lsr        r7, r2, #16
  023bc:    and        r7, r7, #0xffffc007

PKT_0xc0:
  023c0:    lsr        r6, r2, #30
  023c4:    hwop       r5, r1, #0x0
  023c8:    hwop       r3, r1, #0x0
  023cc:    hwop       r4, r1, #0x0
  023d0:    hwop       r10, r1, #0x0
  023d4:    lsl        r9, r10, r6
  023d8:    hwop       r10, r9, #0x3
  023dc:    mov        r9, #0x1
  023e0:    hwop       r11, r9, #0x3
  023e4:    hwop       r10, r10, #0x0
  023e8:    and        r8, r6, #0x3
  023ec:    ldd        r11, reg[r0, #0x5ba4]
  023f0:    and        r9, r11, #0xfffff011
  023f4:    cbz        r9, _PKT_0xc0_0
  023f8:    nop
  023fc:    ldd        r10, reg[r0, #0xa0]
  02400:    nop
  02404:    ldd        r5, reg[r0, #0xa4]
  02408:    nop
  0240c:    ldd        r3, reg[r0, #0xa8]
_PKT_0xc0_0:
  02410:    stw        r8, mem[r0, #0x43]
  02414:    stw        r10, mem[r0, #0x44]
  02418:    stw        r7, mem[r0, #0x47]
  0241c:    stw        r5, mem[r0, #0x45]
  02420:    stw        r4, mem[r0, #0x48]
  02424:    stw        r3, mem[r0, #0x46]
  02428:    std        r5, [r0, #0x81]
  0242c:    b          _PKT_0xf0_2  
  02430:    hwop       r3, r1, #0x0
  02434:    hwop       r4, r1, #0x0
  02438:    hwop       r5, r1, #0x0
  0243c:    hwop       r6, r1, #0x0
  02440:    hwop       r7, r1, #0x0
  02444:    mov        r9, #0xf884
  02448:    lsl        r9, r9, #2
  0244c:    ldd        r12, reg[r9, #0x0]
  02450:    lsr        r13, r12, #31

PKT_0xc1:
  02454:    cbnz       r13, _PKT_0xc1_1
  02458:    lsld       r8, r6, #32
  0245c:    hwop       r8, r8, #0x20
  02460:    stw        r2, mem[r0, #0xec]
  02464:    cbz        r4, _PKT_0xc1_0
  02468:    std        r3, mem[r0, #0x43]
  0246c:    stw        r7, mem[r0, #0x44]
  02470:    stw        r0, mem[r0, #0x47]
  02474:    stw        r5, mem[r0, #0x45]
  02478:    stw        r0, mem[r0, #0x48]
  0247c:    stw        r6, mem[r0, #0x46]
  02480:    hwop       r8, r8, #0x20
  02484:    hwop       r5, r8, #0x0
  02488:    lsrd       r6, r8, #32
  0248c:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  02490:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  02494:    sub        r4, r4, #0x1
  02498:    b          _PKT_0xb1_2  
_PKT_0xc1_0:
  0249c:    ldd        r10, reg[r0, #0x4a14]
  024a0:    lsr        r11, r10, #25
  024a4:    and        r10, r11, #0xfffff001
  024a8:    cbz        r10, _PKT_0xc1_0
  024ac:    stw        r0, mem[r0, #0xec]
  024b0:    std        r6, [r0, #0x81]
  024b4:    b          _PKT_0xf0_2  
_PKT_0xc1_1:
  024b8:    std        r6, [r0, #0x81]
  024bc:    b          _PKT_0xf0_2  
  024c0:    std        r2, mem[r0, #0x43]
  024c4:    hwop       r3, r1, #0x0
  024c8:    hwop       r4, r1, #0x0
  024cc:    std        r0, mem[r0, #0x47]
  024d0:    stw        r1, mem[r0, #0x49]
  024d4:    stw        r1, mem[r0, #0x4a]
  024d8:    hwop       r5, r1, #0x0
  024dc:    hwop       r6, r1, #0x0
  024e0:    hwop       r7, r1, #0x0
  024e4:    hwop       r8, r1, #0x0
  024e8:    hwop       r9, r1, #0x0
_PKT_0xc1_2:
  024ec:    add        r10, r9, #0x1
  024f0:    lsl        r9, r10, #3
  024f4:    ldd        r11, reg[r0, #0x5ba4]
  024f8:    and        r10, r11, #0xfffff011
  024fc:    cbz        r10, _PKT_0xc1_4
  02500:    nop
  02504:    ldd        r3, reg[r0, #0xa4]
  02508:    nop
  0250c:    ldd        r4, reg[r0, #0xa8]
  02510:    nop
  02514:    ldd        r5, reg[r0, #0xac]
  02518:    nop
_PKT_0xc1_3:
  0251c:    ldd        r6, reg[r0, #0xb0]
  02520:    nop
  02524:    ldd        r9, reg[r0, #0xa0]
_PKT_0xc1_4:
  02528:    stw        r5, mem[r0, #0x4b]
  0252c:    stw        r6, mem[r0, #0x4c]
  02530:    stw        r7, mem[r0, #0x4d]
  02534:    stw        r9, mem[r0, #0x44]
  02538:    nop
  0253c:    stw        r3, mem[r0, #0x45]
  02540:    stw        r8, mem[r0, #0x4e]
  02544:    std        r1, mem[r0, #0x4f]
  02548:    stw        r4, mem[r0, #0x46]
  0254c:    std        r10, [r0, #0x81]
  02550:    b          _PKT_0xf0_2  
  02554:    std        r0, mem[r0, #0x43]
  02558:    lsr        r3, r2, #31
  0255c:    hwop       r9, r1, #0x0
  02560:    hwop       r10, r1, #0x0
  02564:    hwop       r11, r1, #0x0
  02568:    hwop       r12, r1, #0x0
  0256c:    hwop       r4, r1, #0x0
  02570:    hwop       r5, r1, #0x0
  02574:    hwop       r7, r1, #0x0
  02578:    add        r8, r7, #0x1
  0257c:    ldd        r13, reg[r0, #0x5ba4]
  02580:    and        r6, r13, #0xfffff011
  02584:    cbz        r6, _PKT_0xc1_5
  02588:    nop
  0258c:    ldd        r8, reg[r0, #0xa0]
  02590:    nop
  02594:    ldd        r9, reg[r0, #0xac]
  02598:    nop
  0259c:    ldd        r10, reg[r0, #0xb0]
  025a0:    nop
  025a4:    ldd        r11, reg[r0, #0xa4]
  025a8:    nop
  025ac:    ldd        r12, reg[r0, #0xa8]
_PKT_0xc1_5:
  025b0:    stw        r9, mem[r0, #0x52]
  025b4:    stw        r10, mem[r0, #0x53]
  025b8:    stw        r11, mem[r0, #0x2c]
  025bc:    stw        r12, mem[r0, #0x2d]
  025c0:    stw        r0, mem[r0, #0x47]

PKT_0xc3:
  025c4:    lsl        r7, r8, #1
  025c8:    stw        r7, mem[r0, #0x2a]
_PKT_0xc3_0:
  025cc:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  025d0:    ldd        r14, mem[r0, #0x0]
  025d4:    cbnz       r3, _PKT_0xc3_1
  025d8:    nop
  025dc:    hwop       r14, r14, #0x7
  025e0:    b          _PKT_0xc1_2  
  025e4:    nop
_PKT_0xc3_1:
  025e8:    hwop       r14, r14, #0x6
  025ec:    nop
  025f0:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  025f4:    stw        r14, mem[r0, #0x2e]
  025f8:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  025fc:    ldd        r14, mem[r0, #0x0]
  02600:    nop
  02604:    cbnz       r3, _PKT_0xc3_2
  02608:    nop
  0260c:    hwop       r14, r14, #0x7
  02610:    b          _PKT_0xc1_3  
  02614:    nop
_PKT_0xc3_2:
  02618:    hwop       r14, r14, #0x6
  0261c:    nop
  02620:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
_PKT_0xc3_3:
  02624:    stw        r14, mem[r0, #0x2e]
  02628:    ldd        r9, reg[r0, #0x49f0]
  0262c:    lsr        r10, r9, #5
  02630:    and        r11, r10, #0xfffff001
  02634:    cbz        r11, _PKT_0xc3_4
  02638:    ldd        r9, reg[r0, #0x24]
  0263c:    nop
  02640:    and        r10, r9, #0x7fffffff
  02644:    cbnz       r10, _PKT_0xc3_4
  02648:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  0264c:    ldd        r9, reg[r0, #0x6c]
  02650:    nop
  02654:    and        r10, r9, #0xfffff001
  02658:    cbz        r10, _PKT_0xc3_4
  0265c:    nop
  02660:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  02664:    std        r1, mem[r0, #0x2f]
  02668:    b          _PKT_0xf0_12  
  0266c:    nop
_PKT_0xc3_4:
  02670:    sub        r8, r8, #0x1
  02674:    cbnz       r8, _PKT_0xc3_0
  02678:    nop
  0267c:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  02680:    std        r1, mem[r0, #0x2f]
  02684:    std        r8, [r0, #0x81]
  02688:    b          _PKT_0xf0_2  
  0268c:    nop
_PKT_0xc3_5:
  02690:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02694:    mov        r9, #0x4a14
  02698:    ldd        r10, reg[r9, #0x0]
  0269c:    nop
  026a0:    lsr        r9, r10, #13
  026a4:    and        r10, r9, #0xfffff001
  026a8:    cbz        r10, _PKT_0xc3_5
  026ac:    nop
  026b0:    btab

  026b4:    ldd        r15, reg[r0, #0x6c]
  026b8:    and        r15, r15, #0xffd30fff
  026bc:    cbnz       r15, _PKT_0xf0_38
  026c0:    btab

  026c4:    std        r7, [r0, #0x81]
  026c8:    std        r0, mem[r0, #0x43]
  026cc:    lsr        r4, r2, #28
  026d0:    and        r4, r4, #0xffffc007
  026d4:    lsl        r3, r4, #2
  026d8:    hwop       r9, r1, #0x0
  026dc:    hwop       r10, r1, #0x0
  026e0:    hwop       r11, r1, #0x0
  026e4:    hwop       r12, r1, #0x0
  026e8:    hwop       r4, r1, #0x0
  026ec:    lsr        r5, r4, #8
  026f0:    and        r4, r4, #0xffffffff
  026f4:    hwop       r7, r1, #0x0
  026f8:    lsl        r8, r7, #2
  026fc:    stw        r8, reg[r0, #0x4c88]
  02700:    stw        r4, reg[r0, #0x4c80]
  02704:    stw        r5, reg[r0, #0x4c84]
  02708:    lsld       r14, r10, #32
  0270c:    hwop       r10, r14, #0x20
  02710:    lsld       r14, r12, #32
  02714:    hwop       r12, r14, #0x20
  02718:    lsl        r9, r8, #3
  0271c:    hwop       r10, r10, #0x20
  02720:    subd       r11, r10, #0x20
  02724:    hwop       r4, r11, #0x0
  02728:    lsrd       r5, r11, #32
  0272c:    and        r7, r4, #0x7fffffff
  02730:    cbz        r7, _PKT_0xc3_6
  02734:    std        r3, mem[r0, #0x37]
_PKT_0xc3_6:
  02738:    stw        r4, mem[r0, #0x52]
  0273c:    stw        r5, mem[r0, #0x53]

PKT_0xc2:
  02740:    nop
  02744:    nop
  02748:    ldd        r14, mem[r0, #0x0]
  0274c:    nop
  02750:    std        r0, mem[r0, #0x37]
  02754:    dw         0x840009bb  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x9bb
  02758:    mov        r6, #0x1c
  0275c:    add        r6, r6, r3
  02760:    add        r6, r6, r7
  02764:    lsrd       r9, r12, #5
  02768:    lsld       r13, r9, #5
  0276c:    hwop       r13, r13, #0x20
  02770:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  02774:    addd       r11, r11, #0x4
  02778:    addd       r12, r12, #0x4
  0277c:    hwop       r4, r11, #0x0
  02780:    lsrd       r5, r11, #32
  02784:    and        r7, r4, #0x7fffffff
  02788:    std        r3, mem[r0, #0x37]
  0278c:    stw        r4, mem[r0, #0x52]
  02790:    stw        r5, mem[r0, #0x53]
  02794:    nop
  02798:    nop
  0279c:    ldd        r14, mem[r0, #0x0]
  027a0:    nop
  027a4:    std        r0, mem[r0, #0x37]
  027a8:    dw         0x840009bb  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x9bb
  027ac:    mov        r6, #0x1c
  027b0:    hwop       r6, r6, #0x0
  027b4:    add        r6, r6, r7
  027b8:    lsrd       r9, r12, #5
  027bc:    lsld       r13, r9, #5
  027c0:    hwop       r13, r13, #0x20
  027c4:    dw         0x840007f6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7f6
  027c8:    addd       r11, r11, #0x4
  027cc:    addd       r12, r12, #0x4
  027d0:    sub        r8, r8, #0x1
  027d4:    cbz        r8, _PKT_0xf0_11
  027d8:    and        r7, r8, #0xffffc007
  027dc:    cbnz       r7, _PKT_0xc2_0
  027e0:    subd       r11, r11, #0x40
_PKT_0xc2_0:
  027e4:    b          _PKT_0xc3_3  
  027e8:    nop
  027ec:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  027f0:    ldd        r4, reg[r0, #0x4c88]
  027f4:    add        r5, r4, r8
  027f8:    setge      r4, r5, #0x4
  027fc:    cbnz       r4, _PKT_0xc2_1
  02800:    ldd        r4, reg[r0, #0x4c80]
  02804:    lsr        r5, r4, #1
  02808:    stw        r5, reg[r0, #0x4c80]
  0280c:    and        r5, r4, #0xfffff001
  02810:    cbnz       r5, _PKT_0xc2_1
  02814:    mov        r14, #0x0
_PKT_0xc2_1:
  02818:    setgt      r4, r8, #0x4
  0281c:    cbnz       r4, _PKT_0xd0_0
  02820:    ldd        r4, reg[r0, #0x4c84]
  02824:    lsr        r5, r4, #1

PKT_0xd0:
  02828:    stw        r5, reg[r0, #0x4c84]
  0282c:    and        r5, r4, #0xfffff001
  02830:    cbnz       r5, _PKT_0xd0_0
  02834:    mov        r14, #0x0
_PKT_0xd0_0:
  02838:    btab


PKT_0xd1:
  0283c:    nop
  02840:    stw        r2, mem[r0, #0x25]
  02844:    lsr        r4, r2, #23
  02848:    and        r4, r4, #0xfffff001
  0284c:    mov        r9, #0xf884
  02850:    lsl        r9, r9, #2
  02854:    ldd        r12, reg[r9, #0x0]
  02858:    lsr        r13, r12, #31
  0285c:    hwop       r13, r13, #0x6
  02860:    cbnz       r13, _PKT_0xe0_1
  02864:    hwop       r3, r1, #0x0
  02868:    hwop       r4, r1, #0x0

PKT_0xd2:
  0286c:    hwop       r5, r1, #0x0
  02870:    hwop       r6, r1, #0x0
  02874:    hwop       r7, r1, #0x0
  02878:    hwop       r8, r1, #0x0
  0287c:    hwop       r14, r1, #0x0
  02880:    std        r0, mem[r0, #0x43]
  02884:    stw        r0, mem[r0, #0x47]

PKT_0xe0:
  02888:    stw        r3, mem[r0, #0x52]
  0288c:    stw        r4, mem[r0, #0x53]
  02890:    stw        r3, mem[r0, #0x2c]
  02894:    stw        r4, mem[r0, #0x2d]
  02898:    add        r13, r14, #0x1
  0289c:    lsl        r12, r13, #1
  028a0:    stw        r12, mem[r0, #0x2a]
_PKT_0xe0_0:
  028a4:    ldd        r12, mem[r0, #0x0]
  028a8:    nop
  028ac:    eor        r9, r5, r0
  028b0:    hwop       r9, r9, #0x6
  028b4:    hwop       r9, r9, #0x7
  028b8:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  028bc:    stw        r9, mem[r0, #0x2e]
  028c0:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  028c4:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  028c8:    nop
  028cc:    ldd        r12, mem[r0, #0x0]
  028d0:    nop
  028d4:    eor        r9, r6, r0
  028d8:    hwop       r9, r9, #0x6
  028dc:    hwop       r9, r9, #0x7
  028e0:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  028e4:    stw        r9, mem[r0, #0x2e]
  028e8:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  028ec:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  028f0:    sub        r13, r13, #0x1
  028f4:    cbnz       r13, _PKT_0xe0_0
  028f8:    std        r8, [r0, #0x81]
  028fc:    std        r1, mem[r0, #0x2f]
  02900:    b          _PKT_0xf0_2  
_PKT_0xe0_1:
  02904:    std        r8, [r0, #0x81]
  02908:    hwop       r2, r1, #0x0
  0290c:    hwop       r2, r1, #0x0
  02910:    hwop       r2, r1, #0x0
  02914:    hwop       r2, r1, #0x0
  02918:    hwop       r2, r1, #0x0
  0291c:    hwop       r2, r1, #0x0

PKT_0x100:
  02920:    hwop       r2, r1, #0x0
  02924:    b          _PKT_0xf0_2  
  02928:    stw        r2, [r0, #0x5d]
_PKT_0x100_0:
  0292c:    stw        r1, [r0, #0x5e]
  02930:    stw        r1, [r0, #0x5f]
  02934:    std        r3, [r0, #0x81]
  02938:    b          _PKT_0xf0_2  
  0293c:    mov        r3, #0x2
  02940:    lsl        r4, r3, #28

PKT_0x110:
  02944:    ldd        r3, reg[r0, #0x49ec]
  02948:    hwop       r3, r4, #0x7
  0294c:    stw        r3, reg[r0, #0x49ec]
  02950:    std        r4, mem[r0, #0x43]
_PKT_0x110_0:
  02954:    std        r8, mem[r0, #0x44]
  02958:    std        r0, mem[r0, #0x61]
  0295c:    stw        r1, mem[r0, #0x45]
  02960:    stw        r1, mem[r0, #0x46]
  02964:    std        r3, [r0, #0x81]
  02968:    b          _PKT_0xf0_2  
  0296c:    std        r4, mem[r0, #0x43]
  02970:    std        r8, mem[r0, #0x44]
  02974:    std        r1, mem[r0, #0x61]
  02978:    stw        r1, mem[r0, #0x45]
  0297c:    stw        r1, mem[r0, #0x46]
  02980:    std        r3, [r0, #0x81]

PKT_0x1:
  02984:    b          _PKT_0xf0_2  
  02988:    and        r6, r0, #0xfffff800
  0298c:    std        r3, [r0, #0x81]
  02990:    ldd        r12, reg[r0, #0x4a14]
  02994:    and        r14, r12, #0xfffff810
  02998:    lsr        r12, r14, #9
  0299c:    eor        r12, r12, r0
  029a0:    ldd        r13, reg[r0, #0x5aa8]
  029a4:    lsr        r14, r13, #31

PKT_0x4:
  029a8:    hwop       r12, r12, #0x7
  029ac:    ldd        r13, reg[r0, #0x68]
  029b0:    and        r14, r13, #0xffffc007
  029b4:    eor        r13, r14, #0x0
  029b8:    hwop       r12, r12, #0x6
  029bc:    cbnz       r6, _PKT_0x4_0
  029c0:    hwop       r10, r1, #0x0
  029c4:    hwop       r7, r1, #0x0
_PKT_0x4_0:
  029c8:    cbz        r12, _PKT_0x4_2
  029cc:    lsr        r12, r10, #20
  029d0:    std        r3, [r0, #0xd3]
  029d4:    stw        r12, [r0, #0xd5]
  029d8:    stw        r10, [r0, #0x5b]
  029dc:    stw        r7, [r0, #0x5c]
_PKT_0x4_1:
  029e0:    nop
  029e4:    nop
  029e8:    ldd        r10, reg[r0, #0x4a14]
  029ec:    lsr        r12, r10, #14
  029f0:    and        r10, r12, #0xfffff001
  029f4:    cbz        r10, _PKT_0x4_1
  029f8:    nop
  029fc:    cbz        r6, _PKT_0x5_0
  02a00:    btab

_PKT_0x4_2:
  02a04:    stw        r0, [r0, #0x62]
  02a08:    mov        r2, #0xf7

PKT_0x5:
  02a0c:    stw        r2, [r0, #0x50]
  02a10:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
_PKT_0x5_0:
  02a14:    stw        r0, [r0, #0x62]
  02a18:    stw        r0, [r0, #0x7e]
  02a1c:    b          _PKT_0x0_2  
  02a20:    stw        r1, [r0, #0x155]
  02a24:    stw        r1, [r0, #0x156]
  02a28:    stw        r1, [r0, #0x157]
  02a2c:    ldd        r5, [r0, #0x158]
  02a30:    cbz        r5, _PKT_0x0_6
  02a34:    and        r6, r5, #0xfffff001
  02a38:    cbnz       r6, _PKT_0xf0_11
  02a3c:    dw         0x84000a5b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5b
  02a40:    b          _PKT_0x100_0  
  02a44:    stw        r1, [r0, #0x159]
  02a48:    stw        r1, [r0, #0x15a]
  02a4c:    stw        r1, [r0, #0x15b]
  02a50:    stw        r1, [r0, #0x15d]
  02a54:    ldd        r5, [r0, #0x15c]
  02a58:    cbz        r5, _PKT_0x0_6
  02a5c:    and        r6, r5, #0xfffff001
  02a60:    cbnz       r6, _PKT_0xf0_11
  02a64:    dw         0x84000a5b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5b
  02a68:    b          _PKT_0x110_0  
  02a6c:    ldd        r6, reg[r0, #0x4a14]
_PKT_0x5_1:
  02a70:    lsr        r5, r6, #25
  02a74:    and        r6, r5, #0xfffff001
  02a78:    cbz        r6, _PKT_0x5_2
  02a7c:    stw        r0, [r0, #0x62]
_PKT_0x5_2:
  02a80:    btab

  02a84:    std        r0, [r0, #0x100]
  02a88:    std        r1, [r0, #0x9b]
  02a8c:    stw        r0, [r0, #0x30]
  02a90:    nop
  02a94:    nop
  02a98:    stw        r0, [r0, #0x76]
  02a9c:    std        r1, [r0, #0x30]
  02aa0:    stw        r0, [r0, #0x9b]
  02aa4:    b          _PKT_0xf0_2  
  02aa8:    dw         0x84000abb  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xabb
  02aac:    dw         0x84000ac3  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xac3
  02ab0:    dw         0x84000acd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xacd
  02ab4:    hwop       r3, r1, #0x0
  02ab8:    hwop       r3, r1, #0x0
  02abc:    hwop       r3, r1, #0x0
  02ac0:    mov        r3, #0x1
  02ac4:    stw        r2, [r0, #0x101]
  02ac8:    stw        r3, [r0, #0x0]
  02acc:    stw        r1, [r0, #0x1]
  02ad0:    stw        r1, [r0, #0xb]
  02ad4:    stw        r1, [r0, #0x2]
  02ad8:    stw        r1, [r0, #0x3]
  02adc:    stw        r1, [r0, #0x4]
  02ae0:    stw        r1, [r0, #0x5]
  02ae4:    stw        r0, [r0, #0xff]
  02ae8:    hwop       r3, r1, #0x0
  02aec:    hwop       r3, r1, #0x0
  02af0:    hwop       r3, r1, #0x0
  02af4:    hwop       r3, r1, #0x0
  02af8:    dw         0x84000adc  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xadc
  02afc:    stw        r1, [r0, #0x109]
  02b00:    stw        r1, [r0, #0x10a]
  02b04:    std        r1, [r0, #0x10d]
  02b08:    b          _PKT_0xf0_0  
  02b0c:    dw         0x84000abb  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xabb
  02b10:    hwop       r3, r1, #0x0
  02b14:    hwop       r3, r1, #0x0
  02b18:    hwop       r4, r1, #0x0
  02b1c:    lsld       r10, r4, #32
  02b20:    hwop       r5, r10, #0x20
  02b24:    hwop       r3, r1, #0x0
  02b28:    hwop       r4, r1, #0x0
  02b2c:    lsld       r10, r4, #32
  02b30:    hwop       r6, r10, #0x20
  02b34:    hwop       r3, r1, #0x0
  02b38:    hwop       r4, r1, #0x0
  02b3c:    lsld       r10, r4, #32
  02b40:    hwop       r7, r10, #0x20
  02b44:    hwop       r3, r1, #0x0
  02b48:    hwop       r4, r1, #0x0
  02b4c:    lsld       r10, r4, #32
  02b50:    hwop       r8, r10, #0x20
  02b54:    hwop       r3, r1, #0x0
  02b58:    hwop       r4, r1, #0x0
  02b5c:    lsld       r10, r4, #32
  02b60:    hwop       r9, r10, #0x20
  02b64:    hwop       r3, r1, #0x0
  02b68:    hwop       r3, r1, #0x0
  02b6c:    mov        r11, #0x1
  02b70:    hwop       r10, r5, #0x20
  02b74:    dw         0x84000ab2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xab2
  02b78:    cbz        r11, _PKT_0x5_3
  02b7c:    hwop       r10, r6, #0x20
  02b80:    dw         0x84000ab2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xab2
  02b84:    cbz        r11, _PKT_0x5_3
  02b88:    hwop       r10, r7, #0x20
  02b8c:    dw         0x84000ab2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xab2
  02b90:    cbz        r11, _PKT_0x5_3
  02b94:    hwop       r10, r8, #0x20
  02b98:    dw         0x84000ab2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xab2
  02b9c:    cbz        r11, _PKT_0x5_3
  02ba0:    hwop       r10, r9, #0x20
  02ba4:    dw         0x84000ab2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xab2
  02ba8:    cbz        r11, _PKT_0x5_3
  02bac:    b          _PKT_0x5_1  
_PKT_0x5_3:
  02bb0:    dw         0x84000ac3  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xac3
  02bb4:    dw         0x84000acd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xacd
  02bb8:    stw        r1, [r0, #0x109]
  02bbc:    stw        r1, [r0, #0x10a]
  02bc0:    std        r1, [r0, #0x10d]
  02bc4:    b          _PKT_0xf0_2  
  02bc8:    cbz        r10, _PKT_0x5_4
  02bcc:    hwop       r3, r10, #0x0
  02bd0:    lsrd       r4, r10, #32
  02bd4:    stw        r3, mem[r0, #0x52]
  02bd8:    stw        r4, mem[r0, #0x53]
  02bdc:    mov        r10, #0x10
  02be0:    stw        r10, mem[r0, #0x22]
  02be4:    ldd        r11, mem[r0, #0x0]
_PKT_0x5_4:
  02be8:    btab

_PKT_0x5_5:
  02bec:    std        r2, [r0, #0x104]
  02bf0:    lsr        r3, r2, #8
  02bf4:    cbz        r3, _PKT_0x5_6
  02bf8:    ldd        r6, reg[r0, #0x4a14]
  02bfc:    lsr        r3, r6, #25
  02c00:    and        r4, r3, #0xfffff001
  02c04:    cbz        r4, _PKT_0x5_5
_PKT_0x5_6:
  02c08:    btab

  02c0c:    lsr        r3, r2, #9
  02c10:    and        r4, r3, #0xffffc007
  02c14:    orr        r3, r4, #0x2
  02c18:    cbz        r3, _PKT_0x5_8
_PKT_0x5_7:
  02c1c:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02c20:    ldd        r6, reg[r0, #0x4a14]
  02c24:    lsr        r3, r6, #13
  02c28:    and        r4, r3, #0xfffff001
  02c2c:    cbz        r4, _PKT_0x5_7
_PKT_0x5_8:
  02c30:    btab

  02c34:    std        r1, mem[r0, #0x103]
  02c38:    lsr        r3, r2, #11
  02c3c:    and        r4, r3, #0xffffc007
  02c40:    cbz        r4, _PKT_0x5_10
  02c44:    orr        r3, r4, #0x1
  02c48:    cbz        r3, _PKT_0x5_9
  02c4c:    mov        r5, #0x11
  02c50:    stw        r5, mem[r0, #0xdd]
_PKT_0x5_9:
  02c54:    orr        r3, r4, #0x2
  02c58:    cbz        r3, _PKT_0x5_10
  02c5c:    mov        r5, #0x11
  02c60:    stw        r5, mem[r0, #0xde]
  02c64:    mov        r5, #0x10
  02c68:    stw        r5, mem[r0, #0x23]
_PKT_0x5_10:
  02c6c:    btab

  02c70:    lsr        r3, r2, #11
  02c74:    and        r4, r3, #0xffffc007
  02c78:    orr        r3, r4, #0x2
  02c7c:    cbz        r3, _PKT_0x5_12
_PKT_0x5_11:
  02c80:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02c84:    ldd        r6, reg[r0, #0x4a14]
  02c88:    lsr        r3, r6, #25
  02c8c:    and        r4, r3, #0xfffff001
  02c90:    cbz        r4, _PKT_0x5_11
_PKT_0x5_12:
  02c94:    btab

  02c98:    ldd        r4, [r0, #0x10b]
  02c9c:    ldd        r5, [r0, #0x10c]
_PKT_0x5_13:
  02ca0:    ldd        r6, reg[r0, #0x6c]
  02ca4:    and        r3, r6, #0xffd30fff
  02ca8:    cbnz       r3, _PKT_0xf0_38
  02cac:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02cb0:    ldd        r6, reg[r0, #0x4a14]
  02cb4:    lsr        r3, r6, #25
  02cb8:    and        r8, r3, #0xfffff001
  02cbc:    cbz        r8, _PKT_0x5_13
  02cc0:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  02cc4:    std        r5, mem[r0, #0x43]
  02cc8:    mov        r10, #0x10
  02ccc:    stw        r10, mem[r0, #0xa7]

PKT_0xf0:
  02cd0:    std        r0, mem[r0, #0xa1]
  02cd4:    std        r0, mem[r0, #0xa2]
  02cd8:    std        r0, mem[r0, #0x47]
  02cdc:    mov        r6, #0x1
  02ce0:    stw        r4, mem[r0, #0x45]
  02ce4:    std        r0, mem[r0, #0xa3]
  02ce8:    stw        r6, mem[r0, #0xa5]
  02cec:    stw        r0, mem[r0, #0xa6]
  02cf0:    stw        r4, mem[r0, #0x52]
  02cf4:    stw        r5, mem[r0, #0x53]
  02cf8:    stw        r5, mem[r0, #0x46]
  02cfc:    nop
  02d00:    ldd        r10, mem[r0, #0x0]
_PKT_0xf0_0:
  02d04:    stw        r0, [r0, #0xbd]
  02d08:    dw         0x84000964  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x964
  02d0c:    std        r1, [r0, #0x141]
  02d10:    btab

  02d14:    ldd        r3, reg[r0, #0x5a8c]
  02d18:    ldd        r4, reg[r0, #0x5a80]
  02d1c:    lsr        r7, r4, #1
  02d20:    and        r4, r7, #0x7fffffff
  02d24:    mov        r5, #0x1
  02d28:    add        r4, r4, #0x2
  02d2c:    hwop       r7, r5, #0x23
  02d30:    subd       r4, r7, #0x1
_PKT_0xf0_1:
  02d34:    hwop       r8, r3, #0x26
_PKT_0xf0_2:
  02d38:    ldd        r5, reg[r0, #0x5a84]
  02d3c:    ldd        r6, reg[r0, #0x5a88]
  02d40:    lsld       r7, r6, #32
  02d44:    hwop       r6, r5, #0x20
  02d48:    lsld       r5, r6, #8
  02d4c:    hwop       r8, r8, #0x20
  02d50:    hwop       r3, r8, #0x0
  02d54:    lsrd       r4, r8, #32
  02d58:    btab

  02d5c:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
_PKT_0xf0_3:
  02d60:    ldd        r10, reg[r0, #0x49f0]
  02d64:    lsr        r6, r10, #1
  02d68:    and        r10, r6, #0xfffff001
  02d6c:    cbnz       r10, _PKT_0xf0_4
  02d70:    ldd        r6, reg[r0, #0x4a14]
  02d74:    lsr        r3, r6, #13
  02d78:    and        r6, r3, #0xfffff001
  02d7c:    cbz        r6, _PKT_0xf0_3
_PKT_0xf0_4:
  02d80:    std        r1, [r0, #0x100]
  02d84:    std        r1, mem[r0, #0x107]
  02d88:    std        r1, mem[r0, #0x43]
  02d8c:    std        r4, mem[r0, #0x44]
  02d90:    std        r1, [r0, #0x102]
  02d94:    mov        r10, #0x10
  02d98:    stw        r10, mem[r0, #0x23]
  02d9c:    ldd        r3, [r0, #0x10e]
  02da0:    stw        r3, mem[r0, #0x45]
_PKT_0xf0_5:
  02da4:    ldd        r4, [r0, #0x142]
  02da8:    lsr        r5, r4, #8
  02dac:    lsl        r4, r5, #8
  02db0:    add        r5, r4, #0x1
  02db4:    stw        r5, mem[r0, #0x48]
  02db8:    stw        r0, mem[r0, #0x47]
  02dbc:    ldd        r4, [r0, #0x10f]
  02dc0:    stw        r4, mem[r0, #0x46]
  02dc4:    nop
  02dc8:    std        r1, mem[r0, #0x106]
  02dcc:    btab

  02dd0:    b          _PKT_0xf0_2  
  02dd4:    ldd        r14, reg[r0, #0x4a14]
  02dd8:    lsr        r13, r14, #25
  02ddc:    and        r14, r13, #0xfffff001
  02de0:    cbnz       r14, _PKT_0xf0_6
  02de4:    std        r1, [r0, #0x99]
_PKT_0xf0_6:
  02de8:    btab

  02dec:    ldd        r6, reg[r0, #0x4a18]
  02df0:    and        r5, r6, #0xffffffff
  02df4:    orr        r6, r5, #0x3ff
  02df8:    cbnz       r6, _PKT_0xf0_7
  02dfc:    std        r0, [r0, #0x99]
_PKT_0xf0_7:
  02e00:    btab

_PKT_0xf0_8:
  02e04:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02e08:    ldd        r6, reg[r0, #0x98]
  02e0c:    cbnz       r6, _PKT_0xf0_8
  02e10:    nop
  02e14:    ldd        r6, reg[r0, #0x5ba8]
  02e18:    cbz        r6, _PKT_0xf0_11
  02e1c:    std        r0, reg[r0, #0x5ba8]
_PKT_0xf0_9:
  02e20:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02e24:    ldd        r4, reg[r0, #0x4a14]
  02e28:    lsr        r3, r4, #25
  02e2c:    and        r4, r3, #0xfffff001
  02e30:    cbz        r4, _PKT_0xf0_9
_PKT_0xf0_10:
  02e34:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
_PKT_0xf0_11:
  02e38:    ldd        r3, reg[r0, #0xc8]
  02e3c:    cbz        r3, _PKT_0xf0_13
  02e40:    stw        r0, [r0, #0xc2]
  02e44:    ldd        r6, [r0, #0xc9]
  02e48:    cbnz       r6, _PKT_0xf0_14
  02e4c:    stw        r0, [r0, #0xc7]
  02e50:    and        r4, r3, #0xfffff001
  02e54:    cbnz       r4, _INDIRECT_BUFFER_END_2
  02e58:    and        r4, r3, #0xffffe003
  02e5c:    cbnz       r4, _DISPATCH_DIRECT_0
  02e60:    and        r4, r3, #0xffff800f
  02e64:    cbnz       r4, _SET_BASE_11
  02e68:    and        r4, r3, #0xfff800ff
_PKT_0xf0_12:
  02e6c:    cbnz       r4, _DISPATCH_INDIRECT_0
  02e70:    and        r4, r3, #0xf800ffff
  02e74:    cbnz       r4, _REG_RMW_2
_PKT_0xf0_13:
  02e78:    ldd        r6, reg[r0, #0x70]
  02e7c:    cbz        r6, _PKT_0xf0_14
  02e80:    nop
  02e84:    ldd        r4, reg[r0, #0x4a14]
  02e88:    and        r10, r4, #0xfffff880
  02e8c:    cbz        r10, _PKT_0xf0_14
  02e90:    stw        r0, [r0, #0x105]
  02e94:    b          _PKT_0x0_4  
_PKT_0xf0_14:
  02e98:    dw         0x84000b35  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xb35
  02e9c:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  02ea0:    dw         0x840011c3  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11c3
_PKT_0xf0_15:
  02ea4:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  02ea8:    ldd        r5, reg[r0, #0x6c]
  02eac:    and        r3, r5, #0xffd30fff
  02eb0:    cbnz       r3, _PKT_0xf0_38
  02eb4:    dw         0x840013cc  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13cc
  02eb8:    and        r6, r2, #0xffffffff
  02ebc:    and        r6, r6, #0x1
  02ec0:    cbnz       r6, _PKT_0xf0_19
  02ec4:    ldd        r5, reg[r0, #0x49f0]
  02ec8:    lsr        r3, r5, #17
  02ecc:    and        r4, r3, #0xfffff001
  02ed0:    cbz        r4, _PKT_0xf0_19
  02ed4:    mov        r14, #0x0
  02ed8:    ldd        r14, reg[r0, #0x7c]
  02edc:    and        r10, r14, #0xfc007fff
  02ee0:    sub        r14, r10, #0x1
  02ee4:    cbnz       r14, _PKT_0xf0_19
  02ee8:    ldd        r6, reg[r0, #0x4a14]
  02eec:    lsr        r3, r6, #25
  02ef0:    and        r4, r3, #0xfffff001
  02ef4:    cbnz       r4, _PKT_0xf0_19
  02ef8:    ldd        r6, reg[r0, #0x5ba4]
  02efc:    and        r4, r6, #0xfffff001
  02f00:    cbz        r4, _PKT_0xf0_19
  02f04:    mov        r12, #0x4a2c
  02f08:    stw        r12, [r0, #0x6b]
  02f0c:    stw        r0, [r0, #0x64]
  02f10:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
_PKT_0xf0_16:
  02f14:    ldd        r6, reg[r12, #0x0]
  02f18:    and        r10, r6, #0xfffff801
  02f1c:    cbz        r10, _PKT_0xf0_16
  02f20:    mov        r6, #0x8
_PKT_0xf0_17:
  02f24:    sub        r6, r6, #0x1
  02f28:    cbnz       r6, _PKT_0xf0_17
  02f2c:    ldd        r6, reg[r0, #0x6c]
  02f30:    and        r6, r6, #0xfffffd20
  02f34:    cbnz       r6, _PKT_0xf0_38
  02f38:    stw        r0, [r0, #0x30]
  02f3c:    nop
  02f40:    nop
  02f44:    nop
  02f48:    nop
  02f4c:    nop
  02f50:    stw        r0, [r0, #0x6b]
  02f54:    std        r1, [r0, #0x30]
  02f58:    mov        r14, #0x0
  02f5c:    ldd        r14, reg[r0, #0x7c]
  02f60:    and        r10, r14, #0xfc007fff
_PKT_0xf0_18:
  02f64:    sub        r14, r10, #0x1
  02f68:    cbz        r14, _PKT_0xf0_146
_PKT_0xf0_19:
  02f6c:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  02f70:    ldd        r4, reg[r0, #0x6c]
  02f74:    and        r6, r4, #0xffffffff
  02f78:    cbz        r6, _PKT_0xf0_27
  02f7c:    and        r6, r4, #0xfffff001
  02f80:    cbz        r6, _PKT_0xf0_20
  02f84:    stw        r0, [r0, #0xfd]
_PKT_0xf0_20:
  02f88:    and        r6, r2, #0xffffffff
  02f8c:    and        r3, r6, #0x1
  02f90:    cbnz       r3, _PKT_0xf0_21
  02f94:    and        r4, r2, #0xfffff880
  02f98:    cbnz       r4, _PKT_0xf0_27
  02f9c:    and        r4, r2, #0xfffffff8
  02fa0:    cbnz       r4, _PKT_0xf0_24
  02fa4:    lsr        r3, r2, #25
  02fa8:    and        r3, r3, #0xfffff001
  02fac:    cbz        r3, _PKT_0xf0_24
  02fb0:    b          _PKT_0xf0_18  
_PKT_0xf0_21:
  02fb4:    and        r3, r6, #0x2
  02fb8:    cbnz       r3, _PKT_0xf0_22
  02fbc:    lsr        r4, r2, #31
  02fc0:    and        r4, r4, #0xfffff001
  02fc4:    cbz        r4, _PKT_0xf0_24
  02fc8:    b          _PKT_0xf0_18  
_PKT_0xf0_22:
  02fcc:    and        r3, r6, #0xb
  02fd0:    cbz        r3, _PKT_0xf0_23
  02fd4:    and        r3, r6, #0xc
  02fd8:    cbz        r3, _PKT_0xf0_23
  02fdc:    b          _PKT_0xf0_18  
_PKT_0xf0_23:
  02fe0:    and        r6, r2, #0xffffffff
  02fe4:    and        r3, r6, #0x10c
  02fe8:    cbz        r3, _PKT_0xf0_24
  02fec:    ldd        r4, reg[r0, #0xa0]
  02ff0:    lsr        r3, r4, #9
  02ff4:    cbz        r3, _PKT_0xf0_27
_PKT_0xf0_24:
  02ff8:    ldd        r5, reg[r0, #0x49f0]
  02ffc:    and        r4, r5, #0xfffff809
  03000:    cbz        r4, _PKT_0xf0_27
  03004:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  03008:    ldd        r6, reg[r0, #0x6c]
  0300c:    and        r3, r6, #0xffffc007
  03010:    cbz        r3, _PKT_0xf0_27
  03014:    ldd        r6, reg[r0, #0x4a14]
  03018:    lsr        r3, r6, #25
  0301c:    and        r4, r3, #0xfffff001
  03020:    cbz        r4, _PKT_0xf0_25
  03024:    b          _PKT_0xf0_40  
_PKT_0xf0_25:
  03028:    dw         0x84000d2a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd2a
  0302c:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  03030:    ldd        r6, reg[r0, #0x6c]
  03034:    and        r3, r6, #0xfffff001
  03038:    ldd        r6, reg[r0, #0x5ba4]
  0303c:    and        r4, r6, #0xfffff001
  03040:    cbnz       r4, _PKT_0xf0_26
  03044:    cbnz       r3, _PKT_0xf0_51
  03048:    b          _PKT_0xf0_5  
_PKT_0xf0_26:
  0304c:    and        r4, r6, #0xfffff808
  03050:    cbz        r4, _PKT_0xf0_15
  03054:    b          _PKT_0xf0_40  
  03058:    mov        r2, #0xf0
  0305c:    stw        r2, [r0, #0x50]
  03060:    b          _PKT_0xf0_87  
_PKT_0xf0_27:
  03064:    dw         0x84000b3b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xb3b
  03068:    ldd        r6, reg[r0, #0x4a14]
  0306c:    lsr        r3, r6, #25
_PKT_0xf0_28:
  03070:    and        r4, r3, #0xfffff001
  03074:    cbz        r4, _PKT_0xf0_11
  03078:    stw        r0, [r0, #0x9b]
  0307c:    std        r0, [r0, #0xee]
_PKT_0xf0_29:
  03080:    ldd        r10, reg[r0, #0x5b50]
  03084:    and        r6, r10, #0xfffff001
  03088:    cbz        r6, _PKT_0xf0_33
  0308c:    ldd        r10, reg[r0, #0x4afc]
  03090:    and        r6, r10, #0xfffff001
  03094:    cbnz       r6, _PKT_0xf0_31
_PKT_0xf0_30:
  03098:    dw         0x84000ae6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xae6
_PKT_0xf0_31:
  0309c:    ldd        r10, reg[r0, #0x4afc]
  030a0:    and        r6, r10, #0xffffe003
  030a4:    cbnz       r6, _PKT_0xf0_32
  030a8:    dw         0x84000b17  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xb17
  030ac:    ldd        r10, reg[r0, #0x4afc]
  030b0:    and        r6, r10, #0xfffff001
  030b4:    cbz        r6, _PKT_0xf0_30
  030b8:    ldd        r10, reg[r0, #0x4afc]
  030bc:    and        r6, r10, #0xffffe003
  030c0:    cbz        r6, _PKT_0xf0_31
_PKT_0xf0_32:
  030c4:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  030c8:    ldd        r6, reg[r0, #0x4a14]
  030cc:    lsr        r3, r6, #25
  030d0:    and        r4, r3, #0xfffff001
  030d4:    cbz        r4, _PKT_0xf0_29
  030d8:    stw        r0, [r0, #0x77]
_PKT_0xf0_33:
  030dc:    ldd        r3, reg[r0, #0x4a60]
  030e0:    lsr        r3, r3, #16
  030e4:    and        r4, r3, #0xffffffff
  030e8:    orr        r3, r4, #0x10
  030ec:    cbz        r3, _PKT_0xf0_34
  030f0:    stw        r0, [r0, #0x77]
_PKT_0xf0_34:
  030f4:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  030f8:    ldd        r4, reg[r0, #0x6c]
  030fc:    and        r3, r4, #0xfffff001
  03100:    cbz        r3, _PKT_0xf0_36
  03104:    ldd        r3, reg[r0, #0x4a60]
  03108:    lsr        r3, r3, #16
  0310c:    and        r4, r3, #0xffffffff
  03110:    and        r3, r4, #0x103
  03114:    cbz        r3, _PKT_0xf0_37
_PKT_0xf0_35:
  03118:    and        r3, r4, #0x203
  0311c:    cbz        r3, _PKT_0xf0_37
  03120:    and        r3, r4, #0x303
  03124:    cbz        r3, _PKT_0xf0_37
_PKT_0xf0_36:
  03128:    ldd        r3, reg[r0, #0x4a14]
  0312c:    and        r3, r3, #0xfffff820
  03130:    cbnz       r3, _PKT_0xf0_37
  03134:    stw        r0, [r0, #0x62]
  03138:    stw        r0, [r0, #0x105]
  0313c:    stw        r0, [r0, #0x62]
_PKT_0xf0_37:
  03140:    stw        r0, [r0, #0xfd]
  03144:    stw        r0, [r0, #0x7e]
  03148:    dw         0x84000db2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdb2
  0314c:    ldd        r6, reg[r0, #0x4a14]
  03150:    nop
  03154:    and        r10, r6, #0xfffff810
  03158:    cbz        r10, _PKT_0xf0_38
  0315c:    nop
  03160:    ldd        r6, reg[r0, #0x80]
  03164:    nop
  03168:    cbnz       r6, _PKT_0xf0_121
  0316c:    nop
_PKT_0xf0_38:
  03170:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  03174:    ldd        r6, reg[r0, #0x6c]
  03178:    and        r6, r6, #0xffffffff
  0317c:    cbz        r6, _PKT_0xf0_57
  03180:    std        r1, [r0, #0x99]
  03184:    std        r1, [r0, #0xfd]
  03188:    dw         0x84000d42  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd42
  0318c:    ldd        r6, reg[r0, #0x6c]
  03190:    and        r3, r6, #0xffff800f
  03194:    cbz        r3, _PKT_0xf0_41
  03198:    mov        r2, #0xf2
  0319c:    stw        r2, [r0, #0x50]
  031a0:    mov        r4, #0x80
_PKT_0xf0_39:
  031a4:    sub        r4, r4, #0x1
_PKT_0xf0_40:
  031a8:    cbnz       r4, _PKT_0xf0_39
  031ac:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  031b0:    std        r0, [r0, #0xca]
  031b4:    std        r0, [r0, #0xcb]
  031b8:    mov        r4, #0x4
  031bc:    stw        r4, [r0, #0x65]
  031c0:    mov        r2, #0xffff
  031c4:    b          _PKT_0xf0_87  
_PKT_0xf0_41:
  031c8:    ldd        r6, reg[r0, #0x6c]
  031cc:    and        r3, r6, #0xfff800ff
  031d0:    cbz        r3, _PKT_0xf0_42
  031d4:    mov        r2, #0xdc
  031d8:    stw        r2, [r0, #0x50]
  031dc:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  031e0:    mov        r4, #0x3
  031e4:    stw        r4, [r0, #0x65]
  031e8:    mov        r2, #0xffff
  031ec:    b          _PKT_0xf0_87  
_PKT_0xf0_42:
  031f0:    ldd        r6, reg[r0, #0x6c]
  031f4:    and        r3, r6, #0xfffffa00
  031f8:    cbz        r3, _PKT_0xf0_43
  031fc:    mov        r2, #0xe4
  03200:    stw        r2, [r0, #0x50]
  03204:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  03208:    mov        r4, #0x3
  0320c:    stw        r4, [r0, #0x65]
  03210:    mov        r2, #0xffff
  03214:    b          _PKT_0xf0_87  
_PKT_0xf0_43:
  03218:    ldd        r6, reg[r0, #0x6c]
  0321c:    and        r3, r6, #0xfffff820
  03220:    cbz        r3, _PKT_0xf0_46
  03224:    ldd        r6, reg[r0, #0x49f0]
  03228:    and        r6, r6, #0xfffff804
_PKT_0xf0_44:
  0322c:    cbz        r6, _PKT_0xf0_45
  03230:    mov        r2, #0xdd
  03234:    stw        r2, [r0, #0x50]
_PKT_0xf0_45:
  03238:    mov        r2, #0xffff
  0323c:    mov        r4, #0x5
  03240:    stw        r4, [r0, #0x65]
  03244:    b          _PKT_0xf0_44  
_PKT_0xf0_46:
  03248:    ldd        r6, reg[r0, #0x6c]
  0324c:    and        r3, r6, #0xfffffc00
  03250:    cbz        r3, _PKT_0xf0_49
  03254:    ldd        r6, reg[r0, #0x49f0]
  03258:    and        r6, r6, #0xfffff804
  0325c:    cbz        r6, _PKT_0xf0_47
  03260:    mov        r2, #0xde
  03264:    stw        r2, [r0, #0x50]
_PKT_0xf0_47:
  03268:    mov        r2, #0xffff
  0326c:    mov        r4, #0x5
  03270:    stw        r4, [r0, #0x65]
_PKT_0xf0_48:
  03274:    b          _PKT_0xf0_44  
_PKT_0xf0_49:
  03278:    ldd        r6, reg[r0, #0x6c]
  0327c:    and        r3, r6, #0xfffff900
  03280:    cbz        r3, _PKT_0xf0_51
  03284:    ldd        r6, reg[r0, #0x49f0]
  03288:    and        r6, r6, #0xfffff804
  0328c:    cbz        r6, _PKT_0xf0_50
  03290:    mov        r2, #0xdf
  03294:    stw        r2, [r0, #0x50]
_PKT_0xf0_50:
  03298:    mov        r2, #0xffff
  0329c:    mov        r4, #0x5
  032a0:    stw        r4, [r0, #0x65]
  032a4:    b          _PKT_0xf0_44  
_PKT_0xf0_51:
  032a8:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  032ac:    ldd        r6, reg[r0, #0x6c]
  032b0:    and        r3, r6, #0xfffff001
  032b4:    cbz        r3, _PKT_0xf0_54
  032b8:    ldd        r6, reg[r0, #0x4ab0]
  032bc:    lsr        r3, r6, #21
  032c0:    and        r6, r3, #0xfffff001
  032c4:    cbz        r6, _PKT_0xf0_54
  032c8:    ldd        r14, reg[r0, #0x4af8]
  032cc:    lsr        r13, r14, #31
  032d0:    and        r14, r14, #0xfffff001
  032d4:    hwop       r13, r14, #0x6
  032d8:    cbnz       r13, _PKT_0xf0_96
  032dc:    ldd        r6, reg[r0, #0x4a14]
_PKT_0xf0_52:
  032e0:    and        r3, r6, #0xfffff808
  032e4:    cbz        r3, _PKT_0xf0_53
  032e8:    ldd        r6, reg[r0, #0x5abc]
  032ec:    cbnz       r6, _PKT_0xf0_53
  032f0:    ldd        r13, reg[r0, #0x5a8c]
  032f4:    ldd        r14, reg[r0, #0x5a94]
  032f8:    seteq      r4, r13, r14
  032fc:    cbz        r4, _PKT_0xf0_53
  03300:    std        r0, [r0, #0xca]
  03304:    std        r0, [r0, #0xcb]
  03308:    b          _PKT_0xf0_59  
_PKT_0xf0_53:
  0330c:    mov        r2, #0xf0
  03310:    stw        r2, [r0, #0x50]
  03314:    b          _PKT_0xf0_87  
_PKT_0xf0_54:
  03318:    ldd        r6, reg[r0, #0x6c]
  0331c:    and        r3, r6, #0xfffff880
  03320:    cbz        r3, _PKT_0xf0_55
  03324:    std        r1, [r0, #0x95]
  03328:    b          _PKT_0xf0_87  
  0332c:    std        r1, [r0, #0x95]
  03330:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  03334:    b          _PKT_0xf0_87  
_PKT_0xf0_55:
  03338:    ldd        r6, reg[r0, #0x6c]
  0333c:    and        r3, r6, #0xffffe003
  03340:    cbnz       r3, _PKT_0xf0_56
  03344:    stw        r0, [r0, #0x99]
  03348:    stw        r0, [r0, #0xfd]
  0334c:    b          _PKT_0xf0_48  
_PKT_0xf0_56:
  03350:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  03354:    ldd        r3, reg[r0, #0x84]
  03358:    cbnz       r3, _PKT_0xf0_56
  0335c:    ldd        r6, reg[r0, #0x4a14]
  03360:    lsr        r3, r6, #13
  03364:    and        r4, r3, #0xfffff001
  03368:    cbz        r4, _PKT_0xf0_11
  0336c:    mov        r2, #0xcdef
  03370:    b          _PKT_0xf0_87  
_PKT_0xf0_57:
  03374:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  03378:    dw         0x840013b8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13b8
  0337c:    dw         0x840011c3  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11c3
  03380:    ldd        r3, reg[r0, #0x5a80]
  03384:    and        r6, r3, #0xfffff001
  03388:    cbnz       r6, _PKT_0xf0_58
  0338c:    and        r6, r2, #0xffffffff
  03390:    and        r6, r6, #0x3
  03394:    cbz        r6, _PKT_0xf0_61
  03398:    ldd        r6, reg[r0, #0x4a10]
  0339c:    and        r3, r6, #0xffffffff
  033a0:    and        r6, r3, #0x3
  033a4:    cbz        r6, _PKT_0xf0_61
_PKT_0xf0_58:
  033a8:    ldd        r3, reg[r0, #0x4bcc]
  033ac:    lsr        r6, r3, #16
  033b0:    and        r6, r6, #0xfffff001
  033b4:    cbz        r6, _PKT_0xf0_60
  033b8:    ldd        r3, reg[r0, #0x5b44]
  033bc:    lsr        r6, r3, #7
  033c0:    and        r6, r6, #0xfffff001
  033c4:    cbz        r6, _PKT_0xf0_61
  033c8:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  033cc:    ldd        r3, reg[r0, #0x5b44]
  033d0:    and        r4, r3, #0x7fffffff
  033d4:    stw        r4, reg[r0, #0x5b44]
_PKT_0xf0_59:
  033d8:    b          _PKT_0xf0_52  
_PKT_0xf0_60:
  033dc:    dw         0x84000db2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdb2
_PKT_0xf0_61:
  033e0:    ldd        r6, reg[r0, #0x5abc]
  033e4:    cbz        r6, _PKT_0xf0_64
  033e8:    ldd        r6, reg[r0, #0x5aa8]
  033ec:    and        r3, r6, #0xfffff001
  033f0:    cbz        r3, _PKT_0xf0_63
  033f4:    stw        r0, [r0, #0x9b]
  033f8:    stw        r0, [r0, #0xfd]
  033fc:    stw        r0, [r0, #0x9a]
  03400:    ldd        r3, reg[r0, #0x5ab0]
  03404:    cbz        r3, _PKT_0xf0_62
  03408:    ldd        r4, reg[r0, #0x4a0c]
  0340c:    cbnz       r4, _PKT_0xf0_62
  03410:    nop
  03414:    stw        r0, [r0, #0x85]
_PKT_0xf0_62:
  03418:    b          _COPY_DATA_6  
_PKT_0xf0_63:
  0341c:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  03420:    b          _PKT_0xf0_48  
_PKT_0xf0_64:
  03424:    ldd        r6, reg[r0, #0x4a14]
  03428:    and        r3, r6, #0xfffff808
  0342c:    cbz        r3, _PKT_0x0_1
  03430:    stw        r0, [r0, #0x99]
  03434:    ldd        r3, reg[r0, #0x5a80]
  03438:    nop
  0343c:    and        r6, r3, #0xfffff001
  03440:    cbnz       r6, _PKT_0xf0_65
  03444:    ldd        r13, reg[r0, #0x5a8c]
  03448:    ldd        r14, reg[r0, #0x5a94]
  0344c:    seteq      r4, r13, r14
  03450:    cbz        r4, _PKT_0xf0_65
  03454:    ldd        r10, reg[r0, #0x5ac4]
  03458:    lsr        r9, r10, #9
  0345c:    and        r10, r9, #0xfffff001
  03460:    cbnz       r10, _PKT_0xf0_67
  03464:    ldd        r6, reg[r0, #0xfc]
  03468:    cbnz       r6, _PKT_0xf0_197
_PKT_0xf0_65:
  0346c:    ldd        r6, reg[r0, #0x5a9c]
  03470:    and        r4, r6, #0xfffff001
  03474:    cbz        r4, _PKT_0xf0_66
  03478:    ldd        r6, reg[r0, #0x4a14]
  0347c:    and        r3, r6, #0xfffff840
  03480:    cbz        r3, _PKT_0xf0_10
_PKT_0xf0_66:
  03484:    ldd        r6, reg[r0, #0x4a14]
  03488:    and        r3, r6, #0xfffff840
  0348c:    cbnz       r3, _PKT_0xf0_67
  03490:    ldd        r3, reg[r0, #0x5a80]
  03494:    and        r6, r3, #0xfffff001
  03498:    cbz        r6, _PKT_0xf0_10
  0349c:    ldd        r3, reg[r0, #0x5b44]
  034a0:    orr        r6, r3, #0x1
  034a4:    stw        r6, reg[r0, #0x5b44]
  034a8:    ldd        r6, reg[r0, #0x5a9c]
  034ac:    nop
  034b0:    and        r4, r6, #0xfffff001
  034b4:    cbz        r4, _PKT_0xf0_67
  034b8:    nop
  034bc:    ldd        r6, reg[r0, #0x4a14]
  034c0:    and        r3, r6, #0xfffff840
  034c4:    cbnz       r3, _PKT_0xf0_67
  034c8:    ldd        r6, reg[r0, #0x5a9c]
  034cc:    and        r4, r6, #0xfffff001
  034d0:    cbnz       r4, _PKT_0xf0_11
  034d4:    b          _PKT_0xf0_1  
_PKT_0xf0_67:
  034d8:    std        r1, [r0, #0xfa]
  034dc:    ldd        r10, reg[r0, #0x5ac4]
  034e0:    lsr        r9, r10, #9
  034e4:    and        r10, r9, #0xfffff001
  034e8:    cbz        r10, _PKT_0xf0_68
  034ec:    std        r1, [r0, #0xca]
  034f0:    std        r0, [r0, #0xfa]
  034f4:    b          _PKT_0xf0_2  
_PKT_0xf0_68:
  034f8:    std        r1, [r0, #0x9b]
  034fc:    std        r1, [r0, #0xfd]
  03500:    ldd        r6, reg[r0, #0x49f0]
  03504:    lsr        r3, r6, #28
  03508:    and        r3, r3, #0xfffff001
  0350c:    ldd        r6, reg[r0, #0x5ac4]
  03510:    and        r4, r6, #0xfffff804
  03514:    cbz        r3, _PKT_0xf0_69
  03518:    mov        r2, #0xf3
  0351c:    stw        r2, [r0, #0x50]
  03520:    dw         0x840011c3  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11c3
  03524:    std        r0, [r0, #0xca]
  03528:    ldd        r6, reg[r0, #0x68]
  0352c:    nop
  03530:    sub        r3, r6, #0x1
  03534:    cbnz       r3, _PKT_0xf0_96
  03538:    std        r1, [r0, #0x93]
  0353c:    b          _PKT_0xf0_87  
_PKT_0xf0_69:
  03540:    cbnz       r4, _PKT_0xf0_96
  03544:    stw        r0, [r0, #0x9b]
  03548:    stw        r0, [r0, #0xfd]
  0354c:    dw         0x84001396  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1396
  03550:    b          _PKT_0xf0_1  
  03554:    ldd        r14, reg[r0, #0x4a2c]
  03558:    and        r14, r14, #0xf800ffff
  0355c:    cbz        r14, _PKT_0xf0_74
_PKT_0xf0_70:
  03560:    ldd        r14, reg[r0, #0x4a18]
  03564:    and        r14, r14, #0xfffff808
  03568:    cbz        r14, _PKT_0xf0_70
  0356c:    stw        r0, [r0, #0x64]
_PKT_0xf0_71:
  03570:    ldd        r14, reg[r0, #0x4a2c]
  03574:    and        r14, r14, #0xfffff801
  03578:    cbz        r14, _PKT_0xf0_71
  0357c:    ldd        r14, reg[r0, #0x49f0]
  03580:    lsr        r10, r14, #29
  03584:    and        r14, r10, #0xfffff001
_PKT_0xf0_72:
  03588:    cbz        r14, _PKT_0xf0_73
  0358c:    mov        r2, #0xf5
  03590:    stw        r2, [r0, #0x50]
  03594:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
_PKT_0xf0_73:
  03598:    ldd        r14, reg[r0, #0x4a2c]
  0359c:    and        r14, r14, #0xf800ffff
  035a0:    cbnz       r14, _PKT_0xf0_73
_PKT_0xf0_74:
  035a4:    btab

  035a8:    and        r6, r2, #0xffffffff
  035ac:    and        r3, r6, #0x1
  035b0:    lsr        r6, r2, #28
  035b4:    and        r6, r6, #0xfffc007f
  035b8:    and        r4, r6, #0x7
  035bc:    hwop       r6, r3, #0x0
  035c0:    cbnz       r6, _PKT_0xf0_77
  035c4:    ldd        r14, reg[r0, #0x49f0]
  035c8:    mov        r3, #0x1
  035cc:    lsl        r5, r3, #5
  035d0:    eor        r5, r5, r0
  035d4:    hwop       r6, r5, #0x6
  035d8:    stw        r6, reg[r0, #0x49f0]
_PKT_0xf0_75:
  035dc:    ldd        r15, reg[r0, #0x6c]
  035e0:    nop
  035e4:    and        r15, r15, #0xffd30fff
  035e8:    cbnz       r15, _PKT_0xf0_76
  035ec:    nop
  035f0:    ldd        r6, reg[r0, #0x4a14]
  035f4:    lsr        r3, r6, #25
  035f8:    and        r4, r3, #0xfffff001
  035fc:    cbz        r4, _PKT_0xf0_75
_PKT_0xf0_76:
  03600:    stw        r14, reg[r0, #0x49f0]
_PKT_0xf0_77:
  03604:    btab

  03608:    mov        r10, #0x0
  0360c:    ldd        r14, reg[r0, #0x6c]
  03610:    nop
  03614:    and        r10, r14, #0xf800ffff
  03618:    cbz        r10, _PKT_0xf0_78
  0361c:    mov        r2, #0xf4
  03620:    stw        r2, [r0, #0x50]
  03624:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
  03628:    stw        r0, [r0, #0x166]
_PKT_0xf0_78:
  0362c:    btab

  03630:    stw        r0, [r0, #0x60]
  03634:    nop
  03638:    nop
  0363c:    nop
  03640:    nop
_PKT_0xf0_79:
  03644:    ldd        r14, reg[r0, #0x4a14]
  03648:    nop
  0364c:    lsr        r10, r14, #24
  03650:    and        r6, r10, #0xfffff802
  03654:    cbz        r6, _PKT_0xf0_79
  03658:    and        r6, r10, #0xffffe003
  0365c:    cbz        r6, _PKT_0xf0_80
  03660:    dw         0x84000d81  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd81
_PKT_0xf0_80:
  03664:    sub        r3, r2, #0xf0
  03668:    cbz        r3, _PKT_0xf0_81
  0366c:    sub        r3, r2, #0xf2
  03670:    cbz        r3, _PKT_0xf0_81
  03674:    sub        r3, r2, #0xf3
  03678:    cbz        r3, _PKT_0xf0_81
  0367c:    b          _PKT_0xf0_72  
_PKT_0xf0_81:
  03680:    std        r0, [r0, #0xca]
  03684:    std        r0, [r0, #0xcb]
  03688:    dw         0x84000d65  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd65
  0368c:    btab

  03690:    nop
  03694:    ldd        r6, reg[r0, #0x4a2c]
  03698:    mov        r3, #0x2
  0369c:    eor        r4, r3, r0
  036a0:    hwop       r5, r4, #0x6
  036a4:    nop
  036a8:    stw        r5, reg[r0, #0x4a2c]
  036ac:    nop
  036b0:    btab

  036b4:    ldd        r14, reg[r0, #0x4ab0]
  036b8:    lsr        r13, r14, #25
  036bc:    and        r13, r13, #0xfffff001
  036c0:    cbz        r13, _PKT_0xf0_82
  036c4:    ldd        r14, reg[r0, #0x5a80]
  036c8:    lsr        r13, r14, #1
  036cc:    lsl        r14, r13, #1
  036d0:    stw        r14, reg[r0, #0x5a80]
_PKT_0xf0_82:
  036d4:    btab

  036d8:    ldd        r14, reg[r0, #0x4a2c]
  036dc:    and        r14, r14, #0xffffe003
  036e0:    cbz        r14, _PKT_0xf0_83
  036e4:    ldd        r15, reg[r0, #0x4a14]
  036e8:    lsr        r15, r15, #25
  036ec:    and        r15, r15, #0xfffff001
  036f0:    cbz        r15, _PKT_0xf0_83
  036f4:    mov        r2, #0xf0
  036f8:    stw        r2, [r0, #0x50]
  036fc:    b          _PKT_0xf0_87  
_PKT_0xf0_83:
  03700:    btab

  03704:    ldd        r3, reg[r0, #0x4a60]
  03708:    lsr        r6, r3, #16
  0370c:    and        r6, r6, #0xffffffff
  03710:    and        r3, r6, #0x1
  03714:    cbz        r3, _PKT_0xf0_84
  03718:    stw        r0, [r0, #0x77]
_PKT_0xf0_84:
  0371c:    btab

  03720:    ldd        r14, reg[r0, #0x5b44]
  03724:    orr        r13, r14, #0x2
  03728:    stw        r13, reg[r0, #0x5b44]
  0372c:    btab

  03730:    ldd        r14, reg[r0, #0x5b44]
  03734:    mov        r13, #0x1
  03738:    lsl        r13, r13, #6
  0373c:    eor        r3, r13, r0
  03740:    hwop       r4, r14, #0x6
  03744:    stw        r4, reg[r0, #0x5b44]
  03748:    btab

  0374c:    stw        r0, [r0, #0x9a]
  03750:    stw        r0, [r0, #0x9b]
  03754:    stw        r0, [r0, #0x99]
  03758:    stw        r0, [r0, #0xfd]
  0375c:    btab

  03760:    stw        r0, [r0, #0x69]
_PKT_0xf0_85:
  03764:    ldd        r10, reg[r0, #0x4a18]
  03768:    lsr        r6, r10, #16
  0376c:    and        r6, r6, #0xfffff001
  03770:    cbnz       r6, _PKT_0xf0_85
  03774:    nop
  03778:    btab

  0377c:    stw        r0, [r0, #0x76]
  03780:    stw        r0, [r0, #0x75]
  03784:    ldd        r6, reg[r0, #0x5abc]
  03788:    cbz        r6, _PKT_0xf0_86
  0378c:    stw        r0, [r0, #0x42]
  03790:    stw        r0, [r0, #0x85]
_PKT_0xf0_86:
  03794:    std        r0, [r0, #0xed]
  03798:    ldd        r6, reg[r0, #0x5b00]
  0379c:    stw        r6, reg[r0, #0x5b00]
  037a0:    ldd        r6, reg[r0, #0x5b08]
  037a4:    stw        r6, reg[r0, #0x5b08]
  037a8:    ldd        r6, reg[r0, #0x5b0c]
  037ac:    stw        r6, reg[r0, #0x5b0c]
  037b0:    ldd        r6, reg[r0, #0x5b10]
  037b4:    stw        r6, reg[r0, #0x5b10]
_PKT_0xf0_87:
  037b8:    ldd        r6, reg[r0, #0x5b14]
  037bc:    stw        r6, reg[r0, #0x5b14]
  037c0:    nop
  037c4:    btab

  037c8:    ldd        r3, reg[r0, #0x4bcc]
  037cc:    lsr        r6, r3, #16
  037d0:    and        r6, r6, #0xfffff001
  037d4:    cbz        r6, _PKT_0xf0_88
  037d8:    btab

_PKT_0xf0_88:
  037dc:    ldd        r3, reg[r0, #0x5b44]
  037e0:    and        r6, r3, #0xfffff803
  037e4:    and        r6, r6, #0x20
  037e8:    cbz        r6, _PKT_0xf0_89
  037ec:    btab

_PKT_0xf0_89:
  037f0:    ldd        r3, reg[r0, #0x5b44]
  037f4:    orr        r4, r3, #0x4
  037f8:    stw        r4, reg[r0, #0x5b44]
  037fc:    btab

  03800:    mov        r14, #0x0
  03804:    ldd        r14, reg[r0, #0x7c]
  03808:    and        r10, r14, #0xfc007fff
  0380c:    cbz        r10, _PKT_0xf0_90
  03810:    setne      r14, r10, #0x4
  03814:    cbnz       r14, _PKT_0xf0_154
_PKT_0xf0_90:
  03818:    btab

  0381c:    ldd        r14, reg[r0, #0x4a2c]
  03820:    and        r14, r14, #0xffffe003
  03824:    cbnz       r14, _PKT_0xf0_91
  03828:    and        r3, r2, #0xffffffff
  0382c:    and        r6, r3, #0xffff
  03830:    cbnz       r6, _PKT_0xf0_92
_PKT_0xf0_91:
  03834:    btab

_PKT_0xf0_92:
  03838:    ldd        r5, reg[r0, #0x6c]
  0383c:    and        r3, r5, #0xffd20fff
  03840:    cbnz       r3, _PKT_0xf0_38
  03844:    btab

  03848:    orr        r6, r2, #0xcdef
  0384c:    cbz        r6, _PKT_0xf0_93
  03850:    ldd        r3, reg[r0, #0x4a14]
  03854:    and        r6, r3, #0xfffff810
  03858:    cbnz       r6, _PKT_0xf0_93
  0385c:    ldd        r3, reg[r0, #0x5a8c]
  03860:    ldd        r6, reg[r0, #0x5a94]
  03864:    seteq      r5, r3, r6
  03868:    cbz        r5, _PKT_0xf0_93
  0386c:    nop
  03870:    mov        r2, #0xf3
  03874:    stw        r2, [r0, #0x50]
_PKT_0xf0_93:
  03878:    btab

  0387c:    ldd        r6, reg[r0, #0x4a60]
  03880:    lsr        r7, r6, #16
  03884:    and        r6, r7, #0xffffffff
  03888:    orr        r7, r6, #0x2
  0388c:    cbz        r7, _PKT_0xf0_95
  03890:    ldd        r6, reg[r0, #0x4a14]
  03894:    lsr        r7, r6, #25
  03898:    and        r6, r7, #0xfffff001
  0389c:    cbz        r6, _PKT_0xf0_95
  038a0:    ldd        r6, reg[r0, #0x5ba4]
_PKT_0xf0_94:
  038a4:    mov        r7, #0x101
  038a8:    eor        r8, r7, r0
  038ac:    hwop       r6, r8, #0x6
  038b0:    stw        r6, reg[r0, #0x5ba4]
_PKT_0xf0_95:
  038b4:    btab

_PKT_0xf0_96:
  038b8:    std        r0, [r0, #0xee]
  038bc:    ldd        r3, reg[r0, #0x5b44]
  038c0:    and        r6, r3, #0xffffffff
  038c4:    stw        r6, reg[r0, #0x5b44]
_PKT_0xf0_97:
  038c8:    std        r1, [r0, #0x9b]
  038cc:    mov        r12, #0x4a2c
  038d0:    stw        r12, [r0, #0x6b]
  038d4:    stw        r0, [r0, #0x64]
_PKT_0xf0_98:
  038d8:    orr        r6, r2, #0xe5
  038dc:    cbnz       r6, _PKT_0xf0_99
  038e0:    dw         0x84000dc7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc7
_PKT_0xf0_99:
  038e4:    ldd        r6, reg[r12, #0x0]
  038e8:    and        r3, r6, #0xfffff801
  038ec:    cbz        r3, _PKT_0xf0_98
  038f0:    stw        r0, mem[r0, #0xec]
  038f4:    dw         0x84000ddf  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xddf
  038f8:    dw         0x84000dd2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdd2
  038fc:    mov        r3, #0x8
_PKT_0xf0_100:
  03900:    sub        r3, r3, #0x1
  03904:    cbnz       r3, _PKT_0xf0_100
  03908:    dw         0x84000dc7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc7
  0390c:    stw        r0, [r0, #0x30]
_PKT_0xf0_101:
  03910:    ldd        r5, reg[r0, #0x5ac0]
  03914:    nop
  03918:    ldd        r6, reg[r0, #0x5ac0]
  0391c:    nop
  03920:    seteq      r3, r5, r6
  03924:    cbz        r3, _PKT_0xf0_101
  03928:    std        r1, [r0, #0xfa]
  0392c:    nop
  03930:    nop
  03934:    stw        r0, [r0, #0x76]
  03938:    stw        r0, [r0, #0x75]
  0393c:    std        r0, [r0, #0xed]
  03940:    ldd        r6, reg[r0, #0x5ab0]
  03944:    stw        r6, reg[r0, #0x4a0c]
  03948:    ldd        r6, reg[r0, #0x5b00]
  0394c:    stw        r6, reg[r0, #0x5b00]
  03950:    ldd        r6, reg[r0, #0x5b08]
  03954:    stw        r6, reg[r0, #0x5b08]
  03958:    ldd        r6, reg[r0, #0x5b0c]
  0395c:    stw        r6, reg[r0, #0x5b0c]
  03960:    ldd        r6, reg[r0, #0x5b10]
  03964:    stw        r6, reg[r0, #0x5b10]
  03968:    ldd        r6, reg[r0, #0x5b14]
  0396c:    stw        r6, reg[r0, #0x5b14]
  03970:    std        r0, [r0, #0xfa]
  03974:    nop
  03978:    orr        r13, r2, #0xffff
  0397c:    cbnz       r13, _PKT_0xf0_103
  03980:    orr        r14, r2, #0xe5
  03984:    cbz        r14, _PKT_0xf0_102
  03988:    std        r0, reg[r0, #0x4acc]
  0398c:    b          _PKT_0xf0_94  
_PKT_0xf0_102:
  03990:    ldd        r14, reg[r0, #0x4af8]
  03994:    lsr        r13, r14, #31
  03998:    and        r14, r14, #0xfffff001
  0399c:    hwop       r13, r14, #0x6
  039a0:    cbnz       r13, _PKT_0xf0_104
_PKT_0xf0_103:
  039a4:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
  039a8:    nop
_PKT_0xf0_104:
  039ac:    stw        r0, [r0, #0x6b]
  039b0:    std        r1, [r0, #0x30]
  039b4:    ldd        r3, reg[r0, #0x5b44]
  039b8:    orr        r6, r3, #0x0
  039bc:    stw        r6, reg[r0, #0x5b44]
  039c0:    dw         0x84000dc7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc7
  039c4:    std        r1, [r0, #0xfd]
  039c8:    ldd        r14, reg[r0, #0x4af8]
  039cc:    lsr        r13, r14, #31
  039d0:    and        r14, r14, #0xfffff001
  039d4:    hwop       r13, r14, #0x6
  039d8:    cbz        r13, _PKT_0xf0_108
_PKT_0xf0_105:
  039dc:    ldd        r14, reg[r0, #0x4a14]
  039e0:    lsr        r13, r14, #25
  039e4:    and        r14, r13, #0xfffff001
  039e8:    cbz        r14, _PKT_0xf0_105
  039ec:    mov        r13, #0x1
  039f0:    lsl        r13, r13, #30
  039f4:    ldd        r14, reg[r0, #0x4af8]
_PKT_0xf0_106:
  039f8:    hwop       r14, r14, #0x7
  039fc:    stw        r14, reg[r0, #0x4af8]
  03a00:    mov        r6, #0x100
_PKT_0xf0_107:
  03a04:    ldd        r14, reg[r0, #0x4af8]
  03a08:    nop
  03a0c:    lsr        r13, r14, #31
  03a10:    cbnz       r13, _PKT_0xf0_107
  03a14:    std        r1, [r0, #0x174]
  03a18:    std        r1, [r0, #0x175]
  03a1c:    std        r1, [r0, #0x176]
  03a20:    std        r1, [r0, #0x177]
  03a24:    mov        r13, #0x1
  03a28:    lsl        r13, r13, #30
  03a2c:    eor        r13, r13, r0
  03a30:    hwop       r14, r13, #0x6
  03a34:    stw        r14, reg[r0, #0x4af8]
  03a38:    nop
  03a3c:    std        r1, [r0, #0x178]
  03a40:    mov        r13, #0x1
  03a44:    lsl        r13, r13, #8
  03a48:    eor        r13, r13, r0
  03a4c:    ldd        r14, reg[r0, #0x49f0]
  03a50:    hwop       r14, r13, #0x6
  03a54:    nop
  03a58:    std        r0, [r0, #0xca]
_PKT_0xf0_108:
  03a5c:    ldd        r6, reg[r0, #0x5a80]
  03a60:    and        r3, r6, #0xfffff001
  03a64:    cbnz       r3, _PKT_0xf0_109
  03a68:    ldd        r6, reg[r0, #0x5ac4]
  03a6c:    and        r3, r6, #0xfffff810
  03a70:    cbz        r3, _PKT_0xf0_109
  03a74:    ldd        r6, reg[r0, #0x5aa8]
  03a78:    and        r3, r6, #0xfffff001
  03a7c:    ldd        r4, reg[r0, #0x5b44]
  03a80:    lsl        r5, r3, #8
  03a84:    hwop       r4, r5, #0x7
  03a88:    stw        r4, reg[r0, #0x5b44]
  03a8c:    lsr        r3, r6, #1
  03a90:    lsl        r3, r3, #1
  03a94:    stw        r3, reg[r0, #0x5aa8]
_PKT_0xf0_109:
  03a98:    ldd        r6, reg[r0, #0x4a14]
  03a9c:    and        r3, r6, #0xfffff808
  03aa0:    cbnz       r3, _PKT_0xf0_110
  03aa4:    ldd        r6, reg[r0, #0x4ab0]
  03aa8:    lsr        r4, r6, #25
  03aac:    and        r4, r4, #0xfffff001
  03ab0:    cbz        r4, _PKT_0xf0_113
_PKT_0xf0_110:
  03ab4:    ldd        r6, reg[r0, #0x6c]
  03ab8:    and        r4, r6, #0xffd20fff
  03abc:    cbnz       r4, _PKT_0xf0_38
  03ac0:    and        r4, r6, #0xfffff001
  03ac4:    cbz        r4, _PKT_0xf0_111
  03ac8:    sub        r6, r2, #0xf0
  03acc:    cbnz       r6, _PKT_0xf0_38
_PKT_0xf0_111:
  03ad0:    stw        r0, [r0, #0x65]
  03ad4:    ldd        r4, reg[r0, #0x5ac4]
  03ad8:    orr        r3, r4, #0x8
  03adc:    stw        r3, reg[r0, #0x5ac4]
  03ae0:    mov        r3, #0x0
_PKT_0xf0_112:
  03ae4:    add        r3, r3, #0x1
  03ae8:    setge      r4, r3, #0x2
  03aec:    cbz        r4, _PKT_0xf0_112
  03af0:    nop
  03af4:    std        r1, [r0, #0x95]
_PKT_0xf0_113:
  03af8:    stw        r0, [r0, #0x6b]
  03afc:    std        r1, [r0, #0x30]
  03b00:    stw        r0, [r0, #0x93]
_PKT_0xf0_114:
  03b04:    add        r3, r3, #0x1
  03b08:    setge      r4, r3, #0x2
  03b0c:    cbz        r4, _PKT_0xf0_114
  03b10:    std        r0, [r0, #0xfd]
  03b14:    stw        r0, [r0, #0x99]
  03b18:    stw        r0, reg[r0, #0x5ac4]
  03b1c:    ldd        r6, reg[r0, #0x7c]
  03b20:    and        r5, r6, #0xf800ffff
  03b24:    cbnz       r5, _PKT_0xf0_144
  03b28:    ldd        r5, reg[r0, #0x4a2c]
  03b2c:    and        r3, r5, #0xf001ffff
  03b30:    cbnz       r3, _PKT_0xf0_11
  03b34:    nop
  03b38:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  03b3c:    dw         0x84000d42  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd42
  03b40:    dw         0x840013cc  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13cc
  03b44:    ldd        r5, reg[r0, #0x5a94]
  03b48:    ldd        r3, reg[r0, #0x5a8c]
  03b4c:    seteq      r6, r5, r3
  03b50:    cbz        r6, _PKT_0xf0_115
  03b54:    ldd        r5, reg[r0, #0x5a9c]
  03b58:    and        r3, r5, #0xffff800f
  03b5c:    cbnz       r3, _PKT_0xf0_115
  03b60:    ldd        r5, reg[r0, #0x5ac4]
  03b64:    and        r3, r5, #0xfffff810
  03b68:    cbnz       r3, _PKT_0xf0_115
  03b6c:    ldd        r13, reg[r0, #0x5a8c]
  03b70:    ldd        r14, reg[r0, #0x5a94]
  03b74:    seteq      r4, r13, r14
  03b78:    cbz        r4, _PKT_0xf0_115
  03b7c:    ldd        r14, reg[r0, #0x6c]
  03b80:    and        r10, r14, #0xf800ffff
  03b84:    cbnz       r10, _PKT_0xf0_113
  03b88:    ldd        r6, reg[r0, #0xfc]
  03b8c:    cbnz       r6, _PKT_0xf0_197
_PKT_0xf0_115:
  03b90:    ldd        r6, reg[r0, #0x5aa8]
  03b94:    and        r3, r6, #0xfffff001
  03b98:    cbz        r3, _PKT_0xf0_116
  03b9c:    ldd        r4, reg[r0, #0x5abc]
  03ba0:    cbz        r4, _PKT_0xf0_116
  03ba4:    and        r3, r6, #0xfffff808
  03ba8:    cbnz       r3, _PKT_0xf0_116
  03bac:    ldd        r4, reg[r0, #0x5ac4]
  03bb0:    and        r3, r4, #0xfffff810
  03bb4:    cbz        r3, _PKT_0xf0_116
  03bb8:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  03bbc:    b          _PKT_0xf0_2  
_PKT_0xf0_116:
  03bc0:    ldd        r4, reg[r0, #0x5a80]
  03bc4:    and        r3, r4, #0xfffff001
  03bc8:    cbz        r3, _PKT_0xf0_113
  03bcc:    mov        r2, #0x0
  03bd0:    dw         0x84000d81  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd81
  03bd4:    ldd        r4, reg[r0, #0x5b44]
  03bd8:    lsr        r3, r4, #8
  03bdc:    and        r3, r3, #0xfffff001
  03be0:    ldd        r6, reg[r0, #0x5aa8]
  03be4:    hwop       r6, r6, #0x7
  03be8:    stw        r6, reg[r0, #0x5aa8]
  03bec:    stw        r0, [r0, #0xfd]
  03bf0:    stw        r0, [r0, #0x9b]
  03bf4:    stw        r0, [r0, #0x85]
_PKT_0xf0_117:
  03bf8:    stw        r0, [r0, #0x9a]
  03bfc:    stw        r0, [r0, #0x99]
  03c00:    stw        r0, [r0, #0xfd]
  03c04:    ldd        r6, reg[r0, #0x4ab0]
  03c08:    lsr        r4, r6, #25
  03c0c:    and        r4, r4, #0xfffff001
  03c10:    cbnz       r4, _PKT_0xf0_118
  03c14:    std        r1, [r0, #0xf2]
  03c18:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  03c1c:    b          _PKT_0xf0_2  
_PKT_0xf0_118:
  03c20:    ldd        r6, reg[r0, #0x5abc]
  03c24:    cbz        r6, _PKT_0xf0_119
  03c28:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  03c2c:    b          _COPY_DATA_6  
_PKT_0xf0_119:
  03c30:    ldd        r6, reg[r0, #0x4a14]
  03c34:    and        r3, r6, #0xffff800f
  03c38:    cbnz       r3, _PKT_0xf0_120
  03c3c:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  03c40:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  03c44:    b          _PKT_0x0_0  
_PKT_0xf0_120:
  03c48:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  03c4c:    ldd        r6, reg[r0, #0x6c]
  03c50:    and        r3, r6, #0x7fffffff
  03c54:    cbnz       r3, _PKT_0xf0_38
  03c58:    ldd        r5, reg[r0, #0x5ac4]
  03c5c:    and        r6, r5, #0xfffff804
  03c60:    cbnz       r6, _PKT_0xf0_109
  03c64:    dw         0x84001396  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1396
  03c68:    b          _PKT_0xf0_106  
_PKT_0xf0_121:
  03c6c:    ldd        r3, reg[r0, #0x5b30]
  03c70:    ldd        r4, reg[r0, #0x5b34]
  03c74:    hwop       r6, r3, #0x7
  03c78:    cbz        r6, _PKT_0xf0_38
  03c7c:    stw        r0, mem[r0, #0xe5]
  03c80:    stw        r0, mem[r0, #0xe6]
  03c84:    ldd        r6, reg[r0, #0x84]
  03c88:    cbnz       r6, _PKT_0xf0_121
  03c8c:    stw        r0, [r0, #0xc7]
  03c90:    ldd        r6, reg[r0, #0x4a14]
  03c94:    and        r10, r6, #0xfffff810
  03c98:    cbz        r10, _PKT_0xf0_123
  03c9c:    stw        r0, [r0, #0x77]
  03ca0:    lsld       r6, r4, #32
  03ca4:    hwop       r6, r6, #0x20
  03ca8:    mov        r9, #0x5ab0
  03cac:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03cb0:    mov        r9, #0x5b00
  03cb4:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03cb8:    mov        r9, #0x5b04
  03cbc:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03cc0:    mov        r9, #0x5b08
  03cc4:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03cc8:    mov        r9, #0x5b0c
  03ccc:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03cd0:    mov        r9, #0x5b10
  03cd4:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03cd8:    mov        r9, #0x5b14
  03cdc:    dw         0x84000fa8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfa8
  03ce0:    ldd        r6, reg[r0, #0x5abc]
  03ce4:    ldd        r4, reg[r0, #0xdc]
  03ce8:    add        r7, r6, r4
  03cec:    lsl        r5, r4, #2
  03cf0:    stw        r5, reg[r0, #0x5ab0]
  03cf4:    stw        r7, reg[r0, #0x5ac0]
_PKT_0xf0_122:
  03cf8:    ldd        r6, reg[r0, #0x6c]
  03cfc:    and        r10, r6, #0xffffd30f
  03d00:    cbnz       r10, _PKT_0xf0_38
  03d04:    nop
  03d08:    ldd        r4, reg[r0, #0x5ac0]
  03d0c:    cbnz       r4, _PKT_0xf0_122
  03d10:    std        r1, [r0, #0x8b]
  03d14:    ldd        r6, reg[r0, #0x4a14]
  03d18:    and        r10, r6, #0xfffff810
  03d1c:    cbz        r10, _PKT_0xf0_123
  03d20:    ldd        r6, reg[r0, #0x5abc]
  03d24:    cbz        r6, _PKT_0xf0_123
  03d28:    ldd        r4, reg[r0, #0xdc]
  03d2c:    cbz        r4, _PKT_0xf0_123
  03d30:    add        r7, r6, r4
  03d34:    lsl        r5, r4, #2
  03d38:    stw        r5, reg[r0, #0x5ab0]
  03d3c:    stw        r7, reg[r0, #0x5ac0]
  03d40:    b          _PKT_0xf0_117  
_PKT_0xf0_123:
  03d44:    std        r1, [r0, #0x82]
  03d48:    nop
_PKT_0xf0_124:
  03d4c:    ldd        r4, reg[r0, #0x5ac0]
  03d50:    nop
  03d54:    cbnz       r4, _PKT_0xf0_124
  03d58:    ldd        r6, reg[r0, #0x49f0]
  03d5c:    lsr        r3, r6, #30
  03d60:    and        r6, r3, #0xfffff001
  03d64:    cbz        r6, _PKT_0xf0_125
  03d68:    mov        r2, #0xdb
  03d6c:    stw        r2, [r0, #0x50]
  03d70:    dw         0x84000d4c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd4c
_PKT_0xf0_125:
  03d74:    std        r0, [r0, #0x83]
  03d78:    stw        r0, reg[r0, #0x5b3c]
  03d7c:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  03d80:    nop
  03d84:    b          _PKT_0xf0_18  
  03d88:    std        r1, [r0, #0x99]
  03d8c:    std        r1, [r0, #0x9a]
  03d90:    std        r1, [r0, #0x9b]
  03d94:    hwop       r7, r6, #0x0
  03d98:    lsrd       r8, r6, #32
  03d9c:    stw        r7, mem[r0, #0x52]
  03da0:    stw        r8, mem[r0, #0x53]
  03da4:    nop
  03da8:    mov        r10, #0x10
  03dac:    stw        r10, mem[r0, #0x22]
  03db0:    ldd        r5, mem[r0, #0x0]
  03db4:    std        r0, [r0, #0x99]
  03db8:    std        r0, [r0, #0x9a]
  03dbc:    std        r0, [r0, #0x9b]
  03dc0:    std        r0, [r0, #0xfd]
  03dc4:    ldd        r11, reg[r0, #0x6c]
  03dc8:    and        r11, r11, #0xffd30fff
  03dcc:    cbnz       r11, _PKT_0xf0_38
  03dd0:    stw        r5, reg[r9, #0x0]
  03dd4:    addd       r6, r6, #0x4
  03dd8:    std        r0, [r0, #0x99]
  03ddc:    btab

  03de0:    hwop       r7, r6, #0x0
  03de4:    lsrd       r8, r6, #32
  03de8:    and        r10, r7, #0x7fffffff
  03dec:    cbnz       r10, _PKT_0xf0_126
  03df0:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
_PKT_0xf0_126:
  03df4:    cbz        r10, _PKT_0xf0_127
  03df8:    mov        r10, #0x3
_PKT_0xf0_127:
  03dfc:    stw        r10, mem[r0, #0x37]
  03e00:    stw        r7, mem[r0, #0x52]
  03e04:    stw        r8, mem[r0, #0x53]
  03e08:    nop
  03e0c:    nop
  03e10:    ldd        r5, mem[r0, #0x0]
  03e14:    cbz        r10, _PKT_0xf0_128
  03e18:    mov        r10, #0x0
  03e1c:    stw        r10, mem[r0, #0x37]
_PKT_0xf0_128:
  03e20:    stw        r5, reg[r9, #0x0]
  03e24:    addd       r6, r6, #0x4
  03e28:    btab

  03e2c:    hwop       r7, r6, #0x0
  03e30:    lsrd       r8, r6, #32
  03e34:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  03e38:    stw        r7, mem[r0, #0x52]
  03e3c:    stw        r8, mem[r0, #0x53]
  03e40:    nop
  03e44:    nop
  03e48:    ldd        r5, mem[r0, #0x0]
  03e4c:    nop
  03e50:    nop
  03e54:    lsr        r10, r9, #2
  03e58:    ldd        r7, reg[r0, #0x4a60]
  03e5c:    and        r7, r7, #0xffffc007
  03e60:    cbz        r7, _PKT_0xf0_129
  03e64:    nop
  03e68:    nop
  03e6c:    add        r10, r10, #0x600
_PKT_0xf0_129:
  03e70:    std        r3, [r0, #0xd3]
  03e74:    std        r15, [r0, #0xd1]
  03e78:    stw        r10, [r0, #0x5b]
  03e7c:    stw        r5, [r0, #0x5c]
  03e80:    btab

_PKT_0xf0_130:
  03e84:    hwop       r7, r6, #0x0
  03e88:    lsrd       r8, r6, #32
  03e8c:    and        r10, r7, #0x7fffffff
  03e90:    cbnz       r10, _PKT_0xf0_131
  03e94:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
_PKT_0xf0_131:
  03e98:    cbz        r10, _PKT_0xf0_132
  03e9c:    mov        r10, #0x3
_PKT_0xf0_132:
  03ea0:    stw        r10, mem[r0, #0x37]
  03ea4:    stw        r7, mem[r0, #0x52]
  03ea8:    stw        r8, mem[r0, #0x53]
  03eac:    nop
  03eb0:    nop
  03eb4:    ldd        r5, mem[r0, #0x0]
  03eb8:    cbz        r10, _PKT_0xf0_133
  03ebc:    mov        r10, #0x0
  03ec0:    stw        r10, mem[r0, #0x37]
_PKT_0xf0_133:
  03ec4:    std        r3, [r0, #0xd3]
  03ec8:    std        r2, [r0, #0xcd]
  03ecc:    stw        r0, [r0, #0xd5]
  03ed0:    stw        r9, [r0, #0x5b]
  03ed4:    stw        r5, [r0, #0x5c]
  03ed8:    addd       r6, r6, #0x4
  03edc:    add        r9, r9, #0x1
_PKT_0xf0_134:
  03ee0:    nop
  03ee4:    ldd        r10, reg[r0, #0x4a14]
  03ee8:    nop
  03eec:    lsr        r7, r10, #14
  03ef0:    and        r10, r7, #0xfffff001
  03ef4:    cbz        r10, _PKT_0xf0_134
  03ef8:    nop
  03efc:    sub        r3, r3, #0x1
  03f00:    cbnz       r3, _PKT_0xf0_130
  03f04:    nop
  03f08:    btab

  03f0c:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  03f10:    nop
  03f14:    ldd        r9, reg[r0, #0x6c]
  03f18:    and        r9, r9, #0xffd30fff
  03f1c:    cbnz       r9, _PKT_0xf0_38
  03f20:    hwop       r14, r6, #0x0
  03f24:    lsrd       r9, r6, #32
  03f28:    std        r1, mem[r0, #0x43]
  03f2c:    std        r4, mem[r0, #0x44]
  03f30:    nop
  03f34:    stw        r14, mem[r0, #0x45]
  03f38:    stw        r0, mem[r0, #0x47]
  03f3c:    stw        r5, mem[r0, #0x48]
  03f40:    stw        r9, mem[r0, #0x46]
  03f44:    addd       r6, r6, #0x4
  03f48:    btab

  03f4c:    and        r8, r6, #0x7fffffff
  03f50:    orr        r7, r8, #0x1c
  03f54:    cbz        r7, _PKT_0xf0_135
  03f58:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  03f5c:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  03f60:    nop
_PKT_0xf0_135:
  03f64:    hwop       r7, r6, #0x0
  03f68:    lsrd       r8, r6, #32
  03f6c:    ldd        r5, reg[r9, #0x0]
  03f70:    std        r1, mem[r0, #0x43]
  03f74:    stw        r7, mem[r0, #0x39]
  03f78:    stw        r5, mem[r0, #0x3b]
  03f7c:    stw        r8, mem[r0, #0x3a]
  03f80:    and        r8, r6, #0x7fffffff
  03f84:    orr        r7, r8, #0x1c
  03f88:    cbz        r7, _PKT_0xf0_136
  03f8c:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  03f90:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  03f94:    nop
_PKT_0xf0_136:
  03f98:    addd       r6, r6, #0x4
  03f9c:    btab

  03fa0:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  03fa4:    nop
  03fa8:    std        r1, [r0, #0xfd]
  03fac:    hwop       r7, r6, #0x0
  03fb0:    lsrd       r8, r6, #32
  03fb4:    ldd        r5, reg[r9, #0x0]
  03fb8:    std        r1, mem[r0, #0x43]
  03fbc:    std        r4, mem[r0, #0x44]
  03fc0:    mov        r10, #0x10
  03fc4:    stw        r10, mem[r0, #0x23]
  03fc8:    stw        r7, mem[r0, #0x45]
  03fcc:    stw        r5, mem[r0, #0x48]
  03fd0:    stw        r0, mem[r0, #0x47]
  03fd4:    stw        r8, mem[r0, #0x46]
  03fd8:    addd       r6, r6, #0x4
  03fdc:    std        r0, [r0, #0xfd]
  03fe0:    btab

_PKT_0xf0_137:
  03fe4:    std        r3, [r0, #0xd3]
  03fe8:    std        r2, [r0, #0xcd]
  03fec:    ldd        r5, unk[r9, #0x0]
  03ff0:    nop
  03ff4:    nop
  03ff8:    and        r8, r6, #0x7fffffff
  03ffc:    orr        r7, r8, #0x1c
  04000:    cbz        r7, _PKT_0xf0_138
  04004:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04008:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
_PKT_0xf0_138:
  0400c:    hwop       r7, r6, #0x0
  04010:    lsrd       r8, r6, #32
  04014:    std        r1, mem[r0, #0x43]
  04018:    stw        r7, mem[r0, #0x39]
  0401c:    stw        r5, mem[r0, #0x3b]
  04020:    stw        r8, mem[r0, #0x3a]
  04024:    and        r8, r6, #0x7fffffff
  04028:    orr        r7, r8, #0x1c
  0402c:    cbz        r7, _PKT_0xf0_139
  04030:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04034:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
_PKT_0xf0_139:
  04038:    addd       r6, r6, #0x4
  0403c:    add        r9, r9, #0x4
  04040:    sub        r3, r3, #0x1
  04044:    cbnz       r3, _PKT_0xf0_137
  04048:    nop
  0404c:    btab

  04050:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04054:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  04058:    nop
  0405c:    hwop       r7, r6, #0x0
  04060:    lsrd       r8, r6, #32
  04064:    std        r1, mem[r0, #0x43]
  04068:    stw        r7, mem[r0, #0x45]
  0406c:    stw        r0, mem[r0, #0x47]
  04070:    stw        r9, mem[r0, #0x26]
  04074:    stw        r8, mem[r0, #0x29]
  04078:    addd       r6, r6, #0x20
  0407c:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04080:    dw         0x84000fe2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe2
  04084:    btab

_PKT_0xf0_140:
  04088:    nop
  0408c:    ldd        r14, reg[r0, #0x4a14]
  04090:    lsr        r15, r14, #14
  04094:    and        r14, r15, #0xfffff001
  04098:    cbz        r14, _PKT_0xf0_140
  0409c:    btab

  040a0:    ldd        r11, reg[r0, #0x6c]
  040a4:    and        r10, r11, #0xfffff820
  040a8:    cbz        r10, _PKT_0xf0_141
  040ac:    b          _PKT_0xf0_35  
_PKT_0xf0_141:
  040b0:    btab

_PKT_0xf0_142:
  040b4:    dw         0x8400096d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x96d
  040b8:    ldd        r10, reg[r0, #0x49f0]
  040bc:    and        r11, r10, #0xffffe003
  040c0:    cbz        r11, _PKT_0xf0_143
  040c4:    ldd        r10, reg[r0, #0x4a7c]
  040c8:    lsr        r11, r10, #24
  040cc:    and        r10, r11, #0xfffff001
  040d0:    cbz        r10, _PKT_0xf0_142
  040d4:    nop
_PKT_0xf0_143:
  040d8:    btab

_PKT_0xf0_144:
  040dc:    ldd        r6, reg[r0, #0x7c]
  040e0:    and        r6, r6, #0xfc007fff
  040e4:    sub        r5, r6, #0x1
  040e8:    cbz        r5, _PKT_0xf0_150
  040ec:    sub        r5, r6, #0x2
_PKT_0xf0_145:
  040f0:    cbz        r5, _PKT_0xf0_158
  040f4:    sub        r5, r6, #0x3
  040f8:    cbz        r5, _PKT_0xf0_173
  040fc:    sub        r5, r6, #0x4
  04100:    cbz        r5, _PKT_0xf0_187
  04104:    and        r5, r6, #0xf800ffff
  04108:    cbnz       r5, _PKT_0xf0_154
  0410c:    b          _PKT_0xf0_2  
_PKT_0xf0_146:
  04110:    ldd        r14, reg[r0, #0x14]
  04114:    cbz        r14, _PKT_0xf0_146
  04118:    sub        r6, r2, #0xffff
  0411c:    cbnz       r6, _PKT_0xf0_148
_PKT_0xf0_147:
  04120:    ldd        r5, reg[r0, #0x5a80]
  04124:    and        r6, r5, #0xfffff001
  04128:    cbz        r6, _PKT_0xf0_147
_PKT_0xf0_148:
  0412c:    ldd        r6, reg[r0, #0x84]
  04130:    cbnz       r6, _PKT_0xf0_146
  04134:    ldd        r14, reg[r0, #0x6c]
  04138:    and        r14, r14, #0xffd20fff
  0413c:    cbnz       r14, _PKT_0xf0_38
  04140:    ldd        r6, reg[r0, #0x4a60]
  04144:    mov        r7, #0x1
  04148:    and        r5, r6, #0xffffc007
  0414c:    mov        r10, #0xfb48
  04150:    cbz        r5, _PKT_0xf0_149
  04154:    mov        r10, #0xfb49
_PKT_0xf0_149:
  04158:    stw        r7, [r0, #0xe7]
  0415c:    std        r1, [r0, #0xdb]
  04160:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
_PKT_0xf0_150:
  04164:    std        r1, [r0, #0x99]
  04168:    std        r1, [r0, #0x9a]
  0416c:    std        r1, [r0, #0x9b]
  04170:    std        r1, [r0, #0xfd]
  04174:    mov        r7, #0xf
  04178:    stw        r7, reg[r0, #0x5b44]
_PKT_0xf0_151:
  0417c:    ldd        r14, reg[r0, #0x4a14]
  04180:    lsr        r10, r14, #25
  04184:    and        r14, r10, #0xfffff001
  04188:    cbz        r14, _PKT_0xf0_151
  0418c:    ldd        r6, reg[r0, #0x7c]
  04190:    mov        r5, #0xf
  04194:    eor        r5, r5, r0
  04198:    hwop       r6, r6, #0x6
  0419c:    stw        r6, [r0, #0x7a]
  041a0:    ldd        r6, reg[r0, #0x4a60]
  041a4:    mov        r7, #0x0
  041a8:    and        r5, r6, #0xffffc007
  041ac:    mov        r10, #0xfb48
  041b0:    cbz        r5, _PKT_0xf0_152
  041b4:    mov        r10, #0xfb49
_PKT_0xf0_152:
  041b8:    stw        r7, [r0, #0xe8]
  041bc:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
_PKT_0xf0_153:
  041c0:    std        r1, [r0, #0x7b]
  041c4:    std        r1, [r0, #0x7d]
  041c8:    std        r1, [r0, #0x99]
  041cc:    std        r1, [r0, #0x9a]
  041d0:    std        r1, [r0, #0x9b]
  041d4:    std        r1, [r0, #0x93]
  041d8:    std        r1, [r0, #0x9d]
  041dc:    std        r1, [r0, #0x97]
  041e0:    std        r1, [r0, #0xfd]
  041e4:    std        r0, mem[r0, #0x43]
  041e8:    std        r1, [r0, #0x174]
  041ec:    std        r1, [r0, #0x176]
_PKT_0xf0_154:
  041f0:    dw         0x840011c3  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11c3
  041f4:    ldd        r6, reg[r0, #0x7c]
  041f8:    and        r5, r6, #0xfc007fff
  041fc:    sub        r6, r5, #0x1
  04200:    cbz        r6, _PKT_0xf0_146
  04204:    ldd        r6, reg[r0, #0x7c]
  04208:    and        r5, r6, #0xfc007fff
  0420c:    sub        r6, r5, #0x2
  04210:    cbz        r6, _PKT_0xf0_156
  04214:    ldd        r6, reg[r0, #0x7c]
  04218:    and        r5, r6, #0xfc007fff
  0421c:    sub        r6, r5, #0x3
  04220:    cbz        r6, _PKT_0xf0_171
  04224:    ldd        r6, reg[r0, #0x7c]
  04228:    and        r5, r6, #0xfc007fff
  0422c:    sub        r6, r5, #0x4
  04230:    cbz        r6, _PKT_0xf0_185
  04234:    ldd        r6, reg[r0, #0x7c]
  04238:    and        r5, r6, #0xf800ffff
  0423c:    cbnz       r5, _PKT_0xf0_154
  04240:    mov        r5, #0xf
  04244:    stw        r5, reg[r0, #0x5b44]
  04248:    stw        r0, [r0, #0x30]
  0424c:    nop
  04250:    nop
  04254:    nop
  04258:    std        r1, [r0, #0x30]
  0425c:    dw         0x840013a8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13a8
  04260:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  04264:    stw        r0, [r0, #0x9d]
  04268:    nop
  0426c:    nop
  04270:    ldd        r6, reg[r0, #0x5abc]
  04274:    cbz        r6, _PKT_0xf0_155
  04278:    ldd        r6, reg[r0, #0x5aa8]
  0427c:    and        r3, r6, #0xfffff001
  04280:    cbz        r3, _PKT_0xf0_155
  04284:    stw        r0, [r0, #0x42]
_PKT_0xf0_155:
  04288:    dw         0x8400119c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x119c
  0428c:    b          _PKT_0xf0_2  
_PKT_0xf0_156:
  04290:    stw        r0, [r0, #0x77]
  04294:    dw         0x84001186  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1186
  04298:    std        r2, mem[r0, #0x112]
  0429c:    std        r2, mem[r0, #0x111]
  042a0:    ldd        r6, reg[r0, #0x4a60]
  042a4:    mov        r7, #0x2
  042a8:    and        r5, r6, #0xffffc007
  042ac:    mov        r10, #0xfb48
  042b0:    cbz        r5, _PKT_0xf0_157
  042b4:    mov        r10, #0xfb49
_PKT_0xf0_157:
  042b8:    stw        r7, [r0, #0xe7]
  042bc:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
_PKT_0xf0_158:
  042c0:    mov        r11, #0xf882
  042c4:    lsl        r10, r11, #2
  042c8:    ldd        r3, reg[r10, #0x0]
  042cc:    mov        r11, #0xf883
  042d0:    lsl        r10, r11, #2
  042d4:    ldd        r4, reg[r10, #0x0]
  042d8:    lsld       r6, r4, #32
  042dc:    hwop       r6, r6, #0x20
  042e0:    mov        r11, #0xf88c
  042e4:    lsl        r10, r11, #2
  042e8:    ldd        r3, reg[r10, #0x0]
  042ec:    mov        r11, #0xf88d
  042f0:    lsl        r10, r11, #2
  042f4:    ldd        r4, reg[r10, #0x0]
  042f8:    lsld       r2, r4, #32
  042fc:    hwop       r2, r2, #0x20
  04300:    mov        r3, #0x40
  04304:    mov        r9, #0x49e8
  04308:    lsrd       r2, r2, #26
_PKT_0xf0_159:
  0430c:    and        r4, r2, #0xfffff001
  04310:    lsrd       r2, r2, #1
  04314:    cbz        r4, _PKT_0xf0_160
  04318:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
_PKT_0xf0_160:
  0431c:    add        r9, r9, #0x4
  04320:    sub        r3, r3, #0x1
  04324:    cbnz       r3, _PKT_0xf0_159
  04328:    mov        r11, #0xf88e
  0432c:    lsl        r10, r11, #2
  04330:    ldd        r3, reg[r10, #0x0]
  04334:    mov        r11, #0xf88f
  04338:    lsl        r10, r11, #2
  0433c:    ldd        r4, reg[r10, #0x0]
  04340:    lsld       r2, r4, #32
  04344:    hwop       r2, r2, #0x20
  04348:    mov        r3, #0x40
  0434c:    mov        r9, #0x4a80
_PKT_0xf0_161:
  04350:    and        r4, r2, #0xfffff001
  04354:    lsrd       r2, r2, #1
  04358:    cbz        r4, _PKT_0xf0_162
  0435c:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
_PKT_0xf0_162:
  04360:    add        r9, r9, #0x4
  04364:    sub        r3, r3, #0x1
  04368:    cbnz       r3, _PKT_0xf0_161
  0436c:    mov        r12, #0x0
_PKT_0xf0_163:
  04370:    mov        r11, #0xf888
  04374:    lsl        r10, r11, #2
  04378:    ldd        r3, reg[r10, #0x0]
  0437c:    mov        r11, #0xf889
  04380:    lsl        r10, r11, #2
  04384:    ldd        r4, reg[r10, #0x0]
  04388:    lsld       r2, r4, #32
  0438c:    hwop       r2, r2, #0x20
  04390:    mov        r3, #0x40
  04394:    mov        r9, #0x4b80
  04398:    hwop       r9, r9, #0x0
_PKT_0xf0_164:
  0439c:    and        r4, r2, #0xfffff001
  043a0:    lsrd       r2, r2, #1
  043a4:    cbz        r4, _PKT_0xf0_165
  043a8:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
_PKT_0xf0_165:
  043ac:    add        r9, r9, #0x4
  043b0:    sub        r3, r3, #0x1
  043b4:    cbnz       r3, _PKT_0xf0_164
  043b8:    mov        r11, #0xf88a
  043bc:    lsl        r10, r11, #2
  043c0:    ldd        r3, reg[r10, #0x0]
  043c4:    hwop       r2, r0, #0x20
  043c8:    mov        r3, #0x20
  043cc:    mov        r9, #0x4c80
  043d0:    hwop       r9, r9, #0x0
_PKT_0xf0_166:
  043d4:    and        r4, r2, #0xfffff001
  043d8:    lsrd       r2, r2, #1
  043dc:    cbz        r4, _PKT_0xf0_167
  043e0:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
_PKT_0xf0_167:
  043e4:    add        r9, r9, #0x4
  043e8:    sub        r3, r3, #0x1
  043ec:    cbnz       r3, _PKT_0xf0_166
  043f0:    nop
  043f4:    add        r12, r12, #0x180
  043f8:    setge      r11, r12, #0xf00
  043fc:    cbz        r11, _PKT_0xf0_163
  04400:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04404:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  04408:    std        r1, mem[r0, #0x33]
  0440c:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04410:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  04414:    ldd        r7, reg[r0, #0x4a60]
  04418:    and        r5, r7, #0xffffc007
  0441c:    cbnz       r5, _PKT_0xf0_168
  04420:    lsrd       r10, r6, #5
  04424:    addd       r10, r10, #0x1
  04428:    lsld       r6, r10, #5
  0442c:    mov        r3, #0x20
  04430:    mov        r9, #0x4280
  04434:    dw         0x84000fb9  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfb9
  04438:    mov        r3, #0x5
  0443c:    mov        r9, #0x46a4
  04440:    dw         0x84000fb9  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfb9
  04444:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04448:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  0444c:    std        r1, mem[r0, #0x33]
_PKT_0xf0_168:
  04450:    dw         0x84001191  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1191
_PKT_0xf0_169:
  04454:    ldd        r6, reg[r0, #0x4a14]
  04458:    lsr        r5, r6, #13
  0445c:    and        r6, r5, #0xfffff001
  04460:    cbz        r6, _PKT_0xf0_169
  04464:    ldd        r6, reg[r0, #0x4a60]
  04468:    mov        r7, #0x0
  0446c:    and        r5, r6, #0xffffc007
  04470:    mov        r10, #0xfb48
  04474:    cbz        r5, _PKT_0xf0_170
  04478:    mov        r10, #0xfb49
_PKT_0xf0_170:
  0447c:    stw        r7, [r0, #0xe9]
  04480:    ldd        r6, reg[r0, #0x7c]
  04484:    mov        r5, #0xf
  04488:    eor        r5, r5, r0
  0448c:    hwop       r6, r6, #0x6
  04490:    stw        r6, [r0, #0x7a]
  04494:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  04498:    b          _PKT_0xf0_145  
_PKT_0xf0_171:
  0449c:    dw         0x84001186  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1186
  044a0:    ldd        r6, reg[r0, #0x4a60]
  044a4:    mov        r7, #0x3
  044a8:    and        r5, r6, #0xffffc007
  044ac:    mov        r10, #0xfb48
  044b0:    cbz        r5, _PKT_0xf0_172
  044b4:    mov        r10, #0xfb49
_PKT_0xf0_172:
  044b8:    stw        r7, [r0, #0xe7]
  044bc:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
_PKT_0xf0_173:
  044c0:    mov        r11, #0xf882
  044c4:    lsl        r10, r11, #2
  044c8:    ldd        r3, reg[r10, #0x0]
  044cc:    mov        r11, #0xf883
  044d0:    lsl        r10, r11, #2
  044d4:    ldd        r4, reg[r10, #0x0]
  044d8:    lsld       r6, r4, #32
  044dc:    hwop       r6, r6, #0x20
  044e0:    mov        r11, #0xf88c
  044e4:    lsl        r10, r11, #2
  044e8:    ldd        r3, reg[r10, #0x0]
  044ec:    mov        r11, #0xf88d
  044f0:    lsl        r10, r11, #2
  044f4:    ldd        r4, reg[r10, #0x0]
  044f8:    lsld       r2, r4, #32
  044fc:    hwop       r2, r2, #0x20
  04500:    mov        r3, #0x40
  04504:    mov        r9, #0x49e8
  04508:    lsrd       r2, r2, #26
_PKT_0xf0_174:
  0450c:    and        r4, r2, #0xfffff001
  04510:    lsrd       r2, r2, #1
  04514:    cbz        r4, _PKT_0xf0_175
  04518:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
_PKT_0xf0_175:
  0451c:    add        r9, r9, #0x4
  04520:    sub        r3, r3, #0x1
  04524:    cbnz       r3, _PKT_0xf0_174
  04528:    mov        r11, #0xf88e
  0452c:    lsl        r10, r11, #2
  04530:    ldd        r3, reg[r10, #0x0]
  04534:    mov        r11, #0xf88f
  04538:    lsl        r10, r11, #2
  0453c:    ldd        r4, reg[r10, #0x0]
  04540:    lsld       r2, r4, #32
  04544:    hwop       r2, r2, #0x20
  04548:    mov        r3, #0x40
  0454c:    mov        r9, #0x4a80
_PKT_0xf0_176:
  04550:    and        r4, r2, #0xfffff001
  04554:    lsrd       r2, r2, #1
  04558:    cbz        r4, _PKT_0xf0_177
  0455c:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
_PKT_0xf0_177:
  04560:    add        r9, r9, #0x4
  04564:    sub        r3, r3, #0x1
  04568:    cbnz       r3, _PKT_0xf0_176
  0456c:    mov        r12, #0x0
_PKT_0xf0_178:
  04570:    mov        r11, #0xf888
  04574:    lsl        r10, r11, #2
  04578:    ldd        r3, reg[r10, #0x0]
  0457c:    mov        r11, #0xf889
  04580:    lsl        r10, r11, #2
  04584:    ldd        r4, reg[r10, #0x0]
  04588:    lsld       r2, r4, #32
  0458c:    hwop       r2, r2, #0x20
  04590:    mov        r3, #0x40
  04594:    mov        r9, #0x4b80
  04598:    hwop       r9, r9, #0x0
_PKT_0xf0_179:
  0459c:    and        r4, r2, #0xfffff001
  045a0:    lsrd       r2, r2, #1
  045a4:    cbz        r4, _PKT_0xf0_180
  045a8:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
_PKT_0xf0_180:
  045ac:    add        r9, r9, #0x4
  045b0:    sub        r3, r3, #0x1
  045b4:    cbnz       r3, _PKT_0xf0_179
  045b8:    mov        r11, #0xf88a
  045bc:    lsl        r10, r11, #2
  045c0:    ldd        r3, reg[r10, #0x0]
  045c4:    hwop       r2, r0, #0x20
  045c8:    mov        r3, #0x20
  045cc:    mov        r9, #0x4c80
  045d0:    hwop       r9, r9, #0x0
_PKT_0xf0_181:
  045d4:    and        r4, r2, #0xfffff001
  045d8:    lsrd       r2, r2, #1
  045dc:    cbz        r4, _PKT_0xf0_182
  045e0:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
_PKT_0xf0_182:
  045e4:    add        r9, r9, #0x4
  045e8:    sub        r3, r3, #0x1
  045ec:    cbnz       r3, _PKT_0xf0_181
  045f0:    nop
  045f4:    add        r12, r12, #0x180
  045f8:    setge      r11, r12, #0xf00
  045fc:    cbz        r11, _PKT_0xf0_178
  04600:    ldd        r7, reg[r0, #0x4a60]
  04604:    and        r5, r7, #0xffffc007
  04608:    cbnz       r5, _PKT_0xf0_183
  0460c:    lsrd       r10, r6, #5
  04610:    addd       r10, r10, #0x1
  04614:    lsld       r6, r10, #5
  04618:    mov        r3, #0x20
  0461c:    mov        r9, #0x4280
  04620:    lsr        r9, r9, #2
  04624:    dw         0x84000f61  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf61
  04628:    mov        r3, #0x5
  0462c:    mov        r9, #0x46a4
  04630:    lsr        r9, r9, #2
  04634:    dw         0x84000f61  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf61
_PKT_0xf0_183:
  04638:    ldd        r6, reg[r0, #0x4a60]
  0463c:    mov        r7, #0x0
  04640:    and        r5, r6, #0xffffc007
  04644:    mov        r10, #0xfb48
  04648:    cbz        r5, _PKT_0xf0_184
  0464c:    mov        r10, #0xfb49
_PKT_0xf0_184:
  04650:    stw        r7, [r0, #0xea]
  04654:    ldd        r6, reg[r0, #0x7c]
  04658:    mov        r5, #0xf
  0465c:    eor        r5, r5, r0
  04660:    hwop       r6, r6, #0x6
  04664:    stw        r6, [r0, #0x7a]
  04668:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  0466c:    b          _PKT_0xf0_145  
_PKT_0xf0_185:
  04670:    dw         0x84001186  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1186
  04674:    std        r0, mem[r0, #0xe5]
  04678:    std        r0, mem[r0, #0xe6]
  0467c:    std        r1, mem[r0, #0x112]
  04680:    std        r1, mem[r0, #0x111]
  04684:    stw        r0, [r0, #0x77]
  04688:    ldd        r6, reg[r0, #0x4a60]
  0468c:    mov        r7, #0x4
  04690:    and        r5, r6, #0xffffc007
  04694:    mov        r10, #0xfb48
  04698:    cbz        r5, _PKT_0xf0_186
  0469c:    mov        r10, #0xfb49
_PKT_0xf0_186:
  046a0:    stw        r7, [r0, #0xe7]
  046a4:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
_PKT_0xf0_187:
  046a8:    ldd        r6, reg[r0, #0x4a60]
  046ac:    mov        r7, #0x0
  046b0:    and        r5, r6, #0xffffc007
  046b4:    mov        r10, #0xfb48
  046b8:    cbz        r5, _PKT_0xf0_188
  046bc:    mov        r10, #0xfb49
_PKT_0xf0_188:
  046c0:    stw        r7, [r0, #0xeb]
  046c4:    ldd        r6, reg[r0, #0x7c]
  046c8:    mov        r5, #0xf
  046cc:    eor        r5, r5, r0
  046d0:    hwop       r6, r6, #0x6
  046d4:    stw        r6, [r0, #0x7a]
  046d8:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  046dc:    stw        r0, [r0, #0x7b]
  046e0:    std        r0, [r0, #0x174]
  046e4:    std        r0, [r0, #0x176]
  046e8:    b          _PKT_0xf0_145  
_PKT_0xf0_189:
  046ec:    ldd        r8, reg[r0, #0x4a14]
  046f0:    lsr        r11, r8, #14
  046f4:    and        r8, r11, #0xfffff001
  046f8:    cbz        r8, _PKT_0xf0_189
  046fc:    stw        r0, [r0, #0xd5]
  04700:    stw        r10, [r0, #0x5b]
  04704:    std        r2, [r0, #0xcd]
  04708:    std        r3, [r0, #0xd3]
  0470c:    stw        r7, [r0, #0x5c]
  04710:    btab

  04714:    nop
  04718:    std        r1, [r0, #0x7b]
  0471c:    std        r1, [r0, #0x9d]
  04720:    std        r1, [r0, #0x7d]
  04724:    std        r1, [r0, #0x99]
  04728:    std        r1, [r0, #0x9a]
  0472c:    std        r1, [r0, #0x9b]
  04730:    std        r1, [r0, #0x93]
  04734:    std        r1, [r0, #0x97]
  04738:    std        r1, [r0, #0xfd]
  0473c:    btab

  04740:    nop
  04744:    stw        r0, reg[r0, #0x4b80]
  04748:    stw        r0, reg[r0, #0x4d00]
  0474c:    stw        r0, reg[r0, #0x4e80]
  04750:    stw        r0, reg[r0, #0x5000]
  04754:    stw        r0, reg[r0, #0x5180]
  04758:    stw        r0, reg[r0, #0x5300]
  0475c:    stw        r0, reg[r0, #0x5480]
  04760:    stw        r0, reg[r0, #0x5600]
  04764:    stw        r0, reg[r0, #0x5780]
  04768:    stw        r0, reg[r0, #0x5900]
  0476c:    btab

  04770:    mov        r14, #0x0
  04774:    mov        r10, #0x0
_PKT_0xf0_190:
  04778:    ldd        r5, reg[r14, #0x4b80]
  0477c:    and        r6, r5, #0xfffff001
  04780:    cbz        r6, _PKT_0xf0_191
  04784:    ldd        r8, reg[r14, #0x4b9c]
  04788:    and        r9, r8, #0xffff800f
  0478c:    cbz        r9, _PKT_0xf0_191
  04790:    ldd        r7, reg[r0, #0xbc]
  04794:    cbnz       r7, _PKT_0xf0_190
  04798:    dw         0x840011ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11ac
_PKT_0xf0_191:
  0479c:    add        r14, r14, #0x180
  047a0:    add        r10, r10, #0x1
  047a4:    and        r6, r10, #0xa
  047a8:    cbnz       r6, _PKT_0xf0_190
  047ac:    btab

_PKT_0xf0_192:
  047b0:    ldd        r6, reg[r0, #0x6c]
  047b4:    and        r6, r6, #0xffa61fff
  047b8:    cbnz       r6, _PKT_0xf0_38
  047bc:    ldd        r6, reg[r0, #0xb8]
  047c0:    cbnz       r6, _PKT_0xf0_192
  047c4:    nop
  047c8:    stw        r10, mem[r0, #0xb7]
  047cc:    ldd        r11, reg[r14, #0x4c4c]
  047d0:    stw        r11, mem[r0, #0xb1]
  047d4:    ldd        r11, reg[r14, #0x4c48]
  047d8:    stw        r11, mem[r0, #0xb2]
  047dc:    ldd        r11, reg[r14, #0x4b9c]
_PKT_0xf0_193:
  047e0:    lsr        r12, r11, #1
  047e4:    and        r13, r12, #0xfffff001
  047e8:    stw        r13, mem[r0, #0xb4]
  047ec:    ldd        r11, reg[r14, #0x4b80]
  047f0:    lsr        r12, r11, #23
  047f4:    and        r13, r12, #0xfffff001
  047f8:    stw        r13, mem[r0, #0xb5]
  047fc:    lsr        r12, r11, #24
  04800:    and        r13, r12, #0xfc007fff
  04804:    stw        r13, mem[r0, #0xb6]
  04808:    btab

  0480c:    std        r1, [r0, #0xfa]
  04810:    mov        r14, #0xf887
  04814:    lsl        r10, r14, #2
  04818:    ldd        r7, reg[r10, #0x0]
  0481c:    cbz        r7, _PKT_0xf0_194
  04820:    ldd        r10, reg[r0, #0xe4]
  04824:    cbz        r10, _PKT_0xf0_194
  04828:    stw        r0, [r0, #0xe1]
  0482c:    ldd        r7, reg[r0, #0xe0]
  04830:    nop
  04834:    ldd        r10, reg[r0, #0x20]
  04838:    nop
  0483c:    seteq      r14, r7, r10
  04840:    cbnz       r14, _PKT_0xf0_194
  04844:    stw        r7, [r0, #0x21]
  04848:    nop
  0484c:    dw         0x840011d6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11d6
_PKT_0xf0_194:
  04850:    std        r0, [r0, #0xfa]
  04854:    btab

  04858:    ldd        r6, reg[r0, #0x4a60]
  0485c:    and        r5, r6, #0xffffc007
  04860:    mov        r10, #0xfb50
  04864:    cbz        r5, _PKT_0xf0_195
  04868:    mov        r10, #0xfb51
_PKT_0xf0_195:
  0486c:    ldd        r8, reg[r0, #0x4a14]
  04870:    lsr        r11, r8, #14
  04874:    and        r8, r11, #0xfffff001
  04878:    cbz        r8, _PKT_0xf0_195
  0487c:    stw        r0, [r0, #0xd5]
  04880:    stw        r10, [r0, #0x5b]
  04884:    std        r2, [r0, #0xcd]
  04888:    std        r3, [r0, #0xd3]
  0488c:    stw        r7, [r0, #0x5c]
  04890:    dw         0x84000fe2  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe2
  04894:    ldd        r6, reg[r0, #0x4a14]
  04898:    and        r10, r6, #0xfffff808
  0489c:    cbz        r10, _PKT_0xf0_196
  048a0:    ldd        r6, reg[r0, #0x5a80]
  048a4:    and        r10, r6, #0xfffff001
  048a8:    cbnz       r10, _PKT_0xf0_196
  048ac:    ldd        r6, reg[r0, #0x5a9c]
  048b0:    and        r10, r6, #0xfffff001
  048b4:    cbz        r10, _PKT_0xf0_196
  048b8:    stw        r0, mem[r0, #0xf5]
_PKT_0xf0_196:
  048bc:    btab

  048c0:    std        r1, [r0, #0xfa]
  048c4:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  048c8:    std        r0, [r0, #0xcb]
  048cc:    std        r0, [r0, #0xfa]
_PKT_0xf0_197:
  048d0:    dw         0x84000d81  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd81
  048d4:    std        r1, [r0, #0x9b]
  048d8:    std        r1, [r0, #0x9a]
  048dc:    stw        r0, [r0, #0x99]
  048e0:    stw        r0, [r0, #0xfd]
  048e4:    dw         0x84001396  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1396
  048e8:    dw         0x84000dc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xdc0
  048ec:    dw         0x84000d42  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd42
  048f0:    dw         0x840013d6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13d6
  048f4:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  048f8:    ldd        r6, reg[r0, #0x6c]
  048fc:    and        r6, r6, #0xffa61fff
  04900:    cbnz       r6, _PKT_0xf0_38
  04904:    ldd        r6, reg[r0, #0xf4]
  04908:    cbz        r6, _PKT_0xf0_198
  0490c:    ldd        r13, reg[r0, #0x5a94]
  04910:    ldd        r14, reg[r0, #0x5a8c]
  04914:    seteq      r12, r13, r14
  04918:    cbz        r12, _PKT_0xf0_198
  0491c:    b          _PKT_0xf0_193  
  04920:    ldd        r10, reg[r0, #0x5b50]
  04924:    and        r6, r10, #0xfffff001
  04928:    cbz        r6, _PKT_0xf0_198
  0492c:    mov        r10, #0x2
  04930:    stw        r10, [r0, #0x104]
_PKT_0xf0_198:
  04934:    mov        r6, #0xf
_PKT_0xf0_199:
  04938:    sub        r6, r6, #0x1
  0493c:    cbnz       r6, _PKT_0xf0_199
  04940:    stw        r0, [r0, #0x85]
  04944:    ldd        r5, reg[r0, #0x4a14]
  04948:    and        r6, r5, #0xffff800f
  0494c:    cbnz       r6, _PKT_0xf0_200
  04950:    dw         0x84000d98  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd98
  04954:    dw         0x84000d93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd93
  04958:    ldd        r6, reg[r0, #0x5abc]
  0495c:    cbz        r6, _PKT_0xf0_11
  04960:    stw        r0, [r0, #0x42]
  04964:    b          _PKT_0xf0_2  
_PKT_0xf0_200:
  04968:    dw         0x84000d76  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd76
  0496c:    ldd        r6, reg[r0, #0x6c]
  04970:    and        r6, r6, #0xffa61fff
  04974:    cbnz       r6, _PKT_0xf0_38
  04978:    ldd        r5, reg[r0, #0x5ac4]
  0497c:    and        r6, r5, #0xfffff804
  04980:    cbnz       r6, _PKT_0xf0_109
  04984:    dw         0x84000d93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd93
  04988:    ldd        r6, reg[r0, #0x5abc]
  0498c:    cbz        r6, _PKT_0xf0_11
  04990:    stw        r0, [r0, #0x42]
  04994:    b          _PKT_0xf0_2  
  04998:    hwop       r7, r6, #0x0
  0499c:    lsrd       r8, r6, #32
  049a0:    stw        r7, mem[r0, #0x52]
  049a4:    stw        r8, mem[r0, #0x53]
  049a8:    nop
  049ac:    ldd        r5, mem[r0, #0x0]
  049b0:    nop
  049b4:    nop
  049b8:    lsl        r9, r9, #2
  049bc:    stw        r5, reg[r9, #0x0]
  049c0:    addd       r6, r6, #0x4
  049c4:    btab

_PKT_0xf0_201:
  049c8:    dw         0x84001188  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1188
  049cc:    lsl        r3, r4, #16
  049d0:    hwop       r4, r3, #0x7
  049d4:    stw        r4, reg[r0, #0x49d8]
  049d8:    ldd        r6, reg[r0, #0x4a60]
  049dc:    mov        r7, #0x6
  049e0:    and        r5, r6, #0xffffc007
  049e4:    mov        r10, #0xfb48
  049e8:    cbz        r5, _PKT_0xf0_202
  049ec:    mov        r10, #0xfb49
_PKT_0xf0_202:
  049f0:    stw        r7, [r0, #0xe7]
  049f4:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  049f8:    std        r7, mem[r0, #0xe5]
  049fc:    std        r3, mem[r0, #0xe6]
  04a00:    std        r2, mem[r0, #0x112]
  04a04:    std        r2, mem[r0, #0x111]
  04a08:    std        r1, [r0, #0x174]
  04a0c:    std        r1, [r0, #0x176]
  04a10:    mov        r11, #0xf882
  04a14:    lsl        r10, r11, #2
  04a18:    ldd        r7, reg[r10, #0x0]
  04a1c:    mov        r11, #0xf883
  04a20:    lsl        r10, r11, #2
  04a24:    ldd        r8, reg[r10, #0x0]
  04a28:    lsld       r6, r8, #32
  04a2c:    hwop       r6, r6, #0x20
  04a30:    mov        r9, #0xf887
  04a34:    dw         0x84001226  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1226
  04a38:    mov        r9, #0xf884
  04a3c:    dw         0x84001226  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1226
  04a40:    mov        r9, #0x49e8
  04a44:    mov        r10, #0x4a74
  04a48:    add        r10, r10, r9
  04a4c:    lsr        r11, r10, #2
  04a50:    add        r4, r11, #0x1
_PKT_0xf0_203:
  04a54:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04a58:    add        r9, r9, #0x4
  04a5c:    sub        r4, r4, #0x1
  04a60:    cbnz       r4, _PKT_0xf0_203
  04a64:    mov        r9, #0x4a9c
  04a68:    mov        r10, #0x4b40
  04a6c:    add        r10, r10, r9
  04a70:    lsr        r11, r10, #2
  04a74:    add        r4, r11, #0x1
_PKT_0xf0_204:
  04a78:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04a7c:    add        r9, r9, #0x4
  04a80:    sub        r4, r4, #0x1
  04a84:    cbnz       r4, _PKT_0xf0_204
  04a88:    mov        r3, #0x1
  04a8c:    mov        r9, #0x4b80
  04a90:    mov        r10, #0x4ca4
  04a94:    add        r10, r10, r9
  04a98:    lsr        r11, r10, #2
_PKT_0xf0_205:
  04a9c:    add        r4, r11, #0x1
  04aa0:    add        r13, r4, #0x0
  04aa4:    mov        r2, #0x4b80
_PKT_0xf0_206:
  04aa8:    dw         0x84000f4b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf4b
  04aac:    add        r4, r13, #0x0
_PKT_0xf0_207:
  04ab0:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04ab4:    add        r9, r9, #0x4
  04ab8:    sub        r4, r4, #0x1
  04abc:    cbnz       r4, _PKT_0xf0_207
  04ac0:    hwop       r9, r2, #0x0
  04ac4:    add        r9, r9, #0x180
  04ac8:    hwop       r2, r9, #0x0
  04acc:    sub        r3, r3, #0x1
  04ad0:    cbnz       r3, _PKT_0xf0_206
  04ad4:    mov        r3, #0x9
  04ad8:    mov        r9, #0x4d00
  04adc:    mov        r2, #0x4d00
_PKT_0xf0_208:
  04ae0:    dw         0x84000f4b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf4b
  04ae4:    mov        r11, #0x4d00
  04ae8:    mov        r10, #0x4d48
  04aec:    add        r10, r10, r11
  04af0:    lsr        r11, r10, #2
  04af4:    add        r4, r11, #0x1
  04af8:    add        r13, r4, #0x0
  04afc:    add        r4, r13, #0x0
_PKT_0xf0_209:
  04b00:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04b04:    add        r9, r9, #0x4
  04b08:    sub        r4, r4, #0x1
  04b0c:    cbnz       r4, _PKT_0xf0_209
  04b10:    mov        r11, #0x4d48
  04b14:    mov        r10, #0x4da8
  04b18:    add        r10, r10, r11
  04b1c:    sub        r10, r10, #0x4
  04b20:    hwop       r9, r9, #0x0
  04b24:    mov        r11, #0x4da8
  04b28:    mov        r10, #0x4e24
  04b2c:    add        r10, r10, r11
  04b30:    lsr        r11, r10, #2
  04b34:    add        r4, r11, #0x1
  04b38:    add        r13, r4, #0x0
  04b3c:    add        r4, r13, #0x0
_PKT_0xf0_210:
  04b40:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04b44:    add        r9, r9, #0x4
  04b48:    sub        r4, r4, #0x1
  04b4c:    cbnz       r4, _PKT_0xf0_210
  04b50:    hwop       r9, r2, #0x0
  04b54:    add        r9, r9, #0x180
  04b58:    hwop       r2, r9, #0x0
  04b5c:    sub        r3, r3, #0x1
  04b60:    cbnz       r3, _PKT_0xf0_208
  04b64:    mov        r4, #0x1
  04b68:    lsl        r4, r4, #31
  04b6c:    stw        r4, [r0, #0x165]
  04b70:    b          _PKT_0xf0_205  
_PKT_0xf0_211:
  04b74:    and        r9, r4, #0xfffff801
  04b78:    cbnz       r9, _PKT_0xf0_212
  04b7c:    sub        r4, r4, #0x1
_PKT_0xf0_212:
  04b80:    mov        r9, #0x1
  04b84:    lsl        r9, r9, #31
  04b88:    hwop       r4, r4, #0x7
  04b8c:    mov        r9, #0x1
  04b90:    lsl        r9, r9, #5
  04b94:    hwop       r4, r4, #0x7
  04b98:    stw        r4, [r0, #0x165]
  04b9c:    mov        r3, #0xa
  04ba0:    mov        r9, #0x4b94
  04ba4:    mov        r12, #0x4c54
_PKT_0xf0_213:
  04ba8:    and        r11, r4, #0x7fffffff
  04bac:    lsr        r13, r4, #5
  04bb0:    lsl        r13, r13, #31
  04bb4:    hwop       r13, r13, #0x7
  04bb8:    stw        r13, [r0, #0x8c]
  04bbc:    std        r1, reg[r12, #0x0]
_PKT_0xf0_214:
  04bc0:    mov        r11, #0x8
_PKT_0xf0_215:
  04bc4:    sub        r11, r11, #0x1
  04bc8:    cbnz       r11, _PKT_0xf0_215
  04bcc:    stw        r0, [r0, #0x8d]
  04bd0:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04bd4:    add        r9, r9, #0x4
  04bd8:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04bdc:    stw        r13, [r0, #0x8c]
  04be0:    std        r0, reg[r12, #0x0]
  04be4:    mov        r11, #0x8
_PKT_0xf0_216:
  04be8:    sub        r11, r11, #0x1
  04bec:    cbnz       r11, _PKT_0xf0_216
  04bf0:    stw        r0, [r0, #0x8d]
  04bf4:    add        r12, r12, #0x180
  04bf8:    add        r9, r9, #0x180
  04bfc:    sub        r9, r9, #0x4
  04c00:    sub        r3, r3, #0x1
  04c04:    cbnz       r3, _PKT_0xf0_213
  04c08:    add        r4, r4, #0x1
  04c0c:    and        r3, r4, #0x7fffffff
  04c10:    seteq      r3, r3, #0x1f
  04c14:    cbnz       r3, _PKT_0xf0_211
  04c18:    mov        r9, #0xf884
  04c1c:    lsl        r9, r9, #2
  04c20:    dw         0x84000f38  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf38
  04c24:    stw        r0, [r0, #0x165]
  04c28:    mov        r2, #0xf
  04c2c:    stw        r2, reg[r0, #0x49d8]
  04c30:    ldd        r6, reg[r0, #0x4a60]
  04c34:    mov        r7, #0x0
  04c38:    and        r5, r6, #0xffffc007
  04c3c:    mov        r10, #0xfb48
  04c40:    cbz        r5, _PKT_0xf0_217
  04c44:    mov        r10, #0xfb49
_PKT_0xf0_217:
  04c48:    stw        r7, [r0, #0xea]
  04c4c:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  04c50:    mov        r14, #0xf893
  04c54:    lsl        r13, r14, #2
  04c58:    ldd        r7, reg[r13, #0x0]
  04c5c:    orr        r14, r7, #0x6
  04c60:    cbz        r14, _PKT_0xf0_218
  04c64:    stw        r0, reg[r13, #0x0]
_PKT_0xf0_218:
  04c68:    dw         0x840013a8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x13a8
  04c6c:    std        r0, mem[r0, #0xe5]
  04c70:    std        r0, mem[r0, #0xe6]
  04c74:    std        r1, mem[r0, #0x112]
  04c78:    std        r1, mem[r0, #0x111]
  04c7c:    stw        r0, [r0, #0x77]
  04c80:    std        r0, [r0, #0x174]
  04c84:    std        r0, [r0, #0x176]
  04c88:    dw         0x8400119c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x119c
  04c8c:    b          _PKT_0xf0_2  
  04c90:    lsl        r9, r9, #2
  04c94:    ldd        r5, reg[r9, #0x0]
  04c98:    nop
  04c9c:    hwop       r7, r6, #0x0
  04ca0:    lsrd       r8, r6, #32
  04ca4:    std        r1, mem[r0, #0x43]
  04ca8:    stw        r7, mem[r0, #0x39]
  04cac:    stw        r5, mem[r0, #0x3b]
  04cb0:    stw        r8, mem[r0, #0x3a]
  04cb4:    addd       r6, r6, #0x4
  04cb8:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  04cbc:    btab

  04cc0:    dw         0x84001188  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1188
  04cc4:    lsl        r3, r4, #16
  04cc8:    hwop       r4, r3, #0x7
  04ccc:    stw        r4, reg[r0, #0x49d8]
  04cd0:    ldd        r6, reg[r0, #0x4a60]
  04cd4:    mov        r7, #0x5
  04cd8:    and        r5, r6, #0xffffc007
  04cdc:    mov        r10, #0xfb48
  04ce0:    cbz        r5, _PKT_0xf0_219
  04ce4:    mov        r10, #0xfb49
_PKT_0xf0_219:
  04ce8:    stw        r7, [r0, #0xe7]
  04cec:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  04cf0:    std        r7, mem[r0, #0xe5]
  04cf4:    std        r3, mem[r0, #0xe6]
  04cf8:    std        r2, mem[r0, #0x112]
  04cfc:    std        r2, mem[r0, #0x111]
  04d00:    std        r1, [r0, #0x174]
  04d04:    std        r1, [r0, #0x176]
  04d08:    mov        r11, #0xf882
  04d0c:    lsl        r10, r11, #2
  04d10:    ldd        r7, reg[r10, #0x0]
  04d14:    mov        r11, #0xf883
  04d18:    lsl        r10, r11, #2
  04d1c:    ldd        r8, reg[r10, #0x0]
  04d20:    lsld       r6, r8, #32
  04d24:    hwop       r6, r6, #0x20
  04d28:    mov        r9, #0xf887
  04d2c:    dw         0x840012e4  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12e4
  04d30:    mov        r9, #0xf884
  04d34:    dw         0x840012e4  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12e4
  04d38:    mov        r9, #0x49e8
  04d3c:    mov        r10, #0x4a74
  04d40:    add        r10, r10, r9
  04d44:    lsr        r11, r10, #2
  04d48:    add        r4, r11, #0x1
_PKT_0xf0_220:
  04d4c:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04d50:    add        r9, r9, #0x4
  04d54:    sub        r4, r4, #0x1
  04d58:    cbnz       r4, _PKT_0xf0_220
  04d5c:    nop
  04d60:    mov        r9, #0x4a9c
  04d64:    mov        r10, #0x4b40
  04d68:    add        r10, r10, r9
  04d6c:    lsr        r11, r10, #2
  04d70:    add        r4, r11, #0x1
_PKT_0xf0_221:
  04d74:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04d78:    add        r9, r9, #0x4
  04d7c:    sub        r4, r4, #0x1
  04d80:    cbnz       r4, _PKT_0xf0_221
  04d84:    nop
  04d88:    mov        r3, #0x1
  04d8c:    mov        r9, #0x4b80
  04d90:    mov        r10, #0x4ca4
  04d94:    add        r10, r10, r9
  04d98:    lsr        r11, r10, #2
  04d9c:    add        r4, r11, #0x1
  04da0:    add        r13, r4, #0x0
  04da4:    mov        r2, #0x4b80
_PKT_0xf0_222:
  04da8:    add        r4, r13, #0x0
_PKT_0xf0_223:
  04dac:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04db0:    add        r9, r9, #0x4
  04db4:    sub        r4, r4, #0x1
  04db8:    cbnz       r4, _PKT_0xf0_223
  04dbc:    nop
  04dc0:    hwop       r9, r2, #0x0
  04dc4:    add        r9, r9, #0x180
  04dc8:    hwop       r2, r9, #0x0
  04dcc:    sub        r3, r3, #0x1
  04dd0:    cbnz       r3, _PKT_0xf0_222
  04dd4:    nop
  04dd8:    mov        r3, #0x9
  04ddc:    mov        r9, #0x4d00
  04de0:    mov        r2, #0x4d00
_PKT_0xf0_224:
  04de4:    mov        r11, #0x4d00
  04de8:    mov        r10, #0x4d48
  04dec:    add        r10, r10, r11
  04df0:    lsr        r11, r10, #2
  04df4:    add        r4, r11, #0x1
  04df8:    add        r13, r4, #0x0
  04dfc:    add        r4, r13, #0x0
_PKT_0xf0_225:
  04e00:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04e04:    add        r9, r9, #0x4
  04e08:    sub        r4, r4, #0x1
  04e0c:    cbnz       r4, _PKT_0xf0_225
  04e10:    nop
  04e14:    mov        r11, #0x4d48
  04e18:    mov        r10, #0x4da8
  04e1c:    add        r10, r10, r11
  04e20:    sub        r10, r10, #0x4
  04e24:    hwop       r9, r9, #0x0
  04e28:    mov        r11, #0x4da8
  04e2c:    mov        r10, #0x4e24
  04e30:    add        r10, r10, r11
  04e34:    lsr        r11, r10, #2
  04e38:    add        r4, r11, #0x1
  04e3c:    add        r13, r4, #0x0
  04e40:    add        r4, r13, #0x0
_PKT_0xf0_226:
  04e44:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04e48:    add        r9, r9, #0x4
  04e4c:    sub        r4, r4, #0x1
  04e50:    cbnz       r4, _PKT_0xf0_226
  04e54:    nop
  04e58:    hwop       r9, r2, #0x0
  04e5c:    add        r9, r9, #0x180
  04e60:    hwop       r2, r9, #0x0
  04e64:    sub        r3, r3, #0x1
  04e68:    cbnz       r3, _PKT_0xf0_224
  04e6c:    nop
  04e70:    mov        r4, #0x1
  04e74:    lsl        r4, r4, #31
  04e78:    stw        r4, [r0, #0x165]
  04e7c:    b          _PKT_0xf0_222  
_PKT_0xf0_227:
  04e80:    and        r9, r4, #0xfffff801
  04e84:    cbnz       r9, _PKT_0xf0_228
  04e88:    sub        r4, r4, #0x1
_PKT_0xf0_228:
  04e8c:    mov        r9, #0x1
  04e90:    lsl        r9, r9, #31
  04e94:    hwop       r4, r4, #0x7
  04e98:    mov        r9, #0x1
  04e9c:    lsl        r9, r9, #5
  04ea0:    hwop       r4, r4, #0x7
  04ea4:    stw        r4, [r0, #0x165]
  04ea8:    mov        r3, #0xa
  04eac:    mov        r9, #0x4b94
_PKT_0xf0_229:
  04eb0:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04eb4:    add        r9, r9, #0x4
  04eb8:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04ebc:    add        r9, r9, #0x180
  04ec0:    sub        r9, r9, #0x4
  04ec4:    sub        r3, r3, #0x1
  04ec8:    cbnz       r3, _PKT_0xf0_229
  04ecc:    add        r4, r4, #0x1
  04ed0:    and        r3, r4, #0x7fffffff
  04ed4:    seteq      r3, r3, #0x1f
_PKT_0xf0_230:
  04ed8:    cbnz       r3, _PKT_0xf0_227
  04edc:    mov        r9, #0xf884
  04ee0:    lsl        r9, r9, #2
  04ee4:    dw         0x84000f93  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf93
  04ee8:    stw        r0, [r0, #0x165]
  04eec:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04ef0:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
  04ef4:    std        r1, mem[r0, #0x33]
  04ef8:    dw         0x84000fe8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfe8
  04efc:    dw         0x84000fed  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xfed
_PKT_0xf0_231:
  04f00:    ldd        r6, reg[r0, #0x4a14]
  04f04:    lsr        r5, r6, #13
  04f08:    and        r6, r5, #0xfffff001
  04f0c:    cbz        r6, _PKT_0xf0_231
  04f10:    mov        r2, #0xf
  04f14:    stw        r2, reg[r0, #0x49d8]
  04f18:    ldd        r6, reg[r0, #0x4a60]
  04f1c:    mov        r7, #0x0
  04f20:    and        r5, r6, #0xffffc007
  04f24:    mov        r10, #0xfb48
  04f28:    cbz        r5, _PKT_0xf0_232
  04f2c:    mov        r10, #0xfb49
_PKT_0xf0_232:
  04f30:    stw        r7, [r0, #0xe9]
  04f34:    dw         0x8400117b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x117b
  04f38:    std        r0, mem[r0, #0xe5]
  04f3c:    std        r0, mem[r0, #0xe6]
  04f40:    std        r1, mem[r0, #0x112]
  04f44:    std        r1, mem[r0, #0x111]
  04f48:    stw        r0, [r0, #0x77]
  04f4c:    std        r0, [r0, #0x174]
  04f50:    std        r0, [r0, #0x176]
_PKT_0xf0_233:
  04f54:    b          _PKT_0xf0_230  
  04f58:    ldd        r13, reg[r0, #0xfc]
  04f5c:    cbz        r13, _PKT_0xf0_234
  04f60:    ldd        r13, reg[r0, #0x5a8c]
  04f64:    ldd        r14, reg[r0, #0x5a94]
  04f68:    seteq      r4, r13, r14
  04f6c:    cbz        r4, _PKT_0xf0_234
  04f70:    mov        r14, #0x0
  04f74:    mov        r13, #0x0
  04f78:    mov        r14, #0xf893
  04f7c:    lsl        r13, r14, #2
  04f80:    lsl        r13, r14, #2
  04f84:    cbz        r13, _PKT_0xf0_234
  04f88:    ldd        r4, reg[r13, #0x0]
  04f8c:    and        r13, r4, #0xfc007fff
  04f90:    orr        r14, r13, #0x5
  04f94:    cbz        r14, _PKT_0xf0_234
  04f98:    b          _PKT_0xf0_214  
_PKT_0xf0_234:
  04f9c:    btab

_PKT_0xf0_235:
  04fa0:    std        r0, [r0, #0x174]
  04fa4:    std        r0, [r0, #0x175]
  04fa8:    std        r0, [r0, #0x176]
  04fac:    std        r0, [r0, #0x177]
  04fb0:    std        r0, [r0, #0xcb]
  04fb4:    stw        r0, [r0, #0x93]
  04fb8:    stw        r0, [r0, #0x99]
  04fbc:    stw        r0, [r0, #0xfd]
  04fc0:    stw        r0, [r0, #0x97]
  04fc4:    stw        r0, [r0, #0x7d]
  04fc8:    stw        r0, [r0, #0xdb]
  04fcc:    stw        r0, [r0, #0x9a]
  04fd0:    stw        r0, [r0, #0x9b]
  04fd4:    btab

  04fd8:    nop
  04fdc:    b          _PKT_0xf0_230  
  04fe0:    ldd        r14, reg[r0, #0x49d8]

PKT_0xa444:
  04fe4:    orr        r13, r14, #0xf
  04fe8:    cbnz       r13, _PKT_0xa444_0
  04fec:    mov        r14, #0x0
  04ff0:    mov        r13, #0x0
  04ff4:    mov        r14, #0xf893
  04ff8:    lsl        r13, r14, #2
  04ffc:    lsl        r13, r14, #2
  05000:    cbz        r13, _PKT_0xa444_0
  05004:    ldd        r4, reg[r13, #0x0]
  05008:    and        r13, r4, #0xfc007fff
  0500c:    orr        r14, r13, #0x6
  05010:    cbnz       r14, _PKT_0xf0_201
_PKT_0xa444_0:
  05014:    btab

  05018:    mov        r13, #0x13
  0501c:    stw        r13, [r0, #0x170]
  05020:    stw        r13, [r0, #0x171]
  05024:    stw        r13, [r0, #0x172]
  05028:    stw        r13, [r0, #0x173]
  0502c:    btab

  05030:    ldd        r14, reg[r0, #0x4af8]
  05034:    lsr        r13, r14, #31
  05038:    cbz        r13, _PKT_0xa444_1
  0503c:    nop
  05040:    and        r13, r14, #0xfffff001
  05044:    cbnz       r13, _PKT_0xa444_3
  05048:    nop
  0504c:    b          _PKT_0xf0_235  
  05050:    nop
_PKT_0xa444_1:
  05054:    btab

  05058:    ldd        r14, reg[r0, #0x4af8]
  0505c:    lsr        r13, r14, #31
  05060:    cbz        r13, _PKT_0xa444_2
  05064:    nop
  05068:    and        r13, r14, #0xfffff001
  0506c:    cbnz       r13, _PKT_0xf0_97
  05070:    nop
  05074:    b          _PKT_0xf0_235  
  05078:    nop
_PKT_0xa444_2:
  0507c:    btab

_PKT_0xa444_3:
  05080:    std        r1, [r0, #0xfa]
  05084:    mov        r13, #0x1
  05088:    lsl        r13, r13, #8
  0508c:    ldd        r14, reg[r0, #0x49f0]
  05090:    hwop       r14, r13, #0x7
  05094:    nop
  05098:    std        r1, [r0, #0xca]
  0509c:    b          _PKT_0xf0_12  
  050a0:    std        r1, [r0, #0xfa]
  050a4:    mov        r13, #0x1
  050a8:    lsl        r13, r13, #30
  050ac:    hwop       r14, r14, #0x7
  050b0:    stw        r14, reg[r0, #0x4af8]
_PKT_0xa444_4:
  050b4:    std        r0, [r0, #0x174]
  050b8:    std        r0, [r0, #0x175]
  050bc:    std        r0, [r0, #0x176]
  050c0:    std        r0, [r0, #0x177]
  050c4:    ldd        r14, reg[r0, #0x4af8]
  050c8:    nop
  050cc:    lsr        r13, r14, #31
  050d0:    cbnz       r13, _PKT_0xa444_4
  050d4:    mov        r13, #0x1
  050d8:    lsl        r13, r13, #30
  050dc:    eor        r13, r13, r0
  050e0:    hwop       r14, r13, #0x6
  050e4:    stw        r14, reg[r0, #0x4af8]
  050e8:    std        r0, [r0, #0x178]
  050ec:    std        r0, [r0, #0xfa]
  050f0:    b          _PKT_0xf0_233  
  050f4:    nop
  050f8:    nop
  050fc:    nop
  05100:    nop
  05104:    nop
  05108:    nop
  0510c:    nop
  05110:    nop
  05114:    nop
  05118:    nop
  0511c:    nop
  05120:    nop
  05124:    nop
  05128:    nop
  0512c:    nop
  05130:    nop
  05134:    nop
  05138:    nop
  0513c:    nop
  05140:    nop
  05144:    nop
  05148:    nop
  0514c:    nop
  05150:    nop
  05154:    nop
  05158:    nop
  0515c:    nop
  05160:    nop
  05164:    nop
  05168:    nop
  0516c:    nop
  05170:    nop
  05174:    nop
  05178:    nop
  0517c:    nop
  05180:    nop
  05184:    nop
  05188:    nop
  0518c:    nop
  05190:    nop
  05194:    nop
  05198:    nop
  0519c:    nop
  051a0:    nop
  051a4:    nop
  051a8:    nop
  051ac:    nop
  051b0:    nop
  051b4:    nop
  051b8:    nop
  051bc:    nop
  051c0:    nop
  051c4:    nop
  051c8:    nop
  051cc:    nop
  051d0:    nop
  051d4:    nop
  051d8:    nop
  051dc:    nop
  051e0:    nop
  051e4:    nop
  051e8:    nop
  051ec:    nop
  051f0:    nop
  051f4:    nop
  051f8:    nop
  051fc:    nop
  05200:    nop
  05204:    nop
  05208:    nop
  0520c:    nop
  05210:    nop
  05214:    nop
  05218:    nop
  0521c:    nop
  05220:    nop
  05224:    nop
  05228:    nop
  0522c:    nop
  05230:    nop
  05234:    nop
  05238:    nop
  0523c:    nop
  05240:    nop
  05244:    nop
  05248:    nop
  0524c:    nop
  05250:    nop
  05254:    nop
  05258:    nop
  0525c:    nop
  05260:    nop
  05264:    nop
  05268:    nop
  0526c:    nop
  05270:    nop
  05274:    nop
  05278:    nop
  0527c:    nop
  05280:    nop
  05284:    nop
  05288:    nop
  0528c:    nop
  05290:    nop
  05294:    nop
  05298:    nop
  0529c:    nop
  052a0:    nop
  052a4:    nop
  052a8:    nop
  052ac:    nop
  052b0:    nop
  052b4:    nop
  052b8:    nop
  052bc:    nop
  052c0:    nop
  052c4:    nop
  052c8:    nop
  052cc:    nop
  052d0:    nop
  052d4:    nop
  052d8:    nop
  052dc:    nop
  052e0:    nop
  052e4:    nop
  052e8:    nop
  052ec:    nop
  052f0:    nop
  052f4:    nop
  052f8:    nop
  052fc:    nop
  05300:    nop
  05304:    nop
  05308:    nop
  0530c:    nop
  05310:    nop
  05314:    nop
  05318:    nop
  0531c:    nop
  05320:    nop
  05324:    nop
  05328:    nop
  0532c:    nop
  05330:    nop
  05334:    nop
  05338:    nop
  0533c:    nop
  05340:    nop
  05344:    nop
  05348:    nop
  0534c:    nop
  05350:    nop
  05354:    nop
  05358:    nop
  0535c:    nop
  05360:    nop
  05364:    nop
  05368:    nop
  0536c:    nop
  05370:    nop
  05374:    nop
  05378:    nop
  0537c:    nop
  05380:    nop
  05384:    nop
  05388:    nop
  0538c:    nop
  05390:    nop
  05394:    nop
  05398:    nop
  0539c:    nop
  053a0:    nop
  053a4:    nop
  053a8:    nop
  053ac:    nop
  053b0:    nop
  053b4:    nop
  053b8:    nop
  053bc:    nop
  053c0:    nop
  053c4:    nop
  053c8:    nop
  053cc:    nop
  053d0:    nop
  053d4:    nop
  053d8:    nop
  053dc:    nop
  053e0:    nop
  053e4:    nop
  053e8:    nop
  053ec:    nop
  053f0:    nop
  053f4:    nop
  053f8:    nop
  053fc:    nop
  05400:    nop
  05404:    nop
  05408:    nop
  0540c:    nop
  05410:    nop
  05414:    nop
  05418:    nop
  0541c:    nop
  05420:    nop
  05424:    nop
  05428:    nop
  0542c:    nop
  05430:    nop
  05434:    nop
  05438:    nop
  0543c:    nop
  05440:    nop
  05444:    nop
  05448:    nop
  0544c:    nop
  05450:    nop
  05454:    nop
  05458:    nop
  0545c:    nop
  05460:    nop
  05464:    nop
  05468:    nop
  0546c:    nop
  05470:    nop
  05474:    nop
  05478:    nop
  0547c:    nop
  05480:    nop
  05484:    nop
  05488:    nop
  0548c:    nop
  05490:    nop
  05494:    nop
  05498:    nop
  0549c:    nop
  054a0:    nop
  054a4:    nop
  054a8:    nop
  054ac:    nop
  054b0:    nop
  054b4:    nop
  054b8:    nop
  054bc:    nop
  054c0:    nop
  054c4:    nop
  054c8:    nop
  054cc:    nop
  054d0:    nop
  054d4:    nop
  054d8:    nop
  054dc:    nop
  054e0:    nop
  054e4:    nop
  054e8:    nop
  054ec:    nop
  054f0:    nop
  054f4:    nop
  054f8:    nop
  054fc:    nop
  05500:    nop
  05504:    nop
  05508:    nop
  0550c:    nop
  05510:    nop
  05514:    nop
  05518:    nop
  0551c:    nop
  05520:    nop
  05524:    nop
  05528:    nop
  0552c:    nop
  05530:    nop
  05534:    nop
  05538:    nop
  0553c:    nop
  05540:    nop
  05544:    nop
  05548:    nop
  0554c:    nop
  05550:    nop
  05554:    nop
  05558:    nop
  0555c:    nop
  05560:    nop
  05564:    nop
  05568:    nop
  0556c:    nop
  05570:    nop
  05574:    nop
  05578:    nop
  0557c:    nop
  05580:    nop
  05584:    nop
  05588:    nop
  0558c:    nop
  05590:    nop
  05594:    nop
  05598:    nop
  0559c:    nop
  055a0:    nop
  055a4:    nop
  055a8:    nop
  055ac:    nop
  055b0:    nop
  055b4:    nop
  055b8:    nop
  055bc:    nop
  055c0:    nop
  055c4:    nop
  055c8:    nop
  055cc:    nop
  055d0:    nop
  055d4:    nop
  055d8:    nop
  055dc:    nop
  055e0:    nop
  055e4:    nop
  055e8:    nop
  055ec:    nop
  055f0:    nop
  055f4:    nop
  055f8:    nop
  055fc:    nop
  05600:    nop
  05604:    nop
  05608:    nop
  0560c:    nop
  05610:    nop
  05614:    nop
  05618:    nop
  0561c:    nop
  05620:    nop
  05624:    nop
  05628:    nop
  0562c:    nop
  05630:    nop
  05634:    nop
  05638:    nop
  0563c:    nop
  05640:    nop
  05644:    nop
  05648:    nop
  0564c:    nop
  05650:    nop
  05654:    nop
  05658:    nop
  0565c:    nop
  05660:    nop
  05664:    nop
  05668:    nop
  0566c:    nop
  05670:    nop
  05674:    nop
  05678:    nop
  0567c:    nop
  05680:    nop
  05684:    nop
  05688:    nop
  0568c:    nop
  05690:    nop
  05694:    nop
  05698:    nop
  0569c:    nop
  056a0:    nop
  056a4:    nop
  056a8:    nop
  056ac:    nop
  056b0:    nop
  056b4:    nop
  056b8:    nop
  056bc:    nop
  056c0:    nop
  056c4:    nop
  056c8:    nop
  056cc:    nop
  056d0:    nop
  056d4:    nop
  056d8:    nop
  056dc:    nop
  056e0:    nop
  056e4:    nop
  056e8:    nop
  056ec:    nop
  056f0:    nop
  056f4:    nop
  056f8:    nop
  056fc:    nop
  05700:    nop
  05704:    nop
  05708:    nop
  0570c:    nop
  05710:    nop
  05714:    nop
  05718:    nop
  0571c:    nop
  05720:    nop
  05724:    nop
  05728:    nop
  0572c:    nop
  05730:    nop
  05734:    nop
  05738:    nop
  0573c:    nop
  05740:    nop
  05744:    nop
  05748:    nop
  0574c:    nop
  05750:    nop
  05754:    nop
  05758:    nop
  0575c:    nop
  05760:    nop
  05764:    nop
  05768:    nop
  0576c:    nop
  05770:    nop
  05774:    nop
  05778:    nop
  0577c:    nop
  05780:    nop
  05784:    nop
  05788:    nop
  0578c:    nop
  05790:    nop
  05794:    nop
  05798:    nop
  0579c:    nop
  057a0:    nop
  057a4:    nop
  057a8:    nop
  057ac:    nop
  057b0:    nop
  057b4:    nop
  057b8:    nop
  057bc:    nop
  057c0:    nop
  057c4:    nop
  057c8:    nop
  057cc:    nop
  057d0:    nop
  057d4:    nop
  057d8:    nop
  057dc:    nop
  057e0:    nop
  057e4:    nop
  057e8:    nop
  057ec:    nop
  057f0:    nop
  057f4:    nop
  057f8:    nop
  057fc:    nop
  05800:    nop
  05804:    nop
  05808:    nop
  0580c:    nop
  05810:    nop
  05814:    nop
  05818:    nop
  0581c:    nop
  05820:    nop
  05824:    nop
  05828:    nop
  0582c:    nop
  05830:    nop
  05834:    nop
  05838:    nop
  0583c:    nop
  05840:    nop
  05844:    nop
  05848:    nop
  0584c:    nop
  05850:    nop
  05854:    nop
  05858:    nop
  0585c:    nop
  05860:    nop
  05864:    nop
  05868:    nop
  0586c:    nop
  05870:    nop
  05874:    nop
  05878:    nop
  0587c:    nop
  05880:    nop
  05884:    nop
  05888:    nop
  0588c:    nop
  05890:    nop
  05894:    nop
  05898:    nop
  0589c:    nop
  058a0:    nop
  058a4:    nop
  058a8:    nop
  058ac:    nop
  058b0:    nop
  058b4:    nop
  058b8:    nop
  058bc:    nop
  058c0:    nop
  058c4:    nop
  058c8:    nop
  058cc:    nop
  058d0:    nop
  058d4:    nop
  058d8:    nop
  058dc:    nop
  058e0:    nop
  058e4:    nop
  058e8:    nop
  058ec:    nop
  058f0:    nop
  058f4:    nop
  058f8:    nop
  058fc:    nop
  05900:    nop
  05904:    nop
  05908:    nop
  0590c:    nop
  05910:    nop
  05914:    nop
  05918:    nop
  0591c:    nop
  05920:    nop
  05924:    nop
  05928:    nop
  0592c:    nop
  05930:    nop
  05934:    nop
  05938:    nop
  0593c:    nop
  05940:    nop
  05944:    nop
  05948:    nop
  0594c:    nop
  05950:    nop
  05954:    nop
  05958:    nop
  0595c:    nop
  05960:    nop
  05964:    nop
  05968:    nop
  0596c:    nop
  05970:    nop
  05974:    nop
  05978:    nop
  0597c:    nop
  05980:    nop
  05984:    nop
  05988:    nop
  0598c:    nop
  05990:    nop
  05994:    nop
  05998:    nop
  0599c:    nop
  059a0:    nop
  059a4:    nop
  059a8:    nop
  059ac:    nop
  059b0:    nop
  059b4:    nop
  059b8:    nop
  059bc:    nop
  059c0:    nop
  059c4:    nop
  059c8:    nop
  059cc:    nop
  059d0:    nop
  059d4:    nop
  059d8:    nop
  059dc:    nop
  059e0:    nop
  059e4:    nop
  059e8:    nop
  059ec:    nop
  059f0:    nop
  059f4:    nop
  059f8:    nop
  059fc:    nop
  05a00:    nop
  05a04:    nop
  05a08:    nop
  05a0c:    nop
  05a10:    nop
  05a14:    nop
  05a18:    nop
  05a1c:    nop
  05a20:    nop
  05a24:    nop
  05a28:    nop
  05a2c:    nop
  05a30:    nop
  05a34:    nop
  05a38:    nop
  05a3c:    nop
  05a40:    nop
  05a44:    nop
  05a48:    nop
  05a4c:    nop
  05a50:    nop
  05a54:    nop
  05a58:    nop
  05a5c:    nop
  05a60:    nop
  05a64:    nop
  05a68:    nop
  05a6c:    nop
  05a70:    nop
  05a74:    nop
  05a78:    nop
  05a7c:    nop
  05a80:    nop
  05a84:    nop
  05a88:    nop
  05a8c:    nop
  05a90:    nop
  05a94:    nop
  05a98:    nop
  05a9c:    nop
  05aa0:    nop
  05aa4:    nop
  05aa8:    nop
  05aac:    nop
  05ab0:    nop
  05ab4:    nop
  05ab8:    nop
  05abc:    nop
  05ac0:    nop
  05ac4:    nop
  05ac8:    nop
  05acc:    nop
  05ad0:    nop
  05ad4:    nop
  05ad8:    nop
  05adc:    nop
  05ae0:    nop
  05ae4:    nop
  05ae8:    nop
  05aec:    nop
  05af0:    nop
  05af4:    nop
  05af8:    nop
  05afc:    nop
  05b00:    nop
  05b04:    nop
  05b08:    nop
  05b0c:    nop
  05b10:    nop
  05b14:    nop
  05b18:    nop
  05b1c:    nop
  05b20:    nop
  05b24:    nop
  05b28:    nop
  05b2c:    nop
  05b30:    nop
  05b34:    nop
  05b38:    nop
  05b3c:    nop
  05b40:    nop
  05b44:    nop
  05b48:    nop
  05b4c:    nop
  05b50:    nop
  05b54:    nop
  05b58:    nop
  05b5c:    nop
  05b60:    nop
  05b64:    nop
  05b68:    nop
  05b6c:    nop
  05b70:    nop
  05b74:    nop
  05b78:    nop
  05b7c:    nop
  05b80:    nop
  05b84:    nop
  05b88:    nop
  05b8c:    nop
  05b90:    nop
  05b94:    nop
  05b98:    nop
  05b9c:    nop
  05ba0:    nop
  05ba4:    nop
  05ba8:    nop
  05bac:    nop
  05bb0:    nop
  05bb4:    nop
  05bb8:    nop
  05bbc:    nop
  05bc0:    nop
  05bc4:    nop
  05bc8:    nop
  05bcc:    nop
  05bd0:    nop
  05bd4:    nop
  05bd8:    nop
  05bdc:    nop
  05be0:    nop
  05be4:    nop
  05be8:    nop
  05bec:    nop
  05bf0:    nop
  05bf4:    nop
  05bf8:    nop
  05bfc:    nop
  05c00:    nop
  05c04:    nop
  05c08:    nop
  05c0c:    nop
  05c10:    nop
  05c14:    nop
  05c18:    nop
  05c1c:    nop
  05c20:    nop
  05c24:    nop
  05c28:    nop
  05c2c:    nop
  05c30:    nop
  05c34:    nop
  05c38:    nop
  05c3c:    nop
  05c40:    nop
  05c44:    nop
  05c48:    nop
  05c4c:    nop
  05c50:    nop
  05c54:    nop
  05c58:    nop
  05c5c:    nop
  05c60:    nop
  05c64:    nop
  05c68:    nop
  05c6c:    nop
  05c70:    nop
  05c74:    nop
  05c78:    nop
  05c7c:    nop
  05c80:    nop
  05c84:    nop
  05c88:    nop
  05c8c:    nop
  05c90:    nop
  05c94:    nop
  05c98:    nop
  05c9c:    nop
  05ca0:    nop
  05ca4:    nop
  05ca8:    nop
  05cac:    nop
  05cb0:    nop
  05cb4:    nop
  05cb8:    nop
  05cbc:    nop
  05cc0:    nop
  05cc4:    nop
  05cc8:    nop
  05ccc:    nop
  05cd0:    nop
  05cd4:    nop
  05cd8:    nop
  05cdc:    nop
  05ce0:    nop
  05ce4:    nop
  05ce8:    nop
  05cec:    nop
  05cf0:    nop
  05cf4:    nop
  05cf8:    nop
  05cfc:    nop
  05d00:    nop
  05d04:    nop
  05d08:    nop
  05d0c:    nop
  05d10:    nop
  05d14:    nop
  05d18:    nop
  05d1c:    nop
  05d20:    nop
  05d24:    nop
  05d28:    nop
  05d2c:    nop
  05d30:    nop
  05d34:    nop
  05d38:    nop
  05d3c:    nop
  05d40:    nop
  05d44:    nop
  05d48:    nop
  05d4c:    nop
  05d50:    nop
  05d54:    nop
  05d58:    nop
  05d5c:    nop
  05d60:    nop
  05d64:    nop
  05d68:    nop
  05d6c:    nop
  05d70:    nop
  05d74:    nop
  05d78:    nop
  05d7c:    nop
  05d80:    nop
  05d84:    nop
  05d88:    nop
  05d8c:    nop
  05d90:    nop
  05d94:    nop
  05d98:    nop
  05d9c:    nop
  05da0:    nop
  05da4:    nop
  05da8:    nop
  05dac:    nop
  05db0:    nop
  05db4:    nop
  05db8:    nop
  05dbc:    nop
  05dc0:    nop
  05dc4:    nop
  05dc8:    nop
  05dcc:    nop
  05dd0:    nop
  05dd4:    nop
  05dd8:    nop
  05ddc:    nop
  05de0:    nop
  05de4:    nop
  05de8:    nop
  05dec:    nop
  05df0:    nop
  05df4:    nop
  05df8:    nop
  05dfc:    nop
  05e00:    nop
  05e04:    nop
  05e08:    nop
  05e0c:    nop
  05e10:    nop
  05e14:    nop
  05e18:    nop
  05e1c:    nop
  05e20:    nop
  05e24:    nop
  05e28:    nop
  05e2c:    nop
  05e30:    nop
  05e34:    nop
  05e38:    nop
  05e3c:    nop
  05e40:    nop
  05e44:    nop
  05e48:    nop
  05e4c:    nop
  05e50:    nop
  05e54:    nop
  05e58:    nop
  05e5c:    nop
  05e60:    nop
  05e64:    nop
  05e68:    nop
  05e6c:    nop
  05e70:    nop
  05e74:    nop
  05e78:    nop
  05e7c:    nop
  05e80:    nop
  05e84:    nop
  05e88:    nop
  05e8c:    nop
  05e90:    nop
  05e94:    nop
  05e98:    nop
  05e9c:    nop
  05ea0:    nop
  05ea4:    nop
  05ea8:    nop
  05eac:    nop
  05eb0:    nop
  05eb4:    nop
  05eb8:    nop
  05ebc:    nop
  05ec0:    nop
  05ec4:    nop
  05ec8:    nop
  05ecc:    nop
  05ed0:    nop
  05ed4:    nop
  05ed8:    nop
  05edc:    nop
  05ee0:    nop
  05ee4:    nop
  05ee8:    nop
  05eec:    nop
  05ef0:    nop
  05ef4:    nop
  05ef8:    nop
  05efc:    nop
  05f00:    nop
  05f04:    nop
  05f08:    nop
  05f0c:    nop
  05f10:    nop
  05f14:    nop
  05f18:    nop
  05f1c:    nop
  05f20:    nop
  05f24:    nop
  05f28:    nop
  05f2c:    nop
  05f30:    nop
  05f34:    nop
  05f38:    nop
  05f3c:    nop
  05f40:    nop
  05f44:    nop
  05f48:    nop
  05f4c:    nop
  05f50:    nop
  05f54:    nop
  05f58:    nop
  05f5c:    nop
  05f60:    nop
  05f64:    nop
  05f68:    nop
  05f6c:    nop
  05f70:    nop
  05f74:    nop
  05f78:    nop
  05f7c:    nop
  05f80:    nop
  05f84:    nop
  05f88:    nop
  05f8c:    nop
  05f90:    nop
  05f94:    nop
  05f98:    nop
  05f9c:    nop
  05fa0:    nop
  05fa4:    nop
  05fa8:    nop
  05fac:    nop
  05fb0:    nop
  05fb4:    nop
  05fb8:    nop
  05fbc:    nop
  05fc0:    nop
  05fc4:    nop
  05fc8:    nop
  05fcc:    nop
  05fd0:    nop
  05fd4:    nop
  05fd8:    nop
  05fdc:    nop
  05fe0:    nop
  05fe4:    nop
  05fe8:    nop
  05fec:    nop
  05ff0:    nop
  05ff4:    nop
  05ff8:    nop
  05ffc:    nop
  06000:    nop
  06004:    nop
  06008:    nop
  0600c:    nop
  06010:    nop
  06014:    nop
  06018:    nop
  0601c:    nop
  06020:    nop
  06024:    nop
  06028:    nop
  0602c:    nop
  06030:    nop
  06034:    nop
  06038:    nop
  0603c:    nop
  06040:    nop
  06044:    nop
  06048:    nop
  0604c:    nop
  06050:    nop
  06054:    nop
  06058:    nop
  0605c:    nop
  06060:    nop
  06064:    nop
  06068:    nop
  0606c:    nop
  06070:    nop
  06074:    nop
  06078:    nop
  0607c:    nop
  06080:    nop
  06084:    nop
  06088:    nop
  0608c:    nop
  06090:    nop
  06094:    nop
  06098:    nop
  0609c:    nop
  060a0:    nop
  060a4:    nop
  060a8:    nop
  060ac:    nop
  060b0:    nop
  060b4:    nop
  060b8:    nop
  060bc:    nop
  060c0:    nop
  060c4:    nop
  060c8:    nop
  060cc:    nop
  060d0:    nop
  060d4:    nop
  060d8:    nop
  060dc:    nop
  060e0:    nop
  060e4:    nop
  060e8:    nop
  060ec:    nop
  060f0:    nop
  060f4:    nop
  060f8:    nop
  060fc:    nop
  06100:    nop
  06104:    nop
  06108:    nop
  0610c:    nop
  06110:    nop
  06114:    nop
  06118:    nop
  0611c:    nop
  06120:    nop
  06124:    nop
  06128:    nop
  0612c:    nop
  06130:    nop
  06134:    nop
  06138:    nop
  0613c:    nop
  06140:    nop
  06144:    nop
  06148:    nop
  0614c:    nop
  06150:    nop
  06154:    nop
  06158:    nop
  0615c:    nop
  06160:    nop
  06164:    nop
  06168:    nop
  0616c:    nop
  06170:    nop
  06174:    nop
  06178:    nop
  0617c:    nop
  06180:    nop
  06184:    nop
  06188:    nop
  0618c:    nop
  06190:    nop
  06194:    nop
  06198:    nop
  0619c:    nop
  061a0:    nop
  061a4:    nop
  061a8:    nop
  061ac:    nop
  061b0:    nop
  061b4:    nop
  061b8:    nop
  061bc:    nop
  061c0:    nop
  061c4:    nop
  061c8:    nop
  061cc:    nop
  061d0:    nop
  061d4:    nop
  061d8:    nop
  061dc:    nop
  061e0:    nop
  061e4:    nop
  061e8:    nop
  061ec:    nop
  061f0:    nop
  061f4:    nop
  061f8:    nop
  061fc:    nop
  06200:    nop
  06204:    nop
  06208:    nop
  0620c:    nop
  06210:    nop
  06214:    nop
  06218:    nop
  0621c:    nop
  06220:    nop
  06224:    nop
  06228:    nop
  0622c:    nop
  06230:    nop
  06234:    nop
  06238:    nop
  0623c:    nop
  06240:    nop
  06244:    nop
  06248:    nop
  0624c:    nop
  06250:    nop
  06254:    nop
  06258:    nop
  0625c:    nop
  06260:    nop
  06264:    nop
  06268:    nop
  0626c:    nop
  06270:    nop
  06274:    nop
  06278:    nop
  0627c:    nop
  06280:    nop
  06284:    nop
  06288:    nop
  0628c:    nop
  06290:    nop
  06294:    nop
  06298:    nop
  0629c:    nop
  062a0:    nop
  062a4:    nop
  062a8:    nop
  062ac:    nop
  062b0:    nop
  062b4:    nop
  062b8:    nop
  062bc:    nop
  062c0:    nop
  062c4:    nop
  062c8:    nop
  062cc:    nop
  062d0:    nop
  062d4:    nop
  062d8:    nop
  062dc:    nop
  062e0:    nop
  062e4:    nop
  062e8:    nop
  062ec:    nop
  062f0:    nop
  062f4:    nop
  062f8:    nop
  062fc:    nop
  06300:    nop
  06304:    nop
  06308:    nop
  0630c:    nop
  06310:    nop
  06314:    nop
  06318:    nop
  0631c:    nop
  06320:    nop
  06324:    nop
  06328:    nop
  0632c:    nop
  06330:    nop
  06334:    nop
  06338:    nop
  0633c:    nop
  06340:    nop
  06344:    nop
  06348:    nop
  0634c:    nop
  06350:    nop
  06354:    nop
  06358:    nop
  0635c:    nop
  06360:    nop
  06364:    nop
  06368:    nop
  0636c:    nop
  06370:    nop
  06374:    nop
  06378:    nop
  0637c:    nop
  06380:    nop
  06384:    nop
  06388:    nop
  0638c:    nop
  06390:    nop
  06394:    nop
  06398:    nop
  0639c:    nop
  063a0:    nop
  063a4:    nop
  063a8:    nop
  063ac:    nop
  063b0:    nop
  063b4:    nop
  063b8:    nop
  063bc:    nop
  063c0:    nop
  063c4:    nop
  063c8:    nop
  063cc:    nop
  063d0:    nop
  063d4:    nop
  063d8:    nop
  063dc:    nop
  063e0:    nop
  063e4:    nop
  063e8:    nop
  063ec:    nop
  063f0:    nop
  063f4:    nop
  063f8:    nop
  063fc:    nop
  06400:    nop
  06404:    nop
  06408:    nop
  0640c:    nop
  06410:    nop
  06414:    nop
  06418:    nop
  0641c:    nop
  06420:    nop
  06424:    nop
  06428:    nop
  0642c:    nop
  06430:    nop
  06434:    nop
  06438:    nop
  0643c:    nop
  06440:    nop
  06444:    nop
  06448:    nop
  0644c:    nop
  06450:    nop
  06454:    nop
  06458:    nop
  0645c:    nop
  06460:    nop
  06464:    nop
  06468:    nop
  0646c:    nop
  06470:    nop
  06474:    nop
  06478:    nop
  0647c:    nop
  06480:    nop
  06484:    nop
  06488:    nop
  0648c:    nop
  06490:    nop
  06494:    nop
  06498:    nop
  0649c:    nop
  064a0:    nop
  064a4:    nop
  064a8:    nop
  064ac:    nop
  064b0:    nop
  064b4:    nop
  064b8:    nop
  064bc:    nop
  064c0:    nop
  064c4:    nop
  064c8:    nop
  064cc:    nop
  064d0:    nop
  064d4:    nop
  064d8:    nop
  064dc:    nop
  064e0:    nop
  064e4:    nop
  064e8:    nop
  064ec:    nop
  064f0:    nop
  064f4:    nop
  064f8:    nop
  064fc:    nop
  06500:    nop
  06504:    nop
  06508:    nop
  0650c:    nop
  06510:    nop
  06514:    nop
  06518:    nop
  0651c:    nop
  06520:    nop
  06524:    nop
  06528:    nop
  0652c:    nop
  06530:    nop
  06534:    nop
  06538:    nop
  0653c:    nop
  06540:    nop
  06544:    nop
  06548:    nop
  0654c:    nop
  06550:    nop
  06554:    nop
  06558:    nop
  0655c:    nop
  06560:    nop
  06564:    nop
  06568:    nop
  0656c:    nop

PKT_0x8504:
  06570:    nop
  06574:    nop
  06578:    nop
  0657c:    nop
  06580:    nop
  06584:    nop
  06588:    nop
  0658c:    nop
  06590:    nop
  06594:    nop
  06598:    nop
  0659c:    nop
  065a0:    nop
  065a4:    nop
  065a8:    nop
  065ac:    nop
  065b0:    nop
  065b4:    nop
  065b8:    nop
  065bc:    nop
  065c0:    nop
  065c4:    nop
  065c8:    nop
  065cc:    nop
  065d0:    nop
  065d4:    nop
  065d8:    nop
  065dc:    nop
  065e0:    nop
  065e4:    nop
  065e8:    nop
  065ec:    nop
  065f0:    nop
  065f4:    nop
  065f8:    nop
  065fc:    nop
  06600:    nop
  06604:    nop
  06608:    nop
  0660c:    nop
  06610:    nop
  06614:    nop
  06618:    nop
  0661c:    nop
  06620:    nop
  06624:    nop
  06628:    nop
  0662c:    nop
  06630:    nop
  06634:    nop
  06638:    nop

PKT_0x9cd7:
  0663c:    nop
  06640:    nop
  06644:    nop
  06648:    nop
  0664c:    nop
  06650:    nop
  06654:    nop
  06658:    nop
  0665c:    nop
  06660:    nop
  06664:    nop
  06668:    nop
  0666c:    nop
  06670:    nop
  06674:    nop
  06678:    nop
  0667c:    nop
  06680:    nop
  06684:    nop
  06688:    nop
  0668c:    nop
  06690:    nop
  06694:    nop
  06698:    nop
  0669c:    nop
  066a0:    nop
  066a4:    nop
  066a8:    nop
  066ac:    nop
  066b0:    nop
  066b4:    nop
  066b8:    nop
  066bc:    nop
  066c0:    nop
  066c4:    nop
  066c8:    nop
  066cc:    nop
  066d0:    nop
  066d4:    nop
  066d8:    nop
  066dc:    nop
  066e0:    nop
  066e4:    nop
  066e8:    nop
  066ec:    nop
  066f0:    nop
  066f4:    nop
  066f8:    nop
  066fc:    nop
  06700:    nop
  06704:    nop
  06708:    nop
  0670c:    nop
  06710:    nop
  06714:    nop
  06718:    nop
  0671c:    nop
  06720:    nop
  06724:    nop
  06728:    nop
  0672c:    nop
  06730:    nop
  06734:    nop
  06738:    nop
  0673c:    nop
  06740:    nop
  06744:    nop
  06748:    nop
  0674c:    nop
  06750:    nop
  06754:    nop
  06758:    nop
  0675c:    nop
  06760:    nop
  06764:    nop
  06768:    nop
  0676c:    nop
  06770:    nop
  06774:    nop
  06778:    nop
  0677c:    nop
  06780:    nop
  06784:    nop
  06788:    nop
  0678c:    nop
  06790:    nop
  06794:    nop
  06798:    nop
  0679c:    nop
  067a0:    nop
  067a4:    nop
  067a8:    nop
  067ac:    nop
  067b0:    nop
  067b4:    nop
  067b8:    nop
  067bc:    nop
  067c0:    nop
  067c4:    nop
  067c8:    nop
  067cc:    nop
  067d0:    nop
  067d4:    nop
  067d8:    nop
  067dc:    nop
  067e0:    nop
  067e4:    nop
  067e8:    nop
  067ec:    nop
  067f0:    nop
  067f4:    nop
  067f8:    nop
  067fc:    nop
  06800:    nop
  06804:    nop
  06808:    nop
  0680c:    nop
  06810:    nop
  06814:    nop
  06818:    nop
  0681c:    nop
  06820:    nop
  06824:    nop
  06828:    nop
  0682c:    nop
  06830:    nop
  06834:    nop
  06838:    nop
  0683c:    nop
  06840:    nop
  06844:    nop
  06848:    nop
  0684c:    nop
  06850:    nop
  06854:    nop
  06858:    nop
  0685c:    nop
  06860:    nop
  06864:    nop
  06868:    nop
  0686c:    nop
  06870:    nop
  06874:    nop
  06878:    nop
  0687c:    nop
  06880:    nop
  06884:    nop
  06888:    nop
  0688c:    nop
  06890:    nop
  06894:    nop
  06898:    nop
  0689c:    nop
  068a0:    nop
  068a4:    nop
  068a8:    nop
  068ac:    nop
  068b0:    nop
  068b4:    nop
  068b8:    nop
  068bc:    nop
  068c0:    nop
  068c4:    nop
  068c8:    nop
  068cc:    nop
  068d0:    nop
  068d4:    nop
  068d8:    nop
  068dc:    nop
  068e0:    nop
  068e4:    nop
  068e8:    nop
  068ec:    nop
  068f0:    nop
  068f4:    nop
  068f8:    nop
  068fc:    nop
  06900:    nop
  06904:    nop
  06908:    nop
  0690c:    nop
  06910:    nop
  06914:    nop
  06918:    nop
  0691c:    nop
  06920:    nop
  06924:    nop
  06928:    nop
  0692c:    nop
  06930:    nop
  06934:    nop
  06938:    nop
  0693c:    nop
  06940:    nop
  06944:    nop
  06948:    nop
  0694c:    nop
  06950:    nop
  06954:    nop
  06958:    nop
  0695c:    nop
  06960:    nop
  06964:    nop
  06968:    nop
  0696c:    nop
  06970:    nop
  06974:    nop
  06978:    nop
  0697c:    nop
  06980:    nop
  06984:    nop
  06988:    nop
  0698c:    nop
  06990:    nop
  06994:    nop
  06998:    nop
  0699c:    nop
  069a0:    nop
  069a4:    nop
  069a8:    nop
  069ac:    nop
  069b0:    nop
  069b4:    nop
  069b8:    nop
  069bc:    nop
  069c0:    nop
  069c4:    nop
  069c8:    nop
  069cc:    nop
  069d0:    nop
  069d4:    nop
  069d8:    nop
  069dc:    nop
  069e0:    nop
  069e4:    nop
  069e8:    nop
  069ec:    nop
  069f0:    nop
  069f4:    nop
  069f8:    nop
  069fc:    nop
  06a00:    nop
  06a04:    nop
  06a08:    nop
  06a0c:    nop
  06a10:    nop
  06a14:    nop
  06a18:    nop
  06a1c:    nop
  06a20:    nop
  06a24:    nop
  06a28:    nop
  06a2c:    nop
  06a30:    nop
  06a34:    nop
  06a38:    nop
  06a3c:    nop
  06a40:    nop
  06a44:    nop
  06a48:    nop
  06a4c:    nop
  06a50:    nop
  06a54:    nop
  06a58:    nop
  06a5c:    nop
  06a60:    nop
  06a64:    nop
  06a68:    nop
  06a6c:    nop
  06a70:    nop
  06a74:    nop
  06a78:    nop
  06a7c:    nop
  06a80:    nop
  06a84:    nop
  06a88:    nop
  06a8c:    nop
  06a90:    nop
  06a94:    nop
  06a98:    nop
  06a9c:    nop
  06aa0:    nop
  06aa4:    nop
  06aa8:    nop
  06aac:    nop
  06ab0:    nop
  06ab4:    nop
  06ab8:    nop
  06abc:    nop
  06ac0:    nop
  06ac4:    nop
  06ac8:    nop
  06acc:    nop
  06ad0:    nop
  06ad4:    nop
  06ad8:    nop
  06adc:    nop
  06ae0:    nop
  06ae4:    nop
  06ae8:    nop
  06aec:    nop
  06af0:    nop
  06af4:    nop
  06af8:    nop
  06afc:    nop
  06b00:    nop
  06b04:    nop
  06b08:    nop
  06b0c:    nop
  06b10:    nop
  06b14:    nop
  06b18:    nop
  06b1c:    nop
  06b20:    nop
  06b24:    nop
  06b28:    nop
  06b2c:    nop
  06b30:    nop
  06b34:    nop
  06b38:    nop
  06b3c:    nop
  06b40:    nop
  06b44:    nop
  06b48:    nop
  06b4c:    nop
  06b50:    nop
  06b54:    nop
  06b58:    nop
  06b5c:    nop
  06b60:    nop
  06b64:    nop
  06b68:    nop
  06b6c:    nop
  06b70:    nop
  06b74:    nop
  06b78:    nop
  06b7c:    nop
  06b80:    nop
  06b84:    nop
  06b88:    nop
  06b8c:    nop
  06b90:    nop
  06b94:    nop
  06b98:    nop
  06b9c:    nop
  06ba0:    nop
  06ba4:    nop
  06ba8:    nop
  06bac:    nop
  06bb0:    nop
  06bb4:    nop
  06bb8:    nop
  06bbc:    nop
  06bc0:    nop
  06bc4:    nop
  06bc8:    nop
  06bcc:    nop
  06bd0:    nop
  06bd4:    nop
  06bd8:    nop
  06bdc:    nop
  06be0:    nop
  06be4:    nop
  06be8:    nop
  06bec:    nop
  06bf0:    nop
  06bf4:    nop
  06bf8:    nop
  06bfc:    nop
  06c00:    nop
  06c04:    nop
  06c08:    nop
  06c0c:    nop
  06c10:    nop
  06c14:    nop
  06c18:    nop
  06c1c:    nop
  06c20:    nop
  06c24:    nop
  06c28:    nop
  06c2c:    nop
  06c30:    nop
  06c34:    nop
  06c38:    nop
  06c3c:    nop
  06c40:    nop
  06c44:    nop
  06c48:    nop
  06c4c:    nop
  06c50:    nop
  06c54:    nop
  06c58:    nop
  06c5c:    nop
  06c60:    nop
  06c64:    nop
  06c68:    nop
  06c6c:    nop
  06c70:    nop
  06c74:    nop
  06c78:    nop
  06c7c:    nop
  06c80:    nop
  06c84:    nop
  06c88:    nop
  06c8c:    nop
  06c90:    nop
  06c94:    nop
  06c98:    nop
  06c9c:    nop
  06ca0:    nop
  06ca4:    nop
  06ca8:    nop
  06cac:    nop
  06cb0:    nop
  06cb4:    nop
  06cb8:    nop
  06cbc:    nop
  06cc0:    nop
  06cc4:    nop
  06cc8:    nop
  06ccc:    nop
  06cd0:    nop
  06cd4:    nop
  06cd8:    nop
  06cdc:    nop
  06ce0:    nop
  06ce4:    nop
  06ce8:    nop
  06cec:    nop
  06cf0:    nop
  06cf4:    nop
  06cf8:    nop
  06cfc:    nop
  06d00:    nop
  06d04:    nop
  06d08:    nop
  06d0c:    nop
  06d10:    nop
  06d14:    nop
  06d18:    nop
  06d1c:    nop
  06d20:    nop
  06d24:    nop
  06d28:    nop
  06d2c:    nop
  06d30:    nop
  06d34:    nop
  06d38:    nop
  06d3c:    nop
  06d40:    nop
  06d44:    nop
  06d48:    nop
  06d4c:    nop
  06d50:    nop
  06d54:    nop
  06d58:    nop
  06d5c:    nop
  06d60:    nop
  06d64:    nop
  06d68:    nop
  06d6c:    nop
  06d70:    nop
  06d74:    nop
  06d78:    nop
  06d7c:    nop
  06d80:    nop
  06d84:    nop
  06d88:    nop
  06d8c:    nop
  06d90:    nop
  06d94:    nop
  06d98:    nop
  06d9c:    nop
  06da0:    nop
  06da4:    nop
  06da8:    nop
  06dac:    nop
  06db0:    nop
  06db4:    nop
  06db8:    nop
  06dbc:    nop
  06dc0:    nop
  06dc4:    nop
  06dc8:    nop
  06dcc:    nop
  06dd0:    nop
  06dd4:    nop
  06dd8:    nop
  06ddc:    nop
  06de0:    nop
  06de4:    nop
  06de8:    nop
  06dec:    nop
  06df0:    nop
  06df4:    nop
  06df8:    nop
  06dfc:    nop
  06e00:    nop
  06e04:    nop
  06e08:    nop
  06e0c:    nop
  06e10:    nop
  06e14:    nop
  06e18:    nop
  06e1c:    nop
  06e20:    nop
  06e24:    nop
  06e28:    nop
  06e2c:    nop
  06e30:    nop
  06e34:    nop
  06e38:    nop
  06e3c:    nop
  06e40:    nop
  06e44:    nop
  06e48:    nop
  06e4c:    nop
  06e50:    nop
  06e54:    nop
  06e58:    nop
  06e5c:    nop
  06e60:    nop
  06e64:    nop
  06e68:    nop
  06e6c:    nop
  06e70:    nop
  06e74:    nop
  06e78:    nop
  06e7c:    nop
  06e80:    nop
  06e84:    nop
  06e88:    nop
  06e8c:    nop
  06e90:    nop
  06e94:    nop
  06e98:    nop
  06e9c:    nop
  06ea0:    nop
  06ea4:    nop
  06ea8:    nop
  06eac:    nop
  06eb0:    nop
  06eb4:    nop
  06eb8:    nop
  06ebc:    nop
  06ec0:    nop
  06ec4:    nop
  06ec8:    nop
  06ecc:    nop
  06ed0:    nop
  06ed4:    nop
  06ed8:    nop
  06edc:    nop
  06ee0:    nop
  06ee4:    nop
  06ee8:    nop
  06eec:    nop
  06ef0:    nop
  06ef4:    nop
  06ef8:    nop
  06efc:    nop
  06f00:    nop
  06f04:    nop
  06f08:    nop
  06f0c:    nop
  06f10:    nop
  06f14:    nop
  06f18:    nop
  06f1c:    nop
  06f20:    nop
  06f24:    nop
  06f28:    nop
  06f2c:    nop
  06f30:    nop
  06f34:    nop
  06f38:    nop
  06f3c:    nop
  06f40:    nop
  06f44:    nop
  06f48:    nop
  06f4c:    nop
  06f50:    nop
  06f54:    nop
  06f58:    nop
  06f5c:    nop
  06f60:    nop
  06f64:    nop
  06f68:    nop
  06f6c:    nop
  06f70:    nop
  06f74:    nop
  06f78:    nop
  06f7c:    nop
  06f80:    nop
  06f84:    nop
  06f88:    nop
  06f8c:    nop
  06f90:    nop
  06f94:    nop
  06f98:    nop
  06f9c:    nop
  06fa0:    nop
  06fa4:    nop
  06fa8:    nop
  06fac:    nop
  06fb0:    nop
  06fb4:    nop
  06fb8:    nop
  06fbc:    nop
  06fc0:    nop
  06fc4:    nop
  06fc8:    nop
  06fcc:    nop
  06fd0:    nop
  06fd4:    nop
  06fd8:    nop
  06fdc:    nop
  06fe0:    nop
  06fe4:    nop
  06fe8:    nop
  06fec:    nop
  06ff0:    nop
  06ff4:    nop
  06ff8:    nop
  06ffc:    nop
  07000:    nop
  07004:    nop
  07008:    nop
  0700c:    nop
  07010:    nop
  07014:    nop
  07018:    nop
  0701c:    nop
  07020:    nop
  07024:    nop
  07028:    nop
  0702c:    nop
  07030:    nop
  07034:    nop
  07038:    nop
  0703c:    nop
  07040:    nop
  07044:    nop
  07048:    nop
  0704c:    nop
  07050:    nop
  07054:    nop
  07058:    nop
  0705c:    nop
  07060:    nop
  07064:    nop
  07068:    nop
  0706c:    nop
  07070:    nop
  07074:    nop
  07078:    nop
  0707c:    nop
  07080:    nop
  07084:    nop
  07088:    nop
  0708c:    nop
  07090:    nop
  07094:    nop
  07098:    nop
  0709c:    nop
  070a0:    nop
  070a4:    nop
  070a8:    nop
  070ac:    nop
  070b0:    nop
  070b4:    nop
  070b8:    nop
  070bc:    nop
  070c0:    nop
  070c4:    nop
  070c8:    nop
  070cc:    nop
  070d0:    nop
  070d4:    nop
  070d8:    nop
  070dc:    nop
  070e0:    nop
  070e4:    nop
  070e8:    nop
  070ec:    nop
  070f0:    nop
  070f4:    nop
  070f8:    nop
  070fc:    nop
  07100:    nop
  07104:    nop
  07108:    nop
  0710c:    nop
  07110:    nop
  07114:    nop
  07118:    nop
  0711c:    nop
  07120:    nop
  07124:    nop
  07128:    nop
  0712c:    nop
  07130:    nop
  07134:    nop
  07138:    nop
  0713c:    nop
  07140:    nop
  07144:    nop
  07148:    nop
  0714c:    nop
  07150:    nop
  07154:    nop
  07158:    nop
  0715c:    nop
  07160:    nop
  07164:    nop
  07168:    nop
  0716c:    nop
  07170:    nop
  07174:    nop
  07178:    nop
  0717c:    nop
  07180:    nop
  07184:    nop
  07188:    nop
  0718c:    nop
  07190:    nop
  07194:    nop
  07198:    nop
  0719c:    nop
  071a0:    nop
  071a4:    nop
  071a8:    nop
  071ac:    nop
  071b0:    nop
  071b4:    nop
  071b8:    nop
  071bc:    nop
  071c0:    nop
  071c4:    nop
  071c8:    nop
  071cc:    nop
  071d0:    nop
  071d4:    nop
  071d8:    nop
  071dc:    nop
  071e0:    nop
  071e4:    nop
  071e8:    nop
  071ec:    nop
  071f0:    nop
  071f4:    nop
  071f8:    nop
  071fc:    nop
  07200:    nop
  07204:    nop
  07208:    nop
  0720c:    nop
  07210:    nop
  07214:    nop
  07218:    nop
  0721c:    nop
  07220:    nop
  07224:    nop
  07228:    nop
  0722c:    nop
  07230:    nop
  07234:    nop
  07238:    nop
  0723c:    nop
  07240:    nop
  07244:    nop
  07248:    nop
  0724c:    nop
  07250:    nop
  07254:    nop
  07258:    nop
  0725c:    nop
  07260:    nop
  07264:    nop
  07268:    nop
  0726c:    nop
  07270:    nop
  07274:    nop
  07278:    nop
  0727c:    nop
  07280:    nop
  07284:    nop
  07288:    nop
  0728c:    nop
  07290:    nop
  07294:    nop
  07298:    nop
  0729c:    nop
  072a0:    nop
  072a4:    nop
  072a8:    nop
  072ac:    nop
  072b0:    nop
  072b4:    nop
  072b8:    nop
  072bc:    nop
  072c0:    nop
  072c4:    nop
  072c8:    nop
  072cc:    nop
  072d0:    nop
  072d4:    nop
  072d8:    nop
  072dc:    nop
  072e0:    nop
  072e4:    nop
  072e8:    nop
  072ec:    nop
  072f0:    nop
  072f4:    nop
  072f8:    nop
  072fc:    nop
  07300:    nop
  07304:    nop
  07308:    nop
  0730c:    nop
  07310:    nop
  07314:    nop
  07318:    nop
  0731c:    nop
  07320:    nop
  07324:    nop
  07328:    nop
  0732c:    nop
  07330:    nop
  07334:    nop
  07338:    nop
  0733c:    nop
  07340:    nop
  07344:    nop
  07348:    nop
  0734c:    nop
  07350:    nop
  07354:    nop
  07358:    nop
  0735c:    nop
  07360:    nop
  07364:    nop
  07368:    nop
  0736c:    nop
  07370:    nop
  07374:    nop
  07378:    nop
  0737c:    nop
  07380:    nop
  07384:    nop
  07388:    nop
  0738c:    nop
  07390:    nop
  07394:    nop
  07398:    nop
  0739c:    nop
  073a0:    nop
  073a4:    nop
  073a8:    nop
  073ac:    nop
  073b0:    nop
  073b4:    nop
  073b8:    nop
  073bc:    nop
  073c0:    nop

PKT_0xaf07:
  073c4:    nop
  073c8:    nop
  073cc:    nop
  073d0:    nop
  073d4:    nop
  073d8:    nop
  073dc:    nop
  073e0:    nop
  073e4:    nop
  073e8:    nop
  073ec:    nop
  073f0:    nop
  073f4:    nop
  073f8:    nop
  073fc:    nop
  07400:    nop
  07404:    nop
  07408:    nop
  0740c:    nop
  07410:    nop
  07414:    nop
  07418:    nop
  0741c:    nop
  07420:    nop
  07424:    nop
  07428:    nop
  0742c:    nop
  07430:    nop
  07434:    nop
  07438:    nop
  0743c:    nop
  07440:    nop
  07444:    nop
  07448:    nop
  0744c:    nop
  07450:    nop
  07454:    nop
  07458:    nop
  0745c:    nop
  07460:    nop
  07464:    nop
  07468:    nop
  0746c:    nop
  07470:    nop
  07474:    nop
  07478:    nop
  0747c:    nop
  07480:    nop
  07484:    nop
  07488:    nop
  0748c:    nop
  07490:    nop
  07494:    nop
  07498:    nop
  0749c:    nop
  074a0:    nop
  074a4:    nop
  074a8:    nop
  074ac:    nop
  074b0:    nop
  074b4:    nop
  074b8:    nop
  074bc:    nop
  074c0:    nop
  074c4:    nop
  074c8:    nop
  074cc:    nop
  074d0:    nop
  074d4:    nop
  074d8:    nop
  074dc:    nop
  074e0:    nop
  074e4:    nop
  074e8:    nop
  074ec:    nop
  074f0:    nop
  074f4:    nop
  074f8:    nop
  074fc:    nop
  07500:    nop
  07504:    nop
  07508:    nop
  0750c:    nop
  07510:    nop
  07514:    nop
  07518:    nop
  0751c:    nop
  07520:    nop
  07524:    nop
  07528:    nop
  0752c:    nop
  07530:    nop
  07534:    nop
  07538:    nop
  0753c:    nop
  07540:    nop
  07544:    nop
  07548:    nop
  0754c:    nop
  07550:    nop
  07554:    nop
  07558:    nop
  0755c:    nop
  07560:    nop
  07564:    nop
  07568:    nop
  0756c:    nop
  07570:    nop
  07574:    nop
  07578:    nop
  0757c:    nop
  07580:    nop
  07584:    nop
  07588:    nop
  0758c:    nop
  07590:    nop
  07594:    nop
  07598:    nop
  0759c:    nop
  075a0:    nop
  075a4:    nop
  075a8:    nop
  075ac:    nop
  075b0:    nop
  075b4:    nop
  075b8:    nop
  075bc:    nop
  075c0:    nop
  075c4:    nop
  075c8:    nop

PKT_0xd3d:
  075cc:    nop
  075d0:    nop
  075d4:    nop
  075d8:    nop
  075dc:    nop
  075e0:    nop
  075e4:    nop
  075e8:    nop
  075ec:    nop
  075f0:    nop
  075f4:    nop
  075f8:    nop
  075fc:    nop
  07600:    nop
  07604:    nop
  07608:    nop
  0760c:    nop
  07610:    nop
  07614:    nop
  07618:    nop
  0761c:    nop
  07620:    nop
  07624:    nop
  07628:    nop
  0762c:    nop
  07630:    nop
  07634:    nop
  07638:    nop
  0763c:    nop
  07640:    nop
  07644:    nop
  07648:    nop
  0764c:    nop
  07650:    nop
  07654:    nop
  07658:    nop
  0765c:    nop
  07660:    nop
  07664:    nop
  07668:    nop
  0766c:    nop
  07670:    nop
  07674:    nop
  07678:    nop
  0767c:    nop
  07680:    nop
  07684:    nop
  07688:    nop
  0768c:    nop
  07690:    nop
  07694:    nop
  07698:    nop
  0769c:    nop
  076a0:    nop
  076a4:    nop
  076a8:    nop
  076ac:    nop
  076b0:    nop
  076b4:    nop
  076b8:    nop
  076bc:    nop
  076c0:    nop
  076c4:    nop
  076c8:    nop
  076cc:    nop
  076d0:    nop
  076d4:    nop
  076d8:    nop
  076dc:    nop
  076e0:    nop
  076e4:    nop
  076e8:    nop
  076ec:    nop
  076f0:    nop
  076f4:    nop
  076f8:    nop
  076fc:    nop
  07700:    nop
  07704:    nop
  07708:    nop
  0770c:    nop
  07710:    nop
  07714:    nop
  07718:    nop
  0771c:    nop
  07720:    nop
  07724:    nop
  07728:    nop
  0772c:    nop
  07730:    nop
  07734:    nop
  07738:    nop
  0773c:    nop
  07740:    nop
  07744:    nop
  07748:    nop
  0774c:    nop
  07750:    nop
  07754:    nop
  07758:    nop
  0775c:    nop
  07760:    nop
  07764:    nop
  07768:    nop
  0776c:    nop
  07770:    nop
  07774:    nop
  07778:    nop
  0777c:    nop
  07780:    nop
  07784:    nop
  07788:    nop
  0778c:    nop
  07790:    nop
  07794:    nop
  07798:    nop
  0779c:    nop
  077a0:    nop
  077a4:    nop
  077a8:    nop
  077ac:    nop
  077b0:    nop
  077b4:    nop
  077b8:    nop
  077bc:    nop
  077c0:    nop
  077c4:    nop
  077c8:    nop
  077cc:    nop
  077d0:    nop
  077d4:    nop
  077d8:    nop
  077dc:    nop
  077e0:    nop
  077e4:    nop
  077e8:    nop
  077ec:    nop
  077f0:    nop
  077f4:    nop
  077f8:    nop
  077fc:    nop
  07800:    nop
  07804:    nop
  07808:    nop
  0780c:    nop
  07810:    nop
  07814:    nop
  07818:    nop
  0781c:    nop
  07820:    nop
  07824:    nop
  07828:    nop
  0782c:    nop
  07830:    nop
  07834:    nop
  07838:    nop
  0783c:    nop
  07840:    nop
  07844:    nop
  07848:    nop
  0784c:    nop
  07850:    nop
  07854:    nop
  07858:    nop
  0785c:    nop
  07860:    nop
  07864:    nop
  07868:    nop
  0786c:    nop
  07870:    nop
  07874:    nop
  07878:    nop
  0787c:    nop
  07880:    nop
  07884:    nop
  07888:    nop
  0788c:    nop
  07890:    nop
  07894:    nop
  07898:    nop
  0789c:    nop
  078a0:    nop
  078a4:    nop
  078a8:    nop
  078ac:    nop
  078b0:    nop
  078b4:    nop
  078b8:    nop
  078bc:    nop
  078c0:    nop
  078c4:    nop
  078c8:    nop
  078cc:    nop
  078d0:    nop
  078d4:    nop
  078d8:    nop
  078dc:    nop
  078e0:    nop
  078e4:    nop
  078e8:    nop
  078ec:    nop
  078f0:    nop
  078f4:    nop
  078f8:    nop
  078fc:    nop
  07900:    nop
  07904:    nop
  07908:    nop
  0790c:    nop
  07910:    nop
  07914:    nop
  07918:    nop
  0791c:    nop
  07920:    nop
  07924:    nop
  07928:    nop
  0792c:    nop
  07930:    nop
  07934:    nop
  07938:    nop
  0793c:    nop
  07940:    nop
  07944:    nop
  07948:    nop
  0794c:    nop
  07950:    nop
  07954:    nop
  07958:    nop
  0795c:    nop
  07960:    nop
  07964:    nop
  07968:    nop
  0796c:    nop
  07970:    nop
  07974:    nop
  07978:    nop
  0797c:    nop
  07980:    nop
  07984:    nop
  07988:    nop
  0798c:    nop
  07990:    nop
  07994:    nop
  07998:    nop
  0799c:    nop
  079a0:    nop
  079a4:    nop
  079a8:    nop
  079ac:    nop
  079b0:    nop
  079b4:    nop
  079b8:    nop
  079bc:    nop
  079c0:    nop
  079c4:    nop
  079c8:    nop
  079cc:    nop
  079d0:    nop
  079d4:    nop
  079d8:    nop
  079dc:    nop
  079e0:    nop
  079e4:    nop
  079e8:    nop
  079ec:    nop
  079f0:    nop
  079f4:    nop
  079f8:    nop
  079fc:    nop
  07a00:    nop
  07a04:    nop
  07a08:    nop
  07a0c:    nop
  07a10:    nop
  07a14:    nop
  07a18:    nop
  07a1c:    nop
  07a20:    nop
  07a24:    nop
  07a28:    nop
  07a2c:    nop
  07a30:    nop
  07a34:    nop
  07a38:    nop
  07a3c:    nop
  07a40:    nop
  07a44:    nop
  07a48:    nop
  07a4c:    nop
  07a50:    nop
  07a54:    nop
  07a58:    nop
  07a5c:    nop
  07a60:    nop
  07a64:    nop
  07a68:    nop
  07a6c:    nop
  07a70:    nop
  07a74:    nop
  07a78:    nop
  07a7c:    nop
  07a80:    nop
  07a84:    nop
  07a88:    nop
  07a8c:    nop
  07a90:    nop
  07a94:    nop
  07a98:    nop
  07a9c:    nop
  07aa0:    nop
  07aa4:    nop
  07aa8:    nop
  07aac:    nop
  07ab0:    nop
  07ab4:    nop
  07ab8:    nop
  07abc:    nop
  07ac0:    nop
  07ac4:    nop
  07ac8:    nop
  07acc:    nop
  07ad0:    nop
  07ad4:    nop
  07ad8:    nop
  07adc:    nop
  07ae0:    nop
  07ae4:    nop
  07ae8:    nop
  07aec:    nop
  07af0:    nop
  07af4:    nop
  07af8:    nop
  07afc:    nop
  07b00:    nop
  07b04:    nop
  07b08:    nop
  07b0c:    nop
  07b10:    nop
  07b14:    nop
  07b18:    nop
  07b1c:    nop
  07b20:    nop
  07b24:    nop
  07b28:    nop
  07b2c:    nop
  07b30:    nop
  07b34:    nop
  07b38:    nop
  07b3c:    nop
  07b40:    nop
  07b44:    nop
  07b48:    nop
  07b4c:    nop
  07b50:    nop
  07b54:    nop
  07b58:    nop
  07b5c:    nop
  07b60:    nop
  07b64:    nop
  07b68:    nop
  07b6c:    nop
  07b70:    nop
  07b74:    nop
  07b78:    nop
  07b7c:    nop
  07b80:    nop
  07b84:    nop
  07b88:    nop
  07b8c:    nop
  07b90:    nop
  07b94:    nop
  07b98:    nop
  07b9c:    nop
  07ba0:    nop
  07ba4:    nop
  07ba8:    nop
  07bac:    nop
  07bb0:    nop
  07bb4:    nop
  07bb8:    nop
  07bbc:    nop
  07bc0:    nop
  07bc4:    nop
  07bc8:    nop
  07bcc:    nop
  07bd0:    nop
  07bd4:    nop
  07bd8:    nop
  07bdc:    nop
  07be0:    nop
  07be4:    nop
  07be8:    nop
  07bec:    nop
  07bf0:    nop
  07bf4:    nop
  07bf8:    nop
  07bfc:    nop
  07c00:    nop
  07c04:    nop
  07c08:    nop
  07c0c:    nop
  07c10:    nop
  07c14:    nop
  07c18:    nop
  07c1c:    nop
  07c20:    nop
  07c24:    nop
  07c28:    nop
  07c2c:    nop
  07c30:    nop
  07c34:    nop
  07c38:    nop
  07c3c:    nop
  07c40:    nop
  07c44:    nop
  07c48:    nop
  07c4c:    nop
  07c50:    nop
  07c54:    nop
  07c58:    nop
  07c5c:    nop
  07c60:    nop
  07c64:    nop
  07c68:    nop
  07c6c:    nop
  07c70:    nop
  07c74:    nop
  07c78:    nop
  07c7c:    nop
  07c80:    nop
  07c84:    nop
  07c88:    nop
  07c8c:    nop
  07c90:    nop
  07c94:    nop
  07c98:    nop
  07c9c:    nop
  07ca0:    nop
  07ca4:    nop
  07ca8:    nop
  07cac:    nop
  07cb0:    nop
  07cb4:    nop
  07cb8:    nop
  07cbc:    nop
  07cc0:    nop
  07cc4:    nop
  07cc8:    nop
  07ccc:    nop
  07cd0:    nop
  07cd4:    nop
  07cd8:    nop
  07cdc:    nop
  07ce0:    nop
  07ce4:    nop
  07ce8:    nop
  07cec:    nop
  07cf0:    nop
  07cf4:    nop
  07cf8:    nop
  07cfc:    nop
  07d00:    nop
  07d04:    nop
  07d08:    nop
  07d0c:    nop
  07d10:    nop
  07d14:    nop
  07d18:    nop
  07d1c:    nop
  07d20:    nop
  07d24:    nop
  07d28:    nop
  07d2c:    nop
  07d30:    nop
  07d34:    nop
  07d38:    nop
  07d3c:    nop
  07d40:    nop
  07d44:    nop
  07d48:    nop
  07d4c:    nop
  07d50:    nop
  07d54:    nop
  07d58:    nop
  07d5c:    nop
  07d60:    nop
  07d64:    nop
  07d68:    nop
  07d6c:    nop
  07d70:    nop
  07d74:    nop
  07d78:    nop
  07d7c:    nop
  07d80:    nop
  07d84:    nop
  07d88:    nop
  07d8c:    nop
  07d90:    nop
  07d94:    nop
  07d98:    nop
  07d9c:    nop
  07da0:    nop
  07da4:    nop
  07da8:    nop
  07dac:    nop
  07db0:    nop
  07db4:    nop
  07db8:    nop
  07dbc:    nop
  07dc0:    nop
  07dc4:    nop
  07dc8:    nop
  07dcc:    nop
  07dd0:    nop
  07dd4:    nop
  07dd8:    nop
  07ddc:    nop
  07de0:    nop
  07de4:    nop
  07de8:    nop
  07dec:    nop
  07df0:    nop
  07df4:    nop
  07df8:    nop
  07dfc:    nop
  07e00:    nop
  07e04:    nop
  07e08:    nop
  07e0c:    nop
  07e10:    nop
  07e14:    nop
  07e18:    nop
  07e1c:    nop
  07e20:    nop
  07e24:    nop
  07e28:    nop
  07e2c:    nop
  07e30:    nop
  07e34:    nop
  07e38:    nop
  07e3c:    nop
  07e40:    nop
  07e44:    nop
  07e48:    nop
  07e4c:    nop
  07e50:    nop
  07e54:    nop
  07e58:    nop
  07e5c:    nop
  07e60:    nop
  07e64:    nop
  07e68:    nop
  07e6c:    nop
  07e70:    nop
  07e74:    nop
  07e78:    nop
  07e7c:    nop
  07e80:    nop
  07e84:    nop
  07e88:    nop
  07e8c:    nop
  07e90:    nop
  07e94:    nop
  07e98:    nop
  07e9c:    nop
  07ea0:    nop
  07ea4:    nop
  07ea8:    nop
  07eac:    nop
  07eb0:    nop
  07eb4:    nop
  07eb8:    nop
  07ebc:    nop
  07ec0:    nop
  07ec4:    nop
  07ec8:    nop
  07ecc:    nop
  07ed0:    nop
  07ed4:    nop
  07ed8:    nop
  07edc:    nop
  07ee0:    nop
  07ee4:    nop
  07ee8:    nop
  07eec:    nop
  07ef0:    nop
  07ef4:    nop
  07ef8:    nop
  07efc:    nop
  07f00:    nop
  07f04:    nop
  07f08:    nop
  07f0c:    nop
  07f10:    nop
  07f14:    nop
  07f18:    nop
  07f1c:    nop
  07f20:    nop
  07f24:    nop
  07f28:    nop
  07f2c:    nop
  07f30:    nop
  07f34:    nop
  07f38:    nop
  07f3c:    nop
  07f40:    nop
  07f44:    nop
  07f48:    nop
  07f4c:    nop
  07f50:    nop
  07f54:    nop
  07f58:    nop
  07f5c:    nop
  07f60:    nop
  07f64:    nop
  07f68:    nop
  07f6c:    nop
  07f70:    nop
  07f74:    nop
  07f78:    nop
  07f7c:    nop
  07f80:    nop
  07f84:    nop
  07f88:    nop
  07f8c:    nop
  07f90:    nop
  07f94:    nop
  07f98:    nop
  07f9c:    nop
  07fa0:    nop
  07fa4:    nop
  07fa8:    nop
  07fac:    nop
  07fb0:    nop
  07fb4:    nop
  07fb8:    nop
  07fbc:    nop
  07fc0:    nop
  07fc4:    nop
  07fc8:    nop
  07fcc:    nop
  07fd0:    nop
  07fd4:    nop
  07fd8:    nop
  07fdc:    nop
  07fe0:    nop
  07fe4:    nop
  07fe8:    nop
  07fec:    nop
  07ff0:    nop
  07ff4:    nop
  07ff8:    nop
  07ffc:    nop
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x0] = PKT_0x0
#J[0x7ee] = PKT_0xf0
#J[0x0] = PKT_0x0
#J[NOP] = NOP
#J[SET_BASE] = SET_BASE
#J[INDEX_BUFFER_SIZE] = INDEX_BUFFER_SIZE
#J[0x14] = PKT_0x14
#J[DISPATCH_DIRECT] = DISPATCH_DIRECT
#J[DISPATCH_INDIRECT] = DISPATCH_INDIRECT
#J[INDIRECT_BUFFER_END] = INDIRECT_BUFFER_END
#J[0x18] = PKT_0x18
#J[SET_PREDICATION] = SET_PREDICATION
#J[REG_RMW] = REG_RMW
#J[0x31] = PKT_0x31
#J[INDIRECT_BUFFER_32] = INDIRECT_BUFFER_32
#J[INDIRECT_BUFFER_CONST] = INDIRECT_BUFFER_CONST
#J[STRMOUT_BUFFER_UPDATE] = STRMOUT_BUFFER_UPDATE
#J[DRAW_INDEX_OFFSET_2] = DRAW_INDEX_OFFSET_2
#J[DRAW_PREAMBLE] = DRAW_PREAMBLE
#J[COPY_DATA] = COPY_DATA
#J[DMA_DATA] = DMA_DATA
#J[LOAD_CONFIG_REG] = LOAD_CONFIG_REG
#J[0x70] = PKT_0x70
#J[0x71] = PKT_0x71
#J[LOAD_CONST_RAM] = LOAD_CONST_RAM
#J[WRITE_CONST_RAM] = WRITE_CONST_RAM
#J[0x82] = PKT_0x82
#J[DUMP_CONST_RAM] = DUMP_CONST_RAM
#J[INCREMENT_CE_COUNTER] = INCREMENT_CE_COUNTER
#J[0x90] = PKT_0x90
#J[0xa0] = PKT_0xa0
#J[0xb0] = PKT_0xb0
#J[0xb1] = PKT_0xb1
#J[0xc0] = PKT_0xc0
#J[0xc1] = PKT_0xc1
#J[0xc2] = PKT_0xc2
#J[0xc3] = PKT_0xc3
#J[0xd0] = PKT_0xd0
#J[0xd1] = PKT_0xd1
#J[0xd2] = PKT_0xd2
#J[0xe0] = PKT_0xe0
#J[0xf0] = PKT_0xf0
#J[0x100] = PKT_0x100
#J[0x110] = PKT_0x110
#J[0x7f6] = PKT_0xf0
#J[0x7f5] = PKT_0xf0
#J[0x7f4] = PKT_0xf0
#J[0x7f3] = PKT_0xf0
#J[0x7f2] = PKT_0xf0
#J[0x4] = PKT_0x4
#J[0x5] = PKT_0x5
#J[0x1] = PKT_0x1
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0xf0] = PKT_0xf0
#J[0x6504] = PKT_0x6504
#J[0x8a31] = PKT_0x8a31
#J[0xd44d] = PKT_0xd44d
#J[0x4658] = PKT_0x4658
#J[0x15c1] = PKT_0x15c1
#J[0x41a5] = PKT_0x41a5
#J[0xe1ef] = PKT_0xe1ef
#J[0x83f] = PKT_0x83f
#J[0x91c6] = PKT_0x91c6
#J[0x7dc2] = PKT_0x7dc2
#J[0xa444] = PKT_0xa444
#J[0xd3d] = PKT_0xd3d
#J[0xefaa] = PKT_0xefaa
#J[0x641] = PKT_0x641
#J[0x2f08] = PKT_0x2f08
#J[0x9cd7] = PKT_0x9cd7
#J[0xaf07] = PKT_0xaf07
#J[0x2aee] = PKT_0x2aee
#J[0x42a] = PKT_0x42a
#J[0xa927] = PKT_0xa927
#J[0x3435] = PKT_0x3435
#J[0x37b7] = PKT_0x37b7
#J[0x9294] = PKT_0x9294
#J[0x5bb9] = PKT_0x5bb9
#J[0xdace] = PKT_0xdace
#J[0xb6d4] = PKT_0xb6d4
#J[0x18e9] = PKT_0x18e9
#J[0xb0f] = PKT_0xb0f
#J[0x9ebb] = PKT_0x9ebb
#J[0x74d0] = PKT_0x74d0
#J[0x8504] = PKT_0x8504
#J[0x16cc] = PKT_0x16cc
#J[0xa26c] = PKT_0xa26c
#J[0x534c] = PKT_0x534c
#J[0xbf57] = PKT_0xbf57
#J[0xbc59] = PKT_0xbc59
#J[0x288f] = PKT_0x288f
#J[0x98cb] = PKT_0x98cb
#J[0xd5fc] = PKT_0xd5fc
#J[0x6dd4] = PKT_0x6dd4
#J[0x73bc] = PKT_0x73bc
#J[0xc780] = PKT_0xc780
#J[0x7bd] = PKT_0x7bd
#J[0x45aa] = PKT_0x45aa
#J[0x3f95] = PKT_0x3f95
#J[0x360a] = PKT_0x360a
#J[0x72ac] = PKT_0x72ac
#J[0xfe6d] = PKT_0xfe6d
#J[0x3b2a] = PKT_0x3b2a
#J[0xa7cc] = PKT_0xa7cc
#J[0x4f9e] = PKT_0x4f9e
#J[0xb651] = PKT_0xb651
#J[0x59f1] = PKT_0x59f1
#J[0x5d23] = PKT_0x5d23
#J[0xc7e8] = PKT_0xc7e8
#J[0x4096] = PKT_0x4096
#J[0xd8ae] = PKT_0xd8ae
#J[0x9c2d] = PKT_0x9c2d
#J[0xb545] = PKT_0xb545
#J[0x38d7] = PKT_0x38d7
#J[0xbc34] = PKT_0xbc34
#J[0x9926] = PKT_0x9926
#J[0x756d] = PKT_0x756d
#J[0x843d] = PKT_0x843d
