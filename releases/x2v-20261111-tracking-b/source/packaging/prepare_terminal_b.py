"""Freeze accepted AB AF; package only terminal-loss UI cleanup for release B."""
from pathlib import Path
import hashlib,json,shutil,subprocess,sys

P=Path(__file__).resolve().parent;R=P.parents[2]
A=R/'native-video/experimental/x2v-touch-tracking-20261111-bfm-cache-trial'
B=R/'native-video/experimental/x2v-touch-tracking-20261111-terminal-loss-trial';B.mkdir(exist_ok=True)
m=json.loads((A/'manifest.json').read_text());remote='/blackbox/'+B.name
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for n in ['imx861bqr_hb722.conf','imx861bqr_hb722.sp',m['watcher_name']]:shutil.copy2(A/n,B/n)
shutil.copytree(A/'gui',B/'gui',dirs_exist_ok=True)
for p in (P/'lost-terminal/gui').iterdir():shutil.copy2(p,B/'gui'/p.name)
session='x2v_video_session_20261111b.sh';s=(A/m['session_name']).read_text();assert m['remote'] in s
(B/session).write_text(s.replace(m['remote'],remote))
loader='libx2v_gui_tracking_20261111b.so';gui='/blackbox/x2v-native-20261011/gui-tracking-b'
c=(A/'gui_bootstrap_touch.c').read_text().replace('/gui-touch-y/','/gui-tracking-b/').replace('bootstrap-touch-y.log','bootstrap-tracking-b.log')
(B/'gui_bootstrap_touch.c').write_text(c)
cmd=[sys.executable,'-m','ziglang','cc','-target','aarch64-linux-musl','-std=c11','-O2','-fPIC','-shared','-nostdlib','-Wl,-z,noexecstack','-Wl,-soname,'+loader,str(B/'gui_bootstrap_touch.c'),'-o',str(B/loader)]
r=subprocess.run(cmd,capture_output=True,text=True);assert not r.returncode,r.stderr
b=(A/'product_boot_touch_trial.sh').read_text()
for old,new in [(m['session_name'],session),(m['loader_name'],loader),('gui-touch-y','gui-tracking-b'),(m['files'][m['loader_name']],sha(B/loader))]:
 assert old in b,old;b=b.replace(old,new)
(B/'product_boot_touch_trial.sh').write_text(b)
for p in B.glob('*.sh'):subprocess.run(['sh','-n',str(p)],check=True)
m.update(version='20261111b',remote=remote,UI_device_path=gui,session_name=session,loader_name=loader,
 temporary_only=True,permanent_boot_changed=False,camera_executed=False,
 AF_binary_user_accepted=True,AF_binary_unchanged_from='20261111ab',
 AF_acceptance='User: tracking performance and lock speed satisfactory; approve final install',
 UI_change='A genuine loss ends the lease and native AF session; discard recovered packets; new tap required; clear touch-origin state')
assert sha(Path(m['copy_library']['source']))==m['copy_library']['sha256']
m['files']={p.name:sha(p) for p in B.iterdir() if p.is_file() and p.name not in ['manifest.json','STATUS.md']}
(B/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2));print(B)
