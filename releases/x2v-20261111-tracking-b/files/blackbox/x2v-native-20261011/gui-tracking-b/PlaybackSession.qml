import QtQuick
import "Catalog.js" as Catalog

QtObject {
    id: root
    property var approvedRoots: []
    property bool available: false
    property bool fresh: false
    property bool catalogReady: false
    property string catalogError: ""
    property var clips: []
    property string phase: "idle"
    property var selectedClip: null
    property real position: 0
    property real duration: 0
    property bool canPause: false
    property bool canSeek: false
    property bool canResume: false
    property bool positionKnown: false
    property string error: ""
    property string pendingOp: ""
    property int sessionId: 0
    property int requestId: 0
    property int lastSequence: -1
    property string pendingOpenId: ""
    readonly property string title: selectedClip ? selectedClip.title : ""
    readonly property bool active: phase !== "idle"
    readonly property bool playing: phase === "playing"
    readonly property bool ready: fresh && !error && !pendingOp &&
                                  ["playing", "paused", "ended"].indexOf(phase) >= 0
    readonly property bool canOpen: available && fresh && catalogReady && !catalogError && !active
    signal commandRequested(var command)
    signal refreshRequested()

    function replaceCatalog(snapshot) {
        try {
            clips = Catalog.normalize(snapshot, approvedRoots);
            catalogReady = true; catalogError = "";
            return true;
        } catch (e) { catalogError = String(e.message || e); return false; }
    }
    function send(op, extra) {
        var command = { op: op, sessionId: sessionId, requestId: ++requestId };
        for (var key in extra) command[key] = extra[key];
        commandRequested(command);
    }
    function open(id) {
        if (!canOpen) return false;
        for (var i = 0; i < clips.length; ++i) {
            if (clips[i].id !== id) continue;
            pendingOpenId = "";
            selectedClip = clips[i]; ++sessionId; lastSequence = -1;
            position = 0; duration = selectedClip.duration; positionKnown = false; error = "";
            canPause = false; canSeek = false; canResume = false;
            phase = "loading"; pendingOp = "open";
            send("open", { id: id, source: selectedClip.source });
            return true;
        }
        return false;
    }
    function clipIndex(id) {
        for (var i = 0; i < clips.length; ++i) if (clips[i].id === id) return i;
        return -1;
    }
    function openAdjacent(delta) {
        if (!clips.length || !delta) return false;
        var ix = selectedClip ? clipIndex(selectedClip.id) : 0;
        if (ix < 0) ix = 0;
        var n = (ix + delta) % clips.length;
        if (n < 0) n += clips.length;
        if (clips[n].id === (selectedClip ? selectedClip.id : "") && clips.length === 1)
            return false;
        if (!active) return open(clips[n].id);
        pendingOpenId = clips[n].id;
        return stop(true);
    }
    function togglePlayback() {
        if (!ready) return false;
        var op = phase === "playing" && canPause ? "pause" :
                 phase === "paused" && canResume ? "resume" : "";
        if (!op) return false;
        pendingOp = op; send(op, {}); return true;
    }
    function seek(seconds) {
        if (!ready || !canSeek || !isFinite(seconds) || duration <= 0) return false;
        pendingOp = "seek"; send("seek", { seconds: Math.max(0, Math.min(duration, seconds)) });
        return true;
    }
    function stop(keepPending) {
        if (!keepPending) pendingOpenId = "";
        if (!active || phase === "stopping") return false;
        // Stop stays available on heartbeat loss. Wait for release acknowledgement.
        phase = "stopping"; pendingOp = "stop"; send("stop", {}); return true;
    }
    function applyPlayerSnapshot(snapshot) {
        if (!snapshot || snapshot.sessionId !== sessionId ||
            !Number.isInteger(snapshot.sequence) || snapshot.sequence <= lastSequence ||
            ["idle", "loading", "playing", "paused", "ended", "stopping", "error"].indexOf(snapshot.phase) < 0)
            return false;
        if (phase === "idle" || (phase === "stopping" &&
            ["idle", "error", "stopping"].indexOf(snapshot.phase) < 0)) return false;
        lastSequence = snapshot.sequence; phase = snapshot.phase;
        if (snapshot.duration !== undefined && isFinite(snapshot.duration) && snapshot.duration > 0)
            duration = snapshot.duration;
        positionKnown = snapshot.positionKnown === true;
        if (positionKnown && isFinite(snapshot.position)) position = Math.max(0, Math.min(duration, snapshot.position));
        canPause = snapshot.canPause === true; canSeek = snapshot.canSeek === true; canResume = snapshot.canResume === true;
        error = snapshot.phase === "error" ? String(snapshot.error || "无法播放此视频") : "";
        if (snapshot.ackRequestId === requestId || ["idle", "ended", "error"].indexOf(phase) >= 0)
            pendingOp = "";
        if (phase === "idle") {
            selectedClip = null; position = 0; duration = 0;
            canPause = false; canSeek = false; canResume = false; positionKnown = false;
            var next = pendingOpenId;
            pendingOpenId = "";
            if (next) Qt.callLater(function () { root.open(next); });
        }
        return true;
    }
}
