"""Read-only native ACK benchmark, no camera source calls or RAW readback."""
from pathlib import Path
from datetime import datetime
import json,subprocess,time,hashlib
from factory_session import connect
R=Path(__file__).resolve().parents[1]
B=R/'native-video/experimental/native-rx15-receipt-validator'
audit=json.loads((R/'research/full-fov-pipeline/native-rx15-validator-independent-review/receipt.json').read_text())
assert audit['decision']=='GO_READONLY_NATIVE_TEXT_PERFORMANCE_TEST_ONLY' and not audit['p1']
run='receipt-native-bench-'+datetime.now().strftime('%H%M%S')
out=R/'native-video/outputs'/run;out.mkdir(exist_ok=False)
remote='/data/x2v-source-20261012/runs/'+run
old='/data/x2v-source-20261012/runs/source-isolated-150137'
binary='/system/bin/x2v_rx15_receipt_validate_20261012a'
def adb(*args):
 p=subprocess.run(['adb','-s','123456789ABCDEF',*map(str,args)],capture_output=True,text=True,timeout=8)
 if p.returncode:raise RuntimeError((p.returncode,p.stdout,p.stderr))
 return p.stdout
assert adb('shell','getprop ro.product.device').strip()=='eagle2_hb722'
assert adb('shell','sha256sum '+binary).split()[0]==audit['artifact_sha256']
for name in ['receiver.receipt','receiver2.receipt']:
 local=R/'native-video/outputs/source-isolated-150137/device-run'/name
 assert adb('shell','sha256sum '+old+'/'+name).split()[0]==hashlib.sha256(local.read_bytes()).hexdigest()
script='''#!/system/bin/sh
set -eu
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
for lock in /data/x2v-source-20261012/source-session.lock /data/x2v-native-20261012/gui-session.lock /blackbox/x2v-native-20261011/gui-session.lock;do test ! -e "$lock" && test ! -L "$lock";done
cd REMOTE
read t rest < /proc/uptime;echo AWK_BEGIN:$t
timeout 5 awk -v require_frame=1 -v expected_generation=1 -f receipt_gate.awk OLD/receiver.receipt
read t rest < /proc/uptime;echo AWK_END:$t
timeout 5 BINARY --expected-generation 1 --require-frame 1 < OLD/receiver.receipt
timeout 5 BINARY --expected-generation 2 --require-frame 1 < OLD/receiver2.receipt
timeout 5 BINARY --expected-generation 1 --require-frame 0 < OLD/receiver.receipt
if timeout 5 BINARY --expected-generation 2 --require-frame 1 < OLD/receiver.receipt;then exit 21;else rc=$?;test "$rc" = 1;fi
echo ACK_BENCH_PASS
'''.replace('REMOTE',remote).replace('OLD',old).replace('BINARY',binary)
(out/'measure.sh').write_text(script)
adb('shell','test ! -e '+remote+' && mkdir '+remote)
for src,name in [(out/'measure.sh','measure.sh'),(R/'native-video/experimental/source-session-isolated-resident-two-v15/receipt_gate.awk','receipt_gate.awk')]:
 adb('push',src,remote+'/'+name)
 assert adb('shell','sha256sum '+remote+'/'+name).split()[0]==hashlib.sha256(src.read_bytes()).hexdigest()
with connect() as f:
 health='pidof camera-service;pidof camera-gui;odindb-send -s system -p screen_idle_timeout;mount | grep " /system "'
 before=f.factory_shell(health,capture_ms=4000)
 start=time.monotonic();result=f.factory_shell('timeout 12 sh '+remote+'/measure.sh',capture_ms=15000);wall=time.monotonic()-start
 after=f.factory_shell(health,capture_ms=4000)
(out/'stdout.txt').write_text(result)
lines=result.strip().splitlines();assert 'ACK_BENCH_PASS' in lines,result
results=[json.loads(x) for x in lines if x.startswith('{')]
assert len(results)==4
for gen,frame,row in zip([1,2,1],[1,1,0],results[:3]):
 assert row['valid']==1 and row['safe_cpu_closure']==1 and row['clock_valid']==1 and row['expected_generation']==gen and row['require_frame']==frame
assert all(x['capture_success']==1 and x['configuration_applied']==1 for x in results[:2])
assert results[-1]['valid']==0
times={line.split(':')[0]:float(line.split(':')[1]) for line in lines if line.startswith('AWK_')}
report={'passed':before==after,'scope':'existing completed ACKs only; no source transition/capture/DMA calls','before':before,'after':after,'native_results':results,'old_awk_seconds_10ms_resolution':round(times['AWK_END']-times['AWK_BEGIN'],3),'factory_command_wall_seconds':wall,'clock_scope':'C validation_ns is own read+parse+checks, not complete interclip latency','binary_sha256':audit['artifact_sha256']}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
assert report['passed'],report
print(json.dumps({'report':str(out/'report.json'),**report},indent=2))
