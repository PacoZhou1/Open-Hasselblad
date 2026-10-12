0x3a298: sub    sp, sp, #0xc0
0x3a29c: stp    x22, x21, [sp, #0x90]
0x3a2a0: stp    x20, x19, [sp, #0xa0]
0x3a2a4: stp    x29, x30, [sp, #0xb0]
0x3a2a8: add    x29, sp, #0xb0
0x3a2ac: mrs    x22, tpidr_el0
0x3a2b0: adrp   x4, #0x4c000
0x3a2b4: ldr    x8, [x22, #0x28]
0x3a2b8: adrp   x5, #0x4d000
0x3a2bc: mov    x20, x1
0x3a2c0: add    x4, x4, #0xc27 ; "hardware/dji/common/codec/hal/msenc/dji_msenc.c"
0x3a2c4: add    x5, x5, #0x7e4 ; "moonshadow_enc_start"
0x3a2c8: stur   x8, [x29, #-0x28]
0x3a2cc: mov    w6, #0x33f
0x3a2d0: ldr    x19, [x0, #0x70]
0x3a2d4: mov    w0, #0x32
0x3a2d8: mov    w1, #3
0x3a2dc: add    x2, sp, #8
0x3a2e0: mov    w3, #0x80
0x3a2e4: bl     #0x95a8 ; <duss_log_gen_head>
0x3a2e8: cbz    w0, #0x3a310
0x3a2ec: adrp   x3, #0x45000
0x3a2f0: adrp   x4, #0x4d000
0x3a2f4: add    x3, x3, #0xe43 ; "[%s] Starting... (Instance: %p)
"
0x3a2f8: add    x4, x4, #0x7e4 ; "moonshadow_enc_start"
0x3a2fc: mov    w0, #0x32
0x3a300: mov    w1, #3
0x3a304: add    x2, sp, #8
0x3a308: mov    x5, x19
0x3a30c: bl     #0x95b8 ; <duss_log_print>
0x3a310: cbz    x20, #0x3a484
0x3a314: cbz    x19, #0x3a484
0x3a318: ldr    w8, [x20]
0x3a31c: str    w8, [x19, #0x108]
0x3a320: ldr    w8, [x20, #4]
0x3a324: str    w8, [x19, #0x10c]
0x3a328: ldr    w0, [x20, #0xc]
0x3a32c: bl     #0xa9a8 ; <msenc_get_bit_depth>
0x3a330: str    w0, [x19, #0x110]
0x3a334: ldr    w0, [x20, #0xc]
0x3a338: bl     #0xa9b8 ; <msenc_get_bayer_type>
0x3a33c: str    w0, [x19, #0x114]
0x3a340: mov    w8, #1
0x3a344: ldr    w9, [x20, #8]
0x3a348: movk   w8, #0x302, lsl #16
0x3a34c: adrp   x4, #0x4c000
0x3a350: adrp   x5, #0x4d000
0x3a354: add    x4, x4, #0xc27 ; "hardware/dji/common/codec/hal/msenc/dji_msenc.c"
0x3a358: lsl    w10, w9, #3
0x3a35c: cmp    w9, #4
0x3a360: lsr    w8, w8, w10
0x3a364: csel   w8, w8, wzr, lo
0x3a368: add    x5, x5, #0x7e4 ; "moonshadow_enc_start"
0x3a36c: mov    w0, #0x32
0x3a370: mov    w6, #0x35f
0x3a374: strb   w8, [x19, #0x118]
0x3a378: mov    w1, #3
0x3a37c: add    x2, sp, #8
0x3a380: mov    w3, #0x80
0x3a384: add    x21, x19, #0x118
0x3a388: bl     #0x95a8 ; <duss_log_gen_head>
0x3a38c: cbz    w0, #0x3a3b4
0x3a390: ldr    w5, [x20, #8]
0x3a394: adrp   x3, #0x4d000
0x3a398: adrp   x4, #0x4d000
0x3a39c: add    x3, x3, #0x828 ; "%s(): profile %d"
0x3a3a0: add    x4, x4, #0x7e4 ; "moonshadow_enc_start"
0x3a3a4: mov    w0, #0x32
0x3a3a8: mov    w1, #3
0x3a3ac: add    x2, sp, #8
0x3a3b0: bl     #0x95b8 ; <duss_log_print>
0x3a3b4: adrp   x4, #0x4c000
0x3a3b8: strh   wzr, [x19, #0x390]
0x3a3bc: adrp   x5, #0x4d000
0x3a3c0: mov    w8, #1
0x3a3c4: add    x4, x4, #0xc27 ; "hardware/dji/common/codec/hal/msenc/dji_msenc.c"
0x3a3c8: add    x5, x5, #0x839 ; "msenc_setup_rate_ctrl"
0x3a3cc: mov    w0, #0x32
0x3a3d0: strb   w8, [x19, #0x392]
0x3a3d4: mov    w6, #0x676
0x3a3d8: mov    w1, #2
0x3a3dc: add    x2, sp, #8
0x3a3e0: mov    w3, #0x80
0x3a3e4: bl     #0x95a8 ; <duss_log_gen_head>
0x3a3e8: cbz    w0, #0x3a40c
0x3a3ec: adrp   x3, #0x4d000
0x3a3f0: adrp   x4, #0x4d000
0x3a3f4: add    x3, x3, #0x84f ; "____MSENC:%s():Currently, msenc_setup_ratectrl is not implemented.
"
0x3a3f8: add    x4, x4, #0x839 ; "msenc_setup_rate_ctrl"
0x3a3fc: mov    w0, #0x32
0x3a400: mov    w1, #2
0x3a404: add    x2, sp, #8
0x3a408: bl     #0x95b8 ; <duss_log_print>
0x3a40c: ldp    w0, w1, [x20]
0x3a410: mov    w2, #4
0x3a414: bl     #0xa9c8 ; <msenc_encode_get_slice_num>
0x3a418: add    x8, x19, #0x388
0x3a41c: str    w0, [x19, #0x148]
0x3a420: mov    x0, x8
0x3a424: mov    x1, x21
0x3a428: bl     #0xa9d8 ; <msenc_frame_depend_param_init>
0x3a42c: adrp   x4, #0x4c000
0x3a430: adrp   x5, #0x4d000
0x3a434: add    x4, x4, #0xc27 ; "hardware/dji/common/codec/hal/msenc/dji_msenc.c"
0x3a438: add    x5, x5, #0x7e4 ; "moonshadow_enc_start"
0x3a43c: mov    w0, #0x32
0x3a440: mov    w6, #0x370
0x3a444: mov    w1, #3
0x3a448: add    x2, sp, #8
0x3a44c: mov    w3, #0x80
0x3a450: bl     #0x95a8 ; <duss_log_gen_head>
0x3a454: cbz    w0, #0x3a47c
0x3a458: adrp   x3, #0x45000
0x3a45c: adrp   x4, #0x4d000
0x3a460: add    x3, x3, #0xe81 ; "[%s] Start successfully (Instance: %p)
"
0x3a464: add    x4, x4, #0x7e4 ; "moonshadow_enc_start"
0x3a468: mov    w0, #0x32
0x3a46c: mov    w1, #3
0x3a470: add    x2, sp, #8
0x3a474: mov    x5, x19
0x3a478: bl     #0x95b8 ; <duss_log_print>
0x3a47c: mov    w0, wzr
0x3a480: b      #0x3a4d4
0x3a484: adrp   x4, #0x4c000
0x3a488: adrp   x5, #0x4d000
0x3a48c: add    x4, x4, #0xc27 ; "hardware/dji/common/codec/hal/msenc/dji_msenc.c"
0x3a490: add    x5, x5, #0x7e4 ; "moonshadow_enc_start"
0x3a494: mov    w0, #0x32
0x3a498: mov    w6, #0x343
0x3a49c: mov    w1, #1
0x3a4a0: add    x2, sp, #8
0x3a4a4: mov    w3, #0x80
0x3a4a8: bl     #0x95a8 ; <duss_log_gen_head>
0x3a4ac: cbz    w0, #0x3a4d0
0x3a4b0: adrp   x3, #0x4d000
0x3a4b4: adrp   x4, #0x4d000
0x3a4b8: add    x3, x3, #0x7f9 ; "____MSENC:%s(): pointer parameters is NULL:%d
"
0x3a4bc: add    x4, x4, #0x7e4 ; "moonshadow_enc_start"
0x3a4c0: mov    w0, #0x32
0x3a4c4: mov    w1, #1
0x3a4c8: add    x2, sp, #8
0x3a4cc: bl     #0x95b8 ; <duss_log_print>
0x3a4d0: mov    w0, #-0x3eb
0x3a4d4: ldr    x8, [x22, #0x28]
0x3a4d8: ldur   x9, [x29, #-0x28]
0x3a4dc: cmp    x8, x9
0x3a4e0: b.ne   #0x3a4f8
0x3a4e4: ldp    x29, x30, [sp, #0xb0]
0x3a4e8: ldp    x20, x19, [sp, #0xa0]
0x3a4ec: ldp    x22, x21, [sp, #0x90]
0x3a4f0: add    sp, sp, #0xc0
0x3a4f4: ret    
0x3a4f8: bl     #0x95e8 ; <__stack_chk_fail>
0x3a4fc: udf    #0
0x3a500: sub    sp, sp, #0xb0
0x3a504: stp    x20, x19, [sp, #0x90]
0x3a508: stp    x29, x30, [sp, #0xa0]
0x3a50c: add    x29, sp, #0xa0
0x3a510: mrs    x20, tpidr_el0
0x3a514: adrp   x4, #0x4c000
0x3a518: ldr    x8, [x20, #0x28]
0x3a51c: adrp   x5, #0x4d000
0x3a520: add    x4, x4, #0xc27 ; "hardware/dji/common/codec/hal/msenc/dji_msenc.c"
0x3a524: add    x5, x5, #0x893 ; "moonshadow_enc_stop"
0x3a528: mov    w6, #0x379
0x3a52c: stur   x8, [x29, #-0x18]
0x3a530: mov    w1, #3
0x3a534: ldr    x19, [x0, #0x70]
0x3a538: mov    w0, #0x32
0x3a53c: add    x2, sp, #8
0x3a540: mov    w3, #0x80
0x3a544: bl     #0x95a8 ; <duss_log_gen_head>
0x3a548: cbz    w0, #0x3a570
0x3a54c: adrp   x3, #0x45000
0x3a550: adrp   x4, #0x4d000
0x3a554: add    x3, x3, #0xfac ; "[%s] Stop successfully (Instance: %p)
"
0x3a558: add    x4, x4, #0x893 ; "moonshadow_enc_stop"
0x3a55c: mov    w0, #0x32
0x3a560: mov    w1, #3
0x3a564: add    x2, sp, #8
0x3a568: mov    x5, x19
0x3a56c: bl     #0x95b8 ; <duss_log_print>
0x3a570: ldr    x8, [x20, #0x28]
0x3a574: ldur   x9, [x29, #-0x18]
0x3a578: cmp    x8, x9
0x3a57c: b.ne   #0x3a594
0x3a580: ldp    x29, x30, [sp, #0xa0]
0x3a584: ldp    x20, x19, [sp, #0x90]
0x3a588: mov    w0, wzr
0x3a58c: add    sp, sp, #0xb0
0x3a590: ret    
0x3a594: bl     #0x95e8 ; <__stack_chk_fail>
