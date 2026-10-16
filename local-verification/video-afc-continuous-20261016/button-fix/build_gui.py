from pathlib import Path
import re
D=Path(__file__).resolve().parent
ROOT=D.parents[2]
STOCK=ROOT/'resources/gui-resources/3/qt/qml/app/qml'
OUT=D/'gui';OUT.mkdir(exist_ok=True)
for name,new in [('LiveViewImage','X2VLiveViewImage'),('LiveViewOverlay','X2VLiveViewOverlay')]:
 s=(STOCK/'liveview'/f'{name}.qml').read_text()
 s=re.sub(r'import "\.\./([^\"]+)"',r'import "qrc:/qt/qml/app/qml/\1"',s)
 s=s.replace('import QtQuick\n','import QtQuick\nimport "qrc:/qt/qml/app/qml/liveview"\n',1)
 s=s.replace('    id: root\n','    id: root\n    property bool videoAfNavigation: false\n    signal videoMenuRequested()\n',1)
 if name=='LiveViewImage':
  s=s.replace('    LiveViewOverlay {','    X2VLiveViewOverlay {\n        videoAfNavigation: root.videoAfNavigation\n        onVideoMenuRequested: root.videoMenuRequested()')
 else:
  old='if (viewModel.inSession && !MKeys.pressedFn(KeyFn.ExposureModeCycle, event))'
  newguard='if (viewModel.inSession && !(root.videoAfNavigation && !viewModel.exposing && viewModel.afStatus === HblmTypes.E_AutoFocusStatus_RunningCont) && !MKeys.pressedFn(KeyFn.ExposureModeCycle, event))'
  assert s.count(old)==1;s=s.replace(old,newguard)
  anchor='            console.info("LiveViewOverlay.onPressed", event.key)'
  assert s.count(anchor)==1
  s=s.replace(anchor,anchor+'''
            if (root.videoAfNavigation && viewModel.inSession && !viewModel.exposing && MKeys.pressedFn(KeyFn.Menu, event)) {
                event.accepted = true;
                root.videoMenuRequested();
                return;
            }
''')
 (OUT/f'{new}.qml').write_text(s)
s=(STOCK/'MainContent.qml').read_text()
s=re.sub(r'import "(?!qrc:)([^\"]+)"',r'import "qrc:/qt/qml/app/qml/\1"',s)
s=s.replace('import QtQuick\n','import QtQuick\nimport "qrc:/qt/qml/app/qml"\n',1)
assert s.count('as LiveViewImage')==2
s=s.replace('as LiveViewImage','as X2VLiveViewImage')
(OUT/'X2VMainContent.qml').write_text(s)
s=(D/'installed-main.qml').read_text()
s=s.replace('source: "qrc:/qt/qml/app/qml/liveview/LiveViewImage.qml"','source: "X2VLiveViewImage.qml"')
s=s.replace('onLoaded: mainContentLoader.setSource("qrc:/qt/qml/app/qml/MainContent.qml", {liveviewLoader: liveviewLoader})','''onLoaded: {
            item.videoMenuRequested.connect(root.beginVideoMenu);
            item.videoAfNavigation = Qt.binding(function() { return recorder.videoMode && rec.session === "up" && root.nativeShutter; });
            mainContentLoader.setSource("qrc:/qt/qml/app/qml/MainContent.qml", {liveviewLoader: liveviewLoader});
        }''')
# AF is active in the viewfinder, paused in menu/playback, and resumes on return.
s=s.replace('    function writeTelemetry() {','''    property bool videoMenuPending: false
    property double videoMenuDeadline: 0
    property double afNavigationUntil: 0
    function beginVideoMenu() {
        videoMenuPending = true;
        videoMenuDeadline = Date.now() + 2500;
        writeAfContext();
        menuAfWait.start();
    }
    Timer {
        id: menuAfWait
        interval: 50; repeat: true
        onTriggered: {
            var vm = liveviewLoader.item ? liveviewLoader.item.viewModel : null;
            if (vm && !vm.inSession && root.mainModel()) {
                afNavigationUntil = Date.now() + 1000;
                videoMenuPending = false;
                stop();
                root.mainModel().toggle_screen("control_screen", {});
                root.uiLog("af_menu_released", {});
            } else if (Date.now() > videoMenuDeadline) {
                stop(); videoMenuPending = false;
                root.uiLog("af_menu_timeout", {});
            }
        }
    }
    property string lastAfContext: ""
    function writeAfContext() {
        var context = recorder.videoMode && rec.session === "up" && root.stockState() === "liveview" &&
                      !videoMenuPending && Date.now() >= afNavigationUntil && !videoGallery.visible && !root.settingsOpen && !drive.driveVisible ? "viewfinder" : "navigation";
        if (context === lastAfContext) return;
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///tmp/x2v-product/af-context");
        xhr.send(context);
        lastAfContext = context;
    }
    function writeTelemetry() {
        writeAfContext();''')
s=s.replace('mainContentLoader.setSource("qrc:/qt/qml/app/qml/MainContent.qml"','mainContentLoader.setSource("X2VMainContent.qml"')
s=s.replace('var s = {t: Date.now(),', 'var s = {afNav: liveviewLoader.item ? liveviewLoader.item.videoAfNavigation : false, screenStatus: liveviewLoader.item ? liveviewLoader.item.viewModel.screenStatus : -1, t: Date.now(),')
(OUT/'main.qml').write_text(s)
p=D.parent/'video-afc-watch.sh';s=p.read_text()
s=s.replace('    case "$mode" in','''    context=$(cat /tmp/x2v-product/af-context 2>/dev/null)
    if [ "$context" != viewfinder ]; then
        stop_focus
        sleep .3
        continue
    fi
    case "$mode" in''')
(D/'video-afc-watch.sh').write_text(s)
print(OUT)
