"""One root-reviewed RX15 fast-C delta trial; separate packet, release revoked finally."""
from pathlib import Path
import hashlib,json,datetime,subprocess,sys
import isolated_resident_two_v15_test as trial
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-resident-two-v15-fast-c'
O=R/'native-video/experimental/source-session-isolated-resident-two-v15';H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sys.argv[1:]==['--execute']
review=json.loads((R/'research/full-fov-pipeline/rx15-fast-c-independent-review/receipt.json').read_text())
assert review['decision']=='GO_offline_controller_delta_root_release_separate' and not review['blocking_findings']
assert sha(P/'controller.sh')==review['controller_sha256'] and sha(P/'bootstrap.sh')==review['bootstrap_sha256']
assert sha(P/'focused-report.json')==review['focused_report_sha256']
assert json.loads((P/'focused-report.json').read_text())['passed']
for report in ['receipt-validator-stage-154231','receipt-native-bench-154528','source-isolated-151741']:
 assert json.loads((R/'native-video/outputs'/report/'report.json').read_text())['passed']
assert sha(R/'local-verification/isolated_resident_two_v15_test.py')=='266ce7d3b7787b77740b9944306f21d87f7ed58d6e6aad78e125ab2ea7c7ff6d'
assert not (P/'freeze.json').exists(),'consumed once; never rerun'
h=json.loads(H.read_text());assert h.get('released_modes')==[]
hold='echo HOLD_fast_c_controller_not_released >&2\nexit 31\n'
c=(P/'controller.sh').read_text();assert c.count(hold)==1
(P/'controller.sh').write_text(c.replace(hold,'',1))
b=(P/'bootstrap.sh').read_text();assert b.count(review['controller_sha256'])==1
(P/'bootstrap.sh').write_text(b.replace(review['controller_sha256'],sha(P/'controller.sh')))
for name in ['controller.sh','bootstrap.sh']:subprocess.run(['/bin/sh','-n',str(P/name)],check=True)
f=json.loads((O/'freeze.json').read_text());mode='isolated-resident-two-v15-fast-c'
f.update(mode=mode,execution_approved=True,hard_hold=False,parent_controller_sha256=sha(O/'controller.sh'),runtime_files={n:sha(P/n) for n in f['runtime_files']},receipt_validator_sha256=review['helper_sha256'],review_status='One root-reviewed fast-C parser delta trial; unchanged source/receiver/native teardown; no full RAW readback')
f.pop('root_final_go_sha256',None)
go={'decision':'GO_ONE_BOUNDED_FAST_C_TWO_CLIP_TRIAL','independent_review':review,'final_runtime_files':f['runtime_files'],'receiver_unchanged':True,'only_release_delta':'remove two-line HOLD and repin bootstrap','source_constructor_ms':47000,'native_watchdog_s':150,'full_raw_readback':False,'no_new_source_mode':True}
(P/'root-final-go.json').write_text(json.dumps(go,indent=2)+'\n')
f['root_final_go_sha256']=sha(P/'root-final-go.json');(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h.update(released_modes=[mode],released_mode_scope='One same-source RX15 A/S then B/T with reviewed C ACK parser only',release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'))
H.write_text(json.dumps(h,indent=2)+'\n')
trial.CANDIDATE=P;trial.MODE=mode
try:rc=trial.main()
finally:
 h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='single fast-C two-clip trial consumed; reconcile before next operation');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
