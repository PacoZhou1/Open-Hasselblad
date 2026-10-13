"""One authorized actual two-clip 30fps RAW round3 conf DCAM_FPS_3000."""
import datetime,hashlib,json,sys
from pathlib import Path
R=Path(__file__).resolve().parents[1]
P=R/'native-video/experimental/grok-raw30c-session'
H=R/'local-verification/source_session_execution_hold.json'
MODE='isolated-two-grok-raw30c'
if sys.argv[1:]!=['--execute']:
    print('OFFLINE grok-raw30c conf DCAM_FPS_3000 capture');raise SystemExit(0)
import grok_raw30c_isolated_two_test as trial
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
freeze=json.loads((P/'freeze.json').read_text())
assert freeze['hard_hold'] and not freeze['execution_approved']
for label in ('receiver','validator'):
    reports=sorted((R/'native-video/outputs').glob('source-grok-raw30c-'+label+'-stage-*/report.json'))
    assert reports, 'missing grok-raw30c '+label+' stage'
    report=json.loads(reports[-1].read_text())
    assert report['passed'] and report['source_sha256']==freeze[label+'_sha256']
    assert report['destination']==freeze[label+'_path']
for name,digest in freeze['runtime_files'].items():assert sha(P/name)==digest
hold=json.loads(H.read_text());assert hold['released_modes']==[]
freeze.update(execution_approved=True,hard_hold=False,root_review='grok-hardware round3 conf DCAM_FPS_3000')
(P/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n')
hold.update(released_modes=[MODE],release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P/'freeze.json'),
            released_mode_scope='Round3 actual two-clip 30fps conf DCAM_FPS_3000')
H.write_text(json.dumps(hold,indent=2)+'\n')
try:rc=trial.main()
finally:
    hold=json.loads(H.read_text())
    hold.update(released_modes=[],revocation_reason='grok-raw30c conf3000 once consumed')
    H.write_text(json.dumps(hold,indent=2)+'\n')
raise SystemExit(rc)
