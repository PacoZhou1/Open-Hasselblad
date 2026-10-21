from pathlib import Path
import json,sys,time,subprocess
D=Path(__file__).resolve().parent;ROOT=D.parents[1];sys.path.insert(0,str(D.parent))
from factory_session import connect
PK=ROOT/'releases/x2v-20261017-flat-prr';M=json.loads((PK/'manifest.json').read_text())
ST='/blackbox/x2v-native-20261011/flat-prr-20261017';ET='/system/etc/x2v/'
NEW=ET+'x2v_product_boot_20261017a.sh';OLD=ET+'x2v_product_boot_20261015c.sh'
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,check=True,timeout=20).stdout
lock=D.parent/'camera-testing.lock/owner.json';owner=json.loads(lock.read_text());assert owner['owner']=='codex-preview-debug'
owner.update(state='TESTING',task='Install and verify flat ProRes MOV storage');lock.write_text(json.dumps(owner,indent=2)+'\n')
adb('shell','mkdir -p '+ST)
for i,a in enumerate(M['assets']):adb('push',str(PK/a['file']),ST+'/asset'+str(i))
lines=['#!/system/bin/sh','set -e','mount -o remount,rw /system',"trap 'mount -o remount,ro /system' EXIT"]
# Publish boot selector last, after all dependencies are installed.
for i in (0,2,3,1):
 a=M['assets'][i];p=a['destination'];lines += [f'test ! -e {p}',f'cp {ST}/asset{i} {p}.tmp',f'chmod 755 {p}.tmp',f'mv {p}.tmp {p}',f'restorecon {p}']
lines+=['echo OK']
(D/'install-device.sh').write_text('\n'.join(lines)+'\n');adb('push',str(D/'install-device.sh'),ST+'/install.sh')
report={};stopped=False;newpid=None
with connect() as r:
 def q(c):
  assert len(c.encode())<=231,c
  return r.factory_shell(c,capture_ms=2500)
 def state():
  for _ in range(4):
   try:return json.loads(q('cat /tmp/x2v-product/state.json'))
   except ValueError:time.sleep(.1)
  raise RuntimeError('No state')
 def cmd(c):q('echo "%d %s" > /tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
 def wait(pred,seconds=35):
  end=time.monotonic()+seconds;last=None
  while time.monotonic()<end:
   s=state();v=(s['supervisor_pid'],s['mode'],s['session'],s['phase'])
   if v!=last:print(v,flush=True);last=v
   if pred(s):return s
   time.sleep(.25)
  raise RuntimeError(s)
 def launch(p):
  result=q(f'toybox nohup sh {p} >{ST}/launch.log 2>&1 </dev/null & echo $!').strip();assert result.isdigit(),result
  pid=int(result);adb('shell',f'p=$(pidof adbd);echo {pid} > /acct/uid_0/pid_$p/cgroup.procs');return pid
 report['before']=state();assert report['before']['phase'] in ('idle','saved'),report['before']
 try:
  if report['before']['session']!='down':cmd('video_off');wait(lambda s:s['session']=='down' and s['phase']=='idle')
  q('kill -TERM '+str(report['before']['supervisor_pid']));stopped=True
  q('kill -TERM $(pidof camera-gui);true')
  report['install']=q('sh '+ST+'/install.sh');assert 'OK' in report['install']
  report['system_mount']=q('grep " /system " /proc/mounts');assert ' ro,' in report['system_mount']
  newpid=launch(NEW);report['pid']=newpid
  wait(lambda s:s['supervisor_pid']==newpid,15)
  cmd('video_on');report['after']=wait(lambda s:s['backend_ready'] and s['session']=='up' and s['phase']=='idle')
  report['error']=q('odindb-send -s error -p active_error');assert 'active_error = false' in report['error']
  report['installed']=True
 except Exception as e:
  report['failure']=repr(e)
  if newpid:
   cmd('video_off');wait(lambda s:s['session']=='down');q(f'kill -TERM {newpid}')
  q(f'mount -o remount,rw /system;test ! -f {NEW} || mv {NEW} {NEW}.disabled;mount -o remount,ro /system')
  if stopped:launch(OLD)
  raise
 finally:
  (D/'install-result.json').write_text(json.dumps(report,indent=2)+'\n');print(report,flush=True)
