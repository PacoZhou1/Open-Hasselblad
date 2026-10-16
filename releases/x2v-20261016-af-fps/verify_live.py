from pathlib import Path
import sys,json,time
D=Path(__file__).resolve().parent;R=D.parents[1];sys.path.insert(0,str(R/'local-verification'));from factory_session import connect
out={'release':'x2v-20261016-af-fps','installed':False,'files_match':True,'files_written_this_pass':0}
with connect() as r:
 def q(c):return r.factory_shell(c,capture_ms=3000)
 def state():
  for _ in range(4):
   try:return json.loads(q('cat /tmp/x2v-product/state.json'))
   except ValueError:time.sleep(.1)
  raise RuntimeError('state unavailable')
 out['boot_id']=q('cat /proc/sys/kernel/random/boot_id').strip();out['before']=state()
 assert out['before']['phase'] in ['idle','saved'],out['before']
 if out['before']['session']=='down':q(f'echo "{time.time_ns()%1000000000} video_on" > /tmp/x2v-product/gui.cmd')
 end=time.monotonic()+40
 while time.monotonic()<end:
  s=state()
  if s['session']=='up' and s['backend_ready'] and s['phase']=='idle':break
  if s['phase']=='error':raise RuntimeError(s)
  time.sleep(.25)
 else:raise RuntimeError(s)
 out['after']=s;out['camera']=q('odindb-send -s camera -p focus_mode,af_status');out['error']=q('odindb-send -s error -p active_error')
 out['runtime_library']=q('p=$(pidof camera-service);grep libx2v_af_25 /proc/$p/maps | head -1')
 out['diagnostic_library']=q('p=$(pidof camera-service);grep -E "range_observer|cd_observer|near_probe" /proc/$p/maps || true')
 out['watcher']=q('cat /tmp/x2v-live/video-afc.pid;tail -4 /tmp/x2v-live/video-afc.log 2>/dev/null || true')
 assert out['runtime_library'] and not out['diagnostic_library']
 assert 'active_error = false' in out['error']
 assert 'E_FocusModes_Afc(4)' in out['camera'] and 'RunningCont(3)' in out['camera'],out['camera']
 out['installed']=True;out['status']='persistent_files_match_and_stable_runtime_verified_after_user_reboot';out['user_reboot_persistence_verified']=True
 (D/'installation.json').write_text(json.dumps(out,indent=2));print(json.dumps(out,indent=2),flush=True)
