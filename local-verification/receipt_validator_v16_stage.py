"""Stage RX16 pure CPU ACK parser; this neither loads nor arms a receiver."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/native-rx16-dng-receipt-validator'
EXPECTED='8657b1d900f11bd09b17521b893941684ba4c3c04081a16e4b043d5a7a7c69ed'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((B/'host-test/report.json').read_text())
assert report['passed'] and len(report['cases'])==31
assert sha(B/'validator.c')==report['validator_sha256']
assert sha(B/'schema.h')==report['schema_sha256']
receipt=json.loads((B/'build/receipt.json').read_text())
assert receipt['host_report_sha256']==sha(B/'host-test/report.json')
assert receipt['native_camera_calls'] is False
ssd_stage.BINARY=B/'build/x2v_rx16_dng_receipt_validate_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_rx16_dng_receipt_validate_20261012a'
ssd_stage.RUN_PREFIX='receipt-v16-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
