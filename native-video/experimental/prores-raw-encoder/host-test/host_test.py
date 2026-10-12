"""Host checks for the ProRes RAW encoder's CPU stages, run on an arm64 Mac (NEON path).

1. camera-layout frames (stride 3968 px, 2946 rows) are built from real MODE21 DNG readbacks;
2. NEON and scalar preprocessing must agree bit for bit (checked inside test_host);
3. output must match a float numpy reference to +-1 code (+-2 on corrected class pixels);
4. optical-black estimate must match an independent numpy estimate;
5. banding: the class / same-colour-neighbour ratio is reported before and after correction;
6. prr_mov must wrap a two-segment elementary stream that ffprobe and AVFoundation decode.
"""
import json
import re
import struct
import subprocess
import sys
from pathlib import Path

import numpy as np
import tifffile

T = Path(__file__).resolve().parent
P = T.parent
R = P.parents[2]
NATIVE = R / 'native-video/outputs'
PRR = R / 'research/prores-raw-20261013'
sys.path.insert(0, str(PRR))
import prr_color  # noqa: E402

SOURCES = {
    'dark_212801': 'source-isolated-212801/dng-sample-readback/clip1-frame-000032-UNCALIBRATED.dng',
    'flat_214208_c1': 'source-isolated-214208/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng',
    'flat_214208_c2': 'source-isolated-214208/dng-sample-readback/clip2-frame-000031-UNCALIBRATED.dng',
    'wall_221635_c1': 'source-isolated-221635/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng',
    'desk_235857_c1': 'source-isolated-235857/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng',
}
SRC_W, SRC_H, STRIDE = 3920, 2946, 3968
X0, Y0, W, H = 16, 32, 3888, 2912
WHITE, OB_BIAS = 64681.0, -3.0
OUT = T / 'out'


def build():
    exe = OUT / 'test_host'
    subprocess.run(['clang', '-std=c11', '-O2', '-Wall', '-Wextra', '-Werror', '-o', exe, T / 'test_host.c',
                    P / 'prr_pre.c', P / 'prr_mov.c', '-lm'], check=True)
    return exe


def camera_frames():
    path = OUT / 'frames.raw'
    names = list(SOURCES)
    with path.open('wb') as f:
        for name in names:
            img = tifffile.imread(NATIVE / SOURCES[name])
            assert img.shape == (SRC_H, SRC_W) and img.dtype == np.uint16
            row = np.zeros((SRC_H, STRIDE), '<u2')
            row[:, :SRC_W] = img
            f.write(row.tobytes())
    return path, names


def black_reference(src):
    ob = np.concatenate([src[40:2940, 2:14].ravel(), src[40:2940, 3906:3918].ravel()]).astype(np.int64)
    m = int(np.median(ob >> 4))
    sel = ob[(ob >= max(m - 32, 0) << 4) & (ob < (m + 33) << 4)]
    return sel.mean() + OB_BIAS


def band_gain_grid():
    text = (P / 'prr_banding.h').read_text()

    def arr(name):
        body = re.search(name + r'\[[^=]*=\s*\{(.*?)\};', text, re.S).group(1)
        return np.array([float(v) for v in re.findall(r'-?\d+\.\d+', body)])
    cx, cy, g = arr('prr_band_cx'), arr('prr_band_cy'), arr('prr_band_g')
    return cx, cy, g.reshape(len(cy), len(cx))


def band_gain(cx, cy, g, x, y):
    def axis(c, v):
        i = np.clip(np.searchsorted(c, v, side='right') - 1, 0, len(c) - 2)
        t = np.clip((v - c[i]) / (c[i + 1] - c[i]), 0, 1)
        return i, t
    ix, tx = axis(cx, x)
    iy, ty = axis(cy, y)
    top = g[iy[:, None], ix] * (1 - tx) + g[iy[:, None], ix + 1] * tx
    bot = g[iy[:, None] + 1, ix] * (1 - tx) + g[iy[:, None] + 1, ix + 1] * tx
    return top * (1 - ty[:, None]) + bot * ty[:, None]


def reference(src, black, banding, grid):
    win = src[Y0:Y0 + H, X0:X0 + W].astype(np.float64)
    out = np.clip(np.rint((win - black) * 65279.0 / (WHITE - black) + 256), 0, 65535)
    cls = np.zeros((H, W), bool)
    if banding:
        rows = np.arange(H)[(Y0 + np.arange(H)) % 6 == 1]
        cols = np.arange(W)[(X0 + np.arange(W)) % 2 == 1]
        gain = band_gain(*grid, (X0 + cols).astype(np.float64), (Y0 + rows).astype(np.float64))
        sub = out[np.ix_(rows, cols)]
        out[np.ix_(rows, cols)] = np.clip(np.rint((sub - 256) / gain + 256), 0, 65535)
        cls[np.ix_(rows, cols)] = True
    return out, cls


def class_ratio(img, y0, x0, pedestal):
    """Median over 64x48 tiles of class / mean(same-colour rows two above and below)."""
    y = np.arange(img.shape[0]) + y0
    x = np.arange(img.shape[1]) + x0
    rows = np.where((y % 6 == 1) & (np.arange(len(y)) >= 2) & (np.arange(len(y)) < len(y) - 2))[0]
    cols = np.where(x % 2 == 1)[0]
    a = img[np.ix_(rows, cols)].astype(np.float64) - pedestal
    n = (img[np.ix_(rows - 2, cols)].astype(np.float64) + img[np.ix_(rows + 2, cols)]) / 2 - pedestal
    ok = n > 2000
    r = np.where(ok, a / np.where(ok, n, 1), np.nan)
    th, tw = r.shape[0] // 8, r.shape[1] // 32
    tiles = np.array([[np.nanmedian(r[i * 8:(i + 1) * 8, j * 32:(j + 1) * 32]) for j in range(tw)] for i in range(th)])
    t = tiles[np.isfinite(tiles)]
    return {'tiles': int(t.size), 'median': float(np.median(t)) if t.size else None,
            'p5': float(np.percentile(t, 5)) if t.size else None, 'p95': float(np.percentile(t, 95)) if t.size else None,
            'max_abs_dev': float(np.max(np.abs(t - 1))) if t.size else None}


def run_pre(exe, frames, banding):
    dst = OUT / ('pre_b%d.raw' % banding)
    r = subprocess.run([exe, 'pre', frames, dst, str(banding)], capture_output=True, text=True)
    lines = r.stdout.split('\n')
    blacks = [float(l.split()[3]) for l in lines if l.startswith('frame ')]
    tail = [l for l in lines if l.startswith('mismatch')][0].split()
    return r.returncode, dst, blacks, {'neon_scalar_mismatch': int(tail[1]), 'neon_ms': float(tail[3]),
                                       'scalar_ms': float(tail[5])}


def check_mov(exe):
    src = PRR / 'out_shift_p1.bin'
    md = prr_color.metadata(0.3385, 0.5917)
    buf = bytearray(src.read_bytes())
    for off in prr_color.frames(buf):
        prr_color.patch_frame(buf, off, md)
    prr = OUT / 'colour.prr'
    prr.write_bytes(bytes(buf))
    mov = OUT / 'colour.mov'
    r = subprocess.run([exe, 'mov', prr, mov], capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    words = r.stdout.split()
    nframes, nbytes = int(words[words.index('frames') + 1]), int(words[words.index('bytes') + 1])
    truncated = int(words[words.index('truncated') + 1]) if 'truncated' in words else 0
    buf = buf[:nbytes]
    probe = json.loads(subprocess.run(['ffprobe', '-v', 'error', '-show_streams', '-show_format', '-of', 'json', mov],
                                      capture_output=True, text=True, check=True).stdout)
    s = probe['streams'][0]
    data = mov.read_bytes()
    mdat = data.find(b'mdat') - 4
    first = struct.unpack_from('>I', data, mdat + 8)[0]
    res = {'frames_in': nframes, 'input_tail_truncated_bytes': truncated, 'codec_tag': s.get('codec_tag_string'), 'width': s.get('width'),
           'height': s.get('height'), 'nb_frames': s.get('nb_frames'), 'duration': probe['format'].get('duration'),
           'mdat_box_size': struct.unpack_from('>I', data, mdat)[0], 'first_sample_size_field': first,
           'bytes_match_input': data[mdat + 8:mdat + 8 + len(buf)] == bytes(buf)}
    avf = Path('/tmp/prrcheck/probe')
    if avf.exists():
        png = OUT / 'colour_frame0.png'
        a = subprocess.run([avf, mov, png], capture_output=True, text=True)
        res['avfoundation'] = {'rc': a.returncode, 'out': a.stdout.strip()[-200:], 'png': str(png.relative_to(R))}
    return res


def main():
    OUT.mkdir(exist_ok=True)
    exe = build()
    frames, names = camera_frames()
    src_all = np.fromfile(frames, '<u2').reshape(len(names), SRC_H, STRIDE)
    grid = band_gain_grid()
    report = {'frames': names, 'checks': {}}
    for banding in (0, 1):
        rc, dst, blacks, timing = run_pre(exe, frames, banding)
        out_all = np.fromfile(dst, '<u2').reshape(len(names), H, STRIDE)[:, :, :W]
        per = {}
        for i, name in enumerate(names):
            ref_black = black_reference(src_all[i])
            ref, cls = reference(src_all[i], blacks[i], banding, grid)
            diff = np.abs(out_all[i].astype(np.int64) - ref.astype(np.int64))
            per[name] = {'black_c': blacks[i], 'black_numpy': round(float(ref_black), 3),
                         'max_diff_plain': int(diff[~cls].max()), 'max_diff_class': int(diff[cls].max()) if cls.any() else 0}
            if name != 'dark_212801':
                per[name]['class_ratio_in'] = class_ratio(src_all[i][Y0:Y0 + H, X0:X0 + W], Y0, X0, blacks[i])
                per[name]['class_ratio_out'] = class_ratio(out_all[i], Y0, X0, 256)
        report['checks']['banding_%d' % banding] = {'rc': rc, 'timing': timing, 'frames': per}
    report['checks']['mov'] = check_mov(exe)
    ok = all(c['rc'] == 0 and c['timing']['neon_scalar_mismatch'] == 0 and
             all(f['max_diff_plain'] <= 1 and f['max_diff_class'] <= 2 and abs(f['black_c'] - f['black_numpy']) < 0.01
                 for f in c['frames'].values())
             for k, c in report['checks'].items() if k.startswith('banding'))
    flats = [f['class_ratio_out'] for n, f in report['checks']['banding_1']['frames'].items()
             if n.startswith(('flat', 'wall'))]
    ok = ok and all(f['p5'] >= 0.99 and f['p95'] <= 1.01 for f in flats)
    m = report['checks']['mov']
    ok = ok and m['codec_tag'] == 'aprh' and m['bytes_match_input'] and m.get('avfoundation', {}).get('rc', 0) == 0
    report['passed'] = bool(ok)
    (T / 'report.json').write_text(json.dumps(report, indent=1) + '\n')
    print(json.dumps(report, indent=1))
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
