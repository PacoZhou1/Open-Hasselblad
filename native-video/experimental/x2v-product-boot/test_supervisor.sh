#!/usr/bin/env mksh
# Host tests of x2v_product_boot.sh's helpers under mksh, the camera's shell: the functions are
# taken from the script as they are, around a fake odindb-send and a fake clip drive.
#   mksh test_supervisor.sh
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=$HERE/x2v_product_boot.sh
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
fails=0
ok() { echo "PASS $*"; }
bad() { echo "FAIL $*"; fails=$((fails+1)); }

# Each function as written: a one-line one, or through its closing brace in column 0.
extract() {
    for f in "$@"; do
        awk -v f="$f" '
            !on && index($0, f "() {") == 1 { on = 1; print; if ($0 ~ /}[[:space:]]*$/ && $0 !~ /\{[[:space:]]*$/) on = 0; next }
            on { print; if ($0 == "}") on = 0 }' "$SRC"
    done
}
extract now cs log valid_pid pstart alive bg reap_bg wake wake_step catalog catalog_step catalog_entry catalog_add write_catalog watch_system > "$T/fns.sh"
grep -q '^CAT_JOB=' "$SRC" && grep '^CAT_JOB=\|^SAVE_WAIT=\|^WAKE_WANT=\|^SYS_T=\|^CAT_HEAD=' "$SRC" >> "$T/fns.sh"

mkdir -p "$T/bin" "$T/run" "$T/rec" "$T/clips"
cat > "$T/bin/odindb-send" <<'EOF'
#!/bin/sh
# Slow like the real one; records the call order.
sleep "${FAKE_ODIN_S:-0.5}"
echo "$*" >> "$FAKE_ODIN_LOG"
case "$*" in *system_state*) echo "system_state = ${FAKE_SYSTEM_STATE:-E_SystemState_Active(1)}";; esac
EOF
chmod +x "$T/bin/odindb-send"
export PATH="$T/bin:$PATH" FAKE_ODIN_LOG="$T/odin.log"
LOG=$T/sup.log; RUN=$T/run; REC=$T/rec; CLIPS=$T/clips; WAKE=x2v-video-recording
WOKE=0; S_SES=up; SHUTDOWN=0
# /proc/uptime does not exist on the host.
mkdir -p "$T/proc"; UPTIME_FILE=$T/proc/uptime
. "$T/fns.sh"
now() { NOW=$(( $(date +%s) - T0 )); }
cs() { CS=$(python3 -c 'import time;print(int(time.time()*100))'); }
log() { printf '%s %s\n' "$(date +%s)" "$*" >> "$LOG"; }
pstart() { PS=""; kill -0 "$1" 2>/dev/null || return 1; ps -o stat= -p "$1" | grep -q Z && return 1; PS=$(ps -o lstart= -p "$1" | tr -d ' '); }
T0=$(date +%s)

# --- bg / reap_bg: a child is reaped once done, and leaves no zombie
bg sleep 0.3; J="$BG_PID $BG_PS"
reap_bg $J && bad "reap_bg returned done while the child runs" || ok "reap_bg waits for a running child"
sleep 0.6
if reap_bg $J; then ok "reap_bg reaps a finished child (rc=$BG_RC)"; else bad "reap_bg still sees a finished child"; fi
ps -o stat= -p "${J% *}" 2>/dev/null | grep -q Z && bad "zombie left" || ok "no zombie"

# --- wake: release never overtakes acquire, the loop never blocks on it
: > "$FAKE_ODIN_LOG"
t=$(date +%s)
wake 1; wake 0
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do wake_step; sleep 0.2; done
[ $(( $(date +%s) - t )) -le 4 ] && ok "wake calls ran beside the loop" || bad "wake blocked"
order=$(tr '\n' ' ' < "$FAKE_ODIN_LOG")
case "$order" in *acquire_wake_lock*release_wake_lock*) ok "acquire then release: $order";; *) bad "wake order: $order";; esac
[ "$WOKE" = 0 ] && ok "ends released" || bad "WOKE=$WOKE"

# --- catalog: 50 clips, fork-free, newest first, valid JSON, SAVE_WAIT cleared when done
for i in $(seq 1 50); do
    ts=$(printf '20261014_%06d' $((100000 + i)))
    case $((i % 3)) in 0) c=PRR; m=clip.mov;; 1) c=H264; m=clip.mp4;; 2) c=DNG; m=proxy.mp4;; esac
    d=$CLIPS/X2V_${c}_$ts; mkdir -p "$d"; : > "$d/$m"
    printf '{"schema":1,"frames":%d,"bytes":%d,"seconds":4.2,"duration":4.1%s,"error":0}\n' $i $((i * 1000)) \
        "$( [ $c = DNG ] && echo ',"proxy_error":0' )" > "$d/clip.json"
done
mkdir -p "$CLIPS/X2V_PRR_20261014_999999"; : > "$CLIPS/X2V_PRR_20261014_999999/clip.mov"
echo '{"schema":1,"duration":1.0,"bytes":5,"error":5}' > "$CLIPS/X2V_PRR_20261014_999999/clip.json"
SAVE_WAIT=1; cs; c0=$CS
catalog
while [ -n "$CAT_JOB" ]; do catalog_step; sleep 0.05; done
cs; ms=$(( (CS - c0) * 10 ))
[ "$SAVE_WAIT" = 0 ] && ok "SAVE_WAIT cleared when the catalog is written" || bad "SAVE_WAIT stuck"
python3 - "$REC/catalog.json" "$ms" <<'EOF' && ok "catalog: 50 entries, newest first, error clip left out ($ms ms on the host)" || bad "catalog content"
import json, sys
c = json.load(open(sys.argv[1]))['clips']
ids = [x['id'] for x in c]
ts = [i.split('_', 2)[2] for i in ids]
assert len(c) == 50, len(c)
assert ts == sorted(ts, reverse=True), ts[:5]
assert not any('999999' in i for i in ids)
assert all(isinstance(x['duration'], float) and isinstance(x['bytes'], int) for x in c)
EOF
# A request while one runs queues exactly one more.
catalog; catalog; catalog
n=0; while [ -n "$CAT_JOB" ]; do catalog_step; sleep 0.05; n=$((n+1)); done
[ "$(grep -c catalog_done "$LOG")" = 3 ] && ok "requests mid-way queue one more pass" || bad "catalog passes: $(grep -c catalog_done "$LOG")"

# --- the per-boot entry cache: a clip still without clip.json is not cached as one that never plays
d=$CLIPS/X2V_H264_20261014_300000; mkdir -p "$d"; : > "$d/clip.mp4"
catalog; while [ -n "$CAT_JOB" ]; do catalog_step; sleep 0.05; done
grep -q X2V_H264_20261014_300000 "$REC/catalog.json" && bad "listed before its clip.json" || ok "not listed before its clip.json"
[ -f "$RUN/cat/X2V_H264_20261014_300000" ] && bad "cached before its clip.json" || ok "not cached before its clip.json"
echo '{"schema":1,"bytes":7,"duration":2.5,"error":0}' > "$d/clip.json"
catalog; while [ -n "$CAT_JOB" ]; do catalog_step; sleep 0.05; done
python3 -c "import json,sys;c=json.load(open(sys.argv[1]))['clips'];assert c[0]['id']=='X2V_H264_20261014_300000',c[0]" \
    "$REC/catalog.json" && ok "listed first once its clip.json is there" || bad "new clip not first"

# --- catalog_add: a saved clip goes first at once, without a rebuild; a second add is a no-op
d=$CLIPS/X2V_DNG_20261014_400000; mkdir -p "$d"; : > "$d/proxy.mp4"
echo '{"schema":1,"bytes":9,"duration":3.5,"proxy_error":0,"error":0}' > "$d/clip.json"
n0=$(grep -c catalog_done "$LOG"); cs; c0=$CS
catalog_add X2V_DNG_20261014_400000
cs; ms=$(( (CS - c0) * 10 ))
[ -z "$CAT_JOB" ] && [ "$(grep -c catalog_done "$LOG")" = "$n0" ] && ok "added without a rebuild ($ms ms)" || bad "catalog_add rebuilt"
python3 -c "import json,sys;c=json.load(open(sys.argv[1]))['clips'];assert c[0]['id']=='X2V_DNG_20261014_400000' and len(c)==52,(c[0]['id'],len(c))" \
    "$REC/catalog.json" && ok "added clip first, valid JSON, 52 clips" || bad "catalog after add"
catalog_add X2V_DNG_20261014_400000
python3 -c "import json,sys;c=json.load(open(sys.argv[1]))['clips'];assert len(c)==52,len(c)" "$REC/catalog.json" \
    && ok "adding it again changes nothing" || bad "duplicate entry"
# An add while a rebuild runs queues another rebuild and holds "saved" until it is done.
catalog; d=$CLIPS/X2V_PRR_20261014_500000; mkdir -p "$d"; : > "$d/clip.mov"
echo '{"schema":1,"bytes":3,"duration":1.5,"error":0}' > "$d/clip.json"
SAVE_WAIT=0; catalog_add X2V_PRR_20261014_500000
[ "$CAT_AGAIN" = 1 ] && [ "$SAVE_WAIT" = 1 ] && ok "add mid-rebuild queues one more and holds saved" || bad "CAT_AGAIN=$CAT_AGAIN SAVE_WAIT=$SAVE_WAIT"
while [ -n "$CAT_JOB" ]; do catalog_step; sleep 0.05; done
python3 -c "import json,sys;c=json.load(open(sys.argv[1]))['clips'];assert c[0]['id']=='X2V_PRR_20261014_500000',c[0]['id']" \
    "$REC/catalog.json" && [ "$SAVE_WAIT" = 0 ] && ok "after the rebuild it is still first, saved released" || bad "lost after rebuild"

# --- watch_system: the probe runs beside the loop and a PrepareShutdown is seen
export FAKE_SYSTEM_STATE='E_SystemState_PrepareShutdown(6)' FAKE_ODIN_S=0.4
SYS_T=0; SYS_JOB=""; T0=$(( $(date +%s) - 100 ))
watch_system
[ -n "$SYS_JOB" ] && ok "probe started in the background" || bad "no probe"
sleep 0.8; watch_system
[ "$SHUTDOWN" = 1 ] && ok "PrepareShutdown seen" || bad "SHUTDOWN=$SHUTDOWN"

echo "$fails failed"
[ "$fails" = 0 ]
