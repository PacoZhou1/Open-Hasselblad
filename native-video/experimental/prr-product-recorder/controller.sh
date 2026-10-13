#!/system/bin/sh
# Offline candidate: root final reviewed packet alone may remove this HOLD.
# RX16 provisional DNG two generations within one native source; 47s absolute source budget.
# Only CPU clip/generation/FD proof changed; original native source stop/recovery retained.
# Requires migrated native bootstrap and data-only ADB observer before imaging dispatch.
set -u
# Exact native factory PATH, verified on this camera; bootstrap uses a narrower PATH.
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH
set -f
ROOT=/data/x2v-source-20261012
LOCK=$ROOT/source-session.lock
PEER_OLD=/blackbox/x2v-native-20261011/gui-session.lock
PEER_NEW=/data/x2v-native-20261012/gui-session.lock
SERVICE=/system/bin/camera-service
GUI=/system/bin/camera-gui
FACTORY=/system/bin/camera-test
SERVICE_SHA=51b9e02f8bfebf388be8dfa163c8e512bee19aeb8ae37a6712727ccc6f26a52d
GUI_SHA=b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b
FACTORY_SHA=d018fee011426aefef1ded0bd2554ec6f4d31ea0b2529b63f9d5baddc44c42e0
RCAM=/system/lib64/librcam.so
RCAM_SHA=3dd5b37b3db18b3e6b54271e1501b4dd337e101c06cdd386a896b1547b662f66
RECEIVER=/system/lib64/libx2v_mode21c24_prr_async_20261013a.so
RECEIVER_SHA=8d77747222d106999b15def2edc608bfcaf33431c4a71e7c69effb928b31ae59
RECEIPT_VALIDATOR=/system/bin/x2v_prr_async_receipt_validate_20261013a
RECEIPT_VALIDATOR_SHA=d4ba780241e546bd00fc39127d8d818cebb98d34ea33c041eecce81ec6c3550f
HAL=/system/lib64/libduml_hal.so
HAL_SHA=adfb1cf834584d5c2d3e7b8a49c8ff78a919f007b4fe4ee5442a658dafc71d20
FRWK=/system/lib64/libdcam_frwk.so
FRWK_SHA=5329c95d3c36775fbf1a93bbf1100a766b08bcf4504a2e3a6292bd3fcdb7bf88
BULK_ROOT=/mnt/media_rw/ssd/x2v-source-20261012
SELF=$0
TOOLS=${SELF%/*}
SP=$TOOLS/imx861bqr_hb722.sp
CONF=$TOOLS/imx861bqr_hb722.conf
SP_SHA=594f651e83a6d916e9af64ac96c718038c511c3a419028690982b079a6e729e4
CONF_SHA=5558a0fc6a5864c4711a3f0d0fba5b66d775822d6522b599724a9921d0fca3aa
BUSY=setup_dcam_stream_group_active,teardown_current_dcam_stream_group_active,start_dcam_stream_active,stop_dcam_stream_active,set_live_view_active
STATE=live_view_state,liveview_transport_mode_current,stream_group,crop_mode_current
IDLE=do_exposure_active,do_exposure_extended_active,do_exposure_extended2_active,find_focus_active,exposure_status,exposures_processing_counter,zoom_active
valid_id() { case "$1" in ''|*[!A-Za-z0-9_-]*) return 1;; esac; [ "${#1}" -le 64 ]; }
valid_pid() { case "$1" in ''|*[!0-9]*) return 1;; esac; [ "$1" -gt 1 ]; }
proc_start() (
 valid_pid "$1" || exit 1
 IFS= read -r line < "/proc/$1/stat" || exit 1
 tail=${line##*) }; set -- $tail
 [ "$#" -ge 20 ] && [ "$1" != Z ] || exit 1
 shift 19; printf '%s\n' "$1"
)
# Includes Z so a retired same-starttime zombie can be waited out safely.
proc_start_raw() (
 valid_pid "$1" || exit 1
 IFS= read -r line < "/proc/$1/stat" || exit 1
 tail=${line##*) }; set -- $tail
 [ "$#" -ge 20 ] || exit 1
 shift 19; printf '%s\n' "$1"
)
proc_state() (
 IFS= read -r line < "/proc/$1/stat" || exit 1
 tail=${line##*) }; set -- $tail; printf '%s\n' "$1"
)
proc_pgid() ( read line < "/proc/$1/stat" || exit 1; tail=${line##*) }; set -- $tail; printf '%s\n' "$3"; )
proc_sid() ( read line < "/proc/$1/stat" || exit 1; tail=${line##*) }; set -- $tail; printf '%s\n' "$4"; )
proc_group() { awk -F: '$2=="cpuacct" {print $3}' "/proc/$1/cgroup"; }
proc_exe() { readlink "/proc/$1/exe"; }
uptime_seconds() { read up unused < /proc/uptime; printf '%s\n' "${up%%.*}"; }
alive() { [ -n "$2" ] && [ "$(proc_start "$1" 2>/dev/null || true)" = "$2" ]; }
owned() { [ "$(cat "$LOCK/owner" 2>/dev/null || true)" = "$OWNER" ]; }
log() { printf '%s %s\n' "$(uptime_seconds)" "$*" >> "$RUN/events.log" 2>/dev/null || true; }
phase() { log "PHASE $1"; printf '%s\n' "$1" > "$RUN/phase" 2>/dev/null || true; }
fail() { phase "ERROR_$1"; return 1; }
verify_hash() { printf '%s  %s\n' "$2" "$1" | sha256sum -c -; }
identity() { p=$(pidof "$1" 2>/dev/null || true); valid_pid "$p" || return 1; s=$(proc_start "$p") || return 1; printf '%s %s\n' "$p" "$s"; }
owned_member() (
 read oi op os extra < "$RUN/session.owner" || exit 1
 [ "$oi" = "$ID" ] && [ -z "$extra" ] && valid_pid "$op" || exit 1
 alive "$1" "$2" && [ "$(proc_group "$1")" = "$(cat "$RUN/owner.group")" ] &&
 [ "$(proc_pgid "$1")" = "$op" ] && [ "$(proc_sid "$1")" = "$op" ]
)
match_service() {
 read sp ss < "$RUN/active-service.identity" || return 1
 alive "$sp" "$ss" && [ "$(pidof camera-service 2>/dev/null || true)" = "$sp" ] &&
 [ "$(proc_exe "$sp")" = "$SERVICE" ] &&
 [ "$(proc_group "$sp")" = "$(cat "$RUN/active-service.group")" ]
}
gate() { owned && { [ "$RECOVERING" = 1 ] || [ ! -f "$RUN/abort" ]; }; }
# Bootstrap kept its native domain while joining the tested shared adbd group.
# This separates factory cleanup only; adbd failure still affects all own workers.
bootstrap_owner() {
 if [ -f "$RUN/product.mode" ]; then
  fg=$(cat "$ROOT/target.group") || return 1
  [ -n "$fg" ] && [ "$(proc_group $$)" = "$fg" ] || return 1
  [ "$(cat /proc/self/attr/current 2>/dev/null)" = "$DOMAIN" ] || return 1
  printf '%s\n' "$fg" > "$RUN/owner.group" || return 1
  printf '%s\n' /product > "$RUN/factory.group" || return 1
  return 0
 fi
 read bv br bn bb bfp bfs bfpg bd extra < "$RUN/passive.binding" || return 1
 [ "$bv $br" = "v1 $ID" ] && [ -z "$extra" ] || return 1
 read mv mk mr mn mc mip mis mb mpg msid md mg mt mw mwd extra < "$RUN/passive.migrated" || return 1
 [ "$mv $mk $mr $mn $mb" = "v1 migrated $ID $bn $bb" ] && [ -z "$extra" ] || return 1
 [ "$mip" = "$$" ] && [ "$mis" = "$(proc_start $$)" ] &&
 [ "$mpg" = "$$" ] && [ "$msid" = "$$" ] &&
 [ "$(proc_pgid $$)" = "$$" ] && [ "$(proc_sid $$)" = "$$" ] &&
 [ "$md" = u:r:hbl_camera_service:s0 ] && [ "$mg $mt" = '/uid_0/pid_3102 /uid_0/pid_3102' ] &&
 [ "$(proc_group $$)" = "$mg" ] && [ "$bb" = "$(cat /proc/sys/kernel/random/boot_id)" ] || return 1
 case "$bd:$mw:$mwd:$bfp:$bfs:$bfpg" in *[!0-9:]*|'') return 1;; esac
 valid_pid "$bfp" && valid_pid "$bfs" && valid_pid "$bfpg" || return 1
 now=$(uptime_seconds)
 [ "$mw" -lt "$mwd" ] && [ "$mw" -le "$now" ] && [ "$((now-mw))" -le 20 ] && [ "$now" -lt "$bd" ] || return 1
 [ "$(cat "$RUN/passive.go")" = "v1 $ID $bn $mc" ] && [ ! -e "$RUN/passive.stop" ] || return 1
 fg=$mg; fp=$bfp
 printf '%s\n' "$fg" > "$RUN/owner.group" && printf '/uid_0/pid_%s\n' "$fp" > "$RUN/factory.group"
}
guard_ready() (
 if [ -f "$RUN/product.mode" ]; then return 0; fi
 read bv br bn bb bd extra < "$RUN/guard.binding" || exit 1
 [ "$bv $br" = "v1 $ID" ] && [ -z "$extra" ] || exit 1
 read pv pr pn pb unused < "$RUN/passive.binding" || exit 1
 [ "$bn $bb" = "$pn $pb" ] && [ "$bb" = "$(cat /proc/sys/kernel/random/boot_id)" ] || exit 1
 read rv rr rn rp rs rg rpg rb extra < "$RUN/adb-guard.ready" || exit 1
 [ "$rv $rr $rn $rb" = "v1 $ID $bn $bb" ] && [ -z "$extra" ] || exit 1
 alive "$rp" "$rs" && [ "$(proc_group "$rp")" = "$rg" ] && [ "$(proc_pgid "$rp")" = "$rpg" ] || exit 1
 [ "$rg" = /uid_0/pid_3102 ] && [ "$rpg" = "$rp" ] && [ "$rpg" != "$(proc_pgid $$)" ] &&
 [ "$rg" != "$(cat "$RUN/factory.group")" ] || exit 1
 read hv hr hn hp ht extra < "$RUN/adb-guard.heartbeat" || exit 1
 [ "$hv $hr $hn $hp" = "v1 $ID $bn $rp" ] && [ -z "$extra" ] || exit 1
 case "$ht:$bd" in *[!0-9:]*) exit 1;; esac
 now=$(uptime_seconds)
 [ "$now" -ge "$ht" ] && [ "$((now-ht))" -le 5 ] && [ "$((bd-now))" -ge "${1:-20}" ] || exit 1
 [ ! -e "$ROOT/EXECUTION_HOLD" ] && [ ! -e "$RUN/guard.hold" ] && [ ! -e "$RUN/abort" ]
)
seal_guard_owners() {
 if [ -f "$RUN/product.mode" ]; then
  read wp ws < "$RUN/watchdog.identity" || return 1
  alive "$wp" "$ws" || return 1
  log PRODUCT_GUARD_SEAL_SKIPPED
  return 0
 fi
 guard_ready 130 || return 1
 read bv br nonce bb bd extra < "$RUN/guard.binding" || return 1
 read wp ws < "$RUN/watchdog.identity" || return 1
 owned_member "$mp" "$ms" &&
 [ "$(proc_exe "$mp")" = "$(cat "$RUN/manual-shell.exe")" ] &&
 owned_member "$wp" "$ws" || return 1
 verify_hash /system/bin/x2v_guard_clock_20261012b d44ae57623f60019d54817a9651e343ea6e26646e2e8860c16811181dc700f59 || return 1
 mount | grep -q ' /system .*[(]ro,' || return 1
 printf 'v1 %s %s %s %s %s %s %s %s\n' "$ID" "$nonce" "$mp" "$ms" "$$" "$(proc_start $$)" "$wp" "$ws" > "$RUN/owners.tmp" || return 1
 mv "$RUN/owners.tmp" "$RUN/owners" || return 1
 oh=$(sha256sum "$RUN/owners"); oh=${oh%% *}
 printf '%s\n' "$oh" > "$RUN/owners.sha256.tmp" && mv "$RUN/owners.sha256.tmp" "$RUN/owners.sha256" || return 1
 n=0
 while [ "$(cat "$RUN/adb-guard.owners-ack" 2>/dev/null || true)" != "v1 $ID $nonce $oh" ]; do
  guard_ready 120 || return 1
  n=$((n+1)); [ "$n" -lt 50 ] || return 1; sleep 0.1
 done
 log GUARD_SEALED_ALL_OWNERS_BEFORE_STOCK_STOP_DATA_ABORT_ONLY
}
query() {
 gate && match_service || return 1
 query_owner=$(cat "$RUN/active-service.identity") || return 1
 if timeout 4 odindb-send -s camera -p "$1" > "$RUN/reply.$2" 2>&1; then qr=0; else qr=$?; fi
 log "QUERY $2 rc=$qr"
 gate && match_service && [ "$qr" -eq 0 ] && [ "$(cat "$RUN/active-service.identity")" = "$query_owner" ] || return 1
 QUERY_OWNER=$query_owner
}
op() {
 STATE_SNAPSHOT_READY=0
 gate && match_service || return 1
 log "OP_BEGIN $*"
 if timeout 8 odindb-send -s camera -m "$@" > "$RUN/op.reply" 2>&1; then opr=0; else opr=$?; fi
 log "OP_END $* rc=$opr"; gate && match_service && [ "$opr" -eq 0 ]
}
snapshot_fields() {
 awk -v keys="$1" '
 BEGIN {n=split(keys,k,",");for(i=1;i<=n;i++)want[k[i]]=1}
 NF!=3 || $2!="=" || !($1 in want) {bad=1;next}
 {seen[$1]++;if(seen[$1]!=1)bad=1}
 END {for(i=1;i<=n;i++)if(seen[k[i]]!=1)bad=1;exit bad}
 ' "$RUN/reply.$2"
}
take_state_snapshot() {
 [ "${STATE_SNAPSHOT_READY:-0}" = 1 ] || return 1
 STATE_SNAPSHOT_READY=0
 gate && match_service && [ "$(cat "$RUN/active-service.identity")" = "$SNAPSHOT_OWNER" ]
}
busy_once() {
 STATE_SNAPSHOT_READY=0
 query "$BUSY,$IDLE,$STATE" snapshot && snapshot_fields "$BUSY,$IDLE,$STATE" snapshot || return 2
 # Each consumer sees the same complete reply, with the same checked owner.
 cp "$RUN/reply.snapshot" "$RUN/reply.state" &&
 cp "$RUN/reply.snapshot" "$RUN/reply.idle" &&
 cp "$RUN/reply.snapshot" "$RUN/reply.busy" || return 2
 SNAPSHOT_OWNER=$QUERY_OWNER
 allfalse=1
 oldifs=$IFS; IFS=,; set -- $BUSY; IFS=$oldifs
 for field do
  grep -Eq "^$field = (true|false)$" "$RUN/reply.busy" || return 2
  grep -qx "$field = false" "$RUN/reply.busy" || allfalse=0
 done
 [ "$allfalse" = 1 ]
}
wait_idle() {
 idle_until=$(( $(uptime_seconds)+20 ))
 while :; do
  busy_once; b=$?
  [ "$b" -eq 0 ] && break
  [ "$b" -eq 1 ] || { fail busy_unknown; return 1; }
  [ "$(uptime_seconds)" -lt "$idle_until" ] || { fail native_pending; return 1; }
  sleep 0.1
 done
 for line in 'do_exposure_active = false' 'do_exposure_extended_active = false' 'do_exposure_extended2_active = false' 'find_focus_active = false' 'exposure_status = E_ExposureStatus_None(0)' 'exposures_processing_counter = 0' 'zoom_active = false'; do
  grep -qx "$line" "$RUN/reply.idle" || { fail exposure_or_focus_busy; return 1; }
 done
 gate && match_service && [ "$(cat "$RUN/active-service.identity")" = "$SNAPSHOT_OWNER" ] || return 1
 STATE_SNAPSHOT_READY=1
}
normal_state() {
 take_state_snapshot || return 1
 grep -qx 'liveview_transport_mode_current = E_LiveviewTransportMode_None(0)' "$RUN/reply.state" &&
 grep -qx 'crop_mode_current = E_CropMode_None(0)' "$RUN/reply.state" &&
 grep -Eq '^stream_group = E_StreamGroup_(Still16bit\(0\)|Max\(255\))$' "$RUN/reply.state"
}
# Function fragment only: root supplies op/query/wait_idle/match_service,
# normal_state/graph_state, graph_evidence, fail/phase, RUN and valid_pid.
# No standalone execution, no process signals, no device paths or new backend.
q_scope() {
    read qs_pid qs_start qs_extra < "$RUN/active-service.identity" || return 1
    valid_pid "$qs_pid" && valid_pid "$qs_start" && [ -z "$qs_extra" ] || return 1
    qs_owner="$qs_pid $qs_start"
    qs_prefix="$RUN/native-$qs_pid-$qs_start"
    q_owner_same
}
q_owner_same() {
    [ "$(cat "$RUN/active-service.identity" 2>/dev/null)" = "$qs_owner" ] && match_service
}
q_sticky() {
    if [ -f "$1-intent" ] && [ ! -f "$1-confirmed" ]; then
        fail "$2"; return 1
    fi
}

quiesce() {
    q_scope || { fail normal_quiesce_owner; return 1; }
    q_sticky "$qs_prefix-normal-off" normal_off_unknown_no_retry || return 1
    q_sticky "$qs_prefix-normal-teardown" normal_teardown_unknown_no_retry || return 1
    wait_idle && normal_state && q_owner_same || { fail quiesce_precheck; return 1; }
    if grep -qx 'live_view_state = E_LiveViewState_Active(1)' "$RUN/reply.state"; then
        [ ! -f "$qs_prefix-normal-off-confirmed" ] || { fail normal_off_state_regressed; return 1; }
        q_owner_same && : > "$qs_prefix-normal-off-intent" || return 1
        op set_live_view false && wait_idle && normal_state && q_owner_same &&
        grep -qx 'live_view_state = E_LiveViewState_Off(0)' "$RUN/reply.state" || {
            fail normal_off_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-normal-off-confirmed" || return 1
    fi
    grep -qx 'live_view_state = E_LiveViewState_Off(0)' "$RUN/reply.state" || { fail not_off; return 1; }
    if grep -qx 'stream_group = E_StreamGroup_Still16bit(0)' "$RUN/reply.state"; then
        [ ! -f "$qs_prefix-normal-teardown-confirmed" ] || { fail normal_teardown_state_regressed; return 1; }
        q_owner_same && : > "$qs_prefix-normal-teardown-intent" || return 1
        op teardown_current_dcam_stream_group && wait_idle && normal_state && q_owner_same &&
        grep -qx 'stream_group = E_StreamGroup_Max(255)' "$RUN/reply.state" || {
            fail normal_teardown_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-normal-teardown-confirmed" || return 1
    fi
    grep -qx 'stream_group = E_StreamGroup_Max(255)' "$RUN/reply.state" || { fail not_torn_down; return 1; }
    q_owner_same || return 1
    phase quiesced_group255
}

normal_start() {
 wait_idle && normal_state && op set_live_view true && wait_idle && normal_state || return 1
 grep -qx 'live_view_state = E_LiveViewState_Active(1)' "$RUN/reply.state" &&
 grep -qx 'stream_group = E_StreamGroup_Still16bit(0)' "$RUN/reply.state"
}
method_count() {
 op get_frame_count || return 1
 value=$(sed -n 's/^count = \([0-9][0-9]*\)$/\1/p' "$RUN/op.reply")
 case "$value" in ''|*[!0-9]*) return 1;; esac
 printf '%s\n' "$value"
}
frames_advance() {
 first=$(method_count) || return 1
 frames_until=$(( $(uptime_seconds)+5 ))
 while :; do
  sleep 0.1
  last=$(method_count) || return 1
  if [ "$last" -gt "$first" ]; then log "FRAMES first=$first last=$last"; return 0; fi
  [ "$(uptime_seconds)" -lt "$frames_until" ] || return 1
 done
}
wait_absent() {
 n=0
 while [ "$(getprop "init.svc.$1")" != stopped ] || [ -n "$(pidof "$1" 2>/dev/null || true)" ]; do
  n=$((n+1)); [ "$n" -lt 40 ] || return 1; sleep 0.1
 done
}
wait_ready() {
 if [ "$RECOVERING" = 1 ]; then [ "$(getprop init.svc.camera-service)" = running ] || return 1; fi
 n=0
 while :; do
  match_service || return 1
  STATE_SNAPSHOT_READY=0
  if query "$STATE" state && snapshot_fields "$STATE" state; then
   SNAPSHOT_OWNER=$QUERY_OWNER
   STATE_SNAPSHOT_READY=1
   if normal_state; then return 0; fi
  fi
  n=$((n+1)); [ "$n" -lt 10 ] || return 1; sleep 0.1
 done
}
release_locks() {
 for lk in "$PEER_OLD" "$PEER_NEW" "$LOCK"; do
  if [ "$(cat "$lk/owner" 2>/dev/null || true)" = "$OWNER" ]; then
   rm -f "$lk/owner" && rmdir "$lk" || return 1
  fi
 done
}
lock_recovery() {
 exec 9>> "$RUN/recovery.flock" || return 1
 LOCK_HELD=0
 nlock=0
 while ! toybox flock -n 8 8>&9; do
  nlock=$((nlock+1)); [ "$nlock" -lt 15 ] || return 1; sleep 1
 done
 LOCK_HELD=1
}
# This runs ONLY in the supervisor, which is the direct manual-child parent.
# A recovery subshell cannot reap that child; waiting there is not equivalent.
retire_manual_parent() {
 rp=; rs=; read rp rs < "$RUN/manual.identity" 2>/dev/null || return 0
 valid_pid "$rp" || return 0
 [ ! -f "$RUN/manual.reaped" ] || return 0
 actual=$(proc_start_raw "$rp" 2>/dev/null || true)
 [ -z "$actual" ] || [ "$actual" = "$rs" ] || { fail retiring_pid_reused; return 1; }
 if alive "$rp" "$rs"; then
  owned_member "$rp" "$rs" || { fail parent_retire_cgroup; return 1; }
  rexe=$(proc_exe "$rp")
  if [ "$rexe" = "$SERVICE" ]; then
   printf '%s %s\n' "$rp" "$rs" > "$RUN/active-service.identity" && cp "$RUN/owner.group" "$RUN/active-service.group" || return 1
   receiver_drain && owner_quiesce || { fail parent_retire_pending_no_kill; return 1; }
  elif [ "$rexe" = "$(cat "$RUN/manual-shell.exe" 2>/dev/null || true)" ] && [ -f "$RUN/abort" ] && { [ ! -f "$RUN/launch" ] || [ -z "$(pidof camera-service 2>/dev/null || true)" ]; }; then
   log PARENT_GATED_CHILD_CANCEL
  else fail parent_retire_identity; return 1; fi
  kill -TERM "$rp" || return 1
  nr=0; while alive "$rp" "$rs"; do nr=$((nr+1)); [ "$nr" -lt 40 ] || { fail parent_retire_survived_term; return 1; }; sleep 0.1; done
 fi
 log "PARENT_REAP_BEGIN pid=$rp start=$rs proc_state=$(proc_state "$rp" 2>/dev/null || true) raw_start=$(proc_start_raw "$rp" 2>/dev/null || true)"
 # The child has been observed dead/Z; wait cannot now block on a live producer.
 # A scoped child exit 143/7 is recorded separately, not rewritten as body success.
 if wait "$rp"; then child_rc=0; else child_rc=$?; fi
 log "PARENT_REAP_END pid=$rp wait_rc=$child_rc proc_state=$(proc_state "$rp" 2>/dev/null || true)"
 printf '%s\n' "$child_rc" > "$RUN/manual.wait.rc" && : > "$RUN/manual.reaped"
}
wait_manual_absent() {
 nabs=0
 while :; do
  existing=$(pidof camera-service 2>/dev/null || true)
  initstate=$(getprop init.svc.camera-service)
  current_start=$(proc_start_raw "$mp" 2>/dev/null || true)
  log "MANUAL_ABSENCE pidof=$existing init=$initstate own_pid=$mp own_start=$ms proc_state=$(proc_state "$mp" 2>/dev/null || true) current_start=$current_start"
  [ -z "$existing" ] && [ "$initstate" = stopped ] && return 0
  [ "$initstate" = stopped ] && [ "$existing" = "$mp" ] || { fail foreign_service_no_overlap; return 1; }
  if [ -n "$current_start" ]; then
   [ "$current_start" = "$ms" ] || { fail retiring_pid_reused; return 1; }
  else
   # pidof may have observed the owned retiring PID immediately before reaping.
   # Missing /proc alone is insufficient: confirm absence/init state anew.
   existing_again=$(pidof camera-service 2>/dev/null || true)
   init_again=$(getprop init.svc.camera-service)
   log "MANUAL_ABSENCE_RECHECK pidof=$existing_again init=$init_again current_start_missing=true"
   [ -z "$existing_again" ] && [ "$init_again" = stopped ] && return 0
   [ "$init_again" = stopped ] && [ "$existing_again" = "$mp" ] || { fail foreign_service_no_overlap; return 1; }
  fi
  nabs=$((nabs+1)); [ "$nabs" -lt 40 ] || { fail manual_pidof_not_absent; return 1; }
  sleep 0.1
 done
}
clone_evidence() {
 awk '
 {
  line=$0
  while ((pos=index(line,"X2V_SOURCE_ADAPTER "))>0) {
   r=substr(line,pos)
   if (r ~ /^X2V_SOURCE_ADAPTER clone_ready build=mode21-c24-direct load_bias=0x[0-9a-fA-F]+ dladdr_mapping=0x[0-9a-fA-F]+ descriptor_bytes=192 mode_count=28 startup_hb_index=23 startup_driver_index=52 candidate_hb_index=24 candidate_driver_index=17 calls=[1-8] hardware_owner=native_init frame_evidence=false($|[^A-Za-z0-9_])/) ready=1
   if (r ~ /^X2V_SOURCE_ADAPTER native_init_end rc=0 fps_guard_commit=0 clone_retained_until_exit=true($|[^A-Za-z0-9_])/) init=1
   if (r ~ /^X2V_SOURCE_ADAPTER reject=/) bad=1
   if (r ~ /^X2V_SOURCE_ADAPTER native_init_end / && r !~ /^X2V_SOURCE_ADAPTER native_init_end rc=0 fps_guard_commit=0 clone_retained_until_exit=true($|[^A-Za-z0-9_])/) bad=1
   line=substr(r,length("X2V_SOURCE_ADAPTER ")+1)
  }
 }
 END { exit !(ready && init && !bad) }
 ' "$RUN/manual-service.log" || { fail target_clone_or_fps_commit_invalid; return 1; }
 : > "$RUN/clone.confirmed" || return 1
 log 'CLONE_CONFIRMED mode_count=28 startup_hb23_driver52 target_hb24_driver17 native_init_rc0 fps_guard_commit0'
}
graph_evidence() {
 awk '
 {
  line=$0
  while ((pos=index(line,"X2V_GRAPH "))>0) {
   r=substr(line,pos)
   if (r ~ /^X2V_GRAPH owned HAL headers installed stage=mode21-c24 profile2_target=1($|[^A-Za-z0-9_])/) getter=1
   if (r ~ /^X2V_GRAPH parser redirect \/(system\/)?etc\/imx861bqr_hb722\.sp -> FD5 independent-open($|[^A-Za-z0-9_])/) sp=1
   if (r ~ /^X2V_GRAPH parser redirect \/(system\/)?etc\/imx861bqr_hb722\.conf -> FD6 independent-open($|[^A-Za-z0-9_])/) conf=1
   if (r ~ /^X2V_GRAPH native_parser_create rc=0 owner_bound=1 role=primary_imx861($|[^A-Za-z0-9_])/) parsed=1
   if (r ~ /^X2V_GRAPH native_aux_parser_create rc=0 owner_bound=1 role=tof_ads6401($|[^A-Za-z0-9_])/) tof=1
   if (r ~ /^X2V_GRAPH native_aux_parser_create / && r !~ /^X2V_GRAPH native_aux_parser_create rc=0 owner_bound=1 role=tof_ads6401($|[^A-Za-z0-9_])/) bad=1
   if (r ~ /^X2V_GRAPH reject / || r ~ /^X2V_GRAPH target blocked entry=/) bad=1
   if (r ~ /^X2V_GRAPH native_parser_create / && r !~ /^X2V_GRAPH native_parser_create rc=0 owner_bound=1 role=primary_imx861($|[^A-Za-z0-9_])/) bad=1
   line=substr(r,length("X2V_GRAPH ")+1)
  }
 }
 END {exit !(getter && sp && conf && parsed && tof && !bad)}
 ' "$RUN/manual-service.log" || { fail target_graph_parser_or_gate_invalid; return 1; }
 : > "$RUN/graph.confirmed" || return 1
 log 'GRAPH_CONFIRMED target_header FD5_sp FD6_conf primary_and_tof_distinct_bound_rc0'
}
target_setup_evidence() {
 # A byte boundary in this owned append-progressing service log limits timing
 # evidence to this setup transaction. Never append a marker through a second FD.
 q_scope && [ -f "$qs_prefix-graph-setup-confirmed" ] && q_owner_same && graph_evidence || return 1
 read off < "$RUN/target.setup-log-offset" || return 1
 case "$off" in ''|*[!0-9]*) return 1;; esac
 [ "$(stat -c %s "$RUN/manual-service.log")" -ge "$off" ] || return 1
 tail -c "+$((off+1))" "$RUN/manual-service.log" | awk '
 {
  line=$0
  while ((pos=index(line,"X2V_SOURCE_FPS "))>0) {
   r=substr(line,pos)
   if (r !~ /^X2V_SOURCE_FPS kind=(prepare|update) hb=24 driver=17 requested=[0-9]+\/[0-9]+ applied=24\/1 frame_evidence=false($|[^A-Za-z0-9_])/) bad=1
   if (r ~ /^X2V_SOURCE_FPS kind=prepare hb=24 driver=17 requested=[0-9]+\/[0-9]+ applied=24\/1 frame_evidence=false($|[^A-Za-z0-9_])/) prepare=1
   line=substr(r,length("X2V_SOURCE_FPS ")+1)
  }
 }
 END {exit !(prepare && !bad)}
 ' || { fail target_prepare_not_confirmed_for_setup; return 1; }
 log 'TARGET_PREPARE_REQUEST_CONFIRMED hb24_driver17_applied24_1; not_measured_fps_or_mcu_ack'
}
graph_state() {
 take_state_snapshot || return 1
 grep -qx 'live_view_state = E_LiveViewState_Off(0)' "$RUN/reply.state" &&
 grep -qx 'liveview_transport_mode_current = E_LiveviewTransportMode_None(0)' "$RUN/reply.state" &&
 grep -qx 'crop_mode_current = E_CropMode_None(0)' "$RUN/reply.state" &&
 grep -Eq '^stream_group = E_StreamGroup_(LiveviewRawCalib\(13\)|Max\(255\))$' "$RUN/reply.state"
}
graph_setup() {
    q_scope || { fail graph_setup_owner; return 1; }
    q_sticky "$qs_prefix-graph-setup" graph_setup_unknown_no_retry || return 1
    [ ! -f "$qs_prefix-graph-setup-confirmed" ] || { fail graph_setup_already_confirmed_no_repeat; return 1; }
    qs_setup_owner=$qs_owner
    quiesce && [ "$qs_owner" = "$qs_setup_owner" ] && graph_evidence && q_owner_same || return 1
    stat -c %s "$RUN/manual-service.log" > "$RUN/target.setup-log-offset" || return 1
    : > "$qs_prefix-graph-setup-intent" || return 1
    # Repeating setup auto-starts. Never issue start_dcam_stream 1 here.
    op setup_dcam_stream_group 13 && wait_idle && graph_state && q_owner_same &&
    grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || {
        fail graph_setup_unknown_no_retry; return 1;
    }
    : > "$qs_prefix-graph-setup-confirmed" || return 1
    phase graph13_auto_started
}

owner_quiesce() {
    q_scope || { fail graph_quiesce_owner; return 1; }
    [ -f "$qs_prefix-graph-setup-intent" ] || { quiesce; return $?; }
    q_sticky "$qs_prefix-graph-setup" graph_setup_unknown_no_retry || return 1
    [ -f "$qs_prefix-graph-setup-confirmed" ] || { fail graph_setup_unconfirmed; return 1; }
    q_sticky "$qs_prefix-color-stop" color_stop_unknown_no_retry || return 1
    q_sticky "$qs_prefix-graph-stop" graph_stop_unknown_no_retry || return 1
    q_sticky "$qs_prefix-graph-teardown" graph_teardown_unknown_no_retry || return 1
    wait_idle && graph_state && q_owner_same || { fail graph_quiesce_unknown; return 1; }
    if grep -qx 'stream_group = E_StreamGroup_Max(255)' "$RUN/reply.state"; then
        # A getter value alone is not the native completion reply.
        [ -f "$qs_prefix-graph-teardown-confirmed" ] || { fail graph_max_without_teardown_completion; return 1; }
        phase graph_quiesced_group255; return $?
    fi
    [ ! -f "$qs_prefix-graph-teardown-confirmed" ] || { fail graph_state_regressed_no_retry; return 1; }
    if [ ! -f "$qs_prefix-color-stop-confirmed" ]; then
        q_owner_same && : > "$qs_prefix-color-stop-intent" || return 1
        op stop_dcam_stream 0 && wait_idle && graph_state && q_owner_same &&
        grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || {
            fail color_stop_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-color-stop-confirmed" || return 1
    fi
    if [ ! -f "$qs_prefix-graph-stop-confirmed" ]; then
        q_owner_same && : > "$qs_prefix-graph-stop-intent" || return 1
        op stop_dcam_stream 1 && wait_idle && graph_state && q_owner_same &&
        grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || {
            fail graph_stop_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-graph-stop-confirmed" || return 1
    fi
    if grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state"; then
        q_owner_same && : > "$qs_prefix-graph-teardown-intent" || return 1
        op teardown_current_dcam_stream_group && wait_idle && graph_state && q_owner_same &&
        grep -qx 'stream_group = E_StreamGroup_Max(255)' "$RUN/reply.state" || {
            fail graph_teardown_unknown_no_retry; return 1;
        }
        : > "$qs_prefix-graph-teardown-confirmed" || return 1
    fi
    grep -qx 'stream_group = E_StreamGroup_Max(255)' "$RUN/reply.state" &&
    [ -f "$qs_prefix-graph-teardown-confirmed" ] || { fail graph_max_without_teardown_completion; return 1; }
    q_owner_same || return 1
    phase graph_quiesced_group255
}

inode_token() {
 [ -f "$1" ] && [ ! -L "$1" ] && [ "$(stat -c %h "$1")" = 1 ] || return 1
 stat -c '%d:%i' "$1"
}
# Embedded CPU/file evidence only. Caller has separately validated RX16 capture.
directory_token() {
 [ -d "$1" ] && [ ! -L "$1" ] || return 1
 stat -c '%d:%i' "$1"
}
directory_empty() (
 [ -d "$1" ] && [ ! -L "$1" ] || exit 1
 set +f
 for entry in "$1"/* "$1"/.[!.]* "$1"/..?*; do
  [ ! -e "$entry" ] && [ ! -L "$entry" ] || exit 1
 done
)
directory_prepared() (
 [ -d "$1" ] && [ ! -L "$1" ] || exit 1
 set +f
 jsonl=;mov=
 for entry in "$1"/* "$1"/.[!.]* "$1"/..?*; do
  if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then continue; fi
  case "${entry##*/}" in
   clip.partial.jsonl) jsonl=$entry;;
   clip.partial.mov) mov=$entry;;
   *) exit 1;;
  esac
 done
 [ -n "$jsonl" ] && [ -n "$mov" ] || exit 1
 [ -f "$jsonl" ] && [ ! -L "$jsonl" ] && [ "$(stat -c %h "$jsonl")" = 1 ] || exit 1
 [ -f "$mov" ] && [ ! -L "$mov" ] && [ "$(stat -c %h "$mov")" = 1 ] || exit 1
 identity=$(stat -c '%d:%i:%h:%s' "$jsonl") || exit 1
 header=;extra=
 { IFS= read -r header && ! IFS= read -r extra && [ -z "$extra" ]; } < "$jsonl" || exit 1
 [ "$(stat -c '%d:%i:%h:%s' "$jsonl")" = "$identity" ] &&
 [ "$header" = '{"kind":"PRORES_RAW_HQ_MOV","version":1,"width":3888,"height":2912,"source_width":3920,"source_height":2946,"source_stride":7936,"fourcc":"aprh","profile":"HQ","calibrated":false}' ]
)
bind_prepared_manifest() {
 directory_prepared "$CLIP_DIR" || return 1
 manifest_identity=$(inode_token "$CLIP_DIR/clip.partial.jsonl") || return 1
 manifest_pin=$RUN/dng$CLIP_SUFFIX.manifest.inode
 if [ -e "$manifest_pin" ] || [ -L "$manifest_pin" ]; then
  [ -f "$manifest_pin" ] && [ ! -L "$manifest_pin" ] && [ "$(cat "$manifest_pin")" = "$manifest_identity" ] || return 1
 else
  (umask 077; set -C; printf '%s\n' "$manifest_identity" > "$manifest_pin") || return 1
 fi
 [ "$(inode_token "$CLIP_DIR/clip.partial.jsonl")" = "$manifest_identity" ]
}
wait_directory_prepared() {
 prepared_until=$(( $(uptime_seconds)+8 ))
 while ! directory_prepared "$CLIP_DIR"; do
  gate && match_service && receiver_inodes && [ ! -f "$RUN/receiver.cancel-intent" ] &&
  [ "$(stat -c %s "$CLIP_RECEIPT")" = 0 ] || return 1
  [ "$(uptime_seconds)" -lt "$prepared_until" ] || return 1
  sleep 0.1
 done
}
dng_inventory() (
 [ -d "$CLIP_DIR" ] && [ ! -L "$CLIP_DIR" ] || exit 1
 set +f
 for entry in "$CLIP_DIR"/* "$CLIP_DIR"/.[!.]* "$CLIP_DIR"/..?*; do
  if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then continue; fi
  [ -f "$entry" ] && [ ! -L "$entry" ] || exit 1
  case "${entry##*/}" in clip.jsonl|clip.mov) ;; *) exit 1;; esac
 done
 [ -f "$CLIP_DIR/clip.jsonl" ] && [ ! -L "$CLIP_DIR/clip.jsonl" ] || exit 1
 [ -f "$CLIP_DIR/clip.mov" ] && [ ! -L "$CLIP_DIR/clip.mov" ] || exit 1
 stat -c '%d:%i:%h:%s:%n' "$CLIP_DIR/clip.jsonl" "$CLIP_DIR/clip.mov"
)
dng_directory_verified() (
 before=$(directory_token "$CLIP_DIR") || exit 1
 [ "$(inode_token "$CLIP_DIR/clip.jsonl")" = "$(cat "$RUN/dng$CLIP_SUFFIX.manifest.inode")" ] || exit 1
 dng_inventory > "$RUN/dng$CLIP_SUFFIX.inventory-before" || exit 1
 manifest_hash=$(sha256sum "$CLIP_DIR/clip.jsonl") || exit 1
 manifest_hash=${manifest_hash%% *}
 awk -v dir="$CLIP_DIR" '
 function fail() {bad=1}
 function pairs(line, dest, n,a,i,k,p) {
  if(substr(line,1,1)!="{" || substr(line,length(line),1)!="}")return 0
  n=split(substr(line,2,length(line)-2),a,",")
  for(i=1;i<=n;i++) {p=index(a[i],":");k=substr(a[i],2,p-3);if(k in dest)return 0;dest[k]=substr(a[i],p+1)}
  return n
 }
 BEGIN {
  u="(0|[1-9][0-9]*)"
  frame="^\\{\"index\":" u ",\"file\":\"clip[.]mov\",\"source_id\":" u ",\"native_timestamp_raw\":" u ",\"cpu_admission_ns\":" u ",\"write_begin_ns\":" u ",\"pwrite_end_ns\":" u ",\"write_end_ns\":" u ",\"fsync_begin_ns\":" u ",\"fsync_end_ns\":" u ",\"file_bytes\":" u ",\"pixel_bytes\":22643712,\"mov_offset\":" u ",\"file_fsync\":true,\"file_published\":true,\"namespace_durable\":false,\"native_metadata_hex_v1\":\"[0-9a-f]+\"\\}$"
  head="{\"kind\":\"PRORES_RAW_HQ_MOV\",\"version\":1,\"width\":3888,\"height\":2912,\"source_width\":3920,\"source_height\":2946,\"source_stride\":7936,\"fourcc\":\"aprh\",\"profile\":\"HQ\",\"calibrated\":false}"
 }
 FILENAME==ARGV[1] {
  if(FNR!=1){fail();next}
  n=split($0,a,",");for(i=1;i<=n;i++){p=index(a[i],":");k=substr(a[i],2,p-3);v[k]=substr(a[i],p+1)}
  count=v["frames_copied"]+0
  if(count<2 || count>240 || v["version"]!=16 || v["dng_published_frames"]!=count)fail()
  next
 }
 FILENAME==ARGV[2] {
  manifest_lines++
  if(FNR==1){if($0!=head)fail();next}
  if(FNR<=count+1) {
   for(oldkey in row)delete row[oldkey]
   if($0 !~ frame || pairs($0,row)!=17){fail();next}
   if(length(row["native_metadata_hex_v1"])!=1058 || substr(row["native_metadata_hex_v1"],2,32)!="584d443101000d001002000000000000")fail()
   j=FNR-2
   if(row["index"]!=j || row["file"]!="\"clip.mov\"" || row["source_id"]!=v["frame" j "_id"] || row["native_timestamp_raw"]!=v["frame" j "_timestamp_native"] || row["cpu_admission_ns"]!=v["frame" j "_admission_ns"])fail()
   if(row["write_begin_ns"]+0 < v["frame" j "_write_begin_ns"]+0 || row["pwrite_end_ns"]+0 != v["frame" j "_pwrite_end_ns"]+0 || row["pwrite_end_ns"]+0 < row["write_begin_ns"]+0)fail()
   if(row["fsync_begin_ns"]+0 < v["frame" j "_complete_begin_ns"]+0 || row["fsync_end_ns"]+0 > v["frame" j "_complete_end_ns"]+0 || row["fsync_end_ns"]+0 < row["fsync_begin_ns"]+0 || row["write_end_ns"]+0 != row["fsync_end_ns"]+0)fail()
   if(v["frame" j "_submitted"]!=1 || v["frames_submitted"]!=count || v["dng_join_failed"]!=0)fail()
   fb=row["file_bytes"]+0
   if(fb<152 || fb>16777216 || fb!=v["frame" j "_bytes"]+0)fail()
   encoded+=fb
   next
  }
  if(FNR!=count+2 || $0!="{\"end\":true,\"published_frames\":" count ",\"submitted_frames\":" count ",\"bytes_written\":" encoded ",\"error\":0}")fail()
  if(v["bytes_written"]+0!=encoded)fail()
  next
 }
 FILENAME==ARGV[3] {
  if(split($0,a,":")!=5 || a[1]!~/^[0-9]+$/ || a[2]!~/^[0-9]+$/ || a[3]!=1 || a[4]!~/^[0-9]+$/ || substr(a[5],1,length(dir)+1)!=dir "/"){fail();next}
  name=substr(a[5],length(dir)+2)
  if(seen[name]++ || inode[a[1] ":" a[2]]++)fail()
  if(name=="clip.jsonl"){if(a[4]+0<=0 || a[4]+0>1048576)fail();manifest_seen++}
  else if(name=="clip.mov"){if(a[4]+0<=encoded || a[4]+0>encoded+16777216)fail();files++}
  else fail()
 }
 END {exit !(count>=2 && !bad && manifest_lines==count+2 && manifest_seen==1 && files==1)}
 ' "$CLIP_RECEIPT" "$CLIP_DIR/clip.jsonl" "$RUN/dng$CLIP_SUFFIX.inventory-before" || exit 1
 dng_inventory > "$RUN/dng$CLIP_SUFFIX.inventory-after" || exit 1
 cmp -s "$RUN/dng$CLIP_SUFFIX.inventory-before" "$RUN/dng$CLIP_SUFFIX.inventory-after" || exit 1
 after_hash=$(sha256sum "$CLIP_DIR/clip.jsonl") || exit 1
 [ "${after_hash%% *}" = "$manifest_hash" ] && [ "$(directory_token "$CLIP_DIR")" = "$before" ] &&
 [ "$(inode_token "$CLIP_DIR/clip.jsonl")" = "$(cat "$RUN/dng$CLIP_SUFFIX.manifest.inode")" ] &&
 cp "$CLIP_DIR/clip.jsonl" "$RUN/dng$CLIP_SUFFIX.metadata.jsonl"
)


select_clip() {
 case "$1" in
  1) CLIP_GEN=1; CLIP_SUFFIX=; CLIP_START=A; CLIP_STOP=S;;
  2) CLIP_GEN=2; CLIP_SUFFIX=2; CLIP_START=B; CLIP_STOP=T;;
  *) return 1;;
 esac
 CLIP_DIR=$BULK/dng$CLIP_SUFFIX
 CLIP_RAW=$CLIP_DIR # compatibility variable for identity/cache only; never a RAW file
 CLIP_RECEIPT=$RUN/receiver$CLIP_SUFFIX.receipt
 CLIP_RAW_PIN=$RUN/raw$CLIP_SUFFIX.inode
 CLIP_ACK_PIN=$RUN/receipt$CLIP_SUFFIX.inode
}
receiver_inodes() {
 [ "$(directory_token "$CLIP_RAW")" = "$(cat "$CLIP_RAW_PIN")" ] &&
 [ "$(inode_token "$RUN/receiver.command")" = "$(cat "$RUN/command.inode")" ] &&
 [ "$(inode_token "$CLIP_RECEIPT")" = "$(cat "$CLIP_ACK_PIN")" ] &&
 [ "$(stat -c %s "$RUN/receiver.command")" = 1 ]
}
receiver_all_inodes() (
 select_clip 1 && receiver_inodes && select_clip 2 && receiver_inodes
)
prepare_receiver() {
 [ -d /mnt/media_rw/ssd ] && [ ! -L /mnt/media_rw/ssd ] || return 1
 [ ! -L "$BULK_ROOT" ] && mkdir -p "$BULK_ROOT/runs" && [ ! -L "$BULK_ROOT/runs" ] || return 1
 (umask 077; mkdir "$BULK" && mkdir "$BULK/dng" "$BULK/dng2") || return 1
 (umask 077; set -C; printf 0 > "$RUN/receiver.command" && : > "$RUN/receiver.receipt" && : > "$RUN/receiver2.receipt") || return 1
 directory_token "$BULK/dng" > "$RUN/raw.inode" && directory_token "$BULK/dng2" > "$RUN/raw2.inode" &&
 inode_token "$RUN/receiver.command" > "$RUN/command.inode" && inode_token "$RUN/receiver.receipt" > "$RUN/receipt.inode" &&
 inode_token "$RUN/receiver2.receipt" > "$RUN/receipt2.inode" || return 1
 printf '%s\n' "$(cat "$RUN/raw.inode")" "$(cat "$RUN/raw2.inode")" "$(cat "$RUN/command.inode")" \
  "$(cat "$RUN/receipt.inode")" "$(cat "$RUN/receipt2.inode")" |
  awk 'NF!=1||seen[$0]++ {bad=1} END{exit !(NR==5&&!bad)}' || return 1
 directory_empty "$BULK/dng" && directory_empty "$BULK/dng2" &&
 [ "$(stat -c %s "$RUN/receiver.receipt")" = 0 ] && [ "$(stat -c %s "$RUN/receiver2.receipt")" = 0 ] && receiver_all_inodes
}
receipt_validate_uncached() {
 receiver_inodes || return 1
 case "${1:-0}" in 0|1) ;; *) return 1;; esac
 timeout 4 "$RECEIPT_VALIDATOR" --expected-generation "$CLIP_GEN" --require-frame "${1:-0}" < "$CLIP_RECEIPT" > /dev/null
}

# Source after original receipt_valid is renamed receipt_validate_uncached.
# Original strict AWK stays byte-identical. In-memory cache, local to one shell.
# Assumes the controller's exclusive writer/immutable terminal receipt contract.
# No cache of closure-only, partial, malformed, failed or unstable validation.
# Same single-link/pinned-inode/length predicate, one multi-file stat per pass.
# All pathname/pin parsing below uses shell builtins; only stat and sha256 spawn.
receipt_cache_stat() (
 for file in "$CLIP_RAW" "$RUN/receiver.command" "$CLIP_RECEIPT"; do
  if [ "$file" = "$CLIP_RAW" ]; then directory_token "$file" >/dev/null || exit 1;
  else [ -f "$file" ] && [ ! -L "$file" ] || exit 1; fi
 done
 rows=$(stat -c '%d:%i:%h:%s' "$CLIP_RAW" "$RUN/receiver.command" "$CLIP_RECEIPT") || exit 1
 set -f
 oldifs=$IFS; IFS=' 	
'; set -- $rows; IFS=$oldifs
 [ "$#" = 3 ] || exit 1
 raw_row=$1; command_row=$2; receipt_row=$3
 for kind in raw command receipt; do
  case "$kind" in raw) row=$raw_row;; command) row=$command_row;; receipt) row=$receipt_row;; esac
  case "$row" in ''|*[!0-9:]*) exit 1;; esac
  d=${row%%:*}; rest=${row#*:}; [ "$rest" != "$row" ] || exit 1
  i=${rest%%:*}; rest2=${rest#*:}; [ "$rest2" != "$rest" ] || exit 1
  h=${rest2%%:*}; size=${rest2#*:}; [ "$size" != "$rest2" ] || exit 1
  case "$d:$i:$size" in *::*|:*|*:|*[!0-9:]*) exit 1;; esac
  case "$size" in ''|*[!0-9]*) exit 1;; esac
  if [ "$kind" = raw ]; then case "$h" in ''|*[!0-9]*) exit 1;; esac; [ "$h" -ge 1 ] || exit 1;
  else [ "$h" = 1 ] || exit 1; fi
  pin=; extra=
  case "$kind" in raw) pin_path=$CLIP_RAW_PIN;; command) pin_path=$RUN/command.inode;; receipt) pin_path=$CLIP_ACK_PIN;; esac
  { IFS= read -r pin && ! IFS= read -r extra && [ -z "$extra" ]; } < "$pin_path" || exit 1
  [ "$pin" = "$d:$i" ] || exit 1
  if [ "$kind" = command ]; then [ "$size" = 1 ] || exit 1; fi
 done
 printf '%s %s %s\n' "$raw_row" "$command_row" "$receipt_row"
)
receipt_cache_snapshot() (
 rcs_before=$(receipt_cache_stat) || exit 1
 rcs_hash=$(sha256sum "$CLIP_RECEIPT") || exit 1
 rcs_hash=${rcs_hash%% *}
 case "$rcs_hash" in ''|*[!0-9a-f]*) exit 1;; esac
 [ "${#rcs_hash}" -eq 64 ] || exit 1
 rcs_after=$(receipt_cache_stat) || exit 1
 [ "$rcs_before" = "$rcs_after" ] || exit 1
 printf '%s %s\n' "$rcs_before" "$rcs_hash"
)
receipt_valid() {
 typeset rcv_require=${1:-0} rcv_context rcv_before rcv_after
 case "$rcv_require" in 0|1) ;; *) return 1;; esac
 rcv_context="${RUN}|${BULK}|${ID}|${nonce-}|${CLIP_GEN}|${CLIP_RAW}|${CLIP_RECEIPT}"
 rcv_before=$(receipt_cache_snapshot) || return 1
 if [ "${RECEIPT_SUCCESS_CONTEXT-}" = "$rcv_context" ] &&
    [ "${RECEIPT_SUCCESS_SNAPSHOT-}" = "$rcv_before" ]; then
  rcv_after=$(receipt_cache_snapshot) || return 1
  [ "$rcv_after" = "$rcv_before" ] && return 0
  RECEIPT_SUCCESS_CONTEXT=; RECEIPT_SUCCESS_SNAPSHOT=
  return 1
 fi
 RECEIPT_SUCCESS_CONTEXT=; RECEIPT_SUCCESS_SNAPSHOT=
 if receipt_validate_uncached 1; then
  rcv_after=$(receipt_cache_snapshot) || return 1
  [ "$rcv_after" = "$rcv_before" ] &&
  [ "$rcv_context" = "${RUN}|${BULK}|${ID}|${nonce-}|${CLIP_GEN}|${CLIP_RAW}|${CLIP_RECEIPT}" ] || return 1
  RECEIPT_SUCCESS_CONTEXT=$rcv_context
  RECEIPT_SUCCESS_SNAPSHOT=$rcv_after
  return 0
 fi
 [ "$rcv_require" = 0 ] || return 1
 receipt_validate_uncached 0
}

receiver_cancel() {
 : > "$RUN/receiver.cancel-intent" || return 1
 receiver_all_inodes || { fail receiver_inode_changed; return 1; }
 if printf D 1<> "$RUN/receiver.command"; then cancel_rc=0; else cancel_rc=$?; fi
 log "RECEIVER_CANCEL_WRITE rc=$cancel_rc"
 [ "$cancel_rc" -eq 0 ] || return 1
 receiver_all_inodes && [ "$(cat "$RUN/receiver.command")" = D ]
}
receiver_drain() {
 receiver_cancel || return 1
 drain_until=$(( $(uptime_seconds)+25 ))
 for drain_generation in 1 2; do
  select_clip "$drain_generation" || return 1
  while ! receipt_valid 0; do
   gate && match_service || return 1
   [ "$(uptime_seconds)" -lt "$drain_until" ] || { fail receiver_cpu_ack_unknown_no_term; return 1; }
   sleep 0.1
  done
  log "RECEIVER_CPU_DRAIN_ACK generation=$CLIP_GEN scope=receiver_cpu_drain; not_native_dma_drain"
 done
}
receiver_arm() {
 select_clip 1 || return 1
 gate && match_service && receiver_inodes || return 1
 [ ! -f "$RUN/receiver.cancel-intent" ] && [ ! -f "$RUN/receiver.arm-intent" ] &&
 [ "$(cat "$RUN/receiver.command")" = 0 ] && [ "$(stat -c %s "$CLIP_RECEIPT")" = 0 ] &&
 bind_prepared_manifest || { fail receiver_not_waiting; return 1; }
 # Reuse the just-completed native setup ACK; no extra settling delay.
 q_scope && [ -f "$qs_prefix-graph-setup-confirmed" ] && q_owner_same &&
 grep -qx 'live_view_state = E_LiveViewState_Off(0)' "$RUN/reply.state" &&
 grep -qx 'liveview_transport_mode_current = E_LiveviewTransportMode_None(0)' "$RUN/reply.state" &&
 grep -qx 'crop_mode_current = E_CropMode_None(0)' "$RUN/reply.state" &&
 grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || return 1
 # Both the three prefaulted CPU slots and native target buffers exist now.
 # Keep 128 MiB available; low or unreadable memory means no arm, normal drain.
 cat /proc/meminfo > "$RUN/target-meminfo-before-arm" || return 1
 available=$(awk '$1=="MemAvailable:" && $2~/^[0-9]+$/ && $3=="kB" && NF==3 {n++;v=$2} END {if(n==1)print v;else exit 1}' "$RUN/target-meminfo-before-arm") || { fail target_memory_unknown; return 1; }
 case "$available" in ''|*[!0-9]*) fail target_memory_unknown; return 1;; esac
 [ "$available" -ge 131072 ] || { fail target_memory_reserve_low_no_arm; return 1; }
 log "TARGET_MEMORY_BEFORE_ARM available_kib=$available minimum_kib=131072"
 # Receiver has a fixed ~47s constructor polling budget. Launch precedes it;
 # this conservative gate leaves >=23s for10s capture and existing CPU drain.
 read launch_time < "$RUN/receiver.launch-uptime" || return 1
 case "$launch_time" in ''|*[!0-9]*) return 1;; esac
 arm_now=$(uptime_seconds)
 [ "$arm_now" -ge "$launch_time" ] && [ "$((arm_now-launch_time))" -le 24 ] || { fail receiver_arm_budget_exhausted; return 1; }
 df -k /mnt/media_rw/ssd > "$RUN/ssd-space.before-arm" || return 1
 awk 'NR==2 {good=(NF>=6 && $4 ~ /^[0-9]+$/ && $4>=12582912)} END{exit !good}' "$RUN/ssd-space.before-arm" || { fail target_storage_reserve_low_no_arm; return 1; }
 : > "$RUN/receiver.arm-intent" || return 1
 gate && match_service && [ ! -f "$RUN/receiver.cancel-intent" ] && receiver_inodes || return 1
 printf A 1<> "$RUN/receiver.command" || return 1
 [ "$(cat "$RUN/receiver.command")" = A ] || return 1
 log RECEIVER_EXPLICIT_ARM_AFTER_GRAPH13_SETUP_ACK
}
receiver_user_stop_trial() {
 if [ -f "$RUN/product.mode" ]; then
  n=0
  while [ "$n" -lt 80 ] && [ ! -f /blackbox/x2v-native-20261011/rec/user-stop ]; do
   n=$((n+1)); sleep 0.1
  done
 else
  sleep 2
 fi
 gate && match_service && receiver_inodes || return 1
 [ -f "$RUN/receiver$CLIP_SUFFIX.arm-intent" ] && [ ! -f "$RUN/receiver.cancel-intent" ] &&
 [ "$(cat "$RUN/receiver.command")" = "$CLIP_START" ] || { fail receiver_not_recording_for_user_stop; return 1; }
 : > "$RUN/receiver$CLIP_SUFFIX.stop-intent" || return 1
 printf '%s' "$CLIP_STOP" 1<> "$RUN/receiver.command" || return 1
 receiver_inodes && [ "$(cat "$RUN/receiver.command")" = "$CLIP_STOP" ] || return 1
 log "RECEIVER_EXPLICIT_USER_STOP_GEN$CLIP_GEN command=$CLIP_STOP"
}
receiver_arm_second() {
 # Only one source owner/graph; ACK1 has been strictly validated and sealed.
 select_clip 1 && receipt_valid 1 && [ -f "$RUN/receiver.confirmed" ] || return 1
 select_clip 2 && wait_directory_prepared || return 1
 gate && match_service && receiver_all_inodes && [ ! -f "$RUN/receiver.cancel-intent" ] &&
 [ ! -f "$RUN/receiver2.arm-intent" ] && [ "$(cat "$RUN/receiver.command")" = S ] &&
 bind_prepared_manifest && [ "$(stat -c %s "$CLIP_RECEIPT")" = 0 ] || return 1
 wait_idle && graph_state && q_scope && q_owner_same &&
 grep -qx 'stream_group = E_StreamGroup_LiveviewRawCalib(13)' "$RUN/reply.state" || return 1
 read second_launch < "$RUN/receiver.launch-uptime" || return 1
 case "$second_launch" in ''|*[!0-9]*) return 1;; esac
 second_now=$(uptime_seconds)
 [ "$second_now" -ge "$second_launch" ] && [ "$((second_now-second_launch))" -le 34 ] || { fail second_clip_source_budget_exhausted; return 1; }
 df -k /mnt/media_rw/ssd > "$RUN/ssd-space.before-arm2" || return 1
 awk 'NR==2 {good=(NF>=6 && $4 ~ /^[0-9]+$/ && $4>=7340032)} END{exit !good}' "$RUN/ssd-space.before-arm2" || return 1
 : > "$RUN/receiver2.arm-intent" || return 1
 gate && match_service && receiver_all_inodes && [ ! -f "$RUN/receiver.cancel-intent" ] || return 1
 printf B 1<> "$RUN/receiver.command" || return 1
 [ "$(cat "$RUN/receiver.command")" = B ] || return 1
 log RECEIVER_EXPLICIT_ARM_SECOND_GENERATION
}
receiver_config_applied() {
 # Caller has confirmed complete safe CPU closure and strict v16 generation-bound DNG capture.
 # Configuration evidence is NOT a CPU/DMA-drain predicate.
 receiver_inodes || return 1
 awk '
 function val(key) {return key in v ? v[key] : -9007199254740991}
 NR==1 {
  n=split($0,a,",")
  for(i=1;i<=n;i++)if(a[i] ~ /^"(frames_copied|frame[0-9]+_(mem_flags_rc|mem_flags|mem_fd_rc))":-?[0-9]+$/){
   at=index(a[i],":"); key=substr(a[i],2,at-3);v[key]=substr(a[i],at+1)+0
  }
  count=val("frames_copied");if(count<2 || count>240)bad=1
  for(j=0;j<count;j++) {
   k="frame" j "_"
   if(val(k"mem_flags_rc")!=0 || val(k"mem_flags")!=17 || val(k"mem_fd_rc")!=0)bad=1
  }
  good=1
 }
 NR!=1 {bad=1}
 END {exit !(good && !bad)}
 ' "$CLIP_RECEIPT"
}

receiver_frame() {
 frame_until=$(( $(uptime_seconds)+20 ))
 # Wait for a complete CPU terminal receipt before deciding frame success.
 # A newly published success must not be mistaken for failure on a second read.
 while ! receipt_valid 0; do
  gate && match_service || return 1
  [ "$(uptime_seconds)" -lt "$frame_until" ] || { fail receiver_ring_not_observed; return 1; }
  sleep 0.1
 done
 receipt_valid 1 || { fail receiver_terminal_without_frame; return 1; }
 grep -q '"stop_reason":6,' "$CLIP_RECEIPT" || { fail receiver_user_stop_not_observed; return 1; }
 log "RECEIVER_CAPTURE_VERIFIED_V16_PRR_ACK_GEN$CLIP_GEN"
 receiver_config_applied || { fail receiver_config_flags17_not_observed; return 1; }
 log "RECEIVER_CONFIG_FLAGS17_CONFIRMED_GEN$CLIP_GEN"
 receiver_inodes && dng_directory_verified && receiver_inodes || { fail receiver_dng_manifest_or_directory; return 1; }
 : > "$RUN/receiver$CLIP_SUFFIX.confirmed" || return 1
 log "RECEIVER_DNG_DIRECTORY_VERIFIED_GEN$CLIP_GEN format=PRORES_RAW_HQ_MOV file=clip.mov encoded_max=16777216 source_span=23379456"
 log RECEIVER_BULK_HASH_SKIPPED_DIRECTORY_INODE_MANIFEST_FSYNC_ACK_PRESERVED

}

recover() (
 RECOVERING=1
 unset LD_PRELOAD LD_LIBRARY_PATH X2V_SOURCE_ADAPTER X2V_RECEIVER_ONESHOT X2V_OWNED_RAW_GRAPH
 owned || { [ -f "$RUN/restored" ]; exit $?; }
 lock_recovery || exit 1
 trap 'recover_rc=$?; exec 9>&-; exit "$recover_rc"' EXIT
 owned || { [ -f "$RUN/restored" ]; exit $?; }
 : > "$RUN/abort" || exit 1
 phase recovering
 # A live owned child must be normally torn down before TERM, never blind KILL.
 mp=; ms=; read mp ms < "$RUN/manual.identity" 2>/dev/null || true
 if valid_pid "$mp" && alive "$mp" "$ms"; then
  owned_member "$mp" "$ms" || { fail manual_cgroup_changed; exit 1; }
  mexe=$(proc_exe "$mp")
  if [ "$mexe" = "$SERVICE" ]; then
  printf '%s %s\n' "$mp" "$ms" > "$RUN/active-service.identity" || exit 1
  cp "$RUN/owner.group" "$RUN/active-service.group" || exit 1
  receiver_drain && owner_quiesce || { fail manual_pending_no_kill; exit 1; }
  elif [ "$mexe" = "$(cat "$RUN/manual-shell.exe" 2>/dev/null || true)" ] && { [ ! -f "$RUN/launch" ] || [ -z "$(pidof camera-service 2>/dev/null || true)" ]; }; then
   log GATED_MANUAL_SHELL_CANCELLED
  else fail manual_identity_changed; exit 1; fi
  kill -TERM "$mp" || exit 1
  n=0; while alive "$mp" "$ms"; do n=$((n+1)); [ "$n" -lt 40 ] || { fail manual_survived_term; exit 1; }; sleep 0.1; done
 fi
 # Pre-launch failure: owned waiting child was cancelled above, stock untouched.
 if [ ! -f "$RUN/native-intent" ]; then
  : > "$RUN/restored" && release_locks; exit $?
 fi
 original_still_running=0
 if [ ! -f "$RUN/launch" ] && [ "$(getprop init.svc.camera-service)" = running ]; then
  read osp oss < "$RUN/original-service.identity" || exit 1
  alive "$osp" "$oss" && [ "$(pidof camera-service)" = "$osp" ] &&
  [ "$(proc_exe "$osp")" = "$SERVICE" ] && [ "$(proc_group "$osp")" = "$(cat "$RUN/original-service.group")" ] || { fail foreign_service_no_overlap; exit 1; }
  original_still_running=1
 fi
 if [ -f "$RUN/service-stop-intent" ] && [ "$original_still_running" = 0 ] && [ ! -f "$RUN/restored-service.identity" ] && valid_pid "$mp"; then
  wait_manual_absent || exit 1
 fi
 if [ -f "$RUN/service-stop-intent" ]; then
  if [ -f "$RUN/restored-service.identity" ]; then
   cp "$RUN/restored-service.identity" "$RUN/active-service.identity" || exit 1
   read rp rs < "$RUN/restored-service.identity"
   rg=$(proc_group "$rp")
   [ "$rg" = "/uid_0/pid_$rp" ] || { fail restored_service_cgroup; exit 1; }
   printf '%s\n' "$rg" > "$RUN/active-service.group" || exit 1
   match_service || { fail restored_service_changed; exit 1; }
  elif [ "$original_still_running" = 1 ]; then
   cp "$RUN/original-service.identity" "$RUN/active-service.identity" && cp "$RUN/original-service.group" "$RUN/active-service.group" || exit 1
   match_service || { fail foreign_service_no_overlap; exit 1; }
   log ORIGINAL_SERVICE_STILL_RUNNING_STOP_DID_NOT_COMPLETE
  else
   [ -z "$(pidof camera-service 2>/dev/null || true)" ] &&
   [ "$(getprop init.svc.camera-service)" = stopped ] || { fail foreign_service_no_overlap; exit 1; }
   : > "$RUN/service-restore-intent" || exit 1
   setprop ctl.start camera-service 9>&- || exit 1
   n=0
   while ! identity camera-service > "$RUN/restored-service.identity.tmp" || [ "$(getprop init.svc.camera-service)" != running ]; do
    n=$((n+1)); [ "$n" -lt 40 ] || { fail init_service_start; exit 1; }; sleep 0.1
   done
   mv "$RUN/restored-service.identity.tmp" "$RUN/restored-service.identity" || exit 1
   cp "$RUN/restored-service.identity" "$RUN/active-service.identity" || exit 1
   read rp rs < "$RUN/restored-service.identity"
   rg=$(proc_group "$rp")
   [ "$rg" = "/uid_0/pid_$rp" ] || { fail restored_service_cgroup; exit 1; }
   printf '%s\n' "$rg" > "$RUN/active-service.group" || exit 1
  fi
 else
  cp "$RUN/original-service.identity" "$RUN/active-service.identity" && cp "$RUN/original-service.group" "$RUN/active-service.group" || exit 1
 fi
 wait_ready && normal_start && frames_advance || { fail normal_restore_not_ready; exit 1; }
 if [ -f "$RUN/gui-stop-intent" ]; then
  gs=$(getprop init.svc.camera-gui); gp=$(pidof camera-gui 2>/dev/null || true)
  if [ "$gs" = stopped ] && [ -z "$gp" ]; then
   setprop ctl.start camera-gui 9>&- || exit 1
  elif [ "$gs" = running ]; then
   if [ -f "$RUN/restored-gui.identity" ]; then read gp0 gs0 < "$RUN/restored-gui.identity"; else read gp0 gs0 < "$RUN/original-gui.identity"; fi
   alive "$gp0" "$gs0" && [ "$gp" = "$gp0" ] && [ "$(proc_exe "$gp0")" = "$GUI" ] || { fail foreign_gui; exit 1; }
  else fail foreign_gui; exit 1; fi
  n=0
  while [ "$(getprop init.svc.camera-gui)" != running ] || ! identity camera-gui > "$RUN/restored-gui.identity"; do
   n=$((n+1)); [ "$n" -lt 40 ] || { fail init_gui_start; exit 1; }; sleep 0.1
  done
  read gp0 gs0 < "$RUN/restored-gui.identity" || exit 1
  [ "$(proc_exe "$gp0")" = "$GUI" ] && [ "$(proc_group "$gp0")" = "/uid_0/pid_$gp0" ] || { fail restored_gui_identity; exit 1; }
 fi
 wait_idle && normal_state && grep -qx 'live_view_state = E_LiveViewState_Active(1)' "$RUN/reply.state" && grep -qx 'stream_group = E_StreamGroup_Still16bit(0)' "$RUN/reply.state" || { fail final_normal_state; exit 1; }
 phase restored
 : > "$RUN/restored" && release_locks || exit 1
 log NORMAL_STOCK_RESTORED
)

case "${1:-}" in
 '') ;; # Default offline message remains callable on the host.
 *) [ "$(cat /proc/self/attr/current 2>/dev/null)" = u:r:hbl_camera_service:s0 ] || { echo native_visibility_domain_required >&2; exit 2; };;
esac
case "${1:-}" in
 '') echo 'OFFLINE: fixed target mode21 group13 DNG bounded ring240 only; root review then --execute-isolated-two-prr-async RUNID (150s native watchdog; data-only ADB observer)'; exit 0;;
 --execute-isolated-two-prr-async) MODE=execute-isolated-two-prr-async; shift;;
 --child|--watchdog|--recover) MODE=${1#--}; shift;;
 *) echo 'unsupported action: isolated-two-prr-async only' >&2; exit 2;;
esac
[ "$#" -eq 1 ] && valid_id "$1" || exit 2
ID=$1; RUN=$ROOT/runs/$ID; BULK=$BULK_ROOT/runs/$ID; RECOVERING=0; LOCK_HELD=0
select_clip 1 || exit 2
[ -d "$ROOT" ] && [ ! -L "$ROOT" ] && [ ! -L "$ROOT/runs" ] && [ -d "$RUN" ] && [ ! -L "$RUN" ] || exit 2
[ -z "$(find "$RUN" -type l -print)" ] || exit 2
if [ "$MODE" != execute-isolated-two-prr-async ]; then
 OWNER=$(cat "$RUN/session.owner") || exit 3
 if [ "$MODE" = recover ]; then
  : > "$RUN/abort" || exit 3
  read oi op os < "$RUN/session.owner" || exit 3
  if owned && alive "$op" "$os"; then kill -TERM "$op" 2>/dev/null || true; fi
  recover; exit $?
 fi
 if [ "$MODE" = watchdog ]; then
  owned_member "$$" "$(proc_start $$)" || exit 3
  : > "$RUN/watchdog.ready" || exit 3
  read oi op os < "$RUN/session.owner" || exit 3
  deadline=$(cat "$RUN/deadline") || exit 3
  while owned && [ ! -f "$RUN/restored" ]; do
   if ! alive "$op" "$os" || [ "$(uptime_seconds)" -ge "$deadline" ]; then
    : > "$RUN/abort" || exit 3
    if alive "$op" "$os"; then kill -TERM "$op" 2>/dev/null || true; fi
    recover; exit $?
   fi
   sleep 1
  done
  exit 0
 fi
 : > "$RUN/child.ready" || exit 3
 n=0
 while [ ! -f "$RUN/launch" ]; do
  gate || exit 3; n=$((n+1)); [ "$n" -lt 900 ] || exit 3; sleep 0.1
 done
 gate && owned_member "$$" "$(proc_start $$)" &&
 [ -z "$(pidof camera-service 2>/dev/null || true)" ] && [ "$(getprop init.svc.camera-service)" = stopped ] || exit 3
 unset LD_PRELOAD LD_LIBRARY_PATH X2V_SOURCE_ADAPTER X2V_RECEIVER_ONESHOT X2V_OWNED_RAW_GRAPH
 verify_hash /system/lib64/libdcam_base.so 8486fa7ce0b400992358ad92c445ad026a3784703accf2bae8a490ed10b2ff52 && verify_hash "$RECEIPT_VALIDATOR" "$RECEIPT_VALIDATOR_SHA" && verify_hash "$SP" "$SP_SHA" && verify_hash "$CONF" "$CONF_SHA" && verify_hash "$RCAM" "$RCAM_SHA" && verify_hash "$RECEIVER" "$RECEIVER_SHA" && verify_hash "$HAL" "$HAL_SHA" && verify_hash "$FRWK" "$FRWK_SHA" || exit 4
 receiver_all_inodes && directory_empty "$BULK/dng" && directory_empty "$BULK/dng2" &&
 [ "$(stat -c %s "$RUN/receiver.receipt")" = 0 ] && [ "$(stat -c %s "$RUN/receiver2.receipt")" = 0 ] &&
 [ "$(cat "$RUN/receiver.command")" = 0 ] || exit 4
 export XDG_RUNTIME_DIR=/tmp X2V_SOURCE_ADAPTER=mode21-c-24fps X2V_OWNED_RAW_GRAPH=mode21-c24 X2V_RECEIVER_ONESHOT=GROUP13_MODE21C24_PRR_ASYNC_V1 LD_PRELOAD=$RECEIVER
 exec "$SERVICE" 3<"$BULK/dng" 4<"$BULK/dng2" 5<"$SP" 6<"$CONF" 7<"$RUN/receiver.command" 8<>"$RUN/receiver.receipt" 9<>"$RUN/receiver2.receipt"
fi
[ -z "${LD_PRELOAD:-}" ] && [ -z "${LD_LIBRARY_PATH:-}" ] || exit 4
if env | grep -Eq '^X2V_(SOURCE_|OBSERVER_|RECEIVER_|OWNED_)'; then echo inherited_source_environment_rejected >&2; exit 4; fi
verify_hash /system/lib64/libdcam_base.so 8486fa7ce0b400992358ad92c445ad026a3784703accf2bae8a490ed10b2ff52 && verify_hash "$RECEIPT_VALIDATOR" "$RECEIPT_VALIDATOR_SHA" && verify_hash "$SP" "$SP_SHA" && verify_hash "$CONF" "$CONF_SHA" && verify_hash "$RCAM" "$RCAM_SHA" && verify_hash "$RECEIVER" "$RECEIVER_SHA" && verify_hash "$HAL" "$HAL_SHA" && verify_hash "$FRWK" "$FRWK_SHA" || exit 4
[ "$(id -u)" = 0 ] || exit 4
[ ! -f "$RUN/session.owner" ] || exit 4
verify_hash "$SERVICE" "$SERVICE_SHA" && verify_hash "$GUI" "$GUI_SHA" && verify_hash "$FACTORY" "$FACTORY_SHA" || exit 4
bootstrap_owner || { echo isolated_bootstrap_proof_required >&2; exit 4; }
OWNER="$ID $$ $(proc_start $$)"
mkdir "$LOCK" || exit 4
printf '%s\n' "$OWNER" > "$LOCK/owner" && printf '%s\n' "$OWNER" > "$RUN/session.owner" || exit 4
finish() {
 result=$?; trap - EXIT HUP INT TERM
 RECOVERING=1
 if owned && [ -f "$RUN/manual.identity" ]; then
  : > "$RUN/abort" || result=70
  if [ "$LOCK_HELD" != 1 ]; then lock_recovery || result=70; fi
  if [ "$LOCK_HELD" = 1 ]; then retire_manual_parent || { log PARENT_RETIRE_FAILED; result=70; }; fi
 fi
 exec 9>&-
 LOCK_HELD=0
 printf '%s\n' "$result" > "$RUN/body.rc" 2>/dev/null || true
 if recover; then rr=0; else rr=$?; fi
 printf '%s\n' "$rr" > "$RUN/recovery.rc" 2>/dev/null || true
 [ "$rr" -eq 0 ] || result=70
 exit "$result"
}
trap finish EXIT
trap 'exit 60' HUP INT TERM
for lk in "$PEER_OLD" "$PEER_NEW"; do
 [ -d "${lk%/*}" ] && [ ! -L "${lk%/*}" ] && mkdir "$lk" || exit 4
 printf '%s\n' "$OWNER" > "$lk/owner" || exit 4
done
[ "$(getprop init.svc.camera-service)" = running ] && [ "$(getprop init.svc.camera-gui)" = running ] || exit 4
identity camera-service > "$RUN/original-service.identity" && identity camera-gui > "$RUN/original-gui.identity" || exit 4
cp "$RUN/original-service.identity" "$RUN/active-service.identity" || exit 4
[ "$(proc_group $$)" = "$fg" ] && { [ "$fg" = /uid_0/pid_3102 ] || [ -f "$RUN/product.mode" ]; } || exit 4
read sp ss < "$RUN/original-service.identity"; read gp gs < "$RUN/original-gui.identity"
[ "$(proc_exe "$sp")" = "$SERVICE" ] && [ "$(proc_exe "$gp")" = "$GUI" ] &&
[ "$(proc_group "$sp")" = "/uid_0/pid_$sp" ] && [ "$(proc_group "$gp")" = "/uid_0/pid_$gp" ] || exit 4
printf '%s\n' "$(proc_group "$sp")" > "$RUN/original-service.group" && cp "$RUN/original-service.group" "$RUN/active-service.group" || exit 4
printf '%s\n' "$(proc_group "$gp")" > "$RUN/original-gui.group" || exit 4
[ ! -e /data/x2v-native-20261012/io-benchmark.lock ] || exit 4
df -k /mnt/media_rw/ssd > "$RUN/ssd-space.before" || exit 4
awk 'NR==2 {good=(NF>=6 && $4 ~ /^[0-9]+$/ && $4>=12582912)} END{exit !good}' "$RUN/ssd-space.before" || exit 4
prepare_receiver || exit 4
printf '%s\n' "$(( $(uptime_seconds)+150 ))" > "$RUN/deadline" || exit 4
# /dev/null fallback keeps a missing bulk log from preventing the independent guard.
if [ -w "$RUN" ]; then wdlog=$RUN/watchdog.log; else wdlog=/dev/null; fi
toybox nohup sh "$SELF" --watchdog "$ID" > "$wdlog" 2>&1 9>&- &
wp=$!; printf '%s %s\n' "$wp" "$(proc_start "$wp")" > "$RUN/watchdog.identity" || exit 4
n=0; while [ ! -f "$RUN/watchdog.ready" ]; do
 alive "$wp" "$(awk '{print $2}' "$RUN/watchdog.identity")" || exit 4
 n=$((n+1)); [ "$n" -lt 30 ] || exit 4; sleep 0.1
done
guard_ready 150 || exit 4
sh "$SELF" --child "$ID" > "$RUN/manual-service.log" 2>&1 9>&- &
mp=$!; ms=$(proc_start "$mp") || exit 5
printf '%s %s\n' "$mp" "$ms" > "$RUN/manual.identity" || exit 5
n=0; while [ ! -f "$RUN/child.ready" ]; do
 alive "$mp" "$ms" && gate || exit 5
 n=$((n+1)); [ "$n" -lt 30 ] || exit 5; sleep 0.1
done
proc_exe "$mp" > "$RUN/manual-shell.exe" || exit 5
owned_member "$mp" "$ms" && gate || exit 5
seal_guard_owners || exit 4
lock_recovery || exit 4
wait_idle && normal_state || exit 5
guard_ready 100 || exit 5
: > "$RUN/native-intent" || exit 5
quiesce || exit 5
gate || exit 5
: > "$RUN/gui-stop-intent" || exit 5
setprop ctl.stop camera-gui 9>&- && wait_absent camera-gui || exit 5
gate || exit 5
guard_ready 80 || exit 5
: > "$RUN/service-stop-intent" || exit 5
setprop ctl.stop camera-service 9>&- && wait_absent camera-service || exit 5
phase stock_absent
printf '%s %s\n' "$mp" "$ms" > "$RUN/active-service.identity" && cp "$RUN/owner.group" "$RUN/active-service.group" || exit 5
uptime_seconds > "$RUN/receiver.launch-uptime" && : > "$RUN/launch" || exit 5
n=0; while [ "$(proc_exe "$mp" 2>/dev/null || true)" != "$SERVICE" ]; do
 alive "$mp" "$ms" && gate || exit 5
 n=$((n+1)); [ "$n" -lt 40 ] || exit 5; sleep 0.1
done
wait_ready && normal_start && clone_evidence && graph_evidence && graph_setup && target_setup_evidence && receiver_arm && receiver_user_stop_trial && receiver_frame && { [ -f "$RUN/product.mode" ] || { receiver_arm_second && receiver_user_stop_trial && receiver_frame; }; } && target_setup_evidence || exit 5
phase manual_target_graph_raw_confirmed
retire_manual_parent || exit 5
phase smoke_complete
exit 0
