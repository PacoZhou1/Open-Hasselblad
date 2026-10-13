"""Stage the reviewed readonly RX17 progress helper; no source transition."""
from pathlib import Path
import json
import ssd_stage
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'native-video/experimental/source-session-isolated-resident-two-v17-progress/reader'
EXPECTED='7057c7f54b4231c1187b78d7edb9d691a782b1a397790f9365680577775b033d'
r=json.loads((BASE/'host-test/report.json').read_text())
assert r['passed'] and r['count']==18
ssd_stage.BINARY=BASE/'build/x2v_rx17_progress_read_20261012a'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/bin/x2v_rx17_progress_read_20261012a'
ssd_stage.RUN_PREFIX='progress-reader-v17-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
