"""New scene observation using byte-identical, proven RX14 short-stop packet."""
from pathlib import Path
import datetime,hashlib,json,shutil,sys
import isolated_target_userstop_v14_test as trial
R=Path(__file__).resolve().parents[1];B=R/'native-video/experimental/source-session-isolated-target-userstop-v14';P=R/'native-video/experimental/source-session-wall-reference-retry1-20261012';H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not P.exists(),'single scene observation already created; do not rerun'
f=json.loads((B/'freeze.json').read_text());assert f['runtime_files']['controller.sh']=='ea0ca5b84deea91e20c9149a83c724d24233024fc1285e12c73607cd5ac6c2f4'
assert json.loads((R/'native-video/outputs/source-isolated-140802/report.json').read_text())['passed']
assert json.loads((R/'native-video/outputs/source-isolated-150137/report.json').read_text())['passed']
h=json.loads(H.read_text());assert not h['released_modes']
P.mkdir()
for n,d in f['runtime_files'].items():assert sha(B/n)==d;shutil.copyfile(B/n,P/n)
f.update(scene='User moved camera from curtain to wall; fresh diagnostic observation',source_packet=str(B.relative_to(R)),source_packet_byte_identical=True,execution_approved=True,scope='one new2s S short capture using proven RX14, no mode/receiver changes, then stock restoration')
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h.update(released_modes=[f['mode']],released_mode_scope=f['scope'],release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'));H.write_text(json.dumps(h,indent=2)+'\n')
trial.CANDIDATE=P;sys.argv=[sys.argv[0],'--execute']
try:rc=trial.main()
finally:
 h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='single fresh wall reference capture consumed');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
