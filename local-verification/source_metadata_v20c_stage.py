from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'research/full-fov-pipeline/raw-banding-calibration-investigation/native-frame-metadata-audit/rx18-callback-candidate-c/build/target-token/libx2v_rx18_native_metadata_candidate_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='bcf8cfa08d2264ec682ce3aaec0a8d52ef13de498ee991bdf4c964d612fab263'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_metadata_20261012c.so'
ssd_stage.RUN_PREFIX='source-metadata-v20c-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
