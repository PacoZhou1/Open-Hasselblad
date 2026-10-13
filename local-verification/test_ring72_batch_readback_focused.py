#!/usr/bin/env python3
"""Changed four-frame transport mocks only; no camera or real factory/ADB."""
from pathlib import Path
import hashlib,json,re,sys,tempfile,types,shutil
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1];SOURCE=ROOT/'local-verification/isolated_ring72_v12_batch_readback.py';BASE=ROOT/'local-verification/isolated_ring72_v12_c24_readback.py';AUDIT=ROOT/'native-video/experimental/ring72-batch-readback-review';FRAME=23379456;MODE='isolated-target-ring72-v12-c24'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
def main():
 AUDIT.mkdir(exist_ok=True);old={n:sys.modules.get(n) for n in ['factory_session','gui_session']}
 def forbidden(*a,**k):raise AssertionError('Real device access forbidden')
 sys.modules['factory_session']=types.SimpleNamespace(connect=forbidden);sys.modules['gui_session']=types.SimpleNamespace(adb=forbidden);cases=[]
 try:
  for case in ['success_four_plus_tail','quality0','short_transfer','corrupt_transfer','native_space_low','source_inode_wrong','chunk_nlink2','chunk_replaced_after_transfer','whole_sha_wrong','final_exists']:
   with tempfile.TemporaryDirectory(prefix='batch-',dir=AUDIT) as td:
    r=Path(td);run='source-isolated-123456';out=r/'native-video/outputs'/run;d=out/'device-run';d.mkdir(parents=True);packet=r/'packet';packet.mkdir();(packet/'ack_contract.py').write_text('# transport mock only\n');(packet/'freeze.json').write_text(json.dumps(dict(mode=MODE,ack_contract_sha256=sha(packet/'ack_contract.py'))));hold=r/'hold.json';hold.write_text(json.dumps(dict(released_modes=[MODE])))
    (out/'report.json').write_text(json.dumps(dict(mode=MODE,run_id=run,passed=True,body_rc='0',recovery_rc='0',locks_absent=True)))
    for n in ['restored','manual.reaped']:(d/n).touch()
    (d/'receiver.receipt').write_text('{"transport_mock":true}\n')
    raw=r/'source.raw'
    with raw.open('wb') as f:
     f.truncate(5*FRAME)
     for i in range(5):f.seek(i*FRAME);f.write(bytes([65+i]));f.seek((i+1)*FRAME-1);f.write(bytes([90-i]))
    source_sha=sha(raw);st=raw.stat();source_token=f'{st.st_dev}:{st.st_ino}:1:{5*FRAME}'
    (d/'raw.inode').write_text('0:0' if case=='source_inode_wrong' else f'{st.st_dev}:{st.st_ino}')
    (d/'receiver.raw.sha256').write_text(('0'*64 if case=='whole_sha_wrong' else source_sha)+' raw.partial\n');(d/'receiver.raw.bytes').write_text(str(5*FRAME))
    contract=dict(total_bytes=5*FRAME,count=5,frames=[dict(index=i,id=100+i,timestamp_native=10000+i) for i in range(5)],stop_reason=1,cpu_admission_intervals_ns=[1]*4,cpu_write_completion_intervals_ns=[1]*4,native_timestamp_deltas=[1]*4,copy_provider={},cpu_copy_wall_ns=[2]*5,cpu_copy_thread_ns=[1]*5,cpu_wall_quality_false_frame_indices=[],capture_success_verified=True,configuration_applied_verified=True,expected_mem_flags=17,writer_provider={},writer_flags_before=131074,writer_flags_active=196610,cpu_write_wall_ns=[2]*5,cpu_write_thread_ns=[3 if case=='quality0' else 1]*5,writer_cpu_wall_quality_false_frame_indices=list(range(5)) if case=='quality0' else [],writer_fsync_wall_ns=2,writer_fsync_thread_ns=1,writer_fsync_cpu_wall_consistent=1,direct_writer_verified=True)
    native={};deleted=[];copies=[];transfers=[];calls=[];replaced=False
    bulk='/mnt/media_rw/ssd/x2v-source-20261012/runs/'+run+'/raw.partial'
    def token(p):
     st=p.stat();return f'{st.st_dev}:{st.st_ino}:{st.st_nlink}:{st.st_size}'
    class Factory:
     def __enter__(self):return self
     def __exit__(self,*a):return False
     def factory_shell(self,cmd,capture_ms):
      calls.append(('factory',cmd))
      if cmd.startswith('df '):return 'dev 499656 0 '+('32768' if case=='native_space_low' else '449000')+' 0% /data\n'
      if 'stat -c' in cmd:
       assert cmd.startswith('cd /mnt/media_rw/ssd/') and 'raw.partial' in cmd and len(cmd.encode())<=231
       return source_token+'\n'
      assert len(cmd.encode())<=231 and 'set -C;toybox dd' in cmd and 'bs=7936' in cmd
      first=int(re.search(r'skip=(\d+)',cmd)[1])//2946;n=int(re.search(r'count=(\d+)',cmd)[1])//2946;assert n in [4,1];assert first in [0,4]
      name=cmd.split(' >')[1].removesuffix(')');remote='/data/x2v-source-20261012/runs/'+run+'/'+name;p=r/name;assert remote not in native
      with raw.open('rb') as src,p.open('xb') as dest:
       src.seek(first*FRAME);left=n*FRAME
       while left:b=src.read(min(left,1024*1024));assert b;dest.write(b);left-=len(b)
      native[remote]=p;copies.append((first,n))
      if case=='chunk_nlink2':__import__('os').link(p,r/'extra-hardlink')
      return ''
    def adb(*args,**kwargs):
     cmd=args[1];calls.append(('adb',cmd))
     if cmd.endswith('&& echo CLEAR'):return 'CLEAR\n'
     if cmd.startswith('getprop'):return 'running\n'
     if cmd.startswith('sha256sum '):return sha(native[cmd.split()[1]])+' temp\n'
     match=re.search(r'stat -c "%d:%i:%h:%s" ([^ )]+)',cmd);assert match,cmd;remote=match[1]
     assert remote!=bulk, 'ADB cannot inspect native SSD source'
     p=native[remote];tok=token(p)
     if '&& rm ' in cmd:
      assert cmd.split(' = ')[1].split(' && rm')[0]==tok;p.unlink();del native[remote];deleted.append(remote);return ''
     return tok+'\n'
    def transfer(cmd,stdout,stderr,timeout):
     nonlocal replaced
     assert cmd[:5]==['adb','-s','123456789ABCDEF','exec-out','cat'] and timeout==90
     p=native[cmd[5]];want=p.stat().st_size-(1 if case=='short_transfer' else 0);sent=0
     with p.open('rb') as src:
      while sent<want:
       b=src.read(min(want-sent,1024*1024));assert b
       if case=='corrupt_transfer' and sent==0:b=bytes([b[0]^1])+b[1:]
       stdout.write(b);sent+=len(b)
     transfers.append(sent)
     if case=='chunk_replaced_after_transfer':
      oldp=r/'oldchunk';p.rename(oldp);shutil.copyfile(oldp,p);replaced=True
     return types.SimpleNamespace(returncode=0,stderr=b'')
    m=types.ModuleType('batch_mock');m.__file__=str(SOURCE);exec(compile(SOURCE.read_text(),str(SOURCE),'exec'),m.__dict__);m.ROOT,m.PACKET,m.HOLD=r,packet,hold;m.adb,m.connect,m.validate=adb,Factory,lambda rx:contract;m.subprocess=types.SimpleNamespace(run=transfer,PIPE=-1)
    final=out/'raw-ring72-3920x2946-stride7936.bin'
    if case=='final_exists':final.write_bytes(b'prior')
    with patch.object(sys,'argv',['runner','--run',run,'--execute']),patch.object(m.shutil,'disk_usage',lambda p:types.SimpleNamespace(free=10**10)):
     rc=m.main()
    res=json.loads((out/'ring72-readback-report.json').read_text());good=case in ['success_four_plus_tail','quality0'];assert res['passed']==good and rc==(0 if good else 1);assert sha(raw)==source_sha
    if good:
     assert sha(final)==source_sha and copies==[(0,4),(4,1)] and transfers==[4*FRAME,FRAME] and len(deleted)==2 and not native
     assert res['frame_hash_origin']=='host-derived' and len(res['transfer_chunks'])==2
     with raw.open('rb') as src:
      for f in res['frames']:
       h=hashlib.sha256();left=FRAME
       while left:b=src.read(min(left,1024*1024));h.update(b);left-=len(b)
       assert f['sha256']==h.hexdigest() and f['full_chunk_verified']
     assert bool(res['writer_cpu_wall_quality_false_frame_indices'])==(case=='quality0')
    else:
     if case!='final_exists':assert not final.exists()
     else:assert final.read_bytes()==b'prior'
     if case in ['short_transfer','corrupt_transfer','chunk_nlink2','chunk_replaced_after_transfer']:
      assert native and not deleted and res['retained_native_temp']
    cases.append(dict(name=case,passed=True,factory_dd_calls=len(copies),transfer_count=len(transfers)))
 finally:
  for n,v in old.items():
   if v is None:sys.modules.pop(n,None)
   else:sys.modules[n]=v
 report=dict(scope='Offline changed batch transport mocks only; parsed protocol fixture mocked5frames, originalACK72 validator unchanged; no device',passed=True,cases=cases,count=len(cases),files={str(p.relative_to(ROOT)):sha(p) for p in [SOURCE,BASE,Path(__file__)]},chunk_bytes=4*FRAME,actual_frame_bytes=FRAME)
 (AUDIT/'focused-report.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',len(cases))
if __name__=='__main__':main()
