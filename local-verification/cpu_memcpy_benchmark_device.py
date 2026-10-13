"""One bounded anonymous-RAM comparison; stock imaging remains owned by stock.

No camera mode, HAL buffer, SSD, cache policy, firmware or service mutation.
The independently reviewed helper must already be staged at the pinned path.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess

from factory_session import connect
from gui_session import SERIAL, verify_device
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
HELPER = '/system/bin/x2v_memcpy_bench_20261012a'
FRAME_BYTES = 23379456
LIBC = ROOT/'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/lib64/libc.so'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_result(data):
    if not (data.get('pass') is True and data.get('rc') == 0 and
            data.get('scope') == 'cpu_anonymous_ram' and
            data.get('copy_provider_pinned') == 1 and data.get('copy_provider_kind') == 1 and
            data.get('copy_provider_path') == '/system/lib64/libc.so' and
            data.get('frame_bytes') == FRAME_BYTES and
            data.get('pool_bytes') == 2*(FRAME_BYTES+64) and
            isinstance(data.get('peak_rss_kib'), int) and
            0 < data['peak_rss_kib'] <= 65536):
        raise ValueError('Benchmark top-level evidence rejected')
    base, offset, address = (data.get('copy_provider_'+key) for key in ('base', 'offset', 'address'))
    if not (all(type(n) is int for n in (base, offset, address)) and
            base > 0 and offset == 0x1e590 and address == base+offset):
        raise ValueError('Provider address receipt differs from inspected ELF')
    expected_limits = {'cpu_seconds': 4, 'alarm_seconds': 8, 'as_bytes': 134217728,
                       'fsize_bytes': 16384, 'rss_guard_kib': 65536,
                       'max_cases': 4, 'iterations_per_case': 3}
    if data.get('limits') != expected_limits:
        raise ValueError('Resource limit receipt differs')
    cases = data.get('cases', [])
    if len(cases) != 4:
        raise ValueError('Expected exactly four copy cases')
    identities = set()
    for case in cases:
        identity = (case.get('implementation'), case.get('alignment'))
        if identity in identities:
            raise ValueError('Duplicate benchmark case')
        identities.add(identity)
        if not (case.get('iterations') == 3 and case.get('bytes') == FRAME_BYTES and
                case.get('total_bytes') == FRAME_BYTES*3 and case.get('verified') == 1 and
                isinstance(case.get('wall_ns'), int) and isinstance(case.get('cpu_ns'), int) and
                0 < case['wall_ns'] <= 10000000000 and
                0 < case['cpu_ns'] <= min(case['wall_ns'], 4000000000)):
            raise ValueError('Benchmark case rejected')
    if identities != {(impl, align) for impl in ('v9_exact', 'native_libc') for align in (0, 1)}:
        raise ValueError('Unexpected benchmark cases')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--execute', action='store_true')
    ap.add_argument('--artifact', type=Path)
    ap.add_argument('--sha256')
    args = ap.parse_args()
    if not args.execute:
        print(json.dumps({'device_access': False, 'helper': HELPER,
                          'frames_captured': 0, 'ordinary_ram_only': True,
                          'outer_timeout_seconds': 10, 'minimum_available_kib': 196608}))
        return 0
    if not (args.artifact and re.fullmatch(r'[a-f0-9]{64}', args.sha256 or '') and
            digest(args.artifact) == args.sha256):
        raise ValueError('Exact reviewed local artifact and SHA required before device access')
    verify_device()
    out = ROOT/'native-video/outputs'/datetime.now().strftime('cpu-memcpy-%H%M%S')
    out.mkdir(exist_ok=False)
    report = {'scope': 'Anonymous RAM helper only; no source-frame or capture-rate proof',
              'time': datetime.now().astimezone().isoformat(), 'passed': False,
              'helper': HELPER, 'helper_sha256': args.sha256, 'events': [], 'dispatched': False}

    def query(f, command):
        if len(command.encode()) > 231:
            raise ValueError('Factory command too long')
        value = f.factory_shell(command, capture_ms=4000).strip()
        report['events'].append({'command': command, 'output': value})
        return value

    def snapshot(f):
        return {'service': query(f, 'pidof camera-service'),
                'gui': query(f, 'pidof camera-gui'),
                'gui_init': query(f, 'getprop init.svc.camera-gui'),
                'state': query(f, STATE),
                'frames': query(f, 'timeout 4 odindb-send -s camera -m get_frame_count'),
                'memory': query(f, 'head -n 6 /proc/meminfo'),
                'active_error': query(f, 'timeout 3 odindb-send -s error -p active_error'),
                'mount': query(f, 'mount | grep " /system "'),
                'locks': query(f, 'for p in /data/x2v-source-20261012/source-session.lock /data/x2v-native-20261012/gui-session.lock /blackbox/x2v-native-20261011/gui-session.lock;do test ! -e "$p" || echo "$p";done;true')}

    def healthy(s):
        return (s['service'].isdigit() and s['gui'].isdigit() and s['gui_init'] == 'running' and
                check_state(s['state']) and '(ro,' in s['mount'] and not s['locks'] and
                s['active_error'] == 'active_error = false')

    try:
        with connect() as f:
            if query(f, 'sha256sum '+HELPER).split()[0] != args.sha256:
                raise ValueError('Installed helper SHA mismatch')
            report['libc_sha256'] = query(f, 'sha256sum /system/lib64/libc.so').split()[0]
            if report['libc_sha256'] != digest(LIBC):
                raise ValueError('Installed libc differs from inspected provider')
            report['before'] = snapshot(f)
        b = report['before']
        if not healthy(b):
            raise ValueError('Stock health gate failed')
        available = int(re.search(r'^MemAvailable:\s*(\d+) kB$', b['memory'], re.M)[1])
        if available < 196608:
            raise ValueError('Insufficient available memory for bounded benchmark')
        report['dispatched'] = True
        command = 'env -i PATH=/system/bin:/system/xbin timeout 10 nice -n 10 '+HELPER+' --run'
        proc = subprocess.run(['adb', '-s', SERIAL, 'shell', command], capture_output=True,
                              text=True, timeout=16)
        (out/'stdout.json').write_text(proc.stdout)
        (out/'stderr.txt').write_text(proc.stderr)
        report['returncode'] = proc.returncode
        if proc.returncode:
            raise RuntimeError('Helper returned nonzero; retained stdout/stderr')
        data = json.loads(proc.stdout)
        report['result'] = data
        validate_result(data)
        report['benchmark_validated'] = True
    except Exception as exc:
        report['error'] = repr(exc)
    finally:
        try:
            with connect() as f:
                report['after'] = snapshot(f)
            a = report['after']
            b = report.get('before', {})
            f0 = re.fullmatch(r'count\s*=\s*(\d+)', b.get('frames', ''))
            f1 = re.fullmatch(r'count\s*=\s*(\d+)', a['frames'])
            report['liveview_advanced'] = bool(f0 and f1 and int(f1[1]) > int(f0[1]))
            report['stock_unchanged'] = healthy(a) and all(b.get(k) == a[k] for k in ('service', 'gui'))
        except Exception as exc:
            report['health_error'] = repr(exc)
        report['passed'] = bool(report.get('benchmark_validated') and report.get('liveview_advanced') and
                                report.get('stock_unchanged') and not report.get('error'))
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps({'passed': report['passed'], 'report': str(out/'report.json'),
                          'error': report.get('error'), 'health_error': report.get('health_error')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
