#!/usr/bin/env python3
"""Start/stop a bounded GUI screen audit, or collect one previous run read-only.

Frame timestamps come from X2V_SCREEN_FRAME events, not file mtimes or a fabricated
constant FPS. External compositor/video-overlay planes may be absent in captures.
"""
import argparse
import hashlib
import json
import math
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

DEVICE_ROOT = '/blackbox/x2v-native-20261011/screen-audit'
CONFIG_PATH = '/blackbox/x2v-native-20261011/audit-config.json'
RUN_RE = re.compile(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$')
FRAME_RE = re.compile(r'^frame-([0-9]{6})\.(bmp|png)$')
PREFIX_RE = re.compile(r'X2V_SCREEN_(FRAME|AUDIT)\s+')
MAX_FRAMES = 80
MAX_TOTAL_BYTES = 256 * 1024 * 1024
MAX_FRAME_BYTES = 4 * 1024 * 1024
ESTIMATED_FRAME_BYTES = 1024 * 768 * 4 + 4096
LOGGER_MAX_BYTES = 8 * 1024 * 1024
FREE_SPACE_RESERVE_BYTES = 128 * 1024 * 1024


def validate_run_id(run_id):
    if not RUN_RE.fullmatch(run_id):
        raise ValueError('runId must be 1–64 ASCII letters/digits/underscore/hyphen, starting with a letter or digit')
    return run_id


def parse_events(text, run_id):
    events = []
    decoder = json.JSONDecoder()
    for line in text.splitlines():
        prefix = PREFIX_RE.search(line)
        if not prefix:
            continue
        tail = line[prefix.end():].lstrip()
        try:
            event, _ = decoder.raw_decode(tail)
        except (ValueError, TypeError):
            continue
        if isinstance(event, dict) and event.get('runId') == run_id:
            events.append(dict(event, recordType=prefix.group(1)))
    return events


def parse_control_events(text, audit_events):
    starts = [e.get('timestampMs') for e in audit_events if e.get('event') == 'started']
    stops = [e.get('timestampMs') for e in audit_events if e.get('event') == 'stopped']
    frame_times = [e.get('timestampMs') for e in audit_events if e.get('recordType') == 'FRAME']
    lower = min((n for n in starts if isinstance(n, (int, float))), default=None)
    upper = max((n for n in stops + frame_times if isinstance(n, (int, float))), default=None)
    if lower is None or upper is None:
        return []
    records = []
    for line in text.splitlines():
        if 'X2V_CONTROL ' not in line:
            continue
        tail = line.split('X2V_CONTROL ', 1)[1].lstrip()
        try:
            event, _ = json.JSONDecoder().raw_decode(tail)
        except (ValueError, TypeError):
            continue
        if not isinstance(event, dict):
            continue
        stamp = event.get('timestampMs')
        if isinstance(stamp, (int, float)) and lower <= stamp <= upper:
            records.append(dict(event, recordType='CONTROL'))
    return records


def frame_info(path):
    if path.is_symlink():
        raise ValueError(f'refusing symlink frame: {path.name}')
    size = path.stat().st_size
    if not (24 <= size <= MAX_FRAME_BYTES):
        raise ValueError(f'frame has an invalid size: {path.name}')
    with path.open('rb') as f:
        header = f.read(138)
    if path.suffix.lower() == '.png':
        if header[:8] != b'\x89PNG\r\n\x1a\n' or header[12:16] != b'IHDR':
            raise ValueError(f'not a PNG frame: {path.name}')
        width, height = struct.unpack('>II', header[16:24])
    elif path.suffix.lower() == '.bmp':
        if len(header) < 54 or header[:2] != b'BM':
            raise ValueError(f'not a BMP frame: {path.name}')
        declared_size, pixel_offset, dib_size = struct.unpack_from('<I', header, 2)[0], struct.unpack_from('<I', header, 10)[0], struct.unpack_from('<I', header, 14)[0]
        if declared_size != size or dib_size not in (40, 52, 56, 108, 124) or not (14 + dib_size <= pixel_offset < size):
            raise ValueError(f'invalid BMP header/declared size: {path.name}')
        width, signed_height, planes, bpp, compression = struct.unpack_from('<iiHHI', header, 18)
        height = abs(signed_height)
        if planes != 1 or bpp not in (24, 32) or compression not in (0, 3):
            raise ValueError(f'unsupported BMP pixel layout: {path.name}')
        stride = ((width * bpp + 31) // 32) * 4
        if stride <= 0 or pixel_offset + stride * height > size:
            raise ValueError(f'truncated BMP pixels: {path.name}')
    else:
        raise ValueError(f'unsupported frame format: {path.name}')
    if not (0 < width <= 1024 and 0 < height <= 768):
        raise ValueError(f'invalid frame dimensions: {path.name}')
    return dict(bytes=size, width=width, height=height, format=path.suffix[1:].lower(),
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def quote_concat(path):
    # ffconcat quoting is distinct from shell quoting; subprocess never uses shell.
    return "'" + str(path).replace("'", "'\\''") + "'"


def build_review(run_id, frame_dir, events, output, render=True, control_events=None):
    validate_run_id(run_id)
    frame_dir, output = Path(frame_dir), Path(output)
    output.mkdir(parents=True, exist_ok=True)
    files = sorted(p for p in frame_dir.iterdir() if FRAME_RE.fullmatch(p.name))
    if len(files) > MAX_FRAMES:
        raise ValueError('more than 80 frames in a single run')
    if sum(file.stat().st_size for file in files) > MAX_TOTAL_BYTES:
        raise ValueError('screen audit exceeds the 256 MiB byte budget')
    indices = [int(FRAME_RE.fullmatch(file.name).group(1)) for file in files]
    if len(set(indices)) != len(indices):
        raise ValueError('duplicate frame number across formats')
    successes = {}
    for event in events:
        if event.get('recordType') != 'FRAME' or event.get('success') is not True or event.get('skipped') is True:
            continue
        frame = event.get('frameNumber')
        stamp = event.get('captureStartedAtMs')
        if not isinstance(frame, int) or not 1 <= frame <= MAX_FRAMES or not isinstance(stamp, (int, float)) or not math.isfinite(stamp):
            continue
        successes.setdefault(frame, event)
    timeline, unlogged = [], []
    for file in files:
        index = int(FRAME_RE.fullmatch(file.name).group(1))
        event = successes.get(index)
        if not event:
            unlogged.append(file.name)
            continue
        info = frame_info(file)
        timeline.append(dict(info, frameNumber=index, filename=file.name,
                             captureStartedAtMs=event['captureStartedAtMs'],
                             completedAtMs=event.get('timestampMs'), durationMs=event.get('durationMs'),
                             grabDurationMs=event.get('grabDurationMs'), saveDurationMs=event.get('saveDurationMs')))
    timeline.sort(key=lambda entry: entry['frameNumber'])
    for a, b in zip(timeline, timeline[1:]):
        if b['captureStartedAtMs'] <= a['captureStartedAtMs']:
            raise ValueError('non-increasing wall timestamps: refusing to invent frame ordering/durations')
    dimensions = {(f['width'], f['height']) for f in timeline}
    if len(dimensions) > 1:
        raise ValueError('frame dimensions changed during the run')
    starts = [e for e in events if e.get('recordType') == 'AUDIT' and e.get('event') == 'started']
    stops = [e for e in events if e.get('recordType') == 'AUDIT' and e.get('event') == 'stopped']
    start, stop = (starts[0] if starts else {}), (stops[-1] if stops else {})
    fps = float(start.get('fps', 2))
    fps = min(5, max(1, fps)) if math.isfinite(fps) else 2
    last_duration, tail_estimated = 1/fps, True
    if timeline:
        stopped = stop.get('timestampMs')
        if isinstance(stopped, (int, float)) and math.isfinite(stopped) and stopped > timeline[-1]['captureStartedAtMs']:
            last_duration = (stopped - timeline[-1]['captureStartedAtMs']) / 1000
            tail_estimated = False
        first = timeline[0]['captureStartedAtMs']
        for index, entry in enumerate(timeline):
            entry['offsetSeconds'] = (entry['captureStartedAtMs'] - first) / 1000
            entry['durationSeconds'] = ((timeline[index+1]['captureStartedAtMs'] - entry['captureStartedAtMs']) / 1000
                                        if index+1 < len(timeline) else last_duration)
    missing = sorted(index for index in successes if index not in indices)
    manifest = dict(schemaVersion=1, runId=run_id, readOnlyCollection=True,
                    nativeVideoPlaneGuaranteed=False,
                    limitation='Captures contain the Qt Quick scene. External compositor/video overlays may be absent.',
                    frames=timeline, capturedFrames=len(timeline), maxFrames=MAX_FRAMES,
                    maxTotalBytes=MAX_TOTAL_BYTES, totalFrameBytes=sum(file.stat().st_size for file in files),
                    filesWithoutSuccessEvent=unlogged,
                    successEventsWithoutFile=missing, runStart=start, runStop=stop,
                    runStopObserved=bool(stops), tailDurationEstimated=tail_estimated,
                    wallTimestampMeaning='QML grab request time; callback completion and grab duration are also recorded.',
                    events=events, controlEvents=control_events or [], video=None)
    for metric in ['durationMs', 'grabDurationMs', 'saveDurationMs']:
        values = [entry[metric] for entry in timeline if isinstance(entry.get(metric), (int, float))]
        manifest.setdefault('captureTiming', {})[metric] = dict(max=max(values), average=sum(values)/len(values)) if values else None
    concat = ['ffconcat version 1.0']
    for entry in timeline:
        concat.extend(['file ' + quote_concat((frame_dir / entry['filename']).resolve()),
                       'option framerate 1000', 'duration %.6f' % entry['durationSeconds']])
    if timeline:
        # ffconcat requires a final repeated frame for the preceding duration.
        concat.extend(['file ' + quote_concat((frame_dir / timeline[-1]['filename']).resolve()), 'option framerate 1000'])
    concat_path = output / 'frames.ffconcat'
    concat_path.write_text('\n'.join(concat) + '\n')
    if timeline and render:
        video = output / 'screen-audit.mp4'
        with (output / 'ffmpeg.log').open('w') as log:
            subprocess.run(['ffmpeg', '-hide_banner', '-nostdin', '-y', '-f', 'concat', '-safe', '0',
                            '-i', str(concat_path), '-fps_mode', 'vfr', '-enc_time_base', '1:1000',
                            '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2', '-c:v', 'libx264', '-crf', '20',
                            '-pix_fmt', 'yuv420p', '-video_track_timescale', '1000000',
                            '-movflags', '+faststart', str(video)], check=True, stdout=log, stderr=log)
        probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error', '-show_format', '-show_streams',
                                                   '-of', 'json', str(video)], text=True))
        manifest['video'] = dict(path=str(video.resolve()), ffprobe=probe,
                                 containsTerminalDuplicate=True, audio=False)
    (output / 'audit.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False))
    (output / 'control-events.jsonl').write_text(''.join(json.dumps(e, ensure_ascii=False) + '\n' for e in (control_events or [])))
    return manifest


def collect_local(source, log_file, run_id, output, render=True):
    validate_run_id(run_id)
    source, output = Path(source), Path(output)
    output.mkdir(parents=True, exist_ok=False)
    frames = output / 'frames'
    frames.mkdir()
    candidates = [p for p in source.iterdir() if FRAME_RE.fullmatch(p.name)]
    if len(candidates) > MAX_FRAMES:
        raise ValueError('more than 80 frames in source')
    if sum(file.stat().st_size for file in candidates) > MAX_TOTAL_BYTES:
        raise ValueError('source exceeds the 256 MiB byte budget')
    for file in candidates:
        frame_info(file)
        shutil.copy2(file, frames / file.name)
    raw = Path(log_file).read_text(errors='replace')
    events = parse_events(raw, run_id)
    (output / 'events.jsonl').write_text(''.join(json.dumps(e, ensure_ascii=False) + '\n' for e in events))
    return build_review(run_id, frames, events, output, render, parse_control_events(raw, events))


def collect_device(serial, run_id, output, render=True):
    # All remote operations are reads; caller supplies an explicit device serial.
    output = Path(output)
    output.mkdir(parents=True, exist_ok=False)
    adb = ['adb', '-s', serial]
    with (output / 'adb-pull.log').open('w') as log:
        subprocess.run(adb + ['pull', DEVICE_ROOT + '/' + validate_run_id(run_id), str(output / 'frames')],
                       check=True, stdout=log, stderr=log, timeout=180)
    # ADB's su domain cannot execute logcat on this firmware. The bounded,
    # factory-domain logger started with this run has already saved its output.
    log_path = output / 'frames/events.log'
    if not log_path.is_file():
        raise ValueError('events.log is absent; this collector does not fabricate file timestamps')
    raw = log_path.read_text(errors='replace')
    events = parse_events(raw, run_id)
    (output / 'events.jsonl').write_text(''.join(json.dumps(e, ensure_ascii=False) + '\n' for e in events))
    # Preserve bounded logger diagnostics (for example early EOF) separately
    # from frames and the run-filtered structured events.
    log_path.rename(output / 'logger.log')
    return build_review(run_id, output / 'frames', events, output, render, parse_control_events(raw, events))


def adb_read(serial, *command):
    return subprocess.check_output(['adb', '-s', serial, 'shell', *command], text=True,
                                   errors='replace', timeout=10).strip()


def write_config(serial, config):
    # The final rename lets the QML polling reader see only whole JSON documents.
    token = str(config.get('runId') or 'stop')
    validate_run_id(token)
    remote_tmp = CONFIG_PATH + '.' + token + '.tmp'
    with tempfile.TemporaryDirectory(prefix='x2v-screen-audit-') as tmp:
        source = Path(tmp) / 'audit-config.json'
        source.write_text(json.dumps(config, separators=(',', ':')))
        subprocess.run(['adb', '-s', serial, 'push', str(source), remote_tmp], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, timeout=10)
        subprocess.run(['adb', '-s', serial, 'shell', 'mv', remote_tmp, CONFIG_PATH],
                       check=True, stdout=subprocess.DEVNULL, timeout=10)


def blackbox_available_bytes(df_output):
    # df -k reports 1024-byte blocks. Match the mount explicitly, accepting both
    # ordinary and wrapped filesystem-name output, and fail closed if ambiguous.
    candidates = []
    for line in df_output.splitlines():
        columns = line.split()
        if len(columns) < 5 or columns[-1] != '/blackbox':
            continue
        total, used, available, percent = columns[-5:-1]
        if not all(re.fullmatch(r'[0-9]+', n) for n in (total, used, available)):
            continue
        if not re.fullmatch(r'[0-9]+%', percent) or int(available) > int(total):
            continue
        candidates.append(int(available) * 1024)
    if len(candidates) != 1:
        raise ValueError('cannot determine /blackbox available space from df -k; audit was not started')
    return candidates[0]


def start_device(serial, run_id, seconds=30, fps=2, format='bmp'):
    validate_run_id(run_id)
    if not math.isfinite(seconds) or not math.isfinite(fps) or seconds <= 0 or fps <= 0:
        raise ValueError('seconds and fps must be positive finite numbers')
    seconds, fps = min(60, seconds), min(5, max(1, int(fps)))
    if format not in ('bmp', 'png'):
        raise ValueError('format must be bmp or png')
    adb_identity = adb_read(serial, 'getprop', 'ro.product.device')
    if adb_identity != 'eagle2_hb722':
        raise ValueError('ADB target is not the expected X2D II device')
    camera_ms = int(adb_read(serial, 'date', '+%s')) * 1000
    # A live lease is an explicit busy indication, even if capture might already
    # have ended. Stop it or allow it to expire before requesting another run.
    try:
        old = json.loads(adb_read(serial, 'cat', CONFIG_PATH))
    except (json.JSONDecodeError, subprocess.CalledProcessError):
        old = {}
    if old.get('enabled') is True and old.get('expiresAtMs', 0) > camera_ms:
        raise ValueError('an audit lease is active; use stop before starting another run')
    estimated_frames = min(MAX_FRAMES, math.ceil(seconds * fps), MAX_TOTAL_BYTES // ESTIMATED_FRAME_BYTES)
    estimated_run_bytes = estimated_frames * ESTIMATED_FRAME_BYTES + LOGGER_MAX_BYTES
    required_free_bytes = estimated_run_bytes + FREE_SPACE_RESERVE_BYTES
    available_bytes = blackbox_available_bytes(adb_read(serial, 'df', '-k', '/blackbox'))
    if available_bytes < required_free_bytes:
        raise ValueError(f'/blackbox has {available_bytes} bytes available; audit requires '
                         f'{required_free_bytes} bytes including a 128 MiB reserve; no data was deleted')
    run_dir = DEVICE_ROOT + '/' + run_id
    effective_seconds = min(seconds, MAX_FRAMES / fps)
    logger_seconds = math.ceil(effective_seconds) + 8
    # connect() also verifies the factory USB layout, device identity and stock
    # camera-service hash. Both pidof and logcat require this domain on X2D II.
    from factory_session import connect
    with connect() as factory:
        pid_text = factory.factory_shell('pidof camera-gui', capture_ms=900).strip()
        if not re.fullmatch(r'[0-9]+', pid_text):
            raise ValueError('expected exactly one factory-domain camera-gui PID')
        # PID filter, hard duration, and 8 MiB cap; no unbounded system log.
        # Keep structured INFO events and higher severities, as product QA does.
        # The previous unfiltered reader ended with an unexpected EOF during
        # native thumbnail traffic; filtering reduces load, but is not by itself
        # proof that this firmware logcat failure is fixed. Collection continues
        # to report missing events rather than inventing frame timestamps.
        command = f'cd {run_dir};(timeout {logger_seconds} logcat --pid={pid_text} -v epoch -T 1 camera-gui:I "*:S"|head -c8388608)>events.log 2>&1 &'
        if len(command.encode()) > 231:
            raise ValueError('runId is too long for the factory shell command; use a shorter id')
        subprocess.run(['adb', '-s', serial, 'shell', 'mkdir', '-p', DEVICE_ROOT], check=True, timeout=10)
        subprocess.run(['adb', '-s', serial, 'shell', 'mkdir', run_dir], check=True, timeout=10)
        factory.factory_shell(command, capture_ms=1600)
    lease_ms = int(adb_read(serial, 'date', '+%s')) * 1000
    config = dict(enabled=True, runId=run_id, seconds=seconds, fps=fps, format=format,
                  expiresAtMs=lease_ms + math.ceil(effective_seconds * 1000) + 5000)
    write_config(serial, config)
    return dict(config=config, configPath=CONFIG_PATH, directory=run_dir,
                cameraGuiPid=int(pid_text), loggerMaxSeconds=logger_seconds, loggerMaxBytes=LOGGER_MAX_BYTES,
                adbDeviceIdentity=adb_identity, factoryIdentityAndHashVerified=True,
                cameraClockAtRequestMs=camera_ms,
                maxFrames=MAX_FRAMES, maxTotalBytes=MAX_TOTAL_BYTES,
                spaceBudget=dict(estimatedFrames=estimated_frames, estimatedMaxBytesPerFrame=ESTIMATED_FRAME_BYTES,
                                 estimatedRunBytes=estimated_run_bytes, reserveBytes=FREE_SPACE_RESERVE_BYTES,
                                 requiredFreeBytes=required_free_bytes, availableBytes=available_bytes),
                limitation='Frame save runs synchronously in the GUI callback; inspect saveDurationMs for UI impact.')


def stop_device(serial):
    try:
        previous = json.loads(adb_read(serial, 'cat', CONFIG_PATH))
    except (json.JSONDecodeError, subprocess.CalledProcessError):
        previous = {}
    run_id = previous.get('runId', 'stop')
    validate_run_id(run_id)
    write_config(serial, dict(enabled=False, runId=run_id, expiresAtMs=0))
    return dict(runId=run_id, stopRequested=True, configPath=CONFIG_PATH,
                note='QML polls once per second; collect after it logs the stopped event.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    start = sub.add_parser('start', help='precreate run directory, start bounded GUI-only log collector, write leased config')
    start.add_argument('run_id')
    start.add_argument('--serial', required=True)
    start.add_argument('--seconds', type=float, default=30)
    start.add_argument('--fps', type=float, default=2)
    start.add_argument('--format', choices=('bmp', 'png'), default='bmp')
    stop = sub.add_parser('stop', help='disable the current audit config; does not stop the camera or recorder')
    stop.add_argument('--serial', required=True)
    collect = sub.add_parser('collect', help='read one previously started run; never starts/stops camera capture')
    collect.add_argument('run_id')
    source = collect.add_mutually_exclusive_group(required=True)
    source.add_argument('--serial', help='explicit ADB serial for read-only pull/logcat')
    source.add_argument('--local-source', type=Path, help='offline directory containing frame-000001.bmp or .png etc.')
    collect.add_argument('--log-file', type=Path, help='required for offline collection')
    collect.add_argument('--output', type=Path, help='new local output directory')
    collect.add_argument('--no-render', action='store_true')
    args = parser.parse_args(argv)
    if args.command == 'start':
        print(json.dumps(start_device(args.serial, args.run_id, args.seconds, args.fps, args.format), indent=2, ensure_ascii=False))
        return
    if args.command == 'stop':
        print(json.dumps(stop_device(args.serial), indent=2, ensure_ascii=False))
        return
    validate_run_id(args.run_id)
    if args.local_source and not args.log_file:
        parser.error('--local-source requires --log-file')
    output = args.output or Path(__file__).resolve().parents[1] / 'native-video/outputs/screen-audit' / (
        args.run_id + '-' + datetime.now().strftime('%Y%m%d-%H%M%S'))
    if args.local_source:
        result = collect_local(args.local_source, args.log_file, args.run_id, output, not args.no_render)
    else:
        result = collect_device(args.serial, args.run_id, output, not args.no_render)
    print(json.dumps(dict(runId=args.run_id, capturedFrames=result['capturedFrames'],
                         runStopObserved=result['runStopObserved'], output=str(output.resolve())), ensure_ascii=False))

if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print('screen-audit collection failed: ' + str(error), file=sys.stderr)
        sys.exit(1)
