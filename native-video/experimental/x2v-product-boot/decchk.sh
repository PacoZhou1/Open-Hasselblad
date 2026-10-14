#!/system/bin/sh
# decchk.sh <out> <mode --all|--ends> <clip>...: hardware-decode each clip, one report per clip.
out=$1 mode=$2
shift 2
cd /mnt/media_rw/ssd/X2V_RAW || exit 1
rm -f "$out".*
i=0
for c in "$@"; do
    i=$((i + 1))
    x2v_prr_dec_20261013a -i "$c/clip.mov" "$mode" --report "$out.$i.json" > "$out.$i.log" 2>&1
    echo "$c rc=$?" >> "$out.rc"
done
echo done >> "$out.rc"
