"""Five-second stock USB preview probe with camera-side stop timer; no injection."""
import json
from pathlib import Path
import time
import usb.util
from factory_session import connect

OUT = Path(__file__).resolve().parent / 'usb-preview'
OUT.mkdir(exist_ok=True)
rows = []
packets = []
stop = 'timeout 4 odindb-send -s camera -m set_live_view_extended -- false E_LiveviewTransportMode_Usb'
start = 'timeout 4 odindb-send -s camera -m set_live_view_extended -- true E_LiveviewTransportMode_Usb'
with connect() as r:
    def cmd(q):
        try:
            value = r.factory_shell(q, capture_ms=5500)
            rows.append({'command': q, 'output': value, 'ok': True})
            print(value, flush=True)
            return value
        except Exception as e:
            rows.append({'command': q, 'error': str(e), 'ok': False})
            raise
    baseline = cmd('odindb-send -s camera -p live_view_state,liveview_transport_mode_current,status;pidof camera-service')
    if 'E_LiveViewState_Off(0)' not in baseline or 'E_LiveviewTransportMode_None(0)' not in baseline:
        raise RuntimeError('Existing preview state is not idle; no change made')
    ep = usb.util.find_descriptor(r.device.get_active_configuration()[(4, 0)], bEndpointAddress=0x86)
    armed = False
    try:
        # Independent stop survives a host-side interruption. No persistent file.
        timer = cmd(f"toybox nohup sh -c 'sleep 8;{stop}' >/dev/null 2>&1 & echo $!")
        if not timer.strip().isdigit():
            raise RuntimeError('Stop timer not acknowledged')
        armed = True
        cmd(start)
        cmd('odindb-send -s camera -p live_view_state,liveview_transport_mode_current,liveview_fps,status')
        end = time.monotonic() + 5
        total = 0
        with (OUT/'preview-usb.bin').open('xb') as f:
            while time.monotonic() < end and total < 64*1024*1024:
                try:
                    block = bytes(ep.read(64*1024, timeout=250))
                except Exception as e:
                    if r._is_timeout(e): continue
                    raise
                f.write(block)
                total += len(block)
                packets.append({'bytes': len(block), 'time': time.monotonic(), 'prefix': block[:24].hex()})
        print('received_bytes', total, flush=True)
    finally:
        if armed:
            try: cmd(stop)
            finally:
                time.sleep(1)
                cmd('odindb-send -s camera -p live_view_state,liveview_transport_mode_current,status;pidof camera-service;pidof camera-gui')
        (OUT/'report.json').write_text(json.dumps({'operations': rows, 'packets': packets, 'synthetic': False, 'decoded_video_verified': False}, indent=2)+'\n')
