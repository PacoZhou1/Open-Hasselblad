"""Read the finalized native hardware proxy after owned source recovery."""
from pathlib import Path
import json,subprocess,sys,secrets,time
from factory_session import connect
from gui_session import adb
R=Path(__file__).resolve().parents[1]
P=R/'native-video/outputs'/sys.argv[1]
b=json.loads((P/'report.json').read_text())
assert b['passed'] and b['locks_absent'] and b['recovery_rc']=='0' and b['proxy_file_saved']
out=P/'proxy-readback';out.mkdir(exist_ok=False)
bulk='/mnt/media_rw/ssd/x2v-source-20261012/runs/'+P.name+'/dng/proxy'
run='/data/x2v-source-20261012/runs/'+P.name
tmp=run+'/proxy-read-'+secrets.token_hex(4)
report={'passed':False,'scope':'actual native hardware proxy readback/independent MP4 decode; no timestamp synchronization claim'}
try:
 with connect() as f:
  def q(c):
   assert len(c.encode())<=231
   return f.factory_shell(c,capture_ms=2000).strip()
  identity=q('cd '+bulk+' && test ! -L proxy.mp4 && stat -c "%d:%i:%h:%s" proxy.mp4')
  parts=identity.split(':');assert len(parts)==4 and parts[2]=='1'
  size=int(parts[3]);assert 1024<=size<=64*1024*1024
  assert size==int((P/'device-run/proxy-file.stat').read_text().strip().split(':')[-1])
  q('cd '+bulk+' && (umask 077;set -C;cat proxy.mp4 >'+tmp+')')
  path=out/'proxy.mp4';t=time.monotonic()
  with path.open('xb') as w:
   z=subprocess.run(['adb','-s','123456789ABCDEF','exec-out','cat',tmp],stdout=w,stderr=subprocess.PIPE,timeout=20)
  assert z.returncode==0 and path.stat().st_size==size
  assert q('cd '+bulk+' && stat -c "%d:%i:%h:%s" proxy.mp4')==identity
  adb('shell','test ! -L '+tmp+' && rm '+tmp)
  report.update(path=str(path),bytes=size,source_identity=identity,readback_seconds=time.monotonic()-t)
 probe=subprocess.run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(path)],capture_output=True,text=True,timeout=20)
 assert probe.returncode==0,probe.stderr
 info=json.loads(probe.stdout);vs=[s for s in info['streams'] if s['codec_type']=='video'];assert len(vs)==1 and vs[0]['codec_name']=='h264' and int(vs[0]['nb_read_frames'])>0
 (out/'ffprobe.json').write_text(probe.stdout)
 decode=subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(path),'-f','null','-'],capture_output=True,text=True,timeout=20)
 report.update(decode_exit=decode.returncode,decode_stderr=decode.stderr,video=vs[0]);assert decode.returncode==0
 report['passed']=True
except BaseException as e:report['failure']=repr(e)
finally:
 (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if not report['passed']:raise SystemExit(1)
