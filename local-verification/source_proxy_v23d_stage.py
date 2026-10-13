from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23d_native_rtp/build/target-token/libx2v_mode21c24_native_rtp_v23d_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='5c2648aabe10c8731c0a42b5d85e14bbd40279cf368e436ca89765f53c193a01'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261012d.so'
ssd_stage.RUN_PREFIX='source-proxy-v23d-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
