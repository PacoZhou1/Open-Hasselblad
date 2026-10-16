#define _GNU_SOURCE 1
#include "dng_prepacked.h"
#include "copy_provider.h"
#include "io_provider.h"
#include <errno.h>
#include <fcntl.h>
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
#define LAYOUT_VALIDATED 0x444e4731u
#ifndef O_DIRECT
#define O_DIRECT 0x10000
#endif
#ifdef X2V_HOST_TEST
extern int test_openat(int,const char*,int,mode_t);
extern int test_getfl(int);
extern int test_close(int);
#define OPENAT test_openat
#define GETFL test_getfl
#define CLOSE test_close
#else
#define OPENAT openat
#define GETFL(fd) fcntl(fd,F_GETFL)
#define CLOSE close
#endif
int x2v_dng_header(const struct dng_bayer_frame*,const struct dng_frame_profile*,unsigned char[4096],uint64_t*);
struct x2v_dng_sequence {
 int dir,manifest,direct,error,close_error;uint32_t count;uint64_t manifest_offset,last_stamp;uint32_t last_id;
 _Atomic int stop;uint64_t session_key;_Alignas(4096) unsigned char header[4096];
 struct stat manifest_identity;
};
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
/* Bounded attempts per <=64KiB write. DIRECT continuation requires every
 * returned short byte count to preserve 512-byte ptr/offset/rem alignment. */
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
static uint64_t header_checksum(const unsigned char *p){uint64_t h=14695981039346656037ull;for(unsigned i=0;i<4096;i++){h^=p[i];h*=1099511628211ull;}return h;}
static int layout_check(const struct x2v_dng_layout*l){return l&&l->validated==LAYOUT_VALIDATED&&header_checksum(l->header)==l->header_checksum?0:EINVAL;}
int x2v_dng_layout_init(struct x2v_dng_layout*l,const struct dng_frame_profile*p,int provisional){
 if(!l||!p||provisional!=1||!p->unique_camera_model||!strstr(p->unique_camera_model,"UNCALIBRATED"))return EINVAL;
 l->validated=0;struct dng_bayer_frame f={l->header,X2V_DNG_SPAN,X2V_DNG_STRIDE,X2V_DNG_WIDTH,X2V_DNG_HEIGHT,16};uint64_t pixels;
 if(x2v_dng_header(&f,p,l->header,&pixels))return bad(errno);
 if(pixels!=X2V_DNG_PIXEL_BYTES)return EINVAL;
 int e=x2v_copy_provider_bind();if(e)return e;
 l->header_checksum=header_checksum(l->header);l->validated=LAYOUT_VALIDATED;return 0;
}
int x2v_dng_prepacked_slot_init(struct x2v_dng_prepacked_slot*s,const struct x2v_dng_layout*l,void*data,size_t span){
 if(!s||s->initialized||layout_check(l)||!data||((uintptr_t)data&4095u)||span<X2V_DNG_FILE_BYTES||span>X2V_DNG_SLOT_STRIDE)return EINVAL;
 if((uintptr_t)data>UINTPTR_MAX-span)return EINVAL;
 int e=x2v_copy_bytes(data,l->header,4096);if(e)return e;
 memset((unsigned char*)data+4096+X2V_DNG_PIXEL_BYTES,0,192);
 s->data=data;s->span=span;s->layout=l;s->ticket=(struct x2v_dng_ticket){0,0};atomic_init(&s->state,X2V_DNG_SLOT_FREE);s->initialized=LAYOUT_VALIDATED;return 0;
}
static int slot_shape(const struct x2v_dng_prepacked_slot*s){return s&&s->initialized==LAYOUT_VALIDATED&&s->data&&s->layout&&(((uintptr_t)s->data&4095u)==0)&&s->span>=X2V_DNG_FILE_BYTES&&s->span<=X2V_DNG_SLOT_STRIDE&&(uintptr_t)s->data<=UINTPTR_MAX-s->span;}
int x2v_dng_prepare_prepacked(struct x2v_dng_prepacked_slot*s,const void*source,size_t span,const struct x2v_dng_ticket*t){
 if(!slot_shape(s)||!source||span!=X2V_DNG_SPAN||!t||!t->session||!t->generation)return EINVAL;
 uintptr_t a=(uintptr_t)source,b=(uintptr_t)s->data;if(a>UINTPTR_MAX-span||b>UINTPTR_MAX-s->span||(a<b+s->span&&b<a+span))return EINVAL;
 int expected=X2V_DNG_SLOT_FREE;if(!atomic_compare_exchange_strong_explicit(&s->state,&expected,X2V_DNG_SLOT_PREPARING,memory_order_acq_rel,memory_order_acquire))return EBUSY;
 int e=0;
 /* ONLY immutable layout and exclusively claimed slot, NEVER writer context. */
 if(!s->layout||s->layout->validated!=LAYOUT_VALIDATED||memcmp(s->data,s->layout->header,4096))e=EINVAL;
 if(!e&&(t->session<s->ticket.session||(t->session==s->ticket.session&&t->generation<=s->ticket.generation)))e=ESTALE;
 for(unsigned y=0;!e&&y<X2V_DNG_HEIGHT;y++)e=x2v_copy_bytes(s->data+4096+(size_t)y*7840u,(const unsigned char*)source+(size_t)y*X2V_DNG_STRIDE,7840);
 if(!e){memset(s->data+4096+X2V_DNG_PIXEL_BYTES,0,192);s->ticket=*t;}
 atomic_store_explicit(&s->state,e?X2V_DNG_SLOT_FAILED:X2V_DNG_SLOT_READY,memory_order_release);return e;
}
int x2v_dng_sequence_begin_prepacked(struct x2v_dng_sequence **out,int dir,const struct x2v_dng_layout*l,uint64_t session){
 if(!out||*out||!session||layout_check(l))return EINVAL;
 struct stat st;if(fstat(dir,&st))return bad(errno);if(!S_ISDIR(st.st_mode))return EINVAL;
 int e=x2v_writer_provider_bind();if(e)return e;
 struct x2v_dng_sequence*c=NULL;if(posix_memalign((void**)&c,4096,sizeof *c))return ENOMEM;memset(c,0,sizeof *c);c->dir=c->manifest=-1;c->direct=1;c->session_key=session;
 memcpy(c->header,l->header,4096);
 c->dir=fcntl(dir,F_DUPFD_CLOEXEC,10);if(c->dir<0){e=bad(errno);goto fail;}
 c->manifest=OPENAT(c->dir,"segment.partial.jsonl",O_CREAT|O_EXCL|O_RDWR|O_CLOEXEC|O_NOFOLLOW,0600);if(c->manifest<0){e=bad(errno);goto fail;}
 e=check_fd(c->manifest,0);if(e)goto fail;if(fstat(c->manifest,&c->manifest_identity)){e=bad(errno);goto fail;}
 const char text[]="{\"kind\":\"DNG_SEQUENCE_PROVISIONAL\",\"version\":1,\"width\":3920,\"height\":2946,\"source_stride\":7936,\"stored_bits\":16,\"native_timestamp_unit\":\"unknown_raw_integer\",\"calibrated\":false,\"timecode_present\":false}\n";
 e=append(c,text,sizeof text-1);if(e)goto fail;
 atomic_init(&c->stop,0);*out=c;return 0;
fail:
 if(c->manifest>=0&&CLOSE(c->manifest))e=bad(errno);if(c->dir>=0&&CLOSE(c->dir))e=bad(errno);free(c);return e;
}

int x2v_dng_sequence_put_prepacked(struct x2v_dng_sequence*c,struct x2v_dng_prepacked_slot*slot,const struct x2v_dng_ticket*ticket,const struct x2v_dng_frame_time*t,struct x2v_dng_result*r){
 if(!c||!r)return EINVAL;memset(r,0,sizeof *r);
 if(!slot_shape(slot)||!ticket||!ticket->session||!ticket->generation||!t)return c->error=EINVAL;
 if(c->error)return c->error;if(atomic_load_explicit(&c->stop,memory_order_acquire))return ECANCELED;
 if(c->count>=X2V_DNG_MAX_FRAMES)return EFBIG;
 if(!t->source_id||!t->native_timestamp_raw||!t->cpu_admission_ns||(c->count&&(t->source_id<=c->last_id||t->native_timestamp_raw<=c->last_stamp)))return c->error=EINVAL;
 int ready=X2V_DNG_SLOT_READY;
 if(!atomic_compare_exchange_strong_explicit(&slot->state,&ready,X2V_DNG_SLOT_WRITING,memory_order_acq_rel,memory_order_acquire))return c->error=EBUSY;
 int slot_error=0;
 if(ticket->session!=c->session_key||ticket->session!=slot->ticket.session||ticket->generation!=slot->ticket.generation)slot_error=ESTALE;
 if(!slot_error&&memcmp(slot->data,c->header,4096))slot_error=EINVAL;
 for(unsigned i=0;!slot_error&&i<192;i++)if(slot->data[4096+X2V_DNG_PIXEL_BYTES+i])slot_error=EINVAL;
 if(slot_error){atomic_store_explicit(&slot->state,X2V_DNG_SLOT_FAILED,memory_order_release);return c->error=slot_error;}
 uint64_t start=tick();if(!start){atomic_store(&slot->state,X2V_DNG_SLOT_FAILED);return c->error=EIO;}
 char partial[32],final[32];int n=snprintf(partial,sizeof partial,"frame-%06u.partial",c->count),m=snprintf(final,sizeof final,"frame-%06u.dng",c->count);
 if(n<0||m<0||(size_t)n>=sizeof partial||(size_t)m>=sizeof final){atomic_store(&slot->state,X2V_DNG_SLOT_FAILED);return c->error=EOVERFLOW;}
 int fd=OPENAT(c->dir,partial,O_CREAT|O_EXCL|O_RDWR|O_CLOEXEC|O_NOFOLLOW|(c->direct?O_DIRECT:0),0600);
 if(fd<0){atomic_store(&slot->state,X2V_DNG_SLOT_FAILED);return c->error=bad(errno);}int e=check_fd(fd,c->direct);struct stat identity;
 if(!e&&fstat(fd,&identity))e=bad(errno);
 if(!e)e=put(fd,slot->data,X2V_DNG_FILE_BYTES,0,1);
 if(!e&&x2v_writer_fsync(fd))e=bad(errno);if(!e)r->file_synced=1;
 if(!e&&fstat(fd,&identity))e=bad(errno);
 uint64_t expected=c->direct?X2V_DNG_FILE_BYTES:4096u+23096640u;
 if(!e&&((uint64_t)identity.st_size!=expected||identity.st_nlink!=1))e=EIO;
 r->index=c->count;r->source_id=t->source_id;r->wall_begin_ns=start;r->wall_end_ns=tick();r->pixel_bytes=23096640u;r->file_bytes=expected;
 if(!r->wall_end_ns||r->wall_end_ns<start){if(!e)e=EIO;}
 if(CLOSE(fd)){c->close_error=bad(errno);if(!e)e=c->close_error;}
 if(!e)e=publish(c->dir,partial,final,&identity);
 if(!e){r->published=1;c->count++;c->last_id=t->source_id;c->last_stamp=t->native_timestamp_raw;
  char line[768];int k=snprintf(line,sizeof line,"{\"index\":%u,\"file\":\"%s\",\"source_id\":%u,\"native_timestamp_raw\":%llu,\"cpu_admission_ns\":%llu,\"write_begin_ns\":%llu,\"write_end_ns\":%llu,\"file_bytes\":%llu,\"pixel_bytes\":23096640,\"file_fsync\":true,\"namespace_durable\":false}\n",r->index,final,t->source_id,(unsigned long long)t->native_timestamp_raw,(unsigned long long)t->cpu_admission_ns,(unsigned long long)start,(unsigned long long)r->wall_end_ns,(unsigned long long)expected);
  if(k<=0||(size_t)k>=sizeof line)e=EOVERFLOW;else e=append(c,line,(size_t)k);
 }
 if(!r->wall_end_ns||r->wall_end_ns<start){if(!e)e=EIO;}
 if(e)c->error=e;atomic_store_explicit(&slot->state,e?X2V_DNG_SLOT_FAILED:X2V_DNG_SLOT_FREE,memory_order_release);return e;
}
void x2v_dng_sequence_request_stop(struct x2v_dng_sequence*c){if(c)atomic_store_explicit(&c->stop,1,memory_order_release);}
int x2v_dng_sequence_finish(struct x2v_dng_sequence **owner,struct x2v_dng_finish*r){
 if(!owner||!*owner||!r)return EINVAL;struct x2v_dng_sequence*c=*owner;memset(r,0,sizeof *r);atomic_store(&c->stop,1);
 int e=c->error;
 char summary[160];int n=snprintf(summary,sizeof summary,"{\"end\":true,\"published_frames\":%u,\"error\":%d}\n",c->count,e);
 if(n<=0||(size_t)n>=sizeof summary){if(!e)e=EOVERFLOW;}else{int z=append(c,summary,(size_t)n);if(!e)e=z;}
 if(x2v_writer_fsync(c->manifest)&&!e)e=bad(errno);
 struct stat ms;if(fstat(c->manifest,&ms)){if(!e)e=bad(errno);}else if(!same(&c->manifest_identity,&ms)){if(!e)e=ESTALE;}
 if(CLOSE(c->manifest)){c->close_error=bad(errno);if(!e)e=c->close_error;}
 if(!e){int z=publish(c->dir,"segment.partial.jsonl","segment.jsonl",&ms);if(z)e=z;else r->manifest_published=1;}
 if(x2v_writer_fsync(c->dir)){if(!e)e=bad(errno);}else r->directory_synced=1;
 r->published_frames=c->count;if(CLOSE(c->dir)){c->close_error=bad(errno);if(!e)e=c->close_error;}
 r->error=e;r->close_error=c->close_error;
 free(c);*owner=NULL;r->cpu_released=1;return e;
}
