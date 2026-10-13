from pathlib import Path
import ssd_stage
R = Path(__file__).resolve().parents[1]
B = R / 'native-video/experimental/prores-raw-encoder/build'
ssd_stage.BINARY = B / 'x2v_prr_dec'
ssd_stage.EXPECTED = '5c389c9c32990db0f3f99b3183beb1a5830e6a4f782ce4a99fa1c6748a9f3337'
ssd_stage.DEVICE_BINARY = '/system/bin/x2v_prr_dec_20261013a'
ssd_stage.RUN_PREFIX = 'source-prr-dec-stage'
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
