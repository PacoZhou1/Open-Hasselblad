"""Bounded ordinary-file RAW-sized I/O comparison; default makes no device call.

Root alone operates the camera. This never starts/stops imaging. A completed,
verified recording supplies read-only input; only exclusive new files are written.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import secrets
import subprocess
import time

from factory_session import connect
from gui_session import SERIAL, verify_device
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
HELPER = '/system/bin/x2v_frame_io_20261012a'
BASE = '/data/x2v-native-20261012'
LOCK = BASE+'/io-benchmark.lock'
SOURCE = '/mnt/media_rw/ssd/x2v-source-20261012/runs/source-isolated-081929/raw.partial'
SOURCE_BYTES = 210415104
SOURCE_SHA = 'cb86ea7b0b02956a44439210c7b2b07c899b35496b07c6fcf9b09b22b43ceb24'
FRAME_BYTES = 23379456
TOTAL_BYTES = FRAME_BYTES*3
LIBC = ROOT/'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/lib64/libc.so'
EXECUTION_READY = False


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def adb(*args, timeout=8):
    value = subprocess.run(['adb', '-s', SERIAL, *args], capture_output=True,
                           text=True, timeout=timeout)
    if value.returncode:
        raise RuntimeError(f'ADB rc={value.returncode}: {value.stderr[:1000]}')
    return value.stdout


def validate_result(data, source_stat):
    """Accept only complete native receipts bound to the preflight source inode."""
    def need(condition, reason):
        if not condition:
            raise ValueError('Invalid I/O receipt: '+reason)

    def number(value, minimum=0, maximum=None):
        return type(value) is int and value >= minimum and (maximum is None or value <= maximum)

    def exact(obj, expected):
        for key, value in expected.items():
            need(type(obj.get(key)) is type(value) and obj[key] == value, key)

    def timing(obj):
        exact(obj, {'clock_valid': 1})
        need(number(obj.get('wall_ns')) and number(obj.get('cpu_ns')), 'clock values')
        # Quantization can put CPU slightly above wall. Preserve that quality
        # diagnostic rather than discard the raw measurements or invent a cap.
        exact(obj, {'cpu_wall_consistent': int(obj['cpu_ns'] <= obj['wall_ns'])})

    need(type(data) is dict, 'root object')
    exact(data, dict(scope='ssd_raw_frame_write_compare', version=1,
                     **{'pass': True}, rc=0, errno=0, stage='complete', host_test=False,
                     frame_bytes=FRAME_BYTES, frame_count=3, payload_bytes=TOTAL_BYTES,
                     pool_bytes=TOTAL_BYTES, verify_buffer_bytes=4194304,
                     prefaulted=1, source_read_once=1, source_read_bytes=TOTAL_BYTES,
                     source_contract_valid=1, source_unchanged=1))
    exact(data['limits'], dict(core_bytes=0, cpu_seconds=15, alarm_seconds=30,
                              as_bytes=134217728, fsize_bytes=TOTAL_BYTES, rss_guard_kib=98304))
    need(number(data.get('peak_rss_kib'), 1, 98304), 'RSS bound')
    fields = source_stat.split(':')
    need(len(fields) == 4 and all(re.fullmatch(r'[0-9]+', x) for x in fields), 'source stat')
    dev, ino, links, size = map(int, fields)
    need(links == 1 and size == SOURCE_BYTES, 'source size/links')
    exact(data['source'], dict(dev=dev, ino=ino, size=size))
    flags = data['source'].get('flags')
    need(number(flags) and flags & 3 == 0, 'source FD readonly')
    offsets = {'pwrite': 0x70c40, 'pread': 0x70bc8, 'fsync': 0x70700}
    providers = data['providers']
    need(type(providers) is list and len(providers) == 3, 'provider count')
    bases = set()
    for item, (symbol, offset) in zip(providers, offsets.items()):
        exact(item, dict(symbol=symbol, path='/system/lib64/libc.so', verified=1, offset=offset))
        need(number(item.get('base'), 1) and number(item.get('address'), 1), 'provider address')
        need(item['base'] % 4096 == 0 and item['address'] == item['base']+offset, 'provider location')
        bases.add(item['base'])
    need(len(bases) == 1, 'same resident libc')
    cases = data['cases']
    need(type(cases) is list and len(cases) == 2, 'case count')
    for k, case in enumerate(cases):
        exact(case, dict(mode=['buffered', 'direct_required'][k], fd=3+k, started=1,
                         verify_mode='buffered_pread', readback_buffered=True, memcmp_full=True,
                         physical_disk_read_proven=False, completed_frames=3,
                         bytes_written=TOTAL_BYTES, verified=1, fsync_ok=1))
        # Linux ARM64 values are checked against the actual helper build headers.
        for key in ('flags_before', 'flags_write', 'flags_verify'):
            value = case.get(key)
            need(number(value) and value & 3 == 2, 'output RDWR '+key)
            need(value & (0x400 | 0x101000) == 0, 'no append/sync '+key)
            direct = key == 'flags_write' and k == 1
            need(bool(value & 0x10000) == direct, 'required direct flag '+key)
        frames = case['frames']
        need(type(frames) is list and len(frames) == 3, 'frame count')
        for index, frame in enumerate(frames):
            exact(frame, dict(index=index, offset=index*FRAME_BYTES,
                              requested_bytes=FRAME_BYTES, bytes_written=FRAME_BYTES,
                              src_mod512=0, src_mod4096=(index*FRAME_BYTES) % 4096))
            need(number(frame.get('calls'), 1, 32), 'bounded pwrite calls')
            timing(frame)
        timing(case['fsync'])
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    parser.add_argument('--artifact', type=Path)
    parser.add_argument('--sha256')
    args = parser.parse_args()
    if not args.execute:
        print(json.dumps(dict(device_access=False, helper=HELPER, cases=2,
                              bytes_per_case=TOTAL_BYTES, source_read_only=True,
                              capture_or_mode_change=False, draft_held=not EXECUTION_READY)))
        return 0
    if not EXECUTION_READY:
        raise RuntimeError('HOLD: source/ELF/host review pending; no device call')
    if not (args.artifact and re.fullmatch('[0-9a-f]{64}', args.sha256 or '') and
            sha(args.artifact) == args.sha256):
        raise ValueError('Exact reviewed local helper and SHA required')
    origin = json.loads((ROOT/'native-video/outputs/source-isolated-081929/ring20-readback-report.json').read_text())
    if not (origin['passed'] and origin['raw_bytes'] == SOURCE_BYTES and
            origin['raw_sha256'] == SOURCE_SHA):
        raise ValueError('Completed RAW source evidence differs')
    hold = json.loads((ROOT/'local-verification/source_session_execution_hold.json').read_text())
    if hold.get('released_modes'):
        raise ValueError('Another source experiment is released')
    verify_device()
    nonce = secrets.token_hex(8)
    run = datetime.now().strftime('frame-io-%H%M%S')+'-'+nonce[:8]
    out = ROOT/'native-video/outputs'/run
    out.mkdir(exist_ok=False)
    remote = BASE+'/runs/'+run
    media = '/mnt/media_rw/ssd/X2V_BENCH/'+run
    binding = f'v1 {run} {nonce}\n'
    report = dict(run_id=run, passed=False, helper=HELPER, helper_sha256=args.sha256,
                  scope='Ordinary-file comparison; stock imaging remains active',
                  source=SOURCE, source_bytes=SOURCE_BYTES, source_sha256=SOURCE_SHA,
                  control_directory=remote, media_directory=media, events=[],
                  lock_owned=False, dispatched=False, terminal_observed=False)

    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    def query(factory, command, capture_ms=4500):
        if len(command.encode()) > 231:
            raise ValueError('Factory command length exceeds transport')
        value = factory.factory_shell(command, capture_ms=capture_ms).strip()
        report['events'].append(dict(command=command, output=value))
        return value

    def snapshot(factory):
        return dict(service=query(factory, 'pidof camera-service'),
                    gui=query(factory, 'pidof camera-gui'),
                    gui_init=query(factory, 'getprop init.svc.camera-gui'),
                    state=query(factory, STATE),
                    frames=query(factory, 'timeout 4 odindb-send -s camera -m get_frame_count'),
                    memory=query(factory, 'head -n 6 /proc/meminfo'),
                    active_error=query(factory, 'timeout 3 odindb-send -s error -p active_error'),
                    mount=query(factory, 'mount | grep " /system "'))

    def healthy(value):
        return (value['service'].isdigit() and value['gui'].isdigit() and
                value['gui_init'] == 'running' and check_state(value['state']) and
                value['active_error'] == 'active_error = false' and '(ro,' in value['mount'])

    def input_locks_clear():
        paths = ['/data/x2v-source-20261012/source-session.lock',
                 '/data/x2v-native-20261012/gui-session.lock',
                 '/blackbox/x2v-native-20261011/gui-session.lock']
        return adb('shell', ' && '.join('test ! -e '+path for path in paths)+' && echo CLEAR').strip() == 'CLEAR'

    try:
        if not input_locks_clear():
            raise RuntimeError('Imaging or GUI owner lock exists')
        if adb('shell', 'test ! -e '+LOCK+' && echo CLEAR').strip() != 'CLEAR':
            raise RuntimeError('Existing ordinary-file owner; do not replace it')
        with connect() as factory:
            report['before'] = snapshot(factory)
            if not healthy(report['before']):
                raise RuntimeError('Stock health preflight failed')
            available = re.search(r'^MemAvailable:\s*(\d+) kB$', report['before']['memory'], re.M)
            if not available or int(available[1]) < 196608:
                raise RuntimeError('Require at least192MiB available RAM')
            if query(factory, 'sha256sum '+HELPER).split()[0] != args.sha256:
                raise RuntimeError('Installed helper differs from reviewed artifact')
            if query(factory, 'sha256sum /system/lib64/libc.so').split()[0] != sha(LIBC):
                raise RuntimeError('Original libc identity differs')
            free = query(factory, 'df -k /mnt/media_rw/ssd')
            report['ssd_before'] = free
            rows = [line.split() for line in free.splitlines() if line.strip()]
            if len(rows) < 2 or len(rows[-1]) < 6 or not rows[-1][3].isdigit() or int(rows[-1][3])*1024 < 8*1024**3+2*TOTAL_BYTES:
                raise RuntimeError('Require 8GiB SSD reserve after both output files')
            stat = query(factory, 'p='+SOURCE+'; test -f "$p" && test ! -L "$p" && stat -c "%d:%i:%h:%s" "$p"')
            fields = stat.split(':')
            if len(fields) != 4 or fields[2:] != ['1', str(SOURCE_BYTES)]:
                raise RuntimeError('Source identity/size/link contract differs')
            report['source_stat'] = stat
            if query(factory, 'timeout 10 sha256sum '+SOURCE, capture_ms=12000).split()[0] != SOURCE_SHA:
                raise RuntimeError('Source bytes differ from completed readback')
        # An exclusive shared marker remains on any unresolved dispatch.
        adb('shell', 'mkdir '+LOCK)
        report['lock_owned'] = True
        token = out/'owner.binding'
        token.write_text(binding)
        adb('push', str(token), LOCK+'/owner.binding')
        if adb('shell', 'cat '+LOCK+'/owner.binding') != binding:
            raise RuntimeError('Owner marker readback differs')
        adb('shell', 'test ! -e '+remote+' && mkdir '+remote)
        with connect() as factory:
            parent = '/mnt/media_rw/ssd/X2V_BENCH'
            command = 'test ! -L '+parent+' && mkdir -p '+parent+' && mkdir '+media+' && echo CREATED'
            if query(factory, command) != 'CREATED':
                raise RuntimeError('Exclusive output directory creation unconfirmed')
        controller = out/'controller.sh'
        controller.write_text(f'''#!/system/bin/sh
set -u
cd {remote} || exit 90
run_io() {{
 set -C
 : >{media}/buffered.partial || return 91
 : >{media}/direct.partial || return 92
 env -i PATH=/system/bin:/system/xbin timeout 35 nice -n 10 {HELPER} --run 3<>{media}/buffered.partial 4<>{media}/direct.partial 5<{SOURCE}
}}
run_io >result.json 2>error.log
rc=$?
printf 'v1 {run} {nonce} %s\\n' "$rc" >terminal.tmp && mv terminal.tmp terminal
exit "$rc"
''')
        adb('push', str(controller), remote+'/controller.sh')
        if adb('shell', 'sha256sum '+remote+'/controller.sh').split()[0] != sha(controller):
            raise RuntimeError('Controller upload hash differs')
        # Mark attempted before dispatch: an uncertain USB reply must not cause
        # a second launch or removal of a potentially live writer's lock.
        report['dispatched'] = True
        save()
        with connect() as factory:
            pid = query(factory, 'cd '+remote+' && { toybox nohup sh controller.sh >controller.log 2>&1 & echo $!; }')
            if not pid.isdigit():
                raise RuntimeError('No canonical supervisor PID; do not redispatch')
            report['supervisor_pid'] = int(pid)
            report['supervisor_initial_stat'] = query(factory, 'if [ -r /proc/'+pid+'/stat ];then cat /proc/'+pid+'/stat;fi')
        save()
        deadline = time.monotonic()+55
        while time.monotonic() < deadline:
            try:
                raw = adb('shell', 'if [ -f '+remote+'/terminal ];then cat '+remote+'/terminal;fi', timeout=2)
            except (subprocess.TimeoutExpired, RuntimeError) as exc:
                report.setdefault('observation_errors', []).append(repr(exc))
                continue
            tokens = raw.split()
            if (raw.endswith('\n') and len(raw.splitlines()) == 1 and len(tokens) == 4 and
                    tokens[:3] == ['v1', run, nonce] and tokens[3].isdigit() and int(tokens[3]) <= 255):
                report['terminal_observed'] = True
                report['returncode'] = int(tokens[3])
                break
            time.sleep(.25)
        else:
            raise RuntimeError('Observation expired; retain owner lock and inspect same supervisor')
        for name in ['result.json', 'error.log', 'controller.log', 'terminal']:
            adb('pull', remote+'/'+name, str(out/name))
        data = json.loads((out/'result.json').read_text())
        report['result'] = data
        if report['returncode']:
            raise RuntimeError('Helper failed; preserve partial files and its error receipt')
        validate_result(data, report['source_stat'])
        with connect() as factory:
            report['source_stat_after'] = query(factory, 'p='+SOURCE+'; test -f "$p" && test ! -L "$p" && stat -c "%d:%i:%h:%s" "$p"')
            report['source_sha256_after'] = query(factory, 'timeout 10 sha256sum '+SOURCE, capture_ms=12000).split()[0]
        if report['source_stat_after'] != report['source_stat'] or report['source_sha256_after'] != SOURCE_SHA:
            raise RuntimeError('Original source changed across comparison')
        report['io_validated'] = True
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        # Timeout is not proof of completion. Only no dispatch or this run's
        # canonical parent terminal record allows exact owned-lock removal.
        if report['lock_owned'] and (not report['dispatched'] or report['terminal_observed']):
            try:
                if adb('shell', 'cat '+LOCK+'/owner.binding') != binding:
                    raise RuntimeError('Owner changed; leave lock untouched')
                adb('shell', 'rm '+LOCK+'/owner.binding && rmdir '+LOCK)
                report['own_lock_released'] = True
            except Exception as exc:
                report['lock_release_error'] = repr(exc)
        try:
            with connect() as factory:
                report['after'] = snapshot(factory)
            before, after = report.get('before', {}), report['after']
            f0 = re.fullmatch(r'count\s*=\s*(\d+)', before.get('frames', ''))
            f1 = re.fullmatch(r'count\s*=\s*(\d+)', after['frames'])
            report['liveview_advanced'] = bool(f0 and f1 and int(f1[1]) > int(f0[1]))
            report['stock_unchanged'] = healthy(after) and all(before.get(k) == after[k] for k in ('service', 'gui'))
            report['imaging_locks_absent'] = input_locks_clear()
        except Exception as exc:
            report['health_error'] = repr(exc)
        report['passed'] = bool(report.get('io_validated') and report.get('own_lock_released') and
                                report.get('stock_unchanged') and report.get('liveview_advanced') and
                                report.get('imaging_locks_absent') and not report.get('failure') and
                                not report.get('health_error'))
        save()
        print(json.dumps(dict(passed=report['passed'], report=str(out/'report.json'),
                              failure=report.get('failure'), terminal=report['terminal_observed']), indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
