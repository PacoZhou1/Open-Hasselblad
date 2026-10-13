from pathlib import Path
import hashlib,json,shutil,subprocess
R=Path(__file__).resolve().parents[1];OLD=R/'native-video/experimental/source-session-isolated-two-v23b-hw-proxy';P=OLD.with_name('source-session-isolated-two-v23g-rtp');RX=R/'native-video/experimental/source-receiver-adapter/receiver_v23g_native_rtp';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
receipt=json.loads((RX/'build/target-token/receipt.json').read_text());old=json.loads((OLD/'freeze.json').read_text());P.mkdir(exist_ok=True)
for n in old['runtime_files']:shutil.copy2(OLD/n,P/n)
mode='isolated-two-v23g-rtp';dest='/system/lib64/libx2v_mode21c24_native_rtp_20261013g.so';t=(P/'controller.sh').read_text().replace(old['mode'],mode).replace(old['receiver_path'],dest).replace(old['receiver_sha256'],receipt['sha256']).replace('GROUP13_MODE21C24_DNG_ISP_PROXY_V18','GROUP13_MODE21C24_DNG_NATIVE_RTP_V23G')
t=t.replace('SELF=$0','RECORDER=/system/bin/x2v_recorder_20261011b\nRECORDER_SHA=5d3090ef464ec4b5f1b23d241e6d0e0d4355c465a83f303388dc411e10bc2bd3\nSELF=$0')
fragment=(RX/'proxy-controller-fragment.sh').read_text();resource=(R/'native-video/experimental/raw-proxy-resource-snapshot/resource_snapshot.sh').read_text();t=t.replace('receiver_arm() {',resource+'\n'+fragment+'\nreceiver_arm() {')
t=t.replace('[ "$entry" = "$1/segment.partial.jsonl" ] || exit 1','if [ "$entry" = "$1/proxy" ] && [ "$1" = "$BULK/dng" ];then [ -d "$entry" ] && [ ! -L "$entry" ] || exit 1;continue;fi\n  [ "$entry" = "$1/segment.partial.jsonl" ] || exit 1')
t=t.replace('preview-probe_00000000000000000000000000000001','proxy')
t=t.replace('while ! receipt_valid 0; do\n  gate', 'while ! receipt_valid 0; do\n  proxy_poll || return 1\n  gate')
t=t.replace('while ! receipt_valid 0; do\n   gate', 'while ! receipt_valid 0; do\n   proxy_poll || return 1\n   gate')
t=t.replace('result=$?; trap - EXIT HUP INT TERM', 'result=$?; trap - EXIT HUP INT TERM\n proxy_cleanup_recorder || true')
t=t.replace('receiver_user_stop_trial() {\n sleep 2', 'receiver_user_stop_trial() {\n if [ "$CLIP_GEN" = 1 ];then proxy_wait_started || return 1;sleep 4;x2v_resource_snapshot proxy-stop "$proxy_rp" || true;else sleep 2;fi')
t=t.replace('export XDG_RUNTIME_DIR=/tmp ', 'read gv gr pn gb gd extra < "$RUN/guard.binding" || exit 4\n [ "$gv" = v1 ] && [ "$gr" = "$ID" ] && [ -z "$extra" ] || exit 4\n export X2V_PROXY_SESSION="$ID" X2V_PROXY_NONCE="$pn"\n export XDG_RUNTIME_DIR=/tmp ')
# Start only after all native graph/space/memory/prepared checks; the recorder
# has a separate 5s first-packet deadline regardless of its 30s total ceiling.
anchor=': > \"$RUN/receiver.arm-intent\" || return 1\n gate && match_service && [ ! -f \"$RUN/receiver.cancel-intent\" ] && receiver_inodes || return 1\n printf A'
replacement='gate && match_service && [ ! -f \"$RUN/receiver.cancel-intent\" ] && receiver_inodes || return 1\n proxy_start_recorder || { fail proxy_recorder_prepare_failed; return 1; }\n : > \"$RUN/receiver.arm-intent\" || return 1\n gate && [ ! -f \"$RUN/receiver.cancel-intent\" ] && receiver_inodes || return 1\n printf A'
assert t.count(anchor)==1
t=t.replace(anchor,replacement)
t=t.replace('receiver_user_stop_trial && receiver_frame && target_setup_evidence || exit 5','receiver_user_stop_trial && receiver_frame && target_setup_evidence && proxy_capture_verified || exit 5')
# One capture; close the unused second context through existing D + all-clip drain.
t=t.replace('receiver_frame && receiver_arm_second && receiver_user_stop_trial && receiver_frame && target_setup_evidence && proxy_capture_verified', 'receiver_frame && receiver_drain && target_setup_evidence && proxy_capture_verified')
(P/'controller.sh').write_text(t)
for n in ['bootstrap.sh','guard.sh']:
 f=P/n;s=f.read_text().replace(old['mode'],mode)
 if n=='bootstrap.sh':s=s.replace(old['runtime_files']['controller.sh'],sha(P/'controller.sh'))
 f.write_text(s)
for n in ['controller.sh','bootstrap.sh','guard.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f={**old,'mode':mode,'execution_approved':False,'hard_hold':True,'receiver_path':dest,'receiver_sha256':receipt['sha256'],'token':receipt['token'],'runtime_files':{n:sha(P/n)for n in old['runtime_files']},'integration_receipt':str(RX/'build/target-token/receipt.json'),'parent_freeze_sha256':sha(OLD/'freeze.json'),'proxy_recorder_path':'/system/bin/x2v_recorder_20261011b','proxy_recorder_sha256':'5d3090ef464ec4b5f1b23d241e6d0e0d4355c465a83f303388dc411e10bc2bd3','proxy_capture_seconds':4,'second_raw_seconds':0,'second_context':'unarmed CPU closure required; no second capture','native_budget_ms':47000,'proxy_clock_verified':False,'recorder_launch_point':'receiver_arm after prepared/query/memory/space gates; READY immediately precedes A','root_review':'New D held RTP integration; pending subscribe captures context but committed owner required; reason diagnostics; native stop unchanged.'};(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
for oldname,newname in [('isolated_two_v23b_proxy_test.py','isolated_two_v23g_rtp_test.py'),('run_proxy_v23b_once.py','run_proxy_v23g_once.py'),('source_proxy_v23b_stage.py','source_proxy_v23g_stage.py')]:
 s=(R/'local-verification'/oldname).read_text().replace('v23b-hw-proxy','v23g-rtp').replace('v23b_proxy_test','v23g_rtp_test').replace('v23b','v23g').replace(old['receiver_path'],dest).replace(old['receiver_sha256'],receipt['sha256'])
 s=s.replace("any(re.search(r'saved=[1-9][0-9]* ',line) for line in report['proxy_diagnostics'])", "(d/'proxy-recorder.rc').is_file() and (d/'proxy-recorder.rc').read_text().strip()=='0' and (d/'proxy-state.json').is_file()")
 s=s.replace('X2V_PROXY lifecycle native_retirable=1 callback_pool_finished=1 unmap_error=0','X2V_PROXY lifecycle native_retirable=1 route_disabled=1 recorder_finalized=1 proxy_error=0')
 if oldname=='isolated_two_v23b_proxy_test.py':s=s.replace("report['raw_lifecycle_pass']=report['passed']", "report['raw_lifecycle_pass']=report['passed']\n  report['proxy_file_saved']=report['proxy_payload_saved'] and report['proxy_native_start_returned_zero'] and report['proxy_closure_confirmed']\n  report['passed']=bool(report['passed'] and report['proxy_file_saved'])")
 if oldname=='source_proxy_v23b_stage.py':
  s=s.replace('receiver_v23g_named_hw_proxy','receiver_v23g_native_rtp').replace('libx2v_mode21c24_named_hw_proxy_v23g_arm.TOKEN_REQUIRED.so','libx2v_mode21c24_native_rtp_v23g_arm.TOKEN_REQUIRED.so')
 if oldname=='isolated_two_v23b_proxy_test.py':
  s=s.replace("['receiver.confirmed','receiver2.confirmed']","['receiver.confirmed']")
  s=s.replace(",'RECEIVER_CAPTURE_VERIFIED_V16_DNG_ACK_GEN2'", "")
  s=s.replace(",'RECEIVER_DNG_DIRECTORY_VERIFIED_GEN2'", "")
  s=s.replace(",'RECEIVER_EXPLICIT_USER_STOP_GEN2'", "")
  s=s.replace(",'RECEIVER_CONFIG_FLAGS17_CONFIRMED_GEN2'", "")
  s=s.replace('pair=ack_contract.validate_pair(*receipts)', 'ack_contract.validate_success(receipts[0],1);ack_contract.validate_closure(receipts[1],2);assert receipts[1]["capture_armed"]==0 and receipts[1]["frames_copied"]==0')
  s=s.replace('[measure(rx) for rx in receipts]', '[measure(rx) for rx in receipts[:1]]')
  s=s.replace('for rx in receipts]', 'for rx in receipts[:1]]')
  s=s.replace("(receipts[1]['arm_ns']-receipts[0]['admission_closed_ns'])/1e9", 'None')
  s=s.replace('two DNG captures, directory integrity and native lifecycle checked separately','one DNG capture plus unarmed second CPU closure; native lifecycle checked separately')
  s=s.replace('two_clip_oracle_verified','single_clip_and_unused_closure_oracle_verified')
  s=s.replace('two_clip_oracle_error','single_clip_and_unused_closure_oracle_error')
  s=s.replace("if 'X2V_PROXY ' in line", "if any(tag in line for tag in ['X2V_PROXY ','X2V_PATH ','X2V_RTP '])")
 (R/'local-verification'/newname).write_text(s);compile(s,newname,'exec')
print(P)
