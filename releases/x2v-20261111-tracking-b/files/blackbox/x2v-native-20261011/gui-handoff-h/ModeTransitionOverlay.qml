import QtQuick

Rectangle {
    id: root
    objectName: "modeTransitionOverlay"
    property bool active: false
    property string targetMode: "photo"
    property bool takingLonger: false
    signal cancelRequested()
    visible: active
    color: "#141414"
    // Cover the native display plane as well as the parameter and AF overlays.
    z: 100100
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
    Column {
        anchors.centerIn: parent
        spacing: 28
        Item {
            width: 64; height: 64; anchors.horizontalCenter: parent.horizontalCenter
            Canvas {
                id: ring
                anchors.fill: parent
                onPaint: {
                    var c=getContext("2d"); c.reset(); c.lineWidth=4;
                    c.strokeStyle="#444444"; c.beginPath(); c.arc(32,32,27,0,Math.PI*2); c.stroke();
                    c.strokeStyle="#EEEEEE"; c.lineCap="round"; c.beginPath();
                    c.arc(32,32,27,-Math.PI/2,Math.PI*.8); c.stroke();
                }
                RotationAnimator on rotation { from:0; to:360; duration:950; loops:Animation.Infinite; running:root.active }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.targetMode==="photo" ? "正在返回拍照…" : "正在进入视频模式…"
            color:"#F1F1F1"; font.pixelSize:26
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible:root.takingLonger
            text:"正在等待相机就绪"; color:"#AFAFAF"; font.pixelSize:19
        }
    }
    Rectangle {
        x:32; y:32; width:152; height:64; radius:5
        visible:root.targetMode==="video" || root.takingLonger
        color:"#292929"
        Text { anchors.centerIn:parent; text:root.targetMode==="video" ? "取消切换" : "重试返回"; color:"#EAEAEA"; font.pixelSize:22 }
        MouseArea { anchors.fill:parent; onClicked:root.cancelRequested() }
    }
}
