"""Bounded, CPU-only encoding of a saved RAW-derived diagnostic input.

Default is offline. Root alone stages the hash-pinned helper and executes this.
This never starts capture or changes camera state; it does not measure source fps.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import shlex
import time

from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'native-video/experimental/on-camera-hevc'
VARIANTS = {
    'lossless': ('/system/bin/x2v_swhevc10_20261011a',
                 '40148eaa486797fd45d46c6e7434355398e0045d70ab3e06d6a8b0e9cb8fd2c3'),
    'main10-cqp0': ('/system/bin/x2v_swhevc10_cqp0_20261011a',
                    '493e3ba0147d99f6d27d16e0ba41f91b1a5c37cfcbfb7ec05dfb1f0f936bdf9c'),
}
INPUT_SHA = '93781f799ac0b3a1b242d940857472826f3a3b90d3809a33f13541d7bbef3c9f'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--execute', action='store_true')
    p.add_argument('--variant', choices=VARIANTS, required=True)
    p.add_argument('--frames', type=int, choices=range(1, 6), default=1)
    a = p.parse_args()
    helper, expected = VARIANTS[a.variant]
    if not a.execute:
        print(json.dumps({'device_access': False, 'helper': helper,
                          'frames': a.frames, 'wall_limit_seconds': 10,
                          'input': 'repeated saved 640x480 RAW-derived gray frame'}))
        return
    source = SOURCE / 'inputs/real-raw-gray-10-640x480-1f.yuv'
    if source.stat().st_size != 921600 or sha(source) != INPUT_SHA:
        raise RuntimeError('Pinned real-source input changed')
    ident = datetime.now().strftime('swhevc-%H%M%S') + '-' + a.variant
    out = ROOT / 'native-video/outputs' / ident
    out.mkdir(exist_ok=False)
    remote = '/blackbox/x2v-native-20261011/runs/' + ident
    report = {'remote': remote, 'variant': a.variant, 'frames': a.frames,
              'source_semantics': 'Repeated saved diagnostic still, not live capture',
              'events': [], 'dispatched': False}

    def query(f, command, ms=1000):
        if len(command.encode()) > 231:
            raise ValueError('Factory command too long')
        value = f.factory_shell(command, capture_ms=ms)
        report['events'].append({'command': command, 'output': value})
        return value

    try:
        with connect() as f:
            if query(f, 'sha256sum ' + helper).split()[0] != expected:
                raise RuntimeError('Installed helper differs from reviewed binary')
            pids = query(f, 'pidof camera-service camera-gui').split()
            if len(pids) != 2 or not all(x.isdigit() for x in pids):
                raise RuntimeError('Expected one service and one GUI')
            if not check_state(query(f, STATE)):
                raise RuntimeError('Expected normal still liveview before CPU test')
            mem = query(f, 'head -n 5 /proc/meminfo')
            available = next(int(x.split()[1]) for x in mem.splitlines() if x.startswith('MemAvailable:'))
            if available < 300000:
                raise RuntimeError('Insufficient available memory for conservative CPU test')
            query(f, 'test ! -e ' + remote + ' && mkdir ' + remote)
        (out / 'input.yuv').write_bytes(source.read_bytes() * a.frames)
        script = f'''#!/system/bin/sh
set -u
cd {shlex.quote(remote)}
head -n1 /proc/uptime >before-uptime.txt
pidof camera-service camera-gui >before-pids.txt
timeout 10 nice -n 10 sh encode.sh >encode.log 2>&1
rc=$?
echo "$rc" >exit-code.txt
head -n1 /proc/uptime >after-uptime.txt
pidof camera-service camera-gui >after-pids.txt
sha256sum input.yuv result.partial.h265 >hashes.txt
chmod 644 *.log *.txt *.h265
echo CONTROLLER_FINISHED
'''
        encode = f'''#!/system/bin/sh
set -eu
set -C
exec {helper} --input-fd 3 --output-fd 4 --width 640 --height 480 --frames {a.frames} --fps 30 3<input.yuv 4>result.partial.h265
'''
        (out / 'controller.sh').write_text(script)
        (out / 'encode.sh').write_text(encode)
        for name in ('input.yuv', 'encode.sh', 'controller.sh'):
            adb('push', str(out / name), remote + '/' + name)
        with connect() as f:
            for name in ('input.yuv', 'encode.sh', 'controller.sh'):
                if query(f, 'sha256sum ' + remote + '/' + name).split()[0] != sha(out / name):
                    raise RuntimeError('Upload hash mismatch')
            report['dispatched'] = True
            report['controller_pid'] = query(f, 'cd ' + remote + ';toybox nohup sh controller.sh >controller.log 2>&1 & echo $!').strip()
        time.sleep(12)
        with connect() as f:
            report['final_pids'] = query(f, 'pidof camera-service camera-gui').split()
            report['same_service_and_gui'] = report['final_pids'] == pids
            report['final_state'] = query(f, STATE)
            report['liveview_healthy'] = check_state(report['final_state'])
            report['frame_count'] = query(f, 'timeout 4 odindb-send -s camera -m get_frame_count')
            report['system_mount'] = query(f, 'mount | grep " /system "')
            report['exit_code'] = query(f, 'cat ' + remote + '/exit-code.txt').strip()
            report['device_output_sha256'] = query(f, 'sha256sum ' + remote + '/result.partial.h265').split()[0]
        for name in ('result.partial.h265', 'encode.log', 'controller.log', 'exit-code.txt',
                     'before-uptime.txt', 'after-uptime.txt', 'before-pids.txt', 'after-pids.txt', 'hashes.txt'):
            adb('pull', remote + '/' + name, str(out / name))
        report['output_sha_matches'] = sha(out / 'result.partial.h265') == report['device_output_sha256']
        report['wall_seconds_including_launcher'] = round(float((out / 'after-uptime.txt').read_text().split()[0]) - float((out / 'before-uptime.txt').read_text().split()[0]), 2)
        report['process_test_passed'] = (report['exit_code'] == '0' and report['output_sha_matches'] and
            report['same_service_and_gui'] and report['liveview_healthy'] and '(ro,' in report['system_mount'])
        if not report['process_test_passed']:
            raise RuntimeError('Process test failed; see recorded evidence')
    except Exception as exc:
        report['exception'] = repr(exc)
        raise
    finally:
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print(out)


if __name__ == '__main__':
    main()
