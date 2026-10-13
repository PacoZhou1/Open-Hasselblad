"""One short backend clip plus real manual UI ending/recovery proof. Root only."""
from pathlib import Path
import argparse,json,time
from urllib.request import Request,urlopen
from manual_product_session import adb,REMOTE
from factory_session import connect

def main():
 p=argparse.ArgumentParser();p.add_argument('package',type=Path);p.add_argument('--stop-only',action='store_true');a=p.parse_args();out=a.package.resolve()
 ident=json.loads((out/'identity.json').read_text());run=ident['run_id'];nonce=ident['nonce'];remote=ident['remote']
 assert remote==REMOTE+'/runs/'+run and run.startswith('manual-session-')
 report={'run_id':run,'passed':False,'physical_input_verified':False,'backend_clip':not a.stop_only};port=None;t0=time.monotonic()
 def save():
  report['elapsed_seconds']=round(time.monotonic()-t0,3);(out/'smoke-report.json').write_text(json.dumps(report,indent=2)+'\n')
 def request(path,body=None):
  r=Request('http://127.0.0.1:'+port+path,data=None if body is None else json.dumps(body).encode(),headers={'X-X2V-Token':token,'Content-Type':'application/json'})
  value=json.loads(urlopen(r,timeout=3).read())
  if path!='/catalog':assert value['run_id']==run and value['manual_nonce']==nonce
  return value
 def until(predicate,seconds):
  deadline=time.monotonic()+seconds
  while time.monotonic()<deadline:
   state=request('/state')
   if predicate(state):return state
   if state['phase']=='error':raise RuntimeError('Native bridge error: '+str(state))
   time.sleep(.15)
  raise RuntimeError('State deadline: '+str(state))
 try:
  port=adb('forward','tcp:0','tcp:18761').strip();token=(out/'session.token').read_text().strip()
  if not a.stop_only:
   initial=until(lambda s:s['phase'] in ['idle','saved'] and s['fresh'] and s['rtp_confirmed_off'] and not s['receiver_alive'],4)
   report['initial']=initial
   start=time.monotonic();report['start_reply']=request('/start',{'seconds':3})
   report['recording']=until(lambda s:s['phase']=='recording',8);report['start_to_recording_ms']=round((time.monotonic()-start)*1000,1)
   time.sleep(1.2)
   stop=time.monotonic();report['stop_reply']=request('/stop',{})
   report['saved']=until(lambda s:s['phase']=='saved' and s['rtp_confirmed_off'] and not s['receiver_alive'],12);report['stop_to_saved_ms']=round((time.monotonic()-stop)*1000,1)
   assert report['saved']['frames']>0
   report['catalog']=request('/catalog');print(json.dumps({k:report[k] for k in ['start_to_recording_ms','stop_to_saved_ms']}),flush=True)
  # Publish one canonical stop request. Native watcher validates identity and
  # performs /end -> actual UI player release -> retirement -> stock restore.
  marker=out/'manual.stop';marker.write_text(f'v1 {run} {nonce}\n')
  adb('push',marker,remote+'/manual.stop.tmp');adb('shell',f'test ! -e {remote}/manual.stop && mv {remote}/manual.stop.tmp {remote}/manual.stop')
  report['stop_requested']=True;save();end=time.monotonic();deadline=end+45;last=None
  while time.monotonic()<deadline:
   phase=adb('shell',f'cat {remote}/phase').strip()
   if phase!=last:print('recovery:',phase,flush=True);last=phase
   if phase=='restored':break
   if phase.startswith('error_'):raise RuntimeError('Native recovery HOLD: '+phase)
   time.sleep(.2)
  else:raise RuntimeError('Native recovery not confirmed')
  report['end_to_restored_ms']=round((time.monotonic()-end)*1000,1)
  for name in ['quiescent-state.json','end-state.json','final-state','final-error','bridge.quiescent','session.log','gui.log']:
   data=adb('shell',f'cat {remote}/{name}');(out/('device-'+name)).write_text(data)
  report['quiescent']=json.loads((out/'device-quiescent-state.json').read_text());q=report['quiescent']
  assert q['ending'] and q['manual_native_quiescent'] and q['ui_quiesced'] and not q['receiver_alive'] and q['rtp_confirmed_off']
  with connect() as f:
   report['after']=f.factory_shell('pidof camera-service;pidof camera-gui;getprop init.svc.camera-gui;mount | grep " /system "',capture_ms=3000)
   report['lock_clear']=f.factory_shell('test ! -e '+REMOTE+'/gui-session.lock && echo CLEAR',capture_ms=2000).strip()=='CLEAR'
  before=json.loads((out/'report.json').read_text())['before'].splitlines()[0]
  assert report['after'].splitlines()[0]==before and report['after'].splitlines()[2]=='running' and '(ro,' in report['after'] and report['lock_clear']
  report['passed']=True
 except BaseException as e:report['failure']=repr(e);raise
 finally:
  if port:
   try:adb('forward','--remove','tcp:'+port)
   except BaseException as e:report['forward_remove_error']=repr(e)
  save();print(json.dumps({'report':str(out/'smoke-report.json'),'passed':report['passed'],'failure':report.get('failure')}),flush=True)
if __name__=='__main__':main()
