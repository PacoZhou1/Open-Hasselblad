import QtQuick
import "ExposureAssistData.js" as ExposureAssistData
import "ModeTransitionGate.js" as ModeTransitionGate
import QtQuick.Window
import com.hasselblad.proxies as FocusProxy
import com.hasselblad.video
import com.hasselblad.keys

Window {
    id: root
    objectName: "MainWindow"
    color: "transparent"
    width: 1024
    height: 768
    visibility: Window.FullScreen

    QtObject {
        id: modeTransition
        property bool active: false
        property string targetMode: "photo"
        property var request: null
        property double beganAt: 0
        property double clock: Date.now()
        property bool painted: false
        readonly property bool takingLonger: active && clock-beganAt>8000
        function begin(target, commandId) {
            targetMode=target; beganAt=Date.now(); clock=beganAt; painted=false;
            request=ModeTransitionGate.begin(target,commandId,beganAt);
            active=true;
            root.uiLog("mode_transition_begin",{target:target,id:commandId});
            root.writeAfContext();
        }
        function observe(v) {
            if (!active && (v.job_kind==="enter" || v.job_kind==="exit" ||
                            (v.mode==="photo" && v.photo_ready===false))) {
                begin(v.mode==="video" ? "video" : "photo",String(v.command_id || ""));
                request.acknowledged=true; // Observed backend transition, not a local request.
            }
            if (!active) return;
            if (ModeTransitionGate.step(request,v,rec.fresh).ready) {
                root.uiLog("mode_transition_ready",{target:targetMode,ms:Date.now()-beganAt});
                active=false; request=null; root.writeAfContext();
            }
        }
    }
    Timer { interval:250; repeat:true; running:modeTransition.active; onTriggered:modeTransition.clock=Date.now() }
    ModeTransitionOverlay {
        id:modeTransitionView
        anchors.fill:parent
        // Native connection/error and power-off dialogs remain actionable.
        active:modeTransition.active && ["error","usb_connected","battery_exhausted",
               "bt_connection_request","upgrade_finished","shutdown"].indexOf(root.stockState())<0
        targetMode:modeTransition.targetMode
        takingLonger:modeTransition.takingLonger
        onCancelRequested:recorder.setVideoMode(false)
    }
    Connections {
        target:root
        enabled:modeTransitionView.visible && !modeTransition.painted
        function onFrameSwapped() {
            modeTransition.painted=true;
            root.uiLog("mode_transition_painted",{target:modeTransition.targetMode,ms:Date.now()-modeTransition.beganAt});
        }
    }

    // Full press in video is ignored (MODE21 still hang). Half press still does AF and
    // dismisses stock pages when the gallery does not have focus. Without the session
    // fullpress gate, Override(3) swallows stills and also the service half press.
    property bool nativeShutter: false
    readonly property int videoShutterOverride:
        recorder.videoMode && rec.session === "up" && !nativeShutter && !drive.driveVisible ? 3 : 0
    function pollNativeShutter() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/x2v-live/fullpress");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            var on = String(xhr.responseText || "").trim() === "1";
            if (on !== root.nativeShutter) { root.nativeShutter = on; uiLog("native_shutter", {on: on}); }
        };
        xhr.send();
    }
    // The session's viewfinder (/tmp/x2v-live/view): "isp" puts the ISP's own picture on the display
    // plane under this window, which then must leave it uncovered; "raw" is residentPreview's.
    property bool ispView: false
    function pollView() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/x2v-live/view");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            var on = String(xhr.responseText || "").trim() === "isp";
            if (on !== root.ispView) { root.ispView = on; uiLog("isp_view", {on: on}); }
        };
        xhr.send();
    }
    Timer { interval: 400; repeat: true; running: recorder.videoMode; triggeredOnStart: true; onTriggered: { root.pollNativeShutter(); root.pollView(); } }


    // Full press in video mode is absorbed and ignored. On MODE21 a still still
    // hangs the body; recording is only the on-screen button.
    readonly property int shutterMs: 400
    property double lastShutter: 0
    function shutterTrigger(source, detail) {
        uiLog("shutter_ignored", {source: source, phase: rec.phase, stock: root.stockState(), detail: detail});
    }
    property int keysLogged: 0
    function logKey(where, event) {
        if (keysLogged >= 120) return;
        keysLogged++;
        uiLog("key", {where: where, key: event.key, repeat: event.isAutoRepeat});
    }
    function handleVideoFullPress(event, released) {
        if (!event) return false;
        if (!released) logKey("viewfinder", event);
        if (released || event.isAutoRepeat || !recorder.videoMode || !bodyKeys.isFullPressEvent(event)) return false;
        shutterTrigger("key", {key: event.key});
        event.accepted = true;
        return true;
    }
    function handleVideoZoom(event, released) {
        if (!event || released || event.isAutoRepeat || !recorder.videoMode || rec.session !== "up")
            return false;
        if (videoGallery.visible || root.settingsOpen) return false;
        if (!bodyKeys.isZoomEvent(event)) return false;
        root.toggleFocusMagnify();
        event.accepted = true;
        return true;
    }
    // null until first read: whatever count is there then is not a press. The session's enter
    // removes the file, so a new service's first press always differs from it.
    property var shutterSeen: null
    function pollShutter() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/x2v-live/shutter");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            var n = String(xhr.responseText || "").trim();
            if (root.shutterSeen === null) { root.shutterSeen = n; return; }
            if (n === root.shutterSeen) return;
            root.shutterSeen = n;
            if (n) root.shutterTrigger("forwarded", {count: n});
        };
        xhr.send();
    }
    Timer { interval: 30; repeat: true; running: rec.session === "up"; onTriggered: root.pollShutter() }

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
        source: "X2VLiveViewImage.qml"
        onLoaded: {
            item.videoMenuRequested.connect(root.beginVideoMenu);
            item.videoAfNavigation = Qt.binding(function() { return recorder.videoMode && rec.session === "up" && root.nativeShutter; });
            mainContentLoader.setSource("X2VMainContent.qml", {liveviewLoader: liveviewLoader,
                videoHandoffControlled:Qt.binding(function() { return modeTransition.active; })});
        }
        Keys.onPressed: (event) => { root.handleVideoZoom(event, false) || root.handleVideoFullPress(event, false); }
        Keys.onReleased: (event) => { root.handleVideoZoom(event, true); root.handleVideoFullPress(event, true); }
    }
    // Resident session viewfinder: the stock liveview has no frames while group 13 owns the sensor.
    // Two images take turns: while one is shown the other loads the newest frame, and the next
    // load starts as soon as that one lands, at most every PACE ms. preview.gen is read beside
    // the loads, not before each one (that held it to 12 fps), and only a number not loaded yet
    // starts a load: a frame decoded twice cost this process CPU the recorders then lacked.
    // Under the stock liveview, which draws no picture of its own (that is a display plane) but
    // carries LiveViewOverlay: the ISO / WB / shutter / aperture readouts the body keys change.
    // In ISP view the display plane has the picture, and this would only cover it.
    Item {
        id: residentPreview
        objectName: "x2vResidentPreview"
        z: -1
        anchors.fill: parent
        visible: rec.session === "up" && !videoGallery.visible && (!root.ispView || root.focusMagnify)
        readonly property int pace: 38
        property int front: 0
        property int seq: 0
        property int shown: 0
        property double lastLoad: 0
        property string genWritten: ""
        property string genLoaded: ""
        property bool asking: false
        function pollGen() {
            if (asking) return;
            asking = true;
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/x2v-live/preview.gen");
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) return;
                residentPreview.asking = false;
                var g = String(xhr.responseText || "").trim();
                if (g && g !== residentPreview.genWritten) { residentPreview.genWritten = g; residentPreview.next(); }
            };
            xhr.send();
        }
        function next() {
            var back = front ? pvA : pvB;
            if (!visible || back.status === Image.Loading || !genWritten || genWritten === genLoaded) return;
            var wait = pace - (Date.now() - lastLoad);
            if (wait > 0) { paceTimer.interval = Math.ceil(wait); paceTimer.restart(); return; }
            lastLoad = Date.now();
            genLoaded = genWritten;
            back.source = "file:///tmp/x2v-live/preview.ppm?" + (++seq);
        }
        function landed(img) {
            if (img.status === Image.Loading) return;
            if (img === (front ? pvA : pvB) && img.status === Image.Ready) { front = img === pvB ? 1 : 0; shown++; }
            next();
        }
        onVisibleChanged: { if (visible) next(); else { pvA.source = ""; pvB.source = ""; genLoaded = ""; } }
        Image {
            id: pvA
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            visible: residentPreview.front === 0
            onStatusChanged: residentPreview.landed(pvA)
        }
        Image {
            id: pvB
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            visible: residentPreview.front === 1
            onStatusChanged: residentPreview.landed(pvB)
        }
        Timer { id: paceTimer; repeat: false; onTriggered: residentPreview.next() }
        Timer { interval: 25; repeat: true; running: residentPreview.visible; onTriggered: residentPreview.pollGen() }
    }
    Rectangle {
        z: -1
        anchors.fill: parent
        color: "black"
        visible: recorder.videoMode && rec.session !== "up" && !videoGallery.visible
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
        readonly property int keyOverride: root.videoShutterOverride
        onLoaded: {
            item.videoHandoffLiveViewSuppressed.connect(function(requested,count) {
                root.uiLog("mode_liveview_gui_suppressed",{enabled:requested,count:count});
            });
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
        backendProfileId: rec.backendReady ? rec.profileId : ""
        backendReady: rec.backendReady
        busy: rec.busy
        onIntentSelected: (id) => root.requestProfile(id)
        onDurationSelected: (seconds) => root.writeCmd("duration_" + seconds)
    }
    // The supervisor owns the codec; a choice shows at once and then follows what it publishes.
    property double profileAskedAt: 0
    function requestProfile(id) {
        var p = profileSelection.find(id);
        if (!p) return;
        profileAskedAt = Date.now();
        root.writeCmd("profile_" + p.id);
    }

    QtObject {
        id: rec
        property bool backendReady: false
        property bool fresh: false
        property string phase: "idle"
        property string detail: ""
        property int uptime: 0
        property string profileId: ""
        property string mode: "photo"
        property string session: "down"
        property real seconds: 0
        property int frames: 0
        property double seenAt: 0
        readonly property bool busy: modeTransition.active || ["entering", "exiting", "starting", "recording", "finalizing"].indexOf(phase) >= 0
        function apply(v) {
            if (!v || v.schema !== 1) return;
            if (typeof v.uptime === "number" && v.uptime !== uptime) { uptime = v.uptime; seenAt = Date.now(); }
            // The supervisor rewrites this file several times a second; an unchanged clock means it is gone.
            fresh = v.fresh === true && Date.now() - seenAt < 3000;
            profileId = typeof v.profile_id === "string" && profileSelection.find(v.profile_id) ? v.profile_id : "";
            backendReady = fresh && v.backend_ready === true && !!profileId;
            if (profileId && profileId !== profileSelection.selectedProfileId && Date.now() - root.profileAskedAt > 3000)
                profileSelection.selectedProfileId = profileId;
            if (typeof v.phase === "string") phase = v.phase;
            detail = typeof v.detail === "string" ? v.detail : "";
            if (v.mode === "video" || v.mode === "photo") mode = v.mode;
            if (typeof v.session === "string") session = v.session;
            seconds = typeof v.seconds === "number" ? v.seconds : 0;
            frames = typeof v.frames === "number" ? v.frames : 0;
            if (typeof v.duration_limit_seconds === "number") profileSelection.durationSeconds = v.duration_limit_seconds;
            modeTransition.observe(v);
        }
    }

    QtObject {
        id: recorder
        property bool available: true
        property bool fresh: rec.fresh
        readonly property bool videoMode: rec.mode === "video"
        property string phase: rec.phase
        property int frames: rec.phase === "recording" ? Math.max(1, rec.frames) : 0
        property int durationTicks: rec.phase === "recording" ? Math.round(shownSeconds * 90000) : 0
        // The clip's seconds arrive four times a second and late by a varying amount; shown as
        // they come, the clock now and then skipped a second. It runs on from the last value
        // at this side's own pace, and never backwards.
        property real shownSeconds: 0
        property real anchorSeconds: 0
        property double anchorAt: 0
        function tick() {
            if (rec.phase !== "recording") { shownSeconds = 0; anchorAt = 0; return; }
            var now = Date.now();
            if (!anchorAt || rec.seconds !== anchorSeconds) { anchorSeconds = rec.seconds; anchorAt = now; }
            shownSeconds = Math.max(shownSeconds, anchorSeconds + Math.min(1.0, (now - anchorAt) / 1000));
        }
        property bool rtpConfirmedOff: rec.phase === "saved" || rec.phase === "idle"
        property bool stopNeedsRetry: false
        property string previewError: ""
        readonly property string formatLabel: profileSelection.selected.format + " " + profileSelection.selected.width + "×" + profileSelection.selected.height
        function setVideoMode(value) {
            var id=root.writeCmd(value ? "video_on" : "video_off");
            modeTransition.begin(value ? "video" : "photo",id);
        }
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

    function fallbackCatalog() { return {schemaVersion: 1, clips: []}; }
    function playableClips(v) {
        var out = [], ids = {};
        if (!v || v.schemaVersion !== 1 || !v.clips) return out;
        for (var i = 0; i < v.clips.length; i++) {
            var c = v.clips[i];
            if (!c || typeof c.source !== "string" || !/\.(mov|mp4)$/i.test(c.source)) continue;
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
                var clips = root.playableClips(v);
                if (clips.length) snap = {schemaVersion: 1, clips: clips};
            } catch (e) {}
            playbackController.replaceCatalog(snap);
        };
        xhr.send();
    }
    property int cmdCount: 0
    function writeCmd(name) {
        var id = Date.now() + "-" + (++cmdCount);
        console.info("X2V_PRR_GUI " + JSON.stringify({event: "command", name: name, id: id}));
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///tmp/x2v-product/gui.cmd");
        xhr.send(id + " " + name + "\n");
        return id;
    }
    function pollRec() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/x2v-product/state.json");
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
                liveviewRoot: liveviewLoader.item
                recordingProfiles: profileSelection
                histogramEnabled: root.rawHistogramEnabled
                onHistogramRequested: (enabled) => root.setHistogramPreference(enabled)
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
    function leavePlayback() {
        playbackController.stop();
        videoGallery.visible = false;
        root.focusMagnify = false;
        root.restoreStockFocus();
        root.uiLog("playback_leave", {reason: "half_press"});
        return true;
    }
    function nativeShutterInput(action, released) { return bodyKeys.semanticShutterInput(action, released); }
    property var browseHookItem: null
    property string lastStockState: ""
    function installBrowseHook() {
        var stock = mainContentLoader.item;
        if (!stock || stock === browseHookItem || !stock.data) return;
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
        // The keys a stock screen does not take itself reach MainContent.keyPressed, which emits
        // this first (auto-repeats excluded): the full press from the control screen or ISO pages.
        if (sm.keyPressed) sm.keyPressed.connect(function (k) {
            if (recorder.videoMode && bodyKeys.isFullPressKey(k))
                root.shutterTrigger("stock_key", {key: k});
        });
        // toggle_screen is a signal. Assigning a function does not disconnect
        // the stock state machine, so Playback still opens the photo browser.
        try { vm.toggle_screen.disconnect(sm.toggle_screen); }
        catch (e) {
            browseHookItem = stock;
            root.uiLog("browse_hook", {installed: false, error: String(e)});
            return;
        }
        browseHookItem = stock;
        vm.toggle_screen.connect(function (name, arg) {
            root.uiLog("toggle_screen", {name: name, video: recorder.videoMode});
            // In photo mode Playback stays the stock photo browser.
            if (name === "browse_view" && recorder.videoMode) {
                root.handlePlay();
                return;
            }
            sm.toggle_screen(name, arg);
        });
        root.uiLog("browse_hook", {installed: true});
    }
    property var keyHookItem: null
    property bool keyHooked: false
    function installKeyHook() {
        var stock = mainContentLoader.item;
        if (!stock || stock === keyHookItem || typeof stock.keyPressed !== "function") return;
        // Once per stock item: where keyPressed is a declared QML function it is read-only,
        // and every retry from the timer below only threw again.
        keyHookItem = stock;
        keyHooked = false;
        var origPressed = stock.keyPressed;
        var origReleased = stock.keyReleased;
        try {
            hookKeys(stock, origPressed, origReleased);
            keyHooked = true;
        } catch (e) {
            root.uiLog("key_hook", {installed: false, error: String(e)});
        }
    }
    function hookKeys(stock, origPressed, origReleased) {
        stock.keyPressed = function (event) {
            if (bodyKeys.isPlayEvent(event)) {
                root.handlePlay();
                event.accepted = true;
                return;
            }
            if (root.handleVideoZoom(event, false)) return;
            if (recorder.videoMode && bodyKeys.isFullPressEvent(event)) {
                root.shutterTrigger("stock_hook", {key: event.key});
                event.accepted = true;
                return;
            }
            origPressed(event);
        };
        if (typeof origReleased === "function") {
            stock.keyReleased = function (event) {
                if (recorder.videoMode && bodyKeys.isFullPressEvent(event)) {
                    event.accepted = true;
                    return;
                }
                origReleased(event);
            };
        }
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
            Item {
                anchors.fill: parent
                // ProRes RAW frames: decoded off the GUI thread into the hidden one of two images,
                // which is shown once it is ready, as the resident preview does.
                Item {
                    id: prrFrames
                    anchors.fill: parent
                    visible: rgbSurface.activeSource !== ""
                    property int front: 0
                    readonly property string want: rgbSurface.frameUrl
                    onWantChanged: next()
                    function next() {
                        if (!want) { prrA.source = ""; prrB.source = ""; return; }
                        var shown = front ? prrB : prrA, back = front ? prrA : prrB;
                        if (back.status === Image.Loading || String(shown.source) === want || String(back.source) === want) return;
                        back.source = want;
                    }
                    function landed(img) {
                        if (img.status === Image.Loading) return;
                        if (img === (front ? prrA : prrB) && img.status === Image.Ready) front = img === prrB ? 1 : 0;
                        next();
                    }
                    Image {
                        id: prrA
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                        visible: prrFrames.front === 0
                        onStatusChanged: prrFrames.landed(prrA)
                    }
                    Image {
                        id: prrB
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                        visible: prrFrames.front === 1
                        onStatusChanged: prrFrames.landed(prrB)
                    }
                }
                // H.264 clips: the stock hardware-decoding player, as FirstTimeGuide uses it.
                VideoItemSessionAdapter {
                    anchors.fill: parent
                    session: playbackController
                    accept: "\\.mp4$"
                    videoItemComponent: Component { VideoItem {} }
                    playingStatus: VideoItem.Playing; doneStatus: VideoItem.Done; errorStatus: VideoItem.Error
                    operational: true
                }
            }
        }
        onLeaveRequested: root.leavePlayback()
        // With the focus here the stock root never sees Playback; it closes what it opened.
        Keys.onPressed: (event) => {
            root.uiLog("gallery_key", {key: event.key});
            if (bodyKeys.isPlayEvent(event)) { root.handlePlay(); event.accepted = true; }
            else if (bodyKeys.isHalfPressEvent(event)) { root.leavePlayback(); event.accepted = true; }
        }
    }

    function openGallery() {
        if (recorder.phase === "recording" || recorder.phase === "finalizing") return false;
        root.writeCmd("catalog_refresh");
        root.loadCatalog();
        videoGallery.visible = true;
        videoGallery.forceActiveFocus();
        return true;
    }
    function playClip() {
        videoGallery.visible = true;
        if (playbackController.clips.length) playbackController.open(playbackController.clips[0].id);
    }

    Text {
        id: noticeText
        z: 100020
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 66
        readonly property string phaseText: rec.phase === "entering" ? "正在进入视频模式…" :
                                            rec.phase === "exiting" ? "正在返回拍照…" : ""
        visible: !modeTransition.active && (rec.detail !== "" || phaseText !== "") && !videoGallery.visible && !root.settingsOpen
        text: rec.detail !== "" ? rec.detail : phaseText
        color: "#F3B581"
        font.pixelSize: 22
    }

    // The stock ISO / WB lists run down the right edge over the viewfinder: the record button,
    // there too, steps aside while one is open. Found by name once its loader has made it.
    property var isoWbRoot: null
    property var isoWbLists: []
    property int isoWbSearch: 0
    function findNamed(item, name, depth) {
        if (!item || depth > 14) return null;
        if (item.objectName === name) return item;
        var ch = item.children || [];
        for (var i = 0; i < ch.length; i++) {
            var r = findNamed(ch[i], name, depth + 1);
            if (r) return r;
        }
        return null;
    }
    function isoWbOpen() {
        // The whole stock tree is walked at most every 2 s until the selector exists.
        if (!isoWbRoot && liveviewLoader.item && (isoWbSearch++ % 10) === 0) {
            isoWbRoot = findNamed(liveviewLoader.item, "IsoWBSelector_root", 0);
            if (isoWbRoot) {
                var names = ["IsoWbSelector_iso", "IsoWbSelector_wb", "IsoWbSelector_manualWb"], found = [];
                for (var n = 0; n < names.length; n++) { var l = findNamed(isoWbRoot, names[n], 0); if (l) found.push(l); }
                isoWbLists = found;
            }
        }
        if (!isoWbRoot || !isoWbRoot.visible) return false;
        for (var i = 0; i < isoWbLists.length; i++) if (isoWbLists[i].visible) return true;
        return false;
    }
    property bool isoWbShown: false
    Timer { interval: 200; repeat: true; running: recorder.videoMode && rec.session === "up"; onTriggered: root.isoWbShown = root.isoWbOpen() }

    // On-screen record button: the same start and stop as the shutter's full press.
    Item {
        id: recButton
        objectName: "x2vRecordButton"
        z: 100016
        width: 120
        height: 120
        x: parent.width - width - 22
        y: 410
        visible: recorder.videoMode && rec.session === "up" && !videoGallery.visible && !root.settingsOpen && !root.isoWbShown
        readonly property bool recording: rec.phase === "recording"
        readonly property bool busy: ["starting", "finalizing", "entering", "exiting"].indexOf(rec.phase) >= 0
        Rectangle {
            anchors.centerIn: parent
            width: 100; height: 100; radius: 50
            color: recButtonArea.pressed ? "#99000000" : "#59000000"
            border.color: "#F2F2F2"; border.width: 5
        }
        Rectangle {
            anchors.centerIn: parent
            width: recButton.recording ? 38 : 72
            height: width
            radius: recButton.recording ? 7 : width / 2
            color: recButton.busy ? "#8A4A47" : "#E5332D"
            Behavior on width { NumberAnimation { duration: 120 } }
        }
        MouseArea {
            id: recButtonArea
            anchors.fill: parent
            enabled: !recButton.busy
            onClicked: {
                root.uiLog("rec_button", {phase: rec.phase});
                bodyKeys.recordToggle();
            }
        }
    }

    property bool rawHistogramEnabled: false
    property var rawExposureFrame: null
    property double rawExposureNow: Date.now()
    readonly property var rawExposureStatus: ExposureAssistData.decode(rawExposureFrame, rawExposureNow)
    readonly property var exposureLiveModel: liveviewLoader.item ? liveviewLoader.item.viewModel : null
    property var nativeHistogramLoader: null
    function readHistogramPreference() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///blackbox/x2v-native-20261011/product/raw-histogram.enabled");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) root.rawHistogramEnabled = String(xhr.responseText || "").trim() === "1";
        };
        xhr.send();
    }
    function setHistogramPreference(enabled) {
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///blackbox/x2v-native-20261011/product/raw-histogram.enabled");
        xhr.onreadystatechange = function () { if (xhr.readyState === 4) root.readHistogramPreference(); };
        xhr.send(enabled ? "1\n" : "0\n");
    }
    Timer {
        interval: 250; repeat: true; triggeredOnStart: true
        running: root.rawHistogramEnabled && recorder.videoMode && rec.session === "up"
        onTriggered: {
            root.rawExposureNow = Date.now();
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/x2v-live/exposure-raw.json");
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) return;
                try { root.rawExposureFrame = JSON.parse(xhr.responseText); }
                catch (error) { root.rawExposureFrame = null; }
            };
            xhr.send();
        }
    }
    Timer {
        interval: 700; repeat: true; triggeredOnStart: true
        running: exposureAssist.visible && !root.nativeHistogramLoader && !!liveviewLoader.item
        onTriggered: root.nativeHistogramLoader = root.findNamed(liveviewLoader.item, "histogram_loader", 0)
    }
    Binding {
        target: root.nativeHistogramLoader; property: "visible"; value: false
        when: exposureAssist.visible && !!root.nativeHistogramLoader
        restoreMode: Binding.RestoreBindingOrValue
    }
    ExposureAssistOverlay {
        id: exposureAssist
        anchors.fill: parent
        z: 100012
        visible: root.rawHistogramEnabled && recorder.videoMode && rec.session === "up" && !videoGallery.visible &&
                 !root.settingsOpen && !root.isoWbShown && !root.focusMagnify &&
                 !drive.driveVisible && mainContentLoader.item && mainContentLoader.item.state === "liveview" &&
                 !(experimentalUiLoader.item && experimentalUiLoader.item.exposureTabs &&
                   experimentalUiLoader.item.exposureTabs.selectedParameter !== "")
        interactionAllowed: !!root.exposureLiveModel && root.exposureLiveModel.touchInputAllowed
        histogramData: root.rawExposureStatus.histogram
        histogramValid: root.rawExposureStatus.valid
        histogramAxis: root.rawExposureStatus.histogramAxis
        rawHighValid: root.rawExposureStatus.highValid
        rawLowValid: root.rawExposureStatus.lowValid
        high: root.rawExposureStatus.high
        low: root.rawExposureStatus.low
        avoidRects: {
            var boxes=[];
            if (recButton.visible) boxes.push(Qt.rect(recButton.x-8, recButton.y-8, recButton.width+16, recButton.height+16));
            var vm=root.exposureLiveModel;
            if (vm && vm.canShowFocusPoint) {
                var r=vm.focusRegion;
                if (r && r.width>0 && r.height>0 && r.width<=1 && r.height<=1)
                    boxes.push(Qt.rect(r.x*root.width-8,r.y*root.height-8,r.width*root.width+16,r.height*root.height+16));
            }
            return boxes;
        }
    }

    RecordingOverlay {
        id: recordingOverlay
        anchors.fill: parent
        z: 100015
        onStatusTextChanged: root.uiLog("badge", {text: statusText})
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
                // Whatever the file held before this GUI started is history, not a command.
                if (!root.guiCmdPrimed) { root.guiCmdPrimed = true; root.lastGuiCmd = cmd; return; }
                if (!cmd || cmd === root.lastGuiCmd) return;
                root.lastGuiCmd = cmd;
                if (cmd === "gallery") { root.openGallery(); shotDelay.name = "prr-gui-gallery"; shotDelay.restart(); }
                else if (cmd === "play") { root.playClip(); shotDelay.interval = 1800; shotDelay.name = "prr-gui-player"; shotDelay.restart(); }
                else if (/^shot\d*$/.test(cmd)) root.screenshot("prr-gui-cmd");
                else if (cmd === "home") { playbackController.stop(); videoGallery.visible = false; shotDelay.name = "prr-gui-home"; shotDelay.restart(); }
                else if (/^expmode\d*-[0-3]$/.test(cmd)) {
                    if (liveviewLoader.item) liveviewLoader.item.viewModel.setExpMode(Number(cmd.charAt(cmd.length - 1)));
                }
                else if (/^csexpmode\d*-[0-3]$/.test(cmd)) {
                    if (root.mainModel()) root.mainModel().controlScreen.setExpMode(Number(cmd.charAt(cmd.length - 1)));
                }
                else if (/^histogramtoggle\d*$/.test(cmd)) { if (experimentalUiLoader.item) experimentalUiLoader.item.toggleHistogram(); }
                else if (cmd === "record") recorder.start();
                else if (cmd === "stoprec") recorder.stop();
                else if (/^shutter/.test(cmd)) { root.uiLog("shutter_ignored", {source: "gui_cmd"}); }
                else if (cmd === "video") recorder.setVideoMode(true);
                else if (cmd === "photo") recorder.setVideoMode(false);
                else if (cmd === "settings" || cmd === "format") {
                    if (experimentalUiLoader.item) {
                        experimentalUiLoader.item.experimentalOpen = true;
                        experimentalUiLoader.item.settingsPage = cmd === "format" ? "format" : "";
                    }
                    shotDelay.name = "prr-gui-" + cmd; shotDelay.restart();
                }
                else if (cmd === "closesettings") { if (experimentalUiLoader.item) experimentalUiLoader.item.experimentalOpen = false; }
                // codec<N>-<k>: pick profile k, as a tap on the format page does; N only makes the command new.
                else if (/^codec\d*-\d$/.test(cmd)) {
                    var k = Number(cmd.charAt(cmd.length - 1));
                    if (k < profileSelection.profiles.length) profileSelection.select(profileSelection.profiles[k].id);
                    shotDelay.name = "prr-gui-codec"; shotDelay.restart();
                }
            };
            xhr.send();
        }
    }
    property string lastGuiCmd: ""
    property bool guiCmdPrimed: false

    // BMP: compressing a PNG on this thread held the GUI for about a second, long enough for
    // the recording clock to skip a second in acceptance runs.
    function screenshot(name) {
        root.contentItem.grabToImage(function (r) {
            r.saveToFile("/blackbox/x2v-native-20261011/" + name + ".bmp");
        });
    }
    // Telemetry for acceptance runs, in tmpfs: what the screen shows twice a second, and the last
    // events in order. QML console output reaches no file on this camera.
    property var uiEvents: []
    function uiLog(event, detail) {
        console.info("X2V_PRR_GUI " + JSON.stringify({event: event, timestampMs: Date.now(), detail: detail}));
        uiEvents.push({t: Date.now(), e: event, d: detail});
        if (uiEvents.length > 80) uiEvents.shift();
    }
    function stockState() { return mainContentLoader.item ? String(mainContentLoader.item.state) : ""; }
    property bool videoMenuPending: false
    property double videoMenuDeadline: 0
    property double afNavigationUntil: 0
    function beginVideoMenu() {
        videoMenuPending = true;
        videoMenuDeadline = Date.now() + 2500;
        writeAfContext();
        menuAfWait.start();
    }
    Timer {
        id: menuAfWait
        interval: 50; repeat: true
        onTriggered: {
            var vm = liveviewLoader.item ? liveviewLoader.item.viewModel : null;
            if (vm && !vm.inSession && root.mainModel()) {
                afNavigationUntil = Date.now() + 1000;
                videoMenuPending = false;
                stop();
                root.mainModel().toggle_screen("control_screen", {});
                root.uiLog("af_menu_released", {});
            } else if (Date.now() > videoMenuDeadline) {
                stop(); videoMenuPending = false;
                root.uiLog("af_menu_timeout", {});
            }
        }
    }
    property string lastAfContext: ""
    Connections {
        target: liveviewLoader.item ? liveviewLoader.item.viewModel : null
        function onRequestedLvMainStateChanged() { root.writeAfContext(); }
        function onVideoAfContextRequested() { root.writeAfContext(); }
        function onVideoExposureChangeFinished(result) { root.uiLog("exposure_change", {result: result}); }
    }
    function writeAfContext() {
        var vm = liveviewLoader.item ? liveviewLoader.item.viewModel : null;
        var selector = vm ? String(vm.requestedLvMainState) : "";
        var exposureNavigation = vm && (vm.videoExposureChangePending ||
            selector === "exp_mode_selector" || selector === "popup_exp_mode");
        var context = !modeTransition.active && recorder.videoMode && rec.session === "up" && root.stockState() === "liveview" &&
                      !videoMenuPending && !exposureNavigation && Date.now() >= afNavigationUntil && !videoGallery.visible && !root.settingsOpen && !drive.driveVisible ? "viewfinder" : "navigation";
        if (context === lastAfContext) return;
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///tmp/x2v-product/af-context");
        xhr.send(context);
        lastAfContext = context;
    }
    function writeTelemetry() {
        writeAfContext();
        var fv = liveviewLoader.item ? liveviewLoader.item.viewModel : null;
        var s = {focusPoint: FocusProxy.Camera.focus_point,
                 expMode: fv ? fv.expMode : -1, exposurePending: fv ? fv.videoExposureChangePending : false,
                 focusSession: fv ? fv.inSession : false,
                 focusCanChange: fv ? fv.canChangeFocusPoint : false,
                 focusTouch: fv ? fv.focusTouchAllowed : false,
                 focusVideoMove: fv ? fv.videoCanMoveFocusPoint : false,
                 afStatus: fv ? fv.afStatus : -1, afNav: liveviewLoader.item ? liveviewLoader.item.videoAfNavigation : false, screenStatus: liveviewLoader.item ? liveviewLoader.item.viewModel.screenStatus : -1, t: Date.now(), up: rec.uptime, seenAgeMs: rec.seenAt ? Date.now() - rec.seenAt : -1,
                 badge: recordingOverlay.statusText, badgeVisible: recordingOverlay.visible, notice: noticeText.visible ? noticeText.text : "",
                 modeSwitchActive:modeTransition.active,modeSwitchTarget:modeTransition.targetMode,
                 modeSwitchPainted:modeTransition.painted,
                 handoffSuppressedCount:mainContentLoader.item ? mainContentLoader.item.handoffSuppressedCount : 0,
                 phase: rec.phase, fresh: rec.fresh, mode: rec.mode, session: rec.session, profile: rec.profileId,
                 histogramEnabled: root.rawHistogramEnabled, histogramVisible: exposureAssist.visible, rawHistogramValid: root.rawExposureStatus.valid, rawHighValid: root.rawExposureStatus.highValid, rawHigh: root.rawExposureStatus.high, gallery: videoGallery.visible, clips: playbackController.clips.length, playing: playbackController.active,
                 firstClip: playbackController.clips.length ? playbackController.clips[0].id : "",
                 settings: !!root.settingsOpen, drive: drive.driveVisible, stock: root.stockState(),
                 keyHooked: root.keyHooked, browseHooked: root.browseHookItem !== null,
                 nativeShutter: root.nativeShutter, keyOverride: root.videoShutterOverride,
                 focusMagnify: root.focusMagnify, playbackPhase: playbackController.phase,
                 canPause: playbackController.canPause, canResume: playbackController.canResume,
                 pvShown: residentPreview.shown, pvVisible: residentPreview.visible, ispView: root.ispView,
                 recButton: {visible: recButton.visible, x: recButton.x + recButton.width / 2, y: recButton.y + recButton.height / 2},
                 isoWb: root.isoWbShown, events: uiEvents};
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///tmp/x2v-product/gui-state.json");
        xhr.send(JSON.stringify(s));
    }
    Timer { interval: 500; repeat: true; running: true; onTriggered: root.writeTelemetry() }
    // Which Qt keys the stock mapping gives each body function, for the acceptance runs' key
    // injection: read from KeyFn itself rather than found by pressing buttons.
    function logKeymap() {
        var fns = ["Menu", "Play", "Escape", "Select", "Enter", "HalfPress", "Ael", "Afd", "Cross", "Square",
                   "JstkCenter", "JstkUp", "JstkDown", "JstkLeft", "JstkRight", "ZoomIn", "Left", "Right", "Up", "Down"];
        var buttons = ["E_Button_FullPress", "E_Button_HalfPress", "E_Button_Play", "E_Button_Menu", "E_Button_IsoWb", "E_Button_Afd", "E_Button_Ael"];
        var map = {}, keys = [];
        for (var c = 32; c < 127; c++) keys.push(c);
        for (var s = 0x01000000; s < 0x01000100; s++) keys.push(s);
        try {
            for (var n = 0; n < keys.length; n++) {
                var k = keys[n];
                for (var i = 0; i < fns.length; i++)
                    if (KeyFn[fns[i]] !== undefined && KeyFn.isFn(k, 0, KeyFn[fns[i]])) (map[fns[i]] = map[fns[i]] || []).push(k);
                for (var j = 0; j < buttons.length; j++)
                    if (KeyFn[buttons[j]] !== undefined && KeyFn.isButton(KeyFn[buttons[j]], k)) (map[buttons[j]] = map[buttons[j]] || []).push(k);
            }
        } catch (e) { map.error = String(e); }
        uiLog("keymap", map);
    }
    Connections {
        target: rec
        function onPhaseChanged() { root.uiLog("phase", {phase: rec.phase}); }
        function onFreshChanged() { root.uiLog("fresh", {fresh: rec.fresh, up: rec.uptime}); }
        function onSessionChanged() { root.uiLog("session", {session: rec.session}); }
        function onModeChanged() { root.uiLog("mode", {mode: rec.mode}); }
    }
    Connections {
        target: mainContentLoader.item
        ignoreUnknownSignals: true
        function onStateChanged() {
            var s = root.stockState();
            root.uiLog("stock_state", {state: s});
            // The prompt turned the stock live view off: the viewfinder screen needs it reported on.
            if (s === "control_screen" && root.lastStockState === "usb_connected" && recorder.videoMode && rec.session === "up")
                root.writeCmd("live_view_on");
            // A still on the RAW graph hangs until the battery comes out. The shutter is gated;
            // anything that still reaches exposing (a leftover photo control, a touch) is cancelled.
            if (s === "exposing" && recorder.videoMode && rec.session === "up") {
                root.uiLog("still_blocked", {from: root.lastStockState});
                root.writeCmd("live_view_on");
            }
            root.lastStockState = s;
        }
    }
    Connections {
        target: videoGallery
        function onVisibleChanged() {
            root.uiLog("gallery", {visible: videoGallery.visible, clips: playbackController.clips.length});
            if (videoGallery.visible) root.focusMagnify = false;
            // The gallery took the focus; left with it, the body keys reached nothing.
            if (!videoGallery.visible) root.restoreStockFocus();
        }
    }
    Connections {
        target: experimentalUiLoader.item
        ignoreUnknownSignals: true
        function onExperimentalOpenChanged() {
            if (!experimentalUiLoader.item.experimentalOpen) root.restoreStockFocus();
            else root.focusMagnify = false;
        }
    }
    function restoreStockFocus() {
        if (liveviewLoader.item) liveviewLoader.item.forceActiveFocus();
        root.uiLog("focus", {to: "liveview"});
    }

    property bool focusMagnify: false
    property bool liveviewZoomPatched: false
    function toggleFocusMagnify() {
        if (!recorder.videoMode || rec.session !== "up" || videoGallery.visible) return;
        focusMagnify = !focusMagnify;
        root.uiLog("focus_magnify", {on: focusMagnify, isp: root.ispView});
    }
    function patchLiveviewZoom() {
        var img = liveviewLoader.item;
        if (!img || !img.viewModel) return;
        var vm = img.viewModel;
        if (liveviewZoomPatched) return;
        try {
            vm.zoomInCurrentFocusPoint = function () { root.toggleFocusMagnify(); };
            vm.zoom = function (x, y) { root.toggleFocusMagnify(); };
            vm.exitZoom = function () { root.focusMagnify = false; };
            liveviewZoomPatched = true;
            root.uiLog("zoom_hook", {installed: true});
        } catch (e) {
            root.uiLog("zoom_hook", {installed: false, error: String(e)});
        }
    }
    Connections {
        target: rec
        function onSessionChanged() { if (rec.session !== "up") root.focusMagnify = false; }
        function onModeChanged() { if (rec.mode !== "video") root.focusMagnify = false; }
    }

    Item {
        id: magnifyLayer
        z: 100008
        anchors.fill: parent
        visible: root.focusMagnify && rec.session === "up" && !videoGallery.visible && !root.settingsOpen
        clip: true
        Rectangle { anchors.fill: parent; color: "black" }
        Image {
            width: parent.width * 4
            height: parent.height * 4
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            source: residentPreview.front ? pvB.source : pvA.source
        }
    }

    Timer { interval: 250; repeat: true; running: true; onTriggered: root.pollRec() }
    Timer { interval: 100; repeat: true; running: rec.phase === "recording" || recorder.shownSeconds > 0; onTriggered: recorder.tick() }
    Component.onCompleted: { root.readHistogramPreference(); root.writeCmd("hello"); Qt.callLater(root.logKeymap); }
    // Playback goes through toggle_screen, not keyPressed: its hook needs no key hook.
    Timer { interval: 800; running: !!mainContentLoader.item; repeat: true; onTriggered: { root.installKeyHook(); root.installBrowseHook(); root.patchLiveviewZoom(); } }
    Timer { interval: 2500; running: true; onTriggered: root.screenshot("prr-gui-live") }
}
