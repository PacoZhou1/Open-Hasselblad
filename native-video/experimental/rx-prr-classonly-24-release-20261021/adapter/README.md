# RX18 · RAW + ISP 同源出帧

实机短录已验证：`outputs/source-isolated-200007` 两段 RAW 保存 62/63 帧、约 24 fps、零接收丢帧；同时 color_null 收到1300×970、stride1536、2-plane 原生描述，累计161→388。双流分别停止、whole teardown及原厂恢复通过。完整记录见 `research/full-fov-pipeline/RX18_RAW_ISP_CONCURRENCY_20261012.md`。

基于 RX16 已验证 DNG 写盘：仅合入owned SUB五个几何字段、增加SOUT1/color_null分支及只读描述观察。RAW写盘和终端ACK16未改变。color回调不映射/复制像素、不做文件IO，原生回调照常转发；worker在RAW drain后打印描述。首个描述为source进程全寿命，不是每片首帧。新的token/文件名隔离旧版本。

当前版本还没有硬件H264代理输出，也未验证ISP像素、完整光学视场、原厂IQ校正适配或CPU/DDR/温度余量。原厂编码支路另见 `raw-hardware-proxy-candidate`。此版本安装为默认关闭的独立库，不改启动项；已消费的实机控制包不可重复执行。
