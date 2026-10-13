"""Exactly one root-reviewed two-clip trial; revoke execution release on return."""
from pathlib import Path
import datetime,hashlib,json,subprocess,sys
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-resident-two-v15';H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
review=json.loads((P/'root-final-go.json').read_text())
assert review['decision']=='GO_ONE_BOUNDED_TWO_CLIP_TRIAL'
f=json.loads((P/'draft-contract.json').read_text());test=json.loads((P/'packet-check-report.json').read_text())
assert sha(P/'controller.sh')==review['controller_sha256']==f['runtime_files']['controller.sh']
assert sha(P/'packet-check-report.json')==review['packet_check_sha256'] and test['passed']
assert sha(R/'local-verification/isolated_resident_two_v15_test.py')==review['host_runner_sha256']
assert f['receiver_sha256']==review['receiver_sha256']
stage=R/review['stage_report'];assert json.loads(stage.read_text())['passed']
assert sha(stage)==review['stage_report_sha256']
for n,d in f['runtime_files'].items():assert sha(P/n)==d,n
assert not (P/'freeze.json').exists(),'one-shot packet already consumed; never relaunch'
f.update(execution_approved=True,review_status='one bounded two-clip native test after root final review',root_final_go_sha256=sha(P/'root-final-go.json'))
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h=json.loads(H.read_text());assert h.get('released_modes')==[]
h.update(released_modes=[f['mode']],released_mode_scope='Exactly one RX15 A/S then B/T;47s absolute receiver and150s native watchdog; unchanged native teardown/recovery',release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'))
H.write_text(json.dumps(h,indent=2)+'\n')
try:
    rc=subprocess.run([sys.executable,str(R/'local-verification/isolated_resident_two_v15_test.py'),'--execute']).returncode
finally:
    h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='single RX15 two-clip trial consumed; reconcile before another operation');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
