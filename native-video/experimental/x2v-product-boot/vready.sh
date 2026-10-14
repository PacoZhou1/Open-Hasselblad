#!/system/bin/sh
# vready.sh <bench-parent>: starts the H.264 tool on a held-back input next to a DNG start bench;
# prints the bench's start uptime and every change in the tool's kernel wait point.
T=/data/local/tmp
( (sleep 1.5; cat $T/vin.nv12) | test_venc_e2 $T/vt2.json > /dev/null 2>&1 ) &
read u0 x < /proc/uptime
x2v_bench_dngstart_test "$1" 48 > $T/bds.txt 2>&1 &
b=$!
p=""; last=""; i=0
while [ $i -lt 3000 ]; do
    [ -z "$p" ] && p=$(pidof test_venc_e2)
    if [ -n "$p" ] && [ -d /proc/$p ]; then
        w=""
        for t in /proc/$p/task/*; do read c < $t/wchan 2>/dev/null && w="$w $c"; done
        [ "$w" = "$last" ] || { read u x < /proc/uptime; echo "$u$w"; last=$w; }
    fi
    kill -0 $b 2>/dev/null || break
    i=$((i + 1))
done
wait
echo "bench_start $u0"
rm -rf "$1"/bench*
head -c 300 $T/bds.txt
