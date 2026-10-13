"""One CPU/file-only DNG conversion; explicit --execute, no camera handles."""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import time
from factory_session import connect
from gui_session import adb
from highres_one_frame import STATE, check_state

ROOT=Path(__file__).resolve().parents[1]
HELPER='/system/bin/x2v_dng_20261011a'
HELPER_SHA='c9c02aca697a042ac9982c1c3b951dbfc98d0202d57713ca28fae88846c493fc'
SOURCE='/blackbox/x2v-native-20261011/runs/still-reference-231424/B0003648.3FR'
SOURCE_SHA='4ef366a1c012eda49de62b0c01b978d9d256786782be42330f7b39dee97b6f11'
OUTPUT_SHA='442841d226decbcffc3e9692b08034d6a7ace86df4b1474c6a01f51effcd2a12'

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--execute',action='store_true');a=ap.parse_args()
    if not a.execute:
        print('Offline: own-shot 3FR to unique DNG; CPU10s/wall20s/AS32MiB/FSIZE256MiB.');return
    run=datetime.now().strftime('dng-%H%M%S');out=ROOT/'native-video/outputs'/run;out.mkdir()
    remote='/blackbox/x2v-native-20261011/runs/'+run
    report={'events':[],'dispatched':False,'remote':remote}
    def query(f,c):
        if len(c.encode())>231:raise ValueError('Command too long')
        v=f.factory_shell(c,capture_ms=5000);report['events'].append({'command':c,'output':v});return v
    try:
        with connect() as f:
            for path,digest in ((HELPER,HELPER_SHA),):
                if query(f,'sha256sum '+path).split()[0]!=digest:raise RuntimeError('Pinned file mismatch')
            pids=query(f,'pidof camera-service camera-gui').split()
            if len(pids)!=2 or not check_state(query(f,STATE)):raise RuntimeError('Camera not normal')
            report['before_frame_count']=query(f,'odindb-send -s camera -m get_frame_count')
            if ' (ro,' not in query(f,'mount | grep " /system "'):raise RuntimeError('System not readonly')
            query(f,f'test ! -e {remote} && mkdir {remote}')
        script=f'''#!/system/bin/sh
set -eu
cd {remote}
trap 'rc=$?;echo "$rc" >controller-exit.code' EXIT
[ $(df -k /blackbox | tail -1 | awk '{{print $4}}') -gt 400000 ]
[ ! -e result.dng ] && [ ! -e result.dng.partial ]
timeout 8 sha256sum {SOURCE} >source-before.sha256
[ "$(cut -d' ' -f1 source-before.sha256)" = "{SOURCE_SHA}" ]
date +%s >started.txt
set +e
timeout 22 {HELPER} {SOURCE} result.dng --confirmed-rggb >converter.log 2>&1
rc=$?
set -e
echo "$rc" >exit.code
date +%s >finished.txt
if [ "$rc" -eq 0 ]; then
 sha256sum result.dng >result.sha256
 stat -c '%s' result.dng >result.bytes
 chmod 644 result.dng result.sha256 result.bytes
fi
sha256sum {SOURCE} >source-after.sha256
chmod 644 converter.log exit.code started.txt finished.txt source-after.sha256
echo CONTROLLER_FINISHED
'''
        local=out/'controller.sh';local.write_text(script);adb('push',str(local),remote+'/controller.sh')
        with connect() as f:
            if query(f,'sha256sum '+remote+'/controller.sh').split()[0]!=hashlib.sha256(local.read_bytes()).hexdigest():raise RuntimeError('Upload mismatch')
            report['dispatched']=True
            report['pid']=query(f,f'cd {remote};toybox nohup sh controller.sh >controller.log 2>&1 & echo $!')
        end=time.monotonic()+38
        while time.monotonic()<end:
            v=adb('shell',f'if [ -f {remote}/controller-exit.code ]; then cat {remote}/controller-exit.code; fi').strip()
            if v:report['controller_returncode']=int(v);break
            time.sleep(.5)
        with connect() as f:
            report['after_state']=query(f,STATE);report['after_pids']=query(f,'pidof camera-service camera-gui').split()
            report['same_processes']=report['after_pids']==pids
            report['after_frame_count']=query(f,'odindb-send -s camera -m get_frame_count')
            report['system_mount']=query(f,'mount | grep " /system "')
        for name in ('controller.log','converter.log','exit.code','started.txt','finished.txt','source-before.sha256','source-after.sha256','result.sha256','result.bytes'):
            adb('pull',remote+'/'+name,str(out/name))
        report['returncode']=int((out/'exit.code').read_text())
        if report.get('returncode')!=0:raise RuntimeError('Converter did not succeed')
        if (out/'source-after.sha256').read_text().split()[0]!=SOURCE_SHA:raise RuntimeError('Source changed')
        if (out/'result.sha256').read_text().split()[0]!=OUTPUT_SHA:raise RuntimeError('Output differs from host reference')
        adb('pull',remote+'/result.dng',str(out/'result.dng'))
        digest=hashlib.sha256((out/'result.dng').read_bytes()).hexdigest()
        if digest!=OUTPUT_SHA:raise RuntimeError('Pull differs from device')
        report.update(output_sha256=digest,output_bytes=(out/'result.dng').stat().st_size,
                      success=report['same_processes'] and check_state(report['after_state']))
    except BaseException as exc:report['failure']=repr(exc)
    finally:
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps({'output':str(out),'success':report.get('success',False),'failure':report.get('failure')},indent=2))
    if not report.get('success'):raise SystemExit(1)

if __name__=='__main__':main()
