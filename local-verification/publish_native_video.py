#!/usr/bin/env python3
"""Read-only native-album inspector/planner. Deliberately has no publish mode.

Inputs are local evidence snapshots, never ADB/device commands. A plan is not a
reservation: device-side no-replace publication and a camera naming lease must
be implemented and verified separately before any DCIM write.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys

CLIP_ROOT = '/mnt/media_rw/ssd/X2V_VIDEO'
MANIFEST_KEYS = {'schema', 'id', 'file', 'path', 'file_url', 'duration_ms',
                 'frames', 'width', 'height', 'bytes'}
RECORDER_KEYS = set('schema phase frames width height duration_ticks error mux_error packets reordered queue_bytes file_bytes free_bytes max_file_bytes min_free_bytes max_seconds received_bytes monotonic_ms elapsed_ms last_packet_monotonic_ms last_frame_monotonic_ms pid signal startup_resets rtp_conflicts startup_reacquiring stop_required reason'.split())
SESSION_KEYS = set('schema phase control_phase fresh monotonic_ms recorder_monotonic_ms frames width height duration_ms duration_ticks file_bytes free_bytes error mux_error control_error reason id file path file_url rtp_confirmed_off receiver_alive stop_required requested_seconds max_seconds preview_state preview_error preview_monotonic_ms camera_owned'.split())


class Rejected(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise Rejected(message)


def integer(obj, key, low, high):
    value = obj.get(key)
    require(type(value) is int and low <= value <= high, 'invalid integer: ' + key)
    return value


def open_directory(path):
    """Walk every ancestor using dirfds, denying symlinks and parent traversal."""
    path = Path(path)
    require(path.is_absolute() and '..' not in path.parts, 'directory must be absolute without ..')
    fd = os.open('/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in path.parts[1:]:
            next_fd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                              dir_fd=fd)
            os.close(fd)
            fd = next_fd
        return fd
    except BaseException:
        os.close(fd)
        raise


def open_file(directory, name):
    require('/' not in name and name not in ('', '.', '..'), 'invalid file name')
    fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=directory)
    try:
        info = os.fstat(fd)
        require(stat.S_ISREG(info.st_mode), 'input must be a regular file: ' + name)
        require(info.st_nlink == 1, 'hard-linked input denied: ' + name)
        return fd
    except BaseException:
        os.close(fd)
        raise


def fingerprint(fd):
    s = os.fstat(fd)
    return (s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns, s.st_ctime_ns)


def digest(fd):
    before = fingerprint(fd)
    os.lseek(fd, 0, os.SEEK_SET)
    h = hashlib.sha256()
    while True:
        data = os.read(fd, 1024 * 1024)
        if not data:
            break
        h.update(data)
    require(before == fingerprint(fd), 'input changed during hash')
    return h.hexdigest()


def read_json(directory, name):
    fd = open_file(directory, name)
    try:
        before = fingerprint(fd)
        require(1 < before[2] < 16384, 'JSON exceeds bounded size')
        raw = os.read(fd, 16384)
        require(len(raw) == before[2] and before == fingerprint(fd), 'JSON changed while reading')
        def pairs(items):
            out = {}
            for key, value in items:
                require(key not in out, 'duplicate JSON key: ' + key)
                out[key] = value
            return out
        obj = json.loads(raw, object_pairs_hook=pairs,
                         parse_constant=lambda _: (_ for _ in ()).throw(Rejected('nonfinite JSON')))
        require(type(obj) is dict, 'JSON must be object')
        return obj, hashlib.sha256(raw).hexdigest()
    finally:
        os.close(fd)


def run_media(binary, args, fd):
    os.lseek(fd, 0, os.SEEK_SET)
    try:
        result = subprocess.run([binary] + args, pass_fds=(fd,),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                timeout=45, check=False)
    except subprocess.TimeoutExpired as exc:
        raise Rejected('media validation timeout') from exc
    require(result.returncode == 0, 'media validation failed: ' + binary)
    # Both callers use -v error. FFmpeg-family tools can report a decoder
    # error and still exit 0, so success requires an empty error channel too.
    require(not result.stderr.strip(), 'media validation reported decoder errors: ' + binary)
    require(len(result.stdout) <= 16 * 1024 * 1024, 'media output exceeds bound')
    return result.stdout


def inspect(source_directory, clip_id, session_name, ffprobe='ffprobe', ffmpeg='ffmpeg'):
    require(re.fullmatch(r'X2V_[A-Za-z0-9_]{1,76}', clip_id), 'invalid clip id')
    directory = open_directory(source_directory)
    fd = None
    try:
        filename = clip_id + '.mp4'
        path = CLIP_ROOT + '/' + filename
        manifest, manifest_hash = read_json(directory, clip_id + '.manifest.json')
        recorder, recorder_hash = read_json(directory, filename + '.state.json')
        session, session_hash = read_json(directory, session_name)
        require(set(manifest) == MANIFEST_KEYS, 'manifest schema fields mismatch')
        integer(manifest, 'schema', 1, 1)
        for key, value in [('id', clip_id), ('file', filename), ('path', path),
                           ('file_url', 'file://' + path)]:
            require(manifest[key] == value, 'manifest identity mismatch: ' + key)
        limits = {'duration_ms': (1, 60000), 'frames': (1, 1000000),
                  'width': (1, 65536), 'height': (1, 65536), 'bytes': (1, 256 * 1024 * 1024)}
        for key, bounds in limits.items(): integer(manifest, key, *bounds)
        require(manifest['width'] * manifest['height'] <= 32 * 1024 * 1024,
                'decoded image area exceeds validation bound')
        require(set(recorder) <= RECORDER_KEYS, 'unknown recorder schema field')
        integer(recorder, 'schema', 2, 2)
        require(recorder.get('phase') == 'saved', 'recorder did not save successfully')
        require(recorder.get('reason') == 'controller_stop', 'recorder stop was not controlled')
        for key in ('error', 'mux_error', 'signal', 'queue_bytes'): integer(recorder, key, 0, 0)
        require(recorder.get('startup_reacquiring') is False, 'startup still reacquiring')
        ticks = integer(recorder, 'duration_ticks', 1, 90000 * 60)
        require(ticks // 90 == manifest['duration_ms'], 'recorder duration mismatch')
        for key in ('frames', 'width', 'height'):
            require(type(recorder.get(key)) is int and recorder[key] == manifest[key], 'recorder metadata mismatch: ' + key)
        require(set(session) <= SESSION_KEYS, 'unknown session schema field')
        integer(session, 'schema', 1, 1)
        require(session.get('phase') == 'saved' and session.get('control_phase') == 'saved', 'session not saved')
        for key in ('error', 'mux_error'): integer(session, key, 0, 0)
        require(session.get('control_error') == '', 'session control failed')
        require(session.get('rtp_confirmed_off') is True and session.get('receiver_alive') is False,
                'recording shutdown not confirmed')
        for key in ('id', 'file', 'path', 'file_url', 'duration_ms', 'frames', 'width', 'height'):
            require(type(session.get(key)) is type(manifest[key]) and session[key] == manifest[key], 'session mismatch: ' + key)
        fd = open_file(directory, filename)
        before = fingerprint(fd)
        require(before[2] == manifest['bytes'], 'final MP4 length mismatch')
        require(recorder.get('file_bytes') == before[2] and session.get('file_bytes') == before[2], 'state file size mismatch')
        mp4_hash = digest(fd)
        fd_path = '/dev/fd/' + str(fd)
        media = json.loads(run_media(ffprobe, ['-v', 'error', '-count_frames', '-show_streams', '-show_format', '-of', 'json', fd_path], fd))
        require(media.get('format', {}).get('format_name') == 'mov,mp4,m4a,3gp,3g2,mj2',
                'source is not an MP4-family container')
        videos = [s for s in media.get('streams', []) if s.get('codec_type') == 'video']
        require(len(videos) == 1 and len(media.get('streams', [])) == 1, 'expected one video stream')
        video = videos[0]
        require(video.get('codec_name') == 'h264', 'source is not verified H264 video')
        for key in ('width', 'height'):
            require(video.get(key) == manifest[key], 'decoded dimensions mismatch')
        require(int(video.get('nb_read_frames', -1)) == manifest['frames'], 'decoded frame count mismatch')
        duration = float(video.get('duration', media.get('format', {}).get('duration', 0)))
        require(duration > 0 and abs(duration * 1000 - manifest['duration_ms']) <= 100,
                'decoded duration mismatch')
        # Validate every frame with strict error handling. A usable first-frame
        # preview cannot establish that the rest of the clip decodes correctly.
        run_media(ffmpeg, ['-v', 'error', '-xerror', '-err_detect', 'explode', '-i', fd_path,
                           '-map', '0:v:0', '-threads', '1', '-f', 'null', 'pipe:1'], fd)
        # A genuine decoded first frame; no EXIF invention, no MP4/JPEG disguise.
        jpeg = run_media(ffmpeg, ['-v', 'error', '-i', fd_path, '-map', '0:v:0', '-frames:v', '1',
                                 '-threads', '1', '-c:v', 'mjpeg', '-q:v', '2', '-f', 'image2pipe', 'pipe:1'], fd)
        require(jpeg.startswith(b'\xff\xd8\xff') and jpeg.endswith(b'\xff\xd9'), 'first frame was not JPEG')
        require(before == fingerprint(fd) and mp4_hash == digest(fd), 'MP4 changed during media validation')
        # Reopen names: replacement of directory entries also invalidates evidence.
        for name, expected in [(filename, mp4_hash), (clip_id + '.manifest.json', manifest_hash),
                               (filename + '.state.json', recorder_hash), (session_name, session_hash)]:
            check = open_file(directory, name)
            try: require(digest(check) == expected, 'evidence was replaced: ' + name)
            finally: os.close(check)
        return {'schema': 1, 'mode': 'inspect', 'source_verified': True, 'device_verified': False,
                'source_snapshot': str(Path(source_directory)), 'source_device_path': path,
                'manifest': manifest, 'sha256': mp4_hash,
                'evidence_sha256': {'manifest': manifest_hash, 'recorder': recorder_hash, 'session': session_hash},
                'preview': {'kind': 'decoded_first_frame_jpeg', 'bytes': len(jpeg),
                            'sha256': hashlib.sha256(jpeg).hexdigest(), 'embedded_photo_metadata': False},
                'validation': {'codec': 'h264', 'decoded_frames': int(video['nb_read_frames']),
                               'duration_seconds': duration, 'full_frame_decode': True,
                               'decoder_error_stderr_empty': True}}
    finally:
        if fd is not None: os.close(fd)
        os.close(directory)


def plan(evidence, destination_root, folder, camera_file_index, expected_sha256):
    require(re.fullmatch(r'[1-9][0-9]{2}HASBL', folder), 'invalid DCF folder')
    require(type(camera_file_index) is int and 0 <= camera_file_index < 9999999, 'invalid camera file index')
    require(re.fullmatch(r'[0-9a-f]{64}', expected_sha256), 'expected SHA256 is required')
    require(expected_sha256 == evidence['sha256'], 'source hash differs from expected hash')
    root = Path(destination_root)
    destination = root / 'DCIM' / folder
    directory = open_directory(destination)
    try:
        before = fingerprint(directory)
        entries = os.listdir(directory)
        require(len(entries) <= 20000, 'destination scan exceeds bound')
        number = camera_file_index + 1
        stem = 'B' + str(number).zfill(7)
        highest = 0
        for name in entries:
            info = os.stat(name, dir_fd=directory, follow_symlinks=False)
            require(not stat.S_ISLNK(info.st_mode), 'destination contains symlink')
            require(stat.S_ISREG(info.st_mode), 'destination contains non-file entry')
            require(not name.upper().startswith(stem + '.'), 'same-stem collision: ' + name)
            match = re.fullmatch(r'B([0-9]{7})\..+', name, re.IGNORECASE)
            if match: highest = max(highest, int(match.group(1)))
        require(highest <= camera_file_index, 'camera file index is stale versus snapshot')
        require(before == fingerprint(directory), 'destination changed during scan')
    finally:
        os.close(directory)
    logical = '/ssd/' + folder + '/' + stem + '.MP4'
    physical = '/mnt/media_rw/ssd/DCIM/' + folder + '/' + stem + '.MP4'
    result = dict(evidence)
    result.update({'mode': 'plan', 'publish_enabled': False, 'destination_snapshot': str(destination),
                   'camera_file_index_observed': camera_file_index, 'folder_snapshot_highest_index': highest,
                   'target': {'logical_native_path': logical, 'physical_native_path': physical,
                              'preview_physical_path': physical[:-4] + '.SRC.JPG', 'stem': stem},
                   'playback_mapping': {'logical_native_path': logical,
                                        'verified_source_snapshot_path': str(Path(evidence['source_snapshot']) / evidence['manifest']['file']),
                                        'source_device_path': evidence['source_device_path'], 'sha256': evidence['sha256'],
                                        'published': False},
                   'blockers': ['No camera-owned numbering reservation or enforced no-photo window',
                                'No device-side renameat2(RENAME_NOREPLACE) publisher or crash journal',
                                'Native cache refresh and browse not verified',
                                'Native album UI must pass simulator review before deployment']})
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('inspect', 'plan'))
    parser.add_argument('--source-directory', required=True, help='absolute local evidence snapshot')
    parser.add_argument('--id', required=True)
    parser.add_argument('--session-state', required=True, help='saved bridge JSON filename in source directory')
    parser.add_argument('--destination-root', help='absolute local snapshot of SSD root, containing DCIM')
    parser.add_argument('--folder')
    parser.add_argument('--camera-file-index', type=int)
    parser.add_argument('--expected-sha256')
    args = parser.parse_args(argv)
    try:
        evidence = inspect(args.source_directory, args.id, args.session_state)
        if args.mode == 'plan':
            require(all(v is not None for v in (args.destination_root, args.folder, args.camera_file_index, args.expected_sha256)), 'plan needs destination, folder, observed index and expected hash')
            evidence = plan(evidence, args.destination_root, args.folder, args.camera_file_index, args.expected_sha256)
        print(json.dumps(evidence, indent=2, sort_keys=True))
        return 0
    except (Rejected, OSError, ValueError, KeyError, TypeError) as exc:
        print(json.dumps({'schema': 1, 'mode': args.mode, 'source_verified': False,
                          'publish_enabled': False, 'error': str(exc)}))
        return 2


if __name__ == '__main__':
    sys.exit(main())
