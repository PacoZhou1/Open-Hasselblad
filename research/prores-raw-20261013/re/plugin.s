 0x2878: adrp   x0, #0x30000
 0x287c: add    x0, x0, #0 ; =0x30000
 0x2880: b      #0x22a8 ; <__cxa_finalize>
 0x2884: udf    #0
 0x2888: adrp   x3, #0x30000
 0x288c: add    x3, x3, #0 ; =0x30000
 0x2890: b      #0x22b8 ; <__register_atfork>
 0x2894: udf    #0
 0x2898: sub    sp, sp, #0x1e0
 0x289c: stp    x28, x27, [sp, #0x180]
 0x28a0: stp    x26, x25, [sp, #0x190]
 0x28a4: stp    x24, x23, [sp, #0x1a0]
 0x28a8: stp    x22, x21, [sp, #0x1b0]
 0x28ac: stp    x20, x19, [sp, #0x1c0]
 0x28b0: stp    x29, x30, [sp, #0x1d0]
 0x28b4: add    x29, sp, #0x1d0
 0x28b8: mrs    x23, tpidr_el0
 0x28bc: mov    x25, x4
 0x28c0: ldr    x8, [x23, #0x28]
 0x28c4: mov    x20, x3
 0x28c8: mov    x22, x2
 0x28cc: mov    x21, x1
 0x28d0: cmp    w0, #8
 0x28d4: stur   x8, [x29, #-0x58]
 0x28d8: b.ne   #0x3b74
 0x28dc: cbz    x21, #0x3bd8
 0x28e0: ldr    w8, [x21]
 0x28e4: mov    w19, #-0x2721
 0x28e8: add    w8, w8, w19
 0x28ec: cmp    w8, #0x3b
 0x28f0: b.hi   #0x39e4
 0x28f4: mov    x26, #0xc411
 0x28f8: movk   x26, #0x6208, lsl #16
 0x28fc: movk   x26, #0x3104, lsl #32
 0x2900: movk   x26, #0x882, lsl #48
 0x2904: mov    w9, #1
 0x2908: lsl    x8, x9, x8
 0x290c: tst    x8, x26
 0x2910: b.eq   #0x39e4
 0x2914: cbz    x25, #0x3c3c
 0x2918: adrp   x1, #0x1a000
 0x291c: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2920: mov    w0, #0x4a8
 0x2924: mov    w2, #0x67d
 0x2928: bl     #0x22c8 ; <cam_malloc_internal>
 0x292c: mov    x24, x0
 0x2930: cbz    x24, #0x2b7c
 0x2934: mov    w2, #0x4a8
 0x2938: mov    x0, x24
 0x293c: mov    w1, wzr
 0x2940: bl     #0x22d8 ; <memset>
 0x2944: adrp   x8, #0x4000
 0x2948: str    x20, [x24, #0x98]
 0x294c: add    x8, x8, #0xf48 ; =0x4f48
 0x2950: adrp   x9, #0x5000
 0x2954: add    x9, x9, #0xa10 ; =0x5a10
 0x2958: fmov   d0, x8
 0x295c: adrp   x10, #0x6000
 0x2960: add    x10, x10, #0x838 ; =0x6838
 0x2964: adrp   x8, #0x4000
 0x2968: add    x8, x8, #0xc68 ; =0x4c68
 0x296c: add    x20, x24, #0xb0
 0x2970: mov    w2, #0x310
 0x2974: mov    v0.d[1], x9
 0x2978: adrp   x9, #0x6000
 0x297c: add    x9, x9, #0x700 ; =0x6700
 0x2980: mov    x0, x20
 0x2984: mov    x1, x21
 0x2988: stp    x9, x10, [x24, #0x38]
 0x298c: adrp   x9, #0xa000
 0x2990: adrp   x10, #0xa000
 0x2994: add    x9, x9, #0xb80 ; =0xab80
 0x2998: stur   q0, [x24, #0x18]
 0x299c: add    x10, x10, #0xcb8 ; =0xacb8
 0x29a0: stp    x9, x10, [x24, #0x50]
 0x29a4: adrp   x9, #0xb000
 0x29a8: add    x9, x9, #0x540 ; =0xb540
 0x29ac: stp    x8, x9, [x24]
 0x29b0: adrp   x8, #0xb000
 0x29b4: adrp   x9, #0xe000
 0x29b8: add    x8, x8, #0xcd0 ; =0xbcd0
 0x29bc: add    x9, x9, #0x88 ; =0xe088
 0x29c0: stp    x8, x9, [x24, #0x60]
 0x29c4: adrp   x8, #0xe000
 0x29c8: add    x8, x8, #0x340 ; =0xe340
 0x29cc: mov    w9, #8
 0x29d0: str    x8, [x24, #0x70]
 0x29d4: ldr    x8, [x21, #0x288]
 0x29d8: str    x8, [x24, #0x440]
 0x29dc: ldr    x8, [x21, #0x2f0]
 0x29e0: str    x8, [x24, #0x448]
 0x29e4: ldr    x8, [x21, #0x2e0]
 0x29e8: str    w9, [x24, #0xa8]
 0x29ec: str    x8, [x24, #0x450]
 0x29f0: bl     #0x22e8 ; <memcpy>
 0x29f4: ldr    x8, [x21, #0x230]
 0x29f8: str    x8, [x24, #0x3d8]
 0x29fc: bl     #0x22f8 ; <cam_tracer_get>
 0x2a00: str    x0, [x24, #0x490]
 0x2a04: cbz    x0, #0x2a68
 0x2a08: adrp   x1, #0x1a000
 0x2a0c: add    x2, x24, #0x498
 0x2a10: add    x1, x1, #0x62e ; "enc_drop"
 0x2a14: bl     #0x2308 ; <perf_trace_register_instant>
 0x2a18: ldr    x0, [x24, #0x490]
 0x2a1c: adrp   x1, #0x1a000
 0x2a20: add    x2, x24, #0x49a
 0x2a24: add    x1, x1, #0x637 ; "proresraw_allocate_stream_buffer"
 0x2a28: bl     #0x2318 ; <perf_trace_register_slice>
 0x2a2c: ldr    x0, [x24, #0x490]
 0x2a30: adrp   x1, #0x1a000
 0x2a34: add    x2, x24, #0x49c
 0x2a38: add    x1, x1, #0x658 ; "create_ring_buffer"
 0x2a3c: bl     #0x2318 ; <perf_trace_register_slice>
 0x2a40: ldr    x0, [x24, #0x490]
 0x2a44: adrp   x1, #0x1a000
 0x2a48: add    x2, x24, #0x49e
 0x2a4c: add    x1, x1, #0x66b ; "duss_hal_msenc_encfrm"
 0x2a50: bl     #0x2318 ; <perf_trace_register_slice>
 0x2a54: ldr    x0, [x24, #0x490]
 0x2a58: adrp   x1, #0x1a000
 0x2a5c: add    x2, x24, #0x4a0
 0x2a60: add    x1, x1, #0x681 ; "wait_enc_callback"
 0x2a64: bl     #0x2318 ; <perf_trace_register_slice>
 0x2a68: cbz    x22, #0x2a74
 0x2a6c: mov    x0, x22
 0x2a70: bl     #0x2328 ; <load_from_init_param>
 0x2a74: ldr    w8, [x21, #0x24c]
 0x2a78: sub    w9, w8, #7
 0x2a7c: cmp    w9, #5
 0x2a80: b.hs   #0x3f04
 0x2a84: adrp   x10, #0x1e000
 0x2a88: adrp   x9, #0x30000
 0x2a8c: add    x10, x10, #0x710 ; =0x1e710
 0x2a90: ldr    x0, [x9, #0x10]
 0x2a94: ldr    w8, [x10, x8, lsl #2]
 0x2a98: str    w8, [x24, #0x3e0]
 0x2a9c: cbz    x0, #0x2ac4
 0x2aa0: adrp   x8, #0x30000
 0x2aa4: add    x8, x8, #0x10 ; =0x30010
 0x2aa8: add    x21, x8, #0x18 ; =0x30018
 0x2aac: ldur   x8, [x21, #-0x10]
 0x2ab0: mov    x1, x21
 0x2ab4: blr    x8
 0x2ab8: ldr    x0, [x21, #8]
 0x2abc: add    x21, x21, #0x20
 0x2ac0: cbnz   x0, #0x2aac
 0x2ac4: ldr    w9, [x20]
 0x2ac8: add    w11, w9, w19
 0x2acc: cmp    w11, #0x3b
 0x2ad0: b.hi   #0x3a48
 0x2ad4: mov    w8, #1
 0x2ad8: lsl    x8, x8, x11
 0x2adc: tst    x8, x26
 0x2ae0: b.eq   #0x3a48
 0x2ae4: ldr    w19, [x24, #0xb8]
 0x2ae8: cmp    w19, #0
 0x2aec: b.le   #0x3f68
 0x2af0: ldr    w21, [x24, #0xbc]
 0x2af4: cmp    w21, #0
 0x2af8: b.le   #0x3fcc
 0x2afc: ldr    w22, [x24, #0x1fc]
 0x2b00: cmp    w22, #1
 0x2b04: b.lt   #0x3aac
 0x2b08: cmp    w22, w19
 0x2b0c: b.lt   #0x3aac
 0x2b10: str    w9, [sp, #0x7c]
 0x2b14: adrp   x8, #0x12000
 0x2b18: adrp   x9, #0x12000
 0x2b1c: movi   v0.2d, #0000000000000000
 0x2b20: add    x8, x8, #0x1f8 ; =0x121f8
 0x2b24: stp    x24, x24, [sp, #0xb8]
 0x2b28: add    x9, x9, #0x9f8 ; =0x129f8
 0x2b2c: cmp    w11, #0x3b
 0x2b30: stp    x8, x9, [sp, #0xc8]
 0x2b34: mov    w8, #1
 0x2b38: mov    w9, #0x1000
 0x2b3c: stur   q0, [sp, #0xa8]
 0x2b40: stur   q0, [sp, #0xd8]
 0x2b44: strb   w8, [sp, #0xb0]
 0x2b48: strh   w19, [sp, #0xd8]
 0x2b4c: strh   w21, [sp, #0xda]
 0x2b50: str    wzr, [sp, #0xdc]
 0x2b54: strb   w8, [sp, #0xe1]
 0x2b58: str    w9, [sp, #0xe4]
 0x2b5c: b.hi   #0x3b10
 0x2b60: adrp   x9, #0x1a000
 0x2b64: add    x9, x9, #0x350 ; =0x1a350
 0x2b68: ldrsw  x10, [x9, x11, lsl #2]
 0x2b6c: add    x9, x10, x9
 0x2b70: br     x9
 0x2b74: mov    w8, wzr
 0x2b78: b      #0x2c78
 0x2b7c: adrp   x0, #0x30000
 0x2b80: adrp   x2, #0x1a000
 0x2b84: add    x0, x0, #8 ; =0x30008
 0x2b88: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x2b8c: mov    w1, #1
 0x2b90: bl     #0x2338 ; <log_mgr_check>
 0x2b94: tbz    w0, #0, #0x338c
 0x2b98: bl     #0x2348 ; <co_thread_get>
 0x2b9c: cbz    x0, #0x32f0
 0x2ba0: adrp   x8, #0x1a000
 0x2ba4: stur   wzr, [x29, #-0xe0]
 0x2ba8: add    x8, x8, #0x440 ; =0x1a440
 0x2bac: add    x1, sp, #0xa8
 0x2bb0: sub    x2, x29, #0xe0
 0x2bb4: str    x8, [sp, #0xa8]
 0x2bb8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x2bbc: adrp   x4, #0x1a000
 0x2bc0: adrp   x5, #0x1a000
 0x2bc4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2bc8: add    x5, x5, #0x4be ; "venc_eng_create"
 0x2bcc: mov    w0, #0x51
 0x2bd0: mov    w6, #0x67f
 0x2bd4: mov    w1, #1
 0x2bd8: sub    x2, x29, #0xd8
 0x2bdc: mov    w3, #0x80
 0x2be0: bl     #0x2368 ; <duss_log_gen_head>
 0x2be4: cbz    w0, #0x2c0c
 0x2be8: adrp   x3, #0x1a000
 0x2bec: adrp   x4, #0x1a000
 0x2bf0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x2bf4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2bf8: mov    w0, #0x51
 0x2bfc: mov    w5, #0x67f
 0x2c00: mov    w1, #1
 0x2c04: sub    x2, x29, #0xd8
 0x2c08: bl     #0x2378 ; <duss_log_print>
 0x2c0c: adrp   x4, #0x1a000
 0x2c10: adrp   x5, #0x1a000
 0x2c14: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2c18: add    x5, x5, #0x4be ; "venc_eng_create"
 0x2c1c: mov    w0, #0x51
 0x2c20: mov    w6, #0x67f
 0x2c24: mov    w1, #1
 0x2c28: sub    x2, x29, #0xd8
 0x2c2c: mov    w3, #0x80
 0x2c30: bl     #0x2368 ; <duss_log_gen_head>
 0x2c34: cbz    w0, #0x338c
 0x2c38: ldr    x6, [sp, #0xa8]
 0x2c3c: adrp   x3, #0x1a000
 0x2c40: ldur   w7, [x29, #-0xe0]
 0x2c44: adrp   x4, #0x1a000
 0x2c48: adrp   x5, #0x1a000
 0x2c4c: add    x3, x3, #0x5df ; "%s: %s(%s_%x): proresraw eng alloc mem fail
"
 0x2c50: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x2c54: add    x5, x5, #0x441 ; "co"
 0x2c58: mov    w0, #0x51
 0x2c5c: mov    w1, #1
 0x2c60: sub    x2, x29, #0xd8
 0x2c64: bl     #0x2378 ; <duss_log_print>
 0x2c68: b      #0x338c
 0x2c6c: mov    w8, #3
 0x2c70: b      #0x2c78
 0x2c74: mov    w8, #2
 0x2c78: add    x9, sp, #0xa8
 0x2c7c: str    x11, [sp, #0x80]
 0x2c80: add    x1, x9, #0x3a ; =0x1a03a
 0x2c84: str    x23, [sp, #0xa0]
 0x2c88: mov    x0, x20
 0x2c8c: strb   w8, [sp, #0xe0]
 0x2c90: bl     #0x2388 ; <proresraw_sensel_value_range_get>
 0x2c94: mov    w20, w0
 0x2c98: cbz    w20, #0x2e38
 0x2c9c: adrp   x0, #0x30000
 0x2ca0: adrp   x2, #0x1a000
 0x2ca4: add    x0, x0, #8 ; =0x30008
 0x2ca8: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x2cac: mov    w1, #1
 0x2cb0: bl     #0x2338 ; <log_mgr_check>
 0x2cb4: tbz    w0, #0, #0x2e30
 0x2cb8: bl     #0x2348 ; <co_thread_get>
 0x2cbc: cbz    x0, #0x2d90
 0x2cc0: adrp   x8, #0x1a000
 0x2cc4: stur   wzr, [x29, #-0xe4]
 0x2cc8: add    x8, x8, #0x440 ; =0x1a440
 0x2ccc: sub    x1, x29, #0xe0
 0x2cd0: sub    x2, x29, #0xe4
 0x2cd4: stur   x8, [x29, #-0xe0]
 0x2cd8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x2cdc: adrp   x4, #0x1a000
 0x2ce0: adrp   x5, #0x1d000
 0x2ce4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2ce8: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x2cec: mov    w0, #0x51
 0x2cf0: mov    w6, #0x61e
 0x2cf4: mov    w1, #1
 0x2cf8: sub    x2, x29, #0xd8
 0x2cfc: mov    w3, #0x80
 0x2d00: bl     #0x2368 ; <duss_log_gen_head>
 0x2d04: cbz    w0, #0x2d2c
 0x2d08: adrp   x3, #0x1a000
 0x2d0c: adrp   x4, #0x1a000
 0x2d10: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x2d14: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2d18: mov    w0, #0x51
 0x2d1c: mov    w5, #0x61e
 0x2d20: mov    w1, #1
 0x2d24: sub    x2, x29, #0xd8
 0x2d28: bl     #0x2378 ; <duss_log_print>
 0x2d2c: adrp   x4, #0x1a000
 0x2d30: adrp   x5, #0x1d000
 0x2d34: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2d38: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x2d3c: mov    w0, #0x51
 0x2d40: mov    w6, #0x61e
 0x2d44: mov    w1, #1
 0x2d48: sub    x2, x29, #0xd8
 0x2d4c: mov    w3, #0x80
 0x2d50: bl     #0x2368 ; <duss_log_gen_head>
 0x2d54: cbz    w0, #0x2e30
 0x2d58: ldur   x6, [x29, #-0xe0]
 0x2d5c: adrp   x3, #0x1d000
 0x2d60: ldur   w7, [x29, #-0xe4]
 0x2d64: adrp   x4, #0x1a000
 0x2d68: adrp   x5, #0x1a000
 0x2d6c: str    w20, [sp]
 0x2d70: add    x3, x3, #0x77 ; "%s: %s(%s_%x): proresraw_sensel_value_range_get failed:%d
"
 0x2d74: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x2d78: add    x5, x5, #0x441 ; "co"
 0x2d7c: mov    w0, #0x51
 0x2d80: mov    w1, #1
 0x2d84: sub    x2, x29, #0xd8
 0x2d88: bl     #0x2378 ; <duss_log_print>
 0x2d8c: b      #0x2e30
 0x2d90: adrp   x4, #0x1a000
 0x2d94: adrp   x5, #0x1d000
 0x2d98: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2d9c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x2da0: mov    w0, #0x51
 0x2da4: mov    w6, #0x61e
 0x2da8: mov    w1, #1
 0x2dac: sub    x2, x29, #0xd8
 0x2db0: mov    w3, #0x80
 0x2db4: bl     #0x2368 ; <duss_log_gen_head>
 0x2db8: cbz    w0, #0x2de0
 0x2dbc: adrp   x3, #0x1a000
 0x2dc0: adrp   x4, #0x1a000
 0x2dc4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x2dc8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2dcc: mov    w0, #0x51
 0x2dd0: mov    w5, #0x61e
 0x2dd4: mov    w1, #1
 0x2dd8: sub    x2, x29, #0xd8
 0x2ddc: bl     #0x2378 ; <duss_log_print>
 0x2de0: adrp   x4, #0x1a000
 0x2de4: adrp   x5, #0x1d000
 0x2de8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2dec: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x2df0: mov    w0, #0x51
 0x2df4: mov    w6, #0x61e
 0x2df8: mov    w1, #1
 0x2dfc: sub    x2, x29, #0xd8
 0x2e00: mov    w3, #0x80
 0x2e04: bl     #0x2368 ; <duss_log_gen_head>
 0x2e08: cbz    w0, #0x2e30
 0x2e0c: adrp   x3, #0x1d000
 0x2e10: adrp   x4, #0x1a000
 0x2e14: add    x3, x3, #0xb2 ; "%s: proresraw_sensel_value_range_get failed:%d
"
 0x2e18: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x2e1c: mov    w0, #0x51
 0x2e20: mov    w1, #1
 0x2e24: sub    x2, x29, #0xd8
 0x2e28: mov    w5, w20
 0x2e2c: bl     #0x2378 ; <duss_log_print>
 0x2e30: mov    w8, #0xfeff
 0x2e34: strh   w8, [sp, #0xe2]
 0x2e38: stp    x25, x24, [sp, #0x90]
 0x2e3c: add    x23, x24, #0xa0
 0x2e40: adrp   x24, #0x30000
 0x2e44: stp    w21, w19, [sp, #0x88]
 0x2e48: adrp   x25, #0x1a000
 0x2e4c: str    w22, [sp, #0x78]
 0x2e50: adrp   x27, #0x1a000
 0x2e54: adrp   x28, #0x1d000
 0x2e58: mov    x19, xzr
 0x2e5c: add    x24, x24, #8 ; =0x30008
 0x2e60: add    x25, x25, #0x5c4 ; "PRORESRAW"
 0x2e64: mov    w26, #5
 0x2e68: add    x27, x27, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x2e6c: add    x28, x28, #0 ; "_proresraw_venc_eng_open_device"
 0x2e70: mov    w21, #0x51
 0x2e74: mov    x0, x24
 0x2e78: mov    w1, w26
 0x2e7c: mov    x2, x25
 0x2e80: bl     #0x2338 ; <log_mgr_check>
 0x2e84: tbz    w0, #0, #0x2f40
 0x2e88: bl     #0x2348 ; <co_thread_get>
 0x2e8c: cbz    x0, #0x2f00
 0x2e90: adrp   x8, #0x1a000
 0x2e94: stur   wzr, [x29, #-0xe4]
 0x2e98: add    x8, x8, #0x440 ; =0x1a440
 0x2e9c: sub    x1, x29, #0xe0
 0x2ea0: sub    x2, x29, #0xe4
 0x2ea4: stur   x8, [x29, #-0xe0]
 0x2ea8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x2eac: mov    w1, #3
 0x2eb0: sub    x2, x29, #0xd8
 0x2eb4: mov    w3, #0x80
 0x2eb8: mov    w0, w21
 0x2ebc: mov    x4, x27
 0x2ec0: mov    x5, x28
 0x2ec4: mov    w6, #0x623
 0x2ec8: bl     #0x2368 ; <duss_log_gen_head>
 0x2ecc: cbz    w0, #0x2f40
 0x2ed0: ldur   x6, [x29, #-0xe0]
 0x2ed4: adrp   x3, #0x1d000
 0x2ed8: ldur   w7, [x29, #-0xe4]
 0x2edc: adrp   x5, #0x1a000
 0x2ee0: mov    w1, #3
 0x2ee4: sub    x2, x29, #0xd8
 0x2ee8: mov    w0, w21
 0x2eec: add    x3, x3, #0xe2 ; "%s: %s(%s_%x): before duss_hal_device_open
"
 0x2ef0: mov    x4, x25
 0x2ef4: add    x5, x5, #0x441 ; "co"
 0x2ef8: bl     #0x2378 ; <duss_log_print>
 0x2efc: b      #0x2f40
 0x2f00: mov    w1, #3
 0x2f04: sub    x2, x29, #0xd8
 0x2f08: mov    w3, #0x80
 0x2f0c: mov    w0, w21
 0x2f10: mov    x4, x27
 0x2f14: mov    x5, x28
 0x2f18: mov    w6, #0x623
 0x2f1c: bl     #0x2368 ; <duss_log_gen_head>
 0x2f20: cbz    w0, #0x2f40
 0x2f24: adrp   x3, #0x1d000
 0x2f28: mov    w1, #3
 0x2f2c: sub    x2, x29, #0xd8
 0x2f30: mov    w0, w21
 0x2f34: add    x3, x3, #0x10e ; "%s: before duss_hal_device_open
"
 0x2f38: mov    x4, x25
 0x2f3c: bl     #0x2378 ; <duss_log_print>
 0x2f40: adrp   x8, #0x2f000
 0x2f44: add    x8, x8, #0xa68 ; =0x2fa68
 0x2f48: add    x1, sp, #0xa8
 0x2f4c: mov    x2, x23
 0x2f50: ldr    x22, [x8, x19, lsl #3]
 0x2f54: mov    x0, x22
 0x2f58: bl     #0x2398 ; <duss_hal_device_open>
 0x2f5c: mov    w20, w0
 0x2f60: mov    x0, x24
 0x2f64: mov    w1, w26
 0x2f68: mov    x2, x25
 0x2f6c: bl     #0x2338 ; <log_mgr_check>
 0x2f70: tbz    w0, #0, #0x3030
 0x2f74: bl     #0x2348 ; <co_thread_get>
 0x2f78: cbz    x0, #0x2ff0
 0x2f7c: adrp   x8, #0x1a000
 0x2f80: stur   wzr, [x29, #-0xe4]
 0x2f84: add    x8, x8, #0x440 ; =0x1a440
 0x2f88: sub    x1, x29, #0xe0
 0x2f8c: sub    x2, x29, #0xe4
 0x2f90: stur   x8, [x29, #-0xe0]
 0x2f94: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x2f98: mov    w1, #3
 0x2f9c: sub    x2, x29, #0xd8
 0x2fa0: mov    w3, #0x80
 0x2fa4: mov    w0, w21
 0x2fa8: mov    x4, x27
 0x2fac: mov    x5, x28
 0x2fb0: mov    w6, #0x625
 0x2fb4: bl     #0x2368 ; <duss_log_gen_head>
 0x2fb8: cbz    w0, #0x3030
 0x2fbc: ldur   x6, [x29, #-0xe0]
 0x2fc0: adrp   x3, #0x1d000
 0x2fc4: ldur   w7, [x29, #-0xe4]
 0x2fc8: adrp   x5, #0x1a000
 0x2fcc: mov    w1, #3
 0x2fd0: sub    x2, x29, #0xd8
 0x2fd4: mov    w0, w21
 0x2fd8: add    x3, x3, #0x12f ; "%s: %s(%s_%x): after duss_hal_device_open
"
 0x2fdc: mov    x4, x25
 0x2fe0: add    x5, x5, #0x441 ; "co"
 0x2fe4: bl     #0x2378 ; <duss_log_print>
 0x2fe8: cbnz   w20, #0x3034
 0x2fec: b      #0x3230
 0x2ff0: mov    w1, #3
 0x2ff4: sub    x2, x29, #0xd8
 0x2ff8: mov    w3, #0x80
 0x2ffc: mov    w0, w21
 0x3000: mov    x4, x27
 0x3004: mov    x5, x28
 0x3008: mov    w6, #0x625
 0x300c: bl     #0x2368 ; <duss_log_gen_head>
 0x3010: cbz    w0, #0x3030
 0x3014: adrp   x3, #0x1d000
 0x3018: mov    w1, #3
 0x301c: sub    x2, x29, #0xd8
 0x3020: mov    w0, w21
 0x3024: add    x3, x3, #0x15a ; "%s: after duss_hal_device_open
"
 0x3028: mov    x4, x25
 0x302c: bl     #0x2378 ; <duss_log_print>
 0x3030: cbz    w20, #0x3230
 0x3034: mov    w1, #2
 0x3038: mov    x0, x24
 0x303c: mov    x2, x25
 0x3040: bl     #0x2338 ; <log_mgr_check>
 0x3044: tbz    w0, #0, #0x3118
 0x3048: bl     #0x2348 ; <co_thread_get>
 0x304c: cbz    x0, #0x30d0
 0x3050: adrp   x8, #0x1a000
 0x3054: stur   wzr, [x29, #-0xe4]
 0x3058: add    x8, x8, #0x440 ; =0x1a440
 0x305c: sub    x1, x29, #0xe0
 0x3060: sub    x2, x29, #0xe4
 0x3064: stur   x8, [x29, #-0xe0]
 0x3068: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x306c: mov    w1, #2
 0x3070: sub    x2, x29, #0xd8
 0x3074: mov    w3, #0x80
 0x3078: mov    w0, w21
 0x307c: mov    x4, x27
 0x3080: mov    x5, x28
 0x3084: mov    w6, #0x62b
 0x3088: bl     #0x2368 ; <duss_log_gen_head>
 0x308c: cbz    w0, #0x3118
 0x3090: ldur   x6, [x29, #-0xe0]
 0x3094: adrp   x3, #0x1d000
 0x3098: ldur   w7, [x29, #-0xe4]
 0x309c: adrp   x5, #0x1a000
 0x30a0: mov    w1, #2
 0x30a4: str    w20, [sp, #8]
 0x30a8: sub    x2, x29, #0xd8
 0x30ac: str    x22, [sp]
 0x30b0: mov    w0, w21
 0x30b4: add    x3, x3, #0x1d1 ; "%s: %s(%s_%x): duss_hal_device_open(%s) failed[%d].
"
 0x30b8: mov    x4, x25
 0x30bc: add    x5, x5, #0x441 ; "co"
 0x30c0: bl     #0x2378 ; <duss_log_print>
 0x30c4: cmn    w20, #0x3ec
 0x30c8: b.eq   #0x3120
 0x30cc: b      #0x312c
 0x30d0: mov    w1, #2
 0x30d4: sub    x2, x29, #0xd8
 0x30d8: mov    w3, #0x80
 0x30dc: mov    w0, w21
 0x30e0: mov    x4, x27
 0x30e4: mov    x5, x28
 0x30e8: mov    w6, #0x62b
 0x30ec: bl     #0x2368 ; <duss_log_gen_head>
 0x30f0: cbz    w0, #0x3118
 0x30f4: adrp   x3, #0x1d000
 0x30f8: mov    w1, #2
 0x30fc: sub    x2, x29, #0xd8
 0x3100: mov    w0, w21
 0x3104: add    x3, x3, #0x206 ; "%s: duss_hal_device_open(%s) failed[%d].
"
 0x3108: mov    x4, x25
 0x310c: mov    x5, x22
 0x3110: mov    w6, w20
 0x3114: bl     #0x2378 ; <duss_log_print>
 0x3118: cmn    w20, #0x3ec
 0x311c: b.ne   #0x312c
 0x3120: ldr    x0, [x23]
 0x3124: bl     #0x23a8 ; <duss_hal_device_close>
 0x3128: str    xzr, [x23]
 0x312c: add    x8, x19, #1
 0x3130: mov    w19, #1
 0x3134: cmp    x8, #2
 0x3138: b.lo   #0x2e74
 0x313c: adrp   x0, #0x30000
 0x3140: adrp   x2, #0x1a000
 0x3144: add    x0, x0, #8 ; =0x30008
 0x3148: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x314c: mov    w1, #1
 0x3150: bl     #0x2338 ; <log_mgr_check>
 0x3154: ldp    x19, x23, [sp, #0x98]
 0x3158: tbz    w0, #0, #0x3810
 0x315c: bl     #0x2348 ; <co_thread_get>
 0x3160: cbz    x0, #0x3774
 0x3164: adrp   x8, #0x1a000
 0x3168: stur   wzr, [x29, #-0xe4]
 0x316c: add    x8, x8, #0x440 ; =0x1a440
 0x3170: sub    x1, x29, #0xe0
 0x3174: sub    x2, x29, #0xe4
 0x3178: stur   x8, [x29, #-0xe0]
 0x317c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x3180: adrp   x4, #0x1a000
 0x3184: adrp   x5, #0x1d000
 0x3188: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x318c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3190: mov    w0, #0x51
 0x3194: mov    w6, #0x633
 0x3198: mov    w1, #1
 0x319c: sub    x2, x29, #0xd8
 0x31a0: mov    w3, #0x80
 0x31a4: bl     #0x2368 ; <duss_log_gen_head>
 0x31a8: cbz    w0, #0x31d0
 0x31ac: adrp   x3, #0x1a000
 0x31b0: adrp   x4, #0x1a000
 0x31b4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x31b8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x31bc: mov    w0, #0x51
 0x31c0: mov    w5, #0x633
 0x31c4: mov    w1, #1
 0x31c8: sub    x2, x29, #0xd8
 0x31cc: bl     #0x2378 ; <duss_log_print>
 0x31d0: adrp   x4, #0x1a000
 0x31d4: adrp   x5, #0x1d000
 0x31d8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x31dc: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x31e0: mov    w0, #0x51
 0x31e4: mov    w6, #0x633
 0x31e8: mov    w1, #1
 0x31ec: sub    x2, x29, #0xd8
 0x31f0: mov    w3, #0x80
 0x31f4: bl     #0x2368 ; <duss_log_gen_head>
 0x31f8: cbz    w0, #0x3810
 0x31fc: ldur   x6, [x29, #-0xe0]
 0x3200: adrp   x3, #0x1d000
 0x3204: ldur   w7, [x29, #-0xe4]
 0x3208: adrp   x4, #0x1a000
 0x320c: adrp   x5, #0x1a000
 0x3210: add    x3, x3, #0x230 ; "%s: %s(%s_%x): no video encoding device available.
"
 0x3214: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3218: add    x5, x5, #0x441 ; "co"
 0x321c: mov    w0, #0x51
 0x3220: mov    w1, #1
 0x3224: sub    x2, x29, #0xd8
 0x3228: bl     #0x2378 ; <duss_log_print>
 0x322c: b      #0x3810
 0x3230: adrp   x0, #0x30000
 0x3234: adrp   x2, #0x1a000
 0x3238: add    x0, x0, #8 ; =0x30008
 0x323c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x3240: mov    w1, #3
 0x3244: bl     #0x2338 ; <log_mgr_check>
 0x3248: mov    x20, #0xc411
 0x324c: ldr    x24, [sp, #0x90]
 0x3250: movk   x20, #0x6208, lsl #16
 0x3254: ldp    x19, x23, [sp, #0x98]
 0x3258: ldp    w26, w25, [sp, #0x88]
 0x325c: movk   x20, #0x3104, lsl #32
 0x3260: movk   x20, #0x882, lsl #48
 0x3264: tbz    w0, #0, #0x33e4
 0x3268: bl     #0x2348 ; <co_thread_get>
 0x326c: cbz    x0, #0x3394
 0x3270: adrp   x8, #0x1a000
 0x3274: stur   wzr, [x29, #-0xe4]
 0x3278: add    x8, x8, #0x440 ; =0x1a440
 0x327c: sub    x1, x29, #0xe0
 0x3280: sub    x2, x29, #0xe4
 0x3284: stur   x8, [x29, #-0xe0]
 0x3288: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x328c: adrp   x4, #0x1a000
 0x3290: adrp   x5, #0x1d000
 0x3294: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3298: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x329c: mov    w0, #0x51
 0x32a0: mov    w6, #0x627
 0x32a4: mov    w1, #3
 0x32a8: sub    x2, x29, #0xd8
 0x32ac: mov    w3, #0x80
 0x32b0: bl     #0x2368 ; <duss_log_gen_head>
 0x32b4: cbz    w0, #0x33e4
 0x32b8: ldur   x6, [x29, #-0xe0]
 0x32bc: adrp   x3, #0x1d000
 0x32c0: ldur   w7, [x29, #-0xe4]
 0x32c4: adrp   x4, #0x1a000
 0x32c8: adrp   x5, #0x1a000
 0x32cc: str    x22, [sp]
 0x32d0: add    x3, x3, #0x17a ; "%s: %s(%s_%x): duss_hal_device_open(%s) success
"
 0x32d4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x32d8: add    x5, x5, #0x441 ; "co"
 0x32dc: mov    w0, #0x51
 0x32e0: mov    w1, #3
 0x32e4: sub    x2, x29, #0xd8
 0x32e8: bl     #0x2378 ; <duss_log_print>
 0x32ec: b      #0x33e4
 0x32f0: adrp   x4, #0x1a000
 0x32f4: adrp   x5, #0x1a000
 0x32f8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x32fc: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3300: mov    w0, #0x51
 0x3304: mov    w6, #0x67f
 0x3308: mov    w1, #1
 0x330c: sub    x2, x29, #0xd8
 0x3310: mov    w3, #0x80
 0x3314: bl     #0x2368 ; <duss_log_gen_head>
 0x3318: cbz    w0, #0x3340
 0x331c: adrp   x3, #0x1a000
 0x3320: adrp   x4, #0x1a000
 0x3324: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x3328: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x332c: mov    w0, #0x51
 0x3330: mov    w5, #0x67f
 0x3334: mov    w1, #1
 0x3338: sub    x2, x29, #0xd8
 0x333c: bl     #0x2378 ; <duss_log_print>
 0x3340: adrp   x4, #0x1a000
 0x3344: adrp   x5, #0x1a000
 0x3348: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x334c: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3350: mov    w0, #0x51
 0x3354: mov    w6, #0x67f
 0x3358: mov    w1, #1
 0x335c: sub    x2, x29, #0xd8
 0x3360: mov    w3, #0x80
 0x3364: bl     #0x2368 ; <duss_log_gen_head>
 0x3368: cbz    w0, #0x338c
 0x336c: adrp   x3, #0x1a000
 0x3370: adrp   x4, #0x1a000
 0x3374: add    x3, x3, #0x60c ; "%s: proresraw eng alloc mem fail
"
 0x3378: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x337c: mov    w0, #0x51
 0x3380: mov    w1, #1
 0x3384: sub    x2, x29, #0xd8
 0x3388: bl     #0x2378 ; <duss_log_print>
 0x338c: mov    w0, #-0x3ee
 0x3390: b      #0x39b4
 0x3394: adrp   x4, #0x1a000
 0x3398: adrp   x5, #0x1d000
 0x339c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x33a0: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x33a4: mov    w0, #0x51
 0x33a8: mov    w6, #0x627
 0x33ac: mov    w1, #3
 0x33b0: sub    x2, x29, #0xd8
 0x33b4: mov    w3, #0x80
 0x33b8: bl     #0x2368 ; <duss_log_gen_head>
 0x33bc: cbz    w0, #0x33e4
 0x33c0: adrp   x3, #0x1d000
 0x33c4: adrp   x4, #0x1a000
 0x33c8: add    x3, x3, #0x1ab ; "%s: duss_hal_device_open(%s) success
"
 0x33cc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x33d0: mov    w0, #0x51
 0x33d4: mov    w1, #3
 0x33d8: sub    x2, x29, #0xd8
 0x33dc: mov    x5, x22
 0x33e0: bl     #0x2378 ; <duss_log_print>
 0x33e4: ldr    x9, [sp, #0x80]
 0x33e8: cmp    w9, #0x3b
 0x33ec: b.hi   #0x3d48
 0x33f0: mov    w8, #1
 0x33f4: lsl    x8, x8, x9
 0x33f8: tst    x8, x20
 0x33fc: b.eq   #0x3d48
 0x3400: cmp    w9, #0x3b
 0x3404: b.hi   #0x3dac
 0x3408: mov    w8, #1
 0x340c: lsl    x8, x8, x9
 0x3410: tst    x8, x20
 0x3414: b.eq   #0x3dac
 0x3418: mul    w8, w26, w25
 0x341c: adrp   x9, #0x1a000
 0x3420: ldr    d1, [x9, #0x198]
 0x3424: scvtf  d0, w8
 0x3428: fmul   d0, d0, d1
 0x342c: fcvtzu w8, d0
 0x3430: cmp    w8, #0
 0x3434: str    w8, [x19, #0x3d0]
 0x3438: b.le   #0x4408
 0x343c: cmp    w25, #0
 0x3440: cinc   w8, w25, lt
 0x3444: asr    w8, w8, #1
 0x3448: add    w9, w8, #0x7f
 0x344c: add    w8, w8, #0xfe
 0x3450: cmp    w9, #0
 0x3454: csel   w8, w8, w9, lt
 0x3458: cmp    w26, #0
 0x345c: cinc   w9, w26, lt
 0x3460: asr    w9, w9, #1
 0x3464: add    w10, w9, #7
 0x3468: add    w9, w9, #0xe
 0x346c: cmp    w10, #0
 0x3470: csel   w9, w9, w10, lt
 0x3474: ldr    w10, [x19, #0x2f0]
 0x3478: asr    w8, w8, #7
 0x347c: asr    w9, w9, #3
 0x3480: mul    w8, w9, w8
 0x3484: cmp    w10, #0
 0x3488: lsl    w9, w8, #2
 0x348c: lsl    w8, w8, #4
 0x3490: add    w8, w8, #0xff
 0x3494: str    w9, [x19, #0x3e4]
 0x3498: and    w8, w8, #0xffffff00
 0x349c: str    w8, [x19, #0x3e8]
 0x34a0: b.le   #0x446c
 0x34a4: ldr    w8, [x19, #0x2f4]
 0x34a8: cmp    w8, #0
 0x34ac: b.le   #0x44d0
 0x34b0: adrp   x0, #0x30000
 0x34b4: adrp   x2, #0x1a000
 0x34b8: add    x0, x0, #8 ; =0x30008
 0x34bc: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x34c0: mov    w1, #3
 0x34c4: bl     #0x2338 ; <log_mgr_check>
 0x34c8: tbz    w0, #0, #0x3650
 0x34cc: bl     #0x2348 ; <co_thread_get>
 0x34d0: cbz    x0, #0x35ac
 0x34d4: adrp   x8, #0x1a000
 0x34d8: stur   wzr, [x29, #-0xe4]
 0x34dc: add    x8, x8, #0x440 ; =0x1a440
 0x34e0: sub    x1, x29, #0xe0
 0x34e4: sub    x2, x29, #0xe4
 0x34e8: stur   x8, [x29, #-0xe0]
 0x34ec: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x34f0: adrp   x20, #0x1d000
 0x34f4: adrp   x4, #0x1a000
 0x34f8: add    x20, x20, #0 ; "_proresraw_venc_eng_open_device"
 0x34fc: mov    w21, #0x64c
 0x3500: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3504: mov    w0, #0x51
 0x3508: mov    w1, #3
 0x350c: sub    x2, x29, #0xd8
 0x3510: mov    w3, #0x80
 0x3514: mov    x5, x20
 0x3518: mov    w6, w21
 0x351c: bl     #0x2368 ; <duss_log_gen_head>
 0x3520: cbz    w0, #0x3650
 0x3524: ldr    w8, [x19, #0x3d0]
 0x3528: adrp   x3, #0x1d000
 0x352c: ldr    w9, [x19, #0x3e4]
 0x3530: adrp   x4, #0x1a000
 0x3534: ldr    w10, [x19, #0x3e8]
 0x3538: adrp   x5, #0x1a000
 0x353c: ldr    w11, [x19, #0x2f0]
 0x3540: add    x3, x3, #0x2e3 ; "%s: %s(%s_%x): %s (%d), device %s opened, pixel_format: %d, %dx%d, stride: %d, suggested_s"
 0x3544: ldr    w12, [x19, #0x2f4]
 0x3548: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x354c: ldr    x13, [x19, #0x3d8]
 0x3550: add    x5, x5, #0x441 ; "co"
 0x3554: str    w8, [sp, #0x38]
 0x3558: mov    w0, #0x51
 0x355c: ldr    w8, [sp, #0x78]
 0x3560: mov    w1, #3
 0x3564: ldur   x6, [x29, #-0xe0]
 0x3568: sub    x2, x29, #0xd8
 0x356c: ldur   w7, [x29, #-0xe4]
 0x3570: str    x13, [sp, #0x60]
 0x3574: str    w8, [sp, #0x30]
 0x3578: ldr    w8, [sp, #0x7c]
 0x357c: str    w12, [sp, #0x58]
 0x3580: str    w11, [sp, #0x50]
 0x3584: str    w10, [sp, #0x48]
 0x3588: str    w9, [sp, #0x40]
 0x358c: str    w26, [sp, #0x28]
 0x3590: str    w25, [sp, #0x20]
 0x3594: str    w8, [sp, #0x18]
 0x3598: str    x22, [sp, #0x10]
 0x359c: str    w21, [sp, #8]
 0x35a0: str    x20, [sp]
 0x35a4: bl     #0x2378 ; <duss_log_print>
 0x35a8: b      #0x3650
 0x35ac: adrp   x4, #0x1a000
 0x35b0: adrp   x5, #0x1d000
 0x35b4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x35b8: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x35bc: mov    w0, #0x51
 0x35c0: mov    w6, #0x64c
 0x35c4: mov    w1, #3
 0x35c8: sub    x2, x29, #0xd8
 0x35cc: mov    w3, #0x80
 0x35d0: bl     #0x2368 ; <duss_log_gen_head>
 0x35d4: cbz    w0, #0x3650
 0x35d8: ldr    w8, [x19, #0x3d0]
 0x35dc: adrp   x3, #0x1d000
 0x35e0: ldr    w9, [x19, #0x3e4]
 0x35e4: adrp   x4, #0x1a000
 0x35e8: ldr    w10, [x19, #0x3e8]
 0x35ec: adrp   x5, #0x1d000
 0x35f0: ldr    w11, [x19, #0x2f0]
 0x35f4: add    x3, x3, #0x392 ; "%s: %s (%d), device %s opened, pixel_format: %d, %dx%d, stride: %d, suggested_stream_buf_s"
 0x35f8: ldr    w12, [x19, #0x2f4]
 0x35fc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3600: ldr    x13, [x19, #0x3d8]
 0x3604: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3608: str    w8, [sp, #0x20]
 0x360c: mov    w0, #0x51
 0x3610: ldr    w8, [sp, #0x78]
 0x3614: mov    w6, #0x64c
 0x3618: mov    w1, #3
 0x361c: str    w12, [sp, #0x40]
 0x3620: sub    x2, x29, #0xd8
 0x3624: str    x13, [sp, #0x48]
 0x3628: mov    x7, x22
 0x362c: str    w11, [sp, #0x38]
 0x3630: str    w8, [sp, #0x18]
 0x3634: ldr    w8, [sp, #0x7c]
 0x3638: str    w10, [sp, #0x30]
 0x363c: str    w9, [sp, #0x28]
 0x3640: str    w26, [sp, #0x10]
 0x3644: str    w25, [sp, #8]
 0x3648: str    w8, [sp]
 0x364c: bl     #0x2378 ; <duss_log_print>
 0x3650: add    x20, x19, #0x488
 0x3654: adrp   x8, #0x1a000
 0x3658: add    x8, x8, #0x775 ; "allocator_available"
 0x365c: add    x0, sp, #0xa8
 0x3660: mov    x1, x20
 0x3664: str    x8, [sp, #0xa8]
 0x3668: bl     #0x23b8 ; <duss_osal_event_create>
 0x366c: cbnz   w0, #0x4534
 0x3670: ldr    x0, [x20]
 0x3674: mov    w1, #1
 0x3678: bl     #0x23c8 ; <duss_osal_event_clear>
 0x367c: adrp   x0, #0x30000
 0x3680: adrp   x2, #0x1a000
 0x3684: add    x0, x0, #8 ; =0x30008
 0x3688: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x368c: mov    w1, #3
 0x3690: bl     #0x2338 ; <log_mgr_check>
 0x3694: tbz    w0, #0, #0x3768
 0x3698: bl     #0x2348 ; <co_thread_get>
 0x369c: cbz    x0, #0x371c
 0x36a0: adrp   x8, #0x1a000
 0x36a4: stur   wzr, [x29, #-0xe4]
 0x36a8: add    x8, x8, #0x440 ; =0x1a440
 0x36ac: sub    x1, x29, #0xe0
 0x36b0: sub    x2, x29, #0xe4
 0x36b4: stur   x8, [x29, #-0xe0]
 0x36b8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x36bc: adrp   x4, #0x1a000
 0x36c0: adrp   x5, #0x1a000
 0x36c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x36c8: add    x5, x5, #0x4be ; "venc_eng_create"
 0x36cc: mov    w0, #0x51
 0x36d0: mov    w6, #0x6b7
 0x36d4: mov    w1, #3
 0x36d8: sub    x2, x29, #0xd8
 0x36dc: mov    w3, #0x80
 0x36e0: bl     #0x2368 ; <duss_log_gen_head>
 0x36e4: cbz    w0, #0x3768
 0x36e8: ldur   x6, [x29, #-0xe0]
 0x36ec: adrp   x3, #0x1a000
 0x36f0: ldur   w7, [x29, #-0xe4]
 0x36f4: adrp   x4, #0x1a000
 0x36f8: adrp   x5, #0x1a000
 0x36fc: add    x3, x3, #0x7a4 ; "%s: %s(%s_%x): proresraw venc eng create success
"
 0x3700: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3704: add    x5, x5, #0x441 ; "co"
 0x3708: mov    w0, #0x51
 0x370c: mov    w1, #3
 0x3710: sub    x2, x29, #0xd8
 0x3714: bl     #0x2378 ; <duss_log_print>
 0x3718: b      #0x3768
 0x371c: adrp   x4, #0x1a000
 0x3720: adrp   x5, #0x1a000
 0x3724: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3728: add    x5, x5, #0x4be ; "venc_eng_create"
 0x372c: mov    w0, #0x51
 0x3730: mov    w6, #0x6b7
 0x3734: mov    w1, #3
 0x3738: sub    x2, x29, #0xd8
 0x373c: mov    w3, #0x80
 0x3740: bl     #0x2368 ; <duss_log_gen_head>
 0x3744: cbz    w0, #0x3768
 0x3748: adrp   x3, #0x1a000
 0x374c: adrp   x4, #0x1a000
 0x3750: add    x3, x3, #0x7d6 ; "%s: proresraw venc eng create success
"
 0x3754: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3758: mov    w0, #0x51
 0x375c: mov    w1, #3
 0x3760: sub    x2, x29, #0xd8
 0x3764: bl     #0x2378 ; <duss_log_print>
 0x3768: mov    w0, wzr
 0x376c: str    x19, [x24]
 0x3770: b      #0x39b4
 0x3774: adrp   x4, #0x1a000
 0x3778: adrp   x5, #0x1d000
 0x377c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3780: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3784: mov    w0, #0x51
 0x3788: mov    w6, #0x633
 0x378c: mov    w1, #1
 0x3790: sub    x2, x29, #0xd8
 0x3794: mov    w3, #0x80
 0x3798: bl     #0x2368 ; <duss_log_gen_head>
 0x379c: cbz    w0, #0x37c4
 0x37a0: adrp   x3, #0x1a000
 0x37a4: adrp   x4, #0x1a000
 0x37a8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x37ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x37b0: mov    w0, #0x51
 0x37b4: mov    w5, #0x633
 0x37b8: mov    w1, #1
 0x37bc: sub    x2, x29, #0xd8
 0x37c0: bl     #0x2378 ; <duss_log_print>
 0x37c4: adrp   x4, #0x1a000
 0x37c8: adrp   x5, #0x1d000
 0x37cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x37d0: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x37d4: mov    w0, #0x51
 0x37d8: mov    w6, #0x633
 0x37dc: mov    w1, #1
 0x37e0: sub    x2, x29, #0xd8
 0x37e4: mov    w3, #0x80
 0x37e8: bl     #0x2368 ; <duss_log_gen_head>
 0x37ec: cbz    w0, #0x3810
 0x37f0: adrp   x3, #0x1d000
 0x37f4: adrp   x4, #0x1a000
 0x37f8: add    x3, x3, #0x264 ; "%s: no video encoding device available.
"
 0x37fc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3800: mov    w0, #0x51
 0x3804: mov    w1, #1
 0x3808: sub    x2, x29, #0xd8
 0x380c: bl     #0x2378 ; <duss_log_print>
 0x3810: adrp   x0, #0x30000
 0x3814: adrp   x2, #0x1a000
 0x3818: add    x0, x0, #8 ; =0x30008
 0x381c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x3820: mov    w1, #1
 0x3824: bl     #0x2338 ; <log_mgr_check>
 0x3828: tbz    w0, #0, #0x39a8
 0x382c: bl     #0x2348 ; <co_thread_get>
 0x3830: cbz    x0, #0x3908
 0x3834: adrp   x8, #0x1a000
 0x3838: stur   wzr, [x29, #-0xe0]
 0x383c: add    x8, x8, #0x440 ; =0x1a440
 0x3840: add    x1, sp, #0xa8
 0x3844: sub    x2, x29, #0xe0
 0x3848: str    x8, [sp, #0xa8]
 0x384c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x3850: adrp   x4, #0x1a000
 0x3854: adrp   x5, #0x1a000
 0x3858: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x385c: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3860: mov    w0, #0x51
 0x3864: mov    w6, #0x6ad
 0x3868: mov    w1, #1
 0x386c: sub    x2, x29, #0xd8
 0x3870: mov    w3, #0x80
 0x3874: bl     #0x2368 ; <duss_log_gen_head>
 0x3878: cbz    w0, #0x38a0
 0x387c: adrp   x3, #0x1a000
 0x3880: adrp   x4, #0x1a000
 0x3884: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x3888: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x388c: mov    w0, #0x51
 0x3890: mov    w5, #0x6ad
 0x3894: mov    w1, #1
 0x3898: sub    x2, x29, #0xd8
 0x389c: bl     #0x2378 ; <duss_log_print>
 0x38a0: adrp   x4, #0x1a000
 0x38a4: adrp   x5, #0x1a000
 0x38a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x38ac: add    x5, x5, #0x4be ; "venc_eng_create"
 0x38b0: mov    w0, #0x51
 0x38b4: mov    w6, #0x6ad
 0x38b8: mov    w1, #1
 0x38bc: sub    x2, x29, #0xd8
 0x38c0: mov    w3, #0x80
 0x38c4: bl     #0x2368 ; <duss_log_gen_head>
 0x38c8: cbz    w0, #0x39a8
 0x38cc: ldr    x6, [sp, #0xa8]
 0x38d0: adrp   x3, #0x1a000
 0x38d4: ldur   w7, [x29, #-0xe0]
 0x38d8: adrp   x4, #0x1a000
 0x38dc: adrp   x5, #0x1a000
 0x38e0: mov    w8, #-0x3ef
 0x38e4: add    x3, x3, #0x71c ; "%s: %s(%s_%x): _proresraw_venc_eng_open fail, %d
"
 0x38e8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x38ec: add    x5, x5, #0x441 ; "co"
 0x38f0: str    w8, [sp]
 0x38f4: mov    w0, #0x51
 0x38f8: mov    w1, #1
 0x38fc: sub    x2, x29, #0xd8
 0x3900: bl     #0x2378 ; <duss_log_print>
 0x3904: b      #0x39a8
 0x3908: adrp   x4, #0x1a000
 0x390c: adrp   x5, #0x1a000
 0x3910: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3914: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3918: mov    w0, #0x51
 0x391c: mov    w6, #0x6ad
 0x3920: mov    w1, #1
 0x3924: sub    x2, x29, #0xd8
 0x3928: mov    w3, #0x80
 0x392c: bl     #0x2368 ; <duss_log_gen_head>
 0x3930: cbz    w0, #0x3958
 0x3934: adrp   x3, #0x1a000
 0x3938: adrp   x4, #0x1a000
 0x393c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x3940: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3944: mov    w0, #0x51
 0x3948: mov    w5, #0x6ad
 0x394c: mov    w1, #1
 0x3950: sub    x2, x29, #0xd8
 0x3954: bl     #0x2378 ; <duss_log_print>
 0x3958: adrp   x4, #0x1a000
 0x395c: adrp   x5, #0x1a000
 0x3960: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3964: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3968: mov    w0, #0x51
 0x396c: mov    w6, #0x6ad
 0x3970: mov    w1, #1
 0x3974: sub    x2, x29, #0xd8
 0x3978: mov    w3, #0x80
 0x397c: bl     #0x2368 ; <duss_log_gen_head>
 0x3980: cbz    w0, #0x39a8
 0x3984: adrp   x3, #0x1a000
 0x3988: adrp   x4, #0x1a000
 0x398c: add    x3, x3, #0x74e ; "%s: _proresraw_venc_eng_open fail, %d
"
 0x3990: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3994: mov    w0, #0x51
 0x3998: mov    w5, #-0x3ef
 0x399c: mov    w1, #1
 0x39a0: sub    x2, x29, #0xd8
 0x39a4: bl     #0x2378 ; <duss_log_print>
 0x39a8: mov    x0, x19
 0x39ac: bl     #0xe478
 0x39b0: mov    w0, #-0x3ef
 0x39b4: ldr    x8, [x23, #0x28]
 0x39b8: ldur   x9, [x29, #-0x58]
 0x39bc: cmp    x8, x9
 0x39c0: b.ne   #0x3ca0
 0x39c4: ldp    x29, x30, [sp, #0x1d0]
 0x39c8: ldp    x20, x19, [sp, #0x1c0]
 0x39cc: ldp    x22, x21, [sp, #0x1b0]
 0x39d0: ldp    x24, x23, [sp, #0x1a0]
 0x39d4: ldp    x26, x25, [sp, #0x190]
 0x39d8: ldp    x28, x27, [sp, #0x180]
 0x39dc: add    sp, sp, #0x1e0
 0x39e0: ret    
 0x39e4: bl     #0x2348 ; <co_thread_get>
 0x39e8: cbnz   x0, #0x3ca4
 0x39ec: adrp   x4, #0x1a000
 0x39f0: adrp   x5, #0x1a000
 0x39f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x39f8: add    x5, x5, #0x4be ; "venc_eng_create"
 0x39fc: mov    w0, #0x51
 0x3a00: mov    w6, #0x67a
 0x3a04: sub    x2, x29, #0xd8
 0x3a08: mov    w3, #0x80
 0x3a0c: mov    w1, wzr
 0x3a10: bl     #0x2368 ; <duss_log_gen_head>
 0x3a14: cbz    w0, #0x3d2c
 0x3a18: adrp   x3, #0x1a000
 0x3a1c: adrp   x4, #0x1a000
 0x3a20: adrp   x5, #0x1a000
 0x3a24: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3a28: add    x4, x4, #0x58f ; "is_valid_input_format(config->base.input_format)"
 0x3a2c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3a30: mov    w0, #0x51
 0x3a34: mov    w6, #0x67a
 0x3a38: sub    x2, x29, #0xd8
 0x3a3c: mov    w1, wzr
 0x3a40: bl     #0x2378 ; <duss_log_print>
 0x3a44: b      #0x3d2c
 0x3a48: bl     #0x2348 ; <co_thread_get>
 0x3a4c: cbnz   x0, #0x4030
 0x3a50: adrp   x4, #0x1a000
 0x3a54: adrp   x5, #0x1d000
 0x3a58: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3a5c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3a60: mov    w0, #0x51
 0x3a64: mov    w6, #0x5fd
 0x3a68: sub    x2, x29, #0xd8
 0x3a6c: mov    w3, #0x80
 0x3a70: mov    w1, wzr
 0x3a74: bl     #0x2368 ; <duss_log_gen_head>
 0x3a78: cbz    w0, #0x40b8
 0x3a7c: adrp   x3, #0x1a000
 0x3a80: adrp   x4, #0x1d000
 0x3a84: adrp   x5, #0x1a000
 0x3a88: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3a8c: add    x4, x4, #0x20 ; "is_valid_input_format(pixel_format)"
 0x3a90: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3a94: mov    w0, #0x51
 0x3a98: mov    w6, #0x5fd
 0x3a9c: sub    x2, x29, #0xd8
 0x3aa0: mov    w1, wzr
 0x3aa4: bl     #0x2378 ; <duss_log_print>
 0x3aa8: b      #0x40b8
 0x3aac: bl     #0x2348 ; <co_thread_get>
 0x3ab0: cbnz   x0, #0x40d4
 0x3ab4: adrp   x4, #0x1a000
 0x3ab8: adrp   x5, #0x1d000
 0x3abc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3ac0: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3ac4: mov    w0, #0x51
 0x3ac8: mov    w6, #0x606
 0x3acc: sub    x2, x29, #0xd8
 0x3ad0: mov    w3, #0x80
 0x3ad4: mov    w1, wzr
 0x3ad8: bl     #0x2368 ; <duss_log_gen_head>
 0x3adc: cbz    w0, #0x415c
 0x3ae0: adrp   x3, #0x1a000
 0x3ae4: adrp   x4, #0x1d000
 0x3ae8: adrp   x5, #0x1a000
 0x3aec: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3af0: add    x4, x4, #0x59 ; "stride > 0 && stride >= width"
 0x3af4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3af8: mov    w0, #0x51
 0x3afc: mov    w6, #0x606
 0x3b00: sub    x2, x29, #0xd8
 0x3b04: mov    w1, wzr
 0x3b08: bl     #0x2378 ; <duss_log_print>
 0x3b0c: b      #0x415c
 0x3b10: bl     #0x2348 ; <co_thread_get>
 0x3b14: cbnz   x0, #0x4178
 0x3b18: adrp   x4, #0x1a000
 0x3b1c: adrp   x5, #0x1d000
 0x3b20: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3b24: add    x5, x5, #0x9bd ; "proresraw_bayer_pattern_get"
 0x3b28: mov    w0, #0x51
 0x3b2c: mov    w6, #0x5e5
 0x3b30: sub    x2, x29, #0xd8
 0x3b34: mov    w3, #0x80
 0x3b38: mov    w1, wzr
 0x3b3c: bl     #0x2368 ; <duss_log_gen_head>
 0x3b40: cbz    w0, #0x4200
 0x3b44: adrp   x3, #0x1a000
 0x3b48: adrp   x4, #0x1b000
 0x3b4c: adrp   x5, #0x1a000
 0x3b50: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3b54: add    x4, x4, #0xf7 ; "0"
 0x3b58: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3b5c: mov    w0, #0x51
 0x3b60: mov    w6, #0x5e5
 0x3b64: sub    x2, x29, #0xd8
 0x3b68: mov    w1, wzr
 0x3b6c: bl     #0x2378 ; <duss_log_print>
 0x3b70: b      #0x4200
 0x3b74: bl     #0x2348 ; <co_thread_get>
 0x3b78: cbnz   x0, #0x421c
 0x3b7c: adrp   x4, #0x1a000
 0x3b80: adrp   x5, #0x1a000
 0x3b84: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3b88: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3b8c: mov    w0, #0x51
 0x3b90: mov    w6, #0x678
 0x3b94: sub    x2, x29, #0xd8
 0x3b98: mov    w3, #0x80
 0x3b9c: mov    w1, wzr
 0x3ba0: bl     #0x2368 ; <duss_log_gen_head>
 0x3ba4: cbz    w0, #0x42a4
 0x3ba8: adrp   x3, #0x1a000
 0x3bac: adrp   x4, #0x1a000
 0x3bb0: adrp   x5, #0x1a000
 0x3bb4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3bb8: add    x4, x4, #0x501 ; "codec_type == CAM_VENC_CODEC_PRORESRAW"
 0x3bbc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3bc0: mov    w0, #0x51
 0x3bc4: mov    w6, #0x678
 0x3bc8: sub    x2, x29, #0xd8
 0x3bcc: mov    w1, wzr
 0x3bd0: bl     #0x2378 ; <duss_log_print>
 0x3bd4: b      #0x42a4
 0x3bd8: bl     #0x2348 ; <co_thread_get>
 0x3bdc: cbnz   x0, #0x42c0
 0x3be0: adrp   x4, #0x1a000
 0x3be4: adrp   x5, #0x1a000
 0x3be8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3bec: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3bf0: mov    w0, #0x51
 0x3bf4: mov    w6, #0x679
 0x3bf8: sub    x2, x29, #0xd8
 0x3bfc: mov    w3, #0x80
 0x3c00: mov    w1, wzr
 0x3c04: bl     #0x2368 ; <duss_log_gen_head>
 0x3c08: cbz    w0, #0x4348
 0x3c0c: adrp   x3, #0x1a000
 0x3c10: adrp   x4, #0x1a000
 0x3c14: adrp   x5, #0x1a000
 0x3c18: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3c1c: add    x4, x4, #0x588 ; "config"
 0x3c20: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3c24: mov    w0, #0x51
 0x3c28: mov    w6, #0x679
 0x3c2c: sub    x2, x29, #0xd8
 0x3c30: mov    w1, wzr
 0x3c34: bl     #0x2378 ; <duss_log_print>
 0x3c38: b      #0x4348
 0x3c3c: bl     #0x2348 ; <co_thread_get>
 0x3c40: cbnz   x0, #0x4364
 0x3c44: adrp   x4, #0x1a000
 0x3c48: adrp   x5, #0x1a000
 0x3c4c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3c50: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3c54: mov    w0, #0x51
 0x3c58: mov    w6, #0x67b
 0x3c5c: sub    x2, x29, #0xd8
 0x3c60: mov    w3, #0x80
 0x3c64: mov    w1, wzr
 0x3c68: bl     #0x2368 ; <duss_log_gen_head>
 0x3c6c: cbz    w0, #0x43ec
 0x3c70: adrp   x3, #0x1a000
 0x3c74: adrp   x4, #0x1a000
 0x3c78: adrp   x5, #0x1a000
 0x3c7c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3c80: add    x4, x4, #0x5c0 ; "ops"
 0x3c84: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3c88: mov    w0, #0x51
 0x3c8c: mov    w6, #0x67b
 0x3c90: sub    x2, x29, #0xd8
 0x3c94: mov    w1, wzr
 0x3c98: bl     #0x2378 ; <duss_log_print>
 0x3c9c: b      #0x43ec
 0x3ca0: bl     #0x23d8 ; <__stack_chk_fail>
 0x3ca4: adrp   x8, #0x1a000
 0x3ca8: stur   wzr, [x29, #-0xe0]
 0x3cac: add    x8, x8, #0x440 ; =0x1a440
 0x3cb0: add    x1, sp, #0xa8
 0x3cb4: sub    x2, x29, #0xe0
 0x3cb8: str    x8, [sp, #0xa8]
 0x3cbc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x3cc0: adrp   x19, #0x1a000
 0x3cc4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3cc8: adrp   x5, #0x1a000
 0x3ccc: mov    w20, #0x67a
 0x3cd0: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3cd4: mov    w0, #0x51
 0x3cd8: sub    x2, x29, #0xd8
 0x3cdc: mov    w3, #0x80
 0x3ce0: mov    w1, wzr
 0x3ce4: mov    x4, x19
 0x3ce8: mov    w6, w20
 0x3cec: bl     #0x2368 ; <duss_log_gen_head>
 0x3cf0: cbz    w0, #0x3d2c
 0x3cf4: ldr    x5, [sp, #0xa8]
 0x3cf8: adrp   x3, #0x1a000
 0x3cfc: ldur   w6, [x29, #-0xe0]
 0x3d00: adrp   x4, #0x1a000
 0x3d04: adrp   x7, #0x1a000
 0x3d08: str    w20, [sp, #8]
 0x3d0c: mov    w1, wzr
 0x3d10: str    x19, [sp]
 0x3d14: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x3d18: add    x4, x4, #0x441 ; "co"
 0x3d1c: mov    w0, #0x51
 0x3d20: add    x7, x7, #0x58f ; "is_valid_input_format(config->base.input_format)"
 0x3d24: sub    x2, x29, #0xd8
 0x3d28: bl     #0x2378 ; <duss_log_print>
 0x3d2c: adrp   x4, #0x1a000
 0x3d30: adrp   x5, #0x1a000
 0x3d34: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3d38: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3d3c: mov    w0, #0x51
 0x3d40: mov    w6, #0x67a
 0x3d44: b      #0x4c08
 0x3d48: bl     #0x2348 ; <co_thread_get>
 0x3d4c: cbnz   x0, #0x4598
 0x3d50: adrp   x4, #0x1a000
 0x3d54: adrp   x5, #0x1d000
 0x3d58: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3d5c: add    x5, x5, #0x9d9 ; "_get_suggested_stream_buf_size"
 0x3d60: mov    w0, #0x51
 0x3d64: mov    w6, #0x5b7
 0x3d68: sub    x2, x29, #0xd8
 0x3d6c: mov    w3, #0x80
 0x3d70: mov    w1, wzr
 0x3d74: bl     #0x2368 ; <duss_log_gen_head>
 0x3d78: cbz    w0, #0x4620
 0x3d7c: adrp   x3, #0x1a000
 0x3d80: adrp   x4, #0x1d000
 0x3d84: adrp   x5, #0x1a000
 0x3d88: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3d8c: add    x4, x4, #0x20 ; "is_valid_input_format(pixel_format)"
 0x3d90: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3d94: mov    w0, #0x51
 0x3d98: mov    w6, #0x5b7
 0x3d9c: sub    x2, x29, #0xd8
 0x3da0: mov    w1, wzr
 0x3da4: bl     #0x2378 ; <duss_log_print>
 0x3da8: b      #0x4620
 0x3dac: adrp   x0, #0x30000
 0x3db0: adrp   x2, #0x1a000
 0x3db4: add    x0, x0, #8 ; =0x30008
 0x3db8: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x3dbc: mov    w1, #1
 0x3dc0: bl     #0x2338 ; <log_mgr_check>
 0x3dc4: tbz    w0, #0, #0x4900
 0x3dc8: bl     #0x2348 ; <co_thread_get>
 0x3dcc: cbnz   x0, #0x4830
 0x3dd0: adrp   x4, #0x1a000
 0x3dd4: adrp   x5, #0x1d000
 0x3dd8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3ddc: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x3de0: mov    w0, #0x51
 0x3de4: mov    w6, #0x5aa
 0x3de8: mov    w1, #1
 0x3dec: sub    x2, x29, #0xd8
 0x3df0: mov    w3, #0x80
 0x3df4: bl     #0x2368 ; <duss_log_gen_head>
 0x3df8: cbz    w0, #0x3e20
 0x3dfc: adrp   x3, #0x1a000
 0x3e00: adrp   x4, #0x1a000
 0x3e04: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x3e08: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3e0c: mov    w0, #0x51
 0x3e10: mov    w5, #0x5aa
 0x3e14: mov    w1, #1
 0x3e18: sub    x2, x29, #0xd8
 0x3e1c: bl     #0x2378 ; <duss_log_print>
 0x3e20: adrp   x4, #0x1a000
 0x3e24: adrp   x5, #0x1d000
 0x3e28: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3e2c: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x3e30: mov    w0, #0x51
 0x3e34: mov    w6, #0x5aa
 0x3e38: mov    w1, #1
 0x3e3c: sub    x2, x29, #0xd8
 0x3e40: mov    w3, #0x80
 0x3e44: bl     #0x2368 ; <duss_log_gen_head>
 0x3e48: cbz    w0, #0x4900
 0x3e4c: adrp   x3, #0x1d000
 0x3e50: ldr    w5, [sp, #0x7c]
 0x3e54: adrp   x4, #0x1a000
 0x3e58: add    x3, x3, #0xa42 ; "%s: _get_bit_depth unsupport pixel format[%d].
"
 0x3e5c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x3e60: mov    w0, #0x51
 0x3e64: mov    w1, #1
 0x3e68: sub    x2, x29, #0xd8
 0x3e6c: bl     #0x2378 ; <duss_log_print>
 0x3e70: bl     #0x2348 ; <co_thread_get>
 0x3e74: cbz    x0, #0x4908
 0x3e78: adrp   x8, #0x1a000
 0x3e7c: stur   wzr, [x29, #-0xe4]
 0x3e80: add    x8, x8, #0x440 ; =0x1a440
 0x3e84: sub    x1, x29, #0xe0
 0x3e88: sub    x2, x29, #0xe4
 0x3e8c: stur   x8, [x29, #-0xe0]
 0x3e90: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x3e94: adrp   x19, #0x1a000
 0x3e98: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3e9c: adrp   x5, #0x1d000
 0x3ea0: mov    w20, #0x5ab
 0x3ea4: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x3ea8: mov    w0, #0x51
 0x3eac: sub    x2, x29, #0xd8
 0x3eb0: mov    w3, #0x80
 0x3eb4: mov    w1, wzr
 0x3eb8: mov    x4, x19
 0x3ebc: mov    w6, w20
 0x3ec0: bl     #0x2368 ; <duss_log_gen_head>
 0x3ec4: cbz    w0, #0x4960
 0x3ec8: ldur   x5, [x29, #-0xe0]
 0x3ecc: adrp   x3, #0x1a000
 0x3ed0: ldur   w6, [x29, #-0xe4]
 0x3ed4: adrp   x4, #0x1a000
 0x3ed8: adrp   x7, #0x1b000
 0x3edc: str    w20, [sp, #8]
 0x3ee0: mov    w1, wzr
 0x3ee4: str    x19, [sp]
 0x3ee8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x3eec: add    x4, x4, #0x441 ; "co"
 0x3ef0: mov    w0, #0x51
 0x3ef4: add    x7, x7, #0xf7 ; "0"
 0x3ef8: sub    x2, x29, #0xd8
 0x3efc: bl     #0x2378 ; <duss_log_print>
 0x3f00: b      #0x4960
 0x3f04: bl     #0x2348 ; <co_thread_get>
 0x3f08: cbnz   x0, #0x463c
 0x3f0c: adrp   x4, #0x1a000
 0x3f10: adrp   x5, #0x1a000
 0x3f14: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3f18: add    x5, x5, #0x4be ; "venc_eng_create"
 0x3f1c: mov    w0, #0x51
 0x3f20: mov    w6, #0x6a8
 0x3f24: sub    x2, x29, #0xd8
 0x3f28: mov    w3, #0x80
 0x3f2c: mov    w1, wzr
 0x3f30: bl     #0x2368 ; <duss_log_gen_head>
 0x3f34: cbz    w0, #0x46c4
 0x3f38: adrp   x3, #0x1a000
 0x3f3c: adrp   x4, #0x1a000
 0x3f40: adrp   x5, #0x1a000
 0x3f44: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3f48: add    x4, x4, #0x693 ; "config->base.output_stream.v_profile >= CAM_PRORESRAW_PROFILE_START && config->base.output"
 0x3f4c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3f50: mov    w0, #0x51
 0x3f54: mov    w6, #0x6a8
 0x3f58: sub    x2, x29, #0xd8
 0x3f5c: mov    w1, wzr
 0x3f60: bl     #0x2378 ; <duss_log_print>
 0x3f64: b      #0x46c4
 0x3f68: bl     #0x2348 ; <co_thread_get>
 0x3f6c: cbnz   x0, #0x46e0
 0x3f70: adrp   x4, #0x1a000
 0x3f74: adrp   x5, #0x1d000
 0x3f78: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3f7c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3f80: mov    w0, #0x51
 0x3f84: sub    x2, x29, #0xd8
 0x3f88: mov    w3, #0x80
 0x3f8c: mov    w6, #0x600
 0x3f90: mov    w1, wzr
 0x3f94: bl     #0x2368 ; <duss_log_gen_head>
 0x3f98: cbz    w0, #0x4768
 0x3f9c: adrp   x3, #0x1a000
 0x3fa0: adrp   x4, #0x1d000
 0x3fa4: adrp   x5, #0x1a000
 0x3fa8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x3fac: add    x4, x4, #0x44 ; "width > 0"
 0x3fb0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3fb4: mov    w0, #0x51
 0x3fb8: sub    x2, x29, #0xd8
 0x3fbc: mov    w6, #0x600
 0x3fc0: mov    w1, wzr
 0x3fc4: bl     #0x2378 ; <duss_log_print>
 0x3fc8: b      #0x4768
 0x3fcc: bl     #0x2348 ; <co_thread_get>
 0x3fd0: cbnz   x0, #0x478c
 0x3fd4: adrp   x4, #0x1a000
 0x3fd8: adrp   x5, #0x1d000
 0x3fdc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x3fe0: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x3fe4: mov    w0, #0x51
 0x3fe8: mov    w6, #0x603
 0x3fec: sub    x2, x29, #0xd8
 0x3ff0: mov    w3, #0x80
 0x3ff4: mov    w1, wzr
 0x3ff8: bl     #0x2368 ; <duss_log_gen_head>
 0x3ffc: cbz    w0, #0x4814
 0x4000: adrp   x3, #0x1a000
 0x4004: adrp   x4, #0x1d000
 0x4008: adrp   x5, #0x1a000
 0x400c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x4010: add    x4, x4, #0x4e ; "height > 0"
 0x4014: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4018: mov    w0, #0x51
 0x401c: mov    w6, #0x603
 0x4020: sub    x2, x29, #0xd8
 0x4024: mov    w1, wzr
 0x4028: bl     #0x2378 ; <duss_log_print>
 0x402c: b      #0x4814
 0x4030: adrp   x8, #0x1a000
 0x4034: stur   wzr, [x29, #-0xe4]
 0x4038: add    x8, x8, #0x440 ; =0x1a440
 0x403c: sub    x1, x29, #0xe0
 0x4040: sub    x2, x29, #0xe4
 0x4044: stur   x8, [x29, #-0xe0]
 0x4048: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x404c: adrp   x19, #0x1a000
 0x4050: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4054: adrp   x5, #0x1d000
 0x4058: mov    w20, #0x5fd
 0x405c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4060: mov    w0, #0x51
 0x4064: sub    x2, x29, #0xd8
 0x4068: mov    w3, #0x80
 0x406c: mov    w1, wzr
 0x4070: mov    x4, x19
 0x4074: mov    w6, w20
 0x4078: bl     #0x2368 ; <duss_log_gen_head>
 0x407c: cbz    w0, #0x40b8
 0x4080: ldur   x5, [x29, #-0xe0]
 0x4084: adrp   x3, #0x1a000
 0x4088: ldur   w6, [x29, #-0xe4]
 0x408c: adrp   x4, #0x1a000
 0x4090: adrp   x7, #0x1d000
 0x4094: str    w20, [sp, #8]
 0x4098: mov    w1, wzr
 0x409c: str    x19, [sp]
 0x40a0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x40a4: add    x4, x4, #0x441 ; "co"
 0x40a8: mov    w0, #0x51
 0x40ac: add    x7, x7, #0x20 ; "is_valid_input_format(pixel_format)"
 0x40b0: sub    x2, x29, #0xd8
 0x40b4: bl     #0x2378 ; <duss_log_print>
 0x40b8: adrp   x4, #0x1a000
 0x40bc: adrp   x5, #0x1d000
 0x40c0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x40c4: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x40c8: mov    w0, #0x51
 0x40cc: mov    w6, #0x5fd
 0x40d0: b      #0x4c08
 0x40d4: adrp   x8, #0x1a000
 0x40d8: stur   wzr, [x29, #-0xe4]
 0x40dc: add    x8, x8, #0x440 ; =0x1a440
 0x40e0: sub    x1, x29, #0xe0
 0x40e4: sub    x2, x29, #0xe4
 0x40e8: stur   x8, [x29, #-0xe0]
 0x40ec: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x40f0: adrp   x19, #0x1a000
 0x40f4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x40f8: adrp   x5, #0x1d000
 0x40fc: mov    w20, #0x606
 0x4100: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4104: mov    w0, #0x51
 0x4108: sub    x2, x29, #0xd8
 0x410c: mov    w3, #0x80
 0x4110: mov    w1, wzr
 0x4114: mov    x4, x19
 0x4118: mov    w6, w20
 0x411c: bl     #0x2368 ; <duss_log_gen_head>
 0x4120: cbz    w0, #0x415c
 0x4124: ldur   x5, [x29, #-0xe0]
 0x4128: adrp   x3, #0x1a000
 0x412c: ldur   w6, [x29, #-0xe4]
 0x4130: adrp   x4, #0x1a000
 0x4134: adrp   x7, #0x1d000
 0x4138: str    w20, [sp, #8]
 0x413c: mov    w1, wzr
 0x4140: str    x19, [sp]
 0x4144: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4148: add    x4, x4, #0x441 ; "co"
 0x414c: mov    w0, #0x51
 0x4150: add    x7, x7, #0x59 ; "stride > 0 && stride >= width"
 0x4154: sub    x2, x29, #0xd8
 0x4158: bl     #0x2378 ; <duss_log_print>
 0x415c: adrp   x4, #0x1a000
 0x4160: adrp   x5, #0x1d000
 0x4164: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4168: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x416c: mov    w0, #0x51
 0x4170: mov    w6, #0x606
 0x4174: b      #0x4c08
 0x4178: adrp   x8, #0x1a000
 0x417c: stur   wzr, [x29, #-0xe4]
 0x4180: add    x8, x8, #0x440 ; =0x1a440
 0x4184: sub    x1, x29, #0xe0
 0x4188: sub    x2, x29, #0xe4
 0x418c: stur   x8, [x29, #-0xe0]
 0x4190: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4194: adrp   x19, #0x1a000
 0x4198: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x419c: adrp   x5, #0x1d000
 0x41a0: mov    w20, #0x5e5
 0x41a4: add    x5, x5, #0x9bd ; "proresraw_bayer_pattern_get"
 0x41a8: mov    w0, #0x51
 0x41ac: sub    x2, x29, #0xd8
 0x41b0: mov    w3, #0x80
 0x41b4: mov    w1, wzr
 0x41b8: mov    x4, x19
 0x41bc: mov    w6, w20
 0x41c0: bl     #0x2368 ; <duss_log_gen_head>
 0x41c4: cbz    w0, #0x4200
 0x41c8: ldur   x5, [x29, #-0xe0]
 0x41cc: adrp   x3, #0x1a000
 0x41d0: ldur   w6, [x29, #-0xe4]
 0x41d4: adrp   x4, #0x1a000
 0x41d8: adrp   x7, #0x1b000
 0x41dc: str    w20, [sp, #8]
 0x41e0: mov    w1, wzr
 0x41e4: str    x19, [sp]
 0x41e8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x41ec: add    x4, x4, #0x441 ; "co"
 0x41f0: mov    w0, #0x51
 0x41f4: add    x7, x7, #0xf7 ; "0"
 0x41f8: sub    x2, x29, #0xd8
 0x41fc: bl     #0x2378 ; <duss_log_print>
 0x4200: adrp   x4, #0x1a000
 0x4204: adrp   x5, #0x1d000
 0x4208: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x420c: add    x5, x5, #0x9bd ; "proresraw_bayer_pattern_get"
 0x4210: mov    w0, #0x51
 0x4214: mov    w6, #0x5e5
 0x4218: b      #0x4c08
 0x421c: adrp   x8, #0x1a000
 0x4220: stur   wzr, [x29, #-0xe0]
 0x4224: add    x8, x8, #0x440 ; =0x1a440
 0x4228: add    x1, sp, #0xa8
 0x422c: sub    x2, x29, #0xe0
 0x4230: str    x8, [sp, #0xa8]
 0x4234: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4238: adrp   x19, #0x1a000
 0x423c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4240: adrp   x5, #0x1a000
 0x4244: mov    w20, #0x678
 0x4248: add    x5, x5, #0x4be ; "venc_eng_create"
 0x424c: mov    w0, #0x51
 0x4250: sub    x2, x29, #0xd8
 0x4254: mov    w3, #0x80
 0x4258: mov    w1, wzr
 0x425c: mov    x4, x19
 0x4260: mov    w6, w20
 0x4264: bl     #0x2368 ; <duss_log_gen_head>
 0x4268: cbz    w0, #0x42a4
 0x426c: ldr    x5, [sp, #0xa8]
 0x4270: adrp   x3, #0x1a000
 0x4274: ldur   w6, [x29, #-0xe0]
 0x4278: adrp   x4, #0x1a000
 0x427c: adrp   x7, #0x1a000
 0x4280: str    w20, [sp, #8]
 0x4284: mov    w1, wzr
 0x4288: str    x19, [sp]
 0x428c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4290: add    x4, x4, #0x441 ; "co"
 0x4294: mov    w0, #0x51
 0x4298: add    x7, x7, #0x501 ; "codec_type == CAM_VENC_CODEC_PRORESRAW"
 0x429c: sub    x2, x29, #0xd8
 0x42a0: bl     #0x2378 ; <duss_log_print>
 0x42a4: adrp   x4, #0x1a000
 0x42a8: adrp   x5, #0x1a000
 0x42ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x42b0: add    x5, x5, #0x4be ; "venc_eng_create"
 0x42b4: mov    w0, #0x51
 0x42b8: mov    w6, #0x678
 0x42bc: b      #0x4c08
 0x42c0: adrp   x8, #0x1a000
 0x42c4: stur   wzr, [x29, #-0xe0]
 0x42c8: add    x8, x8, #0x440 ; =0x1a440
 0x42cc: add    x1, sp, #0xa8
 0x42d0: sub    x2, x29, #0xe0
 0x42d4: str    x8, [sp, #0xa8]
 0x42d8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x42dc: adrp   x19, #0x1a000
 0x42e0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x42e4: adrp   x5, #0x1a000
 0x42e8: mov    w20, #0x679
 0x42ec: add    x5, x5, #0x4be ; "venc_eng_create"
 0x42f0: mov    w0, #0x51
 0x42f4: sub    x2, x29, #0xd8
 0x42f8: mov    w3, #0x80
 0x42fc: mov    w1, wzr
 0x4300: mov    x4, x19
 0x4304: mov    w6, w20
 0x4308: bl     #0x2368 ; <duss_log_gen_head>
 0x430c: cbz    w0, #0x4348
 0x4310: ldr    x5, [sp, #0xa8]
 0x4314: adrp   x3, #0x1a000
 0x4318: ldur   w6, [x29, #-0xe0]
 0x431c: adrp   x4, #0x1a000
 0x4320: adrp   x7, #0x1a000
 0x4324: str    w20, [sp, #8]
 0x4328: mov    w1, wzr
 0x432c: str    x19, [sp]
 0x4330: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4334: add    x4, x4, #0x441 ; "co"
 0x4338: mov    w0, #0x51
 0x433c: add    x7, x7, #0x588 ; "config"
 0x4340: sub    x2, x29, #0xd8
 0x4344: bl     #0x2378 ; <duss_log_print>
 0x4348: adrp   x4, #0x1a000
 0x434c: adrp   x5, #0x1a000
 0x4350: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4354: add    x5, x5, #0x4be ; "venc_eng_create"
 0x4358: mov    w0, #0x51
 0x435c: mov    w6, #0x679
 0x4360: b      #0x4c08
 0x4364: adrp   x8, #0x1a000
 0x4368: stur   wzr, [x29, #-0xe0]
 0x436c: add    x8, x8, #0x440 ; =0x1a440
 0x4370: add    x1, sp, #0xa8
 0x4374: sub    x2, x29, #0xe0
 0x4378: str    x8, [sp, #0xa8]
 0x437c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4380: adrp   x19, #0x1a000
 0x4384: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4388: adrp   x5, #0x1a000
 0x438c: mov    w20, #0x67b
 0x4390: add    x5, x5, #0x4be ; "venc_eng_create"
 0x4394: mov    w0, #0x51
 0x4398: sub    x2, x29, #0xd8
 0x439c: mov    w3, #0x80
 0x43a0: mov    w1, wzr
 0x43a4: mov    x4, x19
 0x43a8: mov    w6, w20
 0x43ac: bl     #0x2368 ; <duss_log_gen_head>
 0x43b0: cbz    w0, #0x43ec
 0x43b4: ldr    x5, [sp, #0xa8]
 0x43b8: adrp   x3, #0x1a000
 0x43bc: ldur   w6, [x29, #-0xe0]
 0x43c0: adrp   x4, #0x1a000
 0x43c4: adrp   x7, #0x1a000
 0x43c8: str    w20, [sp, #8]
 0x43cc: mov    w1, wzr
 0x43d0: str    x19, [sp]
 0x43d4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x43d8: add    x4, x4, #0x441 ; "co"
 0x43dc: mov    w0, #0x51
 0x43e0: add    x7, x7, #0x5c0 ; "ops"
 0x43e4: sub    x2, x29, #0xd8
 0x43e8: bl     #0x2378 ; <duss_log_print>
 0x43ec: adrp   x4, #0x1a000
 0x43f0: adrp   x5, #0x1a000
 0x43f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x43f8: add    x5, x5, #0x4be ; "venc_eng_create"
 0x43fc: mov    w0, #0x51
 0x4400: mov    w6, #0x67b
 0x4404: b      #0x4c08
 0x4408: bl     #0x2348 ; <co_thread_get>
 0x440c: cbnz   x0, #0x497c
 0x4410: adrp   x4, #0x1a000
 0x4414: adrp   x5, #0x1d000
 0x4418: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x441c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4420: mov    w0, #0x51
 0x4424: mov    w6, #0x639
 0x4428: sub    x2, x29, #0xd8
 0x442c: mov    w3, #0x80
 0x4430: mov    w1, wzr
 0x4434: bl     #0x2368 ; <duss_log_gen_head>
 0x4438: cbz    w0, #0x4a04
 0x443c: adrp   x3, #0x1a000
 0x4440: adrp   x4, #0x1c000
 0x4444: adrp   x5, #0x1a000
 0x4448: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x444c: add    x4, x4, #0x948 ; "eng->suggested_stream_buf_size > 0"
 0x4450: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4454: mov    w0, #0x51
 0x4458: mov    w6, #0x639
 0x445c: sub    x2, x29, #0xd8
 0x4460: mov    w1, wzr
 0x4464: bl     #0x2378 ; <duss_log_print>
 0x4468: b      #0x4a04
 0x446c: bl     #0x2348 ; <co_thread_get>
 0x4470: cbnz   x0, #0x4a20
 0x4474: adrp   x4, #0x1a000
 0x4478: adrp   x5, #0x1d000
 0x447c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4480: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4484: mov    w0, #0x51
 0x4488: mov    w6, #0x644
 0x448c: sub    x2, x29, #0xd8
 0x4490: mov    w3, #0x80
 0x4494: mov    w1, wzr
 0x4498: bl     #0x2368 ; <duss_log_gen_head>
 0x449c: cbz    w0, #0x4aa8
 0x44a0: adrp   x3, #0x1a000
 0x44a4: adrp   x4, #0x1d000
 0x44a8: adrp   x5, #0x1a000
 0x44ac: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x44b0: add    x4, x4, #0x28d ; "eng->config.base.output_stream.fps_num > 0"
 0x44b4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x44b8: mov    w0, #0x51
 0x44bc: mov    w6, #0x644
 0x44c0: sub    x2, x29, #0xd8
 0x44c4: mov    w1, wzr
 0x44c8: bl     #0x2378 ; <duss_log_print>
 0x44cc: b      #0x4aa8
 0x44d0: bl     #0x2348 ; <co_thread_get>
 0x44d4: cbnz   x0, #0x4ac4
 0x44d8: adrp   x4, #0x1a000
 0x44dc: adrp   x5, #0x1d000
 0x44e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x44e4: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x44e8: mov    w0, #0x51
 0x44ec: mov    w6, #0x645
 0x44f0: sub    x2, x29, #0xd8
 0x44f4: mov    w3, #0x80
 0x44f8: mov    w1, wzr
 0x44fc: bl     #0x2368 ; <duss_log_gen_head>
 0x4500: cbz    w0, #0x4b4c
 0x4504: adrp   x3, #0x1a000
 0x4508: adrp   x4, #0x1d000
 0x450c: adrp   x5, #0x1a000
 0x4510: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x4514: add    x4, x4, #0x2b8 ; "eng->config.base.output_stream.fps_den > 0"
 0x4518: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x451c: mov    w0, #0x51
 0x4520: mov    w6, #0x645
 0x4524: sub    x2, x29, #0xd8
 0x4528: mov    w1, wzr
 0x452c: bl     #0x2378 ; <duss_log_print>
 0x4530: b      #0x4b4c
 0x4534: bl     #0x2348 ; <co_thread_get>
 0x4538: cbnz   x0, #0x4b68
 0x453c: adrp   x4, #0x1a000
 0x4540: adrp   x5, #0x1a000
 0x4544: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4548: add    x5, x5, #0x4be ; "venc_eng_create"
 0x454c: mov    w0, #0x51
 0x4550: mov    w6, #0x6b4
 0x4554: sub    x2, x29, #0xd8
 0x4558: mov    w3, #0x80
 0x455c: mov    w1, wzr
 0x4560: bl     #0x2368 ; <duss_log_gen_head>
 0x4564: cbz    w0, #0x4bf0
 0x4568: adrp   x3, #0x1a000
 0x456c: adrp   x4, #0x1a000
 0x4570: adrp   x5, #0x1a000
 0x4574: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x4578: add    x4, x4, #0x789 ; "((duss_result_t) 0) == rlt"
 0x457c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4580: mov    w0, #0x51
 0x4584: mov    w6, #0x6b4
 0x4588: sub    x2, x29, #0xd8
 0x458c: mov    w1, wzr
 0x4590: bl     #0x2378 ; <duss_log_print>
 0x4594: b      #0x4bf0
 0x4598: adrp   x8, #0x1a000
 0x459c: stur   wzr, [x29, #-0xe4]
 0x45a0: add    x8, x8, #0x440 ; =0x1a440
 0x45a4: sub    x1, x29, #0xe0
 0x45a8: sub    x2, x29, #0xe4
 0x45ac: stur   x8, [x29, #-0xe0]
 0x45b0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x45b4: adrp   x19, #0x1a000
 0x45b8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x45bc: adrp   x5, #0x1d000
 0x45c0: mov    w20, #0x5b7
 0x45c4: add    x5, x5, #0x9d9 ; "_get_suggested_stream_buf_size"
 0x45c8: mov    w0, #0x51
 0x45cc: sub    x2, x29, #0xd8
 0x45d0: mov    w3, #0x80
 0x45d4: mov    w1, wzr
 0x45d8: mov    x4, x19
 0x45dc: mov    w6, w20
 0x45e0: bl     #0x2368 ; <duss_log_gen_head>
 0x45e4: cbz    w0, #0x4620
 0x45e8: ldur   x5, [x29, #-0xe0]
 0x45ec: adrp   x3, #0x1a000
 0x45f0: ldur   w6, [x29, #-0xe4]
 0x45f4: adrp   x4, #0x1a000
 0x45f8: adrp   x7, #0x1d000
 0x45fc: str    w20, [sp, #8]
 0x4600: mov    w1, wzr
 0x4604: str    x19, [sp]
 0x4608: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x460c: add    x4, x4, #0x441 ; "co"
 0x4610: mov    w0, #0x51
 0x4614: add    x7, x7, #0x20 ; "is_valid_input_format(pixel_format)"
 0x4618: sub    x2, x29, #0xd8
 0x461c: bl     #0x2378 ; <duss_log_print>
 0x4620: adrp   x4, #0x1a000
 0x4624: adrp   x5, #0x1d000
 0x4628: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x462c: add    x5, x5, #0x9d9 ; "_get_suggested_stream_buf_size"
 0x4630: mov    w0, #0x51
 0x4634: mov    w6, #0x5b7
 0x4638: b      #0x4c08
 0x463c: adrp   x8, #0x1a000
 0x4640: stur   wzr, [x29, #-0xe0]
 0x4644: add    x8, x8, #0x440 ; =0x1a440
 0x4648: add    x1, sp, #0xa8
 0x464c: sub    x2, x29, #0xe0
 0x4650: str    x8, [sp, #0xa8]
 0x4654: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4658: adrp   x19, #0x1a000
 0x465c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4660: adrp   x5, #0x1a000
 0x4664: mov    w20, #0x6a8
 0x4668: add    x5, x5, #0x4be ; "venc_eng_create"
 0x466c: mov    w0, #0x51
 0x4670: sub    x2, x29, #0xd8
 0x4674: mov    w3, #0x80
 0x4678: mov    w1, wzr
 0x467c: mov    x4, x19
 0x4680: mov    w6, w20
 0x4684: bl     #0x2368 ; <duss_log_gen_head>
 0x4688: cbz    w0, #0x46c4
 0x468c: ldr    x5, [sp, #0xa8]
 0x4690: adrp   x3, #0x1a000
 0x4694: ldur   w6, [x29, #-0xe0]
 0x4698: adrp   x4, #0x1a000
 0x469c: adrp   x7, #0x1a000
 0x46a0: str    w20, [sp, #8]
 0x46a4: mov    w1, wzr
 0x46a8: str    x19, [sp]
 0x46ac: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x46b0: add    x4, x4, #0x441 ; "co"
 0x46b4: mov    w0, #0x51
 0x46b8: add    x7, x7, #0x693 ; "config->base.output_stream.v_profile >= CAM_PRORESRAW_PROFILE_START && config->base.output"
 0x46bc: sub    x2, x29, #0xd8
 0x46c0: bl     #0x2378 ; <duss_log_print>
 0x46c4: adrp   x4, #0x1a000
 0x46c8: adrp   x5, #0x1a000
 0x46cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x46d0: add    x5, x5, #0x4be ; "venc_eng_create"
 0x46d4: mov    w0, #0x51
 0x46d8: mov    w6, #0x6a8
 0x46dc: b      #0x4c08
 0x46e0: adrp   x8, #0x1a000
 0x46e4: stur   wzr, [x29, #-0xe4]
 0x46e8: add    x8, x8, #0x440 ; =0x1a440
 0x46ec: sub    x1, x29, #0xe0
 0x46f0: sub    x2, x29, #0xe4
 0x46f4: stur   x8, [x29, #-0xe0]
 0x46f8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x46fc: adrp   x19, #0x1a000
 0x4700: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4704: adrp   x5, #0x1d000
 0x4708: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x470c: mov    w0, #0x51
 0x4710: sub    x2, x29, #0xd8
 0x4714: mov    w3, #0x80
 0x4718: mov    w6, #0x600
 0x471c: mov    w1, wzr
 0x4720: mov    x4, x19
 0x4724: mov    w20, #0x600
 0x4728: bl     #0x2368 ; <duss_log_gen_head>
 0x472c: cbz    w0, #0x4768
 0x4730: ldur   x5, [x29, #-0xe0]
 0x4734: adrp   x3, #0x1a000
 0x4738: ldur   w6, [x29, #-0xe4]
 0x473c: adrp   x4, #0x1a000
 0x4740: adrp   x7, #0x1d000
 0x4744: str    w20, [sp, #8]
 0x4748: mov    w1, wzr
 0x474c: str    x19, [sp]
 0x4750: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4754: add    x4, x4, #0x441 ; "co"
 0x4758: mov    w0, #0x51
 0x475c: add    x7, x7, #0x44 ; "width > 0"
 0x4760: sub    x2, x29, #0xd8
 0x4764: bl     #0x2378 ; <duss_log_print>
 0x4768: adrp   x4, #0x1a000
 0x476c: adrp   x5, #0x1d000
 0x4770: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4774: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4778: mov    w0, #0x51
 0x477c: sub    x2, x29, #0xd8
 0x4780: mov    w3, #0x80
 0x4784: mov    w6, #0x600
 0x4788: b      #0x4c10
 0x478c: adrp   x8, #0x1a000
 0x4790: stur   wzr, [x29, #-0xe4]
 0x4794: add    x8, x8, #0x440 ; =0x1a440
 0x4798: sub    x1, x29, #0xe0
 0x479c: sub    x2, x29, #0xe4
 0x47a0: stur   x8, [x29, #-0xe0]
 0x47a4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x47a8: adrp   x19, #0x1a000
 0x47ac: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x47b0: adrp   x5, #0x1d000
 0x47b4: mov    w20, #0x603
 0x47b8: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x47bc: mov    w0, #0x51
 0x47c0: sub    x2, x29, #0xd8
 0x47c4: mov    w3, #0x80
 0x47c8: mov    w1, wzr
 0x47cc: mov    x4, x19
 0x47d0: mov    w6, w20
 0x47d4: bl     #0x2368 ; <duss_log_gen_head>
 0x47d8: cbz    w0, #0x4814
 0x47dc: ldur   x5, [x29, #-0xe0]
 0x47e0: adrp   x3, #0x1a000
 0x47e4: ldur   w6, [x29, #-0xe4]
 0x47e8: adrp   x4, #0x1a000
 0x47ec: adrp   x7, #0x1d000
 0x47f0: str    w20, [sp, #8]
 0x47f4: mov    w1, wzr
 0x47f8: str    x19, [sp]
 0x47fc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4800: add    x4, x4, #0x441 ; "co"
 0x4804: mov    w0, #0x51
 0x4808: add    x7, x7, #0x4e ; "height > 0"
 0x480c: sub    x2, x29, #0xd8
 0x4810: bl     #0x2378 ; <duss_log_print>
 0x4814: adrp   x4, #0x1a000
 0x4818: adrp   x5, #0x1d000
 0x481c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4820: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4824: mov    w0, #0x51
 0x4828: mov    w6, #0x603
 0x482c: b      #0x4c08
 0x4830: adrp   x8, #0x1a000
 0x4834: stur   wzr, [x29, #-0xe4]
 0x4838: add    x8, x8, #0x440 ; =0x1a440
 0x483c: sub    x1, x29, #0xe0
 0x4840: sub    x2, x29, #0xe4
 0x4844: stur   x8, [x29, #-0xe0]
 0x4848: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x484c: adrp   x4, #0x1a000
 0x4850: adrp   x5, #0x1d000
 0x4854: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4858: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x485c: mov    w0, #0x51
 0x4860: mov    w6, #0x5aa
 0x4864: mov    w1, #1
 0x4868: sub    x2, x29, #0xd8
 0x486c: mov    w3, #0x80
 0x4870: bl     #0x2368 ; <duss_log_gen_head>
 0x4874: cbz    w0, #0x489c
 0x4878: adrp   x3, #0x1a000
 0x487c: adrp   x4, #0x1a000
 0x4880: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x4884: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4888: mov    w0, #0x51
 0x488c: mov    w5, #0x5aa
 0x4890: mov    w1, #1
 0x4894: sub    x2, x29, #0xd8
 0x4898: bl     #0x2378 ; <duss_log_print>
 0x489c: adrp   x4, #0x1a000
 0x48a0: adrp   x5, #0x1d000
 0x48a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x48a8: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x48ac: mov    w0, #0x51
 0x48b0: mov    w6, #0x5aa
 0x48b4: mov    w1, #1
 0x48b8: sub    x2, x29, #0xd8
 0x48bc: mov    w3, #0x80
 0x48c0: bl     #0x2368 ; <duss_log_gen_head>
 0x48c4: cbz    w0, #0x4900
 0x48c8: ldur   x6, [x29, #-0xe0]
 0x48cc: adrp   x3, #0x1d000
 0x48d0: ldur   w7, [x29, #-0xe4]
 0x48d4: adrp   x4, #0x1a000
 0x48d8: adrp   x5, #0x1a000
 0x48dc: ldr    w8, [sp, #0x7c]
 0x48e0: add    x3, x3, #0xa07 ; "%s: %s(%s_%x): _get_bit_depth unsupport pixel format[%d].
"
 0x48e4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x48e8: add    x5, x5, #0x441 ; "co"
 0x48ec: mov    w0, #0x51
 0x48f0: str    w8, [sp]
 0x48f4: mov    w1, #1
 0x48f8: sub    x2, x29, #0xd8
 0x48fc: bl     #0x2378 ; <duss_log_print>
 0x4900: bl     #0x2348 ; <co_thread_get>
 0x4904: cbnz   x0, #0x3e78
 0x4908: adrp   x4, #0x1a000
 0x490c: adrp   x5, #0x1d000
 0x4910: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4914: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x4918: mov    w0, #0x51
 0x491c: mov    w6, #0x5ab
 0x4920: sub    x2, x29, #0xd8
 0x4924: mov    w3, #0x80
 0x4928: mov    w1, wzr
 0x492c: bl     #0x2368 ; <duss_log_gen_head>
 0x4930: cbz    w0, #0x4960
 0x4934: adrp   x3, #0x1a000
 0x4938: adrp   x4, #0x1b000
 0x493c: adrp   x5, #0x1a000
 0x4940: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x4944: add    x4, x4, #0xf7 ; "0"
 0x4948: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x494c: mov    w0, #0x51
 0x4950: mov    w6, #0x5ab
 0x4954: sub    x2, x29, #0xd8
 0x4958: mov    w1, wzr
 0x495c: bl     #0x2378 ; <duss_log_print>
 0x4960: adrp   x4, #0x1a000
 0x4964: adrp   x5, #0x1d000
 0x4968: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x496c: add    x5, x5, #0x9f8 ; "_get_bit_depth"
 0x4970: mov    w0, #0x51
 0x4974: mov    w6, #0x5ab
 0x4978: b      #0x4c08
 0x497c: adrp   x8, #0x1a000
 0x4980: stur   wzr, [x29, #-0xe4]
 0x4984: add    x8, x8, #0x440 ; =0x1a440
 0x4988: sub    x1, x29, #0xe0
 0x498c: sub    x2, x29, #0xe4
 0x4990: stur   x8, [x29, #-0xe0]
 0x4994: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4998: adrp   x19, #0x1a000
 0x499c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x49a0: adrp   x5, #0x1d000
 0x49a4: mov    w20, #0x639
 0x49a8: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x49ac: mov    w0, #0x51
 0x49b0: sub    x2, x29, #0xd8
 0x49b4: mov    w3, #0x80
 0x49b8: mov    w1, wzr
 0x49bc: mov    x4, x19
 0x49c0: mov    w6, w20
 0x49c4: bl     #0x2368 ; <duss_log_gen_head>
 0x49c8: cbz    w0, #0x4a04
 0x49cc: ldur   x5, [x29, #-0xe0]
 0x49d0: adrp   x3, #0x1a000
 0x49d4: ldur   w6, [x29, #-0xe4]
 0x49d8: adrp   x4, #0x1a000
 0x49dc: adrp   x7, #0x1c000
 0x49e0: str    w20, [sp, #8]
 0x49e4: mov    w1, wzr
 0x49e8: str    x19, [sp]
 0x49ec: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x49f0: add    x4, x4, #0x441 ; "co"
 0x49f4: mov    w0, #0x51
 0x49f8: add    x7, x7, #0x948 ; "eng->suggested_stream_buf_size > 0"
 0x49fc: sub    x2, x29, #0xd8
 0x4a00: bl     #0x2378 ; <duss_log_print>
 0x4a04: adrp   x4, #0x1a000
 0x4a08: adrp   x5, #0x1d000
 0x4a0c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4a10: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4a14: mov    w0, #0x51
 0x4a18: mov    w6, #0x639
 0x4a1c: b      #0x4c08
 0x4a20: adrp   x8, #0x1a000
 0x4a24: stur   wzr, [x29, #-0xe4]
 0x4a28: add    x8, x8, #0x440 ; =0x1a440
 0x4a2c: sub    x1, x29, #0xe0
 0x4a30: sub    x2, x29, #0xe4
 0x4a34: stur   x8, [x29, #-0xe0]
 0x4a38: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4a3c: adrp   x19, #0x1a000
 0x4a40: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4a44: adrp   x5, #0x1d000
 0x4a48: mov    w20, #0x644
 0x4a4c: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4a50: mov    w0, #0x51
 0x4a54: sub    x2, x29, #0xd8
 0x4a58: mov    w3, #0x80
 0x4a5c: mov    w1, wzr
 0x4a60: mov    x4, x19
 0x4a64: mov    w6, w20
 0x4a68: bl     #0x2368 ; <duss_log_gen_head>
 0x4a6c: cbz    w0, #0x4aa8
 0x4a70: ldur   x5, [x29, #-0xe0]
 0x4a74: adrp   x3, #0x1a000
 0x4a78: ldur   w6, [x29, #-0xe4]
 0x4a7c: adrp   x4, #0x1a000
 0x4a80: adrp   x7, #0x1d000
 0x4a84: str    w20, [sp, #8]
 0x4a88: mov    w1, wzr
 0x4a8c: str    x19, [sp]
 0x4a90: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4a94: add    x4, x4, #0x441 ; "co"
 0x4a98: mov    w0, #0x51
 0x4a9c: add    x7, x7, #0x28d ; "eng->config.base.output_stream.fps_num > 0"
 0x4aa0: sub    x2, x29, #0xd8
 0x4aa4: bl     #0x2378 ; <duss_log_print>
 0x4aa8: adrp   x4, #0x1a000
 0x4aac: adrp   x5, #0x1d000
 0x4ab0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4ab4: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4ab8: mov    w0, #0x51
 0x4abc: mov    w6, #0x644
 0x4ac0: b      #0x4c08
 0x4ac4: adrp   x8, #0x1a000
 0x4ac8: stur   wzr, [x29, #-0xe4]
 0x4acc: add    x8, x8, #0x440 ; =0x1a440
 0x4ad0: sub    x1, x29, #0xe0
 0x4ad4: sub    x2, x29, #0xe4
 0x4ad8: stur   x8, [x29, #-0xe0]
 0x4adc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4ae0: adrp   x19, #0x1a000
 0x4ae4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4ae8: adrp   x5, #0x1d000
 0x4aec: mov    w20, #0x645
 0x4af0: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4af4: mov    w0, #0x51
 0x4af8: sub    x2, x29, #0xd8
 0x4afc: mov    w3, #0x80
 0x4b00: mov    w1, wzr
 0x4b04: mov    x4, x19
 0x4b08: mov    w6, w20
 0x4b0c: bl     #0x2368 ; <duss_log_gen_head>
 0x4b10: cbz    w0, #0x4b4c
 0x4b14: ldur   x5, [x29, #-0xe0]
 0x4b18: adrp   x3, #0x1a000
 0x4b1c: ldur   w6, [x29, #-0xe4]
 0x4b20: adrp   x4, #0x1a000
 0x4b24: adrp   x7, #0x1d000
 0x4b28: str    w20, [sp, #8]
 0x4b2c: mov    w1, wzr
 0x4b30: str    x19, [sp]
 0x4b34: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4b38: add    x4, x4, #0x441 ; "co"
 0x4b3c: mov    w0, #0x51
 0x4b40: add    x7, x7, #0x2b8 ; "eng->config.base.output_stream.fps_den > 0"
 0x4b44: sub    x2, x29, #0xd8
 0x4b48: bl     #0x2378 ; <duss_log_print>
 0x4b4c: adrp   x4, #0x1a000
 0x4b50: adrp   x5, #0x1d000
 0x4b54: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4b58: add    x5, x5, #0 ; "_proresraw_venc_eng_open_device"
 0x4b5c: mov    w0, #0x51
 0x4b60: mov    w6, #0x645
 0x4b64: b      #0x4c08
 0x4b68: adrp   x8, #0x1a000
 0x4b6c: stur   wzr, [x29, #-0xe4]
 0x4b70: add    x8, x8, #0x440 ; =0x1a440
 0x4b74: sub    x1, x29, #0xe0
 0x4b78: sub    x2, x29, #0xe4
 0x4b7c: stur   x8, [x29, #-0xe0]
 0x4b80: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4b84: adrp   x19, #0x1a000
 0x4b88: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4b8c: adrp   x5, #0x1a000
 0x4b90: mov    w20, #0x6b4
 0x4b94: add    x5, x5, #0x4be ; "venc_eng_create"
 0x4b98: mov    w0, #0x51
 0x4b9c: sub    x2, x29, #0xd8
 0x4ba0: mov    w3, #0x80
 0x4ba4: mov    w1, wzr
 0x4ba8: mov    x4, x19
 0x4bac: mov    w6, w20
 0x4bb0: bl     #0x2368 ; <duss_log_gen_head>
 0x4bb4: cbz    w0, #0x4bf0
 0x4bb8: ldur   x5, [x29, #-0xe0]
 0x4bbc: adrp   x3, #0x1a000
 0x4bc0: ldur   w6, [x29, #-0xe4]
 0x4bc4: adrp   x4, #0x1a000
 0x4bc8: adrp   x7, #0x1a000
 0x4bcc: str    w20, [sp, #8]
 0x4bd0: mov    w1, wzr
 0x4bd4: str    x19, [sp]
 0x4bd8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4bdc: add    x4, x4, #0x441 ; "co"
 0x4be0: mov    w0, #0x51
 0x4be4: add    x7, x7, #0x789 ; "((duss_result_t) 0) == rlt"
 0x4be8: sub    x2, x29, #0xd8
 0x4bec: bl     #0x2378 ; <duss_log_print>
 0x4bf0: adrp   x4, #0x1a000
 0x4bf4: adrp   x5, #0x1a000
 0x4bf8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4bfc: add    x5, x5, #0x4be ; "venc_eng_create"
 0x4c00: mov    w0, #0x51
 0x4c04: mov    w6, #0x6b4
 0x4c08: sub    x2, x29, #0xd8
 0x4c0c: mov    w3, #0x80
 0x4c10: mov    w1, wzr
 0x4c14: bl     #0x2368 ; <duss_log_gen_head>
 0x4c18: cbz    w0, #0x4c34
 0x4c1c: adrp   x3, #0x1a000
 0x4c20: add    x3, x3, #0x550 ; "Assertion Comment: "
 0x4c24: mov    w0, #0x51
 0x4c28: sub    x2, x29, #0xd8
 0x4c2c: mov    w1, wzr
 0x4c30: bl     #0x2378 ; <duss_log_print>
 0x4c34: adrp   x0, #0x1a000
 0x4c38: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0x4c3c: bl     #0x23e8 ; <log_to_kmsg>
 0x4c40: adrp   x0, #0x1a000
 0x4c44: add    x0, x0, #0x57f ; "Camera:	"
 0x4c48: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0x4c4c: bl     #0x2408 ; <is_running_in_cam_sil>
 0x4c50: tbz    w0, #0, #0x4c60
 0x4c54: mov    x0, xzr
 0x4c58: bl     #0x2418 ; <fflush>
 0x4c5c: bl     #0x2428 ; <abort>
 0x4c60: mov    w0, #1
 0x4c64: bl     #0x2438 ; <exit>
 0x4c68: sub    sp, sp, #0xd0
 0x4c6c: stp    x20, x19, [sp, #0xb0]
 0x4c70: stp    x29, x30, [sp, #0xc0]
 0x4c74: add    x29, sp, #0xc0
 0x4c78: mrs    x20, tpidr_el0
 0x4c7c: mov    x8, x0
 0x4c80: ldr    x9, [x20, #0x28]
 0x4c84: add    x19, sp, #0x10
 0x4c88: str    x9, [x19]
 0x4c8c: cbz    x8, #0x4cd8
 0x4c90: cbz    x1, #0x4d3c
 0x4c94: adrp   x9, #0xe000
 0x4c98: add    x9, x9, #0x5a0 ; =0xe5a0
 0x4c9c: mov    x0, x1
 0x4ca0: mov    x1, x9
 0x4ca4: mov    x2, x8
 0x4ca8: bl     #0x2448 ; <parse_parameter_str>
 0x4cac: ldr    x8, [x20, #0x28]
 0x4cb0: cmp    w0, #0
 0x4cb4: ldr    x9, [x19]
 0x4cb8: mov    w10, #-0x3e9
 0x4cbc: csel   w0, wzr, w10, eq
 0x4cc0: cmp    x8, x9
 0x4cc4: b.ne   #0x4da0
 0x4cc8: ldp    x29, x30, [sp, #0xc0]
 0x4ccc: ldp    x20, x19, [sp, #0xb0]
 0x4cd0: add    sp, sp, #0xd0
 0x4cd4: ret    
 0x4cd8: bl     #0x2348 ; <co_thread_get>
 0x4cdc: cbnz   x0, #0x4da4
 0x4ce0: adrp   x4, #0x1a000
 0x4ce4: adrp   x5, #0x1a000
 0x4ce8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4cec: add    x5, x5, #0x7fd ; "_proresraw_venc_eng_set_param"
 0x4cf0: mov    w0, #0x51
 0x4cf4: mov    w6, #0xf5
 0x4cf8: add    x2, sp, #0x28
 0x4cfc: mov    w3, #0x80
 0x4d00: mov    w1, wzr
 0x4d04: bl     #0x2368 ; <duss_log_gen_head>
 0x4d08: cbz    w0, #0x4e2c
 0x4d0c: adrp   x3, #0x1a000
 0x4d10: adrp   x4, #0x1a000
 0x4d14: adrp   x5, #0x1a000
 0x4d18: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x4d1c: add    x4, x4, #0x5c0 ; "ops"
 0x4d20: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4d24: mov    w0, #0x51
 0x4d28: mov    w6, #0xf5
 0x4d2c: add    x2, sp, #0x28
 0x4d30: mov    w1, wzr
 0x4d34: bl     #0x2378 ; <duss_log_print>
 0x4d38: b      #0x4e2c
 0x4d3c: bl     #0x2348 ; <co_thread_get>
 0x4d40: cbnz   x0, #0x4e48
 0x4d44: adrp   x4, #0x1a000
 0x4d48: adrp   x5, #0x1a000
 0x4d4c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4d50: add    x5, x5, #0x7fd ; "_proresraw_venc_eng_set_param"
 0x4d54: mov    w0, #0x51
 0x4d58: mov    w6, #0xf6
 0x4d5c: add    x2, sp, #0x28
 0x4d60: mov    w3, #0x80
 0x4d64: mov    w1, wzr
 0x4d68: bl     #0x2368 ; <duss_log_gen_head>
 0x4d6c: cbz    w0, #0x4ed0
 0x4d70: adrp   x3, #0x1a000
 0x4d74: adrp   x4, #0x1a000
 0x4d78: adrp   x5, #0x1a000
 0x4d7c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x4d80: add    x4, x4, #0x81b ; "param"
 0x4d84: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4d88: mov    w0, #0x51
 0x4d8c: mov    w6, #0xf6
 0x4d90: add    x2, sp, #0x28
 0x4d94: mov    w1, wzr
 0x4d98: bl     #0x2378 ; <duss_log_print>
 0x4d9c: b      #0x4ed0
 0x4da0: bl     #0x23d8 ; <__stack_chk_fail>
 0x4da4: adrp   x8, #0x1a000
 0x4da8: str    wzr, [sp, #0x1c]
 0x4dac: add    x8, x8, #0x440 ; =0x1a440
 0x4db0: add    x1, sp, #0x20
 0x4db4: add    x2, sp, #0x1c
 0x4db8: str    x8, [sp, #0x20]
 0x4dbc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4dc0: adrp   x19, #0x1a000
 0x4dc4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4dc8: adrp   x5, #0x1a000
 0x4dcc: mov    w20, #0xf5
 0x4dd0: add    x5, x5, #0x7fd ; "_proresraw_venc_eng_set_param"
 0x4dd4: mov    w0, #0x51
 0x4dd8: add    x2, sp, #0x28
 0x4ddc: mov    w3, #0x80
 0x4de0: mov    w1, wzr
 0x4de4: mov    x4, x19
 0x4de8: mov    w6, w20
 0x4dec: bl     #0x2368 ; <duss_log_gen_head>
 0x4df0: cbz    w0, #0x4e2c
 0x4df4: ldr    x5, [sp, #0x20]
 0x4df8: adrp   x3, #0x1a000
 0x4dfc: ldr    w6, [sp, #0x1c]
 0x4e00: adrp   x4, #0x1a000
 0x4e04: adrp   x7, #0x1a000
 0x4e08: str    w20, [sp, #8]
 0x4e0c: mov    w1, wzr
 0x4e10: str    x19, [sp]
 0x4e14: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4e18: add    x4, x4, #0x441 ; "co"
 0x4e1c: mov    w0, #0x51
 0x4e20: add    x7, x7, #0x5c0 ; "ops"
 0x4e24: add    x2, sp, #0x28
 0x4e28: bl     #0x2378 ; <duss_log_print>
 0x4e2c: adrp   x4, #0x1a000
 0x4e30: adrp   x5, #0x1a000
 0x4e34: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4e38: add    x5, x5, #0x7fd ; "_proresraw_venc_eng_set_param"
 0x4e3c: mov    w0, #0x51
 0x4e40: mov    w6, #0xf5
 0x4e44: b      #0x4ee8
 0x4e48: adrp   x8, #0x1a000
 0x4e4c: str    wzr, [sp, #0x1c]
 0x4e50: add    x8, x8, #0x440 ; =0x1a440
 0x4e54: add    x1, sp, #0x20
 0x4e58: add    x2, sp, #0x1c
 0x4e5c: str    x8, [sp, #0x20]
 0x4e60: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4e64: adrp   x19, #0x1a000
 0x4e68: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4e6c: adrp   x5, #0x1a000
 0x4e70: mov    w20, #0xf6
 0x4e74: add    x5, x5, #0x7fd ; "_proresraw_venc_eng_set_param"
 0x4e78: mov    w0, #0x51
 0x4e7c: add    x2, sp, #0x28
 0x4e80: mov    w3, #0x80
 0x4e84: mov    w1, wzr
 0x4e88: mov    x4, x19
 0x4e8c: mov    w6, w20
 0x4e90: bl     #0x2368 ; <duss_log_gen_head>
 0x4e94: cbz    w0, #0x4ed0
 0x4e98: ldr    x5, [sp, #0x20]
 0x4e9c: adrp   x3, #0x1a000
 0x4ea0: ldr    w6, [sp, #0x1c]
 0x4ea4: adrp   x4, #0x1a000
 0x4ea8: adrp   x7, #0x1a000
 0x4eac: str    w20, [sp, #8]
 0x4eb0: mov    w1, wzr
 0x4eb4: str    x19, [sp]
 0x4eb8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x4ebc: add    x4, x4, #0x441 ; "co"
 0x4ec0: mov    w0, #0x51
 0x4ec4: add    x7, x7, #0x81b ; "param"
 0x4ec8: add    x2, sp, #0x28
 0x4ecc: bl     #0x2378 ; <duss_log_print>
 0x4ed0: adrp   x4, #0x1a000
 0x4ed4: adrp   x5, #0x1a000
 0x4ed8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4edc: add    x5, x5, #0x7fd ; "_proresraw_venc_eng_set_param"
 0x4ee0: mov    w0, #0x51
 0x4ee4: mov    w6, #0xf6
 0x4ee8: add    x2, sp, #0x28
 0x4eec: mov    w3, #0x80
 0x4ef0: mov    w1, wzr
 0x4ef4: bl     #0x2368 ; <duss_log_gen_head>
 0x4ef8: cbz    w0, #0x4f14
 0x4efc: adrp   x3, #0x1a000
 0x4f00: add    x3, x3, #0x550 ; "Assertion Comment: "
 0x4f04: mov    w0, #0x51
 0x4f08: add    x2, sp, #0x28
 0x4f0c: mov    w1, wzr
 0x4f10: bl     #0x2378 ; <duss_log_print>
 0x4f14: adrp   x0, #0x1a000
 0x4f18: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0x4f1c: bl     #0x23e8 ; <log_to_kmsg>
 0x4f20: adrp   x0, #0x1a000
 0x4f24: add    x0, x0, #0x57f ; "Camera:	"
 0x4f28: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0x4f2c: bl     #0x2408 ; <is_running_in_cam_sil>
 0x4f30: tbz    w0, #0, #0x4f40
 0x4f34: mov    x0, xzr
 0x4f38: bl     #0x2418 ; <fflush>
 0x4f3c: bl     #0x2428 ; <abort>
 0x4f40: mov    w0, #1
 0x4f44: bl     #0x2438 ; <exit>
 0x4f48: sub    sp, sp, #0xf0
 0x4f4c: stp    x22, x21, [sp, #0xc0]
 0x4f50: stp    x20, x19, [sp, #0xd0]
 0x4f54: stp    x29, x30, [sp, #0xe0]
 0x4f58: add    x29, sp, #0xe0
 0x4f5c: mrs    x21, tpidr_el0
 0x4f60: mov    x19, x0
 0x4f64: ldr    x8, [x21, #0x28]
 0x4f68: adrp   x0, #0x30000
 0x4f6c: adrp   x2, #0x1a000
 0x4f70: add    x22, sp, #0x10
 0x4f74: add    x0, x0, #8 ; =0x30008
 0x4f78: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x4f7c: mov    w1, #3
 0x4f80: str    x8, [x22]
 0x4f84: bl     #0x2338 ; <log_mgr_check>
 0x4f88: tbz    w0, #0, #0x5060
 0x4f8c: bl     #0x2348 ; <co_thread_get>
 0x4f90: cbz    x0, #0x5014
 0x4f94: adrp   x8, #0x1a000
 0x4f98: str    wzr, [sp, #0x20]
 0x4f9c: add    x8, x8, #0x440 ; =0x1a440
 0x4fa0: add    x1, sp, #0x28
 0x4fa4: add    x2, sp, #0x20
 0x4fa8: str    x8, [sp, #0x28]
 0x4fac: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x4fb0: adrp   x4, #0x1a000
 0x4fb4: adrp   x5, #0x1a000
 0x4fb8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x4fbc: add    x5, x5, #0x849 ; "_proresraw_venc_eng_start"
 0x4fc0: mov    w0, #0x51
 0x4fc4: mov    w6, #0x108
 0x4fc8: mov    w1, #3
 0x4fcc: add    x2, sp, #0x38
 0x4fd0: mov    w3, #0x80
 0x4fd4: bl     #0x2368 ; <duss_log_gen_head>
 0x4fd8: cbz    w0, #0x5060
 0x4fdc: ldr    x6, [sp, #0x28]
 0x4fe0: adrp   x3, #0x1a000
 0x4fe4: ldr    w7, [sp, #0x20]
 0x4fe8: adrp   x4, #0x1a000
 0x4fec: adrp   x5, #0x1a000
 0x4ff0: add    x3, x3, #0x863 ; "%s: %s(%s_%x): start_enc
"
 0x4ff4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x4ff8: add    x5, x5, #0x441 ; "co"
 0x4ffc: mov    w0, #0x51
 0x5000: mov    w1, #3
 0x5004: add    x2, sp, #0x38
 0x5008: bl     #0x2378 ; <duss_log_print>
 0x500c: cbnz   x19, #0x5064
 0x5010: b      #0x54ec
 0x5014: adrp   x4, #0x1a000
 0x5018: adrp   x5, #0x1a000
 0x501c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5020: add    x5, x5, #0x849 ; "_proresraw_venc_eng_start"
 0x5024: mov    w0, #0x51
 0x5028: mov    w6, #0x108
 0x502c: mov    w1, #3
 0x5030: add    x2, sp, #0x38
 0x5034: mov    w3, #0x80
 0x5038: bl     #0x2368 ; <duss_log_gen_head>
 0x503c: cbz    w0, #0x5060
 0x5040: adrp   x3, #0x1a000
 0x5044: adrp   x4, #0x1a000
 0x5048: add    x3, x3, #0x87d ; "%s: start_enc
"
 0x504c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5050: mov    w0, #0x51
 0x5054: mov    w1, #3
 0x5058: add    x2, sp, #0x38
 0x505c: bl     #0x2378 ; <duss_log_print>
 0x5060: cbz    x19, #0x54ec
 0x5064: ldr    w8, [x19, #0xb0]
 0x5068: mov    w9, #-0x2721
 0x506c: stp    xzr, xzr, [sp, #0x28]
 0x5070: add    w9, w8, w9
 0x5074: cmp    w9, #0x3b
 0x5078: b.hi   #0x5488
 0x507c: mov    x11, #0xc411
 0x5080: movk   x11, #0x6208, lsl #16
 0x5084: movk   x11, #0x3104, lsl #32
 0x5088: mov    w10, #1
 0x508c: movk   x11, #0x882, lsl #48
 0x5090: lsl    x9, x10, x9
 0x5094: tst    x9, x11
 0x5098: b.eq   #0x5488
 0x509c: ldr    w9, [x19, #0x3e0]
 0x50a0: str    w8, [sp, #0x34]
 0x50a4: cmp    w9, #5
 0x50a8: b.hs   #0x5550
 0x50ac: ldr    w8, [x19, #0xb8]
 0x50b0: str    w9, [sp, #0x30]
 0x50b4: cmp    w8, #0
 0x50b8: b.le   #0x55b4
 0x50bc: ldr    w9, [x19, #0xbc]
 0x50c0: str    w8, [sp, #0x28]
 0x50c4: cmp    w9, #0
 0x50c8: b.le   #0x56bc
 0x50cc: adrp   x0, #0x30000
 0x50d0: str    w9, [sp, #0x2c]
 0x50d4: adrp   x2, #0x1a000
 0x50d8: add    x0, x0, #8 ; =0x30008
 0x50dc: mov    w1, #5
 0x50e0: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x50e4: bl     #0x2338 ; <log_mgr_check>
 0x50e8: tbz    w0, #0, #0x51bc
 0x50ec: bl     #0x2348 ; <co_thread_get>
 0x50f0: cbz    x0, #0x5170
 0x50f4: adrp   x8, #0x1a000
 0x50f8: str    wzr, [sp, #0x1c]
 0x50fc: add    x8, x8, #0x440 ; =0x1a440
 0x5100: add    x1, sp, #0x20
 0x5104: add    x2, sp, #0x1c
 0x5108: str    x8, [sp, #0x20]
 0x510c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5110: adrp   x4, #0x1a000
 0x5114: adrp   x5, #0x1a000
 0x5118: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x511c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5120: mov    w0, #0x51
 0x5124: mov    w6, #0x668
 0x5128: mov    w1, #3
 0x512c: add    x2, sp, #0x38
 0x5130: mov    w3, #0x80
 0x5134: bl     #0x2368 ; <duss_log_gen_head>
 0x5138: cbz    w0, #0x51bc
 0x513c: ldr    x6, [sp, #0x20]
 0x5140: adrp   x3, #0x1a000
 0x5144: ldr    w7, [sp, #0x1c]
 0x5148: adrp   x4, #0x1a000
 0x514c: adrp   x5, #0x1a000
 0x5150: add    x3, x3, #0x94f ; "%s: %s(%s_%x): before duss_hal_device_start
"
 0x5154: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5158: add    x5, x5, #0x441 ; "co"
 0x515c: mov    w0, #0x51
 0x5160: mov    w1, #3
 0x5164: add    x2, sp, #0x38
 0x5168: bl     #0x2378 ; <duss_log_print>
 0x516c: b      #0x51bc
 0x5170: adrp   x4, #0x1a000
 0x5174: adrp   x5, #0x1a000
 0x5178: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x517c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5180: mov    w0, #0x51
 0x5184: mov    w6, #0x668
 0x5188: mov    w1, #3
 0x518c: add    x2, sp, #0x38
 0x5190: mov    w3, #0x80
 0x5194: bl     #0x2368 ; <duss_log_gen_head>
 0x5198: cbz    w0, #0x51bc
 0x519c: adrp   x3, #0x1a000
 0x51a0: adrp   x4, #0x1a000
 0x51a4: add    x3, x3, #0x97c ; "%s: before duss_hal_device_start
"
 0x51a8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x51ac: mov    w0, #0x51
 0x51b0: mov    w1, #3
 0x51b4: add    x2, sp, #0x38
 0x51b8: bl     #0x2378 ; <duss_log_print>
 0x51bc: ldr    x0, [x19, #0xa0]
 0x51c0: add    x1, sp, #0x28
 0x51c4: bl     #0x2458 ; <duss_hal_device_start>
 0x51c8: mov    w20, w0
 0x51cc: adrp   x0, #0x30000
 0x51d0: adrp   x2, #0x1a000
 0x51d4: add    x0, x0, #8 ; =0x30008
 0x51d8: mov    w1, #5
 0x51dc: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x51e0: bl     #0x2338 ; <log_mgr_check>
 0x51e4: tbz    w0, #0, #0x52bc
 0x51e8: bl     #0x2348 ; <co_thread_get>
 0x51ec: cbz    x0, #0x5270
 0x51f0: adrp   x8, #0x1a000
 0x51f4: str    wzr, [sp, #0x1c]
 0x51f8: add    x8, x8, #0x440 ; =0x1a440
 0x51fc: add    x1, sp, #0x20
 0x5200: add    x2, sp, #0x1c
 0x5204: str    x8, [sp, #0x20]
 0x5208: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x520c: adrp   x4, #0x1a000
 0x5210: adrp   x5, #0x1a000
 0x5214: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5218: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x521c: mov    w0, #0x51
 0x5220: mov    w6, #0x66a
 0x5224: mov    w1, #3
 0x5228: add    x2, sp, #0x38
 0x522c: mov    w3, #0x80
 0x5230: bl     #0x2368 ; <duss_log_gen_head>
 0x5234: cbz    w0, #0x52bc
 0x5238: ldr    x6, [sp, #0x20]
 0x523c: adrp   x3, #0x1a000
 0x5240: ldr    w7, [sp, #0x1c]
 0x5244: adrp   x4, #0x1a000
 0x5248: adrp   x5, #0x1a000
 0x524c: add    x3, x3, #0x99e ; "%s: %s(%s_%x): after duss_hal_device_start
"
 0x5250: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5254: add    x5, x5, #0x441 ; "co"
 0x5258: mov    w0, #0x51
 0x525c: mov    w1, #3
 0x5260: add    x2, sp, #0x38
 0x5264: bl     #0x2378 ; <duss_log_print>
 0x5268: cbnz   w20, #0x52c0
 0x526c: b      #0x5460
 0x5270: adrp   x4, #0x1a000
 0x5274: adrp   x5, #0x1a000
 0x5278: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x527c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5280: mov    w0, #0x51
 0x5284: mov    w6, #0x66a
 0x5288: mov    w1, #3
 0x528c: add    x2, sp, #0x38
 0x5290: mov    w3, #0x80
 0x5294: bl     #0x2368 ; <duss_log_gen_head>
 0x5298: cbz    w0, #0x52bc
 0x529c: adrp   x3, #0x1a000
 0x52a0: adrp   x4, #0x1a000
 0x52a4: add    x3, x3, #0x9ca ; "%s: after duss_hal_device_start
"
 0x52a8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x52ac: mov    w0, #0x51
 0x52b0: mov    w1, #3
 0x52b4: add    x2, sp, #0x38
 0x52b8: bl     #0x2378 ; <duss_log_print>
 0x52bc: cbz    w20, #0x5460
 0x52c0: adrp   x0, #0x30000
 0x52c4: adrp   x2, #0x1a000
 0x52c8: add    x0, x0, #8 ; =0x30008
 0x52cc: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x52d0: mov    w1, #1
 0x52d4: bl     #0x2338 ; <log_mgr_check>
 0x52d8: tbz    w0, #0, #0x5454
 0x52dc: bl     #0x2348 ; <co_thread_get>
 0x52e0: cbz    x0, #0x53b4
 0x52e4: adrp   x8, #0x1a000
 0x52e8: str    wzr, [sp, #0x1c]
 0x52ec: add    x8, x8, #0x440 ; =0x1a440
 0x52f0: add    x1, sp, #0x20
 0x52f4: add    x2, sp, #0x1c
 0x52f8: str    x8, [sp, #0x20]
 0x52fc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5300: adrp   x4, #0x1a000
 0x5304: adrp   x5, #0x1a000
 0x5308: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x530c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5310: mov    w0, #0x51
 0x5314: mov    w6, #0x66c
 0x5318: mov    w1, #1
 0x531c: add    x2, sp, #0x38
 0x5320: mov    w3, #0x80
 0x5324: bl     #0x2368 ; <duss_log_gen_head>
 0x5328: cbz    w0, #0x5350
 0x532c: adrp   x3, #0x1a000
 0x5330: adrp   x4, #0x1a000
 0x5334: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x5338: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x533c: mov    w0, #0x51
 0x5340: mov    w5, #0x66c
 0x5344: mov    w1, #1
 0x5348: add    x2, sp, #0x38
 0x534c: bl     #0x2378 ; <duss_log_print>
 0x5350: adrp   x4, #0x1a000
 0x5354: adrp   x5, #0x1a000
 0x5358: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x535c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5360: mov    w0, #0x51
 0x5364: mov    w6, #0x66c
 0x5368: mov    w1, #1
 0x536c: add    x2, sp, #0x38
 0x5370: mov    w3, #0x80
 0x5374: bl     #0x2368 ; <duss_log_gen_head>
 0x5378: cbz    w0, #0x5454
 0x537c: ldr    x6, [sp, #0x20]
 0x5380: adrp   x3, #0x1a000
 0x5384: ldr    w7, [sp, #0x1c]
 0x5388: adrp   x4, #0x1a000
 0x538c: adrp   x5, #0x1a000
 0x5390: str    w20, [sp]
 0x5394: add    x3, x3, #0x9eb ; "%s: %s(%s_%x): duss_hal_device_start() error: %d
"
 0x5398: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x539c: add    x5, x5, #0x441 ; "co"
 0x53a0: mov    w0, #0x51
 0x53a4: mov    w1, #1
 0x53a8: add    x2, sp, #0x38
 0x53ac: bl     #0x2378 ; <duss_log_print>
 0x53b0: b      #0x5454
 0x53b4: adrp   x4, #0x1a000
 0x53b8: adrp   x5, #0x1a000
 0x53bc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x53c0: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x53c4: mov    w0, #0x51
 0x53c8: mov    w6, #0x66c
 0x53cc: mov    w1, #1
 0x53d0: add    x2, sp, #0x38
 0x53d4: mov    w3, #0x80
 0x53d8: bl     #0x2368 ; <duss_log_gen_head>
 0x53dc: cbz    w0, #0x5404
 0x53e0: adrp   x3, #0x1a000
 0x53e4: adrp   x4, #0x1a000
 0x53e8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x53ec: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x53f0: mov    w0, #0x51
 0x53f4: mov    w5, #0x66c
 0x53f8: mov    w1, #1
 0x53fc: add    x2, sp, #0x38
 0x5400: bl     #0x2378 ; <duss_log_print>
 0x5404: adrp   x4, #0x1a000
 0x5408: adrp   x5, #0x1a000
 0x540c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5410: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5414: mov    w0, #0x51
 0x5418: mov    w6, #0x66c
 0x541c: mov    w1, #1
 0x5420: add    x2, sp, #0x38
 0x5424: mov    w3, #0x80
 0x5428: bl     #0x2368 ; <duss_log_gen_head>
 0x542c: cbz    w0, #0x5454
 0x5430: adrp   x3, #0x1a000
 0x5434: adrp   x4, #0x1a000
 0x5438: add    x3, x3, #0xa1d ; "%s: duss_hal_device_start() error: %d
"
 0x543c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5440: mov    w0, #0x51
 0x5444: mov    w1, #1
 0x5448: add    x2, sp, #0x38
 0x544c: mov    w5, w20
 0x5450: bl     #0x2378 ; <duss_log_print>
 0x5454: ldr    x0, [x19, #0xa0]
 0x5458: bl     #0x23a8 ; <duss_hal_device_close>
 0x545c: str    xzr, [x19, #0xa0]
 0x5460: ldr    x8, [x21, #0x28]
 0x5464: ldr    x9, [x22]
 0x5468: cmp    x8, x9
 0x546c: b.ne   #0x5720
 0x5470: mov    w0, w20
 0x5474: ldp    x29, x30, [sp, #0xe0]
 0x5478: ldp    x20, x19, [sp, #0xd0]
 0x547c: ldp    x22, x21, [sp, #0xc0]
 0x5480: add    sp, sp, #0xf0
 0x5484: ret    
 0x5488: bl     #0x2348 ; <co_thread_get>
 0x548c: cbnz   x0, #0x5618
 0x5490: adrp   x4, #0x1a000
 0x5494: adrp   x5, #0x1a000
 0x5498: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x549c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x54a0: mov    w0, #0x51
 0x54a4: mov    w6, #0x65b
 0x54a8: add    x2, sp, #0x38
 0x54ac: mov    w3, #0x80
 0x54b0: mov    w1, wzr
 0x54b4: bl     #0x2368 ; <duss_log_gen_head>
 0x54b8: cbz    w0, #0x56a0
 0x54bc: adrp   x3, #0x1a000
 0x54c0: adrp   x4, #0x1a000
 0x54c4: adrp   x5, #0x1a000
 0x54c8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x54cc: add    x4, x4, #0x8ad ; "is_valid_input_format(eng->config.base.input_format)"
 0x54d0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x54d4: mov    w0, #0x51
 0x54d8: mov    w6, #0x65b
 0x54dc: add    x2, sp, #0x38
 0x54e0: mov    w1, wzr
 0x54e4: bl     #0x2378 ; <duss_log_print>
 0x54e8: b      #0x56a0
 0x54ec: bl     #0x2348 ; <co_thread_get>
 0x54f0: cbnz   x0, #0x5724
 0x54f4: adrp   x4, #0x1a000
 0x54f8: adrp   x5, #0x1a000
 0x54fc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5500: add    x5, x5, #0x849 ; "_proresraw_venc_eng_start"
 0x5504: mov    w0, #0x51
 0x5508: mov    w6, #0x10a
 0x550c: add    x2, sp, #0x38
 0x5510: mov    w3, #0x80
 0x5514: mov    w1, wzr
 0x5518: bl     #0x2368 ; <duss_log_gen_head>
 0x551c: cbz    w0, #0x57ac
 0x5520: adrp   x3, #0x1a000
 0x5524: adrp   x4, #0x1a000
 0x5528: adrp   x5, #0x1a000
 0x552c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x5530: add    x4, x4, #0x5c0 ; "ops"
 0x5534: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5538: mov    w0, #0x51
 0x553c: mov    w6, #0x10a
 0x5540: add    x2, sp, #0x38
 0x5544: mov    w1, wzr
 0x5548: bl     #0x2378 ; <duss_log_print>
 0x554c: b      #0x57ac
 0x5550: bl     #0x2348 ; <co_thread_get>
 0x5554: cbnz   x0, #0x57c8
 0x5558: adrp   x4, #0x1a000
 0x555c: adrp   x5, #0x1a000
 0x5560: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5564: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5568: mov    w0, #0x51
 0x556c: mov    w6, #0x65f
 0x5570: add    x2, sp, #0x38
 0x5574: mov    w3, #0x80
 0x5578: mov    w1, wzr
 0x557c: bl     #0x2368 ; <duss_log_gen_head>
 0x5580: cbz    w0, #0x5850
 0x5584: adrp   x3, #0x1a000
 0x5588: adrp   x4, #0x1a000
 0x558c: adrp   x5, #0x1a000
 0x5590: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x5594: add    x4, x4, #0x8e2 ; "eng->profile <= DUSS_PRORESRAW_PROFILE_XQ"
 0x5598: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x559c: mov    w0, #0x51
 0x55a0: mov    w6, #0x65f
 0x55a4: add    x2, sp, #0x38
 0x55a8: mov    w1, wzr
 0x55ac: bl     #0x2378 ; <duss_log_print>
 0x55b0: b      #0x5850
 0x55b4: bl     #0x2348 ; <co_thread_get>
 0x55b8: cbnz   x0, #0x586c
 0x55bc: adrp   x4, #0x1a000
 0x55c0: adrp   x5, #0x1a000
 0x55c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x55c8: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x55cc: mov    w0, #0x51
 0x55d0: mov    w6, #0x662
 0x55d4: add    x2, sp, #0x38
 0x55d8: mov    w3, #0x80
 0x55dc: mov    w1, wzr
 0x55e0: bl     #0x2368 ; <duss_log_gen_head>
 0x55e4: cbz    w0, #0x58f4
 0x55e8: adrp   x3, #0x1a000
 0x55ec: adrp   x4, #0x1a000
 0x55f0: adrp   x5, #0x1a000
 0x55f4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x55f8: add    x4, x4, #0x90c ; "eng->config.base.input_width > 0"
 0x55fc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5600: mov    w0, #0x51
 0x5604: mov    w6, #0x662
 0x5608: add    x2, sp, #0x38
 0x560c: mov    w1, wzr
 0x5610: bl     #0x2378 ; <duss_log_print>
 0x5614: b      #0x58f4
 0x5618: adrp   x8, #0x1a000
 0x561c: str    wzr, [sp, #0x1c]
 0x5620: add    x8, x8, #0x440 ; =0x1a440
 0x5624: add    x1, sp, #0x20
 0x5628: add    x2, sp, #0x1c
 0x562c: str    x8, [sp, #0x20]
 0x5630: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5634: adrp   x19, #0x1a000
 0x5638: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x563c: adrp   x5, #0x1a000
 0x5640: mov    w20, #0x65b
 0x5644: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5648: mov    w0, #0x51
 0x564c: add    x2, sp, #0x38
 0x5650: mov    w3, #0x80
 0x5654: mov    w1, wzr
 0x5658: mov    x4, x19
 0x565c: mov    w6, w20
 0x5660: bl     #0x2368 ; <duss_log_gen_head>
 0x5664: cbz    w0, #0x56a0
 0x5668: ldr    x5, [sp, #0x20]
 0x566c: adrp   x3, #0x1a000
 0x5670: ldr    w6, [sp, #0x1c]
 0x5674: adrp   x4, #0x1a000
 0x5678: adrp   x7, #0x1a000
 0x567c: str    w20, [sp, #8]
 0x5680: mov    w1, wzr
 0x5684: str    x19, [sp]
 0x5688: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x568c: add    x4, x4, #0x441 ; "co"
 0x5690: mov    w0, #0x51
 0x5694: add    x7, x7, #0x8ad ; "is_valid_input_format(eng->config.base.input_format)"
 0x5698: add    x2, sp, #0x38
 0x569c: bl     #0x2378 ; <duss_log_print>
 0x56a0: adrp   x4, #0x1a000
 0x56a4: adrp   x5, #0x1a000
 0x56a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x56ac: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x56b0: mov    w0, #0x51
 0x56b4: mov    w6, #0x65b
 0x56b8: b      #0x59b0
 0x56bc: bl     #0x2348 ; <co_thread_get>
 0x56c0: cbnz   x0, #0x5910
 0x56c4: adrp   x4, #0x1a000
 0x56c8: adrp   x5, #0x1a000
 0x56cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x56d0: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x56d4: mov    w0, #0x51
 0x56d8: mov    w6, #0x665
 0x56dc: add    x2, sp, #0x38
 0x56e0: mov    w3, #0x80
 0x56e4: mov    w1, wzr
 0x56e8: bl     #0x2368 ; <duss_log_gen_head>
 0x56ec: cbz    w0, #0x5998
 0x56f0: adrp   x3, #0x1a000
 0x56f4: adrp   x4, #0x1a000
 0x56f8: adrp   x5, #0x1a000
 0x56fc: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x5700: add    x4, x4, #0x92d ; "eng->config.base.input_height > 0"
 0x5704: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5708: mov    w0, #0x51
 0x570c: mov    w6, #0x665
 0x5710: add    x2, sp, #0x38
 0x5714: mov    w1, wzr
 0x5718: bl     #0x2378 ; <duss_log_print>
 0x571c: b      #0x5998
 0x5720: bl     #0x23d8 ; <__stack_chk_fail>
 0x5724: adrp   x8, #0x1a000
 0x5728: str    wzr, [sp, #0x20]
 0x572c: add    x8, x8, #0x440 ; =0x1a440
 0x5730: add    x1, sp, #0x28
 0x5734: add    x2, sp, #0x20
 0x5738: str    x8, [sp, #0x28]
 0x573c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5740: adrp   x19, #0x1a000
 0x5744: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5748: adrp   x5, #0x1a000
 0x574c: mov    w20, #0x10a
 0x5750: add    x5, x5, #0x849 ; "_proresraw_venc_eng_start"
 0x5754: mov    w0, #0x51
 0x5758: add    x2, sp, #0x38
 0x575c: mov    w3, #0x80
 0x5760: mov    w1, wzr
 0x5764: mov    x4, x19
 0x5768: mov    w6, w20
 0x576c: bl     #0x2368 ; <duss_log_gen_head>
 0x5770: cbz    w0, #0x57ac
 0x5774: ldr    x5, [sp, #0x28]
 0x5778: adrp   x3, #0x1a000
 0x577c: ldr    w6, [sp, #0x20]
 0x5780: adrp   x4, #0x1a000
 0x5784: adrp   x7, #0x1a000
 0x5788: str    w20, [sp, #8]
 0x578c: mov    w1, wzr
 0x5790: str    x19, [sp]
 0x5794: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x5798: add    x4, x4, #0x441 ; "co"
 0x579c: mov    w0, #0x51
 0x57a0: add    x7, x7, #0x5c0 ; "ops"
 0x57a4: add    x2, sp, #0x38
 0x57a8: bl     #0x2378 ; <duss_log_print>
 0x57ac: adrp   x4, #0x1a000
 0x57b0: adrp   x5, #0x1a000
 0x57b4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x57b8: add    x5, x5, #0x849 ; "_proresraw_venc_eng_start"
 0x57bc: mov    w0, #0x51
 0x57c0: mov    w6, #0x10a
 0x57c4: b      #0x59b0
 0x57c8: adrp   x8, #0x1a000
 0x57cc: str    wzr, [sp, #0x1c]
 0x57d0: add    x8, x8, #0x440 ; =0x1a440
 0x57d4: add    x1, sp, #0x20
 0x57d8: add    x2, sp, #0x1c
 0x57dc: str    x8, [sp, #0x20]
 0x57e0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x57e4: adrp   x19, #0x1a000
 0x57e8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x57ec: adrp   x5, #0x1a000
 0x57f0: mov    w20, #0x65f
 0x57f4: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x57f8: mov    w0, #0x51
 0x57fc: add    x2, sp, #0x38
 0x5800: mov    w3, #0x80
 0x5804: mov    w1, wzr
 0x5808: mov    x4, x19
 0x580c: mov    w6, w20
 0x5810: bl     #0x2368 ; <duss_log_gen_head>
 0x5814: cbz    w0, #0x5850
 0x5818: ldr    x5, [sp, #0x20]
 0x581c: adrp   x3, #0x1a000
 0x5820: ldr    w6, [sp, #0x1c]
 0x5824: adrp   x4, #0x1a000
 0x5828: adrp   x7, #0x1a000
 0x582c: str    w20, [sp, #8]
 0x5830: mov    w1, wzr
 0x5834: str    x19, [sp]
 0x5838: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x583c: add    x4, x4, #0x441 ; "co"
 0x5840: mov    w0, #0x51
 0x5844: add    x7, x7, #0x8e2 ; "eng->profile <= DUSS_PRORESRAW_PROFILE_XQ"
 0x5848: add    x2, sp, #0x38
 0x584c: bl     #0x2378 ; <duss_log_print>
 0x5850: adrp   x4, #0x1a000
 0x5854: adrp   x5, #0x1a000
 0x5858: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x585c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5860: mov    w0, #0x51
 0x5864: mov    w6, #0x65f
 0x5868: b      #0x59b0
 0x586c: adrp   x8, #0x1a000
 0x5870: str    wzr, [sp, #0x1c]
 0x5874: add    x8, x8, #0x440 ; =0x1a440
 0x5878: add    x1, sp, #0x20
 0x587c: add    x2, sp, #0x1c
 0x5880: str    x8, [sp, #0x20]
 0x5884: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5888: adrp   x19, #0x1a000
 0x588c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5890: adrp   x5, #0x1a000
 0x5894: mov    w20, #0x662
 0x5898: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x589c: mov    w0, #0x51
 0x58a0: add    x2, sp, #0x38
 0x58a4: mov    w3, #0x80
 0x58a8: mov    w1, wzr
 0x58ac: mov    x4, x19
 0x58b0: mov    w6, w20
 0x58b4: bl     #0x2368 ; <duss_log_gen_head>
 0x58b8: cbz    w0, #0x58f4
 0x58bc: ldr    x5, [sp, #0x20]
 0x58c0: adrp   x3, #0x1a000
 0x58c4: ldr    w6, [sp, #0x1c]
 0x58c8: adrp   x4, #0x1a000
 0x58cc: adrp   x7, #0x1a000
 0x58d0: str    w20, [sp, #8]
 0x58d4: mov    w1, wzr
 0x58d8: str    x19, [sp]
 0x58dc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x58e0: add    x4, x4, #0x441 ; "co"
 0x58e4: mov    w0, #0x51
 0x58e8: add    x7, x7, #0x90c ; "eng->config.base.input_width > 0"
 0x58ec: add    x2, sp, #0x38
 0x58f0: bl     #0x2378 ; <duss_log_print>
 0x58f4: adrp   x4, #0x1a000
 0x58f8: adrp   x5, #0x1a000
 0x58fc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5900: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5904: mov    w0, #0x51
 0x5908: mov    w6, #0x662
 0x590c: b      #0x59b0
 0x5910: adrp   x8, #0x1a000
 0x5914: str    wzr, [sp, #0x1c]
 0x5918: add    x8, x8, #0x440 ; =0x1a440
 0x591c: add    x1, sp, #0x20
 0x5920: add    x2, sp, #0x1c
 0x5924: str    x8, [sp, #0x20]
 0x5928: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x592c: adrp   x19, #0x1a000
 0x5930: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5934: adrp   x5, #0x1a000
 0x5938: mov    w20, #0x665
 0x593c: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x5940: mov    w0, #0x51
 0x5944: add    x2, sp, #0x38
 0x5948: mov    w3, #0x80
 0x594c: mov    w1, wzr
 0x5950: mov    x4, x19
 0x5954: mov    w6, w20
 0x5958: bl     #0x2368 ; <duss_log_gen_head>
 0x595c: cbz    w0, #0x5998
 0x5960: ldr    x5, [sp, #0x20]
 0x5964: adrp   x3, #0x1a000
 0x5968: ldr    w6, [sp, #0x1c]
 0x596c: adrp   x4, #0x1a000
 0x5970: adrp   x7, #0x1a000
 0x5974: str    w20, [sp, #8]
 0x5978: mov    w1, wzr
 0x597c: str    x19, [sp]
 0x5980: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x5984: add    x4, x4, #0x441 ; "co"
 0x5988: mov    w0, #0x51
 0x598c: add    x7, x7, #0x92d ; "eng->config.base.input_height > 0"
 0x5990: add    x2, sp, #0x38
 0x5994: bl     #0x2378 ; <duss_log_print>
 0x5998: adrp   x4, #0x1a000
 0x599c: adrp   x5, #0x1a000
 0x59a0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x59a4: add    x5, x5, #0x88c ; "_proresraw_venc_eng_start_device"
 0x59a8: mov    w0, #0x51
 0x59ac: mov    w6, #0x665
 0x59b0: add    x2, sp, #0x38
 0x59b4: mov    w3, #0x80
 0x59b8: mov    w1, wzr
 0x59bc: bl     #0x2368 ; <duss_log_gen_head>
 0x59c0: cbz    w0, #0x59dc
 0x59c4: adrp   x3, #0x1a000
 0x59c8: add    x3, x3, #0x550 ; "Assertion Comment: "
 0x59cc: mov    w0, #0x51
 0x59d0: add    x2, sp, #0x38
 0x59d4: mov    w1, wzr
 0x59d8: bl     #0x2378 ; <duss_log_print>
 0x59dc: adrp   x0, #0x1a000
 0x59e0: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0x59e4: bl     #0x23e8 ; <log_to_kmsg>
 0x59e8: adrp   x0, #0x1a000
 0x59ec: add    x0, x0, #0x57f ; "Camera:	"
 0x59f0: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0x59f4: bl     #0x2408 ; <is_running_in_cam_sil>
 0x59f8: tbz    w0, #0, #0x5a08
 0x59fc: mov    x0, xzr
 0x5a00: bl     #0x2418 ; <fflush>
 0x5a04: bl     #0x2428 ; <abort>
 0x5a08: mov    w0, #1
 0x5a0c: bl     #0x2438 ; <exit>
 0x5a10: sub    sp, sp, #0x1e0
 0x5a14: stp    x28, x27, [sp, #0x180]
 0x5a18: stp    x26, x25, [sp, #0x190]
 0x5a1c: stp    x24, x23, [sp, #0x1a0]
 0x5a20: stp    x22, x21, [sp, #0x1b0]
 0x5a24: stp    x20, x19, [sp, #0x1c0]
 0x5a28: stp    x29, x30, [sp, #0x1d0]
 0x5a2c: add    x29, sp, #0x1d0
 0x5a30: mrs    x20, tpidr_el0
 0x5a34: mov    x19, x0
 0x5a38: ldr    x8, [x20, #0x28]
 0x5a3c: adrp   x0, #0x30000
 0x5a40: adrp   x2, #0x1a000
 0x5a44: add    x9, sp, #0x28
 0x5a48: add    x0, x0, #8 ; =0x30008
 0x5a4c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x5a50: mov    w1, #3
 0x5a54: str    x8, [x9]
 0x5a58: bl     #0x2338 ; <log_mgr_check>
 0x5a5c: tbz    w0, #0, #0x5b34
 0x5a60: bl     #0x2348 ; <co_thread_get>
 0x5a64: cbz    x0, #0x5ae8
 0x5a68: adrp   x8, #0x1a000
 0x5a6c: str    wzr, [sp, #0x38]
 0x5a70: add    x8, x8, #0x440 ; =0x1a440
 0x5a74: add    x1, sp, #0x40
 0x5a78: add    x2, sp, #0x38
 0x5a7c: str    x8, [sp, #0x40]
 0x5a80: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5a84: adrp   x4, #0x1a000
 0x5a88: adrp   x5, #0x1a000
 0x5a8c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5a90: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5a94: mov    w0, #0x51
 0x5a98: mov    w6, #0x123
 0x5a9c: mov    w1, #3
 0x5aa0: add    x2, sp, #0xc0
 0x5aa4: mov    w3, #0x80
 0x5aa8: bl     #0x2368 ; <duss_log_gen_head>
 0x5aac: cbz    w0, #0x5b34
 0x5ab0: ldr    x6, [sp, #0x40]
 0x5ab4: adrp   x3, #0x1a000
 0x5ab8: ldr    w7, [sp, #0x38]
 0x5abc: adrp   x4, #0x1a000
 0x5ac0: adrp   x5, #0x1a000
 0x5ac4: add    x3, x3, #0xa5d ; "%s: %s(%s_%x): ================ venc_eng stopping ... ================
"
 0x5ac8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5acc: add    x5, x5, #0x441 ; "co"
 0x5ad0: mov    w0, #0x51
 0x5ad4: mov    w1, #3
 0x5ad8: add    x2, sp, #0xc0
 0x5adc: bl     #0x2378 ; <duss_log_print>
 0x5ae0: cbnz   x19, #0x5b38
 0x5ae4: b      #0x6598
 0x5ae8: adrp   x4, #0x1a000
 0x5aec: adrp   x5, #0x1a000
 0x5af0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5af4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5af8: mov    w0, #0x51
 0x5afc: mov    w6, #0x123
 0x5b00: mov    w1, #3
 0x5b04: add    x2, sp, #0xc0
 0x5b08: mov    w3, #0x80
 0x5b0c: bl     #0x2368 ; <duss_log_gen_head>
 0x5b10: cbz    w0, #0x5b34
 0x5b14: adrp   x3, #0x1a000
 0x5b18: adrp   x4, #0x1a000
 0x5b1c: add    x3, x3, #0xaa5 ; "%s: ================ venc_eng stopping ... ================
"
 0x5b20: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5b24: mov    w0, #0x51
 0x5b28: mov    w1, #3
 0x5b2c: add    x2, sp, #0xc0
 0x5b30: bl     #0x2378 ; <duss_log_print>
 0x5b34: cbz    x19, #0x6598
 0x5b38: adrp   x0, #0x30000
 0x5b3c: adrp   x2, #0x1a000
 0x5b40: add    x0, x0, #8 ; =0x30008
 0x5b44: mov    w1, #5
 0x5b48: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x5b4c: bl     #0x2338 ; <log_mgr_check>
 0x5b50: tbz    w0, #0, #0x5c24
 0x5b54: bl     #0x2348 ; <co_thread_get>
 0x5b58: cbz    x0, #0x5bd8
 0x5b5c: adrp   x8, #0x1a000
 0x5b60: str    wzr, [sp, #0x38]
 0x5b64: add    x8, x8, #0x440 ; =0x1a440
 0x5b68: add    x1, sp, #0x40
 0x5b6c: add    x2, sp, #0x38
 0x5b70: str    x8, [sp, #0x40]
 0x5b74: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5b78: adrp   x4, #0x1a000
 0x5b7c: adrp   x5, #0x1a000
 0x5b80: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5b84: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5b88: mov    w0, #0x51
 0x5b8c: mov    w6, #0x129
 0x5b90: mov    w1, #3
 0x5b94: add    x2, sp, #0xc0
 0x5b98: mov    w3, #0x80
 0x5b9c: bl     #0x2368 ; <duss_log_gen_head>
 0x5ba0: cbz    w0, #0x5c24
 0x5ba4: ldr    x6, [sp, #0x40]
 0x5ba8: adrp   x3, #0x1a000
 0x5bac: ldr    w7, [sp, #0x38]
 0x5bb0: adrp   x4, #0x1a000
 0x5bb4: adrp   x5, #0x1a000
 0x5bb8: add    x3, x3, #0xae2 ; "%s: %s(%s_%x): before duss_hal_device_stop
"
 0x5bbc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5bc0: add    x5, x5, #0x441 ; "co"
 0x5bc4: mov    w0, #0x51
 0x5bc8: mov    w1, #3
 0x5bcc: add    x2, sp, #0xc0
 0x5bd0: bl     #0x2378 ; <duss_log_print>
 0x5bd4: b      #0x5c24
 0x5bd8: adrp   x4, #0x1a000
 0x5bdc: adrp   x5, #0x1a000
 0x5be0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5be4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5be8: mov    w0, #0x51
 0x5bec: mov    w6, #0x129
 0x5bf0: mov    w1, #3
 0x5bf4: add    x2, sp, #0xc0
 0x5bf8: mov    w3, #0x80
 0x5bfc: bl     #0x2368 ; <duss_log_gen_head>
 0x5c00: cbz    w0, #0x5c24
 0x5c04: adrp   x3, #0x1a000
 0x5c08: adrp   x4, #0x1a000
 0x5c0c: add    x3, x3, #0xb0e ; "%s: before duss_hal_device_stop
"
 0x5c10: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5c14: mov    w0, #0x51
 0x5c18: mov    w1, #3
 0x5c1c: add    x2, sp, #0xc0
 0x5c20: bl     #0x2378 ; <duss_log_print>
 0x5c24: ldr    x0, [x19, #0xa0]
 0x5c28: mov    x1, xzr
 0x5c2c: bl     #0x2468 ; <duss_hal_device_stop>
 0x5c30: mov    w21, w0
 0x5c34: adrp   x0, #0x30000
 0x5c38: adrp   x2, #0x1a000
 0x5c3c: add    x0, x0, #8 ; =0x30008
 0x5c40: mov    w1, #5
 0x5c44: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x5c48: bl     #0x2338 ; <log_mgr_check>
 0x5c4c: tbz    w0, #0, #0x5d24
 0x5c50: bl     #0x2348 ; <co_thread_get>
 0x5c54: cbz    x0, #0x5cd8
 0x5c58: adrp   x8, #0x1a000
 0x5c5c: str    wzr, [sp, #0x38]
 0x5c60: add    x8, x8, #0x440 ; =0x1a440
 0x5c64: add    x1, sp, #0x40
 0x5c68: add    x2, sp, #0x38
 0x5c6c: str    x8, [sp, #0x40]
 0x5c70: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5c74: adrp   x4, #0x1a000
 0x5c78: adrp   x5, #0x1a000
 0x5c7c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5c80: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5c84: mov    w0, #0x51
 0x5c88: mov    w6, #0x12b
 0x5c8c: mov    w1, #3
 0x5c90: add    x2, sp, #0xc0
 0x5c94: mov    w3, #0x80
 0x5c98: bl     #0x2368 ; <duss_log_gen_head>
 0x5c9c: cbz    w0, #0x5d24
 0x5ca0: ldr    x6, [sp, #0x40]
 0x5ca4: adrp   x3, #0x1a000
 0x5ca8: ldr    w7, [sp, #0x38]
 0x5cac: adrp   x4, #0x1a000
 0x5cb0: adrp   x5, #0x1a000
 0x5cb4: add    x3, x3, #0xb2f ; "%s: %s(%s_%x): after duss_hal_device_stop
"
 0x5cb8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5cbc: add    x5, x5, #0x441 ; "co"
 0x5cc0: mov    w0, #0x51
 0x5cc4: mov    w1, #3
 0x5cc8: add    x2, sp, #0xc0
 0x5ccc: bl     #0x2378 ; <duss_log_print>
 0x5cd0: cbnz   w21, #0x5d28
 0x5cd4: b      #0x5ebc
 0x5cd8: adrp   x4, #0x1a000
 0x5cdc: adrp   x5, #0x1a000
 0x5ce0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5ce4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5ce8: mov    w0, #0x51
 0x5cec: mov    w6, #0x12b
 0x5cf0: mov    w1, #3
 0x5cf4: add    x2, sp, #0xc0
 0x5cf8: mov    w3, #0x80
 0x5cfc: bl     #0x2368 ; <duss_log_gen_head>
 0x5d00: cbz    w0, #0x5d24
 0x5d04: adrp   x3, #0x1a000
 0x5d08: adrp   x4, #0x1a000
 0x5d0c: add    x3, x3, #0xb5a ; "%s: after duss_hal_device_stop
"
 0x5d10: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5d14: mov    w0, #0x51
 0x5d18: mov    w1, #3
 0x5d1c: add    x2, sp, #0xc0
 0x5d20: bl     #0x2378 ; <duss_log_print>
 0x5d24: cbz    w21, #0x5ebc
 0x5d28: adrp   x0, #0x30000
 0x5d2c: adrp   x2, #0x1a000
 0x5d30: add    x0, x0, #8 ; =0x30008
 0x5d34: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x5d38: mov    w1, #1
 0x5d3c: bl     #0x2338 ; <log_mgr_check>
 0x5d40: tbz    w0, #0, #0x5ebc
 0x5d44: bl     #0x2348 ; <co_thread_get>
 0x5d48: cbz    x0, #0x5e1c
 0x5d4c: adrp   x8, #0x1a000
 0x5d50: str    wzr, [sp, #0x38]
 0x5d54: add    x8, x8, #0x440 ; =0x1a440
 0x5d58: add    x1, sp, #0x40
 0x5d5c: add    x2, sp, #0x38
 0x5d60: str    x8, [sp, #0x40]
 0x5d64: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5d68: adrp   x4, #0x1a000
 0x5d6c: adrp   x5, #0x1a000
 0x5d70: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5d74: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5d78: mov    w0, #0x51
 0x5d7c: mov    w6, #0x12e
 0x5d80: mov    w1, #1
 0x5d84: add    x2, sp, #0xc0
 0x5d88: mov    w3, #0x80
 0x5d8c: bl     #0x2368 ; <duss_log_gen_head>
 0x5d90: cbz    w0, #0x5db8
 0x5d94: adrp   x3, #0x1a000
 0x5d98: adrp   x4, #0x1a000
 0x5d9c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x5da0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5da4: mov    w0, #0x51
 0x5da8: mov    w5, #0x12e
 0x5dac: mov    w1, #1
 0x5db0: add    x2, sp, #0xc0
 0x5db4: bl     #0x2378 ; <duss_log_print>
 0x5db8: adrp   x4, #0x1a000
 0x5dbc: adrp   x5, #0x1a000
 0x5dc0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5dc4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5dc8: mov    w0, #0x51
 0x5dcc: mov    w6, #0x12e
 0x5dd0: mov    w1, #1
 0x5dd4: add    x2, sp, #0xc0
 0x5dd8: mov    w3, #0x80
 0x5ddc: bl     #0x2368 ; <duss_log_gen_head>
 0x5de0: cbz    w0, #0x5ebc
 0x5de4: ldr    x6, [sp, #0x40]
 0x5de8: adrp   x3, #0x1a000
 0x5dec: ldr    w7, [sp, #0x38]
 0x5df0: adrp   x4, #0x1a000
 0x5df4: adrp   x5, #0x1a000
 0x5df8: str    w21, [sp]
 0x5dfc: add    x3, x3, #0xb7a ; "%s: %s(%s_%x): duss_hal_device_stop(proresraw) error: %d
"
 0x5e00: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5e04: add    x5, x5, #0x441 ; "co"
 0x5e08: mov    w0, #0x51
 0x5e0c: mov    w1, #1
 0x5e10: add    x2, sp, #0xc0
 0x5e14: bl     #0x2378 ; <duss_log_print>
 0x5e18: b      #0x5ebc
 0x5e1c: adrp   x4, #0x1a000
 0x5e20: adrp   x5, #0x1a000
 0x5e24: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5e28: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5e2c: mov    w0, #0x51
 0x5e30: mov    w6, #0x12e
 0x5e34: mov    w1, #1
 0x5e38: add    x2, sp, #0xc0
 0x5e3c: mov    w3, #0x80
 0x5e40: bl     #0x2368 ; <duss_log_gen_head>
 0x5e44: cbz    w0, #0x5e6c
 0x5e48: adrp   x3, #0x1a000
 0x5e4c: adrp   x4, #0x1a000
 0x5e50: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x5e54: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5e58: mov    w0, #0x51
 0x5e5c: mov    w5, #0x12e
 0x5e60: mov    w1, #1
 0x5e64: add    x2, sp, #0xc0
 0x5e68: bl     #0x2378 ; <duss_log_print>
 0x5e6c: adrp   x4, #0x1a000
 0x5e70: adrp   x5, #0x1a000
 0x5e74: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5e78: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5e7c: mov    w0, #0x51
 0x5e80: mov    w6, #0x12e
 0x5e84: mov    w1, #1
 0x5e88: add    x2, sp, #0xc0
 0x5e8c: mov    w3, #0x80
 0x5e90: bl     #0x2368 ; <duss_log_gen_head>
 0x5e94: cbz    w0, #0x5ebc
 0x5e98: adrp   x3, #0x1a000
 0x5e9c: adrp   x4, #0x1a000
 0x5ea0: add    x3, x3, #0xbb4 ; "%s: duss_hal_device_stop(proresraw) error: %d
"
 0x5ea4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x5ea8: mov    w0, #0x51
 0x5eac: mov    w1, #1
 0x5eb0: add    x2, sp, #0xc0
 0x5eb4: mov    w5, w21
 0x5eb8: bl     #0x2378 ; <duss_log_print>
 0x5ebc: ldr    x0, [x19, #0x430]
 0x5ec0: str    w21, [sp, #0x1c]
 0x5ec4: mov    w21, #0x86a0
 0x5ec8: str    x20, [sp, #0x20]
 0x5ecc: movk   w21, #1, lsl #16
 0x5ed0: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x5ed4: mov    w25, w0
 0x5ed8: adrp   x0, #0x30000
 0x5edc: adrp   x2, #0x1a000
 0x5ee0: add    x0, x0, #8 ; =0x30008
 0x5ee4: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x5ee8: mov    w1, #3
 0x5eec: bl     #0x2338 ; <log_mgr_check>
 0x5ef0: cbz    w25, #0x6014
 0x5ef4: adrp   x22, #0x1a000
 0x5ef8: adrp   x23, #0x1a000
 0x5efc: adrp   x28, #0x1a000
 0x5f00: adrp   x27, #0x1a000
 0x5f04: adrp   x20, #0x30000
 0x5f08: add    x22, x22, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x5f0c: add    x23, x23, #0xa44 ; "_proresraw_venc_eng_stop"
 0x5f10: mov    w24, #0x51
 0x5f14: mov    w26, #0x13a
 0x5f18: add    x28, x28, #0x5c4 ; "PRORESRAW"
 0x5f1c: add    x27, x27, #0x440 ; =0x1a440
 0x5f20: add    x20, x20, #8 ; =0x30008
 0x5f24: tbz    w0, #0, #0x5fec
 0x5f28: bl     #0x2348 ; <co_thread_get>
 0x5f2c: cbz    x0, #0x5fa4
 0x5f30: add    x1, sp, #0x40
 0x5f34: str    x27, [sp, #0x40]
 0x5f38: add    x2, sp, #0x38
 0x5f3c: str    wzr, [sp, #0x38]
 0x5f40: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x5f44: mov    w1, #3
 0x5f48: add    x2, sp, #0xc0
 0x5f4c: mov    w3, #0x80
 0x5f50: mov    w0, w24
 0x5f54: mov    x4, x22
 0x5f58: mov    x5, x23
 0x5f5c: mov    w6, w26
 0x5f60: bl     #0x2368 ; <duss_log_gen_head>
 0x5f64: cbz    w0, #0x5fec
 0x5f68: ldr    x6, [sp, #0x40]
 0x5f6c: adrp   x3, #0x1a000
 0x5f70: ldr    w7, [sp, #0x38]
 0x5f74: adrp   x5, #0x1a000
 0x5f78: ldr    w8, [x19, #0x428]
 0x5f7c: mov    w1, #3
 0x5f80: add    x2, sp, #0xc0
 0x5f84: str    w25, [sp, #8]
 0x5f88: mov    w0, w24
 0x5f8c: add    x3, x3, #0xbe3 ; "%s: %s(%s_%x): waiting for all encoding operations to finish (capacity: %d, enqueued: %d) "
 0x5f90: mov    x4, x28
 0x5f94: str    w8, [sp]
 0x5f98: add    x5, x5, #0x441 ; "co"
 0x5f9c: bl     #0x2378 ; <duss_log_print>
 0x5fa0: b      #0x5fec
 0x5fa4: mov    w1, #3
 0x5fa8: add    x2, sp, #0xc0
 0x5fac: mov    w3, #0x80
 0x5fb0: mov    w0, w24
 0x5fb4: mov    x4, x22
 0x5fb8: mov    x5, x23
 0x5fbc: mov    w6, w26
 0x5fc0: bl     #0x2368 ; <duss_log_gen_head>
 0x5fc4: cbz    w0, #0x5fec
 0x5fc8: ldr    w5, [x19, #0x428]
 0x5fcc: adrp   x3, #0x1a000
 0x5fd0: mov    w1, #3
 0x5fd4: add    x2, sp, #0xc0
 0x5fd8: mov    w0, w24
 0x5fdc: add    x3, x3, #0xc42 ; "%s: waiting for all encoding operations to finish (capacity: %d, enqueued: %d) ...
"
 0x5fe0: mov    x4, x28
 0x5fe4: mov    w6, w25
 0x5fe8: bl     #0x2378 ; <duss_log_print>
 0x5fec: mov    w0, w21
 0x5ff0: bl     #0x2488 ; <duss_osal_task_sleep>
 0x5ff4: ldr    x0, [x19, #0x430]
 0x5ff8: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x5ffc: mov    w25, w0
 0x6000: mov    w1, #3
 0x6004: mov    x0, x20
 0x6008: mov    x2, x28
 0x600c: bl     #0x2338 ; <log_mgr_check>
 0x6010: cbnz   w25, #0x5f24
 0x6014: tbz    w0, #0, #0x60e8
 0x6018: bl     #0x2348 ; <co_thread_get>
 0x601c: cbz    x0, #0x609c
 0x6020: adrp   x8, #0x1a000
 0x6024: str    wzr, [sp, #0x38]
 0x6028: add    x8, x8, #0x440 ; =0x1a440
 0x602c: add    x1, sp, #0x40
 0x6030: add    x2, sp, #0x38
 0x6034: str    x8, [sp, #0x40]
 0x6038: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x603c: adrp   x4, #0x1a000
 0x6040: adrp   x5, #0x1a000
 0x6044: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6048: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x604c: mov    w0, #0x51
 0x6050: mov    w6, #0x13d
 0x6054: mov    w1, #3
 0x6058: add    x2, sp, #0xc0
 0x605c: mov    w3, #0x80
 0x6060: bl     #0x2368 ; <duss_log_gen_head>
 0x6064: cbz    w0, #0x60e8
 0x6068: ldr    x6, [sp, #0x40]
 0x606c: adrp   x3, #0x1a000
 0x6070: ldr    w7, [sp, #0x38]
 0x6074: adrp   x4, #0x1a000
 0x6078: adrp   x5, #0x1a000
 0x607c: add    x3, x3, #0xc96 ; "%s: %s(%s_%x): all encoding operations finished
"
 0x6080: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6084: add    x5, x5, #0x441 ; "co"
 0x6088: mov    w0, #0x51
 0x608c: mov    w1, #3
 0x6090: add    x2, sp, #0xc0
 0x6094: bl     #0x2378 ; <duss_log_print>
 0x6098: b      #0x60e8
 0x609c: adrp   x4, #0x1a000
 0x60a0: adrp   x5, #0x1a000
 0x60a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x60a8: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x60ac: mov    w0, #0x51
 0x60b0: mov    w6, #0x13d
 0x60b4: mov    w1, #3
 0x60b8: add    x2, sp, #0xc0
 0x60bc: mov    w3, #0x80
 0x60c0: bl     #0x2368 ; <duss_log_gen_head>
 0x60c4: cbz    w0, #0x60e8
 0x60c8: adrp   x3, #0x1a000
 0x60cc: adrp   x4, #0x1a000
 0x60d0: add    x3, x3, #0xcc7 ; "%s: all encoding operations finished
"
 0x60d4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x60d8: mov    w0, #0x51
 0x60dc: mov    w1, #3
 0x60e0: add    x2, sp, #0xc0
 0x60e4: bl     #0x2378 ; <duss_log_print>
 0x60e8: ldr    x0, [x19, #0x408]
 0x60ec: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x60f0: ldr    w8, [x19, #0x414]
 0x60f4: mov    w28, w0
 0x60f8: cmp    w28, w8
 0x60fc: b.eq   #0x6228
 0x6100: adrp   x22, #0x30000
 0x6104: adrp   x23, #0x1a000
 0x6108: adrp   x24, #0x1a000
 0x610c: adrp   x25, #0x1a000
 0x6110: adrp   x20, #0x1a000
 0x6114: add    x22, x22, #8 ; =0x30008
 0x6118: add    x23, x23, #0x5c4 ; "PRORESRAW"
 0x611c: add    x24, x24, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6120: add    x25, x25, #0xa44 ; "_proresraw_venc_eng_stop"
 0x6124: mov    w26, #0x51
 0x6128: mov    w27, #0x14a
 0x612c: add    x20, x20, #0x440 ; =0x1a440
 0x6130: mov    w1, #3
 0x6134: mov    x0, x22
 0x6138: mov    x2, x23
 0x613c: bl     #0x2338 ; <log_mgr_check>
 0x6140: tbz    w0, #0, #0x6208
 0x6144: bl     #0x2348 ; <co_thread_get>
 0x6148: cbz    x0, #0x61c0
 0x614c: add    x1, sp, #0x40
 0x6150: str    x20, [sp, #0x40]
 0x6154: add    x2, sp, #0x38
 0x6158: str    wzr, [sp, #0x38]
 0x615c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x6160: mov    w1, #3
 0x6164: add    x2, sp, #0xc0
 0x6168: mov    w3, #0x80
 0x616c: mov    w0, w26
 0x6170: mov    x4, x24
 0x6174: mov    x5, x25
 0x6178: mov    w6, w27
 0x617c: bl     #0x2368 ; <duss_log_gen_head>
 0x6180: cbz    w0, #0x6208
 0x6184: ldr    x6, [sp, #0x40]
 0x6188: adrp   x3, #0x1a000
 0x618c: ldr    w7, [sp, #0x38]
 0x6190: adrp   x5, #0x1a000
 0x6194: ldr    w8, [x19, #0x414]
 0x6198: mov    w1, #3
 0x619c: add    x2, sp, #0xc0
 0x61a0: str    w28, [sp, #8]
 0x61a4: mov    w0, w26
 0x61a8: add    x3, x3, #0xced ; "%s: %s(%s_%x): waiting for all stream_buffer allocator to be released(created_allocator_co"
 0x61ac: mov    x4, x23
 0x61b0: str    w8, [sp]
 0x61b4: add    x5, x5, #0x441 ; "co"
 0x61b8: bl     #0x2378 ; <duss_log_print>
 0x61bc: b      #0x6208
 0x61c0: mov    w1, #3
 0x61c4: add    x2, sp, #0xc0
 0x61c8: mov    w3, #0x80
 0x61cc: mov    w0, w26
 0x61d0: mov    x4, x24
 0x61d4: mov    x5, x25
 0x61d8: mov    w6, w27
 0x61dc: bl     #0x2368 ; <duss_log_gen_head>
 0x61e0: cbz    w0, #0x6208
 0x61e4: ldr    w5, [x19, #0x414]
 0x61e8: adrp   x3, #0x1a000
 0x61ec: mov    w1, #3
 0x61f0: add    x2, sp, #0xc0
 0x61f4: mov    w0, w26
 0x61f8: add    x3, x3, #0xd62 ; "%s: waiting for all stream_buffer allocator to be released(created_allocator_count: %d, en"
 0x61fc: mov    x4, x23
 0x6200: mov    w6, w28
 0x6204: bl     #0x2378 ; <duss_log_print>
 0x6208: mov    w0, w21
 0x620c: bl     #0x2488 ; <duss_osal_task_sleep>
 0x6210: ldr    x0, [x19, #0x408]
 0x6214: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x6218: ldr    w8, [x19, #0x414]
 0x621c: mov    w28, w0
 0x6220: cmp    w28, w8
 0x6224: b.ne   #0x6130
 0x6228: ldrb   w8, [x19, #0x4a2]
 0x622c: add    x21, sp, #0x28
 0x6230: cbz    w8, #0x6384
 0x6234: mov    w2, #0xb8
 0x6238: add    x0, sp, #0xc0
 0x623c: mov    w1, wzr
 0x6240: add    x20, sp, #0xc0
 0x6244: bl     #0x22d8 ; <memset>
 0x6248: adrp   x3, #0x1a000
 0x624c: add    x3, x3, #0xdcc ; "write_speed"
 0x6250: add    x0, sp, #0xc0
 0x6254: mov    w1, #0x20
 0x6258: mov    w2, #0x20
 0x625c: bl     #0xe788
 0x6260: adrp   x3, #0x1a000
 0x6264: add    x0, x20, #0x20 ; "#"
 0x6268: add    x3, x3, #0xdd8 ; "write speed is normal"
 0x626c: mov    w1, #0x80
 0x6270: mov    w2, #0x80
 0x6274: bl     #0xe788
 0x6278: mov    w9, #0x2501
 0x627c: mov    w8, #0x100
 0x6280: movk   w9, #0x3c0, lsl #16
 0x6284: add    x0, sp, #0xc0
 0x6288: strh   w8, [sp, #0x164]
 0x628c: str    w9, [sp, #0x160]
 0x6290: bl     #0x2498 ; <cam_ecg_report_status>
 0x6294: cbz    w0, #0x6384
 0x6298: adrp   x0, #0x30000
 0x629c: adrp   x2, #0x1a000
 0x62a0: add    x0, x0, #8 ; =0x30008
 0x62a4: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x62a8: mov    w1, #2
 0x62ac: bl     #0x2338 ; <log_mgr_check>
 0x62b0: tbz    w0, #0, #0x6384
 0x62b4: bl     #0x2348 ; <co_thread_get>
 0x62b8: cbz    x0, #0x6338
 0x62bc: adrp   x8, #0x1a000
 0x62c0: str    wzr, [sp, #0x34]
 0x62c4: add    x8, x8, #0x440 ; =0x1a440
 0x62c8: add    x1, sp, #0x38
 0x62cc: add    x2, sp, #0x34
 0x62d0: str    x8, [sp, #0x38]
 0x62d4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x62d8: adrp   x4, #0x1a000
 0x62dc: adrp   x5, #0x1a000
 0x62e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x62e4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x62e8: mov    w0, #0x51
 0x62ec: mov    w6, #0x15a
 0x62f0: mov    w1, #2
 0x62f4: add    x2, sp, #0x40
 0x62f8: mov    w3, #0x80
 0x62fc: bl     #0x2368 ; <duss_log_gen_head>
 0x6300: cbz    w0, #0x6384
 0x6304: ldr    x6, [sp, #0x38]
 0x6308: adrp   x3, #0x1a000
 0x630c: ldr    w7, [sp, #0x34]
 0x6310: adrp   x4, #0x1a000
 0x6314: adrp   x5, #0x1a000
 0x6318: add    x3, x3, #0xdee ; "%s: %s(%s_%x): ecg not init
"
 0x631c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6320: add    x5, x5, #0x441 ; "co"
 0x6324: mov    w0, #0x51
 0x6328: mov    w1, #2
 0x632c: add    x2, sp, #0x40
 0x6330: bl     #0x2378 ; <duss_log_print>
 0x6334: b      #0x6384
 0x6338: adrp   x4, #0x1a000
 0x633c: adrp   x5, #0x1a000
 0x6340: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6344: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x6348: mov    w0, #0x51
 0x634c: mov    w6, #0x15a
 0x6350: mov    w1, #2
 0x6354: add    x2, sp, #0x40
 0x6358: mov    w3, #0x80
 0x635c: bl     #0x2368 ; <duss_log_gen_head>
 0x6360: cbz    w0, #0x6384
 0x6364: adrp   x3, #0x1a000
 0x6368: adrp   x4, #0x1a000
 0x636c: add    x3, x3, #0xe0b ; "%s: ecg not init
"
 0x6370: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6374: mov    w0, #0x51
 0x6378: mov    w1, #2
 0x637c: add    x2, sp, #0x40
 0x6380: bl     #0x2378 ; <duss_log_print>
 0x6384: adrp   x0, #0x30000
 0x6388: adrp   x2, #0x1a000
 0x638c: add    x0, x0, #8 ; =0x30008
 0x6390: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6394: mov    w1, #3
 0x6398: bl     #0x2338 ; <log_mgr_check>
 0x639c: ldr    x20, [sp, #0x20]
 0x63a0: tbz    w0, #0, #0x6474
 0x63a4: bl     #0x2348 ; <co_thread_get>
 0x63a8: cbz    x0, #0x6428
 0x63ac: adrp   x8, #0x1a000
 0x63b0: str    wzr, [sp, #0x34]
 0x63b4: add    x8, x8, #0x440 ; =0x1a440
 0x63b8: add    x1, sp, #0x38
 0x63bc: add    x2, sp, #0x34
 0x63c0: str    x8, [sp, #0x38]
 0x63c4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x63c8: adrp   x4, #0x1a000
 0x63cc: adrp   x5, #0x1a000
 0x63d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x63d4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x63d8: mov    w0, #0x51
 0x63dc: mov    w6, #0x15e
 0x63e0: mov    w1, #3
 0x63e4: add    x2, sp, #0x40
 0x63e8: mov    w3, #0x80
 0x63ec: bl     #0x2368 ; <duss_log_gen_head>
 0x63f0: cbz    w0, #0x6474
 0x63f4: ldr    x6, [sp, #0x38]
 0x63f8: adrp   x3, #0x1a000
 0x63fc: ldr    w7, [sp, #0x34]
 0x6400: adrp   x4, #0x1a000
 0x6404: adrp   x5, #0x1a000
 0x6408: add    x3, x3, #0xe1d ; "%s: %s(%s_%x): all file writing operations finished
"
 0x640c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6410: add    x5, x5, #0x441 ; "co"
 0x6414: mov    w0, #0x51
 0x6418: mov    w1, #3
 0x641c: add    x2, sp, #0x40
 0x6420: bl     #0x2378 ; <duss_log_print>
 0x6424: b      #0x6474
 0x6428: adrp   x4, #0x1a000
 0x642c: adrp   x5, #0x1a000
 0x6430: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6434: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x6438: mov    w0, #0x51
 0x643c: mov    w6, #0x15e
 0x6440: mov    w1, #3
 0x6444: add    x2, sp, #0x40
 0x6448: mov    w3, #0x80
 0x644c: bl     #0x2368 ; <duss_log_gen_head>
 0x6450: cbz    w0, #0x6474
 0x6454: adrp   x3, #0x1a000
 0x6458: adrp   x4, #0x1a000
 0x645c: add    x3, x3, #0xe52 ; "%s: all file writing operations finished
"
 0x6460: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6464: mov    w0, #0x51
 0x6468: mov    w1, #3
 0x646c: add    x2, sp, #0x40
 0x6470: bl     #0x2378 ; <duss_log_print>
 0x6474: adrp   x0, #0x30000
 0x6478: strb   wzr, [x19, #0x43c]
 0x647c: adrp   x2, #0x1a000
 0x6480: add    x0, x0, #8 ; =0x30008
 0x6484: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6488: mov    w1, #3
 0x648c: bl     #0x2338 ; <log_mgr_check>
 0x6490: tbz    w0, #0, #0x6564
 0x6494: bl     #0x2348 ; <co_thread_get>
 0x6498: cbz    x0, #0x6518
 0x649c: adrp   x8, #0x1a000
 0x64a0: str    wzr, [sp, #0x34]
 0x64a4: add    x8, x8, #0x440 ; =0x1a440
 0x64a8: add    x1, sp, #0x38
 0x64ac: add    x2, sp, #0x34
 0x64b0: str    x8, [sp, #0x38]
 0x64b4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x64b8: adrp   x4, #0x1a000
 0x64bc: adrp   x5, #0x1a000
 0x64c0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x64c4: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x64c8: mov    w0, #0x51
 0x64cc: mov    w6, #0x162
 0x64d0: mov    w1, #3
 0x64d4: add    x2, sp, #0x40
 0x64d8: mov    w3, #0x80
 0x64dc: bl     #0x2368 ; <duss_log_gen_head>
 0x64e0: cbz    w0, #0x6564
 0x64e4: ldr    x6, [sp, #0x38]
 0x64e8: adrp   x3, #0x1a000
 0x64ec: ldr    w7, [sp, #0x34]
 0x64f0: adrp   x4, #0x1a000
 0x64f4: adrp   x5, #0x1a000
 0x64f8: add    x3, x3, #0xe7c ; "%s: %s(%s_%x): ================ venc_eng stopped. ================
"
 0x64fc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6500: add    x5, x5, #0x441 ; "co"
 0x6504: mov    w0, #0x51
 0x6508: mov    w1, #3
 0x650c: add    x2, sp, #0x40
 0x6510: bl     #0x2378 ; <duss_log_print>
 0x6514: b      #0x6564
 0x6518: adrp   x4, #0x1a000
 0x651c: adrp   x5, #0x1a000
 0x6520: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6524: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x6528: mov    w0, #0x51
 0x652c: mov    w6, #0x162
 0x6530: mov    w1, #3
 0x6534: add    x2, sp, #0x40
 0x6538: mov    w3, #0x80
 0x653c: bl     #0x2368 ; <duss_log_gen_head>
 0x6540: cbz    w0, #0x6564
 0x6544: adrp   x3, #0x1a000
 0x6548: adrp   x4, #0x1a000
 0x654c: add    x3, x3, #0xec0 ; "%s: ================ venc_eng stopped. ================
"
 0x6550: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6554: mov    w0, #0x51
 0x6558: mov    w1, #3
 0x655c: add    x2, sp, #0x40
 0x6560: bl     #0x2378 ; <duss_log_print>
 0x6564: ldr    x8, [x20, #0x28]
 0x6568: ldr    x9, [x21]
 0x656c: cmp    x8, x9
 0x6570: b.ne   #0x65fc
 0x6574: ldr    w0, [sp, #0x1c]
 0x6578: ldp    x29, x30, [sp, #0x1d0]
 0x657c: ldp    x20, x19, [sp, #0x1c0]
 0x6580: ldp    x22, x21, [sp, #0x1b0]
 0x6584: ldp    x24, x23, [sp, #0x1a0]
 0x6588: ldp    x26, x25, [sp, #0x190]
 0x658c: ldp    x28, x27, [sp, #0x180]
 0x6590: add    sp, sp, #0x1e0
 0x6594: ret    
 0x6598: bl     #0x2348 ; <co_thread_get>
 0x659c: cbnz   x0, #0x6600
 0x65a0: adrp   x4, #0x1a000
 0x65a4: adrp   x5, #0x1a000
 0x65a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x65ac: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x65b0: mov    w0, #0x51
 0x65b4: mov    w6, #0x125
 0x65b8: add    x2, sp, #0xc0
 0x65bc: mov    w3, #0x80
 0x65c0: mov    w1, wzr
 0x65c4: bl     #0x2368 ; <duss_log_gen_head>
 0x65c8: cbz    w0, #0x6688
 0x65cc: adrp   x3, #0x1a000
 0x65d0: adrp   x4, #0x1a000
 0x65d4: adrp   x5, #0x1a000
 0x65d8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x65dc: add    x4, x4, #0x5c0 ; "ops"
 0x65e0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x65e4: mov    w0, #0x51
 0x65e8: mov    w6, #0x125
 0x65ec: add    x2, sp, #0xc0
 0x65f0: mov    w1, wzr
 0x65f4: bl     #0x2378 ; <duss_log_print>
 0x65f8: b      #0x6688
 0x65fc: bl     #0x23d8 ; <__stack_chk_fail>
 0x6600: adrp   x8, #0x1a000
 0x6604: str    wzr, [sp, #0x38]
 0x6608: add    x8, x8, #0x440 ; =0x1a440
 0x660c: add    x1, sp, #0x40
 0x6610: add    x2, sp, #0x38
 0x6614: str    x8, [sp, #0x40]
 0x6618: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x661c: adrp   x19, #0x1a000
 0x6620: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6624: adrp   x5, #0x1a000
 0x6628: mov    w20, #0x125
 0x662c: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x6630: mov    w0, #0x51
 0x6634: add    x2, sp, #0xc0
 0x6638: mov    w3, #0x80
 0x663c: mov    w1, wzr
 0x6640: mov    x4, x19
 0x6644: mov    w6, w20
 0x6648: bl     #0x2368 ; <duss_log_gen_head>
 0x664c: cbz    w0, #0x6688
 0x6650: ldr    x5, [sp, #0x40]
 0x6654: adrp   x3, #0x1a000
 0x6658: ldr    w6, [sp, #0x38]
 0x665c: adrp   x4, #0x1a000
 0x6660: adrp   x7, #0x1a000
 0x6664: str    w20, [sp, #8]
 0x6668: mov    w1, wzr
 0x666c: str    x19, [sp]
 0x6670: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x6674: add    x4, x4, #0x441 ; "co"
 0x6678: mov    w0, #0x51
 0x667c: add    x7, x7, #0x5c0 ; "ops"
 0x6680: add    x2, sp, #0xc0
 0x6684: bl     #0x2378 ; <duss_log_print>
 0x6688: adrp   x4, #0x1a000
 0x668c: adrp   x5, #0x1a000
 0x6690: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6694: add    x5, x5, #0xa44 ; "_proresraw_venc_eng_stop"
 0x6698: mov    w0, #0x51
 0x669c: mov    w6, #0x125
 0x66a0: add    x2, sp, #0xc0
 0x66a4: mov    w3, #0x80
 0x66a8: mov    w1, wzr
 0x66ac: bl     #0x2368 ; <duss_log_gen_head>
 0x66b0: cbz    w0, #0x66cc
 0x66b4: adrp   x3, #0x1a000
 0x66b8: add    x3, x3, #0x550 ; "Assertion Comment: "
 0x66bc: mov    w0, #0x51
 0x66c0: add    x2, sp, #0xc0
 0x66c4: mov    w1, wzr
 0x66c8: bl     #0x2378 ; <duss_log_print>
 0x66cc: adrp   x0, #0x1a000
 0x66d0: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0x66d4: bl     #0x23e8 ; <log_to_kmsg>
 0x66d8: adrp   x0, #0x1a000
 0x66dc: add    x0, x0, #0x57f ; "Camera:	"
 0x66e0: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0x66e4: bl     #0x2408 ; <is_running_in_cam_sil>
 0x66e8: tbz    w0, #0, #0x66f8
 0x66ec: mov    x0, xzr
 0x66f0: bl     #0x2418 ; <fflush>
 0x66f4: bl     #0x2428 ; <abort>
 0x66f8: mov    w0, #1
 0x66fc: bl     #0x2438 ; <exit>
 0x6700: sub    sp, sp, #0xc0
 0x6704: stp    x20, x19, [sp, #0xa0]
 0x6708: stp    x29, x30, [sp, #0xb0]
 0x670c: add    x29, sp, #0xb0
 0x6710: mrs    x19, tpidr_el0
 0x6714: adrp   x0, #0x30000
 0x6718: ldr    x8, [x19, #0x28]
 0x671c: adrp   x2, #0x1a000
 0x6720: mov    x20, sp
 0x6724: add    x0, x0, #8 ; =0x30008
 0x6728: mov    w1, #5
 0x672c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6730: str    x8, [x20]
 0x6734: bl     #0x2338 ; <log_mgr_check>
 0x6738: tbz    w0, #0, #0x680c
 0x673c: bl     #0x2348 ; <co_thread_get>
 0x6740: cbz    x0, #0x67c0
 0x6744: adrp   x8, #0x1a000
 0x6748: str    wzr, [sp, #0xc]
 0x674c: add    x8, x8, #0x440 ; =0x1a440
 0x6750: add    x1, sp, #0x10
 0x6754: add    x2, sp, #0xc
 0x6758: str    x8, [sp, #0x10]
 0x675c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x6760: adrp   x4, #0x1a000
 0x6764: adrp   x5, #0x1a000
 0x6768: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x676c: add    x5, x5, #0xef9 ; "_proresraw_venc_eng_reset"
 0x6770: mov    w0, #0x51
 0x6774: mov    w6, #0x16c
 0x6778: mov    w1, #3
 0x677c: add    x2, sp, #0x18
 0x6780: mov    w3, #0x80
 0x6784: bl     #0x2368 ; <duss_log_gen_head>
 0x6788: cbz    w0, #0x680c
 0x678c: ldr    x6, [sp, #0x10]
 0x6790: adrp   x3, #0x1a000
 0x6794: ldr    w7, [sp, #0xc]
 0x6798: adrp   x4, #0x1a000
 0x679c: adrp   x5, #0x1a000
 0x67a0: add    x3, x3, #0xf13 ; "%s: %s(%s_%x): reg_buffers
"
 0x67a4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x67a8: add    x5, x5, #0x441 ; "co"
 0x67ac: mov    w0, #0x51
 0x67b0: mov    w1, #3
 0x67b4: add    x2, sp, #0x18
 0x67b8: bl     #0x2378 ; <duss_log_print>
 0x67bc: b      #0x680c
 0x67c0: adrp   x4, #0x1a000
 0x67c4: adrp   x5, #0x1a000
 0x67c8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x67cc: add    x5, x5, #0xef9 ; "_proresraw_venc_eng_reset"
 0x67d0: mov    w0, #0x51
 0x67d4: mov    w6, #0x16c
 0x67d8: mov    w1, #3
 0x67dc: add    x2, sp, #0x18
 0x67e0: mov    w3, #0x80
 0x67e4: bl     #0x2368 ; <duss_log_gen_head>
 0x67e8: cbz    w0, #0x680c
 0x67ec: adrp   x3, #0x1a000
 0x67f0: adrp   x4, #0x1a000
 0x67f4: add    x3, x3, #0xf2f ; "%s: reg_buffers
"
 0x67f8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x67fc: mov    w0, #0x51
 0x6800: mov    w1, #3
 0x6804: add    x2, sp, #0x18
 0x6808: bl     #0x2378 ; <duss_log_print>
 0x680c: ldr    x8, [x19, #0x28]
 0x6810: ldr    x9, [x20]
 0x6814: cmp    x8, x9
 0x6818: b.ne   #0x6830
 0x681c: ldp    x29, x30, [sp, #0xb0]
 0x6820: ldp    x20, x19, [sp, #0xa0]
 0x6824: mov    w0, wzr
 0x6828: add    sp, sp, #0xc0
 0x682c: ret    
 0x6830: bl     #0x23d8 ; <__stack_chk_fail>
 0x6834: udf    #0
 0x6838: stp    d9, d8, [sp, #-0x70]!
 0x683c: stp    x28, x27, [sp, #0x10]
 0x6840: stp    x26, x25, [sp, #0x20]
 0x6844: stp    x24, x23, [sp, #0x30]
 0x6848: stp    x22, x21, [sp, #0x40]
 0x684c: stp    x20, x19, [sp, #0x50]
 0x6850: stp    x29, x30, [sp, #0x60]
 0x6854: add    x29, sp, #0x60
 0x6858: sub    sp, sp, #0x2d0
 0x685c: mrs    x24, tpidr_el0
 0x6860: mov    x26, x1
 0x6864: ldr    x8, [x24, #0x28]
 0x6868: mov    x25, x0
 0x686c: mov    w2, #0x48
 0x6870: add    x0, sp, #0x110
 0x6874: mov    w1, wzr
 0x6878: str    x8, [sp, #0x80]
 0x687c: stp    xzr, xzr, [sp, #0xa8]
 0x6880: stp    xzr, xzr, [sp, #0x98]
 0x6884: str    xzr, [sp, #0x90]
 0x6888: bl     #0x22d8 ; <memset>
 0x688c: movi   v0.2d, #0000000000000000
 0x6890: adrp   x0, #0x30000
 0x6894: adrp   x2, #0x1a000
 0x6898: str    wzr, [sp, #0x100]
 0x689c: add    x0, x0, #8 ; =0x30008
 0x68a0: str    xzr, [sp, #0x88]
 0x68a4: mov    w1, #5
 0x68a8: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x68ac: stp    q0, q0, [sp, #0xe0]
 0x68b0: bl     #0x2338 ; <log_mgr_check>
 0x68b4: tbz    w0, #0, #0x69ec
 0x68b8: bl     #0x2348 ; <co_thread_get>
 0x68bc: cbz    x0, #0x69a0
 0x68c0: adrp   x8, #0x1a000
 0x68c4: str    wzr, [sp, #0xd0]
 0x68c8: add    x8, x8, #0x440 ; =0x1a440
 0x68cc: add    x1, sp, #0x158
 0x68d0: add    x2, sp, #0xd0
 0x68d4: str    x8, [sp, #0x158]
 0x68d8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x68dc: adrp   x4, #0x1a000
 0x68e0: adrp   x5, #0x1a000
 0x68e4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x68e8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x68ec: mov    w0, #0x51
 0x68f0: mov    w6, #0x267
 0x68f4: mov    w1, #3
 0x68f8: add    x2, sp, #0x1c8
 0x68fc: mov    w3, #0x80
 0x6900: bl     #0x2368 ; <duss_log_gen_head>
 0x6904: cbz    w0, #0x69ec
 0x6908: ldr    x6, [sp, #0x158]
 0x690c: adrp   x3, #0x1a000
 0x6910: ldr    w7, [sp, #0xd0]
 0x6914: adrp   x4, #0x1a000
 0x6918: adrp   x5, #0x1a000
 0x691c: add    x3, x3, #0xf5e ; "%s: %s(%s_%x): enc_frame
"
 0x6920: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6924: add    x5, x5, #0x441 ; "co"
 0x6928: mov    w0, #0x51
 0x692c: mov    w1, #3
 0x6930: add    x2, sp, #0x1c8
 0x6934: bl     #0x2378 ; <duss_log_print>
 0x6938: cbnz   x25, #0x69f0
 0x693c: bl     #0x2348 ; <co_thread_get>
 0x6940: cbnz   x0, #0x8740
 0x6944: adrp   x4, #0x1a000
 0x6948: adrp   x5, #0x1a000
 0x694c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6950: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6954: mov    w0, #0x51
 0x6958: mov    w6, #0x269
 0x695c: add    x2, sp, #0x1c8
 0x6960: mov    w3, #0x80
 0x6964: mov    w1, wzr
 0x6968: bl     #0x2368 ; <duss_log_gen_head>
 0x696c: cbz    w0, #0x87c8
 0x6970: adrp   x3, #0x1a000
 0x6974: adrp   x4, #0x1a000
 0x6978: adrp   x5, #0x1a000
 0x697c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x6980: add    x4, x4, #0x5c0 ; "ops"
 0x6984: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6988: mov    w0, #0x51
 0x698c: mov    w6, #0x269
 0x6990: add    x2, sp, #0x1c8
 0x6994: mov    w1, wzr
 0x6998: bl     #0x2378 ; <duss_log_print>
 0x699c: b      #0x87c8
 0x69a0: adrp   x4, #0x1a000
 0x69a4: adrp   x5, #0x1a000
 0x69a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x69ac: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x69b0: mov    w0, #0x51
 0x69b4: mov    w6, #0x267
 0x69b8: mov    w1, #3
 0x69bc: add    x2, sp, #0x1c8
 0x69c0: mov    w3, #0x80
 0x69c4: bl     #0x2368 ; <duss_log_gen_head>
 0x69c8: cbz    w0, #0x69ec
 0x69cc: adrp   x3, #0x1a000
 0x69d0: adrp   x4, #0x1a000
 0x69d4: add    x3, x3, #0xf78 ; "%s: enc_frame
"
 0x69d8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x69dc: mov    w0, #0x51
 0x69e0: mov    w1, #3
 0x69e4: add    x2, sp, #0x1c8
 0x69e8: bl     #0x2378 ; <duss_log_print>
 0x69ec: cbz    x25, #0x693c
 0x69f0: cbz    x26, #0x8268
 0x69f4: ldr    w8, [x26, #0x9c]
 0x69f8: cbnz   w8, #0x82cc
 0x69fc: add    x0, sp, #0x158
 0x6a00: mov    w2, #0x70
 0x6a04: mov    w1, wzr
 0x6a08: bl     #0x22d8 ; <memset>
 0x6a0c: ldr    x19, [x26]
 0x6a10: cbz    x19, #0x8330
 0x6a14: ldr    x8, [x19, #0x20]
 0x6a18: cbz    x8, #0x8394
 0x6a1c: ldr    w8, [x19, #0xb0]
 0x6a20: cmp    w8, #1
 0x6a24: b.ne   #0x83f8
 0x6a28: ldr    x8, [x25, #0x408]
 0x6a2c: cbz    x8, #0x845c
 0x6a30: ldr    x8, [x25, #0x420]
 0x6a34: cbz    x8, #0x84c0
 0x6a38: ldr    x8, [x25, #0x430]
 0x6a3c: cbz    x8, #0x8524
 0x6a40: add    x1, sp, #0x90
 0x6a44: mov    x0, x26
 0x6a48: bl     #0x24a8 ; <proresraw_wb_gain_get>
 0x6a4c: mov    w20, w0
 0x6a50: cbz    w20, #0x6af8
 0x6a54: adrp   x0, #0x30000
 0x6a58: adrp   x2, #0x1a000
 0x6a5c: add    x0, x0, #8 ; =0x30008
 0x6a60: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6a64: mov    w1, #2
 0x6a68: bl     #0x2338 ; <log_mgr_check>
 0x6a6c: tbz    w0, #0, #0x6b50
 0x6a70: bl     #0x2348 ; <co_thread_get>
 0x6a74: cbz    x0, #0x6b00
 0x6a78: adrp   x8, #0x1a000
 0x6a7c: str    wzr, [sp, #0xc0]
 0x6a80: add    x8, x8, #0x440 ; =0x1a440
 0x6a84: add    x1, sp, #0xd0
 0x6a88: add    x2, sp, #0xc0
 0x6a8c: str    x8, [sp, #0xd0]
 0x6a90: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x6a94: adrp   x4, #0x1a000
 0x6a98: adrp   x5, #0x1a000
 0x6a9c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6aa0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6aa4: mov    w0, #0x51
 0x6aa8: mov    w6, #0x27c
 0x6aac: mov    w1, #2
 0x6ab0: add    x2, sp, #0x1c8
 0x6ab4: mov    w3, #0x80
 0x6ab8: bl     #0x2368 ; <duss_log_gen_head>
 0x6abc: cbz    w0, #0x6b50
 0x6ac0: ldr    x6, [sp, #0xd0]
 0x6ac4: adrp   x3, #0x1b000
 0x6ac8: ldr    w7, [sp, #0xc0]
 0x6acc: adrp   x4, #0x1a000
 0x6ad0: adrp   x5, #0x1a000
 0x6ad4: str    w20, [sp]
 0x6ad8: add    x3, x3, #0xf ; "%s: %s(%s_%x): get the wb gain failed, ret:%d, using default wb_gain
"
 0x6adc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6ae0: add    x5, x5, #0x441 ; "co"
 0x6ae4: mov    w0, #0x51
 0x6ae8: mov    w1, #2
 0x6aec: add    x2, sp, #0x1c8
 0x6af0: bl     #0x2378 ; <duss_log_print>
 0x6af4: b      #0x6b50
 0x6af8: ldp    w21, w22, [sp, #0x90]
 0x6afc: b      #0x6b64
 0x6b00: adrp   x4, #0x1a000
 0x6b04: adrp   x5, #0x1a000
 0x6b08: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6b0c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6b10: mov    w0, #0x51
 0x6b14: mov    w6, #0x27c
 0x6b18: mov    w1, #2
 0x6b1c: add    x2, sp, #0x1c8
 0x6b20: mov    w3, #0x80
 0x6b24: bl     #0x2368 ; <duss_log_gen_head>
 0x6b28: cbz    w0, #0x6b50
 0x6b2c: adrp   x3, #0x1b000
 0x6b30: adrp   x4, #0x1a000
 0x6b34: add    x3, x3, #0x55 ; "%s: get the wb gain failed, ret:%d, using default wb_gain
"
 0x6b38: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6b3c: mov    w0, #0x51
 0x6b40: mov    w1, #2
 0x6b44: add    x2, sp, #0x1c8
 0x6b48: mov    w5, w20
 0x6b4c: bl     #0x2378 ; <duss_log_print>
 0x6b50: adrp   x8, #0x1a000
 0x6b54: mov    w21, #0x2bba
 0x6b58: mov    w22, #0x1f96
 0x6b5c: ldr    d0, [x8, #0x1a0]
 0x6b60: str    d0, [sp, #0x90]
 0x6b64: add    x1, sp, #0x110
 0x6b68: add    x2, sp, #0x8c
 0x6b6c: mov    x0, x26
 0x6b70: bl     #0x24b8 ; <proresraw_ccm_cct_get_from_adj>
 0x6b74: mov    w20, w0
 0x6b78: cbnz   w20, #0x8588
 0x6b7c: add    x23, sp, #0x110
 0x6b80: adrp   x8, #0x1a000
 0x6b84: add    x1, sp, #0x88
 0x6b88: ldp    q0, q1, [x23]
 0x6b8c: mov    x0, x26
 0x6b90: ldr    d8, [x8, #0x1a8]
 0x6b94: fcvtn  v0.2s, v0.2d
 0x6b98: fcvtn2 v0.4s, v1.2d
 0x6b9c: ldp    q1, q2, [x23, #0x20]
 0x6ba0: fcvtn  v1.2s, v1.2d
 0x6ba4: str    q0, [sp, #0xe0]
 0x6ba8: fcvtn2 v1.4s, v2.2d
 0x6bac: ldr    d0, [sp, #0x150]
 0x6bb0: fcvt   s0, d0
 0x6bb4: str    q1, [sp, #0xf0]
 0x6bb8: str    s0, [sp, #0x100]
 0x6bbc: bl     #0x24c8 ; <proresraw_d_gain_get_from_adj>
 0x6bc0: mov    w20, w0
 0x6bc4: cbz    w20, #0x6c6c
 0x6bc8: adrp   x0, #0x30000
 0x6bcc: adrp   x2, #0x1a000
 0x6bd0: add    x0, x0, #8 ; =0x30008
 0x6bd4: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6bd8: mov    w1, #2
 0x6bdc: bl     #0x2338 ; <log_mgr_check>
 0x6be0: tbz    w0, #0, #0x6cc4
 0x6be4: bl     #0x2348 ; <co_thread_get>
 0x6be8: cbz    x0, #0x6c74
 0x6bec: adrp   x8, #0x1a000
 0x6bf0: str    wzr, [sp, #0xc0]
 0x6bf4: add    x8, x8, #0x440 ; =0x1a440
 0x6bf8: add    x1, sp, #0xd0
 0x6bfc: add    x2, sp, #0xc0
 0x6c00: str    x8, [sp, #0xd0]
 0x6c04: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x6c08: adrp   x4, #0x1a000
 0x6c0c: adrp   x5, #0x1a000
 0x6c10: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6c14: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6c18: mov    w0, #0x51
 0x6c1c: mov    w6, #0x28e
 0x6c20: mov    w1, #2
 0x6c24: add    x2, sp, #0x1c8
 0x6c28: mov    w3, #0x80
 0x6c2c: bl     #0x2368 ; <duss_log_gen_head>
 0x6c30: cbz    w0, #0x6cc4
 0x6c34: ldr    x6, [sp, #0xd0]
 0x6c38: adrp   x3, #0x1b000
 0x6c3c: ldr    w7, [sp, #0xc0]
 0x6c40: adrp   x4, #0x1a000
 0x6c44: adrp   x5, #0x1a000
 0x6c48: str    w20, [sp]
 0x6c4c: add    x3, x3, #0xf9 ; "%s: %s(%s_%x): proresraw_d_gain_get failed:%d
"
 0x6c50: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6c54: add    x5, x5, #0x441 ; "co"
 0x6c58: mov    w0, #0x51
 0x6c5c: mov    w1, #2
 0x6c60: add    x2, sp, #0x1c8
 0x6c64: bl     #0x2378 ; <duss_log_print>
 0x6c68: b      #0x6cc4
 0x6c6c: ldr    w8, [sp, #0x88]
 0x6c70: b      #0x6ccc
 0x6c74: adrp   x4, #0x1a000
 0x6c78: adrp   x5, #0x1a000
 0x6c7c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6c80: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6c84: mov    w0, #0x51
 0x6c88: mov    w6, #0x28e
 0x6c8c: mov    w1, #2
 0x6c90: add    x2, sp, #0x1c8
 0x6c94: mov    w3, #0x80
 0x6c98: bl     #0x2368 ; <duss_log_gen_head>
 0x6c9c: cbz    w0, #0x6cc4
 0x6ca0: adrp   x3, #0x1b000
 0x6ca4: adrp   x4, #0x1a000
 0x6ca8: add    x3, x3, #0x128 ; "%s: proresraw_d_gain_get failed:%d
"
 0x6cac: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6cb0: mov    w0, #0x51
 0x6cb4: mov    w1, #2
 0x6cb8: add    x2, sp, #0x1c8
 0x6cbc: mov    w5, w20
 0x6cc0: bl     #0x2378 ; <duss_log_print>
 0x6cc4: mov    w8, #0x3f800000
 0x6cc8: str    w8, [sp, #0x88]
 0x6ccc: ldp    s0, s1, [sp, #0x90]
 0x6cd0: ldp    q2, q3, [sp, #0xe0]
 0x6cd4: ldr    w9, [sp, #0x8c]
 0x6cd8: ucvtf  d0, d0
 0x6cdc: ucvtf  d1, d1
 0x6ce0: stur   q2, [x23, #0x74]
 0x6ce4: stur   q3, [x23, #0x84]
 0x6ce8: adrp   x0, #0x30000
 0x6cec: str    w8, [sp, #0x180]
 0x6cf0: adrp   x2, #0x1a000
 0x6cf4: ldr    w8, [sp, #0x100]
 0x6cf8: add    x0, x0, #8 ; =0x30008
 0x6cfc: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6d00: strh   w9, [sp, #0x1a8]
 0x6d04: fmul   d0, d0, d8
 0x6d08: mov    w1, #4
 0x6d0c: fmul   d1, d1, d8
 0x6d10: str    w8, [sp, #0x1a4]
 0x6d14: fcvt   s0, d0
 0x6d18: fcvt   s1, d1
 0x6d1c: str    s0, [sp, #0x178]
 0x6d20: str    s1, [sp, #0x88]
 0x6d24: str    s1, [sp, #0x17c]
 0x6d28: bl     #0x2338 ; <log_mgr_check>
 0x6d2c: tbz    w0, #0, #0x6e3c
 0x6d30: ucvtf  d0, w21
 0x6d34: ucvtf  d1, w22
 0x6d38: fmul   d9, d0, d8
 0x6d3c: fmul   d8, d1, d8
 0x6d40: bl     #0x2348 ; <co_thread_get>
 0x6d44: cbz    x0, #0x6de0
 0x6d48: adrp   x8, #0x1a000
 0x6d4c: str    wzr, [sp, #0xc0]
 0x6d50: add    x8, x8, #0x440 ; =0x1a440
 0x6d54: add    x1, sp, #0xd0
 0x6d58: add    x2, sp, #0xc0
 0x6d5c: str    x8, [sp, #0xd0]
 0x6d60: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x6d64: adrp   x4, #0x1a000
 0x6d68: adrp   x5, #0x1a000
 0x6d6c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6d70: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6d74: mov    w0, #0x51
 0x6d78: mov    w6, #0x29d
 0x6d7c: mov    w1, #4
 0x6d80: add    x2, sp, #0x1c8
 0x6d84: mov    w3, #0x80
 0x6d88: bl     #0x2368 ; <duss_log_gen_head>
 0x6d8c: cbz    w0, #0x6e3c
 0x6d90: mov    v0.16b, v9.16b
 0x6d94: ldr    x6, [sp, #0xd0]
 0x6d98: mov    v1.16b, v8.16b
 0x6d9c: ldr    w7, [sp, #0xc0]
 0x6da0: ldp    w8, w9, [sp, #0x90]
 0x6da4: ldrh   w10, [sp, #0x1a8]
 0x6da8: adrp   x3, #0x1b000
 0x6dac: adrp   x4, #0x1a000
 0x6db0: adrp   x5, #0x1a000
 0x6db4: str    w9, [sp, #8]
 0x6db8: add    x3, x3, #0x14c ; "%s: %s(%s_%x): ====rgain:%u, bgain:%u, compute result:rgain:%lf, bgain:%lf cct: %d
"
 0x6dbc: str    w10, [sp, #0x10]
 0x6dc0: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6dc4: str    w8, [sp]
 0x6dc8: add    x5, x5, #0x441 ; "co"
 0x6dcc: mov    w0, #0x51
 0x6dd0: mov    w1, #4
 0x6dd4: add    x2, sp, #0x1c8
 0x6dd8: bl     #0x2378 ; <duss_log_print>
 0x6ddc: b      #0x6e3c
 0x6de0: adrp   x4, #0x1a000
 0x6de4: adrp   x5, #0x1a000
 0x6de8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6dec: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x6df0: mov    w0, #0x51
 0x6df4: mov    w6, #0x29d
 0x6df8: mov    w1, #4
 0x6dfc: add    x2, sp, #0x1c8
 0x6e00: mov    w3, #0x80
 0x6e04: bl     #0x2368 ; <duss_log_gen_head>
 0x6e08: cbz    w0, #0x6e3c
 0x6e0c: mov    v0.16b, v9.16b
 0x6e10: ldrh   w7, [sp, #0x1a8]
 0x6e14: mov    v1.16b, v8.16b
 0x6e18: adrp   x3, #0x1b000
 0x6e1c: ldp    w5, w6, [sp, #0x90]
 0x6e20: adrp   x4, #0x1a000
 0x6e24: add    x3, x3, #0x1a0 ; "%s: ====rgain:%u, bgain:%u, compute result:rgain:%lf, bgain:%lf cct: %d
"
 0x6e28: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x6e2c: mov    w0, #0x51
 0x6e30: mov    w1, #4
 0x6e34: add    x2, sp, #0x1c8
 0x6e38: bl     #0x2378 ; <duss_log_print>
 0x6e3c: ldr    x0, [x25, #0x408]
 0x6e40: strb   wzr, [sp, #0x1b0]
 0x6e44: str    wzr, [sp, #0x1ac]
 0x6e48: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x6e4c: ldr    x27, [x25, #0x490]
 0x6e50: bl     #0x24d8 ; <duss_osal_get_exec_obj_id>
 0x6e54: mov    w20, w0
 0x6e58: tbnz   w20, #0x1f, #0x7994
 0x6e5c: cbz    x27, #0x79d4
 0x6e60: ldrh   w1, [x25, #0x49a]
 0x6e64: cbz    w1, #0x6e74
 0x6e68: mov    x0, x27
 0x6e6c: mov    w2, w20
 0x6e70: bl     #0x24e8 ; <perf_trace_coroutine_slice_begin>
 0x6e74: add    x1, sp, #0xb0
 0x6e78: add    x2, sp, #0xa8
 0x6e7c: mov    x0, x25
 0x6e80: bl     #0xe838
 0x6e84: ldrh   w1, [x25, #0x49a]
 0x6e88: mov    w21, w0
 0x6e8c: cbz    w1, #0x79e8
 0x6e90: mov    x0, x27
 0x6e94: mov    w2, w20
 0x6e98: bl     #0x24f8 ; <perf_trace_coroutine_slice_end>
 0x6e9c: cbnz   w21, #0x79ec
 0x6ea0: ldr    x0, [x25, #0x420]
 0x6ea4: add    x1, sp, #0x98
 0x6ea8: bl     #0x2508 ; <buffer_queue_dequeue>
 0x6eac: cbnz   w0, #0x8e60
 0x6eb0: ldr    x8, [sp, #0x98]
 0x6eb4: cbz    x8, #0x8ec4
 0x6eb8: ldr    x0, [x25, #0x3f8]
 0x6ebc: add    x1, sp, #0xa0
 0x6ec0: bl     #0x2508 ; <buffer_queue_dequeue>
 0x6ec4: cbnz   w0, #0x8f28
 0x6ec8: ldr    x21, [sp, #0xa0]
 0x6ecc: cbz    x21, #0x8f8c
 0x6ed0: ldr    x20, [x26, #0x48]
 0x6ed4: str    xzr, [sp, #0xd0]
 0x6ed8: str    wzr, [sp, #0xcc]
 0x6edc: cbz    x20, #0x8ff0
 0x6ee0: ldr    x0, [x21, #8]
 0x6ee4: cbz    x0, #0x9054
 0x6ee8: ldr    w8, [x25, #0x3e4]
 0x6eec: cbz    w8, #0x90b8
 0x6ef0: ldr    w9, [x25, #0x3e8]
 0x6ef4: cbz    w9, #0x911c
 0x6ef8: cmp    w9, w8, lsl #2
 0x6efc: b.lo   #0x9180
 0x6f00: add    x1, sp, #0xd0
 0x6f04: bl     #0x2518 ; <duss_hal_mem_map>
 0x6f08: cbnz   w0, #0x91e4
 0x6f0c: ldr    x8, [sp, #0xd0]
 0x6f10: cbz    x8, #0x9248
 0x6f14: ldr    x0, [x21, #8]
 0x6f18: add    x1, sp, #0xcc
 0x6f1c: bl     #0x2528 ; <duss_hal_mem_get_size>
 0x6f20: cbnz   w0, #0x92ac
 0x6f24: ldr    w8, [sp, #0xcc]
 0x6f28: ldr    w9, [x25, #0x3e8]
 0x6f2c: cmp    w8, w9
 0x6f30: b.lo   #0x9310
 0x6f34: adrp   x2, #0x1a000
 0x6f38: adrp   x3, #0x1b000
 0x6f3c: add    x2, x2, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6f40: add    x3, x3, #0xe43 ; "_proresraw_extract_ics_info"
 0x6f44: mov    w1, #0x4dd
 0x6f48: mov    w4, #0x1b8
 0x6f4c: mov    x0, x20
 0x6f50: bl     #0x2538 ; <dcam_container_get_by_id_inner>
 0x6f54: cbz    x0, #0x6fa0
 0x6f58: ldr    w8, [x0]
 0x6f5c: cmp    w8, #2
 0x6f60: b.ne   #0x96b0
 0x6f64: add    x1, sp, #0xdc
 0x6f68: bl     #0x2548 ; <dcam_container_val_as_uint16>
 0x6f6c: mov    x8, x0
 0x6f70: cbz    x8, #0x9714
 0x6f74: ldrsw  x9, [sp, #0xdc]
 0x6f78: cmp    w9, #1
 0x6f7c: b.lt   #0x8dfc
 0x6f80: ldr    w10, [sp, #0xcc]
 0x6f84: lsl    x2, x9, #1
 0x6f88: cmp    x2, x10
 0x6f8c: b.hi   #0x8dfc
 0x6f90: ldr    x0, [sp, #0xd0]
 0x6f94: mov    x1, x8
 0x6f98: bl     #0x22e8 ; <memcpy>
 0x6f9c: b      #0x70b8
 0x6fa0: adrp   x0, #0x30000
 0x6fa4: adrp   x2, #0x1a000
 0x6fa8: add    x0, x0, #8 ; =0x30008
 0x6fac: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x6fb0: mov    w1, #2
 0x6fb4: bl     #0x2338 ; <log_mgr_check>
 0x6fb8: tbz    w0, #0, #0x708c
 0x6fbc: bl     #0x2348 ; <co_thread_get>
 0x6fc0: cbz    x0, #0x7040
 0x6fc4: adrp   x8, #0x1a000
 0x6fc8: str    wzr, [sp, #0xdc]
 0x6fcc: add    x8, x8, #0x440 ; =0x1a440
 0x6fd0: add    x1, sp, #0xc0
 0x6fd4: add    x2, sp, #0xdc
 0x6fd8: str    x8, [sp, #0xc0]
 0x6fdc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x6fe0: adrp   x4, #0x1a000
 0x6fe4: adrp   x5, #0x1b000
 0x6fe8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x6fec: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x6ff0: mov    w0, #0x51
 0x6ff4: mov    w6, #0x1bb
 0x6ff8: mov    w1, #2
 0x6ffc: add    x2, sp, #0x1c8
 0x7000: mov    w3, #0x80
 0x7004: bl     #0x2368 ; <duss_log_gen_head>
 0x7008: cbz    w0, #0x708c
 0x700c: ldr    x6, [sp, #0xc0]
 0x7010: adrp   x3, #0x1b000
 0x7014: ldr    w7, [sp, #0xdc]
 0x7018: adrp   x4, #0x1a000
 0x701c: adrp   x5, #0x1a000
 0x7020: add    x3, x3, #0xf18 ; "%s: %s(%s_%x): Can't find DCAM_STATUS_STATS_RAW_ICS in metadata, default ics stats data wi"
 0x7024: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7028: add    x5, x5, #0x441 ; "co"
 0x702c: mov    w0, #0x51
 0x7030: mov    w1, #2
 0x7034: add    x2, sp, #0x1c8
 0x7038: bl     #0x2378 ; <duss_log_print>
 0x703c: b      #0x708c
 0x7040: adrp   x4, #0x1a000
 0x7044: adrp   x5, #0x1b000
 0x7048: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x704c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x7050: mov    w0, #0x51
 0x7054: mov    w6, #0x1bb
 0x7058: mov    w1, #2
 0x705c: add    x2, sp, #0x1c8
 0x7060: mov    w3, #0x80
 0x7064: bl     #0x2368 ; <duss_log_gen_head>
 0x7068: cbz    w0, #0x708c
 0x706c: adrp   x3, #0x1b000
 0x7070: adrp   x4, #0x1a000
 0x7074: add    x3, x3, #0xf7f ; "%s: Can't find DCAM_STATUS_STATS_RAW_ICS in metadata, default ics stats data will be used!"
 0x7078: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x707c: mov    w0, #0x51
 0x7080: mov    w1, #2
 0x7084: add    x2, sp, #0x1c8
 0x7088: bl     #0x2378 ; <duss_log_print>
 0x708c: ldr    w8, [x25, #0x3e8]
 0x7090: cmp    w8, #2
 0x7094: b.lo   #0x70b8
 0x7098: mov    x8, xzr
 0x709c: ldr    x9, [sp, #0xd0]
 0x70a0: strh   wzr, [x9, x8, lsl #1]
 0x70a4: add    x8, x8, #1 ; =0x1a001
 0x70a8: ldr    w9, [x25, #0x3e8]
 0x70ac: lsr    w9, w9, #1
 0x70b0: cmp    x8, x9
 0x70b4: b.lo   #0x709c
 0x70b8: ldr    x0, [x21, #8]
 0x70bc: bl     #0x2558 ; <duss_hal_mem_unmap>
 0x70c0: cbnz   w0, #0x9374
 0x70c4: ldp    x8, x9, [sp, #0x98]
 0x70c8: str    x9, [sp, #0x160]
 0x70cc: ldr    x9, [x8]
 0x70d0: cbnz   x9, #0x93d8
 0x70d4: ldr    x9, [sp, #0xb0]
 0x70d8: add    x1, sp, #0xd0
 0x70dc: str    x9, [x8]
 0x70e0: ldr    x0, [sp, #0xb0]
 0x70e4: bl     #0x2568 ; <cam_encoded_buffer_allocator_get_ring_buffer_info>
 0x70e8: ldp    w8, w9, [sp, #0xd0]
 0x70ec: adrp   x0, #0x30000
 0x70f0: adrp   x2, #0x1a000
 0x70f4: add    x0, x0, #8 ; =0x30008
 0x70f8: mov    w1, #5
 0x70fc: stp    x9, x8, [sp, #0x1b8]
 0x7100: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x7104: bl     #0x2338 ; <log_mgr_check>
 0x7108: tbz    w0, #0, #0x7228
 0x710c: bl     #0x2348 ; <co_thread_get>
 0x7110: cbz    x0, #0x71bc
 0x7114: adrp   x8, #0x1a000
 0x7118: str    wzr, [sp, #0xdc]
 0x711c: add    x8, x8, #0x440 ; =0x1a440
 0x7120: add    x1, sp, #0xc0
 0x7124: add    x2, sp, #0xdc
 0x7128: str    x8, [sp, #0xc0]
 0x712c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x7130: adrp   x4, #0x1a000
 0x7134: adrp   x5, #0x1a000
 0x7138: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x713c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7140: mov    w0, #0x51
 0x7144: mov    w6, #0x2d2
 0x7148: mov    w1, #3
 0x714c: add    x2, sp, #0x1c8
 0x7150: mov    w3, #0x80
 0x7154: bl     #0x2368 ; <duss_log_gen_head>
 0x7158: cbz    w0, #0x7228
 0x715c: ldr    x0, [x25, #0x430]
 0x7160: ldr    x20, [sp, #0xc0]
 0x7164: ldr    w21, [sp, #0xdc]
 0x7168: ldp    w22, w23, [sp, #0xd0]
 0x716c: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x7170: ldr    w9, [x25, #0x438]
 0x7174: adrp   x3, #0x1b000
 0x7178: adrp   x4, #0x1a000
 0x717c: str    w23, [sp, #8]
 0x7180: adrp   x5, #0x1a000
 0x7184: str    w22, [sp]
 0x7188: mov    w8, w0
 0x718c: add    x3, x3, #0x4c5 ; "%s: %s(%s_%x): ringbuffer left mem %d total size %d encode queue %d/%d
"
 0x7190: str    w9, [sp, #0x18]
 0x7194: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7198: add    x5, x5, #0x441 ; "co"
 0x719c: str    w8, [sp, #0x10]
 0x71a0: mov    w0, #0x51
 0x71a4: mov    w1, #3
 0x71a8: add    x2, sp, #0x1c8
 0x71ac: mov    x6, x20
 0x71b0: mov    w7, w21
 0x71b4: bl     #0x2378 ; <duss_log_print>
 0x71b8: b      #0x7228
 0x71bc: adrp   x4, #0x1a000
 0x71c0: adrp   x5, #0x1a000
 0x71c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x71c8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x71cc: mov    w0, #0x51
 0x71d0: mov    w6, #0x2d2
 0x71d4: mov    w1, #3
 0x71d8: add    x2, sp, #0x1c8
 0x71dc: mov    w3, #0x80
 0x71e0: bl     #0x2368 ; <duss_log_gen_head>
 0x71e4: cbz    w0, #0x7228
 0x71e8: ldr    x0, [x25, #0x430]
 0x71ec: ldp    w20, w21, [sp, #0xd0]
 0x71f0: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x71f4: ldr    w8, [x25, #0x438]
 0x71f8: adrp   x3, #0x1b000
 0x71fc: adrp   x4, #0x1a000
 0x7200: mov    w7, w0
 0x7204: add    x3, x3, #0x50d ; "%s: ringbuffer left mem %d total size %d encode queue %d/%d
"
 0x7208: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x720c: str    w8, [sp]
 0x7210: mov    w0, #0x51
 0x7214: mov    w1, #3
 0x7218: add    x2, sp, #0x1c8
 0x721c: mov    w5, w20
 0x7220: mov    w6, w21
 0x7224: bl     #0x2378 ; <duss_log_print>
 0x7228: ldr    x8, [sp, #0x98]
 0x722c: ldr    x9, [x8, #8]
 0x7230: cbnz   x9, #0x943c
 0x7234: ldr    x0, [sp, #0xa8]
 0x7238: str    x0, [x8, #8]
 0x723c: bl     #0x2578 ; <stream_buffer_group_addref>
 0x7240: ldr    x0, [x25, #0x430]
 0x7244: add    x1, sp, #0x98
 0x7248: bl     #0x2588 ; <buffer_queue_enqueue>
 0x724c: cbnz   w0, #0x94a0
 0x7250: ldr    x8, [sp, #0x158]
 0x7254: stp    x27, x24, [sp, #0x70]
 0x7258: cbnz   x8, #0x9504
 0x725c: adrp   x0, #0x30000
 0x7260: str    x26, [sp, #0x68]
 0x7264: adrp   x2, #0x1a000
 0x7268: str    x19, [sp, #0x158]
 0x726c: add    x0, x0, #8 ; =0x30008
 0x7270: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x7274: mov    w1, #4
 0x7278: bl     #0x2338 ; <log_mgr_check>
 0x727c: tbz    w0, #0, #0x73a4
 0x7280: bl     #0x2348 ; <co_thread_get>
 0x7284: cbz    x0, #0x7334
 0x7288: adrp   x8, #0x1a000
 0x728c: str    wzr, [sp, #0xdc]
 0x7290: add    x8, x8, #0x440 ; =0x1a440
 0x7294: add    x1, sp, #0xc0
 0x7298: add    x2, sp, #0xdc
 0x729c: str    x8, [sp, #0xc0]
 0x72a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x72a4: adrp   x4, #0x1a000
 0x72a8: adrp   x5, #0x1a000
 0x72ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x72b0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x72b4: mov    w0, #0x51
 0x72b8: mov    w6, #0x2e2
 0x72bc: mov    w1, #4
 0x72c0: add    x2, sp, #0x1c8
 0x72c4: mov    w3, #0x80
 0x72c8: bl     #0x2368 ; <duss_log_gen_head>
 0x72cc: cbz    w0, #0x73a4
 0x72d0: ldr    x6, [sp, #0xc0]
 0x72d4: adrp   x3, #0x1b000
 0x72d8: ldr    w7, [sp, #0xdc]
 0x72dc: adrp   x4, #0x1a000
 0x72e0: ldr    w8, [x19, #0x28]
 0x72e4: adrp   x5, #0x1a000
 0x72e8: ldp    w9, w10, [x19, #0x38]
 0x72ec: ldp    w11, w12, [x19, #0xb0]
 0x72f0: ldr    x13, [x19, #0x30]
 0x72f4: add    x3, x3, #0x59e ; "%s: %s(%s_%x): frame_buffer: pixel format: %d, width: %d, height: %d, plane_count: %d, fra"
 0x72f8: ldrb   w14, [x19, #0xb8]
 0x72fc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7300: add    x5, x5, #0x441 ; "co"
 0x7304: str    w12, [sp, #0x20]
 0x7308: mov    w0, #0x51
 0x730c: str    x13, [sp, #0x28]
 0x7310: mov    w1, #4
 0x7314: str    w11, [sp, #0x18]
 0x7318: add    x2, sp, #0x1c8
 0x731c: str    w14, [sp, #0x30]
 0x7320: str    w10, [sp, #0x10]
 0x7324: str    w9, [sp, #8]
 0x7328: str    w8, [sp]
 0x732c: bl     #0x2378 ; <duss_log_print>
 0x7330: b      #0x73a4
 0x7334: adrp   x4, #0x1a000
 0x7338: adrp   x5, #0x1a000
 0x733c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7340: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7344: mov    w0, #0x51
 0x7348: mov    w6, #0x2e2
 0x734c: mov    w1, #4
 0x7350: add    x2, sp, #0x1c8
 0x7354: mov    w3, #0x80
 0x7358: bl     #0x2368 ; <duss_log_gen_head>
 0x735c: cbz    w0, #0x73a4
 0x7360: ldr    w5, [x19, #0x28]
 0x7364: adrp   x3, #0x1b000
 0x7368: ldp    w6, w7, [x19, #0x38]
 0x736c: ldp    w8, w9, [x19, #0xb0]
 0x7370: ldr    x10, [x19, #0x30]
 0x7374: adrp   x4, #0x1a000
 0x7378: ldrb   w11, [x19, #0xb8]
 0x737c: add    x3, x3, #0x61d ; "%s: frame_buffer: pixel format: %d, width: %d, height: %d, plane_count: %d, frame_id: %d, "
 0x7380: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7384: str    w9, [sp, #8]
 0x7388: mov    w0, #0x51
 0x738c: str    x10, [sp, #0x10]
 0x7390: mov    w1, #4
 0x7394: str    w8, [sp]
 0x7398: add    x2, sp, #0x1c8
 0x739c: str    w11, [sp, #0x18]
 0x73a0: bl     #0x2378 ; <duss_log_print>
 0x73a4: ldr    w8, [x19, #0xb0]
 0x73a8: str    x25, [sp, #0x60]
 0x73ac: cmp    w8, #1
 0x73b0: b.lt   #0x74f4
 0x73b4: adrp   x23, #0x30000
 0x73b8: adrp   x24, #0x1a000
 0x73bc: adrp   x25, #0x1a000
 0x73c0: adrp   x26, #0x1a000
 0x73c4: adrp   x20, #0x1a000
 0x73c8: mov    x22, xzr
 0x73cc: add    x21, x19, #0x50 ; =0x1a050
 0x73d0: add    x23, x23, #8 ; =0x30008
 0x73d4: add    x24, x24, #0x5c4 ; "PRORESRAW"
 0x73d8: add    x25, x25, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x73dc: add    x26, x26, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x73e0: mov    w27, #0x51
 0x73e4: mov    w28, #0x2e8
 0x73e8: add    x20, x20, #0x440 ; =0x1a440
 0x73ec: mov    w1, #4
 0x73f0: mov    x0, x23
 0x73f4: mov    x2, x24
 0x73f8: bl     #0x2338 ; <log_mgr_check>
 0x73fc: tbz    w0, #0, #0x74e0
 0x7400: bl     #0x2348 ; <co_thread_get>
 0x7404: cbz    x0, #0x748c
 0x7408: add    x1, sp, #0xc0
 0x740c: str    x20, [sp, #0xc0]
 0x7410: add    x2, sp, #0xdc
 0x7414: str    wzr, [sp, #0xdc]
 0x7418: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x741c: mov    w1, #4
 0x7420: add    x2, sp, #0x1c8
 0x7424: mov    w3, #0x80
 0x7428: mov    w0, w27
 0x742c: mov    x4, x25
 0x7430: mov    x5, x26
 0x7434: mov    w6, w28
 0x7438: bl     #0x2368 ; <duss_log_gen_head>
 0x743c: cbz    w0, #0x74e0
 0x7440: ldr    x6, [sp, #0xc0]
 0x7444: adrp   x3, #0x1b000
 0x7448: ldr    w7, [sp, #0xdc]
 0x744c: adrp   x5, #0x1a000
 0x7450: ldp    w8, w9, [x21, #-0x10]
 0x7454: ldp    w10, w11, [x21, #-4]
 0x7458: mov    w1, #4
 0x745c: add    x2, sp, #0x1c8
 0x7460: str    w9, [sp, #0x10]
 0x7464: mov    w0, w27
 0x7468: str    w11, [sp, #0x20]
 0x746c: add    x3, x3, #0x691 ; "%s: %s(%s_%x): frame_buffer: plane[%d] bytes_per_line: %d, offset: %d, plane_height: %d, b"
 0x7470: str    w10, [sp, #0x18]
 0x7474: mov    x4, x24
 0x7478: str    w8, [sp, #8]
 0x747c: add    x5, x5, #0x441 ; "co"
 0x7480: str    w22, [sp]
 0x7484: bl     #0x2378 ; <duss_log_print>
 0x7488: b      #0x74e0
 0x748c: mov    w1, #4
 0x7490: add    x2, sp, #0x1c8
 0x7494: mov    w3, #0x80
 0x7498: mov    w0, w27
 0x749c: mov    x4, x25
 0x74a0: mov    x5, x26
 0x74a4: mov    w6, w28
 0x74a8: bl     #0x2368 ; <duss_log_gen_head>
 0x74ac: cbz    w0, #0x74e0
 0x74b0: ldp    w6, w7, [x21, #-0x10]
 0x74b4: ldp    w8, w9, [x21, #-4]
 0x74b8: adrp   x3, #0x1b000
 0x74bc: mov    w1, #4
 0x74c0: add    x2, sp, #0x1c8
 0x74c4: str    w9, [sp, #8]
 0x74c8: mov    w0, w27
 0x74cc: str    w8, [sp]
 0x74d0: add    x3, x3, #0x6fd ; "%s: frame_buffer: plane[%d] bytes_per_line: %d, offset: %d, plane_height: %d, bytes_writte"
 0x74d4: mov    x4, x24
 0x74d8: mov    w5, w22
 0x74dc: bl     #0x2378 ; <duss_log_print>
 0x74e0: ldrsw  x8, [x19, #0xb0]
 0x74e4: add    x22, x22, #1 ; =0x30001
 0x74e8: add    x21, x21, #0x1c
 0x74ec: cmp    x22, x8
 0x74f0: b.lt   #0x73ec
 0x74f4: ldr    x0, [sp, #0xa8]
 0x74f8: ldr    w8, [x0, #0x20]
 0x74fc: cbz    w8, #0x7610
 0x7500: ldr    x8, [x0, #0x50]
 0x7504: ldr    x24, [sp, #0x78]
 0x7508: ldr    x20, [x8]
 0x750c: ldr    w8, [x20, #0x1b8]
 0x7510: cmp    w8, #1
 0x7514: b.ne   #0x9778
 0x7518: ldr    x8, [x20]
 0x751c: ldp    x23, x25, [sp, #0x68]
 0x7520: sbfx   x8, x8, #0, #0x17
 0x7524: cmp    w8, #1
 0x7528: b.ne   #0x97dc
 0x752c: adrp   x0, #0x30000
 0x7530: adrp   x2, #0x1a000
 0x7534: add    x0, x0, #8 ; =0x30008
 0x7538: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x753c: mov    w1, #4
 0x7540: bl     #0x2338 ; <log_mgr_check>
 0x7544: ldr    x21, [sp, #0x60]
 0x7548: tbz    w0, #0, #0x769c
 0x754c: bl     #0x2348 ; <co_thread_get>
 0x7550: cbz    x0, #0x7618
 0x7554: adrp   x8, #0x1a000
 0x7558: str    wzr, [sp, #0xdc]
 0x755c: add    x8, x8, #0x440 ; =0x1a440
 0x7560: add    x1, sp, #0xc0
 0x7564: add    x2, sp, #0xdc
 0x7568: str    x8, [sp, #0xc0]
 0x756c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x7570: adrp   x4, #0x1a000
 0x7574: adrp   x5, #0x1a000
 0x7578: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x757c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7580: mov    w0, #0x51
 0x7584: mov    w6, #0x2f8
 0x7588: mov    w1, #4
 0x758c: add    x2, sp, #0x1c8
 0x7590: mov    w3, #0x80
 0x7594: bl     #0x2368 ; <duss_log_gen_head>
 0x7598: cbz    w0, #0x769c
 0x759c: ldr    x6, [sp, #0xc0]
 0x75a0: adrp   x3, #0x1b000
 0x75a4: ldr    w7, [sp, #0xdc]
 0x75a8: adrp   x4, #0x1a000
 0x75ac: ldr    w8, [x20, #0x28]
 0x75b0: adrp   x5, #0x1a000
 0x75b4: ldp    w9, w10, [x20, #0x30]
 0x75b8: ldr    w11, [x20, #0x1b8]
 0x75bc: add    x3, x3, #0x78e ; "%s: %s(%s_%x): stream_buffer_primary: stream_buffer[%i]: pix_fmt:%d, w:%4d, h:%4d, plane_c"
 0x75c0: ldr    x12, [x20, #0x1c0]
 0x75c4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x75c8: ldp    w13, w14, [x20, #0x38]
 0x75cc: ldp    w15, w16, [x20, #0x40]
 0x75d0: add    x5, x5, #0x441 ; "co"
 0x75d4: mov    w0, #0x51
 0x75d8: str    w14, [sp, #0x38]
 0x75dc: mov    w1, #4
 0x75e0: str    w15, [sp, #0x48]
 0x75e4: add    x2, sp, #0x1c8
 0x75e8: str    w16, [sp, #0x40]
 0x75ec: str    w13, [sp, #0x30]
 0x75f0: str    x12, [sp, #0x28]
 0x75f4: str    w11, [sp, #0x20]
 0x75f8: str    w10, [sp, #0x18]
 0x75fc: str    w9, [sp, #0x10]
 0x7600: str    w8, [sp, #8]
 0x7604: str    wzr, [sp]
 0x7608: bl     #0x2378 ; <duss_log_print>
 0x760c: b      #0x769c
 0x7610: ldr    x24, [sp, #0x78]
 0x7614: b      #0x7f64
 0x7618: adrp   x4, #0x1a000
 0x761c: adrp   x5, #0x1a000
 0x7620: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7624: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7628: mov    w0, #0x51
 0x762c: mov    w6, #0x2f8
 0x7630: mov    w1, #4
 0x7634: add    x2, sp, #0x1c8
 0x7638: mov    w3, #0x80
 0x763c: bl     #0x2368 ; <duss_log_gen_head>
 0x7640: cbz    w0, #0x769c
 0x7644: ldr    w6, [x20, #0x28]
 0x7648: adrp   x3, #0x1b000
 0x764c: ldp    w7, w8, [x20, #0x30]
 0x7650: ldr    w9, [x20, #0x1b8]
 0x7654: adrp   x4, #0x1a000
 0x7658: ldr    x10, [x20, #0x1c0]
 0x765c: mov    w5, wzr
 0x7660: ldp    w11, w12, [x20, #0x38]
 0x7664: ldp    w13, w14, [x20, #0x40]
 0x7668: add    x3, x3, #0x845 ; "%s: stream_buffer_primary: stream_buffer[%i]: pix_fmt:%d, w:%4d, h:%4d, plane_count:%d, ti"
 0x766c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7670: str    w12, [sp, #0x20]
 0x7674: mov    w0, #0x51
 0x7678: str    w13, [sp, #0x30]
 0x767c: mov    w1, #4
 0x7680: str    w14, [sp, #0x28]
 0x7684: add    x2, sp, #0x1c8
 0x7688: str    w11, [sp, #0x18]
 0x768c: str    x10, [sp, #0x10]
 0x7690: str    w9, [sp, #8]
 0x7694: str    w8, [sp]
 0x7698: bl     #0x2378 ; <duss_log_print>
 0x769c: ldr    x8, [x19, #0x30]
 0x76a0: str    x8, [x20, #0x1c0]
 0x76a4: ldr    w9, [x19, #0x28]
 0x76a8: ldr    x8, [sp, #0xa8]
 0x76ac: str    w9, [x20, #0x2c]
 0x76b0: ldr    w9, [x8, #0x20]
 0x76b4: str    x20, [sp, #0x168]
 0x76b8: cmp    w9, #2
 0x76bc: b.lo   #0x785c
 0x76c0: ldr    x8, [x8, #0x50]
 0x76c4: ldr    x20, [x8, #8]
 0x76c8: ldr    w8, [x20, #0x1b8]
 0x76cc: cmp    w8, #1
 0x76d0: b.ne   #0xa46c
 0x76d4: ldr    x8, [x20]
 0x76d8: sbfx   x8, x8, #0, #0x17
 0x76dc: cmp    w8, #1
 0x76e0: b.ne   #0xa4d0
 0x76e4: adrp   x0, #0x30000
 0x76e8: adrp   x2, #0x1a000
 0x76ec: add    x0, x0, #8 ; =0x30008
 0x76f0: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x76f4: mov    w1, #4
 0x76f8: bl     #0x2338 ; <log_mgr_check>
 0x76fc: tbz    w0, #0, #0x7848
 0x7700: bl     #0x2348 ; <co_thread_get>
 0x7704: cbz    x0, #0x77c4
 0x7708: adrp   x8, #0x1a000
 0x770c: str    wzr, [sp, #0xdc]
 0x7710: add    x8, x8, #0x440 ; =0x1a440
 0x7714: add    x1, sp, #0xc0
 0x7718: add    x2, sp, #0xdc
 0x771c: str    x8, [sp, #0xc0]
 0x7720: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x7724: adrp   x4, #0x1a000
 0x7728: adrp   x5, #0x1a000
 0x772c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7730: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7734: mov    w0, #0x51
 0x7738: mov    w6, #0x308
 0x773c: mov    w1, #4
 0x7740: add    x2, sp, #0x1c8
 0x7744: mov    w3, #0x80
 0x7748: bl     #0x2368 ; <duss_log_gen_head>
 0x774c: cbz    w0, #0x7848
 0x7750: ldr    x6, [sp, #0xc0]
 0x7754: adrp   x3, #0x1b000
 0x7758: ldr    w7, [sp, #0xdc]
 0x775c: adrp   x4, #0x1a000
 0x7760: ldr    w8, [x20, #0x28]
 0x7764: adrp   x5, #0x1a000
 0x7768: ldp    w9, w10, [x20, #0x30]
 0x776c: ldr    w11, [x20, #0x1b8]
 0x7770: add    x3, x3, #0x8f1 ; "%s: %s(%s_%x): stream_buffer_seconadary: stream_buffer[%i]: pix_fmt:%d, w:%4d, h:%4d, plan"
 0x7774: ldr    x12, [x20, #0x1c0]
 0x7778: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x777c: ldp    w13, w14, [x20, #0x38]
 0x7780: ldp    w15, w16, [x20, #0x40]
 0x7784: add    x5, x5, #0x441 ; "co"
 0x7788: mov    w0, #0x51
 0x778c: str    w14, [sp, #0x38]
 0x7790: mov    w1, #4
 0x7794: str    w15, [sp, #0x48]
 0x7798: add    x2, sp, #0x1c8
 0x779c: str    w16, [sp, #0x40]
 0x77a0: str    w13, [sp, #0x30]
 0x77a4: str    x12, [sp, #0x28]
 0x77a8: str    w11, [sp, #0x20]
 0x77ac: str    w10, [sp, #0x18]
 0x77b0: str    w9, [sp, #0x10]
 0x77b4: str    w8, [sp, #8]
 0x77b8: str    wzr, [sp]
 0x77bc: bl     #0x2378 ; <duss_log_print>
 0x77c0: b      #0x7848
 0x77c4: adrp   x4, #0x1a000
 0x77c8: adrp   x5, #0x1a000
 0x77cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x77d0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x77d4: mov    w0, #0x51
 0x77d8: mov    w6, #0x308
 0x77dc: mov    w1, #4
 0x77e0: add    x2, sp, #0x1c8
 0x77e4: mov    w3, #0x80
 0x77e8: bl     #0x2368 ; <duss_log_gen_head>
 0x77ec: cbz    w0, #0x7848
 0x77f0: ldr    w6, [x20, #0x28]
 0x77f4: adrp   x3, #0x1b000
 0x77f8: ldp    w7, w8, [x20, #0x30]
 0x77fc: ldr    w9, [x20, #0x1b8]
 0x7800: adrp   x4, #0x1a000
 0x7804: ldr    x10, [x20, #0x1c0]
 0x7808: mov    w5, wzr
 0x780c: ldp    w11, w12, [x20, #0x38]
 0x7810: ldp    w13, w14, [x20, #0x40]
 0x7814: add    x3, x3, #0x9ab ; "%s: stream_buffer_seconadary: stream_buffer[%i]: pix_fmt:%d, w:%4d, h:%4d, plane_count:%d,"
 0x7818: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x781c: str    w12, [sp, #0x20]
 0x7820: mov    w0, #0x51
 0x7824: str    w13, [sp, #0x30]
 0x7828: mov    w1, #4
 0x782c: str    w14, [sp, #0x28]
 0x7830: add    x2, sp, #0x1c8
 0x7834: str    w11, [sp, #0x18]
 0x7838: str    x10, [sp, #0x10]
 0x783c: str    w9, [sp, #8]
 0x7840: str    w8, [sp]
 0x7844: bl     #0x2378 ; <duss_log_print>
 0x7848: ldr    x8, [x19, #0x30]
 0x784c: str    x8, [x20, #0x1c0]
 0x7850: ldr    w8, [x19, #0x28]
 0x7854: str    x20, [sp, #0x170]
 0x7858: str    w8, [x20, #0x2c]
 0x785c: adrp   x0, #0x30000
 0x7860: adrp   x2, #0x1a000
 0x7864: add    x0, x0, #8 ; =0x30008
 0x7868: mov    w1, #5
 0x786c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x7870: bl     #0x2338 ; <log_mgr_check>
 0x7874: tbz    w0, #0, #0x7948
 0x7878: bl     #0x2348 ; <co_thread_get>
 0x787c: cbz    x0, #0x78fc
 0x7880: adrp   x8, #0x1a000
 0x7884: str    wzr, [sp, #0xdc]
 0x7888: add    x8, x8, #0x440 ; =0x1a440
 0x788c: add    x1, sp, #0xc0
 0x7890: add    x2, sp, #0xdc
 0x7894: str    x8, [sp, #0xc0]
 0x7898: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x789c: adrp   x4, #0x1a000
 0x78a0: adrp   x5, #0x1a000
 0x78a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x78a8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x78ac: mov    w0, #0x51
 0x78b0: mov    w6, #0x310
 0x78b4: mov    w1, #3
 0x78b8: add    x2, sp, #0x1c8
 0x78bc: mov    w3, #0x80
 0x78c0: bl     #0x2368 ; <duss_log_gen_head>
 0x78c4: cbz    w0, #0x7948
 0x78c8: ldr    x6, [sp, #0xc0]
 0x78cc: adrp   x3, #0x1b000
 0x78d0: ldr    w7, [sp, #0xdc]
 0x78d4: adrp   x4, #0x1a000
 0x78d8: adrp   x5, #0x1a000
 0x78dc: add    x3, x3, #0xa5a ; "%s: %s(%s_%x): before duss_hal_msenc_encfrm()
"
 0x78e0: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x78e4: add    x5, x5, #0x441 ; "co"
 0x78e8: mov    w0, #0x51
 0x78ec: mov    w1, #3
 0x78f0: add    x2, sp, #0x1c8
 0x78f4: bl     #0x2378 ; <duss_log_print>
 0x78f8: b      #0x7948
 0x78fc: adrp   x4, #0x1a000
 0x7900: adrp   x5, #0x1a000
 0x7904: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7908: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x790c: mov    w0, #0x51
 0x7910: mov    w6, #0x310
 0x7914: mov    w1, #3
 0x7918: add    x2, sp, #0x1c8
 0x791c: mov    w3, #0x80
 0x7920: bl     #0x2368 ; <duss_log_gen_head>
 0x7924: cbz    w0, #0x7948
 0x7928: adrp   x3, #0x1b000
 0x792c: adrp   x4, #0x1a000
 0x7930: add    x3, x3, #0xa89 ; "%s: before duss_hal_msenc_encfrm()
"
 0x7934: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7938: mov    w0, #0x51
 0x793c: mov    w1, #3
 0x7940: add    x2, sp, #0x1c8
 0x7944: bl     #0x2378 ; <duss_log_print>
 0x7948: bl     #0x24d8 ; <duss_osal_get_exec_obj_id>
 0x794c: mov    w20, w0
 0x7950: tbnz   w20, #0x1f, #0x7e64
 0x7954: cbz    x25, #0x7ea4
 0x7958: ldrh   w1, [x21, #0x49e]
 0x795c: cbz    w1, #0x796c
 0x7960: mov    x0, x25
 0x7964: mov    w2, w20
 0x7968: bl     #0x24e8 ; <perf_trace_coroutine_slice_begin>
 0x796c: ldr    x0, [x21, #0xa0]
 0x7970: add    x1, sp, #0x158
 0x7974: bl     #0x2598 ; <duss_hal_msenc_encfrm>
 0x7978: ldrh   w1, [x21, #0x49e]
 0x797c: mov    w22, w0
 0x7980: cbz    w1, #0x7eb4
 0x7984: mov    x0, x25
 0x7988: mov    w2, w20
 0x798c: bl     #0x24f8 ; <perf_trace_coroutine_slice_end>
 0x7990: b      #0x7eb4
 0x7994: cbz    x27, #0x79d4
 0x7998: ldrh   w1, [x25, #0x49a]
 0x799c: cbz    w1, #0x79a8
 0x79a0: mov    x0, x27
 0x79a4: bl     #0x25a8 ; <perf_trace_slice_begin>
 0x79a8: add    x1, sp, #0xb0
 0x79ac: add    x2, sp, #0xa8
 0x79b0: mov    x0, x25
 0x79b4: bl     #0xe838
 0x79b8: ldrh   w1, [x25, #0x49a]
 0x79bc: mov    w21, w0
 0x79c0: cbz    w1, #0x79e8
 0x79c4: mov    x0, x27
 0x79c8: bl     #0x25b8 ; <perf_trace_slice_end>
 0x79cc: cbnz   w21, #0x79ec
 0x79d0: b      #0x6ea0
 0x79d4: add    x1, sp, #0xb0
 0x79d8: add    x2, sp, #0xa8
 0x79dc: mov    x0, x25
 0x79e0: bl     #0xe838
 0x79e4: mov    w21, w0
 0x79e8: cbz    w21, #0x6ea0
 0x79ec: ldr    x8, [sp, #0xa8]
 0x79f0: cbnz   x8, #0x8678
 0x79f4: ldr    x8, [sp, #0xb0]
 0x79f8: cbnz   x8, #0x86dc
 0x79fc: ldr    w8, [x25, #0x464]
 0x7a00: adrp   x2, #0x1b000
 0x7a04: add    x2, x2, #0x21c ; "no_sbuf_group"
 0x7a08: mov    x0, x25
 0x7a0c: mov    x1, x26
 0x7a10: add    w8, w8, #1
 0x7a14: str    w8, [x25, #0x464]
 0x7a18: bl     #0xff18
 0x7a1c: ldr    x0, [x25, #0x408]
 0x7a20: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x7a24: mov    w21, w0
 0x7a28: adrp   x0, #0x30000
 0x7a2c: adrp   x2, #0x1a000
 0x7a30: add    x0, x0, #8 ; =0x30008
 0x7a34: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x7a38: mov    w1, #1
 0x7a3c: bl     #0x2338 ; <log_mgr_check>
 0x7a40: tbz    w0, #0, #0x7bd0
 0x7a44: bl     #0x2348 ; <co_thread_get>
 0x7a48: cbz    x0, #0x7b30
 0x7a4c: adrp   x8, #0x1a000
 0x7a50: str    wzr, [sp, #0xc0]
 0x7a54: add    x8, x8, #0x440 ; =0x1a440
 0x7a58: add    x1, sp, #0xd0
 0x7a5c: add    x2, sp, #0xc0
 0x7a60: str    x8, [sp, #0xd0]
 0x7a64: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x7a68: adrp   x4, #0x1a000
 0x7a6c: adrp   x5, #0x1a000
 0x7a70: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7a74: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7a78: mov    w0, #0x51
 0x7a7c: mov    w6, #0x2af
 0x7a80: mov    w1, #1
 0x7a84: add    x2, sp, #0x1c8
 0x7a88: mov    w3, #0x80
 0x7a8c: bl     #0x2368 ; <duss_log_gen_head>
 0x7a90: cbz    w0, #0x7ab8
 0x7a94: adrp   x3, #0x1a000
 0x7a98: adrp   x4, #0x1a000
 0x7a9c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x7aa0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7aa4: mov    w0, #0x51
 0x7aa8: mov    w5, #0x2af
 0x7aac: mov    w1, #1
 0x7ab0: add    x2, sp, #0x1c8
 0x7ab4: bl     #0x2378 ; <duss_log_print>
 0x7ab8: adrp   x4, #0x1a000
 0x7abc: adrp   x5, #0x1a000
 0x7ac0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7ac4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7ac8: mov    w0, #0x51
 0x7acc: mov    w6, #0x2af
 0x7ad0: mov    w1, #1
 0x7ad4: add    x2, sp, #0x1c8
 0x7ad8: mov    w3, #0x80
 0x7adc: bl     #0x2368 ; <duss_log_gen_head>
 0x7ae0: cbz    w0, #0x7bd0
 0x7ae4: ldr    x6, [sp, #0xd0]
 0x7ae8: adrp   x3, #0x1b000
 0x7aec: ldr    w7, [sp, #0xc0]
 0x7af0: adrp   x4, #0x1a000
 0x7af4: adrp   x5, #0x1a000
 0x7af8: str    w21, [sp]
 0x7afc: add    x3, x3, #0x22a ; "%s: %s(%s_%x): no stream buffer group available, enqueued_allocator_count: %d
"
 0x7b00: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7b04: add    x5, x5, #0x441 ; "co"
 0x7b08: mov    w0, #0x51
 0x7b0c: mov    w1, #1
 0x7b10: add    x2, sp, #0x1c8
 0x7b14: bl     #0x2378 ; <duss_log_print>
 0x7b18: ldrb   w8, [x25, #0x340]
 0x7b1c: cbnz   w8, #0x7bd8
 0x7b20: add    x22, x19, #0xb4 ; =0x1a0b4
 0x7b24: add    x19, x19, #0x30 ; =0x1a030
 0x7b28: add    x26, x26, #0xa0 ; =0x1a0a0
 0x7b2c: b      #0x7c6c
 0x7b30: adrp   x4, #0x1a000
 0x7b34: adrp   x5, #0x1a000
 0x7b38: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7b3c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7b40: mov    w0, #0x51
 0x7b44: mov    w6, #0x2af
 0x7b48: mov    w1, #1
 0x7b4c: add    x2, sp, #0x1c8
 0x7b50: mov    w3, #0x80
 0x7b54: bl     #0x2368 ; <duss_log_gen_head>
 0x7b58: cbz    w0, #0x7b80
 0x7b5c: adrp   x3, #0x1a000
 0x7b60: adrp   x4, #0x1a000
 0x7b64: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x7b68: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7b6c: mov    w0, #0x51
 0x7b70: mov    w5, #0x2af
 0x7b74: mov    w1, #1
 0x7b78: add    x2, sp, #0x1c8
 0x7b7c: bl     #0x2378 ; <duss_log_print>
 0x7b80: adrp   x4, #0x1a000
 0x7b84: adrp   x5, #0x1a000
 0x7b88: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7b8c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7b90: mov    w0, #0x51
 0x7b94: mov    w6, #0x2af
 0x7b98: mov    w1, #1
 0x7b9c: add    x2, sp, #0x1c8
 0x7ba0: mov    w3, #0x80
 0x7ba4: bl     #0x2368 ; <duss_log_gen_head>
 0x7ba8: cbz    w0, #0x7bd0
 0x7bac: adrp   x3, #0x1b000
 0x7bb0: adrp   x4, #0x1a000
 0x7bb4: add    x3, x3, #0x279 ; "%s: no stream buffer group available, enqueued_allocator_count: %d
"
 0x7bb8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7bbc: mov    w0, #0x51
 0x7bc0: mov    w1, #1
 0x7bc4: add    x2, sp, #0x1c8
 0x7bc8: mov    w5, w21
 0x7bcc: bl     #0x2378 ; <duss_log_print>
 0x7bd0: ldrb   w8, [x25, #0x340]
 0x7bd4: cbz    w8, #0x7b20
 0x7bd8: ldr    x20, [x19, #0x30]!
 0x7bdc: add    x0, sp, #0x1c8
 0x7be0: mov    w2, #0x100
 0x7be4: mov    w1, wzr
 0x7be8: mov    x22, x19
 0x7bec: ldr    w21, [x22, #0x84]!
 0x7bf0: ldr    w23, [x26, #0xa0]!
 0x7bf4: bl     #0x22d8 ; <memset>
 0x7bf8: add    x0, sp, #0xd0
 0x7bfc: str    xzr, [sp, #0xd0]
 0x7c00: bl     #0x25c8 ; <duss_osal_get_boot_time>
 0x7c04: ldr    x6, [sp, #0xd0]
 0x7c08: adrp   x3, #0x1b000
 0x7c0c: ldr    w8, [x25, #0x470]
 0x7c10: adrp   x4, #0x1a000
 0x7c14: ldr    w9, [x25, #0x480]
 0x7c18: add    x3, x3, #0xdca ; "%s frame drop happened, timestamp: %ld, boot_time: %lu, frame_id: %u, stream_buffer_cnt: %"
 0x7c1c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7c20: str    w23, [sp]
 0x7c24: add    x0, sp, #0x1c8
 0x7c28: mov    w1, #0x100
 0x7c2c: str    w8, [sp, #8]
 0x7c30: mov    w2, #0x100
 0x7c34: str    w9, [sp, #0x10]
 0x7c38: mov    x5, x20
 0x7c3c: mov    w7, w21
 0x7c40: bl     #0xe788
 0x7c44: ldr    x21, [x25, #0x440]
 0x7c48: add    x0, sp, #0x1c8
 0x7c4c: mov    w1, #0x100
 0x7c50: bl     #0x25d8 ; <__strlen_chk>
 0x7c54: mov    x3, x0
 0x7c58: add    x2, sp, #0x1c8
 0x7c5c: mov    w4, #0x100
 0x7c60: mov    x0, x21
 0x7c64: mov    x1, x20
 0x7c68: bl     #0x25e8 ; <cam_video_monitor_log_frame_info_timestamp>
 0x7c6c: ldr    w0, [x22]
 0x7c70: adrp   x3, #0x1b000
 0x7c74: ldr    x1, [x19]
 0x7c78: add    x3, x3, #0x2bd ; "no sbuf"
 0x7c7c: ldr    w2, [x26]
 0x7c80: bl     #0x25f8 ; <cam_video_monitor_report_venc_drop>
 0x7c84: adrp   x0, #0x30000
 0x7c88: adrp   x2, #0x1a000
 0x7c8c: add    x0, x0, #8 ; =0x30008
 0x7c90: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x7c94: mov    w1, #1
 0x7c98: bl     #0x2338 ; <log_mgr_check>
 0x7c9c: tbz    w0, #0, #0x7e5c
 0x7ca0: bl     #0x2348 ; <co_thread_get>
 0x7ca4: cbz    x0, #0x7da0
 0x7ca8: adrp   x8, #0x1a000
 0x7cac: str    wzr, [sp, #0xc0]
 0x7cb0: add    x8, x8, #0x440 ; =0x1a440
 0x7cb4: add    x1, sp, #0xd0
 0x7cb8: add    x2, sp, #0xc0
 0x7cbc: str    x8, [sp, #0xd0]
 0x7cc0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x7cc4: adrp   x4, #0x1a000
 0x7cc8: adrp   x5, #0x1a000
 0x7ccc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7cd0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7cd4: mov    w0, #0x51
 0x7cd8: mov    w6, #0x2bb
 0x7cdc: mov    w1, #1
 0x7ce0: add    x2, sp, #0x1c8
 0x7ce4: mov    w3, #0x80
 0x7ce8: bl     #0x2368 ; <duss_log_gen_head>
 0x7cec: cbz    w0, #0x7d14
 0x7cf0: adrp   x3, #0x1a000
 0x7cf4: adrp   x4, #0x1a000
 0x7cf8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x7cfc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7d00: mov    w0, #0x51
 0x7d04: mov    w5, #0x2bb
 0x7d08: mov    w1, #1
 0x7d0c: add    x2, sp, #0x1c8
 0x7d10: bl     #0x2378 ; <duss_log_print>
 0x7d14: adrp   x4, #0x1a000
 0x7d18: adrp   x5, #0x1a000
 0x7d1c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7d20: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7d24: mov    w0, #0x51
 0x7d28: mov    w6, #0x2bb
 0x7d2c: mov    w1, #1
 0x7d30: add    x2, sp, #0x1c8
 0x7d34: mov    w3, #0x80
 0x7d38: bl     #0x2368 ; <duss_log_gen_head>
 0x7d3c: cbz    w0, #0x7e5c
 0x7d40: ldr    w8, [x25, #0x460]
 0x7d44: ldr    x0, [x25, #0x430]
 0x7d48: ldr    x20, [sp, #0xd0]
 0x7d4c: ldr    w21, [sp, #0xc0]
 0x7d50: ldr    w19, [x25, #0x464]
 0x7d54: add    w22, w8, #1
 0x7d58: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x7d5c: adrp   x3, #0x1b000
 0x7d60: str    w19, [sp, #8]
 0x7d64: adrp   x4, #0x1a000
 0x7d68: str    w22, [sp]
 0x7d6c: adrp   x5, #0x1a000
 0x7d70: mov    w8, w0
 0x7d74: add    x3, x3, #0x2c5 ; "%s: %s(%s_%x): frame_buffer: drop frame buffer, reason: 1.stream_buffers are used up; or 2"
 0x7d78: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7d7c: add    x5, x5, #0x441 ; "co"
 0x7d80: str    w8, [sp, #0x10]
 0x7d84: mov    w0, #0x51
 0x7d88: mov    w1, #1
 0x7d8c: add    x2, sp, #0x1c8
 0x7d90: mov    x6, x20
 0x7d94: mov    w7, w21
 0x7d98: bl     #0x2378 ; <duss_log_print>
 0x7d9c: b      #0x7e5c
 0x7da0: adrp   x4, #0x1a000
 0x7da4: adrp   x5, #0x1a000
 0x7da8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7dac: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7db0: mov    w0, #0x51
 0x7db4: mov    w6, #0x2bb
 0x7db8: mov    w1, #1
 0x7dbc: add    x2, sp, #0x1c8
 0x7dc0: mov    w3, #0x80
 0x7dc4: bl     #0x2368 ; <duss_log_gen_head>
 0x7dc8: cbz    w0, #0x7df0
 0x7dcc: adrp   x3, #0x1a000
 0x7dd0: adrp   x4, #0x1a000
 0x7dd4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x7dd8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7ddc: mov    w0, #0x51
 0x7de0: mov    w5, #0x2bb
 0x7de4: mov    w1, #1
 0x7de8: add    x2, sp, #0x1c8
 0x7dec: bl     #0x2378 ; <duss_log_print>
 0x7df0: adrp   x4, #0x1a000
 0x7df4: adrp   x5, #0x1a000
 0x7df8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7dfc: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7e00: mov    w0, #0x51
 0x7e04: mov    w6, #0x2bb
 0x7e08: mov    w1, #1
 0x7e0c: add    x2, sp, #0x1c8
 0x7e10: mov    w3, #0x80
 0x7e14: bl     #0x2368 ; <duss_log_gen_head>
 0x7e18: cbz    w0, #0x7e5c
 0x7e1c: ldr    w8, [x25, #0x460]
 0x7e20: ldr    x0, [x25, #0x430]
 0x7e24: ldr    w20, [x25, #0x464]
 0x7e28: add    w19, w8, #1
 0x7e2c: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0x7e30: adrp   x3, #0x1b000
 0x7e34: adrp   x4, #0x1a000
 0x7e38: mov    w7, w0
 0x7e3c: add    x3, x3, #0x39a ; "%s: frame_buffer: drop frame buffer, reason: 1.stream_buffers are used up; or 2.the frame_"
 0x7e40: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7e44: mov    w0, #0x51
 0x7e48: mov    w1, #1
 0x7e4c: add    x2, sp, #0x1c8
 0x7e50: mov    w5, w19
 0x7e54: mov    w6, w20
 0x7e58: bl     #0x2378 ; <duss_log_print>
 0x7e5c: mov    w22, #-0x3ef
 0x7e60: b      #0x8230
 0x7e64: cbz    x25, #0x7ea4
 0x7e68: ldrh   w1, [x21, #0x49e]
 0x7e6c: cbz    w1, #0x7e78
 0x7e70: ldr    x0, [sp, #0x70]
 0x7e74: bl     #0x25a8 ; <perf_trace_slice_begin>
 0x7e78: ldr    x0, [x21, #0xa0]
 0x7e7c: add    x1, sp, #0x158
 0x7e80: bl     #0x2598 ; <duss_hal_msenc_encfrm>
 0x7e84: ldrh   w1, [x21, #0x49e]
 0x7e88: mov    w22, w0
 0x7e8c: cbz    w1, #0x7e98
 0x7e90: ldr    x0, [sp, #0x70]
 0x7e94: bl     #0x25b8 ; <perf_trace_slice_end>
 0x7e98: ldr    x24, [sp, #0x78]
 0x7e9c: ldr    x23, [sp, #0x68]
 0x7ea0: b      #0x7eb4
 0x7ea4: ldr    x0, [x21, #0xa0]
 0x7ea8: add    x1, sp, #0x158
 0x7eac: bl     #0x2598 ; <duss_hal_msenc_encfrm>
 0x7eb0: mov    w22, w0
 0x7eb4: adrp   x0, #0x30000
 0x7eb8: adrp   x2, #0x1a000
 0x7ebc: add    x0, x0, #8 ; =0x30008
 0x7ec0: mov    w1, #5
 0x7ec4: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x7ec8: bl     #0x2338 ; <log_mgr_check>
 0x7ecc: tbz    w0, #0, #0x7fbc
 0x7ed0: bl     #0x2348 ; <co_thread_get>
 0x7ed4: cbz    x0, #0x7f70
 0x7ed8: adrp   x8, #0x1a000
 0x7edc: str    wzr, [sp, #0xdc]
 0x7ee0: add    x8, x8, #0x440 ; =0x1a440
 0x7ee4: add    x1, sp, #0xc0
 0x7ee8: add    x2, sp, #0xdc
 0x7eec: str    x8, [sp, #0xc0]
 0x7ef0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x7ef4: adrp   x4, #0x1a000
 0x7ef8: adrp   x5, #0x1a000
 0x7efc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7f00: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7f04: mov    w0, #0x51
 0x7f08: mov    w6, #0x314
 0x7f0c: mov    w1, #3
 0x7f10: add    x2, sp, #0x1c8
 0x7f14: mov    w3, #0x80
 0x7f18: bl     #0x2368 ; <duss_log_gen_head>
 0x7f1c: cbz    w0, #0x7fbc
 0x7f20: ldr    x6, [sp, #0xc0]
 0x7f24: adrp   x3, #0x1b000
 0x7f28: ldr    w7, [sp, #0xdc]
 0x7f2c: adrp   x4, #0x1a000
 0x7f30: adrp   x5, #0x1a000
 0x7f34: add    x3, x3, #0xaad ; "%s: %s(%s_%x): after duss_hal_msenc_encfrm()
"
 0x7f38: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7f3c: add    x5, x5, #0x441 ; "co"
 0x7f40: mov    w0, #0x51
 0x7f44: mov    w1, #3
 0x7f48: add    x2, sp, #0x1c8
 0x7f4c: bl     #0x2378 ; <duss_log_print>
 0x7f50: cbnz   w22, #0x7fc0
 0x7f54: ldr    w8, [x21, #0x460]
 0x7f58: ldr    x0, [sp, #0xa8]
 0x7f5c: add    w8, w8, #1
 0x7f60: str    w8, [x21, #0x460]
 0x7f64: bl     #0x2608 ; <stream_buffer_group_subref>
 0x7f68: mov    w22, wzr
 0x7f6c: b      #0x8230
 0x7f70: adrp   x4, #0x1a000
 0x7f74: adrp   x5, #0x1a000
 0x7f78: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x7f7c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x7f80: mov    w0, #0x51
 0x7f84: mov    w6, #0x314
 0x7f88: mov    w1, #3
 0x7f8c: add    x2, sp, #0x1c8
 0x7f90: mov    w3, #0x80
 0x7f94: bl     #0x2368 ; <duss_log_gen_head>
 0x7f98: cbz    w0, #0x7fbc
 0x7f9c: adrp   x3, #0x1b000
 0x7fa0: adrp   x4, #0x1a000
 0x7fa4: add    x3, x3, #0xadb ; "%s: after duss_hal_msenc_encfrm()
"
 0x7fa8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x7fac: mov    w0, #0x51
 0x7fb0: mov    w1, #3
 0x7fb4: add    x2, sp, #0x1c8
 0x7fb8: bl     #0x2378 ; <duss_log_print>
 0x7fbc: cbz    w22, #0x7f54
 0x7fc0: ldr    w8, [x21, #0x464]
 0x7fc4: adrp   x2, #0x1b000
 0x7fc8: add    x2, x2, #0xafe ; "enc_error"
 0x7fcc: mov    x0, x21
 0x7fd0: mov    x1, x23
 0x7fd4: add    w8, w8, #1
 0x7fd8: str    w8, [x21, #0x464]
 0x7fdc: bl     #0xff18
 0x7fe0: ldr    w0, [x19, #0xb4]
 0x7fe4: adrp   x3, #0x1b000
 0x7fe8: ldr    x1, [x19, #0x30]
 0x7fec: add    x3, x3, #0xb08 ; "enc error"
 0x7ff0: ldr    w2, [x23, #0xa0]
 0x7ff4: bl     #0x25f8 ; <cam_video_monitor_report_venc_drop>
 0x7ff8: adrp   x0, #0x30000
 0x7ffc: adrp   x2, #0x1a000
 0x8000: add    x0, x0, #8 ; =0x30008
 0x8004: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0x8008: mov    w1, #1
 0x800c: bl     #0x2338 ; <log_mgr_check>
 0x8010: tbz    w0, #0, #0x8194
 0x8014: bl     #0x2348 ; <co_thread_get>
 0x8018: cbz    x0, #0x80f4
 0x801c: adrp   x8, #0x1a000
 0x8020: str    wzr, [sp, #0xdc]
 0x8024: add    x8, x8, #0x440 ; =0x1a440
 0x8028: add    x1, sp, #0xc0
 0x802c: add    x2, sp, #0xdc
 0x8030: str    x8, [sp, #0xc0]
 0x8034: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8038: adrp   x4, #0x1a000
 0x803c: adrp   x5, #0x1a000
 0x8040: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8044: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8048: mov    w0, #0x51
 0x804c: mov    w6, #0x319
 0x8050: mov    w1, #1
 0x8054: add    x2, sp, #0x1c8
 0x8058: mov    w3, #0x80
 0x805c: bl     #0x2368 ; <duss_log_gen_head>
 0x8060: cbz    w0, #0x8088
 0x8064: adrp   x3, #0x1a000
 0x8068: adrp   x4, #0x1a000
 0x806c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x8070: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8074: mov    w0, #0x51
 0x8078: mov    w5, #0x319
 0x807c: mov    w1, #1
 0x8080: add    x2, sp, #0x1c8
 0x8084: bl     #0x2378 ; <duss_log_print>
 0x8088: adrp   x4, #0x1a000
 0x808c: adrp   x5, #0x1a000
 0x8090: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8094: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8098: mov    w0, #0x51
 0x809c: mov    w6, #0x319
 0x80a0: mov    w1, #1
 0x80a4: add    x2, sp, #0x1c8
 0x80a8: mov    w3, #0x80
 0x80ac: bl     #0x2368 ; <duss_log_gen_head>
 0x80b0: cbz    w0, #0x8194
 0x80b4: ldr    x6, [sp, #0xc0]
 0x80b8: adrp   x3, #0x1b000
 0x80bc: ldr    w7, [sp, #0xdc]
 0x80c0: adrp   x4, #0x1a000
 0x80c4: adrp   x5, #0x1a000
 0x80c8: str    w22, [sp]
 0x80cc: add    x3, x3, #0xb12 ; "%s: %s(%s_%x): Failed to submit encoding-request to encoder with error %d
"
 0x80d0: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x80d4: add    x5, x5, #0x441 ; "co"
 0x80d8: mov    w0, #0x51
 0x80dc: mov    w1, #1
 0x80e0: add    x2, sp, #0x1c8
 0x80e4: bl     #0x2378 ; <duss_log_print>
 0x80e8: ldr    x8, [sp, #0xa0]
 0x80ec: cbnz   x8, #0x819c
 0x80f0: b      #0x81a8
 0x80f4: adrp   x4, #0x1a000
 0x80f8: adrp   x5, #0x1a000
 0x80fc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8100: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8104: mov    w0, #0x51
 0x8108: mov    w6, #0x319
 0x810c: mov    w1, #1
 0x8110: add    x2, sp, #0x1c8
 0x8114: mov    w3, #0x80
 0x8118: bl     #0x2368 ; <duss_log_gen_head>
 0x811c: cbz    w0, #0x8144
 0x8120: adrp   x3, #0x1a000
 0x8124: adrp   x4, #0x1a000
 0x8128: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0x812c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8130: mov    w0, #0x51
 0x8134: mov    w5, #0x319
 0x8138: mov    w1, #1
 0x813c: add    x2, sp, #0x1c8
 0x8140: bl     #0x2378 ; <duss_log_print>
 0x8144: adrp   x4, #0x1a000
 0x8148: adrp   x5, #0x1a000
 0x814c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8150: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8154: mov    w0, #0x51
 0x8158: mov    w6, #0x319
 0x815c: mov    w1, #1
 0x8160: add    x2, sp, #0x1c8
 0x8164: mov    w3, #0x80
 0x8168: bl     #0x2368 ; <duss_log_gen_head>
 0x816c: cbz    w0, #0x8194
 0x8170: adrp   x3, #0x1b000
 0x8174: adrp   x4, #0x1a000
 0x8178: add    x3, x3, #0xb5d ; "%s: Failed to submit encoding-request to encoder with error %d
"
 0x817c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x8180: mov    w0, #0x51
 0x8184: mov    w1, #1
 0x8188: add    x2, sp, #0x1c8
 0x818c: mov    w5, w22
 0x8190: bl     #0x2378 ; <duss_log_print>
 0x8194: ldr    x8, [sp, #0xa0]
 0x8198: cbz    x8, #0x81a8
 0x819c: ldr    x0, [x21, #0x3f8]
 0x81a0: add    x1, sp, #0xa0
 0x81a4: bl     #0x2588 ; <buffer_queue_enqueue>
 0x81a8: ldr    x8, [sp, #0x98]
 0x81ac: cbz    x8, #0x81f0
 0x81b0: ldr    x9, [x8]
 0x81b4: cbz    x9, #0x81d0
 0x81b8: ldr    x0, [x21, #0x430]
 0x81bc: add    x1, sp, #0x98
 0x81c0: bl     #0x2618 ; <buffer_queue_dequeue_reverse>
 0x81c4: ldr    x8, [sp, #0x98]
 0x81c8: str    xzr, [x8]
 0x81cc: ldr    x8, [sp, #0x98]
 0x81d0: ldr    x0, [x8, #8]
 0x81d4: cbz    x0, #0xa7cc
 0x81d8: bl     #0x2608 ; <stream_buffer_group_subref>
 0x81dc: ldr    x8, [sp, #0x98]
 0x81e0: add    x1, sp, #0x98
 0x81e4: str    xzr, [x8, #8]
 0x81e8: ldr    x0, [x21, #0x420]
 0x81ec: bl     #0x2588 ; <buffer_queue_enqueue>
 0x81f0: ldr    x1, [sp, #0xa8]
 0x81f4: cbz    x1, #0x8218
 0x81f8: ldr    x0, [sp, #0xb0]
 0x81fc: strb   wzr, [sp, #0xcc]
 0x8200: cbz    x0, #0xa830
 0x8204: add    x2, sp, #0xcc
 0x8208: bl     #0x2628 ; <cam_encoded_buffer_allocator_buffer_update>
 0x820c: ldr    x0, [sp, #0xa8]
 0x8210: bl     #0x2608 ; <stream_buffer_group_subref>
 0x8214: str    xzr, [sp, #0xa8]
 0x8218: ldr    x8, [sp, #0xb0]
 0x821c: cbz    x8, #0x8230
 0x8220: ldr    x0, [x21, #0x408]
 0x8224: add    x1, sp, #0xb0
 0x8228: bl     #0x2588 ; <buffer_queue_enqueue>
 0x822c: str    xzr, [sp, #0xb0]
 0x8230: ldr    x8, [x24, #0x28]
 0x8234: ldr    x9, [sp, #0x80]
 0x8238: cmp    x8, x9
 0x823c: b.ne   #0x8674
 0x8240: mov    w0, w22
 0x8244: add    sp, sp, #0x2d0
 0x8248: ldp    x29, x30, [sp, #0x60]
 0x824c: ldp    x20, x19, [sp, #0x50]
 0x8250: ldp    x22, x21, [sp, #0x40]
 0x8254: ldp    x24, x23, [sp, #0x30]
 0x8258: ldp    x26, x25, [sp, #0x20]
 0x825c: ldp    x28, x27, [sp, #0x10]
 0x8260: ldp    d9, d8, [sp], #0x70
 0x8264: ret    
 0x8268: bl     #0x2348 ; <co_thread_get>
 0x826c: cbnz   x0, #0x87e4
 0x8270: adrp   x4, #0x1a000
 0x8274: adrp   x5, #0x1a000
 0x8278: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x827c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8280: mov    w0, #0x51
 0x8284: mov    w6, #0x26a
 0x8288: add    x2, sp, #0x1c8
 0x828c: mov    w3, #0x80
 0x8290: mov    w1, wzr
 0x8294: bl     #0x2368 ; <duss_log_gen_head>
 0x8298: cbz    w0, #0x886c
 0x829c: adrp   x3, #0x1a000
 0x82a0: adrp   x4, #0x1a000
 0x82a4: adrp   x5, #0x1a000
 0x82a8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x82ac: add    x4, x4, #0x81b ; "param"
 0x82b0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x82b4: mov    w0, #0x51
 0x82b8: mov    w6, #0x26a
 0x82bc: add    x2, sp, #0x1c8
 0x82c0: mov    w1, wzr
 0x82c4: bl     #0x2378 ; <duss_log_print>
 0x82c8: b      #0x886c
 0x82cc: bl     #0x2348 ; <co_thread_get>
 0x82d0: cbnz   x0, #0x8888
 0x82d4: adrp   x4, #0x1a000
 0x82d8: adrp   x5, #0x1a000
 0x82dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x82e0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x82e4: mov    w0, #0x51
 0x82e8: mov    w6, #0x26b
 0x82ec: add    x2, sp, #0x1c8
 0x82f0: mov    w3, #0x80
 0x82f4: mov    w1, wzr
 0x82f8: bl     #0x2368 ; <duss_log_gen_head>
 0x82fc: cbz    w0, #0x8910
 0x8300: adrp   x3, #0x1a000
 0x8304: adrp   x4, #0x1a000
 0x8308: adrp   x5, #0x1a000
 0x830c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8310: add    x4, x4, #0xf87 ; "!param->output.frame_nr"
 0x8314: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8318: mov    w0, #0x51
 0x831c: mov    w6, #0x26b
 0x8320: add    x2, sp, #0x1c8
 0x8324: mov    w1, wzr
 0x8328: bl     #0x2378 ; <duss_log_print>
 0x832c: b      #0x8910
 0x8330: bl     #0x2348 ; <co_thread_get>
 0x8334: cbnz   x0, #0x892c
 0x8338: adrp   x4, #0x1a000
 0x833c: adrp   x5, #0x1a000
 0x8340: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8344: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8348: mov    w0, #0x51
 0x834c: mov    w6, #0x272
 0x8350: add    x2, sp, #0x1c8
 0x8354: mov    w3, #0x80
 0x8358: mov    w1, wzr
 0x835c: bl     #0x2368 ; <duss_log_gen_head>
 0x8360: cbz    w0, #0x89b4
 0x8364: adrp   x3, #0x1a000
 0x8368: adrp   x4, #0x1a000
 0x836c: adrp   x5, #0x1a000
 0x8370: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8374: add    x4, x4, #0xf9f ; "fbuf"
 0x8378: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x837c: mov    w0, #0x51
 0x8380: mov    w6, #0x272
 0x8384: add    x2, sp, #0x1c8
 0x8388: mov    w1, wzr
 0x838c: bl     #0x2378 ; <duss_log_print>
 0x8390: b      #0x89b4
 0x8394: bl     #0x2348 ; <co_thread_get>
 0x8398: cbnz   x0, #0x89d0
 0x839c: adrp   x4, #0x1a000
 0x83a0: adrp   x5, #0x1a000
 0x83a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x83a8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x83ac: mov    w0, #0x51
 0x83b0: mov    w6, #0x273
 0x83b4: add    x2, sp, #0x1c8
 0x83b8: mov    w3, #0x80
 0x83bc: mov    w1, wzr
 0x83c0: bl     #0x2368 ; <duss_log_gen_head>
 0x83c4: cbz    w0, #0x8a58
 0x83c8: adrp   x3, #0x1a000
 0x83cc: adrp   x4, #0x1a000
 0x83d0: adrp   x5, #0x1a000
 0x83d4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x83d8: add    x4, x4, #0xfa4 ; "fbuf->buffer"
 0x83dc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x83e0: mov    w0, #0x51
 0x83e4: mov    w6, #0x273
 0x83e8: add    x2, sp, #0x1c8
 0x83ec: mov    w1, wzr
 0x83f0: bl     #0x2378 ; <duss_log_print>
 0x83f4: b      #0x8a58
 0x83f8: bl     #0x2348 ; <co_thread_get>
 0x83fc: cbnz   x0, #0x8a74
 0x8400: adrp   x4, #0x1a000
 0x8404: adrp   x5, #0x1a000
 0x8408: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x840c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8410: mov    w0, #0x51
 0x8414: mov    w6, #0x274
 0x8418: add    x2, sp, #0x1c8
 0x841c: mov    w3, #0x80
 0x8420: mov    w1, wzr
 0x8424: bl     #0x2368 ; <duss_log_gen_head>
 0x8428: cbz    w0, #0x8afc
 0x842c: adrp   x3, #0x1a000
 0x8430: adrp   x4, #0x1a000
 0x8434: adrp   x5, #0x1a000
 0x8438: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x843c: add    x4, x4, #0xfb1 ; "fbuf->plane_count == 1"
 0x8440: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8444: mov    w0, #0x51
 0x8448: mov    w6, #0x274
 0x844c: add    x2, sp, #0x1c8
 0x8450: mov    w1, wzr
 0x8454: bl     #0x2378 ; <duss_log_print>
 0x8458: b      #0x8afc
 0x845c: bl     #0x2348 ; <co_thread_get>
 0x8460: cbnz   x0, #0x8b18
 0x8464: adrp   x4, #0x1a000
 0x8468: adrp   x5, #0x1a000
 0x846c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8470: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8474: mov    w0, #0x51
 0x8478: mov    w6, #0x276
 0x847c: add    x2, sp, #0x1c8
 0x8480: mov    w3, #0x80
 0x8484: mov    w1, wzr
 0x8488: bl     #0x2368 ; <duss_log_gen_head>
 0x848c: cbz    w0, #0x8ba0
 0x8490: adrp   x3, #0x1a000
 0x8494: adrp   x4, #0x1a000
 0x8498: adrp   x5, #0x1a000
 0x849c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x84a0: add    x4, x4, #0xfc8 ; "eng->allocator_pool"
 0x84a4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x84a8: mov    w0, #0x51
 0x84ac: mov    w6, #0x276
 0x84b0: add    x2, sp, #0x1c8
 0x84b4: mov    w1, wzr
 0x84b8: bl     #0x2378 ; <duss_log_print>
 0x84bc: b      #0x8ba0
 0x84c0: bl     #0x2348 ; <co_thread_get>
 0x84c4: cbnz   x0, #0x8bbc
 0x84c8: adrp   x4, #0x1a000
 0x84cc: adrp   x5, #0x1a000
 0x84d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x84d4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x84d8: mov    w0, #0x51
 0x84dc: mov    w6, #0x277
 0x84e0: add    x2, sp, #0x1c8
 0x84e4: mov    w3, #0x80
 0x84e8: mov    w1, wzr
 0x84ec: bl     #0x2368 ; <duss_log_gen_head>
 0x84f0: cbz    w0, #0x8c44
 0x84f4: adrp   x3, #0x1a000
 0x84f8: adrp   x4, #0x1a000
 0x84fc: adrp   x5, #0x1a000
 0x8500: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8504: add    x4, x4, #0xfdc ; "eng->encoding_request_pool"
 0x8508: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x850c: mov    w0, #0x51
 0x8510: mov    w6, #0x277
 0x8514: add    x2, sp, #0x1c8
 0x8518: mov    w1, wzr
 0x851c: bl     #0x2378 ; <duss_log_print>
 0x8520: b      #0x8c44
 0x8524: bl     #0x2348 ; <co_thread_get>
 0x8528: cbnz   x0, #0x8c60
 0x852c: adrp   x4, #0x1a000
 0x8530: adrp   x5, #0x1a000
 0x8534: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8538: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x853c: mov    w0, #0x51
 0x8540: mov    w6, #0x278
 0x8544: add    x2, sp, #0x1c8
 0x8548: mov    w3, #0x80
 0x854c: mov    w1, wzr
 0x8550: bl     #0x2368 ; <duss_log_gen_head>
 0x8554: cbz    w0, #0x8ce8
 0x8558: adrp   x3, #0x1a000
 0x855c: adrp   x4, #0x1a000
 0x8560: adrp   x5, #0x1a000
 0x8564: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8568: add    x4, x4, #0xff7 ; "eng->encoding_request_q"
 0x856c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8570: mov    w0, #0x51
 0x8574: mov    w6, #0x278
 0x8578: add    x2, sp, #0x1c8
 0x857c: mov    w1, wzr
 0x8580: bl     #0x2378 ; <duss_log_print>
 0x8584: b      #0x8ce8
 0x8588: bl     #0x2348 ; <co_thread_get>
 0x858c: cbnz   x0, #0x8d04
 0x8590: adrp   x4, #0x1a000
 0x8594: adrp   x5, #0x1a000
 0x8598: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x859c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x85a0: mov    w0, #0x51
 0x85a4: mov    w6, #0x285
 0x85a8: add    x2, sp, #0x1c8
 0x85ac: mov    w3, #0x80
 0x85b0: mov    w1, wzr
 0x85b4: bl     #0x2368 ; <duss_log_gen_head>
 0x85b8: cbz    w0, #0x8d80
 0x85bc: adrp   x3, #0x1b000
 0x85c0: adrp   x4, #0x1a000
 0x85c4: add    x3, x3, #0xc9 ; "%s: proresraw_ccm_cct_get_from_adj failed:%d
"
 0x85c8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x85cc: mov    w0, #0x51
 0x85d0: add    x2, sp, #0x1c8
 0x85d4: mov    w1, wzr
 0x85d8: mov    w5, w20
 0x85dc: bl     #0x2378 ; <duss_log_print>
 0x85e0: bl     #0x2348 ; <co_thread_get>
 0x85e4: cbz    x0, #0x8d88
 0x85e8: adrp   x8, #0x1a000
 0x85ec: str    wzr, [sp, #0xc0]
 0x85f0: add    x8, x8, #0x440 ; =0x1a440
 0x85f4: add    x1, sp, #0xd0
 0x85f8: add    x2, sp, #0xc0
 0x85fc: str    x8, [sp, #0xd0]
 0x8600: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8604: adrp   x19, #0x1a000
 0x8608: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x860c: adrp   x5, #0x1a000
 0x8610: mov    w20, #0x285
 0x8614: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8618: mov    w0, #0x51
 0x861c: add    x2, sp, #0x1c8
 0x8620: mov    w3, #0x80
 0x8624: mov    w1, wzr
 0x8628: mov    x4, x19
 0x862c: mov    w6, w20
 0x8630: bl     #0x2368 ; <duss_log_gen_head>
 0x8634: cbz    w0, #0x8de0
 0x8638: ldr    x5, [sp, #0xd0]
 0x863c: adrp   x3, #0x1a000
 0x8640: ldr    w6, [sp, #0xc0]
 0x8644: adrp   x4, #0x1a000
 0x8648: adrp   x7, #0x1b000
 0x864c: str    w20, [sp, #8]
 0x8650: mov    w1, wzr
 0x8654: str    x19, [sp]
 0x8658: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x865c: add    x4, x4, #0x441 ; "co"
 0x8660: mov    w0, #0x51
 0x8664: add    x7, x7, #0xf7 ; "0"
 0x8668: add    x2, sp, #0x1c8
 0x866c: bl     #0x2378 ; <duss_log_print>
 0x8670: b      #0x8de0
 0x8674: bl     #0x23d8 ; <__stack_chk_fail>
 0x8678: bl     #0x2348 ; <co_thread_get>
 0x867c: cbnz   x0, #0x9568
 0x8680: adrp   x4, #0x1a000
 0x8684: adrp   x5, #0x1a000
 0x8688: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x868c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8690: mov    w0, #0x51
 0x8694: mov    w6, #0x2a8
 0x8698: add    x2, sp, #0x1c8
 0x869c: mov    w3, #0x80
 0x86a0: mov    w1, wzr
 0x86a4: bl     #0x2368 ; <duss_log_gen_head>
 0x86a8: cbz    w0, #0x95f0
 0x86ac: adrp   x3, #0x1a000
 0x86b0: adrp   x4, #0x1b000
 0x86b4: adrp   x5, #0x1a000
 0x86b8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x86bc: add    x4, x4, #0x1e9 ; "buffer_group == ((void*)0)"
 0x86c0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x86c4: mov    w0, #0x51
 0x86c8: mov    w6, #0x2a8
 0x86cc: add    x2, sp, #0x1c8
 0x86d0: mov    w1, wzr
 0x86d4: bl     #0x2378 ; <duss_log_print>
 0x86d8: b      #0x95f0
 0x86dc: bl     #0x2348 ; <co_thread_get>
 0x86e0: cbnz   x0, #0x960c
 0x86e4: adrp   x4, #0x1a000
 0x86e8: adrp   x5, #0x1a000
 0x86ec: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x86f0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x86f4: mov    w0, #0x51
 0x86f8: mov    w6, #0x2a9
 0x86fc: add    x2, sp, #0x1c8
 0x8700: mov    w3, #0x80
 0x8704: mov    w1, wzr
 0x8708: bl     #0x2368 ; <duss_log_gen_head>
 0x870c: cbz    w0, #0x9694
 0x8710: adrp   x3, #0x1a000
 0x8714: adrp   x4, #0x1b000
 0x8718: adrp   x5, #0x1a000
 0x871c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8720: add    x4, x4, #0x204 ; "allocator == ((void*)0)"
 0x8724: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8728: mov    w0, #0x51
 0x872c: mov    w6, #0x2a9
 0x8730: add    x2, sp, #0x1c8
 0x8734: mov    w1, wzr
 0x8738: bl     #0x2378 ; <duss_log_print>
 0x873c: b      #0x9694
 0x8740: adrp   x8, #0x1a000
 0x8744: str    wzr, [sp, #0xd0]
 0x8748: add    x8, x8, #0x440 ; =0x1a440
 0x874c: add    x1, sp, #0x158
 0x8750: add    x2, sp, #0xd0
 0x8754: str    x8, [sp, #0x158]
 0x8758: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x875c: adrp   x19, #0x1a000
 0x8760: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8764: adrp   x5, #0x1a000
 0x8768: mov    w20, #0x269
 0x876c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8770: mov    w0, #0x51
 0x8774: add    x2, sp, #0x1c8
 0x8778: mov    w3, #0x80
 0x877c: mov    w1, wzr
 0x8780: mov    x4, x19
 0x8784: mov    w6, w20
 0x8788: bl     #0x2368 ; <duss_log_gen_head>
 0x878c: cbz    w0, #0x87c8
 0x8790: ldr    x5, [sp, #0x158]
 0x8794: adrp   x3, #0x1a000
 0x8798: ldr    w6, [sp, #0xd0]
 0x879c: adrp   x4, #0x1a000
 0x87a0: adrp   x7, #0x1a000
 0x87a4: str    w20, [sp, #8]
 0x87a8: mov    w1, wzr
 0x87ac: str    x19, [sp]
 0x87b0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x87b4: add    x4, x4, #0x441 ; "co"
 0x87b8: mov    w0, #0x51
 0x87bc: add    x7, x7, #0x5c0 ; "ops"
 0x87c0: add    x2, sp, #0x1c8
 0x87c4: bl     #0x2378 ; <duss_log_print>
 0x87c8: adrp   x4, #0x1a000
 0x87cc: adrp   x5, #0x1a000
 0x87d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x87d4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x87d8: mov    w0, #0x51
 0x87dc: mov    w6, #0x269
 0x87e0: b      #0xab20
 0x87e4: adrp   x8, #0x1a000
 0x87e8: str    wzr, [sp, #0xd0]
 0x87ec: add    x8, x8, #0x440 ; =0x1a440
 0x87f0: add    x1, sp, #0x158
 0x87f4: add    x2, sp, #0xd0
 0x87f8: str    x8, [sp, #0x158]
 0x87fc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8800: adrp   x19, #0x1a000
 0x8804: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8808: adrp   x5, #0x1a000
 0x880c: mov    w20, #0x26a
 0x8810: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8814: mov    w0, #0x51
 0x8818: add    x2, sp, #0x1c8
 0x881c: mov    w3, #0x80
 0x8820: mov    w1, wzr
 0x8824: mov    x4, x19
 0x8828: mov    w6, w20
 0x882c: bl     #0x2368 ; <duss_log_gen_head>
 0x8830: cbz    w0, #0x886c
 0x8834: ldr    x5, [sp, #0x158]
 0x8838: adrp   x3, #0x1a000
 0x883c: ldr    w6, [sp, #0xd0]
 0x8840: adrp   x4, #0x1a000
 0x8844: adrp   x7, #0x1a000
 0x8848: str    w20, [sp, #8]
 0x884c: mov    w1, wzr
 0x8850: str    x19, [sp]
 0x8854: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x8858: add    x4, x4, #0x441 ; "co"
 0x885c: mov    w0, #0x51
 0x8860: add    x7, x7, #0x81b ; "param"
 0x8864: add    x2, sp, #0x1c8
 0x8868: bl     #0x2378 ; <duss_log_print>
 0x886c: adrp   x4, #0x1a000
 0x8870: adrp   x5, #0x1a000
 0x8874: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8878: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x887c: mov    w0, #0x51
 0x8880: mov    w6, #0x26a
 0x8884: b      #0xab20
 0x8888: adrp   x8, #0x1a000
 0x888c: str    wzr, [sp, #0xd0]
 0x8890: add    x8, x8, #0x440 ; =0x1a440
 0x8894: add    x1, sp, #0x158
 0x8898: add    x2, sp, #0xd0
 0x889c: str    x8, [sp, #0x158]
 0x88a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x88a4: adrp   x19, #0x1a000
 0x88a8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x88ac: adrp   x5, #0x1a000
 0x88b0: mov    w20, #0x26b
 0x88b4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x88b8: mov    w0, #0x51
 0x88bc: add    x2, sp, #0x1c8
 0x88c0: mov    w3, #0x80
 0x88c4: mov    w1, wzr
 0x88c8: mov    x4, x19
 0x88cc: mov    w6, w20
 0x88d0: bl     #0x2368 ; <duss_log_gen_head>
 0x88d4: cbz    w0, #0x8910
 0x88d8: ldr    x5, [sp, #0x158]
 0x88dc: adrp   x3, #0x1a000
 0x88e0: ldr    w6, [sp, #0xd0]
 0x88e4: adrp   x4, #0x1a000
 0x88e8: adrp   x7, #0x1a000
 0x88ec: str    w20, [sp, #8]
 0x88f0: mov    w1, wzr
 0x88f4: str    x19, [sp]
 0x88f8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x88fc: add    x4, x4, #0x441 ; "co"
 0x8900: mov    w0, #0x51
 0x8904: add    x7, x7, #0xf87 ; "!param->output.frame_nr"
 0x8908: add    x2, sp, #0x1c8
 0x890c: bl     #0x2378 ; <duss_log_print>
 0x8910: adrp   x4, #0x1a000
 0x8914: adrp   x5, #0x1a000
 0x8918: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x891c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8920: mov    w0, #0x51
 0x8924: mov    w6, #0x26b
 0x8928: b      #0xab20
 0x892c: adrp   x8, #0x1a000
 0x8930: str    wzr, [sp, #0xc0]
 0x8934: add    x8, x8, #0x440 ; =0x1a440
 0x8938: add    x1, sp, #0xd0
 0x893c: add    x2, sp, #0xc0
 0x8940: str    x8, [sp, #0xd0]
 0x8944: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8948: adrp   x19, #0x1a000
 0x894c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8950: adrp   x5, #0x1a000
 0x8954: mov    w20, #0x272
 0x8958: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x895c: mov    w0, #0x51
 0x8960: add    x2, sp, #0x1c8
 0x8964: mov    w3, #0x80
 0x8968: mov    w1, wzr
 0x896c: mov    x4, x19
 0x8970: mov    w6, w20
 0x8974: bl     #0x2368 ; <duss_log_gen_head>
 0x8978: cbz    w0, #0x89b4
 0x897c: ldr    x5, [sp, #0xd0]
 0x8980: adrp   x3, #0x1a000
 0x8984: ldr    w6, [sp, #0xc0]
 0x8988: adrp   x4, #0x1a000
 0x898c: adrp   x7, #0x1a000
 0x8990: str    w20, [sp, #8]
 0x8994: mov    w1, wzr
 0x8998: str    x19, [sp]
 0x899c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x89a0: add    x4, x4, #0x441 ; "co"
 0x89a4: mov    w0, #0x51
 0x89a8: add    x7, x7, #0xf9f ; "fbuf"
 0x89ac: add    x2, sp, #0x1c8
 0x89b0: bl     #0x2378 ; <duss_log_print>
 0x89b4: adrp   x4, #0x1a000
 0x89b8: adrp   x5, #0x1a000
 0x89bc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x89c0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x89c4: mov    w0, #0x51
 0x89c8: mov    w6, #0x272
 0x89cc: b      #0xab20
 0x89d0: adrp   x8, #0x1a000
 0x89d4: str    wzr, [sp, #0xc0]
 0x89d8: add    x8, x8, #0x440 ; =0x1a440
 0x89dc: add    x1, sp, #0xd0
 0x89e0: add    x2, sp, #0xc0
 0x89e4: str    x8, [sp, #0xd0]
 0x89e8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x89ec: adrp   x19, #0x1a000
 0x89f0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x89f4: adrp   x5, #0x1a000
 0x89f8: mov    w20, #0x273
 0x89fc: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8a00: mov    w0, #0x51
 0x8a04: add    x2, sp, #0x1c8
 0x8a08: mov    w3, #0x80
 0x8a0c: mov    w1, wzr
 0x8a10: mov    x4, x19
 0x8a14: mov    w6, w20
 0x8a18: bl     #0x2368 ; <duss_log_gen_head>
 0x8a1c: cbz    w0, #0x8a58
 0x8a20: ldr    x5, [sp, #0xd0]
 0x8a24: adrp   x3, #0x1a000
 0x8a28: ldr    w6, [sp, #0xc0]
 0x8a2c: adrp   x4, #0x1a000
 0x8a30: adrp   x7, #0x1a000
 0x8a34: str    w20, [sp, #8]
 0x8a38: mov    w1, wzr
 0x8a3c: str    x19, [sp]
 0x8a40: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x8a44: add    x4, x4, #0x441 ; "co"
 0x8a48: mov    w0, #0x51
 0x8a4c: add    x7, x7, #0xfa4 ; "fbuf->buffer"
 0x8a50: add    x2, sp, #0x1c8
 0x8a54: bl     #0x2378 ; <duss_log_print>
 0x8a58: adrp   x4, #0x1a000
 0x8a5c: adrp   x5, #0x1a000
 0x8a60: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8a64: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8a68: mov    w0, #0x51
 0x8a6c: mov    w6, #0x273
 0x8a70: b      #0xab20
 0x8a74: adrp   x8, #0x1a000
 0x8a78: str    wzr, [sp, #0xc0]
 0x8a7c: add    x8, x8, #0x440 ; =0x1a440
 0x8a80: add    x1, sp, #0xd0
 0x8a84: add    x2, sp, #0xc0
 0x8a88: str    x8, [sp, #0xd0]
 0x8a8c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8a90: adrp   x19, #0x1a000
 0x8a94: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8a98: adrp   x5, #0x1a000
 0x8a9c: mov    w20, #0x274
 0x8aa0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8aa4: mov    w0, #0x51
 0x8aa8: add    x2, sp, #0x1c8
 0x8aac: mov    w3, #0x80
 0x8ab0: mov    w1, wzr
 0x8ab4: mov    x4, x19
 0x8ab8: mov    w6, w20
 0x8abc: bl     #0x2368 ; <duss_log_gen_head>
 0x8ac0: cbz    w0, #0x8afc
 0x8ac4: ldr    x5, [sp, #0xd0]
 0x8ac8: adrp   x3, #0x1a000
 0x8acc: ldr    w6, [sp, #0xc0]
 0x8ad0: adrp   x4, #0x1a000
 0x8ad4: adrp   x7, #0x1a000
 0x8ad8: str    w20, [sp, #8]
 0x8adc: mov    w1, wzr
 0x8ae0: str    x19, [sp]
 0x8ae4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x8ae8: add    x4, x4, #0x441 ; "co"
 0x8aec: mov    w0, #0x51
 0x8af0: add    x7, x7, #0xfb1 ; "fbuf->plane_count == 1"
 0x8af4: add    x2, sp, #0x1c8
 0x8af8: bl     #0x2378 ; <duss_log_print>
 0x8afc: adrp   x4, #0x1a000
 0x8b00: adrp   x5, #0x1a000
 0x8b04: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8b08: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8b0c: mov    w0, #0x51
 0x8b10: mov    w6, #0x274
 0x8b14: b      #0xab20
 0x8b18: adrp   x8, #0x1a000
 0x8b1c: str    wzr, [sp, #0xc0]
 0x8b20: add    x8, x8, #0x440 ; =0x1a440
 0x8b24: add    x1, sp, #0xd0
 0x8b28: add    x2, sp, #0xc0
 0x8b2c: str    x8, [sp, #0xd0]
 0x8b30: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8b34: adrp   x19, #0x1a000
 0x8b38: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8b3c: adrp   x5, #0x1a000
 0x8b40: mov    w20, #0x276
 0x8b44: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8b48: mov    w0, #0x51
 0x8b4c: add    x2, sp, #0x1c8
 0x8b50: mov    w3, #0x80
 0x8b54: mov    w1, wzr
 0x8b58: mov    x4, x19
 0x8b5c: mov    w6, w20
 0x8b60: bl     #0x2368 ; <duss_log_gen_head>
 0x8b64: cbz    w0, #0x8ba0
 0x8b68: ldr    x5, [sp, #0xd0]
 0x8b6c: adrp   x3, #0x1a000
 0x8b70: ldr    w6, [sp, #0xc0]
 0x8b74: adrp   x4, #0x1a000
 0x8b78: adrp   x7, #0x1a000
 0x8b7c: str    w20, [sp, #8]
 0x8b80: mov    w1, wzr
 0x8b84: str    x19, [sp]
 0x8b88: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x8b8c: add    x4, x4, #0x441 ; "co"
 0x8b90: mov    w0, #0x51
 0x8b94: add    x7, x7, #0xfc8 ; "eng->allocator_pool"
 0x8b98: add    x2, sp, #0x1c8
 0x8b9c: bl     #0x2378 ; <duss_log_print>
 0x8ba0: adrp   x4, #0x1a000
 0x8ba4: adrp   x5, #0x1a000
 0x8ba8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8bac: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8bb0: mov    w0, #0x51
 0x8bb4: mov    w6, #0x276
 0x8bb8: b      #0xab20
 0x8bbc: adrp   x8, #0x1a000
 0x8bc0: str    wzr, [sp, #0xc0]
 0x8bc4: add    x8, x8, #0x440 ; =0x1a440
 0x8bc8: add    x1, sp, #0xd0
 0x8bcc: add    x2, sp, #0xc0
 0x8bd0: str    x8, [sp, #0xd0]
 0x8bd4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8bd8: adrp   x19, #0x1a000
 0x8bdc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8be0: adrp   x5, #0x1a000
 0x8be4: mov    w20, #0x277
 0x8be8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8bec: mov    w0, #0x51
 0x8bf0: add    x2, sp, #0x1c8
 0x8bf4: mov    w3, #0x80
 0x8bf8: mov    w1, wzr
 0x8bfc: mov    x4, x19
 0x8c00: mov    w6, w20
 0x8c04: bl     #0x2368 ; <duss_log_gen_head>
 0x8c08: cbz    w0, #0x8c44
 0x8c0c: ldr    x5, [sp, #0xd0]
 0x8c10: adrp   x3, #0x1a000
 0x8c14: ldr    w6, [sp, #0xc0]
 0x8c18: adrp   x4, #0x1a000
 0x8c1c: adrp   x7, #0x1a000
 0x8c20: str    w20, [sp, #8]
 0x8c24: mov    w1, wzr
 0x8c28: str    x19, [sp]
 0x8c2c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x8c30: add    x4, x4, #0x441 ; "co"
 0x8c34: mov    w0, #0x51
 0x8c38: add    x7, x7, #0xfdc ; "eng->encoding_request_pool"
 0x8c3c: add    x2, sp, #0x1c8
 0x8c40: bl     #0x2378 ; <duss_log_print>
 0x8c44: adrp   x4, #0x1a000
 0x8c48: adrp   x5, #0x1a000
 0x8c4c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8c50: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8c54: mov    w0, #0x51
 0x8c58: mov    w6, #0x277
 0x8c5c: b      #0xab20
 0x8c60: adrp   x8, #0x1a000
 0x8c64: str    wzr, [sp, #0xc0]
 0x8c68: add    x8, x8, #0x440 ; =0x1a440
 0x8c6c: add    x1, sp, #0xd0
 0x8c70: add    x2, sp, #0xc0
 0x8c74: str    x8, [sp, #0xd0]
 0x8c78: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8c7c: adrp   x19, #0x1a000
 0x8c80: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8c84: adrp   x5, #0x1a000
 0x8c88: mov    w20, #0x278
 0x8c8c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8c90: mov    w0, #0x51
 0x8c94: add    x2, sp, #0x1c8
 0x8c98: mov    w3, #0x80
 0x8c9c: mov    w1, wzr
 0x8ca0: mov    x4, x19
 0x8ca4: mov    w6, w20
 0x8ca8: bl     #0x2368 ; <duss_log_gen_head>
 0x8cac: cbz    w0, #0x8ce8
 0x8cb0: ldr    x5, [sp, #0xd0]
 0x8cb4: adrp   x3, #0x1a000
 0x8cb8: ldr    w6, [sp, #0xc0]
 0x8cbc: adrp   x4, #0x1a000
 0x8cc0: adrp   x7, #0x1a000
 0x8cc4: str    w20, [sp, #8]
 0x8cc8: mov    w1, wzr
 0x8ccc: str    x19, [sp]
 0x8cd0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x8cd4: add    x4, x4, #0x441 ; "co"
 0x8cd8: mov    w0, #0x51
 0x8cdc: add    x7, x7, #0xff7 ; "eng->encoding_request_q"
 0x8ce0: add    x2, sp, #0x1c8
 0x8ce4: bl     #0x2378 ; <duss_log_print>
 0x8ce8: adrp   x4, #0x1a000
 0x8cec: adrp   x5, #0x1a000
 0x8cf0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8cf4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8cf8: mov    w0, #0x51
 0x8cfc: mov    w6, #0x278
 0x8d00: b      #0xab20
 0x8d04: adrp   x8, #0x1a000
 0x8d08: str    wzr, [sp, #0xc0]
 0x8d0c: add    x8, x8, #0x440 ; =0x1a440
 0x8d10: add    x1, sp, #0xd0
 0x8d14: add    x2, sp, #0xc0
 0x8d18: str    x8, [sp, #0xd0]
 0x8d1c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x8d20: adrp   x4, #0x1a000
 0x8d24: adrp   x5, #0x1a000
 0x8d28: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8d2c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8d30: mov    w0, #0x51
 0x8d34: mov    w6, #0x285
 0x8d38: add    x2, sp, #0x1c8
 0x8d3c: mov    w3, #0x80
 0x8d40: mov    w1, wzr
 0x8d44: bl     #0x2368 ; <duss_log_gen_head>
 0x8d48: cbz    w0, #0x8d80
 0x8d4c: ldr    x6, [sp, #0xd0]
 0x8d50: adrp   x3, #0x1b000
 0x8d54: ldr    w7, [sp, #0xc0]
 0x8d58: adrp   x4, #0x1a000
 0x8d5c: adrp   x5, #0x1a000
 0x8d60: str    w20, [sp]
 0x8d64: add    x3, x3, #0x90 ; "%s: %s(%s_%x): proresraw_ccm_cct_get_from_adj failed:%d
"
 0x8d68: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0x8d6c: mov    w0, #0x51
 0x8d70: add    x5, x5, #0x441 ; "co"
 0x8d74: add    x2, sp, #0x1c8
 0x8d78: mov    w1, wzr
 0x8d7c: bl     #0x2378 ; <duss_log_print>
 0x8d80: bl     #0x2348 ; <co_thread_get>
 0x8d84: cbnz   x0, #0x85e8
 0x8d88: adrp   x4, #0x1a000
 0x8d8c: adrp   x5, #0x1a000
 0x8d90: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8d94: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8d98: mov    w0, #0x51
 0x8d9c: mov    w6, #0x285
 0x8da0: add    x2, sp, #0x1c8
 0x8da4: mov    w3, #0x80
 0x8da8: mov    w1, wzr
 0x8dac: bl     #0x2368 ; <duss_log_gen_head>
 0x8db0: cbz    w0, #0x8de0
 0x8db4: adrp   x3, #0x1a000
 0x8db8: adrp   x4, #0x1b000
 0x8dbc: adrp   x5, #0x1a000
 0x8dc0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8dc4: add    x4, x4, #0xf7 ; "0"
 0x8dc8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8dcc: mov    w0, #0x51
 0x8dd0: mov    w6, #0x285
 0x8dd4: add    x2, sp, #0x1c8
 0x8dd8: mov    w1, wzr
 0x8ddc: bl     #0x2378 ; <duss_log_print>
 0x8de0: adrp   x4, #0x1a000
 0x8de4: adrp   x5, #0x1a000
 0x8de8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8dec: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8df0: mov    w0, #0x51
 0x8df4: mov    w6, #0x285
 0x8df8: b      #0xab20
 0x8dfc: bl     #0x2348 ; <co_thread_get>
 0x8e00: cbnz   x0, #0x9840
 0x8e04: adrp   x4, #0x1a000
 0x8e08: adrp   x5, #0x1b000
 0x8e0c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8e10: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x8e14: mov    w0, #0x51
 0x8e18: mov    w6, #0x1c3
 0x8e1c: add    x2, sp, #0x1c8
 0x8e20: mov    w3, #0x80
 0x8e24: mov    w1, wzr
 0x8e28: bl     #0x2368 ; <duss_log_gen_head>
 0x8e2c: cbz    w0, #0x98c8
 0x8e30: adrp   x3, #0x1a000
 0x8e34: adrp   x4, #0x1c000
 0x8e38: adrp   x5, #0x1a000
 0x8e3c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8e40: add    x4, x4, #6 ; "meta_cnt > 0 && meta_cnt * sizeof(uint16_t) <= ics_buf_size"
 0x8e44: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8e48: mov    w0, #0x51
 0x8e4c: mov    w6, #0x1c3
 0x8e50: add    x2, sp, #0x1c8
 0x8e54: mov    w1, wzr
 0x8e58: bl     #0x2378 ; <duss_log_print>
 0x8e5c: b      #0x98c8
 0x8e60: bl     #0x2348 ; <co_thread_get>
 0x8e64: cbnz   x0, #0x98e4
 0x8e68: adrp   x4, #0x1a000
 0x8e6c: adrp   x5, #0x1a000
 0x8e70: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8e74: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8e78: mov    w0, #0x51
 0x8e7c: mov    w6, #0x2c1
 0x8e80: add    x2, sp, #0x1c8
 0x8e84: mov    w3, #0x80
 0x8e88: mov    w1, wzr
 0x8e8c: bl     #0x2368 ; <duss_log_gen_head>
 0x8e90: cbz    w0, #0x996c
 0x8e94: adrp   x3, #0x1a000
 0x8e98: adrp   x4, #0x1b000
 0x8e9c: adrp   x5, #0x1a000
 0x8ea0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8ea4: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x8ea8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8eac: mov    w0, #0x51
 0x8eb0: mov    w6, #0x2c1
 0x8eb4: add    x2, sp, #0x1c8
 0x8eb8: mov    w1, wzr
 0x8ebc: bl     #0x2378 ; <duss_log_print>
 0x8ec0: b      #0x996c
 0x8ec4: bl     #0x2348 ; <co_thread_get>
 0x8ec8: cbnz   x0, #0x9988
 0x8ecc: adrp   x4, #0x1a000
 0x8ed0: adrp   x5, #0x1a000
 0x8ed4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8ed8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8edc: mov    w0, #0x51
 0x8ee0: mov    w6, #0x2c2
 0x8ee4: add    x2, sp, #0x1c8
 0x8ee8: mov    w3, #0x80
 0x8eec: mov    w1, wzr
 0x8ef0: bl     #0x2368 ; <duss_log_gen_head>
 0x8ef4: cbz    w0, #0x9a10
 0x8ef8: adrp   x3, #0x1a000
 0x8efc: adrp   x4, #0x1b000
 0x8f00: adrp   x5, #0x1a000
 0x8f04: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8f08: add    x4, x4, #0x47f ; "encoding_request"
 0x8f0c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8f10: mov    w0, #0x51
 0x8f14: mov    w6, #0x2c2
 0x8f18: add    x2, sp, #0x1c8
 0x8f1c: mov    w1, wzr
 0x8f20: bl     #0x2378 ; <duss_log_print>
 0x8f24: b      #0x9a10
 0x8f28: bl     #0x2348 ; <co_thread_get>
 0x8f2c: cbnz   x0, #0x9a2c
 0x8f30: adrp   x4, #0x1a000
 0x8f34: adrp   x5, #0x1a000
 0x8f38: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8f3c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8f40: mov    w0, #0x51
 0x8f44: mov    w6, #0x2c5
 0x8f48: add    x2, sp, #0x1c8
 0x8f4c: mov    w3, #0x80
 0x8f50: mov    w1, wzr
 0x8f54: bl     #0x2368 ; <duss_log_gen_head>
 0x8f58: cbz    w0, #0x9ab4
 0x8f5c: adrp   x3, #0x1a000
 0x8f60: adrp   x4, #0x1b000
 0x8f64: adrp   x5, #0x1a000
 0x8f68: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8f6c: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x8f70: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8f74: mov    w0, #0x51
 0x8f78: mov    w6, #0x2c5
 0x8f7c: add    x2, sp, #0x1c8
 0x8f80: mov    w1, wzr
 0x8f84: bl     #0x2378 ; <duss_log_print>
 0x8f88: b      #0x9ab4
 0x8f8c: bl     #0x2348 ; <co_thread_get>
 0x8f90: cbnz   x0, #0x9ad0
 0x8f94: adrp   x4, #0x1a000
 0x8f98: adrp   x5, #0x1a000
 0x8f9c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8fa0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x8fa4: mov    w0, #0x51
 0x8fa8: mov    w6, #0x2c6
 0x8fac: add    x2, sp, #0x1c8
 0x8fb0: mov    w3, #0x80
 0x8fb4: mov    w1, wzr
 0x8fb8: bl     #0x2368 ; <duss_log_gen_head>
 0x8fbc: cbz    w0, #0x9b58
 0x8fc0: adrp   x3, #0x1a000
 0x8fc4: adrp   x4, #0x1b000
 0x8fc8: adrp   x5, #0x1a000
 0x8fcc: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x8fd0: add    x4, x4, #0x490 ; "ics_buffer"
 0x8fd4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x8fd8: mov    w0, #0x51
 0x8fdc: mov    w6, #0x2c6
 0x8fe0: add    x2, sp, #0x1c8
 0x8fe4: mov    w1, wzr
 0x8fe8: bl     #0x2378 ; <duss_log_print>
 0x8fec: b      #0x9b58
 0x8ff0: bl     #0x2348 ; <co_thread_get>
 0x8ff4: cbnz   x0, #0x9b74
 0x8ff8: adrp   x4, #0x1a000
 0x8ffc: adrp   x5, #0x1b000
 0x9000: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9004: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9008: mov    w0, #0x51
 0x900c: mov    w6, #0x1a9
 0x9010: add    x2, sp, #0x1c8
 0x9014: mov    w3, #0x80
 0x9018: mov    w1, wzr
 0x901c: bl     #0x2368 ; <duss_log_gen_head>
 0x9020: cbz    w0, #0x9bfc
 0x9024: adrp   x3, #0x1a000
 0x9028: adrp   x4, #0x1b000
 0x902c: adrp   x5, #0x1a000
 0x9030: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9034: add    x4, x4, #0xe5f ; "metadata"
 0x9038: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x903c: mov    w0, #0x51
 0x9040: mov    w6, #0x1a9
 0x9044: add    x2, sp, #0x1c8
 0x9048: mov    w1, wzr
 0x904c: bl     #0x2378 ; <duss_log_print>
 0x9050: b      #0x9bfc
 0x9054: bl     #0x2348 ; <co_thread_get>
 0x9058: cbnz   x0, #0x9c18
 0x905c: adrp   x4, #0x1a000
 0x9060: adrp   x5, #0x1b000
 0x9064: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9068: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x906c: mov    w0, #0x51
 0x9070: mov    w6, #0x1ab
 0x9074: add    x2, sp, #0x1c8
 0x9078: mov    w3, #0x80
 0x907c: mov    w1, wzr
 0x9080: bl     #0x2368 ; <duss_log_gen_head>
 0x9084: cbz    w0, #0x9ca0
 0x9088: adrp   x3, #0x1a000
 0x908c: adrp   x4, #0x1b000
 0x9090: adrp   x5, #0x1a000
 0x9094: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9098: add    x4, x4, #0xe68 ; "ics_buffer->ics_buffer"
 0x909c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x90a0: mov    w0, #0x51
 0x90a4: mov    w6, #0x1ab
 0x90a8: add    x2, sp, #0x1c8
 0x90ac: mov    w1, wzr
 0x90b0: bl     #0x2378 ; <duss_log_print>
 0x90b4: b      #0x9ca0
 0x90b8: bl     #0x2348 ; <co_thread_get>
 0x90bc: cbnz   x0, #0x9cbc
 0x90c0: adrp   x4, #0x1a000
 0x90c4: adrp   x5, #0x1b000
 0x90c8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x90cc: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x90d0: mov    w0, #0x51
 0x90d4: mov    w6, #0x1ac
 0x90d8: add    x2, sp, #0x1c8
 0x90dc: mov    w3, #0x80
 0x90e0: mov    w1, wzr
 0x90e4: bl     #0x2368 ; <duss_log_gen_head>
 0x90e8: cbz    w0, #0x9d44
 0x90ec: adrp   x3, #0x1a000
 0x90f0: adrp   x4, #0x1b000
 0x90f4: adrp   x5, #0x1a000
 0x90f8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x90fc: add    x4, x4, #0xe7f ; "eng->ics_stat_count > 0"
 0x9100: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9104: mov    w0, #0x51
 0x9108: mov    w6, #0x1ac
 0x910c: add    x2, sp, #0x1c8
 0x9110: mov    w1, wzr
 0x9114: bl     #0x2378 ; <duss_log_print>
 0x9118: b      #0x9d44
 0x911c: bl     #0x2348 ; <co_thread_get>
 0x9120: cbnz   x0, #0x9d60
 0x9124: adrp   x4, #0x1a000
 0x9128: adrp   x5, #0x1b000
 0x912c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9130: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9134: mov    w0, #0x51
 0x9138: mov    w6, #0x1ad
 0x913c: add    x2, sp, #0x1c8
 0x9140: mov    w3, #0x80
 0x9144: mov    w1, wzr
 0x9148: bl     #0x2368 ; <duss_log_gen_head>
 0x914c: cbz    w0, #0x9de8
 0x9150: adrp   x3, #0x1a000
 0x9154: adrp   x4, #0x1b000
 0x9158: adrp   x5, #0x1a000
 0x915c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9160: add    x4, x4, #0xe97 ; "eng->ics_stat_buf_size > 0"
 0x9164: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9168: mov    w0, #0x51
 0x916c: mov    w6, #0x1ad
 0x9170: add    x2, sp, #0x1c8
 0x9174: mov    w1, wzr
 0x9178: bl     #0x2378 ; <duss_log_print>
 0x917c: b      #0x9de8
 0x9180: bl     #0x2348 ; <co_thread_get>
 0x9184: cbnz   x0, #0x9e04
 0x9188: adrp   x4, #0x1a000
 0x918c: adrp   x5, #0x1b000
 0x9190: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9194: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9198: mov    w0, #0x51
 0x919c: mov    w6, #0x1ae
 0x91a0: add    x2, sp, #0x1c8
 0x91a4: mov    w3, #0x80
 0x91a8: mov    w1, wzr
 0x91ac: bl     #0x2368 ; <duss_log_gen_head>
 0x91b0: cbz    w0, #0x9e8c
 0x91b4: adrp   x3, #0x1a000
 0x91b8: adrp   x4, #0x1b000
 0x91bc: adrp   x5, #0x1a000
 0x91c0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x91c4: add    x4, x4, #0xeb2 ; "eng->ics_stat_buf_size >= eng->ics_stat_count * 4"
 0x91c8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x91cc: mov    w0, #0x51
 0x91d0: mov    w6, #0x1ae
 0x91d4: add    x2, sp, #0x1c8
 0x91d8: mov    w1, wzr
 0x91dc: bl     #0x2378 ; <duss_log_print>
 0x91e0: b      #0x9e8c
 0x91e4: bl     #0x2348 ; <co_thread_get>
 0x91e8: cbnz   x0, #0x9ea8
 0x91ec: adrp   x4, #0x1a000
 0x91f0: adrp   x5, #0x1b000
 0x91f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x91f8: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x91fc: mov    w0, #0x51
 0x9200: mov    w6, #0x1b1
 0x9204: add    x2, sp, #0x1c8
 0x9208: mov    w3, #0x80
 0x920c: mov    w1, wzr
 0x9210: bl     #0x2368 ; <duss_log_gen_head>
 0x9214: cbz    w0, #0x9f30
 0x9218: adrp   x3, #0x1a000
 0x921c: adrp   x4, #0x1b000
 0x9220: adrp   x5, #0x1a000
 0x9224: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9228: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x922c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9230: mov    w0, #0x51
 0x9234: mov    w6, #0x1b1
 0x9238: add    x2, sp, #0x1c8
 0x923c: mov    w1, wzr
 0x9240: bl     #0x2378 ; <duss_log_print>
 0x9244: b      #0x9f30
 0x9248: bl     #0x2348 ; <co_thread_get>
 0x924c: cbnz   x0, #0x9f4c
 0x9250: adrp   x4, #0x1a000
 0x9254: adrp   x5, #0x1b000
 0x9258: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x925c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9260: mov    w0, #0x51
 0x9264: mov    w6, #0x1b2
 0x9268: add    x2, sp, #0x1c8
 0x926c: mov    w3, #0x80
 0x9270: mov    w1, wzr
 0x9274: bl     #0x2368 ; <duss_log_gen_head>
 0x9278: cbz    w0, #0x9fd4
 0x927c: adrp   x3, #0x1a000
 0x9280: adrp   x4, #0x1b000
 0x9284: adrp   x5, #0x1a000
 0x9288: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x928c: add    x4, x4, #0xee4 ; "ics_buf_addr"
 0x9290: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9294: mov    w0, #0x51
 0x9298: mov    w6, #0x1b2
 0x929c: add    x2, sp, #0x1c8
 0x92a0: mov    w1, wzr
 0x92a4: bl     #0x2378 ; <duss_log_print>
 0x92a8: b      #0x9fd4
 0x92ac: bl     #0x2348 ; <co_thread_get>
 0x92b0: cbnz   x0, #0x9ff0
 0x92b4: adrp   x4, #0x1a000
 0x92b8: adrp   x5, #0x1b000
 0x92bc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x92c0: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x92c4: mov    w0, #0x51
 0x92c8: mov    w6, #0x1b5
 0x92cc: add    x2, sp, #0x1c8
 0x92d0: mov    w3, #0x80
 0x92d4: mov    w1, wzr
 0x92d8: bl     #0x2368 ; <duss_log_gen_head>
 0x92dc: cbz    w0, #0xa078
 0x92e0: adrp   x3, #0x1a000
 0x92e4: adrp   x4, #0x1b000
 0x92e8: adrp   x5, #0x1a000
 0x92ec: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x92f0: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x92f4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x92f8: mov    w0, #0x51
 0x92fc: mov    w6, #0x1b5
 0x9300: add    x2, sp, #0x1c8
 0x9304: mov    w1, wzr
 0x9308: bl     #0x2378 ; <duss_log_print>
 0x930c: b      #0xa078
 0x9310: bl     #0x2348 ; <co_thread_get>
 0x9314: cbnz   x0, #0xa094
 0x9318: adrp   x4, #0x1a000
 0x931c: adrp   x5, #0x1b000
 0x9320: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9324: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9328: mov    w0, #0x51
 0x932c: mov    w6, #0x1b6
 0x9330: add    x2, sp, #0x1c8
 0x9334: mov    w3, #0x80
 0x9338: mov    w1, wzr
 0x933c: bl     #0x2368 ; <duss_log_gen_head>
 0x9340: cbz    w0, #0xa11c
 0x9344: adrp   x3, #0x1a000
 0x9348: adrp   x4, #0x1b000
 0x934c: adrp   x5, #0x1a000
 0x9350: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9354: add    x4, x4, #0xef1 ; "ics_buf_size >= eng->ics_stat_buf_size"
 0x9358: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x935c: mov    w0, #0x51
 0x9360: mov    w6, #0x1b6
 0x9364: add    x2, sp, #0x1c8
 0x9368: mov    w1, wzr
 0x936c: bl     #0x2378 ; <duss_log_print>
 0x9370: b      #0xa11c
 0x9374: bl     #0x2348 ; <co_thread_get>
 0x9378: cbnz   x0, #0xa138
 0x937c: adrp   x4, #0x1a000
 0x9380: adrp   x5, #0x1b000
 0x9384: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9388: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x938c: mov    w0, #0x51
 0x9390: mov    w6, #0x1c8
 0x9394: add    x2, sp, #0x1c8
 0x9398: mov    w3, #0x80
 0x939c: mov    w1, wzr
 0x93a0: bl     #0x2368 ; <duss_log_gen_head>
 0x93a4: cbz    w0, #0xa1c0
 0x93a8: adrp   x3, #0x1a000
 0x93ac: adrp   x4, #0x1b000
 0x93b0: adrp   x5, #0x1a000
 0x93b4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x93b8: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x93bc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x93c0: mov    w0, #0x51
 0x93c4: mov    w6, #0x1c8
 0x93c8: add    x2, sp, #0x1c8
 0x93cc: mov    w1, wzr
 0x93d0: bl     #0x2378 ; <duss_log_print>
 0x93d4: b      #0xa1c0
 0x93d8: bl     #0x2348 ; <co_thread_get>
 0x93dc: cbnz   x0, #0xa1dc
 0x93e0: adrp   x4, #0x1a000
 0x93e4: adrp   x5, #0x1a000
 0x93e8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x93ec: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x93f0: mov    w0, #0x51
 0x93f4: mov    w6, #0x2cc
 0x93f8: add    x2, sp, #0x1c8
 0x93fc: mov    w3, #0x80
 0x9400: mov    w1, wzr
 0x9404: bl     #0x2368 ; <duss_log_gen_head>
 0x9408: cbz    w0, #0xa264
 0x940c: adrp   x3, #0x1a000
 0x9410: adrp   x4, #0x1b000
 0x9414: adrp   x5, #0x1a000
 0x9418: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x941c: add    x4, x4, #0x49b ; "encoding_request->allocator == ((void*)0)"
 0x9420: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9424: mov    w0, #0x51
 0x9428: mov    w6, #0x2cc
 0x942c: add    x2, sp, #0x1c8
 0x9430: mov    w1, wzr
 0x9434: bl     #0x2378 ; <duss_log_print>
 0x9438: b      #0xa264
 0x943c: bl     #0x2348 ; <co_thread_get>
 0x9440: cbnz   x0, #0xa280
 0x9444: adrp   x4, #0x1a000
 0x9448: adrp   x5, #0x1a000
 0x944c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9450: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9454: mov    w0, #0x51
 0x9458: mov    w6, #0x2d4
 0x945c: add    x2, sp, #0x1c8
 0x9460: mov    w3, #0x80
 0x9464: mov    w1, wzr
 0x9468: bl     #0x2368 ; <duss_log_gen_head>
 0x946c: cbz    w0, #0xa308
 0x9470: adrp   x3, #0x1a000
 0x9474: adrp   x4, #0x1b000
 0x9478: adrp   x5, #0x1a000
 0x947c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9480: add    x4, x4, #0x54a ; "encoding_request->buffer_group == ((void*)0)"
 0x9484: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9488: mov    w0, #0x51
 0x948c: mov    w6, #0x2d4
 0x9490: add    x2, sp, #0x1c8
 0x9494: mov    w1, wzr
 0x9498: bl     #0x2378 ; <duss_log_print>
 0x949c: b      #0xa308
 0x94a0: bl     #0x2348 ; <co_thread_get>
 0x94a4: cbnz   x0, #0xa324
 0x94a8: adrp   x4, #0x1a000
 0x94ac: adrp   x5, #0x1a000
 0x94b0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x94b4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x94b8: mov    w0, #0x51
 0x94bc: mov    w6, #0x2d9
 0x94c0: add    x2, sp, #0x1c8
 0x94c4: mov    w3, #0x80
 0x94c8: mov    w1, wzr
 0x94cc: bl     #0x2368 ; <duss_log_gen_head>
 0x94d0: cbz    w0, #0xa3ac
 0x94d4: adrp   x3, #0x1a000
 0x94d8: adrp   x4, #0x1b000
 0x94dc: adrp   x5, #0x1a000
 0x94e0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x94e4: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x94e8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x94ec: mov    w0, #0x51
 0x94f0: mov    w6, #0x2d9
 0x94f4: add    x2, sp, #0x1c8
 0x94f8: mov    w1, wzr
 0x94fc: bl     #0x2378 ; <duss_log_print>
 0x9500: b      #0xa3ac
 0x9504: bl     #0x2348 ; <co_thread_get>
 0x9508: cbnz   x0, #0xa3c8
 0x950c: adrp   x4, #0x1a000
 0x9510: adrp   x5, #0x1a000
 0x9514: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9518: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x951c: mov    w0, #0x51
 0x9520: mov    w6, #0x2db
 0x9524: add    x2, sp, #0x1c8
 0x9528: mov    w3, #0x80
 0x952c: mov    w1, wzr
 0x9530: bl     #0x2368 ; <duss_log_gen_head>
 0x9534: cbz    w0, #0xa450
 0x9538: adrp   x3, #0x1a000
 0x953c: adrp   x4, #0x1b000
 0x9540: adrp   x5, #0x1a000
 0x9544: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9548: add    x4, x4, #0x577 ; "enc_param.p_frame_buffer == ((void*)0)"
 0x954c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9550: mov    w0, #0x51
 0x9554: mov    w6, #0x2db
 0x9558: add    x2, sp, #0x1c8
 0x955c: mov    w1, wzr
 0x9560: bl     #0x2378 ; <duss_log_print>
 0x9564: b      #0xa450
 0x9568: adrp   x8, #0x1a000
 0x956c: str    wzr, [sp, #0xc0]
 0x9570: add    x8, x8, #0x440 ; =0x1a440
 0x9574: add    x1, sp, #0xd0
 0x9578: add    x2, sp, #0xc0
 0x957c: str    x8, [sp, #0xd0]
 0x9580: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9584: adrp   x19, #0x1a000
 0x9588: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x958c: adrp   x5, #0x1a000
 0x9590: mov    w20, #0x2a8
 0x9594: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9598: mov    w0, #0x51
 0x959c: add    x2, sp, #0x1c8
 0x95a0: mov    w3, #0x80
 0x95a4: mov    w1, wzr
 0x95a8: mov    x4, x19
 0x95ac: mov    w6, w20
 0x95b0: bl     #0x2368 ; <duss_log_gen_head>
 0x95b4: cbz    w0, #0x95f0
 0x95b8: ldr    x5, [sp, #0xd0]
 0x95bc: adrp   x3, #0x1a000
 0x95c0: ldr    w6, [sp, #0xc0]
 0x95c4: adrp   x4, #0x1a000
 0x95c8: adrp   x7, #0x1b000
 0x95cc: str    w20, [sp, #8]
 0x95d0: mov    w1, wzr
 0x95d4: str    x19, [sp]
 0x95d8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x95dc: add    x4, x4, #0x441 ; "co"
 0x95e0: mov    w0, #0x51
 0x95e4: add    x7, x7, #0x1e9 ; "buffer_group == ((void*)0)"
 0x95e8: add    x2, sp, #0x1c8
 0x95ec: bl     #0x2378 ; <duss_log_print>
 0x95f0: adrp   x4, #0x1a000
 0x95f4: adrp   x5, #0x1a000
 0x95f8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x95fc: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9600: mov    w0, #0x51
 0x9604: mov    w6, #0x2a8
 0x9608: b      #0xab20
 0x960c: adrp   x8, #0x1a000
 0x9610: str    wzr, [sp, #0xc0]
 0x9614: add    x8, x8, #0x440 ; =0x1a440
 0x9618: add    x1, sp, #0xd0
 0x961c: add    x2, sp, #0xc0
 0x9620: str    x8, [sp, #0xd0]
 0x9624: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9628: adrp   x19, #0x1a000
 0x962c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9630: adrp   x5, #0x1a000
 0x9634: mov    w20, #0x2a9
 0x9638: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x963c: mov    w0, #0x51
 0x9640: add    x2, sp, #0x1c8
 0x9644: mov    w3, #0x80
 0x9648: mov    w1, wzr
 0x964c: mov    x4, x19
 0x9650: mov    w6, w20
 0x9654: bl     #0x2368 ; <duss_log_gen_head>
 0x9658: cbz    w0, #0x9694
 0x965c: ldr    x5, [sp, #0xd0]
 0x9660: adrp   x3, #0x1a000
 0x9664: ldr    w6, [sp, #0xc0]
 0x9668: adrp   x4, #0x1a000
 0x966c: adrp   x7, #0x1b000
 0x9670: str    w20, [sp, #8]
 0x9674: mov    w1, wzr
 0x9678: str    x19, [sp]
 0x967c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9680: add    x4, x4, #0x441 ; "co"
 0x9684: mov    w0, #0x51
 0x9688: add    x7, x7, #0x204 ; "allocator == ((void*)0)"
 0x968c: add    x2, sp, #0x1c8
 0x9690: bl     #0x2378 ; <duss_log_print>
 0x9694: adrp   x4, #0x1a000
 0x9698: adrp   x5, #0x1a000
 0x969c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x96a0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x96a4: mov    w0, #0x51
 0x96a8: mov    w6, #0x2a9
 0x96ac: b      #0xab20
 0x96b0: bl     #0x2348 ; <co_thread_get>
 0x96b4: cbnz   x0, #0xa534
 0x96b8: adrp   x4, #0x1a000
 0x96bc: adrp   x5, #0x1b000
 0x96c0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x96c4: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x96c8: mov    w0, #0x51
 0x96cc: add    x2, sp, #0x1c8
 0x96d0: mov    w3, #0x80
 0x96d4: mov    w6, #0x1c0
 0x96d8: mov    w1, wzr
 0x96dc: bl     #0x2368 ; <duss_log_gen_head>
 0x96e0: cbz    w0, #0xa5bc
 0x96e4: adrp   x3, #0x1a000
 0x96e8: adrp   x4, #0x1b000
 0x96ec: adrp   x5, #0x1a000
 0x96f0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x96f4: add    x4, x4, #0xfdb ; "DCAM_VAL_TYPE_UINT16 == val->val_type"
 0x96f8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x96fc: mov    w0, #0x51
 0x9700: add    x2, sp, #0x1c8
 0x9704: mov    w6, #0x1c0
 0x9708: mov    w1, wzr
 0x970c: bl     #0x2378 ; <duss_log_print>
 0x9710: b      #0xa5bc
 0x9714: bl     #0x2348 ; <co_thread_get>
 0x9718: cbnz   x0, #0xa5e0
 0x971c: adrp   x4, #0x1a000
 0x9720: adrp   x5, #0x1b000
 0x9724: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9728: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x972c: mov    w0, #0x51
 0x9730: mov    w6, #0x1c2
 0x9734: add    x2, sp, #0x1c8
 0x9738: mov    w3, #0x80
 0x973c: mov    w1, wzr
 0x9740: bl     #0x2368 ; <duss_log_gen_head>
 0x9744: cbz    w0, #0xa668
 0x9748: adrp   x3, #0x1a000
 0x974c: adrp   x4, #0x1c000
 0x9750: adrp   x5, #0x1a000
 0x9754: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9758: add    x4, x4, #1 ; "data"
 0x975c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9760: mov    w0, #0x51
 0x9764: mov    w6, #0x1c2
 0x9768: add    x2, sp, #0x1c8
 0x976c: mov    w1, wzr
 0x9770: bl     #0x2378 ; <duss_log_print>
 0x9774: b      #0xa668
 0x9778: bl     #0x2348 ; <co_thread_get>
 0x977c: cbnz   x0, #0xa684
 0x9780: adrp   x4, #0x1a000
 0x9784: adrp   x5, #0x1a000
 0x9788: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x978c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9790: mov    w0, #0x51
 0x9794: mov    w6, #0x2f1
 0x9798: add    x2, sp, #0x1c8
 0x979c: mov    w3, #0x80
 0x97a0: mov    w1, wzr
 0x97a4: bl     #0x2368 ; <duss_log_gen_head>
 0x97a8: cbz    w0, #0xa70c
 0x97ac: adrp   x3, #0x1a000
 0x97b0: adrp   x4, #0x1b000
 0x97b4: adrp   x5, #0x1a000
 0x97b8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x97bc: add    x4, x4, #0x75e ; "sbuf->plane_count == 1"
 0x97c0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x97c4: mov    w0, #0x51
 0x97c8: mov    w6, #0x2f1
 0x97cc: add    x2, sp, #0x1c8
 0x97d0: mov    w1, wzr
 0x97d4: bl     #0x2378 ; <duss_log_print>
 0x97d8: b      #0xa70c
 0x97dc: bl     #0x2348 ; <co_thread_get>
 0x97e0: cbnz   x0, #0xa728
 0x97e4: adrp   x4, #0x1a000
 0x97e8: adrp   x5, #0x1a000
 0x97ec: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x97f0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x97f4: mov    w0, #0x51
 0x97f8: mov    w6, #0x2f2
 0x97fc: add    x2, sp, #0x1c8
 0x9800: mov    w3, #0x80
 0x9804: mov    w1, wzr
 0x9808: bl     #0x2368 ; <duss_log_gen_head>
 0x980c: cbz    w0, #0xa7b0
 0x9810: adrp   x3, #0x1a000
 0x9814: adrp   x4, #0x1b000
 0x9818: adrp   x5, #0x1a000
 0x981c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0x9820: add    x4, x4, #0x775 ; "sbuf->obj.ref_count == 1"
 0x9824: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9828: mov    w0, #0x51
 0x982c: mov    w6, #0x2f2
 0x9830: add    x2, sp, #0x1c8
 0x9834: mov    w1, wzr
 0x9838: bl     #0x2378 ; <duss_log_print>
 0x983c: b      #0xa7b0
 0x9840: adrp   x8, #0x1a000
 0x9844: str    wzr, [sp, #0xbc]
 0x9848: add    x8, x8, #0x440 ; =0x1a440
 0x984c: add    x1, sp, #0xc0
 0x9850: add    x2, sp, #0xbc
 0x9854: str    x8, [sp, #0xc0]
 0x9858: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x985c: adrp   x19, #0x1a000
 0x9860: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9864: adrp   x5, #0x1b000
 0x9868: mov    w20, #0x1c3
 0x986c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9870: mov    w0, #0x51
 0x9874: add    x2, sp, #0x1c8
 0x9878: mov    w3, #0x80
 0x987c: mov    w1, wzr
 0x9880: mov    x4, x19
 0x9884: mov    w6, w20
 0x9888: bl     #0x2368 ; <duss_log_gen_head>
 0x988c: cbz    w0, #0x98c8
 0x9890: ldr    x5, [sp, #0xc0]
 0x9894: adrp   x3, #0x1a000
 0x9898: ldr    w6, [sp, #0xbc]
 0x989c: adrp   x4, #0x1a000
 0x98a0: adrp   x7, #0x1c000
 0x98a4: str    w20, [sp, #8]
 0x98a8: mov    w1, wzr
 0x98ac: str    x19, [sp]
 0x98b0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x98b4: add    x4, x4, #0x441 ; "co"
 0x98b8: mov    w0, #0x51
 0x98bc: add    x7, x7, #6 ; "meta_cnt > 0 && meta_cnt * sizeof(uint16_t) <= ics_buf_size"
 0x98c0: add    x2, sp, #0x1c8
 0x98c4: bl     #0x2378 ; <duss_log_print>
 0x98c8: adrp   x4, #0x1a000
 0x98cc: adrp   x5, #0x1b000
 0x98d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x98d4: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x98d8: mov    w0, #0x51
 0x98dc: mov    w6, #0x1c3
 0x98e0: b      #0xab20
 0x98e4: adrp   x8, #0x1a000
 0x98e8: str    wzr, [sp, #0xc0]
 0x98ec: add    x8, x8, #0x440 ; =0x1a440
 0x98f0: add    x1, sp, #0xd0
 0x98f4: add    x2, sp, #0xc0
 0x98f8: str    x8, [sp, #0xd0]
 0x98fc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9900: adrp   x19, #0x1a000
 0x9904: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9908: adrp   x5, #0x1a000
 0x990c: mov    w20, #0x2c1
 0x9910: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9914: mov    w0, #0x51
 0x9918: add    x2, sp, #0x1c8
 0x991c: mov    w3, #0x80
 0x9920: mov    w1, wzr
 0x9924: mov    x4, x19
 0x9928: mov    w6, w20
 0x992c: bl     #0x2368 ; <duss_log_gen_head>
 0x9930: cbz    w0, #0x996c
 0x9934: ldr    x5, [sp, #0xd0]
 0x9938: adrp   x3, #0x1a000
 0x993c: ldr    w6, [sp, #0xc0]
 0x9940: adrp   x4, #0x1a000
 0x9944: adrp   x7, #0x1b000
 0x9948: str    w20, [sp, #8]
 0x994c: mov    w1, wzr
 0x9950: str    x19, [sp]
 0x9954: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9958: add    x4, x4, #0x441 ; "co"
 0x995c: mov    w0, #0x51
 0x9960: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x9964: add    x2, sp, #0x1c8
 0x9968: bl     #0x2378 ; <duss_log_print>
 0x996c: adrp   x4, #0x1a000
 0x9970: adrp   x5, #0x1a000
 0x9974: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9978: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x997c: mov    w0, #0x51
 0x9980: mov    w6, #0x2c1
 0x9984: b      #0xab20
 0x9988: adrp   x8, #0x1a000
 0x998c: str    wzr, [sp, #0xc0]
 0x9990: add    x8, x8, #0x440 ; =0x1a440
 0x9994: add    x1, sp, #0xd0
 0x9998: add    x2, sp, #0xc0
 0x999c: str    x8, [sp, #0xd0]
 0x99a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x99a4: adrp   x19, #0x1a000
 0x99a8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x99ac: adrp   x5, #0x1a000
 0x99b0: mov    w20, #0x2c2
 0x99b4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x99b8: mov    w0, #0x51
 0x99bc: add    x2, sp, #0x1c8
 0x99c0: mov    w3, #0x80
 0x99c4: mov    w1, wzr
 0x99c8: mov    x4, x19
 0x99cc: mov    w6, w20
 0x99d0: bl     #0x2368 ; <duss_log_gen_head>
 0x99d4: cbz    w0, #0x9a10
 0x99d8: ldr    x5, [sp, #0xd0]
 0x99dc: adrp   x3, #0x1a000
 0x99e0: ldr    w6, [sp, #0xc0]
 0x99e4: adrp   x4, #0x1a000
 0x99e8: adrp   x7, #0x1b000
 0x99ec: str    w20, [sp, #8]
 0x99f0: mov    w1, wzr
 0x99f4: str    x19, [sp]
 0x99f8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x99fc: add    x4, x4, #0x441 ; "co"
 0x9a00: mov    w0, #0x51
 0x9a04: add    x7, x7, #0x47f ; "encoding_request"
 0x9a08: add    x2, sp, #0x1c8
 0x9a0c: bl     #0x2378 ; <duss_log_print>
 0x9a10: adrp   x4, #0x1a000
 0x9a14: adrp   x5, #0x1a000
 0x9a18: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9a1c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9a20: mov    w0, #0x51
 0x9a24: mov    w6, #0x2c2
 0x9a28: b      #0xab20
 0x9a2c: adrp   x8, #0x1a000
 0x9a30: str    wzr, [sp, #0xc0]
 0x9a34: add    x8, x8, #0x440 ; =0x1a440
 0x9a38: add    x1, sp, #0xd0
 0x9a3c: add    x2, sp, #0xc0
 0x9a40: str    x8, [sp, #0xd0]
 0x9a44: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9a48: adrp   x19, #0x1a000
 0x9a4c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9a50: adrp   x5, #0x1a000
 0x9a54: mov    w20, #0x2c5
 0x9a58: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9a5c: mov    w0, #0x51
 0x9a60: add    x2, sp, #0x1c8
 0x9a64: mov    w3, #0x80
 0x9a68: mov    w1, wzr
 0x9a6c: mov    x4, x19
 0x9a70: mov    w6, w20
 0x9a74: bl     #0x2368 ; <duss_log_gen_head>
 0x9a78: cbz    w0, #0x9ab4
 0x9a7c: ldr    x5, [sp, #0xd0]
 0x9a80: adrp   x3, #0x1a000
 0x9a84: ldr    w6, [sp, #0xc0]
 0x9a88: adrp   x4, #0x1a000
 0x9a8c: adrp   x7, #0x1b000
 0x9a90: str    w20, [sp, #8]
 0x9a94: mov    w1, wzr
 0x9a98: str    x19, [sp]
 0x9a9c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9aa0: add    x4, x4, #0x441 ; "co"
 0x9aa4: mov    w0, #0x51
 0x9aa8: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x9aac: add    x2, sp, #0x1c8
 0x9ab0: bl     #0x2378 ; <duss_log_print>
 0x9ab4: adrp   x4, #0x1a000
 0x9ab8: adrp   x5, #0x1a000
 0x9abc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9ac0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9ac4: mov    w0, #0x51
 0x9ac8: mov    w6, #0x2c5
 0x9acc: b      #0xab20
 0x9ad0: adrp   x8, #0x1a000
 0x9ad4: str    wzr, [sp, #0xc0]
 0x9ad8: add    x8, x8, #0x440 ; =0x1a440
 0x9adc: add    x1, sp, #0xd0
 0x9ae0: add    x2, sp, #0xc0
 0x9ae4: str    x8, [sp, #0xd0]
 0x9ae8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9aec: adrp   x19, #0x1a000
 0x9af0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9af4: adrp   x5, #0x1a000
 0x9af8: mov    w20, #0x2c6
 0x9afc: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9b00: mov    w0, #0x51
 0x9b04: add    x2, sp, #0x1c8
 0x9b08: mov    w3, #0x80
 0x9b0c: mov    w1, wzr
 0x9b10: mov    x4, x19
 0x9b14: mov    w6, w20
 0x9b18: bl     #0x2368 ; <duss_log_gen_head>
 0x9b1c: cbz    w0, #0x9b58
 0x9b20: ldr    x5, [sp, #0xd0]
 0x9b24: adrp   x3, #0x1a000
 0x9b28: ldr    w6, [sp, #0xc0]
 0x9b2c: adrp   x4, #0x1a000
 0x9b30: adrp   x7, #0x1b000
 0x9b34: str    w20, [sp, #8]
 0x9b38: mov    w1, wzr
 0x9b3c: str    x19, [sp]
 0x9b40: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9b44: add    x4, x4, #0x441 ; "co"
 0x9b48: mov    w0, #0x51
 0x9b4c: add    x7, x7, #0x490 ; "ics_buffer"
 0x9b50: add    x2, sp, #0x1c8
 0x9b54: bl     #0x2378 ; <duss_log_print>
 0x9b58: adrp   x4, #0x1a000
 0x9b5c: adrp   x5, #0x1a000
 0x9b60: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9b64: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0x9b68: mov    w0, #0x51
 0x9b6c: mov    w6, #0x2c6
 0x9b70: b      #0xab20
 0x9b74: adrp   x8, #0x1a000
 0x9b78: str    wzr, [sp, #0xdc]
 0x9b7c: add    x8, x8, #0x440 ; =0x1a440
 0x9b80: add    x1, sp, #0xc0
 0x9b84: add    x2, sp, #0xdc
 0x9b88: str    x8, [sp, #0xc0]
 0x9b8c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9b90: adrp   x19, #0x1a000
 0x9b94: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9b98: adrp   x5, #0x1b000
 0x9b9c: mov    w20, #0x1a9
 0x9ba0: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9ba4: mov    w0, #0x51
 0x9ba8: add    x2, sp, #0x1c8
 0x9bac: mov    w3, #0x80
 0x9bb0: mov    w1, wzr
 0x9bb4: mov    x4, x19
 0x9bb8: mov    w6, w20
 0x9bbc: bl     #0x2368 ; <duss_log_gen_head>
 0x9bc0: cbz    w0, #0x9bfc
 0x9bc4: ldr    x5, [sp, #0xc0]
 0x9bc8: adrp   x3, #0x1a000
 0x9bcc: ldr    w6, [sp, #0xdc]
 0x9bd0: adrp   x4, #0x1a000
 0x9bd4: adrp   x7, #0x1b000
 0x9bd8: str    w20, [sp, #8]
 0x9bdc: mov    w1, wzr
 0x9be0: str    x19, [sp]
 0x9be4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9be8: add    x4, x4, #0x441 ; "co"
 0x9bec: mov    w0, #0x51
 0x9bf0: add    x7, x7, #0xe5f ; "metadata"
 0x9bf4: add    x2, sp, #0x1c8
 0x9bf8: bl     #0x2378 ; <duss_log_print>
 0x9bfc: adrp   x4, #0x1a000
 0x9c00: adrp   x5, #0x1b000
 0x9c04: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9c08: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9c0c: mov    w0, #0x51
 0x9c10: mov    w6, #0x1a9
 0x9c14: b      #0xab20
 0x9c18: adrp   x8, #0x1a000
 0x9c1c: str    wzr, [sp, #0xdc]
 0x9c20: add    x8, x8, #0x440 ; =0x1a440
 0x9c24: add    x1, sp, #0xc0
 0x9c28: add    x2, sp, #0xdc
 0x9c2c: str    x8, [sp, #0xc0]
 0x9c30: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9c34: adrp   x19, #0x1a000
 0x9c38: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9c3c: adrp   x5, #0x1b000
 0x9c40: mov    w20, #0x1ab
 0x9c44: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9c48: mov    w0, #0x51
 0x9c4c: add    x2, sp, #0x1c8
 0x9c50: mov    w3, #0x80
 0x9c54: mov    w1, wzr
 0x9c58: mov    x4, x19
 0x9c5c: mov    w6, w20
 0x9c60: bl     #0x2368 ; <duss_log_gen_head>
 0x9c64: cbz    w0, #0x9ca0
 0x9c68: ldr    x5, [sp, #0xc0]
 0x9c6c: adrp   x3, #0x1a000
 0x9c70: ldr    w6, [sp, #0xdc]
 0x9c74: adrp   x4, #0x1a000
 0x9c78: adrp   x7, #0x1b000
 0x9c7c: str    w20, [sp, #8]
 0x9c80: mov    w1, wzr
 0x9c84: str    x19, [sp]
 0x9c88: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9c8c: add    x4, x4, #0x441 ; "co"
 0x9c90: mov    w0, #0x51
 0x9c94: add    x7, x7, #0xe68 ; "ics_buffer->ics_buffer"
 0x9c98: add    x2, sp, #0x1c8
 0x9c9c: bl     #0x2378 ; <duss_log_print>
 0x9ca0: adrp   x4, #0x1a000
 0x9ca4: adrp   x5, #0x1b000
 0x9ca8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9cac: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9cb0: mov    w0, #0x51
 0x9cb4: mov    w6, #0x1ab
 0x9cb8: b      #0xab20
 0x9cbc: adrp   x8, #0x1a000
 0x9cc0: str    wzr, [sp, #0xdc]
 0x9cc4: add    x8, x8, #0x440 ; =0x1a440
 0x9cc8: add    x1, sp, #0xc0
 0x9ccc: add    x2, sp, #0xdc
 0x9cd0: str    x8, [sp, #0xc0]
 0x9cd4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9cd8: adrp   x19, #0x1a000
 0x9cdc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9ce0: adrp   x5, #0x1b000
 0x9ce4: mov    w20, #0x1ac
 0x9ce8: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9cec: mov    w0, #0x51
 0x9cf0: add    x2, sp, #0x1c8
 0x9cf4: mov    w3, #0x80
 0x9cf8: mov    w1, wzr
 0x9cfc: mov    x4, x19
 0x9d00: mov    w6, w20
 0x9d04: bl     #0x2368 ; <duss_log_gen_head>
 0x9d08: cbz    w0, #0x9d44
 0x9d0c: ldr    x5, [sp, #0xc0]
 0x9d10: adrp   x3, #0x1a000
 0x9d14: ldr    w6, [sp, #0xdc]
 0x9d18: adrp   x4, #0x1a000
 0x9d1c: adrp   x7, #0x1b000
 0x9d20: str    w20, [sp, #8]
 0x9d24: mov    w1, wzr
 0x9d28: str    x19, [sp]
 0x9d2c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9d30: add    x4, x4, #0x441 ; "co"
 0x9d34: mov    w0, #0x51
 0x9d38: add    x7, x7, #0xe7f ; "eng->ics_stat_count > 0"
 0x9d3c: add    x2, sp, #0x1c8
 0x9d40: bl     #0x2378 ; <duss_log_print>
 0x9d44: adrp   x4, #0x1a000
 0x9d48: adrp   x5, #0x1b000
 0x9d4c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9d50: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9d54: mov    w0, #0x51
 0x9d58: mov    w6, #0x1ac
 0x9d5c: b      #0xab20
 0x9d60: adrp   x8, #0x1a000
 0x9d64: str    wzr, [sp, #0xdc]
 0x9d68: add    x8, x8, #0x440 ; =0x1a440
 0x9d6c: add    x1, sp, #0xc0
 0x9d70: add    x2, sp, #0xdc
 0x9d74: str    x8, [sp, #0xc0]
 0x9d78: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9d7c: adrp   x19, #0x1a000
 0x9d80: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9d84: adrp   x5, #0x1b000
 0x9d88: mov    w20, #0x1ad
 0x9d8c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9d90: mov    w0, #0x51
 0x9d94: add    x2, sp, #0x1c8
 0x9d98: mov    w3, #0x80
 0x9d9c: mov    w1, wzr
 0x9da0: mov    x4, x19
 0x9da4: mov    w6, w20
 0x9da8: bl     #0x2368 ; <duss_log_gen_head>
 0x9dac: cbz    w0, #0x9de8
 0x9db0: ldr    x5, [sp, #0xc0]
 0x9db4: adrp   x3, #0x1a000
 0x9db8: ldr    w6, [sp, #0xdc]
 0x9dbc: adrp   x4, #0x1a000
 0x9dc0: adrp   x7, #0x1b000
 0x9dc4: str    w20, [sp, #8]
 0x9dc8: mov    w1, wzr
 0x9dcc: str    x19, [sp]
 0x9dd0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9dd4: add    x4, x4, #0x441 ; "co"
 0x9dd8: mov    w0, #0x51
 0x9ddc: add    x7, x7, #0xe97 ; "eng->ics_stat_buf_size > 0"
 0x9de0: add    x2, sp, #0x1c8
 0x9de4: bl     #0x2378 ; <duss_log_print>
 0x9de8: adrp   x4, #0x1a000
 0x9dec: adrp   x5, #0x1b000
 0x9df0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9df4: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9df8: mov    w0, #0x51
 0x9dfc: mov    w6, #0x1ad
 0x9e00: b      #0xab20
 0x9e04: adrp   x8, #0x1a000
 0x9e08: str    wzr, [sp, #0xdc]
 0x9e0c: add    x8, x8, #0x440 ; =0x1a440
 0x9e10: add    x1, sp, #0xc0
 0x9e14: add    x2, sp, #0xdc
 0x9e18: str    x8, [sp, #0xc0]
 0x9e1c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9e20: adrp   x19, #0x1a000
 0x9e24: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9e28: adrp   x5, #0x1b000
 0x9e2c: mov    w20, #0x1ae
 0x9e30: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9e34: mov    w0, #0x51
 0x9e38: add    x2, sp, #0x1c8
 0x9e3c: mov    w3, #0x80
 0x9e40: mov    w1, wzr
 0x9e44: mov    x4, x19
 0x9e48: mov    w6, w20
 0x9e4c: bl     #0x2368 ; <duss_log_gen_head>
 0x9e50: cbz    w0, #0x9e8c
 0x9e54: ldr    x5, [sp, #0xc0]
 0x9e58: adrp   x3, #0x1a000
 0x9e5c: ldr    w6, [sp, #0xdc]
 0x9e60: adrp   x4, #0x1a000
 0x9e64: adrp   x7, #0x1b000
 0x9e68: str    w20, [sp, #8]
 0x9e6c: mov    w1, wzr
 0x9e70: str    x19, [sp]
 0x9e74: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9e78: add    x4, x4, #0x441 ; "co"
 0x9e7c: mov    w0, #0x51
 0x9e80: add    x7, x7, #0xeb2 ; "eng->ics_stat_buf_size >= eng->ics_stat_count * 4"
 0x9e84: add    x2, sp, #0x1c8
 0x9e88: bl     #0x2378 ; <duss_log_print>
 0x9e8c: adrp   x4, #0x1a000
 0x9e90: adrp   x5, #0x1b000
 0x9e94: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9e98: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9e9c: mov    w0, #0x51
 0x9ea0: mov    w6, #0x1ae
 0x9ea4: b      #0xab20
 0x9ea8: adrp   x8, #0x1a000
 0x9eac: str    wzr, [sp, #0xdc]
 0x9eb0: add    x8, x8, #0x440 ; =0x1a440
 0x9eb4: add    x1, sp, #0xc0
 0x9eb8: add    x2, sp, #0xdc
 0x9ebc: str    x8, [sp, #0xc0]
 0x9ec0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9ec4: adrp   x19, #0x1a000
 0x9ec8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9ecc: adrp   x5, #0x1b000
 0x9ed0: mov    w20, #0x1b1
 0x9ed4: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9ed8: mov    w0, #0x51
 0x9edc: add    x2, sp, #0x1c8
 0x9ee0: mov    w3, #0x80
 0x9ee4: mov    w1, wzr
 0x9ee8: mov    x4, x19
 0x9eec: mov    w6, w20
 0x9ef0: bl     #0x2368 ; <duss_log_gen_head>
 0x9ef4: cbz    w0, #0x9f30
 0x9ef8: ldr    x5, [sp, #0xc0]
 0x9efc: adrp   x3, #0x1a000
 0x9f00: ldr    w6, [sp, #0xdc]
 0x9f04: adrp   x4, #0x1a000
 0x9f08: adrp   x7, #0x1b000
 0x9f0c: str    w20, [sp, #8]
 0x9f10: mov    w1, wzr
 0x9f14: str    x19, [sp]
 0x9f18: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9f1c: add    x4, x4, #0x441 ; "co"
 0x9f20: mov    w0, #0x51
 0x9f24: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0x9f28: add    x2, sp, #0x1c8
 0x9f2c: bl     #0x2378 ; <duss_log_print>
 0x9f30: adrp   x4, #0x1a000
 0x9f34: adrp   x5, #0x1b000
 0x9f38: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9f3c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9f40: mov    w0, #0x51
 0x9f44: mov    w6, #0x1b1
 0x9f48: b      #0xab20
 0x9f4c: adrp   x8, #0x1a000
 0x9f50: str    wzr, [sp, #0xdc]
 0x9f54: add    x8, x8, #0x440 ; =0x1a440
 0x9f58: add    x1, sp, #0xc0
 0x9f5c: add    x2, sp, #0xdc
 0x9f60: str    x8, [sp, #0xc0]
 0x9f64: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0x9f68: adrp   x19, #0x1a000
 0x9f6c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9f70: adrp   x5, #0x1b000
 0x9f74: mov    w20, #0x1b2
 0x9f78: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9f7c: mov    w0, #0x51
 0x9f80: add    x2, sp, #0x1c8
 0x9f84: mov    w3, #0x80
 0x9f88: mov    w1, wzr
 0x9f8c: mov    x4, x19
 0x9f90: mov    w6, w20
 0x9f94: bl     #0x2368 ; <duss_log_gen_head>
 0x9f98: cbz    w0, #0x9fd4
 0x9f9c: ldr    x5, [sp, #0xc0]
 0x9fa0: adrp   x3, #0x1a000
 0x9fa4: ldr    w6, [sp, #0xdc]
 0x9fa8: adrp   x4, #0x1a000
 0x9fac: adrp   x7, #0x1b000
 0x9fb0: str    w20, [sp, #8]
 0x9fb4: mov    w1, wzr
 0x9fb8: str    x19, [sp]
 0x9fbc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0x9fc0: add    x4, x4, #0x441 ; "co"
 0x9fc4: mov    w0, #0x51
 0x9fc8: add    x7, x7, #0xee4 ; "ics_buf_addr"
 0x9fcc: add    x2, sp, #0x1c8
 0x9fd0: bl     #0x2378 ; <duss_log_print>
 0x9fd4: adrp   x4, #0x1a000
 0x9fd8: adrp   x5, #0x1b000
 0x9fdc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0x9fe0: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0x9fe4: mov    w0, #0x51
 0x9fe8: mov    w6, #0x1b2
 0x9fec: b      #0xab20
 0x9ff0: adrp   x8, #0x1a000
 0x9ff4: str    wzr, [sp, #0xdc]
 0x9ff8: add    x8, x8, #0x440 ; =0x1a440
 0x9ffc: add    x1, sp, #0xc0
 0xa000: add    x2, sp, #0xdc
 0xa004: str    x8, [sp, #0xc0]
 0xa008: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa00c: adrp   x19, #0x1a000
 0xa010: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa014: adrp   x5, #0x1b000
 0xa018: mov    w20, #0x1b5
 0xa01c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa020: mov    w0, #0x51
 0xa024: add    x2, sp, #0x1c8
 0xa028: mov    w3, #0x80
 0xa02c: mov    w1, wzr
 0xa030: mov    x4, x19
 0xa034: mov    w6, w20
 0xa038: bl     #0x2368 ; <duss_log_gen_head>
 0xa03c: cbz    w0, #0xa078
 0xa040: ldr    x5, [sp, #0xc0]
 0xa044: adrp   x3, #0x1a000
 0xa048: ldr    w6, [sp, #0xdc]
 0xa04c: adrp   x4, #0x1a000
 0xa050: adrp   x7, #0x1b000
 0xa054: str    w20, [sp, #8]
 0xa058: mov    w1, wzr
 0xa05c: str    x19, [sp]
 0xa060: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa064: add    x4, x4, #0x441 ; "co"
 0xa068: mov    w0, #0x51
 0xa06c: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xa070: add    x2, sp, #0x1c8
 0xa074: bl     #0x2378 ; <duss_log_print>
 0xa078: adrp   x4, #0x1a000
 0xa07c: adrp   x5, #0x1b000
 0xa080: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa084: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa088: mov    w0, #0x51
 0xa08c: mov    w6, #0x1b5
 0xa090: b      #0xab20
 0xa094: adrp   x8, #0x1a000
 0xa098: str    wzr, [sp, #0xdc]
 0xa09c: add    x8, x8, #0x440 ; =0x1a440
 0xa0a0: add    x1, sp, #0xc0
 0xa0a4: add    x2, sp, #0xdc
 0xa0a8: str    x8, [sp, #0xc0]
 0xa0ac: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa0b0: adrp   x19, #0x1a000
 0xa0b4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa0b8: adrp   x5, #0x1b000
 0xa0bc: mov    w20, #0x1b6
 0xa0c0: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa0c4: mov    w0, #0x51
 0xa0c8: add    x2, sp, #0x1c8
 0xa0cc: mov    w3, #0x80
 0xa0d0: mov    w1, wzr
 0xa0d4: mov    x4, x19
 0xa0d8: mov    w6, w20
 0xa0dc: bl     #0x2368 ; <duss_log_gen_head>
 0xa0e0: cbz    w0, #0xa11c
 0xa0e4: ldr    x5, [sp, #0xc0]
 0xa0e8: adrp   x3, #0x1a000
 0xa0ec: ldr    w6, [sp, #0xdc]
 0xa0f0: adrp   x4, #0x1a000
 0xa0f4: adrp   x7, #0x1b000
 0xa0f8: str    w20, [sp, #8]
 0xa0fc: mov    w1, wzr
 0xa100: str    x19, [sp]
 0xa104: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa108: add    x4, x4, #0x441 ; "co"
 0xa10c: mov    w0, #0x51
 0xa110: add    x7, x7, #0xef1 ; "ics_buf_size >= eng->ics_stat_buf_size"
 0xa114: add    x2, sp, #0x1c8
 0xa118: bl     #0x2378 ; <duss_log_print>
 0xa11c: adrp   x4, #0x1a000
 0xa120: adrp   x5, #0x1b000
 0xa124: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa128: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa12c: mov    w0, #0x51
 0xa130: mov    w6, #0x1b6
 0xa134: b      #0xab20
 0xa138: adrp   x8, #0x1a000
 0xa13c: str    wzr, [sp, #0xbc]
 0xa140: add    x8, x8, #0x440 ; =0x1a440
 0xa144: add    x1, sp, #0xc0
 0xa148: add    x2, sp, #0xbc
 0xa14c: str    x8, [sp, #0xc0]
 0xa150: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa154: adrp   x19, #0x1a000
 0xa158: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa15c: adrp   x5, #0x1b000
 0xa160: mov    w20, #0x1c8
 0xa164: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa168: mov    w0, #0x51
 0xa16c: add    x2, sp, #0x1c8
 0xa170: mov    w3, #0x80
 0xa174: mov    w1, wzr
 0xa178: mov    x4, x19
 0xa17c: mov    w6, w20
 0xa180: bl     #0x2368 ; <duss_log_gen_head>
 0xa184: cbz    w0, #0xa1c0
 0xa188: ldr    x5, [sp, #0xc0]
 0xa18c: adrp   x3, #0x1a000
 0xa190: ldr    w6, [sp, #0xbc]
 0xa194: adrp   x4, #0x1a000
 0xa198: adrp   x7, #0x1b000
 0xa19c: str    w20, [sp, #8]
 0xa1a0: mov    w1, wzr
 0xa1a4: str    x19, [sp]
 0xa1a8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa1ac: add    x4, x4, #0x441 ; "co"
 0xa1b0: mov    w0, #0x51
 0xa1b4: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xa1b8: add    x2, sp, #0x1c8
 0xa1bc: bl     #0x2378 ; <duss_log_print>
 0xa1c0: adrp   x4, #0x1a000
 0xa1c4: adrp   x5, #0x1b000
 0xa1c8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa1cc: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa1d0: mov    w0, #0x51
 0xa1d4: mov    w6, #0x1c8
 0xa1d8: b      #0xab20
 0xa1dc: adrp   x8, #0x1a000
 0xa1e0: str    wzr, [sp, #0xc0]
 0xa1e4: add    x8, x8, #0x440 ; =0x1a440
 0xa1e8: add    x1, sp, #0xd0
 0xa1ec: add    x2, sp, #0xc0
 0xa1f0: str    x8, [sp, #0xd0]
 0xa1f4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa1f8: adrp   x19, #0x1a000
 0xa1fc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa200: adrp   x5, #0x1a000
 0xa204: mov    w20, #0x2cc
 0xa208: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa20c: mov    w0, #0x51
 0xa210: add    x2, sp, #0x1c8
 0xa214: mov    w3, #0x80
 0xa218: mov    w1, wzr
 0xa21c: mov    x4, x19
 0xa220: mov    w6, w20
 0xa224: bl     #0x2368 ; <duss_log_gen_head>
 0xa228: cbz    w0, #0xa264
 0xa22c: ldr    x5, [sp, #0xd0]
 0xa230: adrp   x3, #0x1a000
 0xa234: ldr    w6, [sp, #0xc0]
 0xa238: adrp   x4, #0x1a000
 0xa23c: adrp   x7, #0x1b000
 0xa240: str    w20, [sp, #8]
 0xa244: mov    w1, wzr
 0xa248: str    x19, [sp]
 0xa24c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa250: add    x4, x4, #0x441 ; "co"
 0xa254: mov    w0, #0x51
 0xa258: add    x7, x7, #0x49b ; "encoding_request->allocator == ((void*)0)"
 0xa25c: add    x2, sp, #0x1c8
 0xa260: bl     #0x2378 ; <duss_log_print>
 0xa264: adrp   x4, #0x1a000
 0xa268: adrp   x5, #0x1a000
 0xa26c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa270: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa274: mov    w0, #0x51
 0xa278: mov    w6, #0x2cc
 0xa27c: b      #0xab20
 0xa280: adrp   x8, #0x1a000
 0xa284: str    wzr, [sp, #0xdc]
 0xa288: add    x8, x8, #0x440 ; =0x1a440
 0xa28c: add    x1, sp, #0xc0
 0xa290: add    x2, sp, #0xdc
 0xa294: str    x8, [sp, #0xc0]
 0xa298: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa29c: adrp   x19, #0x1a000
 0xa2a0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa2a4: adrp   x5, #0x1a000
 0xa2a8: mov    w20, #0x2d4
 0xa2ac: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa2b0: mov    w0, #0x51
 0xa2b4: add    x2, sp, #0x1c8
 0xa2b8: mov    w3, #0x80
 0xa2bc: mov    w1, wzr
 0xa2c0: mov    x4, x19
 0xa2c4: mov    w6, w20
 0xa2c8: bl     #0x2368 ; <duss_log_gen_head>
 0xa2cc: cbz    w0, #0xa308
 0xa2d0: ldr    x5, [sp, #0xc0]
 0xa2d4: adrp   x3, #0x1a000
 0xa2d8: ldr    w6, [sp, #0xdc]
 0xa2dc: adrp   x4, #0x1a000
 0xa2e0: adrp   x7, #0x1b000
 0xa2e4: str    w20, [sp, #8]
 0xa2e8: mov    w1, wzr
 0xa2ec: str    x19, [sp]
 0xa2f0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa2f4: add    x4, x4, #0x441 ; "co"
 0xa2f8: mov    w0, #0x51
 0xa2fc: add    x7, x7, #0x54a ; "encoding_request->buffer_group == ((void*)0)"
 0xa300: add    x2, sp, #0x1c8
 0xa304: bl     #0x2378 ; <duss_log_print>
 0xa308: adrp   x4, #0x1a000
 0xa30c: adrp   x5, #0x1a000
 0xa310: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa314: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa318: mov    w0, #0x51
 0xa31c: mov    w6, #0x2d4
 0xa320: b      #0xab20
 0xa324: adrp   x8, #0x1a000
 0xa328: str    wzr, [sp, #0xdc]
 0xa32c: add    x8, x8, #0x440 ; =0x1a440
 0xa330: add    x1, sp, #0xc0
 0xa334: add    x2, sp, #0xdc
 0xa338: str    x8, [sp, #0xc0]
 0xa33c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa340: adrp   x19, #0x1a000
 0xa344: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa348: adrp   x5, #0x1a000
 0xa34c: mov    w20, #0x2d9
 0xa350: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa354: mov    w0, #0x51
 0xa358: add    x2, sp, #0x1c8
 0xa35c: mov    w3, #0x80
 0xa360: mov    w1, wzr
 0xa364: mov    x4, x19
 0xa368: mov    w6, w20
 0xa36c: bl     #0x2368 ; <duss_log_gen_head>
 0xa370: cbz    w0, #0xa3ac
 0xa374: ldr    x5, [sp, #0xc0]
 0xa378: adrp   x3, #0x1a000
 0xa37c: ldr    w6, [sp, #0xdc]
 0xa380: adrp   x4, #0x1a000
 0xa384: adrp   x7, #0x1b000
 0xa388: str    w20, [sp, #8]
 0xa38c: mov    w1, wzr
 0xa390: str    x19, [sp]
 0xa394: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa398: add    x4, x4, #0x441 ; "co"
 0xa39c: mov    w0, #0x51
 0xa3a0: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xa3a4: add    x2, sp, #0x1c8
 0xa3a8: bl     #0x2378 ; <duss_log_print>
 0xa3ac: adrp   x4, #0x1a000
 0xa3b0: adrp   x5, #0x1a000
 0xa3b4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa3b8: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa3bc: mov    w0, #0x51
 0xa3c0: mov    w6, #0x2d9
 0xa3c4: b      #0xab20
 0xa3c8: adrp   x8, #0x1a000
 0xa3cc: str    wzr, [sp, #0xdc]
 0xa3d0: add    x8, x8, #0x440 ; =0x1a440
 0xa3d4: add    x1, sp, #0xc0
 0xa3d8: add    x2, sp, #0xdc
 0xa3dc: str    x8, [sp, #0xc0]
 0xa3e0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa3e4: adrp   x19, #0x1a000
 0xa3e8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa3ec: adrp   x5, #0x1a000
 0xa3f0: mov    w20, #0x2db
 0xa3f4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa3f8: mov    w0, #0x51
 0xa3fc: add    x2, sp, #0x1c8
 0xa400: mov    w3, #0x80
 0xa404: mov    w1, wzr
 0xa408: mov    x4, x19
 0xa40c: mov    w6, w20
 0xa410: bl     #0x2368 ; <duss_log_gen_head>
 0xa414: cbz    w0, #0xa450
 0xa418: ldr    x5, [sp, #0xc0]
 0xa41c: adrp   x3, #0x1a000
 0xa420: ldr    w6, [sp, #0xdc]
 0xa424: adrp   x4, #0x1a000
 0xa428: adrp   x7, #0x1b000
 0xa42c: str    w20, [sp, #8]
 0xa430: mov    w1, wzr
 0xa434: str    x19, [sp]
 0xa438: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa43c: add    x4, x4, #0x441 ; "co"
 0xa440: mov    w0, #0x51
 0xa444: add    x7, x7, #0x577 ; "enc_param.p_frame_buffer == ((void*)0)"
 0xa448: add    x2, sp, #0x1c8
 0xa44c: bl     #0x2378 ; <duss_log_print>
 0xa450: adrp   x4, #0x1a000
 0xa454: adrp   x5, #0x1a000
 0xa458: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa45c: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa460: mov    w0, #0x51
 0xa464: mov    w6, #0x2db
 0xa468: b      #0xab20
 0xa46c: bl     #0x2348 ; <co_thread_get>
 0xa470: cbnz   x0, #0xa894
 0xa474: adrp   x4, #0x1a000
 0xa478: adrp   x5, #0x1a000
 0xa47c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa480: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa484: mov    w0, #0x51
 0xa488: mov    w6, #0x301
 0xa48c: add    x2, sp, #0x1c8
 0xa490: mov    w3, #0x80
 0xa494: mov    w1, wzr
 0xa498: bl     #0x2368 ; <duss_log_gen_head>
 0xa49c: cbz    w0, #0xa91c
 0xa4a0: adrp   x3, #0x1a000
 0xa4a4: adrp   x4, #0x1b000
 0xa4a8: adrp   x5, #0x1a000
 0xa4ac: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xa4b0: add    x4, x4, #0x75e ; "sbuf->plane_count == 1"
 0xa4b4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa4b8: mov    w0, #0x51
 0xa4bc: mov    w6, #0x301
 0xa4c0: add    x2, sp, #0x1c8
 0xa4c4: mov    w1, wzr
 0xa4c8: bl     #0x2378 ; <duss_log_print>
 0xa4cc: b      #0xa91c
 0xa4d0: bl     #0x2348 ; <co_thread_get>
 0xa4d4: cbnz   x0, #0xa938
 0xa4d8: adrp   x4, #0x1a000
 0xa4dc: adrp   x5, #0x1a000
 0xa4e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa4e4: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa4e8: mov    w0, #0x51
 0xa4ec: mov    w6, #0x302
 0xa4f0: add    x2, sp, #0x1c8
 0xa4f4: mov    w3, #0x80
 0xa4f8: mov    w1, wzr
 0xa4fc: bl     #0x2368 ; <duss_log_gen_head>
 0xa500: cbz    w0, #0xa9c0
 0xa504: adrp   x3, #0x1a000
 0xa508: adrp   x4, #0x1b000
 0xa50c: adrp   x5, #0x1a000
 0xa510: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xa514: add    x4, x4, #0x775 ; "sbuf->obj.ref_count == 1"
 0xa518: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa51c: mov    w0, #0x51
 0xa520: mov    w6, #0x302
 0xa524: add    x2, sp, #0x1c8
 0xa528: mov    w1, wzr
 0xa52c: bl     #0x2378 ; <duss_log_print>
 0xa530: b      #0xa9c0
 0xa534: adrp   x8, #0x1a000
 0xa538: str    wzr, [sp, #0xdc]
 0xa53c: add    x8, x8, #0x440 ; =0x1a440
 0xa540: add    x1, sp, #0xc0
 0xa544: add    x2, sp, #0xdc
 0xa548: str    x8, [sp, #0xc0]
 0xa54c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa550: adrp   x19, #0x1a000
 0xa554: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa558: adrp   x5, #0x1b000
 0xa55c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa560: mov    w0, #0x51
 0xa564: add    x2, sp, #0x1c8
 0xa568: mov    w3, #0x80
 0xa56c: mov    w6, #0x1c0
 0xa570: mov    w1, wzr
 0xa574: mov    x4, x19
 0xa578: mov    w20, #0x1c0
 0xa57c: bl     #0x2368 ; <duss_log_gen_head>
 0xa580: cbz    w0, #0xa5bc
 0xa584: ldr    x5, [sp, #0xc0]
 0xa588: adrp   x3, #0x1a000
 0xa58c: ldr    w6, [sp, #0xdc]
 0xa590: adrp   x4, #0x1a000
 0xa594: adrp   x7, #0x1b000
 0xa598: str    w20, [sp, #8]
 0xa59c: mov    w1, wzr
 0xa5a0: str    x19, [sp]
 0xa5a4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa5a8: add    x4, x4, #0x441 ; "co"
 0xa5ac: mov    w0, #0x51
 0xa5b0: add    x7, x7, #0xfdb ; "DCAM_VAL_TYPE_UINT16 == val->val_type"
 0xa5b4: add    x2, sp, #0x1c8
 0xa5b8: bl     #0x2378 ; <duss_log_print>
 0xa5bc: adrp   x4, #0x1a000
 0xa5c0: adrp   x5, #0x1b000
 0xa5c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa5c8: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa5cc: mov    w0, #0x51
 0xa5d0: add    x2, sp, #0x1c8
 0xa5d4: mov    w3, #0x80
 0xa5d8: mov    w6, #0x1c0
 0xa5dc: b      #0xab28
 0xa5e0: adrp   x8, #0x1a000
 0xa5e4: str    wzr, [sp, #0xbc]
 0xa5e8: add    x8, x8, #0x440 ; =0x1a440
 0xa5ec: add    x1, sp, #0xc0
 0xa5f0: add    x2, sp, #0xbc
 0xa5f4: str    x8, [sp, #0xc0]
 0xa5f8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa5fc: adrp   x19, #0x1a000
 0xa600: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa604: adrp   x5, #0x1b000
 0xa608: mov    w20, #0x1c2
 0xa60c: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa610: mov    w0, #0x51
 0xa614: add    x2, sp, #0x1c8
 0xa618: mov    w3, #0x80
 0xa61c: mov    w1, wzr
 0xa620: mov    x4, x19
 0xa624: mov    w6, w20
 0xa628: bl     #0x2368 ; <duss_log_gen_head>
 0xa62c: cbz    w0, #0xa668
 0xa630: ldr    x5, [sp, #0xc0]
 0xa634: adrp   x3, #0x1a000
 0xa638: ldr    w6, [sp, #0xbc]
 0xa63c: adrp   x4, #0x1a000
 0xa640: adrp   x7, #0x1c000
 0xa644: str    w20, [sp, #8]
 0xa648: mov    w1, wzr
 0xa64c: str    x19, [sp]
 0xa650: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa654: add    x4, x4, #0x441 ; "co"
 0xa658: mov    w0, #0x51
 0xa65c: add    x7, x7, #1 ; "data"
 0xa660: add    x2, sp, #0x1c8
 0xa664: bl     #0x2378 ; <duss_log_print>
 0xa668: adrp   x4, #0x1a000
 0xa66c: adrp   x5, #0x1b000
 0xa670: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa674: add    x5, x5, #0xe43 ; "_proresraw_extract_ics_info"
 0xa678: mov    w0, #0x51
 0xa67c: mov    w6, #0x1c2
 0xa680: b      #0xab20
 0xa684: adrp   x8, #0x1a000
 0xa688: str    wzr, [sp, #0xdc]
 0xa68c: add    x8, x8, #0x440 ; =0x1a440
 0xa690: add    x1, sp, #0xc0
 0xa694: add    x2, sp, #0xdc
 0xa698: str    x8, [sp, #0xc0]
 0xa69c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa6a0: adrp   x19, #0x1a000
 0xa6a4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa6a8: adrp   x5, #0x1a000
 0xa6ac: mov    w20, #0x2f1
 0xa6b0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa6b4: mov    w0, #0x51
 0xa6b8: add    x2, sp, #0x1c8
 0xa6bc: mov    w3, #0x80
 0xa6c0: mov    w1, wzr
 0xa6c4: mov    x4, x19
 0xa6c8: mov    w6, w20
 0xa6cc: bl     #0x2368 ; <duss_log_gen_head>
 0xa6d0: cbz    w0, #0xa70c
 0xa6d4: ldr    x5, [sp, #0xc0]
 0xa6d8: adrp   x3, #0x1a000
 0xa6dc: ldr    w6, [sp, #0xdc]
 0xa6e0: adrp   x4, #0x1a000
 0xa6e4: adrp   x7, #0x1b000
 0xa6e8: str    w20, [sp, #8]
 0xa6ec: mov    w1, wzr
 0xa6f0: str    x19, [sp]
 0xa6f4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa6f8: add    x4, x4, #0x441 ; "co"
 0xa6fc: mov    w0, #0x51
 0xa700: add    x7, x7, #0x75e ; "sbuf->plane_count == 1"
 0xa704: add    x2, sp, #0x1c8
 0xa708: bl     #0x2378 ; <duss_log_print>
 0xa70c: adrp   x4, #0x1a000
 0xa710: adrp   x5, #0x1a000
 0xa714: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa718: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa71c: mov    w0, #0x51
 0xa720: mov    w6, #0x2f1
 0xa724: b      #0xab20
 0xa728: adrp   x8, #0x1a000
 0xa72c: str    wzr, [sp, #0xdc]
 0xa730: add    x8, x8, #0x440 ; =0x1a440
 0xa734: add    x1, sp, #0xc0
 0xa738: add    x2, sp, #0xdc
 0xa73c: str    x8, [sp, #0xc0]
 0xa740: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa744: adrp   x19, #0x1a000
 0xa748: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa74c: adrp   x5, #0x1a000
 0xa750: mov    w20, #0x2f2
 0xa754: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa758: mov    w0, #0x51
 0xa75c: add    x2, sp, #0x1c8
 0xa760: mov    w3, #0x80
 0xa764: mov    w1, wzr
 0xa768: mov    x4, x19
 0xa76c: mov    w6, w20
 0xa770: bl     #0x2368 ; <duss_log_gen_head>
 0xa774: cbz    w0, #0xa7b0
 0xa778: ldr    x5, [sp, #0xc0]
 0xa77c: adrp   x3, #0x1a000
 0xa780: ldr    w6, [sp, #0xdc]
 0xa784: adrp   x4, #0x1a000
 0xa788: adrp   x7, #0x1b000
 0xa78c: str    w20, [sp, #8]
 0xa790: mov    w1, wzr
 0xa794: str    x19, [sp]
 0xa798: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa79c: add    x4, x4, #0x441 ; "co"
 0xa7a0: mov    w0, #0x51
 0xa7a4: add    x7, x7, #0x775 ; "sbuf->obj.ref_count == 1"
 0xa7a8: add    x2, sp, #0x1c8
 0xa7ac: bl     #0x2378 ; <duss_log_print>
 0xa7b0: adrp   x4, #0x1a000
 0xa7b4: adrp   x5, #0x1a000
 0xa7b8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa7bc: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa7c0: mov    w0, #0x51
 0xa7c4: mov    w6, #0x2f2
 0xa7c8: b      #0xab20
 0xa7cc: bl     #0x2348 ; <co_thread_get>
 0xa7d0: cbnz   x0, #0xa9dc
 0xa7d4: adrp   x4, #0x1a000
 0xa7d8: adrp   x5, #0x1a000
 0xa7dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa7e0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa7e4: mov    w0, #0x51
 0xa7e8: mov    w6, #0x32c
 0xa7ec: add    x2, sp, #0x1c8
 0xa7f0: mov    w3, #0x80
 0xa7f4: mov    w1, wzr
 0xa7f8: bl     #0x2368 ; <duss_log_gen_head>
 0xa7fc: cbz    w0, #0xaa64
 0xa800: adrp   x3, #0x1a000
 0xa804: adrp   x4, #0x1b000
 0xa808: adrp   x5, #0x1a000
 0xa80c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xa810: add    x4, x4, #0xb9d ; "encoding_request->buffer_group"
 0xa814: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa818: mov    w0, #0x51
 0xa81c: mov    w6, #0x32c
 0xa820: add    x2, sp, #0x1c8
 0xa824: mov    w1, wzr
 0xa828: bl     #0x2378 ; <duss_log_print>
 0xa82c: b      #0xaa64
 0xa830: bl     #0x2348 ; <co_thread_get>
 0xa834: cbnz   x0, #0xaa80
 0xa838: adrp   x4, #0x1a000
 0xa83c: adrp   x5, #0x1a000
 0xa840: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa844: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa848: mov    w0, #0x51
 0xa84c: mov    w6, #0x334
 0xa850: add    x2, sp, #0x1c8
 0xa854: mov    w3, #0x80
 0xa858: mov    w1, wzr
 0xa85c: bl     #0x2368 ; <duss_log_gen_head>
 0xa860: cbz    w0, #0xab08
 0xa864: adrp   x3, #0x1a000
 0xa868: adrp   x4, #0x1b000
 0xa86c: adrp   x5, #0x1a000
 0xa870: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xa874: add    x4, x4, #0xbbc ; "allocator"
 0xa878: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa87c: mov    w0, #0x51
 0xa880: mov    w6, #0x334
 0xa884: add    x2, sp, #0x1c8
 0xa888: mov    w1, wzr
 0xa88c: bl     #0x2378 ; <duss_log_print>
 0xa890: b      #0xab08
 0xa894: adrp   x8, #0x1a000
 0xa898: str    wzr, [sp, #0xdc]
 0xa89c: add    x8, x8, #0x440 ; =0x1a440
 0xa8a0: add    x1, sp, #0xc0
 0xa8a4: add    x2, sp, #0xdc
 0xa8a8: str    x8, [sp, #0xc0]
 0xa8ac: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa8b0: adrp   x19, #0x1a000
 0xa8b4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa8b8: adrp   x5, #0x1a000
 0xa8bc: mov    w20, #0x301
 0xa8c0: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa8c4: mov    w0, #0x51
 0xa8c8: add    x2, sp, #0x1c8
 0xa8cc: mov    w3, #0x80
 0xa8d0: mov    w1, wzr
 0xa8d4: mov    x4, x19
 0xa8d8: mov    w6, w20
 0xa8dc: bl     #0x2368 ; <duss_log_gen_head>
 0xa8e0: cbz    w0, #0xa91c
 0xa8e4: ldr    x5, [sp, #0xc0]
 0xa8e8: adrp   x3, #0x1a000
 0xa8ec: ldr    w6, [sp, #0xdc]
 0xa8f0: adrp   x4, #0x1a000
 0xa8f4: adrp   x7, #0x1b000
 0xa8f8: str    w20, [sp, #8]
 0xa8fc: mov    w1, wzr
 0xa900: str    x19, [sp]
 0xa904: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa908: add    x4, x4, #0x441 ; "co"
 0xa90c: mov    w0, #0x51
 0xa910: add    x7, x7, #0x75e ; "sbuf->plane_count == 1"
 0xa914: add    x2, sp, #0x1c8
 0xa918: bl     #0x2378 ; <duss_log_print>
 0xa91c: adrp   x4, #0x1a000
 0xa920: adrp   x5, #0x1a000
 0xa924: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa928: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa92c: mov    w0, #0x51
 0xa930: mov    w6, #0x301
 0xa934: b      #0xab20
 0xa938: adrp   x8, #0x1a000
 0xa93c: str    wzr, [sp, #0xdc]
 0xa940: add    x8, x8, #0x440 ; =0x1a440
 0xa944: add    x1, sp, #0xc0
 0xa948: add    x2, sp, #0xdc
 0xa94c: str    x8, [sp, #0xc0]
 0xa950: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa954: adrp   x19, #0x1a000
 0xa958: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa95c: adrp   x5, #0x1a000
 0xa960: mov    w20, #0x302
 0xa964: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa968: mov    w0, #0x51
 0xa96c: add    x2, sp, #0x1c8
 0xa970: mov    w3, #0x80
 0xa974: mov    w1, wzr
 0xa978: mov    x4, x19
 0xa97c: mov    w6, w20
 0xa980: bl     #0x2368 ; <duss_log_gen_head>
 0xa984: cbz    w0, #0xa9c0
 0xa988: ldr    x5, [sp, #0xc0]
 0xa98c: adrp   x3, #0x1a000
 0xa990: ldr    w6, [sp, #0xdc]
 0xa994: adrp   x4, #0x1a000
 0xa998: adrp   x7, #0x1b000
 0xa99c: str    w20, [sp, #8]
 0xa9a0: mov    w1, wzr
 0xa9a4: str    x19, [sp]
 0xa9a8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xa9ac: add    x4, x4, #0x441 ; "co"
 0xa9b0: mov    w0, #0x51
 0xa9b4: add    x7, x7, #0x775 ; "sbuf->obj.ref_count == 1"
 0xa9b8: add    x2, sp, #0x1c8
 0xa9bc: bl     #0x2378 ; <duss_log_print>
 0xa9c0: adrp   x4, #0x1a000
 0xa9c4: adrp   x5, #0x1a000
 0xa9c8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xa9cc: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xa9d0: mov    w0, #0x51
 0xa9d4: mov    w6, #0x302
 0xa9d8: b      #0xab20
 0xa9dc: adrp   x8, #0x1a000
 0xa9e0: str    wzr, [sp, #0xdc]
 0xa9e4: add    x8, x8, #0x440 ; =0x1a440
 0xa9e8: add    x1, sp, #0xc0
 0xa9ec: add    x2, sp, #0xdc
 0xa9f0: str    x8, [sp, #0xc0]
 0xa9f4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xa9f8: adrp   x19, #0x1a000
 0xa9fc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xaa00: adrp   x5, #0x1a000
 0xaa04: mov    w20, #0x32c
 0xaa08: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xaa0c: mov    w0, #0x51
 0xaa10: add    x2, sp, #0x1c8
 0xaa14: mov    w3, #0x80
 0xaa18: mov    w1, wzr
 0xaa1c: mov    x4, x19
 0xaa20: mov    w6, w20
 0xaa24: bl     #0x2368 ; <duss_log_gen_head>
 0xaa28: cbz    w0, #0xaa64
 0xaa2c: ldr    x5, [sp, #0xc0]
 0xaa30: adrp   x3, #0x1a000
 0xaa34: ldr    w6, [sp, #0xdc]
 0xaa38: adrp   x4, #0x1a000
 0xaa3c: adrp   x7, #0x1b000
 0xaa40: str    w20, [sp, #8]
 0xaa44: mov    w1, wzr
 0xaa48: str    x19, [sp]
 0xaa4c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xaa50: add    x4, x4, #0x441 ; "co"
 0xaa54: mov    w0, #0x51
 0xaa58: add    x7, x7, #0xb9d ; "encoding_request->buffer_group"
 0xaa5c: add    x2, sp, #0x1c8
 0xaa60: bl     #0x2378 ; <duss_log_print>
 0xaa64: adrp   x4, #0x1a000
 0xaa68: adrp   x5, #0x1a000
 0xaa6c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xaa70: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xaa74: mov    w0, #0x51
 0xaa78: mov    w6, #0x32c
 0xaa7c: b      #0xab20
 0xaa80: adrp   x8, #0x1a000
 0xaa84: str    wzr, [sp, #0xdc]
 0xaa88: add    x8, x8, #0x440 ; =0x1a440
 0xaa8c: add    x1, sp, #0xc0
 0xaa90: add    x2, sp, #0xdc
 0xaa94: str    x8, [sp, #0xc0]
 0xaa98: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xaa9c: adrp   x19, #0x1a000
 0xaaa0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xaaa4: adrp   x5, #0x1a000
 0xaaa8: mov    w20, #0x334
 0xaaac: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xaab0: mov    w0, #0x51
 0xaab4: add    x2, sp, #0x1c8
 0xaab8: mov    w3, #0x80
 0xaabc: mov    w1, wzr
 0xaac0: mov    x4, x19
 0xaac4: mov    w6, w20
 0xaac8: bl     #0x2368 ; <duss_log_gen_head>
 0xaacc: cbz    w0, #0xab08
 0xaad0: ldr    x5, [sp, #0xc0]
 0xaad4: adrp   x3, #0x1a000
 0xaad8: ldr    w6, [sp, #0xdc]
 0xaadc: adrp   x4, #0x1a000
 0xaae0: adrp   x7, #0x1b000
 0xaae4: str    w20, [sp, #8]
 0xaae8: mov    w1, wzr
 0xaaec: str    x19, [sp]
 0xaaf0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xaaf4: add    x4, x4, #0x441 ; "co"
 0xaaf8: mov    w0, #0x51
 0xaafc: add    x7, x7, #0xbbc ; "allocator"
 0xab00: add    x2, sp, #0x1c8
 0xab04: bl     #0x2378 ; <duss_log_print>
 0xab08: adrp   x4, #0x1a000
 0xab0c: adrp   x5, #0x1a000
 0xab10: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xab14: add    x5, x5, #0xf40 ; "_proresraw_venc_eng_enc_frame"
 0xab18: mov    w0, #0x51
 0xab1c: mov    w6, #0x334
 0xab20: add    x2, sp, #0x1c8
 0xab24: mov    w3, #0x80
 0xab28: mov    w1, wzr
 0xab2c: bl     #0x2368 ; <duss_log_gen_head>
 0xab30: cbz    w0, #0xab4c
 0xab34: adrp   x3, #0x1a000
 0xab38: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xab3c: mov    w0, #0x51
 0xab40: add    x2, sp, #0x1c8
 0xab44: mov    w1, wzr
 0xab48: bl     #0x2378 ; <duss_log_print>
 0xab4c: adrp   x0, #0x1a000
 0xab50: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xab54: bl     #0x23e8 ; <log_to_kmsg>
 0xab58: adrp   x0, #0x1a000
 0xab5c: add    x0, x0, #0x57f ; "Camera:	"
 0xab60: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xab64: bl     #0x2408 ; <is_running_in_cam_sil>
 0xab68: tbz    w0, #0, #0xab78
 0xab6c: mov    x0, xzr
 0xab70: bl     #0x2418 ; <fflush>
 0xab74: bl     #0x2428 ; <abort>
 0xab78: mov    w0, #1
 0xab7c: bl     #0x2438 ; <exit>
 0xab80: sub    sp, sp, #0xc0
 0xab84: stp    x20, x19, [sp, #0xa0]
 0xab88: stp    x29, x30, [sp, #0xb0]
 0xab8c: add    x29, sp, #0xb0
 0xab90: mrs    x19, tpidr_el0
 0xab94: adrp   x0, #0x30000
 0xab98: ldr    x8, [x19, #0x28]
 0xab9c: adrp   x2, #0x1a000
 0xaba0: mov    x20, sp
 0xaba4: add    x0, x0, #8 ; =0x30008
 0xaba8: mov    w1, #5
 0xabac: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xabb0: str    x8, [x20]
 0xabb4: bl     #0x2338 ; <log_mgr_check>
 0xabb8: tbz    w0, #0, #0xac8c
 0xabbc: bl     #0x2348 ; <co_thread_get>
 0xabc0: cbz    x0, #0xac40
 0xabc4: adrp   x8, #0x1a000
 0xabc8: str    wzr, [sp, #0xc]
 0xabcc: add    x8, x8, #0x440 ; =0x1a440
 0xabd0: add    x1, sp, #0x10
 0xabd4: add    x2, sp, #0xc
 0xabd8: str    x8, [sp, #0x10]
 0xabdc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xabe0: adrp   x4, #0x1a000
 0xabe4: adrp   x5, #0x1c000
 0xabe8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xabec: add    x5, x5, #0x42 ; "_proresraw_venc_eng_reg_buffers"
 0xabf0: mov    w0, #0x51
 0xabf4: mov    w6, #0x349
 0xabf8: mov    w1, #3
 0xabfc: add    x2, sp, #0x18
 0xac00: mov    w3, #0x80
 0xac04: bl     #0x2368 ; <duss_log_gen_head>
 0xac08: cbz    w0, #0xac8c
 0xac0c: ldr    x6, [sp, #0x10]
 0xac10: adrp   x3, #0x1a000
 0xac14: ldr    w7, [sp, #0xc]
 0xac18: adrp   x4, #0x1a000
 0xac1c: adrp   x5, #0x1a000
 0xac20: add    x3, x3, #0xf13 ; "%s: %s(%s_%x): reg_buffers
"
 0xac24: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xac28: add    x5, x5, #0x441 ; "co"
 0xac2c: mov    w0, #0x51
 0xac30: mov    w1, #3
 0xac34: add    x2, sp, #0x18
 0xac38: bl     #0x2378 ; <duss_log_print>
 0xac3c: b      #0xac8c
 0xac40: adrp   x4, #0x1a000
 0xac44: adrp   x5, #0x1c000
 0xac48: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xac4c: add    x5, x5, #0x42 ; "_proresraw_venc_eng_reg_buffers"
 0xac50: mov    w0, #0x51
 0xac54: mov    w6, #0x349
 0xac58: mov    w1, #3
 0xac5c: add    x2, sp, #0x18
 0xac60: mov    w3, #0x80
 0xac64: bl     #0x2368 ; <duss_log_gen_head>
 0xac68: cbz    w0, #0xac8c
 0xac6c: adrp   x3, #0x1a000
 0xac70: adrp   x4, #0x1a000
 0xac74: add    x3, x3, #0xf2f ; "%s: reg_buffers
"
 0xac78: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xac7c: mov    w0, #0x51
 0xac80: mov    w1, #3
 0xac84: add    x2, sp, #0x18
 0xac88: bl     #0x2378 ; <duss_log_print>
 0xac8c: ldr    x8, [x19, #0x28]
 0xac90: ldr    x9, [x20]
 0xac94: cmp    x8, x9
 0xac98: b.ne   #0xacb0
 0xac9c: ldp    x29, x30, [sp, #0xb0]
 0xaca0: ldp    x20, x19, [sp, #0xa0]
 0xaca4: mov    w0, wzr
 0xaca8: add    sp, sp, #0xc0
 0xacac: ret    
 0xacb0: bl     #0x23d8 ; <__stack_chk_fail>
 0xacb4: udf    #0
 0xacb8: sub    sp, sp, #0x140
 0xacbc: stp    x28, x27, [sp, #0xe0]
 0xacc0: stp    x26, x25, [sp, #0xf0]
 0xacc4: stp    x24, x23, [sp, #0x100]
 0xacc8: stp    x22, x21, [sp, #0x110]
 0xaccc: stp    x20, x19, [sp, #0x120]
 0xacd0: stp    x29, x30, [sp, #0x130]
 0xacd4: add    x29, sp, #0x130
 0xacd8: mrs    x19, tpidr_el0
 0xacdc: mov    x20, x0
 0xace0: ldr    x8, [x19, #0x28]
 0xace4: add    x9, sp, #0x30
 0xace8: str    x8, [x9]
 0xacec: cbz    x20, #0xb32c
 0xacf0: adrp   x0, #0x30000
 0xacf4: adrp   x2, #0x1a000
 0xacf8: add    x0, x0, #8 ; =0x30008
 0xacfc: mov    w1, #5
 0xad00: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xad04: bl     #0x2338 ; <log_mgr_check>
 0xad08: tbz    w0, #0, #0xaddc
 0xad0c: bl     #0x2348 ; <co_thread_get>
 0xad10: cbz    x0, #0xad90
 0xad14: adrp   x8, #0x1a000
 0xad18: str    wzr, [sp, #0x40]
 0xad1c: add    x8, x8, #0x440 ; =0x1a440
 0xad20: add    x1, sp, #0x50
 0xad24: add    x2, sp, #0x40
 0xad28: str    x8, [sp, #0x50]
 0xad2c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xad30: adrp   x4, #0x1a000
 0xad34: adrp   x5, #0x1c000
 0xad38: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xad3c: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xad40: mov    w0, #0x51
 0xad44: mov    w6, #0x355
 0xad48: mov    w1, #3
 0xad4c: add    x2, sp, #0x58
 0xad50: mov    w3, #0x80
 0xad54: bl     #0x2368 ; <duss_log_gen_head>
 0xad58: cbz    w0, #0xaddc
 0xad5c: ldr    x6, [sp, #0x50]
 0xad60: adrp   x3, #0x1c000
 0xad64: ldr    w7, [sp, #0x40]
 0xad68: adrp   x4, #0x1a000
 0xad6c: adrp   x5, #0x1a000
 0xad70: add    x3, x3, #0x84 ; "%s: %s(%s_%x): unreg_buffers
"
 0xad74: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xad78: add    x5, x5, #0x441 ; "co"
 0xad7c: mov    w0, #0x51
 0xad80: mov    w1, #3
 0xad84: add    x2, sp, #0x58
 0xad88: bl     #0x2378 ; <duss_log_print>
 0xad8c: b      #0xaddc
 0xad90: adrp   x4, #0x1a000
 0xad94: adrp   x5, #0x1c000
 0xad98: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xad9c: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xada0: mov    w0, #0x51
 0xada4: mov    w6, #0x355
 0xada8: mov    w1, #3
 0xadac: add    x2, sp, #0x58
 0xadb0: mov    w3, #0x80
 0xadb4: bl     #0x2368 ; <duss_log_gen_head>
 0xadb8: cbz    w0, #0xaddc
 0xadbc: adrp   x3, #0x1c000
 0xadc0: adrp   x4, #0x1a000
 0xadc4: add    x3, x3, #0xa2 ; "%s: unreg_buffers
"
 0xadc8: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xadcc: mov    w0, #0x51
 0xadd0: mov    w1, #3
 0xadd4: add    x2, sp, #0x58
 0xadd8: bl     #0x2378 ; <duss_log_print>
 0xaddc: ldr    x0, [x20, #0x408]
 0xade0: str    x19, [sp, #0x20]
 0xade4: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xade8: mov    x19, x20
 0xadec: str    w0, [sp, #0x2c]
 0xadf0: cbz    w0, #0xaf68
 0xadf4: adrp   x22, #0x30000
 0xadf8: adrp   x23, #0x1a000
 0xadfc: adrp   x24, #0x1a000
 0xae00: adrp   x25, #0x1c000
 0xae04: mov    w28, #0x86a0
 0xae08: mov    w21, wzr
 0xae0c: add    x22, x22, #8 ; =0x30008
 0xae10: add    x23, x23, #0x5c4 ; "PRORESRAW"
 0xae14: add    x24, x24, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xae18: add    x25, x25, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xae1c: mov    w26, #0x51
 0xae20: mov    w27, #0x368
 0xae24: movk   w28, #1, lsl #16
 0xae28: ldr    x0, [x19, #0x408]
 0xae2c: add    x1, sp, #0x50
 0xae30: mov    x20, x19
 0xae34: strb   wzr, [sp, #0x4c]
 0xae38: bl     #0x2508 ; <buffer_queue_dequeue>
 0xae3c: cbnz   w0, #0xb11c
 0xae40: ldr    x0, [sp, #0x50]
 0xae44: adrp   x19, #0x1a000
 0xae48: add    x19, x19, #0x440 ; =0x1a440
 0xae4c: cbz    x0, #0xb180
 0xae50: ldrb   w8, [sp, #0x4c]
 0xae54: cbnz   w8, #0xaf48
 0xae58: b      #0xae60
 0xae5c: ldr    x0, [sp, #0x50]
 0xae60: add    x1, sp, #0x4c
 0xae64: bl     #0x2638 ; <cam_encoded_buffer_allocator_buffer_is_full>
 0xae68: cbnz   w0, #0xafb8
 0xae6c: mov    w1, #3
 0xae70: mov    x0, x22
 0xae74: mov    x2, x23
 0xae78: bl     #0x2338 ; <log_mgr_check>
 0xae7c: tbz    w0, #0, #0xaf38
 0xae80: bl     #0x2348 ; <co_thread_get>
 0xae84: cbz    x0, #0xaef4
 0xae88: add    x1, sp, #0x40
 0xae8c: str    x19, [sp, #0x40]
 0xae90: add    x2, sp, #0x3c
 0xae94: str    wzr, [sp, #0x3c]
 0xae98: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xae9c: mov    w1, #3
 0xaea0: add    x2, sp, #0x58
 0xaea4: mov    w3, #0x80
 0xaea8: mov    w0, w26
 0xaeac: mov    x4, x24
 0xaeb0: mov    x5, x25
 0xaeb4: mov    w6, w27
 0xaeb8: bl     #0x2368 ; <duss_log_gen_head>
 0xaebc: cbz    w0, #0xaf38
 0xaec0: ldr    x6, [sp, #0x40]
 0xaec4: adrp   x3, #0x1c000
 0xaec8: ldr    w7, [sp, #0x3c]
 0xaecc: adrp   x5, #0x1a000
 0xaed0: mov    w1, #3
 0xaed4: str    w21, [sp]
 0xaed8: add    x2, sp, #0x58
 0xaedc: mov    w0, w26
 0xaee0: add    x3, x3, #0xb5 ; "%s: %s(%s_%x): waiting for file writing operations on allocator %d to finish...
"
 0xaee4: mov    x4, x23
 0xaee8: add    x5, x5, #0x441 ; "co"
 0xaeec: bl     #0x2378 ; <duss_log_print>
 0xaef0: b      #0xaf38
 0xaef4: mov    w1, #3
 0xaef8: add    x2, sp, #0x58
 0xaefc: mov    w3, #0x80
 0xaf00: mov    w0, w26
 0xaf04: mov    x4, x24
 0xaf08: mov    x5, x25
 0xaf0c: mov    w6, w27
 0xaf10: bl     #0x2368 ; <duss_log_gen_head>
 0xaf14: cbz    w0, #0xaf38
 0xaf18: adrp   x3, #0x1c000
 0xaf1c: mov    w1, #3
 0xaf20: add    x2, sp, #0x58
 0xaf24: mov    w0, w26
 0xaf28: add    x3, x3, #0x106 ; "%s: waiting for file writing operations on allocator %d to finish...
"
 0xaf2c: mov    x4, x23
 0xaf30: mov    w5, w21
 0xaf34: bl     #0x2378 ; <duss_log_print>
 0xaf38: mov    w0, w28
 0xaf3c: bl     #0x2488 ; <duss_osal_task_sleep>
 0xaf40: ldrb   w8, [sp, #0x4c]
 0xaf44: cbz    w8, #0xae5c
 0xaf48: mov    x19, x20
 0xaf4c: add    x1, sp, #0x50
 0xaf50: ldr    x0, [x19, #0x408]
 0xaf54: bl     #0x2588 ; <buffer_queue_enqueue>
 0xaf58: ldr    w8, [sp, #0x2c]
 0xaf5c: add    w21, w21, #1
 0xaf60: cmp    w21, w8
 0xaf64: b.lo   #0xae28
 0xaf68: ldr    x0, [x19, #0x3f8]
 0xaf6c: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xaf70: ldr    w8, [x19, #0x400]
 0xaf74: cmp    w0, w8
 0xaf78: b.ne   #0xb390
 0xaf7c: ldr    x8, [sp, #0x20]
 0xaf80: add    x9, sp, #0x30
 0xaf84: ldr    x8, [x8, #0x28]
 0xaf88: ldr    x9, [x9]
 0xaf8c: cmp    x8, x9
 0xaf90: b.ne   #0xb3f4
 0xaf94: ldp    x29, x30, [sp, #0x130]
 0xaf98: ldp    x20, x19, [sp, #0x120]
 0xaf9c: ldp    x22, x21, [sp, #0x110]
 0xafa0: ldp    x24, x23, [sp, #0x100]
 0xafa4: ldp    x26, x25, [sp, #0xf0]
 0xafa8: ldp    x28, x27, [sp, #0xe0]
 0xafac: mov    w0, wzr
 0xafb0: add    sp, sp, #0x140
 0xafb4: ret    
 0xafb8: bl     #0x2348 ; <co_thread_get>
 0xafbc: cbnz   x0, #0xb01c
 0xafc0: adrp   x4, #0x1a000
 0xafc4: adrp   x5, #0x1c000
 0xafc8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xafcc: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xafd0: mov    w0, #0x51
 0xafd4: mov    w6, #0x366
 0xafd8: add    x2, sp, #0x58
 0xafdc: mov    w3, #0x80
 0xafe0: mov    w1, wzr
 0xafe4: bl     #0x2368 ; <duss_log_gen_head>
 0xafe8: cbz    w0, #0xb0a4
 0xafec: adrp   x3, #0x1a000
 0xaff0: adrp   x4, #0x1b000
 0xaff4: adrp   x5, #0x1a000
 0xaff8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xaffc: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xb000: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb004: mov    w0, #0x51
 0xb008: mov    w6, #0x366
 0xb00c: add    x2, sp, #0x58
 0xb010: mov    w1, wzr
 0xb014: bl     #0x2378 ; <duss_log_print>
 0xb018: b      #0xb0a4
 0xb01c: adrp   x8, #0x1a000
 0xb020: str    wzr, [sp, #0x3c]
 0xb024: add    x8, x8, #0x440 ; =0x1a440
 0xb028: add    x1, sp, #0x40
 0xb02c: add    x2, sp, #0x3c
 0xb030: str    x8, [sp, #0x40]
 0xb034: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb038: adrp   x19, #0x1a000
 0xb03c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb040: adrp   x5, #0x1c000
 0xb044: mov    w20, #0x366
 0xb048: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb04c: mov    w0, #0x51
 0xb050: add    x2, sp, #0x58
 0xb054: mov    w3, #0x80
 0xb058: mov    w1, wzr
 0xb05c: mov    x4, x19
 0xb060: mov    w6, w20
 0xb064: bl     #0x2368 ; <duss_log_gen_head>
 0xb068: cbz    w0, #0xb0a4
 0xb06c: ldr    x5, [sp, #0x40]
 0xb070: adrp   x3, #0x1a000
 0xb074: ldr    w6, [sp, #0x3c]
 0xb078: adrp   x4, #0x1a000
 0xb07c: adrp   x7, #0x1b000
 0xb080: str    w20, [sp, #8]
 0xb084: mov    w1, wzr
 0xb088: str    x19, [sp]
 0xb08c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xb090: add    x4, x4, #0x441 ; "co"
 0xb094: mov    w0, #0x51
 0xb098: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xb09c: add    x2, sp, #0x58
 0xb0a0: bl     #0x2378 ; <duss_log_print>
 0xb0a4: adrp   x4, #0x1a000
 0xb0a8: adrp   x5, #0x1c000
 0xb0ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb0b0: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb0b4: mov    w0, #0x51
 0xb0b8: mov    w6, #0x366
 0xb0bc: add    x2, sp, #0x58
 0xb0c0: mov    w3, #0x80
 0xb0c4: mov    w1, wzr
 0xb0c8: bl     #0x2368 ; <duss_log_gen_head>
 0xb0cc: cbz    w0, #0xb0e8
 0xb0d0: adrp   x3, #0x1a000
 0xb0d4: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xb0d8: mov    w0, #0x51
 0xb0dc: add    x2, sp, #0x58
 0xb0e0: mov    w1, wzr
 0xb0e4: bl     #0x2378 ; <duss_log_print>
 0xb0e8: adrp   x0, #0x1a000
 0xb0ec: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xb0f0: bl     #0x23e8 ; <log_to_kmsg>
 0xb0f4: adrp   x0, #0x1a000
 0xb0f8: add    x0, x0, #0x57f ; "Camera:	"
 0xb0fc: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xb100: bl     #0x2408 ; <is_running_in_cam_sil>
 0xb104: tbz    w0, #0, #0xb114
 0xb108: mov    x0, xzr
 0xb10c: bl     #0x2418 ; <fflush>
 0xb110: bl     #0x2428 ; <abort>
 0xb114: mov    w0, #1
 0xb118: bl     #0x2438 ; <exit>
 0xb11c: bl     #0x2348 ; <co_thread_get>
 0xb120: cbnz   x0, #0xb1e4
 0xb124: adrp   x4, #0x1a000
 0xb128: adrp   x5, #0x1c000
 0xb12c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb130: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb134: mov    w0, #0x51
 0xb138: mov    w6, #0x361
 0xb13c: add    x2, sp, #0x58
 0xb140: mov    w3, #0x80
 0xb144: mov    w1, wzr
 0xb148: bl     #0x2368 ; <duss_log_gen_head>
 0xb14c: cbz    w0, #0xb26c
 0xb150: adrp   x3, #0x1a000
 0xb154: adrp   x4, #0x1b000
 0xb158: adrp   x5, #0x1a000
 0xb15c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xb160: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xb164: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb168: mov    w0, #0x51
 0xb16c: mov    w6, #0x361
 0xb170: add    x2, sp, #0x58
 0xb174: mov    w1, wzr
 0xb178: bl     #0x2378 ; <duss_log_print>
 0xb17c: b      #0xb26c
 0xb180: bl     #0x2348 ; <co_thread_get>
 0xb184: cbnz   x0, #0xb288
 0xb188: adrp   x4, #0x1a000
 0xb18c: adrp   x5, #0x1c000
 0xb190: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb194: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb198: mov    w0, #0x51
 0xb19c: mov    w6, #0x362
 0xb1a0: add    x2, sp, #0x58
 0xb1a4: mov    w3, #0x80
 0xb1a8: mov    w1, wzr
 0xb1ac: bl     #0x2368 ; <duss_log_gen_head>
 0xb1b0: cbz    w0, #0xb310
 0xb1b4: adrp   x3, #0x1a000
 0xb1b8: adrp   x4, #0x1b000
 0xb1bc: adrp   x5, #0x1a000
 0xb1c0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xb1c4: add    x4, x4, #0xbbc ; "allocator"
 0xb1c8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb1cc: mov    w0, #0x51
 0xb1d0: mov    w6, #0x362
 0xb1d4: add    x2, sp, #0x58
 0xb1d8: mov    w1, wzr
 0xb1dc: bl     #0x2378 ; <duss_log_print>
 0xb1e0: b      #0xb310
 0xb1e4: adrp   x8, #0x1a000
 0xb1e8: str    wzr, [sp, #0x3c]
 0xb1ec: add    x8, x8, #0x440 ; =0x1a440
 0xb1f0: add    x1, sp, #0x40
 0xb1f4: add    x2, sp, #0x3c
 0xb1f8: str    x8, [sp, #0x40]
 0xb1fc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb200: adrp   x19, #0x1a000
 0xb204: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb208: adrp   x5, #0x1c000
 0xb20c: mov    w20, #0x361
 0xb210: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb214: mov    w0, #0x51
 0xb218: add    x2, sp, #0x58
 0xb21c: mov    w3, #0x80
 0xb220: mov    w1, wzr
 0xb224: mov    x4, x19
 0xb228: mov    w6, w20
 0xb22c: bl     #0x2368 ; <duss_log_gen_head>
 0xb230: cbz    w0, #0xb26c
 0xb234: ldr    x5, [sp, #0x40]
 0xb238: adrp   x3, #0x1a000
 0xb23c: ldr    w6, [sp, #0x3c]
 0xb240: adrp   x4, #0x1a000
 0xb244: adrp   x7, #0x1b000
 0xb248: str    w20, [sp, #8]
 0xb24c: mov    w1, wzr
 0xb250: str    x19, [sp]
 0xb254: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xb258: add    x4, x4, #0x441 ; "co"
 0xb25c: mov    w0, #0x51
 0xb260: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xb264: add    x2, sp, #0x58
 0xb268: bl     #0x2378 ; <duss_log_print>
 0xb26c: adrp   x4, #0x1a000
 0xb270: adrp   x5, #0x1c000
 0xb274: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb278: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb27c: mov    w0, #0x51
 0xb280: mov    w6, #0x361
 0xb284: b      #0xb0bc
 0xb288: adrp   x8, #0x1a000
 0xb28c: str    wzr, [sp, #0x3c]
 0xb290: add    x8, x8, #0x440 ; =0x1a440
 0xb294: add    x1, sp, #0x40
 0xb298: add    x2, sp, #0x3c
 0xb29c: str    x8, [sp, #0x40]
 0xb2a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb2a4: adrp   x19, #0x1a000
 0xb2a8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb2ac: adrp   x5, #0x1c000
 0xb2b0: mov    w20, #0x362
 0xb2b4: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb2b8: mov    w0, #0x51
 0xb2bc: add    x2, sp, #0x58
 0xb2c0: mov    w3, #0x80
 0xb2c4: mov    w1, wzr
 0xb2c8: mov    x4, x19
 0xb2cc: mov    w6, w20
 0xb2d0: bl     #0x2368 ; <duss_log_gen_head>
 0xb2d4: cbz    w0, #0xb310
 0xb2d8: ldr    x5, [sp, #0x40]
 0xb2dc: adrp   x3, #0x1a000
 0xb2e0: ldr    w6, [sp, #0x3c]
 0xb2e4: adrp   x4, #0x1a000
 0xb2e8: adrp   x7, #0x1b000
 0xb2ec: str    w20, [sp, #8]
 0xb2f0: mov    w1, wzr
 0xb2f4: str    x19, [sp]
 0xb2f8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xb2fc: add    x4, x4, #0x441 ; "co"
 0xb300: mov    w0, #0x51
 0xb304: add    x7, x7, #0xbbc ; "allocator"
 0xb308: add    x2, sp, #0x58
 0xb30c: bl     #0x2378 ; <duss_log_print>
 0xb310: adrp   x4, #0x1a000
 0xb314: adrp   x5, #0x1c000
 0xb318: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb31c: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb320: mov    w0, #0x51
 0xb324: mov    w6, #0x362
 0xb328: b      #0xb0bc
 0xb32c: bl     #0x2348 ; <co_thread_get>
 0xb330: cbnz   x0, #0xb3f8
 0xb334: adrp   x4, #0x1a000
 0xb338: adrp   x5, #0x1c000
 0xb33c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb340: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb344: mov    w0, #0x51
 0xb348: mov    w6, #0x353
 0xb34c: add    x2, sp, #0x58
 0xb350: mov    w3, #0x80
 0xb354: mov    w1, wzr
 0xb358: bl     #0x2368 ; <duss_log_gen_head>
 0xb35c: cbz    w0, #0xb480
 0xb360: adrp   x3, #0x1a000
 0xb364: adrp   x4, #0x1a000
 0xb368: adrp   x5, #0x1a000
 0xb36c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xb370: add    x4, x4, #0x5c0 ; "ops"
 0xb374: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb378: mov    w0, #0x51
 0xb37c: mov    w6, #0x353
 0xb380: add    x2, sp, #0x58
 0xb384: mov    w1, wzr
 0xb388: bl     #0x2378 ; <duss_log_print>
 0xb38c: b      #0xb480
 0xb390: bl     #0x2348 ; <co_thread_get>
 0xb394: cbnz   x0, #0xb49c
 0xb398: adrp   x4, #0x1a000
 0xb39c: adrp   x5, #0x1c000
 0xb3a0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb3a4: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb3a8: mov    w0, #0x51
 0xb3ac: mov    w6, #0x370
 0xb3b0: add    x2, sp, #0x58
 0xb3b4: mov    w3, #0x80
 0xb3b8: mov    w1, wzr
 0xb3bc: bl     #0x2368 ; <duss_log_gen_head>
 0xb3c0: cbz    w0, #0xb524
 0xb3c4: adrp   x3, #0x1a000
 0xb3c8: adrp   x4, #0x1c000
 0xb3cc: adrp   x5, #0x1a000
 0xb3d0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xb3d4: add    x4, x4, #0x14c ; "count == eng->ics_buffer_pool_size"
 0xb3d8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb3dc: mov    w0, #0x51
 0xb3e0: mov    w6, #0x370
 0xb3e4: add    x2, sp, #0x58
 0xb3e8: mov    w1, wzr
 0xb3ec: bl     #0x2378 ; <duss_log_print>
 0xb3f0: b      #0xb524
 0xb3f4: bl     #0x23d8 ; <__stack_chk_fail>
 0xb3f8: adrp   x8, #0x1a000
 0xb3fc: str    wzr, [sp, #0x40]
 0xb400: add    x8, x8, #0x440 ; =0x1a440
 0xb404: add    x1, sp, #0x50
 0xb408: add    x2, sp, #0x40
 0xb40c: str    x8, [sp, #0x50]
 0xb410: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb414: adrp   x19, #0x1a000
 0xb418: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb41c: adrp   x5, #0x1c000
 0xb420: mov    w20, #0x353
 0xb424: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb428: mov    w0, #0x51
 0xb42c: add    x2, sp, #0x58
 0xb430: mov    w3, #0x80
 0xb434: mov    w1, wzr
 0xb438: mov    x4, x19
 0xb43c: mov    w6, w20
 0xb440: bl     #0x2368 ; <duss_log_gen_head>
 0xb444: cbz    w0, #0xb480
 0xb448: ldr    x5, [sp, #0x50]
 0xb44c: adrp   x3, #0x1a000
 0xb450: ldr    w6, [sp, #0x40]
 0xb454: adrp   x4, #0x1a000
 0xb458: adrp   x7, #0x1a000
 0xb45c: str    w20, [sp, #8]
 0xb460: mov    w1, wzr
 0xb464: str    x19, [sp]
 0xb468: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xb46c: add    x4, x4, #0x441 ; "co"
 0xb470: mov    w0, #0x51
 0xb474: add    x7, x7, #0x5c0 ; "ops"
 0xb478: add    x2, sp, #0x58
 0xb47c: bl     #0x2378 ; <duss_log_print>
 0xb480: adrp   x4, #0x1a000
 0xb484: adrp   x5, #0x1c000
 0xb488: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb48c: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb490: mov    w0, #0x51
 0xb494: mov    w6, #0x353
 0xb498: b      #0xb0bc
 0xb49c: adrp   x8, #0x1a000
 0xb4a0: str    wzr, [sp, #0x40]
 0xb4a4: add    x8, x8, #0x440 ; =0x1a440
 0xb4a8: add    x1, sp, #0x50
 0xb4ac: add    x2, sp, #0x40
 0xb4b0: str    x8, [sp, #0x50]
 0xb4b4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb4b8: adrp   x19, #0x1a000
 0xb4bc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb4c0: adrp   x5, #0x1c000
 0xb4c4: mov    w20, #0x370
 0xb4c8: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb4cc: mov    w0, #0x51
 0xb4d0: add    x2, sp, #0x58
 0xb4d4: mov    w3, #0x80
 0xb4d8: mov    w1, wzr
 0xb4dc: mov    x4, x19
 0xb4e0: mov    w6, w20
 0xb4e4: bl     #0x2368 ; <duss_log_gen_head>
 0xb4e8: cbz    w0, #0xb524
 0xb4ec: ldr    x5, [sp, #0x50]
 0xb4f0: adrp   x3, #0x1a000
 0xb4f4: ldr    w6, [sp, #0x40]
 0xb4f8: adrp   x4, #0x1a000
 0xb4fc: adrp   x7, #0x1c000
 0xb500: str    w20, [sp, #8]
 0xb504: mov    w1, wzr
 0xb508: str    x19, [sp]
 0xb50c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xb510: add    x4, x4, #0x441 ; "co"
 0xb514: mov    w0, #0x51
 0xb518: add    x7, x7, #0x14c ; "count == eng->ics_buffer_pool_size"
 0xb51c: add    x2, sp, #0x58
 0xb520: bl     #0x2378 ; <duss_log_print>
 0xb524: adrp   x4, #0x1a000
 0xb528: adrp   x5, #0x1c000
 0xb52c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb530: add    x5, x5, #0x62 ; "_proresraw_venc_eng_unreg_buffers"
 0xb534: mov    w0, #0x51
 0xb538: mov    w6, #0x370
 0xb53c: b      #0xb0bc
 0xb540: sub    sp, sp, #0xf0
 0xb544: str    x23, [sp, #0xb0]
 0xb548: stp    x22, x21, [sp, #0xc0]
 0xb54c: stp    x20, x19, [sp, #0xd0]
 0xb550: stp    x29, x30, [sp, #0xe0]
 0xb554: add    x29, sp, #0xe0
 0xb558: mrs    x21, tpidr_el0
 0xb55c: mov    x19, x0
 0xb560: ldr    x8, [x21, #0x28]
 0xb564: adrp   x0, #0x30000
 0xb568: adrp   x2, #0x1a000
 0xb56c: add    x22, sp, #0x10
 0xb570: add    x0, x0, #8 ; =0x30008
 0xb574: mov    w1, #5
 0xb578: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xb57c: str    x8, [x22]
 0xb580: bl     #0x2338 ; <log_mgr_check>
 0xb584: tbz    w0, #0, #0xb65c
 0xb588: bl     #0x2348 ; <co_thread_get>
 0xb58c: cbz    x0, #0xb610
 0xb590: adrp   x8, #0x1a000
 0xb594: str    wzr, [sp, #0x1c]
 0xb598: add    x8, x8, #0x440 ; =0x1a440
 0xb59c: add    x1, sp, #0x20
 0xb5a0: add    x2, sp, #0x1c
 0xb5a4: str    x8, [sp, #0x20]
 0xb5a8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb5ac: adrp   x4, #0x1a000
 0xb5b0: adrp   x5, #0x1c000
 0xb5b4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb5b8: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb5bc: mov    w0, #0x51
 0xb5c0: mov    w1, #3
 0xb5c4: add    x2, sp, #0x28
 0xb5c8: mov    w3, #0x80
 0xb5cc: mov    w6, #0xc0
 0xb5d0: bl     #0x2368 ; <duss_log_gen_head>
 0xb5d4: cbz    w0, #0xb65c
 0xb5d8: ldr    x6, [sp, #0x20]
 0xb5dc: adrp   x3, #0x1c000
 0xb5e0: ldr    w7, [sp, #0x1c]
 0xb5e4: adrp   x4, #0x1a000
 0xb5e8: adrp   x5, #0x1a000
 0xb5ec: add    x3, x3, #0x18a ; "%s: %s(%s_%x): destroy
"
 0xb5f0: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb5f4: add    x5, x5, #0x441 ; "co"
 0xb5f8: mov    w0, #0x51
 0xb5fc: mov    w1, #3
 0xb600: add    x2, sp, #0x28
 0xb604: bl     #0x2378 ; <duss_log_print>
 0xb608: cbnz   x19, #0xb660
 0xb60c: b      #0xbb68
 0xb610: adrp   x4, #0x1a000
 0xb614: adrp   x5, #0x1c000
 0xb618: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb61c: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb620: mov    w0, #0x51
 0xb624: mov    w1, #3
 0xb628: add    x2, sp, #0x28
 0xb62c: mov    w3, #0x80
 0xb630: mov    w6, #0xc0
 0xb634: bl     #0x2368 ; <duss_log_gen_head>
 0xb638: cbz    w0, #0xb65c
 0xb63c: adrp   x3, #0x1c000
 0xb640: adrp   x4, #0x1a000
 0xb644: add    x3, x3, #0x1a2 ; "%s: destroy
"
 0xb648: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb64c: mov    w0, #0x51
 0xb650: mov    w1, #3
 0xb654: add    x2, sp, #0x28
 0xb658: bl     #0x2378 ; <duss_log_print>
 0xb65c: cbz    x19, #0xbb68
 0xb660: ldrb   w8, [x19, #0x43c]
 0xb664: cbz    w8, #0xb67c
 0xb668: mov    x0, x19
 0xb66c: mov    x1, xzr
 0xb670: bl     #0x5a10
 0xb674: mov    x0, x19
 0xb678: bl     #0xacb8
 0xb67c: ldr    x8, [x19, #0xa0]
 0xb680: cbz    x8, #0xb724
 0xb684: adrp   x0, #0x30000
 0xb688: adrp   x2, #0x1a000
 0xb68c: add    x0, x0, #8 ; =0x30008
 0xb690: mov    w1, #5
 0xb694: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xb698: bl     #0x2338 ; <log_mgr_check>
 0xb69c: tbz    w0, #0, #0xb778
 0xb6a0: bl     #0x2348 ; <co_thread_get>
 0xb6a4: cbz    x0, #0xb72c
 0xb6a8: adrp   x8, #0x1a000
 0xb6ac: str    wzr, [sp, #0x1c]
 0xb6b0: add    x8, x8, #0x440 ; =0x1a440
 0xb6b4: add    x1, sp, #0x20
 0xb6b8: add    x2, sp, #0x1c
 0xb6bc: str    x8, [sp, #0x20]
 0xb6c0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb6c4: adrp   x4, #0x1a000
 0xb6c8: adrp   x5, #0x1c000
 0xb6cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb6d0: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb6d4: mov    w0, #0x51
 0xb6d8: mov    w6, #0xcc
 0xb6dc: mov    w1, #3
 0xb6e0: add    x2, sp, #0x28
 0xb6e4: mov    w3, #0x80
 0xb6e8: bl     #0x2368 ; <duss_log_gen_head>
 0xb6ec: cbz    w0, #0xb778
 0xb6f0: ldr    x6, [sp, #0x20]
 0xb6f4: adrp   x3, #0x1c000
 0xb6f8: ldr    w7, [sp, #0x1c]
 0xb6fc: adrp   x4, #0x1a000
 0xb700: adrp   x5, #0x1a000
 0xb704: add    x3, x3, #0x1af ; "%s: %s(%s_%x): before duss_hal_device_close
"
 0xb708: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb70c: add    x5, x5, #0x441 ; "co"
 0xb710: mov    w0, #0x51
 0xb714: mov    w1, #3
 0xb718: add    x2, sp, #0x28
 0xb71c: bl     #0x2378 ; <duss_log_print>
 0xb720: b      #0xb778
 0xb724: mov    w20, wzr
 0xb728: b      #0xba10
 0xb72c: adrp   x4, #0x1a000
 0xb730: adrp   x5, #0x1c000
 0xb734: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb738: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb73c: mov    w0, #0x51
 0xb740: mov    w6, #0xcc
 0xb744: mov    w1, #3
 0xb748: add    x2, sp, #0x28
 0xb74c: mov    w3, #0x80
 0xb750: bl     #0x2368 ; <duss_log_gen_head>
 0xb754: cbz    w0, #0xb778
 0xb758: adrp   x3, #0x1c000
 0xb75c: adrp   x4, #0x1a000
 0xb760: add    x3, x3, #0x1dc ; "%s: before duss_hal_device_close
"
 0xb764: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb768: mov    w0, #0x51
 0xb76c: mov    w1, #3
 0xb770: add    x2, sp, #0x28
 0xb774: bl     #0x2378 ; <duss_log_print>
 0xb778: ldr    x0, [x19, #0xa0]
 0xb77c: bl     #0x23a8 ; <duss_hal_device_close>
 0xb780: mov    w20, w0
 0xb784: adrp   x0, #0x30000
 0xb788: adrp   x2, #0x1a000
 0xb78c: add    x0, x0, #8 ; =0x30008
 0xb790: mov    w1, #5
 0xb794: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xb798: bl     #0x2338 ; <log_mgr_check>
 0xb79c: tbz    w0, #0, #0xb874
 0xb7a0: bl     #0x2348 ; <co_thread_get>
 0xb7a4: cbz    x0, #0xb828
 0xb7a8: adrp   x8, #0x1a000
 0xb7ac: str    wzr, [sp, #0x1c]
 0xb7b0: add    x8, x8, #0x440 ; =0x1a440
 0xb7b4: add    x1, sp, #0x20
 0xb7b8: add    x2, sp, #0x1c
 0xb7bc: str    x8, [sp, #0x20]
 0xb7c0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb7c4: adrp   x4, #0x1a000
 0xb7c8: adrp   x5, #0x1c000
 0xb7cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb7d0: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb7d4: mov    w0, #0x51
 0xb7d8: mov    w6, #0xce
 0xb7dc: mov    w1, #3
 0xb7e0: add    x2, sp, #0x28
 0xb7e4: mov    w3, #0x80
 0xb7e8: bl     #0x2368 ; <duss_log_gen_head>
 0xb7ec: cbz    w0, #0xb874
 0xb7f0: ldr    x6, [sp, #0x20]
 0xb7f4: adrp   x3, #0x1c000
 0xb7f8: ldr    w7, [sp, #0x1c]
 0xb7fc: adrp   x4, #0x1a000
 0xb800: adrp   x5, #0x1a000
 0xb804: add    x3, x3, #0x1fe ; "%s: %s(%s_%x): after duss_hal_device_close
"
 0xb808: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb80c: add    x5, x5, #0x441 ; "co"
 0xb810: mov    w0, #0x51
 0xb814: mov    w1, #3
 0xb818: add    x2, sp, #0x28
 0xb81c: bl     #0x2378 ; <duss_log_print>
 0xb820: cbnz   w20, #0xb878
 0xb824: b      #0xba0c
 0xb828: adrp   x4, #0x1a000
 0xb82c: adrp   x5, #0x1c000
 0xb830: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb834: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb838: mov    w0, #0x51
 0xb83c: mov    w6, #0xce
 0xb840: mov    w1, #3
 0xb844: add    x2, sp, #0x28
 0xb848: mov    w3, #0x80
 0xb84c: bl     #0x2368 ; <duss_log_gen_head>
 0xb850: cbz    w0, #0xb874
 0xb854: adrp   x3, #0x1c000
 0xb858: adrp   x4, #0x1a000
 0xb85c: add    x3, x3, #0x22a ; "%s: after duss_hal_device_close
"
 0xb860: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb864: mov    w0, #0x51
 0xb868: mov    w1, #3
 0xb86c: add    x2, sp, #0x28
 0xb870: bl     #0x2378 ; <duss_log_print>
 0xb874: cbz    w20, #0xba0c
 0xb878: adrp   x0, #0x30000
 0xb87c: adrp   x2, #0x1a000
 0xb880: add    x0, x0, #8 ; =0x30008
 0xb884: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xb888: mov    w1, #1
 0xb88c: bl     #0x2338 ; <log_mgr_check>
 0xb890: tbz    w0, #0, #0xba0c
 0xb894: bl     #0x2348 ; <co_thread_get>
 0xb898: cbz    x0, #0xb96c
 0xb89c: adrp   x8, #0x1a000
 0xb8a0: str    wzr, [sp, #0x1c]
 0xb8a4: add    x8, x8, #0x440 ; =0x1a440
 0xb8a8: add    x1, sp, #0x20
 0xb8ac: add    x2, sp, #0x1c
 0xb8b0: str    x8, [sp, #0x20]
 0xb8b4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xb8b8: adrp   x4, #0x1a000
 0xb8bc: adrp   x5, #0x1c000
 0xb8c0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb8c4: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb8c8: mov    w0, #0x51
 0xb8cc: mov    w6, #0xd0
 0xb8d0: mov    w1, #1
 0xb8d4: add    x2, sp, #0x28
 0xb8d8: mov    w3, #0x80
 0xb8dc: bl     #0x2368 ; <duss_log_gen_head>
 0xb8e0: cbz    w0, #0xb908
 0xb8e4: adrp   x3, #0x1a000
 0xb8e8: adrp   x4, #0x1a000
 0xb8ec: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xb8f0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb8f4: mov    w0, #0x51
 0xb8f8: mov    w5, #0xd0
 0xb8fc: mov    w1, #1
 0xb900: add    x2, sp, #0x28
 0xb904: bl     #0x2378 ; <duss_log_print>
 0xb908: adrp   x4, #0x1a000
 0xb90c: adrp   x5, #0x1c000
 0xb910: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb914: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb918: mov    w0, #0x51
 0xb91c: mov    w6, #0xd0
 0xb920: mov    w1, #1
 0xb924: add    x2, sp, #0x28
 0xb928: mov    w3, #0x80
 0xb92c: bl     #0x2368 ; <duss_log_gen_head>
 0xb930: cbz    w0, #0xba0c
 0xb934: ldr    x6, [sp, #0x20]
 0xb938: adrp   x3, #0x1c000
 0xb93c: ldr    w7, [sp, #0x1c]
 0xb940: adrp   x4, #0x1a000
 0xb944: adrp   x5, #0x1a000
 0xb948: str    w20, [sp]
 0xb94c: add    x3, x3, #0x24b ; "%s: %s(%s_%x): duss_hal_device_close(proresraw) error: %d
"
 0xb950: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb954: add    x5, x5, #0x441 ; "co"
 0xb958: mov    w0, #0x51
 0xb95c: mov    w1, #1
 0xb960: add    x2, sp, #0x28
 0xb964: bl     #0x2378 ; <duss_log_print>
 0xb968: b      #0xba0c
 0xb96c: adrp   x4, #0x1a000
 0xb970: adrp   x5, #0x1c000
 0xb974: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb978: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb97c: mov    w0, #0x51
 0xb980: mov    w6, #0xd0
 0xb984: mov    w1, #1
 0xb988: add    x2, sp, #0x28
 0xb98c: mov    w3, #0x80
 0xb990: bl     #0x2368 ; <duss_log_gen_head>
 0xb994: cbz    w0, #0xb9bc
 0xb998: adrp   x3, #0x1a000
 0xb99c: adrp   x4, #0x1a000
 0xb9a0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xb9a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb9a8: mov    w0, #0x51
 0xb9ac: mov    w5, #0xd0
 0xb9b0: mov    w1, #1
 0xb9b4: add    x2, sp, #0x28
 0xb9b8: bl     #0x2378 ; <duss_log_print>
 0xb9bc: adrp   x4, #0x1a000
 0xb9c0: adrp   x5, #0x1c000
 0xb9c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xb9c8: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xb9cc: mov    w0, #0x51
 0xb9d0: mov    w6, #0xd0
 0xb9d4: mov    w1, #1
 0xb9d8: add    x2, sp, #0x28
 0xb9dc: mov    w3, #0x80
 0xb9e0: bl     #0x2368 ; <duss_log_gen_head>
 0xb9e4: cbz    w0, #0xba0c
 0xb9e8: adrp   x3, #0x1c000
 0xb9ec: adrp   x4, #0x1a000
 0xb9f0: add    x3, x3, #0x286 ; "%s: duss_hal_device_close(proresraw) error: %d
"
 0xb9f4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xb9f8: mov    w0, #0x51
 0xb9fc: mov    w1, #1
 0xba00: add    x2, sp, #0x28
 0xba04: mov    w5, w20
 0xba08: bl     #0x2378 ; <duss_log_print>
 0xba0c: str    xzr, [x19, #0xa0]
 0xba10: adrp   x8, #0x30000
 0xba14: ldr    x8, [x8, #0x10]
 0xba18: cbz    x8, #0xba38
 0xba1c: adrp   x8, #0x30000
 0xba20: add    x8, x8, #0x10 ; =0x30010
 0xba24: add    x23, x8, #0x20 ; =0x30020
 0xba28: ldp    x8, x0, [x23, #-0x10]
 0xba2c: blr    x8
 0xba30: ldr    x8, [x23], #0x20
 0xba34: cbnz   x8, #0xba28
 0xba38: ldr    x0, [x19, #0x488]
 0xba3c: cbz    x0, #0xba48
 0xba40: bl     #0x2648 ; <duss_osal_event_destroy>
 0xba44: str    xzr, [x19, #0x488]
 0xba48: mov    x0, x19
 0xba4c: bl     #0xe478
 0xba50: adrp   x0, #0x30000
 0xba54: adrp   x2, #0x1a000
 0xba58: add    x0, x0, #8 ; =0x30008
 0xba5c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xba60: mov    w1, #3
 0xba64: bl     #0x2338 ; <log_mgr_check>
 0xba68: tbz    w0, #0, #0xbb3c
 0xba6c: bl     #0x2348 ; <co_thread_get>
 0xba70: cbz    x0, #0xbaf0
 0xba74: adrp   x8, #0x1a000
 0xba78: str    wzr, [sp, #0x1c]
 0xba7c: add    x8, x8, #0x440 ; =0x1a440
 0xba80: add    x1, sp, #0x20
 0xba84: add    x2, sp, #0x1c
 0xba88: str    x8, [sp, #0x20]
 0xba8c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xba90: adrp   x4, #0x1a000
 0xba94: adrp   x5, #0x1c000
 0xba98: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xba9c: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xbaa0: mov    w0, #0x51
 0xbaa4: mov    w6, #0xe1
 0xbaa8: mov    w1, #3
 0xbaac: add    x2, sp, #0x28
 0xbab0: mov    w3, #0x80
 0xbab4: bl     #0x2368 ; <duss_log_gen_head>
 0xbab8: cbz    w0, #0xbb3c
 0xbabc: ldr    x6, [sp, #0x20]
 0xbac0: adrp   x3, #0x1c000
 0xbac4: ldr    w7, [sp, #0x1c]
 0xbac8: adrp   x4, #0x1a000
 0xbacc: adrp   x5, #0x1a000
 0xbad0: add    x3, x3, #0x2b6 ; "%s: %s(%s_%x): proresraw venc eng destroyed
"
 0xbad4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xbad8: add    x5, x5, #0x441 ; "co"
 0xbadc: mov    w0, #0x51
 0xbae0: mov    w1, #3
 0xbae4: add    x2, sp, #0x28
 0xbae8: bl     #0x2378 ; <duss_log_print>
 0xbaec: b      #0xbb3c
 0xbaf0: adrp   x4, #0x1a000
 0xbaf4: adrp   x5, #0x1c000
 0xbaf8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbafc: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xbb00: mov    w0, #0x51
 0xbb04: mov    w6, #0xe1
 0xbb08: mov    w1, #3
 0xbb0c: add    x2, sp, #0x28
 0xbb10: mov    w3, #0x80
 0xbb14: bl     #0x2368 ; <duss_log_gen_head>
 0xbb18: cbz    w0, #0xbb3c
 0xbb1c: adrp   x3, #0x1c000
 0xbb20: adrp   x4, #0x1a000
 0xbb24: add    x3, x3, #0x2e3 ; "%s: proresraw venc eng destroyed
"
 0xbb28: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xbb2c: mov    w0, #0x51
 0xbb30: mov    w1, #3
 0xbb34: add    x2, sp, #0x28
 0xbb38: bl     #0x2378 ; <duss_log_print>
 0xbb3c: ldr    x8, [x21, #0x28]
 0xbb40: ldr    x9, [x22]
 0xbb44: cmp    x8, x9
 0xbb48: b.ne   #0xbbcc
 0xbb4c: mov    w0, w20
 0xbb50: ldr    x23, [sp, #0xb0]
 0xbb54: ldp    x29, x30, [sp, #0xe0]
 0xbb58: ldp    x20, x19, [sp, #0xd0]
 0xbb5c: ldp    x22, x21, [sp, #0xc0]
 0xbb60: add    sp, sp, #0xf0
 0xbb64: ret    
 0xbb68: bl     #0x2348 ; <co_thread_get>
 0xbb6c: cbnz   x0, #0xbbd0
 0xbb70: adrp   x4, #0x1a000
 0xbb74: adrp   x5, #0x1c000
 0xbb78: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbb7c: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xbb80: mov    w0, #0x51
 0xbb84: mov    w6, #0xc2
 0xbb88: add    x2, sp, #0x28
 0xbb8c: mov    w3, #0x80
 0xbb90: mov    w1, wzr
 0xbb94: bl     #0x2368 ; <duss_log_gen_head>
 0xbb98: cbz    w0, #0xbc58
 0xbb9c: adrp   x3, #0x1a000
 0xbba0: adrp   x4, #0x1a000
 0xbba4: adrp   x5, #0x1a000
 0xbba8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xbbac: add    x4, x4, #0x5c0 ; "ops"
 0xbbb0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbbb4: mov    w0, #0x51
 0xbbb8: mov    w6, #0xc2
 0xbbbc: add    x2, sp, #0x28
 0xbbc0: mov    w1, wzr
 0xbbc4: bl     #0x2378 ; <duss_log_print>
 0xbbc8: b      #0xbc58
 0xbbcc: bl     #0x23d8 ; <__stack_chk_fail>
 0xbbd0: adrp   x8, #0x1a000
 0xbbd4: str    wzr, [sp, #0x1c]
 0xbbd8: add    x8, x8, #0x440 ; =0x1a440
 0xbbdc: add    x1, sp, #0x20
 0xbbe0: add    x2, sp, #0x1c
 0xbbe4: str    x8, [sp, #0x20]
 0xbbe8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xbbec: adrp   x19, #0x1a000
 0xbbf0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbbf4: adrp   x5, #0x1c000
 0xbbf8: mov    w20, #0xc2
 0xbbfc: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xbc00: mov    w0, #0x51
 0xbc04: add    x2, sp, #0x28
 0xbc08: mov    w3, #0x80
 0xbc0c: mov    w1, wzr
 0xbc10: mov    x4, x19
 0xbc14: mov    w6, w20
 0xbc18: bl     #0x2368 ; <duss_log_gen_head>
 0xbc1c: cbz    w0, #0xbc58
 0xbc20: ldr    x5, [sp, #0x20]
 0xbc24: adrp   x3, #0x1a000
 0xbc28: ldr    w6, [sp, #0x1c]
 0xbc2c: adrp   x4, #0x1a000
 0xbc30: adrp   x7, #0x1a000
 0xbc34: str    w20, [sp, #8]
 0xbc38: mov    w1, wzr
 0xbc3c: str    x19, [sp]
 0xbc40: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xbc44: add    x4, x4, #0x441 ; "co"
 0xbc48: mov    w0, #0x51
 0xbc4c: add    x7, x7, #0x5c0 ; "ops"
 0xbc50: add    x2, sp, #0x28
 0xbc54: bl     #0x2378 ; <duss_log_print>
 0xbc58: adrp   x4, #0x1a000
 0xbc5c: adrp   x5, #0x1c000
 0xbc60: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbc64: add    x5, x5, #0x16f ; "proresraw_venc_eng_destroy"
 0xbc68: mov    w0, #0x51
 0xbc6c: mov    w6, #0xc2
 0xbc70: add    x2, sp, #0x28
 0xbc74: mov    w3, #0x80
 0xbc78: mov    w1, wzr
 0xbc7c: bl     #0x2368 ; <duss_log_gen_head>
 0xbc80: cbz    w0, #0xbc9c
 0xbc84: adrp   x3, #0x1a000
 0xbc88: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xbc8c: mov    w0, #0x51
 0xbc90: add    x2, sp, #0x28
 0xbc94: mov    w1, wzr
 0xbc98: bl     #0x2378 ; <duss_log_print>
 0xbc9c: adrp   x0, #0x1a000
 0xbca0: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xbca4: bl     #0x23e8 ; <log_to_kmsg>
 0xbca8: adrp   x0, #0x1a000
 0xbcac: add    x0, x0, #0x57f ; "Camera:	"
 0xbcb0: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xbcb4: bl     #0x2408 ; <is_running_in_cam_sil>
 0xbcb8: tbz    w0, #0, #0xbcc8
 0xbcbc: mov    x0, xzr
 0xbcc0: bl     #0x2418 ; <fflush>
 0xbcc4: bl     #0x2428 ; <abort>
 0xbcc8: mov    w0, #1
 0xbccc: bl     #0x2438 ; <exit>
 0xbcd0: sub    sp, sp, #0x130
 0xbcd4: stp    x28, x27, [sp, #0xd0]
 0xbcd8: stp    x26, x25, [sp, #0xe0]
 0xbcdc: stp    x24, x23, [sp, #0xf0]
 0xbce0: stp    x22, x21, [sp, #0x100]
 0xbce4: stp    x20, x19, [sp, #0x110]
 0xbce8: stp    x29, x30, [sp, #0x120]
 0xbcec: add    x29, sp, #0x120
 0xbcf0: mrs    x25, tpidr_el0
 0xbcf4: mov    x19, x2
 0xbcf8: ldr    x8, [x25, #0x28]
 0xbcfc: mov    x20, x0
 0xbd00: adrp   x0, #0x30000
 0xbd04: adrp   x2, #0x1a000
 0xbd08: mov    x21, x1
 0xbd0c: add    x26, sp, #0x20
 0xbd10: add    x0, x0, #8 ; =0x30008
 0xbd14: mov    w1, #5
 0xbd18: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xbd1c: str    x8, [x26]
 0xbd20: str    xzr, [sp, #0x40]
 0xbd24: bl     #0x2338 ; <log_mgr_check>
 0xbd28: tbz    w0, #0, #0xbe60
 0xbd2c: bl     #0x2348 ; <co_thread_get>
 0xbd30: cbz    x0, #0xbe14
 0xbd34: adrp   x8, #0x1a000
 0xbd38: str    wzr, [sp, #0x3c]
 0xbd3c: add    x8, x8, #0x440 ; =0x1a440
 0xbd40: add    x1, sp, #0x30
 0xbd44: add    x2, sp, #0x3c
 0xbd48: str    x8, [sp, #0x30]
 0xbd4c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xbd50: adrp   x4, #0x1a000
 0xbd54: adrp   x5, #0x1c000
 0xbd58: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbd5c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xbd60: mov    w0, #0x51
 0xbd64: mov    w6, #0x40a
 0xbd68: mov    w1, #3
 0xbd6c: add    x2, sp, #0x48
 0xbd70: mov    w3, #0x80
 0xbd74: bl     #0x2368 ; <duss_log_gen_head>
 0xbd78: cbz    w0, #0xbe60
 0xbd7c: ldr    x6, [sp, #0x30]
 0xbd80: adrp   x3, #0x1c000
 0xbd84: ldr    w7, [sp, #0x3c]
 0xbd88: adrp   x4, #0x1a000
 0xbd8c: adrp   x5, #0x1a000
 0xbd90: add    x3, x3, #0x351 ; "%s: %s(%s_%x): create_encoded_buffer_allocator
"
 0xbd94: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xbd98: add    x5, x5, #0x441 ; "co"
 0xbd9c: mov    w0, #0x51
 0xbda0: mov    w1, #3
 0xbda4: add    x2, sp, #0x48
 0xbda8: bl     #0x2378 ; <duss_log_print>
 0xbdac: cbnz   x20, #0xbe64
 0xbdb0: bl     #0x2348 ; <co_thread_get>
 0xbdb4: cbnz   x0, #0xcfe4
 0xbdb8: adrp   x4, #0x1a000
 0xbdbc: adrp   x5, #0x1c000
 0xbdc0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbdc4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xbdc8: mov    w0, #0x51
 0xbdcc: mov    w6, #0x40c
 0xbdd0: add    x2, sp, #0x48
 0xbdd4: mov    w3, #0x80
 0xbdd8: mov    w1, wzr
 0xbddc: bl     #0x2368 ; <duss_log_gen_head>
 0xbde0: cbz    w0, #0xd06c
 0xbde4: adrp   x3, #0x1a000
 0xbde8: adrp   x4, #0x1a000
 0xbdec: adrp   x5, #0x1a000
 0xbdf0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xbdf4: add    x4, x4, #0x5c0 ; "ops"
 0xbdf8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbdfc: mov    w0, #0x51
 0xbe00: mov    w6, #0x40c
 0xbe04: add    x2, sp, #0x48
 0xbe08: mov    w1, wzr
 0xbe0c: bl     #0x2378 ; <duss_log_print>
 0xbe10: b      #0xd06c
 0xbe14: adrp   x4, #0x1a000
 0xbe18: adrp   x5, #0x1c000
 0xbe1c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbe20: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xbe24: mov    w0, #0x51
 0xbe28: mov    w6, #0x40a
 0xbe2c: mov    w1, #3
 0xbe30: add    x2, sp, #0x48
 0xbe34: mov    w3, #0x80
 0xbe38: bl     #0x2368 ; <duss_log_gen_head>
 0xbe3c: cbz    w0, #0xbe60
 0xbe40: adrp   x3, #0x1c000
 0xbe44: adrp   x4, #0x1a000
 0xbe48: add    x3, x3, #0x381 ; "%s: create_encoded_buffer_allocator
"
 0xbe4c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xbe50: mov    w0, #0x51
 0xbe54: mov    w1, #3
 0xbe58: add    x2, sp, #0x48
 0xbe5c: bl     #0x2378 ; <duss_log_print>
 0xbe60: cbz    x20, #0xbdb0
 0xbe64: cbz    x21, #0xcd58
 0xbe68: cbz    x19, #0xcdbc
 0xbe6c: ldr    w8, [x21]
 0xbe70: cbz    w8, #0xce20
 0xbe74: str    w8, [x20, #0x3c0]
 0xbe78: ldr    w8, [x21, #8]
 0xbe7c: ldr    w9, [x21]
 0xbe80: cmp    w8, w9
 0xbe84: b.hi   #0xce84
 0xbe88: mov    w0, #0x13
 0xbe8c: bl     #0x2658 ; <thread_priority_cam_to_duss>
 0xbe90: mov    w1, w0
 0xbe94: add    x2, sp, #0x3c
 0xbe98: mov    x0, xzr
 0xbe9c: bl     #0x2668 ; <duss_osal_task_set_priority>
 0xbea0: bl     #0x24d8 ; <duss_osal_get_exec_obj_id>
 0xbea4: mov    w23, w0
 0xbea8: ldr    x0, [x20, #0x490]
 0xbeac: tbnz   w23, #0x1f, #0xc08c
 0xbeb0: cbz    x0, #0xbec4
 0xbeb4: ldrh   w1, [x20, #0x49c]
 0xbeb8: cbz    w1, #0xbec4
 0xbebc: mov    w2, w23
 0xbec0: bl     #0x24e8 ; <perf_trace_coroutine_slice_begin>
 0xbec4: add    x2, sp, #0x40
 0xbec8: mov    x0, x20
 0xbecc: mov    x1, x21
 0xbed0: bl     #0x10390
 0xbed4: ldr    x8, [x20, #0x490]
 0xbed8: mov    w22, w0
 0xbedc: cbz    x8, #0xbef4
 0xbee0: ldrh   w1, [x20, #0x49c]
 0xbee4: cbz    w1, #0xbef4
 0xbee8: mov    x0, x8
 0xbeec: mov    w2, w23
 0xbef0: bl     #0x24f8 ; <perf_trace_coroutine_slice_end>
 0xbef4: cbz    w22, #0xc0cc
 0xbef8: adrp   x0, #0x30000
 0xbefc: adrp   x2, #0x1a000
 0xbf00: add    x0, x0, #8 ; =0x30008
 0xbf04: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xbf08: mov    w1, #1
 0xbf0c: bl     #0x2338 ; <log_mgr_check>
 0xbf10: tbz    w0, #0, #0xc084
 0xbf14: bl     #0x2348 ; <co_thread_get>
 0xbf18: cbz    x0, #0xbfe8
 0xbf1c: adrp   x8, #0x1a000
 0xbf20: str    wzr, [sp, #0x2c]
 0xbf24: add    x8, x8, #0x440 ; =0x1a440
 0xbf28: add    x1, sp, #0x30
 0xbf2c: add    x2, sp, #0x2c
 0xbf30: str    x8, [sp, #0x30]
 0xbf34: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xbf38: adrp   x4, #0x1a000
 0xbf3c: adrp   x5, #0x1c000
 0xbf40: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbf44: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xbf48: mov    w0, #0x51
 0xbf4c: mov    w6, #0x421
 0xbf50: mov    w1, #1
 0xbf54: add    x2, sp, #0x48
 0xbf58: mov    w3, #0x80
 0xbf5c: bl     #0x2368 ; <duss_log_gen_head>
 0xbf60: cbz    w0, #0xbf88
 0xbf64: adrp   x3, #0x1a000
 0xbf68: adrp   x4, #0x1a000
 0xbf6c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xbf70: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbf74: mov    w0, #0x51
 0xbf78: mov    w5, #0x421
 0xbf7c: mov    w1, #1
 0xbf80: add    x2, sp, #0x48
 0xbf84: bl     #0x2378 ; <duss_log_print>
 0xbf88: adrp   x4, #0x1a000
 0xbf8c: adrp   x5, #0x1c000
 0xbf90: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbf94: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xbf98: mov    w0, #0x51
 0xbf9c: mov    w6, #0x421
 0xbfa0: mov    w1, #1
 0xbfa4: add    x2, sp, #0x48
 0xbfa8: mov    w3, #0x80
 0xbfac: bl     #0x2368 ; <duss_log_gen_head>
 0xbfb0: cbz    w0, #0xc084
 0xbfb4: ldr    x6, [sp, #0x30]
 0xbfb8: adrp   x3, #0x1c000
 0xbfbc: ldr    w7, [sp, #0x2c]
 0xbfc0: adrp   x4, #0x1a000
 0xbfc4: adrp   x5, #0x1a000
 0xbfc8: add    x3, x3, #0x43f ; "%s: %s(%s_%x): Failed to create buffer allocator, out of memory?
"
 0xbfcc: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xbfd0: add    x5, x5, #0x441 ; "co"
 0xbfd4: mov    w0, #0x51
 0xbfd8: mov    w1, #1
 0xbfdc: add    x2, sp, #0x48
 0xbfe0: bl     #0x2378 ; <duss_log_print>
 0xbfe4: b      #0xc084
 0xbfe8: adrp   x4, #0x1a000
 0xbfec: adrp   x5, #0x1c000
 0xbff0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xbff4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xbff8: mov    w0, #0x51
 0xbffc: mov    w6, #0x421
 0xc000: mov    w1, #1
 0xc004: add    x2, sp, #0x48
 0xc008: mov    w3, #0x80
 0xc00c: bl     #0x2368 ; <duss_log_gen_head>
 0xc010: cbz    w0, #0xc038
 0xc014: adrp   x3, #0x1a000
 0xc018: adrp   x4, #0x1a000
 0xc01c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc020: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc024: mov    w0, #0x51
 0xc028: mov    w5, #0x421
 0xc02c: mov    w1, #1
 0xc030: add    x2, sp, #0x48
 0xc034: bl     #0x2378 ; <duss_log_print>
 0xc038: adrp   x4, #0x1a000
 0xc03c: adrp   x5, #0x1c000
 0xc040: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc044: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc048: mov    w0, #0x51
 0xc04c: mov    w6, #0x421
 0xc050: mov    w1, #1
 0xc054: add    x2, sp, #0x48
 0xc058: mov    w3, #0x80
 0xc05c: bl     #0x2368 ; <duss_log_gen_head>
 0xc060: cbz    w0, #0xc084
 0xc064: adrp   x3, #0x1c000
 0xc068: adrp   x4, #0x1a000
 0xc06c: add    x3, x3, #0x481 ; "%s: Failed to create buffer allocator, out of memory?
"
 0xc070: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xc074: mov    w0, #0x51
 0xc078: mov    w1, #1
 0xc07c: add    x2, sp, #0x48
 0xc080: bl     #0x2378 ; <duss_log_print>
 0xc084: mov    w21, #-0x3ef
 0xc088: b      #0xcbf4
 0xc08c: cbz    x0, #0xc09c
 0xc090: ldrh   w1, [x20, #0x49c]
 0xc094: cbz    w1, #0xc09c
 0xc098: bl     #0x25a8 ; <perf_trace_slice_begin>
 0xc09c: add    x2, sp, #0x40
 0xc0a0: mov    x0, x20
 0xc0a4: mov    x1, x21
 0xc0a8: bl     #0x10390
 0xc0ac: ldr    x8, [x20, #0x490]
 0xc0b0: mov    w22, w0
 0xc0b4: cbz    x8, #0xbef4
 0xc0b8: ldrh   w1, [x20, #0x49c]
 0xc0bc: cbz    w1, #0xbef4
 0xc0c0: mov    x0, x8
 0xc0c4: bl     #0x25b8 ; <perf_trace_slice_end>
 0xc0c8: cbnz   w22, #0xbef8
 0xc0cc: ldr    w1, [sp, #0x3c]
 0xc0d0: add    x2, sp, #0x3c
 0xc0d4: mov    x0, xzr
 0xc0d8: bl     #0x2668 ; <duss_osal_task_set_priority>
 0xc0dc: ldr    x0, [sp, #0x40]
 0xc0e0: add    x22, x20, #0x438 ; =0x1a438
 0xc0e4: mov    x1, x22
 0xc0e8: bl     #0x2678 ; <cam_encoded_buffer_allocator_total_result_buffer_count_get>
 0xc0ec: cbnz   w0, #0xd274
 0xc0f0: ldr    w8, [x22]
 0xc0f4: cbz    w8, #0xd2d8
 0xc0f8: ldr    w9, [x21, #8]
 0xc0fc: ldr    x10, [x20, #0x418]
 0xc100: str    w8, [x20, #0x428]
 0xc104: str    w9, [x20, #0x45c]
 0xc108: cbnz   x10, #0xd33c
 0xc10c: adrp   x1, #0x1a000
 0xc110: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc114: mov    w2, #0x42d
 0xc118: lsl    x0, x8, #4
 0xc11c: bl     #0x22c8 ; <cam_malloc_internal>
 0xc120: str    x0, [x20, #0x418]
 0xc124: cbz    x0, #0xc234
 0xc128: ldr    w8, [x20, #0x428]
 0xc12c: mov    w1, wzr
 0xc130: lsl    x2, x8, #4
 0xc134: bl     #0x22d8 ; <memset>
 0xc138: ldr    x8, [x20, #0x420]
 0xc13c: cbnz   x8, #0xd4f4
 0xc140: ldr    w2, [x20, #0x428]
 0xc144: add    x23, x20, #0x420 ; =0x1a420
 0xc148: adrp   x0, #0x1c000
 0xc14c: add    x0, x0, #0x5ab ; "encoding_request_pool"
 0xc150: mov    w1, #8
 0xc154: mov    x3, x23
 0xc158: bl     #0x2688 ; <buffer_queue_create>
 0xc15c: mov    w21, w0
 0xc160: cbz    w21, #0xc324
 0xc164: adrp   x0, #0x30000
 0xc168: adrp   x2, #0x1a000
 0xc16c: add    x0, x0, #8 ; =0x30008
 0xc170: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xc174: mov    w1, #1
 0xc178: bl     #0x2338 ; <log_mgr_check>
 0xc17c: tbz    w0, #0, #0xcac8
 0xc180: bl     #0x2348 ; <co_thread_get>
 0xc184: cbz    x0, #0xc554
 0xc188: adrp   x8, #0x1a000
 0xc18c: str    wzr, [sp, #0x2c]
 0xc190: add    x8, x8, #0x440 ; =0x1a440
 0xc194: add    x1, sp, #0x30
 0xc198: add    x2, sp, #0x2c
 0xc19c: str    x8, [sp, #0x30]
 0xc1a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xc1a4: adrp   x4, #0x1a000
 0xc1a8: adrp   x5, #0x1c000
 0xc1ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc1b0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc1b4: mov    w0, #0x51
 0xc1b8: mov    w6, #0x438
 0xc1bc: mov    w1, #1
 0xc1c0: add    x2, sp, #0x48
 0xc1c4: mov    w3, #0x80
 0xc1c8: bl     #0x2368 ; <duss_log_gen_head>
 0xc1cc: cbz    w0, #0xc1f4
 0xc1d0: adrp   x3, #0x1a000
 0xc1d4: adrp   x4, #0x1a000
 0xc1d8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc1dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc1e0: mov    w0, #0x51
 0xc1e4: mov    w5, #0x438
 0xc1e8: mov    w1, #1
 0xc1ec: add    x2, sp, #0x48
 0xc1f0: bl     #0x2378 ; <duss_log_print>
 0xc1f4: adrp   x4, #0x1a000
 0xc1f8: adrp   x5, #0x1c000
 0xc1fc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc200: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc204: mov    w0, #0x51
 0xc208: mov    w6, #0x438
 0xc20c: mov    w1, #1
 0xc210: add    x2, sp, #0x48
 0xc214: mov    w3, #0x80
 0xc218: bl     #0x2368 ; <duss_log_gen_head>
 0xc21c: cbz    w0, #0xcac8
 0xc220: ldr    x6, [sp, #0x30]
 0xc224: adrp   x3, #0x1c000
 0xc228: ldr    w7, [sp, #0x2c]
 0xc22c: add    x3, x3, #0x5c1 ; "%s: %s(%s_%x): Failed to create encoding request pool with error %d
"
 0xc230: b      #0xc478
 0xc234: adrp   x0, #0x30000
 0xc238: adrp   x2, #0x1a000
 0xc23c: add    x0, x0, #8 ; =0x30008
 0xc240: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xc244: mov    w1, #1
 0xc248: bl     #0x2338 ; <log_mgr_check>
 0xc24c: tbz    w0, #0, #0xcac4
 0xc250: bl     #0x2348 ; <co_thread_get>
 0xc254: cbz    x0, #0xc5dc
 0xc258: adrp   x8, #0x1a000
 0xc25c: str    wzr, [sp, #0x2c]
 0xc260: add    x8, x8, #0x440 ; =0x1a440
 0xc264: add    x1, sp, #0x30
 0xc268: add    x2, sp, #0x2c
 0xc26c: str    x8, [sp, #0x30]
 0xc270: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xc274: adrp   x4, #0x1a000
 0xc278: adrp   x5, #0x1c000
 0xc27c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc280: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc284: mov    w0, #0x51
 0xc288: mov    w6, #0x42f
 0xc28c: mov    w1, #1
 0xc290: add    x2, sp, #0x48
 0xc294: mov    w3, #0x80
 0xc298: bl     #0x2368 ; <duss_log_gen_head>
 0xc29c: cbz    w0, #0xc2c4
 0xc2a0: adrp   x3, #0x1a000
 0xc2a4: adrp   x4, #0x1a000
 0xc2a8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc2ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc2b0: mov    w0, #0x51
 0xc2b4: mov    w5, #0x42f
 0xc2b8: mov    w1, #1
 0xc2bc: add    x2, sp, #0x48
 0xc2c0: bl     #0x2378 ; <duss_log_print>
 0xc2c4: adrp   x4, #0x1a000
 0xc2c8: adrp   x5, #0x1c000
 0xc2cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc2d0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc2d4: mov    w0, #0x51
 0xc2d8: mov    w6, #0x42f
 0xc2dc: mov    w1, #1
 0xc2e0: add    x2, sp, #0x48
 0xc2e4: mov    w3, #0x80
 0xc2e8: bl     #0x2368 ; <duss_log_gen_head>
 0xc2ec: cbz    w0, #0xcac4
 0xc2f0: ldr    x6, [sp, #0x30]
 0xc2f4: adrp   x3, #0x1c000
 0xc2f8: ldr    w7, [sp, #0x2c]
 0xc2fc: add    x3, x3, #0x503 ; "%s: %s(%s_%x): Failed to allocate memory for encoding request array
"
 0xc300: adrp   x4, #0x1a000
 0xc304: adrp   x5, #0x1a000
 0xc308: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xc30c: add    x5, x5, #0x441 ; "co"
 0xc310: mov    w0, #0x51
 0xc314: mov    w1, #1
 0xc318: add    x2, sp, #0x48
 0xc31c: bl     #0x2378 ; <duss_log_print>
 0xc320: b      #0xcac4
 0xc324: ldr    x0, [x23]
 0xc328: cbz    x0, #0xd8f0
 0xc32c: ldr    w8, [x20, #0x428]
 0xc330: cbz    w8, #0xc384
 0xc334: ldr    x8, [x20, #0x418]
 0xc338: add    x1, sp, #0x48
 0xc33c: str    x8, [sp, #0x48]
 0xc340: bl     #0x2588 ; <buffer_queue_enqueue>
 0xc344: ldr    w8, [x20, #0x428]
 0xc348: cmp    w8, #2
 0xc34c: b.lo   #0xc384
 0xc350: mov    w21, #1
 0xc354: mov    w23, #0x10
 0xc358: ldr    x8, [x20, #0x418]
 0xc35c: add    x1, sp, #0x48
 0xc360: ldr    x0, [x20, #0x420]
 0xc364: add    x8, x8, x23
 0xc368: str    x8, [sp, #0x48]
 0xc36c: bl     #0x2588 ; <buffer_queue_enqueue>
 0xc370: ldr    w8, [x20, #0x428]
 0xc374: add    x21, x21, #1
 0xc378: add    x23, x23, #0x10 ; =0x1a010
 0xc37c: cmp    x21, x8
 0xc380: b.lo   #0xc358
 0xc384: ldr    x8, [x20, #0x430]
 0xc388: cbnz   x8, #0xd954
 0xc38c: ldr    w2, [x22]
 0xc390: adrp   x0, #0x1c000
 0xc394: add    x3, x20, #0x430 ; =0x1a430
 0xc398: add    x0, x0, #0x666 ; "encoding_request_q"
 0xc39c: mov    w1, #8
 0xc3a0: bl     #0x2688 ; <buffer_queue_create>
 0xc3a4: mov    w21, w0
 0xc3a8: cbz    w21, #0xc4a8
 0xc3ac: adrp   x0, #0x30000
 0xc3b0: adrp   x2, #0x1a000
 0xc3b4: add    x0, x0, #8 ; =0x30008
 0xc3b8: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xc3bc: mov    w1, #1
 0xc3c0: bl     #0x2338 ; <log_mgr_check>
 0xc3c4: tbz    w0, #0, #0xcac8
 0xc3c8: bl     #0x2348 ; <co_thread_get>
 0xc3cc: cbz    x0, #0xc74c
 0xc3d0: adrp   x8, #0x1a000
 0xc3d4: str    wzr, [sp, #0x2c]
 0xc3d8: add    x8, x8, #0x440 ; =0x1a440
 0xc3dc: add    x1, sp, #0x30
 0xc3e0: add    x2, sp, #0x2c
 0xc3e4: str    x8, [sp, #0x30]
 0xc3e8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xc3ec: adrp   x4, #0x1a000
 0xc3f0: adrp   x5, #0x1c000
 0xc3f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc3f8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc3fc: mov    w0, #0x51
 0xc400: mov    w6, #0x445
 0xc404: mov    w1, #1
 0xc408: add    x2, sp, #0x48
 0xc40c: mov    w3, #0x80
 0xc410: bl     #0x2368 ; <duss_log_gen_head>
 0xc414: cbz    w0, #0xc43c
 0xc418: adrp   x3, #0x1a000
 0xc41c: adrp   x4, #0x1a000
 0xc420: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc424: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc428: mov    w0, #0x51
 0xc42c: mov    w5, #0x445
 0xc430: mov    w1, #1
 0xc434: add    x2, sp, #0x48
 0xc438: bl     #0x2378 ; <duss_log_print>
 0xc43c: adrp   x4, #0x1a000
 0xc440: adrp   x5, #0x1c000
 0xc444: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc448: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc44c: mov    w0, #0x51
 0xc450: mov    w6, #0x445
 0xc454: mov    w1, #1
 0xc458: add    x2, sp, #0x48
 0xc45c: mov    w3, #0x80
 0xc460: bl     #0x2368 ; <duss_log_gen_head>
 0xc464: cbz    w0, #0xcac8
 0xc468: ldr    x6, [sp, #0x30]
 0xc46c: adrp   x3, #0x1c000
 0xc470: ldr    w7, [sp, #0x2c]
 0xc474: add    x3, x3, #0x679 ; "%s: %s(%s_%x): Failed to create encoding_request queue with error %d
"
 0xc478: adrp   x4, #0x1a000
 0xc47c: str    w21, [sp]
 0xc480: adrp   x5, #0x1a000
 0xc484: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xc488: add    x5, x5, #0x441 ; "co"
 0xc48c: mov    w0, #0x51
 0xc490: mov    w1, #1
 0xc494: add    x2, sp, #0x48
 0xc498: bl     #0x2378 ; <duss_log_print>
 0xc49c: ldr    x0, [x20, #0x3f8]
 0xc4a0: cbnz   x0, #0xcad0
 0xc4a4: b      #0xcb00
 0xc4a8: ldr    w8, [x20, #0x400]
 0xc4ac: cbnz   w8, #0xdb00
 0xc4b0: ldr    w8, [x20, #0xc0]
 0xc4b4: cmp    w8, #0
 0xc4b8: b.le   #0xdb64
 0xc4bc: ldr    x9, [x20, #0x3f0]
 0xc4c0: str    w8, [x20, #0x400]
 0xc4c4: cbnz   x9, #0xdbc8
 0xc4c8: adrp   x1, #0x1a000
 0xc4cc: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc4d0: mov    w2, #0x44d
 0xc4d4: lsl    x0, x8, #4
 0xc4d8: bl     #0x22c8 ; <cam_malloc_internal>
 0xc4dc: str    x0, [x20, #0x3f0]
 0xc4e0: cbz    x0, #0xc67c
 0xc4e4: ldr    w8, [x20, #0x400]
 0xc4e8: mov    w1, wzr
 0xc4ec: lsl    x2, x8, #4
 0xc4f0: bl     #0x22d8 ; <memset>
 0xc4f4: ldr    w8, [x20, #0x400]
 0xc4f8: cbz    w8, #0xc7f8
 0xc4fc: adrp   x23, #0x1a000
 0xc500: mov    w24, wzr
 0xc504: mov    w27, #8
 0xc508: mov    w22, #0x456
 0xc50c: add    x23, x23, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc510: ldr    x8, [x20, #0x3f0]
 0xc514: add    x2, x8, x27
 0xc518: ldr    x8, [x2]
 0xc51c: cbnz   x8, #0xd558
 0xc520: ldr    w0, [x20, #0x3e8]
 0xc524: mov    w1, #0x1f
 0xc528: mov    x3, x23
 0xc52c: mov    w4, w22
 0xc530: bl     #0x2698 ; <vmem_alloc_dbg>
 0xc534: mov    w21, w0
 0xc538: cbnz   w21, #0xc8f4
 0xc53c: ldr    w2, [x20, #0x400]
 0xc540: add    w24, w24, #1
 0xc544: add    x27, x27, #0x10 ; =0x1a010
 0xc548: cmp    w24, w2
 0xc54c: b.lo   #0xc510
 0xc550: b      #0xc7fc
 0xc554: adrp   x4, #0x1a000
 0xc558: adrp   x5, #0x1c000
 0xc55c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc560: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc564: mov    w0, #0x51
 0xc568: mov    w6, #0x438
 0xc56c: mov    w1, #1
 0xc570: add    x2, sp, #0x48
 0xc574: mov    w3, #0x80
 0xc578: bl     #0x2368 ; <duss_log_gen_head>
 0xc57c: cbz    w0, #0xc5a4
 0xc580: adrp   x3, #0x1a000
 0xc584: adrp   x4, #0x1a000
 0xc588: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc58c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc590: mov    w0, #0x51
 0xc594: mov    w5, #0x438
 0xc598: mov    w1, #1
 0xc59c: add    x2, sp, #0x48
 0xc5a0: bl     #0x2378 ; <duss_log_print>
 0xc5a4: adrp   x4, #0x1a000
 0xc5a8: adrp   x5, #0x1c000
 0xc5ac: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc5b0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc5b4: mov    w0, #0x51
 0xc5b8: mov    w6, #0x438
 0xc5bc: mov    w1, #1
 0xc5c0: add    x2, sp, #0x48
 0xc5c4: mov    w3, #0x80
 0xc5c8: bl     #0x2368 ; <duss_log_gen_head>
 0xc5cc: cbz    w0, #0xcac8
 0xc5d0: adrp   x3, #0x1c000
 0xc5d4: add    x3, x3, #0x606 ; "%s: Failed to create encoding request pool with error %d
"
 0xc5d8: b      #0xc7d0
 0xc5dc: adrp   x4, #0x1a000
 0xc5e0: adrp   x5, #0x1c000
 0xc5e4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc5e8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc5ec: mov    w0, #0x51
 0xc5f0: mov    w6, #0x42f
 0xc5f4: mov    w1, #1
 0xc5f8: add    x2, sp, #0x48
 0xc5fc: mov    w3, #0x80
 0xc600: bl     #0x2368 ; <duss_log_gen_head>
 0xc604: cbz    w0, #0xc62c
 0xc608: adrp   x3, #0x1a000
 0xc60c: adrp   x4, #0x1a000
 0xc610: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc614: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc618: mov    w0, #0x51
 0xc61c: mov    w5, #0x42f
 0xc620: mov    w1, #1
 0xc624: add    x2, sp, #0x48
 0xc628: bl     #0x2378 ; <duss_log_print>
 0xc62c: adrp   x4, #0x1a000
 0xc630: adrp   x5, #0x1c000
 0xc634: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc638: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc63c: mov    w0, #0x51
 0xc640: mov    w6, #0x42f
 0xc644: mov    w1, #1
 0xc648: add    x2, sp, #0x48
 0xc64c: mov    w3, #0x80
 0xc650: bl     #0x2368 ; <duss_log_gen_head>
 0xc654: cbz    w0, #0xcac4
 0xc658: adrp   x3, #0x1c000
 0xc65c: add    x3, x3, #0x548 ; "%s: Failed to allocate memory for encoding request array
"
 0xc660: adrp   x4, #0x1a000
 0xc664: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xc668: mov    w0, #0x51
 0xc66c: mov    w1, #1
 0xc670: add    x2, sp, #0x48
 0xc674: bl     #0x2378 ; <duss_log_print>
 0xc678: b      #0xcac4
 0xc67c: adrp   x0, #0x30000
 0xc680: adrp   x2, #0x1a000
 0xc684: add    x0, x0, #8 ; =0x30008
 0xc688: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xc68c: mov    w1, #1
 0xc690: bl     #0x2338 ; <log_mgr_check>
 0xc694: tbz    w0, #0, #0xcac4
 0xc698: bl     #0x2348 ; <co_thread_get>
 0xc69c: cbz    x0, #0xca3c
 0xc6a0: adrp   x8, #0x1a000
 0xc6a4: str    wzr, [sp, #0x2c]
 0xc6a8: add    x8, x8, #0x440 ; =0x1a440
 0xc6ac: add    x1, sp, #0x30
 0xc6b0: add    x2, sp, #0x2c
 0xc6b4: str    x8, [sp, #0x30]
 0xc6b8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xc6bc: adrp   x4, #0x1a000
 0xc6c0: adrp   x5, #0x1c000
 0xc6c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc6c8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc6cc: mov    w0, #0x51
 0xc6d0: mov    w6, #0x44f
 0xc6d4: mov    w1, #1
 0xc6d8: add    x2, sp, #0x48
 0xc6dc: mov    w3, #0x80
 0xc6e0: bl     #0x2368 ; <duss_log_gen_head>
 0xc6e4: cbz    w0, #0xc70c
 0xc6e8: adrp   x3, #0x1a000
 0xc6ec: adrp   x4, #0x1a000
 0xc6f0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc6f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc6f8: mov    w0, #0x51
 0xc6fc: mov    w5, #0x44f
 0xc700: mov    w1, #1
 0xc704: add    x2, sp, #0x48
 0xc708: bl     #0x2378 ; <duss_log_print>
 0xc70c: adrp   x4, #0x1a000
 0xc710: adrp   x5, #0x1c000
 0xc714: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc718: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc71c: mov    w0, #0x51
 0xc720: mov    w6, #0x44f
 0xc724: mov    w1, #1
 0xc728: add    x2, sp, #0x48
 0xc72c: mov    w3, #0x80
 0xc730: bl     #0x2368 ; <duss_log_gen_head>
 0xc734: cbz    w0, #0xcac4
 0xc738: ldr    x6, [sp, #0x30]
 0xc73c: adrp   x3, #0x1c000
 0xc740: ldr    w7, [sp, #0x2c]
 0xc744: add    x3, x3, #0x75c ; "%s: %s(%s_%x): Failed to allocate memory for ics buffer array
"
 0xc748: b      #0xc300
 0xc74c: adrp   x4, #0x1a000
 0xc750: adrp   x5, #0x1c000
 0xc754: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc758: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc75c: mov    w0, #0x51
 0xc760: mov    w6, #0x445
 0xc764: mov    w1, #1
 0xc768: add    x2, sp, #0x48
 0xc76c: mov    w3, #0x80
 0xc770: bl     #0x2368 ; <duss_log_gen_head>
 0xc774: cbz    w0, #0xc79c
 0xc778: adrp   x3, #0x1a000
 0xc77c: adrp   x4, #0x1a000
 0xc780: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc784: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc788: mov    w0, #0x51
 0xc78c: mov    w5, #0x445
 0xc790: mov    w1, #1
 0xc794: add    x2, sp, #0x48
 0xc798: bl     #0x2378 ; <duss_log_print>
 0xc79c: adrp   x4, #0x1a000
 0xc7a0: adrp   x5, #0x1c000
 0xc7a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc7a8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc7ac: mov    w0, #0x51
 0xc7b0: mov    w6, #0x445
 0xc7b4: mov    w1, #1
 0xc7b8: add    x2, sp, #0x48
 0xc7bc: mov    w3, #0x80
 0xc7c0: bl     #0x2368 ; <duss_log_gen_head>
 0xc7c4: cbz    w0, #0xcac8
 0xc7c8: adrp   x3, #0x1c000
 0xc7cc: add    x3, x3, #0x6bf ; "%s: Failed to create encoding_request queue with error %d
"
 0xc7d0: adrp   x4, #0x1a000
 0xc7d4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xc7d8: mov    w0, #0x51
 0xc7dc: mov    w1, #1
 0xc7e0: add    x2, sp, #0x48
 0xc7e4: mov    w5, w21
 0xc7e8: bl     #0x2378 ; <duss_log_print>
 0xc7ec: ldr    x0, [x20, #0x3f8]
 0xc7f0: cbnz   x0, #0xcad0
 0xc7f4: b      #0xcb00
 0xc7f8: mov    w2, wzr
 0xc7fc: ldr    x8, [x20, #0x3f8]
 0xc800: cbnz   x8, #0xde18
 0xc804: add    x22, x20, #0x3f8 ; =0x1a3f8
 0xc808: adrp   x0, #0x1c000
 0xc80c: add    x0, x0, #0x888 ; "ics_buffer_pool"
 0xc810: mov    w1, #8
 0xc814: mov    x3, x22
 0xc818: bl     #0x2688 ; <buffer_queue_create>
 0xc81c: mov    w21, w0
 0xc820: cbz    w21, #0xc9cc
 0xc824: adrp   x0, #0x30000
 0xc828: adrp   x2, #0x1a000
 0xc82c: add    x0, x0, #8 ; =0x30008
 0xc830: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xc834: mov    w1, #1
 0xc838: bl     #0x2338 ; <log_mgr_check>
 0xc83c: tbz    w0, #0, #0xcac8
 0xc840: bl     #0x2348 ; <co_thread_get>
 0xc844: cbz    x0, #0xcc28
 0xc848: adrp   x8, #0x1a000
 0xc84c: str    wzr, [sp, #0x2c]
 0xc850: add    x8, x8, #0x440 ; =0x1a440
 0xc854: add    x1, sp, #0x30
 0xc858: add    x2, sp, #0x2c
 0xc85c: str    x8, [sp, #0x30]
 0xc860: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xc864: adrp   x4, #0x1a000
 0xc868: adrp   x5, #0x1c000
 0xc86c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc870: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc874: mov    w0, #0x51
 0xc878: mov    w6, #0x461
 0xc87c: mov    w1, #1
 0xc880: add    x2, sp, #0x48
 0xc884: mov    w3, #0x80
 0xc888: bl     #0x2368 ; <duss_log_gen_head>
 0xc88c: cbz    w0, #0xc8b4
 0xc890: adrp   x3, #0x1a000
 0xc894: adrp   x4, #0x1a000
 0xc898: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc89c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc8a0: mov    w0, #0x51
 0xc8a4: mov    w5, #0x461
 0xc8a8: mov    w1, #1
 0xc8ac: add    x2, sp, #0x48
 0xc8b0: bl     #0x2378 ; <duss_log_print>
 0xc8b4: adrp   x4, #0x1a000
 0xc8b8: adrp   x5, #0x1c000
 0xc8bc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc8c0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc8c4: mov    w0, #0x51
 0xc8c8: mov    w6, #0x461
 0xc8cc: mov    w1, #1
 0xc8d0: add    x2, sp, #0x48
 0xc8d4: mov    w3, #0x80
 0xc8d8: bl     #0x2368 ; <duss_log_gen_head>
 0xc8dc: cbz    w0, #0xcac8
 0xc8e0: ldr    x6, [sp, #0x30]
 0xc8e4: adrp   x3, #0x1c000
 0xc8e8: ldr    w7, [sp, #0x2c]
 0xc8ec: add    x3, x3, #0x898 ; "%s: %s(%s_%x): Failed to create ics buffer pool with error %d
"
 0xc8f0: b      #0xc478
 0xc8f4: adrp   x0, #0x30000
 0xc8f8: adrp   x2, #0x1a000
 0xc8fc: add    x0, x0, #8 ; =0x30008
 0xc900: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xc904: mov    w1, #1
 0xc908: bl     #0x2338 ; <log_mgr_check>
 0xc90c: tbz    w0, #0, #0xcac8
 0xc910: bl     #0x2348 ; <co_thread_get>
 0xc914: cbz    x0, #0xccb0
 0xc918: adrp   x8, #0x1a000
 0xc91c: str    wzr, [sp, #0x2c]
 0xc920: add    x8, x8, #0x440 ; =0x1a440
 0xc924: add    x1, sp, #0x30
 0xc928: add    x2, sp, #0x2c
 0xc92c: str    x8, [sp, #0x30]
 0xc930: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xc934: adrp   x4, #0x1a000
 0xc938: adrp   x5, #0x1c000
 0xc93c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc940: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc944: mov    w0, #0x51
 0xc948: mov    w6, #0x458
 0xc94c: mov    w1, #1
 0xc950: add    x2, sp, #0x48
 0xc954: mov    w3, #0x80
 0xc958: bl     #0x2368 ; <duss_log_gen_head>
 0xc95c: cbz    w0, #0xc984
 0xc960: adrp   x3, #0x1a000
 0xc964: adrp   x4, #0x1a000
 0xc968: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xc96c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc970: mov    w0, #0x51
 0xc974: mov    w5, #0x458
 0xc978: mov    w1, #1
 0xc97c: add    x2, sp, #0x48
 0xc980: bl     #0x2378 ; <duss_log_print>
 0xc984: adrp   x4, #0x1a000
 0xc988: adrp   x5, #0x1c000
 0xc98c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xc990: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xc994: mov    w0, #0x51
 0xc998: mov    w6, #0x458
 0xc99c: mov    w1, #1
 0xc9a0: add    x2, sp, #0x48
 0xc9a4: mov    w3, #0x80
 0xc9a8: bl     #0x2368 ; <duss_log_gen_head>
 0xc9ac: cbz    w0, #0xcac8
 0xc9b0: ldr    x6, [sp, #0x30]
 0xc9b4: adrp   x3, #0x1c000
 0xc9b8: ldr    w7, [sp, #0x2c]
 0xc9bc: adrp   x4, #0x1a000
 0xc9c0: adrp   x5, #0x1a000
 0xc9c4: add    x3, x3, #0x7f4 ; "%s: %s(%s_%x): Failed to allocate ion memory for ics buffery
"
 0xc9c8: b      #0xc484
 0xc9cc: ldr    x0, [x22]
 0xc9d0: cbz    x0, #0xdf20
 0xc9d4: ldr    w8, [x20, #0x400]
 0xc9d8: cbz    w8, #0xca2c
 0xc9dc: ldr    x8, [x20, #0x3f0]
 0xc9e0: add    x1, sp, #0x48
 0xc9e4: str    x8, [sp, #0x48]
 0xc9e8: bl     #0x2588 ; <buffer_queue_enqueue>
 0xc9ec: ldr    w8, [x20, #0x400]
 0xc9f0: cmp    w8, #2
 0xc9f4: b.lo   #0xca2c
 0xc9f8: mov    w21, #1
 0xc9fc: mov    w22, #0x10
 0xca00: ldr    x8, [x20, #0x3f0]
 0xca04: add    x1, sp, #0x48
 0xca08: ldr    x0, [x20, #0x3f8]
 0xca0c: add    x8, x8, x22
 0xca10: str    x8, [sp, #0x48]
 0xca14: bl     #0x2588 ; <buffer_queue_enqueue>
 0xca18: ldr    w8, [x20, #0x400]
 0xca1c: add    x21, x21, #1
 0xca20: add    x22, x22, #0x10 ; =0x30010
 0xca24: cmp    x21, x8
 0xca28: b.lo   #0xca00
 0xca2c: ldr    x8, [sp, #0x40]
 0xca30: mov    w21, wzr
 0xca34: str    x8, [x19]
 0xca38: b      #0xcbf4
 0xca3c: adrp   x4, #0x1a000
 0xca40: adrp   x5, #0x1c000
 0xca44: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xca48: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xca4c: mov    w0, #0x51
 0xca50: mov    w6, #0x44f
 0xca54: mov    w1, #1
 0xca58: add    x2, sp, #0x48
 0xca5c: mov    w3, #0x80
 0xca60: bl     #0x2368 ; <duss_log_gen_head>
 0xca64: cbz    w0, #0xca8c
 0xca68: adrp   x3, #0x1a000
 0xca6c: adrp   x4, #0x1a000
 0xca70: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xca74: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xca78: mov    w0, #0x51
 0xca7c: mov    w5, #0x44f
 0xca80: mov    w1, #1
 0xca84: add    x2, sp, #0x48
 0xca88: bl     #0x2378 ; <duss_log_print>
 0xca8c: adrp   x4, #0x1a000
 0xca90: adrp   x5, #0x1c000
 0xca94: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xca98: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xca9c: mov    w0, #0x51
 0xcaa0: mov    w6, #0x44f
 0xcaa4: mov    w1, #1
 0xcaa8: add    x2, sp, #0x48
 0xcaac: mov    w3, #0x80
 0xcab0: bl     #0x2368 ; <duss_log_gen_head>
 0xcab4: cbz    w0, #0xcac4
 0xcab8: adrp   x3, #0x1c000
 0xcabc: add    x3, x3, #0x79b ; "%s: Failed to allocate memory for ics buffer array
"
 0xcac0: b      #0xc660
 0xcac4: mov    w21, wzr
 0xcac8: ldr    x0, [x20, #0x3f8]
 0xcacc: cbz    x0, #0xcb00
 0xcad0: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xcad4: mov    w22, w0
 0xcad8: cbz    w22, #0xcaf4
 0xcadc: ldr    x0, [x20, #0x3f8]
 0xcae0: add    x1, sp, #0x48
 0xcae4: str    xzr, [sp, #0x48]
 0xcae8: bl     #0x2618 ; <buffer_queue_dequeue_reverse>
 0xcaec: subs   w22, w22, #1
 0xcaf0: b.ne   #0xcadc
 0xcaf4: ldr    x0, [x20, #0x3f8]
 0xcaf8: bl     #0x26a8 ; <buffer_queue_destroy>
 0xcafc: str    xzr, [x20, #0x3f8]
 0xcb00: ldr    x22, [x20, #0x3f0]
 0xcb04: cbz    x22, #0xcb80
 0xcb08: ldr    w8, [x20, #0x400]
 0xcb0c: cbz    w8, #0xcb68
 0xcb10: adrp   x24, #0x1a000
 0xcb14: mov    w27, #8
 0xcb18: mov    w28, #1
 0xcb1c: mov    w23, #0x47c
 0xcb20: add    x24, x24, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcb24: ldr    x0, [x22, x27]
 0xcb28: cbz    x0, #0xcb5c
 0xcb2c: mov    x1, x24
 0xcb30: mov    w2, w23
 0xcb34: bl     #0x26b8 ; <vmem_free_dbg>
 0xcb38: str    xzr, [x22, x27]
 0xcb3c: ldr    w8, [x20, #0x400]
 0xcb40: cmp    x28, w8, uxtw
 0xcb44: b.hs   #0xcb64
 0xcb48: ldr    x22, [x20, #0x3f0]
 0xcb4c: add    x27, x27, #0x10 ; =0x1a010
 0xcb50: add    x28, x28, #1 ; =0x1a001
 0xcb54: ldr    x0, [x22, x27]
 0xcb58: cbnz   x0, #0xcb2c
 0xcb5c: cmp    x28, w8, uxtw
 0xcb60: b.lo   #0xcb48
 0xcb64: ldr    x22, [x20, #0x3f0]
 0xcb68: adrp   x1, #0x1a000
 0xcb6c: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcb70: mov    w2, #0x480
 0xcb74: mov    x0, x22
 0xcb78: bl     #0x26c8 ; <cam_free_internal>
 0xcb7c: str    xzr, [x20, #0x3f0]
 0xcb80: ldr    x0, [x20, #0x430]
 0xcb84: cbz    x0, #0xcb90
 0xcb88: bl     #0x26a8 ; <buffer_queue_destroy>
 0xcb8c: str    xzr, [x20, #0x430]
 0xcb90: ldr    x0, [x20, #0x420]
 0xcb94: cbz    x0, #0xcbc8
 0xcb98: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xcb9c: mov    w22, w0
 0xcba0: cbz    w22, #0xcbbc
 0xcba4: ldr    x0, [x20, #0x420]
 0xcba8: add    x1, sp, #0x48
 0xcbac: str    xzr, [sp, #0x48]
 0xcbb0: bl     #0x2618 ; <buffer_queue_dequeue_reverse>
 0xcbb4: subs   w22, w22, #1
 0xcbb8: b.ne   #0xcba4
 0xcbbc: ldr    x0, [x20, #0x420]
 0xcbc0: bl     #0x26a8 ; <buffer_queue_destroy>
 0xcbc4: str    xzr, [x20, #0x420]
 0xcbc8: ldr    x0, [x20, #0x418]
 0xcbcc: cbz    x0, #0xcbe4
 0xcbd0: adrp   x1, #0x1a000
 0xcbd4: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcbd8: mov    w2, #0x491
 0xcbdc: bl     #0x26c8 ; <cam_free_internal>
 0xcbe0: str    xzr, [x20, #0x418]
 0xcbe4: ldr    x1, [sp, #0x40]
 0xcbe8: mov    x0, x20
 0xcbec: bl     #0x11ec8
 0xcbf0: str    xzr, [x19]
 0xcbf4: ldr    x8, [x25, #0x28]
 0xcbf8: ldr    x9, [x26]
 0xcbfc: cmp    x8, x9
 0xcc00: b.ne   #0xcfe0
 0xcc04: mov    w0, w21
 0xcc08: ldp    x29, x30, [sp, #0x120]
 0xcc0c: ldp    x20, x19, [sp, #0x110]
 0xcc10: ldp    x22, x21, [sp, #0x100]
 0xcc14: ldp    x24, x23, [sp, #0xf0]
 0xcc18: ldp    x26, x25, [sp, #0xe0]
 0xcc1c: ldp    x28, x27, [sp, #0xd0]
 0xcc20: add    sp, sp, #0x130
 0xcc24: ret    
 0xcc28: adrp   x4, #0x1a000
 0xcc2c: adrp   x5, #0x1c000
 0xcc30: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcc34: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcc38: mov    w0, #0x51
 0xcc3c: mov    w6, #0x461
 0xcc40: mov    w1, #1
 0xcc44: add    x2, sp, #0x48
 0xcc48: mov    w3, #0x80
 0xcc4c: bl     #0x2368 ; <duss_log_gen_head>
 0xcc50: cbz    w0, #0xcc78
 0xcc54: adrp   x3, #0x1a000
 0xcc58: adrp   x4, #0x1a000
 0xcc5c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xcc60: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcc64: mov    w0, #0x51
 0xcc68: mov    w5, #0x461
 0xcc6c: mov    w1, #1
 0xcc70: add    x2, sp, #0x48
 0xcc74: bl     #0x2378 ; <duss_log_print>
 0xcc78: adrp   x4, #0x1a000
 0xcc7c: adrp   x5, #0x1c000
 0xcc80: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcc84: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcc88: mov    w0, #0x51
 0xcc8c: mov    w6, #0x461
 0xcc90: mov    w1, #1
 0xcc94: add    x2, sp, #0x48
 0xcc98: mov    w3, #0x80
 0xcc9c: bl     #0x2368 ; <duss_log_gen_head>
 0xcca0: cbz    w0, #0xcac8
 0xcca4: adrp   x3, #0x1c000
 0xcca8: add    x3, x3, #0x8d7 ; "%s: Failed to create ics buffer pool with error %d
"
 0xccac: b      #0xc7d0
 0xccb0: adrp   x4, #0x1a000
 0xccb4: adrp   x5, #0x1c000
 0xccb8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xccbc: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xccc0: mov    w0, #0x51
 0xccc4: mov    w6, #0x458
 0xccc8: mov    w1, #1
 0xcccc: add    x2, sp, #0x48
 0xccd0: mov    w3, #0x80
 0xccd4: bl     #0x2368 ; <duss_log_gen_head>
 0xccd8: cbz    w0, #0xcd00
 0xccdc: adrp   x3, #0x1a000
 0xcce0: adrp   x4, #0x1a000
 0xcce4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xcce8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xccec: mov    w0, #0x51
 0xccf0: mov    w5, #0x458
 0xccf4: mov    w1, #1
 0xccf8: add    x2, sp, #0x48
 0xccfc: bl     #0x2378 ; <duss_log_print>
 0xcd00: adrp   x4, #0x1a000
 0xcd04: adrp   x5, #0x1c000
 0xcd08: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcd0c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcd10: mov    w0, #0x51
 0xcd14: mov    w6, #0x458
 0xcd18: mov    w1, #1
 0xcd1c: add    x2, sp, #0x48
 0xcd20: mov    w3, #0x80
 0xcd24: bl     #0x2368 ; <duss_log_gen_head>
 0xcd28: cbz    w0, #0xcac8
 0xcd2c: adrp   x3, #0x1c000
 0xcd30: adrp   x4, #0x1a000
 0xcd34: add    x3, x3, #0x832 ; "%s: Failed to allocate ion memory for ics buffery
"
 0xcd38: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xcd3c: mov    w0, #0x51
 0xcd40: mov    w1, #1
 0xcd44: add    x2, sp, #0x48
 0xcd48: bl     #0x2378 ; <duss_log_print>
 0xcd4c: ldr    x0, [x20, #0x3f8]
 0xcd50: cbnz   x0, #0xcad0
 0xcd54: b      #0xcb00
 0xcd58: bl     #0x2348 ; <co_thread_get>
 0xcd5c: cbnz   x0, #0xd088
 0xcd60: adrp   x4, #0x1a000
 0xcd64: adrp   x5, #0x1c000
 0xcd68: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcd6c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcd70: mov    w0, #0x51
 0xcd74: mov    w6, #0x40d
 0xcd78: add    x2, sp, #0x48
 0xcd7c: mov    w3, #0x80
 0xcd80: mov    w1, wzr
 0xcd84: bl     #0x2368 ; <duss_log_gen_head>
 0xcd88: cbz    w0, #0xd110
 0xcd8c: adrp   x3, #0x1a000
 0xcd90: adrp   x4, #0x1c000
 0xcd94: adrp   x5, #0x1a000
 0xcd98: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xcd9c: add    x4, x4, #0x3a6 ; "common_cfg"
 0xcda0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcda4: mov    w0, #0x51
 0xcda8: mov    w6, #0x40d
 0xcdac: add    x2, sp, #0x48
 0xcdb0: mov    w1, wzr
 0xcdb4: bl     #0x2378 ; <duss_log_print>
 0xcdb8: b      #0xd110
 0xcdbc: bl     #0x2348 ; <co_thread_get>
 0xcdc0: cbnz   x0, #0xd12c
 0xcdc4: adrp   x4, #0x1a000
 0xcdc8: adrp   x5, #0x1c000
 0xcdcc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcdd0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcdd4: mov    w0, #0x51
 0xcdd8: mov    w6, #0x40e
 0xcddc: add    x2, sp, #0x48
 0xcde0: mov    w3, #0x80
 0xcde4: mov    w1, wzr
 0xcde8: bl     #0x2368 ; <duss_log_gen_head>
 0xcdec: cbz    w0, #0xd1b4
 0xcdf0: adrp   x3, #0x1a000
 0xcdf4: adrp   x4, #0x1b000
 0xcdf8: adrp   x5, #0x1a000
 0xcdfc: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xce00: add    x4, x4, #0xbbc ; "allocator"
 0xce04: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xce08: mov    w0, #0x51
 0xce0c: mov    w6, #0x40e
 0xce10: add    x2, sp, #0x48
 0xce14: mov    w1, wzr
 0xce18: bl     #0x2378 ; <duss_log_print>
 0xce1c: b      #0xd1b4
 0xce20: bl     #0x2348 ; <co_thread_get>
 0xce24: cbnz   x0, #0xd1d0
 0xce28: adrp   x4, #0x1a000
 0xce2c: adrp   x5, #0x1c000
 0xce30: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xce34: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xce38: mov    w0, #0x51
 0xce3c: mov    w6, #0x413
 0xce40: add    x2, sp, #0x48
 0xce44: mov    w3, #0x80
 0xce48: mov    w1, wzr
 0xce4c: bl     #0x2368 ; <duss_log_gen_head>
 0xce50: cbz    w0, #0xd258
 0xce54: adrp   x3, #0x1a000
 0xce58: adrp   x4, #0x1c000
 0xce5c: adrp   x5, #0x1a000
 0xce60: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xce64: add    x4, x4, #0x3b1 ; "common_cfg->mem_total_size"
 0xce68: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xce6c: mov    w0, #0x51
 0xce70: mov    w6, #0x413
 0xce74: add    x2, sp, #0x48
 0xce78: mov    w1, wzr
 0xce7c: bl     #0x2378 ; <duss_log_print>
 0xce80: b      #0xd258
 0xce84: adrp   x0, #0x30000
 0xce88: adrp   x2, #0x1a000
 0xce8c: add    x0, x0, #8 ; =0x30008
 0xce90: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xce94: mov    w1, #1
 0xce98: bl     #0x2338 ; <log_mgr_check>
 0xce9c: tbz    w0, #0, #0xd478
 0xcea0: bl     #0x2348 ; <co_thread_get>
 0xcea4: cbnz   x0, #0xd3a0
 0xcea8: adrp   x4, #0x1a000
 0xceac: adrp   x5, #0x1c000
 0xceb0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xceb4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xceb8: mov    w0, #0x51
 0xcebc: mov    w6, #0x417
 0xcec0: mov    w1, #1
 0xcec4: add    x2, sp, #0x48
 0xcec8: mov    w3, #0x80
 0xcecc: bl     #0x2368 ; <duss_log_gen_head>
 0xced0: cbz    w0, #0xcef8
 0xced4: adrp   x3, #0x1a000
 0xced8: adrp   x4, #0x1a000
 0xcedc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xcee0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcee4: mov    w0, #0x51
 0xcee8: mov    w5, #0x417
 0xceec: mov    w1, #1
 0xcef0: add    x2, sp, #0x48
 0xcef4: bl     #0x2378 ; <duss_log_print>
 0xcef8: adrp   x4, #0x1a000
 0xcefc: adrp   x5, #0x1c000
 0xcf00: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcf04: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcf08: mov    w0, #0x51
 0xcf0c: mov    w6, #0x417
 0xcf10: mov    w1, #1
 0xcf14: add    x2, sp, #0x48
 0xcf18: mov    w3, #0x80
 0xcf1c: bl     #0x2368 ; <duss_log_gen_head>
 0xcf20: cbz    w0, #0xd478
 0xcf24: ldr    w5, [x21, #8]
 0xcf28: adrp   x3, #0x1c000
 0xcf2c: ldr    w6, [x21]
 0xcf30: adrp   x4, #0x1a000
 0xcf34: add    x3, x3, #0x40b ; "%s: mem_thresh %d should be below mem_total_size %d"
 0xcf38: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xcf3c: mov    w0, #0x51
 0xcf40: mov    w1, #1
 0xcf44: add    x2, sp, #0x48
 0xcf48: bl     #0x2378 ; <duss_log_print>
 0xcf4c: bl     #0x2348 ; <co_thread_get>
 0xcf50: cbz    x0, #0xd480
 0xcf54: adrp   x8, #0x1a000
 0xcf58: str    wzr, [sp, #0x3c]
 0xcf5c: add    x8, x8, #0x440 ; =0x1a440
 0xcf60: add    x1, sp, #0x30
 0xcf64: add    x2, sp, #0x3c
 0xcf68: str    x8, [sp, #0x30]
 0xcf6c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xcf70: adrp   x19, #0x1a000
 0xcf74: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xcf78: adrp   x5, #0x1c000
 0xcf7c: mov    w20, #0x418
 0xcf80: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xcf84: mov    w0, #0x51
 0xcf88: add    x2, sp, #0x48
 0xcf8c: mov    w3, #0x80
 0xcf90: mov    w1, wzr
 0xcf94: mov    x4, x19
 0xcf98: mov    w6, w20
 0xcf9c: bl     #0x2368 ; <duss_log_gen_head>
 0xcfa0: cbz    w0, #0xd4d8
 0xcfa4: ldr    x5, [sp, #0x30]
 0xcfa8: adrp   x3, #0x1a000
 0xcfac: ldr    w6, [sp, #0x3c]
 0xcfb0: adrp   x4, #0x1a000
 0xcfb4: adrp   x7, #0x1b000
 0xcfb8: str    w20, [sp, #8]
 0xcfbc: mov    w1, wzr
 0xcfc0: str    x19, [sp]
 0xcfc4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xcfc8: add    x4, x4, #0x441 ; "co"
 0xcfcc: mov    w0, #0x51
 0xcfd0: add    x7, x7, #0xf7 ; "0"
 0xcfd4: add    x2, sp, #0x48
 0xcfd8: bl     #0x2378 ; <duss_log_print>
 0xcfdc: b      #0xd4d8
 0xcfe0: bl     #0x23d8 ; <__stack_chk_fail>
 0xcfe4: adrp   x8, #0x1a000
 0xcfe8: str    wzr, [sp, #0x3c]
 0xcfec: add    x8, x8, #0x440 ; =0x1a440
 0xcff0: add    x1, sp, #0x30
 0xcff4: add    x2, sp, #0x3c
 0xcff8: str    x8, [sp, #0x30]
 0xcffc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd000: adrp   x19, #0x1a000
 0xd004: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd008: adrp   x5, #0x1c000
 0xd00c: mov    w20, #0x40c
 0xd010: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd014: mov    w0, #0x51
 0xd018: add    x2, sp, #0x48
 0xd01c: mov    w3, #0x80
 0xd020: mov    w1, wzr
 0xd024: mov    x4, x19
 0xd028: mov    w6, w20
 0xd02c: bl     #0x2368 ; <duss_log_gen_head>
 0xd030: cbz    w0, #0xd06c
 0xd034: ldr    x5, [sp, #0x30]
 0xd038: adrp   x3, #0x1a000
 0xd03c: ldr    w6, [sp, #0x3c]
 0xd040: adrp   x4, #0x1a000
 0xd044: adrp   x7, #0x1a000
 0xd048: str    w20, [sp, #8]
 0xd04c: mov    w1, wzr
 0xd050: str    x19, [sp]
 0xd054: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd058: add    x4, x4, #0x441 ; "co"
 0xd05c: mov    w0, #0x51
 0xd060: add    x7, x7, #0x5c0 ; "ops"
 0xd064: add    x2, sp, #0x48
 0xd068: bl     #0x2378 ; <duss_log_print>
 0xd06c: adrp   x4, #0x1a000
 0xd070: adrp   x5, #0x1c000
 0xd074: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd078: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd07c: mov    w0, #0x51
 0xd080: mov    w6, #0x40c
 0xd084: b      #0xe024
 0xd088: adrp   x8, #0x1a000
 0xd08c: str    wzr, [sp, #0x3c]
 0xd090: add    x8, x8, #0x440 ; =0x1a440
 0xd094: add    x1, sp, #0x30
 0xd098: add    x2, sp, #0x3c
 0xd09c: str    x8, [sp, #0x30]
 0xd0a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd0a4: adrp   x19, #0x1a000
 0xd0a8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd0ac: adrp   x5, #0x1c000
 0xd0b0: mov    w20, #0x40d
 0xd0b4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd0b8: mov    w0, #0x51
 0xd0bc: add    x2, sp, #0x48
 0xd0c0: mov    w3, #0x80
 0xd0c4: mov    w1, wzr
 0xd0c8: mov    x4, x19
 0xd0cc: mov    w6, w20
 0xd0d0: bl     #0x2368 ; <duss_log_gen_head>
 0xd0d4: cbz    w0, #0xd110
 0xd0d8: ldr    x5, [sp, #0x30]
 0xd0dc: adrp   x3, #0x1a000
 0xd0e0: ldr    w6, [sp, #0x3c]
 0xd0e4: adrp   x4, #0x1a000
 0xd0e8: adrp   x7, #0x1c000
 0xd0ec: str    w20, [sp, #8]
 0xd0f0: mov    w1, wzr
 0xd0f4: str    x19, [sp]
 0xd0f8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd0fc: add    x4, x4, #0x441 ; "co"
 0xd100: mov    w0, #0x51
 0xd104: add    x7, x7, #0x3a6 ; "common_cfg"
 0xd108: add    x2, sp, #0x48
 0xd10c: bl     #0x2378 ; <duss_log_print>
 0xd110: adrp   x4, #0x1a000
 0xd114: adrp   x5, #0x1c000
 0xd118: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd11c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd120: mov    w0, #0x51
 0xd124: mov    w6, #0x40d
 0xd128: b      #0xe024
 0xd12c: adrp   x8, #0x1a000
 0xd130: str    wzr, [sp, #0x3c]
 0xd134: add    x8, x8, #0x440 ; =0x1a440
 0xd138: add    x1, sp, #0x30
 0xd13c: add    x2, sp, #0x3c
 0xd140: str    x8, [sp, #0x30]
 0xd144: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd148: adrp   x19, #0x1a000
 0xd14c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd150: adrp   x5, #0x1c000
 0xd154: mov    w20, #0x40e
 0xd158: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd15c: mov    w0, #0x51
 0xd160: add    x2, sp, #0x48
 0xd164: mov    w3, #0x80
 0xd168: mov    w1, wzr
 0xd16c: mov    x4, x19
 0xd170: mov    w6, w20
 0xd174: bl     #0x2368 ; <duss_log_gen_head>
 0xd178: cbz    w0, #0xd1b4
 0xd17c: ldr    x5, [sp, #0x30]
 0xd180: adrp   x3, #0x1a000
 0xd184: ldr    w6, [sp, #0x3c]
 0xd188: adrp   x4, #0x1a000
 0xd18c: adrp   x7, #0x1b000
 0xd190: str    w20, [sp, #8]
 0xd194: mov    w1, wzr
 0xd198: str    x19, [sp]
 0xd19c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd1a0: add    x4, x4, #0x441 ; "co"
 0xd1a4: mov    w0, #0x51
 0xd1a8: add    x7, x7, #0xbbc ; "allocator"
 0xd1ac: add    x2, sp, #0x48
 0xd1b0: bl     #0x2378 ; <duss_log_print>
 0xd1b4: adrp   x4, #0x1a000
 0xd1b8: adrp   x5, #0x1c000
 0xd1bc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd1c0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd1c4: mov    w0, #0x51
 0xd1c8: mov    w6, #0x40e
 0xd1cc: b      #0xe024
 0xd1d0: adrp   x8, #0x1a000
 0xd1d4: str    wzr, [sp, #0x3c]
 0xd1d8: add    x8, x8, #0x440 ; =0x1a440
 0xd1dc: add    x1, sp, #0x30
 0xd1e0: add    x2, sp, #0x3c
 0xd1e4: str    x8, [sp, #0x30]
 0xd1e8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd1ec: adrp   x19, #0x1a000
 0xd1f0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd1f4: adrp   x5, #0x1c000
 0xd1f8: mov    w20, #0x413
 0xd1fc: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd200: mov    w0, #0x51
 0xd204: add    x2, sp, #0x48
 0xd208: mov    w3, #0x80
 0xd20c: mov    w1, wzr
 0xd210: mov    x4, x19
 0xd214: mov    w6, w20
 0xd218: bl     #0x2368 ; <duss_log_gen_head>
 0xd21c: cbz    w0, #0xd258
 0xd220: ldr    x5, [sp, #0x30]
 0xd224: adrp   x3, #0x1a000
 0xd228: ldr    w6, [sp, #0x3c]
 0xd22c: adrp   x4, #0x1a000
 0xd230: adrp   x7, #0x1c000
 0xd234: str    w20, [sp, #8]
 0xd238: mov    w1, wzr
 0xd23c: str    x19, [sp]
 0xd240: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd244: add    x4, x4, #0x441 ; "co"
 0xd248: mov    w0, #0x51
 0xd24c: add    x7, x7, #0x3b1 ; "common_cfg->mem_total_size"
 0xd250: add    x2, sp, #0x48
 0xd254: bl     #0x2378 ; <duss_log_print>
 0xd258: adrp   x4, #0x1a000
 0xd25c: adrp   x5, #0x1c000
 0xd260: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd264: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd268: mov    w0, #0x51
 0xd26c: mov    w6, #0x413
 0xd270: b      #0xe024
 0xd274: bl     #0x2348 ; <co_thread_get>
 0xd278: cbnz   x0, #0xd5bc
 0xd27c: adrp   x4, #0x1a000
 0xd280: adrp   x5, #0x1c000
 0xd284: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd288: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd28c: mov    w0, #0x51
 0xd290: mov    w6, #0x426
 0xd294: add    x2, sp, #0x48
 0xd298: mov    w3, #0x80
 0xd29c: mov    w1, wzr
 0xd2a0: bl     #0x2368 ; <duss_log_gen_head>
 0xd2a4: cbz    w0, #0xd644
 0xd2a8: adrp   x3, #0x1a000
 0xd2ac: adrp   x4, #0x1b000
 0xd2b0: adrp   x5, #0x1a000
 0xd2b4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd2b8: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xd2bc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd2c0: mov    w0, #0x51
 0xd2c4: mov    w6, #0x426
 0xd2c8: add    x2, sp, #0x48
 0xd2cc: mov    w1, wzr
 0xd2d0: bl     #0x2378 ; <duss_log_print>
 0xd2d4: b      #0xd644
 0xd2d8: bl     #0x2348 ; <co_thread_get>
 0xd2dc: cbnz   x0, #0xd660
 0xd2e0: adrp   x4, #0x1a000
 0xd2e4: adrp   x5, #0x1c000
 0xd2e8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd2ec: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd2f0: mov    w0, #0x51
 0xd2f4: mov    w6, #0x427
 0xd2f8: add    x2, sp, #0x48
 0xd2fc: mov    w3, #0x80
 0xd300: mov    w1, wzr
 0xd304: bl     #0x2368 ; <duss_log_gen_head>
 0xd308: cbz    w0, #0xd6e8
 0xd30c: adrp   x3, #0x1a000
 0xd310: adrp   x4, #0x1c000
 0xd314: adrp   x5, #0x1a000
 0xd318: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd31c: add    x4, x4, #0x4b8 ; "eng->encoding_request_q_size > 0"
 0xd320: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd324: mov    w0, #0x51
 0xd328: mov    w6, #0x427
 0xd32c: add    x2, sp, #0x48
 0xd330: mov    w1, wzr
 0xd334: bl     #0x2378 ; <duss_log_print>
 0xd338: b      #0xd6e8
 0xd33c: bl     #0x2348 ; <co_thread_get>
 0xd340: cbnz   x0, #0xd704
 0xd344: adrp   x4, #0x1a000
 0xd348: adrp   x5, #0x1c000
 0xd34c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd350: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd354: mov    w0, #0x51
 0xd358: mov    w6, #0x42c
 0xd35c: add    x2, sp, #0x48
 0xd360: mov    w3, #0x80
 0xd364: mov    w1, wzr
 0xd368: bl     #0x2368 ; <duss_log_gen_head>
 0xd36c: cbz    w0, #0xd78c
 0xd370: adrp   x3, #0x1a000
 0xd374: adrp   x4, #0x1c000
 0xd378: adrp   x5, #0x1a000
 0xd37c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd380: add    x4, x4, #0x4d9 ; "eng->encoding_request_array == ((void*)0)"
 0xd384: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd388: mov    w0, #0x51
 0xd38c: mov    w6, #0x42c
 0xd390: add    x2, sp, #0x48
 0xd394: mov    w1, wzr
 0xd398: bl     #0x2378 ; <duss_log_print>
 0xd39c: b      #0xd78c
 0xd3a0: adrp   x8, #0x1a000
 0xd3a4: str    wzr, [sp, #0x3c]
 0xd3a8: add    x8, x8, #0x440 ; =0x1a440
 0xd3ac: add    x1, sp, #0x30
 0xd3b0: add    x2, sp, #0x3c
 0xd3b4: str    x8, [sp, #0x30]
 0xd3b8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd3bc: adrp   x4, #0x1a000
 0xd3c0: adrp   x5, #0x1c000
 0xd3c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd3c8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd3cc: mov    w0, #0x51
 0xd3d0: mov    w6, #0x417
 0xd3d4: mov    w1, #1
 0xd3d8: add    x2, sp, #0x48
 0xd3dc: mov    w3, #0x80
 0xd3e0: bl     #0x2368 ; <duss_log_gen_head>
 0xd3e4: cbz    w0, #0xd40c
 0xd3e8: adrp   x3, #0x1a000
 0xd3ec: adrp   x4, #0x1a000
 0xd3f0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
 0xd3f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd3f8: mov    w0, #0x51
 0xd3fc: mov    w5, #0x417
 0xd400: mov    w1, #1
 0xd404: add    x2, sp, #0x48
 0xd408: bl     #0x2378 ; <duss_log_print>
 0xd40c: adrp   x4, #0x1a000
 0xd410: adrp   x5, #0x1c000
 0xd414: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd418: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd41c: mov    w0, #0x51
 0xd420: mov    w6, #0x417
 0xd424: mov    w1, #1
 0xd428: add    x2, sp, #0x48
 0xd42c: mov    w3, #0x80
 0xd430: bl     #0x2368 ; <duss_log_gen_head>
 0xd434: cbz    w0, #0xd478
 0xd438: ldr    x6, [sp, #0x30]
 0xd43c: adrp   x3, #0x1c000
 0xd440: ldr    w7, [sp, #0x3c]
 0xd444: adrp   x4, #0x1a000
 0xd448: ldr    w8, [x21, #8]
 0xd44c: adrp   x5, #0x1a000
 0xd450: ldr    w9, [x21]
 0xd454: add    x3, x3, #0x3cc ; "%s: %s(%s_%x): mem_thresh %d should be below mem_total_size %d"
 0xd458: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xd45c: add    x5, x5, #0x441 ; "co"
 0xd460: mov    w0, #0x51
 0xd464: str    w8, [sp]
 0xd468: mov    w1, #1
 0xd46c: str    w9, [sp, #8]
 0xd470: add    x2, sp, #0x48
 0xd474: bl     #0x2378 ; <duss_log_print>
 0xd478: bl     #0x2348 ; <co_thread_get>
 0xd47c: cbnz   x0, #0xcf54
 0xd480: adrp   x4, #0x1a000
 0xd484: adrp   x5, #0x1c000
 0xd488: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd48c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd490: mov    w0, #0x51
 0xd494: mov    w6, #0x418
 0xd498: add    x2, sp, #0x48
 0xd49c: mov    w3, #0x80
 0xd4a0: mov    w1, wzr
 0xd4a4: bl     #0x2368 ; <duss_log_gen_head>
 0xd4a8: cbz    w0, #0xd4d8
 0xd4ac: adrp   x3, #0x1a000
 0xd4b0: adrp   x4, #0x1b000
 0xd4b4: adrp   x5, #0x1a000
 0xd4b8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd4bc: add    x4, x4, #0xf7 ; "0"
 0xd4c0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd4c4: mov    w0, #0x51
 0xd4c8: mov    w6, #0x418
 0xd4cc: add    x2, sp, #0x48
 0xd4d0: mov    w1, wzr
 0xd4d4: bl     #0x2378 ; <duss_log_print>
 0xd4d8: adrp   x4, #0x1a000
 0xd4dc: adrp   x5, #0x1c000
 0xd4e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd4e4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd4e8: mov    w0, #0x51
 0xd4ec: mov    w6, #0x418
 0xd4f0: b      #0xe024
 0xd4f4: bl     #0x2348 ; <co_thread_get>
 0xd4f8: cbnz   x0, #0xd7a8
 0xd4fc: adrp   x4, #0x1a000
 0xd500: adrp   x5, #0x1c000
 0xd504: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd508: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd50c: mov    w0, #0x51
 0xd510: mov    w6, #0x434
 0xd514: add    x2, sp, #0x48
 0xd518: mov    w3, #0x80
 0xd51c: mov    w1, wzr
 0xd520: bl     #0x2368 ; <duss_log_gen_head>
 0xd524: cbz    w0, #0xd830
 0xd528: adrp   x3, #0x1a000
 0xd52c: adrp   x4, #0x1c000
 0xd530: adrp   x5, #0x1a000
 0xd534: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd538: add    x4, x4, #0x582 ; "eng->encoding_request_pool == ((void*)0)"
 0xd53c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd540: mov    w0, #0x51
 0xd544: mov    w6, #0x434
 0xd548: add    x2, sp, #0x48
 0xd54c: mov    w1, wzr
 0xd550: bl     #0x2378 ; <duss_log_print>
 0xd554: b      #0xd830
 0xd558: bl     #0x2348 ; <co_thread_get>
 0xd55c: cbnz   x0, #0xd84c
 0xd560: adrp   x4, #0x1a000
 0xd564: adrp   x5, #0x1c000
 0xd568: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd56c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd570: mov    w0, #0x51
 0xd574: mov    w6, #0x455
 0xd578: add    x2, sp, #0x48
 0xd57c: mov    w3, #0x80
 0xd580: mov    w1, wzr
 0xd584: bl     #0x2368 ; <duss_log_gen_head>
 0xd588: cbz    w0, #0xd8d4
 0xd58c: adrp   x3, #0x1a000
 0xd590: adrp   x4, #0x1c000
 0xd594: adrp   x5, #0x1a000
 0xd598: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd59c: add    x4, x4, #0x7cf ; "ics_buffer->ics_buffer == ((void*)0)"
 0xd5a0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd5a4: mov    w0, #0x51
 0xd5a8: mov    w6, #0x455
 0xd5ac: add    x2, sp, #0x48
 0xd5b0: mov    w1, wzr
 0xd5b4: bl     #0x2378 ; <duss_log_print>
 0xd5b8: b      #0xd8d4
 0xd5bc: adrp   x8, #0x1a000
 0xd5c0: str    wzr, [sp, #0x2c]
 0xd5c4: add    x8, x8, #0x440 ; =0x1a440
 0xd5c8: add    x1, sp, #0x30
 0xd5cc: add    x2, sp, #0x2c
 0xd5d0: str    x8, [sp, #0x30]
 0xd5d4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd5d8: adrp   x19, #0x1a000
 0xd5dc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd5e0: adrp   x5, #0x1c000
 0xd5e4: mov    w20, #0x426
 0xd5e8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd5ec: mov    w0, #0x51
 0xd5f0: add    x2, sp, #0x48
 0xd5f4: mov    w3, #0x80
 0xd5f8: mov    w1, wzr
 0xd5fc: mov    x4, x19
 0xd600: mov    w6, w20
 0xd604: bl     #0x2368 ; <duss_log_gen_head>
 0xd608: cbz    w0, #0xd644
 0xd60c: ldr    x5, [sp, #0x30]
 0xd610: adrp   x3, #0x1a000
 0xd614: ldr    w6, [sp, #0x2c]
 0xd618: adrp   x4, #0x1a000
 0xd61c: adrp   x7, #0x1b000
 0xd620: str    w20, [sp, #8]
 0xd624: mov    w1, wzr
 0xd628: str    x19, [sp]
 0xd62c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd630: add    x4, x4, #0x441 ; "co"
 0xd634: mov    w0, #0x51
 0xd638: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xd63c: add    x2, sp, #0x48
 0xd640: bl     #0x2378 ; <duss_log_print>
 0xd644: adrp   x4, #0x1a000
 0xd648: adrp   x5, #0x1c000
 0xd64c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd650: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd654: mov    w0, #0x51
 0xd658: mov    w6, #0x426
 0xd65c: b      #0xe024
 0xd660: adrp   x8, #0x1a000
 0xd664: str    wzr, [sp, #0x2c]
 0xd668: add    x8, x8, #0x440 ; =0x1a440
 0xd66c: add    x1, sp, #0x30
 0xd670: add    x2, sp, #0x2c
 0xd674: str    x8, [sp, #0x30]
 0xd678: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd67c: adrp   x19, #0x1a000
 0xd680: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd684: adrp   x5, #0x1c000
 0xd688: mov    w20, #0x427
 0xd68c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd690: mov    w0, #0x51
 0xd694: add    x2, sp, #0x48
 0xd698: mov    w3, #0x80
 0xd69c: mov    w1, wzr
 0xd6a0: mov    x4, x19
 0xd6a4: mov    w6, w20
 0xd6a8: bl     #0x2368 ; <duss_log_gen_head>
 0xd6ac: cbz    w0, #0xd6e8
 0xd6b0: ldr    x5, [sp, #0x30]
 0xd6b4: adrp   x3, #0x1a000
 0xd6b8: ldr    w6, [sp, #0x2c]
 0xd6bc: adrp   x4, #0x1a000
 0xd6c0: adrp   x7, #0x1c000
 0xd6c4: str    w20, [sp, #8]
 0xd6c8: mov    w1, wzr
 0xd6cc: str    x19, [sp]
 0xd6d0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd6d4: add    x4, x4, #0x441 ; "co"
 0xd6d8: mov    w0, #0x51
 0xd6dc: add    x7, x7, #0x4b8 ; "eng->encoding_request_q_size > 0"
 0xd6e0: add    x2, sp, #0x48
 0xd6e4: bl     #0x2378 ; <duss_log_print>
 0xd6e8: adrp   x4, #0x1a000
 0xd6ec: adrp   x5, #0x1c000
 0xd6f0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd6f4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd6f8: mov    w0, #0x51
 0xd6fc: mov    w6, #0x427
 0xd700: b      #0xe024
 0xd704: adrp   x8, #0x1a000
 0xd708: str    wzr, [sp, #0x2c]
 0xd70c: add    x8, x8, #0x440 ; =0x1a440
 0xd710: add    x1, sp, #0x30
 0xd714: add    x2, sp, #0x2c
 0xd718: str    x8, [sp, #0x30]
 0xd71c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd720: adrp   x19, #0x1a000
 0xd724: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd728: adrp   x5, #0x1c000
 0xd72c: mov    w20, #0x42c
 0xd730: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd734: mov    w0, #0x51
 0xd738: add    x2, sp, #0x48
 0xd73c: mov    w3, #0x80
 0xd740: mov    w1, wzr
 0xd744: mov    x4, x19
 0xd748: mov    w6, w20
 0xd74c: bl     #0x2368 ; <duss_log_gen_head>
 0xd750: cbz    w0, #0xd78c
 0xd754: ldr    x5, [sp, #0x30]
 0xd758: adrp   x3, #0x1a000
 0xd75c: ldr    w6, [sp, #0x2c]
 0xd760: adrp   x4, #0x1a000
 0xd764: adrp   x7, #0x1c000
 0xd768: str    w20, [sp, #8]
 0xd76c: mov    w1, wzr
 0xd770: str    x19, [sp]
 0xd774: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd778: add    x4, x4, #0x441 ; "co"
 0xd77c: mov    w0, #0x51
 0xd780: add    x7, x7, #0x4d9 ; "eng->encoding_request_array == ((void*)0)"
 0xd784: add    x2, sp, #0x48
 0xd788: bl     #0x2378 ; <duss_log_print>
 0xd78c: adrp   x4, #0x1a000
 0xd790: adrp   x5, #0x1c000
 0xd794: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd798: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd79c: mov    w0, #0x51
 0xd7a0: mov    w6, #0x42c
 0xd7a4: b      #0xe024
 0xd7a8: adrp   x8, #0x1a000
 0xd7ac: str    wzr, [sp, #0x2c]
 0xd7b0: add    x8, x8, #0x440 ; =0x1a440
 0xd7b4: add    x1, sp, #0x30
 0xd7b8: add    x2, sp, #0x2c
 0xd7bc: str    x8, [sp, #0x30]
 0xd7c0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd7c4: adrp   x19, #0x1a000
 0xd7c8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd7cc: adrp   x5, #0x1c000
 0xd7d0: mov    w20, #0x434
 0xd7d4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd7d8: mov    w0, #0x51
 0xd7dc: add    x2, sp, #0x48
 0xd7e0: mov    w3, #0x80
 0xd7e4: mov    w1, wzr
 0xd7e8: mov    x4, x19
 0xd7ec: mov    w6, w20
 0xd7f0: bl     #0x2368 ; <duss_log_gen_head>
 0xd7f4: cbz    w0, #0xd830
 0xd7f8: ldr    x5, [sp, #0x30]
 0xd7fc: adrp   x3, #0x1a000
 0xd800: ldr    w6, [sp, #0x2c]
 0xd804: adrp   x4, #0x1a000
 0xd808: adrp   x7, #0x1c000
 0xd80c: str    w20, [sp, #8]
 0xd810: mov    w1, wzr
 0xd814: str    x19, [sp]
 0xd818: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd81c: add    x4, x4, #0x441 ; "co"
 0xd820: mov    w0, #0x51
 0xd824: add    x7, x7, #0x582 ; "eng->encoding_request_pool == ((void*)0)"
 0xd828: add    x2, sp, #0x48
 0xd82c: bl     #0x2378 ; <duss_log_print>
 0xd830: adrp   x4, #0x1a000
 0xd834: adrp   x5, #0x1c000
 0xd838: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd83c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd840: mov    w0, #0x51
 0xd844: mov    w6, #0x434
 0xd848: b      #0xe024
 0xd84c: adrp   x8, #0x1a000
 0xd850: str    wzr, [sp, #0x2c]
 0xd854: add    x8, x8, #0x440 ; =0x1a440
 0xd858: add    x1, sp, #0x30
 0xd85c: add    x2, sp, #0x2c
 0xd860: str    x8, [sp, #0x30]
 0xd864: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd868: adrp   x19, #0x1a000
 0xd86c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd870: adrp   x5, #0x1c000
 0xd874: mov    w20, #0x455
 0xd878: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd87c: mov    w0, #0x51
 0xd880: add    x2, sp, #0x48
 0xd884: mov    w3, #0x80
 0xd888: mov    w1, wzr
 0xd88c: mov    x4, x19
 0xd890: mov    w6, w20
 0xd894: bl     #0x2368 ; <duss_log_gen_head>
 0xd898: cbz    w0, #0xd8d4
 0xd89c: ldr    x5, [sp, #0x30]
 0xd8a0: adrp   x3, #0x1a000
 0xd8a4: ldr    w6, [sp, #0x2c]
 0xd8a8: adrp   x4, #0x1a000
 0xd8ac: adrp   x7, #0x1c000
 0xd8b0: str    w20, [sp, #8]
 0xd8b4: mov    w1, wzr
 0xd8b8: str    x19, [sp]
 0xd8bc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xd8c0: add    x4, x4, #0x441 ; "co"
 0xd8c4: mov    w0, #0x51
 0xd8c8: add    x7, x7, #0x7cf ; "ics_buffer->ics_buffer == ((void*)0)"
 0xd8cc: add    x2, sp, #0x48
 0xd8d0: bl     #0x2378 ; <duss_log_print>
 0xd8d4: adrp   x4, #0x1a000
 0xd8d8: adrp   x5, #0x1c000
 0xd8dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd8e0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd8e4: mov    w0, #0x51
 0xd8e8: mov    w6, #0x455
 0xd8ec: b      #0xe024
 0xd8f0: bl     #0x2348 ; <co_thread_get>
 0xd8f4: cbnz   x0, #0xd9b8
 0xd8f8: adrp   x4, #0x1a000
 0xd8fc: adrp   x5, #0x1c000
 0xd900: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd904: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd908: mov    w0, #0x51
 0xd90c: mov    w6, #0x43b
 0xd910: add    x2, sp, #0x48
 0xd914: mov    w3, #0x80
 0xd918: mov    w1, wzr
 0xd91c: bl     #0x2368 ; <duss_log_gen_head>
 0xd920: cbz    w0, #0xda40
 0xd924: adrp   x3, #0x1a000
 0xd928: adrp   x4, #0x1a000
 0xd92c: adrp   x5, #0x1a000
 0xd930: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd934: add    x4, x4, #0xfdc ; "eng->encoding_request_pool"
 0xd938: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd93c: mov    w0, #0x51
 0xd940: mov    w6, #0x43b
 0xd944: add    x2, sp, #0x48
 0xd948: mov    w1, wzr
 0xd94c: bl     #0x2378 ; <duss_log_print>
 0xd950: b      #0xda40
 0xd954: bl     #0x2348 ; <co_thread_get>
 0xd958: cbnz   x0, #0xda5c
 0xd95c: adrp   x4, #0x1a000
 0xd960: adrp   x5, #0x1c000
 0xd964: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd968: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd96c: mov    w0, #0x51
 0xd970: mov    w6, #0x441
 0xd974: add    x2, sp, #0x48
 0xd978: mov    w3, #0x80
 0xd97c: mov    w1, wzr
 0xd980: bl     #0x2368 ; <duss_log_gen_head>
 0xd984: cbz    w0, #0xdae4
 0xd988: adrp   x3, #0x1a000
 0xd98c: adrp   x4, #0x1c000
 0xd990: adrp   x5, #0x1a000
 0xd994: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xd998: add    x4, x4, #0x640 ; "eng->encoding_request_q == ((void*)0)"
 0xd99c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd9a0: mov    w0, #0x51
 0xd9a4: mov    w6, #0x441
 0xd9a8: add    x2, sp, #0x48
 0xd9ac: mov    w1, wzr
 0xd9b0: bl     #0x2378 ; <duss_log_print>
 0xd9b4: b      #0xdae4
 0xd9b8: adrp   x8, #0x1a000
 0xd9bc: str    wzr, [sp, #0x2c]
 0xd9c0: add    x8, x8, #0x440 ; =0x1a440
 0xd9c4: add    x1, sp, #0x30
 0xd9c8: add    x2, sp, #0x2c
 0xd9cc: str    x8, [sp, #0x30]
 0xd9d0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xd9d4: adrp   x19, #0x1a000
 0xd9d8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xd9dc: adrp   x5, #0x1c000
 0xd9e0: mov    w20, #0x43b
 0xd9e4: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xd9e8: mov    w0, #0x51
 0xd9ec: add    x2, sp, #0x48
 0xd9f0: mov    w3, #0x80
 0xd9f4: mov    w1, wzr
 0xd9f8: mov    x4, x19
 0xd9fc: mov    w6, w20
 0xda00: bl     #0x2368 ; <duss_log_gen_head>
 0xda04: cbz    w0, #0xda40
 0xda08: ldr    x5, [sp, #0x30]
 0xda0c: adrp   x3, #0x1a000
 0xda10: ldr    w6, [sp, #0x2c]
 0xda14: adrp   x4, #0x1a000
 0xda18: adrp   x7, #0x1a000
 0xda1c: str    w20, [sp, #8]
 0xda20: mov    w1, wzr
 0xda24: str    x19, [sp]
 0xda28: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xda2c: add    x4, x4, #0x441 ; "co"
 0xda30: mov    w0, #0x51
 0xda34: add    x7, x7, #0xfdc ; "eng->encoding_request_pool"
 0xda38: add    x2, sp, #0x48
 0xda3c: bl     #0x2378 ; <duss_log_print>
 0xda40: adrp   x4, #0x1a000
 0xda44: adrp   x5, #0x1c000
 0xda48: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xda4c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xda50: mov    w0, #0x51
 0xda54: mov    w6, #0x43b
 0xda58: b      #0xe024
 0xda5c: adrp   x8, #0x1a000
 0xda60: str    wzr, [sp, #0x2c]
 0xda64: add    x8, x8, #0x440 ; =0x1a440
 0xda68: add    x1, sp, #0x30
 0xda6c: add    x2, sp, #0x2c
 0xda70: str    x8, [sp, #0x30]
 0xda74: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xda78: adrp   x19, #0x1a000
 0xda7c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xda80: adrp   x5, #0x1c000
 0xda84: mov    w20, #0x441
 0xda88: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xda8c: mov    w0, #0x51
 0xda90: add    x2, sp, #0x48
 0xda94: mov    w3, #0x80
 0xda98: mov    w1, wzr
 0xda9c: mov    x4, x19
 0xdaa0: mov    w6, w20
 0xdaa4: bl     #0x2368 ; <duss_log_gen_head>
 0xdaa8: cbz    w0, #0xdae4
 0xdaac: ldr    x5, [sp, #0x30]
 0xdab0: adrp   x3, #0x1a000
 0xdab4: ldr    w6, [sp, #0x2c]
 0xdab8: adrp   x4, #0x1a000
 0xdabc: adrp   x7, #0x1c000
 0xdac0: str    w20, [sp, #8]
 0xdac4: mov    w1, wzr
 0xdac8: str    x19, [sp]
 0xdacc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xdad0: add    x4, x4, #0x441 ; "co"
 0xdad4: mov    w0, #0x51
 0xdad8: add    x7, x7, #0x640 ; "eng->encoding_request_q == ((void*)0)"
 0xdadc: add    x2, sp, #0x48
 0xdae0: bl     #0x2378 ; <duss_log_print>
 0xdae4: adrp   x4, #0x1a000
 0xdae8: adrp   x5, #0x1c000
 0xdaec: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdaf0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdaf4: mov    w0, #0x51
 0xdaf8: mov    w6, #0x441
 0xdafc: b      #0xe024
 0xdb00: bl     #0x2348 ; <co_thread_get>
 0xdb04: cbnz   x0, #0xdc2c
 0xdb08: adrp   x4, #0x1a000
 0xdb0c: adrp   x5, #0x1c000
 0xdb10: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdb14: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdb18: mov    w0, #0x51
 0xdb1c: mov    w6, #0x449
 0xdb20: add    x2, sp, #0x48
 0xdb24: mov    w3, #0x80
 0xdb28: mov    w1, wzr
 0xdb2c: bl     #0x2368 ; <duss_log_gen_head>
 0xdb30: cbz    w0, #0xdcb4
 0xdb34: adrp   x3, #0x1a000
 0xdb38: adrp   x4, #0x1c000
 0xdb3c: adrp   x5, #0x1a000
 0xdb40: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xdb44: add    x4, x4, #0x6fa ; "eng->ics_buffer_pool_size == 0"
 0xdb48: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdb4c: mov    w0, #0x51
 0xdb50: mov    w6, #0x449
 0xdb54: add    x2, sp, #0x48
 0xdb58: mov    w1, wzr
 0xdb5c: bl     #0x2378 ; <duss_log_print>
 0xdb60: b      #0xdcb4
 0xdb64: bl     #0x2348 ; <co_thread_get>
 0xdb68: cbnz   x0, #0xdcd0
 0xdb6c: adrp   x4, #0x1a000
 0xdb70: adrp   x5, #0x1c000
 0xdb74: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdb78: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdb7c: mov    w0, #0x51
 0xdb80: mov    w6, #0x44a
 0xdb84: add    x2, sp, #0x48
 0xdb88: mov    w3, #0x80
 0xdb8c: mov    w1, wzr
 0xdb90: bl     #0x2368 ; <duss_log_gen_head>
 0xdb94: cbz    w0, #0xdd58
 0xdb98: adrp   x3, #0x1a000
 0xdb9c: adrp   x4, #0x1c000
 0xdba0: adrp   x5, #0x1a000
 0xdba4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xdba8: add    x4, x4, #0x719 ; "eng->config.base.buffer_nr > 0"
 0xdbac: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdbb0: mov    w0, #0x51
 0xdbb4: mov    w6, #0x44a
 0xdbb8: add    x2, sp, #0x48
 0xdbbc: mov    w1, wzr
 0xdbc0: bl     #0x2378 ; <duss_log_print>
 0xdbc4: b      #0xdd58
 0xdbc8: bl     #0x2348 ; <co_thread_get>
 0xdbcc: cbnz   x0, #0xdd74
 0xdbd0: adrp   x4, #0x1a000
 0xdbd4: adrp   x5, #0x1c000
 0xdbd8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdbdc: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdbe0: mov    w0, #0x51
 0xdbe4: mov    w6, #0x44c
 0xdbe8: add    x2, sp, #0x48
 0xdbec: mov    w3, #0x80
 0xdbf0: mov    w1, wzr
 0xdbf4: bl     #0x2368 ; <duss_log_gen_head>
 0xdbf8: cbz    w0, #0xddfc
 0xdbfc: adrp   x3, #0x1a000
 0xdc00: adrp   x4, #0x1c000
 0xdc04: adrp   x5, #0x1a000
 0xdc08: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xdc0c: add    x4, x4, #0x738 ; "eng->ics_buffer_array == ((void*)0)"
 0xdc10: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdc14: mov    w0, #0x51
 0xdc18: mov    w6, #0x44c
 0xdc1c: add    x2, sp, #0x48
 0xdc20: mov    w1, wzr
 0xdc24: bl     #0x2378 ; <duss_log_print>
 0xdc28: b      #0xddfc
 0xdc2c: adrp   x8, #0x1a000
 0xdc30: str    wzr, [sp, #0x2c]
 0xdc34: add    x8, x8, #0x440 ; =0x1a440
 0xdc38: add    x1, sp, #0x30
 0xdc3c: add    x2, sp, #0x2c
 0xdc40: str    x8, [sp, #0x30]
 0xdc44: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xdc48: adrp   x19, #0x1a000
 0xdc4c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdc50: adrp   x5, #0x1c000
 0xdc54: mov    w20, #0x449
 0xdc58: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdc5c: mov    w0, #0x51
 0xdc60: add    x2, sp, #0x48
 0xdc64: mov    w3, #0x80
 0xdc68: mov    w1, wzr
 0xdc6c: mov    x4, x19
 0xdc70: mov    w6, w20
 0xdc74: bl     #0x2368 ; <duss_log_gen_head>
 0xdc78: cbz    w0, #0xdcb4
 0xdc7c: ldr    x5, [sp, #0x30]
 0xdc80: adrp   x3, #0x1a000
 0xdc84: ldr    w6, [sp, #0x2c]
 0xdc88: adrp   x4, #0x1a000
 0xdc8c: adrp   x7, #0x1c000
 0xdc90: str    w20, [sp, #8]
 0xdc94: mov    w1, wzr
 0xdc98: str    x19, [sp]
 0xdc9c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xdca0: add    x4, x4, #0x441 ; "co"
 0xdca4: mov    w0, #0x51
 0xdca8: add    x7, x7, #0x6fa ; "eng->ics_buffer_pool_size == 0"
 0xdcac: add    x2, sp, #0x48
 0xdcb0: bl     #0x2378 ; <duss_log_print>
 0xdcb4: adrp   x4, #0x1a000
 0xdcb8: adrp   x5, #0x1c000
 0xdcbc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdcc0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdcc4: mov    w0, #0x51
 0xdcc8: mov    w6, #0x449
 0xdccc: b      #0xe024
 0xdcd0: adrp   x8, #0x1a000
 0xdcd4: str    wzr, [sp, #0x2c]
 0xdcd8: add    x8, x8, #0x440 ; =0x1a440
 0xdcdc: add    x1, sp, #0x30
 0xdce0: add    x2, sp, #0x2c
 0xdce4: str    x8, [sp, #0x30]
 0xdce8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xdcec: adrp   x19, #0x1a000
 0xdcf0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdcf4: adrp   x5, #0x1c000
 0xdcf8: mov    w20, #0x44a
 0xdcfc: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdd00: mov    w0, #0x51
 0xdd04: add    x2, sp, #0x48
 0xdd08: mov    w3, #0x80
 0xdd0c: mov    w1, wzr
 0xdd10: mov    x4, x19
 0xdd14: mov    w6, w20
 0xdd18: bl     #0x2368 ; <duss_log_gen_head>
 0xdd1c: cbz    w0, #0xdd58
 0xdd20: ldr    x5, [sp, #0x30]
 0xdd24: adrp   x3, #0x1a000
 0xdd28: ldr    w6, [sp, #0x2c]
 0xdd2c: adrp   x4, #0x1a000
 0xdd30: adrp   x7, #0x1c000
 0xdd34: str    w20, [sp, #8]
 0xdd38: mov    w1, wzr
 0xdd3c: str    x19, [sp]
 0xdd40: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xdd44: add    x4, x4, #0x441 ; "co"
 0xdd48: mov    w0, #0x51
 0xdd4c: add    x7, x7, #0x719 ; "eng->config.base.buffer_nr > 0"
 0xdd50: add    x2, sp, #0x48
 0xdd54: bl     #0x2378 ; <duss_log_print>
 0xdd58: adrp   x4, #0x1a000
 0xdd5c: adrp   x5, #0x1c000
 0xdd60: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdd64: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdd68: mov    w0, #0x51
 0xdd6c: mov    w6, #0x44a
 0xdd70: b      #0xe024
 0xdd74: adrp   x8, #0x1a000
 0xdd78: str    wzr, [sp, #0x2c]
 0xdd7c: add    x8, x8, #0x440 ; =0x1a440
 0xdd80: add    x1, sp, #0x30
 0xdd84: add    x2, sp, #0x2c
 0xdd88: str    x8, [sp, #0x30]
 0xdd8c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xdd90: adrp   x19, #0x1a000
 0xdd94: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdd98: adrp   x5, #0x1c000
 0xdd9c: mov    w20, #0x44c
 0xdda0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdda4: mov    w0, #0x51
 0xdda8: add    x2, sp, #0x48
 0xddac: mov    w3, #0x80
 0xddb0: mov    w1, wzr
 0xddb4: mov    x4, x19
 0xddb8: mov    w6, w20
 0xddbc: bl     #0x2368 ; <duss_log_gen_head>
 0xddc0: cbz    w0, #0xddfc
 0xddc4: ldr    x5, [sp, #0x30]
 0xddc8: adrp   x3, #0x1a000
 0xddcc: ldr    w6, [sp, #0x2c]
 0xddd0: adrp   x4, #0x1a000
 0xddd4: adrp   x7, #0x1c000
 0xddd8: str    w20, [sp, #8]
 0xdddc: mov    w1, wzr
 0xdde0: str    x19, [sp]
 0xdde4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xdde8: add    x4, x4, #0x441 ; "co"
 0xddec: mov    w0, #0x51
 0xddf0: add    x7, x7, #0x738 ; "eng->ics_buffer_array == ((void*)0)"
 0xddf4: add    x2, sp, #0x48
 0xddf8: bl     #0x2378 ; <duss_log_print>
 0xddfc: adrp   x4, #0x1a000
 0xde00: adrp   x5, #0x1c000
 0xde04: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xde08: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xde0c: mov    w0, #0x51
 0xde10: mov    w6, #0x44c
 0xde14: b      #0xe024
 0xde18: bl     #0x2348 ; <co_thread_get>
 0xde1c: cbnz   x0, #0xde7c
 0xde20: adrp   x4, #0x1a000
 0xde24: adrp   x5, #0x1c000
 0xde28: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xde2c: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xde30: mov    w0, #0x51
 0xde34: mov    w6, #0x45d
 0xde38: add    x2, sp, #0x48
 0xde3c: mov    w3, #0x80
 0xde40: mov    w1, wzr
 0xde44: bl     #0x2368 ; <duss_log_gen_head>
 0xde48: cbz    w0, #0xdf04
 0xde4c: adrp   x3, #0x1a000
 0xde50: adrp   x4, #0x1c000
 0xde54: adrp   x5, #0x1a000
 0xde58: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xde5c: add    x4, x4, #0x865 ; "eng->ics_buffer_pool == ((void*)0)"
 0xde60: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xde64: mov    w0, #0x51
 0xde68: mov    w6, #0x45d
 0xde6c: add    x2, sp, #0x48
 0xde70: mov    w1, wzr
 0xde74: bl     #0x2378 ; <duss_log_print>
 0xde78: b      #0xdf04
 0xde7c: adrp   x8, #0x1a000
 0xde80: str    wzr, [sp, #0x2c]
 0xde84: add    x8, x8, #0x440 ; =0x1a440
 0xde88: add    x1, sp, #0x30
 0xde8c: add    x2, sp, #0x2c
 0xde90: str    x8, [sp, #0x30]
 0xde94: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xde98: adrp   x19, #0x1a000
 0xde9c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdea0: adrp   x5, #0x1c000
 0xdea4: mov    w20, #0x45d
 0xdea8: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdeac: mov    w0, #0x51
 0xdeb0: add    x2, sp, #0x48
 0xdeb4: mov    w3, #0x80
 0xdeb8: mov    w1, wzr
 0xdebc: mov    x4, x19
 0xdec0: mov    w6, w20
 0xdec4: bl     #0x2368 ; <duss_log_gen_head>
 0xdec8: cbz    w0, #0xdf04
 0xdecc: ldr    x5, [sp, #0x30]
 0xded0: adrp   x3, #0x1a000
 0xded4: ldr    w6, [sp, #0x2c]
 0xded8: adrp   x4, #0x1a000
 0xdedc: adrp   x7, #0x1c000
 0xdee0: str    w20, [sp, #8]
 0xdee4: mov    w1, wzr
 0xdee8: str    x19, [sp]
 0xdeec: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xdef0: add    x4, x4, #0x441 ; "co"
 0xdef4: mov    w0, #0x51
 0xdef8: add    x7, x7, #0x865 ; "eng->ics_buffer_pool == ((void*)0)"
 0xdefc: add    x2, sp, #0x48
 0xdf00: bl     #0x2378 ; <duss_log_print>
 0xdf04: adrp   x4, #0x1a000
 0xdf08: adrp   x5, #0x1c000
 0xdf0c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdf10: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdf14: mov    w0, #0x51
 0xdf18: mov    w6, #0x45d
 0xdf1c: b      #0xe024
 0xdf20: bl     #0x2348 ; <co_thread_get>
 0xdf24: cbnz   x0, #0xdf84
 0xdf28: adrp   x4, #0x1a000
 0xdf2c: adrp   x5, #0x1c000
 0xdf30: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdf34: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdf38: mov    w0, #0x51
 0xdf3c: mov    w6, #0x464
 0xdf40: add    x2, sp, #0x48
 0xdf44: mov    w3, #0x80
 0xdf48: mov    w1, wzr
 0xdf4c: bl     #0x2368 ; <duss_log_gen_head>
 0xdf50: cbz    w0, #0xe00c
 0xdf54: adrp   x3, #0x1a000
 0xdf58: adrp   x4, #0x1c000
 0xdf5c: adrp   x5, #0x1a000
 0xdf60: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xdf64: add    x4, x4, #0x90b ; "eng->ics_buffer_pool"
 0xdf68: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdf6c: mov    w0, #0x51
 0xdf70: mov    w6, #0x464
 0xdf74: add    x2, sp, #0x48
 0xdf78: mov    w1, wzr
 0xdf7c: bl     #0x2378 ; <duss_log_print>
 0xdf80: b      #0xe00c
 0xdf84: adrp   x8, #0x1a000
 0xdf88: str    wzr, [sp, #0x2c]
 0xdf8c: add    x8, x8, #0x440 ; =0x1a440
 0xdf90: add    x1, sp, #0x30
 0xdf94: add    x2, sp, #0x2c
 0xdf98: str    x8, [sp, #0x30]
 0xdf9c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xdfa0: adrp   x19, #0x1a000
 0xdfa4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xdfa8: adrp   x5, #0x1c000
 0xdfac: mov    w20, #0x464
 0xdfb0: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xdfb4: mov    w0, #0x51
 0xdfb8: add    x2, sp, #0x48
 0xdfbc: mov    w3, #0x80
 0xdfc0: mov    w1, wzr
 0xdfc4: mov    x4, x19
 0xdfc8: mov    w6, w20
 0xdfcc: bl     #0x2368 ; <duss_log_gen_head>
 0xdfd0: cbz    w0, #0xe00c
 0xdfd4: ldr    x5, [sp, #0x30]
 0xdfd8: adrp   x3, #0x1a000
 0xdfdc: ldr    w6, [sp, #0x2c]
 0xdfe0: adrp   x4, #0x1a000
 0xdfe4: adrp   x7, #0x1c000
 0xdfe8: str    w20, [sp, #8]
 0xdfec: mov    w1, wzr
 0xdff0: str    x19, [sp]
 0xdff4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xdff8: add    x4, x4, #0x441 ; "co"
 0xdffc: mov    w0, #0x51
 0xe000: add    x7, x7, #0x90b ; "eng->ics_buffer_pool"
 0xe004: add    x2, sp, #0x48
 0xe008: bl     #0x2378 ; <duss_log_print>
 0xe00c: adrp   x4, #0x1a000
 0xe010: adrp   x5, #0x1c000
 0xe014: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe018: add    x5, x5, #0x31d ; "_proresraw_venc_eng_create_encoded_buffer_allocator"
 0xe01c: mov    w0, #0x51
 0xe020: mov    w6, #0x464
 0xe024: add    x2, sp, #0x48
 0xe028: mov    w3, #0x80
 0xe02c: mov    w1, wzr
 0xe030: bl     #0x2368 ; <duss_log_gen_head>
 0xe034: cbz    w0, #0xe050
 0xe038: adrp   x3, #0x1a000
 0xe03c: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xe040: mov    w0, #0x51
 0xe044: add    x2, sp, #0x48
 0xe048: mov    w1, wzr
 0xe04c: bl     #0x2378 ; <duss_log_print>
 0xe050: adrp   x0, #0x1a000
 0xe054: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xe058: bl     #0x23e8 ; <log_to_kmsg>
 0xe05c: adrp   x0, #0x1a000
 0xe060: add    x0, x0, #0x57f ; "Camera:	"
 0xe064: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xe068: bl     #0x2408 ; <is_running_in_cam_sil>
 0xe06c: tbz    w0, #0, #0xe07c
 0xe070: mov    x0, xzr
 0xe074: bl     #0x2418 ; <fflush>
 0xe078: bl     #0x2428 ; <abort>
 0xe07c: mov    w0, #1
 0xe080: bl     #0x2438 ; <exit>
 0xe084: udf    #0
 0xe088: sub    sp, sp, #0xe0
 0xe08c: str    x21, [sp, #0xb0]
 0xe090: stp    x20, x19, [sp, #0xc0]
 0xe094: stp    x29, x30, [sp, #0xd0]
 0xe098: add    x29, sp, #0xd0
 0xe09c: mrs    x20, tpidr_el0
 0xe0a0: adrp   x0, #0x30000
 0xe0a4: ldr    x8, [x20, #0x28]
 0xe0a8: adrp   x2, #0x1a000
 0xe0ac: add    x21, sp, #0x10
 0xe0b0: mov    x19, x1
 0xe0b4: add    x0, x0, #8 ; =0x30008
 0xe0b8: mov    w1, #5
 0xe0bc: str    x8, [x21]
 0xe0c0: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xe0c4: bl     #0x2338 ; <log_mgr_check>
 0xe0c8: tbz    w0, #0, #0xe1a0
 0xe0cc: bl     #0x2348 ; <co_thread_get>
 0xe0d0: cbz    x0, #0xe154
 0xe0d4: adrp   x8, #0x1a000
 0xe0d8: str    wzr, [sp, #0x1c]
 0xe0dc: add    x8, x8, #0x440 ; =0x1a440
 0xe0e0: add    x1, sp, #0x20
 0xe0e4: add    x2, sp, #0x1c
 0xe0e8: str    x8, [sp, #0x20]
 0xe0ec: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xe0f0: adrp   x4, #0x1a000
 0xe0f4: adrp   x5, #0x1c000
 0xe0f8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe0fc: add    x5, x5, #0xed8 ; "_proresraw_venc_eng_get_max_stream_buffer_count_per_encoded"
 0xe100: mov    w0, #0x51
 0xe104: mov    w6, #0x4a1
 0xe108: mov    w1, #3
 0xe10c: add    x2, sp, #0x28
 0xe110: mov    w3, #0x80
 0xe114: bl     #0x2368 ; <duss_log_gen_head>
 0xe118: cbz    w0, #0xe1a0
 0xe11c: ldr    x6, [sp, #0x20]
 0xe120: adrp   x3, #0x1c000
 0xe124: ldr    w7, [sp, #0x1c]
 0xe128: adrp   x4, #0x1a000
 0xe12c: adrp   x5, #0x1a000
 0xe130: add    x3, x3, #0xf14 ; "%s: %s(%s_%x): get_max_stream_buffer_count_per_encoded
"
 0xe134: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xe138: add    x5, x5, #0x441 ; "co"
 0xe13c: mov    w0, #0x51
 0xe140: mov    w1, #3
 0xe144: add    x2, sp, #0x28
 0xe148: bl     #0x2378 ; <duss_log_print>
 0xe14c: cbnz   x19, #0xe1a4
 0xe150: b      #0xe1d4
 0xe154: adrp   x4, #0x1a000
 0xe158: adrp   x5, #0x1c000
 0xe15c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe160: add    x5, x5, #0xed8 ; "_proresraw_venc_eng_get_max_stream_buffer_count_per_encoded"
 0xe164: mov    w0, #0x51
 0xe168: mov    w6, #0x4a1
 0xe16c: mov    w1, #3
 0xe170: add    x2, sp, #0x28
 0xe174: mov    w3, #0x80
 0xe178: bl     #0x2368 ; <duss_log_gen_head>
 0xe17c: cbz    w0, #0xe1a0
 0xe180: adrp   x3, #0x1c000
 0xe184: adrp   x4, #0x1a000
 0xe188: add    x3, x3, #0xf4c ; "%s: get_max_stream_buffer_count_per_encoded
"
 0xe18c: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xe190: mov    w0, #0x51
 0xe194: mov    w1, #3
 0xe198: add    x2, sp, #0x28
 0xe19c: bl     #0x2378 ; <duss_log_print>
 0xe1a0: cbz    x19, #0xe1d4
 0xe1a4: mov    w8, #2
 0xe1a8: str    w8, [x19]
 0xe1ac: ldr    x8, [x20, #0x28]
 0xe1b0: ldr    x9, [x21]
 0xe1b4: cmp    x8, x9
 0xe1b8: b.ne   #0xe238
 0xe1bc: ldp    x29, x30, [sp, #0xd0]
 0xe1c0: ldp    x20, x19, [sp, #0xc0]
 0xe1c4: ldr    x21, [sp, #0xb0]
 0xe1c8: mov    w0, wzr
 0xe1cc: add    sp, sp, #0xe0
 0xe1d0: ret    
 0xe1d4: bl     #0x2348 ; <co_thread_get>
 0xe1d8: cbnz   x0, #0xe23c
 0xe1dc: adrp   x4, #0x1a000
 0xe1e0: adrp   x5, #0x1c000
 0xe1e4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe1e8: add    x5, x5, #0xed8 ; "_proresraw_venc_eng_get_max_stream_buffer_count_per_encoded"
 0xe1ec: mov    w0, #0x51
 0xe1f0: mov    w6, #0x4a2
 0xe1f4: add    x2, sp, #0x28
 0xe1f8: mov    w3, #0x80
 0xe1fc: mov    w1, wzr
 0xe200: bl     #0x2368 ; <duss_log_gen_head>
 0xe204: cbz    w0, #0xe2c4
 0xe208: adrp   x3, #0x1a000
 0xe20c: adrp   x4, #0x1c000
 0xe210: adrp   x5, #0x1a000
 0xe214: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xe218: add    x4, x4, #0xf79 ; "buffer_count"
 0xe21c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe220: mov    w0, #0x51
 0xe224: mov    w6, #0x4a2
 0xe228: add    x2, sp, #0x28
 0xe22c: mov    w1, wzr
 0xe230: bl     #0x2378 ; <duss_log_print>
 0xe234: b      #0xe2c4
 0xe238: bl     #0x23d8 ; <__stack_chk_fail>
 0xe23c: adrp   x8, #0x1a000
 0xe240: str    wzr, [sp, #0x1c]
 0xe244: add    x8, x8, #0x440 ; =0x1a440
 0xe248: add    x1, sp, #0x20
 0xe24c: add    x2, sp, #0x1c
 0xe250: str    x8, [sp, #0x20]
 0xe254: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xe258: adrp   x19, #0x1a000
 0xe25c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe260: adrp   x5, #0x1c000
 0xe264: mov    w20, #0x4a2
 0xe268: add    x5, x5, #0xed8 ; "_proresraw_venc_eng_get_max_stream_buffer_count_per_encoded"
 0xe26c: mov    w0, #0x51
 0xe270: add    x2, sp, #0x28
 0xe274: mov    w3, #0x80
 0xe278: mov    w1, wzr
 0xe27c: mov    x4, x19
 0xe280: mov    w6, w20
 0xe284: bl     #0x2368 ; <duss_log_gen_head>
 0xe288: cbz    w0, #0xe2c4
 0xe28c: ldr    x5, [sp, #0x20]
 0xe290: adrp   x3, #0x1a000
 0xe294: ldr    w6, [sp, #0x1c]
 0xe298: adrp   x4, #0x1a000
 0xe29c: adrp   x7, #0x1c000
 0xe2a0: str    w20, [sp, #8]
 0xe2a4: mov    w1, wzr
 0xe2a8: str    x19, [sp]
 0xe2ac: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xe2b0: add    x4, x4, #0x441 ; "co"
 0xe2b4: mov    w0, #0x51
 0xe2b8: add    x7, x7, #0xf79 ; "buffer_count"
 0xe2bc: add    x2, sp, #0x28
 0xe2c0: bl     #0x2378 ; <duss_log_print>
 0xe2c4: adrp   x4, #0x1a000
 0xe2c8: adrp   x5, #0x1c000
 0xe2cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe2d0: add    x5, x5, #0xed8 ; "_proresraw_venc_eng_get_max_stream_buffer_count_per_encoded"
 0xe2d4: mov    w0, #0x51
 0xe2d8: mov    w6, #0x4a2
 0xe2dc: add    x2, sp, #0x28
 0xe2e0: mov    w3, #0x80
 0xe2e4: mov    w1, wzr
 0xe2e8: bl     #0x2368 ; <duss_log_gen_head>
 0xe2ec: cbz    w0, #0xe308
 0xe2f0: adrp   x3, #0x1a000
 0xe2f4: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xe2f8: mov    w0, #0x51
 0xe2fc: add    x2, sp, #0x28
 0xe300: mov    w1, wzr
 0xe304: bl     #0x2378 ; <duss_log_print>
 0xe308: adrp   x0, #0x1a000
 0xe30c: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xe310: bl     #0x23e8 ; <log_to_kmsg>
 0xe314: adrp   x0, #0x1a000
 0xe318: add    x0, x0, #0x57f ; "Camera:	"
 0xe31c: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xe320: bl     #0x2408 ; <is_running_in_cam_sil>
 0xe324: tbz    w0, #0, #0xe334
 0xe328: mov    x0, xzr
 0xe32c: bl     #0x2418 ; <fflush>
 0xe330: bl     #0x2428 ; <abort>
 0xe334: mov    w0, #1
 0xe338: bl     #0x2438 ; <exit>
 0xe33c: udf    #0
 0xe340: sub    sp, sp, #0xc0
 0xe344: stp    x20, x19, [sp, #0xa0]
 0xe348: stp    x29, x30, [sp, #0xb0]
 0xe34c: add    x29, sp, #0xb0
 0xe350: mrs    x19, tpidr_el0
 0xe354: adrp   x0, #0x30000
 0xe358: ldr    x8, [x19, #0x28]
 0xe35c: adrp   x2, #0x1a000
 0xe360: mov    x20, sp
 0xe364: add    x0, x0, #8 ; =0x30008
 0xe368: mov    w1, #5
 0xe36c: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xe370: str    x8, [x20]
 0xe374: bl     #0x2338 ; <log_mgr_check>
 0xe378: tbz    w0, #0, #0xe44c
 0xe37c: bl     #0x2348 ; <co_thread_get>
 0xe380: cbz    x0, #0xe400
 0xe384: adrp   x8, #0x1a000
 0xe388: str    wzr, [sp, #0xc]
 0xe38c: add    x8, x8, #0x440 ; =0x1a440
 0xe390: add    x1, sp, #0x10
 0xe394: add    x2, sp, #0xc
 0xe398: str    x8, [sp, #0x10]
 0xe39c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xe3a0: adrp   x4, #0x1a000
 0xe3a4: adrp   x5, #0x1c000
 0xe3a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe3ac: add    x5, x5, #0xf86 ; "_proresraw_venc_eng_get_all_stream_buffer_info"
 0xe3b0: mov    w0, #0x51
 0xe3b4: mov    w6, #0x4ae
 0xe3b8: mov    w1, #3
 0xe3bc: add    x2, sp, #0x18
 0xe3c0: mov    w3, #0x80
 0xe3c4: bl     #0x2368 ; <duss_log_gen_head>
 0xe3c8: cbz    w0, #0xe44c
 0xe3cc: ldr    x6, [sp, #0x10]
 0xe3d0: adrp   x3, #0x1c000
 0xe3d4: ldr    w7, [sp, #0xc]
 0xe3d8: adrp   x4, #0x1a000
 0xe3dc: adrp   x5, #0x1a000
 0xe3e0: add    x3, x3, #0xfb5 ; "%s: %s(%s_%x): get_all_stream_buffer_info
"
 0xe3e4: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xe3e8: add    x5, x5, #0x441 ; "co"
 0xe3ec: mov    w0, #0x51
 0xe3f0: mov    w1, #3
 0xe3f4: add    x2, sp, #0x18
 0xe3f8: bl     #0x2378 ; <duss_log_print>
 0xe3fc: b      #0xe44c
 0xe400: adrp   x4, #0x1a000
 0xe404: adrp   x5, #0x1c000
 0xe408: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe40c: add    x5, x5, #0xf86 ; "_proresraw_venc_eng_get_all_stream_buffer_info"
 0xe410: mov    w0, #0x51
 0xe414: mov    w6, #0x4ae
 0xe418: mov    w1, #3
 0xe41c: add    x2, sp, #0x18
 0xe420: mov    w3, #0x80
 0xe424: bl     #0x2368 ; <duss_log_gen_head>
 0xe428: cbz    w0, #0xe44c
 0xe42c: adrp   x3, #0x1c000
 0xe430: adrp   x4, #0x1a000
 0xe434: add    x3, x3, #0xfe0 ; "%s: get_all_stream_buffer_info
"
 0xe438: add    x4, x4, #0x5c4 ; "PRORESRAW"
 0xe43c: mov    w0, #0x51
 0xe440: mov    w1, #3
 0xe444: add    x2, sp, #0x18
 0xe448: bl     #0x2378 ; <duss_log_print>
 0xe44c: ldr    x8, [x19, #0x28]
 0xe450: ldr    x9, [x20]
 0xe454: cmp    x8, x9
 0xe458: b.ne   #0xe470
 0xe45c: ldp    x29, x30, [sp, #0xb0]
 0xe460: ldp    x20, x19, [sp, #0xa0]
 0xe464: mov    w0, wzr
 0xe468: add    sp, sp, #0xc0
 0xe46c: ret    
 0xe470: bl     #0x23d8 ; <__stack_chk_fail>
 0xe474: udf    #0
 0xe478: stp    x24, x23, [sp, #-0x40]!
 0xe47c: stp    x22, x21, [sp, #0x10]
 0xe480: stp    x20, x19, [sp, #0x20]
 0xe484: stp    x29, x30, [sp, #0x30]
 0xe488: add    x29, sp, #0x30
 0xe48c: mov    x19, x0
 0xe490: cbz    x19, #0xe58c
 0xe494: ldr    x0, [x19, #0x3f8]
 0xe498: cbz    x0, #0xe4a4
 0xe49c: bl     #0x26a8 ; <buffer_queue_destroy>
 0xe4a0: str    xzr, [x19, #0x3f8]
 0xe4a4: ldr    x20, [x19, #0x3f0]
 0xe4a8: cbz    x20, #0xe520
 0xe4ac: ldr    w8, [x19, #0x400]
 0xe4b0: cbz    w8, #0xe508
 0xe4b4: adrp   x22, #0x1a000
 0xe4b8: mov    w23, #8
 0xe4bc: mov    w24, #1
 0xe4c0: mov    w21, #0x9d
 0xe4c4: add    x22, x22, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe4c8: ldr    x0, [x20, x23]
 0xe4cc: cbnz   x0, #0xe4e8
 0xe4d0: b      #0xe4fc
 0xe4d4: ldr    x20, [x19, #0x3f0]
 0xe4d8: add    x23, x23, #0x10 ; =0x1a010
 0xe4dc: add    x24, x24, #1 ; =0x1a001
 0xe4e0: ldr    x0, [x20, x23]
 0xe4e4: cbz    x0, #0xe4fc
 0xe4e8: mov    x1, x22
 0xe4ec: mov    w2, w21
 0xe4f0: bl     #0x26b8 ; <vmem_free_dbg>
 0xe4f4: str    xzr, [x20, x23]
 0xe4f8: ldr    w8, [x19, #0x400]
 0xe4fc: cmp    x24, w8, uxtw
 0xe500: b.lo   #0xe4d4
 0xe504: ldr    x20, [x19, #0x3f0]
 0xe508: adrp   x1, #0x1a000
 0xe50c: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe510: mov    w2, #0xa1
 0xe514: mov    x0, x20
 0xe518: bl     #0x26c8 ; <cam_free_internal>
 0xe51c: str    xzr, [x19, #0x3f0]
 0xe520: ldr    x0, [x19, #0x430]
 0xe524: cbz    x0, #0xe530
 0xe528: bl     #0x26a8 ; <buffer_queue_destroy>
 0xe52c: str    xzr, [x19, #0x430]
 0xe530: ldr    x0, [x19, #0x420]
 0xe534: cbz    x0, #0xe540
 0xe538: bl     #0x26a8 ; <buffer_queue_destroy>
 0xe53c: str    xzr, [x19, #0x420]
 0xe540: ldr    x0, [x19, #0x418]
 0xe544: cbz    x0, #0xe55c
 0xe548: adrp   x1, #0x1a000
 0xe54c: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe550: mov    w2, #0xad
 0xe554: bl     #0x26c8 ; <cam_free_internal>
 0xe558: str    xzr, [x19, #0x418]
 0xe55c: mov    x0, x19
 0xe560: mov    x1, xzr
 0xe564: bl     #0x11ec8
 0xe568: mov    x0, x19
 0xe56c: ldp    x29, x30, [sp, #0x30]
 0xe570: ldp    x20, x19, [sp, #0x20]
 0xe574: ldp    x22, x21, [sp, #0x10]
 0xe578: adrp   x1, #0x1a000
 0xe57c: add    x1, x1, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe580: mov    w2, #0xb3
 0xe584: ldp    x24, x23, [sp], #0x40
 0xe588: b      #0x26c8 ; <cam_free_internal>
 0xe58c: ldp    x29, x30, [sp, #0x30]
 0xe590: ldp    x20, x19, [sp, #0x20]
 0xe594: ldp    x22, x21, [sp, #0x10]
 0xe598: ldp    x24, x23, [sp], #0x40
 0xe59c: ret    
 0xe5a0: sub    sp, sp, #0xe0
 0xe5a4: stp    x22, x21, [sp, #0xb0]
 0xe5a8: stp    x20, x19, [sp, #0xc0]
 0xe5ac: stp    x29, x30, [sp, #0xd0]
 0xe5b0: add    x29, sp, #0xd0
 0xe5b4: mrs    x21, tpidr_el0
 0xe5b8: mov    x19, x3
 0xe5bc: ldr    x8, [x21, #0x28]
 0xe5c0: mov    x20, x2
 0xe5c4: add    x22, sp, #0x10
 0xe5c8: str    x8, [x22]
 0xe5cc: cbz    x19, #0xe620
 0xe5d0: cmp    w1, #0x19
 0xe5d4: b.ne   #0xe5f8
 0xe5d8: adrp   x1, #0x1a000
 0xe5dc: add    x1, x1, #0x82f ; "allocator_count_threshold"
 0xe5e0: mov    w2, #0x19
 0xe5e4: bl     #0x26d8 ; <strncmp>
 0xe5e8: cbnz   w0, #0xe5f8
 0xe5ec: mov    x0, x20
 0xe5f0: bl     #0x26e8 ; <atoi>
 0xe5f4: str    w0, [x19, #0x458]
 0xe5f8: ldr    x8, [x21, #0x28]
 0xe5fc: ldr    x9, [x22]
 0xe600: cmp    x8, x9
 0xe604: b.ne   #0xe684
 0xe608: ldp    x29, x30, [sp, #0xd0]
 0xe60c: ldp    x20, x19, [sp, #0xc0]
 0xe610: ldp    x22, x21, [sp, #0xb0]
 0xe614: mov    w0, wzr
 0xe618: add    sp, sp, #0xe0
 0xe61c: ret    
 0xe620: bl     #0x2348 ; <co_thread_get>
 0xe624: cbnz   x0, #0xe688
 0xe628: adrp   x4, #0x1a000
 0xe62c: adrp   x5, #0x1a000
 0xe630: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe634: add    x5, x5, #0x825 ; "_on_param"
 0xe638: mov    w0, #0x51
 0xe63c: mov    w6, #0xe8
 0xe640: add    x2, sp, #0x28
 0xe644: mov    w3, #0x80
 0xe648: mov    w1, wzr
 0xe64c: bl     #0x2368 ; <duss_log_gen_head>
 0xe650: cbz    w0, #0xe710
 0xe654: adrp   x3, #0x1a000
 0xe658: adrp   x4, #0x1a000
 0xe65c: adrp   x5, #0x1a000
 0xe660: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xe664: add    x4, x4, #0x821 ; "eng"
 0xe668: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe66c: mov    w0, #0x51
 0xe670: mov    w6, #0xe8
 0xe674: add    x2, sp, #0x28
 0xe678: mov    w1, wzr
 0xe67c: bl     #0x2378 ; <duss_log_print>
 0xe680: b      #0xe710
 0xe684: bl     #0x23d8 ; <__stack_chk_fail>
 0xe688: adrp   x8, #0x1a000
 0xe68c: str    wzr, [sp, #0x1c]
 0xe690: add    x8, x8, #0x440 ; =0x1a440
 0xe694: add    x1, sp, #0x20
 0xe698: add    x2, sp, #0x1c
 0xe69c: str    x8, [sp, #0x20]
 0xe6a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xe6a4: adrp   x19, #0x1a000
 0xe6a8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe6ac: adrp   x5, #0x1a000
 0xe6b0: mov    w20, #0xe8
 0xe6b4: add    x5, x5, #0x825 ; "_on_param"
 0xe6b8: mov    w0, #0x51
 0xe6bc: add    x2, sp, #0x28
 0xe6c0: mov    w3, #0x80
 0xe6c4: mov    w1, wzr
 0xe6c8: mov    x4, x19
 0xe6cc: mov    w6, w20
 0xe6d0: bl     #0x2368 ; <duss_log_gen_head>
 0xe6d4: cbz    w0, #0xe710
 0xe6d8: ldr    x5, [sp, #0x20]
 0xe6dc: adrp   x3, #0x1a000
 0xe6e0: ldr    w6, [sp, #0x1c]
 0xe6e4: adrp   x4, #0x1a000
 0xe6e8: adrp   x7, #0x1a000
 0xe6ec: str    w20, [sp, #8]
 0xe6f0: mov    w1, wzr
 0xe6f4: str    x19, [sp]
 0xe6f8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xe6fc: add    x4, x4, #0x441 ; "co"
 0xe700: mov    w0, #0x51
 0xe704: add    x7, x7, #0x821 ; "eng"
 0xe708: add    x2, sp, #0x28
 0xe70c: bl     #0x2378 ; <duss_log_print>
 0xe710: adrp   x4, #0x1a000
 0xe714: adrp   x5, #0x1a000
 0xe718: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xe71c: add    x5, x5, #0x825 ; "_on_param"
 0xe720: mov    w0, #0x51
 0xe724: mov    w6, #0xe8
 0xe728: add    x2, sp, #0x28
 0xe72c: mov    w3, #0x80
 0xe730: mov    w1, wzr
 0xe734: bl     #0x2368 ; <duss_log_gen_head>
 0xe738: cbz    w0, #0xe754
 0xe73c: adrp   x3, #0x1a000
 0xe740: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xe744: mov    w0, #0x51
 0xe748: add    x2, sp, #0x28
 0xe74c: mov    w1, wzr
 0xe750: bl     #0x2378 ; <duss_log_print>
 0xe754: adrp   x0, #0x1a000
 0xe758: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xe75c: bl     #0x23e8 ; <log_to_kmsg>
 0xe760: adrp   x0, #0x1a000
 0xe764: add    x0, x0, #0x57f ; "Camera:	"
 0xe768: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xe76c: bl     #0x2408 ; <is_running_in_cam_sil>
 0xe770: tbz    w0, #0, #0xe780
 0xe774: mov    x0, xzr
 0xe778: bl     #0x2418 ; <fflush>
 0xe77c: bl     #0x2428 ; <abort>
 0xe780: mov    w0, #1
 0xe784: bl     #0x2438 ; <exit>
 0xe788: sub    sp, sp, #0x120
 0xe78c: stp    x28, x19, [sp, #0x100]
 0xe790: stp    x29, x30, [sp, #0x110]
 0xe794: add    x29, sp, #0x110
 0xe798: mrs    x19, tpidr_el0
 0xe79c: stp    q6, q7, [sp, #0x70]
 0xe7a0: stp    q4, q5, [sp, #0x50]
 0xe7a4: mov    w11, #-0x80
 0xe7a8: stp    q2, q3, [sp, #0x30]
 0xe7ac: mov    w12, #-0x20
 0xe7b0: stp    q0, q1, [sp, #0x10]
 0xe7b4: add    x13, sp, #0x10
 0xe7b8: stp    x6, x7, [x29, #-0x70]
 0xe7bc: add    x13, x13, #0x80
 0xe7c0: stp    x4, x5, [x29, #-0x80]
 0xe7c4: mov    x8, x3
 0xe7c8: ldr    x10, [x19, #0x28]
 0xe7cc: mov    x9, x1
 0xe7d0: sub    x5, x29, #0x60
 0xe7d4: mov    x1, x2
 0xe7d8: mov    w2, wzr
 0xe7dc: str    x10, [sp, #8]
 0xe7e0: sub    x10, x29, #0x80
 0xe7e4: stp    w12, w11, [x29, #-0x20]
 0xe7e8: add    x10, x10, #0x20 ; =0x1e020
 0xe7ec: add    x11, x29, #0x10
 0xe7f0: sub    x12, x29, #0x38
 0xe7f4: stp    x10, x13, [x29, #-0x30]
 0xe7f8: mov    x3, x9
 0xe7fc: stur   x11, [x29, #-0x38]
 0xe800: mov    x4, x8
 0xe804: ldp    q1, q0, [x12]
 0xe808: stp    q1, q0, [x29, #-0x60]
 0xe80c: bl     #0x26f8 ; <__vsnprintf_chk>
 0xe810: ldr    x8, [x19, #0x28]
 0xe814: ldr    x9, [sp, #8]
 0xe818: cmp    x8, x9
 0xe81c: b.ne   #0xe830
 0xe820: ldp    x29, x30, [sp, #0x110]
 0xe824: ldp    x28, x19, [sp, #0x100]
 0xe828: add    sp, sp, #0x120
 0xe82c: ret    
 0xe830: bl     #0x23d8 ; <__stack_chk_fail>
 0xe834: udf    #0
 0xe838: sub    sp, sp, #0x140
 0xe83c: stp    x28, x27, [sp, #0xe0]
 0xe840: stp    x26, x25, [sp, #0xf0]
 0xe844: stp    x24, x23, [sp, #0x100]
 0xe848: stp    x22, x21, [sp, #0x110]
 0xe84c: stp    x20, x19, [sp, #0x120]
 0xe850: stp    x29, x30, [sp, #0x130]
 0xe854: add    x29, sp, #0x130
 0xe858: mrs    x25, tpidr_el0
 0xe85c: mov    x19, x2
 0xe860: ldr    x8, [x25, #0x28]
 0xe864: mov    x20, x1
 0xe868: mov    x21, x0
 0xe86c: add    x26, sp, #0x18
 0xe870: str    x8, [x26]
 0xe874: stp    xzr, xzr, [sp, #0x40]
 0xe878: cbz    x21, #0xf370
 0xe87c: cbz    x20, #0xf3d4
 0xe880: cbz    x19, #0xf438
 0xe884: add    x0, sp, #0x50
 0xe888: bl     #0x25c8 ; <duss_osal_get_boot_time>
 0xe88c: ldr    x22, [sp, #0x50]
 0xe890: add    x0, sp, #0x30
 0xe894: bl     #0x25c8 ; <duss_osal_get_boot_time>
 0xe898: ldr    x0, [x21, #0x408]
 0xe89c: cbz    x0, #0xf1a0
 0xe8a0: mov    w27, #0x4240
 0xe8a4: movk   w27, #0xf, lsl #16
 0xe8a8: add    x28, x22, x27
 0xe8ac: mov    w22, #0x4240
 0xe8b0: movk   w22, #0xf, lsl #16
 0xe8b4: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xe8b8: mov    w23, w0
 0xe8bc: bl     #0x24d8 ; <duss_osal_get_exec_obj_id>
 0xe8c0: mov    w24, w0
 0xe8c4: ldr    x0, [x21, #0x490]
 0xe8c8: tbnz   w24, #0x1f, #0xe9dc
 0xe8cc: cbz    x0, #0xe8e0
 0xe8d0: ldrh   w1, [x21, #0x4a0]
 0xe8d4: cbz    w1, #0xe8e0
 0xe8d8: mov    w2, w24
 0xe8dc: bl     #0x24e8 ; <perf_trace_coroutine_slice_begin>
 0xe8e0: cbz    w23, #0xe9ac
 0xe8e4: ldr    x0, [x21, #0x490]
 0xe8e8: cbz    x0, #0xe8fc
 0xe8ec: ldrh   w1, [x21, #0x4a0]
 0xe8f0: cbz    w1, #0xe8fc
 0xe8f4: mov    w2, w24
 0xe8f8: bl     #0x24f8 ; <perf_trace_coroutine_slice_end>
 0xe8fc: cmp    w23, #1
 0xe900: b.lt   #0xe954
 0xe904: mov    w24, wzr
 0xe908: ldr    x0, [x21, #0x408]
 0xe90c: add    x1, sp, #0x48
 0xe910: bl     #0x2508 ; <buffer_queue_dequeue>
 0xe914: cbnz   w0, #0xeba8
 0xe918: ldr    x0, [sp, #0x48]
 0xe91c: cbz    x0, #0xec0c
 0xe920: add    x1, sp, #0x40
 0xe924: bl     #0x2708 ; <cam_encoded_buffer_allocator_buffer_get>
 0xe928: mov    w8, w0
 0xe92c: ldr    x0, [sp, #0x40]
 0xe930: cbz    w8, #0xea3c
 0xe934: cbnz   x0, #0xec70
 0xe938: ldr    x0, [x21, #0x408]
 0xe93c: add    x1, sp, #0x48
 0xe940: bl     #0x2588 ; <buffer_queue_enqueue>
 0xe944: cbnz   w0, #0xecd4
 0xe948: add    w24, w24, #1
 0xe94c: cmp    w24, w23
 0xe950: b.lt   #0xe908
 0xe954: add    x0, sp, #0x38
 0xe958: bl     #0x25c8 ; <duss_osal_get_boot_time>
 0xe95c: ldr    x9, [x21, #0x3c8]
 0xe960: cbz    x9, #0xf204
 0xe964: ldp    x10, x8, [sp, #0x30]
 0xe968: subs   x8, x8, x10
 0xe96c: b.lo   #0xf268
 0xe970: udiv   x9, x27, x9
 0xe974: cmp    x9, x8
 0xe978: b.ls   #0xe984
 0xe97c: sub    w0, w9, w8
 0xe980: bl     #0x2488 ; <duss_osal_task_sleep>
 0xe984: add    x0, sp, #0x38
 0xe988: bl     #0x25c8 ; <duss_osal_get_boot_time>
 0xe98c: ldr    x8, [sp, #0x38]
 0xe990: cmp    x28, x8
 0xe994: b.ls   #0xeac0
 0xe998: add    x0, sp, #0x30
 0xe99c: bl     #0x25c8 ; <duss_osal_get_boot_time>
 0xe9a0: ldr    x0, [x21, #0x408]
 0xe9a4: cbnz   x0, #0xe8b4
 0xe9a8: b      #0xf1a0
 0xe9ac: ldr    x0, [x21, #0x488]
 0xe9b0: mov    w1, #3
 0xe9b4: mov    w2, #1
 0xe9b8: mov    w3, w22
 0xe9bc: mov    x4, xzr
 0xe9c0: bl     #0x2718 ; <duss_osal_event_wait>
 0xe9c4: cbnz   w0, #0xead8
 0xe9c8: ldr    x0, [x21, #0x408]
 0xe9cc: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xe9d0: mov    w23, w0
 0xe9d4: cbz    w23, #0xe9ac
 0xe9d8: b      #0xe8e4
 0xe9dc: cbz    x0, #0xe9ec
 0xe9e0: ldrh   w1, [x21, #0x4a0]
 0xe9e4: cbz    w1, #0xe9ec
 0xe9e8: bl     #0x25a8 ; <perf_trace_slice_begin>
 0xe9ec: cbnz   w23, #0xea1c
 0xe9f0: ldr    x0, [x21, #0x488]
 0xe9f4: mov    w1, #3
 0xe9f8: mov    w2, #1
 0xe9fc: mov    w3, w22
 0xea00: mov    x4, xzr
 0xea04: bl     #0x2718 ; <duss_osal_event_wait>
 0xea08: cbnz   w0, #0xead8
 0xea0c: ldr    x0, [x21, #0x408]
 0xea10: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
 0xea14: mov    w23, w0
 0xea18: cbz    w23, #0xe9f0
 0xea1c: ldr    x0, [x21, #0x490]
 0xea20: cbz    x0, #0xe8fc
 0xea24: ldrh   w1, [x21, #0x4a0]
 0xea28: cbz    w1, #0xe8fc
 0xea2c: bl     #0x25b8 ; <perf_trace_slice_end>
 0xea30: cmp    w23, #1
 0xea34: b.ge   #0xe904
 0xea38: b      #0xe954
 0xea3c: cbz    x0, #0xf4a0
 0xea40: ldr    w8, [x0, #0x24]
 0xea44: cmp    w8, #2
 0xea48: b.ne   #0xf504
 0xea4c: ldr    w8, [x0, #0x20]
 0xea50: cbz    w8, #0xf568
 0xea54: cmp    w8, #3
 0xea58: b.hs   #0xf5cc
 0xea5c: ldr    x8, [x0]
 0xea60: sbfx   x8, x8, #0, #0x17
 0xea64: cbnz   w8, #0xf630
 0xea68: bl     #0x2578 ; <stream_buffer_group_addref>
 0xea6c: ldr    x8, [sp, #0x40]
 0xea70: ldr    x9, [x8]
 0xea74: sbfx   x9, x9, #0, #0x17
 0xea78: cmp    w9, #1
 0xea7c: b.ne   #0xf694
 0xea80: ldr    x9, [sp, #0x48]
 0xea84: mov    w0, wzr
 0xea88: str    x9, [x20]
 0xea8c: str    x8, [x19]
 0xea90: ldr    x8, [x25, #0x28]
 0xea94: ldr    x9, [x26]
 0xea98: cmp    x8, x9
 0xea9c: b.ne   #0xf49c
 0xeaa0: ldp    x29, x30, [sp, #0x130]
 0xeaa4: ldp    x20, x19, [sp, #0x120]
 0xeaa8: ldp    x22, x21, [sp, #0x110]
 0xeaac: ldp    x24, x23, [sp, #0x100]
 0xeab0: ldp    x26, x25, [sp, #0xf0]
 0xeab4: ldp    x28, x27, [sp, #0xe0]
 0xeab8: add    sp, sp, #0x140
 0xeabc: ret    
 0xeac0: ldr    x8, [sp, #0x40]
 0xeac4: cbnz   x8, #0xfe0c
 0xeac8: mov    w0, #-0x3ea
 0xeacc: str    xzr, [x20]
 0xead0: str    xzr, [x19]
 0xead4: b      #0xea90
 0xead8: cmn    w0, #0x3ea
 0xeadc: b.ne   #0xeb44
 0xeae0: bl     #0x2348 ; <co_thread_get>
 0xeae4: cbnz   x0, #0xed38
 0xeae8: adrp   x4, #0x1a000
 0xeaec: adrp   x5, #0x1b000
 0xeaf0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xeaf4: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xeaf8: mov    w0, #0x51
 0xeafc: mov    w6, #0x20a
 0xeb00: add    x2, sp, #0x58
 0xeb04: mov    w3, #0x80
 0xeb08: mov    w1, wzr
 0xeb0c: bl     #0x2368 ; <duss_log_gen_head>
 0xeb10: cbz    w0, #0xedc0
 0xeb14: adrp   x3, #0x1a000
 0xeb18: adrp   x4, #0x1b000
 0xeb1c: adrp   x5, #0x1a000
 0xeb20: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xeb24: add    x4, x4, #0xf7 ; "0"
 0xeb28: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xeb2c: mov    w0, #0x51
 0xeb30: mov    w6, #0x20a
 0xeb34: add    x2, sp, #0x58
 0xeb38: mov    w1, wzr
 0xeb3c: bl     #0x2378 ; <duss_log_print>
 0xeb40: b      #0xedc0
 0xeb44: bl     #0x2348 ; <co_thread_get>
 0xeb48: cbnz   x0, #0xee10
 0xeb4c: adrp   x4, #0x1a000
 0xeb50: adrp   x5, #0x1b000
 0xeb54: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xeb58: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xeb5c: mov    w0, #0x51
 0xeb60: mov    w6, #0x20e
 0xeb64: add    x2, sp, #0x58
 0xeb68: mov    w3, #0x80
 0xeb6c: mov    w1, wzr
 0xeb70: bl     #0x2368 ; <duss_log_gen_head>
 0xeb74: cbz    w0, #0xee98
 0xeb78: adrp   x3, #0x1a000
 0xeb7c: adrp   x4, #0x1b000
 0xeb80: adrp   x5, #0x1a000
 0xeb84: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xeb88: add    x4, x4, #0xf7 ; "0"
 0xeb8c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xeb90: mov    w0, #0x51
 0xeb94: mov    w6, #0x20e
 0xeb98: add    x2, sp, #0x58
 0xeb9c: mov    w1, wzr
 0xeba0: bl     #0x2378 ; <duss_log_print>
 0xeba4: b      #0xee98
 0xeba8: bl     #0x2348 ; <co_thread_get>
 0xebac: cbnz   x0, #0xeeb4
 0xebb0: adrp   x4, #0x1a000
 0xebb4: adrp   x5, #0x1b000
 0xebb8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xebbc: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xebc0: mov    w0, #0x51
 0xebc4: mov    w6, #0x215
 0xebc8: add    x2, sp, #0x58
 0xebcc: mov    w3, #0x80
 0xebd0: mov    w1, wzr
 0xebd4: bl     #0x2368 ; <duss_log_gen_head>
 0xebd8: cbz    w0, #0xef3c
 0xebdc: adrp   x3, #0x1a000
 0xebe0: adrp   x4, #0x1b000
 0xebe4: adrp   x5, #0x1a000
 0xebe8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xebec: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xebf0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xebf4: mov    w0, #0x51
 0xebf8: mov    w6, #0x215
 0xebfc: add    x2, sp, #0x58
 0xec00: mov    w1, wzr
 0xec04: bl     #0x2378 ; <duss_log_print>
 0xec08: b      #0xef3c
 0xec0c: bl     #0x2348 ; <co_thread_get>
 0xec10: cbnz   x0, #0xef58
 0xec14: adrp   x4, #0x1a000
 0xec18: adrp   x5, #0x1b000
 0xec1c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xec20: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xec24: mov    w0, #0x51
 0xec28: mov    w6, #0x216
 0xec2c: add    x2, sp, #0x58
 0xec30: mov    w3, #0x80
 0xec34: mov    w1, wzr
 0xec38: bl     #0x2368 ; <duss_log_gen_head>
 0xec3c: cbz    w0, #0xefe0
 0xec40: adrp   x3, #0x1a000
 0xec44: adrp   x4, #0x1b000
 0xec48: adrp   x5, #0x1a000
 0xec4c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xec50: add    x4, x4, #0xc89 ; "alloc"
 0xec54: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xec58: mov    w0, #0x51
 0xec5c: mov    w6, #0x216
 0xec60: add    x2, sp, #0x58
 0xec64: mov    w1, wzr
 0xec68: bl     #0x2378 ; <duss_log_print>
 0xec6c: b      #0xefe0
 0xec70: bl     #0x2348 ; <co_thread_get>
 0xec74: cbnz   x0, #0xeffc
 0xec78: adrp   x4, #0x1a000
 0xec7c: adrp   x5, #0x1b000
 0xec80: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xec84: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xec88: mov    w0, #0x51
 0xec8c: mov    w6, #0x228
 0xec90: add    x2, sp, #0x58
 0xec94: mov    w3, #0x80
 0xec98: mov    w1, wzr
 0xec9c: bl     #0x2368 ; <duss_log_gen_head>
 0xeca0: cbz    w0, #0xf084
 0xeca4: adrp   x3, #0x1a000
 0xeca8: adrp   x4, #0x1b000
 0xecac: adrp   x5, #0x1a000
 0xecb0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xecb4: add    x4, x4, #0xcfe ; "sbg == ((void*)0)"
 0xecb8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xecbc: mov    w0, #0x51
 0xecc0: mov    w6, #0x228
 0xecc4: add    x2, sp, #0x58
 0xecc8: mov    w1, wzr
 0xeccc: bl     #0x2378 ; <duss_log_print>
 0xecd0: b      #0xf084
 0xecd4: bl     #0x2348 ; <co_thread_get>
 0xecd8: cbnz   x0, #0xf0a0
 0xecdc: adrp   x4, #0x1a000
 0xece0: adrp   x5, #0x1b000
 0xece4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xece8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xecec: mov    w0, #0x51
 0xecf0: mov    w6, #0x22c
 0xecf4: add    x2, sp, #0x58
 0xecf8: mov    w3, #0x80
 0xecfc: mov    w1, wzr
 0xed00: bl     #0x2368 ; <duss_log_gen_head>
 0xed04: cbz    w0, #0xf128
 0xed08: adrp   x3, #0x1a000
 0xed0c: adrp   x4, #0x1b000
 0xed10: adrp   x5, #0x1a000
 0xed14: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xed18: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xed1c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xed20: mov    w0, #0x51
 0xed24: mov    w6, #0x22c
 0xed28: add    x2, sp, #0x58
 0xed2c: mov    w1, wzr
 0xed30: bl     #0x2378 ; <duss_log_print>
 0xed34: b      #0xf128
 0xed38: adrp   x8, #0x1a000
 0xed3c: str    wzr, [sp, #0x24]
 0xed40: add    x8, x8, #0x440 ; =0x1a440
 0xed44: add    x1, sp, #0x28
 0xed48: add    x2, sp, #0x24
 0xed4c: str    x8, [sp, #0x28]
 0xed50: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xed54: adrp   x19, #0x1a000
 0xed58: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xed5c: adrp   x5, #0x1b000
 0xed60: mov    w20, #0x20a
 0xed64: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xed68: mov    w0, #0x51
 0xed6c: add    x2, sp, #0x58
 0xed70: mov    w3, #0x80
 0xed74: mov    w1, wzr
 0xed78: mov    x4, x19
 0xed7c: mov    w6, w20
 0xed80: bl     #0x2368 ; <duss_log_gen_head>
 0xed84: cbz    w0, #0xedc0
 0xed88: ldr    x5, [sp, #0x28]
 0xed8c: adrp   x3, #0x1a000
 0xed90: ldr    w6, [sp, #0x24]
 0xed94: adrp   x4, #0x1a000
 0xed98: adrp   x7, #0x1b000
 0xed9c: str    w20, [sp, #8]
 0xeda0: mov    w1, wzr
 0xeda4: str    x19, [sp]
 0xeda8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xedac: add    x4, x4, #0x441 ; "co"
 0xedb0: mov    w0, #0x51
 0xedb4: add    x7, x7, #0xf7 ; "0"
 0xedb8: add    x2, sp, #0x58
 0xedbc: bl     #0x2378 ; <duss_log_print>
 0xedc0: adrp   x4, #0x1a000
 0xedc4: adrp   x5, #0x1b000
 0xedc8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xedcc: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xedd0: mov    w0, #0x51
 0xedd4: mov    w6, #0x20a
 0xedd8: add    x2, sp, #0x58
 0xeddc: mov    w3, #0x80
 0xede0: mov    w1, wzr
 0xede4: bl     #0x2368 ; <duss_log_gen_head>
 0xede8: cbz    w0, #0xee04
 0xedec: adrp   x3, #0x1b000
 0xedf0: add    x3, x3, #0xbfe ; "Assertion Comment: no available ringbuffer allocator for 1 second"
 0xedf4: mov    w0, #0x51
 0xedf8: add    x2, sp, #0x58
 0xedfc: mov    w1, wzr
 0xee00: bl     #0x2378 ; <duss_log_print>
 0xee04: adrp   x0, #0x1b000
 0xee08: add    x0, x0, #0xc40 ; "Camera Assertion Comment: no available ringbuffer allocator for 1 second"
 0xee0c: b      #0xf174
 0xee10: adrp   x8, #0x1a000
 0xee14: str    wzr, [sp, #0x24]
 0xee18: add    x8, x8, #0x440 ; =0x1a440
 0xee1c: add    x1, sp, #0x28
 0xee20: add    x2, sp, #0x24
 0xee24: str    x8, [sp, #0x28]
 0xee28: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xee2c: adrp   x19, #0x1a000
 0xee30: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xee34: adrp   x5, #0x1b000
 0xee38: mov    w20, #0x20e
 0xee3c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xee40: mov    w0, #0x51
 0xee44: add    x2, sp, #0x58
 0xee48: mov    w3, #0x80
 0xee4c: mov    w1, wzr
 0xee50: mov    x4, x19
 0xee54: mov    w6, w20
 0xee58: bl     #0x2368 ; <duss_log_gen_head>
 0xee5c: cbz    w0, #0xee98
 0xee60: ldr    x5, [sp, #0x28]
 0xee64: adrp   x3, #0x1a000
 0xee68: ldr    w6, [sp, #0x24]
 0xee6c: adrp   x4, #0x1a000
 0xee70: adrp   x7, #0x1b000
 0xee74: str    w20, [sp, #8]
 0xee78: mov    w1, wzr
 0xee7c: str    x19, [sp]
 0xee80: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xee84: add    x4, x4, #0x441 ; "co"
 0xee88: mov    w0, #0x51
 0xee8c: add    x7, x7, #0xf7 ; "0"
 0xee90: add    x2, sp, #0x58
 0xee94: bl     #0x2378 ; <duss_log_print>
 0xee98: adrp   x4, #0x1a000
 0xee9c: adrp   x5, #0x1b000
 0xeea0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xeea4: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xeea8: mov    w0, #0x51
 0xeeac: mov    w6, #0x20e
 0xeeb0: b      #0xf140
 0xeeb4: adrp   x8, #0x1a000
 0xeeb8: str    wzr, [sp, #0x24]
 0xeebc: add    x8, x8, #0x440 ; =0x1a440
 0xeec0: add    x1, sp, #0x28
 0xeec4: add    x2, sp, #0x24
 0xeec8: str    x8, [sp, #0x28]
 0xeecc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xeed0: adrp   x19, #0x1a000
 0xeed4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xeed8: adrp   x5, #0x1b000
 0xeedc: mov    w20, #0x215
 0xeee0: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xeee4: mov    w0, #0x51
 0xeee8: add    x2, sp, #0x58
 0xeeec: mov    w3, #0x80
 0xeef0: mov    w1, wzr
 0xeef4: mov    x4, x19
 0xeef8: mov    w6, w20
 0xeefc: bl     #0x2368 ; <duss_log_gen_head>
 0xef00: cbz    w0, #0xef3c
 0xef04: ldr    x5, [sp, #0x28]
 0xef08: adrp   x3, #0x1a000
 0xef0c: ldr    w6, [sp, #0x24]
 0xef10: adrp   x4, #0x1a000
 0xef14: adrp   x7, #0x1b000
 0xef18: str    w20, [sp, #8]
 0xef1c: mov    w1, wzr
 0xef20: str    x19, [sp]
 0xef24: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xef28: add    x4, x4, #0x441 ; "co"
 0xef2c: mov    w0, #0x51
 0xef30: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xef34: add    x2, sp, #0x58
 0xef38: bl     #0x2378 ; <duss_log_print>
 0xef3c: adrp   x4, #0x1a000
 0xef40: adrp   x5, #0x1b000
 0xef44: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xef48: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xef4c: mov    w0, #0x51
 0xef50: mov    w6, #0x215
 0xef54: b      #0xf140
 0xef58: adrp   x8, #0x1a000
 0xef5c: str    wzr, [sp, #0x24]
 0xef60: add    x8, x8, #0x440 ; =0x1a440
 0xef64: add    x1, sp, #0x28
 0xef68: add    x2, sp, #0x24
 0xef6c: str    x8, [sp, #0x28]
 0xef70: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xef74: adrp   x19, #0x1a000
 0xef78: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xef7c: adrp   x5, #0x1b000
 0xef80: mov    w20, #0x216
 0xef84: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xef88: mov    w0, #0x51
 0xef8c: add    x2, sp, #0x58
 0xef90: mov    w3, #0x80
 0xef94: mov    w1, wzr
 0xef98: mov    x4, x19
 0xef9c: mov    w6, w20
 0xefa0: bl     #0x2368 ; <duss_log_gen_head>
 0xefa4: cbz    w0, #0xefe0
 0xefa8: ldr    x5, [sp, #0x28]
 0xefac: adrp   x3, #0x1a000
 0xefb0: ldr    w6, [sp, #0x24]
 0xefb4: adrp   x4, #0x1a000
 0xefb8: adrp   x7, #0x1b000
 0xefbc: str    w20, [sp, #8]
 0xefc0: mov    w1, wzr
 0xefc4: str    x19, [sp]
 0xefc8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xefcc: add    x4, x4, #0x441 ; "co"
 0xefd0: mov    w0, #0x51
 0xefd4: add    x7, x7, #0xc89 ; "alloc"
 0xefd8: add    x2, sp, #0x58
 0xefdc: bl     #0x2378 ; <duss_log_print>
 0xefe0: adrp   x4, #0x1a000
 0xefe4: adrp   x5, #0x1b000
 0xefe8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xefec: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xeff0: mov    w0, #0x51
 0xeff4: mov    w6, #0x216
 0xeff8: b      #0xf140
 0xeffc: adrp   x8, #0x1a000
 0xf000: str    wzr, [sp, #0x24]
 0xf004: add    x8, x8, #0x440 ; =0x1a440
 0xf008: add    x1, sp, #0x28
 0xf00c: add    x2, sp, #0x24
 0xf010: str    x8, [sp, #0x28]
 0xf014: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf018: adrp   x19, #0x1a000
 0xf01c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf020: adrp   x5, #0x1b000
 0xf024: mov    w20, #0x228
 0xf028: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf02c: mov    w0, #0x51
 0xf030: add    x2, sp, #0x58
 0xf034: mov    w3, #0x80
 0xf038: mov    w1, wzr
 0xf03c: mov    x4, x19
 0xf040: mov    w6, w20
 0xf044: bl     #0x2368 ; <duss_log_gen_head>
 0xf048: cbz    w0, #0xf084
 0xf04c: ldr    x5, [sp, #0x28]
 0xf050: adrp   x3, #0x1a000
 0xf054: ldr    w6, [sp, #0x24]
 0xf058: adrp   x4, #0x1a000
 0xf05c: adrp   x7, #0x1b000
 0xf060: str    w20, [sp, #8]
 0xf064: mov    w1, wzr
 0xf068: str    x19, [sp]
 0xf06c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf070: add    x4, x4, #0x441 ; "co"
 0xf074: mov    w0, #0x51
 0xf078: add    x7, x7, #0xcfe ; "sbg == ((void*)0)"
 0xf07c: add    x2, sp, #0x58
 0xf080: bl     #0x2378 ; <duss_log_print>
 0xf084: adrp   x4, #0x1a000
 0xf088: adrp   x5, #0x1b000
 0xf08c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf090: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf094: mov    w0, #0x51
 0xf098: mov    w6, #0x228
 0xf09c: b      #0xf140
 0xf0a0: adrp   x8, #0x1a000
 0xf0a4: str    wzr, [sp, #0x24]
 0xf0a8: add    x8, x8, #0x440 ; =0x1a440
 0xf0ac: add    x1, sp, #0x28
 0xf0b0: add    x2, sp, #0x24
 0xf0b4: str    x8, [sp, #0x28]
 0xf0b8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf0bc: adrp   x19, #0x1a000
 0xf0c0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf0c4: adrp   x5, #0x1b000
 0xf0c8: mov    w20, #0x22c
 0xf0cc: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf0d0: mov    w0, #0x51
 0xf0d4: add    x2, sp, #0x58
 0xf0d8: mov    w3, #0x80
 0xf0dc: mov    w1, wzr
 0xf0e0: mov    x4, x19
 0xf0e4: mov    w6, w20
 0xf0e8: bl     #0x2368 ; <duss_log_gen_head>
 0xf0ec: cbz    w0, #0xf128
 0xf0f0: ldr    x5, [sp, #0x28]
 0xf0f4: adrp   x3, #0x1a000
 0xf0f8: ldr    w6, [sp, #0x24]
 0xf0fc: adrp   x4, #0x1a000
 0xf100: adrp   x7, #0x1b000
 0xf104: str    w20, [sp, #8]
 0xf108: mov    w1, wzr
 0xf10c: str    x19, [sp]
 0xf110: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf114: add    x4, x4, #0x441 ; "co"
 0xf118: mov    w0, #0x51
 0xf11c: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
 0xf120: add    x2, sp, #0x58
 0xf124: bl     #0x2378 ; <duss_log_print>
 0xf128: adrp   x4, #0x1a000
 0xf12c: adrp   x5, #0x1b000
 0xf130: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf134: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf138: mov    w0, #0x51
 0xf13c: mov    w6, #0x22c
 0xf140: add    x2, sp, #0x58
 0xf144: mov    w3, #0x80
 0xf148: mov    w1, wzr
 0xf14c: bl     #0x2368 ; <duss_log_gen_head>
 0xf150: cbz    w0, #0xf16c
 0xf154: adrp   x3, #0x1a000
 0xf158: add    x3, x3, #0x550 ; "Assertion Comment: "
 0xf15c: mov    w0, #0x51
 0xf160: add    x2, sp, #0x58
 0xf164: mov    w1, wzr
 0xf168: bl     #0x2378 ; <duss_log_print>
 0xf16c: adrp   x0, #0x1a000
 0xf170: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
 0xf174: bl     #0x23e8 ; <log_to_kmsg>
 0xf178: adrp   x0, #0x1a000
 0xf17c: add    x0, x0, #0x57f ; "Camera:	"
 0xf180: bl     #0x23f8 ; <duss_log_dump_backtrace>
 0xf184: bl     #0x2408 ; <is_running_in_cam_sil>
 0xf188: tbz    w0, #0, #0xf198
 0xf18c: mov    x0, xzr
 0xf190: bl     #0x2418 ; <fflush>
 0xf194: bl     #0x2428 ; <abort>
 0xf198: mov    w0, #1
 0xf19c: bl     #0x2438 ; <exit>
 0xf1a0: bl     #0x2348 ; <co_thread_get>
 0xf1a4: cbnz   x0, #0xf2cc
 0xf1a8: adrp   x4, #0x1a000
 0xf1ac: adrp   x5, #0x1b000
 0xf1b0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf1b4: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf1b8: mov    w0, #0x51
 0xf1bc: mov    w6, #0x202
 0xf1c0: add    x2, sp, #0x58
 0xf1c4: mov    w3, #0x80
 0xf1c8: mov    w1, wzr
 0xf1cc: bl     #0x2368 ; <duss_log_gen_head>
 0xf1d0: cbz    w0, #0xf354
 0xf1d4: adrp   x3, #0x1a000
 0xf1d8: adrp   x4, #0x1a000
 0xf1dc: adrp   x5, #0x1a000
 0xf1e0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf1e4: add    x4, x4, #0xfc8 ; "eng->allocator_pool"
 0xf1e8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf1ec: mov    w0, #0x51
 0xf1f0: mov    w6, #0x202
 0xf1f4: add    x2, sp, #0x58
 0xf1f8: mov    w1, wzr
 0xf1fc: bl     #0x2378 ; <duss_log_print>
 0xf200: b      #0xf354
 0xf204: bl     #0x2348 ; <co_thread_get>
 0xf208: cbnz   x0, #0xf6f8
 0xf20c: adrp   x4, #0x1a000
 0xf210: adrp   x5, #0x1b000
 0xf214: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf218: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf21c: mov    w0, #0x51
 0xf220: mov    w6, #0x235
 0xf224: add    x2, sp, #0x58
 0xf228: mov    w3, #0x80
 0xf22c: mov    w1, wzr
 0xf230: bl     #0x2368 ; <duss_log_gen_head>
 0xf234: cbz    w0, #0xf780
 0xf238: adrp   x3, #0x1a000
 0xf23c: adrp   x4, #0x1b000
 0xf240: adrp   x5, #0x1a000
 0xf244: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf248: add    x4, x4, #0xd10 ; "eng->fps"
 0xf24c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf250: mov    w0, #0x51
 0xf254: mov    w6, #0x235
 0xf258: add    x2, sp, #0x58
 0xf25c: mov    w1, wzr
 0xf260: bl     #0x2378 ; <duss_log_print>
 0xf264: b      #0xf780
 0xf268: bl     #0x2348 ; <co_thread_get>
 0xf26c: cbnz   x0, #0xf79c
 0xf270: adrp   x4, #0x1a000
 0xf274: adrp   x5, #0x1b000
 0xf278: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf27c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf280: mov    w0, #0x51
 0xf284: mov    w6, #0x237
 0xf288: add    x2, sp, #0x58
 0xf28c: mov    w3, #0x80
 0xf290: mov    w1, wzr
 0xf294: bl     #0x2368 ; <duss_log_gen_head>
 0xf298: cbz    w0, #0xf824
 0xf29c: adrp   x3, #0x1a000
 0xf2a0: adrp   x4, #0x1b000
 0xf2a4: adrp   x5, #0x1a000
 0xf2a8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf2ac: add    x4, x4, #0xd19 ; "time_now >= time_start"
 0xf2b0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf2b4: mov    w0, #0x51
 0xf2b8: mov    w6, #0x237
 0xf2bc: add    x2, sp, #0x58
 0xf2c0: mov    w1, wzr
 0xf2c4: bl     #0x2378 ; <duss_log_print>
 0xf2c8: b      #0xf824
 0xf2cc: adrp   x8, #0x1a000
 0xf2d0: str    wzr, [sp, #0x24]
 0xf2d4: add    x8, x8, #0x440 ; =0x1a440
 0xf2d8: add    x1, sp, #0x28
 0xf2dc: add    x2, sp, #0x24
 0xf2e0: str    x8, [sp, #0x28]
 0xf2e4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf2e8: adrp   x19, #0x1a000
 0xf2ec: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf2f0: adrp   x5, #0x1b000
 0xf2f4: mov    w20, #0x202
 0xf2f8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf2fc: mov    w0, #0x51
 0xf300: add    x2, sp, #0x58
 0xf304: mov    w3, #0x80
 0xf308: mov    w1, wzr
 0xf30c: mov    x4, x19
 0xf310: mov    w6, w20
 0xf314: bl     #0x2368 ; <duss_log_gen_head>
 0xf318: cbz    w0, #0xf354
 0xf31c: ldr    x5, [sp, #0x28]
 0xf320: adrp   x3, #0x1a000
 0xf324: ldr    w6, [sp, #0x24]
 0xf328: adrp   x4, #0x1a000
 0xf32c: adrp   x7, #0x1a000
 0xf330: str    w20, [sp, #8]
 0xf334: mov    w1, wzr
 0xf338: str    x19, [sp]
 0xf33c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf340: add    x4, x4, #0x441 ; "co"
 0xf344: mov    w0, #0x51
 0xf348: add    x7, x7, #0xfc8 ; "eng->allocator_pool"
 0xf34c: add    x2, sp, #0x58
 0xf350: bl     #0x2378 ; <duss_log_print>
 0xf354: adrp   x4, #0x1a000
 0xf358: adrp   x5, #0x1b000
 0xf35c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf360: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf364: mov    w0, #0x51
 0xf368: mov    w6, #0x202
 0xf36c: b      #0xf140
 0xf370: bl     #0x2348 ; <co_thread_get>
 0xf374: cbnz   x0, #0xf840
 0xf378: adrp   x4, #0x1a000
 0xf37c: adrp   x5, #0x1b000
 0xf380: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf384: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf388: mov    w0, #0x51
 0xf38c: add    x2, sp, #0x58
 0xf390: mov    w3, #0x80
 0xf394: mov    w6, #0x1f0
 0xf398: mov    w1, wzr
 0xf39c: bl     #0x2368 ; <duss_log_gen_head>
 0xf3a0: cbz    w0, #0xf8c8
 0xf3a4: adrp   x3, #0x1a000
 0xf3a8: adrp   x4, #0x1a000
 0xf3ac: adrp   x5, #0x1a000
 0xf3b0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf3b4: add    x4, x4, #0x5c0 ; "ops"
 0xf3b8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf3bc: mov    w0, #0x51
 0xf3c0: add    x2, sp, #0x58
 0xf3c4: mov    w6, #0x1f0
 0xf3c8: mov    w1, wzr
 0xf3cc: bl     #0x2378 ; <duss_log_print>
 0xf3d0: b      #0xf8c8
 0xf3d4: bl     #0x2348 ; <co_thread_get>
 0xf3d8: cbnz   x0, #0xf8ec
 0xf3dc: adrp   x4, #0x1a000
 0xf3e0: adrp   x5, #0x1b000
 0xf3e4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf3e8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf3ec: mov    w0, #0x51
 0xf3f0: mov    w6, #0x1f1
 0xf3f4: add    x2, sp, #0x58
 0xf3f8: mov    w3, #0x80
 0xf3fc: mov    w1, wzr
 0xf400: bl     #0x2368 ; <duss_log_gen_head>
 0xf404: cbz    w0, #0xf974
 0xf408: adrp   x3, #0x1a000
 0xf40c: adrp   x4, #0x1b000
 0xf410: adrp   x5, #0x1a000
 0xf414: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf418: add    x4, x4, #0xbbc ; "allocator"
 0xf41c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf420: mov    w0, #0x51
 0xf424: mov    w6, #0x1f1
 0xf428: add    x2, sp, #0x58
 0xf42c: mov    w1, wzr
 0xf430: bl     #0x2378 ; <duss_log_print>
 0xf434: b      #0xf974
 0xf438: bl     #0x2348 ; <co_thread_get>
 0xf43c: cbnz   x0, #0xf990
 0xf440: adrp   x4, #0x1a000
 0xf444: adrp   x5, #0x1b000
 0xf448: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf44c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf450: mov    w0, #0x51
 0xf454: mov    w6, #0x1f2
 0xf458: add    x2, sp, #0x58
 0xf45c: mov    w3, #0x80
 0xf460: mov    w1, wzr
 0xf464: bl     #0x2368 ; <duss_log_gen_head>
 0xf468: cbz    w0, #0xfa18
 0xf46c: adrp   x3, #0x1a000
 0xf470: adrp   x4, #0x1b000
 0xf474: adrp   x5, #0x1a000
 0xf478: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf47c: add    x4, x4, #0xbf1 ; "buffer_group"
 0xf480: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf484: mov    w0, #0x51
 0xf488: mov    w6, #0x1f2
 0xf48c: add    x2, sp, #0x58
 0xf490: mov    w1, wzr
 0xf494: bl     #0x2378 ; <duss_log_print>
 0xf498: b      #0xfa18
 0xf49c: bl     #0x23d8 ; <__stack_chk_fail>
 0xf4a0: bl     #0x2348 ; <co_thread_get>
 0xf4a4: cbnz   x0, #0xfa34
 0xf4a8: adrp   x4, #0x1a000
 0xf4ac: adrp   x5, #0x1b000
 0xf4b0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf4b4: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf4b8: mov    w0, #0x51
 0xf4bc: mov    w6, #0x21b
 0xf4c0: add    x2, sp, #0x58
 0xf4c4: mov    w3, #0x80
 0xf4c8: mov    w1, wzr
 0xf4cc: bl     #0x2368 ; <duss_log_gen_head>
 0xf4d0: cbz    w0, #0xfabc
 0xf4d4: adrp   x3, #0x1a000
 0xf4d8: adrp   x4, #0x1b000
 0xf4dc: adrp   x5, #0x1a000
 0xf4e0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf4e4: add    x4, x4, #0xc8f ; "sbg"
 0xf4e8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf4ec: mov    w0, #0x51
 0xf4f0: mov    w6, #0x21b
 0xf4f4: add    x2, sp, #0x58
 0xf4f8: mov    w1, wzr
 0xf4fc: bl     #0x2378 ; <duss_log_print>
 0xf500: b      #0xfabc
 0xf504: bl     #0x2348 ; <co_thread_get>
 0xf508: cbnz   x0, #0xfad8
 0xf50c: adrp   x4, #0x1a000
 0xf510: adrp   x5, #0x1b000
 0xf514: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf518: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf51c: mov    w0, #0x51
 0xf520: mov    w6, #0x21c
 0xf524: add    x2, sp, #0x58
 0xf528: mov    w3, #0x80
 0xf52c: mov    w1, wzr
 0xf530: bl     #0x2368 ; <duss_log_gen_head>
 0xf534: cbz    w0, #0xfb60
 0xf538: adrp   x3, #0x1a000
 0xf53c: adrp   x4, #0x1b000
 0xf540: adrp   x5, #0x1a000
 0xf544: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf548: add    x4, x4, #0xc93 ; "sbg->max_count == 2"
 0xf54c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf550: mov    w0, #0x51
 0xf554: mov    w6, #0x21c
 0xf558: add    x2, sp, #0x58
 0xf55c: mov    w1, wzr
 0xf560: bl     #0x2378 ; <duss_log_print>
 0xf564: b      #0xfb60
 0xf568: bl     #0x2348 ; <co_thread_get>
 0xf56c: cbnz   x0, #0xfb7c
 0xf570: adrp   x4, #0x1a000
 0xf574: adrp   x5, #0x1b000
 0xf578: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf57c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf580: mov    w0, #0x51
 0xf584: mov    w6, #0x21d
 0xf588: add    x2, sp, #0x58
 0xf58c: mov    w3, #0x80
 0xf590: mov    w1, wzr
 0xf594: bl     #0x2368 ; <duss_log_gen_head>
 0xf598: cbz    w0, #0xfc04
 0xf59c: adrp   x3, #0x1a000
 0xf5a0: adrp   x4, #0x1b000
 0xf5a4: adrp   x5, #0x1a000
 0xf5a8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf5ac: add    x4, x4, #0xca7 ; "sbg->ele_count > 0"
 0xf5b0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf5b4: mov    w0, #0x51
 0xf5b8: mov    w6, #0x21d
 0xf5bc: add    x2, sp, #0x58
 0xf5c0: mov    w1, wzr
 0xf5c4: bl     #0x2378 ; <duss_log_print>
 0xf5c8: b      #0xfc04
 0xf5cc: bl     #0x2348 ; <co_thread_get>
 0xf5d0: cbnz   x0, #0xfc20
 0xf5d4: adrp   x4, #0x1a000
 0xf5d8: adrp   x5, #0x1b000
 0xf5dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf5e0: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf5e4: mov    w0, #0x51
 0xf5e8: mov    w6, #0x21e
 0xf5ec: add    x2, sp, #0x58
 0xf5f0: mov    w3, #0x80
 0xf5f4: mov    w1, wzr
 0xf5f8: bl     #0x2368 ; <duss_log_gen_head>
 0xf5fc: cbz    w0, #0xfca8
 0xf600: adrp   x3, #0x1a000
 0xf604: adrp   x4, #0x1b000
 0xf608: adrp   x5, #0x1a000
 0xf60c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf610: add    x4, x4, #0xcba ; "sbg->ele_count <= 2"
 0xf614: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf618: mov    w0, #0x51
 0xf61c: mov    w6, #0x21e
 0xf620: add    x2, sp, #0x58
 0xf624: mov    w1, wzr
 0xf628: bl     #0x2378 ; <duss_log_print>
 0xf62c: b      #0xfca8
 0xf630: bl     #0x2348 ; <co_thread_get>
 0xf634: cbnz   x0, #0xfcc4
 0xf638: adrp   x4, #0x1a000
 0xf63c: adrp   x5, #0x1b000
 0xf640: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf644: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf648: mov    w0, #0x51
 0xf64c: mov    w6, #0x21f
 0xf650: add    x2, sp, #0x58
 0xf654: mov    w3, #0x80
 0xf658: mov    w1, wzr
 0xf65c: bl     #0x2368 ; <duss_log_gen_head>
 0xf660: cbz    w0, #0xfd4c
 0xf664: adrp   x3, #0x1a000
 0xf668: adrp   x4, #0x1b000
 0xf66c: adrp   x5, #0x1a000
 0xf670: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf674: add    x4, x4, #0xcce ; "sbg->obj.ref_count == 0"
 0xf678: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf67c: mov    w0, #0x51
 0xf680: mov    w6, #0x21f
 0xf684: add    x2, sp, #0x58
 0xf688: mov    w1, wzr
 0xf68c: bl     #0x2378 ; <duss_log_print>
 0xf690: b      #0xfd4c
 0xf694: bl     #0x2348 ; <co_thread_get>
 0xf698: cbnz   x0, #0xfd68
 0xf69c: adrp   x4, #0x1a000
 0xf6a0: adrp   x5, #0x1b000
 0xf6a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf6a8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf6ac: mov    w0, #0x51
 0xf6b0: mov    w6, #0x221
 0xf6b4: add    x2, sp, #0x58
 0xf6b8: mov    w3, #0x80
 0xf6bc: mov    w1, wzr
 0xf6c0: bl     #0x2368 ; <duss_log_gen_head>
 0xf6c4: cbz    w0, #0xfdf0
 0xf6c8: adrp   x3, #0x1a000
 0xf6cc: adrp   x4, #0x1b000
 0xf6d0: adrp   x5, #0x1a000
 0xf6d4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xf6d8: add    x4, x4, #0xce6 ; "sbg->obj.ref_count == 1"
 0xf6dc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf6e0: mov    w0, #0x51
 0xf6e4: mov    w6, #0x221
 0xf6e8: add    x2, sp, #0x58
 0xf6ec: mov    w1, wzr
 0xf6f0: bl     #0x2378 ; <duss_log_print>
 0xf6f4: b      #0xfdf0
 0xf6f8: adrp   x8, #0x1a000
 0xf6fc: str    wzr, [sp, #0x24]
 0xf700: add    x8, x8, #0x440 ; =0x1a440
 0xf704: add    x1, sp, #0x28
 0xf708: add    x2, sp, #0x24
 0xf70c: str    x8, [sp, #0x28]
 0xf710: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf714: adrp   x19, #0x1a000
 0xf718: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf71c: adrp   x5, #0x1b000
 0xf720: mov    w20, #0x235
 0xf724: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf728: mov    w0, #0x51
 0xf72c: add    x2, sp, #0x58
 0xf730: mov    w3, #0x80
 0xf734: mov    w1, wzr
 0xf738: mov    x4, x19
 0xf73c: mov    w6, w20
 0xf740: bl     #0x2368 ; <duss_log_gen_head>
 0xf744: cbz    w0, #0xf780
 0xf748: ldr    x5, [sp, #0x28]
 0xf74c: adrp   x3, #0x1a000
 0xf750: ldr    w6, [sp, #0x24]
 0xf754: adrp   x4, #0x1a000
 0xf758: adrp   x7, #0x1b000
 0xf75c: str    w20, [sp, #8]
 0xf760: mov    w1, wzr
 0xf764: str    x19, [sp]
 0xf768: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf76c: add    x4, x4, #0x441 ; "co"
 0xf770: mov    w0, #0x51
 0xf774: add    x7, x7, #0xd10 ; "eng->fps"
 0xf778: add    x2, sp, #0x58
 0xf77c: bl     #0x2378 ; <duss_log_print>
 0xf780: adrp   x4, #0x1a000
 0xf784: adrp   x5, #0x1b000
 0xf788: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf78c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf790: mov    w0, #0x51
 0xf794: mov    w6, #0x235
 0xf798: b      #0xf140
 0xf79c: adrp   x8, #0x1a000
 0xf7a0: str    wzr, [sp, #0x24]
 0xf7a4: add    x8, x8, #0x440 ; =0x1a440
 0xf7a8: add    x1, sp, #0x28
 0xf7ac: add    x2, sp, #0x24
 0xf7b0: str    x8, [sp, #0x28]
 0xf7b4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf7b8: adrp   x19, #0x1a000
 0xf7bc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf7c0: adrp   x5, #0x1b000
 0xf7c4: mov    w20, #0x237
 0xf7c8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf7cc: mov    w0, #0x51
 0xf7d0: add    x2, sp, #0x58
 0xf7d4: mov    w3, #0x80
 0xf7d8: mov    w1, wzr
 0xf7dc: mov    x4, x19
 0xf7e0: mov    w6, w20
 0xf7e4: bl     #0x2368 ; <duss_log_gen_head>
 0xf7e8: cbz    w0, #0xf824
 0xf7ec: ldr    x5, [sp, #0x28]
 0xf7f0: adrp   x3, #0x1a000
 0xf7f4: ldr    w6, [sp, #0x24]
 0xf7f8: adrp   x4, #0x1a000
 0xf7fc: adrp   x7, #0x1b000
 0xf800: str    w20, [sp, #8]
 0xf804: mov    w1, wzr
 0xf808: str    x19, [sp]
 0xf80c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf810: add    x4, x4, #0x441 ; "co"
 0xf814: mov    w0, #0x51
 0xf818: add    x7, x7, #0xd19 ; "time_now >= time_start"
 0xf81c: add    x2, sp, #0x58
 0xf820: bl     #0x2378 ; <duss_log_print>
 0xf824: adrp   x4, #0x1a000
 0xf828: adrp   x5, #0x1b000
 0xf82c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf830: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf834: mov    w0, #0x51
 0xf838: mov    w6, #0x237
 0xf83c: b      #0xf140
 0xf840: adrp   x8, #0x1a000
 0xf844: str    wzr, [sp, #0x38]
 0xf848: add    x8, x8, #0x440 ; =0x1a440
 0xf84c: add    x1, sp, #0x50
 0xf850: add    x2, sp, #0x38
 0xf854: str    x8, [sp, #0x50]
 0xf858: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf85c: adrp   x19, #0x1a000
 0xf860: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf864: adrp   x5, #0x1b000
 0xf868: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf86c: mov    w0, #0x51
 0xf870: add    x2, sp, #0x58
 0xf874: mov    w3, #0x80
 0xf878: mov    w6, #0x1f0
 0xf87c: mov    w1, wzr
 0xf880: mov    x4, x19
 0xf884: mov    w20, #0x1f0
 0xf888: bl     #0x2368 ; <duss_log_gen_head>
 0xf88c: cbz    w0, #0xf8c8
 0xf890: ldr    x5, [sp, #0x50]
 0xf894: adrp   x3, #0x1a000
 0xf898: ldr    w6, [sp, #0x38]
 0xf89c: adrp   x4, #0x1a000
 0xf8a0: adrp   x7, #0x1a000
 0xf8a4: str    w20, [sp, #8]
 0xf8a8: mov    w1, wzr
 0xf8ac: str    x19, [sp]
 0xf8b0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf8b4: add    x4, x4, #0x441 ; "co"
 0xf8b8: mov    w0, #0x51
 0xf8bc: add    x7, x7, #0x5c0 ; "ops"
 0xf8c0: add    x2, sp, #0x58
 0xf8c4: bl     #0x2378 ; <duss_log_print>
 0xf8c8: adrp   x4, #0x1a000
 0xf8cc: adrp   x5, #0x1b000
 0xf8d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf8d4: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf8d8: mov    w0, #0x51
 0xf8dc: add    x2, sp, #0x58
 0xf8e0: mov    w3, #0x80
 0xf8e4: mov    w6, #0x1f0
 0xf8e8: b      #0xf148
 0xf8ec: adrp   x8, #0x1a000
 0xf8f0: str    wzr, [sp, #0x38]
 0xf8f4: add    x8, x8, #0x440 ; =0x1a440
 0xf8f8: add    x1, sp, #0x50
 0xf8fc: add    x2, sp, #0x38
 0xf900: str    x8, [sp, #0x50]
 0xf904: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf908: adrp   x19, #0x1a000
 0xf90c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf910: adrp   x5, #0x1b000
 0xf914: mov    w20, #0x1f1
 0xf918: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf91c: mov    w0, #0x51
 0xf920: add    x2, sp, #0x58
 0xf924: mov    w3, #0x80
 0xf928: mov    w1, wzr
 0xf92c: mov    x4, x19
 0xf930: mov    w6, w20
 0xf934: bl     #0x2368 ; <duss_log_gen_head>
 0xf938: cbz    w0, #0xf974
 0xf93c: ldr    x5, [sp, #0x50]
 0xf940: adrp   x3, #0x1a000
 0xf944: ldr    w6, [sp, #0x38]
 0xf948: adrp   x4, #0x1a000
 0xf94c: adrp   x7, #0x1b000
 0xf950: str    w20, [sp, #8]
 0xf954: mov    w1, wzr
 0xf958: str    x19, [sp]
 0xf95c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xf960: add    x4, x4, #0x441 ; "co"
 0xf964: mov    w0, #0x51
 0xf968: add    x7, x7, #0xbbc ; "allocator"
 0xf96c: add    x2, sp, #0x58
 0xf970: bl     #0x2378 ; <duss_log_print>
 0xf974: adrp   x4, #0x1a000
 0xf978: adrp   x5, #0x1b000
 0xf97c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf980: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf984: mov    w0, #0x51
 0xf988: mov    w6, #0x1f1
 0xf98c: b      #0xf140
 0xf990: adrp   x8, #0x1a000
 0xf994: str    wzr, [sp, #0x38]
 0xf998: add    x8, x8, #0x440 ; =0x1a440
 0xf99c: add    x1, sp, #0x50
 0xf9a0: add    x2, sp, #0x38
 0xf9a4: str    x8, [sp, #0x50]
 0xf9a8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xf9ac: adrp   x19, #0x1a000
 0xf9b0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xf9b4: adrp   x5, #0x1b000
 0xf9b8: mov    w20, #0x1f2
 0xf9bc: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xf9c0: mov    w0, #0x51
 0xf9c4: add    x2, sp, #0x58
 0xf9c8: mov    w3, #0x80
 0xf9cc: mov    w1, wzr
 0xf9d0: mov    x4, x19
 0xf9d4: mov    w6, w20
 0xf9d8: bl     #0x2368 ; <duss_log_gen_head>
 0xf9dc: cbz    w0, #0xfa18
 0xf9e0: ldr    x5, [sp, #0x50]
 0xf9e4: adrp   x3, #0x1a000
 0xf9e8: ldr    w6, [sp, #0x38]
 0xf9ec: adrp   x4, #0x1a000
 0xf9f0: adrp   x7, #0x1b000
 0xf9f4: str    w20, [sp, #8]
 0xf9f8: mov    w1, wzr
 0xf9fc: str    x19, [sp]
 0xfa00: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfa04: add    x4, x4, #0x441 ; "co"
 0xfa08: mov    w0, #0x51
 0xfa0c: add    x7, x7, #0xbf1 ; "buffer_group"
 0xfa10: add    x2, sp, #0x58
 0xfa14: bl     #0x2378 ; <duss_log_print>
 0xfa18: adrp   x4, #0x1a000
 0xfa1c: adrp   x5, #0x1b000
 0xfa20: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfa24: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfa28: mov    w0, #0x51
 0xfa2c: mov    w6, #0x1f2
 0xfa30: b      #0xf140
 0xfa34: adrp   x8, #0x1a000
 0xfa38: str    wzr, [sp, #0x24]
 0xfa3c: add    x8, x8, #0x440 ; =0x1a440
 0xfa40: add    x1, sp, #0x28
 0xfa44: add    x2, sp, #0x24
 0xfa48: str    x8, [sp, #0x28]
 0xfa4c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfa50: adrp   x19, #0x1a000
 0xfa54: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfa58: adrp   x5, #0x1b000
 0xfa5c: mov    w20, #0x21b
 0xfa60: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfa64: mov    w0, #0x51
 0xfa68: add    x2, sp, #0x58
 0xfa6c: mov    w3, #0x80
 0xfa70: mov    w1, wzr
 0xfa74: mov    x4, x19
 0xfa78: mov    w6, w20
 0xfa7c: bl     #0x2368 ; <duss_log_gen_head>
 0xfa80: cbz    w0, #0xfabc
 0xfa84: ldr    x5, [sp, #0x28]
 0xfa88: adrp   x3, #0x1a000
 0xfa8c: ldr    w6, [sp, #0x24]
 0xfa90: adrp   x4, #0x1a000
 0xfa94: adrp   x7, #0x1b000
 0xfa98: str    w20, [sp, #8]
 0xfa9c: mov    w1, wzr
 0xfaa0: str    x19, [sp]
 0xfaa4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfaa8: add    x4, x4, #0x441 ; "co"
 0xfaac: mov    w0, #0x51
 0xfab0: add    x7, x7, #0xc8f ; "sbg"
 0xfab4: add    x2, sp, #0x58
 0xfab8: bl     #0x2378 ; <duss_log_print>
 0xfabc: adrp   x4, #0x1a000
 0xfac0: adrp   x5, #0x1b000
 0xfac4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfac8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfacc: mov    w0, #0x51
 0xfad0: mov    w6, #0x21b
 0xfad4: b      #0xf140
 0xfad8: adrp   x8, #0x1a000
 0xfadc: str    wzr, [sp, #0x24]
 0xfae0: add    x8, x8, #0x440 ; =0x1a440
 0xfae4: add    x1, sp, #0x28
 0xfae8: add    x2, sp, #0x24
 0xfaec: str    x8, [sp, #0x28]
 0xfaf0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfaf4: adrp   x19, #0x1a000
 0xfaf8: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfafc: adrp   x5, #0x1b000
 0xfb00: mov    w20, #0x21c
 0xfb04: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfb08: mov    w0, #0x51
 0xfb0c: add    x2, sp, #0x58
 0xfb10: mov    w3, #0x80
 0xfb14: mov    w1, wzr
 0xfb18: mov    x4, x19
 0xfb1c: mov    w6, w20
 0xfb20: bl     #0x2368 ; <duss_log_gen_head>
 0xfb24: cbz    w0, #0xfb60
 0xfb28: ldr    x5, [sp, #0x28]
 0xfb2c: adrp   x3, #0x1a000
 0xfb30: ldr    w6, [sp, #0x24]
 0xfb34: adrp   x4, #0x1a000
 0xfb38: adrp   x7, #0x1b000
 0xfb3c: str    w20, [sp, #8]
 0xfb40: mov    w1, wzr
 0xfb44: str    x19, [sp]
 0xfb48: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfb4c: add    x4, x4, #0x441 ; "co"
 0xfb50: mov    w0, #0x51
 0xfb54: add    x7, x7, #0xc93 ; "sbg->max_count == 2"
 0xfb58: add    x2, sp, #0x58
 0xfb5c: bl     #0x2378 ; <duss_log_print>
 0xfb60: adrp   x4, #0x1a000
 0xfb64: adrp   x5, #0x1b000
 0xfb68: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfb6c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfb70: mov    w0, #0x51
 0xfb74: mov    w6, #0x21c
 0xfb78: b      #0xf140
 0xfb7c: adrp   x8, #0x1a000
 0xfb80: str    wzr, [sp, #0x24]
 0xfb84: add    x8, x8, #0x440 ; =0x1a440
 0xfb88: add    x1, sp, #0x28
 0xfb8c: add    x2, sp, #0x24
 0xfb90: str    x8, [sp, #0x28]
 0xfb94: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfb98: adrp   x19, #0x1a000
 0xfb9c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfba0: adrp   x5, #0x1b000
 0xfba4: mov    w20, #0x21d
 0xfba8: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfbac: mov    w0, #0x51
 0xfbb0: add    x2, sp, #0x58
 0xfbb4: mov    w3, #0x80
 0xfbb8: mov    w1, wzr
 0xfbbc: mov    x4, x19
 0xfbc0: mov    w6, w20
 0xfbc4: bl     #0x2368 ; <duss_log_gen_head>
 0xfbc8: cbz    w0, #0xfc04
 0xfbcc: ldr    x5, [sp, #0x28]
 0xfbd0: adrp   x3, #0x1a000
 0xfbd4: ldr    w6, [sp, #0x24]
 0xfbd8: adrp   x4, #0x1a000
 0xfbdc: adrp   x7, #0x1b000
 0xfbe0: str    w20, [sp, #8]
 0xfbe4: mov    w1, wzr
 0xfbe8: str    x19, [sp]
 0xfbec: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfbf0: add    x4, x4, #0x441 ; "co"
 0xfbf4: mov    w0, #0x51
 0xfbf8: add    x7, x7, #0xca7 ; "sbg->ele_count > 0"
 0xfbfc: add    x2, sp, #0x58
 0xfc00: bl     #0x2378 ; <duss_log_print>
 0xfc04: adrp   x4, #0x1a000
 0xfc08: adrp   x5, #0x1b000
 0xfc0c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfc10: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfc14: mov    w0, #0x51
 0xfc18: mov    w6, #0x21d
 0xfc1c: b      #0xf140
 0xfc20: adrp   x8, #0x1a000
 0xfc24: str    wzr, [sp, #0x24]
 0xfc28: add    x8, x8, #0x440 ; =0x1a440
 0xfc2c: add    x1, sp, #0x28
 0xfc30: add    x2, sp, #0x24
 0xfc34: str    x8, [sp, #0x28]
 0xfc38: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfc3c: adrp   x19, #0x1a000
 0xfc40: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfc44: adrp   x5, #0x1b000
 0xfc48: mov    w20, #0x21e
 0xfc4c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfc50: mov    w0, #0x51
 0xfc54: add    x2, sp, #0x58
 0xfc58: mov    w3, #0x80
 0xfc5c: mov    w1, wzr
 0xfc60: mov    x4, x19
 0xfc64: mov    w6, w20
 0xfc68: bl     #0x2368 ; <duss_log_gen_head>
 0xfc6c: cbz    w0, #0xfca8
 0xfc70: ldr    x5, [sp, #0x28]
 0xfc74: adrp   x3, #0x1a000
 0xfc78: ldr    w6, [sp, #0x24]
 0xfc7c: adrp   x4, #0x1a000
 0xfc80: adrp   x7, #0x1b000
 0xfc84: str    w20, [sp, #8]
 0xfc88: mov    w1, wzr
 0xfc8c: str    x19, [sp]
 0xfc90: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfc94: add    x4, x4, #0x441 ; "co"
 0xfc98: mov    w0, #0x51
 0xfc9c: add    x7, x7, #0xcba ; "sbg->ele_count <= 2"
 0xfca0: add    x2, sp, #0x58
 0xfca4: bl     #0x2378 ; <duss_log_print>
 0xfca8: adrp   x4, #0x1a000
 0xfcac: adrp   x5, #0x1b000
 0xfcb0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfcb4: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfcb8: mov    w0, #0x51
 0xfcbc: mov    w6, #0x21e
 0xfcc0: b      #0xf140
 0xfcc4: adrp   x8, #0x1a000
 0xfcc8: str    wzr, [sp, #0x24]
 0xfccc: add    x8, x8, #0x440 ; =0x1a440
 0xfcd0: add    x1, sp, #0x28
 0xfcd4: add    x2, sp, #0x24
 0xfcd8: str    x8, [sp, #0x28]
 0xfcdc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfce0: adrp   x19, #0x1a000
 0xfce4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfce8: adrp   x5, #0x1b000
 0xfcec: mov    w20, #0x21f
 0xfcf0: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfcf4: mov    w0, #0x51
 0xfcf8: add    x2, sp, #0x58
 0xfcfc: mov    w3, #0x80
 0xfd00: mov    w1, wzr
 0xfd04: mov    x4, x19
 0xfd08: mov    w6, w20
 0xfd0c: bl     #0x2368 ; <duss_log_gen_head>
 0xfd10: cbz    w0, #0xfd4c
 0xfd14: ldr    x5, [sp, #0x28]
 0xfd18: adrp   x3, #0x1a000
 0xfd1c: ldr    w6, [sp, #0x24]
 0xfd20: adrp   x4, #0x1a000
 0xfd24: adrp   x7, #0x1b000
 0xfd28: str    w20, [sp, #8]
 0xfd2c: mov    w1, wzr
 0xfd30: str    x19, [sp]
 0xfd34: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfd38: add    x4, x4, #0x441 ; "co"
 0xfd3c: mov    w0, #0x51
 0xfd40: add    x7, x7, #0xcce ; "sbg->obj.ref_count == 0"
 0xfd44: add    x2, sp, #0x58
 0xfd48: bl     #0x2378 ; <duss_log_print>
 0xfd4c: adrp   x4, #0x1a000
 0xfd50: adrp   x5, #0x1b000
 0xfd54: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfd58: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfd5c: mov    w0, #0x51
 0xfd60: mov    w6, #0x21f
 0xfd64: b      #0xf140
 0xfd68: adrp   x8, #0x1a000
 0xfd6c: str    wzr, [sp, #0x24]
 0xfd70: add    x8, x8, #0x440 ; =0x1a440
 0xfd74: add    x1, sp, #0x28
 0xfd78: add    x2, sp, #0x24
 0xfd7c: str    x8, [sp, #0x28]
 0xfd80: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfd84: adrp   x19, #0x1a000
 0xfd88: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfd8c: adrp   x5, #0x1b000
 0xfd90: mov    w20, #0x221
 0xfd94: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfd98: mov    w0, #0x51
 0xfd9c: add    x2, sp, #0x58
 0xfda0: mov    w3, #0x80
 0xfda4: mov    w1, wzr
 0xfda8: mov    x4, x19
 0xfdac: mov    w6, w20
 0xfdb0: bl     #0x2368 ; <duss_log_gen_head>
 0xfdb4: cbz    w0, #0xfdf0
 0xfdb8: ldr    x5, [sp, #0x28]
 0xfdbc: adrp   x3, #0x1a000
 0xfdc0: ldr    w6, [sp, #0x24]
 0xfdc4: adrp   x4, #0x1a000
 0xfdc8: adrp   x7, #0x1b000
 0xfdcc: str    w20, [sp, #8]
 0xfdd0: mov    w1, wzr
 0xfdd4: str    x19, [sp]
 0xfdd8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfddc: add    x4, x4, #0x441 ; "co"
 0xfde0: mov    w0, #0x51
 0xfde4: add    x7, x7, #0xce6 ; "sbg->obj.ref_count == 1"
 0xfde8: add    x2, sp, #0x58
 0xfdec: bl     #0x2378 ; <duss_log_print>
 0xfdf0: adrp   x4, #0x1a000
 0xfdf4: adrp   x5, #0x1b000
 0xfdf8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfdfc: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfe00: mov    w0, #0x51
 0xfe04: mov    w6, #0x221
 0xfe08: b      #0xf140
 0xfe0c: bl     #0x2348 ; <co_thread_get>
 0xfe10: cbnz   x0, #0xfe70
 0xfe14: adrp   x4, #0x1a000
 0xfe18: adrp   x5, #0x1b000
 0xfe1c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfe20: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfe24: mov    w0, #0x51
 0xfe28: mov    w6, #0x241
 0xfe2c: add    x2, sp, #0x58
 0xfe30: mov    w3, #0x80
 0xfe34: mov    w1, wzr
 0xfe38: bl     #0x2368 ; <duss_log_gen_head>
 0xfe3c: cbz    w0, #0xfef8
 0xfe40: adrp   x3, #0x1a000
 0xfe44: adrp   x4, #0x1b000
 0xfe48: adrp   x5, #0x1a000
 0xfe4c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
 0xfe50: add    x4, x4, #0xd30 ; "!sbg"
 0xfe54: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfe58: mov    w0, #0x51
 0xfe5c: mov    w6, #0x241
 0xfe60: add    x2, sp, #0x58
 0xfe64: mov    w1, wzr
 0xfe68: bl     #0x2378 ; <duss_log_print>
 0xfe6c: b      #0xfef8
 0xfe70: adrp   x8, #0x1a000
 0xfe74: str    wzr, [sp, #0x24]
 0xfe78: add    x8, x8, #0x440 ; =0x1a440
 0xfe7c: add    x1, sp, #0x28
 0xfe80: add    x2, sp, #0x24
 0xfe84: str    x8, [sp, #0x28]
 0xfe88: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
 0xfe8c: adrp   x19, #0x1a000
 0xfe90: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xfe94: adrp   x5, #0x1b000
 0xfe98: mov    w20, #0x241
 0xfe9c: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xfea0: mov    w0, #0x51
 0xfea4: add    x2, sp, #0x58
 0xfea8: mov    w3, #0x80
 0xfeac: mov    w1, wzr
 0xfeb0: mov    x4, x19
 0xfeb4: mov    w6, w20
 0xfeb8: bl     #0x2368 ; <duss_log_gen_head>
 0xfebc: cbz    w0, #0xfef8
 0xfec0: ldr    x5, [sp, #0x28]
 0xfec4: adrp   x3, #0x1a000
 0xfec8: ldr    w6, [sp, #0x24]
 0xfecc: adrp   x4, #0x1a000
 0xfed0: adrp   x7, #0x1b000
 0xfed4: str    w20, [sp, #8]
 0xfed8: mov    w1, wzr
 0xfedc: str    x19, [sp]
 0xfee0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
 0xfee4: add    x4, x4, #0x441 ; "co"
 0xfee8: mov    w0, #0x51
 0xfeec: add    x7, x7, #0xd30 ; "!sbg"
 0xfef0: add    x2, sp, #0x58
 0xfef4: bl     #0x2378 ; <duss_log_print>
 0xfef8: adrp   x4, #0x1a000
 0xfefc: adrp   x5, #0x1b000
 0xff00: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
 0xff04: add    x5, x5, #0xbc6 ; "_proresraw_venc_eng_allocate_stream_buffer"
 0xff08: mov    w0, #0x51
 0xff0c: mov    w6, #0x241
 0xff10: b      #0xf140
 0xff14: udf    #0
 0xff18: stp    x28, x25, [sp, #-0x50]!
 0xff1c: stp    x24, x23, [sp, #0x10]
 0xff20: stp    x22, x21, [sp, #0x20]
 0xff24: stp    x20, x19, [sp, #0x30]
 0xff28: stp    x29, x30, [sp, #0x40]
 0xff2c: add    x29, sp, #0x40
 0xff30: sub    sp, sp, #1, lsl #12
 0xff34: sub    sp, sp, #0xb0
 0xff38: mrs    x24, tpidr_el0
 0xff3c: mov    x19, x2
 0xff40: ldr    x8, [x24, #0x28]
 0xff44: mov    x22, x0
 0xff48: add    x25, sp, #0x10
 0xff4c: str    x8, [x25]
 0xff50: cbz    x22, #0x10120
 0xff54: cbz    x1, #0x10184
 0xff58: ldr    x8, [x1]
 0xff5c: ldr    x23, [x22, #0x490]
 0xff60: ldr    x20, [x8, #0x30]
 0xff64: ldr    w21, [x8, #0xb4]
 0xff68: cbz    x23, #0x10068
 0xff6c: ldrh   w8, [x22, #0x498]
 0xff70: cbz    w8, #0xff90
 0xff74: bl     #0x24d8 ; <duss_osal_get_exec_obj_id>
 0xff78: ldrh   w1, [x22, #0x498]
 0xff7c: mov    w8, w0
 0xff80: tbnz   w8, #0x1f, #0x10110
 0xff84: mov    x0, x23
 0xff88: mov    w2, w8
 0xff8c: bl     #0x2728 ; <perf_trace_coroutine_instant>
 0xff90: adrp   x3, #0x1b000
 0xff94: add    x3, x3, #0xd4e ; "enc_drop.%s.%lu.%u.pte"
 0xff98: add    x0, sp, #0xa8
 0xff9c: mov    w1, #0x1000
 0xffa0: mov    w2, #0x1000
 0xffa4: mov    x4, x19
 0xffa8: mov    x5, x20
 0xffac: mov    w6, w21
 0xffb0: bl     #0xe788
 0xffb4: add    x0, sp, #0xa8
 0xffb8: bl     #0x2738 ; <tracer_cpumon_fusion_dump>
 0xffbc: mov    w19, w0
 0xffc0: cbz    w19, #0x1008c
 0xffc4: adrp   x0, #0x30000
 0xffc8: adrp   x2, #0x1a000
 0xffcc: add    x0, x0, #8 ; =0x30008
 0xffd0: add    x2, x2, #0x5c4 ; "PRORESRAW"
 0xffd4: mov    w1, #2
 0xffd8: bl     #0x2338 ; <log_mgr_check>
 0xffdc: tbz    w0, #0, #0x1008c
 0xffe0: bl     #0x2348 ; <co_thread_get>
 0xffe4: cbz    x0, #0x100bc
 0xffe8: adrp   x8, #0x1a000
 0xffec: str    wzr, [sp, #0x1c]
 0xfff0: add    x8, x8, #0x440 ; =0x1a440
 0xfff4: add    x1, sp, #0x20
 0xfff8: add    x2, sp, #0x1c
 0xfffc: str    x8, [sp, #0x20]
0x10000: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10004: adrp   x4, #0x1a000
0x10008: adrp   x5, #0x1b000
0x1000c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10010: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x10014: mov    w0, #0x51
0x10018: mov    w6, #0x188
0x1001c: mov    w1, #2
0x10020: add    x2, sp, #0x28
0x10024: mov    w3, #0x80
0x10028: bl     #0x2368 ; <duss_log_gen_head>
0x1002c: cbz    w0, #0x1008c
0x10030: ldr    x6, [sp, #0x20]
0x10034: adrp   x3, #0x1b000
0x10038: ldr    w7, [sp, #0x1c]
0x1003c: adrp   x4, #0x1a000
0x10040: adrp   x5, #0x1a000
0x10044: str    w19, [sp]
0x10048: add    x3, x3, #0xd65 ; "%s: %s(%s_%x): can't dump perf trace or cpu monitor: %d"
0x1004c: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10050: add    x5, x5, #0x441 ; "co"
0x10054: mov    w0, #0x51
0x10058: mov    w1, #2
0x1005c: add    x2, sp, #0x28
0x10060: bl     #0x2378 ; <duss_log_print>
0x10064: b      #0x1008c
0x10068: adrp   x3, #0x1b000
0x1006c: add    x3, x3, #0xd4e ; "enc_drop.%s.%lu.%u.pte"
0x10070: add    x0, sp, #0xa8
0x10074: mov    w1, #0x1000
0x10078: mov    w2, #0x1000
0x1007c: mov    x4, x19
0x10080: mov    x5, x20
0x10084: mov    w6, w21
0x10088: bl     #0xe788
0x1008c: ldr    x8, [x24, #0x28]
0x10090: ldr    x9, [x25]
0x10094: cmp    x8, x9
0x10098: b.ne   #0x101e8
0x1009c: add    sp, sp, #1, lsl #12
0x100a0: add    sp, sp, #0xb0
0x100a4: ldp    x29, x30, [sp, #0x40]
0x100a8: ldp    x20, x19, [sp, #0x30]
0x100ac: ldp    x22, x21, [sp, #0x20]
0x100b0: ldp    x24, x23, [sp, #0x10]
0x100b4: ldp    x28, x25, [sp], #0x50
0x100b8: ret    
0x100bc: adrp   x4, #0x1a000
0x100c0: adrp   x5, #0x1b000
0x100c4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x100c8: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x100cc: mov    w0, #0x51
0x100d0: mov    w6, #0x188
0x100d4: mov    w1, #2
0x100d8: add    x2, sp, #0x28
0x100dc: mov    w3, #0x80
0x100e0: bl     #0x2368 ; <duss_log_gen_head>
0x100e4: cbz    w0, #0x1008c
0x100e8: adrp   x3, #0x1b000
0x100ec: adrp   x4, #0x1a000
0x100f0: add    x3, x3, #0xd9d ; "%s: can't dump perf trace or cpu monitor: %d"
0x100f4: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x100f8: mov    w0, #0x51
0x100fc: mov    w1, #2
0x10100: add    x2, sp, #0x28
0x10104: mov    w5, w19
0x10108: bl     #0x2378 ; <duss_log_print>
0x1010c: b      #0x1008c
0x10110: cbz    w1, #0xff90
0x10114: mov    x0, x23
0x10118: bl     #0x2748 ; <perf_trace_instant>
0x1011c: b      #0xff90
0x10120: bl     #0x2348 ; <co_thread_get>
0x10124: cbnz   x0, #0x101ec
0x10128: adrp   x4, #0x1a000
0x1012c: adrp   x5, #0x1b000
0x10130: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10134: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x10138: mov    w0, #0x51
0x1013c: mov    w6, #0x179
0x10140: add    x2, sp, #0xa8
0x10144: mov    w3, #0x80
0x10148: mov    w1, wzr
0x1014c: bl     #0x2368 ; <duss_log_gen_head>
0x10150: cbz    w0, #0x10274
0x10154: adrp   x3, #0x1a000
0x10158: adrp   x4, #0x1a000
0x1015c: adrp   x5, #0x1a000
0x10160: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x10164: add    x4, x4, #0x821 ; "eng"
0x10168: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1016c: mov    w0, #0x51
0x10170: mov    w6, #0x179
0x10174: add    x2, sp, #0xa8
0x10178: mov    w1, wzr
0x1017c: bl     #0x2378 ; <duss_log_print>
0x10180: b      #0x10274
0x10184: bl     #0x2348 ; <co_thread_get>
0x10188: cbnz   x0, #0x10290
0x1018c: adrp   x4, #0x1a000
0x10190: adrp   x5, #0x1b000
0x10194: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10198: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x1019c: mov    w0, #0x51
0x101a0: mov    w6, #0x17a
0x101a4: add    x2, sp, #0xa8
0x101a8: mov    w3, #0x80
0x101ac: mov    w1, wzr
0x101b0: bl     #0x2368 ; <duss_log_gen_head>
0x101b4: cbz    w0, #0x10318
0x101b8: adrp   x3, #0x1a000
0x101bc: adrp   x4, #0x1a000
0x101c0: adrp   x5, #0x1a000
0x101c4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x101c8: add    x4, x4, #0x81b ; "param"
0x101cc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x101d0: mov    w0, #0x51
0x101d4: mov    w6, #0x17a
0x101d8: add    x2, sp, #0xa8
0x101dc: mov    w1, wzr
0x101e0: bl     #0x2378 ; <duss_log_print>
0x101e4: b      #0x10318
0x101e8: bl     #0x23d8 ; <__stack_chk_fail>
0x101ec: adrp   x8, #0x1a000
0x101f0: str    wzr, [sp, #0x20]
0x101f4: add    x8, x8, #0x440 ; =0x1a440
0x101f8: add    x1, sp, #0x28
0x101fc: add    x2, sp, #0x20
0x10200: str    x8, [sp, #0x28]
0x10204: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10208: adrp   x19, #0x1a000
0x1020c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10210: adrp   x5, #0x1b000
0x10214: mov    w20, #0x179
0x10218: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x1021c: mov    w0, #0x51
0x10220: add    x2, sp, #0xa8
0x10224: mov    w3, #0x80
0x10228: mov    w1, wzr
0x1022c: mov    x4, x19
0x10230: mov    w6, w20
0x10234: bl     #0x2368 ; <duss_log_gen_head>
0x10238: cbz    w0, #0x10274
0x1023c: ldr    x5, [sp, #0x28]
0x10240: adrp   x3, #0x1a000
0x10244: ldr    w6, [sp, #0x20]
0x10248: adrp   x4, #0x1a000
0x1024c: adrp   x7, #0x1a000
0x10250: str    w20, [sp, #8]
0x10254: mov    w1, wzr
0x10258: str    x19, [sp]
0x1025c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x10260: add    x4, x4, #0x441 ; "co"
0x10264: mov    w0, #0x51
0x10268: add    x7, x7, #0x821 ; "eng"
0x1026c: add    x2, sp, #0xa8
0x10270: bl     #0x2378 ; <duss_log_print>
0x10274: adrp   x4, #0x1a000
0x10278: adrp   x5, #0x1b000
0x1027c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10280: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x10284: mov    w0, #0x51
0x10288: mov    w6, #0x179
0x1028c: b      #0x10330
0x10290: adrp   x8, #0x1a000
0x10294: str    wzr, [sp, #0x20]
0x10298: add    x8, x8, #0x440 ; =0x1a440
0x1029c: add    x1, sp, #0x28
0x102a0: add    x2, sp, #0x20
0x102a4: str    x8, [sp, #0x28]
0x102a8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x102ac: adrp   x19, #0x1a000
0x102b0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x102b4: adrp   x5, #0x1b000
0x102b8: mov    w20, #0x17a
0x102bc: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x102c0: mov    w0, #0x51
0x102c4: add    x2, sp, #0xa8
0x102c8: mov    w3, #0x80
0x102cc: mov    w1, wzr
0x102d0: mov    x4, x19
0x102d4: mov    w6, w20
0x102d8: bl     #0x2368 ; <duss_log_gen_head>
0x102dc: cbz    w0, #0x10318
0x102e0: ldr    x5, [sp, #0x28]
0x102e4: adrp   x3, #0x1a000
0x102e8: ldr    w6, [sp, #0x20]
0x102ec: adrp   x4, #0x1a000
0x102f0: adrp   x7, #0x1a000
0x102f4: str    w20, [sp, #8]
0x102f8: mov    w1, wzr
0x102fc: str    x19, [sp]
0x10300: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x10304: add    x4, x4, #0x441 ; "co"
0x10308: mov    w0, #0x51
0x1030c: add    x7, x7, #0x81b ; "param"
0x10310: add    x2, sp, #0xa8
0x10314: bl     #0x2378 ; <duss_log_print>
0x10318: adrp   x4, #0x1a000
0x1031c: adrp   x5, #0x1b000
0x10320: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10324: add    x5, x5, #0xd35 ; "_proresraw_on_frame_drop"
0x10328: mov    w0, #0x51
0x1032c: mov    w6, #0x17a
0x10330: add    x2, sp, #0xa8
0x10334: mov    w3, #0x80
0x10338: mov    w1, wzr
0x1033c: bl     #0x2368 ; <duss_log_gen_head>
0x10340: cbz    w0, #0x1035c
0x10344: adrp   x3, #0x1a000
0x10348: add    x3, x3, #0x550 ; "Assertion Comment: "
0x1034c: mov    w0, #0x51
0x10350: add    x2, sp, #0xa8
0x10354: mov    w1, wzr
0x10358: bl     #0x2378 ; <duss_log_print>
0x1035c: adrp   x0, #0x1a000
0x10360: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x10364: bl     #0x23e8 ; <log_to_kmsg>
0x10368: adrp   x0, #0x1a000
0x1036c: add    x0, x0, #0x57f ; "Camera:	"
0x10370: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x10374: bl     #0x2408 ; <is_running_in_cam_sil>
0x10378: tbz    w0, #0, #0x10388
0x1037c: mov    x0, xzr
0x10380: bl     #0x2418 ; <fflush>
0x10384: bl     #0x2428 ; <abort>
0x10388: mov    w0, #1
0x1038c: bl     #0x2438 ; <exit>
0x10390: sub    sp, sp, #0x1c0
0x10394: stp    x28, x27, [sp, #0x160]
0x10398: stp    x26, x25, [sp, #0x170]
0x1039c: stp    x24, x23, [sp, #0x180]
0x103a0: stp    x22, x21, [sp, #0x190]
0x103a4: stp    x20, x19, [sp, #0x1a0]
0x103a8: stp    x29, x30, [sp, #0x1b0]
0x103ac: add    x29, sp, #0x1b0
0x103b0: mrs    x27, tpidr_el0
0x103b4: mov    x20, x2
0x103b8: ldr    x8, [x27, #0x28]
0x103bc: mov    x19, x0
0x103c0: add    x25, sp, #0x68
0x103c4: mov    x21, x1
0x103c8: str    x8, [x25]
0x103cc: cbz    x19, #0x1125c
0x103d0: cbz    x21, #0x112c0
0x103d4: cbz    x20, #0x11324
0x103d8: ldp    q0, q1, [x21]
0x103dc: ldr    q2, [x21, #0x20]
0x103e0: stp    q0, q1, [sp, #0x90]
0x103e4: ldr    w8, [x19, #0x3d0]
0x103e8: ldr    x9, [x21, #0x30]
0x103ec: ldr    x10, [x19, #0x3d8]
0x103f0: str    q2, [sp, #0xb0]
0x103f4: cmp    w8, #0
0x103f8: stp    x9, xzr, [sp, #0xc0]
0x103fc: str    x10, [sp, #0xd0]
0x10400: b.le   #0x11388
0x10404: ldr    x9, [x20]
0x10408: mov    w10, #0x80000
0x1040c: stp    w8, w10, [sp, #0xc8]
0x10410: cbnz   x9, #0x113ec
0x10414: add    x0, sp, #0x90
0x10418: mov    x1, x20
0x1041c: bl     #0x2758 ; <cam_encoded_null_buffer_allocator_create>
0x10420: mov    w22, w0
0x10424: cbz    w22, #0x10504
0x10428: adrp   x0, #0x30000
0x1042c: adrp   x2, #0x1a000
0x10430: add    x0, x0, #8 ; =0x30008
0x10434: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x10438: mov    w1, #1
0x1043c: bl     #0x2338 ; <log_mgr_check>
0x10440: tbz    w0, #0, #0x10d70
0x10444: bl     #0x2348 ; <co_thread_get>
0x10448: cbz    x0, #0x10c30
0x1044c: adrp   x8, #0x1a000
0x10450: str    wzr, [sp, #0x78]
0x10454: add    x8, x8, #0x440 ; =0x1a440
0x10458: add    x1, sp, #0x88
0x1045c: add    x2, sp, #0x78
0x10460: str    x8, [sp, #0x88]
0x10464: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10468: adrp   x4, #0x1a000
0x1046c: adrp   x5, #0x1c000
0x10470: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10474: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10478: mov    w0, #0x51
0x1047c: mov    w6, #0x38f
0x10480: mov    w1, #1
0x10484: add    x2, sp, #0xd8
0x10488: mov    w3, #0x80
0x1048c: bl     #0x2368 ; <duss_log_gen_head>
0x10490: cbz    w0, #0x104b8
0x10494: adrp   x3, #0x1a000
0x10498: adrp   x4, #0x1a000
0x1049c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x104a0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x104a4: mov    w0, #0x51
0x104a8: mov    w5, #0x38f
0x104ac: mov    w1, #1
0x104b0: add    x2, sp, #0xd8
0x104b4: bl     #0x2378 ; <duss_log_print>
0x104b8: adrp   x4, #0x1a000
0x104bc: adrp   x5, #0x1c000
0x104c0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x104c4: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x104c8: mov    w0, #0x51
0x104cc: mov    w6, #0x38f
0x104d0: mov    w1, #1
0x104d4: add    x2, sp, #0xd8
0x104d8: mov    w3, #0x80
0x104dc: bl     #0x2368 ; <duss_log_gen_head>
0x104e0: cbz    w0, #0x10d70
0x104e4: ldr    x6, [sp, #0x88]
0x104e8: adrp   x3, #0x1c000
0x104ec: ldr    w7, [sp, #0x78]
0x104f0: adrp   x4, #0x1a000
0x104f4: adrp   x5, #0x1a000
0x104f8: str    w22, [sp]
0x104fc: add    x3, x3, #0x989 ; "%s: %s(%s_%x): Failed to create null allocator with error %d
"
0x10500: b      #0x10638
0x10504: ldr    x8, [x20]
0x10508: cbz    x8, #0x11790
0x1050c: ldp    w8, w9, [x21]
0x10510: udiv   w22, w8, w9
0x10514: cmp    w22, #1
0x10518: b.ls   #0x117f4
0x1051c: ldr    w8, [x19, #0x410]
0x10520: cbnz   w8, #0x11858
0x10524: ldr    x8, [sp, #0xa8]
0x10528: str    w22, [x19, #0x410]
0x1052c: cbz    x8, #0x118bc
0x10530: ldr    x9, [x19, #0x408]
0x10534: str    x8, [x19, #0x3c8]
0x10538: cbnz   x9, #0x11920
0x1053c: add    x23, x19, #0x408 ; =0x1a408
0x10540: adrp   x0, #0x1c000
0x10544: add    x0, x0, #0xa88 ; "allocator_pool"
0x10548: mov    w1, #8
0x1054c: mov    w2, w22
0x10550: mov    x3, x23
0x10554: bl     #0x2688 ; <buffer_queue_create>
0x10558: mov    w24, w0
0x1055c: cbz    w24, #0x10654
0x10560: adrp   x0, #0x30000
0x10564: adrp   x2, #0x1a000
0x10568: add    x0, x0, #8 ; =0x30008
0x1056c: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x10570: mov    w1, #1
0x10574: bl     #0x2338 ; <log_mgr_check>
0x10578: tbz    w0, #0, #0x10d70
0x1057c: bl     #0x2348 ; <co_thread_get>
0x10580: cbz    x0, #0x10cd0
0x10584: adrp   x8, #0x1a000
0x10588: str    wzr, [sp, #0x78]
0x1058c: add    x8, x8, #0x440 ; =0x1a440
0x10590: add    x1, sp, #0x88
0x10594: add    x2, sp, #0x78
0x10598: str    x8, [sp, #0x88]
0x1059c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x105a0: adrp   x4, #0x1a000
0x105a4: adrp   x5, #0x1c000
0x105a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x105ac: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x105b0: mov    w0, #0x51
0x105b4: mov    w6, #0x3a1
0x105b8: mov    w1, #1
0x105bc: add    x2, sp, #0xd8
0x105c0: mov    w3, #0x80
0x105c4: bl     #0x2368 ; <duss_log_gen_head>
0x105c8: cbz    w0, #0x105f0
0x105cc: adrp   x3, #0x1a000
0x105d0: adrp   x4, #0x1a000
0x105d4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x105d8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x105dc: mov    w0, #0x51
0x105e0: mov    w5, #0x3a1
0x105e4: mov    w1, #1
0x105e8: add    x2, sp, #0xd8
0x105ec: bl     #0x2378 ; <duss_log_print>
0x105f0: adrp   x4, #0x1a000
0x105f4: adrp   x5, #0x1c000
0x105f8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x105fc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10600: mov    w0, #0x51
0x10604: mov    w6, #0x3a1
0x10608: mov    w1, #1
0x1060c: add    x2, sp, #0xd8
0x10610: mov    w3, #0x80
0x10614: bl     #0x2368 ; <duss_log_gen_head>
0x10618: cbz    w0, #0x10d70
0x1061c: ldr    x6, [sp, #0x88]
0x10620: adrp   x3, #0x1c000
0x10624: ldr    w7, [sp, #0x78]
0x10628: adrp   x4, #0x1a000
0x1062c: adrp   x5, #0x1a000
0x10630: str    w24, [sp]
0x10634: add    x3, x3, #0xa97 ; "%s: %s(%s_%x): Failed to create allocator pool with error %d
"
0x10638: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x1063c: add    x5, x5, #0x441 ; "co"
0x10640: mov    w0, #0x51
0x10644: mov    w1, #1
0x10648: add    x2, sp, #0xd8
0x1064c: bl     #0x2378 ; <duss_log_print>
0x10650: b      #0x10d70
0x10654: ldr    x0, [x23]
0x10658: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
0x1065c: cbnz   w0, #0x11cb8
0x10660: mov    w26, #2
0x10664: ldr    w8, [x21, #8]
0x10668: ldr    w9, [x21]
0x1066c: ldrb   w10, [x21, #0x2e]
0x10670: udiv   w8, w8, w26
0x10674: udiv   w9, w9, w26
0x10678: add    w8, w8, #0xfff
0x1067c: strb   w10, [sp, #0xbe]
0x10680: add    w9, w9, #0xfff
0x10684: and    w8, w8, #0xfffff000
0x10688: and    w9, w9, #0xfffff000
0x1068c: stp    w9, w8, [sp, #0x94]
0x10690: str    w9, [sp, #0x90]
0x10694: cbz    w26, #0x10b40
0x10698: mov    w28, wzr
0x1069c: add    x0, sp, #0x90
0x106a0: add    x1, sp, #0x88
0x106a4: bl     #0x2768 ; <cam_encoded_ring_buffer_ex_allocator_create>
0x106a8: mov    w24, w0
0x106ac: cbnz   w24, #0x106f0
0x106b0: ldr    x0, [sp, #0x88]
0x106b4: add    x1, sp, #0x84
0x106b8: bl     #0x2678 ; <cam_encoded_buffer_allocator_total_result_buffer_count_get>
0x106bc: cbnz   w0, #0x10f44
0x106c0: ldr    x0, [sp, #0x88]
0x106c4: bl     #0x2778 ; <cam_encoded_buffer_allocator_init>
0x106c8: mov    w24, w0
0x106cc: cbnz   w24, #0x107d4
0x106d0: ldr    x0, [x23]
0x106d4: add    x1, sp, #0x88
0x106d8: bl     #0x2588 ; <buffer_queue_enqueue>
0x106dc: cbnz   w0, #0x10fa8
0x106e0: add    w28, w28, #1
0x106e4: cmp    w28, w26
0x106e8: b.lo   #0x1069c
0x106ec: b      #0x10b40
0x106f0: adrp   x0, #0x30000
0x106f4: adrp   x2, #0x1a000
0x106f8: mov    w1, #1
0x106fc: add    x0, x0, #8 ; =0x30008
0x10700: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x10704: bl     #0x2338 ; <log_mgr_check>
0x10708: tbz    w0, #0, #0x10a18
0x1070c: str    x27, [sp, #0x60]
0x10710: bl     #0x2348 ; <co_thread_get>
0x10714: cbz    x0, #0x108d8
0x10718: adrp   x8, #0x1a000
0x1071c: str    wzr, [sp, #0x74]
0x10720: add    x8, x8, #0x440 ; =0x1a440
0x10724: add    x1, sp, #0x78
0x10728: add    x2, sp, #0x74
0x1072c: str    x8, [sp, #0x78]
0x10730: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10734: adrp   x28, #0x1a000
0x10738: mov    w27, #0x51
0x1073c: add    x28, x28, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10740: adrp   x5, #0x1c000
0x10744: mov    w25, #0x3b4
0x10748: mov    w1, #1
0x1074c: add    x2, sp, #0xd8
0x10750: mov    w3, #0x80
0x10754: mov    w0, w27
0x10758: mov    x4, x28
0x1075c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10760: mov    w6, w25
0x10764: bl     #0x2368 ; <duss_log_gen_head>
0x10768: cbz    w0, #0x1078c
0x1076c: adrp   x3, #0x1a000
0x10770: mov    w1, #1
0x10774: add    x2, sp, #0xd8
0x10778: mov    w0, w27
0x1077c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x10780: mov    x4, x28
0x10784: mov    w5, w25
0x10788: bl     #0x2378 ; <duss_log_print>
0x1078c: adrp   x5, #0x1c000
0x10790: mov    w1, #1
0x10794: add    x2, sp, #0xd8
0x10798: mov    w3, #0x80
0x1079c: mov    w0, w27
0x107a0: mov    x4, x28
0x107a4: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x107a8: mov    w6, w25
0x107ac: bl     #0x2368 ; <duss_log_gen_head>
0x107b0: cbz    w0, #0x10a14
0x107b4: ldr    x6, [sp, #0x78]
0x107b8: adrp   x3, #0x1c000
0x107bc: ldr    w7, [sp, #0x74]
0x107c0: mov    w1, #1
0x107c4: add    x2, sp, #0xd8
0x107c8: mov    w0, w27
0x107cc: add    x3, x3, #0xb1c ; "%s: %s(%s_%x): Failed to create ring buffer ex allocator with error %d
"
0x107d0: b      #0x108bc
0x107d4: ldr    x0, [sp, #0x88]
0x107d8: bl     #0x2788 ; <cam_encoded_buffer_allocator_destroy>
0x107dc: adrp   x0, #0x30000
0x107e0: adrp   x2, #0x1a000
0x107e4: mov    w1, #1
0x107e8: add    x0, x0, #8 ; =0x30008
0x107ec: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x107f0: bl     #0x2338 ; <log_mgr_check>
0x107f4: tbz    w0, #0, #0x10a18
0x107f8: str    x27, [sp, #0x60]
0x107fc: bl     #0x2348 ; <co_thread_get>
0x10800: cbz    x0, #0x10970
0x10804: adrp   x8, #0x1a000
0x10808: str    wzr, [sp, #0x74]
0x1080c: add    x8, x8, #0x440 ; =0x1a440
0x10810: add    x1, sp, #0x78
0x10814: add    x2, sp, #0x74
0x10818: str    x8, [sp, #0x78]
0x1081c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10820: adrp   x28, #0x1a000
0x10824: mov    w25, #0x51
0x10828: add    x28, x28, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1082c: adrp   x5, #0x1c000
0x10830: mov    w27, #0x3bc
0x10834: mov    w1, #1
0x10838: add    x2, sp, #0xd8
0x1083c: mov    w3, #0x80
0x10840: mov    w0, w25
0x10844: mov    x4, x28
0x10848: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1084c: mov    w6, w27
0x10850: bl     #0x2368 ; <duss_log_gen_head>
0x10854: cbz    w0, #0x10878
0x10858: adrp   x3, #0x1a000
0x1085c: mov    w1, #1
0x10860: add    x2, sp, #0xd8
0x10864: mov    w0, w25
0x10868: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x1086c: mov    x4, x28
0x10870: mov    w5, w27
0x10874: bl     #0x2378 ; <duss_log_print>
0x10878: adrp   x5, #0x1c000
0x1087c: mov    w1, #1
0x10880: add    x2, sp, #0xd8
0x10884: mov    w3, #0x80
0x10888: mov    w0, w25
0x1088c: mov    x4, x28
0x10890: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10894: mov    w6, w27
0x10898: bl     #0x2368 ; <duss_log_gen_head>
0x1089c: cbz    w0, #0x10a14
0x108a0: ldr    x6, [sp, #0x78]
0x108a4: adrp   x3, #0x1c000
0x108a8: ldr    w7, [sp, #0x74]
0x108ac: mov    w1, #1
0x108b0: add    x2, sp, #0xd8
0x108b4: mov    w0, w25
0x108b8: add    x3, x3, #0xba1 ; "%s: %s(%s_%x): Failed to init ring buffer allocator with error %d
"
0x108bc: adrp   x4, #0x1a000
0x108c0: str    w24, [sp]
0x108c4: adrp   x5, #0x1a000
0x108c8: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x108cc: add    x5, x5, #0x441 ; "co"
0x108d0: bl     #0x2378 ; <duss_log_print>
0x108d4: b      #0x10a14
0x108d8: adrp   x28, #0x1a000
0x108dc: mov    w27, #0x51
0x108e0: add    x28, x28, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x108e4: adrp   x5, #0x1c000
0x108e8: mov    w25, #0x3b4
0x108ec: mov    w1, #1
0x108f0: add    x2, sp, #0xd8
0x108f4: mov    w3, #0x80
0x108f8: mov    w0, w27
0x108fc: mov    x4, x28
0x10900: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10904: mov    w6, w25
0x10908: bl     #0x2368 ; <duss_log_gen_head>
0x1090c: cbz    w0, #0x10930
0x10910: adrp   x3, #0x1a000
0x10914: mov    w1, #1
0x10918: add    x2, sp, #0xd8
0x1091c: mov    w0, w27
0x10920: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x10924: mov    x4, x28
0x10928: mov    w5, w25
0x1092c: bl     #0x2378 ; <duss_log_print>
0x10930: adrp   x5, #0x1c000
0x10934: mov    w1, #1
0x10938: add    x2, sp, #0xd8
0x1093c: mov    w3, #0x80
0x10940: mov    w0, w27
0x10944: mov    x4, x28
0x10948: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1094c: mov    w6, w25
0x10950: bl     #0x2368 ; <duss_log_gen_head>
0x10954: cbz    w0, #0x10a14
0x10958: adrp   x3, #0x1c000
0x1095c: mov    w1, #1
0x10960: add    x2, sp, #0xd8
0x10964: mov    w0, w27
0x10968: add    x3, x3, #0xb64 ; "%s: Failed to create ring buffer ex allocator with error %d
"
0x1096c: b      #0x10a04
0x10970: adrp   x28, #0x1a000
0x10974: mov    w27, #0x51
0x10978: add    x28, x28, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1097c: adrp   x5, #0x1c000
0x10980: mov    w25, #0x3bc
0x10984: mov    w1, #1
0x10988: add    x2, sp, #0xd8
0x1098c: mov    w3, #0x80
0x10990: mov    w0, w27
0x10994: mov    x4, x28
0x10998: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1099c: mov    w6, w25
0x109a0: bl     #0x2368 ; <duss_log_gen_head>
0x109a4: cbz    w0, #0x109c8
0x109a8: adrp   x3, #0x1a000
0x109ac: mov    w1, #1
0x109b0: add    x2, sp, #0xd8
0x109b4: mov    w0, w27
0x109b8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x109bc: mov    x4, x28
0x109c0: mov    w5, w25
0x109c4: bl     #0x2378 ; <duss_log_print>
0x109c8: adrp   x5, #0x1c000
0x109cc: mov    w1, #1
0x109d0: add    x2, sp, #0xd8
0x109d4: mov    w3, #0x80
0x109d8: mov    w0, w27
0x109dc: mov    x4, x28
0x109e0: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x109e4: mov    w6, w25
0x109e8: bl     #0x2368 ; <duss_log_gen_head>
0x109ec: adrp   x3, #0x1c000
0x109f0: add    x3, x3, #0xbe4 ; "%s: Failed to init ring buffer allocator with error %d
"
0x109f4: cbz    w0, #0x10a14
0x109f8: mov    w1, #1
0x109fc: add    x2, sp, #0xd8
0x10a00: mov    w0, w27
0x10a04: adrp   x4, #0x1a000
0x10a08: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10a0c: mov    w5, w24
0x10a10: bl     #0x2378 ; <duss_log_print>
0x10a14: ldr    x27, [sp, #0x60]
0x10a18: ldr    x0, [x23]
0x10a1c: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
0x10a20: mov    w24, w0
0x10a24: cbz    w24, #0x10a58
0x10a28: mov    w28, wzr
0x10a2c: ldr    x0, [x23]
0x10a30: add    x1, sp, #0x88
0x10a34: bl     #0x2508 ; <buffer_queue_dequeue>
0x10a38: cbnz   w0, #0x10ee0
0x10a3c: ldr    x0, [sp, #0x88]
0x10a40: bl     #0x2798 ; <cam_encoded_buffer_allocator_deinit>
0x10a44: ldr    x0, [sp, #0x88]
0x10a48: bl     #0x2788 ; <cam_encoded_buffer_allocator_destroy>
0x10a4c: add    w28, w28, #1
0x10a50: cmp    w28, w24
0x10a54: b.lo   #0x10a2c
0x10a58: add    w26, w26, #1
0x10a5c: cmp    w26, w22
0x10a60: b.ls   #0x10664
0x10a64: adrp   x0, #0x30000
0x10a68: adrp   x2, #0x1a000
0x10a6c: add    x0, x0, #8 ; =0x30008
0x10a70: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x10a74: mov    w1, #1
0x10a78: bl     #0x2338 ; <log_mgr_check>
0x10a7c: add    x25, sp, #0x68
0x10a80: tbz    w0, #0, #0x10d70
0x10a84: bl     #0x2348 ; <co_thread_get>
0x10a88: cbz    x0, #0x10e40
0x10a8c: adrp   x8, #0x1a000
0x10a90: str    wzr, [sp, #0x78]
0x10a94: add    x8, x8, #0x440 ; =0x1a440
0x10a98: add    x1, sp, #0x88
0x10a9c: add    x2, sp, #0x78
0x10aa0: str    x8, [sp, #0x88]
0x10aa4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10aa8: adrp   x4, #0x1a000
0x10aac: adrp   x5, #0x1c000
0x10ab0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10ab4: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10ab8: mov    w0, #0x51
0x10abc: mov    w6, #0x3e1
0x10ac0: mov    w1, #1
0x10ac4: add    x2, sp, #0xd8
0x10ac8: mov    w3, #0x80
0x10acc: bl     #0x2368 ; <duss_log_gen_head>
0x10ad0: cbz    w0, #0x10af8
0x10ad4: adrp   x3, #0x1a000
0x10ad8: adrp   x4, #0x1a000
0x10adc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x10ae0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10ae4: mov    w0, #0x51
0x10ae8: mov    w5, #0x3e1
0x10aec: mov    w1, #1
0x10af0: add    x2, sp, #0xd8
0x10af4: bl     #0x2378 ; <duss_log_print>
0x10af8: adrp   x4, #0x1a000
0x10afc: adrp   x5, #0x1c000
0x10b00: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10b04: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10b08: mov    w0, #0x51
0x10b0c: mov    w6, #0x3e1
0x10b10: mov    w1, #1
0x10b14: add    x2, sp, #0xd8
0x10b18: mov    w3, #0x80
0x10b1c: bl     #0x2368 ; <duss_log_gen_head>
0x10b20: cbz    w0, #0x10d70
0x10b24: ldr    x6, [sp, #0x88]
0x10b28: adrp   x3, #0x1c000
0x10b2c: ldr    w7, [sp, #0x78]
0x10b30: adrp   x4, #0x1a000
0x10b34: adrp   x5, #0x1a000
0x10b38: add    x3, x3, #0xe43 ; "%s: %s(%s_%x): Failed to create buffer allocators, out of memory?
"
0x10b3c: b      #0x10638
0x10b40: ldr    w8, [x19, #0x414]
0x10b44: cbnz   w8, #0x11d1c
0x10b48: adrp   x0, #0x30000
0x10b4c: str    w26, [x19, #0x414]
0x10b50: adrp   x2, #0x1a000
0x10b54: add    x0, x0, #8 ; =0x30008
0x10b58: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x10b5c: mov    w1, #3
0x10b60: bl     #0x2338 ; <log_mgr_check>
0x10b64: tbz    w0, #0, #0x10e34
0x10b68: bl     #0x2348 ; <co_thread_get>
0x10b6c: cbz    x0, #0x10db0
0x10b70: adrp   x8, #0x1a000
0x10b74: str    wzr, [sp, #0x78]
0x10b78: add    x8, x8, #0x440 ; =0x1a440
0x10b7c: add    x1, sp, #0x88
0x10b80: add    x2, sp, #0x78
0x10b84: str    x8, [sp, #0x88]
0x10b88: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x10b8c: adrp   x4, #0x1a000
0x10b90: adrp   x5, #0x1c000
0x10b94: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10b98: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10b9c: mov    w0, #0x51
0x10ba0: mov    w6, #0x3d1
0x10ba4: mov    w1, #3
0x10ba8: add    x2, sp, #0xd8
0x10bac: mov    w3, #0x80
0x10bb0: bl     #0x2368 ; <duss_log_gen_head>
0x10bb4: cbz    w0, #0x10e34
0x10bb8: ldr    x6, [sp, #0x88]
0x10bbc: adrp   x3, #0x1c000
0x10bc0: ldr    w7, [sp, #0x78]
0x10bc4: adrp   x4, #0x1a000
0x10bc8: ldp    w8, w9, [x21]
0x10bcc: ldr    w10, [x21, #0xc]
0x10bd0: adrp   x5, #0x1a000
0x10bd4: ldr    x11, [sp, #0xd0]
0x10bd8: mov    w15, #2
0x10bdc: ldr    x12, [sp, #0xa8]
0x10be0: add    x3, x3, #0xc3e ; "%s: %s(%s_%x): mem_total_size: %d, min_block_size: %d, stream_buffer_addr_alignment: %d, b"
0x10be4: ldr    w13, [x19, #0x410]
0x10be8: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10bec: ldr    w14, [x19, #0x458]
0x10bf0: add    x5, x5, #0x441 ; "co"
0x10bf4: mov    w0, #0x51
0x10bf8: str    w22, [sp, #0x48]
0x10bfc: mov    w1, #3
0x10c00: str    w26, [sp, #0x38]
0x10c04: add    x2, sp, #0xd8
0x10c08: str    w13, [sp, #0x30]
0x10c0c: str    w14, [sp, #0x50]
0x10c10: str    w15, [sp, #0x40]
0x10c14: str    w15, [sp, #0x28]
0x10c18: stp    x11, x12, [sp, #0x18]
0x10c1c: str    w10, [sp, #0x10]
0x10c20: str    w9, [sp, #8]
0x10c24: str    w8, [sp]
0x10c28: bl     #0x2378 ; <duss_log_print>
0x10c2c: b      #0x10e34
0x10c30: adrp   x4, #0x1a000
0x10c34: adrp   x5, #0x1c000
0x10c38: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10c3c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10c40: mov    w0, #0x51
0x10c44: mov    w6, #0x38f
0x10c48: mov    w1, #1
0x10c4c: add    x2, sp, #0xd8
0x10c50: mov    w3, #0x80
0x10c54: bl     #0x2368 ; <duss_log_gen_head>
0x10c58: cbz    w0, #0x10c80
0x10c5c: adrp   x3, #0x1a000
0x10c60: adrp   x4, #0x1a000
0x10c64: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x10c68: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10c6c: mov    w0, #0x51
0x10c70: mov    w5, #0x38f
0x10c74: mov    w1, #1
0x10c78: add    x2, sp, #0xd8
0x10c7c: bl     #0x2378 ; <duss_log_print>
0x10c80: adrp   x4, #0x1a000
0x10c84: adrp   x5, #0x1c000
0x10c88: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10c8c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10c90: mov    w0, #0x51
0x10c94: mov    w6, #0x38f
0x10c98: mov    w1, #1
0x10c9c: add    x2, sp, #0xd8
0x10ca0: mov    w3, #0x80
0x10ca4: bl     #0x2368 ; <duss_log_gen_head>
0x10ca8: cbz    w0, #0x10d70
0x10cac: adrp   x3, #0x1c000
0x10cb0: adrp   x4, #0x1a000
0x10cb4: add    x3, x3, #0x9c7 ; "%s: Failed to create null allocator with error %d
"
0x10cb8: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10cbc: mov    w0, #0x51
0x10cc0: mov    w1, #1
0x10cc4: add    x2, sp, #0xd8
0x10cc8: mov    w5, w22
0x10ccc: b      #0x10d6c
0x10cd0: adrp   x4, #0x1a000
0x10cd4: adrp   x5, #0x1c000
0x10cd8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10cdc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10ce0: mov    w0, #0x51
0x10ce4: mov    w6, #0x3a1
0x10ce8: mov    w1, #1
0x10cec: add    x2, sp, #0xd8
0x10cf0: mov    w3, #0x80
0x10cf4: bl     #0x2368 ; <duss_log_gen_head>
0x10cf8: cbz    w0, #0x10d20
0x10cfc: adrp   x3, #0x1a000
0x10d00: adrp   x4, #0x1a000
0x10d04: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x10d08: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10d0c: mov    w0, #0x51
0x10d10: mov    w5, #0x3a1
0x10d14: mov    w1, #1
0x10d18: add    x2, sp, #0xd8
0x10d1c: bl     #0x2378 ; <duss_log_print>
0x10d20: adrp   x4, #0x1a000
0x10d24: adrp   x5, #0x1c000
0x10d28: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10d2c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10d30: mov    w0, #0x51
0x10d34: mov    w6, #0x3a1
0x10d38: mov    w1, #1
0x10d3c: add    x2, sp, #0xd8
0x10d40: mov    w3, #0x80
0x10d44: bl     #0x2368 ; <duss_log_gen_head>
0x10d48: cbz    w0, #0x10d70
0x10d4c: adrp   x3, #0x1c000
0x10d50: adrp   x4, #0x1a000
0x10d54: add    x3, x3, #0xad5 ; "%s: Failed to create allocator pool with error %d
"
0x10d58: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10d5c: mov    w0, #0x51
0x10d60: mov    w1, #1
0x10d64: add    x2, sp, #0xd8
0x10d68: mov    w5, w24
0x10d6c: bl     #0x2378 ; <duss_log_print>
0x10d70: ldr    x1, [x20]
0x10d74: mov    x0, x19
0x10d78: bl     #0x11ec8
0x10d7c: mov    w0, #-0x3ef
0x10d80: ldr    x8, [x27, #0x28]
0x10d84: ldr    x9, [x25]
0x10d88: cmp    x8, x9
0x10d8c: b.ne   #0x11450
0x10d90: ldp    x29, x30, [sp, #0x1b0]
0x10d94: ldp    x20, x19, [sp, #0x1a0]
0x10d98: ldp    x22, x21, [sp, #0x190]
0x10d9c: ldp    x24, x23, [sp, #0x180]
0x10da0: ldp    x26, x25, [sp, #0x170]
0x10da4: ldp    x28, x27, [sp, #0x160]
0x10da8: add    sp, sp, #0x1c0
0x10dac: ret    
0x10db0: adrp   x4, #0x1a000
0x10db4: adrp   x5, #0x1c000
0x10db8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10dbc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10dc0: mov    w0, #0x51
0x10dc4: mov    w6, #0x3d1
0x10dc8: mov    w1, #3
0x10dcc: add    x2, sp, #0xd8
0x10dd0: mov    w3, #0x80
0x10dd4: bl     #0x2368 ; <duss_log_gen_head>
0x10dd8: cbz    w0, #0x10e34
0x10ddc: ldp    w5, w6, [x21]
0x10de0: ldr    w7, [x21, #0xc]
0x10de4: adrp   x3, #0x1c000
0x10de8: ldr    x8, [sp, #0xd0]
0x10dec: adrp   x4, #0x1a000
0x10df0: ldr    x9, [sp, #0xa8]
0x10df4: mov    w12, #2
0x10df8: ldr    w10, [x19, #0x410]
0x10dfc: add    x3, x3, #0xd46 ; "%s: mem_total_size: %d, min_block_size: %d, stream_buffer_addr_alignment: %d, bps: %lu, fp"
0x10e00: ldr    w11, [x19, #0x458]
0x10e04: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10e08: mov    w0, #0x51
0x10e0c: str    w22, [sp, #0x30]
0x10e10: mov    w1, #3
0x10e14: str    w26, [sp, #0x20]
0x10e18: add    x2, sp, #0xd8
0x10e1c: str    w10, [sp, #0x18]
0x10e20: str    w11, [sp, #0x38]
0x10e24: str    w12, [sp, #0x28]
0x10e28: str    w12, [sp, #0x10]
0x10e2c: stp    x8, x9, [sp]
0x10e30: bl     #0x2378 ; <duss_log_print>
0x10e34: mov    w0, wzr
0x10e38: add    x25, sp, #0x68
0x10e3c: b      #0x10d80
0x10e40: adrp   x4, #0x1a000
0x10e44: adrp   x5, #0x1c000
0x10e48: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10e4c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10e50: mov    w0, #0x51
0x10e54: mov    w6, #0x3e1
0x10e58: mov    w1, #1
0x10e5c: add    x2, sp, #0xd8
0x10e60: mov    w3, #0x80
0x10e64: bl     #0x2368 ; <duss_log_gen_head>
0x10e68: cbz    w0, #0x10e90
0x10e6c: adrp   x3, #0x1a000
0x10e70: adrp   x4, #0x1a000
0x10e74: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x10e78: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10e7c: mov    w0, #0x51
0x10e80: mov    w5, #0x3e1
0x10e84: mov    w1, #1
0x10e88: add    x2, sp, #0xd8
0x10e8c: bl     #0x2378 ; <duss_log_print>
0x10e90: adrp   x4, #0x1a000
0x10e94: adrp   x5, #0x1c000
0x10e98: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10e9c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10ea0: mov    w0, #0x51
0x10ea4: mov    w6, #0x3e1
0x10ea8: mov    w1, #1
0x10eac: add    x2, sp, #0xd8
0x10eb0: mov    w3, #0x80
0x10eb4: bl     #0x2368 ; <duss_log_gen_head>
0x10eb8: cbz    w0, #0x10d70
0x10ebc: adrp   x3, #0x1c000
0x10ec0: adrp   x4, #0x1a000
0x10ec4: add    x3, x3, #0xe86 ; "%s: Failed to create buffer allocators, out of memory?
"
0x10ec8: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x10ecc: mov    w0, #0x51
0x10ed0: mov    w1, #1
0x10ed4: add    x2, sp, #0xd8
0x10ed8: bl     #0x2378 ; <duss_log_print>
0x10edc: b      #0x10d70
0x10ee0: bl     #0x2348 ; <co_thread_get>
0x10ee4: cbnz   x0, #0x1100c
0x10ee8: adrp   x4, #0x1a000
0x10eec: adrp   x5, #0x1c000
0x10ef0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10ef4: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10ef8: mov    w0, #0x51
0x10efc: mov    w6, #0x3db
0x10f00: add    x2, sp, #0xd8
0x10f04: mov    w3, #0x80
0x10f08: mov    w1, wzr
0x10f0c: bl     #0x2368 ; <duss_log_gen_head>
0x10f10: cbz    w0, #0x11094
0x10f14: adrp   x3, #0x1a000
0x10f18: adrp   x4, #0x1b000
0x10f1c: adrp   x5, #0x1a000
0x10f20: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x10f24: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
0x10f28: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10f2c: mov    w0, #0x51
0x10f30: mov    w6, #0x3db
0x10f34: add    x2, sp, #0xd8
0x10f38: mov    w1, wzr
0x10f3c: bl     #0x2378 ; <duss_log_print>
0x10f40: b      #0x11094
0x10f44: bl     #0x2348 ; <co_thread_get>
0x10f48: cbnz   x0, #0x110b0
0x10f4c: adrp   x4, #0x1a000
0x10f50: adrp   x5, #0x1c000
0x10f54: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10f58: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10f5c: mov    w0, #0x51
0x10f60: mov    w6, #0x3b8
0x10f64: add    x2, sp, #0xd8
0x10f68: mov    w3, #0x80
0x10f6c: mov    w1, wzr
0x10f70: bl     #0x2368 ; <duss_log_gen_head>
0x10f74: cbz    w0, #0x11138
0x10f78: adrp   x3, #0x1a000
0x10f7c: adrp   x4, #0x1b000
0x10f80: adrp   x5, #0x1a000
0x10f84: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x10f88: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
0x10f8c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10f90: mov    w0, #0x51
0x10f94: mov    w6, #0x3b8
0x10f98: add    x2, sp, #0xd8
0x10f9c: mov    w1, wzr
0x10fa0: bl     #0x2378 ; <duss_log_print>
0x10fa4: b      #0x11138
0x10fa8: bl     #0x2348 ; <co_thread_get>
0x10fac: cbnz   x0, #0x1115c
0x10fb0: adrp   x4, #0x1a000
0x10fb4: adrp   x5, #0x1c000
0x10fb8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10fbc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x10fc0: mov    w0, #0x51
0x10fc4: add    x2, sp, #0xd8
0x10fc8: mov    w3, #0x80
0x10fcc: mov    w6, #0x3c0
0x10fd0: mov    w1, wzr
0x10fd4: bl     #0x2368 ; <duss_log_gen_head>
0x10fd8: cbz    w0, #0x111e4
0x10fdc: adrp   x3, #0x1a000
0x10fe0: adrp   x4, #0x1b000
0x10fe4: adrp   x5, #0x1a000
0x10fe8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x10fec: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
0x10ff0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x10ff4: mov    w0, #0x51
0x10ff8: add    x2, sp, #0xd8
0x10ffc: mov    w6, #0x3c0
0x11000: mov    w1, wzr
0x11004: bl     #0x2378 ; <duss_log_print>
0x11008: b      #0x111e4
0x1100c: adrp   x8, #0x1a000
0x11010: str    wzr, [sp, #0x74]
0x11014: add    x8, x8, #0x440 ; =0x1a440
0x11018: add    x1, sp, #0x78
0x1101c: add    x2, sp, #0x74
0x11020: str    x8, [sp, #0x78]
0x11024: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11028: adrp   x19, #0x1a000
0x1102c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11030: adrp   x5, #0x1c000
0x11034: mov    w20, #0x3db
0x11038: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1103c: mov    w0, #0x51
0x11040: add    x2, sp, #0xd8
0x11044: mov    w3, #0x80
0x11048: mov    w1, wzr
0x1104c: mov    x4, x19
0x11050: mov    w6, w20
0x11054: bl     #0x2368 ; <duss_log_gen_head>
0x11058: cbz    w0, #0x11094
0x1105c: ldr    x5, [sp, #0x78]
0x11060: adrp   x3, #0x1a000
0x11064: ldr    w6, [sp, #0x74]
0x11068: adrp   x4, #0x1a000
0x1106c: adrp   x7, #0x1b000
0x11070: str    w20, [sp, #8]
0x11074: mov    w1, wzr
0x11078: str    x19, [sp]
0x1107c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11080: add    x4, x4, #0x441 ; "co"
0x11084: mov    w0, #0x51
0x11088: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
0x1108c: add    x2, sp, #0xd8
0x11090: bl     #0x2378 ; <duss_log_print>
0x11094: adrp   x4, #0x1a000
0x11098: adrp   x5, #0x1c000
0x1109c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x110a0: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x110a4: mov    w0, #0x51
0x110a8: mov    w6, #0x3db
0x110ac: b      #0x11150
0x110b0: adrp   x8, #0x1a000
0x110b4: str    wzr, [sp, #0x74]
0x110b8: add    x8, x8, #0x440 ; =0x1a440
0x110bc: add    x1, sp, #0x78
0x110c0: add    x2, sp, #0x74
0x110c4: str    x8, [sp, #0x78]
0x110c8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x110cc: adrp   x19, #0x1a000
0x110d0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x110d4: adrp   x5, #0x1c000
0x110d8: mov    w20, #0x3b8
0x110dc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x110e0: mov    w0, #0x51
0x110e4: add    x2, sp, #0xd8
0x110e8: mov    w3, #0x80
0x110ec: mov    w1, wzr
0x110f0: mov    x4, x19
0x110f4: mov    w6, w20
0x110f8: bl     #0x2368 ; <duss_log_gen_head>
0x110fc: cbz    w0, #0x11138
0x11100: ldr    x5, [sp, #0x78]
0x11104: adrp   x3, #0x1a000
0x11108: ldr    w6, [sp, #0x74]
0x1110c: adrp   x4, #0x1a000
0x11110: adrp   x7, #0x1b000
0x11114: str    w20, [sp, #8]
0x11118: mov    w1, wzr
0x1111c: str    x19, [sp]
0x11120: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11124: add    x4, x4, #0x441 ; "co"
0x11128: mov    w0, #0x51
0x1112c: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
0x11130: add    x2, sp, #0xd8
0x11134: bl     #0x2378 ; <duss_log_print>
0x11138: adrp   x4, #0x1a000
0x1113c: adrp   x5, #0x1c000
0x11140: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11144: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11148: mov    w0, #0x51
0x1114c: mov    w6, #0x3b8
0x11150: add    x2, sp, #0xd8
0x11154: mov    w3, #0x80
0x11158: b      #0x11204
0x1115c: adrp   x8, #0x1a000
0x11160: str    wzr, [sp, #0x74]
0x11164: add    x8, x8, #0x440 ; =0x1a440
0x11168: add    x1, sp, #0x78
0x1116c: add    x2, sp, #0x74
0x11170: str    x8, [sp, #0x78]
0x11174: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11178: adrp   x19, #0x1a000
0x1117c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11180: adrp   x5, #0x1c000
0x11184: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11188: mov    w0, #0x51
0x1118c: add    x2, sp, #0xd8
0x11190: mov    w3, #0x80
0x11194: mov    w6, #0x3c0
0x11198: mov    w1, wzr
0x1119c: mov    x4, x19
0x111a0: mov    w20, #0x3c0
0x111a4: bl     #0x2368 ; <duss_log_gen_head>
0x111a8: cbz    w0, #0x111e4
0x111ac: ldr    x5, [sp, #0x78]
0x111b0: adrp   x3, #0x1a000
0x111b4: ldr    w6, [sp, #0x74]
0x111b8: adrp   x4, #0x1a000
0x111bc: adrp   x7, #0x1b000
0x111c0: str    w20, [sp, #8]
0x111c4: mov    w1, wzr
0x111c8: str    x19, [sp]
0x111cc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x111d0: add    x4, x4, #0x441 ; "co"
0x111d4: mov    w0, #0x51
0x111d8: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
0x111dc: add    x2, sp, #0xd8
0x111e0: bl     #0x2378 ; <duss_log_print>
0x111e4: adrp   x4, #0x1a000
0x111e8: adrp   x5, #0x1c000
0x111ec: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x111f0: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x111f4: mov    w0, #0x51
0x111f8: add    x2, sp, #0xd8
0x111fc: mov    w3, #0x80
0x11200: mov    w6, #0x3c0
0x11204: mov    w1, wzr
0x11208: bl     #0x2368 ; <duss_log_gen_head>
0x1120c: cbz    w0, #0x11228
0x11210: adrp   x3, #0x1a000
0x11214: add    x3, x3, #0x550 ; "Assertion Comment: "
0x11218: mov    w0, #0x51
0x1121c: add    x2, sp, #0xd8
0x11220: mov    w1, wzr
0x11224: bl     #0x2378 ; <duss_log_print>
0x11228: adrp   x0, #0x1a000
0x1122c: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x11230: bl     #0x23e8 ; <log_to_kmsg>
0x11234: adrp   x0, #0x1a000
0x11238: add    x0, x0, #0x57f ; "Camera:	"
0x1123c: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x11240: bl     #0x2408 ; <is_running_in_cam_sil>
0x11244: tbz    w0, #0, #0x11254
0x11248: mov    x0, xzr
0x1124c: bl     #0x2418 ; <fflush>
0x11250: bl     #0x2428 ; <abort>
0x11254: mov    w0, #1
0x11258: bl     #0x2438 ; <exit>
0x1125c: bl     #0x2348 ; <co_thread_get>
0x11260: cbnz   x0, #0x11454
0x11264: adrp   x4, #0x1a000
0x11268: adrp   x5, #0x1c000
0x1126c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11270: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11274: mov    w0, #0x51
0x11278: add    x2, sp, #0xd8
0x1127c: mov    w3, #0x80
0x11280: mov    w6, #0x380
0x11284: mov    w1, wzr
0x11288: bl     #0x2368 ; <duss_log_gen_head>
0x1128c: cbz    w0, #0x114dc
0x11290: adrp   x3, #0x1a000
0x11294: adrp   x4, #0x1a000
0x11298: adrp   x5, #0x1a000
0x1129c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x112a0: add    x4, x4, #0x821 ; "eng"
0x112a4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x112a8: mov    w0, #0x51
0x112ac: add    x2, sp, #0xd8
0x112b0: mov    w6, #0x380
0x112b4: mov    w1, wzr
0x112b8: bl     #0x2378 ; <duss_log_print>
0x112bc: b      #0x114dc
0x112c0: bl     #0x2348 ; <co_thread_get>
0x112c4: cbnz   x0, #0x11500
0x112c8: adrp   x4, #0x1a000
0x112cc: adrp   x5, #0x1c000
0x112d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x112d4: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x112d8: mov    w0, #0x51
0x112dc: mov    w6, #0x381
0x112e0: add    x2, sp, #0xd8
0x112e4: mov    w3, #0x80
0x112e8: mov    w1, wzr
0x112ec: bl     #0x2368 ; <duss_log_gen_head>
0x112f0: cbz    w0, #0x11588
0x112f4: adrp   x3, #0x1a000
0x112f8: adrp   x4, #0x1c000
0x112fc: adrp   x5, #0x1a000
0x11300: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11304: add    x4, x4, #0x3a6 ; "common_cfg"
0x11308: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1130c: mov    w0, #0x51
0x11310: mov    w6, #0x381
0x11314: add    x2, sp, #0xd8
0x11318: mov    w1, wzr
0x1131c: bl     #0x2378 ; <duss_log_print>
0x11320: b      #0x11588
0x11324: bl     #0x2348 ; <co_thread_get>
0x11328: cbnz   x0, #0x115a4
0x1132c: adrp   x4, #0x1a000
0x11330: adrp   x5, #0x1c000
0x11334: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11338: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1133c: mov    w0, #0x51
0x11340: mov    w6, #0x382
0x11344: add    x2, sp, #0xd8
0x11348: mov    w3, #0x80
0x1134c: mov    w1, wzr
0x11350: bl     #0x2368 ; <duss_log_gen_head>
0x11354: cbz    w0, #0x1162c
0x11358: adrp   x3, #0x1a000
0x1135c: adrp   x4, #0x1c000
0x11360: adrp   x5, #0x1a000
0x11364: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11368: add    x4, x4, #0x939 ; "null_allocator"
0x1136c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11370: mov    w0, #0x51
0x11374: mov    w6, #0x382
0x11378: add    x2, sp, #0xd8
0x1137c: mov    w1, wzr
0x11380: bl     #0x2378 ; <duss_log_print>
0x11384: b      #0x1162c
0x11388: bl     #0x2348 ; <co_thread_get>
0x1138c: cbnz   x0, #0x11648
0x11390: adrp   x4, #0x1a000
0x11394: adrp   x5, #0x1c000
0x11398: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1139c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x113a0: mov    w0, #0x51
0x113a4: mov    w6, #0x387
0x113a8: add    x2, sp, #0xd8
0x113ac: mov    w3, #0x80
0x113b0: mov    w1, wzr
0x113b4: bl     #0x2368 ; <duss_log_gen_head>
0x113b8: cbz    w0, #0x116d0
0x113bc: adrp   x3, #0x1a000
0x113c0: adrp   x4, #0x1c000
0x113c4: adrp   x5, #0x1a000
0x113c8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x113cc: add    x4, x4, #0x948 ; "eng->suggested_stream_buf_size > 0"
0x113d0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x113d4: mov    w0, #0x51
0x113d8: mov    w6, #0x387
0x113dc: add    x2, sp, #0xd8
0x113e0: mov    w1, wzr
0x113e4: bl     #0x2378 ; <duss_log_print>
0x113e8: b      #0x116d0
0x113ec: bl     #0x2348 ; <co_thread_get>
0x113f0: cbnz   x0, #0x116ec
0x113f4: adrp   x4, #0x1a000
0x113f8: adrp   x5, #0x1c000
0x113fc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11400: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11404: mov    w0, #0x51
0x11408: mov    w6, #0x38c
0x1140c: add    x2, sp, #0xd8
0x11410: mov    w3, #0x80
0x11414: mov    w1, wzr
0x11418: bl     #0x2368 ; <duss_log_gen_head>
0x1141c: cbz    w0, #0x11774
0x11420: adrp   x3, #0x1a000
0x11424: adrp   x4, #0x1c000
0x11428: adrp   x5, #0x1a000
0x1142c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11430: add    x4, x4, #0x96b ; "*null_allocator == ((void*)0)"
0x11434: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11438: mov    w0, #0x51
0x1143c: mov    w6, #0x38c
0x11440: add    x2, sp, #0xd8
0x11444: mov    w1, wzr
0x11448: bl     #0x2378 ; <duss_log_print>
0x1144c: b      #0x11774
0x11450: bl     #0x23d8 ; <__stack_chk_fail>
0x11454: adrp   x8, #0x1a000
0x11458: str    wzr, [sp, #0x88]
0x1145c: add    x8, x8, #0x440 ; =0x1a440
0x11460: add    x1, sp, #0x90
0x11464: add    x2, sp, #0x88
0x11468: str    x8, [sp, #0x90]
0x1146c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11470: adrp   x19, #0x1a000
0x11474: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11478: adrp   x5, #0x1c000
0x1147c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11480: mov    w0, #0x51
0x11484: add    x2, sp, #0xd8
0x11488: mov    w3, #0x80
0x1148c: mov    w6, #0x380
0x11490: mov    w1, wzr
0x11494: mov    x4, x19
0x11498: mov    w20, #0x380
0x1149c: bl     #0x2368 ; <duss_log_gen_head>
0x114a0: cbz    w0, #0x114dc
0x114a4: ldr    x5, [sp, #0x90]
0x114a8: adrp   x3, #0x1a000
0x114ac: ldr    w6, [sp, #0x88]
0x114b0: adrp   x4, #0x1a000
0x114b4: adrp   x7, #0x1a000
0x114b8: str    w20, [sp, #8]
0x114bc: mov    w1, wzr
0x114c0: str    x19, [sp]
0x114c4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x114c8: add    x4, x4, #0x441 ; "co"
0x114cc: mov    w0, #0x51
0x114d0: add    x7, x7, #0x821 ; "eng"
0x114d4: add    x2, sp, #0xd8
0x114d8: bl     #0x2378 ; <duss_log_print>
0x114dc: adrp   x4, #0x1a000
0x114e0: adrp   x5, #0x1c000
0x114e4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x114e8: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x114ec: mov    w0, #0x51
0x114f0: add    x2, sp, #0xd8
0x114f4: mov    w3, #0x80
0x114f8: mov    w6, #0x380
0x114fc: b      #0x11204
0x11500: adrp   x8, #0x1a000
0x11504: str    wzr, [sp, #0x88]
0x11508: add    x8, x8, #0x440 ; =0x1a440
0x1150c: add    x1, sp, #0x90
0x11510: add    x2, sp, #0x88
0x11514: str    x8, [sp, #0x90]
0x11518: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1151c: adrp   x19, #0x1a000
0x11520: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11524: adrp   x5, #0x1c000
0x11528: mov    w20, #0x381
0x1152c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11530: mov    w0, #0x51
0x11534: add    x2, sp, #0xd8
0x11538: mov    w3, #0x80
0x1153c: mov    w1, wzr
0x11540: mov    x4, x19
0x11544: mov    w6, w20
0x11548: bl     #0x2368 ; <duss_log_gen_head>
0x1154c: cbz    w0, #0x11588
0x11550: ldr    x5, [sp, #0x90]
0x11554: adrp   x3, #0x1a000
0x11558: ldr    w6, [sp, #0x88]
0x1155c: adrp   x4, #0x1a000
0x11560: adrp   x7, #0x1c000
0x11564: str    w20, [sp, #8]
0x11568: mov    w1, wzr
0x1156c: str    x19, [sp]
0x11570: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11574: add    x4, x4, #0x441 ; "co"
0x11578: mov    w0, #0x51
0x1157c: add    x7, x7, #0x3a6 ; "common_cfg"
0x11580: add    x2, sp, #0xd8
0x11584: bl     #0x2378 ; <duss_log_print>
0x11588: adrp   x4, #0x1a000
0x1158c: adrp   x5, #0x1c000
0x11590: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11594: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11598: mov    w0, #0x51
0x1159c: mov    w6, #0x381
0x115a0: b      #0x11150
0x115a4: adrp   x8, #0x1a000
0x115a8: str    wzr, [sp, #0x88]
0x115ac: add    x8, x8, #0x440 ; =0x1a440
0x115b0: add    x1, sp, #0x90
0x115b4: add    x2, sp, #0x88
0x115b8: str    x8, [sp, #0x90]
0x115bc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x115c0: adrp   x19, #0x1a000
0x115c4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x115c8: adrp   x5, #0x1c000
0x115cc: mov    w20, #0x382
0x115d0: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x115d4: mov    w0, #0x51
0x115d8: add    x2, sp, #0xd8
0x115dc: mov    w3, #0x80
0x115e0: mov    w1, wzr
0x115e4: mov    x4, x19
0x115e8: mov    w6, w20
0x115ec: bl     #0x2368 ; <duss_log_gen_head>
0x115f0: cbz    w0, #0x1162c
0x115f4: ldr    x5, [sp, #0x90]
0x115f8: adrp   x3, #0x1a000
0x115fc: ldr    w6, [sp, #0x88]
0x11600: adrp   x4, #0x1a000
0x11604: adrp   x7, #0x1c000
0x11608: str    w20, [sp, #8]
0x1160c: mov    w1, wzr
0x11610: str    x19, [sp]
0x11614: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11618: add    x4, x4, #0x441 ; "co"
0x1161c: mov    w0, #0x51
0x11620: add    x7, x7, #0x939 ; "null_allocator"
0x11624: add    x2, sp, #0xd8
0x11628: bl     #0x2378 ; <duss_log_print>
0x1162c: adrp   x4, #0x1a000
0x11630: adrp   x5, #0x1c000
0x11634: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11638: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1163c: mov    w0, #0x51
0x11640: mov    w6, #0x382
0x11644: b      #0x11150
0x11648: adrp   x8, #0x1a000
0x1164c: str    wzr, [sp, #0x78]
0x11650: add    x8, x8, #0x440 ; =0x1a440
0x11654: add    x1, sp, #0x88
0x11658: add    x2, sp, #0x78
0x1165c: str    x8, [sp, #0x88]
0x11660: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11664: adrp   x19, #0x1a000
0x11668: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1166c: adrp   x5, #0x1c000
0x11670: mov    w20, #0x387
0x11674: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11678: mov    w0, #0x51
0x1167c: add    x2, sp, #0xd8
0x11680: mov    w3, #0x80
0x11684: mov    w1, wzr
0x11688: mov    x4, x19
0x1168c: mov    w6, w20
0x11690: bl     #0x2368 ; <duss_log_gen_head>
0x11694: cbz    w0, #0x116d0
0x11698: ldr    x5, [sp, #0x88]
0x1169c: adrp   x3, #0x1a000
0x116a0: ldr    w6, [sp, #0x78]
0x116a4: adrp   x4, #0x1a000
0x116a8: adrp   x7, #0x1c000
0x116ac: str    w20, [sp, #8]
0x116b0: mov    w1, wzr
0x116b4: str    x19, [sp]
0x116b8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x116bc: add    x4, x4, #0x441 ; "co"
0x116c0: mov    w0, #0x51
0x116c4: add    x7, x7, #0x948 ; "eng->suggested_stream_buf_size > 0"
0x116c8: add    x2, sp, #0xd8
0x116cc: bl     #0x2378 ; <duss_log_print>
0x116d0: adrp   x4, #0x1a000
0x116d4: adrp   x5, #0x1c000
0x116d8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x116dc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x116e0: mov    w0, #0x51
0x116e4: mov    w6, #0x387
0x116e8: b      #0x11150
0x116ec: adrp   x8, #0x1a000
0x116f0: str    wzr, [sp, #0x78]
0x116f4: add    x8, x8, #0x440 ; =0x1a440
0x116f8: add    x1, sp, #0x88
0x116fc: add    x2, sp, #0x78
0x11700: str    x8, [sp, #0x88]
0x11704: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11708: adrp   x19, #0x1a000
0x1170c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11710: adrp   x5, #0x1c000
0x11714: mov    w20, #0x38c
0x11718: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1171c: mov    w0, #0x51
0x11720: add    x2, sp, #0xd8
0x11724: mov    w3, #0x80
0x11728: mov    w1, wzr
0x1172c: mov    x4, x19
0x11730: mov    w6, w20
0x11734: bl     #0x2368 ; <duss_log_gen_head>
0x11738: cbz    w0, #0x11774
0x1173c: ldr    x5, [sp, #0x88]
0x11740: adrp   x3, #0x1a000
0x11744: ldr    w6, [sp, #0x78]
0x11748: adrp   x4, #0x1a000
0x1174c: adrp   x7, #0x1c000
0x11750: str    w20, [sp, #8]
0x11754: mov    w1, wzr
0x11758: str    x19, [sp]
0x1175c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11760: add    x4, x4, #0x441 ; "co"
0x11764: mov    w0, #0x51
0x11768: add    x7, x7, #0x96b ; "*null_allocator == ((void*)0)"
0x1176c: add    x2, sp, #0xd8
0x11770: bl     #0x2378 ; <duss_log_print>
0x11774: adrp   x4, #0x1a000
0x11778: adrp   x5, #0x1c000
0x1177c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11780: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11784: mov    w0, #0x51
0x11788: mov    w6, #0x38c
0x1178c: b      #0x11150
0x11790: bl     #0x2348 ; <co_thread_get>
0x11794: cbnz   x0, #0x11984
0x11798: adrp   x4, #0x1a000
0x1179c: adrp   x5, #0x1c000
0x117a0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x117a4: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x117a8: mov    w0, #0x51
0x117ac: mov    w6, #0x392
0x117b0: add    x2, sp, #0xd8
0x117b4: mov    w3, #0x80
0x117b8: mov    w1, wzr
0x117bc: bl     #0x2368 ; <duss_log_gen_head>
0x117c0: cbz    w0, #0x11a0c
0x117c4: adrp   x3, #0x1a000
0x117c8: adrp   x4, #0x1c000
0x117cc: adrp   x5, #0x1a000
0x117d0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x117d4: add    x4, x4, #0x9fa ; "*null_allocator"
0x117d8: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x117dc: mov    w0, #0x51
0x117e0: mov    w6, #0x392
0x117e4: add    x2, sp, #0xd8
0x117e8: mov    w1, wzr
0x117ec: bl     #0x2378 ; <duss_log_print>
0x117f0: b      #0x11a0c
0x117f4: bl     #0x2348 ; <co_thread_get>
0x117f8: cbnz   x0, #0x11a28
0x117fc: adrp   x4, #0x1a000
0x11800: adrp   x5, #0x1c000
0x11804: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11808: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x1180c: mov    w0, #0x51
0x11810: mov    w6, #0x396
0x11814: add    x2, sp, #0xd8
0x11818: mov    w3, #0x80
0x1181c: mov    w1, wzr
0x11820: bl     #0x2368 ; <duss_log_gen_head>
0x11824: cbz    w0, #0x11ab0
0x11828: adrp   x3, #0x1a000
0x1182c: adrp   x4, #0x1c000
0x11830: adrp   x5, #0x1a000
0x11834: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11838: add    x4, x4, #0xa0a ; "allocator_count_min <= allocator_count_max"
0x1183c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11840: mov    w0, #0x51
0x11844: mov    w6, #0x396
0x11848: add    x2, sp, #0xd8
0x1184c: mov    w1, wzr
0x11850: bl     #0x2378 ; <duss_log_print>
0x11854: b      #0x11ab0
0x11858: bl     #0x2348 ; <co_thread_get>
0x1185c: cbnz   x0, #0x11acc
0x11860: adrp   x4, #0x1a000
0x11864: adrp   x5, #0x1c000
0x11868: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1186c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11870: mov    w0, #0x51
0x11874: mov    w6, #0x397
0x11878: add    x2, sp, #0xd8
0x1187c: mov    w3, #0x80
0x11880: mov    w1, wzr
0x11884: bl     #0x2368 ; <duss_log_gen_head>
0x11888: cbz    w0, #0x11b54
0x1188c: adrp   x3, #0x1a000
0x11890: adrp   x4, #0x1c000
0x11894: adrp   x5, #0x1a000
0x11898: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1189c: add    x4, x4, #0xa35 ; "eng->allocator_pool_size == 0"
0x118a0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x118a4: mov    w0, #0x51
0x118a8: mov    w6, #0x397
0x118ac: add    x2, sp, #0xd8
0x118b0: mov    w1, wzr
0x118b4: bl     #0x2378 ; <duss_log_print>
0x118b8: b      #0x11b54
0x118bc: bl     #0x2348 ; <co_thread_get>
0x118c0: cbnz   x0, #0x11b70
0x118c4: adrp   x4, #0x1a000
0x118c8: adrp   x5, #0x1c000
0x118cc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x118d0: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x118d4: mov    w0, #0x51
0x118d8: mov    w6, #0x39a
0x118dc: add    x2, sp, #0xd8
0x118e0: mov    w3, #0x80
0x118e4: mov    w1, wzr
0x118e8: bl     #0x2368 ; <duss_log_gen_head>
0x118ec: cbz    w0, #0x11bf8
0x118f0: adrp   x3, #0x1a000
0x118f4: adrp   x4, #0x1c000
0x118f8: adrp   x5, #0x1a000
0x118fc: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11900: add    x4, x4, #0xa53 ; "cfg.common_cfg.fps"
0x11904: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11908: mov    w0, #0x51
0x1190c: mov    w6, #0x39a
0x11910: add    x2, sp, #0xd8
0x11914: mov    w1, wzr
0x11918: bl     #0x2378 ; <duss_log_print>
0x1191c: b      #0x11bf8
0x11920: bl     #0x2348 ; <co_thread_get>
0x11924: cbnz   x0, #0x11c14
0x11928: adrp   x4, #0x1a000
0x1192c: adrp   x5, #0x1c000
0x11930: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11934: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11938: mov    w0, #0x51
0x1193c: mov    w6, #0x39d
0x11940: add    x2, sp, #0xd8
0x11944: mov    w3, #0x80
0x11948: mov    w1, wzr
0x1194c: bl     #0x2368 ; <duss_log_gen_head>
0x11950: cbz    w0, #0x11c9c
0x11954: adrp   x3, #0x1a000
0x11958: adrp   x4, #0x1c000
0x1195c: adrp   x5, #0x1a000
0x11960: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11964: add    x4, x4, #0xa66 ; "eng->allocator_pool == ((void*)0)"
0x11968: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1196c: mov    w0, #0x51
0x11970: mov    w6, #0x39d
0x11974: add    x2, sp, #0xd8
0x11978: mov    w1, wzr
0x1197c: bl     #0x2378 ; <duss_log_print>
0x11980: b      #0x11c9c
0x11984: adrp   x8, #0x1a000
0x11988: str    wzr, [sp, #0x78]
0x1198c: add    x8, x8, #0x440 ; =0x1a440
0x11990: add    x1, sp, #0x88
0x11994: add    x2, sp, #0x78
0x11998: str    x8, [sp, #0x88]
0x1199c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x119a0: adrp   x19, #0x1a000
0x119a4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x119a8: adrp   x5, #0x1c000
0x119ac: mov    w20, #0x392
0x119b0: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x119b4: mov    w0, #0x51
0x119b8: add    x2, sp, #0xd8
0x119bc: mov    w3, #0x80
0x119c0: mov    w1, wzr
0x119c4: mov    x4, x19
0x119c8: mov    w6, w20
0x119cc: bl     #0x2368 ; <duss_log_gen_head>
0x119d0: cbz    w0, #0x11a0c
0x119d4: ldr    x5, [sp, #0x88]
0x119d8: adrp   x3, #0x1a000
0x119dc: ldr    w6, [sp, #0x78]
0x119e0: adrp   x4, #0x1a000
0x119e4: adrp   x7, #0x1c000
0x119e8: str    w20, [sp, #8]
0x119ec: mov    w1, wzr
0x119f0: str    x19, [sp]
0x119f4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x119f8: add    x4, x4, #0x441 ; "co"
0x119fc: mov    w0, #0x51
0x11a00: add    x7, x7, #0x9fa ; "*null_allocator"
0x11a04: add    x2, sp, #0xd8
0x11a08: bl     #0x2378 ; <duss_log_print>
0x11a0c: adrp   x4, #0x1a000
0x11a10: adrp   x5, #0x1c000
0x11a14: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11a18: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11a1c: mov    w0, #0x51
0x11a20: mov    w6, #0x392
0x11a24: b      #0x11150
0x11a28: adrp   x8, #0x1a000
0x11a2c: str    wzr, [sp, #0x78]
0x11a30: add    x8, x8, #0x440 ; =0x1a440
0x11a34: add    x1, sp, #0x88
0x11a38: add    x2, sp, #0x78
0x11a3c: str    x8, [sp, #0x88]
0x11a40: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11a44: adrp   x19, #0x1a000
0x11a48: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11a4c: adrp   x5, #0x1c000
0x11a50: mov    w20, #0x396
0x11a54: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11a58: mov    w0, #0x51
0x11a5c: add    x2, sp, #0xd8
0x11a60: mov    w3, #0x80
0x11a64: mov    w1, wzr
0x11a68: mov    x4, x19
0x11a6c: mov    w6, w20
0x11a70: bl     #0x2368 ; <duss_log_gen_head>
0x11a74: cbz    w0, #0x11ab0
0x11a78: ldr    x5, [sp, #0x88]
0x11a7c: adrp   x3, #0x1a000
0x11a80: ldr    w6, [sp, #0x78]
0x11a84: adrp   x4, #0x1a000
0x11a88: adrp   x7, #0x1c000
0x11a8c: str    w20, [sp, #8]
0x11a90: mov    w1, wzr
0x11a94: str    x19, [sp]
0x11a98: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11a9c: add    x4, x4, #0x441 ; "co"
0x11aa0: mov    w0, #0x51
0x11aa4: add    x7, x7, #0xa0a ; "allocator_count_min <= allocator_count_max"
0x11aa8: add    x2, sp, #0xd8
0x11aac: bl     #0x2378 ; <duss_log_print>
0x11ab0: adrp   x4, #0x1a000
0x11ab4: adrp   x5, #0x1c000
0x11ab8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11abc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11ac0: mov    w0, #0x51
0x11ac4: mov    w6, #0x396
0x11ac8: b      #0x11150
0x11acc: adrp   x8, #0x1a000
0x11ad0: str    wzr, [sp, #0x78]
0x11ad4: add    x8, x8, #0x440 ; =0x1a440
0x11ad8: add    x1, sp, #0x88
0x11adc: add    x2, sp, #0x78
0x11ae0: str    x8, [sp, #0x88]
0x11ae4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11ae8: adrp   x19, #0x1a000
0x11aec: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11af0: adrp   x5, #0x1c000
0x11af4: mov    w20, #0x397
0x11af8: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11afc: mov    w0, #0x51
0x11b00: add    x2, sp, #0xd8
0x11b04: mov    w3, #0x80
0x11b08: mov    w1, wzr
0x11b0c: mov    x4, x19
0x11b10: mov    w6, w20
0x11b14: bl     #0x2368 ; <duss_log_gen_head>
0x11b18: cbz    w0, #0x11b54
0x11b1c: ldr    x5, [sp, #0x88]
0x11b20: adrp   x3, #0x1a000
0x11b24: ldr    w6, [sp, #0x78]
0x11b28: adrp   x4, #0x1a000
0x11b2c: adrp   x7, #0x1c000
0x11b30: str    w20, [sp, #8]
0x11b34: mov    w1, wzr
0x11b38: str    x19, [sp]
0x11b3c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11b40: add    x4, x4, #0x441 ; "co"
0x11b44: mov    w0, #0x51
0x11b48: add    x7, x7, #0xa35 ; "eng->allocator_pool_size == 0"
0x11b4c: add    x2, sp, #0xd8
0x11b50: bl     #0x2378 ; <duss_log_print>
0x11b54: adrp   x4, #0x1a000
0x11b58: adrp   x5, #0x1c000
0x11b5c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11b60: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11b64: mov    w0, #0x51
0x11b68: mov    w6, #0x397
0x11b6c: b      #0x11150
0x11b70: adrp   x8, #0x1a000
0x11b74: str    wzr, [sp, #0x78]
0x11b78: add    x8, x8, #0x440 ; =0x1a440
0x11b7c: add    x1, sp, #0x88
0x11b80: add    x2, sp, #0x78
0x11b84: str    x8, [sp, #0x88]
0x11b88: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11b8c: adrp   x19, #0x1a000
0x11b90: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11b94: adrp   x5, #0x1c000
0x11b98: mov    w20, #0x39a
0x11b9c: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11ba0: mov    w0, #0x51
0x11ba4: add    x2, sp, #0xd8
0x11ba8: mov    w3, #0x80
0x11bac: mov    w1, wzr
0x11bb0: mov    x4, x19
0x11bb4: mov    w6, w20
0x11bb8: bl     #0x2368 ; <duss_log_gen_head>
0x11bbc: cbz    w0, #0x11bf8
0x11bc0: ldr    x5, [sp, #0x88]
0x11bc4: adrp   x3, #0x1a000
0x11bc8: ldr    w6, [sp, #0x78]
0x11bcc: adrp   x4, #0x1a000
0x11bd0: adrp   x7, #0x1c000
0x11bd4: str    w20, [sp, #8]
0x11bd8: mov    w1, wzr
0x11bdc: str    x19, [sp]
0x11be0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11be4: add    x4, x4, #0x441 ; "co"
0x11be8: mov    w0, #0x51
0x11bec: add    x7, x7, #0xa53 ; "cfg.common_cfg.fps"
0x11bf0: add    x2, sp, #0xd8
0x11bf4: bl     #0x2378 ; <duss_log_print>
0x11bf8: adrp   x4, #0x1a000
0x11bfc: adrp   x5, #0x1c000
0x11c00: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11c04: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11c08: mov    w0, #0x51
0x11c0c: mov    w6, #0x39a
0x11c10: b      #0x11150
0x11c14: adrp   x8, #0x1a000
0x11c18: str    wzr, [sp, #0x78]
0x11c1c: add    x8, x8, #0x440 ; =0x1a440
0x11c20: add    x1, sp, #0x88
0x11c24: add    x2, sp, #0x78
0x11c28: str    x8, [sp, #0x88]
0x11c2c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11c30: adrp   x19, #0x1a000
0x11c34: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11c38: adrp   x5, #0x1c000
0x11c3c: mov    w20, #0x39d
0x11c40: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11c44: mov    w0, #0x51
0x11c48: add    x2, sp, #0xd8
0x11c4c: mov    w3, #0x80
0x11c50: mov    w1, wzr
0x11c54: mov    x4, x19
0x11c58: mov    w6, w20
0x11c5c: bl     #0x2368 ; <duss_log_gen_head>
0x11c60: cbz    w0, #0x11c9c
0x11c64: ldr    x5, [sp, #0x88]
0x11c68: adrp   x3, #0x1a000
0x11c6c: ldr    w6, [sp, #0x78]
0x11c70: adrp   x4, #0x1a000
0x11c74: adrp   x7, #0x1c000
0x11c78: str    w20, [sp, #8]
0x11c7c: mov    w1, wzr
0x11c80: str    x19, [sp]
0x11c84: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11c88: add    x4, x4, #0x441 ; "co"
0x11c8c: mov    w0, #0x51
0x11c90: add    x7, x7, #0xa66 ; "eng->allocator_pool == ((void*)0)"
0x11c94: add    x2, sp, #0xd8
0x11c98: bl     #0x2378 ; <duss_log_print>
0x11c9c: adrp   x4, #0x1a000
0x11ca0: adrp   x5, #0x1c000
0x11ca4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11ca8: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11cac: mov    w0, #0x51
0x11cb0: mov    w6, #0x39d
0x11cb4: b      #0x11150
0x11cb8: bl     #0x2348 ; <co_thread_get>
0x11cbc: cbnz   x0, #0x11d80
0x11cc0: adrp   x4, #0x1a000
0x11cc4: adrp   x5, #0x1c000
0x11cc8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11ccc: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11cd0: mov    w0, #0x51
0x11cd4: mov    w6, #0x3a6
0x11cd8: add    x2, sp, #0xd8
0x11cdc: mov    w3, #0x80
0x11ce0: mov    w1, wzr
0x11ce4: bl     #0x2368 ; <duss_log_gen_head>
0x11ce8: cbz    w0, #0x11e08
0x11cec: adrp   x3, #0x1a000
0x11cf0: adrp   x4, #0x1c000
0x11cf4: adrp   x5, #0x1a000
0x11cf8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11cfc: add    x4, x4, #0xb08 ; "enqueued_count == 0"
0x11d00: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11d04: mov    w0, #0x51
0x11d08: mov    w6, #0x3a6
0x11d0c: add    x2, sp, #0xd8
0x11d10: mov    w1, wzr
0x11d14: bl     #0x2378 ; <duss_log_print>
0x11d18: b      #0x11e08
0x11d1c: bl     #0x2348 ; <co_thread_get>
0x11d20: cbnz   x0, #0x11e24
0x11d24: adrp   x4, #0x1a000
0x11d28: adrp   x5, #0x1c000
0x11d2c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11d30: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11d34: mov    w0, #0x51
0x11d38: mov    w6, #0x3c5
0x11d3c: add    x2, sp, #0xd8
0x11d40: mov    w3, #0x80
0x11d44: mov    w1, wzr
0x11d48: bl     #0x2368 ; <duss_log_gen_head>
0x11d4c: cbz    w0, #0x11eac
0x11d50: adrp   x3, #0x1a000
0x11d54: adrp   x4, #0x1c000
0x11d58: adrp   x5, #0x1a000
0x11d5c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11d60: add    x4, x4, #0xc1c ; "eng->created_allocator_count == 0"
0x11d64: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11d68: mov    w0, #0x51
0x11d6c: mov    w6, #0x3c5
0x11d70: add    x2, sp, #0xd8
0x11d74: mov    w1, wzr
0x11d78: bl     #0x2378 ; <duss_log_print>
0x11d7c: b      #0x11eac
0x11d80: adrp   x8, #0x1a000
0x11d84: str    wzr, [sp, #0x78]
0x11d88: add    x8, x8, #0x440 ; =0x1a440
0x11d8c: add    x1, sp, #0x88
0x11d90: add    x2, sp, #0x78
0x11d94: str    x8, [sp, #0x88]
0x11d98: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11d9c: adrp   x19, #0x1a000
0x11da0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11da4: adrp   x5, #0x1c000
0x11da8: mov    w20, #0x3a6
0x11dac: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11db0: mov    w0, #0x51
0x11db4: add    x2, sp, #0xd8
0x11db8: mov    w3, #0x80
0x11dbc: mov    w1, wzr
0x11dc0: mov    x4, x19
0x11dc4: mov    w6, w20
0x11dc8: bl     #0x2368 ; <duss_log_gen_head>
0x11dcc: cbz    w0, #0x11e08
0x11dd0: ldr    x5, [sp, #0x88]
0x11dd4: adrp   x3, #0x1a000
0x11dd8: ldr    w6, [sp, #0x78]
0x11ddc: adrp   x4, #0x1a000
0x11de0: adrp   x7, #0x1c000
0x11de4: str    w20, [sp, #8]
0x11de8: mov    w1, wzr
0x11dec: str    x19, [sp]
0x11df0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11df4: add    x4, x4, #0x441 ; "co"
0x11df8: mov    w0, #0x51
0x11dfc: add    x7, x7, #0xb08 ; "enqueued_count == 0"
0x11e00: add    x2, sp, #0xd8
0x11e04: bl     #0x2378 ; <duss_log_print>
0x11e08: adrp   x4, #0x1a000
0x11e0c: adrp   x5, #0x1c000
0x11e10: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11e14: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11e18: mov    w0, #0x51
0x11e1c: mov    w6, #0x3a6
0x11e20: b      #0x11150
0x11e24: adrp   x8, #0x1a000
0x11e28: str    wzr, [sp, #0x78]
0x11e2c: add    x8, x8, #0x440 ; =0x1a440
0x11e30: add    x1, sp, #0x88
0x11e34: add    x2, sp, #0x78
0x11e38: str    x8, [sp, #0x88]
0x11e3c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x11e40: adrp   x19, #0x1a000
0x11e44: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11e48: adrp   x5, #0x1c000
0x11e4c: mov    w20, #0x3c5
0x11e50: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11e54: mov    w0, #0x51
0x11e58: add    x2, sp, #0xd8
0x11e5c: mov    w3, #0x80
0x11e60: mov    w1, wzr
0x11e64: mov    x4, x19
0x11e68: mov    w6, w20
0x11e6c: bl     #0x2368 ; <duss_log_gen_head>
0x11e70: cbz    w0, #0x11eac
0x11e74: ldr    x5, [sp, #0x88]
0x11e78: adrp   x3, #0x1a000
0x11e7c: ldr    w6, [sp, #0x78]
0x11e80: adrp   x4, #0x1a000
0x11e84: adrp   x7, #0x1c000
0x11e88: str    w20, [sp, #8]
0x11e8c: mov    w1, wzr
0x11e90: str    x19, [sp]
0x11e94: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x11e98: add    x4, x4, #0x441 ; "co"
0x11e9c: mov    w0, #0x51
0x11ea0: add    x7, x7, #0xc1c ; "eng->created_allocator_count == 0"
0x11ea4: add    x2, sp, #0xd8
0x11ea8: bl     #0x2378 ; <duss_log_print>
0x11eac: adrp   x4, #0x1a000
0x11eb0: adrp   x5, #0x1c000
0x11eb4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11eb8: add    x5, x5, #0x920 ; "_create_buffer_allocator"
0x11ebc: mov    w0, #0x51
0x11ec0: mov    w6, #0x3c5
0x11ec4: b      #0x11150
0x11ec8: sub    sp, sp, #0x100
0x11ecc: stp    x24, x23, [sp, #0xc0]
0x11ed0: stp    x22, x21, [sp, #0xd0]
0x11ed4: stp    x20, x19, [sp, #0xe0]
0x11ed8: stp    x29, x30, [sp, #0xf0]
0x11edc: add    x29, sp, #0xf0
0x11ee0: mrs    x22, tpidr_el0
0x11ee4: mov    x20, x0
0x11ee8: ldr    x8, [x22, #0x28]
0x11eec: add    x23, sp, #0x18
0x11ef0: mov    x19, x1
0x11ef4: str    x8, [x23]
0x11ef8: cbz    x20, #0x120e8
0x11efc: ldr    x0, [x20, #0x408]
0x11f00: cbz    x0, #0x11f50
0x11f04: bl     #0x2478 ; <buffer_queue_get_enqueued_count>
0x11f08: mov    w21, w0
0x11f0c: cbz    w21, #0x11f40
0x11f10: mov    w24, wzr
0x11f14: ldr    x0, [x20, #0x408]
0x11f18: add    x1, sp, #0x30
0x11f1c: bl     #0x2508 ; <buffer_queue_dequeue>
0x11f20: cbnz   w0, #0x11f84
0x11f24: ldr    x0, [sp, #0x30]
0x11f28: bl     #0x2798 ; <cam_encoded_buffer_allocator_deinit>
0x11f2c: ldr    x0, [sp, #0x30]
0x11f30: bl     #0x2788 ; <cam_encoded_buffer_allocator_destroy>
0x11f34: add    w24, w24, #1
0x11f38: cmp    w24, w21
0x11f3c: b.lo   #0x11f14
0x11f40: ldr    x0, [x20, #0x408]
0x11f44: str    wzr, [x20, #0x414]
0x11f48: bl     #0x26a8 ; <buffer_queue_destroy>
0x11f4c: str    xzr, [x20, #0x408]
0x11f50: cbz    x19, #0x11f5c
0x11f54: mov    x0, x19
0x11f58: bl     #0x2788 ; <cam_encoded_buffer_allocator_destroy>
0x11f5c: ldr    x8, [x22, #0x28]
0x11f60: ldr    x9, [x23]
0x11f64: cmp    x8, x9
0x11f68: b.ne   #0x1214c
0x11f6c: ldp    x29, x30, [sp, #0xf0]
0x11f70: ldp    x20, x19, [sp, #0xe0]
0x11f74: ldp    x22, x21, [sp, #0xd0]
0x11f78: ldp    x24, x23, [sp, #0xc0]
0x11f7c: add    sp, sp, #0x100
0x11f80: ret    
0x11f84: bl     #0x2348 ; <co_thread_get>
0x11f88: cbnz   x0, #0x11fe8
0x11f8c: adrp   x4, #0x1a000
0x11f90: adrp   x5, #0x1c000
0x11f94: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11f98: add    x5, x5, #0xebe ; "_destroy_buffer_allocator"
0x11f9c: mov    w0, #0x51
0x11fa0: mov    w6, #0x3f4
0x11fa4: add    x2, sp, #0x38
0x11fa8: mov    w3, #0x80
0x11fac: mov    w1, wzr
0x11fb0: bl     #0x2368 ; <duss_log_gen_head>
0x11fb4: cbz    w0, #0x12070
0x11fb8: adrp   x3, #0x1a000
0x11fbc: adrp   x4, #0x1b000
0x11fc0: adrp   x5, #0x1a000
0x11fc4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x11fc8: add    x4, x4, #0x464 ; "rlt == ((duss_result_t) 0)"
0x11fcc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x11fd0: mov    w0, #0x51
0x11fd4: mov    w6, #0x3f4
0x11fd8: add    x2, sp, #0x38
0x11fdc: mov    w1, wzr
0x11fe0: bl     #0x2378 ; <duss_log_print>
0x11fe4: b      #0x12070
0x11fe8: adrp   x8, #0x1a000
0x11fec: str    wzr, [sp, #0x24]
0x11ff0: add    x8, x8, #0x440 ; =0x1a440
0x11ff4: add    x1, sp, #0x28
0x11ff8: add    x2, sp, #0x24
0x11ffc: str    x8, [sp, #0x28]
0x12000: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12004: adrp   x19, #0x1a000
0x12008: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1200c: adrp   x5, #0x1c000
0x12010: mov    w20, #0x3f4
0x12014: add    x5, x5, #0xebe ; "_destroy_buffer_allocator"
0x12018: mov    w0, #0x51
0x1201c: add    x2, sp, #0x38
0x12020: mov    w3, #0x80
0x12024: mov    w1, wzr
0x12028: mov    x4, x19
0x1202c: mov    w6, w20
0x12030: bl     #0x2368 ; <duss_log_gen_head>
0x12034: cbz    w0, #0x12070
0x12038: ldr    x5, [sp, #0x28]
0x1203c: adrp   x3, #0x1a000
0x12040: ldr    w6, [sp, #0x24]
0x12044: adrp   x4, #0x1a000
0x12048: adrp   x7, #0x1b000
0x1204c: str    w20, [sp, #8]
0x12050: mov    w1, wzr
0x12054: str    x19, [sp]
0x12058: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x1205c: add    x4, x4, #0x441 ; "co"
0x12060: mov    w0, #0x51
0x12064: add    x7, x7, #0x464 ; "rlt == ((duss_result_t) 0)"
0x12068: add    x2, sp, #0x38
0x1206c: bl     #0x2378 ; <duss_log_print>
0x12070: adrp   x4, #0x1a000
0x12074: adrp   x5, #0x1c000
0x12078: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1207c: add    x5, x5, #0xebe ; "_destroy_buffer_allocator"
0x12080: mov    w0, #0x51
0x12084: mov    w6, #0x3f4
0x12088: add    x2, sp, #0x38
0x1208c: mov    w3, #0x80
0x12090: mov    w1, wzr
0x12094: bl     #0x2368 ; <duss_log_gen_head>
0x12098: cbz    w0, #0x120b4
0x1209c: adrp   x3, #0x1a000
0x120a0: add    x3, x3, #0x550 ; "Assertion Comment: "
0x120a4: mov    w0, #0x51
0x120a8: add    x2, sp, #0x38
0x120ac: mov    w1, wzr
0x120b0: bl     #0x2378 ; <duss_log_print>
0x120b4: adrp   x0, #0x1a000
0x120b8: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x120bc: bl     #0x23e8 ; <log_to_kmsg>
0x120c0: adrp   x0, #0x1a000
0x120c4: add    x0, x0, #0x57f ; "Camera:	"
0x120c8: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x120cc: bl     #0x2408 ; <is_running_in_cam_sil>
0x120d0: tbz    w0, #0, #0x120e0
0x120d4: mov    x0, xzr
0x120d8: bl     #0x2418 ; <fflush>
0x120dc: bl     #0x2428 ; <abort>
0x120e0: mov    w0, #1
0x120e4: bl     #0x2438 ; <exit>
0x120e8: bl     #0x2348 ; <co_thread_get>
0x120ec: cbnz   x0, #0x12150
0x120f0: adrp   x4, #0x1a000
0x120f4: adrp   x5, #0x1c000
0x120f8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x120fc: add    x5, x5, #0xebe ; "_destroy_buffer_allocator"
0x12100: mov    w0, #0x51
0x12104: mov    w6, #0x3ec
0x12108: add    x2, sp, #0x38
0x1210c: mov    w3, #0x80
0x12110: mov    w1, wzr
0x12114: bl     #0x2368 ; <duss_log_gen_head>
0x12118: cbz    w0, #0x121d8
0x1211c: adrp   x3, #0x1a000
0x12120: adrp   x4, #0x1a000
0x12124: adrp   x5, #0x1a000
0x12128: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1212c: add    x4, x4, #0x821 ; "eng"
0x12130: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12134: mov    w0, #0x51
0x12138: mov    w6, #0x3ec
0x1213c: add    x2, sp, #0x38
0x12140: mov    w1, wzr
0x12144: bl     #0x2378 ; <duss_log_print>
0x12148: b      #0x121d8
0x1214c: bl     #0x23d8 ; <__stack_chk_fail>
0x12150: adrp   x8, #0x1a000
0x12154: str    wzr, [sp, #0x28]
0x12158: add    x8, x8, #0x440 ; =0x1a440
0x1215c: add    x1, sp, #0x30
0x12160: add    x2, sp, #0x28
0x12164: str    x8, [sp, #0x30]
0x12168: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1216c: adrp   x19, #0x1a000
0x12170: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12174: adrp   x5, #0x1c000
0x12178: mov    w20, #0x3ec
0x1217c: add    x5, x5, #0xebe ; "_destroy_buffer_allocator"
0x12180: mov    w0, #0x51
0x12184: add    x2, sp, #0x38
0x12188: mov    w3, #0x80
0x1218c: mov    w1, wzr
0x12190: mov    x4, x19
0x12194: mov    w6, w20
0x12198: bl     #0x2368 ; <duss_log_gen_head>
0x1219c: cbz    w0, #0x121d8
0x121a0: ldr    x5, [sp, #0x30]
0x121a4: adrp   x3, #0x1a000
0x121a8: ldr    w6, [sp, #0x28]
0x121ac: adrp   x4, #0x1a000
0x121b0: adrp   x7, #0x1a000
0x121b4: str    w20, [sp, #8]
0x121b8: mov    w1, wzr
0x121bc: str    x19, [sp]
0x121c0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x121c4: add    x4, x4, #0x441 ; "co"
0x121c8: mov    w0, #0x51
0x121cc: add    x7, x7, #0x821 ; "eng"
0x121d0: add    x2, sp, #0x38
0x121d4: bl     #0x2378 ; <duss_log_print>
0x121d8: adrp   x4, #0x1a000
0x121dc: adrp   x5, #0x1c000
0x121e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x121e4: add    x5, x5, #0xebe ; "_destroy_buffer_allocator"
0x121e8: mov    w0, #0x51
0x121ec: mov    w6, #0x3ec
0x121f0: b      #0x12088
0x121f4: udf    #0
0x121f8: sub    sp, sp, #0xf0
0x121fc: stp    x22, x21, [sp, #0xc0]
0x12200: stp    x20, x19, [sp, #0xd0]
0x12204: stp    x29, x30, [sp, #0xe0]
0x12208: add    x29, sp, #0xe0
0x1220c: mrs    x21, tpidr_el0
0x12210: mov    x19, x0
0x12214: ldr    x8, [x21, #0x28]
0x12218: add    x22, sp, #0x18
0x1221c: str    x8, [x22]
0x12220: cbz    x19, #0x1246c
0x12224: cbz    x1, #0x124d0
0x12228: ldr    x20, [x1]
0x1222c: cbz    x20, #0x12534
0x12230: ldr    x8, [x1, #8]
0x12234: str    x8, [sp, #0x30]
0x12238: cbz    x8, #0x12598
0x1223c: ldr    x0, [x19, #0x3f8]
0x12240: cbz    x0, #0x125fc
0x12244: add    x1, sp, #0x30
0x12248: bl     #0x2588 ; <buffer_queue_enqueue>
0x1224c: add    x0, x19, #0x468 ; "urce_package/filter/recording/platform/eagle2/venc_eng/proresraw/proresraw_venc_eng.c"
0x12250: bl     #0x27a8 ; <cam_thread_dtime_update>
0x12254: ldr    x8, [x19, #0x450]
0x12258: cbz    x8, #0x12444
0x1225c: adrp   x0, #0x30000
0x12260: adrp   x2, #0x1a000
0x12264: add    x0, x0, #8 ; =0x30008
0x12268: mov    w1, #5
0x1226c: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x12270: bl     #0x2338 ; <log_mgr_check>
0x12274: tbz    w0, #0, #0x12348
0x12278: bl     #0x2348 ; <co_thread_get>
0x1227c: cbz    x0, #0x122fc
0x12280: adrp   x8, #0x1a000
0x12284: str    wzr, [sp, #0x24]
0x12288: add    x8, x8, #0x440 ; =0x1a440
0x1228c: add    x1, sp, #0x28
0x12290: add    x2, sp, #0x24
0x12294: str    x8, [sp, #0x28]
0x12298: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1229c: adrp   x4, #0x1a000
0x122a0: adrp   x5, #0x1d000
0x122a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x122a8: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x122ac: mov    w0, #0x51
0x122b0: mov    w6, #0x557
0x122b4: mov    w1, #3
0x122b8: add    x2, sp, #0x38
0x122bc: mov    w3, #0x80
0x122c0: bl     #0x2368 ; <duss_log_gen_head>
0x122c4: cbz    w0, #0x12348
0x122c8: ldr    x6, [sp, #0x28]
0x122cc: adrp   x3, #0x1d000
0x122d0: ldr    w7, [sp, #0x24]
0x122d4: adrp   x4, #0x1a000
0x122d8: adrp   x5, #0x1a000
0x122dc: add    x3, x3, #0x460 ; "%s: %s(%s_%x): before on_frame_buffer_return
"
0x122e0: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x122e4: add    x5, x5, #0x441 ; "co"
0x122e8: mov    w0, #0x51
0x122ec: mov    w1, #3
0x122f0: add    x2, sp, #0x38
0x122f4: bl     #0x2378 ; <duss_log_print>
0x122f8: b      #0x12348
0x122fc: adrp   x4, #0x1a000
0x12300: adrp   x5, #0x1d000
0x12304: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12308: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x1230c: mov    w0, #0x51
0x12310: mov    w6, #0x557
0x12314: mov    w1, #3
0x12318: add    x2, sp, #0x38
0x1231c: mov    w3, #0x80
0x12320: bl     #0x2368 ; <duss_log_gen_head>
0x12324: cbz    w0, #0x12348
0x12328: adrp   x3, #0x1d000
0x1232c: adrp   x4, #0x1a000
0x12330: add    x3, x3, #0x48e ; "%s: before on_frame_buffer_return
"
0x12334: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x12338: mov    w0, #0x51
0x1233c: mov    w1, #3
0x12340: add    x2, sp, #0x38
0x12344: bl     #0x2378 ; <duss_log_print>
0x12348: ldr    x8, [x19, #0x450]
0x1234c: mov    x1, x20
0x12350: ldr    x0, [x19, #0x440]
0x12354: blr    x8
0x12358: adrp   x0, #0x30000
0x1235c: adrp   x2, #0x1a000
0x12360: add    x0, x0, #8 ; =0x30008
0x12364: mov    w1, #5
0x12368: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x1236c: bl     #0x2338 ; <log_mgr_check>
0x12370: tbz    w0, #0, #0x12444
0x12374: bl     #0x2348 ; <co_thread_get>
0x12378: cbz    x0, #0x123f8
0x1237c: adrp   x8, #0x1a000
0x12380: str    wzr, [sp, #0x24]
0x12384: add    x8, x8, #0x440 ; =0x1a440
0x12388: add    x1, sp, #0x28
0x1238c: add    x2, sp, #0x24
0x12390: str    x8, [sp, #0x28]
0x12394: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12398: adrp   x4, #0x1a000
0x1239c: adrp   x5, #0x1d000
0x123a0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x123a4: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x123a8: mov    w0, #0x51
0x123ac: mov    w6, #0x559
0x123b0: mov    w1, #3
0x123b4: add    x2, sp, #0x38
0x123b8: mov    w3, #0x80
0x123bc: bl     #0x2368 ; <duss_log_gen_head>
0x123c0: cbz    w0, #0x12444
0x123c4: ldr    x6, [sp, #0x28]
0x123c8: adrp   x3, #0x1d000
0x123cc: ldr    w7, [sp, #0x24]
0x123d0: adrp   x4, #0x1a000
0x123d4: adrp   x5, #0x1a000
0x123d8: add    x3, x3, #0x4b1 ; "%s: %s(%s_%x): after on_frame_buffer_return
"
0x123dc: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x123e0: add    x5, x5, #0x441 ; "co"
0x123e4: mov    w0, #0x51
0x123e8: mov    w1, #3
0x123ec: add    x2, sp, #0x38
0x123f0: bl     #0x2378 ; <duss_log_print>
0x123f4: b      #0x12444
0x123f8: adrp   x4, #0x1a000
0x123fc: adrp   x5, #0x1d000
0x12400: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12404: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12408: mov    w0, #0x51
0x1240c: mov    w6, #0x559
0x12410: mov    w1, #3
0x12414: add    x2, sp, #0x38
0x12418: mov    w3, #0x80
0x1241c: bl     #0x2368 ; <duss_log_gen_head>
0x12420: cbz    w0, #0x12444
0x12424: adrp   x3, #0x1d000
0x12428: adrp   x4, #0x1a000
0x1242c: add    x3, x3, #0x4de ; "%s: after on_frame_buffer_return
"
0x12430: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x12434: mov    w0, #0x51
0x12438: mov    w1, #3
0x1243c: add    x2, sp, #0x38
0x12440: bl     #0x2378 ; <duss_log_print>
0x12444: ldr    x8, [x21, #0x28]
0x12448: ldr    x9, [x22]
0x1244c: cmp    x8, x9
0x12450: b.ne   #0x12660
0x12454: ldp    x29, x30, [sp, #0xe0]
0x12458: ldp    x20, x19, [sp, #0xd0]
0x1245c: ldp    x22, x21, [sp, #0xc0]
0x12460: mov    w0, wzr
0x12464: add    sp, sp, #0xf0
0x12468: ret    
0x1246c: bl     #0x2348 ; <co_thread_get>
0x12470: cbnz   x0, #0x12664
0x12474: adrp   x4, #0x1a000
0x12478: adrp   x5, #0x1d000
0x1247c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12480: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12484: mov    w0, #0x51
0x12488: mov    w6, #0x54a
0x1248c: add    x2, sp, #0x38
0x12490: mov    w3, #0x80
0x12494: mov    w1, wzr
0x12498: bl     #0x2368 ; <duss_log_gen_head>
0x1249c: cbz    w0, #0x126ec
0x124a0: adrp   x3, #0x1a000
0x124a4: adrp   x4, #0x1a000
0x124a8: adrp   x5, #0x1a000
0x124ac: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x124b0: add    x4, x4, #0x821 ; "eng"
0x124b4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x124b8: mov    w0, #0x51
0x124bc: mov    w6, #0x54a
0x124c0: add    x2, sp, #0x38
0x124c4: mov    w1, wzr
0x124c8: bl     #0x2378 ; <duss_log_print>
0x124cc: b      #0x126ec
0x124d0: bl     #0x2348 ; <co_thread_get>
0x124d4: cbnz   x0, #0x12708
0x124d8: adrp   x4, #0x1a000
0x124dc: adrp   x5, #0x1d000
0x124e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x124e4: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x124e8: mov    w0, #0x51
0x124ec: mov    w6, #0x54b
0x124f0: add    x2, sp, #0x38
0x124f4: mov    w3, #0x80
0x124f8: mov    w1, wzr
0x124fc: bl     #0x2368 ; <duss_log_gen_head>
0x12500: cbz    w0, #0x12790
0x12504: adrp   x3, #0x1a000
0x12508: adrp   x4, #0x1a000
0x1250c: adrp   x5, #0x1a000
0x12510: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x12514: add    x4, x4, #0x81b ; "param"
0x12518: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1251c: mov    w0, #0x51
0x12520: mov    w6, #0x54b
0x12524: add    x2, sp, #0x38
0x12528: mov    w1, wzr
0x1252c: bl     #0x2378 ; <duss_log_print>
0x12530: b      #0x12790
0x12534: bl     #0x2348 ; <co_thread_get>
0x12538: cbnz   x0, #0x127ac
0x1253c: adrp   x4, #0x1a000
0x12540: adrp   x5, #0x1d000
0x12544: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12548: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x1254c: mov    w0, #0x51
0x12550: mov    w6, #0x54d
0x12554: add    x2, sp, #0x38
0x12558: mov    w3, #0x80
0x1255c: mov    w1, wzr
0x12560: bl     #0x2368 ; <duss_log_gen_head>
0x12564: cbz    w0, #0x12834
0x12568: adrp   x3, #0x1a000
0x1256c: adrp   x4, #0x1d000
0x12570: adrp   x5, #0x1a000
0x12574: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x12578: add    x4, x4, #0x453 ; "frame_buffer"
0x1257c: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12580: mov    w0, #0x51
0x12584: mov    w6, #0x54d
0x12588: add    x2, sp, #0x38
0x1258c: mov    w1, wzr
0x12590: bl     #0x2378 ; <duss_log_print>
0x12594: b      #0x12834
0x12598: bl     #0x2348 ; <co_thread_get>
0x1259c: cbnz   x0, #0x12850
0x125a0: adrp   x4, #0x1a000
0x125a4: adrp   x5, #0x1d000
0x125a8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x125ac: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x125b0: mov    w0, #0x51
0x125b4: mov    w6, #0x54f
0x125b8: add    x2, sp, #0x38
0x125bc: mov    w3, #0x80
0x125c0: mov    w1, wzr
0x125c4: bl     #0x2368 ; <duss_log_gen_head>
0x125c8: cbz    w0, #0x128d8
0x125cc: adrp   x3, #0x1a000
0x125d0: adrp   x4, #0x1b000
0x125d4: adrp   x5, #0x1a000
0x125d8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x125dc: add    x4, x4, #0x490 ; "ics_buffer"
0x125e0: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x125e4: mov    w0, #0x51
0x125e8: mov    w6, #0x54f
0x125ec: add    x2, sp, #0x38
0x125f0: mov    w1, wzr
0x125f4: bl     #0x2378 ; <duss_log_print>
0x125f8: b      #0x128d8
0x125fc: bl     #0x2348 ; <co_thread_get>
0x12600: cbnz   x0, #0x128f4
0x12604: adrp   x4, #0x1a000
0x12608: adrp   x5, #0x1d000
0x1260c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12610: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12614: mov    w0, #0x51
0x12618: mov    w6, #0x550
0x1261c: add    x2, sp, #0x38
0x12620: mov    w3, #0x80
0x12624: mov    w1, wzr
0x12628: bl     #0x2368 ; <duss_log_gen_head>
0x1262c: cbz    w0, #0x1297c
0x12630: adrp   x3, #0x1a000
0x12634: adrp   x4, #0x1c000
0x12638: adrp   x5, #0x1a000
0x1263c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x12640: add    x4, x4, #0x90b ; "eng->ics_buffer_pool"
0x12644: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12648: mov    w0, #0x51
0x1264c: mov    w6, #0x550
0x12650: add    x2, sp, #0x38
0x12654: mov    w1, wzr
0x12658: bl     #0x2378 ; <duss_log_print>
0x1265c: b      #0x1297c
0x12660: bl     #0x23d8 ; <__stack_chk_fail>
0x12664: adrp   x8, #0x1a000
0x12668: str    wzr, [sp, #0x28]
0x1266c: add    x8, x8, #0x440 ; =0x1a440
0x12670: add    x1, sp, #0x30
0x12674: add    x2, sp, #0x28
0x12678: str    x8, [sp, #0x30]
0x1267c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12680: adrp   x19, #0x1a000
0x12684: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12688: adrp   x5, #0x1d000
0x1268c: mov    w20, #0x54a
0x12690: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12694: mov    w0, #0x51
0x12698: add    x2, sp, #0x38
0x1269c: mov    w3, #0x80
0x126a0: mov    w1, wzr
0x126a4: mov    x4, x19
0x126a8: mov    w6, w20
0x126ac: bl     #0x2368 ; <duss_log_gen_head>
0x126b0: cbz    w0, #0x126ec
0x126b4: ldr    x5, [sp, #0x30]
0x126b8: adrp   x3, #0x1a000
0x126bc: ldr    w6, [sp, #0x28]
0x126c0: adrp   x4, #0x1a000
0x126c4: adrp   x7, #0x1a000
0x126c8: str    w20, [sp, #8]
0x126cc: mov    w1, wzr
0x126d0: str    x19, [sp]
0x126d4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x126d8: add    x4, x4, #0x441 ; "co"
0x126dc: mov    w0, #0x51
0x126e0: add    x7, x7, #0x821 ; "eng"
0x126e4: add    x2, sp, #0x38
0x126e8: bl     #0x2378 ; <duss_log_print>
0x126ec: adrp   x4, #0x1a000
0x126f0: adrp   x5, #0x1d000
0x126f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x126f8: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x126fc: mov    w0, #0x51
0x12700: mov    w6, #0x54a
0x12704: b      #0x12994
0x12708: adrp   x8, #0x1a000
0x1270c: str    wzr, [sp, #0x28]
0x12710: add    x8, x8, #0x440 ; =0x1a440
0x12714: add    x1, sp, #0x30
0x12718: add    x2, sp, #0x28
0x1271c: str    x8, [sp, #0x30]
0x12720: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12724: adrp   x19, #0x1a000
0x12728: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1272c: adrp   x5, #0x1d000
0x12730: mov    w20, #0x54b
0x12734: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12738: mov    w0, #0x51
0x1273c: add    x2, sp, #0x38
0x12740: mov    w3, #0x80
0x12744: mov    w1, wzr
0x12748: mov    x4, x19
0x1274c: mov    w6, w20
0x12750: bl     #0x2368 ; <duss_log_gen_head>
0x12754: cbz    w0, #0x12790
0x12758: ldr    x5, [sp, #0x30]
0x1275c: adrp   x3, #0x1a000
0x12760: ldr    w6, [sp, #0x28]
0x12764: adrp   x4, #0x1a000
0x12768: adrp   x7, #0x1a000
0x1276c: str    w20, [sp, #8]
0x12770: mov    w1, wzr
0x12774: str    x19, [sp]
0x12778: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x1277c: add    x4, x4, #0x441 ; "co"
0x12780: mov    w0, #0x51
0x12784: add    x7, x7, #0x81b ; "param"
0x12788: add    x2, sp, #0x38
0x1278c: bl     #0x2378 ; <duss_log_print>
0x12790: adrp   x4, #0x1a000
0x12794: adrp   x5, #0x1d000
0x12798: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1279c: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x127a0: mov    w0, #0x51
0x127a4: mov    w6, #0x54b
0x127a8: b      #0x12994
0x127ac: adrp   x8, #0x1a000
0x127b0: str    wzr, [sp, #0x28]
0x127b4: add    x8, x8, #0x440 ; =0x1a440
0x127b8: add    x1, sp, #0x30
0x127bc: add    x2, sp, #0x28
0x127c0: str    x8, [sp, #0x30]
0x127c4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x127c8: adrp   x19, #0x1a000
0x127cc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x127d0: adrp   x5, #0x1d000
0x127d4: mov    w20, #0x54d
0x127d8: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x127dc: mov    w0, #0x51
0x127e0: add    x2, sp, #0x38
0x127e4: mov    w3, #0x80
0x127e8: mov    w1, wzr
0x127ec: mov    x4, x19
0x127f0: mov    w6, w20
0x127f4: bl     #0x2368 ; <duss_log_gen_head>
0x127f8: cbz    w0, #0x12834
0x127fc: ldr    x5, [sp, #0x30]
0x12800: adrp   x3, #0x1a000
0x12804: ldr    w6, [sp, #0x28]
0x12808: adrp   x4, #0x1a000
0x1280c: adrp   x7, #0x1d000
0x12810: str    w20, [sp, #8]
0x12814: mov    w1, wzr
0x12818: str    x19, [sp]
0x1281c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x12820: add    x4, x4, #0x441 ; "co"
0x12824: mov    w0, #0x51
0x12828: add    x7, x7, #0x453 ; "frame_buffer"
0x1282c: add    x2, sp, #0x38
0x12830: bl     #0x2378 ; <duss_log_print>
0x12834: adrp   x4, #0x1a000
0x12838: adrp   x5, #0x1d000
0x1283c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12840: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12844: mov    w0, #0x51
0x12848: mov    w6, #0x54d
0x1284c: b      #0x12994
0x12850: adrp   x8, #0x1a000
0x12854: str    wzr, [sp, #0x24]
0x12858: add    x8, x8, #0x440 ; =0x1a440
0x1285c: add    x1, sp, #0x28
0x12860: add    x2, sp, #0x24
0x12864: str    x8, [sp, #0x28]
0x12868: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1286c: adrp   x19, #0x1a000
0x12870: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12874: adrp   x5, #0x1d000
0x12878: mov    w20, #0x54f
0x1287c: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12880: mov    w0, #0x51
0x12884: add    x2, sp, #0x38
0x12888: mov    w3, #0x80
0x1288c: mov    w1, wzr
0x12890: mov    x4, x19
0x12894: mov    w6, w20
0x12898: bl     #0x2368 ; <duss_log_gen_head>
0x1289c: cbz    w0, #0x128d8
0x128a0: ldr    x5, [sp, #0x28]
0x128a4: adrp   x3, #0x1a000
0x128a8: ldr    w6, [sp, #0x24]
0x128ac: adrp   x4, #0x1a000
0x128b0: adrp   x7, #0x1b000
0x128b4: str    w20, [sp, #8]
0x128b8: mov    w1, wzr
0x128bc: str    x19, [sp]
0x128c0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x128c4: add    x4, x4, #0x441 ; "co"
0x128c8: mov    w0, #0x51
0x128cc: add    x7, x7, #0x490 ; "ics_buffer"
0x128d0: add    x2, sp, #0x38
0x128d4: bl     #0x2378 ; <duss_log_print>
0x128d8: adrp   x4, #0x1a000
0x128dc: adrp   x5, #0x1d000
0x128e0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x128e4: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x128e8: mov    w0, #0x51
0x128ec: mov    w6, #0x54f
0x128f0: b      #0x12994
0x128f4: adrp   x8, #0x1a000
0x128f8: str    wzr, [sp, #0x24]
0x128fc: add    x8, x8, #0x440 ; =0x1a440
0x12900: add    x1, sp, #0x28
0x12904: add    x2, sp, #0x24
0x12908: str    x8, [sp, #0x28]
0x1290c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12910: adrp   x19, #0x1a000
0x12914: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12918: adrp   x5, #0x1d000
0x1291c: mov    w20, #0x550
0x12920: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x12924: mov    w0, #0x51
0x12928: add    x2, sp, #0x38
0x1292c: mov    w3, #0x80
0x12930: mov    w1, wzr
0x12934: mov    x4, x19
0x12938: mov    w6, w20
0x1293c: bl     #0x2368 ; <duss_log_gen_head>
0x12940: cbz    w0, #0x1297c
0x12944: ldr    x5, [sp, #0x28]
0x12948: adrp   x3, #0x1a000
0x1294c: ldr    w6, [sp, #0x24]
0x12950: adrp   x4, #0x1a000
0x12954: adrp   x7, #0x1c000
0x12958: str    w20, [sp, #8]
0x1295c: mov    w1, wzr
0x12960: str    x19, [sp]
0x12964: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x12968: add    x4, x4, #0x441 ; "co"
0x1296c: mov    w0, #0x51
0x12970: add    x7, x7, #0x90b ; "eng->ics_buffer_pool"
0x12974: add    x2, sp, #0x38
0x12978: bl     #0x2378 ; <duss_log_print>
0x1297c: adrp   x4, #0x1a000
0x12980: adrp   x5, #0x1d000
0x12984: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12988: add    x5, x5, #0x436 ; "_frame_buffer_empty_callback"
0x1298c: mov    w0, #0x51
0x12990: mov    w6, #0x550
0x12994: add    x2, sp, #0x38
0x12998: mov    w3, #0x80
0x1299c: mov    w1, wzr
0x129a0: bl     #0x2368 ; <duss_log_gen_head>
0x129a4: cbz    w0, #0x129c0
0x129a8: adrp   x3, #0x1a000
0x129ac: add    x3, x3, #0x550 ; "Assertion Comment: "
0x129b0: mov    w0, #0x51
0x129b4: add    x2, sp, #0x38
0x129b8: mov    w1, wzr
0x129bc: bl     #0x2378 ; <duss_log_print>
0x129c0: adrp   x0, #0x1a000
0x129c4: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x129c8: bl     #0x23e8 ; <log_to_kmsg>
0x129cc: adrp   x0, #0x1a000
0x129d0: add    x0, x0, #0x57f ; "Camera:	"
0x129d4: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x129d8: bl     #0x2408 ; <is_running_in_cam_sil>
0x129dc: tbz    w0, #0, #0x129ec
0x129e0: mov    x0, xzr
0x129e4: bl     #0x2418 ; <fflush>
0x129e8: bl     #0x2428 ; <abort>
0x129ec: mov    w0, #1
0x129f0: bl     #0x2438 ; <exit>
0x129f4: udf    #0
0x129f8: stp    x28, x27, [sp, #-0x60]!
0x129fc: stp    x26, x25, [sp, #0x10]
0x12a00: stp    x24, x23, [sp, #0x20]
0x12a04: stp    x22, x21, [sp, #0x30]
0x12a08: stp    x20, x19, [sp, #0x40]
0x12a0c: stp    x29, x30, [sp, #0x50]
0x12a10: add    x29, sp, #0x50
0x12a14: sub    sp, sp, #0x220
0x12a18: mrs    x23, tpidr_el0
0x12a1c: mov    x19, x1
0x12a20: ldr    x8, [x23, #0x28]
0x12a24: add    x24, sp, #0x70
0x12a28: mov    x25, x0
0x12a2c: mov    w2, #0x48
0x12a30: add    x0, sp, #0x98
0x12a34: mov    w1, wzr
0x12a38: str    x8, [x24]
0x12a3c: str    xzr, [sp, #0x80]
0x12a40: bl     #0x22d8 ; <memset>
0x12a44: cbz    x25, #0x13764
0x12a48: cbz    x19, #0x137c8
0x12a4c: ldr    x22, [x19, #8]
0x12a50: cbz    x22, #0x1382c
0x12a54: ldr    w8, [x19]
0x12a58: ldr    x21, [x19, #0x10]
0x12a5c: cbz    w8, #0x12ce0
0x12a60: mov    w2, #0xb8
0x12a64: add    x0, sp, #0x160
0x12a68: mov    w1, wzr
0x12a6c: add    x20, sp, #0x160
0x12a70: bl     #0x22d8 ; <memset>
0x12a74: adrp   x3, #0x1d000
0x12a78: adrp   x4, #0x1d000
0x12a7c: add    x3, x3, #0x8bc ; "%s"
0x12a80: add    x4, x4, #0x89e ; "bad_frame"
0x12a84: add    x0, sp, #0x160
0x12a88: mov    w1, #0x20
0x12a8c: mov    w2, #0x20
0x12a90: bl     #0xe788
0x12a94: mov    w19, w0
0x12a98: cmp    w19, #0x20
0x12a9c: b.hs   #0x13894
0x12aa0: adrp   x3, #0x1d000
0x12aa4: adrp   x4, #0x1d000
0x12aa8: add    x0, x20, #0x20 ; "#"
0x12aac: add    x3, x3, #0x8bc ; "%s"
0x12ab0: add    x4, x4, #0x8a8 ; "proresraw bad frame"
0x12ab4: mov    w1, #0x80
0x12ab8: mov    w2, #0x80
0x12abc: bl     #0xe788
0x12ac0: mov    w19, w0
0x12ac4: cmp    w19, #0x80
0x12ac8: b.hs   #0x138f8
0x12acc: mov    w9, #0x4604
0x12ad0: mov    w8, #1
0x12ad4: movk   w9, #0x3c0, lsl #16
0x12ad8: add    x0, sp, #0x160
0x12adc: strb   w8, [sp, #0x204]
0x12ae0: str    w9, [sp, #0x200]
0x12ae4: bl     #0x2498 ; <cam_ecg_report_status>
0x12ae8: cbz    w0, #0x12ce0
0x12aec: adrp   x0, #0x30000
0x12af0: adrp   x2, #0x1a000
0x12af4: add    x0, x0, #8 ; =0x30008
0x12af8: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x12afc: mov    w1, #1
0x12b00: bl     #0x2338 ; <log_mgr_check>
0x12b04: tbz    w0, #0, #0x12ce0
0x12b08: bl     #0x2348 ; <co_thread_get>
0x12b0c: cbz    x0, #0x12c44
0x12b10: adrp   x8, #0x1a000
0x12b14: str    wzr, [sp, #0x8c]
0x12b18: add    x8, x8, #0x440 ; =0x1a440
0x12b1c: add    x1, sp, #0x90
0x12b20: add    x2, sp, #0x8c
0x12b24: str    x8, [sp, #0x90]
0x12b28: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12b2c: adrp   x4, #0x1a000
0x12b30: adrp   x5, #0x1d000
0x12b34: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12b38: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x12b3c: mov    w0, #0x51
0x12b40: mov    w6, #0x4c5
0x12b44: mov    w1, #1
0x12b48: add    x2, sp, #0xe0
0x12b4c: mov    w3, #0x80
0x12b50: bl     #0x2368 ; <duss_log_gen_head>
0x12b54: cbz    w0, #0x12b7c
0x12b58: adrp   x3, #0x1a000
0x12b5c: adrp   x4, #0x1a000
0x12b60: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x12b64: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12b68: mov    w0, #0x51
0x12b6c: mov    w5, #0x4c5
0x12b70: mov    w1, #1
0x12b74: add    x2, sp, #0xe0
0x12b78: bl     #0x2378 ; <duss_log_print>
0x12b7c: adrp   x4, #0x1a000
0x12b80: adrp   x5, #0x1d000
0x12b84: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12b88: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x12b8c: mov    w0, #0x51
0x12b90: mov    w6, #0x4c5
0x12b94: mov    w1, #1
0x12b98: add    x2, sp, #0xe0
0x12b9c: mov    w3, #0x80
0x12ba0: bl     #0x2368 ; <duss_log_gen_head>
0x12ba4: cbz    w0, #0x12ce0
0x12ba8: ldr    x6, [sp, #0x90]
0x12bac: adrp   x3, #0x1d000
0x12bb0: ldr    w7, [sp, #0x8c]
0x12bb4: adrp   x4, #0x1a000
0x12bb8: adrp   x5, #0x1a000
0x12bbc: add    x3, x3, #0x976 ; "%s: %s(%s_%x): ecg report status failed
"
0x12bc0: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x12bc4: add    x5, x5, #0x441 ; "co"
0x12bc8: mov    w0, #0x51
0x12bcc: mov    w1, #1
0x12bd0: add    x2, sp, #0xe0
0x12bd4: bl     #0x2378 ; <duss_log_print>
0x12bd8: ldr    x0, [x25, #0x430]
0x12bdc: cbnz   x0, #0x12ce8
0x12be0: bl     #0x2348 ; <co_thread_get>
0x12be4: cbnz   x0, #0x1395c
0x12be8: adrp   x4, #0x1a000
0x12bec: adrp   x5, #0x1d000
0x12bf0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12bf4: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x12bf8: mov    w0, #0x51
0x12bfc: mov    w6, #0x4e9
0x12c00: add    x2, sp, #0x160
0x12c04: mov    w3, #0x80
0x12c08: mov    w1, wzr
0x12c0c: bl     #0x2368 ; <duss_log_gen_head>
0x12c10: cbz    w0, #0x139e4
0x12c14: adrp   x3, #0x1a000
0x12c18: adrp   x4, #0x1a000
0x12c1c: adrp   x5, #0x1a000
0x12c20: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x12c24: add    x4, x4, #0xff7 ; "eng->encoding_request_q"
0x12c28: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12c2c: mov    w0, #0x51
0x12c30: mov    w6, #0x4e9
0x12c34: add    x2, sp, #0x160
0x12c38: mov    w1, wzr
0x12c3c: bl     #0x2378 ; <duss_log_print>
0x12c40: b      #0x139e4
0x12c44: adrp   x4, #0x1a000
0x12c48: adrp   x5, #0x1d000
0x12c4c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12c50: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x12c54: mov    w0, #0x51
0x12c58: mov    w6, #0x4c5
0x12c5c: mov    w1, #1
0x12c60: add    x2, sp, #0xe0
0x12c64: mov    w3, #0x80
0x12c68: bl     #0x2368 ; <duss_log_gen_head>
0x12c6c: cbz    w0, #0x12c94
0x12c70: adrp   x3, #0x1a000
0x12c74: adrp   x4, #0x1a000
0x12c78: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x12c7c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12c80: mov    w0, #0x51
0x12c84: mov    w5, #0x4c5
0x12c88: mov    w1, #1
0x12c8c: add    x2, sp, #0xe0
0x12c90: bl     #0x2378 ; <duss_log_print>
0x12c94: adrp   x4, #0x1a000
0x12c98: adrp   x5, #0x1d000
0x12c9c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12ca0: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x12ca4: mov    w0, #0x51
0x12ca8: mov    w6, #0x4c5
0x12cac: mov    w1, #1
0x12cb0: add    x2, sp, #0xe0
0x12cb4: mov    w3, #0x80
0x12cb8: bl     #0x2368 ; <duss_log_gen_head>
0x12cbc: cbz    w0, #0x12ce0
0x12cc0: adrp   x3, #0x1d000
0x12cc4: adrp   x4, #0x1a000
0x12cc8: add    x3, x3, #0x99f ; "%s: ecg report status failed
"
0x12ccc: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x12cd0: mov    w0, #0x51
0x12cd4: mov    w1, #1
0x12cd8: add    x2, sp, #0xe0
0x12cdc: bl     #0x2378 ; <duss_log_print>
0x12ce0: ldr    x0, [x25, #0x430]
0x12ce4: cbz    x0, #0x12be0
0x12ce8: add    x1, sp, #0x80
0x12cec: bl     #0x2508 ; <buffer_queue_dequeue>
0x12cf0: mov    w20, w0
0x12cf4: cbz    w20, #0x12dec
0x12cf8: adrp   x0, #0x30000
0x12cfc: adrp   x2, #0x1a000
0x12d00: add    x0, x0, #8 ; =0x30008
0x12d04: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x12d08: mov    w1, #1
0x12d0c: bl     #0x2338 ; <log_mgr_check>
0x12d10: tbz    w0, #0, #0x131bc
0x12d14: bl     #0x2348 ; <co_thread_get>
0x12d18: cbz    x0, #0x1311c
0x12d1c: adrp   x8, #0x1a000
0x12d20: str    wzr, [sp, #0x90]
0x12d24: add    x8, x8, #0x440 ; =0x1a440
0x12d28: add    x1, sp, #0xe0
0x12d2c: add    x2, sp, #0x90
0x12d30: str    x8, [sp, #0xe0]
0x12d34: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12d38: adrp   x4, #0x1a000
0x12d3c: adrp   x5, #0x1d000
0x12d40: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12d44: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x12d48: mov    w0, #0x51
0x12d4c: mov    w6, #0x4ec
0x12d50: mov    w1, #1
0x12d54: add    x2, sp, #0x160
0x12d58: mov    w3, #0x80
0x12d5c: bl     #0x2368 ; <duss_log_gen_head>
0x12d60: cbz    w0, #0x12d88
0x12d64: adrp   x3, #0x1a000
0x12d68: adrp   x4, #0x1a000
0x12d6c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x12d70: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12d74: mov    w0, #0x51
0x12d78: mov    w5, #0x4ec
0x12d7c: mov    w1, #1
0x12d80: add    x2, sp, #0x160
0x12d84: bl     #0x2378 ; <duss_log_print>
0x12d88: adrp   x4, #0x1a000
0x12d8c: adrp   x5, #0x1d000
0x12d90: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12d94: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x12d98: mov    w0, #0x51
0x12d9c: mov    w6, #0x4ec
0x12da0: mov    w1, #1
0x12da4: add    x2, sp, #0x160
0x12da8: mov    w3, #0x80
0x12dac: bl     #0x2368 ; <duss_log_gen_head>
0x12db0: cbz    w0, #0x131bc
0x12db4: ldr    x6, [sp, #0xe0]
0x12db8: adrp   x3, #0x1d000
0x12dbc: ldr    w7, [sp, #0x90]
0x12dc0: adrp   x4, #0x1a000
0x12dc4: adrp   x5, #0x1a000
0x12dc8: str    w20, [sp]
0x12dcc: add    x3, x3, #0x533 ; "%s: %s(%s_%x): Failed to dequeue buffer_group with error %d
"
0x12dd0: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x12dd4: add    x5, x5, #0x441 ; "co"
0x12dd8: mov    w0, #0x51
0x12ddc: mov    w1, #1
0x12de0: add    x2, sp, #0x160
0x12de4: bl     #0x2378 ; <duss_log_print>
0x12de8: b      #0x131bc
0x12dec: ldr    x8, [sp, #0x80]
0x12df0: ldr    x20, [x8, #8]
0x12df4: cbz    x20, #0x13bec
0x12df8: ldr    w8, [x20, #0x20]
0x12dfc: cbz    w8, #0x13c50
0x12e00: ldr    x9, [x20, #0x50]
0x12e04: ldr    x10, [x9]
0x12e08: cbz    x10, #0x13cb4
0x12e0c: cmp    x10, x22
0x12e10: b.ne   #0x13d18
0x12e14: cmp    w8, #2
0x12e18: b.lo   #0x12e28
0x12e1c: ldr    x10, [x9, #8]
0x12e20: cmp    x10, x21
0x12e24: b.ne   #0x14138
0x12e28: adrp   x10, #0x1a000
0x12e2c: stp    x25, x23, [sp, #0x60]
0x12e30: cbz    x21, #0x12e58
0x12e34: ldr    w12, [x21, #0x3c]
0x12e38: ldr    d0, [x10, #0x1b0]
0x12e3c: ldp    w10, w11, [x21, #0x40]
0x12e40: str    d0, [x20, #0x28]
0x12e44: cmn    w12, w11
0x12e48: b.ne   #0x12e60
0x12e4c: cbnz   w10, #0x12e60
0x12e50: mov    w10, #-2
0x12e54: b      #0x12e64
0x12e58: ldr    d0, [x10, #0x1b0]
0x12e5c: str    d0, [x20, #0x28]
0x12e60: mov    w10, #-1
0x12e64: add    w8, w10, w8
0x12e68: str    w8, [x20, #0x3c]
0x12e6c: ldr    x19, [x9]
0x12e70: ldr    w8, [x19, #0x1b8]
0x12e74: cmp    w8, #1
0x12e78: b.ne   #0x13038
0x12e7c: adrp   x22, #0x30000
0x12e80: adrp   x23, #0x1a000
0x12e84: adrp   x24, #0x1a000
0x12e88: adrp   x25, #0x1d000
0x12e8c: mov    w21, wzr
0x12e90: add    x28, x19, #0x1b8 ; =0x1a1b8
0x12e94: add    x22, x22, #8 ; =0x30008
0x12e98: add    x23, x23, #0x5c4 ; "PRORESRAW"
0x12e9c: add    x24, x24, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x12ea0: add    x25, x25, #0x500 ; "_stream_buffer_full_callback"
0x12ea4: mov    w26, #0x51
0x12ea8: mov    w27, #0x514
0x12eac: ldr    x8, [x19]
0x12eb0: sbfx   x8, x8, #0, #0x17
0x12eb4: cmp    w8, #1
0x12eb8: b.ne   #0x1355c
0x12ebc: mov    w1, #4
0x12ec0: mov    x0, x22
0x12ec4: mov    x2, x23
0x12ec8: bl     #0x2338 ; <log_mgr_check>
0x12ecc: tbz    w0, #0, #0x13010
0x12ed0: bl     #0x2348 ; <co_thread_get>
0x12ed4: cbz    x0, #0x12f90
0x12ed8: adrp   x8, #0x1a000
0x12edc: str    wzr, [sp, #0x90]
0x12ee0: add    x8, x8, #0x440 ; =0x1a440
0x12ee4: add    x1, sp, #0xe0
0x12ee8: add    x2, sp, #0x90
0x12eec: str    x8, [sp, #0xe0]
0x12ef0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x12ef4: mov    w1, #4
0x12ef8: add    x2, sp, #0x160
0x12efc: mov    w3, #0x80
0x12f00: mov    w0, w26
0x12f04: mov    x4, x24
0x12f08: mov    x5, x25
0x12f0c: mov    w6, w27
0x12f10: bl     #0x2368 ; <duss_log_gen_head>
0x12f14: cbz    w0, #0x13010
0x12f18: ldr    w11, [x28]
0x12f1c: adrp   x3, #0x1d000
0x12f20: ldr    x6, [sp, #0xe0]
0x12f24: adrp   x5, #0x1a000
0x12f28: ldr    w7, [sp, #0x90]
0x12f2c: mov    w1, #4
0x12f30: ldr    w8, [x19, #0x28]
0x12f34: add    x2, sp, #0x160
0x12f38: ldp    w9, w10, [x19, #0x30]
0x12f3c: ldr    x12, [x19, #0x1c0]
0x12f40: mov    w0, w26
0x12f44: ldp    w13, w14, [x19, #0x38]
0x12f48: ldp    w15, w16, [x19, #0x40]
0x12f4c: add    x3, x3, #0x66c ; "%s: %s(%s_%x): stream_buffer[%i], pix_fmt:%d, w:%4d, h:%4d, plane_count:%d, timestamp:%8ld"
0x12f50: mov    x4, x23
0x12f54: str    w11, [sp, #0x20]
0x12f58: add    x5, x5, #0x441 ; "co"
0x12f5c: str    w15, [sp, #0x48]
0x12f60: mov    w11, #1
0x12f64: str    w16, [sp, #0x40]
0x12f68: str    w14, [sp, #0x38]
0x12f6c: str    w13, [sp, #0x30]
0x12f70: str    x12, [sp, #0x28]
0x12f74: str    w11, [sp, #0x50]
0x12f78: str    w10, [sp, #0x18]
0x12f7c: str    w9, [sp, #0x10]
0x12f80: str    w8, [sp, #8]
0x12f84: str    w21, [sp]
0x12f88: bl     #0x2378 ; <duss_log_print>
0x12f8c: b      #0x13010
0x12f90: mov    w1, #4
0x12f94: add    x2, sp, #0x160
0x12f98: mov    w3, #0x80
0x12f9c: mov    w0, w26
0x12fa0: mov    x4, x24
0x12fa4: mov    x5, x25
0x12fa8: mov    w6, w27
0x12fac: bl     #0x2368 ; <duss_log_gen_head>
0x12fb0: cbz    w0, #0x13010
0x12fb4: ldr    w9, [x28]
0x12fb8: adrp   x3, #0x1d000
0x12fbc: ldr    w6, [x19, #0x28]
0x12fc0: mov    w1, #4
0x12fc4: ldp    w7, w8, [x19, #0x30]
0x12fc8: ldr    x10, [x19, #0x1c0]
0x12fcc: add    x2, sp, #0x160
0x12fd0: ldp    w11, w12, [x19, #0x38]
0x12fd4: ldp    w13, w14, [x19, #0x40]
0x12fd8: mov    w0, w26
0x12fdc: add    x3, x3, #0x71c ; "%s: stream_buffer[%i], pix_fmt:%d, w:%4d, h:%4d, plane_count:%d, timestamp:%8ld, bytes_all"
0x12fe0: str    w9, [sp, #8]
0x12fe4: mov    x4, x23
0x12fe8: str    w13, [sp, #0x30]
0x12fec: mov    w5, w21
0x12ff0: str    w14, [sp, #0x28]
0x12ff4: mov    w9, #1
0x12ff8: str    w12, [sp, #0x20]
0x12ffc: str    w11, [sp, #0x18]
0x13000: str    x10, [sp, #0x10]
0x13004: str    w9, [sp, #0x38]
0x13008: str    w8, [sp]
0x1300c: bl     #0x2378 ; <duss_log_print>
0x13010: ldr    w8, [x20, #0x20]
0x13014: add    w21, w21, #1
0x13018: cmp    w21, w8
0x1301c: b.hs   #0x1309c
0x13020: ldr    x8, [x20, #0x50]
0x13024: ldr    x19, [x8, w21, uxtw #3]
0x13028: ldr    w8, [x19, #0x1b8]
0x1302c: add    x28, x19, #0x1b8 ; =0x1a1b8
0x13030: cmp    w8, #1
0x13034: b.eq   #0x12eac
0x13038: bl     #0x2348 ; <co_thread_get>
0x1303c: cbnz   x0, #0x13664
0x13040: adrp   x4, #0x1a000
0x13044: adrp   x5, #0x1d000
0x13048: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1304c: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13050: mov    w0, #0x51
0x13054: mov    w6, #0x50d
0x13058: add    x2, sp, #0x160
0x1305c: mov    w3, #0x80
0x13060: mov    w1, wzr
0x13064: bl     #0x2368 ; <duss_log_gen_head>
0x13068: cbz    w0, #0x136ec
0x1306c: adrp   x3, #0x1a000
0x13070: adrp   x4, #0x1b000
0x13074: adrp   x5, #0x1a000
0x13078: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1307c: add    x4, x4, #0x75e ; "sbuf->plane_count == 1"
0x13080: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13084: mov    w0, #0x51
0x13088: mov    w6, #0x50d
0x1308c: add    x2, sp, #0x160
0x13090: mov    w1, wzr
0x13094: bl     #0x2378 ; <duss_log_print>
0x13098: b      #0x136ec
0x1309c: ldr    x8, [sp, #0x80]
0x130a0: add    x2, sp, #0x7c
0x130a4: mov    x1, x20
0x130a8: ldr    x0, [x8]
0x130ac: bl     #0x2628 ; <cam_encoded_buffer_allocator_buffer_update>
0x130b0: ldp    x21, x23, [sp, #0x60]
0x130b4: ldrb   w8, [sp, #0x7c]
0x130b8: add    x24, sp, #0x70
0x130bc: ldrb   w9, [x21, #0x4a2]
0x130c0: cmp    w8, w9
0x130c4: b.eq   #0x132f0
0x130c8: mov    w2, #0xb8
0x130cc: add    x0, sp, #0x160
0x130d0: mov    w1, wzr
0x130d4: add    x19, sp, #0x160
0x130d8: bl     #0x22d8 ; <memset>
0x130dc: adrp   x3, #0x1a000
0x130e0: add    x3, x3, #0xdcc ; "write_speed"
0x130e4: add    x0, sp, #0x160
0x130e8: mov    w1, #0x20
0x130ec: mov    w2, #0x20
0x130f0: bl     #0xe788
0x130f4: ldrb   w8, [sp, #0x7c]
0x130f8: add    x0, x19, #0x20 ; "#"
0x130fc: cbz    w8, #0x131c4
0x13100: adrp   x3, #0x1d000
0x13104: add    x3, x3, #0x7c1 ; "write speed is slow because encoded ring buffer is low on memory"
0x13108: mov    w1, #0x80
0x1310c: mov    w2, #0x80
0x13110: bl     #0xe788
0x13114: mov    w8, wzr
0x13118: b      #0x131dc
0x1311c: adrp   x4, #0x1a000
0x13120: adrp   x5, #0x1d000
0x13124: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13128: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x1312c: mov    w0, #0x51
0x13130: mov    w6, #0x4ec
0x13134: mov    w1, #1
0x13138: add    x2, sp, #0x160
0x1313c: mov    w3, #0x80
0x13140: bl     #0x2368 ; <duss_log_gen_head>
0x13144: cbz    w0, #0x1316c
0x13148: adrp   x3, #0x1a000
0x1314c: adrp   x4, #0x1a000
0x13150: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x13154: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13158: mov    w0, #0x51
0x1315c: mov    w5, #0x4ec
0x13160: mov    w1, #1
0x13164: add    x2, sp, #0x160
0x13168: bl     #0x2378 ; <duss_log_print>
0x1316c: adrp   x4, #0x1a000
0x13170: adrp   x5, #0x1d000
0x13174: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13178: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x1317c: mov    w0, #0x51
0x13180: mov    w6, #0x4ec
0x13184: mov    w1, #1
0x13188: add    x2, sp, #0x160
0x1318c: mov    w3, #0x80
0x13190: bl     #0x2368 ; <duss_log_gen_head>
0x13194: cbz    w0, #0x131bc
0x13198: adrp   x3, #0x1d000
0x1319c: adrp   x4, #0x1a000
0x131a0: add    x3, x3, #0x570 ; "%s: Failed to dequeue buffer_group with error %d
"
0x131a4: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x131a8: mov    w0, #0x51
0x131ac: mov    w1, #1
0x131b0: add    x2, sp, #0x160
0x131b4: mov    w5, w20
0x131b8: bl     #0x2378 ; <duss_log_print>
0x131bc: mov    w0, #-0x3ec
0x131c0: b      #0x1352c
0x131c4: adrp   x3, #0x1a000
0x131c8: add    x3, x3, #0xdd8 ; "write speed is normal"
0x131cc: mov    w1, #0x80
0x131d0: mov    w2, #0x80
0x131d4: bl     #0xe788
0x131d8: mov    w8, #1
0x131dc: mov    w9, #0x2501
0x131e0: strb   w8, [sp, #0x205]
0x131e4: movk   w9, #0x3c0, lsl #16
0x131e8: strb   wzr, [sp, #0x204]
0x131ec: add    x0, sp, #0x160
0x131f0: str    w9, [sp, #0x200]
0x131f4: bl     #0x2498 ; <cam_ecg_report_status>
0x131f8: cbz    w0, #0x132e8
0x131fc: adrp   x0, #0x30000
0x13200: adrp   x2, #0x1a000
0x13204: add    x0, x0, #8 ; =0x30008
0x13208: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x1320c: mov    w1, #2
0x13210: bl     #0x2338 ; <log_mgr_check>
0x13214: tbz    w0, #0, #0x132e8
0x13218: bl     #0x2348 ; <co_thread_get>
0x1321c: cbz    x0, #0x1329c
0x13220: adrp   x8, #0x1a000
0x13224: str    wzr, [sp, #0x8c]
0x13228: add    x8, x8, #0x440 ; =0x1a440
0x1322c: add    x1, sp, #0x90
0x13230: add    x2, sp, #0x8c
0x13234: str    x8, [sp, #0x90]
0x13238: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1323c: adrp   x4, #0x1a000
0x13240: adrp   x5, #0x1d000
0x13244: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13248: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x1324c: mov    w0, #0x51
0x13250: mov    w6, #0x52a
0x13254: mov    w1, #2
0x13258: add    x2, sp, #0xe0
0x1325c: mov    w3, #0x80
0x13260: bl     #0x2368 ; <duss_log_gen_head>
0x13264: cbz    w0, #0x132e8
0x13268: ldr    x6, [sp, #0x90]
0x1326c: adrp   x3, #0x1a000
0x13270: ldr    w7, [sp, #0x8c]
0x13274: adrp   x4, #0x1a000
0x13278: adrp   x5, #0x1a000
0x1327c: add    x3, x3, #0xdee ; "%s: %s(%s_%x): ecg not init
"
0x13280: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x13284: add    x5, x5, #0x441 ; "co"
0x13288: mov    w0, #0x51
0x1328c: mov    w1, #2
0x13290: add    x2, sp, #0xe0
0x13294: bl     #0x2378 ; <duss_log_print>
0x13298: b      #0x132e8
0x1329c: adrp   x4, #0x1a000
0x132a0: adrp   x5, #0x1d000
0x132a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x132a8: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x132ac: mov    w0, #0x51
0x132b0: mov    w6, #0x52a
0x132b4: mov    w1, #2
0x132b8: add    x2, sp, #0xe0
0x132bc: mov    w3, #0x80
0x132c0: bl     #0x2368 ; <duss_log_gen_head>
0x132c4: cbz    w0, #0x132e8
0x132c8: adrp   x3, #0x1a000
0x132cc: adrp   x4, #0x1a000
0x132d0: add    x3, x3, #0xe0b ; "%s: ecg not init
"
0x132d4: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x132d8: mov    w0, #0x51
0x132dc: mov    w1, #2
0x132e0: add    x2, sp, #0xe0
0x132e4: bl     #0x2378 ; <duss_log_print>
0x132e8: ldrb   w8, [sp, #0x7c]
0x132ec: strb   w8, [x21, #0x4a2]
0x132f0: ldr    x0, [x21, #0x408]
0x132f4: ldr    x1, [sp, #0x80]
0x132f8: bl     #0x2588 ; <buffer_queue_enqueue>
0x132fc: ldr    x8, [sp, #0x80]
0x13300: add    x1, sp, #0x80
0x13304: str    xzr, [x8]
0x13308: ldr    x8, [sp, #0x80]
0x1330c: str    xzr, [x8, #8]
0x13310: ldr    x0, [x21, #0x420]
0x13314: bl     #0x2588 ; <buffer_queue_enqueue>
0x13318: ldr    x0, [x21, #0x488]
0x1331c: mov    w1, #1
0x13320: bl     #0x27b8 ; <duss_osal_event_set>
0x13324: ldr    x8, [x21, #0x448]
0x13328: cbz    x8, #0x13520
0x1332c: adrp   x0, #0x30000
0x13330: str    x20, [sp, #0x98]
0x13334: adrp   x2, #0x1a000
0x13338: str    wzr, [sp, #0xdc]
0x1333c: add    x0, x0, #8 ; =0x30008
0x13340: mov    w1, #5
0x13344: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x13348: bl     #0x2338 ; <log_mgr_check>
0x1334c: tbz    w0, #0, #0x13420
0x13350: bl     #0x2348 ; <co_thread_get>
0x13354: cbz    x0, #0x133d4
0x13358: adrp   x8, #0x1a000
0x1335c: str    wzr, [sp, #0x8c]
0x13360: add    x8, x8, #0x440 ; =0x1a440
0x13364: add    x1, sp, #0x90
0x13368: add    x2, sp, #0x8c
0x1336c: str    x8, [sp, #0x90]
0x13370: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13374: adrp   x4, #0x1a000
0x13378: adrp   x5, #0x1d000
0x1337c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13380: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13384: mov    w0, #0x51
0x13388: mov    w6, #0x538
0x1338c: mov    w1, #3
0x13390: add    x2, sp, #0xe0
0x13394: mov    w3, #0x80
0x13398: bl     #0x2368 ; <duss_log_gen_head>
0x1339c: cbz    w0, #0x13420
0x133a0: ldr    x6, [sp, #0x90]
0x133a4: adrp   x3, #0x1d000
0x133a8: ldr    w7, [sp, #0x8c]
0x133ac: adrp   x4, #0x1a000
0x133b0: adrp   x5, #0x1a000
0x133b4: add    x3, x3, #0x802 ; "%s: %s(%s_%x): before on_async_process_done
"
0x133b8: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x133bc: add    x5, x5, #0x441 ; "co"
0x133c0: mov    w0, #0x51
0x133c4: mov    w1, #3
0x133c8: add    x2, sp, #0xe0
0x133cc: bl     #0x2378 ; <duss_log_print>
0x133d0: b      #0x13420
0x133d4: adrp   x4, #0x1a000
0x133d8: adrp   x5, #0x1d000
0x133dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x133e0: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x133e4: mov    w0, #0x51
0x133e8: mov    w6, #0x538
0x133ec: mov    w1, #3
0x133f0: add    x2, sp, #0xe0
0x133f4: mov    w3, #0x80
0x133f8: bl     #0x2368 ; <duss_log_gen_head>
0x133fc: cbz    w0, #0x13420
0x13400: adrp   x3, #0x1d000
0x13404: adrp   x4, #0x1a000
0x13408: add    x3, x3, #0x82f ; "%s: before on_async_process_done
"
0x1340c: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x13410: mov    w0, #0x51
0x13414: mov    w1, #3
0x13418: add    x2, sp, #0xe0
0x1341c: bl     #0x2378 ; <duss_log_print>
0x13420: ldr    x8, [x21, #0x448]
0x13424: add    x1, sp, #0x98
0x13428: ldr    x0, [x21, #0x440]
0x1342c: mov    w2, #1
0x13430: blr    x8
0x13434: adrp   x0, #0x30000
0x13438: adrp   x2, #0x1a000
0x1343c: add    x0, x0, #8 ; =0x30008
0x13440: mov    w1, #5
0x13444: add    x2, x2, #0x5c4 ; "PRORESRAW"
0x13448: bl     #0x2338 ; <log_mgr_check>
0x1344c: tbz    w0, #0, #0x13520
0x13450: bl     #0x2348 ; <co_thread_get>
0x13454: cbz    x0, #0x134d4
0x13458: adrp   x8, #0x1a000
0x1345c: str    wzr, [sp, #0x8c]
0x13460: add    x8, x8, #0x440 ; =0x1a440
0x13464: add    x1, sp, #0x90
0x13468: add    x2, sp, #0x8c
0x1346c: str    x8, [sp, #0x90]
0x13470: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13474: adrp   x4, #0x1a000
0x13478: adrp   x5, #0x1d000
0x1347c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13480: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13484: mov    w0, #0x51
0x13488: mov    w6, #0x53a
0x1348c: mov    w1, #3
0x13490: add    x2, sp, #0xe0
0x13494: mov    w3, #0x80
0x13498: bl     #0x2368 ; <duss_log_gen_head>
0x1349c: cbz    w0, #0x13520
0x134a0: ldr    x6, [sp, #0x90]
0x134a4: adrp   x3, #0x1d000
0x134a8: ldr    w7, [sp, #0x8c]
0x134ac: adrp   x4, #0x1a000
0x134b0: adrp   x5, #0x1a000
0x134b4: add    x3, x3, #0x851 ; "%s: %s(%s_%x): after on_async_process_done
"
0x134b8: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x134bc: add    x5, x5, #0x441 ; "co"
0x134c0: mov    w0, #0x51
0x134c4: mov    w1, #3
0x134c8: add    x2, sp, #0xe0
0x134cc: bl     #0x2378 ; <duss_log_print>
0x134d0: b      #0x13520
0x134d4: adrp   x4, #0x1a000
0x134d8: adrp   x5, #0x1d000
0x134dc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x134e0: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x134e4: mov    w0, #0x51
0x134e8: mov    w6, #0x53a
0x134ec: mov    w1, #3
0x134f0: add    x2, sp, #0xe0
0x134f4: mov    w3, #0x80
0x134f8: bl     #0x2368 ; <duss_log_gen_head>
0x134fc: cbz    w0, #0x13520
0x13500: adrp   x3, #0x1d000
0x13504: adrp   x4, #0x1a000
0x13508: add    x3, x3, #0x87d ; "%s: after on_async_process_done
"
0x1350c: add    x4, x4, #0x5c4 ; "PRORESRAW"
0x13510: mov    w0, #0x51
0x13514: mov    w1, #3
0x13518: add    x2, sp, #0xe0
0x1351c: bl     #0x2378 ; <duss_log_print>
0x13520: mov    x0, x20
0x13524: bl     #0x2608 ; <stream_buffer_group_subref>
0x13528: mov    w0, wzr
0x1352c: ldr    x8, [x23, #0x28]
0x13530: ldr    x9, [x24]
0x13534: cmp    x8, x9
0x13538: b.ne   #0x13890
0x1353c: add    sp, sp, #0x220
0x13540: ldp    x29, x30, [sp, #0x50]
0x13544: ldp    x20, x19, [sp, #0x40]
0x13548: ldp    x22, x21, [sp, #0x30]
0x1354c: ldp    x24, x23, [sp, #0x20]
0x13550: ldp    x26, x25, [sp, #0x10]
0x13554: ldp    x28, x27, [sp], #0x60
0x13558: ret    
0x1355c: bl     #0x2348 ; <co_thread_get>
0x13560: cbnz   x0, #0x135c0
0x13564: adrp   x4, #0x1a000
0x13568: adrp   x5, #0x1d000
0x1356c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13570: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13574: mov    w0, #0x51
0x13578: mov    w6, #0x50e
0x1357c: add    x2, sp, #0x160
0x13580: mov    w3, #0x80
0x13584: mov    w1, wzr
0x13588: bl     #0x2368 ; <duss_log_gen_head>
0x1358c: cbz    w0, #0x13648
0x13590: adrp   x3, #0x1a000
0x13594: adrp   x4, #0x1b000
0x13598: adrp   x5, #0x1a000
0x1359c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x135a0: add    x4, x4, #0x775 ; "sbuf->obj.ref_count == 1"
0x135a4: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x135a8: mov    w0, #0x51
0x135ac: mov    w6, #0x50e
0x135b0: add    x2, sp, #0x160
0x135b4: mov    w1, wzr
0x135b8: bl     #0x2378 ; <duss_log_print>
0x135bc: b      #0x13648
0x135c0: adrp   x8, #0x1a000
0x135c4: str    wzr, [sp, #0x90]
0x135c8: add    x8, x8, #0x440 ; =0x1a440
0x135cc: add    x1, sp, #0xe0
0x135d0: add    x2, sp, #0x90
0x135d4: str    x8, [sp, #0xe0]
0x135d8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x135dc: adrp   x19, #0x1a000
0x135e0: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x135e4: adrp   x5, #0x1d000
0x135e8: mov    w20, #0x50e
0x135ec: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x135f0: mov    w0, #0x51
0x135f4: add    x2, sp, #0x160
0x135f8: mov    w3, #0x80
0x135fc: mov    w1, wzr
0x13600: mov    x4, x19
0x13604: mov    w6, w20
0x13608: bl     #0x2368 ; <duss_log_gen_head>
0x1360c: cbz    w0, #0x13648
0x13610: ldr    x5, [sp, #0xe0]
0x13614: adrp   x3, #0x1a000
0x13618: ldr    w6, [sp, #0x90]
0x1361c: adrp   x4, #0x1a000
0x13620: adrp   x7, #0x1b000
0x13624: str    w20, [sp, #8]
0x13628: mov    w1, wzr
0x1362c: str    x19, [sp]
0x13630: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13634: add    x4, x4, #0x441 ; "co"
0x13638: mov    w0, #0x51
0x1363c: add    x7, x7, #0x775 ; "sbuf->obj.ref_count == 1"
0x13640: add    x2, sp, #0x160
0x13644: bl     #0x2378 ; <duss_log_print>
0x13648: adrp   x4, #0x1a000
0x1364c: adrp   x5, #0x1d000
0x13650: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13654: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13658: mov    w0, #0x51
0x1365c: mov    w6, #0x50e
0x13660: b      #0x13704
0x13664: adrp   x8, #0x1a000
0x13668: str    wzr, [sp, #0x90]
0x1366c: add    x8, x8, #0x440 ; =0x1a440
0x13670: add    x1, sp, #0xe0
0x13674: add    x2, sp, #0x90
0x13678: str    x8, [sp, #0xe0]
0x1367c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13680: adrp   x19, #0x1a000
0x13684: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13688: adrp   x5, #0x1d000
0x1368c: mov    w20, #0x50d
0x13690: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13694: mov    w0, #0x51
0x13698: add    x2, sp, #0x160
0x1369c: mov    w3, #0x80
0x136a0: mov    w1, wzr
0x136a4: mov    x4, x19
0x136a8: mov    w6, w20
0x136ac: bl     #0x2368 ; <duss_log_gen_head>
0x136b0: cbz    w0, #0x136ec
0x136b4: ldr    x5, [sp, #0xe0]
0x136b8: adrp   x3, #0x1a000
0x136bc: ldr    w6, [sp, #0x90]
0x136c0: adrp   x4, #0x1a000
0x136c4: adrp   x7, #0x1b000
0x136c8: str    w20, [sp, #8]
0x136cc: mov    w1, wzr
0x136d0: str    x19, [sp]
0x136d4: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x136d8: add    x4, x4, #0x441 ; "co"
0x136dc: mov    w0, #0x51
0x136e0: add    x7, x7, #0x75e ; "sbuf->plane_count == 1"
0x136e4: add    x2, sp, #0x160
0x136e8: bl     #0x2378 ; <duss_log_print>
0x136ec: adrp   x4, #0x1a000
0x136f0: adrp   x5, #0x1d000
0x136f4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x136f8: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x136fc: mov    w0, #0x51
0x13700: mov    w6, #0x50d
0x13704: add    x2, sp, #0x160
0x13708: mov    w3, #0x80
0x1370c: mov    w1, wzr
0x13710: bl     #0x2368 ; <duss_log_gen_head>
0x13714: cbz    w0, #0x13730
0x13718: adrp   x3, #0x1a000
0x1371c: add    x3, x3, #0x550 ; "Assertion Comment: "
0x13720: mov    w0, #0x51
0x13724: add    x2, sp, #0x160
0x13728: mov    w1, wzr
0x1372c: bl     #0x2378 ; <duss_log_print>
0x13730: adrp   x0, #0x1a000
0x13734: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x13738: bl     #0x23e8 ; <log_to_kmsg>
0x1373c: adrp   x0, #0x1a000
0x13740: add    x0, x0, #0x57f ; "Camera:	"
0x13744: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x13748: bl     #0x2408 ; <is_running_in_cam_sil>
0x1374c: tbz    w0, #0, #0x1375c
0x13750: mov    x0, xzr
0x13754: bl     #0x2418 ; <fflush>
0x13758: bl     #0x2428 ; <abort>
0x1375c: mov    w0, #1
0x13760: bl     #0x2438 ; <exit>
0x13764: bl     #0x2348 ; <co_thread_get>
0x13768: cbnz   x0, #0x13a00
0x1376c: adrp   x4, #0x1a000
0x13770: adrp   x5, #0x1d000
0x13774: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13778: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x1377c: mov    w0, #0x51
0x13780: mov    w6, #0x4df
0x13784: add    x2, sp, #0x160
0x13788: mov    w3, #0x80
0x1378c: mov    w1, wzr
0x13790: bl     #0x2368 ; <duss_log_gen_head>
0x13794: cbz    w0, #0x13a88
0x13798: adrp   x3, #0x1a000
0x1379c: adrp   x4, #0x1a000
0x137a0: adrp   x5, #0x1a000
0x137a4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x137a8: add    x4, x4, #0x821 ; "eng"
0x137ac: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x137b0: mov    w0, #0x51
0x137b4: mov    w6, #0x4df
0x137b8: add    x2, sp, #0x160
0x137bc: mov    w1, wzr
0x137c0: bl     #0x2378 ; <duss_log_print>
0x137c4: b      #0x13a88
0x137c8: bl     #0x2348 ; <co_thread_get>
0x137cc: cbnz   x0, #0x13aa4
0x137d0: adrp   x4, #0x1a000
0x137d4: adrp   x5, #0x1d000
0x137d8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x137dc: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x137e0: mov    w0, #0x51
0x137e4: mov    w6, #0x4e0
0x137e8: add    x2, sp, #0x160
0x137ec: mov    w3, #0x80
0x137f0: mov    w1, wzr
0x137f4: bl     #0x2368 ; <duss_log_gen_head>
0x137f8: cbz    w0, #0x13b2c
0x137fc: adrp   x3, #0x1a000
0x13800: adrp   x4, #0x1a000
0x13804: adrp   x5, #0x1a000
0x13808: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1380c: add    x4, x4, #0x81b ; "param"
0x13810: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13814: mov    w0, #0x51
0x13818: mov    w6, #0x4e0
0x1381c: add    x2, sp, #0x160
0x13820: mov    w1, wzr
0x13824: bl     #0x2378 ; <duss_log_print>
0x13828: b      #0x13b2c
0x1382c: bl     #0x2348 ; <co_thread_get>
0x13830: cbnz   x0, #0x13b48
0x13834: adrp   x4, #0x1a000
0x13838: adrp   x5, #0x1d000
0x1383c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13840: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13844: mov    w0, #0x51
0x13848: mov    w6, #0x4e2
0x1384c: add    x2, sp, #0x160
0x13850: mov    w3, #0x80
0x13854: mov    w1, wzr
0x13858: bl     #0x2368 ; <duss_log_gen_head>
0x1385c: cbz    w0, #0x13bd0
0x13860: adrp   x3, #0x1a000
0x13864: adrp   x4, #0x1d000
0x13868: adrp   x5, #0x1a000
0x1386c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x13870: add    x4, x4, #0x51d ; "stream_buffer_primary"
0x13874: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13878: mov    w0, #0x51
0x1387c: mov    w6, #0x4e2
0x13880: add    x2, sp, #0x160
0x13884: mov    w1, wzr
0x13888: bl     #0x2378 ; <duss_log_print>
0x1388c: b      #0x13bd0
0x13890: bl     #0x23d8 ; <__stack_chk_fail>
0x13894: bl     #0x2348 ; <co_thread_get>
0x13898: cbnz   x0, #0x13d7c
0x1389c: adrp   x4, #0x1a000
0x138a0: adrp   x5, #0x1d000
0x138a4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x138a8: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x138ac: mov    w0, #0x51
0x138b0: mov    w6, #0x4c0
0x138b4: add    x2, sp, #0xe0
0x138b8: mov    w3, #0x80
0x138bc: mov    w1, wzr
0x138c0: bl     #0x2368 ; <duss_log_gen_head>
0x138c4: cbz    w0, #0x13e04
0x138c8: adrp   x3, #0x1a000
0x138cc: adrp   x4, #0x1d000
0x138d0: adrp   x5, #0x1a000
0x138d4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x138d8: add    x4, x4, #0x8de ; "ret >= 0 && ret < max_size"
0x138dc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x138e0: mov    w0, #0x51
0x138e4: mov    w6, #0x4c0
0x138e8: add    x2, sp, #0xe0
0x138ec: mov    w1, wzr
0x138f0: bl     #0x2378 ; <duss_log_print>
0x138f4: b      #0x13e04
0x138f8: bl     #0x2348 ; <co_thread_get>
0x138fc: cbnz   x0, #0x13e60
0x13900: adrp   x4, #0x1a000
0x13904: adrp   x5, #0x1d000
0x13908: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1390c: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x13910: mov    w0, #0x51
0x13914: mov    w6, #0x4c1
0x13918: add    x2, sp, #0xe0
0x1391c: mov    w3, #0x80
0x13920: mov    w1, wzr
0x13924: bl     #0x2368 ; <duss_log_gen_head>
0x13928: cbz    w0, #0x13ee8
0x1392c: adrp   x3, #0x1a000
0x13930: adrp   x4, #0x1d000
0x13934: adrp   x5, #0x1a000
0x13938: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1393c: add    x4, x4, #0x8de ; "ret >= 0 && ret < max_size"
0x13940: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13944: mov    w0, #0x51
0x13948: mov    w6, #0x4c1
0x1394c: add    x2, sp, #0xe0
0x13950: mov    w1, wzr
0x13954: bl     #0x2378 ; <duss_log_print>
0x13958: b      #0x13ee8
0x1395c: adrp   x8, #0x1a000
0x13960: str    wzr, [sp, #0x90]
0x13964: add    x8, x8, #0x440 ; =0x1a440
0x13968: add    x1, sp, #0xe0
0x1396c: add    x2, sp, #0x90
0x13970: str    x8, [sp, #0xe0]
0x13974: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13978: adrp   x19, #0x1a000
0x1397c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13980: adrp   x5, #0x1d000
0x13984: mov    w20, #0x4e9
0x13988: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x1398c: mov    w0, #0x51
0x13990: add    x2, sp, #0x160
0x13994: mov    w3, #0x80
0x13998: mov    w1, wzr
0x1399c: mov    x4, x19
0x139a0: mov    w6, w20
0x139a4: bl     #0x2368 ; <duss_log_gen_head>
0x139a8: cbz    w0, #0x139e4
0x139ac: ldr    x5, [sp, #0xe0]
0x139b0: adrp   x3, #0x1a000
0x139b4: ldr    w6, [sp, #0x90]
0x139b8: adrp   x4, #0x1a000
0x139bc: adrp   x7, #0x1a000
0x139c0: str    w20, [sp, #8]
0x139c4: mov    w1, wzr
0x139c8: str    x19, [sp]
0x139cc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x139d0: add    x4, x4, #0x441 ; "co"
0x139d4: mov    w0, #0x51
0x139d8: add    x7, x7, #0xff7 ; "eng->encoding_request_q"
0x139dc: add    x2, sp, #0x160
0x139e0: bl     #0x2378 ; <duss_log_print>
0x139e4: adrp   x4, #0x1a000
0x139e8: adrp   x5, #0x1d000
0x139ec: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x139f0: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x139f4: mov    w0, #0x51
0x139f8: mov    w6, #0x4e9
0x139fc: b      #0x13704
0x13a00: adrp   x8, #0x1a000
0x13a04: str    wzr, [sp, #0x90]
0x13a08: add    x8, x8, #0x440 ; =0x1a440
0x13a0c: add    x1, sp, #0xe0
0x13a10: add    x2, sp, #0x90
0x13a14: str    x8, [sp, #0xe0]
0x13a18: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13a1c: adrp   x19, #0x1a000
0x13a20: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13a24: adrp   x5, #0x1d000
0x13a28: mov    w20, #0x4df
0x13a2c: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13a30: mov    w0, #0x51
0x13a34: add    x2, sp, #0x160
0x13a38: mov    w3, #0x80
0x13a3c: mov    w1, wzr
0x13a40: mov    x4, x19
0x13a44: mov    w6, w20
0x13a48: bl     #0x2368 ; <duss_log_gen_head>
0x13a4c: cbz    w0, #0x13a88
0x13a50: ldr    x5, [sp, #0xe0]
0x13a54: adrp   x3, #0x1a000
0x13a58: ldr    w6, [sp, #0x90]
0x13a5c: adrp   x4, #0x1a000
0x13a60: adrp   x7, #0x1a000
0x13a64: str    w20, [sp, #8]
0x13a68: mov    w1, wzr
0x13a6c: str    x19, [sp]
0x13a70: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13a74: add    x4, x4, #0x441 ; "co"
0x13a78: mov    w0, #0x51
0x13a7c: add    x7, x7, #0x821 ; "eng"
0x13a80: add    x2, sp, #0x160
0x13a84: bl     #0x2378 ; <duss_log_print>
0x13a88: adrp   x4, #0x1a000
0x13a8c: adrp   x5, #0x1d000
0x13a90: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13a94: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13a98: mov    w0, #0x51
0x13a9c: mov    w6, #0x4df
0x13aa0: b      #0x13704
0x13aa4: adrp   x8, #0x1a000
0x13aa8: str    wzr, [sp, #0x90]
0x13aac: add    x8, x8, #0x440 ; =0x1a440
0x13ab0: add    x1, sp, #0xe0
0x13ab4: add    x2, sp, #0x90
0x13ab8: str    x8, [sp, #0xe0]
0x13abc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13ac0: adrp   x19, #0x1a000
0x13ac4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13ac8: adrp   x5, #0x1d000
0x13acc: mov    w20, #0x4e0
0x13ad0: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13ad4: mov    w0, #0x51
0x13ad8: add    x2, sp, #0x160
0x13adc: mov    w3, #0x80
0x13ae0: mov    w1, wzr
0x13ae4: mov    x4, x19
0x13ae8: mov    w6, w20
0x13aec: bl     #0x2368 ; <duss_log_gen_head>
0x13af0: cbz    w0, #0x13b2c
0x13af4: ldr    x5, [sp, #0xe0]
0x13af8: adrp   x3, #0x1a000
0x13afc: ldr    w6, [sp, #0x90]
0x13b00: adrp   x4, #0x1a000
0x13b04: adrp   x7, #0x1a000
0x13b08: str    w20, [sp, #8]
0x13b0c: mov    w1, wzr
0x13b10: str    x19, [sp]
0x13b14: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13b18: add    x4, x4, #0x441 ; "co"
0x13b1c: mov    w0, #0x51
0x13b20: add    x7, x7, #0x81b ; "param"
0x13b24: add    x2, sp, #0x160
0x13b28: bl     #0x2378 ; <duss_log_print>
0x13b2c: adrp   x4, #0x1a000
0x13b30: adrp   x5, #0x1d000
0x13b34: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13b38: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13b3c: mov    w0, #0x51
0x13b40: mov    w6, #0x4e0
0x13b44: b      #0x13704
0x13b48: adrp   x8, #0x1a000
0x13b4c: str    wzr, [sp, #0x90]
0x13b50: add    x8, x8, #0x440 ; =0x1a440
0x13b54: add    x1, sp, #0xe0
0x13b58: add    x2, sp, #0x90
0x13b5c: str    x8, [sp, #0xe0]
0x13b60: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13b64: adrp   x19, #0x1a000
0x13b68: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13b6c: adrp   x5, #0x1d000
0x13b70: mov    w20, #0x4e2
0x13b74: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13b78: mov    w0, #0x51
0x13b7c: add    x2, sp, #0x160
0x13b80: mov    w3, #0x80
0x13b84: mov    w1, wzr
0x13b88: mov    x4, x19
0x13b8c: mov    w6, w20
0x13b90: bl     #0x2368 ; <duss_log_gen_head>
0x13b94: cbz    w0, #0x13bd0
0x13b98: ldr    x5, [sp, #0xe0]
0x13b9c: adrp   x3, #0x1a000
0x13ba0: ldr    w6, [sp, #0x90]
0x13ba4: adrp   x4, #0x1a000
0x13ba8: adrp   x7, #0x1d000
0x13bac: str    w20, [sp, #8]
0x13bb0: mov    w1, wzr
0x13bb4: str    x19, [sp]
0x13bb8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13bbc: add    x4, x4, #0x441 ; "co"
0x13bc0: mov    w0, #0x51
0x13bc4: add    x7, x7, #0x51d ; "stream_buffer_primary"
0x13bc8: add    x2, sp, #0x160
0x13bcc: bl     #0x2378 ; <duss_log_print>
0x13bd0: adrp   x4, #0x1a000
0x13bd4: adrp   x5, #0x1d000
0x13bd8: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13bdc: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13be0: mov    w0, #0x51
0x13be4: mov    w6, #0x4e2
0x13be8: b      #0x13704
0x13bec: bl     #0x2348 ; <co_thread_get>
0x13bf0: cbnz   x0, #0x13f4c
0x13bf4: adrp   x4, #0x1a000
0x13bf8: adrp   x5, #0x1d000
0x13bfc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13c00: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13c04: mov    w0, #0x51
0x13c08: mov    w6, #0x4f1
0x13c0c: add    x2, sp, #0x160
0x13c10: mov    w3, #0x80
0x13c14: mov    w1, wzr
0x13c18: bl     #0x2368 ; <duss_log_gen_head>
0x13c1c: cbz    w0, #0x13fd4
0x13c20: adrp   x3, #0x1a000
0x13c24: adrp   x4, #0x1b000
0x13c28: adrp   x5, #0x1a000
0x13c2c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x13c30: add    x4, x4, #0xbf1 ; "buffer_group"
0x13c34: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13c38: mov    w0, #0x51
0x13c3c: mov    w6, #0x4f1
0x13c40: add    x2, sp, #0x160
0x13c44: mov    w1, wzr
0x13c48: bl     #0x2378 ; <duss_log_print>
0x13c4c: b      #0x13fd4
0x13c50: bl     #0x2348 ; <co_thread_get>
0x13c54: cbnz   x0, #0x13ff0
0x13c58: adrp   x4, #0x1a000
0x13c5c: adrp   x5, #0x1d000
0x13c60: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13c64: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13c68: mov    w0, #0x51
0x13c6c: mov    w6, #0x4f2
0x13c70: add    x2, sp, #0x160
0x13c74: mov    w3, #0x80
0x13c78: mov    w1, wzr
0x13c7c: bl     #0x2368 ; <duss_log_gen_head>
0x13c80: cbz    w0, #0x14078
0x13c84: adrp   x3, #0x1a000
0x13c88: adrp   x4, #0x1d000
0x13c8c: adrp   x5, #0x1a000
0x13c90: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x13c94: add    x4, x4, #0x5a2 ; "buffer_group->ele_count > 0"
0x13c98: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13c9c: mov    w0, #0x51
0x13ca0: mov    w6, #0x4f2
0x13ca4: add    x2, sp, #0x160
0x13ca8: mov    w1, wzr
0x13cac: bl     #0x2378 ; <duss_log_print>
0x13cb0: b      #0x14078
0x13cb4: bl     #0x2348 ; <co_thread_get>
0x13cb8: cbnz   x0, #0x14094
0x13cbc: adrp   x4, #0x1a000
0x13cc0: adrp   x5, #0x1d000
0x13cc4: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13cc8: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13ccc: mov    w0, #0x51
0x13cd0: mov    w6, #0x4f3
0x13cd4: add    x2, sp, #0x160
0x13cd8: mov    w3, #0x80
0x13cdc: mov    w1, wzr
0x13ce0: bl     #0x2368 ; <duss_log_gen_head>
0x13ce4: cbz    w0, #0x1411c
0x13ce8: adrp   x3, #0x1a000
0x13cec: adrp   x4, #0x1d000
0x13cf0: adrp   x5, #0x1a000
0x13cf4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x13cf8: add    x4, x4, #0x5be ; "buffer_group->sbuffer_list[0]"
0x13cfc: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13d00: mov    w0, #0x51
0x13d04: mov    w6, #0x4f3
0x13d08: add    x2, sp, #0x160
0x13d0c: mov    w1, wzr
0x13d10: bl     #0x2378 ; <duss_log_print>
0x13d14: b      #0x1411c
0x13d18: bl     #0x2348 ; <co_thread_get>
0x13d1c: cbnz   x0, #0x1419c
0x13d20: adrp   x4, #0x1a000
0x13d24: adrp   x5, #0x1d000
0x13d28: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13d2c: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13d30: mov    w0, #0x51
0x13d34: mov    w6, #0x4f4
0x13d38: add    x2, sp, #0x160
0x13d3c: mov    w3, #0x80
0x13d40: mov    w1, wzr
0x13d44: bl     #0x2368 ; <duss_log_gen_head>
0x13d48: cbz    w0, #0x14224
0x13d4c: adrp   x3, #0x1a000
0x13d50: adrp   x4, #0x1d000
0x13d54: adrp   x5, #0x1a000
0x13d58: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x13d5c: add    x4, x4, #0x5dc ; "buffer_group->sbuffer_list[0] == stream_buffer_primary"
0x13d60: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13d64: mov    w0, #0x51
0x13d68: mov    w6, #0x4f4
0x13d6c: add    x2, sp, #0x160
0x13d70: mov    w1, wzr
0x13d74: bl     #0x2378 ; <duss_log_print>
0x13d78: b      #0x14224
0x13d7c: adrp   x8, #0x1a000
0x13d80: str    wzr, [sp, #0x8c]
0x13d84: add    x8, x8, #0x440 ; =0x1a440
0x13d88: add    x1, sp, #0x90
0x13d8c: add    x2, sp, #0x8c
0x13d90: str    x8, [sp, #0x90]
0x13d94: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13d98: adrp   x20, #0x1a000
0x13d9c: add    x20, x20, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13da0: adrp   x5, #0x1d000
0x13da4: mov    w21, #0x4c0
0x13da8: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x13dac: mov    w0, #0x51
0x13db0: add    x2, sp, #0xe0
0x13db4: mov    w3, #0x80
0x13db8: mov    w1, wzr
0x13dbc: mov    x4, x20
0x13dc0: mov    w6, w21
0x13dc4: bl     #0x2368 ; <duss_log_gen_head>
0x13dc8: cbz    w0, #0x13e04
0x13dcc: ldr    x5, [sp, #0x90]
0x13dd0: adrp   x3, #0x1a000
0x13dd4: ldr    w6, [sp, #0x8c]
0x13dd8: adrp   x4, #0x1a000
0x13ddc: adrp   x7, #0x1d000
0x13de0: str    w21, [sp, #8]
0x13de4: mov    w1, wzr
0x13de8: str    x20, [sp]
0x13dec: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13df0: add    x4, x4, #0x441 ; "co"
0x13df4: mov    w0, #0x51
0x13df8: add    x7, x7, #0x8de ; "ret >= 0 && ret < max_size"
0x13dfc: add    x2, sp, #0xe0
0x13e00: bl     #0x2378 ; <duss_log_print>
0x13e04: adrp   x4, #0x1a000
0x13e08: adrp   x5, #0x1d000
0x13e0c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13e10: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x13e14: mov    w0, #0x51
0x13e18: mov    w6, #0x4c0
0x13e1c: add    x2, sp, #0xe0
0x13e20: mov    w3, #0x80
0x13e24: mov    w1, wzr
0x13e28: bl     #0x2368 ; <duss_log_gen_head>
0x13e2c: cbz    w0, #0x13e50
0x13e30: adrp   x3, #0x1d000
0x13e34: add    x3, x3, #0x8f9 ; "Assertion Comment: snprintf error ret: %d, (limited to:%d)"
0x13e38: mov    w0, #0x51
0x13e3c: add    x2, sp, #0xe0
0x13e40: mov    w5, #0x20
0x13e44: mov    w1, wzr
0x13e48: mov    w4, w19
0x13e4c: bl     #0x2378 ; <duss_log_print>
0x13e50: adrp   x0, #0x1d000
0x13e54: add    x0, x0, #0x934 ; "Camera Assertion Comment: snprintf error ret: %d, (limited to:%d)"
0x13e58: mov    w2, #0x20
0x13e5c: b      #0x13f40
0x13e60: adrp   x8, #0x1a000
0x13e64: str    wzr, [sp, #0x8c]
0x13e68: add    x8, x8, #0x440 ; =0x1a440
0x13e6c: add    x1, sp, #0x90
0x13e70: add    x2, sp, #0x8c
0x13e74: str    x8, [sp, #0x90]
0x13e78: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13e7c: adrp   x20, #0x1a000
0x13e80: add    x20, x20, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13e84: adrp   x5, #0x1d000
0x13e88: mov    w21, #0x4c1
0x13e8c: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x13e90: mov    w0, #0x51
0x13e94: add    x2, sp, #0xe0
0x13e98: mov    w3, #0x80
0x13e9c: mov    w1, wzr
0x13ea0: mov    x4, x20
0x13ea4: mov    w6, w21
0x13ea8: bl     #0x2368 ; <duss_log_gen_head>
0x13eac: cbz    w0, #0x13ee8
0x13eb0: ldr    x5, [sp, #0x90]
0x13eb4: adrp   x3, #0x1a000
0x13eb8: ldr    w6, [sp, #0x8c]
0x13ebc: adrp   x4, #0x1a000
0x13ec0: adrp   x7, #0x1d000
0x13ec4: str    w21, [sp, #8]
0x13ec8: mov    w1, wzr
0x13ecc: str    x20, [sp]
0x13ed0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13ed4: add    x4, x4, #0x441 ; "co"
0x13ed8: mov    w0, #0x51
0x13edc: add    x7, x7, #0x8de ; "ret >= 0 && ret < max_size"
0x13ee0: add    x2, sp, #0xe0
0x13ee4: bl     #0x2378 ; <duss_log_print>
0x13ee8: adrp   x4, #0x1a000
0x13eec: adrp   x5, #0x1d000
0x13ef0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13ef4: add    x5, x5, #0x8bf ; "_report_bad_frame_error_status"
0x13ef8: mov    w0, #0x51
0x13efc: mov    w6, #0x4c1
0x13f00: add    x2, sp, #0xe0
0x13f04: mov    w3, #0x80
0x13f08: mov    w1, wzr
0x13f0c: bl     #0x2368 ; <duss_log_gen_head>
0x13f10: cbz    w0, #0x13f34
0x13f14: adrp   x3, #0x1d000
0x13f18: add    x3, x3, #0x8f9 ; "Assertion Comment: snprintf error ret: %d, (limited to:%d)"
0x13f1c: mov    w0, #0x51
0x13f20: add    x2, sp, #0xe0
0x13f24: mov    w5, #0x80
0x13f28: mov    w1, wzr
0x13f2c: mov    w4, w19
0x13f30: bl     #0x2378 ; <duss_log_print>
0x13f34: adrp   x0, #0x1d000
0x13f38: add    x0, x0, #0x934 ; "Camera Assertion Comment: snprintf error ret: %d, (limited to:%d)"
0x13f3c: mov    w2, #0x80
0x13f40: mov    w1, w19
0x13f44: bl     #0x23e8 ; <log_to_kmsg>
0x13f48: b      #0x1373c
0x13f4c: adrp   x8, #0x1a000
0x13f50: str    wzr, [sp, #0x90]
0x13f54: add    x8, x8, #0x440 ; =0x1a440
0x13f58: add    x1, sp, #0xe0
0x13f5c: add    x2, sp, #0x90
0x13f60: str    x8, [sp, #0xe0]
0x13f64: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x13f68: adrp   x19, #0x1a000
0x13f6c: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13f70: adrp   x5, #0x1d000
0x13f74: mov    w20, #0x4f1
0x13f78: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13f7c: mov    w0, #0x51
0x13f80: add    x2, sp, #0x160
0x13f84: mov    w3, #0x80
0x13f88: mov    w1, wzr
0x13f8c: mov    x4, x19
0x13f90: mov    w6, w20
0x13f94: bl     #0x2368 ; <duss_log_gen_head>
0x13f98: cbz    w0, #0x13fd4
0x13f9c: ldr    x5, [sp, #0xe0]
0x13fa0: adrp   x3, #0x1a000
0x13fa4: ldr    w6, [sp, #0x90]
0x13fa8: adrp   x4, #0x1a000
0x13fac: adrp   x7, #0x1b000
0x13fb0: str    w20, [sp, #8]
0x13fb4: mov    w1, wzr
0x13fb8: str    x19, [sp]
0x13fbc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x13fc0: add    x4, x4, #0x441 ; "co"
0x13fc4: mov    w0, #0x51
0x13fc8: add    x7, x7, #0xbf1 ; "buffer_group"
0x13fcc: add    x2, sp, #0x160
0x13fd0: bl     #0x2378 ; <duss_log_print>
0x13fd4: adrp   x4, #0x1a000
0x13fd8: adrp   x5, #0x1d000
0x13fdc: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x13fe0: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x13fe4: mov    w0, #0x51
0x13fe8: mov    w6, #0x4f1
0x13fec: b      #0x13704
0x13ff0: adrp   x8, #0x1a000
0x13ff4: str    wzr, [sp, #0x90]
0x13ff8: add    x8, x8, #0x440 ; =0x1a440
0x13ffc: add    x1, sp, #0xe0
0x14000: add    x2, sp, #0x90
0x14004: str    x8, [sp, #0xe0]
0x14008: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1400c: adrp   x19, #0x1a000
0x14010: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14014: adrp   x5, #0x1d000
0x14018: mov    w20, #0x4f2
0x1401c: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x14020: mov    w0, #0x51
0x14024: add    x2, sp, #0x160
0x14028: mov    w3, #0x80
0x1402c: mov    w1, wzr
0x14030: mov    x4, x19
0x14034: mov    w6, w20
0x14038: bl     #0x2368 ; <duss_log_gen_head>
0x1403c: cbz    w0, #0x14078
0x14040: ldr    x5, [sp, #0xe0]
0x14044: adrp   x3, #0x1a000
0x14048: ldr    w6, [sp, #0x90]
0x1404c: adrp   x4, #0x1a000
0x14050: adrp   x7, #0x1d000
0x14054: str    w20, [sp, #8]
0x14058: mov    w1, wzr
0x1405c: str    x19, [sp]
0x14060: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x14064: add    x4, x4, #0x441 ; "co"
0x14068: mov    w0, #0x51
0x1406c: add    x7, x7, #0x5a2 ; "buffer_group->ele_count > 0"
0x14070: add    x2, sp, #0x160
0x14074: bl     #0x2378 ; <duss_log_print>
0x14078: adrp   x4, #0x1a000
0x1407c: adrp   x5, #0x1d000
0x14080: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14084: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x14088: mov    w0, #0x51
0x1408c: mov    w6, #0x4f2
0x14090: b      #0x13704
0x14094: adrp   x8, #0x1a000
0x14098: str    wzr, [sp, #0x90]
0x1409c: add    x8, x8, #0x440 ; =0x1a440
0x140a0: add    x1, sp, #0xe0
0x140a4: add    x2, sp, #0x90
0x140a8: str    x8, [sp, #0xe0]
0x140ac: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x140b0: adrp   x19, #0x1a000
0x140b4: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x140b8: adrp   x5, #0x1d000
0x140bc: mov    w20, #0x4f3
0x140c0: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x140c4: mov    w0, #0x51
0x140c8: add    x2, sp, #0x160
0x140cc: mov    w3, #0x80
0x140d0: mov    w1, wzr
0x140d4: mov    x4, x19
0x140d8: mov    w6, w20
0x140dc: bl     #0x2368 ; <duss_log_gen_head>
0x140e0: cbz    w0, #0x1411c
0x140e4: ldr    x5, [sp, #0xe0]
0x140e8: adrp   x3, #0x1a000
0x140ec: ldr    w6, [sp, #0x90]
0x140f0: adrp   x4, #0x1a000
0x140f4: adrp   x7, #0x1d000
0x140f8: str    w20, [sp, #8]
0x140fc: mov    w1, wzr
0x14100: str    x19, [sp]
0x14104: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x14108: add    x4, x4, #0x441 ; "co"
0x1410c: mov    w0, #0x51
0x14110: add    x7, x7, #0x5be ; "buffer_group->sbuffer_list[0]"
0x14114: add    x2, sp, #0x160
0x14118: bl     #0x2378 ; <duss_log_print>
0x1411c: adrp   x4, #0x1a000
0x14120: adrp   x5, #0x1d000
0x14124: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14128: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x1412c: mov    w0, #0x51
0x14130: mov    w6, #0x4f3
0x14134: b      #0x13704
0x14138: bl     #0x2348 ; <co_thread_get>
0x1413c: cbnz   x0, #0x14240
0x14140: adrp   x4, #0x1a000
0x14144: adrp   x5, #0x1d000
0x14148: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1414c: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x14150: mov    w0, #0x51
0x14154: mov    w6, #0x4f5
0x14158: add    x2, sp, #0x160
0x1415c: mov    w3, #0x80
0x14160: mov    w1, wzr
0x14164: bl     #0x2368 ; <duss_log_gen_head>
0x14168: cbz    w0, #0x142c8
0x1416c: adrp   x3, #0x1a000
0x14170: adrp   x4, #0x1d000
0x14174: adrp   x5, #0x1a000
0x14178: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1417c: add    x4, x4, #0x613 ; "buffer_group->ele_count <= 1 || buffer_group->sbuffer_list[1] == stream_buffer_secondary"
0x14180: add    x5, x5, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14184: mov    w0, #0x51
0x14188: mov    w6, #0x4f5
0x1418c: add    x2, sp, #0x160
0x14190: mov    w1, wzr
0x14194: bl     #0x2378 ; <duss_log_print>
0x14198: b      #0x142c8
0x1419c: adrp   x8, #0x1a000
0x141a0: str    wzr, [sp, #0x90]
0x141a4: add    x8, x8, #0x440 ; =0x1a440
0x141a8: add    x1, sp, #0xe0
0x141ac: add    x2, sp, #0x90
0x141b0: str    x8, [sp, #0xe0]
0x141b4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x141b8: adrp   x19, #0x1a000
0x141bc: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x141c0: adrp   x5, #0x1d000
0x141c4: mov    w20, #0x4f4
0x141c8: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x141cc: mov    w0, #0x51
0x141d0: add    x2, sp, #0x160
0x141d4: mov    w3, #0x80
0x141d8: mov    w1, wzr
0x141dc: mov    x4, x19
0x141e0: mov    w6, w20
0x141e4: bl     #0x2368 ; <duss_log_gen_head>
0x141e8: cbz    w0, #0x14224
0x141ec: ldr    x5, [sp, #0xe0]
0x141f0: adrp   x3, #0x1a000
0x141f4: ldr    w6, [sp, #0x90]
0x141f8: adrp   x4, #0x1a000
0x141fc: adrp   x7, #0x1d000
0x14200: str    w20, [sp, #8]
0x14204: mov    w1, wzr
0x14208: str    x19, [sp]
0x1420c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x14210: add    x4, x4, #0x441 ; "co"
0x14214: mov    w0, #0x51
0x14218: add    x7, x7, #0x5dc ; "buffer_group->sbuffer_list[0] == stream_buffer_primary"
0x1421c: add    x2, sp, #0x160
0x14220: bl     #0x2378 ; <duss_log_print>
0x14224: adrp   x4, #0x1a000
0x14228: adrp   x5, #0x1d000
0x1422c: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14230: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x14234: mov    w0, #0x51
0x14238: mov    w6, #0x4f4
0x1423c: b      #0x13704
0x14240: adrp   x8, #0x1a000
0x14244: str    wzr, [sp, #0x90]
0x14248: add    x8, x8, #0x440 ; =0x1a440
0x1424c: add    x1, sp, #0xe0
0x14250: add    x2, sp, #0x90
0x14254: str    x8, [sp, #0xe0]
0x14258: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1425c: adrp   x19, #0x1a000
0x14260: add    x19, x19, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14264: adrp   x5, #0x1d000
0x14268: mov    w20, #0x4f5
0x1426c: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x14270: mov    w0, #0x51
0x14274: add    x2, sp, #0x160
0x14278: mov    w3, #0x80
0x1427c: mov    w1, wzr
0x14280: mov    x4, x19
0x14284: mov    w6, w20
0x14288: bl     #0x2368 ; <duss_log_gen_head>
0x1428c: cbz    w0, #0x142c8
0x14290: ldr    x5, [sp, #0xe0]
0x14294: adrp   x3, #0x1a000
0x14298: ldr    w6, [sp, #0x90]
0x1429c: adrp   x4, #0x1a000
0x142a0: adrp   x7, #0x1d000
0x142a4: str    w20, [sp, #8]
0x142a8: mov    w1, wzr
0x142ac: str    x19, [sp]
0x142b0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x142b4: add    x4, x4, #0x441 ; "co"
0x142b8: mov    w0, #0x51
0x142bc: add    x7, x7, #0x613 ; "buffer_group->ele_count <= 1 || buffer_group->sbuffer_list[1] == stream_buffer_secondary"
0x142c0: add    x2, sp, #0x160
0x142c4: bl     #0x2378 ; <duss_log_print>
0x142c8: adrp   x4, #0x1a000
0x142cc: adrp   x5, #0x1d000
0x142d0: add    x4, x4, #0x444 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x142d4: add    x5, x5, #0x500 ; "_stream_buffer_full_callback"
0x142d8: mov    w0, #0x51
0x142dc: mov    w6, #0x4f5
0x142e0: b      #0x13704
0x142e4: udf    #0
0x142e8: adrp   x1, #0x14000
0x142ec: add    x1, x1, #0x2f8 ; =0x142f8
0x142f0: mov    x2, xzr
0x142f4: b      #0x2448 ; <parse_parameter_str>
0x142f8: sub    sp, sp, #0xf0
0x142fc: str    x23, [sp, #0xb0]
0x14300: stp    x22, x21, [sp, #0xc0]
0x14304: stp    x20, x19, [sp, #0xd0]
0x14308: stp    x29, x30, [sp, #0xe0]
0x1430c: add    x29, sp, #0xe0
0x14310: mrs    x22, tpidr_el0
0x14314: mov    x19, x2
0x14318: ldr    x8, [x22, #0x28]
0x1431c: add    x23, sp, #0x10
0x14320: mov    x20, x0
0x14324: cmp    w1, #0xd
0x14328: str    x8, [x23]
0x1432c: b.ne   #0x14364
0x14330: sxtw   x21, w1
0x14334: adrp   x1, #0x1e000
0x14338: add    x1, x1, #0x295 ; "xyz2cam_2800k"
0x1433c: mov    x0, x20
0x14340: mov    x2, x21
0x14344: bl     #0x26d8 ; <strncmp>
0x14348: cbz    w0, #0x1436c
0x1434c: adrp   x1, #0x1e000
0x14350: add    x1, x1, #0x303 ; "xyz2cam_6500k"
0x14354: mov    x0, x20
0x14358: mov    x2, x21
0x1435c: bl     #0x26d8 ; <strncmp>
0x14360: cbz    w0, #0x14434
0x14364: mov    w0, wzr
0x14368: b      #0x14654
0x1436c: cbz    x19, #0x14680
0x14370: adrp   x1, #0x30000
0x14374: add    x1, x1, #0x70 ; =0x30070
0x14378: mov    x0, x19
0x1437c: bl     #0x19968
0x14380: mov    w19, w0
0x14384: cbz    w19, #0x14654
0x14388: adrp   x0, #0x30000
0x1438c: adrp   x2, #0x1d000
0x14390: add    x0, x0, #0x100 ; =0x30100
0x14394: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x14398: mov    w1, #1
0x1439c: bl     #0x2338 ; <log_mgr_check>
0x143a0: tbz    w0, #0, #0x14650
0x143a4: bl     #0x2348 ; <co_thread_get>
0x143a8: cbz    x0, #0x14544
0x143ac: adrp   x8, #0x1a000
0x143b0: str    wzr, [sp, #0x1c]
0x143b4: add    x8, x8, #0x440 ; =0x1a440
0x143b8: add    x1, sp, #0x20
0x143bc: add    x2, sp, #0x1c
0x143c0: str    x8, [sp, #0x20]
0x143c4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x143c8: adrp   x4, #0x1d000
0x143cc: adrp   x5, #0x1e000
0x143d0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x143d4: add    x5, x5, #0x2a3 ; "_parse_param"
0x143d8: mov    w0, #0x51
0x143dc: mov    w6, #0x217
0x143e0: mov    w1, #1
0x143e4: add    x2, sp, #0x28
0x143e8: mov    w3, #0x80
0x143ec: bl     #0x2368 ; <duss_log_gen_head>
0x143f0: cbz    w0, #0x14418
0x143f4: adrp   x3, #0x1a000
0x143f8: adrp   x4, #0x1d000
0x143fc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x14400: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14404: mov    w0, #0x51
0x14408: mov    w5, #0x217
0x1440c: mov    w1, #1
0x14410: add    x2, sp, #0x28
0x14414: bl     #0x2378 ; <duss_log_print>
0x14418: adrp   x4, #0x1d000
0x1441c: adrp   x5, #0x1e000
0x14420: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14424: add    x5, x5, #0x2a3 ; "_parse_param"
0x14428: mov    w0, #0x51
0x1442c: mov    w6, #0x217
0x14430: b      #0x144f8
0x14434: cbz    x19, #0x146e4
0x14438: adrp   x1, #0x30000
0x1443c: add    x1, x1, #0xb8 ; =0x300b8
0x14440: mov    x0, x19
0x14444: bl     #0x19968
0x14448: mov    w19, w0
0x1444c: cbz    w19, #0x14654
0x14450: adrp   x0, #0x30000
0x14454: adrp   x2, #0x1d000
0x14458: add    x0, x0, #0x100 ; =0x30100
0x1445c: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x14460: mov    w1, #1
0x14464: bl     #0x2338 ; <log_mgr_check>
0x14468: tbz    w0, #0, #0x14650
0x1446c: bl     #0x2348 ; <co_thread_get>
0x14470: cbz    x0, #0x145b0
0x14474: adrp   x8, #0x1a000
0x14478: str    wzr, [sp, #0x1c]
0x1447c: add    x8, x8, #0x440 ; =0x1a440
0x14480: add    x1, sp, #0x20
0x14484: add    x2, sp, #0x1c
0x14488: str    x8, [sp, #0x20]
0x1448c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x14490: adrp   x4, #0x1d000
0x14494: adrp   x5, #0x1e000
0x14498: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1449c: add    x5, x5, #0x2a3 ; "_parse_param"
0x144a0: mov    w0, #0x51
0x144a4: mov    w6, #0x21e
0x144a8: mov    w1, #1
0x144ac: add    x2, sp, #0x28
0x144b0: mov    w3, #0x80
0x144b4: bl     #0x2368 ; <duss_log_gen_head>
0x144b8: cbz    w0, #0x144e0
0x144bc: adrp   x3, #0x1a000
0x144c0: adrp   x4, #0x1d000
0x144c4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x144c8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x144cc: mov    w0, #0x51
0x144d0: mov    w5, #0x21e
0x144d4: mov    w1, #1
0x144d8: add    x2, sp, #0x28
0x144dc: bl     #0x2378 ; <duss_log_print>
0x144e0: adrp   x4, #0x1d000
0x144e4: adrp   x5, #0x1e000
0x144e8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x144ec: add    x5, x5, #0x2a3 ; "_parse_param"
0x144f0: mov    w0, #0x51
0x144f4: mov    w6, #0x21e
0x144f8: mov    w1, #1
0x144fc: add    x2, sp, #0x28
0x14500: mov    w3, #0x80
0x14504: bl     #0x2368 ; <duss_log_gen_head>
0x14508: cbz    w0, #0x14650
0x1450c: ldr    x6, [sp, #0x20]
0x14510: adrp   x3, #0x1e000
0x14514: ldr    w7, [sp, #0x1c]
0x14518: adrp   x4, #0x1d000
0x1451c: adrp   x5, #0x1a000
0x14520: str    w19, [sp]
0x14524: add    x3, x3, #0x2b6 ; "%s: %s(%s_%x): _xyz2cam_extract() fail, %d
"
0x14528: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1452c: add    x5, x5, #0x441 ; "co"
0x14530: mov    w0, #0x51
0x14534: mov    w1, #1
0x14538: add    x2, sp, #0x28
0x1453c: bl     #0x2378 ; <duss_log_print>
0x14540: b      #0x14650
0x14544: adrp   x4, #0x1d000
0x14548: adrp   x5, #0x1e000
0x1454c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14550: add    x5, x5, #0x2a3 ; "_parse_param"
0x14554: mov    w0, #0x51
0x14558: mov    w6, #0x217
0x1455c: mov    w1, #1
0x14560: add    x2, sp, #0x28
0x14564: mov    w3, #0x80
0x14568: bl     #0x2368 ; <duss_log_gen_head>
0x1456c: cbz    w0, #0x14594
0x14570: adrp   x3, #0x1a000
0x14574: adrp   x4, #0x1d000
0x14578: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x1457c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14580: mov    w0, #0x51
0x14584: mov    w5, #0x217
0x14588: mov    w1, #1
0x1458c: add    x2, sp, #0x28
0x14590: bl     #0x2378 ; <duss_log_print>
0x14594: adrp   x4, #0x1d000
0x14598: adrp   x5, #0x1e000
0x1459c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x145a0: add    x5, x5, #0x2a3 ; "_parse_param"
0x145a4: mov    w0, #0x51
0x145a8: mov    w6, #0x217
0x145ac: b      #0x14618
0x145b0: adrp   x4, #0x1d000
0x145b4: adrp   x5, #0x1e000
0x145b8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x145bc: add    x5, x5, #0x2a3 ; "_parse_param"
0x145c0: mov    w0, #0x51
0x145c4: mov    w6, #0x21e
0x145c8: mov    w1, #1
0x145cc: add    x2, sp, #0x28
0x145d0: mov    w3, #0x80
0x145d4: bl     #0x2368 ; <duss_log_gen_head>
0x145d8: cbz    w0, #0x14600
0x145dc: adrp   x3, #0x1a000
0x145e0: adrp   x4, #0x1d000
0x145e4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x145e8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x145ec: mov    w0, #0x51
0x145f0: mov    w5, #0x21e
0x145f4: mov    w1, #1
0x145f8: add    x2, sp, #0x28
0x145fc: bl     #0x2378 ; <duss_log_print>
0x14600: adrp   x4, #0x1d000
0x14604: adrp   x5, #0x1e000
0x14608: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1460c: add    x5, x5, #0x2a3 ; "_parse_param"
0x14610: mov    w0, #0x51
0x14614: mov    w6, #0x21e
0x14618: mov    w1, #1
0x1461c: add    x2, sp, #0x28
0x14620: mov    w3, #0x80
0x14624: bl     #0x2368 ; <duss_log_gen_head>
0x14628: cbz    w0, #0x14650
0x1462c: adrp   x3, #0x1e000
0x14630: adrp   x4, #0x1d000
0x14634: add    x3, x3, #0x2e2 ; "%s: _xyz2cam_extract() fail, %d
"
0x14638: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1463c: mov    w0, #0x51
0x14640: mov    w1, #1
0x14644: add    x2, sp, #0x28
0x14648: mov    w5, w19
0x1464c: bl     #0x2378 ; <duss_log_print>
0x14650: mov    w0, #-0x3e9
0x14654: ldr    x8, [x22, #0x28]
0x14658: ldr    x9, [x23]
0x1465c: cmp    x8, x9
0x14660: b.ne   #0x1467c
0x14664: ldp    x29, x30, [sp, #0xe0]
0x14668: ldp    x20, x19, [sp, #0xd0]
0x1466c: ldp    x22, x21, [sp, #0xc0]
0x14670: ldr    x23, [sp, #0xb0]
0x14674: add    sp, sp, #0xf0
0x14678: ret    
0x1467c: bl     #0x23d8 ; <__stack_chk_fail>
0x14680: bl     #0x2348 ; <co_thread_get>
0x14684: cbnz   x0, #0x14748
0x14688: adrp   x4, #0x1d000
0x1468c: adrp   x5, #0x1e000
0x14690: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14694: add    x5, x5, #0x2a3 ; "_parse_param"
0x14698: mov    w0, #0x51
0x1469c: mov    w6, #0x214
0x146a0: add    x2, sp, #0x28
0x146a4: mov    w3, #0x80
0x146a8: mov    w1, wzr
0x146ac: bl     #0x2368 ; <duss_log_gen_head>
0x146b0: cbz    w0, #0x147d0
0x146b4: adrp   x3, #0x1a000
0x146b8: adrp   x4, #0x1e000
0x146bc: adrp   x5, #0x1d000
0x146c0: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x146c4: add    x4, x4, #0x2b0 ; "value"
0x146c8: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x146cc: mov    w0, #0x51
0x146d0: mov    w6, #0x214
0x146d4: add    x2, sp, #0x28
0x146d8: mov    w1, wzr
0x146dc: bl     #0x2378 ; <duss_log_print>
0x146e0: b      #0x147d0
0x146e4: bl     #0x2348 ; <co_thread_get>
0x146e8: cbnz   x0, #0x147ec
0x146ec: adrp   x4, #0x1d000
0x146f0: adrp   x5, #0x1e000
0x146f4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x146f8: add    x5, x5, #0x2a3 ; "_parse_param"
0x146fc: mov    w0, #0x51
0x14700: mov    w6, #0x21b
0x14704: add    x2, sp, #0x28
0x14708: mov    w3, #0x80
0x1470c: mov    w1, wzr
0x14710: bl     #0x2368 ; <duss_log_gen_head>
0x14714: cbz    w0, #0x14874
0x14718: adrp   x3, #0x1a000
0x1471c: adrp   x4, #0x1e000
0x14720: adrp   x5, #0x1d000
0x14724: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x14728: add    x4, x4, #0x2b0 ; "value"
0x1472c: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14730: mov    w0, #0x51
0x14734: mov    w6, #0x21b
0x14738: add    x2, sp, #0x28
0x1473c: mov    w1, wzr
0x14740: bl     #0x2378 ; <duss_log_print>
0x14744: b      #0x14874
0x14748: adrp   x8, #0x1a000
0x1474c: str    wzr, [sp, #0x1c]
0x14750: add    x8, x8, #0x440 ; =0x1a440
0x14754: add    x1, sp, #0x20
0x14758: add    x2, sp, #0x1c
0x1475c: str    x8, [sp, #0x20]
0x14760: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x14764: adrp   x19, #0x1d000
0x14768: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1476c: adrp   x5, #0x1e000
0x14770: mov    w20, #0x214
0x14774: add    x5, x5, #0x2a3 ; "_parse_param"
0x14778: mov    w0, #0x51
0x1477c: add    x2, sp, #0x28
0x14780: mov    w3, #0x80
0x14784: mov    w1, wzr
0x14788: mov    x4, x19
0x1478c: mov    w6, w20
0x14790: bl     #0x2368 ; <duss_log_gen_head>
0x14794: cbz    w0, #0x147d0
0x14798: ldr    x5, [sp, #0x20]
0x1479c: adrp   x3, #0x1a000
0x147a0: ldr    w6, [sp, #0x1c]
0x147a4: adrp   x4, #0x1a000
0x147a8: adrp   x7, #0x1e000
0x147ac: str    w20, [sp, #8]
0x147b0: mov    w1, wzr
0x147b4: str    x19, [sp]
0x147b8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x147bc: add    x4, x4, #0x441 ; "co"
0x147c0: mov    w0, #0x51
0x147c4: add    x7, x7, #0x2b0 ; "value"
0x147c8: add    x2, sp, #0x28
0x147cc: bl     #0x2378 ; <duss_log_print>
0x147d0: adrp   x4, #0x1d000
0x147d4: adrp   x5, #0x1e000
0x147d8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x147dc: add    x5, x5, #0x2a3 ; "_parse_param"
0x147e0: mov    w0, #0x51
0x147e4: mov    w6, #0x214
0x147e8: b      #0x1488c
0x147ec: adrp   x8, #0x1a000
0x147f0: str    wzr, [sp, #0x1c]
0x147f4: add    x8, x8, #0x440 ; =0x1a440
0x147f8: add    x1, sp, #0x20
0x147fc: add    x2, sp, #0x1c
0x14800: str    x8, [sp, #0x20]
0x14804: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x14808: adrp   x19, #0x1d000
0x1480c: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14810: adrp   x5, #0x1e000
0x14814: mov    w20, #0x21b
0x14818: add    x5, x5, #0x2a3 ; "_parse_param"
0x1481c: mov    w0, #0x51
0x14820: add    x2, sp, #0x28
0x14824: mov    w3, #0x80
0x14828: mov    w1, wzr
0x1482c: mov    x4, x19
0x14830: mov    w6, w20
0x14834: bl     #0x2368 ; <duss_log_gen_head>
0x14838: cbz    w0, #0x14874
0x1483c: ldr    x5, [sp, #0x20]
0x14840: adrp   x3, #0x1a000
0x14844: ldr    w6, [sp, #0x1c]
0x14848: adrp   x4, #0x1a000
0x1484c: adrp   x7, #0x1e000
0x14850: str    w20, [sp, #8]
0x14854: mov    w1, wzr
0x14858: str    x19, [sp]
0x1485c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x14860: add    x4, x4, #0x441 ; "co"
0x14864: mov    w0, #0x51
0x14868: add    x7, x7, #0x2b0 ; "value"
0x1486c: add    x2, sp, #0x28
0x14870: bl     #0x2378 ; <duss_log_print>
0x14874: adrp   x4, #0x1d000
0x14878: adrp   x5, #0x1e000
0x1487c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14880: add    x5, x5, #0x2a3 ; "_parse_param"
0x14884: mov    w0, #0x51
0x14888: mov    w6, #0x21b
0x1488c: add    x2, sp, #0x28
0x14890: mov    w3, #0x80
0x14894: mov    w1, wzr
0x14898: bl     #0x2368 ; <duss_log_gen_head>
0x1489c: cbz    w0, #0x148b8
0x148a0: adrp   x3, #0x1a000
0x148a4: add    x3, x3, #0x550 ; "Assertion Comment: "
0x148a8: mov    w0, #0x51
0x148ac: add    x2, sp, #0x28
0x148b0: mov    w1, wzr
0x148b4: bl     #0x2378 ; <duss_log_print>
0x148b8: adrp   x0, #0x1a000
0x148bc: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x148c0: bl     #0x23e8 ; <log_to_kmsg>
0x148c4: adrp   x0, #0x1a000
0x148c8: add    x0, x0, #0x57f ; "Camera:	"
0x148cc: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x148d0: bl     #0x2408 ; <is_running_in_cam_sil>
0x148d4: tbz    w0, #0, #0x148e4
0x148d8: mov    x0, xzr
0x148dc: bl     #0x2418 ; <fflush>
0x148e0: bl     #0x2428 ; <abort>
0x148e4: mov    w0, #1
0x148e8: bl     #0x2438 ; <exit>
0x148ec: udf    #0
0x148f0: sub    sp, sp, #0x1c0
0x148f4: stp    d15, d14, [sp, #0x120]
0x148f8: stp    d13, d12, [sp, #0x130]
0x148fc: stp    d11, d10, [sp, #0x140]
0x14900: stp    d9, d8, [sp, #0x150]
0x14904: stp    x28, x27, [sp, #0x160]
0x14908: stp    x26, x25, [sp, #0x170]
0x1490c: stp    x24, x23, [sp, #0x180]
0x14910: stp    x22, x21, [sp, #0x190]
0x14914: stp    x20, x19, [sp, #0x1a0]
0x14918: stp    x29, x30, [sp, #0x1b0]
0x1491c: add    x29, sp, #0x1b0
0x14920: mrs    x9, tpidr_el0
0x14924: add    x10, sp, #0x80
0x14928: ldr    x8, [x9, #0x28]
0x1492c: str    x8, [x10]
0x14930: str    x0, [sp, #0x40]
0x14934: cbz    x0, #0x156a4
0x14938: cbz    x1, #0x15708
0x1493c: fcmp   d0, #0.0
0x14940: b.eq   #0x1576c
0x14944: fcmp   d1, #0.0
0x14948: str    x1, [sp, #0x18]
0x1494c: b.eq   #0x157d0
0x14950: fmov   d2, #1.00000000
0x14954: adrp   x8, #0x1a000
0x14958: str    x9, [sp, #0x20]
0x1495c: adrp   x9, #0x1a000
0x14960: adrp   x10, #0x1a000
0x14964: adrp   x19, #0x1a000
0x14968: adrp   x27, #0x1a000
0x1496c: adrp   x21, #0x30000
0x14970: fdiv   d0, d2, d0
0x14974: ldr    d10, [x19, #0x1b8]
0x14978: ldr    d11, [x27, #0x1c0]
0x1497c: adrp   x22, #0x1d000
0x14980: adrp   x24, #0x30000
0x14984: adrp   x25, #0x30000
0x14988: mov    w20, #-1
0x1498c: add    x21, x21, #0x100 ; =0x30100
0x14990: add    x22, x22, #0xb1c ; "PRORESRAWMETA"
0x14994: mov    w23, #5
0x14998: mov    w28, #0x51
0x1499c: mov    w26, #0x158
0x149a0: add    x24, x24, #0x70 ; =0x30070
0x149a4: add    x25, x25, #0xb8 ; =0x300b8
0x149a8: str    d0, [sp, #0x60]
0x149ac: fdiv   d0, d2, d1
0x149b0: str    d0, [sp, #0x68]
0x149b4: ldr    d0, [x8, #0x1c8]
0x149b8: adrp   x8, #0x1a000
0x149bc: str    d0, [sp, #0x58]
0x149c0: ldr    d0, [x9, #0x1d0]
0x149c4: adrp   x9, #0x1a000
0x149c8: str    d0, [sp, #0x38]
0x149cc: ldr    d0, [x8, #0x1d8]
0x149d0: adrp   x8, #0x1a000
0x149d4: str    d0, [sp, #0x30]
0x149d8: ldr    d0, [x10, #0x1e0]
0x149dc: str    d0, [sp, #0x28]
0x149e0: ldr    d0, [x8, #0x1e8]
0x149e4: str    d0, [sp, #0x50]
0x149e8: ldr    d0, [x9, #0x1f0]
0x149ec: str    d0, [sp, #0x48]
0x149f0: mov    v0.16b, v11.16b
0x149f4: mov    v1.16b, v10.16b
0x149f8: bl     #0x19e30
0x149fc: mov    v12.16b, v0.16b
0x14a00: ldr    d0, [sp, #0x58]
0x14a04: fmov   d8, #1.00000000
0x14a08: fcmp   d12, d0
0x14a0c: mov    v0.16b, v8.16b
0x14a10: b.ls   #0x14a38
0x14a14: ldr    d0, [sp, #0x38]
0x14a18: fcmp   d12, d0
0x14a1c: fmov   d0, xzr
0x14a20: b.ge   #0x14a38
0x14a24: fdiv   d0, d8, d12
0x14a28: ldr    d1, [sp, #0x30]
0x14a2c: fadd   d0, d0, d1
0x14a30: ldr    d1, [sp, #0x28]
0x14a34: fdiv   d0, d0, d1
0x14a38: mov    x0, x21
0x14a3c: str    q0, [sp, #0x70]
0x14a40: mov    w1, w23
0x14a44: mov    x2, x22
0x14a48: bl     #0x2338 ; <log_mgr_check>
0x14a4c: tbz    w0, #0, #0x14b38
0x14a50: bl     #0x2348 ; <co_thread_get>
0x14a54: cbz    x0, #0x14ae0
0x14a58: adrp   x8, #0x1a000
0x14a5c: str    wzr, [sp, #0x8c]
0x14a60: add    x8, x8, #0x440 ; =0x1a440
0x14a64: add    x1, sp, #0x90
0x14a68: add    x2, sp, #0x8c
0x14a6c: str    x8, [sp, #0x90]
0x14a70: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x14a74: adrp   x4, #0x1d000
0x14a78: adrp   x5, #0x1e000
0x14a7c: mov    w1, #3
0x14a80: add    x2, sp, #0x98
0x14a84: mov    w3, #0x80
0x14a88: mov    w0, w28
0x14a8c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14a90: add    x5, x5, #0x375 ; "find_xyz2cam"
0x14a94: mov    w6, w26
0x14a98: bl     #0x2368 ; <duss_log_gen_head>
0x14a9c: cbz    w0, #0x14b38
0x14aa0: mov    v0.16b, v12.16b
0x14aa4: ldr    x6, [sp, #0x90]
0x14aa8: mov    v1.16b, v11.16b
0x14aac: ldr    w7, [sp, #0x8c]
0x14ab0: mov    v2.16b, v10.16b
0x14ab4: adrp   x3, #0x1e000
0x14ab8: adrp   x5, #0x1a000
0x14abc: ldr    q3, [sp, #0x70]
0x14ac0: mov    w1, #3
0x14ac4: add    x2, sp, #0x98
0x14ac8: mov    w0, w28
0x14acc: add    x3, x3, #0x382 ; "%s: %s(%s_%x): t=%lf %lf-%lf %lf
"
0x14ad0: mov    x4, x22
0x14ad4: add    x5, x5, #0x441 ; "co"
0x14ad8: bl     #0x2378 ; <duss_log_print>
0x14adc: b      #0x14b38
0x14ae0: adrp   x4, #0x1d000
0x14ae4: adrp   x5, #0x1e000
0x14ae8: mov    w1, #3
0x14aec: add    x2, sp, #0x98
0x14af0: mov    w3, #0x80
0x14af4: mov    w0, w28
0x14af8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x14afc: add    x5, x5, #0x375 ; "find_xyz2cam"
0x14b00: mov    w6, w26
0x14b04: bl     #0x2368 ; <duss_log_gen_head>
0x14b08: cbz    w0, #0x14b38
0x14b0c: mov    v0.16b, v12.16b
0x14b10: adrp   x3, #0x1e000
0x14b14: mov    v1.16b, v11.16b
0x14b18: ldr    q3, [sp, #0x70]
0x14b1c: mov    v2.16b, v10.16b
0x14b20: mov    w1, #3
0x14b24: add    x2, sp, #0x98
0x14b28: mov    w0, w28
0x14b2c: add    x3, x3, #0x3a4 ; "%s: t=%lf %lf-%lf %lf
"
0x14b30: mov    x4, x22
0x14b34: bl     #0x2378 ; <duss_log_print>
0x14b38: ldr    q23, [sp, #0x70]
0x14b3c: fcmp   d23, d8
0x14b40: b.ge   #0x14bd0
0x14b44: fcmp   d23, #0.0
0x14b48: b.ls   #0x14be8
0x14b4c: fsub   d1, d8, d23
0x14b50: ldr    d5, [x24, #0x10]
0x14b54: ldp    d0, d2, [x24]
0x14b58: ldp    d3, d4, [x25]
0x14b5c: ldr    d6, [x25, #0x10]
0x14b60: fmul   d0, d23, d0
0x14b64: ldur   q7, [x24, #0x28]
0x14b68: fmul   d3, d1, d3
0x14b6c: ldur   q16, [x24, #0x18]
0x14b70: fmul   d2, d23, d2
0x14b74: ldur   q17, [x25, #0x28]
0x14b78: fmul   d4, d1, d4
0x14b7c: ldur   q18, [x25, #0x18]
0x14b80: fmul   d5, d23, d5
0x14b84: ldp    d19, d20, [x24, #0x38]
0x14b88: ldp    d21, d22, [x25, #0x38]
0x14b8c: fmul   d6, d1, d6
0x14b90: fmul   v16.2d, v16.2d, v23.d[0]
0x14b94: fmul   v7.2d, v7.2d, v23.d[0]
0x14b98: fmul   d19, d23, d19
0x14b9c: fmul   v17.2d, v17.2d, v1.d[0]
0x14ba0: fmul   d20, d23, d20
0x14ba4: fmul   v18.2d, v18.2d, v1.d[0]
0x14ba8: fmul   d21, d1, d21
0x14bac: fmul   d23, d1, d22
0x14bb0: fadd   d0, d0, d3
0x14bb4: fadd   d1, d2, d4
0x14bb8: fadd   d5, d5, d6
0x14bbc: fadd   v4.2d, v7.2d, v17.2d
0x14bc0: fadd   v2.2d, v16.2d, v18.2d
0x14bc4: fadd   d3, d19, d21
0x14bc8: fadd   d6, d20, d23
0x14bcc: b      #0x14bfc
0x14bd0: ldp    d0, d1, [x24]
0x14bd4: ldr    d5, [x24, #0x10]
0x14bd8: ldur   q4, [x24, #0x28]
0x14bdc: ldur   q2, [x24, #0x18]
0x14be0: ldp    d3, d6, [x24, #0x38]
0x14be4: b      #0x14bfc
0x14be8: ldp    d0, d1, [x25]
0x14bec: ldr    d5, [x25, #0x10]
0x14bf0: ldur   q4, [x25, #0x28]
0x14bf4: ldur   q2, [x25, #0x18]
0x14bf8: ldp    d3, d6, [x25, #0x38]
0x14bfc: fmul   d7, d6, v2.d[1]
0x14c00: fmul   d25, d0, d6
0x14c04: fmul   d16, d3, v4.d[0]
0x14c08: fmul   d17, d6, v2.d[0]
0x14c0c: fmul   d18, d4, v4.d[1]
0x14c10: mov    d19, v2.d[1]
0x14c14: fmul   d20, d3, v2.d[0]
0x14c18: fmul   d22, d1, v4.d[0]
0x14c1c: fsub   d7, d7, d16
0x14c20: fmul   d23, d5, v2.d[1]
0x14c24: fsub   d16, d17, d18
0x14c28: fmul   d19, d19, v4.d[1]
0x14c2c: fsub   d17, d18, d17
0x14c30: fmul   d21, d0, d7
0x14c34: fsub   d22, d22, d23
0x14c38: fmul   d16, d1, d16
0x14c3c: fmul   d23, d0, v4.d[0]
0x14c40: fsub   d19, d20, d19
0x14c44: fsub   d16, d21, d16
0x14c48: fmul   d21, d1, d6
0x14c4c: fmul   d20, d5, d19
0x14c50: fadd   d16, d20, d16
0x14c54: ldr    d20, [sp, #0x50]
0x14c58: fadd   d16, d16, d20
0x14c5c: fmul   d20, d5, d3
0x14c60: fdiv   d16, d8, d16
0x14c64: fsub   d20, d20, d21
0x14c68: fmul   d21, d5, v4.d[1]
0x14c6c: fmul   d5, d5, v2.d[0]
0x14c70: fmul   d4, d1, v4.d[1]
0x14c74: fmul   d1, d1, v2.d[0]
0x14c78: fmul   d2, d0, v2.d[1]
0x14c7c: fsub   d5, d5, d23
0x14c80: fsub   d1, d2, d1
0x14c84: fmul   d0, d0, d3
0x14c88: fsub   d3, d25, d21
0x14c8c: fmul   d8, d7, d16
0x14c90: fmul   d21, d17, d16
0x14c94: fsub   d0, d4, d0
0x14c98: fmul   d20, d20, d16
0x14c9c: ldp    d4, d6, [sp, #0x60]
0x14ca0: fmul   d17, d22, d16
0x14ca4: fmul   d18, d3, d16
0x14ca8: fmul   d7, d5, d16
0x14cac: fmul   d14, d19, d16
0x14cb0: fmul   d2, d4, d8
0x14cb4: fmul   d3, d4, d21
0x14cb8: fmul   d9, d0, d16
0x14cbc: fmul   d15, d1, d16
0x14cc0: fmul   d1, d6, d17
0x14cc4: fmul   d0, d4, d14
0x14cc8: fadd   d2, d20, d2
0x14ccc: fmul   d4, d6, d7
0x14cd0: fadd   d3, d18, d3
0x14cd4: fmul   d19, d6, d15
0x14cd8: fadd   d5, d9, d0
0x14cdc: fadd   d1, d1, d2
0x14ce0: fadd   d0, d4, d3
0x14ce4: fadd   d2, d19, d5
0x14ce8: fadd   d3, d1, d0
0x14cec: fadd   d2, d2, d3
0x14cf0: fcmp   d2, #0.0
0x14cf4: b.le   #0x14d04
0x14cf8: fdiv   d13, d1, d2
0x14cfc: fdiv   d12, d0, d2
0x14d00: b      #0x14d0c
0x14d04: ldr    d12, [x19, #0x1b8]
0x14d08: ldr    d13, [x27, #0x1c0]
0x14d0c: fsub   d0, d13, d11
0x14d10: fsub   d1, d12, d10
0x14d14: fabs   d0, d0
0x14d18: fabs   d1, d1
0x14d1c: fadd   d0, d0, d1
0x14d20: ldr    d1, [sp, #0x48]
0x14d24: fcmp   d0, d1
0x14d28: b.mi   #0x14d60
0x14d2c: cmp    w20, #0x1c
0x14d30: b.eq   #0x14d4c
0x14d34: mov    v11.16b, v13.16b
0x14d38: add    w20, w20, #1
0x14d3c: mov    v10.16b, v12.16b
0x14d40: cmp    w20, #0x1d
0x14d44: b.lo   #0x149f0
0x14d48: b      #0x14d60
0x14d4c: fadd   d0, d11, d13
0x14d50: fmov   d1, #0.50000000
0x14d54: fadd   d2, d10, d12
0x14d58: fmul   d13, d0, d1
0x14d5c: fmul   d12, d2, d1
0x14d60: mov    v0.16b, v13.16b
0x14d64: str    d7, [sp, #0x70]
0x14d68: mov    v1.16b, v12.16b
0x14d6c: stp    d17, d18, [sp, #0x50]
0x14d70: mov    v10.16b, v20.16b
0x14d74: mov    v11.16b, v21.16b
0x14d78: bl     #0x19e30
0x14d7c: adrp   x8, #0x1a000
0x14d80: fmov   d1, xzr
0x14d84: adrp   x9, #0x1a000
0x14d88: ldr    x19, [sp, #0x18]
0x14d8c: adrp   x10, #0x1a000
0x14d90: ldr    d2, [x8, #0x1f8]
0x14d94: adrp   x8, #0x1a000
0x14d98: ldr    d6, [x9, #0x218]
0x14d9c: adrp   x9, #0x1a000
0x14da0: ldr    d22, [x10, #0x240]
0x14da4: adrp   x10, #0x1a000
0x14da8: ldr    d3, [x8, #0x200]
0x14dac: adrp   x8, #0x1a000
0x14db0: fdiv   d2, d13, d2
0x14db4: ldr    d16, [x9, #0x220]
0x14db8: adrp   x9, #0x1a000
0x14dbc: ldr    d4, [x8, #0x208]
0x14dc0: adrp   x8, #0x1a000
0x14dc4: adrp   x0, #0x30000
0x14dc8: ldr    d20, [x9, #0x230]
0x14dcc: adrp   x9, #0x1a000
0x14dd0: ldr    d5, [x8, #0x210]
0x14dd4: adrp   x8, #0x1a000
0x14dd8: adrp   x2, #0x1d000
0x14ddc: ldr    d27, [x9, #0x270]
0x14de0: adrp   x9, #0x1a000
0x14de4: ldr    d7, [x8, #0x238]
0x14de8: adrp   x8, #0x1a000
0x14dec: add    x0, x0, #0x100 ; =0x30100
0x14df0: mov    w1, #5
0x14df4: ldr    d18, [x8, #0x228]
0x14df8: adrp   x8, #0x1a000
0x14dfc: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x14e00: ldr    d19, [x8, #0x250]
0x14e04: adrp   x8, #0x1a000
0x14e08: fdiv   d3, d12, d3
0x14e0c: ldp    d13, d12, [sp, #0x50]
0x14e10: fmul   d4, d2, d4
0x14e14: fmul   d6, d2, d6
0x14e18: fmul   d2, d2, d18
0x14e1c: ldr    d18, [x8, #0x268]
0x14e20: adrp   x8, #0x1a000
0x14e24: fmul   d5, d3, d5
0x14e28: fmul   d16, d3, d16
0x14e2c: fadd   d4, d4, d1
0x14e30: ldr    d23, [x8, #0x248]
0x14e34: fadd   d6, d6, d1
0x14e38: adrp   x8, #0x1a000
0x14e3c: fadd   d24, d2, d1
0x14e40: fmul   d3, d3, d20
0x14e44: fadd   d5, d5, d1
0x14e48: fadd   d16, d16, d1
0x14e4c: fmul   d17, d4, d7
0x14e50: fmul   d21, d4, d19
0x14e54: fmul   d2, d4, d18
0x14e58: fmul   d25, d6, d19
0x14e5c: fmul   d20, d5, d23
0x14e60: fadd   d17, d17, d1
0x14e64: fadd   d21, d21, d1
0x14e68: fsub   d2, d1, d2
0x14e6c: fadd   d25, d25, d1
0x14e70: fadd   d4, d17, d22
0x14e74: ldr    d22, [x8, #0x258]
0x14e78: adrp   x8, #0x1a000
0x14e7c: fmul   d17, d6, d7
0x14e80: fmul   d7, d24, d7
0x14e84: fadd   d27, d2, d27
0x14e88: ldr    d26, [x8, #0x260]
0x14e8c: adrp   x8, #0x1a000
0x14e90: fadd   d21, d21, d22
0x14e94: ldr    d22, [x10, #0x278]
0x14e98: fadd   d2, d20, d4
0x14e9c: adrp   x10, #0x1a000
0x14ea0: fadd   d17, d17, d1
0x14ea4: ldr    d28, [x8, #0x280]
0x14ea8: fmul   d29, d5, d26
0x14eac: adrp   x8, #0x1a000
0x14eb0: fmul   d5, d5, d22
0x14eb4: fadd   d20, d3, d1
0x14eb8: fadd   d7, d7, d1
0x14ebc: ldr    d30, [x8, #0x288]
0x14ec0: adrp   x8, #0x1a000
0x14ec4: fadd   d17, d17, d28
0x14ec8: fmul   d28, d16, d23
0x14ecc: fsub   d4, d21, d29
0x14ed0: fmul   d21, d6, d18
0x14ed4: fadd   d25, d25, d30
0x14ed8: fmul   d30, d16, d26
0x14edc: fadd   d3, d5, d27
0x14ee0: fmul   d18, d24, d18
0x14ee4: fmul   d16, d16, d22
0x14ee8: fmul   d26, d20, d26
0x14eec: fadd   d5, d28, d17
0x14ef0: fmul   d17, d24, d19
0x14ef4: fsub   d21, d1, d21
0x14ef8: ldr    d19, [x8, #0x298]
0x14efc: fsub   d6, d25, d30
0x14f00: ldr    d25, [x9, #0x290]
0x14f04: adrp   x8, #0x1a000
0x14f08: ldr    d24, [x10, #0x2b0]
0x14f0c: adrp   x9, #0x1a000
0x14f10: fsub   d18, d1, d18
0x14f14: fadd   d7, d7, d19
0x14f18: fmul   d19, d20, d23
0x14f1c: ldr    d23, [x8, #0x2a0]
0x14f20: adrp   x8, #0x1a000
0x14f24: fadd   d17, d17, d1
0x14f28: fmul   d20, d20, d22
0x14f2c: fadd   d21, d21, d25
0x14f30: fmul   d25, d2, d24
0x14f34: ldr    d27, [x8, #0x2b8]
0x14f38: adrp   x8, #0x1a000
0x14f3c: ldr    d30, [sp, #0x60]
0x14f40: fadd   d7, d19, d7
0x14f44: fmul   d19, d4, d24
0x14f48: ldr    d29, [x8, #0x2c0]
0x14f4c: adrp   x8, #0x1a000
0x14f50: fadd   d23, d17, d23
0x14f54: fmul   d28, d5, d27
0x14f58: fadd   d25, d25, d1
0x14f5c: ldr    d17, [x9, #0x2a8]
0x14f60: fmul   d22, d6, d27
0x14f64: adrp   x9, #0x1a000
0x14f68: fadd   d19, d19, d1
0x14f6c: fadd   d18, d18, d17
0x14f70: fadd   d17, d16, d21
0x14f74: fmul   d21, d3, d24
0x14f78: fsub   d16, d23, d26
0x14f7c: fmul   d23, d7, d29
0x14f80: fsub   d24, d25, d28
0x14f84: fsub   d19, d19, d22
0x14f88: fadd   d18, d20, d18
0x14f8c: fadd   d20, d21, d1
0x14f90: fmul   d21, d17, d27
0x14f94: fmul   d22, d16, d29
0x14f98: fsub   d23, d24, d23
0x14f9c: fmul   d24, d18, d29
0x14fa0: fsub   d20, d20, d21
0x14fa4: fsub   d19, d19, d22
0x14fa8: fmul   d21, d8, d23
0x14fac: fmul   d22, d10, d23
0x14fb0: fmul   d23, d13, d23
0x14fb4: ldp    d29, d31, [sp, #0x68]
0x14fb8: fsub   d20, d20, d24
0x14fbc: fmul   d24, d11, d19
0x14fc0: str    d0, [x19]
0x14fc4: fadd   d21, d21, d1
0x14fc8: fmul   d25, d12, d19
0x14fcc: fadd   d22, d22, d1
0x14fd0: fmul   d19, d31, d19
0x14fd4: fadd   d23, d23, d1
0x14fd8: fmul   d26, d14, d20
0x14fdc: fadd   d21, d24, d21
0x14fe0: fmul   d24, d9, d20
0x14fe4: fadd   d22, d25, d22
0x14fe8: fmul   d20, d15, d20
0x14fec: fadd   d19, d19, d23
0x14ff0: fadd   d21, d26, d21
0x14ff4: fadd   d22, d24, d22
0x14ff8: fadd   d19, d20, d19
0x14ffc: fmul   d23, d30, d21
0x15000: fmul   d21, d21, d1
0x15004: fmul   d20, d22, d1
0x15008: fmul   d24, d19, d1
0x1500c: fmul   d19, d29, d19
0x15010: fadd   d23, d23, d1
0x15014: fadd   d21, d21, d1
0x15018: fadd   d23, d20, d23
0x1501c: fadd   d22, d22, d21
0x15020: fadd   d20, d20, d21
0x15024: fadd   d21, d24, d23
0x15028: fadd   d22, d24, d22
0x1502c: fadd   d19, d19, d20
0x15030: fadd   d20, d21, d22
0x15034: fadd   d23, d19, d20
0x15038: fdiv   d20, d22, d23
0x1503c: ldr    d22, [x8, #0x2c8]
0x15040: adrp   x8, #0x1a000
0x15044: ldr    d24, [x8, #0x2d0]
0x15048: adrp   x8, #0x1a000
0x1504c: fmul   d26, d2, d22
0x15050: fdiv   d21, d21, d23
0x15054: fdiv   d19, d19, d23
0x15058: fsub   d23, d1, d26
0x1505c: ldr    d26, [x8, #0x2d8]
0x15060: adrp   x8, #0x1a000
0x15064: fmul   d25, d5, d24
0x15068: fmul   d27, d4, d22
0x1506c: fmul   d22, d3, d22
0x15070: fmul   d28, d6, d24
0x15074: fmul   d24, d17, d24
0x15078: fadd   d23, d25, d23
0x1507c: fmul   d25, d7, d26
0x15080: fsub   d27, d1, d27
0x15084: fsub   d22, d1, d22
0x15088: fadd   d23, d25, d23
0x1508c: fadd   d25, d28, d27
0x15090: fmul   d27, d16, d26
0x15094: fadd   d22, d24, d22
0x15098: fmul   d24, d18, d26
0x1509c: fmul   d26, d8, d23
0x150a0: fadd   d25, d27, d25
0x150a4: fmul   d27, d10, d23
0x150a8: fadd   d22, d24, d22
0x150ac: fmul   d23, d13, d23
0x150b0: fadd   d24, d26, d1
0x150b4: fmul   d26, d11, d25
0x150b8: fadd   d27, d27, d1
0x150bc: fmul   d28, d12, d25
0x150c0: fadd   d23, d23, d1
0x150c4: fmul   d25, d31, d25
0x150c8: fadd   d24, d26, d24
0x150cc: fmul   d26, d14, d22
0x150d0: fadd   d23, d25, d23
0x150d4: fadd   d24, d26, d24
0x150d8: fadd   d26, d28, d27
0x150dc: fmul   d27, d9, d22
0x150e0: fmul   d22, d15, d22
0x150e4: fadd   d25, d27, d26
0x150e8: fmul   d26, d30, d24
0x150ec: fmul   d27, d24, d1
0x150f0: fadd   d22, d22, d23
0x150f4: fadd   d23, d26, d1
0x150f8: fmul   d26, d25, d1
0x150fc: fadd   d24, d27, d1
0x15100: fmul   d27, d22, d1
0x15104: fmul   d22, d29, d22
0x15108: fadd   d23, d26, d23
0x1510c: fadd   d25, d25, d24
0x15110: fadd   d24, d26, d24
0x15114: fadd   d23, d27, d23
0x15118: fadd   d25, d27, d25
0x1511c: fadd   d22, d22, d24
0x15120: fadd   d24, d23, d25
0x15124: fadd   d26, d22, d24
0x15128: fdiv   d24, d23, d26
0x1512c: fdiv   d23, d25, d26
0x15130: ldr    d25, [x8, #0x2e0]
0x15134: adrp   x8, #0x1a000
0x15138: fmul   d2, d2, d25
0x1513c: fdiv   d22, d22, d26
0x15140: ldr    d26, [x8, #0x2e8]
0x15144: adrp   x8, #0x1a000
0x15148: ldr    d27, [x8, #0x2f0]
0x1514c: adrp   x8, #0x1a000
0x15150: fsub   d2, d1, d2
0x15154: fmul   d5, d5, d26
0x15158: fmul   d4, d4, d25
0x1515c: fmul   d3, d3, d25
0x15160: fmul   d6, d6, d26
0x15164: fadd   d2, d5, d2
0x15168: fmul   d5, d7, d27
0x1516c: fsub   d4, d1, d4
0x15170: fsub   d3, d1, d3
0x15174: fadd   d2, d5, d2
0x15178: fmul   d5, d17, d26
0x1517c: fadd   d4, d6, d4
0x15180: fmul   d6, d16, d27
0x15184: fadd   d3, d5, d3
0x15188: fmul   d5, d18, d27
0x1518c: fadd   d4, d6, d4
0x15190: fmul   d6, d8, d2
0x15194: fmul   d7, d10, d2
0x15198: fmul   d2, d13, d2
0x1519c: fadd   d3, d5, d3
0x151a0: fadd   d5, d6, d1
0x151a4: fmul   d6, d11, d4
0x151a8: fadd   d7, d7, d1
0x151ac: fmul   d16, d12, d4
0x151b0: fadd   d2, d2, d1
0x151b4: fmul   d17, d31, d4
0x151b8: fadd   d5, d6, d5
0x151bc: fmul   d6, d14, d3
0x151c0: fadd   d2, d17, d2
0x151c4: fadd   d5, d6, d5
0x151c8: fadd   d6, d16, d7
0x151cc: fmul   d7, d9, d3
0x151d0: fmul   d3, d15, d3
0x151d4: fadd   d4, d7, d6
0x151d8: fmul   d6, d30, d5
0x151dc: fmul   d5, d5, d1
0x151e0: fadd   d2, d3, d2
0x151e4: fadd   d3, d6, d1
0x151e8: fmul   d6, d4, d1
0x151ec: fadd   d5, d5, d1
0x151f0: fmul   d7, d2, d1
0x151f4: fmul   d2, d29, d2
0x151f8: fadd   d3, d6, d3
0x151fc: fadd   d4, d4, d5
0x15200: fadd   d5, d6, d5
0x15204: fadd   d3, d7, d3
0x15208: fadd   d4, d7, d4
0x1520c: fadd   d2, d2, d5
0x15210: fadd   d5, d3, d4
0x15214: fadd   d5, d2, d5
0x15218: fdiv   d2, d2, d5
0x1521c: fdiv   d3, d3, d5
0x15220: fdiv   d4, d4, d5
0x15224: ldr    d5, [x8, #0x2f8]
0x15228: adrp   x8, #0x1a000
0x1522c: ldr    d7, [x8, #0x300]
0x15230: adrp   x8, #0x1a000
0x15234: ldr    d18, [x8, #0x308]
0x15238: adrp   x8, #0x1a000
0x1523c: fmul   d6, d21, d5
0x15240: fmul   d16, d20, d5
0x15244: fmul   d5, d19, d5
0x15248: fmul   d17, d24, d7
0x1524c: fmul   d25, d23, d7
0x15250: fmul   d7, d22, d7
0x15254: fadd   d6, d6, d1
0x15258: fmul   d26, d4, d18
0x1525c: fadd   d16, d16, d1
0x15260: fadd   d5, d5, d1
0x15264: fadd   d6, d17, d6
0x15268: fmul   d17, d3, d18
0x1526c: fadd   d16, d25, d16
0x15270: ldr    d25, [x8, #0x310]
0x15274: fadd   d5, d7, d5
0x15278: fmul   d7, d2, d18
0x1527c: adrp   x8, #0x1a000
0x15280: fmul   d27, d20, d25
0x15284: ldr    d18, [x8, #0x328]
0x15288: fadd   d6, d17, d6
0x1528c: fmul   d17, d21, d25
0x15290: adrp   x8, #0x1a000
0x15294: fadd   d5, d7, d5
0x15298: ldr    d7, [x9, #0x318]
0x1529c: adrp   x9, #0x1a000
0x152a0: fmul   d25, d19, d25
0x152a4: fmul   d21, d21, d18
0x152a8: fadd   d16, d26, d16
0x152ac: fmul   d20, d20, d18
0x152b0: ldr    d26, [x8, #0x320]
0x152b4: fmul   d18, d19, d18
0x152b8: ldr    d28, [x9, #0x330]
0x152bc: adrp   x8, #0x1a000
0x152c0: fadd   d17, d17, d1
0x152c4: fadd   d27, d27, d1
0x152c8: fmul   d19, d24, d7
0x152cc: fadd   d25, d25, d1
0x152d0: fmul   d8, d23, d7
0x152d4: fsub   d21, d1, d21
0x152d8: fmul   d7, d22, d7
0x152dc: fmul   d24, d24, d28
0x152e0: fsub   d20, d1, d20
0x152e4: fmul   d10, d23, d28
0x152e8: fsub   d1, d1, d18
0x152ec: fmul   d18, d22, d28
0x152f0: ldr    d30, [x8, #0x338]
0x152f4: fadd   d17, d19, d17
0x152f8: fmul   d19, d3, d26
0x152fc: fadd   d22, d8, d27
0x15300: fmul   d28, d4, d26
0x15304: fadd   d7, d7, d25
0x15308: fmul   d25, d2, d26
0x1530c: fsub   d21, d21, d24
0x15310: fmul   d24, d3, d30
0x15314: fsub   d20, d20, d10
0x15318: fmul   d4, d4, d30
0x1531c: fsub   d1, d1, d18
0x15320: fmul   d2, d2, d30
0x15324: fsub   d17, d17, d19
0x15328: ldr    x8, [sp, #0x40]
0x1532c: fsub   d18, d22, d28
0x15330: fsub   d0, d7, d25
0x15334: fadd   d3, d24, d21
0x15338: fadd   d4, d4, d20
0x1533c: stp    d6, d16, [x8]
0x15340: fadd   d1, d2, d1
0x15344: stp    d5, d17, [x8, #0x10]
0x15348: stp    d18, d0, [x8, #0x20]
0x1534c: stp    d3, d4, [x8, #0x30]
0x15350: str    d1, [x8, #0x40]
0x15354: bl     #0x2338 ; <log_mgr_check>
0x15358: tbz    w0, #0, #0x1543c
0x1535c: bl     #0x2348 ; <co_thread_get>
0x15360: cbz    x0, #0x153e8
0x15364: adrp   x8, #0x1a000
0x15368: str    wzr, [sp, #0x8c]
0x1536c: add    x8, x8, #0x440 ; =0x1a440
0x15370: add    x1, sp, #0x90
0x15374: add    x2, sp, #0x8c
0x15378: str    x8, [sp, #0x90]
0x1537c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15380: adrp   x4, #0x1d000
0x15384: adrp   x5, #0x1d000
0x15388: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1538c: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15390: mov    w0, #0x51
0x15394: mov    w6, #0x23c
0x15398: mov    w1, #3
0x1539c: add    x2, sp, #0x98
0x153a0: mov    w3, #0x80
0x153a4: bl     #0x2368 ; <duss_log_gen_head>
0x153a8: cbz    w0, #0x1543c
0x153ac: ldr    x6, [sp, #0x90]
0x153b0: adrp   x3, #0x1d000
0x153b4: ldr    w7, [sp, #0x8c]
0x153b8: adrp   x4, #0x1d000
0x153bc: ldr    d0, [x19]
0x153c0: adrp   x5, #0x1a000
0x153c4: ldp    d1, d2, [sp, #0x60]
0x153c8: add    x3, x3, #0xb2a ; "%s: %s(%s_%x): ct=%lf @%lf,%lf
"
0x153cc: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x153d0: add    x5, x5, #0x441 ; "co"
0x153d4: mov    w0, #0x51
0x153d8: mov    w1, #3
0x153dc: add    x2, sp, #0x98
0x153e0: bl     #0x2378 ; <duss_log_print>
0x153e4: b      #0x1543c
0x153e8: adrp   x4, #0x1d000
0x153ec: adrp   x5, #0x1d000
0x153f0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x153f4: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x153f8: mov    w0, #0x51
0x153fc: mov    w6, #0x23c
0x15400: mov    w1, #3
0x15404: add    x2, sp, #0x98
0x15408: mov    w3, #0x80
0x1540c: bl     #0x2368 ; <duss_log_gen_head>
0x15410: cbz    w0, #0x1543c
0x15414: ldr    d0, [x19]
0x15418: adrp   x3, #0x1d000
0x1541c: adrp   x4, #0x1d000
0x15420: ldp    d1, d2, [sp, #0x60]
0x15424: add    x3, x3, #0xb4a ; "%s: ct=%lf @%lf,%lf
"
0x15428: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1542c: mov    w0, #0x51
0x15430: mov    w1, #3
0x15434: add    x2, sp, #0x98
0x15438: bl     #0x2378 ; <duss_log_print>
0x1543c: adrp   x0, #0x30000
0x15440: adrp   x2, #0x1d000
0x15444: add    x0, x0, #0x100 ; =0x30100
0x15448: mov    w1, #5
0x1544c: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x15450: bl     #0x2338 ; <log_mgr_check>
0x15454: tbz    w0, #0, #0x15530
0x15458: bl     #0x2348 ; <co_thread_get>
0x1545c: cbz    x0, #0x154e0
0x15460: adrp   x8, #0x1a000
0x15464: str    wzr, [sp, #0x8c]
0x15468: add    x8, x8, #0x440 ; =0x1a440
0x1546c: add    x1, sp, #0x90
0x15470: add    x2, sp, #0x8c
0x15474: str    x8, [sp, #0x90]
0x15478: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1547c: adrp   x4, #0x1d000
0x15480: adrp   x5, #0x1d000
0x15484: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15488: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x1548c: mov    w0, #0x51
0x15490: mov    w6, #0x23e
0x15494: mov    w1, #3
0x15498: add    x2, sp, #0x98
0x1549c: mov    w3, #0x80
0x154a0: bl     #0x2368 ; <duss_log_gen_head>
0x154a4: cbz    w0, #0x15530
0x154a8: ldr    x6, [sp, #0x90]
0x154ac: adrp   x3, #0x1d000
0x154b0: ldr    w7, [sp, #0x8c]
0x154b4: adrp   x4, #0x1d000
0x154b8: ldr    d0, [x19]
0x154bc: adrp   x5, #0x1a000
0x154c0: add    x3, x3, #0xb5f ; "%s: %s(%s_%x): cct:%lf
"
0x154c4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x154c8: add    x5, x5, #0x441 ; "co"
0x154cc: mov    w0, #0x51
0x154d0: mov    w1, #3
0x154d4: add    x2, sp, #0x98
0x154d8: bl     #0x2378 ; <duss_log_print>
0x154dc: b      #0x15530
0x154e0: adrp   x4, #0x1d000
0x154e4: adrp   x5, #0x1d000
0x154e8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x154ec: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x154f0: mov    w0, #0x51
0x154f4: mov    w6, #0x23e
0x154f8: mov    w1, #3
0x154fc: add    x2, sp, #0x98
0x15500: mov    w3, #0x80
0x15504: bl     #0x2368 ; <duss_log_gen_head>
0x15508: cbz    w0, #0x15530
0x1550c: ldr    d0, [x19]
0x15510: adrp   x3, #0x1d000
0x15514: adrp   x4, #0x1d000
0x15518: add    x3, x3, #0xb77 ; "%s: cct:%lf
"
0x1551c: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x15520: mov    w0, #0x51
0x15524: mov    w1, #3
0x15528: add    x2, sp, #0x98
0x1552c: bl     #0x2378 ; <duss_log_print>
0x15530: adrp   x21, #0x30000
0x15534: adrp   x22, #0x1d000
0x15538: adrp   x24, #0x1d000
0x1553c: adrp   x25, #0x1d000
0x15540: adrp   x28, #0x1d000
0x15544: adrp   x19, #0x1a000
0x15548: mov    x20, xzr
0x1554c: add    x21, x21, #0x100 ; =0x30100
0x15550: add    x22, x22, #0xb1c ; "PRORESRAWMETA"
0x15554: mov    w23, #5
0x15558: add    x24, x24, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1555c: add    x25, x25, #0xae8 ; "proresraw_ccm_cct_get"
0x15560: mov    w26, #0x51
0x15564: mov    w27, #0x240
0x15568: add    x28, x28, #0xb84 ; "%s: %s(%s_%x): ccm[%d]:%lf
"
0x1556c: add    x19, x19, #0x441 ; "co"
0x15570: mov    x0, x21
0x15574: mov    w1, w23
0x15578: mov    x2, x22
0x1557c: bl     #0x2338 ; <log_mgr_check>
0x15580: tbz    w0, #0, #0x1564c
0x15584: bl     #0x2348 ; <co_thread_get>
0x15588: cbz    x0, #0x15600
0x1558c: adrp   x8, #0x1a000
0x15590: str    wzr, [sp, #0x8c]
0x15594: add    x8, x8, #0x440 ; =0x1a440
0x15598: add    x1, sp, #0x90
0x1559c: add    x2, sp, #0x8c
0x155a0: str    x8, [sp, #0x90]
0x155a4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x155a8: mov    w1, #3
0x155ac: add    x2, sp, #0x98
0x155b0: mov    w3, #0x80
0x155b4: mov    w0, w26
0x155b8: mov    x4, x24
0x155bc: mov    x5, x25
0x155c0: mov    w6, w27
0x155c4: bl     #0x2368 ; <duss_log_gen_head>
0x155c8: cbz    w0, #0x1564c
0x155cc: ldr    x8, [sp, #0x40]
0x155d0: mov    w1, #3
0x155d4: ldr    x6, [sp, #0x90]
0x155d8: add    x2, sp, #0x98
0x155dc: ldr    w7, [sp, #0x8c]
0x155e0: mov    w0, w26
0x155e4: mov    x3, x28
0x155e8: ldr    d0, [x8, x20, lsl #3]
0x155ec: mov    x4, x22
0x155f0: mov    x5, x19
0x155f4: str    w20, [sp]
0x155f8: bl     #0x2378 ; <duss_log_print>
0x155fc: b      #0x1564c
0x15600: mov    w1, #3
0x15604: add    x2, sp, #0x98
0x15608: mov    w3, #0x80
0x1560c: mov    w0, w26
0x15610: mov    x4, x24
0x15614: mov    x5, x25
0x15618: mov    w6, w27
0x1561c: bl     #0x2368 ; <duss_log_gen_head>
0x15620: cbz    w0, #0x1564c
0x15624: ldr    x8, [sp, #0x40]
0x15628: adrp   x3, #0x1d000
0x1562c: mov    w1, #3
0x15630: add    x2, sp, #0x98
0x15634: mov    w0, w26
0x15638: ldr    d0, [x8, x20, lsl #3]
0x1563c: add    x3, x3, #0xba0 ; "%s: ccm[%d]:%lf
"
0x15640: mov    x4, x22
0x15644: mov    w5, w20
0x15648: bl     #0x2378 ; <duss_log_print>
0x1564c: add    x20, x20, #1 ; =0x1a001
0x15650: cmp    x20, #9
0x15654: b.ne   #0x15570
0x15658: ldr    x8, [sp, #0x20]
0x1565c: add    x9, sp, #0x80
0x15660: ldr    x8, [x8, #0x28]
0x15664: ldr    x9, [x9]
0x15668: cmp    x8, x9
0x1566c: b.ne   #0x15834
0x15670: ldp    x29, x30, [sp, #0x1b0]
0x15674: ldp    x20, x19, [sp, #0x1a0]
0x15678: ldp    x22, x21, [sp, #0x190]
0x1567c: ldp    x24, x23, [sp, #0x180]
0x15680: ldp    x26, x25, [sp, #0x170]
0x15684: ldp    x28, x27, [sp, #0x160]
0x15688: ldp    d9, d8, [sp, #0x150]
0x1568c: ldp    d11, d10, [sp, #0x140]
0x15690: ldp    d13, d12, [sp, #0x130]
0x15694: ldp    d15, d14, [sp, #0x120]
0x15698: mov    w0, wzr
0x1569c: add    sp, sp, #0x1c0
0x156a0: ret    
0x156a4: bl     #0x2348 ; <co_thread_get>
0x156a8: cbnz   x0, #0x15838
0x156ac: adrp   x4, #0x1d000
0x156b0: adrp   x5, #0x1d000
0x156b4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x156b8: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x156bc: mov    w0, #0x51
0x156c0: mov    w6, #0x231
0x156c4: add    x2, sp, #0x98
0x156c8: mov    w3, #0x80
0x156cc: mov    w1, wzr
0x156d0: bl     #0x2368 ; <duss_log_gen_head>
0x156d4: cbz    w0, #0x158c0
0x156d8: adrp   x3, #0x1a000
0x156dc: adrp   x4, #0x1d000
0x156e0: adrp   x5, #0x1d000
0x156e4: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x156e8: add    x4, x4, #0xafe ; "ccm"
0x156ec: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x156f0: mov    w0, #0x51
0x156f4: mov    w6, #0x231
0x156f8: add    x2, sp, #0x98
0x156fc: mov    w1, wzr
0x15700: bl     #0x2378 ; <duss_log_print>
0x15704: b      #0x158c0
0x15708: bl     #0x2348 ; <co_thread_get>
0x1570c: cbnz   x0, #0x158dc
0x15710: adrp   x4, #0x1d000
0x15714: adrp   x5, #0x1d000
0x15718: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1571c: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15720: mov    w0, #0x51
0x15724: mov    w6, #0x232
0x15728: add    x2, sp, #0x98
0x1572c: mov    w3, #0x80
0x15730: mov    w1, wzr
0x15734: bl     #0x2368 ; <duss_log_gen_head>
0x15738: cbz    w0, #0x15964
0x1573c: adrp   x3, #0x1a000
0x15740: adrp   x4, #0x1d000
0x15744: adrp   x5, #0x1d000
0x15748: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x1574c: add    x4, x4, #0xb02 ; "cct"
0x15750: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15754: mov    w0, #0x51
0x15758: mov    w6, #0x232
0x1575c: add    x2, sp, #0x98
0x15760: mov    w1, wzr
0x15764: bl     #0x2378 ; <duss_log_print>
0x15768: b      #0x15964
0x1576c: bl     #0x2348 ; <co_thread_get>
0x15770: cbnz   x0, #0x15980
0x15774: adrp   x4, #0x1d000
0x15778: adrp   x5, #0x1d000
0x1577c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15780: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15784: mov    w0, #0x51
0x15788: mov    w6, #0x234
0x1578c: add    x2, sp, #0x98
0x15790: mov    w3, #0x80
0x15794: mov    w1, wzr
0x15798: bl     #0x2368 ; <duss_log_gen_head>
0x1579c: cbz    w0, #0x15a08
0x157a0: adrp   x3, #0x1a000
0x157a4: adrp   x4, #0x1d000
0x157a8: adrp   x5, #0x1d000
0x157ac: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x157b0: add    x4, x4, #0xb06 ; "0 != gainr"
0x157b4: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x157b8: mov    w0, #0x51
0x157bc: mov    w6, #0x234
0x157c0: add    x2, sp, #0x98
0x157c4: mov    w1, wzr
0x157c8: bl     #0x2378 ; <duss_log_print>
0x157cc: b      #0x15a08
0x157d0: bl     #0x2348 ; <co_thread_get>
0x157d4: cbnz   x0, #0x15a24
0x157d8: adrp   x4, #0x1d000
0x157dc: adrp   x5, #0x1d000
0x157e0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x157e4: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x157e8: mov    w0, #0x51
0x157ec: mov    w6, #0x235
0x157f0: add    x2, sp, #0x98
0x157f4: mov    w3, #0x80
0x157f8: mov    w1, wzr
0x157fc: bl     #0x2368 ; <duss_log_gen_head>
0x15800: cbz    w0, #0x15aac
0x15804: adrp   x3, #0x1a000
0x15808: adrp   x4, #0x1d000
0x1580c: adrp   x5, #0x1d000
0x15810: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x15814: add    x4, x4, #0xb11 ; "0 != gainb"
0x15818: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1581c: mov    w0, #0x51
0x15820: mov    w6, #0x235
0x15824: add    x2, sp, #0x98
0x15828: mov    w1, wzr
0x1582c: bl     #0x2378 ; <duss_log_print>
0x15830: b      #0x15aac
0x15834: bl     #0x23d8 ; <__stack_chk_fail>
0x15838: adrp   x8, #0x1a000
0x1583c: str    wzr, [sp, #0x8c]
0x15840: add    x8, x8, #0x440 ; =0x1a440
0x15844: add    x1, sp, #0x90
0x15848: add    x2, sp, #0x8c
0x1584c: str    x8, [sp, #0x90]
0x15850: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15854: adrp   x19, #0x1d000
0x15858: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1585c: adrp   x5, #0x1d000
0x15860: mov    w20, #0x231
0x15864: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15868: mov    w0, #0x51
0x1586c: add    x2, sp, #0x98
0x15870: mov    w3, #0x80
0x15874: mov    w1, wzr
0x15878: mov    x4, x19
0x1587c: mov    w6, w20
0x15880: bl     #0x2368 ; <duss_log_gen_head>
0x15884: cbz    w0, #0x158c0
0x15888: ldr    x5, [sp, #0x90]
0x1588c: adrp   x3, #0x1a000
0x15890: ldr    w6, [sp, #0x8c]
0x15894: adrp   x4, #0x1a000
0x15898: adrp   x7, #0x1d000
0x1589c: str    w20, [sp, #8]
0x158a0: mov    w1, wzr
0x158a4: str    x19, [sp]
0x158a8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x158ac: add    x4, x4, #0x441 ; "co"
0x158b0: mov    w0, #0x51
0x158b4: add    x7, x7, #0xafe ; "ccm"
0x158b8: add    x2, sp, #0x98
0x158bc: bl     #0x2378 ; <duss_log_print>
0x158c0: adrp   x4, #0x1d000
0x158c4: adrp   x5, #0x1d000
0x158c8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x158cc: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x158d0: mov    w0, #0x51
0x158d4: mov    w6, #0x231
0x158d8: b      #0x15ac4
0x158dc: adrp   x8, #0x1a000
0x158e0: str    wzr, [sp, #0x8c]
0x158e4: add    x8, x8, #0x440 ; =0x1a440
0x158e8: add    x1, sp, #0x90
0x158ec: add    x2, sp, #0x8c
0x158f0: str    x8, [sp, #0x90]
0x158f4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x158f8: adrp   x19, #0x1d000
0x158fc: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15900: adrp   x5, #0x1d000
0x15904: mov    w20, #0x232
0x15908: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x1590c: mov    w0, #0x51
0x15910: add    x2, sp, #0x98
0x15914: mov    w3, #0x80
0x15918: mov    w1, wzr
0x1591c: mov    x4, x19
0x15920: mov    w6, w20
0x15924: bl     #0x2368 ; <duss_log_gen_head>
0x15928: cbz    w0, #0x15964
0x1592c: ldr    x5, [sp, #0x90]
0x15930: adrp   x3, #0x1a000
0x15934: ldr    w6, [sp, #0x8c]
0x15938: adrp   x4, #0x1a000
0x1593c: adrp   x7, #0x1d000
0x15940: str    w20, [sp, #8]
0x15944: mov    w1, wzr
0x15948: str    x19, [sp]
0x1594c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x15950: add    x4, x4, #0x441 ; "co"
0x15954: mov    w0, #0x51
0x15958: add    x7, x7, #0xb02 ; "cct"
0x1595c: add    x2, sp, #0x98
0x15960: bl     #0x2378 ; <duss_log_print>
0x15964: adrp   x4, #0x1d000
0x15968: adrp   x5, #0x1d000
0x1596c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15970: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15974: mov    w0, #0x51
0x15978: mov    w6, #0x232
0x1597c: b      #0x15ac4
0x15980: adrp   x8, #0x1a000
0x15984: str    wzr, [sp, #0x8c]
0x15988: add    x8, x8, #0x440 ; =0x1a440
0x1598c: add    x1, sp, #0x90
0x15990: add    x2, sp, #0x8c
0x15994: str    x8, [sp, #0x90]
0x15998: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1599c: adrp   x19, #0x1d000
0x159a0: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x159a4: adrp   x5, #0x1d000
0x159a8: mov    w20, #0x234
0x159ac: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x159b0: mov    w0, #0x51
0x159b4: add    x2, sp, #0x98
0x159b8: mov    w3, #0x80
0x159bc: mov    w1, wzr
0x159c0: mov    x4, x19
0x159c4: mov    w6, w20
0x159c8: bl     #0x2368 ; <duss_log_gen_head>
0x159cc: cbz    w0, #0x15a08
0x159d0: ldr    x5, [sp, #0x90]
0x159d4: adrp   x3, #0x1a000
0x159d8: ldr    w6, [sp, #0x8c]
0x159dc: adrp   x4, #0x1a000
0x159e0: adrp   x7, #0x1d000
0x159e4: str    w20, [sp, #8]
0x159e8: mov    w1, wzr
0x159ec: str    x19, [sp]
0x159f0: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x159f4: add    x4, x4, #0x441 ; "co"
0x159f8: mov    w0, #0x51
0x159fc: add    x7, x7, #0xb06 ; "0 != gainr"
0x15a00: add    x2, sp, #0x98
0x15a04: bl     #0x2378 ; <duss_log_print>
0x15a08: adrp   x4, #0x1d000
0x15a0c: adrp   x5, #0x1d000
0x15a10: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15a14: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15a18: mov    w0, #0x51
0x15a1c: mov    w6, #0x234
0x15a20: b      #0x15ac4
0x15a24: adrp   x8, #0x1a000
0x15a28: str    wzr, [sp, #0x8c]
0x15a2c: add    x8, x8, #0x440 ; =0x1a440
0x15a30: add    x1, sp, #0x90
0x15a34: add    x2, sp, #0x8c
0x15a38: str    x8, [sp, #0x90]
0x15a3c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15a40: adrp   x19, #0x1d000
0x15a44: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15a48: adrp   x5, #0x1d000
0x15a4c: mov    w20, #0x235
0x15a50: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15a54: mov    w0, #0x51
0x15a58: add    x2, sp, #0x98
0x15a5c: mov    w3, #0x80
0x15a60: mov    w1, wzr
0x15a64: mov    x4, x19
0x15a68: mov    w6, w20
0x15a6c: bl     #0x2368 ; <duss_log_gen_head>
0x15a70: cbz    w0, #0x15aac
0x15a74: ldr    x5, [sp, #0x90]
0x15a78: adrp   x3, #0x1a000
0x15a7c: ldr    w6, [sp, #0x8c]
0x15a80: adrp   x4, #0x1a000
0x15a84: adrp   x7, #0x1d000
0x15a88: str    w20, [sp, #8]
0x15a8c: mov    w1, wzr
0x15a90: str    x19, [sp]
0x15a94: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x15a98: add    x4, x4, #0x441 ; "co"
0x15a9c: mov    w0, #0x51
0x15aa0: add    x7, x7, #0xb11 ; "0 != gainb"
0x15aa4: add    x2, sp, #0x98
0x15aa8: bl     #0x2378 ; <duss_log_print>
0x15aac: adrp   x4, #0x1d000
0x15ab0: adrp   x5, #0x1d000
0x15ab4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15ab8: add    x5, x5, #0xae8 ; "proresraw_ccm_cct_get"
0x15abc: mov    w0, #0x51
0x15ac0: mov    w6, #0x235
0x15ac4: add    x2, sp, #0x98
0x15ac8: mov    w3, #0x80
0x15acc: mov    w1, wzr
0x15ad0: bl     #0x2368 ; <duss_log_gen_head>
0x15ad4: cbz    w0, #0x15af0
0x15ad8: adrp   x3, #0x1a000
0x15adc: add    x3, x3, #0x550 ; "Assertion Comment: "
0x15ae0: mov    w0, #0x51
0x15ae4: add    x2, sp, #0x98
0x15ae8: mov    w1, wzr
0x15aec: bl     #0x2378 ; <duss_log_print>
0x15af0: adrp   x0, #0x1a000
0x15af4: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x15af8: bl     #0x23e8 ; <log_to_kmsg>
0x15afc: adrp   x0, #0x1a000
0x15b00: add    x0, x0, #0x57f ; "Camera:	"
0x15b04: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x15b08: bl     #0x2408 ; <is_running_in_cam_sil>
0x15b0c: tbz    w0, #0, #0x15b1c
0x15b10: mov    x0, xzr
0x15b14: bl     #0x2418 ; <fflush>
0x15b18: bl     #0x2428 ; <abort>
0x15b1c: mov    w0, #1
0x15b20: bl     #0x2438 ; <exit>
0x15b24: udf    #0
0x15b28: sub    sp, sp, #0x130
0x15b2c: stp    x28, x27, [sp, #0xd0]
0x15b30: stp    x26, x25, [sp, #0xe0]
0x15b34: stp    x24, x23, [sp, #0xf0]
0x15b38: stp    x22, x21, [sp, #0x100]
0x15b3c: stp    x20, x19, [sp, #0x110]
0x15b40: stp    x29, x30, [sp, #0x120]
0x15b44: add    x29, sp, #0x120
0x15b48: mrs    x22, tpidr_el0
0x15b4c: add    x23, sp, #0x28
0x15b50: ldr    x8, [x22, #0x28]
0x15b54: mov    x21, x0
0x15b58: mov    x20, x2
0x15b5c: adrp   x2, #0x1d000
0x15b60: adrp   x3, #0x1d000
0x15b64: str    x8, [x23]
0x15b68: mov    x19, x1
0x15b6c: ldr    x0, [x21, #0x48]
0x15b70: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15b74: add    x3, x3, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15b78: str    wzr, [sp, #0x44]
0x15b7c: mov    w1, #0x4de
0x15b80: mov    w4, #0x24e
0x15b84: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x15b88: cbz    x0, #0x15bcc
0x15b8c: ldr    w8, [x0, #4]
0x15b90: cbz    w8, #0x15bcc
0x15b94: cmp    w8, #9
0x15b98: b.ne   #0x1632c
0x15b9c: ldr    w8, [x0]
0x15ba0: cmp    w8, #6
0x15ba4: b.ne   #0x1632c
0x15ba8: mov    x8, xzr
0x15bac: ldr    x9, [x0, #8]
0x15bb0: ldr    s0, [x9, x8, lsl #2]
0x15bb4: fcvt   d0, s0
0x15bb8: str    d0, [x19, x8, lsl #3]
0x15bbc: add    x8, x8, #1 ; =0x1a001
0x15bc0: ldrsw  x9, [x0, #4]
0x15bc4: cmp    x8, x9
0x15bc8: b.lt   #0x15bac
0x15bcc: ldr    x0, [x21, #0x48]
0x15bd0: adrp   x2, #0x1d000
0x15bd4: adrp   x3, #0x1d000
0x15bd8: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15bdc: add    x3, x3, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15be0: mov    w1, #0x491
0x15be4: mov    w4, #0x257
0x15be8: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x15bec: mov    x21, x0
0x15bf0: cbz    x21, #0x15ccc
0x15bf4: add    x1, sp, #0x44
0x15bf8: mov    x0, x21
0x15bfc: bl     #0x27e8 ; <dcam_container_val_as_uint32>
0x15c00: ldr    w8, [x21]
0x15c04: cmp    w8, #4
0x15c08: b.ne   #0x15dbc
0x15c0c: ldr    w8, [sp, #0x44]
0x15c10: cmp    w8, #1
0x15c14: b.ne   #0x15ea0
0x15c18: ldr    w8, [x0]
0x15c1c: adrp   x0, #0x30000
0x15c20: adrp   x2, #0x1d000
0x15c24: str    x22, [sp, #0x20]
0x15c28: add    x0, x0, #0x100 ; =0x30100
0x15c2c: mov    w1, #5
0x15c30: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x15c34: str    w8, [x20]
0x15c38: bl     #0x2338 ; <log_mgr_check>
0x15c3c: tbz    w0, #0, #0x1612c
0x15c40: bl     #0x2348 ; <co_thread_get>
0x15c44: cbz    x0, #0x160dc
0x15c48: adrp   x8, #0x1a000
0x15c4c: str    wzr, [sp, #0x34]
0x15c50: add    x8, x8, #0x440 ; =0x1a440
0x15c54: add    x1, sp, #0x38
0x15c58: add    x2, sp, #0x34
0x15c5c: str    x8, [sp, #0x38]
0x15c60: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15c64: adrp   x4, #0x1d000
0x15c68: adrp   x5, #0x1d000
0x15c6c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15c70: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15c74: mov    w0, #0x51
0x15c78: mov    w6, #0x267
0x15c7c: mov    w1, #3
0x15c80: add    x2, sp, #0x48
0x15c84: mov    w3, #0x80
0x15c88: bl     #0x2368 ; <duss_log_gen_head>
0x15c8c: cbz    w0, #0x1612c
0x15c90: ldr    x6, [sp, #0x38]
0x15c94: adrp   x3, #0x1d000
0x15c98: ldr    w7, [sp, #0x34]
0x15c9c: adrp   x4, #0x1d000
0x15ca0: ldr    w8, [x20]
0x15ca4: adrp   x5, #0x1a000
0x15ca8: add    x3, x3, #0xd33 ; "%s: %s(%s_%x): color temp: %d
"
0x15cac: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x15cb0: add    x5, x5, #0x441 ; "co"
0x15cb4: mov    w0, #0x51
0x15cb8: str    w8, [sp]
0x15cbc: mov    w1, #3
0x15cc0: add    x2, sp, #0x48
0x15cc4: bl     #0x2378 ; <duss_log_print>
0x15cc8: b      #0x1612c
0x15ccc: adrp   x0, #0x30000
0x15cd0: adrp   x2, #0x1d000
0x15cd4: add    x0, x0, #0x100 ; =0x30100
0x15cd8: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x15cdc: mov    w1, #1
0x15ce0: bl     #0x2338 ; <log_mgr_check>
0x15ce4: tbz    w0, #0, #0x16034
0x15ce8: bl     #0x2348 ; <co_thread_get>
0x15cec: cbz    x0, #0x15f98
0x15cf0: adrp   x8, #0x1a000
0x15cf4: str    wzr, [sp, #0x34]
0x15cf8: add    x8, x8, #0x440 ; =0x1a440
0x15cfc: add    x1, sp, #0x38
0x15d00: add    x2, sp, #0x34
0x15d04: str    x8, [sp, #0x38]
0x15d08: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15d0c: adrp   x4, #0x1d000
0x15d10: adrp   x5, #0x1d000
0x15d14: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15d18: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15d1c: mov    w0, #0x51
0x15d20: mov    w6, #0x259
0x15d24: mov    w1, #1
0x15d28: add    x2, sp, #0x48
0x15d2c: mov    w3, #0x80
0x15d30: bl     #0x2368 ; <duss_log_gen_head>
0x15d34: cbz    w0, #0x15d5c
0x15d38: adrp   x3, #0x1a000
0x15d3c: adrp   x4, #0x1d000
0x15d40: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x15d44: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15d48: mov    w0, #0x51
0x15d4c: mov    w5, #0x259
0x15d50: mov    w1, #1
0x15d54: add    x2, sp, #0x48
0x15d58: bl     #0x2378 ; <duss_log_print>
0x15d5c: adrp   x4, #0x1d000
0x15d60: adrp   x5, #0x1d000
0x15d64: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15d68: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15d6c: mov    w0, #0x51
0x15d70: mov    w6, #0x259
0x15d74: mov    w1, #1
0x15d78: add    x2, sp, #0x48
0x15d7c: mov    w3, #0x80
0x15d80: bl     #0x2368 ; <duss_log_gen_head>
0x15d84: cbz    w0, #0x16034
0x15d88: ldr    x6, [sp, #0x38]
0x15d8c: adrp   x3, #0x1d000
0x15d90: ldr    w7, [sp, #0x34]
0x15d94: adrp   x4, #0x1d000
0x15d98: adrp   x5, #0x1a000
0x15d9c: add    x3, x3, #0xc0a ; "%s: %s(%s_%x): Get the DCAM_STATUS_EI_VALUE value failed!
"
0x15da0: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x15da4: add    x5, x5, #0x441 ; "co"
0x15da8: mov    w0, #0x51
0x15dac: mov    w1, #1
0x15db0: add    x2, sp, #0x48
0x15db4: bl     #0x2378 ; <duss_log_print>
0x15db8: b      #0x16034
0x15dbc: adrp   x0, #0x30000
0x15dc0: adrp   x2, #0x1d000
0x15dc4: add    x0, x0, #0x100 ; =0x30100
0x15dc8: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x15dcc: mov    w1, #1
0x15dd0: bl     #0x2338 ; <log_mgr_check>
0x15dd4: tbz    w0, #0, #0x162f4
0x15dd8: bl     #0x2348 ; <co_thread_get>
0x15ddc: cbz    x0, #0x1603c
0x15de0: adrp   x8, #0x1a000
0x15de4: str    wzr, [sp, #0x34]
0x15de8: add    x8, x8, #0x440 ; =0x1a440
0x15dec: add    x1, sp, #0x38
0x15df0: add    x2, sp, #0x34
0x15df4: str    x8, [sp, #0x38]
0x15df8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15dfc: adrp   x4, #0x1d000
0x15e00: adrp   x5, #0x1d000
0x15e04: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15e08: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15e0c: mov    w0, #0x51
0x15e10: mov    w6, #0x25f
0x15e14: mov    w1, #1
0x15e18: add    x2, sp, #0x48
0x15e1c: mov    w3, #0x80
0x15e20: bl     #0x2368 ; <duss_log_gen_head>
0x15e24: cbz    w0, #0x15e4c
0x15e28: adrp   x3, #0x1a000
0x15e2c: adrp   x4, #0x1d000
0x15e30: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x15e34: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15e38: mov    w0, #0x51
0x15e3c: mov    w5, #0x25f
0x15e40: mov    w1, #1
0x15e44: add    x2, sp, #0x48
0x15e48: bl     #0x2378 ; <duss_log_print>
0x15e4c: adrp   x4, #0x1d000
0x15e50: adrp   x5, #0x1d000
0x15e54: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15e58: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15e5c: mov    w0, #0x51
0x15e60: mov    w6, #0x25f
0x15e64: mov    w1, #1
0x15e68: add    x2, sp, #0x48
0x15e6c: mov    w3, #0x80
0x15e70: bl     #0x2368 ; <duss_log_gen_head>
0x15e74: cbz    w0, #0x162f4
0x15e78: ldr    x6, [sp, #0x38]
0x15e7c: adrp   x3, #0x1d000
0x15e80: ldr    w7, [sp, #0x34]
0x15e84: adrp   x4, #0x1d000
0x15e88: adrp   x5, #0x1a000
0x15e8c: add    x3, x3, #0xc75 ; "%s: %s(%s_%x): color temp: value type unexpected.
"
0x15e90: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x15e94: add    x5, x5, #0x441 ; "co"
0x15e98: mov    w0, #0x51
0x15e9c: b      #0x15f88
0x15ea0: adrp   x0, #0x30000
0x15ea4: adrp   x2, #0x1d000
0x15ea8: add    x0, x0, #0x100 ; =0x30100
0x15eac: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x15eb0: mov    w1, #1
0x15eb4: bl     #0x2338 ; <log_mgr_check>
0x15eb8: tbz    w0, #0, #0x162f4
0x15ebc: bl     #0x2348 ; <co_thread_get>
0x15ec0: cbz    x0, #0x16254
0x15ec4: adrp   x8, #0x1a000
0x15ec8: str    wzr, [sp, #0x34]
0x15ecc: add    x8, x8, #0x440 ; =0x1a440
0x15ed0: add    x1, sp, #0x38
0x15ed4: add    x2, sp, #0x34
0x15ed8: str    x8, [sp, #0x38]
0x15edc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x15ee0: adrp   x4, #0x1d000
0x15ee4: adrp   x5, #0x1d000
0x15ee8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15eec: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15ef0: mov    w0, #0x51
0x15ef4: mov    w6, #0x263
0x15ef8: mov    w1, #1
0x15efc: add    x2, sp, #0x48
0x15f00: mov    w3, #0x80
0x15f04: bl     #0x2368 ; <duss_log_gen_head>
0x15f08: cbz    w0, #0x15f30
0x15f0c: adrp   x3, #0x1a000
0x15f10: adrp   x4, #0x1d000
0x15f14: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x15f18: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15f1c: mov    w0, #0x51
0x15f20: mov    w5, #0x263
0x15f24: mov    w1, #1
0x15f28: add    x2, sp, #0x48
0x15f2c: bl     #0x2378 ; <duss_log_print>
0x15f30: adrp   x4, #0x1d000
0x15f34: adrp   x5, #0x1d000
0x15f38: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15f3c: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15f40: mov    w0, #0x51
0x15f44: mov    w6, #0x263
0x15f48: mov    w1, #1
0x15f4c: add    x2, sp, #0x48
0x15f50: mov    w3, #0x80
0x15f54: bl     #0x2368 ; <duss_log_gen_head>
0x15f58: cbz    w0, #0x162f4
0x15f5c: ldr    x6, [sp, #0x38]
0x15f60: adrp   x3, #0x1d000
0x15f64: ldr    w7, [sp, #0x34]
0x15f68: adrp   x4, #0x1d000
0x15f6c: ldr    w8, [sp, #0x44]
0x15f70: adrp   x5, #0x1a000
0x15f74: add    x3, x3, #0xcd0 ; "%s: %s(%s_%x): color temp: value count unexpected:%d.
"
0x15f78: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x15f7c: add    x5, x5, #0x441 ; "co"
0x15f80: mov    w0, #0x51
0x15f84: str    w8, [sp]
0x15f88: mov    w1, #1
0x15f8c: add    x2, sp, #0x48
0x15f90: bl     #0x2378 ; <duss_log_print>
0x15f94: b      #0x162f4
0x15f98: adrp   x4, #0x1d000
0x15f9c: adrp   x5, #0x1d000
0x15fa0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15fa4: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15fa8: mov    w0, #0x51
0x15fac: mov    w6, #0x259
0x15fb0: mov    w1, #1
0x15fb4: add    x2, sp, #0x48
0x15fb8: mov    w3, #0x80
0x15fbc: bl     #0x2368 ; <duss_log_gen_head>
0x15fc0: cbz    w0, #0x15fe8
0x15fc4: adrp   x3, #0x1a000
0x15fc8: adrp   x4, #0x1d000
0x15fcc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x15fd0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15fd4: mov    w0, #0x51
0x15fd8: mov    w5, #0x259
0x15fdc: mov    w1, #1
0x15fe0: add    x2, sp, #0x48
0x15fe4: bl     #0x2378 ; <duss_log_print>
0x15fe8: adrp   x4, #0x1d000
0x15fec: adrp   x5, #0x1d000
0x15ff0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x15ff4: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x15ff8: mov    w0, #0x51
0x15ffc: mov    w6, #0x259
0x16000: mov    w1, #1
0x16004: add    x2, sp, #0x48
0x16008: mov    w3, #0x80
0x1600c: bl     #0x2368 ; <duss_log_gen_head>
0x16010: cbz    w0, #0x16034
0x16014: adrp   x3, #0x1d000
0x16018: adrp   x4, #0x1d000
0x1601c: add    x3, x3, #0xc45 ; "%s: Get the DCAM_STATUS_EI_VALUE value failed!
"
0x16020: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16024: mov    w0, #0x51
0x16028: mov    w1, #1
0x1602c: add    x2, sp, #0x48
0x16030: bl     #0x2378 ; <duss_log_print>
0x16034: mov    w0, #-0x3e9
0x16038: b      #0x162f8
0x1603c: adrp   x4, #0x1d000
0x16040: adrp   x5, #0x1d000
0x16044: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16048: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x1604c: mov    w0, #0x51
0x16050: mov    w6, #0x25f
0x16054: mov    w1, #1
0x16058: add    x2, sp, #0x48
0x1605c: mov    w3, #0x80
0x16060: bl     #0x2368 ; <duss_log_gen_head>
0x16064: cbz    w0, #0x1608c
0x16068: adrp   x3, #0x1a000
0x1606c: adrp   x4, #0x1d000
0x16070: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16074: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16078: mov    w0, #0x51
0x1607c: mov    w5, #0x25f
0x16080: mov    w1, #1
0x16084: add    x2, sp, #0x48
0x16088: bl     #0x2378 ; <duss_log_print>
0x1608c: adrp   x4, #0x1d000
0x16090: adrp   x5, #0x1d000
0x16094: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16098: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x1609c: mov    w0, #0x51
0x160a0: mov    w6, #0x25f
0x160a4: mov    w1, #1
0x160a8: add    x2, sp, #0x48
0x160ac: mov    w3, #0x80
0x160b0: bl     #0x2368 ; <duss_log_gen_head>
0x160b4: cbz    w0, #0x162f4
0x160b8: adrp   x3, #0x1d000
0x160bc: adrp   x4, #0x1d000
0x160c0: add    x3, x3, #0xca8 ; "%s: color temp: value type unexpected.
"
0x160c4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x160c8: mov    w0, #0x51
0x160cc: mov    w1, #1
0x160d0: add    x2, sp, #0x48
0x160d4: bl     #0x2378 ; <duss_log_print>
0x160d8: b      #0x162f4
0x160dc: adrp   x4, #0x1d000
0x160e0: adrp   x5, #0x1d000
0x160e4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x160e8: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x160ec: mov    w0, #0x51
0x160f0: mov    w6, #0x267
0x160f4: mov    w1, #3
0x160f8: add    x2, sp, #0x48
0x160fc: mov    w3, #0x80
0x16100: bl     #0x2368 ; <duss_log_gen_head>
0x16104: cbz    w0, #0x1612c
0x16108: ldr    w5, [x20]
0x1610c: adrp   x3, #0x1d000
0x16110: adrp   x4, #0x1d000
0x16114: add    x3, x3, #0xd52 ; "%s: color temp: %d
"
0x16118: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1611c: mov    w0, #0x51
0x16120: mov    w1, #3
0x16124: add    x2, sp, #0x48
0x16128: bl     #0x2378 ; <duss_log_print>
0x1612c: adrp   x21, #0x30000
0x16130: adrp   x22, #0x1d000
0x16134: adrp   x24, #0x1d000
0x16138: adrp   x25, #0x1d000
0x1613c: adrp   x28, #0x1a000
0x16140: mov    x20, xzr
0x16144: add    x21, x21, #0x100 ; =0x30100
0x16148: add    x22, x22, #0xb1c ; "PRORESRAWMETA"
0x1614c: mov    w23, #5
0x16150: add    x24, x24, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16154: add    x25, x25, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x16158: mov    w26, #0x51
0x1615c: mov    w27, #0x269
0x16160: add    x28, x28, #0x440 ; =0x1a440
0x16164: mov    x0, x21
0x16168: mov    w1, w23
0x1616c: mov    x2, x22
0x16170: bl     #0x2338 ; <log_mgr_check>
0x16174: tbz    w0, #0, #0x16238
0x16178: bl     #0x2348 ; <co_thread_get>
0x1617c: cbz    x0, #0x161f0
0x16180: add    x1, sp, #0x38
0x16184: str    x28, [sp, #0x38]
0x16188: add    x2, sp, #0x34
0x1618c: str    wzr, [sp, #0x34]
0x16190: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x16194: mov    w1, #3
0x16198: add    x2, sp, #0x48
0x1619c: mov    w3, #0x80
0x161a0: mov    w0, w26
0x161a4: mov    x4, x24
0x161a8: mov    x5, x25
0x161ac: mov    w6, w27
0x161b0: bl     #0x2368 ; <duss_log_gen_head>
0x161b4: cbz    w0, #0x16238
0x161b8: ldr    x6, [sp, #0x38]
0x161bc: adrp   x3, #0x1d000
0x161c0: ldr    w7, [sp, #0x34]
0x161c4: adrp   x5, #0x1a000
0x161c8: ldr    d0, [x19, x20, lsl #3]
0x161cc: mov    w1, #3
0x161d0: add    x2, sp, #0x48
0x161d4: str    w20, [sp]
0x161d8: mov    w0, w26
0x161dc: add    x3, x3, #0xd66 ; "%s: %s(%s_%x): adj ccm[%d]:%lf
"
0x161e0: mov    x4, x22
0x161e4: add    x5, x5, #0x441 ; "co"
0x161e8: bl     #0x2378 ; <duss_log_print>
0x161ec: b      #0x16238
0x161f0: mov    w1, #3
0x161f4: add    x2, sp, #0x48
0x161f8: mov    w3, #0x80
0x161fc: mov    w0, w26
0x16200: mov    x4, x24
0x16204: mov    x5, x25
0x16208: mov    w6, w27
0x1620c: bl     #0x2368 ; <duss_log_gen_head>
0x16210: cbz    w0, #0x16238
0x16214: ldr    d0, [x19, x20, lsl #3]
0x16218: adrp   x3, #0x1d000
0x1621c: mov    w1, #3
0x16220: add    x2, sp, #0x48
0x16224: mov    w0, w26
0x16228: add    x3, x3, #0xd86 ; "%s: adj ccm[%d]:%lf
"
0x1622c: mov    x4, x22
0x16230: mov    w5, w20
0x16234: bl     #0x2378 ; <duss_log_print>
0x16238: add    x20, x20, #1 ; =0x1a001
0x1623c: cmp    x20, #9
0x16240: b.ne   #0x16164
0x16244: ldr    x22, [sp, #0x20]
0x16248: mov    w0, wzr
0x1624c: add    x23, sp, #0x28
0x16250: b      #0x162f8
0x16254: adrp   x4, #0x1d000
0x16258: adrp   x5, #0x1d000
0x1625c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16260: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x16264: mov    w0, #0x51
0x16268: mov    w6, #0x263
0x1626c: mov    w1, #1
0x16270: add    x2, sp, #0x48
0x16274: mov    w3, #0x80
0x16278: bl     #0x2368 ; <duss_log_gen_head>
0x1627c: cbz    w0, #0x162a4
0x16280: adrp   x3, #0x1a000
0x16284: adrp   x4, #0x1d000
0x16288: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x1628c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16290: mov    w0, #0x51
0x16294: mov    w5, #0x263
0x16298: mov    w1, #1
0x1629c: add    x2, sp, #0x48
0x162a0: bl     #0x2378 ; <duss_log_print>
0x162a4: adrp   x4, #0x1d000
0x162a8: adrp   x5, #0x1d000
0x162ac: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x162b0: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x162b4: mov    w0, #0x51
0x162b8: mov    w6, #0x263
0x162bc: mov    w1, #1
0x162c0: add    x2, sp, #0x48
0x162c4: mov    w3, #0x80
0x162c8: bl     #0x2368 ; <duss_log_gen_head>
0x162cc: cbz    w0, #0x162f4
0x162d0: ldr    w5, [sp, #0x44]
0x162d4: adrp   x3, #0x1d000
0x162d8: adrp   x4, #0x1d000
0x162dc: add    x3, x3, #0xd07 ; "%s: color temp: value count unexpected:%d.
"
0x162e0: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x162e4: mov    w0, #0x51
0x162e8: mov    w1, #1
0x162ec: add    x2, sp, #0x48
0x162f0: bl     #0x2378 ; <duss_log_print>
0x162f4: mov    w0, #-0x3eb
0x162f8: ldr    x8, [x22, #0x28]
0x162fc: ldr    x9, [x23]
0x16300: cmp    x8, x9
0x16304: b.ne   #0x16328
0x16308: ldp    x29, x30, [sp, #0x120]
0x1630c: ldp    x20, x19, [sp, #0x110]
0x16310: ldp    x22, x21, [sp, #0x100]
0x16314: ldp    x24, x23, [sp, #0xf0]
0x16318: ldp    x26, x25, [sp, #0xe0]
0x1631c: ldp    x28, x27, [sp, #0xd0]
0x16320: add    sp, sp, #0x130
0x16324: ret    
0x16328: bl     #0x23d8 ; <__stack_chk_fail>
0x1632c: bl     #0x2348 ; <co_thread_get>
0x16330: cbnz   x0, #0x16390
0x16334: adrp   x4, #0x1d000
0x16338: adrp   x5, #0x1d000
0x1633c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16340: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x16344: mov    w0, #0x51
0x16348: mov    w6, #0x250
0x1634c: add    x2, sp, #0x48
0x16350: mov    w3, #0x80
0x16354: mov    w1, wzr
0x16358: bl     #0x2368 ; <duss_log_gen_head>
0x1635c: cbz    w0, #0x16418
0x16360: adrp   x3, #0x1a000
0x16364: adrp   x4, #0x1d000
0x16368: adrp   x5, #0x1d000
0x1636c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x16370: add    x4, x4, #0xbd0 ; "DCAM_VAL_TYPE_FLOAT == val->val_type && 9 == val->ele_cnt"
0x16374: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16378: mov    w0, #0x51
0x1637c: mov    w6, #0x250
0x16380: add    x2, sp, #0x48
0x16384: mov    w1, wzr
0x16388: bl     #0x2378 ; <duss_log_print>
0x1638c: b      #0x16418
0x16390: adrp   x8, #0x1a000
0x16394: str    wzr, [sp, #0x34]
0x16398: add    x8, x8, #0x440 ; =0x1a440
0x1639c: add    x1, sp, #0x38
0x163a0: add    x2, sp, #0x34
0x163a4: str    x8, [sp, #0x38]
0x163a8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x163ac: adrp   x19, #0x1d000
0x163b0: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x163b4: adrp   x5, #0x1d000
0x163b8: mov    w20, #0x250
0x163bc: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x163c0: mov    w0, #0x51
0x163c4: add    x2, sp, #0x48
0x163c8: mov    w3, #0x80
0x163cc: mov    w1, wzr
0x163d0: mov    x4, x19
0x163d4: mov    w6, w20
0x163d8: bl     #0x2368 ; <duss_log_gen_head>
0x163dc: cbz    w0, #0x16418
0x163e0: ldr    x5, [sp, #0x38]
0x163e4: adrp   x3, #0x1a000
0x163e8: ldr    w6, [sp, #0x34]
0x163ec: adrp   x4, #0x1a000
0x163f0: adrp   x7, #0x1d000
0x163f4: str    w20, [sp, #8]
0x163f8: mov    w1, wzr
0x163fc: str    x19, [sp]
0x16400: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x16404: add    x4, x4, #0x441 ; "co"
0x16408: mov    w0, #0x51
0x1640c: add    x7, x7, #0xbd0 ; "DCAM_VAL_TYPE_FLOAT == val->val_type && 9 == val->ele_cnt"
0x16410: add    x2, sp, #0x48
0x16414: bl     #0x2378 ; <duss_log_print>
0x16418: adrp   x4, #0x1d000
0x1641c: adrp   x5, #0x1d000
0x16420: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16424: add    x5, x5, #0xbb1 ; "proresraw_ccm_cct_get_from_adj"
0x16428: mov    w0, #0x51
0x1642c: mov    w6, #0x250
0x16430: add    x2, sp, #0x48
0x16434: mov    w3, #0x80
0x16438: mov    w1, wzr
0x1643c: bl     #0x2368 ; <duss_log_gen_head>
0x16440: cbz    w0, #0x1645c
0x16444: adrp   x3, #0x1a000
0x16448: add    x3, x3, #0x550 ; "Assertion Comment: "
0x1644c: mov    w0, #0x51
0x16450: add    x2, sp, #0x48
0x16454: mov    w1, wzr
0x16458: bl     #0x2378 ; <duss_log_print>
0x1645c: adrp   x0, #0x1a000
0x16460: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x16464: bl     #0x23e8 ; <log_to_kmsg>
0x16468: adrp   x0, #0x1a000
0x1646c: add    x0, x0, #0x57f ; "Camera:	"
0x16470: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x16474: bl     #0x2408 ; <is_running_in_cam_sil>
0x16478: tbz    w0, #0, #0x16488
0x1647c: mov    x0, xzr
0x16480: bl     #0x2418 ; <fflush>
0x16484: bl     #0x2428 ; <abort>
0x16488: mov    w0, #1
0x1648c: bl     #0x2438 ; <exit>
0x16490: sub    sp, sp, #0xe0
0x16494: stp    x22, x21, [sp, #0xb0]
0x16498: stp    x20, x19, [sp, #0xc0]
0x1649c: stp    x29, x30, [sp, #0xd0]
0x164a0: add    x29, sp, #0xd0
0x164a4: mrs    x21, tpidr_el0
0x164a8: add    x22, sp, #8
0x164ac: ldr    x8, [x21, #0x28]
0x164b0: adrp   x2, #0x1d000
0x164b4: adrp   x3, #0x1d000
0x164b8: mov    x19, x1
0x164bc: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x164c0: str    x8, [x22]
0x164c4: add    x3, x3, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x164c8: ldr    x0, [x0, #0x48]
0x164cc: mov    w1, #0x4df
0x164d0: mov    w4, #0x276
0x164d4: str    wzr, [sp, #0x24]
0x164d8: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x164dc: mov    x20, x0
0x164e0: cbz    x20, #0x165b4
0x164e4: add    x1, sp, #0x24
0x164e8: mov    x0, x20
0x164ec: bl     #0x27f8 ; <dcam_container_val_as_float>
0x164f0: ldr    w8, [x20]
0x164f4: mov    x20, x0
0x164f8: cmp    w8, #6
0x164fc: b.ne   #0x166a4
0x16500: ldr    w8, [sp, #0x24]
0x16504: adrp   x0, #0x30000
0x16508: add    x0, x0, #0x100 ; =0x30100
0x1650c: cmp    w8, #1
0x16510: b.ne   #0x16788
0x16514: adrp   x2, #0x1d000
0x16518: mov    w1, #5
0x1651c: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x16520: bl     #0x2338 ; <log_mgr_check>
0x16524: tbz    w0, #0, #0x16a10
0x16528: bl     #0x2348 ; <co_thread_get>
0x1652c: cbz    x0, #0x169bc
0x16530: adrp   x8, #0x1a000
0x16534: str    wzr, [sp, #0x14]
0x16538: add    x8, x8, #0x440 ; =0x1a440
0x1653c: add    x1, sp, #0x18
0x16540: add    x2, sp, #0x14
0x16544: str    x8, [sp, #0x18]
0x16548: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1654c: adrp   x4, #0x1d000
0x16550: adrp   x5, #0x1d000
0x16554: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16558: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x1655c: mov    w0, #0x51
0x16560: mov    w6, #0x286
0x16564: mov    w1, #3
0x16568: add    x2, sp, #0x28
0x1656c: mov    w3, #0x80
0x16570: bl     #0x2368 ; <duss_log_gen_head>
0x16574: cbz    w0, #0x16a10
0x16578: ldr    s0, [x20]
0x1657c: adrp   x3, #0x1d000
0x16580: ldr    x6, [sp, #0x18]
0x16584: adrp   x4, #0x1d000
0x16588: ldr    w7, [sp, #0x14]
0x1658c: adrp   x5, #0x1a000
0x16590: add    x3, x3, #0xeec ; "%s: %s(%s_%x): gain factor %f
"
0x16594: fcvt   d0, s0
0x16598: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1659c: add    x5, x5, #0x441 ; "co"
0x165a0: mov    w0, #0x51
0x165a4: mov    w1, #3
0x165a8: add    x2, sp, #0x28
0x165ac: bl     #0x2378 ; <duss_log_print>
0x165b0: b      #0x16a10
0x165b4: adrp   x0, #0x30000
0x165b8: adrp   x2, #0x1d000
0x165bc: add    x0, x0, #0x100 ; =0x30100
0x165c0: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x165c4: mov    w1, #1
0x165c8: bl     #0x2338 ; <log_mgr_check>
0x165cc: tbz    w0, #0, #0x16914
0x165d0: bl     #0x2348 ; <co_thread_get>
0x165d4: cbz    x0, #0x16878
0x165d8: adrp   x8, #0x1a000
0x165dc: str    wzr, [sp, #0x14]
0x165e0: add    x8, x8, #0x440 ; =0x1a440
0x165e4: add    x1, sp, #0x18
0x165e8: add    x2, sp, #0x14
0x165ec: str    x8, [sp, #0x18]
0x165f0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x165f4: adrp   x4, #0x1d000
0x165f8: adrp   x5, #0x1d000
0x165fc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16600: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16604: mov    w0, #0x51
0x16608: mov    w6, #0x278
0x1660c: mov    w1, #1
0x16610: add    x2, sp, #0x28
0x16614: mov    w3, #0x80
0x16618: bl     #0x2368 ; <duss_log_gen_head>
0x1661c: cbz    w0, #0x16644
0x16620: adrp   x3, #0x1a000
0x16624: adrp   x4, #0x1d000
0x16628: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x1662c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16630: mov    w0, #0x51
0x16634: mov    w5, #0x278
0x16638: mov    w1, #1
0x1663c: add    x2, sp, #0x28
0x16640: bl     #0x2378 ; <duss_log_print>
0x16644: adrp   x4, #0x1d000
0x16648: adrp   x5, #0x1d000
0x1664c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16650: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16654: mov    w0, #0x51
0x16658: mov    w6, #0x278
0x1665c: mov    w1, #1
0x16660: add    x2, sp, #0x28
0x16664: mov    w3, #0x80
0x16668: bl     #0x2368 ; <duss_log_gen_head>
0x1666c: cbz    w0, #0x16914
0x16670: ldr    x6, [sp, #0x18]
0x16674: adrp   x3, #0x1d000
0x16678: ldr    w7, [sp, #0x14]
0x1667c: adrp   x4, #0x1d000
0x16680: adrp   x5, #0x1a000
0x16684: add    x3, x3, #0xdb9 ; "%s: %s(%s_%x): Get the DCAM_STATUS_GAIN_FACTOR value failed!
"
0x16688: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1668c: add    x5, x5, #0x441 ; "co"
0x16690: mov    w0, #0x51
0x16694: mov    w1, #1
0x16698: add    x2, sp, #0x28
0x1669c: bl     #0x2378 ; <duss_log_print>
0x166a0: b      #0x16914
0x166a4: adrp   x0, #0x30000
0x166a8: adrp   x2, #0x1d000
0x166ac: add    x0, x0, #0x100 ; =0x30100
0x166b0: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x166b4: mov    w1, #1
0x166b8: bl     #0x2338 ; <log_mgr_check>
0x166bc: tbz    w0, #0, #0x16ac0
0x166c0: bl     #0x2348 ; <co_thread_get>
0x166c4: cbz    x0, #0x1691c
0x166c8: adrp   x8, #0x1a000
0x166cc: str    wzr, [sp, #0x14]
0x166d0: add    x8, x8, #0x440 ; =0x1a440
0x166d4: add    x1, sp, #0x18
0x166d8: add    x2, sp, #0x14
0x166dc: str    x8, [sp, #0x18]
0x166e0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x166e4: adrp   x4, #0x1d000
0x166e8: adrp   x5, #0x1d000
0x166ec: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x166f0: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x166f4: mov    w0, #0x51
0x166f8: mov    w6, #0x27e
0x166fc: mov    w1, #1
0x16700: add    x2, sp, #0x28
0x16704: mov    w3, #0x80
0x16708: bl     #0x2368 ; <duss_log_gen_head>
0x1670c: cbz    w0, #0x16734
0x16710: adrp   x3, #0x1a000
0x16714: adrp   x4, #0x1d000
0x16718: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x1671c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16720: mov    w0, #0x51
0x16724: mov    w5, #0x27e
0x16728: mov    w1, #1
0x1672c: add    x2, sp, #0x28
0x16730: bl     #0x2378 ; <duss_log_print>
0x16734: adrp   x4, #0x1d000
0x16738: adrp   x5, #0x1d000
0x1673c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16740: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16744: mov    w0, #0x51
0x16748: mov    w6, #0x27e
0x1674c: mov    w1, #1
0x16750: add    x2, sp, #0x28
0x16754: mov    w3, #0x80
0x16758: bl     #0x2368 ; <duss_log_gen_head>
0x1675c: cbz    w0, #0x16ac0
0x16760: ldr    x6, [sp, #0x18]
0x16764: adrp   x3, #0x1d000
0x16768: ldr    w7, [sp, #0x14]
0x1676c: adrp   x4, #0x1d000
0x16770: adrp   x5, #0x1a000
0x16774: add    x3, x3, #0xe2a ; "%s: %s(%s_%x): gain factor: value type unexpected.
"
0x16778: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1677c: add    x5, x5, #0x441 ; "co"
0x16780: mov    w0, #0x51
0x16784: b      #0x16868
0x16788: adrp   x2, #0x1d000
0x1678c: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x16790: mov    w1, #1
0x16794: bl     #0x2338 ; <log_mgr_check>
0x16798: tbz    w0, #0, #0x16ac0
0x1679c: bl     #0x2348 ; <co_thread_get>
0x167a0: cbz    x0, #0x16a20
0x167a4: adrp   x8, #0x1a000
0x167a8: str    wzr, [sp, #0x14]
0x167ac: add    x8, x8, #0x440 ; =0x1a440
0x167b0: add    x1, sp, #0x18
0x167b4: add    x2, sp, #0x14
0x167b8: str    x8, [sp, #0x18]
0x167bc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x167c0: adrp   x4, #0x1d000
0x167c4: adrp   x5, #0x1d000
0x167c8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x167cc: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x167d0: mov    w0, #0x51
0x167d4: mov    w6, #0x282
0x167d8: mov    w1, #1
0x167dc: add    x2, sp, #0x28
0x167e0: mov    w3, #0x80
0x167e4: bl     #0x2368 ; <duss_log_gen_head>
0x167e8: cbz    w0, #0x16810
0x167ec: adrp   x3, #0x1a000
0x167f0: adrp   x4, #0x1d000
0x167f4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x167f8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x167fc: mov    w0, #0x51
0x16800: mov    w5, #0x282
0x16804: mov    w1, #1
0x16808: add    x2, sp, #0x28
0x1680c: bl     #0x2378 ; <duss_log_print>
0x16810: adrp   x4, #0x1d000
0x16814: adrp   x5, #0x1d000
0x16818: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1681c: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16820: mov    w0, #0x51
0x16824: mov    w6, #0x282
0x16828: mov    w1, #1
0x1682c: add    x2, sp, #0x28
0x16830: mov    w3, #0x80
0x16834: bl     #0x2368 ; <duss_log_gen_head>
0x16838: cbz    w0, #0x16ac0
0x1683c: ldr    x6, [sp, #0x18]
0x16840: adrp   x3, #0x1d000
0x16844: ldr    w7, [sp, #0x14]
0x16848: adrp   x4, #0x1d000
0x1684c: ldr    w8, [sp, #0x24]
0x16850: adrp   x5, #0x1a000
0x16854: add    x3, x3, #0xe87 ; "%s: %s(%s_%x): gain factor: value count unexpected:%d.
"
0x16858: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1685c: add    x5, x5, #0x441 ; "co"
0x16860: mov    w0, #0x51
0x16864: str    w8, [sp]
0x16868: mov    w1, #1
0x1686c: add    x2, sp, #0x28
0x16870: bl     #0x2378 ; <duss_log_print>
0x16874: b      #0x16ac0
0x16878: adrp   x4, #0x1d000
0x1687c: adrp   x5, #0x1d000
0x16880: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16884: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16888: mov    w0, #0x51
0x1688c: mov    w6, #0x278
0x16890: mov    w1, #1
0x16894: add    x2, sp, #0x28
0x16898: mov    w3, #0x80
0x1689c: bl     #0x2368 ; <duss_log_gen_head>
0x168a0: cbz    w0, #0x168c8
0x168a4: adrp   x3, #0x1a000
0x168a8: adrp   x4, #0x1d000
0x168ac: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x168b0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x168b4: mov    w0, #0x51
0x168b8: mov    w5, #0x278
0x168bc: mov    w1, #1
0x168c0: add    x2, sp, #0x28
0x168c4: bl     #0x2378 ; <duss_log_print>
0x168c8: adrp   x4, #0x1d000
0x168cc: adrp   x5, #0x1d000
0x168d0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x168d4: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x168d8: mov    w0, #0x51
0x168dc: mov    w6, #0x278
0x168e0: mov    w1, #1
0x168e4: add    x2, sp, #0x28
0x168e8: mov    w3, #0x80
0x168ec: bl     #0x2368 ; <duss_log_gen_head>
0x168f0: cbz    w0, #0x16914
0x168f4: adrp   x3, #0x1d000
0x168f8: adrp   x4, #0x1d000
0x168fc: add    x3, x3, #0xdf7 ; "%s: Get the DCAM_STATUS_GAIN_FACTOR value failed!
"
0x16900: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16904: mov    w0, #0x51
0x16908: mov    w1, #1
0x1690c: add    x2, sp, #0x28
0x16910: bl     #0x2378 ; <duss_log_print>
0x16914: mov    w0, #-0x3e9
0x16918: b      #0x16ac4
0x1691c: adrp   x4, #0x1d000
0x16920: adrp   x5, #0x1d000
0x16924: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16928: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x1692c: mov    w0, #0x51
0x16930: mov    w6, #0x27e
0x16934: mov    w1, #1
0x16938: add    x2, sp, #0x28
0x1693c: mov    w3, #0x80
0x16940: bl     #0x2368 ; <duss_log_gen_head>
0x16944: cbz    w0, #0x1696c
0x16948: adrp   x3, #0x1a000
0x1694c: adrp   x4, #0x1d000
0x16950: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16954: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16958: mov    w0, #0x51
0x1695c: mov    w5, #0x27e
0x16960: mov    w1, #1
0x16964: add    x2, sp, #0x28
0x16968: bl     #0x2378 ; <duss_log_print>
0x1696c: adrp   x4, #0x1d000
0x16970: adrp   x5, #0x1d000
0x16974: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16978: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x1697c: mov    w0, #0x51
0x16980: mov    w6, #0x27e
0x16984: mov    w1, #1
0x16988: add    x2, sp, #0x28
0x1698c: mov    w3, #0x80
0x16990: bl     #0x2368 ; <duss_log_gen_head>
0x16994: cbz    w0, #0x16ac0
0x16998: adrp   x3, #0x1d000
0x1699c: adrp   x4, #0x1d000
0x169a0: add    x3, x3, #0xe5e ; "%s: gain factor: value type unexpected.
"
0x169a4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x169a8: mov    w0, #0x51
0x169ac: mov    w1, #1
0x169b0: add    x2, sp, #0x28
0x169b4: bl     #0x2378 ; <duss_log_print>
0x169b8: b      #0x16ac0
0x169bc: adrp   x4, #0x1d000
0x169c0: adrp   x5, #0x1d000
0x169c4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x169c8: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x169cc: mov    w0, #0x51
0x169d0: mov    w6, #0x286
0x169d4: mov    w1, #3
0x169d8: add    x2, sp, #0x28
0x169dc: mov    w3, #0x80
0x169e0: bl     #0x2368 ; <duss_log_gen_head>
0x169e4: cbz    w0, #0x16a10
0x169e8: ldr    s0, [x20]
0x169ec: adrp   x3, #0x1d000
0x169f0: adrp   x4, #0x1d000
0x169f4: add    x3, x3, #0xf0b ; "%s: gain factor %f
"
0x169f8: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x169fc: fcvt   d0, s0
0x16a00: mov    w0, #0x51
0x16a04: mov    w1, #3
0x16a08: add    x2, sp, #0x28
0x16a0c: bl     #0x2378 ; <duss_log_print>
0x16a10: ldr    w8, [x20]
0x16a14: mov    w0, wzr
0x16a18: str    w8, [x19]
0x16a1c: b      #0x16ac4
0x16a20: adrp   x4, #0x1d000
0x16a24: adrp   x5, #0x1d000
0x16a28: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16a2c: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16a30: mov    w0, #0x51
0x16a34: mov    w6, #0x282
0x16a38: mov    w1, #1
0x16a3c: add    x2, sp, #0x28
0x16a40: mov    w3, #0x80
0x16a44: bl     #0x2368 ; <duss_log_gen_head>
0x16a48: cbz    w0, #0x16a70
0x16a4c: adrp   x3, #0x1a000
0x16a50: adrp   x4, #0x1d000
0x16a54: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16a58: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16a5c: mov    w0, #0x51
0x16a60: mov    w5, #0x282
0x16a64: mov    w1, #1
0x16a68: add    x2, sp, #0x28
0x16a6c: bl     #0x2378 ; <duss_log_print>
0x16a70: adrp   x4, #0x1d000
0x16a74: adrp   x5, #0x1d000
0x16a78: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16a7c: add    x5, x5, #0xd9b ; "proresraw_d_gain_get_from_adj"
0x16a80: mov    w0, #0x51
0x16a84: mov    w6, #0x282
0x16a88: mov    w1, #1
0x16a8c: add    x2, sp, #0x28
0x16a90: mov    w3, #0x80
0x16a94: bl     #0x2368 ; <duss_log_gen_head>
0x16a98: cbz    w0, #0x16ac0
0x16a9c: ldr    w5, [sp, #0x24]
0x16aa0: adrp   x3, #0x1d000
0x16aa4: adrp   x4, #0x1d000
0x16aa8: add    x3, x3, #0xebf ; "%s: gain factor: value count unexpected:%d.
"
0x16aac: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16ab0: mov    w0, #0x51
0x16ab4: mov    w1, #1
0x16ab8: add    x2, sp, #0x28
0x16abc: bl     #0x2378 ; <duss_log_print>
0x16ac0: mov    w0, #-0x3eb
0x16ac4: ldr    x8, [x21, #0x28]
0x16ac8: ldr    x9, [x22]
0x16acc: cmp    x8, x9
0x16ad0: b.ne   #0x16ae8
0x16ad4: ldp    x29, x30, [sp, #0xd0]
0x16ad8: ldp    x20, x19, [sp, #0xc0]
0x16adc: ldp    x22, x21, [sp, #0xb0]
0x16ae0: add    sp, sp, #0xe0
0x16ae4: ret    
0x16ae8: bl     #0x23d8 ; <__stack_chk_fail>
0x16aec: udf    #0
0x16af0: sub    sp, sp, #0x120
0x16af4: str    x28, [sp, #0xc0]
0x16af8: stp    x26, x25, [sp, #0xd0]
0x16afc: stp    x24, x23, [sp, #0xe0]
0x16b00: stp    x22, x21, [sp, #0xf0]
0x16b04: stp    x20, x19, [sp, #0x100]
0x16b08: stp    x29, x30, [sp, #0x110]
0x16b0c: add    x29, sp, #0x110
0x16b10: mrs    x25, tpidr_el0
0x16b14: add    x26, sp, #0x18
0x16b18: ldr    x8, [x25, #0x28]
0x16b1c: mov    x21, x0
0x16b20: mov    x20, x1
0x16b24: str    x8, [x26]
0x16b28: str    wzr, [sp, #0x30]
0x16b2c: cbz    x21, #0x17024
0x16b30: bl     #0x2808 ; <dcam_container_alloc>
0x16b34: mov    x19, x0
0x16b38: cbz    x19, #0x16c64
0x16b3c: adrp   x22, #0x1d000
0x16b40: adrp   x23, #0x1d000
0x16b44: add    x22, x22, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16b48: add    x23, x23, #0xf1f ; "proresraw_sensel_value_range_get"
0x16b4c: mov    w24, #0x4e0
0x16b50: mov    w6, #0x29c
0x16b54: add    x2, sp, #0x34
0x16b58: mov    w3, #1
0x16b5c: mov    x0, x19
0x16b60: mov    w1, w24
0x16b64: mov    x4, x22
0x16b68: mov    x5, x23
0x16b6c: bl     #0x2818 ; <dcam_container_set_as_uint16_inner>
0x16b70: ldr    x8, [x21, #0x2f8]
0x16b74: mov    x1, x19
0x16b78: ldr    x0, [x21, #0x280]
0x16b7c: blr    x8
0x16b80: mov    w4, #0x2a5
0x16b84: mov    x0, x19
0x16b88: mov    w1, w24
0x16b8c: mov    x2, x22
0x16b90: mov    x3, x23
0x16b94: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x16b98: ldr    w8, [x0]
0x16b9c: cmp    w8, #2
0x16ba0: b.ne   #0x16d54
0x16ba4: add    x1, sp, #0x30
0x16ba8: bl     #0x2548 ; <dcam_container_val_as_uint16>
0x16bac: ldrh   w8, [x0]
0x16bb0: adrp   x0, #0x30000
0x16bb4: adrp   x2, #0x1d000
0x16bb8: add    x0, x0, #0x100 ; =0x30100
0x16bbc: mov    w1, #5
0x16bc0: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x16bc4: strh   w8, [x20]
0x16bc8: bl     #0x2338 ; <log_mgr_check>
0x16bcc: tbz    w0, #0, #0x16f3c
0x16bd0: bl     #0x2348 ; <co_thread_get>
0x16bd4: cbz    x0, #0x16ee8
0x16bd8: adrp   x8, #0x1a000
0x16bdc: str    wzr, [sp, #0x24]
0x16be0: add    x8, x8, #0x440 ; =0x1a440
0x16be4: add    x1, sp, #0x28
0x16be8: add    x2, sp, #0x24
0x16bec: str    x8, [sp, #0x28]
0x16bf0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x16bf4: adrp   x4, #0x1d000
0x16bf8: adrp   x5, #0x1d000
0x16bfc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16c00: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16c04: mov    w0, #0x51
0x16c08: mov    w6, #0x2ae
0x16c0c: mov    w1, #3
0x16c10: add    x2, sp, #0x38
0x16c14: mov    w3, #0x80
0x16c18: bl     #0x2368 ; <duss_log_gen_head>
0x16c1c: cbz    w0, #0x16f3c
0x16c20: ldr    x6, [sp, #0x28]
0x16c24: adrp   x3, #0x1d000
0x16c28: ldr    w7, [sp, #0x24]
0x16c2c: adrp   x4, #0x1d000
0x16c30: ldrh   w8, [x20]
0x16c34: adrp   x5, #0x1a000
0x16c38: ldr    w9, [sp, #0x30]
0x16c3c: add    x3, x3, #0xff8 ; "%s: %s(%s_%x): sensel_value_range:%d %d
"
0x16c40: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16c44: add    x5, x5, #0x441 ; "co"
0x16c48: mov    w0, #0x51
0x16c4c: str    w8, [sp]
0x16c50: mov    w1, #3
0x16c54: str    w9, [sp, #8]
0x16c58: add    x2, sp, #0x38
0x16c5c: bl     #0x2378 ; <duss_log_print>
0x16c60: b      #0x16f3c
0x16c64: adrp   x0, #0x30000
0x16c68: adrp   x2, #0x1d000
0x16c6c: add    x0, x0, #0x100 ; =0x30100
0x16c70: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x16c74: mov    w1, #1
0x16c78: bl     #0x2338 ; <log_mgr_check>
0x16c7c: tbz    w0, #0, #0x16ee0
0x16c80: bl     #0x2348 ; <co_thread_get>
0x16c84: cbz    x0, #0x16e44
0x16c88: adrp   x8, #0x1a000
0x16c8c: str    wzr, [sp, #0x24]
0x16c90: add    x8, x8, #0x440 ; =0x1a440
0x16c94: add    x1, sp, #0x28
0x16c98: add    x2, sp, #0x24
0x16c9c: str    x8, [sp, #0x28]
0x16ca0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x16ca4: adrp   x4, #0x1d000
0x16ca8: adrp   x5, #0x1d000
0x16cac: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16cb0: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16cb4: mov    w0, #0x51
0x16cb8: mov    w6, #0x297
0x16cbc: mov    w1, #1
0x16cc0: add    x2, sp, #0x38
0x16cc4: mov    w3, #0x80
0x16cc8: bl     #0x2368 ; <duss_log_gen_head>
0x16ccc: cbz    w0, #0x16cf4
0x16cd0: adrp   x3, #0x1a000
0x16cd4: adrp   x4, #0x1d000
0x16cd8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16cdc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16ce0: mov    w0, #0x51
0x16ce4: mov    w5, #0x297
0x16ce8: mov    w1, #1
0x16cec: add    x2, sp, #0x38
0x16cf0: bl     #0x2378 ; <duss_log_print>
0x16cf4: adrp   x4, #0x1d000
0x16cf8: adrp   x5, #0x1d000
0x16cfc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16d00: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16d04: mov    w0, #0x51
0x16d08: mov    w6, #0x297
0x16d0c: mov    w1, #1
0x16d10: add    x2, sp, #0x38
0x16d14: mov    w3, #0x80
0x16d18: bl     #0x2368 ; <duss_log_gen_head>
0x16d1c: cbz    w0, #0x16ee0
0x16d20: ldr    x6, [sp, #0x28]
0x16d24: adrp   x3, #0x1d000
0x16d28: ldr    w7, [sp, #0x24]
0x16d2c: adrp   x4, #0x1d000
0x16d30: adrp   x5, #0x1a000
0x16d34: add    x3, x3, #0xf40 ; "%s: %s(%s_%x): dcam_container_alloc() fail
"
0x16d38: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16d3c: add    x5, x5, #0x441 ; "co"
0x16d40: mov    w0, #0x51
0x16d44: mov    w1, #1
0x16d48: add    x2, sp, #0x38
0x16d4c: bl     #0x2378 ; <duss_log_print>
0x16d50: b      #0x16ee0
0x16d54: adrp   x0, #0x30000
0x16d58: adrp   x2, #0x1d000
0x16d5c: add    x0, x0, #0x100 ; =0x30100
0x16d60: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x16d64: mov    w1, #1
0x16d68: bl     #0x2338 ; <log_mgr_check>
0x16d6c: tbz    w0, #0, #0x16fe8
0x16d70: bl     #0x2348 ; <co_thread_get>
0x16d74: cbz    x0, #0x16f4c
0x16d78: adrp   x8, #0x1a000
0x16d7c: str    wzr, [sp, #0x24]
0x16d80: add    x8, x8, #0x440 ; =0x1a440
0x16d84: add    x1, sp, #0x28
0x16d88: add    x2, sp, #0x24
0x16d8c: str    x8, [sp, #0x28]
0x16d90: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x16d94: adrp   x4, #0x1d000
0x16d98: adrp   x5, #0x1d000
0x16d9c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16da0: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16da4: mov    w0, #0x51
0x16da8: mov    w6, #0x2a7
0x16dac: mov    w1, #1
0x16db0: add    x2, sp, #0x38
0x16db4: mov    w3, #0x80
0x16db8: bl     #0x2368 ; <duss_log_gen_head>
0x16dbc: cbz    w0, #0x16de4
0x16dc0: adrp   x3, #0x1a000
0x16dc4: adrp   x4, #0x1d000
0x16dc8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16dcc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16dd0: mov    w0, #0x51
0x16dd4: mov    w5, #0x2a7
0x16dd8: mov    w1, #1
0x16ddc: add    x2, sp, #0x38
0x16de0: bl     #0x2378 ; <duss_log_print>
0x16de4: adrp   x4, #0x1d000
0x16de8: adrp   x5, #0x1d000
0x16dec: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16df0: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16df4: mov    w0, #0x51
0x16df8: mov    w6, #0x2a7
0x16dfc: mov    w1, #1
0x16e00: add    x2, sp, #0x38
0x16e04: mov    w3, #0x80
0x16e08: bl     #0x2368 ; <duss_log_gen_head>
0x16e0c: cbz    w0, #0x16fe8
0x16e10: ldr    x6, [sp, #0x28]
0x16e14: adrp   x3, #0x1d000
0x16e18: ldr    w7, [sp, #0x24]
0x16e1c: adrp   x4, #0x1d000
0x16e20: adrp   x5, #0x1a000
0x16e24: add    x3, x3, #0xf8d ; "%s: %s(%s_%x): sensel value range: value type unexpected.
"
0x16e28: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16e2c: add    x5, x5, #0x441 ; "co"
0x16e30: mov    w0, #0x51
0x16e34: mov    w1, #1
0x16e38: add    x2, sp, #0x38
0x16e3c: bl     #0x2378 ; <duss_log_print>
0x16e40: b      #0x16fe8
0x16e44: adrp   x4, #0x1d000
0x16e48: adrp   x5, #0x1d000
0x16e4c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16e50: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16e54: mov    w0, #0x51
0x16e58: mov    w6, #0x297
0x16e5c: mov    w1, #1
0x16e60: add    x2, sp, #0x38
0x16e64: mov    w3, #0x80
0x16e68: bl     #0x2368 ; <duss_log_gen_head>
0x16e6c: cbz    w0, #0x16e94
0x16e70: adrp   x3, #0x1a000
0x16e74: adrp   x4, #0x1d000
0x16e78: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16e7c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16e80: mov    w0, #0x51
0x16e84: mov    w5, #0x297
0x16e88: mov    w1, #1
0x16e8c: add    x2, sp, #0x38
0x16e90: bl     #0x2378 ; <duss_log_print>
0x16e94: adrp   x4, #0x1d000
0x16e98: adrp   x5, #0x1d000
0x16e9c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16ea0: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16ea4: mov    w0, #0x51
0x16ea8: mov    w6, #0x297
0x16eac: mov    w1, #1
0x16eb0: add    x2, sp, #0x38
0x16eb4: mov    w3, #0x80
0x16eb8: bl     #0x2368 ; <duss_log_gen_head>
0x16ebc: cbz    w0, #0x16ee0
0x16ec0: adrp   x3, #0x1d000
0x16ec4: adrp   x4, #0x1d000
0x16ec8: add    x3, x3, #0xf6c ; "%s: dcam_container_alloc() fail
"
0x16ecc: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16ed0: mov    w0, #0x51
0x16ed4: mov    w1, #1
0x16ed8: add    x2, sp, #0x38
0x16edc: bl     #0x2378 ; <duss_log_print>
0x16ee0: mov    w0, #-0x3ee
0x16ee4: b      #0x16ff4
0x16ee8: adrp   x4, #0x1d000
0x16eec: adrp   x5, #0x1d000
0x16ef0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16ef4: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16ef8: mov    w0, #0x51
0x16efc: mov    w6, #0x2ae
0x16f00: mov    w1, #3
0x16f04: add    x2, sp, #0x38
0x16f08: mov    w3, #0x80
0x16f0c: bl     #0x2368 ; <duss_log_gen_head>
0x16f10: cbz    w0, #0x16f3c
0x16f14: ldrh   w5, [x20]
0x16f18: adrp   x3, #0x1e000
0x16f1c: ldr    w6, [sp, #0x30]
0x16f20: adrp   x4, #0x1d000
0x16f24: add    x3, x3, #0x21 ; "%s: sensel_value_range:%d %d
"
0x16f28: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16f2c: mov    w0, #0x51
0x16f30: mov    w1, #3
0x16f34: add    x2, sp, #0x38
0x16f38: bl     #0x2378 ; <duss_log_print>
0x16f3c: mov    x0, x19
0x16f40: bl     #0x2828 ; <dcam_container_free>
0x16f44: mov    w0, wzr
0x16f48: b      #0x16ff4
0x16f4c: adrp   x4, #0x1d000
0x16f50: adrp   x5, #0x1d000
0x16f54: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16f58: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16f5c: mov    w0, #0x51
0x16f60: mov    w6, #0x2a7
0x16f64: mov    w1, #1
0x16f68: add    x2, sp, #0x38
0x16f6c: mov    w3, #0x80
0x16f70: bl     #0x2368 ; <duss_log_gen_head>
0x16f74: cbz    w0, #0x16f9c
0x16f78: adrp   x3, #0x1a000
0x16f7c: adrp   x4, #0x1d000
0x16f80: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x16f84: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16f88: mov    w0, #0x51
0x16f8c: mov    w5, #0x2a7
0x16f90: mov    w1, #1
0x16f94: add    x2, sp, #0x38
0x16f98: bl     #0x2378 ; <duss_log_print>
0x16f9c: adrp   x4, #0x1d000
0x16fa0: adrp   x5, #0x1d000
0x16fa4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x16fa8: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x16fac: mov    w0, #0x51
0x16fb0: mov    w6, #0x2a7
0x16fb4: mov    w1, #1
0x16fb8: add    x2, sp, #0x38
0x16fbc: mov    w3, #0x80
0x16fc0: bl     #0x2368 ; <duss_log_gen_head>
0x16fc4: cbz    w0, #0x16fe8
0x16fc8: adrp   x3, #0x1d000
0x16fcc: adrp   x4, #0x1d000
0x16fd0: add    x3, x3, #0xfc8 ; "%s: sensel value range: value type unexpected.
"
0x16fd4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x16fd8: mov    w0, #0x51
0x16fdc: mov    w1, #1
0x16fe0: add    x2, sp, #0x38
0x16fe4: bl     #0x2378 ; <duss_log_print>
0x16fe8: mov    x0, x19
0x16fec: bl     #0x2828 ; <dcam_container_free>
0x16ff0: mov    w0, #-0x3eb
0x16ff4: ldr    x8, [x25, #0x28]
0x16ff8: ldr    x9, [x26]
0x16ffc: cmp    x8, x9
0x17000: b.ne   #0x17088
0x17004: ldp    x29, x30, [sp, #0x110]
0x17008: ldp    x20, x19, [sp, #0x100]
0x1700c: ldp    x22, x21, [sp, #0xf0]
0x17010: ldp    x24, x23, [sp, #0xe0]
0x17014: ldp    x26, x25, [sp, #0xd0]
0x17018: ldr    x28, [sp, #0xc0]
0x1701c: add    sp, sp, #0x120
0x17020: ret    
0x17024: bl     #0x2348 ; <co_thread_get>
0x17028: cbnz   x0, #0x1708c
0x1702c: adrp   x4, #0x1d000
0x17030: adrp   x5, #0x1d000
0x17034: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17038: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x1703c: mov    w0, #0x51
0x17040: mov    w6, #0x293
0x17044: add    x2, sp, #0x38
0x17048: mov    w3, #0x80
0x1704c: mov    w1, wzr
0x17050: bl     #0x2368 ; <duss_log_gen_head>
0x17054: cbz    w0, #0x17114
0x17058: adrp   x3, #0x1a000
0x1705c: adrp   x4, #0x1a000
0x17060: adrp   x5, #0x1d000
0x17064: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x17068: add    x4, x4, #0x588 ; "config"
0x1706c: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17070: mov    w0, #0x51
0x17074: mov    w6, #0x293
0x17078: add    x2, sp, #0x38
0x1707c: mov    w1, wzr
0x17080: bl     #0x2378 ; <duss_log_print>
0x17084: b      #0x17114
0x17088: bl     #0x23d8 ; <__stack_chk_fail>
0x1708c: adrp   x8, #0x1a000
0x17090: str    wzr, [sp, #0x24]
0x17094: add    x8, x8, #0x440 ; =0x1a440
0x17098: add    x1, sp, #0x28
0x1709c: add    x2, sp, #0x24
0x170a0: str    x8, [sp, #0x28]
0x170a4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x170a8: adrp   x19, #0x1d000
0x170ac: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x170b0: adrp   x5, #0x1d000
0x170b4: mov    w20, #0x293
0x170b8: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x170bc: mov    w0, #0x51
0x170c0: add    x2, sp, #0x38
0x170c4: mov    w3, #0x80
0x170c8: mov    w1, wzr
0x170cc: mov    x4, x19
0x170d0: mov    w6, w20
0x170d4: bl     #0x2368 ; <duss_log_gen_head>
0x170d8: cbz    w0, #0x17114
0x170dc: ldr    x5, [sp, #0x28]
0x170e0: adrp   x3, #0x1a000
0x170e4: ldr    w6, [sp, #0x24]
0x170e8: adrp   x4, #0x1a000
0x170ec: adrp   x7, #0x1a000
0x170f0: str    w20, [sp, #8]
0x170f4: mov    w1, wzr
0x170f8: str    x19, [sp]
0x170fc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x17100: add    x4, x4, #0x441 ; "co"
0x17104: mov    w0, #0x51
0x17108: add    x7, x7, #0x588 ; "config"
0x1710c: add    x2, sp, #0x38
0x17110: bl     #0x2378 ; <duss_log_print>
0x17114: adrp   x4, #0x1d000
0x17118: adrp   x5, #0x1d000
0x1711c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17120: add    x5, x5, #0xf1f ; "proresraw_sensel_value_range_get"
0x17124: mov    w0, #0x51
0x17128: mov    w6, #0x293
0x1712c: add    x2, sp, #0x38
0x17130: mov    w3, #0x80
0x17134: mov    w1, wzr
0x17138: bl     #0x2368 ; <duss_log_gen_head>
0x1713c: cbz    w0, #0x17158
0x17140: adrp   x3, #0x1a000
0x17144: add    x3, x3, #0x550 ; "Assertion Comment: "
0x17148: mov    w0, #0x51
0x1714c: add    x2, sp, #0x38
0x17150: mov    w1, wzr
0x17154: bl     #0x2378 ; <duss_log_print>
0x17158: adrp   x0, #0x1a000
0x1715c: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x17160: bl     #0x23e8 ; <log_to_kmsg>
0x17164: adrp   x0, #0x1a000
0x17168: add    x0, x0, #0x57f ; "Camera:	"
0x1716c: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x17170: bl     #0x2408 ; <is_running_in_cam_sil>
0x17174: tbz    w0, #0, #0x17184
0x17178: mov    x0, xzr
0x1717c: bl     #0x2418 ; <fflush>
0x17180: bl     #0x2428 ; <abort>
0x17184: mov    w0, #1
0x17188: bl     #0x2438 ; <exit>
0x1718c: udf    #0
0x17190: sub    sp, sp, #0xe0
0x17194: stp    x22, x21, [sp, #0xb0]
0x17198: stp    x20, x19, [sp, #0xc0]
0x1719c: stp    x29, x30, [sp, #0xd0]
0x171a0: add    x29, sp, #0xd0
0x171a4: mrs    x22, tpidr_el0
0x171a8: mov    x21, x0
0x171ac: ldr    x8, [x22, #0x28]
0x171b0: mov    x19, x1
0x171b4: stur   x8, [x29, #-0x28]
0x171b8: str    wzr, [sp, #0x10]
0x171bc: cbz    x21, #0x189ec
0x171c0: ldr    x0, [x21, #0x48]
0x171c4: cbz    x0, #0x18a50
0x171c8: adrp   x2, #0x1d000
0x171cc: adrp   x3, #0x1e000
0x171d0: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x171d4: add    x3, x3, #0x3f ; "proresraw_d_gain_get"
0x171d8: mov    w1, #0x586
0x171dc: mov    w4, #0x321
0x171e0: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x171e4: mov    x20, x0
0x171e8: cbz    x20, #0x17374
0x171ec: add    x1, sp, #0x10
0x171f0: mov    x0, x20
0x171f4: bl     #0x27e8 ; <dcam_container_val_as_uint32>
0x171f8: ldr    w8, [x20]
0x171fc: cmp    w8, #4
0x17200: b.ne   #0x17464
0x17204: ldr    w8, [sp, #0x10]
0x17208: cmp    w8, #1
0x1720c: b.ne   #0x17548
0x17210: ldr    w8, [x0]
0x17214: cmp    w8, #1
0x17218: b.ne   #0x17640
0x1721c: ldr    x0, [x21, #0x48]
0x17220: str    wzr, [sp, #0x24]
0x17224: cbz    x0, #0x18c5c
0x17228: adrp   x2, #0x1d000
0x1722c: adrp   x3, #0x1e000
0x17230: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17234: add    x3, x3, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17238: mov    w1, #0x587
0x1723c: mov    w4, #0x2c0
0x17240: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x17244: mov    x20, x0
0x17248: cbz    x20, #0x178a0
0x1724c: add    x1, sp, #0x24
0x17250: mov    x0, x20
0x17254: bl     #0x27e8 ; <dcam_container_val_as_uint32>
0x17258: ldr    w8, [x20]
0x1725c: mov    x20, x0
0x17260: cmp    w8, #4
0x17264: b.ne   #0x17a44
0x17268: ldr    w8, [sp, #0x24]
0x1726c: cmp    w8, #1
0x17270: b.ne   #0x17bf4
0x17274: ldr    x0, [x21, #0x48]
0x17278: adrp   x2, #0x1d000
0x1727c: adrp   x3, #0x1e000
0x17280: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17284: add    x3, x3, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17288: mov    w1, #0x588
0x1728c: mov    w4, #0x2d0
0x17290: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x17294: mov    x21, x0
0x17298: cbz    x21, #0x17ea4
0x1729c: add    x1, sp, #0x24
0x172a0: mov    x0, x21
0x172a4: bl     #0x27e8 ; <dcam_container_val_as_uint32>
0x172a8: ldr    w8, [x21]
0x172ac: mov    x21, x0
0x172b0: cmp    w8, #4
0x172b4: b.ne   #0x18068
0x172b8: ldr    w8, [sp, #0x24]
0x172bc: adrp   x0, #0x30000
0x172c0: adrp   x2, #0x1d000
0x172c4: add    x0, x0, #0x100 ; =0x30100
0x172c8: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x172cc: cmp    w8, #1
0x172d0: b.ne   #0x18260
0x172d4: mov    w1, #4
0x172d8: bl     #0x2338 ; <log_mgr_check>
0x172dc: tbz    w0, #0, #0x18478
0x172e0: bl     #0x2348 ; <co_thread_get>
0x172e4: cbz    x0, #0x18424
0x172e8: adrp   x8, #0x1a000
0x172ec: str    wzr, [sp, #0x14]
0x172f0: add    x8, x8, #0x440 ; =0x1a440
0x172f4: add    x1, sp, #0x18
0x172f8: add    x2, sp, #0x14
0x172fc: str    x8, [sp, #0x18]
0x17300: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17304: adrp   x4, #0x1d000
0x17308: adrp   x5, #0x1e000
0x1730c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17310: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17314: mov    w0, #0x51
0x17318: mov    w6, #0x2e0
0x1731c: mov    w1, #4
0x17320: add    x2, sp, #0x28
0x17324: mov    w3, #0x80
0x17328: bl     #0x2368 ; <duss_log_gen_head>
0x1732c: cbz    w0, #0x18478
0x17330: ldr    x6, [sp, #0x18]
0x17334: adrp   x3, #0x1e000
0x17338: ldr    w7, [sp, #0x14]
0x1733c: adrp   x4, #0x1d000
0x17340: ldr    w8, [x21]
0x17344: adrp   x5, #0x1a000
0x17348: ldr    w9, [x20]
0x1734c: add    x3, x3, #0x59d ; "%s: %s(%s_%x): ei_gain %d, ei_value %d
"
0x17350: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x17354: add    x5, x5, #0x441 ; "co"
0x17358: mov    w0, #0x51
0x1735c: str    w8, [sp]
0x17360: mov    w1, #4
0x17364: str    w9, [sp, #8]
0x17368: add    x2, sp, #0x28
0x1736c: bl     #0x2378 ; <duss_log_print>
0x17370: b      #0x18478
0x17374: adrp   x0, #0x30000
0x17378: adrp   x2, #0x1d000
0x1737c: add    x0, x0, #0x100 ; =0x30100
0x17380: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17384: mov    w1, #1
0x17388: bl     #0x2338 ; <log_mgr_check>
0x1738c: tbz    w0, #0, #0x184d4
0x17390: bl     #0x2348 ; <co_thread_get>
0x17394: cbz    x0, #0x176bc
0x17398: adrp   x8, #0x1a000
0x1739c: str    wzr, [sp, #0x24]
0x173a0: add    x8, x8, #0x440 ; =0x1a440
0x173a4: add    x1, sp, #0x18
0x173a8: add    x2, sp, #0x24
0x173ac: str    x8, [sp, #0x18]
0x173b0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x173b4: adrp   x4, #0x1d000
0x173b8: adrp   x5, #0x1e000
0x173bc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x173c0: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x173c4: mov    w0, #0x51
0x173c8: mov    w6, #0x323
0x173cc: mov    w1, #1
0x173d0: add    x2, sp, #0x28
0x173d4: mov    w3, #0x80
0x173d8: bl     #0x2368 ; <duss_log_gen_head>
0x173dc: cbz    w0, #0x17404
0x173e0: adrp   x3, #0x1a000
0x173e4: adrp   x4, #0x1d000
0x173e8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x173ec: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x173f0: mov    w0, #0x51
0x173f4: mov    w5, #0x323
0x173f8: mov    w1, #1
0x173fc: add    x2, sp, #0x28
0x17400: bl     #0x2378 ; <duss_log_print>
0x17404: adrp   x4, #0x1d000
0x17408: adrp   x5, #0x1e000
0x1740c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17410: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x17414: mov    w0, #0x51
0x17418: mov    w6, #0x323
0x1741c: mov    w1, #1
0x17420: add    x2, sp, #0x28
0x17424: mov    w3, #0x80
0x17428: bl     #0x2368 ; <duss_log_gen_head>
0x1742c: cbz    w0, #0x184d4
0x17430: ldr    x6, [sp, #0x18]
0x17434: adrp   x3, #0x1d000
0x17438: ldr    w7, [sp, #0x24]
0x1743c: adrp   x4, #0x1d000
0x17440: adrp   x5, #0x1a000
0x17444: add    x3, x3, #0xc0a ; "%s: %s(%s_%x): Get the DCAM_STATUS_EI_VALUE value failed!
"
0x17448: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1744c: add    x5, x5, #0x441 ; "co"
0x17450: mov    w0, #0x51
0x17454: mov    w1, #1
0x17458: add    x2, sp, #0x28
0x1745c: bl     #0x2378 ; <duss_log_print>
0x17460: b      #0x184d4
0x17464: adrp   x0, #0x30000
0x17468: adrp   x2, #0x1d000
0x1746c: add    x0, x0, #0x100 ; =0x30100
0x17470: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17474: mov    w1, #1
0x17478: bl     #0x2338 ; <log_mgr_check>
0x1747c: tbz    w0, #0, #0x185ac
0x17480: bl     #0x2348 ; <co_thread_get>
0x17484: cbz    x0, #0x1775c
0x17488: adrp   x8, #0x1a000
0x1748c: str    wzr, [sp, #0x24]
0x17490: add    x8, x8, #0x440 ; =0x1a440
0x17494: add    x1, sp, #0x18
0x17498: add    x2, sp, #0x24
0x1749c: str    x8, [sp, #0x18]
0x174a0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x174a4: adrp   x4, #0x1d000
0x174a8: adrp   x5, #0x1e000
0x174ac: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x174b0: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x174b4: mov    w0, #0x51
0x174b8: mov    w6, #0x329
0x174bc: mov    w1, #1
0x174c0: add    x2, sp, #0x28
0x174c4: mov    w3, #0x80
0x174c8: bl     #0x2368 ; <duss_log_gen_head>
0x174cc: cbz    w0, #0x174f4
0x174d0: adrp   x3, #0x1a000
0x174d4: adrp   x4, #0x1d000
0x174d8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x174dc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x174e0: mov    w0, #0x51
0x174e4: mov    w5, #0x329
0x174e8: mov    w1, #1
0x174ec: add    x2, sp, #0x28
0x174f0: bl     #0x2378 ; <duss_log_print>
0x174f4: adrp   x4, #0x1d000
0x174f8: adrp   x5, #0x1e000
0x174fc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17500: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x17504: mov    w0, #0x51
0x17508: mov    w6, #0x329
0x1750c: mov    w1, #1
0x17510: add    x2, sp, #0x28
0x17514: mov    w3, #0x80
0x17518: bl     #0x2368 ; <duss_log_gen_head>
0x1751c: cbz    w0, #0x185ac
0x17520: ldr    x6, [sp, #0x18]
0x17524: adrp   x3, #0x1e000
0x17528: ldr    w7, [sp, #0x24]
0x1752c: adrp   x4, #0x1d000
0x17530: adrp   x5, #0x1a000
0x17534: add    x3, x3, #0x77 ; "%s: %s(%s_%x): ei_mode: value type unexpected.
"
0x17538: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1753c: add    x5, x5, #0x441 ; "co"
0x17540: mov    w0, #0x51
0x17544: b      #0x17630
0x17548: adrp   x0, #0x30000
0x1754c: adrp   x2, #0x1d000
0x17550: add    x0, x0, #0x100 ; =0x30100
0x17554: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17558: mov    w1, #1
0x1755c: bl     #0x2338 ; <log_mgr_check>
0x17560: tbz    w0, #0, #0x185ac
0x17564: bl     #0x2348 ; <co_thread_get>
0x17568: cbz    x0, #0x177fc
0x1756c: adrp   x8, #0x1a000
0x17570: str    wzr, [sp, #0x24]
0x17574: add    x8, x8, #0x440 ; =0x1a440
0x17578: add    x1, sp, #0x18
0x1757c: add    x2, sp, #0x24
0x17580: str    x8, [sp, #0x18]
0x17584: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17588: adrp   x4, #0x1d000
0x1758c: adrp   x5, #0x1e000
0x17590: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17594: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x17598: mov    w0, #0x51
0x1759c: mov    w6, #0x32d
0x175a0: mov    w1, #1
0x175a4: add    x2, sp, #0x28
0x175a8: mov    w3, #0x80
0x175ac: bl     #0x2368 ; <duss_log_gen_head>
0x175b0: cbz    w0, #0x175d8
0x175b4: adrp   x3, #0x1a000
0x175b8: adrp   x4, #0x1d000
0x175bc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x175c0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x175c4: mov    w0, #0x51
0x175c8: mov    w5, #0x32d
0x175cc: mov    w1, #1
0x175d0: add    x2, sp, #0x28
0x175d4: bl     #0x2378 ; <duss_log_print>
0x175d8: adrp   x4, #0x1d000
0x175dc: adrp   x5, #0x1e000
0x175e0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x175e4: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x175e8: mov    w0, #0x51
0x175ec: mov    w6, #0x32d
0x175f0: mov    w1, #1
0x175f4: add    x2, sp, #0x28
0x175f8: mov    w3, #0x80
0x175fc: bl     #0x2368 ; <duss_log_gen_head>
0x17600: cbz    w0, #0x185ac
0x17604: ldr    x6, [sp, #0x18]
0x17608: adrp   x3, #0x1e000
0x1760c: ldr    w7, [sp, #0x24]
0x17610: adrp   x4, #0x1d000
0x17614: ldr    w8, [sp, #0x10]
0x17618: adrp   x5, #0x1a000
0x1761c: add    x3, x3, #0xcc ; "%s: %s(%s_%x): ei_mode: value count unexpected:%d.
"
0x17620: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x17624: add    x5, x5, #0x441 ; "co"
0x17628: mov    w0, #0x51
0x1762c: str    w8, [sp]
0x17630: mov    w1, #1
0x17634: add    x2, sp, #0x28
0x17638: bl     #0x2378 ; <duss_log_print>
0x1763c: b      #0x185ac
0x17640: str    wzr, [sp, #0x24]
0x17644: cbz    x19, #0x18cc0
0x17648: ldr    x0, [x21, #0x48]
0x1764c: cbz    x0, #0x18d24
0x17650: adrp   x2, #0x1d000
0x17654: adrp   x3, #0x1e000
0x17658: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1765c: add    x3, x3, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17660: mov    w1, #0x425
0x17664: mov    w4, #0x302
0x17668: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x1766c: mov    x20, x0
0x17670: cbz    x20, #0x1796c
0x17674: add    x1, sp, #0x24
0x17678: mov    x0, x20
0x1767c: bl     #0x27e8 ; <dcam_container_val_as_uint32>
0x17680: ldr    w8, [x20]
0x17684: cmp    w8, #5
0x17688: b.ne   #0x17b1c
0x1768c: ldr    w8, [sp, #0x24]
0x17690: cmp    w8, #1
0x17694: b.ne   #0x17cd0
0x17698: ldr    s0, [x0]
0x1769c: adrp   x8, #0x1a000
0x176a0: mov    w0, wzr
0x176a4: ldr    d1, [x8, #0x1a8]
0x176a8: ucvtf  d0, d0
0x176ac: fmul   d0, d0, d1
0x176b0: fcvt   s0, d0
0x176b4: str    s0, [x19]
0x176b8: b      #0x185b0
0x176bc: adrp   x4, #0x1d000
0x176c0: adrp   x5, #0x1e000
0x176c4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x176c8: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x176cc: mov    w0, #0x51
0x176d0: mov    w6, #0x323
0x176d4: mov    w1, #1
0x176d8: add    x2, sp, #0x28
0x176dc: mov    w3, #0x80
0x176e0: bl     #0x2368 ; <duss_log_gen_head>
0x176e4: cbz    w0, #0x1770c
0x176e8: adrp   x3, #0x1a000
0x176ec: adrp   x4, #0x1d000
0x176f0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x176f4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x176f8: mov    w0, #0x51
0x176fc: mov    w5, #0x323
0x17700: mov    w1, #1
0x17704: add    x2, sp, #0x28
0x17708: bl     #0x2378 ; <duss_log_print>
0x1770c: adrp   x4, #0x1d000
0x17710: adrp   x5, #0x1e000
0x17714: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17718: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x1771c: mov    w0, #0x51
0x17720: mov    w6, #0x323
0x17724: mov    w1, #1
0x17728: add    x2, sp, #0x28
0x1772c: mov    w3, #0x80
0x17730: bl     #0x2368 ; <duss_log_gen_head>
0x17734: cbz    w0, #0x184d4
0x17738: adrp   x3, #0x1d000
0x1773c: adrp   x4, #0x1d000
0x17740: add    x3, x3, #0xc45 ; "%s: Get the DCAM_STATUS_EI_VALUE value failed!
"
0x17744: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x17748: mov    w0, #0x51
0x1774c: mov    w1, #1
0x17750: add    x2, sp, #0x28
0x17754: bl     #0x2378 ; <duss_log_print>
0x17758: b      #0x184d4
0x1775c: adrp   x4, #0x1d000
0x17760: adrp   x5, #0x1e000
0x17764: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17768: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x1776c: mov    w0, #0x51
0x17770: mov    w6, #0x329
0x17774: mov    w1, #1
0x17778: add    x2, sp, #0x28
0x1777c: mov    w3, #0x80
0x17780: bl     #0x2368 ; <duss_log_gen_head>
0x17784: cbz    w0, #0x177ac
0x17788: adrp   x3, #0x1a000
0x1778c: adrp   x4, #0x1d000
0x17790: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17794: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17798: mov    w0, #0x51
0x1779c: mov    w5, #0x329
0x177a0: mov    w1, #1
0x177a4: add    x2, sp, #0x28
0x177a8: bl     #0x2378 ; <duss_log_print>
0x177ac: adrp   x4, #0x1d000
0x177b0: adrp   x5, #0x1e000
0x177b4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x177b8: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x177bc: mov    w0, #0x51
0x177c0: mov    w6, #0x329
0x177c4: mov    w1, #1
0x177c8: add    x2, sp, #0x28
0x177cc: mov    w3, #0x80
0x177d0: bl     #0x2368 ; <duss_log_gen_head>
0x177d4: cbz    w0, #0x185ac
0x177d8: adrp   x3, #0x1e000
0x177dc: adrp   x4, #0x1d000
0x177e0: add    x3, x3, #0xa7 ; "%s: ei_mode: value type unexpected.
"
0x177e4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x177e8: mov    w0, #0x51
0x177ec: mov    w1, #1
0x177f0: add    x2, sp, #0x28
0x177f4: bl     #0x2378 ; <duss_log_print>
0x177f8: b      #0x185ac
0x177fc: adrp   x4, #0x1d000
0x17800: adrp   x5, #0x1e000
0x17804: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17808: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x1780c: mov    w0, #0x51
0x17810: mov    w6, #0x32d
0x17814: mov    w1, #1
0x17818: add    x2, sp, #0x28
0x1781c: mov    w3, #0x80
0x17820: bl     #0x2368 ; <duss_log_gen_head>
0x17824: cbz    w0, #0x1784c
0x17828: adrp   x3, #0x1a000
0x1782c: adrp   x4, #0x1d000
0x17830: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17834: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17838: mov    w0, #0x51
0x1783c: mov    w5, #0x32d
0x17840: mov    w1, #1
0x17844: add    x2, sp, #0x28
0x17848: bl     #0x2378 ; <duss_log_print>
0x1784c: adrp   x4, #0x1d000
0x17850: adrp   x5, #0x1e000
0x17854: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17858: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x1785c: mov    w0, #0x51
0x17860: mov    w6, #0x32d
0x17864: mov    w1, #1
0x17868: add    x2, sp, #0x28
0x1786c: mov    w3, #0x80
0x17870: bl     #0x2368 ; <duss_log_gen_head>
0x17874: cbz    w0, #0x185ac
0x17878: ldr    w5, [sp, #0x10]
0x1787c: adrp   x3, #0x1e000
0x17880: adrp   x4, #0x1d000
0x17884: add    x3, x3, #0x100 ; "%s: ei_mode: value count unexpected:%d.
"
0x17888: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1788c: mov    w0, #0x51
0x17890: mov    w1, #1
0x17894: add    x2, sp, #0x28
0x17898: bl     #0x2378 ; <duss_log_print>
0x1789c: b      #0x185ac
0x178a0: adrp   x0, #0x30000
0x178a4: adrp   x2, #0x1d000
0x178a8: add    x0, x0, #0x100 ; =0x30100
0x178ac: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x178b0: mov    w1, #1
0x178b4: bl     #0x2338 ; <log_mgr_check>
0x178b8: tbz    w0, #0, #0x184d4
0x178bc: bl     #0x2348 ; <co_thread_get>
0x178c0: cbz    x0, #0x17dac
0x178c4: adrp   x8, #0x1a000
0x178c8: str    wzr, [sp, #0x14]
0x178cc: add    x8, x8, #0x440 ; =0x1a440
0x178d0: add    x1, sp, #0x18
0x178d4: add    x2, sp, #0x14
0x178d8: str    x8, [sp, #0x18]
0x178dc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x178e0: adrp   x4, #0x1d000
0x178e4: adrp   x5, #0x1e000
0x178e8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x178ec: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x178f0: mov    w0, #0x51
0x178f4: mov    w6, #0x2c2
0x178f8: mov    w1, #1
0x178fc: add    x2, sp, #0x28
0x17900: mov    w3, #0x80
0x17904: bl     #0x2368 ; <duss_log_gen_head>
0x17908: cbz    w0, #0x17930
0x1790c: adrp   x3, #0x1a000
0x17910: adrp   x4, #0x1d000
0x17914: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17918: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1791c: mov    w0, #0x51
0x17920: mov    w5, #0x2c2
0x17924: mov    w1, #1
0x17928: add    x2, sp, #0x28
0x1792c: bl     #0x2378 ; <duss_log_print>
0x17930: adrp   x4, #0x1d000
0x17934: adrp   x5, #0x1e000
0x17938: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1793c: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17940: mov    w0, #0x51
0x17944: mov    w6, #0x2c2
0x17948: mov    w1, #1
0x1794c: add    x2, sp, #0x28
0x17950: mov    w3, #0x80
0x17954: bl     #0x2368 ; <duss_log_gen_head>
0x17958: cbz    w0, #0x184d4
0x1795c: ldr    x6, [sp, #0x18]
0x17960: adrp   x3, #0x1d000
0x17964: ldr    w7, [sp, #0x14]
0x17968: b      #0x1743c
0x1796c: adrp   x0, #0x30000
0x17970: adrp   x2, #0x1d000
0x17974: add    x0, x0, #0x100 ; =0x30100
0x17978: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x1797c: mov    w1, #1
0x17980: bl     #0x2338 ; <log_mgr_check>
0x17984: tbz    w0, #0, #0x184d4
0x17988: bl     #0x2348 ; <co_thread_get>
0x1798c: cbz    x0, #0x17e18
0x17990: adrp   x8, #0x1a000
0x17994: str    wzr, [sp, #0x14]
0x17998: add    x8, x8, #0x440 ; =0x1a440
0x1799c: add    x1, sp, #0x18
0x179a0: add    x2, sp, #0x14
0x179a4: str    x8, [sp, #0x18]
0x179a8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x179ac: adrp   x4, #0x1d000
0x179b0: adrp   x5, #0x1e000
0x179b4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x179b8: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x179bc: mov    w0, #0x51
0x179c0: mov    w6, #0x304
0x179c4: mov    w1, #1
0x179c8: add    x2, sp, #0x28
0x179cc: mov    w3, #0x80
0x179d0: bl     #0x2368 ; <duss_log_gen_head>
0x179d4: cbz    w0, #0x179fc
0x179d8: adrp   x3, #0x1a000
0x179dc: adrp   x4, #0x1d000
0x179e0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x179e4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x179e8: mov    w0, #0x51
0x179ec: mov    w5, #0x304
0x179f0: mov    w1, #1
0x179f4: add    x2, sp, #0x28
0x179f8: bl     #0x2378 ; <duss_log_print>
0x179fc: adrp   x4, #0x1d000
0x17a00: adrp   x5, #0x1e000
0x17a04: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17a08: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17a0c: mov    w0, #0x51
0x17a10: mov    w6, #0x304
0x17a14: mov    w1, #1
0x17a18: add    x2, sp, #0x28
0x17a1c: mov    w3, #0x80
0x17a20: bl     #0x2368 ; <duss_log_gen_head>
0x17a24: cbz    w0, #0x184d4
0x17a28: ldr    x6, [sp, #0x18]
0x17a2c: adrp   x3, #0x1e000
0x17a30: ldr    w7, [sp, #0x14]
0x17a34: adrp   x4, #0x1d000
0x17a38: adrp   x5, #0x1a000
0x17a3c: add    x3, x3, #0x608 ; "%s: %s(%s_%x): Get the digital gain value failed!
"
0x17a40: b      #0x17448
0x17a44: adrp   x0, #0x30000
0x17a48: adrp   x2, #0x1d000
0x17a4c: add    x0, x0, #0x100 ; =0x30100
0x17a50: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17a54: mov    w1, #1
0x17a58: bl     #0x2338 ; <log_mgr_check>
0x17a5c: tbz    w0, #0, #0x185ac
0x17a60: bl     #0x2348 ; <co_thread_get>
0x17a64: cbz    x0, #0x17f50
0x17a68: adrp   x8, #0x1a000
0x17a6c: str    wzr, [sp, #0x14]
0x17a70: add    x8, x8, #0x440 ; =0x1a440
0x17a74: add    x1, sp, #0x18
0x17a78: add    x2, sp, #0x14
0x17a7c: str    x8, [sp, #0x18]
0x17a80: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17a84: adrp   x4, #0x1d000
0x17a88: adrp   x5, #0x1e000
0x17a8c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17a90: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17a94: mov    w0, #0x51
0x17a98: mov    w6, #0x2c8
0x17a9c: mov    w1, #1
0x17aa0: add    x2, sp, #0x28
0x17aa4: mov    w3, #0x80
0x17aa8: bl     #0x2368 ; <duss_log_gen_head>
0x17aac: cbz    w0, #0x17ad4
0x17ab0: adrp   x3, #0x1a000
0x17ab4: adrp   x4, #0x1d000
0x17ab8: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17abc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17ac0: mov    w0, #0x51
0x17ac4: mov    w5, #0x2c8
0x17ac8: mov    w1, #1
0x17acc: add    x2, sp, #0x28
0x17ad0: bl     #0x2378 ; <duss_log_print>
0x17ad4: adrp   x4, #0x1d000
0x17ad8: adrp   x5, #0x1e000
0x17adc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17ae0: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17ae4: mov    w0, #0x51
0x17ae8: mov    w6, #0x2c8
0x17aec: mov    w1, #1
0x17af0: add    x2, sp, #0x28
0x17af4: mov    w3, #0x80
0x17af8: bl     #0x2368 ; <duss_log_gen_head>
0x17afc: cbz    w0, #0x185ac
0x17b00: ldr    x6, [sp, #0x18]
0x17b04: adrp   x3, #0x1e000
0x17b08: ldr    w7, [sp, #0x14]
0x17b0c: adrp   x4, #0x1d000
0x17b10: adrp   x5, #0x1a000
0x17b14: add    x3, x3, #0x435 ; "%s: %s(%s_%x): ei_value: value type unexpected.
"
0x17b18: b      #0x17538
0x17b1c: adrp   x0, #0x30000
0x17b20: adrp   x2, #0x1d000
0x17b24: add    x0, x0, #0x100 ; =0x30100
0x17b28: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17b2c: mov    w1, #1
0x17b30: bl     #0x2338 ; <log_mgr_check>
0x17b34: tbz    w0, #0, #0x185ac
0x17b38: bl     #0x2348 ; <co_thread_get>
0x17b3c: cbz    x0, #0x17fdc
0x17b40: adrp   x8, #0x1a000
0x17b44: str    wzr, [sp, #0x14]
0x17b48: add    x8, x8, #0x440 ; =0x1a440
0x17b4c: add    x1, sp, #0x18
0x17b50: add    x2, sp, #0x14
0x17b54: str    x8, [sp, #0x18]
0x17b58: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17b5c: adrp   x4, #0x1d000
0x17b60: adrp   x5, #0x1e000
0x17b64: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17b68: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17b6c: mov    w0, #0x51
0x17b70: mov    w6, #0x30a
0x17b74: mov    w1, #1
0x17b78: add    x2, sp, #0x28
0x17b7c: mov    w3, #0x80
0x17b80: bl     #0x2368 ; <duss_log_gen_head>
0x17b84: cbz    w0, #0x17bac
0x17b88: adrp   x3, #0x1a000
0x17b8c: adrp   x4, #0x1d000
0x17b90: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17b94: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17b98: mov    w0, #0x51
0x17b9c: mov    w5, #0x30a
0x17ba0: mov    w1, #1
0x17ba4: add    x2, sp, #0x28
0x17ba8: bl     #0x2378 ; <duss_log_print>
0x17bac: adrp   x4, #0x1d000
0x17bb0: adrp   x5, #0x1e000
0x17bb4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17bb8: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17bbc: mov    w0, #0x51
0x17bc0: mov    w6, #0x30a
0x17bc4: mov    w1, #1
0x17bc8: add    x2, sp, #0x28
0x17bcc: mov    w3, #0x80
0x17bd0: bl     #0x2368 ; <duss_log_gen_head>
0x17bd4: cbz    w0, #0x185ac
0x17bd8: ldr    x6, [sp, #0x18]
0x17bdc: adrp   x3, #0x1e000
0x17be0: ldr    w7, [sp, #0x14]
0x17be4: adrp   x4, #0x1d000
0x17be8: adrp   x5, #0x1a000
0x17bec: add    x3, x3, #0x663 ; "%s: %s(%s_%x): dgain: value type unexpected.
"
0x17bf0: b      #0x17538
0x17bf4: adrp   x0, #0x30000
0x17bf8: adrp   x2, #0x1d000
0x17bfc: add    x0, x0, #0x100 ; =0x30100
0x17c00: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17c04: mov    w1, #1
0x17c08: bl     #0x2338 ; <log_mgr_check>
0x17c0c: tbz    w0, #0, #0x185ac
0x17c10: bl     #0x2348 ; <co_thread_get>
0x17c14: cbz    x0, #0x18140
0x17c18: adrp   x8, #0x1a000
0x17c1c: str    wzr, [sp, #0x14]
0x17c20: add    x8, x8, #0x440 ; =0x1a440
0x17c24: add    x1, sp, #0x18
0x17c28: add    x2, sp, #0x14
0x17c2c: str    x8, [sp, #0x18]
0x17c30: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17c34: adrp   x4, #0x1d000
0x17c38: adrp   x5, #0x1e000
0x17c3c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17c40: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17c44: mov    w0, #0x51
0x17c48: mov    w6, #0x2cc
0x17c4c: mov    w1, #1
0x17c50: add    x2, sp, #0x28
0x17c54: mov    w3, #0x80
0x17c58: bl     #0x2368 ; <duss_log_gen_head>
0x17c5c: cbz    w0, #0x17c84
0x17c60: adrp   x3, #0x1a000
0x17c64: adrp   x4, #0x1d000
0x17c68: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17c6c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17c70: mov    w0, #0x51
0x17c74: mov    w5, #0x2cc
0x17c78: mov    w1, #1
0x17c7c: add    x2, sp, #0x28
0x17c80: bl     #0x2378 ; <duss_log_print>
0x17c84: adrp   x4, #0x1d000
0x17c88: adrp   x5, #0x1e000
0x17c8c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17c90: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17c94: mov    w0, #0x51
0x17c98: mov    w6, #0x2cc
0x17c9c: mov    w1, #1
0x17ca0: add    x2, sp, #0x28
0x17ca4: mov    w3, #0x80
0x17ca8: bl     #0x2368 ; <duss_log_gen_head>
0x17cac: cbz    w0, #0x185ac
0x17cb0: ldr    x6, [sp, #0x18]
0x17cb4: adrp   x3, #0x1e000
0x17cb8: ldr    w7, [sp, #0x14]
0x17cbc: adrp   x4, #0x1d000
0x17cc0: ldr    w8, [sp, #0x24]
0x17cc4: adrp   x5, #0x1a000
0x17cc8: add    x3, x3, #0x48c ; "%s: %s(%s_%x): ei_value: value count unexpected:%d.
"
0x17ccc: b      #0x17620
0x17cd0: adrp   x0, #0x30000
0x17cd4: adrp   x2, #0x1d000
0x17cd8: add    x0, x0, #0x100 ; =0x30100
0x17cdc: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17ce0: mov    w1, #1
0x17ce4: bl     #0x2338 ; <log_mgr_check>
0x17ce8: tbz    w0, #0, #0x185ac
0x17cec: bl     #0x2348 ; <co_thread_get>
0x17cf0: cbz    x0, #0x181d0
0x17cf4: adrp   x8, #0x1a000
0x17cf8: str    wzr, [sp, #0x14]
0x17cfc: add    x8, x8, #0x440 ; =0x1a440
0x17d00: add    x1, sp, #0x18
0x17d04: add    x2, sp, #0x14
0x17d08: str    x8, [sp, #0x18]
0x17d0c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17d10: adrp   x4, #0x1d000
0x17d14: adrp   x5, #0x1e000
0x17d18: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17d1c: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17d20: mov    w0, #0x51
0x17d24: mov    w6, #0x30e
0x17d28: mov    w1, #1
0x17d2c: add    x2, sp, #0x28
0x17d30: mov    w3, #0x80
0x17d34: bl     #0x2368 ; <duss_log_gen_head>
0x17d38: cbz    w0, #0x17d60
0x17d3c: adrp   x3, #0x1a000
0x17d40: adrp   x4, #0x1d000
0x17d44: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17d48: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17d4c: mov    w0, #0x51
0x17d50: mov    w5, #0x30e
0x17d54: mov    w1, #1
0x17d58: add    x2, sp, #0x28
0x17d5c: bl     #0x2378 ; <duss_log_print>
0x17d60: adrp   x4, #0x1d000
0x17d64: adrp   x5, #0x1e000
0x17d68: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17d6c: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17d70: mov    w0, #0x51
0x17d74: mov    w6, #0x30e
0x17d78: mov    w1, #1
0x17d7c: add    x2, sp, #0x28
0x17d80: mov    w3, #0x80
0x17d84: bl     #0x2368 ; <duss_log_gen_head>
0x17d88: cbz    w0, #0x185ac
0x17d8c: ldr    x6, [sp, #0x18]
0x17d90: adrp   x3, #0x1e000
0x17d94: ldr    w7, [sp, #0x14]
0x17d98: adrp   x4, #0x1d000
0x17d9c: ldr    w8, [sp, #0x24]
0x17da0: adrp   x5, #0x1a000
0x17da4: add    x3, x3, #0x6b4 ; "%s: %s(%s_%x): dgain: value count unexpected:%d.
"
0x17da8: b      #0x17620
0x17dac: adrp   x4, #0x1d000
0x17db0: adrp   x5, #0x1e000
0x17db4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17db8: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17dbc: mov    w0, #0x51
0x17dc0: mov    w6, #0x2c2
0x17dc4: mov    w1, #1
0x17dc8: add    x2, sp, #0x28
0x17dcc: mov    w3, #0x80
0x17dd0: bl     #0x2368 ; <duss_log_gen_head>
0x17dd4: cbz    w0, #0x17dfc
0x17dd8: adrp   x3, #0x1a000
0x17ddc: adrp   x4, #0x1d000
0x17de0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17de4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17de8: mov    w0, #0x51
0x17dec: mov    w5, #0x2c2
0x17df0: mov    w1, #1
0x17df4: add    x2, sp, #0x28
0x17df8: bl     #0x2378 ; <duss_log_print>
0x17dfc: adrp   x4, #0x1d000
0x17e00: adrp   x5, #0x1e000
0x17e04: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17e08: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17e0c: mov    w0, #0x51
0x17e10: mov    w6, #0x2c2
0x17e14: b      #0x17724
0x17e18: adrp   x4, #0x1d000
0x17e1c: adrp   x5, #0x1e000
0x17e20: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17e24: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17e28: mov    w0, #0x51
0x17e2c: mov    w6, #0x304
0x17e30: mov    w1, #1
0x17e34: add    x2, sp, #0x28
0x17e38: mov    w3, #0x80
0x17e3c: bl     #0x2368 ; <duss_log_gen_head>
0x17e40: cbz    w0, #0x17e68
0x17e44: adrp   x3, #0x1a000
0x17e48: adrp   x4, #0x1d000
0x17e4c: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17e50: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17e54: mov    w0, #0x51
0x17e58: mov    w5, #0x304
0x17e5c: mov    w1, #1
0x17e60: add    x2, sp, #0x28
0x17e64: bl     #0x2378 ; <duss_log_print>
0x17e68: adrp   x4, #0x1d000
0x17e6c: adrp   x5, #0x1e000
0x17e70: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17e74: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17e78: mov    w0, #0x51
0x17e7c: mov    w6, #0x304
0x17e80: mov    w1, #1
0x17e84: add    x2, sp, #0x28
0x17e88: mov    w3, #0x80
0x17e8c: bl     #0x2368 ; <duss_log_gen_head>
0x17e90: cbz    w0, #0x184d4
0x17e94: adrp   x3, #0x1e000
0x17e98: adrp   x4, #0x1d000
0x17e9c: add    x3, x3, #0x63b ; "%s: Get the digital gain value failed!
"
0x17ea0: b      #0x17744
0x17ea4: adrp   x0, #0x30000
0x17ea8: adrp   x2, #0x1d000
0x17eac: add    x0, x0, #0x100 ; =0x30100
0x17eb0: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x17eb4: mov    w1, #1
0x17eb8: bl     #0x2338 ; <log_mgr_check>
0x17ebc: tbz    w0, #0, #0x184d4
0x17ec0: bl     #0x2348 ; <co_thread_get>
0x17ec4: cbz    x0, #0x1832c
0x17ec8: adrp   x8, #0x1a000
0x17ecc: str    wzr, [sp, #0x14]
0x17ed0: add    x8, x8, #0x440 ; =0x1a440
0x17ed4: add    x1, sp, #0x18
0x17ed8: add    x2, sp, #0x14
0x17edc: str    x8, [sp, #0x18]
0x17ee0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x17ee4: adrp   x4, #0x1d000
0x17ee8: adrp   x5, #0x1e000
0x17eec: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17ef0: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17ef4: mov    w0, #0x51
0x17ef8: mov    w6, #0x2d2
0x17efc: mov    w1, #1
0x17f00: add    x2, sp, #0x28
0x17f04: mov    w3, #0x80
0x17f08: bl     #0x2368 ; <duss_log_gen_head>
0x17f0c: cbz    w0, #0x17f34
0x17f10: adrp   x3, #0x1a000
0x17f14: adrp   x4, #0x1d000
0x17f18: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17f1c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17f20: mov    w0, #0x51
0x17f24: mov    w5, #0x2d2
0x17f28: mov    w1, #1
0x17f2c: add    x2, sp, #0x28
0x17f30: bl     #0x2378 ; <duss_log_print>
0x17f34: adrp   x4, #0x1d000
0x17f38: adrp   x5, #0x1e000
0x17f3c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17f40: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17f44: mov    w0, #0x51
0x17f48: mov    w6, #0x2d2
0x17f4c: b      #0x17948
0x17f50: adrp   x4, #0x1d000
0x17f54: adrp   x5, #0x1e000
0x17f58: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17f5c: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17f60: mov    w0, #0x51
0x17f64: mov    w6, #0x2c8
0x17f68: mov    w1, #1
0x17f6c: add    x2, sp, #0x28
0x17f70: mov    w3, #0x80
0x17f74: bl     #0x2368 ; <duss_log_gen_head>
0x17f78: cbz    w0, #0x17fa0
0x17f7c: adrp   x3, #0x1a000
0x17f80: adrp   x4, #0x1d000
0x17f84: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x17f88: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17f8c: mov    w0, #0x51
0x17f90: mov    w5, #0x2c8
0x17f94: mov    w1, #1
0x17f98: add    x2, sp, #0x28
0x17f9c: bl     #0x2378 ; <duss_log_print>
0x17fa0: adrp   x4, #0x1d000
0x17fa4: adrp   x5, #0x1e000
0x17fa8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17fac: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x17fb0: mov    w0, #0x51
0x17fb4: mov    w6, #0x2c8
0x17fb8: mov    w1, #1
0x17fbc: add    x2, sp, #0x28
0x17fc0: mov    w3, #0x80
0x17fc4: bl     #0x2368 ; <duss_log_gen_head>
0x17fc8: cbz    w0, #0x185ac
0x17fcc: adrp   x3, #0x1e000
0x17fd0: adrp   x4, #0x1d000
0x17fd4: add    x3, x3, #0x466 ; "%s: ei_value: value type unexpected.
"
0x17fd8: b      #0x177e4
0x17fdc: adrp   x4, #0x1d000
0x17fe0: adrp   x5, #0x1e000
0x17fe4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x17fe8: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x17fec: mov    w0, #0x51
0x17ff0: mov    w6, #0x30a
0x17ff4: mov    w1, #1
0x17ff8: add    x2, sp, #0x28
0x17ffc: mov    w3, #0x80
0x18000: bl     #0x2368 ; <duss_log_gen_head>
0x18004: cbz    w0, #0x1802c
0x18008: adrp   x3, #0x1a000
0x1800c: adrp   x4, #0x1d000
0x18010: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x18014: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18018: mov    w0, #0x51
0x1801c: mov    w5, #0x30a
0x18020: mov    w1, #1
0x18024: add    x2, sp, #0x28
0x18028: bl     #0x2378 ; <duss_log_print>
0x1802c: adrp   x4, #0x1d000
0x18030: adrp   x5, #0x1e000
0x18034: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18038: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x1803c: mov    w0, #0x51
0x18040: mov    w6, #0x30a
0x18044: mov    w1, #1
0x18048: add    x2, sp, #0x28
0x1804c: mov    w3, #0x80
0x18050: bl     #0x2368 ; <duss_log_gen_head>
0x18054: cbz    w0, #0x185ac
0x18058: adrp   x3, #0x1e000
0x1805c: adrp   x4, #0x1d000
0x18060: add    x3, x3, #0x691 ; "%s: dgain: value type unexpected.
"
0x18064: b      #0x177e4
0x18068: adrp   x0, #0x30000
0x1806c: adrp   x2, #0x1d000
0x18070: add    x0, x0, #0x100 ; =0x30100
0x18074: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x18078: mov    w1, #1
0x1807c: bl     #0x2338 ; <log_mgr_check>
0x18080: tbz    w0, #0, #0x185ac
0x18084: bl     #0x2348 ; <co_thread_get>
0x18088: cbz    x0, #0x18398
0x1808c: adrp   x8, #0x1a000
0x18090: str    wzr, [sp, #0x14]
0x18094: add    x8, x8, #0x440 ; =0x1a440
0x18098: add    x1, sp, #0x18
0x1809c: add    x2, sp, #0x14
0x180a0: str    x8, [sp, #0x18]
0x180a4: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x180a8: adrp   x4, #0x1d000
0x180ac: adrp   x5, #0x1e000
0x180b0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x180b4: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x180b8: mov    w0, #0x51
0x180bc: mov    w6, #0x2d8
0x180c0: mov    w1, #1
0x180c4: add    x2, sp, #0x28
0x180c8: mov    w3, #0x80
0x180cc: bl     #0x2368 ; <duss_log_gen_head>
0x180d0: cbz    w0, #0x180f8
0x180d4: adrp   x3, #0x1a000
0x180d8: adrp   x4, #0x1d000
0x180dc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x180e0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x180e4: mov    w0, #0x51
0x180e8: mov    w5, #0x2d8
0x180ec: mov    w1, #1
0x180f0: add    x2, sp, #0x28
0x180f4: bl     #0x2378 ; <duss_log_print>
0x180f8: adrp   x4, #0x1d000
0x180fc: adrp   x5, #0x1e000
0x18100: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18104: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x18108: mov    w0, #0x51
0x1810c: mov    w6, #0x2d8
0x18110: mov    w1, #1
0x18114: add    x2, sp, #0x28
0x18118: mov    w3, #0x80
0x1811c: bl     #0x2368 ; <duss_log_gen_head>
0x18120: cbz    w0, #0x185ac
0x18124: ldr    x6, [sp, #0x18]
0x18128: adrp   x3, #0x1e000
0x1812c: ldr    w7, [sp, #0x14]
0x18130: adrp   x4, #0x1d000
0x18134: adrp   x5, #0x1a000
0x18138: add    x3, x3, #0x4eb ; "%s: %s(%s_%x): ei_gain: value type unexpected.
"
0x1813c: b      #0x17538
0x18140: adrp   x4, #0x1d000
0x18144: adrp   x5, #0x1e000
0x18148: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1814c: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x18150: mov    w0, #0x51
0x18154: mov    w6, #0x2cc
0x18158: mov    w1, #1
0x1815c: add    x2, sp, #0x28
0x18160: mov    w3, #0x80
0x18164: bl     #0x2368 ; <duss_log_gen_head>
0x18168: cbz    w0, #0x18190
0x1816c: adrp   x3, #0x1a000
0x18170: adrp   x4, #0x1d000
0x18174: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x18178: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1817c: mov    w0, #0x51
0x18180: mov    w5, #0x2cc
0x18184: mov    w1, #1
0x18188: add    x2, sp, #0x28
0x1818c: bl     #0x2378 ; <duss_log_print>
0x18190: adrp   x4, #0x1d000
0x18194: adrp   x5, #0x1e000
0x18198: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1819c: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x181a0: mov    w0, #0x51
0x181a4: mov    w6, #0x2cc
0x181a8: mov    w1, #1
0x181ac: add    x2, sp, #0x28
0x181b0: mov    w3, #0x80
0x181b4: bl     #0x2368 ; <duss_log_gen_head>
0x181b8: cbz    w0, #0x185ac
0x181bc: ldr    w5, [sp, #0x24]
0x181c0: adrp   x3, #0x1e000
0x181c4: adrp   x4, #0x1d000
0x181c8: add    x3, x3, #0x4c1 ; "%s: ei_value: value count unexpected:%d.
"
0x181cc: b      #0x17888
0x181d0: adrp   x4, #0x1d000
0x181d4: adrp   x5, #0x1e000
0x181d8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x181dc: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x181e0: mov    w0, #0x51
0x181e4: mov    w6, #0x30e
0x181e8: mov    w1, #1
0x181ec: add    x2, sp, #0x28
0x181f0: mov    w3, #0x80
0x181f4: bl     #0x2368 ; <duss_log_gen_head>
0x181f8: cbz    w0, #0x18220
0x181fc: adrp   x3, #0x1a000
0x18200: adrp   x4, #0x1d000
0x18204: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x18208: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1820c: mov    w0, #0x51
0x18210: mov    w5, #0x30e
0x18214: mov    w1, #1
0x18218: add    x2, sp, #0x28
0x1821c: bl     #0x2378 ; <duss_log_print>
0x18220: adrp   x4, #0x1d000
0x18224: adrp   x5, #0x1e000
0x18228: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1822c: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18230: mov    w0, #0x51
0x18234: mov    w6, #0x30e
0x18238: mov    w1, #1
0x1823c: add    x2, sp, #0x28
0x18240: mov    w3, #0x80
0x18244: bl     #0x2368 ; <duss_log_gen_head>
0x18248: cbz    w0, #0x185ac
0x1824c: ldr    w5, [sp, #0x24]
0x18250: adrp   x3, #0x1e000
0x18254: adrp   x4, #0x1d000
0x18258: add    x3, x3, #0x6e6 ; "%s: dgain: value count unexpected:%d.
"
0x1825c: b      #0x17888
0x18260: mov    w1, #1
0x18264: bl     #0x2338 ; <log_mgr_check>
0x18268: tbz    w0, #0, #0x185ac
0x1826c: bl     #0x2348 ; <co_thread_get>
0x18270: cbz    x0, #0x1851c
0x18274: adrp   x8, #0x1a000
0x18278: str    wzr, [sp, #0x14]
0x1827c: add    x8, x8, #0x440 ; =0x1a440
0x18280: add    x1, sp, #0x18
0x18284: add    x2, sp, #0x14
0x18288: str    x8, [sp, #0x18]
0x1828c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x18290: adrp   x4, #0x1d000
0x18294: adrp   x5, #0x1e000
0x18298: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1829c: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x182a0: mov    w0, #0x51
0x182a4: mov    w6, #0x2dc
0x182a8: mov    w1, #1
0x182ac: add    x2, sp, #0x28
0x182b0: mov    w3, #0x80
0x182b4: bl     #0x2368 ; <duss_log_gen_head>
0x182b8: cbz    w0, #0x182e0
0x182bc: adrp   x3, #0x1a000
0x182c0: adrp   x4, #0x1d000
0x182c4: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x182c8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x182cc: mov    w0, #0x51
0x182d0: mov    w5, #0x2dc
0x182d4: mov    w1, #1
0x182d8: add    x2, sp, #0x28
0x182dc: bl     #0x2378 ; <duss_log_print>
0x182e0: adrp   x4, #0x1d000
0x182e4: adrp   x5, #0x1e000
0x182e8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x182ec: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x182f0: mov    w0, #0x51
0x182f4: mov    w6, #0x2dc
0x182f8: mov    w1, #1
0x182fc: add    x2, sp, #0x28
0x18300: mov    w3, #0x80
0x18304: bl     #0x2368 ; <duss_log_gen_head>
0x18308: cbz    w0, #0x185ac
0x1830c: ldr    x6, [sp, #0x18]
0x18310: adrp   x3, #0x1e000
0x18314: ldr    w7, [sp, #0x14]
0x18318: adrp   x4, #0x1d000
0x1831c: ldr    w8, [sp, #0x24]
0x18320: adrp   x5, #0x1a000
0x18324: add    x3, x3, #0x540 ; "%s: %s(%s_%x): ei_gain: value count unexpected:%d.
"
0x18328: b      #0x17620
0x1832c: adrp   x4, #0x1d000
0x18330: adrp   x5, #0x1e000
0x18334: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18338: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x1833c: mov    w0, #0x51
0x18340: mov    w6, #0x2d2
0x18344: mov    w1, #1
0x18348: add    x2, sp, #0x28
0x1834c: mov    w3, #0x80
0x18350: bl     #0x2368 ; <duss_log_gen_head>
0x18354: cbz    w0, #0x1837c
0x18358: adrp   x3, #0x1a000
0x1835c: adrp   x4, #0x1d000
0x18360: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x18364: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18368: mov    w0, #0x51
0x1836c: mov    w5, #0x2d2
0x18370: mov    w1, #1
0x18374: add    x2, sp, #0x28
0x18378: bl     #0x2378 ; <duss_log_print>
0x1837c: adrp   x4, #0x1d000
0x18380: adrp   x5, #0x1e000
0x18384: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18388: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x1838c: mov    w0, #0x51
0x18390: mov    w6, #0x2d2
0x18394: b      #0x17724
0x18398: adrp   x4, #0x1d000
0x1839c: adrp   x5, #0x1e000
0x183a0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x183a4: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x183a8: mov    w0, #0x51
0x183ac: mov    w6, #0x2d8
0x183b0: mov    w1, #1
0x183b4: add    x2, sp, #0x28
0x183b8: mov    w3, #0x80
0x183bc: bl     #0x2368 ; <duss_log_gen_head>
0x183c0: cbz    w0, #0x183e8
0x183c4: adrp   x3, #0x1a000
0x183c8: adrp   x4, #0x1d000
0x183cc: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x183d0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x183d4: mov    w0, #0x51
0x183d8: mov    w5, #0x2d8
0x183dc: mov    w1, #1
0x183e0: add    x2, sp, #0x28
0x183e4: bl     #0x2378 ; <duss_log_print>
0x183e8: adrp   x4, #0x1d000
0x183ec: adrp   x5, #0x1e000
0x183f0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x183f4: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x183f8: mov    w0, #0x51
0x183fc: mov    w6, #0x2d8
0x18400: mov    w1, #1
0x18404: add    x2, sp, #0x28
0x18408: mov    w3, #0x80
0x1840c: bl     #0x2368 ; <duss_log_gen_head>
0x18410: cbz    w0, #0x185ac
0x18414: adrp   x3, #0x1e000
0x18418: adrp   x4, #0x1d000
0x1841c: add    x3, x3, #0x51b ; "%s: ei_gain: value type unexpected.
"
0x18420: b      #0x177e4
0x18424: adrp   x4, #0x1d000
0x18428: adrp   x5, #0x1e000
0x1842c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18430: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x18434: mov    w0, #0x51
0x18438: mov    w6, #0x2e0
0x1843c: mov    w1, #4
0x18440: add    x2, sp, #0x28
0x18444: mov    w3, #0x80
0x18448: bl     #0x2368 ; <duss_log_gen_head>
0x1844c: cbz    w0, #0x18478
0x18450: ldr    w5, [x21]
0x18454: adrp   x3, #0x1e000
0x18458: ldr    w6, [x20]
0x1845c: adrp   x4, #0x1d000
0x18460: add    x3, x3, #0x5c5 ; "%s: ei_gain %d, ei_value %d
"
0x18464: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x18468: mov    w0, #0x51
0x1846c: mov    w1, #4
0x18470: add    x2, sp, #0x28
0x18474: bl     #0x2378 ; <duss_log_print>
0x18478: ldr    w8, [x21]
0x1847c: cmp    w8, #2
0x18480: b.eq   #0x184dc
0x18484: cmp    w8, #1
0x18488: b.ne   #0x184d4
0x1848c: ldr    w8, [x20]
0x18490: mov    w0, #-0x3e9
0x18494: cmp    w8, #0x63f
0x18498: b.gt   #0x185d4
0x1849c: cmp    w8, #0x18f
0x184a0: b.gt   #0x18644
0x184a4: cmp    w8, #0xc7
0x184a8: b.gt   #0x18714
0x184ac: cmp    w8, #0x64
0x184b0: b.eq   #0x18854
0x184b4: cmp    w8, #0x7d
0x184b8: b.eq   #0x18864
0x184bc: cmp    w8, #0xa0
0x184c0: b.ne   #0x185b0
0x184c4: adrp   x9, #0x1e000
0x184c8: mov    w8, #2
0x184cc: add    x9, x9, #0xb20 ; "d"
0x184d0: b      #0x189d8
0x184d4: mov    w0, #-0x3e9
0x184d8: b      #0x185b0
0x184dc: ldr    w8, [x20]
0x184e0: mov    w0, #-0x3e9
0x184e4: cmp    w8, #0x63f
0x184e8: b.gt   #0x18610
0x184ec: cmp    w8, #0x18f
0x184f0: b.gt   #0x18674
0x184f4: cmp    w8, #0xc7
0x184f8: b.gt   #0x1873c
0x184fc: cmp    w8, #0x64
0x18500: b.eq   #0x18874
0x18504: cmp    w8, #0x7d
0x18508: b.eq   #0x1887c
0x1850c: cmp    w8, #0xa0
0x18510: b.ne   #0x185b0
0x18514: mov    w8, #2
0x18518: b      #0x189d0
0x1851c: adrp   x4, #0x1d000
0x18520: adrp   x5, #0x1e000
0x18524: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18528: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x1852c: mov    w0, #0x51
0x18530: mov    w6, #0x2dc
0x18534: mov    w1, #1
0x18538: add    x2, sp, #0x28
0x1853c: mov    w3, #0x80
0x18540: bl     #0x2368 ; <duss_log_gen_head>
0x18544: cbz    w0, #0x1856c
0x18548: adrp   x3, #0x1a000
0x1854c: adrp   x4, #0x1d000
0x18550: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x18554: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18558: mov    w0, #0x51
0x1855c: mov    w5, #0x2dc
0x18560: mov    w1, #1
0x18564: add    x2, sp, #0x28
0x18568: bl     #0x2378 ; <duss_log_print>
0x1856c: adrp   x4, #0x1d000
0x18570: adrp   x5, #0x1e000
0x18574: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18578: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x1857c: mov    w0, #0x51
0x18580: mov    w6, #0x2dc
0x18584: mov    w1, #1
0x18588: add    x2, sp, #0x28
0x1858c: mov    w3, #0x80
0x18590: bl     #0x2368 ; <duss_log_gen_head>
0x18594: cbz    w0, #0x185ac
0x18598: ldr    w5, [sp, #0x24]
0x1859c: adrp   x3, #0x1e000
0x185a0: adrp   x4, #0x1d000
0x185a4: add    x3, x3, #0x574 ; "%s: ei_gain: value count unexpected:%d.
"
0x185a8: b      #0x17888
0x185ac: mov    w0, #-0x3eb
0x185b0: ldr    x8, [x22, #0x28]
0x185b4: ldur   x9, [x29, #-0x28]
0x185b8: cmp    x8, x9
0x185bc: b.ne   #0x18ab4
0x185c0: ldp    x29, x30, [sp, #0xd0]
0x185c4: ldp    x20, x19, [sp, #0xc0]
0x185c8: ldp    x22, x21, [sp, #0xb0]
0x185cc: add    sp, sp, #0xe0
0x185d0: ret    
0x185d4: mov    w9, #0x18ff
0x185d8: cmp    w8, w9
0x185dc: b.gt   #0x1869c
0x185e0: cmp    w8, #0xc7f
0x185e4: b.gt   #0x1875c
0x185e8: cmp    w8, #0x640
0x185ec: b.eq   #0x18884
0x185f0: cmp    w8, #0x7d0
0x185f4: b.eq   #0x18894
0x185f8: cmp    w8, #0x9c4
0x185fc: b.ne   #0x185b0
0x18600: adrp   x9, #0x1e000
0x18604: mov    w8, #0xe
0x18608: add    x9, x9, #0xb20 ; "d"
0x1860c: b      #0x189d8
0x18610: mov    w9, #0x18ff
0x18614: cmp    w8, w9
0x18618: b.gt   #0x186dc
0x1861c: cmp    w8, #0xc7f
0x18620: b.gt   #0x18788
0x18624: cmp    w8, #0x640
0x18628: b.eq   #0x188a4
0x1862c: cmp    w8, #0x7d0
0x18630: b.eq   #0x188ac
0x18634: cmp    w8, #0x9c4
0x18638: b.ne   #0x185b0
0x1863c: mov    w8, #0xe
0x18640: b      #0x189d0
0x18644: cmp    w8, #0x31f
0x18648: b.gt   #0x187ac
0x1864c: cmp    w8, #0x190
0x18650: b.eq   #0x188b4
0x18654: cmp    w8, #0x1f4
0x18658: b.eq   #0x188c4
0x1865c: cmp    w8, #0x280
0x18660: b.ne   #0x185b0
0x18664: adrp   x9, #0x1e000
0x18668: mov    w8, #8
0x1866c: add    x9, x9, #0xb20 ; "d"
0x18670: b      #0x189d8
0x18674: cmp    w8, #0x31f
0x18678: b.gt   #0x187d4
0x1867c: cmp    w8, #0x190
0x18680: b.eq   #0x188d4
0x18684: cmp    w8, #0x1f4
0x18688: b.eq   #0x188dc
0x1868c: cmp    w8, #0x280
0x18690: b.ne   #0x185b0
0x18694: mov    w8, #8
0x18698: b      #0x189d0
0x1869c: mov    w9, #0x31ff
0x186a0: cmp    w8, w9
0x186a4: b.gt   #0x187f4
0x186a8: mov    w9, #0x1900
0x186ac: cmp    w8, w9
0x186b0: b.eq   #0x188e4
0x186b4: mov    w9, #0x1f40
0x186b8: cmp    w8, w9
0x186bc: b.eq   #0x188f4
0x186c0: mov    w9, #0x2710
0x186c4: cmp    w8, w9
0x186c8: b.ne   #0x185b0
0x186cc: adrp   x9, #0x1e000
0x186d0: mov    w8, #0x14
0x186d4: add    x9, x9, #0xb20 ; "d"
0x186d8: b      #0x189d8
0x186dc: mov    w9, #0x31ff
0x186e0: cmp    w8, w9
0x186e4: b.gt   #0x18828
0x186e8: mov    w9, #0x1900
0x186ec: cmp    w8, w9
0x186f0: b.eq   #0x18904
0x186f4: mov    w9, #0x1f40
0x186f8: cmp    w8, w9
0x186fc: b.eq   #0x1890c
0x18700: mov    w9, #0x2710
0x18704: cmp    w8, w9
0x18708: b.ne   #0x185b0
0x1870c: mov    w8, #0x14
0x18710: b      #0x189d0
0x18714: cmp    w8, #0xc8
0x18718: b.eq   #0x18914
0x1871c: cmp    w8, #0xfa
0x18720: b.eq   #0x18924
0x18724: cmp    w8, #0x140
0x18728: b.ne   #0x185b0
0x1872c: adrp   x9, #0x1e000
0x18730: mov    w8, #5
0x18734: add    x9, x9, #0xb20 ; "d"
0x18738: b      #0x189d8
0x1873c: cmp    w8, #0xc8
0x18740: b.eq   #0x18934
0x18744: cmp    w8, #0xfa
0x18748: b.eq   #0x1893c
0x1874c: cmp    w8, #0x140
0x18750: b.ne   #0x185b0
0x18754: mov    w8, #5
0x18758: b      #0x189d0
0x1875c: cmp    w8, #0xc80
0x18760: b.eq   #0x18944
0x18764: cmp    w8, #0xfa0
0x18768: b.eq   #0x18954
0x1876c: mov    w9, #0x1388
0x18770: cmp    w8, w9
0x18774: b.ne   #0x185b0
0x18778: adrp   x9, #0x1e000
0x1877c: mov    w8, #0x11
0x18780: add    x9, x9, #0xb20 ; "d"
0x18784: b      #0x189d8
0x18788: cmp    w8, #0xc80
0x1878c: b.eq   #0x18964
0x18790: cmp    w8, #0xfa0
0x18794: b.eq   #0x1896c
0x18798: mov    w9, #0x1388
0x1879c: cmp    w8, w9
0x187a0: b.ne   #0x185b0
0x187a4: mov    w8, #0x11
0x187a8: b      #0x189d0
0x187ac: cmp    w8, #0x320
0x187b0: b.eq   #0x18974
0x187b4: cmp    w8, #0x3e8
0x187b8: b.eq   #0x18984
0x187bc: cmp    w8, #0x4e2
0x187c0: b.ne   #0x185b0
0x187c4: adrp   x9, #0x1e000
0x187c8: mov    w8, #0xb
0x187cc: add    x9, x9, #0xb20 ; "d"
0x187d0: b      #0x189d8
0x187d4: cmp    w8, #0x320
0x187d8: b.eq   #0x18994
0x187dc: cmp    w8, #0x3e8
0x187e0: b.eq   #0x1899c
0x187e4: cmp    w8, #0x4e2
0x187e8: b.ne   #0x185b0
0x187ec: mov    w8, #0xb
0x187f0: b      #0x189d0
0x187f4: mov    w9, #0x3200
0x187f8: cmp    w8, w9
0x187fc: b.eq   #0x189a4
0x18800: mov    w9, #0x3e80
0x18804: cmp    w8, w9
0x18808: b.eq   #0x189b4
0x1880c: mov    w9, #0x4e20
0x18810: cmp    w8, w9
0x18814: b.ne   #0x185b0
0x18818: adrp   x9, #0x1e000
0x1881c: mov    w8, #0x17
0x18820: add    x9, x9, #0xb20 ; "d"
0x18824: b      #0x189d8
0x18828: mov    w9, #0x3200
0x1882c: cmp    w8, w9
0x18830: b.eq   #0x189c4
0x18834: mov    w9, #0x3e80
0x18838: cmp    w8, w9
0x1883c: b.eq   #0x189cc
0x18840: mov    w9, #0x4e20
0x18844: cmp    w8, w9
0x18848: b.ne   #0x185b0
0x1884c: mov    w8, #0x17
0x18850: b      #0x189d0
0x18854: adrp   x9, #0x1e000
0x18858: mov    x8, xzr
0x1885c: add    x9, x9, #0xb20 ; "d"
0x18860: b      #0x189d8
0x18864: adrp   x9, #0x1e000
0x18868: mov    w8, #1
0x1886c: add    x9, x9, #0xb20 ; "d"
0x18870: b      #0x189d8
0x18874: mov    x8, xzr
0x18878: b      #0x189d0
0x1887c: mov    w8, #1
0x18880: b      #0x189d0
0x18884: adrp   x9, #0x1e000
0x18888: mov    w8, #0xc
0x1888c: add    x9, x9, #0xb20 ; "d"
0x18890: b      #0x189d8
0x18894: adrp   x9, #0x1e000
0x18898: mov    w8, #0xd
0x1889c: add    x9, x9, #0xb20 ; "d"
0x188a0: b      #0x189d8
0x188a4: mov    w8, #0xc
0x188a8: b      #0x189d0
0x188ac: mov    w8, #0xd
0x188b0: b      #0x189d0
0x188b4: adrp   x9, #0x1e000
0x188b8: mov    w8, #6
0x188bc: add    x9, x9, #0xb20 ; "d"
0x188c0: b      #0x189d8
0x188c4: adrp   x9, #0x1e000
0x188c8: mov    w8, #7
0x188cc: add    x9, x9, #0xb20 ; "d"
0x188d0: b      #0x189d8
0x188d4: mov    w8, #6
0x188d8: b      #0x189d0
0x188dc: mov    w8, #7
0x188e0: b      #0x189d0
0x188e4: adrp   x9, #0x1e000
0x188e8: mov    w8, #0x12
0x188ec: add    x9, x9, #0xb20 ; "d"
0x188f0: b      #0x189d8
0x188f4: adrp   x9, #0x1e000
0x188f8: mov    w8, #0x13
0x188fc: add    x9, x9, #0xb20 ; "d"
0x18900: b      #0x189d8
0x18904: mov    w8, #0x12
0x18908: b      #0x189d0
0x1890c: mov    w8, #0x13
0x18910: b      #0x189d0
0x18914: adrp   x9, #0x1e000
0x18918: mov    w8, #3
0x1891c: add    x9, x9, #0xb20 ; "d"
0x18920: b      #0x189d8
0x18924: adrp   x9, #0x1e000
0x18928: mov    w8, #4
0x1892c: add    x9, x9, #0xb20 ; "d"
0x18930: b      #0x189d8
0x18934: mov    w8, #3
0x18938: b      #0x189d0
0x1893c: mov    w8, #4
0x18940: b      #0x189d0
0x18944: adrp   x9, #0x1e000
0x18948: mov    w8, #0xf
0x1894c: add    x9, x9, #0xb20 ; "d"
0x18950: b      #0x189d8
0x18954: adrp   x9, #0x1e000
0x18958: mov    w8, #0x10
0x1895c: add    x9, x9, #0xb20 ; "d"
0x18960: b      #0x189d8
0x18964: mov    w8, #0xf
0x18968: b      #0x189d0
0x1896c: mov    w8, #0x10
0x18970: b      #0x189d0
0x18974: adrp   x9, #0x1e000
0x18978: mov    w8, #9
0x1897c: add    x9, x9, #0xb20 ; "d"
0x18980: b      #0x189d8
0x18984: adrp   x9, #0x1e000
0x18988: mov    w8, #0xa
0x1898c: add    x9, x9, #0xb20 ; "d"
0x18990: b      #0x189d8
0x18994: mov    w8, #9
0x18998: b      #0x189d0
0x1899c: mov    w8, #0xa
0x189a0: b      #0x189d0
0x189a4: adrp   x9, #0x1e000
0x189a8: mov    w8, #0x15
0x189ac: add    x9, x9, #0xb20 ; "d"
0x189b0: b      #0x189d8
0x189b4: adrp   x9, #0x1e000
0x189b8: mov    w8, #0x16
0x189bc: add    x9, x9, #0xb20 ; "d"
0x189c0: b      #0x189d8
0x189c4: mov    w8, #0x15
0x189c8: b      #0x189d0
0x189cc: mov    w8, #0x16
0x189d0: adrp   x9, #0x1e000
0x189d4: add    x9, x9, #0xbe8 ; "d"
0x189d8: add    x8, x9, x8, lsl #3
0x189dc: mov    w0, wzr
0x189e0: ldr    w8, [x8, #4]
0x189e4: str    w8, [x19]
0x189e8: b      #0x185b0
0x189ec: bl     #0x2348 ; <co_thread_get>
0x189f0: cbnz   x0, #0x18ab8
0x189f4: adrp   x4, #0x1d000
0x189f8: adrp   x5, #0x1e000
0x189fc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18a00: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x18a04: mov    w0, #0x51
0x18a08: mov    w6, #0x31d
0x18a0c: add    x2, sp, #0x28
0x18a10: mov    w3, #0x80
0x18a14: mov    w1, wzr
0x18a18: bl     #0x2368 ; <duss_log_gen_head>
0x18a1c: cbz    w0, #0x18b40
0x18a20: adrp   x3, #0x1a000
0x18a24: adrp   x4, #0x1e000
0x18a28: adrp   x5, #0x1d000
0x18a2c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x18a30: add    x4, x4, #0x54 ; "venc_param"
0x18a34: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18a38: mov    w0, #0x51
0x18a3c: mov    w6, #0x31d
0x18a40: add    x2, sp, #0x28
0x18a44: mov    w1, wzr
0x18a48: bl     #0x2378 ; <duss_log_print>
0x18a4c: b      #0x18b40
0x18a50: bl     #0x2348 ; <co_thread_get>
0x18a54: cbnz   x0, #0x18b5c
0x18a58: adrp   x4, #0x1d000
0x18a5c: adrp   x5, #0x1e000
0x18a60: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18a64: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x18a68: mov    w0, #0x51
0x18a6c: mov    w6, #0x31f
0x18a70: add    x2, sp, #0x28
0x18a74: mov    w3, #0x80
0x18a78: mov    w1, wzr
0x18a7c: bl     #0x2368 ; <duss_log_gen_head>
0x18a80: cbz    w0, #0x18be4
0x18a84: adrp   x3, #0x1a000
0x18a88: adrp   x4, #0x1e000
0x18a8c: adrp   x5, #0x1d000
0x18a90: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x18a94: add    x4, x4, #0x5f ; "cam_enc_param->metadata"
0x18a98: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18a9c: mov    w0, #0x51
0x18aa0: mov    w6, #0x31f
0x18aa4: add    x2, sp, #0x28
0x18aa8: mov    w1, wzr
0x18aac: bl     #0x2378 ; <duss_log_print>
0x18ab0: b      #0x18be4
0x18ab4: bl     #0x23d8 ; <__stack_chk_fail>
0x18ab8: adrp   x8, #0x1a000
0x18abc: str    wzr, [sp, #0x24]
0x18ac0: add    x8, x8, #0x440 ; =0x1a440
0x18ac4: add    x1, sp, #0x18
0x18ac8: add    x2, sp, #0x24
0x18acc: str    x8, [sp, #0x18]
0x18ad0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x18ad4: adrp   x19, #0x1d000
0x18ad8: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18adc: adrp   x5, #0x1e000
0x18ae0: mov    w20, #0x31d
0x18ae4: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x18ae8: mov    w0, #0x51
0x18aec: add    x2, sp, #0x28
0x18af0: mov    w3, #0x80
0x18af4: mov    w1, wzr
0x18af8: mov    x4, x19
0x18afc: mov    w6, w20
0x18b00: bl     #0x2368 ; <duss_log_gen_head>
0x18b04: cbz    w0, #0x18b40
0x18b08: ldr    x5, [sp, #0x18]
0x18b0c: adrp   x3, #0x1a000
0x18b10: ldr    w6, [sp, #0x24]
0x18b14: adrp   x4, #0x1a000
0x18b18: adrp   x7, #0x1e000
0x18b1c: str    w20, [sp, #8]
0x18b20: mov    w1, wzr
0x18b24: str    x19, [sp]
0x18b28: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x18b2c: add    x4, x4, #0x441 ; "co"
0x18b30: mov    w0, #0x51
0x18b34: add    x7, x7, #0x54 ; "venc_param"
0x18b38: add    x2, sp, #0x28
0x18b3c: bl     #0x2378 ; <duss_log_print>
0x18b40: adrp   x4, #0x1d000
0x18b44: adrp   x5, #0x1e000
0x18b48: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18b4c: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x18b50: mov    w0, #0x51
0x18b54: mov    w6, #0x31d
0x18b58: b      #0x18bfc
0x18b5c: adrp   x8, #0x1a000
0x18b60: str    wzr, [sp, #0x24]
0x18b64: add    x8, x8, #0x440 ; =0x1a440
0x18b68: add    x1, sp, #0x18
0x18b6c: add    x2, sp, #0x24
0x18b70: str    x8, [sp, #0x18]
0x18b74: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x18b78: adrp   x19, #0x1d000
0x18b7c: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18b80: adrp   x5, #0x1e000
0x18b84: mov    w20, #0x31f
0x18b88: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x18b8c: mov    w0, #0x51
0x18b90: add    x2, sp, #0x28
0x18b94: mov    w3, #0x80
0x18b98: mov    w1, wzr
0x18b9c: mov    x4, x19
0x18ba0: mov    w6, w20
0x18ba4: bl     #0x2368 ; <duss_log_gen_head>
0x18ba8: cbz    w0, #0x18be4
0x18bac: ldr    x5, [sp, #0x18]
0x18bb0: adrp   x3, #0x1a000
0x18bb4: ldr    w6, [sp, #0x24]
0x18bb8: adrp   x4, #0x1a000
0x18bbc: adrp   x7, #0x1e000
0x18bc0: str    w20, [sp, #8]
0x18bc4: mov    w1, wzr
0x18bc8: str    x19, [sp]
0x18bcc: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x18bd0: add    x4, x4, #0x441 ; "co"
0x18bd4: mov    w0, #0x51
0x18bd8: add    x7, x7, #0x5f ; "cam_enc_param->metadata"
0x18bdc: add    x2, sp, #0x28
0x18be0: bl     #0x2378 ; <duss_log_print>
0x18be4: adrp   x4, #0x1d000
0x18be8: adrp   x5, #0x1e000
0x18bec: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18bf0: add    x5, x5, #0x3f ; "proresraw_d_gain_get"
0x18bf4: mov    w0, #0x51
0x18bf8: mov    w6, #0x31f
0x18bfc: add    x2, sp, #0x28
0x18c00: mov    w3, #0x80
0x18c04: mov    w1, wzr
0x18c08: bl     #0x2368 ; <duss_log_gen_head>
0x18c0c: cbz    w0, #0x18c28
0x18c10: adrp   x3, #0x1a000
0x18c14: add    x3, x3, #0x550 ; "Assertion Comment: "
0x18c18: mov    w0, #0x51
0x18c1c: add    x2, sp, #0x28
0x18c20: mov    w1, wzr
0x18c24: bl     #0x2378 ; <duss_log_print>
0x18c28: adrp   x0, #0x1a000
0x18c2c: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x18c30: bl     #0x23e8 ; <log_to_kmsg>
0x18c34: adrp   x0, #0x1a000
0x18c38: add    x0, x0, #0x57f ; "Camera:	"
0x18c3c: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x18c40: bl     #0x2408 ; <is_running_in_cam_sil>
0x18c44: tbz    w0, #0, #0x18c54
0x18c48: mov    x0, xzr
0x18c4c: bl     #0x2418 ; <fflush>
0x18c50: bl     #0x2428 ; <abort>
0x18c54: mov    w0, #1
0x18c58: bl     #0x2438 ; <exit>
0x18c5c: bl     #0x2348 ; <co_thread_get>
0x18c60: cbnz   x0, #0x18d88
0x18c64: adrp   x4, #0x1d000
0x18c68: adrp   x5, #0x1e000
0x18c6c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18c70: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x18c74: mov    w0, #0x51
0x18c78: mov    w6, #0x2be
0x18c7c: add    x2, sp, #0x28
0x18c80: mov    w3, #0x80
0x18c84: mov    w1, wzr
0x18c88: bl     #0x2368 ; <duss_log_gen_head>
0x18c8c: cbz    w0, #0x18e10
0x18c90: adrp   x3, #0x1a000
0x18c94: adrp   x4, #0x1e000
0x18c98: adrp   x5, #0x1d000
0x18c9c: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x18ca0: add    x4, x4, #0x5f ; "cam_enc_param->metadata"
0x18ca4: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18ca8: mov    w0, #0x51
0x18cac: mov    w6, #0x2be
0x18cb0: add    x2, sp, #0x28
0x18cb4: mov    w1, wzr
0x18cb8: bl     #0x2378 ; <duss_log_print>
0x18cbc: b      #0x18e10
0x18cc0: bl     #0x2348 ; <co_thread_get>
0x18cc4: cbnz   x0, #0x18e2c
0x18cc8: adrp   x4, #0x1d000
0x18ccc: adrp   x5, #0x1e000
0x18cd0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18cd4: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18cd8: mov    w0, #0x51
0x18cdc: mov    w6, #0x2fe
0x18ce0: add    x2, sp, #0x28
0x18ce4: mov    w3, #0x80
0x18ce8: mov    w1, wzr
0x18cec: bl     #0x2368 ; <duss_log_gen_head>
0x18cf0: cbz    w0, #0x18eb4
0x18cf4: adrp   x3, #0x1a000
0x18cf8: adrp   x4, #0x1e000
0x18cfc: adrp   x5, #0x1d000
0x18d00: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x18d04: add    x4, x4, #0x601 ; "d_gain"
0x18d08: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18d0c: mov    w0, #0x51
0x18d10: mov    w6, #0x2fe
0x18d14: add    x2, sp, #0x28
0x18d18: mov    w1, wzr
0x18d1c: bl     #0x2378 ; <duss_log_print>
0x18d20: b      #0x18eb4
0x18d24: bl     #0x2348 ; <co_thread_get>
0x18d28: cbnz   x0, #0x18ed0
0x18d2c: adrp   x4, #0x1d000
0x18d30: adrp   x5, #0x1e000
0x18d34: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18d38: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18d3c: mov    w0, #0x51
0x18d40: add    x2, sp, #0x28
0x18d44: mov    w3, #0x80
0x18d48: mov    w6, #0x300
0x18d4c: mov    w1, wzr
0x18d50: bl     #0x2368 ; <duss_log_gen_head>
0x18d54: cbz    w0, #0x18f58
0x18d58: adrp   x3, #0x1a000
0x18d5c: adrp   x4, #0x1e000
0x18d60: adrp   x5, #0x1d000
0x18d64: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x18d68: add    x4, x4, #0x5f ; "cam_enc_param->metadata"
0x18d6c: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18d70: mov    w0, #0x51
0x18d74: add    x2, sp, #0x28
0x18d78: mov    w6, #0x300
0x18d7c: mov    w1, wzr
0x18d80: bl     #0x2378 ; <duss_log_print>
0x18d84: b      #0x18f58
0x18d88: adrp   x8, #0x1a000
0x18d8c: str    wzr, [sp, #0x14]
0x18d90: add    x8, x8, #0x440 ; =0x1a440
0x18d94: add    x1, sp, #0x18
0x18d98: add    x2, sp, #0x14
0x18d9c: str    x8, [sp, #0x18]
0x18da0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x18da4: adrp   x19, #0x1d000
0x18da8: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18dac: adrp   x5, #0x1e000
0x18db0: mov    w20, #0x2be
0x18db4: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x18db8: mov    w0, #0x51
0x18dbc: add    x2, sp, #0x28
0x18dc0: mov    w3, #0x80
0x18dc4: mov    w1, wzr
0x18dc8: mov    x4, x19
0x18dcc: mov    w6, w20
0x18dd0: bl     #0x2368 ; <duss_log_gen_head>
0x18dd4: cbz    w0, #0x18e10
0x18dd8: ldr    x5, [sp, #0x18]
0x18ddc: adrp   x3, #0x1a000
0x18de0: ldr    w6, [sp, #0x14]
0x18de4: adrp   x4, #0x1a000
0x18de8: adrp   x7, #0x1e000
0x18dec: str    w20, [sp, #8]
0x18df0: mov    w1, wzr
0x18df4: str    x19, [sp]
0x18df8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x18dfc: add    x4, x4, #0x441 ; "co"
0x18e00: mov    w0, #0x51
0x18e04: add    x7, x7, #0x5f ; "cam_enc_param->metadata"
0x18e08: add    x2, sp, #0x28
0x18e0c: bl     #0x2378 ; <duss_log_print>
0x18e10: adrp   x4, #0x1d000
0x18e14: adrp   x5, #0x1e000
0x18e18: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18e1c: add    x5, x5, #0x417 ; "_proresraw_d_gain_get_from_ei"
0x18e20: mov    w0, #0x51
0x18e24: mov    w6, #0x2be
0x18e28: b      #0x18bfc
0x18e2c: adrp   x8, #0x1a000
0x18e30: str    wzr, [sp, #0x14]
0x18e34: add    x8, x8, #0x440 ; =0x1a440
0x18e38: add    x1, sp, #0x18
0x18e3c: add    x2, sp, #0x14
0x18e40: str    x8, [sp, #0x18]
0x18e44: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x18e48: adrp   x19, #0x1d000
0x18e4c: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18e50: adrp   x5, #0x1e000
0x18e54: mov    w20, #0x2fe
0x18e58: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18e5c: mov    w0, #0x51
0x18e60: add    x2, sp, #0x28
0x18e64: mov    w3, #0x80
0x18e68: mov    w1, wzr
0x18e6c: mov    x4, x19
0x18e70: mov    w6, w20
0x18e74: bl     #0x2368 ; <duss_log_gen_head>
0x18e78: cbz    w0, #0x18eb4
0x18e7c: ldr    x5, [sp, #0x18]
0x18e80: adrp   x3, #0x1a000
0x18e84: ldr    w6, [sp, #0x14]
0x18e88: adrp   x4, #0x1a000
0x18e8c: adrp   x7, #0x1e000
0x18e90: str    w20, [sp, #8]
0x18e94: mov    w1, wzr
0x18e98: str    x19, [sp]
0x18e9c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x18ea0: add    x4, x4, #0x441 ; "co"
0x18ea4: mov    w0, #0x51
0x18ea8: add    x7, x7, #0x601 ; "d_gain"
0x18eac: add    x2, sp, #0x28
0x18eb0: bl     #0x2378 ; <duss_log_print>
0x18eb4: adrp   x4, #0x1d000
0x18eb8: adrp   x5, #0x1e000
0x18ebc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18ec0: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18ec4: mov    w0, #0x51
0x18ec8: mov    w6, #0x2fe
0x18ecc: b      #0x18bfc
0x18ed0: adrp   x8, #0x1a000
0x18ed4: str    wzr, [sp, #0x14]
0x18ed8: add    x8, x8, #0x440 ; =0x1a440
0x18edc: add    x1, sp, #0x18
0x18ee0: add    x2, sp, #0x14
0x18ee4: str    x8, [sp, #0x18]
0x18ee8: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x18eec: adrp   x19, #0x1d000
0x18ef0: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18ef4: adrp   x5, #0x1e000
0x18ef8: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18efc: mov    w0, #0x51
0x18f00: add    x2, sp, #0x28
0x18f04: mov    w3, #0x80
0x18f08: mov    w6, #0x300
0x18f0c: mov    w1, wzr
0x18f10: mov    x4, x19
0x18f14: mov    w20, #0x300
0x18f18: bl     #0x2368 ; <duss_log_gen_head>
0x18f1c: cbz    w0, #0x18f58
0x18f20: ldr    x5, [sp, #0x18]
0x18f24: adrp   x3, #0x1a000
0x18f28: ldr    w6, [sp, #0x14]
0x18f2c: adrp   x4, #0x1a000
0x18f30: adrp   x7, #0x1e000
0x18f34: str    w20, [sp, #8]
0x18f38: mov    w1, wzr
0x18f3c: str    x19, [sp]
0x18f40: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x18f44: add    x4, x4, #0x441 ; "co"
0x18f48: mov    w0, #0x51
0x18f4c: add    x7, x7, #0x5f ; "cam_enc_param->metadata"
0x18f50: add    x2, sp, #0x28
0x18f54: bl     #0x2378 ; <duss_log_print>
0x18f58: adrp   x4, #0x1d000
0x18f5c: adrp   x5, #0x1e000
0x18f60: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18f64: add    x5, x5, #0x5e2 ; "_proresraw_d_gain_get_from_iso"
0x18f68: mov    w0, #0x51
0x18f6c: add    x2, sp, #0x28
0x18f70: mov    w3, #0x80
0x18f74: mov    w6, #0x300
0x18f78: b      #0x18c04
0x18f7c: udf    #0
0x18f80: sub    sp, sp, #0xf0
0x18f84: stp    x22, x21, [sp, #0xc0]
0x18f88: stp    x20, x19, [sp, #0xd0]
0x18f8c: stp    x29, x30, [sp, #0xe0]
0x18f90: add    x29, sp, #0xe0
0x18f94: mrs    x21, tpidr_el0
0x18f98: add    x22, sp, #0x18
0x18f9c: ldr    x8, [x21, #0x28]
0x18fa0: mov    x19, x1
0x18fa4: str    x8, [x22]
0x18fa8: str    wzr, [sp, #0x34]
0x18fac: cbz    x0, #0x195f0
0x18fb0: cbz    x19, #0x19654
0x18fb4: ldr    x0, [x0, #0x48]
0x18fb8: cbz    x0, #0x196b8
0x18fbc: adrp   x2, #0x1d000
0x18fc0: adrp   x3, #0x1e000
0x18fc4: add    x2, x2, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x18fc8: add    x3, x3, #0x129 ; "proresraw_wb_gain_get"
0x18fcc: mov    w1, #0x48d
0x18fd0: mov    w4, #0x343
0x18fd4: bl     #0x2538 ; <dcam_container_get_by_id_inner>
0x18fd8: mov    x20, x0
0x18fdc: cbz    x20, #0x190f0
0x18fe0: add    x1, sp, #0x34
0x18fe4: mov    x0, x20
0x18fe8: bl     #0x27e8 ; <dcam_container_val_as_uint32>
0x18fec: ldr    w8, [x20]
0x18ff0: cmp    w8, #4
0x18ff4: b.ne   #0x191e0
0x18ff8: ldr    w8, [sp, #0x34]
0x18ffc: cmp    w8, #3
0x19000: b.gt   #0x192d0
0x19004: adrp   x0, #0x30000
0x19008: adrp   x2, #0x1d000
0x1900c: add    x0, x0, #0x100 ; =0x30100
0x19010: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x19014: mov    w1, #1
0x19018: bl     #0x2338 ; <log_mgr_check>
0x1901c: tbz    w0, #0, #0x19570
0x19020: bl     #0x2348 ; <co_thread_get>
0x19024: cbz    x0, #0x194d0
0x19028: adrp   x8, #0x1a000
0x1902c: str    wzr, [sp, #0x24]
0x19030: add    x8, x8, #0x440 ; =0x1a440
0x19034: add    x1, sp, #0x28
0x19038: add    x2, sp, #0x24
0x1903c: str    x8, [sp, #0x28]
0x19040: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19044: adrp   x4, #0x1d000
0x19048: adrp   x5, #0x1e000
0x1904c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19050: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19054: mov    w0, #0x51
0x19058: mov    w6, #0x350
0x1905c: mov    w1, #1
0x19060: add    x2, sp, #0x38
0x19064: mov    w3, #0x80
0x19068: bl     #0x2368 ; <duss_log_gen_head>
0x1906c: cbz    w0, #0x19094
0x19070: adrp   x3, #0x1a000
0x19074: adrp   x4, #0x1d000
0x19078: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x1907c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19080: mov    w0, #0x51
0x19084: mov    w5, #0x350
0x19088: mov    w1, #1
0x1908c: add    x2, sp, #0x38
0x19090: bl     #0x2378 ; <duss_log_print>
0x19094: adrp   x4, #0x1d000
0x19098: adrp   x5, #0x1e000
0x1909c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x190a0: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x190a4: mov    w0, #0x51
0x190a8: mov    w6, #0x350
0x190ac: mov    w1, #1
0x190b0: add    x2, sp, #0x38
0x190b4: mov    w3, #0x80
0x190b8: bl     #0x2368 ; <duss_log_gen_head>
0x190bc: cbz    w0, #0x19570
0x190c0: ldr    x6, [sp, #0x28]
0x190c4: adrp   x3, #0x1e000
0x190c8: ldr    w7, [sp, #0x24]
0x190cc: adrp   x4, #0x1d000
0x190d0: ldr    w8, [sp, #0x34]
0x190d4: adrp   x5, #0x1a000
0x190d8: add    x3, x3, #0x1f5 ; "%s: %s(%s_%x): AWB_REGION: value count unexpected:%d.
"
0x190dc: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x190e0: add    x5, x5, #0x441 ; "co"
0x190e4: mov    w0, #0x51
0x190e8: str    w8, [sp]
0x190ec: b      #0x192c0
0x190f0: adrp   x0, #0x30000
0x190f4: adrp   x2, #0x1d000
0x190f8: add    x0, x0, #0x100 ; =0x30100
0x190fc: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x19100: mov    w1, #1
0x19104: bl     #0x2338 ; <log_mgr_check>
0x19108: tbz    w0, #0, #0x19428
0x1910c: bl     #0x2348 ; <co_thread_get>
0x19110: cbz    x0, #0x1938c
0x19114: adrp   x8, #0x1a000
0x19118: str    wzr, [sp, #0x24]
0x1911c: add    x8, x8, #0x440 ; =0x1a440
0x19120: add    x1, sp, #0x28
0x19124: add    x2, sp, #0x24
0x19128: str    x8, [sp, #0x28]
0x1912c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19130: adrp   x4, #0x1d000
0x19134: adrp   x5, #0x1e000
0x19138: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1913c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19140: mov    w0, #0x51
0x19144: mov    w6, #0x345
0x19148: mov    w1, #1
0x1914c: add    x2, sp, #0x38
0x19150: mov    w3, #0x80
0x19154: bl     #0x2368 ; <duss_log_gen_head>
0x19158: cbz    w0, #0x19180
0x1915c: adrp   x3, #0x1a000
0x19160: adrp   x4, #0x1d000
0x19164: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x19168: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1916c: mov    w0, #0x51
0x19170: mov    w5, #0x345
0x19174: mov    w1, #1
0x19178: add    x2, sp, #0x38
0x1917c: bl     #0x2378 ; <duss_log_print>
0x19180: adrp   x4, #0x1d000
0x19184: adrp   x5, #0x1e000
0x19188: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1918c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19190: mov    w0, #0x51
0x19194: mov    w6, #0x345
0x19198: mov    w1, #1
0x1919c: add    x2, sp, #0x38
0x191a0: mov    w3, #0x80
0x191a4: bl     #0x2368 ; <duss_log_gen_head>
0x191a8: cbz    w0, #0x19428
0x191ac: ldr    x6, [sp, #0x28]
0x191b0: adrp   x3, #0x1e000
0x191b4: ldr    w7, [sp, #0x24]
0x191b8: adrp   x4, #0x1d000
0x191bc: adrp   x5, #0x1a000
0x191c0: add    x3, x3, #0x147 ; "%s: %s(%s_%x): Get the AWB gain value failed!
"
0x191c4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x191c8: add    x5, x5, #0x441 ; "co"
0x191cc: mov    w0, #0x51
0x191d0: mov    w1, #1
0x191d4: add    x2, sp, #0x38
0x191d8: bl     #0x2378 ; <duss_log_print>
0x191dc: b      #0x19428
0x191e0: adrp   x0, #0x30000
0x191e4: adrp   x2, #0x1d000
0x191e8: add    x0, x0, #0x100 ; =0x30100
0x191ec: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x191f0: mov    w1, #1
0x191f4: bl     #0x2338 ; <log_mgr_check>
0x191f8: tbz    w0, #0, #0x19570
0x191fc: bl     #0x2348 ; <co_thread_get>
0x19200: cbz    x0, #0x19430
0x19204: adrp   x8, #0x1a000
0x19208: str    wzr, [sp, #0x24]
0x1920c: add    x8, x8, #0x440 ; =0x1a440
0x19210: add    x1, sp, #0x28
0x19214: add    x2, sp, #0x24
0x19218: str    x8, [sp, #0x28]
0x1921c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19220: adrp   x4, #0x1d000
0x19224: adrp   x5, #0x1e000
0x19228: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1922c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19230: mov    w0, #0x51
0x19234: mov    w6, #0x34b
0x19238: mov    w1, #1
0x1923c: add    x2, sp, #0x38
0x19240: mov    w3, #0x80
0x19244: bl     #0x2368 ; <duss_log_gen_head>
0x19248: cbz    w0, #0x19270
0x1924c: adrp   x3, #0x1a000
0x19250: adrp   x4, #0x1d000
0x19254: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x19258: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1925c: mov    w0, #0x51
0x19260: mov    w5, #0x34b
0x19264: mov    w1, #1
0x19268: add    x2, sp, #0x38
0x1926c: bl     #0x2378 ; <duss_log_print>
0x19270: adrp   x4, #0x1d000
0x19274: adrp   x5, #0x1e000
0x19278: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1927c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19280: mov    w0, #0x51
0x19284: mov    w6, #0x34b
0x19288: mov    w1, #1
0x1928c: add    x2, sp, #0x38
0x19290: mov    w3, #0x80
0x19294: bl     #0x2368 ; <duss_log_gen_head>
0x19298: cbz    w0, #0x19570
0x1929c: ldr    x6, [sp, #0x28]
0x192a0: adrp   x3, #0x1e000
0x192a4: ldr    w7, [sp, #0x24]
0x192a8: adrp   x4, #0x1d000
0x192ac: adrp   x5, #0x1a000
0x192b0: add    x3, x3, #0x19a ; "%s: %s(%s_%x): AWB_REGION: value type unexpected.
"
0x192b4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x192b8: add    x5, x5, #0x441 ; "co"
0x192bc: mov    w0, #0x51
0x192c0: mov    w1, #1
0x192c4: add    x2, sp, #0x38
0x192c8: bl     #0x2378 ; <duss_log_print>
0x192cc: b      #0x19570
0x192d0: ldrh   w8, [x0]
0x192d4: adrp   x2, #0x1d000
0x192d8: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x192dc: mov    w1, #4
0x192e0: str    w8, [x19]
0x192e4: ldrh   w8, [x0, #0xc]
0x192e8: adrp   x0, #0x30000
0x192ec: add    x0, x0, #0x100 ; =0x30100
0x192f0: str    w8, [x19, #4]
0x192f4: bl     #0x2338 ; <log_mgr_check>
0x192f8: tbz    w0, #0, #0x195c8
0x192fc: bl     #0x2348 ; <co_thread_get>
0x19300: cbz    x0, #0x19578
0x19304: adrp   x8, #0x1a000
0x19308: str    wzr, [sp, #0x24]
0x1930c: add    x8, x8, #0x440 ; =0x1a440
0x19310: add    x1, sp, #0x28
0x19314: add    x2, sp, #0x24
0x19318: str    x8, [sp, #0x28]
0x1931c: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19320: adrp   x4, #0x1d000
0x19324: adrp   x5, #0x1e000
0x19328: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1932c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19330: mov    w0, #0x51
0x19334: mov    w6, #0x357
0x19338: mov    w1, #4
0x1933c: add    x2, sp, #0x38
0x19340: mov    w3, #0x80
0x19344: bl     #0x2368 ; <duss_log_gen_head>
0x19348: cbz    w0, #0x195c8
0x1934c: ldr    x6, [sp, #0x28]
0x19350: adrp   x3, #0x1e000
0x19354: ldr    w7, [sp, #0x24]
0x19358: adrp   x4, #0x1d000
0x1935c: ldp    w8, w9, [x19]
0x19360: adrp   x5, #0x1a000
0x19364: add    x3, x3, #0x258 ; "%s: %s(%s_%x): rgain:%u, bgain:%u 
"
0x19368: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1936c: add    x5, x5, #0x441 ; "co"
0x19370: str    w9, [sp, #8]
0x19374: mov    w0, #0x51
0x19378: str    w8, [sp]
0x1937c: mov    w1, #4
0x19380: add    x2, sp, #0x38
0x19384: bl     #0x2378 ; <duss_log_print>
0x19388: b      #0x195c8
0x1938c: adrp   x4, #0x1d000
0x19390: adrp   x5, #0x1e000
0x19394: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19398: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x1939c: mov    w0, #0x51
0x193a0: mov    w6, #0x345
0x193a4: mov    w1, #1
0x193a8: add    x2, sp, #0x38
0x193ac: mov    w3, #0x80
0x193b0: bl     #0x2368 ; <duss_log_gen_head>
0x193b4: cbz    w0, #0x193dc
0x193b8: adrp   x3, #0x1a000
0x193bc: adrp   x4, #0x1d000
0x193c0: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x193c4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x193c8: mov    w0, #0x51
0x193cc: mov    w5, #0x345
0x193d0: mov    w1, #1
0x193d4: add    x2, sp, #0x38
0x193d8: bl     #0x2378 ; <duss_log_print>
0x193dc: adrp   x4, #0x1d000
0x193e0: adrp   x5, #0x1e000
0x193e4: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x193e8: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x193ec: mov    w0, #0x51
0x193f0: mov    w6, #0x345
0x193f4: mov    w1, #1
0x193f8: add    x2, sp, #0x38
0x193fc: mov    w3, #0x80
0x19400: bl     #0x2368 ; <duss_log_gen_head>
0x19404: cbz    w0, #0x19428
0x19408: adrp   x3, #0x1e000
0x1940c: adrp   x4, #0x1d000
0x19410: add    x3, x3, #0x176 ; "%s: Get the AWB gain value failed!
"
0x19414: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x19418: mov    w0, #0x51
0x1941c: mov    w1, #1
0x19420: add    x2, sp, #0x38
0x19424: bl     #0x2378 ; <duss_log_print>
0x19428: mov    w0, #-0x3e9
0x1942c: b      #0x195cc
0x19430: adrp   x4, #0x1d000
0x19434: adrp   x5, #0x1e000
0x19438: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1943c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19440: mov    w0, #0x51
0x19444: mov    w6, #0x34b
0x19448: mov    w1, #1
0x1944c: add    x2, sp, #0x38
0x19450: mov    w3, #0x80
0x19454: bl     #0x2368 ; <duss_log_gen_head>
0x19458: cbz    w0, #0x19480
0x1945c: adrp   x3, #0x1a000
0x19460: adrp   x4, #0x1d000
0x19464: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x19468: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1946c: mov    w0, #0x51
0x19470: mov    w5, #0x34b
0x19474: mov    w1, #1
0x19478: add    x2, sp, #0x38
0x1947c: bl     #0x2378 ; <duss_log_print>
0x19480: adrp   x4, #0x1d000
0x19484: adrp   x5, #0x1e000
0x19488: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1948c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19490: mov    w0, #0x51
0x19494: mov    w6, #0x34b
0x19498: mov    w1, #1
0x1949c: add    x2, sp, #0x38
0x194a0: mov    w3, #0x80
0x194a4: bl     #0x2368 ; <duss_log_gen_head>
0x194a8: cbz    w0, #0x19570
0x194ac: adrp   x3, #0x1e000
0x194b0: adrp   x4, #0x1d000
0x194b4: add    x3, x3, #0x1cd ; "%s: AWB_REGION: value type unexpected.
"
0x194b8: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x194bc: mov    w0, #0x51
0x194c0: mov    w1, #1
0x194c4: add    x2, sp, #0x38
0x194c8: bl     #0x2378 ; <duss_log_print>
0x194cc: b      #0x19570
0x194d0: adrp   x4, #0x1d000
0x194d4: adrp   x5, #0x1e000
0x194d8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x194dc: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x194e0: mov    w0, #0x51
0x194e4: mov    w6, #0x350
0x194e8: mov    w1, #1
0x194ec: add    x2, sp, #0x38
0x194f0: mov    w3, #0x80
0x194f4: bl     #0x2368 ; <duss_log_gen_head>
0x194f8: cbz    w0, #0x19520
0x194fc: adrp   x3, #0x1a000
0x19500: adrp   x4, #0x1d000
0x19504: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x19508: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1950c: mov    w0, #0x51
0x19510: mov    w5, #0x350
0x19514: mov    w1, #1
0x19518: add    x2, sp, #0x38
0x1951c: bl     #0x2378 ; <duss_log_print>
0x19520: adrp   x4, #0x1d000
0x19524: adrp   x5, #0x1e000
0x19528: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1952c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19530: mov    w0, #0x51
0x19534: mov    w6, #0x350
0x19538: mov    w1, #1
0x1953c: add    x2, sp, #0x38
0x19540: mov    w3, #0x80
0x19544: bl     #0x2368 ; <duss_log_gen_head>
0x19548: cbz    w0, #0x19570
0x1954c: ldr    w5, [sp, #0x34]
0x19550: adrp   x3, #0x1e000
0x19554: adrp   x4, #0x1d000
0x19558: add    x3, x3, #0x22c ; "%s: AWB_REGION: value count unexpected:%d.
"
0x1955c: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x19560: mov    w0, #0x51
0x19564: mov    w1, #1
0x19568: add    x2, sp, #0x38
0x1956c: bl     #0x2378 ; <duss_log_print>
0x19570: mov    w0, #-0x3eb
0x19574: b      #0x195cc
0x19578: adrp   x4, #0x1d000
0x1957c: adrp   x5, #0x1e000
0x19580: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19584: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19588: mov    w0, #0x51
0x1958c: mov    w6, #0x357
0x19590: mov    w1, #4
0x19594: add    x2, sp, #0x38
0x19598: mov    w3, #0x80
0x1959c: bl     #0x2368 ; <duss_log_gen_head>
0x195a0: cbz    w0, #0x195c8
0x195a4: ldp    w5, w6, [x19]
0x195a8: adrp   x3, #0x1e000
0x195ac: adrp   x4, #0x1d000
0x195b0: add    x3, x3, #0x27c ; "%s: rgain:%u, bgain:%u 
"
0x195b4: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x195b8: mov    w0, #0x51
0x195bc: mov    w1, #4
0x195c0: add    x2, sp, #0x38
0x195c4: bl     #0x2378 ; <duss_log_print>
0x195c8: mov    w0, wzr
0x195cc: ldr    x8, [x21, #0x28]
0x195d0: ldr    x9, [x22]
0x195d4: cmp    x8, x9
0x195d8: b.ne   #0x1971c
0x195dc: ldp    x29, x30, [sp, #0xe0]
0x195e0: ldp    x20, x19, [sp, #0xd0]
0x195e4: ldp    x22, x21, [sp, #0xc0]
0x195e8: add    sp, sp, #0xf0
0x195ec: ret    
0x195f0: bl     #0x2348 ; <co_thread_get>
0x195f4: cbnz   x0, #0x19720
0x195f8: adrp   x4, #0x1d000
0x195fc: adrp   x5, #0x1e000
0x19600: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19604: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19608: mov    w0, #0x51
0x1960c: mov    w6, #0x33f
0x19610: add    x2, sp, #0x38
0x19614: mov    w3, #0x80
0x19618: mov    w1, wzr
0x1961c: bl     #0x2368 ; <duss_log_gen_head>
0x19620: cbz    w0, #0x197a8
0x19624: adrp   x3, #0x1a000
0x19628: adrp   x4, #0x1e000
0x1962c: adrp   x5, #0x1d000
0x19630: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x19634: add    x4, x4, #0x54 ; "venc_param"
0x19638: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1963c: mov    w0, #0x51
0x19640: mov    w6, #0x33f
0x19644: add    x2, sp, #0x38
0x19648: mov    w1, wzr
0x1964c: bl     #0x2378 ; <duss_log_print>
0x19650: b      #0x197a8
0x19654: bl     #0x2348 ; <co_thread_get>
0x19658: cbnz   x0, #0x197c4
0x1965c: adrp   x4, #0x1d000
0x19660: adrp   x5, #0x1e000
0x19664: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19668: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x1966c: mov    w0, #0x51
0x19670: mov    w6, #0x340
0x19674: add    x2, sp, #0x38
0x19678: mov    w3, #0x80
0x1967c: mov    w1, wzr
0x19680: bl     #0x2368 ; <duss_log_gen_head>
0x19684: cbz    w0, #0x1984c
0x19688: adrp   x3, #0x1a000
0x1968c: adrp   x4, #0x1e000
0x19690: adrp   x5, #0x1d000
0x19694: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x19698: add    x4, x4, #0x13f ; "wb_gain"
0x1969c: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x196a0: mov    w0, #0x51
0x196a4: mov    w6, #0x340
0x196a8: add    x2, sp, #0x38
0x196ac: mov    w1, wzr
0x196b0: bl     #0x2378 ; <duss_log_print>
0x196b4: b      #0x1984c
0x196b8: bl     #0x2348 ; <co_thread_get>
0x196bc: cbnz   x0, #0x19868
0x196c0: adrp   x4, #0x1d000
0x196c4: adrp   x5, #0x1e000
0x196c8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x196cc: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x196d0: mov    w0, #0x51
0x196d4: mov    w6, #0x342
0x196d8: add    x2, sp, #0x38
0x196dc: mov    w3, #0x80
0x196e0: mov    w1, wzr
0x196e4: bl     #0x2368 ; <duss_log_gen_head>
0x196e8: cbz    w0, #0x198f0
0x196ec: adrp   x3, #0x1a000
0x196f0: adrp   x4, #0x1e000
0x196f4: adrp   x5, #0x1d000
0x196f8: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x196fc: add    x4, x4, #0x5f ; "cam_enc_param->metadata"
0x19700: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19704: mov    w0, #0x51
0x19708: mov    w6, #0x342
0x1970c: add    x2, sp, #0x38
0x19710: mov    w1, wzr
0x19714: bl     #0x2378 ; <duss_log_print>
0x19718: b      #0x198f0
0x1971c: bl     #0x23d8 ; <__stack_chk_fail>
0x19720: adrp   x8, #0x1a000
0x19724: str    wzr, [sp, #0x24]
0x19728: add    x8, x8, #0x440 ; =0x1a440
0x1972c: add    x1, sp, #0x28
0x19730: add    x2, sp, #0x24
0x19734: str    x8, [sp, #0x28]
0x19738: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x1973c: adrp   x19, #0x1d000
0x19740: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19744: adrp   x5, #0x1e000
0x19748: mov    w20, #0x33f
0x1974c: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19750: mov    w0, #0x51
0x19754: add    x2, sp, #0x38
0x19758: mov    w3, #0x80
0x1975c: mov    w1, wzr
0x19760: mov    x4, x19
0x19764: mov    w6, w20
0x19768: bl     #0x2368 ; <duss_log_gen_head>
0x1976c: cbz    w0, #0x197a8
0x19770: ldr    x5, [sp, #0x28]
0x19774: adrp   x3, #0x1a000
0x19778: ldr    w6, [sp, #0x24]
0x1977c: adrp   x4, #0x1a000
0x19780: adrp   x7, #0x1e000
0x19784: str    w20, [sp, #8]
0x19788: mov    w1, wzr
0x1978c: str    x19, [sp]
0x19790: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x19794: add    x4, x4, #0x441 ; "co"
0x19798: mov    w0, #0x51
0x1979c: add    x7, x7, #0x54 ; "venc_param"
0x197a0: add    x2, sp, #0x38
0x197a4: bl     #0x2378 ; <duss_log_print>
0x197a8: adrp   x4, #0x1d000
0x197ac: adrp   x5, #0x1e000
0x197b0: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x197b4: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x197b8: mov    w0, #0x51
0x197bc: mov    w6, #0x33f
0x197c0: b      #0x19908
0x197c4: adrp   x8, #0x1a000
0x197c8: str    wzr, [sp, #0x24]
0x197cc: add    x8, x8, #0x440 ; =0x1a440
0x197d0: add    x1, sp, #0x28
0x197d4: add    x2, sp, #0x24
0x197d8: str    x8, [sp, #0x28]
0x197dc: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x197e0: adrp   x19, #0x1d000
0x197e4: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x197e8: adrp   x5, #0x1e000
0x197ec: mov    w20, #0x340
0x197f0: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x197f4: mov    w0, #0x51
0x197f8: add    x2, sp, #0x38
0x197fc: mov    w3, #0x80
0x19800: mov    w1, wzr
0x19804: mov    x4, x19
0x19808: mov    w6, w20
0x1980c: bl     #0x2368 ; <duss_log_gen_head>
0x19810: cbz    w0, #0x1984c
0x19814: ldr    x5, [sp, #0x28]
0x19818: adrp   x3, #0x1a000
0x1981c: ldr    w6, [sp, #0x24]
0x19820: adrp   x4, #0x1a000
0x19824: adrp   x7, #0x1e000
0x19828: str    w20, [sp, #8]
0x1982c: mov    w1, wzr
0x19830: str    x19, [sp]
0x19834: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x19838: add    x4, x4, #0x441 ; "co"
0x1983c: mov    w0, #0x51
0x19840: add    x7, x7, #0x13f ; "wb_gain"
0x19844: add    x2, sp, #0x38
0x19848: bl     #0x2378 ; <duss_log_print>
0x1984c: adrp   x4, #0x1d000
0x19850: adrp   x5, #0x1e000
0x19854: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19858: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x1985c: mov    w0, #0x51
0x19860: mov    w6, #0x340
0x19864: b      #0x19908
0x19868: adrp   x8, #0x1a000
0x1986c: str    wzr, [sp, #0x24]
0x19870: add    x8, x8, #0x440 ; =0x1a440
0x19874: add    x1, sp, #0x28
0x19878: add    x2, sp, #0x24
0x1987c: str    x8, [sp, #0x28]
0x19880: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19884: adrp   x19, #0x1d000
0x19888: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1988c: adrp   x5, #0x1e000
0x19890: mov    w20, #0x342
0x19894: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19898: mov    w0, #0x51
0x1989c: add    x2, sp, #0x38
0x198a0: mov    w3, #0x80
0x198a4: mov    w1, wzr
0x198a8: mov    x4, x19
0x198ac: mov    w6, w20
0x198b0: bl     #0x2368 ; <duss_log_gen_head>
0x198b4: cbz    w0, #0x198f0
0x198b8: ldr    x5, [sp, #0x28]
0x198bc: adrp   x3, #0x1a000
0x198c0: ldr    w6, [sp, #0x24]
0x198c4: adrp   x4, #0x1a000
0x198c8: adrp   x7, #0x1e000
0x198cc: str    w20, [sp, #8]
0x198d0: mov    w1, wzr
0x198d4: str    x19, [sp]
0x198d8: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x198dc: add    x4, x4, #0x441 ; "co"
0x198e0: mov    w0, #0x51
0x198e4: add    x7, x7, #0x5f ; "cam_enc_param->metadata"
0x198e8: add    x2, sp, #0x38
0x198ec: bl     #0x2378 ; <duss_log_print>
0x198f0: adrp   x4, #0x1d000
0x198f4: adrp   x5, #0x1e000
0x198f8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x198fc: add    x5, x5, #0x129 ; "proresraw_wb_gain_get"
0x19900: mov    w0, #0x51
0x19904: mov    w6, #0x342
0x19908: add    x2, sp, #0x38
0x1990c: mov    w3, #0x80
0x19910: mov    w1, wzr
0x19914: bl     #0x2368 ; <duss_log_gen_head>
0x19918: cbz    w0, #0x19934
0x1991c: adrp   x3, #0x1a000
0x19920: add    x3, x3, #0x550 ; "Assertion Comment: "
0x19924: mov    w0, #0x51
0x19928: add    x2, sp, #0x38
0x1992c: mov    w1, wzr
0x19930: bl     #0x2378 ; <duss_log_print>
0x19934: adrp   x0, #0x1a000
0x19938: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x1993c: bl     #0x23e8 ; <log_to_kmsg>
0x19940: adrp   x0, #0x1a000
0x19944: add    x0, x0, #0x57f ; "Camera:	"
0x19948: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x1994c: bl     #0x2408 ; <is_running_in_cam_sil>
0x19950: tbz    w0, #0, #0x19960
0x19954: mov    x0, xzr
0x19958: bl     #0x2418 ; <fflush>
0x1995c: bl     #0x2428 ; <abort>
0x19960: mov    w0, #1
0x19964: bl     #0x2438 ; <exit>
0x19968: str    x28, [sp, #-0x40]!
0x1996c: stp    x22, x21, [sp, #0x10]
0x19970: stp    x20, x19, [sp, #0x20]
0x19974: stp    x29, x30, [sp, #0x30]
0x19978: add    x29, sp, #0x30
0x1997c: sub    sp, sp, #0x2c0
0x19980: mrs    x21, tpidr_el0
0x19984: mov    x19, x1
0x19988: ldr    x8, [x21, #0x28]
0x1998c: add    x22, sp, #0x18
0x19990: mov    x20, x0
0x19994: add    x0, sp, #0xb8
0x19998: mov    w2, #0x200
0x1999c: mov    w1, wzr
0x199a0: str    x8, [x22]
0x199a4: bl     #0x22d8 ; <memset>
0x199a8: add    x0, sp, #0xb8
0x199ac: str    xzr, [sp, #0x30]
0x199b0: mov    w2, #0x200
0x199b4: mov    w3, #0x200
0x199b8: mov    x1, x20
0x199bc: bl     #0x2838 ; <__strlcpy_chk>
0x199c0: adrp   x1, #0x1e000
0x199c4: add    x1, x1, #0x311 ; ","
0x199c8: add    x0, sp, #0xb8
0x199cc: add    x2, sp, #0x30
0x199d0: bl     #0x2848 ; <strtok_r>
0x199d4: cbz    x0, #0x19ae4
0x199d8: bl     #0x2858 ; <atof>
0x199dc: adrp   x1, #0x1e000
0x199e0: str    d0, [x19]
0x199e4: add    x1, x1, #0x311 ; ","
0x199e8: add    x2, sp, #0x30
0x199ec: mov    x0, xzr
0x199f0: bl     #0x2848 ; <strtok_r>
0x199f4: cbz    x0, #0x19cc8
0x199f8: bl     #0x2858 ; <atof>
0x199fc: adrp   x1, #0x1e000
0x19a00: str    d0, [x19, #8]
0x19a04: add    x1, x1, #0x311 ; ","
0x19a08: add    x2, sp, #0x30
0x19a0c: mov    x0, xzr
0x19a10: bl     #0x2848 ; <strtok_r>
0x19a14: cbz    x0, #0x19cc8
0x19a18: bl     #0x2858 ; <atof>
0x19a1c: adrp   x1, #0x1e000
0x19a20: str    d0, [x19, #0x10]
0x19a24: add    x1, x1, #0x311 ; ","
0x19a28: add    x2, sp, #0x30
0x19a2c: mov    x0, xzr
0x19a30: bl     #0x2848 ; <strtok_r>
0x19a34: cbz    x0, #0x19cc8
0x19a38: bl     #0x2858 ; <atof>
0x19a3c: adrp   x1, #0x1e000
0x19a40: str    d0, [x19, #0x18]
0x19a44: add    x1, x1, #0x311 ; ","
0x19a48: add    x2, sp, #0x30
0x19a4c: mov    x0, xzr
0x19a50: bl     #0x2848 ; <strtok_r>
0x19a54: cbz    x0, #0x19cc8
0x19a58: bl     #0x2858 ; <atof>
0x19a5c: adrp   x1, #0x1e000
0x19a60: str    d0, [x19, #0x20]
0x19a64: add    x1, x1, #0x311 ; ","
0x19a68: add    x2, sp, #0x30
0x19a6c: mov    x0, xzr
0x19a70: bl     #0x2848 ; <strtok_r>
0x19a74: cbz    x0, #0x19cc8
0x19a78: bl     #0x2858 ; <atof>
0x19a7c: adrp   x1, #0x1e000
0x19a80: str    d0, [x19, #0x28]
0x19a84: add    x1, x1, #0x311 ; ","
0x19a88: add    x2, sp, #0x30
0x19a8c: mov    x0, xzr
0x19a90: bl     #0x2848 ; <strtok_r>
0x19a94: cbz    x0, #0x19cc8
0x19a98: bl     #0x2858 ; <atof>
0x19a9c: adrp   x1, #0x1e000
0x19aa0: str    d0, [x19, #0x30]
0x19aa4: add    x1, x1, #0x311 ; ","
0x19aa8: add    x2, sp, #0x30
0x19aac: mov    x0, xzr
0x19ab0: bl     #0x2848 ; <strtok_r>
0x19ab4: cbz    x0, #0x19cc8
0x19ab8: bl     #0x2858 ; <atof>
0x19abc: adrp   x1, #0x1e000
0x19ac0: str    d0, [x19, #0x38]
0x19ac4: add    x1, x1, #0x311 ; ","
0x19ac8: add    x2, sp, #0x30
0x19acc: mov    x0, xzr
0x19ad0: bl     #0x2848 ; <strtok_r>
0x19ad4: mov    x20, x0
0x19ad8: cbz    x20, #0x19bdc
0x19adc: add    x19, x19, #0x40 ; "at)"
0x19ae0: b      #0x19be8
0x19ae4: adrp   x0, #0x30000
0x19ae8: adrp   x2, #0x1d000
0x19aec: add    x0, x0, #0x100 ; =0x30100
0x19af0: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x19af4: mov    w1, #1
0x19af8: bl     #0x2338 ; <log_mgr_check>
0x19afc: tbz    w0, #0, #0x19c9c
0x19b00: bl     #0x2348 ; <co_thread_get>
0x19b04: cbz    x0, #0x19bfc
0x19b08: adrp   x8, #0x1a000
0x19b0c: str    wzr, [sp, #0x24]
0x19b10: add    x8, x8, #0x440 ; =0x1a440
0x19b14: add    x1, sp, #0x28
0x19b18: add    x2, sp, #0x24
0x19b1c: str    x8, [sp, #0x28]
0x19b20: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19b24: adrp   x4, #0x1d000
0x19b28: adrp   x5, #0x1e000
0x19b2c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19b30: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19b34: mov    w0, #0x51
0x19b38: mov    w6, #0x1f9
0x19b3c: mov    w1, #1
0x19b40: add    x2, sp, #0x38
0x19b44: mov    w3, #0x80
0x19b48: bl     #0x2368 ; <duss_log_gen_head>
0x19b4c: cbz    w0, #0x19b74
0x19b50: adrp   x3, #0x1a000
0x19b54: adrp   x4, #0x1d000
0x19b58: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x19b5c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19b60: mov    w0, #0x51
0x19b64: mov    w5, #0x1f9
0x19b68: mov    w1, #1
0x19b6c: add    x2, sp, #0x38
0x19b70: bl     #0x2378 ; <duss_log_print>
0x19b74: adrp   x4, #0x1d000
0x19b78: adrp   x5, #0x1e000
0x19b7c: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19b80: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19b84: mov    w0, #0x51
0x19b88: mov    w6, #0x1f9
0x19b8c: mov    w1, #1
0x19b90: add    x2, sp, #0x38
0x19b94: mov    w3, #0x80
0x19b98: bl     #0x2368 ; <duss_log_gen_head>
0x19b9c: cbz    w0, #0x19c9c
0x19ba0: ldr    x6, [sp, #0x28]
0x19ba4: adrp   x3, #0x1e000
0x19ba8: ldr    w7, [sp, #0x24]
0x19bac: adrp   x4, #0x1d000
0x19bb0: adrp   x5, #0x1a000
0x19bb4: add    x8, sp, #0xb8
0x19bb8: add    x3, x3, #0x324 ; "%s: %s(%s_%x): %s cann't be delimited by ','
"
0x19bbc: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x19bc0: add    x5, x5, #0x441 ; "co"
0x19bc4: str    x8, [sp]
0x19bc8: mov    w0, #0x51
0x19bcc: mov    w1, #1
0x19bd0: add    x2, sp, #0x38
0x19bd4: bl     #0x2378 ; <duss_log_print>
0x19bd8: b      #0x19c9c
0x19bdc: ldr    x0, [sp, #0x30]
0x19be0: bl     #0x2858 ; <atof>
0x19be4: str    d0, [x19, #0x40]!
0x19be8: mov    x0, x20
0x19bec: bl     #0x2858 ; <atof>
0x19bf0: mov    w0, wzr
0x19bf4: str    d0, [x19]
0x19bf8: b      #0x19ca0
0x19bfc: adrp   x4, #0x1d000
0x19c00: adrp   x5, #0x1e000
0x19c04: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19c08: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19c0c: mov    w0, #0x51
0x19c10: mov    w6, #0x1f9
0x19c14: mov    w1, #1
0x19c18: add    x2, sp, #0x38
0x19c1c: mov    w3, #0x80
0x19c20: bl     #0x2368 ; <duss_log_gen_head>
0x19c24: cbz    w0, #0x19c4c
0x19c28: adrp   x3, #0x1a000
0x19c2c: adrp   x4, #0x1d000
0x19c30: add    x3, x3, #0x5ce ; "FILE:%s, LINE:%d"
0x19c34: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19c38: mov    w0, #0x51
0x19c3c: mov    w5, #0x1f9
0x19c40: mov    w1, #1
0x19c44: add    x2, sp, #0x38
0x19c48: bl     #0x2378 ; <duss_log_print>
0x19c4c: adrp   x4, #0x1d000
0x19c50: adrp   x5, #0x1e000
0x19c54: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19c58: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19c5c: mov    w0, #0x51
0x19c60: mov    w6, #0x1f9
0x19c64: mov    w1, #1
0x19c68: add    x2, sp, #0x38
0x19c6c: mov    w3, #0x80
0x19c70: bl     #0x2368 ; <duss_log_gen_head>
0x19c74: cbz    w0, #0x19c9c
0x19c78: adrp   x3, #0x1e000
0x19c7c: adrp   x4, #0x1d000
0x19c80: add    x3, x3, #0x352 ; "%s: %s cann't be delimited by ','
"
0x19c84: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x19c88: mov    w0, #0x51
0x19c8c: mov    w1, #1
0x19c90: add    x2, sp, #0x38
0x19c94: add    x5, sp, #0xb8
0x19c98: bl     #0x2378 ; <duss_log_print>
0x19c9c: mov    w0, #-0x3e9
0x19ca0: ldr    x8, [x21, #0x28]
0x19ca4: ldr    x9, [x22]
0x19ca8: cmp    x8, x9
0x19cac: b.ne   #0x19e2c
0x19cb0: add    sp, sp, #0x2c0
0x19cb4: ldp    x29, x30, [sp, #0x30]
0x19cb8: ldp    x20, x19, [sp, #0x20]
0x19cbc: ldp    x22, x21, [sp, #0x10]
0x19cc0: ldr    x28, [sp], #0x40
0x19cc4: ret    
0x19cc8: bl     #0x2348 ; <co_thread_get>
0x19ccc: cbnz   x0, #0x19d2c
0x19cd0: adrp   x4, #0x1d000
0x19cd4: adrp   x5, #0x1e000
0x19cd8: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19cdc: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19ce0: mov    w0, #0x51
0x19ce4: mov    w6, #0x204
0x19ce8: add    x2, sp, #0x38
0x19cec: mov    w3, #0x80
0x19cf0: mov    w1, wzr
0x19cf4: bl     #0x2368 ; <duss_log_gen_head>
0x19cf8: cbz    w0, #0x19db4
0x19cfc: adrp   x3, #0x1a000
0x19d00: adrp   x4, #0x1b000
0x19d04: adrp   x5, #0x1d000
0x19d08: add    x3, x3, #0x528 ; "Assertion Failed: %s File:%s Lineno:%d
"
0x19d0c: add    x4, x4, #0xf7 ; "0"
0x19d10: add    x5, x5, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19d14: mov    w0, #0x51
0x19d18: mov    w6, #0x204
0x19d1c: add    x2, sp, #0x38
0x19d20: mov    w1, wzr
0x19d24: bl     #0x2378 ; <duss_log_print>
0x19d28: b      #0x19db4
0x19d2c: adrp   x8, #0x1a000
0x19d30: str    wzr, [sp, #0x24]
0x19d34: add    x8, x8, #0x440 ; =0x1a440
0x19d38: add    x1, sp, #0x28
0x19d3c: add    x2, sp, #0x24
0x19d40: str    x8, [sp, #0x28]
0x19d44: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19d48: adrp   x19, #0x1d000
0x19d4c: add    x19, x19, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19d50: adrp   x5, #0x1e000
0x19d54: mov    w20, #0x204
0x19d58: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19d5c: mov    w0, #0x51
0x19d60: add    x2, sp, #0x38
0x19d64: mov    w3, #0x80
0x19d68: mov    w1, wzr
0x19d6c: mov    x4, x19
0x19d70: mov    w6, w20
0x19d74: bl     #0x2368 ; <duss_log_gen_head>
0x19d78: cbz    w0, #0x19db4
0x19d7c: ldr    x5, [sp, #0x28]
0x19d80: adrp   x3, #0x1a000
0x19d84: ldr    w6, [sp, #0x24]
0x19d88: adrp   x4, #0x1a000
0x19d8c: adrp   x7, #0x1b000
0x19d90: str    w20, [sp, #8]
0x19d94: mov    w1, wzr
0x19d98: str    x19, [sp]
0x19d9c: add    x3, x3, #0x4ce ; "%s(%s_%x): Assertion Failed: %s File:%s Lineno:%d
"
0x19da0: add    x4, x4, #0x441 ; "co"
0x19da4: mov    w0, #0x51
0x19da8: add    x7, x7, #0xf7 ; "0"
0x19dac: add    x2, sp, #0x38
0x19db0: bl     #0x2378 ; <duss_log_print>
0x19db4: adrp   x4, #0x1d000
0x19db8: adrp   x5, #0x1e000
0x19dbc: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19dc0: add    x5, x5, #0x313 ; "_xyz2cam_extract"
0x19dc4: mov    w0, #0x51
0x19dc8: mov    w6, #0x204
0x19dcc: add    x2, sp, #0x38
0x19dd0: mov    w3, #0x80
0x19dd4: mov    w1, wzr
0x19dd8: bl     #0x2368 ; <duss_log_gen_head>
0x19ddc: cbz    w0, #0x19df8
0x19de0: adrp   x3, #0x1a000
0x19de4: add    x3, x3, #0x550 ; "Assertion Comment: "
0x19de8: mov    w0, #0x51
0x19dec: add    x2, sp, #0x38
0x19df0: mov    w1, wzr
0x19df4: bl     #0x2378 ; <duss_log_print>
0x19df8: adrp   x0, #0x1a000
0x19dfc: add    x0, x0, #0x564 ; "Camera Assertion Comment: "
0x19e00: bl     #0x23e8 ; <log_to_kmsg>
0x19e04: adrp   x0, #0x1a000
0x19e08: add    x0, x0, #0x57f ; "Camera:	"
0x19e0c: bl     #0x23f8 ; <duss_log_dump_backtrace>
0x19e10: bl     #0x2408 ; <is_running_in_cam_sil>
0x19e14: tbz    w0, #0, #0x19e24
0x19e18: mov    x0, xzr
0x19e1c: bl     #0x2418 ; <fflush>
0x19e20: bl     #0x2428 ; <abort>
0x19e24: mov    w0, #1
0x19e28: bl     #0x2438 ; <exit>
0x19e2c: bl     #0x23d8 ; <__stack_chk_fail>
0x19e30: sub    sp, sp, #0x170
0x19e34: stp    d15, d14, [sp, #0xe0]
0x19e38: stp    d13, d12, [sp, #0xf0]
0x19e3c: stp    d11, d10, [sp, #0x100]
0x19e40: stp    d9, d8, [sp, #0x110]
0x19e44: stp    x28, x25, [sp, #0x120]
0x19e48: stp    x24, x23, [sp, #0x130]
0x19e4c: stp    x22, x21, [sp, #0x140]
0x19e50: stp    x20, x19, [sp, #0x150]
0x19e54: stp    x29, x30, [sp, #0x160]
0x19e58: add    x29, sp, #0x160
0x19e5c: fmov   d2, #1.50000000
0x19e60: adrp   x22, #0x1e000
0x19e64: fmov   d3, #6.00000000
0x19e68: mrs    x21, tpidr_el0
0x19e6c: fmov   d4, #3.00000000
0x19e70: add    x22, x22, #0x740 ; =0x1e740
0x19e74: fadd   d5, d0, d0
0x19e78: ldr    x8, [x21, #0x28]
0x19e7c: fmov   d9, xzr
0x19e80: mov    x19, xzr
0x19e84: fmov   d15, #1.00000000
0x19e88: mov    x23, xzr
0x19e8c: fsub   d0, d2, d0
0x19e90: add    x20, sp, #0x40
0x19e94: fmul   d2, d1, d3
0x19e98: add    x24, x22, #0x38 ; "%d %d
"
0x19e9c: fmul   d1, d1, d4
0x19ea0: mov    x25, #0x100000000
0x19ea4: str    x8, [x20]
0x19ea8: mov    v8.16b, v9.16b
0x19eac: mov    v13.16b, v9.16b
0x19eb0: fadd   d0, d0, d2
0x19eb4: fdiv   d2, d5, d0
0x19eb8: fdiv   d3, d1, d0
0x19ebc: ldr    d10, [x24]
0x19ec0: fmul   d0, d10, d10
0x19ec4: fadd   d1, d0, d15
0x19ec8: fsqrt  d0, d1
0x19ecc: fcmp   d0, d0
0x19ed0: b.vc   #0x19eec
0x19ed4: mov    v0.16b, v1.16b
0x19ed8: mov    v11.16b, v2.16b
0x19edc: mov    v12.16b, v3.16b
0x19ee0: bl     #0x2868 ; <sqrt>
0x19ee4: mov    v3.16b, v12.16b
0x19ee8: mov    v2.16b, v11.16b
0x19eec: fdiv   d11, d10, d0
0x19ef0: cmp    x19, #0x1d
0x19ef4: ldp    d10, d14, [x24, #-0x10]
0x19ef8: fsub   d1, d3, d14
0x19efc: fdiv   d12, d15, d0
0x19f00: fsub   d0, d2, d10
0x19f04: fmul   d0, d11, d0
0x19f08: fmul   d1, d12, d1
0x19f0c: fsub   d0, d1, d0
0x19f10: b.eq   #0x19f48
0x19f14: fcmp   d0, #0.0
0x19f18: b.ls   #0x19f48
0x19f1c: mov    v8.16b, v12.16b
0x19f20: add    x23, x23, x25
0x19f24: mov    v13.16b, v11.16b
0x19f28: add    x19, x19, #1 ; "proresraw_venc_eng_open_device"
0x19f2c: mov    v9.16b, v0.16b
0x19f30: add    x24, x24, #0x20 ; "is_valid_input_format(pixel_format)"
0x19f34: cmp    x19, #0x1e
0x19f38: b.lo   #0x19ebc
0x19f3c: fmov   d15, xzr
0x19f40: mov    v1.16b, v15.16b
0x19f44: b      #0x1a150
0x19f48: fmov   d1, xzr
0x19f4c: stp    d3, d2, [sp, #0x28]
0x19f50: fmin   d0, d0, d1
0x19f54: fneg   d2, d0
0x19f58: cbz    w19, #0x19f64
0x19f5c: fsub   d0, d9, d0
0x19f60: fdiv   d1, d2, d0
0x19f64: str    d2, [sp, #0x18]
0x19f68: asr    x8, x23, #0x1b
0x19f6c: fsub   d2, d15, d1
0x19f70: ldur   d3, [x24, #-0x18]
0x19f74: ldr    d0, [x22, x8]
0x19f78: adrp   x8, #0x1a000
0x19f7c: str    d1, [sp, #0x38]
0x19f80: adrp   x0, #0x30000
0x19f84: adrp   x2, #0x1d000
0x19f88: add    x0, x0, #0x100 ; =0x30100
0x19f8c: stp    d0, d3, [sp, #8]
0x19f90: fmul   d0, d1, d0
0x19f94: fmul   d1, d2, d3
0x19f98: mov    w1, #5
0x19f9c: add    x2, x2, #0xb1c ; "PRORESRAWMETA"
0x19fa0: str    d2, [sp, #0x20]
0x19fa4: asr    x23, x23, #0x20
0x19fa8: fadd   d0, d0, d1
0x19fac: ldr    d1, [x8, #0x340]
0x19fb0: fdiv   d15, d1, d0
0x19fb4: bl     #0x2338 ; <log_mgr_check>
0x19fb8: tbz    w0, #0, #0x1a0c0
0x19fbc: add    x19, x19, #1 ; "proresraw_venc_eng_open_device"
0x19fc0: bl     #0x2348 ; <co_thread_get>
0x19fc4: cbz    x0, #0x1a05c
0x19fc8: adrp   x8, #0x1a000
0x19fcc: str    wzr, [sp, #0x4c]
0x19fd0: add    x8, x8, #0x440 ; =0x1a440
0x19fd4: add    x1, sp, #0x50
0x19fd8: add    x2, sp, #0x4c
0x19fdc: str    x8, [sp, #0x50]
0x19fe0: bl     #0x2358 ; <co_thread_get_current_co_name_co_id>
0x19fe4: adrp   x4, #0x1d000
0x19fe8: adrp   x5, #0x1e000
0x19fec: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x19ff0: add    x5, x5, #0x3bb ; "xy2cct"
0x19ff4: mov    w0, #0x51
0x19ff8: mov    w6, #0x112
0x19ffc: mov    w1, #3
0x1a000: add    x2, sp, #0x58
0x1a004: mov    w3, #0x80
0x1a008: bl     #0x2368 ; <duss_log_gen_head>
0x1a00c: cbz    w0, #0x1a0c0
0x1a010: mov    v0.16b, v15.16b
0x1a014: ldr    x6, [sp, #0x50]
0x1a018: mov    v5.16b, v9.16b
0x1a01c: ldr    w7, [sp, #0x4c]
0x1a020: adrp   x3, #0x1e000
0x1a024: ldr    d2, [sp, #0x38]
0x1a028: adrp   x4, #0x1d000
0x1a02c: ldr    d4, [sp, #0x18]
0x1a030: adrp   x5, #0x1a000
0x1a034: str    w19, [sp]
0x1a038: ldp    d1, d3, [sp, #8]
0x1a03c: add    x3, x3, #0x3c2 ; "%s: %s(%s_%x): !!%02d-:%lf %lf %lf %lf %lf %lf
"
0x1a040: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1a044: add    x5, x5, #0x441 ; "co"
0x1a048: mov    w0, #0x51
0x1a04c: mov    w1, #3
0x1a050: add    x2, sp, #0x58
0x1a054: bl     #0x2378 ; <duss_log_print>
0x1a058: b      #0x1a0c0
0x1a05c: adrp   x4, #0x1d000
0x1a060: adrp   x5, #0x1e000
0x1a064: add    x4, x4, #0xa72 ; "hardware/dji/common/camera/dcam_resource_package/filter/recording/platform/eagle2/venc_eng"
0x1a068: add    x5, x5, #0x3bb ; "xy2cct"
0x1a06c: mov    w0, #0x51
0x1a070: mov    w6, #0x112
0x1a074: mov    w1, #3
0x1a078: add    x2, sp, #0x58
0x1a07c: mov    w3, #0x80
0x1a080: bl     #0x2368 ; <duss_log_gen_head>
0x1a084: cbz    w0, #0x1a0c0
0x1a088: mov    v0.16b, v15.16b
0x1a08c: adrp   x3, #0x1e000
0x1a090: mov    v5.16b, v9.16b
0x1a094: adrp   x4, #0x1d000
0x1a098: ldp    d1, d3, [sp, #8]
0x1a09c: ldr    d2, [sp, #0x38]
0x1a0a0: add    x3, x3, #0x3f2 ; "%s: !!%02d-:%lf %lf %lf %lf %lf %lf
"
0x1a0a4: ldr    d4, [sp, #0x18]
0x1a0a8: add    x4, x4, #0xb1c ; "PRORESRAWMETA"
0x1a0ac: mov    w0, #0x51
0x1a0b0: mov    w1, #3
0x1a0b4: add    x2, sp, #0x58
0x1a0b8: mov    w5, w19
0x1a0bc: bl     #0x2378 ; <duss_log_print>
0x1a0c0: ldr    d6, [sp, #0x20]
0x1a0c4: add    x8, x22, x23, lsl #5
0x1a0c8: ldr    d5, [sp, #0x38]
0x1a0cc: fmul   d0, d12, d6
0x1a0d0: fmul   d1, d8, d5
0x1a0d4: fmul   d2, d11, d6
0x1a0d8: fmul   d3, d13, d5
0x1a0dc: fmul   d4, d10, d6
0x1a0e0: fadd   d9, d1, d0
0x1a0e4: fadd   d8, d3, d2
0x1a0e8: ldp    d2, d3, [x8, #8]
0x1a0ec: fmul   d0, d9, d9
0x1a0f0: fmul   d2, d5, d2
0x1a0f4: fmul   d1, d8, d8
0x1a0f8: fmul   d3, d5, d3
0x1a0fc: fmul   d5, d14, d6
0x1a100: fadd   d2, d4, d2
0x1a104: ldr    d4, [sp, #0x30]
0x1a108: fadd   d1, d0, d1
0x1a10c: fadd   d3, d5, d3
0x1a110: fsub   d10, d4, d2
0x1a114: ldr    d2, [sp, #0x28]
0x1a118: fsqrt  d0, d1
0x1a11c: fsub   d11, d2, d3
0x1a120: fcmp   d0, d0
0x1a124: b.vc   #0x1a130
0x1a128: mov    v0.16b, v1.16b
0x1a12c: bl     #0x2868 ; <sqrt>
0x1a130: fdiv   d1, d9, d0
0x1a134: adrp   x8, #0x1a000
0x1a138: fdiv   d0, d8, d0
0x1a13c: fmul   d1, d10, d1
0x1a140: fmul   d0, d0, d11
0x1a144: fadd   d0, d1, d0
0x1a148: ldr    d1, [x8, #0x348]
0x1a14c: fmul   d1, d0, d1
0x1a150: ldr    x8, [x21, #0x28]
0x1a154: ldr    x9, [x20]
0x1a158: cmp    x8, x9
0x1a15c: b.ne   #0x1a190
0x1a160: mov    v0.16b, v15.16b
0x1a164: ldp    x29, x30, [sp, #0x160]
0x1a168: ldp    x20, x19, [sp, #0x150]
0x1a16c: ldp    x22, x21, [sp, #0x140]
0x1a170: ldp    x24, x23, [sp, #0x130]
0x1a174: ldp    x28, x25, [sp, #0x120]
0x1a178: ldp    d9, d8, [sp, #0x110]
0x1a17c: ldp    d11, d10, [sp, #0x100]
0x1a180: ldp    d13, d12, [sp, #0xf0]
0x1a184: ldp    d15, d14, [sp, #0xe0]
0x1a188: add    sp, sp, #0x170
0x1a18c: ret    
0x1a190: bl     #0x23d8 ; <__stack_chk_fail>
