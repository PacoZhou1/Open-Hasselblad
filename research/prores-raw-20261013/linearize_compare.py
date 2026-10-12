"""Map decoded ProRes RAW values back to the encoder's linear input via a monotone LUT and measure loss.

The decoder output is a non-linear transfer of the input, so each 16-step input code gets the median decoded
value; that curve is inverted to bring decoded samples back to linear 16-bit units. Fits a closed form too.
"""
import json
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from compare_decode import band_profile, load_input, H, W  # noqa: E402

HERE = Path(__file__).resolve().parent
BLACK = 4050.0


def main():
    in_name, dec_name, k_in, k_dec = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    meta = json.loads((HERE / (Path(in_name).stem + '.json')).read_text())
    src = load_input((HERE / in_name).read_bytes(), meta, k_in)
    tf = meta.get('transform')
    in_black = tf['encoded_black'] if tf else BLACK
    in_gain = tf['gain'] if tf else 1.0
    dec = np.fromfile(HERE / dec_name, dtype='<u2').reshape(-1, H, W)[k_dec].astype(np.float64)
    codes = np.unique(src)
    med = np.array([np.median(dec[src == c]) for c in codes])
    cnt = np.array([(src == c).sum() for c in codes])
    good = cnt >= 50
    xc, yc = codes[good], np.maximum.accumulate(med[good])
    lin = np.interp(dec, yc, xc)
    err = (lin - src) / in_gain
    sig = (src - in_black) / in_gain
    a, p, c = None, None, None
    for gamma in np.linspace(0.3, 0.7, 41):
        A = np.vstack([np.power(np.maximum(xc, 1), gamma), np.ones_like(xc)]).T
        sol, res, *_ = np.linalg.lstsq(A, yc, rcond=None)
        r = float(res[0]) if res.size else 0.0
        if a is None or r < best:
            best, a, p, c = r, sol[0], gamma, sol[1]
    rows = []
    for lo, hi in [(25, 100), (100, 400), (400, 1600), (1600, 6400), (6400, 25600), (25600, 61000)]:
        mm = (sig >= lo) & (sig < hi)
        if mm.sum() < 2000:
            continue
        e = err[mm]
        rows.append({'signal_above_black_16bit': [lo, hi], 'signal_12bit': [lo / 16, hi / 16], 'n': int(mm.sum()),
                     'rms_err_16bit': round(float(np.sqrt(np.mean(e ** 2))), 1),
                     'rms_err_pct_of_signal': round(float(100 * np.sqrt(np.mean((e / sig[mm]) ** 2))), 2),
                     'bias_16bit': round(float(np.mean(e)), 1)})
    noise = []
    for lo, hi in [(100, 400), (400, 1600), (1600, 6400)]:
        mm = (sig[:, 1:-1] >= lo) & (sig[:, 1:-1] < hi)
        d = (src[:, 2:] - src[:, :-2])[mm] / in_gain
        noise.append({'signal': [lo, hi], 'approx_input_noise_16bit': round(float(np.std(d) / np.sqrt(2)), 1)})
    out = {
        'curve_fit_dec_eq_a_x_pow_g_plus_c': [float(a), float(p), float(c)],
        'error_by_level_linear': rows,
        'input_neighbour_noise_reference': noise,
        'banding_ratio_input': band_profile(src, in_black),
        'banding_ratio_decoded_linearized': band_profile(lin, in_black),
        'input_range': [float(src.min()), float(src.max())],
    }
    print(json.dumps(out, indent=1))
    (HERE / ('linear_%s_%d.json' % (Path(dec_name).stem, k_dec))).write_text(json.dumps(out, indent=1) + '\n')
    np.save(HERE / ('lin_%s_%d.npy' % (Path(dec_name).stem, k_dec)), lin.astype(np.float32))


if __name__ == '__main__':
    main()
