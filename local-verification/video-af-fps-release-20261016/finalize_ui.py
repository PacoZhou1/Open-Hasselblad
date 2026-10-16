from pathlib import Path
import subprocess,time,json,sys
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parent));from factory_session import connect
B='/blackbox/x2v-native-20261011';ST=B+'/fps-release-20261016';G=B+'/gui'
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],text=True,capture_output=True,check=True,timeout=15).stdout
adb('push',str(D/'RecordingProfiles.qml'),G+'/RecordingProfiles.qml.new')
with connect() as r:
 def q(c):assert len(c.encode())<=231,c;return r.factory_shell(c,capture_ms=5000)
 def st():
  for _ in range(4):
   try:return json.loads(q('cat /tmp/x2v-product/state.json'))
   except ValueError:time.sleep(.1)
  raise RuntimeError('state')
 def cmd(c):q('echo "%d %s" > /tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
 def wait(up):
  end=time.monotonic()+40
  while time.monotonic()<end:
   s=st()
   if s['session']==('up' if up else 'down') and s['phase'] not in ('entering','exiting'):return s
   time.sleep(.25)
  raise RuntimeError(s)
 assert 'E_FocusModes_Man(8)' in q('odindb-send -s camera -p focus_mode')
 for name in ['tof-context-2.bin','tof-param-2.bin']:
  try:adb('pull',ST+'/'+name,str(D/('cycle-'+name)))
  except Exception:pass
 q('touch /tmp/x2v-live/video-afc.stop;timeout 3 odindb-send -s camera -m stop_session;true')
 cmd('video_off');wait(False)
 q(f'rm -f {B}/video/af-diagnostic-pause /tmp/x2v-near-dump')
 q(f'mv {G}/RecordingProfiles.qml.new {G}/RecordingProfiles.qml')
 q('kill -TERM $(pidof camera-gui);true')
 time.sleep(1)
 cmd('video_on');wait(True)
 report={'state':st(),'focus':q('odindb-send -s camera -p focus_mode,af_status;true'),'error':q('odindb-send -s error -p active_error;true'),'selection':q(f'cat {B}/product/profile'),'library':q('p=$(pidof camera-service);grep libx2v_explore_toflimits /proc/$p/maps | head -1')}
 q(f'echo settings > {B}/gui-cmd');time.sleep(.7)
 q(f'echo shot{int(time.time())} > {B}/gui-cmd');time.sleep(.5)
 print(json.dumps(report,indent=2),flush=True);(D/'final-state.json').write_text(json.dumps(report,indent=2))
