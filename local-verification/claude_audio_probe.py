"""Read-only audio / wireless-mic probe over the factory shell (hbl_camera_service context).

Only ls/cat/getprop/ps/dumpsys-style reads. Requires the shared camera lock to be held by OWNER.
Usage: claude_audio_probe.py [query-set]   (sets: base, more)
"""
import datetime
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from claude_readonly_audit import ROOT, STATE, lock_owner  # noqa: E402
from factory_session import connect  # noqa: E402

OWNER = 'z-claude-audio-mic'
OUT = ROOT / 'research/claude-audio-20261013'
SETS = {
    'base': [
        ('cards', 'cat /proc/asound/cards /proc/asound/pcm 2>&1; ls -l /dev/snd 2>&1'),
        ('asound_tree', 'ls -R /proc/asound 2>&1 | head -c 3000'),
        ('procs', "ps -A -o PID,NAME 2>&1 | grep -iE 'audio|sound|mic|bt|blue|wireless|usb|media|dji' | head -c 3000"),
        ('props', "getprop | grep -iE 'audio|bt|blue|mic|wireless|usb|snd' | head -c 4000"),
        ('usb_host', 'ls /sys/bus/usb/devices 2>&1; for d in /sys/bus/usb/devices/*/product; do echo $d $(cat $d); done 2>&1 | head -c 2000'),
        ('bt_nodes', "ls /dev 2>&1 | grep -iE 'tty|hci|bt|rfkill|uhid|wlan|sdio' | tr '\\n' ' '; ls /sys/class/rfkill /sys/class/bluetooth 2>&1"),
        ('net', 'ls /sys/class/net 2>&1; cat /proc/net/dev 2>&1 | head -c 1200'),
    ],
}


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else 'base'
    extra = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    if lock_owner() != OWNER:
        raise SystemExit('Camera lock not held by ' + OWNER)
    queries = extra if extra else SETS[name]
    OUT.mkdir(parents=True, exist_ok=True)
    out = {'started': datetime.datetime.now().astimezone().isoformat()}
    with connect() as f:
        out['state'] = f.factory_shell(STATE, capture_ms=5000).strip()
        for key, cmd in queries:
            assert len(cmd.encode()) <= 231, (key, len(cmd.encode()))
            try:
                out[key] = f.factory_shell(cmd, capture_ms=15000)
            except Exception as e:  # one slow or failing read must not discard the others
                out[key] = 'ERROR: %s' % e
    path = OUT / ('probe-%s-%s.json' % (name, datetime.datetime.now().strftime('%H%M%S')))
    path.write_text(json.dumps(out, indent=1, ensure_ascii=False) + '\n')
    for k, v in out.items():
        print('=====', k)
        print(v if isinstance(v, str) else v)
    print(path)


if __name__ == '__main__':
    main()
