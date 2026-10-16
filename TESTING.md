# TESTING — 相机由 Codex 占用

操作者：codex-preview-debug。用户已于2026-10-15恢复授权，2026-10-16要求保存并推送当前已装机版，随后排查对焦点锁死。

已安装的恢复点：releases/x2v-20261016-af-fps。持续AF、MF切换、按键修复和24/25/30fps选择已持久化；重启后正式25fps库、RunningCont和无错误已核验。30fps仍可能掉帧，近端间歇性失效未闭合，新报告的触屏/摇杆对焦点锁死未修复。没有产品25秒自动停止限制；默认录制上限300秒。

只有当前操作者可发设备命令，其他工作可离线分析；保留原厂恢复路径。未经协调不得启动ADB、USB、录制、重启或装机测试。设备锁：local-verification/camera-testing.lock/owner.json。
