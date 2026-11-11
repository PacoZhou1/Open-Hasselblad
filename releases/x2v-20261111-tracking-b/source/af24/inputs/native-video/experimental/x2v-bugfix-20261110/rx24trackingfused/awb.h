#ifndef X2V_AWB_H
#define X2V_AWB_H
#include "prr_pre.h"
#include <stdint.h>

/* As-shot white balance of a source frame (prr_pre's geometry, RGGB from the window
 * origin): the gains that make its near-neutral content grey. Grey world over lit,
 * unclipped 2x2 quads, then refined on the quads whose balanced chroma is already near
 * neutral. Returns 0 and the gains, or -1 when too little of the frame qualifies or the
 * result is implausible. */
int awb_estimate(const struct prr_pre *p, const uint16_t *src, float black, float *wb_red, float *wb_blue);
/* The same on the frame packed by dng_pack12_to. */
int awb_estimate12(const struct prr_pre *p, const uint8_t *px, float black, float *wb_red, float *wb_blue);

#endif
