from pathlib import Path
import subprocess,sys
from elftools.elf.elffile import ELFFile
D=Path(__file__).resolve().parent;R=D.parents[1];B=D/'build';B.mkdir(exist_ok=True)
S=R/'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
z=[sys.executable,'-m','ziglang'];obs=[]
for src in [D/'sync_paths.c',R/'native-video/experimental/prores-raw-encoder/start.c']:
 o=B/(src.stem+'.o');subprocess.run([*z,'cc','-target','aarch64-linux-gnu','-O2','-std=c11','-Wall','-Wextra','-Werror','-fPIE','-fno-stack-protector','-c',str(src),'-o',str(o)],check=True);obs.append(str(o))
(B/'exports.map').write_text('{ local: *; };\n')
out=B/'x2v_sync_paths_20261017a'
subprocess.run([*z,'ld.lld','-m','aarch64linux','-pie','--entry=_start','--dynamic-linker=/system/bin/linker64','--version-script='+str(B/'exports.map'),'-z','now','-z','relro',*obs,str(S/'lib64/libc.so'),'-o',str(out)],check=True)
with out.open('rb') as f:
 e=ELFFile(f);assert e['e_machine']=='EM_AARCH64';assert next(s.get_interp_name() for s in e.iter_segments() if s['p_type']=='PT_INTERP')=='/system/bin/linker64'
subprocess.run(['cc','-Wall','-Wextra','-Werror',str(D/'sync_paths.c'),'-o',str(B/'sync-host')],check=True)
print('Built target and host publication flush helper')
