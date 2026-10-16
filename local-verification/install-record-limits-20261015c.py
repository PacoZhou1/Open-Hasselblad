"""Install user-approved incremental duration/thermal UI on the verified current baseline."""
import hashlib,json,subprocess,sys,time
from pathlib import Path
from factory_session import connect
ROOT=Path(__file__).resolve().parents[1]
PKG=ROOT/'native-video/experimental/x2v-product-boot/dist/x2v-record-limits-20261015c'
OUT=ROOT/'native-video/experimental/x2v-product-boot/evidence/record-limits-20261015'
B='/blackbox/x2v-native-20261011';ST=B+'/install-limits-20261015c'
NEW='/system/etc/x2v/x2v_product_boot_20261015c.sh'
OLD='/system/etc/x2v/x2v_product_boot_20261014zm.sh'
NAMES=['main.qml','RecordingProfiles.qml','ExperimentalVideoSettings.qml']
def adb(*a):
 r=subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,timeout=15)
 if r.returncode:raise RuntimeError(r.stderr)
 return r.stdout

def q(cmd):
 assert len(cmd.encode())<=231,cmd
 with connect() as f:return f.factory_shell(cmd,capture_ms=1500)

def state():
 for _ in range(4):
  try:return json.loads(q('cat /tmp/x2v-product/state.json | sed \'s/"detail":"[^"]*"/"detail":""/\''))
  except ValueError:time.sleep(.05)
 raise RuntimeError('No complete state')

def wait(pred,seconds=30):
 end=time.monotonic()+seconds
 while time.monotonic()<end:
  s=state()
  if pred(s):return s
  time.sleep(.25)
 raise RuntimeError(s)

def command(c):q('echo "%d %s" > /tmp/x2v-product/gui.cmd'%(time.time_ns()%1000000000,c))
def launch(path):
 pid=q(f'S={ST};toybox nohup sh {path} >$S/launch.out 2>&1 & echo $!').strip()
 assert pid.isdigit(),pid
 # Development launch only. On reboot weston starts it in its own persistent cgroup.
 adb('shell',f'p=$(pidof adbd); echo {int(pid)} > /acct/uid_0/pid_$p/cgroup.procs')
 return int(pid)

def stop_supervisor(pid):
 q(f'kill -TERM {pid}')
 end=time.monotonic()+3
 while time.monotonic()<end:
  if q(f'[ -d /proc/{pid} ] && echo live || echo gone').strip()=='gone':return
  time.sleep(.1)
 raise RuntimeError('Old supervisor has not stopped')

s=state();assert s['phase'] in ('idle','saved'),s
assert json.loads((ROOT/'local-verification/camera-testing.lock/owner.json').read_text())['owner']=='codex-preview-debug'
m=json.loads((PKG/'manifest.json').read_text())
for name,digest in m['files'].items():assert hashlib.sha256((PKG/name).read_bytes()).hexdigest()==digest,name
assert 'TEST ONLY' not in (PKG/Path(NEW).name).read_text()
assert 'cmd === "durationnever"' not in (PKG/'gui/main.qml').read_text()
q(f'mkdir -p {ST}/gui {ST}/rollback')
for name in NAMES:
 q(f'cp {B}/gui/{name} {ST}/rollback/{name}')
 adb('push',str(PKG/'gui'/name),ST+'/gui/'+name)
adb('push',str(PKG/Path(NEW).name),ST+'/supervisor.sh')
result={'version':m['version'],'old_state':s,'boot_id':q('cat /proc/sys/kernel/random/boot_id').strip(),'reboot_tested':False,'installed':False}
installed=False;stopped=False;pid=None
try:
 print('Returning to photo before replacing supervisor...',flush=True)
 command('video_off');wait(lambda x:x['session']=='down',35)
 stop_supervisor(s['supervisor_pid']);stopped=True
 play=q('pidof x2v_prr_play_20261014zg;true').strip()
 if play and all(p.isdigit() for p in play.split()):q('kill -TERM '+play)
 q('kill -TERM $(pidof camera-gui);true')
 q('mount -o remount,rw /system')
 try:
  q(f'N={NEW}.tmp; cp {ST}/supervisor.sh $N && chmod 755 $N && restorecon $N')
  q(f'mv {NEW}.tmp {NEW}')
  installed=True
 finally:q('mount -o remount,ro /system')
 for name in NAMES:q(f'cp {ST}/gui/{name} {B}/gui/{name}')
 # Keep the existing selected duration (300 from the completed trial); do not overwrite preferences.
 pid=launch(NEW)
 print('New persistent supervisor started',pid,flush=True)
 wait(lambda x:x['supervisor_pid']==pid and x.get('duration_limit_seconds')==300,20)
 er=q('odindb-send -s error -p current_error;true')
 if 'CODE = 40' in er and 'ACTION = 1' in er:q('odindb-send -s error -m ack_error -- 40')
 command('video_on')
 result['state']=wait(lambda x:x['session']=='up' and x['phase']=='idle' and x.get('temperature_status') in ('low','moderate'),35)
 result['selected_boot']=q('ls /system/etc/x2v/x2v_product_boot_*.sh | sort | tail -1').strip()
 assert result['selected_boot']==NEW
 result['running_command']=q(f'tr "\\000" " " < /proc/{pid}/cmdline').strip();assert NEW in result['running_command']
 result['mount']=q("grep ' /system ' /proc/mounts").strip();assert ' ro,' in result['mount']
 result['receiver_mapping']=q('p=$(pidof camera-service);grep libx2v_preview_aligned /proc/$p/maps | head -1').strip();assert result['receiver_mapping']
 q(f'G={B}/gui;sha256sum {NEW} $G/main.qml $G/RecordingProfiles.qml > {ST}/installed.sha')
 q(f'sha256sum {B}/gui/ExperimentalVideoSettings.qml >> {ST}/installed.sha')
 actual=q(f'cat {ST}/installed.sha').splitlines()
 expected=[m['files'][Path(NEW).name],m['files']['gui/main.qml'],m['files']['gui/RecordingProfiles.qml'],m['files']['gui/ExperimentalVideoSettings.qml']]
 assert [x.split()[0] for x in actual]==expected
 result['installed_files_verified']=True;result['installed']=True
 print(json.dumps(result,ensure_ascii=False,indent=2),flush=True)
except Exception:
 if installed:
  q('mount -o remount,rw /system')
  try:q(f'rm -f {NEW}')
  finally:q('mount -o remount,ro /system')
 for name in NAMES:q(f'cp {ST}/rollback/{name} {B}/gui/{name}')
 if pid:
  try:command('video_off');wait(lambda x:x['session']=='down',35);stop_supervisor(pid)
  except Exception as e:result['rollback_issue']=str(e)
 if stopped and 'rollback_issue' not in result:
  q('kill -TERM $(pidof camera-gui);true');launch(OLD)
 raise
finally:
 (OUT/'permanent-install.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
