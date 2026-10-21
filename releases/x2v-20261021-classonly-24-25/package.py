from pathlib import Path
import json,hashlib,shutil
R=Path(__file__).resolve().parents[2];P=R/'releases/x2v-20261021-classonly-24-25';BASE=R/'releases/x2v-20261017-flat-prr/files/system/etc/x2v';P.mkdir(exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assets=[]
for fps in (24,25):
 src=R/f'native-video/experimental/rx-prr-classonly-{fps}-release-20261021/build/libx2v_prr_resident.so';dest=f'/system/lib64/libx2v_classonly{fps}_20261021a.so';f=P/'files'/dest.lstrip('/');f.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,f);assets.append(dict(source=str(src.relative_to(R)),file=str(f.relative_to(P)),destination=dest,mode='644',sha256=sha(f),bytes=f.stat().st_size))
s=(BASE/'x2v_video_session_20261017flat.sh').read_text()
for fps,old,h in [(24,'libx2v_explore_toflimits_20261015.so','a7f2aef85196424f8e41aa1026f545ca9f4f38def35cdea75db62ea86e18a409'),(25,'libx2v_af_25_20261016.so','c57d60450d5cb9f937ee9e7f8900387422e498128538781aa7f8919ddd7ff1cf')]:
 assert s.count(old)==1 and s.count(h)==1
 a=next(a for a in assets if f'classonly{fps}_' in a['destination']);s=s.replace(old,Path(a['destination']).name).replace(h,a['sha256'])
b=(BASE/'x2v_product_boot_20261017a.sh').read_text();assert b.count('x2v_video_session_20261017flat.sh')==1;b=b.replace('x2v_video_session_20261017flat.sh','x2v_video_session_20261021a.sh')
for name,text in [('x2v_video_session_20261021a.sh',s),('x2v_product_boot_20261021a.sh',b)]:
 dest='/system/etc/x2v/'+name;f=P/'files'/dest.lstrip('/');f.parent.mkdir(parents=True,exist_ok=True);f.write_text(text);assets.append(dict(source='derived from installed x2v-20261017-flat-prr',file=str(f.relative_to(P)),destination=dest,mode='755',sha256=sha(f),bytes=f.stat().st_size))
(P/'manifest.json').write_text(json.dumps(dict(release=P.name,base='x2v-20261017-flat-prr / 6648b237',installed=False,device_verified=False,assets=assets,scope='ProRes RAW 24/25fps defect-class-only reconstruction; 30fps and DNG unchanged',recovery_boot='/system/etc/x2v/x2v_product_boot_20261017a.sh'),indent=2)+'\n')
print(P)
