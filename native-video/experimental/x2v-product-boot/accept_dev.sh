#!/system/bin/sh
# Input for accept.py, on the camera: a body key or a touch, as the hardware sends them.
#   accept_dev.sh key <device> <code> <hold_s>
#   accept_dev.sh tap <x> <y> <hold_s>        (screen pixels; fts_ts reports them 1:1)
#   accept_dev.sh cpu <pid...>                (utime+stime ticks, one line per pid)
#   accept_dev.sh send <verb> [args]          (a resident command; prints its ack or "timeout")
case "$1" in
    send)
        shift; L=/tmp/x2v-live
        s=$(( $(cat $L/seq 2>/dev/null || echo 0) + 1 )); echo $s > $L/seq
        echo "$s $*" > $L/command.tmp && mv $L/command.tmp $L/command
        for i in $(seq 1 100); do
            grep -q "\"seq_ack\":$s[,}]" $L/status.json 2>/dev/null && { echo "ack $s"; exit 0; }
            sleep 0.1
        done
        echo timeout;;
    key)
        sendevent "$2" 1 "$3" 1; sendevent "$2" 0 0 0
        sleep "$4"
        sendevent "$2" 1 "$3" 0; sendevent "$2" 0 0 0;;
    tap)
        T=/dev/input/event5
        sendevent $T 3 47 0; sendevent $T 3 57 4242; sendevent $T 3 53 "$2"; sendevent $T 3 54 "$3"
        sendevent $T 3 48 40; sendevent $T 1 330 1; sendevent $T 0 0 0
        sleep "$4"
        sendevent $T 3 57 -1; sendevent $T 1 330 0; sendevent $T 0 0 0;;
    cpu)
        shift
        for p in "$@"; do
            set -- $(cut -d' ' -f14,15 "/proc/$p/stat" 2>/dev/null)
            echo "$p $(( ${1:-0} + ${2:-0} ))"
        done;;
esac
