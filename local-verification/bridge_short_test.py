"""Explicit bounded development test; does not run on import or startup."""
import argparse
import json
from pathlib import Path
import time
from urllib.request import Request, urlopen
from factory_session import connect

def run(output, seconds=5):
    output.mkdir(parents=True, exist_ok=False)
    token = Path('native-video/outputs/runtime/session.token').read_text().strip()
    report = {'states': [], 'success': False}
    def api(path, data=None):
        request = Request('http://127.0.0.1:18762'+path,
                          data=None if data is None else json.dumps(data).encode(),
                          headers={'X-X2V-Token':token, 'Content-Type':'application/json'})
        return json.loads(urlopen(request, timeout=3).read())
    def save():
        (output/'capture.json').write_text(json.dumps(report, indent=2))
    dispatched = False
    try:
        state = api('/state')
        assert state['phase'] in ['idle','saved','error'] and state['rtp_confirmed_off'], state
        with connect() as device:
            report['baseline'] = device.factory_shell('odindb-send -s camera -p live_view_state,liveview_transport_mode_current')
            assert 'Mode_None(0)' in report['baseline'] or 'Mode_Normal(1)' in report['baseline'], report['baseline']
            device.factory_shell('odindb-send -s camera -m set_live_view_extended -- false E_LiveviewTransportMode_Rtp')
            report['before'] = device.factory_shell('odindb-send -s camera -p live_view_state,liveview_transport_mode_current')
            assert 'State_Off(0)' in report['before'] and 'Mode_None(0)' in report['before'], report['before']
        dispatched = True
        report['start'] = api('/start', {'seconds':seconds})
        end = time.monotonic()+seconds+12
        last = ''
        while time.monotonic() < end:
            state = api('/state'); report['states'].append(state)
            if state['phase'] != last:
                print(json.dumps(state), flush=True); last = state['phase']
            if state['phase'] in ['saved','error']: break
            time.sleep(.25)
        assert state['phase'] == 'saved', state
        report['catalog'] = api('/catalog')
        report['success'] = True
        print('SAVED_DIRECT_SSD', state['path'], flush=True)
    except BaseException as error:
        report['failure'] = repr(error)
        raise
    finally:
        save()
        try:
            if dispatched:
                report['stop'] = api('/stop', {})
                end = time.monotonic()+7
                while not report['stop']['rtp_confirmed_off'] and time.monotonic() < end:
                    time.sleep(.25); report['stop'] = api('/state')
        finally:
            with connect() as device:
                report['cameraFinal'] = device.factory_shell('odindb-send -s camera -p live_view_state,liveview_transport_mode_current')
            save()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=int, default=5, choices=range(1,16))
    args = parser.parse_args()
    run(args.output, args.seconds)
