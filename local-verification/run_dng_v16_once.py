"""One reviewed 24fps-source RX16 two-clip DNG trial, revoked on return."""
from pathlib import Path
import hashlib,json,datetime,subprocess,sys
import isolated_resident_two_v16_dng_test as trial
R=Path(__file__).resolve().parents[1]
P=R/'native-video/experimental/source-session-isolated-resident-two-v16-dng'
H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sys.argv[1:]==['--execute']
assert not (P/'freeze.json').exists(),'consumed packet; reconcile before a fresh run'
report=json.loads((P/'delta-host-report.json').read_text())
assert report['passed'] and report['count']==69
for n,h in report['source_sha256'].items():assert sha(P/n)==h,n
assert sha(P/'controller.sh')=='01fb9fce14176a42eebabd6ac54f2eb50427a283e0c9be19f4485d701b1cc239'
review=R/'research/full-fov-pipeline/rx16-prepacked-independent-review/receipt.json'
assert sha(review)=='4d1e6f91bd68155ecd895ee79bacfdcca2ab5c6cde4b1a86551c6894dbc5eda8'
oracle=R/'native-video/experimental/receipt-oracle-v16-dng'
o=json.loads((oracle/'focused-report.json').read_text())
assert o['passed'] and sha(oracle/'ack_contract.py')==o['source_sha256']
for n in ['source-dng-v16-stage-175001','receipt-v16-stage-174719','dng-prepacked-replay-174121']:
 assert json.loads((R/'native-video/outputs'/n/'report.json').read_text())['passed']
h=json.loads(H.read_text());assert h.get('released_modes')==[]
draft=json.loads((P/'draft-contract.json').read_text())
for n,digest in draft['runtime_files'].items():assert sha(P/n)==digest
hold='if [ "$#" -gt 0 ]; then echo HOLD_RX16_DNG_candidate_not_released >&2; exit 30; fi\n'
c=(P/'controller.sh').read_text();assert c.count(hold)==1
(P/'controller.sh').write_text(c.replace(hold,'',1))
b=(P/'bootstrap.sh').read_text();old=draft['runtime_files']['controller.sh'];assert b.count(old)==1
(P/'bootstrap.sh').write_text(b.replace(old,sha(P/'controller.sh')))
for n in ['controller.sh','bootstrap.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f=dict(draft);f.update(execution_approved=True,hard_hold=False,runtime_files={n:sha(P/n) for n in draft['runtime_files']},
 host_runner_sha256=sha(R/'local-verification/isolated_resident_two_v16_dng_test.py'),
 oracle_sha256=sha(oracle/'ack_contract.py'),root_receiver_review_sha256=sha(review),
 root_review='Root read complete controller delta and actual directory/manifest fixtures; original native recovery unchanged. Single2s x2 trial; no calibration/UI/persistence claim.')
f['integrations_pending']=['Actual capture/stop/restore/24fps and selected DNG readback still to verify']
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h.update(released_modes=[trial.MODE],released_mode_scope='Single2s x2 same24fps source with prepacked DNG receiver; full native recovery retained',release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'))
H.write_text(json.dumps(h,indent=2)+'\n')
try:rc=trial.main()
finally:
 h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='One RX16 DNG trial consumed; inspect receipts and recovery before next operation');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
