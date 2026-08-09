
PKT_0x0:
  00000:    ldw        r11, [r7, #0x40ea]
  00004:    subd       r7, r13, #0xd26e  ; b=3
  00008:    std        r6, mem[r5, #0xab47]
  0000c:    orrd       r7, r4, #0xca9  ; b=3
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
  00058:    b          _PKT_0x862a_0  
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
  000d0:    ext3b      r0, r4, #0xc844
_PKT_0x0_0:
  000d4:    eord       r2, r0, #0xffffffffffffd90a
  000d8:    hwop       r11, r14, #0xbae
  000dc:    mov        r3, #0xd82e  ; rs=r2
  000e0:    b.29       True   ; r0, r0
  000e4:    stw.e      r14, mem[r6, #0xb1a]
  000e8:    orr        r7, r8, #0x3a4a  ; b=2
  000ec:    cbz        r4, True
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
  00120:    std        r1, [r0, #0xfd]
  00124:    std        r1, [r0, #0x9b]
  00128:    std        r1, [r0, #0x9a]
  0012c:    mov        r12, #0x4a2c
  00130:    stw        r12, [r0, #0x6b]
  00134:    stw        r0, [r0, #0x64]
_PKT_0x0_1:
  00138:    ldd        r6, reg[r12, #0x0]
  0013c:    and        r3, r6, #0xfffff801
  00140:    cbz        r3, _PKT_0x0_1
  00144:    stw        r0, [r0, #0x30]
_PKT_0x0_2:
  00148:    nop
  0014c:    nop
  00150:    stw        r0, [r0, #0x76]
  00154:    stw        r0, [r0, #0x75]
  00158:    stw        r0, [r0, #0x85]
  0015c:    std        r0, [r0, #0x9b]
  00160:    std        r0, [r0, #0x9a]
  00164:    ldd        r6, reg[r0, #0x5abc]
  00168:    cbz        r6, _PKT_0x0_3
  0016c:    stw        r0, [r0, #0x42]
_PKT_0x0_3:
  00170:    stw        r0, [r0, #0x6b]
  00174:    std        r1, [r0, #0x30]
  00178:    ldd        r3, reg[r0, #0x5b44]
  0017c:    orr        r6, r3, #0x0
_PKT_0x0_4:
  00180:    stw        r6, reg[r0, #0x5b44]
  00184:    std        r0, [r0, #0xfa]

PKT_0x0:
  00188:    dw         0x84001385  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1385
  0018c:    dw         0x8400137b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x137b
  00190:    std        r1, [r0, #0x108]
  00194:    ldd        r10, reg[r0, #0x5b50]
  00198:    and        r6, r10, #0xfffff001
  0019c:    cbz        r6, _PKT_0x0_0
  001a0:    mov        r10, #0x2
  001a4:    stw        r10, [r0, #0x104]
_PKT_0x0_0:
  001a8:    ldd        r6, reg[r0, #0x7c]
  001ac:    and        r5, r6, #0xf800ffff
  001b0:    cbnz       r5, _PKT_0xe9be_60
  001b4:    stw        r0, [r0, #0x6b]
  001b8:    dw         0x84001366  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1366
  001bc:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  001c0:    ldd        r5, reg[r0, #0x5a80]
  001c4:    and        r6, r5, #0xfffff001
  001c8:    cbz        r6, _PKT_0xf0_9
  001cc:    ldd        r6, reg[r0, #0xfc]
  001d0:    cbnz       r6, _PKT_0x753b_6
_PKT_0x0_1:
  001d4:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
_PKT_0x0_2:
  001d8:    nop
  001dc:    ldd        r3, reg[r0, #0xc8]
  001e0:    cbz        r3, _NOP_0
  001e4:    stw        r0, [r0, #0xc2]
  001e8:    ldd        r6, [r0, #0xc9]
  001ec:    cbnz       r6, _PKT_0xf0_12
  001f0:    stw        r0, [r0, #0xc7]
  001f4:    and        r4, r3, #0xfffff001
  001f8:    cbnz       r4, _INDIRECT_BUFFER_END_4
  001fc:    and        r4, r3, #0xffffe003
  00200:    cbnz       r4, _DISPATCH_DIRECT_0
  00204:    and        r4, r3, #0xffff800f
  00208:    cbnz       r4, _SET_BASE_11

NOP:
  0020c:    and        r4, r3, #0xfff800ff
  00210:    cbnz       r4, _DISPATCH_INDIRECT_1
  00214:    and        r4, r3, #0xf800ffff
  00218:    cbnz       r4, _REG_RMW_2
_NOP_0:
  0021c:    ldd        r6, reg[r0, #0x7c]
  00220:    and        r5, r6, #0xf800ffff
  00224:    cbnz       r5, _PKT_0xe9be_60
  00228:    ldd        r4, reg[r0, #0x5ac0]
  0022c:    cbz        r4, _NOP_1
  00230:    ldd        r4, reg[r0, #0x5b40]
  00234:    and        r4, r4, #0xfffff001
  00238:    cbz        r4, _PKT_0xa0_3
  0023c:    nop
  00240:    b          _PKT_0xe9be_25  
_NOP_1:
  00244:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  00248:    ldd        r14, reg[r0, #0x6c]
  0024c:    and        r14, r14, #0xffd30fff
  00250:    cbnz       r14, _PKT_0x6ac7_2
  00254:    ldd        r10, reg[r0, #0x4af0]
  00258:    cbz        r10, _PKT_0xf0_9
  0025c:    ldd        r6, reg[r0, #0x4a14]
  00260:    lsr        r3, r6, #12
  00264:    and        r10, r3, #0xfffff201
  00268:    and        r3, r10, #0x2001
  0026c:    cbz        r3, _NOP_2
  00270:    b          _PKT_0xf0_2  
  00274:    nop
  00278:    nop
  0027c:    nop
_NOP_2:
  00280:    hwop       r2, r1, #0x0
  00284:    b.28       PKT_0x0   ; r0, r0

INDIRECT_BUFFER_END:
  00288:    stw        r0, [r0, #0x62]
  0028c:    lsr        r3, r2, #16
  00290:    stw        r3, reg[r0, #0x5ac0]
  00294:    std        r1, [r0, #0x81]
  00298:    stw        r3, [r0, #0x81]
  0029c:    stw        r0, [r0, #0x7e]
  002a0:    cbz        r2, _NOP_1
_INDIRECT_BUFFER_END_0:
  002a4:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  002a8:    ldd        r3, reg[r0, #0x6c]
  002ac:    and        r3, r3, #0xffd30fff
  002b0:    cbnz       r3, _PKT_0x6ac7_2
  002b4:    ldd        r4, reg[r0, #0x5ac0]
  002b8:    cbnz       r4, _INDIRECT_BUFFER_END_0
  002bc:    b          _PKT_0xf0_2  
  002c0:    lsr        r4, r2, #31
  002c4:    cbz        r4, _INDIRECT_BUFFER_END_1
  002c8:    b          _PKT_0x0_2  
  002cc:    lsr        r4, r2, #30
  002d0:    and        r4, r4, #0xfffff001
  002d4:    cbz        r4, _INDIRECT_BUFFER_END_1
  002d8:    ldd        r3, reg[r0, #0x4bcc]
  002dc:    lsr        r4, r3, #24
  002e0:    orr        r3, r4, #0x2
  002e4:    lsr        r4, r2, #16
  002e8:    and        r4, r4, #0xfffff001
  002ec:    eor        r5, r4, r0
  002f0:    hwop       r3, r5, #0x6
  002f4:    cbz        r3, _INDIRECT_BUFFER_END_1
  002f8:    nop
  002fc:    std        r3, [r0, #0xee]
  00300:    btab

_INDIRECT_BUFFER_END_1:
  00304:    std        r0, [r0, #0xee]
  00308:    btab

  0030c:    dw         0x84000073  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x73
  00310:    stw        r2, [r0, #0x0]
  00314:    stw        r1, [r0, #0x1]
  00318:    stw        r1, [r0, #0xb]
  0031c:    stw        r1, [r0, #0x2]
  00320:    stw        r1, [r0, #0x3]
  00324:    stw        r1, [r0, #0x4]
  00328:    stw        r1, [r0, #0x5]
  0032c:    mov        r14, #0x7
  00330:    lsr        r4, r2, #27
  00334:    and        r4, r4, #0xfffff001
  00338:    cbnz       r4, _INDIRECT_BUFFER_END_3
  0033c:    and        r5, r4, #0xfff800ff
  00340:    cbnz       r5, _INDIRECT_BUFFER_END_4
  00344:    ldd        r6, reg[r0, #0x49f4]
  00348:    lsr        r6, r6, #16
  0034c:    and        r7, r6, #0xfffff001
  00350:    cbz        r7, _INDIRECT_BUFFER_END_4
  00354:    and        r8, r6, #0xffffe003
_INDIRECT_BUFFER_END_2:
  00358:    cbz        r8, _INDIRECT_BUFFER_END_4
  0035c:    stw        r0, [r0, #0xc0]
  00360:    ldd        r6, [r0, #0xc9]
  00364:    cbz        r6, _INDIRECT_BUFFER_END_4
  00368:    std        r1, [r0, #0xc1]
  0036c:    b          _PKT_0xf0_0  
_INDIRECT_BUFFER_END_3:
  00370:    stw        r1, [r0, #0x15]
  00374:    stw        r1, [r0, #0x16]
  00378:    add        r14, r14, #0x2
_INDIRECT_BUFFER_END_4:
  0037c:    stw        r0, [r0, #0xff]
  00380:    stw        r14, [r0, #0x81]
  00384:    b          _PKT_0xf0_0  
  00388:    ldd        r14, reg[r0, #0x5a80]
  0038c:    lsr        r12, r14, #23
  00390:    and        r12, r12, #0xfffff001
  00394:    cbz        r12, _PKT_0x18_5
  00398:    ldd        r13, reg[r0, #0x4a14]
  0039c:    and        r14, r13, #0xfffff810
  003a0:    lsr        r13, r14, #9
  003a4:    eor        r6, r13, r0
  003a8:    ldd        r13, reg[r0, #0x5aa8]
  003ac:    lsr        r14, r13, #31
  003b0:    hwop       r6, r6, #0x7
  003b4:    lsl        r13, r6, #31
  003b8:    lsr        r6, r13, #31
  003bc:    cbz        r6, _PKT_0x18_5
  003c0:    stw        r2, [r0, #0x0]
  003c4:    stw        r2, [r0, #0xef]
  003c8:    hwop       r8, r1, #0x0
  003cc:    stw        r8, [r0, #0x1]
  003d0:    hwop       r3, r1, #0x0
  003d4:    stw        r3, [r0, #0xb]
  003d8:    lsr        r4, r3, #23
  003dc:    and        r4, r4, #0xfffff001
  003e0:    hwop       r5, r6, #0x6
  003e4:    cbz        r5, _INDIRECT_BUFFER_END_5
  003e8:    nop
_INDIRECT_BUFFER_END_5:
  003ec:    lsr        r4, r3, #31
  003f0:    and        r4, r4, #0xfffff001
  003f4:    hwop       r5, r6, #0x6
  003f8:    cbz        r5, _INDIRECT_BUFFER_END_6
  003fc:    nop
_INDIRECT_BUFFER_END_6:
  00400:    hwop       r3, r1, #0x0
  00404:    hwop       r4, r1, #0x0
  00408:    stw        r3, [r0, #0x2]
  0040c:    stw        r4, [r0, #0x3]
  00410:    stw        r1, [r0, #0x4]
  00414:    stw        r1, [r0, #0x5]
  00418:    and        r5, r3, #0xffffffff
  0041c:    hwop       r5, r8, #0x0
  00420:    ldd        r6, reg[r0, #0x4a20]
  00424:    and        r7, r6, #0xffffc007
  00428:    add        r7, r7, #0x10
  0042c:    lsl        r8, r5, r7
  00430:    sub        r9, r7, #0xc
  00434:    mov        r10, #0x1
  00438:    hwop       r7, r10, #0x3
  0043c:    lsld       r6, r4, #32
  00440:    hwop       r5, r6, #0x20
  00444:    lsrd       r6, r5, #12
  00448:    lsr        r5, r6, #4
  0044c:    lsl        r6, r5, #4
  00450:    stw        r0, [r0, #0xff]
  00454:    stw        r0, [r0, #0xd5]
  00458:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
_INDIRECT_BUFFER_END_7:
  0045c:    std        r3, [r0, #0xd3]
  00460:    ldd        r9, reg[r0, #0x14c]
  00464:    lsld       r10, r9, #2
  00468:    ldd        r13, unk[r10, #0x0]
  0046c:    nop
  00470:    and        r10, r13, #0xfffff001
  00474:    cbz        r10, _INDIRECT_BUFFER_END_7
_INDIRECT_BUFFER_END_8:
  00478:    ldd        r9, reg[r0, #0x144]
  0047c:    lsld       r10, r9, #2
  00480:    ldd        r12, unk[r10, #0x0]
  00484:    nop
  00488:    and        r11, r12, #0xfffff001
  0048c:    cbz        r11, _INDIRECT_BUFFER_END_8
_INDIRECT_BUFFER_END_9:
  00490:    dw         0x84000125  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x125
  00494:    ldd        r9, reg[r0, #0x148]
  00498:    stw        r9, [r0, #0x5b]
  0049c:    ldd        r10, reg[r0, #0x4a80]
  004a0:    and        r10, r10, #0xfffc007f
  004a4:    cbnz       r10, _INDIRECT_BUFFER_END_9
  004a8:    stw        r3, [r0, #0x5c]
  004ac:    dw         0x84000112  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112
_INDIRECT_BUFFER_END_10:
  004b0:    dw         0x84000125  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x125
  004b4:    ldd        r9, reg[r0, #0x140]
  004b8:    stw        r9, [r0, #0x5b]
  004bc:    ldd        r10, reg[r0, #0x4a80]
  004c0:    and        r10, r10, #0xfffc007f
  004c4:    cbnz       r10, _INDIRECT_BUFFER_END_10
  004c8:    stw        r3, [r0, #0x5c]
  004cc:    dw         0x84000112  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112
_INDIRECT_BUFFER_END_11:
  004d0:    std        r3, [r0, #0xd3]

PKT_0x18:
  004d4:    ldd        r9, reg[r0, #0x14c]
  004d8:    lsld       r10, r9, #2
  004dc:    ldd        r13, unk[r10, #0x0]
  004e0:    nop
  004e4:    and        r10, r13, #0xfffff001
  004e8:    cbz        r10, _INDIRECT_BUFFER_END_11
  004ec:    mov        r12, #0x0
_PKT_0x18_0:
  004f0:    ldd        r9, reg[r0, #0x144]
  004f4:    lsl        r10, r9, #2
  004f8:    ldd        r11, unk[r10, #0x0]
  004fc:    nop
  00500:    and        r10, r11, #0xfffff001
  00504:    cbz        r10, _PKT_0x18_0
  00508:    std        r1, [r0, #0xf3]
  0050c:    std        r0, [r0, #0xf3]
  00510:    hwop       r12, r13, #0x7
_PKT_0x18_1:
  00514:    hwop       r11, r12, #0x7
  00518:    stw        r11, [r0, #0xe2]
  0051c:    cbz        r8, _PKT_0x18_3
  00520:    hwop       r6, r6, #0x20
_PKT_0x18_2:
  00524:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  00528:    ldd        r13, [r0, #0xe3]
  0052c:    nop
  00530:    cbnz       r13, _PKT_0x18_2
  00534:    nop
  00538:    sub        r8, r8, #0x1
  0053c:    b          _INDIRECT_BUFFER_END_2  
_PKT_0x18_3:
  00540:    std        r7, [r0, #0x81]
  00544:    b          _PKT_0xf0_0  
  00548:    nop
  0054c:    nop
  00550:    nop
_PKT_0x18_4:
  00554:    ldd        r9, reg[r0, #0x4a14]
  00558:    lsr        r10, r9, #14
  0055c:    and        r9, r10, #0xfffff001
  00560:    cbz        r9, _PKT_0x18_4
  00564:    btab

_PKT_0x18_5:
  00568:    hwop       r2, r1, #0x0
  0056c:    hwop       r2, r1, #0x0
  00570:    hwop       r2, r1, #0x0
  00574:    hwop       r2, r1, #0x0
  00578:    hwop       r2, r1, #0x0
  0057c:    hwop       r2, r1, #0x0
  00580:    std        r7, [r0, #0x81]
  00584:    mov        r9, #0x7
  00588:    lsl        r9, r9, #2
  0058c:    dw         0x8400018c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x18c
_PKT_0x18_6:
  00590:    b          _PKT_0xf0_0  
  00594:    lsr        r10, r6, #4
  00598:    lsl        r14, r10, #4
  0059c:    lsld       r9, r14, #12
  005a0:    add        r10, r9, #0x0
  005a4:    lsrd       r14, r9, #32
  005a8:    std        r1, [r0, #0xbe]
  005ac:    stw        r10, [r0, #0xb9]
  005b0:    stw        r14, [r0, #0xba]
  005b4:    ldd        r10, [r0, #0xbb]
  005b8:    ldd        r14, [r0, #0xbf]
  005bc:    lsld       r9, r14, #32
  005c0:    hwop       r9, r9, #0x20
  005c4:    lsrd       r10, r9, #16
  005c8:    lsld       r14, r10, #4
  005cc:    add        r3, r14, #0x1
  005d0:    btab

  005d4:    ldd        r13, reg[r0, #0x4a14]
  005d8:    and        r14, r13, #0xfffff810
  005dc:    lsr        r13, r14, #9
  005e0:    cbz        r13, _PKT_0x18_8
  005e4:    ldd        r10, reg[r0, #0x5ab0]
  005e8:    nop
  005ec:    stw        r10, reg[r0, #0x5ba8]
_PKT_0x18_7:
  005f0:    b          _PKT_0x18_1  
_PKT_0x18_8:
  005f4:    ldd        r10, reg[r0, #0x5a8c]
  005f8:    nop
  005fc:    stw        r10, reg[r0, #0x5ba8]
  00600:    nop
  00604:    ldd        r10, reg[r0, #0x5a90]
  00608:    nop
  0060c:    stw        r10, reg[r0, #0x5bac]
  00610:    nop
  00614:    eor        r6, r13, r0
  00618:    ldd        r13, reg[r0, #0x5aa8]
  0061c:    lsr        r14, r13, #31
  00620:    hwop       r6, r6, #0x7
  00624:    lsl        r13, r6, #31
  00628:    lsr        r6, r13, #31
  0062c:    stw        r2, [r0, #0x0]
  00630:    hwop       r3, r1, #0x0
  00634:    lsr        r13, r3, #24
  00638:    lsl        r14, r3, #8
  0063c:    lsr        r3, r14, #8
  00640:    stw        r3, [r0, #0x1]
  00644:    hwop       r3, r1, #0x0
  00648:    cbz        r6, _PKT_0x18_12
  0064c:    ldd        r14, reg[r0, #0x5a80]
  00650:    lsr        r12, r14, #23
  00654:    and        r12, r12, #0xfffff001
  00658:    cbz        r12, _PKT_0x18_12
  0065c:    stw        r3, [r0, #0xb]
  00660:    mov        r14, #0x7
  00664:    stw        r14, [r0, #0x81]
  00668:    lsr        r4, r3, #23
  0066c:    and        r4, r4, #0xfffff001
  00670:    hwop       r5, r6, #0x6
  00674:    cbz        r5, _PKT_0x18_9
  00678:    nop
_PKT_0x18_9:
  0067c:    lsr        r4, r3, #31
  00680:    and        r4, r4, #0xfffff001
  00684:    hwop       r5, r6, #0x6
  00688:    cbz        r5, _PKT_0x18_10
  0068c:    nop
_PKT_0x18_10:
  00690:    stw        r1, [r0, #0x2]
  00694:    stw        r1, [r0, #0x3]
  00698:    stw        r1, [r0, #0x4]
  0069c:    stw        r1, [r0, #0x5]
  006a0:    stw        r0, [r0, #0xff]
  006a4:    nop
  006a8:    sub        r13, r13, #0x1
_PKT_0x18_11:
  006ac:    dw         0x8400019f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x19f
  006b0:    ldd        r6, reg[r0, #0x4a14]
  006b4:    nop
  006b8:    lsr        r3, r6, #25
  006bc:    and        r4, r3, #0xfffff001
  006c0:    cbz        r4, _PKT_0x18_11
  006c4:    nop
  006c8:    std        r4, [r0, #0x81]
  006cc:    add        r13, r13, #0x1
  006d0:    cbz        r13, _PKT_0xf0_9
  006d4:    sub        r13, r13, #0x1
  006d8:    b          _PKT_0x18_6  
  006dc:    nop
  006e0:    hwop       r2, r1, #0x0
  006e4:    hwop       r2, r1, #0x0
_PKT_0x18_12:
  006e8:    add        r14, r13, #0x0
  006ec:    lsl        r14, r14, #4
  006f0:    hwop       r2, r1, #0x0
  006f4:    hwop       r2, r1, #0x0
  006f8:    hwop       r2, r1, #0x0
  006fc:    hwop       r2, r1, #0x0
  00700:    cbz        r13, _PKT_0x18_13
  00704:    nop
  00708:    sub        r13, r13, #0x1
  0070c:    std        r4, [r0, #0x81]
  00710:    b          _PKT_0x18_7  
  00714:    nop
_PKT_0x18_13:
  00718:    std        r7, [r0, #0x81]
  0071c:    mov        r9, #0x7
  00720:    lsl        r9, r9, #2
  00724:    hwop       r9, r14, #0x0
  00728:    dw         0x8400018c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x18c
  0072c:    b          _PKT_0xf0_0  
  00730:    std        r1, [r0, #0xf1]
  00734:    ldd        r6, reg[r0, #0x4a14]
  00738:    and        r10, r6, #0xfffff810
  0073c:    cbnz       r10, _PKT_0x18_14
  00740:    ldd        r6, reg[r0, #0x5a8c]
  00744:    nop
  00748:    ldd        r7, reg[r0, #0x5a90]
  0074c:    nop
  00750:    lsld       r5, r7, #32
  00754:    hwop       r7, r5, #0x20
  00758:    hwop       r5, r7, #0x20
  0075c:    stw        r5, reg[r0, #0x5a8c]
  00760:    lsrd       r7, r5, #32
  00764:    stw        r7, reg[r0, #0x5a90]
  00768:    btab

_PKT_0x18_14:
  0076c:    ldd        r6, reg[r0, #0x5ab0]
  00770:    hwop       r7, r6, #0x0
_PKT_0x18_15:
  00774:    stw        r7, reg[r0, #0x5ab0]
  00778:    btab

  0077c:    ldd        r15, reg[r0, #0x6c]
  00780:    and        r15, r15, #0xffd30fff
  00784:    cbnz       r15, SET_BASE
  00788:    btab


SET_BASE:
  0078c:    ldd        r13, reg[r0, #0x4a14]
  00790:    and        r14, r13, #0xfffff810
  00794:    lsr        r13, r14, #9
  00798:    cbz        r13, _SET_BASE_0
  0079c:    ldd        r10, reg[r0, #0x5ba8]
  007a0:    nop
  007a4:    stw        r10, reg[r0, #0x5ab0]
  007a8:    std        r0, reg[r0, #0x5ba8]
  007ac:    b          _PKT_0x655a_11  
_SET_BASE_0:
  007b0:    ldd        r10, reg[r0, #0x5ba8]
  007b4:    nop
  007b8:    stw        r10, reg[r0, #0x5a8c]
  007bc:    nop
  007c0:    ldd        r10, reg[r0, #0x5bac]
  007c4:    nop
  007c8:    stw        r10, reg[r0, #0x5a90]
  007cc:    std        r0, reg[r0, #0x5ba8]
  007d0:    std        r0, reg[r0, #0x5bac]
  007d4:    b          _PKT_0x655a_11  
  007d8:    lsr        r13, r3, #3
  007dc:    and        r13, r13, #0x7fffffff
  007e0:    setne      r15, r13, #0x3
  007e4:    cbz        r15, _SET_BASE_1
  007e8:    mov        r13, #0x100
  007ec:    lsl        r13, r13, r12
  007f0:    b          _PKT_0x18_15  
_SET_BASE_1:
  007f4:    setne      r15, r13, #0x7
  007f8:    cbz        r15, _SET_BASE_2
  007fc:    mov        r13, #0x1000
  00800:    lsl        r13, r13, r12
  00804:    b          _PKT_0x18_15  
_SET_BASE_2:
  00808:    setne      r15, r13, #0xb
  0080c:    cbz        r15, _SET_BASE_3
  00810:    mov        r13, #0x1
  00814:    lsl        r13, r13, #16
  00818:    lsl        r13, r13, r12
  0081c:    b          _PKT_0x18_15  
_SET_BASE_3:
  00820:    setne      r15, r13, #0xf
  00824:    cbz        r15, _SET_BASE_4
  00828:    btab

_SET_BASE_4:
  0082c:    setne      r15, r13, #0x13
  00830:    cbz        r15, _SET_BASE_5
  00834:    mov        r13, #0x1
  00838:    lsl        r13, r13, #16
  0083c:    lsl        r13, r13, r12
  00840:    b          _PKT_0x18_15  
_SET_BASE_5:
  00844:    setne      r15, r13, #0x17
  00848:    cbz        r15, _SET_BASE_6
  0084c:    mov        r13, #0x1000
  00850:    lsl        r13, r13, r12
  00854:    b          _PKT_0x18_15  
_SET_BASE_6:
  00858:    setne      r15, r13, #0x1b
  0085c:    cbz        r15, _SET_BASE_7
  00860:    mov        r13, #0x1
  00864:    lsl        r13, r13, #16
  00868:    lsl        r13, r13, r12
  0086c:    b          _PKT_0x18_15  
_SET_BASE_7:
  00870:    btab

  00874:    lsr        r13, r13, #1
  00878:    setgt      r15, r11, r13
  0087c:    cbz        r15, _SET_BASE_8
  00880:    nop
  00884:    std        r1, reg[r0, #0x5ba8]
_SET_BASE_8:
  00888:    btab

  0088c:    dw         0x84000073  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x73
  00890:    stw        r2, [r0, #0x0]
  00894:    stw        r1, [r0, #0x4]
  00898:    stw        r1, [r0, #0x5]
  0089c:    mov        r14, #0xd
  008a0:    lsr        r4, r2, #26
  008a4:    and        r4, r4, #0xffffc007
  008a8:    cbz        r4, _SET_BASE_9
  008ac:    stw        r1, [r0, #0x15]
  008b0:    stw        r1, [r0, #0x16]
  008b4:    add        r14, r14, #0x3
_SET_BASE_9:
  008b8:    hwop       r13, r1, #0x0
  008bc:    stw        r13, [r0, #0x6]
  008c0:    add        r13, r13, #0x1
  008c4:    hwop       r12, r1, #0x0
  008c8:    stw        r12, [r0, #0x7]
  008cc:    and        r12, r12, #0xffffffff
  008d0:    add        r12, r12, #0x1
  008d4:    subd       r11, r12, r13
  008d8:    hwop       r3, r1, #0x0
  008dc:    stw        r3, [r0, #0x8]
  008e0:    and        r12, r3, #0xfffc007f
  008e4:    dw         0x840001b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1b6
  008e8:    stw        r11, [r0, #0x18]
  008ec:    hwop       r3, r1, #0x0
  008f0:    stw        r3, [r0, #0x9]
  008f4:    and        r7, r3, #0xffffffff
  008f8:    lsr        r6, r3, #16
  008fc:    hwop       r13, r7, #0x23
  00900:    hwop       r3, r1, #0x0
  00904:    and        r12, r3, #0xffffffff
  00908:    stw        r3, [r0, #0xa]
  0090c:    cbz        r4, _SET_BASE_10
  00910:    hwop       r3, r1, #0x0
_SET_BASE_10:
  00914:    stw        r3, [r0, #0xb]
  00918:    hwop       r3, r1, #0x0
  0091c:    lsld       r5, r1, #32
  00920:    hwop       r3, r5, #0x20
  00924:    hwop       r5, r1, #0x0
  00928:    stw        r5, [r0, #0x10]
  0092c:    addd       r11, r5, #0x1
  00930:    subd       r8, r11, r6
  00934:    hwop       r9, r8, #0x20
  00938:    hwop       r7, r1, #0x0
  0093c:    stw        r7, [r0, #0xd]
  00940:    addd       r6, r7, #0x1
  00944:    subd       r7, r12, r6
  00948:    hwop       r8, r7, #0x20
  0094c:    hwop       r10, r8, #0x20
  00950:    stw        r10, [r0, #0x2]
  00954:    lsrd       r10, r10, #32
  00958:    stw        r10, [r0, #0x3]
  0095c:    stw        r1, [r0, #0x1]
  00960:    cbnz       r4, _SET_BASE_11
  00964:    and        r5, r4, #0xf800ffff
  00968:    cbnz       r5, _SET_BASE_11
  0096c:    ldd        r6, reg[r0, #0x49f4]
  00970:    lsr        r6, r6, #16
  00974:    and        r7, r6, #0xfffff001
  00978:    cbz        r7, _SET_BASE_11
  0097c:    and        r8, r6, #0xffffe003
  00980:    cbz        r8, _SET_BASE_11
  00984:    stw        r0, [r0, #0xc0]
  00988:    ldd        r6, [r0, #0xc9]
  0098c:    cbz        r6, _SET_BASE_11
  00990:    std        r4, [r0, #0xc1]
  00994:    b          _PKT_0xf0_0  
_SET_BASE_11:
  00998:    stw        r0, [r0, #0xff]
  0099c:    stw        r14, [r0, #0x81]
  009a0:    b          _PKT_0xf0_0  
  009a4:    stw        r2, [r0, #0x0]
  009a8:    stw        r1, [r0, #0x4]
  009ac:    stw        r1, [r0, #0x5]
  009b0:    mov        r14, #0xd
  009b4:    lsr        r4, r2, #26

INDEX_BUFFER_SIZE:
  009b8:    and        r4, r4, #0xffffc007
  009bc:    cbz        r4, _INDEX_BUFFER_SIZE_0
  009c0:    stw        r1, [r0, #0x15]
  009c4:    stw        r1, [r0, #0x16]
  009c8:    add        r14, r14, #0x3
_INDEX_BUFFER_SIZE_0:
  009cc:    hwop       r13, r1, #0x0
  009d0:    stw        r13, [r0, #0x6]
  009d4:    add        r13, r13, #0x1
  009d8:    hwop       r12, r1, #0x0
  009dc:    stw        r12, [r0, #0x7]
  009e0:    and        r12, r12, #0xffffffff
  009e4:    add        r12, r12, #0x1
  009e8:    subd       r11, r12, r13
  009ec:    hwop       r3, r1, #0x0
  009f0:    stw        r3, [r0, #0x8]
  009f4:    and        r12, r3, #0xfffc007f
  009f8:    dw         0x840001b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1b6
  009fc:    stw        r11, [r0, #0x18]
  00a00:    hwop       r3, r1, #0x0
  00a04:    stw        r3, [r0, #0x9]
  00a08:    and        r7, r3, #0xffffffff
  00a0c:    lsr        r6, r3, #16
  00a10:    hwop       r13, r7, #0x23
  00a14:    hwop       r3, r1, #0x0
  00a18:    and        r12, r3, #0xffffffff
  00a1c:    stw        r3, [r0, #0xa]
  00a20:    cbz        r4, _INDEX_BUFFER_SIZE_1
  00a24:    hwop       r3, r1, #0x0
_INDEX_BUFFER_SIZE_1:
  00a28:    stw        r3, [r0, #0xb]
  00a2c:    hwop       r3, r1, #0x0
  00a30:    lsld       r5, r1, #32
  00a34:    hwop       r3, r5, #0x20
  00a38:    hwop       r5, r1, #0x0
  00a3c:    stw        r5, [r0, #0x10]
  00a40:    addd       r11, r5, #0x1
  00a44:    subd       r8, r11, r6
  00a48:    hwop       r9, r8, #0x20

PKT_0x14:
  00a4c:    hwop       r7, r1, #0x0
  00a50:    stw        r7, [r0, #0xd]
  00a54:    addd       r6, r7, #0x1
  00a58:    subd       r7, r12, r6
  00a5c:    hwop       r8, r7, #0x20
  00a60:    hwop       r10, r8, #0x20
  00a64:    stw        r10, [r0, #0x2]
  00a68:    lsrd       r10, r10, #32
  00a6c:    stw        r10, [r0, #0x3]
  00a70:    stw        r1, [r0, #0x1]
  00a74:    cbnz       r4, _SET_BASE_11
  00a78:    and        r5, r4, #0xf800ffff
  00a7c:    cbnz       r5, _SET_BASE_11
  00a80:    ldd        r6, reg[r0, #0x49f4]
  00a84:    lsr        r6, r6, #16
  00a88:    and        r7, r6, #0xfffff001
  00a8c:    cbz        r7, _SET_BASE_11
  00a90:    and        r8, r6, #0xffffe003
  00a94:    cbz        r8, _SET_BASE_11
  00a98:    stw        r0, [r0, #0xc0]
  00a9c:    ldd        r6, [r0, #0xc9]
  00aa0:    cbz        r6, _PKT_0x14_0
  00aa4:    std        r4, [r0, #0xc1]
  00aa8:    b          _PKT_0xf0_0  
_PKT_0x14_0:
  00aac:    stw        r0, [r0, #0xff]
  00ab0:    stw        r14, [r0, #0x81]
  00ab4:    b          _PKT_0xf0_0  
  00ab8:    stw        r2, [r0, #0x0]
  00abc:    hwop       r3, r1, #0x0
  00ac0:    and        r7, r3, #0xfffffff
  00ac4:    cbz        r7, _PKT_0x14_1
  00ac8:    stw        r0, [r0, #0x66]
_PKT_0x14_1:
  00acc:    lsld       r4, r1, #32
  00ad0:    hwop       r5, r4, #0x20
  00ad4:    hwop       r3, r1, #0x0
  00ad8:    stw        r3, [r0, #0x13]
  00adc:    lsr        r6, r3, #4
  00ae0:    lsl        r6, r6, #4
  00ae4:    and        r7, r3, #0xfc007fff
  00ae8:    stw        r1, [r0, #0x1]
  00aec:    hwop       r4, r1, #0x0
  00af0:    add        r4, r4, #0x1
  00af4:    stw        r4, [r0, #0xa]
  00af8:    stw        r4, [r0, #0xb]
  00afc:    and        r4, r4, #0xffffffff
  00b00:    hwop       r8, r1, #0x0
  00b04:    lsld       r9, r1, #32
  00b08:    hwop       r10, r9, #0x20
  00b0c:    subd       r11, r4, r6
  00b10:    hwop       r12, r11, #0x20
  00b14:    lsl        r12, r12, #2
  00b18:    hwop       r13, r12, #0x20
  00b1c:    stw        r13, [r0, #0x4]
  00b20:    lsrd       r13, r13, #32
  00b24:    stw        r13, [r0, #0x5]
  00b28:    subd       r11, r4, r3
  00b2c:    lsl        r14, r11, #2
  00b30:    hwop       r12, r14, #0x20
  00b34:    stw        r12, [r0, #0x2]
  00b38:    lsrd       r12, r12, #32
  00b3c:    stw        r12, [r0, #0x3]
  00b40:    stw        r0, [r0, #0xff]
  00b44:    std        r8, [r0, #0x81]
  00b48:    b          _PKT_0xf0_0  
  00b4c:    stw        r2, [r0, #0x0]
  00b50:    lsr        r9, r2, #29
  00b54:    hwop       r3, r1, #0x0
  00b58:    lsld       r4, r1, #32
  00b5c:    hwop       r13, r4, #0x20
  00b60:    hwop       r3, r1, #0x0
  00b64:    stw        r3, [r0, #0x9]

DISPATCH_DIRECT:
  00b68:    and        r7, r3, #0xffffffff
  00b6c:    lsr        r6, r3, #16
  00b70:    hwop       r3, r1, #0x0
  00b74:    stw        r3, [r0, #0xa]
  00b78:    and        r5, r3, #0xffffffff
  00b7c:    lsr        r4, r3, #13
  00b80:    add        r10, r4, #0x1
  00b84:    subd       r8, r6, r10
  00b88:    hwop       r11, r1, #0x0
  00b8c:    stw        r11, [r0, #0x7]
  00b90:    stw        r11, [r0, #0x18]
  00b94:    addd       r14, r11, #0x1
  00b98:    subd       r12, r5, r14
  00b9c:    hwop       r4, r8, #0x20
  00ba0:    hwop       r5, r7, #0x20
  00ba4:    hwop       r6, r5, #0x23
  00ba8:    hwop       r13, r6, #0x20
  00bac:    stw        r13, [r0, #0x2]
  00bb0:    lsrd       r13, r13, #32
  00bb4:    stw        r13, [r0, #0x3]
  00bb8:    hwop       r3, r1, #0x0
  00bbc:    lsld       r4, r1, #32
  00bc0:    hwop       r13, r4, #0x20
  00bc4:    hwop       r3, r1, #0x0
  00bc8:    stw        r3, [r0, #0xf]
  00bcc:    and        r7, r3, #0xffffffff
  00bd0:    lsr        r6, r3, #16
  00bd4:    hwop       r3, r1, #0x0
  00bd8:    stw        r3, [r0, #0x10]
  00bdc:    and        r5, r3, #0xffffffff
  00be0:    lsr        r4, r3, #13
  00be4:    add        r4, r4, #0x1
  00be8:    subd       r8, r6, r4
  00bec:    hwop       r11, r1, #0x0
  00bf0:    stw        r11, [r0, #0xd]
  00bf4:    stw        r11, [r0, #0x19]
  00bf8:    addd       r11, r11, #0x1
  00bfc:    subd       r12, r5, r11
  00c00:    hwop       r6, r8, #0x20
  00c04:    hwop       r5, r7, #0x20
  00c08:    hwop       r8, r5, #0x23
  00c0c:    hwop       r13, r8, #0x20
  00c10:    stw        r13, [r0, #0x4]
  00c14:    lsrd       r13, r13, #32
  00c18:    stw        r13, [r0, #0x5]
  00c1c:    hwop       r3, r1, #0x0
  00c20:    stw        r3, [r0, #0x11]
  00c24:    hwop       r5, r1, #0x0
  00c28:    stw        r5, [r0, #0x12]
  00c2c:    stw        r5, [r0, #0xb]
  00c30:    ldd        r6, reg[r0, #0x49f4]
  00c34:    lsr        r6, r6, #16
  00c38:    and        r7, r6, #0xfffff001
  00c3c:    cbz        r7, _DISPATCH_DIRECT_0
  00c40:    and        r8, r6, #0xffffe003
  00c44:    cbz        r8, _DISPATCH_DIRECT_0
  00c48:    stw        r0, [r0, #0xc0]
  00c4c:    ldd        r6, [r0, #0xc9]
  00c50:    cbz        r6, _DISPATCH_DIRECT_0
  00c54:    std        r2, [r0, #0xc1]
  00c58:    b          _PKT_0xf0_0  
_DISPATCH_DIRECT_0:
  00c5c:    stw        r0, [r0, #0xff]
  00c60:    std        r13, [r0, #0x81]
  00c64:    b          _PKT_0xf0_0  
  00c68:    stw        r2, [r0, #0x0]
  00c6c:    stw        r1, [r0, #0x4]
  00c70:    stw        r1, [r0, #0x5]
  00c74:    hwop       r3, r1, #0x0
  00c78:    stw        r3, [r0, #0x9]
  00c7c:    and        r7, r3, #0xffffffff
  00c80:    lsr        r6, r3, #16
  00c84:    hwop       r3, r1, #0x0
  00c88:    and        r8, r3, #0xffffffff
  00c8c:    stw        r8, [r0, #0xa]
  00c90:    lsr        r3, r3, #16
  00c94:    and        r4, r3, #0xffffffff
  00c98:    stw        r4, [r0, #0x6]
  00c9c:    add        r13, r4, #0x1
_DISPATCH_DIRECT_1:
  00ca0:    hwop       r12, r1, #0x0
  00ca4:    stw        r12, [r0, #0x7]
  00ca8:    and        r12, r12, #0xffffffff
  00cac:    add        r12, r12, #0x1
  00cb0:    subd       r11, r12, r13
  00cb4:    hwop       r3, r1, #0x0
  00cb8:    stw        r3, [r0, #0x8]
  00cbc:    and        r9, r3, #0xfffc007f
  00cc0:    hwop       r12, r9, #0x0
  00cc4:    dw         0x840001b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1b6
  00cc8:    stw        r11, [r0, #0x18]
  00ccc:    lsr        r14, r2, #31
  00cd0:    cbz        r14, _DISPATCH_DIRECT_7
  00cd4:    lsr        r14, r2, #12
  00cd8:    and        r14, r14, #0xfffff001
  00cdc:    cbnz       r14, _DISPATCH_DIRECT_7
  00ce0:    ldd        r14, reg[r0, #0x49f4]
  00ce4:    lsr        r14, r14, #18
  00ce8:    and        r14, r14, #0xfffff001
  00cec:    lsr        r11, r2, #19
  00cf0:    and        r11, r11, #0xfffff001
  00cf4:    hwop       r14, r14, #0x7
  00cf8:    cbz        r14, _DISPATCH_DIRECT_7
  00cfc:    lsr        r5, r3, #3
  00d00:    and        r11, r5, #0xffffc007
  00d04:    lsr        r5, r5, #7
  00d08:    and        r12, r5, #0xfffff001
  00d0c:    cbz        r12, _DISPATCH_DIRECT_6
  00d10:    and        r14, r11, #0x2
  00d14:    hwop       r11, r0, #0x0
  00d18:    cbnz       r11, _DISPATCH_DIRECT_2
  00d1c:    mov        r14, #0x7
  00d20:    mov        r15, #0x3
  00d24:    mov        r12, #0x7
  00d28:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_2:
  00d2c:    sub        r11, r11, #0x1
  00d30:    cbnz       r11, _DISPATCH_DIRECT_3
  00d34:    mov        r14, #0x3
  00d38:    mov        r15, #0x3
  00d3c:    mov        r12, #0x7
  00d40:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_3:
  00d44:    sub        r11, r11, #0x1
  00d48:    cbnz       r11, _DISPATCH_DIRECT_4
  00d4c:    mov        r14, #0x3
  00d50:    mov        r15, #0x3
  00d54:    mov        r12, #0x3
  00d58:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_4:
  00d5c:    sub        r11, r11, #0x1
  00d60:    cbnz       r11, _DISPATCH_DIRECT_5
  00d64:    mov        r14, #0x3
  00d68:    mov        r15, #0x1
  00d6c:    mov        r12, #0x3
  00d70:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_5:
  00d74:    mov        r14, #0x1
  00d78:    mov        r15, #0x1
  00d7c:    mov        r12, #0x3
  00d80:    b          _DISPATCH_DIRECT_1  
_DISPATCH_DIRECT_6:
  00d84:    lsr        r3, r9, #1
  00d88:    and        r4, r9, #0xfffff001
  00d8c:    hwop       r4, r3, #0x0
  00d90:    mov        r5, #0xf
  00d94:    lsl        r14, r5, r3
  00d98:    lsl        r15, r5, r4
  00d9c:    mov        r12, #0x0
  00da0:    hwop       r14, r7, #0x6
  00da4:    hwop       r15, r6, #0x6
  00da8:    hwop       r12, r8, #0x6
_DISPATCH_DIRECT_7:
  00dac:    hwop       r3, r1, #0x0
  00db0:    lsld       r4, r1, #32
  00db4:    hwop       r13, r4, #0x20
  00db8:    hwop       r3, r1, #0x0
  00dbc:    stw        r3, [r0, #0xf]
  00dc0:    and        r7, r3, #0xffffffff
  00dc4:    lsr        r6, r3, #16
  00dc8:    hwop       r3, r1, #0x0
  00dcc:    stw        r3, [r0, #0x10]
  00dd0:    and        r8, r3, #0xffffffff
  00dd4:    lsr        r10, r3, #16
  00dd8:    add        r10, r10, #0x1
  00ddc:    hwop       r11, r1, #0x0
  00de0:    stw        r11, [r0, #0xd]
  00de4:    addd       r11, r11, #0x1
  00de8:    subd       r12, r12, r11
  00dec:    subd       r15, r15, r10
  00df0:    hwop       r12, r12, #0x20
  00df4:    hwop       r12, r12, #0x20
  00df8:    hwop       r15, r12, #0x23
  00dfc:    subd       r4, r8, r11
  00e00:    subd       r5, r6, r10
  00e04:    hwop       r12, r5, #0x20
  00e08:    hwop       r11, r7, #0x20
  00e0c:    hwop       r10, r11, #0x23
  00e10:    hwop       r13, r10, #0x20
  00e14:    stw        r13, [r0, #0x179]
  00e18:    lsrd       r4, r13, #32
  00e1c:    stw        r4, [r0, #0x17a]
  00e20:    lsr        r14, r2, #31
  00e24:    cbz        r14, _DISPATCH_DIRECT_8
  00e28:    lsr        r14, r2, #12
  00e2c:    and        r14, r14, #0xfffff001
  00e30:    cbnz       r14, _DISPATCH_DIRECT_8
  00e34:    ldd        r14, reg[r0, #0x49f4]
  00e38:    lsr        r14, r14, #18
  00e3c:    and        r14, r14, #0xfffff001
  00e40:    lsr        r11, r2, #19
  00e44:    and        r11, r11, #0xfffff001
  00e48:    hwop       r14, r14, #0x7
  00e4c:    cbz        r14, _DISPATCH_DIRECT_8
  00e50:    hwop       r13, r13, #0x21
_DISPATCH_DIRECT_8:
  00e54:    stw        r13, [r0, #0x2]
  00e58:    lsrd       r13, r13, #32
  00e5c:    stw        r13, [r0, #0x3]
  00e60:    stw        r1, [r0, #0x11]
  00e64:    hwop       r3, r1, #0x0
  00e68:    stw        r3, [r0, #0x12]
  00e6c:    stw        r3, [r0, #0xb]
  00e70:    lsr        r3, r2, #19
  00e74:    and        r3, r3, #0xfffff001
  00e78:    mov        r14, #0xe
  00e7c:    cbz        r3, _DISPATCH_INDIRECT_0
  00e80:    stw        r1, [r0, #0x15]
  00e84:    stw        r1, [r0, #0x16]

DISPATCH_INDIRECT:
  00e88:    stw        r1, [r0, #0x1c]
  00e8c:    add        r14, r14, #0x3
_DISPATCH_INDIRECT_0:
  00e90:    ldd        r6, reg[r0, #0x49f4]
  00e94:    lsr        r6, r6, #16
  00e98:    and        r7, r6, #0xfffff001
  00e9c:    cbz        r7, _DISPATCH_INDIRECT_1
  00ea0:    and        r8, r6, #0xffffe003
  00ea4:    cbz        r8, _DISPATCH_INDIRECT_1
  00ea8:    stw        r0, [r0, #0xc0]
  00eac:    ldd        r6, [r0, #0xc9]
  00eb0:    cbz        r6, _DISPATCH_INDIRECT_1
  00eb4:    std        r8, [r0, #0xc1]
  00eb8:    b          _PKT_0xf0_0  
_DISPATCH_INDIRECT_1:
  00ebc:    stw        r0, [r0, #0xff]
  00ec0:    stw        r14, [r0, #0x81]
  00ec4:    dw         0x84000373  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x373
  00ec8:    b          _PKT_0xf0_0  
  00ecc:    lsr        r10, r2, #19
  00ed0:    cbz        r10, _PKT_0xf0_6
_DISPATCH_INDIRECT_2:
  00ed4:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  00ed8:    ldd        r6, reg[r0, #0x4a14]
  00edc:    lsr        r6, r6, #25
  00ee0:    and        r10, r6, #0xfffff001
  00ee4:    cbz        r10, _DISPATCH_INDIRECT_2
  00ee8:    dw         0x84000383  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x383
  00eec:    ldd        r6, reg[r0, #0x4a14]
  00ef0:    and        r10, r6, #0xfffff810
  00ef4:    cbz        r10, _DISPATCH_INDIRECT_3
  00ef8:    ldd        r6, reg[r0, #0x5aa8]
  00efc:    and        r10, r6, #0xfffff808
  00f00:    cbnz       r10, _DISPATCH_INDIRECT_3
  00f04:    std        r0, [r0, #0xca]
_DISPATCH_INDIRECT_3:
  00f08:    btab

  00f0c:    stw        r0, [r0, #0x62]
  00f10:    nop
  00f14:    ldd        r6, reg[r0, #0x5ac4]
  00f18:    and        r10, r6, #0xfffff810
  00f1c:    cbnz       r10, _DISPATCH_INDIRECT_6
  00f20:    ldd        r6, reg[r0, #0x4a14]
  00f24:    and        r10, r6, #0xfffff810
  00f28:    cbnz       r10, _DISPATCH_INDIRECT_4
  00f2c:    and        r10, r6, #0xffff800f
  00f30:    cbnz       r10, _DISPATCH_INDIRECT_6
_DISPATCH_INDIRECT_4:
  00f34:    std        r1, [r0, #0x9b]
  00f38:    std        r1, [r0, #0x9a]
  00f3c:    mov        r12, #0x4a2c
  00f40:    stw        r12, [r0, #0x6b]
  00f44:    stw        r0, [r0, #0x64]
_DISPATCH_INDIRECT_5:
  00f48:    ldd        r6, reg[r12, #0x0]
  00f4c:    and        r3, r6, #0xfffff801
  00f50:    cbz        r3, _DISPATCH_INDIRECT_5
  00f54:    stw        r0, [r0, #0x30]
  00f58:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  00f5c:    stw        r0, [r0, #0x76]
  00f60:    stw        r0, [r0, #0x6b]
  00f64:    std        r1, [r0, #0x30]
  00f68:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  00f6c:    stw        r0, [r0, #0x85]
  00f70:    stw        r0, [r0, #0x9b]
  00f74:    std        r0, [r0, #0x9a]
  00f78:    ldd        r5, reg[r0, #0x5abc]
  00f7c:    cbz        r5, _DISPATCH_INDIRECT_6
  00f80:    stw        r0, [r0, #0x42]
_DISPATCH_INDIRECT_6:
  00f84:    btab

  00f88:    stw        r2, [r0, #0x0]
  00f8c:    stw        r1, [r0, #0x2]
  00f90:    stw        r1, [r0, #0x3]
  00f94:    stw        r1, [r0, #0x9]
  00f98:    hwop       r3, r1, #0x0
  00f9c:    and        r4, r3, #0xffffffff

SET_PREDICATION:
  00fa0:    stw        r4, [r0, #0xa]
  00fa4:    lsr        r3, r3, #16
  00fa8:    and        r4, r3, #0xffffffff
  00fac:    stw        r4, [r0, #0x6]
  00fb0:    add        r13, r4, #0x1
  00fb4:    hwop       r12, r1, #0x0
  00fb8:    stw        r12, [r0, #0x7]
  00fbc:    and        r12, r12, #0xffffffff
  00fc0:    add        r12, r12, #0x1
  00fc4:    subd       r11, r12, r13
  00fc8:    hwop       r3, r1, #0x0
  00fcc:    stw        r3, [r0, #0x8]
  00fd0:    and        r12, r3, #0xfffc007f
  00fd4:    dw         0x840001b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1b6
  00fd8:    stw        r11, [r0, #0x18]
  00fdc:    stw        r1, [r0, #0x4]
  00fe0:    stw        r1, [r0, #0x5]

REG_RMW:
  00fe4:    stw        r1, [r0, #0xf]
  00fe8:    hwop       r3, r1, #0x0
  00fec:    and        r4, r3, #0xffffffff
  00ff0:    stw        r4, [r0, #0x10]
  00ff4:    lsr        r3, r3, #16
  00ff8:    and        r4, r3, #0xffffffff
  00ffc:    stw        r4, [r0, #0xc]
  01000:    add        r13, r4, #0x1
  01004:    hwop       r12, r1, #0x0
  01008:    stw        r12, [r0, #0xd]
  0100c:    and        r12, r12, #0xffffffff
  01010:    add        r12, r12, #0x1
  01014:    subd       r11, r12, r13
  01018:    hwop       r3, r1, #0x0
  0101c:    stw        r3, [r0, #0xe]
  01020:    and        r12, r3, #0xfffc007f
  01024:    dw         0x840001b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1b6
  01028:    stw        r11, [r0, #0x19]
  0102c:    stw        r1, [r0, #0x11]
  01030:    hwop       r3, r1, #0x0
  01034:    stw        r3, [r0, #0x12]
  01038:    stw        r3, [r0, #0xb]
  0103c:    lsr        r3, r2, #19
  01040:    and        r3, r3, #0xfffff001
  01044:    mov        r14, #0xf
  01048:    cbz        r3, _REG_RMW_1
  0104c:    stw        r1, [r0, #0x15]
_REG_RMW_0:
  01050:    stw        r1, [r0, #0x16]
  01054:    stw        r1, [r0, #0x1c]
  01058:    add        r14, r14, #0x3
_REG_RMW_1:
  0105c:    ldd        r6, reg[r0, #0x49f4]
  01060:    lsr        r6, r6, #16
  01064:    and        r7, r6, #0xfffff001
  01068:    cbz        r7, _REG_RMW_2
  0106c:    and        r8, r6, #0xffffe003
  01070:    cbz        r8, _REG_RMW_2
  01074:    stw        r0, [r0, #0xc0]
  01078:    ldd        r6, [r0, #0xc9]
  0107c:    cbz        r6, _REG_RMW_2
  01080:    mov        r9, #0x1
  01084:    lsl        r9, r9, #4
  01088:    stw        r9, [r0, #0xc1]
  0108c:    b          _PKT_0xf0_0  
_REG_RMW_2:
  01090:    stw        r0, [r0, #0xff]
  01094:    stw        r14, [r0, #0x81]
  01098:    dw         0x84000373  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x373
  0109c:    b          _PKT_0xf0_0  
  010a0:    dw         0x84000070  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x70
  010a4:    stw        r2, [r0, #0x0]
  010a8:    mov        r13, #0x4
  010ac:    stw        r1, [r0, #0x4]
  010b0:    stw        r1, [r0, #0x5]
  010b4:    hwop       r3, r1, #0x0
  010b8:    lsl        r4, r3, #12
  010bc:    lsr        r5, r4, #12
  010c0:    hwop       r13, r13, #0x20
  010c4:    add        r13, r13, #0x1
  010c8:    stw        r13, [r0, #0x81]
  010cc:    lsr        r12, r3, #8
  010d0:    stw        r12, [r0, #0xb]
  010d4:    lsl        r11, r5, #2
  010d8:    stw        r11, [r0, #0x1]
  010dc:    mov        r7, #0x10
  010e0:    b          _REG_RMW_0  
  010e4:    dw         0x84000070  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x70
  010e8:    stw        r2, [r0, #0x0]
  010ec:    mov        r13, #0x9
  010f0:    stw        r1, [r0, #0x4]
  010f4:    stw        r1, [r0, #0x5]
  010f8:    hwop       r13, r1, #0x0
_REG_RMW_3:
  010fc:    stw        r13, [r0, #0x6]
  01100:    add        r13, r13, #0x1
  01104:    hwop       r12, r1, #0x0
  01108:    stw        r12, [r0, #0x7]
  0110c:    and        r12, r12, #0xffffffff
  01110:    add        r12, r12, #0x1
  01114:    subd       r11, r12, r13
  01118:    stw        r11, [r0, #0x18]
  0111c:    stw        r1, [r0, #0x8]
  01120:    stw        r1, [r0, #0x9]
  01124:    hwop       r3, r1, #0x0
  01128:    stw        r3, [r0, #0xa]
  0112c:    stw        r3, [r0, #0xb]
  01130:    hwop       r3, r1, #0x0
  01134:    lsl        r4, r3, #2
  01138:    stw        r4, [r0, #0x1]
  0113c:    hwop       r13, r13, #0x20
  01140:    add        r13, r13, #0x1
  01144:    stw        r13, [r0, #0x81]
  01148:    lsl        r11, r3, #2
  0114c:    mov        r7, #0x24
  01150:    std        r2, [r0, #0xed]
  01154:    ldd        r6, reg[r0, #0x4a14]
  01158:    and        r10, r6, #0xfffff810
  0115c:    cbnz       r10, _REG_RMW_5
  01160:    ldd        r5, reg[r0, #0x5a88]
  01164:    lsld       r4, r5, #32
  01168:    ldd        r3, reg[r0, #0x5a84]
  0116c:    hwop       r3, r3, #0x20
  01170:    ldd        r5, reg[r0, #0x5a90]
  01174:    lsld       r5, r5, #32
  01178:    ldd        r4, reg[r0, #0x5a8c]
  0117c:    hwop       r4, r5, #0x20
  01180:    hwop       r4, r4, #0x20
  01184:    ldd        r7, reg[r0, #0x5a80]
  01188:    and        r8, r7, #0x7fffffff
  0118c:    lsr        r7, r8, #1
  01190:    mov        r8, #0x4
  01194:    hwop       r7, r8, #0x3
  01198:    sub        r9, r7, #0x1
  0119c:    hwop       r4, r4, #0x6
  011a0:    lsld       r5, r3, #8
  011a4:    hwop       r5, r5, #0x20
  011a8:    lsrd       r3, r5, #32
  011ac:    stw        r5, [r0, #0x2]
_REG_RMW_4:
  011b0:    stw        r3, [r0, #0x3]
  011b4:    mov        r3, #0x1
  011b8:    stw        r3, mem[r0, #0x67]
  011bc:    b          _REG_RMW_3  
_REG_RMW_5:
  011c0:    ldd        r3, reg[r0, #0x5ab4]
  011c4:    nop
  011c8:    ldd        r6, reg[r0, #0x5ab8]
  011cc:    nop
  011d0:    ldd        r9, reg[r0, #0x5ab0]
  011d4:    nop
  011d8:    hwop       r4, r9, #0x20
  011dc:    hwop       r5, r3, #0x20
  011e0:    lsrd       r7, r5, #32
  011e4:    hwop       r6, r6, #0x0
  011e8:    stw        r5, [r0, #0x2]
  011ec:    stw        r6, [r0, #0x3]
  011f0:    std        r1, [r0, #0x6d]
  011f4:    std        r1, [r0, #0x6e]
  011f8:    hwop       r7, r0, #0x0
  011fc:    lsr        r10, r2, #31
_REG_RMW_6:
  01200:    and        r10, r10, #0xfffff001
  01204:    cbz        r10, _REG_RMW_7
  01208:    ldd        r14, reg[r0, #0x5b00]
  0120c:    nop
  01210:    stw        r14, reg[r0, #0x4ac8]
  01214:    nop
_REG_RMW_7:
  01218:    stw        r0, [r0, #0xff]
  0121c:    std        r1, [r0, #0x9b]
_REG_RMW_8:
  01220:    dw         0x84000cc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcc0
  01224:    ldd        r14, reg[r0, #0x6c]
  01228:    and        r10, r14, #0xffd30fff
  0122c:    cbnz       r10, _STRMOUT_BUFFER_UPDATE_0
  01230:    ldd        r12, reg[r0, #0x49f0]
  01234:    lsr        r10, r12, #5
  01238:    and        r12, r10, #0xfffff001
  0123c:    cbz        r12, _PKT_0x31_0
  01240:    and        r10, r14, #0xfffff001
  01244:    cbz        r10, _PKT_0x31_0
  01248:    lsr        r12, r2, #31
  0124c:    and        r12, r12, #0xfffff001

PKT_0x31:
  01250:    cbnz       r12, _PKT_0x31_0
  01254:    ldd        r10, reg[r0, #0x5ba4]
  01258:    and        r12, r10, #0xfffff001
  0125c:    cbz        r12, _STRMOUT_BUFFER_UPDATE_0
  01260:    lsr        r12, r10, #8
  01264:    and        r12, r12, #0xfffff001
  01268:    cbnz       r10, _STRMOUT_BUFFER_UPDATE_0
_PKT_0x31_0:
  0126c:    ldd        r6, reg[r0, #0x4a14]
  01270:    lsr        r6, r6, #25
  01274:    and        r10, r6, #0xfffff001
  01278:    cbz        r10, _REG_RMW_8
  0127c:    stw        r0, [r0, #0x62]
  01280:    std        r0, [r0, #0xed]
  01284:    ldd        r6, reg[r0, #0x4a14]
  01288:    and        r10, r6, #0xfffff810
  0128c:    cbnz       r10, _PKT_0x31_1
  01290:    mov        r10, #0x4a08
  01294:    stw        r0, mem[r0, #0x67]
  01298:    mov        r8, #0x5a8c
  0129c:    ldd        r4, reg[r8, #0x0]
  012a0:    b          _REG_RMW_4  
_PKT_0x31_1:
  012a4:    mov        r8, #0x5ab0
  012a8:    ldd        r4, reg[r8, #0x0]
  012ac:    mov        r10, #0x4a0c
  012b0:    lsl        r11, r11, #8

INDIRECT_BUFFER_32:
  012b4:    lsr        r11, r11, #8

PKT_0x484a:
  012b8:    addd       r11, r11, #0x4
  012bc:    ldd        r6, reg[r10, #0x0]
  012c0:    hwop       r3, r4, #0x0
  012c4:    hwop       r14, r6, #0x0
  012c8:    setgt      r12, r6, r4
  012cc:    cbz        r12, _PKT_0x484a_0
  012d0:    hwop       r14, r6, #0x0
_PKT_0x484a_0:
  012d4:    mul        r12, r3, r14
  012d8:    cbnz       r12, _INDIRECT_BUFFER_CONST_0
  012dc:    hwop       r2, r11, #0x0

INDIRECT_BUFFER_CONST:
  012e0:    b          _REG_RMW_6  
_INDIRECT_BUFFER_CONST_0:
  012e4:    hwop       r13, r3, #0x0
  012e8:    stw        r13, reg[r10, #0x0]
  012ec:    add        r2, r3, r6
  012f0:    hwop       r2, r4, #0x0
  012f4:    hwop       r13, r2, #0x0
  012f8:    stw        r13, reg[r8, #0x0]
  012fc:    add        r2, r14, r4
  01300:    lsr        r2, r2, #2
  01304:    stw        r2, reg[r0, #0x5ac0]
_INDIRECT_BUFFER_CONST_1:
  01308:    ldd        r10, reg[r0, #0x6c]

STRMOUT_BUFFER_UPDATE:
  0130c:    and        r10, r10, #0xffd30fff
  01310:    cbnz       r10, _STRMOUT_BUFFER_UPDATE_0
  01314:    ldd        r4, reg[r0, #0x5ac0]
  01318:    cbnz       r4, _INDIRECT_BUFFER_CONST_1
  0131c:    stw        r0, [r0, #0x9b]
  01320:    std        r0, [r0, #0x6d]
  01324:    b          _PKT_0xf0_2  
  01328:    nop
_STRMOUT_BUFFER_UPDATE_0:
  0132c:    lsr        r10, r2, #31
  01330:    and        r10, r10, #0xfffff001
  01334:    cbz        r10, _DRAW_INDEX_OFFSET_2_0

DRAW_INDEX_OFFSET_2:
  01338:    ldd        r6, reg[r0, #0x4ac8]
  0133c:    stw        r6, reg[r0, #0x5b00]
  01340:    stw        r0, reg[r0, #0x5ba4]
_DRAW_INDEX_OFFSET_2_0:
  01344:    stw        r0, [r0, #0x9b]
  01348:    std        r0, [r0, #0x6d]
  0134c:    b          _PKT_0x655a_11  
  01350:    dw         0x84000d30  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd30
_DRAW_INDEX_OFFSET_2_1:
  01354:    ldd        r3, reg[r0, #0x4a18]

DRAW_PREAMBLE:
  01358:    lsr        r4, r3, #16
  0135c:    and        r4, r4, #0xfffff001
  01360:    cbnz       r4, _DRAW_INDEX_OFFSET_2_1
  01364:    std        r9, [r0, #0x81]
  01368:    stw        r2, [r0, #0x200]
  0136c:    stw        r1, [r0, #0x201]
  01370:    stw        r1, [r0, #0x202]
  01374:    stw        r1, [r0, #0x203]
  01378:    stw        r1, [r0, #0x204]
  0137c:    stw        r1, [r0, #0x205]
  01380:    stw        r1, [r0, #0x206]
  01384:    stw        r1, [r0, #0x207]
  01388:    stw        r1, [r0, #0x208]
  0138c:    std        r1, [r0, #0x22d]
  01390:    hwop       r6, r2, #0x0
  01394:    lsr        r6, r6, #30
  01398:    and        r6, r6, #0xffffc007
  0139c:    orr        r7, r6, #0x1
  013a0:    cbz        r7, _COPY_DATA_0
_DRAW_PREAMBLE_0:
  013a4:    ldd        r5, reg[r0, #0x16c]
  013a8:    cbz        r5, _DRAW_PREAMBLE_0

COPY_DATA:
  013ac:    std        r1, [r0, #0x209]
_COPY_DATA_0:
  013b0:    b          _PKT_0xf0_2  
  013b4:    dw         0x84000d30  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd30
  013b8:    std        r5, [r0, #0x81]
  013bc:    stw        r2, [r0, #0x210]
  013c0:    stw        r1, [r0, #0x211]
  013c4:    stw        r1, [r0, #0x212]
  013c8:    stw        r1, [r0, #0x213]
  013cc:    stw        r1, [r0, #0x214]
_COPY_DATA_1:
  013d0:    ldd        r5, reg[r0, #0x16c]
  013d4:    cbz        r5, _COPY_DATA_1
  013d8:    std        r1, [r0, #0x215]
  013dc:    b          _PKT_0xf0_2  
  013e0:    dw         0x84000d30  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd30
  013e4:    std        r1, [r0, #0x81]
  013e8:    stw        r2, [r0, #0x219]
  013ec:    hwop       r6, r2, #0x0
  013f0:    lsr        r6, r6, #30
  013f4:    and        r6, r6, #0xfffff001
  013f8:    cbz        r6, _PKT_0xf0_9
_COPY_DATA_2:
  013fc:    ldd        r5, reg[r0, #0x16c]
  01400:    cbz        r5, _COPY_DATA_2
  01404:    std        r1, [r0, #0x220]
  01408:    b          _PKT_0xf0_2  
  0140c:    dw         0x84000d34  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd34
  01410:    std        r5, [r0, #0x81]
  01414:    stw        r2, [r0, #0x221]
  01418:    stw        r1, [r0, #0x222]
  0141c:    stw        r1, [r0, #0x223]
  01420:    stw        r1, [r0, #0x224]
  01424:    stw        r1, [r0, #0x225]
_COPY_DATA_3:
  01428:    ldd        r5, reg[r0, #0x16c]
  0142c:    cbz        r5, _COPY_DATA_3
  01430:    std        r1, [r0, #0x226]
  01434:    b          _PKT_0xf0_2  
  01438:    dw         0x84000d34  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd34
  0143c:    std        r2, [r0, #0x81]
  01440:    stw        r2, [r0, #0x216]
  01444:    stw        r1, [r0, #0x217]
_COPY_DATA_4:
  01448:    ldd        r5, reg[r0, #0x16c]
  0144c:    cbz        r5, _COPY_DATA_4
  01450:    std        r1, [r0, #0x218]
  01454:    b          _PKT_0xf0_2  
  01458:    dw         0x84000d34  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd34
  0145c:    mov        r10, #0x0
  01460:    std        r1, [r0, #0x81]
_COPY_DATA_5:
  01464:    mov        r12, #0x380
  01468:    lsl        r12, r12, #16
  0146c:    add        r11, r12, #0xc
  01470:    ldd        r6, unk[r11, #0x0]
  01474:    nop
  01478:    nop
  0147c:    cbz        r6, _COPY_DATA_5
  01480:    eor        r7, r6, r0
  01484:    cbz        r7, _COPY_DATA_5
  01488:    stw        r6, [r10, #0x211]
  0148c:    add        r10, r10, #0x1
  01490:    orr        r14, r10, #0x4
  01494:    cbz        r14, _COPY_DATA_5
_COPY_DATA_6:
  01498:    stw        r0, [r0, #0xd5]
_COPY_DATA_7:
  0149c:    ldd        r5, reg[r0, #0x16c]
  014a0:    cbz        r5, _COPY_DATA_7
  014a4:    std        r1, [r0, #0x215]
  014a8:    b          _PKT_0xf0_2  
  014ac:    std        r6, [r0, #0x81]
  014b0:    ldd        r6, reg[r0, #0x5aa8]
  014b4:    and        r12, r6, #0xfffff001
  014b8:    stw        r0, [r0, #0x7e]
  014bc:    cbz        r12, _PKT_0x70_3

DMA_DATA:
  014c0:    and        r3, r6, #0xffffffff
  014c4:    lsr        r4, r2, #16
  014c8:    lsl        r5, r4, #16
  014cc:    hwop       r7, r5, #0x7
  014d0:    stw        r7, reg[r0, #0x5aa8]
  014d4:    stw        r1, reg[r0, #0x5ab4]
  014d8:    nop
  014dc:    stw        r1, reg[r0, #0x5ab8]
  014e0:    stw        r0, reg[r0, #0x5ab0]
  014e4:    hwop       r12, r1, #0x0
  014e8:    stw        r12, reg[r0, #0x5abc]
  014ec:    stw        r0, [r0, #0x3c]
  014f0:    hwop       r3, r1, #0x0
  014f4:    hwop       r4, r1, #0x0
  014f8:    stw        r0, [r0, #0x85]
  014fc:    stw        r3, reg[r0, #0x5b30]
  01500:    stw        r4, reg[r0, #0x5b34]
  01504:    stw        r0, [r0, #0x8a]
  01508:    stw        r0, [r0, #0x7f]
  0150c:    hwop       r10, r3, #0x7
  01510:    cbz        r10, _PKT_0x70_2
  01514:    lsld       r6, r4, #32
  01518:    hwop       r6, r6, #0x20

LOAD_CONFIG_REG:
  0151c:    mov        r9, #0x5ab0
  01520:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8
  01524:    cbz        r5, _PKT_0x70_0
  01528:    mov        r9, #0x5b00
  0152c:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8
  01530:    mov        r9, #0x5b04
  01534:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8
  01538:    mov        r9, #0x5b08
  0153c:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8
  01540:    mov        r9, #0x5b0c
  01544:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8

PKT_0x70:
  01548:    mov        r9, #0x5b10
  0154c:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8
  01550:    mov        r9, #0x5b14
  01554:    dw         0x84000ea8  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xea8
  01558:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
_PKT_0x70_0:
  0155c:    lsl        r12, r12, #2
  01560:    std        r1, mem[r0, #0x43]
  01564:    std        r4, mem[r0, #0x44]
  01568:    mov        r10, #0x10
  0156c:    stw        r10, mem[r0, #0x23]
  01570:    stw        r3, mem[r0, #0x45]
  01574:    stw        r0, mem[r0, #0x48]
  01578:    stw        r0, mem[r0, #0x47]
  0157c:    stw        r4, mem[r0, #0x46]
  01580:    stw        r0, [r0, #0x62]
_PKT_0x70_1:
  01584:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  01588:    ldd        r6, reg[r0, #0x4a14]
  0158c:    lsr        r6, r6, #25
  01590:    and        r4, r6, #0xfffff001
  01594:    cbz        r4, _PKT_0x70_1
_PKT_0x70_2:
  01598:    stw        r0, [r0, #0x42]
  0159c:    b          _PKT_0x0_0  
_PKT_0x70_3:
  015a0:    hwop       r2, r1, #0x0
  015a4:    hwop       r2, r1, #0x0
  015a8:    hwop       r2, r1, #0x0
  015ac:    hwop       r2, r1, #0x0
  015b0:    hwop       r2, r1, #0x0
  015b4:    std        r1, [r0, #0x8b]
  015b8:    stw        r0, [r0, #0x62]
  015bc:    b          _PKT_0xf0_2  
  015c0:    std        r1, mem[r0, #0x43]
  015c4:    std        r4, mem[r0, #0x44]
  015c8:    stw        r2, mem[r0, #0x25]
  015cc:    lsr        r3, r2, #16
  015d0:    and        r3, r3, #0xfffc007f
  015d4:    add        r3, r3, #0x10
  015d8:    stw        r3, mem[r0, #0x117]
  015dc:    lsr        r3, r2, #24
  015e0:    and        r3, r3, #0xffffc007
  015e4:    add        r3, r3, #0x10
  015e8:    stw        r3, mem[r0, #0x118]
  015ec:    lsr        r2, r1, #2
  015f0:    lsl        r2, r2, #2
  015f4:    stw        r2, mem[r0, #0x45]
  015f8:    hwop       r3, r1, #0x0
  015fc:    ldd        r6, reg[r0, #0x49f0]
  01600:    and        r10, r6, #0xf800ffff

INCREMENT_DE_COUNTER:
  01604:    lsr        r10, r10, #3
  01608:    stw        r10, mem[r0, #0x47]
  0160c:    stw        r1, mem[r0, #0x48]
  01610:    stw        r3, mem[r0, #0x46]
  01614:    std        r4, [r0, #0x81]
  01618:    b          _PKT_0xf0_2  
  0161c:    ldd        r6, reg[r0, #0x49f0]
  01620:    hwop       r3, r1, #0x0
  01624:    std        r2, [r0, #0x81]
  01628:    and        r10, r6, #0xfffff001
  0162c:    cbz        r10, _INCREMENT_DE_COUNTER_0
  01630:    mov        r2, #0xe0
  01634:    stw        r2, [r0, #0x50]
  01638:    stw        r3, [r0, #0x51]
  0163c:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
_INCREMENT_DE_COUNTER_0:
  01640:    stw        r0, [r0, #0x62]
  01644:    b          _PKT_0xf0_2  
  01648:    stw        r2, [r0, #0x55]
  0164c:    std        r3, [r0, #0x81]
  01650:    lsr        r3, r2, #30
  01654:    and        r3, r3, #0xfffff001
  01658:    stw        r1, [r0, #0x56]
  0165c:    stw        r1, [r0, #0x57]
_INCREMENT_DE_COUNTER_1:
  01660:    ldd        r6, reg[r0, #0x4a14]
  01664:    nop
  01668:    and        r10, r6, #0xfffff810
  0166c:    cbz        r10, _INCREMENT_DE_COUNTER_2
  01670:    nop
  01674:    ldd        r6, reg[r0, #0x80]
  01678:    nop
  0167c:    cbnz       r6, _PKT_0xe9be_29
  01680:    nop
_INCREMENT_DE_COUNTER_2:
  01684:    nop
  01688:    ldd        r5, [r0, #0x58]
  0168c:    nop

INCREMENT_CE_COUNTER:
  01690:    sub        r6, r5, #0x3
  01694:    cbz        r6, _INCREMENT_CE_COUNTER_1
  01698:    sub        r7, r5, #0x1
  0169c:    cbz        r7, _INCREMENT_CE_COUNTER_0
  016a0:    dw         0x84000cab  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcab
  016a4:    dw         0x84000cc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcc0
  016a8:    dw         0x84001395  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1395
  016ac:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  016b0:    ldd        r6, reg[r0, #0x6c]
  016b4:    and        r4, r6, #0xff001fff
  016b8:    cbnz       r4, _PKT_0x6ac7_2
  016bc:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  016c0:    ldd        r7, [r0, #0x59]
  016c4:    cbz        r7, _INCREMENT_DE_COUNTER_1
  016c8:    mov        r2, #0xe2
  016cc:    stw        r2, [r0, #0x50]
  016d0:    mov        r3, #0x1
  016d4:    stw        r3, [r0, #0x65]
  016d8:    mov        r2, #0xffff
  016dc:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  016e0:    b          _PKT_0x6ac7_52  
_INCREMENT_CE_COUNTER_0:
  016e4:    mov        r2, #0xdd
  016e8:    stw        r2, [r0, #0x50]
  016ec:    mov        r4, #0x5
  016f0:    stw        r4, [r0, #0x65]
  016f4:    mov        r2, #0xffff
  016f8:    b          _PKT_0x6ac7_7  
_INCREMENT_CE_COUNTER_1:
  016fc:    stw        r0, [r0, #0x62]
  01700:    b          _PKT_0xf0_2  
  01704:    stw        r0, [r0, #0xd5]
  01708:    hwop       r3, r1, #0x0
  0170c:    stw        r3, reg[r0, #0x4f80]
  01710:    hwop       r3, r1, #0x0
  01714:    stw        r3, reg[r0, #0x4f84]
  01718:    hwop       r3, r1, #0x0
  0171c:    lsr        r4, r3, #17
  01720:    and        r4, r4, #0x7fffffff
  01724:    stw        r4, reg[r0, #0x4f88]
  01728:    lsl        r4, r3, #15
  0172c:    lsr        r4, r4, #15
  01730:    stw        r4, reg[r0, #0x4f8c]
  01734:    hwop       r9, r1, #0x0
  01738:    hwop       r13, r1, #0x0
  0173c:    ldd        r3, reg[r0, #0x4f84]
  01740:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  01744:    hwop       r13, r1, #0x0
  01748:    ldd        r3, reg[r0, #0x4f88]
  0174c:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  01750:    add        r13, r9, #0x0
  01754:    ldd        r3, reg[r0, #0x4f80]
  01758:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  0175c:    hwop       r8, r1, #0x0
  01760:    lsl        r8, r8, #2
  01764:    ldd        r3, reg[r0, #0x4f8c]
  01768:    dw         0x8400059d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x59d
  0176c:    std        r8, [r0, #0x81]
  01770:    b          _PKT_0xf0_2  
_INCREMENT_CE_COUNTER_2:
  01774:    std        r15, [r0, #0xd1]
  01778:    ldd        r12, unk[r8, #0x0]
  0177c:    nop
  01780:    dw         0x84000f71  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf71
  01784:    hwop       r14, r12, #0x6
  01788:    cbz        r14, _INCREMENT_CE_COUNTER_2
  0178c:    btab

  01790:    hwop       r3, r1, #0x0
  01794:    stw        r3, reg[r0, #0x4f80]
  01798:    nop
  0179c:    hwop       r3, r1, #0x0
  017a0:    stw        r3, reg[r0, #0x4f84]
  017a4:    nop
  017a8:    hwop       r3, r1, #0x0
  017ac:    lsr        r4, r3, #16
  017b0:    and        r4, r4, #0x7fffffff
  017b4:    stw        r4, reg[r0, #0x4f88]
  017b8:    nop
  017bc:    and        r4, r3, #0xffffffff
  017c0:    stw        r4, reg[r0, #0x4f8c]
  017c4:    nop
  017c8:    lsr        r4, r3, #21
  017cc:    and        r4, r4, #0xfffff001
  017d0:    lsr        r5, r3, #22
  017d4:    and        r5, r5, #0xfffff001
  017d8:    mov        r3, #0x1
  017dc:    lsl        r3, r3, #16
  017e0:    mov        r6, #0xa6e4
  017e4:    hwop       r6, r6, #0x0
  017e8:    mov        r7, #0xa709
  017ec:    hwop       r7, r7, #0x0
  017f0:    mov        r8, #0xa70a
  017f4:    hwop       r8, r8, #0x0
  017f8:    mov        r9, #0x28a4
  017fc:    mov        r10, #0x28c9
  01800:    mov        r11, #0x28ca
  01804:    ldd        r14, reg[r0, #0x4a60]
  01808:    and        r13, r14, #0xffffc007
  0180c:    cbz        r13, PKT_0x71
  01810:    mov        r3, #0x1
  01814:    lsl        r3, r3, #16
  01818:    mov        r6, #0xa6e7
  0181c:    hwop       r6, r6, #0x0
  01820:    mov        r7, #0xa70f
  01824:    hwop       r7, r7, #0x0
  01828:    mov        r8, #0xa710
  0182c:    hwop       r8, r8, #0x0
  01830:    mov        r9, #0x28a7
  01834:    mov        r10, #0x28cf
  01838:    mov        r11, #0x28d0

PKT_0x71:
  0183c:    cbz        r5, _PKT_0x71_0
  01840:    ldd        r3, reg[r0, #0x4f84]
  01844:    hwop       r13, r7, #0x0
  01848:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  0184c:    ldd        r3, reg[r0, #0x4f88]
  01850:    hwop       r13, r8, #0x0
  01854:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  01858:    ldd        r3, reg[r0, #0x4f80]
  0185c:    hwop       r13, r6, #0x0
  01860:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
_PKT_0x71_0:
  01864:    cbz        r4, _PKT_0x71_1
  01868:    ldd        r3, reg[r0, #0x4f84]
  0186c:    hwop       r13, r10, #0x0
  01870:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  01874:    ldd        r3, reg[r0, #0x4f88]
  01878:    hwop       r13, r11, #0x0
  0187c:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
  01880:    ldd        r3, reg[r0, #0x4f80]
  01884:    hwop       r13, r9, #0x0
  01888:    dw         0x8400060a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x60a
_PKT_0x71_1:
  0188c:    mov        r3, #0x6
  01890:    lsl        r3, r3, #16
  01894:    mov        r6, #0x9bd8
  01898:    hwop       r6, r6, #0x0
  0189c:    mov        r7, #0xa2d8
  018a0:    mov        r9, #0xa290
  018a4:    ldd        r14, reg[r0, #0x4a60]
  018a8:    and        r13, r14, #0xffffc007
  018ac:    cbz        r13, _WRITE_CONST_RAM_0

WRITE_CONST_RAM:
  018b0:    mov        r3, #0x6
  018b4:    lsl        r3, r3, #16
  018b8:    mov        r6, #0x9be4
  018bc:    hwop       r6, r6, #0x0
  018c0:    mov        r7, #0xa2e4
  018c4:    mov        r9, #0xa29c
_WRITE_CONST_RAM_0:
  018c8:    cbz        r5, _WRITE_CONST_RAM_1
  018cc:    mov        r10, #0x0
  018d0:    hwop       r8, r6, #0x0
  018d4:    dw         0x840005fe  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x5fe
  018d8:    nop
_WRITE_CONST_RAM_1:
  018dc:    cbz        r4, PKT_0x82
  018e0:    mov        r10, #0x1
  018e4:    hwop       r8, r7, #0x0
  018e8:    dw         0x840005fe  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x5fe
  018ec:    nop

PKT_0x82:
  018f0:    std        r4, [r0, #0x81]
  018f4:    b          _PKT_0xf0_2  
  018f8:    ldd        r3, reg[r0, #0x4f8c]
_PKT_0x82_0:
  018fc:    cbz        r10, _PKT_0x82_1
  01900:    ldd        r12, unk[r9, #0x0]
  01904:    nop
_PKT_0x82_1:
  01908:    std        r15, [r0, #0xd1]
  0190c:    ldd        r12, unk[r8, #0x0]
  01910:    nop
  01914:    dw         0x84000f71  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf71
  01918:    and        r13, r12, #0xffffffff
  0191c:    seteq      r14, r13, r3
  01920:    cbz        r14, _PKT_0x82_0
  01924:    btab

  01928:    std        r15, [r0, #0xd1]
  0192c:    stw        r13, [r0, #0x5b]
_PKT_0x82_2:
  01930:    stw        r3, [r0, #0x5c]
  01934:    dw         0x84000f71  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf71
  01938:    btab

  0193c:    hwop       r3, r1, #0x0
  01940:    hwop       r4, r1, #0x0
  01944:    lsld       r10, r4, #32
  01948:    hwop       r11, r10, #0x20
  0194c:    addd       r10, r11, #0x4
  01950:    hwop       r5, r10, #0x0
  01954:    lsrd       r6, r10, #32
  01958:    stw        r3, mem[r0, #0x52]
  0195c:    stw        r4, mem[r0, #0x53]
  01960:    ldd        r12, mem[r0, #0x0]
  01964:    nop
  01968:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  0196c:    nop
  01970:    nop
  01974:    lsld       r14, r13, #32
  01978:    hwop       r14, r14, #0x20
_PKT_0x82_3:
  0197c:    addd       r14, r14, #0x1
  01980:    hwop       r12, r14, #0x0
  01984:    lsrd       r13, r14, #32
  01988:    std        r1, mem[r0, #0x43]
  0198c:    std        r4, mem[r0, #0x44]
  01990:    std        r0, mem[r0, #0x47]
  01994:    stw        r3, mem[r0, #0x45]
  01998:    stw        r12, mem[r0, #0x48]
  0199c:    stw        r4, mem[r0, #0x46]
  019a0:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  019a4:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  019a8:    std        r3, [r0, #0x81]
  019ac:    b          _PKT_0xf0_2  
  019b0:    std        r3, [r0, #0xd3]
  019b4:    hwop       r3, r1, #0x0
  019b8:    hwop       r4, r1, #0x0
  019bc:    hwop       r5, r1, #0x0
  019c0:    ldd        r6, unk[r3, #0x0]
  019c4:    nop
  019c8:    nop
  019cc:    std        r1, mem[r0, #0x43]
  019d0:    std        r4, mem[r0, #0x44]
  019d4:    nop
  019d8:    stw        r4, mem[r0, #0x45]
  019dc:    stw        r6, mem[r0, #0x48]
  019e0:    stw        r0, mem[r0, #0x47]
  019e4:    stw        r5, mem[r0, #0x46]
  019e8:    std        r4, [r0, #0x81]
  019ec:    b          _PKT_0xf0_2  
  019f0:    lsr        r10, r2, #16
  019f4:    orr        r11, r10, #0x0
  019f8:    cbnz       r11, _PKT_0x82_4
  019fc:    orr        r11, r10, #0x1
  01a00:    cbnz       r11, _PKT_0x82_5
  01a04:    orr        r11, r10, #0x2
  01a08:    cbnz       r11, _PKT_0x82_7
  01a0c:    b          _PKT_0x82_6  
_PKT_0x82_4:
  01a10:    mov        r10, #0x14c
  01a14:    mov        r11, #0x148
  01a18:    b          _PKT_0x82_2  
_PKT_0x82_5:
  01a1c:    mov        r10, #0x154
  01a20:    mov        r11, #0x150
_PKT_0x82_6:
  01a24:    b          _PKT_0x82_2  
_PKT_0x82_7:
  01a28:    mov        r10, #0x144
  01a2c:    mov        r11, #0x140
  01a30:    mov        r2, #0x0
  01a34:    ldd        r12, reg[r10, #0x0]
  01a38:    mov        r5, #0x0
  01a3c:    ldd        r13, reg[r11, #0x0]
  01a40:    mov        r8, #0x0
  01a44:    hwop       r3, r1, #0x0
  01a48:    hwop       r4, r1, #0x0
  01a4c:    lsld       r6, r4, #32
  01a50:    hwop       r6, r6, #0x20
  01a54:    hwop       r4, r1, #0x0
  01a58:    add        r3, r4, #0x0
  01a5c:    ldd        r4, reg[r0, #0x4a20]
  01a60:    and        r4, r4, #0xffffc007
  01a64:    add        r7, r4, #0x4
  01a68:    mov        r14, #0x1
  01a6c:    hwop       r4, r14, #0x3
  01a70:    hwop       r7, r1, #0x0
  01a74:    std        r3, [r0, #0xd3]
  01a78:    stw        r0, [r0, #0xd5]
_PKT_0x82_8:
  01a7c:    lsld       r11, r12, #2
  01a80:    ldd        r10, unk[r11, #0x0]
  01a84:    nop
  01a88:    and        r9, r10, #0xfffff001
  01a8c:    cbz        r9, _PKT_0x82_8
  01a90:    dw         0x84000691  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x691
  01a94:    ldd        r9, reg[r0, #0x4a80]
  01a98:    and        r9, r9, #0xfffff001
  01a9c:    cbnz       r9, _PKT_0x82_8
  01aa0:    stw        r13, [r0, #0x5b]
  01aa4:    stw        r14, [r0, #0x5c]
  01aa8:    hwop       r3, r3, #0x20
  01aac:    dw         0x84000112  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112
  01ab0:    lsld       r11, r12, #2
_PKT_0x82_9:
  01ab4:    ldd        r10, unk[r11, #0x0]
  01ab8:    nop
  01abc:    and        r9, r10, #0xfffff001
  01ac0:    cbz        r9, _PKT_0x82_9
  01ac4:    nop
  01ac8:    std        r1, [r0, #0xf3]
  01acc:    std        r0, [r0, #0xf3]
  01ad0:    lsr        r11, r10, #1
  01ad4:    and        r10, r11, #0xfffff001

LOAD_CONST_RAM:
  01ad8:    and        r9, r2, #0x7fffffff
  01adc:    hwop       r11, r10, #0x3
  01ae0:    hwop       r5, r5, #0x0
  01ae4:    add        r2, r2, #0x1
  01ae8:    seteq      r11, r2, r7
  01aec:    cbnz       r11, _LOAD_CONST_RAM_1
  01af0:    and        r10, r2, #0xfffc007f
  01af4:    cbnz       r10, _LOAD_CONST_RAM_0
  01af8:    lsl        r11, r8, #1
  01afc:    add        r8, r11, #0x1
_LOAD_CONST_RAM_0:
  01b00:    and        r11, r2, #0x7fffffff
  01b04:    cbnz       r11, _PKT_0x82_8
  01b08:    dw         0x84000f14  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf14
  01b0c:    mov        r5, #0x0
  01b10:    mov        r8, #0x0
  01b14:    b          _PKT_0x82_3  
_LOAD_CONST_RAM_1:
  01b18:    lsl        r11, r8, #1
  01b1c:    add        r8, r11, #0x1
  01b20:    dw         0x84000f14  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf14
  01b24:    std        r5, [r0, #0x81]
  01b28:    b          _PKT_0xf0_2  
  01b2c:    hwop       r2, r1, #0x0
  01b30:    hwop       r2, r1, #0x0
  01b34:    hwop       r2, r1, #0x0
  01b38:    hwop       r2, r1, #0x0
  01b3c:    std        r5, [r0, #0x81]
  01b40:    b          _PKT_0xf0_2  
  01b44:    lsr        r10, r3, #4
  01b48:    lsl        r14, r10, #4
  01b4c:    lsld       r9, r14, #12
  01b50:    add        r10, r9, #0x0
  01b54:    lsrd       r14, r9, #32
  01b58:    std        r1, [r0, #0xbe]
  01b5c:    stw        r10, [r0, #0xb9]
  01b60:    stw        r14, [r0, #0xba]
  01b64:    ldd        r10, [r0, #0xbb]
  01b68:    ldd        r14, [r0, #0xbf]
  01b6c:    lsld       r9, r14, #32
  01b70:    hwop       r9, r9, #0x20
  01b74:    lsrd       r10, r9, #16
  01b78:    lsld       r14, r10, #4
  01b7c:    add        r14, r14, #0x3
  01b80:    btab

  01b84:    cbz        r10, _LOAD_CONST_RAM_4
  01b88:    nop
  01b8c:    cbnz       r4, _LOAD_CONST_RAM_4
  01b90:    mov        r12, #0x1
  01b94:    lsl        r12, r12, #31
  01b98:    seteq      r14, r5, r12
  01b9c:    cbz        r14, _LOAD_CONST_RAM_4
  01ba0:    mov        r3, #0x1000
  01ba4:    mov        r4, #0x389c
  01ba8:    mov        r5, #0x3898
_LOAD_CONST_RAM_2:
  01bac:    mov        r7, #0x400
  01bb0:    ldd        r14, reg[r0, #0x4a60]
  01bb4:    and        r12, r14, #0xffffc007
  01bb8:    cbz        r12, _LOAD_CONST_RAM_3
  01bbc:    lsl        r14, r7, #1
  01bc0:    add        r7, r14, #0x0
_LOAD_CONST_RAM_3:
  01bc4:    std        r3, [r0, #0x71]
  01bc8:    stw        r7, [r0, #0x73]
  01bcc:    stw        r7, [r0, #0x72]
  01bd0:    mov        r6, #0x3
_LOAD_CONST_RAM_4:
  01bd4:    btab

  01bd8:    lsr        r10, r2, #26
  01bdc:    and        r7, r10, #0xfffff001
  01be0:    lsr        r11, r2, #31
  01be4:    eor        r10, r11, r0
  01be8:    hwop       r6, r7, #0x6
  01bec:    lsr        r2, r2, #28
  01bf0:    and        r13, r2, #0xfffc007f
  01bf4:    stw        r13, [r0, #0x71]
  01bf8:    hwop       r4, r1, #0x0
  01bfc:    hwop       r5, r1, #0x0
  01c00:    hwop       r7, r1, #0x0
  01c04:    stw        r7, [r0, #0x73]
  01c08:    stw        r1, [r0, #0x72]
  01c0c:    std        r6, [r0, #0x81]
  01c10:    std        r3, [r0, #0xd3]
  01c14:    hwop       r9, r1, #0x0
  01c18:    and        r8, r9, #0xffffffff
  01c1c:    lsr        r3, r9, #16
  01c20:    cbz        r3, _LOAD_CONST_RAM_5
  01c24:    addd       r3, r3, #0x1
_LOAD_CONST_RAM_5:
  01c28:    dw         0x840006a1  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x6a1
  01c2c:    setgt      r12, r8, #0x3
  01c30:    lsl        r8, r8, #2
  01c34:    cbnz       r12, _LOAD_CONST_RAM_6
  01c38:    mov        r8, #0x10
_LOAD_CONST_RAM_6:
  01c3c:    mov        r9, #0x1
  01c40:    cbz        r6, _LOAD_CONST_RAM_7
  01c44:    lsr        r14, r5, #20
  01c48:    lsl        r14, r14, #20
  01c4c:    lsl        r10, r5, #12
  01c50:    lsr        r10, r10, #12
  01c54:    lsr        r10, r10, #2
  01c58:    hwop       r10, r10, #0x0
  01c5c:    mov        r2, #0xf
  01c60:    lsl        r2, r2, #28
  01c64:    dw         0x840009b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x9b6
_LOAD_CONST_RAM_7:
  01c68:    ldd        r14, reg[r0, #0x49f4]
  01c6c:    mov        r12, #0x1
  01c70:    lsl        r12, r12, #20
  01c74:    hwop       r14, r14, #0x27
  01c78:    stw        r14, reg[r0, #0x49f4]
_LOAD_CONST_RAM_8:
  01c7c:    sub        r9, r9, #0x1
  01c80:    cbnz       r9, _LOAD_CONST_RAM_8
  01c84:    cbnz       r11, _DUMP_CONST_RAM_0

DUMP_CONST_RAM:
  01c88:    stw        r0, [r0, #0x74]
  01c8c:    std        r15, [r0, #0xd1]
  01c90:    ldd        r12, unk[r4, #0x0]
  01c94:    b          _LOAD_CONST_RAM_2  
_DUMP_CONST_RAM_0:
  01c98:    stw        r4, mem[r0, #0x52]
  01c9c:    stw        r5, mem[r0, #0x53]
  01ca0:    stw        r0, [r0, #0x74]
  01ca4:    nop
  01ca8:    ldd        r12, mem[r0, #0x0]
  01cac:    dw         0x84000cab  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcab
  01cb0:    dw         0x84000cc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcc0
  01cb4:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  01cb8:    cbnz       r12, _DUMP_CONST_RAM_3
  01cbc:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  01cc0:    ldd        r14, reg[r0, #0x6c]
  01cc4:    and        r14, r14, #0xfffff001
  01cc8:    cbnz       r14, _PKT_0x6ac7_2
  01ccc:    dw         0x84001395  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1395
  01cd0:    cbz        r11, _DUMP_CONST_RAM_1
  01cd4:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  01cd8:    orr        r10, r3, #0x1000
  01cdc:    cbz        r10, _DUMP_CONST_RAM_1
  01ce0:    ldd        r14, reg[r0, #0x6c]
  01ce4:    and        r14, r14, #0xffffe003
  01ce8:    cbnz       r14, _PKT_0x6ac7_2
_DUMP_CONST_RAM_1:
  01cec:    hwop       r9, r8, #0x0
  01cf0:    cbz        r3, _DUMP_CONST_RAM_2
  01cf4:    ldd        r14, reg[r0, #0x49f4]
  01cf8:    lsr        r10, r14, #20
  01cfc:    and        r14, r10, #0xfffff001
  01d00:    cbz        r14, _DUMP_CONST_RAM_5
  01d04:    lsr        r10, r3, #12
  01d08:    sub        r10, r10, #0x1
  01d0c:    cbz        r10, _LOAD_CONST_RAM_8
  01d10:    subd       r3, r3, #0x1
  01d14:    cbnz       r3, _LOAD_CONST_RAM_8
_DUMP_CONST_RAM_2:
  01d18:    mov        r2, #0xf6
  01d1c:    stw        r2, [r0, #0x50]
  01d20:    mov        r3, #0x2
  01d24:    stw        r3, [r0, #0x65]
  01d28:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  01d2c:    dw         0x8400071b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71b
  01d30:    b          _PKT_0x6ac7_52  
_DUMP_CONST_RAM_3:
  01d34:    cbz        r6, _DUMP_CONST_RAM_5
  01d38:    lsr        r14, r4, #20
  01d3c:    lsl        r14, r14, #20
  01d40:    lsl        r10, r4, #12
  01d44:    lsr        r10, r10, #12
  01d48:    lsr        r10, r10, #2
  01d4c:    hwop       r10, r10, #0x0
  01d50:    mov        r2, #0xf
  01d54:    lsl        r2, r2, #28
_DUMP_CONST_RAM_4:
  01d58:    dw         0x840009b6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x9b6
_DUMP_CONST_RAM_5:
  01d5c:    dw         0x8400071b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x71b
  01d60:    stw        r0, [r0, #0x62]
  01d64:    stw        r0, [r0, #0x7e]
  01d68:    b          _PKT_0x0_2  
  01d6c:    ldd        r11, reg[r0, #0x49f4]
  01d70:    mov        r12, #0x1
  01d74:    lsl        r14, r12, #20
  01d78:    eor        r12, r14, r0
  01d7c:    hwop       r14, r11, #0x6
  01d80:    stw        r14, reg[r0, #0x49f4]
  01d84:    btab

  01d88:    stw        r0, reg[r0, #0x4f94]
  01d8c:    nop
  01d90:    lsr        r11, r2, #31
  01d94:    hwop       r3, r1, #0x0
  01d98:    cbnz       r11, _DUMP_CONST_RAM_6
  01d9c:    nop
  01da0:    stw        r3, reg[r0, #0x4f80]
  01da4:    nop
  01da8:    nop
  01dac:    stw        r3, reg[r0, #0x4f84]
  01db0:    nop
  01db4:    nop
  01db8:    stw        r3, reg[r0, #0x4f88]
  01dbc:    nop
  01dc0:    nop
  01dc4:    stw        r3, reg[r0, #0x4f8c]
  01dc8:    nop
  01dcc:    nop
  01dd0:    stw        r3, reg[r0, #0x5100]
  01dd4:    nop
  01dd8:    nop
  01ddc:    stw        r3, reg[r0, #0x5104]
  01de0:    nop
  01de4:    nop
  01de8:    stw        r3, reg[r0, #0x5108]
  01dec:    nop
  01df0:    nop
  01df4:    stw        r3, reg[r0, #0x510c]
  01df8:    nop
  01dfc:    nop
_DUMP_CONST_RAM_6:
  01e00:    hwop       r4, r1, #0x0
  01e04:    hwop       r5, r1, #0x0
  01e08:    lsld       r6, r5, #32
  01e0c:    hwop       r6, r6, #0x20
  01e10:    hwop       r4, r1, #0x0
  01e14:    hwop       r5, r1, #0x0
  01e18:    lsld       r7, r5, #32
  01e1c:    hwop       r7, r7, #0x20
  01e20:    hwop       r4, r1, #0x0
  01e24:    hwop       r5, r1, #0x0
  01e28:    lsld       r8, r5, #32
  01e2c:    hwop       r8, r8, #0x20
  01e30:    hwop       r4, r1, #0x0

PKT_0x914:
  01e34:    hwop       r5, r1, #0x0
  01e38:    lsld       r9, r5, #32
  01e3c:    hwop       r9, r9, #0x20
  01e40:    hwop       r13, r1, #0x0
  01e44:    hwop       r14, r1, #0x0
  01e48:    lsld       r12, r14, #32
  01e4c:    hwop       r13, r13, #0x20
  01e50:    hwop       r2, r1, #0x0
  01e54:    std        r13, [r0, #0x81]
_PKT_0x914_0:
  01e58:    cbz        r11, _PKT_0x914_3
  01e5c:    hwop       r4, r8, #0x0
  01e60:    lsrd       r5, r8, #32
  01e64:    and        r10, r4, #0x7fffffff
  01e68:    cbnz       r10, _PKT_0x914_3
_PKT_0x914_1:
  01e6c:    cbz        r10, _PKT_0x914_2
  01e70:    std        r3, mem[r0, #0x37]
_PKT_0x914_2:
  01e74:    stw        r4, mem[r0, #0x52]
  01e78:    stw        r5, mem[r0, #0x53]
  01e7c:    nop
  01e80:    nop
  01e84:    ldd        r3, mem[r0, #0x0]
  01e88:    nop
  01e8c:    std        r0, mem[r0, #0x37]
  01e90:    dw         0x840007a5  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7a5
  01e94:    stw        r3, reg[r12, #0x0]
  01e98:    nop
  01e9c:    cbnz       r10, _PKT_0x914_1
_PKT_0x914_3:
  01ea0:    hwop       r4, r6, #0x0
  01ea4:    lsrd       r5, r6, #32
  01ea8:    and        r10, r4, #0x7fffffff
_PKT_0x914_4:
  01eac:    cbz        r10, _PKT_0x914_5
  01eb0:    std        r3, mem[r0, #0x37]
_PKT_0x914_5:
  01eb4:    stw        r4, mem[r0, #0x52]
  01eb8:    stw        r5, mem[r0, #0x53]
  01ebc:    nop
  01ec0:    nop
  01ec4:    ldd        r2, mem[r0, #0x0]
  01ec8:    nop
  01ecc:    std        r0, mem[r0, #0x37]
  01ed0:    dw         0x840007a5  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x7a5

PKT_0xf0:
  01ed4:    ldd        r3, reg[r12, #0x0]
  01ed8:    nop
  01edc:    nop
  01ee0:    seteq      r12, r2, r3
  01ee4:    ldd        r4, reg[r0, #0x4f94]
  01ee8:    nop
  01eec:    add        r5, r4, #0x1
  01ef0:    stw        r5, reg[r0, #0x4f94]
  01ef4:    nop
  01ef8:    cbnz       r12, _PKT_0x90_1
  01efc:    mov        r14, #0x0

PKT_0x90:
  01f00:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f04:    hwop       r14, r6, #0x0
  01f08:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f0c:    lsrd       r14, r6, #32
  01f10:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f14:    hwop       r14, r2, #0x0
  01f18:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f1c:    cbz        r11, _PKT_0xf0_9
  01f20:    hwop       r14, r8, #0x0
  01f24:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f28:    lsrd       r14, r8, #32
  01f2c:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f30:    hwop       r14, r3, #0x0
_PKT_0x90_0:
  01f34:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f38:    b          _PKT_0xf0_2  
_PKT_0x90_1:
  01f3c:    addd       r6, r6, #0x4
  01f40:    addd       r8, r8, #0x4
  01f44:    mul        r14, r6, r7
  01f48:    cbnz       r14, _PKT_0x90_2
  01f4c:    cbz        r11, _PKT_0x914_0
  01f50:    mul        r14, r8, r9
  01f54:    cbnz       r14, _PKT_0x90_2
  01f58:    b          _DUMP_CONST_RAM_4  
_PKT_0x90_2:
  01f5c:    mov        r14, #0x1
  01f60:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  01f64:    b          _PKT_0xf0_2  
  01f68:    hwop       r4, r13, #0x0
  01f6c:    lsrd       r5, r13, #32
  01f70:    std        r1, mem[r0, #0x43]
  01f74:    std        r4, mem[r0, #0x44]
  01f78:    nop
  01f7c:    stw        r4, mem[r0, #0x45]
  01f80:    stw        r14, mem[r0, #0x48]
  01f84:    stw        r0, mem[r0, #0x47]

PKT_0xa0:
  01f88:    stw        r5, mem[r0, #0x46]
  01f8c:    addd       r13, r13, #0x4
  01f90:    btab

  01f94:    lsr        r12, r10, #4
  01f98:    cbnz       r12, _PKT_0xa0_0
  01f9c:    mov        r12, #0x4f80
  01fa0:    b          _PKT_0x914_4  
  01fa4:    nop
_PKT_0xa0_0:
  01fa8:    mov        r12, #0x5100
  01fac:    and        r14, r10, #0xfc007fff
  01fb0:    hwop       r12, r12, #0x0
  01fb4:    lsld       r14, r5, #32
  01fb8:    hwop       r14, r14, #0x20
  01fbc:    addd       r14, r14, #0x4
  01fc0:    hwop       r4, r14, #0x0
  01fc4:    lsrd       r5, r14, #32
  01fc8:    and        r10, r4, #0x7fffffff
  01fcc:    btab

  01fd0:    nop
  01fd4:    lsr        r13, r2, #16
  01fd8:    and        r14, r13, #0xffffffff
  01fdc:    ldd        r11, reg[r0, #0x4a50]
  01fe0:    and        r12, r11, #0xffffffff
  01fe4:    hwop       r4, r12, #0x6
  01fe8:    orr        r3, r4, r0
  01fec:    eor        r2, r3, r0
  01ff0:    and        r2, r2, #0xfffff001
  01ff4:    hwop       r5, r1, #0x0
  01ff8:    std        r2, [r0, #0x81]
  01ffc:    b          _PKT_0x90_0  
  02000:    hwop       r3, r1, #0x0
  02004:    stw        r3, mem[r0, #0x52]
  02008:    hwop       r4, r1, #0x0
  0200c:    stw        r4, mem[r0, #0x53]
_PKT_0xa0_1:
  02010:    nop
  02014:    hwop       r5, r1, #0x0
  02018:    ldd        r4, mem[r0, #0x0]
  0201c:    setgt      r2, r4, r5
  02020:    hwop       r5, r1, #0x0
  02024:    ldd        r6, reg[r0, #0x4a14]
  02028:    and        r8, r6, #0xfffff810
  0202c:    cbnz       r8, _PKT_0xa0_2
  02030:    stw        r5, reg[r0, #0x5b3c]
_PKT_0xa0_2:
  02034:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02038:    stw        r0, [r0, #0x62]
  0203c:    cbz        r2, _PKT_0xa0_5
  02040:    stw        r5, reg[r0, #0x5ac0]
  02044:    hwop       r4, r5, #0x0
_PKT_0xa0_3:
  02048:    ldd        r7, reg[r0, #0x6c]
  0204c:    and        r7, r7, #0xfffffd20
  02050:    cbnz       r7, _PKT_0x6ac7_2
  02054:    hwop       r5, r4, #0x0
  02058:    ldd        r4, reg[r0, #0x5ac0]
  0205c:    add        r7, r5, r4
  02060:    cbnz       r7, _PKT_0xa0_3
  02064:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  02068:    stw        r0, [r0, #0x62]
  0206c:    ldd        r6, reg[r0, #0x6c]
  02070:    and        r3, r6, #0xfffff001
  02074:    cbnz       r3, _PKT_0x6ac7_2
  02078:    cbnz       r8, _PKT_0xa0_4
  0207c:    stw        r4, reg[r0, #0x5b3c]
_PKT_0xa0_4:
  02080:    cbnz       r4, _PKT_0xa0_3
_PKT_0xa0_5:
  02084:    b          _PKT_0xf0_2  
  02088:    ldd        r12, reg[r0, #0x6c]
  0208c:    and        r12, r12, #0xffd30fff
  02090:    cbnz       r12, _PKT_0x6ac7_2
  02094:    std        r1, [r0, #0x9b]
  02098:    std        r1, [r0, #0xfd]
  0209c:    dw         0x840012ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ac
  020a0:    lsr        r3, r2, #18
  020a4:    stw        r3, [r0, #0xee]
  020a8:    lsr        r10, r2, #25
  020ac:    and        r11, r10, #0xffffffff
_PKT_0xa0_6:
  020b0:    lsr        r10, r2, #16
  020b4:    and        r14, r10, #0xfffff001
  020b8:    orr        r3, r11, #0x8
  020bc:    orr        r12, r11, #0x28
  020c0:    hwop       r3, r12, #0x7
  020c4:    hwop       r14, r3, #0x6
  020c8:    orr        r12, r11, #0x48
  020cc:    hwop       r3, r12, #0x7
  020d0:    orr        r12, r11, #0x68
  020d4:    hwop       r3, r12, #0x7
  020d8:    eor        r12, r11, #0x20
  020dc:    lsr        r10, r2, #30
_PKT_0xa0_7:
  020e0:    and        r9, r10, #0xfffff001
  020e4:    hwop       r13, r12, #0x6
  020e8:    hwop       r4, r1, #0x0
  020ec:    hwop       r5, r1, #0x0
  020f0:    hwop       r6, r1, #0x0
  020f4:    hwop       r7, r1, #0x0
  020f8:    hwop       r8, r1, #0x0
  020fc:    hwop       r9, r1, #0x0
  02100:    hwop       r10, r1, #0x0
  02104:    and        r10, r10, #0xffffffff
  02108:    std        r8, [r0, #0x81]
  0210c:    cbz        r11, _PKT_0xb1_2
  02110:    std        r5, mem[r0, #0x43]
  02114:    stw        r11, mem[r0, #0xa7]
  02118:    stw        r13, mem[r0, #0xa1]
  0211c:    stw        r3, mem[r0, #0xa2]
  02120:    std        r0, mem[r0, #0x47]
  02124:    stw        r4, mem[r0, #0x45]
  02128:    stw        r8, mem[r0, #0xa3]
  0212c:    stw        r9, mem[r0, #0xa9]
  02130:    stw        r6, mem[r0, #0xa5]
  02134:    stw        r7, mem[r0, #0xa6]
  02138:    stw        r4, mem[r0, #0x52]
  0213c:    stw        r5, mem[r0, #0x53]

PKT_0xb0:
  02140:    stw        r5, mem[r0, #0x46]
  02144:    cbz        r14, _PKT_0xf198_0
  02148:    stw        r13, [r0, #0xaa]
  0214c:    stw        r8, [r0, #0xab]
  02150:    stw        r9, [r0, #0xad]
  02154:    stw        r0, [r0, #0xae]
  02158:    ldd        r12, mem[r0, #0x0]
  0215c:    stw        r0, [r0, #0xbd]
  02160:    lsl        r2, r10, #3
  02164:    cbz        r12, _PKT_0xb0_0
  02168:    b          _PKT_0xa0_6  
_PKT_0xb0_0:
  0216c:    ldd        r12, [r0, #0xaf]
  02170:    cbnz       r12, _PKT_0xb1_0
  02174:    sub        r2, r2, #0x1
  02178:    cbnz       r2, _PKT_0xb0_0

PKT_0xf198:
  0217c:    dw         0x84000844  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x844
  02180:    b          _PKT_0xa0_1  
_PKT_0xf198_0:
  02184:    lsr        r6, r11, #6
  02188:    eor        r7, r6, r0
  0218c:    and        r6, r7, #0xfffff001
  02190:    hwop       r8, r6, #0x6
  02194:    cbz        r8, _PKT_0xb1_2
  02198:    ldd        r6, mem[r0, #0x0]
  0219c:    nop
  021a0:    ldd        r12, reg[r0, #0x6c]
  021a4:    and        r12, r12, #0xffd30fff
  021a8:    cbnz       r12, _PKT_0xb1_3
  021ac:    stw        r0, [r0, #0xbd]
  021b0:    ldd        r4, reg[r0, #0x4a64]
  021b4:    lsr        r5, r4, #31

PKT_0xb1:
  021b8:    and        r4, r5, #0xfffff001
  021bc:    cbz        r4, _PKT_0xb1_2
  021c0:    dw         0x84000844  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x844
  021c4:    mov        r2, #0xd9
  021c8:    stw        r2, [r0, #0x50]
  021cc:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
  021d0:    b          _PKT_0xa0_7  
_PKT_0xb1_0:
  021d4:    mov        r2, #0xda
_PKT_0xb1_1:
  021d8:    stw        r2, [r0, #0x50]
  021dc:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
_PKT_0xb1_2:
  021e0:    dw         0x84000844  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x844
  021e4:    dw         0x84000cab  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcab
  021e8:    ldd        r6, reg[r0, #0x4a14]
  021ec:    lsr        r3, r6, #13
  021f0:    and        r4, r3, #0xfffff001
  021f4:    cbz        r4, _PKT_0xb1_2
  021f8:    stw        r0, mem[r0, #0xa2]
  021fc:    stw        r0, [r0, #0x77]
  02200:    stw        r0, [r0, #0xee]
  02204:    stw        r0, [r0, #0x62]
  02208:    stw        r0, [r0, #0x9b]
  0220c:    b          _PKT_0xf0_2  
  02210:    ldd        r12, reg[r0, #0x6c]
  02214:    and        r12, r12, #0xff800fff
  02218:    cbnz       r12, _PKT_0xb1_3
  0221c:    ldd        r12, reg[r0, #0x6c]
  02220:    and        r12, r12, #0xfffffd30
  02224:    cbz        r12, _PKT_0xc0_0
_PKT_0xb1_3:
  02228:    stw        r0, [r0, #0x77]
  0222c:    stw        r0, [r0, #0xee]
  02230:    stw        r0, [r0, #0x9b]

PKT_0xc0:
  02234:    b          _PKT_0x655a_11  
_PKT_0xc0_0:
  02238:    btab

  0223c:    nop
  02240:    lsr        r7, r2, #16
  02244:    and        r7, r7, #0xffffc007
  02248:    lsr        r6, r2, #30
  0224c:    hwop       r5, r1, #0x0
  02250:    hwop       r3, r1, #0x0
  02254:    hwop       r4, r1, #0x0
  02258:    hwop       r10, r1, #0x0
  0225c:    lsl        r9, r10, r6
  02260:    hwop       r10, r9, #0x3
  02264:    mov        r9, #0x1
  02268:    hwop       r11, r9, #0x3
  0226c:    hwop       r10, r10, #0x0
  02270:    and        r8, r6, #0x3
  02274:    ldd        r11, reg[r0, #0x5ba4]
  02278:    and        r9, r11, #0xfffff011
  0227c:    cbz        r9, _PKT_0xc0_1
  02280:    nop
  02284:    ldd        r10, reg[r0, #0xa0]
  02288:    nop
  0228c:    ldd        r5, reg[r0, #0xa4]
  02290:    nop
  02294:    ldd        r3, reg[r0, #0xa8]
_PKT_0xc0_1:
  02298:    stw        r8, mem[r0, #0x43]
  0229c:    stw        r10, mem[r0, #0x44]
  022a0:    stw        r7, mem[r0, #0x47]
  022a4:    stw        r5, mem[r0, #0x45]
  022a8:    stw        r4, mem[r0, #0x48]
  022ac:    stw        r3, mem[r0, #0x46]
  022b0:    std        r5, [r0, #0x81]
  022b4:    b          _PKT_0xf0_2  
  022b8:    hwop       r3, r1, #0x0
  022bc:    hwop       r4, r1, #0x0
  022c0:    hwop       r5, r1, #0x0
  022c4:    hwop       r6, r1, #0x0

PKT_0xc1:
  022c8:    hwop       r7, r1, #0x0
  022cc:    lsld       r8, r6, #32
  022d0:    hwop       r8, r8, #0x20
  022d4:    stw        r2, mem[r0, #0xec]
  022d8:    cbz        r4, _PKT_0xc1_0
  022dc:    std        r3, mem[r0, #0x43]
  022e0:    stw        r7, mem[r0, #0x44]
  022e4:    stw        r0, mem[r0, #0x47]
  022e8:    stw        r5, mem[r0, #0x45]
  022ec:    stw        r0, mem[r0, #0x48]
  022f0:    stw        r6, mem[r0, #0x46]
  022f4:    hwop       r8, r8, #0x20
  022f8:    hwop       r5, r8, #0x0
  022fc:    lsrd       r6, r8, #32
  02300:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  02304:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  02308:    sub        r4, r4, #0x1
  0230c:    b          _PKT_0xb1_1  
_PKT_0xc1_0:
  02310:    ldd        r10, reg[r0, #0x4a14]
  02314:    lsr        r11, r10, #25
  02318:    and        r10, r11, #0xfffff001
  0231c:    cbz        r10, _PKT_0xc1_0
  02320:    stw        r0, mem[r0, #0xec]
  02324:    std        r6, [r0, #0x81]
  02328:    b          _PKT_0xf0_2  
  0232c:    std        r6, [r0, #0x81]
  02330:    b          _PKT_0xf0_2  
  02334:    std        r2, mem[r0, #0x43]
  02338:    hwop       r3, r1, #0x0
  0233c:    hwop       r4, r1, #0x0
  02340:    std        r0, mem[r0, #0x47]
  02344:    stw        r1, mem[r0, #0x49]
  02348:    stw        r1, mem[r0, #0x4a]
  0234c:    hwop       r5, r1, #0x0
  02350:    hwop       r6, r1, #0x0
  02354:    hwop       r7, r1, #0x0
  02358:    hwop       r8, r1, #0x0
  0235c:    hwop       r9, r1, #0x0
_PKT_0xc1_1:
  02360:    add        r10, r9, #0x1
  02364:    lsl        r9, r10, #3
  02368:    ldd        r11, reg[r0, #0x5ba4]
  0236c:    and        r10, r11, #0xfffff011
  02370:    cbz        r10, _PKT_0xc1_3
  02374:    nop
  02378:    ldd        r3, reg[r0, #0xa4]
  0237c:    nop
  02380:    ldd        r4, reg[r0, #0xa8]
  02384:    nop
  02388:    ldd        r5, reg[r0, #0xac]
  0238c:    nop
_PKT_0xc1_2:
  02390:    ldd        r6, reg[r0, #0xb0]
  02394:    nop
  02398:    ldd        r9, reg[r0, #0xa0]
_PKT_0xc1_3:
  0239c:    stw        r5, mem[r0, #0x4b]
  023a0:    stw        r6, mem[r0, #0x4c]
  023a4:    stw        r7, mem[r0, #0x4d]
  023a8:    stw        r9, mem[r0, #0x44]
  023ac:    nop
  023b0:    stw        r3, mem[r0, #0x45]
  023b4:    stw        r8, mem[r0, #0x4e]
  023b8:    std        r1, mem[r0, #0x4f]
  023bc:    stw        r4, mem[r0, #0x46]
  023c0:    std        r10, [r0, #0x81]
  023c4:    b          _PKT_0xf0_2  
  023c8:    std        r0, mem[r0, #0x43]
  023cc:    lsr        r3, r2, #31
  023d0:    hwop       r9, r1, #0x0
  023d4:    hwop       r10, r1, #0x0
  023d8:    hwop       r11, r1, #0x0
  023dc:    hwop       r12, r1, #0x0
  023e0:    hwop       r4, r1, #0x0
  023e4:    hwop       r5, r1, #0x0
  023e8:    hwop       r7, r1, #0x0
  023ec:    add        r8, r7, #0x1
  023f0:    ldd        r13, reg[r0, #0x5ba4]
  023f4:    and        r6, r13, #0xfffff011
  023f8:    cbz        r6, _PKT_0xc1_4
  023fc:    nop
  02400:    ldd        r8, reg[r0, #0xa0]
  02404:    nop
  02408:    ldd        r9, reg[r0, #0xac]
  0240c:    nop
  02410:    ldd        r10, reg[r0, #0xb0]
  02414:    nop
  02418:    ldd        r11, reg[r0, #0xa4]
  0241c:    nop
  02420:    ldd        r12, reg[r0, #0xa8]
_PKT_0xc1_4:
  02424:    stw        r9, mem[r0, #0x52]
  02428:    stw        r10, mem[r0, #0x53]
  0242c:    stw        r11, mem[r0, #0x2c]
  02430:    stw        r12, mem[r0, #0x2d]
  02434:    stw        r0, mem[r0, #0x47]

PKT_0xc3:
  02438:    lsl        r7, r8, #1
  0243c:    stw        r7, mem[r0, #0x2a]
_PKT_0xc3_0:
  02440:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  02444:    ldd        r14, mem[r0, #0x0]
  02448:    cbnz       r3, _PKT_0xc3_1
  0244c:    nop
  02450:    hwop       r14, r14, #0x7
  02454:    b          _PKT_0xc1_1  
  02458:    nop
_PKT_0xc3_1:
  0245c:    hwop       r14, r14, #0x6
  02460:    nop
  02464:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  02468:    stw        r14, mem[r0, #0x2e]
  0246c:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  02470:    ldd        r14, mem[r0, #0x0]
  02474:    nop
  02478:    cbnz       r3, _PKT_0xc3_2
  0247c:    nop
  02480:    hwop       r14, r14, #0x7
  02484:    b          _PKT_0xc1_2  
  02488:    nop
_PKT_0xc3_2:
  0248c:    hwop       r14, r14, #0x6
  02490:    nop
  02494:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
_PKT_0xc3_3:
  02498:    stw        r14, mem[r0, #0x2e]
  0249c:    ldd        r9, reg[r0, #0x49f0]
  024a0:    lsr        r10, r9, #5
  024a4:    and        r11, r10, #0xfffff001
  024a8:    cbz        r11, _PKT_0xc3_4
  024ac:    ldd        r9, reg[r0, #0x24]
  024b0:    nop
  024b4:    and        r10, r9, #0x7fffffff
  024b8:    cbnz       r10, _PKT_0xc3_4
  024bc:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  024c0:    ldd        r9, reg[r0, #0x6c]
  024c4:    nop
  024c8:    and        r10, r9, #0xfffff001
  024cc:    cbz        r10, _PKT_0xc3_4
  024d0:    nop
  024d4:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  024d8:    std        r1, mem[r0, #0x2f]
  024dc:    b          _PKT_0xf0_10  
  024e0:    nop
_PKT_0xc3_4:
  024e4:    sub        r8, r8, #0x1
  024e8:    cbnz       r8, _PKT_0xc3_0
  024ec:    nop
  024f0:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  024f4:    std        r1, mem[r0, #0x2f]
  024f8:    std        r8, [r0, #0x81]
  024fc:    b          _PKT_0xf0_2  
  02500:    nop
_PKT_0xc3_5:
  02504:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02508:    mov        r9, #0x4a14
  0250c:    ldd        r10, reg[r9, #0x0]
  02510:    nop
  02514:    lsr        r9, r10, #13
  02518:    and        r10, r9, #0xfffff001
  0251c:    cbz        r10, _PKT_0xc3_5
  02520:    nop
  02524:    btab

  02528:    ldd        r15, reg[r0, #0x6c]
  0252c:    and        r15, r15, #0xffd30fff
  02530:    cbnz       r15, _PKT_0x6ac7_2
  02534:    btab

  02538:    std        r7, [r0, #0x81]
  0253c:    std        r0, mem[r0, #0x43]
  02540:    lsr        r4, r2, #28
  02544:    and        r4, r4, #0xffffc007
  02548:    lsl        r3, r4, #2
  0254c:    hwop       r9, r1, #0x0
  02550:    hwop       r10, r1, #0x0
  02554:    hwop       r11, r1, #0x0
  02558:    hwop       r12, r1, #0x0
  0255c:    hwop       r4, r1, #0x0
  02560:    lsr        r5, r4, #8
  02564:    and        r4, r4, #0xffffffff
  02568:    hwop       r7, r1, #0x0
  0256c:    lsl        r8, r7, #2
  02570:    stw        r8, reg[r0, #0x4c88]
  02574:    stw        r4, reg[r0, #0x4c80]
  02578:    stw        r5, reg[r0, #0x4c84]
  0257c:    lsld       r14, r10, #32
  02580:    hwop       r10, r14, #0x20
  02584:    lsld       r14, r12, #32
  02588:    hwop       r12, r14, #0x20
  0258c:    lsl        r9, r8, #3
  02590:    hwop       r10, r10, #0x20
  02594:    subd       r11, r10, #0x20
  02598:    hwop       r4, r11, #0x0
  0259c:    lsrd       r5, r11, #32
  025a0:    and        r7, r4, #0x7fffffff
  025a4:    cbz        r7, _PKT_0xc3_6
  025a8:    std        r3, mem[r0, #0x37]
_PKT_0xc3_6:
  025ac:    stw        r4, mem[r0, #0x52]
  025b0:    stw        r5, mem[r0, #0x53]

PKT_0xc2:
  025b4:    nop
  025b8:    nop
  025bc:    ldd        r14, mem[r0, #0x0]
  025c0:    nop
  025c4:    std        r0, mem[r0, #0x37]
  025c8:    dw         0x84000958  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x958
  025cc:    mov        r6, #0x1c
  025d0:    add        r6, r6, r3
  025d4:    add        r6, r6, r7
  025d8:    lsrd       r9, r12, #5
  025dc:    lsld       r13, r9, #5
  025e0:    hwop       r13, r13, #0x20
  025e4:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  025e8:    addd       r11, r11, #0x4
  025ec:    addd       r12, r12, #0x4
  025f0:    hwop       r4, r11, #0x0
  025f4:    lsrd       r5, r11, #32
  025f8:    and        r7, r4, #0x7fffffff
  025fc:    std        r3, mem[r0, #0x37]
  02600:    stw        r4, mem[r0, #0x52]
  02604:    stw        r5, mem[r0, #0x53]
  02608:    nop
  0260c:    nop
  02610:    ldd        r14, mem[r0, #0x0]
  02614:    nop
  02618:    std        r0, mem[r0, #0x37]
  0261c:    dw         0x84000958  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x958
  02620:    mov        r6, #0x1c
  02624:    hwop       r6, r6, #0x0
  02628:    add        r6, r6, r7
  0262c:    lsrd       r9, r12, #5
  02630:    lsld       r13, r9, #5
  02634:    hwop       r13, r13, #0x20
  02638:    dw         0x8400079a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x79a
  0263c:    addd       r11, r11, #0x4
  02640:    addd       r12, r12, #0x4
  02644:    sub        r8, r8, #0x1
  02648:    cbz        r8, _PKT_0xf0_9
  0264c:    and        r7, r8, #0xffffc007
  02650:    cbnz       r7, _PKT_0xc2_0
  02654:    subd       r11, r11, #0x40
_PKT_0xc2_0:
  02658:    b          _PKT_0xc3_3  
  0265c:    nop
  02660:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02664:    ldd        r4, reg[r0, #0x4c88]
  02668:    add        r5, r4, r8
  0266c:    setge      r4, r5, #0x4
  02670:    cbnz       r4, _PKT_0xd0_0
  02674:    ldd        r4, reg[r0, #0x4c80]
  02678:    lsr        r5, r4, #1
  0267c:    stw        r5, reg[r0, #0x4c80]
  02680:    and        r5, r4, #0xfffff001

PKT_0xd0:
  02684:    cbnz       r5, _PKT_0xd0_0
  02688:    mov        r14, #0x0
_PKT_0xd0_0:
  0268c:    setgt      r4, r8, #0x4
  02690:    cbnz       r4, _PKT_0xd1_0
  02694:    ldd        r4, reg[r0, #0x4c84]

PKT_0xd1:
  02698:    lsr        r5, r4, #1
  0269c:    stw        r5, reg[r0, #0x4c84]
  026a0:    and        r5, r4, #0xfffff001
  026a4:    cbnz       r5, _PKT_0xd1_0
  026a8:    mov        r14, #0x0
_PKT_0xd1_0:
  026ac:    btab

  026b0:    nop

PKT_0xd2:
  026b4:    stw        r2, mem[r0, #0x25]
  026b8:    lsr        r4, r2, #23
  026bc:    and        r4, r4, #0xfffff001
  026c0:    hwop       r3, r1, #0x0
  026c4:    hwop       r4, r1, #0x0
  026c8:    hwop       r5, r1, #0x0
  026cc:    hwop       r6, r1, #0x0

PKT_0xe0:
  026d0:    hwop       r7, r1, #0x0
  026d4:    hwop       r8, r1, #0x0
  026d8:    hwop       r14, r1, #0x0
  026dc:    std        r0, mem[r0, #0x43]
  026e0:    stw        r0, mem[r0, #0x47]
  026e4:    stw        r3, mem[r0, #0x52]
  026e8:    stw        r4, mem[r0, #0x53]
  026ec:    stw        r3, mem[r0, #0x2c]
  026f0:    stw        r4, mem[r0, #0x2d]
  026f4:    add        r13, r14, #0x1
  026f8:    lsl        r12, r13, #1
  026fc:    stw        r12, mem[r0, #0x2a]
_PKT_0xe0_0:
  02700:    ldd        r12, mem[r0, #0x0]
  02704:    nop
  02708:    eor        r9, r5, r0
  0270c:    hwop       r9, r9, #0x6
  02710:    hwop       r9, r9, #0x7
  02714:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02718:    stw        r9, mem[r0, #0x2e]
  0271c:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  02720:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  02724:    nop
  02728:    ldd        r12, mem[r0, #0x0]
  0272c:    nop
  02730:    eor        r9, r6, r0
  02734:    hwop       r9, r9, #0x6
  02738:    hwop       r9, r9, #0x7
  0273c:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02740:    stw        r9, mem[r0, #0x2e]
  02744:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  02748:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  0274c:    sub        r13, r13, #0x1
  02750:    cbnz       r13, _PKT_0xe0_0
  02754:    std        r8, [r0, #0x81]
  02758:    std        r1, mem[r0, #0x2f]
  0275c:    b          _PKT_0xf0_2  
  02760:    std        r8, [r0, #0x81]
  02764:    hwop       r2, r1, #0x0
  02768:    hwop       r2, r1, #0x0
  0276c:    hwop       r2, r1, #0x0
  02770:    hwop       r2, r1, #0x0
  02774:    hwop       r2, r1, #0x0
  02778:    hwop       r2, r1, #0x0

PKT_0x100:
  0277c:    hwop       r2, r1, #0x0
  02780:    b          _PKT_0xf0_2  
  02784:    stw        r2, [r0, #0x5d]
_PKT_0x100_0:
  02788:    stw        r1, [r0, #0x5e]
  0278c:    stw        r1, [r0, #0x5f]
  02790:    std        r3, [r0, #0x81]
  02794:    b          _PKT_0xf0_2  
  02798:    std        r4, mem[r0, #0x43]
  0279c:    std        r8, mem[r0, #0x44]

PKT_0x110:
  027a0:    std        r0, mem[r0, #0x61]
  027a4:    stw        r1, mem[r0, #0x45]
  027a8:    stw        r1, mem[r0, #0x46]
  027ac:    std        r3, [r0, #0x81]
_PKT_0x110_0:
  027b0:    b          _PKT_0xf0_2  
  027b4:    std        r4, mem[r0, #0x43]
  027b8:    std        r8, mem[r0, #0x44]
  027bc:    std        r1, mem[r0, #0x61]
  027c0:    stw        r1, mem[r0, #0x45]
  027c4:    stw        r1, mem[r0, #0x46]

PKT_0x111:
  027c8:    std        r3, [r0, #0x81]
  027cc:    b          _PKT_0xf0_2  
  027d0:    and        r6, r0, #0xfffff800
  027d4:    std        r3, [r0, #0x81]
  027d8:    ldd        r12, reg[r0, #0x4a14]
  027dc:    and        r14, r12, #0xfffff810
  027e0:    lsr        r12, r14, #9
  027e4:    eor        r12, r12, r0
  027e8:    ldd        r13, reg[r0, #0x5aa8]
  027ec:    lsr        r14, r13, #31
  027f0:    hwop       r12, r12, #0x7
_PKT_0x111_0:
  027f4:    ldd        r13, reg[r0, #0x68]
  027f8:    and        r14, r13, #0xffffc007
  027fc:    eor        r13, r14, #0x0
  02800:    hwop       r12, r12, #0x6
  02804:    orr        r13, r6, #0x1
  02808:    cbnz       r13, _PKT_0x111_1
  0280c:    orr        r13, r6, #0x3
  02810:    cbnz       r13, _PKT_0x111_2
  02814:    hwop       r10, r1, #0x0
  02818:    hwop       r7, r1, #0x0
_PKT_0x111_1:
  0281c:    cbz        r12, _PKT_0x4_0
_PKT_0x111_2:
  02820:    lsr        r12, r10, #20
  02824:    std        r3, [r0, #0xd3]

PKT_0x1:
  02828:    stw        r12, [r0, #0xd5]
  0282c:    stw        r10, [r0, #0x5b]
  02830:    stw        r7, [r0, #0x5c]
_PKT_0x1_0:
  02834:    nop
  02838:    nop
  0283c:    ldd        r10, reg[r0, #0x4a14]
  02840:    lsr        r12, r10, #14
  02844:    and        r10, r12, #0xfffff001
  02848:    cbz        r10, _PKT_0x1_0
  0284c:    nop

PKT_0x4:
  02850:    cbz        r6, _PKT_0x4_1
  02854:    btab

_PKT_0x4_0:
  02858:    stw        r0, [r0, #0x62]
  0285c:    mov        r2, #0xf7
  02860:    stw        r2, [r0, #0x50]
  02864:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
_PKT_0x4_1:
  02868:    stw        r0, [r0, #0x62]
  0286c:    stw        r0, [r0, #0x7e]
_PKT_0x4_2:
  02870:    ldd        r12, reg[r0, #0x84]
  02874:    cbnz       r12, _PKT_0x4_2
  02878:    b          _PKT_0x0_2  
  0287c:    stw        r1, [r0, #0x155]
  02880:    stw        r1, [r0, #0x156]
  02884:    stw        r1, [r0, #0x157]
  02888:    ldd        r5, [r0, #0x158]
  0288c:    cbz        r5, _NOP_2
  02890:    and        r6, r5, #0xfffff001
  02894:    cbnz       r6, _PKT_0xf0_9
  02898:    dw         0x84000a03  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa03
  0289c:    b          _PKT_0x100_0  
  028a0:    stw        r1, [r0, #0x159]
  028a4:    stw        r1, [r0, #0x15a]
  028a8:    stw        r1, [r0, #0x15b]
  028ac:    stw        r1, [r0, #0x15d]
  028b0:    ldd        r5, [r0, #0x15c]

PKT_0x5:
  028b4:    cbz        r5, _NOP_2
  028b8:    and        r6, r5, #0xfffff001
  028bc:    cbnz       r6, _PKT_0xf0_9
  028c0:    dw         0x84000a03  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa03
  028c4:    b          _PKT_0x110_0  
  028c8:    std        r1, [r0, #0x167]
  028cc:    stw        r1, [r0, #0x159]
  028d0:    stw        r1, [r0, #0x15a]
  028d4:    stw        r1, [r0, #0x15b]
  028d8:    hwop       r3, r1, #0x0
  028dc:    ldd        r5, reg[r0, #0x5a80]
  028e0:    lsr        r6, r5, #24
  028e4:    and        r6, r6, #0xfc007fff
  028e8:    lsl        r5, r6, #24
  028ec:    hwop       r3, r3, #0x7
  028f0:    stw        r3, [r0, #0x15d]
  028f4:    ldd        r5, [r0, #0x15c]
  028f8:    cbz        r5, _NOP_2
  028fc:    and        r6, r5, #0xfffff001
  02900:    cbnz       r6, _PKT_0xf0_9
  02904:    dw         0x84000a03  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa03
  02908:    b          _PKT_0x111_0  
  0290c:    ldd        r6, reg[r0, #0x4a14]
  02910:    lsr        r5, r6, #25
  02914:    and        r6, r5, #0xfffff001
_PKT_0x5_0:
  02918:    cbz        r6, _PKT_0x5_1
  0291c:    nop
  02920:    stw        r0, [r0, #0x62]
_PKT_0x5_1:
  02924:    btab

  02928:    std        r0, [r0, #0x100]
  0292c:    std        r1, [r0, #0x9b]
  02930:    stw        r0, [r0, #0x30]
  02934:    nop
  02938:    nop
  0293c:    stw        r0, [r0, #0x76]
  02940:    nop
  02944:    std        r1, [r0, #0x30]
  02948:    stw        r0, [r0, #0x9b]
  0294c:    b          _PKT_0xf0_2  
  02950:    dw         0x84000a66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa66
  02954:    dw         0x84000a6e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa6e
  02958:    dw         0x84000a78  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa78
  0295c:    hwop       r3, r1, #0x0
  02960:    hwop       r3, r1, #0x0
  02964:    hwop       r3, r1, #0x0
  02968:    mov        r3, #0x1
  0296c:    stw        r2, [r0, #0x101]
  02970:    stw        r3, [r0, #0x0]
  02974:    stw        r1, [r0, #0x1]
  02978:    stw        r1, [r0, #0xb]
  0297c:    stw        r1, [r0, #0x2]
  02980:    stw        r1, [r0, #0x3]
  02984:    stw        r1, [r0, #0x4]
  02988:    stw        r1, [r0, #0x5]
  0298c:    stw        r0, [r0, #0xff]
  02990:    hwop       r3, r1, #0x0
  02994:    hwop       r3, r1, #0x0
  02998:    hwop       r3, r1, #0x0
  0299c:    hwop       r3, r1, #0x0
  029a0:    dw         0x84000a87  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa87
  029a4:    stw        r1, [r0, #0x109]
  029a8:    stw        r1, [r0, #0x10a]
  029ac:    std        r1, [r0, #0x10d]
  029b0:    b          _PKT_0xf0_0  
  029b4:    dw         0x84000a66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa66
  029b8:    hwop       r3, r1, #0x0
  029bc:    hwop       r3, r1, #0x0
  029c0:    hwop       r4, r1, #0x0
  029c4:    lsld       r10, r4, #32
  029c8:    hwop       r5, r10, #0x20
  029cc:    hwop       r3, r1, #0x0
  029d0:    hwop       r4, r1, #0x0
  029d4:    lsld       r10, r4, #32
  029d8:    hwop       r6, r10, #0x20
  029dc:    hwop       r3, r1, #0x0
  029e0:    hwop       r4, r1, #0x0
  029e4:    lsld       r10, r4, #32
  029e8:    hwop       r7, r10, #0x20
  029ec:    hwop       r3, r1, #0x0
  029f0:    hwop       r4, r1, #0x0
  029f4:    lsld       r10, r4, #32
  029f8:    hwop       r8, r10, #0x20
  029fc:    hwop       r3, r1, #0x0
  02a00:    hwop       r4, r1, #0x0
  02a04:    lsld       r10, r4, #32
  02a08:    hwop       r9, r10, #0x20
  02a0c:    hwop       r3, r1, #0x0
  02a10:    hwop       r3, r1, #0x0
  02a14:    mov        r11, #0x1
  02a18:    hwop       r10, r5, #0x20
  02a1c:    dw         0x84000a5c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5c
  02a20:    cbz        r11, _PKT_0x5_2
  02a24:    hwop       r10, r6, #0x20
  02a28:    dw         0x84000a5c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5c
  02a2c:    cbz        r11, _PKT_0x5_2
  02a30:    hwop       r10, r7, #0x20
  02a34:    dw         0x84000a5c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5c
  02a38:    cbz        r11, _PKT_0x5_2
  02a3c:    hwop       r10, r8, #0x20
  02a40:    dw         0x84000a5c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5c
  02a44:    cbz        r11, _PKT_0x5_2
  02a48:    hwop       r10, r9, #0x20
  02a4c:    dw         0x84000a5c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa5c
  02a50:    cbz        r11, _PKT_0x5_2
  02a54:    b          _PKT_0x5_0  
_PKT_0x5_2:
  02a58:    dw         0x84000a6e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa6e
  02a5c:    dw         0x84000a78  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa78
  02a60:    stw        r1, [r0, #0x109]
  02a64:    stw        r1, [r0, #0x10a]
  02a68:    std        r1, [r0, #0x10d]
  02a6c:    b          _PKT_0xf0_2  
  02a70:    cbz        r10, _PKT_0xe1a3_0
  02a74:    hwop       r3, r10, #0x0
  02a78:    lsrd       r4, r10, #32
  02a7c:    stw        r3, mem[r0, #0x52]
  02a80:    stw        r4, mem[r0, #0x53]
  02a84:    nop
  02a88:    mov        r10, #0x10

PKT_0xe1a3:
  02a8c:    stw        r10, mem[r0, #0x22]
  02a90:    ldd        r11, mem[r0, #0x0]
_PKT_0xe1a3_0:
  02a94:    btab

_PKT_0xe1a3_1:
  02a98:    std        r2, [r0, #0x104]
  02a9c:    lsr        r3, r2, #8
  02aa0:    cbz        r3, _PKT_0xe1a3_2
  02aa4:    ldd        r6, reg[r0, #0x4a14]
  02aa8:    lsr        r3, r6, #25
  02aac:    and        r4, r3, #0xfffff001
  02ab0:    cbz        r4, _PKT_0xe1a3_1
_PKT_0xe1a3_2:
  02ab4:    btab

  02ab8:    lsr        r3, r2, #9
  02abc:    and        r4, r3, #0xffffc007
  02ac0:    orr        r3, r4, #0x2
  02ac4:    cbz        r3, _PKT_0xe1a3_4
_PKT_0xe1a3_3:
  02ac8:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02acc:    ldd        r6, reg[r0, #0x4a14]
  02ad0:    lsr        r3, r6, #13
  02ad4:    and        r4, r3, #0xfffff001
  02ad8:    cbz        r4, _PKT_0xe1a3_3
_PKT_0xe1a3_4:
  02adc:    btab

  02ae0:    std        r1, mem[r0, #0x103]
  02ae4:    lsr        r3, r2, #11
  02ae8:    and        r4, r3, #0xffffc007
  02aec:    cbz        r4, _PKT_0xe1a3_6
  02af0:    orr        r3, r4, #0x1
  02af4:    cbz        r3, _PKT_0xe1a3_5
  02af8:    mov        r5, #0x11
  02afc:    stw        r5, mem[r0, #0xdd]
_PKT_0xe1a3_5:
  02b00:    orr        r3, r4, #0x2
  02b04:    cbz        r3, _PKT_0xe1a3_6
  02b08:    mov        r5, #0x11
  02b0c:    stw        r5, mem[r0, #0xde]
  02b10:    mov        r5, #0x10
  02b14:    stw        r5, mem[r0, #0x23]
_PKT_0xe1a3_6:
  02b18:    btab

  02b1c:    lsr        r3, r2, #11
  02b20:    and        r4, r3, #0xffffc007
  02b24:    orr        r3, r4, #0x2
  02b28:    cbz        r3, _PKT_0xe1a3_8
_PKT_0xe1a3_7:
  02b2c:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02b30:    ldd        r6, reg[r0, #0x4a14]
  02b34:    lsr        r3, r6, #25
  02b38:    and        r4, r3, #0xfffff001
  02b3c:    cbz        r4, _PKT_0xe1a3_7
_PKT_0xe1a3_8:
  02b40:    btab

  02b44:    ldd        r4, [r0, #0x10b]
  02b48:    nop
  02b4c:    ldd        r5, [r0, #0x10c]
  02b50:    nop
_PKT_0xe1a3_9:
  02b54:    ldd        r6, reg[r0, #0x6c]
  02b58:    and        r3, r6, #0xffd30fff
  02b5c:    cbnz       r3, _PKT_0x6ac7_2
  02b60:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02b64:    ldd        r6, reg[r0, #0x4a14]
  02b68:    lsr        r3, r6, #25
  02b6c:    and        r8, r3, #0xfffff001
  02b70:    cbz        r8, _PKT_0xe1a3_9
  02b74:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  02b78:    std        r5, mem[r0, #0x43]
  02b7c:    mov        r10, #0x10
  02b80:    stw        r10, mem[r0, #0xa7]
  02b84:    std        r0, mem[r0, #0xa1]
  02b88:    std        r0, mem[r0, #0xa2]
  02b8c:    std        r0, mem[r0, #0x47]
  02b90:    mov        r6, #0x1

PKT_0xf0:
  02b94:    stw        r4, mem[r0, #0x45]
_PKT_0xf0_0:
  02b98:    std        r0, mem[r0, #0xa3]
  02b9c:    stw        r6, mem[r0, #0xa5]
  02ba0:    stw        r0, mem[r0, #0xa6]
  02ba4:    stw        r4, mem[r0, #0x52]
  02ba8:    stw        r5, mem[r0, #0x53]
  02bac:    stw        r5, mem[r0, #0x46]
  02bb0:    nop
  02bb4:    ldd        r10, mem[r0, #0x0]
  02bb8:    stw        r0, [r0, #0xbd]
  02bbc:    nop
  02bc0:    dw         0x84000901  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x901
  02bc4:    std        r1, [r0, #0x141]
_PKT_0xf0_1:
  02bc8:    btab

_PKT_0xf0_2:
  02bcc:    ldd        r3, reg[r0, #0x5a8c]
  02bd0:    nop
  02bd4:    ldd        r4, reg[r0, #0x5a80]
  02bd8:    lsr        r7, r4, #1
  02bdc:    and        r4, r7, #0x7fffffff
  02be0:    mov        r5, #0x1
  02be4:    add        r4, r4, #0x2
  02be8:    hwop       r7, r5, #0x23
  02bec:    subd       r4, r7, #0x1
  02bf0:    hwop       r8, r3, #0x26
  02bf4:    ldd        r5, reg[r0, #0x5a84]
  02bf8:    nop
  02bfc:    ldd        r6, reg[r0, #0x5a88]
  02c00:    lsld       r7, r6, #32
  02c04:    hwop       r6, r5, #0x20
  02c08:    lsld       r5, r6, #8
  02c0c:    hwop       r8, r8, #0x20
  02c10:    hwop       r3, r8, #0x0
  02c14:    lsrd       r4, r8, #32
  02c18:    btab

  02c1c:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
_PKT_0xf0_3:
  02c20:    ldd        r10, reg[r0, #0x49f0]
  02c24:    lsr        r6, r10, #1
  02c28:    and        r10, r6, #0xfffff001
  02c2c:    cbnz       r10, _PKT_0xf0_5
  02c30:    ldd        r6, reg[r0, #0x4a14]
  02c34:    nop
_PKT_0xf0_4:
  02c38:    lsr        r3, r6, #13
  02c3c:    and        r6, r3, #0xfffff001
  02c40:    cbz        r6, _PKT_0xf0_3
_PKT_0xf0_5:
  02c44:    std        r1, [r0, #0x100]
  02c48:    std        r1, mem[r0, #0x107]
  02c4c:    std        r1, mem[r0, #0x43]
  02c50:    std        r4, mem[r0, #0x44]
  02c54:    std        r1, [r0, #0x102]
  02c58:    mov        r10, #0x10
  02c5c:    stw        r10, mem[r0, #0x23]
  02c60:    ldd        r3, [r0, #0x10e]
  02c64:    stw        r3, mem[r0, #0x45]
  02c68:    ldd        r4, [r0, #0x142]
  02c6c:    lsr        r5, r4, #8
  02c70:    lsl        r4, r5, #8
  02c74:    add        r5, r4, #0x1
  02c78:    stw        r5, mem[r0, #0x48]
  02c7c:    stw        r0, mem[r0, #0x47]
  02c80:    ldd        r4, [r0, #0x10f]
  02c84:    stw        r4, mem[r0, #0x46]
  02c88:    nop
  02c8c:    std        r1, mem[r0, #0x106]
  02c90:    btab

  02c94:    b          _PKT_0xf0_2  
_PKT_0xf0_6:
  02c98:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02c9c:    ldd        r6, reg[r0, #0x98]
  02ca0:    cbnz       r6, _PKT_0xf0_6
  02ca4:    nop
  02ca8:    ldd        r6, reg[r0, #0x5ba8]
  02cac:    cbz        r6, _PKT_0xf0_9
  02cb0:    std        r0, reg[r0, #0x5ba8]
_PKT_0xf0_7:
  02cb4:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02cb8:    ldd        r4, reg[r0, #0x4a14]
  02cbc:    lsr        r3, r4, #25
  02cc0:    and        r4, r3, #0xfffff001
  02cc4:    cbz        r4, _PKT_0xf0_7
_PKT_0xf0_8:
  02cc8:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
_PKT_0xf0_9:
  02ccc:    ldd        r3, reg[r0, #0xc8]
  02cd0:    cbz        r3, _PKT_0xf0_11
  02cd4:    stw        r0, [r0, #0xc2]
  02cd8:    ldd        r6, [r0, #0xc9]
  02cdc:    cbnz       r6, _PKT_0xf0_12
  02ce0:    stw        r0, [r0, #0xc7]
  02ce4:    and        r4, r3, #0xfffff001
  02ce8:    cbnz       r4, _INDIRECT_BUFFER_END_4
  02cec:    and        r4, r3, #0xffffe003
  02cf0:    cbnz       r4, _DISPATCH_DIRECT_0
  02cf4:    and        r4, r3, #0xffff800f
  02cf8:    cbnz       r4, _SET_BASE_11
  02cfc:    and        r4, r3, #0xfff800ff
  02d00:    cbnz       r4, _DISPATCH_INDIRECT_1
_PKT_0xf0_10:
  02d04:    and        r4, r3, #0xf800ffff
  02d08:    cbnz       r4, _REG_RMW_2
_PKT_0xf0_11:
  02d0c:    ldd        r6, reg[r0, #0x70]
  02d10:    cbz        r6, _PKT_0xf0_12
  02d14:    nop
  02d18:    ldd        r4, reg[r0, #0x4a14]
  02d1c:    and        r10, r4, #0xfffff880
  02d20:    cbz        r10, _PKT_0xf0_12
  02d24:    stw        r0, [r0, #0x105]
  02d28:    b          _PKT_0x0_4  
_PKT_0xf0_12:
  02d2c:    dw         0x84000cab  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcab
  02d30:    dw         0x84001197  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1197
  02d34:    nop
_PKT_0xf0_13:
  02d38:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02d3c:    ldd        r5, reg[r0, #0x6c]
  02d40:    and        r3, r5, #0xffd30fff
  02d44:    cbnz       r3, _PKT_0x6ac7_2
  02d48:    dw         0x8400138b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x138b
  02d4c:    and        r6, r2, #0xffffffff
  02d50:    and        r6, r6, #0x1
  02d54:    cbnz       r6, _PKT_0x655a_1
  02d58:    ldd        r5, reg[r0, #0x49f0]
  02d5c:    lsr        r3, r5, #17
  02d60:    and        r4, r3, #0xfffff001
  02d64:    cbz        r4, _PKT_0x655a_1
  02d68:    mov        r14, #0x0
  02d6c:    ldd        r14, reg[r0, #0x7c]
  02d70:    and        r10, r14, #0xfc007fff
  02d74:    sub        r14, r10, #0x1
  02d78:    cbnz       r14, _PKT_0x655a_1
  02d7c:    ldd        r6, reg[r0, #0x4a14]
  02d80:    lsr        r3, r6, #25
  02d84:    and        r4, r3, #0xfffff001
  02d88:    cbnz       r4, _PKT_0x655a_1
  02d8c:    ldd        r6, reg[r0, #0x5ba4]
  02d90:    and        r4, r6, #0xfffff001
  02d94:    cbz        r4, _PKT_0x655a_1
  02d98:    mov        r12, #0x4a2c
  02d9c:    stw        r12, [r0, #0x6b]
  02da0:    stw        r0, [r0, #0x64]
  02da4:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
_PKT_0xf0_14:
  02da8:    ldd        r6, reg[r12, #0x0]
  02dac:    and        r10, r6, #0xfffff801
  02db0:    cbz        r10, _PKT_0xf0_14
  02db4:    mov        r6, #0x8
_PKT_0xf0_15:
  02db8:    sub        r6, r6, #0x1
  02dbc:    cbnz       r6, _PKT_0xf0_15

PKT_0x655a:
  02dc0:    ldd        r6, reg[r0, #0x6c]
  02dc4:    and        r6, r6, #0xfffffd20
  02dc8:    cbnz       r6, _PKT_0x6ac7_2
  02dcc:    stw        r0, [r0, #0x30]
  02dd0:    nop
  02dd4:    nop
  02dd8:    nop
  02ddc:    nop
  02de0:    nop
  02de4:    nop
  02de8:    stw        r0, [r0, #0x6b]
  02dec:    std        r1, [r0, #0x30]
  02df0:    mov        r14, #0x0
  02df4:    ldd        r14, reg[r0, #0x7c]
_PKT_0x655a_0:
  02df8:    and        r10, r14, #0xfc007fff
  02dfc:    sub        r14, r10, #0x1
  02e00:    cbz        r14, _PKT_0xe9be_55
_PKT_0x655a_1:
  02e04:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  02e08:    ldd        r4, reg[r0, #0x6c]
  02e0c:    nop
  02e10:    and        r6, r4, #0xffffffff
  02e14:    cbz        r6, _PKT_0x655a_9
  02e18:    and        r6, r4, #0xfffff001
  02e1c:    cbz        r6, _PKT_0x655a_2
_PKT_0x655a_2:
  02e20:    and        r6, r2, #0xffffffff
  02e24:    and        r3, r6, #0x1
  02e28:    cbnz       r3, _PKT_0x655a_3
  02e2c:    and        r4, r2, #0xfffff880
  02e30:    cbnz       r4, _PKT_0x655a_9
  02e34:    and        r4, r2, #0xfffffff8
  02e38:    cbnz       r4, _PKT_0x655a_6
  02e3c:    lsr        r3, r2, #25
  02e40:    and        r3, r3, #0xfffff001
  02e44:    cbz        r3, _PKT_0x655a_6
  02e48:    b          _PKT_0x655a_0  
_PKT_0x655a_3:
  02e4c:    and        r3, r6, #0x2
  02e50:    cbnz       r3, _PKT_0x655a_4
  02e54:    lsr        r4, r2, #31
  02e58:    and        r4, r4, #0xfffff001
  02e5c:    cbz        r4, _PKT_0x655a_6
  02e60:    b          _PKT_0x655a_0  
_PKT_0x655a_4:
  02e64:    and        r3, r6, #0xb
  02e68:    cbz        r3, _PKT_0x655a_5
  02e6c:    and        r3, r6, #0xc
  02e70:    cbz        r3, _PKT_0x655a_5
  02e74:    b          _PKT_0x655a_0  
_PKT_0x655a_5:
  02e78:    and        r6, r2, #0xffffffff
  02e7c:    and        r3, r6, #0x10c
  02e80:    cbz        r3, _PKT_0x655a_6
  02e84:    ldd        r4, reg[r0, #0xa0]
  02e88:    lsr        r3, r4, #9
  02e8c:    cbz        r3, _PKT_0x655a_9
_PKT_0x655a_6:
  02e90:    ldd        r5, reg[r0, #0x49f0]
  02e94:    and        r4, r5, #0xfffff809
  02e98:    cbz        r4, _PKT_0x655a_9
  02e9c:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  02ea0:    ldd        r6, reg[r0, #0x6c]
  02ea4:    and        r3, r6, #0xffffc007
  02ea8:    cbz        r3, _PKT_0x655a_9
  02eac:    ldd        r6, reg[r0, #0x4a14]
  02eb0:    lsr        r3, r6, #25
  02eb4:    and        r4, r3, #0xfffff001
  02eb8:    cbz        r4, _PKT_0x655a_7
  02ebc:    b          _PKT_0x6ac7_4  
_PKT_0x655a_7:
  02ec0:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  02ec4:    ldd        r6, reg[r0, #0x6c]
  02ec8:    and        r3, r6, #0xfffff001
  02ecc:    ldd        r6, reg[r0, #0x5ba4]
  02ed0:    and        r4, r6, #0xfffff001
  02ed4:    cbnz       r4, _PKT_0x655a_8
  02ed8:    cbnz       r3, _PKT_0x6ac7_16
  02edc:    b          _PKT_0xf0_4  
_PKT_0x655a_8:
  02ee0:    and        r4, r6, #0xfffff808
  02ee4:    cbz        r4, _PKT_0xf0_13
  02ee8:    b          _PKT_0x6ac7_4  
  02eec:    mov        r2, #0xf0
  02ef0:    stw        r2, [r0, #0x50]
  02ef4:    b          _PKT_0x6ac7_52  
_PKT_0x655a_9:
  02ef8:    dw         0x840012b5  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12b5
  02efc:    ldd        r6, reg[r0, #0x4a14]
  02f00:    lsr        r3, r6, #25
  02f04:    and        r4, r3, #0xfffff001
  02f08:    cbz        r4, _PKT_0xf0_9
  02f0c:    stw        r0, [r0, #0x9b]
  02f10:    std        r0, [r0, #0xee]
_PKT_0x655a_10:
  02f14:    ldd        r10, reg[r0, #0x5b50]
_PKT_0x655a_11:
  02f18:    and        r6, r10, #0xfffff001
  02f1c:    cbz        r6, _PKT_0x655a_15
  02f20:    ldd        r10, reg[r0, #0x4afc]
  02f24:    and        r6, r10, #0xfffff001
  02f28:    cbnz       r6, _PKT_0x655a_13
_PKT_0x655a_12:
  02f2c:    dw         0x84000a91  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xa91
_PKT_0x655a_13:
  02f30:    ldd        r10, reg[r0, #0x4afc]
  02f34:    and        r6, r10, #0xffffe003
  02f38:    cbnz       r6, _PKT_0x655a_14
  02f3c:    dw         0x84000ac7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xac7
  02f40:    ldd        r10, reg[r0, #0x4afc]
  02f44:    and        r6, r10, #0xfffff001
  02f48:    cbz        r6, _PKT_0x655a_12
  02f4c:    ldd        r10, reg[r0, #0x4afc]
  02f50:    and        r6, r10, #0xffffe003
  02f54:    cbz        r6, _PKT_0x655a_13
_PKT_0x655a_14:
  02f58:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  02f5c:    ldd        r6, reg[r0, #0x4a14]
  02f60:    lsr        r3, r6, #25
  02f64:    and        r4, r3, #0xfffff001
  02f68:    cbz        r4, _PKT_0x655a_10
  02f6c:    stw        r0, [r0, #0x77]
_PKT_0x655a_15:
  02f70:    ldd        r3, reg[r0, #0x4a60]
  02f74:    lsr        r3, r3, #16
  02f78:    and        r4, r3, #0xffffffff
  02f7c:    orr        r3, r4, #0x10
  02f80:    cbz        r3, _PKT_0x655a_16
  02f84:    stw        r0, [r0, #0x77]
_PKT_0x655a_16:
  02f88:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  02f8c:    ldd        r4, reg[r0, #0x6c]
  02f90:    and        r3, r4, #0xfffff001
  02f94:    cbz        r3, _PKT_0x655a_17
  02f98:    ldd        r3, reg[r0, #0x4a60]
  02f9c:    lsr        r3, r3, #16
  02fa0:    and        r4, r3, #0xffffffff
  02fa4:    and        r3, r4, #0x103
  02fa8:    cbz        r3, _PKT_0x6ac7_0
  02fac:    and        r3, r4, #0x203
  02fb0:    cbz        r3, _PKT_0x6ac7_0
  02fb4:    and        r3, r4, #0x303
  02fb8:    cbz        r3, _PKT_0x6ac7_0
_PKT_0x655a_17:
  02fbc:    ldd        r3, reg[r0, #0x4a14]

PKT_0x6ac7:
  02fc0:    and        r3, r3, #0xfffff820
  02fc4:    cbnz       r3, _PKT_0x6ac7_0
  02fc8:    stw        r0, [r0, #0x62]
  02fcc:    stw        r0, [r0, #0x105]
  02fd0:    stw        r0, [r0, #0x62]
_PKT_0x6ac7_0:
  02fd4:    stw        r0, [r0, #0x7e]
  02fd8:    ldd        r10, reg[r0, #0x4af0]
  02fdc:    cbz        r10, _PKT_0x6ac7_1
  02fe0:    std        r0, [r0, #0xfd]
  02fe4:    dw         0x840012ba  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ba
  02fe8:    dw         0x840012ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ac
  02fec:    std        r1, [r0, #0xfd]
  02ff0:    dw         0x84000d58  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd58
_PKT_0x6ac7_1:
  02ff4:    ldd        r6, reg[r0, #0x4a14]
  02ff8:    nop
  02ffc:    and        r10, r6, #0xfffff810
  03000:    cbz        r10, _PKT_0x6ac7_2
  03004:    nop
  03008:    ldd        r6, reg[r0, #0x80]
  0300c:    nop
  03010:    cbnz       r6, _PKT_0xe9be_29
  03014:    nop
_PKT_0x6ac7_2:
  03018:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  0301c:    ldd        r6, reg[r0, #0x6c]
  03020:    and        r6, r6, #0xffffffff
  03024:    cbz        r6, _PKT_0x6ac7_20
  03028:    std        r1, [r0, #0x99]
  0302c:    stw        r0, mem[r0, #0xec]
  03030:    dw         0x84000cc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcc0
  03034:    ldd        r6, reg[r0, #0x6c]
  03038:    and        r3, r6, #0xffff800f
  0303c:    cbz        r3, _PKT_0x6ac7_5
  03040:    mov        r2, #0xf2
  03044:    stw        r2, [r0, #0x50]
  03048:    mov        r4, #0x80
_PKT_0x6ac7_3:
  0304c:    sub        r4, r4, #0x1
_PKT_0x6ac7_4:
  03050:    cbnz       r4, _PKT_0x6ac7_3
  03054:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  03058:    std        r0, [r0, #0xcb]
  0305c:    std        r0, [r0, #0xca]
  03060:    mov        r4, #0x4
  03064:    stw        r4, [r0, #0x65]
  03068:    mov        r2, #0xffff
  0306c:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_5:
  03070:    ldd        r6, reg[r0, #0x6c]
  03074:    and        r3, r6, #0xfff800ff
  03078:    cbz        r3, _PKT_0x6ac7_6
  0307c:    mov        r2, #0xdc
  03080:    stw        r2, [r0, #0x50]
  03084:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  03088:    mov        r4, #0x3
  0308c:    stw        r4, [r0, #0x65]
  03090:    mov        r2, #0xffff
  03094:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_6:
  03098:    ldd        r6, reg[r0, #0x6c]
  0309c:    and        r3, r6, #0xfffffa00
  030a0:    cbz        r3, _PKT_0x6ac7_8
_PKT_0x6ac7_7:
  030a4:    mov        r2, #0xe4
  030a8:    stw        r2, [r0, #0x50]
  030ac:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  030b0:    mov        r4, #0x3
  030b4:    stw        r4, [r0, #0x65]
  030b8:    mov        r2, #0xffff
  030bc:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_8:
  030c0:    ldd        r6, reg[r0, #0x6c]
  030c4:    and        r3, r6, #0xfffff820
  030c8:    cbz        r3, _PKT_0x6ac7_11
  030cc:    ldd        r6, reg[r0, #0x49f0]
  030d0:    and        r6, r6, #0xfffff804
  030d4:    cbz        r6, _PKT_0x6ac7_10
  030d8:    mov        r2, #0xdd
_PKT_0x6ac7_9:
  030dc:    stw        r2, [r0, #0x50]
_PKT_0x6ac7_10:
  030e0:    mov        r2, #0xffff
  030e4:    mov        r4, #0x5
  030e8:    stw        r4, [r0, #0x65]
  030ec:    b          _PKT_0x6ac7_7  
_PKT_0x6ac7_11:
  030f0:    ldd        r6, reg[r0, #0x6c]
  030f4:    and        r3, r6, #0xfffffc00
  030f8:    cbz        r3, _PKT_0x6ac7_13
  030fc:    ldd        r6, reg[r0, #0x49f0]
  03100:    and        r6, r6, #0xfffff804
  03104:    cbz        r6, _PKT_0x6ac7_12
  03108:    mov        r2, #0xde
  0310c:    stw        r2, [r0, #0x50]
_PKT_0x6ac7_12:
  03110:    mov        r2, #0xffff
  03114:    mov        r4, #0x5
  03118:    stw        r4, [r0, #0x65]
  0311c:    b          _PKT_0x6ac7_7  
_PKT_0x6ac7_13:
  03120:    ldd        r6, reg[r0, #0x6c]
  03124:    and        r3, r6, #0xfffff900
  03128:    cbz        r3, _PKT_0x6ac7_16
  0312c:    ldd        r6, reg[r0, #0x49f0]
  03130:    and        r6, r6, #0xfffff804
  03134:    cbz        r6, _PKT_0x6ac7_14
  03138:    mov        r2, #0xdf
  0313c:    stw        r2, [r0, #0x50]
_PKT_0x6ac7_14:
  03140:    mov        r2, #0xffff
  03144:    mov        r4, #0x5
_PKT_0x6ac7_15:
  03148:    stw        r4, [r0, #0x65]
  0314c:    b          _PKT_0x6ac7_7  
_PKT_0x6ac7_16:
  03150:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  03154:    ldd        r6, reg[r0, #0x6c]
  03158:    and        r3, r6, #0xfffff001
  0315c:    cbz        r3, _PKT_0x6ac7_17
  03160:    ldd        r6, reg[r0, #0x4ab0]
  03164:    lsr        r3, r6, #21
  03168:    and        r6, r3, #0xfffff001
  0316c:    cbz        r6, _PKT_0x6ac7_17
  03170:    ldd        r14, reg[r0, #0x4af8]
  03174:    lsr        r13, r14, #31
  03178:    and        r14, r14, #0xfffff001
  0317c:    hwop       r13, r14, #0x6
  03180:    cbnz       r13, _PKT_0xe9be_6
  03184:    mov        r2, #0xf0
  03188:    stw        r2, [r0, #0x50]
  0318c:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_17:
  03190:    ldd        r6, reg[r0, #0x6c]
  03194:    and        r3, r6, #0xfffff880
  03198:    cbz        r3, _PKT_0x6ac7_18
  0319c:    std        r1, [r0, #0x95]
  031a0:    b          _PKT_0x6ac7_52  
  031a4:    std        r1, [r0, #0x95]
  031a8:    dw         0x84000d15  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd15
  031ac:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_18:
  031b0:    ldd        r6, reg[r0, #0x6c]
  031b4:    and        r3, r6, #0xffffe003
  031b8:    cbnz       r3, _PKT_0x6ac7_19
  031bc:    stw        r0, [r0, #0x99]
  031c0:    b          _PKT_0x6ac7_9  
_PKT_0x6ac7_19:
  031c4:    ldd        r6, reg[r0, #0x4a14]
  031c8:    lsr        r3, r6, #13
  031cc:    and        r4, r3, #0xfffff001
  031d0:    cbz        r4, _PKT_0xf0_9
  031d4:    mov        r2, #0xcdef
  031d8:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_20:
  031dc:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  031e0:    dw         0x8400137b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x137b
  031e4:    dw         0x84001197  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1197
  031e8:    ldd        r3, reg[r0, #0x5a80]
  031ec:    and        r6, r3, #0xfffff001
  031f0:    cbnz       r6, _PKT_0x6ac7_21
  031f4:    and        r6, r2, #0xffffffff
  031f8:    and        r6, r6, #0x3
  031fc:    cbz        r6, _PKT_0x6ac7_23
  03200:    ldd        r6, reg[r0, #0x4a10]
  03204:    and        r3, r6, #0xffffffff
  03208:    and        r6, r3, #0x3
  0320c:    cbz        r6, _PKT_0x6ac7_23
_PKT_0x6ac7_21:
  03210:    ldd        r3, reg[r0, #0x4bcc]
  03214:    lsr        r6, r3, #16
  03218:    and        r6, r6, #0xfffff001
  0321c:    cbz        r6, _PKT_0x6ac7_22
  03220:    ldd        r3, reg[r0, #0x5b44]
  03224:    lsr        r6, r3, #7
  03228:    and        r6, r6, #0xfffff001
  0322c:    cbz        r6, _PKT_0x6ac7_23
  03230:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  03234:    ldd        r3, reg[r0, #0x5b44]
  03238:    and        r4, r3, #0x7fffffff
  0323c:    stw        r4, reg[r0, #0x5b44]
  03240:    b          _PKT_0x6ac7_15  
_PKT_0x6ac7_22:
  03244:    dw         0x84000d58  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd58
_PKT_0x6ac7_23:
  03248:    ldd        r6, reg[r0, #0x5abc]
  0324c:    cbz        r6, _PKT_0x6ac7_26
  03250:    ldd        r6, reg[r0, #0x5aa8]
  03254:    and        r3, r6, #0xfffff001
  03258:    cbz        r3, _PKT_0x6ac7_25
  0325c:    stw        r0, [r0, #0x9b]
  03260:    stw        r0, [r0, #0x9a]
  03264:    ldd        r3, reg[r0, #0x5ab0]
  03268:    cbz        r3, _PKT_0x6ac7_24
  0326c:    ldd        r4, reg[r0, #0x4a0c]
  03270:    cbnz       r4, _PKT_0x6ac7_24
  03274:    nop
  03278:    stw        r0, [r0, #0x85]
_PKT_0x6ac7_24:
  0327c:    b          _COPY_DATA_6  
_PKT_0x6ac7_25:
  03280:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  03284:    b          _PKT_0x6ac7_9  
_PKT_0x6ac7_26:
  03288:    ldd        r6, reg[r0, #0x4a14]
  0328c:    and        r3, r6, #0xfffff808
  03290:    cbz        r3, _PKT_0x0_1
  03294:    ldd        r3, reg[r0, #0x5a80]
  03298:    nop
  0329c:    and        r6, r3, #0xfffff001
  032a0:    cbnz       r6, _PKT_0x6ac7_27
  032a4:    ldd        r13, reg[r0, #0x5a8c]
  032a8:    ldd        r14, reg[r0, #0x5a94]
  032ac:    seteq      r4, r13, r14
  032b0:    cbz        r4, _PKT_0x6ac7_27
  032b4:    ldd        r6, reg[r0, #0xfc]
  032b8:    cbnz       r6, _PKT_0x753b_6
  032bc:    nop
_PKT_0x6ac7_27:
  032c0:    ldd        r6, reg[r0, #0x5a9c]
  032c4:    and        r4, r6, #0xfffff001
  032c8:    cbz        r4, _PKT_0x6ac7_28
  032cc:    ldd        r6, reg[r0, #0x4a14]
  032d0:    and        r3, r6, #0xfffff840
  032d4:    cbz        r3, _PKT_0xf0_8
_PKT_0x6ac7_28:
  032d8:    ldd        r6, reg[r0, #0x5ac4]
  032dc:    and        r4, r6, #0xfffff804
  032e0:    cbnz       r4, _PKT_0x6ac7_29
  032e4:    ldd        r3, reg[r0, #0x5a80]
  032e8:    and        r6, r3, #0xfffff001
  032ec:    cbz        r6, _PKT_0xf0_8
  032f0:    ldd        r6, reg[r0, #0x4a14]
  032f4:    and        r3, r6, #0xfffff840
  032f8:    cbnz       r3, _PKT_0x6ac7_29
  032fc:    ldd        r3, reg[r0, #0x5b44]
  03300:    orr        r6, r3, #0x1
  03304:    stw        r6, reg[r0, #0x5b44]
  03308:    ldd        r6, reg[r0, #0x5a9c]
  0330c:    nop
  03310:    and        r4, r6, #0xfffff001
  03314:    cbz        r4, _PKT_0x6ac7_29
  03318:    nop
  0331c:    ldd        r6, reg[r0, #0x4a14]
  03320:    and        r3, r6, #0xfffff840
  03324:    cbnz       r3, _PKT_0x6ac7_29
  03328:    ldd        r6, reg[r0, #0x5a9c]
  0332c:    and        r4, r6, #0xfffff001
  03330:    cbnz       r4, _PKT_0xf0_9
  03334:    b          _PKT_0xf0_1  
_PKT_0x6ac7_29:
  03338:    std        r1, [r0, #0xfa]
  0333c:    ldd        r10, reg[r0, #0x5ac4]
  03340:    lsr        r9, r10, #9
  03344:    and        r10, r9, #0xfffff001
  03348:    cbz        r10, _PKT_0x6ac7_30
  0334c:    std        r1, [r0, #0xca]
  03350:    std        r0, [r0, #0xfa]
  03354:    b          _PKT_0xf0_2  
_PKT_0x6ac7_30:
  03358:    std        r1, [r0, #0x9b]
  0335c:    ldd        r6, reg[r0, #0x49f0]
  03360:    lsr        r3, r6, #28
  03364:    and        r3, r3, #0xfffff001
  03368:    ldd        r6, reg[r0, #0x5ac4]
  0336c:    and        r4, r6, #0xfffff804
  03370:    cbz        r3, _PKT_0x6ac7_32
  03374:    mov        r2, #0xf3
  03378:    stw        r2, [r0, #0x50]
  0337c:    dw         0x84001197  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1197
  03380:    std        r0, [r0, #0xca]
_PKT_0x6ac7_31:
  03384:    ldd        r6, reg[r0, #0x68]
  03388:    nop
  0338c:    sub        r3, r6, #0x1
  03390:    cbnz       r3, _PKT_0xe9be_6
  03394:    std        r1, [r0, #0x93]
  03398:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_32:
  0339c:    cbnz       r4, _PKT_0xe9be_6
  033a0:    stw        r0, [r0, #0x9b]
  033a4:    dw         0x84001352  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1352
  033a8:    b          _PKT_0xf0_1  
  033ac:    ldd        r14, reg[r0, #0x4a2c]
_PKT_0x6ac7_33:
  033b0:    and        r14, r14, #0xf800ffff
  033b4:    cbz        r14, _PKT_0x6ac7_37
_PKT_0x6ac7_34:
  033b8:    ldd        r14, reg[r0, #0x4a18]
  033bc:    and        r14, r14, #0xfffff808
  033c0:    cbz        r14, _PKT_0x6ac7_34
  033c4:    stw        r0, [r0, #0x64]
_PKT_0x6ac7_35:
  033c8:    ldd        r14, reg[r0, #0x4a2c]
  033cc:    and        r14, r14, #0xfffff801
  033d0:    cbz        r14, _PKT_0x6ac7_35
  033d4:    ldd        r14, reg[r0, #0x49f0]
  033d8:    lsr        r10, r14, #29
  033dc:    and        r14, r10, #0xfffff001
  033e0:    cbz        r14, _PKT_0x6ac7_36
  033e4:    mov        r2, #0xf5
  033e8:    stw        r2, [r0, #0x50]
  033ec:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
_PKT_0x6ac7_36:
  033f0:    ldd        r14, reg[r0, #0x4a2c]
  033f4:    and        r14, r14, #0xf800ffff
  033f8:    cbnz       r14, _PKT_0x6ac7_36
_PKT_0x6ac7_37:
  033fc:    btab

  03400:    mov        r10, #0x0
  03404:    ldd        r14, reg[r0, #0x6c]
  03408:    nop
  0340c:    and        r10, r14, #0xf800ffff
  03410:    cbz        r10, _PKT_0x6ac7_38
  03414:    mov        r2, #0xf4
  03418:    stw        r2, [r0, #0x50]
  0341c:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
  03420:    stw        r0, [r0, #0x166]
_PKT_0x6ac7_38:
  03424:    btab

_PKT_0x6ac7_39:
  03428:    ldd        r6, reg[r0, #0x4a60]
  0342c:    and        r5, r6, #0xffffc007
  03430:    orr        r6, r5, #0x0
  03434:    cbnz       r6, _PKT_0x6ac7_41
  03438:    orr        r6, r5, #0x1
  0343c:    cbnz       r6, _PKT_0x6ac7_42
_PKT_0x6ac7_40:
  03440:    mov        r15, #0x80
  03444:    dw         0x84000cec  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcec
  03448:    ldd        r14, reg[r0, #0x5b44]
  0344c:    orr        r14, r14, #0x0
  03450:    stw        r14, reg[r0, #0x5b44]
  03454:    btab

_PKT_0x6ac7_41:
  03458:    mov        r15, #0x80
  0345c:    dw         0x84000cec  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcec
  03460:    mov        r10, #0x4614
  03464:    std        r3, [r0, #0xd3]
  03468:    ldd        r14, unk[r10, #0x0]
  0346c:    nop
  03470:    nop
  03474:    lsr        r14, r14, #8
  03478:    and        r14, r14, #0xfffff001
  0347c:    cbnz       r14, _PKT_0x6ac7_40
  03480:    b          _PKT_0x6ac7_30  
_PKT_0x6ac7_42:
  03484:    mov        r15, #0x80
  03488:    dw         0x84000cec  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcec
  0348c:    mov        r10, #0x4614
  03490:    std        r3, [r0, #0xd3]
  03494:    ldd        r14, unk[r10, #0x0]
  03498:    nop
  0349c:    nop
  034a0:    lsr        r14, r14, #9
  034a4:    and        r14, r14, #0xfffff001
  034a8:    cbnz       r14, _PKT_0x6ac7_40
  034ac:    b          _PKT_0x6ac7_31  
  034b0:    cbz        r15, _PKT_0x6ac7_43
  034b4:    sub        r15, r15, #0x1
  034b8:    b          _PKT_0x6ac7_33  
_PKT_0x6ac7_43:
  034bc:    btab

  034c0:    ldd        r14, reg[r0, #0x5b44]
  034c4:    and        r14, r14, #0xffffffff
  034c8:    stw        r14, reg[r0, #0x5b44]
  034cc:    stw        r0, [r0, #0x60]
  034d0:    nop
  034d4:    nop
  034d8:    nop
  034dc:    nop
_PKT_0x6ac7_44:
  034e0:    ldd        r14, reg[r0, #0x4a14]
  034e4:    nop
  034e8:    lsr        r10, r14, #24
  034ec:    and        r6, r10, #0xfffff802
  034f0:    cbz        r6, _PKT_0x6ac7_44
  034f4:    and        r6, r10, #0xffffe003
  034f8:    cbz        r6, _PKT_0x6ac7_45
  034fc:    dw         0x84000d29  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd29
_PKT_0x6ac7_45:
  03500:    dw         0x84000cca  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcca
  03504:    sub        r3, r2, #0xf0
  03508:    cbz        r3, _PKT_0x6ac7_46
  0350c:    sub        r3, r2, #0xf2
  03510:    cbz        r3, _PKT_0x6ac7_46
  03514:    sub        r3, r2, #0xf3
  03518:    cbz        r3, _PKT_0x6ac7_46
  0351c:    b          _PKT_0x6ac7_39  
_PKT_0x6ac7_46:
  03520:    std        r0, [r0, #0xca]
  03524:    std        r0, [r0, #0xcb]
  03528:    dw         0x84000d0d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd0d
  0352c:    btab

  03530:    nop
  03534:    ldd        r6, reg[r0, #0x4a2c]
  03538:    mov        r3, #0x2
  0353c:    eor        r4, r3, r0
  03540:    hwop       r5, r4, #0x6
  03544:    nop
  03548:    stw        r5, reg[r0, #0x4a2c]
  0354c:    nop
  03550:    btab

  03554:    ldd        r14, reg[r0, #0x4ab0]
  03558:    lsr        r13, r14, #25
  0355c:    and        r13, r13, #0xfffff001
  03560:    cbz        r13, _PKT_0x6ac7_47
  03564:    ldd        r14, reg[r0, #0x5a80]
  03568:    lsr        r13, r14, #1
  0356c:    lsl        r14, r13, #1
  03570:    stw        r14, reg[r0, #0x5a80]
_PKT_0x6ac7_47:
  03574:    btab

  03578:    ldd        r14, reg[r0, #0x4a2c]
  0357c:    and        r14, r14, #0xffffe003
  03580:    cbz        r14, _PKT_0x6ac7_48
  03584:    ldd        r15, reg[r0, #0x4a14]
  03588:    lsr        r15, r15, #25
  0358c:    and        r15, r15, #0xfffff001
  03590:    cbz        r15, _PKT_0x6ac7_48
  03594:    mov        r2, #0xf0
  03598:    stw        r2, [r0, #0x50]
  0359c:    b          _PKT_0x6ac7_52  
_PKT_0x6ac7_48:
  035a0:    btab

  035a4:    ldd        r3, reg[r0, #0x4a60]
  035a8:    lsr        r6, r3, #16
  035ac:    and        r6, r6, #0xffffffff
  035b0:    and        r3, r6, #0x1
  035b4:    cbz        r3, _PKT_0x6ac7_49
  035b8:    stw        r0, [r0, #0x77]
_PKT_0x6ac7_49:
  035bc:    btab

  035c0:    ldd        r14, reg[r0, #0x5b44]
  035c4:    orr        r13, r14, #0x2
  035c8:    stw        r13, reg[r0, #0x5b44]
  035cc:    btab

  035d0:    ldd        r14, reg[r0, #0x5b44]
  035d4:    mov        r13, #0x1
  035d8:    lsl        r13, r13, #6
  035dc:    eor        r3, r13, r0
  035e0:    hwop       r4, r14, #0x6
  035e4:    stw        r4, reg[r0, #0x5b44]
  035e8:    btab

  035ec:    stw        r0, [r0, #0x9a]
  035f0:    stw        r0, [r0, #0x9b]
  035f4:    stw        r0, [r0, #0x99]
  035f8:    btab

  035fc:    stw        r0, [r0, #0x69]
_PKT_0x6ac7_50:
  03600:    ldd        r10, reg[r0, #0x4a18]
  03604:    lsr        r6, r10, #16
  03608:    and        r6, r6, #0xfffff001
  0360c:    cbnz       r6, _PKT_0x6ac7_50
  03610:    nop
  03614:    btab

  03618:    stw        r0, [r0, #0x76]
  0361c:    stw        r0, [r0, #0x75]
  03620:    ldd        r6, reg[r0, #0x5abc]
  03624:    cbz        r6, _PKT_0x6ac7_51
  03628:    stw        r0, [r0, #0x42]
  0362c:    stw        r0, [r0, #0x85]
_PKT_0x6ac7_51:
  03630:    std        r0, [r0, #0xed]
  03634:    ldd        r6, reg[r0, #0x5b00]
  03638:    stw        r6, reg[r0, #0x5b00]
  0363c:    ldd        r6, reg[r0, #0x5b08]
  03640:    stw        r6, reg[r0, #0x5b08]
  03644:    ldd        r6, reg[r0, #0x5b0c]
  03648:    stw        r6, reg[r0, #0x5b0c]
  0364c:    ldd        r6, reg[r0, #0x5b10]
_PKT_0x6ac7_52:
  03650:    stw        r6, reg[r0, #0x5b10]
  03654:    ldd        r6, reg[r0, #0x5b14]
  03658:    stw        r6, reg[r0, #0x5b14]
  0365c:    btab

  03660:    ldd        r3, reg[r0, #0x4bcc]
  03664:    lsr        r6, r3, #16
  03668:    and        r6, r6, #0xfffff001
  0366c:    cbz        r6, PKT_0xe9be
  03670:    btab


PKT_0xe9be:
  03674:    ldd        r3, reg[r0, #0x5b44]
  03678:    and        r6, r3, #0xfffff803
  0367c:    and        r6, r6, #0x20
  03680:    cbz        r6, _PKT_0xe9be_0
  03684:    btab

_PKT_0xe9be_0:
  03688:    ldd        r3, reg[r0, #0x5b44]
  0368c:    orr        r4, r3, #0x4
  03690:    stw        r4, reg[r0, #0x5b44]
  03694:    btab

  03698:    mov        r14, #0x0
  0369c:    ldd        r14, reg[r0, #0x7c]
  036a0:    and        r10, r14, #0xfc007fff
  036a4:    cbz        r10, _PKT_0xe9be_1
  036a8:    setne      r14, r10, #0x4
  036ac:    cbnz       r14, _PKT_0xe9be_61
_PKT_0xe9be_1:
  036b0:    btab

  036b4:    ldd        r14, reg[r0, #0x4a2c]
  036b8:    and        r14, r14, #0xffffe003
  036bc:    cbnz       r14, _PKT_0xe9be_2
  036c0:    and        r3, r2, #0xffffffff
  036c4:    and        r6, r3, #0xffff
  036c8:    cbnz       r6, _PKT_0xe9be_3
_PKT_0xe9be_2:
  036cc:    btab

_PKT_0xe9be_3:
  036d0:    ldd        r5, reg[r0, #0x6c]
  036d4:    and        r3, r5, #0xffd20fff
  036d8:    cbnz       r3, _PKT_0x6ac7_2
  036dc:    btab

  036e0:    orr        r6, r2, #0xcdef
  036e4:    cbz        r6, _PKT_0xe9be_4
  036e8:    ldd        r3, reg[r0, #0x4a14]
  036ec:    and        r6, r3, #0xfffff810
  036f0:    cbnz       r6, _PKT_0xe9be_4
  036f4:    ldd        r3, reg[r0, #0x5a8c]
  036f8:    ldd        r6, reg[r0, #0x5a94]
  036fc:    seteq      r5, r3, r6
  03700:    cbz        r5, _PKT_0xe9be_4
  03704:    nop
  03708:    mov        r2, #0xf3
  0370c:    stw        r2, [r0, #0x50]
_PKT_0xe9be_4:
  03710:    btab

  03714:    ldd        r6, reg[r0, #0x4a60]
  03718:    lsr        r7, r6, #16
  0371c:    and        r6, r7, #0xffffffff
  03720:    orr        r7, r6, #0x2
  03724:    cbz        r7, _PKT_0xe9be_5
  03728:    ldd        r6, reg[r0, #0x4a14]
  0372c:    lsr        r7, r6, #25
  03730:    and        r6, r7, #0xfffff001
  03734:    cbz        r6, _PKT_0xe9be_5
  03738:    ldd        r6, reg[r0, #0x5ba4]
  0373c:    mov        r7, #0x101
  03740:    eor        r8, r7, r0
  03744:    hwop       r6, r8, #0x6
  03748:    stw        r6, reg[r0, #0x5ba4]
_PKT_0xe9be_5:
  0374c:    btab

_PKT_0xe9be_6:
  03750:    std        r0, [r0, #0xee]
  03754:    ldd        r3, reg[r0, #0x5b44]
  03758:    and        r6, r3, #0xffffffff
  0375c:    stw        r6, reg[r0, #0x5b44]
_PKT_0xe9be_7:
  03760:    std        r1, [r0, #0x9b]
  03764:    mov        r12, #0x4a2c
  03768:    stw        r12, [r0, #0x6b]
  0376c:    stw        r0, [r0, #0x64]
_PKT_0xe9be_8:
  03770:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  03774:    ldd        r6, reg[r12, #0x0]
  03778:    and        r3, r6, #0xfffff801
  0377c:    cbz        r3, _PKT_0xe9be_8
  03780:    stw        r0, mem[r0, #0xec]
  03784:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  03788:    dw         0x84000d85  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd85
  0378c:    dw         0x84000d78  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd78
  03790:    mov        r3, #0x8
_PKT_0xe9be_9:
  03794:    sub        r3, r3, #0x1
  03798:    cbnz       r3, _PKT_0xe9be_9
  0379c:    stw        r0, [r0, #0x30]
_PKT_0xe9be_10:
  037a0:    ldd        r5, reg[r0, #0x5ac0]
  037a4:    nop
  037a8:    ldd        r6, reg[r0, #0x5ac0]
  037ac:    nop
  037b0:    seteq      r3, r5, r6
  037b4:    cbz        r3, _PKT_0xe9be_10
  037b8:    std        r1, [r0, #0xfa]
  037bc:    nop
  037c0:    nop
  037c4:    stw        r0, [r0, #0x76]
  037c8:    stw        r0, [r0, #0x75]
  037cc:    std        r0, [r0, #0xed]
  037d0:    ldd        r6, reg[r0, #0x5ab0]
  037d4:    stw        r6, reg[r0, #0x4a0c]
  037d8:    ldd        r6, reg[r0, #0x5b00]
  037dc:    stw        r6, reg[r0, #0x5b00]
  037e0:    ldd        r6, reg[r0, #0x5b08]
  037e4:    stw        r6, reg[r0, #0x5b08]
  037e8:    ldd        r6, reg[r0, #0x5b0c]
  037ec:    stw        r6, reg[r0, #0x5b0c]
  037f0:    ldd        r6, reg[r0, #0x5b10]
  037f4:    stw        r6, reg[r0, #0x5b10]
  037f8:    ldd        r6, reg[r0, #0x5b14]
  037fc:    stw        r6, reg[r0, #0x5b14]
  03800:    std        r0, [r0, #0xfa]
  03804:    nop
  03808:    orr        r13, r2, #0xffff
  0380c:    cbnz       r13, _PKT_0xe9be_11
  03810:    ldd        r14, reg[r0, #0x4af8]
  03814:    lsr        r13, r14, #31
  03818:    and        r14, r14, #0xfffff001
  0381c:    hwop       r13, r14, #0x6
  03820:    cbnz       r13, _PKT_0xe9be_12
_PKT_0xe9be_11:
  03824:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
  03828:    nop
_PKT_0xe9be_12:
  0382c:    stw        r0, [r0, #0x6b]
  03830:    std        r1, [r0, #0x30]
  03834:    std        r15, reg[r0, #0x5b44]
  03838:    ldd        r14, reg[r0, #0x4af8]
  0383c:    lsr        r13, r14, #31
  03840:    and        r14, r14, #0xfffff001
_PKT_0xe9be_13:
  03844:    hwop       r13, r14, #0x6
  03848:    cbz        r13, _PKT_0xe9be_16
_PKT_0xe9be_14:
  0384c:    ldd        r14, reg[r0, #0x4a14]
  03850:    lsr        r13, r14, #25
  03854:    and        r14, r13, #0xfffff001
  03858:    cbz        r14, _PKT_0xe9be_14
  0385c:    mov        r13, #0x1
  03860:    lsl        r13, r13, #30
  03864:    ldd        r14, reg[r0, #0x4af8]
  03868:    hwop       r14, r14, #0x7
  0386c:    stw        r14, reg[r0, #0x4af8]
  03870:    mov        r6, #0x100
_PKT_0xe9be_15:
  03874:    ldd        r14, reg[r0, #0x4af8]
  03878:    nop
  0387c:    lsr        r13, r14, #31
  03880:    cbnz       r13, _PKT_0xe9be_15
  03884:    std        r1, [r0, #0x174]
  03888:    std        r1, [r0, #0x175]
  0388c:    std        r1, [r0, #0x176]
  03890:    std        r1, [r0, #0x177]
  03894:    mov        r13, #0x1
  03898:    lsl        r13, r13, #30
  0389c:    eor        r13, r13, r0
  038a0:    hwop       r14, r13, #0x6
  038a4:    stw        r14, reg[r0, #0x4af8]
  038a8:    nop
  038ac:    std        r1, [r0, #0x178]
  038b0:    mov        r13, #0x1
  038b4:    lsl        r13, r13, #8
  038b8:    eor        r13, r13, r0
  038bc:    ldd        r14, reg[r0, #0x49f0]
  038c0:    hwop       r14, r13, #0x6
  038c4:    nop
  038c8:    std        r0, [r0, #0xca]
_PKT_0xe9be_16:
  038cc:    ldd        r6, reg[r0, #0x5a80]
  038d0:    and        r3, r6, #0xfffff001
  038d4:    cbnz       r3, _PKT_0xe9be_17
  038d8:    ldd        r6, reg[r0, #0x5ac4]
  038dc:    and        r3, r6, #0xfffff810
  038e0:    cbz        r3, _PKT_0xe9be_17
_PKT_0xe9be_17:
  038e4:    ldd        r6, reg[r0, #0x4a14]
  038e8:    and        r3, r6, #0xfffff808
  038ec:    cbnz       r3, _PKT_0xe9be_18
  038f0:    ldd        r6, reg[r0, #0x4ab0]
  038f4:    lsr        r4, r6, #25
  038f8:    and        r4, r4, #0xfffff001
  038fc:    cbz        r4, _PKT_0xe9be_21
_PKT_0xe9be_18:
  03900:    ldd        r6, reg[r0, #0x6c]
  03904:    and        r4, r6, #0xffd20fff
  03908:    cbnz       r4, _PKT_0x6ac7_2
  0390c:    and        r4, r6, #0xfffff001
  03910:    cbz        r4, _PKT_0xe9be_19
  03914:    sub        r6, r2, #0xf0
  03918:    cbnz       r6, _PKT_0x6ac7_2
_PKT_0xe9be_19:
  0391c:    stw        r0, [r0, #0x65]
  03920:    ldd        r4, reg[r0, #0x5ac4]
  03924:    orr        r3, r4, #0x8
  03928:    stw        r3, reg[r0, #0x5ac4]
  0392c:    mov        r3, #0x0
_PKT_0xe9be_20:
  03930:    add        r3, r3, #0x1
  03934:    setge      r4, r3, #0x2
  03938:    cbz        r4, _PKT_0xe9be_20
  0393c:    nop
  03940:    std        r1, [r0, #0x95]
_PKT_0xe9be_21:
  03944:    stw        r0, [r0, #0x6b]
  03948:    std        r1, [r0, #0x30]
  0394c:    stw        r0, [r0, #0x93]
  03950:    stw        r0, [r0, #0x99]
  03954:    std        r15, reg[r0, #0x5b44]
  03958:    stw        r0, reg[r0, #0x5ac4]
  0395c:    ldd        r6, reg[r0, #0x7c]
  03960:    and        r5, r6, #0xf800ffff
  03964:    cbnz       r5, _PKT_0xe9be_53
  03968:    ldd        r5, reg[r0, #0x4a2c]
  0396c:    and        r3, r5, #0xf001ffff
  03970:    cbnz       r3, _PKT_0xf0_9
  03974:    nop
  03978:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  0397c:    dw         0x84000cc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcc0
  03980:    dw         0x8400138b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x138b
  03984:    ldd        r10, reg[r0, #0x4af0]
  03988:    cbz        r10, _PKT_0xe9be_22
  0398c:    std        r0, [r0, #0xfd]
  03990:    dw         0x840012ba  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ba
  03994:    dw         0x840012ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ac
  03998:    std        r1, [r0, #0xfd]
_PKT_0xe9be_22:
  0399c:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  039a0:    ldd        r5, reg[r0, #0x5a94]
  039a4:    ldd        r3, reg[r0, #0x5a8c]
  039a8:    seteq      r6, r5, r3
  039ac:    cbz        r6, _PKT_0xe9be_23
  039b0:    ldd        r5, reg[r0, #0x5a9c]
  039b4:    and        r3, r5, #0xffff800f
  039b8:    cbnz       r3, _PKT_0xe9be_23
  039bc:    ldd        r5, reg[r0, #0x5ac4]
  039c0:    and        r3, r5, #0xfffff810
  039c4:    cbnz       r3, _PKT_0xe9be_23
  039c8:    ldd        r13, reg[r0, #0x5a8c]
  039cc:    ldd        r14, reg[r0, #0x5a94]
  039d0:    seteq      r4, r13, r14
  039d4:    cbz        r4, _PKT_0xe9be_23
  039d8:    ldd        r14, reg[r0, #0x6c]
  039dc:    and        r10, r14, #0xf800ffff
  039e0:    cbnz       r10, _PKT_0xe9be_21
  039e4:    ldd        r6, reg[r0, #0xfc]
  039e8:    cbnz       r6, _PKT_0x753b_6
_PKT_0xe9be_23:
  039ec:    ldd        r6, reg[r0, #0x5aa8]
  039f0:    and        r3, r6, #0xfffff001
  039f4:    cbz        r3, _PKT_0xe9be_24
  039f8:    ldd        r4, reg[r0, #0x5abc]
  039fc:    cbz        r4, _PKT_0xe9be_24
  03a00:    and        r3, r6, #0xfffff808
  03a04:    cbnz       r3, _PKT_0xe9be_24
  03a08:    ldd        r4, reg[r0, #0x5ac4]
  03a0c:    and        r3, r4, #0xfffff810
  03a10:    cbz        r3, _PKT_0xe9be_24
  03a14:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  03a18:    b          _PKT_0xf0_2  
_PKT_0xe9be_24:
  03a1c:    ldd        r4, reg[r0, #0x5a80]
  03a20:    and        r3, r4, #0xfffff001
  03a24:    cbz        r3, _PKT_0xe9be_21
  03a28:    mov        r2, #0x0
  03a2c:    dw         0x84000d29  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd29
  03a30:    stw        r0, [r0, #0x9b]
_PKT_0xe9be_25:
  03a34:    stw        r0, [r0, #0x85]
  03a38:    stw        r0, [r0, #0x9a]
  03a3c:    stw        r0, [r0, #0x99]
  03a40:    ldd        r6, reg[r0, #0x4ab0]
  03a44:    lsr        r4, r6, #25
  03a48:    and        r4, r4, #0xfffff001
  03a4c:    cbnz       r4, _PKT_0xe9be_26
  03a50:    std        r1, [r0, #0xf2]
  03a54:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  03a58:    b          _PKT_0xf0_2  
_PKT_0xe9be_26:
  03a5c:    ldd        r6, reg[r0, #0x5abc]
  03a60:    cbz        r6, _PKT_0xe9be_27
  03a64:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  03a68:    b          _COPY_DATA_6  
_PKT_0xe9be_27:
  03a6c:    ldd        r6, reg[r0, #0x4a14]
  03a70:    and        r3, r6, #0xffff800f
  03a74:    cbnz       r3, _PKT_0xe9be_28
  03a78:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  03a7c:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  03a80:    b          _PKT_0x0_0  
_PKT_0xe9be_28:
  03a84:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  03a88:    ldd        r6, reg[r0, #0x6c]
  03a8c:    and        r3, r6, #0x7fffffff
  03a90:    cbnz       r3, _PKT_0x6ac7_2
  03a94:    ldd        r5, reg[r0, #0x5ac4]
  03a98:    and        r6, r5, #0xfffff804
  03a9c:    cbnz       r6, _PKT_0xe9be_6
  03aa0:    dw         0x84001352  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1352
  03aa4:    b          _PKT_0xe9be_13  
_PKT_0xe9be_29:
  03aa8:    ldd        r3, reg[r0, #0x5b30]
  03aac:    ldd        r4, reg[r0, #0x5b34]
  03ab0:    hwop       r6, r3, #0x7
  03ab4:    cbz        r6, _PKT_0x6ac7_2
  03ab8:    stw        r0, mem[r0, #0xe5]
  03abc:    stw        r0, mem[r0, #0xe6]
  03ac0:    ldd        r6, reg[r0, #0x84]
  03ac4:    cbnz       r6, _PKT_0xe9be_29
  03ac8:    stw        r0, [r0, #0xc7]
  03acc:    ldd        r6, reg[r0, #0x4a14]
  03ad0:    and        r10, r6, #0xfffff810
  03ad4:    cbz        r10, _PKT_0xe9be_32
  03ad8:    stw        r0, [r0, #0x77]
  03adc:    lsld       r6, r4, #32
  03ae0:    hwop       r6, r6, #0x20
  03ae4:    mov        r9, #0x5ab0
  03ae8:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03aec:    mov        r9, #0x5b00
  03af0:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03af4:    mov        r9, #0x5b04
  03af8:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03afc:    mov        r9, #0x5b08
  03b00:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03b04:    mov        r9, #0x5b0c
  03b08:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03b0c:    mov        r9, #0x5b10
  03b10:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03b14:    mov        r9, #0x5b14
  03b18:    dw         0x84000f39  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf39
  03b1c:    ldd        r6, reg[r0, #0x5abc]
  03b20:    ldd        r4, reg[r0, #0xdc]
  03b24:    add        r7, r6, r4
  03b28:    lsl        r5, r4, #2
  03b2c:    stw        r5, reg[r0, #0x5ab0]
  03b30:    stw        r7, reg[r0, #0x5ac0]
_PKT_0xe9be_30:
  03b34:    ldd        r6, reg[r0, #0x6c]
  03b38:    and        r6, r6, #0xffffd30f
  03b3c:    cbnz       r6, _PKT_0x6ac7_2
  03b40:    nop
  03b44:    ldd        r4, reg[r0, #0x5ac0]
  03b48:    cbnz       r4, _PKT_0xe9be_30
  03b4c:    std        r1, [r0, #0x8b]
_PKT_0xe9be_31:
  03b50:    ldd        r6, reg[r0, #0x4a14]
  03b54:    and        r10, r6, #0xfffff810
  03b58:    cbnz       r10, _PKT_0xe9be_31
_PKT_0xe9be_32:
  03b5c:    std        r1, [r0, #0x82]
  03b60:    nop
_PKT_0xe9be_33:
  03b64:    ldd        r4, reg[r0, #0x5ac0]
  03b68:    nop
  03b6c:    cbnz       r4, _PKT_0xe9be_33
  03b70:    ldd        r6, reg[r0, #0x49f0]
  03b74:    lsr        r3, r6, #30
  03b78:    and        r6, r3, #0xfffff001
  03b7c:    cbz        r6, _PKT_0xe9be_34
  03b80:    mov        r2, #0xdb
  03b84:    stw        r2, [r0, #0x50]
  03b88:    dw         0x84000cf0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcf0
_PKT_0xe9be_34:
  03b8c:    std        r0, [r0, #0x83]
  03b90:    stw        r0, reg[r0, #0x5b3c]
  03b94:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  03b98:    nop
  03b9c:    b          _PKT_0x655a_0  
  03ba0:    std        r1, [r0, #0x99]
  03ba4:    std        r1, [r0, #0x9a]
  03ba8:    std        r1, [r0, #0x9b]
  03bac:    hwop       r7, r6, #0x0
  03bb0:    lsrd       r8, r6, #32
  03bb4:    stw        r7, mem[r0, #0x52]
  03bb8:    stw        r8, mem[r0, #0x53]
  03bbc:    nop
  03bc0:    mov        r10, #0x10
  03bc4:    stw        r10, mem[r0, #0x22]
  03bc8:    ldd        r5, mem[r0, #0x0]
  03bcc:    std        r0, [r0, #0x99]
  03bd0:    std        r0, [r0, #0x9a]
  03bd4:    std        r0, [r0, #0x9b]
  03bd8:    ldd        r11, reg[r0, #0x6c]
  03bdc:    and        r11, r11, #0xffd30fff
  03be0:    cbnz       r11, _PKT_0x6ac7_2
  03be4:    stw        r5, reg[r9, #0x0]
  03be8:    addd       r6, r6, #0x4
  03bec:    std        r0, [r0, #0x99]
  03bf0:    btab

  03bf4:    hwop       r7, r6, #0x0
  03bf8:    lsrd       r8, r6, #32
  03bfc:    and        r10, r7, #0x7fffffff
  03c00:    cbnz       r10, _PKT_0xe9be_35
  03c04:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
_PKT_0xe9be_35:
  03c08:    cbz        r10, _PKT_0xe9be_36
  03c0c:    mov        r10, #0x3
_PKT_0xe9be_36:
  03c10:    stw        r10, mem[r0, #0x37]
  03c14:    stw        r7, mem[r0, #0x52]
  03c18:    stw        r8, mem[r0, #0x53]
  03c1c:    nop
  03c20:    nop
  03c24:    ldd        r5, mem[r0, #0x0]
  03c28:    cbz        r10, _PKT_0xe9be_37
  03c2c:    mov        r10, #0x0
  03c30:    stw        r10, mem[r0, #0x37]
_PKT_0xe9be_37:
  03c34:    stw        r5, reg[r9, #0x0]
  03c38:    addd       r6, r6, #0x4
  03c3c:    btab

  03c40:    hwop       r7, r6, #0x0
  03c44:    lsrd       r8, r6, #32
  03c48:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03c4c:    stw        r7, mem[r0, #0x52]
  03c50:    stw        r8, mem[r0, #0x53]
  03c54:    nop
  03c58:    nop
  03c5c:    ldd        r5, mem[r0, #0x0]
  03c60:    nop
  03c64:    nop
  03c68:    lsr        r10, r9, #2
  03c6c:    ldd        r7, reg[r0, #0x4a60]
  03c70:    and        r7, r7, #0xffffc007
  03c74:    cbz        r7, _PKT_0xe9be_38
  03c78:    nop
  03c7c:    nop
  03c80:    add        r10, r10, #0x600
_PKT_0xe9be_38:
  03c84:    std        r3, [r0, #0xd3]
  03c88:    std        r15, [r0, #0xd1]
  03c8c:    stw        r10, [r0, #0x5b]
  03c90:    stw        r5, [r0, #0x5c]
  03c94:    btab

_PKT_0xe9be_39:
  03c98:    hwop       r7, r6, #0x0
  03c9c:    lsrd       r8, r6, #32
  03ca0:    and        r10, r7, #0x7fffffff
  03ca4:    cbnz       r10, _PKT_0xe9be_40
  03ca8:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
_PKT_0xe9be_40:
  03cac:    cbz        r10, _PKT_0xe9be_41
  03cb0:    mov        r10, #0x3
_PKT_0xe9be_41:
  03cb4:    stw        r10, mem[r0, #0x37]
  03cb8:    stw        r7, mem[r0, #0x52]
  03cbc:    stw        r8, mem[r0, #0x53]
  03cc0:    nop
  03cc4:    nop
  03cc8:    ldd        r5, mem[r0, #0x0]
  03ccc:    cbz        r10, _PKT_0xe9be_42
  03cd0:    mov        r10, #0x0
  03cd4:    stw        r10, mem[r0, #0x37]
_PKT_0xe9be_42:
  03cd8:    stw        r0, [r0, #0xd5]
  03cdc:    stw        r9, [r0, #0x5b]
  03ce0:    std        r2, [r0, #0xcd]
  03ce4:    std        r3, [r0, #0xd3]
  03ce8:    stw        r5, [r0, #0x5c]
  03cec:    addd       r6, r6, #0x4
  03cf0:    add        r9, r9, #0x1
_PKT_0xe9be_43:
  03cf4:    nop
  03cf8:    ldd        r10, reg[r0, #0x4a14]
  03cfc:    nop
  03d00:    lsr        r7, r10, #14
  03d04:    and        r10, r7, #0xfffff001
  03d08:    cbz        r10, _PKT_0xe9be_43
  03d0c:    nop
  03d10:    sub        r3, r3, #0x1
  03d14:    cbnz       r3, _PKT_0xe9be_39
  03d18:    nop
  03d1c:    btab

  03d20:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03d24:    hwop       r7, r6, #0x0
  03d28:    lsrd       r8, r6, #32
  03d2c:    stw        r7, mem[r0, #0x52]
  03d30:    stw        r8, mem[r0, #0x53]
  03d34:    nop
  03d38:    nop
  03d3c:    ldd        r5, mem[r0, #0x0]
  03d40:    addd       r6, r6, #0x20
  03d44:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03d48:    dw         0x84000f71  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf71
  03d4c:    btab

  03d50:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  03d54:    nop
  03d58:    ldd        r9, reg[r0, #0x6c]
  03d5c:    and        r9, r9, #0xffd30fff
  03d60:    cbnz       r9, _PKT_0x6ac7_2
  03d64:    hwop       r14, r6, #0x0
  03d68:    lsrd       r9, r6, #32
  03d6c:    std        r1, mem[r0, #0x43]
  03d70:    std        r4, mem[r0, #0x44]
  03d74:    nop
  03d78:    stw        r14, mem[r0, #0x45]
  03d7c:    stw        r0, mem[r0, #0x47]
  03d80:    stw        r5, mem[r0, #0x48]
  03d84:    stw        r9, mem[r0, #0x46]
  03d88:    addd       r6, r6, #0x4
  03d8c:    btab

  03d90:    and        r8, r6, #0x7fffffff
  03d94:    orr        r7, r8, #0x1c
  03d98:    cbz        r7, _PKT_0xe9be_44
  03d9c:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03da0:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  03da4:    nop
_PKT_0xe9be_44:
  03da8:    hwop       r7, r6, #0x0
  03dac:    lsrd       r8, r6, #32
  03db0:    ldd        r5, reg[r9, #0x0]
  03db4:    std        r1, mem[r0, #0x43]
  03db8:    stw        r7, mem[r0, #0x39]
  03dbc:    stw        r5, mem[r0, #0x3b]
  03dc0:    stw        r8, mem[r0, #0x3a]
  03dc4:    and        r8, r6, #0x7fffffff
  03dc8:    orr        r7, r8, #0x1c
  03dcc:    cbz        r7, _PKT_0xe9be_45
  03dd0:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03dd4:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  03dd8:    nop
_PKT_0xe9be_45:
  03ddc:    addd       r6, r6, #0x4
  03de0:    btab

  03de4:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  03de8:    nop
  03dec:    hwop       r7, r6, #0x0
  03df0:    lsrd       r8, r6, #32
  03df4:    ldd        r5, reg[r9, #0x0]
  03df8:    std        r1, mem[r0, #0x43]
  03dfc:    std        r4, mem[r0, #0x44]
  03e00:    mov        r10, #0x10
  03e04:    stw        r10, mem[r0, #0x23]
  03e08:    stw        r7, mem[r0, #0x45]
  03e0c:    stw        r5, mem[r0, #0x48]
  03e10:    stw        r0, mem[r0, #0x47]
  03e14:    stw        r8, mem[r0, #0x46]
  03e18:    addd       r6, r6, #0x4
  03e1c:    btab

_PKT_0xe9be_46:
  03e20:    std        r2, [r0, #0xcd]
  03e24:    std        r3, [r0, #0xd3]
  03e28:    ldd        r5, unk[r9, #0x0]
  03e2c:    nop
  03e30:    nop
  03e34:    and        r8, r6, #0x7fffffff
  03e38:    orr        r7, r8, #0x1c
  03e3c:    cbz        r7, _PKT_0xe9be_47
  03e40:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03e44:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
_PKT_0xe9be_47:
  03e48:    hwop       r7, r6, #0x0
  03e4c:    lsrd       r8, r6, #32
  03e50:    std        r1, mem[r0, #0x43]
  03e54:    stw        r7, mem[r0, #0x39]
  03e58:    stw        r5, mem[r0, #0x3b]
  03e5c:    stw        r8, mem[r0, #0x3a]
  03e60:    and        r8, r6, #0x7fffffff
  03e64:    orr        r7, r8, #0x1c
  03e68:    cbz        r7, _PKT_0xe9be_48
  03e6c:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03e70:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
_PKT_0xe9be_48:
  03e74:    addd       r6, r6, #0x4
  03e78:    add        r9, r9, #0x4
  03e7c:    sub        r3, r3, #0x1
  03e80:    cbnz       r3, _PKT_0xe9be_46
  03e84:    nop
  03e88:    btab

  03e8c:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03e90:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  03e94:    nop
  03e98:    hwop       r7, r6, #0x0
  03e9c:    lsrd       r8, r6, #32
  03ea0:    std        r1, mem[r0, #0x43]
  03ea4:    stw        r7, mem[r0, #0x45]
  03ea8:    stw        r0, mem[r0, #0x47]
  03eac:    stw        r9, mem[r0, #0x26]
  03eb0:    stw        r8, mem[r0, #0x29]
  03eb4:    addd       r6, r6, #0x20
  03eb8:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  03ebc:    dw         0x84000f71  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf71
  03ec0:    btab

_PKT_0xe9be_49:
  03ec4:    nop
  03ec8:    ldd        r14, reg[r0, #0x4a14]
  03ecc:    lsr        r15, r14, #14
  03ed0:    and        r14, r15, #0xfffff001
  03ed4:    cbz        r14, _PKT_0xe9be_49
  03ed8:    btab

  03edc:    ldd        r11, reg[r0, #0x6c]
  03ee0:    and        r10, r11, #0xfffff820
  03ee4:    cbz        r10, _PKT_0xe9be_50
  03ee8:    b          PKT_0x6ac7  
_PKT_0xe9be_50:
  03eec:    btab

_PKT_0xe9be_51:
  03ef0:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  03ef4:    ldd        r10, reg[r0, #0x49f0]
  03ef8:    and        r11, r10, #0xffffe003
  03efc:    cbz        r11, _PKT_0xe9be_52
  03f00:    ldd        r10, reg[r0, #0x4a7c]
  03f04:    lsr        r11, r10, #24
  03f08:    and        r10, r11, #0xfffff001
  03f0c:    cbz        r10, _PKT_0xe9be_51
  03f10:    nop
_PKT_0xe9be_52:
  03f14:    btab

_PKT_0xe9be_53:
  03f18:    ldd        r6, reg[r0, #0x7c]
  03f1c:    and        r6, r6, #0xfc007fff
  03f20:    sub        r5, r6, #0x1
  03f24:    cbz        r5, _PKT_0xe9be_57
  03f28:    sub        r5, r6, #0x2
  03f2c:    cbz        r5, _PKT_0xe9be_65
_PKT_0xe9be_54:
  03f30:    sub        r5, r6, #0x3
  03f34:    cbz        r5, _PKT_0xe9be_80
  03f38:    sub        r5, r6, #0x4
  03f3c:    cbz        r5, _PKT_0xe9be_94
  03f40:    and        r5, r6, #0xf800ffff
  03f44:    cbnz       r5, _PKT_0xe9be_61
  03f48:    b          _PKT_0xf0_2  
_PKT_0xe9be_55:
  03f4c:    ldd        r14, reg[r0, #0x14]
  03f50:    cbz        r14, _PKT_0xe9be_55
  03f54:    mov        r15, #0x1
  03f58:    stw        r15, reg[r0, #0x4acc]
  03f5c:    ldd        r6, reg[r0, #0x84]
  03f60:    cbnz       r6, _PKT_0xe9be_55
  03f64:    ldd        r14, reg[r0, #0x6c]
  03f68:    and        r14, r14, #0xffd20fff
  03f6c:    cbnz       r14, _PKT_0x6ac7_2
  03f70:    dw         0x84001139  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1139
  03f74:    ldd        r6, reg[r0, #0x4a60]
  03f78:    mov        r7, #0x1
  03f7c:    and        r5, r6, #0xffffc007
  03f80:    mov        r10, #0xfb48
  03f84:    cbz        r5, _PKT_0xe9be_56
  03f88:    mov        r10, #0xfb49
_PKT_0xe9be_56:
  03f8c:    stw        r7, [r0, #0xe7]
  03f90:    mov        r15, #0x2
  03f94:    stw        r15, reg[r0, #0x4acc]
  03f98:    std        r1, [r0, #0xdb]
  03f9c:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
_PKT_0xe9be_57:
  03fa0:    std        r1, [r0, #0x99]
  03fa4:    std        r1, [r0, #0x9a]
  03fa8:    std        r1, [r0, #0x9b]
  03fac:    mov        r7, #0xf
  03fb0:    stw        r7, reg[r0, #0x5b44]
_PKT_0xe9be_58:
  03fb4:    ldd        r14, reg[r0, #0x4a14]
  03fb8:    lsr        r10, r14, #25
  03fbc:    and        r14, r10, #0xfffff001
  03fc0:    cbz        r14, _PKT_0xe9be_58
  03fc4:    ldd        r6, reg[r0, #0x7c]
  03fc8:    mov        r5, #0xf
  03fcc:    eor        r5, r5, r0
  03fd0:    hwop       r6, r6, #0x6
  03fd4:    stw        r6, [r0, #0x7a]
  03fd8:    ldd        r6, reg[r0, #0x4a60]
  03fdc:    mov        r7, #0x0
  03fe0:    and        r5, r6, #0xffffc007
  03fe4:    mov        r10, #0xfb48
  03fe8:    cbz        r5, _PKT_0xe9be_59
  03fec:    mov        r10, #0xfb49
_PKT_0xe9be_59:
  03ff0:    stw        r7, [r0, #0xe8]
  03ff4:    mov        r15, #0x3
  03ff8:    stw        r15, reg[r0, #0x4acc]
  03ffc:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
_PKT_0xe9be_60:
  04000:    std        r1, [r0, #0x7b]
  04004:    std        r1, [r0, #0x7d]
  04008:    std        r1, [r0, #0x99]
  0400c:    std        r1, [r0, #0x9a]
  04010:    std        r1, [r0, #0x9b]
  04014:    std        r1, [r0, #0xfd]
  04018:    std        r1, [r0, #0x93]
  0401c:    std        r1, [r0, #0x9d]
  04020:    std        r1, [r0, #0x97]
  04024:    std        r0, mem[r0, #0x43]
  04028:    std        r1, [r0, #0x174]
  0402c:    std        r1, [r0, #0x176]
_PKT_0xe9be_61:
  04030:    ldd        r6, reg[r0, #0x7c]
  04034:    and        r5, r6, #0xfc007fff
  04038:    sub        r6, r5, #0x1
  0403c:    cbz        r6, _PKT_0xe9be_55
  04040:    ldd        r6, reg[r0, #0x7c]
  04044:    and        r5, r6, #0xfc007fff
  04048:    sub        r6, r5, #0x2
  0404c:    cbz        r6, _PKT_0xe9be_63
  04050:    ldd        r6, reg[r0, #0x7c]
  04054:    and        r5, r6, #0xfc007fff
  04058:    sub        r6, r5, #0x3
  0405c:    cbz        r6, _PKT_0xe9be_78
  04060:    ldd        r6, reg[r0, #0x7c]
  04064:    and        r5, r6, #0xfc007fff
  04068:    sub        r6, r5, #0x4
  0406c:    cbz        r6, _PKT_0xe9be_92
  04070:    ldd        r6, reg[r0, #0x7c]
  04074:    and        r5, r6, #0xfc007fff
  04078:    sub        r6, r5, #0x5
  0407c:    cbz        r6, _PKT_0x753b_29
  04080:    ldd        r6, reg[r0, #0x7c]
  04084:    and        r5, r6, #0xf800ffff
  04088:    cbnz       r5, _PKT_0xe9be_61
  0408c:    mov        r5, #0xf
  04090:    stw        r5, reg[r0, #0x5b44]
  04094:    stw        r0, [r0, #0x30]
  04098:    nop
  0409c:    nop
  040a0:    nop
  040a4:    std        r1, [r0, #0x30]
  040a8:    dw         0x84001361  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1361
  040ac:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  040b0:    stw        r0, [r0, #0x9d]
  040b4:    mov        r15, #0x0
  040b8:    stw        r15, reg[r0, #0x4acc]
  040bc:    dw         0x8400116f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x116f
  040c0:    dw         0x84001206  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1206
  040c4:    ldd        r6, reg[r0, #0x5abc]
  040c8:    cbz        r6, _PKT_0xe9be_62
  040cc:    ldd        r6, reg[r0, #0x5aa8]
  040d0:    and        r3, r6, #0xfffff001
  040d4:    cbz        r3, _PKT_0xe9be_62
  040d8:    stw        r0, [r0, #0x42]
_PKT_0xe9be_62:
  040dc:    stw        r0, [r0, #0x9b]
  040e0:    b          _PKT_0xf0_2  
_PKT_0xe9be_63:
  040e4:    mov        r15, #0x10
  040e8:    stw        r15, reg[r0, #0x4acc]
  040ec:    stw        r0, [r0, #0x77]
  040f0:    dw         0x84001138  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1138
  040f4:    ldd        r15, reg[r0, #0x4ad0]
  040f8:    stw        r15, mem[r0, #0xe6]
  040fc:    add        r15, r15, #0x4
  04100:    stw        r15, mem[r0, #0xe5]
  04104:    std        r2, mem[r0, #0x112]
  04108:    std        r2, mem[r0, #0x111]
  0410c:    ldd        r6, reg[r0, #0x4a60]
  04110:    mov        r7, #0x2
  04114:    and        r5, r6, #0xffffc007
  04118:    mov        r10, #0xfb48
  0411c:    cbz        r5, _PKT_0xe9be_64
  04120:    mov        r10, #0xfb49
_PKT_0xe9be_64:
  04124:    stw        r7, [r0, #0xe7]
  04128:    mov        r15, #0x20
  0412c:    stw        r15, reg[r0, #0x4acc]
  04130:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
_PKT_0xe9be_65:
  04134:    mov        r11, #0xf882
  04138:    lsl        r10, r11, #2
  0413c:    ldd        r3, reg[r10, #0x0]
  04140:    mov        r11, #0xf883
  04144:    lsl        r10, r11, #2
  04148:    ldd        r4, reg[r10, #0x0]
  0414c:    lsld       r6, r4, #32
  04150:    hwop       r6, r6, #0x20
  04154:    mov        r11, #0xf88c
  04158:    lsl        r10, r11, #2
  0415c:    ldd        r3, reg[r10, #0x0]
  04160:    mov        r11, #0xf88d
  04164:    lsl        r10, r11, #2
  04168:    ldd        r4, reg[r10, #0x0]
  0416c:    lsld       r2, r4, #32
  04170:    hwop       r2, r2, #0x20
  04174:    mov        r3, #0x40
  04178:    mov        r9, #0x49e8
  0417c:    lsrd       r2, r2, #26
_PKT_0xe9be_66:
  04180:    and        r4, r2, #0xfffff001
  04184:    lsrd       r2, r2, #1
  04188:    cbz        r4, _PKT_0xe9be_67
  0418c:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
_PKT_0xe9be_67:
  04190:    add        r9, r9, #0x4
  04194:    sub        r3, r3, #0x1
  04198:    cbnz       r3, _PKT_0xe9be_66
  0419c:    mov        r11, #0xf88e
  041a0:    lsl        r10, r11, #2
  041a4:    ldd        r3, reg[r10, #0x0]
  041a8:    mov        r11, #0xf88f
  041ac:    lsl        r10, r11, #2
  041b0:    ldd        r4, reg[r10, #0x0]
  041b4:    lsld       r2, r4, #32
  041b8:    hwop       r2, r2, #0x20
  041bc:    mov        r3, #0x40
  041c0:    mov        r9, #0x4a80
_PKT_0xe9be_68:
  041c4:    and        r4, r2, #0xfffff001
  041c8:    lsrd       r2, r2, #1
  041cc:    cbz        r4, _PKT_0xe9be_69
  041d0:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
_PKT_0xe9be_69:
  041d4:    add        r9, r9, #0x4
  041d8:    sub        r3, r3, #0x1
  041dc:    cbnz       r3, _PKT_0xe9be_68
  041e0:    mov        r12, #0x0
_PKT_0xe9be_70:
  041e4:    mov        r11, #0xf888
  041e8:    lsl        r10, r11, #2
  041ec:    ldd        r3, reg[r10, #0x0]
  041f0:    mov        r11, #0xf889
  041f4:    lsl        r10, r11, #2
  041f8:    ldd        r4, reg[r10, #0x0]
  041fc:    lsld       r2, r4, #32
  04200:    hwop       r2, r2, #0x20
  04204:    mov        r3, #0x40
  04208:    mov        r9, #0x4b80
  0420c:    hwop       r9, r9, #0x0
_PKT_0xe9be_71:
  04210:    and        r4, r2, #0xfffff001
  04214:    lsrd       r2, r2, #1
  04218:    cbz        r4, _PKT_0xe9be_72
  0421c:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
_PKT_0xe9be_72:
  04220:    add        r9, r9, #0x4
  04224:    sub        r3, r3, #0x1
  04228:    cbnz       r3, _PKT_0xe9be_71
  0422c:    mov        r11, #0xf88a
  04230:    lsl        r10, r11, #2
  04234:    ldd        r3, reg[r10, #0x0]
  04238:    hwop       r2, r0, #0x20
  0423c:    mov        r3, #0x20
  04240:    mov        r9, #0x4c80
  04244:    hwop       r9, r9, #0x0
_PKT_0xe9be_73:
  04248:    and        r4, r2, #0xfffff001
  0424c:    lsrd       r2, r2, #1
  04250:    cbz        r4, _PKT_0xe9be_74
  04254:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
_PKT_0xe9be_74:
  04258:    add        r9, r9, #0x4
  0425c:    sub        r3, r3, #0x1
  04260:    cbnz       r3, _PKT_0xe9be_73
  04264:    nop
  04268:    add        r12, r12, #0x180
  0426c:    setge      r11, r12, #0xf00
  04270:    cbz        r11, _PKT_0xe9be_70
  04274:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  04278:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  0427c:    std        r1, mem[r0, #0x33]
  04280:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  04284:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  04288:    ldd        r7, reg[r0, #0x4a60]
  0428c:    and        r5, r7, #0xffffc007
  04290:    cbnz       r5, _PKT_0xe9be_75
  04294:    lsrd       r10, r6, #5
  04298:    addd       r10, r10, #0x1
  0429c:    lsld       r6, r10, #5
  042a0:    mov        r3, #0x20
  042a4:    mov        r9, #0x4280
  042a8:    dw         0x84000f48  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf48
  042ac:    mov        r3, #0x5
  042b0:    mov        r9, #0x46a4
  042b4:    dw         0x84000f48  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf48
  042b8:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  042bc:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  042c0:    std        r1, mem[r0, #0x33]
_PKT_0xe9be_75:
  042c4:    dw         0x84001143  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1143
_PKT_0xe9be_76:
  042c8:    ldd        r6, reg[r0, #0x4a14]
  042cc:    lsr        r5, r6, #13
  042d0:    and        r6, r5, #0xfffff001
  042d4:    cbz        r6, _PKT_0xe9be_76
  042d8:    ldd        r6, reg[r0, #0x4a60]
  042dc:    mov        r7, #0x0
  042e0:    and        r5, r6, #0xffffc007
  042e4:    mov        r10, #0xfb48
  042e8:    cbz        r5, _PKT_0xe9be_77
  042ec:    mov        r10, #0xfb49
_PKT_0xe9be_77:
  042f0:    stw        r7, [r0, #0xe9]
  042f4:    mov        r15, #0x30
  042f8:    stw        r15, reg[r0, #0x4acc]
  042fc:    ldd        r6, reg[r0, #0x7c]
  04300:    mov        r5, #0xf
  04304:    eor        r5, r5, r0
  04308:    hwop       r6, r6, #0x6
  0430c:    stw        r6, [r0, #0x7a]
  04310:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  04314:    b          _PKT_0xe9be_54  
_PKT_0xe9be_78:
  04318:    mov        r15, #0x100
  0431c:    stw        r15, reg[r0, #0x4acc]
  04320:    dw         0x84001138  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1138
  04324:    ldd        r15, reg[r0, #0x4ad0]
  04328:    stw        r15, mem[r0, #0xe6]
  0432c:    add        r15, r15, #0x4
  04330:    stw        r15, mem[r0, #0xe5]
  04334:    std        r2, mem[r0, #0x112]
  04338:    std        r2, mem[r0, #0x111]
  0433c:    ldd        r6, reg[r0, #0x4a60]
  04340:    mov        r7, #0x3
  04344:    and        r5, r6, #0xffffc007
  04348:    mov        r10, #0xfb48
  0434c:    cbz        r5, _PKT_0xe9be_79
  04350:    mov        r10, #0xfb49
_PKT_0xe9be_79:
  04354:    mov        r15, #0x200
  04358:    stw        r15, reg[r0, #0x4acc]
  0435c:    stw        r7, [r0, #0xe7]
  04360:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
_PKT_0xe9be_80:
  04364:    mov        r11, #0xf882
  04368:    lsl        r10, r11, #2
  0436c:    ldd        r3, reg[r10, #0x0]
  04370:    mov        r11, #0xf883
  04374:    lsl        r10, r11, #2
  04378:    ldd        r4, reg[r10, #0x0]
  0437c:    lsld       r6, r4, #32
  04380:    hwop       r6, r6, #0x20
  04384:    mov        r11, #0xf88c
  04388:    lsl        r10, r11, #2
  0438c:    ldd        r3, reg[r10, #0x0]
  04390:    mov        r11, #0xf88d
  04394:    lsl        r10, r11, #2
  04398:    ldd        r4, reg[r10, #0x0]
  0439c:    lsld       r2, r4, #32
  043a0:    hwop       r2, r2, #0x20
  043a4:    mov        r3, #0x40
  043a8:    mov        r9, #0x49e8
  043ac:    lsrd       r2, r2, #26
_PKT_0xe9be_81:
  043b0:    and        r4, r2, #0xfffff001
  043b4:    lsrd       r2, r2, #1
  043b8:    cbz        r4, _PKT_0xe9be_82
  043bc:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
_PKT_0xe9be_82:
  043c0:    add        r9, r9, #0x4
  043c4:    sub        r3, r3, #0x1
  043c8:    cbnz       r3, _PKT_0xe9be_81
  043cc:    mov        r11, #0xf88e
  043d0:    lsl        r10, r11, #2
  043d4:    ldd        r3, reg[r10, #0x0]
  043d8:    mov        r11, #0xf88f
  043dc:    lsl        r10, r11, #2
  043e0:    ldd        r4, reg[r10, #0x0]
  043e4:    lsld       r2, r4, #32
  043e8:    hwop       r2, r2, #0x20
  043ec:    mov        r3, #0x40
  043f0:    mov        r9, #0x4a80
_PKT_0xe9be_83:
  043f4:    and        r4, r2, #0xfffff001
  043f8:    lsrd       r2, r2, #1
  043fc:    cbz        r4, _PKT_0xe9be_84
  04400:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
_PKT_0xe9be_84:
  04404:    add        r9, r9, #0x4
  04408:    sub        r3, r3, #0x1
  0440c:    cbnz       r3, _PKT_0xe9be_83
  04410:    mov        r12, #0x0
_PKT_0xe9be_85:
  04414:    mov        r11, #0xf888
  04418:    lsl        r10, r11, #2
  0441c:    ldd        r3, reg[r10, #0x0]
  04420:    mov        r11, #0xf889
  04424:    lsl        r10, r11, #2
  04428:    ldd        r4, reg[r10, #0x0]
  0442c:    lsld       r2, r4, #32
  04430:    hwop       r2, r2, #0x20
  04434:    mov        r3, #0x40
  04438:    mov        r9, #0x4b80
  0443c:    hwop       r9, r9, #0x0
_PKT_0xe9be_86:
  04440:    and        r4, r2, #0xfffff001
  04444:    lsrd       r2, r2, #1
  04448:    cbz        r4, _PKT_0xe9be_87
  0444c:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
_PKT_0xe9be_87:
  04450:    add        r9, r9, #0x4
  04454:    sub        r3, r3, #0x1
  04458:    cbnz       r3, _PKT_0xe9be_86
  0445c:    mov        r11, #0xf88a
  04460:    lsl        r10, r11, #2
  04464:    ldd        r3, reg[r10, #0x0]
  04468:    hwop       r2, r0, #0x20
  0446c:    mov        r3, #0x20
  04470:    mov        r9, #0x4c80
  04474:    hwop       r9, r9, #0x0
_PKT_0xe9be_88:
  04478:    and        r4, r2, #0xfffff001
  0447c:    lsrd       r2, r2, #1
  04480:    cbz        r4, _PKT_0xe9be_89
  04484:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
_PKT_0xe9be_89:
  04488:    add        r9, r9, #0x4
  0448c:    sub        r3, r3, #0x1
  04490:    cbnz       r3, _PKT_0xe9be_88
  04494:    nop
  04498:    add        r12, r12, #0x180
  0449c:    setge      r11, r12, #0xf00
  044a0:    cbz        r11, _PKT_0xe9be_85
  044a4:    ldd        r7, reg[r0, #0x4a60]
  044a8:    and        r5, r7, #0xffffc007
  044ac:    cbnz       r5, _PKT_0xe9be_90
  044b0:    lsrd       r10, r6, #5
  044b4:    addd       r10, r10, #0x1
  044b8:    lsld       r6, r10, #5
  044bc:    mov        r3, #0x20
  044c0:    mov        r9, #0x4280
  044c4:    lsr        r9, r9, #2
  044c8:    dw         0x84000ee6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xee6
  044cc:    mov        r3, #0x5
  044d0:    mov        r9, #0x46a4
  044d4:    lsr        r9, r9, #2
  044d8:    dw         0x84000ee6  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xee6
_PKT_0xe9be_90:
  044dc:    dw         0x8400114e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x114e
  044e0:    ldd        r6, reg[r0, #0x4a60]
  044e4:    mov        r7, #0x0
  044e8:    and        r5, r6, #0xffffc007
  044ec:    mov        r10, #0xfb48
  044f0:    cbz        r5, _PKT_0xe9be_91
  044f4:    mov        r10, #0xfb49
_PKT_0xe9be_91:
  044f8:    mov        r15, #0x300
  044fc:    stw        r15, reg[r0, #0x4acc]
  04500:    stw        r7, [r0, #0xea]
  04504:    ldd        r6, reg[r0, #0x7c]
  04508:    mov        r5, #0xf
  0450c:    eor        r5, r5, r0
  04510:    hwop       r6, r6, #0x6
  04514:    stw        r6, [r0, #0x7a]
  04518:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  0451c:    b          _PKT_0xe9be_54  
_PKT_0xe9be_92:
  04520:    mov        r15, #0x1000
  04524:    stw        r15, reg[r0, #0x4acc]
  04528:    dw         0x84001138  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1138
  0452c:    std        r0, mem[r0, #0xe5]
  04530:    std        r0, mem[r0, #0xe6]
  04534:    std        r1, mem[r0, #0x112]
  04538:    std        r1, mem[r0, #0x111]
  0453c:    stw        r0, [r0, #0x77]
  04540:    ldd        r6, reg[r0, #0x4a60]
  04544:    mov        r7, #0x4
  04548:    and        r5, r6, #0xffffc007
  0454c:    mov        r10, #0xfb48
  04550:    cbz        r5, _PKT_0xe9be_93
  04554:    mov        r10, #0xfb49
_PKT_0xe9be_93:
  04558:    stw        r7, [r0, #0xe7]
  0455c:    mov        r15, #0x2000
  04560:    stw        r15, reg[r0, #0x4acc]
  04564:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
_PKT_0xe9be_94:
  04568:    ldd        r6, reg[r0, #0x4a60]
  0456c:    mov        r7, #0x0
  04570:    and        r5, r6, #0xffffc007
  04574:    mov        r10, #0xfb48
  04578:    cbz        r5, _PKT_0xe9be_95
  0457c:    mov        r10, #0xfb49
_PKT_0xe9be_95:
  04580:    stw        r7, [r0, #0xeb]
  04584:    mov        r15, #0x3000
  04588:    stw        r15, reg[r0, #0x4acc]
  0458c:    ldd        r6, reg[r0, #0x7c]
  04590:    mov        r5, #0xf
  04594:    eor        r5, r5, r0
  04598:    hwop       r6, r6, #0x6
  0459c:    stw        r6, [r0, #0x7a]
  045a0:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  045a4:    stw        r0, [r0, #0x7b]
  045a8:    std        r0, [r0, #0x174]
  045ac:    std        r0, [r0, #0x176]
  045b0:    b          _PKT_0xe9be_54  
_PKT_0xe9be_96:
  045b4:    ldd        r8, reg[r0, #0x4a14]
  045b8:    lsr        r11, r8, #14
  045bc:    and        r8, r11, #0xfffff001
  045c0:    cbz        r8, _PKT_0xe9be_96
  045c4:    stw        r0, [r0, #0xd5]
  045c8:    stw        r10, [r0, #0x5b]
  045cc:    std        r2, [r0, #0xcd]
  045d0:    std        r3, [r0, #0xd3]
  045d4:    stw        r7, [r0, #0x5c]
  045d8:    btab

  045dc:    nop
  045e0:    std        r1, [r0, #0x7b]
  045e4:    std        r1, [r0, #0x9d]
  045e8:    std        r1, [r0, #0x7d]
  045ec:    std        r1, [r0, #0x99]
  045f0:    std        r1, [r0, #0x9a]
  045f4:    std        r1, [r0, #0x9b]
  045f8:    std        r1, [r0, #0xfd]
  045fc:    std        r1, [r0, #0x93]

PKT_0x753b:
  04600:    std        r1, [r0, #0x97]
  04604:    btab

  04608:    nop
  0460c:    stw        r0, reg[r0, #0x4b80]
  04610:    stw        r0, reg[r0, #0x4d00]
  04614:    stw        r0, reg[r0, #0x4e80]
  04618:    stw        r0, reg[r0, #0x5000]
  0461c:    stw        r0, reg[r0, #0x5180]
  04620:    stw        r0, reg[r0, #0x5300]
  04624:    stw        r0, reg[r0, #0x5480]
  04628:    stw        r0, reg[r0, #0x5600]
  0462c:    stw        r0, reg[r0, #0x5780]
  04630:    stw        r0, reg[r0, #0x5900]
  04634:    btab

  04638:    std        r1, reg[r0, #0x4f54]
  0463c:    std        r1, reg[r0, #0x50d4]
  04640:    std        r1, reg[r0, #0x5254]
  04644:    std        r1, reg[r0, #0x53d4]
  04648:    std        r1, reg[r0, #0x5554]
  0464c:    std        r1, reg[r0, #0x56d4]
  04650:    std        r1, reg[r0, #0x5854]
  04654:    std        r1, reg[r0, #0x59d4]
  04658:    stw        r0, reg[r0, #0x4e94]
  0465c:    stw        r0, reg[r0, #0x4e98]
  04660:    stw        r0, reg[r0, #0x5014]
  04664:    stw        r0, reg[r0, #0x5018]
  04668:    stw        r0, reg[r0, #0x5194]
  0466c:    stw        r0, reg[r0, #0x5198]
  04670:    stw        r0, reg[r0, #0x5314]
  04674:    stw        r0, reg[r0, #0x5318]
  04678:    stw        r0, reg[r0, #0x5494]
  0467c:    stw        r0, reg[r0, #0x5498]
  04680:    stw        r0, reg[r0, #0x5614]
  04684:    stw        r0, reg[r0, #0x5618]
  04688:    stw        r0, reg[r0, #0x5794]
  0468c:    stw        r0, reg[r0, #0x5798]
  04690:    stw        r0, reg[r0, #0x5914]
  04694:    stw        r0, reg[r0, #0x5918]
  04698:    std        r0, reg[r0, #0x4f54]
  0469c:    std        r0, reg[r0, #0x50d4]
  046a0:    std        r0, reg[r0, #0x5254]
  046a4:    std        r0, reg[r0, #0x53d4]
  046a8:    std        r0, reg[r0, #0x5554]
  046ac:    std        r0, reg[r0, #0x56d4]
  046b0:    std        r0, reg[r0, #0x5854]
  046b4:    std        r0, reg[r0, #0x59d4]
  046b8:    btab

  046bc:    mov        r14, #0x0
  046c0:    mov        r10, #0x0
_PKT_0x753b_0:
  046c4:    ldd        r5, reg[r14, #0x4b80]
  046c8:    and        r6, r5, #0xfffff001
  046cc:    cbz        r6, _PKT_0x753b_1
  046d0:    ldd        r8, reg[r14, #0x4b9c]
  046d4:    and        r9, r8, #0xffff800f
  046d8:    cbz        r9, _PKT_0x753b_1
  046dc:    ldd        r7, reg[r0, #0xbc]
  046e0:    cbnz       r7, _PKT_0x753b_0
  046e4:    dw         0x84001180  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1180
_PKT_0x753b_1:
  046e8:    add        r14, r14, #0x180
  046ec:    add        r10, r10, #0x1
  046f0:    and        r6, r10, #0xa
  046f4:    cbnz       r6, _PKT_0x753b_0
  046f8:    dw         0x840012ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ac
  046fc:    btab

_PKT_0x753b_2:
  04700:    ldd        r6, reg[r0, #0x6c]
  04704:    and        r6, r6, #0xffa61fff
  04708:    cbnz       r6, _PKT_0x6ac7_2
  0470c:    ldd        r6, reg[r0, #0xb8]
  04710:    cbnz       r6, _PKT_0x753b_2
  04714:    nop
  04718:    stw        r10, mem[r0, #0xb7]
  0471c:    ldd        r11, reg[r14, #0x4c4c]
  04720:    stw        r11, mem[r0, #0xb1]
  04724:    ldd        r11, reg[r14, #0x4c48]
  04728:    stw        r11, mem[r0, #0xb2]
  0472c:    ldd        r11, reg[r14, #0x4b9c]
  04730:    lsr        r12, r11, #1
  04734:    and        r13, r12, #0xfffff001
  04738:    stw        r13, mem[r0, #0xb4]
  0473c:    ldd        r11, reg[r14, #0x4b80]
  04740:    lsr        r12, r11, #23
  04744:    and        r13, r12, #0xfffff001
  04748:    stw        r13, mem[r0, #0xb5]
  0474c:    lsr        r12, r11, #24
  04750:    and        r13, r12, #0xfc007fff
  04754:    stw        r13, mem[r0, #0xb6]
  04758:    btab

  0475c:    mov        r10, #0xf887
  04760:    lsl        r14, r10, #2
  04764:    ldd        r10, reg[r14, #0x0]
  04768:    cbz        r10, _PKT_0x753b_3
  0476c:    std        r1, [r0, #0xfa]
  04770:    ldd        r10, reg[r0, #0xe4]
  04774:    cbz        r10, _PKT_0x753b_3
  04778:    ldd        r7, reg[r0, #0xe0]
  0477c:    ldd        r10, reg[r0, #0x20]
  04780:    stw        r0, [r0, #0xe1]
  04784:    seteq      r14, r7, r10
  04788:    cbnz       r14, _PKT_0x753b_3
  0478c:    stw        r7, [r0, #0x21]
  04790:    dw         0x840011a7  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11a7
_PKT_0x753b_3:
  04794:    std        r0, [r0, #0xfa]
  04798:    btab

  0479c:    ldd        r6, reg[r0, #0x4a60]
  047a0:    and        r5, r6, #0xffffc007
  047a4:    mov        r10, #0xfb50
  047a8:    cbz        r5, _PKT_0x753b_4
  047ac:    mov        r10, #0xfb51
_PKT_0x753b_4:
  047b0:    ldd        r8, reg[r0, #0x4a14]
  047b4:    lsr        r11, r8, #14
  047b8:    and        r8, r11, #0xfffff001
  047bc:    cbz        r8, _PKT_0x753b_4
  047c0:    stw        r0, [r0, #0xd5]
  047c4:    stw        r10, [r0, #0x5b]
  047c8:    std        r2, [r0, #0xcd]
  047cc:    std        r3, [r0, #0xd3]
  047d0:    stw        r7, [r0, #0x5c]
  047d4:    dw         0x84000f71  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf71
  047d8:    ldd        r6, reg[r0, #0x4a14]
  047dc:    and        r10, r6, #0xfffff808
  047e0:    cbz        r10, _PKT_0x753b_5
  047e4:    ldd        r6, reg[r0, #0x5a80]
  047e8:    and        r10, r6, #0xfffff001
  047ec:    cbnz       r10, _PKT_0x753b_5
  047f0:    ldd        r6, reg[r0, #0x5a9c]
  047f4:    and        r10, r6, #0xfffff001
  047f8:    cbz        r10, _PKT_0x753b_5
  047fc:    stw        r0, mem[r0, #0xf5]
_PKT_0x753b_5:
  04800:    btab

_PKT_0x753b_6:
  04804:    dw         0x84000d29  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd29
  04808:    std        r1, [r0, #0x9b]
  0480c:    std        r1, [r0, #0x9a]
  04810:    stw        r0, [r0, #0x99]
  04814:    std        r15, reg[r0, #0x5b44]
_PKT_0x753b_7:
  04818:    ldd        r10, reg[r0, #0x4af0]
  0481c:    cbz        r10, _PKT_0x753b_8
  04820:    std        r0, [r0, #0xfd]
  04824:    dw         0x840012ba  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ba
  04828:    dw         0x840012ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ac
  0482c:    std        r1, [r0, #0xfd]
_PKT_0x753b_8:
  04830:    dw         0x84001352  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1352
  04834:    mov        r4, #0xf886
  04838:    lsl        r10, r4, #2
  0483c:    ldd        r4, reg[r10, #0x0]
  04840:    cbnz       r4, _PKT_0x753b_9
  04844:    dw         0x84001197  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1197
_PKT_0x753b_9:
  04848:    dw         0x84000d66  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd66
  0484c:    dw         0x84000cc0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xcc0
  04850:    dw         0x84001395  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1395
  04854:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  04858:    ldd        r6, reg[r0, #0x6c]
  0485c:    and        r6, r6, #0xffa61fff
  04860:    cbnz       r6, _PKT_0x6ac7_2
  04864:    ldd        r6, reg[r0, #0xf4]
  04868:    cbnz       r6, _PKT_0x753b_7
  0486c:    ldd        r10, reg[r0, #0x5b50]
  04870:    and        r6, r10, #0xfffff001
  04874:    cbz        r6, _PKT_0x753b_10
  04878:    mov        r10, #0x2
  0487c:    stw        r10, [r0, #0x104]
_PKT_0x753b_10:
  04880:    mov        r6, #0xf
_PKT_0x753b_11:
  04884:    sub        r6, r6, #0x1
  04888:    cbnz       r6, _PKT_0x753b_11
  0488c:    stw        r0, [r0, #0x85]
  04890:    ldd        r5, reg[r0, #0x4a14]
  04894:    and        r6, r5, #0xffff800f
  04898:    cbnz       r6, _PKT_0x753b_12
  0489c:    dw         0x84000d3f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3f
  048a0:    dw         0x84000d3b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3b
  048a4:    ldd        r6, reg[r0, #0x5abc]
  048a8:    cbz        r6, _PKT_0xf0_9
  048ac:    stw        r0, [r0, #0x42]
  048b0:    b          _PKT_0xf0_2  
_PKT_0x753b_12:
  048b4:    dw         0x84000d1e  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd1e
  048b8:    ldd        r6, reg[r0, #0x6c]
  048bc:    and        r6, r6, #0xffa61fff
  048c0:    cbnz       r6, _PKT_0x6ac7_2
  048c4:    ldd        r5, reg[r0, #0x5ac4]
  048c8:    and        r6, r5, #0xfffff804
  048cc:    cbnz       r6, _PKT_0xe9be_17
  048d0:    dw         0x84000d3b  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd3b
  048d4:    ldd        r6, reg[r0, #0x5abc]
  048d8:    cbz        r6, _PKT_0xf0_9
  048dc:    stw        r0, [r0, #0x42]
  048e0:    b          _PKT_0xf0_2  
  048e4:    hwop       r7, r6, #0x0
  048e8:    lsrd       r8, r6, #32
  048ec:    stw        r7, mem[r0, #0x52]
  048f0:    stw        r8, mem[r0, #0x53]
  048f4:    nop
  048f8:    nop
  048fc:    ldd        r5, mem[r0, #0x0]
  04900:    nop
  04904:    nop
  04908:    lsl        r9, r9, #2
  0490c:    stw        r5, reg[r9, #0x0]
  04910:    addd       r6, r6, #0x4
  04914:    btab

  04918:    std        r1, [r0, #0x9b]
  0491c:    mov        r12, #0x4a2c
  04920:    stw        r12, [r0, #0x6b]
  04924:    stw        r0, [r0, #0x64]
_PKT_0x753b_13:
  04928:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  0492c:    ldd        r6, reg[r12, #0x0]
  04930:    and        r3, r6, #0xfffff801
  04934:    cbz        r3, _PKT_0x753b_13
  04938:    stw        r0, [r0, #0x30]
  0493c:    dw         0x84000d6d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xd6d
  04940:    stw        r0, [r0, #0x76]
  04944:    stw        r0, [r0, #0x6b]
  04948:    std        r1, [r0, #0x30]
  0494c:    btab

_PKT_0x753b_14:
  04950:    std        r1, [r0, #0xfa]
  04954:    ldd        r6, reg[r0, #0x49ec]
  04958:    mov        r5, #0xf
  0495c:    lsl        r7, r5, #28
  04960:    hwop       r6, r6, #0x7
  04964:    stw        r6, reg[r0, #0x49ec]
  04968:    std        r0, [r0, #0xfa]
  0496c:    dw         0x84001206  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1206
  04970:    dw         0x8400113a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x113a
  04974:    lsl        r3, r4, #16
  04978:    hwop       r4, r3, #0x7
  0497c:    stw        r4, reg[r0, #0x49d8]
  04980:    ldd        r6, reg[r0, #0x4a60]
  04984:    mov        r7, #0x6
  04988:    and        r5, r6, #0xffffc007
  0498c:    mov        r10, #0xfb48
  04990:    cbz        r5, _PKT_0x753b_15
  04994:    mov        r10, #0xfb49
_PKT_0x753b_15:
  04998:    stw        r7, [r0, #0xe7]
  0499c:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  049a0:    std        r7, mem[r0, #0xe5]
  049a4:    std        r3, mem[r0, #0xe6]
  049a8:    std        r2, mem[r0, #0x112]
  049ac:    std        r2, mem[r0, #0x111]
  049b0:    std        r1, [r0, #0x174]
  049b4:    std        r1, [r0, #0x176]
  049b8:    mov        r11, #0xf882
  049bc:    lsl        r10, r11, #2
  049c0:    ldd        r7, reg[r10, #0x0]
  049c4:    mov        r11, #0xf883
  049c8:    lsl        r10, r11, #2
  049cc:    ldd        r8, reg[r10, #0x0]
  049d0:    lsld       r6, r8, #32
  049d4:    hwop       r6, r6, #0x20
  049d8:    mov        r9, #0xf887
  049dc:    dw         0x840011f9  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11f9
  049e0:    mov        r9, #0xf884
  049e4:    dw         0x840011f9  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x11f9
  049e8:    mov        r9, #0x49e8
  049ec:    mov        r10, #0x4a74
  049f0:    add        r10, r10, r9
  049f4:    lsr        r11, r10, #2
  049f8:    add        r4, r11, #0x1
_PKT_0x753b_16:
  049fc:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
  04a00:    add        r9, r9, #0x4
  04a04:    sub        r4, r4, #0x1
  04a08:    cbnz       r4, _PKT_0x753b_16
  04a0c:    nop
  04a10:    mov        r9, #0x4a9c
  04a14:    mov        r10, #0x4b40
  04a18:    add        r10, r10, r9
  04a1c:    lsr        r11, r10, #2
  04a20:    add        r4, r11, #0x1
_PKT_0x753b_17:
  04a24:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
  04a28:    add        r9, r9, #0x4
  04a2c:    sub        r4, r4, #0x1
  04a30:    cbnz       r4, _PKT_0x753b_17
  04a34:    nop
  04a38:    mov        r3, #0x1
  04a3c:    mov        r9, #0x4b80
  04a40:    mov        r10, #0x4ca4
  04a44:    add        r10, r10, r9
  04a48:    lsr        r11, r10, #2
  04a4c:    add        r4, r11, #0x1
  04a50:    add        r13, r4, #0x0
  04a54:    mov        r2, #0x4b80
_PKT_0x753b_18:
  04a58:    dw         0x84000ed0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xed0
  04a5c:    add        r4, r13, #0x0
_PKT_0x753b_19:
  04a60:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
  04a64:    add        r9, r9, #0x4
  04a68:    sub        r4, r4, #0x1
  04a6c:    cbnz       r4, _PKT_0x753b_19
  04a70:    nop
  04a74:    hwop       r9, r2, #0x0
  04a78:    add        r9, r9, #0x180
  04a7c:    hwop       r2, r9, #0x0
  04a80:    sub        r3, r3, #0x1
  04a84:    cbnz       r3, _PKT_0x753b_18
  04a88:    nop
  04a8c:    mov        r3, #0x9
  04a90:    mov        r9, #0x4d00
  04a94:    mov        r2, #0x4d00
_PKT_0x753b_20:
  04a98:    dw         0x84000ed0  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xed0
  04a9c:    mov        r11, #0x4d00
  04aa0:    mov        r10, #0x4d48
  04aa4:    add        r10, r10, r11
  04aa8:    lsr        r11, r10, #2
  04aac:    add        r4, r11, #0x1
  04ab0:    add        r13, r4, #0x0
  04ab4:    add        r4, r13, #0x0
_PKT_0x753b_21:
  04ab8:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
  04abc:    add        r9, r9, #0x4
  04ac0:    sub        r4, r4, #0x1
  04ac4:    cbnz       r4, _PKT_0x753b_21
  04ac8:    nop
  04acc:    mov        r11, #0x4d48
  04ad0:    mov        r10, #0x4da8
  04ad4:    add        r10, r10, r11
  04ad8:    sub        r10, r10, #0x4
  04adc:    hwop       r9, r9, #0x0
  04ae0:    mov        r11, #0x4da8
  04ae4:    mov        r10, #0x4e24
  04ae8:    add        r10, r10, r11
  04aec:    lsr        r11, r10, #2
  04af0:    add        r4, r11, #0x1
  04af4:    add        r13, r4, #0x0
  04af8:    add        r4, r13, #0x0
_PKT_0x753b_22:
  04afc:    dw         0x84000ebd  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xebd
  04b00:    add        r9, r9, #0x4
  04b04:    sub        r4, r4, #0x1
  04b08:    cbnz       r4, _PKT_0x753b_22
  04b0c:    nop
  04b10:    hwop       r9, r2, #0x0
  04b14:    add        r9, r9, #0x180
  04b18:    hwop       r2, r9, #0x0
  04b1c:    sub        r3, r3, #0x1
  04b20:    cbnz       r3, _PKT_0x753b_20
  04b24:    nop
  04b28:    mov        r2, #0xf
_PKT_0x753b_23:
  04b2c:    stw        r2, reg[r0, #0x49d8]
  04b30:    ldd        r6, reg[r0, #0x4a60]
  04b34:    mov        r7, #0x0
  04b38:    and        r5, r6, #0xffffc007
  04b3c:    mov        r10, #0xfb48
  04b40:    cbz        r5, _PKT_0x753b_24
  04b44:    mov        r10, #0xfb49
_PKT_0x753b_24:
  04b48:    stw        r7, [r0, #0xea]
  04b4c:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  04b50:    mov        r14, #0xf893
  04b54:    lsl        r13, r14, #2
  04b58:    ldd        r7, reg[r13, #0x0]
  04b5c:    orr        r14, r7, #0x6
  04b60:    cbz        r14, _PKT_0x753b_25
  04b64:    stw        r0, reg[r13, #0x0]
_PKT_0x753b_25:
  04b68:    dw         0x8400136d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x136d
  04b6c:    std        r0, mem[r0, #0xe5]
  04b70:    std        r0, mem[r0, #0xe6]
  04b74:    std        r1, mem[r0, #0x112]
  04b78:    std        r1, mem[r0, #0x111]
  04b7c:    stw        r0, [r0, #0x77]
  04b80:    std        r0, [r0, #0x174]
  04b84:    std        r0, [r0, #0x176]
  04b88:    dw         0x8400116f  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x116f
  04b8c:    dw         0x84001206  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x1206
  04b90:    stw        r0, [r0, #0x9b]
  04b94:    ldd        r10, reg[r0, #0x4af0]
  04b98:    cbz        r10, _PKT_0xf0_9
  04b9c:    std        r0, [r0, #0xfd]
  04ba0:    dw         0x840012ba  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ba
  04ba4:    dw         0x840012ac  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12ac
  04ba8:    std        r1, [r0, #0xfd]
  04bac:    b          _PKT_0xf0_2  
_PKT_0x753b_26:
  04bb0:    dw         0x8400090a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x90a
  04bb4:    ldd        r11, reg[r0, #0x84]
  04bb8:    cbnz       r11, _PKT_0x753b_26
  04bbc:    dw         0x840012b5  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12b5
  04bc0:    ldd        r10, reg[r0, #0x4a14]
  04bc4:    lsr        r11, r10, #25
  04bc8:    and        r10, r11, #0xfffff001
  04bcc:    cbz        r10, _PKT_0x753b_26
  04bd0:    btab

  04bd4:    ldd        r15, reg[r0, #0x5b44]
  04bd8:    and        r15, r15, #0xffffe003
  04bdc:    cbnz       r15, _PKT_0x753b_27
  04be0:    std        r15, reg[r0, #0x5b44]
_PKT_0x753b_27:
  04be4:    btab

  04be8:    mov        r14, #0x0
_PKT_0x753b_28:
  04bec:    add        r14, r14, #0x1
  04bf0:    setgt      r15, r14, #0x10
  04bf4:    cbz        r15, _PKT_0x753b_28
  04bf8:    btab

  04bfc:    lsl        r9, r9, #2
  04c00:    ldd        r5, reg[r9, #0x0]
  04c04:    nop
  04c08:    hwop       r7, r6, #0x0
  04c0c:    lsrd       r8, r6, #32
  04c10:    std        r1, mem[r0, #0x43]
  04c14:    stw        r7, mem[r0, #0x39]
  04c18:    stw        r5, mem[r0, #0x3b]
  04c1c:    stw        r8, mem[r0, #0x3a]
  04c20:    addd       r6, r6, #0x4
  04c24:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
  04c28:    btab

_PKT_0x753b_29:
  04c2c:    dw         0x8400113a  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x113a
  04c30:    lsl        r3, r4, #16
  04c34:    hwop       r4, r3, #0x7
  04c38:    stw        r4, reg[r0, #0x49d8]
  04c3c:    ldd        r6, reg[r0, #0x4a60]
  04c40:    mov        r7, #0x5
  04c44:    and        r5, r6, #0xffffc007
  04c48:    mov        r10, #0xfb48
  04c4c:    cbz        r5, _PKT_0x753b_30
  04c50:    mov        r10, #0xfb49
_PKT_0x753b_30:
  04c54:    stw        r7, [r0, #0xe7]
  04c58:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  04c5c:    std        r7, mem[r0, #0xe5]
  04c60:    std        r3, mem[r0, #0xe6]
  04c64:    std        r2, mem[r0, #0x112]
  04c68:    std        r2, mem[r0, #0x111]
  04c6c:    std        r1, [r0, #0x174]
  04c70:    std        r1, [r0, #0x176]
  04c74:    mov        r11, #0xf882
  04c78:    lsl        r10, r11, #2
  04c7c:    ldd        r7, reg[r10, #0x0]
  04c80:    mov        r11, #0xf883
  04c84:    lsl        r10, r11, #2
  04c88:    ldd        r8, reg[r10, #0x0]
  04c8c:    lsld       r6, r8, #32
  04c90:    hwop       r6, r6, #0x20
  04c94:    mov        r9, #0xf887
  04c98:    dw         0x840012bf  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12bf
  04c9c:    mov        r9, #0xf884
  04ca0:    dw         0x840012bf  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x12bf
  04ca4:    mov        r9, #0x49e8
  04ca8:    mov        r10, #0x4a74
  04cac:    add        r10, r10, r9
  04cb0:    lsr        r11, r10, #2
  04cb4:    add        r4, r11, #0x1
_PKT_0x753b_31:
  04cb8:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
  04cbc:    add        r9, r9, #0x4
  04cc0:    sub        r4, r4, #0x1
  04cc4:    cbnz       r4, _PKT_0x753b_31
  04cc8:    nop
  04ccc:    mov        r9, #0x4a9c
  04cd0:    mov        r10, #0x4b40
  04cd4:    add        r10, r10, r9
  04cd8:    lsr        r11, r10, #2
  04cdc:    add        r4, r11, #0x1
_PKT_0x753b_32:
  04ce0:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
  04ce4:    add        r9, r9, #0x4
  04ce8:    sub        r4, r4, #0x1
  04cec:    cbnz       r4, _PKT_0x753b_32
  04cf0:    nop
  04cf4:    mov        r3, #0x1
  04cf8:    mov        r9, #0x4b80
  04cfc:    mov        r10, #0x4ca4
  04d00:    add        r10, r10, r9
  04d04:    lsr        r11, r10, #2
  04d08:    add        r4, r11, #0x1
  04d0c:    add        r13, r4, #0x0
  04d10:    mov        r2, #0x4b80
_PKT_0x753b_33:
  04d14:    add        r4, r13, #0x0
_PKT_0x753b_34:
  04d18:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
  04d1c:    add        r9, r9, #0x4
  04d20:    sub        r4, r4, #0x1
  04d24:    cbnz       r4, _PKT_0x753b_34
  04d28:    nop
  04d2c:    hwop       r9, r2, #0x0
  04d30:    add        r9, r9, #0x180
  04d34:    hwop       r2, r9, #0x0
  04d38:    sub        r3, r3, #0x1
  04d3c:    cbnz       r3, _PKT_0x753b_33
  04d40:    nop
  04d44:    mov        r3, #0x9
  04d48:    mov        r9, #0x4d00
  04d4c:    mov        r2, #0x4d00
_PKT_0x753b_35:
  04d50:    mov        r11, #0x4d00
  04d54:    mov        r10, #0x4d48
  04d58:    add        r10, r10, r11
  04d5c:    lsr        r11, r10, #2
  04d60:    add        r4, r11, #0x1
  04d64:    add        r13, r4, #0x0
  04d68:    add        r4, r13, #0x0
_PKT_0x753b_36:
  04d6c:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
  04d70:    add        r9, r9, #0x4
  04d74:    sub        r4, r4, #0x1
  04d78:    cbnz       r4, _PKT_0x753b_36
  04d7c:    nop
  04d80:    mov        r11, #0x4d48
  04d84:    mov        r10, #0x4da8
  04d88:    add        r10, r10, r11
  04d8c:    sub        r10, r10, #0x4
  04d90:    hwop       r9, r9, #0x0
  04d94:    mov        r11, #0x4da8
  04d98:    mov        r10, #0x4e24
  04d9c:    add        r10, r10, r11
  04da0:    lsr        r11, r10, #2
  04da4:    add        r4, r11, #0x1
  04da8:    add        r13, r4, #0x0
  04dac:    add        r4, r13, #0x0
_PKT_0x753b_37:
  04db0:    dw         0x84000f24  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf24
  04db4:    add        r9, r9, #0x4
  04db8:    sub        r4, r4, #0x1
  04dbc:    cbnz       r4, _PKT_0x753b_37
  04dc0:    nop
  04dc4:    hwop       r9, r2, #0x0
  04dc8:    add        r9, r9, #0x180
  04dcc:    hwop       r2, r9, #0x0
  04dd0:    sub        r3, r3, #0x1
  04dd4:    cbnz       r3, _PKT_0x753b_35
  04dd8:    nop
  04ddc:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  04de0:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
_PKT_0x753b_38:
  04de4:    std        r1, mem[r0, #0x33]
  04de8:    dw         0x84000f77  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf77
  04dec:    dw         0x84000f7c  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0xf7c
_PKT_0x753b_39:
  04df0:    ldd        r6, reg[r0, #0x4a14]
  04df4:    lsr        r5, r6, #13
  04df8:    and        r6, r5, #0xfffff001
  04dfc:    cbz        r6, _PKT_0x753b_39
  04e00:    mov        r2, #0xf
  04e04:    stw        r2, reg[r0, #0x49d8]
  04e08:    ldd        r6, reg[r0, #0x4a60]
  04e0c:    mov        r7, #0x0
  04e10:    and        r5, r6, #0xffffc007
  04e14:    mov        r10, #0xfb48
  04e18:    cbz        r5, _PKT_0x753b_40
  04e1c:    mov        r10, #0xfb49
_PKT_0x753b_40:
  04e20:    stw        r7, [r0, #0xe9]
  04e24:    dw         0x8400112d  #rs=0 rd=0 rx=0 a=0x21 b=0x0, imm=0x112d
  04e28:    std        r0, mem[r0, #0xe5]
  04e2c:    std        r0, mem[r0, #0xe6]
  04e30:    std        r1, mem[r0, #0x112]
  04e34:    std        r1, mem[r0, #0x111]
  04e38:    stw        r0, [r0, #0x77]
  04e3c:    std        r0, [r0, #0x174]
  04e40:    std        r0, [r0, #0x176]
  04e44:    b          _PKT_0x753b_38  
  04e48:    ldd        r13, reg[r0, #0xfc]
  04e4c:    cbz        r13, _PKT_0x753b_42
_PKT_0x753b_41:
  04e50:    ldd        r13, reg[r0, #0x5a8c]
  04e54:    ldd        r14, reg[r0, #0x5a94]
  04e58:    seteq      r4, r13, r14
  04e5c:    cbz        r4, _PKT_0x753b_42
  04e60:    mov        r14, #0xf893
  04e64:    lsl        r13, r14, #2
  04e68:    lsl        r13, r14, #2
  04e6c:    ldd        r4, reg[r13, #0x0]
  04e70:    and        r13, r4, #0xfc007fff
  04e74:    orr        r14, r13, #0x5
  04e78:    cbz        r14, _PKT_0x753b_42
  04e7c:    b          _PKT_0x753b_23  
_PKT_0x753b_42:
  04e80:    btab

  04e84:    std        r0, [r0, #0x174]
  04e88:    std        r0, [r0, #0x175]
  04e8c:    std        r0, [r0, #0x176]
  04e90:    std        r0, [r0, #0x177]
  04e94:    std        r0, [r0, #0xcb]
  04e98:    stw        r0, [r0, #0x93]
_PKT_0x753b_43:
  04e9c:    stw        r0, [r0, #0x99]
  04ea0:    stw        r0, [r0, #0x97]
  04ea4:    stw        r0, [r0, #0x7d]
  04ea8:    stw        r0, [r0, #0xdb]
  04eac:    stw        r0, [r0, #0x9a]
  04eb0:    btab

  04eb4:    std        r0, [r0, #0x174]
  04eb8:    std        r0, [r0, #0x175]
  04ebc:    std        r0, [r0, #0x176]
  04ec0:    std        r0, [r0, #0x177]
  04ec4:    std        r0, [r0, #0xcb]
  04ec8:    stw        r0, [r0, #0x93]
  04ecc:    stw        r0, [r0, #0x99]
  04ed0:    stw        r0, [r0, #0x97]
  04ed4:    stw        r0, [r0, #0x7d]
  04ed8:    stw        r0, [r0, #0xdb]
  04edc:    stw        r0, [r0, #0x9a]
  04ee0:    btab

  04ee4:    nop
  04ee8:    b          _PKT_0x753b_38  
  04eec:    ldd        r14, reg[r0, #0x49d8]
  04ef0:    orr        r13, r14, #0xf
  04ef4:    cbnz       r13, _PKT_0x753b_44
  04ef8:    mov        r14, #0xf893
  04efc:    lsl        r13, r14, #2
  04f00:    ldd        r4, reg[r13, #0x0]
  04f04:    and        r13, r4, #0xfc007fff
  04f08:    orr        r14, r13, #0x6
  04f0c:    cbnz       r14, _PKT_0x753b_14
_PKT_0x753b_44:
  04f10:    btab

  04f14:    mov        r13, #0x13
  04f18:    stw        r13, [r0, #0x170]
  04f1c:    stw        r13, [r0, #0x171]
  04f20:    stw        r13, [r0, #0x172]
  04f24:    stw        r13, [r0, #0x173]
  04f28:    btab

  04f2c:    ldd        r14, reg[r0, #0x4af8]
  04f30:    lsr        r13, r14, #31
  04f34:    cbz        r13, _PKT_0x753b_45
  04f38:    nop
  04f3c:    and        r13, r14, #0xfffff001
  04f40:    cbnz       r13, _PKT_0x753b_47
  04f44:    nop
  04f48:    b          _PKT_0x753b_43  
  04f4c:    nop
_PKT_0x753b_45:
  04f50:    btab

  04f54:    ldd        r14, reg[r0, #0x4af8]
  04f58:    lsr        r13, r14, #31
  04f5c:    cbz        r13, _PKT_0x753b_46
  04f60:    nop
  04f64:    and        r13, r14, #0xfffff001
  04f68:    cbnz       r13, _PKT_0xe9be_7
  04f6c:    nop
  04f70:    b          _PKT_0x753b_43  
  04f74:    nop
_PKT_0x753b_46:
  04f78:    btab

_PKT_0x753b_47:
  04f7c:    std        r1, [r0, #0xfa]
  04f80:    mov        r13, #0x1
  04f84:    lsl        r13, r13, #8
  04f88:    ldd        r14, reg[r0, #0x49f0]
  04f8c:    hwop       r14, r13, #0x7
  04f90:    nop
  04f94:    std        r1, [r0, #0xca]
  04f98:    b          _PKT_0xf0_10  
  04f9c:    std        r1, [r0, #0xfa]
  04fa0:    mov        r13, #0x1
  04fa4:    lsl        r13, r13, #30
  04fa8:    hwop       r14, r14, #0x7
  04fac:    stw        r14, reg[r0, #0x4af8]
_PKT_0x753b_48:
  04fb0:    std        r0, [r0, #0x174]
  04fb4:    std        r0, [r0, #0x175]
  04fb8:    std        r0, [r0, #0x176]
  04fbc:    std        r0, [r0, #0x177]
  04fc0:    ldd        r14, reg[r0, #0x4af8]
  04fc4:    nop
  04fc8:    lsr        r13, r14, #31
  04fcc:    cbnz       r13, _PKT_0x753b_48
  04fd0:    mov        r13, #0x1
  04fd4:    lsl        r13, r13, #30
  04fd8:    eor        r13, r13, r0
  04fdc:    hwop       r14, r13, #0x6
  04fe0:    stw        r14, reg[r0, #0x4af8]
  04fe4:    std        r0, [r0, #0x178]
  04fe8:    std        r0, [r0, #0xfa]
  04fec:    b          _PKT_0x753b_41  
  04ff0:    nop
  04ff4:    nop
  04ff8:    nop
  04ffc:    nop
  05000:    nop
  05004:    nop
  05008:    nop
  0500c:    nop
  05010:    nop
  05014:    nop
  05018:    nop
  0501c:    nop
  05020:    nop
  05024:    nop
  05028:    nop
  0502c:    nop
  05030:    nop
  05034:    nop
  05038:    nop
  0503c:    nop
  05040:    nop
  05044:    nop
  05048:    nop
  0504c:    nop
  05050:    nop
  05054:    nop
  05058:    nop
  0505c:    nop
  05060:    nop
  05064:    nop
  05068:    nop
  0506c:    nop
  05070:    nop
  05074:    nop
  05078:    nop
  0507c:    nop
  05080:    nop
  05084:    nop
  05088:    nop
  0508c:    nop
  05090:    nop
  05094:    nop
  05098:    nop
  0509c:    nop
  050a0:    nop
  050a4:    nop
  050a8:    nop
  050ac:    nop
  050b0:    nop
  050b4:    nop
  050b8:    nop
  050bc:    nop
  050c0:    nop
  050c4:    nop
  050c8:    nop
  050cc:    nop
  050d0:    nop
  050d4:    nop
  050d8:    nop
  050dc:    nop
  050e0:    nop
  050e4:    nop
  050e8:    nop
  050ec:    nop
  050f0:    nop
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

PKT_0xd90c:
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

PKT_0x862a:
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
_PKT_0x862a_0:
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
#J[INCREMENT_DE_COUNTER] = INCREMENT_DE_COUNTER
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
#J[0x111] = PKT_0x111
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
#J[0x4252] = PKT_0x4252
#J[0x28b3] = PKT_0x28b3
#J[0xe27b] = PKT_0xe27b
#J[0xa776] = PKT_0xa776
#J[0x8e9d] = PKT_0x8e9d
#J[0x914] = PKT_0x914
#J[0x8deb] = PKT_0x8deb
#J[0xa05e] = PKT_0xa05e
#J[0x8147] = PKT_0x8147
#J[0x2150] = PKT_0x2150
#J[0x6b58] = PKT_0x6b58
#J[0x51c4] = PKT_0x51c4
#J[0xc1e] = PKT_0xc1e
#J[0xe33c] = PKT_0xe33c
#J[0x3abb] = PKT_0x3abb
#J[0xad09] = PKT_0xad09
#J[0xa419] = PKT_0xa419
#J[0x2afe] = PKT_0x2afe
#J[0x373d] = PKT_0x373d
#J[0x1ea] = PKT_0x1ea
#J[0x862a] = PKT_0x862a
#J[0x76eb] = PKT_0x76eb
#J[0x71c3] = PKT_0x71c3
#J[0xf728] = PKT_0xf728
#J[0xafc0] = PKT_0xafc0
#J[0xfce2] = PKT_0xfce2
#J[0x3e04] = PKT_0x3e04
#J[0x9d2d] = PKT_0x9d2d
#J[0x9480] = PKT_0x9480
#J[0x11cc] = PKT_0x11cc
#J[0x484a] = PKT_0x484a
#J[0xebda] = PKT_0xebda
#J[0xf198] = PKT_0xf198
#J[0x13f1] = PKT_0x13f1
#J[0x82c3] = PKT_0x82c3
#J[0x76d3] = PKT_0x76d3
#J[0x6ac7] = PKT_0x6ac7
#J[0x6176] = PKT_0x6176
#J[0x25a5] = PKT_0x25a5
#J[0x766a] = PKT_0x766a
#J[0xe971] = PKT_0xe971
#J[0xef74] = PKT_0xef74
#J[0x76fe] = PKT_0x76fe
#J[0xf507] = PKT_0xf507
#J[0x8a14] = PKT_0x8a14
#J[0x4978] = PKT_0x4978
#J[0xd90c] = PKT_0xd90c
#J[0x4c8] = PKT_0x4c8
#J[0xe2a9] = PKT_0xe2a9
#J[0xb307] = PKT_0xb307
#J[0x6ef9] = PKT_0x6ef9
#J[0x2cfa] = PKT_0x2cfa
#J[0xe1a3] = PKT_0xe1a3
#J[0xe2db] = PKT_0xe2db
#J[0x655a] = PKT_0x655a
#J[0xc3c2] = PKT_0xc3c2
#J[0x3fbe] = PKT_0x3fbe
#J[0xe9be] = PKT_0xe9be
#J[0x753b] = PKT_0x753b
#J[0xbd12] = PKT_0xbd12
#J[0xf116] = PKT_0xf116
#J[0x1098] = PKT_0x1098
#J[0x40b5] = PKT_0x40b5
#J[0x348f] = PKT_0x348f
