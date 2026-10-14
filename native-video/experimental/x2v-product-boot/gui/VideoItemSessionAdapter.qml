import QtQuick

// Host injects Component { VideoItem {} } and the actual native status enums.
// No unsupported VideoItem methods are called or invented.
Item {
    id: root
    objectName: "x2vVideoItemSessionAdapter"
    required property var session
    property Component videoItemComponent: null
    property int playingStatus: -101
    property int doneStatus: -102
    property int errorStatus: -103
    property bool operational: false
    property int activeSession: -1
    property int sequence: 0
    property int activeRequest: 0
    property string activeSource: ""
    property bool closing: false
    // Loader.item becomes null before deleteLater destroys the native QObject.
    // This guarded Item reference survives that gap and clears on destruction.
    property Item retiringItem: null
    property string releasePhase: ""
    property string releaseError: ""
    property real releaseStartedAtMs: 0
    property int startupTimeoutMs: 10000
    // Sources this player opens; any other open belongs to another player.
    property string accept: "\\.mp4$"

    function logNative(stage, extra) {
        var detail = { stage: stage, sessionId: activeSession, requestId: activeRequest };
        for (var key in extra) detail[key] = extra[key];
        console.info("X2V_CONTROL " + JSON.stringify({ event: "playback_native",
            timestampMs: Date.now(), detail: detail }));
    }
    function publish(phase, message) {
        session.applyPlayerSnapshot({ sessionId: activeSession, sequence: ++sequence,
            ackRequestId: activeRequest, phase: phase, error: message || "",
            positionKnown: false, canPause: false, canResume: false, canSeek: false });
    }
    function updateStatus() {
        if (!videoLoader.item || closing || !activeSource) return;
        if (videoLoader.item.status === playingStatus) { openTimeout.stop(); publish("playing"); }
        else if (videoLoader.item.status === doneStatus) { openTimeout.stop(); publish("ended"); }
        else if (videoLoader.item.status === errorStatus) { openTimeout.stop(); publish("error", "机内播放器无法打开此视频"); }
    }
    function finishRelease() {
        if (!closing || retiringItem || videoLoader.item || !releasePhase) return;
        var nextPhase = releasePhase, message = releaseError;
        releasePhase = ""; releaseError = "";
        logNative("release_complete", { durationMs: Math.max(0, Date.now() - releaseStartedAtMs), phase: nextPhase });
        publish(nextPhase, message);
    }
    function releasePlayer(nextPhase, message) {
        closing = true;
        openTimeout.stop();
        if (!releasePhase) {
            releaseStartedAtMs = Date.now();
            logNative("release_begin", { phase: nextPhase });
        }
        releasePhase = nextPhase; releaseError = message || "";
        if (videoLoader.item) retiringItem = videoLoader.item;
        // Never set native source="" before deleteLater. Firmware setSource()
        // clears worker while queued startDecoder callbacks still dereference it.
        // Native destruction performs stop/wait and then removes posted events.
        videoLoader.active = false;
        activeSource = ""; // adapter string only; not bound to the native source
        if (!retiringItem) Qt.callLater(root.finishRelease);
    }
    onRetiringItemChanged: {
        if (!retiringItem && closing && releasePhase) Qt.callLater(root.finishRelease);
    }
    function handle(command) {
        if (command.op === "open") {
            if (!new RegExp(accept, "i").test(String(command.source))) { activeSession = -1; return; }
            activeSession = command.sessionId; activeRequest = command.requestId;
            sequence = 0; closing = false; activeSource = command.source;
            if (!operational || !videoItemComponent) { publish("error", "播放器尚未连接"); return; }
            logNative("open_received", {});
            publish("loading");
            openTimeout.restart();
            videoLoader.active = true;
        } else if (command.sessionId === activeSession && command.op === "stop") {
            activeRequest = command.requestId;
            releasePlayer("idle", "");
        }
    }
    Loader {
        id: videoLoader
        anchors.fill: parent; active: false; sourceComponent: root.videoItemComponent
        onLoaded: {
            var started = Date.now();
            root.logNative("source_begin", {});
            item.source = root.activeSource;
            root.logNative("source_end", { durationMs: Math.max(0, Date.now() - started) });
            root.updateStatus();
        }
        onStatusChanged: { if (status === Loader.Error) root.publish("error", "无法加载机内播放器"); }
    }
    Timer {
        id: openTimeout
        interval: root.startupTimeoutMs
        onTriggered: {
            root.releasePlayer("error", "打开视频超时，请返回重试");
        }
    }
    // On adapter unload the Loader owns native deletion; no source mutation.
    Connections { target: root.session; function onCommandRequested(command) { root.handle(command); } }
    Connections { target: videoLoader.item; function onStatusChanged() { root.updateStatus(); } }
}
