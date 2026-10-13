#!/system/bin/sh
# Offline by default. Fixed native controller bootstrap, never an arbitrary exec.
PATH=/system/bin
export PATH
unset LD_PRELOAD LD_LIBRARY_PATH
ROOT=/data/x2v-source-20261012/runs
TARGET=/uid_0/pid_3102
DOMAIN=u:r:hbl_camera_service:s0
CONTROLLER_SHA=aebecedb8cd989ff96c76c718ea5d5c9bc1866e6ffd8e9b5fc083fe92394277b
if [ "$#" = 0 ]; then print -r -- 'OFFLINE native source bootstrap draft'; exit 0; fi
[ "$#" = 2 ] && [ "$1" = --run ] || exit 64
[ "${#CONTROLLER_SHA}" = 64 ] || { print -r -- HOLD_controller_pin_pending; exit 30; }
case "$CONTROLLER_SHA" in *[!a-f0-9]*) print -r -- HOLD_controller_pin_invalid; exit 30;; esac
RUN_ID=$2
case "$RUN_ID" in source-isolated-*) ;; *) exit 64;; esac
case "$RUN_ID" in *[!A-Za-z0-9_-]*|'') exit 64;; esac
[ "${#RUN_ID}" -le 80 ] || exit 64
R=$ROOT/$RUN_ID
[ -d "$R" ] && [ ! -L "$R" ] || exit 65
CHALLENGE=-
WINDOW_DEADLINE=0
MIGRATED=0
SELF=$$
fail() { print -r -- "HOLD $1"; exit 30; }
hex32() { [ "${#1}" = 32 ] || return 1; case "$1" in *[!a-f0-9]*) return 1;; esac; }
read_now() {
    _up=; _extra=
    IFS=' ' read -r _up _extra < /proc/uptime || return 1
    NOW=${_up%%.*}
    case "$NOW" in ''|*[!0-9]*) return 1;; esac
}
read_identity() {
    _line=
    IFS= read -r _line < /proc/$$/stat || return 1
    [ "${_line%% *}" = "$SELF" ] || return 1
    _rest=${_line##*) }
    [ "$_rest" != "$_line" ] || return 1
    set -- $_rest
    [ "$#" -ge 20 ] || return 1
    STATE=$1; PPID_NOW=$2; PGID_NOW=$3; SID_NOW=$4
    shift 19; START_NOW=$1
    GROUP_NOW=
    while IFS=: read -r _a _controllers _path; do
        [ "$_controllers" = cpuacct ] && GROUP_NOW=$_path
    done < /proc/$$/cgroup
    [ -n "$GROUP_NOW" ] || return 1
    DOMAIN_NOW=
    IFS= read -r DOMAIN_NOW < /proc/$$/attr/current || [ -n "$DOMAIN_NOW" ] || return 1
    BOOT_NOW=
    IFS= read -r BOOT_NOW < /proc/sys/kernel/random/boot_id || return 1
    [ "$DOMAIN_NOW" = "$DOMAIN" ] && [ "$BOOT_NOW" = "$BOOT" ] &&
        [ "$PGID_NOW" = "$SELF" ] && [ "$SID_NOW" = "$SELF" ] &&
        [ "$START_NOW" = "$START" ]
}
single_thread() {
    # This kernel has no task/PID/children interface. No child enumeration
    # claim: fixed noninteractive script executes only builtins until MIGRATED.
    _threads=
    while read -r _key _value _extra; do
        [ "$_key" = Threads: ] && _threads=$_value
    done < /proc/$$/status
    [ "$_threads" = 1 ] || return 1
    set -- /proc/$$/task/[0-9]*
    [ "$#" = 1 ] && [ "$1" = /proc/$$/task/$$ ]
}

stopped() {
    [ -e "$R/passive.stop" ] || return 1
    [ ! -L "$R/passive.stop" ] || return 2
    _v= _r= _n= _x=
    IFS=' ' read -r _v _r _n _x < "$R/passive.stop" || return 2
    [ "$_v" = v1 ] && [ "$_r" = "$RUN_ID" ] && [ "$_n" = "$NONCE" ] && [ -z "$_x" ] || return 2
    return 0
}
live() {
    stopped; _stop_rc=$?
    [ "$_stop_rc" = 2 ] && fail malformed_stop
    if [ "$_stop_rc" = 0 ]; then
        read_now && read_identity || fail stop_identity_unreadable
        [ "$NOW" -lt "$DEADLINE" ] || fail stop_lifetime_expired
        if [ "$MIGRATED" = 0 ] && [ "$WINDOW_DEADLINE" -gt 0 ]; then
            [ "$NOW" -lt "$WINDOW_DEADLINE" ] || fail stop_window_expired
        fi
        if [ "$MIGRATED" = 1 ]; then
            [ "$GROUP_NOW" = "$TARGET" ] || fail stop_group_changed
        else
            case "$GROUP_NOW" in /uid_0/pid_$FACTORY_PID|"$TARGET") ;; *) fail stop_group_changed;; esac
        fi
        record done done
        exit 0
    fi
    read_now || fail clock_unreadable
    [ "$NOW" -lt "$DEADLINE" ] || fail lifetime_expired
    read_identity || fail identity_changed_or_unreadable
}
record() {
    # Reader must require a complete newline and exact token count. No mv/fork.
    print -r -- "v1 $1 $RUN_ID $NONCE $CHALLENGE $SELF $START $BOOT $PGID_NOW $SID_NOW $DOMAIN_NOW $GROUP_NOW $TARGET $NOW $WINDOW_DEADLINE" > "$R/passive.$2" || fail record_write
}
for _f in passive.binding passive.challenge passive.ready passive.fresh passive.migrated passive.go passive.heartbeat passive.done passive.query-after passive.query.before passive.query.after passive.state.before passive.state.after passive.count.before passive.count.after; do
    [ ! -L "$R/$_f" ] || fail symlink_record
done
[ -f "$R/passive.binding" ] || fail binding_missing
IFS=' ' read -r _v _r NONCE BOOT FACTORY_PID FACTORY_START FACTORY_PGID DEADLINE _x < "$R/passive.binding" || fail incomplete_binding
[ "$_v" = v1 ] && [ "$_r" = "$RUN_ID" ] && [ -z "$_x" ] && hex32 "$NONCE" || fail binding_fields
for _num in "$FACTORY_PID" "$FACTORY_START" "$FACTORY_PGID" "$DEADLINE"; do
    case "$_num" in ''|*[!0-9]*) fail binding_number;; esac
done
[ "$FACTORY_PID" -gt 1 ] && [ "$FACTORY_PGID" != "$SELF" ] || fail factory_identity
read_now || fail clock_unreadable
[ "$DEADLINE" -gt "$NOW" ] && [ "$DEADLINE" -le "$((NOW + 90))" ] || fail lifetime_range
for _f in challenge ready fresh migrated go heartbeat done query-after query.before query.after state.before state.after count.before count.after; do
    [ ! -e "$R/passive.$_f" ] || fail stale_run_record
done
# Root preflight seals native helper/source hashes and the target group identity.
# Factory PID/start/PGID are verified once while stock remains untouched.
IFS= read -r _line < /proc/$FACTORY_PID/stat || fail factory_stat
[ "${_line%% *}" = "$FACTORY_PID" ] || fail factory_pid
_rest=${_line##*) }; set -- $_rest
[ "$#" -ge 20 ] && [ "$3" = "$FACTORY_PGID" ] || fail factory_pgid
shift 19
[ "$1" = "$FACTORY_START" ] || fail factory_start
IFS= read -r _line < /proc/$$/stat || fail self_stat
_rest=${_line##*) }; set -- $_rest
[ "$#" -ge 20 ] || fail self_stat_fields
shift 19; START=$1
live
[ "$GROUP_NOW" = /uid_0/pid_$FACTORY_PID ] || fail initial_factory_group
[ "$((DEADLINE - NOW))" -gt 60 ] || fail ready_budget
single_thread || fail thread_state_unknown_or_multiple
record ready ready
# No external process is created until migration is confirmed. Waiting is a
# bounded CPU busy-poll; this deliberately avoids an unmigrated sleep child.
while :; do
    live
    [ "$GROUP_NOW" = /uid_0/pid_$FACTORY_PID ] || fail premature_group_change
    [ -e "$R/passive.challenge" ] && break
done
[ ! -L "$R/passive.challenge" ] || fail challenge_symlink
IFS=' ' read -r _v _r _n CHALLENGE _x < "$R/passive.challenge" || fail incomplete_challenge
[ "$_v" = v1 ] && [ "$_r" = "$RUN_ID" ] && [ "$_n" = "$NONCE" ] && [ -z "$_x" ] && hex32 "$CHALLENGE" || fail challenge_fields
live
single_thread || fail thread_state_unknown_or_multiple
[ "$((DEADLINE - NOW))" -gt 60 ] || fail fresh_budget
WINDOW_DEADLINE=$((NOW + 5))
[ "$WINDOW_DEADLINE" -lt "$DEADLINE" ] || fail insufficient_window
record fresh fresh
while :; do
    live
    [ "$NOW" -lt "$WINDOW_DEADLINE" ] || fail migration_window_expired
    case "$GROUP_NOW" in
        "$TARGET") break;;
        /uid_0/pid_$FACTORY_PID) ;;
        *) fail unexpected_group;;
    esac
done
single_thread || fail thread_state_unknown_or_multiple
live
[ "$GROUP_NOW" = "$TARGET" ] && [ "$NOW" -lt "$WINDOW_DEADLINE" ] || fail migration_not_current
MIGRATED=1
record migrated migrated
# Fixed controller release, still no arbitrary command/path/env accepted.
while :; do
    live
    [ "$GROUP_NOW" = "$TARGET" ] || fail post_migration_group_changed
    record heartbeat heartbeat
    [ -e "$R/passive.go" ] && break
    sleep 1
done
[ ! -L "$R/passive.go" ] || fail go_symlink
IFS=' ' read -r _v _r _n _c _x < "$R/passive.go" || fail incomplete_go
[ "$_v" = v1 ] && [ "$_r" = "$RUN_ID" ] && [ "$_n" = "$NONCE" ] && [ "$_c" = "$CHALLENGE" ] && [ -z "$_x" ] || fail go_fields
live
[ "$GROUP_NOW" = "$TARGET" ] || fail pre_hash_group_changed
[ -f "$R/controller.sh" ] && [ ! -L "$R/controller.sh" ] || fail controller_not_regular
# Hashing is permitted only AFTER native migration ACK. It is the only
# executable selection gate: exact fixed file, exact compiled-in pin.
_controller_hash=$(sha256sum "$R/controller.sh") || fail controller_hash_unreadable
_controller_hash=${_controller_hash%% *}
[ "$_controller_hash" = "$CONTROLLER_SHA" ] || fail controller_hash_mismatch
live
[ "$GROUP_NOW" = "$TARGET" ] && [ -f "$R/controller.sh" ] && [ ! -L "$R/controller.sh" ] || fail pre_exec_identity_or_path
record heartbeat heartbeat
# Same PID/start/PGID/SID/domain/cpuacct survive exec; controller must verify
# migrated/fresh/binding and use its OWN bounded execution/recovery deadline.
exec /system/bin/sh "$R/controller.sh" --execute-isolated-two-prr-async "$RUN_ID"
fail controller_exec_failed
