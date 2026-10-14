import QtQuick
import "qrc:/qt/qml/app/qml/mainmenu" as NativeMenu
import "qrc:/qt/qml/app/qml/components" as NativeComponents
Rectangle {
 id:root;objectName:"x2vExperimentalVideoSettings";color:"black"
 property var profiles:null
 property string page:""
 readonly property var chosen:profiles?profiles.selected:null
 readonly property bool editable:!!profiles && !profiles.busy
 readonly property var options:!profiles?[]:page==="resolution"?profiles.profiles.map(function(p){return {id:p.id,text:p.width+" × "+p.height,detail:p.format+" · "+p.fps+" fps"};}):
  page==="format"?profiles.profiles.map(function(p){return {id:p.id,text:p.format,detail:p.width+" × "+p.height+" · "+p.fps+" fps · "+p.note};}):
  page==="fps"&&chosen?[{id:chosen.id,text:chosen.fps+" fps",detail:chosen.note}]:[]
 signal close()
 function openPage(name){if(!editable || ["resolution","fps","format"].indexOf(name)<0)return false;page=name;return true;}
 function choose(ix){if(!editable || ix<0 || ix>=options.length)return false;if(!profiles.select(options[ix].id))return false;page="";return true;}
 NativeMenu.MenuHeader {id:header;width:parent.width;text:[{text:root.page==="resolution"?"分辨率":root.page==="fps"?"帧率":root.page==="format"?"格式":"实验性功能"}];showBackArrow:true;onClose:{if(root.page)root.page="";else root.close();}}
 Column {y:header.height;width:parent.width;visible:!root.page
  Repeater {model:["分辨率","帧率","RAW","格式","录像状态"]
   delegate:Item {
    required property int index;required property string modelData
    width:root.width;height:110
    Text {x:48;y:30;text:parent.modelData;color:"white";font.pixelSize:30;font.weight:Font.Medium}
    Text {anchors.right:parent.right;anchors.rightMargin:72;y:30;color:index===4?(profiles&&profiles.canRecord?"white":"#A0A0A0"):"white";font.pixelSize:29;visible:index!==2
     text:!root.chosen?"—":index===0?root.chosen.width+" × "+root.chosen.height:index===1?root.chosen.fps+" fps":index===3?root.chosen.format:profiles.canRecord?"就绪":root.chosen.verifiedLabel
    }
    Text {anchors.right:parent.right;anchors.rightMargin:36;y:27;visible:index===0||index===1||index===3;text:"›";color:"#AAA";font.pixelSize:38}
    NativeComponents.Switch {anchors.right:parent.right;anchors.rightMargin:48;y:24;visible:index===2;value:!!root.chosen&&root.chosen.raw;itemEnabled:root.editable}
    Text {x:48;y:75;visible:index===4;text:root.chosen?root.chosen.format+" · "+root.chosen.note:"";color:"#8E8E8E";font.pixelSize:23}
    Rectangle {x:48;width:parent.width-96;height:1;anchors.bottom:parent.bottom;color:"#333"}
    MouseArea {anchors.fill:parent;enabled:root.editable && index!==4;onClicked:{if(index===0)root.openPage("resolution");else if(index===1)root.openPage("fps");else if(index===2)profiles.setRaw(!root.chosen.raw);else if(index===3)root.openPage("format");}}
   }
  }
 }
 Column {y:header.height;width:parent.width;visible:!!root.page
  Repeater {model:root.options
   delegate:Item {
    required property int index;required property var modelData
    width:root.width;height:126
    Text {x:48;y:25;text:parent.modelData.text;color:"white";font.pixelSize:32}
    Text {x:48;y:78;text:parent.modelData.detail;color:"#999";font.pixelSize:24}
    Text {anchors.right:parent.right;anchors.rightMargin:54;y:25;text:"✓";color:"white";font.pixelSize:34;visible:!!root.chosen && parent.modelData.id===root.chosen.id}
    Rectangle {x:48;width:parent.width-96;height:1;anchors.bottom:parent.bottom;color:"#333"}
    MouseArea {anchors.fill:parent;enabled:root.editable;onClicked:root.choose(index)}
   }
  }
 }
 Text {x:48;anchors.bottom:parent.bottom;anchors.bottomMargin:27;color:"#8E8E8E";font.pixelSize:23;text:root.page==="fps"?"仅提供已验证规格":root.page?"选择会同步匹配的格式与帧率":"选择规格不会自动开始录像"}
}
