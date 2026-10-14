#!/system/bin/sh
# stk.sh <iterations> <out>: busy-samples the x2v-dng writers' kernel stacks, builtins only;
# logs "uptime tid frames..." whenever a writer is anywhere but its queue wait.
p=$(pidof camera-service); n=$1; out=$2
tids=""
for t in /proc/$p/task/*; do read c < $t/comm; [ "$c" = x2v-dng ] && tids="$tids ${t##*/}"; done
: > "$out"
i=0
while [ $i -lt $n ]; do
    read up x < /proc/uptime
    for t in $tids; do
        s=""; k=0
        while read a b; do s="$s ${b%%+*}"; k=$((k + 1)); [ $k -ge 14 ] && break; done < /proc/$p/task/$t/stack
        case "$s" in *futex_wait*) ;; *) echo "$up $t$s" >> "$out";; esac
    done
    i=$((i + 1))
done
