from pathlib import Path
import ssd_stage
R = Path(__file__).resolve().parents[1]
B = R / 'native-video/experimental/prores-raw-encoder/build/x2v_prr_play'
ssd_stage.BINARY = B
ssd_stage.EXPECTED = 'e9ad6f179edd9ae778a42e4d57e0fed4b9f09ba0b866e70d3f3d3fe0fbf6534f'
ssd_stage.DEVICE_BINARY = '/system/bin/x2v_prr_play_20261013a'
ssd_stage.RUN_PREFIX = 'source-prr-play-stage'
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
