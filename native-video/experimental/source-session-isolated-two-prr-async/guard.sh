#!/system/bin/sh
# Data-only ADB secondary guard. No native process inspection or recovery.
PATH=/system/bin
export PATH
unset LD_PRELOAD LD_LIBRARY_PATH X2V_SOURCE_ADAPTER X2V_RECEIVER_ONESHOT X2V_OWNED_RAW_GRAPH
ROOT=/data/x2v-source-20261012/runs
CLOCK=/system/bin/x2v_guard_clock_20261012b
CLOCK_SHA=d44ae57623f60019d54817a9651e343ea6e26646e2e8860c16811181dc700f59
digits() { case "$1" in ''|0*|*[!0-9]*|????????????*) return 1;; esac; [ "$1" -gt 0 ]; }
nonce32() { case "$1" in *[!a-fA-F0-9]*) return 1;; esac; [ "${#1}" = 32 ]; }
hash64() { case "$1" in *[!a-f0-9]*) return 1;; esac; [ "${#1}" = 64 ]; }
now() { current=$("$CLOCK") || return 1; digits "$current"; }
boot() { current_boot=$(cat /proc/sys/kernel/random/boot_id) || return 1; }
digest() { hashed=$(sha256sum "$1") || return 1; hashed=${hashed%% *}; hash64 "$hashed"; }
line() {
 [ -f "$1" ] && [ ! -L "$1" ] || return 1
 bytes=$(stat -c %s "$1") || return 1
 digits "$bytes" && [ "$bytes" -le 512 ] || return 1
 exec 6< "$1" || return 1
 IFS= read -r record <&6; first_rc=$?
 extra=; IFS= read -r extra <&6; second_rc=$?
 exec 6<&-
 [ "$first_rc" = 0 ] && [ "$second_rc" != 0 ] && [ -z "$extra" ]
}
abort() {
 [ ! -L "$R/abort" ] || exit 32
 printf 'v1 %s %s %s\n' "$run" "${nonce:-unknown}" "$1" > "$R/abort" || exit 32
 printf 'ABORT %s\n' "$1"
 exit 30
}
self() {
 read sline < /proc/$$/stat || return 1
 srest=${sline##*) }; set -- $srest
 own_pgid=$3; own_session=$4; shift 19; own_start=$1
 own_group=
 while IFS=: read -r hierarchy controllers group; do
  case ",$controllers," in *,cpuacct,*) own_group=$group;; esac
 done < /proc/$$/cgroup
 digits "$own_start" && [ "$own_pgid" = "$$" ] && [ "$own_session" = "$$" ] && [ "$own_group" = /uid_0/pid_3102 ]
}
binding() {
 line "$R/guard.binding" || return 1
 set -f; set -- $record
 [ "$#" = 5 ] && [ "$1" = v1 ] && [ "$2" = "$run" ] || return 1
 nonce=$3; bound_boot=$4; deadline=$5
 nonce32 "$nonce" && digits "$deadline" || return 1
 boot && [ "$current_boot" = "$bound_boot" ] && now || return 1
 [ "$current" -lt "$deadline" ] && [ "$((deadline-current))" -le 300 ] || return 1
 digest "$R/guard.binding" || return 1
 binding_hash=$hashed
}
owners() {
 # Initial registration can arrive after ready. Once sealed, missing/changed
 # records are a sticky abort. No PID is ever queried in the native domain.
 if [ ! -e "$R/owners" ] || [ ! -e "$R/owners.sha256" ]; then
  [ -z "$owner_hash" ] || return 1
  return 0
 fi
 line "$R/owners" || return 1
 set -f; set -- $record
 [ "$#" = 9 ] && [ "$1" = v1 ] && [ "$2" = "$run" ] && [ "$3" = "$nonce" ] || return 1
 mp=$4; ms=$5; sp=$6; ss=$7; wp=$8; ws=$9
 for n in "$mp" "$ms" "$sp" "$ss" "$wp" "$ws"; do digits "$n" || return 1; done
 [ "$mp" != "$sp" ] && [ "$mp" != "$wp" ] && [ "$sp" != "$wp" ] || return 1
 [ "$mp" != "$$" ] && [ "$sp" != "$$" ] && [ "$wp" != "$$" ] || return 1
 digest "$R/owners" || return 1
 next_owner_hash=$hashed
 line "$R/owners.sha256" || return 1
 hash64 "$record" && [ "$record" = "$next_owner_hash" ] || return 1
 if [ -n "$owner_hash" ]; then [ "$owner_hash" = "$next_owner_hash" ]; return $?; fi
 owner_hash=$next_owner_hash
 [ ! -e "$R/adb-guard.owners-ack" ] && [ ! -L "$R/adb-guard.owners-ack.tmp.$$" ] || return 1
 printf 'v1 %s %s %s\n' "$run" "$nonce" "$owner_hash" > "$R/adb-guard.owners-ack.tmp.$$" &&
 mv "$R/adb-guard.owners-ack.tmp.$$" "$R/adb-guard.owners-ack"
}
stopped() {
 if [ -e "$R/restored" ]; then
  [ -f "$R/restored" ] && [ ! -L "$R/restored" ] || return 2
  return 0
 fi
 if [ -e "$R/guard.stop" ]; then
  line "$R/guard.stop" || return 2
  [ "$record" = "v1 $run $nonce $bound_boot" ] || return 2
  return 0
 fi
 return 1
}
verb=${1:-}; run=${2:-}
case "$verb" in --guard|--worker) :;; *) printf 'OFFLINE data-only guard; explicit --guard RUN required\n'; exit 0;; esac
case "$run" in source-isolated-?*) :;; *) exit 2;; esac
case "$run" in *[!a-zA-Z0-9_-]*) exit 2;; esac
R=$ROOT/$run
[ -d "$ROOT" ] && [ ! -L "$ROOT" ] && [ ! -L /data/x2v-source-20261012 ] &&
[ -d "$R" ] && [ ! -L "$R" ] || exit 3
if [ "$verb" = --guard ]; then exec setsid /system/bin/sh "$0" --worker "$run"; fi
# Direct worker invocation must still be a fresh session leader in pinned ADB
# cgroup. setsid creates a process session; it cannot migrate cpuacct groups.
self || abort self_domain_or_session
identity_start=$own_start
digest "$CLOCK" && [ "$hashed" = "$CLOCK_SHA" ] || abort clock_hash
binding || abort binding_invalid
sealed_binding_hash=$binding_hash
mkdir "$R/adb-guard.running" || abort duplicate_guard
owner_hash=
[ ! -e "$R/adb-guard.ready" ] && [ ! -L "$R/adb-guard.ready.tmp.$$" ] || abort stale_ready
printf 'v1 %s %s %s %s %s %s %s\n' "$run" "$nonce" "$$" "$own_start" "$own_group" "$own_pgid" "$bound_boot" > "$R/adb-guard.ready.tmp.$$" &&
mv "$R/adb-guard.ready.tmp.$$" "$R/adb-guard.ready" || abort ready_io
while :; do
 self && [ "$own_start" = "$identity_start" ] || abort self_domain_changed
 digest "$R/guard.binding" && [ "$hashed" = "$sealed_binding_hash" ] || abort binding_changed
 boot && [ "$current_boot" = "$bound_boot" ] || abort boot_changed
 now || abort clock_unavailable
 [ ! -e "$R/abort" ] && [ ! -L "$R/abort" ] || abort explicit_abort
 [ "$current" -lt "$deadline" ] || abort deadline
 stopped; stop_rc=$?
 if [ "$stop_rc" = 0 ]; then printf 'STOP run=%s restored_or_valid_stop\n' "$run"; exit 0; fi
 [ "$stop_rc" = 1 ] || abort stop_invalid
 owners || abort owners_invalid_or_changed
 [ ! -L "$R/adb-guard.heartbeat" ] && [ ! -L "$R/adb-guard.heartbeat.tmp.$$" ] || abort heartbeat_path
 printf 'v1 %s %s %s %s\n' "$run" "$nonce" "$$" "$current" > "$R/adb-guard.heartbeat.tmp.$$" &&
 mv "$R/adb-guard.heartbeat.tmp.$$" "$R/adb-guard.heartbeat" || abort heartbeat_io
 sleep 1
done
