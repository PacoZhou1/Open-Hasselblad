#!/system/bin/sh
# venc_pipe.sh <dir> <src.nv12> <pics>: test_venc_e2 reading an anonymous pipe as /proc/self/fd/3 and
# writing another as /proc/self/fd/4, the way the resident recorder hands it frames.
d=$1 src=$2 pics=$3
rm -rf "$d" && mkdir -p "$d" && cd "$d" || exit 1
cat > venc.json <<EOF
{"instance_active_num":1,"enable_perf_trace":0,"instances":[{
 "input":"/proc/self/fd/3","output":"/proc/self/fd/4","recon":"","gmv":"",
 "src_width":1300,"src_height":970,"enc_width":1300,"enc_height":970,
 "frame_rate_num":24,"frame_rate_den":1,"bitrate":20000000,
 "input_alignment":8,"input_bitdepth":8,"codec_type":"H264",
 "input_format":"NV12","enc_mode":"storage","enc_pic_num":$pics,
 "hw_core_num":1,"priority":0,"aging":0,"force_i_enc":0,
 "enable_performance_test":0,"enable_bandwidth_test":0,
 "enable_dynamic_frame_rate_test":0,"enable_debug_dump_test":0,
 "enable_force_idr_test":0,"enable_re_encode_test":0,
 "enable_custom_ref_test":0,"idr_interval":24}]}
EOF
t0=$(cut -d' ' -f1 /proc/uptime)
{ cat "$src" | /system/bin/test_venc_e2 "$d/venc.json" 3<&0 0</dev/null 4>&1 1>venc.log 2>&1
  echo "rc=$? t0=$t0 t=$(cut -d' ' -f1 /proc/uptime)" > venc.rc; } | cat > out.h264
chmod 644 ./*
