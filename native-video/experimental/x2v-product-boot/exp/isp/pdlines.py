"""Fine horizontal lines in an X2V DNG: per CFA site, the mean of each row against its same-colour
neighbours two rows away, by row phase (y % 6) and column parity. pdlines.py <file.dng>"""
import struct, sys
import numpy as np


def read_dng(path):
    b = open(path, 'rb').read()
    le = b[:2] == b'II'
    e = '<' if le else '>'
    off = struct.unpack_from(e + 'I', b, 4)[0]
    n = struct.unpack_from(e + 'H', b, off)[0]
    tags = {}
    for i in range(n):
        t, typ, cnt, val = struct.unpack_from(e + 'HHII', b, off + 2 + 12 * i)
        if typ == 3 and cnt == 1:
            val = struct.unpack_from(e + 'H', b, off + 2 + 12 * i + 8)[0]
        tags[t] = (typ, cnt, val)
    w, h, so, bps = tags[256][2], tags[257][2], tags[273][2], tags[258][2]
    assert bps == 12, bps
    raw = np.frombuffer(b, np.uint8, (w * h * 3) // 2, so).reshape(h, w // 2, 3).astype(np.uint16)
    img = np.empty((h, w), np.uint16)
    img[:, 0::2] = (raw[:, :, 0] << 4) | (raw[:, :, 1] >> 4)
    img[:, 1::2] = ((raw[:, :, 1] & 15) << 8) | raw[:, :, 2]
    return img, tags


def report(img, x0=0, y0=0, black=None):
    h, w = img.shape
    f = img.astype(np.float64)
    if black is None:
        black = np.median(f[:8])
    out = []
    for py in range(2):
        for px in range(2):
            ch = f[py::2, px::2] - black
            # Row means over the middle half of the columns; each row against the mean of the
            # same-colour rows above and below (two sensor rows away).
            m = ch[:, ch.shape[1] // 4: 3 * ch.shape[1] // 4].mean(axis=1)
            r = m[1:-1] / np.maximum((m[:-2] + m[2:]) / 2, 1e-6) - 1
            ys = (np.arange(1, len(m) - 1) * 2 + py + y0)
            for ph in range(6):
                sel = ys % 6 == ph
                if sel.any():
                    out.append((py, px, ph, float(np.median(r[sel])) * 100, float(np.std(r[sel])) * 100))
    return out


def pd_row_residual(img, y0=32, x0=16):
    """Median percent the PD rows (sensor y % 6 == 1) sit above the mean of the same-colour
    sites two rows away. Whole-row interpolation drives this to ~0; a leftover line is
    several tenths of a percent. The older ±4-row report still sees scene gradient."""
    win = img[y0:2944, x0:3904].astype(np.float64)
    ys = np.where((np.arange(win.shape[0]) + y0) % 6 == 1)[0]
    ys = ys[(ys >= 2) & (ys < win.shape[0] - 2)]
    r = win[ys] / np.maximum((win[ys - 2] + win[ys + 2]) * 0.5, 1.0) - 1.0
    return {'all': float(np.median(r)) * 100,
            'g': float(np.median(r[:, 0::2])) * 100,
            'b': float(np.median(r[:, 1::2])) * 100}


def fix(img):
    """What the resident now does: every site on rows y % 6 == 1 (window x0 16, y0 32)
    takes the rounded-up mean of the same-colour sites two rows above and below."""
    out = img.copy()
    ys = np.arange(37, 2942, 6)
    out[ys, 16:3904] = ((img[ys - 2, 16:3904].astype(np.uint32) + img[ys + 2, 16:3904] + 1) >> 1)
    return out


def show(title, img):
    win = img[32:2944, 16:3904]
    print(title)
    print('site(py,px)  y%6   median_dev%   spread%')
    for py, px, ph, med, sd in report(win, y0=32):
        flag = '  <--' if abs(med) > 0.3 else ''
        print('  (%d,%d)        %d    %+7.3f      %6.3f%s' % (py, px, ph, med, sd, flag))


if __name__ == '__main__':
    img, tags = read_dng(sys.argv[1])
    print('size', img.shape, 'mean', img.mean())
    print('pd_row_residual', pd_row_residual(img))
    show('as recorded', img)
    show('with the interpolation', fix(img))
    print('pd_row_residual after fix', pd_row_residual(fix(img)))
