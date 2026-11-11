import QtQuick
import com.hasselblad.proxies
import "qrc:/qt/qml/app/qml/controlscreen"

ControlScreenViewModel {
    property var videoExposureController: null
    function setExpMode(val: int) {
        if (videoExposureController) videoExposureController.setExpMode(val)
        else Camera.exp_mode = val
    }
    function setSettingsMode(val: int) {
        if (videoExposureController) videoExposureController.setSettingsMode(val)
        else System.settings_mode = val
    }
}
