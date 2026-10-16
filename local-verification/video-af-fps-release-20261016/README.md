# Video frame-rate release and close-focus investigation — 2026-10-16

## Installed changes

- Persistent product supervisor now selects exact profile IDs; ProRes RAW HQ 24/25/30 fps choices in RecordingProfiles.qml.
- 25 uses driver17/C with 36 MHz /450/3200 timing. 30 uses driver18/D with 36 MHz /400/3000 timing. Same output3888×2912; transport3920×2946. Native AF rate getter and MOV/clip metadata agree with each profile.
- Frame-rate changes require normal video graph exit/reentry (measured~17s); record is disabled until the running graph matches the choice. No switching during recording/finalizing. Codec/frame-rate selection persists in product/profile; duration and thermal/storage limits remain.
- Installed session /system/etc/x2v/x2v_video_session_20261014zl.sh; supervisor /system/etc/x2v/x2v_product_boot_20261015c.sh. Exact pre-change scripts and GUI archived in this folder/device fps-release-20261016 rollback0..3.
- 30 fps UI explicitly says experimental / possible dropped frames. DNG remains24; H264 remains unavailable.

## Actual recordings

See fps-results.json and clip25.json/clip30.json. All stopped and saved normally with no active camera error.

| Trial | Source timestamp estimate | Seen | Written | Dropped |
|---|---:|---:|---:|---:|
|25 first|24.99945|170|169|1|
|25 warm|24.99945|171|171|0|
|30 first|29.85293*|205|198|7|
|30 warm|29.99931*|196|191|5|

*The current estimator mixes delivered count with first/last admitted-frame timestamps; with dropped frames it is approximate, not a complete all-source-timestamp trace. Native timing/source config is30; this does not prove sustained zero-drop30 recording. Drop counters identify primarily preprocessing/source-slot pressure, not SSD write failure. Warm30 copy max15ms, preprocess max43ms, write max from clip.json. AF motor controller paused during these qualification clips; ToF statistics plumbing remains installed. No claim of sustained30+activeAF qualification.

## Near focus — NOT fully fixed

- Initial failure: actual lens547 then275, native MOD2344/INF0. ToF estimates around0.48m, target around2190, but native output confidence0. In historical user-handling sequence it also selected~3m and pulled far.
- Restarting the video service cleared this state. A diagnostic build adding read-only logs and bounded context dumps, without changing focus behavior, moved275→~2200 with native confidence60. User: much clearer, still slightly defocused.
- User repeated MF→AF: no large pullback this time, still slight defocus. Native ToF parameters byte-identical across this cycle. This is NOT proof that the intermittent pullback bug has been repaired.
- User's manual best focus2331; AF settled2175–2199. Both inside original MOD2344. Do not broaden motor limits to compensate.
- Native af_imx861.json output_confidence defines60 as rlt_dir_ok_peak_range_confidence. Existing threshold80→60 enables this approximate ToF result. It is not optical best-focus confirmation. Video still lacks a verified PD/CD image-based fine-focus loop.
- cycle-af-near.png and manual-near.png capture the same static ColorChecker scene; manual image visibly sharper. Simple ROI gradient-energy comparison is diagnostic only, not calibrated MTF or a general AF acceptance metric.
- Near probe executable only collects native context/params on a marker, at most3 captures. Permanent release selector restored immediately; runtime subsequently restored to accepted library. No register or motor-limit edits.
- Wide mode is not established as full-area image autofocus/recognition: native config includes ToF foreground preference, but missing recognition/PD/CD means menu selection alone cannot prove full-area targeting/tracking.

## Remaining work

1. Reproduce stale/incorrect-confidence far pullback with matched native pre/post context; distinguish region selection, temporal state, and MF/AF transition.
2. Add image-based fine-focus confirmation/refinement; do not apply the one-scene~150-position offset as a global calibration.
3. Optimize30fps source-copy/preprocess scheduling and qualify active AF + sustained recording. Do not label it drop-free yet.
4. Physical reboot persistence not tested in this pass; files and selection are persistent, live profile switching was tested.

## Final handoff

- Updated exact installed ExperimentalVideoSettings.qml footer to remove obsolete 24-only claim; screenshot fps-options-final.png shows 24/25/30, selected25, and30 experimental warning. Returned to live view.
- release-last-state.json: videoidle25, manualfocus, AFidle, no active error, temperaturelow. Development keepawake retained.
