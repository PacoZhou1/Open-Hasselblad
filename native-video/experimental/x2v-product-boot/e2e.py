#!/usr/bin/env python3
"""Drive the on-camera product through the GUI's own command hook (as a user would through the
GUI): video mode, shutter start/stop, gallery playback, photo mode. Reads the supervisor's state."""
import json, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'rx-prr-resident'))
import device_test as d  # noqa: E402

BB = '/blackbox/x2v-native-20261011'
EV = HERE / 'evidence'
EV.mkdir(exist_ok=True)
n = [0]


def gui(cmd):
    d.adb('shell', f'echo {cmd} > {BB}/gui-cmd')


def state(f):
    try:
        return json.loads(d.fq(f, 'cat /tmp/x2v-product/state.json', 6000))
    except Exception as e:
        return {'error': str(e)[:120]}


def wait(f, pred, secs, label):
    end = time.time() + secs
    while time.time() < end:
        s = state(f)
        if pred(s):
            print(f'{label}: {s}', flush=True)
            return s
        time.sleep(0.5)
    raise SystemExit(f'{label} timeout: {state(f)}')


def shot(f, name):
    # The GUI ignores a repeat of the previous command, so separate shots with a harmless one.
    gui('home')
    time.sleep(0.5)
    gui('shot')
    time.sleep(1.5)
    d.fq(f, f'cp {BB}/prr-gui-cmd.png {BB}/video/{name}.png; chmod 644 {BB}/video/{name}.png', 6000)
    d.adb('pull', f'{BB}/video/{name}.png', str(EV / f'{name}.png'))


def main(seconds):
    with d.connect() as f:
        print('start', state(f), flush=True)
        t0 = time.time()
        gui('video')
        wait(f, lambda s: s.get('session') == 'up' and s.get('backend_ready'), 60, 'video_ready')
        print(f'enter {time.time() - t0:.1f}s', flush=True)
        time.sleep(2)
        shot(f, 'e2e-video-idle')
        gui('shutter1')
        wait(f, lambda s: s.get('phase') == 'recording', 20, 'recording')
        time.sleep(seconds / 2)
        shot(f, 'e2e-recording')
        time.sleep(seconds / 2)
        gui('shutter2')
        s = wait(f, lambda s: s.get('phase') == 'saved', 60, 'saved')
        print(d.fq(f, 'ls -t /mnt/media_rw/ssd/X2V_RAW|head -1|while read c;do cat /mnt/media_rw/ssd/X2V_RAW/$c/clip.json;ls -l /mnt/media_rw/ssd/X2V_RAW/$c;done', 8000), flush=True)
        print(d.fq(f, f'head -c 600 {BB}/rec/catalog.json', 6000), flush=True)
        gui('gallery')
        time.sleep(2.5)
        d.fq(f, f'cp {BB}/prr-gui-gallery.png {BB}/video/e2e-gallery.png; chmod 644 {BB}/video/e2e-gallery.png', 6000)
        d.adb('pull', f'{BB}/video/e2e-gallery.png', str(EV / 'e2e-gallery.png'))
        gui('play')
        time.sleep(4)
        d.fq(f, f'cp {BB}/prr-gui-player.png {BB}/video/e2e-player.png; chmod 644 {BB}/video/e2e-player.png', 6000)
        d.adb('pull', f'{BB}/video/e2e-player.png', str(EV / 'e2e-player.png'))
        print(d.fq(f, f'tail -n 5 {BB}/product/play.log', 6000), flush=True)
        gui('home')
        time.sleep(1)
        t0 = time.time()
        gui('photo')
        wait(f, lambda s: s.get('session') == 'down' and s.get('phase') != 'exiting' and s.get('mode') == 'photo', 60, 'photo')
        print(f'exit {time.time() - t0:.1f}s', flush=True)
        print(d.fq(f, f'tail -n 25 {BB}/product/supervisor.log', 6000), flush=True)
        print(d.fq(f, 'odindb-send -s camera -p live_view_state,stream_group; odindb-send -s error -p active_error', 6000))


if __name__ == '__main__':
    main(float(sys.argv[1]) if len(sys.argv) > 1 else 10)
