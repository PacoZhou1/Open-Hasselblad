from pathlib import Path
import json,sys,subprocess,time
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parent));from factory_session import connect
G='/blackbox/x2v-native-20261011/gui';ST='/blackbox/x2v-native-20261011/fps-explore'
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,check=True,timeout=15).stdout
lock=D.parent/'camera-testing.lock/owner.json';l=json.loads(lock.read_text());assert l['owner']=='codex-preview-debug';l.update(state='TESTING',task='Focus-point touch and joystick fix');lock.write_text(json.dumps(l,indent=2)+'\n')
backup=D/'previous';backup.mkdir(exist_ok=True)
files=list((D/'gui').glob('*.qml'))
for p in files:
 if not (backup/p.name).exists():
  old=subprocess.run(['adb','-s','123456789ABCDEF','pull',G+'/'+p.name,str(backup/p.name)],capture_output=True,text=True)
  if old.returncode and p.name!='X2VLiveviewViewModel.qml':raise RuntimeError(old.stderr)
 adb('push',str(p),G+'/'+p.name+'.candidate')
with connect() as r:
 def q(c):assert len(c.encode())<=231;return r.factory_shell(c,capture_ms=2500)
 before=json.loads(q('cat /tmp/x2v-product/state.json'));assert before['phase']=='idle',before
 q('touch /tmp/x2v-live/video-afc.stop;timeout 3 odindb-send -s camera -m stop_session;true')
 for p in files:q(f'mv {G}/{p.name}.candidate {G}/{p.name}')
 q('kill -TERM $(pidof camera-gui)')
 start=time.time();s=None
 for _ in range(20):
  time.sleep(.5)
  q(f'cp /tmp/x2v-product/gui-state.json {ST}/focus-gui.json')
  try:s=json.loads(adb('shell','cat '+ST+'/focus-gui.json'))
  except ValueError:continue
  if 'focusVideoMove' in s:break
 else:
  for p in backup.glob('*.qml'):adb('push',str(p),G+'/'+p.name+'.restore');q(f'mv {G}/{p.name}.restore {G}/{p.name}')
  q('kill -TERM $(pidof camera-gui)');raise RuntimeError('GUI load not confirmed; original restored')
 print({k:s.get(k) for k in ['stock','focusPoint','focusSession','focusCanChange','focusVideoMove','afStatus']},flush=True)
 (D/'installed.json').write_text(json.dumps({'gui_loaded':True,'time':time.time(),'files':[p.name for p in files],'before':before,'after':s},indent=2))
 print('Candidate GUI installed; AF paused pending video entry',flush=True)
