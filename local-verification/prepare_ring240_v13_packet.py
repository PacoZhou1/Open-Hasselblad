"""Offline derivative of proven fast15 lifecycle; fixed 10s/240-frame RX13."""
from pathlib import Path
import json,re,hashlib,subprocess,difflib
R=Path(__file__).resolve().parents[1];E=R/'native-video/experimental'
B=E/'source-session-isolated-target-ring72-fast15';N=E/'source-session-isolated-target-ring240-v13-c24'
RX=E/'source-receiver-adapter/receiver_v13_mode21c24_ring240_direct'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not (N/'freeze.json').exists(),'frozen candidate may not be regenerated'
N.mkdir(exist_ok=True)
f=json.loads((RX/'freeze.json').read_text())
assert f['receipt_version']==13 and f['max_count']==240 and f['constructor_ms']==47000
c=(B/'controller.sh').read_text()
for old,new in [('isolated-target-ring72-fast15','isolated-target-ring240-v13-c24'),('ring72','ring240'),('RING72','RING240'),('1683320832','5611069440'),('3000000000','10000000000'),('40000000000','47000000000'),('3145728','7340032'),('V12_ACK','V13_ACK'),('strict v12','strict v13')]:c=c.replace(old,new)
c=re.sub(r'\b72\b','240',c)
c=c.replace('\\"version\\":12','\\"version\\":13')
c=re.sub(r'^RECEIVER_SHA=\w+$','RECEIVER_SHA='+f['artifact_sha256'],c,flags=re.M)
c=c.replace('frame_until=$(( $(uptime_seconds)+10 ))','frame_until=$(( $(uptime_seconds)+20 ))')
c=c.replace('fixed ~40s constructor polling budget','fixed ~47s constructor polling budget').replace('>=16s for3s capture','>=23s for10s capture')
c=c.replace('inherited v12 direct writer','v13 direct writer; unchanged fast15 native stop/recovery')
assert '\\"version\\":13' in c and '\\"version\\":12' not in c
# Config confirmation is linear in the ACK size; exact schema was just validated.
old=''' function val(key, text) {
  if(!match($0,"\\\"" key "\\\":-?[0-9]+")) return -9007199254740991
  text=substr($0,RSTART,RLENGTH);sub(/^[^:]*:/,"",text);return text+0
 }
 NR==1 {
  count=val("frames_copied");if(count<2 || count>240)bad=1'''
new=''' function val(key) {return key in v ? v[key] : -9007199254740991}
 NR==1 {
  n=split($0,a,",")
  for(i=1;i<=n;i++)if(a[i] ~ /^"(frames_copied|frame[0-9]+_(mem_flags_rc|mem_flags|mem_fd_rc))":-?[0-9]+$/){
   at=index(a[i],":"); key=substr(a[i],2,at-3);v[key]=substr(a[i],at+1)+0
  }
  count=val("frames_copied");if(count<2 || count>240)bad=1'''
assert c.count(old)==1,'config parser exact source drift'
c=c.replace(old,new)
(N/'controller.sh').write_text(c)
for name in ['bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf']:
 t=(B/name).read_text().replace('isolated-target-ring72-fast15','isolated-target-ring240-v13-c24')
 if name=='bootstrap.sh':t=re.sub(r'^CONTROLLER_SHA=\w+$','CONTROLLER_SHA='+sha(N/'controller.sh'),t,flags=re.M)
 (N/name).write_text(t)
for name in ['controller.sh','bootstrap.sh','guard.sh']:
 subprocess.run([str(R/'native-video/outputs/runtime/mksh-r56-host/mksh'),'-n',str(N/name)],check=True)
 (N/(name+'.diff')).write_text(''.join(difflib.unified_diff((B/name).read_text().splitlines(True),(N/name).read_text().splitlines(True),fromfile='fast15/'+name,tofile='ring240/'+name)))
# Save exact embedded ACK and flag validator for the focused independent oracle.
start=c.index('function value(key)') if 'function value(key)' in c else c.index('function value(key,')
end=c.index("\n ' \"$RUN/receiver.receipt\"",start)
(N/'receipt_gate.awk').write_text(c[start:end]+'\n')
start=c.index(' function val(key)');end=c.index("\n ' \"$RUN/receiver.receipt\"",start)
(N/'config_gate.awk').write_text(c[start:end]+'\n')
h=(R/'local-verification/isolated_target_ring72_fast15_test.py').read_text().replace('source-session-isolated-target-ring72-fast15','source-session-isolated-target-ring240-v13-c24').replace("MODE='isolated-target-ring72-fast15'","MODE='isolated-target-ring240-v13-c24'").replace('ring72 v12','ring240 v13').replace('V12_ACK','V13_ACK')
old_final="  try:report['locks_absent']=adb('shell','test ! -e '+REMOTE+'/source-session.lock && test ! -e /data/x2v-native-20261012/gui-session.lock && test ! -e /blackbox/x2v-native-20261011/gui-session.lock && echo CLEAR').strip()=='CLEAR'"
new_final="""  try:
   with connect() as f:
    report['locks_absent']=all(q(f,'test ! -e '+lock+' && test ! -L '+lock+' && echo CLEAR').strip()=='CLEAR' for lock in [REMOTE+'/source-session.lock','/data/x2v-native-20261012/gui-session.lock','/blackbox/x2v-native-20261011/gui-session.lock'])"""
assert h.count(old_final)==1
h=h.replace(old_final,new_final)
(R/'local-verification/isolated_target_ring240_v13_test.py').write_text(h)
contract={'mode':'isolated-target-ring240-v13-c24','execution_approved':False,'receiver_path':f['system_path_candidate'],'receiver_sha256':f['artifact_sha256'],'receiver_freeze_sha256':sha(RX/'freeze.json'),'receipt_version':13,'max_frame_count':240,'max_payload_bytes':5611069440,'admission_ns':10000000000,'constructor_ms':47000,'pool_bytes':70138368,'ssd_min_available_kib':7340032,'max_launch_age_before_arm_s':24,'frame_observation_limit_s':20,'native_watchdog_s':150,'bound_boot':'80026cc1-5987-40c7-a271-f68e8165c424','bound_group':'/uid_0/pid_5258','runtime_files':{n:sha(N/n) for n in ['controller.sh','bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf']},'host_runner_sha256':sha(R/'local-verification/isolated_target_ring240_v13_test.py'),'review_status':'DRAFT awaiting focused ACK checks and independent lifecycle delta review','bulk_sha':False,'full_host_readback':False}
(N/'draft-contract.json').write_text(json.dumps(contract,indent=2)+'\n')
print(N)
