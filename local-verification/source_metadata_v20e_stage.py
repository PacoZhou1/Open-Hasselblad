from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'research/full-fov-pipeline/raw-banding-calibration-investigation/native-frame-metadata-audit/rx18-callback-candidate-e/build/target-token/libx2v_rx18_native_metadata_candidate_e_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='c0f5e72ab9a8deb34595a15c305dfebd25bb75bc423a5e8a37f60086e1c7ecdb'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_metadata_20261012e.so'
ssd_stage.RUN_PREFIX='source-metadata-v20e-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
