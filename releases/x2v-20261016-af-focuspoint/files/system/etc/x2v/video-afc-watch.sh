#!/system/bin/sh
# Own focus only for this video service lifetime, independently of clip lifetime.
set -u
LIVE=/tmp/x2v-live
owner=$1
find_pid=
requested=0
last_mode=
log() { read up rest < /proc/uptime; echo "$up $*"; }
same_owner() { [ "$(cat "$LIVE/service.pid" 2>/dev/null)" = "$owner" ] && kill -0 "$owner" 2>/dev/null; }
stop_focus() {
    if [ "$requested" = 1 ] && same_owner; then
        timeout 3 odindb-send -s camera -m stop_session
        log AF_STOP
    fi
    [ -z "$find_pid" ] || { wait "$find_pid" 2>/dev/null || true; }
    find_pid=
    requested=0
}
cleanup() {
    stop_focus
    [ "$(cat "$LIVE/video-afc.pid" 2>/dev/null)" != "$$" ] || rm -f "$LIVE/video-afc.pid"
    log WATCH_END
}
trap cleanup EXIT
trap 'exit 0' HUP INT TERM
echo $$ > "$LIVE/video-afc.pid"
log "WATCH_START owner=$owner"
while same_owner && [ "$(cat "$LIVE/session" 2>/dev/null)" = up ] && [ ! -e "$LIVE/video-afc.stop" ]; do
    values=$(timeout 2 odindb-send -s camera -p focus_mode,af_status 2>/dev/null)
    mode=$(printf '%s\n' "$values" | sed -n 's/^focus_mode = //p')
    active=$(printf '%s\n' "$values" | sed -n 's/^af_status = //p')
    if [ "$mode" != "$last_mode" ]; then log "MODE $mode"; last_mode=$mode; fi
    context=$(cat /tmp/x2v-product/af-context 2>/dev/null)
    if [ "$context" != viewfinder ]; then
        stop_focus
        sleep .3
        continue
    fi
    case "$mode" in
        E_FocusModes_Afs\(*)
            stop_focus
            timeout 2 odindb-send -s camera -p focus_mode -- 4
            ;;
        E_FocusModes_Afc\(4\))
            if [ -n "$active" ] && [ "$active" != 'E_AutoFocusStatus_RunningCont(3)' ]; then
                [ -z "$find_pid" ] || { wait "$find_pid" 2>/dev/null || true; }
                timeout 3 odindb-send -s camera -m find_focus > "$LIVE/video-afc-find.log" 2>&1 &
                find_pid=$!
                requested=1
                log "AF_START pid=$find_pid"
            fi
            ;;
        *) stop_focus;;
    esac
    sleep .3
done
