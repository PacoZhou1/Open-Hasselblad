from pathlib import Path
import json,sys,time,subprocess
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parent));from factory_session import connect
B='/blackbox/x2v-native-20261011';ST=B+'/fps-explore'
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],text=True,capture_output=True,check=True,timeout=10).stdout
out=[]
with connect() as r:
 def q(c):assert len(c.encode())<=231;return r.factory_shell(c,capture_ms=2500)
 def snapshot(label):
  q(f'cp /tmp/x2v-product/gui-state.json {ST}/focus-gui.json')
  g=json.loads(adb('shell','cat '+ST+'/focus-gui.json'))
  s={k:g.get(k) for k in ['focusPoint','focusSession','focusCanChange','focusTouch','focusVideoMove','afStatus','stock','gallery','phase']}
  s['label']=label;s['native']=q('odindb-send -s camera -p focus_point,af_status');out.append(s);print(s,flush=True)
  (D/'input-results.json').write_text(json.dumps(out,indent=2))
  return s
 snapshot('before')
 for label,args in [('touch_A','tap 300 300 .12'),('touch_B','tap 700 400 .12'),('touch_A_again','tap 300 300 .12'),('joystick_right','key /dev/input/event0 106 .12'),('joystick_left','key /dev/input/event0 105 .12')]:
  q(f'sh {ST}/button-input.sh {args};true');time.sleep(.8);snapshot(label)
