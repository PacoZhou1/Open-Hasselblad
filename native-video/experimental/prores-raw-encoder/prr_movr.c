#include "prr_movr.h"
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static uint32_t be32(const uint8_t *p) { return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | p[3]; }
static uint64_t be64(const uint8_t *p) { return (uint64_t)be32(p) << 32 | be32(p + 4); }
static uint16_t be16(const uint8_t *p) { return (uint16_t)(p[0] << 8 | p[1]); }

struct box {
    uint64_t start, payload, end;
    char type[4];
};

static int read_box(int fd, uint64_t pos, uint64_t limit, struct box *b)
{
    uint8_t h[16];
    if (pos + 8 > limit || pread(fd, h, 8, (off_t)pos) != 8)
        return 0;
    uint64_t size = be32(h);
    memcpy(b->type, h + 4, 4);
    b->start = pos;
    b->payload = pos + 8;
    if (size == 1) {
        if (pread(fd, h + 8, 8, (off_t)pos + 8) != 8)
            return 0;
        size = be64(h + 8);
        b->payload = pos + 16;
    } else if (size == 0) {
        size = limit - pos;
    }
    if (size < b->payload - pos)
        return 0;
    b->end = pos + size > limit ? limit : pos + size;
    return 1;
}

static uint8_t *load(int fd, const struct box *b, uint32_t *len)
{
    uint64_t n = b->end - b->payload;
    if (n > (64u << 20))
        return NULL;
    uint8_t *p = malloc(n ? n : 1);
    if (p && pread(fd, p, n, (off_t)b->payload) != (ssize_t)n) {
        free(p);
        return NULL;
    }
    *len = (uint32_t)n;
    return p;
}

struct tables {
    uint8_t *stsz, *stsc, *stco, *stts, *stsd, *mdhd;
    uint32_t stsz_n, stsc_n, stco_n, stts_n, stsd_n, mdhd_n;
    int co64;
};

static void free_tables(struct tables *t)
{
    free(t->stsz);
    free(t->stsc);
    free(t->stco);
    free(t->stts);
    free(t->stsd);
    free(t->mdhd);
    memset(t, 0, sizeof *t);
}

static void walk(int fd, uint64_t pos, uint64_t end, struct tables *t)
{
    struct box b;
    while (read_box(fd, pos, end, &b)) {
        if (!memcmp(b.type, "trak", 4) || !memcmp(b.type, "mdia", 4) || !memcmp(b.type, "minf", 4) ||
            !memcmp(b.type, "stbl", 4))
            walk(fd, b.payload, b.end, t);
#define LEAF(name, field)                                         \
        else if (!memcmp(b.type, name, 4) && !t->field)           \
            t->field = load(fd, &b, &t->field##_n);
        LEAF("stsz", stsz)
        LEAF("stsc", stsc)
        LEAF("stts", stts)
        LEAF("stsd", stsd)
        LEAF("mdhd", mdhd)
#undef LEAF
        else if ((!memcmp(b.type, "stco", 4) || !memcmp(b.type, "co64", 4)) && !t->stco) {
            t->co64 = b.type[1] == 'o';
            t->stco = load(fd, &b, &t->stco_n);
        }
        if (b.end <= pos)
            break;
        pos = b.end;
    }
}

static int from_tables(struct prr_movr *r, const struct tables *t)
{
    if (!t->stsz || !t->stsc || !t->stco || t->stsz_n < 12 || t->stsc_n < 8 || t->stco_n < 8)
        return -EINVAL;
    uint32_t n = be32(t->stsz + 8), fixed = be32(t->stsz + 4);
    if (!fixed && t->stsz_n < 12 + 4ull * n)
        return -EINVAL;
    uint32_t chunks = be32(t->stco + 4), entries = be32(t->stsc + 4);
    uint32_t w = t->co64 ? 8 : 4;
    if (t->stco_n < 8 + (uint64_t)w * chunks || t->stsc_n < 8 + 12ull * entries || !entries)
        return -EINVAL;
    r->sizes = calloc(n ? n : 1, sizeof *r->sizes);
    r->offsets = calloc(n ? n : 1, sizeof *r->offsets);
    if (!r->sizes || !r->offsets)
        return -ENOMEM;
    uint32_t s = 0;
    for (uint32_t e = 0; e < entries && s < n; e++) {
        const uint8_t *p = t->stsc + 8 + 12 * e;
        uint32_t first = be32(p), per = be32(p + 4);
        uint32_t last = e + 1 < entries ? be32(p + 12) - 1 : chunks;
        for (uint32_t c = first; c <= last && c >= 1 && c <= chunks && s < n; c++) {
            const uint8_t *q = t->stco + 8 + (uint64_t)w * (c - 1);
            uint64_t off = t->co64 ? be64(q) : be32(q);
            for (uint32_t k = 0; k < per && s < n; k++, s++) {
                r->sizes[s] = fixed ? fixed : be32(t->stsz + 12 + 4 * s);
                r->offsets[s] = off;
                off += r->sizes[s];
            }
        }
    }
    r->count = s;
    if (t->stts && t->stts_n >= 16 && be32(t->stts + 4))
        r->sample_duration = be32(t->stts + 12);
    if (t->mdhd && t->mdhd_n >= 16)
        r->timescale = t->mdhd[0] == 1 && t->mdhd_n >= 24 ? be32(t->mdhd + 20) : be32(t->mdhd + 12);
    if (t->stsd && t->stsd_n >= 8 + 36) {
        memcpy(r->fourcc, t->stsd + 12, 4);
        r->width = be16(t->stsd + 8 + 32);
        r->height = be16(t->stsd + 8 + 34);
    }
    return 0;
}

static int scan(struct prr_movr *r, uint64_t pos, uint64_t end)
{
    uint32_t cap = 0;
    r->count = 0;
    for (;;) {
        uint8_t h[8];
        if (pos + 8 > end || pread(r->fd, h, 8, (off_t)pos) != 8 || memcmp(h + 4, "prrf", 4))
            break;
        uint32_t size = be32(h);
        if (size < 8 || pos + size > end)
            break;
        if (r->count == cap) {
            cap = cap ? cap * 2 : 256;
            uint32_t *s = realloc(r->sizes, cap * sizeof *s);
            uint64_t *o = s ? realloc(r->offsets, cap * sizeof *o) : NULL;
            if (s)
                r->sizes = s;
            if (!o)
                return -ENOMEM;
            r->offsets = o;
        }
        r->sizes[r->count] = size;
        r->offsets[r->count++] = pos;
        pos += size;
    }
    r->recovered = 1;
    memcpy(r->fourcc, "aprh", 4);
    return 0;
}

int prr_movr_open(struct prr_movr *r, const char *path)
{
    memset(r, 0, sizeof *r);
    r->fd = open(path, O_RDONLY | O_CLOEXEC);
    if (r->fd < 0)
        return -errno;
    struct stat st;
    if (fstat(r->fd, &st)) {
        int e = -errno;
        prr_movr_close(r);
        return e;
    }
    r->file_size = (uint64_t)st.st_size;
    struct box b, mdat = { 0 }, moov = { 0 };
    int have_mdat = 0, have_moov = 0;
    for (uint64_t pos = 0; read_box(r->fd, pos, r->file_size, &b) && b.end > pos; pos = b.end) {
        if (!memcmp(b.type, "mdat", 4) && !have_mdat) {
            mdat = b;
            have_mdat = 1;
        } else if (!memcmp(b.type, "moov", 4)) {
            moov = b;
            have_moov = 1;
        }
    }
    int rc = -EINVAL;
    if (have_moov) {
        struct tables t = { 0 };
        walk(r->fd, moov.payload, moov.end, &t);
        rc = from_tables(r, &t);
        free_tables(&t);
        if (rc) {
            free(r->sizes);
            free(r->offsets);
            r->sizes = NULL;
            r->offsets = NULL;
        }
    }
    if (rc && have_mdat)
        rc = scan(r, mdat.payload, mdat.end);
    if (rc) {
        prr_movr_close(r);
        return rc;
    }
    return 0;
}

int prr_movr_read(const struct prr_movr *r, uint32_t i, void *buf, uint32_t cap)
{
    if (i >= r->count)
        return -ERANGE;
    if (r->sizes[i] > cap)
        return -ENOSPC;
    uint8_t *p = buf;
    uint32_t got = 0;
    while (got < r->sizes[i]) {
        ssize_t n = pread(r->fd, p + got, r->sizes[i] - got, (off_t)(r->offsets[i] + got));
        if (n <= 0)
            return n < 0 ? -errno : -EIO;
        got += (uint32_t)n;
    }
    return (int)got;
}

uint32_t prr_movr_max_size(const struct prr_movr *r)
{
    uint32_t m = 0;
    for (uint32_t i = 0; i < r->count; i++)
        if (r->sizes[i] > m)
            m = r->sizes[i];
    return m;
}

void prr_movr_close(struct prr_movr *r)
{
    if (r->fd >= 0)
        close(r->fd);
    free(r->sizes);
    free(r->offsets);
    memset(r, 0, sizeof *r);
    r->fd = -1;
}
