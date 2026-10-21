# 修复前 / 后同帧 RAW 诊断（2026-10-17）

状态（2026-10-21更新）：原版同帧采集与候选实机短录已完成，详见 RESULTS-20261021.md。候选未永久安装，相机恢复稳定版。以下保留初始实验设计。

临时源码：native-video/experimental/rx-prr-rawpair-20261017。
仅在收到 `rawpair` 命令后，于编码线程持有源槽与编码槽时保存一对图像；不改变原预处理算法、不写传感器寄存器、不增加图像缓冲。一次触发只取一帧，同一份 source 与 preprocessed 在释放内存前写完。输出文件使用 O_EXCL 避免覆盖，写入循环处理短写与 EINTR。

诊断输出：SSD/X2V_RAW/.x2v-diagnostics/rawpair_<monotonic_ns>/。
source.u16：包含行尾与光学黑区的原始 3968×2946 容器。
preprocessed.u16：3968 stride ×2912行，其中3888列是有效编码像素。
pair.json：几何、黑白电平、WB、帧序号、状态及诊断耗时。
诊断写盘会暂停这一帧编码；此轮不用于帧率或掉帧验收。

## 同帧比对

analyze_pair.py 直接编译当前生产 prr_pre.c；先用保存的 source 和 black 重建处理后图像，要求有效像素与实机 preprocessed 逐值完全一致。通过后再从同一 source 分别关/开行修复，以相同白平衡、矩阵、去马赛克输出对照。这样不会把两次拍摄的移动、曝光或对焦变化误判成算法效果。

已有 host-check.json：未修复行逐值不变、修改只限 y%6=5、均匀输入开关一致。尚无实机对照结论。

## 临时运行

相机须开机、USB 连接，使用仅充电/Phocus联机。选择24fps ProRes RAW，空闲状态；对准有细纹的真实静物，避免电脑屏幕。先恢复 ADB 和 keepawake。

执行 device_trial.py。它核对当前已安装 flat-prr 版启动脚本未漂移，写入独立命名的诊断库，临时从 blackbox 启动诊断 supervisor。不会修改永久启动选择、生产session或GUI。
采到一对文件即停止短录，取回文件，退出临时服务，并重新启动永久 supervisor；保持测试前的拍照/视频选择。异常也尝试恢复，失败写 recovery_error 与 RECOVERY_REQUIRED，不能声称恢复成功。

之后执行 `analyze_pair.py <device-result.json中的local_pair目录>`。
不得将 ISP 的 `cdump raw` NV12 当成这里要求的传感器 Bayer RAW。
