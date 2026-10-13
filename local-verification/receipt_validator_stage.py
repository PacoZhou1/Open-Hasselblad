"""Stage reviewed standalone CPU receipt validator; no source/GUI/capture calls."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/native-rx15-receipt-validator'
assert hashlib.sha256((B/'freeze.json').read_bytes()).hexdigest()=='3fcaaa85158bc39ff0e1c4f1d4b57e26e3223c643e9700c74504a1497909f9e5'
review=R/'research/full-fov-pipeline/native-rx15-validator-independent-review/receipt.json'
audit=json.loads(review.read_text())
assert audit['decision']=='GO_READONLY_NATIVE_TEXT_PERFORMANCE_TEST_ONLY' and not audit['p1']
assert audit['artifact_sha256']=='f7a0e7b22b18e103595a0ec7c92da12e8ae73f915921d6da41377c9c38f9fc68'
ssd_stage.BINARY=B/'build/x2v_rx15_receipt_validate_20261012a'
ssd_stage.EXPECTED='f7a0e7b22b18e103595a0ec7c92da12e8ae73f915921d6da41377c9c38f9fc68'
ssd_stage.DEVICE_BINARY='/system/bin/x2v_rx15_receipt_validate_20261012a'
ssd_stage.RUN_PREFIX='receipt-validator-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
