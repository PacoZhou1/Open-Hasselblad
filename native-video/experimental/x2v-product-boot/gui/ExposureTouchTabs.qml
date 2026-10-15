import QtQuick
import "qrc:/qt/qml/app/qml/mainmenu" as NativeMenu

// Native ControlScreenViewModel is the sole value and command authority.
// Exposure compensation is Camera.exposure_quick_adjust (rear wheel), not
// flash evModel. Stock canSetState("exposure_adjust") is flash-only.
Item {
    id: root
    objectName: "x2vExposureTouchTabs"
    property var nativeModel: null
    property bool interactionAllowed: false
    property string selectedParameter: ""
    readonly property var states: ["aperture", "shutterspeed", "iso", "exposure_adjust"]
    readonly property var labels: ["光圈", "快门", "ISO", "曝光补偿"]
    // Stock ControlScreenViewModel: E_ExpMode_Manual is 0. In M the fourth tab
    // is the light-meter over/under, not EV compensation.
    readonly property bool manualExposure: !!nativeModel && nativeModel.expMode === 0
    readonly property real evStops: {
        if (!nativeModel || typeof nativeModel.quickAdjust !== "number") return 0;
        return nativeModel.quickAdjust / 12;
    }
    readonly property real meterStops: {
        if (!nativeModel || typeof nativeModel.balanceScaleEvValue !== "number") return 0;
        return nativeModel.balanceScaleEvValue;
    }
    readonly property bool meterValid: !!nativeModel && nativeModel.balanceScaleValid === true
    readonly property string evLabel: {
        var v = root.evStops;
        return (v > 0 ? "+" : "") + v.toFixed(1) + " EV";
    }
    readonly property string meterLabel: {
        if (!root.meterValid) return "—";
        var v = root.meterStops;
        return (v > 0 ? "+" : "") + v.toFixed(1) + " EV";
    }
    function canEdit(ix) {
        if (!interactionAllowed || !nativeModel) return false;
        if (ix === 3) {
            if (root.manualExposure) return false;
            if (nativeModel.canChangeEvAdj === true) return true;
            if (nativeModel.quickAdjustEnabled === true) return true;
            if (typeof nativeModel.stepQuickAdjust === "function") return true;
            if (typeof nativeModel.setQuickAdjust === "function") return true;
        }
        return typeof nativeModel.canSetState === "function" && nativeModel.canSetState(states[ix]);
    }
    function valueText(ix) {
        if (!nativeModel) return "—";
        if (ix === 0) return "f/" + nativeModel.aperture;
        if (ix === 1) return String(nativeModel.shutterSpeed);
        if (ix === 2) return nativeModel.isoAndAutoAsString;
        return root.manualExposure ? root.meterLabel : root.evLabel;
    }
    function openParameter(ix) {
        if (!canEdit(ix)) return false;
        selectedParameter = states[ix]; return true;
    }
    function choices() {
        if (!nativeModel) return [];
        if (selectedParameter === "aperture") return nativeModel.apertureValues;
        if (selectedParameter === "shutterspeed") return nativeModel.shutterSpeedValues;
        if (selectedParameter === "iso") return nativeModel.isoValues;
        return [];
    }
    function selectValue(value) {
        var ix = states.indexOf(selectedParameter);
        if (ix < 0 || !canEdit(ix) || choices().indexOf(value) < 0) return false;
        if (ix === 0) nativeModel.setApertureFromString(value);
        else if (ix === 1) nativeModel.setShutterSpeedFromString(value);
        else if (ix === 2) nativeModel.setIsoFromString(value);
        else return false;
        selectedParameter = ""; return true;
    }
    function stepEv(direction) {
        if (selectedParameter !== "exposure_adjust" || !canEdit(3) || !nativeModel) return false;
        if (typeof nativeModel.stepQuickAdjust === "function") {
            nativeModel.stepQuickAdjust(direction);
            return true;
        }
        if (typeof nativeModel.setQuickAdjust === "function" && typeof nativeModel.quickAdjust === "number") {
            var step = nativeModel.adjStepInc > 0 ? nativeModel.adjStepInc : 4;
            nativeModel.setQuickAdjust(nativeModel.quickAdjust + direction * step);
            return true;
        }
        return false;
    }
    onInteractionAllowedChanged: if (!interactionAllowed) selectedParameter = ""
    onManualExposureChanged: if (manualExposure && selectedParameter === "exposure_adjust") selectedParameter = ""
    Row {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.leftMargin: 8; anchors.rightMargin: 8; anchors.bottomMargin: 8; height: 96
        Repeater { model: 4
            delegate: Rectangle {
                required property int index
                objectName: "exposureTab" + index
                width: (root.width - 16) / 4; height: 96; color: tap.pressed ? "#4a4a4a" : "#171717"
                border.width: 1; border.color: "#434343"
                readonly property bool meterTab: index === 3 && root.manualExposure
                Text {
                    x: 24; y: 12; text: root.labels[parent.index]
                    color: parent.meterTab ? "#8a8a8a" : "#bdbdbd"; font.pixelSize: 21
                }
                Text {
                    x: 24; y: 40
                    text: root.valueText(parent.index)
                    color: parent.meterTab ? "#7a7a7a" : (root.canEdit(parent.index) ? "white" : "#888888")
                    font.pixelSize: 32; font.weight: Font.Medium
                }
                Text { anchors.right: parent.right; rightPadding: 18; y: 16; text: root.canEdit(parent.index) ? "⌄" : ""; color: "#bdbdbd"; font.pixelSize: 25 }
                MouseArea { id: tap; anchors.fill: parent; enabled: root.canEdit(parent.index); onClicked: root.openParameter(parent.index) }
            }
        }
    }
    Item {
        anchors.fill: parent; visible: root.selectedParameter !== ""
        Rectangle { anchors.fill: parent; color: "#b0000000"; MouseArea { anchors.fill: parent; onClicked: root.selectedParameter = "" } }
        Rectangle {
            x: 152; y: 64; width: 720; height: 608; color: "#171717"; border.color: "#555555"
            NativeMenu.MenuHeader {
                id: header; width: parent.width; text: [{text: root.labels[root.states.indexOf(root.selectedParameter)] || ""}]; showBackArrow: true
                onClose: root.selectedParameter = ""
            }
            ListView {
                id: choiceList; y: header.height; width: parent.width; height: parent.height - y; clip: true
                model: root.choices(); visible: root.selectedParameter !== "exposure_adjust"
                delegate: Rectangle {
                    required property string modelData
                    width: choiceList.width; height: 88; color: choiceTap.pressed ? "#444444" : "transparent"
                    Text { anchors.centerIn: parent; text: parent.modelData; color: "white"; font.pixelSize: 32 }
                    Rectangle { height: 1; width: parent.width - 96; x: 48; anchors.bottom: parent.bottom; color: "#333333" }
                    MouseArea { id: choiceTap; anchors.fill: parent; onClicked: root.selectValue(parent.modelData) }
                }
            }
            Row {
                x: 48; y: header.height + 30; width: parent.width - 96; spacing: 16
                visible: root.selectedParameter === "exposure_adjust"
                Rectangle { width: 96; height: 88; color: minus.pressed ? "#555555" : "#303030"; Text { anchors.centerIn: parent; text: "−"; color: "white"; font.pixelSize: 40 } MouseArea { id: minus; anchors.fill: parent; onClicked: root.stepEv(-1) } }
                Text { width: 400; height: 88; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; text: root.evLabel; color: "white"; font.pixelSize: 40 }
                Rectangle { width: 96; height: 88; color: plus.pressed ? "#555555" : "#303030"; Text { anchors.centerIn: parent; text: "+"; color: "white"; font.pixelSize: 40 } MouseArea { id: plus; anchors.fill: parent; onClicked: root.stepEv(1) } }
            }
        }
    }
}
