from pathlib import Path
import ssd_stage
R = Path(__file__).resolve().parents[1]
B = R / 'native-video/experimental/prores-raw-encoder/build'
ssd_stage.BINARY = B / 'libx2v_inotify_guard.so'
ssd_stage.EXPECTED = '3931c6a280cfb372546138ead7a5cc99a3b2591645187e952a4ee5685049887e'
ssd_stage.DEVICE_BINARY = '/system/lib64/libx2v_inotify_guard.so'
ssd_stage.RUN_PREFIX = 'source-prr-guard-stage'
if __name__ == '__main__':
    raise SystemExit(ssd_stage.main())
