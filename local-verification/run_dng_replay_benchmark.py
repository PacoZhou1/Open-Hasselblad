"""Six bounded ordinary-file DNG replays on SSD; no camera mode operation."""
import argparse, hashlib, json, statistics, time
from datetime import datetime
from pathlib import Path
from factory_session import connect
from gui_session import adb, verify_device
from highres_one_frame import STATE, check_state
from dng_replay_stage import EXPECTED

R=Path(__file__).resolve().parents[1]
BINARY='/system/bin/x2v_dng_replay_bench_20261012a'
RUN_PREFIX='dng-replay'
RESULT_SCOPE='resident_dng_replay_benchmark'
RESULT_VERSION=1
TIMING_KINDS=('write','finish','verify')
EXTRA_ARGS=''
SOURCE='/mnt/media_rw/ssd/x2v-source-20261012/runs/source-isolated-151741/raw.partial'
SOURCE_IDENTITY='66321:127281:1:1472905728'
LOCKS=['/data/x2v-source-20261012/source-session.lock',
       '/data/x2v-native-20261012/gui-session.lock',
       '/blackbox/x2v-native-20261011/gui-session.lock']
IOLOCK='/data/x2v-native-20261012/io-benchmark.lock'
ACK=json.loads((R/'native-video/outputs/source-isolated-151741/device-run/receiver.receipt').read_text())
META={k:ACK['frame20_'+k] for k in ['id','timestamp_native','admission_ns','write_offset']}

def validate(d):
    assert d['scope']==RESULT_SCOPE and d['version']==RESULT_VERSION
    for k in ['pass','source_unchanged','memcmp_full_selected_words','backend_required_direct','pixel_readback_buffered']:
        assert d[k] is True,k
    for k in ['errno','close_error','new_capture_frames']:assert d[k]==0,k
    assert d['completed']==d['replay_count']==len(d['frames'])==6
    assert d['source_id']==META['id'] and d['native_timestamp_raw']==META['timestamp_native']
    assert d['original_cpu_admission_ns']==META['admission_ns'] and d['source_offset']==META['write_offset']
    assert (d['source_dev'],d['source_inode'],d['source_size'])==(66321,127281,1472905728)
    assert d['source_flags']&3==0 and d['peak_rss_kib']<=65536
    assert d['expected_DNG_bytes']==23100928 and d['expected_total_DNG_bytes']==138605568
    assert d['writer_provider_pinned']==d['writer_provider_kind']==1
    assert d['writer_provider_path']=='/system/lib64/libc.so'
    for kind,offset in [('pwrite',0x70c40),('fsync',0x70700)]:
        assert d['writer_provider_'+kind+'_offset']==offset
        assert d['writer_provider_'+kind+'_address']==d['writer_provider_base']+offset
    assert d['total_clock_valid']==1 and d['total_end_ns']>d['total_begin_ns']
    assert d['total_cpu_end_ns']>=d['total_cpu_begin_ns']
    for i,row in enumerate(d['frames']):
        assert row['replay_index']==i
        assert row['file_bytes']==23100928 and row['pixel_bytes']==23096640
        for k in ['frame_published','file_synced','manifest_published','directory_synced','cpu_released','verified']:assert row[k]==1,k
        assert row['finish_error']==row['finish_close_error']==0
        for kind in TIMING_KINDS:
            t=row[kind];assert t['valid']==1
            for clock in ['wall','cpu']:
                assert t[clock+'_end_ns']>=t[clock+'_begin_ns']
                assert t[clock+'_ns']==t[clock+'_end_ns']-t[clock+'_begin_ns']
    return {kind+'_ms':[round(row[kind]['wall_ns']/1e6,3) for row in d['frames']]
            for kind in TIMING_KINDS}

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--execute',action='store_true');args=ap.parse_args()
    if not args.execute:
        print(json.dumps({'offline_only':True,'metadata':META,'new_capture_frames':0,'output_bytes':138605568}));return 0
    verify_device()
    run=datetime.now().strftime(RUN_PREFIX+'-%H%M%S')
    out=R/'native-video/outputs'/run;out.mkdir(exist_ok=False)
    remote='/data/x2v-native-20261012/runs/'+run
    media='/mnt/media_rw/ssd/X2V_BENCH/'+run
    report={'run':run,'passed':False,'source':SOURCE,'media':media,'metadata':META,'artifact_sha256':EXPECTED,'events':[]}
    def q(f,cmd):
        assert len(cmd.encode())<=231
        s=f.factory_shell(cmd,capture_ms=4000);report['events'].append({'command':cmd,'output':s});return s.strip()
    def health(f):
        return {'pids':q(f,'pidof camera-service;pidof camera-gui;getprop init.svc.camera-gui'),
                'state':q(f,STATE),'mount':q(f,'mount | grep " /system "'),
                'timeout':q(f,'odindb-send -s system -p screen_idle_timeout')}
    def locks(f):
        for p in LOCKS+[IOLOCK]:assert q(f,'test ! -e '+p+' && test ! -L '+p+' && echo CLEAR')=='CLEAR',p
    script=f'''#!/system/bin/sh
set -eu
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
cd {remote}
set -C
for p in {' '.join(LOCKS)};do test ! -e "$p" && test ! -L "$p";done
test ! -e {IOLOCK} && test ! -L {IOLOCK}
mkdir {IOLOCK}
echo {run} >{IOLOCK}/owner
cleanup() {{
 rc=$?
 trap - EXIT
 if [ "$(cat {IOLOCK}/owner)" = {run} ];then rm {IOLOCK}/owner; rmdir {IOLOCK} || rc=95;else rc=96;fi
 echo "$rc" >exit.code
 chmod 644 exit.code result.json error.log 2>/dev/null || true
 exit "$rc"
}}
trap cleanup EXIT
for p in {' '.join(LOCKS)};do test ! -e "$p" && test ! -L "$p";done
test "$(stat -c '%d:%i:%h:%s' {SOURCE})" = {SOURCE_IDENTITY}
for p in /mnt /mnt/media_rw /mnt/media_rw/ssd /mnt/media_rw/ssd/X2V_BENCH /mnt/media_rw/ssd/x2v-source-20261012 /mnt/media_rw/ssd/x2v-source-20261012/runs /mnt/media_rw/ssd/x2v-source-20261012/runs/source-isolated-151741 {SOURCE};do test ! -L "$p";done
free=$(df -k /mnt/media_rw/ssd | tail -n 1 | awk '{{print $4}}')
test "$free" -gt 12582912
mkdir {media}
timeout 35 {BINARY} --run-replay --source-offset {META['write_offset']} --source-id {META['id']} --timestamp-raw {META['timestamp_native']} --admission-raw {META['admission_ns']} {EXTRA_ARGS} 3<{media} 4<{SOURCE} >result.json 2>error.log
test "$(stat -c '%d:%i:%h:%s' {SOURCE})" = {SOURCE_IDENTITY}
'''
    (out/'controller.sh').write_text(script)
    try:
        with connect() as f:
            locks(f);report['before']=health(f)
            b=report['before'];assert 'running' in b['pids'] and check_state(b['state']) and '(ro,' in b['mount']
            assert q(f,'sha256sum '+BINARY).split()[0]==EXPECTED
            assert q(f,"stat -c '%d:%i:%h:%s' "+SOURCE)==SOURCE_IDENTITY
            assert q(f,'test ! -e '+remote+' && mkdir '+remote+' && echo CREATED')=='CREATED'
        adb('push',str(out/'controller.sh'),remote+'/controller.sh')
        with connect() as f:
            assert q(f,'sha256sum '+remote+'/controller.sh').split()[0]==hashlib.sha256(script.encode()).hexdigest()
            t=time.monotonic()
            pid=q(f,'cd '+remote+';toybox nohup sh controller.sh >controller.log 2>&1 & echo $!')
            assert pid.isdigit();report['supervisor_pid']=pid
        deadline=time.monotonic()+40
        while time.monotonic()<deadline:
            ready=adb('shell','if [ -f '+remote+'/exit.code ];then cat '+remote+'/exit.code;fi').strip()
            if ready:report['exit_code']=int(ready);break
            time.sleep(.2)
        else:raise RuntimeError('Unknown completion; inspect same supervisor; no redispatch')
        report['host_dispatch_to_observed_seconds']=time.monotonic()-t
        for name in ['result.json','error.log','controller.log','exit.code']:
            adb('pull',remote+'/'+name,str(out/name))
        assert report['exit_code']==0,(out/'error.log').read_text()
        d=json.loads((out/'result.json').read_text());report['times']=validate(d)
        report['write_median_ms']=statistics.median(report['times']['write_ms'])
        report['io_verified']=True
    except BaseException as e:report['failure']=repr(e)
    finally:
        try:
            with connect() as f:
                report['after']=health(f);locks(f)
                report['source_after']=q(f,"stat -c '%d:%i:%h:%s' "+SOURCE)
                report['locks_clear']=True
        except BaseException as e:report['health_failure']=repr(e)
        report['passed']=bool(report.get('io_verified') and not report.get('failure') and not report.get('health_failure')
            and report.get('before')==report.get('after') and report.get('source_after')==SOURCE_IDENTITY)
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps({'report':str(out/'report.json'),'passed':report['passed'],'failure':report.get('failure'),
                          'times':report.get('times'),'health_failure':report.get('health_failure')},indent=2))
    return 0 if report['passed'] else 1

if __name__=='__main__':raise SystemExit(main())
