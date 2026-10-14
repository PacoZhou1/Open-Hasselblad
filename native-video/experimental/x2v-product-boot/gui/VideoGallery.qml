import QtQuick
import "Catalog.js" as Catalog

Rectangle {
    id: root
    required property var session
    property Component playbackSurface: null
    signal leaveRequested()
    color: "#080808"
    focus: visible
    onVisibleChanged: { if (!visible && session.active) session.stop(); }
    Keys.onEscapePressed: { if (session.active) session.stop(); else root.leaveRequested(); }
    Rectangle {
        id: header
        height: 90; width: parent.width; color: "#111111"
        Text {
            x: 32; anchors.verticalCenter: parent.verticalCenter
            text: "‹  相册"; color: "#FFFFFF"; font.pixelSize: 28
            MouseArea { anchors.fill: parent; anchors.margins: -18; onClicked: root.leaveRequested() }
        }
        Text { anchors.centerIn: parent; text: "视频  ·  " + session.clips.length; color: "white"; font.pixelSize: 30 }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 32; anchors.verticalCenter: parent.verticalCenter
            text: "刷新"; color: session.fresh ? "#DDDDDD" : "#666666"; font.pixelSize: 24
            MouseArea { anchors.fill: parent; anchors.margins: -18; enabled: session.fresh; onClicked: session.refreshRequested() }
        }
    }
    GridView {
        id: grid
        objectName: "videoGrid"
        anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom; margins: 18 }
        clip: true; model: session.clips; cellWidth: width / 3; cellHeight: cellWidth * 0.84
        currentIndex: count > 0 ? 0 : -1
        boundsBehavior: Flickable.StopAtBounds
        delegate: Item {
            id: tile
            required property var modelData
            required property int index
            width: grid.cellWidth; height: grid.cellHeight
            Rectangle {
                anchors.fill: parent; anchors.margins: 6; color: "#191919"
                border.color: tile.GridView.isCurrentItem ? "#E8AD65" : "#333333"
                border.width: tile.GridView.isCurrentItem ? 3 : 1
                Image {
                    id: thumb
                    anchors { left: parent.left; right: parent.right; top: parent.top; bottom: title.top; margins: 3 }
                    source: tile.modelData.thumbnail; fillMode: Image.PreserveAspectFit
                    asynchronous: true; cache: true; sourceSize.width: 340; sourceSize.height: 250
                }
                Text {
                    anchors.centerIn: thumb; text: "▷"; color: "#E8E8E8"; font.pixelSize: 46
                    visible: thumb.status !== Image.Ready
                }
                Rectangle {
                    anchors { right: thumb.right; bottom: thumb.bottom; margins: 10 }
                    width: 80; height: 33; radius: 4; color: "#C9000000"
                    Text { anchors.centerIn: parent; text: Catalog.time(tile.modelData.duration); color: "white"; font.pixelSize: 20 }
                }
                Text {
                    id: title
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 14 }
                    height: 29; text: tile.modelData.title; textFormat: Text.PlainText
                    color: "#EEEEEE"; font.pixelSize: 20; elide: Text.ElideMiddle
                }
                MouseArea {
                    anchors.fill: parent; enabled: session.canOpen
                    onClicked: { grid.currentIndex = tile.index; session.open(tile.modelData.id); }
                }
            }
        }
        Keys.onReturnPressed: { if (currentIndex >= 0) session.open(session.clips[currentIndex].id); }
    }
    Rectangle {
        anchors.fill: grid; color: "#E5080808"
        visible: session.clips.length === 0 || !!session.catalogError || !session.fresh
        Text {
            anchors.centerIn: parent; width: parent.width - 100; horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap; font.pixelSize: 27; color: "#BBBBBB"
            text: !session.fresh ? "相机连接中断，视频列表暂不可用" :
                  session.catalogError ? "无法读取视频列表\n" + session.catalogError :
                  !session.catalogReady ? "正在读取视频…" : "暂无已保存的视频"
            textFormat: Text.PlainText
        }
    }
    Rectangle {
        anchors.fill: parent; color: "black"; visible: session.active
        // Create the adapter before the first open command, independent of visibility.
        Loader { anchors.fill: parent; sourceComponent: root.playbackSurface }
        MouseArea { anchors.fill: parent } // block taps reaching the gallery below
        Image {
            anchors.fill: parent; anchors.bottomMargin: 140
            visible: session.phase !== "playing" && session.phase !== "paused"
            source: session.selectedClip ? session.selectedClip.thumbnail : ""
            fillMode: Image.PreserveAspectFit; opacity: 0.45
        }
        Text {
            anchors.centerIn: parent; width: parent.width - 100; horizontalAlignment: Text.AlignHCenter
            color: session.error ? "#F3B581" : "#EEEEEE"; font.pixelSize: 28; wrapMode: Text.WordWrap
            visible: ["loading", "stopping", "ended", "error"].indexOf(session.phase) >= 0 || !session.fresh
            text: !session.fresh ? "播放状态连接中断，请返回退出" :
                  session.phase === "loading" ? "正在打开视频…" :
                  session.phase === "stopping" ? "正在停止播放…" :
                  session.phase === "ended" ? "播放结束" : session.error
            textFormat: Text.PlainText
        }
        VideoPlaybackControls {
            anchors.fill: parent; player: root.session
            onTogglePlayback: session.togglePlayback()
            onSeekRequested: seconds => session.seek(seconds)
            onCloseRequested: session.stop()
        }
    }
}
