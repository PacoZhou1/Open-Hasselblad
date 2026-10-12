"""Post-test verification for a Claude camera session; writes the release report.

Usage: claude_prr_finish.py [owner]   (default z-claude-prores-raw)

Recovery holds only when camera-service and camera-gui have been running since before the lock was
claimed (so nothing in this session restarted them), no encoder/decoder test process survives, every
directory created on /data was removed again, and none of the shared session lock files exist.
"""
import datetime
import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from claude_prr_factory import OWNER  # noqa: E402
from claude_readonly_audit import ROOT, SESSION_LOCKS, STATE, lock_owner  # noqa: E402
from factory_session import connect  # noqa: E402

OUT = ROOT / 'research/prores-raw-20261013/device-finish'
CREATED = ['/data/local/tmp/x2v-claude-prr', '/data/local/tmp', '/data/local', '/data/codec_debug_hub']
LEFTOVER = 'pidof test_msenc test_msdec test_msenc_p0 test_msenc_p1 test_msenc_p2 test_msenc_p3 x2v_prr_enc x2v_prr_dec || echo NONE'
STARTS = ('for n in camera-service camera-gui;do p=$(pidof $n);echo $n $p $(cut -d" " -f22 /proc/$p/stat);done;'
          'cut -d" " -f1 /proc/uptime;date +%s')
CLK_TCK = 100


def claimed_at():
    out = subprocess.run([sys.executable, str(ROOT / 'local-verification/camera_testing.py'), 'status'],
                         capture_output=True, text=True, check=True).stdout
    return datetime.datetime.fromisoformat(json.loads(out)['claimed_at'])


def main():
    owner = sys.argv[1] if len(sys.argv) > 1 else OWNER
    if lock_owner() != owner:
        raise SystemExit('Camera lock not held by ' + owner)
    claim = claimed_at()
    report = {'operator': owner, 'finished': datetime.datetime.now().astimezone().isoformat(),
              'claimed_at': claim.isoformat(), 'recovery_rc': None, 'locks_absent': False}
    with connect() as f:
        def q(cmd):
            assert len(cmd.encode()) <= 231, cmd
            return f.factory_shell(cmd, capture_ms=5000).strip()
        report['state'] = q(STATE)
        lines = q(STARTS).splitlines()
        uptime, now = float(lines[2]), int(lines[3])
        report['service_started_at'] = {}
        for line in lines[:2]:
            name, pid, ticks = line.split()
            started = now - (uptime - int(ticks) / CLK_TCK)
            report['service_started_at'][name] = {
                'pid': int(pid),
                'started': datetime.datetime.fromtimestamp(started).astimezone().isoformat(timespec='seconds')}
        report['leftover_processes'] = q(LEFTOVER)
        report['created_paths_absent'] = {p: q('test ! -e %s && echo ABSENT' % p) == 'ABSENT' for p in CREATED}
        report['locks_absent'] = all(q('test ! -e %s && test ! -L %s && echo CLEAR' % (p, p)) == 'CLEAR'
                                     for p in SESSION_LOCKS)
    same_services = all(datetime.datetime.fromisoformat(v['started']) < claim
                        for v in report['service_started_at'].values())
    ok = same_services and report['leftover_processes'] == 'NONE' and all(report['created_paths_absent'].values())
    report['services_running_since_before_claim'] = same_services
    report['recovery_rc'] = '0' if ok else '1'
    out = OUT / owner
    out.mkdir(parents=True, exist_ok=True)
    (out / 'report.json').write_text(json.dumps(report, indent=1, ensure_ascii=False) + '\n')
    print(json.dumps(report, ensure_ascii=False, indent=1))
    print(out / 'report.json')


if __name__ == '__main__':
    main()
