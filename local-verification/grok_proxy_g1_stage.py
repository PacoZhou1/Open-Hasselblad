from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/grok-raw-proxy-g/build/target-token/libx2v_mode21c24_native_rtp_grok1_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='725819b46288e29c4e267475d552837779bd5d0be6dccbfbf4d3d3e6c237af28'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261013grok1.so'
ssd_stage.RUN_PREFIX='source-proxy-grok1-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
