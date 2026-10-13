"""Offline source candidate only. Does not release, stage or execute on camera."""
from pathlib import Path
import shutil,json,hashlib
R=Path(__file__).resolve().parents[1]
A=R/'native-video/experimental/source-receiver-adapter'
base=A/'receiver_v16_dng_prepacked';dst=A/'receiver_v18_dng_isp_proxy'
geom=R/'native-video/experimental/raw-isp-geometry-candidate'
assert not dst.exists(), 'preserve existing candidate'
dst.mkdir()
for p in base.iterdir():
 if p.is_file() and (p.suffix in ('.c','.h','.py','.sp','.conf') or p.name=='source-review.json'):
  shutil.copy2(p,dst/p.name)
for n in ['geometry.c','native_sub_pin.h']:shutil.copy2(geom/n,dst/n)
p=dst/'target_topology.c';s=p.read_text();s=s.replace('static uint32_t r32(', 'extern int x2v_isp_full_transfer_geometry(void *,size_t);\nstatic uint32_t r32(',1)
needle='  /* +5b8/+5bc deliberately untouched until independent consumer audit. */'
assert s.count(needle)==1
s=s.replace(needle,'  /* Owned SUB geometry only; coefficients and native dual graph remain unverified. */\n  int isp_rc=x2v_isp_full_transfer_geometry(row,0x640);\n  if(isp_rc)return isp_rc;')
p.write_text(s)
p=dst/'shape.h';s=p.read_text();assert s.count('GROUP13_MODE21C24_DNG_RESIDENT2_V16')==1
p.write_text(s.replace('GROUP13_MODE21C24_DNG_RESIDENT2_V16','GROUP13_MODE21C24_DNG_ISP_PROXY_V18'))
p=dst/'build.py';s=p.read_text().replace("'android_abi_check.c']","'android_abi_check.c','geometry.c']",1)
s=s.replace('libx2v_mode21c24_dng_resident2_v16_arm','libx2v_mode21c24_dng_isp_proxy_v18_arm').replace('GROUP13_MODE21C24_DNG_RESIDENT2_V16','GROUP13_MODE21C24_DNG_ISP_PROXY_V18')
p.write_text(s)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=dst/'source-review.json';d=json.loads(p.read_text());d['scope']='RX18 offline intermediate: owned ISP geometry integrated; RAW-only config still retained. No native proxy or device release.'
for key in ['production_sources','headers']:
 for n in d[key]:d[key][n]=sha(dst/n)
d['production_sources']['geometry.c']=sha(dst/'geometry.c');d['headers']['native_sub_pin.h']=sha(dst/'native_sub_pin.h')
p.write_text(json.dumps(d,indent=2)+'\n')
(dst/'README.md').write_text('''# RX18 ISP + RAW integration candidate\n\nOffline intermediate only; not staged or released. Based on the proven RX16 DNG writer. Adds the owned SUB geometry function only, with a unique launch token/artifact. Terminal receipt version remains 16 because its schema is unchanged.\n\nRAW-only SP/conf intentionally retained until the native hardware proxy branch is reviewed. This is not yet a simultaneous-recording implementation. Remaining integration: original ISP tuning/coefficient compatibility; native VENC and transport wiring; bounded simultaneous start/stop and restoration; source/output frame timing; CPU/load/temperature evidence. No direct register or firmware boot changes.\n''')
print(dst)
