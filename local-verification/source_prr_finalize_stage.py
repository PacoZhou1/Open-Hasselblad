from pathlib import Path
import hashlib
import ssd_stage
R = Path(__file__).resolve().parents[1]
B = R / 'native-video/outputs/prr-product-release-20261013/system/bin/x2v_prr_finalize_20261013b'
ssd_stage.BINARY = B
ssd_stage.EXPECTED = hashlib.sha256(B.read_bytes()).hexdigest()
ssd_stage.DEVICE_BINARY = '/system/bin/x2v_prr_finalize_20261013c'
ssd_stage.RUN_PREFIX = 'source-prr-finalize-stage'
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
