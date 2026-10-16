"""Actual RX16 + prepacked backend lifecycle checks; simulated native HAL/DIRECT."""
from pathlib import Path
import subprocess,time,json,hashlib,sys
p=Path(__file__).resolve().parent;base=p/'host-test';b=p.parents[1]/'resident-cinemadng-prepacked-writer';g=p.parents[1]/'resident-raw-clip-state'
base.mkdir(exist_ok=True)
sources=[p/'check_dng_resident.c',b/'dng_prepacked.c',b/'frame_writer.c',g/'clip_gate.c']
cmd=['clang','-std=c11','-O1','-g','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-DX2V_SHAPE=2','-DX2V_HOST_TEST','-DO_DIRECT=0x10000','-I',str(b),'-I',str(g),*map(str,sources),'-lpthread','-o',str(base/'check_dng_resident')]
subprocess.run(cmd,check=True,capture_output=True,text=True)
inputs=sources+[p/'receiver.c',p/'receiver.h',p/'control.c',p/'profile_provisional.h',p/'vendor_hook.c',b/'dng_prepacked.h']
pins={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in inputs}
cases=['normal','three-slot-stop','inflight-original','stale-ticket','second-write-error','abort-between','expiry-between-clips','fd-valid','fd-alias-output','fd-regular-output','fd-command-writable'];rs=[]
for c in cases:
 out=base/(str(time.time_ns())+'-'+c);out.mkdir()
 r=subprocess.run([str(base/'check_dng_resident'),c,str(out)],capture_output=True,text=True,timeout=40)
 (out/'stdout.txt').write_text(r.stdout);(out/'stderr.txt').write_text(r.stderr)
 rs.append({'case':c,'exit_code':r.returncode,'output':str(out),'stderr':r.stderr[-2000:]});print(c,r.returncode,r.stderr[-350:].strip(),flush=True)
 if r.returncode:break
stable=pins=={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in inputs}
report={'scope':'actual RX16 receiver/control/hook plus actual prepacked backend, native HAL/provider/DIRECT simulated on host; not camera proof','cases':rs,'passed':len(rs)==len(cases) and all(r['exit_code']==0 for r in rs) and stable,'source_stable':stable,'source_sha256':pins,'build_command':cmd}
(base/'report.json').write_text(json.dumps(report,indent=2)+'\n')
raise SystemExit(0 if report['passed'] else 1)
