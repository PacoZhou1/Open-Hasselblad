"""Private two-clip RAW capture with Grok asynchronous DNG writer; no device I/O."""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

R = Path(__file__).resolve().parents[1]
OLD = R / 'native-video/experimental/source-session-isolated-two-v20e-metadata'
NEW = R / 'native-video/experimental/source-session-isolated-two-v25-async'
MODE = 'isolated-two-v25-async'
DEVICE = '/system/lib64/libx2v_mode21c24_async_20261013a.so'
VALIDATOR = '/system/bin/x2v_rx25_async_receipt_validate_20261013a'
TOKEN = 'GROUP13_MODE21C24_DNG_ASYNC_WRITER_V25'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()

def write_new(p, value):
    with p.open('x') as f:
        f.write(value)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('receiver', type=Path)
    ap.add_argument('validator', type=Path)
    args = ap.parse_args()
    rx, vd = args.receiver.resolve(), args.validator.resolve()
    parent = json.loads((OLD / 'freeze.json').read_text())
    before = {n: sha(OLD/n) for n in parent['runtime_files']}
    assert before == parent['runtime_files']
    NEW.mkdir()
    for name in before:
        shutil.copy2(OLD/name, NEW/name)
    c = (NEW/'controller.sh').read_text()
    for a, b in ((parent['mode'],MODE), (parent['receiver_path'],DEVICE),
                 (parent['receiver_sha256'],sha(rx)), (parent['validator_path'],VALIDATOR),
                 (parent['validator_sha256'],sha(vd)), (parent['token'],TOKEN)):
        assert a in c, a
        c = c.replace(a,b)
    old_frame = next(l for l in c.splitlines() if 'frame="^' in l)
    new_frame = old_frame.replace(r',\"write_end_ns\":', r',\"pwrite_end_ns\":" u ",\"write_end_ns\":')
    new_frame = new_frame.replace(r',\"file_bytes\":', r',\"fsync_begin_ns\":" u ",\"fsync_end_ns\":" u ",\"file_bytes\":')
    new_frame = new_frame.replace(r'\"file_fsync\":true,', r'\"file_fsync\":true,\"file_published\":true,')
    assert new_frame != old_frame
    c = c.replace(old_frame,new_frame).replace('pairs($0,row)!=12','pairs($0,row)!=16')
    old_clock = next(l for l in c.splitlines() if 'if(row["write_begin_ns"]+0' in l)
    new_clock = '''   if(row["write_begin_ns"]+0 < v["frame" j "_write_begin_ns"]+0 || row["pwrite_end_ns"]+0 != v["frame" j "_pwrite_end_ns"]+0 || row["pwrite_end_ns"]+0 < row["write_begin_ns"]+0)fail()
   if(row["fsync_begin_ns"]+0 < v["frame" j "_complete_begin_ns"]+0 || row["fsync_end_ns"]+0 > v["frame" j "_complete_end_ns"]+0 || row["fsync_end_ns"]+0 < row["fsync_begin_ns"]+0 || row["write_end_ns"]+0 != row["fsync_end_ns"]+0)fail()
   if(v["frame" j "_submitted"]!=1 || v["frames_submitted"]!=count || v["dng_join_failed"]!=0)fail()'''
    c = c.replace(old_clock,new_clock)
    old_end = next(l for l in c.splitlines() if 'FNR!=count+2' in l)
    new_end = old_end.replace(r' count ",\"error\":0}', r' count ",\"submitted_frames\":" count ",\"error\":0}')
    assert new_end != old_end
    c = c.replace(old_end,new_end)
    (NEW/'controller.sh').write_text(c)
    b = (NEW/'bootstrap.sh').read_text().replace(parent['mode'],MODE).replace(before['controller.sh'],sha(NEW/'controller.sh'))
    (NEW/'bootstrap.sh').write_text(b)
    (NEW/'guard.sh').write_text((NEW/'guard.sh').read_text().replace(parent['mode'],MODE))
    for name in ('controller.sh','bootstrap.sh','guard.sh'):
        subprocess.run(['/bin/sh','-n',str(NEW/name)],check=True)
    freeze = dict(parent)
    freeze.update(mode=MODE, hard_hold=True, execution_approved=False,
                  token=TOKEN, receiver_path=DEVICE, receiver_sha256=sha(rx),
                  validator_path=VALIDATOR, validator_sha256=sha(vd),
                  runtime_files={n:sha(NEW/n) for n in before},
                  parent_freeze_sha256=sha(OLD/'freeze.json'),
                  integrations_pending=['actual async writer timing and final closure'],
                  scope='Two actual 24fps RAW short recordings; async fsync writer; no hardware encoder changes',
                  receiver_artifact=str(rx),validator_artifact=str(vd))
    (NEW/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n')
    runner = (R/'local-verification/isolated_two_v20e_metadata_test.py').read_text()
    runner = runner.replace(OLD.name,NEW.name).replace(parent['mode'],MODE)
    runner = runner.replace('   import ack_contract\n','   import ack_contract_v25_async as ack_contract\n')
    runner = runner.replace('from dng_capture_metrics import measure','from dng_async_metrics import measure')
    runner = runner.replace("[measure(rx) for rx in receipts]", "[measure(rx, d/name) for rx,name in zip(receipts,['dng.metadata.jsonl','dng2.metadata.jsonl'])]")
    path=R/'local-verification/isolated_two_v25_async_test.py'
    compile(runner,str(path),'exec');write_new(path,runner)
    stage = f'''from pathlib import Path
import ssd_stage
ssd_stage.BINARY=Path({str(rx)!r})
ssd_stage.EXPECTED={sha(rx)!r}
ssd_stage.DEVICE_BINARY={DEVICE!r}
ssd_stage.RUN_PREFIX='source-async-v25-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
'''
    write_new(R/'local-verification/source_async_v25_receiver_stage.py',stage)
    assert {n:sha(OLD/n) for n in before}==before
    print(json.dumps(dict(packet=str(NEW),receiver_sha256=sha(rx),validator_sha256=sha(vd))))

if __name__=='__main__':main()
