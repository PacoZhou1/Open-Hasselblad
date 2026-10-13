"""Root-reviewed single bounded RX13 capture. Release is always revoked on return."""
from pathlib import Path
import json,hashlib,subprocess,sys,datetime
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-target-ring240-v13-c24';H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
expected='ffb077d49fe2634d198dc79f84b7d3bfd0c185e6a1de48907d30fc76cc5966c5'
assert sha(P/'controller.sh')==expected
f=json.loads((P/'draft-contract.json').read_text());test=json.loads((P/'packet-check-report.json').read_text());stage=R/'native-video/outputs/source-c24-ring240-stage-132542/report.json'
assert test['passed'] and test['controller_sha256']==expected and json.loads(stage.read_text())['passed']
assert not (P/'freeze.json').exists(),'one-shot freeze already created; do not rerun'
for n,d in f['runtime_files'].items():assert sha(P/n)==d
assert sha(R/'local-verification/isolated_target_ring240_v13_test.py')==f['host_runner_sha256']
f.update(execution_approved=True,review_status='root GO exactly one bounded10s/max240 after native_album_sol independent delta and schema acceleration GO',controller_sha256=expected,stage_report=str(stage.relative_to(R)),packet_check_sha256=sha(P/'packet-check-report.json'),native_parser_seconds=1.12,native_configuration_check_seconds=.09,source_graph_metadata_visitor_enabled=False)
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h=json.loads(H.read_text());assert h.get('released_modes')==[]
h['released_modes']=[f['mode']];h['released_mode_scope']='Exactly one RX13 bounded10s/max240; native stop/drain/reap/restore preserved; no bulk SHA/full readback';h['release_time']=datetime.datetime.now().astimezone().isoformat();h['released_packet_freeze_sha256']=sha(P/'freeze.json');H.write_text(json.dumps(h,indent=2)+'\n')
try:
 p=subprocess.run([sys.executable,str(R/'local-verification/isolated_target_ring240_v13_test.py'),'--execute']);rc=p.returncode
finally:
 h=json.loads(H.read_text());h['released_modes']=[];h['revocation_reason']='single RX13 trial consumed; reconcile before any further source operation';H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
