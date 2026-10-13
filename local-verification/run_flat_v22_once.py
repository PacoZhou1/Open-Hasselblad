"""One bounded flat-wall metadata trial; root reviewed, no encoder change."""
from pathlib import Path
import datetime
import hashlib
import json
import sys
import isolated_two_v22_flat_test as trial

R = Path(__file__).resolve().parents[1]
P = R / "native-video/experimental/source-session-isolated-two-v22-flat"
H = R / "local-verification/source_session_execution_hold.json"
MODE = "isolated-two-v22-flat"

if sys.argv[1:] != ["--execute"]:
    print("OFFLINE V22 native metadata trial")
    raise SystemExit(0)

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
freeze = json.loads((P / "freeze.json").read_text())
assert freeze["hard_hold"] and not freeze["execution_approved"]
stages = sorted((R / "native-video/outputs").glob("source-isp-v18-stage-*/report.json"))
assert stages
stage = json.loads(stages[-1].read_text())
assert stage["passed"] and stage["source_sha256"] == freeze["receiver_sha256"]
assert stage["destination"] == freeze["receiver_path"]
for name, digest in freeze["runtime_files"].items():
    assert sha(P / name) == digest
hold = json.loads(H.read_text())
assert hold["released_modes"] == []
freeze.update(execution_approved=True, hard_hold=False,
              root_review='Previously successful RX18 unchanged binary, exact graph/stop/recovery; current boot and group updated. User confirmed flat wall and cap removed; no metadata getter or encoder change.',
              condition={"lens_cap": "removed_user_confirmed", "exposure_controlled": False,
                         "purpose": "flat-wall pixels first; no exposure control claim"})
(P / "freeze.json").write_text(json.dumps(freeze, indent=2) + "\n")
hold.update(released_modes=[MODE], release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P / "freeze.json"),
            released_mode_scope="One two-clip proven RX18 flat-wall capture; cap removed, no encoder")
H.write_text(json.dumps(hold, indent=2) + "\n")
try:
    rc = trial.main()
finally:
    hold = json.loads(H.read_text())
    hold.update(released_modes=[], revocation_reason="V22 metadata one-shot consumed")
    H.write_text(json.dumps(hold, indent=2) + "\n")
raise SystemExit(rc)
