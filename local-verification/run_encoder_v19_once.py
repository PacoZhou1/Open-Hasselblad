"""One bounded native hardware encoder branch coexistence/metrics trial."""
from pathlib import Path
import hashlib,json,sys,datetime
import isolated_two_v19_encoder_test as trial
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-two-v19-encoder';H=R/'local-verification/source_session_execution_hold.json';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();mode='isolated-two-v19-encoder'
if sys.argv[1:]!=['--execute']:print('OFFLINE hardware encoder role5 trial');raise SystemExit(0)
f=json.loads((P/'freeze.json').read_text());assert f['hard_hold'] and not f['execution_approved']
assert json.loads((R/'native-video/outputs/source-isolated-200007/raw-isp-concurrency.json').read_text())['passed']
for n,h in f['runtime_files'].items():assert sha(P/n)==h
h=json.loads(H.read_text());assert h['released_modes']==[]
f.update(execution_approved=True,hard_hold=False,root_review='Original complete native VENC branch copied; public role5 same manager native start/initRecording and stop audited. Transport remainsNone, no payload claim. First clip RAW+ISP/second addsVENC. Exact newstart/stop intent, no unknown retry, same owner, group13 after each single operation, whole completion unchanged. Sequential readonly3samples replaces2s sleep with4s bound; sourcearm/sourcecaps unchanged. ExistingRX18 ELF/ACK16 unchanged.')
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n');h.update(released_modes=[mode],released_mode_scope='One RAW+ISP then RAW+ISP+nativeVENC bounded pair with readonlyresource samples; no encoded file claim',release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'));H.write_text(json.dumps(h,indent=2)+'\n')
try:rc=trial.main()
finally:
 h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='V19 hardware encoder one-shot consumed');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
