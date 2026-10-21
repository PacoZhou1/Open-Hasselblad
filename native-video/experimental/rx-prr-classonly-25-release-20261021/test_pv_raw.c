/* Host check of pv_raw.h on a 16-bit MODE21 DNG (3920 x 2946 strip, no compression):
 *   test_pv_raw in.dng out.ppm [frames=12]
 * The frame is placed at the camera's 3968-sample stride and rendered `frames` times, so the
 * white balance has settled as it would after half a second of viewfinder. */
#include "pv_raw.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static uint32_t rd(const uint8_t *b, int n) { uint32_t v = 0; for (int i = n - 1; i >= 0; i--) v = v << 8 | b[i]; return v; }

int main(int argc, char **argv)
{
    if (argc < 3) { fprintf(stderr, "usage: test_pv_raw in.dng out.ppm [frames]\n"); return 2; }
    int frames = argc > 3 ? atoi(argv[3]) : 12;
    FILE *f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 1; }
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    uint8_t *file = malloc((size_t)size);
    fseek(f, 0, SEEK_SET);
    if (fread(file, 1, (size_t)size, f) != (size_t)size) return 1;
    fclose(f);
    uint32_t ifd = rd(file + 4, 4), w = 0, h = 0, off = 0;
    for (unsigned i = 0, n = rd(file + ifd, 2); i < n; i++) {
        const uint8_t *e = file + ifd + 2 + 12 * i;
        uint32_t tag = rd(e, 2), type = rd(e + 2, 2), v = type == 3 ? rd(e + 8, 2) : rd(e + 8, 4);
        if (tag == 256) w = v;
        if (tag == 257) h = v;
        if (tag == 273) off = v;
    }
    if (w > PVR_STRIDE_PX || h < PVR_Y0 + 6 * PVR_H || (long)off + (long)w * h * 2 > size) {
        fprintf(stderr, "unexpected strip %ux%u at %u\n", w, h, off);
        return 1;
    }
    uint16_t *src = calloc((size_t)PVR_STRIDE_PX * h, 2);
    for (uint32_t y = 0; y < h; y++) memcpy(src + (size_t)y * PVR_STRIDE_PX, file + off + (size_t)y * w * 2, (size_t)w * 2);
    static const float cam_to_xyz[9] = { 0.7141116f, 0.1032353f, 0.1331231f, 0.2757776f, 0.8515739f, -0.1273514f,
                                         0.1016372f, -0.420501f, 1.407694f };
    struct pv_raw s;
    pv_raw_init(&s, cam_to_xyz, 2.161865234375f, 2.167236328125f, 64681.0f);
    uint16_t *rows = malloc(PVR_ROWS_BYTES);
    struct pvr_frame *fr = malloc(sizeof *fr), *frs = malloc(sizeof *frs);
    uint8_t *rgb = malloc((size_t)PVR_W * PVR_H * 3);
    double ms = 0;
    for (int i = 0; i < frames; i++) {
        struct timespec a, b;
        clock_gettime(CLOCK_MONOTONIC, &a);
        pv_raw_take(fr, src);
        pv_raw_render(&s, fr, rgb);
        clock_gettime(CLOCK_MONOTONIC, &b);
        ms += (b.tv_sec - a.tv_sec) * 1e3 + (b.tv_nsec - a.tv_nsec) / 1e6;
        if (i < 3 || i == frames - 1) printf("frame %d black=%.1f wb=%.3f/%.3f\n", i, s.black, s.wb[0], s.wb[1]);
    }
    printf("%.2f ms per frame (take + render)\n", ms / frames);
    {
        struct timespec x, y;
        clock_gettime(CLOCK_MONOTONIC, &x);
        for (int i = 0; i < 20; i++) pv_raw_take(fr, src);
        clock_gettime(CLOCK_MONOTONIC, &y);
        printf("take %.2f ms (NEON sums, %zu bytes kept)\n", ((y.tv_sec - x.tv_sec) * 1e3 + (y.tv_nsec - x.tv_nsec) / 1e6) / 20,
               sizeof fr->px);
    }
    /* NEON and scalar fixed point against float, each from a fresh state so all three start from
     * the same balance: the pixels and the next frame's gains must agree. */
    struct pv_raw a, b, c;
    pv_raw_init(&a, cam_to_xyz, 2.161865234375f, 2.167236328125f, 64681.0f);
    b = a;
    c = a;
    uint8_t *ref = malloc((size_t)PVR_W * PVR_H * 3), *sca = malloc((size_t)PVR_W * PVR_H * 3);
    struct timespec t0, t1, t2, t3;
    /* The float version renders the rows as they were; the take is checked NEON against scalar. */
    pv_raw_take_rows(rows, src);
    pvr_take(frs, src, 0);
    if (memcmp(fr->px, frs->px, sizeof fr->px) || fr->ob_sum != frs->ob_sum) { fprintf(stderr, "NEON take differs\n"); return 1; }
    clock_gettime(CLOCK_MONOTONIC, &t0);
    pv_raw_render(&a, fr, rgb);
    clock_gettime(CLOCK_MONOTONIC, &t1);
    pv_raw_render_scalar(&c, fr, sca);
    clock_gettime(CLOCK_MONOTONIC, &t2);
    pv_raw_render_float(&b, rows, ref);
    clock_gettime(CLOCK_MONOTONIC, &t3);
    int maxd = 0, maxs = 0;
    double sum = 0;
    for (size_t i = 0; i < (size_t)PVR_W * PVR_H * 3; i++) {
        int dd = abs((int)rgb[i] - (int)ref[i]), ds = abs((int)rgb[i] - (int)sca[i]);
        if (dd > maxd) maxd = dd;
        if (ds > maxs) maxs = ds;
        sum += dd;
    }
#define MS(x, y) ((y.tv_sec - x.tv_sec) * 1e3 + (y.tv_nsec - x.tv_nsec) / 1e6)
    printf("neon %.2f ms, scalar %.2f ms, float %.2f ms; vs float max %d mean %.3f; vs scalar max %d; "
           "wb neon %.3f/%.3f scalar %.3f/%.3f float %.3f/%.3f\n", MS(t0, t1), MS(t1, t2), MS(t2, t3), maxd,
           sum / ((double)PVR_W * PVR_H * 3), maxs, a.wb[0], a.wb[1], c.wb[0], c.wb[1], b.wb[0], b.wb[1]);
    /* Split in two parts as the preview thread does: the same pixels and the same next gains. */
    struct pv_raw d2;
    pv_raw_init(&d2, cam_to_xyz, 2.161865234375f, 2.167236328125f, 64681.0f);
    uint8_t *split = malloc((size_t)PVR_W * PVR_H * 3);
    struct pvr_k parts[2];
    pv_raw_begin(&d2, fr, &parts[0]);
    parts[1] = parts[0];
    pv_raw_part(&parts[1], fr, split, PVR_H / 2, PVR_H, 1);
    pv_raw_part(&parts[0], fr, split, 0, PVR_H / 2, 1);
    pv_raw_end(&d2, parts, 2);
    int splitd = memcmp(split, rgb, (size_t)PVR_W * PVR_H * 3) != 0;
    printf("split in two parts: pixels %s, wb %.3f/%.3f\n", splitd ? "DIFFER" : "identical", d2.wb[0], d2.wb[1]);
    if (splitd || d2.wb[0] != a.wb[0] || d2.wb[1] != a.wb[1]) { fprintf(stderr, "split render disagrees\n"); return 1; }
    if (maxd > 2 || maxs || fabsf(a.wb[0] - c.wb[0]) > 1e-6f || fabsf(a.wb[1] - c.wb[1]) > 1e-6f ||
        fabsf(a.wb[0] - b.wb[0]) > 0.01f || fabsf(a.wb[1] - b.wb[1]) > 0.01f) {
        fprintf(stderr, "fixed point disagrees\n");
        return 1;
    }
    FILE *o = fopen(argv[2], "wb");
    fprintf(o, "P6\n%d %d\n255\n", PVR_W, PVR_H);
    fwrite(rgb, 1, (size_t)PVR_W * PVR_H * 3, o);
    fclose(o);
    return 0;
}
