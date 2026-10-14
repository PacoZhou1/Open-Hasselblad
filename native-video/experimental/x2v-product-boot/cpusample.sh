#!/system/bin/sh
# cpusample.sh <seconds> <out>: CPU ticks per process (and per camera-service thread) over a window.
w=${1:-10}
out=${2:-/tmp/cpu.txt}
snap() {
    for s in /proc/[0-9]*/stat; do
        read -r l < "$s" 2>/dev/null || continue
        p=${l%% *}; n=${l#*\(}; n=${n%%\)*}; r=${l##*) }; set -- $r
        echo "$p $(( ${12} + ${13} )) $n/pr${16}/pol${39}"
    done
    c=$(pidof camera-service)
    for s in /proc/$c/task/[0-9]*/stat; do
        read -r l < "$s" 2>/dev/null || continue
        t=${l%% *}; n=${l#*\(}; n=${n%%\)*}; r=${l##*) }; set -- $r
        echo "T$t $(( ${12} + ${13} )) cs:$n/pr${16}/rt${38}/pol${39}"
    done
}
read -r cpu a b c d e f g rest < /proc/stat; t0=$((a+b+c+d+e+f+g)); i0=$d
snap > "$out.0"
sleep "$w"
read -r cpu a b c d e f g rest < /proc/stat; t1=$((a+b+c+d+e+f+g)); i1=$d
snap > "$out.1"
{
    echo "total_ticks=$((t1-t0)) idle=$((i1-i0)) window=${w}s"
    awk 'NR==FNR{a[$1]=$2;next} ($1 in a){d=$2-a[$1]; if(d>=5) print d, $1, $3}' "$out.0" "$out.1" | sort -rn | head -n 30
} > "$out.tmp" && mv "$out.tmp" "$out"
