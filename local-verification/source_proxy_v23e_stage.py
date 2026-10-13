from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23e_native_rtp/build/target-token/libx2v_mode21c24_native_rtp_v23e_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='70b53dd213da3b86b381352082fcc6f706ee91bb473c3628c6105db2fe1042a5'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261012e.so'
ssd_stage.RUN_PREFIX='source-proxy-v23e-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
