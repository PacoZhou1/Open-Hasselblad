"""Measure explicit grow-to-length allocation, including it in write time."""
import run_dng_prepacked_replay as previous
from dng_length_alloc_stage import EXPECTED,ssd_stage
runner=previous.runner
runner.EXPECTED=EXPECTED
runner.BINARY=ssd_stage.DEVICE_BINARY
runner.RUN_PREFIX='dng-length-alloc'
runner.RESULT_SCOPE='resident_dng_length_allocation_replay_benchmark'
runner.RESULT_VERSION=5
runner.EXTRA_ARGS='--allocation-mode mode0_length'
PHASES=('open_check','prepare_alloc','pwrite','fsync','close_publish','manifest_append')

def validate(d):
    times=previous.validate(d)
    assert d['allocation_mode']=='mode0_length'
    assert d['allocation_provider_pinned']==1
    assert d['allocation_provider_path']=='/system/lib64/libc.so'
    assert d['allocation_provider_offset']==0x70610
    assert d['allocation_provider_address']==d['allocation_provider_base']+0x70610
    for row in d['frames']:
        assert row['allocation_enabled']==1 and row['allocation_syscall_mode']==0
        assert row['allocation_size_observed']==1
        assert row['allocation_observed_size']==23100928
        assert row['phase_clock_error']==row['allocation_rc']==row['allocation_unsupported']==0
        assert set(row['write_phases'])==set(PHASES)
        last={c:row['write'][c+'_begin_ns'] for c in ('wall','cpu')}
        for name in PHASES:
            p=row['write_phases'][name]
            assert p['valid']==p['attempted']==1
            for c in ('wall','cpu'):
                assert last[c]<=p[c+'_begin_ns']<=p[c+'_end_ns']<=row['write'][c+'_end_ns']
                assert p[c+'_ns']==p[c+'_end_ns']-p[c+'_begin_ns']
                last[c]=p[c+'_end_ns']
            assert p['cpu_wall_consistent']==int(p['cpu_ns']<=p['wall_ns'])
    for name in PHASES:
        times[name+'_ms']=[round(r['write_phases'][name]['wall_ns']/1e6,3) for r in d['frames']]
    return times

runner.validate=validate
if __name__=='__main__':raise SystemExit(runner.main())
