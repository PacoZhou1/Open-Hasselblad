import QtQuick
import com.hasselblad.keys

// Video-mode start and stop come only from the on-screen record button.
// A full press in video mode is eaten and ignored: on the MODE21 graph it
// still reaches a still capture and hangs the body. Do not take Qt focus
// on this item: LiveViewOverlay needs activeFocus for WB / ISO / wheels.
Item {
    id: root
    objectName: "x2vBodyKeys"
    x: 0
    y: 0
    width: 0
    height: 0
    required property var recorder
    property var recordingProfiles: null
    property bool hardwareShutterReady: false
    property bool galleryOpen: false
    property bool settingsOpen: false
    property bool driveVisible: false
    property var stockFocus: null
    property var stockRoot: null
    property bool fullShutterDown: false
    property bool startCommandPending: false
    property bool hardwareStopPending: false
    readonly property bool idle: ["idle", "saved", "error"].indexOf(recorder.phase) >= 0
    readonly property bool gateActive: !!recorder.videoMode && !driveVisible
    readonly property int keyOverride: 0
    readonly property bool canStart: !!recordingProfiles && recordingProfiles.canRecord &&
        hardwareShutterReady && !!recorder.videoMode && !galleryOpen && !settingsOpen &&
        idle && !startCommandPending && recorder.stopNeedsRetry !== true
    focus: false
    activeFocusOnTab: false

    signal playRequested()

    function isFullPressKey(key) {
        try {
            if (typeof KeyFn !== "undefined" && typeof KeyFn.isButton === "function" &&
                KeyFn.E_Button_FullPress !== undefined &&
                KeyFn.isButton(KeyFn.E_Button_FullPress, key))
                return true;
        } catch (e) {}
        return key === 69;
    }
    function isFullPressEvent(event) { return !!event && isFullPressKey(event.key); }
    function isFnEvent(event, name) {
        if (!event || !name) return false;
        try {
            if (typeof KeyFn !== "undefined" && typeof KeyFn.isFn === "function" &&
                KeyFn[name] !== undefined && KeyFn.isFn(event.key, event.modifiers, KeyFn[name]))
                return true;
        } catch (e) {}
        return false;
    }
    function isFnListEvent(event, names) {
        for (var i = 0; i < names.length; i++)
            if (isFnEvent(event, names[i])) return true;
        return false;
    }
    function isPlayEvent(event) { return isFnEvent(event, "Play"); }
    function isHalfPressEvent(event) {
        if (isFnEvent(event, "HalfPress")) return true;
        try {
            if (typeof KeyFn !== "undefined" && typeof KeyFn.isButton === "function" &&
                KeyFn.E_Button_HalfPress !== undefined &&
                KeyFn.isButton(KeyFn.E_Button_HalfPress, event.key))
                return true;
        } catch (e) {}
        return !!event && event.key === 65;
    }
    function isZoomEvent(event) {
        if (isFnListEvent(event, ["ZoomIn", "JstkCenter"])) return true;
        try {
            if (typeof KeyFn !== "undefined" && typeof KeyFn.isButton === "function" &&
                KeyFn.E_Button_JstkClick !== undefined &&
                KeyFn.isButton(KeyFn.E_Button_JstkClick, event.key))
                return true;
        } catch (e) {}
        return false;
    }
    function semanticShutterInput(action, released) {
        if (action === "half_press") return false;
        if (action !== "full_press" || !recorder.videoMode) return false;
        if (released) { fullShutterDown = false; return true; }
        fullShutterDown = true;
        return true;
    }
    function recordToggle() {
        if (!recorder.videoMode || galleryOpen || settingsOpen) return false;
        if (recorder.phase === "recording" || recorder.stopNeedsRetry === true) {
            stopRecording();
            return true;
        }
        if (recorder.phase === "starting" || startCommandPending) {
            hardwareStopPending = true;
            return true;
        }
        if (canStart) return startRecording();
        return false;
    }
    function reconcileHardwareStop() {
        if (hardwareStopPending && recorder.phase === "recording") {
            hardwareStopPending = false;
            Qt.callLater(function () { if (recorder.phase === "recording") root.stopRecording(); });
        } else if (["idle", "saved", "error"].indexOf(recorder.phase) >= 0) {
            hardwareStopPending = false;
        }
    }
    function startRecording() {
        if (!canStart) return false;
        startCommandPending = true;
        commandDeadline.restart();
        if (recorder.start() === false) {
            startCommandPending = false;
            commandDeadline.stop();
            return false;
        }
        return true;
    }
    function stopRecording() { recorder.stop(); }
    function semanticPlay() { playRequested(); return true; }

    Timer {
        id: commandDeadline
        interval: 10000
        onTriggered: root.startCommandPending = false
    }
    Connections {
        target: root.recorder
        function onPhaseChanged() {
            root.startCommandPending = false;
            commandDeadline.stop();
            root.reconcileHardwareStop();
        }
        function onVideoModeChanged() {
            if (!root.recorder.videoMode) {
                root.fullShutterDown = false;
                root.hardwareStopPending = false;
            }
        }
    }
}
