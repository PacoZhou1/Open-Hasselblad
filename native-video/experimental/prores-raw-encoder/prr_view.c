#include "prr_view.h"
#include <math.h>
#include <string.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif

#define BLACK 256.0f
#define RANGE 65279.0f

/* Offsets of R, G1, G2, B inside a 2x2 quad for RGGB, GRBG, GBRG, BGGR. */
static const int bayer_pos[4][4] = { { 0, 1, 2, 3 }, { 1, 0, 3, 2 }, { 2, 3, 0, 1 }, { 3, 2, 1, 0 } };

static const float xyz_to_srgb[9] = {
    3.2404542f, -1.5371385f, -0.4985314f,
    -0.9692660f, 1.8760108f, 0.0415560f,
    0.0556434f, -0.2040259f, 1.0572252f,
};

void prr_view_setup(struct prr_view *v, const struct prr_dec_meta *meta, int width, int height, int scale, float ev)
{
    memset(v, 0, sizeof *v);
    v->scale = scale < 2 ? 2 : scale & ~1;
    v->bayer = meta->bayer & 3;
    v->out_w = width / v->scale;
    v->out_h = height / v->scale;
    float wb[3] = { meta->wb_red > 0 ? meta->wb_red : 1, 1, meta->wb_blue > 0 ? meta->wb_blue : 1 };
    float k = powf(2.0f, ev) / RANGE;
    int identity = 1;
    for (int i = 0; i < 9; i++)
        if (meta->matrix[i] != 0)
            identity = 0;
    for (int r = 0; r < 3; r++)
        for (int c = 0; c < 3; c++) {
            float s = r == c;
            if (!identity) {
                s = 0;
                for (int j = 0; j < 3; j++)
                    s += xyz_to_srgb[r * 3 + j] * meta->matrix[j * 3 + c];
            }
            v->m[r * 3 + c] = s * wb[c] * k;
        }
    const int *p = bayer_pos[v->bayer];
    float norm = 4.0f / (float)(v->scale * v->scale);
    for (int c = 0; c < 3; c++) {
        const float *m = v->m + c * 3;
        v->k[c][p[0]] = m[0] * norm * 4095.0f;
        v->k[c][p[1]] = m[1] * 0.5f * norm * 4095.0f;
        v->k[c][p[2]] = m[1] * 0.5f * norm * 4095.0f;
        v->k[c][p[3]] = m[2] * norm * 4095.0f;
        v->k0[c] = 0.5f - BLACK * (m[0] + m[1] + m[2]) * 4095.0f;
    }
    for (int i = 0; i < 4096; i++) {
        float x = i / 4095.0f;
        float y = x <= 0.0031308f ? 12.92f * x : 1.055f * powf(x, 1 / 2.4f) - 0.055f;
        v->lut[i] = (uint8_t)lrintf(y * 255.0f);
    }
}

static inline uint8_t enc(const struct prr_view *v, float x)
{
    int i = (int)(x * 4095.0f + 0.5f);
    return v->lut[i < 0 ? 0 : i > 4095 ? 4095 : i];
}

#if defined(__aarch64__)
#define PV4_AHEAD 128   /* samples: 256 bytes, four lines ahead on each row */
/* Scale 4: each output pixel sums four samples per quad position, from Bayer rows 0 and 2 (even)
 * and 1 and 3 (odd); four output pixels per step. Returns the first column it left. */
static int rows4_neon(const struct prr_view *v, const uint16_t *r0, int sp, uint8_t *o)
{
    const uint16_t *r1 = r0 + sp, *r2 = r1 + sp, *r3 = r2 + sp;
    const float32x4_t k0 = vdupq_n_f32(v->k0[0]), k1 = vdupq_n_f32(v->k0[1]), k2 = vdupq_n_f32(v->k0[2]);
    const int32x4_t lo = vdupq_n_s32(0), hi = vdupq_n_s32(4095);
    int ox = 0;
    for (; ox + 4 <= v->out_w; ox += 4, o += 12) {
        const int x = ox * 4;
        /* The A55 is in order: a miss on any of the four rows stalls it, so stay ahead of all of them. */
        if (!(ox & 7)) {
            __builtin_prefetch(r0 + x + PV4_AHEAD);
            __builtin_prefetch(r1 + x + PV4_AHEAD);
            __builtin_prefetch(r2 + x + PV4_AHEAD);
            __builtin_prefetch(r3 + x + PV4_AHEAD);
        }
        uint16x8x2_t a = vld2q_u16(r0 + x), b = vld2q_u16(r1 + x), c = vld2q_u16(r2 + x), d = vld2q_u16(r3 + x);
        float32x4_t q[4] = {
            vcvtq_f32_u32(vpadalq_u16(vpaddlq_u16(a.val[0]), c.val[0])),
            vcvtq_f32_u32(vpadalq_u16(vpaddlq_u16(a.val[1]), c.val[1])),
            vcvtq_f32_u32(vpadalq_u16(vpaddlq_u16(b.val[0]), d.val[0])),
            vcvtq_f32_u32(vpadalq_u16(vpaddlq_u16(b.val[1]), d.val[1])),
        };
        float32x4_t ch[3] = { k0, k1, k2 };
        for (int j = 0; j < 4; j++) {
            ch[0] = vfmaq_n_f32(ch[0], q[j], v->k[0][j]);
            ch[1] = vfmaq_n_f32(ch[1], q[j], v->k[1][j]);
            ch[2] = vfmaq_n_f32(ch[2], q[j], v->k[2][j]);
        }
        int32_t idx[3][4];
        for (int c3 = 0; c3 < 3; c3++)
            vst1q_s32(idx[c3], vminq_s32(vmaxq_s32(vcvtq_s32_f32(ch[c3]), lo), hi));
        for (int i = 0; i < 4; i++) {
            o[i * 3] = v->lut[idx[0][i]];
            o[i * 3 + 1] = v->lut[idx[1][i]];
            o[i * 3 + 2] = v->lut[idx[2][i]];
        }
    }
    return ox;
}
#endif

void prr_view_rows(const struct prr_view *v, const uint16_t *bayer, int stride_bytes, uint8_t *rgb, int row_begin, int row_end)
{
    const int *p = bayer_pos[v->bayer];
    int s = v->scale, q = s / 2, sp = stride_bytes / 2;
    float norm = 1.0f / (float)(q * q);
    for (int oy = row_begin; oy < row_end; oy++) {
        uint8_t *o = rgb + (size_t)oy * v->out_w * 3;
        int ox = 0;
#if defined(__aarch64__)
        if (s == 4) {
            ox = rows4_neon(v, bayer + (size_t)(oy * 4) * sp, sp, o);
            o += ox * 3;
        }
#endif
        for (; ox < v->out_w; ox++) {
            uint32_t acc[4] = { 0, 0, 0, 0 };
            for (int qy = 0; qy < q; qy++) {
                const uint16_t *r0 = bayer + (size_t)(oy * s + qy * 2) * sp + ox * s;
                const uint16_t *r1 = r0 + sp;
                for (int qx = 0; qx < q; qx++) {
                    acc[0] += r0[2 * qx];
                    acc[1] += r0[2 * qx + 1];
                    acc[2] += r1[2 * qx];
                    acc[3] += r1[2 * qx + 1];
                }
            }
            float R = acc[p[0]] * norm - BLACK;
            float G = (acc[p[1]] + acc[p[2]]) * 0.5f * norm - BLACK;
            float B = acc[p[3]] * norm - BLACK;
            const float *m = v->m;
            o[0] = enc(v, m[0] * R + m[1] * G + m[2] * B);
            o[1] = enc(v, m[3] * R + m[4] * G + m[5] * B);
            o[2] = enc(v, m[6] * R + m[7] * G + m[8] * B);
            o += 3;
        }
    }
}
