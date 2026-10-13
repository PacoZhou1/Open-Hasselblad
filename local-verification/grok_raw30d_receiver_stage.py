from pathlib import Path
import ssd_stage
ssd_stage.BINARY=Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/grok-raw30b-async/build/target-token/libx2v_mode21d18_async30_arm.TOKEN_REQUIRED.so')
ssd_stage.EXPECTED='87381ceec2cdbf45e7c5a34d0e0dc30195ec178561ec3cb1bce56791468019fa'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21d18_async30_20261013b.so'
ssd_stage.RUN_PREFIX='source-grok-raw30d-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
