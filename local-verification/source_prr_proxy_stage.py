from pathlib import Path
import ssd_stage
R = Path(__file__).resolve().parents[1]
B = R / 'native-video/experimental/prores-raw-encoder/build'
ssd_stage.BINARY = B / 'x2v_prr_proxy'
ssd_stage.EXPECTED = 'e3cd74a20300e3a975f268b8b31dba963ba724084906532e95f9e5e269ce8ccb'
ssd_stage.DEVICE_BINARY = '/system/bin/x2v_prr_proxy_20261013b'
ssd_stage.RUN_PREFIX = 'source-prr-proxy-stage'
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
