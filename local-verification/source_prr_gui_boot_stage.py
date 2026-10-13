from pathlib import Path
import hashlib
import ssd_stage
R = Path(__file__).resolve().parents[1]
B = R / 'native-video/experimental/prr-product-gui/x2v_prr_gui_boot.sh'
ssd_stage.BINARY = B
ssd_stage.EXPECTED = hashlib.sha256(B.read_bytes()).hexdigest()
ssd_stage.DEVICE_BINARY = '/system/bin/x2v_prr_gui_boot_20261013d'
ssd_stage.RUN_PREFIX = 'source-prr-gui-boot-stage'
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
