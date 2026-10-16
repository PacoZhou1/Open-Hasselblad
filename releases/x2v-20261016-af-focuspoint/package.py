from pathlib import Path
import json,shutil,hashlib
D=Path(__file__).resolve().parent;R=D.parents[1]
base=D.parent/'x2v-20261016-af-fps';fix=R/'local-verification/video-focus-point-fix-20261016/gui'
m=json.loads((base/'manifest.json').read_text());m.update(release=D.name,checkpoint='c67f3c8db1367a7fdd5e316c7342ec742ccf29c4')
for a in m['assets']:
 src=base/a['file'];candidate=fix/src.name
 if a['destination'].startswith('/blackbox/') and candidate.exists():
  src=candidate;a['source']=str(src.relative_to(R))
 out=D/a['file'];out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,out);a['sha256']=hashlib.sha256(out.read_bytes()).hexdigest()
name='X2VLiveviewViewModel.qml';dest='/blackbox/x2v-native-20261011/gui/'+name
out=D/'files'/dest.lstrip('/');shutil.copy2(fix/name,out)
m['assets'].append(dict(file=str(out.relative_to(D)),destination=dest,mode='644',sha256=hashlib.sha256(out.read_bytes()).hexdigest(),source=str((fix/name).relative_to(R))))
(D/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
print('Packaged',len(m['assets']),'assets')
