#!/usr/bin/env python3
"""Atomic grok-banding claim, one sim-switch Tv80/92 capture, judge, restore, release.

No ADB/USB/factory unless claim succeeds. Does not steal or delete another owner lock.
"""
from pathlib import Path
import datetime, json, subprocess, sys

R = Path(__file__).resolve().parents[1]
TESTING = R / "TESTING.md"
LOCK_OWNER = R / "local-verification/camera-testing.lock/owner.json"
CLAIM = R / "local-verification/camera_testing.py"
ONCE = R / "local-verification/grok_banding_sim_once.py"
READ = R / "local-verification/grok_banding_read_samples.py"
JUDGE = (
    R
    / "research/full-fov-pipeline/grok-banding-independent-20261012/banding/hardware-exposure/judge_response.py"
)
PY = R / ".venv/bin/python"
TASK = "MODE21 one-factor sim/liveview switch then Tv80/92 same Sv36; RX25 24fps; restore all"
DEVICE_PY = PY if PY.is_file() else Path(sys.executable)


def run(args, check=True, cwd=None):
    r = subprocess.run([str(x) for x in args], capture_output=True, text=True, cwd=cwd)
    if check and r.returncode:
        raise SystemExit(r.stdout + "\n" + r.stderr)
    return r


def status():
    r = run([sys.executable, CLAIM, "status"])
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return {"state": "unknown", "raw": r.stdout}


def main():
    st = status()
    print("TESTING.md:\n" + TESTING.read_text())
    print("lock:", json.dumps(st, ensure_ascii=False))
    if st.get("state") not in (None, "available") and LOCK_OWNER.exists():
        print("PREPARED_WAITING_FOR_DEVICE")
        print("owner=", st.get("owner"), "task=", st.get("task"))
        print("packet ready: native-video/experimental/grok-banding-sim-exposure")
        print("claim later: python3 local-verification/grok_banding_claim_and_run.py")
        raise SystemExit(2)
    claim = run([sys.executable, CLAIM, "claim", "grok-banding", TASK], check=False)
    if claim.returncode:
        print(claim.stdout)
        print(claim.stderr)
        print("PREPARED_WAITING_FOR_DEVICE claim_failed")
        raise SystemExit(2)
    claimed = json.loads(claim.stdout)
    print("CLAIMED", json.dumps(claimed, ensure_ascii=False))
    restore = {
        "recovery_rc": None,
        "locks_absent": False,
        "operator": "grok-banding",
        "claimed_at": claimed.get("claimed_at"),
        "task": TASK,
    }
    try:
        run([sys.executable, CLAIM, "update", "grok-banding", "RUNNING " + TASK])
        once = run([DEVICE_PY, ONCE, "--execute"], check=False, cwd=str(R / "local-verification"))
        print(once.stdout)
        print(once.stderr, file=sys.stderr)
        report_file = None
        for line in reversed((once.stdout or "").splitlines()):
            line = line.strip()
            if line.startswith("{") and '"report"' in line:
                try:
                    report_file = Path(json.loads(line)["report"])
                    break
                except (json.JSONDecodeError, KeyError, TypeError):
                    pass
        if report_file is None:
            blob = once.stdout or ""
            key = '"report": "'
            if key in blob:
                report_file = Path(blob.split(key, 1)[1].split('"', 1)[0])
        if report_file is None or not report_file.is_file():
            raise RuntimeError("no native report in once stdout")
        native = json.loads(report_file.read_text())
        restore["native_report"] = str(report_file)
        restore["run_id"] = native.get("run_id")
        restore["recovery_rc"] = native.get("recovery_rc")
        restore["locks_absent"] = bool(native.get("locks_absent"))
        restore["body_rc"] = native.get("body_rc")
        restore["sim_switch"] = native.get("sim_switch")
        restore["exposure_user_settings_restored"] = native.get("exposure_user_settings_restored")
        restore["sim_restored"] = native.get("sim_restored")
        restore["passed_native"] = native.get("passed")
        restore["native_failure"] = native.get("failure")
        if restore["recovery_rc"] == "0" and restore["locks_absent"] and native.get("exposure_platforms_selected_confirmed"):
            run([sys.executable, CLAIM, "update", "grok-banding", "READBACK " + native.get("run_id", "")])
            sample = run([DEVICE_PY, READ, native["run_id"]], check=False, cwd=str(R / "local-verification"))
            print(sample.stdout)
            restore["sample_readback_rc"] = sample.returncode
            if sample.returncode == 0:
                sample_dir = report_file.parent / "dng-sample-readback"
                samples = json.loads((sample_dir / "report.json").read_text())["samples"]
                judge = run(
                    [
                        str(PY),
                        str(JUDGE),
                        "--clip1-jsonl",
                        str(report_file.parent / "device-run/dng.metadata.jsonl"),
                        "--clip2-jsonl",
                        str(report_file.parent / "device-run/dng2.metadata.jsonl"),
                        "--clip1-dng",
                        samples[0]["path"],
                        "--clip2-dng",
                        samples[1]["path"],
                        "--switch",
                        native.get("sim_switch") or "",
                        "--out",
                        str(
                            R
                            / "research/full-fov-pipeline/grok-banding-independent-20261012/banding/hardware-exposure"
                            / ("judge-" + native["run_id"] + ".json")
                        ),
                    ],
                    check=False,
                )
                print(judge.stdout)
                restore["judge_rc"] = judge.returncode
                restore["judge_stdout"] = judge.stdout
        restore["finished_at"] = datetime.datetime.now().astimezone().isoformat()
    except BaseException as e:
        restore["wrapper_failure"] = repr(e)
        print("WRAPPER", e)
    report_path = R / "local-verification" / (
        "grok_banding_restore-" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + ".json"
    )
    if restore.get("recovery_rc") != "0" or restore.get("locks_absent") is not True:
        restore["held"] = True
        report_path.write_text(json.dumps(restore, indent=2, ensure_ascii=False) + "\n")
        print("HOLDING_LOCK recovery incomplete", report_path)
        print(json.dumps(restore, indent=2, ensure_ascii=False))
        raise SystemExit(1)
    restore["held"] = False
    report_path.write_text(json.dumps(restore, indent=2, ensure_ascii=False) + "\n")
    rel = run([sys.executable, CLAIM, "release", "grok-banding", str(report_path)])
    print("RELEASED", rel.stdout)
    print(json.dumps(restore, indent=2, ensure_ascii=False))
    raise SystemExit(0 if restore.get("passed_native") and restore.get("judge_rc") == 0 else 1)


if __name__ == "__main__":
    main()
