#!/system/bin/sh
# One outstanding AF request per owned service. A CLI timeout is not a native
# cancellation acknowledgement; never enqueue another while the session lives.
set -u
LIVE=${X2V_AF_LIVE:-/tmp/x2v-live}
PROD=${X2V_AF_PROD:-/tmp/x2v-product}
PROC=${X2V_AF_PROC:-/proc}
HOME_DIR=/blackbox/x2v-native-20261011/video
owner=$1
vot_token=
vot_wait=0
find_pid=
requested=0
request_at=0
last_mode=
retry_at=0
retry_delay=1
query_failures=0
now() { read up rest < "$PROC/uptime"; NOW=${up%%.*}; }
log() { read up rest < "$PROC/uptime"; echo "$up $*"; }
read_file() { FILE_TEXT=; IFS= read -r FILE_TEXT < "$1" 2>/dev/null || true; }
owner_ticks() {
    stat_line=; IFS= read -r stat_line < "$PROC/$owner/stat" 2>/dev/null || return 1
    stat_tail=${stat_line##*) };set -- $stat_tail
    [ "$#" -ge 20 ] || return 1
    shift 19;OWNER_TICKS=$1
}
owner_ticks || exit 1
owner_started=$OWNER_TICKS
same_owner() {
    read_file "$LIVE/service.pid"
    [ "$FILE_TEXT" = "$owner" ] && kill -0 "$owner" 2>/dev/null &&
        owner_ticks && [ "$OWNER_TICKS" = "$owner_started" ]
}
session_up() { read_file "$LIVE/session";[ "$FILE_TEXT" = up ]; }
token_owner_matches() {
    read_file "$LIVE/vot-state.json";native=$FILE_TEXT
    case "$native" in *'"epoch":"'*'"servicePid":'*) ;; *) return 1;; esac
    native_epoch=${native#*'"epoch":"'};native_epoch=${native_epoch%%'"'*}
    native_pid=${native#*'"servicePid":'};native_pid=${native_pid%%,*}
    [ "$native_pid" = "$owner" ] && [ "${token%/tap/*}" = "$native_epoch" ]
}
parse_status() {
    mode=;active=;exposure=;busy=
    ff=;fe=;ss=;st=
    while read -r key equal value;do
      [ "$equal" = = ] || continue
      case "$key" in
       focus_mode) mode=$value;; af_status) active=$value;; exposure_status) exposure=$value;;
       find_focus_active) ff=$value;busy=$value;;find_focus_extended_active) fe=$value;;
       stop_session_active) ss=$value;;start_session_active) st=$value;;
      esac
    done <<EOF
$1
EOF
}

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
release_vot() {
    if [ -n "$vot_token" ] && same_owner; then
        timeout 1 odindb-send -s camera -m stop_session
        log VOT_AF_RELEASE
    fi
    vot_token=
    rm -f "$LIVE/vot-af-quiet" "$LIVE/vot-af-quiet.tmp"
}
cleanup() {
    release_vot
    stop_focus
    [ "$(cat "$LIVE/video-afc.pid" 2>/dev/null)" != "$$" ] || rm -f "$LIVE/video-afc.pid"
    log WATCH_END
}
trap cleanup EXIT
trap 'exit 0' HUP INT TERM
echo $$ > "$LIVE/video-afc.pid"
log "WATCH_START owner=$owner"
while same_owner && session_up && [ ! -e "$LIVE/video-afc.stop" ]; do
    [ ! -f "$HOME_DIR/af-diagnostic-pause" ] || break
    reap_find
    [ ! -e "$PROD/shutdown-requested" ] || break
    read_file "$PROD/af-context";context=$FILE_TEXT
    case "$context" in
      tracking:*)
        token=${context#tracking:}
        now
        # read assigns valid fields even if the final record has no newline.
        # Reset first to avoid reusing stale fields after missing/partial files.
        heartbeat=;stamp=
        read heartbeat stamp < "$LIVE/vot-owner" 2>/dev/null || true
        case "${stamp:-}" in ''|*[!0-9]*) stamp=0;; esac
        wall=$(date +%s)
        if [ "$token" != "$vot_token" ]; then
            release_vot
            vot_token=$token;vot_wait=$NOW
        fi
        if [ "$heartbeat" != "$token" ] || [ "$wall" -lt "$stamp" ] || [ $((wall-stamp)) -gt 2 ]; then
            if [ $((NOW-vot_wait)) -ge 2 ]; then
                log VOT_HEARTBEAT_EXPIRED
                release_vot
                # Do not overwrite a newer GUI navigation/token intent.
                [ "$(cat "$PROD/af-context" 2>/dev/null)" != "$context" ] || echo navigation > "$PROD/af-context"
            fi
            sleep .3;continue
        fi
        vot_wait=$NOW
        stop_focus
        [ -z "$find_pid" ] || { sleep .3;continue; }
        read_file "$LIVE/vot-af-quiet"
        if [ "$FILE_TEXT" != "$token" ]; then
            # Only this transfer checks all native pending methods; no UI waits.
            same_owner || break
            quiet=$(timeout 2 odindb-send -s camera -p find_focus_active,find_focus_extended_active,stop_session_active,start_session_active 2>/dev/null)
            same_owner || break
            parse_status "$quiet"
            [ "$ff" = false ] && [ "$fe" = false ] && [ "$ss" = false ] && [ "$st" = false ] || { sleep .3;continue; }
            read_file "$PROD/af-context";[ "$FILE_TEXT" = "$context" ] || continue
            token_owner_matches || { sleep .3;continue; }
            printf '%s\n' "$token" > "$LIVE/vot-af-quiet.tmp"
            mv "$LIVE/vot-af-quiet.tmp" "$LIVE/vot-af-quiet"
            log VOT_AF_QUIET
        fi
        sleep .3;continue
        ;;
      *)
        # Normal GUI unclaim follows its own AF release ACK; avoid a late stop
        # racing the next ordinary request. Navigation/expired GUI revokes AF.
        if [ -n "$vot_token" ]; then
            if [ "$context" = viewfinder ]; then vot_token=;rm -f "$LIVE/vot-af-quiet";
            else release_vot;fi
        fi
        ;;
    esac
    if [ "$context" != viewfinder ]; then
        stop_focus
        sleep .3
        continue
    fi
    values=$(timeout 2 odindb-send -s camera -p focus_mode,af_status,exposure_status,find_focus_active 2>/dev/null)
    parse_status "$values"
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
