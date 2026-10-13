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

def start():
 if STATE.exists() and json.loads(STATE.read_text()).get('active'):raise RuntimeError('Already active; use status/stop')
 from factory_session import connect
 # Baseline is read before every fresh start.
 with connect() as r:
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
 sleep 10
done
'''
  local=ROOT/'keepawake-device.sh';local.write_text(script)
  # system_data_file is readable by both the factory and ADB domains.
  adb('push',str(local),SCRIPT)
  adb('shell',f'echo {int(time.time())+120} > {LEASE}')
  pid=r.factory_shell(f'toybox nohup sh {SCRIPT} >{REMOTE}/keepawake.log 2>&1 & echo $!').strip()
  if not pid.isdigit():raise RuntimeError('Camera watchdog did not launch')
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
 print('Lease stopped; camera restores timeout within 10 seconds.',state)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('action',choices=['start','stop','status','worker']);a=p.parse_args().action
 if a=='status':print(STATE.read_text() if STATE.exists() else 'inactive')
 else:globals()[a]()
