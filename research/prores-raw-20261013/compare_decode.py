"""Compare ffmpeg-decoded ProRes RAW frames against the exact 16-bit input the camera encoder received."""
import json
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'claude-audit-20261013'))
from class_physics import ratio_field  # noqa: E402

HERE = Path(__file__).resolve().parent
W, H = 3920, 2944


def load_input(raw, meta, k):
    stride = meta['stride'] // 2
    fb = meta['frame_bytes']
    a = np.frombuffer(raw[k * fb:k * fb + meta['stride'] * H], dtype='<u2').reshape(H, stride)
    return a[:, :W].astype(np.float64)


def band_profile(img, dark_level):
    dark = np.full((2946, 3920), dark_level)
    pad = np.vstack([img, np.full((2, W), dark_level)])
    ys, xs, r, _ = ratio_field(pad, dark, 1, 1)
    cx = (xs > 1700) & (xs < 2200)
    cy = (ys > 1200) & (ys < 1700)
    lx = xs < 400

    def med(mask):
        v = r[mask]
        v = v[np.isfinite(v)]
        return float(np.median(v)) if v.size > 300 else None
    return {'centre': med(np.ix_(cy, cx)), 'left': med(np.ix_(cy, lx))}


def main():
    in_name, dec_name, k_in, k_dec = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    meta = json.loads((HERE / (Path(in_name).stem + '.json')).read_text())
    src = load_input((HERE / in_name).read_bytes(), meta, k_in)
    dec = np.fromfile(HERE / dec_name, dtype='<u2').reshape(-1, H, W)[k_dec].astype(np.float64)
    m = (src > 4300) & (src < 60000)
    a, b = np.polyfit(src[m][::50], dec[m][::50], 1)
    pred = a * src + b
    err = dec - pred
    black = 4050.0
    sig = src - black
    rows = []
    for lo, hi in [(100, 400), (400, 1600), (1600, 6400), (6400, 25600), (25600, 61000)]:
        mm = (sig >= lo) & (sig < hi)
        if mm.sum() < 1000:
            continue
        e = err[mm] / a
        rows.append({'signal_16bit': [lo, hi], 'n': int(mm.sum()), 'rms_err_16bit': float(np.sqrt(np.mean(e ** 2))),
                     'rms_err_pct_of_signal': float(100 * np.sqrt(np.mean((e / sig[mm]) ** 2))),
                     'mean_err_16bit': float(np.mean(e))})
    peak = 65535.0
    mse = np.mean((err[m] / a) ** 2)
    out = {
        'mapping_dec_eq_a_src_plus_b': [float(a), float(b)],
        'psnr_db_vs_16bit_full_scale': float(10 * np.log10(peak ** 2 / mse)),
        'psnr_db_vs_12bit_signal': float(10 * np.log10((4095 * 16) ** 2 / mse)),
        'error_by_level': rows,
        'banding_ratio_input': band_profile(src, black),
        'banding_ratio_decoded': band_profile((dec - b) / a, black),
        'input_minmax': [float(src.min()), float(src.max())],
        'decoded_minmax': [float(dec.min()), float(dec.max())],
    }
    print(json.dumps(out, indent=1))
    (HERE / ('compare_%s_%d.json' % (Path(dec_name).stem, k_dec))).write_text(json.dumps(out, indent=1) + '\n')


if __name__ == '__main__':
    main()
