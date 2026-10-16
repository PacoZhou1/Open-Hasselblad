"""Exercise AF/MF/video-exit transitions with a fake native control service."""
from pathlib import Path
import tempfile,os,subprocess,time,json
D=Path(__file__).resolve().parent
with tempfile.TemporaryDirectory() as tmp:
 t=Path(tmp);(t/'service.pid').write_text(str(os.getpid()));(t/'session').write_text('up');(t/'focus').write_text('E_FocusModes_Afc(4)');(t/'active').write_text('E_AutoFocusStatus_Idle(0)');(t/'uptime').write_text('123 0\n');(t/'events').touch();(t/'af-context').write_text('viewfinder')
 tool=t/'odindb-send'
 tool.write_text('''#!/usr/bin/env python3
from pathlib import Path
import os,sys
p=Path(os.environ['AF_TEST_DIR']);a=sys.argv
if 'find_focus' in a:
 (p/'active').write_text('E_AutoFocusStatus_RunningCont(3)')
 with (p/'events').open('a') as f:f.write('start\\n')
elif 'stop_session' in a:
 (p/'active').write_text('E_AutoFocusStatus_Idle(0)')
 with (p/'events').open('a') as f:f.write('stop\\n')
elif '--' in a:(p/'focus').write_text('E_FocusModes_Afc(4)')
else:print('focus_mode = '+(p/'focus').read_text()+'\\naf_status = '+(p/'active').read_text())
''');tool.chmod(0o755)
 timeout=t/'timeout';timeout.write_text('#!/bin/sh\nshift\nexec "$@"\n');timeout.chmod(0o755)
 s=(D/'video-afc-watch.sh').read_text().replace('LIVE=/tmp/x2v-live','LIVE='+str(t)).replace('/proc/uptime',str(t/'uptime')).replace('/tmp/x2v-product/af-context',str(t/'af-context'));(t/'watch.sh').write_text(s)
 env=dict(os.environ,AF_TEST_DIR=str(t),PATH=str(t)+':'+os.environ['PATH'])
 def until(pred):
  end=time.monotonic()+3
  while time.monotonic()<end:
   if pred():return
   time.sleep(.05)
  raise AssertionError(((t/'events').read_text(),(t/'log').read_text()))
 with (t/'log').open('w') as log:
  p=subprocess.Popen(['sh',str(t/'watch.sh'),str(os.getpid())],env=env,stdout=log,stderr=log)
  try:
   until(lambda:(t/'events').read_text()=='start\n')
   time.sleep(.6);assert (t/'events').read_text()=='start\n'
   (t/'focus').write_text('E_FocusModes_Man(8)');until(lambda:(t/'events').read_text()=='start\nstop\n')
   time.sleep(.6);assert (t/'active').read_text()=='E_AutoFocusStatus_Idle(0)'
   (t/'focus').write_text('E_FocusModes_Afc(4)');until(lambda:(t/'events').read_text()=='start\nstop\nstart\n')
   (t/'af-context').write_text('navigation');until(lambda:(t/'events').read_text()=='start\nstop\nstart\nstop\n')
   time.sleep(.6);assert (t/'active').read_text()=='E_AutoFocusStatus_Idle(0)'
   (t/'af-context').write_text('viewfinder');until(lambda:(t/'events').read_text()=='start\nstop\nstart\nstop\nstart\n')
   (t/'video-afc.stop').touch();p.wait(timeout=5)
   assert (t/'events').read_text()=='start\nstop\nstart\nstop\nstart\nstop\n'
   assert not (t/'video-afc.pid').exists()
   result={'idle_af':True,'no_repeated_start':True,'mf_stops':True,'af_resumes':True,'video_exit_stops':True,'navigation_pauses':True,'return_resumes':True,'physical_ring_verified':False}
   (D/'host-test.json').write_text(json.dumps(result,indent=2)+'\n');print(result)
  finally:
   if p.poll() is None:p.terminate();p.wait(timeout=5)
