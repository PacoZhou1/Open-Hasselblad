"""Stage a reviewed, default-off ordinary-file DNG benchmark helper."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/resident-cinemadng-benchmark'
EXPECTED='5d0f631dbc3c53f2bd5036df93b81a07bbd0b673fe837959ee450e0913383894'
assert hashlib.sha256((B/'freeze.json').read_bytes()).hexdigest()=='21e93454538329b40a8da61899ac0677d2c7fae9c17f34e3c3aaec4f36f00cd1'
review=R/'research/full-fov-pipeline/resident-dng-benchmark-independent-review/receipt.json'
audit=json.loads(review.read_text())
assert audit['artifact_sha256']==EXPECTED and not audit['blocking_findings']
assert audit['decision']=='GO_source_actual_ELF_for_root_bounded_ordinary_file_benchmark'
ssd_stage.BINARY=B/'build/x2v_dng_replay_bench_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_dng_replay_bench_20261012a'
ssd_stage.RUN_PREFIX='dng-replay-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
