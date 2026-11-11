import QtQuick
import com.hasselblad.keys
import "qrc:/qt/qml/app/qml/components" as Stock
import "qrc:/qt/qml/app/qml/components/buttons" as Buttons
import "qrc:/qt/qml/app/qml/scripts/Keys.js" as MKeys

// Private augmented grid. Factory model and photo-mode enum values stay intact.
Stock.HblGridView {
    id: root; objectName: "x2vDriveModeSwitch"
    required property var recorder
    required property var extensionOwner
    required property Item popup
    property Item stockGrid: null
    property Item pageSwipe: null
    readonly property bool dialogOpen: !!pageSwipe && pageSwipe.show === true
    readonly property bool attached: !!stockGrid && stockGrid.srcModel.length === 6
    readonly property bool inputAllowed: extensionOwner.canSwitchMode
    property var entries: []
    x: 0; y: 0; width: parent.width; height: parent.height; z: 1000
    visible: attached && extensionOwner.visible && popup.visible && !dialogOpen
    numCols: 4; numRows: 2; cellWidth: width / 4; cellHeight: 220
    model: entries; interactive: false; topMargin: 145
    function find(name) {
        var queue=[popup];
        for(var n=0;queue.length && n<512;++n){var x=queue.shift();if(!x)continue;if(x.objectName===name)return x;for(var i=0;i<x.children.length;++i)queue.push(x.children[i]);}
        return null;
    }
    function attach() {
        stockGrid=find("DriveModeGrid_root");pageSwipe=find("PopoverDriveMode_pageSwipe");
        if(!attached)return;
        var values=[];for(var i=0;i<6;++i)values.push({nativeIndex:i,item:stockGrid.srcModel[i],video:false});
        values.push({nativeIndex:-1,item:null,video:true});entries=values;syncSelection();
    }
    function syncSelection() {if(attached)currentIndex=recorder.videoMode?6:stockGrid.currentIndex;}
    function isIndexSelectable(ix) {return ix>=0 && ix<entries.length && inputAllowed && (entries[ix].video || entries[ix].item.writable);}
    function select(ix,closePopup) {
        if(!isIndexSelectable(ix))return false;
        currentIndex=ix;
        if(entries[ix].video)return extensionOwner.chooseVideoMode(true,popup);
        // Route only genuine native values through the original connected signals.
        if(typeof recorder.setVideoMode==="function")recorder.setVideoMode(false);else recorder.videoMode=false;
        stockGrid.currentIndex=entries[ix].nativeIndex;stockGrid.setSelected(closePopup);return true;
    }
    function settings() {
        if(currentIndex<0 || !isIndexSelectable(currentIndex))return;
        var e=entries[currentIndex];
        if(e.video){select(currentIndex,true);return;}
        stockGrid.currentIndex=e.nativeIndex;
        if(e.item.submenuName)stockGrid.openDialog(e.item.submenuName);else select(currentIndex,true);
    }
    onVisibleChanged:{if(visible){syncSelection();forceActiveFocus();}else if(stockGrid && popup.visible)stockGrid.forceActiveFocus();}
    Connections {target:recorder;ignoreUnknownSignals:true;function onVideoModeChanged(){root.syncSelection();}}
    Connections {target:stockGrid;ignoreUnknownSignals:true;function onCurrentIndexChanged(){if(!recorder.videoMode)root.syncSelection();}}
    Rectangle {z:-1;anchors.fill:parent;color:"#101010"}
    Text {x:44.8;y:30;text:qsTranslate("PopoverDriveMode","Drive Mode");color:"white";font.pixelSize:32}
    Text {x:44.8;y:635;width:parent.width-89.6;text:root.currentIndex===6?(root.extensionOwner.recordingProfiles ? root.extensionOwner.recordingProfiles.driveLine : "录像规格未绑定"):(root.currentIndex>=0 && root.entries[root.currentIndex] ? qsTranslate("DriveModes",root.entries[root.currentIndex].item.description):"");color:"#AAAAAA";font.pixelSize:23;wrapMode:Text.WordWrap}
    delegate: FocusScope {
        required property int index;required property var modelData
        width:root.cellWidth;height:root.cellHeight;focus:GridView.isCurrentItem
        Buttons.FramedImage {
            id: icon;objectName: modelData.video?"x2vSelectVideo":"x2vNativeDrive"+index
            width:parent.width;highlightWidth:121.6;highlightHeight:89.6
            text:modelData.video?"录像":qsTranslate("DriveModes",modelData.item.iconText)
            source:modelData.video?"image://svg/ic_controlscreen_exposure_mode_video":(modelData.item.writable?modelData.item.icon:modelData.item.iconDisabled)
            textPixelSize:26;textSideMargin:8;textTopMargin:12;textWrapping:Text.WordWrap
            forceFrameOutline:root.currentIndex===index;forceBoldText:root.currentIndex===index
            selectable:root.isIndexSelectable(index);acceptKeys:false
            onPressed:{root.forceActiveFocus();root.select(index,root.currentIndex===index);}
        }
    }
    Keys.onPressed:event=>{
        event.accepted=false;
        if(MKeys.pressedFnListAcc([KeyFn.Afd,KeyFn.Square],event))root.settings();
        else if(MKeys.pressedFnAcc(KeyFn.PopAccept,event))root.select(root.currentIndex,true);
        else if(MKeys.pressedFnAcc(KeyFn.JstkUp,event))root.moveUp();
        else if(MKeys.pressedFnAcc(KeyFn.JstkDown,event))root.moveDown();
        else if(MKeys.pressedFnListAcc([KeyFn.Up,KeyFn.Left],event))root.moveLeft();
        else if(MKeys.pressedFnListAcc([KeyFn.Down,KeyFn.Right],event))root.moveRight();
    }
    Component.onCompleted:attach()
}
