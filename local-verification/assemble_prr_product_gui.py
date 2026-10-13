"""Assemble the persistent ProRes RAW product GUI into the install packet."""
import hashlib
import json
import shutil
from pathlib import Path

R = Path(__file__).resolve().parents[1]
SRC = R / 'native-video/experimental/prr-product-gui'
RT = R / 'native-video/runtime/gui'
UIK = R / 'native-video/experimental/manual-video-product-ui-k/gui'
UIC = R / 'native-video/experimental/raw-proxy-product-device-candidate/ui-template/gui'
PKT = R / 'native-video/outputs/prr-product-release-20261013'
PKG = R / 'native-video/outputs/gui-sessions/prr-gui-persist'

RUNTIME = [
    'Catalog.js',
    'PlaybackSession.qml',
    'VideoGallery.qml',
    'VideoItemSessionAdapter.qml',
    'VideoPlaybackControls.qml',
]
PRODUCT = [
    'RecordingProfiles.qml',
    'ExperimentalVideoSettings.qml',
    'ExperimentalVideoUi.qml',
    'ExperimentalMenuEntry.qml',
    'VideoDriveGrid.qml',
    'RecordingOverlay.qml',
]
OWNED = ['main.qml', 'DriveAttach.qml', 'BodyKeys.qml', 'PrrFrameSurface.qml', 'ExposureTouchTabs.qml']


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def copy_into(dest):
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    rows = {}
    for name in RUNTIME:
        shutil.copy2(RT / name, dest / name)
    for name in PRODUCT:
        src = UIK / name if (UIK / name).is_file() else UIC / name
        shutil.copy2(src, dest / name)
    for name in OWNED:
        shutil.copy2(SRC / name, dest / name)
    for path in sorted(dest.iterdir()):
        if path.is_file():
            rows[path.name] = sha(path)
    return rows


def main():
    overlay = PKT / 'overlay/gui'
    files = copy_into(overlay)
    data_gui = PKT / 'data/x2v-native-20261012/raw-product-device/gui'
    copy_into(data_gui)
    shutil.copy2(SRC / 'prr_gui_persist.sh', PKT / 'overlay/prr_gui_persist.sh')
    (PKT / 'overlay/prr_gui_persist.sh').chmod(0o755)

    if PKG.exists():
        shutil.rmtree(PKG)
    payload = PKG / 'payload'
    payload.mkdir(parents=True)
    shutil.copytree(overlay, payload / 'gui')
    shutil.copy2(SRC / 'x2v_prr_helper.sh', payload / 'helper.sh')
    shutil.copy2(SRC / 'x2v-prr-gui.rc', payload / 'x2v-prr-gui.rc')
    (payload / 'helper.sh').chmod(0o755)
    manifest = ''.join(f'{digest}  gui/{name}\n' for name, digest in sorted(files.items()))
    (payload / 'manifest.sha256').write_text(manifest)
    shutil.copy2(SRC / 'prr_gui_persist.sh', PKG / 'prr_gui_persist.sh')
    (PKG / 'prr_gui_persist.sh').chmod(0o755)
    launch = (
        '#!/system/bin/sh\nset -eu\n'
        'cd /blackbox/x2v-native-20261011/runs/prr-gui-persist\n'
        'exec sh ./prr_gui_persist.sh\n'
    )
    (PKG / 'launch.sh').write_text(launch)
    (PKG / 'launch.sh').chmod(0o755)
    meta = {
        'schema': 1,
        'runid': 'prr-gui-persist',
        'kind': 'persistent-product-gui',
        'camera_gui_sha256': 'b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b',
        'loader_sha256': '2ec7b4686682ea1c5c9e9de87876135e0085b8563c90d223211150c3572708dd',
        'files': files,
        'manifest_sha256': sha(payload / 'manifest.sha256'),
        'script_sha256': sha(PKG / 'prr_gui_persist.sh'),
        'launch_sha256': sha(PKG / 'launch.sh'),
        'restore_on_success': False,
        'note': 'Drive/settings ProRes RAW HQ + proven runtime gallery. Not a bounded gui_session.',
    }
    (PKG / 'package.json').write_text(json.dumps(meta, indent=2, ensure_ascii=False) + '\n')

    man_path = PKT / 'manifest.json'
    man = json.loads(man_path.read_text())
    man['gui'] = {
        'overlay': 'overlay/gui',
        'persist_script': 'overlay/prr_gui_persist.sh',
        'package': 'native-video/outputs/gui-sessions/prr-gui-persist',
        'files': files,
        'restore_on_success': False,
        'features': [
            'Drive video tile + ProRes RAW HQ 3888×2912',
            'Experimental settings: resolution/fps/RAW/format',
            'Shutter full-press start/stop; body Playback opens gallery',
            'No floating 相册/录像, no idle 视频 badge, no persistent format bar',
            'msdec RGB surface playback of clip.mov; no HEVC proxy',
        ],
    }
    man['status'] = 'OFFLINE_PACKET_PLUS_PERSISTENT_GUI'
    man_path.write_text(json.dumps(man, indent=2, ensure_ascii=False) + '\n')
    (PKT / 'README.md').write_text(
        '# X2D II ProRes RAW HQ product packet\n\n'
        'Installable via the existing SHA-pinned `/system` stage protocol. '
        'Does not flash boot or firmware partitions.\n\n'
        '1. Stage each `/system/bin/x2v_*` and `/system/lib64/libx2v_*.so` with `ssd_stage.py`.\n'
        '2. Install the persistent product GUI with '
        '`local-verification/prr_product_gui_install.py` '
        '(Drive / settings / catalog / in-camera playback). '
        'This is not a bounded `gui_session`; stock camera-gui is not restored '
        'while the overlay is healthy.\n'
        '3. Record with the isolated PRR packet; finalize with `x2v_prr_finalize_20261013b TAKE`.\n'
        '4. Playback is msdec → RGB (`x2v_prr_play` on :18763), not an HEVC proxy.\n'
        '5. Stage `/system/bin/x2v_prr_gui_boot_20261013d` '
        '(`source_prr_gui_boot_stage.py --execute`) and write '
        '`/system/etc/init/x2v-prr-gui.rc` (`prr_product_keeper.py init-rc`). '
        'The supervisor is not oneshot: it waits for blackbox overlay files, '
        'then keeps stock camera-gui replaced across reboot.\n'
    )
    print(json.dumps({'overlay': str(overlay), 'package': str(PKG),
                      'files': files}, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    raise SystemExit(main())
