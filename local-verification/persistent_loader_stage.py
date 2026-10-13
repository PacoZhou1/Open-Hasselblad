"""Pinned system-loader publication through the identical guarded SSD stager.

This chooses one reviewed source and a fresh X2V destination. It does not launch
the GUI or expose arbitrary command-line source/path overrides.
"""
from pathlib import Path
import hashlib
import json
import ssd_stage

BASE = Path(__file__).resolve().parents[1]/'native-video/experimental/persistent-session-system'
EXPECTED = 'f88756fb2445be43626e2ba18eedb3e54035773c25e7ffe15ea32c15d38143ce'


def main():
    frozen = json.loads((BASE/'freeze.json').read_text())
    if frozen['loader_sha256'] != EXPECTED:
        raise RuntimeError('Frozen loader identity differs')
    manifest = BASE/'source-manifest.json'
    if hashlib.sha256(manifest.read_bytes()).hexdigest() != frozen['source_manifest_sha256']:
        raise RuntimeError('Candidate freeze differs')
    for name, digest in json.loads(manifest.read_text())['files'].items():
        if hashlib.sha256((BASE/name).read_bytes()).hexdigest() != digest:
            raise RuntimeError('Frozen candidate file differs: '+name)
    ssd_stage.BINARY = BASE/'build/libx2v_gui_bootstrap_20261012_data.so'
    ssd_stage.EXPECTED = EXPECTED
    ssd_stage.DEVICE_BINARY = '/system/lib64/libx2v_gui_bootstrap_20261012_data.so'
    ssd_stage.RUN_PREFIX = 'persistent-loader-stage'
    return ssd_stage.main()


if __name__ == '__main__':
    raise SystemExit(main())
