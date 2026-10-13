from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23b_named_hw_proxy/build/target-token/libx2v_mode21c24_named_hw_proxy_v23b_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='769eea7e900d4cd2bbfacaa654d0c6c5e22de473f8e7a325a9301c99c7e2a1c3'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_named_proxy_20261012b.so'
ssd_stage.RUN_PREFIX='source-proxy-v23b-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
