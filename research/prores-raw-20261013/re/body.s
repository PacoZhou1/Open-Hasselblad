 0x6320: stp    x28, x27, [sp, #-0x60]!
 0x6324: stp    x26, x25, [sp, #0x10]
 0x6328: stp    x24, x23, [sp, #0x20]
 0x632c: stp    x22, x21, [sp, #0x30]
 0x6330: stp    x20, x19, [sp, #0x40]
 0x6334: stp    x29, x30, [sp, #0x50]
 0x6338: mov    x8, x0
 0x633c: mov    w0, #0xd2bb
 0x6340: mov    w3, #0xd391
 0x6344: ldp    w14, w29, [x8, #8]
 0x6348: ldp    w10, w30, [x8, #0x10]
 0x634c: movk   w0, #0x2ad7, lsl #16
 0x6350: movk   w3, #0xeb86, lsl #16
 0x6354: eor    w9, w30, w10
 0x6358: ldr    w21, [x1]
 0x635c: and    w9, w9, w29
 0x6360: eor    w9, w9, w30
 0x6364: add    w9, w14, w9
 0x6368: mov    w11, #0xa478
 0x636c: str    w21, [x8, #0x58]
 0x6370: add    w9, w9, w21
 0x6374: ldr    w6, [x1, #4]
 0x6378: movk   w11, #0xd76a, lsl #16
 0x637c: add    w9, w9, w11
 0x6380: eor    w11, w10, w29
 0x6384: add    w4, w30, w6
 0x6388: str    w6, [x8, #0x5c]
 0x638c: ror    w9, w9, #0x19
 0x6390: mov    w12, #0xb756
 0x6394: movk   w12, #0xe8c7, lsl #16
 0x6398: add    w9, w9, w29
 0x639c: and    w11, w9, w11
 0x63a0: eor    w11, w11, w10
 0x63a4: add    w11, w4, w11
 0x63a8: ldr    w4, [x1, #8]
 0x63ac: add    w11, w11, w12
 0x63b0: eor    w5, w9, w29
 0x63b4: mov    w12, #0x70db
 0x63b8: ror    w11, w11, #0x14
 0x63bc: str    w4, [x8, #0x60]
 0x63c0: add    w7, w10, w4
 0x63c4: ldr    w20, [x1, #0xc]
 0x63c8: movk   w12, #0x2420, lsl #16
 0x63cc: add    w11, w11, w9
 0x63d0: and    w5, w11, w5
 0x63d4: eor    w5, w5, w29
 0x63d8: str    w20, [x8, #0x64]
 0x63dc: add    w5, w7, w5
 0x63e0: add    w5, w5, w12
 0x63e4: eor    w19, w11, w9
 0x63e8: add    w7, w29, w20
 0x63ec: ror    w5, w5, #0xf
 0x63f0: mov    w12, #0xceee
 0x63f4: movk   w12, #0xc1bd, lsl #16
 0x63f8: add    w22, w5, w11
 0x63fc: and    w5, w22, w19
 0x6400: eor    w5, w5, w9
 0x6404: add    w7, w7, w5
 0x6408: ldr    w5, [x1, #0x10]
 0x640c: add    w7, w7, w12
 0x6410: eor    w19, w22, w11
 0x6414: mov    w12, #0xfaf
 0x6418: ror    w7, w7, #0xa
 0x641c: str    w5, [x8, #0x68]
 0x6420: add    w9, w9, w5
 0x6424: ldr    w24, [x1, #0x14]
 0x6428: movk   w12, #0xf57c, lsl #16
 0x642c: add    w7, w7, w22
 0x6430: and    w19, w7, w19
 0x6434: eor    w19, w19, w11
 0x6438: str    w24, [x8, #0x6c]
 0x643c: add    w9, w9, w19
 0x6440: add    w9, w9, w12
 0x6444: eor    w19, w7, w22
 0x6448: add    w11, w11, w24
 0x644c: ror    w9, w9, #0x19
 0x6450: mov    w12, #0xc62a
 0x6454: movk   w12, #0x4787, lsl #16
 0x6458: add    w9, w9, w7
 0x645c: and    w19, w9, w19
 0x6460: eor    w19, w19, w22
 0x6464: add    w11, w11, w19
 0x6468: ldr    w19, [x1, #0x18]
 0x646c: add    w11, w11, w12
 0x6470: eor    w23, w9, w7
 0x6474: mov    w12, #0x4613
 0x6478: ror    w11, w11, #0x14
 0x647c: str    w19, [x8, #0x70]
 0x6480: add    w22, w22, w19
 0x6484: ldr    w28, [x1, #0x1c]
 0x6488: movk   w12, #0xa830, lsl #16
 0x648c: add    w11, w11, w9
 0x6490: and    w23, w11, w23
 0x6494: eor    w23, w23, w7
 0x6498: str    w28, [x8, #0x74]
 0x649c: add    w22, w22, w23
 0x64a0: add    w22, w22, w12
 0x64a4: eor    w23, w11, w9
 0x64a8: add    w7, w7, w28
 0x64ac: ror    w22, w22, #0xf
 0x64b0: mov    w12, #0x9501
 0x64b4: movk   w12, #0xfd46, lsl #16
 0x64b8: add    w22, w22, w11
 0x64bc: and    w23, w22, w23
 0x64c0: eor    w23, w23, w9
 0x64c4: add    w7, w7, w23
 0x64c8: ldr    w23, [x1, #0x20]
 0x64cc: add    w7, w7, w12
 0x64d0: eor    w25, w22, w11
 0x64d4: mov    w12, #0x98d8
 0x64d8: ror    w7, w7, #0xa
 0x64dc: str    w23, [x8, #0x78]
 0x64e0: add    w9, w9, w23
 0x64e4: movk   w12, #0x6980, lsl #16
 0x64e8: add    w26, w7, w22
 0x64ec: and    w7, w26, w25
 0x64f0: eor    w7, w7, w11
 0x64f4: add    w9, w9, w7
 0x64f8: ldr    w7, [x1, #0x24]
 0x64fc: add    w9, w9, w12
 0x6500: eor    w25, w26, w22
 0x6504: mov    w15, #0xd7be
 0x6508: ror    w9, w9, #0x19
 0x650c: str    w7, [x8, #0x7c]
 0x6510: add    w11, w7, w11
 0x6514: ldr    w27, [x1, #0x28]
 0x6518: movk   w15, #0x895c, lsl #16
 0x651c: add    w12, w9, w26
 0x6520: and    w9, w12, w25
 0x6524: eor    w9, w9, w22
 0x6528: str    w27, [x8, #0x80]
 0x652c: add    w9, w11, w9
 0x6530: mov    w11, #0xf7af
 0x6534: movk   w11, #0x8b44, lsl #16
 0x6538: add    w9, w9, w11
 0x653c: add    w11, w27, w22
 0x6540: eor    w22, w12, w26
 0x6544: ror    w9, w9, #0x14
 0x6548: mov    w17, #0x7193
 0x654c: movk   w17, #0xfd98, lsl #16
 0x6550: add    w25, w9, w12
 0x6554: and    w9, w25, w22
 0x6558: ldr    w22, [x1, #0x2c]
 0x655c: eor    w9, w9, w26
 0x6560: add    w9, w11, w9
 0x6564: mov    w11, #-0xa44f
 0x6568: add    w9, w9, w11
 0x656c: str    w22, [x8, #0x84]
 0x6570: add    w11, w22, w26
 0x6574: eor    w26, w25, w12
 0x6578: ror    w9, w9, #0xf
 0x657c: subs   w2, w2, #0x40
 0x6580: add    w13, w9, w25
 0x6584: and    w9, w13, w26
 0x6588: eor    w9, w9, w12
 0x658c: add    w11, w11, w9
 0x6590: ldr    w9, [x1, #0x30]
 0x6594: add    w11, w11, w15
 0x6598: eor    w26, w13, w25
 0x659c: ror    w11, w11, #0xa
 0x65a0: str    w9, [x8, #0x88]
 0x65a4: add    w12, w9, w12
 0x65a8: add    w15, w11, w13
 0x65ac: and    w11, w15, w26
 0x65b0: ldr    w26, [x1, #0x34]
 0x65b4: eor    w11, w11, w25
 0x65b8: add    w11, w12, w11
 0x65bc: mov    w12, #0x1122
 0x65c0: movk   w12, #0x6b90, lsl #16
 0x65c4: str    w26, [x8, #0x8c]
 0x65c8: add    w11, w11, w12
 0x65cc: add    w12, w26, w25
 0x65d0: eor    w25, w15, w13
 0x65d4: ror    w11, w11, #0x19
 0x65d8: add    w16, w11, w15
 0x65dc: and    w11, w16, w25
 0x65e0: eor    w11, w11, w13
 0x65e4: add    w12, w12, w11
 0x65e8: ldr    w11, [x1, #0x38]
 0x65ec: add    w12, w12, w17
 0x65f0: eor    w25, w16, w15
 0x65f4: mov    w17, #0x438e
 0x65f8: ror    w12, w12, #0x14
 0x65fc: str    w11, [x8, #0x90]
 0x6600: add    w13, w11, w13
 0x6604: movk   w17, #0xa679, lsl #16
 0x6608: add    w12, w12, w16
 0x660c: and    w25, w12, w25
 0x6610: eor    w25, w25, w15
 0x6614: add    w13, w13, w25
 0x6618: ldr    w25, [x1, #0x3c]
 0x661c: add    w13, w13, w17
 0x6620: eor    w17, w12, w16
 0x6624: add    x1, x1, #0x40
 0x6628: ror    w13, w13, #0xf
 0x662c: str    w25, [x8, #0x94]
 0x6630: add    w15, w25, w15
 0x6634: add    w13, w13, w12
 0x6638: and    w17, w13, w17
 0x663c: eor    w17, w17, w16
 0x6640: add    w15, w15, w17
 0x6644: mov    w17, #0x821
 0x6648: movk   w17, #0x49b4, lsl #16
 0x664c: add    w15, w15, w17
 0x6650: add    w16, w6, w16
 0x6654: ror    w15, w15, #0xa
 0x6658: add    w15, w15, w13
 0x665c: eor    w17, w15, w13
 0x6660: and    w17, w17, w12
 0x6664: eor    w17, w17, w13
 0x6668: add    w16, w16, w17
 0x666c: mov    w17, #0x2562
 0x6670: movk   w17, #0xf61e, lsl #16
 0x6674: add    w16, w16, w17
 0x6678: add    w12, w19, w12
 0x667c: ror    w16, w16, #0x1b
 0x6680: add    w16, w16, w15
 0x6684: eor    w17, w16, w15
 0x6688: and    w17, w17, w13
 0x668c: eor    w17, w17, w15
 0x6690: add    w12, w12, w17
 0x6694: mov    w17, #0xb340
 0x6698: movk   w17, #0xc040, lsl #16
 0x669c: add    w12, w12, w17
 0x66a0: add    w13, w22, w13
 0x66a4: ror    w12, w12, #0x17
 0x66a8: add    w12, w12, w16
 0x66ac: eor    w17, w12, w16
 0x66b0: and    w17, w17, w15
 0x66b4: eor    w17, w17, w16
 0x66b8: add    w13, w13, w17
 0x66bc: mov    w17, #0x5a51
 0x66c0: movk   w17, #0x265e, lsl #16
 0x66c4: add    w13, w13, w17
 0x66c8: add    w15, w21, w15
 0x66cc: ror    w13, w13, #0x12
 0x66d0: add    w13, w13, w12
 0x66d4: eor    w17, w13, w12
 0x66d8: and    w17, w17, w16
 0x66dc: eor    w17, w17, w12
 0x66e0: add    w15, w15, w17
 0x66e4: mov    w17, #0xc7aa
 0x66e8: movk   w17, #0xe9b6, lsl #16
 0x66ec: add    w15, w15, w17
 0x66f0: add    w16, w24, w16
 0x66f4: ror    w15, w15, #0xc
 0x66f8: add    w15, w15, w13
 0x66fc: eor    w17, w15, w13
 0x6700: and    w17, w17, w12
 0x6704: eor    w17, w17, w13
 0x6708: add    w16, w16, w17
 0x670c: mov    w17, #0x105d
 0x6710: movk   w17, #0xd62f, lsl #16
 0x6714: add    w16, w16, w17
 0x6718: add    w12, w27, w12
 0x671c: ror    w16, w16, #0x1b
 0x6720: add    w16, w16, w15
 0x6724: eor    w17, w16, w15
 0x6728: and    w17, w17, w13
 0x672c: eor    w17, w17, w15
 0x6730: add    w12, w12, w17
 0x6734: mov    w17, #0x1453
 0x6738: movk   w17, #0x244, lsl #16
 0x673c: add    w12, w12, w17
 0x6740: add    w13, w25, w13
 0x6744: ror    w12, w12, #0x17
 0x6748: add    w12, w12, w16
 0x674c: eor    w17, w12, w16
 0x6750: and    w17, w17, w15
 0x6754: eor    w17, w17, w16
 0x6758: add    w13, w13, w17
 0x675c: mov    w17, #0xe681
 0x6760: movk   w17, #0xd8a1, lsl #16
 0x6764: add    w13, w13, w17
 0x6768: add    w15, w5, w15
 0x676c: ror    w13, w13, #0x12
 0x6770: add    w13, w13, w12
 0x6774: eor    w17, w13, w12
 0x6778: and    w17, w17, w16
 0x677c: eor    w17, w17, w12
 0x6780: add    w15, w15, w17
 0x6784: mov    w17, #0xfbc8
 0x6788: movk   w17, #0xe7d3, lsl #16
 0x678c: add    w15, w15, w17
 0x6790: add    w16, w7, w16
 0x6794: ror    w15, w15, #0xc
 0x6798: add    w15, w15, w13
 0x679c: eor    w17, w15, w13
 0x67a0: and    w17, w17, w12
 0x67a4: eor    w17, w17, w13
 0x67a8: add    w16, w16, w17
 0x67ac: mov    w17, #0xcde6
 0x67b0: movk   w17, #0x21e1, lsl #16
 0x67b4: add    w16, w16, w17
 0x67b8: add    w12, w11, w12
 0x67bc: ror    w16, w16, #0x1b
 0x67c0: add    w16, w16, w15
 0x67c4: eor    w17, w16, w15
 0x67c8: and    w17, w17, w13
 0x67cc: eor    w17, w17, w15
 0x67d0: add    w12, w12, w17
 0x67d4: mov    w17, #0x7d6
 0x67d8: movk   w17, #0xc337, lsl #16
 0x67dc: add    w12, w12, w17
 0x67e0: add    w13, w20, w13
 0x67e4: ror    w12, w12, #0x17
 0x67e8: add    w12, w12, w16
 0x67ec: eor    w17, w12, w16
 0x67f0: and    w17, w17, w15
 0x67f4: eor    w17, w17, w16
 0x67f8: add    w13, w13, w17
 0x67fc: mov    w17, #0xd87
 0x6800: movk   w17, #0xf4d5, lsl #16
 0x6804: add    w13, w13, w17
 0x6808: add    w15, w23, w15
 0x680c: ror    w13, w13, #0x12
 0x6810: add    w13, w13, w12
 0x6814: eor    w17, w13, w12
 0x6818: and    w17, w17, w16
 0x681c: eor    w17, w17, w12
 0x6820: add    w15, w15, w17
 0x6824: mov    w17, #0x14ed
 0x6828: movk   w17, #0x455a, lsl #16
 0x682c: add    w15, w15, w17
 0x6830: add    w16, w26, w16
 0x6834: ror    w15, w15, #0xc
 0x6838: add    w15, w15, w13
 0x683c: eor    w17, w15, w13
 0x6840: and    w17, w17, w12
 0x6844: eor    w17, w17, w13
 0x6848: add    w16, w16, w17
 0x684c: mov    w17, #0xe905
 0x6850: movk   w17, #0xa9e3, lsl #16
 0x6854: add    w16, w16, w17
 0x6858: add    w12, w4, w12
 0x685c: ror    w16, w16, #0x1b
 0x6860: add    w16, w16, w15
 0x6864: eor    w17, w16, w15
 0x6868: and    w17, w17, w13
 0x686c: eor    w17, w17, w15
 0x6870: add    w12, w12, w17
 0x6874: mov    w17, #0xa3f8
 0x6878: movk   w17, #0xfcef, lsl #16
 0x687c: add    w12, w12, w17
 0x6880: add    w13, w28, w13
 0x6884: ror    w12, w12, #0x17
 0x6888: add    w12, w12, w16
 0x688c: eor    w17, w12, w16
 0x6890: and    w17, w17, w15
 0x6894: eor    w17, w17, w16
 0x6898: add    w13, w13, w17
 0x689c: mov    w17, #0x2d9
 0x68a0: movk   w17, #0x676f, lsl #16
 0x68a4: add    w13, w13, w17
 0x68a8: add    w15, w9, w15
 0x68ac: ror    w13, w13, #0x12
 0x68b0: add    w13, w13, w12
 0x68b4: eor    w17, w13, w12
 0x68b8: and    w17, w17, w16
 0x68bc: eor    w17, w17, w12
 0x68c0: add    w15, w15, w17
 0x68c4: mov    w17, #0x4c8a
 0x68c8: movk   w17, #0x8d2a, lsl #16
 0x68cc: add    w15, w15, w17
 0x68d0: add    w16, w24, w16
 0x68d4: ror    w15, w15, #0xc
 0x68d8: add    w15, w15, w13
 0x68dc: eor    w17, w15, w13
 0x68e0: eor    w18, w17, w12
 0x68e4: add    w16, w16, w18
 0x68e8: mov    w18, #0x3942
 0x68ec: movk   w18, #0xfffa, lsl #16
 0x68f0: add    w16, w16, w18
 0x68f4: add    w12, w23, w12
 0x68f8: add    w13, w22, w13
 0x68fc: ror    w16, w16, #0x1c
 0x6900: add    w16, w16, w15
 0x6904: eor    w17, w16, w17
 0x6908: add    w12, w12, w17
 0x690c: mov    w17, #0xf681
 0x6910: movk   w17, #0x8771, lsl #16
 0x6914: add    w12, w12, w17
 0x6918: ror    w12, w12, #0x15
 0x691c: add    w12, w12, w16
 0x6920: eor    w17, w12, w16
 0x6924: eor    w18, w17, w15
 0x6928: add    w13, w13, w18
 0x692c: mov    w18, #0x6122
 0x6930: movk   w18, #0x6d9d, lsl #16
 0x6934: add    w13, w13, w18
 0x6938: add    w15, w11, w15
 0x693c: add    w16, w6, w16
 0x6940: ror    w13, w13, #0x10
 0x6944: add    w13, w13, w12
 0x6948: eor    w17, w13, w17
 0x694c: add    w15, w15, w17
 0x6950: mov    w17, #0x380c
 0x6954: movk   w17, #0xfde5, lsl #16
 0x6958: add    w15, w15, w17
 0x695c: ror    w15, w15, #9
 0x6960: add    w15, w15, w13
 0x6964: eor    w17, w15, w13
 0x6968: eor    w18, w17, w12
 0x696c: add    w16, w16, w18
 0x6970: mov    w18, #0xea44
 0x6974: movk   w18, #0xa4be, lsl #16
 0x6978: add    w16, w16, w18
 0x697c: add    w12, w5, w12
 0x6980: add    w13, w28, w13
 0x6984: ror    w16, w16, #0x1c
 0x6988: add    w16, w16, w15
 0x698c: eor    w17, w16, w17
 0x6990: add    w12, w12, w17
 0x6994: mov    w17, #0xcfa9
 0x6998: movk   w17, #0x4bde, lsl #16
 0x699c: add    w12, w12, w17
 0x69a0: ror    w12, w12, #0x15
 0x69a4: add    w12, w12, w16
 0x69a8: eor    w17, w12, w16
 0x69ac: eor    w18, w17, w15
 0x69b0: add    w13, w13, w18
 0x69b4: mov    w18, #0x4b60
 0x69b8: movk   w18, #0xf6bb, lsl #16
 0x69bc: add    w13, w13, w18
 0x69c0: add    w15, w27, w15
 0x69c4: add    w16, w26, w16
 0x69c8: ror    w13, w13, #0x10
 0x69cc: add    w13, w13, w12
 0x69d0: eor    w17, w13, w17
 0x69d4: add    w15, w15, w17
 0x69d8: mov    w17, #0xbc70
 0x69dc: movk   w17, #0xbebf, lsl #16
 0x69e0: add    w15, w15, w17
 0x69e4: ror    w15, w15, #9
 0x69e8: add    w15, w15, w13
 0x69ec: eor    w17, w15, w13
 0x69f0: eor    w18, w17, w12
 0x69f4: add    w16, w16, w18
 0x69f8: mov    w18, #0x7ec6
 0x69fc: movk   w18, #0x289b, lsl #16
 0x6a00: add    w16, w16, w18
 0x6a04: add    w12, w21, w12
 0x6a08: add    w13, w20, w13
 0x6a0c: ror    w16, w16, #0x1c
 0x6a10: add    w16, w16, w15
 0x6a14: eor    w17, w16, w17
 0x6a18: add    w12, w12, w17
 0x6a1c: mov    w17, #0x27fa
 0x6a20: movk   w17, #0xeaa1, lsl #16
 0x6a24: add    w12, w12, w17
 0x6a28: ror    w12, w12, #0x15
 0x6a2c: add    w12, w12, w16
 0x6a30: eor    w17, w12, w16
 0x6a34: eor    w18, w17, w15
 0x6a38: add    w13, w13, w18
 0x6a3c: mov    w18, #0x3085
 0x6a40: movk   w18, #0xd4ef, lsl #16
 0x6a44: add    w13, w13, w18
 0x6a48: add    w15, w19, w15
 0x6a4c: add    w16, w7, w16
 0x6a50: ror    w13, w13, #0x10
 0x6a54: add    w13, w13, w12
 0x6a58: eor    w17, w13, w17
 0x6a5c: add    w15, w15, w17
 0x6a60: mov    w17, #0x1d05
 0x6a64: movk   w17, #0x488, lsl #16
 0x6a68: add    w15, w15, w17
 0x6a6c: ror    w15, w15, #9
 0x6a70: add    w15, w15, w13
 0x6a74: eor    w17, w15, w13
 0x6a78: eor    w18, w17, w12
 0x6a7c: add    w16, w16, w18
 0x6a80: mov    w18, #0xd039
 0x6a84: movk   w18, #0xd9d4, lsl #16
 0x6a88: add    w16, w16, w18
 0x6a8c: add    w12, w9, w12
 0x6a90: add    w13, w25, w13
 0x6a94: ror    w16, w16, #0x1c
 0x6a98: add    w16, w16, w15
 0x6a9c: eor    w17, w16, w17
 0x6aa0: add    w12, w12, w17
 0x6aa4: mov    w17, #0x99e5
 0x6aa8: movk   w17, #0xe6db, lsl #16
 0x6aac: add    w12, w12, w17
 0x6ab0: ror    w12, w12, #0x15
 0x6ab4: add    w12, w12, w16
 0x6ab8: eor    w17, w12, w16
 0x6abc: eor    w18, w17, w15
 0x6ac0: add    w13, w13, w18
 0x6ac4: mov    w18, #0x7cf8
 0x6ac8: movk   w18, #0x1fa2, lsl #16
 0x6acc: add    w13, w13, w18
 0x6ad0: add    w15, w4, w15
 0x6ad4: add    w16, w21, w16
 0x6ad8: ror    w13, w13, #0x10
 0x6adc: add    w13, w13, w12
 0x6ae0: eor    w17, w13, w17
 0x6ae4: add    w15, w15, w17
 0x6ae8: mov    w17, #0x5665
 0x6aec: movk   w17, #0xc4ac, lsl #16
 0x6af0: add    w15, w15, w17
 0x6af4: add    w11, w11, w13
 0x6af8: ror    w15, w15, #9
 0x6afc: add    w15, w15, w13
 0x6b00: orn    w17, w15, w12
 0x6b04: eor    w17, w17, w13
 0x6b08: add    w16, w16, w17
 0x6b0c: mov    w17, #0x2244
 0x6b10: movk   w17, #0xf429, lsl #16
 0x6b14: add    w16, w16, w17
 0x6b18: add    w12, w28, w12
 0x6b1c: ror    w16, w16, #0x1a
 0x6b20: add    w16, w16, w15
 0x6b24: orn    w17, w16, w13
 0x6b28: eor    w17, w17, w15
 0x6b2c: add    w12, w12, w17
 0x6b30: mov    w17, #0xff97
 0x6b34: movk   w17, #0x432a, lsl #16
 0x6b38: add    w12, w12, w17
 0x6b3c: add    w9, w9, w16
 0x6b40: ror    w12, w12, #0x16
 0x6b44: add    w12, w12, w16
 0x6b48: orn    w13, w12, w15
 0x6b4c: eor    w13, w13, w16
 0x6b50: add    w11, w11, w13
 0x6b54: mov    w13, #0x23a7
 0x6b58: movk   w13, #0xab94, lsl #16
 0x6b5c: add    w11, w11, w13
 0x6b60: add    w13, w24, w15
 0x6b64: ror    w11, w11, #0x11
 0x6b68: add    w11, w11, w12
 0x6b6c: orn    w15, w11, w16
 0x6b70: eor    w15, w15, w12
 0x6b74: add    w13, w13, w15
 0x6b78: mov    w15, #0xa039
 0x6b7c: movk   w15, #0xfc93, lsl #16
 0x6b80: add    w13, w13, w15
 0x6b84: ror    w13, w13, #0xb
 0x6b88: add    w13, w13, w11
 0x6b8c: orn    w15, w13, w12
 0x6b90: eor    w15, w15, w11
 0x6b94: add    w9, w9, w15
 0x6b98: mov    w15, #0x59c3
 0x6b9c: movk   w15, #0x655b, lsl #16
 0x6ba0: add    w9, w9, w15
 0x6ba4: add    w12, w20, w12
 0x6ba8: ror    w9, w9, #0x1a
 0x6bac: add    w9, w9, w13
 0x6bb0: orn    w15, w9, w11
 0x6bb4: eor    w15, w15, w13
 0x6bb8: add    w12, w12, w15
 0x6bbc: mov    w15, #0xcc92
 0x6bc0: movk   w15, #0x8f0c, lsl #16
 0x6bc4: add    w12, w12, w15
 0x6bc8: add    w11, w27, w11
 0x6bcc: ror    w12, w12, #0x16
 0x6bd0: add    w12, w12, w9
 0x6bd4: orn    w15, w12, w13
 0x6bd8: eor    w15, w15, w9
 0x6bdc: add    w11, w11, w15
 0x6be0: mov    w15, #0xf47d
 0x6be4: movk   w15, #0xffef, lsl #16
 0x6be8: add    w11, w11, w15
 0x6bec: add    w13, w6, w13
 0x6bf0: ror    w11, w11, #0x11
 0x6bf4: add    w11, w11, w12
 0x6bf8: orn    w15, w11, w9
 0x6bfc: eor    w15, w15, w12
 0x6c00: add    w13, w13, w15
 0x6c04: mov    w15, #0x5dd1
 0x6c08: movk   w15, #0x8584, lsl #16
 0x6c0c: add    w13, w13, w15
 0x6c10: add    w9, w23, w9
 0x6c14: ror    w13, w13, #0xb
 0x6c18: add    w13, w13, w11
 0x6c1c: orn    w15, w13, w12
 0x6c20: eor    w15, w15, w11
 0x6c24: add    w9, w9, w15
 0x6c28: mov    w15, #0x7e4f
 0x6c2c: movk   w15, #0x6fa8, lsl #16
 0x6c30: add    w9, w9, w15
 0x6c34: add    w12, w25, w12
 0x6c38: ror    w9, w9, #0x1a
 0x6c3c: add    w9, w9, w13
 0x6c40: orn    w15, w9, w11
 0x6c44: eor    w15, w15, w13
 0x6c48: add    w12, w12, w15
 0x6c4c: mov    w15, #0xe6e0
 0x6c50: movk   w15, #0xfe2c, lsl #16
 0x6c54: add    w12, w12, w15
 0x6c58: add    w11, w19, w11
 0x6c5c: ror    w12, w12, #0x16
 0x6c60: add    w12, w12, w9
 0x6c64: orn    w15, w12, w13
 0x6c68: eor    w15, w15, w9
 0x6c6c: add    w11, w11, w15
 0x6c70: mov    w15, #0x4314
 0x6c74: movk   w15, #0xa301, lsl #16
 0x6c78: add    w11, w11, w15
 0x6c7c: add    w13, w26, w13
 0x6c80: ror    w11, w11, #0x11
 0x6c84: add    w11, w11, w12
 0x6c88: orn    w15, w11, w9
 0x6c8c: eor    w15, w15, w12
 0x6c90: add    w13, w13, w15
 0x6c94: mov    w15, #0x11a1
 0x6c98: movk   w15, #0x4e08, lsl #16
 0x6c9c: add    w13, w13, w15
 0x6ca0: add    w9, w5, w9
 0x6ca4: ror    w13, w13, #0xb
 0x6ca8: add    w13, w13, w11
 0x6cac: orn    w15, w13, w12
 0x6cb0: eor    w15, w15, w11
 0x6cb4: add    w9, w9, w15
 0x6cb8: mov    w15, #0x7e82
 0x6cbc: movk   w15, #0xf753, lsl #16
 0x6cc0: add    w9, w9, w15
 0x6cc4: add    w12, w22, w12
 0x6cc8: ror    w9, w9, #0x1a
 0x6ccc: add    w9, w9, w13
 0x6cd0: orn    w15, w9, w11
 0x6cd4: eor    w15, w15, w13
 0x6cd8: add    w12, w12, w15
 0x6cdc: mov    w15, #0xf235
 0x6ce0: movk   w15, #0xbd3a, lsl #16
 0x6ce4: add    w12, w12, w15
 0x6ce8: add    w11, w4, w11
 0x6cec: add    w14, w9, w14
 0x6cf0: ror    w12, w12, #0x16
 0x6cf4: add    w12, w12, w9
 0x6cf8: orn    w15, w12, w13
 0x6cfc: eor    w15, w15, w9
 0x6d00: add    w11, w11, w15
 0x6d04: add    w11, w11, w0
 0x6d08: add    w13, w7, w13
 0x6d0c: add    w30, w12, w30
 0x6d10: ror    w11, w11, #0x11
 0x6d14: add    w11, w11, w12
 0x6d18: orn    w15, w11, w9
 0x6d1c: eor    w15, w15, w12
 0x6d20: add    w13, w13, w15
 0x6d24: add    w13, w13, w3
 0x6d28: add    w12, w11, w29
 0x6d2c: add    w10, w11, w10
 0x6d30: ror    w9, w13, #0xb
 0x6d34: add    w29, w12, w9
 0x6d38: b.ne   #0x6354
 0x6d3c: stp    w14, w29, [x8, #8]
 0x6d40: mov    x0, x1
 0x6d44: stp    w10, w30, [x8, #0x10]
 0x6d48: ldp    x29, x30, [sp, #0x50]
 0x6d4c: ldp    x20, x19, [sp, #0x40]
 0x6d50: ldp    x22, x21, [sp, #0x30]
 0x6d54: ldp    x24, x23, [sp, #0x20]
 0x6d58: ldp    x26, x25, [sp, #0x10]
 0x6d5c: ldp    x28, x27, [sp], #0x60
 0x6d60: ret    
