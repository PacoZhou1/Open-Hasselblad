"""Measure delivered-frame cadence; does not assert physical exposure timing."""
import statistics

def measure(rx):
    n=rx['frames_written']
    assert n>=2
    ids=[rx[f'frame{i}_id'] for i in range(n)]
    t=[rx[f'frame{i}_admission_ns'] for i in range(n)]
    intervals=[(b-a)/1e6 for a,b in zip(t,t[1:])]
    writes=[(rx[f'frame{i}_write_end_ns']-rx[f'frame{i}_write_begin_ns'])/1e6 for i in range(n)]
    copies=[(rx[f'frame{i}_copy_end_ns']-rx[f'frame{i}_copy_begin_ns'])/1e6 for i in range(n)]
    fps=(n-1)*1e9/(t[-1]-t[0])
    contiguous=all(b==a+1 for a,b in zip(ids,ids[1:]))
    return {'frames':n,'delivered_fps':fps,'source_ids_contiguous':contiguous,
            'receiver_drops':rx['drop_full']+rx['drop_copy_busy'],
            'admission_interval_ms':{'min':min(intervals),'median':statistics.median(intervals),'max':max(intervals)},
            'copy_ms':{'median':statistics.median(copies),'max':max(copies)},
            'write_ms':{'median':statistics.median(writes),'max':max(writes)},
            'short_trial_24fps_delivery_pass':contiguous and rx['drop_full']==rx['drop_copy_busy']==0 and 23.76<=fps<=24.24,
            'physical_exposure_timing_verified':False,'long_duration_verified':False}
