"""Stage reviewed RX17 under a new name; no load or startup hook."""
from pathlib import Path
import hashlib
import json
import ssd_stage

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'native-video/experimental/source-receiver-adapter/receiver_v17_dng_progress'
EXPECTED = 'd77cdb42e9353fa28e80ef2d564d13f3c8e460ac37bf2008d240c69634973fd9'
checkpoint = BASE / 'review-checkpoint.json'
assert hashlib.sha256(checkpoint.read_bytes()).hexdigest() == 'ed7a0d671d247125b31afc8879538712718f631e6b47ed030c4435132b60750d'
host = json.loads((BASE / 'host-test/report.json').read_text())
assert host['passed'] and len(host['cases']) == 10
ssd_stage.BINARY = BASE / 'build/target-token/libx2v_mode21c24_dng_progress_v17_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED = EXPECTED
ssd_stage.DEVICE_BINARY = '/system/lib64/libx2v_mode21c24_dng_progress_20261012a.so'
ssd_stage.RUN_PREFIX = 'source-progress-v17-stage'

# Root read full new live_progress/progress_wire and RX16 control/receiver/hook
# deltas: advisory-only worker writes, same frame callback and write durability,
# min11 duplicates preserve original FD10 placeholder, strict PID/start binding,
# unchanged terminal ACK16 and native recovery responsibilities. Stage only;
# source execution requires a separate reviewed progress-aware controller.
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
