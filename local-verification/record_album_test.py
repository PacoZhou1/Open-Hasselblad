"""One bounded, explicit real-camera recording -> native album UI experiment.

The candidate's existing clicked handlers request one three-second capture.
This proves programmatic UI integration, not physical touch or shutter input.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import time
from types import SimpleNamespace
from urllib.request import Request, urlopen

import gui_session as gs
import screen_audit as sa
from factory_session import connect
from highres_one_frame import STATE, check_state
from album_product_test import BRIDGE, BRIDGE_SHA, REMOTE, SERIAL


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--package', type=Path, required=True)
    ap.add_argument('--lease-module', type=Path,
                    default=Path('native-video/simulator/evidence/record-album-qa/make_lease.py'))
    ap.add_argument('--execute', action='store_true')
    args = ap.parse_args()
    package = args.package.resolve()
    meta = gs.verify_package(package)
    if meta['runid'] not in ('native-record-album-a', 'native-record-album-b') or meta['seconds'] != 85:
        raise ValueError('Requires the frozen candidate and independent 85-second session')
    spec = importlib.util.spec_from_file_location('record_lease', args.lease_module.resolve())
    lease_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(lease_module)
    # Offline candidate/hash validation; this synthetic value is never published.
    validation_lease = lease_module.make(package, 1000, 1000, True)
    if validation_lease['runId'] != meta['runid']:
        raise ValueError('Lease/candidate run ID mismatch')
    if not args.execute:
        print(json.dumps({'prepared_only': True, 'device_contacted': False, 'package': str(package)}))
        return 0
    raise RuntimeError('EXECUTION_HOLD: blackbox cleanup removed the run, lease and recovery state in b. '
                       'Move control/recovery state and bulk audit files before another device run.')
    out = package / 'record-qa'
    out.mkdir(exist_ok=False)
    run = meta['runid']
    remote = REMOTE + '/runs/' + run
    token = Path('native-video/outputs/runtime/session.token').read_text().strip()
    report = {'runId': run, 'passed': False, 'physical_input_verified': False}
    bridge_id = None
    deployed = audit = False

    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    def api(path, data=None):
        req = Request('http://127.0.0.1:18762' + path,
                      data=None if data is None else json.dumps(data).encode(),
                      headers={'X-X2V-Token': token, 'Content-Type': 'application/json'})
        return json.loads(urlopen(req, timeout=3).read())

    def identity(f, pid):
        if not str(pid).isdigit():
            raise ValueError('Non-numeric PID')
        raw = f.factory_shell(f'readlink /proc/{pid}/exe;cat /proc/{pid}/stat', capture_ms=3000)
        lines = raw.splitlines()
        return {'pid': str(pid), 'exe': lines[0], 'starttime': lines[1].split()[21], 'raw': raw}

    def events():
        raw = gs.adb('shell', 'cat ' + remote + '/record-events.log')
        (out / 'events.log').write_text(raw)
        for tag, key in [('X2V_RECORD_ALBUM_QA ', 'events'), ('X2V_CONTROL ', 'controls')]:
            rows = []
            for ln in raw.splitlines():
                if tag in ln:
                    try:
                        rows.append(json.JSONDecoder().raw_decode(ln.split(tag, 1)[1])[0])
                    except ValueError:
                        pass
            report[key] = rows
        report['qml_errors'] = [ln for ln in raw.splitlines() if re.search(r'(ReferenceError|TypeError):', ln)]
        return report['events']

    def disable():
        p = out / 'disabled.json'
        p.write_text('{"enabled":false,"expiresAtMs":0}')
        gs.adb('push', str(p), REMOTE + '/record-album-qa.json')

    try:
        with connect() as f:
            report['before'] = f.factory_shell(STATE, capture_ms=5000)
            if not check_state(report['before']):
                raise RuntimeError('Original liveview is not healthy')
            if f.factory_shell('pidof x2v_session_bridge_20261011d || true').strip():
                raise RuntimeError('Existing bridge is not owned by this experiment')
            if f.factory_shell('sha256sum ' + BRIDGE).split()[0] != BRIDGE_SHA:
                raise RuntimeError('Bridge hash differs')
            report['service_before'] = f.factory_shell('pidof camera-service').strip()
            command = f'toybox nohup timeout 180 {BRIDGE} --token-file {REMOTE}/session.token >{REMOTE}/{run}-bridge.log 2>&1 & echo $!'
            if len(command.encode()) > 231:
                raise ValueError('Bridge launch too long')
            report['bridge_launcher'] = f.factory_shell(command)
        time.sleep(.3)
        with connect() as f:
            bridge_id = identity(f, f.factory_shell('pidof x2v_session_bridge_20261011d').strip())
            if bridge_id['exe'] != BRIDGE:
                raise RuntimeError('Bridge identity mismatch')
        report['bridge_identity'] = bridge_id
        gs.adb('forward', 'tcp:18762', 'tcp:18761')
        report['initial_bridge'] = api('/state')
        if (report['initial_bridge']['phase'] not in ('idle', 'saved') or
                not report['initial_bridge']['rtp_confirmed_off'] or report['initial_bridge']['receiver_alive']):
            raise RuntimeError('Bridge is not idle')
        report['catalog_before'] = api('/catalog')
        disable()
        started_ms = int(gs.adb('shell', 'date +%s').strip()) * 1000
        deployed = True
        gs.deploy(SimpleNamespace(package=package))
        report['initial_gui'] = gs.status_data(run)
        if report['initial_gui']['phase'] != 'running':
            raise RuntimeError('Temporary GUI not running')
        with connect() as f:
            report['gui_identity'] = identity(f, f.factory_shell('pidof camera-gui').strip())
            watchdog = report['initial_gui']['files']['watchdog.identity'].split()
            report['watchdog_identity'] = identity(f, watchdog[0])
            if report['watchdog_identity']['starttime'] != watchdog[1]:
                raise RuntimeError('Independent watchdog identity differs')
            pid = report['gui_identity']['pid']
            command = f'cd {remote};(timeout 85 logcat --pid={pid} -v epoch -T 1 camera-gui:I "*:S"|head -c8388608)>record-events.log 2>&1 & echo $!'
            if len(command.encode()) > 231:
                raise ValueError('Logger command too long')
            logger_pid = f.factory_shell(command).strip()
            report['logger_identity'] = identity(f, logger_pid)
        report['audit'] = sa.start_device(SERIAL, run, seconds=45, fps=2, format='bmp')
        audit = True
        now_ms = int(gs.adb('shell', 'date +%s').strip()) * 1000
        lease = lease_module.make(package, started_ms, now_ms, True)
        report['lease'] = lease
        p = out / 'lease.json'
        p.write_text(json.dumps(lease))
        gs.adb('push', str(p), REMOTE + '/record-album-qa.json.tmp')
        gs.adb('shell', f'mv {REMOTE}/record-album-qa.json.tmp {REMOTE}/record-album-qa.json')
        deadline = time.monotonic() + (lease['expiresAtMs'] - now_ms) / 1000
        while time.monotonic() < deadline:
            rows = events()
            if report['qml_errors']:
                raise RuntimeError('QML runtime error')
            failed = next((e for e in rows if e.get('event') == 'failed'), None)
            if failed:
                raise RuntimeError('UI flow failed: ' + json.dumps(failed))
            if any(e.get('event') == 'passed' and e.get('runId') == run for e in rows):
                break
            time.sleep(.4)
        else:
            raise RuntimeError('UI flow did not complete before lease expiry')
        saved = next(e for e in rows if e['event'] == 'new_saved_clip')['detail']
        played = next(e for e in rows if e['event'] == 'player_playing')['detail']['sessionId']
        releases = [e for e in report['controls'] if e.get('event') == 'playback_native'
                    and e.get('detail', {}).get('stage') == 'release_complete'
                    and e['detail'].get('sessionId') == played]
        if not releases:
            raise RuntimeError('Native release_complete missing for actual player session')
        report['new_clip'] = saved
        report['player_release'] = releases[-1]
        report['catalog_after'] = api('/catalog')
        ids = {x['id'] for x in report['catalog_before']['clips']}
        if saved['id'] in ids or not 0 < saved['durationMs'] <= 5000:
            raise RuntimeError('Clip identity/duration bounds failed')
        report['flow_completed'] = True
    except BaseException as exc:
        report['failure'] = repr(exc)
    finally:
        try:
            disable()
            if audit:
                sa.stop_device(SERIAL)
        except BaseException as exc:
            report['lease_cleanup_error'] = repr(exc)
        if deployed:
            try:
                time.sleep(.4)
                events()
            except BaseException as exc:
                report['final_log_error'] = repr(exc)
            # Missing logging must never prevent an independent recovery attempt.
            try:
                gs.stop(SimpleNamespace(runid=run))
                report['restoration'] = gs.status_data(run)
            except BaseException as exc:
                report['gui_cleanup_error'] = repr(exc)
        try:
            if bridge_id:
                report['finally_stop'] = api('/stop', {})
                deadline = time.monotonic() + 10
                while time.monotonic() < deadline:
                    state = api('/state')
                    if state['rtp_confirmed_off'] and not state['receiver_alive']:
                        break
                    time.sleep(.2)
                report['bridge_final'] = state
                if not state['rtp_confirmed_off'] or state['receiver_alive']:
                    raise RuntimeError('Producer/receiver stop unconfirmed; refusing to kill owner')
                with connect() as f:
                    current = identity(f, bridge_id['pid'])
                    if current['exe'] != bridge_id['exe'] or current['starttime'] != bridge_id['starttime']:
                        raise RuntimeError('Bridge ownership changed')
                    f.factory_shell('kill -TERM ' + bridge_id['pid'])
                    report['owned_bridge_stop_sent'] = True
            with connect() as f:
                state = f.factory_shell(STATE, capture_ms=5000)
                if 'E_LiveViewState_Off(0)' in state and 'E_LiveviewTransportMode_None(0)' in state:
                    f.factory_shell('timeout 4 odindb-send -s camera -m set_live_view true', capture_ms=5000)
                    time.sleep(.5)
                report['final_state'] = f.factory_shell(STATE, capture_ms=5000)
                for name, cmd in [('service_after', 'pidof camera-service'), ('gui_after', 'pidof camera-gui'),
                                  ('gui_init_after', 'getprop init.svc.camera-gui'),
                                  ('bridge_after', 'pidof x2v_session_bridge_20261011d || true'),
                                  ('system_mount', 'mount | grep " /system "')]:
                    report[name] = f.factory_shell(cmd, capture_ms=5000).strip()
            gs.adb('forward', '--remove', 'tcp:18762')
            report['forward_removed'] = True
        except BaseException as exc:
            report['camera_cleanup_error'] = repr(exc)
        save()
    # Validate the new media after GUI/producer restoration, never an old clip.
    try:
        if report.get('flow_completed'):
            remote_clip = report['new_clip']['path']
            if not re.fullmatch(r'/mnt/media_rw/ssd/X2V_VIDEO/X2V_[0-9_]+\.mp4', remote_clip):
                raise ValueError('Unexpected clip path')
            media = out / 'new-clip.mp4'
            gs.adb('pull', remote_clip, str(media), timeout=30)
            with connect() as f:
                digest = f.factory_shell('sha256sum ' + remote_clip, capture_ms=6000).split()[0]
            if gs.sha(media) != digest:
                raise RuntimeError('Device/host media hash differs')
            probe = subprocess.run(['ffprobe', '-v', 'error', '-count_frames', '-show_streams',
                                    '-show_format', '-of', 'json', str(media)],
                                   check=True, capture_output=True, text=True, timeout=20)
            receipt = json.loads(probe.stdout)
            video = next(s for s in receipt['streams'] if s['codec_type'] == 'video')
            if not (video['codec_name'] == 'h264' and video['width'] == 1300 and video['height'] == 970
                    and 0 < float(receipt['format']['duration']) <= 5 and int(video['nb_read_frames']) > 0):
                raise RuntimeError('Unexpected recording media properties')
            decode = subprocess.run(['ffmpeg', '-v', 'error', '-xerror', '-i', str(media),
                                     '-map', '0:v:0', '-f', 'null', '-'], capture_output=True,
                                    text=True, timeout=30)
            (out / 'decode.log').write_text(decode.stdout + decode.stderr)
            if decode.returncode or decode.stderr.strip():
                raise RuntimeError('Strict full-frame decode failed')
            receipt.update(sha256=digest, strict_full_decode=True, decode_exit=decode.returncode)
            (out / 'media.json').write_text(json.dumps(receipt, indent=2) + '\n')
            report['media_passed'] = True
            report['media_sha256'] = digest
    except BaseException as exc:
        report['media_error'] = repr(exc)
    report['passed'] = bool(report.get('flow_completed') and report.get('media_passed') and
        not report.get('failure') and not report.get('qml_errors') and
        not report.get('lease_cleanup_error') and not report.get('final_log_error') and
        not report.get('gui_cleanup_error') and not report.get('camera_cleanup_error') and
        report.get('forward_removed') and report.get('gui_init_after') == 'running' and
        report.get('bridge_after') == '' and report.get('restoration', {}).get('phase') == 'restored' and
        check_state(report.get('final_state', '')) and report.get('service_after') == report.get('service_before'))
    save()
    print(json.dumps({'passed': report['passed'], 'report': str(out / 'report.json'),
                      'failure': report.get('failure'), 'media_error': report.get('media_error')}, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
