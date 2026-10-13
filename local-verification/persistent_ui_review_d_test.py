"""Offline by default. Root alone executes bounded data/SSD GUI permission + UI QA.

No direct HTTP /start: recording comes only from the frozen QML handler chain.
"""
import argparse,hashlib,importlib.util,json,re,subprocess,sys,time
from pathlib import Path
from urllib.request import Request,urlopen
PROJECT=Path(__file__).resolve().parents[1]
DEFAULT=PROJECT/'native-video/simulator/evidence/device-record-album-data-review-d'
SERIAL='123456789ABCDEF'
ROOT='/data/x2v-native-20261012'
BULK='/mnt/media_rw/ssd/X2V_AUDIT'
INBOX=ROOT+'/runner-inbox'
LOADER_SHAS={'c9ffc917b2b777512810b66b9eba25874b6232b2da37715729bcaeef04c0f98b','f88756fb2445be43626e2ba18eedb3e54035773c25e7ffe15ea32c15d38143ce'}
GUI_SHA='b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b'
BRIDGE='/system/bin/x2v_session_bridge_20261011d'
BRIDGE_SHA='4df4993e93b5136ad1d3c32597b0988027eb0881d3bd8e0e517da8ef608bfcea'

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load_module(path,name):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def validate(candidate):
    frozen=json.loads((candidate/'freeze.json').read_text())
    if sha(candidate/'source-manifest.json')!=frozen['source_manifest_sha256']:raise ValueError('Freeze manifest SHA differs')
    manifest=json.loads((candidate/'source-manifest.json').read_text())
    actual={p.relative_to(candidate).as_posix():sha(p) for p in candidate.rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.name not in ('source-manifest.json','freeze.json')}
    if actual!=manifest['files']:raise ValueError('Frozen candidate/source/evidence differs')
    prep=load_module(candidate/'prepare.py','persistent_prepare')
    permission=candidate/'prepared'/frozen['permission_run_id'];record=candidate/'prepared'/frozen['record_run_id']
    metas=[prep.verify_package(p) for p in (permission,record)]
    if metas[0]['purpose']!='permission-probe' or metas[1]['purpose']!='record-qa' or metas[0]['runid']==metas[1]['runid']:raise ValueError('Distinct permission/record identities required')
    for m in metas:
        if m['seconds']!=85 or m['remote_root']!=ROOT or m['bulk_root']!=BULK or m['loader_sha256'] not in LOADER_SHAS or m['camera_gui_sha256']!=GUI_SHA:raise ValueError('Unreviewed path/build/lease')
    controller=(candidate/'gui_session.sh').read_text()
    loader=re.search(r'^LOADER=(.+)$',controller,re.M).group(1)
    # No CLI override. System fallback requires its own newly frozen controller/package.
    if loader not in (ROOT+'/libx2v_gui_bootstrap_20261012_data.so','/system/lib64/libx2v_gui_bootstrap_20261012_data.so'):raise ValueError('Loader outside immutable reviewed namespace')
    if 'toybox flock -n 8 8>&9' not in controller or '[ "$SESSION_SECONDS" -eq 85 ]' not in controller:raise ValueError('Recovery contract absent')
    if metas[0]['loader_sha256']!=metas[1]['loader_sha256']:raise ValueError('Permission/record loader differ')
    lease=load_module(candidate/'make_lease.py','persistent_lease')
    test=lease.make(record,1000,1000,True)
    if test['runId']!=metas[1]['runid']:raise ValueError('Lease identity differs')
    return dict(loader_sha=metas[0]['loader_sha256'],candidate=candidate,permission=permission,record=record,metas=metas,loader=loader,lease=lease,nonce=json.loads((candidate/'identity.json').read_text())['nonce'])

def system_readonly(text):
    options=[set(match.group(1).split(',')) for line in text.splitlines() for match in [re.search(r' on /system type \S+ \(([^)]*)\)',line)] if match]
    return bool(options) and all('ro' in value and 'rw' not in value for value in options)

def cleanup_steps(report,steps):
    """Every step runs even if prior log collection/disable/save is interrupted."""
    for name,operation in steps:
        try:report[name]=operation()
        except BaseException as exc:report[name+'_error']=repr(exc)

def parse_events(raw,tag):
    rows=[]
    for line in raw.splitlines():
        if tag in line:
            try:rows.append(json.JSONDecoder().raw_decode(line.split(tag,1)[1])[0])
            except ValueError:pass
    return rows

class Device:
    def __init__(self,out):self.out=out;self.calls=[]
    def adb(self,*args,timeout=20):
        return subprocess.run(['adb','-s',SERIAL,*map(str,args)],capture_output=True,text=True,timeout=timeout,check=True).stdout
    def factory(self,command,capture_ms=5000):
        if len(command.encode())>231:raise ValueError('Factory command exceeds 231 bytes')
        from factory_session import connect
        with connect() as f:value=f.factory_shell(command,capture_ms=capture_ms)
        self.calls.append(dict(command=command,output=value));return value
    def checked(self,command,capture_ms=5000):
        text=self.factory(command+';echo X2V_RC:$?',capture_ms)
        matched=re.search(r'X2V_RC:(\d+)\s*$',text)
        if not matched or matched[1]!='0':raise RuntimeError('Factory command failed: '+command+'; '+text)
        return text[:matched.start()].rstrip()
    def put(self,local,remote):
        self.adb('push',local,remote)
    def identity(self,pid):
        if not re.fullmatch(r'[0-9]+',str(pid)):raise ValueError('Expected exactly one PID')
        raw=self.factory(f'readlink /proc/{pid}/exe;cat /proc/{pid}/stat',3000);lines=raw.strip().splitlines()
        if len(lines)!=2:raise RuntimeError('Identity unavailable')
        tail=lines[1].rsplit(') ',1)[1].split()
        if tail[0]=='Z':raise RuntimeError('Process is zombie')
        return dict(pid=str(pid),exe=lines[0],starttime=tail[19])
    def digest(self,path):
        raw=self.checked('sha256sum '+path);digest=raw.split()[0]
        if not re.fullmatch('[0-9a-f]{64}',digest):raise ValueError('Bad device digest')
        return digest
    def clock(self):return int(self.adb('shell','date +%s').strip())*1000
    def pull_file(self,remote,local):
        source=remote
        if remote.startswith('/mnt/media_rw/ssd/'):
            cache=ROOT+'/pull-cache/'+hashlib.sha256(remote.encode()).hexdigest()[:16]
            self.checked('mkdir -p '+ROOT+'/pull-cache')
            self.checked('test "$(wc -c <'+remote+')" -le 67108864')
            self.checked(f'cp {remote} {cache}.tmp')
            self.checked(f'mv {cache}.tmp {cache}')
            source=cache
        elif not remote.startswith(ROOT+'/'):raise ValueError('Pull outside owned namespace')
        self.adb('pull',source,local)
    def pull_text(self,remote,local):
        self.pull_file(remote,local);return local.read_text(errors='replace')

class Runner:
    def __init__(self,config,out,device):
        self.c=config;self.out=out;self.d=device;self.bridge_id=None;self.forwarded=False;self.token='';self.seq=0
        self.report=dict(schema=1,passed=False,device_contacted=True,physical_touch_verified=False,physical_shutter_verified=False,phases=[])
    def save(self):
        # No token body is ever placed in reports or factory shell command text.
        (self.out/'report.json').write_text(json.dumps(self.report,indent=2)+'\n')
        (self.out/'device-commands.json').write_text(json.dumps(self.d.calls,indent=2)+'\n')
    def api(self,path,data=None):
        if path=='/start':raise RuntimeError('Direct HTTP recording bypass forbidden')
        req=Request('http://127.0.0.1:18762'+path,data=None if data is None else json.dumps(data).encode(),headers={'X-X2V-Token':self.token,'Content-Type':'application/json'})
        return json.loads(urlopen(req,timeout=3).read())
    def baseline(self):
        from highres_one_frame import STATE,check_state
        value=dict(state=self.d.factory(STATE),service=self.d.checked('pidof camera-service'),gui=self.d.checked('pidof camera-gui'),init=self.d.checked('getprop init.svc.camera-gui'),mount=self.d.checked('mount | grep " /system "'))
        if not check_state(value['state']) or value['init']!='running' or not system_readonly(value['mount']):raise RuntimeError('Stock baseline is not Active/None/GUI running/system ro')
        return value
    def publish(self,source,destination):
        self.seq+=1;inbox=f'{INBOX}/config-{self.seq}.json'
        self.d.put(source,inbox)
        self.d.checked(f'cp {inbox} {destination}.tmp')
        self.d.checked(f'mv {destination}.tmp {destination}')
    def json_control(self,value,name):
        local=self.out/f'control-{self.seq+1}-{name}';local.write_text(json.dumps(value)+'\n');self.publish(local,ROOT+'/'+name)
    def stage(self,package,meta):
        remote=ROOT+'/runs/'+meta['runid'];inbox=INBOX+'/'+meta['runid'];bulk=BULK+'/'+meta['runid']
        self.d.checked('test ! -e '+remote)
        self.d.checked('test ! -e '+inbox)
        self.d.checked('test ! -e '+bulk)
        self.d.checked('mkdir -p '+ROOT+'/runs '+INBOX+' '+BULK)
        self.d.checked('mkdir '+remote+' '+inbox+' '+bulk)
        for name in ('payload','gui_session.sh','launch.sh'):
            self.d.put(package/name,inbox+'/'+name)
            self.d.checked(f'cp -R {inbox}/{name} {remote}/{name}')
        for name,key in [('gui_session.sh','script_sha256'),('launch.sh','launch_sha256'),('payload/manifest.sha256','manifest_sha256')]:
            if self.d.digest(remote+'/'+name)!=meta[key]:raise RuntimeError('Staged package hash differs')
        self.d.checked(f'cd {remote}/payload && sha256sum -c manifest.sha256',10000)
        self.d.checked(f'test -z "$(find {remote}/payload/gui -type l -print)"')
        self.publish(package/'disabled-audit-config.json',ROOT+'/audit-config.json')
        self.publish(package/'disabled-record-album-qa.json',ROOT+'/record-album-qa.json')
        return remote,bulk
    def mapping(self,package):
        loader=self.c['loader'];local=package/Path(loader).name
        if loader.startswith(ROOT+'/'):
            inbox=INBOX+'/loader.so';self.d.put(local,inbox)
            self.d.checked(f'cd {ROOT} && if [ ! -e {Path(loader).name} ];then cp {inbox} {Path(loader).name};fi')
        # System loader is never installed by this runner: root stages reviewed immutable artifact separately.
        if self.d.digest(loader)!=self.c['loader_sha']:raise RuntimeError('Loader SHA differs')
        if self.d.digest('/system/bin/camera-gui')!=GUI_SHA:raise RuntimeError('Camera GUI SHA differs')
        log=ROOT+'/bootstrap.log'
        def size():return int(self.d.factory(f'if [ -f {log} ];then wc -c <{log};else echo 0;fi').strip())
        before=size()
        self.d.checked('timeout 3 env X2V_GUI_ENABLE=0 LD_PRELOAD='+loader+' /system/bin/true',5000)
        if size()<=before or self.d.checked('tail -n1 '+log)!='BOOTSTRAP_LIBRARY_LOADED':raise RuntimeError('Fresh constructor mapping evidence missing')
        self.report['loader_mapping']=dict(path=loader,sha256=self.c['loader_sha'],constructor_fresh=True)
        before=size()
        # Frozen loader can fall through on dry mismatch; exact GUI + loader pins are mandatory.
        self.d.checked('timeout 5 env X2V_GUI_ENABLE=1 X2V_GUI_DRY_RUN=1 LD_PRELOAD='+loader+' /system/bin/camera-gui',7000)
        if size()<=before or self.d.checked('tail -n1 '+log)!='DRY_RUN_BUILD_PREFIX_VERIFIED':raise RuntimeError('Fresh matched GUI prefix dry-run evidence missing')
        self.report['loader_mapping']['gui_prefix_verified']=True
    def start_bridge(self,bulk):
        if self.d.factory('pidof x2v_session_bridge_20261011d || true').strip():raise RuntimeError('Bridge already exists; not owned')
        if self.d.digest(BRIDGE)!=BRIDGE_SHA:raise RuntimeError('Bridge SHA differs')
        source=PROJECT/'native-video/outputs/runtime/session.token';self.token=source.read_text().strip()
        if not re.fullmatch(r'[0-9a-f]{32,64}',self.token):raise ValueError('Token malformed')
        inbox=INBOX+'/session.token';self.d.put(source,inbox)
        self.d.checked('chmod 600 '+inbox);self.d.checked(f'cp {inbox} {ROOT}/session.token');self.d.checked('chmod 600 '+ROOT+'/session.token')
        script=self.out/'bridge-launch.sh';script.write_text('#!/system/bin/sh\nexec timeout 180 '+BRIDGE+' --token-file '+ROOT+'/session.token >'+bulk+'/bridge.log 2>&1\n')
        self.d.put(script,INBOX+'/bridge-launch.sh');self.d.checked(f'cp {INBOX}/bridge-launch.sh {ROOT}/bridge-launch.sh')
        self.d.checked(f'toybox nohup sh {ROOT}/bridge-launch.sh >{ROOT}/bridge-launch.log 2>&1 & echo $!')
        deadline=time.monotonic()+5
        while time.monotonic()<deadline:
            pid=self.d.factory('pidof x2v_session_bridge_20261011d || true').strip()
            if pid:break
            time.sleep(.2)
        self.bridge_id=self.d.identity(pid)
        if self.bridge_id['exe']!=BRIDGE:raise RuntimeError('Bridge exe differs')
        self.report['bridge_identity']=self.bridge_id
        self.d.adb('forward','tcp:18762','tcp:18761');self.forwarded=True
        state=self.api('/state')
        if state['phase'] not in ('idle','saved') or not state['rtp_confirmed_off'] or state['receiver_alive']:raise RuntimeError('Bridge not idle')
        self.report['bridge_initial']=state
    def status(self,remote):
        raw=self.d.factory(f'for f in phase child.identity watchdog.identity restored-stock.pids;do echo FILE:$f;cat {remote}/$f 2>/dev/null || true;done',3000)
        result={};name=None
        for line in raw.splitlines():
            if line.startswith('FILE:'):name=line[5:];result[name]=''
            elif name:result[name]+=line+'\n'
        return {k:v.strip() for k,v in result.items()}
    def run_phase(self,package,meta,remote,bulk):
        phase=dict(purpose=meta['purpose'],runId=meta['runid'],passed=False,bridge_identity=self.bridge_id);self.report['phases'].append(phase)
        out=self.out/meta['runid'];out.mkdir();launched=False
        def events():
            raw=self.d.pull_text(bulk+'/record-events.log',out/'events.log')
            phase['storage_events']=parse_events(raw,'X2V_PERSISTENT_STORAGE ')
            phase['qa_events']=[e for e in parse_events(raw,'X2V_RECORD_ALBUM_QA ') if e.get('runId')==meta['runid']]
            phase['controls']=parse_events(raw,'X2V_CONTROL ');phase['frames']=parse_events(raw,'X2V_SCREEN_FRAME ')
            phase['qml_errors']=[line for line in raw.splitlines() if re.search(r'(ReferenceError|TypeError|SyntaxError):',line)]
            if phase['qml_errors']:raise RuntimeError('QML runtime error')
            return raw
        def wait(predicate,seconds):
            deadline=time.monotonic()+seconds
            while time.monotonic()<deadline:
                events()
                if predicate():return
                time.sleep(.4)
            raise RuntimeError('Timed out waiting for phase evidence')
        def disable():
            self.json_control(dict(enabled=False,expiresAtMs=0), 'record-album-qa.json')
            self.json_control(dict(enabled=False,expiresAtMs=0), 'audit-config.json')
            return True
        def restore():
            self.d.checked(f'sh {remote}/gui_session.sh --recover {meta["runid"]}',15000)
            state=self.status(remote);baseline=self.final_baseline()
            if state.get('phase')!='restored' or baseline['service']!=self.report['before']['service']:raise RuntimeError('Restoration/service readback failed')
            return dict(session=state,baseline=baseline)
        try:
            started=self.d.clock();launched=True # uncertain dispatch still requires finally recovery attempt
            self.d.checked(f'cd {remote} && toybox nohup sh launch.sh >session.log 2>&1 & echo $!',3000)
            deadline=time.monotonic()+12
            while time.monotonic()<deadline:
                status=self.status(remote)
                if status.get('phase')=='running':break
                if status.get('phase','').startswith('error_') or status.get('phase')=='restored':raise RuntimeError('GUI exited before running: '+str(status))
                time.sleep(.25)
            else:raise RuntimeError('GUI launch deadline')
            child=status['child.identity'].split();watchdog=status['watchdog.identity'].split()
            gui=self.d.identity(child[0]);wd=self.d.identity(watchdog[0])
            if gui['exe']!='/system/bin/camera-gui' or gui['starttime']!=child[1] or wd['starttime']!=watchdog[1]:raise RuntimeError('GUI/watchdog identities differ')
            phase['gui_identity']=gui;phase['watchdog_identity']=wd
            logger=self.out/(meta['runid']+'-logger.sh')
            logger.write_text('#!/system/bin/sh\n(timeout 85 logcat --pid='+gui['pid']+' -v epoch -T 1000 camera-gui:I "*:S"|head -c8388608) >'+bulk+'/record-events.log 2>&1\n')
            self.d.put(logger,INBOX+'/logger.sh');self.d.checked(f'cp {INBOX}/logger.sh {remote}/logger.sh')
            logger_pid=self.d.checked(f'cd {remote} && toybox nohup sh logger.sh >logger-launch.log 2>&1 & echo $!').strip()
            phase['logger_identity']=self.d.identity(logger_pid)
            identity_file=out/'logger.identity';identity_file.write_text(logger_pid+' '+phase['logger_identity']['starttime']+'\n');self.d.put(identity_file,INBOX+'/logger.identity');self.d.checked(f'cp {INBOX}/logger.identity {remote}/logger.identity')
            logger_deadline=time.monotonic()+4
            while time.monotonic()<logger_deadline:
                try:self.d.checked('test -f '+bulk+'/record-events.log');break
                except RuntimeError:time.sleep(.2)
            else:raise RuntimeError('Logger did not create bounded events file')
            # PID and fresh nonce bind backlog events to this exact GUI/candidate.
            wait(lambda:any(e.get('event')=='token_read' and e.get('tokenValid') for e in phase['storage_events']) and all(any(e.get('source')=='file://'+ROOT+'/'+name and e.get('probeNonceMatched') for e in phase['storage_events']) for name in ('audit-config.json','record-album-qa.json')),12)
            if any(e.get('event')=='armed' for e in phase['qa_events']):raise RuntimeError('QA armed before valid lease')
            if meta['purpose']=='permission-probe':
                now=self.d.clock();audit_id=meta['runid']+'-save';audit_dir=BULK+'/'+audit_id
                self.d.checked('test ! -e '+audit_dir+' && mkdir '+audit_dir)
                self.json_control(dict(enabled=True,expiresAtMs=now+6000,runId=audit_id,seconds=1,fps=1,format='bmp'),'audit-config.json')
                wait(lambda:any(e.get('runId')==audit_id and e.get('success') and e.get('frameNumber')==1 for e in phase['frames']),8)
                frame=next(e for e in phase['frames'] if e.get('runId')==audit_id and e.get('success'))
                path=frame['path'];expected=audit_dir+'/frame-000001.bmp'
                if path!=expected:raise RuntimeError('Unexpected screenshot path')
                self.d.pull_file(path,out/'permission-frame.bmp');digest=self.d.digest(path)
                if sha(out/'permission-frame.bmp')!=digest:raise RuntimeError('Screenshot device/host digest differs')
                phase['ssd_save']=dict(path=path,sha256=digest,frame=frame)
                phase['flow_completed']=True
            else:
                phase['catalog_before']=self.api('/catalog')
                if phase['catalog_before'].get('truncated') or not phase['catalog_before'].get('storage_available'):raise RuntimeError('Catalog/storage not complete')
                if self.d.identity(logger_pid)!=phase['logger_identity']:raise RuntimeError('Run logger exited or changed before arm')
                now=self.d.clock();lease=self.c['lease'].make(package,started,now,True)
                phase['lease']=lease;self.json_control(lease,'record-album-qa.json')
                def complete():
                    failed=next((e for e in phase['qa_events'] if e.get('event')=='failed'),None)
                    if failed:raise RuntimeError('UI flow failed: '+json.dumps(failed))
                    return any(e.get('event')=='passed' for e in phase['qa_events'])
                wait(complete,max(1,(lease['expiresAtMs']-now)/1000))
                rows=phase['qa_events'];required=('armed','recording_red_border','new_saved_clip','latest_single_preview','player_playing','player_idle','passed')
                for name in required:
                    if not any(e['event']==name for e in rows):raise RuntimeError('Missing run-specific event: '+name)
                saved=next(e['detail'] for e in rows if e['event']=='new_saved_clip');session=next(e['detail']['sessionId'] for e in rows if e['event']=='player_playing')
                if saved['id'] in {x['id'] for x in phase['catalog_before']['clips']} or not 0<saved['durationMs']<=5000:raise RuntimeError('Fresh clip/duration failed')
                releases=[e for e in phase['controls'] if e.get('event')=='playback_native' and e.get('detail',{}).get('stage')=='release_complete' and e['detail'].get('sessionId')==session]
                if not releases:raise RuntimeError('Actual native release_complete absent')
                phase['new_clip']=saved;phase['player_release']=releases[-1];phase['catalog_after']=self.api('/catalog');phase['flow_completed']=True
        except BaseException as exc:phase['failure']=repr(exc)
        finally:
            steps=[('lease_disabled',disable)]
            if launched:steps += [('final_log',lambda:(events(),True)[1]),('bridge_cleanup',self.stop_bridge),('restoration',restore)]
            cleanup_steps(phase,steps)
            phase['passed']=bool(phase.get('flow_completed') and not phase.get('failure') and not any(k.endswith('_error') for k in phase) and phase.get('restoration'))
            self.save()
        return phase
    def stop_bridge(self):
        if not self.bridge_id:return dict(owned=False)
        result=self.api('/stop',{});deadline=time.monotonic()+10
        while time.monotonic()<deadline:
            state=self.api('/state')
            if state['rtp_confirmed_off'] and not state['receiver_alive']:break
            time.sleep(.2)
        else:raise RuntimeError('Producer/receiver stop unconfirmed; bridge termination refused')
        current=self.d.identity(self.bridge_id['pid'])
        if current!=self.bridge_id:raise RuntimeError('Bridge ownership changed')
        self.d.checked('kill -TERM '+current['pid'])
        deadline=time.monotonic()+4
        while time.monotonic()<deadline:
            if not self.d.factory('pidof x2v_session_bridge_20261011d || true').strip():break
            time.sleep(.2)
        else:raise RuntimeError('Owned bridge did not exit')
        self.bridge_id=None
        return dict(stop=result,final=state,terminated=True)
    def final_baseline(self):
        from highres_one_frame import STATE
        state=self.d.factory(STATE)
        if 'E_LiveViewState_Off(0)' in state and 'E_LiveviewTransportMode_None(0)' in state:
            self.d.checked('timeout 4 odindb-send -s camera -m set_live_view true');time.sleep(.5)
        result=self.baseline()
        if result['service']!=self.report['before']['service']:raise RuntimeError('Camera service changed')
        return result
    def execute(self,mode):
        try:
            # Reject source/I/O overlap; root still owns scheduling, these are not a cross-domain atomic mutex.
            self.d.checked('test ! -e /data/x2v-source-20261012/source-session.lock')
            self.d.checked('test ! -e '+ROOT+'/io-benchmark.lock')
            self.report['before']=self.baseline()
            self.d.checked('test ! -e '+ROOT+'/gui-session.lock')
            self.d.checked('test ! -e /blackbox/x2v-native-20261011/gui-session.lock')
            self.d.checked('mkdir -p '+ROOT+'/runs '+INBOX+' '+BULK)
            # SSD space, not blackbox headroom: 256MiB max capture +128MiB reserve +8MiB log.
            df=self.d.checked('df -k '+BULK);available=int(df.strip().splitlines()[-1].split()[-3])*1024
            if available<392*1024*1024:raise RuntimeError('Insufficient SSD audit budget')
            self.report['ssd_available_bytes']=available
            self.mapping(self.c['permission'])
            for package,meta in zip((self.c['permission'],self.c['record']),self.c['metas']):
                if meta['purpose']=='record-qa' and mode!='all':break
                remote,bulk=self.stage(package,meta)
                self.start_bridge(bulk)
                result=self.run_phase(package,meta,remote,bulk)
                if not result['passed']:raise RuntimeError('Phase failed: '+meta['purpose'])
        except BaseException as exc:self.report['failure']=repr(exc)
        finally:
            # Each cleanup remains independent even if log pull, lease write or API fails.
            steps=[('bridge_cleanup',self.stop_bridge)]
            if 'before' in self.report:steps.append(('final_baseline',self.final_baseline))
            if self.forwarded:steps.append(('forward_removed',lambda:(self.d.adb('forward','--remove','tcp:18762'),True)[1]))
            cleanup_steps(self.report,steps)
            self.report['passed']=bool(self.report['phases'] and all(p['passed'] for p in self.report['phases']) and not self.report.get('failure') and not any(k.endswith('_error') for k in self.report) and self.report.get('final_baseline'))
            self.save()
        return self.report

def main(argv=None):
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--candidate-root',type=Path,default=DEFAULT);ap.add_argument('--phase',choices=['permission','all'],default='permission');ap.add_argument('--output',type=Path);ap.add_argument('--execute',action='store_true');a=ap.parse_args(argv)
    config=validate(a.candidate_root.resolve())
    if not a.execute:
        print(json.dumps(dict(prepared_only=True,device_contacted=False,phase=a.phase,loader=config['loader'],loader_sha256=config['loader_sha'],packages=[str(config['permission']),str(config['record'])],required_gates=['constructor mapping','exact GUI SHA + prefix dry-run','disabled QML token and nonce reads','one SSD frame and recovery','distinct leased recording run if --phase all']),indent=2));return 0
    output=(a.output or PROJECT/'native-video/outputs'/('persistent-ui-'+time.strftime('%Y%m%d-%H%M%S'))).resolve()
    if output==config['candidate'] or config['candidate'] in output.parents:raise ValueError('Device evidence must not modify frozen candidate')
    output.mkdir(parents=True,exist_ok=False)
    result=Runner(config,output,Device(output)).execute(a.phase)
    print(json.dumps(dict(passed=result['passed'],report=str(output/'report.json'),failure=result.get('failure')),indent=2));return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
