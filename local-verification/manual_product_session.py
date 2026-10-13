"""Root-only temporary manual product session. Offline preparation by default.
No firmware/init edits. Start/stop clips reuse the resident bridge and service.
"""
from pathlib import Path
from datetime import datetime
import argparse, hashlib, importlib.util, json, re, secrets, shutil, subprocess, time
from urllib.request import Request, urlopen
ROOT=Path(__file__).resolve().parents[1]
N=ROOT/'native-video'
C=N/'experimental/manual-session-control-f'
UI=N/'experimental/manual-video-product-ui'
REMOTE='/data/x2v-native-20261012'
TARGET='/uid_0/pid_2676'
DOMAIN='u:r:hbl_camera_service:s0'
BRIDGE_SHA='810523dea771c75c86ff48285c8f10037e82b9e6f14a349ffb8bc9958b8597d2'
CLIENT_SHA='b0177536057d992bb8ca6c31654a468a59f4a842270d00bb37efadaeec785862'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def adb(*args,timeout=15):
 r=subprocess.run(['adb','-s','123456789ABCDEF',*map(str,args)],capture_output=True,text=True,timeout=timeout)
 if r.returncode:raise RuntimeError('ADB failed: '+r.stderr.strip())
 return r.stdout

def prepare(ui=UI,target=TARGET,boot_id=None):
 assert re.fullmatch(r'/uid_0/pid_[1-9][0-9]*',target) and int(target.rsplit('_',1)[1])>1
 assert boot_id is None or re.fullmatch(r'[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}',boot_id)
 run='manual-session-'+datetime.now().strftime('%H%M%S');out=N/'outputs'/run;out.mkdir()
 nonce=secrets.token_hex(16);remote=REMOTE+'/runs/'+run
 subprocess.run([str(ROOT/'.venv/bin/python'),str(ui/'prepare_ui.py'),'--run-id',run,'--nonce32',nonce,'--token-source','file://'+remote+'/session.token','--out',str(out)],check=True,capture_output=True)
 delta=json.loads((C/'final-delta-host-report.json').read_text())
 assert delta['passed'] and sha(C/'controller.sh')==delta['source_sha256']['controller.sh']
 c=(C/'controller.sh').read_text()
 hold='echo HOLD_MANUAL_CONTROLLER_UNREVIEWED >&2\nexit 30\n'
 assert c.count(hold)==1 and c.count('BRIDGE_SHA=PENDING')==1 and c.count('CLIENT_SHA=PENDING')==1
 assert 'PATH=/sbin:/system/sbin:/system/bin:/system/xbin' in c and 'manual_stop_requested' in c
 c=c.replace(hold,'').replace('# Manual session candidate: offline, unreleased, never install this draft.','# Root-bound temporary manual product session.').replace('BRIDGE_SHA=PENDING','BRIDGE_SHA='+BRIDGE_SHA).replace('CLIENT_SHA=PENDING','CLIENT_SHA='+CLIENT_SHA)
 assert c.count(TARGET)==2
 c=c.replace(TARGET,target)
 (out/'controller.sh').write_text(c)
 b=(C/'bootstrap.sh').read_text();assert b.count('CONTROLLER_SHA=PENDING')==1 and b.count(TARGET)==1
 b=b.replace(TARGET,target)
 (out/'bootstrap.sh').write_text(b.replace('CONTROLLER_SHA=PENDING','CONTROLLER_SHA='+sha(out/'controller.sh')))
 # Private token is never printed or serialized into the public receipt.
 p=out/'session.token';p.write_text(secrets.token_hex(32)+'\n');p.chmod(0o600)
 for name in ('controller.sh','bootstrap.sh'):
  subprocess.run([str(N/'outputs/runtime/mksh-r56-host/mksh'),'-n',str(out/name)],check=True)
 identity=dict(run_id=run,nonce=nonce,remote=remote,target_group=target,boot_id=boot_id,source_controller_sha256=sha(C/'controller.sh'),controller_sha256=sha(out/'controller.sh'),bootstrap_sha256=sha(out/'bootstrap.sh'),session_seconds=600,clip_seconds=30,permanent_firmware=False)
 (out/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
 print(json.dumps(dict(prepared=str(out),run_id=run)),flush=True)
 return out

def execute(out):
 from factory_session import connect
 ident=json.loads((out/'identity.json').read_text());run=ident['run_id'];nonce=ident['nonce'];remote=ident['remote'];target=ident.get('target_group',TARGET)
 assert re.fullmatch(r'/uid_0/pid_[1-9][0-9]*',target)
 assert re.fullmatch(r'manual-session-[A-Za-z0-9_-]+',run) and remote==REMOTE+'/runs/'+run
 assert sha(out/'controller.sh')==ident['controller_sha256'] and sha(out/'bootstrap.sh')==ident['bootstrap_sha256']
 report=dict(run_id=run,passed=False,controller_released=False,bootstrapped=False,started_at=datetime.now().isoformat(),physical_input_verified=False,permanent_firmware=False)
 t0=time.monotonic()
 def save():
  report['elapsed_seconds']=round(time.monotonic()-t0,3)
  (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 def q(f,cmd):
  assert len(cmd.encode())<=231
  value=f.factory_shell(cmd,capture_ms=5000)
  report.setdefault('native_queries',[]).append(dict(command=cmd,output=value))
  return value
 def put(name,body):
  p=out/name;p.write_text(body);adb('push',p,remote+'/'+name+'.tmp');adb('shell',f'test ! -e {remote}/{name} && mv {remote}/{name}.tmp {remote}/{name}')
 def read(name):return adb('shell',f'if [ -f {remote}/{name} ];then cat {remote}/{name};fi')
 def now():return int(adb('shell','/system/bin/x2v_guard_clock_20261012b').strip())
 def wait_record(name,kind,token,seconds):
  deadline=time.monotonic()+seconds
  while time.monotonic()<deadline:
   raw=read(name);x=raw.split()
   if raw.endswith('\n') and len(raw.splitlines())==1 and len(x)==15 and x[:5]==['v1',kind,run,nonce,token] and x[7]==boot and x[10]==DOMAIN and x[12]==target and all(re.fullmatch('[0-9]+',x[i]) for i in [5,6,8,9,13,14]) and x[5]==x[8]==x[9] and int(x[5])>1:return x
   time.sleep(.1)
  raise RuntimeError('Missing canonical '+name)
 try:
  # Native visibility for locks; ADB cannot certify absence of native processes.
  with connect() as f:
   raw=q(f,'p=$(pidof camera-test);cat /proc/$p/stat;cat /proc/$p/cgroup');lines=raw.strip().splitlines();fp=lines[0].split()[0];fields=lines[0].rsplit(') ',1)[1].split();fs=fields[19];fpg=fields[2]
   assert '2:cpuacct:/uid_0/pid_'+fp in lines
   for lock in ['/data/x2v-source-20261012/source-session.lock',REMOTE+'/gui-session.lock','/blackbox/x2v-native-20261011/gui-session.lock',REMOTE+'/io-benchmark.lock']:
    assert q(f,'test ! -e '+lock+' && test ! -L '+lock+' && echo CLEAR').strip()=='CLEAR'
   report['before']=q(f,'pidof camera-service;pidof camera-gui;getprop init.svc.camera-service;getprop init.svc.camera-gui;mount | grep " /system "')
   assert report['before'].splitlines()[2:4]==['running','running'] and '(ro,' in report['before']
  boot=adb('shell','cat /proc/sys/kernel/random/boot_id').strip()
  assert 'cpuacct:'+target in adb('shell','cat /proc/$(pidof adbd)/cgroup')
  assert not ident.get('boot_id') or boot==ident['boot_id']
  report['boot']=boot
  adb('shell','test ! -e '+remote+' && mkdir '+remote)
  for name in ['payload','controller.sh','bootstrap.sh','session.token']:adb('push',out/name,remote+'/'+name)
  adb('shell','chmod 600 '+remote+'/session.token')
  uploaded=adb('shell',f'sha256sum {remote}/controller.sh {remote}/bootstrap.sh').splitlines()
  assert [line.split()[0] for line in uploaded]==[ident['controller_sha256'],ident['bootstrap_sha256']]
  # All data is uploaded before the short native bootstrap window begins.
  put('passive.binding',f'v1 {run} {nonce} {boot} {fp} {fs} {fpg} {now()+85}\n')
  logger=out/'logger.sh';logger.write_text('PATH=/sbin:/system/bin:/system/xbin\nexport PATH\nexec timeout 40 logcat -v brief -T 1 -s camera-gui:I >'+remote+'/startup-logcat.log 2>&1\n')
  adb('push',logger,remote+'/logger.sh')
  with connect() as f:
   q(f,'cd '+remote+' && toybox nohup sh logger.sh </dev/null >logger-launch.log 2>&1 &')
   report['bootstrapped']=True;save()
   report['bootstrap_dispatch']=q(f,'cd '+remote+' && toybox nohup toybox setsid sh bootstrap.sh --run '+run+' </dev/null >session.log 2>&1 &')
  ready=wait_record('passive.ready','ready','-',8);assert ready[11]=='/uid_0/pid_'+fp;report['ready']=ready
  challenge=secrets.token_hex(16);put('passive.challenge',f'v1 {run} {nonce} {challenge}\n')
  fresh=wait_record('passive.fresh','fresh',challenge,3);assert fresh[5:13]==ready[5:13]
  current=now();assert 0<=current-int(fresh[13])<=2 and int(fresh[14])-current>=3
  report['fresh']=fresh
  cmd=f'n=$(/system/bin/x2v_guard_clock_20261012b);test "$n" -ge {fresh[13]} && test "$n" -lt {fresh[14]} && test ! -e {remote}/passive.stop && echo {fresh[5]} >/acct{target}/cgroup.procs && echo ATTACHED'
  assert adb('shell',cmd).strip()=='ATTACHED'
  migrated=wait_record('passive.migrated','migrated',challenge,4);assert migrated[5:11]==ready[5:11] and migrated[11]==target;report['migrated']=migrated
  report['controller_released']=True;save();put('passive.go',f'v1 {run} {nonce} {challenge}\n')
  last='';deadline=time.monotonic()+35
  while time.monotonic()<deadline:
   phase=read('phase').strip()
   if phase!=last:print('manual phase:',phase,flush=True);last=phase
   if phase=='running':break
   if phase.startswith('error_') or phase=='restored':raise RuntimeError('Controller ended before usable UI: '+phase)
   time.sleep(.2)
  else:raise RuntimeError('Manual launch deadline; native watchdog still owns recovery')
  report['running_seconds']=round(time.monotonic()-t0,3)
  # Native process/start identity and current API session; this is not touch proof.
  with connect() as f:
   for name,expected in [('child.identity','/system/bin/camera-gui'),('bridge.identity','/system/bin/x2v_session_bridge_20261012e')]:
    pid,start=read(name).split();exec_deadline=time.monotonic()+5
    while True:
     v=q(f,f'readlink /proc/{pid}/exe;cat /proc/{pid}/stat');vlines=v.strip().splitlines();tail=vlines[-1].rsplit(') ',1)[1].split()
     assert tail[0]!='Z' and tail[19]==start
     if vlines[0]==expected:break
     assert vlines[0] in ['/system/bin/sh','/system/bin/mksh'] and time.monotonic()<exec_deadline
     time.sleep(.1)
    report[name]=dict(pid=pid,start=start,exe=expected)
  port=adb('forward','tcp:0','tcp:18761').strip();report['forward_port']=int(port)
  token=(out/'session.token').read_text().strip()
  request=Request('http://127.0.0.1:'+port+'/state',headers={'X-X2V-Token':token})
  report['state']=json.loads(urlopen(request,timeout=3).read())
  assert report['state']['run_id']==run and report['state']['manual_nonce']==nonce and not report['state']['ending']
  adb('forward','--remove','tcp:'+port);report['forward_removed']=True
  # Process/API success is separate from an actually initialized QML interface.
  report['host_launch_and_bridge_passed']=True
  deadline=time.monotonic()+6;events=[]
  while time.monotonic()<deadline:
   raw=read('startup-logcat.log');(out/'startup-logcat.log').write_text(raw);events=[]
   for line in raw.splitlines():
    if 'X2V_USER_SESSION_UI ' not in line:continue
    try:event=json.loads(line.split('X2V_USER_SESSION_UI ',1)[1])
    except ValueError:continue
    if event.get('runId')==run:events.append(event)
   active=any(e.get('event')=='manual_gate_phase' and e.get('detail',{}).get('phase')=='active' for e in events)
   loaded=any(e.get('event')=='stock_root_loaded' and e.get('detail',{}).get('mainModelReady') for e in events)
   if active and loaded:break
   time.sleep(.2)
  report['ui_events']=events;report['ui_ready']=bool(active and loaded)
  report['passed']=report['ui_ready'];report['phase']='running';save()
  print(json.dumps(dict(report=str(out/'report.json'),passed=report['passed'],ui_ready=report['ui_ready'],run_id=run,elapsed=report['elapsed_seconds'])),flush=True)
 except BaseException as e:
  report['failure']=repr(e)
  if report.get('forward_port') and not report.get('forward_removed'):
   try:adb('forward','--remove','tcp:'+str(report['forward_port']));report['forward_removed']=True
   except BaseException as fe:report['forward_error']=repr(fe)
  try:
   if report['controller_released']:put('manual.stop',f'v1 {run} {nonce}\n');report['recovery_requested']=True
   elif report['bootstrapped']:put('passive.stop',f'v1 {run} {nonce}\n')
   report['session_log']=read('session.log');report['phase']=read('phase').strip()
  except BaseException as secondary:report['collection_error']=repr(secondary)
  save();print(json.dumps(dict(report=str(out/'report.json'),passed=False,failure=report['failure'])),flush=True);raise

def main():
 global C
 p=argparse.ArgumentParser();p.add_argument('--execute',type=Path);p.add_argument('--ui',type=Path,default=UI);p.add_argument('--target-group',default=TARGET);p.add_argument('--boot-id');p.add_argument('--controller-dir',type=Path,default=C);a=p.parse_args();C=a.controller_dir.resolve()
 if a.execute:execute(a.execute.resolve())
 else:prepare(a.ui.resolve(),a.target_group,a.boot_id)
if __name__=='__main__':main()
