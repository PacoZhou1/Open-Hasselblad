#ifndef X2_DNG_FRAME_WRITER_H
#define X2_DNG_FRAME_WRITER_H
#include <stddef.h>
#include <stdint.h>
/* CPU memory only; LE uint16 Bayer. No source ownership transfer. */
struct dng_bayer_frame {
 const unsigned char *data;
 size_t span, stride;
 uint32_t width,height;
 uint16_t output_bits; /*16 direct rows, or12 MSB TIFF packing; all12 samples<=4095*/
};
struct dng_rational { uint32_t numerator,denominator; };
struct dng_srational { int32_t numerator,denominator; };
struct dng_frame_profile {
 const char *unique_camera_model; /* explicitly declared provisional profile, never implicit */
 unsigned char cfa[4];           /* at THIS buffer origin, not uncropped origin */
 struct dng_rational black_level;
 uint32_t white_level;
 struct dng_srational color_matrix1[9];
 struct dng_rational as_shot_neutral[3];
 uint16_t calibration_illuminant1; /*0 means unknown; never assume D65*/
};
/* Internal CPU header builder; no file IO, no pixel interpretation. */
int x2v_dng_header(const struct dng_bayer_frame *,const struct dng_frame_profile *,
                   unsigned char header[4096],uint64_t *pixel_bytes);
#endif
