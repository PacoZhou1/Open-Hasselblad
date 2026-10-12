"""Host checks for the hardware-independent parts of x2v_prr_dec (MOV reader, preview renderer)."""
import json
import subprocess
import sys
from pathlib import Path

import numpy as np

H = Path(__file__).resolve().parent
P = H.parent
OUT = H / 'out'
CLIPS = [Path('/tmp/prrcheck/r1.mov'), Path('/tmp/prrcheck/r3.mov'),
         P.parents[2] / 'research/prores-raw-20261013/x2v_prr_enc-20261013/r1_5frames_nopatch.mov']
MATRIX = [0.679142, 0.232644, 0.03868397, 0.2693026, 0.9537324, -0.223035, 0.05197585, -0.2955711, 1.332425]
XYZ2SRGB = np.array([[3.2404542, -1.5371385, -0.4985314], [-0.9692660, 1.8760108, 0.0415560],
                     [0.0556434, -0.2040259, 1.0572252]])


def tool(*args):
    r = subprocess.run([str(OUT / 'test_tools'), *map(str, args)], capture_output=True, text=True)
    if r.returncode and args[0] != 'movr':
        sys.exit(r.stderr)
    return json.loads(r.stdout), r.returncode


def ffprobe_packets(path):
    r = subprocess.run(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'packet=pos,size',
                        '-of', 'json', str(path)], capture_output=True, text=True, check=True)
    return [[int(p['pos']), int(p['size'])] for p in json.loads(r.stdout)['packets']]


def check_reader(clip, res):
    got, rc = tool('movr', clip)
    want = ffprobe_packets(clip)
    res[clip.name] = {'count': got['count'], 'ffprobe_count': len(want), 'match': got['samples'] == want,
                      'bad': got['bad'], 'fourcc': got['fourcc'], 'size': [got['width'], got['height']],
                      'timescale': got['timescale'], 'duration': got['duration'], 'recovered': got['recovered']}
    assert rc == 0 and got['samples'] == want and got['fourcc'] == 'aprh' and not got['recovered'], res[clip.name]
    return got


def check_recovery(clip, info, res):
    data = clip.read_bytes()
    first = info['samples'][0][0]
    mdat = data.rfind(b'mdat', 0, first) - 4
    keep = 10
    cut = info['samples'][keep][0] + info['samples'][keep][1] // 2
    t = bytearray(data[:cut])
    if t[mdat:mdat + 4] == b'\0\0\0\1':
        t[mdat + 8:mdat + 16] = bytes(8)
    else:
        t[mdat:mdat + 4] = bytes(4)
    path = OUT / 'truncated.mov'
    path.write_bytes(bytes(t))
    got, rc = tool('movr', path)
    res['recovery'] = {'source': clip.name, 'cut_at': cut, 'count': got['count'], 'expected': keep,
                       'recovered': got['recovered'], 'match': got['samples'] == info['samples'][:keep]}
    assert rc == 0 and got['recovered'] and got['samples'] == info['samples'][:keep], res['recovery']


def reference_view(b, bayer, wbr, wbb, scale, ev):
    pos = {0: (0, 1, 2, 3), 1: (1, 0, 3, 2), 2: (2, 3, 0, 1), 3: (3, 2, 1, 0)}[bayer]
    ph = [b[0::2, 0::2], b[0::2, 1::2], b[1::2, 0::2], b[1::2, 1::2]]
    q = scale // 2
    oh, ow = b.shape[0] // scale, b.shape[1] // scale
    means = [p[:oh * q, :ow * q].reshape(oh, q, ow, q).astype(np.float64).mean(axis=(1, 3)) for p in ph]
    rgb = np.stack([means[pos[0]], (means[pos[1]] + means[pos[2]]) / 2, means[pos[3]]], -1) - 256
    m = XYZ2SRGB @ np.array(MATRIX).reshape(3, 3) @ np.diag([wbr, 1, wbb]) * (2 ** ev / 65279)
    lin = np.clip(np.rint(rgb @ m.T * 4095), 0, 4095) / 4095
    srgb = np.where(lin <= 0.0031308, 12.92 * lin, 1.055 * lin ** (1 / 2.4) - 0.055)
    return np.rint(srgb * 255).astype(np.uint8)


def check_view(res):
    rng = np.random.default_rng(7)
    h, w, stride = 96, 128, 512
    img = np.zeros((h, stride // 2), np.uint16)
    yy, xx = np.mgrid[0:h, 0:w]
    img[:, :w] = np.clip(256 + (xx * 300 + yy * 200) + rng.integers(0, 4000, (h, w)), 256, 65535)
    raw = OUT / 'view_in.raw'
    img.tofile(raw)
    worst = {}
    for bayer in range(4):
        for scale in (2, 4, 6):
            out = OUT / 'view_out.rgb'
            got, _ = tool('view', raw, w, h, stride, bayer, 2.95421, 1.690046, scale, 1.5, *MATRIX, out)
            a = np.fromfile(out, np.uint8).reshape(got['out_h'], got['out_w'], 3).astype(int)
            ref = reference_view(img[:, :w], bayer, 2.95421, 1.690046, scale, 1.5).astype(int)
            worst[f'bayer{bayer}_scale{scale}'] = int(np.abs(a - ref).max())
    res['view_max_abs_diff_8bit'] = worst
    assert max(worst.values()) <= 1, worst


def main():
    OUT.mkdir(exist_ok=True)
    subprocess.run(['clang', '-O1', '-g', '-fsanitize=address,undefined', '-fno-sanitize-recover=all', '-Wall',
                    '-Wextra', '-Werror', '-std=c11', H / 'test_tools.c', P / 'prr_movr.c', P / 'prr_view.c',
                    '-o', OUT / 'test_tools'], check=True)
    res = {}
    infos = {c.name: check_reader(c, res) for c in CLIPS if c.exists()}
    check_recovery(CLIPS[1], infos['r3.mov'], res)
    check_view(res)
    res['passed'] = True
    (H / 'dec_parts_report.json').write_text(json.dumps(res, indent=1) + '\n')
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
