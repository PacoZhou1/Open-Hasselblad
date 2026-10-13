"""Stage only the frozen default-off one-frame receiver; no process launch."""
import hashlib
import json
from pathlib import Path
import ssd_stage

BASE = Path(__file__).resolve().parents[1]/'native-video/experimental/source-receiver-adapter'
EXPECTED = '84d8b943e729f90f96652c4334a3737ce1c0fdb1874a624dd38e67b776c19bda'
DESTINATION = '/system/lib64/libx2v_source_receiver_20261012a.so'


def main():
    frozen = json.loads((BASE/'normal-freeze.json').read_text())
    if frozen['artifact_sha256'] != EXPECTED:
        raise RuntimeError('Frozen normal receiver differs')
    for name, digest in frozen['files'].items():
        if hashlib.sha256((BASE/name).read_bytes()).hexdigest() != digest:
            raise RuntimeError('Frozen receiver file differs: '+name)
    ssd_stage.BINARY = BASE/'build/libx2v_source_receiver.OFF.so'
    ssd_stage.EXPECTED = EXPECTED
    ssd_stage.DEVICE_BINARY = DESTINATION
    ssd_stage.RUN_PREFIX = 'source-receiver-stage'
    return ssd_stage.main()


if __name__ == '__main__':
    raise SystemExit(main())
