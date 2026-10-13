from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/native-prr-async-receipt-validator/build/x2v_prr_async_receipt_validate_20261013a'
ssd_stage.EXPECTED='d4ba780241e546bd00fc39127d8d818cebb98d34ea33c041eecce81ec6c3550f'
ssd_stage.DEVICE_BINARY='/system/bin/x2v_prr_async_receipt_validate_20261013a'
ssd_stage.RUN_PREFIX='source-prr-async-validator-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
