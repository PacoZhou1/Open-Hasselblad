"""Descriptive uncalibrated RAW dark statistics, no pixel correction."""
from pathlib import Path
import json
import numpy as np
import tifffile
R=Path(__file__).resolve().parents[1]
run=R/'native-video/outputs/source-isolated-212801'
files=sorted((run/'dng-sample-readback').glob('*.dng'))
assert len(files)==2
results=[]
for path in files:
 a=tifffile.imread(path)
 assert a.shape==(2946,3920) and a.dtype==np.uint16
 r={'file':str(path),'shape':list(a.shape),'percentiles_u16':np.percentile(a,[0,1,50,99,100]).tolist(),'low4_all_zero':bool(np.all((a&15)==0)),'phases':[]}
 # Same even-origin centered window in both frames; no rendered RGB or CFA assumption.
 c=a[144:2802,200:3720].astype(np.float64)
 for yp in [0,1]:
  for xp in [0,1]:
   v=c[yp::2,xp::2];row=v.mean(axis=1)
   fold=[float(row[k::3].mean()) for k in range(3)]
   r['phases'].append({'x_parity':xp,'y_parity':yp,'mean_u16':float(v.mean()),'pixel_std_u16':float(v.std()),'fold3_mean_u16':fold,'fold3_peak_to_peak_u16':max(fold)-min(fold)})
 # y=1 mod6 xodd versus same column neighbouring same-parity rows.
 y=np.arange(151,2797,6);x=np.arange(201,3719,2)
 v=a[np.ix_(y,x)].astype(np.float64)
 ref=(a[np.ix_(y-2,x)].astype(np.float64)+a[np.ix_(y+2,x)].astype(np.float64))/2
 d=v-ref;r['class11_minus_same_phase_neighbors_u16']={'mean':float(d.mean()),'median':float(np.median(d)),'absolute_median':float(np.median(abs(d)))}
 results.append(r)
out={'condition':{'lens_cap':'user_confirmed','controlled_exposure':False,'native_exposure_metadata':'not_available_in_RX18','calibration_applied':False},'scope':'Two midpoint samples from actual 24fps dark clips. Descriptive only; cannot separate gain/offset or establish permanent calibration.','samples':results}
(run/'dark-pixel-analysis.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
