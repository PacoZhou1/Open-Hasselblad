#!/system/bin/sh
# wbench.sh <bench_write> <out>: write-strategy comparison on the clip volume, 1 GiB each.
b=$1
out=${2:-/tmp/wbench.txt}
T=/mnt/media_rw/ssd/X2V_RAW/.wbench
{
    for args in "buffered" "behind 1024 8 1" "behind 1024 16 2" "behind 1024 8 4" "direct"; do
        rm -f "$T"; sync; sleep 2
        set -- $args
        ${LD:+$LD }"$b" "$T" "$@"
    done
    rm -f "$T"
} > "$out.tmp" 2>&1
mv "$out.tmp" "$out"
