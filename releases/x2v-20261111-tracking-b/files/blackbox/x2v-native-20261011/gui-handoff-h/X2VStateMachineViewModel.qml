import QtQuick
import com.hasselblad.proxies
import com.hasselblad.types
import "qrc:/qt/qml/app/qml/viewmodels"

StateMachineViewModel {
    id: root
    property bool handoffControlled: false
    property int suppressedCount: 0
    property int lastSuppressed: -1
    signal handoffLiveViewSuppressed(bool requested, int count)
    onHandoffControlledChanged: if (!handoffControlled) lastSuppressed=-1

    function setLiveViewState(enable: bool) {
        // The session owner establishes the final native live-view state.
        // Do not replay an obsolete GUI start/stop after the handoff completes.
        // Errors and power-off keep the original native route.
        if (handoffControlled && !activeError && systemState===HblmTypes.E_SystemState_Active) {
            suppressedCount++;
            var value=enable ? 1 : 0;
            if (lastSuppressed!==value) {
                lastSuppressed=value;
                handoffLiveViewSuppressed(enable,suppressedCount);
            }
            return;
        }
        Camera.doSet_live_view(enable);
    }
}
