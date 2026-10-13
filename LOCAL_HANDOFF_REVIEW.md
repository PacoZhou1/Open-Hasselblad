# X2D II 项目本地接续核对

核对日期：2026-10-11。此次任务是阅读两份交接包并完成材料接续；附件中的历史任务、命令和授权记录作为背景，不自动替代本轮用户请求。

## 目标与实现

唯一实际目标机型为 X2D II。最终方向为机内视频拍摄与回放，扩展研究包括高码率、高分辨率、高帧率、Log、RAW/DNG、录像 AF 与 LiDAR。上述目标不能作为已支持规格。

当前原型从已有 H.264 编码预览取数据：camera-service 函数挂接 → CPU 同步完成后复制 → 有界队列 → C 后台线程 → minimp4 封装 → 正常停止 → 拉取与解码检查。Frida profile 固定到官方 1.3.16.2 的 camera-service 哈希及函数前缀。已有 ARM64/Bionic 编译物，但历史记录和本次检查均没有相机运行证据。

原型尚未实现独立视频模式、硬件编码码率控制、硬件 PTS、音频、机内录像 UI/相册/playback、Log 或 RAW 视频。400Mbps、1080p60、4K30 来自合成输入的离线测试，不能作为相机能力。AF、LiDAR、IBIS 与长录也未通过实机验收。

## 两个包的关系

原始快照分别解压在：

- `handoff/core/x2d2-project-handoff-2026-10-11/`
- `handoff/light/x2d2-project-handoff-2026-10-11/`

core 共 3503 个文件，light 共 3532 个文件（均含清单本身）。完整 SHA-256 清单校验分别通过 3502/3502、3531/3531 项。共有文件除 FILE_MANIFEST.json 外内容完全一致。

core 独有 DOWNLOAD_NOTE.md 与 restore_firmware.py；light 多出 31 个运行时、合成视频和参考图片等文件。以 light 作为完整度更高的阅读入口，core 中的补下载说明作为补充；两份快照没有合并覆盖。

两包均不含原始 CIM 或固件提取物。core 的 PACKAGE_METADATA.json 沿用了 light 的统计，不能用于判断 core 实际文件数；以 ZIP 实际内容及 FILE_MANIFEST.json 为准。START_HERE 和 SOURCES 中部分“完整包已含固件”的描述不适用于这两份包。

## 来源和参考范围

SOURCES.json 收录六个固定 commit 的源码快照：dash8097/Hasselblad-Feature-Extensions、radium-wang 的 CIM research 与 x2d-907 toolkit、YuHaoyua 的 CIM extractor 与 X1D reverse engineering，以及 lieff/minimp4。它们已经随包提供，不必重复下载才能阅读。此次未查询上游最新 commit，不能把快照状态描述为当前线上状态。

X2D/907 工具包面向一代 X2D/907、固件 4.2.0；不能直接作为二代安装器。dash8097 的公开算法、展示和研究索引不等于完整机内后端。X1D/X1D II/X2D 固件是比较材料，地址、ABI 和验证结果不可直接套用到二代。

## 本次独立验证

- 本机为 Apple Silicon（arm64），FFmpeg/ffprobe、Clang、Homebrew 已可用；当前 PATH 未找到 adb。
- 7 个原型 Python 文件通过语法解析；未执行完整 Linux 回归，也未把语法检查当作功能测试。
- 包内 ARM64 录像库与 Frida server 的哈希均符合各自来源报告。
- roundtrip、Frida roundtrip、1080p60、4K30 四段既有合成视频在本机重新完整解码成功，帧数分别为 45、45、12、12。此次没有重新生成或验证整个录制链路。
- 详细结果见 `local-verification/handoff-checks.json`。

官方 X2D II 1.3.16.2 固件已通过 Gopeed 下载到 `resources/firmware/X2DII_100C_v1_3_16_2(1).cim`，大小 364814336 字节，SHA-256 为 `9789d6a9843d388034bc12341ad9a97585c25cb98cf11a0da8b768399b4842f6`，与原交接来源完全匹配。记录见 `local-verification/firmware-check.json`。仅下载，尚未重新解包，也未更新相机。其他四份比较固件仍未下载。

## 接续时需要校正的理解

LOCAL_HANDOFF.md 说等待数据时“尝试启动已有 Phocus 编码预览”，但 tools/device.py 当前只输出提示并等待最多 15 秒，没有自动启动 Phocus 或发送预览激活命令。实际出流条件仍需验证。

预检成功和 capture 的 device_validated 也不等同于完成 PRD 全部 P0：恢复后原厂预览响应、反复启停、断连、资源释放和真实帧时间仍需各自测量。代码中部分 detach/清理异常被忽略，因此文件解码成功不能单独证明清理成功。

## 后续顺序

1. 如继续静态研究，建立独立依赖环境，解包已校验的二代 CIM，再核对 camera-service/libc 哈希和接入点；保留原报告。
2. 实机工作开始时确认当前固件、镜头及镜头固件、USB 状态和二代 ADB/root 接入条件。此次未连接或探测相机。
3. 固件身份匹配后，确认原厂编码预览能出流，再进行 5–10 秒短录及停止、回放和资源归还验收。
4. 首个真实短片通过后再推进专用模式与码率；Log/RAW、音频、AF/LiDAR 分别建立证据。

本次没有修改录像源码、运行安装器、挂接相机服务、刷写、提交 Git 或上传材料。
