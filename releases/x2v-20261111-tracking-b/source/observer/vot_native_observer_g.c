/* TEST ONLY. No operation is issued to a camera, ML engine, AF or Qt object.
 * Wrap only the exact native VOT DDS subscription, forwarding original calls.
 * Callbacks copy into bounded owned slots; all JSON/file I/O runs on publisher.
 */
#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "../packet-layout-corrected/vot_packet.h"
extern void *__loader_dlsym(void *,const char *,const void *);
typedef void (*Callback)(void *,void *,uint32_t);
static _Atomic(uintptr_t) ind_handle,rsp_handle,req_handle;
static _Atomic(Callback) original_callback;
static _Atomic(Callback) original_af_node_callback;
static _Atomic unsigned af_node_callbacks,af_node_frame,af_node_bytes;
static _Atomic uint64_t af_node_ns;
static _Atomic unsigned af_node_mode=~0u,af_node_producer;

static _Atomic int callback_bound;
static _Atomic(uintptr_t) callback_user;
static _Atomic unsigned subscription_generation;
static _Atomic unsigned callbacks,invalid_packets,slot_drops,seed_counter;
static _Atomic unsigned pending_seed_tag,last_native_frame,seed_frame_floor;
static atomic_flag slot_lock=ATOMIC_FLAG_INIT;
static struct {
 unsigned char packet[VOT_MAX_PACKET];uint32_t bytes;uint64_t rx_ns;double rx_ms;
 unsigned seed,subscription;unsigned char ack[16],request[40];unsigned ack_seq,request_seq;
 uint64_t ack_ns,request_ns;
} slot;
static pthread_once_t once=PTHREAD_ONCE_INIT;
static int enabled(void) { const char *p=getenv("X2V_VOT_OBSERVER");return p&&!strcmp(p,"1"); }
static uint64_t mono_ns(void) { struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return (uint64_t)t.tv_sec*1000000000ull+(unsigned long)t.tv_nsec; }
static double wall_ms(void) { struct timespec t;clock_gettime(CLOCK_REALTIME,&t);return (double)t.tv_sec*1000+t.tv_nsec/1e6; }
static void *next(const char *s,const void *caller) { return __loader_dlsym(RTLD_NEXT,s,caller); }
static int native_callback(Callback fn) {
 Dl_info d={0};void *p;memcpy(&p,&fn,sizeof p);
 if (!dladdr(p,&d)||!d.dli_fname||!d.dli_fbase) return 0;
 const char *b=strrchr(d.dli_fname,'/');b=b?b+1:d.dli_fname;
 // Verified ELF first PT_LOAD VA=0; exact local adapter signature is Pv,S_,j.
 return !strcmp(b,"camera-service") && (uintptr_t)p==(uintptr_t)d.dli_fbase+0x2cac60;
}
static int af_node_callback(Callback fn) {
 Dl_info d={0},a={0};void *pc;memcpy(&pc,&fn,sizeof pc);
 if(!dladdr(pc,&d)||!d.dli_fname)return 0;
 const char*b=strrchr(d.dli_fname,'/');b=b?b+1:d.dli_fname;
 if(strcmp(b,"libdcam_plugins_AIO.so"))return 0;
 void *anchor=__loader_dlsym(RTLD_DEFAULT,"_dsh_frame_buffer_remote_observer_on_frame",(void*)&af_node_callback);
 if(!anchor||!dladdr(anchor,&a)||a.dli_fbase!=d.dli_fbase)return 0;
 // Matching AIO exported anchor VA=0x1dc040, native ROI callback VA=0x31dd78.
 return (uintptr_t)pc==(uintptr_t)anchor-0x1dc040+0x31dd78;
}
static void on_af_node_ind(void *data,void *user,uint32_t n) {
 atomic_fetch_add(&af_node_callbacks,1);atomic_store(&af_node_bytes,n);
 atomic_store(&af_node_ns,mono_ns());
 if(user){unsigned mode;uintptr_t producer;memcpy(&mode,(char*)user+0xa0,4);memcpy(&producer,(char*)user+0xa8,8);
  atomic_store(&af_node_mode,mode);atomic_store(&af_node_producer,producer!=0);}

 if(data&&n>=0x48)atomic_store(&af_node_frame,vot_u32((unsigned char*)data+0x10));
 Callback real=atomic_load(&original_af_node_callback);
 if(real)real(data,user,n);
}
static void on_ind(void *data,void *user,uint32_t n) {
 atomic_fetch_add(&callbacks,1);
 if ((uintptr_t)user==atomic_load(&callback_user) && data && n>=0x48 && n<=VOT_MAX_PACKET &&
     (size_t)((unsigned char*)data)[0x44]<=(n-0x48u)/0x34u) {
  uint32_t frame=vot_u32((unsigned char*)data+0x10),old=atomic_load(&last_native_frame);
  uint32_t delta=frame-old;
  if(delta&&delta<0x80000000u)atomic_compare_exchange_strong(&last_native_frame,&old,frame);
  if (!atomic_flag_test_and_set_explicit(&slot_lock,memory_order_acquire)) {
   memcpy(slot.packet,data,n);slot.bytes=n;slot.rx_ns=mono_ns();slot.rx_ms=wall_ms();
   unsigned generation=atomic_load(&seed_counter);uint32_t since=frame-atomic_load(&seed_frame_floor);
   slot.seed=generation&&(!since||since>=0x80000000u)?generation-1:generation;
   slot.subscription=atomic_load(&subscription_generation);
   atomic_flag_clear_explicit(&slot_lock,memory_order_release);
  } else atomic_fetch_add(&slot_drops,1);
 } else atomic_fetch_add(&invalid_packets,1);
 Callback real=atomic_load(&original_callback);
 if (real) real(data,user,n);
}
static void atomic_json(const char *text,size_t n) {
 const char *tmp="/tmp/x2v-live/vot-state.json.tmp";
 FILE *f=fopen(tmp,"w");if(!f)return;
 int ok=fwrite(text,1,n,f)==n;
 if(fclose(f))ok=0;
 if(ok)rename(tmp,"/tmp/x2v-live/vot-state.json");
}
static void *publish(void *unused) {
 (void)unused;
 unsigned char packet[VOT_MAX_PACKET],ack[16]={0},request[40]={0};
 uint32_t bytes=0;uint64_t rx=0,ack_ns=0,request_ns=0;double rx_ms=0;
 unsigned seed=0,ack_seq=0,request_seq=0,subscription=0;int status=0;uint64_t last_rx=0;
 const char *capture_env=getenv("X2V_VOT_CAPTURE_PACKETS");
 int capture_enabled=capture_env&&!strcmp(capture_env,"1");
 unsigned captured_packets=0;uint64_t captured_rx=0;
 unsigned lifecycle=0;uint64_t started=mono_ns();
 char epoch[80];snprintf(epoch,sizeof epoch,"vot/%ld/%llu",(long)getpid(),(unsigned long long)started);
 unsigned last_seed=0;uint32_t last_frame=0;int have_frame=0;uint64_t ordered_seq=0;
 uint64_t traced_rx=0;unsigned traced_ack=0,traced_request=0,ticks=0;FILE *trace=NULL;
 for (;;) {
  struct timespec pause={0,33000000};nanosleep(&pause,NULL);
  unsigned current_subscription=atomic_load(&subscription_generation);
  if(subscription!=current_subscription){
   subscription=current_subscription;status=0;have_frame=0;ordered_seq=0;last_rx=0;last_seed=0;lifecycle++;
   snprintf(epoch,sizeof epoch,"vot/%ld/%llu/%u",(long)getpid(),(unsigned long long)started,subscription);
  }
  if(atomic_flag_test_and_set_explicit(&slot_lock,memory_order_acquire))continue;
  bytes=slot.bytes;if(bytes)memcpy(packet,slot.packet,bytes);
  unsigned packet_subscription=slot.subscription;
  rx=slot.rx_ns;rx_ms=slot.rx_ms;seed=slot.seed;
  if(slot.ack_seq!=ack_seq){ack_seq=slot.ack_seq;memcpy(ack,slot.ack,16);ack_ns=slot.ack_ns;
   if(!vot_u32(ack+12)){status=ack[9];lifecycle++;}}
  if(slot.request_seq!=request_seq){request_seq=slot.request_seq;memcpy(request,slot.request,40);request_ns=slot.request_ns;}
  atomic_flag_clear_explicit(&slot_lock,memory_order_release);
  if(packet_subscription!=subscription)bytes=0;
  // Publisher-only diagnostics; preserve raw native bytes independently of
  // ROI parser validity. The ACK-generated seed and receive time exclude
  // Proposal packets retained from before successful arbitrary startup.
  if(capture_enabled && captured_packets<8 && bytes>=0x48 && bytes<=VOT_MAX_PACKET &&
     packet[0x1c]==9 && status==21 && seed>0 && rx>ack_ns && rx!=captured_rx){
   unsigned number=captured_packets++;captured_rx=rx;
   char path[80];snprintf(path,sizeof path,"/tmp/x2v-live/vot-packet-%u.bin",number);
   FILE *raw=fopen(path,"wb");int saved=0;
   if(raw){saved=fwrite(packet,1,bytes,raw)==bytes;if(fclose(raw))saved=0;}
   FILE *index=fopen("/tmp/x2v-live/vot-packet-index.jsonl",number?"a":"w");
   if(index){
    fprintf(index,"{\"index\":%u,\"epoch\":\"%s\",\"nativeSeedSeq\":%u,\"frameId\":%u,\"bytes\":%u,\"receivedMonotonicNs\":%llu,\"ackMonotonicNs\":%llu,\"saved\":%s}\n",
     number,epoch,seed,vot_u32(packet+0x10),bytes,(unsigned long long)rx,
     (unsigned long long)ack_ns,saved?"true":"false");
    fclose(index);
   }
  }
  VotResult r={0};int parsed=bytes&&vot_packet(packet,bytes,&r);
  int new_result=parsed&&rx!=last_rx;
  if(new_result){
   uint32_t delta=r.frame_id-last_frame;
   if(!have_frame){ordered_seq=r.frame_id;have_frame=1;last_frame=r.frame_id;}
   else if(delta&&delta<0x80000000u){ordered_seq+=delta;last_frame=r.frame_id;}
   else new_result=0; // duplicate / late result never refreshes the green frame
   last_rx=rx;
  }
  char result[1100]="null";
  // Preserve receipt timestamp and sequence while holding the same packet.
  // A heartbeat must never make an old target result appear fresh.
  if(parsed && seed && r.kind==9 && status==21 && (new_result || (seed==last_seed && have_frame && r.frame_id==last_frame))) {
   snprintf(result,sizeof result,
    "{\"origin\":\"native_vot_result\",\"epoch\":\"%s\",\"nativeSeedSeq\":%u,\"frameSeq\":%llu,\"nativeFrameId\":%u,\"observedAt\":%.3f,\"receivedMonotonicNs\":%llu,\"sourceTimestampNs\":null,\"targetId\":%d,\"selected_found\":%s,\"record_type\":%u,\"available\":%s,\"arbitrary\":%s,\"tracked\":%s,\"lost\":%s,\"statusRaw\":%u,\"confidence\":%.8g,\"region\":{\"x\":%.8g,\"y\":%.8g,\"width\":%.8g,\"height\":%.8g}}",
    epoch,seed,(unsigned long long)ordered_seq,r.frame_id,rx_ms,(unsigned long long)rx,r.selected_id,
    r.selected_found?"true":"false",r.record_type,r.available?"true":"false",r.arbitrary?"true":"false",r.tracked?"true":"false",r.lost?"true":"false",r.status,
    isfinite(r.confidence)?r.confidence:0,isfinite(r.x)?r.x:0,isfinite(r.y)?r.y:0,isfinite(r.w)?r.w:0,isfinite(r.h)?r.h:0);
  }
  last_seed=seed;
  int active=status==1||status==2||status==3||status==4||status==21;
  char header[33];for(unsigned i=0;i<16;i++)snprintf(header+i*2,3,"%02x",bytes?packet[i]:0);
  char control_hex[81],ack_hex[33],control_run_mode[16]="null";
  for(unsigned i=0;i<40;i++)snprintf(control_hex+i*2,3,"%02x",request[i]);
  for(unsigned i=0;i<16;i++)snprintf(ack_hex+i*2,3,"%02x",ack[i]);
  // Worker::start uses request+16 as run_mode only for START/start_type1.
  // For start_type2 the same byte is click_type, never a run_mode.
  if(request_seq && request[9]==1 && request[12]==1)
   snprintf(control_run_mode,sizeof control_run_mode,"%u",request[16]);
  const char *ui=getenv("X2V_VOT_UI");
  char json[3200];int n=snprintf(json,sizeof json,
   "{\"schema\":1,\"enabled\":%s,\"backendReady\":%s,\"epoch\":\"%s\",\"servicePid\":%ld,\"observedAt\":%.3f,\"sourceSeq\":%llu,\"nativeSeedSeq\":%u,\"mlRunning\":%s,\"workerActive\":%s,\"lifecycleSeq\":%u,\"mlStatusRaw\":%d,\"ackError\":%u,\"ackMonotonicNs\":%llu,\"lastControlMonotonicNs\":%llu,\"lastControlType\":%u,\"lastControlStartType\":%u,\"lastControlClickType\":%u,\"controlRequestHex40\":\"%s\",\"ackHex16\":\"%s\",\"controlRunMode\":%s,\"callbackCount\":%u,\"afNodeCallbackCount\":%u,\"afNodeMode\":%u,\"afNodeHasProducer\":%u,\"afNodeFrame\":%u,\"afNodeBytes\":%u,\"afNodeMonotonicNs\":%llu,\"invalidPacketCount\":%u,\"slotDropCount\":%u,\"resultReceivedMonotonicNs\":%llu,\"nativeFrameId\":%u,\"packetKind\":%u,\"header16Raw\":\"%s\",\"result\":%s}\n",
   ui&&!strcmp(ui,"1")?"true":"false",atomic_load(&callback_bound)&&atomic_load(&rsp_handle)?"true":"false",
   epoch,(long)getpid(),wall_ms(),(unsigned long long)ordered_seq,atomic_load(&seed_counter),active?"true":"false",active?"true":"false",
   lifecycle,status,vot_u32(ack+12),(unsigned long long)ack_ns,(unsigned long long)request_ns,request[9],request[12],request[16],control_hex,ack_hex,control_run_mode,
   atomic_load(&callbacks),atomic_load(&af_node_callbacks),atomic_load(&af_node_mode),atomic_load(&af_node_producer),atomic_load(&af_node_frame),atomic_load(&af_node_bytes),(unsigned long long)atomic_load(&af_node_ns),atomic_load(&invalid_packets),atomic_load(&slot_drops),(unsigned long long)rx,r.frame_id,r.kind,header,result);
  if(n>0&&(size_t)n<sizeof json){
   atomic_json(json,(size_t)n);
   if(rx!=traced_rx||ack_seq!=traced_ack||request_seq!=traced_request||!(++ticks%10)){
    if(!trace)trace=fopen("/tmp/x2v-live/vot-trace.jsonl","w");
    if(trace){fwrite(json,1,(size_t)n,trace);fflush(trace);if(ftell(trace)>2*1024*1024){fclose(trace);trace=NULL;}}
    traced_rx=rx;traced_ack=ack_seq;traced_request=request_seq;
   }
  }
 }
 return NULL;
}
static void begin(void){pthread_t t;if(!pthread_create(&t,NULL,publish,NULL))pthread_detach(t);}
int duss_ps_subscriber_create(void *a,const void *b,const void *c,void **out) {
 typedef int(*Fn)(void*,const void*,const void*,void**);void *p=next("duss_ps_subscriber_create",(void*)&duss_ps_subscriber_create);Fn real;memcpy(&real,&p,sizeof real);if(!real)return -1003;
 int rc=real(a,b,c,out);
 if(enabled()&&!rc&&c&&out&&*out){const char *name=NULL;memcpy(&name,c,sizeof name);
  if(name&&!strcmp(name,"ml_main_cam_vot_ind")){atomic_store(&callback_bound,0);atomic_store(&pending_seed_tag,0);atomic_store(&last_native_frame,0);atomic_fetch_add(&subscription_generation,1);atomic_store(&ind_handle,(uintptr_t)*out);pthread_once(&once,begin);}
  if(name&&!strcmp(name,"ml_main_cam_vot_ctrl_rsp"))atomic_store(&rsp_handle,(uintptr_t)*out);
 }
 return rc;
}
int duss_ps_publisher_create(void *a,const void *b,const void *c,void **out) {
 typedef int(*Fn)(void*,const void*,const void*,void**);void*p=next("duss_ps_publisher_create",(void*)&duss_ps_publisher_create);Fn real;memcpy(&real,&p,sizeof real);if(!real)return -1003;
 int rc=real(a,b,c,out);
 if(enabled()&&!rc&&c&&out&&*out){const char*name=NULL;memcpy(&name,c,sizeof name);if(name&&!strcmp(name,"ml_main_cam_vot_ctrl_req"))atomic_store(&req_handle,(uintptr_t)*out);}
 return rc;
}
int duss_ps_msg_async_receive(void *handle,void *user,Callback cb) {
 typedef int(*Fn)(void*,void*,Callback);void*p=next("duss_ps_msg_async_receive",(void*)&duss_ps_msg_async_receive);Fn real;memcpy(&real,&p,sizeof real);if(!real)return -1003;
 if(enabled()&&cb&&af_node_callback(cb)){
  atomic_store(&original_af_node_callback,cb);
  return real(handle,user,on_af_node_ind);
 }
 if(enabled()&&(uintptr_t)handle==atomic_load(&ind_handle)&&cb&&native_callback(cb)){
  atomic_store(&original_callback,cb);atomic_store(&callback_user,(uintptr_t)user);int rc=real(handle,user,on_ind);if(!rc)atomic_store(&callback_bound,1);return rc;
 }
 return real(handle,user,cb);
}
int duss_ps_msg_send(void *h,int timeout,void *data,uint32_t n) {
 typedef int(*Fn)(void*,int,void*,uint32_t);void*p=next("duss_ps_msg_send",(void*)&duss_ps_msg_send);Fn real;memcpy(&real,&p,sizeof real);if(!real)return -1003;
 int scope=enabled()&&(uintptr_t)h==atomic_load(&req_handle)&&data&&n==40;
 // sendTrackingTarget's ROI branch sets click_type=9 at request+0x10.
 // +0x11 is TrackingMode, not the arbitrary seed discriminator.
 unsigned seed_tag=scope&&vot_seed_request(data,n)?(unsigned)((unsigned char*)data)[8]+1:0;
 if(seed_tag)atomic_store(&pending_seed_tag,seed_tag);
 if(scope){
  if(!atomic_flag_test_and_set_explicit(&slot_lock,memory_order_acquire)){memcpy(slot.request,data,40);slot.request_ns=mono_ns();slot.request_seq++;atomic_flag_clear_explicit(&slot_lock,memory_order_release);}}
 int rc=real(h,timeout,data,n);
 if(rc&&seed_tag)atomic_compare_exchange_strong(&pending_seed_tag,&seed_tag,0);
 return rc;
}
int duss_ps_msg_receive(void *h,int timeout,void *data,uint32_t *n) {
 typedef int(*Fn)(void*,int,void*,uint32_t*);void*p=next("duss_ps_msg_receive",(void*)&duss_ps_msg_receive);Fn real;memcpy(&real,&p,sizeof real);if(!real)return -1003;
 int rc=real(h,timeout,data,n);
 if(enabled()&&!rc&&(uintptr_t)h==atomic_load(&rsp_handle)&&data&&n&&*n>=16){
  unsigned tag=atomic_load(&pending_seed_tag);
  if(tag&&vot_seed_ack(data,*n,tag)){
   atomic_store(&seed_frame_floor,atomic_load(&last_native_frame));
   atomic_fetch_add(&seed_counter,1);atomic_store(&pending_seed_tag,0);
  } else if(tag)atomic_store(&pending_seed_tag,0);
  if(!atomic_flag_test_and_set_explicit(&slot_lock,memory_order_acquire)){memcpy(slot.ack,data,16);slot.ack_ns=mono_ns();slot.ack_seq++;atomic_flag_clear_explicit(&slot_lock,memory_order_release);}}
 if((uintptr_t)h==atomic_load(&rsp_handle)&&(rc||!data||!n||*n<16))atomic_store(&pending_seed_tag,0);
 return rc;
}
int duss_ps_subscriber_destroy(void *h) {
 typedef int(*Fn)(void*);void*p=next("duss_ps_subscriber_destroy",(void*)&duss_ps_subscriber_destroy);Fn real;memcpy(&real,&p,sizeof real);if(!real)return -1003;
 if((uintptr_t)h==atomic_load(&ind_handle)){atomic_store(&callback_bound,0);atomic_store(&ind_handle,0);}
 if((uintptr_t)h==atomic_load(&rsp_handle))atomic_store(&rsp_handle,0);
 return real(h);
}
