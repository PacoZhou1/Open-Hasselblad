#ifndef X2V_DNG_PREPACKED_H
#define X2V_DNG_PREPACKED_H
#include "frame_writer.h"
#include <stdatomic.h>
#include <stddef.h>
#include <stdint.h>
#define X2V_DNG_WIDTH 3920u
#define X2V_DNG_HEIGHT 2946u
#define X2V_DNG_STRIDE 7936u
#define X2V_DNG_SPAN 23379456u
#define X2V_DNG_PIXEL_BYTES 23096640u
#define X2V_DNG_HEADER_BYTES 4096u
#define X2V_DNG_FILE_BYTES 23100928u
#define X2V_DNG_SLOT_STRIDE 23101440u
#define X2V_DNG_POOL_BYTES 69304320u
#define X2V_DNG_MAX_FRAMES 240u
enum x2v_dng_slot_state {X2V_DNG_SLOT_FREE=0,X2V_DNG_SLOT_PREPARING=1,
 X2V_DNG_SLOT_READY=2,X2V_DNG_SLOT_WRITING=3,X2V_DNG_SLOT_FAILED=4};
/* Init on coordinator/main before any callback, then immutable until ALL
 * prepare/put/stop callers quiesce. Carries no mutable writer/session fields. */
struct x2v_dng_layout {_Alignas(4096) unsigned char header[4096];uint64_t header_checksum;uint32_t validated;};
struct x2v_dng_ticket {uint64_t session,generation;};
/* Caller owns struct+allocation. Zero-init before slot_init; no reinit while
 * any prepare/put touches it. One prepare/put per slot, different slots MAY
 * run on callback/writer threads concurrently with one immutable layout. */
struct x2v_dng_prepacked_slot {
 unsigned char *data;size_t span;const struct x2v_dng_layout *layout;
 _Atomic int state;struct x2v_dng_ticket ticket;uint32_t initialized;
};
struct x2v_dng_frame_time {uint32_t source_id;uint64_t native_timestamp_raw,cpu_admission_ns;};
struct x2v_dng_result {uint32_t index,source_id;uint64_t file_bytes,pixel_bytes,wall_begin_ns,wall_end_ns;int published,file_synced;};
struct x2v_dng_finish {uint32_t published_frames;int error,manifest_published,directory_synced,cpu_released,close_error;};
struct x2v_dng_sequence;
/* Explicit profile only; acknowledgement_provisional must1 and model contains
 * UNCALIBRATED. Builds exact baseline header and binds pinned libc memcpy,
 * never runs in borrowed callback. No vendor API. */
int x2v_dng_layout_init(struct x2v_dng_layout *,const struct dng_frame_profile *,
                        int acknowledge_provisional);
/* CPU base4096 aligned, span FILE_BYTES..SLOT_STRIDE. Header/tail preset.
 * Extra512 pool bytes beyond FILE_BYTES are NEVER sent to output. */
int x2v_dng_prepacked_slot_init(struct x2v_dng_prepacked_slot *,
 const struct x2v_dng_layout *,void *data,size_t span);
/* Callback-safe CPU path: no writer context, syscall, loader, stdio or native
 * object. Only immutable layout, owned slot atomic state, source span and
 * cached Bionic memcpy. External RX reservation/lifetime gates remain required.
 * ticket session/generation are immutable values from RX reservation.
 * READY is internal CPU completion; RX must finish HAL unmap before its own outer SLOT_READY/publication.
 * Writer may run while original callback remains active; outer control must
 * retain hook lease until original returns and wait lease0 before pool/ctx free. */
int x2v_dng_prepare_prepacked(struct x2v_dng_prepacked_slot *,
 const void *source,size_t source_span,const struct x2v_dng_ticket *);
/* One CPU writer only. begin dup retains caller's unique directory FD.
 * session_key nonzero distinguishes each resident clip. Only immutable header
 * copied from layout; prepare never reads this mutable context. */
int x2v_dng_sequence_begin_prepacked(struct x2v_dng_sequence **,int directory_fd,
 const struct x2v_dng_layout *,uint64_t session_key);
/* Matches exact ticket/session, READY + immutable header, requires DIRECT512,
 * one normal large pwrite(FILE_BYTES), no image copy. Bounded32 short attempts.
 * Slot stays read-only WRITING until IO/close/publish/manifest completed. */
int x2v_dng_sequence_put_prepacked(struct x2v_dng_sequence *,
 struct x2v_dng_prepacked_slot *,const struct x2v_dng_ticket *,
 const struct x2v_dng_frame_time *,struct x2v_dng_result *);
/* Do NOT call request_stop before draining already-admitted RX slots.
 * Caller ensures context remains alive while this function runs. */
void x2v_dng_sequence_request_stop(struct x2v_dng_sequence *);
/* One writer/retired owner only; no concurrent prepare/put/stop using this
 * context/layout. Frees backend context, NOT caller slot or native buffers.
 * cpu_released means context free; close_error/error independently matter. */
int x2v_dng_sequence_finish(struct x2v_dng_sequence **,struct x2v_dng_finish *);
#endif
