from pathlib import Path
import ssd_stage
ssd_stage.BINARY=Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/rx-prr-async/build/target-token/libx2v_mode21c24_prr_async_v1.TOKEN_REQUIRED.so')
ssd_stage.EXPECTED='8d77747222d106999b15def2edc608bfcaf33431c4a71e7c69effb928b31ae59'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_prr_async_20261013a.so'
ssd_stage.RUN_PREFIX='source-prr-async-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
