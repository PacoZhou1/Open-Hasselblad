"""Assemble release B locally, without touching the camera or publishing boot."""
from pathlib import Path
import datetime,hashlib,json,shutil

D=Path(__file__).resolve().parent;R=D.parents[1]
P=R/'native-video/experimental/x2v-touch-tracking-20261111-terminal-loss-trial'
M=json.loads((P/'manifest.json').read_text())
assert M['version']=='20261111b' and M['AF_binary_unchanged_from']=='20261111ab'
test=R/'native-video/experimental/x2v-touch-tracking-20261110/lost-terminal/test-receipt.json'
assert json.loads(test.read_text())['passed']==9
O=R/'releases/x2v-20261111-tracking-b';F=O/'files';F.mkdir(parents=True,exist_ok=True)
for n in ['x2v-20261110-video-tools-g','x2v-20261111-lifecycle-a']:
    shutil.copytree(R/'releases'/n/'files',F,dirs_exist_ok=True)
def copy(src,dest):
    target=F/dest.lstrip('/');target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,target)
boot='/system/etc/x2v/x2v_product_boot_20261111b.sh'
copy(P/'product_boot_touch_trial.sh',boot)
for key,folder in [('session_name','/system/etc/x2v/'),('watcher_name','/system/etc/x2v/'),('loader_name','/system/lib64/')]:copy(P/M[key],folder+M[key])
for key in ['copy_library','observer']:copy(Path(M[key]['source']),M[key]['device_path'])
shutil.copytree(P/'gui',F/M['UI_device_path'].lstrip('/'),dirs_exist_ok=True)
for name in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:copy(P/name,M['remote']+'/'+name)
assets=[{'dest':'/'+str(p.relative_to(F)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in sorted(F.rglob('*')) if p.is_file()]
old={}
receipt=O/'receipt.json'
if receipt.exists():old=json.loads(receipt.read_text())
out={'version':M['version'],'firmware':'1.3.16.2','boot':boot,'gui_directory':M['UI_device_path'],
     'built_at':datetime.datetime.now().isoformat(),'installed':old.get('installed',False),
     'AF_user_accepted':True,'lock_speed_user_accepted':True,'native_BFM_cache_input_Hz':24,
     'AF_native_binary_unchanged':M['copy_library'],
     'loss_behavior':'Native loss ends current touch lease; stop AF, clear touch-origin bits, release owner; a new tap is required',
     'loss_host_tests':str(test),'loss_physical_test':old.get('loss_physical_test','pending'),
     'photo_IQ_readout_pixel_math_unchanged':True,'retained_fallback_boot':'/system/etc/x2v/x2v_product_boot_20261111a.sh',
     'physical_cold_boot_verified':old.get('physical_cold_boot_verified',False),'files':assets}
for key in ['installed_at','installation_receipt','cold_verification_pending','memory_request_pool']:
    if key in old:out[key]=old[key]
receipt.write_text(json.dumps(out,ensure_ascii=False,indent=2))
print(json.dumps({'release':str(O),'files':len(assets),'bytes':sum(a['bytes'] for a in assets),'installed':out['installed']},indent=2))
