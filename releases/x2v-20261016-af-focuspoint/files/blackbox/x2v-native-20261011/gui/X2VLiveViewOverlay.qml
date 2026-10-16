/*
 * vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab fileencoding=utf-8
 * encoding: utf-8
 * -*- coding: utf-8 -*-
 *
 * Copyright 2020 Victor Hasselblad AB.
 *
 * All information contained in or disclosed by this document is confidential
 * and proprietary of Victor Hasselblad AB. By accepting this material the
 * recipient agrees that this material and the information contained therein
 * will be held in confidence and will not be reproduced in whole or in part
 * without written permission from Victor Hasselblad AB.
 */

pragma ComponentBehavior: Bound

import QtQuick
import "qrc:/qt/qml/app/qml/liveview"

import com.hasselblad.types
import com.hasselblad.input
import com.hasselblad.constants
import com.hasselblad.keys
import com.hasselblad.objectdetection

import "qrc:/qt/qml/app/qml/components"
import "qrc:/qt/qml/app/qml/components/controls"
import "qrc:/qt/qml/app/qml/viewmodels"
import "qrc:/qt/qml/app/qml/scripts/Keys.js" as MKeys

FocusScope {
    objectName: "LiveViewOverlay_root"
    id: root
    property bool videoAfNavigation: false
    property bool focusTouchAllowed: viewModel ? viewModel.canMoveFocusPointBackScreen : false
    signal videoMenuRequested()
    focus: true
    property LiveviewViewModel viewModel: null
    readonly property real textSize: 42
    readonly property rect focusIndicatorRegion: {
        if (af_indicator.visible === true) {
            return af_indicator.afPaintedRegion
        } else if (mfassistDistanceScaleIndicator.visible === true) {
            return mfassistDistanceScaleIndicator.afPaintedRegion
        } else {
            return Qt.rect(0,0,0,0)
        }
    }

    // Show info or not (ISO/WB and focus will always be visible):
    property bool infoVisible: false
    property bool showOnlyBottomRow: false
    property bool dragAreaPressed: false
    property bool preventSwipe: spirit_mode_loader.active || viewModel.isZoomed
    readonly property bool canOpenPopupsWithTouch: (root.state === "" || root.state === "spiritlevel") &&
                                                   viewModel.touchInputAllowed
    readonly property bool overlayOff: (viewModel.isZoomed || root.state === "evf_brightness") ||
                                       root.state === "iso_wb_selector" || root.state === "object_detection_selector"
    readonly property bool popupActive: popup.active || spirit_mode_loader.active
    readonly property bool idle: root.state === "" || root.state === "spiritlevel"
    readonly property double borderMarginX: Constants.liveViewBorderNormalMarginX
    readonly property double borderMarginY: Constants.liveViewBorderNormalMarginY
    property bool isStoppedDown: false


    onViewModelChanged: {
        if (viewModel) {
            viewModel.notifyAvOutOfRange.connect(apertureIndicator.notifyAvOutOfRange)
            viewModel.notifyTvOutOfRange.connect(shutterspeedIndicator.notifyTvOutOfRange)
            viewModel.preventSwipe = Qt.binding(function() { return root.preventSwipe})

            thumbwheelHandler.setTvSelected.connect(viewModel.setTvSelected)
            thumbwheelHandler.setAvSelected.connect(viewModel.setAvSelected)
            thumbwheelHandler.setSvSelected.connect(viewModel.setSvSelected)
            thumbwheelHandler.stepProgramShift.connect(viewModel.stepProgramShift)
            thumbwheelHandler.stepQuickAdjust.connect(viewModel.stepQuickAdjust)
            thumbwheelHandler.setObjectLeft.connect(viewModel.moveToObjectLeft)
            thumbwheelHandler.setObjectRight.connect(viewModel.moveToObjectRight)
        }
    }

    function handleButtonRelease(event)
    {
        console.info("liveview overlay released", event.key)
        if (event.isAutoRepeat) {
            event.accepted = false
        } else if (viewModel.capabilityStopDown &&  MKeys.pressedFnAcc(KeyFn.StopDown, event)) {
            viewModel.setStopDown(false)
            root.isStoppedDown = false
        } else if (MKeys.pressedFnAcc(KeyFn.FocusMode, event)) {
            if (afPointSelectionTimer.running) {
                afPointSelectionTimer.stop()
                // Short press of AF/MF.
                viewModel.cycleFocusMode()
            }
        } else if (MKeys.pressedFnAcc(KeyFn.Shift, event)) {
            shortPressTimer.handleKeyReleased(event)
        }
    }

    function tapToAf()
    {
        if (af_indicator.visible === true) {
            af_indicator.tapToAf()
        } else if (mfassistDistanceScaleIndicator.visible === true) {
            mfassistDistanceScaleIndicator.tapToAf()
        } else {
            console.warn("Tap to AF is currently not available")
        }
    }

    function moveObjectBoxWithKey(event) : bool
    {
        if (!MKeys.pressedFn(KeyFn.JstkNavKey, event)) {
            return false
        }

        var ev2 = event
        ev2.key = viewModel.rotateJstkNavKey(event.key)

        if (MKeys.pressedFnList([KeyFn.JstkUp, KeyFn.JstkDown], ev2)) {
            // Block these keys
            return true
        } else if (MKeys.pressedFnList([KeyFn.JstkLeft, KeyFn.JstkUpLeft, KeyFn.JstkDownLeft], ev2)) {
            viewModel.moveToObjectLeft()
        } else if (MKeys.pressedFnList([KeyFn.JstkRight, KeyFn.JstkUpRight, KeyFn.JstkDownRight], ev2)) {
            viewModel.moveToObjectRight(false)
        } else {
            return false
        }
        return true
    }

    Loader {
        id: cropLoader
        anchors.fill: parent
        enabled: active
        active: root.viewModel.currentCropMode !== HblmTypes.E_CropMode_None
        source: Constants.appPrefix + "components/CropOverlay.qml"
        onLoaded: {
            item.cropMode = Qt.binding(function() { return root.viewModel.currentCropMode })
            item.cropFactors = Qt.binding(function() { return root.viewModel.cropFactors })
            item.opacity = Qt.binding(function() { return root.viewModel.cropOpacity })
            item.blockTouch = Qt.binding(function() { return root.viewModel.screenBack })
        }
    }

    ThumbWheelHandler {
        id: thumbwheelHandler
        attachedLens: root.viewModel.attachedLens
        cameraType: root.viewModel.cameraType
        expMode: root.viewModel.expMode
        tvSelected: root.viewModel.tvSelected
        avSelected: root.viewModel.avSelected
        svSelected: root.viewModel.svSelected
        avList: root.viewModel.avList
        tvList: root.viewModel.tvList
        svList: root.viewModel.svList
        quickAdjust: root.viewModel.quickAdjust
        eShutter: root.viewModel.eShutter
        quickAdjustEnabled: root.viewModel.quickAdjustEnabled
        canSelectObject: root.viewModel.canSelectObjectBox
        canChangeAv: root.viewModel.canChangeAv
        canChangeTv: root.viewModel.canChangeTv
        canChangeSv: root.viewModel.canChangeSv
    }

    Rectangle {
        id: fdPriorityArea
        anchors.centerIn: parent
        width: root.width * Constants.fdPrioAreaSize.width
        height: root.height * Constants.fdPrioAreaSize.height
        visible: root.viewModel.showObjectIndicator && root.viewModel.debugObjectDetection &&
                 root.viewModel.objectDetectionMulti
        color: "transparent"
        border.color: Constants.colorRed
    }

    Rectangle {
        id: focusGrid
        anchors.centerIn: parent
        width: root.width * Constants.focusGridSize.width
        height: root.height * Constants.focusGridSize.height
        visible: fdPriorityArea.visible
        color: "transparent"
        border.color: Constants.colorRed
    }

    Loader {
        id: quickAdjustSliderLoader
        readonly property real yPos: item ? (item as QuickAdjustSlider).yPos : -1
        anchors.fill: parent
        enabled: active
        active: false
        source: Constants.appPrefix + "liveview/QuickAdjustSlider.qml"

        onLoaded: {
            item.value = Qt.binding(function() { return root.viewModel.quickAdjust })
            item.stepSize = Qt.binding(function() { return root.viewModel.quickAdjustStepSize })
            item.setQuickAdjust.connect(root.viewModel.setQuickAdjust)
            item.close.connect(function() { root.viewModel.clearLvMainState("quick_adjust_slider") })
        }
    }

    // Representing the area where live view will be seen. For other items to anchor to
    // Width and height ratio should always be 4:3
    Item {
        id: liveViewVideoArea
        width: (parent.width / parent.height) > (4 / 3) ? parent.height * 4 / 3 : parent.width
        height: (parent.width / parent.height) > (4 / 3) ? parent.height : parent.width * 3 / 4
        anchors.centerIn: parent
    }

    HblLoader {
        id: grid
        readonly property real cropWidth: root.viewModel.cropFactors.width * root.width
        readonly property real cropHeight: root.viewModel.cropFactors.height * root.height
        source: Constants.appPrefix + "liveview/GridOverlay.qml"
        active: false
        visible: false
        anchors {
            fill: liveViewVideoArea
            topMargin: grid.cropHeight
            bottomMargin: grid.cropHeight
            leftMargin: grid.cropWidth
            rightMargin: grid.cropWidth
        }

        readonly property int defaultBottomMargin: exposureInfoState.active ? 65.6 : 0
        readonly property int internalBottomMargin: (defaultBottomMargin > grid.cropHeight) ? (defaultBottomMargin - grid.cropHeight) : 0
        onLoaded: {
            item.lowContrast = Qt.binding(function() { return root.viewModel.screenEVF }) // Keep high constrast mode for the rear screen in case of bright sunlight etc
            item.internalBottomMargin = Qt.binding(function() { return grid.internalBottomMargin})
        }
    }

    HblLoader {
        id: afDebugGrid
        anchors.fill: root
        active: root.viewModel.debugAF
        source: Constants.appPrefix + "liveview/AfDebugGrid.qml"
        visible: root.viewModel.debugAF
    }

    Item {
        id: afIndicators
        anchors.fill: liveViewVideoArea
        visible: root.state !== "zoom" && root.state !== "evf_brightness" &&
                 root.state !== "iso_wb_selector" && root.state !== "self_timer" &&
                 !root.showOnlyBottomRow
        enabled: !root.showOnlyBottomRow
        readonly property bool showObjectIndicator: root.viewModel.showObjectIndicator &&
                                                  !spirit_mode_loader.active && root.state !== "af_point_selection"
        readonly property bool showMfAssist: root.viewModel.mfAssistDistanceScaleEnabled && !root.viewModel.afSelectionStateActive
        readonly property bool hideAf: showObjectIndicator && root.viewModel.inSession

        AFIndicator {
            id: af_indicator
            enabled: root.focusTouchAllowed
            anchors.fill: parent
            showAfIndicator: (root.viewModel.canShowFocusPoint || root.viewModel.isWideAndFocusError) &&
                             !afIndicators.showMfAssist && !afIndicators.hideAf
            showSpotMeter: root.viewModel.canShowSpotMeter && root.state !== "af_point_selection" &&
                           !mfassistDistanceScaleIndicator.visible
            visible: showAfIndicator || showSpotMeter
            viewModel: root.viewModel
            showSpotPlus: viewModel.isAfSpotPlus && !root.viewModel.lensTypeHAndSpotPlus
            showDirectionArrows: root.state === "af_point_selection" ||
                                 (root.state === "object_detection_selector" && object_detection_selector_loader.stateCustomActive)
            alignToMesh: viewModel.isAfSpotPlus || viewModel.isAfCustom // Note: Wide can have mesh, but no indicator is shown for wide
            Component.onCompleted: {
                viewModel.tpAfPosUpdated.connect(af_indicator.tpPosUpdated)
                viewModel.tpTapToAf.connect(af_indicator.tapToAf)
                viewModel.afPosUpdated.connect(af_indicator.afPosUpdated)
            }
        }

        MFAssistIndicator {
            id: mfassistDistanceScaleIndicator
            enabled: root.focusTouchAllowed
            anchors.fill: parent
            viewModel: root.viewModel
            visible: viewModel.canShowFocusPoint && afIndicators.showMfAssist && !afIndicators.hideAf
            Component.onCompleted: {
                viewModel.tpAfPosUpdated.connect(mfassistDistanceScaleIndicator.tpPosUpdated)
                viewModel.afPosUpdated.connect(mfassistDistanceScaleIndicator.afPosUpdated)
            }
        }

        AfMesh {
            id: afMesh
            anchors.fill: parent
            visible: rows > 0 && root.viewModel.inSession && !root.viewModel.lensTypeH
            rows: root.viewModel.afMeshRows
            cols: root.viewModel.afMeshCols
            meshCenter: root.viewModel.afMeshCenter
        }

        Repeater {
            id: landmarksIndicator
            anchors.fill: parent
            model: DetectedObjects.landmarks
            visible: objectIndicator.visible && root.viewModel.debugLandmarks

            delegate: DetectedObjectsItemModel {
                id: landMarksDg
                visible: landmarksIndicator.visible
                x: landMarksDg.region.x * root.width
                y: landMarksDg.region.y * root.height
                width: landMarksDg.region.width * root.width
                height: landMarksDg.region.height * root.height

                SecondaryObject {
                    anchors.fill: parent
                    debugColor: landMarksDg.debugColor
                    debugName: root.landmarkToShortString(landMarksDg.landmark) + root.objectIdString(landMarksDg.largestForId, landMarksDg.objectId)
                }
            }
        }

        Repeater {
            id: secondaryObjectsIndicator
            anchors.fill: parent
            model: DetectedObjects.secondaryObjects
            visible: objectIndicator.visible && root.viewModel.showSecondaryObjects

            delegate: DetectedObjectsItemModel {
                id: objectsDg
                visible: secondaryObjectsIndicator.visible
                x: objectsDg.region.x * root.width
                y: objectsDg.region.y * root.height
                width: objectsDg.region.width * root.width
                height: objectsDg.region.height * root.height

                SecondaryObject {
                    anchors.fill: parent
                    debugColor: objectsDg.debugColor
                    debugName: root.landmarkToShortString(objectsDg.landmark) + root.objectIdString(objectsDg.largestForId, objectsDg.objectId)
                }
            }
        }

        PrimaryObjectIndicator {
            id: objectIndicator
            enabled: root.viewModel.canSelectObjectBoxBackScreen
            selectionModeActive: root.viewModel.canShowObjectBoxArrows
            canMoveLeft: root.viewModel.objectIdToLeft !== Constants.objectDetectionIdInvalid
            canMoveRight: root.viewModel.objectIdToRight !== Constants.objectDetectionIdInvalid
            cameraRotation: root.viewModel.cameraRotation
            anchors.fill: parent
            symbol: root.viewModel ? root.viewModel.objectIndicatorStatus : AfSymbol.State.Idle
            exposureFailed: root.viewModel.exposureFailed
            visible: afIndicators.showObjectIndicator
        }

    }

    HblLoader {
        id: exposureButtonLoader
        anchors.fill: parent
        active: root.infoVisible && root.viewModel.capabilitySupportGuiExposure && root.viewModel.screenBack
        enabled: active && !root.viewModel.exposing && !root.popupActive
        arguments: { "canDrag": true }
        source: Constants.appPrefix + "components/ExposureButton.qml"

        onLoaded: {
            item.canExpose = Qt.binding(function() { return !root.viewModel.isBTMode && !root.viewModel.isContinuousDriveMode })
            item.position = Qt.binding(function() { return root.viewModel.exposureButtonPosition })
            item.maxYButtonBottom = Qt.binding(function() {
                if (quickAdjustSliderLoader.yPos >= 0) {
                    return quickAdjustSliderLoader.yPos
                }
                return item.defaultMaxYButtonBottom
            })
            item.setExposureButtonPosition.connect(root.viewModel.setExposureButtonPosition)
            item.expose.connect(root.viewModel.doExposure)
            item.exposureBlocked.connect(root.viewModel.exposureButtonBlocked)
        }
    }

    StatusRow {
        id: statusRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: root.borderMarginX
            rightMargin: root.borderMarginX
        }
        visible: root.infoVisible && !root.showOnlyBottomRow
        // "Always" here means unless canShowBattery is false which overrides everything
        alwaysShowBattery: true
        showUsb: true
        allowWifi: !spiritLevelState.active
        flashReady: root.viewModel.flashReady && !spiritLevelState.active
        flashCharging: root.viewModel.flashCharging
        batteryStatusValid: root.viewModel.batteryStatusValid
        batteryWarning: root.viewModel.batteryWarning
        batteryLevelCritical: root.viewModel.batteryLevelCritical
        charging: root.viewModel.charging
        batteryLevel: root.viewModel.batteryLevel
        isOutlined: true
        showTemperatureWarning: root.viewModel.showTemperatureWarning
        connectedHosts: root.viewModel.connectedHosts
        usbSuperSpeed: root.viewModel.usbSuperSpeed
    }

    Connections {
        target: root.viewModel
        function onDriveModeChanged() { driveModeChangedTimer.restart() }
    }

    Timer {
        id: driveModeChangedTimer
        interval: 500
    }

    Timer {
        id: afPointSelectionTimer
        interval: Constants.afSelectionLongPressThreshold
        onTriggered: {
            // This is a long press on AF/MF -> open afPointSelection
            root.viewModel.requestLvMainState("af_point_selection")
        }
    }

    ScaledImage {
        id: wbIcon
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: root.borderMarginX
            topMargin: 57 * 1.6
        }
        visible: !spiritLevelState.active && root.infoVisible &&
                 !root.showOnlyBottomRow
        source: visible ? root.viewModel.wbIcon : ""
        opacity: wbBlink.targetOpacity
    }

    DataChangedAnimation {
        id: wbBlink
    }

    MouseArea {
        id: wb_mousearea
        enabled: wbIcon.visible && root.canOpenPopupsWithTouch && root.viewModel.canChangeWbMode
        anchors {
            fill: wbIcon
            margins: -wbIcon.width / 2
        }

        onClicked: {
            iso_wb_selector_loader.nextWBState()
        }
    }

    HblLoader {
        id: timerIndicatorLoader
        anchors {
            top: root.top
            left: parent.left
            leftMargin: Constants.liveViewBorderNormalMarginX
            topMargin: 113 * 1.6
        }
        width: item ? item.width : 0
        height: item ? item.height : 0
        centerInParent: true
        active: root.infoVisible && root.viewModel.isDriveModeWithTimer && !root.viewModel.exposing && !root.showOnlyBottomRow
        source: Constants.appPrefix + "components/TimerIndicator.qml"
        arguments: { "textFontWeight": Font.Medium }

        onLoaded: {
            item.screenEVF = Qt.binding(function() { return root.viewModel.screenEVF })
            item.driveMode = Qt.binding(function() { return root.viewModel.driveMode })
            item.iconSource = Qt.binding(function() { return root.viewModel.driveModeIcon })
            item.bracketingActive = Qt.binding(function() { return root.viewModel.bracketingActive })
            item.selfTimerDelay = Qt.binding(function() { return root.viewModel.selfTimerDelay })
            item.selfTimerNumberOfFrames = Qt.binding(function() { return root.viewModel.selfTimerNumberOfFrames })
            item.intervalTime = Qt.binding(function() { return root.viewModel.intervalTime })
            item.expBracketingNumberOfFrames = Qt.binding(function() { return root.viewModel.expBracketingNumberOfFrames })
            item.focusBracketingNumberOfFrames = Qt.binding(function() { return root.viewModel.focusBracketingNumberOfFrames })
            item.intervalNumberOfShots = Qt.binding(function() { return root.viewModel.intervalNumberOfShots })
            item.exposuresInSession = Qt.binding(function() { return root.viewModel.exposuresInSession })
            item.cameraMode = Qt.binding(function() { return root.viewModel.cameraMode })
            item.fontPixelSize = Qt.binding(function() { return 24 * 1.6 })
        }
    }

    ScaledImage {
        id: driveModeIndicator
        visible: {
            if (root.showOnlyBottomRow || !root.infoVisible) {
                return false
            } else if (root.viewModel.isDriveModeSingle) {
                return driveModeChangedTimer.running && !root.viewModel.exposing
            } else if (root.viewModel.isDriveModeContinuous) {
                return true
            }

            return false
        }
        asynchronous: false
        anchors {
            top: timerIndicatorLoader.top
            left: parent.left
            leftMargin: Constants.liveViewBorderNormalMarginX
        }
        source: visible ? root.viewModel.driveModeIcon : ""
    }

    ScaledImage {
        id: ibisIndicator
        visible: root.viewModel.hasPlatformIbisSupport && root.infoVisible && !root.showOnlyBottomRow
        anchors {
            top: root.top
            left: parent.left
            leftMargin: Constants.liveViewBorderNormalMarginX
            topMargin: 167 * 1.6
        }
        source: root.viewModel.ibisIcon
    }

    ScaledImage {
        id: focusAreaAndDetectionIndicator
        visible: root.viewModel.canChangeObjectDetection && root.infoVisible && !root.showOnlyBottomRow
        anchors {
            top: root.top
            right: parent.right
            rightMargin: root.borderMarginX
            topMargin: 254
        }
        source: root.viewModel.detectionIcon
    }


    HdrDrcIndicator {
        id: hdrDrc
        anchors {
            right: parent.right
            rightMargin: root.borderMarginX
            top: root.top
            topMargin: 200
        }
        visible: (!blocked || blinking) && (root.viewModel.hdrDrcIcon !== "") && root.infoVisible && !root.showOnlyBottomRow
        source: visible ? root.viewModel.hdrDrcIcon : ""
        hdrStored: root.viewModel.hdrStored
        hdrCurrent: root.viewModel.hdrCurrent
    }

    // Auto ISO indicator
    ScaledImage {
        visible: isoText.canShowIso && root.viewModel.isAutoIso
        anchors {
            right: isoText.left
            rightMargin: 5 * 1.6
            verticalCenter: isoValueText.verticalCenter
        }
        source: visible ? root.viewModel.autoIsoIcon : ""
    }

    Text {
        id: isoText
        readonly property bool canShowIso: root.viewModel.canShowSv &&
                                           ((root.infoVisible && !root.showOnlyBottomRow) ||
                                           root.state === "quick_adjust_slider")
        visible: canShowIso
        anchors {
            right: isoValueText.left
            rightMargin: 4 * 1.6
            verticalCenter: isoValueText.verticalCenter
        }
        text: "ISO"
        font.pixelSize: 24 * 1.6
        font.weight: Font.Medium
        color: Constants.cameraViewNormalTextColor
        style: Text.Outline
        styleColor: Constants.colorBlack
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
    Text {
        id: isoValueText
        readonly property real topMargin: 92
        visible: isoText.canShowIso
        anchors {
            top: root.top
            right: parent.right
            rightMargin: root.borderMarginX
            topMargin: isoValueText.topMargin
        }
        text: root.viewModel.isoAsString
        font.pixelSize: 24 * 1.6
        font.weight: Font.Medium
        color: Constants.cameraViewNormalTextColor
        style: Text.Outline
        styleColor: Constants.colorBlack
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
    MouseArea {
        id: isoMouseArea
        readonly property bool canChangeIso: root.viewModel.canChangeSv && isoText.canShowIso &&
                                             root.state !== "quick_adjust_slider"
        enabled: canChangeIso && root.canOpenPopupsWithTouch
        anchors {
            left: isoText.left
            right: isoValueText.right
            top: isoText.top
            bottom: isoText.bottom
            margins: -isoText.height / 2
        }

        onClicked: {
            iso_wb_selector_loader.nextIsoState()
        }
    }

    FocusIndicator {
        id: focusIndicator
        anchors {
            right: parent.right
            rightMargin: root.borderMarginX
            top: root.top
            topMargin: 139
        }
        visible: showIndicators && !root.overlayOff && root.infoVisible && !root.showOnlyBottomRow
        viewModel: root.viewModel
    }

    HblLoader {
        objectName: "iso_wb_selector_loader"
        id: iso_wb_selector_loader
        source: Constants.appPrefix + "liveview/IsoWBSelector.qml"
        anchors.fill: parent
        focus: active
        active: false
        visible: false
        enabled: false

        property string requestedState: ""

        function nextState()
        {
            console.log("==== nextState(), root.state", root.state)
            if (root.viewModel.canSetState("iso_wb_selector")) {
                requestedState = ""
                root.viewModel.requestLvMainState("iso_wb_selector")
            }
        }
        function nextIsoState()
        {
            if (root.viewModel.canSetState("iso_wb_selector")) {
                requestedState = "iso"
                root.viewModel.requestLvMainState("iso_wb_selector")
            }
        }
        function nextWBState()
        {
            if (root.viewModel.canSetState("iso_wb_selector")) {
                requestedState = "wb"
                root.viewModel.requestLvMainState("iso_wb_selector")
            }
        }

        function handleStateChanged()
        {
            if (item.state === "none") {
                root.viewModel.clearLvMainState("iso_wb_selector")
            } else {
                root.viewModel.requestLvMainState("iso_wb_selector")
            }
        }

        onLoaded: {
            item.wbMode = Qt.binding(function() { return root.viewModel.wbMode })
            item.wbManualTemp = Qt.binding(function() { return root.viewModel.wbManualTemp })
            item.wbManualTint = Qt.binding(function() { return root.viewModel.wbManualTint })
            item.isoValues = Qt.binding(function() { return root.viewModel.isoValues })
            item.isoSelectedAsString = Qt.binding(function() { return root.viewModel.isoSelectedAsString })
            item.wbModel = Qt.binding(function() { return root.viewModel.wbModel })
            item.isFullAuto = Qt.binding(function() { return root.viewModel.isFullAuto })
            item.allowTouch = Qt.binding(function() { return root.viewModel.screenBack })
            item.fontPixelSize = Qt.binding(function() { return root.textSize })

            item.stateChanged.connect(iso_wb_selector_loader.handleStateChanged)
            item.setWbMode.connect(root.viewModel.setWbMode)
            item.setIsoFromString.connect(root.viewModel.setIsoFromString)
            item.setWbManualTemp.connect(root.viewModel.setWbManualTemp)
            item.setWbManualTint.connect(root.viewModel.setWbManualTint)
            item.setGuiSelectedValue.connect(root.viewModel.setGuiSelectedValue)
            item.startVibration.connect(root.viewModel.startVibration)

            if (requestedState === "iso") {
                item.nextIsoState()
            } else if (requestedState === "wb") {
                item.nextWBState()
            } else {
                item.nextState()
            }
        }

        onActiveChanged: {
            if (!active) {
                requestedState = ""
            }
        }
    }

    HblLoader {
        objectName: "object_detection_selector_loader"
        id: object_detection_selector_loader
        property bool stateCustomActive: false

        source: Constants.appPrefix + "liveview/ObjectDetectionSelector.qml"
        anchors.fill: parent
        focus: active
        active: false
        visible: false
        enabled: false

        onLoaded: {
            item.focusArea = Qt.binding(function() { return root.viewModel.focusArea })
            item.objectDetection = Qt.binding(function() { return root.viewModel.objectDetection })
            item.focusAreaModel = Qt.binding(function() { return root.viewModel.focusAreaModel.model })
            item.objectDetectionModel = Qt.binding(function() { return root.viewModel.objectDetectionModel })
            item.allowTouch = Qt.binding(function() { return root.viewModel.screenBack })
            item.fontPixelSize = Qt.binding(function() { return root.textSize })
            stateCustomActive = Qt.binding(function() { return item ? item.stateCustomActive : false })

            item.setFocusArea.connect(root.viewModel.setFocusArea)
            item.setObjectDetection.connect(root.viewModel.setObjectDetection)
            item.stepFocusSize.connect(root.viewModel.stepFocusSize)
            item.startVibration.connect(root.viewModel.startVibration)
            item.close.connect(function() { viewModel.clearLvMainState("object_detection_selector") })
        }

        // We must be able to move AF point with joystick also when ObjectDetection is shown.
        Keys.forwardTo: joystickInput
    }

    HblLoader {
        id: expModeSelectorLoader
        anchors {
            top: root.top
            topMargin: 108 * 1.6
            horizontalCenter: parent.horizontalCenter
        }
        enabled: active
        active: false
        arguments: { "expModeModel": root.viewModel.expModeModel }
        source: Constants.appPrefix + "liveview/ExpModeSelector.qml"

        onLoaded: {
            item.expMode = Qt.binding(function() { return root.viewModel.expMode })
            item.settingsMode = Qt.binding(function() { return root.viewModel.settingsMode })

            item.setExpMode.connect(root.viewModel.setExpMode)
            item.setSettingsMode.connect(root.viewModel.setSettingsMode)
            item.setGuiSelectedValue.connect(root.viewModel.setGuiSelectedValue)
            item.startVibration.connect(root.viewModel.startVibration)
            item.close.connect(function() { root.viewModel.clearLvMainState("exp_mode_selector") })
        }
    }

    Loader {
        id: evfBrightnessSelectorLoader
        anchors.fill: parent
        active: false
        enabled: active
        source: Constants.appPrefix + "liveview/EvfBrightnessSelector.qml"

        onLoaded: {
            item.value = Qt.binding(function() { return root.viewModel.evfBrightness })
            item.setEvfBrightness.connect(root.viewModel.setEvfBrightness)
            item.showBrightnessMenu.connect(root.viewModel.showBrightnessMenu)
            item.vibrate.connect(root.viewModel.startVibration)
            item.close.connect(function() { root.viewModel.clearLvMainState("evf_brightness") })
        }
    }

    Item {
        id: bottom_area
        objectName: "bottom_area"

        anchors {
            left: parent.left
            right: parent.right
            bottom: root.bottom
            bottomMargin: root.borderMarginY
        }
        visible: root.infoVisible

        height: 35.2 // Match height of AV text

        ScaledImage {
            id: expModeIndicator
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: (balanceScaleLoader.x - width) / 2
            }
            visible: root.viewModel.canShowExpMode
            source: root.viewModel.expModeIcon

            MouseArea {
                enabled: root.canOpenPopupsWithTouch && root.viewModel.canSetState("popup_exp_mode")
                anchors {
                    fill: parent
                    margins: -parent.height
                }
                onClicked: root.viewModel.requestLvMainState("popup_exp_mode")
            }
        }

        HblLoader {
            id: balanceScaleLoader
            anchors {
                left: parent.left
                bottom: parent.bottom
                bottomMargin: 2 * 1.6
                leftMargin: 60 * 1.6
            }
            width: item ? item.width : 0
            height: item ? item.height : 0
            centerInParent: true
            active: root.viewModel.canShowBalanceScale
            enabled: root.canOpenPopupsWithTouch && root.viewModel.canSetState("quick_adjust_slider")
            source: Constants.appPrefix + "components/BalanceScaleIndicator.qml"
            arguments: { "fontWeight": Font.Medium }
            onLoaded: {
                item.value = Qt.binding(function() { return root.viewModel.evValue })
                item.valid = Qt.binding(function() { return root.viewModel.balanceScaleValid })
                item.spacing = Qt.binding(function() { return 8 * 1.6 })
                item.pixelSize = Qt.binding(function() { return 22 * 1.6 })
            }

            MouseArea {
                anchors {
                    fill: parent
                    topMargin: -parent.height / 2
                    bottomMargin: -parent.height / 2
                }
                onClicked: root.viewModel.requestLvMainState("quick_adjust_slider")
            }
        }

        // AE-L Lock indicator
        ScaledImage {
            id: aeLock
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: 217 * 1.6
            }
            source: root.viewModel.aeLockIcon
            visible: source.toString() !== ""

            MouseArea {
                anchors {
                    fill: parent
                    margins: -parent.width / 2
                }
                enabled: root.viewModel.canToggleAelTouch
                onClicked: root.viewModel.toggleAel()
            }
        }

        ApertureIndicator {
            id: apertureIndicator
            avOutOfRange: root.viewModel.avOutOfRange
            aperture: root.viewModel.aperture
            visible: root.viewModel.capabilityGetAv
            anchors {
                left: parent.left
                baseline: parent.bottom
                baselineOffset: -2
                leftMargin: 281 * 1.6
            }
            font.pixelSize: (root.isStoppedDown ? 30 : 28) * 1.6
            font.weight: Font.Medium
        }

        ScaledImage {
            id: eShutterIcon
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: 358 * 1.6
            }
            visible: root.viewModel.eShutter
            source: visible ? root.viewModel.eShutterIcon : ""
        }

        ShutterSpeedIndicator {
            id: shutterspeedIndicator
            tvOutOfRange: root.viewModel.tvOutOfRange
            shutterSpeed: root.viewModel.shutterSpeedLv
            visible: root.viewModel.capabilityGetTv
            enabled: root.canOpenPopupsWithTouch &&
                     (root.viewModel.canSetState("popup_tv") || root.viewModel.canSetState("quick_adjust_slider"))
            anchors {
                baseline: parent.bottom
                left: parent.left
                baselineOffset: -2
                leftMargin: 393 * 1.6
            }
            font.pixelSize: 28 * 1.6
            font.weight: Font.Medium
            onClicked: {
                if (root.viewModel.canSetState("quick_adjust_slider")) {
                    root.viewModel.requestLvMainState("quick_adjust_slider")
                } else if (root.viewModel.canSetState("popup_tv")) {
                    root.viewModel.requestLvMainState("popup_tv")
                }
            }
        }

        ScaledImage {
            id: evadjIcon
            anchors {
                bottom: parent.bottom
                left: parent.right
                leftMargin: 514 * 1.6
            }
            visible: root.viewModel.canShowEvAdj && (root.viewModel.evAdj !== 0)
            source: visible ? root.viewModel.exposureCompensationIcon : ""
        }

        StorageIndicator {
            id: imageLeftIndicator
            anchors {
                right: parent.right
                verticalCenter: apertureIndicator.verticalCenter
                rightMargin: root.borderMarginX
            }
            visible: !root.viewModel.techCamera
            tetheredLocalStorage: root.viewModel.tetheredLocalStorage
            internalMediaStatus: root.viewModel.internalMediaStatus
            externalMediaStatus: root.viewModel.externalMediaStatus
            storageWarningIcon: root.viewModel.storageWarningIcon
            exposuresLeft: root.viewModel.exposuresLeft
            imageFormatText: root.viewModel.imageFormatText
            imageFormatEnabled: !root.viewModel.liveviewRestore
            liveviewMode: root.viewModel.state === HblmTypes.E_LiveViewState_Active
        }
    }

    HblLoader {
        id: writing_indicator_loader
        objectName: "writing_indicator_loader"
        arguments: {"bigVariant": false}
        source: Constants.appPrefix + "components/WritingIndicator.qml"
        active: bottom_area.visible && (root.viewModel.mediaProcessing || root.viewModel.numberOfExposuresProcessing > 0)
        visible: active
        anchors {
            bottom: bottom_area.bottom
            right: parent.right
            bottomMargin: 61.5
            rightMargin: root.borderMarginX
        }
        width: Constants.writingIndicatorSizeSmall
        height: Constants.writingIndicatorSizeSmall
        onLoaded: {
            item.processing = Qt.binding(function() { return root.viewModel.mediaProcessing })
            item.numberOfExposuresProcessing = Qt.binding(function() { return root.viewModel.numberOfExposuresProcessing })
            item.numberOfExposureBuffers = Qt.binding(function() { return root.viewModel.numberOfExposureBuffers })
        }
    }

    HblLoader {
        objectName: "hts_loader"
        id: hts_loader
        arguments: {"viewModel" : root.viewModel }
        source: Constants.appPrefix + "liveview/HTS.qml"
        active: false
        visible: active
        anchors.fill: parent

        onActiveChanged: {
            if (!active) {
                root.viewModel.setHtsPolling(false)
            }
        }
    }

    HblLoader {
        objectName: "focus_distance_loader"
        id: focus_distance_loader
        arguments: {"viewModel" : root.viewModel }
        source: Constants.appPrefix + "liveview/FocusDistanceScale.qml"
        active: false
        visible: active
        anchors.fill: parent
        onActiveChanged: {
            if (!active) {
                root.viewModel.setLensFocusPositionUpdate(false, 0)
            }
        }
        onLoaded: {
            item.topMarginOffset = Qt.binding(function() {
                return spiritLevelState.active ? - 50 : 0
            })
        }
    }

    HblLoader {
        objectName: "spirit_level_loader"
        id: spirit_level_loader
        property bool popupActive: false

        /* About the show property
         * This property is used to decouple a state transition dependency that generated a warning:
         * QML StateGroup: Can't apply a state change as part of a state definition.
         *
         * This issue occured when the exposure mode popup was closed and the spirit level overlay was
         * to be shown again. Then it failed to enter the spiritlevel state and it was not possible to
         * open the spirit level popup
         *
         * Workaround:
         * Instead of activating the loader from the spiritLevelState item, the show property is set.
         * Which will start a timer that will activate the loader.
         */
        property bool show: false

        source: Constants.appPrefix + "liveview/SpiritLevel.qml"
        arguments: { "showFocusPoint": true }
        active: false
        visible: false
        enabled: false
        anchors.fill: parent

        onShowChanged: {
            if (show) {
                spiritLevelActiveTimer.start()
            } else {
                spiritLevelActiveTimer.stop()
                spirit_level_loader.active = false
            }
        }

        Timer {
            id: spiritLevelActiveTimer
            interval: 1
            onTriggered: spirit_level_loader.active = true
        }

        onLoaded: {
            item.systemState = Qt.binding(function() { return root.viewModel.systemState })
            item.userLevelEnabled = Qt.binding(function() { return !root.viewModel.isFullAuto })
            item.spiritLevelIcon = Qt.binding(function() { return root.viewModel.spiritLevelIcon })
            item.spiritLevelActive = Qt.binding(function() { return root.viewModel.spiritLevelActive })
            item.spiritLevelUserCalibration = Qt.binding(function() { return root.viewModel.spiritLevelUserCalibration })
            item.spiritLevelOrientation = Qt.binding(function() { return root.viewModel.spiritLevelOrientation })
            item.spiritLevelHorizontal = Qt.binding(function() { return root.viewModel.spiritLevelHorizontal })
            item.spiritLevelVertical = Qt.binding(function() { return root.viewModel.spiritLevelVertical })
            item.openPopup.connect(function() { popupActive = true })
            item.doSpiritLevel.connect(root.viewModel.doSpiritLevel)
            item.startVibration.connect(root.viewModel.startVibration)

            // Set it visible after connecting all properties and signals
            spirit_level_loader.visible = true
        }
        onActiveChanged: {
            if (!active) {
                spirit_level_loader.visible = false
                popupActive = false
            }
        }
        // We must be able to move AF point with joystick also when SpiritLevel is shown.
        Keys.forwardTo: joystickInput
    }

    HblLoader {
        objectName: "histogram_loader"
        id: histogram_loader
        source: Constants.appPrefix + "liveview/LiveViewHistogram.qml"
        arguments: {"canDrag" : true }
        active: false
        visible: active
        enabled: active && root.viewModel.touchInputAllowed
        anchors.fill: parent
        onActiveChanged: {
            root.viewModel.setHistogramUpdateRate(active ? 100 : -1)
        }
        onLoaded: {
            item.position = Qt.binding(function() { return root.viewModel.histogramPosition })
            item.histogramData = Qt.binding(function() { return root.viewModel.histogram })
            item.active = Qt.binding(function() { return root.viewModel.histogramUpdateRate > 0 })
            item.minY = Qt.binding(function() { return isoValueText.topMargin })
            item.setHistogramPosition.connect(root.viewModel.setHistogramPosition)
        }
    }

    HblLoader {
        objectName: "selftimer_loader"
        id: selftimer_loader
        source: Constants.appPrefix + "liveview/SelfTimer.qml"
        arguments: {"viewModel" : root.viewModel }
        active: false
        focus: active
        visible: active
        enabled: active
        anchors.fill: parent
        onLoaded: {

        }
    }

    LiveViewOverlayState {
        id: overlayState
        readonly property bool show: !(root.overlayOff || root.showOnlyBottomRow)
        viewModel: root.viewModel

        Item {
            id: naturalState
            objectName: "LiveViewOverlay_naturalState"
            onStateChanged: console.log("substate natural", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Natural ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_Natural))
                }
            ]
        }
        Item {
            id: gridState
            objectName: "LiveViewOverlay_gridState"
            onStateChanged: console.log("substate grid", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Grid ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_Grid))
                    PropertyChanges { grid.active: true; restoreEntryValues: false }
                    PropertyChanges { grid.visible: (root.state === "" || root.state === "spiritlevel") && overlayState.show }
                }
            ]
        }
        Item {
            id: exposureInfoState
            objectName: "LiveViewOverlay_exposureInfoState"
            readonly property bool active: state === "active"
            onStateChanged: console.log("substate info", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_ExposureInfo ||
                          overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Grid ||
                          overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_SpiritLevel ||
                          overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_FocusDistanceScale ||
                          overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Histogram ||
                          overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_HTS ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_ExposureInfo))
                    PropertyChanges { root.infoVisible: !root.overlayOff}
                }
            ]
        }
        Item {
            id: spiritLevelState
            objectName: "LiveViewOverlay_spiritLevelState"
            readonly property bool active: state === "active"
            onStateChanged: console.log("substate spiritlevel", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_SpiritLevel ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_SpiritLevel))
                    PropertyChanges { spirit_level_loader.show: !root.viewModel.isZoomed && overlayState.show }
                    // spiritlevel focus is controlled by root state
                }
            ]
        }
        Item {
            id: fdsState
            objectName: "LiveViewOverlay_fdsState"
            onStateChanged: console.log("substate fds", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_FocusDistanceScale ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_FocusDistanceScale))
                    PropertyChanges { focus_distance_loader.active: overlayState.show }
                }
            ]
        }
        Item {
            id: histogramState
            objectName: "LiveViewOverlay_histogramState"
            onStateChanged: console.log("substate histogram", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Histogram ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_Histogram))
                    PropertyChanges { histogram_loader.active: overlayState.show || root.state === "quick_adjust_slider" }
                }
            ]
        }
        Item {
            id: htsState
            objectName: "LiveViewOverlay_htsState"
            onStateChanged: console.log("substate hts", state)
            states: [
                State {
                    name: "active"
                    when: overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_HTS ||
                          (overlayState.currentOverlay === HblmTypes.E_LiveViewOverlay_Combined &&
                           (overlayState.combinedMask & HblmTypes.E_LiveViewOverlay_HTS))
                    PropertyChanges { hts_loader.active: overlayState.show }
                }
            ]
        }
    }

    onStateChanged: console.info("liveviewOverlay main state", state)
    state: ""
    states: [
        State {
            when: root.viewModel.isZoomed
            name: "zoom"
            PropertyChanges { zoomOverlayLoader{ focus: true; active: true } }
            PropertyChanges { cropLoader.active: false }
        },
        State {
            when: root.viewModel.selfTimerActive
            name: "self_timer"
            PropertyChanges { selftimer_loader { active: true; enabled: true; visible: true; focus: true } }
        },
        State {
            when: root.viewModel.requestedLvMainState === "evf_brightness"
            name: "evf_brightness"
            PropertyChanges { evfBrightnessSelectorLoader { active: true; focus: true } }
        },
        State {
            when: root.viewModel.requestedLvMainState === "af_point_selection"
            name: "af_point_selection"
            PropertyChanges { afPointSelection.focus: true}
            PropertyChanges { root.viewModel.disableMfAssistFocusIndicator: true}
        },
        State {
            when: root.viewModel.requestedLvMainState === "popup_tv"
            name: "popup_tv"
            PropertyChanges { popup { active: true; focus: true } }
            StateChangeScript {
                script: {
                    popup.setSource(Constants.appPrefix + "controls/PopupListSelector.qml",
                                    { "objectName": "popupTv", "fadedBackground": false, "popupAnchor.leftMargin": root.width * 0.4,
                                        "popupAnchor.rightMargin": Constants.popupListMarginX, "currentlySelectedValue": root.viewModel.shutterSpeed,
                                        "guiPopupState": HblmTypes.E_GuiPopupState_ShutterSpeed })
                }
            }
        },
        State {
            when: root.viewModel.requestedLvMainState === "popup_exp_mode"
            name: "popup_exp_mode"
            PropertyChanges { popup { active: true; focus: true } }
            StateChangeScript {
                script: {
                    popup.setSource(Constants.appPrefix + "popups/PopoverExposureMode.qml", { "fadedBackground": false })
                }
            }
        },
        State {
            when: root.viewModel.requestedLvMainState === "iso_wb_selector"
            name: "iso_wb_selector"
            PropertyChanges { iso_wb_selector_loader { active: true; enabled: true; visible: true } }
            PropertyChanges { root.infoVisible: false}
        },
        State {
            when: root.viewModel.requestedLvMainState === "object_detection_selector"
            name: "object_detection_selector"
            PropertyChanges { object_detection_selector_loader { active: true; enabled: true; visible: true } }
            PropertyChanges { root.infoVisible: false}
        },
        State {
            when: root.viewModel.requestedLvMainState === "exp_mode_selector"
            name: "exp_mode_selector"
            PropertyChanges { expModeSelectorLoader { active: true; focus: true } }
            PropertyChanges { root.showOnlyBottomRow: true}
        },
        State {
            when: root.viewModel.requestedLvMainState === "quick_adjust_slider"
            name: "quick_adjust_slider"
            PropertyChanges { quickAdjustSliderLoader { active: true; focus: true } }
            PropertyChanges { root.showOnlyBottomRow: true}
        },
        State {
            when: spirit_level_loader.active
            name: "spiritlevel"
            PropertyChanges { spirit_level_loader { focus: !spirit_level_loader.popupActive; enabled: true } }
        },
        State {
            name: ""
            StateChangeScript {
                script: {
                    root.onDefaultState()
                }
            }
        }
    ]
    transitions: [
        Transition {
            from: "popup_tv,popup_exp_mode"
            ScriptAction {
                script: {
                    popup.source = ""
                    popup.sourceComponent = undefined
                }
            }
        }
    ]

    function onDefaultState()
    {
        joystickInput.focus = true
    }

    HblLoader {
        id: zoomOverlayLoader
        anchors.fill: liveViewVideoArea
        arguments: { "viewModel": root.viewModel }
        source: Constants.appPrefix + "liveview/ZoomOverlay.qml"
        active: false
        enabled: active

        onLoaded: {
            item.dragAreaPressed = Qt.binding(function() { return root.dragAreaPressed })
       }
    }

    Item {
        id: afPointSelection
        objectName: "afPointSelection"
        readonly property int keyOverride: HblmTypes.E_CameraKeyOption_OverrideHalfPress // Used by KeyFocusHandler.cpp
        readonly property int guiPopupState: HblmTypes.E_GuiPopupState_LvMoveAfPoint // Used by KeyFocusHandler.cpp
        readonly property int keyRepeatIntervalMs: Constants.focusPointSpeedMs // Used by KeyRepeat.cpp

        Keys.onPressed: (event)=> {
            if (root.viewModel.moveFocusPointWithKey(event)) {
                event.accepted = true
            } else if (MKeys.pressedFnAcc(KeyFn.Square, event)) {
                // Block toggle overlays while moving focus point with wheels
                // Should exit on "AF/MF" default value i.e. FocusMode
            } else if (MKeys.pressedFnListAcc([KeyFn.FocusMode, KeyFn.Afd, KeyFn.Ael, KeyFn.MoveAfPoint, KeyFn.HalfPress], event)) {
                root.viewModel.clearLvMainState("af_point_selection")
            }
        }
    }

    Keys.onPressed: (event)=> {
        if (event.isAutoRepeat) {
            event.accepted = false
        } else {
            console.info("LiveViewOverlay.onPressed", event.key)
            if (root.videoAfNavigation && viewModel.inSession && !viewModel.exposing && MKeys.pressedFn(KeyFn.Menu, event)) {
                event.accepted = true;
                root.videoMenuRequested();
                return;
            }


            afPointSelectionTimer.stop()

            if (viewModel.inSession && !(root.videoAfNavigation && !viewModel.exposing && viewModel.afStatus === HblmTypes.E_AutoFocusStatus_RunningCont) && !MKeys.pressedFn(KeyFn.ExposureModeCycle, event)) {
              // swallow mosts keys if we're inside a session.
                console.info("Block key while in session")
                event.accepted = true
                return
            }

            if (MKeys.pressedFnListAcc([KeyFn.Square, KeyFn.Overlay], event)) {
                if (overlayState.show) {
                    overlayState.setNextOverlay()
                }
            } else if (MKeys.pressedFnListAcc([KeyFn.ZoomIn], event)) {
                viewModel.zoomInCurrentFocusPoint()
            } else if (MKeys.pressedFnListAcc([KeyFn.Cross, KeyFn.ResetFocusPoint], event)) {
                viewModel.resetFocusPoint()
            } else if ((MKeys.pressedFnAcc(KeyFn.IsoWb, event))) {
                iso_wb_selector_loader.nextState()
            } else if (MKeys.pressedFnAcc(KeyFn.Iso, event)) {
                iso_wb_selector_loader.nextIsoState()
            } else if (MKeys.pressedFnAcc(KeyFn.Wb, event)) {
                iso_wb_selector_loader.nextWBState()
            } else if (viewModel.isStoppedDown && MKeys.pressedFn(KeyFn.Ael, event)) {
                // Stop the possibility to disable AE-L during stop down.
                event.accepted = true
            } else if (viewModel.capabilityStopDown && MKeys.pressedFnAcc(KeyFn.StopDown, event)) {
                // Activate stopdown (only) while holding the button
                viewModel.setStopDown(true)
                root.isStoppedDown = true
            } else if (MKeys.pressedFnAcc(KeyFn.ExposureMode, event)) {
                viewModel.openExpMode()
            } else if (MKeys.pressedFnAcc(KeyFn.FocusMode, event)) {
                // We do not know yet if this is a short or long press. Start a timer to find out
                afPointSelectionTimer.restart()
            } else if (MKeys.pressedFnAcc(KeyFn.ExposureModeCycle, event)) {
                root.viewModel.cycleExpMode()
            } else if (MKeys.pressedFnAcc(KeyFn.DriveMode, event)) {
                root.viewModel.cycleDriveMode()
            } else if (MKeys.pressedFnAcc(KeyFn.FocusArea, event)) {
                viewModel.openObjectDetection()
            } else if (MKeys.pressedFnAcc(KeyFn.FocusAreaCycle, event)) {
                viewModel.cycleFocusArea()
            } else if (MKeys.pressedFnAcc(KeyFn.DetectionSwitch, event)) {
                viewModel.toggleObjectDetection()
            } else if (MKeys.pressedFnAcc(KeyFn.DetectionCycle, event)) {
                viewModel.cycleObjectDetection()
            } else if (root.viewModel.objectDetectionMulti && root.viewModel.showObjectIndicator &&
                       MKeys.pressedFnAcc(KeyFn.Shift, event)) {
                shortPressTimer.handleKeyPressed(event)
            } else if (MKeys.pressedFnAcc(KeyFn.DriveNear, event)) {
                viewModel.lensDriveTo(HblmTypes.E_LensDriveEndpoint_Near)
            } else if (MKeys.pressedFnAcc(KeyFn.DriveInfinity, event)) {
                viewModel.lensDriveTo(HblmTypes.E_LensDriveEndpoint_Infinity)
            } else if (root.idle && MKeys.pressedFnAcc(KeyFn.ExpCompReset, event)) {
                viewModel.setQuickAdjust(0)
            } else if (root.activeFocus && !viewModel.isZoomed && thumbwheelHandler.handleEvent(event)) {
                event.accepted = true
            }
        }
    }

    Keys.onReleased: (event)=> handleButtonRelease(event)

    ShortPressTimer {
        id: shortPressTimer
        keyFunctions: [KeyFn.Shift]
        onShortPressReleased: (event)=> {
            if (MKeys.pressedFn(KeyFn.Shift, event)) {
                root.viewModel.moveToObjectRight(true)
            }
        }
    }

    JoystickInput {
        id: joystickInput
        readonly property int keyRepeatIntervalMs: Constants.focusPointSpeedMs // Used by KeyRepeat.cpp
        onJoystickPressed: (key, modifiers)=> {
            var event = {}
            event.key = key
            event.modifiers = modifiers
            if (root.viewModel.joystickMoveFocus) {
                if (root.viewModel.showObjectIndicator && root.viewModel.isAfWide) {
                    event.accepted = root.moveObjectBoxWithKey(event)
                } else {
                    if (root.viewModel.canShowFocusPoint || root.viewModel.canShowSpotMeter) {
                        event.accepted = root.viewModel.moveFocusPointWithKey(event)
                    }
                }
            }
        }
        onJoystickReleased: (key, modifiers)=> {
            var event = {}
            event.key = key
            event.modifiers = modifiers
            event.isAutoRepeat = false
            root.handleButtonRelease(event)
        }
    }

    HblLoader {
        objectName: "spirit_mode_loader"
        id: spirit_mode_loader
        source: Constants.appPrefix + "liveview/SpiritModePopup.qml"
        active: spirit_level_loader.popupActive
        visible: active
        focus: active
        anchors.fill: parent
        onLoaded: {
            item.spiritLevelUserCalibration = Qt.binding(function() { return root.viewModel.spiritLevelUserCalibration })
            item.doSpiritLevel.connect(root.viewModel.doSpiritLevel)
            item.setSpiritLevelUserCalibration.connect(root.viewModel.setSpiritLevelUserCalibration)
            item.close.connect(function () { spirit_level_loader.popupActive = false })
        }
    }

    Loader {
        id: popup
        objectName: "LiveViewOverlay_popupLoader"
        asynchronous: false
        anchors.fill: parent
        active: false

        onLoaded: {
            if (root.state === "popup_tv") {
                popup.allowExpParamChanges(false)
                thumbwheelHandler.tvChangeEnabled = true

                (item as PopupListSelector).selectedValueChanged.connect(root.viewModel.setShutterSpeedFromString)
                (item as PopupListSelector).model = Qt.binding(function () { return root.viewModel.shutterSpeedValues })
                (item as PopupListSelector).interactive = Qt.binding(function () { return root.viewModel.touchInputAllowed })
                (item as PopupListSelector).currentlySelectedValue = Qt.binding(function () { return root.viewModel.shutterSpeed })

                item.init()
            } else if (root.state === "popup_exp_mode") {
                item.isVideo = Qt.binding(function () { return root.viewModel.isVideo })
                item.capabilityVideo = Qt.binding(function () { return root.viewModel.capabilityVideo })
                item.expMode = Qt.binding(function () { return root.viewModel.expMode })
                item.expModeList = Qt.binding(function () { return root.viewModel.expModeList })
                item.init()
            }
        }

        Connections {
            target: popup.item
            ignoreUnknownSignals: true
            function onClose() { popup.close() }
            function onColorPick() { root.viewModel.toggle_screen("browse_view", { "color_pick": true}) }
            function onSetWbMode(mode: int) { root.viewModel.setWbMode(mode) }
            function onSetExpMode(mode: int) { root.viewModel.setExpMode(mode) }
            function onSetGuiSelectedValue(popupState: int, value: int) { root.viewModel.setGuiSelectedValue(popupState, value) }
        }

        function allowExpParamChanges(enabled: bool)
        {
            thumbwheelHandler.avChangeEnabled = enabled
            thumbwheelHandler.tvChangeEnabled = enabled
            thumbwheelHandler.svChangeEnabled = enabled
            thumbwheelHandler.quickAdjustEnabled = enabled
            thumbwheelHandler.programShiftEnabled = enabled
        }

        function close()
        {
            popup.allowExpParamChanges(true)
            // We may have set a new state here so only clear possible popup states
            root.viewModel.clearLvMainState("popup_tv")
            root.viewModel.clearLvMainState("popup_exp_mode")
        }
    }

    // Todo: EC1706-845 Fade in GUI until implemented in Wayland
    Rectangle {
        id: fadeRect
        visible: root.viewModel.screenStatus === HblmTypes.E_ScreenStatus_Fading
        anchors.fill: parent
        color: Constants.colorBlack
        opacity: 0.8
    }

    Connections {
        target: root.viewModel
        function onIsFullAutoChanged()
        {
            if (root.viewModel.isFullAuto) {
                popup.close()
                root.viewModel.clearLvMainState("iso_wb_selector")
            }
        }
        function onScreenEVFChanged()
        {
            root.viewModel.clearLvMainState("iso_wb_selector")
             root.viewModel.clearLvMainState("object_detection_selector")
            root.viewModel.clearLvMainState("exp_mode_selector")
        }
        function onRepaintAfIndicator()
        {
            af_indicator.updateAfPos(true)
            mfassistDistanceScaleIndicator.updateAfPos(true)
        }
        function onClosePopups() { spirit_level_loader.popupActive = false }
        function onColorPickValueUpdated() { wbBlink.startDelayed(200) }
    }

    Component.onCompleted: {
        if (root.state === "") {
            root.onDefaultState()
        }
    }

    Loader {
        anchors.fill: parent
        source: Constants.appPrefix + "liveview/SvgOverlay.qml"
        active: root.viewModel.debugSvg
    }

    function landmarkToShortString(landmark : int) : string
    {
        switch(landmark) {
        case HblmTypes.E_Landmark_None: return "N"
        case HblmTypes.E_Landmark_Body: return "B"
        case HblmTypes.E_Landmark_BodyUpper: return "BU"
        case HblmTypes.E_Landmark_Head: return "H"
        case HblmTypes.E_Landmark_Face: return "F"
        case HblmTypes.E_Landmark_EyeLeft: return "EL"
        case HblmTypes.E_Landmark_EyeRight: return "ER"
        case HblmTypes.E_Landmark_Person: return "P"
        case HblmTypes.E_Landmark_HeadShoulder: return "HS"
        case HblmTypes.E_Landmark_HandLeft: return "HL"
        case HblmTypes.E_Landmark_HandRight: return "HR"
        case HblmTypes.E_Landmark_Item: return "I"
        case HblmTypes.E_Landmark_ItemFront: return "IF"
        case HblmTypes.E_Landmark_ItemRear: return "IR"
        case HblmTypes.E_Landmark_Arbitrary: return "A"
        default: return "E"
        }
    }

    function objectIdString(includeId : bool, objectId : int) : string
    {
        if (includeId) {
            return " (" + objectId + ")"
        }
        return "";
    }
}
