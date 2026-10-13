"""Read midpoint plus one extra in-camera DNG per clip after recovery. Keep SSD sources."""
from pathlib import Path
import hashlib, json, secrets, subprocess, sys, time
from factory_session import connect
from gui_session import adb

R = Path(__file__).resolve().parents[1]


def main():
    P = R / "native-video/outputs" / sys.argv[1]
    D = P / "dng-sample-readback"
    base = json.loads((P / "report.json").read_text())
    assert base.get("recovery_rc") == "0" and base.get("locks_absent") is True
    D.mkdir(exist_ok=False)
    remote = "/data/x2v-source-20261012/runs/" + P.name
    bulk = "/mnt/media_rw/ssd/x2v-source-20261012/runs/" + P.name
    report = {
        "passed": False,
        "scope": "two actual in-camera DNGs per clip (mid + extra); originals retained",
        "samples": [],
    }
    try:
        assert adb("shell", "getprop init.svc.camera-service").strip() == "running"
        with connect() as f:
            def q(c):
                assert len(c.encode()) <= 231
                return f.factory_shell(c, capture_ms=2000).strip()

            for lock in [
                "/data/x2v-source-20261012/source-session.lock",
                "/data/x2v-native-20261012/gui-session.lock",
                "/blackbox/x2v-native-20261011/gui-session.lock",
            ]:
                assert q("test ! -e " + lock + " && test ! -L " + lock + " && echo CLEAR") == "CLEAR"
            for suffix in ["", "2"]:
                rx = json.loads((P / ("device-run/receiver" + suffix + ".receipt")).read_text())
                n = int(rx["frames_written"])
                indices = [n // 2]
                extra = max(8, n // 4)
                if extra != indices[0] and extra < n:
                    indices.append(extra)
                for ix in indices:
                    source = bulk + "/dng" + suffix + f"/frame-{ix:06d}.dng"
                    identity = q("test ! -L " + source + ' && stat -c "%d:%i:%h:%s" ' + source)
                    assert identity.split(":")[-2:] == ["1", "23100928"]
                    temp = remote + "/dng-read-" + secrets.token_hex(4)
                    assert int(q("df -k /data | tail -n 1").split()[-3]) * 1024 > 23100928 + 33554432
                    q("(umask 077;set -C;cat " + source + " >" + temp + ")")
                    digest = adb("shell", "sha256sum " + temp).split()[0]
                    path = D / f'clip{suffix or "1"}-frame-{ix:06d}-UNCALIBRATED.dng'
                    start = time.monotonic()
                    with path.open("xb") as out:
                        z = subprocess.run(
                            ["adb", "-s", "123456789ABCDEF", "exec-out", "cat", temp],
                            stdout=out, stderr=subprocess.PIPE, timeout=15,
                        )
                    assert z.returncode == 0, z.stderr
                    assert path.stat().st_size == 23100928 and hashlib.sha256(path.read_bytes()).hexdigest() == digest
                    assert q('stat -c "%d:%i:%h:%s" ' + source) == identity
                    adb("shell", "test ! -L " + temp + " && rm " + temp)
                    report["samples"].append(
                        {
                            "generation": rx["clip_generation"],
                            "index": ix,
                            "native_id": rx[f"frame{ix}_id"],
                            "path": str(path),
                            "sha256": digest,
                            "source_identity": identity,
                            "readback_seconds": time.monotonic() - start,
                        }
                    )
            report["passed"] = True
    except BaseException as e:
        report["failure"] = repr(e)
    (D / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    if not report["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
