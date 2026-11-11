.pragma library

function begin(target, commandId, now) {
    return {target:target, commandId:String(commandId), beganAt:now,
            acknowledged:false, firstRaw:-1, sourcePid:0};
}

function step(request, snapshot, fresh) {
    if (!request) return {ready:false, reason:"none"};
    if (!fresh || !snapshot || snapshot.schema!==1) return {ready:false, reason:"stale"};
    if (String(snapshot.command_id)===request.commandId) request.acknowledged=true;
    if (!request.acknowledged) return {ready:false, reason:"awaiting_ack"};
    if (snapshot.job_kind) { request.firstRaw=-1; return {ready:false, reason:"handoff"}; }
    if (snapshot.mode!==request.target) return {ready:false, reason:"different_mode"};
    if (request.target==="photo") {
        return {ready:snapshot.session==="down" && snapshot.photo_ready===true,
                reason:"photo_restore"};
    }
    if (snapshot.session!=="up" || snapshot.backend_ready!==true ||
        typeof snapshot.raw_total!=="number" || !(snapshot.source_pid>0))
        return {ready:false, reason:"video_source"};
    if (request.sourcePid!==snapshot.source_pid) {
        request.sourcePid=snapshot.source_pid; request.firstRaw=-1;
    }
    if (request.firstRaw<0) request.firstRaw=snapshot.raw_total;
    return {ready:snapshot.raw_total>request.firstRaw, reason:"fresh_video_frame"};
}
