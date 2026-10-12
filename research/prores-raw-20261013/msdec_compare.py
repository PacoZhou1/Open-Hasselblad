"""Compare the camera's own ProRes RAW hardware decode (test_msdec, 16-bit) with the encoder input."""
import json
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from compare_decode import band_profile, load_input, H, W  # noqa: E402

HERE = Path(__file__).resolve().parent
LEVELS = [(6.25, 25), (25, 100), (100, 400), (400, 1600), (1600, 3800)]


def main():
    in_name, dec_name = sys.argv[1], sys.argv[2]
    meta = json.loads((HERE / (Path(in_name).stem + '.json')).read_text())
    src = load_input((HERE / in_name).read_bytes(), meta, 0)
    dec = np.fromfile(HERE / dec_name, dtype='<u2').reshape(H, W).astype(np.float64)
    tf = meta.get('transform')
    in_black = tf['encoded_black'] if tf else 4050.0
    gain = tf['gain'] if tf else 1.0
    m = (src > in_black + 400 * gain) & (src < 60000)
    a, b = np.polyfit(src[m][::37], dec[m][::37], 1)
    err = (dec - src) / gain
    sig12 = (src - in_black) / gain / 16
    rows = []
    for lo, hi in LEVELS:
        mm = (sig12 >= lo) & (sig12 < hi)
        if mm.sum() < 2000:
            continue
        e = err[mm]
        d = (src[:, 2:] - src[:, :-2])[mm[:, 1:-1]] / gain / np.sqrt(2)
        rows.append({'signal_12bit': [lo, hi], 'n': int(mm.sum()),
                     'rms_err_12bit': round(float(np.sqrt(np.mean(e ** 2))) / 16, 2),
                     'bias_12bit': round(float(np.mean(e)) / 16, 3),
                     'input_local_diff_12bit': round(float(np.std(d)) / 16, 2)})
    out = {'fit_dec_eq_a_src_plus_b': [round(float(a), 5), round(float(b), 2)],
           'max_abs_err_12bit': round(float(np.abs(err).max()) / 16, 1),
           'rows': rows,
           'banding_ratio_input': band_profile(src, in_black),
           'banding_ratio_decoded': band_profile(dec, in_black)}
    print(json.dumps(out, indent=1))
    (HERE / ('msdec_compare_%s.json' % Path(dec_name).stem)).write_text(json.dumps(out, indent=1) + '\n')


if __name__ == '__main__':
    main()
