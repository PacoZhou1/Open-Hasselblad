"""Stage new default-off RX13 shared object only; never loads it or starts capture."""
from pathlib import Path
import json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/source-receiver-adapter/receiver_v13_mode21c24_ring240_direct'
f=json.loads((B/'freeze.json').read_text())
assert f['receipt_version']==13 and f['max_count']==240 and f['constructor_ms']==47000
ssd_stage.BINARY=B/f['artifact']
ssd_stage.EXPECTED=f['artifact_sha256']
ssd_stage.DEVICE_BINARY=f['system_path_candidate']
ssd_stage.RUN_PREFIX='source-c24-ring240-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
