#!/system/bin/sh
# warmtest.sh <bench-parent> <warm 0|1>: optionally a keep-warm H.264 encoder fed a frame every
# 0.5 s; then a second encoder whose first frame lands as a DNG start bench begins.
T=/data/local/tmp
F=1891500
if [ "$2" = 1 ]; then
    : > $T/warm.on
    ( while [ -f $T/warm.on ]; do head -c $F $T/vin.nv12; sleep 0.5; done ) | test_venc_e2 $T/vt3.json > /dev/null 2>&1 &
fi
( (sleep 10; cat $T/vin.nv12) | test_venc_e2 $T/vt2.json > /dev/null 2>&1 ) &
sleep 9.9
x2v_bench_dngstart_test "$1" 48 > $T/bds.txt
rm -f $T/warm.on
sleep 1
rm -rf "$1"/bench*
head -c 250 $T/bds.txt
