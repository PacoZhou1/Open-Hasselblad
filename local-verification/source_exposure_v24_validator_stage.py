from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'research/full-fov-pipeline/raw-banding-calibration-investigation/native-frame-metadata-audit/controlled-exposure-v24/receipt-validator/build/x2v_rx16_dng_receipt_validate_20261012v24'
ssd_stage.EXPECTED='414972a0a2f80d4bcf829452067d1941629af34908a4520e88dc3476f3d57d4c'
ssd_stage.DEVICE_BINARY='/system/bin/x2v_rx16_dng_receipt_validate_20261012v24'
ssd_stage.RUN_PREFIX='source-exposure-v24-validator-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
