/* On-camera structural check of a recorded clip:
 *   bench_movcheck clip.mov
 * Walks the top-level atoms, reads stsz/co64 from moov, and checks that every sample sits
 * where the table says, back to back inside mdat, and starts with its own size and "prrf".
 * Also XOR-folds every sample's bytes so two copies of a clip can be compared. */
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static uint32_t be32(const uint8_t *p) { return (uint32_t)p[0] << 24 | p[1] << 16 | p[2] << 8 | p[3]; }
static uint64_t be64(const uint8_t *p) { return (uint64_t)be32(p) << 32 | be32(p + 4); }

/* First box of type t inside [p, p+n), descending through the listed containers. */
static const uint8_t *find(const uint8_t *p, size_t n, const char *t, uint32_t *len)
{
    static const char *containers[] = { "trak", "mdia", "minf", "stbl" };
    for (size_t o = 0; o + 8 <= n;) {
        uint32_t s = be32(p + o);
        if (s < 8 || o + s > n) return NULL;
        if (!memcmp(p + o + 4, t, 4)) { *len = s; return p + o; }
        for (int i = 0; i < 4; i++)
            if (!memcmp(p + o + 4, containers[i], 4)) {
                const uint8_t *r = find(p + o + 8, s - 8, t, len);
                if (r) return r;
            }
        o += s;
    }
    return NULL;
}

int main(int argc, char **argv)
{
    if (argc < 2) return 2;
    int fd = open(argv[1], O_RDONLY | O_CLOEXEC);
    if (fd < 0) { printf("open failed\n"); return 1; }
    off_t size = lseek(fd, 0, SEEK_END);
    uint64_t at = 0, mdat_at = 0, mdat_len = 0, moov_at = 0, moov_len = 0;
    uint8_t h[16];
    while (at + 8 <= (uint64_t)size) {
        if (pread(fd, h, 16, (off_t)at) < 8) break;
        uint64_t len = be32(h), hdr = 8;
        if (len == 1) { len = be64(h + 8); hdr = 16; }
        if (len < 8 || at + len > (uint64_t)size) { printf("bad atom at %llu len %llu\n", (unsigned long long)at, (unsigned long long)len); return 1; }
        if (!memcmp(h + 4, "mdat", 4)) { mdat_at = at + hdr; mdat_len = len - hdr; }
        if (!memcmp(h + 4, "moov", 4)) { moov_at = at; moov_len = len; }
        at += len;
    }
    if (at != (uint64_t)size || !mdat_at || !moov_at) { printf("atoms end %llu of %lld, mdat %llu moov %llu\n", (unsigned long long)at, (long long)size, (unsigned long long)mdat_at, (unsigned long long)moov_at); return 1; }
    uint8_t *moov = malloc(moov_len);
    if (!moov || pread(fd, moov, moov_len, (off_t)moov_at) != (ssize_t)moov_len) return 1;
    uint32_t zl, cl;
    const uint8_t *stsz = find(moov + 8, moov_len - 8, "stsz", &zl), *co64 = find(moov + 8, moov_len - 8, "co64", &cl);
    if (!stsz || !co64) { printf("no stsz/co64\n"); return 1; }
    uint32_t n = be32(stsz + 16);
    if (be32(co64 + 12) != n || zl < 20 + 4ull * n || cl < 16 + 8ull * n) { printf("table sizes\n"); return 1; }
    uint64_t expect = mdat_at, fold = 0, biggest = 0, slack = 0;
    uint8_t *buf = malloc(32u << 20);
    if (!buf) return 1;
    for (uint32_t i = 0; i < n; i++) {
        uint32_t s = be32(stsz + 20 + 4 * i);
        uint64_t o = be64(co64 + 16 + 8 * i);
        if (o != expect) { printf("sample %u at %llu, expected %llu\n", i, (unsigned long long)o, (unsigned long long)expect); return 1; }
        if (s > (32u << 20) || pread(fd, buf, s, (off_t)o) != (ssize_t)s) { printf("sample %u read\n", i); return 1; }
        if (s < 8 || be32(buf) > s || memcmp(buf + 4, "prrf", 4)) {
            printf("sample %u bad header: size %u field %u tag %.4s\n", i, s, be32(buf), (const char *)buf + 4);
            return 1;
        }
        if (s - be32(buf) > slack) slack = s - be32(buf);
        for (uint32_t k = 0; k + 8 <= s; k += 8) { uint64_t v; memcpy(&v, buf + k, 8); fold ^= v + k; }
        if (s > biggest) biggest = s;
        expect = o + s;
    }
    if (expect != mdat_at + mdat_len) { printf("samples end %llu, mdat ends %llu\n", (unsigned long long)expect, (unsigned long long)(mdat_at + mdat_len)); return 1; }
    printf("ok samples %u bytes %llu biggest %llu header_slack %llu fold %016llx\n", n, (unsigned long long)(expect - mdat_at),
           (unsigned long long)biggest, (unsigned long long)slack, (unsigned long long)fold);
    return 0;
}
