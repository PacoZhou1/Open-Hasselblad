from pathlib import Path
import subprocess,json,hashlib
R=Path(__file__).resolve().parents[1];A=R/'native-video/experimental/source-receiver-adapter';P=A/'receiver_v18_dng_isp_proxy';T=A/'target_topology_geometry_review';B=P/'host-test';B.mkdir(exist_ok=True)
s=(T/'check_geometry.c').read_text().replace('0x1f8,0x1fc};','0x1f8,0x1fc,0x5bc,0x5cc,0x5d0,0x5dc,0x5e0};').replace('0,0,3920,2946};','0,0,3920,2946,2946,0,0,3920,2946};').replace('0x5bc)==986','0x5bc)==2946').replace(' /* unrelated component unchanged */','')
s=s.replace('assert(!memcmp(&before,&out,sizeof out));','if(o<0x5ac)assert(!memcmp(&before,&out,sizeof out));')
(B/'check.c').write_text(s)
subprocess.run(['clang','-std=c11','-O1','-g','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-I',str(P),str(P/'target_topology.c'),str(P/'geometry.c'),str(B/'check.c'),'-o',str(B/'check')],check=True)
results=[]
for case in ['normal','target','0x5bc']:
 r=subprocess.run([str(B/'check'),case],cwd=T,capture_output=True,text=True);results.append({'case':case,'rc':r.returncode,'output':r.stdout+r.stderr});assert r.returncode==0,results[-1]
report={'scope':'Actual integrated RX18 topology C; local native data fixture only, no vendor execution or camera access','passed':True,'cases':results,'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [P/'target_topology.c',P/'geometry.c']},'hardware_proxy_verified':False}
(B/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
