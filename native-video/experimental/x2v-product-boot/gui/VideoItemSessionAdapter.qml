import QtQuick

// Host injects Component { VideoItem {} } and the actual native status enums.
// VideoItem has no pause in the firmware ABI; pause hides the decoder after a
// grab, resume shows it again. pause()/paused are used only if they exist.
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
    property bool userPaused: false
    property url freezeUrl: ""

    function logNative(stage, extra) {
        var detail = { stage: stage, sessionId: activeSession, requestId: activeRequest };
        for (var key in extra) detail[key] = extra[key];
        console.info("X2V_CONTROL " + JSON.stringify({ event: "playback_native",
            timestampMs: Date.now(), detail: detail }));
    }
    function publish(phase, message) {
        session.applyPlayerSnapshot({ sessionId: activeSession, sequence: ++sequence,
            ackRequestId: activeRequest, phase: phase, error: message || "",
            positionKnown: false,
            canPause: phase === "playing",
            canResume: phase === "paused",
            canSeek: false });
    }
    function updateStatus() {
        if (!videoLoader.item || closing || !activeSource || userPaused) return;
        if (videoLoader.item.status === playingStatus) { openTimeout.stop(); publish("playing"); }
        else if (videoLoader.item.status === doneStatus) { openTimeout.stop(); publish("ended"); }
        else if (videoLoader.item.status === errorStatus) { openTimeout.stop(); publish("error", "机内播放器无法打开此视频"); }
    }
    function callIf(item, names, argPresent, arg) {
        if (!item) return false;
        for (var i = 0; i < names.length; i++) {
            var n = names[i];
            try {
                if (typeof item[n] === "function") {
                    if (argPresent) item[n](arg); else item[n]();
                    return true;
                }
            } catch (e) {}
        }
        return false;
    }
    function nativePause(item) {
        if (callIf(item, ["pause"])) return true;
        try { if (item.paused !== undefined) { item.paused = true; return true; } } catch (e) {}
        return false;
    }
    function nativeResume(item) {
        if (callIf(item, ["resume", "play", "start"])) return true;
        try { if (item.paused !== undefined) { item.paused = false; return true; } } catch (e) {}
        return false;
    }
    function freezeThenHide(item) {
        if (!item || typeof item.grabToImage !== "function") {
            if (item) item.visible = false;
            return;
        }
        item.grabToImage(function (result) {
            if (!root.userPaused) return;
            root.freezeUrl = result.url;
            if (videoLoader.item) videoLoader.item.visible = false;
        });
    }
    function pausePlayback() {
        var item = videoLoader.item;
        if (!item || closing) return false;
        userPaused = true;
        if (!nativePause(item)) freezeThenHide(item);
        publish("paused");
        logNative("pause", {});
        return true;
    }
    function resumePlayback() {
        var item = videoLoader.item;
        if (!item || closing) return false;
        userPaused = false;
        freezeUrl = "";
        item.visible = true;
        nativeResume(item);
        publish("playing");
        logNative("resume", {});
        return true;
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
            userPaused = false; freezeUrl = "";
            publish("loading");
            openTimeout.restart();
            videoLoader.active = true;
        } else if (command.sessionId === activeSession && command.op === "stop") {
            activeRequest = command.requestId;
            userPaused = false; freezeUrl = "";
            releasePlayer("idle", "");
        } else if (command.sessionId === activeSession && command.op === "pause") {
            activeRequest = command.requestId;
            root.pausePlayback();
        } else if (command.sessionId === activeSession && command.op === "resume") {
            activeRequest = command.requestId;
            root.resumePlayback();
        }
    }
    Loader {
        id: videoLoader
        anchors.fill: parent; active: false; sourceComponent: root.videoItemComponent
        onLoaded: {
            var started = Date.now();
            root.userPaused = false;
            root.freezeUrl = "";
            item.visible = true;
            root.logNative("source_begin", {});
            item.source = root.activeSource;
            root.logNative("source_end", { durationMs: Math.max(0, Date.now() - started) });
            root.updateStatus();
        }
        onStatusChanged: { if (status === Loader.Error) root.publish("error", "无法加载机内播放器"); }
    }
    Image {
        anchors.fill: parent
        visible: root.userPaused && root.freezeUrl !== ""
        source: root.freezeUrl
        fillMode: Image.PreserveAspectFit
        cache: false
    }
    Text {
        anchors.centerIn: parent
        visible: root.userPaused && root.freezeUrl === ""
        text: "已暂停"
        color: "#EEEEEE"
        font.pixelSize: 32
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
