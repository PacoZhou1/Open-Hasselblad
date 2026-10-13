"""Fixed isolated resident mode21 two-clip v16 DNG; default offline. Root is sole camera owner."""
from pathlib import Path
from datetime import datetime
import argparse, hashlib, json, re, secrets, subprocess, time
from factory_session import connect
from source_session_test import STATE,NORMAL
ROOT=Path(__file__).resolve().parents[1]
CANDIDATE=ROOT/'native-video/experimental/source-session-isolated-two-v20c-metadata'
HOLD=ROOT/'local-verification/source_session_execution_hold.json'
MODE='isolated-two-v20c-metadata'
TARGET='/uid_0/pid_3102'
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
 assert adb('shell','cat /proc/sys/kernel/random/boot_id').strip()=='41867eda-01a6-4809-b1d0-ebedba61dce4'
 assert '2:cpuacct:'+TARGET in adb('shell','cat /proc/self/cgroup').splitlines()
 freeze=json.loads((CANDIDATE/'freeze.json').read_text())
 assert freeze['mode']==MODE and set(freeze['runtime_files'])=={'controller.sh','bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf'}
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
   with connect() as f: assert q(f,'test ! -e '+lock+' && test ! -L '+lock+' && echo CLEAR').strip()=='CLEAR'
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
  guard_ready_until=time.monotonic()+5
  while time.monotonic()<guard_ready_until:
   if read('adb-guard.ready') and read('adb-guard.heartbeat'):break
   time.sleep(.05)
  else:raise RuntimeError('No guard ready/heartbeat completion')
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
  attach="now=$(/system/bin/x2v_guard_clock_20261012b); if [ \"$now\" -ge "+fresh[13]+" ] && [ \"$now\" -lt "+fresh[14]+" ] && [ ! -e "+remote+"/passive.stop ]; then if printf '%s\\n' "+pid+" > /acct/uid_0/pid_3102/cgroup.procs; then echo OWNED_ATTACH_WRITE_OK; else echo OWNED_ATTACH_WRITE_DENIED; fi; else echo OWNED_ATTACH_EXPIRED; fi"
  report['attach_reply']=adb('shell',attach);assert 'OWNED_ATTACH_WRITE_OK' in report['attach_reply']
  migrated=wait_record('passive.migrated','migrated',challenge,4);assert migrated[5:11]==ready[5:11] and migrated[11]==TARGET;report['migrated']=migrated
  report['controller_released']=True
  put('passive.go',f'v1 {run} {nonce} {challenge}\n')
  # Source transitions never issue HblShell. Existing native controller/wd own
  # all stream stop, frame closure, producer retirement and stock restoration.
  until=time.monotonic()+200;last=None
  while time.monotonic()<until:
   try:
    observation=adb('shell','cd '+remote+' && for n in phase body.rc recovery.rc restored;do if [ -f "$n" ];then echo FILE:$n;cat "$n";fi;done',timeout=3)
   except (subprocess.TimeoutExpired,RuntimeError) as e:
    # A transient read failure is not a stopped native owner. Reobserve this
    # exact run; never relaunch or cancel solely because one poll expired.
    report.setdefault('observation_errors',[]).append(repr(e));continue
   if observation!=last:print(observation.strip(),flush=True);report.setdefault('observations',[]).append(observation);last=observation
   if 'FILE:recovery.rc\n' in observation and 'FILE:restored\n' in observation:break
   if not observation.strip() and 'isolated_bootstrap_proof_required' in read('session.log'):
    raise RuntimeError('Controller rejected bootstrap before owner locks or imaging mutation')
   time.sleep(.2)
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
  try:
   with connect() as f:
    report['locks_absent']=all(q(f,'test ! -e '+lock+' && test ! -L '+lock+' && echo CLEAR').strip()=='CLEAR' for lock in [REMOTE+'/source-session.lock','/data/x2v-native-20261012/gui-session.lock','/blackbox/x2v-native-20261011/gui-session.lock'])
  except BaseException as e:report['lock_error']=repr(e)
  d=out/'device-run'
  def local(name):p=d/name;return p.read_text().strip() if p.is_file() else None
  report['body_rc']=local('body.rc');report['recovery_rc']=local('recovery.rc')
  report['receiver_confirmed']=all((d/name).is_file() for name in ['receiver.confirmed','receiver2.confirmed'])
  events=local('events.log') or ''
  report['explicit_arm_confirmed']='RECEIVER_EXPLICIT_ARM_AFTER_GRAPH13_SETUP_ACK' in events
  report['receiver_capture_verified']=all(marker in events for marker in ['RECEIVER_CAPTURE_VERIFIED_V16_DNG_ACK_GEN1','RECEIVER_CAPTURE_VERIFIED_V16_DNG_ACK_GEN2'])
  report['dng_directory_verified']=all(marker in events for marker in ['RECEIVER_DNG_DIRECTORY_VERIFIED_GEN1','RECEIVER_DNG_DIRECTORY_VERIFIED_GEN2'])
  report['user_stop_confirmed']=all(marker in events for marker in ['RECEIVER_EXPLICIT_USER_STOP_GEN1','RECEIVER_EXPLICIT_USER_STOP_GEN2'])
  report['configuration_applied_verified']=all(marker in events for marker in ['RECEIVER_CONFIG_FLAGS17_CONFIRMED_GEN1','RECEIVER_CONFIG_FLAGS17_CONFIRMED_GEN2'])
  try:
   import sys
   sys.path.insert(0,str(ROOT/'native-video/experimental/receipt-oracle-v16-dng'))
   import ack_contract
   receipts=[json.loads((d/name).read_text()) for name in ['receiver.receipt','receiver2.receipt']]
   pair=ack_contract.validate_pair(*receipts)
   from dng_capture_metrics import measure
   report['delivery_metrics']=[measure(rx) for rx in receipts]
   report['short_trial_24fps_delivery_pass']=all(m['short_trial_24fps_delivery_pass'] for m in report['delivery_metrics'])
   from decode_raw_native_metadata import read_manifest
   report['native_metadata']=[read_manifest(d/name) for name in ['dng.metadata.jsonl','dng2.metadata.jsonl']]
   assert all(m['frame_count']==rx['frames_written'] for m,rx in zip(report['native_metadata'],receipts))
   report['two_clip_oracle_verified']=True
   summary={'passed':True,'clips':[{'generation':rx['clip_generation'],'frames':rx['frames_written'],'bytes':rx['bytes_written'],'stop_reason':rx['stop_reason'],'arm_to_closed_seconds':(rx['admission_closed_ns']-rx['arm_ns'])/1e9,'stop_to_writer_done_seconds':(rx['writer_done_ns']-rx['admission_closed_ns'])/1e9} for rx in receipts],'interclip_arm_gap_seconds':(receipts[1]['arm_ns']-receipts[0]['admission_closed_ns'])/1e9,'scope':'two DNG captures, directory integrity and native lifecycle checked separately','full_raw_readback':False}
   (out/'capture-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
  except (OSError,AssertionError,KeyError,TypeError,ValueError) as e:
   report['two_clip_oracle_verified']=False;report['two_clip_oracle_error']=repr(e)
  report['passed']=bool(report['two_clip_oracle_verified'] and not report.get('failure') and report['body_rc']=='0' and report['recovery_rc']=='0' and (d/'restored').is_file() and report['receiver_confirmed'] and report['explicit_arm_confirmed'] and report['receiver_capture_verified'] and report['dng_directory_verified'] and report['user_stop_confirmed'] and report['configuration_applied_verified'] and report.get('locks_absent') and report.get('after') and normal(report['after']))
  if (d/'restored').is_file() or not report['controller_released']:
   try:put('guard.stop',f'v1 {run} {nonce} {boot}\n')
   except BaseException as e:report['guard_stop_error']=repr(e)
  report['bulk_hash_verified']=False
  report['full_host_readback_verified']=False
  (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
  print(json.dumps({'report':str(out/'report.json'),'passed':report['passed'],'failure':report.get('failure')},indent=2))
 return 0 if report['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
