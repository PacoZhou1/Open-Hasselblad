# TESTING — 相机正在被占用

**Operator / 操作者：codex-preview-debug**

任务：已将实验ToF对焦接入机内rec流程，用户点右侧红色触屏录制按钮即触发AF，25秒自动停止；可反复测试，不再有电脑端5分钟等待期限。14:24机内自测完成，无错误，当前特意保持video/up/saved待用户使用。本次开机UUID匹配才启用候选，重启回稳定库。其他操作者不得操作相机。动态跟焦质量仍待用户移动测试。

更新：2026-10-16T14:25:00+08:00

其他代理不得运行 ADB、USB、factory、录制、重启或装机命令。离线代码与文件分析可继续。占用无自动超时；只有操作者完成停止和原厂恢复后释放。原始数据保留，不刷启动/固件分区。

状态：`python3 local-verification/camera_testing.py status`

释放：`python3 local-verification/camera_testing.py release codex-preview-debug RESTORED_REPORT.json`
