"""Same verified RX16; first clip2s, second8s within unchanged native deadlines."""
from pathlib import Path
import hashlib,json,datetime,subprocess,sys
import isolated_resident_two_v16_dng_test as trial
R=Path(__file__).resolve().parents[1]
O=R/'native-video/experimental/source-session-isolated-resident-two-v16-dng'
P=R/'native-video/experimental/source-session-isolated-resident-two-v16-dng-eight'
H=R/'local-verification/source_session_execution_hold.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sys.argv[1:]==['--execute'] and not P.exists()
prior=json.loads((R/'native-video/outputs/source-isolated-175315/report.json').read_text())
assert prior['passed'] and prior['short_trial_24fps_delivery_pass']
assert json.loads((R/'native-video/outputs/source-isolated-175315/dng-sample-readback/decode-report.json').read_text())['passed']
f=json.loads((O/'freeze.json').read_text())
for n,h in f['runtime_files'].items():assert sha(O/n)==h,n
h=json.loads(H.read_text());assert h['released_modes']==[]
P.mkdir()
for n in f['runtime_files']:(P/n).write_bytes((O/n).read_bytes())
c=(P/'controller.sh').read_text();needle='receiver_user_stop_trial() {\n sleep 2\n';assert c.count(needle)==1
c=c.replace(needle,'receiver_user_stop_trial() {\n case "$CLIP_GEN" in 1) sleep 2;; 2) sleep 8;; *) return 1;; esac\n')
(P/'controller.sh').write_text(c)
b=(P/'bootstrap.sh').read_text();old=f['runtime_files']['controller.sh'];assert b.count(old)==1
(P/'bootstrap.sh').write_text(b.replace(old,sha(P/'controller.sh')))
for n in ['controller.sh','bootstrap.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
mode='isolated-resident-two-v16-dng-eight'
f.update(mode=mode,runtime_files={n:sha(P/n) for n in f['runtime_files']},perclip_trial_s=[2,8],parent_freeze_sha256=sha(O/'freeze.json'),root_review='Only second user-stop sleep2 to8, unchanged service/library/parser/source/mode47s constructor/10s clip cap/34s secondarm/150s watchdog. At latest secondarm31.54s, expected closure40.14s retains6.86s. First clip remains2s, no deadline extension.')
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h.update(released_modes=[mode],released_mode_scope='One2s then8s RX16 DNG continuation with unchanged caps/recovery',release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'))
H.write_text(json.dumps(h,indent=2)+'\n');trial.CANDIDATE=P;trial.MODE=mode
try:rc=trial.main()
finally:
 h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='Eight-second RX16 DNG packet consumed');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
