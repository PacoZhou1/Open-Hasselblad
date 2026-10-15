#!/system/bin/sh
# Resident video session (camera domain). enter: owned camera-service + group13 +
# resident receiver. rec/stop: clip commands. exit: restore stock service and GUI.
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
set -u
LIVE=/tmp/x2v-live
HOME_DIR=/blackbox/x2v-native-20261011/video
# X2V_LIB/X2V_LIB_SHA: development override only; the supervisor never sets them.
LIB=${X2V_LIB:-/system/lib64/libx2v_preview_aligned_20261015b.so}
LIB_SHA=${X2V_LIB_SHA:-782d559481ea0b9703a75eb850cf88548eb4ca17044d95691ea6a46886bb57a6}
ETC=${X2V_ETC:-/system/etc/x2v}
SP=$ETC/imx861bqr_hb722.sp
SP_SHA=594f651e83a6d916e9af64ac96c718038c511c3a419028690982b079a6e729e4
# ISP view: the colour stream goes to the display plane (wl-disp, six buffers: with three the
# plane's hold halved the stream to 12 fps), as the stock liveview does: the ISP's own picture at
# the sensor's rate, none of it drawn by this side. $HOME_DIR/raw_view keeps the viewfinder the
# resident renders from the RAW stream instead.
if [ -f "$HOME_DIR/raw_view" ]; then
    VIEW=raw
    CONF=$ETC/imx861bqr_hb722.conf
    CONF_SHA=5558a0fc6a5864c4711a3f0d0fba5b66d775822d6522b599724a9921d0fca3aa
else
    VIEW=isp
    CONF=$ETC/imx861bqr_hb722_view_20261014zg.conf
    CONF_SHA=31c0c21f207c9ac840edc7834767d8670a22832bf3e64b7fb16518a7374a4363
fi
SERVICE=/system/bin/camera-service
CLIPS=/mnt/media_rw/ssd/X2V_RAW
# stop: stop camera-gui for the session; keep: leave it alone; overlay: a supervisor owns camera-gui.
GUI_MODE=${X2V_GUI_MODE:-stop}
LOG=$HOME_DIR/session.log
BUSY=setup_dcam_stream_group_active,start_dcam_stream_active,stop_dcam_stream_active,teardown_current_dcam_stream_group_active,set_live_view_active
G_NORMAL='E_StreamGroup_(Still16bit\(0\)|Max\(255\))'
G13='E_StreamGroup_LiveviewRawCalib(13)'

uptime_s() { read up rest < /proc/uptime; printf '%s\n' "${up%%.*}"; }
log() { read up rest < /proc/uptime; printf '%s %s\n' "$up" "$*" >> "$LOG"; }
field() { timeout 3 odindb-send -s camera -p "$1" 2>/dev/null | sed -n "s/^$1 = //p"; }
# "none" or "<code>/<action>"; action 0 is Critical, which only a reboot clears.
err() {
    e=$(timeout 3 odindb-send -s error -p active_error,current_error 2>/dev/null)
    printf '%s\n' "$e" | grep -qx 'active_error = false' && { echo none; return; }
    printf '%s\n' "$e" | sed -n 's/^current_error = .*ACTION = \([0-9]*\).*CODE = \([0-9]*\).*/\2\/\1/p'
}
critical() { case "$(err)" in */0|'') return 0;; esac; return 1; }
wait_no_error() {
    wait_no_error_end=$(( $(uptime_s) + $1 ))
    while [ "$(err)" != none ]; do
        [ "$(uptime_s)" -lt "$wait_no_error_end" ] || return 1
        sleep 0.5
    done
}
op() {
    log "op $*"
    timeout 8 odindb-send -s camera -m "$@" >> "$LOG" 2>&1 || { log "op_fail $* err=$(err)"; return 1; }
    log "op_ok $* err=$(err)"
}
IDLE=do_exposure_active,do_exposure_extended_active,do_exposure_extended2_active,find_focus_active,zoom_active
STATE=live_view_state,liveview_transport_mode_current,stream_group,crop_mode_current
# odindb keeps answering field queries after its service dies, so a reply only
# counts while a camera-service process is actually alive.
service_up() { [ -n "$(pidof camera-service 2>/dev/null)" ]; }
# All waits are bounded by wall time, not iteration count: a dead service makes each query slow.
wait_idle() {
    wait_idle_end=$(( $(uptime_s) + ${1:-20} ))
    while :; do
        r=$(timeout 3 odindb-send -s camera -p "$BUSY,$IDLE,exposures_processing_counter" 2>/dev/null)
        c=$(printf '%s\n' "$r" | grep -c ' = false$')
        service_up && [ "$c" = 10 ] && printf '%s\n' "$r" | grep -qx 'exposures_processing_counter = 0' && return 0
        [ "$(uptime_s)" -lt "$wait_idle_end" ] || { log "busy_timeout $(printf '%s' "$r" | grep -v ' = false$' | tr '\n' ' ')"; return 1; }
        sleep 0.1
    done
}
# Same gate as the proven controller's normal_state.
wait_normal() {
    wait_normal_end=$(( $(uptime_s) + $1 ))
    while :; do
        r=$(timeout 3 odindb-send -s camera -p "$STATE" 2>/dev/null)
        service_up &&
        printf '%s\n' "$r" | grep -qx 'liveview_transport_mode_current = E_LiveviewTransportMode_None(0)' &&
        printf '%s\n' "$r" | grep -qx 'crop_mode_current = E_CropMode_None(0)' &&
        printf '%s\n' "$r" | grep -Eqx "stream_group = $G_NORMAL" && return 0
        [ "$(uptime_s)" -lt "$wait_normal_end" ] || { log "normal_timeout $(printf '%s' "$r" | tr '\n' ' ')"; return 1; }
        sleep 0.2
    done
}
# A rejected set_live_view changes nothing, so retrying while the service settles is safe.
# It also answers "Ignoring set live view" while an error holds its state machine (see enter).
live_view() {
    live_view_end=$(( $(uptime_s) + 15 ))
    while :; do
        r=$(timeout 8 odindb-send -s camera -m set_live_view "$1" 2>&1); rc=$?
        log "op set_live_view $1 rc=$rc err=$(err) $(printf '%s' "$r" | tr '\n' ' ')"
        [ "$rc" = 0 ] && return 0
        printf '%s\n' "$r" | grep -Eq 'Invalid system state|Ignoring set live view' &&
            [ "$(uptime_s)" -lt "$live_view_end" ] || return 1
        sleep 0.5; wait_idle 10 || return 1
    done
}
# Early after boot the owned service can answer set_live_view Ok and still never build
# the still group; asking again once it has settled works, and costs far less than a restore.
live_on() {
    live_view true && wait_idle && wait_field stream_group 'E_StreamGroup_Still16bit\(0\)' 8 && return 0
    # The vendor HAL has crashed the service in this first live view after boot; asking a
    # dead service again only runs out every timeout before the restore that recovers it.
    # crash_dump holds the process for a moment after the bus has dropped it.
    if printf '%s' "$r" | grep -q 'disconnected from message bus'; then
        live_on_end=$(( $(uptime_s) + 5 ))
        while [ -n "$(owned_pid)" ] && [ "$(uptime_s)" -lt "$live_on_end" ]; do sleep 0.1; done
    fi
    [ -n "$(owned_pid)" ] || { log owned_service_died; return 1; }
    # Still ignored after live_view's own retries: the error state dropping it has outlasted
    # another round here every time.
    printf '%s' "$r" | grep -q 'Ignoring set live view' && { log live_view_ignored; return 1; }
    log live_on_retry
    live_view false; wait_idle
    live_view true && wait_idle && wait_field stream_group 'E_StreamGroup_Still16bit\(0\)' 10
}
# $2 is an extended regex matched against the whole value; $3 is seconds.
wait_field() {
    wait_field_end=$(( $(uptime_s) + $3 ))
    while :; do
        v=$(field "$1")
        printf '%s\n' "$v" | grep -Eqx "$2" && return 0
        [ "$(uptime_s)" -lt "$wait_field_end" ] || { log "wait_fail $1 want=$2 got=$v"; return 1; }
        sleep 0.1
    done
}
svc_gone() {
    svc_gone_end=$(( $(uptime_s) + 8 ))
    while [ "$(getprop "init.svc.$1")" != stopped ] || [ -n "$(pidof "$1" 2>/dev/null)" ]; do
        [ "$(uptime_s)" -lt "$svc_gone_end" ] || return 1; sleep 0.1
    done
}
status_field() { sed -n "s/.*\"$1\":\"\{0,1\}\([^,\"}]*\).*/\1/p" "$LIVE/status.json" 2>/dev/null; }
next_seq() { s=$(cat "$LIVE/seq" 2>/dev/null || echo 0); s=$((s+1)); echo "$s" > "$LIVE/seq"; echo "$s"; }
send() {
    s=$(next_seq)
    printf '%s %s\n' "$s" "$1" > "$LIVE/command.tmp" && mv "$LIVE/command.tmp" "$LIVE/command"
    send_end=$(( $(uptime_s) + ${2:-30} ))
    while [ "$(status_field seq_ack)" != "$s" ]; do
        [ "$(uptime_s)" -lt "$send_end" ] || { log "ack_timeout $s $1"; return 1; }
        sleep 0.1
    done
}
verify() { printf '%s  %s\n' "$2" "$1" | sha256sum -c - >/dev/null 2>&1; }
owned_pid() {
    p=$(cat "$LIVE/service.pid" 2>/dev/null || true)
    [ -n "$p" ] && [ -d "/proc/$p" ] && [ "$(readlink "/proc/$p/exe")" = "$SERVICE" ] && echo "$p"
}

# camera-test exits when camera-service goes away and init then kills its whole
# cgroup, so a launcher inside it must first be moved to a cgroup that survives.
escape_cgroup() {
    tc=$(grep cpuacct /proc/$(pidof camera-test)/cgroup 2>/dev/null | cut -d: -f3)
    [ -n "$tc" ] && [ "$(grep cpuacct /proc/$$/cgroup | cut -d: -f3)" = "$tc" ] || return 0
    echo $$ > "$HOME_DIR/session.pid"
    escape_cgroup_end=$(( $(uptime_s) + 15 ))
    while [ "$(grep cpuacct /proc/$$/cgroup | cut -d: -f3)" = "$tc" ]; do
        [ "$(uptime_s)" -lt "$escape_cgroup_end" ] || { log launcher_in_camera_test_cgroup; return 1; }
        sleep 0.1
    done
    log "migrated cgroup=$(grep cpuacct /proc/$$/cgroup | cut -d: -f3)"
}

restore_stock() {
    log restore_begin
    p=$(owned_pid)
    if [ -n "$p" ]; then
        # Stop the RAW graph through the service only while it is actually streaming;
        # stop_dcam_stream with nothing running took the service down.
        if [ "$(field stream_group)" = "$G13" ]; then
            # The receiver refuses group changes until released; if it cannot ack, the kill below still ends it.
            [ "${RELEASED:-0}" = 1 ] || [ ! -f "$LIVE/status.json" ] || send release 3 || true
            op stop_dcam_stream 0 && wait_idle 10
            op stop_dcam_stream 1 && wait_idle 10
            op teardown_current_dcam_stream_group && wait_idle 10
        fi
        kill -TERM "$p"
        restore_stock_end=$(( $(uptime_s) + 6 ))
        while [ -d "/proc/$p" ] && [ "$(uptime_s)" -lt "$restore_stock_end" ]; do sleep 0.1; done
        [ -d "/proc/$p" ] && { log service_kill; kill -KILL "$p"; sleep 0.5; }
    fi
    rm -f "$LIVE/service.pid" "$LIVE/fullpress" "$LIVE/view"
    [ -z "$(pidof camera-service 2>/dev/null)" ] || [ "$(getprop init.svc.camera-service)" = running ] ||
        log "foreign_camera_service $(pidof camera-service)"
    [ "$(getprop init.svc.camera-service)" = running ] || setprop ctl.start camera-service
    wait_normal 40 && wait_idle 20 && live_view true && wait_idle 20
    [ "$GUI_MODE" != stop ] || [ "$(getprop init.svc.camera-gui)" = running ] || setprop ctl.start camera-gui
    echo down > "$LIVE/session"
    log "restore_end group=$(field stream_group) live=$(field live_view_state) gui=$(getprop init.svc.camera-gui)"
}

# Power-off and reboot stay in PrepareShutdown while the owned service runs: only the
# stock one lets them through. Hand the camera back without the live-view round trip.
shutdown_fast() {
    log shutdown_begin
    [ "$(cat "$LIVE/session" 2>/dev/null)" = up ] && send quit 10
    p=$(owned_pid)
    if [ -n "$p" ]; then
        kill -TERM "$p"
        shutdown_end=$(( $(uptime_s) + 4 ))
        while [ -d "/proc/$p" ] && [ "$(uptime_s)" -lt "$shutdown_end" ]; do sleep 0.1; done
        [ -d "/proc/$p" ] && { log service_kill; kill -KILL "$p"; }
    fi
    rm -f "$LIVE/service.pid"
    [ "$(getprop init.svc.camera-service)" = running ] || setprop ctl.start camera-service
    echo down > "$LIVE/session"
    log "shutdown_end svc=$(getprop init.svc.camera-service)"
}

enter() {
    [ "$(cat "$LIVE/session" 2>/dev/null)" = up ] && { echo up; return 0; }
    mkdir -p "$LIVE" "$HOME_DIR" "$CLIPS"
    [ -f "$LOG" ] && mv -f "$LOG" "$LOG.1"
    verify "$SP" "$SP_SHA" && verify "$CONF" "$CONF_SHA" || { log bad_graph_files; return 4; }
    [ -z "$LIB_SHA" ] || verify "$LIB" "$LIB_SHA" || { log bad_lib; return 4; }
    [ "$(getprop init.svc.camera-service)" = running ] || { log stock_not_running; return 4; }
    echo 0 > "$LIVE/seq"; echo "0 none" > "$LIVE/command"
    rm -f "$LIVE/status.json" "$LIVE/preview.ppm" "$LIVE/preview.gen" "$LIVE/shutter" "$LIVE/fullpress"
    # The GUI hides its own viewfinder image over the display plane.
    echo "$VIEW" > "$LIVE/view"
    echo entering > "$LIVE/session"
    critical && { log "enter_refused error=$(err)"; echo down > "$LIVE/session"; return 8; }
    # 40, the "USB connected" prompt: right after boot the owned service ignored every live view
    # request while it waited, and the enter ran out its retries and restored, a minute of work;
    # answered, the enter takes ~15 s. 11 tells the supervisor to ask again shortly.
    case "$(err)" in 40/*) log usb_prompt_pending; echo down > "$LIVE/session"; return 11;; esac
    log "enter gui_mode=$GUI_MODE view=$VIEW cgroup=$(grep cpuacct /proc/$$/cgroup | cut -d: -f3)"
    escape_cgroup || { echo down > "$LIVE/session"; return 7; }
    # An error waiting to be acknowledged holds the camera's state machine in its error state,
    # which drops every set_live_view; answering it on screen clears it.
    wait_no_error 30 || log "error_pending err=$(err)"
    wait_idle
    if [ "$(field live_view_state)" = 'E_LiveViewState_Active(1)' ]; then live_view false; wait_idle; fi
    if [ "$(field stream_group)" = 'E_StreamGroup_Still16bit(0)' ]; then op teardown_current_dcam_stream_group; wait_idle; fi
    if [ "$GUI_MODE" = stop ]; then setprop ctl.stop camera-gui; svc_gone camera-gui; fi
    setprop ctl.stop camera-service
    svc_gone camera-service || { log stock_stop_failed; restore_stock; return 5; }
    log "stock_stopped err=$(err) system=$(timeout 3 odindb-send -s system -p system_state 2>/dev/null)"
    # Appended, so the supervisor can trim it while the service runs.
    [ -f "$HOME_DIR/service.log" ] && mv -f "$HOME_DIR/service.log" "$HOME_DIR/service.log.1"
    (
        export XDG_RUNTIME_DIR=/tmp X2V_SOURCE_ADAPTER=mode21-c-24fps X2V_OWNED_RAW_GRAPH=mode21-c24
        export X2V_RESIDENT=GROUP13_MODE21C24_PRR_RESIDENT_V1
        [ "$VIEW" = isp ] && export X2V_ISP_VIEW=1
        # At least as safe from the low-memory killer as the stock service (-100): started from
        # some other shell it would inherit that shell's score, 200 from camera-test.
        read adj < /proc/self/oom_score_adj
        [ "$adj" -gt -100 ] && echo -100 > /proc/self/oom_score_adj
        # Own session: the service must not share a process group with this script.
        exec setsid sh -c 'LD_PRELOAD=$1 exec "$2"' x2v "$LIB" "$SERVICE" 5<"$SP" 6<"$CONF"
    ) >> "$HOME_DIR/service.log" 2>&1 &
    enter_end=$(( $(uptime_s) + 5 ))
    until p=$(pidof camera-service 2>/dev/null) && [ -n "$p" ]; do
        [ "$(uptime_s)" -lt "$enter_end" ] || { log owned_service_missing; restore_stock; return 6; }
        sleep 0.1
    done
    echo "$p" > "$LIVE/service.pid"
    log "owned_service pid=$p pgid=$(cut -d' ' -f5 /proc/$p/stat) self_pgid=$(cut -d' ' -f5 /proc/$$/stat)"
    ok=1
    wait_normal 40 && wait_idle || ok=0
    log "owned_ready err=$(err) system=$(timeout 3 odindb-send -s system -p system_state 2>/dev/null)"
    # Same native order as the proven controller: one normal live view, quiesce to Max, then group13.
    [ "$ok" = 1 ] && live_on || ok=0
    [ "$ok" = 1 ] && live_view false && wait_idle || ok=0
    if [ "$ok" = 1 ] && [ "$(field stream_group)" = 'E_StreamGroup_Still16bit(0)' ]; then
        op teardown_current_dcam_stream_group && wait_idle || ok=0
    fi
    [ "$ok" = 1 ] && wait_field stream_group 'E_StreamGroup_Max\(255\)' 8 || ok=0
    [ "$ok" = 1 ] && op setup_dcam_stream_group 13 && wait_idle &&
        wait_field stream_group 'E_StreamGroup_LiveviewRawCalib\(13\)' 8 || ok=0
    enter_end=$(( $(uptime_s) + 10 ))
    while [ "$ok" = 1 ] && [ "$(status_field state)" != idle ]; do
        [ "$(uptime_s)" -lt "$enter_end" ] || { log "receiver_not_idle state=$(status_field state)"; ok=0; break; }
        sleep 0.1
    done
    if [ "$ok" != 1 ]; then
        e=$(err)
        log "enter_failed err=$e"
        restore_stock
        [ "$e" = none ] && return 6
        return 10
    fi
    # The encoder takes ~150 MB of ION. Opened by the first clip, the kernel reclaimed
    # memory while that clip recorded and it dropped frames; a failure here only defers it.
    send prep 15 && [ "$(status_field encoder_ready)" = 1 ] || log prep_deferred
    # The stock GUI shows its viewfinder screen only while the service reports live view active;
    # with live view off it parks on the control screen, over the picture and with the shutter
    # going to stills. With group13 streaming the guard absorbs the stock live-view entry, so
    # this only sets that state, as a half press would. Once: while the "USB connected" prompt
    # waits, every attempt is ignored; the GUI asks again when the prompt is answered.
    r=$(timeout 8 odindb-send -s camera -m set_live_view true 2>&1) && wait_idle 10 ||
        log "live_view_shown_failed $(printf '%s' "$r" | tr '\n' ' ' | cut -c1-80)"
    echo up > "$LIVE/session"
    log "enter_ok fps_lines=$(grep -c X2V_SOURCE_FPS "$HOME_DIR/service.log")"
    echo up
}

rec() {
    [ "$(cat "$LIVE/session" 2>/dev/null)" = up ] || return 3
    case "${1:-prores_raw}" in
        prores_raw) p=PRR;;
        h264) p=H264;;
        dng) p=DNG;;
        *) log "rec_bad_codec $1"; return 2;;
    esac
    d=$CLIPS/X2V_${p}_$(date +%Y%m%d_%H%M%S)
    mkdir -p "$d" || return 4
    send "rec $d ${1:-prores_raw}" 15 || return 5
    [ "$(status_field state)" = recording ] || { log "rec_rejected state=$(status_field state) error=$(status_field error)"; return 6; }
    echo "$d"
}

stop_clip() {
    c=$(status_field clip)
    send stop 40 || return 5
    # The ack lands before the MOV is finalized and last_clip is published.
    stop_clip_end=$(( $(uptime_s) + 40 ))
    while [ -n "$c" ] && [ "$(status_field last_clip)" != "$c" ]; do
        [ "$(uptime_s)" -lt "$stop_clip_end" ] || { log "finalize_timeout $c"; return 6; }
        sleep 0.1
    done
    status_field last_clip
}

for s in HUP INT QUIT PIPE TERM USR1 USR2 ALRM; do trap "log sig_$s; exit 9" $s; done
case "${1:-}" in
    enter) enter;;
    rec) rec "${2:-}";;
    stop) stop_clip;;
    exit) escape_cgroup || exit 7
          # quit also releases the guard; a dead service has nothing to finalize.
          [ "$(cat "$LIVE/session" 2>/dev/null)" = up ] && [ -n "$(owned_pid)" ] && send quit 40 && RELEASED=1
          restore_stock;;
    shutdown) shutdown_fast;;
    status) cat "$LIVE/status.json";;
    *) echo "usage: enter|rec|stop|exit|shutdown|status" >&2; exit 2;;
esac
