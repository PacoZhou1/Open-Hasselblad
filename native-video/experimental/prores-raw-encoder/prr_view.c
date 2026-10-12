#include "prr_view.h"
#include <math.h>
#include <string.h>

#define BLACK 256.0f
#define RANGE 65279.0f

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

void prr_view_rows(const struct prr_view *v, const uint16_t *bayer, int stride_bytes, uint8_t *rgb, int row_begin, int row_end)
{
    /* Offsets of R, G1, G2, B inside a 2x2 quad for RGGB, GRBG, GBRG, BGGR. */
    static const int pos[4][4] = { { 0, 1, 2, 3 }, { 1, 0, 3, 2 }, { 2, 3, 0, 1 }, { 3, 2, 1, 0 } };
    const int *p = pos[v->bayer];
    int s = v->scale, q = s / 2, sp = stride_bytes / 2;
    float norm = 1.0f / (float)(q * q);
    for (int oy = row_begin; oy < row_end; oy++) {
        uint8_t *o = rgb + (size_t)oy * v->out_w * 3;
        for (int ox = 0; ox < v->out_w; ox++) {
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
