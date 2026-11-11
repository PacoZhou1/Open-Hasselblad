#ifndef PRR_ENC_H
#define PRR_ENC_H
#include <pthread.h>
#include <stdint.h>
#include "prr_hal.h"

#define PRR_MAX_SLOTS 8

struct prr_meta {
    float wb_red, wb_blue, gain;
    float matrix[9];
    uint16_t cct;
};

struct prr_enc_cfg {
    int width, height, stride;
    int profile;             /* start_cfg profile; 1 = HQ */
    int bayer;               /* 0 = RGGB */
    int frame_slots, stream_slots;
    int plugin_open;         /* also fill the open_cfg fields the stock plugin sets */
    int cached_stream;       /* cached bitstream buffers: CPU reads of uncached ION run near 33 MB/s */
    uint32_t stream_bytes;   /* per buffer; 0 = 0.8 frame. The second buffer of a pair only takes overflow. */
};

struct prr_out {
    int pair;
    uint64_t pts;
    const uint8_t *a, *b;
    uint32_t alen, blen;
    int32_t result;
};

struct prr_frame_slot {
    _Alignas(16) uint8_t frame[PRR_FRAME_BYTES];
    _Alignas(16) uint8_t ics[PRR_ICS_BYTES];
    _Alignas(16) uint8_t packet[PRR_PKT_BYTES];
    void *fbuf, *ibuf;
    uint16_t *va;
    int busy;
};

struct prr_stream_pair {
    _Alignas(16) uint8_t s[2][PRR_STREAM_BYTES];
    void *buf[2];
    uint8_t *va[2];
    uint32_t bytes;
    uint32_t span[2];        /* bytes exposed to the CPU, cleaned before the pair is reused */
    uint64_t pts;
    int32_t result;
    int busy, done;
};

struct prr_enc {
    struct prr_enc_cfg cfg;
    void *mem, *enc;
    int started;
    _Alignas(16) uint8_t open_cfg[PRR_OPEN_BYTES];
    _Alignas(16) uint8_t start_cfg[PRR_START_BYTES];
    uint32_t frame_bytes, ics_bytes, stream_bytes;
    struct prr_frame_slot fr[PRR_MAX_SLOTS];
    struct prr_stream_pair st[PRR_MAX_SLOTS];
    int order[PRR_MAX_SLOTS], order_head, order_count;
    pthread_mutex_t mu;
    pthread_cond_t cv;
    uint32_t submitted, encoded, unknown_callbacks, busy_returns;
    volatile int close_step;   /* 1 stopping, 2 closing, 3 freeing, 4 done */
    int open_stage;            /* prr_enc_open step that failed: 1 hal, 2 ion, 3 msenc, 4 frame, 5 stream, 6 start */
};

int prr_enc_open(struct prr_enc *e, const struct prr_enc_cfg *cfg);
int prr_enc_acquire_frame(struct prr_enc *e, uint16_t **va);
int prr_enc_submit(struct prr_enc *e, int slot, uint64_t pts, const struct prr_meta *meta);
int prr_enc_next(struct prr_enc *e, struct prr_out *out, int timeout_ms);
void prr_enc_release(struct prr_enc *e, const struct prr_out *out);
int prr_enc_pending(struct prr_enc *e);
void prr_enc_close(struct prr_enc *e);
/* Closes on a helper thread; the codec debug hub can block device_close indefinitely under adb su.
 * Returns the step reached (4 = finished) when it completes or the timeout passes. */
int prr_enc_close_timed(struct prr_enc *e, int timeout_ms);

#endif
