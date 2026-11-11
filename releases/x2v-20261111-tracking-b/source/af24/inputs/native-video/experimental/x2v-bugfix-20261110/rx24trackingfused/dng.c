#include "dng.h"
#include <math.h>
#include <string.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif

enum { BYTE = 1, ASCII = 2, SHORT = 3, LONG = 4, RATIONAL = 5, SRATIONAL = 10 };
static const uint32_t type_size[] = { 0, 1, 1, 2, 4, 8, 0, 0, 0, 0, 8 };

#define IFD_AT 8u
#define MAX_TAGS 40u

struct ifd {
    uint8_t *buf;
    uint32_t n, data, last;      /* entries, next free byte for out-of-line values, last tag id */
    int full;
};

static void put16(uint8_t *p, uint32_t v) { p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8); }
static void put32(uint8_t *p, uint32_t v) { put16(p, v); put16(p + 2, v >> 16); }

/* `value` is already little-endian. Tags must come in ascending order; values over
 * 4 bytes go after the (fixed-size) entry table. */
static void tag(struct ifd *d, uint16_t id, uint16_t type, uint32_t count, const void *value)
{
    uint32_t size = type_size[type] * count;
    if (d->n == MAX_TAGS || (d->n && id <= d->last) || (size > 4 && d->data + size > DNG_HDR_BYTES)) {
        d->full = 1;
        return;
    }
    uint8_t *e = d->buf + IFD_AT + 2 + 12 * d->n++;
    d->last = id;
    put16(e, id);
    put16(e + 2, type);
    put32(e + 4, count);
    if (size <= 4) {
        memcpy(e + 8, value, size);
    } else {
        put32(e + 8, d->data);
        memcpy(d->buf + d->data, value, size);
        d->data += (size + 1) & ~1u;
    }
}

static void tag_ints(struct ifd *d, uint16_t id, uint16_t type, uint32_t count, const uint32_t *v)
{
    uint8_t b[64];
    for (uint32_t i = 0; i < count && i < 16; i++) {
        if (type == BYTE) b[i] = (uint8_t)v[i];
        else if (type == SHORT) put16(b + 2 * i, v[i]);
        else put32(b + 4 * i, v[i]);
    }
    tag(d, id, type, count, b);
}

static void tag_int(struct ifd *d, uint16_t id, uint16_t type, uint32_t v) { tag_ints(d, id, type, 1, &v); }

static void tag_rats(struct ifd *d, uint16_t id, uint16_t type, uint32_t count, const double *v, uint32_t den)
{
    uint8_t b[72];
    for (uint32_t i = 0; i < count && i < 9; i++) {
        double q = floor(v[i] * den + 0.5);
        put32(b + 8 * i, type == SRATIONAL ? (uint32_t)(int32_t)q : (uint32_t)q);
        put32(b + 8 * i + 4, den);
    }
    tag(d, id, type, count, b);
}

static void tag_str(struct ifd *d, uint16_t id, const char *s) { tag(d, id, ASCII, (uint32_t)strlen(s) + 1, s); }

static int invert3(const double *m, double *o)
{
    double a = m[4] * m[8] - m[5] * m[7], b = m[5] * m[6] - m[3] * m[8], c = m[3] * m[7] - m[4] * m[6];
    double det = m[0] * a + m[1] * b + m[2] * c;
    if (fabs(det) < 1e-12) return -1;
    o[0] = a / det; o[1] = (m[2] * m[7] - m[1] * m[8]) / det; o[2] = (m[1] * m[5] - m[2] * m[4]) / det;
    o[3] = b / det; o[4] = (m[0] * m[8] - m[2] * m[6]) / det; o[5] = (m[2] * m[3] - m[0] * m[5]) / det;
    o[6] = c / det; o[7] = (m[1] * m[6] - m[0] * m[7]) / det; o[8] = (m[0] * m[4] - m[1] * m[3]) / det;
    return 0;
}

static uint32_t bcd(uint32_t v) { return (v / 10) << 4 | v % 10; }

int dng_header(uint8_t *out, const struct dng_geom *g, const struct dng_color *c, double black, uint32_t white,
               uint32_t frame, uint32_t fps)
{
    memset(out, 0, DNG_HDR_BYTES);
    memcpy(out, "II*\0", 4);
    put32(out + 4, IFD_AT);
    struct ifd d = { out, 0, IFD_AT + 2 + 12 * MAX_TAGS + 4, 0, 0 };

    /* DNG's ColorMatrix1 maps XYZ to raw (unbalanced) camera RGB: the inverse of
     * cam_to_xyz after the gains it was calibrated with, so it does not follow the
     * scene. AsShotNeutral is the raw colour of the scene's white. */
    const double cal[3] = { c->cal_red, 1, c->cal_blue };
    double m[9], xyz_to_cam[9];
    for (int i = 0; i < 9; i++) m[i] = c->cam_to_xyz[i] * cal[i % 3];
    if (!fps || !(c->wb_red > 0 && c->wb_blue > 0) || (g->bits != 12 && g->bits != 16) || invert3(m, xyz_to_cam))
        return -1;
    const double neutral[3] = { 1 / c->wb_red, 1, 1 / c->wb_blue };
    const double step = (double)(1u << (16 - g->bits)), stored_black = black / step;
    const double crop_origin[2] = { 0, 0 }, crop_size[2] = { g->crop_w, g->crop_h }, rate = fps;
    const uint32_t cfa_dim[2] = { 2, 2 }, rggb[4] = { 0, 1, 1, 2 }, planes[3] = { 0, 1, 2 };
    const uint32_t version[4] = { 1, 4, 0, 0 }, backward[4] = { 1, 1, 0, 0 }, one_by_one[2] = { 1, 1 };
    const uint32_t active[4] = { g->top, g->left, g->bottom, g->right };
    uint32_t s = frame / fps;
    const uint32_t timecode[8] = { bcd(frame % fps), bcd(s % 60), bcd(s / 60 % 60), bcd(s / 3600 % 24) };

    tag_int(&d, 254, LONG, 0);                                  /* NewSubfileType: main image */
    tag_int(&d, 256, LONG, g->stride_px);
    tag_int(&d, 257, LONG, g->rows);
    tag_int(&d, 258, SHORT, g->bits);
    tag_int(&d, 259, SHORT, 1);                                 /* uncompressed */
    tag_int(&d, 262, SHORT, 32803);                             /* CFA */
    tag_str(&d, 270, "X2V video frame; colour profile not calibrated");
    tag_str(&d, 271, "Hasselblad");
    tag_str(&d, 272, "X2D II 100C");
    tag_int(&d, 273, LONG, DNG_HDR_BYTES);                      /* StripOffsets */
    tag_int(&d, 274, SHORT, 1);
    tag_int(&d, 277, SHORT, 1);
    tag_int(&d, 278, LONG, g->rows);
    tag_int(&d, 279, LONG, (uint32_t)dng_pixel_bytes(g));
    tag_int(&d, 284, SHORT, 1);
    tag_str(&d, 305, "X2V");
    tag_ints(&d, 33421, SHORT, 2, cfa_dim);
    tag_ints(&d, 33422, BYTE, 4, rggb);
    tag_ints(&d, 50706, BYTE, 4, version);
    tag_ints(&d, 50707, BYTE, 4, backward);
    tag_str(&d, 50708, "Hasselblad X2D II 100C X2V video");  /* UniqueCameraModel */
    tag_ints(&d, 50710, BYTE, 3, planes);
    tag_int(&d, 50711, SHORT, 1);                               /* CFALayout: rectangular */
    tag_ints(&d, 50713, SHORT, 2, one_by_one);                  /* BlackLevelRepeatDim */
    tag_rats(&d, 50714, RATIONAL, 1, &stored_black, 256);
    tag_int(&d, 50717, LONG, (uint32_t)(white / step));
    tag_rats(&d, 50719, RATIONAL, 2, crop_origin, 1);
    tag_rats(&d, 50720, RATIONAL, 2, crop_size, 1);
    tag_rats(&d, 50721, SRATIONAL, 9, xyz_to_cam, 10000);       /* ColorMatrix1 */
    tag_rats(&d, 50728, RATIONAL, 3, neutral, 10000);           /* AsShotNeutral */
    tag_int(&d, 50778, SHORT, 21);                              /* CalibrationIlluminant1: D65 */
    tag_ints(&d, 50829, LONG, 4, active);                       /* ActiveArea */
    tag_ints(&d, 51043, BYTE, 8, timecode);                     /* TimeCodes (SMPTE) */
    tag_rats(&d, 51044, SRATIONAL, 1, &rate, 1);                /* FrameRate */
    put16(out + IFD_AT, d.n);
    return d.full ? -1 : 0;
}

/* In place: the rows read, two above and below each class row, are never class rows. */
void dng_fix_classes(const struct prr_pre *p, uint16_t *src)
{
    if (p->class_first < 0) return;
    const size_t two = 2 * (size_t)p->g.src_stride_px;
    for (int k = 0; k < p->class_rows; k++) {
        uint16_t *s = src + (size_t)(p->g.y0 + p->class_first + 6 * k) * p->g.src_stride_px + p->g.x0;
        for (int x = 0; x < p->g.width; x++)
            s[x] = (uint16_t)(((uint32_t)s[x - two] + s[x + two] + 1) >> 1);
    }
}

/* Same arithmetic as prr_pre_black, on 12-bit samples: its histogram bins are the 12-bit
 * values, and the window and the mean are the same once scaled by 16. The samples are kept
 * from the first pass, so the frame's scattered optical-black lines are read once. Not
 * reentrant. */
float dng_black12(const struct prr_pre *p, const uint8_t *px)
{
    enum { BINS = 4096, WINDOW = 32, MAX_OB = 1 << 17 };
    static uint16_t ob[MAX_OB];
    const size_t rb = dng_row_bytes12(p);
    uint32_t h[BINS] = { 0 }, n = 0;
    for (int y = p->g.ob_y0; y < p->g.ob_y1; y++) {
        const uint8_t *row = px + (size_t)y * rb;
        for (int r = 0; r < 2; r++)
            for (int x = p->g.ob_x[r][0]; x < p->g.ob_x[r][1] && n < MAX_OB; x++) {
                unsigned v = dng_get12(row, (unsigned)x);
                h[v]++;
                ob[n++] = (uint16_t)v;
            }
    }
    if (!n)
        return NAN;
    uint32_t acc = 0;
    int m = 0;
    while (m < BINS - 1 && (acc += h[m]) < (n + 1) / 2)
        m++;
    const unsigned lo = m > WINDOW ? (unsigned)(m - WINDOW) : 0, hi = (unsigned)(m + WINDOW + 1);
    uint64_t sum = 0, cnt = 0;
    for (uint32_t i = 0; i < n; i++)
        if (ob[i] >= lo && ob[i] < hi) {
            sum += ob[i];
            cnt++;
        }
    return (float)((double)(sum << 4) / (double)cnt) + p->ob_bias;
}

/* Every sample of each class row, as dng_fix_classes. x0 is even, so each packed pair is
 * one even and one odd site; the mean of two 12-bit values rounded up equals the 16-bit
 * mean then packed. */
void dng_fix_classes12(const struct prr_pre *p, uint8_t *px)
{
    if (p->class_first < 0) return;
    const size_t rb = dng_row_bytes12(p);
    const int pairs = p->g.width / 2;
    for (int k = 0; k < p->class_rows; k++) {
        uint8_t *row = px + (size_t)(p->g.y0 + p->class_first + 6 * k) * rb;
        int j = 0;
#if defined(__aarch64__)
        const uint8x8_t lo4 = vdup_n_u8(15);
        for (uint8_t *g = row + (size_t)(p->g.x0 >> 1) * 3; j + 8 <= pairs; j += 8, g += 24) {
            uint8x8x3_t t = vld3_u8(g), u = vld3_u8(g - 2 * rb), d = vld3_u8(g + 2 * rb);
            uint16x8_t up_e = vorrq_u16(vshll_n_u8(u.val[0], 4), vmovl_u8(vshr_n_u8(u.val[1], 4)));
            uint16x8_t dn_e = vorrq_u16(vshll_n_u8(d.val[0], 4), vmovl_u8(vshr_n_u8(d.val[1], 4)));
            uint16x8_t up_o = vorrq_u16(vshll_n_u8(vand_u8(u.val[1], lo4), 8), vmovl_u8(u.val[2]));
            uint16x8_t dn_o = vorrq_u16(vshll_n_u8(vand_u8(d.val[1], lo4), 8), vmovl_u8(d.val[2]));
            uint16x8_t e = vrhaddq_u16(up_e, dn_e), o = vrhaddq_u16(up_o, dn_o);
            t.val[0] = vmovn_u16(vshrq_n_u16(e, 4));
            t.val[1] = vorr_u8(vmovn_u16(vshlq_n_u16(e, 4)), vmovn_u16(vshrq_n_u16(o, 8)));
            t.val[2] = vmovn_u16(o);
            vst3_u8(g, t);
        }
#endif
        for (int x = p->g.x0 + 2 * j; x < p->g.x0 + p->g.width; x++)
            dng_put12(row, (unsigned)x, (dng_get12(row - 2 * rb, (unsigned)x) +
                                         dng_get12(row + 2 * rb, (unsigned)x) + 1) >> 1);
    }
}

void dng_pack12(uint16_t *buf, size_t samples) { dng_pack12_to((uint8_t *)buf, buf, samples); }

/* Safe in place: each step reads its input before writing, and its output ends before
 * the next step's input begins. Saturating +8 then >>4 rounds without passing 4095. */
void dng_pack12_to(uint8_t *dst, const uint16_t *src, size_t samples)
{
    const uint16_t *s = src;
    uint8_t *o = dst;
    size_t i = 0;
#if defined(__aarch64__)
    const uint16x8_t half = vdupq_n_u16(8);
    for (; i + 16 <= samples; i += 16, s += 16, o += 24) {
        uint16x8x2_t v = vld2q_u16(s);
        uint16x8_t a = vshrq_n_u16(vqaddq_u16(v.val[0], half), 4), b = vshrq_n_u16(vqaddq_u16(v.val[1], half), 4);
        uint8x8x3_t r;
        r.val[0] = vmovn_u16(vshrq_n_u16(a, 4));
        r.val[1] = vmovn_u16(vorrq_u16(vshlq_n_u16(a, 4), vshrq_n_u16(b, 8)));
        r.val[2] = vmovn_u16(b);
        vst3_u8(o, r);
    }
#endif
    for (; i + 2 <= samples; i += 2, s += 2, o += 3) {
        unsigned a = s[0] >= 65528 ? 4095 : (s[0] + 8u) >> 4, b = s[1] >= 65528 ? 4095 : (s[1] + 8u) >> 4;
        o[0] = (uint8_t)(a >> 4);
        o[1] = (uint8_t)(a << 4 | b >> 8);
        o[2] = (uint8_t)b;
    }
}
