#!/system/bin/sh
cleanup() {
 timeout 4 odindb-send -s system -p screen_idle_timeout -- 300
 timeout 4 odindb-send -s system -m release_wake_lock -- x2v-debug-session
}
trap cleanup EXIT
trap 'exit 0' INT TERM HUP
while [ -f /blackbox/x2v-native-20261011/keepawake.lease ]; do
 read expiry < /blackbox/x2v-native-20261011/keepawake.lease
 now=$(date +%s)
 case "$expiry" in ''|*[!0-9]*) exit 1;; esac
 [ "$now" -lt "$expiry" ] || exit 0
 sleep 10
done
