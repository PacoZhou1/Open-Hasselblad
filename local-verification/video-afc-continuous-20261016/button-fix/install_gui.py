from pathlib import Path
import subprocess,json,time,sys
D=Path(__file__).resolve().parent;sys.path.insert(0,str(D.parents[1]))
from factory_session import connect
BB='/blackbox/x2v-native-20261011';G=BB+'/gui';ST=BB+'/fps-explore'
def adb(*args):return subprocess.run(['adb','-s','123456789ABCDEF',*args],capture_output=True,text=True,check=True,timeout=15).stdout
lock=D.parents[1]/'camera-testing.lock/owner.json';l=json.loads(lock.read_text());assert l['owner']=='codex-preview-debug';l.update(state='TESTING',task='AF session navigation gate fix');lock.write_text(json.dumps(l,indent=2))
(D/'previous-watch.sh').write_text(adb('shell','cat /system/etc/x2v/video-afc-watch.sh'))
for p in (D/'gui').glob('*.qml'):adb('push',str(p),G+'/'+p.name+'.candidate')
adb('push',str(D/'video-afc-watch.sh'),ST+'/video-afc-watch-buttonfix.sh')
with connect() as r:
 def q(c):assert len(c.encode())<=231;return r.factory_shell(c,capture_ms=5000)
 q('touch /tmp/x2v-live/video-afc.stop;timeout 3 odindb-send -s camera -m stop_session;true')
 for p in (D/'gui').glob('*.qml'):q(f'mv {G}/{p.name}.candidate {G}/{p.name}')
 q('mount -o remount,rw /system')
 try:q(f'L=/system/etc/x2v/video-afc-watch.sh;cp {ST}/video-afc-watch-buttonfix.sh $L;chmod 755 $L;restorecon $L')
 finally:q('mount -o remount,ro /system')
 q('kill -TERM $(pidof camera-gui)')
 time.sleep(1)
 q(f'cp /tmp/x2v-product/gui-state.json {ST}/buttonfix-gui.json;true')
 print(adb('shell','cat '+ST+'/buttonfix-gui.json')[:1500])
print('GUI candidate installed; AF remains paused until load check')
