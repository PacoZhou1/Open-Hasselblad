from pathlib import Path
D=Path(__file__).resolve().parent
R=D.parents[1]
S=R/'releases/x2v-20261016-af-fps/files/blackbox/x2v-native-20261011/gui'
def replace(s,a,b):
    assert a in s,a
    return s.replace(a,b)
s=(S/'X2VLiveViewImage.qml').read_text()
s=replace(s,'LiveviewViewModel {\n        id: liveviewViewModel','X2VLiveviewViewModel {\n        id: liveviewViewModel\n        videoAfNavigation: root.videoAfNavigation')
s=replace(s,'!root.viewModel.inSession && root.viewModel.screenBack','(!root.viewModel.inSession || liveviewViewModel.videoFocusSession) && root.viewModel.screenBack')
s=replace(s,'readonly property bool canMoveFocusPointBackScreen: root.viewModel.canMoveFocusPointBackScreen','readonly property bool canMoveFocusPointBackScreen: liveviewViewModel.focusTouchAllowed')
s=replace(s,'disableDrag: root.viewModel.inSession','disableDrag: root.viewModel.inSession && !liveviewViewModel.videoFocusSession')
s=replace(s,'root.viewModel.canMoveFocusPointEvf || root.viewModel.canMoveSpotCircleEvf','liveviewViewModel.focusEvfAllowed || root.viewModel.canMoveSpotCircleEvf')
s=replace(s,'videoAfNavigation: root.videoAfNavigation\n        onVideoMenuRequested','videoAfNavigation: root.videoAfNavigation\n        focusTouchAllowed: liveviewViewModel.focusTouchAllowed\n        onVideoMenuRequested')
(D/'gui/X2VLiveViewImage.qml').write_text(s)
s=(S/'X2VLiveViewOverlay.qml').read_text()
s=replace(s,'property bool videoAfNavigation: false','property bool videoAfNavigation: false\n    property bool focusTouchAllowed: viewModel ? viewModel.canMoveFocusPointBackScreen : false')
s=replace(s,'enabled: root.viewModel.canMoveFocusPointBackScreen','enabled: root.focusTouchAllowed')
s=replace(s,'enabled: viewModel.canMoveFocusPointBackScreen','enabled: root.focusTouchAllowed')
(D/'gui/X2VLiveViewOverlay.qml').write_text(s)
s=(S/'main.qml').read_text()
s=s.replace('import QtQuick.Window', 'import QtQuick.Window\nimport com.hasselblad.proxies as FocusProxy')
s=replace(s,'var s = {afNav:', '''var fv = liveviewLoader.item ? liveviewLoader.item.viewModel : null;
        var s = {focusPoint: FocusProxy.Camera.focus_point,
                 focusSession: fv ? fv.inSession : false,
                 focusCanChange: fv ? fv.canChangeFocusPoint : false,
                 focusTouch: fv ? fv.focusTouchAllowed : false,
                 focusVideoMove: fv ? fv.videoCanMoveFocusPoint : false,
                 afStatus: fv ? fv.afStatus : -1, afNav:''')
(D/'gui/main.qml').write_text(s)
print('Prepared focus-point candidate; checkpoint unchanged')
