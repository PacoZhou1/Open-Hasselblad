from datetime import datetime
from pathlib import Path
import subprocess,time,json
from factory_session import connect
from usb_preview_capture import is_idle,STATE
out=Path('native-video/outputs')/datetime.now().strftime('rtp-%Y%m%d-%H%M%S');out.mkdir()
remote='/blackbox/x2v-native-20261011/'+out.name+'.bin'
rows=[]
with connect() as r:
 def cmd(q):
  try:o=r.factory_shell(q);rows.append(dict(query=q,output=o));return o
  except Exception as e:rows.append(dict(query=q,error=str(e)));raise
 assert is_idle(cmd(STATE))
 p=subprocess.Popen(['adb','shell','/blackbox/x2v-native-20261011/rtp_probe',remote,'9'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 first=p.stdout.readline();print(first,flush=True)
 if not first.startswith('READY'):raise RuntimeError(first)
 stop='timeout 4 odindb-send -s camera -m set_live_view_extended -- false E_LiveviewTransportMode_Rtp'
 timer=cmd(f"toybox nohup sh -c 'sleep 6;{stop}' >/dev/null 2>&1 & echo $!").strip()
 try:
  print(cmd('timeout 4 odindb-send -s camera -m set_live_view_extended -- true E_LiveviewTransportMode_Rtp'),flush=True)
  time.sleep(3)
 finally:
  try: print(cmd(stop),flush=True)
  finally:
   state=cmd(STATE);print(state,flush=True)
   if is_idle(state) and timer.isdigit():cmd('kill '+timer+' 2>/dev/null || true')
 rest=p.communicate(timeout=15)[0];print(rest,flush=True)
(out/'report.json').write_text(json.dumps(dict(operations=rows,receiver=first+rest,exit_code=p.returncode,remote=remote),indent=2))
subprocess.run(['adb','pull',remote,str(out/'rtp.bin')],check=True)
print(out)
