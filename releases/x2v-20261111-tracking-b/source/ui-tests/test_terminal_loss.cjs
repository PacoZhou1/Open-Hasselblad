const fs=require('fs'),vm=require('vm'),assert=require('assert');
const A=vm.runInNewContext(fs.readFileSync(__dirname+'/gui/TouchTrackingController.js','utf8')+';({initial,step,packedPoint})');
const point={x:.4,y:.5},epoch='vot/accepted-ab/terminal-loss';
const base={enabled:true,video:true,context:'viewfinder',manual:false,focusMode:4,focusArea:2,objectDetection:0,
 backendReady:true,epoch,sourceSeq:100,nativeSeedSeq:4,quietToken:'',inSession:false,afCommandBusy:false,
 afRunning:false,mlRunning:true,workerActive:true,lifecycleSeq:8,focusPoint:A.packedPoint(point),touchTracking:true,arbitraryTracking:true};
const types=r=>Array.from(r.effects,e=>e.type);
function acquire(){
 let c={...base},s=A.step(A.initial(),{type:'tap',point},c,1000).state;
 c.quietToken=s.token;s=A.step(s,{type:'tick'},c,1050).state;
 let r=A.step(s,{type:'point_readback'},c,1060);assert.deepEqual(types(r),['point_ready','start_af']);s=r.state;
 c={...c,inSession:true,afRunning:true,nativeSeedSeq:5,sourceSeq:101};
 r=A.step(s,{type:'receipt',receipt:packet(101,1200)},c,1200);
 assert.equal(r.state.phase,'locked');return {s:r.state,c};
}
function packet(frameSeq,observedAt,extra={}){return {origin:'native_vot_result',epoch,nativeSeedSeq:5,frameSeq,observedAt,
 targetId:0,arbitrary:true,tracked:true,lost:false,region:{x:.3,y:.4,width:.2,height:.2},...extra};}
let tests=0;
for(const [extra,reason] of [[{lost:true},'target_lost'],[{targetId:7},'target_id_changed'],[{tracked:false},'target_unavailable']]){
 let {s,c}=acquire();c.sourceSeq=102;
 let r=A.step(s,{type:'receipt',receipt:packet(102,1300,extra)},c,1300);s=r.state;
 assert.equal(s.phase,'releasing');assert.equal(s.region,null);assert.equal(s.reason,reason);assert.deepEqual(types(r),['stop_af']);
 // The precise regression: a fresh recovered result must not bring back a
 // tracking target while the release command is still draining.
 c.sourceSeq=103;r=A.step(s,{type:'receipt',receipt:packet(103,1320)},c,1320);s=r.state;
 assert.equal(s.phase,'releasing');assert.equal(r.effects.length,0);
 c.inSession=false;r=A.step(s,{type:'tick'},c,1350);s=r.state;
 assert.equal(s.phase,'idle');assert.deepEqual(types(r),['restore','unclaim']);assert.equal(r.effects[0].reason,reason);
 c.sourceSeq=104;r=A.step(s,{type:'receipt',receipt:packet(104,1400)},c,1400);
 assert.equal(r.state.phase,'idle');assert.equal(r.effects.length,0);
 // A genuinely new user tap is allowed; an old seed's frame cannot lock it.
 c.nativeSeedSeq=5;r=A.step(s,{type:'tap',point},c,1500);s=r.state;assert.equal(s.phase,'claiming');
 c.quietToken=s.token;s=A.step(s,{type:'tick'},c,1550).state;assert.equal(s.generation,2);
 s=A.step(s,{type:'point_readback'},c,1560).state;
 c.inSession=true;c.afRunning=true;c.sourceSeq=105;
 r=A.step(s,{type:'receipt',receipt:packet(105,1600)},c,1600);assert.equal(r.state.phase,'pending');
 r=A.step(r.state,{type:'receipt',receipt:packet(106,1650,{nativeSeedSeq:6})},{...c,sourceSeq:106,nativeSeedSeq:6},1650);
 assert.equal(r.state.phase,'locked');tests++;
}
{
 let {s,c}=acquire();c.sourceSeq=110;
 let r=A.step(s,{type:'tick'},c,1800);assert.equal(r.state.phase,'releasing');
 assert.equal(r.state.reason,'receipt_timeout');assert.deepEqual(types(r),['stop_af']);tests++;
}
for(const change of [{manual:true},{context:'navigation'},{video:false}]){
 const {s,c}=acquire();const r=A.step(s,{type:'tick'},{...c,...change},1300);
 assert.equal(r.state.phase,'releasing');assert.deepEqual(types(r),['stop_af']);tests++;
}
{
 const {s,c}=acquire();const r=A.step(s,{type:'cancel'},c,1300);
 assert.equal(r.state.reason,'cancel');assert.deepEqual(types(r),['stop_af']);tests++;
}
{
 const {s,c}=acquire();const r=A.step(s,{type:'receipt',receipt:packet(102,1300,{lost:true})},{...c,inSession:false,afRunning:false,sourceSeq:102},1300);
 assert.equal(r.state.phase,'idle');assert.equal(r.state.reason,'native_session_end');
 assert.deepEqual(types(r),['stop_af','restore','unclaim']);tests++;
}
fs.writeFileSync(__dirname+'/test-receipt.json',JSON.stringify({passed:tests,hardware:false,
 scope:'Real lock/loss/recovered packet counterexample; release ACK; late-frame rejection; explicit new tap; receipt timeout; MF/navigation/cancel'},null,2)+'\n');
console.log('PASS '+tests+' terminal-loss lifecycle cases');
