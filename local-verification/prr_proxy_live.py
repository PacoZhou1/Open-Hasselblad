"""Transcode an on-camera ProRes RAW clip to HEVC playback.mp4, then publish a take."""
import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'native-video/outputs/prr-proxy-live'
SRC = '/mnt/media_rw/ssd/x2v-source-20261012/runs/source-isolated-050839/dng/clip.mov'
WORK = '/data/x2v-native-20261012/prr-proxy'
TAKE = '/mnt/media_rw/ssd/X2V_RAW/X2V_PRR_050839_CLIP1'
VIDEO = '/mnt/media_rw/ssd/X2V_VIDEO/X2V_PRR_050839.mp4'
PROXY_BIN = '/system/bin/x2v_prr_proxy_20261013b'
GUARD = '/system/lib64/libx2v_inotify_guard.so'


def adb(*args, timeout=30):
    r = subprocess.run(['adb', '-s', '123456789ABCDEF', *args], capture_output=True, text=True, timeout=timeout)
    if r.returncode:
        raise RuntimeError(r.stderr or r.stdout)
    return r.stdout


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    report = {'src': SRC, 'take': TAKE, 'passed': False}
    with connect() as f:
        def q(cmd, ms=8000):
            assert len(cmd.encode()) <= 231, len(cmd.encode())
            return f.factory_shell(cmd, capture_ms=ms)
        report['src_ls'] = q('ls -l ' + SRC)
        report['venc'] = q('ls -l /system/bin/test_venc_e2')
        report['mkdir'] = q('mkdir -p %s && echo MK' % WORK)
        report['clean'] = q('rm -f %s/proxy.rc %s/playback.mp4 %s/proxy.mp4 %s/proxy.log' % (WORK, WORK, WORK, WORK))
        report['copy'] = q('cp %s %s/clip.mov && echo CP' % (SRC, WORK), 8000)
    launch = OUT / 'launch.sh'
    launch.write_text(
        '#!/system/bin/sh\ncd %s\n'
        'LD_PRELOAD=%s %s -i %s/clip.mov -o %s/playback.mp4 --work %s --preload %s '
        '>proxy.log 2>&1\n'
        'echo $? >proxy.rc\n' % (WORK, GUARD, PROXY_BIN, WORK, WORK, WORK, GUARD))
    adb('push', str(launch), WORK + '/launch.sh')
    dispatch = 'cd %s && toybox nohup sh launch.sh </dev/null >session.log 2>&1 & echo $!' % WORK
    assert len(dispatch.encode()) <= 231, len(dispatch.encode())
    with connect() as f:
        pid = f.factory_shell(dispatch, capture_ms=4000).strip()
    report['proxy_pid'] = pid
    if not pid.isdigit():
        raise RuntimeError('proxy dispatch failed: ' + pid)
    deadline = time.monotonic() + 180
    rc_text = ''
    while time.monotonic() < deadline:
        rc_text = adb('shell', 'if [ -f %s/proxy.rc ]; then cat %s/proxy.rc; fi' % (WORK, WORK)).strip()
        if rc_text:
            break
        time.sleep(1)
    log = adb('shell', 'cat %s/proxy.log' % WORK)
    report['proxy_stdout'] = log
    report['proxy_stderr'] = ''
    report['proxy_rc'] = int(rc_text) if rc_text.isdigit() else -1
    with connect() as f:
        def q(cmd, ms=8000):
            assert len(cmd.encode()) <= 231, len(cmd.encode())
            return f.factory_shell(cmd, capture_ms=ms)
        report['work_ls'] = q('ls -l %s' % WORK)
        if report['proxy_rc'] == 0:
            report['take_mk'] = q('mkdir -p %s/preview %s/raw && echo TM' % (TAKE, TAKE))
            report['pub_clip'] = q('cp %s/clip.mov %s/clip.mov && echo CC' % (WORK, TAKE), 8000)
            report['pub_mp4'] = q('cp %s/playback.mp4 %s/preview/playback.mp4 && echo PM' % (WORK, TAKE), 8000)
            report['vid_mk'] = q('mkdir -p /mnt/media_rw/ssd/X2V_VIDEO && echo VM')
            report['pub_vid'] = q('cp %s/playback.mp4 %s && echo PV' % (WORK, VIDEO), 8000)
            report['playback_stat'] = q('ls -l %s/preview/playback.mp4 %s' % (TAKE, VIDEO))
    ok = report['proxy_rc'] == 0 and '"ok":true' in (report['proxy_stdout'] or '')
    report['passed'] = ok
    (OUT / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': ok, 'report': str(OUT / 'report.json'),
                      'stdout': (report['proxy_stdout'] or '')[-400:],
                      'stderr': (report['proxy_stderr'] or '')[-400:]}, indent=2))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
