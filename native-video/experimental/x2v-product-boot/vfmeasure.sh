#!/system/bin/sh
# Viewfinder frame pacing from the display engine: VOP0 (main panel, 50 Hz) video plane counters.
# usage: vfmeasure.sh <label> [rest_samples] [half_s] [after_samples]   (samples are ~0.2 s apart)
L=${1:-run}; REST=${2:-15}; HALF=${3:-4}; AFTER=${4:-10}
sample() {
    awk -v p="$1" 'BEGIN{getline u < "/proc/uptime"; split(u, a, " ")}
        /^VOP /{vop=$2} /plane [0-9]+ -/{pl=$2}
        vop=="0" && pl=="4" && /frame cnt:/{gsub(",",""); c=$3}
        vop=="0" && pl=="4" && /total drop:/{gsub(",",""); r=$9}
        END{print p, a[1], c+0, r+0}' /proc/display/plane
}
{
    i=0; while [ $i -lt "$REST" ]; do sample rest; sleep 0.2; i=$((i+1)); done
    inject-keypress -k HalfPress -t $((HALF * 1000)) >/dev/null 2>&1 &
    i=0; while [ $i -lt $((HALF * 5)) ]; do sample half; sleep 0.2; i=$((i+1)); done
    wait
    i=0; while [ $i -lt "$AFTER" ]; do sample after; sleep 0.2; i=$((i+1)); done
} > /tmp/vf.$L
awk -v L="$L" '
    { if (!($1 in t0)) { t0[$1] = $2; c0[$1] = $3; r0[$1] = $4; ord[++k] = $1 }
      t1[$1] = $2; c1[$1] = $3; r1[$1] = $4 }
    END { for (i = 1; i <= k; i++) { p = ord[i]; dt = t1[p] - t0[p]; if (dt <= 0) dt = 1
          printf "%s %-5s fps=%5.1f repeat/s=%5.1f span=%.1fs\n", L, p, (c1[p]-c0[p])/dt, (r1[p]-r0[p])/dt, dt } }' /tmp/vf.$L
