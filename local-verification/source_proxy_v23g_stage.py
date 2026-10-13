from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23g_native_rtp/build/target-token/libx2v_mode21c24_native_rtp_v23g_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='0376e680c1f05826e0ffc6e8709b63eb5846ff3f81d44c76bf6d590f35f7f74f'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261013g.so'
ssd_stage.RUN_PREFIX='source-proxy-v23g-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
