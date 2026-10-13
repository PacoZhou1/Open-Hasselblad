"""Root-only, zero-file test of the original full-FOV RAW stream lifecycle.

Default is offline. Does not use camera-expose, import a shared destination,
enable a dump, capture a photograph, encode, or change firmware/startup files.
Native operation failure is not a successful recovery; all original replies and
watchdog observations are retained. A client timeout never proves cancellation.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import time

from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, check_state

ROOT = Path(__file__).resolve().parents[1]
# The stock profile produced zero frames and crashed in native sensor teardown.
# Keep its controller available for offline fault analysis, but prevent accidental
# replay until a separately reviewed implementation resolves the actual fault.
EXECUTION_HOLD = ('group12 failed on device in g12-life-001048: no RAW frames, '
                  'sensor-interface mismatch, native teardown assertion; '
                  'camera-service restarted and ordinary LiveView recovered')
BASE = '/blackbox/x2v-native-20261011/runs/'
GROUP = 'odindb-send -s camera -p stream_group'
BUSY = ('odindb-send -s camera -p setup_dcam_stream_group_active,'
        'teardown_current_dcam_stream_group_active,start_dcam_stream_active,stop_dcam_stream_active,set_live_view_active')
BUSY_NAMES = ('setup_dcam_stream_group_active', 'teardown_current_dcam_stream_group_active',
              'start_dcam_stream_active', 'stop_dcam_stream_active', 'set_live_view_active')
IDLE = ('odindb-send -s camera -p do_exposure_active,do_exposure_extended_active,'
        'do_exposure_extended2_active,find_focus_active,exposure_status,exposures_processing_counter,zoom_active')
IDLE_LINES = ('do_exposure_active = false', 'do_exposure_extended_active = false',
              'do_exposure_extended2_active = false', 'find_focus_active = false',
              'exposure_status = E_ExposureStatus_None(0)', 'exposures_processing_counter = 0', 'zoom_active = false')


def make_controller(remote, service):
    # All substitutions are root-owned paths and a verified decimal PID.
    return f'''#!/system/bin/sh
set -u
cd {remote} || exit 30
x2inbody=0
x2gateowned=0
same_service() {{ [ "$(pidof camera-service)" = "{service}" ]; }}
group() {{ timeout 5 {GROUP}; }}
unlock() {{
 if [ "$x2gateowned" = 1 ];then
  rm operation.lock/owner
  rmdir operation.lock
  x2gateowned=0
 fi
}}
lock() {{
 x2tries=0
 while ! mkdir operation.lock 2>/dev/null;do
  # Reclaim only a proven dead/reused owner in this unique run directory.
  if [ -f operation.lock/owner ];then
   read x2ownerpid x2ownerstart <operation.lock/owner
   x2current=$(awk '{{print $22}}' /proc/$x2ownerpid/stat 2>/dev/null)
   if [ -n "$x2ownerstart" ] && [ "$x2current" != "$x2ownerstart" ];then
    rm operation.lock/owner && rmdir operation.lock || return 40
   fi
  fi
  x2tries=$((x2tries+1))
  [ "$x2tries" -lt 80 ] || return 41
  sleep 0.2
 done
 x2start=$(awk '{{print $22}}' /proc/$$/stat) || return 40
 echo "$$ $x2start" >operation.lock/owner
 x2gateowned=1
}}
op() {{
 if [ "$x2inbody" = 1 ] && [ -f abort ];then return 61;fi
 echo "OP_BEGIN $*"
 if timeout 12 odindb-send -s camera -m "$@";then x2rc=0;else x2rc=$?;fi
 echo "OP_END $* rc=$x2rc"
 if [ "$x2inbody" = 1 ] && [ -f abort ];then return 61;fi
 return "$x2rc"
}}
restore_body() {{
 same_service || {{ echo SERVICE_CHANGED_NO_FURTHER_COMMAND; return 42; }}
 # Do not race a pending native operation after a client timeout.
 x2wait=0
 while :;do
  timeout 5 {BUSY} >restore-busy.txt 2>&1 || return 43
  x2allfalse=1
  for x2field in {' '.join(BUSY_NAMES)};do
   grep -Eq "^$x2field = (true|false)$" restore-busy.txt || return 43
   grep -q "^$x2field = false$" restore-busy.txt || x2allfalse=0
  done
  if [ "$x2allfalse" = 1 ];then break;fi
  x2wait=$((x2wait+1))
  [ "$x2wait" -lt 12 ] || {{ echo NATIVE_OPERATION_STILL_PENDING;return 44; }}
  sleep 1
 done
 group >restore-group.txt || return 45
 if grep -q 'E_StreamGroup_LiveviewZoomFullFovRawCalib(12)' restore-group.txt;then
  op stop_dcam_stream 1 || return 46
  group >restore-stopped-group.txt || return 47
  if grep -q 'E_StreamGroup_LiveviewZoomFullFovRawCalib(12)' restore-stopped-group.txt;then
   op teardown_current_dcam_stream_group || return 47
  elif ! grep -q 'E_StreamGroup_Max(255)' restore-stopped-group.txt;then return 47;fi
 elif ! grep -Eq 'E_StreamGroup_(Still16bit\\(0\\)|Max\\(255\\))' restore-group.txt;then
  echo UNEXPECTED_GROUP_NO_FURTHER_COMMAND;return 48
 fi
 same_service || return 49
 op set_live_view true || return 50
 timeout 5 {STATE} >restored-state.txt 2>&1 || return 51
 grep -q 'E_LiveViewState_Active(1)' restored-state.txt || return 52
 grep -q 'E_LiveviewTransportMode_None(0)' restored-state.txt || return 53
 grep -q 'E_StreamGroup_Still16bit(0)' restored-state.txt || return 54
 echo RESTORED_NORMAL
 touch restored
}}
restore() {{
 [ ! -f restored ] || return 0
 touch abort
 lock || return $?
 x2inbody=0
 if restore_body;then x2restorerc=0;else x2restorerc=$?;fi
 unlock || return 55
 return "$x2restorerc"
}}
if [ "${{1:-}}" = restore ];then
 restore >watchdog-restore.log 2>&1
 echo $? >watchdog-restore.rc
 exit
fi
finish() {{
 x2bodyrc=$?
 set +e
 echo "$x2bodyrc" >body.rc
 unlock
 if restore >restore.log 2>&1;then x2finalrc=0;else x2finalrc=$?;fi
 echo "$x2finalrc" >restore.rc
 touch finished
}}
trap finish EXIT
trap 'exit 60' HUP INT TERM
set -e
same_service
lock
x2inbody=1
# Independent guard invokes only original APIs; it never kills camera-service.
toybox nohup sh -c 'sleep 30;sh {remote}/controller.sh restore' >watchdog.log 2>&1 &
echo $! >watchdog.pid
(timeout 48 logcat -v epoch -T 1 camera-service:I DUSS51:I '*:S'|head -c16777216)>events.log 2>&1 &
op set_live_view false
timeout 5 {STATE} >off-state.txt
grep -q 'E_LiveViewState_Off(0)' off-state.txt
grep -q 'E_LiveviewTransportMode_None(0)' off-state.txt
group >off-group.txt
if grep -q 'E_StreamGroup_Still16bit(0)' off-group.txt;then
 op teardown_current_dcam_stream_group
elif ! grep -q 'E_StreamGroup_Max(255)' off-group.txt;then
 echo UNEXPECTED_GROUP_BEFORE_SETUP
 exit 62
fi
group >empty-group.txt
grep -q 'E_StreamGroup_Max(255)' empty-group.txt
[ ! -f abort ]
op setup_dcam_stream_group 12
group >setup-group.txt
grep -q 'E_StreamGroup_LiveviewZoomFullFovRawCalib(12)' setup-group.txt
[ ! -f abort ]
op start_dcam_stream 1
sleep 2
[ ! -f abort ]
cp /data/dji_debug_camera.xml group12-debug.xml
timeout 5 {STATE} >running-state.txt
grep -q 'E_StreamGroup_LiveviewZoomFullFovRawCalib(12)' running-state.txt
grep -q 'E_LiveViewState_Off(0)' running-state.txt
grep -q 'E_LiveviewTransportMode_None(0)' running-state.txt
op stop_dcam_stream 1
group >raw-stopped-group.txt
if grep -q 'E_StreamGroup_LiveviewZoomFullFovRawCalib(12)' raw-stopped-group.txt;then
 op teardown_current_dcam_stream_group
elif ! grep -q 'E_StreamGroup_Max(255)' raw-stopped-group.txt;then
 echo UNEXPECTED_GROUP_AFTER_RAW_STOP
 exit 63
fi
group >stopped-group.txt
grep -q 'E_StreamGroup_Max(255)' stopped-group.txt
echo ZERO_DUMP_LIFECYCLE_COMPLETE
'''


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--execute', action='store_true')
    a = p.parse_args()
    if not a.execute:
        print('Offline only: stock LiveView off; teardown; group12 setup; RAW stream1 start/2s/stop; teardown; normal LiveView restore.')
        return
    if EXECUTION_HOLD:
        p.error('Device execution disabled: '+EXECUTION_HOLD)
    run = datetime.now().strftime('g12-life-%H%M%S')
    out = ROOT / 'native-video/outputs/highres-source-20261011' / run
    out.mkdir()
    remote = BASE + run
    report = {'run': run, 'remote': remote, 'dispatched': False, 'passed': False, 'queries': []}

    def query(f, c):
        if len(c.encode()) > 231:
            raise ValueError('Factory command too long')
        s = f.factory_shell(c, capture_ms=6000)
        report['queries'].append({'command': c, 'output': s})
        return s

    try:
        with connect() as f:
            report['before'] = query(f, STATE)
            if not check_state(report['before']):
                raise RuntimeError('Expected stock liveview baseline')
            report['pids_before'] = [query(f, 'pidof '+name).strip()
                                     for name in ('camera-service', 'camera-gui')]
            if len(report['pids_before']) != 2 or not all(x.isdigit() for x in report['pids_before']):
                raise RuntimeError('Unexpected camera process identity')
            idle = query(f, IDLE)
            if any(x not in idle.splitlines() for x in IDLE_LINES):
                raise RuntimeError('Camera activity is present')
            busy = query(f, BUSY).splitlines()
            if any(name+' = false' not in busy for name in BUSY_NAMES):
                raise RuntimeError('Another native lifecycle request is active')
            report['format_before'] = query(f, 'odindb-send -s camera -p image_format,image_postprocessing_current')
            marker = 'NEW_OWNED_DIRECTORY_'+run
            if query(f, f'test ! -e {remote} && mkdir {remote} && echo {marker}').strip() != marker:
                raise RuntimeError('Remote output directory was not exclusively created')
        script = out / 'controller.sh'
        script.write_text(make_controller(remote, report['pids_before'][0]))
        adb('push', str(script), remote + '/controller.sh')
        with connect() as f:
            if query(f, 'sha256sum '+remote+'/controller.sh').split()[0] != hashlib.sha256(script.read_bytes()).hexdigest():
                raise RuntimeError('Controller hash differs')
            report['dispatched'] = True
            report['launcher'] = query(f, f'(cd {remote} && toybox nohup sh controller.sh >controller.log 2>&1) & echo $!')
        # ADB reads only; the independent device guard is already running.
        end = time.monotonic()+55
        while time.monotonic() < end:
            if adb('shell', f'test -f {remote}/finished && test -f {remote}/watchdog-restore.rc && echo finished || true').strip() == 'finished':
                break
            time.sleep(1)
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        if report['dispatched']:
            try:
                adb('pull', remote, str(out/'device'))
                with connect() as f:
                    report['after'] = query(f, STATE)
                    report['pids_after'] = [query(f, 'pidof '+name).strip()
                                            for name in ('camera-service', 'camera-gui')]
                    report['format_after'] = query(f, 'odindb-send -s camera -p image_format,image_postprocessing_current')
                    report['busy_after'] = query(f, BUSY)
                    report['idle_after'] = query(f, IDLE)
                    report['frames_1'] = query(f, 'odindb-send -s camera -m get_frame_count')
                    time.sleep(.4)
                    report['frames_2'] = query(f, 'odindb-send -s camera -m get_frame_count')
                    report['system_mount'] = query(f, 'mount | grep " /system "')
                dev = out/'device'
                first = re.fullmatch(r'count = ([0-9]+)\s*', report['frames_1'])
                second = re.fullmatch(r'count = ([0-9]+)\s*', report['frames_2'])
                report['frames_increasing'] = bool(first and second and int(second[1]) > int(first[1]))
                report['passed'] = (check_state(report['after']) and report['pids_before']==report['pids_after']
                    and report['format_before']==report['format_after']
                    and report['frames_increasing'] and '(ro,' in report['system_mount']
                    and all(name+' = false' in report['busy_after'].splitlines() for name in BUSY_NAMES)
                    and all(line in report['idle_after'].splitlines() for line in IDLE_LINES)
                    and (dev/'body.rc').read_text().strip()=='0'
                    and (dev/'restore.rc').read_text().strip()=='0'
                    and (dev/'watchdog-restore.rc').read_text().strip()=='0'
                    and (dev/'restored').exists()
                    and 'ZERO_DUMP_LIFECYCLE_COMPLETE' in (dev/'controller.log').read_text())
            except BaseException as exc:
                report['readback_error'] = repr(exc)
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps({'passed': report['passed'], 'report': str(out/'report.json'), 'failure': report.get('failure')}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
