#!/system/bin/sh
# GUI frame pacing from the display engine: VOP0 osd1 (the camera-gui window) commit counter.
# usage: guimeasure.sh <label> [seconds]   samples ~10 per second; prints per-second commits and gaps.
L=${1:-run}; N=$(( ${2:-20} * 10 ))
i=0
while [ $i -lt "$N" ]; do
    awk 'BEGIN{getline u < "/proc/uptime"; split(u, a, " ")}
        /^VOP /{vop=$2} /plane [0-9]+ -/{pl=$2}
        vop=="0" && pl=="1" && /frame cnt:/{gsub(",",""); c=$3}
        END{print a[1], c+0}' /proc/display/plane
    sleep 0.1
    i=$((i+1))
done > /tmp/gui.$L
awk -v L="$L" '
    NR == 1 { t0 = $1; c0 = $2; tl = $1; cl = $2; next }
    { if ($2 != cl) { gap = $1 - tl; if (gap > mg) mg = gap; if (gap > 0.5) slow++; tl = $1; cl = $2 } t1 = $1; c1 = $2 }
    END { dt = t1 - t0; if (dt <= 0) dt = 1
          gap = t1 - tl; if (gap > mg) mg = gap
          printf "%s commits/s=%5.1f longest_gap=%.2fs gaps>0.5s=%d span=%.1fs\n", L, (c1 - c0) / dt, mg, slow + 0, dt }' /tmp/gui.$L
