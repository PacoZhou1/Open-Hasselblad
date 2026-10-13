#!/usr/bin/env python3
"""Atomic grok-banding claim, matched-dark Tv80/92 capture, judge, restore, release.

No ADB/USB/factory unless claim succeeds. Does not steal or delete another owner lock.
Requires USER_SCENE_CONFIRMED lens_cap=on.
"""
from pathlib import Path
import datetime, json, subprocess, sys

R = Path(__file__).resolve().parents[1]
TESTING = R / "TESTING.md"
LOCK_OWNER = R / "local-verification/camera-testing.lock/owner.json"
CLAIM = R / "local-verification/camera_testing.py"
HOLD = R / "local-verification/source_session_execution_hold.json"
ONCE = R / "local-verification/grok_banding_dark_once.py"
READ = R / "local-verification/grok_banding_dark_read_samples.py"
BANDING = R / "research/full-fov-pipeline/grok-banding-independent-20261012/banding"
JUDGE = BANDING / "hardware-exposure/judge_dark.py"
ESTIMATE = BANDING / "estimate_class_response.py"
APPLY = BANDING / "hardware-exposure/apply_matched_dark.py"
SCENE = BANDING / "hardware-exposure/USER_SCENE_CONFIRMED.json"
BRIGHT = R / "native-video/outputs/source-isolated-011701/dng-sample-readback"
PY = R / ".venv/bin/python"
TASK = "MODE21 matched dark 011701 settings Tv80/92 Sv36 liveview=true RX25 24fps; restore all"
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


def pick(samples, generation, prefer_mid=True):
    group = [s for s in samples if s["generation"] == generation]
    if not group:
        raise RuntimeError(f"no samples generation {generation}")
    group = sorted(group, key=lambda s: s["index"])
    return group[len(group) // 2] if prefer_mid else group[0]


def main():
    scene = json.loads(SCENE.read_text())
    if scene.get("lens_cap") != "on":
        print("LENS_CAP_NOT_CONFIRMED", json.dumps(scene, ensure_ascii=False))
        raise SystemExit(3)
    st = status()
    print("TESTING.md:\n" + TESTING.read_text())
    print("lock:", json.dumps(st, ensure_ascii=False))
    print("scene:", json.dumps(scene, ensure_ascii=False))
    hold = json.loads(HOLD.read_text()) if HOLD.is_file() else {}
    if hold.get("released_modes"):
        print("READY_WAITING_DARK HOLD released_modes busy", hold.get("released_modes"))
        raise SystemExit(2)
    if st.get("state") not in (None, "available") and LOCK_OWNER.exists():
        print("PREPARED_WAITING_FOR_DEVICE")
        print("READY_WAITING_DARK")
        print("owner=", st.get("owner"), "task=", st.get("task"))
        print("packet ready: native-video/experimental/grok-banding-dark-011701")
        print("claim later: python3 local-verification/grok_banding_dark_claim_and_run.py")
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
        "scene": scene,
    }
    try:
        run([sys.executable, CLAIM, "update", "grok-banding", "RUNNING " + TASK])
        once = run([DEVICE_PY, ONCE, "--execute"], check=False, cwd=str(R / "local-verification"))
        print(once.stdout)
        print(once.stderr, file=sys.stderr)
        report_file = None
        blob = once.stdout or ""
        decoder = json.JSONDecoder()
        idx = 0
        while idx < len(blob):
            start = blob.find("{", idx)
            if start < 0:
                break
            try:
                obj, end = decoder.raw_decode(blob[start:])
            except json.JSONDecodeError:
                idx = start + 1
                continue
            if isinstance(obj, dict) and obj.get("report"):
                report_file = Path(obj["report"])
            idx = start + end
        if report_file is None:
            for line in reversed(blob.splitlines()):
                line = line.strip()
                if line.startswith("{") and '"report"' in line:
                    try:
                        report_file = Path(json.loads(line)["report"])
                        break
                    except (json.JSONDecodeError, KeyError, TypeError):
                        pass
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
        restore["frames"] = None
        if restore["recovery_rc"] == "0" and restore["locks_absent"] and native.get("exposure_platforms_selected_confirmed"):
            run([sys.executable, CLAIM, "update", "grok-banding", "READBACK " + native.get("run_id", "")])
            sample = run([DEVICE_PY, READ, native["run_id"]], check=False, cwd=str(R / "local-verification"))
            print(sample.stdout)
            restore["sample_readback_rc"] = sample.returncode
            if sample.returncode == 0:
                sample_dir = report_file.parent / "dng-sample-readback"
                samples = json.loads((sample_dir / "report.json").read_text())["samples"]
                dark1 = pick(samples, 1)
                dark2 = pick(samples, 2)
                judge_out = BANDING / "hardware-exposure" / ("judge-dark-" + native["run_id"] + ".json")
                judge = run(
                    [
                        str(PY),
                        str(JUDGE),
                        "--clip1-jsonl",
                        str(report_file.parent / "device-run/dng.metadata.jsonl"),
                        "--clip2-jsonl",
                        str(report_file.parent / "device-run/dng2.metadata.jsonl"),
                        "--clip1-dng",
                        dark1["path"],
                        "--clip2-dng",
                        dark2["path"],
                        "--switch",
                        native.get("sim_switch") or "",
                        "--out",
                        str(judge_out),
                    ],
                    check=False,
                )
                print(judge.stdout)
                restore["judge_rc"] = judge.returncode
                restore["judge_stdout"] = judge.stdout
                restore["judge"] = str(judge_out)
                restore["matched_011701_settings"] = False
                if judge_out.is_file():
                    j = json.loads(judge_out.read_text())
                    restore["matched_011701_settings"] = bool(j.get("matched_011701_settings"))
                    restore["mismatches"] = j.get("mismatches")
                bright1 = BRIGHT / "clip1-frame-000031-UNCALIBRATED.dng"
                bright2 = BRIGHT / "clip2-frame-000031-UNCALIBRATED.dng"
                extras = [s["path"] for s in samples if s["path"] not in (dark1["path"], dark2["path"])]
                if restore["matched_011701_settings"] and bright1.is_file() and bright2.is_file():
                    est_dir = BANDING / "candidate" / ("estimate-matched-dark-" + native["run_id"])
                    est_cmd = [
                        str(PY),
                        str(ESTIMATE),
                        "--dark",
                        dark1["path"],
                        "--flat",
                        str(bright1),
                        "--flat2",
                        str(bright2),
                        "--requested-ratio",
                        "0.5",
                        "--out",
                        str(est_dir),
                    ]
                    for extra in extras:
                        est_cmd.extend(["--eval", extra])
                    est_cmd.extend(["--eval", dark2["path"]])
                    est = run(est_cmd, check=False)
                    print(est.stdout)
                    restore["estimate_rc"] = est.returncode
                    restore["estimate"] = str(est_dir / "class-response-estimate.json")
                    est_json = est_dir / "class-response-estimate.json"
                    if est.returncode == 0 and est_json.is_file():
                        e = json.loads(est_json.read_text())
                        coeff_path = BANDING / "candidate" / ("matched-dark-v2-" + native["run_id"] + "-coeffs.json")
                        bounds = {
                            "mode": "MODE21 C24 LiveviewRawCalib graph13",
                            "fps": 24,
                            "exp_mode": "Manual0",
                            "sv": 36,
                            "iso": 100,
                            "video_analog": 2000,
                            "tv": [80, 92],
                            "liveview_exposure_control": True,
                            "dark_run": native.get("run_id"),
                            "bright_run": "source-isolated-011701",
                        }
                        coeff = {
                            "id": "matched_dark_v2_" + native["run_id"],
                            "a": e["a"],
                            "b": e["b"],
                            "deployed": False,
                            "permanent_calibration": False,
                            "neighbor_interpolation": False,
                            "formula": e["formula"],
                            "dark_anchor_median": e["dark_anchor_median"],
                            "exposure_pair": e.get("exposure_pair"),
                            "capture_bounds": bounds,
                            "estimate": str(est_json),
                        }
                        coeff_path.write_text(json.dumps(coeff, indent=2) + "\n")
                        apply_dir = BANDING / "candidate" / ("apply-matched-dark-" + native["run_id"])
                        apply_cmd = [str(PY), str(APPLY), "--coeff", str(coeff_path), "--out", str(apply_dir)]
                        for path in [dark1["path"], dark2["path"], str(bright1), str(bright2), *extras]:
                            apply_cmd.extend(["--dng", path])
                        app = run(apply_cmd, check=False)
                        print(app.stdout)
                        restore["apply_rc"] = app.returncode
                        restore["apply"] = str(apply_dir)
                        restore["coeff"] = str(coeff_path)
                        restore["a"] = e["a"]
                        restore["b"] = e["b"]
                elif not restore["matched_011701_settings"]:
                    restore["fit_skipped"] = "unmatched_shutter_or_gain_or_not_dark"
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
    raise SystemExit(0 if restore.get("passed_native") and restore.get("matched_011701_settings") else 1)


if __name__ == "__main__":
    main()
