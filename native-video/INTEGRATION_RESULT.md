# X2D II 临时录像界面与录屏验证 — 2026-10-11

**历史集成记录。** 2026-10-12 的最新状态以 [CURRENT_HANDOFF](../local-verification/CURRENT_HANDOFF.md) 为准。下文旧 Toolkit 命令暂被执行门暂停：实机观察到 blackbox 清理删除会话恢复状态，需要迁移后重新验收。不是当前可直接运行的装机指南。

已通过有界实机链路：loopback RTP → 相机 SSD 直接 MP4 → 真实录制状态红框 → 视频列表 → 原厂 VideoItem 解码 → 播放结束 → 返回。另提供一键相机界面录屏工具。尚不等于长期稳定、原厂照片/视频混排或永久安装完成。

## 20:28 最新结果与用户工作方式

- 用户确认录制时机背实时监看正常、实体Playback入口与播放可用；希望按钮更灵敏，并将视频真正并入原厂相册，沿用原厂控件。当前单独VideoGallery是中间实现。
- UI/UX专职代理已使用 **GPT-6.1 Sol / high** 在 `simulator/` 制作1024×768桌面模拟器；所有新UI先在模拟器审查，**用户确认后才能上机**。其余子代理也已重建为同模型/档位，根代理只负责主流程与集成。详见 `WORKSTREAMS.md`。
- bridge c 真实短录两段：162帧/5.408秒、369帧/12.308秒，1300×970 H.264 8bit、平均约30fps；设备与Mac SHA一致、FFmpeg全帧解码零错误。第二段手动停止到saved约962ms。两段均从正常实时取景开始，停后独立preview请求回读Active/None。见 `outputs/bridge-c-real/` 与 `outputs/bridge-c-repeat/`。
- 本轮管线测试前后camera-service=380、原厂camera-gui=5313/running未重启；已停止本轮闲置bridge并移除端口转发，原厂文件哈希保持，/system只读，保活继续。
- UI停止播放过程中曾出现一次原生VideoItem空worker崩溃；已定位并提供等待对象销毁的候选修复。宿主机测试通过；后续有界实机没有观察到新增崩溃，但缺完整循环日志，**完整回归仍未通过**。见 `ui/VIDEOITEM_LIFECYCLE.md` 与 `outputs/playback-release-regression/`。不再绕过模拟器确认门重复部署。
- 原生DCF/Video/SRC.JPG规则见 `NATIVE_ALBUM_RESEARCH.md`，当前仅有只读inspect/plan，没有向DCIM发布。高规格研究见 `CAPABILITY_RESEARCH.md` 和 `research/codec-capabilities/README.md`；原厂RTP发送器硬编码AVC，4K/10bit/HEVC/60fps仍未验证。

以下保留19:44至19:52的首次集成与Toolkit证据，当前状态以上节为准。

## 视频与画面证据

- 相机：X2D II 100C，1.3.16.2，USB 2756:000b。
- 文件：`/mnt/media_rw/ssd/X2V_VIDEO/X2V_20261011_114000_25158_1.mp4`。
- 162帧，5.408333秒，1300×970，H.264，8,339,638字节。
- SHA-256：`cf6b43c0d866e12f90ca499981e0e62031c1f4099710bf7e1f51f044912ccd99`；相机文件与电脑副本匹配；FFmpeg完整解码无错误。
- `outputs/integration-b-1940/capture.json`：真实状态、原始/停止回读与已发布目录。
- `outputs/screen-audit/record-save-playback/screen-audit.mp4`：35秒70帧界面录像，零跳帧，按实际抓帧时间编码。
- 同目录 `recording.png`、`saved.png`、`playing.png`、`ended.png`、`idle.png`：红框、保存、回看和释放画面的实际抽帧。

## Toolkit

双击项目根目录 `录制相机屏幕30秒.command`，或运行：

```sh
.venv/bin/python local-verification/camera_toolkit.py record --seconds 30 --fps 2 --format bmp
```

默认采样1024×768、每秒2帧、30秒。程序自动预检、创建独立临时GUI会话、录屏、导出MP4和带时间戳的JSON、停止本轮并确认原厂GUI恢复。拒绝打断已有GUI会话、正在录制的进程或RTP/USB传输。已有开发会话要用显式 `--attach RUNID`，该模式不会关闭原会话。

最终一键实测报告：`outputs/camera-toolkit/final-one-click/report.json`，`success=true`。30.011秒内尝试60次，成功保存59帧、1次因上一抓帧未完成而跳过；视频保留真实采样间隔，末尾补一帧表达末帧持续时长。MP4在 `capture/screen-audit.mp4`，逐帧记录在 `capture/audit.json`。原厂界面已自动恢复且独立回读确认。恢复锁竞态已修复，11组本地进程回归与旧版负对照验证通过。

它记录Qt Quick界面。实测原厂LiveView图像会呈黑底，文字、菜单和红框可见；VideoItem回放的视频画面可见。此工具是取样审查，不是30fps实时镜像。BMP把本轮首组基准中的同步保存平均耗时从约292ms降到49ms；同时录制/回看的后续一轮平均39.8ms。实际界面仍有捕获开销，不能把采样间隔内未看到错误当作不存在错误。

最终一键轮保存平均66ms、单次最大862ms，存在短暂卡顿和跳帧；早期零跳帧结果不代表每次零跳帧。前两轮一键失败报告也予以保留：首次因完整进程表过长导致预检USB响应超时；另一次采集完成但恢复检查读到中间状态，未误记成成功。

保护包括：80帧/256MiB上限，空间余量，2秒抓帧超时，不重入，租约到期停止，独立GUI watchdog，完整文件哈希和PID启动时间身份校验。未安装开机自启。

## 未完成与已知限制

- 本次录制由主机调用设备上的bridge启动，bridge与封装器独立在相机完成开始、停止和保存。还没有拔线操作、长录、连续多段及断电恢复验收。
- 用户后来确认原厂Playback入口/播放可以使用，Drive Mode全流程手动验收仍不足；实体快门接管未实现。当前产品入口仍是临时开发会话，不是开机后永久视频模式。模拟器中的快门行为不能当作实机已接管。
- 暂停、跳转、音频、高分辨率/高码率、DNG、Log、LiDAR/AF-C/人脸视频对焦尚未验证。
- 首次GUI+SSD集成在0帧时出现RTP同序号冲突，安全中止且未发布MP4。新版本只在提交首个NAL前、有界次数和时限内重新建立参数/IDR门；录制中仍严格失败。该恢复通过了真实RTP样本故障注入及逐帧对比，但此次成功实录没有触发恢复分支。
- 早期原生播放器EOF时有缓冲回收Timeout日志，该次仍正常ended和约20ms释放返回；后来已发生停止路径崩溃，候选修复与未完成验证见最新结果。进程外watchdog保留。
- 仅添加带x2v命名的自有/system文件，原厂camera-service、camera-gui和两个init配置哈希保持一致；system恢复只读。GUI进程有意重启，camera-service未重启。没有刷固件或修改全局SELinux策略。
