#!/usr/bin/env python3
"""Resident ProRes RAW receiver: own sources + unchanged MODE21 source/graph adapters + encoder."""
import hashlib, json, subprocess, sys
from pathlib import Path
from elftools.elf.elffile import ELFFile

HERE = Path(__file__).resolve().parent
R = HERE.parents[2]
EXP = R / 'native-video/experimental'
A = EXP / 'source-receiver-adapter'
BASE = A / 'receiver_v18_dng_isp_proxy'
CAND = EXP / 'rx-prr-async/candidate'
H = R / 'research/full-fov-pipeline/source-adapter'
ENC = EXP / 'prores-raw-encoder'
S = R / 'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
B = HERE / 'build'
B.mkdir(exist_ok=True)

# session_gate.c replaces BASE target_start_gate.c: the same gate plus the resident session guard.
ADAPTER = ['target_parser_gate.c', 'target_topology.c', 'graph_binding.c',
           'hal_topology_glue.c', 'fps_guard_session.c', 'source_mode21_guard_preload.c', 'target_descriptor.c']
sources = ([HERE / 'resident.c', HERE / 'vrec.c', HERE / 'dng.c', HERE / 'awb.c', HERE / 'session_gate.c',
            HERE / 'shutter_gate.c', CAND / 'debug_hub_guard.c',
            A / 'android_stat_check.c']
           + [BASE / n for n in ADAPTER + ['geometry.c']]
           + [H / 'owned_descriptor.c', H / 'hal_profile_adapter.c']
           + [ENC / n for n in ['prr_hal.c', 'prr_pre.c', 'prr_enc.c', 'prr_mov.c']])

# The adapter sources are the reviewed, device-proven ones; refuse drifted copies.
freeze = json.loads((BASE / 'source-review.json').read_text())
base_freeze = json.loads((A / 'receiver_v7_target_fullrect/freeze.json').read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
for src in sources:
    if src.parent == BASE and src.name in freeze['production_sources']:
        assert sha(src) == freeze['production_sources'][src.name], src
    rel = str(src.relative_to(R))
    if rel in base_freeze.get('unchanged_target_shared_sources', {}):
        assert sha(src) == base_freeze['unchanged_target_shared_sources'][rel], rel

commands = []
def run(c):
    commands.append(list(map(str, c)))
    r = subprocess.run(list(map(str, c)), capture_output=True, text=True, timeout=120)
    if r.returncode:
        raise RuntimeError(r.stderr)

z = [sys.executable, '-m', 'ziglang', 'cc', '-target', 'aarch64-linux-gnu']
objects = []
for i, src in enumerate(sources):
    obj = B / f'{i}-{src.name}.o'
    flags = ['-std=c11', '-Wall', '-Wextra', '-Werror', '-fPIC', '-O2', '-fno-stack-protector',
             '-fno-builtin-memcmp', '-ffunction-sections', '-fdata-sections', '-D_GNU_SOURCE', '-DX2V_ANDROID',
             '-DX2V_SHAPE=2', '-DX2V_ENABLE_MODE21_PROFILE=1', '-DX2V_ALLOW_MODE21_START=1',
             '-I', H, '-I', A, '-I', CAND, '-I', BASE, '-I', ENC, '-include', A / 'android_errno.h']
    run([*z, *flags, '-c', src, '-o', obj])
    objects.append(obj)

def export_version(file, name):
    with file.open('rb') as f:
        e = ELFFile(f)
        ds = e.get_section_by_name('.dynsym')
        index = next(i for i, s in enumerate(ds.iter_symbols()) if s.name == name and s['st_shndx'] != 'SHN_UNDEF')
        v = e.get_section_by_name('.gnu.version').get_symbol(index)['ndx']
        if isinstance(v, str):
            return None
        names = {node['vd_ndx']: next(aux).name for node, aux in e.get_section_by_name('.gnu.version_d').iter_versions()}
        return names[v & 0x7fff]

provider_exports = {'cam_filter_dump_frame_data': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_set_streaming_params': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_start_streaming': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_stop_streaming': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_start_stream': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_stop_stream': 'lib64/libdcam_frwk.so',
                    'stream_group_mgr_create': 'lib64/libdcam_frwk.so', 'rcam_imgsys_create': 'lib64/librcam.so',
                    'dlsym': 'lib64/libdl.so', '__open_2': 'lib64/libc.so', 'fopen': 'lib64/libc.so',
                    'inotify_add_watch': 'lib64/libc.so', 'libevdev_next_event': 'lib64/libevdev.so',
                    'libevdev_uinput_write_event': 'lib64/libevdev.so'}
groups = {}
for name, file in provider_exports.items():
    v = export_version(S / file, name)
    if v:
        groups.setdefault(v, []).append(name)
internal = ['x2v_mode21_vendor_allowed', 'x2v_target_parser_owner', 'x2v_target_parser_class']
vmap = B / 'versions.map'
vmap.write_text('\n'.join(f'{v} {{ global: ' + '; '.join(n) + '; };' for v, n in groups.items())
                + '\nX2V_REVIEWED_INTERNAL { global: ' + '; '.join(internal) + '; local: *; };\n')
libs = [S / 'lib64' / n for n in ['libc.so', 'libdl.so', 'libm.so', 'libduml_hal.so', 'libduml_util.so', 'libduml_vcodec.so']]
artifact = B / 'libx2v_prr_resident.so'
run([*z, '-nostdlib', '-shared', '-Wl,--gc-sections', '-Wl,--allow-shlib-undefined', f'-Wl,--version-script={vmap}',
     *objects, *libs, '-o', artifact])

provider_symbols = set()
for p in libs + [S / 'bin/linker64']:
    with p.open('rb') as f:
        provider_symbols |= {s.name for s in ELFFile(f).get_section_by_name('.dynsym').iter_symbols()
                             if s.name and s['st_shndx'] != 'SHN_UNDEF'}
with artifact.open('rb') as f:
    e = ELFFile(f)
    d = e.get_section_by_name('.dynsym')
    imports = sorted(s.name for s in d.iter_symbols() if s.name and s['st_shndx'] == 'SHN_UNDEF')
    missing = [n for n in imports if n not in provider_symbols]
    assert not missing, missing
    exports = {s.name for s in d.iter_symbols() if s.name and s['st_shndx'] not in ['SHN_UNDEF', 'SHN_ABS']}
    assert exports == set(provider_exports) | set(internal), exports ^ (set(provider_exports) | set(internal))
    versions = [c.name for v, aux in e.get_section_by_name('.gnu.version_r').iter_versions() for c in aux]
    assert not any('GLIBC' in n for n in versions), versions
for n, pv in provider_exports.items():
    assert export_version(artifact, n) == export_version(S / pv, n), n

receipt = {'artifact': str(artifact), 'sha256': sha(artifact), 'bytes': artifact.stat().st_size,
           'token': 'GROUP13_MODE21C24_PRR_RESIDENT_V1', 'format': 'aprn', 'profile': 0,
           'sources': {str(p.relative_to(R)): sha(p) for p in sources}, 'imports': imports,
           'exports': sorted(exports), 'commands': commands}
(B / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(artifact.name, receipt['sha256'], receipt['bytes'])
