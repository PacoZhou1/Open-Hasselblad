#ifndef XMD_OFFLINE_SAMPLE_H
#define XMD_OFFLINE_SAMPLE_H
#include <stddef.h>
#include <stdint.h>

/* Layout recovered from the exported accessor and independent native readers.
 * This is not a proposed generic SDK header or an unpinned firmware ABI. */
struct xmd_native_value { int32_t type, count; const void *data; };
typedef const struct xmd_native_value *(*xmd_get_by_id_fn)(
    void *, int32_t, const char *, const char *, int32_t);

enum { XMD_FIELD_COUNT=13, XMD_DATA_BYTES=16 };
enum { XMD_ABSENT=0, XMD_COPIED=1, XMD_SHAPE_MISMATCH=2, XMD_NULL_DATA=3 };
enum { XMD_OK=0, XMD_BAD_CONTRACT=1, XMD_NO_CONTAINER=2, XMD_NO_READ_PERMISSION=3, XMD_ACTIVE_WRITER=4, XMD_NOT_READ_ONLY=5 };
struct xmd_field {
    uint32_t tag, state;
    int32_t native_type, native_count;
    uint32_t copied_bytes;
    unsigned char data[XMD_DATA_BYTES];
};
struct xmd_snapshot {
    uint32_t frame_id, state;
    uint64_t native_timestamp;
    uint32_t container_permission;
    uint16_t observed_writer_count;
    /* No automatic upgrade to an applied-value assertion: EXPM has fallback. */
    uint8_t exact_exposure_frame_match_proven;
    struct xmd_field fields[XMD_FIELD_COUNT];
};

/* Must be called on a matching borrowed native frame before original forward.
 * get_by_id must be cached/pinned outside callback to libdcam_base.so.
 * Only out is retained. No source pointer, worker IO or permission changes. */
int xmd_sample_borrowed_frame(const void *frame, size_t known_native_frame_bytes,
    int verified_native_contract, xmd_get_by_id_fn get_by_id,
    struct xmd_snapshot *out);
#endif
