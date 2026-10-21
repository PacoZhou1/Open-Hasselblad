#define _GNU_SOURCE 1
#include "receiver.h"
#include "shape.h"
#include "hook.h"
#include "clip_gate.h"
#include <stdlib.h>
#include "../normal_diagnostic/diag_pins.h"
#include <dlfcn.h>
#include <stdint.h>
#include <stdatomic.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
extern int duss_hal_mem_get_flags(void *,uint32_t *);
extern int duss_hal_mem_get_fd(void *,int *);
extern int duss_hal_mem_map(void *,void **);
extern int duss_hal_mem_unmap(void *);
extern int duss_hal_mem_get_size(void *,uint32_t *);
extern int duss_hal_mem_sync_ext(void *,unsigned,unsigned,uint64_t);
typedef void (*native_fn)(const char *,const char *,void *,void *);
static native_fn original;
extern void x2v_color_observe(const char *,const char *,const void *);
enum { CLOSED=0x80000000u, COUNT_MASK=0x7fffffffu, SLOTS=8 };
struct sample {uint32_t pixel,aux,width,height,stride,offset,ph,planes;};
struct x2v_hook_clip {
 struct x2v_clip_descriptor descriptor;
 struct x2v_receiver *receiver;
 struct sample samples[SLOTS];
 _Atomic unsigned ready[SLOTS],seen,rejected;
 _Atomic int vendor_error,hal_unmap_error;
};
static struct x2v_clip_publication publication;
static uintptr_t original_address,hook_address,got_address;
static int pinned,got_is_hook;
void cam_filter_dump_frame_data(const char *,const char *,void *,void *);
static uint32_t u32(const void*p,size_t o){uint32_t v;memcpy(&v,(const char*)p+o,4);return v;}
static uint64_t u64(const void*p,size_t o){uint64_t v;memcpy(&v,(const char*)p+o,8);return v;}
static int equal(const char*a,const char*b){if(!a)return 0;while(*b){if(*a++!=*b++)return 0;}return !*a;}

int x2v_hook_bind(void){
 void*p=dlsym(RTLD_NEXT,"cam_filter_dump_frame_data");memcpy(&original,&p,sizeof p);Dl_info d={0};
 if(!p||!dladdr(p,&d)||!d.dli_fname)return EINVAL;
 const char*b=strrchr(d.dli_fname,'/');b=b?b+1:d.dli_fname;
 if(strcmp(b,"libdcam_frwk.so")||memcmp(p,original_dump_pin,sizeof original_dump_pin))return EINVAL;
 pinned=1;original_address=(uintptr_t)p;hook_address=(uintptr_t)&cam_filter_dump_frame_data;
 memcpy(&got_address,(void*)(original_address-0x20a0b0+0x36f978),8);got_is_hook=got_address==hook_address;
 return got_is_hook?0:EINVAL;
}
struct x2v_hook_clip *x2v_hook_clip_new(struct x2v_receiver *receiver,uint64_t generation){
 if(!receiver)return NULL;
 static struct x2v_hook_clip metadata[2];static unsigned used;
 if(used>=2||generation!=(uint64_t)used+1)return NULL;
 struct x2v_hook_clip *h=&metadata[used++];
 h->receiver=receiver;
 for(unsigned i=0;i<SLOTS;i++)atomic_init(&h->ready[i],0);
 atomic_init(&h->seen,0);atomic_init(&h->rejected,0);atomic_init(&h->vendor_error,0);atomic_init(&h->hal_unmap_error,0);
 if(x2v_clip_descriptor_init(&h->descriptor,h,generation))return NULL;
 return h;
}
int x2v_hook_open(struct x2v_hook_clip *h){
 if(!h||!pinned||!got_is_hook)return EINVAL;
 return x2v_clip_publish(&publication,&h->descriptor);
}
void x2v_hook_close(struct x2v_hook_clip *h){if(h)(void)x2v_clip_withdraw(&publication,&h->descriptor);}
int x2v_receiver_callback_active(struct x2v_hook_clip *h){return h?(int)x2v_clip_lease_count(&h->descriptor):0;}
int x2v_receiver_vendor_error(struct x2v_hook_clip *h){return h?atomic_load(&h->vendor_error):0;}

/* Cached original/token. No getenv, dlsym, stdio, allocator or file IO here.
 * Only a synchronous original callback lease permits HAL map/sync/read/unmap.
 * cfg/frame/parent pools are never altered or retained by this shim. */
void cam_filter_dump_frame_data(const char*name,const char*port,void*cfg,void*frame){
 x2v_color_observe(name,port,frame);
 struct x2v_clip_lease lease={0};struct x2v_hook_clip *h=NULL;
 if(frame&&equal(name,X2V_NAME)&&equal(port,X2V_PORT)&&!x2v_clip_enter(&publication,&lease)){
  h=lease.receiver_context;
  struct x2v_receiver *ctx=h->receiver;
  struct sample r={u32(frame,0x28),u32(frame,0x2c),u32(frame,0x38),u32(frame,0x3c),u32(frame,0x40),u32(frame,0x44),u32(frame,0x4c),u32(frame,0xb0)};
  unsigned n=atomic_fetch_add(&h->seen,1);if(n<SLOTS){h->samples[n]=r;atomic_store_explicit(&h->ready[n],1,memory_order_release);}
  int match=r.pixel==X2V_PIXEL&&r.width==X2V_WIDTH&&r.height==X2V_HEIGHT&&r.stride==X2V_STRIDE&&r.offset==0&&r.ph==X2V_HEIGHT&&r.planes==1;
  if(!match)atomic_fetch_add(&h->rejected,1);
  struct x2v_ticket ticket;
  int admitted=match?x2v_receiver_reserve(ctx,u32(frame,0xb4),u64(frame,0x30),&ticket):EAGAIN;
  if(!admitted){
   /* Reservation is admission authorization BEFORE map. A D/duration closure
    * after it may occur before map; this existing finite lease still completes
    * map/sync/copy/unmap. No native handle leaves this callback. */
   void*handle=(void*)(uintptr_t)u64(frame,0x20),*p=NULL;uint32_t bytes=0,flags=0;int fd=0;
   int flags_rc=handle?duss_hal_mem_get_flags(handle,&flags):EINVAL,fd_rc=handle?duss_hal_mem_get_fd(handle,&fd):EINVAL;
   /* Read-only diagnostics on this borrowed handle. FD is never closed,
    * retained, fcntl-modified or remapped; queries do not select cache policy. */
   x2v_receiver_note_mapping(ctx,&ticket,flags_rc,flags,fd_rc,fd);
   int e=handle?duss_hal_mem_get_size(handle,&bytes):EINVAL;
   if(!e&&(bytes<X2V_BYTES||bytes>33554432))e=EOVERFLOW;
   if(!e){e=duss_hal_mem_map(handle,&p);if(!e){
    e=p?duss_hal_mem_sync_ext(handle,1,0,X2V_BYTES):EFAULT;
    if(!e)e=x2v_receiver_copy_reserved(ctx,&ticket,p,X2V_BYTES);
    int unmap=duss_hal_mem_unmap(handle);
    if(unmap){atomic_store(&h->hal_unmap_error,unmap);if(!e)e=unmap;}
   }}
   x2v_receiver_finish_reserved(ctx,&ticket,e);
   if(e){atomic_store(&h->vendor_error,e);x2v_receiver_disarm(ctx);}
  }else if(admitted!=EAGAIN){atomic_store(&h->vendor_error,admitted);x2v_receiver_disarm(ctx);}

 }
 if(original)original(name,port,cfg,frame);
 if(lease.descriptor)(void)x2v_clip_release(&lease);
}

size_t x2v_hook_json(struct x2v_hook_clip *h,char*out,size_t cap){
 if(!h)return 0;
 int n=snprintf(out,cap,"\"binding_pinned\":%d,\"got_is_hook\":%d,\"hook_window_closed\":%d,\"seen\":%u,\"rejected\":%u,\"vendor_error\":%d,\"hal_unmap_error\":%d,\"expected_pixel\":%u,\"samples\":[",pinned,got_is_hook,x2v_clip_closed(&h->descriptor),atomic_load(&h->seen),atomic_load(&h->rejected),atomic_load(&h->vendor_error),atomic_load(&h->hal_unmap_error),X2V_PIXEL);
 if(n<0||(size_t)n>=cap)return 0;size_t pos=n;unsigned emitted=0;
 for(unsigned i=0;i<SLOTS;i++){if(!atomic_load_explicit(&h->ready[i],memory_order_acquire))continue;struct sample*r=&h->samples[i];
  n=snprintf(out+pos,cap-pos,"%s{\"pixel_28\":%u,\"aux_2c\":%u,\"width\":%u,\"height\":%u,\"stride\":%u,\"offset\":%u,\"planeheight\":%u,\"planes\":%u}",emitted++?",":"",r->pixel,r->aux,r->width,r->height,r->stride,r->offset,r->ph,r->planes);
  if(n<0||(size_t)n>=cap-pos)return 0;pos+=n;
 }
 if(pos+2>=cap)return 0;out[pos++]=']';out[pos]=0;return pos;
}
