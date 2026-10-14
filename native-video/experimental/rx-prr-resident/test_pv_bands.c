/* Host check of pv_bands.h on a captured colour frame:
 *   test_pv_bands colour.nv12 out.ppm [frames]
 * Prints, in RGB8 units: the mean band-edge colour step, and the seam: the column
 * median of each row's second difference, summed over the rows around every band
 * edge (base: the same around rows midway between bands, i.e. the scene itself). */
#include "pv_bands.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define W 1300
#define H 970
#define STRIDE 1536
#define OW (W / 2)
#define OH (H / 2)

static int cmpf(const void *a, const void *b)
{
    float x = *(const float *)a, y = *(const float *)b;
    return x < y ? -1 : x > y;
}

static double edge_step(const uint8_t *rgb)
{
    double sum = 0;
    int n = 0;
    for (int k = 0; k < pvb_bands(OH); k++) {
        int a = PVB_FIRST + k * PVB_PITCH, e = a + PVB_H;
        int pairs[2][2] = { { a + 2, a - 2 }, { e - 2, e + 2 } };
        for (int j = 0; j < 2; j++)
            for (int x = 0; x < OW; x++) {
                const uint8_t *i = rgb + ((size_t)pairs[j][0] * OW + x) * 3, *o = rgb + ((size_t)pairs[j][1] * OW + x) * 3;
                int bg = (i[2] - i[1]) - (o[2] - o[1]), rg = (i[0] - i[1]) - (o[0] - o[1]);
                sum += abs(bg) + abs(rg);
                n++;
            }
    }
    return sum / n;
}

static double seam_at(const uint8_t *rgb, int row)
{
    static float v[OW];
    double s = 0;
    for (int y = row - 3; y <= row + 3; y++)
        for (int c = 0; c < 3; c++) {
            for (int x = 0; x < OW; x++) {
                const uint8_t *p = rgb + ((size_t)y * OW + x) * 3 + c;
                v[x] = p[0] - (p[-OW * 3] + p[OW * 3]) * 0.5f;
            }
            s += fabs(pvb_median(v, OW));
        }
    return s;
}

static void seams(const uint8_t *rgb, double *edge, double *base)
{
    int nb = pvb_bands(OH);
    *edge = *base = 0;
    for (int k = 0; k < nb; k++) {
        int a = PVB_FIRST + k * PVB_PITCH;
        *edge += (seam_at(rgb, a) + seam_at(rgb, a + PVB_H)) / 2;
        *base += (seam_at(rgb, a + PVB_H + 12) + seam_at(rgb, a - 24)) / 2;
    }
    *edge /= nb;
    *base /= nb;
}

static void report(const char *tag, const uint8_t *rgb)
{
    double e, b;
    seams(rgb, &e, &b);
    printf("%-8s colour %.2f  seam %.2f  base %.2f\n", tag, edge_step(rgb), e, b);
}

int main(int argc, char **argv)
{
    if (argc < 3) return 2;
    int frames = argc > 3 ? atoi(argv[3]) : 8;
    static uint8_t nv12[STRIDE * H * 3 / 2], rgb[OW * OH * 3];
    FILE *f = fopen(argv[1], "rb");
    if (!f || fread(nv12, 1, sizeof nv12, f) != sizeof nv12) return 1;
    fclose(f);
    static uint8_t ref[OW * OH * 3], noise[STRIDE * H * 3 / 2];
    pv_nv12_to_rgb(nv12, STRIDE, H, rgb, OW, OH);
    pv_nv12_to_rgb_scalar(nv12, STRIDE, H, ref, OW, OH);
    int same = !memcmp(rgb, ref, sizeof rgb);
    uint32_t r = 1;
    for (size_t i = 0; i < sizeof noise; i++) noise[i] = (uint8_t)((r = r * 1103515245u + 12345u) >> 16);
    pv_nv12_to_rgb(noise, STRIDE, H, rgb, OW, OH);
    pv_nv12_to_rgb_scalar(noise, STRIDE, H, ref, OW, OH);
    same &= !memcmp(rgb, ref, sizeof rgb);
    printf("convert matches scalar: %s\n", same ? "yes" : "NO");
    if (!same) return 3;
    for (int t = 0; t < 20000; t++) {
        float v[PVB_BW], u[PVB_BW];
        int n = 1 + t % PVB_BW;
        for (int i = 0; i < n; i++) v[i] = u[i] = (float)((r = r * 1103515245u + 12345u) >> 16 & (t & 1 ? 7 : 1023));
        qsort(u, (size_t)n, sizeof *u, cmpf);
        if (pvb_median(v, n) != u[n / 2]) { printf("median mismatch n=%d\n", n); return 4; }
    }
    printf("median matches sort: yes\n");
    static struct pv_bands s;
    pv_bands_init(&s);
    pv_nv12_to_rgb(nv12, STRIDE, H, rgb, OW, OH);
    report("before", rgb);
    for (int i = 0; i < frames; i++) {
        pv_nv12_to_rgb(nv12, STRIDE, H, rgb, OW, OH);
        pv_bands_fix(&s, rgb, OW, OH);
        char tag[16];
        snprintf(tag, sizeof tag, "frame %d", i);
        if (i == 0 || i == frames - 1) report(tag, rgb);
    }
    f = fopen(argv[2], "wb");
    fprintf(f, "P6\n%d %d\n255\n", OW, OH);
    fwrite(rgb, 1, sizeof rgb, f);
    fclose(f);
    /* Recording path: the converged gains on the full-size frame, seen through the plain conversion. */
    static uint8_t full[STRIDE * H * 3 / 2], half[OW * OH * 3];
    memcpy(full, nv12, sizeof full);
    pv_bands_fix_nv12(&s, full, STRIDE, W, H);
    pv_nv12_to_rgb(full, STRIDE, H, half, OW, OH);
    report("nv12", half);
    double diff = 0;
    for (size_t i = 0; i < sizeof half; i++) diff += abs(half[i] - rgb[i]);
    printf("nv12 vs rgb path: mean abs %.3f\n", diff / sizeof half);
    /* The vector, band-at-a-time fix against the per-block reference, on the frame and on noise. */
    static uint8_t ref_full[STRIDE * H * 3 / 2];
    const uint8_t *srcs[2] = { nv12, noise };
    for (int q = 0; q < 2; q++) {
        memcpy(full, srcs[q], sizeof full);
        memcpy(ref_full, srcs[q], sizeof ref_full);
        clock_t c0 = clock();
        for (int i = 0; i < 10; i++) { memcpy(full, srcs[q], sizeof full); pv_bands_fix_nv12(&s, full, STRIDE, W, H); }
        clock_t c1 = clock();
        for (int i = 0; i < 10; i++) { memcpy(ref_full, srcs[q], sizeof ref_full); pv_bands_fix_nv12_scalar(&s, ref_full, STRIDE, W, H); }
        clock_t c2 = clock();
        int worst_v = 0;
        size_t differ = 0;
        for (size_t i = 0; i < sizeof full; i++) {
            int d = abs(full[i] - ref_full[i]);
            differ += d != 0;
            if (d > worst_v) worst_v = d;
        }
        printf("nv12 fix vs scalar (%s): worst %d, %zu bytes differ; %.2f vs %.2f ms\n", q ? "noise" : "frame", worst_v,
               differ, (c1 - c0) * 100.0 / CLOCKS_PER_SEC, (c2 - c1) * 100.0 / CLOCKS_PER_SEC);
        if (worst_v > 1) return 6;
    }
    /* Identity gains must leave the active picture as it was, give or take rounding. */
    struct pv_bands one = s;
    for (int k = 0; k < PVB_MAX; k++)
        for (int j = 0; j < 2; j++)
            for (int n = 0; n < PVB_MAXBLK; n++)
                for (int c = 0; c < 3; c++) {
                    one.g[k][j][n][c] = 1;
                    for (int d = 0; d < 3; d++) one.t[k][j][d][n][c] = 1;
                }
    memcpy(full, nv12, sizeof full);
    pv_bands_fix_nv12(&one, full, STRIDE, W, H);
    int worst = 0;
    for (int y = 2 * PV_TOP_FILL; y < H * 3 / 2; y++)
        for (int x = 2 * PV_LEFT_FILL; x < W; x++) {
            int d = abs(full[(size_t)y * STRIDE + x] - nv12[(size_t)y * STRIDE + x]);
            if (y >= H && y < H + PV_TOP_FILL) d = 0;
            if (d > worst) worst = d;
        }
    printf("nv12 identity worst %d\n", worst);
    if (worst > 1) return 5;
    if (argc > 4) {
        f = fopen(argv[4], "wb");
        memcpy(full, nv12, sizeof full);
        pv_bands_fix_nv12(&s, full, STRIDE, W, H);
        for (int y = 0; y < H; y++) fwrite(full + (size_t)y * STRIDE, 1, W, f);
        for (int y = 0; y < H / 2; y++) fwrite(full + (size_t)(H + y) * STRIDE, 1, W, f);
        fclose(f);
    }
    return 0;
}
