#!/system/bin/sh
# pmprobe.sh: runtime-PM state of the codec interconnect and the H.264 cores while an encoder
# waits 6 s for its input and then encodes 3 frames.
D=/sys/bus/platform/devices
s() { echo "$1 noc=$(cat $D/f3c00000.codec_noc/power/runtime_status) cores=$(cat $D/soc:vc_enc_pm_core*/power/runtime_status | tr '\n' ' ')"; }
s pre
( (sleep 6; head -c 5674500 /data/local/tmp/vin.nv12) | test_venc_e2 /data/local/tmp/vt2.json > /dev/null 2>&1 ) &
sleep 0.5; s t0.5
sleep 2.5; s t3
sleep 2.5; s t5.5
sleep 0.7; s t6.2
sleep 0.5; s t6.7
wait; s end
sleep 3; s end+3
