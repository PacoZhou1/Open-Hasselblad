"""Observe stock focus magnification for 3s, then restore; no RAW dump.

The original UI calls Camera.doSet_zoom(true/false). Default is a dry run.
No zoom point/level, sensor profile or driver/register changes are made.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import time
from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, DISARM, check_state, global_dump_clearance

ROOT = Path(__file__).resolve().parents[1]
ZOOM_OFF = 'timeout 4 odindb-send -s camera -m set_zoom false'
ZOOM_ON = 'timeout 4 odindb-send -s camera -m set_zoom true'
ZOOM_STATE = 'timeout 4 odindb-send -s camera -p zoom_active,zoom_level,zoom_point'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if not args.execute:
        print('No device access. Plan: stock zoom on; observe 3s; stock zoom off; independent 8s restoration.')
        return
    identity = datetime.now().strftime('zoom-source-%H%M%S')
    out = ROOT / 'native-video/outputs/highres-source-20261011' / identity
    out.mkdir()
    remote = '/blackbox/x2v-native-20261011/runs/' + identity
    report = {'events': [], 'dispatched': False, 'remote': remote}

    def query(f, cmd, ms=1000):
        if len(cmd.encode()) > 231:
            raise ValueError('Factory command exceeds transport bound')
        val = f.factory_shell(cmd, capture_ms=ms)
        report['events'].append({'command': cmd, 'output': val})
        return val

    try:
        with connect() as f:
            pids = query(f, 'pidof camera-service camera-gui').split()
            if len(pids) != 2 or not all(x.isdigit() for x in pids):
                raise RuntimeError('Expected original service and GUI')
            service, gui = pids
            if not check_state(query(f, STATE)):
                raise RuntimeError('Expected normal still liveview')
            if 'zoom_active = false' not in query(f, ZOOM_STATE):
                raise RuntimeError('Will not override an existing user zoom')
            query(f, DISARM)
            report['global_dump_clearance'] = global_dump_clearance(f, service, query)
            query(f, 'timeout 4 odindb-send -s camera -m get_frame_count')
            query(f, f'test ! -e {remote} && mkdir {remote}')
        script = f'''#!/system/bin/sh
set -eu
cd {remote}
cleanup() {{ {ZOOM_OFF} || echo RESTORE_FAILED; }}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
[ "$(pidof camera-service)" = "{service}" ] || exit 31
toybox nohup sh -c 'sleep 8;{ZOOM_OFF}' >watchdog.log 2>&1 &
echo watchdog_pid=$!
(timeout 13 logcat --pid={service} -v epoch -T 1 | head -c12582912) >events.log 2>&1 &
ready_count=0
while ! grep -q 'beginning of' events.log; do
 ready_count=$((ready_count+1))
 [ "$ready_count" -lt 15 ] || exit 33
 sleep 0.1
done
{ZOOM_ON}
echo ZOOM_REQUEST_ACK
{ZOOM_STATE} >zoom-state.txt
sleep 3
{ZOOM_OFF}
echo ZOOM_RESTORED
sleep 2
{STATE} >final-state.txt
{ZOOM_STATE} >>final-state.txt
pidof camera-service camera-gui >final-pids.txt
echo CONTROLLER_FINISHED
'''
        local = out / 'controller.sh'
        local.write_text(script)
        adb('push', str(local), remote + '/controller.sh')
        with connect() as f:
            if query(f, 'sha256sum ' + remote + '/controller.sh').split()[0] != hashlib.sha256(local.read_bytes()).hexdigest():
                raise RuntimeError('Upload hash differs')
            report['dispatched'] = True
            report['pid'] = query(f, f'cd {remote};toybox nohup sh controller.sh >controller.log 2>&1 & echo $!')
        time.sleep(14)
    finally:
        if report['dispatched']:
            try:
                with connect() as f:
                    query(f, ZOOM_OFF)
                    report['final_state'] = query(f, STATE)
                    report['zoom_state'] = query(f, ZOOM_STATE)
                    report['final_pids'] = query(f, 'pidof camera-service camera-gui').split()
                    report['same_service_and_gui'] = report['final_pids'] == pids
                    report['restored'] = check_state(report['final_state']) and 'zoom_active = false' in report['zoom_state']
                    query(f, 'timeout 4 odindb-send -s camera -m get_frame_count')
                    query(f, f'chmod 644 {remote}/*.log {remote}/*.txt')
                for name in ('controller.log', 'watchdog.log', 'events.log', 'zoom-state.txt', 'final-state.txt', 'final-pids.txt'):
                    adb('pull', remote + '/' + name, str(out / name))
            except Exception as exc:
                report['recovery_error'] = repr(exc)
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print(out)


if __name__ == '__main__':
    main()
