#!/usr/bin/env python3
"""Before releasing the camera: check it is left as delivered (product hooked and idle, /system read-only,
no test process, lock or work directory left) and write the report camera_testing.py release wants.
   release_check.py [report.json]"""
import hashlib, json, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'rx-prr-resident'))
import device_test as d  # noqa: E402

receipt = json.loads(max((HERE / 'dist').glob('x2v-fw-*/receipt.json')).read_text())
DIST = HERE / 'dist' / f"x2v-fw-{receipt['version']}"
HOOK_SHA = hashlib.sha256((DIST / 'weston.ini.hook').read_bytes()).hexdigest()
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / 'evidence' / 'release-report.json'
G = d.BB
TEST_LOCKS = ['/data/x2v-source-20261012/source-session.lock', '/data/x2v-native-20261012/gui-session.lock',
              '/blackbox/x2v-native-20261011/gui-session.lock']
TEST_PROCS = ('bench_', 'x2v_bench', 'tsnap', 'test_msenc', 'test_msdec', 'warmtest', 'vmsamp')


def js(f, path):
    for _ in range(5):
        r = d.fq(f, 'od -An -v -tx1 %s 2>/dev/null; true' % path, 6000)
        try:
            s = bytes.fromhex(''.join(r.split())).decode()
            return json.loads(s) if s else {}
        except ValueError:
            time.sleep(0.3)
    return {}


with d.connect() as f:
    # The lease ends keepawake.sh, which hands screen and sleep back to the camera.
    d.fq(f, 'rm -f %s/keepawake.lease; true' % G, 4000)
    mounts = d.fq(f, "grep ' /system ' /proc/mounts; true", 4000)
    ini = d.fq(f, 'sha256sum /system/etc/weston.ini; true', 4000).split()[:1]
    pids = {n: d.fq(f, 'pidof %s; true' % n, 4000).strip() for n in ('weston', 'camera-service', 'camera-gui')}
    procs = d.fq(f, 'ps -A -o PPID,NAME; true', 8000).splitlines()[1:]
    venc = [p.split()[0] for p in procs if p.split()[-1:] == ['test_venc_e2']]
    stray = sorted({p.split()[-1] for p in procs if any(t in p.split()[-1] for t in TEST_PROCS)})
    locks = {p: d.fq(f, '[ -e %s ] && echo PRESENT || echo CLEAR; true' % p, 4000).strip() for p in TEST_LOCKS}
    work = d.fq(f, '[ -e /data/local ] && echo PRESENT || echo CLEAR; true', 4000).strip()
    state = js(f, '/tmp/x2v-product/state.json')
    time.sleep(12)
    awake = d.fq(f, "ps -A -o ARGS | grep -c '[k]eepawake.sh'; true", 4000).strip()

checks = {
    'system_readonly': ' ro,' in mounts,
    'weston_ini_hooked': ini == [HOOK_SHA],
    'processes_running': all(pids.values()),
    'product_idle': state.get('session') == 'up' and state.get('phase') in ('idle', 'saved') or
                    state.get('mode') == 'photo' and state.get('phase') == 'idle',
    'no_test_process': not stray,
    # Only the resident's armed proxy encoder, a child of camera-service.
    'proxy_encoder_owned': all(p == pids['camera-service'] for p in venc) and len(venc) <= 1,
    'work_removed': work == 'CLEAR',
    'keepawake_ended': awake == '0',
}
locks_absent = all(v == 'CLEAR' for v in locks.values())
report = {
    'recovery_rc': '0' if all(checks.values()) and locks_absent else '1',
    'locks_absent': locks_absent,
    'firmware': receipt['version'],
    'checks': checks,
    'locks': locks,
    'pids': pids,
    'stray_processes': stray,
    'state': {k: state.get(k) for k in ('mode', 'session', 'phase', 'codec', 'uptime')},
}
OUT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
print(json.dumps(report, ensure_ascii=False))
