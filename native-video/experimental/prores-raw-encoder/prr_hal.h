#ifndef PRR_HAL_H
#define PRR_HAL_H
#include <stdint.h>
#include <string.h>

/* DJI duss HAL as used by stock test_msenc and libdcam_venc_proresraw.so (Android 9 firmware 1.3.16).
 * Struct layouts are byte offsets recovered from those binaries; see
 * research/prores-raw-20261013/results.json "hal_recipe". Only the fields below are written. */

struct prr_hal_device {
    const char *name;
    void *attach;
    void *detach;
    void *reserved;
};

int duss_hal_initialize(struct prr_hal_device *table);
int duss_hal_device_open(const char *name, void *cfg, void **handle);
int duss_hal_device_start(void *handle, void *cfg);
int duss_hal_device_stop(void *handle, void *cfg);
int duss_hal_device_close(void *handle);
int duss_hal_mem_alloc(void *mem, void **buf, uint32_t size, uint32_t align, uint32_t flags, uint32_t heap);
int duss_hal_mem_free(void *buf);
int duss_hal_mem_map(void *buf, void **va);
int duss_hal_mem_get_phys_addr(void *buf, uint64_t *pa);
/* dir bits 2|4 and 1|8 select the two ion_custom_sync modes; a no-op on uncached buffers. */
int duss_hal_mem_sync(void *buf, int dir);
int duss_hal_msenc_encfrm(void *handle, void *packet);
int duss_hal_attach_msenc(void);
int duss_hal_detach_msenc(void);
int duss_hal_attach_ion_mem(void);
int duss_hal_detach_ion_mem(void);
int duss_hal_attach_codec_msdec(void);
int duss_hal_detach_codec_msdec(void);
int duss_hal_msdec_parse_header(void *handle, void *header);
int duss_hal_msdec_decstrm(void *handle, void *arg);

/* duss_log_initialize + duss_hal_initialize once per process with every device this code opens. */
int prr_hal_init(void);

typedef int (*prr_frame_empty_cb)(void *ctx, void **frame_and_ics);
struct prr_stream_done { int32_t result; int32_t pad; void *stream1; void *stream2; };
typedef int (*prr_stream_full_cb)(void *ctx, struct prr_stream_done *done);

enum {
    PRR_OPEN_U8_08 = 0x08,
    PRR_OPEN_STREAM_CTX = 0x10,
    PRR_OPEN_FRAME_CTX = 0x18,
    PRR_OPEN_FRAME_CB = 0x20,
    PRR_OPEN_STREAM_CB = 0x28,
    PRR_OPEN_WIDTH = 0x30,
    PRR_OPEN_HEIGHT = 0x32,
    PRR_OPEN_CROP = 0x34,
    PRR_OPEN_BAYER = 0x38,
    PRR_OPEN_U8_39 = 0x39,
    PRR_OPEN_SENSEL_RANGE = 0x3a,
    PRR_OPEN_U32_3C = 0x3c,
    PRR_OPEN_BYTES = 0x100,

    PRR_START_WIDTH = 0x0,
    PRR_START_HEIGHT = 0x4,
    PRR_START_PROFILE = 0x8,
    PRR_START_PIXFMT = 0xc,
    PRR_START_BYTES = 0x40,

    PRR_FRAME_HANDLE = 0x20,
    PRR_FRAME_PTS = 0x30,
    PRR_FRAME_STRIDE = 0x40,
    PRR_FRAME_OFFSET = 0x44,
    PRR_FRAME_PLANE_H = 0x4c,
    PRR_FRAME_PLANES = 0xb0,
    PRR_FRAME_BYTES = 0x330,

    PRR_ICS_HANDLE = 0x08,
    PRR_ICS_BYTES = 0x40,

    PRR_STREAM_HANDLE = 0x20,
    PRR_STREAM_ALLOCATED = 0x38,
    PRR_STREAM_OFFSET = 0x3c,
    PRR_STREAM_WRITTEN = 0x40,
    PRR_STREAM_DATA_OFFSET = 0x44,
    PRR_STREAM_BYTES = 0x1c8,

    PRR_PKT_FRAME = 0x00,
    PRR_PKT_ICS = 0x08,
    PRR_PKT_STREAM1 = 0x10,
    PRR_PKT_STREAM2 = 0x18,
    PRR_PKT_WB_RED = 0x20,
    PRR_PKT_WB_BLUE = 0x24,
    PRR_PKT_GAIN = 0x28,
    PRR_PKT_MATRIX = 0x2c,
    PRR_PKT_CCT = 0x50,
    PRR_PKT_MATRIX_TYPE = 0x54,
    PRR_PKT_BYTES = 0x100,

    PRR_PIXFMT_BAYER16_BASE = 10031,
    PRR_ICS_ALIGN = 256,
    /* mem_alloc flags bit 4 -> ION_FLAG_CACHED | ION_FLAG_CACHED_NEEDS_SYNC (ion_mem_alloc). */
    PRR_MEM_CACHED = 0x10,

    /* test_msdec: header {ptr, u32 len, then parsed u32 width, height, bayer}; decstrm takes
     * {stream, frame, decoded metadata} and fills the metadata in place. */
    PRR_DHDR_PTR = 0x00,
    PRR_DHDR_LEN = 0x08,
    PRR_DHDR_WIDTH = 0x0c,
    PRR_DHDR_HEIGHT = 0x10,
    PRR_DHDR_BAYER = 0x14,
    PRR_DHDR_BYTES = 0x20,
    PRR_DHDR_READ = 0x100,

    PRR_DSTREAM_WH = 0x30,
    PRR_DSTREAM_SEG2_OFFSET = 0x54,
    PRR_DSTREAM_SEG2_LEN = 0x58,
    PRR_DSTREAM_MODE = 0x1b8,

    PRR_DFRAME_PIXFMT = 0x28,
    PRR_DFRAME_WIDTH = 0x38,
    PRR_DFRAME_HEIGHT = 0x3c,
    PRR_DFRAME_STRIDE = 0x40,

    PRR_DARG_STREAM = 0x00,
    PRR_DARG_FRAME = 0x08,
    PRR_DARG_HSIZE = 0x10,
    PRR_DARG_VSIZE = 0x12,
    PRR_DARG_CROP = 0x14,
    PRR_DARG_BAYER = 0x18,
    PRR_DARG_RANGE = 0x1a,
    PRR_DARG_WB_RED = 0x1c,
    PRR_DARG_WB_BLUE = 0x20,
    PRR_DARG_MATRIX = 0x24,
    PRR_DARG_GAIN = 0x48,
    PRR_DARG_CCT = 0x4c,
};

static inline void prr_put8(void *s, int off, uint8_t v) { memcpy((char *)s + off, &v, 1); }
static inline void prr_put16(void *s, int off, uint16_t v) { memcpy((char *)s + off, &v, 2); }
static inline void prr_put32(void *s, int off, uint32_t v) { memcpy((char *)s + off, &v, 4); }
static inline void prr_put64(void *s, int off, uint64_t v) { memcpy((char *)s + off, &v, 8); }
static inline void prr_putf(void *s, int off, float v) { memcpy((char *)s + off, &v, 4); }
static inline void prr_putp(void *s, int off, const void *v) { memcpy((char *)s + off, &v, sizeof v); }
static inline uint32_t prr_get32(const void *s, int off) { uint32_t v; memcpy(&v, (const char *)s + off, 4); return v; }
static inline void *prr_getp(const void *s, int off) { void *v; memcpy(&v, (const char *)s + off, sizeof v); return v; }

#endif
