"""One saved full-frame still encoded by CPU on camera; never starts capture.

Explicit execution requires the separately reviewed, hash-pinned installed helper.
The input was demosaiced/downsampled on the host. This is not 4K live recording.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import shlex
import time
import uuid

from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
HELPER = '/system/bin/x2v_ffhevc10_20261012a'
HELPER_SHA = 'e03369f8ec2aac416ba3a023d000cce2dc55b69f6b93c72cb61a22e4f93b3bb9'
SOURCE = ROOT/'native-video/experimental/full-frame-reference/evidence/real-still-3648-final/rec709-3840x2880-yuv420p10le.yuv'
SOURCE_SHA = '454b15fdaae7ceb625a2fdbf99b3261b54521754a65838f706af63f88605d9ea'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if not args.execute:
        print(json.dumps({'device_access': False, 'helper': HELPER, 'frames': 1,
                          'dimensions': [3840, 2880], 'capture': False,
                          'wall_limit_seconds': 42, 'address_space_mib': 256}))
        return 0
    if SOURCE.stat().st_size != 33177600 or sha(SOURCE) != SOURCE_SHA:
        raise RuntimeError('Pinned real full-frame input changed')
    ident = datetime.now().strftime('ffhevc-%H%M%S')
    out = ROOT/'native-video/outputs'/ident
    out.mkdir(exist_ok=False)
    remote = '/blackbox/x2v-native-20261011/runs/'+ident
    report = {'run_id': ident, 'remote': remote, 'passed': False, 'events': [],
              'dispatched': False, 'input_sha256': SOURCE_SHA,
              'helper_sha256': HELPER_SHA, 'distinct_capture_count': 1,
              'source_semantics': 'B0003648 original full crop, host RGB/Rec709/resize; on-camera CPU encoding only',
              'continuous_video': False, 'media_validation_pending': True}

    def query(f, command):
        if len(command.encode()) > 231:
            raise ValueError('Factory command exceeds 231 bytes')
        value = f.factory_shell(command, capture_ms=6000)
        report['events'].append({'command': command, 'output': value})
        return value

    def snapshot(f):
        return {'service': query(f, 'pidof camera-service').strip(),
                'gui': query(f, 'pidof camera-gui').strip(),
                'gui_init': query(f, 'getprop init.svc.camera-gui').strip(),
                'state': query(f, STATE),
                'frames': query(f, 'timeout 4 odindb-send -s camera -m get_frame_count'),
                'memory': query(f, 'head -n 6 /proc/meminfo'),
                'system_mount': query(f, 'mount | grep " /system "')}

    try:
        with connect() as f:
            if query(f, 'sha256sum '+HELPER).split()[0] != HELPER_SHA:
                raise RuntimeError('Installed helper differs from reviewed binary')
            report['before'] = snapshot(f)
            before = report['before']
            if not (before['service'].isdigit() and before['gui'].isdigit() and
                    before['gui_init'] == 'running' and check_state(before['state']) and
                    '(ro,' in before['system_mount']):
                raise RuntimeError('Expected stable stock GUI, normal liveview and read-only system')
            available = next(int(x.split()[1]) for x in before['memory'].splitlines() if x.startswith('MemAvailable:'))
            if available < 358400:
                raise RuntimeError('Need at least 350MiB available before bounded 256MiB CPU test')
            nonce = uuid.uuid4().hex
            if query(f, 'test ! -e '+remote+' && mkdir '+remote+' && echo '+nonce).strip() != nonce:
                raise RuntimeError('Exclusive job directory was not acknowledged')
        encode = f'''#!/system/bin/sh
set -eu
set -C
exec {HELPER} --input-fd 3 --output-fd 4 --width 3840 --height 2880 --frames 1 --fps 1 3<input.yuv 4>result.partial.h265
'''
        controller = f'''#!/system/bin/sh
set -u
cd {shlex.quote(remote)} || exit 90
head -n1 /proc/uptime >before-uptime.txt
timeout 42 nice -n 10 sh encode.sh >encode.log 2>&1
rc=$?
printf '%s\\n' "$rc" >exit-code.txt
head -n1 /proc/uptime >after-uptime.txt
sha256sum input.yuv result.partial.h265 >hashes.txt
chmod 644 *.log *.txt *.h265
echo CONTROLLER_FINISHED
'''
        (out/'encode.sh').write_text(encode)
        (out/'controller.sh').write_text(controller)
        for source, name in [(SOURCE, 'input.yuv'), (out/'encode.sh', 'encode.sh'), (out/'controller.sh', 'controller.sh')]:
            adb('push', str(source), remote+'/'+name)
        with connect() as f:
            for source, name in [(SOURCE, 'input.yuv'), (out/'encode.sh', 'encode.sh'), (out/'controller.sh', 'controller.sh')]:
                if query(f, 'sha256sum '+remote+'/'+name).split()[0] != sha(source):
                    raise RuntimeError('Uploaded file hash differs')
            report['dispatched'] = True
            report['controller_pid'] = query(f, 'cd '+remote+';toybox nohup sh controller.sh >controller.log 2>&1 & echo $!').strip()
        # CPU-only process: independent timeout and its own alarm require no
        # sensor/GUI restoration operation, even if this host disappears.
        for _ in range(22):
            time.sleep(2)
            if adb('shell', 'test -f '+remote+'/exit-code.txt && cat '+remote+'/exit-code.txt || true').strip():
                break
        with connect() as f:
            report['after'] = snapshot(f)
            report['exit_code'] = query(f, 'cat '+remote+'/exit-code.txt').strip()
            report['device_output_sha256'] = query(f, 'sha256sum '+remote+'/result.partial.h265').split()[0]
        for name in ('result.partial.h265', 'encode.log', 'controller.log', 'exit-code.txt', 'before-uptime.txt', 'after-uptime.txt', 'hashes.txt'):
            adb('pull', remote+'/'+name, str(out/name))
        report['output_sha_matches'] = sha(out/'result.partial.h265') == report['device_output_sha256']
        report['input_still_matches'] = (out/'hashes.txt').read_text().splitlines()[0].split()[0] == SOURCE_SHA
        report['output_bytes'] = (out/'result.partial.h265').stat().st_size
        resource = re.search(r'peak_rss_kib=(\d+)', (out/'encode.log').read_text())
        report['peak_rss_kib'] = int(resource[1]) if resource else None
        report['wall_seconds_including_launcher'] = round(float((out/'after-uptime.txt').read_text().split()[0])-float((out/'before-uptime.txt').read_text().split()[0]), 2)
        after = report['after']
        before_frames = re.fullmatch(r'count\s*=\s*(\d+)\s*', before['frames'])
        after_frames = re.fullmatch(r'count\s*=\s*(\d+)\s*', after['frames'])
        report['liveview_advanced'] = bool(before_frames and after_frames and int(after_frames[1]) > int(before_frames[1]))
        report['passed'] = bool(report['exit_code'] == '0' and report['output_sha_matches'] and
                                report['input_still_matches'] and report['liveview_advanced'] and
                                report['peak_rss_kib'] is not None and report['peak_rss_kib'] <= 256000 and
                                0 < report['output_bytes'] <= 32*1024*1024 and
                                all(before[k] == after[k] for k in ('service', 'gui')) and
                                after['gui_init'] == 'running' and check_state(after['state']) and
                                '(ro,' in after['system_mount'])
    except Exception as exc:
        report['exception'] = repr(exc)
    finally:
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps({'passed': report['passed'], 'report': str(out/'report.json'),
                          'exception': report.get('exception')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
