from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path(__file__).resolve().parents[1];E=R/'native-video/experimental';O=E/'source-session-isolated-two-v18-isp';P=E/'source-session-isolated-two-v19-encoder';C=E/'raw-hardware-proxy-candidate/config';assert not P.exists();P.mkdir();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
f=json.loads((O/'freeze.json').read_text());mode='isolated-two-v19-encoder'
for n in f['runtime_files']:shutil.copy2((C if n.endswith(('.sp','.conf')) else O)/n,P/n)
shutil.copy2(E/'raw-proxy-resource-metrics/sample.sh',P/'sample.sh')
c=(P/'controller.sh').read_text().replace('isolated-two-v18-isp',mode)
for n in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:c=c.replace(f['runtime_files'][n],sha(P/n))
a='    q_sticky "$qs_prefix-color-stop" color_stop_unknown_no_retry || return 1';assert c.count(a)==1
c=c.replace(a,'''    q_sticky "$qs_prefix-encoder-start" encoder_start_unknown_no_retry || return 1
    q_sticky "$qs_prefix-encoder-stop" encoder_stop_unknown_no_retry || return 1
'''+a)
a='    if [ ! -f "$qs_prefix-color-stop-confirmed" ]; then';assert c.count(a)==1
c=c.replace(a,'''    if [ -f "$qs_prefix-encoder-start-confirmed" ] && [ ! -f "$qs_prefix-encoder-stop-confirmed" ]; then
        q_owner_same && : > "$qs_prefix-encoder-stop-intent" || return 1
        op stop_dcam_stream 5 && wait_idle && graph_state && q_owner_same &&
        grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || {
            fail encoder_stop_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-encoder-stop-confirmed" || return 1
    fi
'''+a)
a='receiver_user_stop_trial() {\n sleep 2\n';assert c.count(a)==1
c=c.replace(a,'''receiver_user_stop_trial() {
 # Same two-second intended window, actual three samples include read overhead.
 # Sequential readonly proc/sysfs; no factory RPC or independent live worker.
 read resource_pid resource_start < "$RUN/active-service.identity" || return 1
 timeout 4 sh "$TOOLS/sample.sh" 3 "$resource_pid" > "$RUN/resources-gen$CLIP_GEN.log" 2> "$RUN/resources-gen$CLIP_GEN.stderr" || return 1
''')
a='owner_quiesce() {';assert c.count(a)==1
c=c.replace(a,'''encoder_start() {
 q_scope && q_owner_same && wait_idle && graph_state || return 1
 grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || return 1
 q_sticky "$qs_prefix-encoder-start" encoder_start_unknown_no_retry || return 1
 [ ! -f "$qs_prefix-encoder-start-confirmed" ] || return 1
 : > "$qs_prefix-encoder-start-intent" || return 1
 op start_dcam_stream 5 && wait_idle && graph_state && q_owner_same &&
 grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || {
  fail encoder_start_unknown_no_retry; return 1;
 }
 : > "$qs_prefix-encoder-start-confirmed" || return 1
 log NATIVE_ENCODER_ROLE5_START_ACK_NOT_PAYLOAD_PROOF
}

'''+a)
a='receiver_frame && receiver_arm_second';assert c.count(a)==1;c=c.replace(a,'receiver_frame && encoder_start && receiver_arm_second')
(P/'controller.sh').write_text(c)
b=(P/'bootstrap.sh').read_text().replace('isolated-two-v18-isp',mode).replace(f['runtime_files']['controller.sh'],sha(P/'controller.sh'));(P/'bootstrap.sh').write_text(b)
for n in ['controller.sh','bootstrap.sh','sample.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f.update(mode=mode,execution_approved=False,hard_hold=True,runtime_files={n:sha(P/n) for n in list(f['runtime_files'])+['sample.sh']},scope='Two bounded captures: RAW+ISP then RAW+ISP+nativeVENC(role5). No network/encoded file claim; readonly resources each capture.',parent_freeze_sha256=sha(O/'freeze.json'))
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
s=(R/'local-verification/isolated_resident_two_v16_dng_test.py').read_text().replace('source-session-isolated-resident-two-v16-dng','source-session-isolated-two-v19-encoder').replace("MODE='isolated-resident-two-v16-dng'","MODE='isolated-two-v19-encoder'").replace("'imx861bqr_hb722.conf'}","'imx861bqr_hb722.conf','sample.sh'}")
(R/'local-verification/isolated_two_v19_encoder_test.py').write_text(s)
print(P)
