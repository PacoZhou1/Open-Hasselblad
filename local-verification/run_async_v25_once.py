"""One authorized actual two-clip RAW recording with asynchronous writer."""
import datetime
import hashlib
import json
import sys
from pathlib import Path

R=Path(__file__).resolve().parents[1]
P=R/'native-video/experimental/source-session-isolated-two-v25-async'
H=R/'local-verification/source_session_execution_hold.json'
MODE='isolated-two-v25-async'
if sys.argv[1:] != ['--execute']:
    print('OFFLINE RX25 async writer actual capture');raise SystemExit(0)
import isolated_two_v25_async_test as trial
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
freeze=json.loads((P/'freeze.json').read_text())
assert freeze['hard_hold'] and not freeze['execution_approved']
for label in ('receiver','validator'):
    reports=sorted((R/'native-video/outputs').glob('source-async-v25-'+label+'-stage-*/report.json'))
    assert reports
    report=json.loads(reports[-1].read_text())
    assert report['passed'] and report['source_sha256']==freeze[label+'_sha256']
    assert report['destination']==freeze[label+'_path']
for name,digest in freeze['runtime_files'].items():assert sha(P/name)==digest
hold=json.loads(H.read_text());assert hold['released_modes']==[]
freeze.update(execution_approved=True,hard_hold=False,
              root_review='Grok async writer with CPU-owned metadata, true durable counters and final join; RAW source and native stop unchanged; actual user-requested timing capture')
(P/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n')
hold.update(released_modes=[MODE],release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P/'freeze.json'),
            released_mode_scope='One actual two-clip 24fps RAW async writer timing trial')
H.write_text(json.dumps(hold,indent=2)+'\n')
try:rc=trial.main()
finally:
    hold=json.loads(H.read_text())
    hold.update(released_modes=[],revocation_reason='RX25 async writer once consumed')
    H.write_text(json.dumps(hold,indent=2)+'\n')
raise SystemExit(rc)
