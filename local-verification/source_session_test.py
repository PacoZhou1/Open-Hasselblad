"""Root-only stock source-owner smoke; default offline, exact frozen controller.

The device controller owns lifecycle and a separate userspace watchdog.
The watchdog shares resources with the native owner; its timeout is not a
guarantee of recovery when the process, filesystem, or kernel is stalled.
Host disconnects never cancel it or prove recovery. No mode/preload overrides.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import secrets
import time

from factory_session import connect
from gui_session import adb, verify_device

ROOT = Path(__file__).resolve().parents[1]
CANDIDATE = ROOT/'native-video/experimental/source-session'
MODE = 'normal-stock'
RUN_PREFIX = 'source-stock'
EXTRA_MARKER = None
INDEPENDENT_GUARD = False
HOST_TIMEOUT = 125
EXECUTION_HOLD = Path(__file__).with_name('source_session_execution_hold.json')
REMOTE = '/data/x2v-source-20261012'
STATE = ('odindb-send -s camera -p live_view_state,'
         'liveview_transport_mode_current,stream_group,crop_mode_current')
NORMAL = ('live_view_state = E_LiveViewState_Active(1)',
          'liveview_transport_mode_current = E_LiveviewTransportMode_None(0)',
          'stream_group = E_StreamGroup_Still16bit(0)',
          'crop_mode_current = E_CropMode_None(0)')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--execute', action='store_true')
    args = ap.parse_args()
    if not args.execute:
        print(json.dumps({'offline_only': True, 'mode': MODE,
                          'preload': MODE != 'normal-stock', 'controller': str(CANDIDATE/'controller.sh'),
                          'requires_root_reviewed_freeze': True,
                          'execution_hold_present': EXECUTION_HOLD.exists()}))
        return 0
    # No USB request, staging, or dispatch while a previous native owner has
    # unknown health. Removing this file requires resolving its recorded gates.
    if EXECUTION_HOLD.exists() and MODE not in json.loads(EXECUTION_HOLD.read_text()).get('released_modes', []):
        raise RuntimeError('Source-owner experiments held: '+str(EXECUTION_HOLD))
    frozen = json.loads((CANDIDATE/'freeze.json').read_text())
    controller = CANDIDATE/'controller.sh'
    if sha(controller) != frozen['controller_sha256']:
        raise RuntimeError('Controller differs from reviewed freeze')
    runtime_files = frozen.get('runtime_files', {'controller.sh': frozen['controller_sha256']})
    if runtime_files.get('controller.sh') != frozen['controller_sha256'] or len(runtime_files) > 4:
        raise RuntimeError('Invalid fixed runtime packet')
    for name, digest in runtime_files.items():
        if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,79}', name):
            raise RuntimeError('Runtime packet requires flat fixed filenames')
        local = CANDIDATE/name
        if local.is_symlink() or not local.is_file() or local.stat().st_size > 2*1024*1024 or sha(local) != digest:
            raise RuntimeError('Runtime packet file differs: '+name)
    # camera-test's executeSuTestCmd creates a dangling stack-loop connection
    # when its CameraProxy is unsynchronised. Do not send HblShell requests
    # during a stopped/transitioning source owner. A running init property is
    # only a prerequisite, not proof that the factory proxy is synchronised.
    if adb('shell', 'getprop init.svc.camera-service').strip() != 'running':
        raise RuntimeError('Stock service is not running; no factory HblShell request sent')
    verify_device()
    run = datetime.now().strftime(RUN_PREFIX+'-%H%M%S')
    out = ROOT/'native-video/outputs'/run
    out.mkdir(exist_ok=False)
    remote = REMOTE+'/runs/'+run
    report = {'run_id': run, 'mode': MODE, 'remote': remote,
              'controller_sha256': sha(controller), 'dispatched': False,
              'passed': False, 'queries': []}

    def query(f, command):
        if len(command.encode()) > 231:
            raise ValueError('Factory command exceeds 231-byte limit')
        result = f.factory_shell(command, capture_ms=6000)
        report['queries'].append({'command': command, 'output': result})
        return result

    def snapshot():
        if adb('shell', 'getprop init.svc.camera-service').strip() != 'running':
            raise RuntimeError('Health query withheld: stock service is not running; avoid unsynchronised factory HblShell')
        with connect() as f:
            return {'state': query(f, STATE),
                    'processes': query(f, 'pidof camera-service;pidof camera-gui;getprop init.svc.camera-service;getprop init.svc.camera-gui'),
                    'system_mount': query(f, 'mount | grep " /system "')}

    def normal(s):
        return (all(x in s['state'].splitlines() for x in NORMAL) and
                s['processes'].splitlines()[2:] == ['running', 'running'] and
                '(ro,' in s['system_mount'])

    try:
        report['before'] = snapshot()
        if not normal(report['before']):
            raise RuntimeError('Original service/GUI/liveview/read-only baseline required')
        for peer in ['/blackbox/x2v-native-20261011', '/data/x2v-native-20261012']:
            adb('shell', f'test -d {peer} && test ! -L {peer} && test ! -e {peer}/gui-session.lock')
        # Exclusively allocated data directory; no blackbox bulk/control files.
        adb('shell', f'test ! -L {REMOTE} && mkdir -p {REMOTE}/runs && test ! -e {remote} && mkdir {remote}')
        for name, digest in runtime_files.items():
            adb('push', str(CANDIDATE/name), remote+'/'+name)
            if adb('shell', 'sha256sum '+remote+'/'+name).split()[0] != digest:
                raise RuntimeError('Uploaded runtime packet hash differs: '+name)
        if INDEPENDENT_GUARD:
            expected_guard = '2d1f0b22b77a011d3d11e66fb4a64ec09455a0f1f73c60a8262317f7d9a41930'
            if runtime_files.get('guard.sh') != expected_guard:
                raise RuntimeError('Independent guard differs from reviewed and device-tested candidate')
            with connect() as f:
                raw = query(f, 'p=$(pidof camera-test);cat /proc/$p/stat;cat /proc/$p/cgroup')
            lines = raw.strip().splitlines()
            fp = int(lines[0].split()[0])
            fields = lines[0].rsplit(') ', 1)[1].split()
            fs, fg = int(fields[19]), int(fields[2])
            if '2:cpuacct:/uid_0/pid_'+str(fp) not in lines:
                raise RuntimeError('Factory owner cgroup mismatch')
            boot = adb('shell', 'cat /proc/sys/kernel/random/boot_id').strip()
            now = int(adb('shell', '/system/bin/x2v_guard_clock_20261012b').strip())
            nonce = secrets.token_hex(16)
            for name, value in [('binding', f'v1 {run} {nonce} {boot} {now+270} {fp} {fs} {fg}\n'),
                                ('dispatch.permit', f'v1 {run} {nonce} kernel_stock_only\n')]:
                local = out/name
                local.write_text(value)
                adb('push', str(local), remote+'/'+name)
                if adb('shell', 'sha256sum '+remote+'/'+name).split()[0] != sha(local):
                    raise RuntimeError('Guard binding/permit upload mismatch')
            report['guard_arm'] = adb('shell', f'sh {remote}/guard.sh --arm {run}')
            glaunch = out/'guard-launch.sh'
            glaunch.write_text(f'#!/system/bin/sh\nexec sh {remote}/guard.sh --guard {run}\n')
            adb('push', str(glaunch), remote+'/guard-launch.sh')
            report['guard_dispatch'] = adb('shell', f'toybox nohup sh {remote}/guard-launch.sh < /dev/null >{remote}/guard.log 2>&1 & echo $!')
            time.sleep(2)
            ready = adb('shell', f'cat {remote}/adb-guard.ready').strip().split()
            if (len(ready) != 8 or ready[:3] != ['v1', run, nonce] or ready[-1] != boot or
                    ready[5] == '/uid_0/pid_'+str(fp) or int(ready[6]) == fg):
                raise RuntimeError('Guard is not independently ready')
            report['guard_ready'] = ready
            hb = adb('shell', f'cat {remote}/adb-guard.heartbeat').strip().split()
            now = int(adb('shell', '/system/bin/x2v_guard_clock_20261012b').strip())
            if hb[:4] != ['v1', run, nonce, ready[3]] or not 0 <= now-int(hb[4]) <= 5:
                raise RuntimeError('Guard heartbeat stale')
            report['guard_heartbeat'] = hb
        launch = out/'launch.sh'
        launch.write_text('#!/system/bin/sh\nexec sh '+remote+'/controller.sh --execute-'+MODE+' '+run+'\n')
        adb('push', str(launch), remote+'/launch.sh')
        if adb('shell', 'sha256sum '+remote+'/launch.sh').split()[0] != sha(launch):
            raise RuntimeError('Uploaded launcher hash differs')
        with connect() as f:
            report['dispatched'] = True
            report['dispatch_reply'] = query(f, 'cd '+remote+' && toybox nohup sh launch.sh >session.log 2>&1 & echo $!')
        # Observe run markers even when dispatch reply was lost; never redispatch.
        deadline = time.monotonic()+HOST_TIMEOUT
        last_phase = None
        while time.monotonic() < deadline:
            observation = adb('shell', 'cd '+remote+' && for n in phase body.rc recovery.rc restored; do if [ -f "$n" ]; then echo FILE:$n; cat "$n"; fi; done')
            if observation != last_phase:
                print(observation.strip(), flush=True)
                report.setdefault('observations', []).append(observation)
                last_phase = observation
            # A failed body recovery can still be followed by the independent
            # watchdog's successful recovery. Keep observing; retain both facts.
            if 'FILE:recovery.rc\n' in observation and 'FILE:restored\n' in observation:
                break
            time.sleep(1)
        else:
            raise RuntimeError('Host deadline; device watchdog state must be inspected')
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        # Evidence retrieval and health verification are independent: a missing
        # logfile must not suppress recovery observation.
        try:
            adb('pull', remote, str(out/'device-run'), timeout=60)
        except BaseException as exc:
            report['pull_error'] = repr(exc)
        try:
            report['after'] = snapshot()
        except BaseException as exc:
            report['health_error'] = repr(exc)
        try:
            report['locks_absent'] = adb('shell', 'test ! -e '+REMOTE+'/source-session.lock && test ! -e /data/x2v-native-20261012/gui-session.lock && test ! -e /blackbox/x2v-native-20261011/gui-session.lock && echo CLEAR').strip() == 'CLEAR'
        except BaseException as exc:
            report['lock_error'] = repr(exc)
        device = out/'device-run'
        def read(name):
            p = device/name
            return p.read_text().strip() if p.is_file() else None
        report['body_rc'] = read('body.rc')
        report['recovery_rc'] = read('recovery.rc')
        report['manual_frames_confirmed'] = 'PHASE manual_normal_frames_confirmed' in (read('events.log') or '')
        report['extra_marker_confirmed'] = EXTRA_MARKER is None or (device/EXTRA_MARKER).is_file()
        report['passed'] = bool(not report.get('failure') and report['body_rc'] == '0' and
                                report['recovery_rc'] == '0' and (device/'restored').is_file() and
                                report['manual_frames_confirmed'] and report['extra_marker_confirmed'] and report.get('locks_absent') and
                                report.get('after') and normal(report['after']))
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps({'passed': report['passed'], 'report': str(out/'report.json'),
                          'failure': report.get('failure')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
