import QtQuick
import com.hasselblad.proxies
import com.hasselblad.constants
import com.hasselblad.types
import "qrc:/qt/qml/app/qml/viewmodels"
import "qrc:/qt/qml/app/qml/liveview"

// Keep the stock type: stock indicators take a typed LiveviewViewModel.
// Only focus-point movement may bypass an ongoing video continuous-AF session.
LiveviewViewModel {
    id: root
    property bool videoAfNavigation: false
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
