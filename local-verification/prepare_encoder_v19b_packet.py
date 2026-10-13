from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path(__file__).resolve().parents[1];E=R/'native-video/experimental';O=E/'source-session-isolated-two-v19-encoder';P=E/'source-session-isolated-two-v19b-encoder';C=E/'raw-hardware-proxy-candidate-b/config';assert not P.exists();P.mkdir();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
f=json.loads((O/'freeze.json').read_text());mode='isolated-two-v19b-encoder'
for n in f['runtime_files']:shutil.copy2((C if n.endswith(('.sp','.conf')) else O)/n,P/n)
c=(P/'controller.sh').read_text().replace('isolated-two-v19-encoder',mode)
for n in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:c=c.replace(f['runtime_files'][n],sha(P/n))
a='target_setup_evidence && receiver_arm && receiver_user_stop_trial && receiver_frame && encoder_start && receiver_arm_second';assert c.count(a)==1
c=c.replace(a,'target_setup_evidence && encoder_start && receiver_arm && receiver_user_stop_trial && receiver_frame && receiver_arm_second')
(P/'controller.sh').write_text(c)
b=(P/'bootstrap.sh').read_text().replace('isolated-two-v19-encoder',mode).replace(f['runtime_files']['controller.sh'],sha(P/'controller.sh'));(P/'bootstrap.sh').write_text(b)
for n in ['controller.sh','bootstrap.sh','sample.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f.update(mode=mode,execution_approved=False,hard_hold=True,runtime_files={n:sha(P/n) for n in f['runtime_files']},scope='Native VENC started before both RAW captures. Removes proven invalid listen+pull fanout only. Two resource-sampled clips, no encoded file claim; not RAW-only A/B.',parent_freeze_sha256=sha(O/'freeze.json'))
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
s=(R/'local-verification/isolated_two_v19_encoder_test.py').read_text().replace('source-session-isolated-two-v19-encoder','source-session-isolated-two-v19b-encoder').replace("MODE='isolated-two-v19-encoder'","MODE='isolated-two-v19b-encoder'")
(R/'local-verification/isolated_two_v19b_encoder_test.py').write_text(s)
s=(R/'local-verification/run_encoder_v19_once.py').read_text().replace('isolated_two_v19_encoder_test','isolated_two_v19b_encoder_test').replace('source-session-isolated-two-v19-encoder','source-session-isolated-two-v19b-encoder').replace('isolated-two-v19-encoder','isolated-two-v19b-encoder').replace('First clip RAW+ISP/second addsVENC.','Both clips nativeVENC+RAW. Actual201733parser rejection fixed by removingcolor_null listen fromliveview; onlypullshadowremains.').replace('One RAW+ISP then RAW+ISP+nativeVENC bounded pair','One nativeVENC+RAW bounded pair (both clips)')
(R/'local-verification/run_encoder_v19b_once.py').write_text(s)
print(P)
