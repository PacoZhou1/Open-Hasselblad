from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/grok-raw-proxy-g2/build/target-token/libx2v_mode21c24_native_rtp_grok2_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='03c9e14c45307773691850c28c60308a4d410d99a13fc437a6cb5b196892cf1f'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261013grok2.so'
ssd_stage.RUN_PREFIX='source-proxy-grok2-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
