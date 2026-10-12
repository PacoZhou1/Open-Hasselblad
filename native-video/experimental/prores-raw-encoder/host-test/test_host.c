/* Host harness: `pre <src.raw> <dst.raw> <banding> [black]` runs NEON and scalar preprocessing and
 * checks they agree; `mov <in.prr> <out.mov>` wraps an elementary stream with prr_mov. */
#include "../prr_mov.h"
#include "../prr_pre.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static void *slurp(const char *path, size_t *n)
{
    FILE *f = fopen(path, "rb");
    if (!f)
        return NULL;
    fseek(f, 0, SEEK_END);
    *n = (size_t)ftell(f);
    fseek(f, 0, SEEK_SET);
    void *p = malloc(*n);
    if (p && fread(p, 1, *n, f) != *n) {
        free(p);
        p = NULL;
    }
    fclose(f);
    return p;
}

static double now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e3 + t.tv_nsec / 1e6;
}

static int pre(int argc, char **argv)
{
    static const struct prr_pre_geom g = PRR_PRE_GEOM_MODE21;
    struct prr_pre p;
    if (prr_pre_init(&p, &g, 64681.0f, -3.0f, atoi(argv[4])))
        return 1;
    size_t n, frame = (size_t)g.src_stride_px * g.src_rows * 2, out = (size_t)g.dst_stride_px * g.height * 2;
    uint16_t *src = slurp(argv[2], &n);
    if (!src || n % frame)
        return 1;
    FILE *f = fopen(argv[3], "wb");
    uint16_t *a = calloc(1, out), *b = calloc(1, out);
    size_t mismatch = 0;
    double t_neon = 0, t_scalar = 0;
    for (size_t i = 0; i < n / frame; i++) {
        const uint16_t *s = src + i * frame / 2;
        float black = argc > 5 ? strtof(argv[5], NULL) : prr_pre_black(&p, s);
        double t0 = now_ms();
        prr_pre_rows(&p, s, a, black, 0, g.height);
        double t1 = now_ms();
        prr_pre_rows_scalar(&p, s, b, black, 0, g.height);
        t_neon += t1 - t0;
        t_scalar += now_ms() - t1;
        for (size_t k = 0; k < out / 2; k++)
            mismatch += a[k] != b[k];
        fwrite(a, 1, out, f);
        printf("frame %zu black %.3f\n", i, black);
    }
    fclose(f);
    printf("mismatch %zu neon_ms %.2f scalar_ms %.2f\n", mismatch, t_neon / (n / frame), t_scalar / (n / frame));
    prr_pre_free(&p);
    return mismatch != 0;
}

static int mov(char **argv)
{
    size_t n;
    uint8_t *d = slurp(argv[2], &n);
    if (!d)
        return 1;
    struct prr_mov m;
    int w = d[16] << 8 | d[17], h = d[18] << 8 | d[19];
    if (prr_mov_open(&m, argv[3], w, h, "aprh", 24000, 1000))
        return 1;
    size_t pos = 0;
    int frames = 0;
    while (pos + 8 <= n) {
        uint32_t size = (uint32_t)d[pos] << 24 | d[pos + 1] << 16 | d[pos + 2] << 8 | d[pos + 3];
        if (memcmp(d + pos + 4, "prrf", 4) || pos + size > n) {
            printf("truncated %zu\n", n - pos);
            break;
        }
        uint32_t half = size / 2;
        if (prr_mov_write(&m, d + pos, half, d + pos + half, size - half))
            return 1;
        pos += size;
        frames++;
    }
    printf("frames %d bytes %zu\n", frames, pos);
    return prr_mov_close(&m) ? 1 : 0;
}

int main(int argc, char **argv)
{
    if (argc >= 5 && !strcmp(argv[1], "pre"))
        return pre(argc, argv);
    if (argc == 4 && !strcmp(argv[1], "mov"))
        return mov(argv);
    fprintf(stderr, "usage: test_host pre src dst banding [black] | mov in.prr out.mov\n");
    return 2;
}
