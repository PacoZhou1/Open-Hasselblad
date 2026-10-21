"""Development keep-awake lease. Stop restores the captured 300-second timeout.
The camera watchdog restores settings within 120 seconds if the host worker dies.
"""
import argparse,json,os,signal,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent
STATE=ROOT/'keepawake-state.json'
REMOTE='/blackbox/x2v-native-20261011'
SCRIPT=REMOTE+'/keepawake.sh';LEASE=REMOTE+'/keepawake.lease'
def adb(*args):return subprocess.run(['adb','-s','123456789ABCDEF',*args],capture_output=True,text=True,timeout=8,check=True).stdout

def ensure():
 """Re-arm at an operator-owned capture boundary, never from a competing worker."""
 state=json.loads(STATE.read_text())
 if not state.get('active'):raise RuntimeError('Keepawake is not enabled')
 owner=json.loads((ROOT/'camera-testing.lock/owner.json').read_text())
 if owner.get('owner')!='codex-preview-debug':raise RuntimeError('Camera belongs to another operator')
 from factory_session import connect
 adb('shell',f'echo {int(time.time())+120} > {LEASE}')
 with connect() as r:
  thermal=r.factory_shell('odindb-send -s system -p temperature_status').strip()
  if thermal not in ('temperature_status = E_TemperatureStatus_Low(1)', 'temperature_status = E_TemperatureStatus_Moderate(2)'):
   raise RuntimeError('Keepawake refused: '+thermal)
  boot=r.factory_shell('cat /proc/sys/kernel/random/boot_id').strip()
  pid=int(state.get('camera_pid') or 0)
  alive=r.factory_shell(f"tr '\\000' ' ' < /proc/{pid}/cmdline;true").strip() if pid else ''
  if SCRIPT not in alive:
   result=r.factory_shell(f'toybox nohup sh {SCRIPT} >{REMOTE}/keepawake.log 2>&1 & echo $!').strip()
   if not result.isdigit():raise RuntimeError('Camera watchdog did not launch: '+result)
   state['camera_pid']=int(result)
   # Development factory commands inherit camera-test's disposable cgroup.
   adb('shell',f'p=$(pidof adbd); echo {int(result)} > /acct/uid_0/pid_$p/cgroup.procs')
  wake=r.factory_shell('odindb-send -s system -m acquire_wake_lock -- x2v-debug-session').strip()
  r.factory_shell('odindb-send -s system -p screen_idle_timeout -- 0')
  actual=r.factory_shell('odindb-send -s system -p screen_idle_timeout').strip()
  if actual.split('=')[-1].strip()!='0':raise RuntimeError(actual)
 state.update(boot_id=boot,verified_at=time.time(),screen_idle_timeout=0,wake_reply=wake)
 # A cached active flag survives a Mac restart; it does not prove that the
 # process renewing the 120-second camera lease is still alive.
 host_pid=state.get('host_pid')
 host_command=subprocess.run(['ps','-p',str(host_pid or 0),'-o','command='],capture_output=True,text=True).stdout
 if str(Path(__file__).resolve()) not in host_command or ' worker' not in host_command:
  state['host_pid']=None
  temp=STATE.with_suffix('.tmp');temp.write_text(json.dumps(state,indent=2));temp.replace(STATE)
  with (ROOT/'keepawake-host.log').open('a') as log:
   host=subprocess.Popen([sys.executable,str(Path(__file__).resolve()),'worker'],stdin=subprocess.DEVNULL,stdout=log,stderr=log,start_new_session=True)
  state['host_pid']=host.pid
 temp=STATE.with_suffix('.tmp');temp.write_text(json.dumps(state,indent=2));temp.replace(STATE)
 print(json.dumps(state));return state

def start():
 if STATE.exists() and json.loads(STATE.read_text()).get('active'):raise RuntimeError('Already active; use status/stop')
 from factory_session import connect
 # Baseline is read before every fresh start.
 with connect() as r:
  thermal=r.factory_shell('odindb-send -s system -p temperature_status').strip()
  if thermal not in ('temperature_status = E_TemperatureStatus_Low(1)', 'temperature_status = E_TemperatureStatus_Moderate(2)'):
   raise RuntimeError('Keepawake refused: '+thermal)
  value=r.factory_shell('odindb-send -s system -p screen_idle_timeout')
  old=int(value.split('=')[1].strip())
  script=f'''#!/system/bin/sh
cleanup() {{
 timeout 4 odindb-send -s system -p screen_idle_timeout -- {old}
 timeout 4 odindb-send -s system -m release_wake_lock -- x2v-debug-session
}}
trap cleanup EXIT
trap 'exit 0' INT TERM HUP
while [ -f {LEASE} ]; do
 read expiry < {LEASE}
 now=$(date +%s)
 case "$expiry" in ''|*[!0-9]*) exit 1;; esac
 [ "$now" -lt "$expiry" ] || exit 0
 temp=$(timeout 2 odindb-send -s system -p temperature_status)
 case "$temp" in *E_TemperatureStatus_Low*|*E_TemperatureStatus_Moderate*) ;; *) exit 0;; esac
 state=$(timeout 2 odindb-send -s system -p system_state)
 case "$state" in *PrepareShutdown*|*Shutdown*) exit 0;; esac
 sleep 2
done
'''
  local=ROOT/'keepawake-device.sh';local.write_text(script)
  # system_data_file is readable by both the factory and ADB domains.
  adb('push',str(local),SCRIPT)
  adb('shell',f'echo {int(time.time())+120} > {LEASE}')
  pid=r.factory_shell(f'toybox nohup sh {SCRIPT} >{REMOTE}/keepawake.log 2>&1 & echo $!').strip()
  if not pid.isdigit():raise RuntimeError('Camera watchdog did not launch')
  adb('shell',f'p=$(pidof adbd); echo {int(pid)} > /acct/uid_0/pid_$p/cgroup.procs')
  r.factory_shell('odindb-send -s system -m acquire_wake_lock -- x2v-debug-session')
  r.factory_shell('odindb-send -s system -p screen_idle_timeout -- 0')
  r.factory_shell('odindb-send -s system -m set_screen_enabled -- true')
 STATE.write_text(json.dumps(dict(active=True,baseline_timeout=old,camera_pid=int(pid),host_pid=None),indent=2))
 with (ROOT/'keepawake-host.log').open('a') as log:
  p=subprocess.Popen([sys.executable,str(Path(__file__).resolve()),'worker'],stdin=subprocess.DEVNULL,stdout=log,stderr=log,start_new_session=True)
 state=json.loads(STATE.read_text());state['host_pid']=p.pid;STATE.write_text(json.dumps(state,indent=2));print(state)

def worker():
 # Explicitly requested continuous development keep-awake; no boot installation.
 while True:
  try:
   state=json.loads(STATE.read_text())
   if not state.get('active'):return
   owner=state.get('host_pid')
   if owner is not None and owner!=os.getpid():return
   adb('shell',f'echo {int(time.time())+120} > {LEASE}')
  except Exception as e:print(str(e),flush=True)
  time.sleep(30)

def stop():
 state=json.loads(STATE.read_text());state['active']=False;STATE.write_text(json.dumps(state,indent=2))
 adb('shell',f'rm -f {LEASE}')
 # Actual restoration is performed by the camera's factory-domain watchdog.
 print('Lease stopped; camera restores timeout within a few seconds.',state)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('action',choices=['start','stop','status','worker','ensure']);a=p.parse_args().action
 if a=='status':print(STATE.read_text() if STATE.exists() else 'inactive')
 else:globals()[a]()
