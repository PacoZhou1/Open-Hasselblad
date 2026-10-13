from pathlib import Path
import json,hashlib,shutil
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-receiver-adapter/receiver_v18_dng_isp_proxy'
p=P/'vendor_hook.c';s=p.read_text();needle=' struct x2v_clip_lease lease={0};';assert s.count(needle)==1
s=s.replace('static native_fn original;','static native_fn original;\nextern void x2v_color_observe(const char *,const char *,const void *);',1).replace(needle,' x2v_color_observe(name,port,frame);\n'+needle,1);p.write_text(s)
p=P/'control.c';s=p.read_text().replace('static struct clip_control clips[2];','extern void x2v_color_report(unsigned);\nstatic struct clip_control clips[2];',1);needle=' int published=ack(c,rc,expired,attempted,drain_rc);';assert s.count(needle)==1;s=s.replace(needle,' x2v_color_report(c->generation);\n'+needle,1);p.write_text(s)
p=P/'build.py';s=p.read_text().replace("'geometry.c']","'geometry.c','color_observer.c']",1).replace("allowed={'duss_hal_mem_get_flags'","allowed={'x2v_color_observe','duss_hal_mem_get_flags'",1);p.write_text(s)
for n in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:shutil.copy2(R/'native-video/experimental/raw-isp-geometry-candidate/config'/n,P/n)
p=P/'source-review.json';d=json.loads(p.read_text());d['scope']='RX18 offline dual RAW+ISP metadata observation; not H264, no execution approval';d['production_sources']['color_observer.c']=''
for k in ['production_sources','headers']:
 for n in d[k]:d[k][n]=hashlib.sha256((P/n).read_bytes()).hexdigest()
p.write_text(json.dumps(d,indent=2)+'\n')
