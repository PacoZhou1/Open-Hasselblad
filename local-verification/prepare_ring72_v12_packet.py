"""Generate next bounded RAW packet offline; pins are mandatory before freeze."""
from pathlib import Path
import argparse
import difflib
import hashlib
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[1]
OLD=ROOT/'native-video/experimental/source-session-isolated-target-ring20-v11-c24'
NEW=ROOT/'native-video/experimental/source-session-isolated-target-ring72-v12-c24'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--receiver-sha',default='PENDING');args=ap.parse_args()
    assert args.receiver_sha=='PENDING' or re.fullmatch('[0-9a-f]{64}',args.receiver_sha)
    assert not (NEW/'freeze.json').exists(),'Never regenerate frozen packet'
    frozen=json.loads((OLD/'freeze.json').read_text())
    for n,h in frozen['runtime_files'].items():assert sha(OLD/n)==h
    NEW.mkdir(exist_ok=True)
    for n in ('guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf'):(NEW/n).write_bytes((OLD/n).read_bytes())
    # Only numeric count/version and admission window change in these strict
    # parsers. Dimension, native CPU closure, generation and per-frame gates stay.
    gate=(OLD/'receipt_gate.awk').read_text()
    gate=re.sub(r'\b20\b','72',gate).replace('467589120','1683320832')
    gate=gate.replace(r'\"version\":11',r'\"version\":12').replace('arm+1000000000','arm+3000000000')
    (NEW/'receipt_gate.awk').write_text(gate)
    ack=(OLD/'ack_contract.py').read_text()
    ack=re.sub(r'\b20\b','72',ack).replace('version=11','version=12').replace('arm+1000000000','arm+3000000000').replace('v11 ACK','v12 ACK')
    (NEW/'ack_contract.py').write_text(ack)
    c=(OLD/'controller.sh').read_text()
    oldgate=(OLD/'receipt_gate.awk').read_text().rstrip('\n')
    assert c.count(oldgate)==1
    c=c.replace(oldgate,gate.rstrip('\n'))
    c=c.replace('ring20','ring72').replace('v11','v12').replace('V11_ACK','V12_ACK').replace('RING20_DIRECT','RING72_DIRECT')
    c=c.replace('count>20)bad=1','count>72)bad=1')
    c=re.sub(r'^RECEIVER_SHA=[0-9a-f]+$',f'RECEIVER_SHA={args.receiver_sha}',c,flags=re.M)
    # Larger finite output requires at least3GiB free before ownership and A.
    # This reads only existing mounts before image ownership or file creation.
    c=c.replace('prepare_receiver || exit 4','''[ ! -e /data/x2v-native-20261012/io-benchmark.lock ] || exit 4
df -k /mnt/media_rw/ssd > "$RUN/ssd-space.before" || exit 4
awk 'NR==2 {good=(NF>=6 && $4 ~ /^[0-9]+$/ && $4>=3145728)} END{exit !good}' "$RUN/ssd-space.before" || exit 4
prepare_receiver || exit 4''')
    assert 3145728*1024 >= 1683320832+512*1024*1024
    c=c.replace('# this conservative gate leaves >=10s without resetting/claiming real-time.', '# this conservative gate leaves >=16s for3s capture and existing CPU drain.')
    c=c.replace('"$((arm_now-launch_time))" -le 28', '"$((arm_now-launch_time))" -le 24')
    c=c.replace(' : > "$RUN/receiver.arm-intent" || return 1', ''' df -k /mnt/media_rw/ssd > "$RUN/ssd-space.before-arm" || return 1
 awk 'NR==2 {good=(NF>=6 && $4 ~ /^[0-9]+$/ && $4>=3145728)} END{exit !good}' "$RUN/ssd-space.before-arm" || { fail target_storage_reserve_low_no_arm; return 1; }
 : > "$RUN/receiver.arm-intent" || return 1''')
    fast=(NEW/'observation-fast.sh').read_text()
    for name in ['query','busy_once','wait_idle','normal_state','graph_state','wait_ready','frames_advance']:
        pattern=r'^'+name+r'\(\) \{.*?^\}'
        replacement=re.search(pattern,fast,re.S|re.M).group()
        c,count=re.subn(pattern,lambda _:replacement,c,count=1,flags=re.S|re.M)
        assert count==1,name
    for name in ['snapshot_fields','take_state_snapshot']:
        block=re.search(r'^'+name+r'\(\) \{.*?^\}',fast,re.S|re.M).group()
        c=c.replace('busy_once() {',block+'\nbusy_once() {',1)
    c=c.replace('op() {\n gate', 'op() {\n STATE_SNAPSHOT_READY=0\n gate',1)
    cache=ROOT/'native-video/experimental/receipt-cache-v12/receipt-cache.sh'
    assert cache.exists()
    c=c.replace('receipt_valid() {', 'receipt_validate_uncached() {',1)
    c=c.replace('receiver_cancel() {',cache.read_text()+'\nreceiver_cancel() {',1)
    (NEW/'controller.sh').write_text(c)
    b=(OLD/'bootstrap.sh').read_text().replace('ring20-v11','ring72-v12')
    b=re.sub(r'^CONTROLLER_SHA=[0-9a-f]+$',f'CONTROLLER_SHA={sha(NEW/"controller.sh")}',b,flags=re.M)
    (NEW/'bootstrap.sh').write_text(b)
    for old,new in [('isolated_target_ring20_v11_c24_test.py','isolated_target_ring72_v12_c24_test.py'),('isolated_ring20_v11_c24_readback.py','isolated_ring72_v12_c24_readback.py')]:
        text=(ROOT/'local-verification'/old).read_text().replace('ring20','ring72').replace('v11','v12').replace('V11_ACK','V12_ACK')
        if 'readback' in new:text=text.replace('MAX_BYTES=FRAME_BYTES*20','MAX_BYTES=FRAME_BYTES*72')
        else:
            text=text.replace('  time.sleep(1.3)\n  gr=', '''  guard_ready_until=time.monotonic()+5
  while time.monotonic()<guard_ready_until:
   if read('adb-guard.ready') and read('adb-guard.heartbeat'):break
   time.sleep(.05)
  else:raise RuntimeError('No guard ready/heartbeat completion')
  gr=''')
            text=text.replace('   time.sleep(1)\n  else:', '   time.sleep(.2)\n  else:')
        (ROOT/'local-verification'/new).write_text(text)
    for n in ['controller.sh','bootstrap.sh','receipt_gate.awk','ack_contract.py']:
        (NEW/(n+'.diff')).write_text(''.join(difflib.unified_diff((OLD/n).read_text().splitlines(True),(NEW/n).read_text().splitlines(True),fromfile='C24-v11/'+n,tofile='C24-v12/'+n)))
    mksh=ROOT/'native-video/outputs/runtime/mksh-r56-host/mksh'
    for n in ['controller.sh','bootstrap.sh','guard.sh']:
        subprocess.run([str(mksh),'-n',str(NEW/n)],capture_output=True,check=True)
    receipt={'scope':'Offline ring72/3s candidate, native source geometry/timing and cleanup reused; not execution release',
             'baseline_freeze_sha256':sha(OLD/'freeze.json'),'receiver_sha256':args.receiver_sha,
             'files':{n:sha(NEW/n) for n in ['controller.sh','bootstrap.sh','guard.sh','imx861bqr_hb722.sp','imx861bqr_hb722.conf','ack_contract.py','receipt_gate.awk']},
             'limits':{'frames':72,'admission_ns':3000000000,'max_bytes':1683320832,'prefault_bytes':70138368,'ssd_min_available_KiB':3145728,'max_launch_age_before_A_seconds':24}}
    (NEW/'draft-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print('ring72 v12 packet generated; no freeze or execution release')

if __name__=='__main__':main()
