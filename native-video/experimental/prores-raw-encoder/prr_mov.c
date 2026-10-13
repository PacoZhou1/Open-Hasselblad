#include "prr_mov.h"
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

struct buf { uint8_t *p; size_t n, cap; int bad; };

static void put(struct buf *b, const void *d, size_t n)
{
    if (b->bad)
        return;
    if (b->n + n > b->cap) {
        size_t cap = b->cap ? b->cap * 2 : 4096;
        while (cap < b->n + n)
            cap *= 2;
        uint8_t *p = realloc(b->p, cap);
        if (!p) {
            b->bad = 1;
            return;
        }
        b->p = p;
        b->cap = cap;
    }
    memcpy(b->p + b->n, d, n);
    b->n += n;
}

static void be16(struct buf *b, uint32_t v) { uint8_t x[2] = { v >> 8, v }; put(b, x, 2); }
static void be32(struct buf *b, uint32_t v) { uint8_t x[4] = { v >> 24, v >> 16, v >> 8, v }; put(b, x, 4); }
static void be64(struct buf *b, uint64_t v) { be32(b, (uint32_t)(v >> 32)); be32(b, (uint32_t)v); }
static void zeros(struct buf *b, size_t n) { while (n--) put(b, "", 1); }

static size_t open_box(struct buf *b, const char *kind)
{
    size_t at = b->n;
    be32(b, 0);
    put(b, kind, 4);
    return at;
}

static size_t open_full(struct buf *b, const char *kind, uint32_t version_flags)
{
    size_t at = open_box(b, kind);
    be32(b, version_flags);
    return at;
}

static void close_box(struct buf *b, size_t at)
{
    if (b->bad)
        return;
    uint32_t n = (uint32_t)(b->n - at);
    uint8_t x[4] = { n >> 24, n >> 16, n >> 8, n };
    memcpy(b->p + at, x, 4);
}

static void unity_matrix(struct buf *b)
{
    static const uint32_t m[9] = { 0x10000, 0, 0, 0, 0x10000, 0, 0, 0, 0x40000000 };
    for (int i = 0; i < 9; i++)
        be32(b, m[i]);
}

static int write_all(int fd, const void *d, size_t n)
{
    const uint8_t *p = d;
    while (n) {
        ssize_t w = write(fd, p, n);
        if (w < 0 && errno == EINTR)
            continue;
        if (w <= 0)
            return -1;
        p += w;
        n -= (size_t)w;
    }
    return 0;
}

static int pwrite_all(int fd, const void *d, size_t n, uint64_t at)
{
    const uint8_t *p = d;
    while (n) {
        ssize_t w = pwrite(fd, p, n, (off_t)at);
        if (w < 0 && errno == EINTR)
            continue;
        if (w <= 0)
            return -1;
        p += w;
        at += (uint64_t)w;
        n -= (size_t)w;
    }
    return 0;
}

static int mov_begin(struct prr_mov *m, int fd, int width, int height, const char *fourcc,
                     uint32_t timescale, uint32_t sample_duration)
{
    memset(m, 0, sizeof *m);
    m->width = (uint16_t)width;
    m->height = (uint16_t)height;
    memcpy(m->fourcc, fourcc, 4);
    m->timescale = timescale;
    m->sample_duration = sample_duration;
    m->fd = fd;
    if (m->fd < 0)
        return -1;
    struct buf b = { 0 };
    size_t ftyp = open_box(&b, "ftyp");
    put(&b, "qt  ", 4);
    be32(&b, 0x200);
    put(&b, "qt  ", 4);
    close_box(&b, ftyp);
    m->wide_offset = b.n;
    be32(&b, 8);
    put(&b, "wide", 4);
    be32(&b, 0);
    put(&b, "mdat", 4);
    int rc = b.bad || write_all(m->fd, b.p, b.n) ? -1 : 0;
    m->pos = b.n;
    free(b.p);
    if (rc) {
        close(m->fd);
        m->fd = -1;
    }
    return rc;
}

int prr_mov_open(struct prr_mov *m, const char *path, int width, int height, const char *fourcc,
                 uint32_t timescale, uint32_t sample_duration)
{
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    if (fd < 0)
        return -1;
    return mov_begin(m, fd, width, height, fourcc, timescale, sample_duration);
}

int prr_mov_openat(struct prr_mov *m, int dirfd, const char *name, int width, int height,
                   const char *fourcc, uint32_t timescale, uint32_t sample_duration)
{
    int fd = openat(dirfd, name, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC, 0644);
    if (fd < 0)
        return -1;
    return mov_begin(m, fd, width, height, fourcc, timescale, sample_duration);
}

int prr_mov_fsync(struct prr_mov *m)
{
    return m->fd < 0 ? -1 : fsync(m->fd);
}

int prr_mov_write(struct prr_mov *m, const void *a, uint32_t alen, const void *b, uint32_t blen)
{
    if (m->count == m->capacity) {
        uint32_t cap = m->capacity ? m->capacity * 2 : 1024;
        uint32_t *s = realloc(m->sizes, cap * sizeof *s);
        if (!s)
            return -1;
        m->sizes = s;
        uint64_t *o = realloc(m->offsets, cap * sizeof *o);
        if (!o)
            return -1;
        m->offsets = o;
        m->capacity = cap;
    }
    if (write_all(m->fd, a, alen) || (blen && write_all(m->fd, b, blen)))
        return -1;
    m->sizes[m->count] = alen + blen;
    m->offsets[m->count] = m->pos;
    m->count++;
    m->pos += (uint64_t)alen + blen;
    return 0;
}

static void build_moov(const struct prr_mov *m, struct buf *b)
{
    uint32_t duration = m->count * m->sample_duration;
    size_t moov = open_box(b, "moov");

    size_t mvhd = open_full(b, "mvhd", 0);
    be32(b, 0); be32(b, 0); be32(b, m->timescale); be32(b, duration);
    be32(b, 0x10000); be16(b, 0x100); zeros(b, 10);
    unity_matrix(b);
    zeros(b, 24);
    be32(b, 2);
    close_box(b, mvhd);

    size_t trak = open_box(b, "trak");
    size_t tkhd = open_full(b, "tkhd", 3);
    be32(b, 0); be32(b, 0); be32(b, 1); be32(b, 0); be32(b, duration);
    zeros(b, 8); be16(b, 0); be16(b, 0); be16(b, 0); be16(b, 0);
    unity_matrix(b);
    be32(b, (uint32_t)m->width << 16); be32(b, (uint32_t)m->height << 16);
    close_box(b, tkhd);

    size_t mdia = open_box(b, "mdia");
    size_t mdhd = open_full(b, "mdhd", 0);
    be32(b, 0); be32(b, 0); be32(b, m->timescale); be32(b, duration); be16(b, 0x7fff); be16(b, 0);
    close_box(b, mdhd);
    size_t hdlr = open_full(b, "hdlr", 0);
    put(b, "mhlr", 4); put(b, "vide", 4); zeros(b, 12); zeros(b, 1);
    close_box(b, hdlr);

    size_t minf = open_box(b, "minf");
    size_t vmhd = open_full(b, "vmhd", 1);
    zeros(b, 8);
    close_box(b, vmhd);
    size_t dinf = open_box(b, "dinf");
    size_t dref = open_full(b, "dref", 0);
    be32(b, 1);
    size_t alis = open_full(b, "alis", 1);
    close_box(b, alis);
    close_box(b, dref);
    close_box(b, dinf);

    size_t stbl = open_box(b, "stbl");
    size_t stsd = open_full(b, "stsd", 0);
    be32(b, 1);
    size_t entry = open_box(b, m->fourcc);
    static const char name[] = "Apple ProRes RAW";
    zeros(b, 6); be16(b, 1);
    be16(b, 0); be16(b, 0); put(b, "appl", 4); be32(b, 0); be32(b, 0x200);
    be16(b, m->width); be16(b, m->height); be32(b, 0x480000); be32(b, 0x480000); be32(b, 0); be16(b, 1);
    uint8_t len = sizeof name - 1;
    put(b, &len, 1); put(b, name, len); zeros(b, 31 - len);
    be16(b, 24); be16(b, 0xffff);
    close_box(b, entry);
    close_box(b, stsd);

    size_t stts = open_full(b, "stts", 0);
    be32(b, 1); be32(b, m->count); be32(b, m->sample_duration);
    close_box(b, stts);
    size_t stsc = open_full(b, "stsc", 0);
    be32(b, 1); be32(b, 1); be32(b, 1); be32(b, 1);
    close_box(b, stsc);
    size_t stsz = open_full(b, "stsz", 0);
    be32(b, 0); be32(b, m->count);
    for (uint32_t i = 0; i < m->count; i++)
        be32(b, m->sizes[i]);
    close_box(b, stsz);
    size_t co64 = open_full(b, "co64", 0);
    be32(b, m->count);
    for (uint32_t i = 0; i < m->count; i++)
        be64(b, m->offsets[i]);
    close_box(b, co64);
    close_box(b, stbl);
    close_box(b, minf);
    close_box(b, mdia);
    close_box(b, trak);
    close_box(b, moov);
}

int prr_mov_close(struct prr_mov *m)
{
    if (m->fd < 0)
        return -1;
    int rc = 0;
    uint64_t mdat_start = m->wide_offset + 8;
    uint64_t mdat_size = m->pos - mdat_start;
    struct buf b = { 0 };
    if (mdat_size <= 0xffffffffull) {
        be32(&b, (uint32_t)mdat_size);
        rc |= b.bad || pwrite_all(m->fd, b.p, b.n, mdat_start);
    } else {
        be32(&b, 1);
        put(&b, "mdat", 4);
        be64(&b, m->pos - m->wide_offset);
        rc |= b.bad || pwrite_all(m->fd, b.p, b.n, m->wide_offset);
    }
    b.n = 0;
    build_moov(m, &b);
    rc |= b.bad || pwrite_all(m->fd, b.p, b.n, m->pos);
    free(b.p);
    rc |= fsync(m->fd);
    rc |= close(m->fd);
    m->fd = -1;
    free(m->sizes);
    free(m->offsets);
    m->sizes = NULL;
    m->offsets = NULL;
    return rc ? -1 : 0;
}
