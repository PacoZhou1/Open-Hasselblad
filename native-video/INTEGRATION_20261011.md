# 2026-10-11 晚间集成结果

## 2026-10-12 02:35：用户改为模式接入最高优先；新接口已stage，normal owner实机出帧，watchdog恢复成功

- 最新用户明确批准开发新接口、大幅尝试，优先攻破模式源。Root仍唯一相机操作者，三个sol/high agents全部转模式实现：native_album=owned HB/HAL mode；codec=RAW receiver/owned topology/graph；uiux=source owner controller。UI system candidate已离线冻结但暂停装机，不回到UI/3FV样片支线。Goal active。
- 原服务动态构造点已找到：librcam rcam_dev_create通过PLT调用rcam_imgsys_create，shim调用原factory并wrap public+10 Init，在原Init之前复制并安装owned c0 descriptor/24×84 HB rows，数据保留至进程exit。normal-clone保留HB23→driver52所有bytes。Root发现并修正重要load bias：首LOAD vaddr2b000/offset0，不能用dladdr.dli_fbase直接加VA；现在factory−24c678并dl_iterate_phdr crosscheck。
- `research/full-fov-pipeline/source-adapter/` frozen normal-clone so SHA1b314a384bda2ee4caf6b8c6d60d8258e2e3b56c65d48778684043ac8bee0b70 /161536B；7hostchecks/noDT_NEEDED。已用guarded stager安装新`/system/lib64/libx2v_source_normal_clone_20261012a.so`，outputs/source-adapter-stage-022350/report.json通过。仅/system/bin/true映射RC0记录source-adapter-map-20261012.json，未启用在service。librcam原文件未改、/system ro。
- `experimental/source-session` stock controller SHA48f248f92b754ddbea84a65c6cb283c58b366f46c820d3fcdc62b874b02e547a/13host checks；从factory camera-test cgroup1094启动独立controller/watchdog，停止原service/gui并单一manual service，不与其他硬件owner并行。90s是开始恢复deadline，不是所有错误强制kill保证。
- 实机`outputs/source-stock-023126/`：manual service7391成功Active/None/Still16bit，frame458→610，正常set_live_view(false)后group255，bodyrc0。第一次recover TERM后立即`ERROR_foreign_service_no_overlap`，recoveryrc1原报告保留failed。随后独立watchdog自动重试完整恢复：stock service8957/frame476→626，GUI9780/running，restored标记及锁释放，后续frame2950、systemro。证据after-watchdog/events.log + watchdog-readback.json。未人工干预设备恢复。退出后pidof/init状态短暂未收敛是候选根因，尚无首次失败瞬间PID证据，clone controller将加bounded absence wait及日志；不能把本轮总体验收冒称无错误passed。
- Root主机`source_session_test.py`已修：body首次recoveryrc1后继续观察watchdog restored，而非立刻结束读back；原body/recovery错误不抹去。defaultoffline，固定modewrapper，无arbitraryexe/preload参数。UI agent在新source-session-normal-clone独立修恢复及固定cloneenv，stock冻结保留。
- `experimental/source-receiver-adapter`正常单帧CPUcopy .so SHA84d8b943e729f90f96652c4334a3737ce1c0fdb1874a624dd38e67b776c19bda/38104B，normal-freeze含所有编译输入+27Bionic/HALimports验证。借原callback映射/同步/拷贝22MB/立刻unmap，writer仅持CPU副本。只接受显式HB23_DRIVER52+空FD3、readonly命令FD7、空ACKFD8；完成/命令D后disarm+本hook退出+CPUdrainACK，不把cache sync当DMA fence。已stage到`/system/lib64/libx2v_source_receiver_20261012a.so`，outputs/source-receiver-stage-023400/report.json通过；未load/constructor执行（DT_NEEDED HAL，不做独立true预载以免原库constructor）。
- Root并核MCU时序取得实际代码证据：`research/full-fov-pipeline/mode21-timing-root/{README.md,solver.py,candidates.json}`。MCU0806d1e0固定72M sensor→36M HB、偶数xhs/xvs/精确ratio/minline约束；tgConfig0806ced4按72M/rowclock应用总周期。没有通用frame+8规则。离线allocator转写复现normal52 100fps240/1500；候选17@20fps36M/450/4000，17@24fps500/3000，18@30fps400/3000。17–20该路径无60fps解，不是整硬件极限。native_album按17@20完整HB行+HAL请求ratio继续；未实际切mode17。
- HAL owned entry新进展：get_cam_info out+120→16B modeheader(count10,arrayptr)，out+130→topologyheader(count7,arrayptr)；此前漏掉二级指针的无入口结论被纠正。插件handle-local dlsym不会自动用preload同名getter，codec正在做实际loader边界/ownedheadercallback。graph13是原枚举LiveviewRawCalib，normal/target新配置仍只生成，加载重定向正在实现；目标20fps且绕开旧3884×970 SBPC ROI，不只改传感器driverbyte。
- 当前相机stock service8957/GUI9780，Active/None/Still16bit，systemro，source/GUI locks clear。Root无执行中设备命令；保活仍启用。下一步等clone controller冻结→review→实际normal-clone/恢复→normal receiver→完整target接入。禁止未完成target/FPS/receiver适配的试切，group12旧HOLD仍保留。

## 2026-10-12 02:05：机内 SSD 2 GiB 直接写实测通过；data loader 映射被拒，系统路径候选离线制作中

- Root 唯一设备操作者，三个 gpt-6.1-sol/high 子代理继续。goal active，无 commit/push。当前 service28857 / stockGUI23222/running，Active/None/Still16bit/CropNone，/system ro；无 root 设备长进程。
- 新 `experimental/ssd-direct-write/ssd_direct_fd.c`：仅新空普通FD3，O_DIRECT必须设置成功，4MiB对齐buffer，最多2GiB/64MiB AS/20sCPU/45s alarm/48s外timeout，写+fsync+全直接读回memcmp；3项host ASAN/UBSAN通过。helper SHA9813c88ec2bd9d0a03e34568298a49859e6126c82ca05ff4ac521db94adb9945。
- `/data` ELF exec RC126被保留于outputs/ssd-014724/report.json，未产生SSD写入。只改ROOT的既有stage_artifact副本（SHA5bcfb0c2183e321531b11cca5225b9b67805e0a0ac7ce1451f2746e7d80acd78）沿用独立watchdog/SHA/label/ro恢复，发布自有 `/system/bin/x2v_ssd_20261012a`，原厂文件未覆盖/安全策略未变。安装先完成导致host PID读取失败，未重发；outputs/ssd-stage-015322/reconciled.json确认installed_readonly/hash/锁释放/同健康PID；原失败观察保留。ssd_stage.py已修结束进程读取race。
- 实机16MiB：outputs/ssd-015419/report.json passed，618.931MB/s。实机2GiB：outputs/ssd-015455/report.json passed，write2.812916s+fsync8.734ms=761.074MB/s，全读回相等；512个4MiB写最大16.886ms、nearest-rank P50/P95/P99=4.960/8.462/10.426ms。前后service/gui同PID、取景正常。全读回15.518s包括比较，不当纯SSD读速。仅短单文件伪随机重复块测试，不是持续DNG/温升/缓存耗尽/每帧fsync；UHD16bit30p预算498MB/s，3884×2914 16bit30p679MB/s仅12%余量，12bitUHD60p746.5MB/s仅2%余量不承诺。详情experimental/ssd-direct-write/README.md + raw-budget.json。相机自身X2V_BENCH保留2GiB+16MiB自有partial证据。
- UI `experimental/persistent-session` 冻结：controller2f85ca7e.../data loaderc9ffc917...，permission-a与record-a两包，22controller+9Qt/HTTP(0warning)+7contracts+121filefreeze通过。root仅用/system/bin/true做预映射，没有起camera-gui：outputs/persistent-map-probe-0200/report.json显示loader data segment2 Permission denied RC1，机身同PID健康。不是只execbit问题，不改SELinux。该data-loader方案不可装机。
- UI代理正在独立新建 `experimental/persistent-session-system`：状态仍data、审查bulkSSD、loader新自有/system/lib64路径（guarded stage），新b runIds，dry-run失败显式return而非进入stockmain，fresh hashes；新 `local-verification/persistent_ui_test.py` runner制作中。未冻结前勿部署；旧record_album_test HOLD保留。root下一步先review/stage/mapping/permission-only/恢复，再不同run录制QA。
- `research/full-fov-pipeline/mode21-profile-adapter/README.md`与contract冻结（README3da4e91b... /contract7ca997e3...），7hostchecks。原厂c0descriptor+b0 borrowed rows+b8count，按248+count*e0分配，stable handle-cell+callback lifetime恢复；但无已审service新descriptor入口，HB sensor实际static global绑定，不能独立第二instance。模式完整timing/receiver/stop drain仍缺，group12 HOLD不解除。native_album代理转有限10–15分钟公开真实3FV样片查找与解析。
- codec交`experimental/hardware-hevc-session`实际0x138 start/0x1c0 submit、6参数ION、cached sync≠DMA fence、header type2len/type1copy、12vendor符号静态链接；hostASAN/UBSAN通过。audit.so SHA bf66514018860c2b951778f0d588ecaa23600cbf4fbc3d1175d17c9a4023e58a 禁止load。完整descriptor/正常归还/失败DMAstop未闭合，HOLD不解除。该代理转独立 `research/cinemadng-writer-plan` 最小writer接口/真实照片离线像素校验，勿冒充实拍连续DNG。
- 总报告更新加入实测SSD+constructor证据，15,622字符/28local links无missing，receipt新SHA。H6D采样附录仍明确3864×2898+3/3+2160窗口，binning vs skipping/public mode mapping未证。原始日志/失败报告不覆盖。

## 2026-10-12 01:38：b录制成功但blackbox清理致QA中断；相机已手动安全恢复，RAW方向优先

- 用户最新明确提出4K Bayer直接CinemaDNG、尽量合并/跳采保全视场、绕开重型彩色编码；若DNG不行考虑3FV。根目标仍保留所有独立条件，RAW源→有界writer→DNG与H265并行优先。root已查官方X2DII产品页写速最高2370MB/s、1TB；不是本机持续基准。30fps UHD12bit373MB/s/16bit498，3884×2914 12bit509/16bit679；1TB理论44.65/33.49/32.72/24.54min，未扣现照片/开销。
- 总报告`research/X2DII_H6D_SYSTEM_PIPELINE_REPORT_20261012.md`最新14.6k字/25local links检查0missing，receipt记录SHA69fe5aa7...。硬件/Qt/容量/stride由codec独立审查通过；后续b故障与RAW预算已补。报告不是整个goal完成。
- b UI入口修复实际通过：Drive→Video→原厂收屏→LiveView→Start，bridge真正保存60帧2.008333s/3408036B。`record-qa/recovered-media.json` H264High/yuv420p1300×970全帧decode0error，SHA061a2b20745f4facbf9b66b5786ef6f31eea72cc7eb3d0bef9fb421d31acb531。源SSD片保留；factory复制到新`/data/x2v-native-20261012/b-clip-173014.mp4`供ADBpull，源/hostSHA相同。直ADB读SSD被拒绝，不重复；/data/local/tmp不存在。
- b整体QA仍失败：运行时整个/blackbox/x2v-native-20261011/runs及owner/audit/config被删除，logger文件消失。old free535.61MiB，原厂500MiB/30s cleanup threshold，x2v顶层不在whitelist，静态dji_blackbox实际rm排除白名单调用已证；b空间预算未考虑该阈值，free后跳3.49GB强吻合，未见本次daemon日志不能称最终动态因果。
- b watchdog自身也消失/已退出，old supervisor和临时GUI仍在。root按部署记录PID/starttime逐一复核，TERM自有supervisor21571和GUI21693（watchdog21657已无），确认无GUI后start原厂。`record-qa/manual-recovery.json` passed：stockGUI23222/running、service28857不变、ActiveNone、systemro。bridge已确认rtp_off/receiver_dead后停，18762移除。**当前机身正常，无root长命令。** 原failed report保留。
- root修record_album_test.py：final日志读取错误与gs.stop恢复独立；加EXECUTION_HOLD在任何设备访问前，直到新状态存储迁移完成。现在不要重跑a/b/旧blackbox试验。原factorytoken及旧run/QML/data可能已被清除，不能按历史路径假设仍在；自有/system helper还在但需新readback。未改blackbox策略/白名单/SELinux或启动项。
- UI sol/high已获授权实现独立`native-video/experimental/persistent-session/`：/data/x2v-native-20261012放controller/lease/payload，bulk audit放SSD，新loader编译/hashes；不改现runtime或a/b/d/f。旧bootstrap有硬编码customprefix/log也要迁。root唯一设备操作者，agent仅offline。cleanup审计在simulator/evidence/blackbox-cleanup-audit/README.md。
- codec新`experimental/hardware-hevc-backend/packed10-public/`：官方VSI format24 SEMIPLANAR101010 +本机transYUVtoP101010format地址62908，恢复位排列/UV交错。真实3840×2880 planar10↔packed22,118,400B逐字节一致，12检查通过；native转换器8bit补零，硬件实际低2bit仍未测。agent完成，未连设备。
- native_album已交`research/full-fov-pipeline/full-fov-entry-audit/README.md`：type4仍group12/11656×8742；type3group13/3920×986；24HB+10profile无17–20绑定，不能靠hiddenAPI直接出3884×2914。现在继续用户新问题H6D实际100c ROI/binning/skipping静态追踪，不把4K输出当无裁切证明。goal active/no commit/push。


## 2026-10-12 01:28：H6D固件/全栈报告已交初稿，record-album a入口失败并恢复

- 最新用户要求已并行执行：H6D官方1.21.0 CIM63MB+GPL415MB实际下载/校验/全量解包；主报告`research/X2DII_H6D_SYSTEM_PIPELINE_REPORT_20261012.md`已落，包含系统、影像、H6D对比、证据等级和未完成项，面板打开请求queued。不能将报告交付当整个goal完成。
- H6D专项`research/h6d100c-raw-video/README.md`+source/artifact manifest+verification/receipt已冻结。i.MX6Q主控之外，even/odd QSPI重组后真实Zynq BootHeader/FSBL/PL/FARM app校验通过；RAW/MP4/META三轨3FV、CFast写卡、COMP表和Phocus解码路径。无真实3FV样片/未证无损或无裁切。2018固件≠2016首发，主机25fps vs digitalback30fps原文冲突保留。
- 新X2D2 live DT `imaging-dt-properties-20261012.json`：12节点statusokay，ProRes/Moonshadow/J2K/JPEG-LS均sysfs实际bind；JPEGXR没有对应bind。ISP UIOnode不等于eagle2-camera绑定本身。codec专项`experimental/hardware-hevc-backend/IMAGING_PIPELINE.md`+other-codec-inventory.json已纳入真实库/plugin调用，并未执行硬件codec。新`x2d2-static-core-stack-20261012.json`含6核心ELF SHA/dependencies/init；QtCore构建字符串6.8.2。
- root新runner`local-verification/record_album_test.py`默认dry，仅--execute进入设备，需冻结candidate/lease/85s独立watchdog，验证新片身份与全帧decode。a实机完成Drive→Video，但QA误用了CFV-only隐藏lvButton，stage_timeout_liveview，未录制。failed原报告保留；显式recover ORIGINAL_GUI_CONFIRMED，stockGUI19068/running，service28857未变，LiveViewActiveNone，bridge停/forward移除。证据`outputs/gui-sessions/native-record-album-a/record-qa/`，audit34帧runStopObservedtrue。已查看frame16真控制屏。
- UI agent正修b（未冻结/未部署）：改用原厂ControlScreenSwipeArea.enableDrawer(false)→setDrawerEnabled(false)的真实X2D收屏UI链，19shared组件不变，a冻结。b lease模块`simulator/evidence/record-album-qa-b/make_lease.py`，runid native-record-album-b；root runner支持明确--lease-module，先做offline hash检查。
- 输入专项`simulator/evidence/record-album-qa/input-chain/README.md`已证明二代keyOverride→forward_input_events→InputControl；Override3抑制全按也影响半按，Qt accepted不能阻止service拍照。现产品未接实体快门录像，未改override；不可贴全屏mode3伪装完成AF。
- root唯一设备操作者；三sol/high代理当前：UI修b；codec审总报告并追官方/开源VSI packed10位序；native_album从H6D转查full-fov-entry-audit。camera-expose type4 FullFovRaw初步已确认仍是group12，不是新的3884×2914入口，不解除HOLD。无root长命令在跑，无commit/push，goal active。


## 2026-10-12 00:51：恢复锁实机通过、全幅彩色 Main10 单帧机测成功

- e实机保留失败：UI流程成功，但Android mksh空exec9设置CLOEXEC，flock9实际BadFD，三个恢复者均失败。root用冻结d控制器仅恢复e，stockGUI6812/service28857正常。实机纯文件probe证实`toybox flock -n 8 8>&9`成功，父9持锁/关闭释放。证据在e/product-qa/fd-probe-and-mcu-version.json；不要复用坏e包。
- runtime最终SHA `a671f5e300894c56ddd5440049574240443fee051d32a411aefe2a75f8c26379`，真实host mksh R56+C flock和过程故障20项通过。报告outputs/runtime/gui-session-mksh-host-tests.json。f完整实机回归 **passed=true**：outputs/gui-sessions/native-album-product-f/product-qa/report.json。冻结d UI不变，2300项，最新单张→3/5列→video playing→stop idle→照片新identity ready，QML错误0；recover rc0/ORIGINAL_GUI_CONFIRMED、restored、stockGUI9757/running、service28857不变，bridge停/18762移除。supervisor TERM exit.code1与恢复rc0分开。f屏幕审查50帧/stop完整。
- **机内3840×2880彩色HEVC Main10单帧成功**：outputs/ffhevc-004844/validation.json。自有新增helper `/system/bin/x2v_ffhevc10_20261012a` SHAe03369f8ec2aac416ba3a023d000cce2dc55b69f6b93c72cb61a22e4f93b3bb9；stage后/system ro。输入B3648原始全crop11656×8742在HOST去马赛克/缩到3840×2880 Rec709 10bit，普通FD CPU单张编码；不是实时源。限额256MiBAS/30sCPU/40salarm+42stimeout、350MiB可用内存门。
- 实机rc0、8946059B，SHAa0175b793762f26dfc0978503c265b4fd8026cac3697238462424bade14c1cad；RSS208720KiB约204MiB、CPU18.42s、含launcher墙钟31.02s。Main10 idc2/yuv420p10le/3840×2880，HEVC+hvc1完整decode同host SHA07880977fd60e2b9ab199771d4cc857834c2dfbbc957196318d7bed187df60f7。QP0有损max11/RMS0.9766。**软件单帧不是实时4K方案，不把指定1s时间线当录像。** 原process pending字段保留，最终validation独立关联SHA。
- 当前健康：service28857/gui9757均未因CPU试验重启，Active/None/Still16bit/CropNone，frame_count516→2371，/systemro；MemAvailable374024→399280KiB。保活继续，未替换原厂固件/启动项。
- MCU实质证明冻结于research/full-fov-pipeline/exmcu-mode-contract/mcu-handler/README.md+11checks：实际0f/11 handlers→SensorImx861 ops→17–20各345寄存器列与libsensor一致。root原厂只读exmcu firmware_version回apps_messaging_version=b9558bd/firmware_version=f991af，与.cont实际响应构造匹配。不能把全机real_version_id或buildIDs当flash全SHA/运行模式成功。group12 HOLD继续，3884×2914连续源仍未取得。
- 并行下一步：native_album代理新mode21-profile-plan梳理HB23→52与17–20的host尺寸/SLVS/ROI/buffer/ISP差异，不能单改conf；codec代理新目录给硬件HEVC最小接口/退出契约（无实机/DMA）；UI代理独立record-album QA走UI handler、3s录制意图/保存最新clip/点播放。shared UI/runtime/d/f冻结；实体快门录像未实现，脚本不能代证触控。
- root新增local-verification/full_frame_hevc_device.py（默认dry）并增强album_product_test.py失败门。当前无root长命令，goal active；未commit/push。用户系统问题已答：Linux5.4.123-rt59+Android9/API28+Qt，4xCortex-A55(41/d05)，DJI Eagle2 HB722 V5，商业SoC料号未确认。

## 2026-10-12：候选 d 真机流程通过，工具恢复锁仍需修复

`outputs/gui-sessions/native-album-product-d/product-qa/report.json` 保留整体passed=false：真实2300项（2295照片+5视频），最新B0003649单张与nativeKey握手、3/5列定位、视频playing、停止idle和返回新照片均完成。Root已核对`outputs/screen-audit/native-album-product-d/grid-14.png`和`grid-18.png`，所选最新照片在可视区域橙框内，旧滚回相册头部问题未复现。48张截图含完整stop事件；抽样不代表全速UI流畅性。

退出工具时`recovery.lock/owner`发生TOCTOU，主动recover返回1。另存`product-qa/recovery-readback.json`确认最终phase=restored、stockGUI787，service28857始终未重启，Active/None/Still16bit，bridge已按身份结束，18762转发移除。UI代理正在修复**本地**恢复锁并加故障测试；不能把后续修复说成已装机。原失败report不覆盖。

同轮另一个group12 RAW试验确实导致此前service380重启28857，详见HIGHRES_SOURCE_20261011.md，不能与本UI会话无service重启混淆。


## 23:39 更新：真实照片/视频共用浏览序列

临时产品候选 c 实机通过 `outputs/gui-sessions/native-album-product-c/product-qa/report.json`。
原厂2294张照片和5段真实视频组成2299项浏览序列；进入最新单张、3列/5列缩略图、选中视频明确播放、停止释放后返回原厂照片均有设备事件。返回时严格核对完整照片路径、当前原厂列表项、双方index、previewReady和viewModel归属，均matched=true；没有把文件名缩写匹配当作照片就绪。

相册照片保留原厂顺序，视频按实际目录顺序合入。历史照片metadata懒加载且部分无时区，完整时间交错排序仍未证实。没有伪造DCIM照片项来冒充视频；本轮新增B0003648是原厂正常拍摄的真实照片。缩略图网格定位和metadata刷新闪空仍在单独改进，自动语义QA不等于实体拨轮/触摸手感验收。

候选 c 测试后恢复原厂GUI21497，camera-service380始终未更换；Active/None/Still16bit/CropNone，/system只读；临时bridge已按身份结束、转发移除，保活继续。录屏在 `outputs/screen-audit/native-album-product-c/`，它是Qt层有开销抽样，不能代替全部画面或流畅性证明。

高规格新增结果及边界以 `HIGHRES_SOURCE_20261011.md` 为准：实际机内CPU Main10、原厂HEIF硬件Main10、单张3FR到DNG均已分别验证。3884×2914连续源及真正高分辨率短录仍在接入，下面早期章节的未验证描述为当时快照。

## 界面与模拟器

官方默认已按用户确认对齐：后拨轮缩放、前拨轮选片；Playback 先进入最新单张，视频需明确点 Play。屏内没有额外退出键，桌面辅助机身控件留在画布外。

模拟器使用原厂资源和菜单组件，恢复 43 个原厂菜单 schema、258 条静态项，专页适配后共 402 节点。主流程 57 项、菜单 25 项检查通过且无 Qt warning/error。当前可运行版本和缺口见 `simulator/README.md`、`simulator/MENU_COVERAGE.md`、`simulator/evidence/source-manifest.json`。

它不是完整固件仿真：部分 C++ 可用条件、真实 ISO 列表、镜头排序、硬件与真实照片/视频混排索引仍未复现。当前机内仍按照片/视频模式分流。真实混排没有写入 DCIM，不能把桌面混排当作已接通。

## 真实机内保存与首帧预览

- Bridge d 与软件首帧工具通过独立 X2V 路径暂存到相机；未覆盖原厂程序或启动项，暂存后 /system 恢复只读。
- 真实测试：`X2V_20261011_133634_21102_1`，159 帧、5.308333 秒、13,243,234 字节，1300×970 H.264 High / yuv420p 8bit，平均 29.953fps、约 19.95Mbps。
- 相机端直接保存到 SSD 后，由有界的软件解码子进程生成 512×382 PPM 首帧；目录返回真实预览路径并结束 pending。
- MP4 和 PPM 回读 SHA 与相机一致，MP4 完整解码零错误。见 `outputs/bridge-d-real/report.json`、`ffprobe.json`、`decode.json`、`device-sha.txt`。
- 早先样片约 13Mbps，本次约 20Mbps；这些是当前码流的实测值，不是已实现的可选码率档位。
- 首帧工具不使用硬件解码器/ION；父进程限制 CPU 3 秒、墙钟 4 秒、内存 256MiB、输出不到 769KiB。预览失败不改变已经保存的 MP4 状态。
- SSD 是 exFAT，输出文件 UID/权限受挂载映射，不能要求 root/0600。可信父进程以 O_EXCL 创建输出 FD 后传入。临时文件归属检查加不覆盖 rename 的并发契约是专用目录唯一 bridge writer；不声称抵御同权限恶意 writer 在检查与 rename/unlink 间替换路径。

本地针对验证：bridge 23 项集成检查、首帧 helper 10 项、首帧 supervisor 13 项（后者 ASAN/UBSAN，含双任务队列成功/挂起/退出）；HTTP QML、可移植 gallery/extension 检查通过。

## 机内播放器停止与释放

最终 `native-playback-final3` 临时包通过真实原厂 Browse 入口，持续 PID 日志先启动，测试再触发：

1. 连续三次播放→停止→等待真实 native QObject 销毁确认→重新打开。
2. 第四次自然播完，仍执行停止/释放确认。
3. 4 次 release_complete 为 25、21、21、11ms；日志包含 3 次 cycle_released、natural_end、passed。
4. 测试后原厂 GUI 恢复。证据：`outputs/native-playback-final3/device-regression/report.json` 与 `events.log`。

前两个包失败保留：第一个测试脚本在 MainContent 加载前打开，被正常初始化关闭；第二个脚本错误引用私有 QML id。二者不是成功验收。最终通过包等待真实 Browse loader，并通过 MainContent.data 内有 browseView/controlScreen 的原厂 MainViewModel 信号进入回放，不改私有原厂资源。

这一回归证明原厂 VideoItem 的停止/重新打开和自然结束释放；不是物理按键时序、触屏手感或长录稳定性验收。不能再次使用 native `source=""` 的旧停止实现。

## 最终设备恢复

`outputs/bridge-d-real/final-device.json`：camera-service PID 380 未更换；原厂 GUI PID 25589/running；LiveView Active / transport None；GUI 会话锁已清理；bridge d 已显式停止，Mac 18762 转发移除；保活仍按用户要求开启。

原厂 camera-service/camera-gui 与两个 init 文件 SHA 均与原基线一致，/system 为只读。新 X2V 工具没有开机自启，也没有刷固件或修改全局安全策略。

## 高规格方向

用户要求即使缺少现成固件功能也继续自行实现，优先保留完整视场。目标链路分为传感器/ISP 连续输出、编码、封装和录制控制；不能放大小预览冒充 4K，不能靠 8→10bit 补位冒充真实位深。

机身真实 4K/60fps/HEVC/Main10 尚未验证。自有下游 HEVC 软件验证见 `experimental/hevc/`；全视场源调查见项目根 `research/full-fov-pipeline/`。软件合成样片不是相机性能或视场证明。已定位的逻辑 3884×2914 模式值得继续关联 ROI、采样、帧周期与 ISP 输出；目前不能仅凭模式名称或表中尺寸承诺无裁切 4K30/60。

HEVC 下游最终离线验证：6 个正例、5 个拒绝案例通过，共16帧短合成素材，覆盖 3840×2160 24/30 与 3840×2880 4:3、Main/Main10。直接生成的10bit梯度覆盖全部1024级；lossless编码后从MP4解码的1,843,200字节与源完全一致，证明软件链保留真实低位信息。hvc1参数集、时间戳、全帧解码一致与不覆盖发布均有证据。它仍不是相机原生10bit、实时4K或机背HEVC播放验收。

全视场调查最终入口：项目根 `research/full-fov-pipeline/FULL_FOV_PIPELINE.md`。56行传感器驱动表与8行HB722表已恢复，MODE_21 /DJI_A2 的3884×2914 active_size有消费者证据；现成F2F路径接7408×1482 RAW输入但目前缩至1300×970 YUV8，下一步研究缩小/量化前的独立消费者。模式命名空间、packing、真实FOV/fps、consumer-return ABI与安全停止仍需恢复；本轮没有按猜测调用硬件。
