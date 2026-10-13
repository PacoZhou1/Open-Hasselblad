"""Stage root-reviewed ordinary-file prepacked benchmark, default off."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/resident-cinemadng-prepacked-benchmark'
EXPECTED='ebcd791ef5c5a936f116e9e9af0026ce1464876feef546050c10251bd6180aa7'
audit=json.loads((R/'research/full-fov-pipeline/resident-dng-prepacked-root-review/receipt.json').read_text())
assert audit['decision']=='GO_CPU_ordinary_file_replay_only' and not audit['blocking_findings']
assert audit['benchmark_ELF_sha256']==EXPECTED
assert hashlib.sha256((B/'build/receipt.json').read_bytes()).hexdigest()==audit['build_receipt_sha256']
ssd_stage.BINARY=B/'build/x2v_dng_prepacked_bench_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_dng_prepacked_bench_20261012a'
ssd_stage.RUN_PREFIX='dng-prepacked-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
