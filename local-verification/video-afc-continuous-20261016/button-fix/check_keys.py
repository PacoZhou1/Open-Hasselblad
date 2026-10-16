from pathlib import Path
import subprocess,time,json,sys
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parents[1]));from factory_session import connect
BB='/blackbox/x2v-native-20261011';ST=BB+'/fps-explore'
def adb(*a):return subprocess.run(['adb','-s','123456789ABCDEF',*a],text=True,capture_output=True,check=True,timeout=10).stdout
with connect() as r:
 def q(c):assert len(c.encode())<=231;return r.factory_shell(c,capture_ms=5000)
 def snapshot():
  for i in range(4):
   q(f'cp /tmp/x2v-product/gui-state.json {ST}/keys-state.json')
   try:return json.loads(adb('shell','cat '+ST+'/keys-state.json'))
   except ValueError:time.sleep(.1)
 def key(dev,code):q(f'sh {ST}/button-input.sh key /dev/input/event{dev} {code} .12;true')
 out=[]
 for label,dev,code in [('halfpress',0,30),('menu',3,59),('menu2',3,59),('play',3,63),('return',0,30)]:
  key(dev,code);time.sleep(.65);s=snapshot();v={k:s.get(k) for k in ['t','stock','mode','gallery','isoWb']};v['action']=label;v['af']=q('odindb-send -s camera -p af_status,exposure_status,live_view_state;true');out.append(v);print(v,flush=True)
 (D/'key-injection.json').write_text(json.dumps(out,indent=2))
 q(f'echo shot{int(time.time())} > {BB}/gui-cmd')
