"""Install the persistent ProRes RAW product GUI onto the camera. Does not restore stock."""
import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect
from camera_testing import LOCK

ROOT = Path(__file__).resolve().parents[1]
PKG = ROOT / 'native-video/outputs/gui-sessions/prr-gui-persist'
OUT = ROOT / 'native-video/outputs/prr-product-gui-install'
REMOTE = '/blackbox/x2v-native-20261011'
RUN = REMOTE + '/runs/prr-gui-persist'
SERIAL = '123456789ABCDEF'
OWNER = 'z-cursor-prr-gui'


def adb(*args, timeout=30):
    r = subprocess.run(['adb', '-s', SERIAL, *args], capture_output=True, text=True, timeout=timeout)
    if r.returncode:
        raise RuntimeError((r.stderr or r.stdout or 'adb failed').strip())
    return r.stdout


def require_claim():
    owner = json.loads((LOCK / 'owner.json').read_text())
    if owner.get('state') != 'TESTING' or owner.get('owner') != OWNER:
        raise SystemExit('claim the camera as %s first' % OWNER)


def main():
    require_claim()
    OUT.mkdir(parents=True, exist_ok=True)
    meta = json.loads((PKG / 'package.json').read_text())
    report = {'passed': False, 'restore_on_success': False, 'package': str(PKG)}
    from gui_session import verify_device
    verify_device()

    adb('shell', 'test ! -e %s/gui-session.lock' % REMOTE)
    adb('shell', 'rm -rf %s && mkdir -p %s/runs && mkdir %s' % (RUN, REMOTE, RUN))
    for name in ('payload', 'prr_gui_persist.sh', 'launch.sh'):
        adb('push', str(PKG / name), RUN + '/' + name)
    for name, key in (('payload/manifest.sha256', 'manifest_sha256'),
                      ('prr_gui_persist.sh', 'script_sha256'),
                      ('launch.sh', 'launch_sha256')):
        got = adb('shell', 'sha256sum %s/%s' % (RUN, name)).split()[0]
        if got != meta[key]:
            raise RuntimeError('upload sha mismatch %s %s %s' % (name, got, meta[key]))

    # Keep the proven playback files world-readable for VideoItem.
    with connect() as f:
        report['mp4'] = f.factory_shell(
            'ls -l %s/X2V_PRR_050839.mp4 %s/prr-050839.jpg' % (REMOTE, REMOTE), capture_ms=4000)

    dispatch = 'cd %s && toybox nohup sh launch.sh </dev/null >session.log 2>&1 & echo $!' % RUN
    assert len(dispatch.encode()) <= 231, len(dispatch.encode())
    with connect() as f:
        pid = f.factory_shell(dispatch, capture_ms=4000).strip()
    report['supervisor_pid'] = pid
    if not pid.isdigit():
        raise RuntimeError('dispatch failed: ' + pid)

    phase = ''
    deadline = time.monotonic() + 45
    while time.monotonic() < deadline:
        phase = adb('shell', 'cat %s/phase 2>/dev/null || true' % RUN).strip()
        report['phase'] = phase
        if phase in ('running', 'crash_loop', 'restored') or phase.startswith('error'):
            break
        time.sleep(1)

    report['session_log'] = adb('shell', 'cat %s/session.log 2>/dev/null || true' % RUN)
    report['dry_run'] = adb('shell', 'cat %s/dry-run.log 2>/dev/null || true' % RUN)
    report['gui_log'] = adb('shell', 'tail -c 4000 %s/gui.log 2>/dev/null || true' % RUN)
    report['child'] = adb('shell', 'cat %s/child.identity 2>/dev/null || true' % RUN)
    report['svc'] = adb('shell', 'getprop init.svc.camera-gui; pidof camera-gui || true')
    report['installed'] = adb('shell', 'ls -l %s/gui/PRODUCT_GUI.installed %s/gui/main.qml 2>/dev/null || true' % (REMOTE, REMOTE))

    time.sleep(8)
    for shot in ('prr-gui-live.png', 'prr-gui-live-ready.png'):
        try:
            adb('pull', REMOTE + '/' + shot, str(OUT / shot))
        except RuntimeError as exc:
            report.setdefault('pull_errors', []).append(shot + ': ' + str(exc))
    report['shots'] = sorted(p.name for p in OUT.glob('prr-gui-*.png'))
    report['phase_after'] = adb('shell', 'cat %s/phase 2>/dev/null || true' % RUN).strip()
    report['svc_after'] = adb('shell', 'getprop init.svc.camera-gui; pidof camera-gui || true')
    report['deaths'] = adb('shell', 'cat %s/deaths 2>/dev/null || echo 0' % RUN).strip()
    report['passed'] = report['phase_after'] == 'running' and 'stopped' in report['svc_after']
    (OUT / 'report.json').write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps({k: report[k] for k in
                      ('passed', 'phase', 'phase_after', 'supervisor_pid', 'shots',
                       'deaths', 'restore_on_success')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
