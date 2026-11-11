#!/usr/bin/env python3
"""Resident ProRes RAW receiver: own sources + unchanged MODE21 source/graph adapters + encoder."""
import hashlib, json, subprocess, sys, re
from pathlib import Path
from elftools.elf.elffile import ELFFile

HERE = Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/x2v-bugfix-20261110/rx24trackingfused')
R = HERE.parents[3]
EXP = R / 'native-video/experimental'
A = EXP / 'source-receiver-adapter'
BASE = HERE / 'adapter'
CAND = EXP / 'rx-prr-async/candidate'
H = R / 'research/full-fov-pipeline/source-adapter'
ENC = EXP / 'prores-raw-encoder'
S = R / 'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
B = Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/x2v-touch-tracking-20261110/bfm-ab/build')
B.mkdir(exist_ok=True)

# session_gate.c replaces BASE target_start_gate.c: the same gate plus the resident session guard.
ADAPTER = ['target_parser_gate.c', 'target_topology.c',
           'hal_topology_glue.c', 'fps_guard_session.c', 'source_mode21_guard_preload.c', 'target_descriptor.c']
sources = ([HERE / 'resident.c', HERE / 'reference_graph_binding.c', HERE.parent / 'preview_exposure_reference.c', HERE.parent / 'preview_exposure_runtime.c', HERE.parent / 'iq_redirect.c', HERE / 'vrec.c', HERE / 'dng.c', HERE / 'awb.c', Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/x2v-touch-tracking-20261110/bfm-ab/session_gate.c'),
            HERE / 'shutter_gate.c', HERE / 'preview_geometry.c', CAND / 'debug_hub_guard.c',
            A / 'android_stat_check.c']
           + [BASE / n for n in ADAPTER + ['geometry.c']]
           + [H / 'owned_descriptor.c', H / 'hal_profile_adapter.c']
           + [ENC / n for n in ['prr_hal.c', 'prr_enc.c', 'prr_mov.c']] + [HERE / 'prr_pre_classonly.c'])

sources.append(Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/x2v-touch-tracking-20261110/af-response-v/af_roi_diagnostics.c'))
sources.append(Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/x2v-touch-tracking-20261110/passive_observer_fps.c'))

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
input_receipts = {}
snapshot_root = B / "input-snapshot"
include_dirs = [H, A, CAND, BASE, ENC]
def snapshot(file):
    file = Path(file).resolve()
    relative = file.relative_to(R)
    data = file.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    name = str(relative)
    if name in input_receipts:
        assert input_receipts[name] == digest, "concurrent input mutation: " + name
        return snapshot_root / relative
    input_receipts[name] = digest
    dest = snapshot_root / relative
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(data)
    for include in re.findall(r'^\s*#\s*include\s*"([^"\n]+)"', data.decode(), re.M):
        candidate = next((d/include for d in [file.parent, *include_dirs] if (d/include).is_file()), None)
        if candidate is None: continue  # inactive conditional headers; compiler checks active includes
        snapshot(candidate)
    return dest

def run(c):
    command = list(map(str, c))
    if "-c" in command:
        ix = command.index("-c") + 1
        command[ix] = str(snapshot(command[ix]))
        for i, value in enumerate(command[:-1]):
            if value == "-I":
                command[i+1] = str(snapshot_root / Path(command[i+1]).relative_to(R))
            elif value == "-include":
                command[i+1] = str(snapshot(command[i+1]))
    commands.append(command)
    result = subprocess.run(command, capture_output=True, text=True, timeout=180)
    if result.returncode: raise RuntimeError(result.stderr)

def original_run(c):
    commands.append(list(map(str, c)))
    r = subprocess.run(list(map(str, c)), capture_output=True, text=True, timeout=120)
    if r.returncode:
        raise RuntimeError(r.stderr)

z = [sys.executable, '-m', 'ziglang', 'cc', '-target', 'aarch64-linux-gnu']
objects = []
for i, src in enumerate(sources):
    obj = B / f'{i}-{src.name}.o'
    flags = ['-std=c11', '-Wall', '-Wextra', '-Werror', '-fPIC', '-O2', '-fno-stack-protector',
             '-g0', '-fno-builtin-memcmp', '-ffunction-sections', '-fdata-sections', '-D_GNU_SOURCE', '-DX2V_ANDROID',
             '-DX2V_ENABLE_VOT_COPY=1', '-DX2V_DEBUG_VOT_TRANSPORT=1', '-DX2V_SHAPE=2', '-DX2V_ENABLE_MODE21_PROFILE=1', '-DX2V_ALLOW_MODE21_START=1',
             '-I', H, '-I', A, '-I', CAND, '-I', BASE, '-I', ENC, '-include', A / 'android_errno.h']
    if src == BASE / 'geometry.c':
        flags += ['-Dx2v_isp_full_transfer_geometry=x2v_base_isp_geometry']
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

provider_exports = {'taskbuf_inc_copy':'lib64/libdcam_base.so','dcam_af_get_stat_cfg':'lib64/libaaa.so','af_scene_bfm_set_stats':'lib64/libaaa.so','dcam_af_set_stat':'lib64/libaaa.so','open':'lib64/libc.so','open64':'lib64/libc.so','openat':'lib64/libc.so','openat64':'lib64/libc.so','fopen':'lib64/libc.so','fopen64':'lib64/libc.so','af_get_is_record':'lib64/libaaa.so','af_get_is_in_recording':'lib64/libaaa.so','afc_ctrl_process':'lib64/libaaa.so','af_get_afc_param':'lib64/libaaa.so','hybrid_af_start':'lib64/libaaa.so','af_get_frame_rate':'lib64/libaaa.so','alg_reset_all_alg_output_info':'lib64/libaaa.so','dcam_af_run':'lib64/libaaa.so','tof_dtof_ads6401_run':'lib64/libaaa.so','taskbuf_attach': 'lib64/libdcam_base.so','taskbuf_detach':'lib64/libdcam_base.so', 'dcam_af_get_stat_cfglist': 'lib64/libaaa.so', 'tof_lib_statistics_info': 'lib64/libaaa.so', 'taskbuf_get_consumer': 'lib64/libdcam_base.so', 'tof_dtof_ads6401_statistics': 'lib64/libaaa.so', 'cam_filter_dump_frame_data': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_set_streaming_params': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_start_streaming': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_stop_streaming': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_start_stream': 'lib64/libdcam_frwk.so',
                    'cam_cap_eng_stop_stream': 'lib64/libdcam_frwk.so',
                    'stream_group_mgr_create': 'lib64/libdcam_frwk.so', 'rcam_imgsys_create': 'lib64/librcam.so',
                    'dlsym': 'lib64/libdl.so', '__open_2': 'lib64/libc.so', 'fopen': 'lib64/libc.so',
                    'inotify_add_watch': 'lib64/libc.so', 'libevdev_next_event': 'lib64/libevdev.so',
                    'libevdev_uinput_write_event': 'lib64/libevdev.so'}
provider_exports.update({
 '_ZN20X2DIITofStreamFilter8onBufferEP16cam_frame_buffer':'lib64/camera/plugins/stream_filter/libdcam_x2dii_tof_stream_filter.so',
 '_ZN20X2DIITofStreamFilter14sendDataToRcamERK26_af_tof_spot_input_data_s_RK8FocusRoi':'lib64/camera/plugins/stream_filter/libdcam_x2dii_tof_stream_filter.so',
})
provider_exports.update({'cam_stream_consumer_get_parameter':'lib64/libdcam_frwk.so', 'cam_frame_buffer_remote_observer_start':'lib64/libdcam_observer.so'})
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
run([*z, '-nostdlib', '-shared', '-Wl,--strip-all', '-Wl,--gc-sections', '-Wl,--allow-shlib-undefined', f'-Wl,--version-script={vmap}',
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

for rel, digest in input_receipts.items():
    assert hashlib.sha256((R/rel).read_bytes()).hexdigest() == digest, "input changed during compilation: "+rel
(B/'input-snapshot-receipt.json').write_text(json.dumps(input_receipts,indent=2)+'\n')
