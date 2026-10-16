# 当前状态（2026-10-16，优先于下方历史记录）

用户已恢复本任务授权。正式持久安装包位于 `releases/x2v-20261016-af-fps`；`installation.json` 记录用户重启后的实际正式25fps运行核验。当前保存重要恢复点并推GitHub，接着处理触摸一次改变对焦点后触屏/五维摇杆无法再移动的问题。30fps可能掉帧，近端间歇性失效尚未根治，不包含临时诊断/对比度扫描实验。相机由codex-preview-debug独占，保活开启。以下为历史记录，暂停/占用状态不应覆盖本段。

---

# USER PAUSED — Cursor接手

用户于2026-10-13明确要求暂停全部Codex/Grok任务并恢复相机。goal已paused；未经用户明确恢复不得继续。Grok PID40056、62465及子进程60204、60212已SIGSTOP，不能自动SIGCONT。native_album已interrupt；其他subagent已完成。

相机source-isolated-021139已原生恢复recovery_rc0；root再次实测原厂camera-service/gui running、liveview Active/transportNone/Still16bit/cropNone、system只读、三处session lock均不存在，TESTING已释放。没有正在运行的x2v/录制controller/guard。恢复证据local-verification/user-pause-restore-20261013.json。用户后来要求保活继续，单独启动原keepawake.sh PID16602、屏幕常亮；这不授权继续录制/测试。Grok-banding等待请求已改.paused，队列清空。Cursor可接手，root到此停止设备命令。

---
# 2026-10-13 01:53 live continuation

User asked specifically whether RAW+lowresproxy simultaneous nowworks; answertruth stillnotproven. Currentgrok1 turn7PID40056 ownsTESTING, launched actual source-isolated-014942 via runner63473(grok_proxy_g2_once.py --execute), verifiedlive02:44 at01:52. No reportyet; do not restart onobservationtimeout. Grok2spatialturn6PID62465 ongoing. PreviousgoalturnPROGRESS matchedDark; currentturnagentstateprogress native persistent62336B actualBionic built bypersistent_boot_sol, waitingnativealbumlease/facade.restored integration; UIbinder81808B focusedhostchecks, nativealbumdevicechild/guard/GUIrelease C work ongoing. Rootnohardware, no completion.

---
# 2026-10-13 01:49 continuation checkpoint

Current goal turn PROGRESS: matched dark actualcapture013949 + independent fourframe dark statistics + continued Grok spatialgain task. Goal remains active/fullscope, no block or complete. Grok2 turn5 actuallycompleted17:46:40Z; stopped idlePID47168, launched visible native turn6PID62465 sameSID0fafbc06-74e3-4a48-beb4-13405907bb52 via Grok 横纹空间增益验证.command/FOLLOWUP_SPATIAL_GAIN_06.md. 4.6 xhigh. Prompt hands actualCodexspatial+darkevidence, requests one-brighttrain/otherheldout fixedgainfield, healthy/detail/darkchecks, actualdiagnosticDNG+same-scalePNG+CPUcost. Must not deploynaturalfitpermanent, askrootifnewphysicalflatneeded. Userstillcapped.

Grok2 v2globalcandidate a=.7186928924,b=1148.981628 improvesglobalfold1510→5.94/757→11.28 but spatialresidualunclosed;darkafter~10.8,newTFcopiesnotclaimedproduction. Paths banding/candidate/estimate-matched-dark-013949,apply-matched-dark-013949,matched-dark-v2-013949-coeffs.json. Rootscientificcounterchecklocal-verification/matched-dark-013949-root-check.json.

Lockcurrentlyavailable, grok-hardware+z-claude-readonly-audit waiting. G1PID40056stillactive, before_vencRELAYcandidate next, lettingread-only audit first. Rootnohardware. Nativealbum+UI+newpersistent_boot agents active. No finalproductinstalled yet.

---
# 2026-10-13 01:46 root — MATCHED DARK captured and independently checked

013949 PASSED, two63frames24.0001/23.9979fps, contiguous,0drop,body0/recovery0/locksabsent. User settings+simrestored. Grok2readfour DNGs clips1/2 frames15/31 into run/dng-sample-readback and released. judge-dark-013949.json confirms same011701 video shutter .009843/.004922,analog2000/ISO100; exactframe metadata match remains0. Root actual4dark ROI means target4056.730223/healthy4056.726928 delta.003295. Bright dark-anchored ratios .71995159/.71915461. local-verification/matched-dark-013949-root-check.json. Appended numbers+calagent handoff to Grok2 ROOT_EXPOSURE_CROSSCHECK_UPDATE.md. User stillcapped; no request to uncap yet.

Nativealbum stillactualdevicebinder/release helper implementation, UIARMfullshutter .so compiled notfrozen yet. New persistent_boot_sol 6.1sol/high owns persistent-video-product-candidate torealBionic runtime gate (oldhcontrollerexit30/pending), coordinatesnative_album; nohardware. Rootnohardwarecommands. Need grok1nextbefore_venc RELAYtest thenactualproxydecode. Wholegoalnotcomplete.

---
# 2026-10-13 01:40 root — user capped, matched dark queued, proxy first packets

Latest human explicitly replied 已盖好. Trusted scene record in Grok banding hardware-exposure/USER_SCENE_CONFIRMED.json. Grok2 turn5 PID47168 has prepared matched-dark packet and started claim-and-run polling (3s) for Tv80/92 Sv36 C24, liveview exposure true. Do not ask again. Grok1 turn7 PID40056 current holder is releasing after source-isolated-013435 restored0/locksabsent; third z-claude-readonly-audit queued after dark. Root has made no device calls.

013435 after_venc ON_DEMAND test: 127 RAW frames 23.99945fps continuous/zero drops. Converter130, venc1/rtp1 dump1, send_calls2/sent2 to127.0.0.1:5000. No sustained encoded stream/MP4, proxy timeout5, whole report false, recovery0. Progress beyond G012317 zero packets, not proxy success. Grok1 continuing own candidates offline after giving camera to dark.

Calibration agent independently found spatial gain variation: healthy tile response 0.9967..1.0029 vs abnormal .6616...7836; corrected target tile bias two-exposure correlation .999773 and slope .499678. Same-class noise gain exactly1/a1.38855; residual includes spatial signal-dependent terms. Need matched dark + real flat before calibration deployment. Nativealbum finaldevice and UI native shutterbinder still active, no installation yet.

---
# 2026-10-13 01:23 root continuation — true30fps and truevideoexposure

Previous goal turn classified PROGRESS, not no-progress: actual Grok trials+firstframehelper. Goal still full RAW+banding+installedproduct, notcomplete. Root thisturn issued no camera commands.

30fps actual: source-isolated-010719 report true/body0/recovery0/locksabsent;80+81frames29.99975/29.99705fps,sourceIDscontinuous,drop0. Fix requires MCU D18/HB25 36M/400/3000+HALfield76=3000+three ownedconf normal_liveview_raw_calib sensor/liveview/liveview_raw DCAM_FPS_3000. Round4 source-isolated-011109 firstclip230frames29.9999fps7.63scontinuous,second blocked47sconstructorbudget;wholefalse,recovery0. Final30fpsSO /system/lib64/libx2v_mode21d18_async30_20261013b.so SHA87381ceec2cdbf45e7c5a34d0e0dc30195ec178561ec3cb1bce56791468019fa,gro k-raw30b-async andgrok-raw30c-session. Warmput30.4/31.1ms at30fps,notall<30ms or sustainedlongrecord. Root compactactual-30fps-first-result.json.

Grok1 turn6 completed17:14:29Z andnormalreleasedlock. RootterminatedidlePID16928 then resumedsameSID turn7PID40056 nativevisible Grok RAW与硬件预览并录.command; FOLLOWUP_RAW_PROXY_07.md grantsactualGproxytest/iterativerepair, givesbandingpriorityfirst. Hehas nowseenbandingrelease andpreparingclaim/executeG. Liveprocessverified; notstalledmerelyexportquiet. Finalgoalnotachieved.

Grok2 turn4PID26161 actuallycaptured source-isolated-011701. Effective manualsim alreadytrue,tethered255,auto=false,liveview_exposure_control=false. OnlySETliveview=true fixedactualvideoexposure:Tv80/92 VIDEO0.009843134→0.004921567ratio0.5;normalRAW9437.965→6746.470,conditionaloldblack3904signalratio.51364;class11fold1510.52→757.06;gainvideoanalog2000/2000,ISO100/100.62+63frames,restore0/locksabsent,settingsrestoredandlockreleased. ActualDNGreadback paths inrun/dng-sample-readback,judge inGrokbanding/hardware-exposure/judge-011701.json. Newestimateda.7270,b1065.79 isdiagnosticonly,no productioncalibration. Olddarkunmatched. Root askeduser via request_user_input_async to caplens, replyPENDING; do NOTcaptureclaimedmatched darkwithoutreply. Otherproxyworkcontinues.

Codexcalagent crossauditfinishedQt/GOTmanual5c3vsindependentliveview489, actualconnectionproven. VIDEO_EXPOSURE_HANDOFF.md updated; root ROOT_EXPOSURE_CROSSCHECK_UPDATE.md preparedinGrok2dir butnotclaimdelivered. Root reactivated calagent(max) solelyindependent011701analysis/diagnosticoutputs, nohardware. Needmatched darkTv80/92 Sv36 liveviewtrueafteruserconfirms.

CodecGactualcandidatefrozen,readHANDOFF.md at receiver_v23g_native_rtp. ARM0376e680…5f7f74f/423200B;source_proxy_v23g_stage.py thenrun_proxy_v23g_once.py onlyholder.1clip4s+closeunusedsecond,original47sbudget,5spackettimeout;newnativeenabled/converter/sendmmsg destinationdiagnostics. No C++patch, serial24writer preservedjustforproxyisolation. Codecagentended. G passed toGrok1already, awaitingactualtrial.

Nativealbumfroze raw-proxy-product-controller-candidate freezeSHAc55940b6…12b114. RX25async+Fproxy+controlprogressSOa669b2c2…87b2e6b472720B;nativehelperb6d561f1…ce61565088B. Integratedrootfirst-frameproof,6focusedrealdecoderchecks/13controller/2Cintegration. No device. Rootfollowupnativealbum ownsnewraw-proxy-product-device-candidate torealmergeGUIcoexist+guard/playerrelease+facadeunifiedintentseq, notjustHOLDdocuments. UIagentfollowupnowowns shutter-full-native-binder-candidate(actualcoldhookconstructor/full/destructor,halfuntouched), coordinatedFULL1/MODE1/ACK1 pipeswithnativealbum;nohardware. Both6.1sol/high. Calmaxthirdslot.

Rootadded local-verification/source_proxy_first_frame_stage.py (defaultofflineverified) requires X2V_TESTING_OWNER exactlockowner for --execute, reusesssd_stage. Notdeviceinstalled. Nativealbuminformed.

---
# 2026-10-13 01:06 latest second Grok 30fps trial

Grok round2 source-isolated-010305 actual report passed lifecycle body0/recovery0/locksabsent. HALfield76=3000 alone did NOT fix cadence:63/64frames delivered24.1604/24.2293fps,sourceIDsnotcontiguous,receiverdrops0,short_trial_30fps_delivery_pass=false,putmedian27.6594/28.1902ms. Grok1 stillownsTESTING; root nohardwarecommands. Continue nativefpslimit diagnosis; do notreport30fpssuccess. Grok2 turn4 exposurepacket remainsrunning. Nativealbum integrating root first-frameproof helper; calagent finishing liveviewtogglecrossaudit; codecG packet inprogress. Goalactive/notcomplete.

---
# 2026-10-13 01:02 root update — Grok autonomous hardware and first 30fps result

Latest user again grants Grok real hardware debugging and bold reversible fixes. Current TESTING owner remains grok-hardware; root has issued ZERO camera commands this turn. Grok1 SIDc68df938-5443-4184-bdae-ac675fe82278 PID16928/turn6 built/staged own MODE21 D18/HB25 36M/400/3000 candidate and actually ran source-isolated-005642. report passed only lifecycle: body0/recovery0/locksabsent. Actual 64/62frames delivered23.9237/24.0772fps, sourceIDs NOT contiguous, receiverdrops0; admission median33.37/33.57ms max67ms, put27.77/28.45ms. short_trial_30fps_delivery_pass=false. Do NOT claim30fps achieved. Grok remains active analyzing ID gaps vs native stamps/put tails. Codec says source timestamp delta needed to distinguish upstream missing delivery vs ID semantics; do not simply add overlapping copy10ms+put27ms.

Grok2 turn3 actually completed16:49:54Z. Root gracefullyterminated only idlePID17940 and resumed sameSID via visible native launcher Grok 横纹实机曝光验证.command, nowturn4PID26161. FOLLOWUP_HARDWARE_EXPOSURE_04.md sends Codex VIDEO_EXPOSURE_HANDOFF.md, instructs actual independent exposure packet/native original attributes, no per-step approvals, claim grok-banding onlyafterGrok1release. Earlierturn3 produced estimator/revisedcausalreport/video-exposure-contract. Candidate still no permanentcalibration. Root didn'teditGroklogs/db or useUIbypass.

Codexcalagent owns native-frame-metadata-audit/video-exposure-native-control-audit/VIDEO_EXPOSURE_HANDOFF.md. Manualbool!=Mmode, updateExpoSim tag5c3 vs liveview_exposure_control tag489; crossauditongoing. Need matched actualVIDEOshutter+RAWresponse beforevalidmulti-exposurecalibration.

Root completed independent native-video/experimental/raw-proxy-first-frame-proof-candidate. Reuses existing thumbnail first_frame decodecore, emits bound v1 SOURCE_ID NONCE dev ino size width height duration90k decoded receipt after actual firstframe (notwholeclipdecode). ARM staticmusl 3303616B SHA96ffb5be5a297a61ccc4e3e0b6d037582739451ada5ba52765c6593d2041d184, candidatepath /system/bin/x2v_proxy_first_frame_20261013a. Six realhostcasespassed inclrealcameraMP4+ffprobegeometry/duration, existingproofpreserved, corrupt/truncated/wrongcodec, malformedbinding. NOTdeviceinstalled/tested. nativealbum owns controller and willintegrate thishelper before product_proxy_saved. No root editsagentcontroller. Nativealbum actualproductreceiver nowRX25async+Fproxy merged a669b2c2…b2e6b; ARMnativehelper6e654c02…88957; stillHOLD GUI/shutter/display/persistence. codec implementing newG0packetdiagnostic +singleclip, nohardwarewhileGrokowns.

---
# 2026-10-13 00:45 USER AUTHORITY CHANGE / HARDWARE HANDOFF

Goal updated by user to full RAW pipeline + fix banding + collaborate with Grok until actual installation/report. NOT COMPLETE. User explicitly grants Grok direct hardware debugging, autonomous fixes/build/stage/record/recover, wants30fps and accepts first/stop-framepeak. User asks RX25async27ms incorporated in nextproduct. Root is NO LONGER solecameraoperator. Root must NOT issue anycamera/ADB/factory/stage commands while Grok ownslock.

Created local-verification/camera_testing.py and root TESTING.md. Atomic local directorycamera-testing.lock owner.json; no automaticexpiry. Claim/update/release(status command). Release requires actualreport recovery_rc0,locks_absent true. Currentowner=grok-hardware (root preclaimed00:37:31), 30fps thenbanding coordinated. Root restored F priorhandoff source-isolated-003337 recovery0/locksabsent. AllCodexagents instructed offlineonly. BothGrok sessions nativevisible atGrok4.6/xhigh, permission-modebypassPermissions+alwaysapprove (userexplicitgrant); no globalconfig edits.

Grok1 sameSIDc68df938-5443-4184-bdae-ac675fe82278 turn6PID16928, currentnativeprocessconfirmedlive tool.exec_done successful. Prompt HARDWARE_30FPS_AUTHORIZATION.md, launcher Grok 30fps 实机调试.command /run_hardware_30fps.py. Ownhardware-30fps/,experimental/grok-raw30*,local-verification/grok_raw30*. Actual30fps mustchangeactualsupportedsource notretimestamp24; limits short240 initially. No boot/firmwarepartition/unknownregisterflash; ownstagingallowed, recoverpath retained. Userdoesnotrequireevery-stepapproval. ReadPROGRESS/ROOT_HANDOFF, do not duplicateitscameraops.

Grok2 sameSID0fafbc06-74e3-4a48-beb4-13405907bb52 turn3PID17940, nativevisibletoolsactuallyworking. Prompt FOLLOWUP_REAL_EXPOSURE_03.md, launcherGrok 横纹实机协作.command. Currentofflinebanding+videoexposurechain, mayclaim grok-banding onlyafterGrok1normalrelease. It received235857nonphysicalhalfexposureevidence, correctioncausalreview, permissiontoself-debugafterclaim. PriorPID80888 andwritePID9336 explicitlycancelledbecauseoldreview/replaytask superseded; terminalconfirmedbeforestart, noJSONL/dbedits/noCUAbypass. EarlierasyncquestionaboutstuckGrokterminal isobsolete.

Fproxy source-isolated-003337 failed secondclipbudget, butactualnamedSTARTcalled1completed1rc0/RTPenabled, recorder0packetsfirst5032msstartup_timeout, namedSTOP0/recovery0. Noactualproxyproof. NativeABI fixesworked. Codec reactivatedoffline newG diagnostic path(graph color/shadowactivation,record40B output2,handshakeUDP), oneclip4s+closeunused2 proposed ratherthanbudgetpadding. Actualtest onlyafterGrokrelease. FirstRAWcaptured butwholetrialfalse.

UIagentfinished raw-proxy-product-gui-coexist-candidate (README/review-manifest ffc639a1…ca9114),378ownedGUI/QML files, failclosedARMloader e586cc2d…c8cc6c/12208B,38 focused+3identitychecks. StillHOLD actualdisplaygraph/Off-presentation/full-keybinder notimplementedverified. Nativealbumworking realinteractivecontroller+nativeFDlauncher, instructedfinalproductmustmergeRX25writer. Calagentworking offlinevideoexposurecontrols, writesVIDEO_EXPOSURE_HANDOFF; nohardware.

---
# 2026-10-13 00:30 root actual writer result

User asked actual Grok optimized RAW recording, not replay. COMPLETED actual RX25 camera trial source-isolated-002209: report passed/body0/recovery0/locksabsent. Two clips64+63=127frames,23.99793/23.99914fps,zero receiver drops,sourceIDs contiguous. putmedian27.110547/27.036459ms vs prior23585732.368229/32.677344ms (16–17% improvement). Whole-frame completionmedian32.2962/32.5344ms; warmputp95 32.3133/32.5833, warmmax40.9883/35.0898, first48.6159/49.2036. finish11.1914/10.1911ms; stop-to-writerdone50.0938/29.3193ms. Allsubmitted/copied/written/published counts equal, fsync retained. No sustained30fps claim. Report WRITE_PERFORMANCE.md and raw metrics report.json in run. Two midpointDNGs readback succeeded; Dependencies installed; two midpoint actual DNGs independently decoded via tifffile, shape2946x3920,uint16,low4zero; decode-report.json saved.

RX25 source native-video/experimental/rx25_async_writer frozen bycodec. Library fe3f5949…2811e2,358376B,device/system/lib64/libx2v_mode21c24_async_20261013a.so/token GROUP13_MODE21C24_DNG_ASYNC_WRITER_V25. Validator457052e4…9d5e6e8b,56568B unique /system/bin/x2v_rx25_async_receipt_validate_20261013a. Bothstagepassed. New consumedpacket source-session-isolated-two-v25-async. Root added ack_contract_v25_async.py (strips exactly newfields only to reuse baselineexactkeyoracle thenchecksasync),dng_async_metrics.py,prepare_async_v25_packet.py,run_async_v25_once.py,derivedrunnerandstage. Newmanifest16fields(not17), end4fieldsincluding submitted. Synthetic adaptedsuccessfulbaseline fixtures validatedawk/metrics and unsyncednegative beforecamera. Do not rerunconsumedpacket.

Grok priorPID89113 was explicitlycancelled withSIGTERM becauseuser supersededreplayprep withactualrecording, psconfirmedterminated. SameSID resumednativevisible turn5 PID9336, model4.6/xhigh, read_file-only thisreviewturn; reads ACTUAL_CAMERA_RESULTS_20261013.md andrealrunreport, noexec/write/device. Actual log16:27:41Z inference_start, soaliveprocessingnotstale. LauncherGrok 实机写入结果复盘.command,script run_actual_feedback.py. Earlierquestionaboutstucktool nowobsolete. No UIbypass, noeditingGroksessiondb/jsonl.

Eproxy trialsource-isolated-000611 failed named_wait native_rc46 but RTPbind/enable succeeded, poison0, contextdelta0x2310; entered1 called0 completed1 unknown0, STOPcalled1/completed1/rc0, noencodedpackets. Restored. Codec nowreactivated tofix46 in independentF. UIagent reactivated offlineGUIcoexist(ownedQMLtree376files), nohardware. nativealbum facadefreeze complete in priorcheckpoint. Calibration235857 actualRAW signalratio.982 despite stillshutter.5 => notvalidphysicalhalfexposurepair, responseanalysisreportsready, agentidle. Root solecameraoperator.

---
# 2026-10-13 00:04 root checkpoint

Latest user asks writer optimization status. Replied: revised Grok async fsync candidate host checks pass, actual prior median32.3–32.5ms/max52.9ms; target~28ms only estimate, no hardware<30ms yet. Grok1 native PID89113/SID c68df938-5443-4184-bdae-ac675fe82278 turn4 is stuck at tool_running since15:55:20Z with no child process/no target-replay directory. Export /tmp/x2v-grok-write-progress.md shows last pending Execute checking Python imports/Bionic symbols. Async question pending whether terminal shows confirmation. Do not claim it is compiling. No termination yet. CUA Terminal denied earlier; do not bypass.

V23d trial source-isolated-235600 failed begin116 stage rtp_bind, diagnostic observed1/poisoned1/reason4/setter_rc-1746948096/context_delta0; zero encoder submit. Recovery0/restored/locksabsent. Codec located actual UINT64 setter void-style ABI; E fixes declaration only, preserves owner gates. E staged successfully source-proxy-v23e-stage-000209/report.json, SHA70b53dd213da3b86b381352082fcc6f706ee91bb473c3628c6105db2fe1042a5 /406008B, unique /system/lib64/libx2v_mode21c24_native_rtp_20261012e.so. E packet frozen, NOT RUN. Next run local-verification/run_proxy_v23e_once.py --execute, sole root hardware. Review diff completed.

V24c controlled exposure source-isolated-235857 PASSED actual two RAW captures/body0/recovery0. Two midpoints readback succeeded dng-sample-readback. First readback overlapped root E stage lock, failed before copy; retained dng-sample-readback-stage-overlap-failed. No camera ownership interference from UI agent. Calibration agent reactivated for offline actual exposure response/fold only, exactmatch still0. Current camera restored, no active native capture. Stage/readback sessions completed.

Grok1 target replay still pending; candidate paths and semantic contract in research/full-fov-pipeline/grok-write-latency-20261012/ROOT_HANDOFF.md. Do not use async put time alone as completion; include finalfinish and published count. Keep user model4.6/xhigh and visible terminal.

---
## 2026-10-12 23:31 — V24 no-capture failure recovered; RX23c next
- Exposure V24 staged receiver231719/validator231631 PASS, then source-isolated-231811 failed before any exposure property dispatch or RAW arm. Android mksh here-doc read<<EOF tried unavailable temporarydir, ee_pid unset; newexposure.dirty existed though no actualSET. NativeRAW CPUreceipts stopped, role0/role1/wholeteardown allRC0, graph255; samehere-doc in restore blocked default recovery.
- Root recovery used unchanged owned controller with TMPDIR=$PWD from exact run directory via native factory only after quiesced known state: `TMPDIR=$PWD toybox nohup sh controller.sh --recover source-isolated-231811`. Completed stockrecovery, frame506→564, A1/AutoISO32766 unchanged. Evidence outputs/source-isolated-231811/recovery-followup/report.json. Original report remainsFAIL at host200s deadline; do not overwrite into capturepass. NoRAW/newmetadata, no userrestart required.
- Calibration supplied separate V24b source-session-isolated-two-v24b-exposure + run_exposure_v24b_once.py, only replaces2here-docs with initialized directread of active-service.identity+exactowner comparison; same staged binaries, no restage. Not executed. Prioritize RX23c now peruser.
- RX23c integrated401520B ARM built and7actualC protocol casesPASS. Codec ownsfinal pathfix (stage initiallywrong named_hw_proxyname) and failurecleanup of CPU-onlyrecorder. Proxy nativeRTPenable+afterenable secondloopbackhandshake; first4sRAWproxy, second2sRAW;30srecorderceiling,3sSTOPfinalization cap. Agentpreparingfinalhandoff. Rootreviewedcontrol/markerprotocol andchecked .state.jsonsuffix. No source test currentlyactive.
- Grok1 revision stilllive as62496 (samewriteSID); Grok2 independentbanding59608 delivered preliminaryREPORT/ROOT_HANDOFF. Newdarkanchoredfit a0.7423704352 b1005.785821 on1/12, heldout221635fold~25; stilluncalibrated/no newexposure. Do not deploysinglefit.

## 2026-10-12 23:12 — Concurrent RAW/proxy product installation authorized; two visible Grok lanes
- User latest: prioritize RAW+low-resolution concurrent capture; when working make/install product build directly for testing. Open separate Grok banding window and work jointly. No further UI approval required (layout already approved); preserve stock recovery, do not claim experiment is finished firmware.
- Grok write session c68df938-5443-4184-bdae-ac675fe82278 turn2 completed15:04:51Z and delivered candidate/ROOT_HANDOFF.md. Root found plain shared error/close_error data races, published falsely means queued, join-failure lifetime bug, timestamp-semantic issue, invalid new-capture SHA comparison. FOLLOWUP_03.md sent via supported native same-session resume, Grok4.6/xhigh, original idle PID52018 terminated only after turn.complete; currentPID in session.json. DO NOT integrate first candidate. Native Terminal revision visible. No session storage manipulation.
- New independent Grok banding session0fafbc06-74e3-4a48-beb4-13405907bb52 PID59608, Grok4.6/xhigh, research/full-fov-pipeline/grok-banding-independent-20261012. Native Terminal opened, actual inference/tool logs + banding/PROGRESS.md confirm execution. Root solecameraoperator; both Groks only own taskdir.
- Current camera liveverified same boot41867eda-01a6-4809-b1d0-ebedba61dce4, stock service/gui running, keepawake20740 exists. Recorder /system/bin/x2v_recorder_20261011b SHA5d3090ef464ec4b5f1b23d241e6d0e0d4355c465a83f303388dc411e10bc2bd3 verified, UDP5000 unbound/5001 native. No active source capture. ADB /procstat/meminfo denied; use ownedcontroller for resource samples.
- RX23b source-isolated-223818 PASS RAW/recovery, no native proxy START due callback observer ENOTSUP95. Native startup binding fix works; new direction native public rtp_enable/is_enabled via captured service UINT64 context, no C++ vtable patch. Frozen helper raw-hardware-rtp-paired-candidate reviewed, exact base_v_lz UINT64 ABI. codec_pipeline_sol owns new receiver_v23c_native_rtp + build script/new controller packet. Protocol uses FD3 owned proxy ready/stop-request/finalized markers; root approved. First capture4s (recorder SPS/IDR gate), secondRAW2s; actualStop0 before stopmarker, RTP stays enabled until sink finalized; UNKNOWN hold. Agent will build/test offline only.
- Root resource_snapshot.sh + analyze.py in native-video/experimental/raw-proxy-resource-snapshot; two short read-only native/recorder CPU/memory/disk snapshots at actual concurrent window. Agent told to embed; failure nonblocking. No sustained-headroom claim from4s.
- raw_calibration_sol owns independentV24 fixedSv36 Tv80/92 Manual exposure package. New70sreceiver/validator and40/54arm deadlines only for exposure property overhead, earlyexit when complete; originalE untouched. Not yet staged/run. Existingdark/wall data unchanged; no calibratedRAW production.
- native_album_sol now implementing real executable product facade/HTTP+K shutter integration independently, not more model-only layers. Current K RAWpending/backend notinstalled. Must bridgeactual controller interactive arm/stop + realterminal/proxyfinal, preserve GUI/service transition recovery. No deviceoperation byagents.

## 2026-10-12 22:34 — User-authorized Grok CLI write optimization in visible Terminal
- User explicitly requests delegate <30ms RAW write optimization to Grok CLI, Grok4.6 maximum effort, and visible Terminal conversation. Login was expired (refresh invalid_grant); user completed OAuth. Actual CLI1.0.13 now running PID42018, wrapper41936, model grok-4.6 effort xhigh (highest cache entry). Session c68df938-5443-4184-bdae-ac675fe82278. Do not relaunch new-session wrapper with same ID.
- Isolated task/workdir research/full-fov-pipeline/grok-write-latency-20261012. TASK.md full prompt; session.json running; conversation.log stdout (plain may defer); conversation-snapshot.md and live-conversation.md prove actual assistant/tool work. Actual first findings: write wall32ms vs CPU8ms, SSD oldmeasurement761MB/s. No optimization delivered/verified yet.
- Native Terminal opened via open -a Terminal. run_visible.py controls login and Grok process; watch_conversation.py PID43407 exports same session every5s to display actual conversation live in secondTerminal. User confirmed login. CUA Terminal inspect was denied; no UI read attempted afterward. Processes and exports verify running task, not screenshot proof.
- Grok only reads main project/writes own candidate directory; forbidden camera/ADB/factory/sharededits. Root remains camera soleoperator and owns actual perfvalidation. Followup use --resume sameUUID, --effort xhigh -m grok-4.6 --prompt-file newfile after currentturn finishes, then visible launcher/reader. No user permission needed again.
- Codec preparing rx23-bind-fix-candidate (newsource, not frozenyet at this note): first get_cam_dump_controller_ops returnsNULL, likely uint8forward/loader issue; 6named APIs replace directextern with checkedfunctionpointers to restorebaseline3DTNEEDED, LOCALresolveranchor/actualmappedbinding-first, factoryreject preservesoriginalp. ROOT has NOT integrated/rebuilt/stagedB. prepare_proxy_v23b_packet.py prepared but NOT RUN; expects receiver_v23b_named_hw_proxy/build receipt.
- Calibration E read124frames success; all9presentfields bitconstant, so exactappliedexposure stillunknown. Offline agent traces tv_selected setter→Tv/12→seconds and commits both3ea/3eb, waiting its final mode/restore instructions. No exposure changes made.
- Camera stock restored from221635; no source test active. RAW full goal remainsactive. Next: receivefrozenbindingdelta→rootBbuild/test/stage→singleboundedproxytrial; readGrok candidate whenavailable; controlledexposure onlywithproperrequest/readback/restore.

## 2026-10-12 22:19 — E metadata plus wall RAW success
- V20e source-isolated-221635 actual62/62 RAW DNG,23.999398/24.004616fps,zero receiverdrops; body0/recovery0/locksabsent/native stock restored. Root75136 terminal0; selectedDNGreadback87280 terminal0. No active source test. E stage221556 passed/defaultOFF/systemro.
- All124 metadata records stateREAD,permission3,writer0. 9fields copied: video shutter0.0100000007,ISO120; still shutter0.0119441161,ISO100; analog both2000,sensor digital both1000,stillISPdigital4096. Black/depth/shutterMode/sensorModeprefix absent. Exact physical exposure match NOT proven, history fallback possible. Native decode now works; next controlled exposure variation needed to establish validity/response.
- Source DNGs preserved. Midpointfiles under221635/dng-sample-readback; rawpixel foldoddodd1188.75/1191.48U16. No correction applied. Write median32.28/32.54ms,max52.90; <30ms target still unmet.
- Calibration agent offline analyzing allmetadata/next native exposure API. Codec offline finding RX23 prearm failure: firstopsassert is get_cam_dump_controller_ops(NULL), no evidence RTPfactoryreject causedit. New component isolation candidate pending; no repeatunchangedV23.

## 2026-10-12 22:13 — RX23 hardware proxy pre-arm failure, automatic stock recovery PASS
- RX23 ARM dc6626309a7c6cab4502fc81e930ff82c8e58f59e970c3af10680cebfa9eb490 staged default-off at /system/lib64/libx2v_mode21c24_named_proxy_20261012a.so; stage220945 passed/systemro. Actual6 C ASAN/UBSAN proxycontrol scenarios cover unknown/noack, unmap error/noack, rejected-before-submit/noempty47s poll, sink error/release.
- Consumed V23 source-isolated-221042, root16171 exit1: native service exited1 BEFORE explicit arm/no RAW/proxy. body5/recovery0, locksabsent, stockActive/None and frame405→467, originalservice11971/gui12868 running, systemro. Exact native-cam.log downloaded; 22:10:48 PID10400 assertion ops base4431/shadow1878/async6523. No beginX2V_PROXY. Codec agent offline investigating factoryobserver/LZ mismatch; do not repeat unchanged packet.
- Hold released_modes empty after finally. No camera source test active. Root remains sole operator. E metadata candidate ARM c0f5e72...1c7ecdb ready from calibration agent; new V20e packet/stage being prepared independently, then root will capture without encoder.
- Existing wall214208125frames and dark212801127frames remain success. Calibration anchored offline fit improves wallfold1313→25U16 but not production calibration/no sourceDNG overwritten; exposure contract not yet available.

## 2026-10-12 21:45 — User flat wall confirmed, RAW capture and late binder PASS
- User replied 已对好 (cap removed, pale wall, unchanged settings). Root executed V20d once, not unused V22 packet. source-isolated-214208 actual63/62frames,23.999773/23.998913fps,zero receiverdrops,body0/recovery0/locksabsent/native stock restored. Root66208 exit0/readback42293 exit0. No active camera operation now.
- V20d only moves getter binding to first A after native graph startup, best effort; frameID/stamp retained on missing binding. Exact libdcam_base+entry64 pinned successfully. Actual XMD1 all125states not_read_only; permission3 (capability read+write), so current extra guard skipped values. Do not claim native exposure/ISO now available. Late loader root cause recovered linker LZ builtin table; agent loader-binding-audit documents.
- Actual flat DNGs in214208/dng-sample-readback, flat-pixel-analysis.json: class11/odd-odd fold1313.121/1309.673U16 vs dark .462/1.161. Otherphases2.1/7/17.9. Meanclass7616 vsreference8928;dark3904. No correction applied/no controlled ISO fact. Calibration agent reached model capacity after proving permission3 satisfiesnativeREAD but getterreturnsborrowedvalue after releasingreader count; concurrentwriter contract stillneedsclose. No relaxedguarddeployment.
- V20d ARM61206731...76edc installed defaultoff /system/lib64/libx2v_mode21c24_metadata_20261012d.so, stage214053PASS. Stop/residentRAWunchanged,3focusedASAN skip-ID guards. Allone-shotreleasesrevoked. Unused V22flat remainsOFF; don'trunredundantly.
- Root created receiver_v23_named_hw_proxy OFF/unbuilt integration: originalRX18clone,graphdlsym AVC factoryobserver,proxy_control begin/tick/end+control hooks. Needs codec finalized late binding source, targetbuild, focusedcontroltest, newcontroller SP/probe inventory/retirable marker beforeteardown. Do notdeploy currentdraft.
- Nativealbum delivered raw-proxy-probe-sink12actualCchecks,offlinenative-freestanding sink childpreview-probe_nonce5x1MiB, data-owned only; source frozen. Codec configuredpair still writinglate providerintegrationBinding. Rootsoledeviceoperator.

## 2026-10-12 21:30 — Actual capped-lens RAW captured, important dark evidence
- User confirmed cap on, then explicitly demanded capture first/no excessive checks. Root switched back to unchanged proven RX18 instead of blocking on experimental metadata binding.
- source-isolated-212801 (new consumed source-session-isolated-two-v21-dark) PASS: 64/63frames,23.999621/23.998928fps,continuoussourceIDs,0receiverdrops. write median32.062/32.271ms,max52.565/53.328; <30ms target NOT met. Native body0,recovery0,locksabsent,stockActive restored. Root exec95902 completed0; sample readback22098 completed0. No current capture active.
- Two actual midpoint DNGs downloaded into run/dng-sample-readback,3920x2946; original SSD sequences remain separate dng/dng2 directories. dark-pixel-analysis.json shows allphase fold3 <1.2U16; anomalous odd/odd phase p2p0.462/1.161 vs previous lit frames hundreds; black median3904U16,low4bits0. No calibration applied; exposure not controlled/native frame exposure unavailable; argues against a large fixed offset under THIS condition, does not prove gain/PDAF/source cause.
- Independent calibration agent reproduced dark stats to <1e-12; old wall affine .816636/576.985 would CREATE169–170U16 periodic difference on these darks. Do NOT deploy it. flat packet source-session-isolated-two-v22-flat prepared OFF/HOLD, no execution; run_flat_v22_once.py only after actual user scene reply.
- Asked user via async to remove cap and point at evenly illuminated pale wall, prefer window daylight, no parameter changes; reply PENDING. Do not call later arbitrary scene controlled flat. Continue independent encoder work meanwhile.
- Metadata A/B/C three pre-arm failures: source-isolated-210722/211442/212604 all zero RAW and recovery0. B RTLD_NOLOAD absent; C dl_iterate_phdr matched0. C uses existing ABI+pin and12actualASAN/UBSAN binding cases; ARMbcf8cfa...fab263 installed defaultOFF/systemro at ...metadata_20261012c.so (stage212508PASS). Do not rerun consumed metadata packets. Calibration agent resumed6.1-sol/max, offline diagnosis plus new dark review; root owns device.
- Codec agent offline: service initRecording role5 makes40B record at private+2710; bypass requires correctcmd143b reply from ownedrecord, bitrate getter expects TSFresource private+30 NOT engine. Native dispatcher partial errors can exit/abort internally before return, so named wrapper is NOT universally nonfatal. Candidate remainsOFF until config/normalstop and recovery boundaries reviewed. No actual RAW+H264 proxy/headroom proof yet.

## 2026-10-12 21:00 — Grok evidence reviewed; metadata capture candidate preparing
- User supplied full405line Grok checklist, read all and crosschecked. New GROK_REVIEW_20261012.md under raw-banding-calibration-investigation records corrections: odd/odd is diagnostic sublattice notproof2x2 sensor skip;4048..4080 are values notcolumns; dark-subtraction residual notuniqueFPNproof; native metadata historyfallback means exact=false; factoryHBnull distinct customHB24.
- Root added decode_raw_native_metadata.py (XMD1 LE528B, RAWframeID/stamp/index/clipbinding, type/count/skips, finite floats) validated against actual agent C lifecycle outputs7manifests/15frames. Rejects wrongID and fakeexact-match. Report raw-native-metadata-decoder-host-check.json. No camera data decoded yet.
- Root added prepare_metadata_v20_packet.py (NOT RUN yet): RX18 successful RAW+ISP graph/stop unchanged; newmetadataELF path, addedbase.so identity,12fieldmanifestgate, saved smallmetadata manifests, hostfullbindingvalidation, newboot41867eda/group3102. Wait foragent finalARM64receipt beforeprepare/stage. HOLD, no capture launched.
- Asked user to coverlens for realdark sample; replypending. Do not call an arbitraryscene dark or launch dependentdark capture withoutreply. Independentofflinework continues.
- Codec pairednamed_session actualC8checks+defaultOFFobject delivered; rootreviewed. Followupnarrowaudit running: partialstart error cleanup and initRecording configuration before bypassingroleallowlist. Nohardwareproxytestuntilreviewedready.

## 2026-10-12 20:46 — User reboot completed, stock recovery verified
- User confirmed normal reboot/reconnected. Fresh boot41867eda-01a6-4809-b1d0-ebedba61dce4 vs old80026cc1 proves old owners retired. Stockservice375/GUI382 running. set_live_view true succeeded; freshcount31→42, later keeper/setup refresh count19→growing. See authoritative outputs/source-isolated-202840/post-user-reboot.json for finalreply. Physicalbuttons not separatelyconfirmed. Automatic V19b recovery remainsFAILED; this is user reboot recovery.
- Reenabled temporaryADB through reviewed camera_access.py enable-adb. Factoryfirmwarev1.3.16.2/originalservice verified. Exact oldowner source-isolated-20284081513135948 lock renamed /data/x2v-source-20261012/stale202840.lock afterbootproof, preserved. No newrun launched.
- Keeper3216 running,hostworker24361 preserved,lease refreshed,wakelock acquired,timeout0. Existingkeepawake-state.json updatedcameraPID. Sourceexecution released_modes empty.
- Continue offline codec paired namedstream interface and calibration metadata candidate; doNOTreuseV19b publicrole5 command. RAW+encodedproxy/headroom stillunverified. UIKnotinstalled.

## 2026-10-12 20:39 — PRIORITY: V19b recovery unresolved, user reboot requested

- Root session11267 finished failure; no active host test. V19b run `native-video/outputs/source-isolated-202840`: role5 start rc1, body70, recovery1 twice, no restored marker, session lock retained. Do NOT rerun consumed packet or clear locks without reconciliation. One-shot released_modes verified below.
- Actual log: doStartStream line2640 current group does not have stream; rlt -1015 then fatal startStream and SIGABRT source PID8541. Native VENC filters were created, but actual encoding not started. SP addition alone does not change service group13 role map. Codec agent auditing this exact precondition; no blind retry.
- Stock init camera-service12227 running but StateErrorIdle/DCAMCallFailed/Critical, Off/None/groupMax255, camera-test12638. Experimental owner/controller/guard absent in factory ps. Root started stock camera-gui using ctl.start only after stopped+no PID; returned running. Stock liveview NOT restored. Original system remains ro; no boot/firmware flash.
- Requested USER NORMAL POWER OFF/ON via async question; reply pending. Resume hardware only after user reboot and fresh stock state proof. Do not infer physical UI acceptance. Keeper16177 was restarted by host finally before reboot request.
- Exact local native logs: native-encoder-failure.txt, stock-recovery-error.txt, recovery-processes.txt, gui-recovery-start.txt under output run. Last RX18 success200007 remains valid RAW+ISP metadata concurrency, NOT hardware H264 proxy or measured headroom.
- Codec exact blocker: doStartStream 0x287938 -> currentStreamGroupHasStream 0x27abe0, false branch0x287c1c returns -1015. initStreamGroupStreams only roles0/1 forgroup12/13 (mask0x3000); role5unsupported. Requested paired same-owner engine named-stream start/stop candidate with nonfatal error propagation, NO private QList poke or publicstart5 retry. Evidence service-group-role-table.txt. Agent codec running native group-role fix offline; calibration running metadata callback integration in independent candidate; mux adapter complete offline (13checks,100 historical H264frames decoded unchanged) clock/AU/source match still open. All agents forbidden camera access.
- UI K actual interactive settings/icon/page completed,15Qt checks, device/backend readiness false; screenshots evidence/03-settings-raw-pending-camera.png. Jlayout approved already. No install this turn.

## Latest 2026-10-12T20:03+08:00: user priority corrected; RAW+ISP live PASS, hardware H264 next

- User explicitly prioritizes RAW+hardware proxy simultaneous capture/headroom and banding fix. UI real spec choices also requested. Do NOT spend next turn on RX17 telemetry/broker work. Root sole camera operator; agents offline only.
- Actual new source run `native-video/outputs/source-isolated-200007`: RX18 two2s RAW+ISP same graph PASS. RAW62/63 frames,23.998844/24.000697fps, contiguous IDs,0 drops;write median32.886/32.805ms(max53.130/53.794),stop→writer23.654/39.506ms. Color callbacks cumulative161→388, first descriptor pixel2/1300x970/stride1536/ph970/planes2. Descriptor is source-lifetime first, not perclip image/clock proof. No pixel mapping/copy forcolor. New report `research/full-fov-pipeline/RX18_RAW_ISP_CONCURRENCY_20261012.md`, JSON `outputs/source-isolated-200007/raw-isp-concurrency.json`.
- Native role0→role1→whole each actual delayed return then state13 forindividual/Max forwhole; markerfiles confirmed. body0/recovery0/restored/locksabsent. Latest stockservice30022/gui30967/factory29815;Active/None/Still16bit/CropNone,systemro. ADBserial123456789ABCDEF transport12; boot/cgroup unchanged. Keeper remained present (no recreation inreport). NO current source/execsession remains. One-shotrelease revoked released_modes[]. ConsumedRX18packet mustnotrerun.
- Root RX18 `source-receiver-adapter/receiver_v18_dng_isp_proxy`: RX16 clone, sameDNG backend/ACK16/47s/10s240caps; ownSUBgeometry5u32; color_observer staticatomicfirst8u32+count only, nativeoriginalonce, workerlogs afterRAWdrain. UniqueELF ea4b9b7ac93be2dd6872b2efd1a919450cf6e0a33b6edf07ae970d44efcb2a8c installedreadonly `/system/lib64/libx2v_mode21c24_dng_isp_20261012a.so`; stage195849PASS. actualintegratedgeometry3casesASAN/UBSAN+colorobserver borroweddescriptor testpass. Codec narrowreview noP1; calibration native stop/dimensions narrowreview no known blocker. Rootcontrolleralso tightenedafterindividualstopgroup13.
- This is NOT hardware H264 proxy, NOT resource-headroom measurement, NOT ISP color/fullopticalFOV proof. NativeISP selected originalIQpreview0 still mode-specificunknown. No firmwareboot/UI install.
- Codec delivered `raw-hardware-proxy-candidate/` generator7checks checkpoint e11d0f6f75871a30b9a2f6f21c3502d13d67de1cf58eaa509da0b9619963db83. SameSOUT1→originalshadow2→streamingconvert→venc1(push)→rtpeng1. Exactrole5stream=liveview_rtp (notliveview_encoded), nativeinitencoderfps3000 whileRAW2400; mustmeasuretimestamps. publicset_live_view_extended true mayreplacegroup13; false forcestransportNone, no Qt setterinvokable; nativeRtpdumpstubret. DoNOTtrytheseasRTPtoggle. Agent now implementing bounded compressed-outputcopy at nativecallback/export BEFORE network-enable gating, keepnativebufferlifetime/forwardonce, feedexistingH264mux. DoNOTCPUencode. ROOTnext: receive/review thisconcretepayloadABI/candidate, new boundedH264+RAW trial,resourceA/B. Needstop5→0→1→whole, confirmed nativeencoderdrain.
- Calibration agent6.1solMAX: fixedwallaffine crossvalidates5unseenframes but coeff variesbytake. Oldtakea~.694,b~1107 vsnewDNGa~.736,b~1005 vswall.817,577; fixedcorrectionreduces errorbut residual unacceptable. No productionRAWmodification. `raw-banding-calibration-investigation/cross-frame-validation` compareimages/metrics readbyroot. IQnative SUB_SBIN enables/bypass segment-specific, samegeometryWH doesnot implybypass; originalpreview0 H[42,44,42],V[128] vsMFpreview1[64,64]; neither blindprofilecopynorcoefsidentityapproved. Agent finalizingshort report/next-shotconditions.
- UIK now actualinteractivechoices delivered `manual-video-product-ui-k/`, freeze163a56fa6756cef117060397653c742f72521760599336b1353046bbece05b59,15actualQtchecks. Lastmenu12thcellicon+Drivevideo nextfocusbracket preserved; realresolution/fps/RAW/formatchoices matchtwo profiles AVC1300x970nominal30 /CinemaDNG3920x2946 24shortproven. RAW manualbackendUNWIRED→待接入/canRecordfalse; cannotmisrouteoldHTTPAVCstart, stopalwaysavailable. Rootviewed03RAWsettings+02resolution screenshot, showed03tousercommentary. Jlayoutalreadyapproved; Knewpage NOTinstalled/shutter/persistence stillpending. Do notclaimselectedspecmeansrecordavailable.
- Nativealbumagent finished `raw-proxy-resource-metrics/` sampler/read-onlyhostanalyzer13checks. sample.sh count[1..120] verifiedPIDs,1scadence+actualuptimebrackets,cpu/percore/processstatstart/RSS/mem/thermal/frequency. noCLK_TCKguess,missing/deniedunavailable; CPUidle≠ISPDDRheadroom. Notdevice-run yet. Use existingindependentobserver, notfactoryRPCduringtransitions. Need matchedRAW-onlyvsRAW+proxy phasedsamples with actualframe/writecontinuity.
- Full RAW goal active/unbudgeted; thisturnPROGRESS, notcomplete. No newmemorywrites/commits/push. No externaluserconfirmation needed forauthorized boundedsource work.

## Latest 2026-10-12T19:27+08:00: RX17 staged; native FD10 launcher required before source test

- Previous turn classified progress (exclusive take layout implemented/tested); this turn also actual progress. Root sole camera operator; no imaging source started. Current native state rechecked Active/None/Still16bit0/CropNone, service29393/gui30347/factory29815; boot80026cc1-5987-40c7-a271-f68e8165c424/adbd group5258 unchanged. Keepawake screen_idle_timeout0 observed. One combined diagnostic returned rc1 solely because ls found no lock paths; camera state queries succeeded.
- RX17 finalized agent checkpoint ed7a0d671d247125b31afc8879538712718f631e6b47ed030c4435132b60750d,10 actualC delta cases. Root read complete live_progress/wire/control/receiver/hook differences and target ABI. Unique defaultoff `/system/lib64/libx2v_mode21c24_dng_progress_20261012a.so` d77cdb42e9353fa28e80ef2d564d13f3c8e460ac37bf2008d240c69634973fd9/335288B successfully staged: outputs/source-progress-v17-stage-190757/report.json, installed_readonly/before=after. Root wrapper local-verification/source_progress_v17_stage.py.
- Codec new HELD packet source-session-isolated-resident-two-v17-progress under active development, not released/loaded. Its readonly256B reader18 actualC cases; ELF7057c7f54b4231c1187b78d7edb9d691a782b1a397790f9365680577775b033d/34320B successfully staged at /system/bin/x2v_rx17_progress_read_20261012a: outputs/progress-reader-v17-stage-192357/report.json. Root read helper code (double reads/even guards/fresh source identity/open admission/actualcopy). Root wrapper progress_reader_v17_stage.py.
- CRITICAL root actual native shell probe: `10</dev/null` does NOT bind FD10, it becomes argument10 and redirects stdin. Evidence research/full-fov-pipeline/raw-product-control-timing/target-shell-fd10-probe.json. Do not execute a controller using shell `10<>progress`. codec tasked native launcher dup2→10 and restorestdin/devnull, retaining3..9 and exact service args; launcher must set RX17 LD_PRELOAD only immediately before service exec, never preload receiver into launcher. Needs actualC/targetreview/staging before packet release.
- root actual C ISP full-transfer geometry candidate in native-video/experimental/raw-isp-geometry-candidate/: guards entire136B nativeSUB plus RAWclone context, exact5u32 changes, sanitizer byte-whitelist/everySUBmutation/doubleapply/wrongcontext PASS. Offline two-sink SP/conf generated, RAW stream unchanged/new1300x970 24fps SOUT1 color_null. NOT linked/staged; no nativeYUV proof. Preserve pendingrange/calibration/dualstop gates.
- raw_calibration_sol continuing native-dual-stop-audit. New evidence: individualstop awaits consumer_wait_stopped; whole doStopStreaming publishesMax BEFORE native stop returns, so need delayedDBus ACK thenMax, neverMax-alone. Agent tracing exact role0→role1→wholeteardown/constraints; do not repeat raw-onlyrole1 fordualstream.
- native_album_sol delivered raw-product-bridge-revision-b134 actualC assertions/9groups and raw-product-broker-candidate39 host ordinaryfile checks. Now building ARM64 native broker in raw-product-broker-native (sole serializedcommand/cancelwriter; privatecontrollerproofingress; missingterminal integration remains unavailable). No device access by anyagent.
- Derived historical175759 timings saved raw-product-control-timing/source-175759.json: ownerguard→firstarm35s, stockabsent→firstarm23s, firststop→secondarm6s, finalstop→restored32s (1s log resolution). Actualwriterstop~40ms separately. Avoid sourcehandoff on every productclip; thisRX17delta should not mix recoveryoptimizations or extend24/34/47s limits.
- No running exec sessions at checkpoint. Source execution HOLD remains, no newUI/bootchanges. FullRAWgoalACTIVE/unbounded and incomplete; next root: receive/review native launcher+heldRX17 packet, stage launcher, release one bounded progress-aware2s×2 trial and inspect actual prepared/firstcopy/terminal/recovery.

## Latest 2026-10-12T19:03+08:00: RAW take layout, thumbnail and ISP-first proxy preparation

- Root has performed no new camera operation in this continuation. Last imaging evidence remains RX16 source-isolated-175759; last ordinary-file allocation replay183444. Recheck device identity/state before any new operation. No new UI/boot installation.
- User explicitly requires one independent SSD directory per recording, consecutive frame numbering, proxy Playback paired to the same take, and prioritizing ISP/hardware over CPU. New `native-video/experimental/raw-take-layout/README.md` defines this; `take_layout.py` is a host-only exclusive UTC+UUID allocator with empty raw/ and preview/ plus immutable take.json. It is NOT connected to source controller/camera yet. Host same-second, clock rollback, duplicate refusal/preservation PASS in host-check.json. Existing175759 dng2 inventory confirms207 frame-000000..000206; no bulk payload reread.
- Proxy architecture remains candidate: native sibling SUB/SOUT YUV → hardware AVC → per-take MP4. RAW-first bounded queues and native buffer/encoder shutdown required. Neither simultaneous RAW/proxy nor associated CPU/thermal headroom proved. Apple official FCP format page lists RAW stills but not explicit CinemaDNG video; don't promise sequence support there based on filenames. Resolve multi-take import still needs application verification.
- Root built `native-video/experimental/raw-dng-thumbnail/`: actual C sanitizer valid/truncated/wrong-width checks + independent NumPy full area-bin pixel agreement; latest area-bin ELF ef728d431ef73748a2977ccbf33c0cebb7d932853a9c000bf31507e44b3dfe16,28168B. NOT staged/executed on camera. Supersedes initial nearest-cell preview that aliased bands. Thumbnail is provisional uncalibrated display, not RAW correction or live proxy.
- codec_pipeline_sol is integrating RX17 fixed256B FD10 live progress, unchanged RX16 terminal ACK/source/durability/47s limits. Native agent repairing bridge ERROR/RESTORING/freshness and preparing ordinary-file broker. Calibration agent auditing native SUB/SOUT monitor path, user ISP-first priority forwarded. All agents OFFLINE, root sole camera operator. Receive/review handoffs before new live packet. No live exec session at this checkpoint.
- Full RAW goal remains active: live progress/control, native simultaneous monitoring, proxy, physical shutter/UI, sustained duration, calibration and persistence still open. Never equate allocated take, command write, readable thumbnail or proxy success with saved RAW/native recovery proof.

## Latest 2026-10-12 18:35: performance A/B complete; no camera/session work active

- mode0_length helper finalELF f6b93037338e0cbbf7d76a64de159d839626c95550a86d5f159f79535a710f5a (131376B); freeze1e4eac532176b02a313c3df506eaddd4a7a879a97e550fbee214aa9aa6a0862c. Newdefaultoffstandalone only. stage183354 PASS/root39929terminal0; sixreplay183444 PASS/root45889terminal0. Allselectedpixels/publications/sync/sourceidentity/stockhealth/locksPASS. Noactiveimaging/nativeworker.
- Explicitmode0 lengthallocation actualsize23100928 observed1 allsix; write median34.229ms/range31.500–37.696. Alloc0.029–0.096ms, pwrite25.923–28.704, openpeaks5.815/7.148. Doesnotmeet<30, overlappingbaselinevariationmeansnotstablegain. DoNOTpromote toRX16 orrerunlive24simplytoverifyunchangedpath. User24fpsverificationalreadyPASS207frames/8.6s/23.9994fps/0drops; currentlivewriter31.852msmedian/max53.297.
- Helpersroot: dng_length_alloc_stage.py +run_dng_length_alloc_replay.py. Commonrun_dng_replay_benchmark.py has optionalEXTRA_ARGS defaultempty; priorsemanticsretained. No newlive source packet/release created.
- codec_progress prototype delivered6actualCcases, checkpoint6fa871c7ac70cc6b575b33bd422e22fa71c5656db964d0f41f9e1966876efb72; readonlyactualRX16 getters and256Bwire contract only. NoFD/targetELF/constructor/physicalRECbinding. NativebridgeCPU100assertions remainsoffline, rootnotedERROR/RESTORING/freshnessissuesunfixedthisturn. Allagentsfinished, mayfollowupwhenneeded, nootherdeviceoperators.
- Calibration investigationcomplete: ChineseREADME/verification-receipt andpointwiseclass11PNG, only720Bfactoryslice; normal14/16/HSfullstillcalibrationnotdirectcurrent12bitmodefit; byteordercommonpackinghypothesesunsupported, pointaffinepromisingbutuncalibrated. No maps/body downloaded,no correctedRAW/DNG production. Rootvieweddiagnosticcrop.
- FullRAWgoalstillACTIVE/unbudgeted; currentturnfocus24then<30 completeasprogressonly, target<30 unresolved. RemainingproductRAWsourcecontrol/status/monitor/shutter/longduration/calibration/persistence/playback. No boot/UIwrites.

## Latest 2026-10-12 18:22: 24fps already verified; phase timings + preallocation diagnostic

- No live camera/source session. Latest full source restore remains175759 service29393/gui30347/factory29815. Subsequent ordinary-file phase andalloc helper runs leftstock/state/systemro/timeout0 unchanged, allpeer/IOlocks clear. Rootsolecameraoperator.
- dng-phase-stage180807/PASS and dng-phase-replay180907/PASS: sixsameframe ordinary SSDwrites, totalmedian34.236ms; pwrite28.296ms/fsync2.907/open1.173/close-publish0.752/manifest0.033. Newphasehelper67ad6801…263fa6, no changedIOdurability. Notnewcapture/30fpsproof.
- dng-alloc-stage181747/PASS installed defaultoff7116ef0…d0fad. none181842/PASS median36.440ms. keep_size181919 terminalFAIL errno116 aftersuccessfulfallocate butpostsizechanged0→23100928; no pixelpwrite/publishedDNG, partialclosedretained, independentstatconfirms. Before/afterhealthsame/sourceunchanged/locks clear. No rerunorrelaxguard. Nativeagent developing separate explicit mode0/grow allocation candidate offline.
- Calibration rootread total720B factoryfile slices:496header+32mode+152GC+20+20descriptors. Source437345304B file untouched, identity45829:14:1:437345304. Single11760x8842mode, GC14/16/141 depths,1536x1094grid. No12bit entry; do not blindlyapplystilltableto3920x2946. raw_calibration_sol finishingofflineanalysis; LE16supported,byte-swapworse,affinepointclasspromisingbutnotvalidatedcalibration.
- native_album_sol delivered raw-product-bridge-candidate CPU model100assertions thenassignedallocation helper. RootreviewrequestedprogressRESTORING/ERROR gates andpipeline_readyfreshnessfix later. codec_pipeline_sol now owns independent receiver-live-progress-candidate; getter/tearingguard only, nofrozenreceiveredit/noFD/constructor/targetintegration. Both stilluninstalled, no RAWmonitoring/shutterclaim.
- Userlatestwrite<30targetremainsopen;24short+8.6s actualpassalreadyreported. Keepminimaltargettests; no bulkhash/readbackrepeats. FullRAWgoalactive.

## Latest 2026-10-12 18:00: RX16 extended24fps PASS, all source work terminal

- `source-isolated-175759` terminalPASS, rootexec32616 exit0. SameRX16, clip1 62frames/2.579s, clip2 207frames/8.613s,4,781,892,096B insecond DNGdirectory. Delivery23.999555/23.999399fps; allsourceIDs consecutive, zero receiverdrops. Secondcopy median9.255ms max10.244; write median31.852ms max53.297; stop→writerdone40.204ms. No sustainedminutes/30fps/calibration claim.
- Nativebody0/recovery0/restored/locks clear, newstockservice29393/gui30347/factory29815, normalActive/Still16bit/None/CropNone/systemro. Keeperrecreated30629 byexistingguard and timeout0/screensettrue. No live imaging/session remains; released_modes cleared. Original175315 short trial alsoPASS andtwoDNGsamplesdecodedLibRaw+tifffile; pixel valuesagree.
- User asked<30ms target andcurrent24first. Current24short+8.6s verified; <30notyetachieved. Slowestwrites175315 bothindex0; steady~31.6ms, writerCPU~8ms. Sourcecopy~9ms overlapswriter, boundedqueueabsorbsinitialslowframe. Codec tasked fresh offlineordinaryfilehelper substep timing(open/pwrite/fsync/close-publish/manifest), unchangeddurability, beforeguessingpreallocation. Nonewdiagnostichelperstaged.
- Userdownloadsample paths: native-video/outputs/source-isolated-175315/dng-sample-readback/clip1-frame-000031-UNCALIBRATED.dng andclip2-frame-000031-UNCALIBRATED.dng. New DNGsequence SSD path /mnt/media_rw/ssd/x2v-source-20261012/runs/source-isolated-175759/dng2. MainfullgoalstillACTIVE: productioncontrol/UI/longrecord/persistence/calibrationunfinished.

## Latest 2026-10-12 17:55: FIRST LIVE RX16 DNG24fps PASS; longer second clip underway

- `source-isolated-175315` terminalPASS (root session49581 exit0). Actual SSD DNG generation1/2 each62frames,1,432,257,536B; delivered24.000157/23.999375fps, contiguousnativeIDs, zero receiverdrops. Copy median9.252/9.303ms max10.31; write median31.568/31.676ms max52.209/56.488. Stop→writerdone39.303/14.408ms; interclip6.768s. constructor→arms22.183/31.540s; sourcebudget47s unchanged.
- Newfiledirectory/manifest gate and newnativeCACK/Pythonpairoracle allPASS; nativebody0/recovery0/restored/systemro/locks clear. Newstockservice21645/gui22566/factory18856, Active/None/Still16bit/CropNone. Rootonlydeviceoperator.
- `dng-sample-readback` sampledframe31 eachclip; both23,100,928B actualmachinewrittenDNG, tifffile/LibRaw decode3920x2946U16 andexactpixelagreement/tag254=0. No simultaneousRAWcopy so notclaimsource-to-DNGbytecomparison for thislive run; existingbackendpreservationtestscoverpacklogic. BothremainUNCALIBRATED. Files available to user in outputfolder.
- User prioritizes24fps thenwrite<30ms. Root now runs `run_dng_v16_eight_second_once.py --execute`, liveexecsession32616. Newpacket source-session-isolated-resident-two-v16-dng-eight onlychanges secondstopwait2→8s; first2s/47sconstructor/10scap/34ssecondarm/150swatchdog/source/backendunchanged. Expectedsecondfinish~40.1s leaves6.9s margin. DO NOT HblShell duringownershiptransition; pollsamehandle; no reexecution.
- Alloldone-shotpacketsconsumed; newrelease revokedinfinally. Codecagentoffline analyzingactualslowframes withoutchangingdurability; calibrationagent6.1sol/max looking at byteorder/stride and actualX2DCalStreamFilter::calibration/doCpuCalibration path.

## Latest 2026-10-12 17:50: prepacked actual replay PASS; RX16 helper staging complete, live24fps next

- `dng-prepacked-stage-174019` PASS; `dng-prepacked-replay-174121` PASS, new capture0. Prepare16.095–18.617ms/write33.506–36.834ms/finish7.376–11.588ms, allpixels match, before/afterstock unchanged. Serialprepare+write49.6–54.7ms; not live24fps proof. Agent formal benchmarkfreeze fdb6de62…5c8d4 references sameELFebcd791e…180aa7; buildreceipt updated references formalbackendmanifest only, no ELFchange/retestneeded.
- `receipt-v16-stage-174719` PASS standaloneCPUvalidator8657b1…69ed; `source-dng-v16-stage-175001` PASS unique defaultoffRX16library57f886…ac5f. No RX16 load/recording started yet. Independent receiver/backend source+ELF narrowGO at research/full-fov-pipeline/rx16-prepacked-independent-review/receipt.json (4d1e6f91…5eda8), no nativehook/HAL/source change.
- Root hostwrapper `isolated_resident_two_v16_dng_test.py` uses new `receipt-oracle-v16-dng/ack_contract.py`22focused casesPASS. `dng_capture_metrics.py`reportsdeliveredfps/contiguousIDs/loss/copy/write separately fromnativeexposuretiming. Native agent owns newheldcontroller andmanifest gate. Root needs finaldiffreview,one-shotrelease/newfreeze then2s×2trial; don'treuseRX15packet.
- User explicitly prioritizes current24fpsrealcapture before<30mswrite forfuture30fps. raw_calibration_sol (6.1sol/max userrequested) owns offlinebanding/byteorder/readout/calibration, no device access; initialBE16 candidate multiplieslocaldeltas256×, notsimplebyte-swapfix. Mainpipelinepreservesoriginalpixels.

## Latest 2026-10-12: RX16 prepacked DNG receiver and new ACK validator built; replay staging active

- Root implemented `receiver_v16_dng_prepacked`: callback rowcopies source23379456 directly into compactDNG slot23100928, aligned pitch23101440/pool69304320; writer has no second imagecopy. All11 actualC ASAN/UBSAN cases PASS including3 occupied slots normalstop, originalcallbackinflight lease, writeerror, abort, dirFDalias/type/access. ARM64 candidate SHA57f886f372d695098391b3f6175e95c7ceeb2d7a88a8b1cbf36662b61378ac5f. DRAFT not staged, not live capture proof.
- `native-rx16-dng-receipt-validator`: new version16/DNG counts+manifest+dirsync+release/zeroerror contract;31 actualC ASAN/UBSAN cases PASS. Native ELF8657b1d900f11bd09b17521b893941684ba4c3c04081a16e4b043d5a7a7c69ed (55000B). Not staged. Native agent now assigned isolated v16 DNG controller/manifest validation, HOLD by default. Root only camera operator.
- Prepacked backend2bfddf87…2297c1, ordinaryfilebenchmarkebcd791e…180aa7(116632B). Root reviewed full backend + complete benchmark delta, current19+4 host cases and actual object/source/ELF pins. Review `research/full-fov-pipeline/resident-dng-prepacked-root-review/receipt.json`; ordinaryfile replay only, not liveRX approval. New runner `run_dng_prepacked_replay.py` validates version2/copyprovider and prepare/write/finish/verify separately. Original v1 validator verified against both existing actual reports; new version2 contract negative checks pass.
- Camera fresh state: service29773/gui30680 running, Active/None transport/Still16bit/CropNone, systemro, timeout0; ADB connected transport12. Stage via `dng_prepacked_stage.py --execute` root session95562 active at write; inspect completion before retry. No imaging transition or live RAW capture started.

## Latest 2026-10-12 16:55: 1MiB actual DNG replay PASS; still below24fps throughput

- dng-1mib-stage-165401 PASS defaultoff helper; dng-replay-1mib-165441 actual6same-frameDNGreplays PASS, outputpixelwords unchanged, service29773/gui30680/normalstock/systemro/timeout0 unchanged; no capture. put47.353–57.852ms,finish8.369–11.938ms; verification separate. Betterthan64KiB81–107ms butstill>41.667ms. Rootexec64220terminal0. Binary52f00714…42caf6; freeze2fa94aea…c4e2cb.
- Nextstandardpath: codec newprepackedDNGbackend preparing4096header+23096640image+192trailingpad total23100928. FutureRXcallback directlyrowcopiesvalidpixels intoalignedslot, replacesoriginalRAWcopy; writeronebigpwritewithoutsecondrowpack. Timeprepare/write separately; ordinarybench cannotprove overlapped24fps. Nativeagentassignedsource-span vsdestination-size split/admissiondrain+slot/ACK integration. No RX16 release yet.
- Padded-raster diagnostic one-strip3968storagewidth/3920ActiveArea givespixel-identical LibRaw visible3920, but semanticsofnonphotositepadding vsActiveArea unresolved; notdeployed. Oldone-rowstrips remainsREJECTED. Preserveoriginalsource/knownstandardcompactDNG.

## Latest 2026-10-12 16:42: actual ordinary-file DNG replay PASS, baseline too slow for24fps

- dng-replay-164115 terminalPASS/rootexec6034exit0; sixsameoriginalframeDNGs onSSD, each23,100,928B, all selectedpixel words equal. No new capture. Source inode/size unchanged, stock before/afteridentical, locks clear/systemro/timeout0.
- write(repack+DIRECTpwrite+filefsync+publish)81.198–106.726ms; finish7.781–11.922ms; verification150.668–173.421ms separately and excluded from encoder speed. This baseline does NOT meet41.667ms24fps budget. Next optimize actual perframe write overhead in NEWbackend candidate (larger staging or contiguousframepack), not add camera capture before throughput feasible. Samples in/mnt/media_rw/ssd/X2V_BENCH/dng-replay-164115/replay-000..005.

## Latest 2026-10-12 16:35: faster repeated RAW clips; DNG replay helper staged

- source-isolated-162018 TERMINAL PASS: two clips63frames each, same RX15/nativeC24 source. Stop-to-writer/fsync34.795ms/11.390ms; interclip5.612s vs previous6.852s. Whole guarded source session75s; no claim startup is fast. Stockservice29773/gui30680/factory18856 restored, systemro/locks clear, timeout0. One-shot fast-start packet consumed. Removed ONLY redundant pretarget read-only frame-count probe; recovery frame-growth check and all original timing guards retained.
- Previous source-isolated-160917 fast-C attempt rejected original24s prearm guard (observed26s), zeroarm/frames, full stock recovery. Never rerun consumed packets. Native C ACK validator installed defaultoff, ~8-12ms parsing vs oldAWK1.99s same existing ACK.
- Wall bands exist in direct U16 pixel statistics (one interleavedphase~939.9U16 mod6 difference); user now sees them in DaVinci too. This excludes PNG-only cause but NOT packing/CFA/readout/calibration/illumination. No proof of decimation/binning/PDAF. Preserve samples.
- Apple compatibility isolated to missing TIFF tag254(NewSubfileType0): WALL_APPLE_COMPAT_UNCALIBRATED.dng pixel-identical, actual Apple Preview opens. No calibration claim. Strided one-row-strip zero-repack prototype REJECTED because LibRaw11,448,960pixel mismatches although Apple/TIFF passed; never use.
- resident-cinemadng-writer frozen1ccabda8...2b413 actual15C cases+reader checks; uncompressed16bitDNG rowrepack,64KiB staging/requiredDIRECT/filefsync/atomicpublish, provisionalcolor. Not RX-integrated. Frozen replaybenchmark21e93454...00cd1 actualELF5d0f631d...83894 passes11C+independentreview; dng-replay-stage-163529 PASS, systemro and stocksame. Root run_dng_replay_benchmark.py ordinary6sameframe SSD test underway; inspect new output report before any continuation. This is no new camera capture.
- UI native-presented-clock candidate-b fixes discovered sessionABA using epoch+gate,29C tests, OFF_REVIEW_HOLD freeze42be24e6...196e52; actual renderer stillunwired/presented_knownfalse. J userlayoutapproved, no newUIinstall. D18 comparisonpacket remainsOFF/unreleased.

## Latest 2026-10-12 15:20: user-corrected scene and new wall evidence

- User correctly identified previous visible horizontal scene lines as curtains and moved camera to wall. Root withdrew the visual claim that those lines alone demonstrated a RAW defect. Do not treat curtain appearance or uncalibrated oldWB preview as causal evidence.
- Freshwall attempt151414 did NOT arm: original24s launch-age guard rejectedage26, zero frames, native recovery0/stockActive/systemro/locks clear. Exact frozenRX14 path then retried once in separatefreshpacket, no guard/deadline relaxation; source-isolated-151741 TERMINAL PASS,63frames1,472,905,728B,zero receiverdrop,USER6,stockrestored. No currentimagingoperation. Preserve originalconsumedpackets.
- Readback onlyframe20(nativeID871,offset467589120),23,379,456B sample exact; pathoutputs/source-isolated-151741/wall-sample-readback/. New wall preview shows actualdesk/wall/Apple-logo object and residual horizontal color bands acrosssmoothareas. wall-analysis.json: odd-y/odd-x mod6row means7407.6/8347.5/8342.6 vsotherphasefold2.5/6.1/23.7U16; relevantphasefold939.9U16. Controlledscene evidenceofphase-response difference, notsensorfailure/PDAF/packingcausalityproof.
- WALL_UNCALIBRATED_ASSUMED_RGGB.dng preservesallrawimagewords exactly verifiedLibRaw; stillassumedCFA/levels/matrix. wall-auto-wb-preview.png usesLINEARdemosaic+softwareautoWB/brightness, NOsiteinterpolationorrepair. Originalrawunchanged. ThisisPChostper-frameDNGcontainer, notmachinecontinuousCinemaDNG.
- Scriptslocal-verification/read_wall_reference_frame.py andrender_wall_reference.py. RenderingusesPYTHONPATH=resources/toolchains/dng-validation-python /usr/bin/python3; project.venv lacksnumpy. No dependencyinstallneeded.

## Latest 2026-10-12 15:03: RX15 real two-clip trial TERMINAL PASS

- source-isolated-150137 fully terminal PASS, root exec session83716 exited0. SAME native source/graph; gen1 A/S and gen2 B/T both USER6, each63frames3920x2946/stride7936/1,472,905,728B, total2,945,811,456B. Zero receiver drops. Stop→writer+fsync29.219ms and3.327ms; gap firstadmissionclose→secondarm6.85166s (controller overhead, not fast shutter-ready claim). Wholeguardsealed→stockrestored77s.
- Both gen CPU closures verified, native stop_dcam_stream1/teardown/reap complete, stock restored normal Active/None/Still16bit/CropNone. Current restored service26318/gui27210/factory26711, boot80026cc1…c424 unchanged. systemro,3locks clear. Native keepawake was recreated as27485 and timeout0 reapplied by runner. No imagingexperiment active. One-shot wrapper revoked released_modes[]. No full RAW download/hash.
- Unique default-off RX15 staged145317 PASS, ELFaf702d…84625, freezee8fb531b…50be3. Packet source-session-isolated-resident-two-v15 consumed, finalcontroller453398fe…bbcbcf/bootstrapfcfd0b7…de664; root-final-go documents only candidateHOLD removal+pin.77independentpacketchecks+14rootpaircases. Never rerun consumed wrapper.
- Next reduce critical-path interclip overhead: codec implementing native C exact ACK validator in new native-rx15-receipt-validator directory; current~3s ACK/file checks+~3s repeated snapshot/armchecks. No reduction of sourceownership/nativeDMAstop safety. Correctimage/standardDNG stillincomplete.
- D18 native preset comparison candidate implemented+built and11hostdelta checksPASS: mode21-d18-comparison-candidate/freeze.json6832d349…9b8838; ELF0e25ac29…0a99310. Independentnative review notdone due selected6.1-sol modelcapacity failure, noD18stage/deviceGO. Do notjustswappreset.
- UIJ layoutAPPROVED. UIagent actual native-playback-pts-probe built14hostchecks, defaultOFF, noUIclock untildecoder/presentedidentity closed. FurtherUIagentturn capacity failed; not downgraded and noUIinstall. Goal remains full RAW product path, no claim of completedUI/DNG/persistence.

## Latest 2026-10-12: UI J approved; RX15 offline two-clip integration

- Direct user reply: “布局确认，可以继续准备装机”. Saved local-verification/ui-j-layout-user-approval.json. Visual approval is no longer pending. Hardware full-shutter interception/half-press preservation and native playback clock still require verification; no new UI was installed on this approval.
- RX14 actual source-isolated-140802 remains latest imaging proof: 62 frames, ~24 fps, 6.303 ms admission-stop to writer+fsync; stock restored. No new imaging experiment in this continuation.
- RX15 receiver_v15_resident_two_clip has actual seven-case host integrated receiver/hook/controller proof and added expiry-between-clips PASS. Separate clip contexts/descriptors/files/ACKs, A/S then B/T, fixed absolute47s deadline. Not device verified.
- Independent review found ACK2 FD6 collision with readonly native conf. Root corrected to9 preserving SP/conf5/6; nine actual fixed-FD sanitizer tests PASS; independent SOURCE BUILD GO. AArch64 target ELF build PASS, SHA af702d5f9044acd11fff34c2c0e4f2fab64cb5eca0b32bda3b0dbf9002484625; candidate-snapshot.json saved. New packet must rebind child FD9 to ACK2 while preserving parent recovery-lock9. No RX15 native controller/staging yet.
- Real calibration file outputs/pd-calibration-readonly-142751/imx861lvbpc_normal.bin: 8744B, sparse676 unique main coordinates and10 secondary points, old3884x970 ROI. Does not explain dense phase periodic anomaly; no MODE21 mapping proven. Unsafe mutable callback snapshot remains OFF. Codec continues offline DSP-periodic parameter tracing.
- UI agent resumed same6.1-sol high after capacity failure, user approval forwarded. Root remains sole device operator.

## Latest 2026-10-12 14:09: RX14 ACTIVE trial now terminal PASS

- source-isolated-140802 is fully TERMINAL PASS (hostsession76762 exit0). ExplicitS/USER6 confirmed,62/62frames,1449526272B,2.609s admission,23.9985fps,zero receiver drops. Stop-admission→writer+fsync complete6.303385ms. Whole guardsealed→stockrestored64s. Sourcegraph/whole native stop/reap/stockrestore PASS,systemro,three locks clear. NoRAW fullreadback/hash. Exactv14hostoracle also PASS onactualdeviceACK. Release wrapper resetreleased_modes[]. No current imagingexperiment.
- Stagedunique default-offRX14 source-c24-userstop-stage-140716 PASS. ELF c736d5...b1303, receiverfreeze50f168...c318; finalnativeGO research/full-fov-pipeline/rx14-userstop-independent-review/final-pins-go.json. Newpacket/controller ea0ca5...c2f4 frozenconsumed; neverre-runone-shotwrapper. AllpriorRX13 packetsunchanged.
- Root next main task: residentvideo-mode source/repeatedclip startstop, ratherthanservicehandoffperclip. Correctimageinterpretation stillopen; codec tracingmode-specific pd_remove/PDAF-site candidate butnoPDmapconfirmed. Raw dataunchanged.
- UIJreview screenshots shown; asynchronousvisualapproval questionpending. NoUIinstall. UIagentofflinephysicalhalf/fullpressaudit: Override3+publicstart_session isnotprovenequivalent tohalfpressheld/AFC/AE semantics.

## Current 2026-10-12: RX13 10s PASS; RX14 normal stop candidate offline

- Previous ACTIVE source-isolated-133712 is TERMINAL PASS. 240 frames,3920x2946/stride7936,5611069440 bytes,10.021s writer interval,23.9996 admission fps,zero receiver loss,70s whole native lifecycle,stock restored/locks clear. Selected frames0/120/239 readback PASS; last offset5587689984 crosses4GiB. No full5.6GB hash/readback.
- RAW image quality remains incomplete: odd-x/odd-y has6-row response anomaly across allnewframes, no single gain/WB fixes it. Interpolation branch modifies1/12 sites and is NOT RAW. Codec is tracing native pd_remove/source mode specific correction, not claiming provenPDAF/packing/binning yet.
- New root-owned RX14 receiver_v14_mode21c24_userstop: S normal early stop(USER6), D explicitabort, final commandseal catches lateD afterwriterDONE, static single-consumerACK removes660KiB stack workspace.14/14actualC sanitizer tests PASS incl lateD. FrozenRX50f168ee..., ELF c736d5a2...b1303. IndependentSOURCE BUILD GO; finalELF/packet reviewpending. DefaultOFF, no stage or imaging trial at this handoff update.
- New packet source-session-isolated-target-userstop-v14, finalcontroller ea0ca5b8...c2f4, bootstrapmatched;56actualCACK/negative-gate checks PASS. Plannedone native2sS stop proof withunchanged10s240cap,47sconstructor,150swatchdog, nativeCPUdrain/stop/reap/restore. PriorRX13/controller immutable. Source released_modes remains[]. Rootonlycameraoperator.
- Latestpreflight native camera service5807/gui6688 running,boot80026cc1...c424,Active/Still16bit/None transport/CropNone,keeper19624 stillpresent,ADBtransport12. No imaging experimentactive.
- UI J finalreview screenshots shown to user:04compactPlayback and08fourborderrecording. Asynclayoutapproval pending. No newUIinstallation. Realshutterfullcapture suppression/halfAF andnativeclock remainunverified;UIagent offlineauditingexactinputsemantics. Nativeagentpersistenth observer hostsourcecheckscomplete, defaultHOLD, nottargetbuilt/bootinstalled.

## 2026-10-12 13:37: ACTIVE one-shot RX13 240-frame test

- User updated active goal: RAW internal recording full workflow until done; do not mark goal complete early. Root sole camera operator; live host session78956 executing `run_ring240_once.py`, run source-isolated-133712. Observe existing run only, NO HblShell during service transitions. Wrapper revokes exact released mode in finally; controller owns native stop/drain/reap/stock restoration.
- Frozen controller ffb077d49fe2634d198dc79f84b7d3bfd0c185e6a1de48907d30fc76cc5966c5; RX13 fd9a5ed4…c3111a staged132542 PASS. 10s/max240/5,611,069,440 bytes;3slots70,138,368 unchanged;47s constructor compensates exactly +7s capture,armage24/globalwatchdog150/SSD7GiB. Native independent RX/packet/schema-acceleration GO.32focused checks PASS. Native parser was24.75s; per-record schema arrays reduced to1.12s/config.09s, no semantic checks removed.
- Host preflight normal liveview wasOff/Max255 butallnativeopsidle/errorfalse; approved normal set_live_view true returnedOk and Active/Still16bit confirmed; report runtime/ring240-normal-preflight.json. Keepawake19624 alive/timeout0,SSD432154368KiB free. USB10Gbps remains latest host observation.
- User DNG location provided: outputs/dng-232855/result.dng (~210MB), from stillB0003648.3FR, explicitly NOT continuous MODE21. New actual RAW diagnostic DNG produced by codec: experimental/mode21-diagnostic-dng/ASSUMED_RGGB_UNCALIBRATED_FULL_TRANSFER.dng,23MB. Pixel exact verified, RGGB/orientation assumed, black/white/matrix/neutral fromstillreference; blue cast/horizontal bands, NOT finished color DNG. Root viewed preview. Don't conflate with synthetic64×48test or calibratedvideo.
- UI j record/layout/loading candidates produced, notinstalled. Waiting final demo package/copy change正在解码→正在加载. Need show screenshots then user approval, hardware shutter/fullcapture suppression and persistence remain separate gates.

## 2026-10-12 13:15: new cable negotiated 10 Gbps

- Current host IORegistry matches X2D II 2756:000b, UsbLinkSpeed=10000000000, bcdUSB800(0x0320), location18874368; ADB transport12. Saved runtime/usb-new-cable-10gbps.json. No need for mass-storage switch. Link rate only, not sustained file throughput.
- Direct ADB attempt to read existing SSD RAW denied by domain permissions; read report explicitly failed, no MB/s claim. No files changed on camera and no imaging operation started.
- RAW agent building independent v13 240frames/10s/47s constructor bounded candidate; 8 C delta checks passed incl >4GiB write offsets/partial failure; target ABI build pending. Root observed prior ctor→arm21.8s, so armage24 retained and ctor40→47 exactly compensates +7s capture; no stop/DMA/global150 budget relaxation.

## 2026-10-12: mode lifecycle, reboot persistence and Playback loading review

- New user explicitly asks video-only HUD lifecycle, restore normal photo menus on exit, restart availability, faster Play startup and loading animation when unavoidable. Root review saved `research/UI_STATE_LIFECYCLE_20261012.md`.
- Confirmed source gap assigned UI agent: canSwitchMode/setVideoMode currently accept error even if stopNeedsRetry (rtp_confirmed_off false); reject mode exit until confirmed stop. Preserve forced videoMode in active/error-not-off snapshots. Photo-mode gallery must still play existing videos.
- Playback Playing status precedes decoded frame; UI agent adds real first-frame gating (VideoItem implicit dimensions on decoded onFrame, not fake timer), loading/retry and late-event cancellation checks. startupTimeout10000 is deadline, not latency. No speed reduction claimed yet.
- Native agent tasked continue persistent h cross-group observer/autonomous UI gate/target candidate; remains OFF/HOLD, not reboot-tested. Keep feature/settings after reboot, never auto-REC. Root ADB cat /init.rc also Permission denied; no permission changes.
- Codec agent resumed narrow immutable dispatch/readtxn closure for RAW metadata; no device operation.
- No UI approval/installation this turn. Existing compact Playback screenshot was shown to user; recording three-state/loading evidence still in progress.

## 2026-10-12 12:49: latest UI review changes, no installation approval

- User requests compact translucent Playback controls over full video: remove filename/sample row and Stop button; play/pause, real clock and progress close together. UI agent j first actual Qt screenshot is `native-video/experimental/manual-video-product-ui-j/evidence/04-playing-real-clock-progress.png`; 88px overlay and 64px playback target, 17 focused checks reported PASS. Root visually reviewed. Native clock/seek remains unproven; desktop clock must not be called installed capability. Camera-only item grab requested to avoid desktop helper labels confusing user.
- Earlier physical screenshots require no floating video Start/Stop, full shutter toggle with half AF preserved, full four-edge red border above tabs, no stock OSD bleed through exposure tabs. UI agent owns j simulator; hardware_ready default false until actual service capture suppression/AF routing proven. User confirmation still required before UI installation.
- Root matched shutter audit read: QML accepted alone cannot stop native still capture. Override3 suppresses both half/full, OverrideHalfPress2 permits full. No native full-only enum. Must close AF route and held-release/focus acknowledgement before deployment.
- Minimal live readonly observation: timeout0, forward_input_events None0, liveview Active1, keepawake19624 cmdline sh. No source experiment or UI launched. HblShell /init.rc read Permission denied; optional hw init returned no data. Agent must inspect local firmware, no permission changes.

# 当前接续点：机内录制第一阶段（2026-10-11）

## 2026-10-12 12:43: RAW fast15 actual PASS, UI requires further simulator refinement, keepawake active

- User confirmed manual recording normal for120546; receipt user-recording-acceptance.json. User now prioritizes continued RAW and UI persistent reboot/DriveMode independent icon next to focus bracketing/fasterPlayback/real time-progress. Explicit newest gate: UI must be shown in simulator screenshots and approved before device install. At12:41 user rejected current playback visual hierarchy/alignment and supplied `/Users/paco/Downloads/浮引截屏_2026-10-12_12-40-52.png`; not approval. UI agent now refining independent i candidate; do not install h/i without approval.
- USB reconnected same boot80026cc1-5987-40c7-a271-f68e8165c424/adbd5258. ADB already runtime enabled; firstenable-adb safely refused existing config, then discovery completed. Later USB dropped; user woke/reconnected. Keeper5537 was natively absent, timeout300. Root restartedkeepawake: native19624/host24361 initially; RAW recovery may recreatekeeper (use current keepawake-state.json). AfterRAW root reacquired namedwakelock and readtimeout0. No boot changes.
- `source-isolated-123511` actual RAW fast15 PASS,body0/recovery0/normalrestore/locksclear. Same RX12/mode21C24/config/3slots/3s72cap.72frames,1683320832bytes,zero drop_full/drop_copy_busy,arm→writerdone3000.504166ms. Nativeguardsealed→restored65s vsprior88s (23s reduction). Fullhostreadback/bulkSHA intentionally NOT performed; no newcolor/FOVclaim. Newstock service24968,GUI25838;nativeidentities persisted `native-runtime-identities.json`,systemro. Source released_modes=[] restored by wrapperfinally.
- Changes in frozen new `source-session-isolated-target-ring72-fast15`: original schema per-field key/value matching + once-indexed AWK values avoids repeatedwholeline scans; native real72text parser2.17s vsold9.39s; reviewedv13cache; removed1.68GB fullSHA butkeptinode/length/fsync/strictCPUclosure/native stop/reap/restore. Packetcurrentboot/group bound5258,host `isolated_target_ring72_fast15_test.py`. IndependentnativeagentGO `fast14-independent-review/fast15-receipt.json`. fast14/v14 supersededcandidateonly. No originalRXbinary/graph/sensorconfig mutations.
- Codec agent completed `experimental/opaque-raw-tiff-evidence/`: priorverified081929frames4/8 perframe hash,4TIFF exactPillow+tifffile pixelmatch. RAW16_OPAQUE,low4zero,upper12 reversible; formalDNGstillnotreleased. Newmetadatareverseengineering:cam_info+14e8 is get_cfa_order,tag1000/type5;ownedprofiledeclares0 nativeDNGconsumerRGGB butphysicalmodephaseunproven. ActiveArea1500 ownedfullrect isreceiverrequestedrect,notindependentnominal3884x2914origin. Found exported typedvisitor dcam_enum_container_inner holdingreadtransaction,needsbounded/lifetime analysisbeforedevicecall; no unsafe genericdump.
- UI h simulator actualQtscreens01Drive and04Playback completed. Drive4col2row originalsix+video7 besideFocus6. DesktopplaybackactualQtMultimediaclock,deviceVideoItem has no position/duration/seek; mustnotclaimdeviceprogresswired. Preview pics shown and userrequestedfurtherlayout; currentUIagentrefiningi withtimebesideplaycontrols,stopsecondary/aligned,independentprogress,filenameweak,1024x768crisp. Computerhelperbaroutsideframe notinstalled.
- Nativeagent `persistent-video-boot-h` planner/defaultHOLD recoveryplan5checks, now implementingactualnativeentry+supervisor/autonomouslease offline. initstockSID0/PGIDPID differsfromg setsid; candidateusesinitparentseparategroup +setsidcontrollerchild,requiresseparateobserverforparentcrash. No permanentRC/boot/UIwrites; deploymentblockedbybothruntimecompletionanduserUIapproval.
- Root soledeviceoperator,3 agents6.1sol high. UI/persistence/codectasksongoingoffline. No imagingexperimentcurrentlyactive. Next RAW work:metadataCFA/active/calibrationsafeinterface and recordingproductization; do not re-rununchanged72capturemerelyforproof. Userperformancepreference:1sinitialtoolyield,completion-drivenpoll,no fixed60/120s.


## 2026-10-12 user acceptance: manual-session-120546 input response

- User directly confirmed “按键和触屏均正常” in response to Menu/Playback keys and touch return check. Physical input responsiveness is now accepted for this run; this does not certify full recording/playback/exposure control flows or future sessions. Evidence: `native-video/outputs/manual-session-120546/user-input-acceptance.json`. No camera operation was performed on this confirmation turn; current runtime/lease state was not rechecked. Earlier pending-input statements below are superseded only for this acceptance scope.


## 2026-10-12 12:06: g actual short record and automatic recovery PASS; manual UI left running

- Root bound frozen `manual-session-control-g` controller51806b4ed2fd6689723c0696e37690fda776f5808d162bcec4a4d9807a6f4a40 and complete `manual-video-product-ui-g`. UI preserves lazy native menu initialization; one-line gate clock-order fix removes actual host Qt mouse/touch-tested false-fresh transient. Neither host input test reproduced lost click; physical button sensitivity cause remains unproven.
- Real `outputs/manual-session-120428` launch/UI ready PASS13.238s. Focused changed-lifecycle smoke PASS: start→recording2408.1ms; stop→saved843.7ms; extension end→original GUI+liveview restored6609.7ms; whole smoke12.37s.45frames,1300x970,1.508s,2323869bytes. Saved `/mnt/media_rw/ssd/X2V_VIDEO/X2V_20261012_040441_8553_1.mp4`. Actual QML quiescence/native stop/GUI+bridge retirement/stock health/lock clear all PASS, service374 unchanged, stock GUI9395,systemro. No repeated codec/full-RAW readback/hash tests.
- NEW ACTIVE manual run `outputs/manual-session-120546`, launch/UI ready PASS13.033s. This is intentionally left running for user; do not overlap RAW or another UI session. Root source g TARGET2676 was rebound to current /uid_0/pid_5258,boot80026cc1-5987-40c7-a271-f68e8165c424. 600s native bounded session (~12:16 expiry),30s clip cap. User async question asks physical Menu/Playback/touch return acceptance; no reply yet. Keep physical_input_verified=false until actual reply/evidence.
- If ending this exact active session early, use root `PYTHONPATH=local-verification .venv/bin/python local-verification/manual_product_smoke.py native-video/outputs/manual-session-120546 --stop-only`; this publishes canonical same-run stop. Do not reuse any old emergency script/PIDs. Fresh report.json contains current child/bridge native identities. Native watchdog performs same tested recovery at lease end.
- Temporary runtime extension, not permanent firmware or boot installation. Experimental menu last tile touch-only; merged album is UI integration not native DCF video-index support. Photo A/M exposure native binding installed, physical adjustment acceptance pending; fullshutter REC mapping absent. RAW/highres/DNG controls remain disabled pending source integration.


## 2026-10-12 11:58: corrected lazy UI and lowres clip pass on new boot; final controller recovery delta pending

- Reboot confirmed. USB still480Mbps; temporaryADB reenabled usingcamera_access.py. Newboot80026cc1-5987-40c7-a271-f68e8165c424,adbdcpuacct/uid_0/pid_5258,service374,factory995. manual_product_session.py now supports --target-group --boot-id --controller-dir, rebinds only exactoldtarget source slots in freshcontroller/bootstrap thenchecksboot/group beforedispatch. Do not usepriorboot2676.
- Keepawakehost93522 stillrunning; prior nativekeeper diedwithboot, newnative5537,keepawake-state updated. Liveview initiallyOff restoredusingapprovedset_live_view true. No permanentboot/init changes.
- `manual-session-115041` usesdiag lazyExperimentalUIafterstockReady; realUIstartupPASS13.35stotal,mainContentcomplete~1.565safterrootstartup;menu/exposuremodelreadytrue andHTTPgateactive. Loaderpinunchanged. This is actualstartup evidence vspriorhungruns. Physicaluserkeyacceptance stillpending.
- `manual_product_smoke.py`: nativebackendshortclip47frames1300x970,1.583s,2,416,432B `X2V_20261012_035113_5877_1.mp4`;start→recording2621.4ms,stop→saved846.8ms. e/UIactualquiescenceACKPASS (ui_player_session0),nativeoff/noReceiver/noCommand confirmed. No repeatedfullRAW/hash/FFmpeg tests.
- Automatic f recovery FAILED narrow lifecycle gates: transientGUIretire false then exactmember false→error_gui_owner_or_exe_changed; anotherrecoverercompletedretirementandstartedstockGUI6813,then immediatehealthfoundOff/None/Max255 afterend teardown→error_final_native_health. Do notmarknormalautomaticrestorePASS. Nativeagentpreparingnewmanual-session-control-g: boundedZ/drain/reap observationwithoutsignals, restoreinitialActiveviafixedset_live_view true fromconfirmedstockOff/None, thenboundedhealthpoll; oldfunchanged.
- RootmanualreconciliationPASS: nativepriorparent5629/WD/GUI5992/bridge5877allABSENT, service374same,stockGUI6813running;fixedset_live_view truereturnedOk,Active/None/Still16bit/CropNone restored;frames1791→1800,errorfalse,systemro,ownlockclear. Filesrestoration-liveview.json andrestoration-reconciled.json. Noactivecameraoperationnow.
- UIagentfollowup investigatesnewdata-evidencedtouchbug: ManualSessionGate.accept setsreceivedAtbefore now causingtransientfresh=false andMouseAreaenabledfalse everypoll (doubleactivephase logs), potentiallycancellingpress. AskedfocusedactualQtpressfixture and minimal timestamporderfix ifconfirmed, nooldsuitedrerun.
- Next:g finalnewsource+delta evidence, optionalsmallUIpressfix; freshboundmanualpacket, one shortclipneededtoverifychangedpostrecordOff→Active recovery (skipunchangedcodec/fullreadbackchecks), then fresh10minmanualsessionleftforuser. Final reportmustsaytemporaryextension30sclip/10minlease,notflashablepermanentfirmware;buttons/menu12touch/exposure/playbackuseracceptancepending.


## 2026-10-12 11:46: lowres manual installation prioritized; two UI startup failures restored, corrected package waiting for USB

- User requests omit repeated successful hash/full-readback/testing; speed tools and mode lifecycle, install existing lowres/menu/playback first. Root now uses1s initial tool yield and result-driven continuation; no fixed60/120s waits. RAW/H265 work is parked during UI installation.
- RAW latest `source-isolated-105950`:72 frames3920x2946/RAW10001/stride7936/1,683,320,832bytes;24.000433 delivery/s,3.034s arm→writerdone,zero copy/full drops, native stop+whole teardown+stockrestore PASS. Fullhostrawreadback intentionally interrupted at user priority; not complete/PASS. Source released_modes=[] remains HOLD. Native overall88s was24normalclone+11target+27payload/validation+11retire+15restore; larger data validation offsets saved control time. Do not call88s a speedup over76s.
- Bridgee and client staged new immutable system files and system remountedro: `manual-bridge-e-stage-111341` and `manual-client-stage-111345` PASS. No boot/init/firmware image flash. eSHA810523de…97d2/clientb0177536…5862, same minimum pins report. Perclip start/stop has no hash/fullreadback orservice restart;30s cap/600s manual session/570s admission cutoff.
- New manualcontrollerf `experimental/manual-session-control-f`: root-reviewed malformedstart/exactGUI/wholethread retirement fixes;explicitPATH includes/sbin awk; canonical same-run manual.stop watcher. Finalcontroller e8a6b21d1e4ae00bea6d1766d2ea484a7aa6ced0e201788b1d6b6537d5181ca7.30+12originalchecks+15newdelta checks across distinct unchanged epochs, not rerun old suites. Source hardHOLD/PENDING stays; root host binds runtime packets.
- Root tools `local-verification/manual_product_session.py` (prepare offline, --execute package), `manual_product_smoke.py` (not yet executed; cannot claim clip timing). Host launcher: native passive bootstrap/cgroup migration thenresidentmanualbridge+temporaryGUI. GUI exec observation fixed to allow bounded samePID/start shell→camera-gui; phase running alone is not UIready. Now readiness requires stock_root_loaded/mainModelReady plusmanual_gate_phaseactive fromcapturedstartup log. native40s bounded logcat camera-gui only; no USB rawdownloads in UI test.
- UI `manual-video-product-ui` firstmanual23filetemplate:14bind/5Qtlogchecks,18oldmanual+4featurecomponents preserved. **NOT usable-installed**. Runs `manual-session-112648` and `manual-session-114216` both showedviewfinder butphysicalbuttons unresponsive; onlyselection+unwired logs, no stockmain ready orfirst HTTPstate. First host racedexe (11.2s), second hostbridge/processPASS12.9s butuserUIfail; report revised passedfalse. Normal UIACK-gatedrecovery held. Both independently recovered nativequiescent→exactGUITERM→wholeprocessretired→freshnativequiescent→exactbridgeTERM→wholeexit→stockinit/health→ownlockclear. NO fake/ui-quiesced. Do not reuse originalpassedtrue from114216 asUIproof.
- `outputs/manual-session-112648/reconciliation.json` stockservice21955 preserved,stockGUI32336,frames43805→43815,Active/None/errorfalse/ro/locks clear. Second114216 emergency-recovery.log confirmsrestore; getfreshpid ifneeded. Native service was never signaled. User was told do not reboot yet, originalrestored; then USBdisappeared.
- Latest USB actualnegotiated480Mbps before andaftercablechange (USB2); ADBtransport6→7/locationchanged, speed did not. At11:45 neitherUSBcamera norADBdevice present; async question pending asksreconnect +whetherrebooted. **No active camera operation**; bothruns restored beforedisconnect. Checkboot/adbdgroup on reconnect: priorbootf6668de2-2070-4793-9cbd-6cfbb7adc2bf,target/uid_0/pid_2676; bootstrap/controller hardtarget needsnewbinding ifrebooted. Do not blindlyrun2676 onnewboot.
- Newcandidate `manual-video-product-ui-diag` changes onlymain/HttpRecorder: limited5s/500msreadonlystartup ticks/tokenlength/no secrets/state-rejecttypes; mainonLoaded rawlogBEFOREnativegetter; entireExperimentalVideoUi nowlazyLoader afterstockMainContentReady. Hypothesis: eagerhidden nativeMenuHeader/Switch/constants/controlScreen init beforestockConstants.window. Rootoldstockmain+successdloader structure identical; loaderELFsamef88756…43ce. Thisis candidatehypothesis, NOT verifiedfix.4focusedQtcompile/bindPASS. PrepareSHA08caf758d6e758182c3138e0536519c785d01da400b03170bc8f52f5429eeb1b/main708298a1…0745/Http84fb2a93…c4212.
- Prepared rootbounddiag `outputs/manual-session-114540` butexecute failedbeforedevicecontact Expectedonecamera; nothinguploaded/launched. Can execute once USBback onlyifsameboot/target; otherwisecreatefreshadaptedbootstrap/controller. Next: loadcorrecteddiag, verifyactualUIstartup; onlythen oneboundedbackendclip withtiming andactualnormalUI/endrestore; finallyfreshmanualsessionforuser. Existingreview-d lowresMP4decode proof neednot rerun unchanged.
- Agents usegpt6.1sol high. Rootsolecameraoperator. UIagentownsdiagcurrentlyfinalizingmetadata;native/codecfinished. Do not launchanotherRAW, installoldbrokenmanualUI, orclaimflashablefirmwareready. Physicalshutterstillphoto; noRECmapping. RAWsettings disabled; mainmenu12thentrycurrentlytouchonly, notnativefavoritemodeldialindex. Exposure inheritance needsrealnativeacceptance.


## 2026-10-12 10:59: test latency optimized, ring72 packet frozen; no RAW trial dispatched yet

- Latest user explicitly requires much faster tests and shorter MCP waits (annotation "76 seconds"). Root uses1s initial tool return/polls and completion-driven continuation; no fixed60/120s waits. Host guard readiness now signal-driven vs1.3s fixed delay, observer1s→0.2s; failure/watchdog budgets retained.
- New batch observation88 actual mksh checks PASS. Native read-only measurement `outputs/source-query-timing-105105/report.json`: separate3calls0.54s vsbatch0.19s,~65% saved on query only; not full76s lifecycle proof. Strong owner freshness/exact16fields/one-shot snapshot; op invalidates; wait_ready no duplicateSTATE; frameproof0.1poll replacesfixed2s, count advancement still required.
- New receipt-cache18 actual mksh+identicalAWK(hostgawk) checks PASS in7.37s; initial macOS awk matrix timedout90s, not PASS. Successful complete receipt only, run+3inodes+fullSHA/length rechecked, failures fallbackoriginalclosure. OriginalAWK bytes unchanged. Native synthetic text benchmark `outputs/cache72-pure-105527/report.json`: first11.42s, cached2.72/2.76s, strictparse1 total; these include inode forks, no imaging. Cache freeze2d86ef94074a691986eb4c464e022f7f9541f176b8ca72cb28c364888d8ea32e.
- RXv12 freeze2a7cdfe3c7ef342ecaf602617440239c824816afbb5bb2ec4903c549f9b9d6dd; ELF05086d72a5679c07b13cae597f42e98b514b82a8be08745b1d8fcba39f292fd8/933408B.9C checks and independentactualELF GO. Stagednewunique `/system/lib64/libx2v_mode21c24_ring72_20261012a.so`, `outputs/source-c24-ring72-stage-105149/report.json` PASS/systemro; doesnotmeanloaded/captured.
- Packet `source-session-isolated-target-ring72-v12-c24` freeze95f74f4ac841e2d59c58b041a4a47df8e1c8bbc84200f3cdfe5819b38888668d/controllercfbaf0677076e683443762250f49e0ccfc85bd28700566f4c3432638cd0ab8ea/bootstrap2f17a362e35bc6bfca8dfb606876e6ca8baedd5ef8108a9ded8fd30942045357. Finalbinding12PASS: originalACK24byteproof+obs88+cache18, actualcap72 anddurationPythoncontracts. check_delta.py is archived pre-latency proof; use check_final_binding.py for final version, do not claim oldcontrollerSHA matchesnew. Source mutatingops/stop/reap/restore functions unchanged. Native independentfinalpin review pending; no one-shot source release yet.
- UI newcandidate `video-settings-exposure-ui`:24QtPASS/0warnings, experimentalmenu/exposuretabs delivered, rawsettingsdisabled/UNWIRED/HOLD/notinstalled; physical12thmenuslotdialnotwired. H265 remainspaused. Metadata typed publicenum found but writer concurrency fatal; no metadata/DNG native trial without finalized-frame proof.


## 2026-10-12 10:35: user prioritizes longer RAW/DNG; new UI settings delegated; no source trial active yet

- Latest user direction: pause H265/10bit encoding; prioritize sustained high-resolution RAW physical tests and explain actual RAW/readout (binning vs skipping vs oversampling), then direct in-camera DNG. UI agent owns new experimental menu slot + resolution/RAW/fps settings, preserve stock exposure mode A/M etc and physical ring/dial actions; clickable exposure tabs. New directory; default unproven modes must not masquerade as installed capability.
- Root new packet `source-session-isolated-target-ring72-v12-c24` plus `prepare_ring72_v12_packet.py`/new host/readback wrappers exists, RX pin PENDING, NOT frozen/released. Delta only72frames/3s/version12/newtoken/path, SP/conf/guard byteexactC24,3slots70,138,368B unchanged, source/stop/restore unchanged. New space gate3GiB before setup and arm, launch-age24s leaves conservative16s of40s constructor deadline. Controller parser synthetic24checks PASS,65,678B receipt; actual native pure-text AWK takes8.05s/pass (no imaging); first ADB-only attempt had127 due native tool visibility, retained separately. Root sole camera operator.
- Codec agent implementing v12 RX3s/max72=1,683,320,832B; new ACK stack capacity131072/147456 to cover89,478B conservative bound; source build GO for minimal delta. Waiting actual tests/ELF/pins, native agent will narrow review. No camera capture started.
- Fresh native preflight `outputs/c24-longer-preflight-1027.json` PASS: stock service1710/gui2685/factory29101, samebootf6668de2/ADB2676,Active/None/Still16bit/CropNone,errorfalse,frames110885→110897,fourlocksabsent/systemro,SSD435,694,848KiB free/MemAvailable409440KiB. Current operation only offline development; last hardware capture remains C24/09482620frames completePASS.
- Manual product work parked offline: bridge e ELF810523dea771c75c86ff48285c8f10037e82b9e6f14a349ffb8bc9958b8597d2/142432B; client ELFb0177536057d992bb8ca6c31654a468a59f4a842270d00bb37efadaeec785862/47456B. No install.36clientC+6bridgeC+12actualhostTCPintegration+20mkshfixture checksPASS,9UIQt/0warnings. Newmanualcontroller hardHOLD/PENDING, native review found GUI exactmember/wholeprocess retirement gap and malformed bridge-start identity validation gap; these MUST be repaired before release.20mkshfixtures do not cover genuine nativeproc/launchpublication. Client proposedpath has `_manual_session_client_` but controller draft still `_manual_client_`; align before future package. UI originalmanual main delivered ddce6d52ce5cb1f3e48266df7529f2e9f55955a6e2bec7fed7a44c47735e205d; defaultUNWIRED/emptytoken/run/nonce, not installed.
- Time evidence:094826 native seal→stockrestore76s; capture arm→writerdone0.844s, copy8.462ms/write27.043ms average. No exact code/build/thinking timings withoutlogs. RAW16_OPAQUE/PHYbitmode12 and low4zero do not establish ADCprecision/CFA/fullFOV; metadata serialization remains unsafe-on-small-buffer, no guessedDNG.

## 2026-10-12 09:54: C24 complete PASS; stock restored, no active device operation

- source-isolated-094826 capture63978/readback46805/posthealth35912 all exited0. report.json and ring20-readback-report.json PASS. 20 frames3920x2946,467589120B,20uniqueSHA,fullSHA b69548f60af8a58baf4f0bb36fe8015fe77a7d1a44a33b1941869541bfa075df; IDs1017–1036,zero receiverdrops;CPU19interval791.691667ms=23.999242/s. Not long recording/exposure-FPS certification/fullFOV/CFA/DNG/highres playback proof.
- ring-container-analysis/report.json and ring-preview.png generated by existing inspect_raw_ring_v11.py; root viewed4gray samples/coherent blurry scene, no color/calibration claim. Meancopy8.461667ms/write27.043360ms,armclose814.141666ms. Native stop/whole teardown/parentreap/stockframes463→612 confirmed.
- post-readback-health.json PASS: service1710/gui2685/factory29101/running,Active/None/Still16bit/CropNone,active_errorfalse,frames8766→8808,4locksabsent/systemro. Allsource releases revoked[], root-release consumed_PASS_revoked. Keepawake still authorized. No active camera experiment.
- Codec offline: C24 performance summary and minimal native SUB/SOUT1 fullheight8bit source plan (distinct from MAIN10). Native offline: metadata serialize capacity-shortage asserts/fatal, not safe4KiB reject; no new metadata/RX device candidate yet. UI offline: manual main only,10min session design without autonomous lifecycle implementation/deploy. Continue scoped progress; no unchanged C24 repeat.

## 2026-10-12 09:50: C24 capture/restore PASS; same-run readback active

- Host capture63978 exited0, source-isolated-094826/report.json PASS/body0/recovery0. Actual20frames/467589120B, IDs1017–1036 contiguous, CPU19intervals≈23.999242/s, drops0/0, copy8.462ms/write27.043ms mean. Arm-close814.142ms. Not long-recording/fullFOV/codec proof.
- Sole active device action is readback host session46805: isolated_ring20_v11_c24_readback.py --run source-isolated-094826 --execute. Wait same handle; do not relaunch. Global C24 release remains solely for same-run readback, revoke upon reconciliation.

## 2026-10-12 09:48: C24 bounded trial dispatched; root sole device operator

- Active host session63978, run source-isolated-094826, isolated_target_ring20_v11_c24_test.py --execute. Observe same process/run only; no HblShell during source transition, native controller owns stop/reap/restore. Global release permits exactly this C24 trial plus same-run readback and must be revoked afterwards.
- C24 RX freeze7eeb2287580feaf04bba500bafedaec8d000618b7348dc876b5d4e63479f69ce,49files; ELF2a3ceb09632dca966eac5821d2f6bddce6bfb30a0039864eac66a61334513b0e/933000B. source-c24-stage-094725 PASS installed_readonly. New unique path /system/lib64/libx2v_mode21c24_ring20_20261012a.so; unchanged direct writer,1s/max20/3slots,driver17. HB36M/500/3000,HAL2400/conf2400/guard24/1 coordinated. Actual13C and independent source/ELF GO.
- Packet freeze068cf08e6305c7b339523ad7dbeeaf68dba584249403bd818ca8f022928b100e/controllerdc86c187ae60d10e6b971c93d075e2d77e57007ac3d3274246f2cc369302f5db/bootstrapc2c8e39dbeea7581d02ff7a71c034b13c0701a71385cb218b86cd397a846426b;17focusedlogchecks+8rootmechanical+native final packet GO. Guard/ACK/SP/native closure byteidenticalv11; wrappers only names changed.
- Freshpreflight four native locks absent,service19329/gui23691/factory29101,Active/None/Still16bit/CropNone/errorfalse,MemAvailable402980KiB,frames74407->74453,bootf6668de2/ADB2676/systemro. This is preflight, not C24 outcome.
- Metadata sync_dmp is NOT synchronous worker: asynchronous retain/queue remains. Do not run native dump or claim CPU drain covers metadata. Native agent investigating bounded synchronous read-only metadata ABI; UIagent only new manualmain offline, codec only YUV source plan offline.

## 2026-10-12 09:23: v11 and lowres UI review-d completed; no active device operation

- Source091537 v11 finite20/467589120B/fullSHA0acadc1ba13f3b33fb18a79156a6b0b48a8e097be1637fc6cf8e78d87a479e93 and native stop/restore/fullreadback PASS. All source modes remainHOLD/released[]. No active source/UI experiment. User-requested keepawake remains.
- outputs/ui-review-d-0919/report.json and extra-acceptance.json PASS: permissionSSDframe+restore; existingUIhandler record/red -> newclip -> latest single idle -> explicitPlay -> native release_complete17ms -> realphoto handshake -> Menu -> stockrestore. NoQMLerrors; service19329 unchanged acrossUI, finalGUI23691/running/Active/None/errorfalse/systemro. Host session88150 and post-run readback23904 exited0.
- Newclip X2V_20261012_012034_22528_1:49frames/1.633333s,1300x970 H264/yuv420p,2605198B; SHAfddef99a054ba14ddde10ee05d27c1f12ebb3d2ac71e4150004d8773a18ac34e device/hostmatch; FFmpegfull decode0errors. UIrequest3s is not3s saved duration. Localmedia outputs/ui-review-d-0919/fresh-recording.mp4.
- Programmatic lowresUI chain proof only: physicaltouch/keys and originalDCFvideoindex remain unverified/unimplemented. Thumbnail correction: saved-event empty was transient; catalog_after has actual PPM/pendingfalse. Native thumbnail readback completed (session26532 exit0),512x382 RGB/586767B/SHA4d51fd0d5781d239e5df6a24ccc4eeee7e61f1d52ef041dad25ce8974cdbdbbf device/hostmatch; root viewed losslessPNG. Host6Qt refresh PASS is separate from unobserved deviceImageReady. Photos/videos merge atUIlevel; hardware shutter recording notconnected. PermissionBMP saved/hashchecked, view_image doesnotdecodeBMP, no new visualacceptanceclaim. FactoryLiveView missing from Qt screenshots remains knowncaptureboundary.
- UIagent updates independentstatus only; codec prepares highresYUV-to-HEVC plan; native prepares metadata/CFA plan. Next camera experiment needs newcandidate, not unchangedv11 repeat. Root solecameraoperator.


## 2026-10-12 09:20: v11 capture/readback PASS; UI review-d is sole current device owner

- `source-isolated-091537`:20 contiguous RAW frames3920×2946,467589120B, fullSHA0acadc1ba13f3b33fb18a79156a6b0b48a8e097be1637fc6cf8e78d87a479e93;20uniquehashes,IDs986–1005,dropfull/busy0. Actualcopy8.123ms/writer26.789ms/CPU7.314ms/fsync4.084ms; armclose961.651ms/writerdone992.084ms. 19CPUdeliveryintervals950.091ms≈19.998/s, notlongrecord orcertifiedsensorfps.
- CPUclosure/native stop1/wholeteardown ACK0+Max/manual15033 parentreap/stockframe468→620/fullreadback allPASS. Rawanalysis preview looked coherent blurry scene; noCFA/FOV/realADC/DNGclaim. Allsource modes nowHOLD/released[]. RX/newpacket unchanged/frozen. Finalpostreadback health in outputs; don't repeatv11 unchanged.
- Root host session88150 now owns `persistent_ui_review_d_test.py --phase all --execute --output native-video/outputs/ui-review-d-0919`. Preflight runs first; noothercamera actions. Newd freeze babe3f60...a3e89e9; newhostc479abfa...6c1c2b8 fixesexactfile:///URI mismatch andaddsrejectsource/IOlocks. 11focusedhost/8contractPASS, GUI runtime/controller/loader byteidenticalc exceptfreshIDs+nonce. Waitsamehandle and run d/verify_result.py aftersuccessfulreport; physicaltouch/keys notprogrammaticproof.


## 2026-10-12 09:15: v11 bounded DIRECT source capture dispatched; root sole device owner

- Current host shell session11445 is executing `isolated_target_ring20_v11_direct_test.py --execute`. Do not redispatch or issue HblShell during source transition. Native controller/watchdog own cleanup; observe same run only. Global release exactly `isolated-target-ring20-v11-direct` until same-run readback, then revoke.
- Finalpacketfreeze a84d844100234eb404bd8ee77c9af59294c025974f5c169ec86744f181b07014; RX40b4bb88a06fe23d27ecf17ca0a6fee129785716ac4dce97e9e02367a0467a47 stagedPASS `source-target11-direct-stage-091209`; systemro. Native source/ELF/packet reviewGO; actualC19, parser20+33, readback7, mechanical12PASS. Samecached17 mode/config/lease/stop/restore; 1s/20max/3slots, onlyrequiredDIRECT writer+diagnostics.
- Freshpreflight service2032/gui13510/factory29101, bootf6668de2..., frames160100→160157, active_errorfalse, MemAvailable407876KiB/systemro/4locksabsent.
- UIreview-c permission phase FAIL by hostobserver URI mismatch (`file:///data/…` vs `/data/…`), no recordarmed. QML token/confignonce reads succeeded; stockrestorePASS/service2032unchanged/gui13510, bridgeidle/terminated. Evidence `outputs/ui-review-c-0910/report.json`. Fixednewidentityreview-d+newhostrunner being prepared offline byuiuxagent; c remainsfrozen. FixedsystemGUIloader stagedPASS `persistent-loader-stage-090943`.


## 2026-10-12 08:48: exact RAW-sized ordinary-file comparison PASS; direct writer candidate starts offline

- Root staged and ran new ordinary-file helper once. Stage `frame-io-stage-084557` PASS/installed_readonly; test `frame-io-084633-8374eb4f` PASS. No sensor mode change. Source081929 RAW first3frames, two exclusive new70,138,368B outputs. Exact512-aligned requests succeed even framebase modulo4096=0/3584/3072; no padding/fallback. Full buffered-pread memcmp afterfsync passes both cases; not forced physical-disk read. Source full210,415,104B SHA/dev/ino/size unchanged before/after.
- Buffered pwrite framewall261.851/237.848/203.479ms, mean234.393, threadCPUmean121.894ms, fsync23.476ms, threeframes+fsync96.522MB/s. RequiredDIRECT framewall34.804/38.403/26.042ms, mean33.083, threadCPUmean6.982ms, fsync5.996ms,666.432MB/s. ActualARM64DIRECT0x10000; flagswrite0x20002→0x30002. This fixed-order3frame ordinaryfile benchmark differs from active receiverwrite; not videoFPS/longwriteproof.
- Stockservice2032/gui2978 unchanged, frame77841→78294, Active/None/Still16bit/CropNone/errorfalse/systemro. RSS74208KiB, postMemAvailable403120KiB. IOlock released,3imaginglocksabsent. No camera operation running. Allsource modesHOLD/released_modes=[]; ordinaryfile host EXECUTION_READY revertedFalse after consumed test. Retain own~140MBoutputs; no reason to repeat unchanged comparison.
- Helper path `/system/bin/x2v_frame_io_20261012a`, SHA9b050af87da08f4473236bc2e9c1e8ce978df847bf897b6795d2141e8fa513c0/47752B, standalone no vendor/privateinit. Freeze3027175f2b6ec06cff287a026612586baca3d0115cb4357f6e173fc753f32f0e,34files rootverified.18 actualC ASAN/UBSAN +32 rootrunner offline mocks reviewed; helperhostDIRECT0x4000 is simulation, productionARM64uses0x10000. Root found/fixed parserflag assumption beforeexecution. Finalreview at research/full-fov-pipeline/ssd-frame-write-compare-review/; root-release.json binds exact releasedhost6950dff0…606430, now back to reviewedHOLD87b92e8e…f8703d.
- Codec now unique writer of new `receiver_v11_target_ring20_direct`; native_album independent reviewer. Keepv10/cached17 lifecycle/sourcegraph/config/map/sync/unmap/callback/1s20cap3slots untouched. New4096alignCPU pool/no stridepadding, ownedfile requiredDIRECT, pinnedBionicpwrite/fsync,32retry/shortalignfail,writeCPU/wall/fsync/flags/provider diagnostics. Version11/newtoken/newpath; not built/staged/executed yet. Root must prepare new controller/parser/readback packet only after receipt contract settles, then independent review and explicit newmode release. Never mutate frozenv10/cached17.
- UI canonical clock-scope fix: CameraExtensionSHAfd2080eb47f2d8cb20684e0656e01eefbe35d147030a3203cb1588a73b91d57f,10focusedQtPASS,6extensiongroupsPASS; photo mode restores stockvisiblebinding. Not installed. Agent UI preparing a new d/f merged-album candidate on persistent-session-system for lowres fullnewIDrecord→Playback→Play→Stop→photo/restore acceptance; no device/controlleredits. Existing runtime/main is video-onlyfallback, do not accidentally use it as mixedalbumintegration. Physicalshutter wiring and physicaltouch/wheel acceptance stillopen.

## 2026-10-12 08:23: cached17 capture/config/restore/readback PASS; copy 30x faster, writer is next

- `source-isolated-081929` fully PASS/body0/recovery0; 9 frames/210415104B; RAW SHA `cb86ea7b0b02956a44439210c7b2b07c899b35496b07c6fcf9b09b22b43ceb24`. Nine unique frame hashes, complete per-frame readback and container analysis; root viewed four representative full-height gray frames without obvious block corruption. This is limited image evidence, not a general coherency/CFA/FOV/DNG proof.
- Actual flags17/getters0 on every captured frame, unchanged frozen v10 RX. Copy wall mean8.587703ms/range8.099219-9.066927, thread CPU mean8.279282ms; previous flags0 mean264.918ms. This controlled configuration change removed the dominant mapped-source copy cost in this short run. All CPU quality flags1.
- Writer mean160.988744ms/range133.998959-204.147656; drop_full11/busy0. IDs1003/1004/1005/1006/1009/1013/1016/1019/1022; first three admission intervals about50ms, later150-200ms. One-second window saved9, writer done1544.314ms afterA; no sustained20fps claim. 3-slot buffering does not solve serial writer throughput.
- Full native stop1/wholeteardown ACK0+Max, manual29729/start935970 parentreap, stockframes472->622. Post-readback active_errorfalse/Active/None/Still16bit/CropNone/systemro. Stockservice2032/gui2978/factory29101; bootf6668de2/ADB2676 unchanged. All source modes returned HOLD/released_modes=[] after readback; no device process running from this experiment, no repeated cached17 trial needed.
- Codec completed `research/full-fov-pipeline/cached17-performance-081929/` audit; README97aaed5a58ceba2c4e5017931d00e40520c69689ef759c0d5fe2889dc56eb6b7 / receipt9598a6bf8bd1a2cebc675f2816ece07d09617304cf22ef8120232d7de7e6f414. Root verified manifest. Same RX importswrite@LIBC, no runtime write-provider or F_GETFL snapshot. Current shell3<> and RXdup have noO_DIRECT/O_DSYNC setting. Existing SSD2GiB benchmark used4MiB/4096alignO_DIRECTpwrite; not directly comparable. Next: small ordinary-file buffered-vs-requiredDIRECT comparator, actual FD flags and separate writer CPU/wall/finalfsync; verify exact address/length/offset alignment. Framebytes23379456 divisible512 but mod4096=3584. No silent fallback or invented per-frame padding. No new writer RX/helper exists yet.
- Runtime packet/config and preflight pins remain as the historical08:20 entry below; do not change frozen files. The next experiment must be a new reviewed candidate. No firmware/boot/init/security changes were made.

## 2026-10-12 08:20: historical cached17 dispatch (completed at 08:23)

- Run `source-isolated-081929`; root shell session5451. Camera ownership is in the native controller. No concurrent camera command or repeat trial. Host `isolated_target_ring20_v10_cached17_test.py`.
- Packet freeze `f132c90884b043f05c6a9b3a8897b309b6b89b9b2b8f32f360cb6cbd1430b20d`; unchanged RX `1d262e00bbbb08970a2295d49e1f9ca0ea51fea9890a8a50f8e5048e81a2627b`. Only target RAW config adds vmem_flag17 in a new owned process/pool. Native narrow review GO; root exact diff and all final hashes verified. Same 1s/20cap/3slots/native stop/restore.
- Global release currently permits only `isolated-target-ring20-v10-cached17`. If capture/restore pass, use `isolated_ring20_v10_cached17_readback.py --run source-isolated-081929 --execute`, then revoke release. Analyze with existing `inspect_raw_ring_v10.py`; receipt stays version10.
- New flags gate follows safe CPU closure and strict capture, and does not block safe cleanup. Native conditional review and exact packet audit: `research/full-fov-pipeline/cpu-copy-memory-audit/cached17-bounded-trial/`; packet-review SHA `1bf531f7e15630f8856f88e13bef9e056d51a4ccab78e97d6b861e9bdb19ef75`. Same-heap repeating SOUT2 native17 precedent and original64B sync length verified. No live remap/flag mutation/firmware flash. Await actual outcome; no speed/coherence claim yet.

## 2026-10-12 08:04：v10 实机短录/原生恢复/读回 PASS，主要耗时是映射源CPU复制

- `outputs/source-isolated-075947/report.json` PASS/body0/recovery0；`ring20-readback-report.json` PASS；4帧93,517,824B，SHA **60b01678beca9df871bef45c33ce5d420c6ae66d17a7d44090075ccbac92f8a6**。逐帧/data中转，临时chunk清完，SSD原样保留；raw IDs992/993/994/999，geometry3920×2946/stride7936/RAW10001，4hash各异。
- copy wall262.270/267.938/264.878/264.588ms；THREAD CPU253.036/256.757/254.864/255.268ms，4个quality1，wall-CPU约9–11ms。原libc提供者pin1，offset0x1e590；4帧get_flags/get_fd rc0、flags0、FD361/362/363/361，src/dst mod64全0。不是主要离CPU调度等待，原libc并未提速；仍不直接断言kernel页缓存属性。
- 1s admission实际4帧，CPU入队跨度798.436ms/3intervals=3.757/s；非sensor exposurefps。arm→close1002.398ms，writerdone1240.936ms。drop_full/busy0不证明上游无丢帧；HALunmap0，fsync1，seen89/rejected0。
- 既有native生命周期全部通过：stop1ACK0、whole teardown ACK0+Max、manual20645/start817747 parentreap、stockframe479→630。stock service24824/gui25746/factory29101，boot仍f6668de2/ADB2676；systemro，三锁clear。所有source mode已重新HOLD，禁止原样重复v10。
- 最终packetfreeze4f4053930275cc2a22bc0742972f519453b0c677d9c1fcb29f79dedac558dfa7；RXfreeze92f1b818f4429dc43fc7ba4ece1c20096b30206277c9910a221a9e56d8d915c9；RX1d262e…2627b，root40RX+12packet文件pin复核。controller8037272b…edc/bootstrap62ce2d9d…ed5，native/UI独审，runtime冻结不再更改。
- root已运行`inspect_raw_ring_v10.py`，`ring-container-analysis/report.json`及4帧全高灰度preview已看，真实场景有细微变化；仍不称CFA/ADC位深/完整FOV/DNG或4K实时录像。codec离线整理本轮诊断；native_album追确切pool分配/原生cache维护。没有v11，没有cachebit/remap/DMA提交。

## 2026-10-12 07:56：v10 RX 实际 ELF 审核与 stage PASS；等待最终冻结控制包，尚未采集

- 新receiver目录`native-video/experimental/source-receiver-adapter/receiver_v10_target_ring20_libc`。13实际C ASAN/UBSAN focused全部PASS，report SHAa1266fc5518315bd0086506ceea8aadf81f576acddb9bdb6575e4a1a478a1f7f。包含CPU API失败、diagnostic getter失败、写盘阻塞、stop、跨时钟域skew。原Mac微秒量化引发两fixture失败已明确定位，最终host用真实UPTIME_RAW；生产仍MONOTONIC+THREAD_CPUTIME。新copy_cpu_wall_consistent只质量指标，0不妨碍有效RAW，原ns不夹值；API失败或同域倒退仍失败。
- target ELF SHA **1d262e00bbbb08970a2295d49e1f9ca0ea51fea9890a8a50f8e5048e81a2627b**，911936B。native独审GO，root15sources/headers/providers现SHA复核匹配；恰好8hook+3helper导出、无弱libc函数外露、37真实provider imports。payload调用预绑定/验证原libc memcpy，get_flags/get_fd同lease仅读无close，原map/sync/copy/unmap/finish/originalcallback顺序不变。provider绑定在token+FD门之后。
- `outputs/source-target10-ring20-stage-075314/report.json` PASS，唯一路径`/system/lib64/libx2v_mode21_ring20_20261012b.so`，stock前后不变/systemro。**target v10 尚未执行**，所有source mode仍HOLD。等待codec receiver freeze与UI最终packet机械pin；不得拿hardHOLD骨架执行或复用v9原样测试。
- 新packet`source-session-isolated-target-ring20-v10`解析器13actual C+26变异、4读回mock PASS，handoff SHA4561435f3c61ebc90a136d9f41c5d8f2670c194694c55e687fe8b03e4a402300；controller草稿dc851bf7…c3ea仍硬HOLD、RXpin pending、未freeze。UI正在移除临时硬HOLD、写确切RX/controller/bootstrap pin，保留全局release gate。root唯一设备操作者，子代理全离线。
- root已新增`local-verification/inspect_raw_ring_v10.py`离线像素+wall/CPU/quality/flags诊断，未执行，无既有v9数据改变。
- 缓存契约补充在`research/full-fov-pipeline/cpu-copy-memory-audit/ALLOCATION_CONTRACT.md`：原厂配置CACHED/NON_CACHED及vmem_flag接缝真实存在；可选CPU zero→sync写路径有证据，但target/kernel DMA维护契约未全闭合。先v10实读flags，不ORbit、不remap、不直接配置cache改变。


## 2026-10-12 07:36：纯 RAM memcpy 基准实机 PASS；不能将 RAW 207ms 归因于旧复制函数本身

- 新独立Bionic CPU helper SHA **31daa19d028bfe097dacfb7f4ff4144cedb9e1db21f88bb0763fe8065bf83882**、28440B；`receiver_v10_target_ring20_libc/benchmark/build/receipt.json`。实际PT_INTERP `/system/bin/linker64`，仅libc/libdl、无init/fini/vendor/意外导出/NXstack，old v9 exact228B隐藏asm原字节2398bd8c…7557。root/native独立源码/ELF审核后stage `cpu-memcpy-stage-073423` PASS，唯一路径`/system/bin/x2v_memcpy_bench_20261012a`，system恢复ro。
- `outputs/cpu-memcpy-073500/report.json` **PASS**：pureRAM两槽46,759,040B，每case3次23,379,456B复制+逐字节核验，峰值RSS47268KiB。旧exact对齐wall16.059/cpu9.599ms、错1B17.093/10.202ms；原libc对齐15.258/9.289ms、错1B17.270/9.071ms。原libc真实provider `/system/lib64/libc.so` +0x1e590验证。这里只能证明普通内存带宽，不证明实际v9GOT绑定/ION缓存或captureFPS。
- 原厂service10358/gui11288未变、取景68256→68398、Active/None/Still16bit/CropNone/active_errorfalse/systemro/三锁clear；无相机模式改变。CPU4s/alarm8s/AS128MiB、outertimeout10s；结果cpu/wall包含拷贝区间，填充/校验不算。
- hostrunner`local-verification/cpu_memcpy_benchmark_device.py` SHA38faf543c74a56e6feddf4954d58a1c07d6d85752226185d1b5e0954a1c6773e，default无device；1valid/14invalid schema门试验。修正初稿provider字段为真实copy_provider_*，实机4cases完整通过。
- 新结论：v9真实RAW每帧203.733–209.651ms远慢于普通RAM，旧弱copy也能~16ms，所以**不能将主要瓶颈简单归因weak memcpy**。v10仍收紧导出/明确原libc，但重点新增线程CPUtime、HAL原flags/getfd及对齐诊断，区分真实buffer访问/调度。codec唯一写新v10，native独审；UI已造HOLD骨架等待actualC ACKfixtures。所有target执行继续HOLD，无bench重复需求。


## 2026-10-12 07:20：v9 一秒 RAW 环形短录全流程 PASS；5 帧，瓶颈集中在 CPU 复制

- `outputs/source-isolated-071109/report.json` PASS/body0/recovery0，`ring20-readback-report.json` PASS。3920×2946/RAW10001/stride7936/plane2946/offset0，5帧116,897,280B，总SHA **ceb8acbccec952b976b053a61193de81d884ee385b58df95bf56c83d68aa4940**；5个单帧hash各异。逐帧/data中转+host exec-out held-inode完整校验，临时data chunks已删、SSD原样保留。
- IDs1015/1016/1017/1020/1025；raw timestamp5303115383/5303165383/5303215400/5303365400/5303615400。CPU admission跨度832.793229ms、4个间隔均值折算4.8031次/s，不能当传感器曝光帧率。1s窗实际5帧，**未达到20fps**。
- 每帧23,379,456B复制203.733/208.530/207.161/209.651/207.031ms；写151.419/220.725/208.793/200.782/153.703ms；HAL size/map/cache前置0.008–0.183ms。3槽有复用，drop_full0/drop_copy_busy0，不能由接收端drop0推出上游无丢帧。arm→closed1001.573ms，writerdone1273.830ms。
- state5/error0/rc0，copied=reserved=written5/fsync1/capture_success1/stopreason1，seen92/rejected0/unmap0。CPUclosure、原生stop1ACK0、wholeteardownACK0+Max、manual6085/start525964父回收、stock frames460→611分别通过。原厂service10358/gui11288/factory29101，bootf6668de2/ADB2676、systemro/三锁clear；keepawake532/host93522未变。恢复后4CPU1.6GHz仅stock样本，不是录制时钟证据。
- v9 ELF **c7c589b698f94fa1e357e22926f4a0b63e1443ab1e347b28ca0993fb4cd8a5f6**，freeze cda42915d68568b9ece0b2893f6c19b2fb893d6a06d76e0baf181af8fee94ca0；controller3e1931f00ff979b5967c16ab9a45c51efb1e38af93bec608bbabf30e0db8ca9e/bootstrapf35599575d595cbf3059037f027e6ce3a98afefa28c8dbee9c4dc2cf44af12ae；installed`/system/lib64/libx2v_mode21_ring20_20261012a.so`。29实际C+41gate+5readback故障测试先通过。冻结v9文件不改。
- source全部HOLD/released_modes=[]，不原样重复v9。codec离线发现插件585个defined dynsyms，包括多种WEAK DEFAULT compiler_rt内存函数；memcpy本体32B SIMD循环从+1开始失对齐，但**实际GOT绑定未证明，不能认定200ms全因此产生**。v10离线收紧导出到审定hook/helper，显式验证原厂libc memcpy提供者；另做纯RAM有界benchmark。native_album独立追原生ION flags/映射和复制契约，暂不改cache属性/DMA。
- `ring-container-analysis/ring-preview.png` root已看全高场景诊断；RAW10001原厂枚举是RAW16_OPAQUE（`research/full-fov-pipeline/target-raw-format-evidence.json`），低4位0不能当真实ADC12bit/CFA证明，未确定活动区/CFA/光学全视场，不造猜测DNG。


## 2026-10-12 06:46：v8 同次启动三帧全流程 PASS、读回 PASS；准备固定环形缓冲短录

- `source-isolated-064319/report.json` PASS/body0/recovery0，`sequence3-readback-report.json` PASS。三帧ID1013/1014/1015，raw timestamp3632423416/3632473416/3632523416，delta50000/50000、ID差1/1。RAW10001，3920×2946/stride7936/plane2946/offset0/1plane，87callbacks/rejected0；三帧70,138,368B，总SHA3943edd1cdaa87115c4705af8c9926d6f0af38820390f14313dc82c7d92de51c。单帧hash见读回report。原生时间单位仍有dispatch/metadata override未决，不称20fps。
- CPUclosure/drain0、callback0、hookclosed1、stop1ACK0、wholeteardownACK0+Max，manual27473/start359011 Z→parentwait1→absence，stock frames480→631，三锁clear/systemro。stock service31632/gui32557/factory29101，bootf6668de2/ADB2676；keepawake重建native532，host93522/baseline300保持。
- `sequence-container-analysis/sequence-preview.png` root已查看三幅全高灰度诊断内容，哈希不同；仍非CFA/ADCbitdepth/FOV/视频编码证明。新离线分析脚本`local-verification/inspect_raw_sequence.py`。
- v8 RX d9d13460d2e1a98d57f4ac801c3850da56f7f4c271938c6a06524ad19c552179，freeze e7cba0e510c568f5b84eae2f629d618e6aa21f16e5ec57ddcaf47b7989e5f1db；stage064142 PASS，新路径`/system/lib64/libx2v_mode21_sequence3_20261012a.so`。controller900b8572a4541a6fc3814b70a30f056081e833696b1bd33c9c1679998bb94235/bootstrapf78c2fb815235812bcded1183b4bf5204df8fe2fe0964282077463a6c1620f13/packetfreeze be403054068680a0646814f094faa28c69f8a507f167dbc9a56afed913798be2；独立final-packet-receipt SHA2a0247497875f9ab77f3a0c1ca689420d6e0b64a3b46a2d8e006371e997d7b49。
- 3槽prefault+目标图setup后A前MemAvailable383296KiB，超过131072门。不是后续内存保证。所有source modes重新HOLD，禁止原样重复已过v8。codec正在写v9设计：3槽复用，满槽drop，固定1s或20帧先到停止，最多467,589,120B，增加CPU monotonic和帧元数据；尚未实现/上机。native_album离线追BOUT timestamp dispatch。


## 2026-10-12 06:20：fullrect v7b 完整PASS；目标源两次实机取帧，开始独立v8三帧实现

- `source-isolated-061645/report.json` **PASS/body0/recovery0**，RAW frame994、timestamp2037397150、seen86 rejected0；3920×2946/stride7936/plane2946/RAW10001，23,379,456B。`raw-readback-report.json` PASS，SHA **551634cbc44ad8777341112fd85ae39324f220d520992a5e09609c8bd02e9c79**，容器分析`container-analysis/report.json`低4位0/644种值；不是已证CFA/位深/FOV。
- v7b仅修receiver_frame先等完整closure再strict分类（8实际mksh tests+native独审）：controller dcd91227…b22d9/bootstrap ceb51610…e8624/freeze22108860…39c33；RX继续已stage f94dbe6c。stop1/wholeteardownACK0+Max，manual17919/start199561 parentwait1/absence，stock frames488→637。原060949 false不改。
- stock service21994/gui22931/factory22373、bootf6668de2/ADB2676、systemro/三锁clear，keepawake23207/host93522/baseline300。source全部HOLD等待新的v8，不能原样反复验证已过的single-frame。
- codec正在独立`receiver_v8_target_sequence3`实现固定3槽/一次A/无slotreuse，总70,138,368B；新token GROUP13_MODE21_RAW_SEQUENCE3/version8/独立capture和CPUclosure。root制controller、计划graph13setup后A前实读MemAvailable>=131072kB（包含已prefault槽+目标native分配），不足不arm并原生收尾。stock内存样本347028kB available仅参考，不能代替targetheadroom。
- native_album在追timestamp生产者单位，codec另有fullrect word/CFA候选分析；frame时间值与uptime×1e6一致尚不等于单位已证。三帧仅两interval，不当持续FPS；mode request20/1仍只是请求。

## 2026-10-12 06:13：首帧 fullrect RAW 已读回；原生完整恢复PASS，控制器两读竞态待修

- `source-isolated-060949` fullrect RX f94dbe6c/controller d5d5452c/bootstrap ada60158：frame976、timestamp1620527450、RAW10001/3920×2946/stride7936/plane2946/offset0/1plane、seen86 rejected0，CPU closure/drain/unmap全0。
- controller原整体报告仍FALSE/body5/recovery0，不能改写。`receiver_frame`先strict读空、再terminal读到成功结果却误判terminal_without_frame；后续stop1 ACK0、whole teardown ACK0/Max、parent reap/absence、stock取景484→635完整PASS。UI子代理正独立派生v7b，仅先等terminal后再strict分类，旧freeze不变。
- root新`reconcile_fullrect_060949.py`核精确本run收尾与stock当前健康后，SSD→临时data→host读回23,379,456B，SHA **a501aeed547c888aed7713c11370876f0cfeb27cf92fc33dc540478539a9b814**。`diagnostic-readback-reconciliation.json` PASS且original_session_passed=false，原SSD保留，临时data副本删除。
- `diagnostic-container-analysis/preview.png` root已查看：2946行整体有室内场景和上下结构，非空白或只有986行；u16LE低4位均0，904种值，不能据此宣布有效12bit/CFA/FOV。codec独立分析活动区/时间戳单位，未确认前不造猜测DNG。
- stock service15614/gui16542/factory15992、bootf6668de2/ADB2676，systemro/三锁clear/noactiveerror。keepawake新16812/host93522/baseline300。所有source modes重新HOLD，待v7b审查后一次repeatability。

## 2026-10-12 05:54：双engine修复实机已过；目标模式启停恢复PASS，RAW有效高度986未达目标

- 新packet`source-session-isolated-target-two-engine-v7`：controller25685940/bootstrap75c76dc8/guard3ee3a8d8，当前ADB2676/bootf6668de2。单combined`libx2v_mode21_twoengine_20261012a.so` SHA0a22addc…98b9f，stage054818 PASS。source2文件v2独审与16actualC tests、packet18actualAWK cases通过；所有其他生命周期保持旧逻辑。
- `outputs/source-isolated-055020/report.json` **overall FALSE/body5/recovery0**保留。manual3880/start41081；正常取景frame465→615，primary_imx861与tof_ads6401均登记，无second_engine错误。447s setupgroup13ACK0，HB24driver17 prepare20/1日志通过（非实测fps），451s显式A。
- RXseen282/rejected282，RAW10001、width3920、**height986**、stride7936、offset0、**planeheight2946**、planes1；无accepted frame/无payload。高平面分配不等于2946有效图像，不能放松shape冒称高分辨率。CPUclosure0/closed1/active0/drain0/unmap0；stop1ACK0+wholeteardownACK0/Max，父进程reap，stock恢复frame464→613。kernel447.761473导出BOUT0首帧905。
- `lifecycle-reconciliation.json`独立记录上述模式启停成功及capture未过；stock service8443/gui9351/factory1044，当前systemActive/noactiveerror/count5283，/systemro/三锁clear。keepawake3019/93522存活；本轮没有factory崩溃或整机重启。hostHOLD重新released_modes=[]避免原样重跑。
- codec正查conf/topology参数，native_album独立查frame descriptor有效height来源。现阶段任务是找2946平面内为何valid986，区分producer实际输出/metadata/ROI；不得先改变报告尺寸。已pull055020完整device-run与新bootkernel。

## 2026-10-12 05:47：target失败后的原厂完整恢复已完成（正常重启），新双engine候选仍未执行

- `outputs/source-isolated-052532/manual-restoration-reconciliation.json` stock_restored=true，原测试/自动恢复仍false。公开system.reboot_system从Fail进入PrepareShutdown；camera/storage.can_shutdown均true后，仅两条自有同名x2v-debug-session wake lock阻塞，按原API逐条释放。没有改Ready/critical ACK、没有force/sys.powerctl直写。
- 原厂重启后boot **f6668de2-2070-4793-9cbd-6cfbb7adc2bf**（旧79cd…），stock service365/gui368/factory1044，原三SHA匹配/systemro。重新临时enable-adb；原厂USB连接提示CODE40/Ackable通过指定ack_error处理；set_live_view成功，Active/None/Still16bit/CropNone，frame129→239，systemActive/active_error=false。三本run旧锁精确匹配owner后释放，未写假的restored/CPU/native停流成功。
- ADB新组为 **/uid_0/pid_2676**，旧2279包不能重跑。保活重建native3019/host93522/baseline300；没有持久启动配置。新target双engine v2草案16个ASAN/UBSAN已通过，native独审BUILD GO，codec正在独立新ELF构建；所有source执行仍HOLD。

## 2026-10-12 05:40：普通group13真实RAW全链PASS；target启动ToF误拦截，恢复仍待解除原厂Fail状态

- `outputs/source-isolated-051920/report.json`及`raw-readback-report.json` PASS：corrected `disp_null/FlterDmp` selector取frame1029，RAW10001、3920×986、stride7936、7,824,896B；SSD/data/host SHA d80099dd63caa5b255865974d022a41a8756ef01391f557a689a63a7fb61ed52一致。CPU closure/drain/unmap0，native stop1 ACK0+whole teardown ACK0/Max，parent reap，body/recovery0，stock frame433→579及锁清/systemro。不是目标3884×2914或无裁切证明。
- `outputs/source-isolated-052532/report.json` FAILED：targetcombined d5d882d2/controller9297eaf6在原厂`_setupTofGroup`启动中被自身second_engine门误拦后SIGABRT。未进入group13 setup、未A、无目标帧/CPUclosure，body70/recovery1；不能将这次称安全停止或高分辨率模式失败。完整日志/报告保留。
- kernel证明core完成，精确15002/14719/14931随后kill0均ESRCH，root通过一次原厂ctl.start恢复service19666，再native核旧三PIDabsent、原厂三SHA相同、systemro、启动原厂GUI21611。factory16737。native state cameraInitialised/suNormal/流idle，**system_state=Fail(5)**保留导致set_live_view true返回Invalid system state；所以还不能说取景完整恢复。正在查原厂正常恢复/重启路径，不直接改Ready绕fault。
- 全部source modes重新HOLD/released_modes=[]。codec两文件engine角色草案按exact SP/cfg+80/out+2e0区分IMX861主与ADS6401ToF，独立审查要求duplicate/failed registration sticky失效，修闭与focused ASAN测试进行中；未build/stage新target、禁止重跑旧target。
- keepawake旧native4808在factory崩溃中丢失，host40187仍在续租，screenidle0/Active；待原厂完整恢复后重建watchdog（baseline300保留）。三旧run锁仍封存，未伪造restored或释放。

## 2026-10-12 05:17：正常group13模式启动/停止/恢复PASS，RAW回调选择键定位修正中

- `outputs/source-isolated-051150/report.json`完整取帧仍FALSE，body5；不改成PASS。独立`lifecycle-reconciliation.json`记录setup13 ACK0、CPU closure0、stop1 ACK0、whole teardown ACK0/Max、parent reap及stock恢复0、frames441→585、三锁clear/systemro。stock service3581/gui4525；factory15353在初始化期间崩溃重启为32463，但隔离controller30476/manual30771持续完成全流程，keepawake重建4808。
- RX v7 RAW-normal已显式A，trigger/armed1、expired0、seen0/rejected0、state7，没有保存RAW payload。kernel原始snapshot明确40859.557651（对应setup13）`vdev<bout0>_wp ctx[0] export 1st frame done, frame_id(851)`。这是底层export证据，不是CPU RAW/像素/FOV证据。
- codec离线已定位原厂`listen`style2在frwk194c38–4c用filtername/`FlterDmp`调用同一dump函数；旧接收器选`disp_null/inport0`只适配push/pull分支，因此seen0不等于全局hook没进入。新独立listen RX候选制作中，仅改selector，完整shape/HAL/WAIT/A/D/closure不变；root未执行新候选。旧研究disp-null-portdump的inport0建议已被这份精确分支证据纠正，不能继续按旧文本执行。
- 旧normalgraph packet0c0db393/f07ee48e/865d经过3线审查并实测上述native生命周期；修正Max门必须whole-teardown-confirmed，stop1不能冒充。所有source modes目前重新HOLD，只保留先前成功carrier release；等待新listen RX固定SHA再发一轮。原始failedreport/CPUreceipt/log全部保留。

## 2026-10-12 05:01：隔离v7b正常模式整链PASS，稳定取景后真实帧799读回

- `outputs/source-isolated-045850/report.json`及`raw-readback-report.json`全部PASS：新controller897e0570…8308、bootstrap552826b0…d8db、data-onlyguard865d…、receiver8ecf…均固定。bootstrap先迁入ADB组、同PID exec，三owner封存ACK后才停stock。manual21647/start4062230，Active/count421→565与clone证据之后显式A，frame_id799/seen814/22,004,736B、trigger_seen1/capture_armed1、expired0，HAL unmap/CPU drain0error。
- RAW已readback路径`outputs/source-isolated-045850/raw-7408x1482-stride14848.bin` SHA **d945e4a5c1491c7e65bcc0d21493408a8ea4f6d185c6914b73e7a7949a036715**，SSD→data→host相同，仅data重复copy已删。不是旧启动frame1，codec正在独立检查像素结构；尚未证明CFA/目标高分辨率/持续录像。
- native set_live_view false/Max255确认、parent实际Z→waitrc1→Absent完成，body0/recovery0。stock恢复service24974/gui25925、frames437→580、Active/None/Still16bit/CropNone，三锁clear/systemro；factory15353本轮没有崩溃，keepawake15479仍在/host40187续租。模式接入普通源的启停/恢复闭环已过，仍须新的group13/target实测。
- 前run045504的v7最初在任何owner锁/停stock前因bootstrap PATH只/system/bin而找不到/sbin/awk，preflight拒绝；保留failedreport和nativeBOOTSTRAP_EXITED/stock6716/gui7199/count110624/locks clear receipt。新v7b只固定实机验证的原厂PATH=/sbin:/system/sbin:/system/bin:/system/xbin并重pin；旧freeze不改。新host启动拒绝可快速结束，不重跑旧packet。
- root接下来从正常隔离v7b派生`source-session-isolated-graph-v7`：C:G:RX+ownedFD5/6 config，normalActive/count后quiesce→group13原生setup自动start→确认Off/None/group13后A；drain后stop1/teardown确认Max→reap→restore。nativewatchdog150/host200/guard270预算；receiver40s不重启。仍HOLD/无group13执行。codec新v7 raw-normal b52b3e9f…f17b、targetcombinedf710beef…d07c编译18checksPASS待freeze，尚未stage/load。

## 2026-10-12 04:54：native跨factory组迁移/重启存活已实机PASS；隔离v7整包待一次source短测

- `outputs/source-passive-044437/report.json` PASS：native helper15275/start3976124/PGID=SID15275，经5秒fresh challenge窗，ADB仅迁这个自有PID，从factory31629组→既有ADB组/uid_0/pid_2279，SELinux仍u:r:hbl_camera_service:s0。factory31629→15353重启后helper存活、DBus两次0/0，原厂service6716/gui7199同PID，帧70437→70659。认证stop后done与native可见ABSENT，systemro。keepawake新15479/host40187/baseline300。
- 原新leaf mkdirPermissionDenied不绕过；现方案不新建/清理进程组，不修改SELinux/init。仅隔离camera-test清理，与adbd仍共享命运。numeric PID attach有残余退出/复用竞态，host在实际write shell内二次核fixedclock窗/stop，单次写、不重试。此前`source-passive-044057`因内核不存在/proc/.../children在ready前HOLD，未attach/restart；native确认helper退出。b改为Threads1+taskglob，nochild仅冻结纯builtins路径静态证明。
- 最新controller固定`experimental/source-session-isolated-carrier-v7/controller.sh` SHA17867bc0…57aa8；bootstrap3e1d5d32…6694内置pin；data-only guard865d43a0…ecf0没有任何ctl/start/kill/nativePID查询，270s仅写abort；原生watchdog90s在ADB组持有DBus与恢复。bootstrap在锁/孩子前验迁移；owner.group/PGID/SID和历史factory.group拆开。原stock恢复继续核init组，native quiesce→reap→restore链保留。9 hostreceipt parser检查通过，完整source设备链尚待。
- 新receiver v7 explicit arm SHA8ecf0585…ca8c，constructor只WAIT预分配，正常Active+帧增长+clone证据后controller同inode写一次A；D和cancel-intent sticky，取消后不A。v6b首个启动容器不再当场景图像。v7 9 ASAN/UBSAN检查及imports通过，`outputs/source-carrier7-stage-044901/report.json` stagePASS，新的/system/lib64/libx2v_carrier_20261012h.so，原程序不变/systemro，尚未加载。
- 新host `local-verification/isolated_source_test.py` defaultoffline，runtimepacket3文件已freeze；仍受source_session_execution_hold.json当前released_modes控制。root唯一设备操作者，下一次只放isolated-carrier-v7，不放高分辨率/graph/旧wrappers。

## 2026-10-12 04:25：单帧CPU读回已证；factory第二次崩溃后原厂已手动恢复，转独立native进程组

- `outputs/source-carrier6-041635/diagnostic-raw-readback.json`：receiver v6b SHA8d51f7b7…662、normal clone1b314a…0b70，启动阶段CPU单帧容器22,004,736B，SSD/data/host SHA9057dbd5…0126一致。receipt v6 rc0/state5/error0、drain_attempted1/drain_rc0/cpu_drained1、callbackactive0、hookclosed1、hal_unmap_error0；carrier7408×1482/stride14848/pixel2为RAW父handle shadow。后续离线分析发现大区仅7/13种接近4000的值，run尚无normal_start/Active/count增长；这是启动阶段容器，不是正常场景RAW、目标3884×2914或持续录制证明。receiver v7将prepare与A显式arm分开，旧v6b不再作场景取帧候选。
- 原厂camera-test16234再次SIG11；init整组kill报1remain，但日志逐条确认manual29818/supervisor29608/watchdog29757被SIG9回收。独立ADB guard29542存活且正确HOLD death_chain_incomplete。原report FAILED保留，**不能将CPU closure当native quiesce或自动恢复PASS**。
- root凭exact owner identity与init单独reap证据一次启动stock，native域核旧3PID ABSENT；`stock-restoration-health.json`原厂service6716/gui7199/factory31629，Active/Still16bit，帧1444→1638，三原厂SHA及/system ro正确。`reconcile-manual-recovery.json`仅释放本run三锁；manual-restoration.receipt单列。无物理重启。keepawake新PID7592，原host40187续租与baseline300保留。
- 已证fresh factory+sleep10s不能消除缺陷：CameraProxy在首次SuTest调用才lazy构造，之前等待不会同步它；失效stack QEventLoop callback可能随后崩溃。所有source modes再次HOLD，released_modes=[]，不得原样重跑。
- 新方向：ADB su能写/acct/uid_0，而native factory域不能；toybox setsid实测self PGID=SID=8820、cpuacct仍/uid_0/pid_2279。正在self-only创建自有leaf、只迁自己、原组回迁、empty rmdir的有界权限试验；新leaf mkdir实测Permission denied，未创建/迁移；self写回已有ADB组/uid_0/pid_2279实测PASS。当前只测试native gated helper经fresh challenge迁入既有ADB组，保留native域，取景不变且只做DBus读。仍与adbd共享生命周期，不能称完全独立系统组。没有改SELinux/init/原厂二进制。

## 2026-10-12 04:06：独立守护跨factory重启、normal observer模式接入完整PASS

- 独立guard b SHA2d1f0b22…41930，ADB own cgroup /uid_0/pid_2279；固定clock helper d44ae576…00f59已stage可执行。boot_id/selfstat/cgroup/mounts可读；/proc/uptime和awk不可用，b已避开。26 host mksh gates不是设备证明；真实survival记录`outputs/source-guard-survival-040201/survival-reconciled.json`：guard15093/start3720588/PGID15090跨factory5822→16234重启存活，心跳37269→37279；stock5493/gui6060身份不变，frames86313→86858。初次ADB launch host20s timeout但guard已运行，保留原failed report，未重复dispatch；后续绝对路径+stdin /dev/null避免compound后台shell持pipe。
- factory Qt风险已缩到executeSuTestCmd在!isSynced创建stack QEventLoop，连接context是长寿命CameraProxy且无disconnect；后续synced可调到销毁栈loop。read_parameter27取Phocus System版本，不能作factory gate。已fresh factory在stock稳定后等待10s再HblShell，sourcetransition期间禁新HblShell。
- **新observer短测PASS：`outputs/source-observer-040421/report.json`**。controller9aa0dfdd…e4d56c + observer6ed1872a…e8f41 + clone1b314a…0b70。独立guard先readyheartbeat，native预建gated child+3owner seal，guard owners ACK后才停原stock；8910个observed callback全部完成active0。carrier descriptor实见pixel2/7408×1482/stride14848，RAW父cdaf像素10001。只是观察，无HALmap/图像复制。
- body0/recovery0，manual native quiesce到Max255、parentreap，stock恢复service20738/gui21892，frame451→594；Active/None/Still16bit/CropNone，ro/锁clear。已解除只限normal-observer-v4的hostHOLD；旧RAW/target wrappers仍拒绝。
- 新keepawake PID16741/factory16234（restart后重建）/baseline300/host40187续租。latest stock状态以上述04:05报告为准，后续实测前重查。
- v5候选receiver_v5冻结：carrier1580faf5…3c7fa已经stage /system/lib64/libx2v_carrier_20261012e.so，未加载；strict carrier2 vs directRAW10001分开。63 own-code ASAN/UBSAN通过，不等于vendor实测。root正在`source-session-normal-carrier-v5/controller.DRAFT.sh`适配单帧CPUcopy，HOLD未放；目标3884×2914仍未交付。

## 2026-10-12 03:39：已恢复原厂；查明factory崩溃导致整组SIGKILL，继续修隔离

- **当前相机已恢复，无需用户物理重启。** Root从ADB可读`/blackbox/system/{kmsg.log,system.log,coredump/}`取得关键现场证据。camera-test1094于03:17:30 SIGSEGV（fault0xaaaaaaaaaaaaaaaa）；栈`DBusProxy::onGetAllFinished+300 → synced → Qt doActivate → QEventLoop::quit+40`。kernel日志确认init kill整个uid0/pid1094 cgroup，并逐条记录watchdog31199/manual31749/supervisor31084收到SIGKILL。这确切解释无CPU ACK/无恢复进度；不是已证的receiver死锁。具体Qt对象生命周期触发还待证。
- 证据`outputs/source-rxb-031730/{camera-test-core.tar.gz,kmsg-snapshot.log,system-snapshot.log}`。native独立core解析：frame中threadData指向主线程stack的0xaa填充值，eventDispatcher值也是aaa；支持失效引用候选，不能直接命名具体UAF对象或归咎RAWcopy。
- Root在kernel明确reap旧owner后，检查stockinit stopped及本run锁身份，通过`kernel-confirmed-stock-start.sh`只启动原厂camera-service；factory立即恢复响应。再原factory域启动stockGUI。`stock-restored-health.json`核service5493/start3554313、GUI6060、factory5822/running；Active/None/Still16bit/CropNone，frames3579→3713；三原厂二进制SHA匹配，/system ro，新service maps没有libx2v；旧三个PID在native可见域都ABSENT。
- `reconcile-kernel-recovery.sh`在native身份和absence全满足后仅释放本run三把过期锁，写manual-restoration.receipt。原body/recoveryrc缺失、failedreport/空CPUreceipt全部保留，不伪造自动恢复或成功取帧。最新`recovery-status.json`已改STOCK_RESTORED_MANUALLY_TESTS_REMAIN_HELD，旧未知状态另存before-kernel-evidence。
- keepawake原watchdog11324也在factory组被SIGKILL，hostworker40187仍续租；原脚本曾在旧blackbox清理时移除。已重新上传同SHA93dd786a…8ae的脚本并恢复watchdog6834，保留原熄屏baseline300和hostworker，不重复acquire_wake_lock。screen_idle_timeout=0、set_screen_enabled(true)=Ok。当前保活恢复。
- 所有manualcamera实验仍被`source_session_execution_hold.json`挡在第一条设备请求前；已测试阻挡，不能仅恢复相机就解除。必须修复同组被杀问题，并验证新的observe-only接口。codec v4 SHA6ed1872a…e8f41/26440B离线ready，callback无getenv/dlsym/stdio/HAL，仅fixedrecords+原子+nativeforward；只证明observer_window ACK，不证明DMA停止。
- UIUX正在新`source-owner-isolation`研究真正cgroup隔离与独立ADB guard；native审计辅助。只读`cgroup-readonly.json`显示factory域可见自身cpuacct=/uid_0/pid_5822，但/acct/uid_0及child组访问Permission denied。libprocessgroup真实createProcessGroup为三参(uid,pid,bool)，而且会chown已存在uid父目录；root禁止此父目录副作用，不改SELinux/init。先self-only权限probe，拒绝则备选独立ADB域guard+fresh kernel kill完整证据恢复链，不能以ADB看不到PID当Absent。

## 2026-10-12 03:29：紧急接续 — RX v2 会话停滞，等待用户机身正常重启

- **当前不能报告相机已恢复。** `outputs/source-rxb-031730/` controller b SHA1682dc8d… + receiver v2 SHA19e1ff7b… 启动后停在 uptime34549 QUERY ready rc0/phase stock_absent；body/recovery rc均不存在，CPU drain receipt为空。Host125s截止、两次factory identity查询超时；ADB数据读写可用，但su不能观察native进程，绝不能把pidof空当进程已退出。
- 所有设备操作暂停，root唯一操作者。已将该run的receiver.command同inode写D并回读size1，尚无ACK。没有盲kill、启动第二service、删除锁。标准`adb reboot`返回设备失败（host命令exit0不算成功），`setprop sys.powerctl reboot` rc1拒绝。已请用户用电源键正常关开；若无响应告知，不拔电池。用户回复之前不要重复加载v3/target。
- `outputs/source-rxb-031730/pre-reboot/`保全36个文件；`recovery-status.json`是最新未恢复状态，原failed report不变。manual候选PID31749/start3454832、supervisor31084/start3453470、watchdog31199/start3453787，factory原PID1094；这些仅为历史身份，当前liveness未知。
- v2回调接入真实已证：original20a0b0 pin通过，frwk GOT指向hook，8个不同原厂节点回调；liveview_sbpc/inport0看到7408×1482、stride14848、planeheight1482、planes1，但format+28=2而非旧预期96。没有任何新HAL map/copy命中；fmt mismatch不能解释40s CPU ACK和90sguard都未产生结果，根因仍未知。
- 格式矛盾静态已闭合：原厂`liveview_raw_shadow`故意配置YUV420 enum2；shadow更新复制RAW父帧handle20/planes/几何并持ref，却保留own format28。RAW父rout0为RAW16_OPAQUE enum10001，96在DUSS namespace无效。普通shadow receiver可用精确carrier2来源契约；纯group13 RAW应另用10001，不能通用接受2或将2命名RAW。
- codec agent的v3仅离线候选；正在独立v4移除callback中getenv/dlsym/stdio并先observe-only；全部HOLD。旧group13 receiver4c263…和target026b…仍有过时fmt96，不能执行。目标3884×2914/3920×2946连续帧未得到。
- 独立控制器审查见`research/full-fov-pipeline/source-session-incidents/source-rxb-031730/incident-review.md`：watchdog与service共factorycgroup、身份链调用没有总timeout、无heartbeat；空watchdog.log不等于未运行。`--recover`没有强制factory可见性，当前严禁从ADB域跑它以免误判native absent。
- 前一run `source-rx-030519` 已完全手动恢复：stock28434/GUI29867、frames6082→6231、Active/None/Still16bit/CropNone、systemro、locks CLEAR。自动恢复失败原因包括设备dd的conv不可用及PID消失竞态候选；b版已改printf同inode及二次absence核验。这个历史恢复不代表本轮恢复。

## 2026-10-12 02:53：owned descriptor 接管首次实机已证；正常帧与首轮恢复成功

- `outputs/source-clone-024928/`实际运行normal-clone，factory shim `clone_ready` 24行/HB23→52，原Init rc0；manual service15044正常帧470→620。原日志包含厂商FW_ARM前缀/行交织，controller严格行首matcher误判`clone_evidence_missing`，body5/original passed=false保留。Root `reconcile_source_clone_024928.py`解析完整tag字段，`reconciled.json`另记新接口实际接管与帧证明，不抹原错误。
- 首次恢复rc0：parent日志本次明确见PID15044状态Z，显式wait rc1之后proc/pidof消失，stock service16476/GUI17414运行，帧477→627、Active/None/Still16bit/CropNone、/system ro、锁释放。此次真实Z证据不反推上一个stock失败必为同因。
- 新normal-receiver控制器正在另目录制作，修tag matcher并结合已固定clone+receiver，FD3/7/8同exec，RAW新SSD独占run，控制小文件data。Root `source_receiver_test.py`defaultoffline/pycompile通过，等freeze后review→实际oneframe→独立SSD/data/host SHA回读。
- Native独立审计35组时序匹配，新增私有prepare与updateFPS双guard：目标HB24第一请求即使旧状态23/50fps，也强制20/1；普通HB23指针/rc不变。`source-adapter/TIMING_INDEPENDENT_AUDIT.md`证明request仅同步24B读取、无逃逸。组件v2 SHA1d9a0647…尚未部署。
- 高度规则已精确：librcam85cb0从driver transfer读取，HB crop可调整，HB+74额外行，85d88/9c仅driver52加2。因此17–20目标3920×2946，无统一+2。有效3884×2914/实际光学视场与CFA仍未实机证明。
- graph `.sp`真实`__open_2`和`.conf`真实`fopen`重定向已做，新HALgetter限固定plugin+地址指令pin+一次CAS；normal graph待冻结与独立smoke，target全链仍未启用。UI/H265等继续停在模式接入之后。

## 2026-10-12 02:35：用户改为模式接入最高优先；新接口已stage，normal owner实机出帧，watchdog恢复成功

- 最新用户明确批准开发新接口、大幅尝试，优先攻破模式源。Root仍唯一相机操作者，三个sol/high agents全部转模式实现：native_album=owned HB/HAL mode；codec=RAW receiver/owned topology/graph；uiux=source owner controller。UI system candidate已离线冻结但暂停装机，不回到UI/3FV样片支线。Goal active。
- 原服务动态构造点已找到：librcam rcam_dev_create通过PLT调用rcam_imgsys_create，shim调用原factory并wrap public+10 Init，在原Init之前复制并安装owned c0 descriptor/24×84 HB rows，数据保留至进程exit。normal-clone保留HB23→driver52所有bytes。Root发现并修正重要load bias：首LOAD vaddr2b000/offset0，不能用dladdr.dli_fbase直接加VA；现在factory−24c678并dl_iterate_phdr crosscheck。
- `research/full-fov-pipeline/source-adapter/` frozen normal-clone so SHA1b314a384bda2ee4caf6b8c6d60d8258e2e3b56c65d48778684043ac8bee0b70 /161536B；7hostchecks/noDT_NEEDED。已用guarded stager安装新`/system/lib64/libx2v_source_normal_clone_20261012a.so`，outputs/source-adapter-stage-022350/report.json通过。仅/system/bin/true映射RC0记录source-adapter-map-20261012.json，未启用在service。librcam原文件未改、/system ro。
- `experimental/source-session` stock controller SHA48f248f92b754ddbea84a65c6cb283c58b366f46c820d3fcdc62b874b02e547a/13host checks；从factory camera-test cgroup1094启动独立controller/watchdog，停止原service/gui并单一manual service，不与其他硬件owner并行。90s是开始恢复deadline，不是所有错误强制kill保证。
- 实机`outputs/source-stock-023126/`：manual service7391成功Active/None/Still16bit，frame458→610，正常set_live_view(false)后group255，bodyrc0。第一次recover TERM后立即`ERROR_foreign_service_no_overlap`，recoveryrc1原报告保留failed。随后独立watchdog自动重试完整恢复：stock service8957/frame476→626，GUI9780/running，restored标记及锁释放，后续frame2950、systemro。证据after-watchdog/events.log + watchdog-readback.json。未人工干预设备恢复。退出后pidof/init状态短暂未收敛是候选根因，尚无首次失败瞬间PID证据，clone controller将加bounded absence wait及日志；不能把本轮总体验收冒称无错误passed。
- Root主机`source_session_test.py`已修：body首次recoveryrc1后继续观察watchdog restored，而非立刻结束读back；原body/recovery错误不抹去。defaultoffline，固定modewrapper，无arbitraryexe/preload参数。UI agent在新source-session-normal-clone独立修恢复及固定cloneenv，stock冻结保留。
- `experimental/source-receiver-adapter`正常单帧CPUcopy .so SHA84d8b943e729f90f96652c4334a3737ce1c0fdb1874a624dd38e67b776c19bda/38104B，normal-freeze含所有编译输入+27Bionic/HALimports验证。借原callback映射/同步/拷贝22MB/立刻unmap，writer仅持CPU副本。只接受显式HB23_DRIVER52+空FD3、readonly命令FD7、空ACKFD8；完成/命令D后disarm+本hook退出+CPUdrainACK，不把cache sync当DMA fence。已stage到`/system/lib64/libx2v_source_receiver_20261012a.so`，outputs/source-receiver-stage-023400/report.json通过；未load/constructor执行（DT_NEEDED HAL，不做独立true预载以免原库constructor）。
- Root并核MCU时序取得实际代码证据：`research/full-fov-pipeline/mode21-timing-root/{README.md,solver.py,candidates.json}`。MCU0806d1e0固定72M sensor→36M HB、偶数xhs/xvs/精确ratio/minline约束；tgConfig0806ced4按72M/rowclock应用总周期。没有通用frame+8规则。离线allocator转写复现normal52 100fps240/1500；候选17@20fps36M/450/4000，17@24fps500/3000，18@30fps400/3000。17–20该路径无60fps解，不是整硬件极限。native_album按17@20完整HB行+HAL请求ratio继续；未实际切mode17。
- HAL owned entry新进展：get_cam_info out+120→16B modeheader(count10,arrayptr)，out+130→topologyheader(count7,arrayptr)；此前漏掉二级指针的无入口结论被纠正。插件handle-local dlsym不会自动用preload同名getter，codec正在做实际loader边界/ownedheadercallback。graph13是原枚举LiveviewRawCalib，normal/target新配置仍只生成，加载重定向正在实现；目标20fps且绕开旧3884×970 SBPC ROI，不只改传感器driverbyte。
- 当前相机stock service8957/GUI9780，Active/None/Still16bit，systemro，source/GUI locks clear。Root无执行中设备命令；保活仍启用。下一步等clone controller冻结→review→实际normal-clone/恢复→normal receiver→完整target接入。禁止未完成target/FPS/receiver适配的试切，group12旧HOLD仍保留。

## 2026-10-12 02:05：机内 SSD 2 GiB 直接写实测通过；data loader 映射被拒，系统路径候选离线制作中

- Root 唯一设备操作者，三个 gpt-6.1-sol/high 子代理继续。goal active，无 commit/push。当前 service28857 / stockGUI23222/running，Active/None/Still16bit/CropNone，/system ro；无 root 设备长进程。
- 新 `experimental/ssd-direct-write/ssd_direct_fd.c`：仅新空普通FD3，O_DIRECT必须设置成功，4MiB对齐buffer，最多2GiB/64MiB AS/20sCPU/45s alarm/48s外timeout，写+fsync+全直接读回memcmp；3项host ASAN/UBSAN通过。helper SHA9813c88ec2bd9d0a03e34568298a49859e6126c82ca05ff4ac521db94adb9945。
- `/data` ELF exec RC126被保留于outputs/ssd-014724/report.json，未产生SSD写入。只改ROOT的既有stage_artifact副本（SHA5bcfb0c2183e321531b11cca5225b9b67805e0a0ac7ce1451f2746e7d80acd78）沿用独立watchdog/SHA/label/ro恢复，发布自有 `/system/bin/x2v_ssd_20261012a`，原厂文件未覆盖/安全策略未变。安装先完成导致host PID读取失败，未重发；outputs/ssd-stage-015322/reconciled.json确认installed_readonly/hash/锁释放/同健康PID；原失败观察保留。ssd_stage.py已修结束进程读取race。
- 实机16MiB：outputs/ssd-015419/report.json passed，618.931MB/s。实机2GiB：outputs/ssd-015455/report.json passed，write2.812916s+fsync8.734ms=761.074MB/s，全读回相等；512个4MiB写最大16.886ms、nearest-rank P50/P95/P99=4.960/8.462/10.426ms。前后service/gui同PID、取景正常。全读回15.518s包括比较，不当纯SSD读速。仅短单文件伪随机重复块测试，不是持续DNG/温升/缓存耗尽/每帧fsync；UHD16bit30p预算498MB/s，3884×2914 16bit30p679MB/s仅12%余量，12bitUHD60p746.5MB/s仅2%余量不承诺。详情experimental/ssd-direct-write/README.md + raw-budget.json。相机自身X2V_BENCH保留2GiB+16MiB自有partial证据。
- UI `experimental/persistent-session` 冻结：controller2f85ca7e.../data loaderc9ffc917...，permission-a与record-a两包，22controller+9Qt/HTTP(0warning)+7contracts+121filefreeze通过。root仅用/system/bin/true做预映射，没有起camera-gui：outputs/persistent-map-probe-0200/report.json显示loader data segment2 Permission denied RC1，机身同PID健康。不是只execbit问题，不改SELinux。该data-loader方案不可装机。
- UI代理正在独立新建 `experimental/persistent-session-system`：状态仍data、审查bulkSSD、loader新自有/system/lib64路径（guarded stage），新b runIds，dry-run失败显式return而非进入stockmain，fresh hashes；新 `local-verification/persistent_ui_test.py` runner制作中。未冻结前勿部署；旧record_album_test HOLD保留。root下一步先review/stage/mapping/permission-only/恢复，再不同run录制QA。
- `research/full-fov-pipeline/mode21-profile-adapter/README.md`与contract冻结（README3da4e91b... /contract7ca997e3...），7hostchecks。原厂c0descriptor+b0 borrowed rows+b8count，按248+count*e0分配，stable handle-cell+callback lifetime恢复；但无已审service新descriptor入口，HB sensor实际static global绑定，不能独立第二instance。模式完整timing/receiver/stop drain仍缺，group12 HOLD不解除。native_album代理转有限10–15分钟公开真实3FV样片查找与解析。
- codec交`experimental/hardware-hevc-session`实际0x138 start/0x1c0 submit、6参数ION、cached sync≠DMA fence、header type2len/type1copy、12vendor符号静态链接；hostASAN/UBSAN通过。audit.so SHA bf66514018860c2b951778f0d588ecaa23600cbf4fbc3d1175d17c9a4023e58a 禁止load。完整descriptor/正常归还/失败DMAstop未闭合，HOLD不解除。该代理转独立 `research/cinemadng-writer-plan` 最小writer接口/真实照片离线像素校验，勿冒充实拍连续DNG。
- 总报告更新加入实测SSD+constructor证据，15,622字符/28local links无missing，receipt新SHA。H6D采样附录仍明确3864×2898+3/3+2160窗口，binning vs skipping/public mode mapping未证。原始日志/失败报告不覆盖。

## 2026-10-12 01:38：b录制成功但blackbox清理致QA中断；相机已手动安全恢复，RAW方向优先

- 用户最新明确提出4K Bayer直接CinemaDNG、尽量合并/跳采保全视场、绕开重型彩色编码；若DNG不行考虑3FV。根目标仍保留所有独立条件，RAW源→有界writer→DNG与H265并行优先。root已查官方X2DII产品页写速最高2370MB/s、1TB；不是本机持续基准。30fps UHD12bit373MB/s/16bit498，3884×2914 12bit509/16bit679；1TB理论44.65/33.49/32.72/24.54min，未扣现照片/开销。
- 总报告`research/X2DII_H6D_SYSTEM_PIPELINE_REPORT_20261012.md`最新14.6k字/25local links检查0missing，receipt记录SHA69fe5aa7...。硬件/Qt/容量/stride由codec独立审查通过；后续b故障与RAW预算已补。报告不是整个goal完成。
- b UI入口修复实际通过：Drive→Video→原厂收屏→LiveView→Start，bridge真正保存60帧2.008333s/3408036B。`record-qa/recovered-media.json` H264High/yuv420p1300×970全帧decode0error，SHA061a2b20745f4facbf9b66b5786ef6f31eea72cc7eb3d0bef9fb421d31acb531。源SSD片保留；factory复制到新`/data/x2v-native-20261012/b-clip-173014.mp4`供ADBpull，源/hostSHA相同。直ADB读SSD被拒绝，不重复；/data/local/tmp不存在。
- b整体QA仍失败：运行时整个/blackbox/x2v-native-20261011/runs及owner/audit/config被删除，logger文件消失。old free535.61MiB，原厂500MiB/30s cleanup threshold，x2v顶层不在whitelist，静态dji_blackbox实际rm排除白名单调用已证；b空间预算未考虑该阈值，free后跳3.49GB强吻合，未见本次daemon日志不能称最终动态因果。
- b watchdog自身也消失/已退出，old supervisor和临时GUI仍在。root按部署记录PID/starttime逐一复核，TERM自有supervisor21571和GUI21693（watchdog21657已无），确认无GUI后start原厂。`record-qa/manual-recovery.json` passed：stockGUI23222/running、service28857不变、ActiveNone、systemro。bridge已确认rtp_off/receiver_dead后停，18762移除。**当前机身正常，无root长命令。** 原failed report保留。
- root修record_album_test.py：final日志读取错误与gs.stop恢复独立；加EXECUTION_HOLD在任何设备访问前，直到新状态存储迁移完成。现在不要重跑a/b/旧blackbox试验。原factorytoken及旧run/QML/data可能已被清除，不能按历史路径假设仍在；自有/system helper还在但需新readback。未改blackbox策略/白名单/SELinux或启动项。
- UI sol/high已获授权实现独立`native-video/experimental/persistent-session/`：/data/x2v-native-20261012放controller/lease/payload，bulk audit放SSD，新loader编译/hashes；不改现runtime或a/b/d/f。旧bootstrap有硬编码customprefix/log也要迁。root唯一设备操作者，agent仅offline。cleanup审计在simulator/evidence/blackbox-cleanup-audit/README.md。
- codec新`experimental/hardware-hevc-backend/packed10-public/`：官方VSI format24 SEMIPLANAR101010 +本机transYUVtoP101010format地址62908，恢复位排列/UV交错。真实3840×2880 planar10↔packed22,118,400B逐字节一致，12检查通过；native转换器8bit补零，硬件实际低2bit仍未测。agent完成，未连设备。
- native_album已交`research/full-fov-pipeline/full-fov-entry-audit/README.md`：type4仍group12/11656×8742；type3group13/3920×986；24HB+10profile无17–20绑定，不能靠hiddenAPI直接出3884×2914。现在继续用户新问题H6D实际100c ROI/binning/skipping静态追踪，不把4K输出当无裁切证明。goal active/no commit/push。


## 2026-10-12 01:28：H6D固件/全栈报告已交初稿，record-album a入口失败并恢复

- 最新用户要求已并行执行：H6D官方1.21.0 CIM63MB+GPL415MB实际下载/校验/全量解包；主报告`research/X2DII_H6D_SYSTEM_PIPELINE_REPORT_20261012.md`已落，包含系统、影像、H6D对比、证据等级和未完成项，面板打开请求queued。不能将报告交付当整个goal完成。
- H6D专项`research/h6d100c-raw-video/README.md`+source/artifact manifest+verification/receipt已冻结。i.MX6Q主控之外，even/odd QSPI重组后真实Zynq BootHeader/FSBL/PL/FARM app校验通过；RAW/MP4/META三轨3FV、CFast写卡、COMP表和Phocus解码路径。无真实3FV样片/未证无损或无裁切。2018固件≠2016首发，主机25fps vs digitalback30fps原文冲突保留。
- 新X2D2 live DT `imaging-dt-properties-20261012.json`：12节点statusokay，ProRes/Moonshadow/J2K/JPEG-LS均sysfs实际bind；JPEGXR没有对应bind。ISP UIOnode不等于eagle2-camera绑定本身。codec专项`experimental/hardware-hevc-backend/IMAGING_PIPELINE.md`+other-codec-inventory.json已纳入真实库/plugin调用，并未执行硬件codec。新`x2d2-static-core-stack-20261012.json`含6核心ELF SHA/dependencies/init；QtCore构建字符串6.8.2。
- root新runner`local-verification/record_album_test.py`默认dry，仅--execute进入设备，需冻结candidate/lease/85s独立watchdog，验证新片身份与全帧decode。a实机完成Drive→Video，但QA误用了CFV-only隐藏lvButton，stage_timeout_liveview，未录制。failed原报告保留；显式recover ORIGINAL_GUI_CONFIRMED，stockGUI19068/running，service28857未变，LiveViewActiveNone，bridge停/forward移除。证据`outputs/gui-sessions/native-record-album-a/record-qa/`，audit34帧runStopObservedtrue。已查看frame16真控制屏。
- UI agent正修b（未冻结/未部署）：改用原厂ControlScreenSwipeArea.enableDrawer(false)→setDrawerEnabled(false)的真实X2D收屏UI链，19shared组件不变，a冻结。b lease模块`simulator/evidence/record-album-qa-b/make_lease.py`，runid native-record-album-b；root runner支持明确--lease-module，先做offline hash检查。
- 输入专项`simulator/evidence/record-album-qa/input-chain/README.md`已证明二代keyOverride→forward_input_events→InputControl；Override3抑制全按也影响半按，Qt accepted不能阻止service拍照。现产品未接实体快门录像，未改override；不可贴全屏mode3伪装完成AF。
- root唯一设备操作者；三sol/high代理当前：UI修b；codec审总报告并追官方/开源VSI packed10位序；native_album从H6D转查full-fov-entry-audit。camera-expose type4 FullFovRaw初步已确认仍是group12，不是新的3884×2914入口，不解除HOLD。无root长命令在跑，无commit/push，goal active。


## 2026-10-12 00:51：恢复锁实机通过、全幅彩色 Main10 单帧机测成功

- e实机保留失败：UI流程成功，但Android mksh空exec9设置CLOEXEC，flock9实际BadFD，三个恢复者均失败。root用冻结d控制器仅恢复e，stockGUI6812/service28857正常。实机纯文件probe证实`toybox flock -n 8 8>&9`成功，父9持锁/关闭释放。证据在e/product-qa/fd-probe-and-mcu-version.json；不要复用坏e包。
- runtime最终SHA `a671f5e300894c56ddd5440049574240443fee051d32a411aefe2a75f8c26379`，真实host mksh R56+C flock和过程故障20项通过。报告outputs/runtime/gui-session-mksh-host-tests.json。f完整实机回归 **passed=true**：outputs/gui-sessions/native-album-product-f/product-qa/report.json。冻结d UI不变，2300项，最新单张→3/5列→video playing→stop idle→照片新identity ready，QML错误0；recover rc0/ORIGINAL_GUI_CONFIRMED、restored、stockGUI9757/running、service28857不变，bridge停/18762移除。supervisor TERM exit.code1与恢复rc0分开。f屏幕审查50帧/stop完整。
- **机内3840×2880彩色HEVC Main10单帧成功**：outputs/ffhevc-004844/validation.json。自有新增helper `/system/bin/x2v_ffhevc10_20261012a` SHAe03369f8ec2aac416ba3a023d000cce2dc55b69f6b93c72cb61a22e4f93b3bb9；stage后/system ro。输入B3648原始全crop11656×8742在HOST去马赛克/缩到3840×2880 Rec709 10bit，普通FD CPU单张编码；不是实时源。限额256MiBAS/30sCPU/40salarm+42stimeout、350MiB可用内存门。
- 实机rc0、8946059B，SHAa0175b793762f26dfc0978503c265b4fd8026cac3697238462424bade14c1cad；RSS208720KiB约204MiB、CPU18.42s、含launcher墙钟31.02s。Main10 idc2/yuv420p10le/3840×2880，HEVC+hvc1完整decode同host SHA07880977fd60e2b9ab199771d4cc857834c2dfbbc957196318d7bed187df60f7。QP0有损max11/RMS0.9766。**软件单帧不是实时4K方案，不把指定1s时间线当录像。** 原process pending字段保留，最终validation独立关联SHA。
- 当前健康：service28857/gui9757均未因CPU试验重启，Active/None/Still16bit/CropNone，frame_count516→2371，/systemro；MemAvailable374024→399280KiB。保活继续，未替换原厂固件/启动项。
- MCU实质证明冻结于research/full-fov-pipeline/exmcu-mode-contract/mcu-handler/README.md+11checks：实际0f/11 handlers→SensorImx861 ops→17–20各345寄存器列与libsensor一致。root原厂只读exmcu firmware_version回apps_messaging_version=b9558bd/firmware_version=f991af，与.cont实际响应构造匹配。不能把全机real_version_id或buildIDs当flash全SHA/运行模式成功。group12 HOLD继续，3884×2914连续源仍未取得。
- 并行下一步：native_album代理新mode21-profile-plan梳理HB23→52与17–20的host尺寸/SLVS/ROI/buffer/ISP差异，不能单改conf；codec代理新目录给硬件HEVC最小接口/退出契约（无实机/DMA）；UI代理独立record-album QA走UI handler、3s录制意图/保存最新clip/点播放。shared UI/runtime/d/f冻结；实体快门录像未实现，脚本不能代证触控。
- root新增local-verification/full_frame_hevc_device.py（默认dry）并增强album_product_test.py失败门。当前无root长命令，goal active；未commit/push。用户系统问题已答：Linux5.4.123-rt59+Android9/API28+Qt，4xCortex-A55(41/d05)，DJI Eagle2 HB722 V5，商业SoC料号未确认。

## 2026-10-12 00:30 接续：用户问进度与Linux/CPU，目标继续

- Root已实读`local-verification/platform-live-20261012.json`：Linux5.4.123-rt59/Android9(API28)/aarch64，4核0x41/0xd05=ARM Cortex-A55（Arm官方MIDR表已核）；DTmodel DJI Eagle2 HB722 V5，compatible dji,eagle2。只确认平台与CPU核，商业SoC料号未知。已在commentary答复，未取消原录像任务。解释在platform-interpretation-20261012.json。
- UI d实机flow_completed=true但report整体false：退出recover报recovery.lock/owner消失/rc1，随后独立readback确认restored、stockGUI787、service28857没变。rc1具体因果尚未确定，不能仅凭missingowner断言。Root已查看3/5列真实截图，最新B3649橙框在视口，48帧日志stop完整。见INTEGRATION顶部。bridge已止/18762已移除。
- UI代理6.1sol/high正在只改runtime/gui_session.sh和其测试，修recover目录锁TOCTOU，候选flock；root提醒spawn的stockGUI等子进程必须关闭继承锁FD。实机只读toybox flock帮助确认sxun fd；SHA b62d2767deab3f0645a36ebfca566561eece56bb41d4739bab17609cb48292cd。修复尚未装机。UI候选d冻结20文件不变。
- native_album代理6.1sol/high已交`research/full-fov-pipeline/exmcu-mode-contract/`离线契约+7项测试。mode prepare0x0f/set0x11在no_wait表，不读ACK；host mode-info byte40为driver index。PHY依赖完整实例+5e0及超出132B相邻字段，不能传临时mode struct。正在该目录mcu-handler追实际exMCU_hb722.cont CortexM4F镜像的SensorHdlr、0f/11 handler、MODE21表；存量.cont含这些字符串但尚未证完整handler支持/当前MCU版本，禁止发命令。
- codec代理6.1sol/high在完成group12失败/fps报告：auto表最低15fps，slowburst只在FSM slowBurstActive，setting setters会持久化QSettings。public MetadataControl metacall存在但未证外部DBus结构序列化，不能盲调。group12仍EXECUTION_HOLD。另考虑原厂正常全幅拍摄→低fps真实序列的替代，但未实施新burst，不把timelapse称24/30fps视频。
- Root更新album_product_test.py：照片ready必须在当前selection之后且nativeKey匹配、最新ready真，5项host/真实stale负例通过；整体通过还要service前后同PID。旧d失败report保留。
- 现无root长命令运行；screen collector已结束，新的MCU与recovery方案均只能离线审查后再决定实测。保活按用户要求继续，未刷写固件/boot，/system最后ro。Goal仍active；不能把未取得3884×2914源称完成。


## 2026-10-12 00:16 更新：group12 实机失败，已恢复，禁止原样重试

- 恢复后的原厂单张拍摄也已实测通过：`native-video/outputs/highres-source-20261011/still-reference-001559/`，新照片B0003649保留原DCIM。RAW213078016B/SHA06c5cd1b9e91d9d17b6c44939c442f9c572432a56345e799f9ffe0c57266ad64；HEIC64935936B/SHA9c90d2cd9b26f96f14050aab0ed5d3c0a3ad8534a708f6bd34645bf5ec36cae5。回读等于源；LibRaw解包全部11904×8842 uint16样本，crop11656×8742，正常；service28857/gui21497保持。不是视频来源成功。
- 新恢复后只读fps：fixed_fps25/liveview_fps50/slowburst_liveview_fps100/Image0。静态updateFpsList fixed分支×2与50吻合；auto分支最小15，不是9/10fps修复。尚不改变fps、不重试group12。最新8项host模型（含执行封锁前置、命名PID）通过。

- 原厂全尺寸 RAW profile 的零 dump 生命周期试验 `native-video/outputs/highres-source-20261011/g12-life-001048/` **失败**。setup12、start1、stop1 的 D-Bus reply 均成功，但没有取得有效 RAW 帧；`disp_null` 消费数是0。setup 实际已启动流，额外 start1 是 already active。不能把 API rc0 当作出图。
- 更早于 teardown 的日志已出现 SLVS 接收尺寸不符（期望11760×8866，收到行数1790、宽0）、1500ms 无帧后原厂 SysMon 自动 reset sensor。teardown 期间 e2_segment_mgr.c:787 的 ioctl=-22，788 触发断言；camera-service 从380自动重启为28857。控制器发现 PID 变化后停止继续发送恢复命令，restore.rc/watchdog.rc=42；不是正常停止成功。
- 原厂自动恢复后独立只读核验 `recovery-readonly.json`：service28857、stockGUI21497，Active/None/Still16bit/CropNone，所有曝光/流方法空闲，frame_count5206→5263，/system只读，拍摄格式仍RawHeif/All。未改启动配置、未执行camera-expose、未写sensor寄存器或刷固件。没有把服务崩溃说成机器变砖，也不以自动恢复证明该高分辨率路径安全。
- `local-verification/profile12_lifecycle.py` 已加 EXECUTION_HOLD，--execute 在访问设备前拒绝原样重跑。controller 保留用于离线分析。其最初7项host fault model通过只证明shell门/错误记录/互斥，不覆盖sensor/HAL。另修复 `pidof camera-service camera-gui` 输出不按参数排序的假设，今后分别查询命名PID。
- codec 与 native_album 两位 sol/high 子代理正分别查高层capture和直接stream流程差异、sensor ioctl/时序，以及真实frame/metadata路径。原3884×2914目标仍未取得；不能用已验证单张全幅照片、host重复帧HEVC或现有3884×970 ROI替代。
- 前一步 UI candidate-c 实机照片/视频混排、单张身份握手、视频播放停止均通过；candidate-d修缩略图定位和metadata刷新抖动，54项桌面Qt检查通过，尚未装机。c完整屏幕审查已从已有日志恢复46帧，`outputs/screen-audit/native-album-product-c-complete/`；原logger EOF证据保留。


## 23:36 更新：原厂全幅 RAW/HEIF、机内 DNG、相册候选 c

- Root 唯一设备操作者，三个 gpt-6.1-sol/high 子代理分别负责 UI、编解码审计、全幅参考流水线。goal active；3884×2914 连续源仍未取得，不能用单张或重复帧替代录像结果。
- 新线索：原厂未 strip 的 `resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/bin/camera-expose` 明确含 `LiveviewZoomFullFovRaw`、timeout、ImageMemory。已交 codec 代理优先审计参数/共享内存/输出/停止恢复，尚未执行该程序。group12 可输出11656×8742 RAW，但类型4需正确共享描述和退出契约；当前不盲调ABI。
- 实机原厂单张 `B0003648` 已完成，`outputs/highres-source-20261011/still-reference-231424/` 保存3FR/HEIC、日志、恢复回读。调用 `do_exposure_extended2 true 4 6000` 的4是 **ForceSingleExposure session option，不是ExposureType4**。原厂正常写DCIM，照片2293→2294；3FR 213073920B / SHA4ef366a1c012eda49de62b0c01b978d9d256786782be42330f7b39dee97b6f11；HEIC64563200B / SHAa52fa2e884d801076ad27d63893de909992cda8bcab7b17872f70d1d0753b540。全RAW11904×8842、声明crop11656×8742，16bit RGGB；HEIC主图12块实际HEVC Main10 3072×2916全部严格解码通过。不是连续源或帧率证明。
- 自有 DNG converter 已在相机执行一次成功：`outputs/dng-232855/validation.json` + recovery-readback.json；约5s输出210514432B，SHA442841d226decbcffc3e9692b08034d6a7ace86df4b1474c6a01f51effcd2a12。全部105255168 RAW样本与源一致，原crop/calibration标签保持。仅普通文件转换，不是连续DNG内录或Phocus色彩验收。helper `/system/bin/x2v_dng_20261011a` SHA c9c02aca697a042ac9982c1c3b951dbfc98d0202d57713ca28fae88846c493fc，stage后/system ro。
- factory_shell 的 capture_ms 是整个USB命令接收截止；1.1s不足以大文件SHA/繁忙后查询。首轮DNG未dispatch，第二轮转换成功后query超时；没有重复转换，用5s只读回读和独立validation确认。保留原失败report，不篡改为成功。runner已修正。普通文件进程timeout安全不等于DMA owner可kill。
- ION只读回读在 `outputs/highres-source-20261011/ion-*-readonly.json`。Linux937MB不是图像总内存；图像池allocated8.73GB，heap id2总2.95GB、当前free2.435GB。撤回Linux MemAvailable不足→group12必OOM推断，仍需核实目标heap/复用/取消。不要读疑似有strlen缺陷的encoder_status。
- UI candidate-b实机2299项=2294照片+5片；单张、3/5列缩略图、真实视频playing、停止release_complete25ms→idle通过，但原厂照片identity handshake失败。精确原因是BrowseView.qml实例覆盖objectName为BrowseView_media_list；c修正此名且保留同viewModel和完整nativeKey门，44项Qt0warning。冻结 `simulator/evidence/device-product-candidate-c/`，root正在准备有界实测。b证据与失败报告保留，不能称整体已通过。
- 最新已恢复正常快照：service380 / stockGUI19022，Active/None/Still16bit/CropNone，/system ro；bridge d按exe+PID+starttime停止、18762forward移除，keepawake继续。后续c测试会有意更换GUI PID。
- Root新增 `local-verification/still_reference.py`、`dng_device_test.py`、`album_product_test.py`；前二默认dry explicit execute，相册需明确已冻结package、独立85s恢复。源文档 `native-video/HIGHRES_SOURCE_20261011.md` 已写23:32结果。全幅RGB16/自有X2V Log2/10bit封装仅host参考由native_album代理继续，不冒充DJI D-Log。

## 23:04 后更新：真实 mode52 映射、机内标准 Main10、原厂相册取样

- Root唯一相机操作者，sol/high三代理继续。当前goal仍active：UI/低分辨率集成以及4K/H265/DNG/Log/10bit独立推进。本轮有实际进展，不能标blocked或complete。
- 最新高规格文档 `native-video/HIGHRES_SOURCE_20261011.md`。原厂放大对焦 true/false 3秒有界探测完整恢复；`outputs/highres-source-20261011/zoom-source-224240/`明确记录normal readout52 / `IMX861_4K3K_11b_MDJI_A2_100P` /7408×1482 /fps更新5000/100。MFzoom为readout3/11760×1292，局部输出1600×1200，不能拿来当全FOV4K。
- librcam设备SHA `3dd5b37b3db18b3e6b54271e1501b4dd337e101c06cdd386a896b1547b662f66` 与提取件一致；内嵌readout表与libsensor完全相同。codec代理正保存HB23→driver52和HB21→driver3的实际表映射。仍未取得3884×2914可解码帧；已有RAW ROI3884×970不能reshape补行。
- **机内CPU HEVC10bit已跑通。** 自有不可变helper `/system/bin/x2v_swhevc10_20261011a` SHA40148eaa486797fd45d46c6e7434355398e0045d70ab3e06d6a8b0e9cb8fd2c3；/system staging后已ro。无相机/DMA句柄、资源/超时有界。单帧a为Rext/Main10 Intra，不能按早期目录名verified-main10叫标准Main10。首次FD rc3/0byte失败也保留；Android shell需同一exec末尾3<与4>。
- **5帧a实机标准Main10成功**：`native-video/outputs/swhevc-230353-lossless/`，640×480、重复同一真实RAW灰度样本，rc0、约1.70秒（含launcher）。actual profile Main10 / idc2；HEVC/hvc1完整解码4,608,000B与输入逐字节一致，输出SHA2d62ef5b2f314dccc53243167964ef5b9005e7be560d0f2b7e09e89268433f1c。不是连续采集、实时30fps、4K或完整FOV；不能以5重复帧宣称短录。`local-verification/software_hevc_run.py`默认离线，--execute有hash/普通FD/内存/状态门。
- codec的独立CQP0标准Main10候选仅host验证，未安装；a已实证无需为profile重复部署。实际编码/Main10验证现在含SPS/ffprobe检查。Root已纠正早期单帧Main10命名，原证据未改。
- 原厂相册probe a因真实2293项超过旧2048门报native_model_size，正常恢复；probe b成功读前32+末32真实photo角色，文件 `native-video/outputs/native-album-live-probe-b/{qt.log,stock-capture.json,restored.json}`。日期44/64为空（lazy metadata），20个ISO无时区；SystemTime.timeZone实际numeric3600对应UTC+1选项，而Qt/JS当前+8，不能盲目把numeric当IANA/偏移秒。
- 相册Root产品决定：missing historical date/时区不得阻塞基本混排查看；刚录完优先明确clip_id，照片保留原厂顺序，选择保留stable key，严格全历史时间排序另记边界。native_album负责原厂排序/按需metadata解释；UIUX正在64页/4096上限/取消generation基础上做真正可部署产品入口，需root后续审查并实机QA。新增UI helper/26项Qt检查不等于已装机混排验收。
- 实时 `/catalog` 曾通过受限idle bridge取得5clips，`native-video/outputs/album-catalog-device-20261011/catalog.json`。该bridge7609已按exe+PID+starttime停止，18762forward移除；没有新录制或DCIM写入。
- 最新正常状态：service380/stockGUI9278，原厂相册probe b临时GUI退出0并restored，随后正常set_live_view(true)恢复Active/None、zoom=false；5帧CPU测试前后两PID相同，frame_count11500，/system ro。GUI重启是有意临时界面会话，不是codec崩溃。保活继续。
- 下载了 `resources/toolchains/dng-validation-python`（隔离target：rawpy/tifffile/numpy/pypdf），未改主venv依赖；DNG尚未实施。原厂DNG writer静态CFA RGGB和默认矩阵已读，但未证明该模式CFA/校准，不能当已校准彩色DNG。仅只读查询了normal do_exposure/drive Single，**没有拍新原厂照片**。

## 22:14 后更新：首个真实 RAW 容器已取出，目标 3884×2914 仍在接入

- 最新证据入口：`native-video/HIGHRES_SOURCE_20261011.md`，优先于后文的静态 source 推测。
- 用户已授权：先接 3884×2914、尽量完整视场，再接 H265/10bit；安全条件满足可直接做有界机内短测，不重复询问同一授权。
- root 通过原厂 `liveview_sbpc_basic-inport0Dmp`、total=1、metadata=1，从已有 Active/Still16bit 源取出 22,004,736 字节容器及3个JSON；四文件设备/宿主SHA一致。证据 `native-video/outputs/highres-source-20261011/raw-one-20261011-221456/`。
- 此前“7408×1482可能直接通向3884×2914”只是候选；实帧拓扑为 `12K_11BIT_60FPS`，元数据50fps，原SBPC实际ROI为 x18/y512/3884×970。离线可还原灰度实景，不能拼接/拉伸成2914行，也尚未证明全光学FOV。
- 全局double-trigger风险由精确只读20槽控制器表、state=-1与callback地址核验排除；未写内存/ptrace。单帧、5秒独立disarm、trap/hostfinally均ACK；服务380/原厂GUI25589未重启，Active/None，稍后帧计数100105→100140，/system仍ro。
- `local-verification/highres_one_frame.py`默认无设备操作；执行要独立审查clearance并重新核验原ELF和所有全局controller。当前刻意要求 `/mnt/media_rw/ssd/camera_dump`不存在；该目录本轮已创建且保留样本，**不要为重跑直接删除它或移走未经核对的文件**。
- 机内H265/Main10仍未启动。`research/full-fov-pipeline/encoder-exit/`查明原厂test工具stop/close失败后仍free、P010转换无效等具体问题；不是无副作用能力查询。
- 新增 `native-video/experimental/raw-source/`：真实RAW→严格ROI reader→10bit灰度平面→host HEVC Main10/hvc1 MP4，1帧3884×970；两种容器完整解码11,302,440字节均与输入一致，8项reader测试通过。此为电脑端灰度诊断，非彩色ISP/连续机内录像/4K；合成3884×2914 reader测试仅为离线适配。
- HB cam_mode表已恢复profile1/2→HB mode23/7408×1482；没有已证MODE_21映射。camera-service实际maps有librcam和HB cam-info，未见libsensor_imx861；禁止拿磁盘驱动符号/整数表索引作为已可调用设备API。
- 本轮UI与正式recorder冻结。三个sol/high代理分别工作于source-access、sensor-mode-crosswalk、raw-source离线adapter；root唯一设备操作者。后续帧/模式/文件证据以新回读为准。

## 最新接续点：晚间集成与高规格自研方向

- 本轮完整证据入口：`native-video/INTEGRATION_20261011.md`。它优先于下方历史快照。
- 用户确认**后拨轮缩放、前拨轮选片**；要求继续自行实现高分辨率/HEVC/10bit，尽可能保留完整视场，不能只等待固件现成开关。
- 最新模拟器已在 Mac 打开，57 主流程 +25 菜单检查通过；43 原厂 schema/258 静态项，专页后402节点。仍有明确仿真缺口，不是完整1:1固件。
- 新 UI 可移植层已按用户“完成后可以装机测试”授权进行临时机内测试。最终 native-playback-final3 的三次停止/释放/重开与自然播放结束均 passed，原厂GUI恢复。前两个测试脚本失败记录保留，不计成功。
- Bridge d 实机5秒短录、软件首帧、目录刷新、整片回读解码通过：159帧/5.308333秒、1300×970 H264 High 8bit、29.953fps、约19.95Mbps。证据 `outputs/bridge-d-real/`。
- 最终回读：camera-service380、原厂GUI25589/running；LiveView Active/transportNone，/system只读，原厂程序/init哈希匹配；bridge d已停止、18762转发移除，保活继续。需下次重新核实实时状态。
- 原生照片/视频混排索引仍未接通；没有写DCIM。物理拨轮/触屏手感需单独验收，不能用本次自动播放器测试替代。
- 高规格自有下游离线实现：`native-video/experimental/hevc/`。传感器/ISP全视场调查：`research/full-fov-pipeline/`。真实4K/60/HEVC/Main10尚未验证；未初始化未知编码器、改寄存器、刷固件或改启动项。
- 三名子代理模型均为gpt-6.1-sol/high。UIUX目录与可移植UI冻结；codec负责离线HEVC下游、native_album转做full-FOV来源。不要恢复旧模型代理。

## 模拟器首版交付（本轮最终接续点）

- `native-video/simulator/打开相机界面模拟器.command` 可双击启动，`README.md`逐页记录覆盖和未覆盖。root已校验最终4个源码SHA匹配测试报告，并在Mac启动供用户评审；运行信息在 `simulator/evidence/user-launch.json`。
- 最终 **51项桌面检查通过、0 Qt warning/error、14张最终截图**。复用原厂DriveModeGrid、曝光控件、BrowseGridItem/BackArrow、SVG图标、HS Sans字体；已从ELF恢复SVG的10000定点缩放契约并修正多余1.6倍。原厂提取资源SHA未改变。
- Playback→统一相册→视频静态预览→明确点Play→真实样片帧播放→返回选中视频→返回同相册已用Qt实际命中测试。LiveView循环样片；168帧解码不补重复帧。所有这些都是桌面模拟，不是原厂储存索引、硬件decoder或真实实体快门已实现。
- 完整MainContent/MainStateMachine、全部主菜单与设置页、硬件行为等**尚未1:1重建**，不要称全量模拟器完成。后续由同一UIUX代理按覆盖清单增量补齐；当前首版可给用户确认流程。新UI仍未上机。
- `publish_native_video.py` 14项安全检查通过；又对第二段369帧真实证据做完整严格解码、状态/manifest/SHA与真实JPEG验证，结果 `outputs/native-album-research/real-bridge-c-inspect.json`。没有生成设备发布计划或写入DCIM。
- 三个子代理当前均完成本轮交付并保留为后续负责人，模型均为gpt-6.1-sol/high；不要恢复旧模型代理。相机最终安全状态仍以20:28节回读为准，此后只有只读获取manifest/state，没有新UI部署或录制。

## 20:28 更新：UI 模拟器独立推进；bridge c 连续录制与预览恢复已实测

### 最新用户约束与分工

- 用户要求 UI/UX 专职子代理制作 1024×768 相机模拟器，先重建、试用界面，**用户确认后才将新的 UI 上机**。根代理负责录制管线和硬件安全。此约束取代此前可直接进行新 UI 临时上机测试的工作方式。
- 所有在用子代理已重建为 **gpt-6.1-sol / high**：`uiux_simulator_sol`（仅 `native-video/simulator/`）、`native_album_sol`（原生索引研究和离线发布计划）、`codec_pipeline_sol`（离线编码能力/ABI）。旧模型代理已中断，不再恢复。
- 用户已亲眼确认录制时机背实时画面正常，实体 Playback 进入/播放可用；触摸不灵敏待优化。用户最终要照片/视频共用原厂相册、原厂风格控制，当前独立 VideoGallery 只是中间实现。不要把模拟器的混排相册当作实机索引已接通。

### 本轮实机管线证据

- `x2v_session_bridge_20261011c` SHA `7814c4502f28814d3454e439c13a94ec69aa58c9ffa65f3d9c98fc48825ff6ee` 已添加到自有 `/system/bin/` 路径，仍使用 recorder b。支持从普通 Active/None 实时取景规范化开始录像；独立 `/preview` 请求在确认停止后恢复普通实时取景，不在相册自动抢占画面。未知 USB/RTP 所有者拒绝接管。22组宿主机 ASan/UBSan 测试通过。
- `native-video/outputs/bridge-c-real/`：从 Active/None 开始约5秒，162帧、5.408333秒、8,852,209 bytes，1300×970 H.264 High / 8bit，平均约29.95fps；SHA `e72570a984afed718ede738042e0ed5ab2015c1e6768d0a7bd04d4e4373d18cd`。停后 `/preview` ready，实读 Active/None。
- 同一 bridge 连续第二段见 `outputs/bridge-c-repeat/`：手动请求停止，369帧、12.308333秒、20,115,116 bytes；SHA `f044c5e47820be04e77e1018c4e1cb430f854dd768b789015de3fc78cf445dfa`，从 stop 请求到 saved 约962ms。两段设备/电脑SHA相同、FFmpeg全帧解码零错误。
- 这些是 HTTP 控制的真实相机管线测试，不是新 QML 自动预览意图的实机验收；`HttpRecorder.qml` 的一次性恢复、相册中不恢复、失败保留 saved 仅有本地测试。新的 UI 仍待模拟器确认。
- 最终 `bridge-c-repeat/final-device-readback.json`：camera-service=380、原厂camera-gui=5313/running，测试前后未重启；LiveView Active/None，/system只读，两个原厂程序与两个init配置SHA未变。本轮闲置bridge按exe+PID+starttime停止，18762转发移除，无录制器/GUI会话锁。用户要求的保活保留，screen_idle_timeout=0。

### 播放器稳定性与高规格边界

- 早于模拟器门禁的用户试看片段中，原生GUI PID545曾在停止播放时 SIGSEGV（null+0x40）。证据 `outputs/monitor-user-check-v2/crash.log`。watchdog恢复原厂，camera-service未重启、成片完好，不能声称没有发生过崩溃。
- 静态定位：VideoItem::setSource("") 清空worker，但排队的startDecoder回调仍访问worker。`VideoItemSessionAdapter.qml`候选修复改用Loader销毁原生对象并等待guarded QObject确实销毁，不再先写空source；本地生命周期测试通过。`outputs/playback-release-regression/`的55秒有界实机跑完并恢复原厂，未看到该PID新增crash，但logcat主缓冲已轮转，**不足以证明完整3次循环与自然结束所有步骤**。不得冒充完整回归通过，也不要越过新UI审批门重复部署。
- 原厂LiveView由独立Wayland图像层合成；Toolkit的Qt截图黑底不代表机背无监看。按用户反馈，此问题已确认是抓取边界，不再当作监看故障继续改动。
- `native-video/CAPABILITY_RESEARCH.md` + `research/codec-capabilities/README.md`：HEVC库存在不等于此机可用；EWLInit会打开电源/内存/编码器设备，不能为只读能力查询执行。原厂RTP sender明确使用AVC FU-A与低5bit NAL分类，HEVC必须改发送路径及接收/封装。4K/24/30/60、真正10bit及无额外裁切尚未验证，没有修改编码器/ISP配置。

以下为较早快照，当前状态以本节和最新实机回读为准。

## 19:52 更新：一键界面录屏与自动恢复已完成实机验收

- `native-video/outputs/camera-toolkit/final-one-click/report.json` 为最终成功报告：30.011秒，60次采样，59帧保存，1次 `grab_in_flight` 跳帧；导出MP4含一个末帧时长补帧，不能把编码60帧说成60张独立截图。MP4与逐帧时间戳在同目录 `capture`。
- 本轮平均保存66ms，单次最大862ms；Qt同步保存仍可能让界面短暂卡顿。它用于有界测试复查，不能承诺无开销或捕获每个瞬时错误。原厂LiveView图像层黑底，菜单/文字/红框和原生VideoItem回看画面可采集。
- 已修复独立恢复进程与主动停止并发时重复进入restoring的竞态；取恢复锁后再次检查完成标志与会话所有权。11组本地进程测试通过，移除修正的负对照能稳定复现旧问题。一键工具等待恢复完成标志与锁释放后再查询原厂GUI，最终 `success=true`、恢复确认true。
- 前两轮失败报告保留：`first-real-one-click` 是预检返回完整ps列表导致USB响应超时；`one-click-verified` 已录60帧，但恢复检查读到中间状态，报告false。最终报告没有覆盖这些证据。
- 收尾已按身份停止本轮空闲bridge b并移除主机18762转发；无录制器运行。camera-service仍PID380，原厂camera-gui=30668/running，LiveView Active/None，原厂两个程序和两个init配置SHA未变，/system只读。证据 `final-one-click/final-device-readback.json`。用户要求的保活继续保留。
- 下一步仍是Drive Mode/Playback手动入口、实体快门与长录验收；本轮没有将临时开发会话改为开机自启。

以下章节为较早快照，当前状态以本节和最新实机回读为准。

## 19:44 更新：SSD 直接短录与红框/回看完整链路已通过一次

- 新录制器 `x2v_recorder_20261011b`（SHA `5d3090ef464ec4b5f1b23d241e6d0e0d4355c465a83f303388dc411e10bc2bd3`）增加只允许首帧提交前的同序号冲突诊断/至多两次重建；严格 RTP 模块未放宽。5项真实样本故障回放、原10+7项有界录制测试通过。
- bridge b 指向新不可变路径；`/system/bin/x2v_session_bridge_20261011b` SHA `a6e3b03eba84d8d2f87366f6ba189197452e27afc15cb0567159872569157a5e`，本次手动启动仍带900秒独立超时。原bridge已停止。
- **实机成功**：`/mnt/media_rw/ssd/X2V_VIDEO/X2V_20261011_114000_25158_1.mp4`，8,339,638 bytes，162帧，5.408333秒，1300×970 H.264；正式 manifest 已发布。SHA `cf6b43c0d866e12f90ca499981e0e62031c1f4099710bf7e1f51f044912ccd99` 与 Mac副本一致，ffmpeg完整解码零错误。证据 `outputs/integration-b-1940`。
- 此次真机 `STARTUP resets=0 conflicts=0`，所以是新版本一次成功实录，**不是相机实际触发恢复分支的证明**；启动冲突恢复目前有离线真实样本注入证据，仍需实机重复覆盖。
- `outputs/screen-audit/record-save-playback` 留下35秒70帧、0skip的真实GUI录屏。状态序列starting→recording→finalizing→saved，player loading→playing→ended→stopping→idle。抽帧recording.png四角红色#ed353d；saved无红框；ended.png显示新片画面和“播放结束”；idle返回视频列表。程序化测试入口含定时打开/退出，只存在该次冻结测试包，正式main没有自动播放计时器。
- 原生player解码入队162帧；EOF处仍出现 `Demux -1007` / 等19个buffer / Timeout，再worker退出、QML ended；此次停止到idle约20ms。不要把内部warning抹掉或说所有异常均修复，也不要把worker状态3误读成QML Error。
- 原厂界面已恢复，普通set_live_view(true)已重新开启；新录屏工具的一键端到端测试正在进行，结果以 `outputs/camera-toolkit/first-real-one-click/report.json` 为准。
- 根目录新增 `录制相机屏幕30秒.command`，包装 `camera_toolkit.py record`；默认启动只含原厂两Loader和屏幕审查组件的临时GUI，2fps/30s/BMP，导出MP4/JSON，独立回收本轮并读回原厂恢复。显式--attach才能复用正在开发的GUI会话，避免打断录制。

下面19:34小节与更早记录为历史，遇到状态冲突以本节和实机回读为准。

## 19:34 更新：机背回看已实证，界面录屏已实证，SSD 直接录制仍在修复

- 用户最新确认：视频列表、播放、返回全部看到了，没有报错；新增要求是开发相机界面录制 toolkit，减少人工盯屏。
- 已找到二代临时 GUI 接入：`native-video/runtime/gui_bootstrap.c` 在手动 camera-gui 的 Bionic main trampoline 之后，验证固定构建和 QString 前缀，只替换本进程的主 QML 路径；原厂资源、文件和启动配置不改。自有库 `/system/lib64/libx2v_gui_bootstrap_20261011.so` 已主动写入 system 后恢复只读。这是新增自有文件，不能再笼统声称从未写 system。
- 临时 GUI 已多次实机启动、超时/手动结束后恢复原厂 GUI；camera-service 一直是 PID 380，GUI 已有意重启多次。`gui_session.sh` / `gui_session.py` 用统一锁、不可变包、完整 SHA、每轮目录、PID+starttime 和进程外 watchdog；不要继续用旧 `gui_probe.sh` 的共享 PID 文件恢复逻辑。
- 实际回看证据：`native-video/outputs/runtime/confirmed-player-end.png` 显示“播放结束 / ended”，`confirmed-player-release.png` 显示已回视频列表。用户明确确认。VideoItem 支持完整播放，暂停/seek 尚无已证实接口，UI 已禁用，不可声称支持。旧原生日志有 drain wait timeout 后最终队列回收，仍需新完整日志排查。
- Screen Audit 真机录屏：`outputs/screen-audit/first-camera-20s` 是 PNG 40帧/20秒，0skip，save 平均291.575ms；`outputs/screen-audit/bmp-camera-20s` 是 BMP 40帧/20秒，0skip，save 平均49ms、max78ms，grab平均75.3ms，文件总94,374,000bytes；均有 MP4、真实时间戳和 JSON。它是2fps取样审查，不是30fps全动镜像。原厂 LiveView 画面可能是外部合成层，实际抓到黑底；菜单/文字可见，VideoItem 回看画面此前截图已可见。
- 新 `HttpRecorder.qml`、`AuditControl.qml`、`CameraExtension.qml` 在临时 GUI 内已加载；UI控制通过仅loopback且私有token的 `session_bridge.c`。已修旧回包倒退、启动回包未返回时停止丢失、重载后活动录制必须显红框、停止未确认保留重试按钮、停止中与保存中分开。
- 自有录制器 `/system/bin/x2v_recorder_20261011` SHA `bee8cf2506068d5d92a55d5ac7ad963b8edcd4028fc0a826361c75c4c02be5e2`；自有 bridge `/system/bin/x2v_session_bridge_20261011` SHA `71be9638256f4c98a76ea690c2a1723741c6c34524bc82ddef94b85cbc9389d5`。均以 system_file 标签增加，不替换原厂文件；/system只读已回查。
- bridge 目前手动 factory 域启动，父 timeout 900s，PID20381是该次快照不是永久身份，监听127.0.0.1:18761。host forward 18762。私有token在 `outputs/runtime/session.token` 和设备 `.../session.token`，不要输出内容或提交。
- **第一轮直接 SSD + 新 GUI 集成失败**：`outputs/integration-1932` 与 `outputs/screen-audit/startup-conflict`。0帧时 RTP同序号槽冲突(-9)，630ms安全中止，readback Off/None，目录只有0byte partial/状态/log，没有MP4/manifest。未冒充成功保存。UI录屏70帧/35秒记录 starting→finalizing→error；正在加严格的启动前诊断/有界重同步，已录制后的包错误仍必须失败。
- 该失败后已停止临时GUI、确认恢复原厂，并调用普通 set_live_view(true) 恢复 Active/None；camera-service没有重启。正常录制停止仍采用 Off/None 门。固件静态证据表明 true,Rtp 自带 ShowModeGui，无需启USB；false,Rtp会关整个Liveview。保留预览的停止方案还需短测，不要直接改成All。
- Drive Mode动态卡片与原厂相册的视频入口已有组件/桌面测试，尚缺用户手动点击的实机闭环；实体快门接管未实现。不要把全部机内产品化/重启保持/高级格式/自动对焦实验称为完成。

以下为18:52之前的历史进展，状态以本节及最新设备回读为准。

用户要求：修正 Phocus 报错/停止；完整机内录制；Drive Mode 视频入口；类似 FX3 的录制红框；正常机背回看；随后研究高分辨率/码率/封装/DNG/Log/LiDAR/AF-C/人脸。允许操作设备和下载依赖，要求避免变砖。另要求持续亮屏与连接保活。

## 已完成

- USB 修正：持续读取贯穿启动和停止，停止异常仍回读/重试；3、3、10s 三轮通过，末尾残包为0。用户在本轮测试后确认：几次机内短录期间没有再出现 Phocus 传输失败或其他屏幕报错，保活开启后屏幕一直亮着。该确认只覆盖本轮测试，不替代长录或异常断连验收。
- 真正机内封装：native-video 中的 ARM64 静态程序在相机执行，接收原厂 loopback RTP（127.0.0.1:5000；向5001发送小握手）。原厂目的端地址因此在 RAM 中指向 loopback，下次 RTP 客户端握手会更新；当前 transport 已关闭。
- 最新自主录制：native-video/outputs/autonomous-20261011-183608/recording.mp4，168帧，5.608333s，1300×970 H.264 High / 8bit YUV420 / BT.709，10.74Mbps；启动和停止均由相机端脚本执行，Mac只在结束后回收结果。没有实际拔线验收。
- 相机本地复制该文件到 `/mnt/media_rw/ssd/X2V_TEST_20261011/X2V_183608.mp4`，SHA匹配；当前先录 blackbox 后复制，不能称为 SSD 直接长录。
- 机内解码：130帧旧片与电脑解码逐帧MD5一致；新片从2s定位后的8帧也一致。未进行屏幕播放。
- Qt UI 自写组件与桌面夹具已完成七种状态渲染检查，outputs/ui 有截图。未装上机背，不能说 Drive Mode 已能使用。
- 保活：local-verification/keepawake.py 和根目录两个 .command。当前后台 worker 持续续租，屏幕保持亮；没有固定时长限制。停止/主机worker退出后相机watchdog自动释放锁并恢复原熄屏值（初始300s），恢复路径已经实测。当前 PID 以 keepawake-state.json 为准，勿依赖本段文档缓存。

## 新发现与修正

- RTP 包乱序，实测不丢包但跨几十个包重排；实现256包窗口，序号回绕与FU-A/STAP-A。丢包不发布成片。
- 原型互斥锁 trylock 会误报队列错误；独立进程改普通加锁。
- su 域禁止硬链接：用 renameat2(RENAME_NOREPLACE) 发布，保留现有文件。
- 原厂启动时短暂切换 SPS；等待至少1s、参数稳定750ms且遇到IDR才写入。参数在已录制时变动仍报错，不静默降级。
- 早期自主试验一段实际只有53帧/1.78s；另一段因参数变化拒绝发布。现在控制脚本等待实际 recording 状态才计算5s，最新结果168帧通过。仍需重复/长录验收。

## 当前设备状态与边界

- camera-service=380、camera-gui=383、phocus=1096，未重启；live_view Off / transport None / Initialised。
- /system 只读，两个启动配置哈希与官方固件一致；没有刷固件、改变SELinux、Frida挂接或修改启动项。
- `/blackbox/x2v-native-20261011` 中有本轮小程序、短片、FFmpeg诊断程序和保活脚本；是主动启动的临时开发工具，不开机自启。
- /tmp/x2v-native-20261011 最早上传的探测程序因SELinux拒绝执行；已转用blackbox+ADB su成功运行。不要继续反复尝试tmp执行或解除全局SELinux。
- ADB su 可以执行blackbox程序，不能访问原厂D-Bus/写SSD/挂接GUI；工厂域能访问D-Bus/SSD，但不能执行tmp或blackbox载荷。此边界是当前GUI接入的主要问题。
- 没有经过验证的二代附加QML安全加载/卸载路径。不能直接运行一代安装器或靠修改启动项冒进。
- 测试录制器仍限制12s/64MiB输入；机背播放、长录、照片/视频切换与高级规格尚未完成。

下一步应先完成适用于二代的临时GUI接入和卸载验证，再连接真实后台状态、Drive Mode、实体快门、红框、视频列表与播放控制。不要把仅桌面通过的QML截图当实机已安装。

## 用户在原生 Playback 页复核（2026-10-11）

- 用户确认当前相册仍仅显示之前的照片，没有视频。这符合当前未接入视频列表/播放界面的状态，不能把机内解码测试称为原生相册回看成功。
- 本轮只读重查：SSD 样片仍为 7,532,078 bytes，SHA-256 `4ee319cca42f629d51131ca32b073e57c79c8ce173f53dc14bfea81a12d0ff83`，与原始复制证据一致；屏幕 Active、idle timeout 0，预览 Off/None。证据 `playback-current-check.json`。
- 原厂 QML `viewmodels/BrowseViewViewModel.qml:66-68` 的播放/暂停状态固定为 false；374-390 行的 start/control/stop 是 TODO 注释。`browseview/BrowseListView.qml:279-285` 没有视频 delegate 分支。
- 实机方法列表中 camera 没有 start_playback/control_playback/stop_playback；gui 无方法。证据 `playback-api-methods.json`。不能仅取消 QML 注释就得到播放器。
- storage 的逻辑卷为 `/ssd`，文件系统根为 `/mnt/media_rw/ssd`；对自建目录 `/ssd/X2V_TEST_20261011` 调用 browse 返回 Non existing item，尽管文件系统可读。物理路径直接传给 browse 则返回 Device not mounted mnt。证据 `playback-sample-browse.json`。这仅证明当前测试目录未被此浏览接口识别，尚不能推断合法相册目录内 MP4 的识别规则。
- 新线索：`mainmenu/FirstTimeGuide.qml:294-304` 使用原厂 VideoItem 播放 `/system/usr/share/video/ftg.mp4`；该原厂片为 1024x768 HEVC Main 10 / 25fps。可继续评估现有播放器复用，尚未尝试加载我们的片段，也没有通过更换原厂引导视频来演示。
