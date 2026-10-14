import QtQuick

Item {
    id: root
    required property var recorder
    property bool hardwareShutterReady:false
    property bool frameVisible:true
    property bool idleBadgeVisible:true
    readonly property bool recording: recorder.phase === "recording" && recorder.frames > 0 && recorder.fresh
    readonly property bool stopping: recorder.phase === "finalizing" && recorder.rtpConfirmedOff === false
    readonly property bool activeBorder: recording || (stopping && recorder.frames > 0 && recorder.fresh)
    readonly property bool busy: recorder.phase === "starting" || recorder.phase === "finalizing"
    readonly property bool stopNeedsRetry: recorder.stopNeedsRetry === true
    readonly property bool uncertain: ((recorder.phase === "recording" || stopping) && !recorder.fresh) || stopNeedsRetry
    readonly property bool previewFailed: recorder.phase === "saved" && !!recorder.previewError
    readonly property bool statusBusy: recording || busy || uncertain || previewFailed ||
        recorder.phase === "error" || recorder.phase === "saved"
    readonly property bool badgeVisible: statusBusy || idleBadgeVisible
    readonly property string clockText: {
        let seconds = Math.max(0, Math.floor(recorder.durationTicks / 90000))
        return (seconds >= 3600 ? String(Math.floor(seconds / 3600)).padStart(2, "0") + ":" : "") +
               String(Math.floor(seconds / 60) % 60).padStart(2, "0") + ":" +
               String(seconds % 60).padStart(2, "0")
    }
    readonly property alias statusText: statusLabel.text
    signal stopRequested()
    visible: recorder.videoMode
    // Full-screen visual only. The center receives no mouse or touch handler.
    Rectangle {
        objectName: "recordingBorder"
        visible:root.frameVisible
        anchors.fill: parent
        color: "transparent"
        border.width: root.activeBorder || root.uncertain ? 6 : 0
        border.color: root.uncertain ? "#E7AB48" : "#ED353D"
    }
    Rectangle {
        objectName: "recordingStatusBadge"
        visible: root.badgeVisible
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 18
        // Integer, fixed state widths keep the badge and timer from shifting.
        width: root.uncertain || root.previewFailed ? 248 : root.recording ? 174 : 144
        height: 40
        radius: 5
        color: "#EE101010"
        Row {
            id: statusRow
            anchors.centerIn: parent
            spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: root.activeBorder ? "#ED353D" : root.uncertain ? "#E7AB48" : "#999999"
            }
            Text {
                id: statusLabel
                objectName: "recordingStatusText"
                color: root.recording || root.busy || root.uncertain ? "#FFFFFF" : "#C6C6C6"
                font.pixelSize: 20; font.weight: Font.Medium
                text: root.stopNeedsRetry ? "停止未确认，请重试" : root.uncertain ? "录制状态失联" : root.stopping ? "正在停止…" : root.recording ? "REC  " + root.clockText :
                      recorder.phase === "starting" ? "正在启动…" :
                      recorder.phase === "finalizing" ? "正在保存…" :
                      recorder.phase === "error" ? "录制失败" :
                      root.previewFailed ? "已保存 · 监看未恢复" :
                      recorder.phase === "saved" ? "已保存" : root.hardwareShutterReady ? "视频" : "快门未接"
            }
        }
    }
}
