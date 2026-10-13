"""Run one short command through the verified factory HblShell; refuses unless z-claude-prores-raw holds the lock."""
import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OWNER = 'z-claude-prores-raw'


def main():
    status = json.loads(subprocess.run([sys.executable, str(ROOT / 'local-verification/camera_testing.py'), 'status'],
                                       capture_output=True, text=True, check=True).stdout)
    if status.get('owner') != OWNER or status.get('state') != 'TESTING':
        raise SystemExit('Camera lock not held by ' + OWNER)
    capture_ms = int(sys.argv[2]) if len(sys.argv) > 2 else 5000
    cmd = sys.argv[1]
    assert len(cmd.encode()) <= 231, len(cmd.encode())
    with connect() as f:
        print(f.factory_shell(cmd, capture_ms=capture_ms))


if __name__ == '__main__':
    main()
