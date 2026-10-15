import QtQuick
Item {
    id:root;objectName:"x2vExperimentalVideoUi";anchors.fill:parent;z:100002
    property Item stockRoot:null
    property Item liveviewRoot:null
    property var nativeExposureModel:null
    property var recordingProfiles:null
    property bool videoMode:false
    property bool galleryOpen:false
    property bool stockZoomed:false
    property bool interactionAllowed:false
    property Item menuAttachment:null
    property Item stockGrid:null
    property Item stockBottomArea:null
    property Item stockAfIndicator:null
    property Item stockMfAssist:null
    property alias exposureTabs:tabs
    readonly property bool hideMfAid:root.videoMode && !!root.nativeExposureModel && root.nativeExposureModel.focusMode===8
    property bool experimentalOpen:false
    readonly property var defaultMenus:["exposureMenu","focusMenu","qualityMenu","cropModesMenu","flashMenu","displayMenu","powerMenu","storageMenu","ibisMenu","connectionMenu","generalMenu"]
    function findNamed(name) {
        var todo=[stockRoot];
        for(var n=0;todo.length && n<4096;++n){var item=todo.shift();if(!item)continue;if(item.objectName===name)return item;for(var i=0;i<item.children.length;++i)todo.push(item.children[i]);}
        return null;
    }
    function findBelow(parent,name) {
        var todo=[parent];for(var n=0;todo.length && n<1024;++n){var x=todo.shift();if(!x)continue;if(x.objectName===name)return x;for(var i=0;i<x.children.length;++i)todo.push(x.children[i]);}return null;
    }
    function verifyLayout(grid) {
        if(!grid || grid.count!==11 || grid.numCols!==4 || !grid.contentItem)return false;
        var found=[];
        for(var i=0;i<grid.contentItem.children.length;++i){var x=grid.contentItem.children[i];if(x.menuName!==undefined && x.index!==undefined)found[x.index]=x.menuName;}
        if(found.length!==11)return false;
        for(var ix=0;ix<11;++ix)if(found[ix]!==defaultMenus[ix])return false;
        return true;
    }
    function scan() {
        var overlay=findNamed("LiveViewOverlay_root");
        if(!overlay && liveviewRoot)overlay=findBelow(liveviewRoot,"LiveViewOverlay_root");
        stockBottomArea=overlay?findBelow(overlay,"bottom_area"):null;
        stockAfIndicator=overlay?findBelow(overlay,"AfIndicator_root"):null;
        stockMfAssist=overlay?findBelow(overlay,"MfAssistIndicator_root"):null;
        var grid=findNamed("MainScreen_grid");
        if(grid!==stockGrid){if(menuAttachment)menuAttachment.destroy();menuAttachment=null;stockGrid=grid;if(grid && grid.contentItem)menuAttachment=entryComponent.createObject(grid.contentItem,{stockGrid:grid});}
        if(menuAttachment)menuAttachment.layoutVerified=verifyLayout(grid);
    }
    onStockRootChanged:scan()
    onLiveviewRootChanged:scan()
    Timer { interval:300;repeat:true;running:!!root.stockRoot;onTriggered:root.scan() }
    Component { id:entryComponent;ExperimentalMenuEntry { onOpenRequested:root.experimentalOpen=true } }
    ExposureTouchTabs {
        id:tabs;anchors.fill:parent;nativeModel:root.nativeExposureModel
        visible:root.videoMode && !root.galleryOpen && !root.stockZoomed && !!root.stockRoot && root.stockRoot.state==="liveview"
        interactionAllowed:visible && root.interactionAllowed && !root.experimentalOpen
        onVisibleChanged:if(!visible)selectedParameter=""
    }
    Binding {
        target:root.stockBottomArea;property:"visible";value:false
        when:tabs.visible && !!root.stockBottomArea
        restoreMode:Binding.RestoreBindingOrValue
    }
    Binding {
        target:root.stockAfIndicator;property:"visible";value:false
        when:root.hideMfAid && !!root.stockAfIndicator
        restoreMode:Binding.RestoreBindingOrValue
    }
    Binding {
        target:root.stockMfAssist;property:"visible";value:false
        when:root.hideMfAid && !!root.stockMfAssist
        restoreMode:Binding.RestoreBindingOrValue
    }
    property alias settingsPage:settings.page
    ExperimentalVideoSettings { id:settings;profiles:root.recordingProfiles;anchors.fill:parent;visible:root.experimentalOpen;onClose:root.experimentalOpen=false }
    Connections {
        target:root.stockRoot;ignoreUnknownSignals:true
        function onStateChanged(){root.experimentalOpen=false;tabs.selectedParameter="";}
    }
    Connections {
        target:root.stockGrid && root.stockGrid.parent?root.stockGrid.parent.mainMenu:null
        ignoreUnknownSignals:true
        function onStateChanged(){root.experimentalOpen=false;}
    }
    Component.onDestruction:if(menuAttachment)menuAttachment.destroy()
}
