"""Measure one-copy preparation and DNG writing separately; no new capture."""
import run_dng_replay_benchmark as runner

EXPECTED='ebcd791ef5c5a936f116e9e9af0026ce1464876feef546050c10251bd6180aa7'
runner.EXPECTED=EXPECTED
runner.BINARY='/system/bin/x2v_dng_prepacked_bench_20261012a'
runner.RUN_PREFIX='dng-prepacked-replay'
runner.RESULT_SCOPE='resident_dng_prepacked_replay_benchmark'
runner.RESULT_VERSION=2
runner.TIMING_KINDS=('prepare','write','finish','verify')
base_validate=runner.validate

def validate(d):
    times=base_validate(d)
    assert d['copy_provider_pinned']==d['copy_provider_kind']==1
    assert d['copy_provider_path']=='/system/lib64/libc.so'
    assert d['copy_provider_offset']==0x1e590
    assert d['copy_provider_address']==d['copy_provider_base']+0x1e590
    times['prepare_plus_write_ms']=[round((r['prepare']['wall_ns']+r['write']['wall_ns'])/1e6,3) for r in d['frames']]
    return times

runner.validate=validate
if __name__=='__main__':raise SystemExit(runner.main())
