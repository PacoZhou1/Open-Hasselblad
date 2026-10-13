"""PRR async ACK: v16 lifecycle with variable encoded sample sizes."""
import importlib.util
from pathlib import Path

BASE = Path(__file__).resolve().parents[1] / 'native-video/experimental/receipt-oracle-v16-dng/ack_contract.py'
spec = importlib.util.spec_from_file_location('rx25_base_contract', BASE)
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)

MAX_SAMPLE = 16777216
PIXEL_BYTES = 22643712
SLOT_STRIDE = 23379968
SOURCE_BYTES = 23379456
POOL_BYTES = SLOT_STRIDE * 3


def validate_capture(rx, expected_generation=None):
    assert rx['scope'] == 'receiver_cpu_drain'
    assert rx['storage_format'] == 'PRORES_RAW_HQ_MOV'
    assert rx['pixel_bytes'] == PIXEL_BYTES
    assert rx['slot_stride'] == SLOT_STRIDE
    assert rx['source_frame_bytes'] == SOURCE_BYTES
    assert rx['writer_direct_required'] == 0
    assert rx['expected_frame_bytes'] == MAX_SAMPLE
    for key, value in dict(version=16, rc=0, state=5, error=0, drain_attempted=1, drain_rc=0,
                           cpu_drained=1, no_arm=0, trigger_seen=1, capture_armed=1,
                           callback_active=0, expired=0, capture_success=1, fsync_ok=1,
                           admission_closed=1, binding_pinned=1, got_is_hook=1,
                           hook_window_closed=1, vendor_error=0, hal_unmap_error=0,
                           expected_pixel=10001, dng_join_failed=0, dng_error=0,
                           dng_close_error=0, dng_manifest_published=1,
                           dng_directory_synced=1, dng_context_released=1).items():
        assert rx[key] == value, key
    if expected_generation is not None:
        assert rx['clip_generation'] == expected_generation
    n = base.number(rx, 'frames_copied', 2, 240)
    assert rx['frames_submitted'] == rx['frames_written'] == rx['dng_published_frames'] == n
    assert rx['frames_reserved'] >= n
    assert rx['prefault_bytes'] == POOL_BYTES
    total = 0
    last_id = 0
    last_offset = -1
    for i in range(n):
        size = base.number(rx, f'frame{i}_bytes', 0x98, MAX_SAMPLE)
        total += size
        assert rx[f'frame{i}_submitted'] == 1
        assert rx[f'frame{i}_written'] == 1
        fid = base.number(rx, f'frame{i}_id', 1)
        assert fid > last_id
        last_id = fid
        offset = base.number(rx, f'frame{i}_write_offset')
        assert offset > last_offset
        last_offset = offset
        assert rx[f'frame{i}_mem_flags_rc'] == 0
        assert rx[f'frame{i}_mem_flags'] == 17
        assert rx[f'frame{i}_mem_fd_rc'] == 0
    assert base.number(rx, 'bytes_written') == total
    assert rx['stop_reason'] in (1, 2, 6)
    return {'capture_success': True, 'frames': n, 'bytes_written': total,
            'drops': rx['drop_full'] + rx['drop_copy_busy']}


def validate_pair(a, b):
    first = validate_capture(a, 1)
    second = validate_capture(b, 2)
    assert a['admission_closed_ns'] <= b['arm_ns']
    return {'pair': True, 'clips': [first, second],
            'interclip_arm_gap_seconds': (b['arm_ns'] - a['admission_closed_ns']) / 1e9}
