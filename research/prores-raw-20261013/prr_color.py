"""ProRes RAW colour metadata from a DNG-style XYZ->camera matrix and an as-shot neutral.

ProRes RAW header semantics (FFmpeg prores_raw.c): black is fixed at 256, white = senselValueRange + 256,
the decoder multiplies R/B by the white-balance factors and then applies a row-major 3x3 matrix taking
white-balanced camera RGB to CIE XYZ D65, then the gain factor.

Usage: prr_color.py <in.mov|in.bin> <out> [neutral_r neutral_b]
Patches every prrf frame header in place (copy) and prints the metadata.
"""
import struct
import sys

import numpy as np

# Hasselblad X2D II 100C ColorMatrix1 (XYZ -> camera), sealed B3648 still; single matrix, taken as D65.
CM_D65 = np.array([19913 / 33464, -14029 / 95647, -1356 / 39731,
                   -37392 / 72475, 5536 / 4383, 28167 / 99667,
                   -9919 / 95535, 9151 / 54614, 54310 / 88279]).reshape(3, 3)
D65 = np.array([0.95047, 1.0, 1.08883])
BRADFORD = np.array([[0.8951, 0.2664, -0.1614], [-0.7502, 1.7135, 0.0367], [0.0389, -0.0685, 1.0296]])

HDR_CROP, HDR_BAYER, HDR_RANGE = 0x14, 0x18, 0x1a
HDR_WB_R, HDR_WB_B, HDR_MATRIX, HDR_GAIN, HDR_CCT = 0x1c, 0x20, 0x24, 0x48, 0x4c


def bradford(src_xyz, dst_xyz):
    s = BRADFORD @ src_xyz
    d = BRADFORD @ dst_xyz
    return np.linalg.inv(BRADFORD) @ np.diag(d / s) @ BRADFORD


def cct_mccamy(xyz):
    x, y = xyz[0] / xyz.sum(), xyz[1] / xyz.sum()
    n = (x - 0.3320) / (0.1858 - y)
    return 449 * n ** 3 + 3525 * n ** 2 + 6823.3 * n + 5520.33


def metadata(neutral_r, neutral_b, cm=CM_D65):
    n = np.array([neutral_r, 1.0, neutral_b])
    cam2xyz = np.linalg.inv(cm)
    illum = cam2xyz @ n
    illum = illum / illum[1]
    m = bradford(illum, D65) @ cam2xyz @ np.diag(n)
    m = m / (m @ np.ones(3))[1]
    return {'wb_red': 1.0 / neutral_r, 'wb_blue': 1.0 / neutral_b, 'matrix': m,
            'cct': int(round(cct_mccamy(illum))), 'gain': 1.0, 'white_xyz': m @ np.ones(3)}


def patch_frame(buf, off, md):
    struct.pack_into('>ff', buf, off + HDR_WB_R, md['wb_red'], md['wb_blue'])
    struct.pack_into('>9f', buf, off + HDR_MATRIX, *md['matrix'].ravel())
    struct.pack_into('>f', buf, off + HDR_GAIN, md['gain'])
    struct.pack_into('>H', buf, off + HDR_CCT, md['cct'])


def frames(buf):
    pos = buf.find(b'prrf') - 4
    while 0 <= pos and pos + 8 <= len(buf) and buf[pos + 4:pos + 8] == b'prrf':
        size = struct.unpack_from('>I', buf, pos)[0]
        yield pos
        pos += size


def main():
    src, dst = sys.argv[1], sys.argv[2]
    nr, nb = (float(sys.argv[3]), float(sys.argv[4])) if len(sys.argv) > 4 else (65536 / 141680, 65536 / 142032)
    md = metadata(nr, nb)
    buf = bytearray(open(src, 'rb').read())
    count = 0
    for off in frames(buf):
        patch_frame(buf, off, md)
        count += 1
    open(dst, 'wb').write(buf)
    np.set_printoptions(precision=4, suppress=True)
    print('frames patched', count, 'wb', round(md['wb_red'], 4), round(md['wb_blue'], 4), 'cct', md['cct'])
    print('matrix\n', md['matrix'], '\nwhite ->', md['white_xyz'])


if __name__ == '__main__':
    main()
