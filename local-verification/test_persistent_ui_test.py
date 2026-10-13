"""Offline runner regression: no USB, ADB, factory, native ELF or camera access."""
import importlib.util,json,tempfile,unittest,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('persistent_runner',HERE/'persistent_ui_test.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class Fake:
    def __init__(self,meta=None):self.calls=[];self.meta=meta;self.restored=False;self.byte_count=0;self.tail='';self.recover_calls=0
    def checked(self,cmd,capture_ms=5000):
        assert len((cmd+';echo X2V_RC:$?').encode())<=231,cmd
        self.calls.append(dict(command=cmd))
        if '/system/bin/true' in cmd:self.byte_count+=31;self.tail='BOOTSTRAP_LIBRARY_LOADED'
        if 'X2V_GUI_DRY_RUN=1' in cmd:self.byte_count+=32;self.tail='DRY_RUN_BUILD_PREFIX_VERIFIED'
        if cmd.startswith('tail -n1'):return self.tail
        if '--recover ' in cmd:self.restored=True;self.recover_calls+=1
        if 'nohup sh logger.sh' in cmd:return '500'
        return ''
    def factory(self,cmd,capture_ms=5000):
        assert len(cmd.encode())<=231,cmd
        if 'then wc -c' in cmd:return str(self.byte_count)
        return ''
    def digest(self,path):
        if path=='/system/bin/camera-gui':return m.GUI_SHA
        if path.endswith('.so'):return 'c9ffc917b2b777512810b66b9eba25874b6232b2da37715729bcaeef04c0f98b'
        for name,key in [('gui_session.sh','script_sha256'),('launch.sh','launch_sha256'),('payload/manifest.sha256','manifest_sha256')]:
            if path.endswith(name):return self.meta[key]
        raise AssertionError(path)
    def put(self,*args):pass
    def clock(self):return 100000
    def identity(self,pid):return dict(pid=pid,exe='/system/bin/camera-gui' if pid=='200' else '/system/bin/sh',starttime='100')
    def pull_text(self,*args):raise FileNotFoundError('bulk/logger disappeared')
class FaultRunner(m.Runner):
    def status(self,remote):return dict(phase='restored' if self.d.restored else 'running',**{'child.identity':'200 100','watchdog.identity':'300 100'})
    def json_control(self,*args):raise OSError('lease publish failed')
    def stop_bridge(self):self.d.calls.append(dict(command='TEST_BRIDGE_STOP'));return dict(terminated=True)
    def final_baseline(self):self.d.calls.append(dict(command='TEST_BASELINE'));return dict(service='380',init='running')
class Tests(unittest.TestCase):
    def test_mount_readonly_parse(self):
        self.assertTrue(m.system_readonly('/dev/block/x on /system type ext4 (ro,seclabel,relatime)'))
        self.assertFalse(m.system_readonly('/dev/block/x on /system type ext4 (rw,seclabel,relatime)'))
        self.assertFalse(m.system_readonly('/dev/block/x on /system/vendor type ext4 (ro,seclabel)'))
    def test_data_mediates_ssd_io(self):
        with tempfile.TemporaryDirectory() as td:
            device=m.Device(Path(td));commands=[];adb_calls=[]
            device.checked=lambda command,*args:commands.append(command) or ''
            device.adb=lambda *args,**kwargs:adb_calls.append(args) or ''
            device.pull_file(m.BULK+'/run/events.log',Path(td)/'events.log')
            self.assertTrue(any(command.startswith('cp '+m.BULK) for command in commands))
            self.assertTrue(adb_calls[0][1].startswith(m.ROOT+'/pull-cache/'))
            self.assertFalse(any('/mnt/media_rw/ssd/' in str(arg) for args in adb_calls for arg in args))
    def test_default_is_offline(self):
        # Same public entry. Neither device connector nor Device is constructed.
        result=subprocess.run([sys.executable,str(HERE/'persistent_ui_test.py')],cwd='/',capture_output=True,text=True,check=True)
        self.assertFalse(json.loads(result.stdout)['device_contacted'])
    def test_cleanup_independence(self):
        seen=[];report={}
        def fail():seen.append('log');raise KeyboardInterrupt('log unavailable')
        m.cleanup_steps(report,[('log',fail),('restore',lambda:seen.append('restore') or True),('bridge',lambda:seen.append('bridge') or True)])
        self.assertEqual(seen,['log','restore','bridge']);self.assertIn('log_error',report);self.assertTrue(report['restore'])
    def test_missing_log_and_disable_still_restore(self):
        config=m.validate(m.DEFAULT)
        with tempfile.TemporaryDirectory() as td:
            fake=Fake();runner=FaultRunner(config,Path(td),fake);runner.report['before']=dict(service='380')
            meta=config['metas'][0];remote=m.ROOT+'/runs/'+meta['runid'];bulk=m.BULK+'/'+meta['runid']
            result=runner.run_phase(config['permission'],meta,remote,bulk)
            self.assertEqual(fake.recover_calls,1);self.assertFalse(result['passed'])
            self.assertIn('lease_disabled_error',result);self.assertIn('final_log_error',result)
            self.assertEqual(result['restoration']['session']['phase'],'restored')
            commands=[item['command'] for item in fake.calls]
            self.assertLess(commands.index('TEST_BRIDGE_STOP'),commands.index('TEST_BASELINE'))
    def test_factory_length_and_mapping_pins(self):
        config=m.validate(m.DEFAULT)
        with tempfile.TemporaryDirectory() as td:
            fake=Fake();runner=m.Runner(config,Path(td),fake)
            runner.mapping(config['permission']);self.assertTrue(runner.report['loader_mapping']['gui_prefix_verified'])
            for package,meta in zip((config['permission'],config['record']),config['metas']):
                fake.meta=meta;runner.stage(package,meta)
    def test_bridge_independent_per_phase(self):
        config=m.validate(m.DEFAULT)
        class BridgeFake(Fake):
            alive=False
            def checked(self,cmd,*args):
                value=super().checked(cmd,*args)
                if 'nohup sh ' in cmd and 'bridge-launch' in cmd:self.alive=True
                if cmd=='kill -TERM 222':self.alive=False
                return value
            def factory(self,cmd,*args):
                if cmd.startswith('pidof x2v_'):return '222' if self.alive else ''
                return super().factory(cmd,*args)
            def digest(self,path):return m.BRIDGE_SHA
            def identity(self,pid):return dict(pid='222',exe=m.BRIDGE,starttime='100')
            def adb(self,*args):return ''
        with tempfile.TemporaryDirectory() as td:
            saved_project=m.PROJECT;m.PROJECT=Path(td)
            token=m.PROJECT/'native-video/outputs/runtime/session.token';token.parent.mkdir(parents=True);token.write_text('ab'*16)
            try:
                runner=m.Runner(config,Path(td),BridgeFake());runner.api=lambda *args:dict(phase='idle',rtp_confirmed_off=True,receiver_alive=False)
                for phase in ('one','two'):
                    bulk=m.BULK+'/'+phase;runner.start_bridge(bulk)
                    script=(Path(td)/'bridge-launch.sh').read_text()
                    self.assertIn('timeout 180',script);self.assertIn(bulk+'/bridge.log',script)
                    self.assertTrue(runner.stop_bridge()['terminated']);self.assertIsNone(runner.bridge_id)
                self.assertEqual(sum('nohup sh ' in c['command'] and 'bridge-launch' in c['command'] for c in runner.d.calls),2)
            finally:m.PROJECT=saved_project
    def test_record_bypass_refused(self):
        config=m.validate(m.DEFAULT)
        with tempfile.TemporaryDirectory() as td:
            with self.assertRaisesRegex(RuntimeError,'bypass'):m.Runner(config,Path(td),Fake()).api('/start',{})
    def test_event_tail_parsing(self):
        raw='old\nX2V_RECORD_ALBUM_QA {"runId":"one","event":"passed"} trailing\nX2V_RECORD_ALBUM_QA bad'
        self.assertEqual(m.parse_events(raw,'X2V_RECORD_ALBUM_QA '),[dict(runId='one',event='passed')])
if __name__=='__main__':unittest.main()
