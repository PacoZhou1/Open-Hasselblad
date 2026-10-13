from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/native-rx25-async-receipt-validator'
ssd_stage.BINARY=B/'build/x2v_rx25_async_receipt_validate_20261013a'
ssd_stage.EXPECTED='457052e42ab2e41aa12e1046cdda58c5a8a086b37d27bf8facd95dc09d5e6e8b'
ssd_stage.DEVICE_BINARY='/system/bin/x2v_rx25_async_receipt_validate_20261013a'
ssd_stage.RUN_PREFIX='source-grok-raw30d-validator-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
