#!/system/bin/sh
# ddtest.sh <out>: sustained write MB/s on the clip volume, buffered + fsync and O_DIRECT.
out=${1:-/tmp/dd.txt}
T=/mnt/media_rw/ssd/X2V_RAW/.ddtest
up() { read -r u _ < /proc/uptime; echo "$u"; }
{
    for mode in fsync direct; do
        rm -f "$T"; sync
        a=$(up)
        if [ $mode = fsync ]; then dd if=/dev/zero of=$T bs=8388608 count=128 conv=fsync 2>&1 | tail -n 1
        else dd if=/dev/zero of=$T bs=8388608 count=128 oflag=direct 2>&1 | tail -n 1; fi
        b=$(up)
        echo "$mode start=$a end=$b"
    done
    rm -f "$T"
} > "$out.tmp" 2>&1
mv "$out.tmp" "$out"
