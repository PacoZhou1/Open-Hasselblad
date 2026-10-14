/* Viewfinder from the ISP colour port (NV12 1300x970, stride 1536) at half size.
 *
 * The group13 graph has no PD-removal stage for MODE21, and the ISP colour output
 * carries horizontal bands where the sensor's PD blue sites go uncorrected: at
 * half size, rows [96k+48, 96k+80], blue about x0.75, green about x1.09 and luma a
 * little high, with the ISP's filters blending the two rows on each side of an edge
 * and leaving a one-row luma spike there. The positions never move; the size of the
 * error depends on brightness and varies across the frame.
 *
 * Per band edge and 50-column block, a line fitted through the rows outside the
 * edge and one through the rows inside it are extrapolated to the edge: their
 * ratio is the band gain (a scene gradient across the edge cancels), and the three
 * rows at the edge are matched to a blend of the two lines. Gains are the median
 * over the block's columns, smoothed over frames; after the first frames each
 * frame measures every third band, in turn.
 *
 * The colour port also has an inactive border: half-size rows 0-5 and columns 0-2
 * are black or half black, and take the nearest active row or column. */
#ifndef PV_BANDS_H
#define PV_BANDS_H
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif

#define PVB_FIRST 48
#define PVB_PITCH 96
#define PVB_H 32
#define PVB_MAX 8
#define PVB_BW 50
#define PVB_MAXBLK 16
#define PVB_FIT 7      /* rows per fitted line */
#define PVB_GAP 2      /* the lines start this many rows from the edge row */
#define PVB_WARM 4     /* frames that measure every band */
#define PVB_ROUND 3    /* afterwards each frame measures every third band */
#define PV_TOP_FILL 6
#define PV_LEFT_FILL 3

struct pv_bands {
    /* band, edge (0: row a, 1: row e), block, RGB */
    float g[PVB_MAX][2][PVB_MAXBLK][3];     /* band gain at the edge */
    float t[PVB_MAX][2][3][PVB_MAXBLK][3];  /* gains of edge rows -1, 0, +1 */
    unsigned frames;
};

static inline uint8_t pvb_clamp8(int v) { return v < 0 ? 0 : v > 255 ? 255 : (uint8_t)v; }

static inline void pv_bands_init(struct pv_bands *s)
{
    static const float g0[3] = { 0.97f, 0.93f, 1.33f };
    /* Share of banded pixel in edge rows -1, 0, +1 of the top and the bottom edge. */
    static const float in[2][3] = { { 0.11f, 0.60f, 1 }, { 0.87f, 0.34f, 0 } };
    for (int k = 0; k < PVB_MAX; k++)
        for (int j = 0; j < 2; j++)
            for (int n = 0; n < PVB_MAXBLK; n++)
                for (int c = 0; c < 3; c++) {
                    s->g[k][j][n][c] = g0[c];
                    for (int d = 0; d < 3; d++) s->t[k][j][d][n][c] = 1 / (in[j][d] / g0[c] + 1 - in[j][d]);
                }
    s->frames = 0;
}

/* Half-size BT.709 conversion: 2x2 luma average, the co-sited chroma pair. */
static inline void pvb_rgb_px(const uint8_t *y0, const uint8_t *y1, const uint8_t *c, uint8_t *o, int x)
{
    int Y = ((y0[2 * x] + y0[2 * x + 1] + y1[2 * x] + y1[2 * x + 1] + 2) >> 2) - 16;
    int U = c[2 * x] - 128, V = c[2 * x + 1] - 128;
    int l = 298 * (Y < 0 ? 0 : Y);
    o[3 * x] = pvb_clamp8((l + 459 * V + 128) >> 8);
    o[3 * x + 1] = pvb_clamp8((l - 55 * U - 136 * V + 128) >> 8);
    o[3 * x + 2] = pvb_clamp8((l + 541 * U + 128) >> 8);
}

#if defined(__aarch64__)
/* clamp8((298 Y + ka A + kb B + 128) >> 8) for eight pixels, as pvb_rgb_px. */
static inline uint8x8_t pvb_mix8(int16x8_t Y, int16x8_t A, int16_t ka, int16x8_t B, int16_t kb)
{
    int32x4_t r = vdupq_n_s32(128);
    int32x4_t lo = vmlal_n_s16(vmlal_n_s16(vmlal_n_s16(r, vget_low_s16(Y), 298), vget_low_s16(A), ka), vget_low_s16(B), kb);
    int32x4_t hi = vmlal_n_s16(vmlal_n_s16(vmlal_n_s16(r, vget_high_s16(Y), 298), vget_high_s16(A), ka), vget_high_s16(B), kb);
    return vqmovn_u16(vcombine_u16(vqshrun_n_s32(lo, 8), vqshrun_n_s32(hi, 8)));
}
#endif

/* Output rows y0..y1-1 only, each at its own place in o. */
static inline void pv_nv12_to_rgb_rows(const uint8_t *nv12, int stride, int src_h, uint8_t *o, int ow, int ybeg, int yend)
{
    const uint8_t *uv = nv12 + (size_t)stride * src_h;
    o += (size_t)ybeg * ow * 3;
    for (int y = ybeg; y < yend; y++, o += (size_t)ow * 3) {
        const uint8_t *y0 = nv12 + (size_t)(2 * y) * stride, *y1 = y0 + stride, *c = uv + (size_t)y * stride;
        int x = 0;
#if defined(__aarch64__)
        for (; x + 8 <= ow; x += 8) {
            __builtin_prefetch(y0 + 2 * x + 512);
            __builtin_prefetch(y1 + 2 * x + 512);
            __builtin_prefetch(c + 2 * x + 512);
            uint16x8_t s = vaddq_u16(vpaddlq_u8(vld1q_u8(y0 + 2 * x)), vpaddlq_u8(vld1q_u8(y1 + 2 * x)));
            int16x8_t Y = vreinterpretq_s16_u16(vqsubq_u16(vrshrq_n_u16(s, 2), vdupq_n_u16(16)));
            uint8x8x2_t q = vld2_u8(c + 2 * x);
            int16x8_t U = vreinterpretq_s16_u16(vsubl_u8(q.val[0], vdup_n_u8(128)));
            int16x8_t V = vreinterpretq_s16_u16(vsubl_u8(q.val[1], vdup_n_u8(128)));
            uint8x8x3_t px = { { pvb_mix8(Y, V, 459, U, 0), pvb_mix8(Y, U, -55, V, -136), pvb_mix8(Y, U, 541, V, 0) } };
            vst3_u8(o + 3 * x, px);
        }
#endif
        for (; x < ow; x++) pvb_rgb_px(y0, y1, c, o, x);
    }
}

static inline void pv_nv12_to_rgb(const uint8_t *nv12, int stride, int src_h, uint8_t *o, int ow, int oh)
{
    pv_nv12_to_rgb_rows(nv12, stride, src_h, o, ow, 0, oh);
}

static inline void pv_nv12_to_rgb_scalar(const uint8_t *nv12, int stride, int src_h, uint8_t *o, int ow, int oh)
{
    const uint8_t *uv = nv12 + (size_t)stride * src_h;
    for (int y = 0; y < oh; y++, o += (size_t)ow * 3) {
        const uint8_t *y0 = nv12 + (size_t)(2 * y) * stride, *y1 = y0 + stride, *c = uv + (size_t)y * stride;
        for (int x = 0; x < ow; x++) pvb_rgb_px(y0, y1, c, o, x);
    }
}

/* v[n / 2] of the sorted values; v is reordered. */
static inline float pvb_median(float *v, int n)
{
    int lo = 0, hi = n - 1, k = n / 2;
    while (lo < hi) {
        float p = v[(lo + hi) / 2];
        int i = lo, j = hi;
        while (i <= j) {
            while (v[i] < p) i++;
            while (v[j] > p) j--;
            if (i <= j) { float t = v[i]; v[i++] = v[j]; v[j--] = t; }
        }
        if (k <= j) hi = j;
        else if (k >= i) lo = i;
        else break;
    }
    return v[k];
}

static inline int pvb_bands(int oh)
{
    int n = 0;
    while (n < PVB_MAX && PVB_FIRST + n * PVB_PITCH + PVB_H + PVB_GAP + PVB_FIT <= oh) n++;
    return n;
}

/* Least-squares line through rows u0..u0+PVB_FIT-1 (offsets from the edge row), evaluated at offset d. */
static inline void pvb_line(float *w, int u0, int d)
{
    const float um = u0 + (PVB_FIT - 1) * 0.5f, ss = (float)(PVB_FIT * (PVB_FIT * PVB_FIT - 1)) / 12;
    for (int i = 0; i < PVB_FIT; i++) w[i] = 1.0f / PVB_FIT + (u0 + i - um) * (d - um) / ss;
}

/* Bands k0, k0 + kstep, ... below nb; every xstep-th column of each block. */
static inline void pvb_measure_x(struct pv_bands *s, const uint8_t *rgb, int w, int nb, int nblk, int k0, int kstep,
                                 float alpha, int xstep)
{
    /* wo/wi[d+1]: line weights for the outside/inside rows at offset d; top edge, bottom is mirrored. */
    float wo[3][PVB_FIT], wi[3][PVB_FIT], r[4][3][PVB_BW];
    for (int d = -1; d <= 1; d++) {
        pvb_line(wo[d + 1], -PVB_GAP - PVB_FIT + 1, d);
        pvb_line(wi[d + 1], PVB_GAP, d);
    }
    for (int k = k0; k < nb; k += kstep) {
        int a = PVB_FIRST + k * PVB_PITCH;
        for (int j = 0; j < 2; j++) {
            /* sgn flips the row offsets for the bottom edge, whose inside is above it. */
            int edge = j ? a + PVB_H : a, sgn = j ? -1 : 1;
            for (int n = 0; n < nblk; n++) {
                int cnt = 0;
                for (int x = n * PVB_BW; x < (n + 1) * PVB_BW; x += xstep) {
                    float G[3], T[3][3];
                    int ok = 1;
                    for (int c = 0; c < 3 && ok; c++) {
                        float O[3] = { 0, 0, 0 }, I[3] = { 0, 0, 0 };
                        for (int i = 0; i < PVB_FIT; i++) {
                            int yo = edge + sgn * (-PVB_GAP - PVB_FIT + 1 + i), yi = edge + sgn * (PVB_GAP + i);
                            float po = rgb[((size_t)yo * w + x) * 3 + c], pi = rgb[((size_t)yi * w + x) * 3 + c];
                            for (int d = 0; d < 3; d++) { O[d] += wo[d][i] * po; I[d] += wi[d][i] * pi; }
                        }
                        if (O[1] < 6 || I[1] < 6 || O[1] > 250 || I[1] > 250) { ok = 0; break; }
                        G[c] = O[1] / I[1];
                        for (int d = 0; d < 3; d++) {
                            /* Each line weighs by its nearness: the other line's distance from this row. */
                            float din = PVB_GAP - (d - 1), dout = PVB_GAP + (d - 1);
                            float target = (din * O[d] + dout * G[c] * I[d]) / (din + dout);
                            float p = rgb[((size_t)(edge + sgn * (d - 1)) * w + x) * 3 + c];
                            if (p < 6 || p > 250) { ok = 0; break; }
                            T[d][c] = target / p;
                        }
                    }
                    if (!ok) continue;
                    for (int c = 0; c < 3; c++) {
                        r[0][c][cnt] = G[c];
                        for (int d = 0; d < 3; d++) r[1 + d][c][cnt] = T[d][c];
                    }
                    cnt++;
                }
                if (cnt < 20 / xstep) continue;
                for (int c = 0; c < 3; c++)
                    for (int q = 0; q < 4; q++) {
                        /* Bottom-edge rows are stored top to bottom: e-1, e, e+1. */
                        float m = pvb_median(r[q][c], cnt);
                        float *g = q ? &s->t[k][j][j ? 3 - q : q - 1][n][c] : &s->g[k][j][n][c];
                        *g += alpha * (m - *g);
                        if (*g < 0.5f) *g = 0.5f;
                        if (*g > 2.0f) *g = 2.0f;
                    }
            }
        }
    }
}

static inline void pvb_measure(struct pv_bands *s, const uint8_t *rgb, int w, int nb, int nblk, int k0, int kstep,
                               float alpha)
{
    pvb_measure_x(s, rgb, w, nb, nblk, k0, kstep, alpha, 1);
}

static inline void pvb_measure_frame(struct pv_bands *s, const uint8_t *rgb, int w, int nb, int nblk)
{
    if (s->frames < PVB_WARM) pvb_measure(s, rgb, w, nb, nblk, 0, 1, 0.6f);
    else pvb_measure(s, rgb, w, nb, nblk, (int)(s->frames % PVB_ROUND), PVB_ROUND, 0.5f);
}

/* Block gains linearly interpolated between block centres; out is interleaved like the RGB row. */
static inline void pvb_row_gain(float *out, const float (*blk)[3], int w, int nblk)
{
    static int tw, tn, n0s[1024], n1s[1024];
    static float fs[1024];
    if (tw != w || tn != nblk) {
        for (int x = 0; x < w; x++) {
            float xs = (x + 0.5f) / PVB_BW - 0.5f, f = 0;
            int n0 = 0, n1 = 0;
            if (xs > 0) {
                n0 = (int)xs; f = xs - n0;
                if (n0 >= nblk - 1) { n0 = nblk - 1; f = 0; }
                n1 = n0 + (f > 0);
            }
            n0s[x] = n0; n1s[x] = n1; fs[x] = f;
        }
        tw = w; tn = nblk;
    }
    for (int x = 0; x < w; x++) {
        const float *b0 = blk[n0s[x]], *b1 = blk[n1s[x]], f = fs[x];
        for (int c = 0; c < 3; c++) out[3 * x + c] = b0[c] * (1 - f) + b1[c] * f;
    }
}

/* Near the clip level the ISP clipped the band rows like their neighbours: a white wall comes out
 * with no band at all, about 252-255 in every channel. There the gain fades to 1 (smoothstep). */
#ifndef PVB_KNEE0
#define PVB_KNEE0 236.0f
#define PVB_KNEE1 252.0f
#endif
static inline float pvb_gain_hl(float p, float g)
{
    if (p <= PVB_KNEE0) return g;
    float u = p >= PVB_KNEE1 ? 1 : (p - PVB_KNEE0) / (PVB_KNEE1 - PVB_KNEE0);
    return g + (1 - g) * u * u * (3 - 2 * u);
}

/* Gains are clamped to [0.5, 2], so the product is never negative. */
static inline uint8_t pvb_scale(uint8_t p, float g)
{
    float v = p * pvb_gain_hl(p, g) + 0.5f;
    return v >= 255.0f ? 255 : (uint8_t)v;
}

#if defined(__aarch64__)
/* pvb_scale on four lanes: p * gain + 0.5, truncated, saturated to 255 when narrowed. */
static inline uint32x4_t pvb_scale4(uint16x4_t p, float32x4_t g)
{
    float32x4_t pf = vcvtq_f32_u32(vmovl_u16(p));
    float32x4_t u = vmulq_n_f32(vsubq_f32(pf, vdupq_n_f32(PVB_KNEE0)), 1 / (PVB_KNEE1 - PVB_KNEE0));
    u = vminq_f32(vmaxq_f32(u, vdupq_n_f32(0)), vdupq_n_f32(1));
    float32x4_t w = vmulq_f32(vmulq_f32(u, u), vfmsq_n_f32(vdupq_n_f32(3), u, 2));
    float32x4_t ge = vfmaq_f32(g, vsubq_f32(vdupq_n_f32(1), g), w);
    return vcvtq_u32_f32(vfmaq_f32(vdupq_n_f32(0.5f), pf, ge));
}

static inline uint8x16_t pvb_pack16(uint32x4_t a, uint32x4_t b, uint32x4_t c, uint32x4_t d)
{
    return vcombine_u8(vqmovn_u16(vcombine_u16(vqmovn_u32(a), vqmovn_u32(b))),
                       vqmovn_u16(vcombine_u16(vqmovn_u32(c), vqmovn_u32(d))));
}
#endif

static inline void pvb_scale_row(uint8_t *restrict p, const float *restrict g, int n)
{
    int i = 0;
#if defined(__aarch64__)
    for (; i + 16 <= n; i += 16) {
        uint8x16_t v = vld1q_u8(p + i);
        uint16x8_t lo = vmovl_u8(vget_low_u8(v)), hi = vmovl_u8(vget_high_u8(v));
        vst1q_u8(p + i, pvb_pack16(pvb_scale4(vget_low_u16(lo), vld1q_f32(g + i)), pvb_scale4(vget_high_u16(lo), vld1q_f32(g + i + 4)),
                                   pvb_scale4(vget_low_u16(hi), vld1q_f32(g + i + 8)), pvb_scale4(vget_high_u16(hi), vld1q_f32(g + i + 12))));
    }
#endif
    for (; i < n; i++) p[i] = pvb_scale(p[i], g[i]);
}

/* Row gains gt + dg * t, as interpolated between the band's two edges. */
static inline void pvb_scale_row_lerp(uint8_t *restrict p, const float *restrict gt, const float *restrict dg, float t, int n)
{
    int i = 0;
#if defined(__aarch64__)
    for (; i + 16 <= n; i += 16) {
        float32x4_t g[4];
        for (int q = 0; q < 4; q++) g[q] = vfmaq_n_f32(vld1q_f32(gt + i + 4 * q), vld1q_f32(dg + i + 4 * q), t);
        uint8x16_t v = vld1q_u8(p + i);
        uint16x8_t lo = vmovl_u8(vget_low_u8(v)), hi = vmovl_u8(vget_high_u8(v));
        vst1q_u8(p + i, pvb_pack16(pvb_scale4(vget_low_u16(lo), g[0]), pvb_scale4(vget_high_u16(lo), g[1]),
                                   pvb_scale4(vget_low_u16(hi), g[2]), pvb_scale4(vget_high_u16(hi), g[3])));
    }
#endif
    for (; i < n; i++) p[i] = pvb_scale(p[i], gt[i] + dg[i] * t);
}

static inline void pvb_apply(const struct pv_bands *s, uint8_t *rgb, int w, int nb, int nblk)
{
    static float gt[1024 * 3], dg[1024 * 3], gr[1024 * 3];
    const int n = w * 3;
    for (int k = 0; k < nb; k++) {
        int a = PVB_FIRST + k * PVB_PITCH, e = a + PVB_H;
        for (int j = 0; j < 2; j++)
            for (int d = 0; d < 3; d++) {
                pvb_row_gain(gr, (const float (*)[3])s->t[k][j][d], w, nblk);
                pvb_scale_row(rgb + (size_t)((j ? e : a) + d - 1) * n, gr, n);
            }
        pvb_row_gain(gt, (const float (*)[3])s->g[k][0], w, nblk);
        pvb_row_gain(dg, (const float (*)[3])s->g[k][1], w, nblk);
        for (int i = 0; i < n; i++) dg[i] -= gt[i];
        for (int y = a + 2; y <= e - 2; y++)
            pvb_scale_row_lerp(rgb + (size_t)y * n, gt, dg, (float)(y - a) / PVB_H, n);
    }
}

static inline void pvb_fill_border(uint8_t *rgb, int w, int h)
{
    if (h <= PV_TOP_FILL || w <= PV_LEFT_FILL) return;
    for (int y = 0; y < h; y++) {
        uint8_t *p = rgb + (size_t)y * w * 3;
        for (int x = 0; x < PV_LEFT_FILL; x++)
            for (int c = 0; c < 3; c++) p[x * 3 + c] = p[PV_LEFT_FILL * 3 + c];
    }
    for (int y = 0; y < PV_TOP_FILL; y++)
        for (size_t i = 0; i < (size_t)w * 3; i++) rgb[(size_t)y * w * 3 + i] = rgb[(size_t)PV_TOP_FILL * w * 3 + i];
}

/* The same correction on the full-size NV12 frame. A half-size pixel is one 2x2 luma block with its
 * chroma pair, so one gain triple applies to the whole block. The viewfinder's BT.709 conversion is
 * linear before clamping: the gained luma is an affine function of the old one, and the chroma comes
 * from the gained mean of the block. Reentrant: no static state, s is only read. */
static inline uint8_t pvb_round8(float v) { return v <= 0 ? 0 : v >= 255 ? 255 : (uint8_t)(v + 0.5f); }

static inline void pvb_fix_block(uint8_t *y0, uint8_t *y1, uint8_t *c, const float *gain)
{
    float U = c[0] - 128.0f, V = c[1] - 128.0f;
    float cr = 1.79274f * V, cg = -0.21325f * U - 0.53291f * V, cb = 2.1124f * U;
    float L = 1.16438f * ((y0[0] + y0[1] + y1[0] + y1[1]) * 0.25f - 16);
    /* The highlight knee is taken at the block mean, so the four luma values stay affine. */
    float g[3] = { pvb_gain_hl(L + cr, gain[0]), pvb_gain_hl(L + cg, gain[1]), pvb_gain_hl(L + cb, gain[2]) };
    float wr = 0.18259f * g[0], wg = 0.61423f * g[1], wb = 0.06201f * g[2];
    float kY = 1.16438f * (wr + wg + wb), kC = 16 + wr * cr + wg * cg + wb * cb - 16 * kY;
    float R = g[0] * (L + cr), G = g[1] * (L + cg), B = g[2] * (L + cb);
    y0[0] = pvb_round8(kY * y0[0] + kC);
    y0[1] = pvb_round8(kY * y0[1] + kC);
    y1[0] = pvb_round8(kY * y1[0] + kC);
    y1[1] = pvb_round8(kY * y1[1] + kC);
    c[0] = pvb_round8(128 - 0.10064f * R - 0.33857f * G + 0.43922f * B);
    c[1] = pvb_round8(128 + 0.43922f * R - 0.39894f * G - 0.04027f * B);
}

struct pvb_cols { int n0[1024], n1[1024]; float f[1024]; };

static inline void pvb_cols_init(struct pvb_cols *t, int w, int nblk)
{
    for (int x = 0; x < w; x++) {
        float xs = (x + 0.5f) / PVB_BW - 0.5f, f = 0;
        int n0 = 0, n1 = 0;
        if (xs > 0) {
            n0 = (int)xs; f = xs - n0;
            if (n0 >= nblk - 1) { n0 = nblk - 1; f = 0; }
            n1 = n0 + (f > 0);
        }
        t->n0[x] = n0; t->n1[x] = n1; t->f[x] = f;
    }
}

/* Gains of half-size row y: edge rows from t, interior rows between the two edges' g; 0 outside bands. */
static inline int pvb_gain_at(const struct pv_bands *s, const struct pvb_cols *t, int y, int nb, int w, float *out)
{
    for (int k = 0; k < nb; k++) {
        int a = PVB_FIRST + k * PVB_PITCH, e = a + PVB_H;
        if (y < a - 1 || y > e + 1) continue;
        const float (*b0)[3], (*b1)[3] = NULL;
        float l = 0;
        if (y <= a + 1) b0 = (const float (*)[3])s->t[k][0][y - a + 1];
        else if (y >= e - 1) b0 = (const float (*)[3])s->t[k][1][y - e + 1];
        else { b0 = (const float (*)[3])s->g[k][0]; b1 = (const float (*)[3])s->g[k][1]; l = (float)(y - a) / PVB_H; }
        for (int x = 0; x < w; x++)
            for (int c = 0; c < 3; c++) {
                float v = b0[t->n0[x]][c] * (1 - t->f[x]) + b0[t->n1[x]][c] * t->f[x];
                if (b1) v += l * (b1[t->n0[x]][c] * (1 - t->f[x]) + b1[t->n1[x]][c] * t->f[x] - v);
                out[3 * x + c] = v;
            }
        return 1;
    }
    return 0;
}

#if defined(__aarch64__)
static inline float32x4_t pvb_gain_hl4(float32x4_t p, float32x4_t g)
{
    float32x4_t u = vmulq_n_f32(vsubq_f32(p, vdupq_n_f32(PVB_KNEE0)), 1 / (PVB_KNEE1 - PVB_KNEE0));
    u = vminq_f32(vmaxq_f32(u, vdupq_n_f32(0)), vdupq_n_f32(1));
    float32x4_t w = vmulq_f32(vmulq_f32(u, u), vfmsq_n_f32(vdupq_n_f32(3), u, 2));
    return vfmaq_f32(g, vsubq_f32(vdupq_n_f32(1), g), w);
}

static inline uint16x4_t pvb_round4(float32x4_t v) { return vqmovn_u32(vcvtq_u32_f32(vaddq_f32(v, vdupq_n_f32(0.5f)))); }

/* pvb_fix_block on four adjacent blocks. */
static inline void pvb_fix_block4(uint8_t *y0, uint8_t *y1, uint8_t *c, const float *gain)
{
    uint8x8_t a = vld1_u8(y0), b = vld1_u8(y1);
    uint8x8x2_t uv = vuzp_u8(vld1_u8(c), vld1_u8(c));
    float32x4_t U = vsubq_f32(vcvtq_f32_u32(vmovl_u16(vget_low_u16(vmovl_u8(uv.val[0])))), vdupq_n_f32(128));
    float32x4_t V = vsubq_f32(vcvtq_f32_u32(vmovl_u16(vget_low_u16(vmovl_u8(uv.val[1])))), vdupq_n_f32(128));
    float32x4_t cr = vmulq_n_f32(V, 1.79274f), cg = vmlaq_n_f32(vmulq_n_f32(U, -0.21325f), V, -0.53291f);
    float32x4_t cb = vmulq_n_f32(U, 2.1124f);
    float32x4_t sum = vcvtq_f32_u32(vmovl_u16(vadd_u16(vpaddl_u8(a), vpaddl_u8(b))));
    float32x4_t L = vmulq_n_f32(vsubq_f32(vmulq_n_f32(sum, 0.25f), vdupq_n_f32(16)), 1.16438f);
    float32x4x3_t gn = vld3q_f32(gain);
    float32x4_t pr = vaddq_f32(L, cr), pg = vaddq_f32(L, cg), pb = vaddq_f32(L, cb);
    float32x4_t g0 = pvb_gain_hl4(pr, gn.val[0]), g1 = pvb_gain_hl4(pg, gn.val[1]), g2 = pvb_gain_hl4(pb, gn.val[2]);
    float32x4_t wr = vmulq_n_f32(g0, 0.18259f), wg = vmulq_n_f32(g1, 0.61423f), wb = vmulq_n_f32(g2, 0.06201f);
    float32x4_t kY = vmulq_n_f32(vaddq_f32(vaddq_f32(wr, wg), wb), 1.16438f);
    float32x4_t kC = vaddq_f32(vdupq_n_f32(16), vfmaq_f32(vfmaq_f32(vmulq_f32(wr, cr), wg, cg), wb, cb));
    kC = vfmsq_n_f32(kC, kY, 16);
    float32x4_t R = vmulq_f32(g0, pr), G = vmulq_f32(g1, pg), B = vmulq_f32(g2, pb);
    float32x4_t C0 = vfmaq_n_f32(vfmaq_n_f32(vfmaq_n_f32(vdupq_n_f32(128), R, -0.10064f), G, -0.33857f), B, 0.43922f);
    float32x4_t C1 = vfmaq_n_f32(vfmaq_n_f32(vfmaq_n_f32(vdupq_n_f32(128), R, 0.43922f), G, -0.39894f), B, -0.04027f);
    /* Each block's kY, kC for both of its pixels in a row. */
    float32x4x2_t ky = vzipq_f32(kY, kY), kc = vzipq_f32(kC, kC);
    uint8_t *rows[2] = { y0, y1 };
    uint8x8_t in[2] = { a, b };
    for (int r = 0; r < 2; r++) {
        uint16x8_t w16 = vmovl_u8(in[r]);
        float32x4_t lo = vfmaq_f32(kc.val[0], ky.val[0], vcvtq_f32_u32(vmovl_u16(vget_low_u16(w16))));
        float32x4_t hi = vfmaq_f32(kc.val[1], ky.val[1], vcvtq_f32_u32(vmovl_u16(vget_high_u16(w16))));
        vst1_u8(rows[r], vqmovn_u16(vcombine_u16(pvb_round4(lo), pvb_round4(hi))));
    }
    uint16x4x2_t z = vzip_u16(pvb_round4(C0), pvb_round4(C1));
    vst1_u8(c, vqmovn_u16(vcombine_u16(z.val[0], z.val[1])));
}
#endif

/* restrict and two blocks of four a step: byte stores may alias the gains otherwise, and the
 * in-order cores then wait out each block's chain of float latencies before the next. */
static inline void pvb_fix_row(uint8_t *restrict y0, uint8_t *restrict y1, uint8_t *restrict c,
                               const float *restrict g, int w)
{
    int x = 0;
#if defined(__aarch64__)
    for (; x + 8 <= w; x += 8) {
        pvb_fix_block4(y0 + 2 * x, y1 + 2 * x, c + 2 * x, g + 3 * x);
        pvb_fix_block4(y0 + 2 * x + 8, y1 + 2 * x + 8, c + 2 * x + 8, g + 3 * x + 12);
    }
    for (; x + 4 <= w; x += 4) pvb_fix_block4(y0 + 2 * x, y1 + 2 * x, c + 2 * x, g + 3 * x);
#endif
    for (; x < w; x++) pvb_fix_block(y0 + 2 * x, y1 + 2 * x, c + 2 * x, g + 3 * x);
}

/* Block gains b interpolated across the w half-size columns, interleaved RGB. */
static inline void pvb_interp(const struct pvb_cols *t, const float (*b)[3], int w, float *out)
{
    for (int x = 0; x < w; x++)
        for (int c = 0; c < 3; c++) out[3 * x + c] = b[t->n0[x]][c] * (1 - t->f[x]) + b[t->n1[x]][c] * t->f[x];
}

static inline void pvb_fill_border_nv12(uint8_t *nv12, int stride, int fw, int fh)
{
    uint8_t *uv = nv12 + (size_t)stride * fh;
    int h = fh / 2;
    /* Inactive border: full-size rows below 2 * PV_TOP_FILL and columns below 2 * PV_LEFT_FILL. */
    for (int y = 0; y < fh; y++) memset(nv12 + (size_t)y * stride, nv12[(size_t)y * stride + 2 * PV_LEFT_FILL], 2 * PV_LEFT_FILL);
    for (int y = 0; y < h; y++)
        for (int x = 0; x < PV_LEFT_FILL; x++) {
            uv[(size_t)y * stride + 2 * x] = uv[(size_t)y * stride + 2 * PV_LEFT_FILL];
            uv[(size_t)y * stride + 2 * x + 1] = uv[(size_t)y * stride + 2 * PV_LEFT_FILL + 1];
        }
    for (int y = 0; y < 2 * PV_TOP_FILL; y++) memcpy(nv12 + (size_t)y * stride, nv12 + (size_t)(2 * PV_TOP_FILL) * stride, (size_t)fw);
    for (int y = 0; y < PV_TOP_FILL; y++) memcpy(uv + (size_t)y * stride, uv + (size_t)PV_TOP_FILL * stride, (size_t)fw);
}

/* nv12: fw x fh luma rows of stride bytes, then the chroma rows; fw, fh twice the viewfinder size.
 * Each band's gains are interpolated across the columns once: its six edge rows, and the two
 * lines its interior rows blend between. */
static inline void pv_bands_fix_nv12(const struct pv_bands *s, uint8_t *nv12, int stride, int fw, int fh)
{
    int w = fw / 2, h = fh / 2, nb = pvb_bands(h), nblk = w / PVB_BW;
    if (w > 1024 || nblk < 1 || nblk > PVB_MAXBLK) return;
    struct pvb_cols t;
    float g[1024 * 3], g0[1024 * 3], dg[1024 * 3];
    pvb_cols_init(&t, w, nblk);
    uint8_t *uv = nv12 + (size_t)stride * fh;
#define PVB_ROW(y) nv12 + (size_t)(2 * (y)) * stride, nv12 + (size_t)(2 * (y) + 1) * stride, uv + (size_t)(y) * stride
    for (int k = 0; k < nb; k++) {
        int a = PVB_FIRST + k * PVB_PITCH, e = a + PVB_H;
        for (int j = 0; j < 2; j++)
            for (int d = 0; d < 3; d++) {
                pvb_interp(&t, (const float (*)[3])s->t[k][j][d], w, g);
                pvb_fix_row(PVB_ROW((j ? e : a) + d - 1), g, w);
            }
        pvb_interp(&t, (const float (*)[3])s->g[k][0], w, g0);
        pvb_interp(&t, (const float (*)[3])s->g[k][1], w, dg);
        for (int i = 0; i < 3 * w; i++) dg[i] -= g0[i];
        for (int y = a + 2; y <= e - 2; y++) {
            float l = (float)(y - a) / PVB_H;
            for (int i = 0; i < 3 * w; i++) g[i] = g0[i] + l * dg[i];
            pvb_fix_row(PVB_ROW(y), g, w);
        }
    }
#undef PVB_ROW
    pvb_fill_border_nv12(nv12, stride, fw, fh);
}

/* The per-row, per-block reference for pv_bands_fix_nv12. */
static inline void pv_bands_fix_nv12_scalar(const struct pv_bands *s, uint8_t *nv12, int stride, int fw, int fh)
{
    int w = fw / 2, h = fh / 2, nb = pvb_bands(h), nblk = w / PVB_BW;
    if (w > 1024 || nblk < 1 || nblk > PVB_MAXBLK) return;
    struct pvb_cols t;
    float g[1024 * 3];
    pvb_cols_init(&t, w, nblk);
    uint8_t *uv = nv12 + (size_t)stride * fh;
    for (int y = 0; y < h; y++) {
        if (!pvb_gain_at(s, &t, y, nb, w, g)) continue;
        uint8_t *y0 = nv12 + (size_t)(2 * y) * stride, *y1 = y0 + stride, *c = uv + (size_t)y * stride;
        for (int x = 0; x < w; x++) pvb_fix_block(y0 + 2 * x, y1 + 2 * x, c + 2 * x, g + 3 * x);
    }
    pvb_fill_border_nv12(nv12, stride, fw, fh);
}

/* After pv_bands_fix_nv12, the luma rows at each band edge one by one: the edge's transition spans
 * rows r-2..r+1 at full size, and rises and dips within single rows that one 2x2 gain cannot
 * follow. Each row's level, per block, is pulled to a line through the rows either side. */
#define PVL_BW 100
#define PVL_MAXBLK 16
#define PVL_Q 14
static inline uint32_t pvl_sum(const uint8_t *p, int n)
{
    uint32_t s = 0;
    int x = 0;
#if defined(__aarch64__)
    uint32x4_t acc = vdupq_n_u32(0);
    for (; x + 16 <= n; x += 16) acc = vpadalq_u16(acc, vpaddlq_u8(vld1q_u8(p + x)));
    s = vaddvq_u32(acc);
#endif
    for (; x < n; x++) s += p[x];
    return s;
}

/* p[x] = clamp8((p[x] * g[x] + 2^(Q-1)) >> Q). */
static inline void pvl_scale_row(uint8_t *restrict p, const uint16_t *restrict g, int n)
{
    int x = 0;
#if defined(__aarch64__)
    for (; x + 8 <= n; x += 8) {
        uint16x8_t v = vmovl_u8(vld1_u8(p + x)), q = vld1q_u16(g + x);
        uint32x4_t lo = vmull_u16(vget_low_u16(v), vget_low_u16(q)), hi = vmull_u16(vget_high_u16(v), vget_high_u16(q));
        vst1_u8(p + x, vqmovn_u16(vcombine_u16(vqrshrn_n_u32(lo, PVL_Q), vqrshrn_n_u32(hi, PVL_Q))));
    }
#endif
    for (; x < n; x++) {
        uint32_t v = ((uint32_t)p[x] * g[x] + (1u << (PVL_Q - 1))) >> PVL_Q;
        p[x] = v > 255 ? 255 : (uint8_t)v;
    }
}

static inline void pv_bands_fix_luma_edges(uint8_t *nv12, int stride, int fw, int fh)
{
    int nb = pvb_bands(fh / 2), nblk = fw / PVL_BW;
    if (nblk < 2 || nblk > PVL_MAXBLK || fw > 2048) return;
    static const int fit[8] = { -6, -5, -4, -3, 2, 3, 4, 5 };
    float gain[4][PVL_MAXBLK];
    uint16_t row[2048];
    for (int k = 0; k < nb; k++)
        for (int j = 0; j < 2; j++) {
            int r = 2 * (PVB_FIRST + k * PVB_PITCH + j * PVB_H);
            if (r - 6 < 0 || r + 5 >= fh) continue;
            for (int b = 0; b < nblk; b++) {
                float m[12];
                for (int i = 0; i < 12; i++)
                    m[i] = (float)pvl_sum(nv12 + (size_t)(r - 6 + i) * stride + b * PVL_BW, PVL_BW) / PVL_BW;
                float sx = 0, sy = 0, sxx = 0, sxy = 0;
                for (int i = 0; i < 8; i++) {
                    float x = (float)fit[i], y = m[fit[i] + 6];
                    sx += x; sy += y; sxx += x * x; sxy += x * y;
                }
                float slope = (8 * sxy - sx * sy) / (8 * sxx - sx * sx), icpt = (sy - slope * sx) / 8;
                for (int d = 0; d < 4; d++) {
                    float have = m[d + 4], want = icpt + slope * (float)(d - 2);
                    float g = have > 8 ? want / have : 1;
                    gain[d][b] = g < 0.85f ? 0.85f : g > 1.15f ? 1.15f : g;
                }
            }
            for (int d = 0; d < 4; d++) {
                /* Gains linear between block centres, flat beyond the outer ones. */
                const float one = (float)(1 << PVL_Q);
                int x = 0;
                for (; x < PVL_BW / 2 && x < fw; x++) row[x] = (uint16_t)(gain[d][0] * one + 0.5f);
                for (int b = 0; b + 1 < nblk; b++) {
                    float g0 = gain[d][b] * one, dg = (gain[d][b + 1] - gain[d][b]) * one / PVL_BW;
                    for (int i = 0; i < PVL_BW && x < fw; i++, x++) row[x] = (uint16_t)(g0 + dg * ((float)i + 0.5f) + 0.5f);
                }
                for (; x < fw; x++) row[x] = (uint16_t)(gain[d][nblk - 1] * one + 0.5f);
                pvl_scale_row(nv12 + (size_t)(r - 2 + d) * stride, row, fw);
            }
        }
}

/* Measures the bands of the frame pv_bands_fix_nv12 is about to correct; rgb is a scratch of
 * fw/2 x fh/2 RGB8. The bands move with the scene, so gains from other frames leave them in: half
 * the bands each frame, alternately, keeps each at most one frame old, and only the rows the
 * measurement reads are converted. */
static inline void pv_bands_measure_nv12(struct pv_bands *s, const uint8_t *nv12, int stride, int fw, int fh,
                                         uint8_t *rgb)
{
    int w = fw / 2, h = fh / 2, nb = pvb_bands(h), nblk = w / PVB_BW;
    if (w > 1024 || nblk < 1 || nblk > PVB_MAXBLK) return;
    const int warm = s->frames < PVB_WARM, k0 = warm ? 0 : (int)(s->frames & 1), kstep = warm ? 1 : 2;
    const int reach = PVB_GAP + PVB_FIT - 1;
    for (int k = k0; k < nb; k += kstep) {
        int a = PVB_FIRST + k * PVB_PITCH, e = a + PVB_H;
        pv_nv12_to_rgb_rows(nv12, stride, fh, rgb, w, a - reach, a + reach + 1);
        pv_nv12_to_rgb_rows(nv12, stride, fh, rgb, w, e - reach, e + reach + 1);
    }
    pvb_measure_x(s, rgb, w, nb, nblk, k0, kstep, 0.6f, 2);
    s->frames++;
}

/* rgb: w x h, RGB8. Only meaningful for the 1300x970 colour port at half size. */
static inline void pv_bands_fix(struct pv_bands *s, uint8_t *rgb, int w, int h)
{
    int nb = pvb_bands(h), nblk = w / PVB_BW;
    if (w > 1024 || nblk < 1 || nblk > PVB_MAXBLK) return;
    pvb_measure_frame(s, rgb, w, nb, nblk);
    pvb_apply(s, rgb, w, nb, nblk);
    pvb_fill_border(rgb, w, h);
    s->frames++;
}
#endif
