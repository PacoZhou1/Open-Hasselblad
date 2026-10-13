import QtQuick
import QtQuick.Window
import com.hasselblad.video
import com.hasselblad.keys

Window {
    id: root
    objectName: "MainWindow"
    color: "transparent"
    width: 1024
    height: 768
    visibility: Window.FullScreen

    readonly property int videoShutterOverride: recorder.videoMode && !drive.driveVisible ? 3 : 0

    function handleVideoFullPress(event, released) {
        if (!event || !recorder.videoMode || !bodyKeys.isFullPressEvent(event)) return false;
        bodyKeys.semanticShutterInput("full_press", released);
        event.accepted = true;
        return true;
    }

    Loader {
        id: liveviewLoader
        objectName: "liveview_loader"
        width: 1024
        height: 768
        scale: root.width / 1024
        anchors.centerIn: parent
        visible: startLiveviewAtStart
        active: true
        focus: startLiveviewAtStart
        asynchronous: true
        readonly property int keyOverride: root.videoShutterOverride
        source: "qrc:/qt/qml/app/qml/liveview/LiveViewImage.qml"
        onLoaded: mainContentLoader.setSource("qrc:/qt/qml/app/qml/MainContent.qml", {liveviewLoader: liveviewLoader})
        Keys.onPressed: (event) => { root.handleVideoFullPress(event, false); }
        Keys.onReleased: (event) => { root.handleVideoFullPress(event, true); }
    }
    Loader {
        id: mainContentLoader
        objectName: "mainContentLoader"
        width: 1024
        height: 768
        scale: root.width / 1024
        anchors.centerIn: parent
        visible: true
        active: true
        focus: !liveviewLoader.focus
        asynchronous: true
        onLoaded: {
            root.installKeyHook();
            root.uiLog("stock_root_loaded", {status: status});
        }
    }

    function mainModel() {
        if (!mainContentLoader.item) return null;
        var data = mainContentLoader.item.data;
        for (var i = 0; i < Math.min(data.length, 128); ++i) {
            var item = data[i];
            if (item && typeof item.toggle_screen === "function" && item.browseView !== undefined && item.controlScreen !== undefined)
                return item;
        }
        return null;
    }

    RecordingProfiles {
        id: profileSelection
        selectedProfileId: "raw_3920_2946_24"
        backendProfileId: rec.backendReady ? "raw_3920_2946_24" : ""
        backendReady: rec.backendReady
        busy: rec.busy
    }

    QtObject {
        id: rec
        property bool backendReady: false
        property bool fresh: false
        property string phase: "idle"
        property string detail: ""
        property int uptime: 0
        readonly property bool busy: ["starting", "recording", "finalizing"].indexOf(phase) >= 0
        function apply(v) {
            if (!v || v.schema !== 1) return;
            backendReady = v.backend_ready === true && v.profile_id === "raw_3920_2946_24";
            fresh = v.fresh === true;
            if (typeof v.phase === "string") phase = v.phase;
            detail = typeof v.detail === "string" ? v.detail : "";
            if (typeof v.uptime === "number") uptime = v.uptime;
        }
    }

    QtObject {
        id: recorder
        property bool available: true
        property bool fresh: rec.fresh
        property bool videoMode: true
        property string phase: rec.phase
        property int frames: rec.busy ? 1 : 0
        property int durationTicks: 0
        property bool rtpConfirmedOff: rec.phase === "saved" || rec.phase === "idle"
        property bool stopNeedsRetry: false
        property string previewError: ""
        readonly property string formatLabel: profileSelection.selected.format + " " + profileSelection.selected.width + "×" + profileSelection.selected.height
        function setVideoMode(value) { videoMode = !!value; }
        function start() { root.writeCmd("start"); return true; }
        function stop() { root.writeCmd("stop"); return true; }
        function refreshCatalog() { root.loadCatalog(); }
    }

    PlaybackSession {
        id: playbackController
        available: true
        fresh: true
        approvedRoots: [
            "/blackbox/x2v-native-20261011",
            "/mnt/media_rw/ssd/X2V_VIDEO",
            "/mnt/media_rw/ssd/X2V_RAW"
        ]
        Component.onCompleted: root.loadCatalog()
        onRefreshRequested: root.loadCatalog()
    }

    function fallbackCatalog() {
        return {schemaVersion: 1, clips: [{
            id: "X2V_PRR_102629_C1", state: "saved", finalized: true,
            source: "/mnt/media_rw/ssd/X2V_RAW/X2V_PRR_102629_C1/clip.mov",
            thumbnail: "/blackbox/x2v-native-20261011/prr-050839.jpg",
            title: "ProRes RAW HQ", duration: 0.79, bytes: 74788229,
            width: 3888, height: 2912, format: "ProRes RAW HQ"
        }]};
    }
    function prrClipsOnly(v) {
        var out = [], ids = {};
        if (!v || v.schemaVersion !== 1 || !v.clips) return out;
        for (var i = 0; i < v.clips.length; i++) {
            var c = v.clips[i];
            if (!c || typeof c.source !== "string" || !/\.mov$/i.test(c.source)) continue;
            if (typeof c.id !== "string" || !c.id || ids[c.id]) continue;
            ids[c.id] = true;
            out.push(c);
        }
        return out;
    }
    function loadCatalog() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///blackbox/x2v-native-20261011/rec/catalog.json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            var snap = root.fallbackCatalog();
            try {
                var v = JSON.parse(xhr.responseText);
                var clips = root.prrClipsOnly(v);
                if (clips.length) snap = {schemaVersion: 1, clips: clips};
            } catch (e) {}
            playbackController.replaceCatalog(snap);
        };
        xhr.send();
    }
    function writeCmd(name) {
        console.info("X2V_PRR_GUI " + JSON.stringify({event: "command", name: name}));
        if (name === "start") root.screenshot("rec-start");
        if (name === "stop") root.screenshot("rec-stop");
    }
    function pollRec() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///blackbox/x2v-native-20261011/rec/state.json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            try { rec.apply(JSON.parse(xhr.responseText)); } catch (e) {}
        };
        xhr.send();
    }

    DriveAttach {
        id: drive
        stockRoot: mainContentLoader.item
        recorder: recorder
        recordingProfiles: profileSelection
    }

    Loader {
        id: experimentalUiLoader
        objectName: "x2vExperimentalUiLoader"
        anchors.fill: parent
        z: 100002
        active: mainContentLoader.status === Loader.Ready && !!mainContentLoader.item
        sourceComponent: Component {
            ExperimentalVideoUi {
                stockRoot: mainContentLoader.item
                recordingProfiles: profileSelection
                nativeExposureModel: root.mainModel() ? root.mainModel().controlScreen : null
                videoMode: recorder.videoMode
                galleryOpen: videoGallery.visible
                interactionAllowed: !videoGallery.visible
            }
        }
    }

    readonly property bool settingsOpen: experimentalUiLoader.item && experimentalUiLoader.item.experimentalOpen

    BodyKeys {
        id: bodyKeys
        recorder: recorder
        recordingProfiles: profileSelection
        hardwareShutterReady: rec.backendReady
        galleryOpen: videoGallery.visible
        settingsOpen: root.settingsOpen
        driveVisible: drive.driveVisible
        stockFocus: liveviewLoader.item
        stockRoot: mainContentLoader.item
        onPlayRequested: root.handlePlay()
    }

    function handlePlay() {
        if (recorder.phase === "recording" || recorder.phase === "finalizing") return false;
        if (videoGallery.visible) {
            if (playbackController.active) playbackController.stop();
            else {
                playbackController.stop();
                videoGallery.visible = false;
            }
            return true;
        }
        return root.openGallery();
    }
    function nativeShutterInput(action, released) { return bodyKeys.semanticShutterInput(action, released); }
    function installBrowseHook() {
        var stock = mainContentLoader.item;
        if (!stock || stock._x2vBrowse || !stock.data) return;
        var vm = null;
        var sm = null;
        var n = Math.min(stock.data.length, 128);
        for (var i = 0; i < n; ++i) {
            var item = stock.data[i];
            if (!item || typeof item.toggle_screen !== "function") continue;
            if (item.browseView !== undefined && item.controlScreen !== undefined) vm = item;
            else if (item.blockKeys !== undefined) sm = item;
        }
        if (!vm || !sm) return;
        // toggle_screen is a signal. Assigning a function does not disconnect
        // the stock state machine, so Playback still opens the photo browser.
        try { vm.toggle_screen.disconnect(sm.toggle_screen); }
        catch (e) { return; }
        vm.toggle_screen.connect(function (name, arg) {
            if (name === "browse_view") {
                root.handlePlay();
                return;
            }
            sm.toggle_screen(name, arg);
        });
        stock._x2vBrowse = true;
        root.uiLog("browse_hook", {installed: true});
    }
    function installKeyHook() {
        var stock = mainContentLoader.item;
        if (!stock || stock._x2vKeys || typeof stock.keyPressed !== "function") return;
        var origPressed = stock.keyPressed;
        var origReleased = stock.keyReleased;
        stock.keyPressed = function (event) {
            if (bodyKeys.isPlayEvent(event)) {
                root.handlePlay();
                event.accepted = true;
                return;
            }
            if (recorder.videoMode && bodyKeys.isFullPressEvent(event)) {
                bodyKeys.semanticShutterInput("full_press", false);
                event.accepted = true;
                return;
            }
            origPressed(event);
        };
        if (typeof origReleased === "function") {
            stock.keyReleased = function (event) {
                if (recorder.videoMode && bodyKeys.isFullPressEvent(event)) {
                    bodyKeys.semanticShutterInput("full_press", true);
                    event.accepted = true;
                    return;
                }
                origReleased(event);
            };
        }
        stock._x2vKeys = true;
        root.installBrowseHook();
    }

    PrrFrameSurface {
        id: rgbSurface
        width: 0
        height: 0
        visible: false
        session: playbackController
        playerBase: "http://127.0.0.1:18763"
        operational: true
    }
    VideoGallery {
        id: videoGallery
        z: 100010
        anchors.fill: parent
        visible: false
        session: playbackController
        playbackSurface: Component {
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                cache: false
                source: rgbSurface.frameUrl
            }
        }
        onLeaveRequested: {
            playbackController.stop();
            visible = false;
        }
    }

    function openGallery() {
        if (recorder.phase === "recording" || recorder.phase === "finalizing") return false;
        root.loadCatalog();
        videoGallery.visible = true;
        videoGallery.forceActiveFocus();
        return true;
    }
    function playClip() {
        videoGallery.visible = true;
        playbackController.open("X2V_PRR_102629_C1");
    }

    Text {
        z: 100020
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 66
        visible: rec.detail !== "" && recorder.videoMode && !videoGallery.visible && !root.settingsOpen
        text: rec.detail
        color: "#F3B581"
        font.pixelSize: 22
    }

    RecordingOverlay {
        anchors.fill: parent
        z: 100015
        recorder: recorder
        hardwareShutterReady: rec.backendReady
        idleBadgeVisible: false
        frameVisible: !videoGallery.visible && !root.settingsOpen
        visible: recorder.videoMode && !videoGallery.visible && !root.settingsOpen
    }

    Timer {
        id: shotDelay
        interval: 900
        property string name: ""
        onTriggered: { root.screenshot(name); interval = 900; }
    }
    Timer {
        interval: 400
        repeat: true
        running: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///blackbox/x2v-native-20261011/gui-cmd");
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) return;
                var cmd = String(xhr.responseText || "").replace(/\s+/g, "");
                if (!cmd || cmd === root.lastGuiCmd) return;
                root.lastGuiCmd = cmd;
                if (cmd === "gallery") { root.openGallery(); shotDelay.name = "prr-gui-gallery"; shotDelay.restart(); }
                else if (cmd === "play") { root.playClip(); shotDelay.interval = 1800; shotDelay.name = "prr-gui-player"; shotDelay.restart(); }
                else if (cmd === "shot") root.screenshot("prr-gui-cmd");
                else if (cmd === "home") { playbackController.stop(); videoGallery.visible = false; shotDelay.name = "prr-gui-home"; shotDelay.restart(); }
                else if (cmd === "record") recorder.start();
                else if (cmd === "settings") {
                    if (experimentalUiLoader.item) experimentalUiLoader.item.experimentalOpen = true;
                    shotDelay.name = "prr-gui-settings"; shotDelay.restart();
                }
            };
            xhr.send();
        }
    }
    property string lastGuiCmd: ""

    function screenshot(name) {
        root.contentItem.grabToImage(function (r) {
            r.saveToFile("/blackbox/x2v-native-20261011/" + name + ".png");
        });
    }
    function uiLog(event, detail) {
        console.info("X2V_PRR_GUI " + JSON.stringify({event: event, timestampMs: Date.now(), detail: detail}));
    }

    Timer { interval: 400; repeat: true; running: true; onTriggered: root.pollRec() }
    Timer { interval: 800; running: !!mainContentLoader.item; repeat: true; onTriggered: { root.installKeyHook(); root.installBrowseHook(); } }
    Timer { interval: 2500; running: true; onTriggered: root.screenshot("prr-gui-live") }
}
