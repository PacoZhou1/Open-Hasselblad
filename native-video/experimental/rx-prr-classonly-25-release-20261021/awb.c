#include "awb.h"
#include "dng.h"
#include <stddef.h>
#include <stdlib.h>

#define AWB_STEP_X 16
#define AWB_STEP_Y 12      /* a multiple of the class pattern's 6 rows */
#define AWB_MIN_QUADS 500
#define AWB_NEAR_LO 0.74f  /* balanced R/G and B/G within about +-0.3 in log */
#define AWB_NEAR_HI 1.35f

/* Sample x of window row y in source units, from the 16-bit frame or the packed one. */
static inline float at(const struct prr_pre *p, const uint16_t *s16, const uint8_t *s12, int y, int x)
{
    size_t r = (size_t)(p->g.y0 + y);
    unsigned c = (unsigned)(p->g.x0 + x);
    if (s12) return (float)(dng_get12(s12 + r * dng_row_bytes12(p), c) << 4);
    return s16[r * (size_t)p->g.src_stride_px + c];
}

/* The lit, unclipped quads are read from the frame once; the refining passes go over them. */
static int estimate(const struct prr_pre *p, const uint16_t *s16, const uint8_t *s12, float black,
                    float *wb_red, float *wb_blue)
{
    const struct prr_pre_geom *g = &p->g;
    const float range = p->white - black, hi = black + 0.92f * range, lo = 0.004f * range;
    /* Class pixels sit on odd rows; start where no sampled quad's odd row is one. */
    int y_first = 0;
    while (p->class_first >= 0 && y_first < 6 && ((y_first + 1 - p->class_first) % 6 + 6) % 6 == 0) y_first += 2;
    size_t cap = (size_t)(g->height / AWB_STEP_Y + 1) * (size_t)(g->width / AWB_STEP_X + 1), nq = 0;
    float *q = malloc(cap * 3 * sizeof *q);
    if (!q) return -1;
    for (int y = y_first; y + 1 < g->height; y += AWB_STEP_Y)
        for (int x = 0; x + 1 < g->width; x += AWB_STEP_X) {
            float a0 = at(p, s16, s12, y, x), a1 = at(p, s16, s12, y, x + 1);
            float b0 = at(p, s16, s12, y + 1, x), b1 = at(p, s16, s12, y + 1, x + 1);
            if (a0 >= hi || a1 >= hi || b0 >= hi || b1 >= hi) continue;
            float r = a0 - black, gg = 0.5f * (a1 + b0) - black, bl = b1 - black;
            if (gg < lo || r <= 0 || bl <= 0) continue;
            q[3 * nq] = r;
            q[3 * nq + 1] = gg;
            q[3 * nq + 2] = bl;
            nq++;
        }
    double kr = 0, kb = 0;
    for (int pass = 0; pass < 3; pass++) {
        double sr = 0, sg = 0, sb = 0;
        int n = 0;
        for (size_t i = 0; i < nq; i++) {
            float r = q[3 * i], gg = q[3 * i + 1], bl = q[3 * i + 2];
            if (pass) {
                float cr = (float)kr * r / gg, cb = (float)kb * bl / gg;
                if (cr < AWB_NEAR_LO || cr > AWB_NEAR_HI || cb < AWB_NEAR_LO || cb > AWB_NEAR_HI) continue;
            }
            sr += r;
            sg += gg;
            sb += bl;
            n++;
        }
        if (n < AWB_MIN_QUADS) break;
        kr = sg / sr;
        kb = sg / sb;
    }
    free(q);
    if (!(kr >= 1 && kr <= 5 && kb >= 1 && kb <= 5)) return -1;
    *wb_red = (float)kr;
    *wb_blue = (float)kb;
    return 0;
}

int awb_estimate(const struct prr_pre *p, const uint16_t *src, float black, float *wb_red, float *wb_blue)
{
    return estimate(p, src, NULL, black, wb_red, wb_blue);
}

int awb_estimate12(const struct prr_pre *p, const uint8_t *px, float black, float *wb_red, float *wb_blue)
{
    return estimate(p, NULL, px, black, wb_red, wb_blue);
}
