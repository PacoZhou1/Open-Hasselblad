"""Start a bounded device-side recorder, then drive stock RTP preview."""
from datetime import datetime
from pathlib import Path
import subprocess,time,json
from factory_session import connect
from usb_preview_capture import is_idle,STATE
out=Path('native-video/outputs')/datetime.now().strftime('native-%Y%m%d-%H%M%S');out.mkdir()
remote='/blackbox/x2v-native-20261011/'+out.name+'.mp4'
rows=[];p=None;first=rest='';failure=None
try:
 with connect() as r:
  def cmd(q):
   try:o=r.factory_shell(q);rows.append(dict(query=q,output=o));return o
   except Exception as e:rows.append(dict(query=q,error=str(e)));raise
  assert is_idle(cmd(STATE))
  p=subprocess.Popen(['adb','shell','/blackbox/x2v-native-20261011/rtp_recorder',remote,'10'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
  first=p.stdout.readline();print(first,flush=True)
  if not first.startswith('READY'):raise RuntimeError(first)
  stop='timeout 4 odindb-send -s camera -m set_live_view_extended -- false E_LiveviewTransportMode_Rtp'
  timer=cmd(f"toybox nohup sh -c 'sleep 7;{stop}' >/dev/null 2>&1 & echo $!").strip()
  if not timer.isdigit():raise RuntimeError('Watchdog missing')
  try:
   print(cmd('timeout 4 odindb-send -s camera -m set_live_view_extended -- true E_LiveviewTransportMode_Rtp'),flush=True)
   time.sleep(4)
  finally:
   try:print(cmd(stop),flush=True)
   finally:
    state=cmd(STATE);print(state,flush=True)
    if is_idle(state):
     cmd('kill '+timer+' 2>/dev/null || true')
     subprocess.run(['adb','shell','touch',remote+'.stop'],check=True)
  rest=p.communicate(timeout=15)[0];print(rest,flush=True)
  if p.returncode:raise RuntimeError('Native recorder failed')
except BaseException as e:
 failure=str(e);raise
finally:
 (out/'report.json').write_text(json.dumps(dict(operations=rows,receiver=first+rest,error=failure,exit_code=p.returncode if p else None,remote=remote,in_camera_mux=True),indent=2))
for suffix in ['', '.state.json']:
 subprocess.run(['adb','pull',remote+suffix,str(out/('recording.mp4'+suffix))],check=True)
print('RESULT_DIRECTORY',out)
