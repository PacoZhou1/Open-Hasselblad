# Recording duration and thermal-stop candidate — 2026-10-15

## Delivery state

Source updated; incremental payload: `../../dist/x2v-record-limits-20261015c`.
User approved permanent installation after the temporary trial. Installed 20261015c supervisor
and three GUI files were read back and match the payload. Boot selection and running command
both point to `/system/etc/x2v/x2v_product_boot_20261015c.sh`. The aligned 20261015b receiver is
unchanged; final video session up/idle, limit 300 seconds, temperature Low, /system read-only.
See `permanent-install.json`. Rollback GUI files are in
`/blackbox/x2v-native-20261011/install-limits-20261015c/rollback`; the old 20261014zm supervisor
remains on /system. No physical power-cycle test was performed. No Git commit/push for this
feature yet.

## Feature

- Native `PopupListSelector`, 1–30 whole minutes, default 5 minutes, plus 永不 (0).
- Native `GenericConfirm` before selecting 永不; exact requested hardware-temperature warning.
- Setting stored atomically at `/blackbox/x2v-native-20261011/product/duration_seconds`.
  Missing/invalid settings fall back to 300 seconds. Busy recording/finalization rejects changes.
- Supervisor reads the resident's monotonic elapsed time; this is independent of GUI timers
  and of frame count. A clip freezes its limit at start. Normal stop/finalize/catalog path is reused.
- Native `system.temperature_status` is read asynchronously every ~2 seconds alongside system state.
  High/Critical stops and saves, then exits video mode without automatic resumption.
  Unknown/stale (>10 seconds) temperature refuses start/stops an active clip.
- 永不 cancels only the duration check. Storage, thermal monitoring and power-off handling stay active.
- Development keep-awake now refuses unsafe/unknown temperature at acquisition and releases its lock
  on high/critical/unknown temperature or a shutdown request. Its normal-temperature running state
  was verified; genuine overheating was not induced.

## Evidence

- `timed-clip.json`: ProRes RAW 3888×2912/24, 60.422 seconds wall time,
  60.375 seconds container duration, 1449 frames, dropped/lost/error = 0, peak write 11 ms.
  Deadline detection at uptime 1246.43; stop started 1246.47; saved 1247.09; wake released 1247.28.
- `thermal-simulated.json`: TEST supervisor injected High; native system temperature was NOT changed.
  Limit = 0. Thermal detection 1609.09; stop 1609.17; save completed 1609.85;
  wake released 1610.10; video exit completed 1615.56. 80 frames, zero drops/errors.
- First thermal simulation saved successfully but exit returned rc=7 because the temporary launcher
  inherited camera-test's disposable cgroup. Migrating the test supervisor into adbd's cgroup
  fixed the test setup; repeat above passed. Normal boot runs under weston's cgroup.
- Changing limit to 60 persisted across a supervisor restart and was read back as 60.
  This is NOT a physical power-cycle test. Trial configuration reset to 300 afterward.
- `settings.png`, `duration.png`, `durationnever.png`: actual on-device QML captures.
  Fonts reduced for readable minute labels; underlying footer hidden while popups are open.
- Host `test_record_limits.py`: actual source functions run in mksh; defaults, invalid/range inputs,
  persistence, deadline boundary, unlimited, busy setting refusal, High/Critical/stale status,
  native query parsing and shutdown-state detection pass. Also run on the incremental payload.
- Existing broader `test_supervisor.sh` is outdated relative to HEAD's gallery changes:
  missing OLD_CLIPS/clip_root fixtures, legacy clip IDs, timing assumptions; it did not pass.
  It is not represented as successful validation of this feature.

## What is established about factory thermal protection

Firmware v1.3.16.2:
- Native LiveviewViewModel/ControlScreenViewModel consume `System.temperature_status`.
- Independent `camera-system` contains `SystemMonitor::updateTemperatureStatus`,
  `SystemMonitor::onTemperatureStatusChanged` at 0xc7510 and multiple sensor monitor classes.
- High (3) emits warning code 55. Critical (4) emits code 56 and schedules a 5000 ms callback;
  callback at 0xc90c4 invokes `SystemMonitor::shutdownSystem` (0x872d0).
- Original `ErrorViewModel.qml` independently describes overheating and shutdown in five seconds.
- PrepareShutdown checks power/wake-lock and camera-service state. Thus system-wide thermal
  monitoring exists, but graceful completion of a custom MOV is not provided by that alone.
- Real camera read Low(1). No genuine threshold-crossing/shutdown test, no threshold edits,
  no sensor-status forcing API calls, and no absolute hardware-safety guarantee.

The incremental package deliberately preserves the actually installed GUI/supervisor baseline;
source HEAD includes other UI/storage work that is not silently included in this payload.
QA-only screenshot commands, fake-temperature input and temporary launcher adaptations are excluded.
