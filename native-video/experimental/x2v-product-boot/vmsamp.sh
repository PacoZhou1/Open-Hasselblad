#!/system/bin/sh
# vmsamp.sh <samples> <out>: every ~50 ms, uptime and the reclaim counters, builtins only.
n=$1; out=$2; i=0
: > "$out"
while [ $i -lt $n ]; do
    read up idle < /proc/uptime
    line="$up"
    while read k v; do
        case $k in pgscan_direct|pgsteal_direct|pgscan_kswapd|pgsteal_kswapd|pgmajfault|workingset_refault) line="$line $k=$v";; esac
    done < /proc/vmstat
    while read k v u; do
        case $k in MemFree:|Cached:|Dirty:) line="$line $k$v";; esac
    done < /proc/meminfo
    echo "$line" >> "$out"
    sleep 0.05
    i=$((i + 1))
done
