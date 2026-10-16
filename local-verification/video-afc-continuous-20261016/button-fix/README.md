# Video continuous AF and body navigation — 2026-10-16

Status: installed persistently; automated input-path pass; user confirmed physical side keys and preview after the second-stage fix ("可以了！").

## Root cause and scope

The stock LiveViewOverlay swallows almost all keys while CameraUI.in_session is true. Native continuous AF enters exposure_status InSession (16), even when no clip is recording. Stopping AF immediately restored keys, confirmed by the user.

Bypassing only the viewfinder key guard was insufficient: the stock menu transition requests liveview off, which is refused until the focus session has ended. First candidate also required retaining the typed LiveViewImage references in MainContent after using a locally named component; both casts now use X2VLiveViewImage.

Candidate changes:
- A narrow viewfinder key exception while custom video mode is active, the native full-press gate is available, native continuous AF is running, and no still exposure is in progress.
- Menu press pauses AF, waits for native session completion, then asks the stock model to open its control screen. No arbitrary fixed sleep determines completion.
- AF watches GUI navigation context: pause in menus/gallery/settings, resume in video viewfinder; physical MF still stops it. Clip start/stop does not own AF lifetime.
- Stock camera binary, raw pipeline, source timing, encoder and full-press protection are unchanged.
- Stock QML copies keep qrc dependencies; main.qml is derived from the actual installed accepted version, not the newer/different repository main.qml.

## Evidence

`key-injection.json`: input via the body's input devices while AF was RunningCont:
1. half press: liveview, RunningCont;
2. menu: control_screen, AF Idle, session None;
3. menu again: main_menu;
4. playback: gallery visible;
5. half press return: liveview, gallery hidden, AF RunningCont again.

`host-test.json`: mock service verifies no repeated AF start, MF stop/AF resume, navigation pause/return resume, and shutdown stop. This does not replace physical acceptance.

Latest live read: error.active_error=false, screen_status Active, video idle. A GUI screenshot does not capture the separate ISP display plane; black in `current.png` cannot determine real preview brightness.

The user reported partial keys and dim preview on the first candidate. After the second-stage fix, the user answered "可以了！" to a combined check of physical side keys and preview brightness.

## Files / recovery

Installed GUI: `/blackbox/x2v-native-20261011/gui/{main,X2VMainContent,X2VLiveViewImage,X2VLiveViewOverlay}.qml`.
Watcher: `/system/etc/x2v/video-afc-watch.sh`.
`installed-main.qml` and `previous-watch.sh` preserve pre-fix files. `build_gui.py` regenerates the candidate from the stock resource extraction and installed baseline. Disable AF first before restoring original main.qml.

## FPS evidence (separate from this fix)

C25: 171 frames, source span 6,800,133 us for 170 intervals => 24.999511 fps, 0 dropped/lost, MOV duration 6.84 s.
D30: 213 frames, source span 7,066,817 us for 212 intervals => 29.999362 fps, 0 dropped/lost, MOV duration 7.10 s.
Source receipts: `../../fps-afc-20261015/{c25-194057,d30-194212}/result.json`.
Current installed AF version remains 24 fps. No long-recording/thermal or AF + 25/30 combination qualification claimed.
