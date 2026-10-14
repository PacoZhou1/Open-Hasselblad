#!/usr/bin/env python3
"""Video-mode viewfinder liveness on the product GUI: receiver preview rate and on-screen change
per scenario (idle, half-press, recording, after stop).
usage: vf_scenarios.py <outdir>"""
import json
import sys
import time
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[2] / 'native-video/experimental/rx-prr-resident'))
import device_test as d  # noqa: E402

G = '/blackbox/x2v-native-20261011'
OUT = Path(sys.argv[1] if len(sys.argv) > 1 else HERE / 'evidence/vf/scenarios')
OUT.mkdir(parents=True, exist_ok=True)
shots = 0


def state(f):
    # Either file can be caught mid-write; a later read gets a whole one.
    for _ in range(5):
        r = d.fq(f, 'cat /proc/uptime; cat /tmp/x2v-product/state.json; echo; cat /tmp/x2v-live/status.json', 6000)
        try:
            t, prod, rx = r.split(None, 1)[0], *[json.loads(l) for l in r.splitlines()[1:] if l.startswith('{')][:2]
            return float(t), {**prod, 'rx': rx}
        except ValueError:
            time.sleep(0.3)
    raise RuntimeError('state unreadable: %r' % r[:300])


def stamp():
    return d.adb('shell', 'stat -c "%%Y %%s" %s/prr-gui-cmd.png 2>/dev/null; true' % G).strip()


def shot(name):
    global shots
    shots += 1
    before = stamp()
    d.adb('shell', 'echo shot > %s/gui-cmd' % G)
    end, last = time.monotonic() + 6, None
    while time.monotonic() < end:
        time.sleep(0.3)
        s = stamp()
        if s and s != before and s == last:
            break
        last = s
    p = OUT / ('%s.png' % name)
    d.adb('pull', '%s/prr-gui-cmd.png' % G, str(p))
    d.adb('shell', 'echo n%d > %s/gui-cmd' % (shots, G))
    time.sleep(0.5)
    return np.asarray(Image.open(p).convert('RGB')).astype(int)[60:640]


def phase(f, name, seconds, action=None):
    t0, s0 = state(f)
    a = shot(name + '_a')
    if action:
        action(f)
    time.sleep(max(0, seconds - 2))
    b = shot(name + '_b')
    t1, s1 = state(f)
    changed = (np.abs(a - b).sum(2) > 6).mean() * 100
    rate = (s1['preview_gen'] - s0['preview_gen']) / (t1 - t0)
    r0, r1 = s0['rx'], s1['rx']
    print('%-12s preview %.1f Hz  screen changed %.1f%%  phase=%s session=%s rx=%s seen=%s written=%s absorbed=%s'
          % (name, rate, changed, s1['phase'], s1['session'], r1.get('state'), r1.get('seen'), r1.get('written'),
             r1.get('guard_absorbed')), flush=True)
    return r0, r1


def gui(cmd):
    return lambda f: d.adb('shell', 'echo %s > %s/gui-cmd' % (cmd, G))


def key(k, ms):
    return lambda f: d.fq(f, '(inject-keypress -k %s -t %d >/dev/null 2>&1 &); echo ok' % (k, ms), 4000)


def shutter(f):
    # A real press: half press held, full press inside it.
    d.fq(f, '(inject-keypress -k HalfPress -t 1200 >/dev/null 2>&1 &); sleep 0.4; '
            '(inject-keypress -k FullPress -t 300 >/dev/null 2>&1 &); echo ok', 4000)


with d.connect() as f:
    d.lease()
    phase(f, 'idle', 8)
    phase(f, 'halfpress', 6, key('HalfPress', 3000))
    phase(f, 'shutter_rec', 12, shutter)
    phase(f, 'shutter_stop', 6, shutter)
    phase(f, 'gui_rec', 10, gui('record'))
    phase(f, 'gui_stop', 6, gui('stoprec'))
    phase(f, 'after', 8)
