"""Explicit bounded ordinary-file SSD test; never changes a camera mode.

Control lives in /data; the reviewed immutable helper lives in /system/bin.
Only a fresh X2V_BENCH subdirectory on SSD
receives test bytes. No cleanup/deletion or existing-media write is performed.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import time

from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
BINARY = ROOT/'native-video/experimental/ssd-direct-write/build/ssd_direct_fd'
EXPECTED = '9813c88ec2bd9d0a03e34568298a49859e6126c82ca05ff4ac521db94adb9945'
DEVICE_BINARY = '/system/bin/x2v_ssd_20261012a'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mib', type=int, choices=[16, 256, 2048], default=16)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if hashlib.sha256(BINARY.read_bytes()).hexdigest() != EXPECTED:
        raise RuntimeError('Reviewed binary differs')
    if not args.execute:
        print(json.dumps({'offline_only': True, 'mib': args.mib, 'reserve_gib': 8,
                          'direct_io_required': True, 'capturing_images': False}))
        return 0
    run = datetime.now().strftime('ssd-%H%M%S')
    out = ROOT/'native-video/outputs'/run
    out.mkdir(exist_ok=False)
    remote = '/data/x2v-native-20261012/' + run
    media = '/mnt/media_rw/ssd/X2V_BENCH/' + run
    report = {'run_id': run, 'passed': False, 'mib': args.mib, 'binary_sha256': EXPECTED,
              'control_directory': remote, 'media_directory': media, 'events': []}

    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    def query(f, command):
        if len(command.encode()) > 231:
            raise ValueError('Factory command too long')
        result = f.factory_shell(command, capture_ms=6000)
        report['events'].append({'command': command, 'output': result})
        return result

    def snapshot(f):
        return {'service': query(f, 'pidof camera-service').strip(),
                'gui': query(f, 'pidof camera-gui').strip(),
                'gui_init': query(f, 'getprop init.svc.camera-gui').strip(),
                'state': query(f, STATE),
                'frame_count': query(f, 'timeout 4 odindb-send -s camera -m get_frame_count'),
                'system_mount': query(f, 'mount | grep " /system "')}

    try:
        with connect() as f:
            report['before'] = snapshot(f)
            b = report['before']
            if not (b['gui_init'] == 'running' and b['service'].isdigit() and
                    b['gui'].isdigit() and check_state(b['state']) and '(ro,' in b['system_mount']):
                raise RuntimeError('Need healthy stock camera and read-only system')
            query(f, 'mkdir ' + remote)
        with connect() as f:
            if query(f, 'sha256sum '+DEVICE_BINARY).split()[0] != EXPECTED:
                raise RuntimeError('Device binary readback differs')
            probe = query(f, DEVICE_BINARY+' --invalid; echo RC:$?')
            report['system_execution_probe'] = probe
            if 'usage: ssd_direct_fd' not in probe or 'RC:2' not in probe:
                raise RuntimeError('No verified helper execution; not falling back')
            query(f, 'test ! -L /mnt/media_rw/ssd/X2V_BENCH && mkdir -p /mnt/media_rw/ssd/X2V_BENCH')
            query(f, 'mkdir ' + media)
        script = f'''#!/system/bin/sh
set -u
cd {remote} || exit 90
set -C
: >{media}/data.partial || exit 91
timeout 48 nice -n 10 {DEVICE_BINARY} --mib {args.mib} 3<>{media}/data.partial >result.json 2>error.log
rc=$?
printf '%s\\n' "$rc" >exit.code
chmod 644 result.json error.log exit.code
exit "$rc"
'''
        local_script = out/'controller.sh'
        local_script.write_text(script)
        adb('push', str(local_script), remote+'/controller.sh')
        with connect() as f:
            if query(f, 'sha256sum '+remote+'/controller.sh').split()[0] != hashlib.sha256(local_script.read_bytes()).hexdigest():
                raise RuntimeError('Controller hash differs')
            report['dispatch_pid'] = query(f, f'cd {remote};toybox nohup sh controller.sh >controller.log 2>&1 & echo $!').strip()
            if not report['dispatch_pid'].isdigit():
                raise RuntimeError('No supervisor PID')
            report['dispatch_identity'] = query(f, 'cat /proc/'+report['dispatch_pid']+'/stat')
        save()
        deadline = time.monotonic()+52
        while time.monotonic() < deadline:
            ready = adb('shell', 'if [ -f '+remote+'/exit.code ]; then cat '+remote+'/exit.code; fi').strip()
            if ready:
                report['exit_code'] = int(ready)
                break
            time.sleep(.4)
        else:
            raise RuntimeError('Outer observation deadline; inspect same supervisor, do not restart')
        for name in ['result.json', 'error.log', 'controller.log', 'exit.code']:
            adb('pull', remote+'/'+name, str(out/name))
        if report['exit_code'] != 0:
            raise RuntimeError('Benchmark failed: '+(out/'error.log').read_text())
        result = json.loads((out/'result.json').read_text())
        if not (result['direct_required'] and not result['host_buffered_test'] and
                result['bytes'] == args.mib*1024*1024 and result['full_readback_equal'] and
                result['write_plus_fsync_seconds'] > 0):
            raise RuntimeError('Result contract failed')
        report['result'] = result
        report['io_verified'] = True
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        try:
            with connect() as f:
                report['after'] = snapshot(f)
                report['ssd_free_after'] = query(f, 'df -k /mnt/media_rw/ssd')
        except BaseException as exc:
            report['health_read_error'] = repr(exc)
        a, b = report.get('after', {}), report.get('before', {})
        report['passed'] = bool(report.get('io_verified') and not report.get('failure') and
            not report.get('health_read_error') and a.get('gui_init') == 'running' and
            a.get('gui') == b.get('gui') and a.get('service') == b.get('service') and
            check_state(a.get('state', '')) and '(ro,' in a.get('system_mount', ''))
        save()
        print(json.dumps({'passed': report['passed'], 'report': str(out/'report.json'),
                          'failure': report.get('failure'),
                          'MBps': report.get('result', {}).get('write_plus_fsync_MBps')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
