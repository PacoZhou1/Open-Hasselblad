"""Stage unique default-off RX15 artifact only; no load, boot hook or capture."""
from pathlib import Path
import json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/source-receiver-adapter/receiver_v15_resident_two_clip'
f=json.loads((B/'freeze.json').read_text())
assert f['receipt_version']==15 and f['max_count_per_clip']==240 and f['constructor_ms']==47000 and f['clip_generations']==[1,2]
ssd_stage.BINARY=B/f['artifact'];ssd_stage.EXPECTED=f['artifact_sha256'];ssd_stage.DEVICE_BINARY=f['system_path_candidate'];ssd_stage.RUN_PREFIX='source-resident2-v15-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
