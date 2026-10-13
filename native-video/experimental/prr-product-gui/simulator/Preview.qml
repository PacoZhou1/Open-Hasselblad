import QtQuick
import QtQuick.Window
import "qrc:/qt/qml/app/qml/components" as Stock
import "../../manual-video-product-ui-k/gui" as NewUi
import "../../../runtime/gui" as Runtime
import ".." as Product

Window {
    id: root
    width: 1024
    height: 840
    visible: true
    color: "black"
    title: "PRR product · 桌面预览 · 未连接相机"
    property string screen: "live"
    property alias cameraViewport: canvas
    property alias profiles: profileSelection
    property alias settings: settings
    property alias drive: grid
    property alias recorder: recorder
    property alias bodyKeys: bodyKeys
    property alias recordOverlay: hud
    property alias gallery: videoGallery
    property alias playback: playbackController
    property int startCalls: 0
    property int stopCalls: 0
    property int transportCalls: 0
    property string playerBase: ""
    property string fixtureRoot: ""

    function simulateHardware(action, released) {
        return bodyKeys.semanticShutterInput(action, released);
    }
    function simulatePlay() { return bodyKeys.semanticPlay(); }

    NewUi.RecordingProfiles {
        id: profileSelection
        selectedProfileId: "raw_3920_2946_24"
        backendProfileId: "raw_3920_2946_24"
        backendReady: true
        busy: ["idle", "saved", "error"].indexOf(recorder.phase) < 0
    }
    QtObject {
        id: recorder
        property bool available: true
        property bool fresh: true
        property bool videoMode: true
        property string phase: "idle"
        property int frames: 0
        property int durationTicks: 0
        property bool rtpConfirmedOff: true
        property bool stopNeedsRetry: false
        property string previewError: ""
        function setVideoMode(value) { videoMode = !!value; }
        function start() { root.startCalls++; phase = "starting"; return true; }
        function stop() { root.stopCalls++; phase = "finalizing"; return true; }
        function refreshCatalog() { root.loadCatalog(); }
    }
    QtObject { id: owner; property bool canSwitchMode: true; property bool visible: true; property var recordingProfiles: profileSelection
        function chooseVideoMode(value, popup) { recorder.setVideoMode(value); return true; } }

    Item {
        id: canvas
        width: 1024
        height: 768
        Image {
            anchors.fill: parent
            source: root.fixtureRoot ? ("file://" + root.fixtureRoot + "/liveview.ppm") : ""
            fillMode: Image.PreserveAspectCrop
        }
        Item {
            id: stockRoot
            objectName: "MainContent"
            anchors.fill: parent
            state: "liveview"
            Item {
                objectName: "LiveViewOverlay_root"
                anchors.fill: parent
                Text { x: 32; y: 96; text: "A\nWB"; font.pixelSize: 32; color: "white" }
                Text { anchors.right: parent.right; anchors.rightMargin: 32; y: 96; text: "AUTO ISO 200\nAF-C"; font.pixelSize: 30; color: "white"; horizontalAlignment: Text.AlignRight }
                Rectangle { anchors.centerIn: parent; width: 100; height: 80; color: "transparent"; border.color: "white"; border.width: 2 }
                Item { objectName: "bottom_area"; anchors.bottom: parent.bottom; width: parent.width; height: 42 }
            }
        }
        NewUi.ExperimentalVideoSettings {
            id: settings
            anchors.fill: parent
            profiles: profileSelection
            visible: root.screen === "settings"
            onClose: root.screen = "live"
        }
        Item {
            id: popup
            objectName: "PopoverDriveMode_root"
            x: 61; y: 24; width: 902; height: 720
            visible: root.screen === "drive"
            function close() { root.screen = "live"; }
            Stock.DriveModeGrid {
                id: stock
                objectName: "DriveModeGrid_root"
                visible: false
                maxWidth: 410
                driveMode: 0
                srcModel: [single, continuous, selftimer, interval, exposurebracket, focusbracket]
            }
            Stock.DriveModeListItem { id: single; mode: 0; iconText: "Single"; icon: "image://svg/ic_controlscreen_drive_mode_single_popup" }
            Stock.DriveModeListItem { id: continuous; mode: 1; iconText: "Continuous"; icon: "image://svg/ic_controlscreen_drive_mode_continuous_popup" }
            Stock.DriveModeListItem { id: selftimer; mode: 2; iconText: "Self-Timer"; icon: "image://svg/ic_controlscreen_drive_mode_selftimer_popup" }
            Stock.DriveModeListItem { id: interval; mode: 3; iconText: "Interval"; icon: "image://svg/ic_controlscreen_drive_mode_interval_popup" }
            Stock.DriveModeListItem { id: exposurebracket; mode: 4; iconText: "Exposure Bracketing"; icon: "image://svg/ic_controlscreen_drive_mode_exposure_bracketing_popup"; submenuName: "exposureBracket" }
            Stock.DriveModeListItem { id: focusbracket; mode: 5; iconText: "Focus Bracketing"; icon: "image://svg/ic_controlscreen_drive_mode_focus_bracketing_popup"; submenuName: "focusBracket" }
            NewUi.VideoDriveGrid { id: grid; recorder: recorder; extensionOwner: owner; popup: popup }
        }
        NewUi.RecordingOverlay {
            id: hud
            anchors.fill: parent
            z: 40
            recorder: recorder
            hardwareShutterReady: true
            idleBadgeVisible: false
            frameVisible: root.screen === "live" && !videoGallery.visible
            visible: recorder.videoMode && !videoGallery.visible && root.screen !== "settings"
        }
        Product.BodyKeys {
            id: bodyKeys
            recorder: recorder
            recordingProfiles: profileSelection
            hardwareShutterReady: true
            galleryOpen: videoGallery.visible
            settingsOpen: root.screen === "settings"
            onPlayRequested: root.handlePlay()
        }
        Runtime.PlaybackSession {
            id: playbackController
            available: true
            fresh: true
            approvedRoots: root.fixtureRoot ? [root.fixtureRoot] : []
        }
        Product.PrrFrameSurface {
            id: rgbSurface
            anchors.fill: parent
            anchors.bottomMargin: 140
            z: 90
            visible: playbackController.active
            session: playbackController
            playerBase: root.playerBase
            frameFile: root.fixtureRoot ? (root.fixtureRoot + "/play_frame.ppm") : ""
            operational: true
        }
        Runtime.VideoGallery {
            id: videoGallery
            z: 80
            anchors.fill: parent
            visible: false
            session: playbackController
            playbackSurface: Component {
                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    source: rgbSurface.frameUrl
                }
            }
            onLeaveRequested: {
                playbackController.stop();
                visible = false;
            }
        }
    }

    function loadCatalog() {
        playbackController.replaceCatalog({
            schemaVersion: 1,
            clips: [{
                id: "X2V_PRR_SIM",
                state: "saved",
                finalized: true,
                source: root.fixtureRoot + "/clip.mov",
                thumbnail: root.fixtureRoot + "/thumb.ppm",
                title: "ProRes RAW HQ",
                duration: 0.125,
                bytes: 4096,
                width: 3888,
                height: 2912,
                format: "ProRes RAW HQ"
            }]
        });
    }
    function openGallery() {
        if (["starting", "recording", "finalizing"].indexOf(recorder.phase) >= 0) return false;
        loadCatalog();
        videoGallery.visible = true;
        videoGallery.forceActiveFocus();
        return true;
    }
    function handlePlay() {
        if (["starting", "recording", "finalizing"].indexOf(recorder.phase) >= 0) return false;
        if (videoGallery.visible) {
            if (playbackController.active) playbackController.stop();
            else { videoGallery.visible = false; }
            return true;
        }
        return openGallery();
    }

    Timer { interval: 250; running: recorder.phase === "starting"; onTriggered: { recorder.frames = 1; recorder.rtpConfirmedOff = false; recorder.phase = "recording"; } }
    Timer { interval: 400; running: recorder.phase === "finalizing"; onTriggered: { recorder.rtpConfirmedOff = true; recorder.phase = "saved"; } }
    Timer { interval: 100; repeat: true; running: recorder.phase === "recording"; onTriggered: { recorder.frames += 3; recorder.durationTicks += 9000; } }
    Timer { interval: 1200; running: recorder.phase === "saved"; onTriggered: recorder.phase = "idle" }

    Row {
        y: 768
        height: 72
        spacing: 10
        Repeater {
            model: ["实验设置", "Drive Mode", "快门", "Playback"]
            delegate: Rectangle {
                required property string modelData
                width: 180
                height: 72
                color: tap.pressed ? "#555" : "#262626"
                Text { anchors.centerIn: parent; text: parent.modelData; color: "white"; font.pixelSize: 22 }
                MouseArea {
                    id: tap
                    anchors.fill: parent
                    onClicked: {
                        if (parent.modelData === "实验设置") root.screen = "settings";
                        else if (parent.modelData === "Drive Mode") root.screen = "drive";
                        else if (parent.modelData === "快门") { root.simulateHardware("full_press", false); root.simulateHardware("full_press", true); }
                        else root.simulatePlay();
                    }
                }
            }
        }
        Text { text: "桌面预览 · 无相机连接"; color: "#999"; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
    }

    Component.onCompleted: loadCatalog()
}
