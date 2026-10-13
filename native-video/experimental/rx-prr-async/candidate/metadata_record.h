#ifndef XMD_RECORD_H
#define XMD_RECORD_H
#include "metadata_sample.h"
#include <stddef.h>
#include <stdint.h>

/* Fixed CPU-owned per-frame ledger, never a native pointer or payload slot. */
struct xmd_record {
    uint64_t clip_generation,slot_generation;
    uint32_t frame_index,ready;
    struct xmd_snapshot snapshot;
};
#define XMD_WIRE_BYTES (60u+36u*XMD_FIELD_COUNT)
#define XMD_HEX_BYTES (2u*XMD_WIRE_BYTES)
int xmd_record_store(struct xmd_record *,uint64_t clip,uint64_t slot,
    uint32_t index,uint32_t source_id,uint64_t stamp,const struct xmd_snapshot *);
int xmd_record_matches(const struct xmd_record *,uint64_t clip,uint64_t slot,
    uint32_t index,uint32_t source_id,uint64_t stamp);
/* Writer-only fixed encoder; lowercase hex, explicit LE wire layout, no IO.
 * Fails instead of publishing unsupported exact hardware-match assertions. */
int xmd_record_hex(const struct xmd_record *,char *,size_t);
#endif
