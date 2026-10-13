"""Push overlay QML onto a running product GUI and restart the overlay child.
Does not restore stock camera-gui.
"""
import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect

SERIAL = '123456789ABCDEF'
REMOTE = '/blackbox/x2v-native-20261011'
GUI = REMOTE + '/gui'
REC = REMOTE + '/rec'
ROOT = Path(__file__).resolve().parents[1]
PKG = ROOT / 'native-video/outputs/gui-sessions/prr-gui-persist'
SRC = ROOT / 'native-video/experimental/prr-product-gui'


def adb(*args, timeout=30):
    r = subprocess.run(['adb', '-s', SERIAL, *args], capture_output=True, text=True, timeout=timeout)
    if r.returncode:
        raise RuntimeError((r.stderr or r.stdout or 'adb failed').strip())
    return r.stdout


def main():
    print('keepawake', Path('local-verification/keepawake-state.json').read_text(), flush=True)
    adb('shell', 'echo %d > %s/keepawake.lease' % (int(time.time()) + 120, REMOTE))
    overlay = PKG / 'payload' / 'gui'
    payload_gui = REMOTE + '/runs/prr-gui-persist/payload/gui'
    for p in sorted(overlay.iterdir()):
        if p.is_file():
            adb('push', str(p), GUI + '/' + p.name)
            adb('push', str(p), payload_gui + '/' + p.name)
            print('push', p.name, flush=True)
    adb('push', str(SRC / 'x2v_prr_helper.sh'), REC + '/helper.sh')
    adb('push', str(PKG / 'payload' / 'manifest.sha256'),
        REMOTE + '/runs/prr-gui-persist/payload/manifest.sha256')
    catalog = ROOT / 'native-video/outputs/prr-product-gui-install/catalog.json'
    if catalog.is_file():
        adb('push', str(catalog), REC + '/catalog.json')
        print('catalog', catalog.stat().st_size, flush=True)
    print('ls', adb('shell', 'ls -l %s/main.qml %s/BodyKeys.qml %s/ExposureTouchTabs.qml %s/helper.sh'
                    % (GUI, GUI, GUI, REC)), flush=True)

    with connect() as f:
        def q(cmd, ms=4000):
            assert len(cmd.encode()) <= 231, (len(cmd.encode()), cmd)
            return f.factory_shell(cmd, capture_ms=ms).strip()
        print('chmod', q('chmod 644 %s/*.qml %s/*.js; chmod 755 %s/helper.sh; echo OK' % (GUI, GUI, REC)), flush=True)
        print('clear', q('rm -f %s/rec-start.png %s/rec-stop.png %s/command %s/busy; echo CLEARED'
                         % (REMOTE, REMOTE, REC, REC)), flush=True)
        print('timeout', q('odindb-send -s system -p screen_idle_timeout'), flush=True)
        print('wake', q('odindb-send -s system -m acquire_wake_lock -- x2v-debug-session'), flush=True)
        print('timeout0', q('odindb-send -s system -p screen_idle_timeout -- 0'), flush=True)
        print('helper.stop', q('printf 1 > %s/helper.stop; echo STOP' % REC), flush=True)
        time.sleep(1.2)
        print('helper.go', q('rm -f %s/helper.stop; echo GO' % REC), flush=True)
        print('gui pids', q('p=$(pidof camera-gui); echo PIDS:$p'), flush=True)
        print('kill overlay', q('kill $(pidof camera-gui); echo K'), flush=True)

    print('waiting overlay restart', flush=True)
    pids = ''
    for i in range(20):
        time.sleep(1)
        pids = adb('shell', 'pidof camera-gui || true').strip()
        svc = adb('shell', 'getprop init.svc.camera-gui').strip()
        print(i, 'svc', svc, 'pids', pids, flush=True)
        if pids:
            break

    with connect() as f:
        def q(cmd, ms=5000):
            assert len(cmd.encode()) <= 231, (len(cmd.encode()), cmd)
            return f.factory_shell(cmd, capture_ms=ms).strip()
        print('override', q('timeout 4 odindb-send -s camera -p forward_input_events,live_view_state'), flush=True)
        print('overlay env', q("p=$(pidof camera-gui); tr '\\0' '\\n' </proc/$p/environ | grep X2V_GUI"), flush=True)
        print('helper', q('cat %s/state.json' % REC), flush=True)
        print('hashes', q('sha256sum %s/BodyKeys.qml %s/main.qml %s/ExposureTouchTabs.qml' % (GUI, GUI, GUI)), flush=True)


if __name__ == '__main__':
    raise SystemExit(main())
