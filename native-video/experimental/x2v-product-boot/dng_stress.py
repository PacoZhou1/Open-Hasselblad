#!/usr/bin/env python3
"""The first clip after a boot, on the product path: reboot, wait for video mode, record through
the GUI, and report the clip's counters, the CPU in mid-clip (per process and per camera-service
thread) and, for DNG, the opening-frame trace.
   dng_stress.py [seconds=60] [--no-reboot] [--codec=dng|prores_raw|h264]"""
import json, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
RX = HERE.parent / 'rx-prr-resident'
sys.path.insert(0, str(RX))
import device_test as d  # noqa: E402

G = d.BB
secs = int(next((a for a in sys.argv[1:] if a.isdigit()), 60))
codec = next((a.split('=', 1)[1] for a in sys.argv[1:] if a.startswith('--codec=')), 'dng')
SNAP = '/data/local/tmp/ts'


def adb_ok():
    try:
        return d.adb('shell', 'echo ok', timeout=10).strip() == 'ok'
    except Exception:
        return False


def status(f, path='/tmp/x2v-live/status.json'):
    # In hex: the factory channel drops characters from a reply holding multibyte text (the
    # Chinese details). The supervisor rewrites its state in place; a torn read is retried.
    for _ in range(5):
        r = d.fq(f, 'od -An -v -tx1 %s 2>/dev/null; true' % path, 6000)
        try:
            return json.loads(bytes.fromhex(''.join(r.split())).decode())
        except ValueError:
            time.sleep(0.3)
    return {}


def lease():
    d.adb('shell', 'echo $(( $(date +%%s) + 1800 )) > %s/keepawake.lease' % G)


if '--no-reboot' not in sys.argv:
    with d.connect() as f:
        print(d.fq(f, 'sync; setprop sys.powerctl reboot; echo sent', 4000), flush=True)
    t0 = time.monotonic()
    time.sleep(45)
    while not adb_ok():
        subprocess.run([sys.executable, str(ROOT / 'local-verification/camera_access.py'), 'enable-adb'],
                       capture_output=True, timeout=60)
        time.sleep(3)
        if time.monotonic() - t0 > 300:
            raise SystemExit('no adb after reboot')
    lease()
    # adb comes up before the factory shell answers.
    for _ in range(10):
        try:
            with d.connect() as f:
                d.fq(f, 'true', 4000)
            break
        except Exception:
            time.sleep(6)
    with d.connect() as f:
        # The supervisor's state lives in tmpfs: whatever it says now is this boot's.
        while True:
            p = status(f, '/tmp/x2v-product/state.json')
            if p.get('session') == 'up' and p.get('phase') == 'idle':
                break
            if time.monotonic() - t0 > 400:
                raise SystemExit('video mode did not come up: %s' % p)
            time.sleep(3)
        print('video mode up %.0fs after reboot (uptime %s)' % (time.monotonic() - t0, p.get('uptime')), flush=True)
    time.sleep(5)

lease()
d.adb('push', str(RX / 'tsnap.sh'), SNAP[:SNAP.rindex('/') + 1] + 'tsnap.sh')
with d.connect() as f:
    s, p = status(f), status(f, '/tmp/x2v-product/state.json')
    print('resident', s.get('state'), '| supervisor', p.get('phase'), 'codec', p.get('codec'), flush=True)
    if s.get('state') != 'idle' or p.get('phase') not in ('idle', 'saved') or p.get('codec') != codec:
        raise SystemExit('not idle in %s mode' % codec)
    mem = d.fq(f, 'grep MemAvailable /proc/meminfo; true', 4000)
    d.adb('shell', 'echo record > %s/gui-cmd' % G)
    t_rec = time.monotonic()
    time.sleep(5)
    window = max(10, secs - 15)
    d.fq(f, 'sh /data/local/tmp/tsnap.sh %d %s 2>/dev/null; true' % (window, SNAP), window * 1000 + 10000)
    mid = status(f)
    time.sleep(max(0.0, secs - (time.monotonic() - t_rec)))
    d.adb('shell', 'echo stoprec > %s/gui-cmd' % G)
    end = time.monotonic() + 40
    while status(f).get('state') != 'idle' and time.monotonic() < end:
        time.sleep(1)
    print('mid-clip: %s | seen %s written %s dropped %s' % (mem.strip(), mid.get('seen'), mid.get('written'),
                                                            mid.get('dropped')))
    for x in 'ab':
        d.adb('pull', '%s.%s' % (SNAP, x), '/tmp/ts.%s' % x)
    print(subprocess.run([sys.executable, str(RX / 'tsnap.py'), '/tmp/ts.a', '/tmp/ts.b', str(window)],
                         capture_output=True, text=True).stdout)
    newest = d.fq(f, 'ls -t /mnt/media_rw/ssd/X2V_RAW | head -n 1; true', 4000).split()[-1]
    print('clip', newest)
    print(d.fq(f, 'cat /mnt/media_rw/ssd/X2V_RAW/%s/clip.json; true' % newest, 4000))
    print(d.fq(f, "grep -a -E 'X2V_RESIDENT (awb|dng_start|clip_end|dng_trace)' %s/video/service.log | tail -n 4; true" % G, 6000))
