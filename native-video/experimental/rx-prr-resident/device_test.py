#!/usr/bin/env python3
"""Development driver for the resident video session (the product path runs on the camera itself)."""
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'local-verification'))
from factory_session import connect  # noqa: E402

SERIAL = '123456789ABCDEF'
BB = '/blackbox/x2v-native-20261011'
HOME = BB + '/video'
# Development builds go to a name derived from their hash, so an installed file is never replaced.
DEV = os.environ.get('X2V_DEV') == '1'
LIB = '/system/lib64/libx2v_prr_resident_20261013g.so'
if DEV:
    LIB = '/system/lib64/libx2v_prr_resident_dev%s.so' % hashlib.sha256(
        (HERE / 'build/libx2v_prr_resident.so').read_bytes()).hexdigest()[:8]
SCRIPT = HOME + '/x2v_video_session.sh'
PKT = ROOT / 'native-video/experimental/source-session-isolated-two-prr-async'


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def adb(*args, timeout=120):
    r = subprocess.run(['adb', '-s', SERIAL, *args], capture_output=True, text=True, timeout=timeout)
    if r.returncode:
        raise RuntimeError((r.stderr or r.stdout).strip())
    return r.stdout


def fq(f, cmd, ms=8000):
    assert len(cmd.encode()) <= 231, (len(cmd.encode()), cmd)
    return f.factory_shell(cmd, capture_ms=ms).strip()


def lease():
    adb('shell', 'echo %d > %s/keepawake.lease' % (int(time.time()) + 600, BB))


def install():
    lib = HERE / 'build/libx2v_prr_resident.so'
    want = sha(lib)
    adb('shell', 'mkdir -p %s/stage' % HOME)
    adb('push', str(lib), HOME + '/stage/lib.so')
    adb('push', str(HERE / 'x2v_video_session.sh'), SCRIPT)
    for n in ['imx861bqr_hb722.sp', 'imx861bqr_hb722.conf']:
        adb('push', str(PKT / n), HOME + '/' + n)
    with connect() as f:
        cur = fq(f, 'sha256sum %s 2>/dev/null; true' % LIB).split()
        if cur and cur[0] == want:
            print('lib already installed', want)
        elif cur:
            raise SystemExit('refusing to replace %s (hash %s); bump the file name' % (LIB, cur[0]))
        else:
            print(fq(f, 'mount -o remount,rw /system && echo RW'))
            try:
                print(fq(f, 'L=%s;cp %s/stage/lib.so $L&&chmod 644 $L&&restorecon $L;sha256sum $L' % (LIB, HOME)))
            finally:
                print(fq(f, 'mount -o remount,ro /system; mount | grep " /system " | cut -c1-60'))
        print(fq(f, 'ls -lZ %s; chmod 755 %s; echo OK' % (LIB, SCRIPT)))
    print('lib sha', want)


def run(action, ms=8000, gui=None):
    lease()
    env = 'X2V_GUI_MODE=%s ' % gui if gui else ''
    if DEV:
        # The factory channel takes 231 bytes; the dev override travels in a file instead.
        adb('shell', 'echo "export X2V_LIB=%s X2V_LIB_SHA=%s" > %s/dev.env'
            % (LIB, sha(HERE / 'build/libx2v_prr_resident.so'), HOME))
        env = '. ./dev.env; ' + env
    if action in ('enter', 'exit'):
        adb('shell', 'rm -f %s/session.pid' % HOME)
        with connect() as f:
            # setsid: camera-test's process group is killed with it when the stock service stops.
            print(action, 'pid', fq(f, 'cd %s && %stoybox setsid sh -x %s %s </dev/null >%s.out 2>&1 & echo $!' % (HOME, env, SCRIPT, action, action)))
        migrate()
        return
    with connect() as f:
        print(fq(f, 'sh %s %s' % (SCRIPT, action), ms))


def migrate():
    # Dev only: move the launcher out of camera-test's cgroup into adbd's, as the proven tests do.
    end = time.monotonic() + 10
    while time.monotonic() < end:
        pid = subprocess.run(['adb', '-s', SERIAL, 'shell', 'cat %s/session.pid 2>/dev/null' % HOME],
                             capture_output=True, text=True).stdout.strip()
        if pid.isdigit():
            adbd = adb('shell', 'pidof adbd').strip().split()[0]
            print('migrate', pid, '->', adbd,
                  adb('shell', 'echo %s > /acct/uid_0/pid_%s/cgroup.procs && echo OK' % (pid, adbd)).strip())
            return
        time.sleep(0.2)
    raise SystemExit('launcher never published session.pid')


def watch(seconds):
    end = time.monotonic() + seconds
    last = None
    while time.monotonic() < end:
        # adb, not the factory channel: that channel dies while camera-service is handed over.
        s = subprocess.run(['adb', '-s', SERIAL, 'shell', 'tail -n 3 %s/session.log; grep X2V_RESIDENT %s/service.log | tail -n 2' % (HOME, HOME)],
                           capture_output=True, text=True, timeout=10).stdout.strip()
        if s != last:
            print(time.strftime('%H:%M:%S'), s, flush=True)
            last = s
        time.sleep(1.5)


def logs():
    with connect() as f:
        print(fq(f, 'tail -n 40 %s/session.log' % HOME, 5000))
        print(fq(f, 'grep -E "X2V_(RESIDENT|SOURCE_ADAPTER|GRAPH|SOURCE_FPS)" %s/service.log | tail -n 25' % HOME, 5000))


if __name__ == '__main__':
    a = sys.argv[1]
    if a == 'install':
        install()
    elif a == 'watch':
        watch(float(sys.argv[2]) if len(sys.argv) > 2 else 30)
    elif a == 'logs':
        logs()
    else:
        run(a, ms=int(sys.argv[2]) if len(sys.argv) > 2 else 30000, gui=(sys.argv[3] if len(sys.argv) > 3 else None))
