"""Pure synthetic receipt parse/cache timing in native shell; no imaging."""
from pathlib import Path
from datetime import datetime
import hashlib,json,re,subprocess,time,sys
from factory_session import connect
R=Path(__file__).resolve().parents[1];P=R/('native-video/experimental/receipt-cache-v13' if '--v13' in sys.argv else 'native-video/experimental/receipt-cache-v12');C=P.parent/'source-session-isolated-target-ring72-v12-c24'
run='cache72-pure-'+datetime.now().strftime('%H%M%S');out=R/'native-video/outputs'/run;out.mkdir()
remote='/data/x2v-source-20261012/runs/'+run
c=(C/'controller.sh').read_text()
def fn(n):return re.search(r'^'+n+r'\(\) \{.*?^\}',c,re.M|re.S)[0]+'\n'
script='''#!/system/bin/sh
set -eu
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
for lock in /data/x2v-source-20261012/source-session.lock /data/x2v-native-20261012/gui-session.lock /blackbox/x2v-native-20261011/gui-session.lock /data/x2v-native-20261012/io-benchmark.lock; do test ! -e "$lock"; done
test "$(getprop init.svc.camera-service)" = running
test "$(getprop init.svc.camera-gui)" = running
'''
script+='RUN='+remote+'\nBULK=$RUN\nID='+run+'\nnonce=pure_synthetic_text_test\n'
script+=fn('inode_token')+fn('receiver_inodes')
script+=(P/'receipt-validate-uncached.sh').read_text().replace('receipt_validate_uncached() {','receipt_validate_uncached() {\n printf "%s\\n" "$1" >> "$RUN/parser-calls"')+'\n'
script+=(P/'receipt-cache.sh').read_text()+'\n'
script+='''(umask 077;set -C;: > "$BULK/raw.partial";printf 0 > "$RUN/receiver.command")
inode_token "$BULK/raw.partial" > "$RUN/raw.inode"
inode_token "$RUN/receiver.command" > "$RUN/command.inode"
inode_token "$RUN/receiver.receipt" > "$RUN/receipt.inode"
for require in 0 1 0; do
 echo BEGIN:$require
 cat /proc/uptime
 receipt_valid "$require"
 cat /proc/uptime
 echo END:$require
done
cat "$RUN/parser-calls"
echo PURE_CACHE_COMPLETE
'''
p=out/'pure-cache.sh';p.write_text(script)
def adb(*args):
 q=subprocess.run(['adb','-s','123456789ABCDEF',*args],capture_output=True,text=True,timeout=10);assert q.returncode==0,(args,q.stdout,q.stderr);return q.stdout
adb('shell','test ! -e '+remote+' && mkdir '+remote)
for source,name in [(p,'pure-cache.sh'),(C/'synthetic-72.receipt.json','receiver.receipt')]:
 adb('push',str(source),remote+'/'+name)
 assert adb('shell','sha256sum '+remote+'/'+name).split()[0]==hashlib.sha256(source.read_bytes()).hexdigest()
start=time.monotonic()
with connect() as f:raw=f.factory_shell('sh '+remote+'/pure-cache.sh',capture_ms=25000)
result={'scope':__doc__,'wall_seconds':time.monotonic()-start,'output':raw,'passed':False,'files':{str(x.relative_to(R)):hashlib.sha256(x.read_bytes()).hexdigest() for x in [p,P/'receipt-cache.sh',P/'receipt-validate-uncached.sh']}}
assert 'PURE_CACHE_COMPLETE' in raw
blocks=re.findall(r'BEGIN:([01])\n([0-9.]+) [0-9.]+\n([0-9.]+) [0-9.]+\nEND:\1',raw);assert len(blocks)==3
result['check_seconds']=[round(float(b)-float(a),3) for n,a,b in blocks]
assert raw.split('END:0\n')[-1]=='1\nPURE_CACHE_COMPLETE\n'
result['strict_parses']=1;result['passed']=True
(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'passed':True,'times':result['check_seconds'],'report':str(out/'report.json')}))
