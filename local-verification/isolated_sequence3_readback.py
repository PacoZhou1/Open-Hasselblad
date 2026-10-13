"""Read back a completed v8 finite sequence after native and stock recovery."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from factory_session import connect
from gui_session import adb

ROOT = Path(__file__).resolve().parents[1]
FRAME_BYTES = 23379456
TOTAL_BYTES = FRAME_BYTES * 3


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', required=True)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if not re.fullmatch(r'source-isolated-[0-9]{6}', args.run):
        raise ValueError('Not a finite isolated source run ID')
    out = ROOT / 'native-video/outputs' / args.run
    base = json.loads((out / 'report.json').read_text())
    assert base['mode'] == 'isolated-target-sequence3-v8'
    if not args.execute:
        print(json.dumps(dict(offline=True, run=args.run, bytes=TOTAL_BYTES)))
        return 0
    report_path = out / 'sequence3-readback-report.json'
    if report_path.exists():
        raise FileExistsError('Preserve prior readback report; never redispatch')
    result = dict(passed=False, session_passed=base['passed'],
                  scope='Three finite CPU-copied RAW frames; no sustained recording or full optical FOV claim')
    try:
        assert base['run_id'] == args.run and base['passed']
        device = out / 'device-run'
        rx = json.loads((device / 'receiver.receipt').read_text())
        assert rx['scope'] == 'receiver_cpu_drain' and rx['version'] == 8
        required = dict(rc=0, state=5, error=0, drain_attempted=1, drain_rc=0,
                        cpu_drained=1, no_arm=0, trigger_seen=1, capture_armed=1,
                        callback_active=0, expired=0, expected_bytes=TOTAL_BYTES,
                        expected_frame_count=3, expected_frame_bytes=FRAME_BYTES,
                        frames_copied=3, frames_written=3, bytes_written=TOTAL_BYTES,
                        copy_active=0, sequence_error=0, prefault_bytes=TOTAL_BYTES,
                        binding_pinned=1, got_is_hook=1, hook_window_closed=1,
                        rejected=0, vendor_error=0, hal_unmap_error=0,
                        expected_pixel=10001)
        for key, expected in required.items():
            assert rx[key] == expected, key
        samples = rx['samples']
        shape = dict(pixel_28=10001, aux_2c=0, width=3920, height=2946,
                     stride=7936, offset=0, planeheight=2946, planes=1)
        assert samples and all(sample == shape for sample in samples)
        frames = []
        last_id = last_stamp = 0
        for index in range(3):
            frame_id = rx[f'frame{index}_id']
            stamp = rx[f'frame{index}_timestamp_native']
            assert 0 < last_id + 1 <= frame_id <= 4294967295
            assert last_stamp < stamp <= 9007199254740991
            assert rx[f'frame{index}_bytes'] == FRAME_BYTES
            assert rx[f'frame{index}_written'] == 1
            frames.append(dict(index=index, frame_id=frame_id,
                               timestamp_native=stamp, offset=index * FRAME_BYTES,
                               bytes=FRAME_BYTES))
            last_id, last_stamp = frame_id, stamp
        assert rx['frame_id'] == last_id and rx['timestamp_native'] == last_stamp
        assert (device / 'restored').is_file() and base['recovery_rc'] == '0'
        assert base['locks_absent'] and (device / 'manual.reaped').is_file()
        expected_hash = (device / 'receiver.raw.sha256').read_text().split()[0]
        assert re.fullmatch('[a-f0-9]{64}', expected_hash)
        assert int((device / 'receiver.raw.bytes').read_text()) == TOTAL_BYTES
        remote = '/data/x2v-source-20261012/runs/' + args.run
        bulk = '/mnt/media_rw/ssd/x2v-source-20261012/runs/' + args.run + '/raw.partial'
        local = out / 'raw-sequence3-3920x2946-stride7936.bin'
        assert not local.exists()
        for lock in ['/data/x2v-source-20261012/source-session.lock',
                     '/data/x2v-native-20261012/gui-session.lock',
                     '/blackbox/x2v-native-20261011/gui-session.lock']:
            assert adb('shell', 'test ! -e ' + lock + ' && echo CLEAR').strip() == 'CLEAR'
        assert adb('shell', 'getprop init.svc.camera-service').strip() == 'running'
        command = 'cd ' + remote + ' && test ! -e raw-readback.partial && cp ' + bulk + ' raw-readback.partial'
        assert len(command.encode()) <= 231
        with connect() as factory:
            result['factory_copy_reply'] = factory.factory_shell(command, capture_ms=6000)
        assert adb('shell', 'sha256sum ' + remote + '/raw-readback.partial').split()[0] == expected_hash
        adb('pull', remote + '/raw-readback.partial', str(local), timeout=45)
        raw = local.read_bytes()
        assert len(raw) == TOTAL_BYTES and hashlib.sha256(raw).hexdigest() == expected_hash
        for frame in frames:
            start = frame['offset']
            frame['sha256'] = hashlib.sha256(raw[start:start + FRAME_BYTES]).hexdigest()
        adb('shell', 'test ! -L ' + remote + '/raw-readback.partial && rm ' + remote + '/raw-readback.partial')
        result.update(passed=True, raw_bytes=TOTAL_BYTES, raw_sha256=expected_hash,
                      raw_path=str(local), receiver_receipt=rx, frames=frames,
                      frame_id_deltas=[frames[i + 1]['frame_id'] - frames[i]['frame_id'] for i in range(2)],
                      timestamp_native_deltas=[frames[i + 1]['timestamp_native'] - frames[i]['timestamp_native'] for i in range(2)],
                      temporary_data_copy_removed=True, native_stop_and_restore=True,
                      continuous_recording_verified=False, field_of_view_verified=False)
    except BaseException as exc:
        result['failure'] = repr(exc)
    report_path.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(passed=result['passed'], report=str(report_path),
                         failure=result.get('failure')), indent=2))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
