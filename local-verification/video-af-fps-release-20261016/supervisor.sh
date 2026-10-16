#!/system/bin/sh
# X2V product supervisor, started once per boot by the weston module.
# Owns: the overlay camera-gui, the playback server, and the bridge between the
# GUI (rec/gui.cmd -> rec/state.json, rec/catalog.json) and the resident video
# session. Any failure falls back to the stock camera.
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
set -u
set -f
# weston runs SCHED_FIFO 40 and fork keeps it. Left there, this loop preempted camera-service
# (viewfinder 49.5 -> 41 fps on half-press) and the recorder threads dropped frames.
chrt -o -p $$ 0 >/dev/null 2>&1
ROOT=/blackbox/x2v-native-20261011
PROD=$ROOT/product
REC=$ROOT/rec
# Polled several times a second: tmpfs, not flash.
RUN=/tmp/x2v-product
ETC=/system/etc/x2v
SESSION=$ETC/x2v_video_session_20261014zl.sh
LIVE=/tmp/x2v-live
CLIPS=/mnt/media_rw/ssd/X2V_RAW
GUI=/system/bin/camera-gui
LOADER=/system/lib64/libx2v_gui_bootstrap_20261011.so
PLAY=/system/bin/x2v_prr_play_20261014zg
# Rewritten every played frame: tmpfs, not flash.
PLAYDIR=/tmp/x2v-play
GUI_SHA=b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b
LOADER_SHA=2ec7b4686682ea1c5c9e9de87876135e0085b8563c90d223211150c3572708dd
LOCK=$PROD/supervisor.lock
LOG=$PROD/supervisor.log
# Held only while a clip records: the camera's shutdown waits for every wake lock.
WAKE=x2v-video-recording

# The main loop runs five times a second, so its helpers set variables instead of printing:
# every $(...) here is a fork.
now() { read up rest < /proc/uptime; NOW=${up%%.*}; }
# Centiseconds: /proc/uptime always has two decimals.
cs() { read up rest < /proc/uptime; CS=${up%.*}${up#*.}; }
uptime_s() { now; printf '%s\n' "$NOW"; }
log() { read up rest < /proc/uptime; printf '%s %s\n' "$up" "$*" >> "$LOG"; }
valid_pid() { case "$1" in ''|*[!0-9]*) return 1;; esac; [ "$1" -gt 1 ]; }
# PS = start time of a live, non-zombie process.
pstart() {
    PS=""
    valid_pid "$1" && [ -r "/proc/$1/stat" ] || return 1
    IFS= read -r line < "/proc/$1/stat" || return 1
    set -- ${line##*) }
    [ "$#" -ge 20 ] && [ "$1" != Z ] || return 1
    shift 19; PS=$1
}
alive() { [ -n "$2" ] && pstart "$1" && [ "$PS" = "$2" ]; }
verify() { printf '%s  %s\n' "$2" "$1" | sha256sum -c - >/dev/null 2>&1; }

# weston (and so this script) starts before /blackbox, which is a late mount.
mount_end=$(( $(uptime_s) + 240 ))
until grep -q ' /blackbox ' /proc/mounts; do [ "$(uptime_s)" -lt "$mount_end" ] || exit 2; sleep 1; done
[ -f "$PROD/disable" ] && exit 0
mkdir -p "$PROD" "$REC" "$RUN" "$PLAYDIR" || exit 1

# One supervisor per boot; a stale lock from a previous boot has a dead owner.
if ! mkdir "$LOCK" 2>/dev/null; then
    read op os < "$LOCK/owner" 2>/dev/null || true
    if alive "${op:-}" "${os:-}"; then exit 0; fi
    rm -rf "$LOCK"; mkdir "$LOCK" || exit 1
fi
pstart $$; printf '%s %s\n' "$$" "$PS" > "$LOCK/owner"
[ -f "$LOG" ] && mv -f "$LOG" "$LOG.1"
log "start pid=$$ script=$0"

# ---- boot gate -------------------------------------------------------------
gate_end=$(( $(uptime_s) + 240 ))
# This system never sets sys.boot_completed; the camera's own readiness is system_state Active.
until [ "$(getprop init.svc.camera-service)" = running ] && [ -S /tmp/wayland-0 ] && [ -f "$ROOT/gui/main.qml" ] &&
      timeout 4 odindb-send -s system -p system_state 2>/dev/null | grep -q 'E_SystemState_Active(1)'; do
    [ "$(uptime_s)" -lt "$gate_end" ] || { log "boot_gate_timeout"; exit 3; }
    sleep 1
done
for f in "$GUI:$GUI_SHA" "$LOADER:$LOADER_SHA"; do
    verify "${f%%:*}" "${f#*:}" || { log "hash_mismatch ${f%%:*}"; exit 4; }
done
[ -f "$SESSION" ] || { log "session_missing"; exit 4; }
log "boot_ready"

# ---- overlay GUI -----------------------------------------------------------
has_overlay_env() { tr '\0' '\n' < "/proc/$1/environ" 2>/dev/null | grep -qx 'X2V_GUI_ENABLE=1'; }
overlay_pid() {
    for p in $(pidof camera-gui 2>/dev/null); do has_overlay_env "$p" && { echo "$p"; return 0; }; done
    return 1
}
stock_pids() { for p in $(pidof camera-gui 2>/dev/null); do has_overlay_env "$p" || echo "$p"; done; }
stop_stock_gui() {
    setprop ctl.stop camera-gui
    n=0; while [ "$(getprop init.svc.camera-gui)" != stopped ] && [ "$n" -lt 40 ]; do n=$((n+1)); sleep 0.1; done
    for p in $(stock_pids); do kill -TERM "$p" 2>/dev/null; done
    n=0; while [ -n "$(stock_pids)" ] && [ "$n" -lt 30 ]; do n=$((n+1)); sleep 0.1; done
    for p in $(stock_pids); do kill -KILL "$p" 2>/dev/null; done
}
GUI_STARTS=""; GUI_T0=0; GUI_OK=0; OV=""
start_overlay() {
    (
        export X2V_GUI_ENABLE=1 X2V_GUI_SESSION_ID=x2v-product LD_PRELOAD=$LOADER
        export QML_XHR_ALLOW_FILE_READ=1 QML_XHR_ALLOW_FILE_WRITE=1
        export XDG_RUNTIME_DIR=/tmp XDG_CACHE_HOME=/data QT_QPA_FONTDIR=/system/lib64/qt/lib/fonts
        exec "$GUI" -platform wayland-egl --fullscreen
    ) >> "$PROD/gui.log" 2>&1 &
    pstart $!; OV="$! $PS"
    log "overlay_start pid=$!"
    now; GUI_T0=$NOW; GUI_OK=0
    GUI_STARTS="$GUI_STARTS $GUI_T0"
}
# Three overlay deaths inside two minutes: give the camera back to the stock GUI.
overlay_unstable() {
    now; keep=""; n=0
    for t in $GUI_STARTS; do [ $((NOW - t)) -lt 120 ] && { keep="$keep $t"; n=$((n+1)); }; done
    GUI_STARTS=$keep
    [ "$n" -ge 3 ]
}
ensure_gui() {
    [ "$(getprop init.svc.camera-gui)" = running ] && stop_stock_gui
    if ! alive "${OV% *}" "${OV#* }"; then
        OV=""
        p=$(overlay_pid) && { pstart "$p"; OV="$p $PS"; }
    fi
    if [ -n "$OV" ]; then
        # The overlay says hello over the command channel once its QML is up; a
        # live process that never does is a blank screen, not a working camera.
        now; [ "$GUI_OK" = 1 ] || [ $((NOW - GUI_T0)) -lt 30 ] && return 0
        log "overlay_silent pid=${OV% *}"; kill -KILL "${OV% *}"; OV=""
    fi
    if overlay_unstable; then
        log "overlay_unstable fallback_to_stock"
        touch "$PROD/gui_failed"
        return 1
    fi
    start_overlay
}
PLAY_ID=""
ensure_play() {
    [ -x "$PLAY" ] || return 0
    alive "${PLAY_ID% *}" "${PLAY_ID#* }" && return 0
    "$PLAY" --listen 127.0.0.1:18763 --dir "$PLAYDIR" >> "$PROD/play.log" 2>&1 &
    pstart $!; PLAY_ID="$! $PS"
}

# ---- session jobs ----------------------------------------------------------
# S_SES: up|down (anything but up, including an enter that died mid-way, is down).
# STL: the receiver's one-line status.json, only read while the session is up.
load() {
    S_SES=down; STL=""
    [ -f "$LIVE/session" ] && read v < "$LIVE/session" && [ "$v" = up ] && S_SES=up
    [ "$S_SES" = up ] && [ -f "$LIVE/status.json" ] && IFS= read -r STL < "$LIVE/status.json"
    ACTIVE_FPS=24
    [ -f "$LIVE/fps" ] && read ACTIVE_FPS < "$LIVE/fps"
    sf state; S_ST=$SF
}
# SF = value of a top-level status.json field ("seconds" never matches "last_seconds").
sf() { SF=""; v=${STL#*\"$1\":}; [ "$v" = "$STL" ] && return; v=${v#\"}; SF=${v%%[\",\}]*}; }
JOB=""; JOB_KIND=""; DETAIL=""; LAST=""; PENDING_STOP=0; SHUTDOWN=0; WOKE=0; ENTER_FAILS=0; ENTER_AT=0; PROMPT_WAIT=0
# DNG fills the drive at about 420 MB/s. A clip stops itself while there is still room to
# finish it (a ProRes RAW clip cut short by a full drive has no index and does not play),
# and none starts without room for some seconds more.
FREE_STOP_MB=4096; FREE_START_MB=8192
# product/storage_mb "<stop> <start>" overrides both, read at each start.
storage_limits() {
    FREE_STOP_MB=4096; FREE_START_MB=8192
    SA=""; SB=""
    [ -f "$PROD/storage_mb" ] && read SA SB < "$PROD/storage_mb"
    [ -n "$SA" ] && [ -n "$SB" ] || return 0
    case "$SA$SB" in *[!0-9]*) return 0;; esac
    FREE_STOP_MB=$SA; FREE_START_MB=$SB
}
FREE_MB=""; FREE_T=0; STOP_NOTE=""
# FREE_MB = free MB on the clip drive, empty without one; sh arithmetic here is 32-bit.
free_mb() {
    now; [ "${1:-}" = now ] || [ $((NOW - FREE_T)) -ge 1 ] || return 0; FREE_T=$NOW
    FREE_MB=""
    set -- $(stat -f -c '%a %S' "$CLIPS" 2>/dev/null)
    [ "$#" = 2 ] && [ "$2" -gt 0 ] && [ "$2" -le 1048576 ] && FREE_MB=$(( $1 / (1048576 / $2) ))
}
# odindb-send is a whole Qt process: seconds to start while a clip records. Each runs beside the
# main loop, whose published clock the GUI takes for this script being alive (3 s, then
# "录制状态失联"). BG_PID / BG_PS: a child started by bg; reap_bg waits for it once it is done.
bg() { "$@" & pstart $!; BG_PID=$!; BG_PS=$PS; }
# Returns 1 while the child runs; otherwise reaps it and sets BG_RC.
reap_bg() {
    BG_RC=""
    [ -n "${1:-}" ] || return 0
    alive "$1" "${2:-}" && return 1
    wait "$1" 2>/dev/null; BG_RC=$?
}
# One wake-lock call at a time, so a release can never overtake the acquire before it.
WAKE_WANT=0; WAKE_JOB=""; WAKE_M=""
wake() { WAKE_WANT=$1; wake_step; }
wake_step() {
    reap_bg ${WAKE_JOB:-} || return 0
    [ -n "$WAKE_JOB" ] && log "wake $WAKE_M rc=$BG_RC"; WAKE_JOB=""
    [ "$WAKE_WANT" = "$WOKE" ] && return 0
    if [ "$WAKE_WANT" = 1 ]; then WAKE_M=acquire_wake_lock; else WAKE_M=release_wake_lock; fi
    bg timeout 4 odindb-send -s system -m "$WAKE_M" -- "$WAKE" >/dev/null 2>&1
    WAKE_JOB="$BG_PID $BG_PS"; WOKE=$WAKE_WANT
}
DESIRED=photo
[ -f "$PROD/mode" ] && read DESIRED < "$PROD/mode"
case "$DESIRED" in video|photo) ;; *) DESIRED=photo;; esac
set_desired() {
    [ "$1" = "$DESIRED" ] && return 0
    DESIRED=$1; echo "$1" > "$PROD/mode.tmp" && mv -f "$PROD/mode.tmp" "$PROD/mode"
}
# Per-clip limit is enforced here, independent of GUI lifetime and frame count.
# 0 is an explicit opt-out; missing/corrupt settings always mean five minutes.
valid_duration() {
    case "${1:-}" in ''|*[!0-9]*|0[0-9]*|??????????*) return 1;; esac
    [ "$1" = 0 ] || { [ "$1" -ge 60 ] && [ "$1" -le 1800 ] && [ $(( $1 % 60 )) = 0 ]; }
}
load_duration() {
    DURATION=300
    value=""; [ -f "$PROD/duration_seconds" ] && read value < "$PROD/duration_seconds"
    valid_duration "$value" && DURATION=$value
    return 0
}
set_duration() {
    valid_duration "$1" || return 1
    printf '%s\n' "$1" > "$PROD/duration_seconds.tmp" &&
        mv -f "$PROD/duration_seconds.tmp" "$PROD/duration_seconds" || return 1
    DURATION=$1
}
load_duration
CLIP_LIMIT=$DURATION
watch_duration() {
    [ "$S_SES" = up ] && [ "$S_ST" = recording ] && [ -z "$JOB" ] && [ "$CLIP_LIMIT" -gt 0 ] || return 0
    sf seconds; elapsed=${SF%%.*}
    case "$elapsed" in ''|*[!0-9]*) return 0;; esac
    [ "$elapsed" -ge "$CLIP_LIMIT" ] || return 0
    log "duration_limit seconds=$elapsed limit=$CLIP_LIMIT"
    STOP_NOTE="已达到录制时长，视频已停止并保存"; start_job stop
}
CODEC=prores_raw
[ -f "$PROD/codec" ] && read CODEC < "$PROD/codec"
case "$CODEC" in prores_raw|h264|dng) ;; *) CODEC=prores_raw;; esac
FPS=24
profile_decode() {
    case "$1" in
        raw_3920_2946_24) CODEC=prores_raw; FPS=24;;
        raw_3920_2946_25) CODEC=prores_raw; FPS=25;;
        raw_3920_2946_30) CODEC=prores_raw; FPS=30;;
        dng_3888_2912_24) CODEC=dng; FPS=24;;
        h264_1300_970_24) CODEC=h264; FPS=24;;
        *) return 1;;
    esac
    PROFILE=$1
}
case "$CODEC" in h264) PROFILE=h264_1300_970_24;; dng) PROFILE=dng_3888_2912_24;; *) PROFILE=raw_3920_2946_24;; esac
saved_profile=""; [ -f "$PROD/profile" ] && read saved_profile < "$PROD/profile"
profile_decode "$saved_profile" || profile_decode "$PROFILE"
choose_profile() {
    profile_decode "$1" || return 1
    printf '%s\n' "$PROFILE" > "$PROD/profile.tmp" && mv -f "$PROD/profile.tmp" "$PROD/profile" || return 1
    printf '%s\n' "$CODEC" > "$PROD/codec.tmp" && mv -f "$PROD/codec.tmp" "$PROD/codec"
    LAST=""; DETAIL=""; ENTER_FAILS=0; ENTER_AT=0
    log "profile $PROFILE fps=$FPS"
}
set_codec() {
    case "$1" in
        prores_raw) choose_profile raw_3920_2946_24;;
        dng) choose_profile dng_3888_2912_24;;
        h264) choose_profile h264_1300_970_24;;
    esac
}
start_job() {
    JOB_KIND=$1
    X2V_FPS=$FPS X2V_GUI_MODE=overlay sh "$SESSION" "$1" ${2:-} > "$PROD/job-$1.out" 2>&1 &
    JOB=$!
    log "job_start $1 pid=$JOB"
    # A reboot during enter leaves this marker; the next boot then stays in photo mode.
    [ "$1" = enter ] && { now; echo "$NOW" > "$PROD/entering"; }
}
job_done() {
    wait "$JOB"; rc=$?
    log "job_end $JOB_KIND rc=$rc out=$(tr '\n' ' ' < "$PROD/job-$JOB_KIND.out" | cut -c1-200)"
    case "$JOB_KIND" in
        enter)
            rm -f "$PROD/entering"
            if [ "$rc" = 0 ]; then
                DETAIL=""; LAST=""; ENTER_FAILS=0; PROMPT_WAIT=0
            elif [ "$rc" = 11 ]; then
                # Not a failure: the prompt waits for an answer, and the enter after it is quick.
                now; ENTER_AT=$((NOW + 3)); PROMPT_WAIT=1
                DETAIL="请先处理屏幕上的「USB已连接」提示，随后自动进入视频模式"
            elif [ "$ENTER_FAILS" = 0 ]; then
                # The camera can still be settling right after boot: one more try.
                ENTER_FAILS=1; now; ENTER_AT=$((NOW + 5)); log "enter_retry rc=$rc"
            else
                ENTER_FAILS=0; set_desired photo
                # 10: an on-screen prompt (USB connected, …) still waits for an answer.
                if [ "$rc" = 10 ]; then DETAIL="请先处理屏幕上的提示，再进入视频模式"; else DETAIL="视频模式启动失败（$rc）"; fi
            fi;;
        rec) if [ "$rc" = 0 ]; then DETAIL=""; wake 1; else DETAIL="录制未启动（$rc）"; PENDING_STOP=0; fi;;
        stop)
            wake 0
            if [ "$rc" = 0 ]; then
                LAST=saved; DETAIL=$STOP_NOTE
                c=$(tail -n 1 "$PROD/job-stop.out")
                [ -d "$c" ] && cp "$LIVE/preview.ppm" "$c/thumb.ppm" 2>/dev/null
                catalog_add "${c##*/}"
            else
                LAST=error; DETAIL="保存失败（$rc）"
            fi
            STOP_NOTE="";;
        exit|shutdown) wake 0;;
    esac
    JOB=""; JOB_KIND=""
}
command_in() {
    [ -f "$RUN/gui.cmd" ] || return 0
    read id cmd < "$RUN/gui.cmd" || return 0
    [ -n "${id:-}" ] && [ "$id" != "$CMD_ID" ] || return 0
    CMD_ID=$id
    log "cmd $id $cmd session=$S_SES state=$S_ST job=$JOB_KIND"
    [ "$SHUTDOWN" = 1 ] && [ "$cmd" != hello ] && return 0
    case "$cmd" in
        hello) GUI_OK=1;;
        video_on) set_desired video; DETAIL=""; ENTER_FAILS=0; ENTER_AT=0;;
        video_off) set_desired photo; PROMPT_WAIT=0;;
        # The stock GUI parks on its control screen when the service reports live view off, as
        # it does after the "USB connected" prompt; with group13 streaming the guard absorbs this.
        live_view_on) [ "$S_SES" = up ] && [ -z "$JOB" ] && [ -z "$LV_JOB" ] && {
            bg timeout 8 odindb-send -s camera -m set_live_view true >/dev/null 2>&1; LV_JOB="$BG_PID $BG_PS"; };;
        start) [ "$ACTIVE_FPS" = "$FPS" ] && [ "$DESIRED" = video ] && [ -z "$JOB" ] && [ "$S_SES" = up ] &&
               case "$S_ST" in
                   idle|error)
                       storage_limits; free_mb now
                       if [ -n "$FREE_MB" ] && [ "$FREE_MB" -lt "$FREE_START_MB" ]; then
                           log "start_refused free_mb=$FREE_MB"; LAST=""; DETAIL="存储空间不足，无法开始录制"
                       elif ! thermal_ready; then LAST=""; DETAIL="温度状态未就绪或过高，暂不能录像"
                       else LAST=""; DETAIL=""; CLIP_LIMIT=$DURATION; start_job rec "$CODEC"; fi;;
               esac;;
        duration_*)
               [ -z "$JOB" ] && [ "$S_ST" != recording ] && [ "$S_ST" != finalizing ] && set_duration "${cmd#duration_}";;
        profile_*)
               [ -z "$JOB" ] && [ "$S_ST" != recording ] && [ "$S_ST" != finalizing ] && choose_profile "${cmd#profile_}";;
        codec_prores_raw|codec_h264|codec_dng)
               # The codec of a clip is fixed when it starts; switching waits for it to end.
               [ -z "$JOB" ] && [ "$S_ST" != recording ] && [ "$S_ST" != finalizing ] && set_codec "${cmd#codec_}";;
        stop) if [ "$JOB_KIND" = rec ]; then PENDING_STOP=1
              elif [ -z "$JOB" ] && [ "$S_ST" = recording ]; then start_job stop; fi;;
    esac
}
# Power-off and reboot wait in PrepareShutdown for wake locks and for the stock camera
# service: save the clip being recorded, then hand the camera back. The chosen mode
# stays, so the next boot comes back to it.
# Photo mode holds neither and needs no watching; odindb-send is a whole Qt process.
SYS_T=0; SYS_JOB=""
TEMP_STATUS=unknown; TEMP_AT=0; THERMAL_TRIPPED=0
thermal_ready() {
    now
    [ "$TEMP_AT" -gt 0 ] && [ $((NOW - TEMP_AT)) -le 10 ] &&
        { [ "$TEMP_STATUS" = low ] || [ "$TEMP_STATUS" = moderate ]; }
}
watch_thermal() {
    [ "$S_SES" = up ] || return 0
    now
    why=""
    case "$TEMP_STATUS" in high|critical) why=hot;; esac
    if [ "$S_ST" = recording ] && ! thermal_ready; then why=${why:-unavailable}; fi
    [ -n "$why" ] || { THERMAL_TRIPPED=0; return 0; }
    if [ "$THERMAL_TRIPPED" = 0 ]; then
        log "thermal_stop reason=$why status=$TEMP_STATUS"
        THERMAL_TRIPPED=1
        if [ "$why" = hot ]; then DETAIL="机身温度过高，已停止录像并退出视频模式"
        else DETAIL="温度监测失联，已停止录像并退出视频模式"; fi
        # Do not automatically resume a hot video graph when it cools down.
        set_desired photo
    fi
    if [ "$S_ST" = recording ] && [ -z "$JOB" ]; then STOP_NOTE=$DETAIL; start_job stop; fi
}

watch_system() {
    reap_bg ${SYS_JOB:-} || return 0
    if [ -n "$SYS_JOB" ]; then
        SYS_JOB=""
        now
        [ -f "$RUN/temperature" ] && {
            read t < "$RUN/temperature"
            case "$t" in
                'temperature_status = E_TemperatureStatus_Low(1)') TEMP_STATUS=low; TEMP_AT=$NOW;;
                'temperature_status = E_TemperatureStatus_Moderate(2)') TEMP_STATUS=moderate; TEMP_AT=$NOW;;
                'temperature_status = E_TemperatureStatus_High(3)') TEMP_STATUS=high; TEMP_AT=$NOW;;
                'temperature_status = E_TemperatureStatus_Critical(4)') TEMP_STATUS=critical; TEMP_AT=$NOW;;
                *) TEMP_STATUS=unknown;;
            esac
        }
        # A redirection that fails on a compound command ends a non-interactive shell.
        [ -f "$RUN/system_state" ] && while IFS= read -r l; do
            case "$l" in
                *'PrepareShutdown(6)'*|*'Shutdown(4)'*) [ "$SHUTDOWN" = 1 ] || { SHUTDOWN=1; log "system_shutdown"; };;
            esac
        done < "$RUN/system_state"
    fi
    [ "$S_SES" = up ] || [ "$WOKE" = 1 ] || return 0
    now; [ $((NOW - SYS_T)) -ge 2 ] || return 0; SYS_T=$NOW
    bg sh -c 'timeout 3 odindb-send -s system -p temperature_status > "$2" 2>/dev/null; timeout 3 odindb-send -s system -p system_state > "$1" 2>/dev/null' x2v "$RUN/system_state" "$RUN/temperature"
    SYS_JOB="$BG_PID $BG_PS"
}
# The receiver's preview counter advances ~12 times a second while group13 streams.
# A dead owned service or a stalled counter is a lost session: save, hand the camera
# back, and re-enter once; a second loss within five minutes stays in photo mode.
GEN_V=""; GEN_T=0; LOSSES=""; PENDING_EXIT=0
watch_session() {
    [ "$S_SES" = up ] && [ -z "$JOB" ] && [ "$SHUTDOWN" = 0 ] && [ "$PENDING_EXIT" = 0 ] || { GEN_V=""; return 0; }
    now
    p=""; [ -f "$LIVE/service.pid" ] && read p < "$LIVE/service.pid"
    if [ -z "$p" ] || [ ! -d "/proc/$p" ]; then session_lost "service_died pid=$p"; return 0; fi
    sf preview_gen
    if [ "$SF" != "$GEN_V" ]; then GEN_V=$SF; GEN_T=$NOW; return 0; fi
    [ $((NOW - GEN_T)) -ge 6 ] && session_lost "preview_stall gen=$GEN_V"
}
watch_storage() {
    [ "$S_SES" = up ] && [ "$S_ST" = recording ] && [ -z "$JOB" ] || return 0
    free_mb
    [ -n "$FREE_MB" ] && [ "$FREE_MB" -lt "$FREE_STOP_MB" ] || return 0
    log "storage_full free_mb=$FREE_MB"
    STOP_NOTE="存储空间将满，录制已停止并保存"; start_job stop
}
session_lost() {
    log "session_lost $1 state=$S_ST"
    GEN_V=""; now; keep=""; n=0
    for t in $LOSSES; do [ $((NOW - t)) -lt 300 ] && { keep="$keep $t"; n=$((n+1)); }; done
    LOSSES="$keep $NOW"
    if [ "$n" -ge 1 ]; then set_desired photo; DETAIL="视频取景中断，已回到拍照"; else DETAIL="视频取景中断，正在恢复"; fi
    case "$1:$S_ST" in
        service_died*) start_job exit;;
        *:recording) PENDING_EXIT=1; start_job stop;;
        *) start_job exit;;
    esac
}
converge() {
    [ -z "$JOB" ] || return 0
    if [ "$PENDING_EXIT" = 1 ]; then PENDING_EXIT=0; start_job exit; return 0; fi
    s=$S_SES; st=$S_ST
    if [ "$SHUTDOWN" = 1 ]; then
        if [ "$s" = up ] && [ "$st" = recording ]; then start_job stop
        elif [ "$s" = up ]; then start_job shutdown
        else wake 0; fi
        return 0
    fi
    if [ "$PENDING_STOP" = 1 ]; then
        PENDING_STOP=0; [ "$st" = recording ] && { start_job stop; return 0; }
    fi
    case "$DESIRED:$s" in
        video:up) [ "$ACTIVE_FPS" = "$FPS" ] || { [ "$st" = idle -o "$st" = error ] && start_job exit; };;
        video:down) now; [ "$NOW" -ge "$ENTER_AT" ] && start_job enter;;
        photo:up) if [ "$st" = recording ]; then start_job stop; else start_job exit; fi;;
    esac
}

# ---- published state -------------------------------------------------------
PUB=""
publish() {
    s=$S_SES; st=$S_ST; ready=false
    case "$JOB_KIND" in
        enter) phase=entering;; exit|shutdown) phase=exiting;; rec) phase=starting;; stop) phase=finalizing;;
        *) case "$s:$st" in
               up:recording) phase=recording;;
               up:finalizing) phase=finalizing;;
               up:error) phase=error;;
               up:*) phase=${LAST:-idle};;
               *) phase=${LAST:-idle}; [ -n "$DETAIL" ] && phase=error;;
           esac
           [ "$phase" = saved ] && [ "$SAVE_WAIT" = 1 ] && phase=finalizing
           # Between the enters that find the USB prompt up: still entering, with its notice.
           [ "$PROMPT_WAIT" = 1 ] && [ "$DESIRED" = video ] && [ "$s" != up ] && phase=entering;;
    esac
    [ "$s" = up ] && [ "$ACTIVE_FPS" = "$FPS" ] && [ -z "$JOB_KIND" -o "$JOB_KIND" = rec -o "$JOB_KIND" = stop ] && ready=true
    [ "$DESIRED" = video ] && [ "$ACTIVE_FPS" != "$FPS" ] && [ "$JOB_KIND" != exit ] && phase=entering
    secs=0; gen=0; frames=0
    # status.json outlives the session in tmpfs; its numbers only mean something while it is up.
    [ "$s" = up ] && { sf seconds; secs=$SF; sf preview_gen; gen=$SF; sf written; frames=$SF; }
    now
    # DETAIL is always one of our own messages: nothing in it needs JSON escaping.
    p='{"schema":1,"backend_ready":'$ready',"profile_id":"'$PROFILE'","codec":"'$CODEC'","phase":"'$phase'","detail":"'$DETAIL'","fresh":true,"uptime":'$NOW',"mode":"'$DESIRED'","session":"'$s'","seconds":'${secs:-0}',"frames":'${frames:-0}',"preview_gen":'${gen:-0}',"duration_limit_seconds":'$DURATION',"temperature_status":"'$TEMP_STATUS'","supervisor_pid":'$$'}'
    [ "$p" = "$PUB" ] && return 0
    # One small write into tmpfs; a reader that catches it half-written just skips that poll.
    printf '%s\n' "$p" > "$RUN/state.json"; PUB=$p
}
# The owned camera-service writes ~30 KB/s (timing-monitor warnings for pipeline stages
# group 13 never runs) and the overlay GUI a line a second; both append, so a trim is safe.
trim_log() {
    s=$(stat -c %s "$1" 2>/dev/null) || return 0
    [ "${s:-0}" -gt "$2" ] || return 0
    tail -c $(( $2 / 8 )) "$1" > "$1.prev" 2>/dev/null; : > "$1"
    log "log_trimmed $1 $s"
}

# A few forks per clip: run beside the main loop. One more is queued when asked mid-way.
CAT_JOB=""; CAT_AGAIN=0; CAT_SSD=0; CAT_CS=0; CAT_N=0
# A saved clip shows as saved once the gallery can list it: until then it is still finalizing.
SAVE_WAIT=0
LV_JOB=""
lv_step() { reap_bg ${LV_JOB:-} || return 0; [ -n "$LV_JOB" ] && log "live_view_on rc=$BG_RC"; LV_JOB=""; }
catalog() {
    if [ -d "$CLIPS" ]; then CAT_SSD=1; else CAT_SSD=0; fi
    if [ -n "$CAT_JOB" ]; then CAT_AGAIN=1; return 0; fi
    cs; CAT_CS=$CS; CAT_N=$((CAT_N + 1))
    bg write_catalog "$CAT_N"; CAT_JOB="$BG_PID $BG_PS"
}
catalog_step() {
    reap_bg ${CAT_JOB:-} || return 0
    [ -n "$CAT_JOB" ] || return 0
    CAT_JOB=""
    cs; log "catalog_done ms=$(( (CS - CAT_CS) * 10 ))"
    if [ "$CAT_AGAIN" = 1 ]; then CAT_AGAIN=0; catalog; else SAVE_WAIT=0; fi
}
# A clip's entry, or "-" for one that never plays, or "" while it has no clip.json yet. No fork
# per clip: at ~60 ms a fork, three per clip made 50 clips an 11 s catalog.
catalog_entry() {
    E=""
    case "$1" in
        X2V_H264_*) m=$CLIPS/$1/clip.mp4; w=1300; h=970; f=H.264;;
        # Plays its H.264 proxy; its size is the frames'.
        X2V_DNG_*) m=$CLIPS/$1/proxy.mp4; w=3888; h=2912; f=CinemaDNG;;
        *) m=$CLIPS/$1/clip.mov; w=3888; h=2912; f="ProRes RAW";;
    esac
    j=$CLIPS/$1/clip.json
    [ -f "$j" ] && IFS= read -r cj < "$j" || return 0
    E=-
    case "$cj" in *'"error":0'*) ;; *) return 0;; esac
    v=${cj#*\"duration\":}; [ "$v" != "$cj" ] || return 0; dur=${v%%[,\}]*}
    v=${cj#*\"bytes\":}; [ "$v" != "$cj" ] || return 0; bytes=${v%%[,\}]*}
    [ -n "$dur" ] && [ -n "$bytes" ] && [ -f "$m" ] || return 0
    th=""; [ -f "$CLIPS/$1/thumb.ppm" ] && th=$CLIPS/$1/thumb.ppm
    E='{"id":"'$1'","state":"saved","finalized":true,"source":"'$m'","thumbnail":"'$th'","title":"'$1'","duration":'$dur',"bytes":'$bytes',"width":'$w',"height":'$h',"format":"'$f'"}'
}
# A clip just saved goes in front of the catalog as it is, in the loop: a whole rebuild lists the
# drive while the clip's last writes still hold it, about 2 s. A rebuild already running may not
# have seen the clip's clip.json, so it runs once more.
CAT_HEAD='{"schemaVersion":1,"clips":['
catalog_add() {
    catalog_entry "$1"
    case "$E" in ''|-) return 0;; esac
    mkdir -p "$RUN/cat"; printf '%s\n' "$E" > "$RUN/cat/$1"
    [ -n "$CAT_JOB" ] && { CAT_AGAIN=1; SAVE_WAIT=1; }
    cur=""; [ -f "$REC/catalog.json" ] && IFS= read -r cur < "$REC/catalog.json"
    case "$cur" in
        *"\"id\":\"$1\""*) return 0;;
        "$CAT_HEAD]}") new="$CAT_HEAD$E]}";;
        "$CAT_HEAD"*) new="$CAT_HEAD$E,${cur#"$CAT_HEAD"}";;
        *) SAVE_WAIT=1; catalog; return 0;;
    esac
    # Its own temporary name: a rebuild may be writing catalog.json.tmp in the background.
    printf '%s\n' "$new" > "$REC/catalog.json.add" && mv -f "$REC/catalog.json.add" "$REC/catalog.json"
}
write_catalog() {
    mkdir -p "$RUN/cat"
    {
        printf '{"schemaVersion":1,"clips":['
        sep=""
        # Newest first across codecs: order by the timestamp after the codec prefix.
        for d in $(ls "$CLIPS" 2>/dev/null | grep -E '^X2V_(PRR|H264|DNG)_' | sed 's/^X2V_[A-Z0-9]*_\(.*\)$/\1 &/' | sort -r | cut -d' ' -f2); do
            # Each entry once a boot, in tmpfs: a DNG clip's directory holds ~1400 files, which
            # exFAT reads through for every name it looks up, three a clip.
            ce=$RUN/cat/$d
            if [ -f "$ce" ]; then
                IFS= read -r E < "$ce" || E=""
            else
                catalog_entry "$d"
                [ -n "$E" ] && printf '%s\n' "$E" > "$ce"
            fi
            [ -n "$E" ] && [ "$E" != - ] || continue
            printf '%s%s' "$sep" "$E"
            sep=","
        done
        printf ']}\n'
    } > "$REC/catalog.json.tmp$1" && mv -f "$REC/catalog.json.tmp$1" "$REC/catalog.json"
}

# ---- main ------------------------------------------------------------------
if [ -f "$PROD/entering" ]; then log "interrupted_enter -> photo"; set_desired photo; rm -f "$PROD/entering"; fi
CMD_ID=""
rm -f "$RUN/gui.cmd"
catalog
load; publish
for s in HUP INT QUIT PIPE TERM; do trap "log sig_$s; exit 9" $s; done
CHECK_T=0
TRIM_T=0
while [ ! -f "$PROD/disable" ]; do
    cs; LOOP_CS=$CS
    now
    if [ $((NOW - TRIM_T)) -ge 30 ]; then
        TRIM_T=$NOW
        trim_log "$ROOT/video/service.log" 16000000
        trim_log "$PROD/gui.log" 4000000
    fi
    if [ $((NOW - CHECK_T)) -ge 2 ]; then
        CHECK_T=$NOW
        if ! ensure_gui; then
            [ -f "$LIVE/session" ] && { log "fallback exit"; X2V_FPS=$FPS X2V_GUI_MODE=overlay sh "$SESSION" exit > "$PROD/job-exit.out" 2>&1; }
            setprop ctl.start camera-gui
            log "stock_gui_restored"
            exit 5
        fi
        ensure_play
        # The SSD mounts a few seconds after this starts, and leaves with USB storage.
        if [ -d "$CLIPS" ]; then c_ssd=1; else c_ssd=0; fi
        [ "$c_ssd" = "$CAT_SSD" ] || { log "catalog ssd=$c_ssd"; catalog; }
    fi
    # A finished job stays in /proc as a zombie until waited for.
    [ -n "$JOB" ] && ! pstart "$JOB" && job_done
    load
    watch_system
    watch_thermal
    watch_session
    watch_duration
    watch_storage
    command_in
    converge
    wake_step
    catalog_step
    lv_step
    publish
    cs; [ $((CS - LOOP_CS)) -lt 150 ] || log "loop_slow ms=$(( (CS - LOOP_CS) * 10 )) job=$JOB_KIND"
    sleep 0.2
done
log "disabled"
