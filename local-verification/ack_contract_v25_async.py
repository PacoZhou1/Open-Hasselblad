"""RX25 async extension to the successful RX16 capture/closure contract."""
import importlib.util
from pathlib import Path

BASE = Path(__file__).resolve().parents[1] / 'native-video/experimental/receipt-oracle-v16-dng/ack_contract.py'
spec = importlib.util.spec_from_file_location('rx25_base_contract', BASE)
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)

EXTRA = {'frames_submitted','dng_join_failed'} | {
    f'frame{i}_{key}' for i in range(240)
    for key in ('submitted','pwrite_begin_ns','pwrite_end_ns','complete_begin_ns','complete_end_ns')}

def baseline_view(rx):
    assert EXTRA <= set(rx)
    return {k:v for k,v in rx.items() if k not in EXTRA}

def validate_capture(rx, expected_generation=None):
    result = base.validate_capture(baseline_view(rx), expected_generation)
    n = rx['frames_copied']
    assert base.number(rx, 'frames_submitted') == rx['frames_written'] == n
    assert base.number(rx, 'dng_join_failed') == 0
    for i in range(240):
        keys = ('submitted', 'pwrite_begin_ns', 'pwrite_end_ns', 'complete_begin_ns', 'complete_end_ns')
        values = {k: base.number(rx, f'frame{i}_{k}') for k in keys}
        if i >= n:
            assert all(v == 0 for v in values.values())
            continue
        assert values['submitted'] == 1
        assert rx[f'frame{i}_write_begin_ns'] <= values['pwrite_begin_ns'] <= values['pwrite_end_ns'] <= rx[f'frame{i}_write_end_ns']
        assert values['pwrite_end_ns'] <= values['complete_begin_ns'] <= values['complete_end_ns'] <= rx['writer_done_ns']
    return result

def validate_pair(a, b):
    result = base.validate_pair(baseline_view(a), baseline_view(b))
    validate_capture(a, 1)
    validate_capture(b, 2)
    return result
