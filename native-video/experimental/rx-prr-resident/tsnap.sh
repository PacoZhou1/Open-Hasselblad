#!/system/bin/sh
# usage (root): tsnap.sh seconds out -> out.a / out.b: /proc stat lines of every process
# (P), and of every thread of camera-service (T), at the window's start and end.
t=$1; o=$2
snap() {
    for f in /proc/[0-9]*/stat; do read l < "$f" 2>/dev/null && echo "P $l"; done
    for p in $(pidof camera-service); do
        for f in /proc/$p/task/*/stat; do read l < "$f" 2>/dev/null && echo "T $p $l"; done
    done
    head -n 1 /proc/stat
}
snap > "$o.a"
sleep "$t"
snap > "$o.b"
chmod 644 "$o.a" "$o.b"
