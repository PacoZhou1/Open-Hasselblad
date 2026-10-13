"""Generate a separate current-boot RAW packet; never dispatches imaging."""
from pathlib import Path
import hashlib,json,re,subprocess,difflib
R=Path(__file__).resolve().parents[1];E=R/'native-video/experimental';B=E/'source-session-isolated-target-ring72-v12-c24';N=E/'source-session-isolated-target-ring72-fast14';P=E/'receipt-linear-v14';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not (N/'freeze.json').exists(),'frozen packet cannot be regenerated'
N.mkdir(exist_ok=True)
c=(B/'controller.sh').read_text();oldgate=(B/'receipt_gate.awk').read_text().rstrip();newgate=(P/'receipt_gate.awk').read_text().rstrip();assert c.count(oldgate)==1;c=c.replace(oldgate,newgate)
oldcache=(E/'receipt-cache-v12/receipt-cache.sh').read_text();newcache=(E/'receipt-cache-v13/receipt-cache.sh').read_text();assert c.count(oldcache)==1;c=c.replace(oldcache,newcache)
old=' sha256sum "$BULK/raw.partial" > "$RUN/receiver.raw.sha256" && printf \'%s\\n\' "$actual_bytes" > "$RUN/receiver.raw.bytes" && : > "$RUN/receiver.confirmed" || return 1'
new=' printf \'%s\\n\' "$actual_bytes" > "$RUN/receiver.raw.bytes" && : > "$RUN/receiver.confirmed" || return 1\n log RECEIVER_BULK_HASH_SKIPPED_SIZE_INODE_FSYNC_ACK_PRESERVED'
assert c.count(old)==1;c=c.replace(old,new)
# Identical receiver/graph/sensor config and bounded capture; only controller identity differs.
c=c.replace('isolated-target-ring72-v12-c24','isolated-target-ring72-fast14').replace('/uid_0/pid_2676','/uid_0/pid_5258')
(N/'controller.sh').write_text(c)
for name in ['bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf']:
 t=(B/name).read_text().replace('/uid_0/pid_2676','/uid_0/pid_5258').replace('isolated-target-ring72-v12-c24','isolated-target-ring72-fast14')
 if name=='bootstrap.sh':t=re.sub(r'^CONTROLLER_SHA=\w+$','CONTROLLER_SHA='+sha(N/'controller.sh'),t,flags=re.M)
 (N/name).write_text(t)
for name in ['controller.sh','bootstrap.sh','guard.sh']:
 subprocess.run([str(R/'native-video/outputs/runtime/mksh-r56-host/mksh'),'-n',str(N/name)],check=True)
 (N/(name+'.diff')).write_text(''.join(difflib.unified_diff((B/name).read_text().splitlines(True),(N/name).read_text().splitlines(True),fromfile='old/'+name,tofile='fast14/'+name)))
h=(R/'local-verification/isolated_target_ring72_v12_c24_test.py').read_text().replace('source-session-isolated-target-ring72-v12-c24','source-session-isolated-target-ring72-fast14').replace("MODE='isolated-target-ring72-v12-c24'","MODE='isolated-target-ring72-fast14'").replace('/uid_0/pid_2676','/uid_0/pid_5258').replace('f6668de2-2070-4793-9cbd-6cfbb7adc2bf','80026cc1-5987-40c7-a271-f68e8165c424')
# Native factory namespace verifies the lock state; ADB process/mount visibility is limited.
old="   assert adb('shell','test ! -e '+lock+' && echo CLEAR').strip()=='CLEAR'"
assert h.count(old)==1;h=h.replace(old,"   with connect() as f: assert q(f,'test ! -e '+lock+' && test ! -L '+lock+' && echo CLEAR').strip()=='CLEAR'")
h=h.replace("  (out/'report.json').write_text", "  report['bulk_hash_verified']=False\n  report['full_host_readback_verified']=False\n  (out/'report.json').write_text")
(R/'local-verification/isolated_target_ring72_fast14_test.py').write_text(h)
f=json.loads((B/'freeze.json').read_text());f.update(mode='isolated-target-ring72-fast14',runtime_files={n:sha(N/n) for n in ['controller.sh','bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf']},controller_sha256=sha(N/'controller.sh'),host_runner_sha256=sha(R/'local-verification/isolated_target_ring72_fast14_test.py'),scope='same RX12 3s/max72; linear schema parsing, reviewed v13 receipt cache, no bulk SHA or full readback; current boot binding',review_status='root candidate awaiting delta review/native parser timing',execution_approved=False,source_parser_sha256=sha(P/'receipt_gate.awk'),bound_boot='80026cc1-5987-40c7-a271-f68e8165c424',bound_group='/uid_0/pid_5258')
(N/'freeze.json').write_text(json.dumps(f,indent=2)+'\n');print(N)
