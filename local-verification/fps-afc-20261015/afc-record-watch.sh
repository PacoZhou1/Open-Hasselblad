#!/system/bin/sh
set -u
clip=$1
status=/tmp/x2v-live/status.json
field() { sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" "$status"; }
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
