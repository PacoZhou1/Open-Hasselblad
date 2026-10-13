"""One original camera-test restart; observation-only independent ADB guard.

Original camera-service and camera-gui must remain the exact same processes.
No manual camera producer, owners seal, dispatch permit, or sensor-mode change.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import secrets
import time

from factory_session import connect
from gui_session import adb

ROOT = Path(__file__).resolve().parents[1]
CANDIDATE = ROOT / 'native-video/experimental/source-owner-isolation-b'
REMOTE = '/data/x2v-source-20261012/runs/'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--execute', action='store_true')
    args = ap.parse_args()
    if not args.execute:
        print('OFFLINE: restart only camera-test; independent guard has no recovery permit')
        return 0
    freeze = json.loads((CANDIDATE / 'freeze.json').read_text())
    expected = freeze['files']['guard.sh']
    assert sha(CANDIDATE / 'guard.sh') == expected
    run = datetime.now().strftime('source-guard-survival-%H%M%S')
    out = ROOT / 'native-video/outputs' / run
    out.mkdir(exist_ok=False)
    remote = REMOTE + run
    report = {'run': run, 'guard_sha256': expected, 'restart_dispatched': False,
              'passed': False, 'scope': 'camera-test restart; original imaging owner unchanged'}
    def snapshot():
        assert adb('shell', 'getprop init.svc.camera-service').strip() == 'running'
        with connect() as f:
            def q(c):
                assert len(c.encode()) <= 231
                return f.factory_shell(c, capture_ms=5000)
            return {'identities': q('for n in camera-service camera-gui camera-test; do p=$(pidof $n);echo NAME:$n;cat /proc/$p/stat;cat /proc/$p/cgroup;done'),
                    'frames': q('odindb-send -s camera -m get_frame_count'),
                    'state': q('odindb-send -s camera -p live_view_state,liveview_transport_mode_current,stream_group,crop_mode_current')}
    def identities(s):
        d = {}
        for block in s['identities'].split('NAME:')[1:]:
            lines = block.splitlines()
            stat = lines[1]
            tail = stat.rsplit(') ', 1)[1].split()
            d[lines[0]] = {'pid': int(stat.split()[0]), 'start': int(tail[19]),
                          'pgid': int(tail[2]), 'cgroup': next(x.split(':', 2)[2] for x in lines if ':cpuacct:' in x)}
        return d
    try:
        report['before'] = snapshot()
        before = identities(report['before'])
        fp = before['camera-test']
        assert fp['cgroup'] == '/uid_0/pid_' + str(fp['pid'])
        boot = adb('shell', 'cat /proc/sys/kernel/random/boot_id').strip()
        now = int(adb('shell', '/system/bin/x2v_guard_clock_20261012b').strip())
        nonce = secrets.token_hex(16)
        (out / 'binding').write_text(f'v1 {run} {nonce} {boot} {now+120} {fp["pid"]} {fp["start"]} {fp["pgid"]}\n')
        adb('shell', f'test ! -e {remote} && mkdir {remote}')
        for p, name in [(CANDIDATE / 'guard.sh', 'guard.sh'), (out / 'binding', 'binding')]:
            adb('push', str(p), remote + '/' + name)
            assert adb('shell', 'sha256sum '+remote+'/'+name).split()[0] == sha(p)
        report['arm'] = adb('shell', f'sh {remote}/guard.sh --arm {run}')
        launch = out / 'launch.sh'
        launch.write_text(f'#!/system/bin/sh\nexec sh {remote}/guard.sh --guard {run}\n')
        adb('push', str(launch), remote + '/launch.sh')
        report['guard_launch'] = adb('shell', f'toybox nohup sh {remote}/launch.sh < /dev/null >{remote}/guard.log 2>&1 & echo $!')
        time.sleep(2)
        ready = adb('shell', f'cat {remote}/adb-guard.ready').strip().split()
        assert ready[:3] == ['v1', run, nonce] and ready[-1] == boot
        assert len(ready) == 8 and ready[5] != fp['cgroup'] and int(ready[6]) != fp['pgid']
        gp, gs = int(ready[3]), int(ready[4])
        report['ready'] = ready
        report['heartbeat_before'] = adb('shell', f'cat {remote}/adb-guard.heartbeat').strip()
        adb('shell', f'test ! -e {remote}/owners && test ! -e {remote}/dispatch.permit && test ! -e {remote}/adb-guard.dispatch.lock')
        report['restart_dispatched'] = True
        adb('shell', 'setprop ctl.restart camera-test')
        # No HblShell requests while the restarted proxy obtains initial state.
        time.sleep(10)
        assert adb('shell', 'getprop init.svc.camera-test').strip() == 'running'
        report['guard_stat_after'] = adb('shell', f'cat /proc/{gp}/stat')
        tail = report['guard_stat_after'].rsplit(') ', 1)[1].split()
        assert int(tail[19]) == gs and tail[0] != 'Z'
        report['heartbeat_after'] = adb('shell', f'cat {remote}/adb-guard.heartbeat').strip()
        assert int(report['heartbeat_after'].split()[-1]) > int(report['heartbeat_before'].split()[-1])
        report['after'] = snapshot()
        after = identities(report['after'])
        assert all(before[n] == after[n] for n in ('camera-service', 'camera-gui'))
        assert before['camera-test']['pid'] != after['camera-test']['pid']
        assert report['after']['state'] == report['before']['state']
        def count(s):
            return int(next(x.split(' = ')[1] for x in s.splitlines() if x.startswith('count = ')))
        assert count(report['after']['frames']) > count(report['before']['frames'])
        adb('shell', f'test ! -e {remote}/adb-guard.dispatch.lock')
        report['passed'] = True
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        try:
            adb('pull', remote, str(out / 'device-run'))
        except BaseException as exc:
            report['pull_error'] = repr(exc)
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps({'passed': report['passed'], 'report': str(out / 'report.json'),
                          'failure': report.get('failure')}, indent=2))
    return 0 if report['passed'] else 1

if __name__ == '__main__':
    raise SystemExit(main())
