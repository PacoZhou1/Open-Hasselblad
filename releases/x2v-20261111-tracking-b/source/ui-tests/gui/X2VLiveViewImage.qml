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

import QtQuick
import "qrc:/qt/qml/app/qml/liveview"

import com.hasselblad.types
import com.hasselblad.constants
import com.hasselblad.keys

import "qrc:/qt/qml/app/qml/components"
import "qrc:/qt/qml/app/qml/viewmodels"
import "qrc:/qt/qml/app/qml/scripts/Keys.js" as MKeys

FocusScope {
    objectName: "LiveViewImage_root"
    id: root
    property bool videoAfNavigation: false
    property alias touchTracking: touchVot
    VideoTouchTracking {
        id: touchVot
        viewModel: liveviewViewModel
    }
    TrackingIndicator {
        anchors.fill: parent; z: 1000
        showing: touchVot.previewVisible && touchVot.videoMode && touchVot.navigationContext === "viewfinder"
        cancellable: touchVot.ownsInput && touchVot.lease.phase !== "armed" && touchVot.navigationContext === "viewfinder"
        phase: touchVot.locked ? "locked" : (touchVot.searching || touchVot.lossVisible) ? "lost" : "pending"
        targetRegion: touchVot.displayRegion ? Qt.rect(touchVot.displayRegion.x,touchVot.displayRegion.y,touchVot.displayRegion.width,touchVot.displayRegion.height) : Qt.rect(0,0,0,0)
        previewSerial: touchVot.previewSerial
        pressPreview: touchVot.previewPending
        onFeedbackFrame: (detail)=> {
            detail.epoch=touchVot.lease.epoch;detail.servicePid=touchVot.expectedSourcePid;
            touchVot.controlEvent("feedback_frame",detail);
        }
        onCancelled: { votSingleTap.stop();touchVot.cancel(); }
    }
    signal videoMenuRequested()
    focus: true
    readonly property alias viewModel: liveviewViewModel

    signal keyPressed(KeyEvent event)
    signal keyReleased(KeyEvent event)

    Keys.onPressed: (event)=> {
        console.info("LiveViewImage.onPressed", event.key)

        if (event.isAutoRepeat) {
            event.accepted = false
        } else if (MKeys.pressedFnAcc(KeyFn.Afd, event)) {
            if (!touchVot.ownsInput) viewModel.doFindFocusExtended(HblmTypes.E_SessionOptions_KeepSession)
        } else {
            root.keyPressed(event)
        }
    }

    Keys.onReleased: (event)=> {
        console.info("LiveViewImage.onReleased", event.key)
        if (MKeys.pressedFnAcc(KeyFn.Afd, event)) {
            if (!touchVot.ownsInput) viewModel.doStop_session()
        } else {
            root.keyReleased(event)
        }
    }

    X2VLiveviewViewModel {
        id: liveviewViewModel
        videoAfNavigation: root.videoAfNavigation
        touchVotOwnsInput: touchVot.ownsInput
        isPinching: dragArea.isPinching
    }

    HblTouchArea {
        id: dragArea
        anchors.fill: parent
        //anchors.bottomMargin: constants.focusPointSelectionAreaBottomMargin
        // The size index used when scaling initially starts
        property point initialSizeIndex: Qt.point(0,0)
        property point focusPointBeforeClick: Qt.point(0,0)
        property point dragStartPt: Qt.point(0,0)
        property point dragCurrentPt: Qt.point(0,0)
        readonly property bool canClick: (!root.viewModel.inSession || liveviewViewModel.videoFocusSession) && root.viewModel.screenBack && !root.viewModel.swipingControlScreen && !isPinching
        readonly property bool canMoveFocusPointBackScreen: liveviewViewModel.focusTouchAllowed
        readonly property bool canMoveSpotCircleBackScreen: root.viewModel.canMoveSpotCircleBackScreen
        readonly property bool canChangeObjectWithSwipe: root.viewModel.canChangeObjectWithSwipe

        disableDrag: root.viewModel.inSession && !liveviewViewModel.videoFocusSession
        enabled: root.viewModel.screenBack && !root.viewModel.swipingControlScreen && !root.viewModel.isZoomed
        doubleClickInterval: Constants.tapToAfClickTimeout

        Timer {
            id: votSingleTap
            property point targetPoint: Qt.point(0,0)
            interval: 0
            onTriggered: {
                dragArea.traceVotInput("trigger","timer_fire",targetPoint);
                if (touchVot.canRoute && touchVot.videoMode && touchVot.navigationContext === "viewfinder") touchVot.tap(targetPoint);
            }
        }
        Connections {
            target: touchVot
            function onVideoModeChanged() { if (!touchVot.videoMode) votSingleTap.stop(); }
            function onNavigationContextChanged() { if (touchVot.navigationContext !== "viewfinder") votSingleTap.stop(); }
        }
        onDoubleClicked: (pt)=> {
            if (touchVot.previewPending) touchVot.clearPressFeedbackIfIdle("double_click");
            traceVotInput("context","gesture:double_clicked",pt);
            if (touchVot.canRoute) {
                votSingleTap.stop(); touchVot.cancel();
                if (touchVot.videoMode && touchVot.navigationContext === "viewfinder") root.viewModel.zoom(pt.x,pt.y);
                return;
            }
            if (!canClick) {
                return
            }

            if ((canMoveFocusPointBackScreen || canMoveSpotCircleBackScreen) &&
                (focusPointBeforeClick.x !== 0 || focusPointBeforeClick.y !== 0)) {
                // Restore focus point since we just responded to the first click
                root.viewModel.setFocusPoint(focusPointBeforeClick)
                focusPointBeforeClick = Qt.point(0,0)
            }
            if (root.viewModel.isZoomed) {
                root.viewModel.exitZoom()
            } else {
                // Stop any ongoing tapToAf
                stopTapToAf()

                root.viewModel.zoom(pt.x, pt.y)
            }
        }

        onPressed: (pt)=> {
            if (touchVot.canRoute || touchVot.canPreview) {
                if (touchVot.videoMode && touchVot.navigationContext === "viewfinder" && root.viewModel.screenBack && !isPinching)
                    touchVot.preview(pt);
                return;
            }
            var clickedOnObjectBox = root.viewModel.isClickOnObjectBox(pt)

            if (!clickedOnObjectBox && (canMoveFocusPointBackScreen || canMoveSpotCircleBackScreen)) {
                //If this press is part of the second click in a double click then don't overwrite focusPointBeforeClick from first click
                if (!isDoubleClick(pt)) {
                    //Backup focus point on press to cover case that user presses/drags with nose before entering EVF
                    focusPointBeforeClick = root.viewModel.focusRegionCentrePoint
                    focusPointTimer.restart()
                }
            }
        }

        onPressAndHold: (pt)=> {
            if (touchVot.previewPending) touchVot.clearPressFeedbackIfIdle("long_press");
            traceVotInput("context","gesture:long_press",pt);
            if (touchVot.canRoute) { votSingleTap.stop(); touchVot.cancel(); return; }
            if (!canClick) {
                return
            }

            var clickedOnObjectBox = root.viewModel.isClickOnObjectBox(pt)

            if (!clickedOnObjectBox && (canMoveFocusPointBackScreen || canMoveSpotCircleBackScreen)) {
                focusPointBeforeClick = root.viewModel.focusRegionCentrePoint
                root.viewModel.setFocusPointFromTouchPoint(pt)
                focusPointTimer.restart()
            }

            doTapToAf(pt, false)
        }

        onPinchStarted: {
            if (touchVot.previewPending) touchVot.clearPressFeedbackIfIdle("pinch");
            traceVotStage("pinch_start");
            if (touchVot.canRoute) { votSingleTap.stop(); touchVot.cancel(); return; }
            stopTapToAf()

            if (canMoveFocusPointBackScreen) {
                console.info("onPinchStarted: initial size index: ", root.viewModel.afSizeIndex)
                dragArea.initialSizeIndex = root.viewModel.afSizeIndex
            }
        }

        onPinchFinished: {
            if (touchVot.canRoute) return;
            if (canMoveFocusPointBackScreen) {
                console.info("onPinchFinished: initial size index: ", dragArea.initialSizeIndex)
                dragArea.initialSizeIndex = Qt.point(0,0)
            }
        }

        // The area was pinched in/out (scale < 1 = pinch in, scale > 1 pinch out)
        onPinchUpdated: (scale, scaleX, scaleY)=> {
            if (touchVot.canRoute) return;
            if (canMoveFocusPointBackScreen) {
                root.viewModel.afSetSizeByScale(dragArea.initialSizeIndex, scaleX, scaleY)
            }
        }

        // Observe the stock touch signals; never seed from released/canceled.
        onReleased: (pt)=> traceVotInput("clicked","released",pt)
        onCanceled: (pt)=> {
            traceVotInput("clicked","canceled",pt);
            if (touchVot.previewPending) touchVot.clearPressFeedbackIfIdle("touch_canceled");
        }
        onClicked: (pt)=> handleOnClicked(pt)

        // Public stock state observations only; no private stage/point mutation.
        function traceVotStage(edge) {
            traceVotInput("context","gesture:"+edge,Qt.point(-1,-1));
        }
        Connections {
            target: dragArea
            function onIsPressedChanged() { dragArea.traceVotStage("is_pressed"); }
            function onIsDraggingChanged() { dragArea.traceVotStage("is_dragging"); }
            function onIsPinchingChanged() { dragArea.traceVotStage("is_pinching"); }
            function onIsPressAndHoldChanged() { dragArea.traceVotStage("is_long_press"); }
            function onEnabledChanged() { dragArea.traceVotStage("enabled"); }
        }
        function traceVotInput(action,edge,pt) {
            if (!touchVot.trialEnabled && !touchVot.ownsInput && !touchVot.previewVisible) return;
            var c=touchVot.snapshot();
            touchVot.controlEvent(action,{edge:edge,point:{x:pt.x,y:pt.y},guiAt:Date.now(),
                canRoute:touchVot.canRoute,video:c.video,context:c.context,enabled:c.enabled,
                backendReady:c.backendReady,mlRunning:c.mlRunning,workerActive:c.workerActive,
                inSession:c.inSession,afCommandBusy:c.afCommandBusy,phase:touchVot.lease.phase,
                publishedPid:touchVot.expectedSourcePid,nativePid:touchVot.nativeState.servicePid,
                observedAge:Date.now()-Number(touchVot.nativeState.observedAt),
                screenBack:root.viewModel.screenBack,swiping:root.viewModel.swipingControlScreen,
                pinching:isPinching,pressed:isPressed,longPress:isPressAndHold});
        }

        onDragStarted: (pt)=> {
            if (touchVot.previewPending) touchVot.clearPressFeedbackIfIdle("drag");
            traceVotInput("context","gesture:drag_start",pt);
            dragStartPt = pt
        }

        onDragPositionUpdated: (pt)=> {
            if (touchVot.canRoute) { votSingleTap.stop(); touchVot.cancel(); return; }
            dragCurrentPt = pt

            if (canMoveFocusPointBackScreen || canMoveSpotCircleBackScreen) {
                root.viewModel.afPosUpdated(true, pt)
                pt = root.viewModel.afTouchPoint
            }

            if (!root.viewModel.showObjectIndicator) {
                //Tap to af
                if (root.viewModel.tapToAf) {
                    if (isInsideAfRegion(pt)) {
                        tapToAfTimer.restartDragTimeout()
                    } else {
                        tapToAfTimer.stop()
                    }
                }
            }
        }

        onDragFinished: (pt)=> {
            traceVotInput("context","gesture:drag_finish",pt);
            if (touchVot.canRoute) { votSingleTap.stop(); touchVot.cancel(); return; }
            var dragDistance = Qt.point(dragCurrentPt.x - dragStartPt.x,
                                        dragCurrentPt.y - dragStartPt.y)
            dragStartPt = Qt.point(0,0)
            dragCurrentPt = Qt.point(0,0)

            if (canMoveFocusPointBackScreen || canMoveSpotCircleBackScreen) {
                root.viewModel.afPosUpdated(false, pt)
            } else { // Repaint to make sure that point is shown on correct position
                root.viewModel.repaintAfIndicator()
            }

            if (canChangeObjectWithSwipe) {
                if (root.viewModel.rotationAdjustedPos(dragDistance) > Constants.objectBoxBackScreenSwipeThreshold) {
                    root.viewModel.moveToObjectRight(false)
                } else if (root.viewModel.rotationAdjustedPos(dragDistance) < -Constants.objectBoxBackScreenSwipeThreshold) {
                    root.viewModel.moveToObjectLeft(false)
                }
            }
        }

        function handleOnClicked(pt: point)
        {
            traceVotInput("clicked","handler_enter",pt);
            if (touchVot.canPreview && !touchVot.canRoute) {
                // Feedback is immediate, but an unavailable owner/backend
                // still cannot receive any AF/ML/seed command.
                touchVot.controlEvent("feedback_unavailable",{guiAt:Date.now()});
                touchVot.clearPressFeedbackIfIdle("tap_rejected");
                return;
            }
            if (touchVot.canRoute) {
                // Reserve the click before stock focus movement / tap AF / object selection.
                if (!touchVot.videoMode || touchVot.navigationContext !== "viewfinder") return;
                if (!root.viewModel.screenBack || root.viewModel.swipingControlScreen || isPinching) return;
                tapToAfTimer.stop(); focusPointTimer.stop();
                votSingleTap.targetPoint=pt; votSingleTap.restart();
                return;
            }
            if (!canClick) {
                return
            }

            var clickedOnObjectBox = root.viewModel.isClickOnObjectBox(pt)

            if ((!clickedOnObjectBox || root.viewModel.objectDetectionSingle) && (canMoveFocusPointBackScreen || canMoveSpotCircleBackScreen)) {
                focusPointBeforeClick = root.viewModel.focusRegionCentrePoint
                root.viewModel.setFocusPointFromTouchPoint(pt)
                focusPointTimer.restart()
            }

            if (root.viewModel.showObjectIndicator) {
                if (clickedOnObjectBox) {
                    var targetId = root.viewModel.intersectingObjectBoxTarget(pt)
                    if (targetId !== Constants.objectDetectionIdInvalid) {
                        root.viewModel.setTargetObject(targetId)
                    }
                } else if (!clickedOnObjectBox && root.viewModel.tapToAf) {
                    // Object detection is active but clicked outside the box
                    // Run tap to AF on this object (which was selected when pressing)
                    root.viewModel.doFindFocusExtended(HblmTypes.E_SessionOptions_None)
                }
            } else { // Not object detection
                if (!isDoubleClick(pt)) {
                    doTapToAf(pt, true)
                }
            }
        }

        function doTapToAf(pt: point, startTimer: bool)
        {
            if (touchVot.canRoute) return;
            if (root.viewModel.canShowFocusPoint && root.viewModel.tapToAf) {
                var insideAfRegion = isInsideAfRegion(pt)

                if (insideAfRegion || canMoveFocusPointBackScreen) {
                    console.info("tapToAf triggered, insideAfRegion", insideAfRegion, "startTimer", startTimer)
                    if (startTimer) {
                        tapToAfTimer.restartClickTimeout()
                    } else {
                        liveViewOverlay.tapToAf()
                    }
                }
            }
        }

        function stopTapToAf()
        {
            tapToAfTimer.stop()
        }

        function isInsideAfRegion(pt: point) : bool
        {
            var afRegion = liveViewOverlay.focusIndicatorRegion
            var afCenterPos = Qt.point(afRegion.x + afRegion.width / 2, afRegion.y + afRegion.height / 2)
            return arePointsClose(pt, afCenterPos, afRegion.width + afRegion.width *  0.5)
        }

        Timer {
            id: focusPointTimer //Used for restoring last focus point in case we change point with nose shortly before entering EVF.
            interval: root.viewModel.focusPointRestoreTimeout
        }

        Timer {
            id: tapToAfTimer //Used for determining if we should tap to af 0.2s after latest drag position update
            property bool isDrag: true
            interval: isDrag ? Constants.tapToAfDragTimeout :
                               Constants.tapToAfClickTimeout
            onTriggered: {
                if (touchVot.canRoute) return;
                console.info("tapToAfTimer", (isDrag ? "drag" : "click"), "triggered")
                liveViewOverlay.tapToAf()
            }

            function restartClickTimeout()
            {
                tapToAfTimer.isDrag = false
                tapToAfTimer.restart()
            }

            function restartDragTimeout()
            {
                tapToAfTimer.isDrag = true
                tapToAfTimer.restart()
            }
        }

        Connections {
            target: root.viewModel
            function onScreenEVFChanged() {
                if (touchVot.canRoute) return;
                //Restore focus point if we enter EVF shortly after changing point since we probably used the nose to change position.
                if (root.viewModel.screenEVF && focusPointTimer.running && dragArea.focusPointBeforeClick) {
                    root.viewModel.setFocusPoint(dragArea.focusPointBeforeClick)
                }
            }
            function onResetState()
            {
                dragArea.reset()
                if (touchpadLoader.item) {
                    (touchpadLoader.item as LiveViewTouchpad).resetState()
                }
                votSingleTap.stop()
                touchVot.cancel()
                tapToAfTimer.stop()
                focusPointTimer.stop()
            }
        }
    }

    HblLoader {
        id: touchpadLoader
        anchors.fill: parent
        arguments: { "viewModel": root.viewModel }
        source: Constants.appPrefix + "liveview/LiveViewTouchpad.qml"
        active: root.visible && root.viewModel.screenEVF
        enabled: !touchVot.ownsInput && (root.viewModel.isZoomed || root.viewModel.evfTpMoveFocus)
        visible: active

        onLoaded: {
            item.canMoveFocusPoint = Qt.binding(function() { return liveviewViewModel.focusEvfAllowed || root.viewModel.canMoveSpotCircleEvf })
            item.allowClick = Qt.binding(function() { return root.viewModel.requestedLvMainState === "" || root.viewModel.isZoomed })
            item.allowDrag = Qt.binding(function() { return (item && item.allowClick) || root.viewModel.requestedLvMainState === "af_point_selection" })
        }
    }

    X2VLiveViewOverlay {
        touchVotOwnsInput: touchVot.ownsInput
        videoAfNavigation: root.videoAfNavigation
        focusTouchAllowed: liveviewViewModel.focusTouchAllowed
        onVideoMenuRequested: root.videoMenuRequested()
        id: liveViewOverlay
        anchors.fill: parent
        dragAreaPressed: dragArea.isPressed
        viewModel: root.viewModel
    }
}
