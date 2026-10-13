from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23c_native_rtp/build/target-token/libx2v_mode21c24_native_rtp_v23c_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='470efb327a96b9a0a8f655fc2c0f0ac92d155100744ce941d15666b53132ba00'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261012c.so'
ssd_stage.RUN_PREFIX='source-proxy-v23c-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
