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
import com.hasselblad.proxies
import com.hasselblad.uiproxies
import com.hasselblad.types
import com.hasselblad.constants

import "qrc:/qt/qml/app/qml/error"
import "qrc:/qt/qml/app/qml/upgrade"
import "qrc:/qt/qml/app/qml/mainmenu"
import "qrc:/qt/qml/app/qml/controlscreen"
import "qrc:/qt/qml/app/qml/viewmodels"

Item {
    id: root
    objectName: "MainViewModel_root"

    signal toggle_screen(string view, var arg)
    signal toggle_drawer_state(string view)
    signal reportError(int errorCode, int errorCategory, int errorAction, var metadata, string view)
    signal setErrorReturnState(string view, var arg)
    signal colorPickDone()
    signal stopPreviewTimer()
    signal setLiveView(bool enable)
    signal requestLvState(string state)
    signal setOverrideDefaultBehaviour(int bitMask, bool enable)
    signal showTimeoutTextDialog(int reason)

    Item {
        id: d

        ErrorViewModel {
            id: errorViewModel

            main: mainModel
            btConnect: btConnectionViewModel
        }

        ShutdownViewModel {
            id: shutdownViewModel
        }

        SuspendViewModel {
            id: suspendViewModel

            main: mainModel
        }

        UpgradeViewModel {
            id: upgradeViewModel

            main: mainModel
        }

        MetadataOverlayViewModel {
            id: metaOverlayViewModel

            main: mainModel
        }

        MainMenuViewModel {
            id: mainMenuViewModel

            main: mainModel
            upgrade: upgradeViewModel
            format: formatDiskViewModel
            error: errorViewModel
            onToggle_screen: (view, arg)=> root.toggle_screen(view, arg)
            onSetLiveView: (enable)=> root.setLiveView(enable)
            onShowTimeoutTextDialog: (reason)=> root.showTimeoutTextDialog(reason)
        }

        FormatViewModel {
            id: formatDiskViewModel
            main: mainModel
        }

        X2VControlScreenViewModel {
            id: controlScreenViewModel
            videoExposureController: root.liveview

            main: mainModel
            mainMenuViewModel: mainMenuViewModel
            onToggle_screen: (view, arg)=> root.toggle_screen(view, arg)
            onToggle_drawer_state: (view)=> root.toggle_drawer_state(view)
            onShowTimeoutTextDialog: (reason)=> root.showTimeoutTextDialog(reason)
            onSetLiveView: (enable)=> root.setLiveView(enable)
        }

        ExposeScreenViewModel {
            id: exposeScreenViewModel

            main: mainModel
            metadataOverlayViewModel: metaOverlayViewModel
            onToggle_screen: (view, arg)=> root.toggle_screen(view, arg)
        }
        TetheredViewModel {
            id: tetheredViewModel

            main: mainModel
            metadataOverlayViewModel: metaOverlayViewModel
            onToggle_screen: (view, arg)=> root.toggle_screen(view, arg)
        }

        BrowseViewViewModel {
            id: browseViewViewModel

            main: mainModel
            metadataOverlayViewModel: metaOverlayViewModel
            onToggle_screen: (view, arg)=> root.toggle_screen(view, arg)
            onStopPreviewTimer: root.stopPreviewTimer()
            onShowTimeoutTextDialog: (reason)=> root.showTimeoutTextDialog(reason)
        }

        BtConnectionViewModel {
            id: btConnectionViewModel
            main: mainModel
        }
    }

    Component.onCompleted: {
        mainMenuViewModel.reportError.connect(root.reportError)
        browseViewViewModel.reportError.connect(root.reportError)
        errorViewModel.setErrorReturnState.connect(root.setErrorReturnState)
        mainMenuViewModel.requestLvState.connect(root.requestLvState)
        root.requestLvState.connect(liveview.requestLvState)
        liveview.setOverrideDefaultBehaviour.connect(root.setOverrideDefaultBehaviour)
        mainMenuViewModel.setOverrideDefaultBehaviour.connect(root.setOverrideDefaultBehaviour)
        browseViewViewModel.colorPickDone.connect(root.colorPickDone)
        browseViewViewModel.colorPickValueUpdated.connect(function() {
            controlScreenViewModel.controlSettingUpdated(GuiTypes.E_ControlSetting_WhiteBalance, true) })
        browseViewViewModel.colorPickValueUpdated.connect(liveview.colorPickValueUpdated)

        liveview.toggle_screen.connect(root.toggle_screen)
        liveview.setLiveView.connect(root.setLiveView)
        liveview.showTimeoutTextDialog.connect(root.showTimeoutTextDialog)

        CameraUI.screenBack = Qt.binding(function () { return root.screenBack })
        CameraUI.screenEVF = Qt.binding(function () { return root.screenEVF })
    }

    property alias error: errorViewModel
    property alias upgrade: upgradeViewModel
    property alias shutdown: shutdownViewModel
    property alias suspendProcessing: suspendViewModel
    property alias mainMenu: mainMenuViewModel
    property alias format: formatDiskViewModel
    property alias controlScreen: controlScreenViewModel
    property alias exposeScreen: exposeScreenViewModel
    property alias tethered: tetheredViewModel
    property alias browseView: browseViewViewModel
    property alias btConnection: btConnectionViewModel

    property MainModel mainModel: null
    property LiveviewViewModel liveview: null

    readonly property bool screenBack: mainModel.screenBack
    readonly property bool screenEVF: mainModel.screenEVF
    readonly property bool sideOriented: mainModel.sideOriented
    readonly property bool showWindow: mainModel.systemState !== HblmTypes.E_SystemState_Testing
    readonly property size defaultScreenSize: mainModel.screenEVF ? Constants.evfScreenSize :
                                                                    Constants.backScreenSize
    readonly property bool preventControlScreenSwipe: mainMenu.preventSwipe ||
                                                      controlScreen.preventSwipe ||
                                                      browseView.preventSwipe ||
                                                      liveview.preventControlScreenSwipe
    readonly property int debugOptions: System.debug_options
    readonly property bool debugActiveInputFocus: debugOptions & HblmTypes.E_DebugOption_ActiveInputFocus

    onPreventControlScreenSwipeChanged: {
        if (liveview.debugTouch) {
            console.info("preventControlScreenSwipe", preventControlScreenSwipe, "mainMenu:", mainMenu.preventSwipe, "controlScreen:", controlScreen.preventSwipe,
                         "browseView:", browseView.preventSwipe, "liveview:", liveview.preventControlScreenSwipe)
        }

        if (preventControlScreenSwipe) {
            preventSwipeTimer.restart()
        } else {
            preventSwipeTimer.stop()
        }
    }

    Timer {
        id: preventSwipeTimer
        interval: 10000
        onTriggered: {
            console.info("ControlScreenSwipe prevent limit.", "mainMenu:", root.mainMenu.preventSwipe,"controlScreen:", root.controlScreen.preventSwipe,
                         "browseView:", root.browseView.preventSwipe, "liveview:", root.liveview.preventControlScreenSwipe)
        }
    }
}
