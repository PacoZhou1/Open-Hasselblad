"""Stage reviewed diagnostic-only ordinary-file phase timer, default off."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/resident-cinemadng-prepacked-phase-benchmark'
EXPECTED='67ad6801a4682237e8e0a7b0b401287acf9fe3b9d063055023913e6fc2263fa6'
assert hashlib.sha256((B/'freeze.json').read_bytes()).hexdigest()=='1a5cd8163077f26df05b245898be5528e544eac0f1b82ec996120f0435f663c9'
ssd_stage.BINARY=B/'build/x2v_dng_phase_bench_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_dng_phase_bench_20261012a'
ssd_stage.RUN_PREFIX='dng-phase-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
