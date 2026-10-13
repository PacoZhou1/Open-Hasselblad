"""Root-reviewed single bounded RX14 capture. Release is always revoked on return."""
from pathlib import Path
import json,hashlib,subprocess,sys,datetime
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-target-userstop-v14';H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
expected='ea0ca5b84deea91e20c9149a83c724d24233024fc1285e12c73607cd5ac6c2f4'
assert sha(P/'controller.sh')==expected
f=json.loads((P/'draft-contract.json').read_text());test=json.loads((P/'packet-check-report.json').read_text());stage=R/'native-video/outputs/source-c24-userstop-stage-140716/report.json'
assert test['passed'] and test['controller_sha256']==expected and json.loads(stage.read_text())['passed']
assert not (P/'freeze.json').exists(),'one-shot freeze already created; do not rerun'
for n,d in f['runtime_files'].items():assert sha(P/n)==d
assert sha(R/'local-verification/isolated_target_userstop_v14_test.py')==f['host_runner_sha256']
review=R/'research/full-fov-pipeline/rx14-userstop-independent-review/final-pins-go.json'
r=json.loads(review.read_text());assert r['decision']=='GO_FOR_ROOT_SINGLE_BOUNDED_2S_S_TRIAL' and r['controller_sha256']==expected and r['rx_elf_sha256']==f['receiver_sha256']
f.update(execution_approved=True,review_status='root GO exactly one 2s S stop with10s/max240 backstop after native_album_sol independent RX14 source/ELF/packet GO',controller_sha256=expected,stage_report=str(stage.relative_to(R)),packet_check_sha256=sha(P/'packet-check-report.json'),native_parser_seconds=1.12,native_configuration_check_seconds=.09,source_graph_metadata_visitor_enabled=False)
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h=json.loads(H.read_text());assert h.get('released_modes')==[]
h['released_modes']=[f['mode']];h['released_mode_scope']='Exactly one RX14 2s S stop with10s/max240 backstop; native stop/drain/reap/restore preserved; no bulk SHA/full readback';h['release_time']=datetime.datetime.now().astimezone().isoformat();h['released_packet_freeze_sha256']=sha(P/'freeze.json');H.write_text(json.dumps(h,indent=2)+'\n')
try:
 p=subprocess.run([sys.executable,str(R/'local-verification/isolated_target_userstop_v14_test.py'),'--execute']);rc=p.returncode
finally:
 h=json.loads(H.read_text());h['released_modes']=[];h['revocation_reason']='single RX14 trial consumed; reconcile before any further source operation';H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
