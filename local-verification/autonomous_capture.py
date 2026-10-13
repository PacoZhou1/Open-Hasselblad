"""Bounded on-device start/stop script + independent native recorder.
The host sends no camera command between dispatch and completion checks.
"""
from datetime import datetime
from pathlib import Path
import subprocess,time,json
from factory_session import connect
from usb_preview_capture import STATE,is_idle
out=Path('native-video/outputs')/datetime.now().strftime('autonomous-%Y%m%d-%H%M%S');out.mkdir()
root='/blackbox/x2v-native-20261011';stem=root+'/'+out.name;remote=stem+'.mp4'
stop='timeout 4 odindb-send -s camera -m set_live_view_extended -- false E_LiveviewTransportMode_Rtp'
script=f'''#!/system/bin/sh
date +%s
echo controller_started
cleanup() {{
 date +%s
 echo controller_stopping
 {stop}
 odindb-send -s camera -p live_view_state,liveview_transport_mode_current > {stem}.final-state
 if grep -q 'E_LiveViewState_Off(0)' {stem}.final-state && grep -q 'E_LiveviewTransportMode_None(0)' {stem}.final-state; then
  touch {remote}.stop
 fi
}}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
# Second independent timeout remains in the camera if this controller exits.
toybox nohup sh -c 'sleep 11;{stop}' >/dev/null 2>&1 &
timeout 4 odindb-send -s camera -m set_live_view_extended -- true E_LiveviewTransportMode_Rtp || exit 1
echo preview_started
date +%s
# Wait until actual complete video samples are being written, at most 4 seconds.
count=0
while ! grep -q '\"phase\":\"recording\"' {remote}.state.json; do
 count=$((count+1))
 [ "$count" -lt 40 ] || exit 2
 sleep 0.1
done
echo recording_started
date +%s
sleep 5
echo sleep_completed
date +%s
'''
local=out/'controller.sh';local.write_text(script)
subprocess.run(['adb','push',str(local),stem+'.sh'],check=True)
with connect() as r:
 baseline=r.factory_shell(STATE);assert is_idle(baseline)
 receiver=subprocess.check_output(['adb','shell',f'toybox nohup {root}/rtp_recorder {remote} 12 >{stem}.log 2>&1 & echo $!'],text=True).strip();assert receiver.isdigit()
 for _ in range(10):
  ready=subprocess.run(['adb','shell','cat',stem+'.log'],capture_output=True,text=True).stdout
  if 'READY' in ready:break
  time.sleep(.1)
 else:raise RuntimeError('Receiver not ready: '+ready)
 controller=r.factory_shell(f'toybox nohup sh {stem}.sh >{stem}.control.log 2>&1 & echo $!').strip();assert controller.isdigit()
# Both the recorder and camera controls now run on the camera, without a host stream.
time.sleep(13)
for remote_path,name in [(remote,'recording.mp4'),(remote+'.state.json','state.json'),(stem+'.final-state','camera-state.txt'),(stem+'.log','recorder.log'),(stem+'.control.log','controller.log')]:
 subprocess.run(['adb','pull',remote_path,str(out/name)],check=True)
with connect() as r:final=r.factory_shell(STATE)
assert is_idle(final)
state=json.loads((out/'state.json').read_text());assert state['phase']=='saved' and state['frames']>0
(out/'report.json').write_text(json.dumps(dict(baseline=baseline,final=final,controller_pid=controller,receiver_pid=receiver,host_command_gap_seconds=13,in_camera_mux=True,in_camera_timed_control=True,cable_disconnect_tested=False),indent=2))
print('RESULT_DIRECTORY',out)
