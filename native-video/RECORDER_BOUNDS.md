# Bounded recorder interface

2026-10-11. These are source/host-test capabilities. The bounded binary has **not** been deployed or accepted for long recording on the camera.

## Launch

The original short-test form remains:

```text
rtp_recorder /absolute/unique.mp4 12
```

It selects a 12-second receive deadline, a 64 MiB final-file ceiling and a 128 MiB free-space reserve. Short form accepts 1–12 seconds.

Explicit bounded mode:

```text
rtp_recorder --bounded /absolute/unique.mp4 60 128 128
```

Arguments are maximum receive seconds, maximum file MiB and optional free-space reserve MiB. Allowed ranges: 1–1800 seconds, 1–4096 MiB file, 64–65536 MiB reserve. The reserve defaults to 128 MiB. These ceilings are safeguards, not tested camera specifications. The muxer has an additional five-second monotonic deadline for draining/finalization. A filesystem syscall blocked inside the kernel still requires an external process watchdog; this is not a hard real-time guarantee.

The recorder listens only on loopback UDP 5000 and sends the stock three-byte handshake to loopback 5001. It does not start or stop the stock camera transport. A separate controller must:

1. Start the receiver and wait for `READY`.
2. Start stock RTP transport and observe fresh `phase=recording` with increasing `frames`.
3. Stop on a user request, `stop_required=true`, or an error/stale state.
4. Confirm stock camera Off / transport None, then create `unique.mp4.stop`.
5. Check terminal `phase=saved`, successful exit and a final MP4 before listing the clip.

The receiver drains until it sees `.stop` and 400 ms of quiet. `.stop` must be created only after the stock transport stop is confirmed. A stale output, partial, stop or state file prevents launch. Use a fresh clip stem per run.

`stop_required` becomes true within five seconds of the receive deadline, within the file-size margin (25% of the limit, capped at 16 MiB), or within 16 MiB of the free-space reserve. The controller should stop immediately when requested. If it cannot stop in time, the recorder aborts and retains `.partial`; it never silently treats hard-limit truncation as a saved recording.

## State and errors

The original state fields and C `X2vStatus` layout are preserved. JSON schema 2 adds `pid`, `monotonic_ms`, `elapsed_ms`, `last_packet_monotonic_ms`, `last_frame_monotonic_ms`, `file_bytes`, `free_bytes`, `max_file_bytes`, `min_free_bytes`, `max_seconds`, `received_bytes`, `stop_required`, `signal`, and `reason`. State is atomically replaced about every 100 ms while receiving. A file-write/state-write failure is an error, never a reason to show REC indefinitely.

A newly written frame advances `last_frame_monotonic_ms`. No completed frame within five seconds of launch, or no frame progress for two seconds during capture, aborts. Missing RTP packets, changed H.264 parameters, socket failures, active-capture SIGINT/SIGTERM/SIGHUP and hard deadlines also abort. Incomplete files retain the `.partial` suffix and do not enter a clip list.

Every MP4 write checks free space on the open destination, preserves the configured reserve, enforces the maximum file extent (including final MP4 indexes), retries interrupted writes, and handles partial writes. The final file is fsynced and published through no-replace rename. Existing user files are never replaced. Process death or loss of power during MP4 finalization is not covered by this non-fragmented container; retained partials are not claimed playable.

Core `x2v_begin_bounded` accepts `X2vLimits`; `x2v_storage_status` is a separate struct so older ctypes status callers retain their ABI. Legacy `x2v_begin` keeps its original maximum 30-second API and deadline-finalization behavior; device CLI uses the stricter bounded API for both forms.

## Offline validation

```text
.venv/bin/python native-video/tests/check_recorder_bounds.py
.venv/bin/python native-video/tools/build.py
```

The host harness uses real recorded X2D II RTP packets and injects file I/O faults. Ten core cases cover exact decoded-frame preservation, interrupted/short writes, data and final-index size ceilings, initial and falling free space, ENOSPC, monotonic deadline, cancellation and existing-file protection. Seven loopback cases cover normal short/bounded stops, SIGTERM, deadline, frame stall, missing packet and file limit. The C test binaries use AddressSanitizer and UndefinedBehaviorSanitizer. Results: `outputs/bounded-tests/report.json`.

A loopback replay proves parsing, failure handling and mux behavior on the host. It does not establish camera performance, thermal behavior, SSD direct-write permissions, detach operation, Drive Mode interaction or on-screen playback.
