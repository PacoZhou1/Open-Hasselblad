# 高分辨率来源接入：首个实机 RAW 样本

## 2026-10-12 00:51：恢复锁实机通过、全幅彩色 Main10 单帧机测成功

- e实机保留失败：UI流程成功，但Android mksh空exec9设置CLOEXEC，flock9实际BadFD，三个恢复者均失败。root用冻结d控制器仅恢复e，stockGUI6812/service28857正常。实机纯文件probe证实`toybox flock -n 8 8>&9`成功，父9持锁/关闭释放。证据在e/product-qa/fd-probe-and-mcu-version.json；不要复用坏e包。
- runtime最终SHA `a671f5e300894c56ddd5440049574240443fee051d32a411aefe2a75f8c26379`，真实host mksh R56+C flock和过程故障20项通过。报告outputs/runtime/gui-session-mksh-host-tests.json。f完整实机回归 **passed=true**：outputs/gui-sessions/native-album-product-f/product-qa/report.json。冻结d UI不变，2300项，最新单张→3/5列→video playing→stop idle→照片新identity ready，QML错误0；recover rc0/ORIGINAL_GUI_CONFIRMED、restored、stockGUI9757/running、service28857不变，bridge停/18762移除。supervisor TERM exit.code1与恢复rc0分开。f屏幕审查50帧/stop完整。
- **机内3840×2880彩色HEVC Main10单帧成功**：outputs/ffhevc-004844/validation.json。自有新增helper `/system/bin/x2v_ffhevc10_20261012a` SHAe03369f8ec2aac416ba3a023d000cce2dc55b69f6b93c72cb61a22e4f93b3bb9；stage后/system ro。输入B3648原始全crop11656×8742在HOST去马赛克/缩到3840×2880 Rec709 10bit，普通FD CPU单张编码；不是实时源。限额256MiBAS/30sCPU/40salarm+42stimeout、350MiB可用内存门。
- 实机rc0、8946059B，SHAa0175b793762f26dfc0978503c265b4fd8026cac3697238462424bade14c1cad；RSS208720KiB约204MiB、CPU18.42s、含launcher墙钟31.02s。Main10 idc2/yuv420p10le/3840×2880，HEVC+hvc1完整decode同host SHA07880977fd60e2b9ab199771d4cc857834c2dfbbc957196318d7bed187df60f7。QP0有损max11/RMS0.9766。**软件单帧不是实时4K方案，不把指定1s时间线当录像。** 原process pending字段保留，最终validation独立关联SHA。
- 当前健康：service28857/gui9757均未因CPU试验重启，Active/None/Still16bit/CropNone，frame_count516→2371，/systemro；MemAvailable374024→399280KiB。保活继续，未替换原厂固件/启动项。
- MCU实质证明冻结于research/full-fov-pipeline/exmcu-mode-contract/mcu-handler/README.md+11checks：实际0f/11 handlers→SensorImx861 ops→17–20各345寄存器列与libsensor一致。root原厂只读exmcu firmware_version回apps_messaging_version=b9558bd/firmware_version=f991af，与.cont实际响应构造匹配。不能把全机real_version_id或buildIDs当flash全SHA/运行模式成功。group12 HOLD继续，3884×2914连续源仍未取得。
- 并行下一步：native_album代理新mode21-profile-plan梳理HB23→52与17–20的host尺寸/SLVS/ROI/buffer/ISP差异，不能单改conf；codec代理新目录给硬件HEVC最小接口/退出契约（无实机/DMA）；UI代理独立record-album QA走UI handler、3s录制意图/保存最新clip/点播放。shared UI/runtime/d/f冻结；实体快门录像未实现，脚本不能代证触控。
- root新增local-verification/full_frame_hevc_device.py（默认dry）并增强album_product_test.py失败门。当前无root长命令，goal active；未commit/push。用户系统问题已答：Linux5.4.123-rt59+Android9/API28+Qt，4xCortex-A55(41/d05)，DJI Eagle2 HB722 V5，商业SoC料号未确认。

## 2026-10-12 00:16 更新：group12 实机失败，已恢复，禁止原样重试

- 恢复后的原厂单张拍摄也已实测通过：`native-video/outputs/highres-source-20261011/still-reference-001559/`，新照片B0003649保留原DCIM。RAW213078016B/SHA06c5cd1b9e91d9d17b6c44939c442f9c572432a56345e799f9ffe0c57266ad64；HEIC64935936B/SHA9c90d2cd9b26f96f14050aab0ed5d3c0a3ad8534a708f6bd34645bf5ec36cae5。回读等于源；LibRaw解包全部11904×8842 uint16样本，crop11656×8742，正常；service28857/gui21497保持。不是视频来源成功。
- 新恢复后只读fps：fixed_fps25/liveview_fps50/slowburst_liveview_fps100/Image0。静态updateFpsList fixed分支×2与50吻合；auto分支最小15，不是9/10fps修复。尚不改变fps、不重试group12。最新8项host模型（含执行封锁前置、命名PID）通过。

- 原厂全尺寸 RAW profile 的零 dump 生命周期试验 `native-video/outputs/highres-source-20261011/g12-life-001048/` **失败**。setup12、start1、stop1 的 D-Bus reply 均成功，但没有取得有效 RAW 帧；`disp_null` 消费数是0。setup 实际已启动流，额外 start1 是 already active。不能把 API rc0 当作出图。
- 更早于 teardown 的日志已出现 SLVS 接收尺寸不符（期望11760×8866，收到行数1790、宽0）、1500ms 无帧后原厂 SysMon 自动 reset sensor。teardown 期间 e2_segment_mgr.c:787 的 ioctl=-22，788 触发断言；camera-service 从380自动重启为28857。控制器发现 PID 变化后停止继续发送恢复命令，restore.rc/watchdog.rc=42；不是正常停止成功。
- 原厂自动恢复后独立只读核验 `recovery-readonly.json`：service28857、stockGUI21497，Active/None/Still16bit/CropNone，所有曝光/流方法空闲，frame_count5206→5263，/system只读，拍摄格式仍RawHeif/All。未改启动配置、未执行camera-expose、未写sensor寄存器或刷固件。没有把服务崩溃说成机器变砖，也不以自动恢复证明该高分辨率路径安全。
- `local-verification/profile12_lifecycle.py` 已加 EXECUTION_HOLD，--execute 在访问设备前拒绝原样重跑。controller 保留用于离线分析。其最初7项host fault model通过只证明shell门/错误记录/互斥，不覆盖sensor/HAL。另修复 `pidof camera-service camera-gui` 输出不按参数排序的假设，今后分别查询命名PID。
- codec 与 native_album 两位 sol/high 子代理正分别查高层capture和直接stream流程差异、sensor ioctl/时序，以及真实frame/metadata路径。原3884×2914目标仍未取得；不能用已验证单张全幅照片、host重复帧HEVC或现有3884×970 ROI替代。
- 前一步 UI candidate-c 实机照片/视频混排、单张身份握手、视频播放停止均通过；candidate-d修缩略图定位和metadata刷新抖动，54项桌面Qt检查通过，尚未装机。c完整屏幕审查已从已有日志恢复46帧，`outputs/screen-audit/native-album-product-c-complete/`；原logger EOF证据保留。


## 23:43 更新：全幅彩色下游参考与原厂取帧工具

`experimental/full-frame-reference/evidence/real-still-3648-final/` 已用实际原厂3FR的完整
11656×8742声明画幅生成3840×2880线性RGB16母版，再分别生成Rec709和自有X2V Log2的
HEVC Main10/hvc1参考片。全程在电脑执行，两片均重复同一张照片4次，不是机内连续录像。
未使用1300×970或3884×970放大；LibRaw处理不等于原厂HNCS。完整解码通过，CQP0仍有损，
实测误差和未编码RGB16/YUV10母版保留。X2V Log2为自有可逆曲线，不叫DJI D-Log，标准transfer标为unspecified。

原厂 `camera-expose` 另有明确 `LiveviewZoomFullFovRaw` 单帧入口并自行分配ImageMemory，
设备程序SHA与提取件待逐项审计；当前只读取SHA与状态，尚未执行该工具。
需要核实客户端超时和服务端共享内存持有、结束后取景恢复，再做有界单帧实验。
这条路径的静态目标为11656×8742 RAW；它仍不是已取得的3884×2914连续流。

## 23:32 更新：原厂全尺寸 RAW / 硬件 Main10 / 自有机内 DNG

通过公开 `do_exposure_extended2(true, ForceSingleExposure=4, 6000ms)` 正常拍摄一张
`B0003648`，保留原有 RawHeif 设置，取得 213,073,920B 3FR 和 64,563,200B HEIC。
没有启用 calibration stream、修改传感器寄存器或启动项。原图仍由原厂正常写入相册；
研究副本在独立 blackbox 目录。单张方法正常 ACK，拍摄时原厂服务380/GUI9278
保持不变，拍后 Active/None；后续 GUI14966 是有意相册测试后的恢复进程。
证据 `outputs/highres-source-20261011/still-reference-231424/`。

实际原厂 HEIF 编码日志确认 `pix_fmt=1003, bitdepth=2`；主图分为12个3072×2916图块。
回读文件全部12个主图块均为 HEVC Main10 / yuv420p10le，并通过完整软件解码。
这是实际硬件静态照片编码证据，不能用图块数或日志配置帧率推算连续录像速度。

完整3FR由独立LibRaw和tifffile解出11904×8842 uint16 RAW，原厂DefaultCrop为
11656×8742（完整4:3）。这张静态照片提供了真实全尺寸参照；它没有解决 mode52 的
3884×2914连续图像源。Linux约937MB内存也不是影像内存上限：只读ION统计显示多个
独立保留内存区，正在按实际heap评估全尺寸取景配置，不能据Linux MemAvailable判定不可行。

**自有机内DNG转换成功**：`outputs/dng-232855/validation.json`。静态ARM64 helper
`/system/bin/x2v_dng_20261011a` 在普通文件间流式复制原始像素，约5秒（秒级计时），rc0。
输出210,514,432B，设备和电脑SHA均为
`442841d226decbcffc3e9692b08034d6a7ace86df4b1474c6a01f51effcd2a12`。
两种独立读取器验证全部105,255,168样本逐字节一致，原厂crop/black/white/matrix/neutral
标签保留，源SHA未变。转换前后service380/GUI14966相同，取景Active/None且帧计数增长，
/system恢复只读。该helper不持有相机或DMA句柄；CPU10秒、wall20秒、32MiB地址空间、
256MiB输出上限，独占partial后禁止覆盖发布。

第一轮主机源SHA查询超过1.1秒USB接收期限，未启动转换；第二轮转换本身成功，但随后
pidof查询也超过该期限。两份原始失败报告均保留；延长纯查询接收期限后的独立回读确认
正常状态与产物，未因查询失败重复拍摄或重新转换。这些是控制观测超时，不是codec崩溃。
当前仍不宣称连续DNG、Phocus渲染色彩一致或新格式已进入机背录像菜单。

## 晚间新增实机证据：实际 mode52 与 CPU HEVC 10bit

本节优先于后面的早期快照。`outputs/highres-source-20261011/zoom-source-224240/`
记录一次正常原厂放大对焦开关（`set_zoom true`，约3秒后 `false`），带独立8秒恢复。
原厂日志实际出现 readout52、`IMX861_4K3K_11b_MDJI_A2_100P`、7408×1482，
随后 fps 更新为5000/100。这补上了当前 normal source 的运行模式证据。
已加载 `librcam.so` 的设备SHA与提取件一致；该库内含同一传感器表及HB exmcu驱动。
之前“libsensor未加载因此无法判断真实控制层”的调查现在推进到实际 `librcam` 路径。

**没有因此取得3884×2914图像。** 已有可读ROI仍为3884×970；不能按模式名称、active_size
或7408×1482容器直接reshape。原厂放大路径转到MF_ZOOM、局部1600×1200，不能作为全视场4K。
测试时 camera-service380、GUI25589未重启，zoom=false、Active/None恢复；原厂转换警告保留在日志。

`outputs/software-hevc-device-20261011/` 已完成一帧640×480真实RAW灰度裁片的机内CPU HEVC10bit编码。
安装自有 `/system/bin/x2v_swhevc10_20261011a` 后恢复/system只读，没有替换原厂程序或启动项。
首次运行因Android shell分开的FD重定向未通过FD检查，rc3/0字节；改成同一exec语句上的FD3/4后
rc0、81,839字节，输出SHA `0cad61d8a331383b9af2a83c1ee88ff5991cfb7d6f7fe75c371b0e3b7b35f723`。
设备/宿主SHA一致，HEVC完整解码921,600字节与输入逐字节相同；宿主hvc1 MP4封装/解码通过。
**实际profile为Rext，非Main10**，此单帧设置触发了x265的Main10 Intra约束；目录名 `verified-main10` 是早期命名，
以mux-report.json实际SPS/ffprobe结果为准。

**23:04 标准Main10已在相机端单独验证。** `outputs/swhevc-230353-lossless/`
使用同一有界CPU helper，连续编码5份相同的640×480真实RAW诊断输入，rc0、约1.70秒（含launcher）。
SPS/VPS `general_profile_idc=2`，ffprobe为Main 10；完整HEVC及宿主hvc1封装解码
4,608,000字节均与输入逐字节一致。设备/宿主输出SHA为
`2d62ef5b2f314dccc53243167964ef5b9005e7be560d0f2b7e09e89268433f1c`。
5帧重复输入不代表连续采集或30fps性能；原厂service380/GUI9278未重启，Active/None，/system只读。
独立CQP0候选只有宿主验证，未安装；不把该候选的有损结果混入上述无损证据。

此为CPU文件到文件的单帧诊断，不是连续采集、彩色ISP、4K实时编码、机内MP4封装或机背回放证明。
编码helper持有普通文件FD，没有相机/DMA/驱动句柄，CPU6秒、wall8秒、256MiB地址空间和32MiB输出上限。
相册只读探针另有意重启临时GUI；进入原厂Browse导致取景Off，之后已用正常set_live_view(true)
恢复Active/None，帧计数37→79，service380/stockGUI6676。不能把相册会话的界面重启归因于编码器。

2026-10-11，固件 1.3.16.2。原始证据目录：
`outputs/highres-source-20261011/raw-one-20261011-221456/`。

## 本轮实际结果

已从原厂正在运行的照片取景流取出一个 RAW 容器及元数据，未切换传感器、重启服务或修改固件。**目标 3884×2914 连续源仍未接通**；这次实帧校正了上一轮只凭静态表与容器尺寸提出的候选关系。

| 项目 | 实际证据 |
|---|---|
| 原厂调试端口 | `liveview_sbpc_basic-inport0Dmp`，单端口、`total=1` |
| 输出 | 一个 22,004,736 字节 RAW 容器；53,461 字节 metadata；misc 和 buffer-info |
| 容器 | 7408×1482；行跨度 14848 字节，精确满足 `14848×1482=22004736` |
| 实帧取景拓扑 | `TPLG_IMX861BQR_LIVEVIEW_12K_11BIT_60FPS`，实帧 metadata 帧率字段 50.0；名称中的 60 不作实测值 |
| 原厂 SBPC 日志 | `x=18,y=512,width=3884,height=970,stride=7424 words`，后续输出 1300×970 |
| 离线可还原性 | 按上述精确 ROI 读取 uint16le，已得到连贯灰度实景；尚无正常彩色 ISP 输出 |
| 视场 | 原厂 crop=None，sensor/digital zoom=1；未作完整 RAW 照片四边比对，不能证明完整光学视场 |
| 关闭 | 初始 disable、单帧 arm、主动 disable、独立 watchdog disable、trap/host finally 均获原厂 ACK |
| 恢复/持续工作 | camera-service=380、camera-gui=25589 前后不变；Active/None/Still16bit；稍后纯读取帧计数 100105→100140 |

四个源文件与电脑副本的 SHA256 均相同，见 `files-manifest.json`。RAW SHA256：
`e4e6af76827654b8a7294cc2677b48a8916677aee6cff845598d44ac3e835d23`。

文件后缀由原厂生成成 `.yuv`，不能据此把该 RAW16_OPAQUE 容器解释成 YUV。ACTIVE_AREA 元数据仅描述当前 7408×1482 缓冲区，缺少 SENSOR_MODE/REAL_SIZE 等字段；它也不能证明 3884×2914。

容器上方 512 行还有其他数据，下面 970 行的右侧大段为零。不能把这些区域拼凑、拉伸成 2914 行，也不能将 1300×970 放大成 4K。后续必须找到实际目标模式的选路、打包方式和采样规则。

## 本次上机边界

根代理是唯一设备操作者；子代理全部只做离线工作，均使用 gpt-6.1-sol/high。执行程序为 `../local-verification/highres_one_frame.py`，默认只打印计划，显式执行时核对固件、状态和独立审查证据。

原厂存在本地 dump 与全局 CamDumpController 同帧命中的断言风险。本次没有猜测 XML 默认值：通过 `/proc/380/maps` 和只读 `/proc/380/mem`，核验全部 20 个控制器槽，两个非空实例均 state=-1，两个函数指针与已审查 ELF 相符，前后表内容一致。执行前重新检查同一条件。未写内存、未 ptrace、未暂停进程。具体偏移、ELF load bias 和清单在 `../research/full-fov-pipeline/consumer-abi/`。

使用原有 SSD dump 根，执行前设备端确认目录不存在；只启用一个端口一帧。采用原厂异步持有/归还引用的路径，没有从未知 ABI 自行借用或释放 DMA buffer。5 秒独立 watchdog 和清理仅关闭未来导出，不冒充已排空 worker。

运行时日志明确记录一次 dump 开始和写入成功；随后同一协程有约 0.869 秒运行段耗时 warning。该 warning 不是独立的引用归还事件，不能单独用它证明 release。原厂 worker 普通成功/错误路径上的 ref-- 来自静态审查；相机持续交付帧和服务不重启是本次运行证据，二者分开记录。

日志在 arm **之前**已有 `ack timeout is less than monitor interval`、still reprocess 等待和 segment polling timeout 信息，不能说整个日志没有 warning/error，也不能把它们全部归因于此次取帧。没有观察到本次双触发断言或服务重启。

本轮没有刷固件、改启动项、写寄存器或修改 `/system` 文件；最终 `/system` 仍为只读。自有控制脚本/日志与取样副本保留在 `/blackbox/x2v-native-20261011/runs/raw-one-20261011-221456/`，原样本在 SSD `camera_dump`，没有删除照片或写入 DCIM。

## 真实 RAW 到 HEVC Main10：电脑端已验证

`experimental/raw-source/frame_adapter.py` 已实现有严格文件哈希、元数据、行跨度和 ROI 边界校验的读帧模块，保存原始 uint16 数据，再直接保留高10位。没有经过8bit中间步骤。8项测试包括错误哈希/长度/元数据/越界拒绝，以及合成3884×2914输入的适配；合成尺寸测试不是实机目标源证明。

这份实机样本的3884×970 ROI 已在电脑上编码成一帧 HEVC Main10 和 hvc1 MP4。HEVC 与 MP4 均完整解码出11,302,440字节，逐字节等于编码前的10bit平面数据，SHA256均为：
`867561d2db4fbb79fcad50fd9c8eeaad281626bc6c49dd6776f99f7c42a67ab3`。

证据与复现方法见 `experimental/raw-source/README.md` 和 `evidence/real-frame-20261011/receipt.json`。这是RAW灰度数据通路诊断，chroma为中性常量；没有去马赛克、白平衡或正常色彩处理。单帧显示时长人为设为1秒，不代表采集速率。它证明真实数据的10bit软件编码/封装保留，不证明传感器有效精度、机内Main10、连续录像或机身回放兼容性。

根代理复核了当前14个适配器/产物文件与已有mux依赖的哈希；实机控制和文件回读的13项检查全部通过，见本次输出目录的 `validation.json`。静态分析、单元测试、电脑编解码与相机运行证据分别记账。

## 高规格剩余工作

1. 核对驱动 MODE_21/DJI_A2 的 3884×2914 与 HB722 模式、原厂拓扑之间的真实映射；不同表中的数字 id 不能混用。当前安全 RAW 导出已接通，不等于目标模式已接通。
2. 在目标模式下取得实际帧、打包/精度/stride 及恢复证据，然后才测有限连续帧与全视场覆盖。
3. HEVC Main10 下游离线基础已经存在；机内编码还需解决具体输入格式和 stop 异常处理。最新审查发现原厂测试工具忽略 stop/close 返回值就释放缓冲区，不能原样拿它证明安全退出；P010 字符串虽被 parser 接受，实际 HAL 转换却拒绝。NV12_10 是另一路，不能把两者混同。

新增模式映射证据：HB722现有cam_mode表的profile1/2明确指向HB mode23（7408×1482），并无已证实指向驱动MODE_21的3884×2914映射。当前camera-service映射有librcam和HB722 cam-info插件，但没有libsensor_imx861；磁盘上存在的驱动函数不等于当前服务持有其可调用实例。后续需要补齐实际控制层、HB模式映射及高分辨率ISP配置，不能把17–20当作D-Bus枚举直接试。对应证据在 `../research/full-fov-pipeline/sensor-mode-crosswalk/`。

UI、现有 H.264 recorder 和已验收播放器本轮保持冻结。高规格开关未以未验证能力对用户启用。
