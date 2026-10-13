from pathlib import Path
from datetime import datetime
import sys,json,subprocess,time
from factory_session import connect
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-target-ring240-v13-c24'
sys.path.insert(0,str(P.parent/'receipt-oracle-v13-ring240'))
from generate_fixture import make_fixture
run='ring240-parser-'+datetime.now().strftime('%H%M%S');out=R/'native-video/outputs'/run;out.mkdir();remote='/data/x2v-source-20261012/runs/'+run
(out/'receiver.receipt').write_text(json.dumps(make_fixture(),separators=(',',':'))+'\n')
script='''PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
cd '''+remote+''' || exit 1
for lock in /data/x2v-source-20261012/source-session.lock /data/x2v-native-20261012/gui-session.lock /blackbox/x2v-native-20261011/gui-session.lock;do if test -e "$lock";then echo 20 > done.rc;exit 20;fi;done
cat /proc/uptime > begin.time
awk -v require_frame=1 -f receipt_gate.awk receiver.receipt
rc=$?
cat /proc/uptime > parsed.time
if [ "$rc" = 0 ];then awk -f config_gate.awk receiver.receipt;rc=$?;fi
cat /proc/uptime > end.time
printf '%s\\n' "$rc" > done.rc
'''
(out/'measure.sh').write_text(script)
def adb(*args):
 p=subprocess.run(['adb','-s','123456789ABCDEF',*map(str,args)],capture_output=True,text=True,timeout=8);assert p.returncode==0,p.stderr;return p.stdout
adb('shell','test ! -e '+remote+' && mkdir '+remote)
for p,n in [(out/'measure.sh','measure.sh'),(P/'receipt_gate.awk','receipt_gate.awk'),(P/'config_gate.awk','config_gate.awk'),(out/'receiver.receipt','receiver.receipt')]:adb('push',p,remote+'/'+n)
with connect() as f:launch=f.factory_shell('toybox nohup sh '+remote+'/measure.sh >'+remote+'/log 2>&1 & echo $!')
end=time.monotonic()+25
while time.monotonic()<end:
 rc=adb('shell','if [ -f '+remote+'/done.rc ];then cat '+remote+'/done.rc;fi').strip()
 if rc:break
 time.sleep(.2)
assert rc=='0',rc
vals={n:float(adb('shell','cat '+remote+'/'+n+'.time').split()[0]) for n in ['begin','parsed','end']}
r={'passed':True,'scope':'native parser on synthetic240 fixture; no imaging/stream mutations','parser_seconds':round(vals['parsed']-vals['begin'],3),'config_seconds':round(vals['end']-vals['parsed'],3),'launch':launch}
(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r))
