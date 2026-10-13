import QtQuick

// Attaches VideoDriveGrid into the stock Drive popover. No CameraExtension,
// no album-merge gallery. Recorder/profile objects come from main.qml.
Item {
    id: root
    objectName: "x2vDriveAttach"
    property Item stockRoot: null
    property var recorder: null
    property var recordingProfiles: null
    readonly property bool canSwitchMode: !!recorder && recorder.fresh
    readonly property bool driveVisible: !!driveTarget && driveTarget.visible
    property Item driveTarget: null
    property var driveAttachment: null

    function chooseVideoMode(value, popup) {
        if (!canSwitchMode) return false;
        if (typeof recorder.setVideoMode === "function") recorder.setVideoMode(value);
        else recorder.videoMode = value;
        if (popup && typeof popup.close === "function") popup.close();
        return true;
    }
    function childNamed(parentItem, name) {
        if (!parentItem) return null;
        var children = parentItem.children;
        for (var i = 0; i < children.length; ++i)
            if (children[i].objectName === name) return children[i];
        return null;
    }
    function detach() {
        if (driveAttachment) driveAttachment.destroy();
        driveAttachment = null;
        driveTarget = null;
    }
    function attachDrive(target) {
        if (driveTarget === target && driveAttachment) return;
        detach();
        if (!target) return;
        var parentItem = target.content && target.content.length ? target.content[0] : target;
        var existing = childNamed(parentItem, "x2vDriveModeSwitch");
        driveTarget = target;
        if (existing) { driveAttachment = existing; return; }
        driveAttachment = driveComponent.createObject(parentItem, {
            recorder: root.recorder, extensionOwner: root, popup: target
        });
    }
    function scan() {
        if (!stockRoot) { detach(); return; }
        var stack = [stockRoot], drive = null, n = 0;
        while (stack.length && n < 4096) {
            var item = stack.pop();
            if (!item || item === root) continue;
            ++n;
            if (item.objectName === "PopoverDriveMode_root" && (!drive || item.visible)) drive = item;
            for (var i = 0; i < item.children.length; ++i) stack.push(item.children[i]);
        }
        attachDrive(drive);
    }

    Timer { interval: 400; running: !!root.stockRoot; repeat: true; onTriggered: root.scan() }
    onStockRootChanged: scan()
    Component.onDestruction: detach()
    Component { id: driveComponent; VideoDriveGrid {} }
}
