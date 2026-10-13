"""Derive held RX15 controller with exact C receipt gate; never operates device."""
from pathlib import Path
import hashlib,json,shutil,difflib,subprocess,shlex
R=Path(__file__).resolve().parents[1];E=R/'native-video/experimental'
OLD=E/'source-session-isolated-resident-two-v15';NEW=E/'source-session-isolated-resident-two-v15-fast-c'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(OLD/'controller.sh')=='453398fe5ca3d82665b29b5523d38e93cf1d7711e1c05ef70a2b20c053bbcbcf'
assert json.loads((R/'native-video/outputs/receipt-native-bench-154528/report.json').read_text())['passed']
NEW.mkdir(exist_ok=False)
for name in ['guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf','config_gate.awk']:
 shutil.copy2(OLD/name,NEW/name)
original=(OLD/'controller.sh').read_text()
start=original.index('receipt_validate_uncached() {\n');end=original.index('\n# Source after original receipt_valid',start)
old_gate=original[start:end]
gate='''receipt_validate_uncached() {
 receiver_inodes || return 1
 case "${1:-0}" in 0|1) ;; *) return 1;; esac
 timeout 4 "$RECEIPT_VALIDATOR" --expected-generation "$CLIP_GEN" --require-frame "${1:-0}" < "$CLIP_RECEIPT" > /dev/null
}
'''
decl='RECEIPT_VALIDATOR=/system/bin/x2v_rx15_receipt_validate_20261012a\nRECEIPT_VALIDATOR_SHA=f7a0e7b22b18e103595a0ec7c92da12e8ae73f915921d6da41377c9c38f9fc68\n'
hold='echo HOLD_fast_c_controller_not_released >&2\nexit 31\n'
changed=original[:start]+gate+original[end:]
changed=changed.replace('RECEIVER_SHA=af702d5f9044acd11fff34c2c0e4f2fab64cb5eca0b32bda3b0dbf9002484625\n','RECEIVER_SHA=af702d5f9044acd11fff34c2c0e4f2fab64cb5eca0b32bda3b0dbf9002484625\n'+decl)
pin='verify_hash "$SP" "$SP_SHA" && verify_hash "$CONF" "$CONF_SHA"'
assert changed.count(pin)==2
changed=changed.replace(pin,'verify_hash "$RECEIPT_VALIDATOR" "$RECEIPT_VALIDATOR_SHA" && '+pin)
changed=changed.replace('# RX15 two generations',hold+'# RX15 two generations',1)
(NEW/'controller.sh').write_text(changed)
bootstrap=(OLD/'bootstrap.sh').read_text().replace(sha(OLD/'controller.sh'),sha(NEW/'controller.sh'))
(NEW/'bootstrap.sh').write_text(bootstrap)
# Reverse exactly the allowed changes: this proves every other runtime line unchanged.
reverse=changed.replace(hold,'',1).replace(decl,'',1).replace('verify_hash "$RECEIPT_VALIDATOR" "$RECEIPT_VALIDATOR_SHA" && ','').replace(gate,old_gate,1)
assert reverse==original
for name in ['controller.sh','bootstrap.sh','guard.sh']:
 subprocess.run(['/bin/sh','-n',str(NEW/name)],check=True,capture_output=True)
(NEW/'controller.diff').write_text(''.join(difflib.unified_diff(original.splitlines(True),changed.splitlines(True),fromfile='frozen-rx15',tofile='fast-c-held')))
# Exercise extracted actual shell wrapper with actual compiled C host parser.
# timeout is a direct host function here: device timeout5 already exercised in native bench.
host=E/'native-rx15-receipt-validator/validator_host_bench'
ack=R/'native-video/outputs/source-isolated-150137/device-run/receiver.receipt'
cases=[]
for name,gen,req,inode,available,expected in [
 ('capture',1,1,0,True,0),('closure',1,0,0,True,0),('wrong-generation',2,1,0,True,1),
 ('wrong-mode',1,2,0,True,1),('inode-failed',1,1,1,True,1),('missing-helper',1,1,0,False,127)]:
 helper=str(host) if available else str(NEW/'nonexistent-helper')
 script='receiver_inodes() { return '+str(inode)+'; }; timeout() { shift; "$@"; };\n'+gate+'\n'
 script+='RECEIPT_VALIDATOR='+shlex.quote(helper)+'\nCLIP_GEN='+str(gen)+'\nCLIP_RECEIPT='+shlex.quote(str(ack))+'\nreceipt_validate_uncached '+str(req)+'\n'
 p=subprocess.run(['/bin/sh','-c',script],capture_output=True,text=True,timeout=5)
 assert p.returncode==expected,(name,p.returncode,p.stderr)
 cases.append({'case':name,'expected_rc':expected,'actual_rc':p.returncode})
report={'passed':True,'actual_shell_with_C_cases':cases,'all_other_controller_bytes_unchanged':True,'separate_configuration_gate_preserved':True,'receiver_unchanged':True,'native_retirement_and_recovery_unchanged':True,'source_budget_not_relaxed':True,'runtime_files':{n:sha(NEW/n) for n in ['controller.sh','bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf']},'execution_approved':False,'hard_hold':True,'device_integrated':False,'read_only_native_bench':'native-video/outputs/receipt-native-bench-154528/report.json'}
(NEW/'focused-report.json').write_text(json.dumps(report,indent=2)+'\n')
(NEW/'README.md').write_text('Held offline candidate. Only canonical receipt parser replaced with reviewed native C helper; provider pinned before mutation, outer timeout4 preserved. Native receiver/source/config/cache/inode/hash/pair/stop/recovery unchanged. Successful helper exit is CPU closure/capture only, not a native DMA fence. No device integration/execution yet. See controller.diff and focused-report.json.\n')
print(json.dumps({'directory':str(NEW),'passed':True,'cases':len(cases),'hold':True}))
