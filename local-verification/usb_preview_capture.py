"""Bounded USB preview capture; keep draining until device stop is confirmed."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import signal
import threading
import time
import usb.util
from factory_session import connect

START = 'timeout 4 odindb-send -s camera -m set_live_view_extended -- true E_LiveviewTransportMode_Usb'
STOP = 'timeout 4 odindb-send -s camera -m set_live_view_extended -- false E_LiveviewTransportMode_Usb'
STATE = 'odindb-send -s camera -p live_view_state,liveview_transport_mode_current,status;pidof camera-service;pidof camera-gui'

def is_idle(state):
    return 'E_LiveViewState_Off(0)' in state and 'E_LiveviewTransportMode_None(0)' in state

def stop_and_confirm(cmd, attempts=2):
    """A rejected stop can still have stopped the device: always read back."""
    failures=[]
    for _ in range(attempts):
        try: cmd(STOP)
        except Exception as e: failures.append(str(e))
        try:
            state=cmd(STATE)
            if is_idle(state): return state,failures
        except Exception as e: failures.append(str(e))
    raise RuntimeError('Device stop could not be confirmed: '+repr(failures))

def capture(seconds=3):
    if not 0 < seconds <= 10: raise ValueError('Experimental capture must be 0–10 seconds')
    out=Path(__file__).resolve().parent/'usb-preview'/datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    out.mkdir()
    report={'utc':datetime.now(timezone.utc).isoformat(),'operations':[], 'packets':[],
            'reader_errors':[], 'synthetic':False,'in_camera_installation':False,
            'requested_seconds':seconds,'stop_confirmed':False,'successful':False}
    finish,ready,cancel=threading.Event(),threading.Event(),threading.Event()
    previous={s:signal.signal(s,lambda *_:cancel.set()) for s in (signal.SIGINT,signal.SIGTERM)}
    try:
        with connect() as r:
            def cmd(q):
                row={'command':q,'at':time.monotonic()};report['operations'].append(row)
                try:
                    value=r.factory_shell(q,capture_ms=5500)
                    row.update(output=value,ok=True)
                    return value
                except Exception as e:
                    row.update(error=str(e),ok=False);raise
            baseline=cmd(STATE);report['baseline']=baseline
            if not is_idle(baseline):raise RuntimeError('Preview not idle; no change made')
            ep=usb.util.find_descriptor(r.device.get_active_configuration()[(4,0)],bEndpointAddress=0x86)
            def drain():
                total=0
                try:
                    with (out/'preview-usb.bin').open('xb') as f:
                        ready.set()
                        deadline=time.monotonic()+seconds+32
                        while not finish.is_set():
                            if time.monotonic()>deadline or total>=128*1024*1024:
                                raise RuntimeError('Receiver time/size bound reached')
                            try: block=bytes(ep.read(64*1024,timeout=150))
                            except Exception as e:
                                if r._is_timeout(e):continue
                                raise
                            f.write(block);total+=len(block)
                            report['packets'].append({'bytes':len(block),'at':time.monotonic()})
                except Exception as e:
                    report['reader_errors'].append(str(e));cancel.set();ready.set()
            thread=threading.Thread(target=drain,name='x2d2-usb-drain')
            thread.start();armed=False;timer_pid=None
            try:
                if not ready.wait(2) or report['reader_errors']:raise RuntimeError('USB reader not ready')
                timer_pid=cmd(f"toybox nohup sh -c 'sleep {int(seconds)+10};{STOP}' >/dev/null 2>&1 & echo $!").strip()
                if not timer_pid.isdigit():raise RuntimeError('Stop watchdog missing')
                armed=True;report['watchdog_pid']=timer_pid
                value=cmd(START)
                if 'Ok' not in value:raise RuntimeError('Start acknowledgement missing')
                cancel.wait(seconds)
            finally:
                try:
                    if armed:
                        state,failures=stop_and_confirm(cmd)
                        report.update(stop_confirmed=True,final_state=state,stop_command_errors=failures)
                        cmd('kill '+timer_pid+' 2>/dev/null || true')
                        # Read pending endpoint transfers through stop acknowledgement.
                        time.sleep(.5)
                finally:
                    finish.set();thread.join(timeout=2)
                    if thread.is_alive():report['reader_errors'].append('Reader did not exit')
            report['interrupted']=cancel.is_set()
            report['successful']=report['stop_confirmed'] and not report['reader_errors'] and bool(report['packets'])
            if not report['successful']:raise RuntimeError('Capture failed; inspect report')
    except BaseException as e:
        report['error']=str(e);raise
    finally:
        for s,handler in previous.items():signal.signal(s,handler)
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
        print('RESULT_DIRECTORY',out,flush=True)
    return out

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--seconds',type=float,default=3)
    print(capture(parser.parse_args().seconds))
