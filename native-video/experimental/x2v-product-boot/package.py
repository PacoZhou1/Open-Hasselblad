#!/usr/bin/env python3
"""Assemble the X2V firmware payload: every file the camera needs, SHA-pinned, plus its installer."""
import hashlib, json, shutil, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
R = HERE.parents[2]
NV = R / 'native-video'
VERSION = '20261015b'
MODVER = '20261013c'
OUT = HERE / 'dist' / f'x2v-fw-{VERSION}'
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()

subprocess.run([sys.executable, HERE / 'build.py'], check=True)
# Rebuild is allowed; a new weston/test hash would fail exists_different on the camera.
ZK = HERE / 'dist' / 'x2v-fw-20261014zk'
if sha(HERE / 'build/x2v-boot.so') != '95bb9145280095a1062deb29801227b9ff38e9267521a4aa9e5b0d8f1e9b6d75':
    shutil.copy2(ZK / 'x2v-boot-20261013c.so', HERE / 'build/x2v-boot.so')
if sha(HERE / 'build/x2v_weston_boot_test') != '6312cfc7c84ecd888ccd69f452b2d8940922857a295e11e3f3f1744c4f52014b':
    shutil.copy2(ZK / 'x2v_weston_boot_test_20261013a', HERE / 'build/x2v_weston_boot_test')

subprocess.run([sys.executable, NV / 'experimental/prores-raw-encoder/build.py'], check=True, capture_output=True)

# (local source, pinned sha or None, mode, destination)
FILES = [
    (NV / 'experimental/rx-prr-resident/build/libx2v_prr_resident.so',
     'b0ec5c175861f457b3462b8de605ff966e424253f7bed540338647f8e0cbcf3b', '644',
     '/system/lib64/libx2v_prr_resident_20261014zl.so'),
    (NV / 'outputs/runtime/libx2v_gui_bootstrap.so',
     '2ec7b4686682ea1c5c9e9de87876135e0085b8563c90d223211150c3572708dd', '644',
     '/system/lib64/libx2v_gui_bootstrap_20261011.so'),
    (NV / 'experimental/prores-raw-encoder/build/x2v_prr_play',
     'c3b3a3ea463bcbe8bf51b3b8ba171ff7424c3a6a753701f9f180c1ceeebfca5b', '755',
     '/system/bin/x2v_prr_play_20261014zg'),
    (NV / 'experimental/grok-raw30c-session/imx861bqr_hb722.sp',
     '594f651e83a6d916e9af64ac96c718038c511c3a419028690982b079a6e729e4', '644', '/system/etc/x2v/imx861bqr_hb722.sp'),
    (NV / 'experimental/source-session-isolated-two-v22-flat/imx861bqr_hb722.conf',
     '5558a0fc6a5864c4711a3f0d0fba5b66d775822d6522b599724a9921d0fca3aa', '644', '/system/etc/x2v/imx861bqr_hb722.conf'),
    (NV / 'experimental/rx-prr-resident/imx861bqr_hb722_view.conf',
     '31c0c21f207c9ac840edc7834767d8670a22832bf3e64b7fb16518a7374a4363', '644',
     '/system/etc/x2v/imx861bqr_hb722_view_20261014zg.conf'),
    (HERE / 'build/x2v-boot.so',
     '95bb9145280095a1062deb29801227b9ff38e9267521a4aa9e5b0d8f1e9b6d75', '644',
     f'/system/lib64/weston/x2v-boot-{MODVER}.so'),
    (HERE / 'build/x2v_weston_boot_test',
     '6312cfc7c84ecd888ccd69f452b2d8940922857a295e11e3f3f1744c4f52014b', '755',
     '/system/bin/x2v_weston_boot_test_20261013a'),
    (HERE / 'x2v_product_boot.sh', None, '755', f'/system/etc/x2v/x2v_product_boot_{VERSION}.sh'),
    (NV / 'experimental/rx-prr-resident/x2v_video_session.sh', None, '755',
     f'/system/etc/x2v/x2v_video_session_{VERSION}.sh'),
]

if OUT.exists():
    shutil.rmtree(OUT)
(OUT / 'gui').mkdir(parents=True)

stock_ini = (HERE / 'stock/weston.ini').read_bytes()
assert hashlib.sha256(stock_ini).hexdigest() == '879b0395a612949357aa08a3804e0805123115b895c059e0851099bd341adfcf'
anchor = b'shell=eagle-shell.so\n'
assert stock_ini.count(anchor) == 1
hook_ini = stock_ini.replace(anchor, anchor + f'modules=x2v-boot-{MODVER}.so\n'.encode())
(OUT / 'weston.ini.hook').write_bytes(hook_ini)
hook_sha = hashlib.sha256(hook_ini).hexdigest()

fw = (HERE / 'x2v_fw.sh').read_text().replace('@HOOK_INI_SHA@', hook_sha)
(OUT / f'x2v_fw_{MODVER}.sh').write_text(fw)
FILES.append((OUT / f'x2v_fw_{MODVER}.sh', None, '755', f'/system/etc/x2v/x2v_fw_{MODVER}.sh'))

manifest, files = [], {}
for src, pin, mode, dest in FILES:
    h = sha(src)
    assert pin is None or h == pin, (src, h)
    name = Path(dest).name
    if src.parent != OUT:
        shutil.copy2(src, OUT / name)
    manifest.append(f'{h} {mode} {dest} {name}')
    files[dest] = {'sha256': h, 'bytes': Path(src).stat().st_size, 'mode': mode, 'source': str(Path(src).relative_to(R))}
(OUT / 'manifest').write_text('\n'.join(manifest) + '\n')

gui = {}
for p in sorted((HERE / 'gui').iterdir()):
    shutil.copy2(p, OUT / 'gui' / p.name)
    gui[p.name] = sha(p)

receipt = {'version': VERSION, 'system_files': files,
           'gui_payload': {'dest': '/blackbox/x2v-native-20261011/gui', 'files': gui},
           'weston_ini': {'path': '/system/etc/weston.ini',
                          'stock_sha256': '879b0395a612949357aa08a3804e0805123115b895c059e0851099bd341adfcf',
                          'hooked_sha256': hook_sha, 'added_line': f'modules=x2v-boot-{MODVER}.so'}}
(OUT / 'receipt.json').write_text(json.dumps(receipt, indent=2, ensure_ascii=False) + '\n')
print(OUT, 'hook_ini', hook_sha)
for d, v in files.items():
    print(v['sha256'][:16], d)
