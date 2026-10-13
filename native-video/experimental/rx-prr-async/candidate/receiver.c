#define _GNU_SOURCE 1
#include "receiver.h"
#include "shape.h"
#include "copy_provider.h"
#include "io_provider.h"
#include "dng_prepacked.h"
#include "profile_provisional.h"
#include "metadata_record.h"
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <stdio.h>
#define SOURCE_BYTES ((size_t)X2V_BYTES)
#define FRAME_BYTES ((size_t)X2V_DNG_FILE_BYTES)
#define SLOT_PITCH ((size_t)X2V_DNG_SLOT_STRIDE)
#define POOL_BYTES ((size_t)X2V_DNG_POOL_BYTES)
#define TOTAL_BYTES ((uint64_t)FRAME_BYTES*X2V_MAX_FRAMES)
_Static_assert(X2V_BYTES==X2V_DNG_SPAN,"native source span unchanged");
_Static_assert(POOL_BYTES==SLOT_PITCH*X2V_RING_SLOTS,"aligned three-slot pool");
_Static_assert(sizeof(off_t)==8,"Bionic AArch64 pwrite64 off_t");
_Static_assert(X2V_MAX_FRAMES<=UINT64_MAX/X2V_BYTES,"payload multiplication");
_Static_assert(UINT64_C(5611069440)<INT64_MAX,"signed pwrite offset range");
enum { SLOT_FREE,SLOT_COPYING,SLOT_READY,SLOT_WRITING };
struct record {
 struct xmd_record native_metadata; /* immutable after outer copied release */
 _Atomic uint32_t id; _Atomic uint64_t stamp,generation,admission,copy_begin,copy_end,write_begin,write_end;
 _Atomic unsigned slot,bytes,written,submitted,cpu_valid,cpu_wall_consistent,src_mod64,dst_mod64,mem_flags;
 _Atomic uint64_t cpu_begin,cpu_end,write_cpu_begin,write_cpu_end,write_offset,pwrite_begin,pwrite_end,complete_begin,complete_end;
 _Atomic unsigned write_cpu_valid,write_cpu_consistent,write_src512,write_src4096,write_calls;
 _Atomic int mem_flags_rc,mem_fd_rc,mem_fd;
};
#define ADMISSION_CLOSED 0x80000000U
struct x2v_receiver {
 uint64_t clip_generation;
 struct x2v_dng_layout dng_layout;
 struct x2v_dng_prepacked_slot dng_slots[X2V_RING_SLOTS];
 struct x2v_dng_sequence *dng;
 struct x2v_dng_finish dng_finish;
 _Atomic unsigned dng_published,dng_manifest,dng_directory,dng_released;
 _Atomic int dng_error,dng_close_error;
struct record records[X2V_MAX_FRAMES];
_Atomic unsigned slot_state[X2V_RING_SLOTS];
_Atomic uint64_t generations[X2V_RING_SLOTS];
_Atomic int state,failure,sequence_error,cpu_drained,lifecycle_failure,stop_reason;
_Atomic unsigned admission_gate;
_Atomic unsigned copy_active,cancel_requested,abort_requested,capture_armed,reserved,copied,written,submitted,writer_exited,expired,admission_closed,drop_full,drop_busy,fsync_ok;
_Atomic uint64_t bytes_written,arm_ns,admission_deadline_ns,closed_ns,writer_done_ns;
uint64_t deadline_ns,constructor_start_ns,prefault_bytes;
uint8_t *cpu_copy;int out_fd,thread_exists;pthread_t io_thread;
int writer_flags_before,writer_flags_active;
uintptr_t cpu_pool_mod4096;
_Atomic uint64_t fsync_wall_begin,fsync_wall_end,fsync_cpu_begin,fsync_cpu_end;
_Atomic unsigned fsync_clock_valid,fsync_cpu_consistent;
};
static int thread_clock(uint64_t*);
static uint64_t monotonic_ns(void){struct timespec t;if(clock_gettime(CLOCK_MONOTONIC,&t))return 0;return (uint64_t)t.tv_sec*1000000000+(uint64_t)t.tv_nsec;}
uint64_t x2v_receiver_millis(void){return monotonic_ns()/1000000;}
void x2v_receiver_set_deadline(struct x2v_receiver *ctx,uint64_t v){ctx->constructor_start_ns=monotonic_ns();ctx->deadline_ns=v*1000000;}
static void close_admission(struct x2v_receiver *ctx,int reason){
 atomic_fetch_or_explicit(&ctx->admission_gate,ADMISSION_CLOSED,memory_order_acq_rel);
 int unset=0;atomic_compare_exchange_strong(&ctx->stop_reason,&unset,reason);
 if(reason==X2V_STOP_EXPIRED){atomic_store(&ctx->expired,1);atomic_store(&ctx->stop_reason,reason);}
 if(reason==X2V_STOP_ERROR)atomic_store(&ctx->stop_reason,reason);
 unsigned open=0;if(atomic_compare_exchange_strong(&ctx->admission_closed,&open,2)){uint64_t now=monotonic_ns();atomic_store(&ctx->closed_ns,now);if(!now){atomic_store(&ctx->failure,EIO);atomic_store(&ctx->stop_reason,X2V_STOP_ERROR);reason=X2V_STOP_ERROR;}atomic_store_explicit(&ctx->admission_closed,1,memory_order_release);}
 int s=atomic_load(&ctx->state),next=reason==X2V_STOP_ERROR?X2V_RX_ERROR:
  reason==X2V_STOP_DURATION||reason==X2V_STOP_FRAME_CAP||reason==X2V_STOP_USER?X2V_RX_READY:X2V_RX_CANCELLED;
 while(s==X2V_RX_WAIT||s==X2V_RX_ARMED){if(atomic_compare_exchange_weak(&ctx->state,&s,next))break;}
}
static int check_time(struct x2v_receiver *ctx){
 uint64_t now=monotonic_ns();if(!now){atomic_store(&ctx->failure,EIO);close_admission(ctx,X2V_STOP_ERROR);return EIO;}
 if(!ctx->deadline_ns||now>=ctx->deadline_ns){close_admission(ctx,X2V_STOP_EXPIRED);return ETIMEDOUT;}
 uint64_t end=atomic_load(&ctx->admission_deadline_ns);
 if(end&&now>=end){close_admission(ctx,X2V_STOP_DURATION);return EAGAIN;}return 0;
}
void x2v_receiver_poll(struct x2v_receiver *ctx){(void)check_time(ctx);}
static void capture_error(struct x2v_receiver *ctx,int e){if(e){atomic_store(&ctx->failure,e);atomic_store(&ctx->state,X2V_RX_ERROR);close_admission(ctx,X2V_STOP_ERROR);}}
static void mark_durable(struct x2v_receiver *ctx,uint32_t index,uint64_t c0,uint64_t c1,uint64_t file_bytes){
 if(index>=X2V_MAX_FRAMES)return;struct record *pr=&ctx->records[index];unsigned expect=0;
 if(atomic_compare_exchange_strong(&pr->written,&expect,1)){atomic_fetch_add(&ctx->written,1);atomic_fetch_add(&ctx->bytes_written,file_bytes);}
 atomic_store(&pr->complete_begin,c0);atomic_store(&pr->complete_end,c1);
}
#ifndef X2V_WRITER_EMPTY_WINDOW
#define X2V_WRITER_EMPTY_WINDOW() ((void)0)
#endif
static void *write_body(struct x2v_receiver *ctx){
 unsigned next=0;
 for(;;){
  unsigned n=atomic_load_explicit(&ctx->copied,memory_order_acquire);
  if(next>=n){
   if(atomic_load(&ctx->failure)||atomic_load(&ctx->sequence_error))break;
   X2V_WRITER_EMPTY_WINDOW();
   if(atomic_load_explicit(&ctx->admission_closed,memory_order_acquire)==1&&!atomic_load_explicit(&ctx->copy_active,memory_order_acquire)){
    /* Acquire after admission closure/copy release: the previous n snapshot
     * can predate final READY publication. Never skip that last record. */
    unsigned fresh=atomic_load_explicit(&ctx->copied,memory_order_acquire);if(next>=fresh)break;else continue;
   }
   usleep(1000);continue;
  }
  struct record *r=&ctx->records[next];unsigned k=atomic_load(&r->slot);
  uint64_t g=atomic_load(&r->generation);unsigned ready=SLOT_READY;
  if(k>=X2V_RING_SLOTS||atomic_load(&ctx->generations[k])!=g||!atomic_compare_exchange_strong(&ctx->slot_state[k],&ready,SLOT_WRITING)){capture_error(ctx,EILSEQ);break;}
  uint64_t now=monotonic_ns(),cb=0,ce=0;if(!now){capture_error(ctx,EIO);break;}atomic_store(&r->write_begin,now);
  atomic_store(&r->write_src512,(uintptr_t)(ctx->cpu_copy+k*SLOT_PITCH)%512);
  atomic_store(&r->write_src4096,(uintptr_t)(ctx->cpu_copy+k*SLOT_PITCH)%4096);
  if(thread_clock(&cb)){capture_error(ctx,EIO);break;}atomic_store(&r->write_cpu_begin,cb);
  const struct x2v_dng_ticket ticket={ctx->clip_generation,g};
  const struct x2v_dng_frame_time frame_time={atomic_load(&r->id),atomic_load(&r->stamp),atomic_load(&r->admission)};
  struct x2v_dng_result result={0};
  int de=x2v_dng_sequence_put_prepacked_metadata(ctx->dng,&ctx->dng_slots[k],&ticket,&frame_time,&result,&r->native_metadata);
  if(de||!result.pwrite_complete||!result.publish_queued||!result.file_bytes||result.file_bytes>FRAME_BYTES||result.pixel_bytes!=X2V_DNG_PIXEL_BYTES){capture_error(ctx,de?de:EIO);break;}
  atomic_store(&r->write_offset,result.mov_offset);
  atomic_store(&r->bytes,(unsigned)result.file_bytes);
  if(result.previous_published)mark_durable(ctx,result.previous_index,result.previous_complete_begin_ns,result.previous_complete_end_ns,atomic_load(&ctx->records[result.previous_index].bytes));
  if(result.published)mark_durable(ctx,result.index,result.complete_begin_ns,result.complete_end_ns,result.file_bytes);
  atomic_store(&r->pwrite_begin,result.pwrite_begin_ns);atomic_store(&r->pwrite_end,result.pwrite_end_ns);
  if(thread_clock(&ce)){capture_error(ctx,EIO);break;}atomic_store(&r->write_cpu_end,ce);
  now=monotonic_ns();if(!now){capture_error(ctx,EIO);break;}atomic_store(&r->write_end,now);
  if(ce<cb||now<atomic_load(&r->write_begin)){capture_error(ctx,EILSEQ);break;}
  atomic_store(&r->write_cpu_valid,1);atomic_store(&r->write_cpu_consistent,ce-cb<=now-atomic_load(&r->write_begin));
  atomic_store_explicit(&r->submitted,1,memory_order_release);atomic_fetch_add(&ctx->submitted,1);
  /* All immutable ledger fields persist beyond this release; next callback
   * cannot overwrite them when reusing the payload slot. */
  atomic_store_explicit(&ctx->slot_state[k],SLOT_FREE,memory_order_release);next++;
 }
 return NULL;
}
int x2v_receiver_capture_success(struct x2v_receiver *ctx){
 unsigned n=atomic_load(&ctx->copied);int reason=atomic_load(&ctx->stop_reason);
 return n>=2&&n<=X2V_MAX_FRAMES&&atomic_load(&ctx->reserved)==n&&atomic_load(&ctx->submitted)==n&&atomic_load(&ctx->written)==n&&
  atomic_load(&ctx->bytes_written)>0&&atomic_load(&ctx->bytes_written)<=(uint64_t)n*FRAME_BYTES&&atomic_load(&ctx->fsync_ok)&&atomic_load(&ctx->fsync_clock_valid)&&
  x2v_writer_provider_pinned()&&atomic_load(&ctx->dng_published)==n&&
  atomic_load(&ctx->dng_manifest)&&atomic_load(&ctx->dng_directory)&&atomic_load(&ctx->dng_released)&&
  !atomic_load(&ctx->dng_error)&&!atomic_load(&ctx->dng_close_error)&&
  !atomic_load(&ctx->failure)&&!atomic_load(&ctx->sequence_error)&&!atomic_load(&ctx->expired)&&!atomic_load(&ctx->abort_requested)&&
  (reason==X2V_STOP_DURATION||reason==X2V_STOP_FRAME_CAP||reason==X2V_STOP_USER);
}
static void *writer(void *argument){
 struct x2v_receiver *ctx=argument;void*p=write_body(ctx);while(atomic_load_explicit(&ctx->copy_active,memory_order_acquire)||atomic_load_explicit(&ctx->admission_closed,memory_order_acquire)==2)usleep(1000);
 /* Callback-side prepare has quiesced; only this writer finalizes backend. */
 if(ctx->dng){
  uint64_t wb=monotonic_ns(),cb=0,ce=0,we=0;
  int e=thread_clock(&cb);atomic_store(&ctx->fsync_wall_begin,wb);atomic_store(&ctx->fsync_cpu_begin,cb);
  int de=x2v_dng_sequence_finish(&ctx->dng,&ctx->dng_finish);
  atomic_store(&ctx->dng_published,ctx->dng_finish.published_frames);
  atomic_store(&ctx->dng_manifest,ctx->dng_finish.manifest_published);
  atomic_store(&ctx->dng_directory,ctx->dng_finish.directory_synced);
  atomic_store(&ctx->dng_released,ctx->dng_finish.cpu_released);
  atomic_store(&ctx->dng_error,ctx->dng_finish.error);
  atomic_store(&ctx->dng_close_error,ctx->dng_finish.close_error);
  int clock_error=thread_clock(&ce);we=monotonic_ns();
  atomic_store(&ctx->fsync_wall_end,we);atomic_store(&ctx->fsync_cpu_end,ce);
  if(e||clock_error||!wb||!we||we<wb||ce<cb)capture_error(ctx,EIO);
  else{atomic_store(&ctx->fsync_clock_valid,1);atomic_store(&ctx->fsync_cpu_consistent,ce-cb<=we-wb);}
  if(ctx->dng_finish.join_failed||!ctx->dng_finish.cpu_released)capture_error(ctx,de?de:EAGAIN);
  else if(de||ctx->dng_finish.error||ctx->dng_finish.close_error)capture_error(ctx,de?de:ctx->dng_finish.error?ctx->dng_finish.error:ctx->dng_finish.close_error);
  else if(ctx->dng_finish.published_frames!=atomic_load(&ctx->submitted))capture_error(ctx,EIO);
  else{
   if(ctx->dng_finish.last_published)mark_durable(ctx,ctx->dng_finish.last_index,ctx->dng_finish.last_complete_begin_ns,ctx->dng_finish.last_complete_end_ns,atomic_load(&ctx->records[ctx->dng_finish.last_index].bytes));
   unsigned i,sub=atomic_load(&ctx->submitted);
   for(i=0;i<sub;i++)if(!atomic_load(&ctx->records[i].written)){capture_error(ctx,EIO);break;}
   if(i==sub&&ctx->dng_finish.manifest_published&&ctx->dng_finish.directory_synced&&ctx->dng_finish.cpu_released)atomic_store(&ctx->fsync_ok,1);
  }
 }
 int end=atomic_load(&ctx->failure)||atomic_load(&ctx->sequence_error)?X2V_RX_ERROR:x2v_receiver_capture_success(ctx)?X2V_RX_DONE:X2V_RX_CANCELLED;
 uint64_t now=monotonic_ns();if(!now){capture_error(ctx,EIO);end=X2V_RX_ERROR;}atomic_store(&ctx->writer_done_ns,now);atomic_store(&ctx->state,end);atomic_store_explicit(&ctx->writer_exited,1,memory_order_release);return p;
}
int x2v_receiver_prepare_normal(struct x2v_receiver *ctx,int fd){
 if(atomic_load(&ctx->state)!=X2V_RX_OFF)return EBUSY;int e=check_time(ctx);if(e)return e;
 struct stat s;int fl=fcntl(fd,F_GETFL);
 if(fl<0||fstat(fd,&s)||!S_ISDIR(s.st_mode)||(fl&O_ACCMODE)!=O_RDONLY||(fl&(O_APPEND|O_DIRECT|O_DSYNC|O_SYNC)))return EINVAL;
 ctx->writer_flags_before=ctx->writer_flags_active=fl; /* directory flags only */
 e=x2v_dng_layout_init(&ctx->dng_layout,&provisional_profile,1);if(e)return e;
 int allocation=posix_memalign((void**)&ctx->cpu_copy,4096,POOL_BYTES);if(allocation)return allocation;
 ctx->cpu_pool_mod4096=(uintptr_t)ctx->cpu_copy%4096;
 for(size_t p=0;p<POOL_BYTES;p+=4096)((volatile uint8_t*)ctx->cpu_copy)[p]=0;
 ((volatile uint8_t*)ctx->cpu_copy)[POOL_BYTES-1]=0;ctx->prefault_bytes=POOL_BYTES;
 e=check_time(ctx);if(e)goto prepare_failed;
 for(unsigned k=0;k<X2V_RING_SLOTS;k++){
  e=x2v_dng_prepacked_slot_init(&ctx->dng_slots[k],&ctx->dng_layout,ctx->cpu_copy+k*SLOT_PITCH,SLOT_PITCH);
  if(e)goto prepare_failed;
 }
 ctx->out_fd=fcntl(fd,F_DUPFD_CLOEXEC,10);if(ctx->out_fd<0){e=errno;goto prepare_failed;}
 e=x2v_dng_sequence_begin_prepacked(&ctx->dng,ctx->out_fd,&ctx->dng_layout,ctx->clip_generation);if(e)goto prepare_failed;
 atomic_store(&ctx->state,X2V_RX_WAIT);e=pthread_create(&ctx->io_thread,NULL,writer,ctx);
 if(e){atomic_store(&ctx->state,X2V_RX_OFF);goto prepare_failed;}
 ctx->thread_exists=1;return 0;
prepare_failed:
 if(ctx->dng){int de=x2v_dng_sequence_finish(&ctx->dng,&ctx->dng_finish);if(de)atomic_store(&ctx->lifecycle_failure,de);}
 if(ctx->out_fd>=0&&close(ctx->out_fd))atomic_store(&ctx->lifecycle_failure,errno?errno:EIO);
 ctx->out_fd=-1;free(ctx->cpu_copy);ctx->cpu_copy=NULL;return e;
}

int x2v_receiver_activate(struct x2v_receiver *ctx){
 if(atomic_load(&ctx->cancel_requested)||atomic_load(&ctx->admission_closed))return ECANCELED;
 int e=check_time(ctx);if(e)return e;
 int s=X2V_RX_WAIT;
 /* Only control thread sends A. Publish clock before opening admission;
  * failed CAS does not reset clocks on repeated A. */
 if(atomic_load(&ctx->capture_armed))return 0;
 uint64_t now=monotonic_ns();if(!now)return EIO;
 atomic_store(&ctx->arm_ns,now);uint64_t end=now+X2V_ADMISSION_NS;atomic_store(&ctx->admission_deadline_ns,end<ctx->deadline_ns?end:ctx->deadline_ns);
 if(atomic_compare_exchange_strong(&ctx->state,&s,X2V_RX_ARMED)){atomic_store(&ctx->capture_armed,1);return 0;}
 return atomic_load(&ctx->cancel_requested)||atomic_load(&ctx->admission_closed)?ECANCELED:EBUSY;
}
int x2v_receiver_capture_armed(struct x2v_receiver *ctx){return atomic_load(&ctx->capture_armed);}
int x2v_receiver_reserve(struct x2v_receiver *ctx,uint32_t id,uint64_t stamp,struct x2v_ticket*t){
 if(!t)return EINVAL;
 int initial=atomic_load(&ctx->state);
 if(atomic_load(&ctx->admission_closed)||atomic_load(&ctx->cancel_requested))return EAGAIN;
 if(initial==X2V_RX_COPYING){atomic_fetch_add(&ctx->drop_busy,1);return EAGAIN;}
 if(initial!=X2V_RX_ARMED)return EAGAIN;
 uint64_t admission=monotonic_ns();if(!admission){capture_error(ctx,EIO);return EIO;}
 unsigned gate=0;if(!atomic_compare_exchange_strong(&ctx->admission_gate,&gate,1)){if(!(gate&ADMISSION_CLOSED))atomic_fetch_add(&ctx->drop_busy,1);return EAGAIN;}
 unsigned idle=0;if(!atomic_compare_exchange_strong(&ctx->copy_active,&idle,1)){atomic_fetch_and(&ctx->admission_gate,ADMISSION_CLOSED);atomic_fetch_add(&ctx->drop_busy,1);return EAGAIN;}
 int s=X2V_RX_ARMED;if(!atomic_compare_exchange_strong(&ctx->state,&s,X2V_RX_COPYING)){atomic_store_explicit(&ctx->copy_active,0,memory_order_release);atomic_fetch_and(&ctx->admission_gate,ADMISSION_CLOSED);return EAGAIN;}
 int e=0;if(atomic_load(&ctx->cancel_requested)||atomic_load(&ctx->admission_closed))e=EAGAIN;
 if(!e&&(atomic_load(&ctx->failure)||atomic_load(&ctx->sequence_error)))e=atomic_load(&ctx->failure)?atomic_load(&ctx->failure):atomic_load(&ctx->sequence_error);
 if(!e)e=check_time(ctx);unsigned n=atomic_load(&ctx->reserved),k=X2V_RING_SLOTS;
 if(!e&&n>=X2V_MAX_FRAMES){close_admission(ctx,X2V_STOP_FRAME_CAP);e=EAGAIN;}
 if(!e&&(!id||!stamp||(n&&(id<=atomic_load(&ctx->records[n-1].id)||stamp<=atomic_load(&ctx->records[n-1].stamp))))){e=EILSEQ;atomic_store(&ctx->sequence_error,e);capture_error(ctx,e);}
 if(!e){for(unsigned i=0;i<X2V_RING_SLOTS;i++){unsigned f=SLOT_FREE;if(atomic_compare_exchange_strong(&ctx->slot_state[i],&f,SLOT_COPYING)){k=i;break;}}if(k==X2V_RING_SLOTS){atomic_fetch_add(&ctx->drop_full,1);e=EAGAIN;}}
 if(e){int c=X2V_RX_COPYING;atomic_compare_exchange_strong(&ctx->state,&c,atomic_load(&ctx->admission_closed)?X2V_RX_READY:X2V_RX_ARMED);atomic_store_explicit(&ctx->copy_active,0,memory_order_release);atomic_fetch_and(&ctx->admission_gate,ADMISSION_CLOSED);return e;}
 /* Admission linearizes under held copy claim before native map. D afterward
  * closes later claims but this existing borrowed transaction may finish. */
 uint64_t now=monotonic_ns();if(!now){atomic_store(&ctx->slot_state[k],SLOT_FREE);capture_error(ctx,EIO);atomic_store_explicit(&ctx->copy_active,0,memory_order_release);atomic_fetch_and(&ctx->admission_gate,ADMISSION_CLOSED);return EIO;}
 if(now>=ctx->deadline_ns||now>=atomic_load(&ctx->admission_deadline_ns)||atomic_load(&ctx->admission_closed)||atomic_load(&ctx->cancel_requested)){atomic_store(&ctx->slot_state[k],SLOT_FREE);int time_error=check_time(ctx);if(!time_error)time_error=EAGAIN;int c=X2V_RX_COPYING;atomic_compare_exchange_strong(&ctx->state,&c,X2V_RX_READY);atomic_store(&ctx->copy_active,0);atomic_fetch_and(&ctx->admission_gate,ADMISSION_CLOSED);return time_error;}
 t->owner=ctx;t->clip_generation=ctx->clip_generation;t->slot=k;t->index=n;t->generation=atomic_fetch_add(&ctx->generations[k],1)+1;
 struct record*r=&ctx->records[n];atomic_store(&r->id,id);atomic_store(&r->stamp,stamp);atomic_store(&r->slot,k);atomic_store(&r->generation,t->generation);atomic_store(&r->admission,admission);
 atomic_store_explicit(&ctx->reserved,n+1,memory_order_release);return 0;
}
static int ticket_valid(struct x2v_receiver *ctx,const struct x2v_ticket*t){return t&&t->owner==ctx&&t->clip_generation==ctx->clip_generation&&t->slot<X2V_RING_SLOTS&&t->index<X2V_MAX_FRAMES&&atomic_load(&ctx->copy_active)&&atomic_load(&ctx->generations[t->slot])==t->generation&&atomic_load(&ctx->slot_state[t->slot])==SLOT_COPYING&&atomic_load(&ctx->records[t->index].generation)==t->generation;}
int x2v_receiver_note_native_metadata(struct x2v_receiver *ctx,const struct x2v_ticket*t,const struct xmd_snapshot *snapshot){
 if(!ticket_valid(ctx,t))return EINVAL;
 struct record*r=&ctx->records[t->index];
 return xmd_record_store(&r->native_metadata,t->clip_generation,t->generation,t->index,atomic_load(&r->id),atomic_load(&r->stamp),snapshot);
}
void x2v_receiver_note_mapping(struct x2v_receiver *ctx,const struct x2v_ticket*t,int flags_rc,uint32_t flags,int fd_rc,int fd){
 if(!ticket_valid(ctx,t)){capture_error(ctx,EINVAL);return;}struct record*r=&ctx->records[t->index];atomic_store(&r->mem_flags_rc,flags_rc);atomic_store(&r->mem_flags,flags);atomic_store(&r->mem_fd_rc,fd_rc);atomic_store(&r->mem_fd,fd);
}
static int thread_clock(uint64_t*out){struct timespec t;if(clock_gettime(CLOCK_THREAD_CPUTIME_ID,&t))return EIO;*out=(uint64_t)t.tv_sec*1000000000+(uint64_t)t.tv_nsec;return *out?0:EIO;}
int x2v_receiver_copy_reserved(struct x2v_receiver *ctx,const struct x2v_ticket*t,const void*p,size_t n){
 if(!ticket_valid(ctx,t)||!p||n!=SOURCE_BYTES)return EINVAL;
 uint64_t now=monotonic_ns();if(!now)return EIO;atomic_store(&ctx->records[t->index].copy_begin,now);
 struct record*r=&ctx->records[t->index];void*dst=ctx->cpu_copy+t->slot*SLOT_PITCH;atomic_store(&r->src_mod64,(uintptr_t)p%64);atomic_store(&r->dst_mod64,(uintptr_t)dst%64);
 uint64_t cpu_begin=0,cpu_end=0;int e=thread_clock(&cpu_begin);if(e)return e;atomic_store(&r->cpu_begin,cpu_begin);
 const struct x2v_dng_ticket dt={ctx->clip_generation,t->generation};
 e=x2v_dng_prepare_prepacked(&ctx->dng_slots[t->slot],p,n,&dt);if(e)return e; e=thread_clock(&cpu_end);if(e)return e;atomic_store(&r->cpu_end,cpu_end);
 now=monotonic_ns();if(!now)return EIO;atomic_store(&r->copy_end,now);
 if(cpu_end<cpu_begin||now<atomic_load(&r->copy_begin))return EILSEQ;
 atomic_store(&r->cpu_wall_consistent,cpu_end-cpu_begin<=now-atomic_load(&r->copy_begin));
 atomic_store(&r->cpu_valid,1);return 0;
}
void x2v_receiver_finish_reserved(struct x2v_receiver *ctx,const struct x2v_ticket*t,int e){
 if(!ticket_valid(ctx,t)){capture_error(ctx,EINVAL);return;}
 struct record*r=&ctx->records[t->index];
 if(!e&&!atomic_load(&r->copy_end))e=EINVAL;
 if(!e)e=xmd_record_matches(&r->native_metadata,t->clip_generation,t->generation,t->index,atomic_load(&r->id),atomic_load(&r->stamp));
 if(e){capture_error(ctx,e);/* Failed reservation retains quota; never published. */}
 else{
  atomic_store_explicit(&ctx->slot_state[t->slot],SLOT_READY,memory_order_release);
  atomic_store_explicit(&ctx->copied,t->index+1,memory_order_release);
  if(t->index+1==X2V_MAX_FRAMES)close_admission(ctx,X2V_STOP_FRAME_CAP);
 }
 int next=atomic_load(&ctx->failure)||atomic_load(&ctx->sequence_error)?X2V_RX_ERROR:atomic_load(&ctx->admission_closed)?X2V_RX_READY:X2V_RX_ARMED;
 int c=X2V_RX_COPYING;atomic_compare_exchange_strong(&ctx->state,&c,next);
 if(atomic_load(&ctx->failure)||atomic_load(&ctx->sequence_error))atomic_store(&ctx->state,X2V_RX_ERROR);
 else if(atomic_load(&ctx->cancel_requested)||atomic_load(&ctx->admission_closed)){int a=X2V_RX_ARMED;atomic_compare_exchange_strong(&ctx->state,&a,X2V_RX_READY);}
 atomic_store_explicit(&ctx->copy_active,0,memory_order_release);atomic_fetch_and(&ctx->admission_gate,ADMISSION_CLOSED);
}
/* Called by the single command consumer. Admission closure excludes new
 * reservations while an already borrowed native buffer finishes normally. */
int x2v_receiver_stop(struct x2v_receiver *ctx){
 if(!atomic_load(&ctx->capture_armed))return EINVAL;
 if(atomic_load(&ctx->abort_requested))return ECANCELED;
 int e=check_time(ctx);if(e&&e!=EAGAIN)return e;
 if(atomic_load(&ctx->failure)||atomic_load(&ctx->sequence_error))return EIO;
 close_admission(ctx,X2V_STOP_USER);return 0;
}
void x2v_receiver_abort(struct x2v_receiver *ctx){
 atomic_store(&ctx->abort_requested,1);x2v_receiver_disarm(ctx);
 /* Cancellation overrides a previously successful stop, but never hides
  * expiry or a data error. finish() uses disarm, not this abort operation. */
 int r=atomic_load(&ctx->stop_reason);
 while(r!=X2V_STOP_ERROR&&r!=X2V_STOP_EXPIRED&&r!=X2V_STOP_CANCEL){
  if(atomic_compare_exchange_weak(&ctx->stop_reason,&r,X2V_STOP_CANCEL))break;
 }
}
void x2v_receiver_disarm(struct x2v_receiver *ctx){atomic_store(&ctx->cancel_requested,1);close_admission(ctx,X2V_STOP_CANCEL);}
int x2v_receiver_drain(struct x2v_receiver *ctx,unsigned ms){
 if(ms>10000)return EINVAL;if(atomic_load(&ctx->lifecycle_failure))return atomic_load(&ctx->lifecycle_failure);
 uint64_t start=x2v_receiver_millis();if(!start)return EIO;
 for(;;){int s=atomic_load(&ctx->state);if(!atomic_load(&ctx->copy_active)&&(!ctx->thread_exists||atomic_load(&ctx->writer_exited))&&(s==0||s==5||s==6||s==7))break;
 uint64_t now=x2v_receiver_millis();if(!now)return EIO;if(now-start>=ms)return ETIMEDOUT;usleep(1000);}
 if(ctx->thread_exists){int e=pthread_join(ctx->io_thread,NULL);if(e)return e;ctx->thread_exists=0;}
 /* Completion join failure retains backend and CPU pool; no false CPU closure. */
 if(ctx->dng||ctx->dng_finish.join_failed)return EBUSY;
 int e=0;if(ctx->out_fd>=0){if(close(ctx->out_fd))e=errno;ctx->out_fd=-1;}free(ctx->cpu_copy);ctx->cpu_copy=NULL;
 if(e){atomic_store(&ctx->lifecycle_failure,e);return e;}atomic_store_explicit(&ctx->cpu_drained,1,memory_order_release);return 0;
}
int x2v_receiver_cpu_drained(struct x2v_receiver *ctx){return atomic_load(&ctx->cpu_drained);}
int x2v_receiver_status(struct x2v_receiver *ctx,int*e,uint32_t*id,uint64_t*stamp){unsigned n=atomic_load_explicit(&ctx->copied,memory_order_acquire);if(e)*e=atomic_load(&ctx->failure);if(n&&n<=X2V_MAX_FRAMES){if(id)*id=atomic_load(&ctx->records[n-1].id);if(stamp)*stamp=atomic_load(&ctx->records[n-1].stamp);}return atomic_load(&ctx->state);}
int x2v_receiver_sequence_error(struct x2v_receiver *ctx){return atomic_load(&ctx->sequence_error);}
int x2v_receiver_expired(struct x2v_receiver *ctx){return atomic_load(&ctx->expired);}
size_t x2v_receiver_sequence_json(struct x2v_receiver *ctx,char*out,size_t cap){
 int n=snprintf(out,cap,"\"storage_format\":\"PRORES_RAW_HQ_MOV\",\"source_frame_bytes\":23379456,\"pixel_bytes\":22643712,\"slot_stride\":23379968,\"max_frame_count\":240,\"expected_frame_bytes\":%u,\"slot_count\":3,\"frames_reserved\":%u,\"frames_copied\":%u,\"frames_submitted\":%u,\"frames_written\":%u,\"bytes_written\":%llu,\"copy_active\":%u,\"sequence_error\":%d,\"prefault_bytes\":%llu,\"capture_success\":%d,\"stop_reason\":%d,\"drop_full\":%u,\"drop_copy_busy\":%u,\"admission_closed\":%u,\"constructor_start_ns\":%llu,\"constructor_deadline_ns\":%llu,\"arm_ns\":%llu,\"admission_deadline_ns\":%llu,\"admission_closed_ns\":%llu,\"writer_done_ns\":%llu,\"fsync_ok\":%u,\"dng_published_frames\":%u,\"dng_manifest_published\":%u,\"dng_directory_synced\":%u,\"dng_context_released\":%u,\"dng_join_failed\":%d,\"dng_error\":%d,\"dng_close_error\":%d",X2V_DNG_FILE_BYTES,atomic_load(&ctx->reserved),atomic_load(&ctx->copied),atomic_load(&ctx->submitted),atomic_load(&ctx->written),(unsigned long long)atomic_load(&ctx->bytes_written),atomic_load(&ctx->copy_active),atomic_load(&ctx->sequence_error),(unsigned long long)ctx->prefault_bytes,x2v_receiver_capture_success(ctx),atomic_load(&ctx->stop_reason),atomic_load(&ctx->drop_full),atomic_load(&ctx->drop_busy),atomic_load(&ctx->admission_closed),(unsigned long long)ctx->constructor_start_ns,(unsigned long long)ctx->deadline_ns,(unsigned long long)atomic_load(&ctx->arm_ns),(unsigned long long)atomic_load(&ctx->admission_deadline_ns),(unsigned long long)atomic_load(&ctx->closed_ns),(unsigned long long)atomic_load(&ctx->writer_done_ns),atomic_load(&ctx->fsync_ok),atomic_load(&ctx->dng_published),atomic_load(&ctx->dng_manifest),atomic_load(&ctx->dng_directory),atomic_load(&ctx->dng_released),ctx->dng_finish.join_failed,atomic_load(&ctx->dng_error),atomic_load(&ctx->dng_close_error));
 if(n<0||(size_t)n>=cap)return 0;size_t pos=n;
 n=snprintf(out+pos,cap-pos,",\"writer_direct_required\":0,\"directory_flags_before\":%d,\"directory_flags_active\":%d,\"cpu_pool_mod4096\":%llu,\"writer_fsync_clock_valid\":%u,\"writer_fsync_cpu_wall_consistent\":%u,\"writer_fsync_wall_begin_ns\":%llu,\"writer_fsync_wall_end_ns\":%llu,\"writer_fsync_cpu_begin_ns\":%llu,\"writer_fsync_cpu_end_ns\":%llu",ctx->writer_flags_before,ctx->writer_flags_active,(unsigned long long)ctx->cpu_pool_mod4096,atomic_load(&ctx->fsync_clock_valid),atomic_load(&ctx->fsync_cpu_consistent),(unsigned long long)atomic_load(&ctx->fsync_wall_begin),(unsigned long long)atomic_load(&ctx->fsync_wall_end),(unsigned long long)atomic_load(&ctx->fsync_cpu_begin),(unsigned long long)atomic_load(&ctx->fsync_cpu_end));
 if(n<0||(size_t)n>=cap-pos)return 0;pos+=(size_t)n;
 for(unsigned i=0;i<X2V_MAX_FRAMES;i++){struct record*r=&ctx->records[i];
 n=snprintf(out+pos,cap-pos,",\"frame%u_id\":%u,\"frame%u_timestamp_native\":%llu,\"frame%u_bytes\":%u,\"frame%u_submitted\":%u,\"frame%u_written\":%u,\"frame%u_slot\":%u,\"frame%u_generation\":%llu,\"frame%u_admission_ns\":%llu,\"frame%u_copy_begin_ns\":%llu,\"frame%u_copy_end_ns\":%llu,\"frame%u_write_begin_ns\":%llu,\"frame%u_write_end_ns\":%llu,\"frame%u_pwrite_begin_ns\":%llu,\"frame%u_pwrite_end_ns\":%llu,\"frame%u_complete_begin_ns\":%llu,\"frame%u_complete_end_ns\":%llu",i,atomic_load(&r->id),i,(unsigned long long)atomic_load(&r->stamp),i,atomic_load(&r->bytes),i,atomic_load(&r->submitted),i,atomic_load(&r->written),i,atomic_load(&r->slot),i,(unsigned long long)atomic_load(&r->generation),i,(unsigned long long)atomic_load(&r->admission),i,(unsigned long long)atomic_load(&r->copy_begin),i,(unsigned long long)atomic_load(&r->copy_end),i,(unsigned long long)atomic_load(&r->write_begin),i,(unsigned long long)atomic_load(&r->write_end),i,(unsigned long long)atomic_load(&r->pwrite_begin),i,(unsigned long long)atomic_load(&r->pwrite_end),i,(unsigned long long)atomic_load(&r->complete_begin),i,(unsigned long long)atomic_load(&r->complete_end));
 if(n<0||(size_t)n>=cap-pos)return 0;pos+=(size_t)n;
 n=snprintf(out+pos,cap-pos,",\"frame%u_copy_cpu_clock_valid\":%u,\"frame%u_copy_cpu_wall_consistent\":%u,\"frame%u_copy_cpu_begin_ns\":%llu,\"frame%u_copy_cpu_end_ns\":%llu,\"frame%u_src_mod64\":%u,\"frame%u_dst_mod64\":%u,\"frame%u_mem_flags_rc\":%d,\"frame%u_mem_flags\":%u,\"frame%u_mem_fd_rc\":%d,\"frame%u_mem_fd\":%d",i,atomic_load(&r->cpu_valid),i,atomic_load(&r->cpu_wall_consistent),i,(unsigned long long)atomic_load(&r->cpu_begin),i,(unsigned long long)atomic_load(&r->cpu_end),i,atomic_load(&r->src_mod64),i,atomic_load(&r->dst_mod64),i,atomic_load(&r->mem_flags_rc),i,atomic_load(&r->mem_flags),i,atomic_load(&r->mem_fd_rc),i,atomic_load(&r->mem_fd));
 if(n<0||(size_t)n>=cap-pos)return 0;pos+=(size_t)n;
 n=snprintf(out+pos,cap-pos,",\"frame%u_write_cpu_clock_valid\":%u,\"frame%u_write_cpu_wall_consistent\":%u,\"frame%u_write_cpu_begin_ns\":%llu,\"frame%u_write_cpu_end_ns\":%llu,\"frame%u_write_src_mod512\":%u,\"frame%u_write_src_mod4096\":%u,\"frame%u_write_offset\":%llu",i,atomic_load(&r->write_cpu_valid),i,atomic_load(&r->write_cpu_consistent),i,(unsigned long long)atomic_load(&r->write_cpu_begin),i,(unsigned long long)atomic_load(&r->write_cpu_end),i,atomic_load(&r->write_src512),i,atomic_load(&r->write_src4096),i,(unsigned long long)atomic_load(&r->write_offset));
 if(n<0||(size_t)n>=cap-pos)return 0;pos+=(size_t)n;}return pos;
}

/* Stable metadata until source-owner exit. Each clip has a new context. */
struct x2v_receiver *x2v_receiver_new(uint64_t generation,uint64_t deadline_ms){
 if(!generation||!deadline_ms)return NULL;
 /* Fixed two-clip proof: shells never reuse addresses during source life. */
 static struct x2v_receiver metadata[2];static unsigned used;
 if(used>=2||generation!=(uint64_t)used+1)return NULL;
 struct x2v_receiver *ctx=&metadata[used++];
 for(unsigned i=0;i<X2V_MAX_FRAMES;i++){
 memset(&ctx->records[i].native_metadata,0,sizeof ctx->records[i].native_metadata);
 atomic_init(&ctx->records[i].id,0);
 atomic_init(&ctx->records[i].stamp,0);
 atomic_init(&ctx->records[i].generation,0);
 atomic_init(&ctx->records[i].admission,0);
 atomic_init(&ctx->records[i].copy_begin,0);
 atomic_init(&ctx->records[i].copy_end,0);
 atomic_init(&ctx->records[i].write_begin,0);
 atomic_init(&ctx->records[i].write_end,0);
 atomic_init(&ctx->records[i].slot,0);
 atomic_init(&ctx->records[i].bytes,0);
 atomic_init(&ctx->records[i].written,0);
 atomic_init(&ctx->records[i].submitted,0);
 atomic_init(&ctx->records[i].pwrite_begin,0);
 atomic_init(&ctx->records[i].pwrite_end,0);
 atomic_init(&ctx->records[i].complete_begin,0);
 atomic_init(&ctx->records[i].complete_end,0);
 atomic_init(&ctx->records[i].cpu_valid,0);
 atomic_init(&ctx->records[i].cpu_wall_consistent,0);
 atomic_init(&ctx->records[i].src_mod64,0);
 atomic_init(&ctx->records[i].dst_mod64,0);
 atomic_init(&ctx->records[i].mem_flags,0);
 atomic_init(&ctx->records[i].cpu_begin,0);
 atomic_init(&ctx->records[i].cpu_end,0);
 atomic_init(&ctx->records[i].write_cpu_begin,0);
 atomic_init(&ctx->records[i].write_cpu_end,0);
 atomic_init(&ctx->records[i].write_offset,0);
 atomic_init(&ctx->records[i].write_cpu_valid,0);
 atomic_init(&ctx->records[i].write_cpu_consistent,0);
 atomic_init(&ctx->records[i].write_src512,0);
 atomic_init(&ctx->records[i].write_src4096,0);
 atomic_init(&ctx->records[i].write_calls,0);
 atomic_init(&ctx->records[i].mem_flags_rc,0);
 atomic_init(&ctx->records[i].mem_fd_rc,0);
 atomic_init(&ctx->records[i].mem_fd,0);
 }
 for(unsigned j=0;j<X2V_RING_SLOTS;j++)atomic_init(&ctx->slot_state[j],0);
 for(unsigned j=0;j<X2V_RING_SLOTS;j++)atomic_init(&ctx->generations[j],0);
 atomic_init(&ctx->state,0);
 atomic_init(&ctx->failure,0);
 atomic_init(&ctx->sequence_error,0);
 atomic_init(&ctx->cpu_drained,0);
 atomic_init(&ctx->lifecycle_failure,0);
 atomic_init(&ctx->stop_reason,0);
 atomic_init(&ctx->admission_gate,0);
 atomic_init(&ctx->copy_active,0);
 atomic_init(&ctx->cancel_requested,0);
 atomic_init(&ctx->abort_requested,0);
 atomic_init(&ctx->capture_armed,0);
 atomic_init(&ctx->reserved,0);
 atomic_init(&ctx->copied,0);
 atomic_init(&ctx->written,0);
 atomic_init(&ctx->submitted,0);
 atomic_init(&ctx->writer_exited,0);
 atomic_init(&ctx->expired,0);
 atomic_init(&ctx->admission_closed,0);
 atomic_init(&ctx->drop_full,0);
 atomic_init(&ctx->drop_busy,0);
 atomic_init(&ctx->fsync_ok,0);
 atomic_init(&ctx->bytes_written,0);
 atomic_init(&ctx->arm_ns,0);
 atomic_init(&ctx->admission_deadline_ns,0);
 atomic_init(&ctx->closed_ns,0);
 atomic_init(&ctx->writer_done_ns,0);
 atomic_init(&ctx->fsync_wall_begin,0);
 atomic_init(&ctx->fsync_wall_end,0);
 atomic_init(&ctx->fsync_cpu_begin,0);
 atomic_init(&ctx->fsync_cpu_end,0);
 atomic_init(&ctx->fsync_clock_valid,0);
 atomic_init(&ctx->fsync_cpu_consistent,0);
 ctx->clip_generation=generation;ctx->out_fd=-1;ctx->writer_flags_before=-1;ctx->writer_flags_active=-1;
 x2v_receiver_set_deadline(ctx,deadline_ms);return ctx;
}
