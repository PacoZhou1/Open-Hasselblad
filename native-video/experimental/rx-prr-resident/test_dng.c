/* Host test for dng.c on a synthetic MODE21 frame whose banding-class pixels carry the
 * class gain, as the sensor's do:
 *   - the in-place fix restores them, and agrees with the ProRes RAW preprocess;
 *   - 12-bit packing in place rounds every sample, edge values included;
 *   - packing first, then black, white balance and the fix on the packed frame, gives the
 *     same bytes as the 16-bit path;
 *   - the frame is written as a DNG for independent readers (tifffile, dcraw_emu, sips).
 * Usage: test_dng out.dng */
#include "awb.h"
#include "dng.h"
#include "prr_pre.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static uint64_t now_us(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000 + (uint64_t)t.tv_nsec / 1000;
}

#define SW 3968
#define SH 2946
#define W 3888
#define H 2912

static double scene(int x, int y)
{
    /* RGGB: a smooth gradient per channel, well inside the sensor's range. */
    double r = 9000 + 6 * x, g = 14000 + 4 * y, b = 6000 + 3 * (x + y);
    return (y & 1) == 0 ? ((x & 1) == 0 ? r : g) : ((x & 1) == 0 ? g : b);
}

int main(int argc, char **argv)
{
    const char *out = argc > 1 ? argv[1] : "test.dng";
    static const struct prr_pre_geom geom = PRR_PRE_GEOM_MODE21;
    static const struct dng_geom dg = DNG_GEOM_MODE21;
    const float white = 64681.0f, true_black = 4096.0f;
    struct prr_pre pre, plain;
    if (prr_pre_init(&pre, &geom, white, 0, 1) || prr_pre_init(&plain, &geom, white, 0, 0)) return 1;
    uint16_t *src = malloc((size_t)SW * SH * 2), *ref = malloc((size_t)SW * H * 2), *lin = malloc((size_t)SW * H * 2);
    if (!src || !ref || !lin) return 1;

    for (int y = 0; y < SH; y++)
        for (int x = 0; x < SW; x++) {
            int active = y >= 32 && y < 32 + H && x >= 16 && x < 16 + W;
            double v = active ? true_black + scene(x, y) : true_black + ((x * 7 + y * 3) % 9) - 4;
            if (active && y % 6 == 1) v = true_black + (v - true_black) * prr_band_gain((float)x, (float)y);
            src[(size_t)y * SW + x] = (uint16_t)lrint(v);
        }

    float black = prr_pre_black(&pre, src);
    prr_pre_rows(&pre, src, ref, black, 0, H);
    dng_fix_classes(&pre, src);
    prr_pre_rows(&plain, src, lin, black, 0, H);

    int fails = 0, restored = 0, worst_restore = 0, worst_match = 0;
    for (int y = 32; y < 32 + H; y++)
        for (int x = 16; x < 16 + W; x++) {
            int d = abs((int)src[(size_t)y * SW + x] - (int)lrint(true_black + scene(x, y)));
            if (y % 6 == 1) restored++;
            if (d > worst_restore) worst_restore = d;
            int r = (y - 32) * SW + (x - 16);
            int m = abs((int)ref[r] - (int)lin[r]);
            if (m > worst_match) worst_match = m;
        }
    printf("black %.2f (true %.0f)\n", black, true_black);
    printf("class pixels %d; worst |fixed - scene| %d; worst |prores preprocess - fixed then scaled| %d\n",
           restored, worst_restore, worst_match);
    if (fabsf(black - true_black) > 1) { puts("FAIL black"); fails++; }
    if (restored != 485 * 3888) { puts("FAIL class pixel count"); fails++; }
    if (worst_restore > 2) { puts("FAIL restore"); fails++; }
    if (worst_match > 3) { puts("FAIL prores agreement"); fails++; }

    /* 12-bit packing, in place: unpack and compare with each sample rounded on its own. */
    static const uint16_t edge[16] = { 0, 7, 8, 23, 24, 4096, 4104, 32767, 65519, 65520, 65527, 65528, 65534, 65535, 1, 65535 };
    size_t n = (size_t)dg.stride_px * dg.rows, bad = 0;
    uint16_t *packed = malloc(n * 2);
    if (!packed) return 1;
    memcpy(packed, src, n * 2);
    memcpy(packed + 4 * SW + 3, edge, sizeof edge);   /* off the 16-sample block grid */
    memcpy(packed + n - 18, edge, sizeof edge);
    uint16_t *want = malloc(n * 2), tail[18], tail_want[18];
    if (!want) return 1;
    memcpy(tail, edge, sizeof edge);                  /* 18 samples: one block, then the scalar pair */
    tail[16] = 65535;
    tail[17] = 9;
    for (size_t i = 0; i < n; i++) want[i] = packed[i] >= 65528 ? 4095 : (uint16_t)((packed[i] + 8u) >> 4);
    for (int i = 0; i < 18; i++) tail_want[i] = tail[i] >= 65528 ? 4095 : (uint16_t)((tail[i] + 8u) >> 4);
    dng_pack12(packed, n);
    dng_pack12(tail, 18);
    for (size_t i = 0; i < n + 18; i += 2) {
        const uint8_t *t = i < n ? (const uint8_t *)packed + i / 2 * 3 : (const uint8_t *)tail + (i - n) / 2 * 3;
        const uint16_t *w = i < n ? want + i : tail_want + (i - n);
        if ((unsigned)(t[0] << 4 | t[1] >> 4) != w[0] || (unsigned)((t[1] & 15) << 8 | t[2]) != w[1]) bad++;
    }
    printf("12-bit pack: %zu + 18 samples, %zu pairs wrong\n", n, bad);
    if (bad) { puts("FAIL pack12"); fails++; }

    /* Packing first, as the resident does: on a sensor-like frame (samples 12-bit values
     * shifted up by 4, noisy, with clipped and near-black patches) black, white balance and
     * the class fix on the packed frame give exactly the bytes of the 16-bit path. */
    {
        uint16_t *q = malloc((size_t)SW * SH * 2), *old = malloc((size_t)SW * SH * 2);
        uint8_t *neu = malloc(n * 3 / 2);
        if (!q || !old || !neu) return 1;
        uint32_t h = 12345;
        for (int y = 0; y < SH; y++)
            for (int x = 0; x < SW; x++) {
                h = h * 1664525u + 1013904223u;
                int active = y >= 32 && y < 32 + H && x >= 16 && x < 16 + W;
                /* Grey under a warm light: red at half of green, blue at 0.6. */
                double l = 4000 + 6 * x + 3 * y, c = (y & 1) == 0 ? ((x & 1) == 0 ? 0.5 : 1) : ((x & 1) == 0 ? 1 : 0.6);
                double v = active ? true_black + l * c : true_black;
                if (active && x > 3000 && y > 2500) v = 65535;
                if (active && x < 600 && y > 2600) v = true_black - 200;
                v += (double)(h >> 24) - 128;
                if (active && y % 6 == 1) v = true_black + (v - true_black) * prr_band_gain((float)x, (float)y);
                long s = lrint(v / 16) * 16;
                q[(size_t)y * SW + x] = (uint16_t)(s < 0 ? 0 : s > 65520 ? 65520 : s);
            }
        memcpy(old, q, (size_t)SW * SH * 2);
        float b_old = prr_pre_black(&pre, old), wr_old = 0, wb_old = 0, wr_new = 0, wb_new = 0;
        int a_old = awb_estimate(&pre, old, b_old, &wr_old, &wb_old);
        dng_fix_classes(&pre, old);
        dng_pack12(old, n);

        uint64_t t0 = now_us();
        dng_pack12_to(neu, q, n);
        uint64_t t1 = now_us();
        float b_new = dng_black12(&pre, neu);
        uint64_t t2 = now_us();
        int a_new = awb_estimate12(&pre, neu, b_new, &wr_new, &wb_new);
        uint64_t t3 = now_us();
        dng_fix_classes12(&pre, neu);
        uint64_t t4 = now_us();
        size_t diff = 0;
        for (size_t i = 0; i < n * 3 / 2; i++) diff += ((const uint8_t *)old)[i] != neu[i];
        printf("packed path: black %.4f vs %.4f, awb %d %.5f/%.5f vs %d %.5f/%.5f, %zu bytes differ\n", b_old, b_new,
               a_old, wr_old, wb_old, a_new, wr_new, wb_new, diff);
        printf("  host us: pack %llu black %llu awb %llu fix %llu\n", (unsigned long long)(t1 - t0),
               (unsigned long long)(t2 - t1), (unsigned long long)(t3 - t2), (unsigned long long)(t4 - t3));
        if (b_old != b_new) { puts("FAIL packed black"); fails++; }
        if (a_old || a_new || wr_old != wr_new || wb_old != wb_new) { puts("FAIL packed awb"); fails++; }
        if (diff) { puts("FAIL packed frame"); fails++; }
        free(q);
        free(old);
        free(neu);
    }

    memcpy(packed, src, n * 2);
    dng_pack12(packed, n);

    static uint8_t hdr[DNG_HDR_BYTES];
    const struct dng_color c = { 3.054f, 1.667f, 2.161865234375f, 2.167236328125f,
        { 0.7141116f, 0.1032353f, 0.1331231f, 0.2757776f, 0.8515739f, -0.1273514f, 0.1016372f, -0.420501f, 1.407694f } };
    if (dng_header(hdr, &dg, &c, black, (uint32_t)white, 24 * 61 + 5, 24)) { puts("FAIL header"); return 1; }
    FILE *f = fopen(out, "wb");
    if (!f || fwrite(hdr, 1, sizeof hdr, f) != sizeof hdr ||
        fwrite(packed, 1, (size_t)dng_pixel_bytes(&dg), f) != dng_pixel_bytes(&dg) || fclose(f)) {
        puts("FAIL write");
        return 1;
    }
    printf("%s: %u + %llu bytes\n", out, DNG_HDR_BYTES, (unsigned long long)dng_pixel_bytes(&dg));
    puts(fails ? "FAILED" : "OK");
    return fails != 0;
}
