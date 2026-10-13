"""One bounded user-confirmed flat-wall metadata trial; root reviewed, no encoder change."""
from pathlib import Path
import datetime
import hashlib
import json
import sys
import grok_proxy_g4_test as trial

R = Path(__file__).resolve().parents[1]
P = R / "native-video/experimental/grok-raw-proxy-g4-session"
H = R / "local-verification/source_session_execution_hold.json"
MODE = "isolated-two-grok-proxy-g4"

if sys.argv[1:] != ["--execute"]:
    print("OFFLINE GROK4 RTP header peek trial")
    raise SystemExit(0)

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
freeze = json.loads((P / "freeze.json").read_text())
assert freeze["hard_hold"] and not freeze["execution_approved"]
stages = sorted((R / "native-video/outputs").glob("source-proxy-grok4-stage-*/report.json"))
assert stages
stage = json.loads(stages[-1].read_text())
assert stage["passed"] and stage["source_sha256"] == freeze["receiver_sha256"]
assert stage["destination"] == freeze["receiver_path"]
for name, digest in freeze["runtime_files"].items():
    assert sha(P / name) == digest
hold = json.loads(H.read_text())
assert hold["released_modes"] == []
freeze.update(execution_approved=True,hard_hold=False)
(P / "freeze.json").write_text(json.dumps(freeze, indent=2) + "\n")
hold.update(released_modes=[MODE], release_time=datetime.datetime.now().astimezone().isoformat(),
            released_packet_freeze_sha256=sha(P / "freeze.json"),
            released_mode_scope="One two-clip RAW trial, first with bounded named hardware AVC probe")
H.write_text(json.dumps(hold, indent=2) + "\n")
try:
    rc = trial.main()
finally:
    hold = json.loads(H.read_text())
    hold.update(released_modes=[], revocation_reason="GROK4 RTP header peek one-shot consumed")
    H.write_text(json.dumps(hold, indent=2) + "\n")
raise SystemExit(rc)
