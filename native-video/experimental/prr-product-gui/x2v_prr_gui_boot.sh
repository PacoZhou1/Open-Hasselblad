#!/system/bin/sh
# Reboot supervisor. Init starts this with late_start and restarts it if it
# dies. Waits for blackbox overlay files (core camera-gui starts earlier),
# then keeps stock camera-gui replaced by the product preload. Not oneshot.
set -eu
set -f
ROOT=/blackbox/x2v-native-20261011
LOCK=$ROOT/gui-session.lock
GUI=/system/bin/camera-gui
LOADER=/system/lib64/libx2v_gui_bootstrap_20261011.so
GUI_SHA=b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b
LOADER_SHA=2ec7b4686682ea1c5c9e9de87876135e0085b8563c90d223211150c3572708dd
ID=prr-gui-boot
RUN=$ROOT/runs/$ID
STOP=$ROOT/rec/boot.stop
MARK=$ROOT/gui/PRODUCT_GUI.installed

valid_pid() { case "$1" in ''|*[!0-9]*) return 1;; esac; [ "$1" -gt 1 ]; }
proc_start() (
    valid_pid "$1" || exit 1
    IFS= read -r line < "/proc/$1/stat" || exit 1
    tail=${line##*) }; set -- $tail
    [ "$#" -ge 20 ] && [ "$1" != Z ] || exit 1
    shift 19; printf '%s\n' "$1"
)
alive() { [ "$(proc_start "$1" 2>/dev/null || true)" = "$2" ] && [ -n "$2" ]; }
has_overlay_env() {
    valid_pid "$1" || return 1
    tr '\0' '\n' < "/proc/$1/environ" 2>/dev/null | grep -q '^X2V_GUI_ENABLE=1$'
}
overlay_pid() {
    for p in $(pidof camera-gui 2>/dev/null || true); do
        if has_overlay_env "$p"; then printf '%s\n' "$p"; return 0; fi
    done
    return 1
}
stock_pids() {
    for p in $(pidof camera-gui 2>/dev/null || true); do
        if ! has_overlay_env "$p"; then printf '%s\n' "$p"; fi
    done
}
verify_hash() { printf '%s  %s\n' "$2" "$1" | sha256sum -c - >/dev/null; }
log() { printf '%s\n' "$*" >> "$RUN/boot.log"; }

n=0
while [ ! -d "$ROOT" ]; do
    n=$((n+1)); [ "$n" -lt 180 ] || exit 7
    sleep 1
done
mkdir -p "$RUN" "$ROOT/rec" "$ROOT/play"
: > "$RUN/boot.log"
log "boot-supervisor start"

n=0
while [ ! -f "$ROOT/gui/main.qml" ] || [ ! -f "$MARK" ]; do
    n=$((n+1))
    [ "$n" -lt 180 ] || { log "overlay files missing after wait"; exit 7; }
    sleep 1
done
rm -f "$STOP"
verify_hash "$GUI" "$GUI_SHA" || { log "gui hash"; exit 4; }
verify_hash "$LOADER" "$LOADER_SHA" || { log "loader hash"; exit 4; }

if ! mkdir "$LOCK" 2>/dev/null; then
    old=$(cat "$LOCK/owner" 2>/dev/null || true)
    op=$(printf '%s\n' "$old" | awk '{print $2}')
    os=$(printf '%s\n' "$old" | awk '{print $3}')
    if [ -n "${op:-}" ] && alive "$op" "$os"; then
        log "lock live $old"
    else
        rm -rf "$LOCK"
        mkdir "$LOCK" || { log "lock steal failed"; exit 8; }
    fi
fi
OWNER="$ID $$ $(proc_start $$)"
printf '%s\n' "$OWNER" > "$LOCK/owner"
cleanup() {
    set +e
    if [ -d "$LOCK" ] && [ "$(cat "$LOCK/owner" 2>/dev/null || true)" = "$OWNER" ]; then
        rm -f "$LOCK/owner"; rmdir "$LOCK" || true
    fi
}
trap cleanup EXIT

stop_stock() {
    setprop ctl.stop camera-gui || true
    n=0
    while [ "$(getprop init.svc.camera-gui)" != stopped ] && [ "$n" -lt 40 ]; do
        n=$((n+1)); sleep 0.1
    done
    for p in $(stock_pids); do
        kill -TERM "$p" 2>/dev/null || true
    done
    n=0
    while [ -n "$(stock_pids)" ] && [ "$n" -lt 30 ]; do
        n=$((n+1)); sleep 0.1
    done
    for p in $(stock_pids); do
        kill -KILL "$p" 2>/dev/null || true
    done
}

start_overlay() {
    overlay_pid >/dev/null && return 0
    export X2V_GUI_ENABLE=1 X2V_GUI_SESSION_ID=$ID LD_PRELOAD=$LOADER QML_XHR_ALLOW_FILE_READ=1
    export XDG_RUNTIME_DIR=/tmp XDG_CACHE_HOME=/data QT_QPA_FONTDIR=/system/lib64/qt/lib/fonts
    "$GUI" -platform wayland-egl --fullscreen >> "$RUN/gui.log" 2>&1 &
    p=$!
    printf '%s %s\n' "$p" "$(proc_start "$p")" > "$RUN/child.identity"
    log "PRODUCT_GUI_BOOT_PID=$p"
}

ensure_helper() {
    [ -f "$ROOT/rec/helper.sh" ] || return 0
    hp=$(cat "$ROOT/rec/helper.pid" 2>/dev/null || true)
    hs=$(proc_start "$hp" 2>/dev/null || true)
    if valid_pid "$hp" && alive "$hp" "$hs"; then return 0; fi
    rm -f "$ROOT/rec/helper.stop"
    sh "$ROOT/rec/helper.sh" >> "$ROOT/rec/helper.log" 2>&1 &
    printf '%s\n' "$!" > "$ROOT/rec/helper.pid"
}

ensure_play() {
    pp=$(cat "$RUN/play.pid" 2>/dev/null || true)
    ps=$(proc_start "$pp" 2>/dev/null || true)
    if valid_pid "$pp" && alive "$pp" "$ps"; then return 0; fi
    PLAY=/system/bin/x2v_prr_play_20261013a
    [ -x "$PLAY" ] || PLAY=/system/bin/x2v_prr_play
    [ -x "$PLAY" ] || return 0
    "$PLAY" --listen 127.0.0.1:18763 --dir "$ROOT/play" >> "$RUN/prr-play.log" 2>&1 &
    printf '%s\n' "$!" > "$RUN/play.pid"
}

log "overlay files ready"
while [ ! -f "$STOP" ]; do
    if [ -n "$(stock_pids)" ] || [ "$(getprop init.svc.camera-gui)" = running ]; then
        stop_stock
    fi
    start_overlay
    ensure_helper
    ensure_play
    sleep 1
done
log "boot.stop"
