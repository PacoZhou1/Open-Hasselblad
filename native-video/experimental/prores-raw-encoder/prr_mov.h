#ifndef PRR_MOV_H
#define PRR_MOV_H
#include <stdint.h>

/* QuickTime writer for ProRes RAW: ftyp, wide, mdat (size 0 = to end of file until close), moov.
 * One chunk per sample with co64 offsets. A file cut off before close keeps every complete frame
 * recoverable by scanning the mdat for size + 'prrf' headers. */

struct prr_mov {
    int fd;
    uint16_t width, height;
    char fourcc[4];
    uint32_t timescale, sample_duration;
    uint64_t wide_offset, pos;
    uint32_t count, capacity;
    uint32_t *sizes;
    uint64_t *offsets;
};

int prr_mov_open(struct prr_mov *m, const char *path, int width, int height, const char *fourcc,
                 uint32_t timescale, uint32_t sample_duration);
int prr_mov_openat(struct prr_mov *m, int dirfd, const char *name, int width, int height,
                   const char *fourcc, uint32_t timescale, uint32_t sample_duration);
int prr_mov_write(struct prr_mov *m, const void *a, uint32_t alen, const void *b, uint32_t blen);
int prr_mov_fsync(struct prr_mov *m);
int prr_mov_close(struct prr_mov *m);

#endif
