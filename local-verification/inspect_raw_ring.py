"""Stream verified v9 RAW frames into offline content/timing diagnostics."""
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
    count = report['actual_frames']
    assert receipt['version'] == 9 and 2 <= count <= 20
    assert receipt['capture_success'] == 1 and receipt['fsync_ok'] == 1
    raw_path = Path(report['raw_path'])
    assert raw_path.stat().st_size == report['raw_bytes'] == count * 23379456
    pixels = np.memmap(raw_path, mode='r', dtype='<u2', shape=(count, 2946, 3968))[:, :, :3920]
    low, high = np.percentile(pixels[:, ::8, ::8], [1, 99.9])
    selected = sorted(set([0, count // 3, count * 2 // 3, count - 1]))
    panel = Image.new('RGB', (600 * len(selected), 490), '#111111')
    draw = ImageDraw.Draw(panel)
    frames = []
    whole_hash = hashlib.sha256()
    out = source.parent / 'ring-container-analysis'
    out.mkdir(exist_ok=False)
    with raw_path.open('rb') as stream:
        for index, meta in enumerate(report['frames']):
            raw = stream.read(23379456)
            digest = hashlib.sha256(raw).hexdigest()
            assert len(raw) == 23379456 and digest == meta['sha256']
            whole_hash.update(raw)
            frame = pixels[index]
            frames.append(dict(index=index, sha256=digest,
                               low4_nonzero=int(np.count_nonzero(frame & 15)),
                               mean=float(frame.mean()), std=float(frame.std()),
                               min=int(frame.min()), max=int(frame.max())))
            if index in selected:
                scaled = np.clip((frame.astype(np.float32) - low) / max(high - low, 1), 0, 1)
                preview = Image.fromarray(np.round(scaled ** .45 * 255).astype('uint8'))
                preview.thumbnail((590, 450))
                column = selected.index(index)
                panel.paste(preview, (column * 600, 30))
                draw.text((column * 600 + 8, 8), f"Index {index} | frame {receipt[f'frame{index}_id']}", fill='white')
    assert whole_hash.hexdigest() == report['raw_sha256']
    panel.save(out / 'ring-preview.png')
    admitted = [receipt[f'frame{i}_admission_ns'] for i in range(count)]
    copied_ms = [(receipt[f'frame{i}_copy_end_ns'] - receipt[f'frame{i}_copy_begin_ns']) / 1e6 for i in range(count)]
    written_ms = [(receipt[f'frame{i}_write_end_ns'] - receipt[f'frame{i}_write_begin_ns']) / 1e6 for i in range(count)]
    result = dict(scope='Finite RAW u16LE diagnostics and CPU delivery timing; no sensor exposure timing, CFA, optical FOV or long-recording proof',
                  source_report=str(source), count=count, raw_sha256=report['raw_sha256'],
                  unique_frame_hashes=len(set(f['sha256'] for f in frames)), frames=frames,
                  cpu_admission_span_ms=(admitted[-1] - admitted[0]) / 1e6,
                  cpu_mean_delivery_intervals_per_second=(count - 1) * 1e9 / (admitted[-1] - admitted[0]),
                  cpu_admission_intervals_ms=[(b - a) / 1e6 for a, b in zip(admitted, admitted[1:])],
                  cpu_copy_ms=copied_ms, cpu_frame_write_ms=written_ms,
                  arm_to_close_ms=(receipt['admission_closed_ns'] - receipt['arm_ns']) / 1e6,
                  arm_to_writer_done_ms=(receipt['writer_done_ns'] - receipt['arm_ns']) / 1e6,
                  drop_full=receipt['drop_full'], drop_copy_busy=receipt['drop_copy_busy'],
                  native_id_deltas=[receipt[f'frame{i+1}_id'] - receipt[f'frame{i}_id'] for i in range(count - 1)],
                  native_timestamp_deltas=report['native_timestamp_deltas'], native_timestamp_unit='unverified',
                  preview=str(out / 'ring-preview.png'),
                  preview_transform=dict(sampled_percentile_step=8, low=float(low), high=float(high), gamma=.45))
    (out / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ['count', 'unique_frame_hashes', 'cpu_admission_span_ms', 'cpu_mean_delivery_intervals_per_second', 'drop_full', 'drop_copy_busy', 'preview']}, indent=2))


if __name__ == '__main__':
    main()
