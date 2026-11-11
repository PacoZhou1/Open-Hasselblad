import QtQuick
import com.hasselblad.proxies
import com.hasselblad.constants
import com.hasselblad.types
import "qrc:/qt/qml/app/qml/viewmodels"
import "qrc:/qt/qml/app/qml/liveview"
import "ExposureModeChange.js" as ExposureModeChange

// Keep the stock type: stock indicators take a typed LiveviewViewModel.
// Only focus-point movement may bypass an ongoing video continuous-AF session.
LiveviewViewModel {
    id: root
    property bool videoAfNavigation: false
    property bool touchVotOwnsInput: false
    property bool videoExposureChangePending: false
    property var videoExposureCommand: null
    signal videoAfContextRequested()
    signal videoExposureChangeFinished(string result)
    onVideoAfNavigationChanged: {
        if (!videoAfNavigation && videoExposureChangePending) {
            exposureChangeWait.stop()
            videoExposureCommand = null
            videoExposureChangePending = false
            videoAfContextRequested()
        }
    }
    function exposureSnapshot() {
        return {mode: expMode, settings: settingsMode, inSession: inSession, exposing: exposing}
    }
    function applyExposureChange(kind, value) {
        if (kind === "mode") Camera.exp_mode = value
        else if (kind === "settings") System.settings_mode = value
        else CameraUI.cycleExpMode()
    }
    function requestExposureChange(kind, value) {
        if (!videoAfNavigation) {
            applyExposureChange(kind, value)
            return
        }
        videoExposureCommand = ExposureModeChange.request(kind, value, exposureSnapshot(), Date.now())
        videoExposureChangePending = true
        videoAfContextRequested()
        exposureChangeWait.restart()
    }
    function setExpMode(val: int) { requestExposureChange("mode", val) }
    function setSettingsMode(val: int) { requestExposureChange("settings", val) }
    function cycleExpMode() {
        closeSelectorOverlays()
        requestExposureChange("cycle", -1)
    }
    Timer {
        id: exposureChangeWait
        interval: 40
        repeat: true
        onTriggered: {
            var result = ExposureModeChange.step(root.videoExposureCommand, root.exposureSnapshot(), Date.now())
            if (result.action === "apply") {
                root.applyExposureChange(result.kind, result.value)
            } else if (result.action === "done" || result.action === "timeout" || result.action === "none") {
                stop()
                root.videoExposureCommand = null
                root.videoExposureChangePending = false
                root.videoAfContextRequested()
                root.videoExposureChangeFinished(result.action)
            }
        }
    }
    readonly property bool videoFocusSession: videoAfNavigation && inSession &&
        !exposing && afStatus === HblmTypes.E_AutoFocusStatus_RunningCont
    readonly property bool videoCanMoveFocusPoint: videoFocusSession &&
        !isZoomed && !swipingControlScreen && canChangeFocusPoint
    readonly property bool focusTouchAllowed: canMoveFocusPointBackScreen ||
        (videoCanMoveFocusPoint && screenBack && canMoveFocusTp)
    readonly property bool focusEvfAllowed: canMoveFocusPointEvf ||
        (videoCanMoveFocusPoint && screenEVF && evfTpMoveFocus)

    // Reuse the stock geometry, crop bounds, grid stepping and key map.
    AutoFocus {
        id: videoPoint
        focusRegion: root.focusRegion
        focusRegionCentrePoint: root.focusRegionCentrePoint
        customFocusSizeIndex: root.afSizeIndex
        currentCropMode: Camera.crop_mode_current
        focusArea: Camera.focus_area
        focusSize: Constants.combinedToSize(Camera.focus_size)
        onSetCameraFocusPoint: (center, tp)=> {
            if (root.touchVotOwnsInput) return
            if (root.inSession && !root.videoCanMoveFocusPoint) return
            var pt = Math.round(center.x * 10000) | (Math.round(center.y * 10000) << 16)
            if (pt === Camera.focus_point) {
                root.repaintAfIndicator()
            } else {
                if (tp) pt |= 0xC0000000
                Camera.focus_point = pt
            }
        }
    }

    function setFocusPointFromTouchPoint(pt: point) : point {
        afTouchPoint = videoPoint.setFocusPointFromTouchPoint(pt)
        return afTouchPoint
    }
    function moveFocusPointWithKey(event) : bool {
        return videoPoint.moveFocusPointWithKey(event)
    }
    function setFocusPoint(pt: point) {
        videoPoint.setFocusPoint(pt, true)
    }
    function resetFocusPoint() {
        videoPoint.setFocusPoint(Constants.defaultFocusPoint, false)
    }
}
