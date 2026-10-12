 0x2878: sub    sp, sp, #0x60
 0x287c: stp    x26, x25, [sp, #0x10]
 0x2880: stp    x24, x23, [sp, #0x20]
 0x2884: stp    x22, x21, [sp, #0x30]
 0x2888: stp    x20, x19, [sp, #0x40]
 0x288c: stp    x29, x30, [sp, #0x50]
 0x2890: add    x29, sp, #0x50
 0x2894: mrs    x25, tpidr_el0
 0x2898: mov    x20, x3
 0x289c: ldr    x8, [x25, #0x28]
 0x28a0: mov    w19, w1
 0x28a4: mov    x22, x0
 0x28a8: mov    x1, sp
 0x28ac: mov    w24, w2
 0x28b0: str    x8, [sp, #8]
 0x28b4: ldr    x8, [x20, #0x20]
 0x28b8: ldp    w26, w21, [x20, #0x38]
 0x28bc: str    xzr, [sp]
 0x28c0: mov    x0, x8
 0x28c4: bl     #0x23e8 ; <duss_hal_mem_map>
 0x28c8: ldr    x8, [sp]
 0x28cc: cmp    w0, #0
 0x28d0: csel   x23, x8, xzr, eq
 0x28d4: cbz    x22, #0x2990
 0x28d8: sub    w8, w24, #0xa
 0x28dc: cmp    w8, #6
 0x28e0: b.hi   #0x2974
 0x28e4: adrp   x9, #0x7000
 0x28e8: add    x9, x9, #0xf50 ; =0x7f50
 0x28ec: ldrsw  x8, [x9, x8, lsl #2]
 0x28f0: add    x8, x8, x9
 0x28f4: br     x8
 0x28f8: cmp    w21, #1
 0x28fc: b.lt   #0x2974
 0x2900: add    w8, w26, w26, lsl #1
 0x2904: cmp    w8, #0
 0x2908: cinc   w8, w8, lt
 0x290c: mov    w26, w21
 0x2910: sbfx   x24, x8, #1, #0x1f
 0x2914: mov    w1, #1
 0x2918: mov    x0, x23
 0x291c: mov    x2, x24
 0x2920: mov    x3, x22
 0x2924: bl     #0x2418 ; <fwrite>
 0x2928: ldrsw  x8, [x20, #0x40]
 0x292c: subs   w26, w26, #1
 0x2930: add    x23, x23, x8
 0x2934: b.ne   #0x2914
 0x2938: b      #0x2974
 0x293c: cmp    w21, #1
 0x2940: b.lt   #0x2974
 0x2944: lsl    w8, w26, #1
 0x2948: mov    w26, w21
 0x294c: sxtw   x24, w8
 0x2950: mov    w1, #1
 0x2954: mov    x0, x23
 0x2958: mov    x2, x24
 0x295c: mov    x3, x22
 0x2960: bl     #0x2418 ; <fwrite>
 0x2964: ldrsw  x8, [x20, #0x40]
 0x2968: subs   w26, w26, #1
 0x296c: add    x23, x23, x8
 0x2970: b.ne   #0x2950
 0x2974: ldr    w2, [x20, #0x40]
 0x2978: adrp   x0, #0x8000
 0x297c: ldr    w4, [x20, #0x50]
 0x2980: add    x0, x0, #0x3d ; "inst:%d, write  output file, stride %d, height %d, len:%d!!!
"
 0x2984: mov    w1, w19
 0x2988: mov    w3, w21
 0x298c: bl     #0x23c8 ; <printf>
 0x2990: ldr    x8, [x25, #0x28]
 0x2994: ldr    x9, [sp, #8]
 0x2998: cmp    x8, x9
 0x299c: b.ne   #0x29bc
 0x29a0: ldp    x29, x30, [sp, #0x50]
 0x29a4: ldp    x20, x19, [sp, #0x40]
 0x29a8: ldp    x22, x21, [sp, #0x30]
 0x29ac: ldp    x24, x23, [sp, #0x20]
 0x29b0: ldp    x26, x25, [sp, #0x10]
 0x29b4: add    sp, sp, #0x60
 0x29b8: ret    
 0x29bc: bl     #0x23d8 ; <__stack_chk_fail>
