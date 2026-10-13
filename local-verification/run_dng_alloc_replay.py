"""Bounded ordinary-file A/B; no imaging mode or receiver change."""
import argparse,sys
import run_dng_prepacked_replay as previous
from dng_alloc_stage import EXPECTED,ssd_stage
runner=previous.runner
PHASES=('open_check','prepare_alloc','pwrite','fsync','close_publish','manifest_append')

def validate(d):
    times=previous.validate(d)
    assert d['allocation_mode']==MODE
    enabled=int(MODE=='keep_size')
    assert d['allocation_provider_pinned']==enabled
    if enabled:
        assert d['allocation_provider_path']=='/system/lib64/libc.so'
        assert d['allocation_provider_offset']==0x70610
        assert d['allocation_provider_address']==d['allocation_provider_base']+0x70610
    else:
        assert d['allocation_provider_path']==''
        assert d['allocation_provider_base']==d['allocation_provider_offset']==d['allocation_provider_address']==0
    for row in d['frames']:
        assert row['phase_clock_error']==row['allocation_rc']==row['allocation_unsupported']==0
        assert row['allocation_mode']==enabled
        assert set(row['write_phases'])==set(PHASES)
        last={c:row['write'][c+'_begin_ns'] for c in ('wall','cpu')}
        for name in PHASES:
            p=row['write_phases'][name]
            if name=='prepare_alloc' and not enabled:
                assert all(v==0 for v in p.values());continue
            assert p['valid']==p['attempted']==1
            for c in ('wall','cpu'):
                assert last[c]<=p[c+'_begin_ns']<=p[c+'_end_ns']<=row['write'][c+'_end_ns']
                assert p[c+'_ns']==p[c+'_end_ns']-p[c+'_begin_ns']
                last[c]=p[c+'_end_ns']
            assert p['cpu_wall_consistent']==int(p['cpu_ns']<=p['wall_ns'])
    for name in PHASES:
        times[name+'_ms']=[round(r['write_phases'][name]['wall_ns']/1e6,3) for r in d['frames']]
    return times

def main():
    global MODE
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--allocation-mode',choices=('none','keep_size'),required=True)
    args,remaining=ap.parse_known_args();MODE=args.allocation_mode
    sys.argv=[sys.argv[0]]+remaining
    runner.EXPECTED=EXPECTED
    runner.BINARY=ssd_stage.DEVICE_BINARY
    runner.RUN_PREFIX='dng-alloc-'+MODE
    runner.RESULT_SCOPE='resident_dng_preallocation_replay_benchmark'
    runner.RESULT_VERSION=4
    runner.EXTRA_ARGS='--allocation-mode '+MODE
    runner.validate=validate
    return runner.main()
if __name__=='__main__':raise SystemExit(main())
