"""Stage frozen normal graph artifacts only; never enable a sensor mode."""
import hashlib
import json
from pathlib import Path
import sys

import ssd_stage
from gui_session import adb

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT/'native-video/experimental/source-receiver-adapter'
HB = ROOT/'research/full-fov-pipeline/source-adapter'
ARTIFACT = 'build/libx2v_raw_graph.OFF.so'
EXPECTED = '15200fbe3cf22c60a8bd5f9ddeb61c79dfaf01c0276759a8f44023303e4761db'
DESTINATION = '/system/lib64/libx2v_raw_graph_normal_20261012a.so'
PREFIX = 'source-graph-stage'


def main():
    freeze = json.loads((BASE/'graph-normal-freeze.json').read_text())
    for folder, key in [(BASE, 'files'), (HB, 'HB_builder_sources')]:
        for name, digest in freeze[key].items():
            if hashlib.sha256((folder/name).read_bytes()).hexdigest() != digest:
                raise RuntimeError('Frozen source changed: '+name)
    item = next(x for x in freeze['artifacts'] if x['file'] == ARTIFACT)
    if item['sha256'] != EXPECTED:
        raise RuntimeError('Frozen artifact changed')
    if '--execute' in sys.argv:
        for name, digest in freeze['providers'].items():
            if adb('shell', 'sha256sum /system/'+name).split()[0] != digest:
                raise RuntimeError('Device provider differs: '+name)
        path = '/system/lib64/camera/plugins/hal/libdcam_cam_info_e2_hb722.so'
        if adb('shell', 'sha256sum '+path).split()[0] != freeze['HAL_plugin_required_readback_SHA']:
            raise RuntimeError('Device HAL plugin differs')
    ssd_stage.BINARY = BASE/ARTIFACT
    ssd_stage.EXPECTED = EXPECTED
    ssd_stage.DEVICE_BINARY = DESTINATION
    ssd_stage.RUN_PREFIX = PREFIX
    return ssd_stage.main()


if __name__ == '__main__':
    raise SystemExit(main())
