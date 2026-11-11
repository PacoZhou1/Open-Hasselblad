#ifndef X2V_PREVIEW_EXPOSURE_H
#define X2V_PREVIEW_EXPOSURE_H
#include <stddef.h>

/* FW 1.3.16.2 dcam_ae_get_output: video begins at +8, still at +0x1090.
 * Read-only output, not a command packet. No sensor/ISP registers are changed.
 * RAW bypasses the ISP's simulation of the requested still exposure. */
int x2v_preview_exposure_gain(const void *ae, size_t bytes, float *gain);
int x2v_preview_exposure_read(float *gain);
#endif
