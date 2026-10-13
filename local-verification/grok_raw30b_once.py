"""One authorized actual two-clip 30fps RAW round2 HAL field76=3000."""
import datetime,hashlib,json,sys
from pathlib import Path
R=Path(__file__).resolve().parents[1]
P=R/'native-video/experimental/grok-raw30b-session'
H=R/'local-verification/source_session_execution_hold.json'
MODE='isolated-two-grok-raw30b'
if sys.argv[1:]!=['--execute']:
    print('OFFLINE grok-raw30b 30fps HAL3000 capture');raise SystemExit(0)
import grok_raw30b_isolated_two_test as trial
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
freeze=json.loads((P/'freeze.json').read_text())
assert freeze['hard_hold'] and not freeze['execution_approved']
for label in ('receiver','validator'):
    reports=sorted((R/'native-video/outputs').glob('source-grok-raw30b-'+label+'-stage-*/report.json'))
    assert reports, 'missing grok-raw30b '+label+' stage'
    report=json.loads(reports[-1].read_text())
    assert report['passed'] and report['source_sha256']==freeze[label+'_sha256']
    assert report['destination']==freeze[label+'_path']
for name,digest in freeze['runtime_files'].items():assert sha(P/name)==digest
hold=json.loads(H.read_text());assert hold['released_modes']==[]
freeze.update(execution_approved=True,hard_hold=False,root_review='grok-hardware round2 HAL field76=3000 D18/HB25 30/1')
(P/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n')
hold.update(released_modes=[MODE],release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P/'freeze.json'),
            released_mode_scope='Round2 actual two-clip 30fps HAL field76=3000')
H.write_text(json.dumps(hold,indent=2)+'\n')
try:rc=trial.main()
finally:
    hold=json.loads(H.read_text())
    hold.update(released_modes=[],revocation_reason='grok-raw30b HAL3000 once consumed')
    H.write_text(json.dumps(hold,indent=2)+'\n')
raise SystemExit(rc)
