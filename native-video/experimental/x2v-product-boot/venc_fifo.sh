#!/system/bin/sh
# venc_fifo.sh <dir> <frames> <pic_num> <src.nv12> [codec] [bitrate]: feed <frames> copies of one tight
# 1300x970 NV12 frame through a FIFO into test_venc_e2 configured for <pic_num> frames.
# With <frames> 0 the encoder reads <src.nv12> itself.
d=$1 n=$2 pics=$3 src=$4 codec=${5:-H264} rate=${6:-20000000} ext=${7:-h26x}
rm -rf "$d" && mkdir -p "$d" && cd "$d" || exit 1
in=$d/in.fifo
if [ "$n" = 0 ]; then in=$src; else mkfifo in.fifo || exit 1; fi
cat > venc.json <<EOF
{"instance_active_num":1,"enable_perf_trace":0,"instances":[{
 "input":"$in","output":"$d/out.$ext","recon":"","gmv":"",
 "src_width":1300,"src_height":970,"enc_width":1300,"enc_height":970,
 "frame_rate_num":24,"frame_rate_den":1,"bitrate":$rate,
 "input_alignment":8,"input_bitdepth":8,"codec_type":"$codec",
 "input_format":"NV12","enc_mode":"storage","enc_pic_num":$pics,
 "hw_core_num":1,"priority":0,"aging":0,"force_i_enc":0,
 "enable_performance_test":0,"enable_bandwidth_test":0,
 "enable_dynamic_frame_rate_test":0,"enable_debug_dump_test":0,
 "enable_force_idr_test":0,"enable_re_encode_test":0,
 "enable_custom_ref_test":0,"idr_interval":24}]}
EOF
t0=$(cut -d' ' -f1 /proc/uptime)
(/system/bin/test_venc_e2 "$d/venc.json" > venc.log 2>&1; echo "rc=$? t=$(cut -d' ' -f1 /proc/uptime)" > venc.rc) &
i=0
[ "$n" = 0 ] || while [ $i -lt "$n" ]; do cat "$src"; i=$((i + 1)); done > in.fifo
echo "fed=$n t0=$t0 t=$(cut -d' ' -f1 /proc/uptime)" > feed.rc
wait
chmod 644 ./*
