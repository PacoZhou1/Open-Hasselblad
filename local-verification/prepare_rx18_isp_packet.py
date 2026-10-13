from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path(__file__).resolve().parents[1];E=R/'native-video/experimental';B=E/'source-receiver-adapter/receiver_v18_dng_isp_proxy';O=E/'source-session-isolated-resident-two-v16-dng';P=E/'source-session-isolated-two-v18-isp';assert not P.exists();P.mkdir()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
f=json.loads((O/'freeze.json').read_text());mode='isolated-two-v18-isp'
for n in f['runtime_files']:shutil.copy2((B if n.endswith(('.sp','.conf')) else O)/n,P/n)
c=(P/'controller.sh').read_text().replace('isolated-resident-two-v16-dng',mode).replace('libx2v_mode21c24_dng_resident2_20261012a.so','libx2v_mode21c24_dng_isp_20261012a.so').replace('GROUP13_MODE21C24_DNG_RESIDENT2_V16','GROUP13_MODE21C24_DNG_ISP_PROXY_V18')
receipt=json.loads((B/'build/target-token/receipt.json').read_text());c=c.replace(f['receiver_sha256'],receipt['sha256'])
for n,key in [('imx861bqr_hb722.sp','SP'),('imx861bqr_hb722.conf','CONF')]:c=c.replace(f['runtime_files'][n],sha(P/n))
a='    q_sticky "$qs_prefix-graph-stop" graph_stop_unknown_no_retry || return 1';assert c.count(a)==1;c=c.replace(a,'    q_sticky "$qs_prefix-color-stop" color_stop_unknown_no_retry || return 1\n'+a)
a='    if [ ! -f "$qs_prefix-graph-stop-confirmed" ]; then';assert c.count(a)==1
c=c.replace(a,'''    if [ ! -f "$qs_prefix-color-stop-confirmed" ]; then
        q_owner_same && : > "$qs_prefix-color-stop-intent" || return 1
        op stop_dcam_stream 0 && wait_idle && graph_state && q_owner_same || {
            fail color_stop_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-color-stop-confirmed" || return 1
    fi
'''+a)
(P/'controller.sh').write_text(c)
b=(P/'bootstrap.sh').read_text().replace('isolated-resident-two-v16-dng',mode).replace(f['runtime_files']['controller.sh'],sha(P/'controller.sh'));(P/'bootstrap.sh').write_text(b)
for n in ['controller.sh','bootstrap.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f.update(mode=mode,execution_approved=False,hard_hold=True,receiver_path='/system/lib64/libx2v_mode21c24_dng_isp_20261012a.so',receiver_sha256=receipt['sha256'],token='GROUP13_MODE21C24_DNG_ISP_PROXY_V18',runtime_files={n:sha(P/n) for n in f['runtime_files']},scope='Bounded two 2s RAW+ISP metadata observation only; no H264 encoder. Existing RAW terminal ABI16 and restoration; role0 delayed stop before role1 and whole.',integrations_pending=['root final delta review/stage/release','native dimension acceptance','native H264 branch and actual headroom'],parent_freeze_sha256=sha(O/'freeze.json'))
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n');print(P)
