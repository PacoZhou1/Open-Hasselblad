"""Build x2v_prr_enc and x2v_prr_dec as Bionic PIEs against the firmware 1.3.16 system libraries and check imports."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

from elftools.elf.elffile import ELFFile

P = Path(__file__).resolve().parent
R = P.parents[2]
S = R / 'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
B = P / 'build'
TARGETS = {
    'x2v_prr_enc': ['prr_hal.c', 'prr_pre.c', 'prr_mov.c', 'prr_enc.c', 'prr_tool.c', 'start.c'],
    'x2v_prr_dec': ['prr_hal.c', 'prr_dec.c', 'prr_movr.c', 'prr_view.c', 'prr_dec_tool.c', 'start.c'],
}
HEADERS = ['prr_pre.h', 'prr_mov.h', 'prr_movr.h', 'prr_enc.h', 'prr_dec.h', 'prr_view.h', 'prr_hal.h', 'prr_banding.h']
LIBS = ['libc.so', 'libm.so', 'libduml_util.so', 'libduml_hal.so', 'libduml_vcodec.so']


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run(cmd, log):
    cmd = [str(c) for c in cmd]
    log.append(cmd)
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if r.returncode:
        sys.exit(r.stderr)


def build(name, sources, log):
    objects = []
    for src in sources:
        obj = B / (src + '.o')
        if obj not in built:
            run([sys.executable, '-m', 'ziglang', 'cc', '-target', 'aarch64-linux-gnu', '-std=c11', '-O2', '-Wall',
                 '-Wextra', '-Werror', '-fPIE', '-DX2V_ANDROID', '-D_GNU_SOURCE', '-fno-builtin-memcmp',
                 '-fno-stack-protector', '-ffunction-sections', '-fdata-sections', '-include', P / 'android_errno.h',
                 '-c', P / src, '-o', obj], log)
            built.add(obj)
        objects.append(obj)
    vm = B / 'exports.map'
    vm.write_text('{ global: inotify_add_watch; local: *; };\n')
    binary = B / name
    run([sys.executable, '-m', 'ziglang', 'ld.lld', '-m', 'aarch64linux', '-pie', '--gc-sections', '--entry=_start',
         '--dynamic-linker=/system/bin/linker64', f'--version-script={vm}', '--export-dynamic-symbol=inotify_add_watch',
         '--allow-shlib-undefined', '-z', 'now', '-z', 'relro', *objects, *[S / 'lib64' / l for l in LIBS],
         '-o', binary], log)

    providers = {}
    for lib in LIBS:
        with (S / 'lib64' / lib).open('rb') as f:
            for s in ELFFile(f).get_section_by_name('.dynsym').iter_symbols():
                if s.name and s['st_shndx'] != 'SHN_UNDEF':
                    providers.setdefault(s.name, lib)
    with binary.open('rb') as f:
        e = ELFFile(f)
        ds = e.get_section_by_name('.dynsym')
        imports = sorted(s.name for s in ds.iter_symbols() if s.name and s['st_shndx'] == 'SHN_UNDEF')
        exports = sorted(s.name for s in ds.iter_symbols() if s.name and s['st_shndx'] != 'SHN_UNDEF')
        missing = [n for n in imports if n not in providers]
        needed = [t.needed for t in e.get_section_by_name('.dynamic').iter_tags() if t.entry.d_tag == 'DT_NEEDED']
        interp = next(p.get_interp_name() for p in e.iter_segments() if p['p_type'] == 'PT_INTERP')
        versions = [n.name for _, aux in e.get_section_by_name('.gnu.version_r').iter_versions() for n in aux] \
            if e.get_section_by_name('.gnu.version_r') else []
    assert not missing, missing
    assert exports == ['inotify_add_watch'], exports
    assert '__errno_location' not in imports and interp == '/system/bin/linker64'
    assert not any('GLIBC' in v for v in versions), versions
    return {
        'artifact': str(binary.relative_to(R)), 'sha256': sha(binary), 'bytes': binary.stat().st_size,
        'sources': {n: sha(P / n) for n in sources}, 'needed': needed,
        'imports': {n: providers[n] for n in imports}, 'exports': exports,
    }


built = set()


def main():
    B.mkdir(exist_ok=True)
    log = []
    receipt = {'scope': 'offline build; run from adb su on device',
               'headers': {n: sha(P / n) for n in HEADERS}, 'targets': {}, 'commands': log}
    for name, sources in TARGETS.items():
        receipt['targets'][name] = build(name, sources, log)
        t = receipt['targets'][name]
        print(name, t['sha256'], t['bytes'], t['needed'])
    (B / 'receipt.json').write_text(json.dumps(receipt, indent=1) + '\n')


if __name__ == '__main__':
    main()
