"""One bounded user-confirmed flat-wall metadata trial; root reviewed, no encoder change."""
from pathlib import Path
import datetime
import hashlib
import json
import sys
import isolated_two_v24c_exposure_test as trial

R = Path(__file__).resolve().parents[1]
P = R / "native-video/experimental/source-session-isolated-two-v24c-exposure"
H = R / "local-verification/source_session_execution_hold.json"
MODE = "isolated-two-v24c-exposure"

if sys.argv[1:] != ["--execute"]:
    print("OFFLINE V24c native exposure trial")
    raise SystemExit(0)

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
freeze = json.loads((P / "freeze.json").read_text())
assert freeze["hard_hold"] and not freeze["execution_approved"]
for label,key in [('receiver','receiver'),('validator','validator')]:
    stages=sorted((R/'native-video/outputs').glob('source-exposure-v24-'+label+'-stage-*/report.json'))
    assert stages
    stage=json.loads(stages[-1].read_text())
    assert stage['passed'] and stage['source_sha256']==freeze[key+'_sha256']
    assert stage['destination']==freeze[key+'_path']
for name, digest in freeze["runtime_files"].items():
    assert sha(P / name) == digest
hold = json.loads(H.read_text())
assert hold["released_modes"] == []
freeze.update(execution_approved=True, hard_hold=False,
              root_review="V24 private70s receiver/validator and actual shell restoration checks; native selected Manual0 Sv36 Tv80→92; E RAW+ISP+metadata/stop retained; exact exposure frame match remains0. No role5 encoder. Root owns hardware dispatch.",
              condition={"lens_cap": "removed_user_confirmed", "scene": "user_confirmed_uniform_wall", "exposure_controlled": "selected_requested_until_RAW_metadata_response",
                         "purpose": "Tv80→92 native exposure response and phase banding"})
(P / "freeze.json").write_text(json.dumps(freeze, indent=2) + "\n")
hold.update(released_modes=[MODE], release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P / "freeze.json"),
            released_mode_scope="One two-clip V24 controlled selected exposure test; settings restored; no encoder")
H.write_text(json.dumps(hold, indent=2) + "\n")
try:
    rc = trial.main()
finally:
    hold = json.loads(H.read_text())
    hold.update(released_modes=[], revocation_reason="V24c exposure one-shot consumed")
    H.write_text(json.dumps(hold, indent=2) + "\n")
raise SystemExit(rc)
