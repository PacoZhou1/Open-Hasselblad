from pathlib import Path
import json,hashlib,shutil
R=Path(__file__).resolve().parents[1];P=R/'native-video/experimental/source-receiver-adapter/receiver_v23_named_hw_proxy';BASE=P.with_name('receiver_v18_dng_isp_proxy')
C=P.parent.parent/'native-named-proxy-session-configured-candidate';V=P.parent.parent/'raw-hardware-avc-output-candidate';F=P.parent.parent/'raw-proxy-probe-sink'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for n in ['imx861bqr_hb722.sp','imx861bqr_hb722.conf']:shutil.copy2(P.parent.parent/'raw-hardware-proxy-candidate-b/config'/n,P/n)
external=[C/n for n in ['named_session.c','recording_reply.c','integration_binding.c']]+[F/'probe_sink.c']
t=(BASE/'build.py').read_text()
t=t.replace("'geometry.c','color_observer.c'","'geometry.c','color_observer.c','proxy_control.c'")
needle='# C24 review pins';i=t.index(needle);t=t[:i]+"\nC=P.parent.parent/'native-named-proxy-session-configured-candidate';V=P.parent.parent/'raw-hardware-avc-output-candidate';F=P.parent.parent/'raw-proxy-probe-sink'\nsources += [C/n for n in ['named_session.c','recording_reply.c','integration_binding.c']] + [P/'avc_capture.c',F/'probe_sink.c']\n"+t[i:]
t=t.replace("expected=sequence_review['production_sources'][src.name] if src.parent==P", "expected=sequence_review['external_sources'][rel] if src in [C/n for n in ['named_session.c','recording_reply.c','integration_binding.c']]+[F/'probe_sink.c'] else sequence_review['production_sources'][src.name] if src.parent==P")
t=t.replace("'-I',G,'-include'", "'-I',G,'-I',P,'-I',C,'-I',V,'-I',F,'-DX2V_NAMED_EXECUTE=1','-include'")
needle='groups={}';t=t.replace(needle,"provider_exports.update({'cam_cap_eng_property_subscribe':'lib64/libdcam_frwk.so','dcam_container_set_as_uint8_inner':'lib64/libdcam_base.so','_ZN15RtpStreamFilter8onBufferEP35cam_cap_encoded_video_result_buffer':'lib64/camera/plugins/libdcam_plugins_AIO.so'})\n"+needle)
t=t.replace('libx2v_mode21c24_dng_isp_proxy_v18_arm.TOKEN_REQUIRED.so','libx2v_mode21c24_named_hw_proxy_v23_arm.TOKEN_REQUIRED.so')
t=t.replace("S/'lib64/libduml_hal.so','-o'", "S/'lib64/libduml_hal.so',S/'lib64/libdcam_frwk.so',S/'lib64/libdcam_base.so','-o'")
t=t.replace("S/'bin/linker64'];provider_symbols", "S/'bin/linker64',S/'lib64/libdcam_frwk.so',S/'lib64/libdcam_base.so'];provider_symbols")
t=t.replace("'native_stop_scope':'unchanged native controller ownership; CPU ACK is not a DMA fence'", "'native_stop_scope':'paired named native proxy STOP then original graph teardown; no public role5; CPU ACK not DMA fence'")
t=t.replace("(B/'receipt.json').write_text", "receipt['integration_status']='OFFLINE ONLY; no controller packet or device release';receipt['proxy_callback_probe_limit']=5;receipt['proxy_clock_verified']=False;receipt['proxy_full_AU_verified']=False\n(B/'receipt.json').write_text")
review=json.loads((BASE/'source-review.json').read_text());review.update(production_sources={p.name:sha(p) for p in P.glob('*.c') if not p.name.startswith('check_')},headers={p.name:sha(p) for p in P.glob('*.h')},external_sources={str(p.relative_to(R)):sha(p) for p in external},status='OFFLINE_INTEGRATION_SNAPSHOT_NOT_NATIVE_VALIDATION',baseline_review_sha256=sha(BASE/'source-review.json'))
(P/'source-review.json').write_text(json.dumps(review,indent=2)+'\n');(P/'build.py').write_text(t);compile(t,str(P/'build.py'),'exec');print(P/'build.py')
