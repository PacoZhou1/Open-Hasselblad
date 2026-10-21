from pathlib import Path
import shutil,json,hashlib
D=Path(__file__).resolve().parent;R=D.parents[1];W=R/'local-verification/prr-flat-storage-20261017'
items=[('session.sh','/system/etc/x2v/x2v_video_session_20261017flat.sh'),('supervisor.sh','/system/etc/x2v/x2v_product_boot_20261017a.sh'),('flat-storage.sh','/system/etc/x2v/x2v_flat_storage_20261017a.sh'),('build/x2v_sync_paths_20261017a','/system/bin/x2v_sync_paths_20261017a')]
assets=[]
for src,dest in items:
 f=D/'files'/dest.lstrip('/');f.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/src,f);assets.append(dict(source=str((W/src).relative_to(R)),file=str(f.relative_to(D)),destination=dest,mode='755',sha256=hashlib.sha256(f.read_bytes()).hexdigest()))
(D/'manifest.json').write_text(json.dumps(dict(release=D.name,base='6648b237',installed=False,device_verified=False,assets=assets),indent=2)+'\n')
