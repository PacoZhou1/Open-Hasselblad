# X2V 装机参考

## Paths

| What | Path |
| --- | --- |
| Overlay GUI | `/blackbox/x2v-native-20261011/gui/` |
| Product logs | `/blackbox/x2v-native-20261011/product/` |
| Clips | `/mnt/media_rw/ssd/video/` (`YYYYMMDDHHMM` + A/B/C). Leftover `X2V_RAW/` still listed. |
| State | `/tmp/x2v-product/state.json` |
| Installer | `/system/etc/x2v/x2v_fw_20261013c.sh` |
| Boot module | `/system/lib64/weston/x2v-boot-20261013c.so` |

ADB cannot list `/mnt/media_rw/ssd` (namespace). Factory can. Long factory
`du` exceeds 231 bytes — split the command.

## Shared pins (do not rewrite)

These dests stay as long as their hash is unchanged (zl era):

- `/system/lib64/libx2v_prr_resident_20261014zl.so`
- `/system/etc/x2v/x2v_video_session_20261014zl.sh` (superseded by `20261015a` when that dest is installed)
- `/system/bin/x2v_recorder_20261015a` (stock H.264 RTP mux; new dest)
- `/system/bin/x2v_prr_play_20261014zg`
- `/system/etc/x2v/imx861bqr_hb722_view_20261014zg.conf`
- `/system/lib64/weston/x2v-boot-20261013c.so`
- `/system/lib64/libx2v_gui_bootstrap_20261011.so`

`package.py` `FILES` dest names are the contract. Changing a file that
already exists on the camera with a new hash requires a new dest suffix.

## Factory error service

```
odindb-send -s error --list-methods
# ack(), ack_all(), ack_current(), ack_error(E_ErrorCode)
```

USB connected is `CODE=40 ACTION=1`. `ack_current` is the one that worked.
`doAck` is not an odindb method.

## Overlay vs stock GUI

Overlay = `camera-gui` with `X2V_GUI_ENABLE=1` and
`LD_PRELOAD=libx2v_gui_bootstrap_*.so`. Init `camera-gui` must stay stopped.
Three overlay deaths in two minutes fall back to stock — do not provoke that.

## deploy.py

`deploy.py install` pushes the newest `dist/x2v-fw-*` then runs the installer
through factory `connect()`. Prefer the adb installer path above; factory
`connect()` identity `sha256sum` can wedge the shell.
