#!/usr/bin/env python3
"""On-camera benchmarks (bench_pv.c, bench_write.c, bench_pack.c), same compiler flags as the resident lib.
   build_bench.py [name]  (default bench_pv)"""
import subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
R = HERE.parents[2]
EXP = R / 'native-video/experimental'
A = EXP / 'source-receiver-adapter'
START = EXP / 'resident-cinemadng-length-allocation-benchmark/start.c'
S = R / 'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
B = HERE / 'build/bench'
B.mkdir(parents=True, exist_ok=True)

def run(c):
    r = subprocess.run(list(map(str, c)), capture_output=True, text=True, timeout=120)
    if r.returncode:
        raise RuntimeError(r.stderr)

name = sys.argv[1] if len(sys.argv) > 1 else 'bench_pv'
objects = []
for i, src in enumerate([HERE / f'{name}.c', START]):
    obj = B / f'{name}-{i}.o'
    run([sys.executable, '-m', 'ziglang', 'cc', '-target', 'aarch64-linux-gnu', '-std=c11', '-O2', '-Wall', '-Wextra',
         '-Werror', '-fPIE', '-D_GNU_SOURCE', '-DX2V_ANDROID', '-fno-stack-protector', '-ffunction-sections',
         '-fdata-sections', '-I', EXP / 'prores-raw-encoder', '-include', A / 'android_errno.h', '-c', src, '-o', obj])
    objects.append(obj)
v = B / 'exports.map'
v.write_text('{local:*;};\n')
out = B / name
run([sys.executable, '-m', 'ziglang', 'ld.lld', '-m', 'aarch64linux', '-pie', '--gc-sections', '--entry=_start',
     '--dynamic-linker=/system/bin/linker64', f'--version-script={v}', '-z', 'now', '-z', 'relro', *objects,
     S / 'lib64/libc.so', S / 'lib64/libm.so', '-o', out])
print(out)
