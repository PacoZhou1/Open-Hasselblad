"""Install the persistent ProRes RAW recorder into /system and start it."""
import hashlib
import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect

ROOT = Path(__file__).resolve().parents[1]
SERIAL = '123456789ABCDEF'
REMOTE = '/blackbox/x2v-native-20261011'
REC = REMOTE + '/prr-rec'
DATA = '/data/x2v-native-20261012'
BIN = '/system/bin/x2v_prr_rec_20261013e'
RC = '/system/etc/init/x2v-prr-rec.rc'
GUI_RC = '/system/etc/init/x2v-prr-gui.rc'
STAGER = ROOT / 'native-video/experimental/ssd-direct-write/stage_artifact_data.sh'
STAGE_SHA = '5bcfb0c2183e321531b11cca5225b9b67805e0a0ac7ce1451f2746e7d80acd78'
SRC = ROOT / 'native-video/experimental/prr-product-recorder'
PKT = ROOT / 'native-video/experimental/source-session-isolated-two-prr-async'
DAEMON = SRC / 'x2v_prr_rec.sh'


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def adb(*args, timeout=60):
    r = subprocess.run(['adb', '-s', SERIAL, *args], capture_output=True, text=True, timeout=timeout)
    if r.returncode:
        raise RuntimeError((r.stderr or r.stdout or 'adb failed').strip())
    return r.stdout


def main():
    assert sha(STAGER) == STAGE_SHA
    expected = sha(DAEMON)
    adb('shell', 'echo %d > %s/keepawake.lease' % (int(time.time()) + 180, REMOTE))
    adb('push', str(SRC / 'controller.sh'), REC + '/controller.sh')
    adb('push', str(PKT / 'imx861bqr_hb722.sp'), REC + '/imx861bqr_hb722.sp')
    adb('push', str(PKT / 'imx861bqr_hb722.conf'), REC + '/imx861bqr_hb722.conf')
    adb('push', str(ROOT / 'native-video/experimental/prr-product-gui/x2v_prr_helper.sh'), REMOTE + '/rec/helper.sh')
    adb('push', str(ROOT / 'native-video/experimental/prr-product-gui/x2v-prr-gui.rc'), REMOTE + '/x2v-prr-gui.rc')
    adb('push', str(SRC / 'x2v-prr-rec.rc'), REMOTE + '/x2v-prr-rec.rc')
    print('packet', adb('shell', 'ls -l %s/controller.sh %s/imx861bqr_hb722.sp' % (REC, REC)), flush=True)

    run = time.strftime('prr-rec-stage-%H%M%S')
    inbox = DATA + '/runs/' + run + '_upload'
    dest = DATA + '/runs/' + run
    adb('shell', 'mkdir -p %s %s/rec' % (inbox, REMOTE))
    adb('push', str(DAEMON), inbox + '/artifact')
    adb('push', str(STAGER), inbox + '/stage.sh')
    if adb('shell', 'sha256sum %s/artifact' % inbox).split()[0] != expected:
        raise SystemExit('upload sha mismatch')
    launch = '#!/system/bin/sh\nexec sh %s/stage.sh %s/artifact %s %s %s\n' % (inbox, inbox, BIN, expected, run)
    local = ROOT / 'native-video/outputs/prr-rec-launch.sh'
    local.parent.mkdir(parents=True, exist_ok=True)
    local.write_text(launch)
    adb('push', str(local), inbox + '/launch.sh')
    pid = adb('shell', 'cd %s && toybox nohup sh launch.sh >session.log 2>&1 & echo $!' % inbox).strip()
    print('stage pid', pid, flush=True)
    phase = ''
    deadline = time.monotonic() + 50
    while time.monotonic() < deadline:
        phase = adb('shell', 'if [ -f %s/stage-complete ]; then cat %s/phase; fi' % (dest, dest)).strip()
        if phase:
            break
        time.sleep(0.5)
    print('stage phase', phase, flush=True)
    print(adb('shell', 'cat %s/session.log' % inbox), flush=True)
    if phase not in ('installed_readonly', 'reused_identical'):
        raise SystemExit('stage failed: ' + phase)

    with connect() as f:
        def q(cmd, ms=8000):
            assert len(cmd.encode()) <= 231, (len(cmd.encode()), cmd)
            return f.factory_shell(cmd, capture_ms=ms).strip()
        print('remount', q('mount -o remount,rw /system && echo RW'), flush=True)
        try:
            print('rc', q('cp %s/x2v-prr-gui.rc %s; cp %s/x2v-prr-rec.rc %s; chmod 644 %s %s; echo RC' % (
                REMOTE, GUI_RC, REMOTE, RC, GUI_RC, RC)), flush=True)
        finally:
            print('ro', q('mount -o remount,ro /system; mount | grep " /system "'), flush=True)
        print('helper', q('chmod 755 %s/rec/helper.sh %s/controller.sh; echo 1 > %s/rec/helper.stop; echo STOP' % (REMOTE, REC, REMOTE)), flush=True)
        time.sleep(1.2)
        print('helper go', q('rm -f %s/rec/helper.stop %s/rec/recorder.stop; echo GO' % (REMOTE, REMOTE)), flush=True)
        start = 'cd %s && toybox nohup sh helper.sh </dev/null >helper.log 2>&1 & echo $!' % (REMOTE + '/rec')
        assert len(start.encode()) <= 231
        print('helper pid', q(start), flush=True)
        print('svc', q('getprop init.svc.x2v-prr-rec; ls -l %s' % BIN), flush=True)
        launched = q('setprop ctl.start x2v-prr-rec; echo START')
        print('ctl', launched, flush=True)
    time.sleep(1.5)
    svc = adb('shell', 'getprop init.svc.x2v-prr-rec').strip()
    print('init.svc.x2v-prr-rec', svc, flush=True)
    if svc != 'running':
        with connect() as f:
            cmd = 'toybox nohup sh %s </dev/null >>%s/rec/recorder.log 2>&1 & echo $!' % (BIN, REMOTE)
            assert len(cmd.encode()) <= 231, len(cmd.encode())
            print('factory start', f.factory_shell(cmd, capture_ms=5000).strip(), flush=True)
        time.sleep(1)
    print('log', adb('shell', 'tail -n 20 %s/rec/recorder.log 2>/dev/null || echo NOLOG'), flush=True)
    print('pid', adb('shell', 'cat %s/rec/recorder.pid 2>/dev/null || echo NOPID' % REMOTE), flush=True)
    print('bin', adb('shell', 'sha256sum %s' % BIN), flush=True)


if __name__ == '__main__':
    raise SystemExit(main())
