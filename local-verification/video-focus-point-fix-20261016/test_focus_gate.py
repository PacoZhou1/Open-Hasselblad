"""Exercise the candidate in Qt, including stock-typed callers and session guards.
Hardware proxies/geometry are stubs; this does not replace camera input testing.
"""
import json, os, tempfile
from pathlib import Path
os.environ.setdefault('QT_QPA_PLATFORM','offscreen')
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine, QQmlComponent
D=Path(__file__).resolve().parent
app=QGuiApplication([]); engine=QQmlEngine()
with tempfile.TemporaryDirectory() as t:
    p=Path(t);(p/'Mocks').mkdir()
    (p/'Mocks/qmldir').write_text('module Mocks\nsingleton Camera 1.0 Camera.qml\nsingleton Constants 1.0 Constants.qml\nsingleton HblmTypes 1.0 HblmTypes.qml\n')
    (p/'Mocks/Camera.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { property int focus_point: 0; property int crop_mode_current: 0; property int focus_area: 0; property int focus_size: 0 }')
    (p/'Mocks/Constants.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { readonly property point defaultFocusPoint: Qt.point(.5,.5); function combinedToSize(v) { return Qt.size(.1,.1) } }')
    (p/'Mocks/HblmTypes.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { readonly property int e_AutoFocusStatus_RunningCont: 3 }')
    # Same public shape as the native model. Stock typed indicator calls must
    # dispatch to the derived candidate; all native session state stays intact.
    (p/'LiveviewViewModel.qml').write_text('''import QtQuick
Item {
 property bool inSession: true; property bool exposing: false
 property int afStatus: 3; property bool isZoomed: false
 property bool swipingControlScreen: false; property bool canChangeFocusPoint: true
 property bool canMoveFocusPointBackScreen: false; property bool canMoveFocusPointEvf: false
 property bool screenBack: true; property bool screenEVF: false
 property bool canMoveFocusTp: true; property bool evfTpMoveFocus: true
 property rect focusRegion: Qt.rect(0,0,.1,.1)
 property point focusRegionCentrePoint: Qt.point(.5,.5)
 property point afSizeIndex: Qt.point(0,0); property point afTouchPoint: Qt.point(0,0)
 function repaintAfIndicator() {}
 function setFocusPointFromTouchPoint(pt: point): point { return Qt.point(0,0) }
 function moveFocusPointWithKey(event): bool { return false }
 function setFocusPoint(pt: point) {}
 function resetFocusPoint() {}
}''')
    (p/'AutoFocus.qml').write_text('''import QtQuick
Item {
 property rect focusRegion; property point focusRegionCentrePoint
 property point customFocusSizeIndex; property int currentCropMode
 property int focusArea; property size focusSize
 signal setCameraFocusPoint(point center, bool tp)
 function setFocusPointFromTouchPoint(pt: point): point { setCameraFocusPoint(pt,true); return pt }
 function setFocusPoint(pt: point, touch: bool) { setCameraFocusPoint(pt,touch) }
 function moveFocusPointWithKey(event): bool { setCameraFocusPoint(Qt.point(.6,.5),false); return true }
}''')
    src=(D/'gui/X2VLiveviewViewModel.qml').read_text()
    src='\n'.join(s for s in src.splitlines() if not s.startswith('import '))
    src=src.replace('HblmTypes.E_AutoFocusStatus_RunningCont','HblmTypes.e_AutoFocusStatus_RunningCont')
    (p/'X2VLiveviewViewModel.qml').write_text('import QtQuick\nimport Mocks 1.0\n'+src)
    (p/'Test.qml').write_text('''import QtQuick
import Mocks 1.0
Item {
 property LiveviewViewModel typed: X2VLiveviewViewModel { id: vm; videoAfNavigation: true }
 property string result: ""
 function check(ok, label) { if (!ok) throw Error(label) }
 function packed(x,y,touch) { var n=Math.round(x*10000)|(Math.round(y*10000)<<16); return touch ? n|0xC0000000 : n }
 function unchanged(label) { Camera.focus_point=7; typed.setFocusPointFromTouchPoint(Qt.point(.3,.4)); check(Camera.focus_point===7,label) }
 Component.onCompleted: {
   var points=[Qt.point(.2,.3),Qt.point(.7,.6),Qt.point(.2,.3)];
   for(var i=0;i<points.length;i++) { typed.setFocusPointFromTouchPoint(points[i]); check(Camera.focus_point===packed(points[i].x,points[i].y,true),"repeated touch "+i) }
   typed.moveFocusPointWithKey({key:1}); check(Camera.focus_point===packed(.6,.5,false),"joystick")
   typed.resetFocusPoint(); check(Camera.focus_point===packed(.5,.5,false),"reset")
   check(vm.inSession,"must not falsify session")
   vm.exposing=true; unchanged("exposure blocked"); vm.exposing=false;
   vm.videoAfNavigation=false; unchanged("stock photo session blocked"); vm.videoAfNavigation=true;
   vm.afStatus=2; unchanged("single AF session blocked"); vm.afStatus=3;
   vm.canChangeFocusPoint=false; unchanged("native permissions"); vm.canChangeFocusPoint=true;
   vm.isZoomed=true; unchanged("zoom"); vm.isZoomed=false;
   vm.swipingControlScreen=true; unchanged("swipe"); vm.swipingControlScreen=false;
   vm.videoAfNavigation=false; vm.inSession=false;
   typed.setFocusPointFromTouchPoint(Qt.point(.3,.4)); check(Camera.focus_point===packed(.3,.4,true),"stock idle")
   result="passed";
 }
}''')
    engine.addImportPath(t)
    c=QQmlComponent(engine,QUrl.fromLocalFile(str(p/'Test.qml')));o=c.create()
    errors=[e.toString() for e in c.errors()]
    assert o is not None,errors
    assert o.property('result')=='passed',errors
    result={'qt_gate_regression':'passed','checks':['repeated_touch_A_B_A','typed_joystick','typed_reset','real_session_retained','exposure_blocked','photo_session_blocked','single_af_blocked','native_permissions','zoom_blocked','swipe_blocked','stock_idle_preserved'],'hardware_input_verified':False}
    (D/'host-check.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))
    o.deleteLater()
