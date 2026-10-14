#!/usr/bin/env python3
"""Push the built payload to the camera and run its installer: deploy.py install|hook|unhook|status."""
import json, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'rx-prr-resident'))
import device_test as d  # noqa: E402

receipt = json.loads(max((HERE / 'dist').glob('x2v-fw-*/receipt.json')).read_text())
DIST = HERE / 'dist' / f"x2v-fw-{receipt['version']}"
FW = next(k for k in receipt['system_files'] if '/x2v_fw_' in k)
STAGE = '/blackbox/x2v-native-20261011/video/fw'
action = sys.argv[1] if len(sys.argv) > 1 else 'status'

if action in ('install', 'hook'):
    d.adb('shell', f'rm -rf {STAGE} && mkdir -p {STAGE}')
    subprocess.run(['adb', '-s', d.SERIAL, 'push', f'{DIST}/.', STAGE + '/'], check=True, capture_output=True)
    d.adb('shell', f'chmod -R a+rX {STAGE}')
# install runs from the stage copy (it is what puts FW in place); later actions use the installed one.
script = f'{STAGE}/{Path(FW).name}' if action == 'install' else FW
arg = f' {STAGE}' if action in ('install', 'hook') else ''
with d.connect() as f:
    print(d.fq(f, f'sh {script} {action}{arg} > {STAGE}.log 2>&1; echo rc=$?', 30000))
print(d.adb('shell', f'cat {STAGE}.log'))
