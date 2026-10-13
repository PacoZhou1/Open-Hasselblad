#!/system/bin/sh
# Persistent product GUI. Stops stock camera-gui, starts overlay, does not
# restore on a healthy run. Crash-loop (3 deaths) falls back to stock.
set -eu
set -f
ROOT=/blackbox/x2v-native-20261011
LOCK=$ROOT/gui-session.lock
GUI=/system/bin/camera-gui
LOADER=/system/lib64/libx2v_gui_bootstrap_20261011.so
GUI_SHA=b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b
LOADER_SHA=2ec7b4686682ea1c5c9e9de87876135e0085b8563c90d223211150c3572708dd
SELF=$0
ID=prr-gui-persist
RUN=$ROOT/runs/$ID

valid_pid() { case "$1" in ''|*[!0-9]*) return 1;; esac; [ "$1" -gt 1 ]; }
proc_start() (
    valid_pid "$1" || exit 1
    IFS= read -r line < "/proc/$1/stat" || exit 1
    tail=${line##*) }
    set -- $tail
    [ "$#" -ge 20 ] && [ "$1" != Z ] || exit 1
    shift 19
    printf '%s\n' "$1"
)
alive() { [ "$(proc_start "$1" 2>/dev/null || true)" = "$2" ] && [ -n "$2" ]; }
read_owner() { cat "$LOCK/owner" 2>/dev/null; }
owned() { [ "$(read_owner || true)" = "$OWNER" ]; }
phase() { printf '%s\n' "$1" > "$RUN/phase.tmp.$$"; mv "$RUN/phase.tmp.$$" "$RUN/phase"; }
verify_hash() { printf '%s  %s\n' "$2" "$1" | sha256sum -c -; }

restore_stock() (
    set +e
    p=; ps=
    read p ps < "$RUN/child.identity" 2>/dev/null || true
    if valid_pid "$p" && alive "$p" "$ps"; then
        kill -TERM "$p" 2>/dev/null || true
        n=0
        while alive "$p" "$ps" && [ "$n" -lt 30 ]; do n=$((n+1)); sleep 0.1; done
        if alive "$p" "$ps"; then kill -KILL "$p" 2>/dev/null || true; fi
    fi
    if [ -f "$RUN/play.pid" ]; then
        read pp < "$RUN/play.pid" || true
        if valid_pid "${pp:-}"; then kill -TERM "$pp" 2>/dev/null || true; fi
    fi
    if [ -f "$RUN/stock-stop-requested" ]; then
        setprop ctl.start camera-gui || true
        n=0
        while [ "$n" -lt 50 ]; do
            state=$(getprop init.svc.camera-gui)
            existing=$(pidof camera-gui 2>/dev/null || true)
            [ "$state" = running ] && [ -n "$existing" ] && break
            n=$((n+1)); sleep 0.1
        done
    fi
    phase restored
    : > "$RUN/restored"
    if owned; then
        rm -f "$LOCK/owner"
        rmdir "$LOCK" || true
    fi
    echo STOCK_GUI_RESTORED
)

MODE=run
case "${1:-}" in --child|--stop) MODE=${1#--}; shift;; esac

if [ "$MODE" = child ]; then
    OWNER=$(cat "$RUN/session.owner")
    n=0
    while [ ! -f "$RUN/launch" ]; do
        owned && [ ! -f "$RUN/stop" ] || exit 3
        n=$((n+1)); [ "$n" -lt 100 ] || exit 4
        sleep 0.1
    done
    owned && [ ! -f "$RUN/stop" ] || exit 3
    export X2V_GUI_ENABLE=1 X2V_GUI_SESSION_ID=$ID LD_PRELOAD=$LOADER QML_XHR_ALLOW_FILE_READ=1
    export XDG_RUNTIME_DIR=/tmp XDG_CACHE_HOME=/data QT_QPA_FONTDIR=/system/lib64/qt/lib/fonts
    exec "$GUI" -platform wayland-egl --fullscreen
fi

if [ "$MODE" = stop ]; then
    [ -d "$RUN" ] || exit 2
    OWNER=$(cat "$RUN/session.owner" 2>/dev/null || true)
    : > "$RUN/stop"
    if [ -n "${OWNER:-}" ]; then
        read oid op os < "$RUN/session.owner" || true
        if valid_pid "${op:-}" && alive "$op" "$os"; then kill -TERM "$op" 2>/dev/null || true; fi
    fi
    exit 0
fi

mkdir -p "$RUN"
[ ! -f "$RUN/session.owner" ] || { echo 'persist already claimed this run dir' >&2; exit 3; }
mkdir "$LOCK" 2>/dev/null || { echo 'GUI session/deployment lock busy' >&2; read_owner >&2 || true; exit 3; }
OWNER="$ID $$ $(proc_start $$)"
printf '%s\n' "$OWNER" > "$RUN/session.owner"
printf '%s\n' "$OWNER" > "$LOCK/owner"
rm -f "$RUN/stop" "$RUN/restored" "$RUN/launch" "$RUN/child.identity"

cleanup() {
    original_result=$?
    set +e
    printf '%s\n' "$original_result" > "$RUN/exit.code"
    if [ -f "$RUN/stop" ] || [ -f "$RUN/crash-loop" ]; then
        restore_stock
    else
        # Keep overlay files. Only stop the supervisor; leave a running child.
        phase installed
        if owned; then
            rm -f "$LOCK/owner"
            rmdir "$LOCK" || true
        fi
    fi
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

phase validating
verify_hash "$GUI" "$GUI_SHA"
verify_hash "$LOADER" "$LOADER_SHA"
[ -f "$RUN/payload/manifest.sha256" ] && [ -f "$RUN/payload/gui/main.qml" ] || exit 4
awk 'NF!=2 || length($1)!=64 || $1 ~ /[^0-9a-f]/ || $2 !~ /^gui\/[A-Za-z0-9_.\/-]+$/ || $2 ~ /(^|\/)\.\.?($|\/)/ {bad=1} END{exit bad || NR==0}' "$RUN/payload/manifest.sha256"
[ -z "$(find "$RUN/payload/gui" -type l -print)" ] || exit 4
[ "$(find "$RUN/payload/gui" -type f | wc -l)" -eq "$(wc -l < "$RUN/payload/manifest.sha256")" ] || exit 4
(cd "$RUN/payload" && sha256sum -c manifest.sha256)
timeout 5 env X2V_GUI_ENABLE=1 X2V_GUI_DRY_RUN=1 LD_PRELOAD="$LOADER" "$GUI" > "$RUN/dry-run.log" 2>&1
[ "$(tail -n 1 "$ROOT/bootstrap.log")" = DRY_RUN_BUILD_PREFIX_VERIFIED ] || exit 4

owned || exit 4
if [ -e "$ROOT/gui" ]; then
    [ -d "$ROOT/gui" ] && [ ! -L "$ROOT/gui" ] || exit 4
    rm -rf "$RUN/previous-gui"
    mv "$ROOT/gui" "$RUN/previous-gui"
fi
cp -R "$RUN/payload/gui" "$ROOT/gui"
(cd "$ROOT" && sha256sum -c "$RUN/payload/manifest.sha256")
: > "$ROOT/gui/PRODUCT_GUI.installed"
if [ -f "$RUN/payload/helper.sh" ]; then
    mkdir -p "$ROOT/rec"
    cp "$RUN/payload/helper.sh" "$ROOT/rec/helper.sh"
    chmod 755 "$ROOT/rec/helper.sh"
fi
if [ -f "$RUN/payload/x2v-prr-gui.rc" ]; then
    cp "$RUN/payload/x2v-prr-gui.rc" "$ROOT/x2v-prr-gui.rc"
    if [ -x /system/bin/x2v_prr_gui_boot_20261013d ]; then
        set +e
        mount -o remount,rw /system
        cp "$RUN/payload/x2v-prr-gui.rc" /system/etc/init/x2v-prr-gui.rc
        chmod 644 /system/etc/init/x2v-prr-gui.rc
        mount -o remount,ro /system
        set -e
    fi
fi

start_play() {
    mkdir -p "$ROOT/play"
    PLAY=/system/bin/x2v_prr_play_20261013a
    [ -x "$PLAY" ] || PLAY=/system/bin/x2v_prr_play
    [ -x "$PLAY" ] || return 0
    "$PLAY" --listen 127.0.0.1:18763 --dir "$ROOT/play" >>"$RUN/prr-play.log" 2>&1 &
    printf '%s\n' "$!" > "$RUN/play.pid"
}

phase stopping_stock
: > "$RUN/stock-stop-requested"
setprop ctl.stop camera-gui
n=0
while [ "$(getprop init.svc.camera-gui)" != stopped ]; do
    n=$((n+1)); [ "$n" -lt 50 ] || exit 5
    sleep 0.1
done
[ -z "$(pidof camera-gui 2>/dev/null || true)" ] || exit 5
start_play

deaths=0
while [ ! -f "$RUN/stop" ]; do
    owned || exit 5
    rm -f "$RUN/launch"
    sh "$SELF" --child > "$RUN/gui.log" 2>&1 &
    p=$!
    printf '%s %s\n' "$p" "$(proc_start "$p")" > "$RUN/child.identity"
    : > "$RUN/launch"
    phase running
    printf 'PRODUCT_GUI_PID=%s\n' "$p"
    set +e
    wait "$p"
    child_rc=$?
    set -e
    [ -f "$RUN/stop" ] && break
    deaths=$((deaths+1))
    printf '%s\n' "$deaths" > "$RUN/deaths"
    if [ "$deaths" -ge 3 ]; then
        : > "$RUN/crash-loop"
        phase crash_loop
        exit 6
    fi
    phase restarting
    sleep 1
done
phase stopping
