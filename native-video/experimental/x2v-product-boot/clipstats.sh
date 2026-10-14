#!/system/bin/sh
# clipstats.sh <out> [n] [check]: per-clip counters of the newest n clips; with a checker binary,
# also its structural verdict on each clip.mov.
out=${1:-/tmp/clipstats.txt}
n=${2:-24}
check=$3
cd /mnt/media_rw/ssd/X2V_RAW || exit 1
for c in $(ls -t | head -n "$n"); do
    j=$(cat "$c/clip.json" 2>/dev/null) || continue
    v() { r=${j#*\"$1\":}; [ "$r" = "$j" ] && echo - || echo "${r%%[,\}]*}"; }
    p=${j#*\"drop_phase\":\[}; [ "$p" = "$j" ] && p=- || p=${p%%\]*}
    echo "$c frames=$(v frames) dropped=$(v dropped) bytes=$(v bytes) qmax=$(v queue_max) wms=$(v write_ms_max)" \
         "direct=$(v direct) pre=$(v pre_ms_max) sub=$(v sub_ms_max) acq=$(v acq_ms_max) phases=$p"
    [ -n "$check" ] && [ -f "$c/clip.mov" ] && echo "  $($check "$c/clip.mov" 2>&1 | tail -1)"
done > "$out.tmp" && mv "$out.tmp" "$out"
