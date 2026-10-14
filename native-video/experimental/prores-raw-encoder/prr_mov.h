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
    uint32_t *durations;
    uint8_t *keys;
    uint32_t non_key;
    /* Sample entry name (default "Apple ProRes RAW") and an optional child box appended to the
     * entry, e.g. a complete avcC; the caller keeps both alive until prr_mov_close. */
    const char *compressor;
    const uint8_t *entry_box;
    uint32_t entry_box_len;
    int iso;
};

int prr_mov_open(struct prr_mov *m, const char *path, int width, int height, const char *fourcc,
                 uint32_t timescale, uint32_t sample_duration);
int prr_mov_openat(struct prr_mov *m, int dirfd, const char *name, int width, int height,
                   const char *fourcc, uint32_t timescale, uint32_t sample_duration);
/* As prr_mov_openat, but an ISO base media (MP4) file: isom brand, free placeholder, url dref. */
int prr_mov_openat_mp4(struct prr_mov *m, int dirfd, const char *name, int width, int height,
                       const char *fourcc, uint32_t timescale, uint32_t sample_duration);
int prr_mov_write(struct prr_mov *m, const void *a, uint32_t alen, const void *b, uint32_t blen);
/* Appends a sample of `size` bytes at offset pos without writing it; the caller writes those bytes
 * there itself before prr_mov_close. */
int prr_mov_add_sample(struct prr_mov *m, uint32_t size);
/* As prr_mov_add_sample, with its own duration and whether it is a sync sample. */
int prr_mov_add_sample_ex(struct prr_mov *m, uint32_t size, uint32_t duration, int key);
int prr_mov_fsync(struct prr_mov *m);
int prr_mov_close(struct prr_mov *m);

#endif
