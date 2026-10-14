# X2D II：4K、无额外裁切、24/30/60 fps、H.265 与 10bit 能力调查

## 2026-10-11 晚间增量（优先于下方较早样本）

- 连续两段机内短录已完整解码：`outputs/bridge-c-real/` 为 162 帧、5.408333 秒、8,852,209 bytes；`outputs/bridge-c-repeat/` 为 369 帧、12.308333 秒、20,115,116 bytes。均为 **1300×970、H.264 High、yuv420p 8-bit，平均约 29.95/29.98 fps，约 13.1 Mbps**。设备和电脑文件 SHA 一致；第二段停止请求到 saved 约 962 ms。短录数据不构成持续帧率/热稳定性验收。
- 原厂 RTP sender 也已静态确认使用 AVC NAL 分类/FU-A。因此切换 HEVC 不能仅改接收器或 MP4 封装；需新的输出路径或同时修正发送端。连续 sensor/ISP 的高分辨率、真实 10-bit 源仍未接通。
- 独立文件编码工具 `test_venc_e2` 支持指定 NV12 输入及 HEVC 输出，已准备 512×384、8-bit、5 帧候选配置。它初始化真实硬件；正常停止/错误取消/缓冲区释放契约仍在核对，**没有执行**。主程序 exit 0 本身也不能作为编码成功证据。
- `dump_topology_info` 内部会初始化并停止流，不能用作无副作用的查询。编码器 sysfs `encoder_status` 只提供软件状态且 show 缓冲区安全未证实；root 只 `ls` 枚举路径与 debug 目录，未读属性内容、未调用 EWLInit。只读回读记录在 `outputs/spec-observation-20261011/`。
- 本轮精确证据和下一步见 `research/codec-capabilities/HANDOFF_NEXT_STEP.md`。**4K 无额外裁切 24/30/60 fps、HEVC/Main10、DNG 连续内录和 Log 均未实测解锁**；仍按传感器源、编码器、传输/封装、回看四段分别验证。

以下为初版离线调查，保留原始样本与分析依据。

日期：2026-10-11。对象：X2D II 100C，官方固件 1.3.16.2。本轮只读本地固件、既有实测记录和一手资料；没有连接相机、调用设备 API、运行生产测试、修改属性或部署文件。

## 结论与证据等级

**值得继续研究 H.265 / 10bit，但现在不能承诺 4K 无额外裁切 24/30/60 fps。** 编码软件栈有明确的 H.265、Main10、P010 / I010 支持和硬件能力检查；目前已知相机预览链路的输入却是小尺寸 8bit YUV。缺口首先是能够连续提供足够尺寸、正确视场和位深的 sensor / ISP 输出，然后才是编码吞吐、封装、回看与持续稳定性。

这里的“静态证实”仅指所检查固件确有该实现或配置；“实测证实”仅限已有样本对应的短时条件。配置中的帧率、编解码库名称和测试脚本均不是实际吞吐证明。

| 目标 | 当前等级 | 确切证据 | 尚缺条件 |
|---|---|---|---|
| 1300×970、8bit H.264 预览保存 / 机内封装 | 短时实测证实 | 已有 USB 样本完整解码；既有 RTP 机内封装报告为 130 帧 | 这不是恒定 30 fps、4K 或持续长录证明 |
| 4K 24 fps，保持完整水平视场 | 候选，未证实 | 通用码率表含 3840×2160/24；编码生产脚本甚至配置 8192×4320 | HB722 实际连续 4K 输出、视场、缩放、端口格式、吞吐均未证实 |
| 4K 30 fps，保持完整水平视场 | 候选，未证实 | 同上；生产脚本帧率字段是 30/1 | 5 帧编码测试配置不能证明实时 30 fps；仍缺传感器 / ISP 来源 |
| 4K 60 fps，保持完整水平视场 | 未证实，约束更多 | 通用码率表含 4K60；存在名称含 `12K_11BIT_60FPS` 的 topology | topology 名称不说明有效成像尺寸；60 fps source、内存与编码吞吐、发热均未知 |
| H.265 / HEVC 8bit 编码 | 强静态候选 | 相机 venc 插件接受 H264/H265；原厂编码测试同时覆盖 H264/HEVC | 未执行该测试；实际硬件 capability、实例创建、输出解码待证 |
| HEVC Main10 编码 | 静态候选 | encoder 的 Main10 capability、10bit 输入及 profile 校验 | 本机 Main10 capability 的实际值未读取；预览 8bit 源不能恢复为真实 10bit |
| 4K60 HEVC Main10 | 未证实 | 只有可组合的软件构件证据 | 不能把各条独立线索合成已支持规格 |
| 原 USB / Phocus encoded-liveview 直接升 4K | 已发现明确阻挡 | 该回调只接纳 1300×970 或 1600×1200，其他 SPS 尺寸进入 fatal | 此限制属于 USB 回调；不等同 RTP-only 也有同一尺寸限制 |
| 用现有 RTP recorder 直接接 HEVC | 当前不支持 | 本项目接收器实现 H.264 RFC 6184，封装为 AVC | 需要 HEVC payload、VPS/SPS/PPS、HEVC MP4 sample entry 与播放器验证 |

“无裁切”须明确为**不额外裁掉水平视场**，还是保留全部 4:3 成像面积。3840×2160 是 16:9；保留原 4:3 全画面则需留边或采用另一输出比例，不能同时铺满 16:9 且不裁不变形。实际视场必须用固定机位、焦距、对焦距离、关闭 MF 放大后的边缘标记比较；输出像素数不证明视场。

## 本地证据定位与身份

以下路径都相对于项目根 `/Users/paco/Documents/ChatGPT/哈苏`：

- `FW/` 表示 `resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/`。
- `QML/` 表示 `resources/gui-resources/3/qt/qml/app/qml/`。
- `file+0x…` 是文件字节偏移；`VA 0x…` 是 ELF 虚拟地址。二者不可混用。函数反汇编可通过已有 `local-verification/disasm.py` 复核；它只在电脑读取 ELF。
- 固件包身份保存在 `local-verification/firmware-check.json`，包 SHA-256 为 `9789d6a9843d388034bc12341ad9a97585c25cb98cf11a0da8b768399b4842f6`，364814336 字节；来源为[官方 1.3.16.2 固件](https://cdn.hasselblad.com/firmware/X2D_II_100C_Firmware/1.3.16.2/X2DII_100C_v1_3_16_2(1).cim)。该旧 JSON 的 extracted 状态不是当前目录是否存在的判断依据。

本轮重新读取的关键 ELF SHA-256：

| FW 内路径 | SHA-256 |
|---|---|
| `bin/camera-service` | `51b9e02f8bfebf388be8dfa163c8e512bee19aeb8ae37a6712727ccc6f26a52d` |
| `lib64/camera/plugins/venc/libdcam_venc_h26x.so` | `7e3819ccddc57207e66a8b562136b2d597a147360f7e0ad2c868712f919f80e5` |
| `lib64/libduml_vcodec.so` | `4f7cdf6d676e4e7829eba44f371ec29474ed596d6d857d450c7f63422b02e9cf` |
| `lib64/lib_vc_encoder.so` | `fb735710c9c55ec4400336ce378f64cb9fdb35808a88214dd25ee52f7fc09210` |
| `bin/test_venc_e2` | `c39765f0f8ab8981835d801b239f5f23ac358bd608559c04e0be0cb09cf2d713` |

## 1. 既有样本到底证明什么

`local-verification/usb-preview/20261011-180543/decode-report.json` 是真实相机 USB 预览在 Mac 保存的记录：100 帧，完整解码及逐帧 hash 对照通过，H.264 High / level 5.1，显示 1300×970、编码块尺寸 1312×976，`yuv420p`、8bit、BT.709 limited，视频约 25.51 Mbit/s。

其 3.320111 秒容器平均帧率约 30.12，报告的 `r_frame_rate` 是 50/1；时间戳增量包含 20 ms 和 40 ms，frame index 有 +1 和 +2。USB byte-52 字段按微秒解释来自观察，不是厂商协议说明。因此不能宣传“稳定、逐帧完整 30 fps”，更不能将标称 `liveview_fps=50` 当成实际录下 50 fps。

`native-video/outputs/native-20261011-182505/report.json` 的 `in_camera_mux=true`、RTP start/stop 返回 Ok、130 帧、6418427 字节和 1300×970，是另一条机内封装短测证据。它证明 H.264 RTP 到本机 MP4 的已跑通路径；不代替本报告未做的高规格编码实验。

`local-verification/stock-recording-attempt.json` 中原厂 `start_recording` / `stop_recording` 返回 Not implemented。`local-verification/recording-api-baseline.json` 记录的 transport 枚举为 None=0、Normal=1、Usb=2、Rtp=4、All=7。

## 2. Sensor / ISP：名字中的 12K60 不等于全宽 4K60

`FW/etc/imx861bqr_hb722.conf` 的直接证据：

| 行 | 配置 | 可以得出的结论 |
|---|---|---|
| 14–17 | still 模式为 4:3 16bit / 14bit / 14bit HS；other 包含 `video_4x3_14bit_f2f` | 带 video 的名称不保证存在通用 video acquisition 模式 |
| 25–38 | 输出 metadata 包含 topology、active area、sensor fps、streaming mode、bit depth、sensor mode、digital zoom ratio | 后续应针对这些已有 metadata 求证，而非盲扫写属性 |
| 62、104 | `TPLG_IMX861BQR_LIVEVIEW_12K_11BIT_60FPS`；帧率调整目标 `5000` | 某 liveview topology 的名称 / 参数存在；不说明其完整有效像素布局 |
| 64 | `yuv_fov_ratio=0.998970,1.0` | 有视场校准配置，仍需实际边缘对照 |
| 78 | still RAW 到 YUV10 SP422 的 reprocess topology | 静态照片的 10bit ISP 输出证据，不是连续视频输出证据 |
| 84、89–90 | no_crop=`0,0,11656,8742`；16x9=`0,1092,11656,6556` | 静态照片 16:9 配置保留水平宽度、裁上下；不能直接移植推断视频 |
| 99 | `ienc_hevc`、image encoder | 静态照片 HEVC 编码不能证明连续 Main10 视频 |
| 113–116 | H.264 pool 32 MiB，最小块 300 KiB、threshold 1000000 | 高码率 / 大 IDR 的内存及分配约束需要另核，不能只改 bps |
| 120 | liveview GDC 的 `in_scaler=1300/11656`，另有 MF zoom bypass | 预览缩放与放大路径会影响输出；还不是 4K source 证明 |
| 161–171、198–229 | 重复预览 buffer 为 1600×1200、YUV8 SP420、variable resolution | 目前直接可见的持续 YUV 路径是小尺寸、8bit |
| 231–245 | liveview_rtp / normal_before_venc 均为 1600×1200、YUV8 SP420、`DCAM_FPS_3000` | RTP 编码来源同样是这一预览层 |
| 247–251 | normal_after_venc 为 1300×970、`DCAM_FPS_3000` | 与已有样本尺寸吻合 |
| 253–265 | zoom_in 的 before / after_venc 为 1600×1200 | 放大路径并非高规格全视场输出 |
| 2730–2755 | 注释 F2F Reprocess for still liveview；输入 7408×1482 RAW16 opaque、6000；输出 1300×970 YUV8、6000 | 此 video_4x3_14bit_f2f 是 still liveview 的重处理；RAW16 容器不等于 16 有效位或完整照片布局 |
| 3228–3303 | 校准的高速 RAW 为 3920×986；全尺寸 11656×8742 RAW16 opaque 配置为 1000 | 校准路径不是正常视频模式；其存在不能证明全尺寸 24/30/60 fps |

`FW/etc/imx861bqr_hb722.sp:696–744` 的链路是：

`liveview_rtp → shadow_liveview_2 → streaming_mode_convert_1 → normal_liveview_before_venc → venc_1 → normal_liveview_after_venc → rtp_eng_1`。

这里 stream 为 repeating，部分 on-demand、low priority。`variable_res` 表示尺寸可变的 buffer 契约，不代表所有 4K 尺寸合法。

`FW/lib64/camera/plugins/hal/libdcam_cam_info_e2_hb722.so` 的 `file+0x6fd4` 为 `TPLG_CFG_IMX861BQR_LIVEVIEW_12K_11BIT_60FPS`，`file+0x763a` 起有 12K60、7K100 calibration、12K10 calibration 和 MF zoom 的名称。port_info 数据结构 ABI 尚未解清，不能用未类型化整数猜 sensor ROI、binning 或实际吞吐。

## 3. camera-service 的默认 profile 与 USB 硬限制

`DCAMCaptureEnginePrivate::initRecording(E_DCAMStream)`，VA `0x286330`：

- `0x286364–0x286374` 将数值 8 写入新配置的 `+8` 字段；没有结构定义前不单凭此字段断言位深，已知 8bit 由配置 / 实际 SPS 另行证实。
- 流 ID 5、6 分别用数值 3000、10000；二者分支均用 resolution ID 46 (`0x2e`)。
- `0x2863cc` 调用 `cam_cap_video_resolution_to`，`0x286408` 调用 `cam_video_bps_get_by_v_format`。
- `FW/lib64/libdcam_frwk.so` 的 `cam_cap_video_resolution_to`（VA `0x21230`）中，ID 46 的 jump-table 分支到 `0x214c4`，最终写 1280×960。**这是码率选择的 nominal profile，并非实际 SPS 尺寸**。
- `0x2864e8–0x286538` 根据 transport bit2=RTP / bit1=USB 选择不同返回字段作为码率参数；因此不能把一个传输路径的码率选择外推到另一条。

`DCAMCaptureEnginePrivate::onEncodedLiveviewStreamBuffer(...)`，VA `0x2a0240`：

1. `0x2a0384–0x2a0390` 读取 transport mask，`tbz w8,#1,0x2a1e1c`：**未开 USB 位即跳过后续 USB 处理**。
2. `0x2a0418` 调用 `sps_parser`。
3. `0x2a0424 / 0x2a042c` 比较 1300×970；`0x2a048c / 0x2a0494` 比较 1600×1200。
4. 其他尺寸跳到 `0x2a1f00`，报告错误后，`0x2a1fa0` 引用 `Unsupported encoded liveview resolution`，`0x2a1fc0` 调用 `QMessageLogger::fatal`。该字符串为 `file+0x6bbc6e`。

这证明**沿原 USB / Phocus encoded-liveview 回调直接改大分辨率可能终止 camera-service**，不是一个可以靠短超时保护的普通失败。RTP-only 不经过这一 USB 尺寸分支，仍需独立确认 venc / RTP 路由的 codec、分辨率和 buffer 契约。本轮没有补丁绕过检查，也没有测试这个 fatal。

## 4. H.265 与 Main10：确有编码实现，但 capability 值未知

以下证据来自 encoder，不依赖 VideoItem 的解码能力或 SoC 型号宣传：

| 文件与 file offset | 证据 | 边界 |
|---|---|---|
| `libdcam_venc_h26x.so +0x11807` | `codec_type == CAM_VENC_CODEC_H264 || codec_type == CAM_VENC_CODEC_H265` | 相机 venc 插件接受两种 codec 的代码存在 |
| 同文件 `+0x11b4f` | 配置日志含 input_res、venc_res、bps、enc_fmt、pix_fmt、fps、enc_mode、rc_mode、idr、use_hlg10 | 可用来核对未来单次已知参数实例，而非猜全局属性 |
| `libduml_vcodec.so +0x4353c` | HLG 仅能用于 10-bit source 的检查 | 真实 10bit 源是前提，8bit padding 不是提升动态范围 |
| 同文件 `+0x43895 / +0x43981` | 实例输入 / 输出尺寸、pix_fmt、bitdepth、stride、use_hlg10_encoding 的日志 | 是具体配置可观测点；不证明当前实例已使用这些能力 |
| `lib_vc_encoder.so +0x61e8c` | 输入格式含 I010、P010、PACKED10BITPLANAR、RGB101010 | ABI 中有 10bit 输入格式；各入口枚举不能互相混用 |
| 同文件 `+0x62856` | HEVC hardware encoding supported 的 0/1 capability 描述 | **没有读取本机的实际 0/1 值** |
| 同文件 `+0x62903` | Main10 hardware supported 的 0/1 capability 描述 | **同样没有读取实际值**；这是候选而非承诺 |
| 同文件 `+0x62b41` | HEVC 最大宽度 capability，单位 8 pixels | 需本机 capability 值，不能拿库中的最大常量当设备上限 |
| 同文件 `+0x6ed91` | HEVC_MAIN_10_PROFILE / H264_HIGH_10_PROFILE 校验 | 10bit profile 代码确实存在 |
| 同文件 `+0x70fe5` | 运行时拒绝不支持 HEVC 的 hardware coding core | 明确说明同一库可以支持不同硬件能力组合 |

`VCEncGetAsicConfig`（VA `0x275c8`）、`EWLReadAsicConfig`（VA `0x5efa8`）不是已证明安全的高层状态接口。后者包含 ioctl `0x6b0d`、mmap / munmap；反汇编还显示 x8 隐含结构返回。没有匹配头文件 / 结构 ABI 前，**不应自行 ctypes 调用、猜结构大小或直接读取寄存器**。优先找既有诊断输出或解析程序自身已知配置和能力日志。

`FW/bin/test_venc_e2` 的 `file+0xbc7a / +0xbca4 / +0xbcb3 / +0xbcda` 分别含 src_width、frame_rate_num、frame_rate_den、input_bitdepth；`+0xbe2a / +0xbe3a` 含 NV12_10 / NV12_16。其标签与底层 P010 / I010 的存储布局、stride、枚举映射仍需确认。

`FW/bin/dji_production_check_h26x.sh:3–10,24–37,55–68` 配置 8192×4320、30/1、30 Mbit/s、NV12 8bit、双 core、5 帧，分别用 H264 和 HEVC，并比较固定 MD5。`enc_mode` 的原始拼写为 `stroage`。这是一条很有价值的**厂内合成源测试线索**，但脚本的存在既不能证明测试曾在这台机身成功，也不能证明传感器输出或实时 8K30 / 4K60。

不要直接运行原生产脚本：它使用固定 `/blackbox` 路径、删除文件、分配大图像，并占用编码资源。未来如采用同一测试程序，应先读清调用与 buffer 上限，再生成本轮独立目录 / 小尺寸 / 极少帧数的专用配置。

## 5. 码率表、USB 与 SSD：压缩后带宽并非首要否定条件

`FW/etc/dji_camera_codec_bps.conf` 明确标为 common bps sample：AVC 的 4K24/25/30 在第 33–35 行为 100 Mbit/s，4K60 在第 48 行为 120 Mbit/s；HEVC 对应第 109–111 / 124 行同样为 100 / 120 Mbit/s。该表同时有其他分辨率和格式，不能视为 HB722 已支持模式清单。

`FW/etc/dji_camera.conf:87–93` 的紧凑 AVC 配置包含 1280×960/30 或 60 的 20 / 25 / 50 Mbit/s 档及 1280×960/100 的 30 / 50 / 70 Mbit/s 档。两份配置的实际加载优先级和质量档映射未完全解析；不能只改其中一处就声称成功提码率。

官方规格给出 USB 3.1 Gen2 Type-C、理论 10 Gbit/s、1 TB SSD；官方产品页给出 SSD 写入最高 2370 MB/s。这里引用的是产品规格，未测当前 USB 协商速度、有效载荷吞吐、SSD 当前空闲量或持续性能。[官方数据表](https://cdn.hasselblad.com/f/77891/x/15b206e1b9/x2d_ii_100c_datasheet_multi_20260416.pdf)、[官方产品页](https://www.hasselblad.com/zh-cn/x-system/x2d-ii-100c/)。

3840×2160 的单向净像素带宽估算如下，单位为十进制 MB/s，未加 stride、对齐、元数据、重复拷贝或协议开销；不是实测：

| 帧率 | NV12 8bit，1.5 B/px | 紧凑 10bit 4:2:0，1.875 B/px | P010，3 B/px | Bayer RAW16 容器，2 B/px |
|---|---:|---:|---:|---:|
| 24 | 298.60 | 373.25 | 597.20 | 398.13 |
| 30 | 373.25 | 466.56 | 746.50 | 497.66 |
| 60 | 746.50 | 933.12 | 1492.99 | 995.33 |

100 / 120 / 400 Mbit/s 压缩流分别只需约 12.5 / 15 / 50 MB/s。由此推断，若能在机内完成编码，压缩流写 SSD 的名义带宽不像首要瓶颈；必须先核 sensor / ISP、内存流量、编码能力与热稳定性。反之，4K60 P010 原始数据约 1.493 GB/s，已大于 USB 10 Gbit/s 的 1.25 GB/s 理论上界；这仅针对原始 P010 外传，不能用于否定机内压缩编码。

官方 HEIF 10bit、3FR 14/16bit 是**照片**格式规格，不是 10bit 视频声明。[官方数据表](https://cdn.hasselblad.com/f/77891/x/15b206e1b9/x2d_ii_100c_datasheet_multi_20260416.pdf)。

## 6. API、封装与回看不能跳过

`local-verification/camera-api-probe.json` 是已有只读 introspection 记录，出现 `video_resolution(int)`、`liveview_fps(uint)`、`image_bit_depth(E_BitDepth)`、`color_profile(E_ColorProfile)`、`stream_group` 以及 `set_live_view_extended(bool, E_LiveviewTransportMode)`。还出现：

- `dump_topology_info(E_StreamGroup, QString topology_name, QString file_name)`、`dump_all_topology_infos()`。
- `setup_dcam_stream_group`、`start_dcam_stream`、teardown、`set_dcam_stream_state`。

**存在于 introspection 不代表实现了、有效或可安全写入。** `image_bit_depth` 的 14/16bit 是照片语义，不是视频 10bit 开关；`video_resolution` setter 出现也不证明当前 camera mode 有对应控制链。topology dump 会写文件，且 camera-service 有 session 排他检查；下一轮若使用，只能定向、单次、私有路径，并先确认空闲，不能与现有录制并发。

原 QML 有 `CameraUI.capabilityVideo` 分支（`ControlScreenViewModel.qml:68–76`、`LiveviewViewModel.qml:107–110`），但 `StateMachineViewModel.qml:345–346` 的 video record 操作仍是 TODO / 注释；`BrowseViewViewModel.qml:66–68,378,384,390` 的若干视频状态 / 播放调用同样未接通。`FirstTimeGuide.qml:294–300` 的 VideoItem 用于原厂教学视频。这说明 UI 遗留接口与可播放视频存在，**不证明 camera acquisition 和 HEVC Main10 编码已开放**。

本项目 `native-video/src/rtp.c:1,23–30` 实现 H.264 的 single NAL、STAP-A、FU-A；`recorder.c` 使用 AVC 参数和封装。HEVC RTP 使用另一个 payload 规范，不能仅把 codec 设置为 HEVC 后继续复用。需要 VPS/SPS/PPS、HEVC depacketization / AU 划分、hvc1/hev1 sample entry、时间戳及关键帧完整性检查，然后分别验证桌面解码和机内 VideoItem。[IETF RFC 7798](https://www.rfc-editor.org/rfc/rfc7798)。

Main10 不等同 Log；HLG 的 flag 也不等同完整色彩管理。Log / HDR 成果需另外证明 ISP 转换、transfer / primaries / matrix / range、编码 VUI 和容器标签一致，不能靠标签或 8bit→10bit 补位制造规格。

## 7. 最小且有边界的后续探测顺序

以下是候选设计，**本轮全部未执行**。必须与 GUI / recorder 的统一互斥锁协调，不重启 camera-service、不改启动项、不修改原厂文件或图库索引。短超时不能保证错误 ioctl / 不兼容 topology 不影响服务，因此先过静态契约检查才可进入设备试验。

1. **零参数改动的观测。** 优先解析既有流 SPS、metadata、日志中的 active area、topology、input / venc size、pix_fmt、bitdepth、stride、fps、codec；记录重复帧 / PTS / frame index。若已有日志提供 ASIC flags，直接解析。不能为“只读能力查询”调用 ABI 未明的 VCEnc 函数。
2. **基线视场确认。** 在既有稳定预览 profile 下以固定焦距、固定对焦和静态边缘图案比较照片 / 预览，并记录 digital zoom、active area、GDC。照片比例裁切和防抖边缘变化要单独记。现有 1300 输出只能确认基线 FOV，不证明 4K 细节。
3. **定向 topology 导出候选。** 如果可确认 dump 的实现和空闲条件，只导出当前已知 HB722 liveview topology 到本轮私有文件；约束文件大小与执行期限。解析具体输入端口、有效 ROI、像素 packing、缩放和可用 YUV 输出后，才能决定是否存在足够大的连续 source。禁止仅靠 `12K60` 字符串选择 topology 或盲写 video_resolution。
4. **独立合成源编码候选。** 先读清 `test_venc_e2` 的输入布局、错误退出和 core 占用，再在完全空闲时，以每轮 nonce 目录、640×480 NV12、最多 5 帧、5 秒外部 watchdog、小容量文件上限，分别验证 H264 / HEVC8；保存 stderr、实际 capability / 返回码、输出 bitstream。此步只证明 encoder，不能触发原 USB liveview 回调。不能直接复用会删除固定路径的生产脚本。
5. **10bit 单独验证。** 先恢复 NV12_10 / NV12_16 到 P010 / I010 的准确 mapping，再以小尺寸合成 10bit 阶梯输入验证 Main10 SPS、实际 bit depth 与解码像素。失败即保留原始错误，不尝试关闭 capability 检查或连续枚举格式。通过仍不代表 ISP 能给真实 10bit。
6. **分辨率与吞吐阶梯。** 合成源小样通过且内存预算明确后，先 4K 单帧 / 极少帧，再最多数秒的 24→30→60 目标；每阶段记录墙钟与单调时间、提交 / 编成帧数、PTS、丢帧、队列、内存、输出字节及温度。码流 nominal fps 不是实际编码速度，5 帧完成也不是长录证明。
7. **接传感器排在最后。** 只有 source 尺寸 / 位深 / 视场和编码能力分别证实后，才设计不触发 USB fatal 的独立、可回滚、严格有界路径。RTP-only 只是绕开已知 USB callback 的条件，仍需核固件 RTP packetizer 的 HEVC 支持。第一轮传感器短测应同时保留原有 baseline 参数、stop 确认和完整恢复读回；发生错误不继续提规格。

长期录制、4K60热稳定性、AF-C / LiDAR / 人脸识别与高规格 stream 的资源共存，均为后续独立验收项。当前报告没有把静态资料、合成源候选或教学视频播放当作这些能力已实现。

## 21:46 机内基线增量

Bridge d 新实片 `X2V_20261011_133634_21102_1`：1300×970 H264 High/yuv420p，159帧/5.308333秒，实际29.953fps、19.95Mbps；整片解码和相机/主机SHA一致。这说明之前13Mbps不应描述成固定上限或已开放的码率档位。机内软件首帧和原厂播放器3次停止释放重开+自然结束回归也通过，见 `INTEGRATION_20261011.md`。

用户已要求超越现成开关继续自研，完整视场优先。下游软件原型在 `experimental/hevc/`；sensor/ISP全视场源调查在项目根 `research/full-fov-pipeline/`。其短合成样片与静态模式表不构成机身4K/HEVC/10bit/60fps或无裁切证据。
