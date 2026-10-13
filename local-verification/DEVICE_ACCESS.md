# X2D II 实机接入 — 2026-10-11

用户已授权连接相机并推进接入，选择“仅充电 / Phocus 联机”模式。

## 实际完成

- macOS USB 检出 X2D II，VID:PID 2756:000b。
- 核对官方 1.3.16.2 CIM 并解包，全部 CIM 条目哈希校验通过；system/vendor 分别提取 1524/93 个普通文件。
- 静态 USB 配置与实机描述符对应：工厂 bulk 接口 4，控制 OUT 0x06 / IN 0x87。接口 3 为存储，不使用一代默认接口。
- 读取参数 27 得到 v1.3.16.2；实机返回路由 03 00 05 08 0f，已在独立适配器中加入精确匹配。
- 工厂诊断读取机型 eagle2_hb722、平台 eagle2、UID 0，以及 camera-service SHA-256：51b9e02f8bfebf388be8dfa163c8e512bee19aeb8ae37a6712727ccc6f26a52d。与原型 profile 一致。
- 通过原厂 sys.usb.config 触发临时 ADB 模式，未修改 persist 属性、启动文件或固件。当前 USB 配置为 rndis,mass_storage,bulk,acm,adb。
- ADB shell 已连接，实际 UID 0，SELinux 上下文 u:r:su:s0。

## 尚未通过的门槛

原型 device.py preflight 在 ADB 读取 camera-service 哈希时失败：Permission denied。工厂通道在 u:r:hbl_camera_service:s0 上下文能读取该文件，ADB 的 su 上下文不能。runcon 到 shell 上下文亦被拒绝；没有关闭 SELinux 或更改策略。getenforce 本身也被拒绝，因此没有据此报告当前 enforcing 值。

/data/local 和 /data/local/tmp 尚不存在；原型默认暂存位置不能直接假定可用。本次未创建相机目录、上传录像库、挂接服务或启动采集。

因此已经完成“USB 工厂诊断 + root ADB 接入”，尚未完成“原型录制运行条件”。后续应研究保持原有安全策略下的受控执行路径、临时存储位置和清理，再验证编码预览与真实短片。不能为了让预检通过而删除固件哈希门槛。

## 文件与环境

- camera_access.py：二代专用窄范围适配器，保留原仓库快照；不调用其配置重置入口，身份/哈希通过才允许临时开启 ADB。
- camera-access.json：工厂通道身份与权限证据。
- adb-access.json：独立 ADB 回读，包括失败信息。
- 本机新增 Android platform-tools 37.0.1 与项目 .venv；pyelftools 使用可下载的 0.32，未修改原包固定依赖清单，也未宣称重现全部历史测试。

恢复普通 USB 模式可在后续结束调试时用固件的临时模式切换；官方配置及原参考说明表明重启会恢复生产模式，但本次没有重启实测。当前保留 ADB 以继续调试。
