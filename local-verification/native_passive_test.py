"""CPU-only native owner attach/survival test; default offline. No imaging mutation."""
from pathlib import Path
from datetime import datetime
import argparse, hashlib, json, re, secrets, subprocess, time
from factory_session import connect

ROOT=Path(__file__).resolve().parents[1]
CANDIDATE=ROOT/'native-video/experimental/native-passive-helper-b'
REMOTE='/data/x2v-source-20261012/runs'
SERIAL='123456789ABCDEF'
DOMAIN='u:r:hbl_camera_service:s0'
TARGET='/uid_0/pid_2279'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def adb(*args, timeout=15):
    r=subprocess.run(['adb','-s',SERIAL,*args],capture_output=True,text=True,timeout=timeout)
    if r.returncode: raise RuntimeError(f'ADB failed {args!r}: {r.stdout} {r.stderr}')
    return r.stdout

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--execute',action='store_true'); a=ap.parse_args()
    if not a.execute:
        print(json.dumps({'offline':True,'scope':'passive native process attach and factory-only restart, no sensor/stream commands','candidate':str(CANDIDATE)})); return 0
    frozen=json.loads((CANDIDATE/'freeze.json').read_text())
    helper=CANDIDATE/'helper.sh'
    if sha(helper)!=frozen['helper_sha256']: raise RuntimeError('Helper differs from reviewed freeze')
    run='source-passive-'+datetime.now().strftime('%H%M%S'); out=ROOT/'native-video/outputs'/run; out.mkdir()
    remote=REMOTE+'/'+run; nonce=secrets.token_hex(16); challenge=secrets.token_hex(16)
    report={'run_id':run,'scope':'passive native owner in shared ADB cpuacct; not imaging mode or dedicated-group isolation','helper_sha256':sha(helper),'passed':False,'dispatched':False,'attach_attempted':False,'factory_restart_attempted':False}
    def query(f,cmd):
        if len(cmd.encode())>231: raise ValueError('Factory command too long')
        value=f.factory_shell(cmd,capture_ms=5000)
        report.setdefault('factory_queries',[]).append({'command':cmd,'output':value}); return value
    def put(name,value):
        p=out/name;p.write_text(value);temporary=remote+'/'+name+'.upload'
        adb('push',str(p),temporary)
        if adb('shell','sha256sum '+temporary).split()[0]!=sha(p): raise RuntimeError('Upload differs')
        adb('shell','test ! -e '+remote+'/'+name+' && mv '+temporary+' '+remote+'/'+name)
    def read(name):
        return adb('shell','if [ -f '+remote+'/'+name+' ]; then cat '+remote+'/'+name+'; fi')
    def clock():return int(adb('shell','/system/bin/x2v_guard_clock_20261012b').strip())
    def record(name,kind,token):
        raw=read(name)
        if not raw.endswith('\n') or len(raw.splitlines())!=1: return None
        x=raw.strip().split()
        if len(x)!=15 or x[:5]!=['v1',kind,run,nonce,token]:return None
        if x[7]!=boot or x[10]!=DOMAIN or x[12]!=TARGET:return None
        if not all(re.fullmatch('[0-9]+',x[i]) for i in [5,6,8,9,13,14]):return None
        if x[5]!=x[8] or x[5]!=x[9] or int(x[5])<2:return None
        return x
    def wait_record(name,kind,token,seconds):
        until=time.monotonic()+seconds
        while time.monotonic()<until:
            x=record(name,kind,token)
            if x:return x
            time.sleep(.1)
        raise RuntimeError('Missing canonical '+name)
    try:
        assert adb('shell','getprop init.svc.camera-service').strip()=='running'
        assert adb('shell','getprop init.svc.camera-gui').strip()=='running'
        with connect() as f:
            report['before']=query(f,'pidof camera-service;pidof camera-gui;p=$(pidof camera-test);cat /proc/$p/stat;cat /proc/$p/cgroup')
        lines=report['before'].strip().splitlines();stock=lines[:2];fp=lines[2].split()[0];fields=lines[2].rsplit(') ',1)[1].split();fs=fields[19];fg=fields[2]
        assert '2:cpuacct:/uid_0/pid_'+fp in lines
        boot=adb('shell','cat /proc/sys/kernel/random/boot_id').strip();now=clock();deadline=now+85
        adb('shell','test ! -e '+remote+' && mkdir '+remote)
        adb('push',str(helper),remote+'/helper.sh')
        assert adb('shell','sha256sum '+remote+'/helper.sh').split()[0]==sha(helper)
        put('passive.binding',f'v1 {run} {nonce} {boot} {fp} {fs} {fg} {deadline}\n')
        with connect() as f:
            report['dispatched']=True
            report['launch']=query(f,'toybox nohup toybox setsid sh '+remote+'/helper.sh --run '+run+' </dev/null >'+remote+'/helper.log 2>&1 &')
        ready=wait_record('passive.ready','ready','-',8);report['ready']=ready
        assert ready[11]=='/uid_0/pid_'+fp
        put('passive.challenge',f'v1 {run} {nonce} {challenge}\n')
        fresh=wait_record('passive.fresh','fresh',challenge,3);report['fresh']=fresh
        assert fresh[5:13]==ready[5:13]
        now=clock()
        assert 0<=now-int(fresh[13])<=2 and int(fresh[14])-now>=3
        pid=fresh[5]
        # Non-atomic numeric-PID API. Single fresh no-child native handshake;
        # never retry this write if the result is lost or the helper exits.
        report['attach_attempted']=True
        attach="now=$(/system/bin/x2v_guard_clock_20261012b); if [ \"$now\" -ge "+fresh[13]+" ] && [ \"$now\" -lt "+fresh[14]+" ] && [ ! -e "+remote+"/passive.stop ]; then if printf '%s\\n' "+pid+" > /acct/uid_0/pid_2279/cgroup.procs; then echo OWNED_ATTACH_WRITE_OK; else echo OWNED_ATTACH_WRITE_DENIED; fi; else echo OWNED_ATTACH_WINDOW_EXPIRED_OR_STOPPED; fi"
        report['attach_reply']=adb('shell',attach)
        assert 'OWNED_ATTACH_WRITE_OK' in report['attach_reply']
        migrated=wait_record('passive.migrated','migrated',challenge,4);report['migrated']=migrated
        assert migrated[5:11]==ready[5:11] and migrated[11]==TARGET
        def wait_query(side):
            expected=f'v1 {run} {nonce} {challenge} 0 0'
            until=time.monotonic()+10
            while time.monotonic()<until:
                raw=read('passive.query.'+side)
                if raw:
                    assert raw.strip()==expected,raw
                    state=read('passive.state.'+side)
                    count=read('passive.count.'+side)
                    for line in ['live_view_state = E_LiveViewState_Active(1)', 'liveview_transport_mode_current = E_LiveviewTransportMode_None(0)', 'stream_group = E_StreamGroup_Still16bit(0)', 'crop_mode_current = E_CropMode_None(0)']:
                        assert line in state.splitlines(),state
                    m=re.fullmatch(r'count = ([0-9]+)\s*',count);assert m,count
                    report['query_'+side]={'receipt':raw,'state':state,'count':int(m[1])}
                    return int(m[1])
                time.sleep(.2)
            raise RuntimeError('Read-only query did not complete: '+side)
        put('passive.go',f'v1 {run} {nonce} {challenge}\n')
        before_count=wait_query('before')
        hb=wait_record('passive.heartbeat','heartbeat',challenge,3)
        assert hb[5:13]==migrated[5:13] and 0<=clock()-int(hb[13])<=3
        report['heartbeat_before']=hb
        # Only the diagnosed factory service is restarted. Stock camera service,
        # GUI, sensor mode and media are left to their existing owners.
        report['factory_restart_attempted']=True
        report['factory_restart_reply']=adb('shell','setprop ctl.restart camera-test')
        time.sleep(3)
        put('passive.query-after',f'v1 {run} {nonce} {challenge}\n')
        after_count=wait_query('after');assert after_count>before_count
        hb=wait_record('passive.heartbeat','heartbeat',challenge,3)
        assert hb[5:13]==migrated[5:13] and 0<=clock()-int(hb[13])<=3
        report['heartbeat_after']=hb
        put('passive.stop',f'v1 {run} {nonce}\n');report['stop_sent']=True
        done=wait_record('passive.done','done',challenge,5);report['done']=done
        assert done[5:13]==migrated[5:13]
        time.sleep(.5)
        with connect() as f:
            report['after']=query(f,'pidof camera-service;pidof camera-gui;pidof camera-test;getprop init.svc.camera-test;mount | grep " /system "')
            lines=report['after'].strip().splitlines()
            assert lines[:2]==stock and lines[2]!=fp and lines[2].isdigit() and lines[3]=='running' and '(ro,' in lines[4]
            report['helper_absence']=query(f,'if [ ! -d /proc/'+pid+' ];then echo NATIVE_HELPER_ABSENT;else cat /proc/'+pid+'/stat;fi')
            assert report['helper_absence'].strip()=='NATIVE_HELPER_ABSENT'
        report['passed']=True
    except BaseException as e:report['failure']=repr(e)
    finally:
        if report['dispatched'] and not report.get('stop_sent'):
            try:put('passive.stop',f'v1 {run} {nonce}\n')
            except BaseException as e:report['stop_error']=repr(e)
        # Factory-only restart kills its old keepawake child. Restore that
        # pre-existing lease guard even if later test assertions fail.
        if report['factory_restart_attempted']:
            try:
                assert adb('shell','getprop init.svc.camera-service').strip()=='running'
                with connect() as f:
                    report['post_test_health']=query(f,'pidof camera-service;pidof camera-gui;pidof camera-test;getprop init.svc.camera-test')
                    state_path=ROOT/'local-verification/keepawake-state.json';ka=json.loads(state_path.read_text());oldpid=int(ka['camera_pid'])
                    absent=query(f,'if [ ! -d /proc/'+str(oldpid)+' ];then echo OLD_KEEPER_ABSENT;else cat /proc/'+str(oldpid)+'/stat;fi')
                    report['old_keeper_check']=absent
                    if absent.strip()=='OLD_KEEPER_ABSENT':
                        kp=query(f,'toybox nohup sh /blackbox/x2v-native-20261011/keepawake.sh </dev/null >/blackbox/x2v-native-20261011/keepawake.log 2>&1 & echo $!').strip()
                        assert kp.isdigit();ka['camera_pid']=int(kp);ka['camera_watchdog_restart_reason']='passive native owner factory-only restart proof';state_path.write_text(json.dumps(ka,indent=2)+'\n')
                        report['keepawake_pid']=int(kp)
                        report['keepawake_restore']=query(f,'odindb-send -s system -p screen_idle_timeout -- 0;odindb-send -s system -m set_screen_enabled -- true')
            except BaseException as e:
                report['post_test_health_error']=repr(e);report['passed']=False
        try:adb('pull',remote,str(out/'device-run'),timeout=20)
        except BaseException as e:report['pull_error']=repr(e)
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'report':str(out/'report.json'),'passed':report['passed'],'failure':report.get('failure')},indent=2))
    return 0 if report['passed'] else 1

if __name__=='__main__':raise SystemExit(main())
