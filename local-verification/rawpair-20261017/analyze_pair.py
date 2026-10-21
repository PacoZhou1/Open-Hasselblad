"""Same-source A/B; never infer untreated pixels from a recorded MOV."""
from pathlib import Path
import argparse,ctypes as C,json,subprocess
import numpy as np,cv2
from PIL import Image
D=Path(__file__).resolve().parent;ROOT=D.parents[1];ENC=ROOT/'native-video/experimental/prores-raw-encoder'
class Geom(C.Structure):
 _fields_=[('src_stride_px',C.c_int),('src_rows',C.c_int),('x0',C.c_int),('y0',C.c_int),('width',C.c_int),('height',C.c_int),('dst_stride_px',C.c_int),('ob_x',(C.c_int*2)*2),('ob_y0',C.c_int),('ob_y1',C.c_int)]
class Pre(C.Structure):
 _fields_=[('g',Geom),('white',C.c_float),('ob_bias',C.c_float),('class_first',C.c_int),('class_rows',C.c_int),('class_cols',C.c_int),('hist',C.POINTER(C.c_uint32))]
def loadlib():
 so=D/'host_pre.dylib'
 subprocess.run(['cc','-O2','-dynamiclib','-I',str(ENC),str(ENC/'prr_pre.c'),'-o',str(so)],check=True)
 lib=C.CDLL(str(so));lib.prr_pre_init.argtypes=[C.POINTER(Pre),C.POINTER(Geom),C.c_float,C.c_float,C.c_int];lib.prr_pre_free.argtypes=[C.POINTER(Pre)]
 lib.prr_pre_rows_scalar.argtypes=[C.POINTER(Pre),C.POINTER(C.c_uint16),C.POINTER(C.c_uint16),C.c_float,C.c_int,C.c_int];return lib

def process(src,m,lib,banding):
 g=Geom(m['src_stride_px'],m['src_rows'],m['x0'],m['y0'],m['width'],m['height'],m['dst_stride_px'],((C.c_int*2)*2)((2,14),(3906,3918)),40,2940);p=Pre();assert lib.prr_pre_init(C.byref(p),C.byref(g),m['white'],0,banding)==0
 out=np.zeros((g.height,g.dst_stride_px),np.uint16)
 lib.prr_pre_rows_scalar(C.byref(p),src.ctypes.data_as(C.POINTER(C.c_uint16)),out.ctypes.data_as(C.POINTER(C.c_uint16)),m['black'],0,g.height);lib.prr_pre_free(C.byref(p));return out

def main():
 ap=argparse.ArgumentParser();ap.add_argument('pair',type=Path);args=ap.parse_args();folder=args.pair;m=json.loads((folder/'pair.json').read_text());assert m['error']==0
 for name,n in [('source.u16',m['source_bytes']),('preprocessed.u16',m['processed_bytes'])]:assert (folder/name).stat().st_size==n,(name,n)
 src=np.fromfile(folder/'source.u16',dtype='<u2').reshape(m['src_rows'],m['src_stride_px']);post=np.fromfile(folder/'preprocessed.u16',dtype='<u2').reshape(m['height'],m['dst_stride_px']);lib=loadlib();on=process(src,m,lib,1);off=process(src,m,lib,0);w=m['width']
 delta=on[:,:w].astype(np.int32)-post[:,:w].astype(np.int32);report={'exact_active_pixels_match':bool(np.array_equal(on[:,:w],post[:,:w])),'max_abs_difference':int(np.abs(delta).max()),'different_pixels':int(np.count_nonzero(delta)),'metadata':m}
 (folder/'verification.json').write_text(json.dumps(report,indent=2));assert report['exact_active_pixels_match'],report
 for name,img in [('untreated_linear',off),('production_linear',on)]:np.save(folder/(name+'.npy'),img[:,:w])
 M=np.array([[.714111626,.103235297,.1331231],[.275777608,.851573884,-.127351403],[.1016372,-.420500994,1.407693982]])
 XYZ=np.array([[3.2404542,-1.5371385,-.4985314],[-.969266,1.8760108,.041556],[.0556434,-.2040259,1.0572252]])
 mat=np.einsum('ij,jk->ik',XYZ,M)*np.array([m['wb'][0],1,m['wb'][1]])/65279
 for name,a in [('untreated',off),('production',on)]:
  rgb=cv2.cvtColor(a[:,:w].copy(),cv2.COLOR_BayerRGGB2RGB).astype(np.float32)-256
  rgb=np.clip(np.einsum('...c,kc->...k',rgb,mat),0,1);rgb=np.where(rgb<=.0031308,12.92*rgb,1.055*rgb**(1/2.4)-.055)
  Image.fromarray(np.uint8(np.clip(np.rint(rgb*255),0,255))).save(folder/(name+'.png'))
 print(json.dumps({k:v for k,v in report.items() if k!='metadata'}))
if __name__=='__main__':main()
