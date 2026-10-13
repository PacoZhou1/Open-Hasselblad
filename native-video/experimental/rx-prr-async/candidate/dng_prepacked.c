#define _GNU_SOURCE 1
#include "dng_prepacked.h"
#include "metadata_record.h"
#include "copy_provider.h"
#include "io_provider.h"
#ifndef X2V_HOST_TEST
#include "prr_enc.h"
#include "prr_mov.h"
#include "prr_pre.h"
#endif
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <time.h>
#include <unistd.h>
#ifdef __APPLE__
#include <sys/stdio.h>
#endif
_Static_assert(sizeof(off_t)==8,"64-bit ordinary file offset");
_Static_assert(X2V_DNG_SLOT_STRIDE>=X2V_DNG_SPAN && (X2V_DNG_SLOT_STRIDE%4096u)==0,"aligned source slot");
#define LAYOUT_VALIDATED 0x50525231u
#ifndef O_DIRECT
#define O_DIRECT 0x10000
#endif
#ifdef X2V_HOST_TEST
extern int test_openat(int,const char*,int,mode_t);
extern int test_getfl(int);
extern int test_close(int);
extern void test_after_pwrite(void);
extern void test_during_fsync(void);
extern int x2v_test_fail_fsync;
extern int x2v_test_fail_rename;
extern int x2v_test_fail_append;
extern int x2v_test_fail_pthread_create;
extern int x2v_test_fail_pthread_join;
#define OPENAT test_openat
#define GETFL test_getfl
#define CLOSE test_close
static int take_fail(int *slot){int e=*slot;*slot=0;return e;}
#else
#define OPENAT openat
#define GETFL(fd) fcntl(fd,F_GETFL)
#define CLOSE close
static void test_after_pwrite(void){}
static void test_during_fsync(void){}
static int take_fail(int *slot){(void)slot;return 0;}
static int x2v_test_fail_fsync,x2v_test_fail_rename,x2v_test_fail_append,x2v_test_fail_pthread_create,x2v_test_fail_pthread_join;
#endif

#ifndef X2V_HOST_TEST
/* Provisional AsShotNeutral from profile_provisional.h, converted to ProRes RAW header. */
static const struct {
 float wb_red,wb_blue,gain,matrix[9];
 uint16_t cct;
} default_meta={
 2.161865234375f,2.167236328125f,1.0f,
 {0.7141116f,0.1032353f,0.1331231f,0.2757776f,0.8515739f,-0.1273514f,0.1016372f,-0.420501f,1.407694f},
 3961
};
#endif

struct pending_io {
 int live,queued,dir;pthread_t th;
 int result,close_error,published,file_synced;
 uint32_t index,source_id;
 uint64_t native_ts,admission,write_begin,pwrite_end,file_bytes,mov_offset;
 uint64_t fsync_begin_ns,fsync_end_ns,complete_begin_ns,complete_end_ns;
 char metadata_hex[XMD_HEX_BYTES+1];unsigned metadata_present;
 char line[2048];int line_len;
};
struct x2v_dng_sequence {
 int dir,manifest,error,close_error;uint32_t count,next;uint64_t manifest_offset,last_stamp,bytes_written;uint32_t last_id;
 _Atomic int stop;uint64_t session_key;
 struct stat manifest_identity;
 struct pending_io pend;
#ifndef X2V_HOST_TEST
 struct prr_mov mov;
 int mov_open;
#endif
#ifdef X2V_HOST_TEST
 int mov_fd;uint64_t mov_pos;
#endif
};
#ifndef X2V_HOST_TEST
static pthread_mutex_t enc_mu=PTHREAD_MUTEX_INITIALIZER;
static struct prr_enc enc;
static struct prr_pre pre;
static int enc_ready,enc_users;
#endif

static int bad(int e){return e?e:EIO;}
static uint64_t tick(void){struct timespec t;if(clock_gettime(CLOCK_MONOTONIC,&t)||t.tv_sec<0||t.tv_nsec<0||t.tv_nsec>=1000000000)return 0;return (uint64_t)t.tv_sec*1000000000u+t.tv_nsec;}
static int same(const struct stat*a,const struct stat*b){return a->st_dev==b->st_dev&&a->st_ino==b->st_ino&&b->st_nlink==1&&S_ISREG(b->st_mode);}
static int publish(int dir,const char*partial,const char*final,const struct stat*identity){
 struct stat s;if(fstatat(dir,partial,&s,AT_SYMLINK_NOFOLLOW))return bad(errno);if(!same(identity,&s)||s.st_size!=identity->st_size)return ESTALE;
#ifdef __APPLE__
 if(renameatx_np(dir,partial,dir,final,RENAME_EXCL))return bad(errno);
#else
 if(syscall(SYS_renameat2,dir,partial,dir,final,1u))return bad(errno);
#endif
 return 0;
}
static int put(int fd,const unsigned char*p,size_t n,off_t off,int direct){
 unsigned calls=0;while(n){if(++calls>32)return ELOOP;
  if(direct&&(((uintptr_t)p|n|(uint64_t)off)&511u))return EINVAL;
  ssize_t z=x2v_writer_pwrite(fd,p,n,off);
  if(z<0){if(errno==EINTR)continue;return bad(errno);}if(!z||(size_t)z>n)return EIO;
  if(direct&&((size_t)z&511u))return EINVAL;
  p+=(size_t)z;n-=(size_t)z;off+=z;
 }return 0;
}
static int append(struct x2v_dng_sequence*c,const char*text,size_t len){
 if(c->manifest_offset+len>1048576)return EFBIG;
 int e=put(c->manifest,(const unsigned char*)text,len,(off_t)c->manifest_offset,0);
 if(!e)c->manifest_offset+=len;return e;
}
static int check_fd(int fd,int direct){
 struct stat s;int f=GETFL(fd);if(f<0)return bad(errno);
 if(fstat(fd,&s))return bad(errno);
 if(!S_ISREG(s.st_mode)||s.st_nlink!=1||s.st_size|| (f&O_ACCMODE)!=O_RDWR|| (f&(O_APPEND|O_SYNC|O_DSYNC))||!!(f&O_DIRECT)!=direct)return EINVAL;
 return 0;
}
static int layout_check(const struct x2v_dng_layout*l){return l&&l->validated==LAYOUT_VALIDATED?0:EINVAL;}

#ifndef X2V_HOST_TEST
struct pre_job {const struct prr_pre *pre;const uint16_t *src;uint16_t *dst;float black;int r0,r1;};
static void *pre_run(void *arg){struct pre_job *j=arg;prr_pre_rows(j->pre,j->src,j->dst,j->black,j->r0,j->r1);return NULL;}
static void preprocess_mt(const struct prr_pre *p,const uint16_t *src,uint16_t *dst,float black){
 struct pre_job w[2];pthread_t th;
 int h=p->g.height;
 w[0]=(struct pre_job){p,src,dst,black,0,h/2};
 w[1]=(struct pre_job){p,src,dst,black,h/2,h};
 if(pthread_create(&th,NULL,pre_run,&w[1])){prr_pre_rows(p,src,dst,black,0,h);return;}
 pre_run(&w[0]);pthread_join(th,NULL);
}

static int ensure_encoder(void){
 pthread_mutex_lock(&enc_mu);
 if(enc_ready){enc_users++;pthread_mutex_unlock(&enc_mu);return 0;}
 static const struct prr_pre_geom geom=PRR_PRE_GEOM_MODE21;
 if(prr_pre_init(&pre,&geom,64681.0f,0.0f,1)){pthread_mutex_unlock(&enc_mu);return ENOMEM;}
 struct prr_enc_cfg cfg={X2V_PRR_WIDTH,X2V_PRR_HEIGHT,(int)geom.dst_stride_px*2,1,0,3,3,0};
 int rc=prr_enc_open(&enc,&cfg);
 if(rc){prr_pre_free(&pre);pthread_mutex_unlock(&enc_mu);return rc<0?-rc:rc;}
 enc_ready=1;enc_users=1;
 pthread_mutex_unlock(&enc_mu);return 0;
}

static int encode_device(const unsigned char *src,uint32_t index,const uint8_t **a,uint32_t *alen,const uint8_t **b,uint32_t *blen,struct prr_out *held){
 uint16_t *dst=NULL;
 int slot=prr_enc_acquire_frame(&enc,&dst);
 if(slot<0)return EAGAIN;
 float black=prr_pre_black(&pre,(const uint16_t*)src);
 preprocess_mt(&pre,(const uint16_t*)src,dst,black);
 struct prr_meta meta={default_meta.wb_red,default_meta.wb_blue,default_meta.gain,{0},default_meta.cct};
 memcpy(meta.matrix,default_meta.matrix,sizeof meta.matrix);
 uint64_t pts=(uint64_t)index*1000ull;
 int rc=prr_enc_submit(&enc,slot,pts,&meta);
 if(rc)return rc<0?-rc:rc;
 if(prr_enc_next(&enc,held,3000))return ETIMEDOUT;
 *a=held->a;*alen=held->alen;*b=held->b;*blen=held->blen;
 if(*alen<0x98||!held->a){prr_enc_release(&enc,held);return EPROTO;}
 return 0;
}
#endif

#ifdef X2V_HOST_TEST
static int encode_host(uint32_t index,unsigned char out[256],const uint8_t **a,uint32_t *alen,const uint8_t **b,uint32_t *blen){
 memset(out,0,256);
 out[0]=0;out[1]=0;out[2]=1;out[3]=0;
 out[4]='p';out[5]='r';out[6]='r';out[7]='f';
 out[8]=(unsigned char)index;
 *a=out;*alen=256;*b=NULL;*blen=0;return 0;
}
#endif

int x2v_dng_layout_init(struct x2v_dng_layout*l,const struct dng_frame_profile*p,int provisional){
 if(!l||!p||provisional!=1||!p->unique_camera_model||!strstr(p->unique_camera_model,"UNCALIBRATED"))return EINVAL;
 int e=x2v_copy_provider_bind();if(e)return e;
 l->header_checksum=0;l->validated=LAYOUT_VALIDATED;return 0;
}
int x2v_dng_prepacked_slot_init(struct x2v_dng_prepacked_slot*s,const struct x2v_dng_layout*l,void*data,size_t span){
 if(!s||s->initialized||layout_check(l)||!data||((uintptr_t)data&4095u)||span<X2V_DNG_SPAN||span>X2V_DNG_SLOT_STRIDE)return EINVAL;
 if((uintptr_t)data>UINTPTR_MAX-span)return EINVAL;
 s->data=data;s->span=span;s->layout=l;s->ticket=(struct x2v_dng_ticket){0,0};atomic_init(&s->state,X2V_DNG_SLOT_FREE);s->initialized=LAYOUT_VALIDATED;return 0;
}
static int slot_shape(const struct x2v_dng_prepacked_slot*s){return s&&s->initialized==LAYOUT_VALIDATED&&s->data&&s->layout&&(((uintptr_t)s->data&4095u)==0)&&s->span>=X2V_DNG_SPAN&&s->span<=X2V_DNG_SLOT_STRIDE&&(uintptr_t)s->data<=UINTPTR_MAX-s->span;}
int x2v_dng_prepare_prepacked(struct x2v_dng_prepacked_slot*s,const void*source,size_t span,const struct x2v_dng_ticket*t){
 if(!slot_shape(s)||!source||span!=X2V_DNG_SPAN||!t||!t->session||!t->generation)return EINVAL;
 uintptr_t a=(uintptr_t)source,b=(uintptr_t)s->data;if(a>UINTPTR_MAX-span||b>UINTPTR_MAX-s->span||(a<b+s->span&&b<a+span))return EINVAL;
 int expected=X2V_DNG_SLOT_FREE;if(!atomic_compare_exchange_strong_explicit(&s->state,&expected,X2V_DNG_SLOT_PREPARING,memory_order_acq_rel,memory_order_acquire))return EBUSY;
 int e=0;
 if(t->session<s->ticket.session||(t->session==s->ticket.session&&t->generation<=s->ticket.generation))e=ESTALE;
 if(!e)e=x2v_copy_bytes(s->data,source,X2V_DNG_SPAN);
 if(!e)s->ticket=*t;
 atomic_store_explicit(&s->state,e?X2V_DNG_SLOT_FAILED:X2V_DNG_SLOT_READY,memory_order_release);return e;
}
int x2v_dng_sequence_begin_prepacked(struct x2v_dng_sequence **out,int dir,const struct x2v_dng_layout*l,uint64_t session){
 if(!out||*out||!session||layout_check(l))return EINVAL;
 struct stat st;if(fstat(dir,&st))return bad(errno);if(!S_ISDIR(st.st_mode))return EINVAL;
 int e=x2v_writer_provider_bind();if(e)return e;
#ifndef X2V_HOST_TEST
 e=ensure_encoder();if(e)return e;
#endif
 struct x2v_dng_sequence*c=NULL;if(posix_memalign((void**)&c,4096,sizeof *c)){
#ifndef X2V_HOST_TEST
  pthread_mutex_lock(&enc_mu);enc_users--;pthread_mutex_unlock(&enc_mu);
#endif
  return ENOMEM;
 }
 memset(c,0,sizeof *c);c->dir=c->manifest=-1;c->session_key=session;
#ifdef X2V_HOST_TEST
 c->mov_fd=-1;
#endif
 c->dir=fcntl(dir,F_DUPFD_CLOEXEC,10);if(c->dir<0){e=bad(errno);goto fail;}
 c->manifest=OPENAT(c->dir,"clip.partial.jsonl",O_CREAT|O_EXCL|O_RDWR|O_CLOEXEC|O_NOFOLLOW,0600);if(c->manifest<0){e=bad(errno);goto fail;}
 e=check_fd(c->manifest,0);if(e)goto fail;if(fstat(c->manifest,&c->manifest_identity)){e=bad(errno);goto fail;}
#ifndef X2V_HOST_TEST
 if(prr_mov_openat(&c->mov,c->dir,"clip.partial.mov",X2V_PRR_WIDTH,X2V_PRR_HEIGHT,"aprh",24000,1001)){e=bad(errno);goto fail;}
 c->mov_open=1;
#else
 c->mov_fd=OPENAT(c->dir,"clip.partial.mov",O_CREAT|O_EXCL|O_RDWR|O_CLOEXEC|O_NOFOLLOW,0600);
 if(c->mov_fd<0){e=bad(errno);goto fail;}
 e=check_fd(c->mov_fd,0);if(e)goto fail;
 c->mov_pos=0;
#endif
 const char text[]="{\"kind\":\"PRORES_RAW_HQ_MOV\",\"version\":1,\"width\":3888,\"height\":2912,\"source_width\":3920,\"source_height\":2946,\"source_stride\":7936,\"fourcc\":\"aprh\",\"profile\":\"HQ\",\"calibrated\":false}\n";
 e=append(c,text,sizeof text-1);if(e)goto fail;
 atomic_init(&c->stop,0);*out=c;return 0;
fail:
#ifndef X2V_HOST_TEST
 if(c->mov_open){prr_mov_close(&c->mov);c->mov_open=0;}
 pthread_mutex_lock(&enc_mu);if(enc_users>0)enc_users--;pthread_mutex_unlock(&enc_mu);
#else
 if(c->mov_fd>=0)CLOSE(c->mov_fd);
#endif
 if(c->manifest>=0&&CLOSE(c->manifest))e=bad(errno);if(c->dir>=0&&CLOSE(c->dir))e=bad(errno);free(c);return e;
}
static int complete_one(struct x2v_dng_sequence*c,struct pending_io*p){
 int e=0;if(!p||!c)return EINVAL;
 p->result=0;p->close_error=0;p->published=0;p->file_synced=0;p->line_len=0;
 p->complete_begin_ns=tick();p->fsync_begin_ns=0;p->fsync_end_ns=0;
 test_during_fsync();
 p->fsync_begin_ns=tick();
 int inj=take_fail(&x2v_test_fail_fsync);
#ifndef X2V_HOST_TEST
 if(inj)e=inj;else if(prr_mov_fsync(&c->mov))e=bad(errno);
#else
 if(inj)e=inj;else if(x2v_writer_fsync(c->mov_fd))e=bad(errno);
#endif
 p->fsync_end_ns=tick();
 if(!e)p->file_synced=1;
 if(!e)p->published=1;
 if(!e){
  int k=snprintf(p->line,sizeof p->line,"{\"index\":%u,\"file\":\"clip.mov\",\"source_id\":%u,\"native_timestamp_raw\":%llu,\"cpu_admission_ns\":%llu,\"write_begin_ns\":%llu,\"pwrite_end_ns\":%llu,\"write_end_ns\":%llu,\"fsync_begin_ns\":%llu,\"fsync_end_ns\":%llu,\"file_bytes\":%llu,\"pixel_bytes\":22643712,\"mov_offset\":%llu,\"file_fsync\":%s,\"file_published\":true,\"namespace_durable\":false}\n",p->index,p->source_id,(unsigned long long)p->native_ts,(unsigned long long)p->admission,(unsigned long long)p->write_begin,(unsigned long long)p->pwrite_end,(unsigned long long)p->fsync_end_ns,(unsigned long long)p->fsync_begin_ns,(unsigned long long)p->fsync_end_ns,(unsigned long long)p->file_bytes,(unsigned long long)p->mov_offset,p->file_synced?"true":"false");
  if(k<=0||(size_t)k>=sizeof p->line)e=EOVERFLOW;
  else{if(p->metadata_present){
   if(k<2||p->line[k-2]!='}')e=EPROTO;
   else{int tail=snprintf(p->line+k-2,sizeof p->line-(size_t)(k-2),",\"native_metadata_hex_v1\":\"%s\"}\n",p->metadata_hex);
    if(tail<=0||(size_t)tail>=sizeof p->line-(size_t)(k-2))e=EOVERFLOW;else k=k-2+tail;}
  }if(!e)p->line_len=k;}
 }
 p->complete_end_ns=tick();p->result=e;return e;
}
static void *complete_thread(void *arg){
 struct x2v_dng_sequence*c=arg;complete_one(c,&c->pend);return NULL;
}
static int harvest(struct x2v_dng_sequence*c,struct x2v_dng_result*r,int as_previous){
 struct pending_io*p=&c->pend;
 if(p->close_error&&!c->close_error)c->close_error=p->close_error;
 int e=p->result;
 if(!e&&p->line_len>0){
  int inj=take_fail(&x2v_test_fail_append);
  if(inj)e=inj;else e=append(c,p->line,(size_t)p->line_len);
  p->line_len=0;
 }
 if(e&&!c->error)c->error=e;
 if(!e){c->count++;c->bytes_written+=p->file_bytes;}
 p->queued=0;
 p->result=e;
 if(r){
  if(as_previous){
   r->previous_joined=1;r->previous_published=p->published;r->previous_file_synced=p->file_synced;
   r->previous_index=p->index;r->previous_fsync_begin_ns=p->fsync_begin_ns;r->previous_fsync_end_ns=p->fsync_end_ns;
   r->previous_complete_begin_ns=p->complete_begin_ns;r->previous_complete_end_ns=p->complete_end_ns;
  }else{
   r->published=p->published;r->file_synced=p->file_synced;
   r->fsync_begin_ns=p->fsync_begin_ns;r->fsync_end_ns=p->fsync_end_ns;
   r->complete_begin_ns=p->complete_begin_ns;r->complete_end_ns=p->complete_end_ns;
  }
 }
 return e;
}
static int join_pending(struct x2v_dng_sequence*c,struct x2v_dng_result*r){
 if(c->pend.live){
  int inj=take_fail(&x2v_test_fail_pthread_join);
  if(inj)return inj;
  int j=pthread_join(c->pend.th,NULL);
  if(j)return bad(j);
  c->pend.live=0;return harvest(c,r,1);
 }
 if(c->pend.queued){complete_one(c,&c->pend);return harvest(c,r,1);}
 return 0;
}
static int queue_complete(struct x2v_dng_sequence*c,struct x2v_dng_result*r){
 int inj=x2v_test_fail_pthread_create;int e=inj?inj:pthread_create(&c->pend.th,NULL,complete_thread,c);
 if(e){
  complete_one(c,&c->pend);r->complete_inline=1;r->publish_queued=1;return harvest(c,r,0);
 }
 c->pend.live=1;r->publish_queued=1;r->published=0;r->file_synced=0;r->complete_inline=0;return 0;
}
static int put_prepacked_inner(struct x2v_dng_sequence*c,struct x2v_dng_prepacked_slot*slot,const struct x2v_dng_ticket*ticket,const struct x2v_dng_frame_time*t,struct x2v_dng_result*r,const struct xmd_record*metadata){
 if(!c||!r)return EINVAL;memset(r,0,sizeof *r);
 if(!slot_shape(slot)||!ticket||!ticket->session||!ticket->generation||!t)return c->error=EINVAL;
 if(c->error)return c->error;if(atomic_load_explicit(&c->stop,memory_order_acquire))return ECANCELED;
 if(c->next>=X2V_DNG_MAX_FRAMES)return EFBIG;
 if(!t->source_id||!t->native_timestamp_raw||!t->cpu_admission_ns||(c->next&&(t->source_id<=c->last_id||t->native_timestamp_raw<=c->last_stamp)))return c->error=EINVAL;
 char metadata_hex[XMD_HEX_BYTES+1]={0};
 if(metadata){int me=xmd_record_matches(metadata,ticket->session,ticket->generation,c->next,t->source_id,t->native_timestamp_raw);
  if(!me)me=xmd_record_hex(metadata,metadata_hex,sizeof metadata_hex);if(me)return c->error=me;}
 int ready=X2V_DNG_SLOT_READY;
 if(!atomic_compare_exchange_strong_explicit(&slot->state,&ready,X2V_DNG_SLOT_WRITING,memory_order_acq_rel,memory_order_acquire))return c->error=EBUSY;
 int slot_error=0;
 if(ticket->session!=c->session_key||ticket->session!=slot->ticket.session||ticket->generation!=slot->ticket.generation)slot_error=ESTALE;
 if(slot_error){atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FAILED,memory_order_release);return c->error=slot_error;}
 uint64_t start=tick();if(!start){atomic_store(&slot->state,X2V_DNG_SLOT_FAILED);return c->error=EIO;}
 uint32_t index=c->next;
 const uint8_t *a=NULL,*b=NULL;uint32_t alen=0,blen=0;
#ifdef X2V_HOST_TEST
 unsigned char stub[256];
 int e=encode_host(index,stub,&a,&alen,&b,&blen);
 uint64_t mov_offset=c->mov_pos;
 r->pwrite_begin_ns=tick();
 if(!e)e=put(c->mov_fd,a,alen,(off_t)c->mov_pos,0);
 if(!e&&blen)e=put(c->mov_fd,b,blen,(off_t)(c->mov_pos+alen),0);
 test_after_pwrite();
 if(!e)c->mov_pos+=alen+blen;
#else
 struct prr_out held={0};
 int e=encode_device(slot->data,index,&a,&alen,&b,&blen,&held);
 uint64_t mov_offset=c->mov.pos;
 r->pwrite_begin_ns=tick();
 if(!e&&prr_mov_write(&c->mov,a,alen,b,blen))e=EIO;
 test_after_pwrite();
 if(!e)prr_enc_release(&enc,&held);
 else if(held.a)prr_enc_release(&enc,&held);
#endif
 r->pwrite_end_ns=tick();
 uint64_t encoded=(uint64_t)alen+blen;
 if(!e&&(!encoded||encoded>X2V_DNG_FILE_BYTES))e=EFBIG;
 r->index=index;r->source_id=t->source_id;r->wall_begin_ns=start;r->pixel_bytes=X2V_DNG_PIXEL_BYTES;r->file_bytes=encoded;r->mov_offset=mov_offset;
 if(!e)r->pwrite_complete=1;
 if(e){
  r->wall_end_ns=tick();c->error=e;atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FAILED,memory_order_release);return e;
 }
 r->join_begin_ns=tick();
 int je=join_pending(c,r);
 r->join_end_ns=tick();
 if(je){
  r->wall_end_ns=tick();if(!c->error)c->error=je;atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FAILED,memory_order_release);return c->error;
 }
 memset(&c->pend,0,sizeof c->pend);c->pend.dir=c->dir;c->pend.index=index;c->pend.source_id=t->source_id;
 c->pend.native_ts=t->native_timestamp_raw;c->pend.admission=t->cpu_admission_ns;c->pend.write_begin=start;c->pend.pwrite_end=r->pwrite_end_ns;c->pend.file_bytes=encoded;c->pend.mov_offset=mov_offset;c->pend.queued=1;
 if(metadata){memcpy(c->pend.metadata_hex,metadata_hex,sizeof metadata_hex);c->pend.metadata_present=1;}
 int qe=queue_complete(c,r);
 if(qe){
  r->wall_end_ns=tick();if(!c->error)c->error=qe;atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FAILED,memory_order_release);return qe;
 }
 c->next=index+1;c->last_id=t->source_id;c->last_stamp=t->native_timestamp_raw;
 r->wall_end_ns=tick();
 if(!r->wall_end_ns||r->wall_end_ns<start){c->error=EIO;atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FAILED,memory_order_release);return EIO;}
 atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FREE,memory_order_release);return 0;
}
int x2v_dng_sequence_put_prepacked(struct x2v_dng_sequence*c,struct x2v_dng_prepacked_slot*s,const struct x2v_dng_ticket*k,const struct x2v_dng_frame_time*t,struct x2v_dng_result*r){return put_prepacked_inner(c,s,k,t,r,NULL);}
int x2v_dng_sequence_put_prepacked_metadata(struct x2v_dng_sequence*c,struct x2v_dng_prepacked_slot*s,const struct x2v_dng_ticket*k,const struct x2v_dng_frame_time*t,struct x2v_dng_result*r,const struct xmd_record*m){if(!m)return EINVAL;return put_prepacked_inner(c,s,k,t,r,m);}
void x2v_dng_sequence_request_stop(struct x2v_dng_sequence*c){if(c)atomic_store_explicit(&c->stop,1,memory_order_release);}
int x2v_dng_sequence_finish(struct x2v_dng_sequence **owner,struct x2v_dng_finish*r){
 if(!owner||!*owner||!r)return EINVAL;struct x2v_dng_sequence*c=*owner;memset(r,0,sizeof *r);atomic_store(&c->stop,1);
 r->submitted_frames=c->next;
 struct x2v_dng_result prev={0};
 int e=join_pending(c,&prev);
 if(c->pend.live){
  r->join_failed=1;r->error=e?e:EAGAIN;r->cpu_released=0;r->published_frames=c->count;r->close_error=c->close_error;return r->error;
 }
 if(!e)e=c->error;
 r->last_index=prev.previous_index;r->last_published=prev.previous_published;r->last_file_synced=prev.previous_file_synced;
 r->last_fsync_begin_ns=prev.previous_fsync_begin_ns;r->last_fsync_end_ns=prev.previous_fsync_end_ns;
 r->last_complete_begin_ns=prev.previous_complete_begin_ns;r->last_complete_end_ns=prev.previous_complete_end_ns;
 char summary[192];int n=snprintf(summary,sizeof summary,"{\"end\":true,\"published_frames\":%u,\"submitted_frames\":%u,\"bytes_written\":%llu,\"error\":%d}\n",c->count,c->next,(unsigned long long)c->bytes_written,e);
 if(n<=0||(size_t)n>=sizeof summary){if(!e)e=EOVERFLOW;}else{int z=append(c,summary,(size_t)n);if(!e)e=z;}
 if(x2v_writer_fsync(c->manifest)&&!e)e=bad(errno);
#ifndef X2V_HOST_TEST
 if(c->mov_open){if(prr_mov_close(&c->mov)&&!e)e=EIO;c->mov_open=0;}
#else
 if(c->mov_fd>=0){if(x2v_writer_fsync(c->mov_fd)&&!e)e=bad(errno);if(CLOSE(c->mov_fd)&&!e)e=bad(errno);c->mov_fd=-1;}
#endif
 struct stat ms,mv;
 if(fstat(c->manifest,&ms)){if(!e)e=bad(errno);}else if(!same(&c->manifest_identity,&ms)){if(!e)e=ESTALE;}
 if(CLOSE(c->manifest)){c->close_error=bad(errno);if(!e)e=c->close_error;}
 if(!e){int inj=take_fail(&x2v_test_fail_rename);if(inj)e=inj;else{int z=publish(c->dir,"clip.partial.jsonl","clip.jsonl",&ms);if(z)e=z;}}
 if(!e&&fstatat(c->dir,"clip.partial.mov",&mv,AT_SYMLINK_NOFOLLOW))e=bad(errno);
 if(!e){int z=publish(c->dir,"clip.partial.mov","clip.mov",&mv);if(z)e=z;else r->manifest_published=1;}
 if(x2v_writer_fsync(c->dir)){if(!e)e=bad(errno);}else r->directory_synced=1;
 r->published_frames=c->count;r->bytes_written=c->bytes_written;if(CLOSE(c->dir)){c->close_error=bad(errno);if(!e)e=c->close_error;}
#ifndef X2V_HOST_TEST
 pthread_mutex_lock(&enc_mu);if(enc_users>0)enc_users--;pthread_mutex_unlock(&enc_mu);
#endif
 r->error=e;r->close_error=c->close_error;
 free(c);*owner=NULL;r->cpu_released=1;return e;
}
