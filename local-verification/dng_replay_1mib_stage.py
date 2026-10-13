"""Stage the one-delta 1MiB ordinary-file replay helper, default off."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/resident-cinemadng-benchmark-1mib'
EXPECTED='52f00714c59d7a258823a3b3bca5c040c47c00dc5ff35c28911847ebe042caf6'
assert hashlib.sha256((B/'freeze.json').read_bytes()).hexdigest()=='2fa94aea3b11078614b13e7101717319abf84fa7c3660e3c2d3759c310c4e2cb'
audit=json.loads((R/'research/full-fov-pipeline/resident-dng-1mib-independent-review/receipt.json').read_text())
assert audit['decision']=='GO_one_delta_CPU_ordinary_file_benchmark_source_and_actual_ELF'
assert audit['benchmark_ELF_sha256']==EXPECTED and not audit['blocking_findings']
ssd_stage.BINARY=B/'build/x2v_dng_replay_1mib_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_dng_replay_1mib_20261012a'
ssd_stage.RUN_PREFIX='dng-1mib-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
