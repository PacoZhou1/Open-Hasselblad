from pathlib import Path
import hashlib,subprocess
D=Path(__file__).resolve().parent
s=(D/'stable-baseline.sh').read_text()
lib=D.parents[1]/'native-video/experimental/rx-prr-explore-toflimits-20261016/build/libx2v_prr_resident.so'
h=hashlib.sha256(lib.read_bytes()).hexdigest()
marker='/blackbox/x2v-native-20261011/fps-explore/afc-test.boot'
block=f'''# Development AF-C is armed for exactly the current boot, with no click deadline.
X2V_AF_TEST=0
if [ -r {marker} ]; then
    read af_boot < {marker}
    read this_boot < /proc/sys/kernel/random/boot_id
    if [ "$af_boot" = "$this_boot" ]; then
        X2V_AF_TEST=1
        LIB=/system/lib64/libx2v_explore_toflimits_20261015.so
        LIB_SHA={h}
    fi
fi
'''
s=s.replace('ETC=${X2V_ETC:-/system/etc/x2v}',block+'ETC=${X2V_ETC:-/system/etc/x2v}')
s=s.replace('    echo "$d"\n}', '''    if [ "$X2V_AF_TEST" = 1 ]; then
        toybox nohup sh /blackbox/x2v-native-20261011/fps-explore/afc-record-watch.sh "$d" > "$d/afc-control.log" 2>&1 < /dev/null &
        log "afc_record_watch clip=$d pid=$!"
    fi
    echo "$d"
}''')
s=s.replace('stop_clip() {\n    c=', '''stop_clip() {
    if [ "$X2V_AF_TEST" = 1 ]; then
        timeout 3 odindb-send -s camera -m stop_session >> "$LOG" 2>&1 || true
    fi
    c=''')
(D/'afc-button-session.sh').write_text(s)
watch='''#!/system/bin/sh
set -u
clip=$1
status=/tmp/x2v-live/status.json
field() { sed -n "s/.*\\\"$1\\\":\\\"\\([^\\\"]*\\)\\\".*/\\1/p" "$status"; }
read started rest < /proc/uptime
started=${started%%.*}
echo "AFC_TEST_START clip=$clip uptime=$started"
[ "$(field clip)" = "$clip" ] && [ "$(field state)" = recording ] || exit 2
# Native AF starts from the same on-camera record action, independent of the host.
timeout 35 odindb-send -s camera -m find_focus > "$clip/afc-find-focus.log" 2>&1 &
focus_pid=$!
echo "AFC_FIND_FOCUS pid=$focus_pid"
while [ "$(field clip)" = "$clip" ] && [ "$(field state)" = recording ]; do
    read now rest < /proc/uptime
    now=${now%%.*}
    if [ "$((now-started))" -ge 25 ]; then
        echo "afc-$started stop" > /tmp/x2v-product/gui.cmd
        echo "AFC_TEST_AUTO_STOP elapsed=$((now-started))"
        break
    fi
    sleep .2
done
# Manual stop and automatic stop both run stop_session through stop_clip().
# Never cancel AF belonging to a subsequent clip.
echo "AFC_TEST_WATCH_END"
'''
(D/'afc-record-watch.sh').write_text(watch)
for p in [D/'afc-button-session.sh',D/'afc-record-watch.sh']:subprocess.run(['sh','-n',str(p)],check=True)
print(h)
