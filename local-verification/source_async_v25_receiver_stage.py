from pathlib import Path
import ssd_stage
ssd_stage.BINARY=Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/rx25_async_writer/build/target-token/libx2v_rx25_async_writer_metadata_e_arm.TOKEN_REQUIRED.so')
ssd_stage.EXPECTED='fe3f59496989a36dcf95444413617d49c62ec0852fc8bce0652da29a942811e2'
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_async_20261013a.so'
ssd_stage.RUN_PREFIX='source-async-v25-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
