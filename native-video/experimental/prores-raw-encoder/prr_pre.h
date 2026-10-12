#ifndef PRR_PRE_H
#define PRR_PRE_H
#include <stdint.h>

/* Camera MODE21 frame -> ProRes RAW encoder input.
 * out = clamp((in - black) * range / (white - black) + 256), so black lands on the format's fixed
 * pedestal of 256 and white on 256 + range = 65535. Banding-class pixels (source x odd, y % 6 == 1)
 * additionally have their above-black signal divided by the class gain surface. */

struct prr_pre_geom {
    int src_stride_px, src_rows;
    int x0, y0, width, height;
    int dst_stride_px;
    int ob_x[2][2];          /* two optical-black column ranges [begin, end) */
    int ob_y0, ob_y1;        /* optical-black row range [begin, end) */
};

struct prr_pre {
    struct prr_pre_geom g;
    float white, ob_bias;
    int class_first;         /* first window row that is a class row, or -1 */
    int class_rows, class_cols;
    uint16_t *inv_q14;       /* class_rows x class_cols inverse class gains, Q14 */
    uint32_t *hist;          /* 4096-bin black histogram scratch */
};

#define PRR_PRE_GEOM_MODE21 { 3968, 2946, 16, 32, 3888, 2912, 3968, {{2, 14}, {3906, 3918}}, 40, 2940 }

int prr_pre_init(struct prr_pre *p, const struct prr_pre_geom *g, float white, float ob_bias, int banding);
void prr_pre_free(struct prr_pre *p);
float prr_pre_black(struct prr_pre *p, const uint16_t *src);
void prr_pre_rows(const struct prr_pre *p, const uint16_t *src, uint16_t *dst, float black, int row_begin, int row_end);
void prr_pre_rows_scalar(const struct prr_pre *p, const uint16_t *src, uint16_t *dst, float black, int row_begin, int row_end);
float prr_band_gain(float x, float y);

#endif
