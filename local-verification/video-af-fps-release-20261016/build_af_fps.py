from pathlib import Path
import sys,shutil,re,struct,json,subprocess,hashlib
D=Path(__file__).resolve().parent;R=D.parents[1];E=R/'native-video/experimental';src=E/'rx-prr-explore-toflimits-20261016'
fps=int(sys.argv[1]);assert fps in [25,30]
name={25:'c25',30:'d30'}[fps];driver={25:17,30:18}[fps];xhs={25:450,30:400}[fps];xvs={25:3200,30:3000}[fps]
dst=E/f'rx-prr-af-{name}-20261016';dst.mkdir(exist_ok=True)
for p in src.iterdir():
 if p.is_file() and (p.suffix in ['.c','.h'] or p.name=='build.py'):shutil.copy2(p,dst/p.name)
shutil.copytree(src/'adapter',dst/'adapter',dirs_exist_ok=True)
p=dst/'adapter/target_rows.h';s=p.read_text();matches=list(re.finditer(r'\{([^{}]+)\}',s));rows=[bytearray(int(x,16) for x in re.findall(r'0x[0-9a-f]+',m[1])) for m in matches];assert len(rows)==8 and all(len(x)==132 for x in rows)
n=f'X2V_MODE21_{name.upper()}_AF'.encode();rows[0][:64]=n+b'\0'*(64-len(n))
for off,val in [(64,driver),(68,36000000),(72,xhs),(84,xvs)]:struct.pack_into('<I',rows[0],off,val)
struct.pack_into('<I',rows[4],76,fps*100)
for i in [4,0]:m=matches[i];s=s[:m.start()]+'{'+','.join(f'0x{x:02x}' for x in rows[i])+'}'+s[m.end():]
p.write_text(s)
p=dst/'adapter/fps_guard_session.c';s=p.read_text().replace('ratio[2]={24,1}',f'ratio[2]={{{fps},1}}').replace('driver=17',f'driver={driver}').replace('applied=24/1',f'applied={fps}/1');p.write_text(s)
for p in list((dst/'adapter').glob('*.c'))+list(dst.glob('*.c')):
 s=p.read_text().replace('mode21-c24',f'mode21-{name}').replace('mode21-c-24fps',f'mode21-{name[0]}-{fps}fps').replace('GROUP13_MODE21C24_PRR_RESIDENT_V1',f'GROUP13_MODE21{name.upper()}_PRR_AF_V1')
 if p.name=='resident.c':s=s.replace('24000, 1000',f'{fps*1000}, 1000').replace(' / 24.0',f' / {fps}.0').replace('\\"fps\\":24',f'\\"fps\\":{fps}').replace('S.slot[k].index, 24)',f'S.slot[k].index, {fps})')
 if p.name=='vrec.c':s=s.replace('(1e6 / 24)',f'(1e6 / {fps})').replace('24000, 1000',f'{fps*1000}, 1000').replace('\\"frame_rate_num\\":24',f'\\"frame_rate_num\\":{fps}').replace('\\"idr_interval\\":24',f'\\"idr_interval\\":{fps}')
 if p.name=='session_gate.c':s=s.replace('24.0f',f'{fps}.0f')
 p.write_text(s)
p=dst/'build.py';s=p.read_text().replace("'GROUP13_MODE21C24_PRR_RESIDENT_V1'",repr(f'GROUP13_MODE21{name.upper()}_PRR_AF_V1'));s=s.replace("if src.parent == BASE and src.name in freeze['production_sources']:","if src.parent == BASE and src.name in freeze['production_sources'] and src.name not in ['fps_guard_session.c','source_mode21_guard_preload.c','hal_topology_glue.c','graph_binding.c','target_parser_gate.c']:");p.write_text(s)
base=R/'native-video/experimental/rx-prr-resident/imx861bqr_hb722_view.conf';s=base.read_text();at=s.index('[normal_liveview_raw_calib:basic]');s=s[:at]+s[at:].replace('DCAM_FPS_2400',f'DCAM_FPS_{fps*100}');(dst/'view.conf').write_text(s)
subprocess.run([sys.executable,str(dst/'build.py')],check=True,stdout=(D/f'build-{fps}.log').open('w'),stderr=subprocess.STDOUT)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
result={'fps':fps,'driver':driver,'timing':[36000000,xhs,xvs],'lib':str(dst/'build/libx2v_prr_resident.so'),'lib_sha':sha(dst/'build/libx2v_prr_resident.so'),'conf':str(dst/'view.conf'),'conf_sha':sha(dst/'view.conf'),'base':str(src),'af_frame_rate':fps}
(D/f'candidate-{fps}.json').write_text(json.dumps(result,indent=2));print(json.dumps(result))
