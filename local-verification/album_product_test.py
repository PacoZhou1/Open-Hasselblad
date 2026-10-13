"""Bounded real merged-album QA; root is the only camera operator.

Explicit package argument deploys a temporary GUI with an independent watchdog.
Only browsing, selection and known low-resolution playback actions are sent.
No recording, photos, deletion, metadata edits or boot changes occur here.
"""
import argparse
import json
from pathlib import Path
import re
import time
from types import SimpleNamespace
from urllib.request import Request, urlopen
import gui_session as gs
import screen_audit as sa
from factory_session import connect
from highres_one_frame import STATE, check_state

SERIAL = '123456789ABCDEF'
REMOTE = '/blackbox/x2v-native-20261011'
BRIDGE = '/system/bin/x2v_session_bridge_20261011d'
BRIDGE_SHA = '4df4993e93b5136ad1d3c32597b0988027eb0881d3bd8e0e517da8ef608bfcea'

def current_photo_ready(events):
    """Require a fresh readiness reply for the actual current selection."""
    selections = [e for e in events if e.get('event') == 'selection']
    if not selections or selections[-1]['detail'].get('kind') != 'photo':
        return False
    selected = selections[-1]
    try:
        key = selected['detail']['key']
        if not key.startswith('photo:'):
            return False
        native_key = json.loads(key[6:])[2]
    except (KeyError, ValueError, IndexError, TypeError):
        return False
    replies = [e for e in events if e.get('event') == 'photo_ready'
               and e.get('timestampMs', -1) >= selected.get('timestampMs', 0)
               and e.get('detail', {}).get('key') == native_key]
    return bool(replies and replies[-1]['detail'].get('ready')
                and not replies[-1]['detail'].get('error'))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--package', required=True, type=Path)
    a = ap.parse_args()
    meta = gs.verify_package(a.package.resolve())
    run = meta['runid']
    out = a.package.resolve() / 'product-qa'
    out.mkdir(exist_ok=False)
    remote = REMOTE + '/runs/' + run
    report = {'runId': run, 'passed': False, 'actions': [], 'events': []}
    deployed = False
    bridge_id = None
    audit = False
    token = Path('native-video/outputs/runtime/session.token').read_text().strip()
    def api(path):
        return json.loads(urlopen(Request('http://127.0.0.1:18762'+path,
                          headers={'X-X2V-Token': token}), timeout=3).read())
    def identity(f, pid):
        return f.factory_shell(f'readlink /proc/{pid}/exe;cat /proc/{pid}/stat', capture_ms=1000)
    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    def read_events():
        raw = gs.adb('shell', 'cat '+remote+'/product-events.log')
        (out/'events.log').write_text(raw)
        events=[]
        for line in raw.splitlines():
            if 'X2V_ALBUM_UI ' in line:
                try: events.append(json.loads(line.split('X2V_ALBUM_UI ',1)[1]))
                except ValueError: pass
        report['events']=events
        controls=[]
        for line in raw.splitlines():
            if 'X2V_CONTROL ' in line:
                try: controls.append(json.loads(line.split('X2V_CONTROL ',1)[1]))
                except ValueError: pass
        report['controls']=controls
        report['qml_errors']=[line for line in raw.splitlines() if re.search(r'(ReferenceError|TypeError):',line)]
        return events
    def action(kind, delay=1.3):
        item={'enabled':True,'expiresAtMs':int(gs.adb('shell','date +%s').strip())*1000+10000,
              'loggerReady':True,'runId':'native-album-product','sequence':len(report['actions'])+1,'action':kind}
        p=out/'lease.json';p.write_text(json.dumps(item))
        gs.adb('push',str(p),REMOTE+'/album-ui-qa.json.tmp')
        gs.adb('shell',f'mv {REMOTE}/album-ui-qa.json.tmp {REMOTE}/album-ui-qa.json')
        report['actions'].append(item)
        time.sleep(delay)
        read_events()
        if report['qml_errors']: raise RuntimeError('QML runtime error; inspect events.log')
    def selected_kind():
        records=[e['detail'] for e in report['events'] if e['event']=='selection' and e['detail'].get('kind')]
        return records[-1]['kind'] if records else None
    def wait_for(predicate, seconds=12):
        end=time.monotonic()+seconds
        while time.monotonic()<end:
            read_events()
            if predicate():return True
            if report['qml_errors']:raise RuntimeError('QML runtime error')
            time.sleep(.5)
        return False
    def latest_qa():
        rows=[e['detail'] for e in report['events'] if e['event']=='qa_action']
        return rows[-1] if rows else {}
    try:
        with connect() as f:
            report['before']=f.factory_shell(STATE)
            if not check_state(report['before']): raise RuntimeError('Expected original liveview')
            if f.factory_shell('pidof x2v_session_bridge_20261011d || true').strip():
                raise RuntimeError('Existing bridge is not owned by this test')
            if f.factory_shell('sha256sum '+BRIDGE).split()[0]!=BRIDGE_SHA: raise RuntimeError('Bridge hash differs')
            report['service_before']=f.factory_shell('pidof camera-service').strip()
            # GUI deploy creates its run directory; bridge log has a separate unique filename.
            c=f'toybox nohup timeout 180 {BRIDGE} --token-file {REMOTE}/session.token >{REMOTE}/{run}-bridge.log 2>&1 & echo $!'
            if len(c.encode())>231: raise RuntimeError('Bridge command too long')
            report['bridge_launcher']=f.factory_shell(c)
        time.sleep(.4)
        with connect() as f:
            pid=f.factory_shell('pidof x2v_session_bridge_20261011d').strip()
            if not pid.isdigit():raise RuntimeError('Expected one owned bridge')
            value=identity(f,pid);parts=value.splitlines()[1].split()
            if value.splitlines()[0]!=BRIDGE:raise RuntimeError('Bridge identity mismatch')
            bridge_id=(pid,parts[21])
        gs.adb('forward','tcp:18762','tcp:18761')
        report['bridge_state']=api('/state')
        if report['bridge_state']['phase'] not in ('idle','saved','error') or not report['bridge_state']['rtp_confirmed_off']:
            raise RuntimeError('Bridge is active')
        report['catalog']=api('/catalog')
        deployed=True
        gs.deploy(SimpleNamespace(package=a.package.resolve()))
        report['initial_gui']=gs.status_data(run)
        if report['initial_gui']['phase']!='running':raise RuntimeError('Temporary GUI not running')
        with connect() as f:
            c=f'cd {remote};(timeout 85 logcat -v epoch -T 100 camera-gui:I "*:S"|head -c8388608)>product-events.log 2>&1 &'
            f.factory_shell(c,capture_ms=1000)
        report['audit']=sa.start_device(SERIAL,run,seconds=38,fps=2,format='bmp');audit=True
        action('browse',1.3)
        if not wait_for(lambda:any(e['event']=='album_rebuilt' and e['detail'].get('count',0)>2000 for e in report['events']),15):
            raise RuntimeError('Full native album did not load')
        action('snapshot')
        action('zoomOut',2)
        action('zoomOut',2)
        action('single',2)
        for _ in range(6):
            if selected_kind()=='video':break
            action('next',2)
        if selected_kind()!='video':raise RuntimeError('Could not select an actual clip')
        action('confirm',1.3)
        action('snapshot',1.3)
        if latest_qa().get('phase') not in ('playing','ended'):raise RuntimeError('No actual playback phase')
        report['playback_observed']=latest_qa()['phase']
        action('stop',1.5)
        action('snapshot',1.3)
        if latest_qa().get('phase')!='idle':raise RuntimeError('Player did not release to idle')
        for _ in range(6):
            if selected_kind()=='photo':break
            action('previous',2)
        if selected_kind()!='photo':raise RuntimeError('Could not return to actual photo')
        if not wait_for(lambda:current_photo_ready(report['events']),6):
            raise RuntimeError('Native photo identity handshake not observed')
        action('snapshot',1.3)
        report['flow_completed']=True
    except BaseException as exc:
        report['failure']=repr(exc)
    finally:
        try:
            p=out/'disabled.json';p.write_text('{"enabled":false,"expiresAtMs":0}')
            gs.adb('push',str(p),REMOTE+'/album-ui-qa.json')
            if audit:sa.stop_device(SERIAL)
            time.sleep(1.3)
            if deployed:
                read_events()
                gs.stop(SimpleNamespace(runid=run))
                report['restoration']=gs.status_data(run)
        except BaseException as exc:report['gui_cleanup_error']=repr(exc)
        try:
            if bridge_id:
                state=api('/state');report['bridge_final']=state
                if state['rtp_confirmed_off'] and state['phase'] in ('idle','saved','error'):
                    with connect() as f:
                        value=identity(f,bridge_id[0]);lines=value.splitlines()
                        if lines[0]==BRIDGE and lines[1].split()[21]==bridge_id[1]:
                            f.factory_shell('kill -TERM '+bridge_id[0])
                            report['owned_bridge_stop_sent']=True
            with connect() as f:
                state=f.factory_shell(STATE)
                if 'E_LiveViewState_Off(0)' in state and 'E_LiveviewTransportMode_None(0)' in state:
                    f.factory_shell('timeout 4 odindb-send -s camera -m set_live_view true')
                    time.sleep(.5)
                report['final_state']=f.factory_shell(STATE, capture_ms=5000)
                report['service_after']=f.factory_shell('pidof camera-service', capture_ms=5000).strip()
                report['gui_after']=f.factory_shell('pidof camera-gui', capture_ms=5000).strip()
                report['gui_init_after']=f.factory_shell('getprop init.svc.camera-gui', capture_ms=5000).strip()
                report['bridge_after']=f.factory_shell('pidof x2v_session_bridge_20261011d || true', capture_ms=5000).strip()
                report['system_mount']=f.factory_shell('mount | grep " /system "', capture_ms=5000)
            gs.adb('forward','--remove','tcp:18762')
            report['forward_removed']=True
        except BaseException as exc:report['camera_cleanup_error']=repr(exc)
        report['passed']=bool(report.get('flow_completed') and not report.get('qml_errors') and
                              not report.get('failure') and not report.get('gui_cleanup_error') and
                              not report.get('camera_cleanup_error') and report.get('forward_removed') and
                              report.get('gui_after') and report.get('gui_init_after')=='running' and
                              report.get('bridge_after')=='' and
                              report.get('bridge_final',{}).get('rtp_confirmed_off') and
                              report.get('restoration',{}).get('phase')=='restored' and check_state(report.get('final_state',''))
                              and report.get('service_before')==report.get('service_after'))
        save()
        print(json.dumps({'passed':report['passed'],'report':str(out/'report.json'),'failure':report.get('failure')},indent=2))
    return 0 if report['passed'] else 1

if __name__=='__main__':raise SystemExit(main())
