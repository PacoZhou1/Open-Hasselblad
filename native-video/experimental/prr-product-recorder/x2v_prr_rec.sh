#!/system/bin/sh
# Persistent ProRes RAW recorder. init restarts this process. One shutter
# start runs one real sensor clip, until the shutter stops it or 8 seconds.
set -u
set -f
ROOT=/blackbox/x2v-native-20261011
REC=$ROOT/rec
PKT=$ROOT/prr-rec
DATA=/data/x2v-source-20261012
CTRL=$PKT/controller.sh
LOG=$REC/recorder.log
mkdir -p "$REC" "$PKT" "$DATA"
printf '%s\n' "$$" > "$REC/recorder.pid"
log() { printf '%s %s\n' "$(cat /proc/uptime)" "$*" >> "$LOG"; }

cgroup_of() {
    awk -F: '$2=="cpuacct" {print $3}' "/proc/$1/cgroup"
}
overlay_pids() {
    for p in $(pidof camera-gui 2>/dev/null || true); do
        if tr '\0' '\n' < "/proc/$p/environ" 2>/dev/null | grep -q '^X2V_GUI_ENABLE=1$'; then
            printf '%s\n' "$p"
        fi
    done
}
stop_overlay() {
    setprop ctl.stop x2v-prr-gui || true
    n=0
    while [ -n "$(overlay_pids)" ] && [ "$n" -lt 30 ]; do
        for p in $(overlay_pids); do kill -TERM "$p" 2>/dev/null || true; done
        n=$((n+1)); sleep 0.2
    done
    for p in $(overlay_pids); do kill -KILL "$p" 2>/dev/null || true; done
    rm -rf "$ROOT/gui-session.lock"
}
start_stock_gui() {
    setprop ctl.start camera-gui || true
    n=0
    while [ "$n" -lt 40 ]; do
        if [ "$(getprop init.svc.camera-gui)" = running ] && [ -z "$(overlay_pids)" ] && [ -n "$(pidof camera-gui 2>/dev/null || true)" ]; then
            return 0
        fi
        n=$((n+1)); sleep 0.25
    done
    return 1
}
bring_overlay() {
    rm -f "$ROOT/rec/boot.stop"
    setprop ctl.start x2v-prr-gui || true
}
publish_clip() {
    id=$1
    src=/mnt/media_rw/ssd/x2v-source-20261012/runs/$id/dng/clip.mov
    [ -f "$src" ] || return 1
    take=/mnt/media_rw/ssd/X2V_RAW/X2V_PRR_$id
    mkdir -p "$take" || return 1
    cp "$src" "$take/clip.mov" || return 1
    bytes=$(stat -c %s "$take/clip.mov") || return 1
    cat > "$REC/catalog.json" <<EOF
{"schemaVersion":1,"clips":[{"id":"X2V_PRR_$id","state":"saved","finalized":true,"source":"$take/clip.mov","thumbnail":"$ROOT/prr-050839.jpg","title":"ProRes RAW HQ","duration":8,"bytes":$bytes,"width":3888,"height":2912,"format":"ProRes RAW HQ"}]}
EOF
    log "PUBLISHED $take/clip.mov $bytes"
}

capture_once() {
    id=prr-$(cat /proc/uptime | awk '{print int($1)}')
    run=$DATA/runs/$id
    rm -rf "$run"
    mkdir -p "$run" || return 1
    : > "$run/product.mode"
    cg=$(cgroup_of $$) || return 1
    printf '%s\n' "$cg" > "$DATA/target.group"
    log "CAPTURE $id cgroup=$cg domain=$(cat /proc/self/attr/current 2>/dev/null)"
    rm -f "$REC/user-stop" "$REC/command"
    : > "$REC/busy"
    stop_overlay
    if ! start_stock_gui; then
        log STOCK_GUI_NOT_READY
        bring_overlay
        return 1
    fi
    toybox setsid sh "$CTRL" --execute-isolated-two-prr-async "$id" >> "$LOG" 2>&1 &
    ep=$!
    printf '%s\n' "$ep" > "$REC/encoder.pid"
    wait "$ep"
    rc=$?
    rm -f "$REC/encoder.pid" "$REC/busy" "$REC/user-stop"
    log "CAPTURE_RC $rc"
    publish_clip "$id" || log PUBLISH_SKIPPED
    bring_overlay
    return "$rc"
}

log "recorder start pid=$$ cgroup=$(cgroup_of $$)"
while [ ! -f "$REC/recorder.stop" ]; do
    cmd=$(cat "$REC/command" 2>/dev/null || true)
    if [ "$cmd" = start ] && [ ! -f "$REC/encoder.pid" ]; then
        capture_once || log CAPTURE_FAILED
    fi
    sleep 1
done
log recorder.stop
rm -f "$REC/recorder.pid"
