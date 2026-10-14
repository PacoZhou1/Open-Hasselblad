import QtQuick
QtObject {
 id:root
 // codec is what the supervisor records: gui.cmd "codec_<codec>", state.json "codec"/"profile_id".
 readonly property var profiles:[
  {id:"h264_1300_970_24",codec:"h264",raw:false,width:1300,height:970,fps:24,format:"H.264",note:"机内硬件编码 · MP4",verifiedLabel:"等待会话"},
  {id:"raw_3920_2946_24",codec:"prores_raw",raw:true,width:3888,height:2912,fps:24,format:"ProRes RAW HQ",note:"机内录制 · MOV",verifiedLabel:"等待会话"},
  {id:"dng_3888_2912_24",codec:"dng",raw:true,width:3888,height:2912,fps:24,format:"CinemaDNG",note:"逐帧 DNG · H.264 代理回看",verifiedLabel:"等待会话"}
 ]
 property string selectedProfileId:"raw_3920_2946_24"
 property string backendProfileId:""
 property bool backendReady:false
 property bool busy:false
 readonly property var selected:find(selectedProfileId)||profiles[1]
 readonly property bool selectionValid:selectedProfileId===selected.id
 readonly property bool canRecord:selectionValid && backendReady && backendProfileId===selectedProfileId && !busy
 signal intentSelected(string profileId)
 function find(id){for(var i=0;i<profiles.length;++i){if(profiles[i].id===id)return profiles[i];}return null;}
 function select(id){if(busy || !find(id))return false;if(id!==selectedProfileId){selectedProfileId=id;intentSelected(id);}return true;}
 function setRaw(value){if(selected.raw===value)return true;for(var i=0;i<profiles.length;++i){if(profiles[i].raw===value)return select(profiles[i].id);}return false;}
}
