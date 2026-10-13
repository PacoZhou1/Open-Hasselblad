"""Stage only the pinned ordinary-file benchmark using the reviewed protocol."""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import time

from factory_session import connect
from gui_session import adb, verify_device
from ssd_direct_test import BINARY, EXPECTED, DEVICE_BINARY

ROOT = Path(__file__).resolve().parents[1]
STAGER = ROOT/'native-video/experimental/ssd-direct-write/stage_artifact_data.sh'
STAGE_SHA = '5bcfb0c2183e321531b11cca5225b9b67805e0a0ac7ce1451f2746e7d80acd78'
RUN_PREFIX = 'ssd-stage'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--execute', action='store_true')
    args = ap.parse_args()
    assert sha(BINARY) == EXPECTED and sha(STAGER) == STAGE_SHA
    if not args.execute:
        print(json.dumps({'offline_only': True, 'destination': DEVICE_BINARY,
                          'same_guarded_stage_protocol': True}))
        return 0
    verify_device()
    run = datetime.now().strftime(RUN_PREFIX+'-%H%M%S')
    out = ROOT/'native-video/outputs'/run
    out.mkdir(exist_ok=False)
    base = '/data/x2v-native-20261012'
    inbox = base+'/runs/'+run+'_upload'
    dest = base+'/runs/'+run
    report = {'run_id': run, 'destination': DEVICE_BINARY, 'passed': False,
              'source_sha256': EXPECTED, 'stage_sha256': STAGE_SHA, 'events': []}

    def q(cmd):
        result = adb('shell', cmd)
        report['events'].append({'command': cmd, 'output': result})
        return result

    def health():
        with connect() as f:
            return f.factory_shell('pidof camera-service;pidof camera-gui;getprop init.svc.camera-gui;mount | grep " /system "', capture_ms=6000)

    try:
        report['before'] = health()
        if 'running' not in report['before'] or '(ro,' not in report['before']:
            raise RuntimeError('Need healthy stock GUI and read-only system')
        q(f'test ! -e {base}/gui-session.lock && mkdir -p {base}/runs && test ! -e {inbox} && mkdir {inbox}')
        for local, name in [(BINARY, 'artifact'), (STAGER, 'stage.sh')]:
            adb('push', str(local), inbox+'/'+name)
            if q('sha256sum '+inbox+'/'+name).split()[0] != sha(local):
                raise RuntimeError('Upload SHA differs')
        launch = out/'launch.sh'
        launch.write_text(f'#!/system/bin/sh\nexec sh {inbox}/stage.sh {inbox}/artifact {DEVICE_BINARY} {EXPECTED} {run}\n')
        adb('push', str(launch), inbox+'/launch.sh')
        if q('sha256sum '+inbox+'/launch.sh').split()[0] != sha(launch):
            raise RuntimeError('Launch SHA differs')
        pid = q(f'cd {inbox} && toybox nohup sh launch.sh >session.log 2>&1 & echo $!').strip()
        report['pid'] = pid
        if not pid.isdigit():
            raise RuntimeError('No staging PID')
        # A small immutable copy may finish before the first /proc read.
        # Observe this run's completion marker instead of dispatching it again.
        report['dispatch_identity'] = q('if [ -r /proc/'+pid+'/stat ]; then cat /proc/'+pid+'/stat; fi')
        deadline = time.monotonic()+45
        while time.monotonic() < deadline:
            result = q(f'if [ -f {dest}/stage-complete ]; then cat {dest}/phase; fi').strip()
            if result:
                report['phase'] = result
                break
            time.sleep(.5)
        report['session_log'] = q('cat '+inbox+'/session.log')
        if report.get('phase') not in ('installed_readonly', 'reused_identical'):
            raise RuntimeError('Stage did not confirm publication; inspect existing session')
        if q('sha256sum '+DEVICE_BINARY).split()[0] != EXPECTED:
            raise RuntimeError('Installed SHA differs')
        report['installed_label'] = q('ls -lZ '+DEVICE_BINARY)
        report['lock_absent'] = q(f'test ! -e {base}/gui-session.lock; echo RC:$?').strip() == 'RC:0'
        report['published'] = True
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        try:
            report['after'] = health()
        except BaseException as exc:
            report['recovery_read_error'] = repr(exc)
        report['passed'] = bool(report.get('published') and report.get('lock_absent') and
                               not report.get('failure') and report.get('before') == report.get('after'))
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps({'passed': report['passed'], 'report': str(out/'report.json'),
                          'phase': report.get('phase'), 'failure': report.get('failure')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
