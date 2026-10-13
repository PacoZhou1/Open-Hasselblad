"""Read one completed, restored isolated source run; never starts imaging."""
from pathlib import Path
import argparse
import hashlib
import json
import re

from factory_session import connect
from gui_session import adb

ROOT = Path(__file__).resolve().parents[1]
SHAPES = {
    'isolated-carrier-v7': (22004736, '7408x1482-stride14848'),
    'isolated-graph-listen-v7': (7824896, '3920x986-stride7936'),
    'isolated-target-listen-v7': (23379456, '3920x2946-stride7936'),
    'isolated-target-fullrect-v7': (23379456, '3920x2946-stride7936'),
    'isolated-target-fullrect-v7b': (23379456, '3920x2946-stride7936'),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', required=True)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if not re.fullmatch(r'source-isolated-[0-9]{6}', args.run):
        raise ValueError('Not an isolated source run ID')
    out = ROOT / 'native-video/outputs' / args.run
    base = json.loads((out / 'report.json').read_text())
    expected_size, label = SHAPES[base['mode']]
    if not args.execute:
        print(json.dumps({'offline': True, 'run': args.run, 'bytes': expected_size}))
        return 0
    result_path = out / 'raw-readback-report.json'
    if result_path.exists():
        raise FileExistsError('Preserve prior readback report; never redispatch')
    result = {'passed': False, 'session_passed': base['passed'],
              'scope': 'one RAW CPU payload after native stop and stock restoration; no sustained FPS, CFA or FOV claim'}
    try:
        assert base['run_id'] == args.run and base['passed']
        device = out / 'device-run'
        receipt = json.loads((device / 'receiver.receipt').read_text())
        assert receipt['scope'] == 'receiver_cpu_drain' and receipt['version'] == 7
        for key, expected in {'rc': 0, 'state': 5, 'error': 0, 'drain_attempted': 1,
                              'drain_rc': 0, 'cpu_drained': 1, 'no_arm': 0,
                              'trigger_seen': 1, 'capture_armed': 1, 'callback_active': 0,
                              'expired': 0, 'vendor_error': 0, 'hal_unmap_error': 0,
                              'expected_bytes': expected_size, 'binding_pinned': 1,
                              'got_is_hook': 1, 'hook_window_closed': 1}.items():
            assert receipt[key] == expected, key
        assert (device / 'restored').is_file() and base['recovery_rc'] == '0'
        expected_hash = (device / 'receiver.raw.sha256').read_text().split()[0]
        assert re.fullmatch('[a-f0-9]{64}', expected_hash)
        assert int((device / 'receiver.raw.bytes').read_text()) == expected_size
        remote = '/data/x2v-source-20261012/runs/' + args.run
        bulk = '/mnt/media_rw/ssd/x2v-source-20261012/runs/' + args.run + '/raw.partial'
        local = out / ('raw-' + label + '.bin')
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
        actual_hash = hashlib.sha256(local.read_bytes()).hexdigest()
        assert local.stat().st_size == expected_size and actual_hash == expected_hash
        adb('shell', 'test ! -L ' + remote + '/raw-readback.partial && rm ' + remote + '/raw-readback.partial')
        result.update(passed=True, raw_bytes=expected_size, raw_sha256=actual_hash,
                      raw_path=str(local), receiver_receipt=receipt,
                      temporary_data_copy_removed=True, native_stop_and_restore=True,
                      continuous_recording_verified=False, field_of_view_verified=False)
    except BaseException as exc:
        result['failure'] = repr(exc)
    result_path.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'passed': result['passed'], 'report': str(result_path),
                      'failure': result.get('failure')}, indent=2))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
