from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path(__file__).resolve().parents[1];OLD=R/'native-video/experimental/source-session-isolated-two-v21-dark';P=R/'native-video/experimental/source-session-isolated-two-v23-hw-proxy';RX=R/'native-video/experimental/source-receiver-adapter/receiver_v23_named_hw_proxy';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not P.exists();P.mkdir();f=json.loads((OLD/'freeze.json').read_text());receipt=json.loads((RX/'build/target-token/receipt.json').read_text());mode='isolated-two-v23-hw-proxy';device='/system/lib64/libx2v_mode21c24_named_proxy_20261012a.so'
for n in f['runtime_files']:shutil.copy2(OLD/n,P/n)
for n in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:shutil.copy2(RX/n,P/n)
t=(P/'controller.sh').read_text().replace(f['mode'],mode).replace(f['receiver_path'],device).replace(f['receiver_sha256'],receipt['sha256'])
for n in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:t=t.replace(f['runtime_files'][n],sha(P/n))
# Inventory permits precisely the owned diagnostic directory; DNG list/manifest remains strict.
needle='  [ -f "$entry" ] && [ ! -L "$entry" ] || exit 1\n  case "${entry##*/}" in segment.jsonl|frame-';assert t.count(needle)==1
replacement='''  if [ "$CLIP_GEN" = 1 ] && [ "${entry##*/}" = preview-probe_00000000000000000000000000000001 ]; then
   [ -d "$entry" ] && [ ! -L "$entry" ] || exit 1
   continue
  fi
'''+needle
t=t.replace(needle,replacement)
# A CPU receipt must be accompanied by confirmed named STOP/absence-of-start.
needle='    q_sticky "$qs_prefix-color-stop" color_stop_unknown_no_retry || return 1';assert t.count(needle)==1
t=t.replace(needle,'''    if [ -f "$RUN/receiver.arm-intent" ]; then
     grep -q 'X2V_PROXY lifecycle native_retirable=1 ' "$RUN/manual-service.log" || { fail named_proxy_not_retirable_no_teardown; return 1; }
    fi
'''+needle)
(P/'controller.sh').write_text(t)
for n in ['bootstrap.sh','guard.sh']:
 t=(P/n).read_text().replace(f['mode'],mode)
 if n=='bootstrap.sh':t=t.replace(f['runtime_files']['controller.sh'],sha(P/'controller.sh'))
 (P/n).write_text(t)
for n in ['bootstrap.sh','guard.sh','controller.sh']:subprocess.run(['/bin/sh','-n',str(P/n)],check=True)
f.update(mode=mode,execution_approved=False,hard_hold=True,receiver_path=device,receiver_sha256=receipt['sha256'],runtime_files={n:sha(P/n) for n in f['runtime_files']},scope='RX23 two RAW clips; first named hardware AVC probe with original hardware encoder and paired native STOP. No public role5. Unknown native op does not permit teardown.',integration_receipt=str(RX/'build/target-token/receipt.json'),proxy_full_AU_verified=False,proxy_PTS_unit_verified=False)
(P/'freeze.json').write_text(json.dumps(f,indent=2)+'\n')
t=(R/'local-verification/isolated_two_v21_dark_test.py').read_text().replace('source-session-isolated-two-v21-dark',P.name).replace('isolated-two-v21-dark',mode)
(R/'local-verification/isolated_two_v23_proxy_test.py').write_text(t);compile(t,'isolated_two_v23_proxy_test.py','exec')
print(json.dumps({'packet':str(P),'held':True,'receiver':receipt['sha256']}))
