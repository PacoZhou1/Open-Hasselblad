---
name: x2v-camera-install
description: >-
  Package a new X2V suffix and install it onto the Hasselblad X2D II
  (装机 / 装 / deploy firmware / push overlay GUI). Use when the user says
  装机, 装, install the camera payload, or needs the reboot-surviving
  product firmware copied without overwriting a different hash.
---

# X2V 装机

Operator `z-cursor-prr-gui`. Camera `eagle2_hb722` / v1.3.16.2 /
`camera-service` sha `51b9e02f8bfebf388be8dfa163c8e512bee19aeb8ae37a6712727ccc6f26a52d`.
ADB serial `123456789ABCDEF`. Factory HblShell ≤231 bytes.

Do not commit. Do not tap 仅充电. Do not `deploy.py unhook`. Do not restore
the stock GUI. Do not delete `DCIM`. Do not in-place replace a product dest
whose hash differs.

## When to install

Only when the user says 装机 / 装. Code-only work stays in
`native-video/experimental/x2v-product-boot/gui/` until then.

## Package

Work dir: `native-video/experimental/x2v-product-boot/`.

1. Bump `VERSION` in `package.py` to a new suffix (`20261014zm` → next letter).
2. Keep unchanged binaries on their current dest names so `exists_different`
   is not hit. A changed boot script uses the new `VERSION` dest. A changed
   session or resident needs a **new dest name**, not a rewrite.
3. Run:

```bash
/Users/paco/Documents/ChatGPT/哈苏/.venv/bin/python package.py
```

4. Confirm `dist/x2v-fw-<VERSION>/receipt.json` and that only intended dests
   are new.

## Enable ADB

```bash
.venv/bin/python local-verification/camera_access.py enable-adb
adb -s 123456789ABCDEF get-state   # device
```

USB must start as `rndis,mass_storage,bulk,acm`. After enable it becomes
`...,adb`. Skip factory `connect()` for the installer: `sha256sum
camera-service` there can hang HblShell.

## Install (adb path)

```bash
STAGE=/blackbox/x2v-native-20261011/video/fw
DIST=native-video/experimental/x2v-product-boot/dist/x2v-fw-<VERSION>
adb -s 123456789ABCDEF shell "rm -rf $STAGE && mkdir -p $STAGE"
adb -s 123456789ABCDEF push "$DIST/." "$STAGE/"
adb -s 123456789ABCDEF shell "sh $STAGE/x2v_fw_20261013c.sh install $STAGE"
```

`chmod /system/etc/x2v` permission denied is OK. Expect `same` on unchanged
dests and `installed` only for the new boot. Last line must be `OK install`.
`/system` must be `ro` afterwards. `weston.ini` stays
`52892ca9c9321c9cdea13ca0b74b42277cb6d88129b24c1ae0638116105d80f1`.

Verify GUI hashes under `/blackbox/x2v-native-20261011/gui/` against the
receipt. Overlay QML overwrite is allowed.

## Bring the overlay back

ADB `su` cannot see weston/camera-gui PIDs (SELinux). Trust getprop + logs.

1. If `init.svc.weston` is running but there is no overlay hello, and
   `camera-service` is stopped, the supervisor is stuck on its boot gate:

```bash
adb -s 123456789ABCDEF shell 'setprop ctl.start camera-service'
```

2. If weston itself is dead: `setprop ctl.restart weston`, then start
   `camera-service`. Do not `ctl.start camera-gui` (that is the stock GUI).
3. Weston module picks the newest `x2v_product_boot_*.sh` by name.
4. Supervisor log must show `overlay_start` then `cmd … hello`.

## USB error 40

enable-adb raises CODE 40. Do not ask the user to tap 仅充电. Factory:

```python
# factory_session.connect(); odindb-send -s error -m ack_current
```

USB config must stay `rndis,mass_storage,bulk,acm,adb`. Enter then retries
and should print `job_end enter rc=0 out=up`.

## Live check

Factory `cat /tmp/x2v-product/state.json` (ADB often cannot read it):

- `backend_ready: true`, `session: "up"`, `phase` idle/recording
- `gui-state.json` has `badge: "视频"`
- `preview_gen` advancing
- `init.svc.camera-gui` stays `stopped` (overlay is not the init service)

## Do not

- `deploy.py unhook` or restore stock `weston.ini`
- Reboot unless weston/camera-service will not come back
- Change ISP / `wl-disp` / group13 / view conf / DNG / PRR / player unless
  the request is a player or UI change
- Overwrite a different-hash dest; bump the file name instead

## Details

See [reference.md](reference.md) for dest pins, factory limits, and the
USB-ack method list.
