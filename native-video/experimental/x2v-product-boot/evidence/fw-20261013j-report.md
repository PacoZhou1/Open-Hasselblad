# x2v firmware 20261013j — device verification (2026-10-13)

Installed on the camera, weston.ini hooked to `x2v-boot-20261013c.so`, supervisor
`x2v_product_boot_20261013j.sh`, session `x2v_video_session_20261013e.sh`, receiver
`libx2v_prr_resident_20261013g.so` (sha b514d562…).

## Viewfinder, photo mode, half-press (VOP0 plane4, 50 Hz panel)

| condition | rest fps | half-press fps | repeats/s on half |
|---|---|---|---|
| stock firmware (C1–C3) | 49.5–50.1 | 49.3–49.6 | 0.4–0.6 |
| product before SCHED fix (A) | 45–47 | 41–43 | 7–9 |
| fw j, settled (J5–J7) | 49.0–49.3 | 49.0–49.5 | 0.6–0.8 |
| fw j, <1 min after leaving video (J3–J4) | 49.4 | 47.3–48.1 | 1.9–2.6 |

## Recording (24 fps ProRes RAW, ~22 s clips)

| build | first clip of session | later clips |
|---|---|---|
| receiver e (before) | 3–6 dropped | 3–4 dropped |
| receiver f (harvest spin fixed) | 10 dropped | 0 dropped |
| receiver g (+ encoder opened at entry) | 1 dropped | 0, 1 dropped |

Idle video session CPU: camera-service 1027 → 274 ticks / 8 s after the harvest fix.

## Shutdown / reboot

- Reboot while recording: clip saved (264 frames, error 0, in catalog), reboot went through, came back.
- Reboot from idle video mode: through in ~2 s, booted back into video mode, ready at 25 s uptime.
- Root cause of the earlier stall: PrepareShutdown waits while the owned camera-service runs.

## Not yet verified on device

- The "Ignoring set live view" retry (the boot race did not recur on the last boot).
- Video-mode preview is the 10 Hz PPM path, not the 50 Hz display plane.
