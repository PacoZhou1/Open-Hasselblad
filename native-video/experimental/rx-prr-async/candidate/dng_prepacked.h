#ifndef X2V_DNG_PREPACKED_H
#define X2V_DNG_PREPACKED_H
#include "frame_writer.h"
struct xmd_record;
#include <stdatomic.h>
#include <stddef.h>
#include <stdint.h>
/* Source geometry is unchanged MODE21. Slot holds the full borrowed frame;
 * encoded ProRes RAW samples are variable length, capped below. */
#define X2V_DNG_WIDTH 3920u
#define X2V_DNG_HEIGHT 2946u
#define X2V_DNG_STRIDE 7936u
#define X2V_DNG_SPAN 23379456u
#define X2V_PRR_WIDTH 3888u
#define X2V_PRR_HEIGHT 2912u
#define X2V_DNG_PIXEL_BYTES 22643712u /* 3888*2912*2 encoder input */
#define X2V_DNG_HEADER_BYTES 0u
#define X2V_DNG_FILE_BYTES 16777216u /* max encoded sample; actual size is per-frame */
#define X2V_DNG_SLOT_STRIDE 23379968u /* 4096-aligned source span */
#define X2V_DNG_POOL_BYTES 70139904u
#define X2V_DNG_MAX_FRAMES 240u
#define X2V_PRR_KIND "PRORES_RAW_HQ_MOV"
enum x2v_dng_slot_state {X2V_DNG_SLOT_FREE=0,X2V_DNG_SLOT_PREPARING=1,
 X2V_DNG_SLOT_READY=2,X2V_DNG_SLOT_WRITING=3,X2V_DNG_SLOT_FAILED=4};
struct x2v_dng_layout {uint64_t header_checksum;uint32_t validated;uint32_t pad;};
struct x2v_dng_ticket {uint64_t session,generation;};
struct x2v_dng_prepacked_slot {
 unsigned char *data;size_t span;const struct x2v_dng_layout *layout;
 _Atomic int state;struct x2v_dng_ticket ticket;uint32_t initialized;
};
struct x2v_dng_frame_time {uint32_t source_id;uint64_t native_timestamp_raw,cpu_admission_ns;};
struct x2v_dng_result {
 uint32_t index,source_id;uint64_t file_bytes,pixel_bytes,wall_begin_ns,wall_end_ns;
 int published,file_synced,pwrite_complete,publish_queued,complete_inline;
 uint64_t pwrite_begin_ns,pwrite_end_ns,join_begin_ns,join_end_ns;
 uint64_t fsync_begin_ns,fsync_end_ns,complete_begin_ns,complete_end_ns;
 int previous_joined,previous_published,previous_file_synced;
 uint32_t previous_index;
 uint64_t previous_fsync_begin_ns,previous_fsync_end_ns,previous_complete_begin_ns,previous_complete_end_ns;
 uint64_t mov_offset;
};
struct x2v_dng_finish {
 uint32_t published_frames,submitted_frames,last_index;
 int error,manifest_published,directory_synced,cpu_released,close_error,join_failed,last_published,last_file_synced;
 uint64_t last_fsync_begin_ns,last_fsync_end_ns,last_complete_begin_ns,last_complete_end_ns;
 uint64_t bytes_written;
};
struct x2v_dng_sequence;
int x2v_dng_layout_init(struct x2v_dng_layout *,const struct dng_frame_profile *,
                        int acknowledge_provisional);
int x2v_dng_prepacked_slot_init(struct x2v_dng_prepacked_slot *,
 const struct x2v_dng_layout *,void *data,size_t span);
int x2v_dng_prepare_prepacked(struct x2v_dng_prepacked_slot *,
 const void *source,size_t source_span,const struct x2v_dng_ticket *);
int x2v_dng_sequence_begin_prepacked(struct x2v_dng_sequence **,int directory_fd,
 const struct x2v_dng_layout *,uint64_t session_key);
int x2v_dng_sequence_put_prepacked(struct x2v_dng_sequence *,
 struct x2v_dng_prepacked_slot *,const struct x2v_dng_ticket *,
 const struct x2v_dng_frame_time *,struct x2v_dng_result *);
int x2v_dng_sequence_put_prepacked_metadata(struct x2v_dng_sequence *,
 struct x2v_dng_prepacked_slot *,const struct x2v_dng_ticket *,
 const struct x2v_dng_frame_time *,struct x2v_dng_result *,const struct xmd_record *);
void x2v_dng_sequence_request_stop(struct x2v_dng_sequence *);
int x2v_dng_sequence_finish(struct x2v_dng_sequence **,struct x2v_dng_finish *);
#endif
