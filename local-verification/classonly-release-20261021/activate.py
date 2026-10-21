from pathlib import Path
import json,sys,time,subprocess,datetime
D=Path(__file__).resolve().parent;R=D.parents[1];sys.path.insert(0,str(D.parent));from factory_session import connect
ST='/blackbox/x2v-native-20261011/classonly-release-20261021';NEW='/system/etc/x2v/x2v_product_boot_20261021a.sh';OLD='/system/etc/x2v/x2v_product_boot_20261017a.sh'
report={'recordings':[]};pid=None
lock=D.parent/'camera-testing.lock/owner.json';owner=json.loads(lock.read_text());assert owner['owner']=='codex-preview-debug'
owner.update(state='TESTING',task='Activate 24/25 class-only release and verify warm recording');lock.write_text(json.dumps(owner,indent=2))
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,check=True,timeout=20).stdout
with connect() as r:
 def q(c):
  assert len(c.encode())<=231,c
  return r.factory_shell(c,capture_ms=2500)
 def js(path):
  for _ in range(8):
   try:return json.loads(q('cat '+path))
   except ValueError:time.sleep(.1)
  raise RuntimeError('No json '+path)
 def st():return js('/tmp/x2v-product/state.json')
 def cmd(c):q('echo "%d %s" >/tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
 def wait(pred,seconds=30):
  end=time.monotonic()+seconds
  while time.monotonic()<end:
   s=st()
   if pred(s):return s
   if s['phase']=='error':raise RuntimeError(s)
   time.sleep(.2)
  raise RuntimeError(s)
 def down():
  cmd('video_off');return wait(lambda s:s['session']=='down' and s['phase'] not in ('entering','exiting'))
 def up():
  end=time.monotonic()+35;next_send=0
  while time.monotonic()<end:
   s=st()
   if s['session']=='up' and s['backend_ready'] and s['phase']=='idle':return s
   if s['mode']=='photo' and s['phase']=='idle' and time.monotonic()>next_send:cmd('video_on');next_send=time.monotonic()+2
   time.sleep(.2)
  raise RuntimeError(s)
 def big(src,name):
  q('cp '+src+' '+ST+'/'+name);q('chmod 644 '+ST+'/'+name)
  txt=adb('shell','cat '+ST+'/'+name);(D/name).write_text(txt);return json.loads(txt)
 def launch(path):
  p=q('toybox nohup sh '+path+' >'+ST+'/activate.log 2>&1 </dev/null & echo $!').strip();assert p.isdigit(),p
  adb('shell',f'p=$(pidof adbd);echo {p} > /acct/uid_0/pid_$p/cgroup.procs');return int(p)
 report['before']=st()
 try:
  if report['before']['session']=='up':down()
  q('kill -TERM '+str(report['before']['supervisor_pid'])+';kill -TERM $(pidof camera-gui);true')
  # Dependencies already installed and read back. Publish the versioned selector.
  q('mount -o remount,rw /system')
  try:q('mv '+NEW+'.disabled '+NEW+';restorecon '+NEW)
  finally:q('mount -o remount,ro /system')
  pid=launch(NEW);wait(lambda s:s['supervisor_pid']==pid,15)
  for fps in (25,24):
   cmd('profile_raw_3920_2946_'+str(fps));wait(lambda s:s['profile_id']=='raw_3920_2946_'+str(fps),10);up()
   for take in (1,2):
    cmd('start');wait(lambda s:s['phase']=='recording',12);end=time.monotonic()+9;progress=[]
    while time.monotonic()<end:
     v=js('/tmp/x2v-live/status.json');progress.append({k:v[k] for k in ('seconds','seen','written','dropped','lost')})
     if v['written']>=fps*3:break
     time.sleep(.35)
    cmd('stop');wait(lambda s:s['phase']=='saved',20);v=js('/tmp/x2v-live/status.json')
    path=q('tail -n1 /blackbox/x2v-native-20261011/product/job-stop.out').strip();assert path.endswith('.mov'),path
    name=Path(path).stem;meta=big('/mnt/media_rw/ssd/X2V_RAW/.x2v-meta/'+name+'.json',f'warm-{fps}-{take}.json')
    item={'fps':fps,'take':take,'path':path,'metadata':meta,'progress':progress};report['recordings'].append(item);print('REC',fps,take,'frames',meta['frames'],'dropped',meta['dropped'],'lost',meta['lost'],flush=True)
    assert meta['error']==0 and meta['lost']==0,meta
   down()
  cmd('profile_raw_3920_2946_25');wait(lambda s:s['profile_id']=='raw_3920_2946_25',8)
  # Leave startup to the existing weston module and verify the actual selected path.
  q('kill -TERM '+str(pid)+';kill -TERM $(pidof camera-gui);true');pid=None;q('setprop ctl.restart weston')
  end=time.monotonic()+25
  while time.monotonic()<end:
   s=st();c=q('tr "\\0" " " </proc/'+str(s['supervisor_pid'])+'/cmdline;true')
   if NEW in c:pid=s['supervisor_pid'];report['automatic_boot_cmdline']=c;break
   time.sleep(.2)
  else:raise RuntimeError('Auto start missing')
  report['after']=up();report['gui']=big('/tmp/x2v-product/gui-state.json','gui-state-final.json')
  report['error']=q('odindb-send -s error -p active_error');assert 'active_error = false' in report['error']
  report['mount']=q('grep " /system " /proc/mounts');assert ' ro,' in report['mount']
  report['installed']=True;report['compositor_autostart_verified']=True;report['full_camera_reboot_tested']=False
 except Exception as e:
  report['failure']=repr(e)
  try:
   s=st()
   if s['phase']=='recording':cmd('stop');wait(lambda s:s['phase']=='saved',20)
   if s['session']=='up':down()
   q('kill -TERM '+str(st()['supervisor_pid'])+';kill -TERM $(pidof camera-gui);true')
   q('mount -o remount,rw /system')
   try:q('test ! -f '+NEW+' || mv '+NEW+' '+NEW+'.disabled')
   finally:q('mount -o remount,ro /system')
   pid=launch(OLD);wait(lambda s:s['supervisor_pid']==pid,15);report['restored']=up()
  except Exception as e2:report['recovery_error']=repr(e2)
  raise
 finally:
  (D/'activation-result.json').write_text(json.dumps(report,indent=2));print(json.dumps(report),flush=True)
  owner.update(state='IDLE' if report.get('installed') or report.get('restored') else 'RECOVERY_REQUIRED',task='Permanent class-only 24/25 installed' if report.get('installed') else 'See activation-result.json',updated_at=datetime.datetime.now().isoformat());lock.write_text(json.dumps(owner,indent=2))
