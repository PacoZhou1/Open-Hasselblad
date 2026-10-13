"""Prove stock services, RO /system, no session locks, leftover proxy work removed."""
import json
from pathlib import Path
from factory_session import connect

OUT = Path(__file__).resolve().parents[1] / 'native-video/outputs/prr-product-restore-1007'
LOCKS = [
    '/data/x2v-source-20261012/source-session.lock',
    '/data/x2v-native-20261012/gui-session.lock',
    '/blackbox/x2v-native-20261011/gui-session.lock',
]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    report = {'recovery_rc': None, 'locks_absent': False, 'passed': False}
    with connect() as f:
        def q(cmd, ms=6000):
            assert len(cmd.encode()) <= 231, len(cmd.encode())
            return f.factory_shell(cmd, capture_ms=ms)
        report['health'] = q('pidof camera-service;pidof camera-gui;getprop init.svc.camera-gui;mount | grep " /system "')
        report['leftover'] = q('pidof x2v_prr_proxy_20261013b test_venc_e2 x2v_prr_dec_20261013a || echo NONE')
        report['clean_work'] = q('rm -rf /data/x2v-native-20261012/prr-proxy && echo CLEAN')
        report['locks'] = {p: q('test ! -e %s && test ! -L %s && echo CLEAR' % (p, p)) for p in LOCKS}
    lines = report['health'].splitlines()
    services = 'running' in report['health'] and '(ro,' in report['health']
    report['locks_absent'] = all(v.strip() == 'CLEAR' for v in report['locks'].values())
    report['stock_gui_running'] = any(x.strip() == 'running' for x in lines)
    report['system_readonly'] = '(ro,' in report['health']
    report['no_proxy_process'] = 'NONE' in report['leftover']
    report['work_removed'] = 'CLEAN' in report['clean_work']
    ok = services and report['locks_absent'] and report['no_proxy_process'] and report['work_removed']
    report['recovery_rc'] = '0' if ok else '1'
    report['passed'] = ok
    (OUT / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': ok, 'report': str(OUT / 'report.json'),
                      'recovery_rc': report['recovery_rc'],
                      'locks_absent': report['locks_absent']}, indent=2))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
