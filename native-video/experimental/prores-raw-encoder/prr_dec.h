#ifndef PRR_DEC_H
#define PRR_DEC_H
#include <stdint.h>
#include "prr_hal.h"

/* Moonshadow ProRes RAW hardware decoder (/dev/msdec0), driven the way stock test_msdec does:
 * open with no config, parse the frame header, then a synchronous decstrm per frame. Output is
 * 16-bit linear Bayer, black 256, white 65535, in a 256-byte aligned stride. */

struct prr_dec_meta {
    uint16_t width, height;
    uint8_t crop[4];
    uint8_t bayer;
    uint16_t sensel_range;
    float wb_red, wb_blue;
    float matrix[9];
    float gain;
    uint16_t cct;
};

struct prr_dec {
    void *mem, *dev;
    void *sbuf, *fbuf;
    uint8_t *sva;
    uint16_t *fva;
    uint32_t stream_cap, frame_bytes;
    int width, height, bayer, stride;
    int sync_dir;   /* nonzero: frame buffer is cached and synced with this dir after each decode */
    int sync_rc;
    _Alignas(16) uint8_t stream[PRR_STREAM_BYTES];
    _Alignas(16) uint8_t frame[PRR_FRAME_BYTES];
    _Alignas(16) uint8_t arg[0x88];
};

int prr_dec_open(struct prr_dec *d, uint32_t max_frame_bytes, int sync_dir);
/* Buffer the next coded frame must be written to before prr_dec_decode. */
static inline uint8_t *prr_dec_input(struct prr_dec *d) { return d->sva; }
/* Decodes len bytes from the input buffer; on success the Bayer frame is at d->fva. */
int prr_dec_decode(struct prr_dec *d, uint32_t len, struct prr_dec_meta *meta);
void prr_dec_close(struct prr_dec *d);

#endif
