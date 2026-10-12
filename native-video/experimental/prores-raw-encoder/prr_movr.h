#ifndef PRR_MOVR_H
#define PRR_MOVR_H
#include <stdint.h>

/* Reader for single-track ProRes RAW QuickTime files. Uses the moov sample tables when present;
 * otherwise (recording cut off before close) scans the mdat for size + 'prrf' frames and keeps
 * every complete one. */

struct prr_movr {
    int fd;
    uint64_t file_size;
    uint32_t count;
    uint64_t *offsets;
    uint32_t *sizes;
    uint32_t timescale, sample_duration;
    uint16_t width, height;
    char fourcc[5];
    int recovered;
};

int prr_movr_open(struct prr_movr *r, const char *path);
/* Reads sample i into buf; returns its size, or a negative errno. */
int prr_movr_read(const struct prr_movr *r, uint32_t i, void *buf, uint32_t cap);
uint32_t prr_movr_max_size(const struct prr_movr *r);
void prr_movr_close(struct prr_movr *r);

#endif
