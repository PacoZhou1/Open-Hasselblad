"""Fixed isolated native carrier v7; default offline. Root is sole camera owner."""
from pathlib import Path
from datetime import datetime
import argparse, hashlib, json, re, secrets, subprocess, time
from factory_session import connect
from source_session_test import STATE,NORMAL
ROOT=Path(__file__).resolve().parents[1]
CANDIDATE=ROOT/'native-video/experimental/source-session-isolated-carrier-v7b'
HOLD=ROOT/'local-verification/source_session_execution_hold.json'
MODE='isolated-carrier-v7'
TARGET='/uid_0/pid_2279'
DOMAIN='u:r:hbl_camera_service:s0'
REMOTE='/data/x2v-source-20261012'

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def adb(*args,timeout=15):
 r=subprocess.run(['adb','-s','123456789ABCDEF',*args],capture_output=True,text=True,timeout=timeout)
 if r.returncode:raise RuntimeError(f'ADB failed {args!r}: {r.stdout} {r.stderr}')
 return r.stdout

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');a=ap.parse_args()
 if not a.execute:
  print(json.dumps({'offline':True,'mode':MODE,'candidate':str(CANDIDATE),'held':HOLD.exists()}));return 0
 if HOLD.exists() and MODE not in json.loads(HOLD.read_text()).get('released_modes',[]):
  raise RuntimeError('Isolated source mode remains held before any device request')
 freeze=json.loads((CANDIDATE/'freeze.json').read_text())
 assert freeze['mode']==MODE and set(freeze['runtime_files'])=={'controller.sh','bootstrap.sh','guard.sh'}
 for name,digest in freeze['runtime_files'].items():assert sha(CANDIDATE/name)==digest
 run='source-isolated-'+datetime.now().strftime('%H%M%S');out=ROOT/'native-video/outputs'/run;out.mkdir()
 remote=REMOTE+'/runs/'+run;nonce=secrets.token_hex(16);challenge=secrets.token_hex(16)
 report={'run_id':run,'mode':MODE,'passed':False,'bootstrap_dispatched':False,'attach_attempted':False,'controller_released':False,'freeze':freeze}
 def q(f,cmd):
  assert len(cmd.encode())<=231
  v=f.factory_shell(cmd,capture_ms=5000);report.setdefault('factory_queries',[]).append({'command':cmd,'output':v});return v
 def put(name,value):
  p=out/name;p.write_text(value);tmp=remote+'/'+name+'.upload';adb('push',str(p),tmp)
  assert adb('shell','sha256sum '+tmp).split()[0]==sha(p)
  adb('shell','test ! -e '+remote+'/'+name+' && mv '+tmp+' '+remote+'/'+name)
 def read(name):return adb('shell','if [ -f '+remote+'/'+name+' ];then cat '+remote+'/'+name+';fi')
 def clock():return int(adb('shell','/system/bin/x2v_guard_clock_20261012b').strip())
 def snap():
  if adb('shell','getprop init.svc.camera-service').strip()!='running':raise RuntimeError('No HblShell health query during source ownership transition')
  with connect() as f:
   return {'state':q(f,STATE),'processes':q(f,'pidof camera-service;pidof camera-gui;pidof camera-test;getprop init.svc.camera-service;getprop init.svc.camera-gui'),'mount':q(f,'mount | grep " /system "')}
 def normal(s):return all(x in s['state'].splitlines() for x in NORMAL) and s['processes'].splitlines()[3:]==['running','running'] and '(ro,' in s['mount']
 def record(name,kind,token):
  raw=read(name)
  if not raw.endswith('\n') or len(raw.splitlines())!=1:return None
  x=raw.strip().split()
  if len(x)!=15 or x[:5]!=['v1',kind,run,nonce,token] or x[7]!=boot or x[10]!=DOMAIN or x[12]!=TARGET:return None
  if not all(re.fullmatch('[0-9]+',x[i]) for i in [5,6,8,9,13,14]):return None
  if x[5]!=x[8] or x[5]!=x[9] or int(x[5])<2:return None
  return x
 def wait_record(name,kind,token,seconds):
  until=time.monotonic()+seconds
  while time.monotonic()<until:
   x=record(name,kind,token)
   if x:return x
   time.sleep(.1)
  raise RuntimeError('Missing canonical '+name)
 try:
  report['before']=snap();assert normal(report['before'])
  for lock in [REMOTE+'/source-session.lock','/data/x2v-native-20261012/gui-session.lock','/blackbox/x2v-native-20261011/gui-session.lock']:
   assert adb('shell','test ! -e '+lock+' && echo CLEAR').strip()=='CLEAR'
  with connect() as f: raw=q(f,'p=$(pidof camera-test);cat /proc/$p/stat;cat /proc/$p/cgroup')
  lines=raw.strip().splitlines();fp=lines[0].split()[0];fields=lines[0].rsplit(') ',1)[1].split();fs=fields[19];fpg=fields[2]
  assert '2:cpuacct:/uid_0/pid_'+fp in lines
  boot=adb('shell','cat /proc/sys/kernel/random/boot_id').strip();now=clock()
  adb('shell','test ! -e '+remote+' && mkdir '+remote)
  for name,digest in freeze['runtime_files'].items():
   adb('push',str(CANDIDATE/name),remote+'/'+name)
   assert adb('shell','sha256sum '+remote+'/'+name).split()[0]==digest
  put('passive.binding',f'v1 {run} {nonce} {boot} {fp} {fs} {fpg} {now+85}\n')
  put('guard.binding',f'v1 {run} {nonce} {boot} {now+270}\n')
  report['guard_launch']=adb('shell','toybox nohup sh '+remote+'/guard.sh --guard '+run+' </dev/null >'+remote+'/guard.log 2>&1 & echo $!')
  time.sleep(1.3)
  gr=read('adb-guard.ready').strip().split();gh=read('adb-guard.heartbeat').strip().split()
  assert len(gr)==8 and gr[:3]==['v1',run,nonce] and gr[5]==TARGET and gr[3]==gr[6] and gr[7]==boot
  assert len(gh)==5 and gh[:4]==['v1',run,nonce,gr[3]] and 0<=clock()-int(gh[4])<=5
  report['guard_ready']=gr
  with connect() as f:
   report['bootstrap_dispatched']=True
   report['bootstrap_launch']=q(f,'toybox nohup toybox setsid sh '+remote+'/bootstrap.sh --run '+run+' </dev/null >'+remote+'/session.log 2>&1 &')
  ready=wait_record('passive.ready','ready','-',8);assert ready[11]=='/uid_0/pid_'+fp;report['ready']=ready
  assert ready[5]!=gr[3]
  put('passive.challenge',f'v1 {run} {nonce} {challenge}\n')
  fresh=wait_record('passive.fresh','fresh',challenge,3);assert fresh[5:13]==ready[5:13];report['fresh']=fresh
  now=clock();assert 0<=now-int(fresh[13])<=2 and int(fresh[14])-now>=3
  pid=fresh[5];report['attach_attempted']=True
  attach="now=$(/system/bin/x2v_guard_clock_20261012b); if [ \"$now\" -ge "+fresh[13]+" ] && [ \"$now\" -lt "+fresh[14]+" ] && [ ! -e "+remote+"/passive.stop ]; then if printf '%s\\n' "+pid+" > /acct/uid_0/pid_2279/cgroup.procs; then echo OWNED_ATTACH_WRITE_OK; else echo OWNED_ATTACH_WRITE_DENIED; fi; else echo OWNED_ATTACH_EXPIRED; fi"
  report['attach_reply']=adb('shell',attach);assert 'OWNED_ATTACH_WRITE_OK' in report['attach_reply']
  migrated=wait_record('passive.migrated','migrated',challenge,4);assert migrated[5:11]==ready[5:11] and migrated[11]==TARGET;report['migrated']=migrated
  report['controller_released']=True
  put('passive.go',f'v1 {run} {nonce} {challenge}\n')
  # Source transitions never issue HblShell. Existing native controller/wd own
  # all stream stop, frame closure, producer retirement and stock restoration.
  until=time.monotonic()+145;last=None
  while time.monotonic()<until:
   observation=adb('shell','cd '+remote+' && for n in phase body.rc recovery.rc restored;do if [ -f "$n" ];then echo FILE:$n;cat "$n";fi;done')
   if observation!=last:print(observation.strip(),flush=True);report.setdefault('observations',[]).append(observation);last=observation
   if 'FILE:recovery.rc\n' in observation and 'FILE:restored\n' in observation:break
   if not observation.strip() and 'isolated_bootstrap_proof_required' in read('session.log'):
    raise RuntimeError('Controller rejected bootstrap before owner locks or imaging mutation')
   time.sleep(1)
  else:raise RuntimeError('Native lifecycle still unresolved at host deadline')
 except BaseException as e:
  report['failure']=repr(e)
  if report['controller_released']:
   try:report['abort_write']=adb('shell','test ! -L '+remote+'/abort && echo host_observation_failed >'+remote+'/abort')
   except BaseException as ae:report['abort_error']=repr(ae)
  elif report['bootstrap_dispatched']:
   try:put('passive.stop',f'v1 {run} {nonce}\n')
   except BaseException as se:report['bootstrap_stop_error']=repr(se)
 finally:
  try:adb('pull',remote,str(out/'device-run'),timeout=30)
  except BaseException as e:report['pull_error']=repr(e)
  try:
   report['after']=snap()
   # Diagnostic daemon may restart during the experiment without reaching the
   # isolated native owner. Recreate old keepawake guard only if native absent.
   with connect() as f:
    kpfile=ROOT/'local-verification/keepawake-state.json';ks=json.loads(kpfile.read_text());old=int(ks['camera_pid'])
    absent=q(f,'if [ ! -d /proc/'+str(old)+' ];then echo OLD_KEEPER_ABSENT;fi')
    if absent.strip()=='OLD_KEEPER_ABSENT':
     kp=q(f,'toybox nohup sh /blackbox/x2v-native-20261011/keepawake.sh </dev/null >/blackbox/x2v-native-20261011/keepawake.log 2>&1 & echo $!').strip();assert kp.isdigit()
     ks['camera_pid']=int(kp);ks['camera_watchdog_restart_reason']='factory changed during isolated source test';kpfile.write_text(json.dumps(ks,indent=2)+'\n');report['keepawake_pid']=int(kp)
     q(f,'odindb-send -s system -p screen_idle_timeout -- 0;odindb-send -s system -m set_screen_enabled -- true')
  except BaseException as e:report['health_error']=repr(e)
  try:report['locks_absent']=adb('shell','test ! -e '+REMOTE+'/source-session.lock && test ! -e /data/x2v-native-20261012/gui-session.lock && test ! -e /blackbox/x2v-native-20261011/gui-session.lock && echo CLEAR').strip()=='CLEAR'
  except BaseException as e:report['lock_error']=repr(e)
  d=out/'device-run'
  def local(name):p=d/name;return p.read_text().strip() if p.is_file() else None
  report['body_rc']=local('body.rc');report['recovery_rc']=local('recovery.rc')
  report['receiver_confirmed']=(d/'receiver.confirmed').is_file()
  events=local('events.log') or ''
  report['explicit_arm_confirmed']='RECEIVER_EXPLICIT_ARM_AFTER_ACTIVE_AND_FRAME_ADVANCEMENT' in events
  report['passed']=bool(not report.get('failure') and report['body_rc']=='0' and report['recovery_rc']=='0' and (d/'restored').is_file() and report['receiver_confirmed'] and report['explicit_arm_confirmed'] and report.get('locks_absent') and report.get('after') and normal(report['after']))
  if (d/'restored').is_file() or not report['controller_released']:
   try:put('guard.stop',f'v1 {run} {nonce} {boot}\n')
   except BaseException as e:report['guard_stop_error']=repr(e)
  (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
  print(json.dumps({'report':str(out/'report.json'),'passed':report['passed'],'failure':report.get('failure')},indent=2))
 return 0 if report['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
