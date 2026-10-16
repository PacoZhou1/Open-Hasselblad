from pathlib import Path
import json,sys,time,subprocess
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parent));from factory_session import connect
B='/blackbox/x2v-native-20261011';ST=B+'/fps-release-20261016'
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],text=True,capture_output=True,check=True,timeout=15).stdout
out=json.loads((D/"fps-results.json").read_text()) if (D/"fps-results.json").exists() else []
with connect() as r:
 def q(c):assert len(c.encode())<=231,c;return r.factory_shell(c,capture_ms=5000)
 def st():
  for _ in range(5):
   try:return json.loads(q('cat /tmp/x2v-product/state.json'))
   except ValueError:time.sleep(.1)
  raise RuntimeError('state')
 def gui(c):q(f'echo {c} > {B}/gui-cmd')
 def wait(pred,n=40):
  end=time.monotonic()+n
  while time.monotonic()<end:
   s=st()
   if pred(s):return s
   time.sleep(.3)
  raise RuntimeError(s)
 for fps,index in [(25,2),(30,3)]:
  rec={'fps':fps};t=time.monotonic();gui(f'codec{int(time.time())}-{index}')
  rec['ready']=wait(lambda s:s['profile_id']==f'raw_3920_2946_{fps}' and s['backend_ready'] and s['phase'] in ('idle','saved'))
  rec['switch_seconds']=round(time.monotonic()-t,2);print('READY',fps,rec['switch_seconds'],flush=True)
  wait(lambda s:s['temperature_status'] in ('low','moderate'),10)
  gui('record');rec['recording']=wait(lambda s:s['phase']=='recording',15)
  time.sleep(5)
  gui('stoprec');rec['saved']=wait(lambda s:s['phase']=='saved',15)
  live=json.loads(q('cat /tmp/x2v-live/status.json'));rec['status']=live
  clip=live['last_clip'];q(f'cp {clip}/clip.json {ST}/clip{fps}.json')
  adb('pull',ST+f'/clip{fps}.json',str(D/f'clip{fps}.json'))
  meta=json.loads((D/f'clip{fps}.json').read_text());rec['clip']=meta
  rec['measured_fps']=(meta['seen']-1)*1e6/meta['source_span_raw']
  rec['error']=q('odindb-send -s error -p active_error;true')
  out.append(rec);(D/'fps-results.json').write_text(json.dumps(out,indent=2))
  print(json.dumps({'fps':fps,'measured':rec['measured_fps'],'frames':meta['frames'],'dropped':meta['dropped'],'lost':meta['lost'],'error':rec['error']}),flush=True)
  assert abs(rec['measured_fps']-fps)<.1 and meta['lost']==0 and meta['fps']==fps
  assert 'active_error = false' in rec['error']
 gui(f'codec{int(time.time())}-1');wait(lambda s:s['profile_id']=='raw_3920_2946_24' and s['backend_ready'])
 print('Restored24',flush=True)
