from pathlib import Path
import sys,json,time,subprocess,datetime,hashlib
D=Path(__file__).resolve().parent;R=D.parents[1];sys.path.insert(0,str(D.parent));from factory_session import connect
P=R/'releases/x2v-20261021-classonly-24-25';M=json.loads((P/'manifest.json').read_text());ST='/blackbox/x2v-native-20261011/classonly-release-20261021'
OLD='/system/etc/x2v/x2v_product_boot_20261017a.sh';NEW='/system/etc/x2v/x2v_product_boot_20261021a.sh';PENDING=NEW+'.pending'
archives=[('/system/lib64/libx2v_cd_observer_20261016.so','e2ae59a1fed57dab05bf0907019cf77a036f45022f6d4008f1a093cefb6a762f'),('/system/lib64/libx2v_range_observer_20261016.so','3da12f9eb5945c93d81c67ba06ecda4a19099b4a468918699c9513ae735affdc')]
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,check=True,timeout=25).stdout
lock=D.parent/'camera-testing.lock/owner.json';owner=json.loads(lock.read_text());assert owner['state']=='IDLE' and owner['owner']=='codex-preview-debug'
adb('shell','mkdir -p '+ST+'/archive')
for i,a in enumerate(M['assets']):adb('push',str(P/a['file']),ST+'/asset'+str(i))
# Dependencies are installed first; the permanent boot selector is published only after live tests.
lines=['#!/system/bin/sh','set -e','mount -o remount,rw /system',"trap 'mount -o remount,ro /system' EXIT"]
for src,h in archives:
 backup=ST+'/archive/'+Path(src).name
 lines += [f'echo "{h}  {src}" | sha256sum -c -',f'cp {src} {backup}',f'echo "{h}  {backup}" | sha256sum -c -',f'rm {src}']
for i,a in enumerate(M['assets']):
 dest=PENDING if a['destination']==NEW else a['destination'];lines += [f'test ! -e {dest}',f'echo "{a["sha256"]}  {ST}/asset{i}" | sha256sum -c -',f'cp {ST}/asset{i} {dest}.tmp',f'chmod {a["mode"]} {dest}.tmp',f'mv {dest}.tmp {dest}',f'restorecon {dest}']
lines += ['echo OK_install_dependencies'];(D/'install-device.sh').write_text('\n'.join(lines)+'\n');adb('push',str(D/'install-device.sh'),ST+'/install.sh')
report={'release':M['release'],'archives':archives,'recordings':[]};stopped=False;newpid=None;published=False
with connect() as r:
 def q(c):
  assert len(c.encode())<=231,c
  return r.factory_shell(c,capture_ms=2500)
 def readjson(path):
  for _ in range(6):
   try:return json.loads(q('cat '+path))
   except ValueError:time.sleep(.1)
  raise RuntimeError('no json '+path)
 def state():return readjson('/tmp/x2v-product/state.json')
 def cmd(c):q('echo "%d %s" >/tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
 def wait(pred,seconds=30):
  end=time.monotonic()+seconds;last=None
  while time.monotonic()<end:
   s=state();v=(s['supervisor_pid'],s['profile_id'],s['mode'],s['session'],s['phase'])
   if v!=last:print(v,flush=True);last=v
   if pred(s):return s
   if s['phase']=='error':raise RuntimeError(s)
   time.sleep(.2)
  raise RuntimeError(s)
 def down():
  cmd('video_off');return wait(lambda s:s['session']=='down' and s['phase'] not in ('exiting','entering'))
 def up():
  cmd('video_on');return wait(lambda s:s['session']=='up' and s['backend_ready'] and s['phase']=='idle')
 def launch(path):
  p=q(f'toybox nohup sh {path} >{ST}/launch.log 2>&1 </dev/null & echo $!').strip();assert p.isdigit(),p
  adb('shell',f'p=$(pidof adbd);echo {p} > /acct/uid_0/pid_$p/cgroup.procs');return int(p)
 def big(path,name):
  q('cp '+path+' '+ST+'/'+name);a=adb('shell','cat '+ST+'/'+name);(D/name).write_text(a);return json.loads(a)
 report['before']=state();assert report['before']['phase'] in ('idle','saved')
 # Check stale diagnostic libraries are unused before archiving them.
 for src,h in archives:
  assert not q('p=$(pidof camera-service);grep '+Path(src).name+' /proc/$p/maps;true').strip()
  assert not q('grep -rl '+Path(src).name+' /system/etc/x2v;true').strip()
 owner.update(state='TESTING',task='Install and verify permanent class-only PRR 24/25fps');lock.write_text(json.dumps(owner,indent=2))
 try:
  if report['before']['session']=='up':down()
  q('kill -TERM '+str(report['before']['supervisor_pid'])+';kill -TERM $(pidof camera-gui);true');stopped=True
  report['install_output']=q('sh '+ST+'/install.sh');assert 'OK_install_dependencies' in report['install_output']
  newpid=launch(PENDING);wait(lambda s:s['supervisor_pid']==newpid,12)
  for fps,minimum in [(25,125),(24,72)]:
   cmd('profile_raw_3920_2946_'+str(fps));wait(lambda s:s['profile_id']=='raw_3920_2946_'+str(fps),8);ready=up()
   mapped=q('p=$(pidof camera-service);grep libx2v_classonly /proc/$p/maps | head -1');assert 'classonly'+str(fps)+'_' in mapped,mapped
   t=time.monotonic();cmd('start');wait(lambda s:s['phase']=='recording',12);start_time=time.monotonic()-t
   until=time.monotonic()+12
   while time.monotonic()<until:
    v=readjson('/tmp/x2v-live/status.json')
    if v['written']>=minimum:break
    time.sleep(.25)
   else:raise RuntimeError(v)
   t=time.monotonic();cmd('stop');wait(lambda s:s['phase']=='saved',20);stop_time=time.monotonic()-t
   live=readjson('/tmp/x2v-live/status.json');path=q('tail -n1 /blackbox/x2v-native-20261011/product/job-stop.out').strip();assert path.endswith('.mov'),path
   ident=Path(path).stem;meta=big('/mnt/media_rw/ssd/X2V_RAW/.x2v-meta/'+ident+'.json','clip-'+str(fps)+'.json')
   item={'fps':fps,'path':path,'metadata':meta,'status':live,'start_seconds':start_time,'stop_seconds':stop_time,'mapping':mapped};report['recordings'].append(item);print('REC',fps,meta,flush=True)
   assert live['lost']==0 and live['error']==0 and live['written']>=minimum,live
   assert 'active_error = false' in q('odindb-send -s error -p active_error')
   down()
  # Publish the new boot name; weston's existing version picker selects it on boot.
  q('mount -o remount,rw /system')
  try:q('mv '+PENDING+' '+NEW+';restorecon '+NEW)
  finally:q('mount -o remount,ro /system')
  published=True
  report['asset_readback']=[]
  for a in M['assets']:
   actual=adb('shell','sha256sum '+a['destination']).split()[0];assert actual==a['sha256'];report['asset_readback'].append({'path':a['destination'],'matches':True})
  # Recreate the compositor-owned boot path, rather than leaving a manually launched supervisor.
  q('kill -TERM '+str(newpid)+';kill -TERM $(pidof camera-gui);true');newpid=None
  q('setprop ctl.restart weston')
  after=wait(lambda s:s['supervisor_pid']!=report['before']['supervisor_pid'] and s['supervisor_pid']!=int(report.get('trial_pid',0)) and s['supervisor_pid']!=0,20)
  # Wait for the prior pending process to be replaced, not just its stale state file.
  end=time.monotonic()+20
  while time.monotonic()<end:
   s=state();c=q('tr "\\0" " " </proc/'+str(s['supervisor_pid'])+'/cmdline;true')
   if NEW in c and '.pending' not in c:report['automatic_boot_cmdline']=c;break
   time.sleep(.2)
  else:raise RuntimeError('new boot did not automatically launch')
  newpid=s['supervisor_pid'];report['auto_start']=s
  cmd('profile_raw_3920_2946_25');wait(lambda s:s['profile_id']=='raw_3920_2946_25',8);report['after']=up()
  report['system_mount']=q('grep " /system " /proc/mounts');assert ' ro,' in report['system_mount']
  report['error']=q('odindb-send -s error -p active_error');assert 'active_error = false' in report['error']
  report['gui']=readjson('/tmp/x2v-product/gui-state.json')
  report['installed']=True;report['compositor_autostart_verified']=True;report['full_camera_reboot_tested']=False
 except Exception as e:
  report['failure']=repr(e)
  try:
   s=state()
   if s['phase'] in ('recording','starting','finalizing'):cmd('stop');wait(lambda s:s['phase'] in ('saved','idle'),20)
   if s['session']=='up':down()
   if newpid:q('kill -TERM '+str(newpid)+';kill -TERM $(pidof camera-gui);true')
   if published:
    q('mount -o remount,rw /system')
    try:q('mv '+NEW+' '+NEW+'.disabled')
    finally:q('mount -o remount,ro /system')
   if stopped:
    oldpid=launch(OLD);wait(lambda s:s['supervisor_pid']==oldpid,15);cmd('profile_'+report['before']['profile_id']);wait(lambda s:s['profile_id']==report['before']['profile_id'],8);report['restored']=up()
  except Exception as e2:report['recovery_error']=repr(e2)
  raise
 finally:
  (D/'install-result.json').write_text(json.dumps(report,indent=2));print(json.dumps(report),flush=True)
  owner.update(state='IDLE' if report.get('installed') or 'restored' in report or not stopped else 'RECOVERY_REQUIRED',task='Class-only PRR 24/25 permanent installation' if report.get('installed') else 'Install failed; see install-result.json',updated_at=datetime.datetime.now().isoformat());lock.write_text(json.dumps(owner,indent=2))
