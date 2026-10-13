"""Read the successful CPU payload from the specific controller-race run.

Never rewrites the failed session report and never starts imaging.
"""
import hashlib
import json
from pathlib import Path
from factory_session import connect
from gui_session import adb
from source_session_test import STATE, NORMAL

ROOT = Path(__file__).resolve().parents[1]
RUN = 'source-isolated-060949'
OUT = ROOT / 'native-video/outputs' / RUN
DEVICE = OUT / 'device-run'
REMOTE = '/data/x2v-source-20261012/runs/' + RUN
BULK = '/mnt/media_rw/ssd/x2v-source-20261012/runs/' + RUN + '/raw.partial'
SIZE = 23379456


def main():
    report_path = OUT / 'diagnostic-readback-reconciliation.json'
    assert not report_path.exists()
    base_path = OUT / 'report.json'
    base_sha = hashlib.sha256(base_path.read_bytes()).hexdigest()
    base = json.loads(base_path.read_text())
    rx = json.loads((DEVICE / 'receiver.receipt').read_text())
    assert base['passed'] is False and base['body_rc'] == '5'
    assert base['recovery_rc'] == '0' and base['locks_absent']
    assert base['explicit_arm_confirmed'] and not base['receiver_confirmed']
    assert rx['version'] == 7 and rx['scope'] == 'receiver_cpu_drain'
    for key, value in dict(rc=0, state=5, error=0, drain_attempted=1,
                           drain_rc=0, cpu_drained=1, no_arm=0, trigger_seen=1,
                           capture_armed=1, callback_active=0, expired=0,
                           expected_bytes=SIZE, binding_pinned=1, got_is_hook=1,
                           hook_window_closed=1, rejected=0, vendor_error=0,
                           hal_unmap_error=0, expected_pixel=10001).items():
        assert rx[key] == value, key
    assert rx['frame_id'] == 976 and rx['seen'] == 86
    expected_shape = dict(pixel_28=10001, aux_2c=0, width=3920, height=2946,
                          stride=7936, offset=0, planeheight=2946, planes=1)
    assert rx['samples'] and all(s == expected_shape for s in rx['samples'])
    events = (DEVICE / 'events.log').read_text()
    for value in ['OP_END setup_dcam_stream_group 13 rc=0',
                  'RECEIVER_EXPLICIT_ARM_AFTER_GRAPH13_SETUP_ACK',
                  'ERROR_receiver_terminal_without_frame',
                  'RECEIVER_CPU_DRAIN_ACK', 'OP_END stop_dcam_stream 1 rc=0',
                  'OP_END teardown_current_dcam_stream_group rc=0',
                  'PHASE graph_quiesced_group255',
                  'PARENT_REAP_END pid=11782 wait_rc=1 proc_state=',
                  'MANUAL_ABSENCE pidof= init=stopped own_pid=11782',
                  'FRAMES first=484 last=635', 'NORMAL_STOCK_RESTORED']:
        assert value in events, value
    for name in ['restored', 'manual.reaped',
                 'native-11782-157935-graph-stop-confirmed',
                 'native-11782-157935-graph-teardown-confirmed']:
        assert (DEVICE / name).is_file(), name
    assert adb('shell', 'cat /proc/sys/kernel/random/boot_id').strip() == 'f6668de2-2070-4793-9cbd-6cfbb7adc2bf'
    assert adb('shell', 'getprop init.svc.camera-service').strip() == 'running'
    for lock in ['/data/x2v-source-20261012/source-session.lock',
                 '/data/x2v-native-20261012/gui-session.lock',
                 '/blackbox/x2v-native-20261011/gui-session.lock']:
        assert adb('shell', 'test ! -e ' + lock + ' && echo CLEAR').strip() == 'CLEAR'
    result = dict(passed=False, original_session_passed=False,
                  original_report_sha256=base_sha, receiver_receipt=rx,
                  scope='Independent payload readback after verified native teardown/reap/restore; original session remains failed')
    queries = []
    with connect() as factory:
        def query(command):
            assert len(command.encode()) <= 231
            reply = factory.factory_shell(command, capture_ms=6000)
            queries.append(dict(command=command, reply=reply))
            return reply
        health = query(STATE)
        assert all(line in health.splitlines() for line in NORMAL)
        assert query('odindb-send -s error -p active_error').strip() == 'active_error = false'
        assert '(ro,' in query('mount | grep " /system "')
        inode = (DEVICE / 'raw.inode').read_text().strip()
        assert query('test ! -L ' + BULK + ' && stat -c %d:%i:%s ' + BULK).strip() == inode + ':' + str(SIZE)
        digest = query('sha256sum ' + BULK).split()[0]
        assert len(digest) == 64 and all(c in '0123456789abcdef' for c in digest)
        query('cd ' + REMOTE + ' && test ! -e diagnostic-readback.partial && cp ' + BULK + ' diagnostic-readback.partial')
    remote_copy = REMOTE + '/diagnostic-readback.partial'
    assert adb('shell', 'sha256sum ' + remote_copy).split()[0] == digest
    raw_path = OUT / 'raw-3920x2946-stride7936.bin'
    assert not raw_path.exists()
    adb('pull', remote_copy, str(raw_path), timeout=45)
    assert raw_path.stat().st_size == SIZE
    assert hashlib.sha256(raw_path.read_bytes()).hexdigest() == digest
    adb('shell', 'test ! -L ' + remote_copy + ' && rm ' + remote_copy)
    assert hashlib.sha256(base_path.read_bytes()).hexdigest() == base_sha
    result.update(passed=True, raw_path=str(raw_path), raw_bytes=SIZE,
                  raw_sha256=digest, queries=queries,
                  native_stop_and_restore=True, temporary_data_copy_removed=True,
                  continuous_recording_verified=False, field_of_view_verified=False)
    report_path.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(report=str(report_path), passed=True, raw_sha256=digest), indent=2))


if __name__ == '__main__':
    main()
