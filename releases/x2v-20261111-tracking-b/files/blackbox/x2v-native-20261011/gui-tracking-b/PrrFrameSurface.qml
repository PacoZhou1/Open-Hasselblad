import QtQuick

// msdec RGB surface. The player (x2v_prr_play) decodes ProRes RAW to packed
// RGB888 and serves /frame.ppm. This adapter never constructs VideoItem or
// asks for an HEVC proxy.
Item {
    id: root
    objectName: "x2vPrrFrameSurface"
    required property var session
    property url playerBase: "http://127.0.0.1:18763"
    property string frameFile: "/tmp/x2v-play/frame.ppm"
    property bool operational: true
    property int activeSession: -1
    property int sequence: 0
    property int activeRequest: 0
    property string activeSource: ""
    property bool closing: false
    property int lastGeneration: -1
    property string frameUrl: ""
    property string lastPhase: ""
    // Sources this player opens; any other open belongs to another player.
    property string accept: "\\.mov$"

    Image {
        id: frame
        objectName: "prrRgbFrame"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        asynchronous: false
        cache: false
        // Hosts that draw frameUrl themselves keep this surface hidden: no second decode per frame.
        source: root.visible ? root.frameUrl : ""
    }

    function publish(phase, extra) {
        var snap = {
            sessionId: activeSession, sequence: ++sequence,
            ackRequestId: activeRequest, phase: phase, error: "",
            positionKnown: false, canPause: false, canResume: false, canSeek: false
        };
        if (extra) {
            for (var key in extra) snap[key] = extra[key];
        }
        lastPhase = phase;
        session.applyPlayerSnapshot(snap);
    }
    function sendCmd(body, done) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", String(root.playerBase).replace(/\/$/, "") + "/cmd");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            if (done) done(xhr.status, xhr.responseText);
        };
        xhr.send(body);
    }
    function pollState() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", String(root.playerBase).replace(/\/$/, "") + "/state");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4 || root.closing) return;
            var st = null;
            try { st = JSON.parse(xhr.responseText); } catch (e) { return; }
            if (!st || st.schema !== 1) return;
            root.applyState(st);
        };
        xhr.send();
    }
    function applyState(st) {
        var phase = st.phase;
        if (["idle", "loading", "playing", "paused", "ended", "error"].indexOf(phase) < 0)
            return;
        if (typeof st.generation === "number" && st.generation !== lastGeneration) {
            lastGeneration = st.generation;
            if (root.frameFile)
                frameUrl = "file://" + root.frameFile + "?" + st.generation;
            else
                frameUrl = String(root.playerBase).replace(/\/$/, "") + "/frame.ppm?g=" + st.generation;
        }
        var extra = {
            error: st.error || "",
            positionKnown: typeof st.position === "number",
            position: st.position,
            duration: st.duration,
            canPause: phase === "playing",
            canResume: phase === "paused"
        };
        if (phase === "idle" && activeSource)
            return;
        publish(phase, extra);
    }
    function handle(command) {
        if (command.op === "open") {
            if (!new RegExp(accept, "i").test(String(command.source))) { activeSession = -1; return; }
            activeSession = command.sessionId;
            activeRequest = command.requestId;
            sequence = 0;
            closing = false;
            activeSource = command.source;
            lastGeneration = -1;
            frameUrl = "";
            if (!operational) { publish("error", { error: "解码器未连接" }); return; }
            publish("loading");
            sendCmd("open " + command.source + "\n", function (status) {
                if (root.closing) return;
                if (status < 200 || status >= 300)
                    root.publish("error", { error: "无法打开 ProRes RAW 解码器" });
            });
            poll.restart();
        } else if (command.sessionId === activeSession && command.op === "stop") {
            activeRequest = command.requestId;
            closing = true;
            poll.stop();
            sendCmd("stop\n");
            activeSource = "";
            frameUrl = "";
            publish("idle");
        } else if (command.sessionId === activeSession && command.op === "pause") {
            activeRequest = command.requestId;
            sendCmd("pause\n");
        } else if (command.sessionId === activeSession && command.op === "resume") {
            activeRequest = command.requestId;
            sendCmd("resume\n");
        }
    }

    Timer {
        id: poll
        interval: 40
        repeat: true
        onTriggered: { if (!root.closing && root.activeSource) root.pollState(); }
    }
    Connections {
        target: root.session
        function onCommandRequested(command) { root.handle(command); }
    }
}
