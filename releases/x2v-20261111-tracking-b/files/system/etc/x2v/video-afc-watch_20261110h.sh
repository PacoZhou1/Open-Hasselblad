#!/system/bin/sh
# One outstanding AF request per owned service. A CLI timeout is not a native
# cancellation acknowledgement; never enqueue another while the session lives.
set -u
LIVE=${X2V_AF_LIVE:-/tmp/x2v-live}
PROD=${X2V_AF_PROD:-/tmp/x2v-product}
PROC=${X2V_AF_PROC:-/proc}
HOME_DIR=/blackbox/x2v-native-20261011/video
owner=$1
find_pid=
requested=0
request_at=0
last_mode=
retry_at=0
retry_delay=1
query_failures=0
now() { read up rest < "$PROC/uptime"; NOW=${up%%.*}; }
log() { read up rest < "$PROC/uptime"; echo "$up $*"; }
same_owner() { [ "$(cat "$LIVE/service.pid" 2>/dev/null)" = "$owner" ] && kill -0 "$owner" 2>/dev/null; }
reap_find() {
    [ -n "$find_pid" ] || return 0
    line=
    [ ! -r "$PROC/$find_pid/stat" ] || read line < "$PROC/$find_pid/stat"
    case "$line" in
        ''|*') Z '*) wait "$find_pid" 2>/dev/null || true; find_pid=;;
    esac
}
stop_focus() {
    if [ "$requested" = 1 ] && same_owner; then
        timeout 1 odindb-send -s camera -m stop_session
        rc=$?; log "AF_STOP rc=$rc"
    fi
    # Reap only completed clients. Never wait on a live D-Bus client from a
    # navigation/shutdown path; its own timeout will finish it.
    reap_find
    requested=0
    retry_at=0
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
    [ ! -f "$HOME_DIR/af-diagnostic-pause" ] || break
    reap_find
    context=$(cat "$PROD/af-context" 2>/dev/null)
    if [ "$context" != viewfinder ]; then
        stop_focus
        sleep .3
        continue
    fi
    values=$(timeout 2 odindb-send -s camera -p focus_mode,af_status,exposure_status,find_focus_active 2>/dev/null)
    mode=$(printf '%s\n' "$values" | sed -n 's/^focus_mode = //p')
    active=$(printf '%s\n' "$values" | sed -n 's/^af_status = //p')
    exposure=$(printf '%s\n' "$values" | sed -n 's/^exposure_status = //p')
    busy=$(printf '%s\n' "$values" | sed -n 's/^find_focus_active = //p')
    if [ -z "$mode" ] || [ -z "$active" ] || [ -z "$exposure" ] || [ -z "$busy" ]; then
        query_failures=$((query_failures+1))
        if [ "$query_failures" -ge 2 ]; then
            log AF_CONTROL_UNAVAILABLE
            echo control_unavailable > "$LIVE/video-afc.fault"
            break
        fi
        sleep .3
        continue
    fi
    query_failures=0
    if [ "$mode" != "$last_mode" ]; then log "MODE $mode"; last_mode=$mode; fi
    case "$mode" in
        E_FocusModes_Afs\(*)
            stop_focus
            timeout 2 odindb-send -s camera -p focus_mode -- 4
            ;;
        E_FocusModes_Afc\(4\))
            if [ "$active" = 'E_AutoFocusStatus_RunningCont(3)' ]; then
                retry_delay=1
            elif [ "$busy" = false ] && [ "$exposure" = 'E_ExposureStatus_None(0)' ]; then
                now
                if [ "$requested" = 1 ]; then
                    # Keep cancellation ownership while the client/request is
                    # still being accepted. A quiet status is not an ACK.
                    if [ -n "$find_pid" ] || [ $((NOW-request_at)) -lt 2 ]; then
                        sleep .3
                        continue
                    fi
                    requested=0
                    retry_at=$((NOW+retry_delay))
                    [ "$retry_delay" -ge 4 ] || retry_delay=$((retry_delay*2))
                    log "AF_SESSION_ENDED retry_at=$retry_at"
                fi
                if [ -z "$find_pid" ] && [ "$NOW" -ge "$retry_at" ]; then
                    timeout 3 odindb-send -s camera -m find_focus > "$LIVE/video-afc-find.log" 2>&1 &
                    find_pid=$!
                    requested=1
                    request_at=$NOW
                    log "AF_START pid=$find_pid"
                fi
            fi
            ;;
        *) stop_focus;;
    esac
    sleep .3
done
