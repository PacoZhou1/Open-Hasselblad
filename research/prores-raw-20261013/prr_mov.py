"""Wrap a concatenated ProRes RAW elementary stream (size+'prrf' frames) into a minimal QuickTime MOV."""
import struct
import sys
from pathlib import Path


def box(kind, payload):
    return struct.pack('>I4s', 8 + len(payload), kind) + payload


def full(kind, version, flags, payload):
    return box(kind, struct.pack('>I', (version << 24) | flags) + payload)


def split_frames(data):
    frames, pos = [], 0
    while pos + 8 <= len(data):
        size, tag = struct.unpack_from('>I4s', data, pos)
        if tag != b'prrf' or size < 8 or pos + size > len(data):
            raise ValueError('bad frame at %d' % pos)
        frames.append(data[pos:pos + size])
        pos += size
    return frames


def frame_dims(frame):
    return struct.unpack_from('>HH', frame, 16)


def build(frames, fourcc=b'aprn', fps=24):
    w, h = frame_dims(frames[0])
    n = len(frames)
    unity = struct.pack('>9I', 0x10000, 0, 0, 0, 0x10000, 0, 0, 0, 0x40000000)
    mvhd = full(b'mvhd', 0, 0, struct.pack('>IIII', 0, 0, fps, n) + struct.pack('>IH', 0x10000, 0x100)
                + bytes(10) + unity + bytes(24) + struct.pack('>I', 2))
    tkhd = full(b'tkhd', 0, 3, struct.pack('>IIIII', 0, 0, 1, 0, n) + bytes(8) + struct.pack('>HHHH', 0, 0, 0, 0)
                + unity + struct.pack('>II', w << 16, h << 16))
    mdhd = full(b'mdhd', 0, 0, struct.pack('>IIIIHH', 0, 0, fps, n, 0x7fff, 0))
    hdlr = full(b'hdlr', 0, 0, b'mhlr' + b'vide' + bytes(12) + b'\x00')
    vmhd = full(b'vmhd', 0, 1, bytes(8))
    dref = full(b'dref', 0, 0, struct.pack('>I', 1) + full(b'alis', 0, 1, b''))
    dinf = box(b'dinf', dref)
    name = b'Apple ProRes RAW'
    entry = (bytes(6) + struct.pack('>H', 1) + struct.pack('>HH4sII', 0, 0, b'appl', 0, 0x200)
             + struct.pack('>HHIIIH', w, h, 0x480000, 0x480000, 0, 1)
             + bytes([len(name)]) + name + bytes(31 - len(name)) + struct.pack('>hh', 24, -1))
    stsd = full(b'stsd', 0, 0, struct.pack('>I', 1) + box(fourcc, entry))
    stts = full(b'stts', 0, 0, struct.pack('>III', 1, n, 1))
    stsc = full(b'stsc', 0, 0, struct.pack('>IIII', 1, 1, n, 1))
    stsz = full(b'stsz', 0, 0, struct.pack('>II', 0, n) + b''.join(struct.pack('>I', len(f)) for f in frames))
    ftyp = box(b'ftyp', b'qt  ' + struct.pack('>I', 0x200) + b'qt  ')
    mdat_off = len(ftyp) + 8
    stco = full(b'stco', 0, 0, struct.pack('>II', 1, mdat_off))
    stbl = box(b'stbl', stsd + stts + stsc + stsz + stco)
    minf = box(b'minf', vmhd + dinf + stbl)
    mdia = box(b'mdia', mdhd + hdlr + minf)
    trak = box(b'trak', tkhd + mdia)
    moov = box(b'moov', mvhd + trak)
    mdat = box(b'mdat', b''.join(frames))
    return ftyp + mdat + moov


def main():
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    fourcc = sys.argv[3].encode() if len(sys.argv) > 3 else b'aprn'
    frames = split_frames(src.read_bytes())
    dst.write_bytes(build(frames, fourcc))
    print(len(frames), 'frames', frame_dims(frames[0]), '->', dst)


if __name__ == '__main__':
    main()
