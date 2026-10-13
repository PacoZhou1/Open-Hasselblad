"""One native RAW dump attempt on the existing still liveview.

Does not run by default. Execution also requires separately recorded evidence
that the global dump controller cannot select this port. Does not switch modes,
stop camera-service, patch firmware, or change the dump root.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shlex
import struct
import time

from factory_session import connect
from gui_session import adb

ROOT = Path(__file__).resolve().parents[1]
NODE = 'liveview_sbpc_basic-inport0Dmp'
CLI_SHA = 'f58fc466cbef315e59d395a531bc3be50c0e68dfc1435b9674acee90a8035f56'
BASE_SHA = '8486fa7ce0b400992358ad92c445ad026a3784703accf2bae8a490ed10b2ff52'
STATE = ('timeout 4 odindb-send -s camera -p '
         'live_view_state,liveview_transport_mode_current,stream_group,crop_mode_current')
DUMP = '/mnt/media_rw/ssd/camera_dump'
PARAMS = ('enable=1,total=1,interval=0,nopad=0,sync_dmp=0,'
          'dump_metadata=1,dump_frame_buffer=1')
DISARM = f'timeout 3 /system/bin/cam_dt_cmdline -e {NODE} enable=0'


def check_state(value):
    return all(x in value for x in (
        'E_LiveViewState_Active(1)', 'E_LiveviewTransportMode_None(0)',
        'E_StreamGroup_Still16bit(0)', 'E_CropMode_None(0)'))


def global_dump_clearance(f, service, query):
    """Read exact audited objects only; never ptrace, pause or write memory."""
    if query(f, 'sha256sum /system/lib64/libdcam_base.so').split()[0] != BASE_SHA:
        raise RuntimeError('Global controller library differs from audited ELF')
    maps = query(f, f'cat /proc/{service}/maps | grep -A6 libdcam_base')
    line = next(x for x in maps.splitlines()
                if 'r-xp 00000000' in x and x.endswith('/libdcam_base.so'))
    # Verified ELF PT_LOAD has p_offset=0 and p_vaddr=0x1000.
    bias = int(line.split('-')[0], 16) - 0x1000
    address = bias + 0x20e278

    def read(address, size):
        cmd = (f'dd if=/proc/{service}/mem bs=1 skip={address} count={size}'
               ' 2>/dev/null | od -An -v -tx1')
        data = bytes.fromhex(query(f, cmd))
        if len(data) != size:
            raise RuntimeError('Incomplete exact-address read')
        return data

    before = read(address, 160)
    pointers = struct.unpack('<20Q', before)
    rows = []
    for index, pointer in enumerate(pointers):
        if not pointer:
            continue
        mode = struct.unpack('<i', read(pointer + 0x2d4, 4))[0]
        ready = struct.unpack('<Q', read(pointer + 0x380, 8))[0]
        any_enabled = struct.unpack('<Q', read(pointer + 0x3a0, 8))[0]
        if mode != -1 or ready != bias + 0x13e4f8 or any_enabled != bias + 0x13f218:
            raise RuntimeError('Global controller is enabled or object identity differs')
        rows.append({'slot': index, 'pointer': hex(pointer), 'mode': mode,
                     'ready': hex(ready), 'any_enabled': hex(any_enabled)})
    if not rows or before != read(address, 160):
        raise RuntimeError('Global controller table changed or is empty')
    return {'library_bias': hex(bias), 'table': hex(address),
            'table_hex': before.hex(), 'controllers': rows,
            'all_allocated_controllers_disabled': True}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--execute', action='store_true')
    p.add_argument('--clearance', type=Path,
                   help='Reviewed evidence excluding a second dump trigger')
    a = p.parse_args()
    if not a.execute:
        print('Preparation only. No device access. Exact arm command:')
        print(f'/system/bin/cam_dt_cmdline -e {NODE} {shlex.quote(PARAMS)}')
        return
    if not a.clearance or not a.clearance.is_file():
        p.error('--execute requires reviewed --clearance evidence')
    identity = datetime.now().strftime('raw-one-%Y%m%d-%H%M%S')
    output = ROOT / 'native-video/outputs/highres-source-20261011' / identity
    output.mkdir()
    remote = '/blackbox/x2v-native-20261011/runs/' + identity
    report = {'utc': datetime.now(timezone.utc).isoformat(), 'remote': remote,
              'node': NODE, 'params': PARAMS, 'events': [], 'armed': False,
              'clearance': str(a.clearance.resolve()),
              'clearance_sha256': hashlib.sha256(a.clearance.read_bytes()).hexdigest()}

    def query(f, command, capture_ms=900):
        if len(command.encode()) > 231:
            raise ValueError('Factory command too long')
        value = f.factory_shell(command, capture_ms=capture_ms)
        report['events'].append({'command': command, 'output': value})
        return value

    try:
        with connect() as f:
            service = query(f, 'pidof camera-service').strip()
            gui = query(f, 'pidof camera-gui').strip()
            if not service.isdigit() or not gui.isdigit():
                raise RuntimeError('Expected one original service and GUI')
            if not check_state(query(f, STATE)):
                raise RuntimeError('Camera is not in the audited still liveview')
            if query(f, 'sha256sum /system/bin/cam_dt_cmdline').split()[0] != CLI_SHA:
                raise RuntimeError('Diagnostic CLI differs from audited firmware')
            # Exclusive new root ensures this run cannot truncate old dump files.
            query(f, f'test ! -e {DUMP}')
            query(f, f'test ! -e {remote} && mkdir {remote}')

        script = f'''#!/system/bin/sh
set -eu
cd {remote}
disarm() {{
 {DISARM}
}}
cleanup() {{
 disarm || echo DISARM_FAILED
}}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
[ "$(pidof camera-service)" = "{service}" ] || exit 31
[ ! -e {DUMP} ] || exit 32
# An independent process closes the selector even if this controller exits.
toybox nohup sh -c 'sleep 5;{DISARM}' >watchdog.log 2>&1 &
echo watchdog_pid=$!
(timeout 12 logcat --pid={service} -v epoch -T 1 | head -c8388608) >events.log 2>&1 &
echo logger_pid=$!
ready_count=0
while ! grep -q 'beginning of' events.log; do
 ready_count=$((ready_count+1))
 [ "$ready_count" -lt 15 ] || exit 33
 sleep 0.1
done
disarm
timeout 3 /system/bin/cam_dt_cmdline -e {NODE} '{PARAMS}'
echo ARMED_ONE_ATTEMPT
sleep 2
disarm
echo DISARMED
sleep 2
{STATE} >final-state.txt
pidof camera-service camera-gui >final-pids.txt
ls -lR {DUMP} >dump-files.txt 2>&1 || true
echo CONTROLLER_FINISHED
'''
        local = output / 'controller.sh'
        local.write_text(script)
        adb('push', str(local), remote + '/controller.sh')
        digest = hashlib.sha256(local.read_bytes()).hexdigest()
        with connect() as f:
            if query(f, 'sha256sum ' + remote + '/controller.sh').split()[0] != digest:
                raise RuntimeError('Controller upload differs')
            report['global_dump_clearance'] = global_dump_clearance(f, service, query)
            if query(f, 'pidof camera-service').strip() != service:
                raise RuntimeError('Service changed during preparation')
            report['armed'] = 'dispatch_requested'
            report['controller_pid'] = query(f, f'cd {remote};toybox nohup sh controller.sh >controller.log 2>&1 & echo $!').strip()
        time.sleep(13)
    finally:
        # Idempotent host-side disarm supplements the native total=1 limit,
        # controller trap and independent five-second watchdog.
        if report['armed']:
            try:
                with connect() as f:
                    query(f, DISARM)
                    report['final_state'] = query(f, STATE)
                    report['final_pids'] = query(f, 'pidof camera-service camera-gui').split()
                    report['stable_service_and_gui'] = report['final_pids'] == [service, gui]
                    report['original_liveview_restored'] = check_state(report['final_state'])
                    query(f, f'chmod 644 {remote}/*.log {remote}/*.txt')
            except Exception as e:
                report['cleanup_error'] = repr(e)
            for name in ('controller.log', 'watchdog.log', 'events.log',
                         'final-state.txt', 'final-pids.txt', 'dump-files.txt'):
                try:
                    adb('pull', remote + '/' + name, str(output / name))
                except Exception as e:
                    report.setdefault('pull_errors', {})[name] = repr(e)
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print(output)


if __name__ == '__main__':
    main()
