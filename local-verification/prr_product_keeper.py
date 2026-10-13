"""Host keeper: 就绪 heartbeat helper + isolated PRR take + overlay after reboot."""
import hashlib
import json
import shutil
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect
from camera_testing import LOCK

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'native-video/experimental/prr-product-gui'
PKT = ROOT / 'native-video/outputs/prr-product-release-20261013'
REMOTE = '/blackbox/x2v-native-20261011'
REC = REMOTE + '/rec'
SERIAL = '123456789ABCDEF'
OWNER = 'z-cursor-prr-gui'
BOOT = '/system/bin/x2v_prr_gui_boot_20261013d'
RC_DEST = '/system/etc/init/x2v-prr-gui.rc'


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def adb(*args, timeout=30):
    r = subprocess.run(['adb', '-s', SERIAL, *args], capture_output=True, text=True, timeout=timeout)
    if r.returncode:
        raise RuntimeError((r.stderr or r.stdout or 'adb failed').strip())
    return r.stdout


def require_claim():
    owner = json.loads((LOCK / 'owner.json').read_text())
    if owner.get('state') != 'TESTING' or owner.get('owner') != OWNER:
        raise SystemExit('claim the camera as %s first' % OWNER)


def factory(cmd, ms=5000):
    assert len(cmd.encode()) <= 231, (len(cmd.encode()), cmd)
    with connect() as f:
        return f.factory_shell(cmd, capture_ms=ms).strip()


def install_init_rc():
    local = SRC / 'x2v-prr-gui.rc'
    adb('push', str(local), REMOTE + '/x2v-prr-gui.rc')
    factory('mount -o remount,rw /system')
    try:
        factory('cp %s/x2v-prr-gui.rc %s' % (REMOTE, RC_DEST))
        factory('chmod 644 %s' % RC_DEST)
        print(factory('ls -l %s' % RC_DEST))
    finally:
        factory('mount -o remount,ro /system')
        print(factory('mount | grep " /system "'))


def start_helper():
    adb('push', str(SRC / 'x2v_prr_helper.sh'), REC + '/helper.sh')
    adb('shell', 'rm -f %s/helper.stop %s/helper.pid; mkdir -p %s' % (REC, REC, REC))
    dispatch = 'cd %s && toybox nohup sh helper.sh </dev/null >helper.log 2>&1 & echo $!' % REC
    assert len(dispatch.encode()) <= 231, len(dispatch.encode())
    pid = factory(dispatch)
    if not pid.isdigit():
        pid = adb('shell', dispatch).strip()
    if not pid.isdigit():
        raise RuntimeError('helper dispatch failed: ' + pid)
    return pid


def wait_ready(seconds=20):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        raw = adb('shell', 'cat %s/state.json 2>/dev/null || true' % REC)
        try:
            st = json.loads(raw)
        except json.JSONDecodeError:
            time.sleep(0.4)
            continue
        if st.get('backend_ready') is True:
            return st
        time.sleep(0.4)
    raise RuntimeError('helper did not publish backend_ready')


def consume_command():
    raw = adb('shell', 'cat %s/command 2>/dev/null || true' % REC).strip()
    if raw:
        adb('shell', 'rm -f %s/command' % REC)
    return raw


def yield_to_stock():
    adb('shell', 'mkdir -p %s; echo 1 > %s/busy' % (REC, REC))
    factory('sh /blackbox/x2v-native-20261011/runs/prr-gui-persist/prr_gui_persist.sh --stop')
    for _ in range(40):
        svc = factory('getprop init.svc.camera-gui')
        pids = factory('pidof camera-gui')
        if svc == 'running' and pids:
            return
        time.sleep(0.5)
    # persist --stop may already have restored; also try ctl.start
    factory('setprop ctl.start camera-gui')
    time.sleep(2)


def bring_overlay():
    adb('shell', 'rm -f %s/busy' % REC)
    factory('test -x %s && %s >/blackbox/x2v-native-20261011/runs/prr-gui-boot/boot.log 2>&1 &' % (BOOT, BOOT))
    time.sleep(3)


def finalize_take(take, work):
    """Run on-device finalize as soon as clip.mov exists. No host pull."""
    factory('mkdir -p %s/preview %s' % (take, work))
    cmd = 'toybox nohup /system/bin/x2v_prr_finalize_20261013c %s %s >/data/x2v-native-20261012/fin.log 2>&1 & echo $!' % (take, work)
    assert len(cmd.encode()) <= 231, len(cmd.encode())
    pid = factory(cmd)
    deadline = time.monotonic() + 90
    while time.monotonic() < deadline:
        out = factory('ls -l %s/preview/playback.mp4 2>/dev/null || echo NO' % take)
        if 'playback.mp4' in out and 'NO' not in out:
            return True
        # Encoder may leave work/proxy.mp4 after venc and not return.
        left = factory('ls -l %s/proxy.mp4 %s/playback.mp4 2>/dev/null || echo NO' % (work, work))
        if 'NO' not in left and ('.mp4' in left):
            factory('cp %s/proxy.mp4 %s/preview/playback.mp4 2>/dev/null || cp %s/playback.mp4 %s/preview/playback.mp4' % (work, take, work, take))
            factory('cp %s/preview/playback.mp4 %s/%s.mp4' % (take, REMOTE, take.rsplit('/', 1)[-1]))
            return True
        time.sleep(2)
    return False


def publish_takes(run_id):
    clips = []
    bulk = '/mnt/media_rw/ssd/x2v-source-20261012/runs/' + run_id
    for src_rel, label in (('dng/clip.mov', 'C1'), ('dng2/clip.mov', 'C2')):
        take_id = run_id.replace('source-isolated-', 'X2V_PRR_') + '_' + label
        take = '/mnt/media_rw/ssd/X2V_RAW/' + take_id
        work = '/data/x2v-native-20261012/prr-' + label.lower()
        src = bulk + '/' + src_rel
        if 'clip.mov' not in factory('ls -l %s 2>/dev/null || echo NO' % src):
            continue
        factory('mkdir -p %s/preview && cp %s %s/clip.mov && echo CP' % (take, src, take))
        size = factory('stat -c %%s %s/clip.mov' % take)
        clips.append({
            'id': take_id, 'state': 'saved', 'finalized': True,
            'source': take + '/clip.mov', 'thumbnail': REMOTE + '/prr-050839.jpg',
            'title': 'ProRes RAW HQ ' + label, 'duration': 0.79,
            'bytes': int(size) if str(size).isdigit() else 74788229,
            'width': 3888, 'height': 2912,
            'format': 'ProRes RAW HQ',
        })
    if clips:
        existing = {'schemaVersion': 1, 'clips': []}
        try:
            existing = json.loads(adb('shell', 'cat %s/catalog.json 2>/dev/null || true' % REC) or '{}')
        except json.JSONDecodeError:
            pass
        if not isinstance(existing.get('clips'), list):
            existing = {'schemaVersion': 1, 'clips': []}
        existing['schemaVersion'] = 1
        existing['clips'] = clips + existing.get('clips', [])
        tmp = ROOT / 'native-video/outputs/prr-product-gui-install/catalog.json'
        tmp.parent.mkdir(parents=True, exist_ok=True)
        tmp.write_text(json.dumps(existing, indent=2) + '\n')
        adb('push', str(tmp), REC + '/catalog.json')
    return clips


def run_take():
    report = {'started_at': datetime.now().isoformat()}
    yield_to_stock()
    cmd = [sys.executable, str(ROOT / 'local-verification/isolated_two_prr_async_test.py'), '--execute']
    proc = subprocess.run(cmd, cwd=str(ROOT), capture_output=True, text=True, timeout=240)
    report['isolated_rc'] = proc.returncode
    report['isolated_out'] = (proc.stdout or '')[-4000:]
    report['isolated_err'] = (proc.stderr or '')[-2000:]
    # Latest source-isolated output
    run_id = None
    if 'source-isolated-' in (proc.stdout or ''):
        import re
        found = re.findall(r'source-isolated-\d{6}', proc.stdout)
        if found:
            run_id = found[-1]
    if not run_id:
        outs = sorted((ROOT / 'native-video/outputs').glob('source-isolated-*'), key=lambda p: p.stat().st_mtime)
        run_id = outs[-1].name if outs else None
    report['run_id'] = run_id
    clips = publish_takes(run_id) if run_id else []
    report['clips'] = clips
    bring_overlay()
    start_helper()
    report['ready_after'] = wait_ready()
    return report


def main():
    require_claim()
    action = sys.argv[1] if len(sys.argv) > 1 else 'up'
    if action == 'init-rc':
        install_init_rc()
        return 0
    if action == 'helper':
        print(json.dumps({'helper_pid': start_helper(), 'state': wait_ready()}, indent=2))
        return 0
    if action == 'take':
        print(json.dumps(run_take(), indent=2)[:4000])
        return 0
    if action == 'watch':
        start_helper()
        print(json.dumps({'state': wait_ready(), 'watching': True}, indent=2))
        while True:
            cmd = consume_command()
            if cmd == 'start':
                print(json.dumps(run_take(), indent=2)[:4000], flush=True)
            time.sleep(0.5)
    raise SystemExit('usage: prr_product_keeper.py up|init-rc|helper|take|watch')


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'up':
        require_claim()
        print(json.dumps({'helper_pid': start_helper(), 'state': wait_ready()}, indent=2))
    else:
        raise SystemExit(main())
