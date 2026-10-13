"""Read Qt v3 resource tables from this firmware ELF, without executing it."""
from pathlib import Path
import struct,zlib,json,hashlib
import zstandard
from elftools.elf.elffile import ELFFile
source=Path('resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/bin/camera-gui')
out=Path('resources/gui-resources');out.mkdir(exist_ok=True)
manifest=[]
with source.open('rb') as f:
 e=ELFFile(f)
 def read(s):
  sec=e.get_section(s['st_shndx']);pos=s['st_value']-sec['sh_addr'];return sec.data()[pos:pos+s['st_size']]
 symbols=list(e.get_section_by_name('.symtab').iter_symbols())
 groups={key:sorted([s for s in symbols if s.name==key],key=lambda s:s['st_value']) for key in ['_ZL16qt_resource_name','_ZL16qt_resource_data','_ZL18qt_resource_struct']}
 for group,(ns,ds,ts) in enumerate(zip(*groups.values())):
  names,data,tree=map(read,(ns,ds,ts));assert len(tree)%22==0
  seen=set()
  def walk(i,path):
   assert i not in seen;seen.add(i)
   no,flags,a,b=struct.unpack_from('>IHII',tree,i*22)
   n=struct.unpack_from('>H',names,no)[0]
   name=names[no+6:no+6+2*n].decode('utf-16-be') if i else ''
   parts=path+([name] if name else [])
   assert all(x not in ('.','..') and '/' not in x for x in parts)
   if flags&2:
    for child in range(b,b+a):walk(child,parts)
   else:
    size=struct.unpack_from('>I',data,b)[0];blob=data[b+4:b+4+size];assert len(blob)==size
    if flags&1:
     expected=struct.unpack_from('>I',blob)[0];blob=zlib.decompress(blob[4:]);assert len(blob)==expected
    if flags&4:blob=zstandard.ZstdDecompressor().decompress(blob)
    rel='/'.join(parts);p=out/str(group)/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    manifest.append(dict(group=group,path=rel,bytes=len(blob),sha256=hashlib.sha256(blob).hexdigest()))
  walk(0,[])
(out/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Extracted',len(manifest),'resources;',sum(x['path'].endswith('.qml') for x in manifest),'QML')
print('\n'.join(str(out/str(x['group'])/x['path']) for x in manifest if any(w in x['path'] for w in ['DriveMode','Recording','Video','Movie','LiveView','Main.qml'])))
