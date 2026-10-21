from pathlib import Path
import json,sys,time,subprocess
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parent));from factory_session import connect
ST='/blackbox/x2v-native-20261011/flat-prr-20261017';report={}
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,check=True,timeout=15).stdout
with connect() as r:
 def q(c):assert len(c.encode())<=231,c;return r.factory_shell(c,capture_ms=2500)
 def state():
  for _ in range(5):
   try:return json.loads(q('cat /tmp/x2v-product/state.json'))
   except ValueError:time.sleep(.1)
  raise RuntimeError('state unavailable')
 def cmd(c):q('echo "%d %s" > /tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
 def wait(pred,seconds=12):
  end=time.monotonic()+seconds
  while time.monotonic()<end:
   s=state()
   if pred(s):return s
   time.sleep(.2)
  raise RuntimeError(s)
 def readbig(src,name):
  q(f'cp {src} {ST}/{name}')
  txt=adb('shell','cat '+ST+'/'+name);(D/name).write_text(txt,encoding='utf-8');return json.loads(txt)
 report['before']=state();assert report['before']['backend_ready'] and report['before']['phase'] in ('idle','saved')
 try:
  t=time.monotonic();cmd('start');report['recording']=wait(lambda s:s['phase']=='recording');report['start_seconds']=time.monotonic()-t
  time.sleep(4)
  t=time.monotonic();cmd('stop');report['saved']=wait(lambda s:s['phase']=='saved',20);report['stop_seconds']=time.monotonic()-t
  report['path']=q('tail -n 1 /blackbox/x2v-native-20261011/product/job-stop.out').strip()
  assert report['path'].endswith('.mov') and '/.x2v-staging/' not in report['path'],report
  ident=Path(report['path']).stem
  report['clip']=readbig('/mnt/media_rw/ssd/X2V_RAW/.x2v-meta/'+ident+'.json','live-clip.json')
  cat=readbig('/blackbox/x2v-native-20261011/rec/catalog.json','live-catalog.json');report['catalog_match']=[c for c in cat['clips'] if c['id']==ident]
  assert report['catalog_match'],report
  report['file']=q('ls -l '+report['path'])
  report['staging']=q('ls -A /mnt/media_rw/ssd/X2V_RAW/.x2v-staging')
  report['error']=q('odindb-send -s error -p active_error')
  assert 'active_error = false' in report['error']
 finally:
  s=state()
  if s['phase']=='recording':cmd('stop');wait(lambda s:s['phase']=='saved',20)
  (D/'live-result.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print(json.dumps(report),flush=True)
