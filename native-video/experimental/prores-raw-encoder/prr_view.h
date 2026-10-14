#ifndef PRR_VIEW_H
#define PRR_VIEW_H
#include <stdint.h>
#include "prr_dec.h"

/* Display rendering of a decoded ProRes RAW frame: box-downscale by an even factor (one RGB value
 * per scale x scale block), white balance and colour matrix from the frame header, XYZ(D65) to
 * linear sRGB, sRGB transfer to 8 bits. */

struct prr_view {
    int scale, bayer;
    int out_w, out_h;
    float m[9];
    /* m, white balance, black and the LUT index scale folded onto the four 2x2 quad position sums:
     * LUT index of channel c = k0[c] + sum_j k[c][j] * sum_j. */
    float k[3][4], k0[3];
    uint8_t lut[4096];
};

void prr_view_setup(struct prr_view *v, const struct prr_dec_meta *meta, int width, int height, int scale, float ev);
/* Renders output rows [row_begin, row_end) as packed RGB888 with stride out_w * 3. */
void prr_view_rows(const struct prr_view *v, const uint16_t *bayer, int stride_bytes, uint8_t *rgb, int row_begin, int row_end);

#endif
