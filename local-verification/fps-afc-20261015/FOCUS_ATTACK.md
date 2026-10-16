# Video AF investigation — 2026-10-15

Scope: C24 recording plus native AF-C / ToF. No changes to sensor rate, laser emission settings or raw lens motor commands. Later 2026-10-16 bounded experiments temporarily change native AF-controller selection and ToF confidence acceptance; see below. Permanent baseline is unchanged.

## Confirmed obstacles

1. Native ToF producer calls `sendDataToRcam` continuously in video, but the AF statistics consumer only observes startup frame1. The native task is 0x23cc bytes, type5, ToF statistic id0x410605; producer goes through taskbuf namespace `rcam`, name `tof_spot`.
2. The third `taskbuf_get_consumer` argument is 500, **not established as camera channel**. The diagnostic label `ch` is misleading. Actual `tof_lib_statistics_info` AF handle is0.
3. Repeated control loss has a concrete memory cause: kernel `lowmemorykiller` logs explicitly kill camera-test at adj200; one snapshot shows camera-service RSS216970 pages. This replaces the earlier cgroup-only explanation. Moving the diagnostic to another cgroup/session did not prevent these kills.
4. Resident `prep` eagerly prepared four extra DNG source buffers even for ProRes RAW: about93.5MB (89.2MiB), plus first-touch of base slots. `toflean` keeps extra DNG buffers lazy, while actual begin_dng retains ensure_dng(). It leaves all image algorithms and encoder settings unchanged.

## Completed trials

- `tofroute-214334`: stopped during stable mode handover before candidate installation; normal photo restoration subsequently verified.
- `tofroute-214609`: RTLD_NEXT cannot resolve local library original; candidate startup failed. Replaced with explicit original library handles. No recording.
- `tofroute-215039`: explicit handles work and startup frame1 reaches original ADS6401 AF entry with rc0. Host factory channel then unavailable; restored baseline and photo via GUI. No recording.
- `local-af-2153`, `local-af-2156`, `local-af-2200`: device-side diagnostic process killed during startup; these are NOT successful AF tests. Boot selection restored explicitly afterward. `local-af-2203` waited for launch permission and expired without starting video.
- `toflean-220825`: C24 554seen/554written/0drops/error0. Producer reaches>1900 frames; consumer only frame1, no AF success. Restoring the larger stable video configuration again lost factory control; baseline boot restored and stock photo/down/idle/no error subsequently verified.

## Next targeted experiment

`tofrequest` asks the original AF-thread `dcam_af_get_stat_cfglist` callback to append the original `tof_lib_get_stat_cfg(0,0x410605,...)` entry once after MODE21 starts. Native list layout is0x58: count plus up to10 pointers. Existing entry is retained, bounds checked, original result preserved. No cross-thread injection into AF internals. The purpose is to test whether switching capture graphs left the ToF memory-stat subscription inactive.

All experimental branches remain isolated directories. Current permanent session remains aligned20261015b. Subsequent trials restore stock photo mode rather than reopening the memory-heavy stable recorder unnecessarily. No new camera partition flashing.

## 22:45 update: subscription lifecycle localized, AF not yet functional

- `tofrequest-221216`: native ToF config request accepted (`id=0x410605`), but no renewed consumer subscription. No completed focus probe in that trial.
- `tofmem-221541`: reduced experimental encoder/source queues; recording observed 140 frames / 6.05 s before control timeout. AF status alone is not evidence of focusing. Memory reclaim still killed factory clients.
- `tofattach-222023`: clean video-idle focus probe. Native `tof_spot` attach occurs at startup, detach occurs before MODE21 prepare, and there is no later attach. All six native AF samples were RunningCont / None / lens Idle. Baseline/photo restoration verified.
- `tofrebind-223027`: first provider capture guard rejected Android load bias, so activation did not run. Later restoration confirmed photo/Active/no error/no candidate mapping.
- `tofrebind-223339`: corrected the ELF mapping bias (PT_LOAD begins at 0x2b000). Native provider activation and register both return0; a second native attach is logged. Host control was lost before focus command, so this is subscription evidence only.
- `tofrebind-223656`: repeated attach/activate/register succeeds. Complete video-idle focus probe still reports RunningCont / None / Idle. No native ToF AF statistics call observed. Restoration verified. The encoder is now lazy during this idle-only experiment; begin_clip still opens it on actual recording.
- `tofrebind-223901`: added a pass-through observer to distinguish taskbuf notification from downstream AF dispatch; control lost during enter before the intended focus probe. Not a completed observer test. Stock photo was subsequently verified.
- `tofrebind-224056`: failed during temporary script installation; independent restoration copied the exact baseline script back. Subsequent read showed photo/down/idle, native live view Active and active_error=false.

Important evidence correction: `X2V_TOF_STATS output` counts entry into `sendDataToRcam`, not successful delivery to taskbuf/AF. The vendor function can return early if `self+0x15358` is null. Do not equate these counters with successful publication. The next compiled diagnostic logs the producer/backing pointers and the pass-through observer, then native consumer entry.

Latest compiled candidate: `rx-prr-explore-tofrebind-20261015`, SHA256 `67f145bf41a53fd49bd0a268bcec66d7ea48947556d32118c8520d68c9491b6d`. It is NOT installed/selected for boot. Its provider methods are validated against matching librcam create() addresses; the object destroy method is wrapped to invalidate the captured pointer before native destruction. Activation/registration call existing native methods, not writes to the provider active flag. No laser power/timing, motor commands, confidence weights or sensor timing changes.

Recovery state: original permanent session selected, stock photo/down/idle/Active/no error verified. No recording/test running. Host keep-awake lease remains enabled. User asked for normal power cycle because even stock photo showed MemAvailable32812kB and repeated lowmemorykiller events for camera-test/phocus/odindb-send. Repeated factory timeouts must not be presented as AF failures.

Next after reboot: ensure keep-awake; one video-idle focus probe using the latest diagnostic. If producer null or backing differs, fix producer binding; if observer runs but AF does not, trace memory-stat buffer manager and AF dispatch policy. Do not change focus weighting until fresh input reaches native AF. Concurrent video AF and physical focusing remain unverified.

Test harness improvement: `trial_af_rebind.py` now retains one verified USB context rather than rehashing the binary for every property read, reopens only after transport failure, retries only read-only state polling, and waits for down+idle on exit. Mutation commands are not automatically replayed after ambiguous timeout.

## 2026-10-16: fresh boot, ToF reaches native AF

User reboot confirmed. Keep-awake renewed. Baseline photo had ~317 MiB MemAvailable; bounded trials retain one factory context and exit to photo.

- `tofrebind-105824`: native producer/backing valid, >600 observer notifications. Therefore input publication and restored subscription are working.
- `tofdispatch-110046`, `tofdispatch-110508`: native dequeue/enqueue return0, bad=0; ToF item dispatch points at native AF notifier. This narrows loss to the AF policy.
- `tofdispatch-111100`: MODE21 AF policy has only one master input `0x440102`, no ToF.
- `tofpolicy-111348`: preserve that master, append ToF `0x410605` as role4 asynchronous slave via original policy load/reset on the native AF task. >600 ToF frames now reach both native statistic functions (size9164,type5,rc0).
- `tofrun-111730`: native ToF and AF run functions execute continuously. ToF ADS6401 subtitle has real nonzero distance/peak.
- `tofrun-112113`: ProRes RAW + native ToF/AF short test, 147 frames written, 1 dropped, 6.25 s, 427921058 bytes, error0, max write13ms. Clip `/mnt/media_rw/ssd/X2V_RAW/X2V_PRR_20261016_112055`. Container/decode/playback not separately tested in this trial. Returned to stock photo, no active error, MemAvailable237744kB.

**Correcting earlier coarse status interpretation:** polling `lens_drive_status=Idle` missed short motor activity. Full native log shows focus position948→1477→1563 and target1563 reached, then contrast search scans and fails to lock. Native ToF confidence2 is a classified enum, not a percentage: config maps OK to peak confidence80 / range confidence100. Do not call it inherently low confidence. Generic `tof_get_output_*` getters use a different common context from ADS6401; their zeros do not negate the native ADS6401 output.

Current decisive blocker: real ToF distance/target vary, but PD peak2218/conf152 and CD fv286/240 stay stale. Native autofocus enters a contrast-based initial acquisition that cannot finish correctly with frozen PD/CD statistics. Native AF-C trigger flag also prevents continuous-controller eligibility during this phase.

- `tofgate-113149`: bounded longer focus test with AF timing getter reporting actual24fps instead of native requested100fps. AF explicitly reports FailedCont. Native body focus mode2 (AF-C), half_press1, trigger_mode1, afc_status0; hybrid eventually idle but trigger mode remains1. Exact baseline/photo restoration succeeded. This rules out simply waiting longer.
- Next temporary candidate `tofcont`: only MODE21 + native body AF-C selects existing continuous controller at hybrid start, clears native trigger mode via original setter. It does not inject measured distance, alter confidence thresholds or send raw motor commands. This is an experiment, not a completed autofocus feature.

All temporary selectors were restored after each completed trial. Permanent baseline remains `aligned20261015b`, boot supervisor20261015c. No flash partition updates, no permanent AF installation.


## 2026-10-16 12:10: first optical focusing during ProRes RAW recording

Candidate `native-video/experimental/rx-prr-explore-tofmaster-20261016`, built by `build_tof_master.py`, now produces native lens movement and visible optical improvement while RAW is recording. This is an experimental ToF-only continuous-control path, not complete native hybrid AF-C or face tracking.

Decisive chain: restore ToF consumer → append asynchronous ToF stats in native AF policy → bypass the initial still-photo contrast scan only for MODE21 + native AF-C → clear native trigger-only state → use native controller position method with ToF as master. Merely enabling ToF input, reducing threshold, disabling fusion or selecting the position method individually left the master output on missing PD data and did not move the lens.

Temporary controller snapshot: ToF threshold80→60, super threshold95 unchanged; fusion0, method0, master3(ToF), slave0(PD). Timing getter24fps; native recording getters reflect video mode and actual resident recording flag. The snapshot does not refresh with UI setting changes and is not ready for permanent installation. Native calibration, ToF confidence computation, lens limits and motor calls remain original. No fake measured distances or raw laser controls.

- `tofmaster-120336`: native current lens position227→~1767, followed native targets1766–1769; saved preview shows central ColorChecker substantially clearer than `tofsolo-115452`. ProRes RAW305 written /306 seen,1 preprocessing drop,12.83s,867692058 bytes,max write15ms,error0. Exact baseline/photo/Active/no error restored. Clip `/mnt/media_rw/ssd/X2V_RAW/X2V_PRR_20261016_120319`. This clip has not yet been separately decoded or played back.
- `tofmaster-dynamic-120946`: repeat static acquisition1767→~1301, target~1300. 658 written/659 seen,1 preprocessing drop,27.5s,1862719922 bytes,max write17ms,error0. Exact baseline restored. User confirmed movement prompt arrived too late, so this is NOT a dynamic-tracking test. A new harness waits for an explicit local movement cue before timing25s.

Evidence corrections: `afc_ctrl_clear_flag` resets per-frame flags after processing, so post-loop active0 is not proof of inactivity. The new pass-through `afc_ctrl_process` diagnostic reads native state before this clearing. Direct diagnostics bypass interposed `af_get_is_record`, so its printed0 is the original getter, not effective recording state. Native GUI remains RunningCont/None; successful optical acquisition must not be conflated with a completed SuccessCont indicator.

One intermediate crash (`tofweight-114541`) was caused by unsupported AArch64 TLSDESC relocation from `_Thread_local`, not ToF weighting. Replaced with a process-local immutable experimental snapshot; subsequent candidates run. Crash/recovery evidence retained. Current native photo recovery succeeded independently.

Remaining: dynamic near/far tracking; confidence/distance/lighting validity; camera UI AF lifecycle without host find_focus; native focus-result publication; settings/ROI compatibility; PD/CD and face statistics. Do not install permanently or claim these complete based on this initial optical success.

- `tofmaster-dynamic-121240`: cued25s movement window within44.7s total recording (waiting cue also recorded). 1068 written/1071 seen,3 preprocessing drops,error0,max write33ms; baseline restored. ToF distance stayed~2085–2088mm, native target403–404/current405. Saved previews focus the rear monitor while the foreground ColorChecker remains blurred. This does not establish dynamic target tracking. Next isolate native AF ROI/ToF region; user has now selected AF-C+center and disabled person/animal recognition.
- `tofroi-dynamic-121951`: installation aborted before boot selector change; partial library copy reported ENOSPC. Baseline photo was independently Active/no error, no candidate mapped. Removed nine superseded experiment libraries with existing local binaries, plus the incomplete ROI copy, freeing~13MB. No stock library/SSD clip removed. Retained working master and stable baseline.


## 2026-10-16 12:40: ToF point-copy truncation localized and tested

- Native plugin onBuffer at0x9ce8 copies `count << 3` bytes from `self+0x4b18` to outgoing points at`self+0x27f0`. Its dumpDepthMap advances10 bytes per point; native libaaa consumes points with stride10 at0x593f1c/0x593f24. For225 points only180 full records are transferred; trailing45 records are zero/stale. This is matching-firmware disassembly evidence, not a guess from preview appearance.
- `tofpoints` keeps original complete SDK source points, validates the existing1800-byte prefix equals that source, then forwards a bounded9016-byte local copy with all2250 point bytes. It modifies no measured distance, status/confidence, calibration, ROI or motor command. CandidateSHA `ee000d9d7b1c91ecf8b813aa914dbc84f34939d77b483167cbd9925bac08cb4c`.
- `tofpoints-123541`: AF did NOT run. Native error40 is `E_ErrorCode_UsbConnected`; native `find_focus` was explicitly ignored. Confirmed the USB notification through native ack_error40 and independently verified active_error=false before repeating. Do not classify the first trial as a point-copy outcome.
- `tofpoints-123730`: copy prefix matches; header/prefix preserved byte-for-byte. Previously zero tail now includes actual points180/181/185/186/187, depths431–441mm. Machine-readable comparison `copy-length-evidence.json` and original/fixed dumps retained. Native selected distance changes from background~2750mm to~425–434mm, corresponding target~2484–2554. However native classified confidence remains0 and AFC refuses motion (position414): target selection changed but optical AF is NOT complete.
- The last restoration command timed out while remounting /system read-only; fallback restored baseline selector. Independent subsequent check confirmed stock photo/down/saved, live viewActive, active_error=false, /system mountedro, MemAvailable141588kB. This is recorded in `recovery-check.json`; original trial report remains false to preserve original recovery timeout.
- User has been asked for actual target distance to compare with measured~43cm. No more target movement requested until this is known. No recording/test process remains active. Keep-awake remains enabled; no permanent AF installation.

Related ROI result: `tofroi-dynamic-122440` native normalized ROI (0.45170,0.43490,0.09670,0.13039), SDK projection111,83→123,95; center setting did propagate. That trial wrote792/793 frames in33.07s,1 preprocessing drop,max write28ms,error0,restoredtrue, but foreground card remained blurred. `tofroi-dynamic-122104` expired waiting for host cue; do not count as dynamic tracking. Future manual-motion runs use physical recording red border as the cue, avoiding chat scheduling latency.

## 2026-10-16 13:21: near-limit isolation and next trial

- User confirmed the previous target was approximately40–60cm away, consistent with native ToF425–434mm. `toflimits-130928/lens-limits.txt` records native lens MOD2344/INF0; previous selected targets2484–2554 exceeded the MOD endpoint. This can explain rejection, but farther-distance trial is required before calling it the sole cause.
- That limits trial did not establish valid AF: USB notification40 blocked requests and factory later timed out; baseline was restored. Low available memory (~50MB) prompted the requested normal power cycle.
- User now confirms target placed0.8–1m away and rebooted. Earlier fresh boot snapshot592385e4-f453-4762-8af3-1ff018552af2 showed424856kB available. Current13:20 USB/ADB enumeration shows no connected camera, so no new trial was started and keepawake ensure could not rearm.
- `trial_af_limits.py` now dismisses only the established USB-connected notification (ACTION1/CAT5/CODE40) and verifies error cleared before requesting live view/focus. Other active errors abort. Syntax checked; device behavior still pending reconnect. Next trial stays video-idle first to isolate range/confidence/lens movement without encoder allocation.

## 2026-10-16 13:31: in-range ToF accepted; diagnostic crash fixed

- Reconnect succeeded; ADB was stopped after boot, runtime ADB reenabled. Keepawake rearmed.
- `toflimits-132551` crashed in `lens_ctrl_get_lens_model_id+20`: this getter writes through its second argument (`str w8,[x1]`), but the added diagnostic called it as one-argument integer getter. This was our instrumentation bug, not evidence of native ToF rejection. Removed that getter from both source and builder; MOD/INF getters independently disassembled and are one-argument return-value functions. Rebuilt SHA a7f2aef85196424f8e41aa1026f545ca9f4f38def35cdea75db62ea86e18a409. Independent recovery confirmed photo/down/idle, Active, no error, no candidate mapping.
- Harness now aborts rejected/disconnected live-view calls and restores the baseline selector before exit/recovery, so a failing candidate cannot be selected again during recovery. Builder no longer overwrites the corrected trial harness.
- `toflimits-132956`: valid video-idle AF-C trial, ToF approximately978–982mm, native class2 mapped confidence80, lens target~940 within0–2344 travel. Lens position938→940–942 and preview ColorChecker clear. Full baseline/photo/Active/no-error recovery true. No ProRes recording in this isolation trial; no dynamic tracking claim.
- User asked to prepare25-second 0.8–1.2m movement with physical recording red border as cue. Prepared `trial_af_limits_dynamic.py` using the repaired candidate and error/recovery path. Do not start the movement test until user ready.

## 2026-10-16 13:40: RAW + native ToF control concurrent, motion unproven

`toflimits-dynamic-133857` used repaired candidate a7f2aef..., user ready and instructed to move on physical red border. ProRes RAW678 seen /677 written,1 preprocessing drop,28.3s,1896565414 bytes,max write20ms,error0. Native timestamp span28208883us (~24fps). Clip `/mnt/media_rw/ssd/X2V_RAW/X2V_PRR_20261016_133838`. This clip was not independently decoded/playback-tested.

Native ToF class2/confidence80 accepted; lens position940→~1160 and subsequent corrections1150–1179. Sparse logged ToF depths793–810mm throughout the active part. Six preview images retain almost identical ColorChecker position/size; this proves concurrent recording with real lens drive, not0.8–1.2m dynamic tracking. Requested user confirmation of red border visibility and whether movement overlapped capture. Preview montage and structured `focus-summary.json` saved.

Normal stop/finalize and exact baseline restore succeeded; stock photo Active/no active error. No permanent AF change.

## 2026-10-16 14:08: user-triggered recording test armed

User did not see the previous red border (possibly missed it) and requested their own trigger. Installed GUI deliberately ignores full-press to avoid leaking MODE21 still requests; reuse existing on-screen red record button instead. `trial_af_manual_button.py` waits for user recording (300s timeout), then starts native find_focus, launches a device-local25s stop timer, captures focus/preview evidence, and returns to stable photo. Boot selector restored immediately after entering the current experimental session. No permanent GUI/AF update.

First manual setup140618 aborted due to large factory-shell GUI JSON corruption, recovered true. Changed telemetry read to device snapshot +ADBpull. Second140701 armed successfully, fresh video/up/idle, recButton visible at942,470. Current screenshot confirms button visible. Initial screenshot command shotmanual was unsupported and retrieved stale image; corrected to unique numeric shot command and replaced screenshot with fresh live-view UI. Waiting user action; process session99931.

## 2026-10-16 14:25: recording action owns AF, host wait removed

User reported no AF after tapping. Evidence: manual140701 runner expired after300s and restored baseline. Later supervisor uptime3690 entered video,3735 started user clip141524,3755 manual stop; GUI events prove physical on-screen recording tap and19s clip, but baseline had no experimental AF. This was our test lifetime/interaction design error, not another ToF failure.

`build_afc_button_session.py` now creates a boot-scoped session selector and `afc-record-watch.sh`. A marker contains current boot UUID; only on that boot does the session choose repaired toflimits library a7f2aef.... `rec()` launches native find_focus through a device-resident watcher after receiver acknowledges recording; watchdog requests supervisor stop after25s, matched to its clip path. `stop_clip()` stops native focus. No host waiter, no click deadline, and subsequent recordings repeat the same flow. Reboot UUID mismatch selects stable aligned20261015b library. Original300s duration and thermal/storage protection remain; experimental25s stop is additional. GUI unchanged, existing touch record button; physical fullpress remains ignored.

Initial control channel timed out before installation; requesting photo through GUI and restarting camera-test restored factory connectivity. Native photoActive/no unknown error verified before install. `toflimits-button-install-142323` verified recording→native AF→device-local25s stop:622seen/618written,4preprocess drops,25.98s,1809729767B,maxwrite22ms,error0. Native AF half_press1/conf80, lens~1344–1353; not dynamic tracking proof. `afc-control.log` proves native request and AUTO_STOP elapsed25. Screenshot confirms complete red border,REC00:01,andstopbutton. Clip142305 saved. Camera intentionally left video/up/saved with experimental test ready; no host process waiting. User may test at any time during this boot, reenter video if needed.

Rollback: stop active clip normally, exit video, remove `/blackbox/x2v-native-20261011/fps-explore/afc-test.boot` and copy `af-baseline.sh` back over system session through established installer. Reboot alone disables AF candidate by UUID mismatch. Do not call current state restored-to-photo: it is intentionally user-test-ready.
