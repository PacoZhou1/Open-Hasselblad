#!/system/bin/sh
# usage: pcpu.sh seconds name... -> % of one core per process over the window
t=$1; shift
ticks() { cut -d' ' -f14,15 "/proc/$1/stat" | tr ' ' '+'; }
pids=""; before=""
for n in "$@"; do p=$(pidof "$n" | cut -d' ' -f1); pids="$pids $p"; before="$before $(( $(ticks "$p") ))"; done
sleep "$t"
set -- "$@"
i=0
for p in $pids; do
    i=$((i + 1))
    a=$(echo $before | cut -d' ' -f$i)
    eval "n=\${$i}"
    echo "$n $(( ($(ticks "$p") - a) / t ))%"
done
