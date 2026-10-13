"""Root-owned one-shot RAW+ISP metadata trial, default offline."""
from pathlib import Path
import hashlib,json,sys,datetime
import isolated_resident_two_v16_dng_test as trial
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-session-isolated-two-v18-isp';H=R/'local-verification/source_session_execution_hold.json';mode='isolated-two-v18-isp';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
if sys.argv[1:]!=['--execute']:print('OFFLINE RX18 dual ISP trial');raise SystemExit(0)
f=json.loads((P/'freeze.json').read_text());assert f['hard_hold'] and not f['execution_approved']
assert json.loads((R/'native-video/outputs/source-isp-v18-stage-195849/report.json').read_text())['passed']
for n,h in f['runtime_files'].items():assert sha(P/n)==h
c=(P/'controller.sh').read_text();old=f['runtime_files']['controller.sh']
for role in [0,1]:
 a=f'op stop_dcam_stream {role} && wait_idle && graph_state && q_owner_same || {{';assert c.count(a)==1
 c=c.replace(a,f'op stop_dcam_stream {role} && wait_idle && graph_state && q_owner_same &&\n        grep -qx \'stream_group = E_StreamGroup_LiveviewRawCalib(13)\' "$RUN/reply.state" || {{')
(P/'controller.sh').write_text(c)
b=(P/'bootstrap.sh').read_text();assert b.count(old)==1;(P/'bootstrap.sh').write_text(b.replace(old,sha(P/'controller.sh')))
import subprocess
for n in ['controller.sh','bootstrap.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f.update(execution_approved=True,hard_hold=False,runtime_files={n:sha(P/n) for n in f['runtime_files']},root_review='New geometry/native dimensions bounded; calibration auditor found no known hardware blocker. Color observer borrowed metadata/static atomics only; no callback IO. Codec delta review PASS; dual stop audit PASS tightened each individual stop group13. Original RAW writing/ACK16/caps/owner recovery retained. Native trial may fail; no retries of unknown native writes.')
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
h=json.loads(H.read_text());assert h['released_modes']==[];h.update(released_modes=[mode],released_mode_scope='One bounded two2s RAW+ISP metadata trial; no H264/no boot changes',release_time=datetime.datetime.now().astimezone().isoformat(),released_packet_freeze_sha256=sha(P/'freeze.json'));H.write_text(json.dumps(h,indent=2)+'\n')
trial.CANDIDATE=P;trial.MODE=mode
try:rc=trial.main()
finally:
 h=json.loads(H.read_text());h.update(released_modes=[],revocation_reason='RX18 dual ISP one-shot consumed');H.write_text(json.dumps(h,indent=2)+'\n')
raise SystemExit(rc)
