# Video continuous-AF focus-point lockout candidate

Status: installed in the persistent GUI directory; host Qt checks and native
repeated-touch input checks passed. User physically tested and accepted the fix:
“成功了 我试了试 可以把这个版本编译装机”. Release evidence is under
`releases/x2v-20261016-af-focuspoint/installation.json`.

Automatic event0 arrow injection did not move the point; do not describe that
as a passed joystick test. Physical acceptance is the user's report. No reboot
or recording test was performed specifically for this change.

## Recovery point

`main` / `c67f3c8db1367a7fdd5e316c7342ec742ccf29c4`, pushed and confirmed on
`origin/main`. Exact prior GUI is under `releases/x2v-20261016-af-fps/files/`.
That release preserves the user's important version, including its reported
focus-point lockout. Keep the frozen release unchanged.

## Finding and change

Continuous AF leaves `CameraUI.in_session` true. Stock `LiveViewImage.canClick`
and drag handling reject input during that session. Independently,
`LiveviewViewModel.AutoFocus.onSetCameraFocusPoint` discards all point writes
while in-session, including joystick and reset requests.

`X2VLiveviewViewModel.qml` inherits the original model, preserving compatibility
with stock typed indicators. It overrides only point-setting functions and uses
the stock AutoFocus component for clipping, crop geometry and joystick steps.
It permits point writes during video continuous AF only, respecting native
can-change permission, exposure, zoom and control-screen swipe restrictions.
The true session state remains unchanged. Touch/drag and EVF movement gates
use the same exception. Photo, menu and exposure handling remain stock.

The GUI telemetry includes real session/AF status, focus point, native
can-change permission and the new point-movement gate for device diagnosis.

## Validation

`test_focus_gate.py` executes the real candidate QML in a host Qt engine with
mock camera proxies and geometry, and calls through the original typed model.
Repeated A → B → A taps, joystick/reset dispatch, unchanged true session state,
photo/single-AF/exposure/native-permission/zoom/swipe rejection and stock idle
movement all pass. See `host-check.json`. This does **not** prove native camera
acceptance, physical input delivery, actual crop geometry or recording behavior.

## Original device test plan (status above supersedes)

1. Reconnect camera, read current GUI/session state and enable keep-awake.
2. Back up the three existing GUI files. Stage the new model and changed image,
   overlay and main QML. Pause continuous AF, replace GUI files and reload only
   the overlay; preserve the camera-service, sensor/ISP/encoder and recordings.
3. Confirm GUI load and telemetry; roll back GUI if load fails. Resume AF.
4. Exercise actual touchscreen A → B → A, joystick and center reset, reading
   camera focus_point after each. Confirm AF remains active and menus work.
   If native can-change is false or the camera rejects writes, investigate that
   boundary before claiming success; do not simply bypass it.
5. Check the same input flow while recording, then user acceptance.
6. Commit the verified fix separately from the c67f3c8d checkpoint.
