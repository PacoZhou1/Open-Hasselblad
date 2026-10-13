"""Stage reviewed explicit-length ordinary-file diagnostic, default off."""
from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/resident-cinemadng-length-allocation-benchmark'
EXPECTED='f6b93037338e0cbbf7d76a64de159d839626c95550a86d5f159f79535a710f5a'
ssd_stage.BINARY=B/'build/x2v_dng_length_alloc_bench_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_dng_length_alloc_bench_20261012a'
ssd_stage.RUN_PREFIX='dng-length-alloc-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
