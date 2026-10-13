from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v23_named_hw_proxy/build/target-token/libx2v_mode21c24_named_hw_proxy_v23_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='dc6626309a7c6cab4502fc81e930ff82c8e58f59e970c3af10680cebfa9eb490'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_named_proxy_20261012a.so'
ssd_stage.RUN_PREFIX='source-proxy-v23-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
