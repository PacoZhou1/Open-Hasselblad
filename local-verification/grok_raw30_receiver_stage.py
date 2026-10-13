from pathlib import Path
import ssd_stage
ssd_stage.BINARY=Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/grok-raw30-async/build/target-token/libx2v_mode21d18_async30_arm.TOKEN_REQUIRED.so')
ssd_stage.EXPECTED='ab3cd35428373826d0e304b86b7c84422c136241321e7ea55a28a77c89659103'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21d18_async30_20261013a.so'
ssd_stage.RUN_PREFIX='source-grok-raw30-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
