"""Short fixed-rate ProRes trial; restores exact installed session in finally."""
import argparse,hashlib,json,subprocess,sys,time,re
from pathlib import Path
R=Path(__file__).resolve().parents[2];sys.path.insert(0,str(R/'local-verification'))
from factory_session import connect
p=argparse.ArgumentParser();p.add_argument('--trace',action='store_true');p.add_argument('--stats',action='store_true');p.add_argument('--route',action='store_true');p.add_argument('--lean',action='store_true');p.add_argument('--request',action='store_true');p.add_argument('--mem',action='store_true');a=p.parse_args();a.request=a.request or a.mem;a.lean=a.lean or a.request;a.route=a.route or a.lean;a.stats=a.stats or a.route;a.profile='toflimits';a.stats=True
C=R/'native-video/experimental'/('rx-prr-explore-'+a.profile+'-20261016')
O=Path(__file__).parent/(a.profile+'-button-install-'+time.strftime('%H%M%S'));O.mkdir()
ST='/blackbox/x2v-native-20261011/fps-explore';SESSION='/system/etc/x2v/x2v_video_session_20261014zl.sh'
LIB='/system/lib64/libx2v_explore_'+a.profile+'_20261015.so';CONF='/system/etc/x2v/explore_'+a.profile+'.conf'
report={'profile':a.profile,'restored':False};changed=False

def adb(*args):return subprocess.run(['adb','-s','123456789ABCDEF',*args],check=True,capture_output=True,text=True,timeout=30).stdout

_context=None
_reader=None
def q(cmd):
 global _context,_reader
 assert len(cmd.encode())<=231,cmd
 if _reader is None:
  _context=connect();_reader=_context.__enter__()
 try:return _reader.factory_shell(cmd,capture_ms=3000)
 except Exception:
  _context.__exit__(None,None,None);_context=None;_reader=None
  raise
import atexit
@atexit.register
def close_reader():
 if _context is not None:_context.__exit__(None,None,None)

def state():
 for _ in range(3):
  try:return json.loads(q("sed 's/\"detail\":\"[^\"]*\"/\"detail\":\"\"/' /tmp/x2v-product/state.json"))
  except ValueError:time.sleep(.05)
 raise RuntimeError('state read failed')

def cmd(c):q('echo "%d %s" > /tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))

def wait(pred,seconds=40):
 end=time.monotonic()+seconds;last=None
 while time.monotonic()<end:
  try:s=state()
  except Exception:
   time.sleep(.2);continue
  phase=(s['session'],s['phase'])
  if phase!=last:print(phase,flush=True);last=phase
  if pred(s):return s
  time.sleep(.2)
 raise RuntimeError(s)

def select(up):
 cmd('video_on' if up else 'video_off');time.sleep(.2)
 return wait(lambda s:s['session']==('up' if up else 'down') and s['phase'] in ('idle','saved'))

def install_session(src):
 q('mount -o remount,rw /system')
 try:q(f'L={SESSION};cp {src} $L && chmod 755 $L && restorecon $L')
 finally:q('mount -o remount,ro /system')

def clear_usb_notice():
 value=q('odindb-send -s error -p active_error,current_error;true')
 if 'active_error = false' in value:return value
 # Dismiss only the known USB-connected notification; never suppress faults.
 if not (re.search(r'\bE_ErrorCode_UsbConnected\(40\)',value) or
         re.search(r'^current_error = Item \{ACTION = 1, CAT = 5, CODE = 40,',value,re.M)):
  raise RuntimeError('Unexpected native error: '+value)
 q('odindb-send -s error -m ack_error -- 40;true')
 value=q('odindb-send -s error -p active_error,current_error;true')
 if 'active_error = false' not in value:raise RuntimeError(value)
 return value


assert json.loads((R/'local-verification/camera-testing.lock/owner.json').read_text())['owner']=='codex-preview-debug'
select(False)
report['initial_error']=clear_usb_notice()
report['memory_before']=q('head -5 /proc/meminfo')
q('mkdir -p '+ST)
adb('push',str(Path(__file__).parent/'stable-baseline.sh'),ST+'/af-baseline.sh')
adb('push',str(C/'build/libx2v_prr_resident.so'),ST+'/tof.so')
adb('push',str(Path(__file__).parent/'afc-button-session.sh'),ST+'/afc-button-session.sh')
adb('push',str(Path(__file__).parent/'afc-record-watch.sh'),ST+'/afc-record-watch.sh')
installed=False
try:
 q('mount -o remount,rw /system')
 try:q(f'L={LIB};cp {ST}/tof.so $L && chmod 644 $L && restorecon $L')
 finally:q('mount -o remount,ro /system')
 q('cat /proc/sys/kernel/random/boot_id > '+ST+'/afc-test.boot')
 install_session(ST+'/afc-button-session.sh');installed=True
 select(True);clear_usb_notice()
 report['idle']=state()
 report['live']=q('odindb-send -s camera -m set_live_view -- true;true')
 cmd('start');wait(lambda s:s['phase']=='recording',20)
 report['recording']=state()
 q('echo shot%d > /blackbox/x2v-native-20261011/gui-cmd' % (time.time_ns()%1000000000))
 time.sleep(1)
 adb('pull','/blackbox/x2v-native-20261011/prr-gui-cmd.bmp',str(O/'recording-screen.bmp'))
 print('VERIFYING ON-CAMERA AF AND AUTO STOP',flush=True)
 wait(lambda s:s['phase']=='saved',35)
 report['status']=json.loads(q('cat /tmp/x2v-live/status.json'))
 clip=report['status']['last_clip'];report['clip']=clip
 report['af_watch']=q('cat '+clip+'/afc-control.log')
 report['af_request']=q('cat '+clip+'/afc-find-focus.log;true')
 report['af_gate']=q('grep X2V_AF_GATE /blackbox/x2v-native-20261011/video/service.log | tail -5;true')
 report['error']=q('odindb-send -s error -p active_error;true')
 if 'AFC_TEST_AUTO_STOP' not in report['af_watch']:raise RuntimeError('Automatic stop not verified')
 if 'af_get_half_press_status=1' not in report['af_gate']:raise RuntimeError('AF request not active in captured samples')
 if 'active_error = false' not in report['error']:raise RuntimeError(report['error'])
 report['ready']=True
 report['restored']=False
 report['handoff_state']='Video test intentionally remains enabled for this boot; next boot selects stable library'
 print('READY: record button now triggers native AF without host timer',O,flush=True)
except Exception:
 report['ready']=False
 if installed:
  install_session(ST+'/af-baseline.sh')
  if state()['phase']=='recording':cmd('stop');wait(lambda s:s['phase']=='saved',15)
  select(False)
 raise
finally:
 (O/'result.json').write_text(json.dumps(report,indent=2)+'\n')
