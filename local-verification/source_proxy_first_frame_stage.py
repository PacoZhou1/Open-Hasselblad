"""Stage the first-frame helper; camera access requires the current TESTING owner."""
from pathlib import Path
import json
import os
import sys
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/raw-proxy-first-frame-proof-candidate/build/x2v_proxy_first_frame_aarch64'
ssd_stage.EXPECTED='96ffb5be5a297a61ccc4e3e0b6d037582739451ada5ba52765c6593d2041d184'
ssd_stage.DEVICE_BINARY='/system/bin/x2v_proxy_first_frame_20261013a'
ssd_stage.RUN_PREFIX='source-proxy-first-frame-stage'
if __name__=='__main__':
    if '--execute' in sys.argv[1:]:
        owner=os.environ.get('X2V_TESTING_OWNER')
        lock=json.loads((R/'local-verification/camera-testing.lock/owner.json').read_text())
        if not owner or lock.get('owner')!=owner or lock.get('state')!='TESTING':
            raise SystemExit('Claim camera first; set X2V_TESTING_OWNER to its current owner.')
    raise SystemExit(ssd_stage.main())
