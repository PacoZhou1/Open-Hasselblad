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
    p->inv_q14 = malloc((size_t)p->class_rows * p->class_cols * sizeof *p->inv_q14);
    if (!p->inv_q14) {
        prr_pre_free(p);
        return -1;
    }
    int par = (1 - g->x0) & 1;
    for (int k = 0; k < p->class_rows; k++) {
        float y = (float)(g->y0 + p->class_first + 6 * k);
        uint16_t *row = p->inv_q14 + (size_t)k * p->class_cols;
        for (int j = 0; j < p->class_cols; j++) {
            float inv = 16384.0f / prr_band_gain((float)(g->x0 + 2 * j + par), y);
            row[j] = (uint16_t)(inv < 8192.0f ? 8192.0f : inv > 32767.0f ? 32767.0f : inv + 0.5f);
        }
    }
    return 0;
}

void prr_pre_free(struct prr_pre *p)
{
    free(p->inv_q14);
    free(p->hist);
    p->inv_q14 = NULL;
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

static const uint16_t *class_row(const struct prr_pre *p, int r)
{
    if (!p->inv_q14 || r < p->class_first || (r - p->class_first) % 6)
        return NULL;
    return p->inv_q14 + (size_t)((r - p->class_first) / 6) * p->class_cols;
}

static inline uint16_t lin1(uint32_t v, struct lin l)
{
    uint64_t t = (uint64_t)v * l.gq;
    t = t > l.off ? t - l.off : 0;
    t = (t + 16384) >> 15;
    return (uint16_t)(t > 65535 ? 65535 : t);
}

static inline uint16_t cls1(uint16_t o, uint16_t inv)
{
    int32_t s = ((int32_t)o - PRR_PEDESTAL) * (int32_t)inv;
    int32_t v = ((s + 8192) >> 14) + PRR_PEDESTAL;
    return (uint16_t)(v < 0 ? 0 : v > 65535 ? 65535 : v);
}

void prr_pre_rows_scalar(const struct prr_pre *p, const uint16_t *src, uint16_t *dst, float black, int row_begin, int row_end)
{
    struct lin l = lin_for(p, black);
    int par = (1 - p->g.x0) & 1;
    for (int r = row_begin; r < row_end; r++) {
        const uint16_t *s = src + (size_t)(p->g.y0 + r) * p->g.src_stride_px + p->g.x0;
        uint16_t *d = dst + (size_t)r * p->g.dst_stride_px;
        for (int x = 0; x < p->g.width; x++)
            d[x] = lin1(s[x], l);
        const uint16_t *inv = class_row(p, r);
        if (inv)
            for (int j = 0; j < p->class_cols; j++)
                d[2 * j + par] = cls1(d[2 * j + par], inv[j]);
    }
}

#if defined(__aarch64__)
static inline uint16x8_t lin8(uint16x8_t v, uint16x4_t g, uint32x4_t off)
{
    uint32x4_t lo = vqsubq_u32(vmull_u16(vget_low_u16(v), g), off);
    uint32x4_t hi = vqsubq_u32(vmull_u16(vget_high_u16(v), g), off);
    return vqrshrn_high_n_u32(vqrshrn_n_u32(lo, 15), hi, 15);
}

static inline int32x4_t cls4(uint16x4_t o, uint16x4_t inv, int32x4_t ped)
{
    int32x4_t s = vsubq_s32(vreinterpretq_s32_u32(vmovl_u16(o)), ped);
    s = vmulq_s32(s, vreinterpretq_s32_u32(vmovl_u16(inv)));
    return vaddq_s32(vrshrq_n_s32(s, 14), ped);
}

static inline uint16x8_t cls8(uint16x8_t o, uint16x8_t inv, int32x4_t ped)
{
    int32x4_t lo = cls4(vget_low_u16(o), vget_low_u16(inv), ped);
    int32x4_t hi = cls4(vget_high_u16(o), vget_high_u16(inv), ped);
    return vcombine_u16(vqmovun_s32(lo), vqmovun_s32(hi));
}
#endif

void prr_pre_rows(const struct prr_pre *p, const uint16_t *src, uint16_t *dst, float black, int row_begin, int row_end)
{
#if defined(__aarch64__)
    struct lin l = lin_for(p, black);
    uint16x4_t g = vdup_n_u16((uint16_t)l.gq);
    uint32x4_t off = vdupq_n_u32(l.off);
    int32x4_t ped = vdupq_n_s32(PRR_PEDESTAL);
    int par = (1 - p->g.x0) & 1;
    for (int r = row_begin; r < row_end; r++) {
        const uint16_t *s = src + (size_t)(p->g.y0 + r) * p->g.src_stride_px + p->g.x0;
        uint16_t *d = dst + (size_t)r * p->g.dst_stride_px;
        const uint16_t *inv = class_row(p, r);
        if (!inv) {
            for (int x = 0; x < p->g.width; x += 8)
                vst1q_u16(d + x, lin8(vld1q_u16(s + x), g, off));
            continue;
        }
        for (int x = 0; x < p->g.width; x += 16) {
            uint16x8x2_t v = vld2q_u16(s + x);
            v.val[0] = lin8(v.val[0], g, off);
            v.val[1] = lin8(v.val[1], g, off);
            v.val[par] = cls8(v.val[par], vld1q_u16(inv + x / 2), ped);
            vst2q_u16(d + x, v);
        }
    }
#else
    prr_pre_rows_scalar(p, src, dst, black, row_begin, row_end);
#endif
}
