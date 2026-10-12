"""Build a test_msenc input file from real MODE21 DNG frames.

Per frame: `height` rows of `stride` bytes (little-endian uint16 samples, row padded to a 256-byte
multiple), followed by a zero ICS block (16 bytes per 128x8 half-resolution block), which is what the
stock ProRes RAW plugin uses when ISP ICS statistics are absent. test_msenc preloads 6 frames.
lib_msenc requires width and height to be multiples of 8, so the bottom two rows are dropped.
"""
import hashlib
import json
import sys
from pathlib import Path

import numpy as np
import tifffile

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
SOURCES = [
    'native-video/outputs/source-isolated-214208/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng',
    'native-video/outputs/source-isolated-214208/dng-sample-readback/clip2-frame-000031-UNCALIBRATED.dng',
    'native-video/outputs/source-isolated-221635/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng',
    'native-video/outputs/source-isolated-221635/dng-sample-readback/clip2-frame-000031-UNCALIBRATED.dng',
    'native-video/outputs/source-isolated-235857/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng',
    'native-video/outputs/source-isolated-235857/dng-sample-readback/clip2-frame-000031-UNCALIBRATED.dng',
]
SRC_H = 2946
W, H = 3920, 2944
BLACK, WHITE = 4050, 64681
PEDESTAL = 256


def black_shift_gain():
    return 65535.0 / (WHITE - BLACK + PEDESTAL)


def stride_for(bit_depth):
    bpp_num, bpp_den = (3, 2) if bit_depth in (10, 12) else (2, 1)
    return (W * bpp_num // bpp_den + 0xff) & ~0xff


def ics_size():
    return ((W // 2 + 127) >> 7) * ((H // 2 + 7) >> 3) * 16


def main():
    bit_depth = int(sys.argv[1]) if len(sys.argv) > 1 else 16
    shift = len(sys.argv) > 2 and sys.argv[2] == 'shift'
    # Scaling signal above black also scales its noise, so a scaled frame over-estimates the bitrate
    # of a genuinely brighter exposure, whose shot noise grows only with the square root of signal.
    scale = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
    assert bit_depth == 16, 'only the unpacked 16-bit layout is known'
    stride = stride_for(bit_depth)
    suffix = ('_shift' if shift else '') + ('_x%g' % scale if scale != 1.0 else '')
    dst = OUT / ('msenc_in_%dbit_6f%s.raw' % (bit_depth, suffix))
    meta = {'width': W, 'height': H, 'bit_depth': bit_depth, 'stride': stride, 'ics_size': ics_size(),
            'frame_bytes': stride * H + ics_size(), 'sources': []}
    if shift:
        gain = black_shift_gain()
        meta['transform'] = {'black': BLACK, 'pedestal': PEDESTAL, 'gain': gain,
                             'encoded_black': PEDESTAL * gain}
    meta['signal_scale'] = scale
    with dst.open('wb') as f:
        for src in SOURCES:
            img = tifffile.imread(ROOT / src)
            assert img.shape == (SRC_H, W) and img.dtype == np.uint16
            img = img[:H]
            if scale != 1.0:
                img = np.clip((img.astype(np.float64) - BLACK) * scale + BLACK, 0, WHITE).astype(np.uint16)
            rows = np.zeros((H, stride // 2), dtype='<u2')
            if shift:
                v = (img.astype(np.float64) - BLACK + PEDESTAL) * gain
                rows[:, :W] = np.clip(np.rint(v), 0, 65535).astype('<u2')
            else:
                rows[:, :W] = img
            f.write(rows.tobytes())
            f.write(bytes(ics_size()))
            meta['sources'].append({'path': src, 'sha256_pixels': hashlib.sha256(img.tobytes()).hexdigest()})
    meta['file'] = dst.name
    meta['file_bytes'] = dst.stat().st_size
    meta['sha256'] = hashlib.sha256(dst.read_bytes()).hexdigest()
    (OUT / (dst.stem + '.json')).write_text(json.dumps(meta, indent=1) + '\n')
    print(json.dumps({k: v for k, v in meta.items() if k != 'sources'}))


if __name__ == '__main__':
    main()
