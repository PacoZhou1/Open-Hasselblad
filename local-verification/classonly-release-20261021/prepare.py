from pathlib import Path
import shutil,json,hashlib
R=Path(__file__).resolve().parents[2];E=R/'native-video/experimental';P=R/'releases/x2v-20261021-classonly-24-25/prr_pre_classonly.c'
for fps,base in [(24,'rx-prr-explore-toflimits-20261016'),(25,'rx-prr-af-c25-20261016')]:
 d=E/f'rx-prr-classonly-{fps}-release-20261021';assert not d.exists();shutil.copytree(E/base,d,ignore=shutil.ignore_patterns('build','__pycache__','*.log'))
 shutil.copy2(P,d/'prr_pre_classonly.c');p=d/'build.py';s=p.read_text();needle="+ [ENC / n for n in ['prr_hal.c', 'prr_pre.c', 'prr_enc.c', 'prr_mov.c']])";assert needle in s;s=s.replace(needle,"+ [ENC / n for n in ['prr_hal.c', 'prr_enc.c', 'prr_mov.c']] + [HERE / 'prr_pre_classonly.c'])");p.write_text(s)
 print(d)
