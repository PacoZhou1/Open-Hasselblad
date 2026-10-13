from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path(__file__).resolve().parents[1]
old=R/'native-video/experimental/source-session-isolated-two-v18-isp'
new=R/'native-video/experimental/source-session-isolated-two-v21-dark'
mode='isolated-two-v21-dark'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
f=json.loads((old/'freeze.json').read_text());assert not new.exists();new.mkdir()
for name in f['runtime_files']:shutil.copy2(old/name,new/name)
for name in ['controller.sh','bootstrap.sh','guard.sh']:
 p=new/name;t=p.read_text().replace('isolated-two-v18-isp',mode).replace('/uid_0/pid_5258','/uid_0/pid_3102')
 if name=='bootstrap.sh':t=t.replace(f['runtime_files']['controller.sh'],sha(new/'controller.sh'))
 p.write_text(t);subprocess.run(['/bin/sh','-n',str(p)],check=True)
f.update(mode=mode,execution_approved=False,hard_hold=True,bound_group='/uid_0/pid_3102',boot_id='41867eda-01a6-4809-b1d0-ebedba61dce4',runtime_files={n:sha(new/n) for n in f['runtime_files']},condition={'lens_cap':'user_confirmed','exposure_controlled':False,'metadata':'original_RX18_receipt_only'},root_scope='Proven RX18 unchanged RAW+ISP binary; collect dark first without experimental metadata binding.')
(new/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
p=R/'local-verification/isolated_resident_two_v16_dng_test.py';t=p.read_text().replace('source-session-isolated-resident-two-v16-dng',new.name).replace("MODE='isolated-resident-two-v16-dng'",f"MODE='{mode}'").replace('80026cc1-5987-40c7-a271-f68e8165c424',f['boot_id']).replace('/uid_0/pid_5258','/uid_0/pid_3102');(R/'local-verification/isolated_two_v21_dark_test.py').write_text(t)
p=R/'local-verification/run_metadata_v20b_once.py';t=p.read_text().replace('isolated_two_v20b_metadata_test','isolated_two_v21_dark_test').replace('source-session-isolated-two-v20b-metadata',new.name).replace('isolated-two-v20b-metadata',mode).replace('source-metadata-v20b-stage-*','source-isp-v18-stage-*').replace('V20b','V21')
a=t.index('              root_review=');b=t.index('              condition=',a)
t=t[:a]+"              root_review='Previously successful RX18 unchanged binary, exact graph/stop/recovery; current boot and group updated. User confirmed cap; no metadata getter or encoder change.',\n"+t[b:]
t=t.replace('One two-clip RAW+ISP metadata presence trial; lens cap, no encoder','One two-clip proven RX18 dark capture; lens cap, no encoder').replace('native metadata presence and first dark-scene baseline','dark-scene pixels first; no exposure control claim')
(R/'local-verification/run_dark_v21_once.py').write_text(t)
print(new)
