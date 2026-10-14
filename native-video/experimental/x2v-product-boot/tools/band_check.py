#!/usr/bin/env python3
"""Residual PD-site bands in a recorded clip: for every band and 50-column block, the mean
chroma inside the band minus the mean of the rows just above and below it.
Usage: band_check.py clip.mp4 [frames]"""
import subprocess, sys
import numpy as np

W, H = 1300, 970
path = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 48
raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', path, '-frames:v', str(n), '-f', 'rawvideo',
                      '-pix_fmt', 'yuv420p', '-'], capture_output=True, check=True).stdout
fs = W * H * 3 // 2
frames = len(raw) // fs
rows = []  # (luma bucket, dY, dU, dV)
for i in range(frames):
    f = np.frombuffer(raw[i * fs:(i + 1) * fs], np.uint8)
    Y = f[:W * H].reshape(H, W).astype(float)
    U = f[W * H:W * H + W * H // 4].reshape(H // 2, W // 2).astype(float)
    V = f[W * H + W * H // 4:].reshape(H // 2, W // 2).astype(float)
    for k in range(5):
        a, e = 192 * k + 96, 192 * k + 160
        if e + 36 > H: break
        ins = slice(a + 6, e - 6)
        out = np.r_[a - 30:a - 4, e + 4:e + 30]
        for b in range(2, W // 50 - 1):
            cs = slice(b * 50, b * 50 + 50); cc = slice(b * 25, b * 25 + 25)
            yi, yo = Y[ins, cs].mean(), Y[out][:, cs].mean()
            ui, uo = U[ins.start // 2:ins.stop // 2, cc].mean(), U[out // 2][:, cc].mean()
            vi, vo = V[ins.start // 2:ins.stop // 2, cc].mean(), V[out // 2][:, cc].mean()
            # Skip blocks where the scene itself changes across the band.
            ya, yb = Y[a - 30:a - 4, cs].mean(), Y[e + 4:e + 30, cs].mean()
            if abs(ya - yb) > 12: continue
            rows.append((yo, yi - yo, ui - uo, vi - vo))
r = np.array(rows)
print(f'{path}: {frames} frames, {len(r)} band blocks')
for lo, hi in ((0, 60), (60, 140), (140, 200), (200, 230), (230, 256)):
    m = (r[:, 0] >= lo) & (r[:, 0] < hi)
    if m.sum() < 5: continue
    d = r[m]
    print(f'  luma {lo:3d}-{hi:3d}: n={m.sum():5d}  dY {d[:,1].mean():+5.2f}  '
          f'dU {d[:,2].mean():+5.2f} (|p95| {np.percentile(abs(d[:,2]),95):4.2f})  '
          f'dV {d[:,3].mean():+5.2f} (|p95| {np.percentile(abs(d[:,3]),95):4.2f})')
