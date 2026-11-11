"""Publish B for the authorized cold verification when native debug was OOM-killed.

Only filesystem staging uses ADB. No native D-Bus, process signal, or guessed
PID is issued from the ADB domain. Do not label physical verification passed.
"""
from pathlib import Path
import datetime,json,subprocess

D=Path(__file__).resolve().parent;R=D.parents[1]
P=R/'native-video/experimental/x2v-touch-tracking-20261111-terminal-loss-trial'
M=json.loads((P/'manifest.json').read_text())
rel=R/'releases/x2v-20261111-tracking-b';receipt=rel/'receipt.json';payload=json.loads(receipt.read_text())
T=R/'native-video/experimental/x2v-touch-tracking-20261110/lost-terminal'
assert json.loads((T/'test-receipt.json').read_text())['passed']==9
assert json.loads((T/'file-request-test-receipt.json').read_text())['passed']
assert M['AF_binary_unchanged_from']=='20261111ab' and payload['AF_user_accepted']
lock=D.parent/'camera-testing.lock/owner.json';owner=json.loads(lock.read_text());assert owner['owner']=='codex-preview-debug'
S=['adb','-s','123456789ABCDEF']
def adb(*args):return subprocess.run(S+list(args),capture_output=True,timeout=10,check=True).stdout
for name in ['main.qml','FileRequests.js','TouchTrackingController.js','VideoTouchTracking.qml','X2VLiveViewImage.qml']:
    assert adb('exec-out','cat',M['UI_device_path']+'/'+name)==(P/'gui'/name).read_bytes(),name
boot=payload['boot'];before=adb('shell','ls /system/etc/x2v/x2v_product_boot_*.sh | tail -n 1').decode().strip();assert before<=boot,before
checks=[]
for key,folder in [('session_name','/system/etc/x2v/'),('watcher_name','/system/etc/x2v/'),('loader_name','/system/lib64/')]:
    checks.append('cmp -s '+M['remote']+'/'+M[key]+' '+folder+M[key])
checks.append('cmp -s '+M['remote']+'/native-copy.so '+M['copy_library']['device_path'])
checks.append('cmp -s '+M['remote']+'/native-observer.so '+M['observer']['device_path'])
script='''#!/system/bin/sh
set -eu
'''+ '\n'.join(checks)+'''
mount -o remount,rw /system
trap 'mount -o remount,ro /system' EXIT
s='''+M['remote']+'''/product_boot_touch_trial.sh
p='''+boot+'''
if [ -e "$p" ];then cmp -s "$s" "$p";else cp "$s" "$p";fi
chmod 755 "$p"
restorecon "$p"
cmp -s "$s" "$p"
echo BOOT_PUBLISHED_FOR_COLD_VERIFICATION
'''
local=D/'tracking-b-publish-cold.sh';local.write_text(script)
remote=M['remote']+'/publish-cold.sh';adb('push',str(local),remote)
out={'version':M['version'],'before_newest':before,'cold_verification_pending':True,'original_boot_retained':True}
try:
    out['write']=adb('shell','sh '+remote).decode()
    assert 'BOOT_PUBLISHED_FOR_COLD_VERIFICATION' in out['write']
    out['newest']=adb('shell','ls /system/etc/x2v/x2v_product_boot_*.sh | tail -n 1').decode().strip();assert out['newest']==boot
    out['system']=adb('shell','cat /proc/mounts | grep " /system "').decode();assert ' ro,' in out['system']
    out['published']=True
    payload.update(installed=True,installed_at=datetime.datetime.now().isoformat(),cold_verification_pending=True,
                   memory_request_pool={'host_verified_requests':4000,'allocated_objects':1,'hardware_growth_test':'pending'},
                   installation_receipt=str(D/'tracking-b-cold-publication.json'))
    receipt.write_text(json.dumps(payload,ensure_ascii=False,indent=2))
finally:
    (D/'tracking-b-cold-publication.json').write_text(json.dumps(out,ensure_ascii=False,indent=2))
    owner.update(state='TESTING',task='B persistent boot staged for user normal restart; native lost-return and memory growth verification pending')
    lock.write_text(json.dumps(owner,indent=2))
print(json.dumps(out,ensure_ascii=False,indent=2))
