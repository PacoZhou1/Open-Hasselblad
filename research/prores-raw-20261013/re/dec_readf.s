 0x2768: sub    sp, sp, #0x50
 0x276c: stp    x24, x23, [sp, #0x10]
 0x2770: stp    x22, x21, [sp, #0x20]
 0x2774: stp    x20, x19, [sp, #0x30]
 0x2778: stp    x29, x30, [sp, #0x40]
 0x277c: add    x29, sp, #0x40
 0x2780: mrs    x24, tpidr_el0
 0x2784: mov    x20, x1
 0x2788: ldr    x8, [x24, #0x28]
 0x278c: mov    x19, x0
 0x2790: mov    x1, sp
 0x2794: str    x8, [sp, #8]
 0x2798: ldr    x8, [x20, #0x20]
 0x279c: str    xzr, [sp]
 0x27a0: mov    x0, x8
 0x27a4: bl     #0x23e8 ; <duss_hal_mem_map>
 0x27a8: ldr    x8, [sp]
 0x27ac: cmp    w0, #0
 0x27b0: ldr    x0, [x20, #0x20]
 0x27b4: mov    x1, sp
 0x27b8: str    wzr, [sp]
 0x27bc: csel   x23, x8, xzr, eq
 0x27c0: bl     #0x23f8 ; <duss_hal_mem_get_size>
 0x27c4: ldr    w8, [sp]
 0x27c8: cmp    w0, #0
 0x27cc: ldrsw  x2, [x20, #0x40]
 0x27d0: mov    w1, #1
 0x27d4: mov    x0, x23
 0x27d8: mov    x3, x19
 0x27dc: csel   w22, w8, wzr, eq
 0x27e0: bl     #0x2408 ; <fread>
 0x27e4: ldr    w3, [x20, #0x58]
 0x27e8: mov    x21, x0
 0x27ec: cmp    w3, #1
 0x27f0: b.lt   #0x2814
 0x27f4: ldrsw  x8, [x20, #0x54]
 0x27f8: sxtw   x2, w3
 0x27fc: mov    w1, #1
 0x2800: mov    x3, x19
 0x2804: add    x0, x23, x8
 0x2808: bl     #0x2408 ; <fread>
 0x280c: ldr    w3, [x20, #0x58]
 0x2810: add    x21, x0, w21, uxtw
 0x2814: ldr    w2, [x20, #0x40]
 0x2818: adrp   x0, #0x7000
 0x281c: adrp   x1, #0x8000
 0x2820: add    x0, x0, #0xff6 ; "----%s, len_l:%d, len_r:%d, s_length:%d, count:%d----
"
 0x2824: add    x1, x1, #0x2d ; "read_msdec_file"
 0x2828: mov    w4, w22
 0x282c: mov    w5, w21
 0x2830: bl     #0x23c8 ; <printf>
 0x2834: mov    x0, x19
 0x2838: mov    x1, xzr
 0x283c: mov    w2, wzr
 0x2840: bl     #0x2388 ; <fseek>
 0x2844: ldr    x8, [x24, #0x28]
 0x2848: ldr    x9, [sp, #8]
 0x284c: cmp    x8, x9
 0x2850: b.ne   #0x2870
 0x2854: mov    w0, w21
 0x2858: ldp    x29, x30, [sp, #0x40]
 0x285c: ldp    x20, x19, [sp, #0x30]
 0x2860: ldp    x22, x21, [sp, #0x20]
 0x2864: ldp    x24, x23, [sp, #0x10]
 0x2868: add    sp, sp, #0x50
 0x286c: ret    
 0x2870: bl     #0x23d8 ; <__stack_chk_fail>
