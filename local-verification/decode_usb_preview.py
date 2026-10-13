"""Parse observed LIVE/H264 records and losslessly mux their measured timeline."""
import collections
import ctypes
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import time

root=Path(sys.argv[1]).resolve()
base=Path(__file__).resolve().parent
data=(root/'preview-usb.bin').read_bytes()
records=[]
offset=0
elementary=bytearray()
while offset+1024<=len(data):
    if data[offset:offset+4]!=b'LIVE':raise ValueError(f'Invalid magic at {offset}')
    header,total,w,h=struct.unpack_from('<4I',data,offset+8)
    n=struct.unpack_from('<I',data,offset+84)[0]
    if header!=1024 or total<header or n>total-header or data[offset+72:offset+76]!=b'H264':
        raise ValueError(f'Invalid header at {offset}')
    if offset+total>len(data):break
    payload=data[offset+header:offset+header+n]
    if not payload.startswith(b'\0\0\0\1'):raise ValueError('Not Annex B')
    elementary.extend(payload)
    records.append({'offset':offset,'size':total,'payload':n,'width':w,'height':h,
                    'timestamp_field':struct.unpack_from('<Q',data,offset+52)[0],
                    'frame_index':struct.unpack_from('<I',data,offset+60)[0],
                    'nal_type':payload[4]&31})
    offset+=total
raw=root/'preview.h264'
with raw.open('xb') as f:f.write(elementary)
output=root/'x2d2-real-usb-preview.mp4'
if output.exists() or Path(str(output)+'.partial').exists():raise ValueError('Output exists')
lib=ctypes.CDLL(str(base/'usb-preview/libx2v_host.dylib'))
lib.x2v_begin.argtypes=[ctypes.c_char_p,ctypes.c_uint,ctypes.c_uint,ctypes.c_uint]
lib.x2v_feed.argtypes=[ctypes.c_void_p,ctypes.c_uint,ctypes.c_uint64]
class Status(ctypes.Structure):
    _fields_=[(k,ctypes.c_uint64) for k in ['state','error','packets','frames','bytes','ignored','queue_bytes','width','height','duration_ticks','timestamp_source','max_queue_bytes']]
if lib.x2v_begin(str(output).encode(),50,1,20):raise RuntimeError('Begin failed')
try:
    for r in records:
        payload=data[r['offset']+1024:r['offset']+1024+r['payload']]
        buf=ctypes.create_string_buffer(payload)
        code=lib.x2v_feed(buf,len(payload),r['timestamp_field']*1000 or 1)
        if code:raise RuntimeError(f'Feed failed: {code}')
        time.sleep(.005)
    code=lib.x2v_stop()
    if code:raise RuntimeError(f'Stop failed: {code}')
finally:lib.x2v_stop()
s=Status();lib.x2v_status(ctypes.byref(s))
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(output)]))
subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(output),'-f','null','-'],check=True,capture_output=True)
def hashes(p):
    text=subprocess.check_output(['ffmpeg','-v','error','-i',str(p),'-f','framemd5','-'],text=True)
    return [l.split(',')[-1].strip() for l in text.splitlines() if not l.startswith('#')]
match=hashes(raw)==hashes(output)
if not match:raise RuntimeError('Decoded frames changed')
frames=[r for r in records if r['nal_type'] in (1,5)]
report={'scope':'Real X2D II 1.3.16.2 stock USB preview, saved on Mac; not in-camera recording',
        'synthetic':False,'timestamp_basis':'USB byte-52 field interpreted as microseconds from observed 20/40ms deltas; not vendor documented',
        'records':records,'trailing_bytes':len(data)-offset,'full_decode_passed':True,'frame_hashes_match':match,
        'recorder':{k:getattr(s,k) for k,_ in s._fields_},'ffprobe':probe,
        'timestamp_delta_counts':dict(collections.Counter(b['timestamp_field']-a['timestamp_field'] for a,b in zip(frames,frames[1:]))),
        'frame_index_delta_counts':dict(collections.Counter(b['frame_index']-a['frame_index'] for a,b in zip(frames,frames[1:]))),
        'sha256':hashlib.sha256(output.read_bytes()).hexdigest()}
(root/'decode-report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'file':str(output),'frames':s.frames,'duration':probe['format']['duration'],'size':probe['format']['size'],
                  'bitrate':probe['format']['bit_rate'],'avg_frame_rate':probe['streams'][0]['avg_frame_rate'],
                  'trailing_bytes':len(data)-offset,'frame_hashes_match':match,'timestamp_delta_counts':report['timestamp_delta_counts']},indent=2))
