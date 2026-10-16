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
 temp=$(timeout 2 odindb-send -s system -p temperature_status)
 case "$temp" in *E_TemperatureStatus_Low*|*E_TemperatureStatus_Moderate*) ;; *) exit 0;; esac
 state=$(timeout 2 odindb-send -s system -p system_state)
 case "$state" in *PrepareShutdown*|*Shutdown*) exit 0;; esac
 sleep 2
done
