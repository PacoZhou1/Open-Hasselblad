#include "prr_pre.h"
#include "prr_banding.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif

#define PRR_RANGE 65279.0
#define PRR_PEDESTAL 256
#define PRR_HIST_BINS 4096
#define PRR_BLACK_WINDOW 32

static void axis(const float *c, int n, float v, int *i, float *t)
{
    if (v <= c[0]) { *i = 0; *t = 0.0f; return; }
    if (v >= c[n - 1]) { *i = n - 2; *t = 1.0f; return; }
    int k = 0;
    while (v >= c[k + 1])
        k++;
    *i = k;
    *t = (v - c[k]) / (c[k + 1] - c[k]);
}

float prr_band_gain(float x, float y)
{
    int ix, iy;
    float tx, ty;
    axis(prr_band_cx, PRR_BAND_GX, x, &ix, &tx);
    axis(prr_band_cy, PRR_BAND_GY, y, &iy, &ty);
    const float *a = prr_band_g[iy], *b = prr_band_g[iy + 1];
    float top = a[ix] + (a[ix + 1] - a[ix]) * tx;
    float bot = b[ix] + (b[ix + 1] - b[ix]) * tx;
    return top + (bot - top) * ty;
}

int prr_pre_init(struct prr_pre *p, const struct prr_pre_geom *g, float white, float ob_bias, int banding)
{
    memset(p, 0, sizeof *p);
    p->g = *g;
    p->white = white;
    p->ob_bias = ob_bias;
    p->class_first = -1;
    if (g->width % 16 || g->x0 < 0 || g->y0 < 0 || g->x0 + g->width > g->src_stride_px ||
        g->y0 + g->height > g->src_rows || g->width > g->dst_stride_px)
        return -1;
    p->hist = calloc(PRR_HIST_BINS, sizeof *p->hist);
    if (!p->hist)
        return -1;
    if (!banding)
        return 0;
    p->class_first = ((1 - g->y0) % 6 + 6) % 6;
    p->class_rows = g->height > p->class_first ? (g->height - p->class_first + 5) / 6 : 0;
    p->class_cols = g->width / 2;
    /* The fix reads source rows two above the first class row and two below the last. */
    if (g->y0 + p->class_first < 2 || g->y0 + p->class_first + 6 * (p->class_rows - 1) + 2 >= g->src_rows) {
        prr_pre_free(p);
        return -1;
    }
    return 0;
}

void prr_pre_free(struct prr_pre *p)
{
    free(p->hist);
    p->hist = NULL;
}

float prr_pre_black(struct prr_pre *p, const uint16_t *src)
{
    uint32_t *h = p->hist;
    memset(h, 0, PRR_HIST_BINS * sizeof *h);
    uint32_t n = 0;
    for (int y = p->g.ob_y0; y < p->g.ob_y1; y++) {
        const uint16_t *s = src + (size_t)y * p->g.src_stride_px;
        for (int r = 0; r < 2; r++)
            for (int x = p->g.ob_x[r][0]; x < p->g.ob_x[r][1]; x++) {
                h[s[x] >> 4]++;
                n++;
            }
    }
    if (!n)
        return NAN;
    uint32_t acc = 0;
    int m = 0;
    while (m < PRR_HIST_BINS - 1 && (acc += h[m]) < (n + 1) / 2)
        m++;
    uint32_t lo = (uint32_t)(m > PRR_BLACK_WINDOW ? m - PRR_BLACK_WINDOW : 0) << 4;
    uint32_t hi = (uint32_t)(m + PRR_BLACK_WINDOW + 1) << 4;
    uint64_t sum = 0, cnt = 0;
    for (int y = p->g.ob_y0; y < p->g.ob_y1; y++) {
        const uint16_t *s = src + (size_t)y * p->g.src_stride_px;
        for (int r = 0; r < 2; r++)
            for (int x = p->g.ob_x[r][0]; x < p->g.ob_x[r][1]; x++)
                if (s[x] >= lo && s[x] < hi) {
                    sum += s[x];
                    cnt++;
                }
    }
    return (float)((double)sum / (double)cnt) + p->ob_bias;
}

struct lin { uint32_t gq, off; };

static struct lin lin_for(const struct prr_pre *p, float black)
{
    double span = (double)p->white - black;
    if (span < 1024.0)
        span = 1024.0;
    double gq = floor(PRR_RANGE * 32768.0 / span + 0.5);
    if (gq > 65535.0)
        gq = 65535.0;
    double off = floor(black * gq + 0.5) - (double)(PRR_PEDESTAL << 15);
    struct lin l = { (uint32_t)gq, off > 0.0 ? (uint32_t)off : 0u };
    return l;
}

static int class_row(const struct prr_pre *p, int r)
{
    return p->class_first >= 0 && r >= p->class_first && (r - p->class_first) % 6 == 0;
}

static inline uint16_t lin1(uint32_t v, struct lin l)
{
    uint64_t t = (uint64_t)v * l.gq;
    t = t > l.off ? t - l.off : 0;
    t = (t + 16384) >> 15;
    return (uint16_t)(t > 65535 ? 65535 : t);
}

void prr_pre_rows_scalar(const struct prr_pre *p, const uint16_t *src, uint16_t *dst, float black, int row_begin, int row_end)
{
    struct lin l = lin_for(p, black);
    const size_t two = 2 * (size_t)p->g.src_stride_px;
    for (int r = row_begin; r < row_end; r++) {
        const uint16_t *s = src + (size_t)(p->g.y0 + r) * p->g.src_stride_px + p->g.x0;
        uint16_t *d = dst + (size_t)r * p->g.dst_stride_px;
        if (class_row(p, r))
            for (int x = 0; x < p->g.width; x++)
                d[x] = lin1(((p->g.x0 + x) & 1) ? (((uint32_t)s[x - two] + s[x + two] + 1) >> 1) : s[x], l);
        else
            for (int x = 0; x < p->g.width; x++)
                d[x] = lin1(s[x], l);
    }
}

#if defined(__aarch64__)
static inline uint16x8_t lin8(uint16x8_t v, uint16x4_t g, uint32x4_t off)
{
    uint32x4_t lo = vqsubq_u32(vmull_u16(vget_low_u16(v), g), off);
    uint32x4_t hi = vqsubq_u32(vmull_u16(vget_high_u16(v), g), off);
    return vqrshrn_high_n_u32(vqrshrn_n_u32(lo, 15), hi, 15);
}

#endif

void prr_pre_rows(const struct prr_pre *p, const uint16_t *src, uint16_t *dst, float black, int row_begin, int row_end)
{
#if defined(__aarch64__)
    struct lin l = lin_for(p, black);
    uint16x4_t g = vdup_n_u16((uint16_t)l.gq);
    uint32x4_t off = vdupq_n_u32(l.off);
    const size_t two = 2 * (size_t)p->g.src_stride_px;
    for (int r = row_begin; r < row_end; r++) {
        const uint16_t *s = src + (size_t)(p->g.y0 + r) * p->g.src_stride_px + p->g.x0;
        uint16_t *d = dst + (size_t)r * p->g.dst_stride_px;
        if (!class_row(p, r)) {
            for (int x = 0; x < p->g.width; x += 8)
                vst1q_u16(d + x, lin8(vld1q_u16(s + x), g, off));
            continue;
        }
        /* Four streams outrun the camera's hardware prefetcher: without these the class rows cost
         * ~50% of the frame. */
        for (int x = 0; x < p->g.width; x += 8) {
            __builtin_prefetch(s + x - two + 128);
            __builtin_prefetch(s + x + two + 128);
            uint16x8_t m = vrhaddq_u16(vld1q_u16(s + x - two), vld1q_u16(s + x + two));
            /* Only absolute odd columns in the class row are defective. Keep measured G. */
            uint16x8_t mask = {0,65535,0,65535,0,65535,0,65535};
            if (p->g.x0 & 1) mask = vmvnq_u16(mask);
            m = vbslq_u16(mask, m, vld1q_u16(s + x));
            vst1q_u16(d + x, lin8(m, g, off));
        }
    }
#else
    prr_pre_rows_scalar(p, src, dst, black, row_begin, row_end);
#endif
}
