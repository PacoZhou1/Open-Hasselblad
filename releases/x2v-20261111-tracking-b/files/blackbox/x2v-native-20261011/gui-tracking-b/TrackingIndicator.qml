import QtQuick
import QtQuick.Window
import com.hasselblad.constants
import "qrc:/qt/qml/app/qml/liveview"

Item {
    id: root
    property bool showing: false
    property bool cancellable: false
    property string phase: "pending"
    property rect targetRegion: Qt.rect(0,0,0,0)
    signal cancelled()
    property int previewSerial: 0
    property bool pressPreview: false
    signal feedbackFrame(var detail)
    property bool feedbackReady: false
    property string feedbackLastPhase: "pending"
    property bool recoveryProbeUsed: false
    property bool probePending: false
    property string probeReason: ""
    property double probeRequestedAt: 0
    property int probeFrames: 0

    function settleFeedback() {
        if (!feedbackReady || phase==="lost") return;
        // Public native helper preserves geometry/colors, but removes the
        // previous Failed state's blink counter and residual opacity=0.
        votSymbol.stopBlink();
        votSymbol.wantedOpacity=1;
        votSymbol.opacity=1;
    }
    function queueFeedbackProbe(reason) {
        if (probePending && probeReason==="first_white" && reason!=="first_white") return;
        probePending=true;probeReason=reason;probeRequestedAt=Date.now();probeFrames=0;
    }
    function ancestorsVisible() {
        var item=votSymbol;
        for (var i=0;item && i<32;i++,item=item.parent) {
            if (item.visible===false || item.opacity===0) return false;
        }
        return true;
    }
    onPreviewSerialChanged: {
        recoveryProbeUsed=false;
        if (!feedbackReady) return;
        settleFeedback();queueFeedbackProbe("first_white");
        Qt.callLater(function() { root.settleFeedback(); });
    }
    onShowingChanged: if (feedbackReady && showing) settleFeedback()
    onPhaseChanged: {
        var previous=feedbackLastPhase;feedbackLastPhase=phase;
        if (!feedbackReady) return;
        settleFeedback();
        Qt.callLater(function() {
            root.settleFeedback();
            // One first recovery observation per click; no per-ROI/frame log.
            if (previous==="lost" && root.phase!=="lost" && !root.pressPreview && !root.recoveryProbeUsed) {
                root.recoveryProbeUsed=true;root.queueFeedbackProbe("recovery");
            }
        });
    }
    Component.onCompleted: {
        feedbackReady=true;feedbackLastPhase=phase;settleFeedback();
        if (showing && previewSerial>0) queueFeedbackProbe("first_white");
    }
    Connections {
        target: root.Window.window
        function onFrameSwapped() {
            if (!root.probePending) return;
            root.probeFrames++;
            var effective=root.ancestorsVisible();
            var shown=root.showing && votSymbol.visible && effective && votSymbol.opacity>0.99 && votSymbol.width>0 && votSymbol.height>0;
            if (root.probeFrames===1 || shown || root.probeFrames>=6) {
                root.feedbackFrame({probe:root.probeReason,stage:shown?"shown":root.probeFrames===1?"first_swap_hidden":"not_shown",
                    guiAt:Date.now(),requestedAt:root.probeRequestedAt,previewSerial:root.previewSerial,
                    phase:root.phase,state:votSymbol.state,opacity:votSymbol.opacity,wantedOpacity:votSymbol.wantedOpacity,
                    visible:votSymbol.visible,effectiveVisible:effective,
                    rect:{x:votSymbol.x,y:votSymbol.y,width:votSymbol.width,height:votSymbol.height}});
            }
            if (shown || root.probeFrames>=6) root.probePending=false;
        }
    }
    visible: showing || cancellable
    AfSymbol {
        id: votSymbol
        objectName: "x2vVotSymbol"
        visible: root.showing && width>0 && height>0
        x: Math.round(root.targetRegion.x*root.width)
        y: Math.round(root.targetRegion.y*root.height)
        width: Math.round(root.targetRegion.width*root.width)
        height: Math.round(root.targetRegion.height*root.height)
        afType: AfSymbol.AfType.ArbitraryTracking
        // Only the real result adapter may select "locked".
        symbol: root.phase==="locked" ? AfSymbol.State.FoundFocus :
                root.phase==="lost" ? AfSymbol.State.Failed : AfSymbol.State.Running
    }
    Rectangle {
        id: cancelButton
        objectName: "x2vVotCancel"
        // WB's stock 58px icon starts at 91.2px; its expanded touch area
        // starts at 62.2px. A 58px button at y=4 ends at 62, above it.
        x: 18
        y: 4
        width: 176; height: 58; radius: 6
        visible: root.cancellable
        color: cancelArea.pressed ? "#98181818" : "#78181818"
        Text {
            anchors.fill: parent
            text: "取消跟踪"
            color: "white"
            font.family: Constants.latinFont
            font.pixelSize: 28
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        // The whole labelled rectangle consumes the press; it cannot leak a
        // second ordinary focus-point tap through the preview underneath it.
        MouseArea {
            id: cancelArea
            objectName: "x2vVotCancelTouch"
            anchors.fill: parent
            preventStealing: true
            propagateComposedEvents: false
            onClicked: root.cancelled()
        }
    }
}
