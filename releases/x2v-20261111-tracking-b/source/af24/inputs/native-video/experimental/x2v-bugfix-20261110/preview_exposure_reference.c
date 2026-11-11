#include "preview_exposure.h"
#include <math.h>
#include <stdint.h>
#include <string.h>

static uint32_t u32(const unsigned char *p, size_t at)
{
    uint32_t v;
    memcpy(&v, p + at, sizeof v);
    return v;
}

int x2v_preview_exposure_gain(const void *ae, size_t bytes, float *gain)
{
    if (!ae || !gain || bytes < 0xa0) return -1;
    const unsigned char *p = ae;
    /* The SUB preview uses video ISP dgain (Q12), gamma dgain (Q8) and
     * positive exposure-simulation EV (Q8). Sensor time/analogue gain are
     * already present in the RAW samples. Still-capture plans and adaptive
     * photographic Knee EV do not define the reference video rendering. */
    double isp = u32(p, 0x64) / 4096.0;
    double dg = u32(p, 0x90) / 256.0;
    double ev = u32(p, 0x9c) / 256.0;
    if (!(isp > 0 && isp <= 256) || !(dg > 0 && dg <= 256) || ev > 5) return -2;
    double value = isp * dg * exp2(ev);
    if (!isfinite(value) || value < 1.0/4096.0 || value > 4096) return -3;
    *gain = (float)value;
    return 0;
}
