/*
 * vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab fileencoding=utf-8
 * encoding: utf-8
 * -*- coding: utf-8 -*-
 *
 * Copyright 2025 Victor Hasselblad AB.
 *
 * All information contained in or disclosed by this document is confidential
 * and proprietary of Victor Hasselblad AB. By accepting this material the
 * recipient agrees that this material and the information contained therein
 * will be held in confidence and will not be reproduced in whole or in part
 * without written permission from Victor Hasselblad AB.
 */

import QtQuick
import "qrc:/qt/qml/app/qml"
import QtQuick.Window

import com.hasselblad.constants
import com.hasselblad.keys
import com.hasselblad.guiconfig
import com.hasselblad.types
import "qrc:/qt/qml/app/qml/scripts/Keys.js" as MKeys

import "qrc:/qt/qml/app/qml/components"
import "qrc:/qt/qml/app/qml/viewmodels"
import "qrc:/qt/qml/app/qml/exposescreen"
import "qrc:/qt/qml/app/qml/liveview"
import "qrc:/qt/qml/app/qml/upgrade"

Item {
    id: root
    visible: mainViewModel.showWindow
    objectName: "MainContent"
    anchors.fill: parent

    // We assume that this loader has finished successful and assigned from start
    property Loader liveviewLoader: null

    Component.onCompleted: {
        Constants.window = Window.window
        Window.window.visibility =  Qt.binding(function() { return !mainViewModel.showWindow ? Window.Hidden :
                                                                GuiConfig.renderFullscreen ? Window.FullScreen :
                                                                                             Window.Windowed })
        // Preload control drawer. This will also trigger preload of browse view afterwards.
        control_drawer_loader.active = true;
    }

    Connections {
        target: root.liveviewLoader.item as X2VLiveViewImage
        enabled: root.liveviewLoader.status === Loader.Ready
        ignoreUnknownSignals: true
        function onKeyPressed(event: KeyEvent)
        {
            root.liveviewKeyPressed(event)
        }
        function onKeyReleased(event: KeyEvent)
        {
            root.keyReleased(event)
        }
    }

    function liveviewKeyPressed(event: KeyEvent)
    {
        // Block a lot of keys here:
        if (MKeys.pressedFnAcc(KeyFn.Left, event) ||
            MKeys.pressedFnAcc(KeyFn.Right, event) ||
            MKeys.pressedFnAcc(KeyFn.Up, event) ||
            MKeys.pressedFnAcc(KeyFn.Down, event) ||
            MKeys.pressedFnAcc(KeyFn.Cross, event) ||
            MKeys.pressedFnAcc(KeyFn.JstkCenter, event) ||
            MKeys.pressedFnAcc(KeyFn.Square, event)) {
            console.info("LiveView blocked key", event.key)
        }

        keyPressed(event)
    }

    function keyPressed(event: KeyEvent)
    {
        if (event.isAutoRepeat) {
            return
        }
        console.info("main key pressed", event.key)
        stateMachineViewModel.keyPressed(event.key)

        if (swipe_area.animatingSwipe) {
            console.info("Animating swipe, ignoring key:", event.key)
            event.accepted = true;
        } else if (MKeys.pressedFnAcc(KeyFn.Menu, event)) {
            console.info("menu pressed")
            mainViewModel.toggle_screen("control_screen", {})
        } else if (MKeys.pressedFnAcc(KeyFn.Play, event)) {
            console.info("play pressed")
            mainViewModel.toggle_screen("browse_view", {})
        } else if (MKeys.isCustomButton(event)) {
            stateMachineViewModel.customButton(MKeys.getCustomButton(event), true)
        } else if (MKeys.isCustomWheel(event)) {
            stateMachineViewModel.customWheel(MKeys.getCustomWheel(event),
                                              MKeys.isCustomWheelIncremented(event))
        } else if (MKeys.pressedFnAcc(KeyFn.Afd, event)) {
            stateMachineViewModel.customButton(HblmTypes.E_UserButtonFunction_AFD, true)
        } else if (MKeys.pressedFnAcc(KeyFn.Ael, event)) {
            stateMachineViewModel.customButton(HblmTypes.E_UserButtonFunction_AEL, true)
        }
    }

    function keyReleased(event: KeyEvent)
    {
        if (MKeys.isCustomButton(event)) {
            stateMachineViewModel.customButton(MKeys.getCustomButton(event), false)
        } else if (MKeys.pressedFnAcc(KeyFn.Afd, event)) {
            stateMachineViewModel.customButton(HblmTypes.E_UserButtonFunction_AFD, false)
        } else if (MKeys.pressedFnAcc(KeyFn.Ael, event)) {
            stateMachineViewModel.customButton(HblmTypes.E_UserButtonFunction_AEL, false)
        }
    }

    QtObject {
        id: d
        property bool allowNotifications: false
    }

    FocusScope {
        id: content_container
        objectName: "content_container"
        focus: true
        anchors.fill: parent

        states: [
            State {
                when: timeout_text_loader.reason !== GuiTypes.E_TimeoutTextReason_Max
                name: "timeout_text"
                StateChangeScript {
                    script: {
                        timeout_text_loader.active = true
                        var mode = HblmTypes.E_VibrationMode_LongDoubleSharpClickStrong1Percent100
                        mainViewModel.liveview.startVibration(mode)
                    }
                }
                PropertyChanges { timeout_text_loader.focus: true }
                PropertyChanges { root.liveviewLoader.focus: false }
            },
            State {
                name: ""
                PropertyChanges { content_container.focus: root.state !== "liveview" }
                PropertyChanges { root.liveviewLoader.focus: root.state === "liveview" }
            }
        ]

        Background {
            id: content_container_bg
            anchors.fill: parent
            color: "transparent"
        }

        HblLoader {
            objectName: "media_browse_loader"
            id: media_browse_loader
            anchors.fill: parent
            asynchronous: true
            active: false
            visible: false
            arguments: {"viewModel" : mainViewModel.browseView }
            source: Constants.appPrefix + "browseview/BrowseView.qml"
            readonly property bool browseViewActive: root.state === "browse_view" || root.state === "exposing"

            onLoaded: {
                console.info("media_browse_loader loaded")
                mainViewModel.browseView.browseViewActive = Qt.binding(function() { return media_browse_loader.browseViewActive })
                mainViewModel.browseView.swipingControlScreen = Qt.binding(function() { return swipe_area.swiping })
            }
        }

        HblLoader {
            objectName: "tethered_preview_loader"
            id: tethered_preview_loader
            anchors.fill: parent
            visible: false
            active: false
            arguments: {"viewModel" : mainViewModel.tethered }
            source: Constants.appPrefix + "tethered/TetheredPreview.qml"

            onLoaded: console.info("tethered_preview_loader loaded")
        }

        Item {
            id: backscreen_content
            objectName: "backscreen_content_root"
            anchors.fill: parent

            ControlScreenSwipeArea {
                id: swipe_area
                property bool noSwipeRightSide: false
                mainMenuViewModel: mainViewModel.mainMenu
                mainState: root.state
                enabled: !(mainViewModel.preventControlScreenSwipe || mainViewModel.screenEVF) && !animatingSwipe
                topThreshold: (parent.y - parent.height * (Constants.swipeLengthDividor - 1) / Constants.swipeLengthDividor)
                bottomThreshold: backscreen_content.y - backscreen_content.height / Constants.swipeLengthDividor
                dragTarget: control_drawer_loader
                onSetDrawerEnabled: (enable)=> stateMachineViewModel.setDrawerEnabled(enable)
                anchors {
                    fill: parent
                    topMargin: mainViewModel.screenEVF ? 0 :
                               atMenuBottom ? (parent.height - menuSwipeAreaHeight) : 0
                    bottomMargin: mainViewModel.screenEVF || atBottom ? 0 :
                                  (swipeAreaHeight !== 0 ? parent.height - swipeAreaHeight : 0)
                    rightMargin: noSwipeRightSide ? Constants.noSwipeRightSideMarginX : 0
                    onBottomMarginChanged: console.info ("Camera View Swipe Area changed bottom margin:", swipe_area.anchors.bottomMargin)
                }

                onEnabledChanged: {
                    if (mainViewModel.mainMenu.debugTouch) {
                        console.info(objectName, "enabled", enabled)
                    }
                }

                HblLoader {
                    objectName: "control_drawer_loader"
                    id: control_drawer_loader
                    readonly property bool atBottom: y === 0
                    arguments: { "mainMenuViewModel" : mainViewModel.mainMenu,
                                 "controlScreenViewModel" : mainViewModel.controlScreen }
                    source: Constants.appPrefix + "controlscreen/ControlDrawer.qml"
                    anchors.horizontalCenter: swipe_area.horizontalCenter
                    asynchronous: true
                    visible: false
                    width: parent.width
                    height: backscreen_content.height
                    onLoaded: {
                        console.info("control_drawer_loader loaded")
                        item.mainState = Qt.binding(function() { return root.state })
                        item.mainViewState = Qt.binding(function() { return mainStateMachine.mainViewState })
                        item.drawerState = Qt.binding(function() { return mainStateMachine.drawerState })
                        item.swiping = Qt.binding(function() { return swipe_area.swiping })
                        item.drawerAtTop = Qt.binding(function() { return swipe_area.atTop })
                        item.timeoutTextActive = Qt.binding(function() { return timeout_text_loader.active })
                        mainViewModel.mainMenu.swipingDrawer = Qt.binding(function() { return swipe_area.swiping })
                        stateMachineViewModel.mainMenuExited.connect(item.mainMenuExited)
                        stateMachineViewModel.controlScreenExited.connect(item.controlScreenExited)
                        initBrowseTimer.start()
                    }

                    Timer {
                        id: initBrowseTimer
                        interval: 1000
                        onTriggered: {
                            content_container.startBrowseView()
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    visible: mainViewModel.mainMenu.debugTouch
                    color: "transparent"
                    border.color: Constants.colorRed
                }
            }

            HblLoader {
                objectName: "upgrade_loader"
                id: upgrade_loader
                anchors.fill: parent
                visible: false
                active: false
                arguments: {"viewModel" : mainViewModel.upgrade }
                source: Constants.appPrefix + "upgrade/Upgrade.qml"

                onLoaded: {
                    console.info("upgrade_loader loaded");
                    (item as Upgrade).close.connect(stateMachineViewModel.goToDefaultState)
                }
                onActiveChanged: console.info("upgrade_loader activate:", active)
            }

            HblLoader {
                objectName: "maintenance_loader"
                id: maintenance_loader
                anchors.fill: parent
                visible: false
                active: false
                source: Constants.appPrefix + "maintenance/MaintenanceScreen.qml"

                onLoaded: {
                    console.info("maintenance_loader loaded")
                }
                onActiveChanged: console.info("maintenance_loader activate:", active)
            }

            HblLoader {
                objectName: "maintenance_lensdata_loader"
                id: maintenance_lensdata_loader
                anchors.fill: parent
                visible: false
                active: false
                source: Constants.appPrefix + "maintenance/MaintenanceLensDataScreen.qml"

                onLoaded: {
                    console.info("maintenance_lensdata_loader loaded")
                }
                onActiveChanged: console.info("maintenance_lensdata_loader active:", active)
            }

            HblLoader {
                objectName: "maintenance_manual_loader"
                id: maintenance_manual_loader
                anchors.fill: parent
                visible: false
                active: false
                focus: active
                arguments: {"viewModel" : mainViewModel.mainMenu }
                source: Constants.appPrefix + "maintenance/SensorCalibrationScreen.qml"

                onLoaded: {
                    console.info(objectName, "loaded")
                }
                onActiveChanged: console.info(objectName, "active:", active)
            }

            HblLoader {
                objectName: "shutdown_loader"
                id: shutdown_loader
                anchors.fill: parent
                visible: false
                active: false
                asynchronous: true
                arguments: {"viewModel" : mainViewModel.shutdown }
                source: Constants.appPrefix + "shutdown/ShutdownScreen.qml"
                onLoaded: console.info("shutdown_loader loaded")
            }

            HblLoader {
                objectName: "suspend_processing_loader"
                id: suspend_processing_loader
                anchors.fill: parent
                visible: false
                active: false
                asynchronous: true
                arguments: {"viewModel" : mainViewModel.suspendProcessing }
                source: Constants.appPrefix + "suspend/SuspendScreen.qml"
                onLoaded: console.info("suspend_processing_loader loaded")
            }
        }

        HblLoader {
            objectName: "exposing_loader"
            id: exposing_loader
            anchors.fill: parent
            visible: false
            active: false
            arguments: {"viewModel" : mainViewModel.exposeScreen }
            source: Constants.appPrefix + "exposescreen/Exposing.qml"
            onLoaded: console.info("exposing_loader loaded");
        }

        HblLoader {
            objectName: "error_loader"
            id: error_loader
            anchors.fill: parent
            visible: false
            active: false
            arguments: {"viewModel" : mainViewModel.error, "upgradeViewModel" : mainViewModel.upgrade, "btConnectionViewModel": mainViewModel.btConnection }
            source: Constants.appPrefix + "error/Error.qml"

            onLoaded: {
                console.info("error_loader loaded")
                item.showAckButton = Qt.binding(function() { return !mainViewModel.screenEVF })
            }
        }

        HblLoader {
            id: first_time_guide_loader
            objectName: "first_time_guide_loader"
            anchors.fill: parent
            visible: false
            active: false
            arguments: {"viewModel" : mainViewModel.mainMenu }
            source: Constants.appPrefix + "mainmenu/FirstTimeGuide.qml"

            onLoaded: {
                console.info(objectName, "loaded")

                // Load control_drawer and liveview overlays in background
                var loadedItem = (item as FirstTimeGuide)
                loadedItem.animationFinished.connect(function() {
                    control_drawer_loader.active = true
                })
            }
            onVisibleChanged: {
                // Also cover case where user enters suspend/shutdown during first time guide
                if (!visible && !stateMachineViewModel.firstTimeGuide) {
                    swipe_area.swipeUpAnimated()
                    active = false
                }
            }
        }

        function startBrowseView()
        {
            console.log("Preload browse view")
            // Speed up browse view by loading in the background
            if (stateMachineViewModel.tetheredRemoteStorage) {
                tethered_preview_loader.active = true
            } else {
                media_browse_loader.active = true
            }
        }

        Keys.onPressed: (event)=> {
            root.keyPressed(event)
        }
        Keys.onReleased: (event)=> {
            root.keyReleased(event)
        }
    }

    HblLoader {
        objectName: "timeout_text_loader"
        id: timeout_text_loader
        anchors.fill: parent
        visible: active
        active: false
        focus: false
        source: Constants.appPrefix + "components/TimeoutText.qml"
        arguments: { "viewModel": stateMachineViewModel }

        property int reason: GuiTypes.E_TimeoutTextReason_Max
        property bool fullScreen: false

        onReasonChanged: {
            if (reason === GuiTypes.E_TimeoutTextReason_Max) {
                return
            }

            // We may change reason while popup is active, then reload with new text
            if (status === Loader.Ready) {
                (item as TimeoutText).start(reason, fullScreen)
            }
        }

        onClose: {
            active = false
            fullScreen = false
            reason = GuiTypes.E_TimeoutTextReason_Max
        }

        onLoaded: {
            (item as TimeoutText).start(reason, fullScreen);
            (item as TimeoutText).close.connect(timeout_text_loader.close)
            console.info("timeout_text_loader loaded")
        }
    }

    HblLoader {
        id: global_notification_loader
        objectName: "global_notification_loader"

        property string header: ""
        property string text: ""
        readonly property bool canShow: d.allowNotifications

        anchors.fill: parent
        visible: active
        active: false
        // Don't set focus since the notification is non-interactive and should not interfere with active view.
        source: Constants.appPrefix + "components/GlobalNotification.qml"

        onCanShowChanged: {
            if (!canShow) {
                close()
            }
        }

        onTextChanged: {
            if (!canShow) {
                return
            }

            if (status === Loader.Ready) {
                (item as GlobalNotification).start(header, text)
            } else if (text !== "") {
                active = true
            }
        }

        onClose: {
            active = false
            header = ""
            text = ""
        }

        onLoaded: {
            item.showAsOverlay = Qt.binding(function () { return root.state === "liveview" })
            item.start(header, text)
            item.close.connect(global_notification_loader.close)
            console.info("global_notification_loader loaded")
        }
    }

    StateMachineViewModel {
        id: stateMachineViewModel
        blockKeys: swipe_area.swiping
        onRequestControlScreenState: (state)=> mainViewModel.controlScreen.requestState(state)
        onLaunchBrowseViewPopup: (substate)=> mainViewModel.browseView.substate = substate
        onRequestLvState: (state)=> mainViewModel.requestLvState(state)
        onCloseDrawer: swipe_area.closeDrawer()
        onShowTimeoutTextDialog: (reason)=> {
            timeout_text_loader.reason = reason
        }
        onEnterSuspend: {
            timeout_text_loader.close()
        }
        onShowNotification: (header, text)=> {
            global_notification_loader.header = header
            global_notification_loader.text = text
        }
    }

    MainModel {
        id: mainModel
    }

    MainViewModel {
        id: mainViewModel
        mainModel: mainModel
        liveview: (root.liveviewLoader.item as X2VLiveViewImage).viewModel

        Component.onCompleted: {
            liveview.swipingControlScreen = Qt.binding(function() { return swipe_area.swiping })
            toggle_screen.connect(stateMachineViewModel.toggle_screen)
            toggle_drawer_state.connect(stateMachineViewModel.toggle_drawer_state)
            reportError.connect(stateMachineViewModel.reportError)
            setLiveView.connect(stateMachineViewModel.setLiveView)
            setErrorReturnState.connect(stateMachineViewModel.setErrorReturnState)
            colorPickDone.connect(stateMachineViewModel.colorPickDone)
            stopPreviewTimer.connect(stateMachineViewModel.stopPreviewTimer)
            setOverrideDefaultBehaviour.connect(stateMachineViewModel.setOverrideDefaultBehaviour)
            stateMachineViewModel.loadMenu.connect(mainMenu.loadMenu)
            stateMachineViewModel.controlSettingUpdated.connect(mainViewModel.controlScreen.controlSettingUpdated)
            stateMachineViewModel.liveviewExited.connect(liveview.resetState)
        }

        onShowTimeoutTextDialog: (reason)=> {
            timeout_text_loader.reason = reason
        }
    }

    MainStateMachine {
        id: mainStateMachine
        viewModel: stateMachineViewModel
        running: true
    }

    Binding {
        when: GuiConfig.isSimulation
        target: root
        property: "width"
        value: mainViewModel.defaultScreenSize.width
    }

    Binding {
        when: GuiConfig.isSimulation
        target: root
        property: "height"
        value: mainViewModel.defaultScreenSize.height
    }

    HblLoader {
        id: osdclock_loader
        objectName: "OsdClockLoader"
        source: Constants.appPrefix + "components/OSDClock.qml"
        arguments: { "viewModel": stateMachineViewModel }
        visible: active
        active: stateMachineViewModel.osdClock !== HblmTypes.E_OSDClock_Off &&
                !stateMachineViewModel.debugSvg
        z: 1000
        anchors.fill: parent
    }

    // Todo: EC1706-845 Fade in GUI until implemented in Wayland
    Rectangle {
        id: fadeRect
        // Keep fading in OFF to avoid blink until screen has been powered off.
        visible: mainViewModel.liveview.screenStatus === HblmTypes.E_ScreenStatus_Fading ||
                 mainViewModel.liveview.screenStatus === HblmTypes.E_ScreenStatus_Off
        anchors.fill: parent
        color: Constants.colorBlack
        opacity: 0.8
    }

    state: mainStateMachine.state
    onStateChanged: console.info("Main state:", state)

    states: [
        State {
            name: "main_menu"
            extend: "non_liveview"
            StateChangeScript {
                script: {
                    control_drawer_loader.visible = true
                    control_drawer_loader.active = true
                }
            }
            PropertyChanges { control_drawer_loader { focus: true; enabled: true; } }
            PropertyChanges { d.allowNotifications: true }
        },
        State {
            name: "upgrade"
            extend: "non_liveview"
            StateChangeScript { script: upgrade_loader.active = true }
            PropertyChanges { upgrade_loader { visible: true; focus: true } }
        },
        State {
            name: "maintenance_lensdata"
            extend: "non_liveview"
            StateChangeScript { script: maintenance_lensdata_loader.active = true }
            PropertyChanges { maintenance_lensdata_loader { visible: true; focus: true } }
        },
        State {
            name: "maintenance"
            extend: "non_liveview"
            StateChangeScript { script: maintenance_loader.active = true }
            PropertyChanges { maintenance_loader { visible: true; focus: true } }
        },
        State {
            name: "maintenance_manual"
            extend: "non_liveview"
            StateChangeScript { script: maintenance_manual_loader.active = true }
            PropertyChanges { maintenance_manual_loader { visible: true; focus: true } }
        },
        State {
            name: "error"
            extend: "non_liveview"
            StateChangeScript { script: error_loader.active = true }
            PropertyChanges { error_loader { visible: true; focus: true } }
        },
        State {
            name: "battery_exhausted"
            extend: "error"
        },
        State {
            name: "usb_connected"
            extend: "error"
        },
        State {
            name: "bt_connection_request"
            extend: "error"
        },
        State {
            name: "upgrade_finished"
            extend: "error"
        },
        State {
            name: "first_time_guide"
            extend: "non_liveview"
            StateChangeScript {
                script: {
                    GuiConfig.setHdrSurfaceFormat()
                    first_time_guide_loader.active = true
                }
            }
            PropertyChanges { first_time_guide_loader { visible: true; focus: true } }
        },
        State {
            name: "control_screen"
            extend: "non_liveview"
            StateChangeScript {
                script: {
                    control_drawer_loader.visible = true
                    control_drawer_loader.active = true
                }
            }
            PropertyChanges { control_drawer_loader.focus: true }
            PropertyChanges { d.allowNotifications: true }
        },
        State {
            name: "prepare_transition"
            extend: "non_liveview"
            PropertyChanges { root.opacity: 0.0 }
        },
        State {
            name: "non_liveview"
            PropertyChanges { root.liveviewLoader { visible: false; focus: false } }
        },
        State {
            name: "liveview"
            PropertyChanges { root.liveviewLoader { visible: true; focus: true } }
            PropertyChanges { d.allowNotifications: true }
        },
        State {
            name: "request_start_liveview"
            extend: "non_liveview"
            PropertyChanges { content_container_bg.color: Constants.mainBackgroundColor }
            PropertyChanges { content_container.focus: true }
        },
        State {
            name: "request_stop_liveview"
            extend: "request_start_liveview"
        },
        State {
            name: "exposing"
            extend: "non_liveview"
            StateChangeScript { script: exposing_loader.active = true }
            PropertyChanges { exposing_loader { focus: true; visible: true } }
        },
        State {
            name: "tethered_preview"
            extend: "non_liveview"
            StateChangeScript { script: tethered_preview_loader.active = true }
            PropertyChanges { tethered_preview_loader { focus: true; visible: true } }
            PropertyChanges {
                swipe_area.swipeAreaHeight: Constants.swipeHeightNormal
            }
        },
        State {
            name: "browse_view"
            extend: "non_liveview"
            PropertyChanges { media_browse_loader.visible: true }
            StateChangeScript { script: {media_browse_loader.active = true } }
            PropertyChanges { media_browse_loader.focus: true }
            PropertyChanges {
                swipe_area {
                    swipeAreaHeight: {
                        var gridType = mainViewModel.browseView.currentGridType
                         return gridType === GuiTypes.E_BrowseGridType_None ? Constants.swipeHeightNormal :
                                                                              Constants.swipeHeightMinimal
                    }
                    noSwipeRightSide: mainViewModel.browseView.noControlScreenSwipeRightSide && !swipe_area.swiping
                }
            }
            PropertyChanges { d.allowNotifications: true }
        },
        State {
            name: "shutdown"
            extend: "non_liveview"
            StateChangeScript { script: shutdown_loader.active = true }
            PropertyChanges { shutdown_loader { visible: true; focus: true } }
        },
        State {
            name: "suspend_processing"
            extend: "non_liveview"
            StateChangeScript { script: suspend_processing_loader.active = true }
            PropertyChanges { suspend_processing_loader { visible: true; focus: true } }
        }
    ]

    ActiveFocusDebug {
        id: active_focus_debug
        objectName: "active_focus_debug"
        enabled: mainViewModel.debugActiveInputFocus
    }
}
