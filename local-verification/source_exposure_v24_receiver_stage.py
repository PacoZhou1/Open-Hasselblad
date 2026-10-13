from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'research/full-fov-pipeline/raw-banding-calibration-investigation/native-frame-metadata-audit/controlled-exposure-v24/receiver-candidate/build/target-token/libx2v_rx18_metadata_exposure_v24_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='968700334502463073bb61bcf0a43b01e1f65bd2918921c6b4c23e37111e5080'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_exposure_20261012v24.so'
ssd_stage.RUN_PREFIX='source-exposure-v24-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
