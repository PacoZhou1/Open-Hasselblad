#!/usr/bin/env python3
"""Product-path checks after a boot, all through the GUI's command file:
   storage  a clip stops itself near a full drive and is saved; no clip starts without room
   codecs   a short clip in each of H.264, ProRes RAW and DNG, then back to the starting codec
   product_checks.py storage|codecs [...]"""
import json, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'rx-prr-resident'))
import device_test as d  # noqa: E402

G = d.BB
CLIPS = '/mnt/media_rw/ssd/X2V_RAW'
OUT = HERE / 'evidence' / 'checks'
OUT.mkdir(parents=True, exist_ok=True)
PROFILES = {'h264': 0, 'prores_raw': 1, 'dng': 2}
n_cmd = [int(time.time()) % 100000]


def js(f, path):
    # In hex: the factory channel drops characters from a reply holding multibyte text (the
    # Chinese details). The supervisor rewrites its state in place; a torn read is retried.
    for _ in range(5):
        r = d.fq(f, 'od -An -v -tx1 %s 2>/dev/null; true' % path, 6000)
        try:
            s = bytes.fromhex(''.join(r.split())).decode()
            return json.loads(s) if s else {}
        except ValueError:
            time.sleep(0.3)
    return {}


def sup(f):
    return js(f, '/tmp/x2v-product/state.json')


def gui(cmd):
    d.adb('shell', 'echo %s > %s/gui-cmd' % (cmd, G))


def shot(name):
    n_cmd[0] += 1
    before = d.adb('shell', 'stat -c %%Y %s/prr-gui-cmd.png 2>/dev/null; true' % G).strip()
    gui('shot%d' % n_cmd[0])
    for _ in range(20):
        time.sleep(0.3)
        if d.adb('shell', 'stat -c %%Y %s/prr-gui-cmd.png 2>/dev/null; true' % G).strip() != before:
            break
    time.sleep(0.6)
    d.adb('pull', '%s/prr-gui-cmd.png' % G, str(OUT / ('%s.png' % name)))
    return OUT / ('%s.png' % name)


def wait(f, ok, timeout, what):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        p = sup(f)
        if ok(p):
            return p
        time.sleep(0.5)
    raise SystemExit('timeout waiting for %s: %s' % (what, sup(f)))


def free_mb(f):
    a, s = d.fq(f, "stat -f -c '%%a %%S' %s; true" % CLIPS, 4000).split()[-2:]
    return int(a) * int(s) // (1 << 20)


def newest(f):
    c = d.fq(f, 'ls -t %s | head -n 1; true' % CLIPS, 4000).split()[-1]
    return c, js(f, '%s/%s/clip.json' % (CLIPS, c))


def in_catalog(f, clip):
    return clip in d.fq(f, 'grep -o %s %s/rec/catalog.json | head -n 1; true' % (clip, G), 4000)


def lease():
    d.adb('shell', 'echo $(( $(date +%%s) + 1800 )) > %s/keepawake.lease' % G)


def set_codec(f, codec):
    if sup(f).get('codec') == codec:
        return
    n_cmd[0] += 1
    gui('codec%d-%d' % (n_cmd[0], PROFILES[codec]))
    wait(f, lambda p: p.get('codec') == codec and p.get('phase') in ('idle', 'saved'), 15, 'codec ' + codec)


def storage(f):
    set_codec(f, 'dng')
    free = free_mb(f)
    # Stop once about 6 GB more is written: some 14 s of DNG.
    d.fq(f, 'echo %d 1000 > %s/product/storage_mb' % (free - 6000, G), 4000)
    try:
        gui('record')
        wait(f, lambda p: p.get('phase') == 'recording', 15, 'recording')
        t0 = time.monotonic()
        p = wait(f, lambda p: p.get('phase') in ('saved', 'idle') and p.get('detail'), 90, 'auto stop')
        took = time.monotonic() - t0
        print('auto stop after %.1fs: phase=%s detail=%s' % (took, p.get('phase'), p.get('detail')))
        img = shot('storage_auto_stop')
        clip, j = newest(f)
        print('  clip %s frames=%s dropped=%s lost=%s error=%s in_catalog=%s free_mb=%d' % (
            clip, j.get('frames'), j.get('dropped'), j.get('lost'), j.get('error'), in_catalog(f, clip), free_mb(f)))
        print('  screen', img)
        gui('stoprec')
        # Now no room to start at all.
        d.fq(f, 'echo 1000 %d > %s/product/storage_mb' % (free + 100000, G), 4000)
        gui('record')
        time.sleep(2.5)
        p, s = sup(f), js(f, '/tmp/x2v-live/status.json')
        print('start without room: phase=%s detail=%s resident=%s' % (p.get('phase'), p.get('detail'), s.get('state')))
        print('  screen', shot('storage_start_refused'))
        print(d.fq(f, "grep -E 'storage_full|start_refused' %s/product/supervisor.log | tail -n 3; true" % G, 4000))
    finally:
        d.fq(f, 'rm -f %s/product/storage_mb; true' % G, 4000)
        gui('stoprec')


def codecs(f):
    start = sup(f).get('codec')
    for codec in ('h264', 'prores_raw', 'dng'):
        set_codec(f, codec)
        gui('record')
        wait(f, lambda p: p.get('phase') == 'recording', 15, 'recording')
        time.sleep(12)
        gui('stoprec')
        wait(f, lambda p: p.get('phase') in ('saved', 'idle'), 60, 'saved')
        clip, j = newest(f)
        print('%-10s %s frames=%s dropped=%s error=%s proxy=%s in_catalog=%s' % (
            codec, clip, j.get('frames'), j.get('dropped'), j.get('error'), j.get('proxy_frames', '-'),
            in_catalog(f, clip)))
    set_codec(f, start)
    print('back to', sup(f).get('codec'))


lease()
with d.connect() as f:
    for name in sys.argv[1:] or ['storage', 'codecs']:
        print('==', name, flush=True)
        globals()[name](f)
