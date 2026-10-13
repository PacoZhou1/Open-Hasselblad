"""Render newly captured raw words for inspection; no source correction or interpolation."""
from pathlib import Path
import sys,json
import numpy as np,tifffile,rawpy
from PIL import Image
R=Path(__file__).resolve().parents[1];P=R/'native-video/outputs'/sys.argv[1];D=P/'wall-sample-readback';report=json.loads((D/'report.json').read_text());assert report['passed']
rec=report['frames'][0];source=R/rec['path'];a=np.frombuffer(source.read_bytes(),dtype='<u2').reshape(2946,3968)[:,:3920].copy()
reference=R/'native-video/experimental/mode21-diagnostic-dng/ASSUMED_RGGB_UNCALIBRATED_FULL_TRANSFER.dng'
tags=[(254,'I',1,0,False)]  # Explicit full-resolution RAW IFD, required by Apple readers.
with tifffile.TiffFile(reference) as tf:
 for k in [274,33421,33422,50706,50707,50708,50710,50711,50713,50714,50717,50829,50719,50720,50721,50778,50728,50936]:
  tag=tf.pages[0].tags[k];typ={1:'B',2:'s',3:'H',4:'I',5:'2I',10:'2i'}[int(tag.dtype)];tags.append((k,typ,tag.count,tag.value,False))
out=D/'WALL_UNCALIBRATED_ASSUMED_RGGB.dng';assert not out.exists()
with out.open('xb') as f:tifffile.imwrite(f,a,photometric=32803,metadata=None,extratags=tags,description=json.dumps({'scope':'Actual user-positioned wall scene; original samples, no correction/interpolation; CFA/levels/color reference remain unverified assumptions','source':rec}),software='X2V wall diagnostic')
with rawpy.imread(str(out)) as raw:
 assert np.array_equal(raw.raw_image,a)
 rgb=raw.postprocess(demosaic_algorithm=rawpy.DemosaicAlgorithm.LINEAR,use_camera_wb=False,use_auto_wb=True,no_auto_bright=False,output_bps=8)
im=Image.fromarray(rgb);im.save(D/'wall-auto-wb-preview-full.png');im.thumbnail((1200,900));im.save(D/'wall-auto-wb-preview.png')
roi=a[256:2680,256:3664].astype(float);metrics={}
for yy in range(2):
 for xx in range(2):
  phase=roi[yy::2,xx::2];means=phase.mean(axis=1);global_y=np.arange(256+yy,2680,2)
  classes={str(k):float(means[global_y%6==k].mean()) for k in range(yy,6,2)}
  # Adjacent same-parity triplets largely reject slowly varying wall illumination.
  trim=len(means)//3*3;triplets=means[:trim].reshape(-1,3);fold=(triplets-triplets.mean(axis=1,keepdims=True)).mean(axis=0)
  metrics[f'phase_y{yy}_x{xx}']={'raw_row_mod6_means':classes,'same_phase_triplet_zero_mean_fold_u16':fold.tolist(),'fold_peak_to_peak_u16':float(np.ptp(fold)),'phase_mean_u16':float(phase.mean()),'fraction_codes_near_reference_white':float(np.mean(phase>=64681))}
result={'run':P.name,'scene':'User states camera facing wall','source_frame':rec,'unchanged_DNG_samples_verified':True,'source_low4_bits_all_zero':bool(np.all((a&15)==0)),'preview':'Linear demosaic under assumed RGGB; software auto-WB and auto-brightness only for viewing. No interpolation repair. Not calibrated color/CFA proof.','phase_statistics':metrics,'limits':'Only one new controlled-scene observation; light flicker, exposure and mode-specific encoding still not identified'}
(D/'wall-analysis.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
