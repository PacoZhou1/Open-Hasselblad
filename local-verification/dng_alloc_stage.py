"""Stage reviewed, default-off ordinary-file preallocation diagnostic."""
from pathlib import Path
import hashlib
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/resident-cinemadng-preallocation-benchmark'
EXPECTED='7116ef0a8d9fc14f293b1ac04cf9c1dd88e69d97ed4ffe852d019e8dae4d0fad'
assert hashlib.sha256((B/'freeze.json').read_bytes()).hexdigest()=='247a45498fcd14553f8eabbd1501e96f4ff658df07e4460cc4062a9b3f3e2f40'
ssd_stage.BINARY=B/'build/x2v_dng_alloc_bench_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_dng_alloc_bench_20261012a'
ssd_stage.RUN_PREFIX='dng-alloc-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
