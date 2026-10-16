from pathlib import Path
import json,sys,time,subprocess
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parent))
from factory_session import connect
B='/blackbox/x2v-native-20261011'; ST=B+'/fps-release-20261016'; G=B+'/gui'
S='/system/etc/x2v/x2v_video_session_20261014zl.sh'; P='/system/etc/x2v/x2v_product_boot_20261015c.sh'
def adb(*args):return subprocess.run(['adb','-s','123456789ABCDEF',*args],text=True,capture_output=True,check=True,timeout=20).stdout
assert json.loads((D.parent/'camera-testing.lock/owner.json').read_text())['owner']=='codex-preview-debug'
assert adb('shell','cat '+G+'/main.qml')==(D.parent/'video-afc-continuous-20261016/button-fix/gui/main.qml').read_text(),'Installed GUI changed'
report={}; changed=False; stopped=False; newpid=None
with connect() as r:
 def q(c):assert len(c.encode())<=231,c;return r.factory_shell(c,capture_ms=5000)
 def state():
  for _ in range(4):
   try:return json.loads(q('cat /tmp/x2v-product/state.json'))
   except ValueError:time.sleep(.1)
  raise RuntimeError('state unavailable')
 def cmd(c):q('echo "%d %s" > /tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
 def wait(pred,seconds=40):
  end=time.monotonic()+seconds;last=None
  while time.monotonic()<end:
   s=state();v=(s['mode'],s['session'],s['phase'])
   if v!=last:print(v,flush=True);last=v
   if pred(s):return s
   time.sleep(.25)
  raise RuntimeError(s)
 def launch():
  pid=q(f'toybox nohup sh {P} >{ST}/launch.log 2>&1 </dev/null & echo $!').strip();assert pid.isdigit(),pid
  adb('shell',f'p=$(pidof adbd);echo {int(pid)} > /acct/uid_0/pid_$p/cgroup.procs')
  return int(pid)
 report['before']=state();assert report['before']['phase'] in ('idle','saved')
 q('mkdir -p '+ST)
 q(f'touch {B}/video/af-diagnostic-pause')
 assets=[(D/'supervisor.sh',P,755),(D/'session.sh',S,755),(D/'main.qml',G+'/main.qml',644),(D/'RecordingProfiles.qml',G+'/RecordingProfiles.qml',644)]
 for fps in (25,30):
  m=json.loads((D/f'candidate-{fps}.json').read_text())
  assets +=[(Path(m['lib']),f'/system/lib64/libx2v_af_{fps}_20261016.so',644),(Path(m['conf']),f'/system/etc/x2v/x2v_af_{fps}_20261016.conf',644)]
 for i,(src,dest,mode) in enumerate(assets):adb('push',str(src),ST+f'/asset{i}')
 for i,(_,dest,_) in enumerate(assets[:4]):q(f'cp {dest} {ST}/rollback{i}')
 try:
  cmd('video_off');wait(lambda s:s['session']=='down' and s['phase'] not in ('exiting','entering'))
  q('kill -TERM '+str(report['before']['supervisor_pid']));stopped=True
  q('kill -TERM $(pidof camera-gui);true')
  q('mount -o remount,rw /system')
  try:
   changed=True
   for i,(_,dest,mode) in enumerate(assets):q(f'L={dest};cp {ST}/asset{i} $L.tmp && chmod {mode} $L.tmp && mv $L.tmp $L && restorecon $L')
  finally:q('mount -o remount,ro /system')
  newpid=launch();report['pid']=newpid
  wait(lambda s:s['supervisor_pid']==newpid,20)
  cmd('video_on');report['after']=wait(lambda s:s['session']=='up' and s['backend_ready'] and s['phase']=='idle')
  report['error']=q('odindb-send -s error -p active_error;true')
  report['af']=q('odindb-send -s camera -p af_status;true')
  assert 'active_error = false' in report['error'],report['error']
  report['installed']=True
 except Exception as e:
  report['failure']=repr(e)
  if newpid:
   cmd('video_off');wait(lambda s:s['session']=='down');q(f'kill -TERM {newpid}')
  if changed:
   q('mount -o remount,rw /system')
   try:
    for i,(_,dest,mode) in enumerate(assets[:4]):q(f'L={dest};cp {ST}/rollback{i} $L && chmod {mode} $L && restorecon $L')
   finally:q('mount -o remount,ro /system')
  if stopped:launch()
  raise
 finally:
  (D/'install-result.json').write_text(json.dumps(report,indent=2));print(report,flush=True)
