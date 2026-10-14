#!/usr/bin/env python3
"""Weston boot module + its load test, linked against the device's own bionic."""
import hashlib, json, subprocess, sys
from pathlib import Path
from elftools.elf.elffile import ELFFile

HERE = Path(__file__).resolve().parent
R = HERE.parents[2]
S = R / 'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
B = HERE / 'build'
B.mkdir(exist_ok=True)
z = [sys.executable, '-m', 'ziglang', 'cc', '-target', 'aarch64-linux-gnu']
flags = ['-std=c11', '-Wall', '-Wextra', '-Werror', '-O2', '-fno-stack-protector', '-D_GNU_SOURCE']
libc = [S / 'lib64' / n for n in ['libc.so', 'libdl.so']]
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()


def run(c):
    r = subprocess.run(list(map(str, c)), capture_output=True, text=True, timeout=120)
    if r.returncode:
        raise SystemExit(r.stderr)


def symbols(p):
    with p.open('rb') as f:
        d = ELFFile(f).get_section_by_name('.dynsym')
        imp = sorted(s.name for s in d.iter_symbols() if s.name and s['st_shndx'] == 'SHN_UNDEF')
        exp = sorted(s.name for s in d.iter_symbols() if s.name and s['st_shndx'] not in ('SHN_UNDEF', 'SHN_ABS'))
    return imp, exp


provided = set()
for p in libc + [S / 'bin/linker64']:
    with p.open('rb') as f:
        provided |= {s.name for s in ELFFile(f).get_section_by_name('.dynsym').iter_symbols()
                     if s.name and s['st_shndx'] != 'SHN_UNDEF'}

def obj(src, extra):
    o = B / (Path(src).stem + '.o')
    run([*z, *flags, *extra, '-c', src, '-o', o])
    return o


mod = B / 'x2v-boot.so'
run([*z, '-nostdlib', '-shared', '-Wl,--gc-sections', obj(HERE / 'x2v_weston_boot.c', ['-fPIC', '-fvisibility=hidden']),
     *libc, '-o', mod])
test = B / 'x2v_weston_boot_test'
run([sys.executable, '-m', 'ziglang', 'ld.lld', '-m', 'aarch64linux', '-pie', '--gc-sections', '--entry=_start',
     '--dynamic-linker=/system/bin/linker64', '--allow-shlib-undefined', '-z', 'now', '-z', 'relro',
     obj(R / 'native-video/experimental/prores-raw-encoder/start.c', ['-fPIE']),
     obj(HERE / 'x2v_weston_boot_test.c', ['-fPIE']), *libc, '-o', test])

out = {}
for p in (mod, test):
    imp, exp = symbols(p)
    missing = [n for n in imp if n not in provided]
    assert not missing, (p.name, missing)
    out[p.name] = {'sha256': sha(p), 'bytes': p.stat().st_size, 'imports': imp, 'exports': exp}
assert out[mod.name]['exports'] == ['wet_module_init'], out[mod.name]['exports']
with test.open('rb') as f:
    assert ELFFile(f).get_section_by_name('.interp').data().rstrip(b'\0') == b'/system/bin/linker64'
with mod.open('rb') as f:
    d = ELFFile(f).get_section_by_name('.dynamic')
    assert sorted(t.needed for t in d.iter_tags() if t.entry.d_tag == 'DT_NEEDED') == ['libc.so', 'libdl.so']
(B / 'receipt.json').write_text(json.dumps(out, indent=2) + '\n')
for k, v in out.items():
    print(k, v['sha256'], v['bytes'])
