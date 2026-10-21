#ifndef X2V_DNG_H
#define X2V_DNG_H
#include "prr_pre.h"
#include <stddef.h>
#include <stdint.h>

/* CinemaDNG frames written straight from a camera MODE21 source frame.
 *
 * The file is a 4 KiB header followed by the source's first `rows` rows at its own
 * stride, untouched except for the phase-detection rows, which get the same
 * interpolation the ProRes RAW path applies. ActiveArea and DefaultCrop select the
 * picture, so no pixel is moved; BlackLevel is the frame's measured optical black.
 * The sensor's samples are 12-bit values shifted up by 4, so they are stored packed
 * at 12 bits, a quarter less to write. Both writes are whole 4 KiB blocks from
 * aligned memory, which is what O_DIRECT needs. */

#define DNG_HDR_BYTES 4096u

struct dng_geom {
    uint32_t stride_px, rows;               /* stored image */
    uint32_t top, left, bottom, right;      /* ActiveArea */
    uint32_t crop_w, crop_h;                /* DefaultCropSize, from the active area's corner */
    uint32_t bits;                          /* stored sample depth: 16, or 12 packed */
};

struct dng_color {
    float wb_red, wb_blue;                  /* as-shot white-balance gains */
    float cal_red, cal_blue;                /* the gains cam_to_xyz is balanced for */
    float cam_to_xyz[9];                    /* white-balanced camera RGB -> XYZ (D65), as in prr_meta */
};

/* MODE21: rows through the active area's last one, a whole number of 4 KiB blocks at 12 bits. */
#define DNG_GEOM_MODE21 { 3968, 2944, 32, 16, 2944, 3904, 3888, 2912, 12 }

static inline uint64_t dng_pixel_bytes(const struct dng_geom *g)
{
    return (uint64_t)g->stride_px * g->rows * g->bits / 8;
}

/* One frame's header, zero-padded to DNG_HDR_BYTES; black and white are in source
 * (16-bit) units. Returns 0, or -1 when it would not fit. */
int dng_header(uint8_t *out, const struct dng_geom *g, const struct dng_color *c, double black, uint32_t white,
               uint32_t frame, uint32_t fps);

/* Phase-detection rows of the source frame `src` (prr_pre's geometry), in place: every
 * column the mean of the same-colour sites two rows above and below, as prr_pre_rows does. */
void dng_fix_classes(const struct prr_pre *p, uint16_t *src);

/* `samples` 16-bit samples -> 12-bit DNG pixels at `dst`, which may be `src` itself:
 * rounded to the nearest 12-bit step, two to three bytes, high bits first. */
void dng_pack12_to(uint8_t *dst, const uint16_t *src, size_t samples);
void dng_pack12(uint16_t *buf, size_t samples);

/* A frame packed from the source at its own stride, read and corrected in source (16-bit)
 * units. On the sensor's samples, 12-bit values shifted up by 4, these give exactly what
 * prr_pre_black and dng_fix_classes followed by packing give on the 16-bit frame. */
float dng_black12(const struct prr_pre *p, const uint8_t *px);
void dng_fix_classes12(const struct prr_pre *p, uint8_t *px);

static inline size_t dng_row_bytes12(const struct prr_pre *p) { return (size_t)p->g.src_stride_px * 3 / 2; }

static inline unsigned dng_get12(const uint8_t *row, unsigned x)
{
    const uint8_t *g = row + (size_t)(x >> 1) * 3;
    return x & 1 ? (unsigned)(g[1] & 15) << 8 | g[2] : (unsigned)g[0] << 4 | g[1] >> 4;
}

static inline void dng_put12(uint8_t *row, unsigned x, unsigned v)
{
    uint8_t *g = row + (size_t)(x >> 1) * 3;
    if (x & 1) {
        g[1] = (uint8_t)((g[1] & 0xf0) | v >> 8);
        g[2] = (uint8_t)v;
    } else {
        g[0] = (uint8_t)(v >> 4);
        g[1] = (uint8_t)((g[1] & 0x0f) | v << 4);
    }
}

#endif
