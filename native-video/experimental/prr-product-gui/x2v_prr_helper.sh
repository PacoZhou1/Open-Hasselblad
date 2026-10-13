#!/system/bin/sh
# Keep phase=starting while rec/busy is set; do not drop to idle on the next poll.
# ADB-domain helper (cpuacct /uid_0/pid_3102). Publishes 就绪 heartbeat.
set -eu
set -f
ROOT=/blackbox/x2v-native-20261011
REC=$ROOT/rec
mkdir -p "$REC" "$ROOT/play" "$ROOT/runs/prr-gui-persist"
: > "$REC/helper.pid"
printf '%s\n' "$$" > "$REC/helper.pid"
START_DEADLINE=0
phase=idle
detail=""
ensure_play() {
    PLAY=/system/bin/x2v_prr_play_20261013a
    [ -x "$PLAY" ] || PLAY=/system/bin/x2v_prr_play
    [ -x "$PLAY" ] || return 0
    mkdir -p "$ROOT/play"
    chmod 755 "$ROOT/play" 2>/dev/null || true
    chmod 644 "$ROOT/play/frame.ppm" "$ROOT/play/frame.ppm.tmp" 2>/dev/null || true
    pp=$(cat "$ROOT/runs/prr-gui-persist/play.pid" 2>/dev/null || true)
    case "$pp" in ''|*[!0-9]*) ;; *) [ -d /proc/"$pp" ] && return 0 ;; esac
    umask 022
    "$PLAY" --listen 127.0.0.1:18763 --dir "$ROOT/play" >>"$ROOT/runs/prr-gui-persist/prr-play.log" 2>&1 &
    printf '%s\n' "$!" > "$ROOT/runs/prr-gui-persist/play.pid"
}
while [ ! -f "$REC/helper.stop" ]; do
    ensure_play
    now=0
    IFS='.' read -r now unused < /proc/uptime 2>/dev/null || now=0
    if [ -f /system/bin/x2v_prr_proxy_20261013b ] && \
       [ -f /system/lib64/libx2v_mode21c24_prr_async_20261013a.so ] && \
       [ -f /system/bin/x2v_prr_async_receipt_validate_20261013a ] && \
       [ "$(getprop init.svc.camera-service)" = running ]; then
        ready=true
    else
        ready=false
    fi
    if [ -f "$ROOT/rec-start.png" ]; then
        rm -f "$ROOT/rec-start.png"
        printf '%s\n' start > "$REC/command"
        : > "$REC/busy"
        START_DEADLINE=$((now + 8))
        phase=starting
        detail=""
    elif [ -f "$ROOT/rec-stop.png" ]; then
        rm -f "$ROOT/rec-stop.png"
        printf '%s\n' stop > "$REC/command"
        : > "$REC/user-stop"
        START_DEADLINE=0
        if [ -f "$REC/encoder.pid" ]; then
            phase=recording
        else
            rm -f "$REC/busy"
            phase=finalizing
        fi
    elif [ -f "$REC/encoder.pid" ]; then
        ep=$(cat "$REC/encoder.pid" 2>/dev/null || true)
        case "$ep" in ''|*[!0-9]*) rm -f "$REC/encoder.pid"; phase=error; rm -f "$REC/busy"; START_DEADLINE=0 ;;
        *) if [ -d /proc/"$ep" ]; then phase=recording; START_DEADLINE=0; else rm -f "$REC/encoder.pid" "$REC/busy"; START_DEADLINE=0; phase=saved; fi ;;
        esac
    elif [ -f "$REC/busy" ]; then
        rp=$(cat "$REC/recorder.pid" 2>/dev/null || true)
        case "$rp" in ''|*[!0-9]*) recorder_alive=0 ;; *) if [ -d /proc/"$rp" ]; then recorder_alive=1; else recorder_alive=0; fi ;; esac
        if [ "$recorder_alive" = 0 ] && [ "$START_DEADLINE" -gt 0 ] && [ "$now" -ge "$START_DEADLINE" ]; then
            rm -f "$REC/busy" "$REC/command"
            START_DEADLINE=0
            phase=error
            detail="录制会话未接上"
        else
            phase=starting
        fi
    elif [ "$phase" != error ]; then
        phase=idle
        detail=""
        START_DEADLINE=0
    fi
    printf '%s\n' "{\"schema\":1,\"backend_ready\":$ready,\"profile_id\":\"raw_3920_2946_24\",\"phase\":\"$phase\",\"detail\":\"$detail\",\"fresh\":true,\"uptime\":$now,\"helper_pid\":$$}" > "$REC/state.json.tmp"
    mv "$REC/state.json.tmp" "$REC/state.json"
    sleep 1
done
