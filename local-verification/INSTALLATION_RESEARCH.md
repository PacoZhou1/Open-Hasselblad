# 录像试运行前的安装方式与接入调查

日期：2026-10-11。用户授权尝试录像，要求先理解他人的安装方式，避免损坏相机。

## 已核实的公开实现

1. https://github.com/derrickyau9/Hasselblad-X2DII-ADB-Enable

   当前 README 明确面向 X2D II 1.3.16.2。通过工厂诊断命令 65 接入，添加主机公钥到 /blackbox/system/adb/misc/adb/adb_keys，再改变 sys.usb.config 开启 ADB；不刷写固件。它的公钥可在重启后保留，并未提供经过验证的自动回滚。我们上一轮已经获得 USB root ADB，因此不运行它的安装程序，不重复写授权公钥。

2. https://github.com/radium-wang/x2d-907-one-click-extension-toolkit

   当前线上 README 显示稳定版 0.4.17；原交接快照中的“下载暂停”已经不能当作线上现状。支持范围仍是一代 X2D/907 的 4.2.0，不支持二代。当前页面对恢复的定义是撤销该工具的改动，不是完整固件恢复。

   已阅读快照 src/x2d_play_software.py 的 install、init_config、restore 路径：校验固件和原文件 → 在 /blackbox 备份启动配置和 manifest → 上传载荷 → 临时 remount /system 为可写 → 写加载库/QML 等及服务启动配置（包含 LD_PRELOAD）→ 哈希回读 → 恢复只读 → 重启验证。失败 trap 试图恢复启动配置及移除本次文件。断电或未预见失败仍不能靠 trap 保证恢复。此流程不作为二代录像的可运行安装方案。

3. dash8097 的附件源码公开组件不是完整二代录像安装包。此次搜索没有取得用户提到的具体录像作者、演示或安装教程，已向用户索取来源。不能把“有人实现录像”的观察补写成已核实的安装步骤。

## 本机和实机新证据

- 安装了与原型匹配的 macOS Frida 17.22.2 主机依赖；未将 Frida 上传到相机。
- 工厂通道再次核实 camera-service 的固定哈希，读取服务 PID 为 380、383、1096（camera-service / camera-gui / phocus 的联合 pidof 输出，未按单个命令归属复核）。
- /system 是 ext4 只读挂载；/blackbox 为 ext4，可用约 2.5 GiB；/tmp 是 32 MiB tmpfs，可用约 29.8 MiB。
- MemTotal 937312 kB、MemAvailable 401252 kB 是一次时点读取，不能作为运行负载余量保证。
- 包内 Frida server 为 59171616 字节，无法直接放入当前 /tmp。原型默认 /data/local/tmp 尚不存在。
- 官方 vendor SELinux 策略对 hbl_camera_service 提供 self ptrace/execmem；对普通 system_data_file 的文件执行权限与 ADB su 域不同。静态权限片段不足以证明整个 Frida 加载/注入路径可用，不能靠关闭全局 SELinux 掩盖问题。
- 请求读取 battery/capacity 失败：该 sysfs 路径不存在。未据此推断电量。

## 当前阻点和边界

后续只读 API 查询尚未执行时，相机已不再出现在 USB/ADB 列表。无法判断是休眠、关机、拔线还是其他原因；已请用户确认。本轮没有设备持久写入、服务重启、策略修改、进程挂接或录像尝试。

原型录制尚未启动。固件静态记录表明上层 doStart_recording/doStop_recording 同位于 0x1f2d30，返回 Not implemented；应继续区分底层组件存在与上层可直接启用。

恢复连接后先查询原厂服务和 API 信息，记录基线；只有确认临时文件位置、执行权限、可靠停止/清理及编码流条件后才进行短录。若必须修改启动项或安全策略，应把具体改动、原件备份及可核实恢复路径单独整理后决定，不直接运行一代安装器。
