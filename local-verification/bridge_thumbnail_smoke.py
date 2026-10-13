"""Explicit 5-second capture, preview generation and recovery check."""
import json,time
from pathlib import Path
from urllib.request import Request,urlopen
from factory_session import connect
OUT=Path('native-video/outputs/bridge-d-real');OUT.mkdir(exist_ok=False)
token=Path('native-video/outputs/runtime/session.token').read_text().strip()
report={'passed':False,'states':[]}
def api(path,data=None):
 r=Request('http://127.0.0.1:18762'+path,data=None if data is None else json.dumps(data).encode(),headers={'X-X2V-Token':token,'Content-Type':'application/json'})
 return json.loads(urlopen(r,timeout=3).read())
def save():(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
try:
 report['before']=api('/state');assert report['before']['phase']=='idle'
 with connect() as f:
  report['baseline']=f.factory_shell('timeout 4 odindb-send -s camera -p live_view_state,liveview_transport_mode_current')
 assert 'State_Active(1)' in report['baseline'] and 'Mode_None(0)' in report['baseline']
 report['start']=api('/start',{'seconds':5});end=time.monotonic()+20;last=''
 while time.monotonic()<end:
  s=api('/state');report['states'].append(s)
  if s['phase']!=last:print(json.dumps(s),flush=True);last=s['phase']
  if s['phase'] in ('saved','error'):break
  time.sleep(.2)
 assert s['phase']=='saved' and s['rtp_confirmed_off'] and not s['receiver_alive'],s
 report['saved']=s
 end=time.monotonic()+6
 while time.monotonic()<end:
  c=api('/catalog');clip=next(x for x in c['clips'] if x['id']==s['id']);report['clip']=clip
  if clip.get('thumbnail') or not clip.get('thumbnail_pending'):break
  time.sleep(.2)
 assert clip.get('thumbnail'),clip
 report['passed']=True
except BaseException as e:report['failure']=repr(e)
finally:
 try:
  api('/stop',{});end=time.monotonic()+6
  while time.monotonic()<end:
   s=api('/state')
   if s['rtp_confirmed_off'] and not s['receiver_alive']:break
   time.sleep(.2)
  report['previewRequest']=api('/preview',{});end=time.monotonic()+6
  while time.monotonic()<end:
   s=api('/state')
   if s['preview_state'] in ('ready','error'):break
   time.sleep(.2)
  report['finalState']=s
  with connect() as f:report['cameraFinal']=f.factory_shell('timeout 4 odindb-send -s camera -p live_view_state,liveview_transport_mode_current')
  report['passed']=report['passed'] and s['preview_state']=='ready' and 'State_Active(1)' in report['cameraFinal']
 except BaseException as e:report['recoveryError']=repr(e);report['passed']=False
 save();print(json.dumps({'passed':report['passed'],'failure':report.get('failure'),'clip':report.get('clip')},indent=2))
raise SystemExit(0 if report['passed'] else 1)
