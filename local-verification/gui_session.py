"""Prepare/test an immutable GUI package; explicitly deploy one bounded session.

`prepare` is entirely offline. Only `deploy`, `status`, `stop`, and `stage`
contact the camera. Device changes go through the verified factory domain.
"""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys
import time

PROJECT = Path(__file__).resolve().parents[1]
NATIVE = PROJECT / 'native-video'
REMOTE = '/blackbox/x2v-native-20261011'
SERIAL = '123456789ABCDEF'
SERVICE_SHA = '51b9e02f8bfebf388be8dfa163c8e512bee19aeb8ae37a6712727ccc6f26a52d'
GUI_SHA = 'b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b'
LOADER_SHA = '2ec7b4686682ea1c5c9e9de87876135e0085b8563c90d223211150c3572708dd'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_id(value):
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,64}', value):
        raise ValueError('Invalid run id')
    return value


def safe_relative(path):
    return bool(re.fullmatch(r'[A-Za-z0-9_./-]+', path)) and not any(
        p in ('', '.', '..') for p in path.split('/'))


def files(root):
    result = {}
    for path in sorted(root.rglob('*')):
        if path.is_symlink():
            raise ValueError(f'Symlink is not allowed: {path}')
        if path.is_dir():
            continue
        relative = path.relative_to(root).as_posix()
        if not path.is_file() or not safe_relative(relative):
            raise ValueError(f'Not a safe regular file: {path}')
        if path.stat().st_size > 16 * 1024 * 1024:
            raise ValueError(f'GUI resource exceeds 16 MiB: {path}')
        result[relative] = sha(path)
    if sum((root/p).stat().st_size for p in result) > 64*1024*1024:
        raise ValueError('GUI package exceeds 64 MiB')
    return result


def prepare(args):
    identity = run_id(args.runid)
    if not 15 <= args.seconds <= 3600:
        raise ValueError('Session duration must be 15–3600 seconds')
    source = args.gui.resolve()
    before = files(source)
    if 'main.qml' not in before:
        raise ValueError('main.qml is required')
    canonical_before = files(NATIVE/'ui')
    for relative, digest in before.items():
        if relative != 'main.qml' and relative.endswith(('.qml', '.js')):
            if canonical_before.get(relative) != digest:
                raise ValueError(f'GUI component differs from desktop-tested ui/{relative}')
    output = (args.output or NATIVE/'outputs/gui-sessions'/identity).resolve()
    output.mkdir(parents=True, exist_ok=False)
    checks = []
    for name in ['check_ui.py', 'check_gallery.py', 'check_camera_extension.py']:
        proc = subprocess.run([sys.executable, str(NATIVE/'tests'/name)], cwd=PROJECT,
                              capture_output=True, text=True, timeout=90)
        (output/(name+'.log')).write_text(proc.stdout + proc.stderr)
        if proc.returncode:
            raise RuntimeError(f'Desktop validation failed: {name}; see {output}')
        checks.append(name)
    if files(source) != before or files(NATIVE/'ui') != canonical_before:
        raise RuntimeError('GUI sources changed during validation; prepare a fresh run')
    payload = output/'payload'
    shutil.copytree(source, payload/'gui')
    manifest = ''.join(f'{digest}  gui/{path}\n' for path, digest in sorted(before.items()))
    (payload/'manifest.sha256').write_text(manifest)
    shutil.copy2(NATIVE/'runtime/gui_session.sh', output/'gui_session.sh')
    launch = f'#!/system/bin/sh\nset -eu\ncd {REMOTE}/runs/{identity}\nexec sh ./gui_session.sh {identity} {args.seconds}\n'
    (output/'launch.sh').write_text(launch)
    metadata = dict(schema=1, runid=identity, seconds=args.seconds,
                    camera_gui_sha256=GUI_SHA, loader_sha256=LOADER_SHA,
                    manifest_sha256=sha(payload/'manifest.sha256'),
                    files=before, script_sha256=sha(output/'gui_session.sh'),
                    launch_sha256=sha(output/'launch.sh'), desktop_checks=checks,
                    native_main_qml_desktop_tested=False,
                    native_main_qml_note='Entry depends on camera-only Qt resources and VideoItem; components were tested, native entry requires bounded device acceptance.',
                    uploaded=False, camera_started=False)
    (output/'package.json').write_text(json.dumps(metadata, ensure_ascii=False, indent=2)+'\n')
    verify_package(output)
    print(json.dumps(dict(package=str(output), **metadata), ensure_ascii=False, indent=2))


def verify_package(package):
    package = package.resolve()
    meta = json.loads((package/'package.json').read_text())
    run_id(meta['runid'])
    if meta['schema'] != 1 or not 15 <= meta['seconds'] <= 3600:
        raise ValueError('Invalid package metadata')
    if meta['camera_gui_sha256'] != GUI_SHA or meta['loader_sha256'] != LOADER_SHA:
        raise ValueError('Unsupported device build')
    actual = files(package/'payload/gui')
    if actual != meta['files']:
        raise ValueError('Prepared GUI changed after validation')
    expected_manifest = ''.join(f'{digest}  gui/{path}\n' for path, digest in sorted(actual.items()))
    if (package/'payload/manifest.sha256').read_text() != expected_manifest:
        raise ValueError('Manifest does not match the complete GUI package')
    for relative, key in [('payload/manifest.sha256', 'manifest_sha256'), ('gui_session.sh', 'script_sha256'), ('launch.sh', 'launch_sha256')]:
        if sha(package/relative) != meta[key]:
            raise ValueError(f'Prepared file changed: {relative}')
    return meta


def adb(*arguments, timeout=20):
    return subprocess.run(['adb', '-s', SERIAL, *arguments], text=True, capture_output=True,
                          timeout=timeout, check=True).stdout


def verify_device():
    if adb('shell', 'getprop ro.product.device').strip() != 'eagle2_hb722':
        raise RuntimeError('ADB device identity mismatch')
    # ADB su cannot read camera-service on this firmware; the factory domain can.
    from factory_session import connect
    with connect():
        pass  # connect verifies exact USB layout, product and camera-service SHA.


def dispatch(remote_run):
    from factory_session import connect
    command = f'cd {remote_run} && toybox nohup sh launch.sh >session.log 2>&1 & echo $!'
    if len(command.encode()) > 231:
        raise ValueError('Factory command exceeds transport limit')
    with connect() as reader:
        pid = reader.factory_shell(command).strip()
    if not pid.isdigit():
        raise RuntimeError(f'Device supervisor dispatch failed: {pid}')
    return int(pid)


def deploy(args):
    package = args.package.resolve()
    meta = verify_package(package)
    verify_device()
    identity = meta['runid']; remote = f'{REMOTE}/runs/{identity}'
    # Reject a running session before upload as well as again in the supervisor.
    adb('shell', f'test ! -e {REMOTE}/gui-session.lock')
    adb('shell', f'mkdir -p {REMOTE}/runs && test ! -e {remote} && mkdir {remote}')
    for name in ['payload', 'gui_session.sh', 'launch.sh']:
        adb('push', str(package/name), f'{remote}/{name}')
    for name, digest in [('payload/manifest.sha256', meta['manifest_sha256']), ('gui_session.sh', meta['script_sha256']), ('launch.sh', meta['launch_sha256'])]:
        if adb('shell', f'sha256sum {remote}/{name}').split()[0] != digest:
            raise RuntimeError(f'Device upload hash mismatch: {name}')
    pid = dispatch(remote)
    deployment = dict(runid=identity, remote=remote, dispatched_pid=pid, uploaded=True,
                      camera_started=False, note='Dispatch alone is not GUI/recording/playback acceptance.')
    (package/'deployment.json').write_text(json.dumps(deployment, indent=2)+'\n')
    for _ in range(30):
        state = status_data(identity)
        if state['phase'] in ('running', 'restored') or state['phase'].startswith('error_'):
            deployment['observed'] = state
            break
        time.sleep(.2)
    (package/'deployment.json').write_text(json.dumps(deployment, indent=2)+'\n')
    print(json.dumps(deployment, indent=2))


def status_data(identity):
    remote = f'{REMOTE}/runs/{run_id(identity)}'
    body = adb('shell', f'for f in phase exit.code session.owner child.identity watchdog.identity restored-stock.pids; do echo FILE:$f; cat {remote}/$f 2>/dev/null || true; done')
    values = {}; name = None
    for line in body.splitlines():
        if line.startswith('FILE:'):
            name = line[5:]; values[name] = ''
        elif name:
            values[name] += line+'\n'
    return dict(runid=identity, phase=values.get('phase', '').strip(), files={k:v.strip() for k,v in values.items()})


def status(args):
    verify_device()
    print(json.dumps(status_data(args.runid), indent=2))


def stop(args):
    verify_device()
    identity = run_id(args.runid)
    remote = f'{REMOTE}/runs/{identity}'
    from factory_session import connect
    # Recovery remains in the factory domain and uses recorded PID+starttime.
    with connect() as reader:
        result = reader.factory_shell(f'sh {remote}/gui_session.sh --recover {identity}', capture_ms=15000)
    print(result)
    print(json.dumps(status_data(identity), indent=2))


def stage(args):
    verify_device()
    identity = run_id(args.runid)
    source = args.source.resolve()
    if not source.is_file() or source.is_symlink() or source.stat().st_size > 64*1024*1024:
        raise ValueError('Artifact must be a regular file no larger than 64 MiB')
    destination = args.destination
    if not re.fullmatch(r'/system/(?:lib64/libx2v_[A-Za-z0-9_.-]+\.so|bin/x2v_[A-Za-z0-9_.-]+)', destination):
        raise ValueError('Destination is outside the X2V artifact namespace')
    digest = sha(source)
    # Upload into a private inbox; the stage script takes the unified device lock.
    inbox = f'{REMOTE}/runs/{identity}_upload'
    adb('shell', f'test ! -e {REMOTE}/gui-session.lock && mkdir -p {REMOTE}/runs && test ! -e {inbox} && mkdir {inbox}')
    for local, name in [(source, 'artifact'), (NATIVE/'runtime/stage_artifact.sh', 'stage_artifact.sh')]:
        adb('push', str(local), f'{inbox}/{name}')
        if adb('shell', f'sha256sum {inbox}/{name}').split()[0] != sha(local):
            raise RuntimeError('Artifact upload digest mismatch')
    launcher = f'#!/system/bin/sh\nexec sh {inbox}/stage_artifact.sh {inbox}/artifact {destination} {digest} {identity}\n'
    output = NATIVE/'outputs/gui-staging'/identity
    output.mkdir(parents=True, exist_ok=False)
    (output/'launch.sh').write_text(launcher)
    adb('push', str(output/'launch.sh'), f'{inbox}/launch.sh')
    # /system staging is verified only in ADB su; GUI start/recovery use factory.
    raw_pid = adb('shell', f'cd {inbox} && toybox nohup sh launch.sh >session.log 2>&1 & echo $!').strip()
    if not raw_pid.isdigit():
        raise RuntimeError('ADB staging supervisor did not launch')
    pid = int(raw_pid)
    print(json.dumps(dict(runid=identity, upload=inbox, dispatched_pid=pid, sha256=digest,
                          destination=destination, note='Check run phase and mount readback before use.'), indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest='action', required=True)
    p = actions.add_parser('prepare'); p.add_argument('--runid', required=True); p.add_argument('--seconds', type=int, default=60)
    p.add_argument('--gui', type=Path, default=NATIVE/'runtime/gui'); p.add_argument('--output', type=Path)
    p = actions.add_parser('deploy'); p.add_argument('--package', type=Path, required=True)
    for name in ['status', 'stop']:
        p = actions.add_parser(name); p.add_argument('--runid', required=True)
    p = actions.add_parser('stage'); p.add_argument('--runid', required=True); p.add_argument('--source', type=Path, required=True); p.add_argument('--destination', required=True)
    args = parser.parse_args()
    globals()[args.action](args)


if __name__ == '__main__':
    main()
