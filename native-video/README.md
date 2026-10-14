# X2D II 机内录制实验

2026-10-11；目标固件 1.3.16.2。此目录接续附件的 recorder/minimp4 核心，原始 handoff 快照未改写。

**2026-10-12 当前状态：下文是首版历史记录，不能据此运行旧 blackbox 会话。** 最新进展与设备状态见 [接续记录](../local-verification/CURRENT_HANDOFF.md)，系统与 RAW 调研见 [总报告](../research/X2DII_H6D_SYSTEM_PIPELINE_REPORT_20261012.md)。低分辨率 SSD 内录、原生风格照片/视频混排已有实机证据；3884×2914 连续源仍未接出。旧录屏入口因实际 blackbox 清理故障已暂停，新 data/SSD 会话方案尚待实机验收。当前最高优先级是新的传感器模式接入。

## 已实机验证

- USB 启停期间持续接收，停止后回读 Off / None；3、3、10 秒重复采集完整解码，末尾没有残包。
- 原厂 RTP 预览 → 相机 loopback UDP → 256 包有界重排 → H.264 NAL → 相机上的 C/MP4 封装线程。
- runtime 在 `/blackbox/x2v-native-20261011` 独立执行；不挂接或重启 camera-service / camera-gui。
- 参数稳定至少 750ms、启动至少 1s 后遇到 IDR 才进入录制；录制中参数改变仍失败，不能静默混合不同分辨率。
- `autonomous-20261011-183608`：控制器与录制器都在相机执行；电脑 13 秒内不发送拍摄控制。168 帧 / 5.608333s，1300×970 H.264 High 8-bit 4:2:0 BT.709，约 10.74Mbps；严格解码成功。尚未做物理拔线试验。
- 文件首先写入 blackbox，再由相机本地复制到 SSD `/mnt/media_rw/ssd/X2V_TEST_20261011/X2V_183608.mp4`，两端 SHA 相同。不是已实现 SSD 直接长录。
- 相机独立解码先前 130 帧片段：2.274 秒、maxrss 26020KiB，逐帧 MD5 与 Mac 相同；从新片 2s 处定位得到的 8 帧也与 Mac 相同。尚未显示到机背屏幕。

## 重要修正

原型在自己后台线程争用互斥锁时会报错；独立录制进程改为正常加锁，不阻塞相机服务线程。相机禁止 su 域在 system_data_file 创建硬链接，发布文件改为 Linux renameat2(RENAME_NOREPLACE)，拒绝覆盖现有文件。数据包丢失、未完整分片、编码参数改变等失败保留 `.partial`，不列为已保存片段。

RTP 按 [RFC 6184](https://www.rfc-editor.org/rfc/rfc6184) 解析，支持 single NAL、FU-A、STAP-A，校验序号、SSRC、分片时戳和大小上限。保留 90kHz 时间线；平均 30fps 不代表每帧等间隔。

## 界面状态

`ui/VideoDriveEntry.qml`、`RecordingOverlay.qml`、`VideoPlaybackControls.qml` 是自写组件。Drive Mode 选择独立 videoMode，不把不存在的录像枚举写给原厂 Camera.drive_mode。红框仅在实际写入帧且状态新鲜时亮起；启动/保存/出错不显示红色 REC，失联显示黄色。

`Preview.qml` 是桌面设计验证夹具，不是原厂页面替换物；七种状态已通过 Qt 软件渲染检查，截图在 outputs/ui。尚未安装到相机。不能声称用户目前能从 Drive Mode 切换或在机背回看。

原厂资源已离线提取到 `resources/gui-resources`：DriveModeGrid、PopoverDriveMode 和 LiveViewOverlay 可作为接入点；BrowseViewViewModel 的视频播放调用与 StateMachineViewModel 的录像按钮调用是注释掉的占位代码。

## 下一道接入边界

- 临时运行程序可在 ADB su 域执行，但该域不能连接原厂 D-Bus、写 SSD 或修改 GUI 进程；工厂域能控制预览/写 SSD，但不能执行 blackbox/tmp 上的自写文件。
- 原厂 GUI 尚无已验证的、无需改启动项的附加 QML 加载入口。需要继续验证适用于二代的临时加载与卸载方法，再接菜单、实体键、红框和播放器。
- 不运行一代安装器；不通过关闭 SELinux、改 init rc、改原厂二进制来跳过这些问题。本阶段不声称有完整刷机恢复方案。
- 首版测试录制器有 12 秒接收上限和 64MiB 输入上限；不能作为长录工具交付。

## 重现与证据

从项目根目录：

```
.venv/bin/python native-video/tools/build.py
PYTHONPATH=local-verification .venv/bin/python -m unittest discover -s local-verification/tests -v
.venv/bin/python native-video/tests/check_ui.py
```

设备实验入口为 `local-verification/native_capture.py` 与 `autonomous_capture.py`；有固件哈希、起始状态、停止确认和有限超时。诊断产物只写专用目录，不覆盖照片。

`rtp_remux.c` 复用真实 RTP 样本验证封装；丢包和已有文件保护结果见 `outputs/fault-tests/report.json`。地址/未实现上层接口的证据见 local-verification 中的 JSON。

机内解码器来自 [FFmpeg 7.1.1 官方源码](https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz)，源码 SHA-256 `733984395e0dbbe5c046abda2dc49a5544e7e0e1e2366bba849222ae9e3a03b1`。最小配置需要启用 HEVC 以包含公用 film-grain 实现，实际只测试 H.264。编译参数和日志保存在 resources/toolchains/ffmpeg-7.1.1；LGPL 源码/许可证一并保留，未发布二进制。

高分辨率、高码率、其他封装、DNG、Log、AF-C、人脸与 LiDAR 仍是后续实验，不是本轮已支持规格。
