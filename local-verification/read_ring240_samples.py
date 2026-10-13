"""Read only three selected frames of completed RX13 run, never the full 5.61GB."""
from pathlib import Path
import sys,json,hashlib,subprocess,secrets,os,time
from factory_session import connect
R=Path(__file__).resolve().parents[1];P=R/'native-video/outputs/source-isolated-133712';D=P/'sample-readback'
sys.path.insert(0,str(R/'native-video/experimental/receipt-oracle-v13-ring240'));import ack_contract
run=P.name;remote='/data/x2v-source-20261012/runs/'+run;bulk='/mnt/media_rw/ssd/x2v-source-20261012/runs/'+run+'/raw.partial'
base=json.loads((P/'report.json').read_text());assert base['passed'] and base['locks_absent']
rx=json.loads((P/'device-run/receiver.receipt').read_text());ack_contract.validate_success(rx)
assert rx['frames_written']==240 and rx['bytes_written']==5611069440
D.mkdir(exist_ok=False);report={'passed':False,'scope':'three selected frames only including frame239 beyond4GiB; original RAW unchanged; no whole-file hash/readback','frames':[]}
def adb(*a,**kw):
 p=subprocess.run(['adb','-s','123456789ABCDEF',*a],capture_output=True,text=True,timeout=kw.get('timeout',8));assert p.returncode==0,(p.stdout,p.stderr);return p.stdout
try:
 with connect() as f:
  def q(cmd):
   assert len(cmd.encode())<=231,(len(cmd.encode()),cmd)
   return f.factory_shell(cmd,capture_ms=6000)
  assert adb('shell','getprop init.svc.camera-service').strip()=='running'
  for lock in ['/data/x2v-source-20261012/source-session.lock','/data/x2v-native-20261012/gui-session.lock','/blackbox/x2v-native-20261011/gui-session.lock']:assert q('test ! -e '+lock+' && test ! -L '+lock+' && echo CLEAR').strip()=='CLEAR'
  source_stat=q('cd '+str(Path(bulk).parent)+' && test -f raw.partial && test ! -L raw.partial && stat -c "%d:%i:%h:%s" raw.partial').strip()
  assert source_stat.split(':')[-2:]==['1','5611069440']
  for ix in [0,120,239]:
   temp='rb13-'+secrets.token_hex(4)+'-'+str(ix);rp=remote+'/'+temp
   fields=q('df -k /data | tail -n 1').split();assert int(fields[-3])*1024>23379456+33554432
   cmd='cd '+remote+' && (umask 077;set -C;toybox dd if='+bulk+' bs=7936 skip='+str(ix*2946)+' count=2946 status=none >'+temp+')'
   q(cmd)
   st=adb('shell','test ! -L '+rp+' && stat -c "%d:%i:%h:%s" '+rp).strip();assert st.split(':')[-2:]==['1','23379456']
   digest=adb('shell','sha256sum '+rp).split()[0]
   path=D/('frame-'+str(ix)+'-stride7936.raw');start=time.monotonic()
   with path.open('xb') as out:
    p=subprocess.run(['adb','-s','123456789ABCDEF','exec-out','cat',rp],stdout=out,stderr=subprocess.PIPE,timeout=15);assert p.returncode==0,p.stderr
   secs=time.monotonic()-start
   assert path.stat().st_size==23379456 and hashlib.sha256(path.read_bytes()).hexdigest()==digest
   adb('shell','test ! -L '+rp+' && test "$(stat -c "%d:%i:%h:%s" '+rp+')" = '+st+' && rm '+rp)
   report['frames'].append({'index':ix,'native_frame_id':rx[f'frame{ix}_id'],'offset':ix*23379456,'path':str(path.relative_to(R)),'bytes':23379456,'sha256':digest,'adb_seconds':secs,'adb_MB_per_second':23379456/secs/1e6})
  assert q('stat -c "%d:%i:%h:%s" '+bulk).strip()==source_stat
  report.update(passed=True,source_stat=source_stat,original_file_unchanged_by_this_reader=True)
except Exception as e:report['failure']=repr(e);raise
finally:
 (D/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
