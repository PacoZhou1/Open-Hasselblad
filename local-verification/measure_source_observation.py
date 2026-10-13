"""Read-only camera state query timing; no imaging mutation."""
from pathlib import Path
from datetime import datetime
import hashlib,json,re,subprocess,time
from factory_session import connect
ROOT=Path(__file__).resolve().parents[1]
P=ROOT/'native-video/experimental/source-session-isolated-target-ring72-v12-c24'
s=(P/'controller.sh').read_text()
values={k:re.search(r'^'+k+r'=(.*)$',s,re.M)[1] for k in ['BUSY','IDLE','STATE']}
run='source-query-timing-'+datetime.now().strftime('%H%M%S')
out=ROOT/'native-video/outputs'/run;out.mkdir()
remote='/data/x2v-source-20261012/runs/'+run
script='''#!/system/bin/sh
set -eu
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
for lock in /data/x2v-source-20261012/source-session.lock /data/x2v-native-20261012/gui-session.lock /blackbox/x2v-native-20261011/gui-session.lock /data/x2v-native-20261012/io-benchmark.lock; do test ! -e "$lock"; done
test "$(getprop init.svc.camera-service)" = running
test "$(getprop init.svc.camera-gui)" = running
pidof camera-service
pidof camera-gui
cat /proc/sys/kernel/random/boot_id
mount | grep ' /system '
df -k /mnt/media_rw/ssd /data
cat /proc/meminfo | head -3
echo SEPARATE_BEGIN
cat /proc/uptime
'''
for k in ['BUSY','IDLE','STATE']:script+='timeout 4 odindb-send -s camera -p '+values[k]+'\n'
script+='''cat /proc/uptime
echo SEPARATE_END
echo BATCH_BEGIN
cat /proc/uptime
'''
script+='timeout 4 odindb-send -s camera -p '+','.join(values.values())+'\n'
script+='''cat /proc/uptime
echo BATCH_END
timeout 3 odindb-send -s error -p active_error
timeout 4 odindb-send -s camera -m get_frame_count
timeout 4 odindb-send -s camera -m get_frame_count
echo TIMING_COMPLETE
'''
p=out/'read-only-query-timing.sh';p.write_text(script)
def adb(*args):
 q=subprocess.run(['adb','-s','123456789ABCDEF',*args],capture_output=True,text=True,timeout=10);assert q.returncode==0,(args,q.stdout,q.stderr);return q.stdout
assert adb('shell','getprop init.svc.camera-service').strip()=='running'
adb('shell','test ! -e '+remote+' && mkdir '+remote)
adb('push',str(p),remote+'/timing.sh')
assert adb('shell','sha256sum '+remote+'/timing.sh').split()[0]==hashlib.sha256(p.read_bytes()).hexdigest()
report={'scope':__doc__,'passed':False,'run':run,'script_sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
start=time.monotonic()
with connect() as f:raw=f.factory_shell('sh '+remote+'/timing.sh',capture_ms=22000)
report['host_seconds']=time.monotonic()-start;report['output']=raw
for name in ['SEPARATE','BATCH']:
 block=raw.split(name+'_BEGIN\n')[1].split(name+'_END')[0].strip().splitlines()
 report[name.lower()+'_seconds']=float(block[-1].split()[0])-float(block[0].split()[0])
 fields=[x for x in block[1:-1] if ' = ' in x]
 assert len(fields)==16 and len(set(x.split(' = ')[0] for x in fields))==16
 report[name.lower()+'_fields']=sorted(fields)
assert report['separate_fields']==report['batch_fields']
assert 'TIMING_COMPLETE' in raw and 'active_error = false' in raw
counts=re.findall(r'^count = ([0-9]+)$',raw,re.M);assert len(counts)==2 and int(counts[1])>int(counts[0])
assert '(ro,' in raw and 'f6668de2-2070-4793-9cbd-6cfbb7adc2bf' in raw
report['passed']=True
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['passed','separate_seconds','batch_seconds','host_seconds']}))
print(out/'report.json')
