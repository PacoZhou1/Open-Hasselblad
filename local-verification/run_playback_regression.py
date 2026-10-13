"""Explicit bounded device regression; logs must be running before the trigger."""
import argparse,json,re,subprocess,time
from pathlib import Path
from types import SimpleNamespace
import gui_session
from factory_session import connect

p=argparse.ArgumentParser();p.add_argument('--package',required=True,type=Path);a=p.parse_args()
package=a.package.resolve();meta=gui_session.verify_package(package);runid=meta['runid'];remote=f'{gui_session.REMOTE}/runs/{runid}'
report={'runid':runid,'passed':False};out=package.parent/'device-regression';out.mkdir(exist_ok=False)
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def events(text):
 result=[]
 for line in text.splitlines():
  mark='X2V_PLAYBACK_REGRESSION '
  if mark in line:
   try:result.append(json.loads(line.split(mark,1)[1]))
   except ValueError:pass
 return result
try:
 gui_session.deploy(SimpleNamespace(package=package))
 state=gui_session.status_data(runid);report['initial']=state
 assert state['phase']=='running',state
 child=state['files']['child.identity'].split();pid=int(child[0]);report['guiPid']=pid
 with connect() as f:
  assert f.factory_shell('pidof camera-gui',capture_ms=900).strip()==str(pid)
  cmd=f'cd {remote};(timeout 75 logcat --pid={pid} -v epoch -T 1|head -c8388608)>regression-events.log 2>&1 & echo $!'
  assert len(cmd.encode())<=231
  logger=f.factory_shell(cmd,capture_ms=900).strip();assert logger.isdigit(),logger
  logger_state=f.factory_shell(f'kill -0 {logger} && cat /proc/{logger}/stat',capture_ms=900)
  report['logger']={'pid':int(logger),'maxSeconds':75,'maxBytes':8388608,'verifiedRunning':bool(logger_state)}
 camera_ms=int(gui_session.adb('shell','date +%s').strip())*1000
 lease=out/'playback-test.json';lease.write_text(json.dumps({'enabled':True,'runId':runid,'loggerReady':True,'expiresAtMs':camera_ms+70000}))
 gui_session.adb('push',str(lease),remote+'/playback-test.json.tmp')
 gui_session.adb('shell',f'mv {remote}/playback-test.json.tmp {remote}/playback-test.json')
 end=time.monotonic()+65;last=''
 while time.monotonic()<end:
  raw=gui_session.adb('shell',f'cat {remote}/regression-events.log');(out/'events.log').write_text(raw)
  ev=events(raw);report['events']=ev
  if re.search(r'(ReferenceError|TypeError):',raw):raise RuntimeError('QML runtime error; see persistent events.log')
  if ev and ev[-1].get('event')!=last:
   last=ev[-1].get('event');print(json.dumps(ev[-1]),flush=True)
  if any(e.get('event') in ('passed','failed') for e in ev):break
  s=gui_session.status_data(runid)
  if s['phase']!='running':report['earlyExit']=s;break
  time.sleep(1)
 passed=[e for e in ev if e.get('event')=='passed'];cycles=[e for e in ev if e.get('event')=='cycle_released'];ended=[e for e in ev if e.get('event')=='natural_end']
 report['nativeChecksPassed']=len(passed)==1 and len(cycles)==3 and len(ended)==1 and not any(e.get('event')=='failed' for e in ev)
 assert report['nativeChecksPassed'],report.get('events')
except BaseException as e:
 report['failure']=repr(e)
finally:
 try:gui_session.stop(SimpleNamespace(runid=runid))
 except BaseException as e:report['restoreError']=repr(e)
 report['restoration']=gui_session.status_data(runid)
 with connect() as f:
  report['cameraFinal']={q:f.factory_shell(q,capture_ms=900) for q in ['pidof camera-service camera-gui','getprop init.svc.camera-gui','timeout 4 odindb-send -s camera -p live_view_state,liveview_transport_mode_current']}
 report['passed']=report.get('nativeChecksPassed',False) and report['restoration']['phase']=='restored'
 save();print(json.dumps({'passed':report['passed'],'report':str(out/'report.json'),'failure':report.get('failure')},indent=2))
raise SystemExit(0 if report['passed'] else 1)
