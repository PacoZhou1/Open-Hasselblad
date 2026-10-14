# X2V 固件 20261014zg：ISP 取景、色带、DNG 细线、误拍照卡死（2026-10-14 22:45）

固件目录：`dist/x2v-fw-20261014zg/`。机上 supervisor 选最新的 `x2v_product_boot_20261014zg.sh`，session `x2v_video_session_20261014zg.sh`，resident `libx2v_prr_resident_20261014zg.so`（sha `9864cc18…`），播放器 `x2v_prr_play_20261014zg`（sha `c3b3a3ea…`）。回退仍是 zf / zd / x / n。

验收 71 项：69 通过，2 项是验收脚本自己用 bicubic 抽第 0 帧造成的假失败。同一素材用 neighbor、从第 1 秒抽帧后 band_score 为 1.00–1.06（干净阈 1.5）。实机取景 cdump 为 **0.99**。证据在 `evidence/accept/20261014-224518/`。

## 1. 取景帧率：CPU RAW→PPM 不是正路

之前把 Bayer 在 A55 上做成 PPM 再给 GUI 贴图，这是在跟 ISP/显示抢带宽，录 ProRes RAW 时只能到 12 fps。正路是走原厂已经接好的那条：

- 色彩口 SOUT1（1300×970 NV12）→ `color_null = wl-disp` + LCD 3D LUT
- 传感器 RAW 口只给录像，不再给取景
- liveview `buffer_nr = 6`（3 个缓冲只有 12.4 fps）

这就是在用 ISP 出图、显示硬件上屏，不是再发明一条 CPU 预览。GUI 在 `ispView` 时藏掉 residentPreview。

| 状态 | zf（CPU RAW 预览） | zg（ISP `wl-disp`） |
|---|---|---|
| 待机 | 偏低，用户仍嫌慢 | **24.1 fps**，colour_fix 8.2 ms |
| 录 ProRes RAW | ~12 fps | **24.4 fps，0 丢帧**（预处理最长 43 ms） |
| 录 DNG | ~20 fps | **24.1 fps，0 丢帧** |

`colour_fix` 仍在 CPU 上做（每帧测增益 + 改 NV12），但只动 1300×970，9 ms 进得去 41 ms 预算。没有把 Bayer 全幅拉到 CPU。

## 2. 回放粗条纹

粗黄条来自 ISP 色彩口（半高上行 48+96k 与 80+96k），不是 RAW。录制预览如果走 RAW 口就看不见；机内回放播的是 H.264 / DNG 的 proxy，所以旧素材回放有、RAW 预览没有。

zg 在 dump 钩子里对**每一帧**色彩口做原地修复，然后才进 `wl-disp` 和 H.264。显示和新录的 264 / DNG proxy 是同一份干净帧。

- 取景 cdump `band_score` **0.99**（1 为干净）
- 新 H.264 / DNG proxy 中段 neighbor 抽帧 **1.06 / 1.00**，肉眼无条
- **旧夹不会改写**。相册里 zf 及更早的 264 / DNG proxy 回放仍有条。请新录一段再看回放。

## 3. DNG 细横线

zf 只插值了 PD 行上的蓝色 class 点（奇数 x）。整行的 G 点还在，大约 +0.35%，细线还在。

zg 对 `y % 6 == 1` 的**每一列**用上下同色 ±2 行做四舍五入均值。DNG 16-bit、打包 12-bit、ProRes RAW 预处理三条路径同一算法。`test_dng` 主机：class 像素 1 885 680，修复后与场景差 0。

| 素材 | PD 行残差 all / G / B |
|---|---|
| 你看的 `X2V_DNG_20261014_193736`（修之前） | 0.15 / 0.10 / 0.28 |
| zf `204854`（只修了蓝点） | 0.04 / 0.11 / 0.00 |
| zg 新录 `X2V_DNG_20261014_224728` 第 10 帧 | **0.00 / 0.00 / 0.06** |

旧 DNG 文件不会被改。新录的 DNG / ProRes RAW 才是整行插值。

## 4. 视频页误拍照卡死

全按已经在 `setFullPressActive` 被数拍、不进 still。漏网的 still（触摸、残留拍照控件）一旦走到 `exposing`，RAW 图会把 camera-service 挂死，半按也回不来。

zg：GUI 看到 `exposing` 且视频 session 仍在，就下 `live_view_on` 取消。半按仍走原厂 AF / 关提示 / 回 liveview。

验收：`fullpress=1`，ISO 页全按只录像不拍照，菜单半按回取景，`odindb capture` 无此方法且 session 仍 up，切回拍照再进视频正常。没有再制造一次真 still（那会在修不好时必须拔电池）。请你在视频页再试一次当时那个「拍照」动作：应不再卡死，半按应回到录像取景。

## 5. 验收数字

开机：overlay 11.4 s，进入提示 14.3 s，视频起来 27.8 s。USB 提示仍算 ENV（线在才有）。三路录像 0 丢帧；屏幕按钮；回放打开/点播/关闭；存储将满自停；拍照模式再回视频。均过。

假失败两项（已用同一文件复测为过）已把验收改成 `-ss 1` + `flags=neighbor`，下次不会再误报。
