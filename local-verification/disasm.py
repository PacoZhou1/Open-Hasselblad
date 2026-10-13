import sys
from pathlib import Path
from elftools.elf.elffile import ELFFile
from capstone import Cs,CS_ARCH_ARM64,CS_MODE_ARM
p=Path('resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system/bin/camera-service')
with p.open('rb') as f:
 e=ELFFile(f);syms=list(e.get_section_by_name('.symtab').iter_symbols());names={s['st_value']:s.name for s in syms if s.name}
 dyn=e.get_section_by_name('.dynsym');plt=e.get_section_by_name('.plt')
 for i,rel in enumerate(e.get_section_by_name('.rela.plt').iter_relocations()):names[plt['sh_addr']+32+16*i]=dyn.get_symbol(rel['r_info_sym']).name
 def ro(a):
  for s in e.iter_sections():
   if s['sh_addr']<=a<s['sh_addr']+s['sh_size'] and s.name=='.rodata':
    v=s.data()[a-s['sh_addr']:a-s['sh_addr']+180].split(b'\0')[0]
    try:return repr(v.decode('ascii'))
    except:return ''
  return ''
 for s in syms:
  if s.name in sys.argv[1:]:
   sec=e.get_section(s['st_shndx']);o=s['st_value']-sec['sh_addr'];regs={}
   for x in Cs(CS_ARCH_ARM64,CS_MODE_ARM).disasm(sec.data()[o:o+s['st_size']],s['st_value']):
    note='';parts=x.op_str.split(', ')
    if x.mnemonic=='bl':note=names.get(int(x.op_str[1:],16),'')
    if x.mnemonic=='adrp':regs[parts[0]]=int(parts[1][1:],16)
    if x.mnemonic=='add' and len(parts)==3 and parts[1] in regs and parts[2].startswith('#'):
     a=regs[parts[1]]+int(parts[2][1:],0);note=ro(a)
    print(f'{x.address:x} {x.mnemonic} {x.op_str} {note}')
