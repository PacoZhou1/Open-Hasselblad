"""One authorized grok-banding sim-switch + Tv80/92 RAW pair. Reuse staged RX25."""
import datetime, hashlib, json, sys
from pathlib import Path
R=Path(__file__).resolve().parents[1]
P=R/'native-video/experimental/grok-banding-sim-exposure'
H=R/'local-verification/source_session_execution_hold.json'
MODE='isolated-two-grok-banding-sim'
if sys.argv[1:] != ['--execute']:
    print('OFFLINE grok-banding sim-exposure two-clip');raise SystemExit(0)
import grok_banding_sim_exposure_test as trial
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
freeze=json.loads((P/'freeze.json').read_text())
assert freeze['hard_hold'] and not freeze['execution_approved']
for label,key in [('receiver','receiver'),('validator','validator')]:
    stages=sorted((R/'native-video/outputs').glob('source-async-v25-'+label+'-stage-*/report.json'))
    assert stages, 'missing already-staged RX25 '+label
    report=json.loads(stages[-1].read_text())
    assert report['passed'] and report['source_sha256']==freeze[key+'_sha256']
    assert report['destination']==freeze[key+'_path']
for name,digest in freeze['runtime_files'].items():assert sha(P/name)==digest
hold=json.loads(H.read_text());assert hold['released_modes']==[]
freeze.update(execution_approved=True,hard_hold=False,
              root_review='grok-banding one-factor factory switch then Tv80/92 same Sv; RX25 async reused; restore A1/AutoISO and sim originals')
(P/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n')
hold.update(released_modes=[MODE],release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P/'freeze.json'),
            released_mode_scope='One two-clip grok-banding sim-switch Tv80/92; settings restored; no encoder')
H.write_text(json.dumps(hold,indent=2)+'\n')
try:rc=trial.main()
finally:
    hold=json.loads(H.read_text())
    hold.update(released_modes=[],revocation_reason='grok-banding sim-exposure one-shot consumed')
    H.write_text(json.dumps(hold,indent=2)+'\n')
raise SystemExit(rc)
