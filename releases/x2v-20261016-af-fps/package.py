from pathlib import Path
import json,shutil,hashlib
D=Path(__file__).resolve().parent;R=D.parents[1];V=R/'local-verification/video-af-fps-release-20261016';B=R/'local-verification/video-afc-continuous-20261016/button-fix';E='/system/etc/x2v/';G='/blackbox/x2v-native-20261011/gui/'
items=[(V/'session.sh',E+'x2v_video_session_20261014zl.sh',755),(V/'supervisor.sh',E+'x2v_product_boot_20261015c.sh',755),(B/'video-afc-watch.sh',E+'video-afc-watch.sh',755),(V/'main.qml',G+'main.qml',644),(V/'RecordingProfiles.qml',G+'RecordingProfiles.qml',644),(V/'ExperimentalVideoSettings.qml',G+'ExperimentalVideoSettings.qml',644)]
for name in ['X2VLiveViewOverlay.qml','X2VMainContent.qml','X2VLiveViewImage.qml']:items.append((B/'gui'/name,G+name,644))
for fps in (25,30):
 m=json.loads((V/f'candidate-{fps}.json').read_text());items +=[(Path(m['lib']),f'/system/lib64/libx2v_af_{fps}_20261016.so',644),(Path(m['conf']),E+f'x2v_af_{fps}_20261016.conf',644)]
items.append((R/'native-video/experimental/rx-prr-explore-toflimits-20261016/build/libx2v_prr_resident.so','/system/lib64/libx2v_explore_toflimits_20261015.so',644))
out=[]
for src,dest,mode in items:
 p=D/'files'/dest.lstrip('/');p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,p);out.append({'file':str(p.relative_to(D)),'destination':dest,'mode':str(mode),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'source':str(src.relative_to(R))})
(D/'manifest.json').write_text(json.dumps({'release':'x2v-20261016-af-fps','base':'existing X2V installation on X2D II 1.3.16.2','assets':out},indent=2))
print(len(out),'assets',sum((D/a['file']).stat().st_size for a in out),'bytes')
