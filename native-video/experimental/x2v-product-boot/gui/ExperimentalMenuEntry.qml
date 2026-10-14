import QtQuick
import "qrc:/qt/qml/app/qml/components/buttons" as NativeButtons
Item {
    id:root;objectName:"x2vExperimentalMenuEntry"
    property var stockGrid:null
    property bool layoutVerified:false
    signal openRequested()
    width:stockGrid?stockGrid.cellWidth:0;height:stockGrid?stockGrid.cellHeight:0
    x:3*width;y:2*height
    visible:layoutVerified && !!stockGrid && stockGrid.count===11 && stockGrid.numCols===4 &&
        !!stockGrid.parent.mainMenu && stockGrid.parent.mainMenu.state!=="menu"
    NativeButtons.FramedImage {
        anchors.horizontalCenter:parent.horizontalCenter;anchors.top:parent.top
        width:parent.width;highlightWidth:136;highlightHeight:102
        source:"image://svg/ic_controlscreen_exposure_mode_video";text:"实验性功能";textPixelSize:33.6;textTopMargin:16
        touchEnabled:true;selectable:true;acceptKeys:false
        onClicked:root.openRequested()
    }
}
