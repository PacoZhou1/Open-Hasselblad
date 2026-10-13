"""Fixed one-frame normal receiver run and independent SSD payload readback."""
import hashlib
import json
from pathlib import Path
import sys

import source_session_test as session
from factory_session import connect
from gui_session import adb

ROOT = Path(__file__).resolve().parents[1]
CANDIDATE = ROOT/'native-video/experimental/source-session-normal-receiver'
MODE = 'normal-receiver'
RUN_PREFIX = 'source-rx'
EXPECTED_BYTES = 22004736
RAW_NAME = 'raw-7408x1482-stride14848.bin'


def main():
    session.CANDIDATE = CANDIDATE
    session.MODE = MODE
    session.RUN_PREFIX = RUN_PREFIX
    session.EXTRA_MARKER = 'receiver.confirmed'
    previous = set((ROOT/'native-video/outputs').glob(RUN_PREFIX+'-*/report.json'))
    rc = session.main()
    if '--execute' not in sys.argv:
        return rc
    created = set((ROOT/'native-video/outputs').glob(RUN_PREFIX+'-*/report.json')) - previous
    if len(created) != 1:
        raise RuntimeError('Cannot identify this invocation report; never redispatch')
    base_report = created.pop()
    out = base_report.parent
    base = json.loads(base_report.read_text())
    result = {'session_passed': base['passed'], 'passed': False,
              'scope': 'one RAW frame through native callback plus SSD readback; not sustained recording'}
    try:
        device = out/'device-run'
        receipt_path = device/'receiver.receipt'
        receipt_text = receipt_path.read_text().strip() if receipt_path.is_file() else ''
        result['cpu_receipt_status'] = 'present' if receipt_text else 'missing_or_empty'
        result['native_session_failure'] = base.get('failure')
        result['native_health_error'] = base.get('health_error')
        if not receipt_text:
            raise RuntimeError('No CPU drain receipt; native restoration remains unproven. No payload readback attempted.')
        receipt = json.loads(receipt_text)
        result['receiver_receipt'] = receipt
        if not (receipt['scope'] == 'receiver_cpu_drain' and receipt['rc'] == 0 and
                receipt['state'] == 5 and receipt['error'] == 0 and receipt['callback_active'] == 0):
            raise RuntimeError('Receiver did not confirm successful CPU copy and drain')
        if not base['passed'] or not (device/'clone.confirmed').is_file():
            raise RuntimeError('Native session and restoration did not pass; inspect before readback')
        size = int((device/'receiver.raw.bytes').read_text().strip())
        expected = (device/'receiver.raw.sha256').read_text().split()[0]
        if size != EXPECTED_BYTES or len(expected) != 64 or any(c not in '0123456789abcdef' for c in expected):
            raise RuntimeError('Unexpected captured bytes/hash receipt')
        # Factory root can access SSD; ADB reads the exclusive data copy only.
        # This path is this run's unshared staging file, never an existing photo.
        remote = base['remote']
        bulk = '/mnt/media_rw/ssd/x2v-source-20261012/runs/'+base['run_id']+'/raw.partial'
        command = 'cd '+remote+' && test ! -e raw-readback.partial && cp '+bulk+' raw-readback.partial'
        if len(command.encode()) > 231:
            raise RuntimeError('Readback command exceeds factory limit')
        with connect() as f:
            result['factory_copy_reply'] = f.factory_shell(command, capture_ms=6000)
        copied_sha = adb('shell', 'sha256sum '+remote+'/raw-readback.partial').split()[0]
        if copied_sha != expected:
            raise RuntimeError('SSD-to-data copied hash differs')
        local = out/RAW_NAME
        adb('pull', remote+'/raw-readback.partial', str(local), timeout=60)
        actual = hashlib.sha256(local.read_bytes()).hexdigest()
        if local.stat().st_size != size or actual != expected:
            raise RuntimeError('Host RAW readback differs')
        # Release only our duplicate in the small data partition after both
        # readback hashes pass; the SSD source and host evidence remain.
        adb('shell', 'test ! -L '+remote+'/raw-readback.partial && rm '+remote+'/raw-readback.partial')
        result.update(passed=True, raw_bytes=size, raw_sha256=actual, raw_path=str(local),
                      temporary_data_copy_removed=True,
                      native_stop_and_restore=base['recovery_rc'] == '0',
                      new_high_resolution_mode_verified=False)
    except BaseException as exc:
        result['failure'] = repr(exc)
    (out/'raw-readback-report.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({'passed': result['passed'], 'report': str(out/'raw-readback-report.json'),
                      'failure': result.get('failure')}, indent=2))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
