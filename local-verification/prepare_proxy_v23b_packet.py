"""Prepare a fresh held proxy retry only after revised ELF exists; never reuse consumed A."""
from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path(__file__).resolve().parents[1];OLD=R/'native-video/experimental/source-session-isolated-two-v23-hw-proxy';P=R/'native-video/experimental/source-session-isolated-two-v23b-hw-proxy';RX=R/'native-video/experimental/source-receiver-adapter/receiver_v23b_named_hw_proxy';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not P.exists();receipt=json.loads((RX/'build/target-token/receipt.json').read_text());old=json.loads((OLD/'freeze.json').read_text());assert receipt['sha256']!=old['receiver_sha256'];P.mkdir();mode='isolated-two-v23b-hw-proxy';dest='/system/lib64/libx2v_mode21c24_named_proxy_20261012b.so'
for n in old['runtime_files']:shutil.copy2(OLD/n,P/n)
p=P/'controller.sh';p.write_text(p.read_text().replace(old['mode'],mode).replace(old['receiver_path'],dest).replace(old['receiver_sha256'],receipt['sha256']))
for n in ['bootstrap.sh','guard.sh']:
 p=P/n;t=p.read_text().replace(old['mode'],mode)
 if n=='bootstrap.sh':t=t.replace(old['runtime_files']['controller.sh'],sha(P/'controller.sh'))
 p.write_text(t);subprocess.run(['/bin/sh','-n',str(p)],check=True)
f={**old,'mode':mode,'execution_approved':False,'hard_hold':True,'receiver_path':dest,'receiver_sha256':receipt['sha256'],'runtime_files':{n:sha(P/n) for n in old['runtime_files']},'integration_receipt':str(RX/'build/target-token/receipt.json'),'parent_freeze_sha256':sha(OLD/'freeze.json'),'root_review':'RX23b binding correction; native RAW/stop/restore unchanged. Six root proxycontrol cases and new actual C forwarding tests; no public role5.'};(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
for oldname,newname in [('isolated_two_v23_proxy_test.py','isolated_two_v23b_proxy_test.py'),('run_proxy_v23_once.py','run_proxy_v23b_once.py'),('source_proxy_v23_stage.py','source_proxy_v23b_stage.py')]:
 t=(R/'local-verification'/oldname).read_text().replace('v23','v23b').replace(old['receiver_path'],dest).replace(old['receiver_sha256'],receipt['sha256'])
 (R/'local-verification'/newname).write_text(t);compile(t,newname,'exec')
print(json.dumps({'packet':str(P),'receiver_sha256':receipt['sha256'],'held':True}))
