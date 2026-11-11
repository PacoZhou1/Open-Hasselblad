// Native VOT control only. A focus-point write or AF map is never a VOT receipt.
function initial() {
    return {phase:"idle", generation:0, token:"", point:null, nextPoint:null,
        epoch:"", baseline:-1, nativeSeedBaseline:0, lastSeq:-1, at:0, receiptAt:0, targetId:-1,
        region:null, acquired:false, progressSeq:-1, progressAt:0, mlOwned:false, afOwned:false, stopSent:false,
        stopSeq:-1, reason:""};
}
function hasLease(s) { return s.phase !== "idle"; }
function allowed(c) {
    return c.enabled && c.video && c.context === "viewfinder" && !c.manual &&
        c.focusMode === 4 && c.focusArea === 2 && c.objectDetection === 0 &&
        c.backendReady && !!c.epoch && Number.isInteger(c.sourceSeq) && c.sourceSeq >= 0;
}
function pointValid(p) { return p && Number.isFinite(p.x) && Number.isFinite(p.y) && p.x>=0 && p.x<=1 && p.y>=0 && p.y<=1; }
function regionValid(r) {
    return r && pointValid(r) && Number.isFinite(r.width) && Number.isFinite(r.height) &&
        r.width>0 && r.height>0 && r.x+r.width<=1 && r.y+r.height<=1;
}
function packedPoint(p) {
    return (Math.round(p.x*10000) | (Math.round(p.y*10000)<<16) | 0xC0000000) >>> 0;
}
function pointReadbackReady(s,c) {
    var point=Number(c.focusPoint);
    return Number.isInteger(point) && point>=0 && point<=0xffffffff &&
        ((point&0x3fffffff)>>>0)===((packedPoint(s.point)&0x3fffffff)>>>0) &&
        c.touchTracking===true && c.arbitraryTracking===true;
}
function firstRegionAligned(point,region) {
    // Only acquisition is constrained. Once locked the native ROI may move freely.
    var epsilon=0.0001;
    return pointValid(point) && point.x>=region.x-epsilon && point.x<=region.x+region.width+epsilon &&
        point.y>=region.y-epsilon && point.y<=region.y+region.height+epsilon;
}
function release(s, reason, now, out) {
    if (!hasLease(s) || s.phase === "releasing" || s.phase === "blocked") return;
    s.phase="releasing"; s.reason=reason; s.at=now; s.targetId=-1; s.region=null;
    if (s.afOwned) out.push({type:"stop_af",reason:reason});
}
function loseTarget(s,reason,now,out) {
    // A genuine loss ends this click's lease. Late native results cannot
    // reacquire it; only a new explicit tap may create another generation.
    s.nextPoint=null;
    release(s,reason,now,out);
}
function seed(s, c, now, out) {
    s.phase="seeding"; s.generation++; s.baseline=c.sourceSeq; s.lastSeq=c.sourceSeq;
    s.nativeSeedBaseline=c.nativeSeedSeq;
    s.acquired=false;s.progressSeq=c.sourceSeq;s.progressAt=now;
    s.at=now; s.receiptAt=0; s.targetId=-1; s.region=null; s.afOwned=true;
    out.push({type:"seed", point:s.point, packed:packedPoint(s.point), generation:s.generation});
}
function step(previous, event, c, now) {
    var s=Object.assign({},previous), out=[];
    if (hasLease(s) && (!c.backendReady || c.epoch!==s.epoch)) {
        // Do not send a delayed stop or seed into a replacement service.
        // Unclaim lets the PID-scoped watcher drain the old service if alive.
        var oldGeneration=s.generation;
        s=initial();s.generation=oldGeneration;s.reason="source_unavailable";
        return {state:s,effects:[{type:"abandon_settings"},{type:"unclaim"},{type:"recovery_required"}]};
    }
    if (hasLease(s) && s.phase!=="releasing" && s.phase!=="blocked" &&
        (!allowed(c) || c.epoch!==s.epoch)) {
        s.nextPoint=null;
        release(s,c.manual?"manual":!c.video?"video_exit":c.context!=="viewfinder"?"navigation":"source_or_mode_change",now,out);
    }
    if (s.acquired && (s.phase==="locked" || s.phase==="af_wait" || s.phase==="searching")) {
        if (Number.isInteger(c.sourceSeq) && c.sourceSeq>s.progressSeq) {
            s.progressSeq=c.sourceSeq;s.progressAt=now;
        }
        if (!c.mlRunning || !c.workerActive) release(s,"ml_inactive",now,out);
        else if (!c.inSession) release(s,"native_session_end",now,out);
        else if (now-s.progressAt>=3500) release(s,"native_progress_timeout",now,out);
    }
    if (event.type==="cancel") {
        s.nextPoint=null; release(s,"cancel",now,out);
    } else if (event.type==="tap" && pointValid(event.point) && allowed(c)) {
        if (s.phase==="idle") {
            s.phase="claiming"; s.point=event.point; s.epoch=c.epoch;
            s.token=c.epoch+"/tap/"+(s.generation+1)+"/"+now; s.at=now; s.reason="";
            out.push({type:"claim",token:s.token});
        } else if (event.type==="tap" && (s.phase==="claiming" || s.phase==="starting_ml")) {
            s.point=event.point;
        } else if (event.type==="tap" && s.phase==="armed") {
            s.point=event.point;seed(s,c,now,out);
        } else if (event.type==="tap" && s.phase!=="blocked") {
            s.nextPoint=event.point;
            release(s,"retarget",now,out);
        }
    }
    // The watcher's exact token proves its previous find command has drained.
    // inSession=false alone cannot prevent a late watcher stop_session race.
    if (s.phase==="claiming" && c.quietToken===s.token && !c.inSession && !c.afCommandBusy) {
        if (c.mlRunning && c.workerActive) {
            if (s.point) seed(s,c,now,out); else s.phase="armed";
        }
        else release(s,"ml_preheat_unavailable",now,out);
    }
    if (s.phase==="starting_ml" && c.mlRunning && c.workerActive) {
        if (s.point) seed(s,c,now,out); else s.phase="armed";
    }
    // A later snapshot/readback event must acknowledge coordinates AND flags.
    // Never send AF in the same effect batch as the seed property setters.
    if (s.phase==="seeding" && previous.phase==="seeding" && pointReadbackReady(s,c) && !c.afCommandBusy) {
        s.phase="pending";
        out.push({type:"point_ready",packed:packedPoint(s.point),readback:c.focusPoint});
        out.push({type:"start_af"});
    }
    if (event.type==="receipt" && (s.phase==="pending" || s.phase==="locked" || s.phase==="af_wait" || s.phase==="searching")) {
        var r=event.receipt;
        if (r && r.origin==="native_vot_result" && r.epoch===s.epoch &&
            Number.isInteger(r.nativeSeedSeq) && r.nativeSeedSeq>s.nativeSeedBaseline && Number.isInteger(r.frameSeq) &&
            r.frameSeq>s.lastSeq && r.frameSeq>s.baseline && Number.isFinite(r.observedAt) &&
            r.observedAt>=s.at && r.observedAt<=now && now-r.observedAt<=400) {
            s.lastSeq=r.frameSeq;
            if (r.lost || (s.acquired && r.targetId!==s.targetId)) {
                if (s.acquired) loseTarget(s,r.lost?"target_lost":"target_id_changed",now,out);
                // Before first lock, a stamped old Lost packet is not a
                // cancellation ACK. Keep the original acquisition deadline.
                // No reseed, AF restart or deadline extension here.
            }
            else if (r.arbitrary && r.tracked && Number.isInteger(r.targetId) && r.targetId>=0 &&
                     c.inSession && c.mlRunning && c.workerActive && regionValid(r.region) &&
                     (s.acquired || firstRegionAligned(s.point,r.region))) {
                if (c.afRunning) {
                    s.phase="locked";s.targetId=r.targetId;s.region=r.region;s.receiptAt=now;
                    if (!s.acquired) { s.progressSeq=c.sourceSeq;s.progressAt=now; }
                    s.acquired=true;s.reason="";
                } else if (s.acquired) {
                    // Tracking is valid; AF readiness is a separate condition.
                    if (s.phase!=="af_wait") out.push({type:"af_wait",reason:"af_not_running",targetId:s.targetId});
                    s.phase="af_wait";s.region=r.region;s.receiptAt=now;s.reason="af_not_running";
                }
            } else if (s.acquired) loseTarget(s,"target_unavailable",now,out);
        }
    }
    if (s.phase==="claiming" && now-s.at>=3500) release(s,"af_handoff_timeout",now,out);
    if (s.phase==="starting_ml" && now-s.at>=2500) release(s,"ml_start_timeout",now,out);
    if ((s.phase==="seeding" || s.phase==="pending") && now-s.at>=1500) release(s,"acquire_timeout",now,out);
    if (s.phase==="locked" && !c.afRunning) {
        s.phase="af_wait";s.reason="af_not_running";
        out.push({type:"af_wait",reason:s.reason,targetId:s.targetId});
    }
    if ((s.phase==="locked" || s.phase==="af_wait") && now-s.receiptAt>=600)
        loseTarget(s,"receipt_timeout",now,out);
    if (s.phase==="releasing" && !c.inSession && !c.afCommandBusy) {
        s.afOwned=false;
        if (s.nextPoint && allowed(c) && c.epoch===s.epoch && c.mlRunning && c.workerActive && !s.stopSent) {
            s.point=s.nextPoint; s.nextPoint=null; seed(s,c,now,out);
        } else {
            s.nextPoint=null;
            if (s.mlOwned && !s.stopSent) {
                s.stopSent=true; s.stopSeq=c.lifecycleSeq;
                out.push({type:"stop_ml"});
            } else if (!s.mlOwned || (!c.mlRunning && !c.workerActive && c.lifecycleSeq>s.stopSeq)) {
                var generation=s.generation, reason=s.reason;
                s=initial(); s.generation=generation; s.reason=reason;
                out.push({type:"restore",reason:reason}); out.push({type:"unclaim",reason:reason});
            }
        }
    }
    if (s.phase==="releasing" && now-s.at>=3500) {
        var generation=s.generation;
        s=initial();s.generation=generation;s.reason="release_timeout";
        out.push({type:"abandon_settings"});out.push({type:"unclaim"});out.push({type:"recovery_required"});
    }
    return {state:s,effects:out};
}
