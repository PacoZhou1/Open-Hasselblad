#!/usr/bin/env python3
"""Product acceptance through the user's own paths. Keys go in at the body-button input device
(the MCU's, which both the GUI and camera-service read) and touches at the touchscreen's, and
every verdict is read from what the screen shows: the GUI's telemetry (gui-state.json: badge,
notice, gallery, stock screen, its timestamped events) and its screenshots, never from the
back end's own idea of how it went. Latencies are the GUI's own timestamps, not this script's
polling.
   accept.py [boot] [record [codec ...]] [play] [keys] [viewfinder] | all
Each check prints PASS/FAIL with its numbers; evidence lands in evidence/accept/<run>/."""
import json, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE.parent / 'rx-prr-resident'))
sys.path.insert(0, str(HERE / 'exp/isp'))
import device_test as d  # noqa: E402
from pdlines import read_dng, pd_row_residual  # noqa: E402

G = d.BB
DEV = G + '/accept/accept_dev.sh'
RUN = time.strftime('%Y%m%d-%H%M%S')
OUT = HERE / 'evidence' / 'accept' / RUN
OUT.mkdir(parents=True, exist_ok=True)
MCU = '/dev/input/event0'                     # exmcu_input: the body buttons
GUI_BUTTONS = '/dev/input/event3'             # gui_buttons: F1 F2 F4 F5
EVDEV = {'Q': 16, 'W': 17, 'E': 18, 'R': 19, 'T': 20, 'Y': 21, 'U': 22, 'I': 23, 'O': 24, 'P': 25, 'A': 30, 'S': 31,
         'D': 32, 'F': 33, 'G': 34, 'H': 35, 'J': 36, 'K': 37, 'L': 38, 'Z': 44, 'X': 45, 'C': 46, 'V': 47, 'B': 48,
         'N': 49, 'M': 50}
QT_F = {0x01000030 + i: 59 + i for i in range(10)}   # Qt Key_F1.. -> KEY_F1..
PROFILES = {'h264': 0, 'prores_raw': 1, 'dng': 2}
PREFIX = {'h264': 'h264', 'prores_raw': 'raw', 'dng': 'dng'}
BAD_BADGES = ('录制状态失联', '停止未确认，请重试', '录制失败')
def fq(f, cmd, ms):
    """A factory-channel command, retried: the channel now and then misses a reply."""
    for i in range(4):
        try:
            return d.fq(f, cmd, ms)
        except Exception:
            if i == 3:
                raise
            time.sleep(1.5)


results = []
n_cmd = [int(time.time()) % 100000]


def verdict(name, ok, env=False, **facts):
    """`env`: failed because of the test bench, not the product (the "USB connected" prompt of the
    cable these checks need). Listed, not counted."""
    level = 'PASS' if ok else 'ENV' if env else 'FAIL'
    results.append({'check': name, 'pass': bool(ok) or env, 'level': level, **facts})
    print('%s %s %s' % (level, name, json.dumps(facts, ensure_ascii=False)), flush=True)
    return ok


def hexjson(f, path):
    # In hex: the factory channel drops characters from replies holding multibyte text.
    for _ in range(6):
        r = fq(f, 'od -An -v -tx1 %s 2>/dev/null; true' % path, 8000)
        try:
            s = bytes.fromhex(''.join(r.split())).decode()
            return json.loads(s) if s else {}
        except ValueError:
            time.sleep(0.2)
    return {}


def gui(f):
    return hexjson(f, '/tmp/x2v-product/gui-state.json')


def gui_full(f):
    """A telemetry read that holds a whole snapshot (the GUI rewrites the file in place)."""
    for _ in range(10):
        s = gui(f)
        if 't' in s:
            return s
        time.sleep(0.2)
    raise RuntimeError('no telemetry snapshot')


def evdev_for(qt):
    """The input device and code that make the GUI see Qt key `qt`."""
    if 65 <= qt <= 90:
        return MCU, EVDEV[chr(qt)]
    if qt in QT_F:
        return GUI_BUTTONS, QT_F[qt]
    raise KeyError('no body key gives Qt key 0x%x' % qt)


def key(f, qt, hold=0.12):
    dev, code = evdev_for(qt)
    fq(f, 'sh %s key %s %d %.2f; true' % (DEV, dev, code, hold), 6000)


def tap(f, x, y, hold=0.08):
    fq(f, 'sh %s tap %d %d %.2f; true' % (DEV, x, y, hold), 6000)


def gui_cmd(cmd):
    d.adb('shell', 'echo %s > %s/gui-cmd' % (cmd, G))


def png_whole(p):
    try:
        from PIL import Image
        with Image.open(p) as im:
            im.load()
        return True
    except Exception:
        return False


def shot(f, name):
    """The GUI's own grab of what it draws, as a BMP (a PNG compressed on its thread stalled the
    GUI for a second). It writes the file in place: wait for a new one whose size has stopped
    changing, and check it decodes whole; kept as PNG here."""
    from PIL import Image
    n_cmd[0] += 1
    src = '%s/prr-gui-cmd.bmp' % G
    stat = 'stat -c "%%Y %%s" %s 2>/dev/null; true' % src
    before = fq(f, stat, 4000).strip()
    gui_cmd('shot%d' % n_cmd[0])
    raw, p = OUT / ('%s.bmp' % name), OUT / ('%s.png' % name)
    last = before
    for _ in range(40):
        time.sleep(0.3)
        cur = fq(f, stat, 4000).strip()
        if cur and cur != before and cur == last:
            d.adb('pull', src, str(raw))
            if png_whole(raw):
                with Image.open(raw) as im:
                    im.convert('RGB').save(p)
                raw.unlink()
                return p
        last = cur
    raise RuntimeError('no whole screenshot for ' + name)


def wait_gui(f, ok, timeout, what):
    end = time.monotonic() + timeout
    s = {}
    while time.monotonic() < end:
        s = gui(f)
        if s and ok(s):
            return s
        time.sleep(0.25)
    raise TimeoutError('%s: %s' % (what, {k: s.get(k) for k in ('badge', 'phase', 'fresh', 'notice', 'gallery', 'stock')}))


def device_ms(f):
    # The device shell's arithmetic is 32-bit.
    return int(fq(f, 'date +%s%N; true', 4000).split()[-1]) // 1000000


def events_since(s, t0_ms):
    return [e for e in s.get('events', []) if e.get('t', 0) >= t0_ms]


def settled(events, kind='badge', field='text', min_ms=50):
    """The values that stayed up at least `min_ms`: a binding's in-between value is never drawn."""
    seq = [(e['t'], e['d'].get(field)) for e in events if e['e'] == kind]
    out = []
    for i, (t, v) in enumerate(seq):
        nxt = seq[i + 1][0] if i + 1 < len(seq) else t + min_ms
        if nxt - t >= min_ms and (not out or out[-1][1] != v):
            out.append((t, v))
    return out


def first_at(events, kind, pred):
    return next((e['t'] for e in events if e['e'] == kind and pred(e['d'])), None)


def keymap(f):
    s = gui(f)
    m = next((e['d'] for e in s.get('events', []) if e['e'] == 'keymap'), None)
    if m is None:
        p = OUT.parent / 'keymap.json'
        m = json.loads(p.read_text()) if p.exists() else {}
    else:
        (OUT.parent / 'keymap.json').write_text(json.dumps(m))
    return m


def set_codec(f, codec):
    if gui(f).get('profile', '').startswith(PREFIX[codec]):
        return
    n_cmd[0] += 1
    gui_cmd('codec%d-%d' % (n_cmd[0], PROFILES[codec]))
    wait_gui(f, lambda s: s.get('profile', '').startswith(PREFIX[codec]) and s.get('phase') in ('idle', 'saved'),
             15, 'codec ' + codec)


def forwarded(f):
    """Full presses camera-service forwarded to the GUI and shutter_gate.c counted: the path the
    physical shutter takes (it is not a key on the body-button device)."""
    r = fq(f, "tail -c 4000000 %s/video/service.log | grep -ac 'shutter press=.*forwarded'; true" % G, 30000)
    try:
        return int(r.split()[-1])
    except (ValueError, IndexError):
        return -1


def native(f):
    """Full presses the state machine's entry turned into a count (shutter_gate.c): the way the
    physical shutter comes, whatever the key override."""
    # The press's own number, not a count of lines: the log is trimmed while the service runs.
    r = fq(f, "grep -ao 'shutter press=[0-9]* (native)' %s/video/service.log | tail -n 1; true" % G, 30000)
    try:
        return int(r.split('=')[1].split()[0])
    except (ValueError, IndexError):
        return 0


def catalog(f):
    return hexjson(f, '%s/rec/catalog.json' % G).get('clips', [])


def lease():
    d.adb('shell', 'echo $(( $(date +%%s) + 1800 )) > %s/keepawake.lease' % G)


def setup():
    lease()
    d.adb('shell', 'mkdir -p %s/accept' % G)
    subprocess.run(['adb', '-s', d.SERIAL, 'push', str(HERE / 'accept_dev.sh'), DEV], check=True, capture_output=True)


def video_ready(f):
    """Video idle on the stock viewfinder screen. With the cable in, the "USB connected" prompt
    can be up: a half press puts it away, as a user would, without choosing any of its options."""
    s = wait_gui(f, lambda s: s.get('session') == 'up' and s.get('phase') in ('idle', 'saved'), 60, 'video idle')
    for _ in range(3):
        if s.get('stock') == 'liveview':
            return s
        key(f, (keymap(f).get('E_Button_HalfPress') or [65])[0], 0.3)
        time.sleep(1.5)
        s = gui(f)
    verdict('state.stock_liveview_before_test', False, stock=s.get('stock'))
    return s


# ---------------------------------------------------------------- checks

def boot():
    """Reboot and time what the screen shows: the overlay, the "entering" notice, video up, and
    which stock screen it lands on."""
    with d.connect() as f:
        # Not retried: a reply lost after the reboot began would reboot it twice.
        d.fq(f, 'sync; setprop sys.powerctl reboot; echo sent', 4000)
    t0 = time.monotonic()
    time.sleep(40)
    while True:
        try:
            if d.adb('shell', 'echo ok', timeout=10).strip() == 'ok':
                break
        except Exception:
            pass
        subprocess.run([sys.executable, str(ROOT / 'local-verification/camera_access.py'), 'enable-adb'],
                       capture_output=True, timeout=60)
        time.sleep(3)
        if time.monotonic() - t0 > 300:
            return verdict('boot.adb', False)
    setup()
    for _ in range(15):
        try:
            with d.connect() as f:
                fq(f, 'true', 4000)
            break
        except Exception:
            time.sleep(5)
    with d.connect() as f:
        # With the cable in, the "USB connected" prompt is up: the screen must say so, and once a
        # half press puts it away (as a user would, choosing none of its options) video follows.
        prompt_at = None
        try:
            s = wait_gui(f, lambda s: (s.get('session') == 'up' and s.get('phase') in ('idle', 'saved')) or
                         'USB已连接' in (s.get('notice') or ''), 240, 'video up or the USB prompt notice')
            if s.get('session') != 'up':
                verdict('boot.usb_prompt_notice', True, notice=s.get('notice'))
                shot(f, 'boot-usb-prompt')
                prompt_at = device_ms(f)
                key(f, (keymap(f).get('E_Button_HalfPress') or [65])[0], 0.3)
                s = wait_gui(f, lambda s: s.get('session') == 'up' and s.get('phase') in ('idle', 'saved'), 120, 'video up')
        except TimeoutError as e:
            return verdict('boot.video_up', False, error=str(e))
        time.sleep(2)
        s = gui(f)
        now_ms = device_ms(f)
        up = float(fq(f, 'cat /proc/uptime; true', 4000).split()[0])
        boot_ms = now_ms - up * 1000
        sup = fq(f, 'cat %s/product/supervisor.log; true' % G, 6000)
        (OUT / 'boot-supervisor.log').write_text(sup)
        ev = s.get('events', [])
        sec = lambda t: None if t is None else round((t - boot_ms) / 1000, 1)  # noqa: E731
        t_entering = first_at(ev, 'phase', lambda x: x.get('phase') == 'entering')
        t_up = first_at(ev, 'session', lambda x: x.get('session') == 'up')
        ov = next((float(l.split()[0]) for l in sup.splitlines() if 'overlay_start' in l), None)
        verdict('boot.overlay_started', ov is not None and ov < 15, overlay_start_s=ov)
        verdict('boot.entering_shown', t_entering is not None and sec(t_entering) < 25, entering_s=sec(t_entering),
                gui_first_event_s=sec(ev[0]['t']) if ev else None)
        ses = fq(f, 'cat %s/video/session.log; true' % G, 6000).splitlines()
        (OUT / 'boot-session.log').write_text('\n'.join(ses))
        up_s = sec(t_up)
        if prompt_at is None:
            verdict('boot.video_up', up_s is not None and up_s < 32, video_up_s=up_s)
        else:
            after = round((t_up - prompt_at) / 1000, 1) if t_up else None
            verdict('boot.video_up_after_prompt', after is not None and after < 25, after_prompt_s=after, video_up_s=up_s)
        try:
            s = wait_gui(f, lambda s: s.get('stock') == 'liveview', 40, 'stock viewfinder screen')
        except TimeoutError:
            s = gui(f)
        verdict('boot.lands_on_viewfinder', s.get('stock') == 'liveview' and (s.get('ispView') or s.get('pvVisible')),
                env=s.get('stock') == 'usb_connected', stock=s.get('stock'), isp=s.get('ispView'),
                pv=s.get('pvVisible'))
        lines = sup.splitlines()
        hello = next((i for i, l in enumerate(lines) if ' hello ' in l), len(lines))
        slow = [l for l in lines[hello:] if 'loop_slow' in l]
        verdict('boot.loop_never_slow_after_gui', not slow, loop_slow=slow[:5])
        km = keymap(f)
        verdict('boot.keymap_read', 'Play' in km, keymap=km)
        shot(f, 'boot-video-idle')


def clip_quality(f, codec, clip):
    """What the user opens: H.264 / DNG-proxy colour bands, and DNG PD-row lines.
    ProRes RAW has no ISP colour plane; its PD rows are interpolated in the encoder."""
    if not clip:
        return
    folder = '/mnt/media_rw/ssd/X2V_RAW/%s' % clip
    if codec in ('h264', 'dng'):
        mp4 = 'clip.mp4' if codec == 'h264' else 'proxy.mp4'
        fq(f, 'cp %s/%s %s/accept/clip.mp4; chmod a+r %s/accept/clip.mp4; true' % (folder, mp4, G, G), 8000)
        d.adb('pull', '%s/accept/clip.mp4' % G, str(OUT / ('%s.mp4' % codec)))
        ppm = OUT / ('%s-frame.ppm' % codec)
        r = subprocess.run(['ffmpeg', '-y', '-ss', '1', '-i', str(OUT / ('%s.mp4' % codec)),
                            '-vf', 'scale=650:485:flags=neighbor', '-frames:v', '1', str(ppm)],
                           capture_output=True, text=True)
        if r.returncode or not ppm.exists():
            verdict('record.%s.colour_frame' % codec, False, error=(r.stderr or r.stdout)[-200:])
        else:
            score = band_score(ppm)
            verdict('record.%s.no_colour_bands' % codec, score < 1.5, band_score=round(score, 2))
    if codec == 'dng':
        name = fq(f, 'ls %s/*_000010.dng 2>/dev/null; true' % folder, 4000).strip().split()[-1]
        if not name.endswith('.dng'):
            return verdict('record.dng.pd_row', False, error='no frame 10')
        fq(f, 'cp %s %s/accept/frame.dng; chmod a+r %s/accept/frame.dng; true' % (name, G, G), 8000)
        dest = OUT / 'dng-000010.dng'
        d.adb('pull', '%s/accept/frame.dng' % G, str(dest))
        res = pd_row_residual(read_dng(dest)[0])
        verdict('record.dng.pd_row', abs(res['all']) < 0.15 and abs(res['g']) < 0.15 and abs(res['b']) < 0.15,
                **{k: round(v, 3) for k, v in res.items()})


def record(codecs=('h264', 'prores_raw', 'dng'), secs=8):
    """Each codec: full press, record, full press. The badge must settle on REC, then 已保存,
    never on a lost back end; by 已保存 the clip must be first in the gallery's catalog."""
    with d.connect() as f:
        full = keymap(f).get('E_Button_FullPress', [69])[0]
        for codec in codecs:
            set_codec(f, codec)
            video_ready(f)
            fw0, nv0 = forwarded(f), native(f)
            t0 = device_ms(f)
            key(f, full)
            try:
                wait_gui(f, lambda s: (s.get('badge') or '').startswith('REC'), 10, 'REC badge')
            except TimeoutError as e:
                verdict('record.%s.start' % codec, False, error=str(e))
                continue
            # A half press mid-clip (focus, as in stock) must leave the clip recording.
            time.sleep(secs / 2)
            key(f, (keymap(f).get('E_Button_HalfPress') or [65])[0], 0.4)
            time.sleep(1)
            hs = gui(f)
            halfpress_ok = (hs.get('badge') or '').startswith('REC') and hs.get('session') == 'up'
            halfpress_facts = {'badge': hs.get('badge'), 'stock': hs.get('stock')}
            time.sleep(max(0.0, secs / 2 - 1))
            shot(f, 'record-%s-recording' % codec)
            t1 = device_ms(f)
            key(f, full)
            try:
                s = wait_gui(f, lambda s: s.get('badge') == '已保存', 20, 'saved badge')
            except TimeoutError as e:
                verdict('record.%s.saved' % codec, False, error=str(e))
                continue
            cat = catalog(f)
            ev = events_since(s, t0)
            shown = settled(ev)
            texts = [v for _, v in shown]
            press = [e['t'] for e in ev if e['e'] == 'shutter' and not e['d'].get('dup')]
            t_rec = next((t for t, v in shown if (v or '').startswith('REC')), None)
            t_saved = next((t for t, v in shown if v == '已保存' and t > t1), None)
            stop_press = next((p for p in press if p >= t1), None)
            verdict('record.%s.badges' % codec, not any(b in BAD_BADGES for b in texts) and t_rec and t_saved,
                    shown=[v for v in texts if not (v or '').startswith('REC  00:0') or v == 'REC  00:00'])
            verdict('record.%s.shutter_seen' % codec, len(press) >= 2, presses=len(press))
            # Each press counted once, from whichever way it came in.
            counted = [e['d'].get('source') for e in ev if e['e'] == 'shutter' and not e['d'].get('dup')]
            verdict('record.%s.one_toggle_per_press' % codec, len(counted) == 2, sources=counted,
                    forwarded=forwarded(f) - fw0)
            verdict('record.%s.native_entry_saw_both' % codec, native(f) - nv0 == 2, native=native(f) - nv0)
            verdict('record.%s.half_press_kept_recording' % codec, halfpress_ok, **halfpress_facts)
            secs_shown = [int(v[-2:]) + 60 * int(v[-5:-3]) for v in texts if (v or '').startswith('REC  ')]
            skips = [b for a, b in zip(secs_shown, secs_shown[1:]) if b - a != 1]
            verdict('record.%s.clock_steps_by_one' % codec, not skips, shown=secs_shown, skips=skips)
            stills = [e for e in ev if e['e'] == 'stock_state' and e['d'].get('state') == 'exposing']
            verdict('record.%s.no_still_taken' % codec, not stills, stills=len(stills))
            if press and t_rec:
                verdict('record.%s.start_ms' % codec, t_rec - press[0] < 2500, ms=t_rec - press[0])
            if stop_press and t_saved:
                verdict('record.%s.stop_ms' % codec, t_saved - stop_press < 3000, ms=t_saved - stop_press)
            clip = cat[0]['id'] if cat else None
            verdict('record.%s.first_in_gallery_at_saved' % codec,
                    bool(clip) and clip.startswith('X2V_' + {'h264': 'H264', 'prores_raw': 'PRR', 'dng': 'DNG'}[codec]),
                    clip=clip)
            j = hexjson(f, '/mnt/media_rw/ssd/X2V_RAW/%s/clip.json' % clip) if clip else {}
            verdict('record.%s.frames' % codec, j.get('dropped') == 0 and j.get('lost') == 0 and
                    j.get('frames', 0) >= (secs - 1) * 24, frames=j.get('frames'), dropped=j.get('dropped'),
                    lost=j.get('lost'))
            clip_quality(f, codec, clip)
            shot(f, 'record-%s-saved' % codec)


def play():
    """Playback in video mode opens the video gallery, newest first; a tap on it plays it; Playback
    again closes the gallery."""
    with d.connect() as f:
        km = keymap(f)
        if 'Play' not in km:
            return verdict('play.key_known', False, keymap=km)
        pk = km['Play'][0]
        video_ready(f)
        newest = (catalog(f) or [{}])[0].get('id')
        t0 = device_ms(f)
        key(f, pk)
        try:
            s = wait_gui(f, lambda s: s.get('gallery'), 4, 'gallery open')
        except TimeoutError as e:
            s = gui(f)
            ev = [e for e in events_since(s, t0) if e['e'] in ('toggle_screen', 'stock_state', 'gallery')]
            return verdict('play.opens_gallery', False, error=str(e), events=ev)
        verdict('play.opens_gallery', True, ms=first_at(events_since(s, t0), 'gallery', lambda x: x.get('visible')) - t0,
                stock=s.get('stock'))
        verdict('play.newest_first', s.get('firstClip') == newest, first=s.get('firstClip'), newest=newest,
                clips=s.get('clips'))
        shot(f, 'play-gallery')
        # VideoGallery: a 90 px header, the grid 18 px in, cells 329 x 276; the first one's centre.
        tap(f, 182, 246)
        try:
            s = wait_gui(f, lambda s: s.get('playing'), 6, 'playing')
            verdict('play.tap_plays', True)
            time.sleep(2)
            shot(f, 'play-playing')
        except TimeoutError as e:
            verdict('play.tap_plays', False, error=str(e))
        key(f, pk)
        time.sleep(1)
        key(f, pk) if gui(f).get('gallery') else None
        try:
            wait_gui(f, lambda s: not s.get('gallery'), 4, 'gallery closed')
            verdict('play.closes_with_playback', True)
        except TimeoutError as e:
            verdict('play.closes_with_playback', False, error=str(e))
            gui_cmd('home')


def keys():
    """The stock readouts the body keys change are on screen in video mode: ISO/WB opens its
    page over the viewfinder, and the shutter's half press brings the viewfinder back."""
    with d.connect() as f:
        km = keymap(f)
        video_ready(f)
        # From the viewfinder screen, as a half press leaves it.
        key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
        wait_gui(f, lambda s: s.get('stock') == 'liveview', 5, 'viewfinder screen')
        before = shot(f, 'keys-before')
        iso = (km.get('E_Button_IsoWb') or [None])[0]
        if iso is None:
            return verdict('keys.isowb_known', False, keymap=km)
        t0 = device_ms(f)
        key(f, iso)
        time.sleep(1.2)
        s = gui(f)
        after = shot(f, 'keys-isowb')
        ev = [e for e in events_since(s, t0) if e['e'] in ('stock_state', 'toggle_screen')]
        # Over the viewfinder the stock ISO/WB selector is a list down the right edge, its current
        # value on the stock orange: found by that colour, which no viewfinder picture is made of.
        box = (850, 80, 1024, 660)
        o0, o1 = orange_share(before, box), orange_share(after, box)
        verdict('keys.isowb_selector_shown', o1 > 0.02 and o0 < 0.005, orange_before=round(o0, 4), orange_after=round(o1, 4),
                stock=s.get('stock'), events=ev)
        # From a stock page the shutter records, and takes no still (a still stalls the session).
        full = (km.get('E_Button_FullPress') or [69])[0]
        t0 = device_ms(f)
        key(f, full)
        try:
            wait_gui(f, lambda s: (s.get('badge') or '').startswith('REC'), 8, 'REC from a stock page')
            time.sleep(3)
            key(f, full)
            s = wait_gui(f, lambda s: s.get('badge') == '已保存', 20, 'saved')
            stills = [e for e in events_since(s, t0) if e['e'] == 'stock_state' and e['d'].get('state') == 'exposing']
            verdict('keys.shutter_on_stock_page_records', not stills, stills=len(stills))
        except TimeoutError as e:
            s = gui(f)
            verdict('keys.shutter_on_stock_page_records', False, error=str(e),
                    events=[x for x in events_since(s, t0) if x['e'] in ('stock_state', 'shutter', 'badge')][:12])
        key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
        try:
            wait_gui(f, lambda s: s.get('stock') == 'liveview', 4, 'back to liveview')
            verdict('keys.half_press_back_to_viewfinder', True)
        except TimeoutError as e:
            verdict('keys.half_press_back_to_viewfinder', False, error=str(e))
        # From the stock menu, as in photo mode: the half press is the service's, and it is back
        # in live view.
        s = gui(f)
        verdict('keys.native_shutter_override_none', s.get('nativeShutter') and s.get('keyOverride') == 0,
                nativeShutter=s.get('nativeShutter'), keyOverride=s.get('keyOverride'),
                service=fq(f, 'odindb-send -s camera -p forward_input_events 2>&1; true', 6000).strip())
        menu = (km.get('Menu') or [0x01000030])[0]
        key(f, menu)
        try:
            s = wait_gui(f, lambda s: s.get('stock') not in ('liveview', None), 4, 'stock menu')
            shot(f, 'keys-menu')
            key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
            wait_gui(f, lambda s: s.get('stock') == 'liveview', 4, 'back to liveview from the menu')
            verdict('keys.half_press_from_menu_to_viewfinder', True, menu_state=s.get('stock'))
        except TimeoutError as e:
            verdict('keys.half_press_from_menu_to_viewfinder', False, error=str(e))
            key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
        gate = fq(f, 'cat /tmp/x2v-live/fullpress 2>/dev/null; true', 4000).strip()
        verdict('keys.fullpress_gate', gate == '1', fullpress=gate)
        # A leftover still request on this graph hangs until the battery comes out. The
        # capture method is answered or absorbed; the session and half-press must stay.
        t0 = device_ms(f)
        cap = fq(f, 'timeout 5 odindb-send -s camera -m capture 2>&1; echo rc=$?; true', 8000).strip()
        time.sleep(2)
        s = gui(f)
        stills = [e for e in events_since(s, t0) if e['e'] in ('still_blocked', 'stock_state')]
        up = s.get('session') == 'up'
        verdict('keys.still_does_not_hang', up and s.get('stock') != 'exposing',
                session=s.get('session'), stock=s.get('stock'), capture=cap[-80:], events=stills[:8])
        key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
        try:
            wait_gui(f, lambda s: s.get('session') == 'up' and s.get('stock') == 'liveview', 6,
                     'preview after a still attempt')
            verdict('keys.half_press_after_still', True)
        except TimeoutError as e:
            verdict('keys.half_press_after_still', False, error=str(e))
        sup = fq(f, "grep -c session_lost %s/product/supervisor.log; true" % G, 4000).strip()
        verdict('keys.session_never_lost', sup == '0', session_lost=sup)


def image_diff(a, b, box=None):
    """Share of pixels whose brightness changed by more than 40, in `box` (l, t, r, b) or all."""
    from PIL import Image, ImageChops
    with Image.open(a) as x, Image.open(b) as y:
        x, y = x.convert('L'), y.convert('L')
        if box:
            x, y = x.crop(box), y.crop(box)
        h = ImageChops.difference(x, y).point(lambda v: 255 if v > 40 else 0).histogram()
        return h[255] / float(x.size[0] * x.size[1])


def orange_share(png, box):
    """Share of pixels in `box` near the stock highlight orange (about 209, 81, 40); the record
    button's red (229, 51, 45) is not it."""
    from PIL import Image
    with Image.open(png) as im:
        px = list(im.convert('RGB').crop(box).getdata())
    hit = sum(1 for r, g, b in px if r > 170 and 62 < g < 110 and b < 70 and r - g > 90)
    return hit / float(len(px))


def photo():
    """Video mode off: the stock camera is back as it was. Its viewfinder screen, no session, the
    resident viewfinder hidden, and Playback is the stock photo browser, not the video gallery.
    No still is taken: it would land on the user's card. Then video mode on again."""
    with d.connect() as f:
        km = keymap(f)
        video_ready(f)
        gui_cmd('photo')
        try:
            s = wait_gui(f, lambda s: s.get('mode') == 'photo' and s.get('session') == 'down' and
                         s.get('stock') == 'liveview', 45, 'photo mode')
            verdict('photo.back_to_stock', not s.get('pvVisible'), stock=s.get('stock'), pv=s.get('pvVisible'))
            shot(f, 'photo-liveview')
            t0 = device_ms(f)
            key(f, km['Play'][0])
            time.sleep(1.5)
            s = gui(f)
            verdict('photo.playback_is_stock_browser', s.get('stock') == 'browse_view' and not s.get('gallery'),
                    stock=s.get('stock'), gallery=s.get('gallery'),
                    events=[e for e in events_since(s, t0) if e['e'] in ('toggle_screen', 'gallery')])
            shot(f, 'photo-browser')
            # The stock browser leaves on a half press; Playback again does nothing there (stock:
            # its browse state has no transition for it, and our hook passes it on unchanged).
            key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
            wait_gui(f, lambda s: s.get('stock') == 'liveview', 6, 'photo viewfinder')
            verdict('photo.half_press_leaves_browser', True)
        except TimeoutError as e:
            verdict('photo.back_to_stock', False, error=str(e))
        finally:
            gui_cmd('video')
        try:
            s = wait_gui(f, lambda s: s.get('session') == 'up' and s.get('phase') in ('idle', 'saved'), 60, 'video again')
            verdict('photo.video_again', True)
        except TimeoutError as e:
            verdict('photo.video_again', False, error=str(e))


def band_score(ppm):
    """Where the ISP colour port had its bands (rows 24 + 48k and 40 + 48k at this height): the
    step in mean (B - G) across those rows over the step across all other rows. ~1 is clean."""
    b = ppm.read_bytes()
    parts = b.split(b'\n', 3)
    w, h = map(int, parts[1].split())
    px = parts[3]
    bg = [sum(px[(y * w + x) * 3 + 2] - px[(y * w + x) * 3 + 1] for x in range(0, w, 2)) / (w / 2) for y in range(h)]
    step = [abs(bg[y + 1] - bg[y]) for y in range(h - 1)]
    edges = {y for k in range(11) for y in (24 + 48 * k - 1, 40 + 48 * k - 1) if 0 <= y < h - 1}
    on = [step[y] for y in edges]
    off = [step[y] for y in range(h - 1) if y not in edges]
    return (sum(on) / len(on)) / max(1e-6, sum(off) / len(off))


def nv12_half_ppm(nv12, dest, w=1300, h=970, stride=1536):
    """BT.709 2x2, as pv_bands.h: the ISP colour port at the half size band_score expects."""
    y = nv12
    c0 = stride * h
    ow, oh = w // 2, h // 2
    out = bytearray(ow * oh * 3)
    for j in range(oh):
        y0 = j * 2 * stride
        y1 = y0 + stride
        c = c0 + j * stride
        o = j * ow * 3
        for i in range(ow):
            Y = ((y[y0 + 2 * i] + y[y0 + 2 * i + 1] + y[y1 + 2 * i] + y[y1 + 2 * i + 1] + 2) >> 2) - 16
            U = y[c + 2 * i] - 128
            V = y[c + 2 * i + 1] - 128
            l = 298 * (0 if Y < 0 else Y)
            def clamp(v):
                return 0 if v < 0 else 255 if v > 255 else v
            out[o + 3 * i] = clamp((l + 459 * V + 128) >> 8)
            out[o + 3 * i + 1] = clamp((l - 55 * U - 136 * V + 128) >> 8)
            out[o + 3 * i + 2] = clamp((l + 541 * U + 128) >> 8)
    dest.write_bytes(b'P6\n%d %d\n255\n' % (ow, oh) + bytes(out))


def viewfinder(secs=5):
    """Frames the display path shows per second, its CPU and the service's, idle and while
    recording DNG, and the band score of the picture. ISP view counts colour frames the
    hook sees (the plane is the ISP's); raw view counts frames the GUI put on screen."""
    with d.connect() as f:
        video_ready(f)
        pids = fq(f, 'echo $(pidof camera-gui) $(pidof camera-service); true', 4000).split()

        def measure(tag):
            """Frames the path put on screen and frames the resident wrote, per second."""
            a, ra = gui_full(f), hexjson(f, '/tmp/x2v-live/status.json')
            c0 = dict(l.split() for l in fq(f, 'sh %s cpu %s; true' % (DEV, ' '.join(pids)), 4000).splitlines())
            t = time.monotonic()
            time.sleep(secs)
            b, rb = gui_full(f), hexjson(f, '/tmp/x2v-live/status.json')
            c1 = dict(l.split() for l in fq(f, 'sh %s cpu %s; true' % (DEV, ' '.join(pids)), 4000).splitlines())
            dt = time.monotonic() - t
            isp = bool(b.get('ispView') or rb.get('isp_view'))
            if isp:
                shown = (int(rb.get('preview_seen') or 0) - int(ra.get('preview_seen') or 0)) / dt
            else:
                shown = (int(b.get('pvShown') or 0) - int(a.get('pvShown') or 0)) / ((b['t'] - a['t']) / 1000.0)
            made = (int(rb.get('preview_gen') or 0) - int(ra.get('preview_gen') or 0)) / dt
            cpu = {n: round((int(c1[p]) - int(c0[p])) / dt, 1) for n, p in zip(('gui_pct', 'service_pct'), pids)}
            # Recording, the viewfinder yields the CPU to the recorder (nice 10): 0 drops come first.
            verdict('viewfinder.%s.fps' % tag, shown >= (11 if tag.startswith('recording') else 18),
                    shown_fps=round(shown, 1), written_fps=round(made, 1), isp_view=isp,
                    colour_fix_us=rb.get('colour_fix_us'), **cpu)
            return shown

        measure('idle')
        s = gui_full(f)
        if s.get('ispView'):
            n_cmd[0] += 1
            fq(f, 'echo %d cdump > /tmp/x2v-live/command; true' % n_cmd[0], 4000)
            time.sleep(0.8)
            fq(f, 'cp /tmp/x2v-live/colour_a.nv12 %s/accept/pv.nv12; chmod a+r %s/accept/pv.nv12; true' % (G, G), 6000)
            d.adb('pull', '%s/accept/pv.nv12' % G, str(OUT / 'viewfinder.nv12'))
            nv12_half_ppm((OUT / 'viewfinder.nv12').read_bytes(), OUT / 'viewfinder.ppm')
        else:
            fq(f, 'cp /tmp/x2v-live/preview.ppm %s/accept/pv.ppm; chmod a+r %s/accept/pv.ppm; true' % (G, G), 6000)
            d.adb('pull', '%s/accept/pv.ppm' % G, str(OUT / 'viewfinder.ppm'))
        score = band_score(OUT / 'viewfinder.ppm')
        verdict('viewfinder.no_bands', score < 1.5, band_score=round(score, 2), isp=bool(s.get('ispView')))
        shot(f, 'viewfinder-idle')
        full = keymap(f).get('E_Button_FullPress', [69])[0]
        # The two RAW recorders take the most CPU: the viewfinder must neither stall nor cost frames.
        for codec in ('prores_raw', 'dng'):
            set_codec(f, codec)
            video_ready(f)
            key(f, full)
            wait_gui(f, lambda s: (s.get('badge') or '').startswith('REC'), 10, 'REC')
            measure('recording_' + codec)
            shot(f, 'viewfinder-recording-' + codec)
            key(f, full)
            wait_gui(f, lambda s: s.get('badge') == '已保存', 20, 'saved')
            clip = (catalog(f) or [{}])[0].get('id')
            j = hexjson(f, '/mnt/media_rw/ssd/X2V_RAW/%s/clip.json' % clip) if clip else {}
            verdict('viewfinder.recording_%s_drops' % codec, j.get('dropped') == 0, clip=clip, frames=j.get('frames'),
                    dropped=j.get('dropped'), pre_ms_max=j.get('pre_ms_max'))


def button():
    """The on-screen record button: a tap starts, a tap stops, as the full press does. It steps
    aside while the stock ISO list is open over it."""
    with d.connect() as f:
        km = keymap(f)
        set_codec(f, 'h264')
        s = video_ready(f)
        b = s.get('recButton') or {}
        if not b.get('visible'):
            return verdict('button.visible', False, button=b)
        verdict('button.visible', True, button=b)
        shot(f, 'button-idle')
        t0 = device_ms(f)
        tap(f, int(b['x']), int(b['y']))
        try:
            wait_gui(f, lambda s: (s.get('badge') or '').startswith('REC'), 8, 'REC from the button')
            time.sleep(4)
            shot(f, 'button-recording')
            tap(f, int(b['x']), int(b['y']))
            s = wait_gui(f, lambda s: s.get('badge') == '已保存', 20, 'saved from the button')
            ev = events_since(s, t0)
            taps = [e for e in ev if e['e'] == 'rec_button']
            shown = [v for _, v in settled(ev)]
            clip = (catalog(f) or [{}])[0].get('id')
            j = hexjson(f, '/mnt/media_rw/ssd/X2V_RAW/%s/clip.json' % clip) if clip else {}
            verdict('button.records', len(taps) == 2 and not any(x in BAD_BADGES for x in shown) and j.get('dropped') == 0,
                    taps=len(taps), clip=clip, frames=j.get('frames'), dropped=j.get('dropped'))
        except TimeoutError as e:
            verdict('button.records', False, error=str(e))
        video_ready(f)
        key(f, (km.get('E_Button_IsoWb') or [73])[0])
        time.sleep(1.2)
        s = gui(f)
        verdict('button.hidden_under_iso_list', s.get('isoWb') and not (s.get('recButton') or {}).get('visible'),
                isoWb=s.get('isoWb'), button=s.get('recButton'))
        key(f, (km.get('E_Button_HalfPress') or [65])[0], 0.3)
        time.sleep(1.2)
        s = gui(f)
        verdict('button.back_after_iso_list', (s.get('recButton') or {}).get('visible'), isoWb=s.get('isoWb'))


def storage():
    """Near a full drive a clip stops itself and is saved, with the notice on screen; with no room
    a press of the shutter starts nothing and says why. Limits are moved instead of filling the
    drive: product/storage_mb "<stop> <start>", read at each start."""
    with d.connect() as f:
        full = keymap(f).get('E_Button_FullPress', [69])[0]
        set_codec(f, 'dng')
        video_ready(f)
        a_, s_ = fq(f, "stat -f -c '%a %S' /mnt/media_rw/ssd/X2V_RAW; true", 4000).split()[-2:]
        free = int(a_) * int(s_) // (1 << 20)
        # Stop once about 4 GB more is written: some 10 s of DNG.
        fq(f, 'echo %d 1000 > %s/product/storage_mb' % (free - 4000, G), 4000)
        try:
            key(f, full)
            wait_gui(f, lambda s: (s.get('badge') or '').startswith('REC'), 10, 'REC')
            s = wait_gui(f, lambda s: s.get('badge') == '已保存' and s.get('notice'), 60, 'auto stop')
            clip = (catalog(f) or [{}])[0].get('id')
            j = hexjson(f, '/mnt/media_rw/ssd/X2V_RAW/%s/clip.json' % clip) if clip else {}
            verdict('storage.auto_stop_saved', '存储空间将满' in s.get('notice', '') and j.get('dropped') == 0,
                    notice=s.get('notice'), clip=clip, frames=j.get('frames'), dropped=j.get('dropped'))
            shot(f, 'storage-auto-stop')
            fq(f, 'echo 1000 %d > %s/product/storage_mb' % (free + 100000, G), 4000)
            key(f, full)
            time.sleep(3)
            s = gui(f)
            verdict('storage.start_refused', '存储空间不足' in s.get('notice', '') and not (s.get('badge') or '').startswith('REC'),
                    notice=s.get('notice'), badge=s.get('badge'))
            shot(f, 'storage-start-refused')
        finally:
            fq(f, 'rm -f %s/product/storage_mb; true' % G, 4000)


def summary():
    (OUT / 'results.json').write_text(json.dumps(results, ensure_ascii=False, indent=1))
    bad = [r['check'] for r in results if not r['pass']]
    env = [r['check'] for r in results if r.get('level') == 'ENV']
    if env:
        print('bench (USB prompt), not counted: ' + ', '.join(env))
    print('\n%d checks, %d failed%s' % (len(results), len(bad), (': ' + ', '.join(bad)) if bad else ''))
    print('evidence', OUT)
    return not bad


if __name__ == '__main__':
    args = sys.argv[1:] or ['all']
    setup()
    if args == ['all']:
        args = ['boot', 'record', 'button', 'play', 'keys', 'viewfinder', 'storage', 'photo']
    i = 0
    while i < len(args):
        a = args[i]
        if a == 'record':
            codecs = []
            while i + 1 < len(args) and args[i + 1] in PROFILES:
                i += 1
                codecs.append(args[i])
            record(tuple(codecs) or ('h264', 'prores_raw', 'dng'))
        elif a in ('boot', 'button', 'play', 'keys', 'viewfinder', 'storage', 'photo'):
            globals()[a]()
        i += 1
    sys.exit(0 if summary() else 1)
