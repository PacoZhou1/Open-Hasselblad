"""Stage unique RX16 library only; no load, source transition, or boot hook."""
from pathlib import Path
import hashlib,json
import ssd_stage
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/source-receiver-adapter/receiver_v16_dng_prepacked'
EXPECTED='57f886f372d695098391b3f6175e95c7ceeb2d7a88a8b1cbf36662b61378ac5f'
P=R/'research/full-fov-pipeline/rx16-prepacked-independent-review/receipt.json'
assert hashlib.sha256(P.read_bytes()).hexdigest()=='4d1e6f91bd68155ecd895ee79bacfdcca2ab5c6cde4b1a86551c6894dbc5eda8'
ssd_stage.BINARY=B/'build/target-token/libx2v_mode21c24_dng_resident2_v16_arm.TOKEN_REQUIRED.so'
ssd_stage.EXPECTED=EXPECTED
ssd_stage.DEVICE_BINARY='/system/lib64/libx2v_mode21c24_dng_resident2_20261012a.so'
ssd_stage.RUN_PREFIX='source-dng-v16-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
