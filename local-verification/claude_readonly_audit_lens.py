"""Second read-only pass: per-lens calibration files and calibration directory listings (base64 dd reads)."""
import base64
import datetime
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from claude_readonly_audit import OWNER, ROOT, SESSION_LOCKS, STATE, lock_owner  # noqa: E402
from factory_session import connect  # noqa: E402

OUT = ROOT / ('research/claude-audit-20261013/device-readonly-lens-' + datetime.datetime.now().strftime('%H%M%S'))
FILES = ['/cali/camera/IMX461BQR/XCD 55V.cali', '/cali/camera/IMX461BQR/XCD 90V.cali',
         '/cali/camera/imx861lvbpc_normal.bin', '/factory_data/camera/IMX861BQR_intri.cali']
QUERIES = [
    ('cali_tree', 'ls -laR /cali/camera/IMX861BQR /cali/camera/pdaf_type3 2>&1 | head -c 4000'),
    ('zoom_head', 'head -c 1800 /factory_data/imx861lvbpc_zoom.json 2>&1'),
    ('lens_sizes', 'wc -c /cali/camera/IMX461BQR/*.cali /cali/camera/imx861lvbpc_normal.bin 2>&1'),
]


def main():
    if lock_owner() != OWNER:
        raise SystemExit('Camera lock not held by ' + OWNER)
    OUT.mkdir(parents=True, exist_ok=False)
    log = []

    def q(f, name, cmd):
        assert len(cmd.encode()) <= 231, (name, len(cmd.encode()))
        v = f.factory_shell(cmd, capture_ms=5000)
        log.append({'name': name, 'command': cmd, 'output': v})
        return v

    report = {'operator': OWNER, 'started': datetime.datetime.now().astimezone().isoformat(),
              'device_writes': 0, 'recovery_rc': None, 'locks_absent': False, 'files': {}}
    with connect() as f:
        report['before'] = q(f, 'state_before', STATE)
        out = {name: q(f, name, cmd) for name, cmd in QUERIES}
        for path in FILES:
            m = re.search(r'(\d+)', q(f, 'size', 'wc -c < "%s" 2>&1' % path))
            if not m:
                continue
            total = min(int(m.group(1)), 512 * 1024)
            data = bytearray()
            for k in range((total + 1535) // 1536):
                b64 = q(f, 'chunk', 'dd if="%s" bs=1536 skip=%d count=1 2>/dev/null|base64' % (path, k))
                data += base64.b64decode(''.join(b64.split()))
            (OUT / Path(path).name.replace(' ', '_')).write_bytes(bytes(data))
            report['files'][path] = {'expected': total, 'got': len(data)}
        report['after'] = q(f, 'state_after', STATE)
        report['locks_absent'] = all(
            q(f, 'lock', 'test ! -e %s && test ! -L %s && echo CLEAR' % (p, p)).strip() == 'CLEAR'
            for p in SESSION_LOCKS)
    same = report['before'].splitlines()[0] == report['after'].splitlines()[0]
    report['state_unchanged'] = same
    report['recovery_rc'] = '0' if same else '1'
    report['finished'] = datetime.datetime.now().astimezone().isoformat()
    (OUT / 'queries.json').write_text(json.dumps([e for e in log if e['name'] != 'chunk'] + [out], indent=1,
                                                 ensure_ascii=False) + '\n')
    (OUT / 'report.json').write_text(json.dumps(report, indent=1, ensure_ascii=False) + '\n')
    print(json.dumps(report, ensure_ascii=False))
    print(OUT)


if __name__ == '__main__':
    main()
