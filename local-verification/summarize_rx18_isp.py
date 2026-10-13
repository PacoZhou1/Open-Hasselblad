from pathlib import Path
import re,json
R=Path(__file__).resolve().parents[1];P=R/'native-video/outputs/source-isolated-200007';D=P/'device-run';base=json.loads((P/'report.json').read_text());lines=(D/'manual-service.log').read_text(errors='replace').splitlines()
color=[]
for line in lines:
 if line.startswith('X2V_ISP_COLOR '):color.append({k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)})
assert base['passed'] and len(color)==2
assert all(x['width']==1300 and x['height']==970 and x['stride']==1536 and x['planes']==2 and x['observed']>0 for x in color)
assert color[1]['observed']>color[0]['observed']
markers={name:len(list(D.glob('native-*-'+name))) for name in ['color-stop-confirmed','graph-stop-confirmed','graph-teardown-confirmed']};assert all(v==1 for v in markers.values()),markers
result={'scope':'Actual same native graph RAW DNG + ISP color metadata; not encoded proxy or resource-headroom proof','raw':base['delivery_metrics'],'color_source_lifetime_snapshots':color,'native_stop_markers':markers,'restored':base['after'],'native_body_rc':base['body_rc'],'native_recovery_rc':base['recovery_rc'],'proxy_encoded':False,'ISP_color_pixels_read':False,'ISP_full_FOV_or_color_correctness_verified':False,'CPU_ISP_DDR_thermal_headroom_measured':False,'passed':True}
(P/'raw-isp-concurrency.json').write_text(json.dumps(result,indent=2)+'\n')
(R/'research/full-fov-pipeline/RX18_RAW_ISP_CONCURRENCY_20261012.md').write_text('''# RAW + ISP 同时出帧实测\n\n2026-10-12，run `source-isolated-200007`。根代理唯一实机操作者，两段约2.6秒，随后恢复原厂取景。\n\n|项目|第一段|第二段|\n|---|---:|---:|\n|机内DNG帧数|62|63|\n|实际交付fps|23.998844|24.000697|\n|RAW丢帧|0|0|\n|写盘中位数ms|32.886|32.805|\n|写盘最大ms|53.130|53.794|\n|停止到writer完成ms|23.654|39.506|\n\n同一source的color_null/SOUT1回调累计161→388。首次描述：pixel=2，1300×970，stride1536，planeheight970，planes2。回调只拷贝描述信息、保留原生转发/归还；没有CPU处理预览像素。第二次计数增加证明观察期间仍有颜色端口回调，首帧描述是进程寿命级，不是每片首帧。\n\n单流停止0→1及whole teardown均收到本次原生完成回复，最终body/recovery均0，stock Active/Still16bit/None/CropNone，system只读，锁已清除。恢复后的service30022/gui30967。\n\n本次证明RAW写盘与ISP颜色输出可共存并正常停止。尚未接H264编码输出、未检查ISP预览像素/色彩/完整光学视场、未测CPU/ISP/DDR/热余量；不把本次数字作为RAW+硬件代理完成。新写盘中位数比前次RAW-only约多1ms，但非同场景受控A/B，不能据此量化ISP开销。\n\n每段独立目录仍为本run/dng及dng2，帧名frame-000000.dng起。仅回读元数据/日志，无重复全量RAW读取或哈希。下一步：SOUT1→原venc硬件编码支路，原生压缩buffer借用期的有界复制→现有MP4封装；对照短录采样CPU/温度并验证RAW与代理时间、丢帧、停止。\n''')
print(json.dumps(result,indent=2))
