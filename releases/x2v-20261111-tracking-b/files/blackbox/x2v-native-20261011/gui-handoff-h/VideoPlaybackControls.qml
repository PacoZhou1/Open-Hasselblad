import QtQuick
import "Catalog.js" as Catalog

Item {
    id: root
    required property var player
    signal togglePlayback()
    signal seekRequested(real seconds)
    signal closeRequested()
    readonly property bool toggleEnabled: player.ready &&
        ((player.phase === "playing" && player.canPause) || (player.phase === "paused" && player.canResume))
    readonly property bool seekEnabled: player.ready && player.canSeek && player.duration > 0
    Rectangle {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 140; color: "#ED111111"
        Text {
            x: 32; y: 18; width: parent.width - 280; elide: Text.ElideMiddle
            text: player.error ? "回放失败 · " + player.error : player.title
            textFormat: Text.PlainText
            color: player.error ? "#F3B581" : "white"; font.pixelSize: 23
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 32; y: 20
            text: (player.positionKnown ? Catalog.time(player.position) + " / " : "时长 ") + Catalog.time(player.duration)
            color: "#C6C6C6"; font.pixelSize: 20
        }
        Rectangle {
            id: bar
            x: 168; y: 99; width: parent.width - 340; height: 5; radius: 2; color: "#555555"
            opacity: root.seekEnabled ? 1 : 0.55
            Rectangle {
                visible: player.positionKnown
                width: player.duration > 0 ? parent.width * Math.min(1, player.position / player.duration) : 0
                height: parent.height; color: "white"
            }
            MouseArea {
                objectName: "videoSeekButton"
                anchors.fill: parent; anchors.topMargin: -26; anchors.bottomMargin: -26
                enabled: root.seekEnabled
                onClicked: mouse => root.seekRequested(Math.max(0, Math.min(1, mouse.x / width)) * player.duration)
            }
        }
        Text {
            x: 32; y: 85; text: player.phase === "playing" ? "暂停" : "播放"
            color: root.toggleEnabled ? "white" : "#686868"; font.pixelSize: 24
            MouseArea {
                objectName: "videoToggleButton"
                anchors.fill: parent; anchors.margins: -16
                enabled: root.toggleEnabled; onClicked: root.togglePlayback()
            }
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 32; y: 85
            text: player.phase === "stopping" ? "正在退出" : "返回"
            color: player.phase === "stopping" ? "#777777" : "white"; font.pixelSize: 24
            MouseArea {
                objectName: "videoCloseButton"
                anchors.fill: parent; anchors.margins: -16
                enabled: player.phase !== "stopping"; onClicked: root.closeRequested()
            }
        }
    }
}
