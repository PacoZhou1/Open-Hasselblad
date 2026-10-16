/* Viewfinder from the RAW port (MODE21, 16-bit samples, RGGB from the window origin).
 *
 * The ISP colour port carries bands where the sensor's PD blue sites go uncorrected
 * (pv_bands.h), and the corrections leave seams that show as the scene moves. The RAW
 * frames have no such stage between the sensor and here.
 *
 * Each output pixel is three 2x2 quads side by side on window rows 6j+2 and 6j+3, which
 * never hold the PD class rows (y % 6 == 1). The camera's callback sums them (pv_raw_take: a
 * third of the frame read, a twelfth written); the rest runs on the preview thread: black
 * from the left optical-black columns, white balance from the frame before, the colour
 * matrix to linear sRGB, then the sRGB curve.
 *
 * White balance follows the scene: every frame measures grey world over the lit,
 * unclipped pixels that are already near neutral under the current gains, and the gains
 * move a part of the way there. */
#ifndef PV_RAW_H
#define PV_RAW_H
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif

#define PVR_W 648
#define PVR_H 485
#define PVR_STRIDE_PX 3968          /* source row, in samples */
#define PVR_X0 16                   /* window origin in the source */
#define PVR_Y0 32
#define PVR_ROW 2                   /* sampled window rows: 6j+2, 6j+3 */
#define PVR_OB_X0 2                 /* left optical-black columns [2, 14) */
#define PVR_OB_X1 14
#define PVR_OB_Y0 40                /* optical-black rows from here */
#define PVR_ROWS_BYTES ((size_t)PVR_H * 2 * PVR_STRIDE_PX * 2)
#define PVR_LUT 4096
/* The camera exposes its RAW about a stop under what its own viewfinder shows; a fixed gain,
 * not an exposure of the preview's own, so the picture still follows ISO and shutter. Past
 * PVR_KNEE the curve rolls off towards white instead of clipping. */
#define PVR_GAIN 2.0
#define PVR_KNEE 0.6

struct pv_raw {
    float wb[2];                    /* red, blue gains (green 1) */
    float m[9];                     /* white-balanced camera RGB -> linear sRGB */
    float white;                    /* source units */
    float black;                    /* last frame's */
    uint8_t lut[PVR_LUT + 1];       /* linear [0, 1] in PVR_LUT steps -> sRGB */
    unsigned frames;
};

/* `cam_to_xyz`: white-balanced camera RGB -> XYZ (D65), row-major. */
static inline void pv_raw_init(struct pv_raw *s, const float cam_to_xyz[9], float wb_red, float wb_blue, float white)
{
    static const float xyz_to_srgb[9] = { 3.2404542f, -1.5371385f, -0.4985314f, -0.9692660f, 1.8760108f,
                                          0.0415560f, 0.0556434f,  -0.2040259f, 1.0572252f };
    for (int r = 0; r < 3; r++)
        for (int c = 0; c < 3; c++) {
            float v = 0;
            for (int k = 0; k < 3; k++) v += xyz_to_srgb[3 * r + k] * cam_to_xyz[3 * k + c];
            s->m[3 * r + c] = v;
        }
    s->wb[0] = wb_red;
    s->wb[1] = wb_blue;
    s->white = white;
    s->black = 0;
    for (int i = 0; i <= PVR_LUT; i++) {
        double x = (double)i / PVR_LUT * PVR_GAIN;
        if (x > PVR_KNEE) x = PVR_KNEE + (1 - PVR_KNEE) * (1 - exp(-(x - PVR_KNEE) / (1 - PVR_KNEE)));
        double y = x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055;
        s->lut[i] = (uint8_t)(y * 255 + 0.5);
    }
    s->frames = 0;
}

/* The sampled row pairs of the mapped frame `src` as they are: what the float version renders. */
static inline void pv_raw_take_rows(uint16_t *rows, const uint16_t *src)
{
    for (int j = 0; j < PVR_H; j++)
        memcpy(rows + (size_t)j * 2 * PVR_STRIDE_PX, src + (size_t)(PVR_Y0 + 6 * j + PVR_ROW) * PVR_STRIDE_PX,
               2 * PVR_STRIDE_PX * sizeof *rows);
}

/* What the camera's callback keeps of a frame (pv_raw_take): per output pixel the sums of its
 * three quads' samples, red and blue over 4 and green over 8, which with the sensor's 12-bit
 * samples shifted up by 4 still fit 16 bits and lose nothing; and the optical black. A quarter of
 * the bytes the row pairs were, written there and read back here: the copy of the rows at every
 * viewfinder frame was memory traffic enough to drop ProRes RAW frames. */
struct pvr_frame {
    uint32_t ob_sum, ob_n;
    uint16_t px[PVR_W * PVR_H * 3];      /* R3/4, G6/8, B3/4 per pixel */
};

static inline uint8_t pvr_out(const struct pv_raw *s, float v)
{
    int i = (int)(v * PVR_LUT + 0.5f);
    return s->lut[i < 0 ? 0 : i > PVR_LUT ? PVR_LUT : i];
}

/* Fixed point, per frame: sums of the three quads in units of six samples (red and blue doubled),
 * so the sensor range is S = 6 (white - black), at most 6 * 65535; white balance in Q8 and the
 * colour matrix pre-scaled to LUT steps over S in Q14, which keeps every product and sum within
 * int32. Grey world samples every fourth column of every other row. */
struct pvr_k {
    int32_t b6, S, wr, wb, mq[9];
    int32_t g_lo, g_hi, rb_hi;
    const uint8_t *lut;
    int64_t sr, sg, sb;
    unsigned n;
};

/* Lit, unclipped, and within a factor of two of neutral under the current gains. */
static inline void pvr_grey(struct pvr_k *k, int32_t R, int32_t G, int32_t B)
{
    if (G <= k->g_lo || G >= k->g_hi || R >= k->rb_hi || B >= k->rb_hi) return;
    int64_t cr = (int64_t)R * k->wr, cb = (int64_t)B * k->wb, g1 = (int64_t)G * 128, g4 = (int64_t)G * 512;
    if (cr > g1 && cr < g4 && cb > g1 && cb < g4) { k->sr += R; k->sg += G; k->sb += B; k->n++; }
}

static inline void pvr_pixel(struct pvr_k *k, int32_t R, int32_t G, int32_t B, int sample, uint8_t *o)
{
    if (sample) pvr_grey(k, R, G, B);
    /* Balanced and clipped to the sensor's range first: a clipped highlight stays white. */
    int32_t br = (R * k->wr) >> 8, bg = G, bb = (B * k->wb) >> 8;
    br = br < 0 ? 0 : br > k->S ? k->S : br;
    bg = bg < 0 ? 0 : bg > k->S ? k->S : bg;
    bb = bb < 0 ? 0 : bb > k->S ? k->S : bb;
    for (int c = 0; c < 3; c++) {
        int32_t v = (k->mq[3 * c] * br + k->mq[3 * c + 1] * bg + k->mq[3 * c + 2] * bb + 8192) >> 14;
        o[c] = k->lut[v < 0 ? 0 : v > PVR_LUT ? PVR_LUT : v];
    }
}

static inline void pvr_take_row_scalar(uint16_t *d, const uint16_t *r0, const uint16_t *r1)
{
    for (int i = 0; i < PVR_W; i++, r0 += 6, r1 += 6, d += 3) {
        d[0] = (uint16_t)(((uint32_t)r0[0] + r0[2] + r0[4]) >> 2);
        d[1] = (uint16_t)(((uint32_t)r0[1] + r0[3] + r0[5] + r1[0] + r1[2] + r1[4]) >> 3);
        d[2] = (uint16_t)(((uint32_t)r1[1] + r1[3] + r1[5]) >> 2);
    }
}

static inline void pvr_row_scalar(struct pvr_k *k, const uint16_t *d, uint8_t *o, int sample_row)
{
    for (int i = 0; i < PVR_W; i++, d += 3, o += 3)
        pvr_pixel(k, 8 * (int32_t)d[0] - k->b6, 8 * (int32_t)d[1] - k->b6, 8 * (int32_t)d[2] - k->b6,
                  sample_row && !(i & 3), o);
}

#if defined(__aarch64__)
/* Four output pixels at a time. vld3q splits 24 samples (R G R G R G per pixel) by threes: in
 * lane 2p it gives a pixel's first, second and third samples, in lane 2p+1 its fourth to sixth;
 * the even and odd lanes separated, a row's two colours are three adds each. */
static inline void pvr_sums4(const uint16_t *r, uint32x4_t *first, uint32x4_t *second)
{
    uint16x8x3_t v = vld3q_u16(r);
    uint16x8_t e01 = vuzp1q_u16(v.val[0], v.val[1]), o01 = vuzp2q_u16(v.val[0], v.val[1]);
    uint16x8_t e22 = vuzp1q_u16(v.val[2], v.val[2]), o22 = vuzp2q_u16(v.val[2], v.val[2]);
    /* first colour: samples 0, 2, 4 = a[2p] + c[2p] + b[2p+1]; second: 1, 3, 5 = b[2p] + a[2p+1] + c[2p+1] */
    *first = vaddw_u16(vaddl_u16(vget_low_u16(e01), vget_low_u16(e22)), vget_high_u16(o01));
    *second = vaddw_u16(vaddl_u16(vget_high_u16(e01), vget_low_u16(o01)), vget_low_u16(o22));
}

static inline void pvr_take_row_neon(uint16_t *d, const uint16_t *r0, const uint16_t *r1)
{
    for (int i = 0; i < PVR_W; i += 4, r0 += 24, r1 += 24, d += 12) {
        uint32x4_t ra, ga, gb, ba;
        pvr_sums4(r0, &ra, &ga);
        pvr_sums4(r1, &gb, &ba);
        uint16x4x3_t out = { { vshrn_n_u32(ra, 2), vshrn_n_u32(vaddq_u32(ga, gb), 3), vshrn_n_u32(ba, 2) } };
        vst3_u16(d, out);
    }
}

static inline void pvr_row_neon(struct pvr_k *k, const uint16_t *d, uint8_t *o, int sample_row)
{
    const int32x4_t b6 = vdupq_n_s32(k->b6), zero = vdupq_n_s32(0), S = vdupq_n_s32(k->S);
    const int32x4_t lut_max = vdupq_n_s32(PVR_LUT), half = vdupq_n_s32(8192);
    for (int i = 0; i < PVR_W; i += 4, d += 12, o += 12) {
        uint16x4x3_t v = vld3_u16(d);
        int32x4_t R = vsubq_s32(vreinterpretq_s32_u32(vshll_n_u16(v.val[0], 3)), b6);
        int32x4_t G = vsubq_s32(vreinterpretq_s32_u32(vshll_n_u16(v.val[1], 3)), b6);
        int32x4_t B = vsubq_s32(vreinterpretq_s32_u32(vshll_n_u16(v.val[2], 3)), b6);
        /* Lane 0 is column i, a multiple of four: only it feeds the grey world. */
        if (sample_row) pvr_grey(k, vgetq_lane_s32(R, 0), vgetq_lane_s32(G, 0), vgetq_lane_s32(B, 0));
        int32x4_t br = vminq_s32(vmaxq_s32(vshrq_n_s32(vmulq_n_s32(R, k->wr), 8), zero), S);
        int32x4_t bg = vminq_s32(vmaxq_s32(G, zero), S);
        int32x4_t bb = vminq_s32(vmaxq_s32(vshrq_n_s32(vmulq_n_s32(B, k->wb), 8), zero), S);
        int32_t idx[3][4];
        for (int c = 0; c < 3; c++) {
            int32x4_t w = vmlaq_n_s32(vmlaq_n_s32(vmlaq_n_s32(half, br, k->mq[3 * c]), bg, k->mq[3 * c + 1]), bb, k->mq[3 * c + 2]);
            w = vminq_s32(vmaxq_s32(vshrq_n_s32(w, 14), zero), lut_max);
            vst1q_s32(idx[c], w);
        }
        for (int p = 0; p < 4; p++) {
            o[3 * p] = k->lut[idx[0][p]];
            o[3 * p + 1] = k->lut[idx[1][p]];
            o[3 * p + 2] = k->lut[idx[2][p]];
        }
    }
}
#endif

/* The camera's callback: frame `src` (mapped) into `f`. */
static inline void pvr_take(struct pvr_frame *f, const uint16_t *src, int use_neon)
{
    uint32_t ob = 0, obn = 0;
    for (int j = 0; j < PVR_H; j++) {
        const uint16_t *r0 = src + (size_t)(PVR_Y0 + 6 * j + PVR_ROW) * PVR_STRIDE_PX, *r1 = r0 + PVR_STRIDE_PX;
        if (PVR_Y0 + 6 * j + PVR_ROW >= PVR_OB_Y0) {
            for (int x = PVR_OB_X0; x < PVR_OB_X1; x++) ob += (uint32_t)r0[x] + r1[x];
            obn += 2 * (PVR_OB_X1 - PVR_OB_X0);
        }
        uint16_t *d = f->px + (size_t)j * PVR_W * 3;
#if defined(__aarch64__)
        if (use_neon) { pvr_take_row_neon(d, r0 + PVR_X0, r1 + PVR_X0); continue; }
#endif
        (void)use_neon;
        pvr_take_row_scalar(d, r0 + PVR_X0, r1 + PVR_X0);
    }
    f->ob_sum = ob;
    f->ob_n = obn;
}
static inline void pv_raw_take(struct pvr_frame *f, const uint16_t *src) { pvr_take(f, src, 1); }

/* A frame in three steps, so that threads can render parts of it: pv_raw_begin (the frame's black
 * and fixed-point constants), pv_raw_part on any number of disjoint row ranges, each with its
 * own copy of the constants, then pv_raw_end with every part's copy (the grey world summed). */
static inline int pv_raw_begin(struct pv_raw *s, const struct pvr_frame *f, struct pvr_k *k)
{
    const int black = f->ob_n ? (int)(f->ob_sum / f->ob_n) : 0;
    s->black = (float)black;
    memset(k, 0, sizeof *k);
    k->b6 = 6 * black;
    k->S = 6 * ((int)s->white - black);
    k->lut = s->lut;
    if (k->S <= 0) return -1;
    k->wr = (int32_t)(s->wb[0] * 256 + 0.5f);
    k->wb = (int32_t)(s->wb[1] * 256 + 0.5f);
    for (int i = 0; i < 9; i++) k->mq[i] = (int32_t)llround((double)s->m[i] * PVR_LUT / (double)k->S * 16384.0);
    k->g_lo = k->S / 50;
    k->g_hi = k->S / 5 * 4;
    k->rb_hi = k->S / 10 * 9;
    return 0;
}

static inline void pv_raw_part(struct pvr_k *k, const struct pvr_frame *f, uint8_t *rgb, int j0, int j1, int use_neon)
{
    for (int j = j0; j < j1; j++) {
        const uint16_t *d = f->px + (size_t)j * PVR_W * 3;
        uint8_t *o = rgb + (size_t)j * PVR_W * 3;
#if defined(__aarch64__)
        if (use_neon) { pvr_row_neon(k, d, o, !(j & 1)); continue; }
#endif
        (void)use_neon;
        pvr_row_scalar(k, d, o, !(j & 1));
    }
}

static inline void pv_raw_end(struct pv_raw *s, const struct pvr_k *parts, int n_parts)
{
    int64_t sr = 0, sg = 0, sb = 0;
    unsigned n = 0;
    for (int i = 0; i < n_parts; i++) { sr += parts[i].sr; sg += parts[i].sg; sb += parts[i].sb; n += parts[i].n; }
    if (n > (unsigned)(PVR_W * PVR_H / 800) && sr > 0 && sb > 0) {
        float a = s->frames < 8 ? 0.5f : 0.15f;
        float nr = fminf(fmaxf((float)sg / (float)sr, 0.8f), 5.0f), nb = fminf(fmaxf((float)sg / (float)sb, 0.8f), 5.0f);
        s->wb[0] += a * (nr - s->wb[0]);
        s->wb[1] += a * (nb - s->wb[1]);
    }
    s->frames++;
}

static inline void pvr_render(struct pv_raw *s, const struct pvr_frame *f, uint8_t *rgb, int use_neon)
{
    struct pvr_k k;
    if (pv_raw_begin(s, f, &k)) return;
    pv_raw_part(&k, f, rgb, 0, PVR_H, use_neon);
    pv_raw_end(s, &k, 1);
}

/* `f` from pv_raw_take -> `rgb`, PVR_W x PVR_H, 8-bit. In float this took 59 ms a frame on the
 * camera, which held the viewfinder near 12 fps. */
static inline void pv_raw_render(struct pv_raw *s, const struct pvr_frame *f, uint8_t *rgb) { pvr_render(s, f, rgb, 1); }
static inline void pv_raw_render_scalar(struct pv_raw *s, const struct pvr_frame *f, uint8_t *rgb) { pvr_render(s, f, rgb, 0); }

/* The first version, in float: the host test checks the fixed point against it. */
static inline void pv_raw_render_float(struct pv_raw *s, const uint16_t *rows, uint8_t *rgb)
{
    double ob = 0;
    unsigned obn = 0;
    for (int j = 0; j < PVR_H; j++) {
        if (PVR_Y0 + 6 * j + PVR_ROW < PVR_OB_Y0) continue;
        const uint16_t *r = rows + (size_t)j * 2 * PVR_STRIDE_PX;
        for (int y = 0; y < 2; y++)
            for (int x = PVR_OB_X0; x < PVR_OB_X1; x++) ob += r[(size_t)y * PVR_STRIDE_PX + x];
        obn += 2 * (PVR_OB_X1 - PVR_OB_X0);
    }
    float black = obn ? (float)(ob / obn) : 0;
    s->black = black;
    const float k = 1.0f / (s->white - black), wr = s->wb[0], wb = s->wb[1];
    const float *m = s->m;
    double sr = 0, sg = 0, sb = 0;
    unsigned n = 0;
    for (int j = 0; j < PVR_H; j++) {
        const uint16_t *r0 = rows + (size_t)j * 2 * PVR_STRIDE_PX + PVR_X0, *r1 = r0 + PVR_STRIDE_PX;
        uint8_t *o = rgb + (size_t)j * PVR_W * 3;
        for (int i = 0; i < PVR_W; i++, r0 += 6, r1 += 6, o += 3) {
            float R = ((float)r0[0] + r0[2] + r0[4]) * (1 / 3.0f);
            float G = ((float)r0[1] + r0[3] + r0[5] + r1[0] + r1[2] + r1[4]) * (1 / 6.0f);
            float B = ((float)r1[1] + r1[3] + r1[5]) * (1 / 3.0f);
            R = (R - black) * k;
            G = (G - black) * k;
            B = (B - black) * k;
            /* Grey world on what is lit, unclipped and already close to neutral. */
            if (G > 0.02f && G < 0.8f && R < 0.9f && B < 0.9f) {
                float cr = R * wr / G, cb = B * wb / G;
                if (cr > 0.5f && cr < 2.0f && cb > 0.5f && cb < 2.0f) {
                    sr += R;
                    sg += G;
                    sb += B;
                    n++;
                }
            }
            /* Balanced and clipped to the sensor's range first: a clipped highlight stays white. */
            float br = fminf(fmaxf(R * wr, 0), 1), bg = fminf(fmaxf(G, 0), 1), bb = fminf(fmaxf(B * wb, 0), 1);
            o[0] = pvr_out(s, m[0] * br + m[1] * bg + m[2] * bb);
            o[1] = pvr_out(s, m[3] * br + m[4] * bg + m[5] * bb);
            o[2] = pvr_out(s, m[6] * br + m[7] * bg + m[8] * bb);
        }
    }
    if (n > (unsigned)(PVR_W * PVR_H / 100) && sr > 0 && sb > 0) {
        float a = s->frames < 8 ? 0.5f : 0.15f;
        float nr = fminf(fmaxf((float)(sg / sr), 0.8f), 5.0f), nb = fminf(fmaxf((float)(sg / sb), 0.8f), 5.0f);
        s->wb[0] += a * (nr - s->wb[0]);
        s->wb[1] += a * (nb - s->wb[1]);
    }
    s->frames++;
}

#endif
