/* On-camera timing of the viewfinder path on a captured colour frame:
 *   bench_pv colour.nv12 [iterations] [out.ppm]
 * Prints the median microseconds of conversion, band measurement, band apply and
 * border fill, and an FNV-1a hash of the last output to compare builds. */
#include "pv_bands.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define W 1300
#define H 970
#define STRIDE 1536
#define OW (W / 2)
#define OH (H / 2)
#define MAXIT 400

static uint64_t now_us(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000u + (uint64_t)t.tv_nsec / 1000u;
}

static int cmp(const void *a, const void *b)
{
    uint32_t x = *(const uint32_t *)a, y = *(const uint32_t *)b;
    return x < y ? -1 : x > y;
}

static uint32_t median(uint32_t *v, int n)
{
    qsort(v, (size_t)n, sizeof *v, cmp);
    return v[n / 2];
}

int main(int argc, char **argv)
{
    if (argc < 2) return 2;
    int it = argc > 2 ? atoi(argv[2]) : 60;
    if (it < 1 || it > MAXIT) return 2;
    static uint8_t nv12[STRIDE * H * 3 / 2], rgb[OW * OH * 3];
    static uint32_t t[5][MAXIT];
    FILE *f = fopen(argv[1], "rb");
    if (!f || fread(nv12, 1, sizeof nv12, f) != sizeof nv12) return 1;
    fclose(f);
    static struct pv_bands s;
    pv_bands_init(&s);
    int nb = pvb_bands(OH), nblk = OW / PVB_BW;
    for (int i = 0; i < it; i++) {
        uint64_t t0 = now_us();
        pv_nv12_to_rgb(nv12, STRIDE, H, rgb, OW, OH);
        uint64_t t1 = now_us();
        pvb_measure_frame(&s, rgb, OW, nb, nblk);
        uint64_t t2 = now_us();
        pvb_apply(&s, rgb, OW, nb, nblk);
        uint64_t t3 = now_us();
        pvb_fill_border(rgb, OW, OH);
        uint64_t t4 = now_us();
        s.frames++;
        t[0][i] = (uint32_t)(t1 - t0);
        t[1][i] = (uint32_t)(t2 - t1);
        t[2][i] = (uint32_t)(t3 - t2);
        t[3][i] = (uint32_t)(t4 - t3);
        t[4][i] = (uint32_t)(t4 - t0);
    }
    uint32_t h = 2166136261u;
    for (size_t i = 0; i < sizeof rgb; i++) h = (h ^ rgb[i]) * 16777619u;
    printf("convert %u measure %u apply %u fill %u total %u us (median of %d) hash %08x\n", median(t[0], it),
           median(t[1], it), median(t[2], it), median(t[3], it), median(t[4], it), it, h);
    if (argc > 3 && (f = fopen(argv[3], "wb"))) {
        fprintf(f, "P6\n%d %d\n255\n", OW, OH);
        fwrite(rgb, 1, sizeof rgb, f);
        fclose(f);
    }
    return 0;
}
