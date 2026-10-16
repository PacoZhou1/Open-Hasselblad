# 2026-10-16 recording + ToF AF checkpoint

User confirmed the on-camera record button starts the experimental focusing test ("好 搞定了"). This is the working checkpoint before person/subject recognition and tracking integration.

## What is implemented

- MODE21 3920×2946 / 24 fps ProRes RAW retains the aligned ISP preview path.
- Reattach the native ToF consumer and its AF statistic subscription. Use the native continuous controller, distance calibration, confidence and motor limits.
- Fix observed ToF point-copy truncation: native producer copies 8 bytes per point while producer diagnostics and ADS6401 consumer use 10-byte records. Forward complete native source records after prefix verification, preserving measured values.
- The temporary controller uses ToF as master because live PD/CD statistics are not yet available in this video mode. This is not complete stock hybrid AF-C.
- `afc-button-session.sh` ties native `find_focus` to the actual in-camera recording action. `afc-record-watch.sh` requests normal stop after 25 seconds, scoped to its own clip. User can stop earlier with the same touch button.
- No host wait window. A saved boot UUID enables this experiment only for that boot; subsequent boots select the stable aligned receiver. Do not call this permanent AF deployment.
- Existing body full-press remains intentionally gated; use the screen record button. Native photo mode and baseline recovery remain available.
- Previously installed duration UI (default 5 minutes, 1–30 minutes/unlimited) and native-status-based thermal/storage controls are included in this checkpoint. The experimental 25-second stop is additional.

## Evidence and limits

- `toflimits-132956`: static target 978–982 mm, native confidence80, lens938→940–942, clean photo recovery.
- `toflimits-dynamic-133857`: 28.3s,677/678 frames written,1 preprocessing drop,max write20ms,no active error,clean recovery. User did not see movement cue; not a verified dynamic-tracking run.
- `toflimits-button-install-142323`: on-camera AF request and25-second automatic stop confirmed; 25.98s,618/622 frames written,4 preprocessing drops,max write22ms,no active error. GUI screenshot confirmed red border and REC clock. User subsequently confirmed operation.
- These specific clips have not separately passed decode/playback acceptance. Person recognition, subject identity tracking, PD/CD fusion, arbitrary ROI and tracking accuracy remain open.
- Known fixed test errors: removed a lens-model diagnostic with the wrong native ABI; dismissed only the known USB-connected notification; replaced the expiring host-trigger test with the device-local record hook.

## Rebuild / recovery

Requires the matching privately supplied X2D II1.3.16.2 extraction under `resources/extracted/`, Zig Python package and pyelftools. Firmware binaries, raw captures and local debug dumps are not part of this checkpoint.

1. Build `native-video/experimental/rx-prr-explore-toflimits-20261016/build.py` with the project Python environment.
2. Run `build_afc_button_session.py` to pin the built library in the boot-scoped session script. Its checked-in `stable-baseline.sh` is the exact aligned baseline used by the tested camera.
3. `install_afc_button_test.py` is an operator-owned physical-camera installer and automatic25-second smoke test, not a host-only check. It requires the established factory access and camera-testing lock. It intentionally leaves successful video mode ready for user recording. Do not run concurrently with another hardware operator.
4. To remove: stop/finalize any recording, exit video, restore `stable-baseline.sh` to `/system/etc/x2v/x2v_video_session_20261014zl.sh` with the established labels/mount handling, and remove `afc-test.boot` in the camera's `fps-explore` directory. A normal reboot also disables the candidate via the UUID mismatch, though the wrapper remains installed.

Built receiver SHA-256 at acceptance: `a7f2aef85196424f8e41aa1026f545ca9f4f38def35cdea75db62ea86e18a409`.

Full local investigation notes: `FOCUS_ATTACK.md`. Only selected structured receipts accompany this checkpoint; image/video captures remain local.
