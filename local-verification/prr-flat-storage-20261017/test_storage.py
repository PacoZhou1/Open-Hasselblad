import json,os,re,subprocess,tempfile,unittest
from pathlib import Path
D=Path(__file__).resolve().parent
class Storage(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);self.clips=self.root/'clips';self.clips.mkdir();self.live=self.root/'live';self.live.mkdir();(self.live/'preview.ppm').write_bytes(b'P6\n1 1\n255\n\x01\x02\x03')
  self.env={**os.environ,'CLIPS':str(self.clips),'LIVE':str(self.live),'X2V_FILE_SYNC':str(D/'build/sync-host'),'RUN':str(self.root/'run'),'REC':str(self.root/'rec')};(self.root/'rec').mkdir()
 def tearDown(self):self.tmp.cleanup()
 def sh(self,cmd,*args,check=True):
  return subprocess.run(['sh','-c','. "$1"; shift; '+cmd,'test',str(D/'flat-storage.sh'),*map(str,args)],env=self.env,text=True,capture_output=True,check=check)
 def new(self):return Path(self.sh('x2v_new_prr_dir').stdout.strip())
 def fill(self,p,error=0):
  (p/'clip.mov').write_bytes(b'unchanged compressed RAW sample'+bytes(range(255)))
  (p/'clip.json').write_text(json.dumps(dict(error=error,duration=2.0,bytes=284),separators=(',',':'))+'\n')
 def publish(self,p,check=True):return self.sh('x2v_publish_prr "$1"',p,check=check)
 def test_flat_and_same_inode(self):
  d=self.new();self.fill(d);before=(d/'clip.mov').stat();raw=(d/'clip.mov').read_bytes();p=Path(self.publish(d).stdout.strip())
  self.assertEqual(p.parent,self.clips);self.assertEqual(p.read_bytes(),raw);self.assertEqual(p.stat().st_ino,before.st_ino);self.assertFalse(d.exists());self.assertTrue((self.clips/'.x2v-meta'/f'{p.stem}.json').is_file());self.assertTrue((self.clips/'.x2v-meta'/f'{p.stem}.ppm').is_file());self.assertEqual(self.publish(d).stdout.strip(),str(p))
 def test_unique_same_second(self):
  a=self.new();b=self.new();self.assertNotEqual(a,b)
 def test_no_overwrite(self):
  d=self.new();self.fill(d);target=self.clips/(d.name+'.mov');target.write_bytes(b'previous take');self.assertNotEqual(self.publish(d,False).returncode,0);self.assertEqual(target.read_bytes(),b'previous take');self.assertTrue((d/'clip.mov').exists())
 def test_failed_capture_preserved(self):
  d=self.new();self.fill(d,5);self.assertNotEqual(self.publish(d,False).returncode,0);self.assertTrue((d/'clip.mov').exists());self.assertFalse((self.clips/(d.name+'.mov')).exists())
 def test_partial_not_published(self):
  d=self.new();self.fill(d);(d/'clip.mov').rename(d/'clip.partial.mov');self.assertNotEqual(self.publish(d,False).returncode,0);self.assertTrue((d/'clip.partial.mov').exists())
 def test_metadata_collision_preserved(self):
  d=self.new();self.fill(d);j=self.clips/'.x2v-meta'/(d.name+'.json');j.write_text('different');self.assertNotEqual(self.publish(d,False).returncode,0);self.assertEqual(j.read_text(),'different');self.assertTrue((d/'clip.mov').exists())
 def test_retry_after_metadata_publication(self):
  d=self.new();self.fill(d);j=self.clips/'.x2v-meta'/(d.name+'.json');j.write_bytes((d/'clip.json').read_bytes());self.assertEqual(self.publish(d).returncode,0)
 def test_dng_rejected_by_prr_publisher(self):
  d=self.clips/'X2V_DNG_20261017_123000';d.mkdir();self.fill(d);self.assertNotEqual(self.publish(d,False).returncode,0);self.assertTrue(d.exists())
 def test_catalog_old_new_dng(self):
  n=self.new();self.fill(n);new=Path(self.publish(n).stdout.strip())
  old=self.clips/'X2V_PRR_20261016_111111';old.mkdir();self.fill(old)
  dng=self.clips/'X2V_DNG_20261016_222222';dng.mkdir();self.fill(dng);(dng/'proxy.mp4').write_bytes(b'proxy')
  sup=(D/'supervisor.sh').read_text();func='\n'.join(re.search(r'^'+name+r'\(\) \{\n.*?^\}',sup,re.M|re.S).group(0) for name in ['catalog_entry','write_catalog'])
  r=subprocess.run(['sh','-c',func+'\nwrite_catalog test'],env=self.env,text=True,capture_output=True);self.assertEqual(r.returncode,0,r.stderr)
  cat=json.loads((self.root/'rec/catalog.json').read_text());entries={e['id']:e for e in cat['clips']}
  self.assertEqual(len(entries),3);self.assertEqual(entries[new.stem]['source'],str(new));self.assertEqual(entries[old.name]['source'],str(old/'clip.mov'));self.assertEqual(entries[dng.name]['source'],str(dng/'proxy.mp4'));self.assertEqual(entries[dng.name]['format'],'CinemaDNG')
if __name__=='__main__':
 suite=unittest.defaultTestLoader.loadTestsFromTestCase(Storage);r=unittest.TextTestRunner(verbosity=2).run(suite)
 (D/'host-results.json').write_text(json.dumps({'tests':r.testsRun,'failures':len(r.failures),'errors':len(r.errors),'passed':r.wasSuccessful(),'camera_test':False},indent=2)+'\n')
 raise SystemExit(not r.wasSuccessful())
