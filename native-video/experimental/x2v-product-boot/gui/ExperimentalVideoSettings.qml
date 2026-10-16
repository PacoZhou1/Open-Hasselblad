import QtQuick
import "qrc:/qt/qml/app/qml/mainmenu" as NativeMenu
import "qrc:/qt/qml/app/qml/components" as NativeComponents
import "qrc:/qt/qml/app/qml/components/controls" as NativeControls
Rectangle {
    id: root
    objectName: "x2vExperimentalVideoSettings"
    color: "black"
    property var profiles: null
    property string page: ""
    property bool durationOpen: false
    property bool foreverWarning: false
    onVisibleChanged: { if (!visible) { durationOpen = false; foreverWarning = false; } }
    onEditableChanged: { if (!editable) { durationOpen = false; foreverWarning = false; } }
    readonly property var chosen: profiles ? profiles.selected : null
    readonly property bool editable: !!profiles && !profiles.busy
    readonly property var options: {
        if (!profiles || !chosen) return [];
        if (page === "format")
            return profiles.formats().map(function (p) {
                return {id: p.id, kind: "format", format: p.format, text: p.format,
                        available: p.available !== false, detail: root.spec(p)};
            });
        if (page === "fps")
            return profiles.fpsList(chosen.format).map(function (p) {
                return {id: p.id, kind: "fps", fps: p.fps, text: p.fps + " fps", available: true,
                        detail: root.spec(p)};
            });
        return [];
    }
    // Size and frame rate stay in the description. The dropped words are the
    // old "机内硬件编码 / 机内录制" and the MOV / H.264 tags.
    function spec(p) {
        var s = p.width + " × " + p.height + " · " + p.fps + " fps";
        if (p.opengate) s += " · OPENGATE";
        if (p.bits) s += " · " + p.bits;
        if (p.bitrate) s += " · " + p.bitrate;
        return s;
    }
    signal close()
    function openPage(name) {
        if (!editable || ["fps", "format"].indexOf(name) < 0) return false;
        page = name;
        return true;
    }
    function choose(ix) {
        if (!editable || ix < 0 || ix >= options.length) return false;
        var o = options[ix];
        if (o.available === false) return false;
        var ok = o.kind === "format" ? profiles.selectFormat(o.format) : profiles.select(o.id);
        if (!ok) return false;
        page = "";
        return true;
    }
    NativeMenu.MenuHeader {
        id: header
        width: parent.width
        text: [{text: root.page === "fps" ? "帧率" : root.page === "format" ? "格式" : "实验性功能"}]
        showBackArrow: true
        onClose: { if (root.page) root.page = ""; else root.close(); }
    }
    Column {
        y: header.height
        width: parent.width
        visible: !root.page
        Repeater {
            model: ["分辨率", "帧率", "RAW", "格式", "录制时长", "录像状态"]
            delegate: Item {
                required property int index
                required property string modelData
                width: root.width
                height: 94
                readonly property bool openable: index === 1 || index === 3 || index === 4
                Text { x: 48; y: 30; text: parent.modelData; color: "white"; font.pixelSize: 30; font.weight: Font.Medium }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: parent.openable ? 72 : 48
                    y: 30
                    visible: index !== 2
                    color: index === 5 ? (profiles && profiles.canRecord ? "white" : "#A0A0A0") : "white"
                    font.pixelSize: 29
                    text: !root.chosen ? "—" : index === 0 ? root.chosen.width + " × " + root.chosen.height
                        : index === 1 ? root.chosen.fps + " fps"
                        : index === 3 ? root.chosen.format
                        : index === 4 ? profiles.durationLabel
                        : profiles.canRecord ? "就绪" : "等待会话"
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 36
                    y: 27
                    visible: parent.openable
                    text: "›"
                    color: "#AAA"
                    font.pixelSize: 38
                }
                NativeComponents.Switch {
                    anchors.right: parent.right
                    anchors.rightMargin: 48
                    y: 24
                    visible: index === 2
                    value: !!root.chosen && root.chosen.raw
                    itemEnabled: root.editable
                }
                Text {
                    x: 48
                    y: 66
                    visible: index === 5
                    text: root.chosen ? root.spec(root.chosen) : ""
                    color: "#8E8E8E"
                    font.pixelSize: 23
                }
                Rectangle { x: 48; width: parent.width - 96; height: 1; anchors.bottom: parent.bottom; color: "#333" }
                MouseArea {
                    anchors.fill: parent
                    enabled: root.editable && index !== 5 && index !== 0
                    onClicked: {
                        if (index === 1) root.openPage("fps");
                        else if (index === 2) profiles.setRaw(!root.chosen.raw);
                        else if (index === 3) root.openPage("format");
                        else if (index === 4) root.durationOpen = true;
                    }
                }
            }
        }
    }
    Column {
        y: header.height
        width: parent.width
        visible: !!root.page
        Repeater {
            model: root.options
            delegate: Item {
                required property int index
                required property var modelData
                width: root.width
                height: 126
                readonly property bool marked: {
                    if (!root.chosen) return false;
                    if (modelData.kind === "format") return modelData.format === root.chosen.format;
                    return modelData.id === root.chosen.id;
                }
                Text { x: 48; y: 25; text: modelData.text; color: modelData.available === false ? "#666666" : "white"; font.pixelSize: 32 }
                Text { x: 48; y: 78; text: modelData.detail; color: "#999"; font.pixelSize: 24 }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 54
                    y: 25
                    text: "✓"
                    color: "white"
                    font.pixelSize: 34
                    visible: parent.marked
                }
                Rectangle { x: 48; width: parent.width - 96; height: 1; anchors.bottom: parent.bottom; color: "#333" }
                MouseArea { anchors.fill: parent; enabled: root.editable && modelData.available !== false; onClicked: root.choose(index) }
            }
        }
    }
    Loader {
        id: durationLoader
        z: 10
        anchors.fill: parent
        active: root.durationOpen
        sourceComponent: NativeControls.PopupListSelector {
            anchors.fill: parent
            interactive: true
            defaultPixelSize: 64
            model: { var a = []; for (var i = 1; i <= 30; ++i) a.push(i + " 分钟"); a.push("永不"); return a; }
            currentlySelectedValue: root.profiles ? root.profiles.durationLabel : "5 分钟"
            popupAnchor.leftMargin: (width - 420) / 2
            popupAnchor.rightMargin: (width - 420) / 2
            onSelectedValueChanged: (value) => {
                if (value === "永不") root.foreverWarning = true;
                else if (root.editable) root.profiles.selectDuration(parseInt(value) * 60);
            }
            onClose: { root.durationOpen = false; }
            Component.onCompleted: forceActiveFocus()
        }
    }
    Loader {
        anchors.fill: parent
        z: 11
        active: root.foreverWarning
        sourceComponent: NativeComponents.GenericConfirm {
            anchors.fill: parent
            sideOriented: false
            headerText: "取消录制时长限制？"
            infoText: "长时间录制导致温度过高可能产生硬件损坏"
            infoText2: "选择永不仍保留温度和存储空间保护。"
            btn1.text: "选择永不"
            btn2.text: "取消"
            onBtn1Selected: { if (root.editable) root.profiles.selectDuration(0); }
            onClose: root.foreverWarning = false
            Component.onCompleted: forceActiveFocus()
        }
    }
    Text {
        x: 48
        anchors.bottom: parent.bottom
        visible: !root.durationOpen && !root.foreverWarning
        anchors.bottomMargin: 27
        color: "#8E8E8E"
        font.pixelSize: 23
        text: root.page === "fps" ? "目前只有 24 fps" : "选择规格不会自动开始录像"
    }
}
