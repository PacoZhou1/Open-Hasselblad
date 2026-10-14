# X2D II 原生相册接入研究

2026-10-11；研究对象为本地解包的 firmware 1.3.16.2。此轮仅静态检查和本地主机验证，没有 ADB、factory、设备写入或 UI 部署。

## 结论与证据边界

原厂存储层已经认识 MP4 和 Video，原厂 QML 已有视频缩略图、视频状态与控制分支。现有录制目录 `X2V_VIDEO` 不属于原厂 DCF 相册目录，因此不会因保存 MP4 自动进入原生照片列表。

候选数据形态是实际路径 `/mnt/media_rw/ssd/DCIM/NNNHASBL/Bddddddd.MP4`，配合同 stem 的真实 JPEG `Bddddddd.SRC.JPG`。原厂逻辑路径省略 DCIM：`/ssd/NNNHASBL/Bddddddd.MP4`。这是静态推出的候选，尚无该形态的原厂 browse 回读、原生视频混排或真实播放证明。

原生相册“支持 Video 分类”不能等同于可播放。`resources/gui-resources/3/qt/qml/app/qml/viewmodels/BrowseViewViewModel.qml` 的 `startPlayback`、`videoControlAction`、`stopPlayback` 仍是 `EC1706-874` TODO，实际 Camera 调用被注释。

## 原厂存储证据

被分析 ELF：`resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/bin/camera-storage`。可复跑静态脚本与完整汇编保存在 `native-video/outputs/native-album-research/`。下面地址均为 ELF 虚拟地址，不是文件 offset。

| 规则 | 静态证据 | 含义 |
| --- | --- | --- |
| MP4 → Video | `CacheItemInfo(QFileInfo)` `0xb9890`；`0xb9b7c–0xb9b98` 上转大写后比较 UTF-16 `MP4`，写入 type 2 | 扩展名被识别为 Video，未检查实际 codec |
| DCF 目录 | UTF-16 常量 `0x213b94`: `[1-9][0-9][0-9]HASBL` | 安全计划仅接受完整 `NNNHASBL` 名称 |
| DCF 文件 | `0x213bbe`: `%1[0-9][0-9][0-9][0-9][0-9][0-9][0-9].%2`；QStringView `0x2839a0` 指向 UTF-16 `B` (`0x213cea`)，length=1；初始化 `0x45ee0–0x45ef8` 构建 wildcard | B 加七位十进制编号；不使用随机巨大编号 |
| 扩展筛选 | `0x213b74`: `^(%1\|%2\|%3\|%4)$`；初始化 `0x45e08–0x45e84` 代入 3FR/HIF/JPG/MP4；`isSuffixValid` `0xaf7e0` | MP4 是原厂允许扩展之一；regex 构造 flag 1 为大小写无关 |
| 路径筛选 | `CacheDir::isItemNameValid` `0xaf328` 对已配置 regex 列表逐项 `QString::contains`；`dryBrowse` `0xae848` 调用路径和 suffix 检查 | 根目录必须符合配置；任意 X2V 根目录不等同于原生相册 |
| DCIM 根 | `0x213d26`: `^DCIM$`，初始化 `0x45f3c–0x45f60` 创建 regex | 实际 SSD 根下需要 DCIM |
| logical → physical | `StorageDevices::displayPathToReal` `0xd4060`；`0xd4498–0xd44e8` 将实际 volume root 追加 `/DCIM` 再替换 display prefix | `/ssd/100HASBL/B0000001.MP4` 对应物理 DCIM 文件，logical 不应再写 `/DCIM` |
| physical → logical | `StorageDevices::toDisplayPath` `0xd3680`；`0xd3c5c–0xd3cb0` 去除 `/DCIM` | UI 和 Storage API 使用 display path，播放器实际文件 URI 需要独立映射 |
| 视频预览 | `Metadata::parse` `0x12b170` 的 Video 分支 `0x12b348` 将路径按 `.` 分割、取首段并追加 `.SRC.JPG` (`0x12b3c4–0x12b3d4`) | 目录和文件都不要包含额外点；使用标准 stem |
| 缺少预览失败 | `0x12b9c0` 建 QFile，`0x12b9d0` 检查 exists；`0x12bab8` 输出 `Video preview missing:`；存在结果保存在返回值寄存器 | 缺少 SRC.JPG 时 metadata parse 返回 false |
| 预览解析特征 | 存在预览后 `0x12b9dc–0x12ba38` 按 JPEG 文件大小构建 image metadata；本分支未调用 `parseHeaderJpeg`，MP4 日期来自 `getFileCreationDate` (`0x12bb64`) | 不需要捏造 EXIF 拍照信息；实际图像解码仍需真实 JPEG |

历史本地记录 `local-verification/playback-sample-browse.json` 显示把 `/mnt/media_rw/...` 直接交给 storage browse 被按设备 `mnt` 解析而失败；把 `/ssd/X2V_TEST_20261011` 交给它返回 Non existing item。该记录只证明两次旧请求失败，不代表当前设备状态。本轮静态路径映射解释了为何 DCIM 外目录不成立。

### 同 stem 预览与 Video 分类风险

`CacheDir::dryBrowse` 使用 `QFileInfo::baseName` 与 `CacheItem::fullPath` (`0xaf188`) 分组，`B0000001.MP4` 和 `B0000001.SRC.JPG` 会共享 baseName。默认初始化的完整过滤链已确认允许 sidecar：filename regex 第二参数是 ASCII `*`（`0x1fc356`），最终 pattern 为 `B[0-9][0-9][0-9][0-9][0-9][0-9][0-9].*`，没有锚。`dryBrowse` 在 `0xae918–0xae920` 取 `QFileInfo::baseName`，然后在 `0xae9f0–0xae9f4` 传入 `isItemNameValid`；该函数 `0xaf3f0–0xaf3fc` 调用 `QString::contains(QRegularExpression)`。因此 MP4 和 SRC.JPG 输入同为 `B0000001`，`.*` 允许零字符，均通过；SRC.JPG 的最终 suffix 又为 JPG，也通过 suffix gate。该判断使用本地 Qt 原生正则复核，证据为 `sidecar-filter-proof.json` 和 `check_sidecar_filter.py`。

`CacheItem::bestFile` `0xa4c10` 在 `0xa4f14–0xa4f84` 寻找首个满足 mask `0x54` 的类型，也就是 Video(2)、JPEG(4)、HEIF(6)。没有发现这里将 Video 明确排在 JPEG 前面的逻辑。文件枚举/列表顺序及 FileContent 选择尚需核实；不能假设先创建 MP4 就能永久保证 Video 分类。以后必须回读原厂 item 的 fileType=Video、文件列表、logical path 与预览，才能推进发布成功状态。

## 刷新与编号

`Cache::browse` `0x92430` 在 `0x92550` 检查 `isBrowsed`，已浏览目录可直接调用 `finishBrowse` (`0x9259c`)。重进相册或重复 browse 不保证重新枚举磁盘。异步首次扫描 `0x95e50` 调用 `dryBrowse`，merge 后 `0x9eec8` 进入 `updateFsDir`。`FileSystemWatcher::checkDirectory` `0xe2000` 对目录添加 QFileSystemWatcher (`0xe21d0`、`0xe22c0`) 并更新 deviceStatus；但尚未证明外部创建的 MP4/SRC.JPG 会使已经浏览的 CacheDir 失效。没有发现公开的“只刷新目录”Storage method。

已记录的 storage methods 有 browse、browse_extended、get_metadata、create_folder、notify_new_exposure_item、remove、remove_extended、reset_image_seq_number、set_metadata。`notify_new_exposure_item` 接收的是拍照帧/共享内存与曝光元数据，不能作为任意视频导入接口；reset_image_seq_number、format、create_folder、伪造 file_saved 都不应拿来做缓存刷新。

DCF 内部确有 `DcfMain::generateFilenames` (`0xfe418`)、`Dcf::generateFilenames` (`0x1047f8`)、`Dcf::getAvailableFilePath` (`0x1008a0`)，但未发现公开的“给外部视频原子保留一个文件编号”的接口。`DcfVolume::getFileIndexFromFolder` (`0x108058`) 扫描并读取 basename 去掉首字符后的十进制编号 (`0x1082b8–0x108310`)。导入超大随机编号有推进原厂拍照索引的风险。

因此后续发布需原厂分配/保留 API，或可实际执行、有限时且禁止拍照的窗口；观察 `camera_file_index`、现有目录最高编号、相机空闲与禁止曝光都只是 reservation 前置条件。只读取索引后写文件会与快门竞争。当前计划器仅提出 `camera_file_index + 1`，若本地 snapshot 最高同 stem 编号超过观测索引就拒绝，不尝试碰撞后跳到巨大编号。

## 本地只读工具

`local-verification/publish_native_video.py` 只有 `inspect` 与 `plan`，没有 publish、ADB、网络请求或 destination 文件写入。名字保留发布目标，但执行权限刻意不存在。

Source verification 要求同一目录中有最终 `X2V_*.mp4`、严格 schema 1 manifest、schema 2 saved recorder state 和 schema 1 saved bridge/session state。manifest 不带 hash，所以工具独立计算 SHA256；plan 额外要求与调用者指定的 expected SHA256 完全匹配。源设备路径必须准确为 `/mnt/media_rw/ssd/X2V_VIDEO/<id>.mp4`，file/id/file_url 必须一致。只接受完成受控停止、零 error/mux_error/signal/queue、RTP confirmed off、receiver 不存活的组合；缺证据拒绝。

工具逐层使用 dirfd/O_NOFOLLOW 验证目录和普通文件，拒绝符号链接、硬链接、路径 traversal、重复 JSON key、未知 manifest 字段与尺寸/帧/时长不一致。打开文件后用稳定 inode/size/mtime/ctime 对照并重新校验目录项哈希；ffprobe 解码计帧和核 H.264 单流后，ffmpeg 使用 `-xerror -err_detect explode` 对完整视频帧序列解码到 null，再从真实第一帧生成 JPEG 字节在内存中算 hash，不生成照片 EXIF、不伪装文件类型。所有媒体命令使用 `-v error`，不仅要求退出码 0，也要求 stderr 无非空错误消息；因此 ffprobe/ffmpeg 报错却返回 0 时仍拒绝。`validation.full_frame_decode=true` 和 `decoder_error_stderr_empty=true` 表示这次完整扫描及第一帧提取均未由工具报告解码错误，不表示已完成设备播放器验收或对拍摄内容的语义鉴定。

plan 要求现有本地 SSD 根 snapshot、完整合法 DCF folder 和原厂 camera_file_index 观测值；不创建目录。全目录检查任意扩展同 stem（大小写无关），包括 3FR/JPG/HIF/HEIF/MP4/SRC.JPG 和未知扩展；出现 symlink、非文件项、扫描超限或目录变化也拒绝。输出 `target.logical_native_path`、`target.physical_native_path`、`playback_mapping`，并始终标明 `device_verified=false`、`publish_enabled=false`、`published=false`。这份映射可以给模拟器使用；不能称作相机原生数据已导入。

调用形态（参数指向本地证据副本；先 inspect，再把其 SHA256 传给 plan）：

```sh
python3 local-verification/publish_native_video.py inspect \
  --source-directory /absolute/local/evidence \
  --id X2V_20261011_122327_4284_2 --session-state session-saved.json

python3 local-verification/publish_native_video.py plan \
  --source-directory /absolute/local/evidence \
  --id X2V_20261011_122327_4284_2 --session-state session-saved.json \
  --destination-root /absolute/local/ssd-snapshot \
  --folder 100HASBL --camera-file-index 123 \
  --expected-sha256 <64-lowercase-hex>
```

保存状态缺字段的早期 MP4 样本不会被此工具认作具备完整发布证据；不能补写假的成功 manifest/state 来绕过门槛。14 项测试使用本地 ffmpeg 合成媒体和显式 fixtures，属于主机安全行为验证，不是相机录制、原厂 browse 或物理播放证据。其中真实子进程稳定复现“return 0 + error stderr”，另外对真实媒体探测、全帧解码与首帧提取三个阶段分别注入相同故障，确认 inspect 每次拒绝，不会返回 source_verified。

root 提供的实机录制第二段原始证据副本 `native-video/outputs/bridge-c-repeat/native-publish-evidence` 也已只读 inspect 通过：`X2V_20261011_122327_4284_2`，1300×970 H.264，369 帧，12.308333 秒，20,115,116 字节，MP4 SHA256 `f044c5e47820be04e77e1018c4e1cb430f854dd768b789015de3fc78cf445dfa` 与 provenance 一致。完整帧严格解码与首帧 JPEG 提取均为零工具错误日志；首帧真实 JPEG 60,581 字节。原始 manifest、recorder、session JSON均校验一致。结果保存在 `native-video/outputs/native-album-research/real-bridge-c-inspect.json`，`source_verified=true` 仅表示本地证据与媒体验证通过，`device_verified=false` 保持不变；此次没有生成 plan、访问设备或导入 DCIM。

## 后续设备发布架构候选（本轮未实现）

在 root 评审后可研究小型独立 C publisher，复用录制器已经使用过的 `renameat2(RENAME_NOREPLACE)`，不能使用 shell `mv -n` 或 check-then-mv 来声称不覆盖。发布源 MP4仍保留 X2V_VIDEO 原件，导入通过同一 SSD 文件系统内的受限 staging copy；在确定空间足够后完整复制并重新 hash/fsync。应以 openat/O_NOFOLLOW 固定 SSD/DCIM/folder 的 dirfd，验证 mount 与同一 st_dev，所有相关照片扩展/sidecar 冲突均拒绝。

MP4与SRC.JPG是两个文件，两个rename不会自动构成原子事务。需要拥有编号 reservation、相机写入排他窗口、publisher自己的排他锁与 crash journal。先发布真实 SRC.JPG，再发布 MP4可避免正常路径中出现Video缺sidecar，但可能产生短暂JPEG item与崩溃后的孤立sidecar，因此还需要缓存处理和恢复协议。任何 cleanup 都仅能撤销本次 journal 拥有且 hash/inode仍匹配的文件，不能删除同名照片；失败保留完整源MP4。

发布完成应 fsync 目标目录，关闭禁拍窗口之前核实原厂索引不会复用该stem，然后进行受支持的缓存刷新或等待已验证的失效事件。storage browse/get_metadata 需回读 logical item、Video type、preview可解码、正确时长/数量/顺序及源hash映射；最后再用先通过模拟器确认的 UI接入控制和播放。原厂播放TODO需由真实录像映射到可验证的播放器适配层，不能仅改fileType或伪造 metadata。

发布账本仍可存在扩展目录，不应向DCIM塞自定义manifest使其冒充照片。拍照元数据/光圈快门等原厂属性只显示确有数据的字段；预览生成时间不能冒充照片曝光时间。native 视频条目时间/排序若只用创建日期，复制的mtime/creation semantics必须另行核验。

## 尚未通过的门槛

1. 原厂编号 reservation，或真正可执行的有界禁拍窗口与相机索引一致性。
2. Video与SRC.JPG同stem后原厂bestFile/FileContent不会错误选择照片。
3. 原厂缓存失效/更新路径和完整browse回读。
4. 两文件事务/no-replace发布、掉电恢复、空间不足与照片竞争故障验证。
5. 原厂控件与视频混排UI先经过模拟器视觉/交互确认，然后再获准部署。
6. 设备上的原生相册、播放生命周期、返回照片、删除语义与用户实际验收。

当前交付证明静态规则与本地安全计划器成立，不证明原生视频混排已上线。

## Playback/拨轮契约增量

完整挂接契约已整理在 `native-video/ui/NATIVE_BROWSE_CONTRACT.md`：Playback进入原厂browse，初始list选择SortedContentModel尾项；KeyFn.Up在未放大的单张下进入3×3 grid，ControlWheelNavLeft/Right换条目（后轮缩放、前轮选片按官方默认与用户确认；不由 KeyFn 语义名推断 raw key）；没有新增退出/返回控件。原厂照片delegate链与视频TODO的实际位置、当前item/index/多选区分和播放器清理生命周期均有QML行号证据。C++ `SortedContentModel::lessThan` 是正常文件DisplayRole字符串排序，不可宣称按EXIF时间最大选取。

进一步静态确认 `CacheItem::addFile` (`0xa5ac8`) 在 `0xa5cd4–0xa5cdc` 直接emplace到files列表尾部，未见优先排序；结合上述已证实的 sidecar 过滤链，共享 stem 后的 Video/JPEG 优先风险仍成立。默认规则允许 SRC.JPG，并未排除 sidecar；后续应以原厂 browse 回读验证真正的 FileContent/type 和缓存。按 root 本轮要求，进一步相册深挖暂停；设备测试不写 DCIM、不进行混合索引导入。

## 原厂菜单恢复交付（静态证据与设备来源分开）

`camera-gui` SHA256 为 `b1b643cb36176cd5a49129dd9bb2be480aa045a96ed1c35c30a779ab5af0801b`。本地 `recover_menu.py` 仅在隔离 Unicorn 内存中执行静态 initializer，Qt 字符串/分配/容器边界由主机替代；没有在相机运行固件、没有修改模拟器。动态 getter 只用于标明 fixture 的条件分支，不等于相机当前状态。

| 交付文件（均在 outputs/native-album-research） | 内容与边界 |
| --- | --- |
| `native-menu-schema.json` / `.md` | `_GLOBAL__sub_I_menux2d.cpp` 0x393050 恢复 11 个顶级类、43 个菜单、258 个静态节点。含原厂顺序、menuLabel/menuFile、全部文本/description、elem/proxy/options/itemValues、RW/availability 枚举身份；propValue 保留 null，未伪造默认值。 |
| `native-property-choices.json` | DisplayConverter static initializer 0x3f1888 的 58 个不同属性、237 个选择。文本与原生 value 配对；回调可用性未据此宣布已计算。这里的未使用 video_resolution 通用常量不是该机视频规格证据。 |
| `native-longlist-choices.json` | addLongLists 0x170dee0 恢复 17 个长列表，包括计时、包围、间隔、所有自定义按钮与控制环。按钮保留条件回调。 |
| `native-dynamic-choice-rules.json` | WB、ISO 上下限动态规则、Wi-Fi 地区频段、附镜头快门限制、滑块与焦距值域，以及准确自定义按钮/interval 条件。 |
| `native-menu-condition-functions.json` / `native-menu-conditions-disassembly.txt` | 34 个 RW 与 9 个 availability 代码的原厂回调身份和完整函数汇编；不是全量已求值公式。 |
| `native-timezone-model.json` | 原厂 kTimeZoneModel 的 38 行，保留 tzId/tzPos/tzOffsetX/tzIcon/time/cities。纯静态模型，不推测当前时区。 |
| `native-license-initial-rows.json` | 原厂 NOTICE 首批 300 行及完整本地 gzip 路径。LicenseModel 实际调用 gunzip -c /etc/NOTICE.xml.gz，从 file-content 行起 trim 并按 300 行加载；保留原厂文本来源。 |
| `native-lens-menu-fields.json` | root 有界只读复制 lens_config 后，仅导出菜单所需字段：128 源行、124 不同 ID。未复制全量校准到菜单报告；源顺序不保证等于原厂排序，重复 ID 与未翻译内部 name 保留，native_model_verified=false。 |

静态值域：亮度 1–100、遮罩 20–100 均步长 1；EVF 亮度 0–100，常规步长 1、100ms 内快速拨轮步长 4；contrast 为无 proxy 的 demo 项，只能称原厂通用 fallback -10..10，不能称实机图像调节能力。手动焦距是 [0..4,0..9,0..9] 三位组合锁，即 UI 可输入 0..499mm。色温 2000..10000 K 步长 100，并插入当前 off-grid 值；色调是原厂 71 个非均匀值，当前 off-grid 值同样保留。

ISO upper/lower 使用动态 `Camera.sv_list`，原生 value 是 SV 整数，显示 ISO 数字来自独立阈值表。原厂先去掉 Auto sentinel 32766，再 upper 去首项、lower 去尾项；不能用阈值表冒充相机能力列表，也不能把显示 ISO 数字写成 SV。Wi-Fi region 为 2/8 时仅 2.4GHz，否则 5GHz 与 2.4GHz；这不是 Wi-Fi 扫描列表。attached_lens 为 0 时快门限制 13 个固定档，非零时另加 6 个 f 倍率档。

自定义按钮普通项无额外回调；EVF Dioptre Adjust 要求 `GuiConfig.hasEvf()`，Screenshot/Language/AF Dump/Debug Script 1–4 要求 `!GuiConfig.isLockedDown()`。间隔计时的准确最短秒数：processing bit0 → 8s，否则 bit1 → 6s，否则 image_format 为 1..4 → 5s，其余 → 2s。菜单行自身 RW/availability 条件还须同时满足。

`LensSelectModel::init` 读 LensModel::lenses，跳过 id=0，按 LensModel 上下文翻译 name、读取 hasDistances，并从 Gui.user_lens_list 得到勾选；原厂说明无距离数据的镜头灰显但仍能勾选。完整镜头模型还涉及原厂排序/重复 ID 与 LegacyOptics 表，当前导出不冒充其运行时结果。屈光度步数不是静态常量：QML 使用 System.diopter_motor_index/num_steps，root 的本轮只读证据显示 num_steps=26；当前 index 仍应来自 live getter 或明确 fixture。

hidden developer 的 af_test_mode 选项源未恢复。真实 ISO sv_list、当前设置、全量 RW/availability 求值和原生模型行为仍需实机只读数据或明确桌面 fixture；模拟器交互通过不替代这些证据。所有文件已直接交 UIUX 使用，模拟器由 UIUX 唯一写入。
