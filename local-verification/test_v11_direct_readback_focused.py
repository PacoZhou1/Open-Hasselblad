#!/usr/bin/env python3
"""Focused offline v11 readback mocks. Never use a real camera transport."""
import hashlib
import json
import re
import shutil
import sys
import tempfile
import types
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'local-verification/isolated_ring20_v11_direct_readback.py'
BASE = ROOT / 'local-verification/isolated_ring20_v10_cached17_readback.py'
PACKET = ROOT / 'native-video/experimental/source-session-isolated-target-ring20-v11-direct'
CODEC = ROOT / 'native-video/experimental/source-receiver-adapter/receiver_v11_target_ring20_direct'
AUDIT = ROOT / 'native-video/experimental/source-receiver-adapter/receiver_v11_readback_review'
FRAME = 23379456


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        while block := f.read(1024 * 1024):
            h.update(block)
    return h.hexdigest()


def run_tests():
    AUDIT.mkdir(exist_ok=True)
    pins = {str(p.relative_to(ROOT)): digest(p) for p in (
        SOURCE, BASE, PACKET / 'ack_contract.py', CODEC / 'host-test/report.json',
        CODEC / 'host-test/duration.receipt.json', CODEC / 'host-test/writer-clock-skew.receipt.json')}
    originals = {k: sys.modules.get(k) for k in ('factory_session', 'gui_session')}
    def forbidden(*args, **kwargs):
        raise AssertionError('Real device transport is forbidden in this test')
    sys.modules['factory_session'] = types.SimpleNamespace(connect=forbidden)
    sys.modules['gui_session'] = types.SimpleNamespace(adb=forbidden)
    checks = []
    try:
        for case in ('success', 'writer_quality0', 'writer_flags_reject', 'writer_provider_reject',
                     'exec_out_short', 'exec_out_corrupt', 'wrong_full_sha'):
            with tempfile.TemporaryDirectory(prefix='mock-', dir=AUDIT) as td:
                root = Path(td)
                run = 'source-isolated-123456'
                out = root / 'native-video/outputs' / run
                device = out / 'device-run'
                device.mkdir(parents=True)
                packet = root / 'packet'
                packet.mkdir()
                shutil.copyfile(PACKET / 'ack_contract.py', packet / 'ack_contract.py')
                mode = 'isolated-target-ring20-v11-direct'
                (packet / 'freeze.json').write_text(json.dumps(dict(
                    mode=mode, ack_contract_sha256=digest(packet / 'ack_contract.py'))))
                hold = root / 'mock-hold.json'
                hold.write_text(json.dumps(dict(released_modes=[mode])))
                (out / 'report.json').write_text(json.dumps(dict(mode=mode, run_id=run,
                    passed=True, body_rc='0', recovery_rc='0', locks_absent=True)))
                fixture = CODEC / 'host-test' / ('writer-clock-skew.receipt.json'
                    if case == 'writer_quality0' else 'duration.receipt.json')
                rx = json.loads(fixture.read_text())
                assert rx['frames_copied'] == 2 and rx['version'] == 11
                if case == 'writer_flags_reject':
                    rx['writer_flags_active'] = rx['writer_flags_before']
                if case == 'writer_provider_reject':
                    rx['writer_provider_pwrite_offset'] += 1
                ack = (json.dumps(rx, separators=(',', ':')) + '\n').encode()
                (device / 'receiver.receipt').write_bytes(ack)
                (device / 'restored').touch()
                (device / 'manual.reaped').touch()
                raw = root / 'opaque-mock-source.raw'
                with raw.open('wb') as f:
                    f.truncate(FRAME * 2)
                    for offset, value in ((0, b'A'), (FRAME - 1, b'Z'),
                                          (FRAME, b'B'), (FRAME * 2 - 1, b'Y')):
                        f.seek(offset)
                        f.write(value)
                source_sha = digest(raw)
                (device / 'receiver.raw.sha256').write_text(
                    ('0' * 64 if case == 'wrong_full_sha' else source_sha) + ' raw.partial\n')
                (device / 'receiver.raw.bytes').write_text(str(FRAME * 2) + '\n')
                native = {}
                deleted = []
                calls = []
                transfer_sizes = []

                class Factory:
                    def __enter__(self):
                        return self
                    def __exit__(self, *args):
                        return False
                    def factory_shell(self, cmd, capture_ms):
                        calls.append(('factory', cmd))
                        if cmd.startswith('df '):
                            return 'dev 499656 0 400000 0% /data\n'
                        assert len(cmd.encode()) <= 231
                        assert 'set -C;toybox dd' in cmd and 'bs=7936' in cmd and 'count=2946' in cmd
                        index = int(re.search(r'skip=(\d+)', cmd).group(1)) // 2946
                        name = cmd.split(' >', 1)[1].removesuffix(')')
                        remote = '/data/x2v-source-20261012/runs/' + run + '/' + name
                        assert remote not in native
                        path = root / name
                        with raw.open('rb') as source, path.open('xb') as dest:
                            source.seek(index * FRAME)
                            left = FRAME
                            while left:
                                block = source.read(min(left, 1024 * 1024))
                                assert block
                                dest.write(block)
                                left -= len(block)
                        native[remote] = path
                        return ''

                def adb(*args, **kwargs):
                    assert args[0] == 'shell'
                    cmd = args[1]
                    calls.append(('adb', cmd))
                    if cmd.startswith('getprop'):
                        return 'running\n'
                    if cmd.endswith('&& echo CLEAR'):
                        return 'CLEAR\n'
                    if cmd.startswith('sha256sum '):
                        return digest(native[cmd.split()[1]]) + ' own-temp\n'
                    match = re.search(r'stat -c "%d:%i:%h:%s" ([^ )]+)', cmd)
                    assert match, cmd
                    remote = match.group(1)
                    path = native[remote]
                    st = path.stat()
                    token = f'{st.st_dev}:{st.st_ino}:{st.st_nlink}:{st.st_size}'
                    if '&& rm ' in cmd:
                        expected = cmd.split(' = ', 1)[1].split(' && rm', 1)[0]
                        assert expected == token
                        path.unlink()
                        del native[remote]
                        deleted.append(remote)
                        return ''
                    return token + '\n'

                def transfer(cmd, stdout, stderr, timeout):
                    assert cmd[:5] == ['adb', '-s', '123456789ABCDEF', 'exec-out', 'cat']
                    assert timeout == 45
                    before = stdout.fileno()
                    limit = FRAME - 1 if case == 'exec_out_short' else FRAME
                    sent = 0
                    with native[cmd[5]].open('rb') as source:
                        while sent < limit:
                            block = source.read(min(limit - sent, 1024 * 1024))
                            assert block
                            if case == 'exec_out_corrupt' and sent == 1024 * 1024:
                                block = bytes([block[0] ^ 1]) + block[1:]
                            stdout.write(block)
                            sent += len(block)
                    assert stdout.fileno() == before
                    transfer_sizes.append(sent)
                    return types.SimpleNamespace(returncode=0, stderr=b'')

                module = types.ModuleType('offline_v11_readback_mock')
                module.__file__ = str(SOURCE)
                exec(compile(SOURCE.read_text(), str(SOURCE), 'exec'), module.__dict__)
                module.ROOT, module.PACKET, module.HOLD = root, packet, hold
                module.adb, module.connect = adb, Factory
                module.subprocess = types.SimpleNamespace(run=transfer, PIPE=-1)
                disk = types.SimpleNamespace(total=10**10, used=0, free=10**10)
                with patch.object(sys, 'argv', ['readback', '--run', run, '--execute']), \
                     patch.object(module.shutil, 'disk_usage', lambda path: disk):
                    rc = module.main()
                result = json.loads((out / 'ring20-readback-report.json').read_text())
                good = case in ('success', 'writer_quality0')
                assert result['passed'] == good and rc == (0 if good else 1)
                assert digest(raw) == source_sha
                final = out / 'raw-ring20-3920x2946-stride7936.bin'
                assert final.exists() == good
                if good:
                    assert final.stat().st_size == FRAME * 2 and digest(final) == source_sha
                    assert transfer_sizes == [FRAME, FRAME] and len(deleted) == 2 and not native
                    assert result['raw_sha256'] == source_sha and result['direct_writer_verified']
                    expected = [i for i in range(2) if rx[f'frame{i}_write_cpu_wall_consistent'] == 0]
                    assert result['writer_cpu_wall_quality_false_frame_indices'] == expected
                    assert bool(expected) == (case == 'writer_quality0')
                    assert result['writer_provider'] == {k: rx[k] for k in (
                        'writer_provider_pinned', 'writer_provider_kind', 'writer_provider_path',
                        'writer_provider_base', 'writer_provider_pwrite_offset', 'writer_provider_pwrite_address',
                        'writer_provider_fsync_offset', 'writer_provider_fsync_address')}
                    assert result['cpu_write_wall_ns'] == [rx[f'frame{i}_write_end_ns'] - rx[f'frame{i}_write_begin_ns'] for i in range(2)]
                    assert result['cpu_write_thread_ns'] == [rx[f'frame{i}_write_cpu_end_ns'] - rx[f'frame{i}_write_cpu_begin_ns'] for i in range(2)]
                    assert not result['sensor_exposure_fps_verified'] and not result['continuous_recording_verified']
                elif case in ('writer_flags_reject', 'writer_provider_reject'):
                    assert calls == [] and not transfer_sizes and not native and not deleted
                else:
                    assert Path(result['retained_host_partial']).exists()
                    if case != 'wrong_full_sha':
                        assert len(native) == 1 and not deleted
                        assert Path(result['retained_host_chunk']).exists()
                    else:
                        assert len(deleted) == 2 and not native and transfer_sizes == [FRAME, FRAME]
                checks.append(dict(case=case,passed=True,rc=rc,source_unchanged=True,
                    actual_c_fixture=str(fixture.relative_to(ROOT)),fixture_sha256=digest(fixture),
                    mutation=case if case in ('writer_flags_reject','writer_provider_reject') else None,
                    tested_ack_sha256=hashlib.sha256(ack).hexdigest(),streamed_transfer_bytes=transfer_sizes,
                    assembled_full_sha_checked=good or case=='wrong_full_sha',
                    input_and_final_sha_equal=good))
    finally:
        for key, value in originals.items():
            if value is None:
                sys.modules.pop(key, None)
            else:
                sys.modules[key] = value
    assert all(digest(ROOT / name) == sha for name, sha in pins.items()), 'Input epoch changed during tests'
    report = dict(scope='offline v11 readback focused mocks; streamed real host files/hash; no camera/ADB/factory execution',
        passed=True,checks=checks,input_pins=pins,test_sha256=digest(Path(__file__)),
        fixture_boundary='Actual C ACKs use explicit HOST provider/DIRECT/HAL stubs; writer misconfiguration mutations labelled',
        readback_unchanged=True,frozen_codec_unchanged=True)
    path = AUDIT / 'receipt.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(passed=True,count=len(checks),receipt=str(path),sha256=digest(path))))


if __name__ == '__main__':
    run_tests()
