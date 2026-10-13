"""Stage reviewed versioned diagnostic normal receiver; no camera launch."""
import hashlib
import json
from pathlib import Path
import ssd_stage

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT/'native-video/experimental/source-receiver-adapter/normal_diagnostic'
EXPECTED = '19e1ff7bf1e51ddd7d2bff0fa5c71e5a2b0bc914b79815a2fb331b5b47481348'


def main():
    contract = json.loads((BASE/'diagnostic-contract.json').read_text())
    if contract['sha256'] != EXPECTED:
        raise RuntimeError('Diagnostic receiver contract differs')
    for name, digest in contract['files'].items():
        if hashlib.sha256((BASE/name).read_bytes()).hexdigest() != digest:
            raise RuntimeError('Diagnostic receiver source differs: '+name)
    ssd_stage.BINARY = BASE/'build/libx2v_source_receiver_diag_v2.OFF.so'
    ssd_stage.EXPECTED = EXPECTED
    ssd_stage.DEVICE_BINARY = '/system/lib64/libx2v_source_receiver_20261012b.so'
    ssd_stage.RUN_PREFIX = 'source-rxdiag-stage'
    return ssd_stage.main()


if __name__ == '__main__':
    raise SystemExit(main())
