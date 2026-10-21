/* On-camera timing of the colour frame fix, step by step, on a frame from cdump (1536-stride NV12).
 *   bench_colfix <frame.nv12> [iterations] */
#include "pv_bands.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define W 1300
#define H 970
#define STRIDE 1536
#define BYTES (STRIDE * H * 3 / 2)

static double now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (double)t.tv_sec * 1e3 + (double)t.tv_nsec / 1e6;
}

int main(int argc, char **argv)
{
    if (argc < 2) return 2;
    int iters = argc > 2 ? atoi(argv[2]) : 50;
    static uint8_t src[BYTES], f[BYTES], rgb[(W / 2) * (H / 2) * 3];
    FILE *in = fopen(argv[1], "rb");
    if (!in || fread(src, 1, BYTES, in) != BYTES) { fprintf(stderr, "read %s\n", argv[1]); return 3; }
    fclose(in);
    struct pv_bands s;
    pv_bands_init(&s);
    double t[5] = { 0 };
    for (int i = 0; i < iters; i++) {
        memcpy(f, src, BYTES);
        double a = now_ms();
        double b = a;
        pv_bands_measure_nv12(&s, f, STRIDE, W, H, rgb);
        double c = now_ms();
        pv_bands_fix_nv12(&s, f, STRIDE, W, H);
        double d = now_ms();
        pv_bands_fix_luma_edges(f, STRIDE, W, H);
        double e = now_ms();
        t[0] += b - a; t[1] += c - b; t[2] += d - c; t[3] += e - d; t[4] += e - a;
    }
    printf("ms/frame: to_rgb %.2f measure %.2f fix_nv12 %.2f luma_edges %.2f total %.2f\n", t[0] / iters,
           t[1] / iters, t[2] / iters, t[3] / iters, t[4] / iters);
    return 0;
}
