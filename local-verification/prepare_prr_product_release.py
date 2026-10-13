"""Offline SHA-pinned PRR product packet. No boot/firmware partition flash."""
import hashlib
import json
import shutil
from pathlib import Path

R = Path(__file__).resolve().parents[1]
B = R / 'native-video/experimental/prores-raw-encoder/build'
UIK = R / 'native-video/experimental/manual-video-product-ui-k/gui'
UIC = R / 'native-video/experimental/raw-proxy-product-device-candidate/ui-template/gui'
RX = R / 'native-video/experimental/rx-prr-async/build/target-token/libx2v_mode21c24_prr_async_v1.TOKEN_REQUIRED.so'
VAL = R / 'native-video/experimental/native-prr-async-receipt-validator/build/x2v_prr_async_receipt_validate_20261013a'
ISO = R / 'native-video/experimental/source-session-isolated-two-prr-async'
OUT = R / 'native-video/outputs/prr-product-release-20261013'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def save(src, dest, mode, rows):
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dest)
    dest.chmod(mode)
    rows.append({'device_path': '/' + dest.relative_to(OUT).as_posix(),
                 'sha256': sha(dest), 'mode': oct(mode), 'bytes': dest.stat().st_size})


def main():
    if OUT.exists():
        raise SystemExit('fresh output required: ' + str(OUT))
    OUT.mkdir(parents=True)
    rows = []
    artifacts = [
        (B / 'x2v_prr_proxy', 'system/bin/x2v_prr_proxy_20261013b', 0o755),
        (B / 'x2v_prr_dec', 'system/bin/x2v_prr_dec_20261013a', 0o755),
        (B / 'libx2v_inotify_guard.so', 'system/lib64/libx2v_inotify_guard.so', 0o644),
        (RX, 'system/lib64/libx2v_mode21c24_prr_async_20261013a.so', 0o644),
        (VAL, 'system/bin/x2v_prr_async_receipt_validate_20261013a', 0o755),
    ]
    for src, rel, mode in artifacts:
        if not src.is_file():
            rows.append({'device_path': '/' + rel, 'sha256': None, 'missing_host_copy': str(src),
                         'note': 'already staged on camera or host artifact not in tree'})
            continue
        save(src, OUT / rel, mode, rows)
    from assemble_prr_product_gui import copy_into, SRC as GUI_SRC
    gui_files = copy_into(OUT / 'overlay/gui')
    copy_into(OUT / 'data/x2v-native-20261012/raw-product-device/gui')
    save(GUI_SRC / 'prr_gui_persist.sh', OUT / 'overlay/prr_gui_persist.sh', 0o755, rows)
    for name, digest in sorted(gui_files.items()):
        rows.append({'device_path': '/blackbox/x2v-native-20261011/gui/' + name,
                     'sha256': digest, 'mode': '0o644'})
    if (UIC / 'RawProductRecorder.qml').is_file():
        save(UIC / 'RawProductRecorder.qml',
             OUT / 'data/x2v-native-20261012/raw-product-device/gui/RawProductRecorder.qml',
             0o644, rows)
    for name in ('controller.sh', 'bootstrap.sh', 'guard.sh',
                 'imx861bqr_hb722.sp', 'imx861bqr_hb722.conf'):
        src = ISO / name
        if src.is_file():
            save(src, OUT / 'data/x2v-source-20261012/packet' / name, 0o500 if name.endswith('.sh') else 0o644, rows)
    finalize = OUT / 'system/bin/x2v_prr_finalize_20261013b'
    finalize.parent.mkdir(parents=True, exist_ok=True)
    finalize.write_text(
        '#!/system/bin/sh\n'
        '# Post-capture: clip.mov -> preview/playback.mp4. Args: TAKE_DIR [WORK_DIR]\n'
        'set -eu\nTAKE=${1:?}; WORK=${2:-/data/x2v-native-20261012/prr-proxy}\n'
        'GUARD=/system/lib64/libx2v_inotify_guard.so\n'
        'BIN=/system/bin/x2v_prr_proxy_20261013b\n'
        'mkdir -p "$WORK" "$TAKE/preview"\n'
        '[ -f "$TAKE/clip.mov" ] || [ -f "$TAKE/raw/clip.mov" ] || exit 2\n'
        'IN=$TAKE/clip.mov; [ -f "$IN" ] || IN=$TAKE/raw/clip.mov\n'
        'LD_PRELOAD=$GUARD "$BIN" -i "$IN" -o "$TAKE/preview/playback.mp4" --work "$WORK" --preload "$GUARD"\n'
    )
    finalize.chmod(0o755)
    rows.append({'device_path': '/system/bin/x2v_prr_finalize_20261013b',
                 'sha256': sha(finalize), 'mode': '0o755', 'bytes': finalize.stat().st_size})
    installer = OUT / 'install.py'
    installer.write_text(
        '"""Stage packet binaries via local-verification/ssd_stage.py --execute. No boot flash."""\n'
        'import json, subprocess, sys\nfrom pathlib import Path\n'
        'P=Path(__file__).resolve().parent; R=P.parents[2]; S=R/"local-verification/ssd_stage.py"\n'
        'rows=json.loads((P/"manifest.json").read_text())["files"]\n'
        'for row in rows:\n'
        '  dest=row["device_path"]\n'
        '  if not dest.startswith("/system/"): continue\n'
        '  src=P/dest[1:]\n'
        '  print("STAGE", dest)\n'
        '  raise SystemExit("invoke source_*_stage.py --execute for each /system artifact; this packet is the pin list")\n'
    )
    manifest = {
        'schema': 'x2v.prr-product-packet/1',
        'status': 'OFFLINE_REVIEW_PACKET_INSTALL_VIA_SSD_STAGE',
        'product': 'Hasselblad X2D II ProRes RAW HQ 3888x2912 + HEVC 1024x768 playback',
        'no_boot_image_or_policy_changes': True,
        'stock_files_modified': [],
        'wire_profile_id': 'raw_3920_2946_24',
        'display': 'ProRes RAW HQ 3888×2912 24 fps',
        'playback': 'preview/playback.mp4 HEVC Main 1024x768 24fps via x2v_prr_proxy_20261013b',
        'files': rows,
        'stage_protocol': 'local-verification/ssd_stage.py --execute; never replace a different hash in place',
        'preserve_on_uninstall': ['Takes clip.mov', 'preview/playback.mp4', 'product-complete.json'],
    }
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
    (OUT / 'README.md').write_text(
        '# X2D II ProRes RAW HQ product packet\n\n'
        'Installable via the existing SHA-pinned `/system` stage protocol. '
        'Does not flash boot or firmware partitions.\n\n'
        '1. Stage each `/system/bin/x2v_*` and `/system/lib64/libx2v_*.so` with `ssd_stage.py`.\n'
        '2. Install the persistent product GUI with '
        '`local-verification/prr_product_gui_install.py` '
        '(Drive / settings / catalog / playback). Not a bounded gui_session.\n'
        '3. Record with the isolated PRR packet; finalize with `x2v_prr_finalize_20261013b TAKE`.\n'
        '4. Playback is `preview/playback.mp4` (HEVC 1024×768) through VideoItem.\n'
    )
    print(json.dumps({'packet': str(OUT), 'files': len(rows)}, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
