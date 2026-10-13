#ifndef X2V_RECEIVER_H
#define X2V_RECEIVER_H
#include <stddef.h>
#include <stdint.h>
#include "metadata_sample.h"
enum { X2V_RX_OFF, X2V_RX_ARMED, X2V_RX_COPYING, X2V_RX_READY,
       X2V_RX_WRITING, X2V_RX_DONE, X2V_RX_ERROR, X2V_RX_CANCELLED,
       X2V_RX_WAIT };
enum { X2V_STOP_NONE, X2V_STOP_DURATION, X2V_STOP_FRAME_CAP,
       X2V_STOP_CANCEL, X2V_STOP_EXPIRED, X2V_STOP_ERROR, X2V_STOP_USER };
#define X2V_RING_SLOTS 3U
#define X2V_MAX_FRAMES 240U
#define X2V_ADMISSION_NS UINT64_C(10000000000)
/* Reservation belongs to exactly one synchronous callback. No native pointer
 * is stored. Reserve BEFORE get_size/map; finish after every successful map's
 * unmap, including error. Never reuse or finish a ticket twice. */
struct x2v_receiver;
struct x2v_receiver *x2v_receiver_new(uint64_t generation,uint64_t deadline_ms);
struct x2v_ticket { struct x2v_receiver *owner; uint64_t clip_generation; unsigned slot,index; uint64_t generation; };
int x2v_receiver_reserve(struct x2v_receiver *ctx,uint32_t id,uint64_t timestamp,struct x2v_ticket *);
int x2v_receiver_note_native_metadata(struct x2v_receiver *,const struct x2v_ticket *,const struct xmd_snapshot *);
void x2v_receiver_note_mapping(struct x2v_receiver *ctx,const struct x2v_ticket *,int,uint32_t,int,int);
int x2v_receiver_copy_reserved(struct x2v_receiver *ctx,const struct x2v_ticket *,const void *,size_t);
void x2v_receiver_finish_reserved(struct x2v_receiver *ctx,const struct x2v_ticket *,int error);
int x2v_receiver_prepare_normal(struct x2v_receiver *ctx,int output_fd);
int x2v_receiver_activate(struct x2v_receiver *ctx);
int x2v_receiver_capture_armed(struct x2v_receiver *ctx);
/* S finishes existing reservations; D aborts and cannot publish a clip. */
int x2v_receiver_stop(struct x2v_receiver *ctx);
void x2v_receiver_abort(struct x2v_receiver *ctx);
void x2v_receiver_disarm(struct x2v_receiver *ctx);
void x2v_receiver_poll(struct x2v_receiver *ctx);
int x2v_receiver_drain(struct x2v_receiver *ctx,unsigned deadline_ms);
int x2v_receiver_cpu_drained(struct x2v_receiver *ctx);
int x2v_receiver_status(struct x2v_receiver *ctx,int *,uint32_t *,uint64_t *);
uint64_t x2v_receiver_millis(void);
void x2v_receiver_set_deadline(struct x2v_receiver *ctx,uint64_t absolute_monotonic_ms);
int x2v_receiver_sequence_error(struct x2v_receiver *ctx);
int x2v_receiver_expired(struct x2v_receiver *ctx);
int x2v_receiver_capture_success(struct x2v_receiver *ctx);
size_t x2v_receiver_sequence_json(struct x2v_receiver *ctx,char *,size_t);
#endif
