import QtQuick
import com.hasselblad.proxies
import com.hasselblad.constants
import com.hasselblad.types
import com.hasselblad.objectdetection
import "TouchTrackingController.js" as Control

// Additive, disabled until a native result adapter supplies fresh evidence.
// This is a non-visual controller; input remains in the stock HblTouchArea.
Item {
    id: root
    property var viewModel: null
    property bool trialEnabled: false
    property bool videoMode: false
    property string navigationContext: "navigation"
    property int expectedSourcePid: 0
    property var nativeState: ({})
    property string quietToken: ""
    property var lease: Control.initial()
    property bool savedArbitrary: false
    property bool settingsOwned: false
    property int previewSerial: 0
    property var previewPoint: null
    property bool previewVisible: false
    property bool lossVisible: false
    property bool previewPending: false
    property var lastRealRegion: null
    property int displayedNativeFrame: -1
    readonly property bool ownsInput: Control.hasLease(lease)
    readonly property string ownerToken: ownsInput ? lease.token : ""
    readonly property bool searching: lease.phase === "searching" && !previewPending
    readonly property bool locked: lease.phase === "locked" && !previewPending
    readonly property bool following: lease.phase === "af_wait" && !previewPending
    readonly property var region: (locked || following) ? lease.region : null
    // Pure press feedback does not wait for the backend read/quiet handshake.
    // This never authorizes a seed; canRoute and Control.allowed stay unchanged.
    readonly property bool canPreview: trialEnabled && videoMode && navigationContext==="viewfinder" && viewModel &&
        !viewModel.isAfDisabledByFocusRingInMf && Camera.focus_mode===4 && Camera.focus_area===2 && Camera.object_detection===0
    readonly property bool canRoute: ownsInput || Control.allowed(snapshot())
    readonly property var displayRegion: (locked || following) ? lease.region : (searching || lossVisible) && lastRealRegion ? lastRealRegion : previewPoint ?
        {x:Math.max(0,Math.min(.9,previewPoint.x-.05)),y:Math.max(0,Math.min(.9,previewPoint.y-.05)),width:.1,height:.1} : null
    signal ownerChanged()
    signal controlEvent(string action, var detail)

    function lostReason(reason) {
        return reason==="target_lost" || reason==="target_id_changed" ||
            reason==="target_unavailable" || reason==="receipt_timeout";
    }

    function snapshot() {
        var fresh=nativeState && expectedSourcePid>0 && nativeState.servicePid===expectedSourcePid && Number.isFinite(nativeState.observedAt) &&
            Date.now()-nativeState.observedAt>=0 && Date.now()-nativeState.observedAt<500;
        return {enabled:trialEnabled,video:videoMode,context:navigationContext,
            manual:!viewModel || viewModel.isAfDisabledByFocusRingInMf || Camera.focus_mode===8,
            focusMode:Camera.focus_mode,focusArea:Camera.focus_area,objectDetection:Camera.object_detection,
            focusPoint:Number(Camera.focus_point),touchTracking:Camera.touch_tracking,arbitraryTracking:Camera.arbitrary_tracking,
            backendReady:fresh && nativeState.backendReady===true,
            servicePid:expectedSourcePid,epoch:nativeState.epoch || "",sourceSeq:nativeState.sourceSeq,nativeSeedSeq:nativeState.nativeSeedSeq,
            mlRunning:fresh && nativeState.mlRunning===true,
            workerActive:fresh && nativeState.workerActive===true,
            lifecycleSeq:nativeState.lifecycleSeq,quietToken:quietToken,
            afCommandBusy:Camera.find_focus_active===true || Camera.find_focus_extended_active===true ||
                Camera.start_session_active===true || Camera.stop_session_active===true,
            inSession:!viewModel || viewModel.inSession,
            afRunning:Camera.af_status===HblmTypes.E_AutoFocusStatus_RunningCont};
    }
    function dispatch(event) {
        var c=snapshot();
        var result=Control.step(lease,event,c,Date.now());
        lease=result.state;
        if (event.type==="tap" && !Control.hasLease(lease) && result.effects.length===0)
            root.clearPressFeedbackIfIdle("tap_rejected");
        if (event.type==="tap") root.controlEvent("trigger",{edge:"dispatch_result",guiAt:Date.now(),
            phase:lease.phase,effects:result.effects.map(function(e) { return e.type; }),
            allowed:Control.allowed(c),context:c.context,enabled:c.enabled,backendReady:c.backendReady,
            manual:c.manual,focusMode:c.focusMode,focusArea:c.focusArea,objectDetection:c.objectDetection,
            sourceSeq:c.sourceSeq,epoch:c.epoch,publishedPid:expectedSourcePid});
        result.effects.forEach(function(e) {
            e.guiAt=Date.now();
            if (e.type==="claim") root.ownerChanged();
            else if (e.type==="start_ml") Camera.doStart_dcam_stream(HblmTypes.E_DCAMStream_LiveviewML);
            else if (e.type==="seed") {
                if (!settingsOwned) { savedArbitrary=Camera.arbitrary_tracking; settingsOwned=true; }
                Camera.touch_tracking=true; Camera.arbitrary_tracking=true;
                Camera.focus_point=e.packed; // unsigned Number, including touch-origin bits
            } else if (e.type==="start_af") viewModel.doFindFocus();
            else if (e.type==="stop_af") {
                if (lostReason(e.reason) || e.reason==="acquire_timeout") {
                    lossVisible=true;lossTimer.restart();
                }
                // Drop the active touch selection before stopping AF. The
                // ordinary AF watcher may resume only after stop is acknowledged.
                Camera.touch_tracking=false;
                Camera.doStop_session();
            }
            else if (e.type==="stop_ml") Camera.doStop_dcam_stream(HblmTypes.E_DCAMStream_LiveviewML);
            else if (e.type==="restore" && settingsOwned) {
                // Touch selection is session state, not a preference to revive.
                // This also covers a native session ending before its Lost
                // receipt arrives, so that event ordering cannot retain a lock.
                Camera.touch_tracking=false;
                var point=Number(Camera.focus_point);
                if (Number.isInteger(point) && point>=0 && point<=0xffffffff)
                    Camera.focus_point=(point&0x3fffffff)>>>0;
                if (Camera.arbitrary_tracking===true) Camera.arbitrary_tracking=savedArbitrary;
                settingsOwned=false;
            } else if (e.type==="abandon_settings") { settingsOwned=false;previewVisible=false;lossVisible=false; }
            else if (e.type==="unclaim") { if (!lossVisible) previewVisible=false;root.ownerChanged(); }
            root.controlEvent(e.type,e);
        });
    }
    function clearPressFeedbackIfIdle(reason) {
        if (root.lease && Control.hasLease(root.lease)) return false;
        lossTimer.stop();
        root.previewVisible=false;root.previewPending=false;root.lossVisible=false;root.lastRealRegion=null;
        root.controlEvent("feedback_cleared",{reason:reason,guiAt:Date.now()});
        return true;
    }
    onCanPreviewChanged: if (!canPreview && previewPending) clearPressFeedbackIfIdle("preview_context_unavailable")
    function tap(screenPoint) {
        if (!Control.hasLease(lease) && !Control.allowed(snapshot())) {
            clearPressFeedbackIfIdle("tap_rejected");
            return;
        }
        previewPending=false;
        // Exactly the stock AutoFocus back-screen normalization and crop clamp.
        var p=Constants.getClosestInboundFocusPoint(
            Qt.point(screenPoint.x/Constants.backScreenSize.width,screenPoint.y/Constants.backScreenSize.height),
            Constants.combinedToSize(Camera.focus_size),Camera.crop_mode_current);
        dispatch({type:"tap",point:{x:p.x,y:p.y}});
    }
    function preview(screenPoint) {
        lossTimer.stop();
        var p=Constants.getClosestInboundFocusPoint(
            Qt.point(screenPoint.x/Constants.backScreenSize.width,screenPoint.y/Constants.backScreenSize.height),
            Constants.combinedToSize(Camera.focus_size),Camera.crop_mode_current);
        previewPoint={x:p.x,y:p.y};previewVisible=true;previewPending=true;lossVisible=false;lastRealRegion=null;
        previewSerial++;
        root.controlEvent("tap_received",{point:previewPoint,observedAt:Date.now()});
    }
    function cancel() { lossTimer.stop();previewVisible=false;previewPending=false;lossVisible=false;dispatch({type:"cancel"}); }
    onNativeStateChanged: {
        dispatch({type:"tick"});
        if (nativeState && nativeState.result) {
            var r=nativeState.result;
            dispatch({type:"receipt",receipt:r});
            if ((locked || following) && r.nativeFrameId!==displayedNativeFrame) {
                lastRealRegion=lease.region;
                displayedNativeFrame=r.nativeFrameId;
                root.controlEvent("roi_applied",{guiAt:Date.now(),nativeFrameId:r.nativeFrameId,
                    receivedMonotonicNs:r.receivedMonotonicNs,nativeSeedSeq:r.nativeSeedSeq,region:lease.region,afReady:locked});
            }
        }
    }
    function traceRouteContext(edge) {
        if (!trialEnabled && !ownsInput && !previewVisible) return;
        var c=snapshot();
        root.controlEvent("context",{edge:edge,guiAt:Date.now(),context:c.context,video:c.video,
            enabled:c.enabled,backendReady:c.backendReady,phase:lease.phase,publishedPid:expectedSourcePid,
            nativePid:nativeState.servicePid,observedAge:Date.now()-Number(nativeState.observedAt)});
    }
    onNavigationContextChanged: {
        traceRouteContext("navigation");
        if (navigationContext!=="viewfinder") { previewVisible=false;lossVisible=false; }
        dispatch({type:"tick"});
    }
    onVideoModeChanged: {
        traceRouteContext("video");
        if (!videoMode) { previewVisible=false;lossVisible=false; }
        dispatch({type:"tick"});
    }
    onExpectedSourcePidChanged: { traceRouteContext("source_pid");dispatch({type:"tick"}); }
    onTrialEnabledChanged: { traceRouteContext("enabled");dispatch({type:"tick"}); }
    Timer { interval:50;repeat:true;running:root.ownsInput;onTriggered:root.dispatch({type:"tick"}) }
    Timer { id:lossTimer;interval:1200;onTriggered:{root.lossVisible=false;root.previewVisible=false;} }
    Connections {
        target: Camera
        function onFocus_modeChanged() {
            if (Camera.focus_mode!==4) { root.previewVisible=false;root.lossVisible=false; }
            root.dispatch({type:"tick"});
        }
        function onFocus_areaChanged() { root.dispatch({type:"tick"}); }
        function onTouch_trackingChanged() { root.dispatch({type:"point_readback"}); }
        function onArbitrary_trackingChanged() { root.dispatch({type:"point_readback"}); }
        function onFocus_pointChanged() {
            if (root.ownsInput && root.lease.point) {
                var expected=Control.packedPoint(root.lease.point);
                root.controlEvent("point_property_readback",{guiAt:Date.now(),value:Number(Camera.focus_point),
                    coordinatesMatch:((Number(Camera.focus_point)&0x3fffffff)>>>0)===((expected&0x3fffffff)>>>0)});
                root.dispatch({type:"point_readback"});
            }
        }
    }
    Connections {
        target: DetectedObjects
        function onDetectedObjectChanged() {
            // Latency comparison only. AF-map output is NOT admitted as a VOT receipt.
            if (root.ownsInput) root.controlEvent("stock_box_received",{
                observedAt:Date.now(),targetId:DetectedObjects.targetId,
                landmark:DetectedObjects.targetLandmark,region:DetectedObjects.targetRegion});
        }
    }
    // Parent must keep this controller alive until ownsInput=false; destroying
    // it before stop acknowledgements abandons the lease and requires recovery.
    Component.onDestruction: {
        var c=root.snapshot();
        if (root.ownsInput && c.backendReady && c.epoch===root.lease.epoch) {
            if (root.lease.afOwned) Camera.doStop_session();
            if (root.lease.mlOwned) Camera.doStop_dcam_stream(HblmTypes.E_DCAMStream_LiveviewML);
        }
    }
}
