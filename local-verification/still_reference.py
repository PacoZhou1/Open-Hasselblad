"""One native photograph as a full-image reference; explicit --execute only.

Uses published do_exposure_extended2, ForceSingleExposure, 6000ms timeout.
No setting/calibration changes; independent stock stop_session at ten seconds.
The resulting photograph is retained in its original native storage location.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import time
from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
IDLE = ('odindb-send -s camera -p drive_mode,exposure_status,'
        'exposures_processing_counter,do_exposure_active,do_exposure_extended_active,'
        'do_exposure_extended2_active,find_focus_active,zoom_active')
STORAGE = ('odindb-send -s storage -p camera_file_index,save_folder,'
           'storage_processing_counter,storage_status,file_saved')
STOP = 'timeout 4 odindb-send -s camera -m stop_session'
SHOT = 'timeout 8 odindb-send -s camera -m do_exposure_extended2 true 4 6000'

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--execute', action='store_true')
    args = p.parse_args()
    if not args.execute:
        print('Offline plan: one native photograph, ForceSingleExposure, 6s native timeout, 10s independent stop.')
        return
    run = datetime.now().strftime('still-reference-%H%M%S')
    out = ROOT / 'native-video/outputs/highres-source-20261011' / run
    out.mkdir()
    remote = '/blackbox/x2v-native-20261011/runs/' + run
    report = {'events': [], 'dispatched': False, 'remote': remote}
    def query(f, command, ms=6000):
        if len(command.encode()) > 231:
            raise ValueError('Command too long')
        value = f.factory_shell(command, capture_ms=ms)
        report['events'].append({'command': command, 'output': value})
        return value
    try:
        with connect() as f:
            pids = [query(f, 'pidof '+name).strip()
                    for name in ('camera-service', 'camera-gui')]
            if len(pids) != 2 or not all(v.isdigit() for v in pids):
                raise RuntimeError('Expected original camera processes')
            if not check_state(query(f, STATE)):
                raise RuntimeError('Expected normal liveview')
            idle = query(f, IDLE)
            if not all(s in idle for s in ('E_DriveModes_Single(0)', 'E_ExposureStatus_None(0)',
                       'exposures_processing_counter = 0', 'do_exposure_active = false',
                       'do_exposure_extended_active = false', 'do_exposure_extended2_active = false',
                       'find_focus_active = false', 'zoom_active = false')):
                raise RuntimeError('Existing camera activity')
            report['storage_before'] = query(f, STORAGE)
            if 'storage_processing_counter = 0' not in report['storage_before']:
                raise RuntimeError('Storage busy')
            query(f, 'df -k /mnt/media_rw/ssd /blackbox')
            marker = 'NEW_OWNED_DIRECTORY_'+run
            if query(f, f'test ! -e {remote} && mkdir {remote} && echo {marker}').strip() != marker:
                raise RuntimeError('Remote output directory was not exclusively created')
        script = f'''#!/system/bin/sh
set -eu
cd {remote}
same_service() {{ [ "$(pidof camera-service)" = "{pids[0]}" ]; }}
cleanup() {{ same_service && {STOP} >cleanup.log 2>&1; }}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
[ "$(pidof camera-service)" = "{pids[0]}" ] || exit 31
toybox nohup sh -c 'sleep 10;[ "$(pidof camera-service)" = "{pids[0]}" ] && {STOP}' >watchdog.log 2>&1 &
echo watchdog_pid=$!
(timeout 16 logcat -T 1 -v epoch | head -c16777216) >events.log 2>&1 &
sleep 0.3
{SHOT}
echo NATIVE_SINGLE_ACK
sleep 8
{IDLE} >camera-after.txt
{STORAGE} >storage-after.txt
{STATE} >state-after.txt
pidof camera-service camera-gui >pids-after.txt
echo CONTROLLER_FINISHED
'''
        local = out / 'controller.sh'
        local.write_text(script)
        adb('push', str(local), remote + '/controller.sh')
        with connect() as f:
            if query(f, 'sha256sum ' + remote + '/controller.sh').split()[0] != hashlib.sha256(local.read_bytes()).hexdigest():
                raise RuntimeError('Upload hash mismatch')
            report['dispatched'] = True
            report['pid'] = query(f, f'cd {remote};toybox nohup sh controller.sh >controller.log 2>&1 & echo $!')
        time.sleep(18)
    finally:
        if report['dispatched']:
            try:
                with connect() as f:
                    # Native stop_session returns Canceled/"Ignore stop session"
                    # when the finite session already ended. Preserve that reply,
                    # then always inspect actual state instead of aborting cleanup.
                    try:
                        if query(f, 'pidof camera-service').strip() == pids[0]:
                            query(f, STOP)
                        else:
                            report['stop_skipped'] = 'camera-service identity changed'
                    except Exception as exc:
                        report['stop_reply_error'] = repr(exc)
                    report['camera_after'] = query(f, IDLE)
                    report['storage_after'] = query(f, STORAGE)
                    report['state_after'] = query(f, STATE)
                    report['final_pids'] = [query(f, 'pidof '+name).strip()
                                            for name in ('camera-service', 'camera-gui')]
                    report['same_processes'] = report['final_pids'] == pids
                    report['restored'] = check_state(report['state_after'])
                    report['system_mount'] = query(f, 'mount | grep " /system "')
                    query(f, f'chmod 644 {remote}/*.log {remote}/*.txt')
                for name in ('controller.log', 'watchdog.log', 'cleanup.log', 'events.log',
                             'camera-after.txt', 'storage-after.txt', 'state-after.txt', 'pids-after.txt'):
                    adb('pull', remote + '/' + name, str(out / name))
            except Exception as exc:
                report['recovery_error'] = repr(exc)
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print(out)

if __name__ == '__main__':
    main()
