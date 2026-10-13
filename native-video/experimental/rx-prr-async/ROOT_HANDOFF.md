# RX-PRR async writer (ProRes RAW HQ)

Cloned from RX25. Token `GROUP13_MODE21C24_PRR_ASYNC_V1`. Artifact `build/target-token/libx2v_mode21c24_prr_async_v1.TOKEN_REQUIRED.so`.

Unchanged: MODE21 callback, map/sync/copy/unmap, 3-slot CPU ring, 240-frame cap, 47s constructor, two-clip control FDs, XMD1 sidecar.

Replaced: DNG prepack/pwrite/rename with in-process Moonshadow encode + one `clip.mov` (`aprh`, 3888×2912 HQ) and `clip.jsonl`. Encoder opens on first `sequence_begin` (after the native HAL is already up). Frame ION is cached and synced before `encfrm`. `inotify_add_watch` falls back to `/tmp` so codec debug hub cannot abort camera-service.

Host proof: `host-test/check_integration` (ASAN/UBSAN) writes two stub `prrf` samples, publishes `clip.mov` + `clip.jsonl`, keeps XMD1 hex, and still refuses CPU free when the backend join fails.

Colour in the live path is the provisional DNG AsShotNeutral (CCT 3961), not a live AWB.

Not done here: session packet / controller awk, device two-clip capture, playback.mp4 transcode, UI rename.
