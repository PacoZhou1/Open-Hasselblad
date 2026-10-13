"""Publish the reviewed normal-mode copy-on-init adapter; no service launch."""
import hashlib
import json
from pathlib import Path
import ssd_stage

BASE = Path(__file__).resolve().parents[1]/'research/full-fov-pipeline/source-adapter'
EXPECTED = '1b314a384bda2ee4caf6b8c6d60d8258e2e3b56c65d48778684043ac8bee0b70'
DESTINATION = '/system/lib64/libx2v_source_normal_clone_20261012a.so'


def main():
    receipt = json.loads((BASE/'build/receipt.json').read_text())
    if receipt['artifact_sha256'] != EXPECTED or receipt['target_mode_supported']:
        raise RuntimeError('Normal-clone identity differs')
    for name, digest in receipt['sources'].items():
        if hashlib.sha256((BASE/name).read_bytes()).hexdigest() != digest:
            raise RuntimeError('Reviewed source differs: '+name)
    ssd_stage.BINARY = BASE/'build/libx2v_source_normal_clone.so'
    ssd_stage.EXPECTED = EXPECTED
    ssd_stage.DEVICE_BINARY = DESTINATION
    ssd_stage.RUN_PREFIX = 'source-adapter-stage'
    return ssd_stage.main()


if __name__ == '__main__':
    raise SystemExit(main())
