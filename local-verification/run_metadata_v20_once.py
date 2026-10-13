"""One bounded dark-scene metadata trial; root reviewed, no encoder change."""
from pathlib import Path
import datetime
import hashlib
import json
import sys
import isolated_two_v20_metadata_test as trial

R = Path(__file__).resolve().parents[1]
P = R / "native-video/experimental/source-session-isolated-two-v20-metadata"
H = R / "local-verification/source_session_execution_hold.json"
MODE = "isolated-two-v20-metadata"

if sys.argv[1:] != ["--execute"]:
    print("OFFLINE V20 native metadata trial")
    raise SystemExit(0)

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
freeze = json.loads((P / "freeze.json").read_text())
assert freeze["hard_hold"] and not freeze["execution_approved"]
stages = sorted((R / "native-video/outputs").glob("source-metadata-v20-stage-*/report.json"))
assert stages
stage = json.loads(stages[-1].read_text())
assert stage["passed"] and stage["source_sha256"] == freeze["receiver_sha256"]
assert stage["destination"] == freeze["receiver_path"]
for name, digest in freeze["runtime_files"].items():
    assert sha(P / name) == digest
hold = json.loads(H.read_text())
assert hold["released_modes"] == []
freeze.update(execution_approved=True, hard_hold=False,
              root_review="RX18 geometry/RAW/stop retained. Getter provider and borrowed permission guard reviewed; snapshot CPU-owned in same frame ticket, writer hex only. Actual C lifetime15frames and independent hostdecoder passed; new manifest regex checked. No role5/encoding. User confirmed lens cap. No exposure/ISO mutation in this presence test.",
              condition={"lens_cap": "user_confirmed", "exposure_controlled": False,
                         "purpose": "native metadata presence and first dark-scene baseline"})
(P / "freeze.json").write_text(json.dumps(freeze, indent=2) + "\n")
hold.update(released_modes=[MODE], release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P / "freeze.json"),
            released_mode_scope="One two-clip RAW+ISP metadata presence trial; lens cap, no encoder")
H.write_text(json.dumps(hold, indent=2) + "\n")
try:
    rc = trial.main()
finally:
    hold = json.loads(H.read_text())
    hold.update(released_modes=[], revocation_reason="V20 metadata one-shot consumed")
    H.write_text(json.dumps(hold, indent=2) + "\n")
raise SystemExit(rc)
