from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/source-receiver-adapter/receiver_v18_dng_isp_proxy/build/target-token/libx2v_mode21c24_dng_isp_proxy_v18_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED='ea4b9b7ac93be2dd6872b2efd1a919450cf6e0a33b6edf07ae970d44efcb2a8c'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_dng_isp_20261012a.so'
ssd_stage.RUN_PREFIX='source-isp-v18-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
