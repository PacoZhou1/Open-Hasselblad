"""Compare equal native lifecycle boundaries; distinguish finite capture and I/O."""
from pathlib import Path
import argparse,json,re,statistics
R=Path(__file__).resolve().parents[1]
def events(run):
 p=R/'native-video/outputs'/run/'device-run/events.log'
 return [(int(line.split(' ',1)[0]),line.split(' ',1)[1]) for line in p.read_text().splitlines()]
def boundaries(e):
 def first(s):return next(t for t,x in e if s in x)
 frames=[t for t,x in e if x.startswith('FRAMES ')];assert len(frames)==2
 return {'guard_sealed':first('GUARD_SEALED_'),'normal_clone_frames':frames[0],'armed':first('RECEIVER_EXPLICIT_ARM_'),'payload_confirmed':first('RECEIVER_FRAME_CONFIRMED'),'reaped':first('PHASE smoke_complete'),'restored':first('NORMAL_STOCK_RESTORED')}
def segments(b):
 keys=list(b);return {keys[i-1]+'__'+keys[i]:b[keys[i]]-b[keys[i-1]] for i in range(1,len(keys))}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--run',required=True);a=ap.parse_args();out=R/'native-video/outputs'/a.run
 old=boundaries(events('source-isolated-094826'));new=boundaries(events(a.run));rx=json.loads((out/'device-run/receiver.receipt').read_text())
 n=rx['frames_written'];times=[rx[f'frame{i}_admission_ns'] for i in range(n)]
 d={'scope':'Native lifecycle timestamps are integer seconds; comparison includes larger payload and strict72-frame validation','baseline_run':'source-isolated-094826','current_run':a.run,'baseline_seconds':old['restored']-old['guard_sealed'],'current_seconds':new['restored']-new['guard_sealed'],'baseline_segments':segments(old),'current_segments':segments(new),'frames':n,'raw_bytes':rx['bytes_written'],'admission_interval_fps':(n-1)*1e9/(times[-1]-times[0]),'arm_to_writer_done_ms':(rx['writer_done_ns']-rx['arm_ns'])/1e6,'drop_full':rx['drop_full'],'drop_copy_busy':rx['drop_copy_busy'],'frame_ids':[rx['frame0_id'],rx[f'frame{n-1}_id']],'continuous_ids':all(rx[f'frame{i+1}_id']==rx[f'frame{i}_id']+1 for i in range(n-1)),'unique_readback_not_yet_verified':True}
 d['reduction_percent']=100*(d['baseline_seconds']-d['current_seconds'])/d['baseline_seconds']
 d['control_before_arm_seconds']={'before':old['armed']-old['guard_sealed'],'after':new['armed']-new['guard_sealed']}
 d['control_after_payload_seconds']={'before':old['restored']-old['payload_confirmed'],'after':new['restored']-new['payload_confirmed']}
 (out/'latency-comparison.json').write_text(json.dumps(d,indent=2)+'\n');print(json.dumps(d,indent=2))
if __name__=='__main__':main()
