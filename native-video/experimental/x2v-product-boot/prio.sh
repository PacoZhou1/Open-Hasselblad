#!/system/bin/sh
# prio.sh: policy, RT priority, last CPU and allowed CPUs of the NVMe IRQ thread, the softirq
# threads and the busiest camera-service threads; and the NVMe IRQ's affinity.
show() {
    a=$(grep Cpus_allowed_list "$1/status" | cut -f2)
    set -- "$2" $(sed 's/^.*) //' "$1/stat")
    # $2 is stat field 3 (state): processor (39), rt_priority (40), policy (41) are $38 $39 $40.
    echo "$1 cpu=${38} rtprio=${39} policy=${40} allowed=$a"
}
for p in /proc/[0-9]*; do
    read c < $p/comm 2>/dev/null || continue
    case "$c" in irq/*nvme*|ksoftirqd/*|kswapd*|test_venc_e2|camera-gui|weston) show $p "$c:${p#/proc/}";; esac
done
s=$(pidof camera-service)
for t in /proc/$s/task/*; do
    read c < $t/comm
    case "$c" in bs_liveview*|x2v-*|AWBTsk|AETsk|isp_*|TmonT|fst_expm*) show $t "csvc:$c:${t##*/}";; esac
done
for i in $(grep nvme /proc/interrupts | cut -d: -f1); do
    echo "irq$i affinity=$(cat /proc/irq/$i/smp_affinity_list) effective=$(cat /proc/irq/$i/effective_affinity_list 2>/dev/null)"
done
grep nvme /proc/interrupts
