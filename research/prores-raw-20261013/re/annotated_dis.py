"""Disassemble an AArch64 range with PLT calls named and adrp/add string literals inlined.

Usage: annotated_dis.py <elf> <start_hex> <size_bytes>
"""
import sys

from capstone import CS_ARCH_ARM64, CS_MODE_ARM, Cs
from elftools.elf.elffile import ELFFile
from elftools.elf.relocation import RelocationSection


def plt_map(e):
    plt = e.get_section_by_name('.plt')
    rela = e.get_section_by_name('.rela.plt')
    dynsym = e.get_section_by_name('.dynsym')
    names = {}
    if not plt or not isinstance(rela, RelocationSection):
        return names
    for i, r in enumerate(rela.iter_relocations()):
        names[plt['sh_addr'] + 32 + 16 * i] = dynsym.get_symbol(r['r_info_sym']).name
    return names


def segments(e):
    return [(s['p_vaddr'], s['p_offset'], s['p_filesz']) for s in e.iter_segments() if s['p_type'] == 'PT_LOAD']


def read_cstr(data, segs, va):
    for v, o, n in segs:
        if v <= va < v + n:
            off = o + va - v
            end = data.find(b'\0', off, off + 200)
            s = data[off:end if end >= 0 else off + 200]
            if s and all(32 <= c < 127 or c in (9, 10) for c in s):
                return s.decode()
    return None


def main():
    path, start, size = sys.argv[1], int(sys.argv[2], 16), int(sys.argv[3])
    data = open(path, 'rb').read()
    e = ELFFile(open(path, 'rb'))
    segs = segments(e)
    plts = plt_map(e)
    text = next(v for v, o, n in segs if v <= start < v + n)
    v, o, n = next(s for s in segs if s[0] == text)
    code = data[o + start - v:o + start - v + size]
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True
    pages = {}
    for ins in md.disasm(code, start):
        note = ''
        ops = ins.op_str
        if ins.mnemonic == 'adrp':
            reg = ops.split(',')[0]
            pages[reg] = int(ops.split('#')[1], 16)
        elif ins.mnemonic == 'add' and '#' in ops:
            parts = [p.strip() for p in ops.split(',')]
            if len(parts) == 3 and parts[1] in pages and parts[2].startswith('#'):
                va = pages[parts[1]] + int(parts[2].lstrip('#'), 16)
                s = read_cstr(data, segs, va)
                note = ' ; "%s"' % s[:90] if s else ' ; =%#x' % va
        elif ins.mnemonic in ('bl', 'b') and ops.startswith('#'):
            tgt = int(ops[1:], 16)
            if tgt in plts:
                note = ' ; <%s>' % plts[tgt]
        print('%#7x: %-6s %s%s' % (ins.address, ins.mnemonic, ops, note))


if __name__ == '__main__':
    main()
