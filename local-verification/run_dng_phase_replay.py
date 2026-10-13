"""Run six diagnostic replays retaining all pixel and fsync semantics."""
import run_dng_prepacked_replay as previous
from dng_phase_stage import EXPECTED,ssd_stage
runner=previous.runner
runner.EXPECTED=EXPECTED
runner.BINARY=ssd_stage.DEVICE_BINARY
runner.RUN_PREFIX='dng-phase-replay'
runner.RESULT_SCOPE='resident_dng_prepacked_phase_replay_benchmark'
runner.RESULT_VERSION=3
PHASES=('open_check','pwrite','fsync','close_publish','manifest_append')

def validate(d):
    times=previous.validate(d)
    for row in d['frames']:
        assert row['phase_clock_error']==0
        assert set(row['write_phases'])==set(PHASES)
        last={c:row['write'][c+'_begin_ns'] for c in ['wall','cpu']}
        for name in PHASES:
            p=row['write_phases'][name]
            assert p['valid']==p['attempted']==1
            for c in ['wall','cpu']:
                assert last[c]<=p[c+'_begin_ns']<=p[c+'_end_ns']<=row['write'][c+'_end_ns']
                assert p[c+'_ns']==p[c+'_end_ns']-p[c+'_begin_ns']
                last[c]=p[c+'_end_ns']
            assert p['cpu_wall_consistent']==int(p['cpu_ns']<=p['wall_ns'])
    for name in PHASES:
        times[name+'_ms']=[round(r['write_phases'][name]['wall_ns']/1e6,3) for r in d['frames']]
    return times

runner.validate=validate
if __name__=='__main__':raise SystemExit(runner.main())
