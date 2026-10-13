"""Offline diagnostics for a verified finite v8 RAW sequence; no CFA/FPS claims."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('readback_report', type=Path)
    args = parser.parse_args()
    source = args.readback_report.resolve()
    report = json.loads(source.read_text())
    assert report['passed'] and report['session_passed']
    receipt = report['receiver_receipt']
    assert receipt['version'] == 8 and receipt['frames_written'] == 3
    shape = receipt['samples'][0]
    assert all(s == shape for s in receipt['samples'])
    assert shape == dict(pixel_28=10001, aux_2c=0, width=3920, height=2946,
                         stride=7936, offset=0, planeheight=2946, planes=1)
    raw = Path(report['raw_path']).read_bytes()
    assert len(raw) == report['raw_bytes'] == 70138368
    assert hashlib.sha256(raw).hexdigest() == report['raw_sha256']
    pixels = np.frombuffer(raw, dtype='<u2').reshape(3, 2946, 3968)[:, :, :3920]
    # All previews use the same transfer function; native rows are not cropped.
    lo, hi = np.percentile(pixels, [1, 99.9])
    out = source.parent / 'sequence-container-analysis'
    out.mkdir(exist_ok=False)
    panel = Image.new('RGB', (1800, 490), '#111111')
    draw = ImageDraw.Draw(panel)
    frames = []
    for index, meta in enumerate(report['frames']):
        data = raw[meta['offset']:meta['offset'] + meta['bytes']]
        assert hashlib.sha256(data).hexdigest() == meta['sha256']
        p = pixels[index]
        levels = np.percentile(p, [0, 1, 50, 99.9, 100])
        scaled = np.clip((p.astype(np.float32) - lo) / max(hi - lo, 1), 0, 1)
        preview = Image.fromarray(np.round(scaled ** .45 * 255).astype('uint8'))
        preview.thumbnail((1600, 1200))
        preview.save(out / f'frame-{index}.png')
        preview.thumbnail((590, 450))
        panel.paste(preview, (index * 600, 30))
        draw.text((index * 600 + 8, 8), f"Frame {meta['frame_id']} | native timestamp {meta['timestamp_native']}", fill='white')
        frames.append(dict(**meta, unique_values=int(np.unique(p).size),
                           word_or=int(np.bitwise_or.reduce(p.reshape(-1))),
                           low4_nonzero=int(np.count_nonzero(p & 15)),
                           percentiles=levels.tolist(),
                           thirds=[dict(rows=len(b), mean=float(b.mean()),
                                        std=float(b.std()), min=int(b.min()), max=int(b.max()))
                                   for b in np.array_split(p, 3)]))
    panel.save(out / 'sequence-preview.png')
    differences = []
    for index in range(2):
        delta = pixels[index + 1].astype(np.int32) - pixels[index].astype(np.int32)
        differences.append(dict(first=index, second=index + 1,
                                changed_words=int(np.count_nonzero(delta)),
                                fraction_changed=float(np.count_nonzero(delta) / delta.size),
                                mean_absolute_u16_difference=float(np.abs(delta).mean())))
    result = dict(scope='Three u16LE containers; not CFA, sensor bit depth, optical FOV, motion or sustained cadence proof',
                  source_report=str(source), raw_sha256=report['raw_sha256'],
                  native_shape=shape, frames=frames, differences=differences,
                  frame_id_deltas=report['frame_id_deltas'],
                  timestamp_native_deltas=report['timestamp_native_deltas'],
                  timestamp_unit='not established for target dispatch',
                  preview_transfer=dict(low=float(lo), high=float(hi), gamma=.45),
                  preview=str(out / 'sequence-preview.png'))
    (out / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(report=str(out / 'report.json'), preview=result['preview'],
                         frame_id_deltas=result['frame_id_deltas'],
                         timestamp_native_deltas=result['timestamp_native_deltas']), indent=2))


if __name__ == '__main__':
    main()
