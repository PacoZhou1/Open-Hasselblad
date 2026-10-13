"""Read-only camera audit: factory PDAF/SBPC calibration files, codec nodes, thermal, storage, outputs.

Only ls/cat/head/dd/getprop/wc reads are issued. Before/after state is compared so the release
report can show nothing changed. Requires the shared camera lock to be held by OWNER.
"""
import datetime
import json
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from factory_session import connect  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OWNER = 'z-claude-readonly-audit'
OUT = ROOT / ('research/claude-audit-20261013/device-readonly-' + datetime.datetime.now().strftime('%H%M%S'))
SESSION_LOCKS = ['/data/x2v-source-20261012/source-session.lock',
                 '/data/x2v-native-20261012/gui-session.lock',
                 '/blackbox/x2v-native-20261011/gui-session.lock']
STATE = 'echo cs=$(pidof camera-service) gui=$(pidof camera-gui) usb=$(getprop sys.usb.config);cat /proc/uptime'
CHUNKED = ['/factory_data/imx861pdaf.json', '/factory_data/pdaf_type3.json', '/factory_data/imx861lvbpc_normal.json']
QUERIES = [
    ('factory_ls', 'ls -la /factory_data /factory_data/camera 2>&1'),
    ('cali_ls', 'ls -la /cali /cali/camera 2>&1; ls -la /cali/camera/* 2>&1 | head -c 5000'),
    ('fcali_ls', 'ls -la /data/fcali 2>&1 | head -c 3000'),
    ('sizes', 'wc -c /factory_data/imx861pdaf.json /factory_data/pdaf_type3.json /factory_data/imx861lvbpc_normal.json /factory_data/as7341.json 2>&1'),
    ('module_info', 'cat /cali/camera/sensor_module_info 2>&1 | head -c 2000; ls -la /cali/camera/IMX461BQR 2>&1 | head -c 3000'),
    ('thermal', 'for z in /sys/class/thermal/thermal_zone*;do echo $(cat $z/type) $(cat $z/temp);done 2>&1'),
    ('nvme', 'cat /sys/class/nvme/nvme0/model /sys/class/nvme/nvme0/firmware_rev /sys/block/nvme0n1/queue/max_hw_sectors_kb 2>&1'),
    ('drm', 'ls /sys/class/drm 2>&1;for c in /sys/class/drm/*/status;do echo $c $(cat $c);done 2>&1'),
    ('dev_nodes', "ls /dev | grep -iE 'vc_|prores|moon|msenc|msdec|j2k|jpegls|jls|cnn|vision|sgbm|vcr|icc|dsp|hantro|hx280|vcam' 2>&1"),
    ('devfreq', 'for d in /sys/class/devfreq/*;do echo $d $(cat $d/cur_freq) / $(cat $d/available_frequencies);done 2>&1 | head -c 4000'),
    ('usb_gadget', 'ls /config/usb_gadget/*/functions /config/usb_gadget/*/configs/*/ 2>&1 | head -c 3000'),
    ('processes', 'ps -A -o PID,NAME 2>&1 | head -c 6000'),
]


def lock_owner():
    out = subprocess.run([sys.executable, str(ROOT / 'local-verification/camera_testing.py'), 'status'],
                         capture_output=True, text=True, check=True).stdout
    return json.loads(out).get('owner')


def main():
    if lock_owner() != OWNER:
        raise SystemExit('Camera lock not held by ' + OWNER)
    OUT.mkdir(parents=True, exist_ok=False)
    log = []

    def q(f, name, cmd, capture_ms=5000):
        assert len(cmd.encode()) <= 231, (name, len(cmd.encode()))
        v = f.factory_shell(cmd, capture_ms=capture_ms)
        log.append({'name': name, 'command': cmd, 'output': v})
        return v

    report = {'operator': OWNER, 'started': datetime.datetime.now().astimezone().isoformat(),
              'device_writes': 0, 'recovery_rc': None, 'locks_absent': False}
    with connect() as f:
        report['before'] = q(f, 'state_before', STATE)
        out = {name: q(f, name, cmd) for name, cmd in QUERIES}
        sizes = out['sizes']
        for path in CHUNKED:
            m = re.search(r'(\d+)\s+' + re.escape(path), sizes)
            if not m:
                continue
            total = min(int(m.group(1)), 512 * 1024)
            parts = []
            for k in range((total + 2047) // 2048):
                parts.append(q(f, 'chunk', 'dd if=%s bs=2048 skip=%d count=1 2>/dev/null' % (path, k)))
            (OUT / Path(path).name).write_text(''.join(parts))
        report['after'] = q(f, 'state_after', STATE)
        report['locks_absent'] = all(
            q(f, 'lock', 'test ! -e %s && test ! -L %s && echo CLEAR' % (p, p)).strip() == 'CLEAR'
            for p in SESSION_LOCKS)
    same = report['before'].splitlines()[0] == report['after'].splitlines()[0]
    report['state_unchanged'] = same
    report['recovery_rc'] = '0' if same else '1'
    report['finished'] = datetime.datetime.now().astimezone().isoformat()
    (OUT / 'queries.json').write_text(json.dumps(log, indent=1, ensure_ascii=False) + '\n')
    (OUT / 'report.json').write_text(json.dumps(report, indent=1, ensure_ascii=False) + '\n')
    print(json.dumps(report, ensure_ascii=False))
    print(OUT)


if __name__ == '__main__':
    main()
