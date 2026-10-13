from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23f_native_rtp/build/target-token/libx2v_mode21c24_native_rtp_v23f_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='af58a1d599bb744c8ff50500bd9ea41da39fb693726f8b6904b8f806bc787466'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_native_rtp_20261013f.so'
ssd_stage.RUN_PREFIX='source-proxy-v23f-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
