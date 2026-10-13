from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/grok-raw-proxy-g4/build/target-token/libx2v_mode21c24_native_rtp_grok4_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='f7926dfff6188e67ac9bb22d853329782295a22c16173149d593d6b163f0be16'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261013grok4.so'
ssd_stage.RUN_PREFIX='source-proxy-grok4-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
