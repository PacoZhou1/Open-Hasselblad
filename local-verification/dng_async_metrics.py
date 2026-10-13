"""Separate writer occupancy from actual async completion and final drain."""
import json
import statistics
from dng_capture_metrics import measure as base_measure

def stats(values):
    values = sorted(values)
    return dict(min=values[0], median=statistics.median(values),
                p95=values[min(len(values)-1, int((len(values)-1)*.95))], max=values[-1])

def measure(rx, manifest):
    result = base_measure(rx)
    n = rx['frames_written']
    rows = [json.loads(line) for line in manifest.read_text().splitlines()]
    frames = rows[1:-1]
    assert len(frames) == n
    assert rows[-1] == dict(end=True, published_frames=n, submitted_frames=n, error=0)
    durations = {key: [] for key in ('put', 'pwrite', 'fsync', 'completion', 'frame_to_durable')}
    for i, frame in enumerate(frames):
        assert frame['index'] == i and frame['source_id'] == rx[f'frame{i}_id']
        assert frame['file_fsync'] and frame['file_published']
        assert frame['write_end_ns'] == frame['fsync_end_ns']
        wb, we = (rx[f'frame{i}_write_{edge}_ns'] for edge in ('begin', 'end'))
        pb, pe = (rx[f'frame{i}_pwrite_{edge}_ns'] for edge in ('begin', 'end'))
        cb, ce = (rx[f'frame{i}_complete_{edge}_ns'] for edge in ('begin', 'end'))
        assert wb <= pb <= pe <= we and pe <= cb <= frame['fsync_begin_ns'] <= frame['fsync_end_ns'] <= ce <= rx['writer_done_ns']
        assert frame['pwrite_end_ns'] == pe
        for key, value in dict(put=we-wb, pwrite=pe-pb,
                              fsync=frame['fsync_end_ns']-frame['fsync_begin_ns'],
                              completion=ce-cb, frame_to_durable=ce-wb).items():
            durations[key].append(value / 1e6)
    result.update(async_writer=True, frames_submitted=rx['frames_submitted'],
                  frames_published=rx['dng_published_frames'],
                  timings_ms={key: stats(value) for key, value in durations.items()},
                  warm_put_ms=stats(durations['put'][1:]), first_put_ms=durations['put'][0],
                  finish_ms=(rx['writer_fsync_wall_end_ns']-rx['writer_fsync_wall_begin_ns'])/1e6,
                  stop_to_writer_done_ms=(rx['writer_done_ns']-rx['admission_closed_ns'])/1e6,
                  sub30ms_median_verified=statistics.median(durations['put'][1:]) < 30,
                  sustained_30fps_verified=False)
    return result
