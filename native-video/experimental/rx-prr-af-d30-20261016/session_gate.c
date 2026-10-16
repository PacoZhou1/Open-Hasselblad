#define _GNU_SOURCE 1
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdatomic.h>
#include <dlfcn.h>
#include <time.h>
#include <unistd.h>
#include <sys/syscall.h>
/* receiver_v18 target_start_gate.c (sha 0a634000a794…), plus the resident session guard.
 * Actual service286fb8 stores group name at params+0xc (72B), then
 * 286fec -> _updateStreamingParams -> native cam_cap_eng_set_streaming_params.
 * service287244 calls start(engine,consumer_collection), NOT group-name x1.
 * Preserve the native signatures; this gate invokes no new hardware API.
 *
 * While a resident session streams group13, the stock GUI still drives the
 * service: its live-view entry stops the primary group, starts the stock still
 * group and the ToF group (which re-times the sensor to 50 Hz). The service
 * treats any failure there as fatal, so those calls are answered with success
 * and not executed until the session releases the guard before its own teardown.
 * start_stream/stop_stream act on the engine's current group (+0x2e8), which
 * stays group13 while set_streaming_params is absorbed, so they are absorbed too. */
extern void *__loader_dlsym(void *,const char *,const void *);
extern int x2v_mode21_descriptor_ready(void);
extern int x2v_mode21_fps_guard_ready(void);
extern int x2v_graph_parser_ready(void);
extern int x2v_target_parser_owner(void *);
extern int x2v_target_parser_class(void *);
extern int x2v_session_guard(void);
#ifndef X2V_ALLOW_MODE21_START
#define X2V_ALLOW_MODE21_START 0
#endif

/* Bounded lifecycle logging; no extra parameter reads beyond the proven
 * 12-byte prefix and 72-byte group name, and no hardware operations. */
static _Atomic unsigned tof_trace_seq;
static unsigned tof_trace_begin(const char *op, void *engine, void *caller,
                                const void *params, const void *argument)
{
 unsigned seq=atomic_fetch_add(&tof_trace_seq,1)+1;
 if(seq>128)return seq;
 struct timespec ts={0};clock_gettime(CLOCK_MONOTONIC,&ts);
 Dl_info info={0};int have=dladdr(caller,&info);
 const char *module=have&&info.dli_fname?strrchr(info.dli_fname,'/'):NULL;
 module=module?module+1:(have&&info.dli_fname?info.dli_fname:"unknown");
 uintptr_t offset=have?(uintptr_t)caller-(uintptr_t)info.dli_fbase:0;
 uint32_t prefix[3]={0};if(params)memcpy(prefix,params,sizeof prefix);
 fprintf(stderr,"X2V_TOF_TRACE begin seq=%u mono=%lld.%09ld tid=%ld op=%s engine=%p caller=%s+0x%lx arg=%p prefix=%08x,%08x,%08x group=%.72s\n",
  seq,(long long)ts.tv_sec,ts.tv_nsec,(long)syscall(SYS_gettid),op,engine,
  module,(unsigned long)offset,argument,prefix[0],prefix[1],prefix[2],
  params?(const char*)params+0xc:"");
 return seq;
}
static void tof_trace_end(unsigned seq,int rc)
{
 if(!seq||seq>128)return;
 struct timespec ts={0};clock_gettime(CLOCK_MONOTONIC,&ts);
 fprintf(stderr,"X2V_TOF_TRACE end seq=%u mono=%lld.%09ld rc=%d\n",
  seq,(long long)ts.tv_sec,ts.tv_nsec,rc);
}

static _Atomic(uintptr_t) known_engine;
static _Atomic(uintptr_t) scope_engine;
static _Atomic int applied_target, vendor_scope, uncertain, target_streaming;
static _Atomic unsigned absorbed;
static int target_stage(void){
 const char *s=getenv("X2V_OWNED_RAW_GRAPH"),*o=getenv("X2V_SOURCE_ADAPTER");
 return s&&o&&!strcmp(s,"mode21-d30")&&!strcmp(o,"mode21-d-30fps");
}
static int clear(void *engine){
 return X2V_ALLOW_MODE21_START && x2v_mode21_descriptor_ready() &&
        x2v_mode21_fps_guard_ready() && x2v_target_parser_owner(engine);
}
int x2v_mode21_vendor_allowed(void){
 return X2V_ALLOW_MODE21_START && target_stage() && atomic_load(&vendor_scope) &&
        !atomic_load(&uncertain) && x2v_mode21_descriptor_ready() && x2v_mode21_fps_guard_ready() &&
        x2v_target_parser_owner((void*)atomic_load(&scope_engine));
}
static int reject(const char *where){
 fprintf(stderr,"X2V_GRAPH target blocked entry=%s build_allow=%d descriptor_ready=%d fps_guard_ready=%d parser_ready=%d\n",where,X2V_ALLOW_MODE21_START,x2v_mode21_descriptor_ready(),x2v_mode21_fps_guard_ready(),x2v_graph_parser_ready());
 return -1003;
}
static int guarded(void){ return target_stage() && atomic_load(&target_streaming) && x2v_session_guard(); }
static int absorb(const char *where,void *engine,const char *group){
 unsigned n=atomic_fetch_add(&absorbed,1)+1;
 if(n<=64||!(n%256))
  fprintf(stderr,"X2V_GRAPH session_guard absorbed entry=%s role=%d group=%.72s n=%u\n",where,x2v_target_parser_class(engine),group?group:"",n);
 return 0;
}
unsigned x2v_session_guard_absorbed(void){ return atomic_load(&absorbed); }
int cam_cap_eng_set_streaming_params(void *engine,void *params){
 typedef int (*fn)(void*,void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_set_streaming_params",(void*)&cam_cap_eng_set_streaming_params);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(target_stage()){
  if(!engine||!params)return reject("unknown_params");
  const char *name=(const char*)params+0xc;
  if(!memchr(name,0,72)||!name[0])return reject("unknown_group");
  int target=!strcmp(name,"normal_liveview_raw_calib");
  /* Native ToF is a distinct registered engine. It cannot acquire HB24 scope
   * and must not disturb primary session state. Unknown engines stay denied. */
  int role=x2v_target_parser_class(engine);
  if(role==2){
   if(target)return reject("target_on_tof_engine");
   unsigned seq=tof_trace_begin("set_params",engine,__builtin_return_address(0),params,NULL);
   int rc=real(engine,params);tof_trace_end(seq,rc);return rc;
  }
  if(role!=1)return reject("unbound_profile_engine");
  uintptr_t old=atomic_load(&known_engine);
  if(old&&old!=(uintptr_t)engine)return reject("second_engine");
  if(guarded())return absorb("set_params",engine,name);
  if(target&&!clear(engine))return reject("set_streaming_params");
  /* Private HB24 prepare can occur synchronously INSIDE this native call.
   * Grant only this validated group13 transaction, not any profile2 choice. */
  atomic_store(&vendor_scope,0);
  atomic_store(&scope_engine,0);
  if(target){atomic_store(&scope_engine,(uintptr_t)engine);atomic_store(&uncertain,0);atomic_store(&vendor_scope,1);}
  int rc=real(engine,params);
  /* Commit ONLY after native success. Failure retains old applied group;
   * later start cannot escape target gate through a failed normal update. */
  if(!rc&&x2v_target_parser_owner(engine)){atomic_store(&applied_target,target);atomic_store(&known_engine,(uintptr_t)engine);atomic_store(&uncertain,0);atomic_store(&vendor_scope,target);}
  else{atomic_store(&uncertain,1);atomic_store(&vendor_scope,0);atomic_store(&scope_engine,0);}
  if(!target)atomic_store(&target_streaming,0);
  return rc;
 }
 return real(engine,params);
}
int cam_cap_eng_start_streaming(void *engine,void *consumers){
 typedef int (*fn)(void*,void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_start_streaming",(void*)&cam_cap_eng_start_streaming);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(target_stage()){
  int role=x2v_target_parser_class(engine);
  if(role==2){
   unsigned seq=tof_trace_begin("start_streaming",engine,__builtin_return_address(0),NULL,consumers);
   int rc=real(engine,consumers);tof_trace_end(seq,rc);return rc;
  }
  if(role!=1)return reject("start_unbound_profile_engine");
  if(!engine||atomic_load(&known_engine)!=(uintptr_t)engine)return reject("start_unknown_engine");
  if(guarded())return absorb("start_streaming",engine,NULL);
  if(atomic_load(&uncertain))return reject("start_uncertain_state");
  if(atomic_load(&applied_target)&&(!clear(engine)||!x2v_mode21_vendor_allowed()))return reject("start_streaming");
  int rc=real(engine,consumers);
  if(!rc&&atomic_load(&applied_target))atomic_store(&target_streaming,1);
  return rc;
 }
 return real(engine,consumers);
}
int cam_cap_eng_stop_streaming(void *engine){
 typedef int (*fn)(void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_stop_streaming",(void*)&cam_cap_eng_stop_streaming);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(guarded() && x2v_target_parser_class(engine)!=2)return absorb("stop_streaming",engine,NULL);
 unsigned seq=target_stage()&&x2v_target_parser_class(engine)==2?
  tof_trace_begin("stop_streaming",engine,__builtin_return_address(0),NULL,NULL):0;
 int rc=real(engine);tof_trace_end(seq,rc);
 if(!rc&&target_stage()&&x2v_target_parser_class(engine)==1)atomic_store(&target_streaming,0);
 return rc;
}
/* Native start_stream/stop_stream forward x1.. untouched to the current group's ops. */
int cam_cap_eng_start_stream(void *engine,void *a,void *b,void *c){
 typedef int (*fn)(void*,void*,void*,void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_start_stream",(void*)&cam_cap_eng_start_stream);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(guarded() && x2v_target_parser_class(engine)!=2)return absorb("start_stream",engine,NULL);
 unsigned seq=target_stage()&&x2v_target_parser_class(engine)==2?
  tof_trace_begin("start_stream",engine,__builtin_return_address(0),NULL,a):0;
 int rc=real(engine,a,b,c);tof_trace_end(seq,rc);return rc;
}
int cam_cap_eng_stop_stream(void *engine,void *a,void *b,void *c){
 typedef int (*fn)(void*,void*,void*,void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_stop_stream",(void*)&cam_cap_eng_stop_stream);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(guarded() && x2v_target_parser_class(engine)!=2)return absorb("stop_stream",engine,NULL);
 unsigned seq=target_stage()&&x2v_target_parser_class(engine)==2?
  tof_trace_begin("stop_stream",engine,__builtin_return_address(0),NULL,a):0;
 int rc=real(engine,a,b,c);tof_trace_end(seq,rc);return rc;
}

/* Observe delivery across the native C++ ToF filter; preserve the original calls.
 * sendDataToRcam copies exactly 0x2334 bytes from data+4 in this firmware. */
static _Atomic unsigned tof_in_count,tof_out_count;
static void *tof_plugin_symbol(const char *name,const void *caller)
{
 static void *plugin;
 if(!plugin)plugin=dlopen("/system/lib64/camera/plugins/stream_filter/libdcam_x2dii_tof_stream_filter.so",RTLD_NOW|RTLD_NOLOAD);
 if(!plugin)return NULL;
 void *p=__loader_dlsym(plugin,name,caller);
 return p==caller?NULL:p;
}

int _ZN20X2DIITofStreamFilter8onBufferEP16cam_frame_buffer(void *self,void *frame)
{
 const char *name="_ZN20X2DIITofStreamFilter8onBufferEP16cam_frame_buffer";
 typedef int (*fn)(void*,void*);void *p=tof_plugin_symbol(name,(void*)&_ZN20X2DIITofStreamFilter8onBufferEP16cam_frame_buffer);fn real;memcpy(&real,&p,sizeof p);
 if(!real){fprintf(stderr,"X2V_TOF_STATS missing onBuffer\n");return -1012;}
 unsigned n=atomic_fetch_add(&tof_in_count,1)+1;
 if(n<=3||n%100==0)fprintf(stderr,"X2V_TOF_STATS input n=%u self=%p frame=%p\n",n,self,frame);
 return real(self,frame);
}
void _ZN20X2DIITofStreamFilter14sendDataToRcamERK26_af_tof_spot_input_data_s_RK8FocusRoi(void *self,const void *data,const void *roi)
{
 const char *name="_ZN20X2DIITofStreamFilter14sendDataToRcamERK26_af_tof_spot_input_data_s_RK8FocusRoi";
 typedef void (*fn)(void*,const void*,const void*);void *p=tof_plugin_symbol(name,(void*)&_ZN20X2DIITofStreamFilter14sendDataToRcamERK26_af_tof_spot_input_data_s_RK8FocusRoi);fn real;memcpy(&real,&p,sizeof p);
 if(!real){fprintf(stderr,"X2V_TOF_STATS missing sendData\n");return;}
 unsigned n=atomic_fetch_add(&tof_out_count,1)+1;
 /* Firmware onBuffer copies count<<3 although dumpDepthMap and libaaa both
  * consume 10-byte point records. Source buffer is self+0x4b18, capacity9000.
  * Use original SDK points; no distance, confidence or coordinate synthesis. */
 unsigned char complete[0x2338];unsigned count=0;memcpy(&count,(char*)data+12,4);
 if(atomic_load(&target_streaming)&&(count==225||count==900)){
  memcpy(complete,data,sizeof complete);
  const unsigned char*source=(unsigned char*)self+0x4b18;
  int prefix_equal=!memcmp((char*)data+16,source,count*8);
  if(prefix_equal){
   memcpy(complete+16,source,count*10);
   if(n==100||n==500){
    fprintf(stderr,"X2V_TOF_POINTS n=%u count=%u prefix_equal=1 bytes=%u->%u\n",n,count,count*8,count*10);
    char path[80];snprintf(path,sizeof path,"/tmp/x2v-tof-original-%u.bin",n);FILE*f=fopen(path,"wb");if(f){fwrite(data,1,sizeof complete,f);fclose(f);}
   }
   data=complete;
  }else if(n==100)fprintf(stderr,"X2V_TOF_POINTS prefix mismatch; original retained\n");
 }

 if(n<=3||n%100==0){
  uint32_t head[4]={0};memcpy(head,data,sizeof head);
  fprintf(stderr,"X2V_TOF_STATS output n=%u input=%u words=%08x,%08x,%08x,%08x\n",n,atomic_load(&tof_in_count),head[0],head[1],head[2],head[3]);
 }
 if(n==100||n==1500||n==3000){
  unsigned slot=n==100?1:(n==1500?2:3);
  char path[80];snprintf(path,sizeof path,"/tmp/x2v-tof-stat-%u.bin",slot);
  FILE *f=fopen(path,"wb");if(f){size_t count=fwrite(data,1,0x2338,f);fclose(f);fprintf(stderr,"X2V_TOF_STATS dump n=%u bytes=%zu\n",n,count);}
 }

 void *producer=NULL,*backing=NULL;memcpy(&producer,(char*)self+0x15358,8);if(producer)memcpy(&backing,(char*)producer+8,8);
 if(n<=3||!(n%100))fprintf(stderr,"X2V_TOF_PUBLISH n=%u producer=%p backing=%p\n",n,producer,backing);
 real(self,data,roi);
}

/* The vendor entry checks task size 0x23cc and type 5 before processing. */
int tof_dtof_ads6401_statistics(int channel,void *task)
{
 typedef int (*fn)(int,void*);
 void *p=__loader_dlsym(dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD),"tof_dtof_ads6401_statistics",(void*)&tof_dtof_ads6401_statistics);
 fn real;memcpy(&real,&p,sizeof p);
 if(!real){fprintf(stderr,"X2V_TOF_CONSUMER missing original\n");return -1;}
 static _Atomic unsigned calls;unsigned n=atomic_fetch_add(&calls,1)+1;
 uint32_t head[8]={0};if(task)memcpy(head,task,sizeof head);
 int rc=real(channel,task);
 if(n<=3||n%100==0)fprintf(stderr,"X2V_TOF_CONSUMER n=%u channel=%d size=%u type=%u frame=%u rc=%d\n",n,channel,head[1],head[4],head[5],rc);
 return rc;
}

int tof_lib_statistics_info(int channel,void *task)
{
 typedef int (*fn)(int,void*);void *p=__loader_dlsym(dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD),"tof_lib_statistics_info",(void*)&tof_lib_statistics_info);fn real;memcpy(&real,&p,sizeof p);
 if(!real){fprintf(stderr,"X2V_TOF_ROUTE missing statistics original\n");return -1;}
 static _Atomic unsigned calls;unsigned n=atomic_fetch_add(&calls,1)+1;
 uint32_t head[8]={0};if(task)memcpy(head,task,sizeof head);
 int rc=real(channel,task);
 if(n<=3||n%100==0)fprintf(stderr,"X2V_TOF_ROUTE stats n=%u ch=%d size=%u type=%u frame=%u rc=%d\n",n,channel,head[1],head[4],head[5],rc);
 return rc;
}

static void *tof_consumer;
static void (*tof_observer_original)(void*,unsigned,void*);
static void tof_observer(void *h,unsigned index,void *ctx){
 static _Atomic unsigned count;unsigned n=atomic_fetch_add(&count,1)+1;
 void *p;memcpy(&p,(char*)ctx+8,8);
 if(n<=3||!(n%100))fprintf(stderr,"X2V_TOF_OBSERVER n=%u index=%u active=%u\n",n,index,*((unsigned char*)p+0xac));
 tof_observer_original(h,index,ctx);
}
static _Atomic(void*) tof_provider;
static int (*tof_destroy_original)(void*);
static int tof_provider_destroy(void *provider){
 atomic_store(&tof_provider,NULL);
 fprintf(stderr,"X2V_TOF_REBIND destroy provider=%p\n",provider);
 return tof_destroy_original(provider);
}
/* Exact native provider object layout from matching librcam create():
 * destroy +0x00, activate +0x10, register +0x40, active +0xac.
 * Capture only the verified native ToF observer; invalidate before destruction.
 * Calls go through the native provider queue; no measurement or lens rewrite. */


static void (*tof_policy_load_original)(void*,const void*);
static void (*tof_policy_process_original)(void*,void*);
/* Use native load/reset/locking on the AF task itself. Keep the native master;
 * add ToF as asynchronous slave-pack (role4), as handled by native AF set_stat. */
static int tof_policy_extend(unsigned cfg[63]){
 unsigned count=cfg[0],slaves=0;
 if(!atomic_load(&target_streaming)||!count||count>=20)return 0;
 for(unsigned i=0;i<count;i++){if(cfg[3+i]==0x410605)return 0;if(cfg[23+2*i]==4)slaves++;}
 if(slaves>=2)return 0;
 cfg[3+count]=0x410605;cfg[23+2*count]=4;cfg[24+2*count]=0;cfg[0]=count+1;
 fprintf(stderr,"X2V_TOF_POLICY_FIX append count=%u master=%x slaves_before=%u\n",cfg[0],cfg[3],slaves);
 return 1;
}
static void tof_policy_load(void *policy,const void *list){
 unsigned cfg[63];memcpy(cfg,list,sizeof cfg);tof_policy_extend(cfg);tof_policy_load_original(policy,cfg);
}
static void tof_policy_process(void *policy,void *event){
 unsigned cfg[63];memcpy(cfg,(char*)policy+0x5c,sizeof cfg);
 if(tof_policy_extend(cfg))tof_policy_load_original(policy,cfg);
 tof_policy_process_original(policy,event);
}
static void tof_install_policy(void *iface,uintptr_t base){
 void *policy=NULL,*load=NULL,*process=NULL;
 memcpy(&policy,(char*)iface+0x210,8);if(!policy)return;
 memcpy(&load,(char*)policy+0x10,8);memcpy(&process,(char*)policy+0x18,8);
 if(load==(void*)&tof_policy_load)return;
 if(load!=(void*)(base+0x186e88)||process!=(void*)(base+0x187078))return;
 memcpy(&tof_policy_load_original,&load,8);memcpy(&tof_policy_process_original,&process,8);
 load=(void*)&tof_policy_load;process=(void*)&tof_policy_process;
 memcpy((char*)policy+0x10,&load,8);memcpy((char*)policy+0x18,&process,8);
 fprintf(stderr,"X2V_TOF_POLICY_FIX installed\n");
}
static void tof_route_snapshot(void *mgr){
 Dl_info di={0};void *dq;memcpy(&dq,(char*)mgr+0x18,8);
 if(!dladdr(dq,&di)||!strstr(di.dli_fname,"librcam.so"))return;
 uintptr_t base=(uintptr_t)dq-0x181e68;
 if((uintptr_t)di.dli_fbase!=base+0x2b000)return;
 void *(*get)(void*,unsigned)=(void*)(base+0x185f68);
 void *it=get((char*)mgr-0xd8,0x410605);if(!it)return;
 uint16_t flags;memcpy(&flags,(char*)it+0x52,2);
 void *dispatch=NULL,*iface=NULL,*notify=NULL;memcpy(&dispatch,(char*)it+0x90,8);
 if(dispatch){memcpy(&iface,(char*)dispatch+8,8);if(iface)memcpy(&notify,(char*)iface+0x18,8);}
 fprintf(stderr,"X2V_TOF_ROUTE_ITEM flags=%u aux=%u dispatch=%p notify=%lx\n",flags,*((unsigned char*)it+0x51),dispatch,notify?(unsigned long)((uintptr_t)notify-base):0ul);
 if(iface&&notify==(void*)(base+0x1947a0))tof_install_policy(iface,base);
}
static int (*tof_dequeue_original)(void*,unsigned,void**);
static int (*tof_enqueue_original)(void*,void*,int);
static int tof_dequeue(void *mgr,unsigned id,void **out){
 int rc=tof_dequeue_original(mgr,id,out);
 static _Atomic unsigned calls;
 if(id==0x410605){unsigned n=atomic_fetch_add(&calls,1)+1;if(n<=3||!(n%100))fprintf(stderr,"X2V_TOF_DISPATCH dequeue n=%u rc=%d buf=%p\n",n,rc,out?*out:NULL);}
 return rc;
}
static int tof_enqueue(void *mgr,void *buf,int bad){
 unsigned id=0;if(buf)memcpy(&id,buf,4);
 static _Atomic unsigned snaps;
 if(id==0x410605&&atomic_fetch_add(&snaps,1)<3){
  /* Temporarily use the original address only for locating the matching module. */
  Dl_info di={0};dladdr((void*)tof_enqueue_original,&di);
  uintptr_t base=(uintptr_t)tof_enqueue_original-0x1821c8;
  void *(*get)(void*,unsigned)=(void*)(base+0x185f68);
  void *it=get((char*)mgr-0xd8,id);uint16_t flags=0;void *dispatch=NULL,*iface=NULL,*notify=NULL;
  if(it){memcpy(&flags,(char*)it+0x52,2);memcpy(&dispatch,(char*)it+0x90,8);if(dispatch){memcpy(&iface,(char*)dispatch+8,8);if(iface)memcpy(&notify,(char*)iface+0x18,8);}}
  fprintf(stderr,"X2V_TOF_ROUTE_LIVE flags=%u dispatch=%p notify=%lx\n",flags,dispatch,notify?(unsigned long)((uintptr_t)notify-base):0ul);
  if(iface&&notify==(void*)(base+0x1947a0)){
   void *policy;memcpy(&policy,(char*)iface+0x210,8);
   if(policy){unsigned *cfg=(unsigned*)((char*)policy+0x5c);unsigned count=cfg[0];
    fprintf(stderr,"X2V_TOF_POLICY count=%u masters=%u field8=%u slave_count=%u entries=",count,cfg[1],cfg[2],*(unsigned*)((char*)policy+0x15c));
    if(count<=20)for(unsigned i=0;i<count;i++)fprintf(stderr,"%x/%u/%u,",cfg[3+i],cfg[23+2*i],cfg[24+2*i]);
    fprintf(stderr,"\n");
   }
  }
 }
 int rc=tof_enqueue_original(mgr,buf,bad);
 static _Atomic unsigned calls;
 if(id==0x410605){unsigned n=atomic_fetch_add(&calls,1)+1;if(n<=3||!(n%100))fprintf(stderr,"X2V_TOF_DISPATCH enqueue n=%u bad=%d rc=%d\n",n,bad,rc);}
 return rc;
}
static void tof_capture_provider(void *cb,void *ctx){
 Dl_info info={0};if(!ctx||!dladdr(cb,&info))return;
 uintptr_t base=(uintptr_t)cb-0x26b238;
 if(!strstr(info.dli_fname,"librcam.so")||((uintptr_t)info.dli_fbase!=base&&(uintptr_t)info.dli_fbase!=base+0x2b000))return;
 void *provider;memcpy(&provider,(char*)ctx+8,8);if(!provider)return;
 void *ops[9];memcpy(ops,provider,sizeof ops);
 if((uintptr_t)ops[2]-base!=0x269ec0||(uintptr_t)ops[8]-base!=0x26a248)return;
 if(ops[0]!=(void*)&tof_provider_destroy){
  if((uintptr_t)ops[0]-base!=0x269b80)return;
  memcpy(&tof_destroy_original,&ops[0],8);
  void *destroy=(void*)&tof_provider_destroy;memcpy(provider,&destroy,8);
 }

 void *mgr=NULL;memcpy(&mgr,(char*)provider+0x98,8);
 if(mgr){
  void *dq,*eq;memcpy(&dq,(char*)mgr+0x18,8);memcpy(&eq,(char*)mgr+0x20,8);
  if(dq!=(void*)&tof_dequeue){
   Dl_info di={0},ei={0};
   if(dladdr(dq,&di)&&dladdr(eq,&ei)&&di.dli_fbase==info.dli_fbase&&ei.dli_fbase==info.dli_fbase){
    tof_route_snapshot(mgr);memcpy(&tof_dequeue_original,&dq,8);memcpy(&tof_enqueue_original,&eq,8);
    fprintf(stderr,"X2V_TOF_DISPATCH methods dq=%lx eq=%lx\n",(unsigned long)((uintptr_t)dq-base),(unsigned long)((uintptr_t)eq-base));
    dq=(void*)&tof_dequeue;eq=(void*)&tof_enqueue;memcpy((char*)mgr+0x18,&dq,8);memcpy((char*)mgr+0x20,&eq,8);
   }
  }
 }
 atomic_store(&tof_provider,provider);
 fprintf(stderr,"X2V_TOF_REBIND captured provider=%p active=%u\n",provider,*((unsigned char*)provider+0xac));
}
static void tof_rebind(void){
 static int done;void *provider=atomic_load(&tof_provider);
 if(done||!provider||!atomic_load(&target_streaming))return;
 int (*activate)(void*);int (*subscribe)(void*,int);
 memcpy(&activate,(char*)provider+0x10,8);memcpy(&subscribe,(char*)provider+0x40,8);
 int before=*((unsigned char*)provider+0xac);
 int ar=activate(provider);int rr=ar?ar:subscribe(provider,0x410605);done=1;
 fprintf(stderr,"X2V_TOF_REBIND activate=%d subscribe=%d before=%d after=%u\n",ar,rr,before,*((unsigned char*)provider+0xac));
}

int taskbuf_get_consumer(const void *desc,void **out,int channel)
{
 typedef int (*fn)(const void*,void**,int);void *p=__loader_dlsym(dlopen("/system/lib64/libdcam_base.so",RTLD_NOW|RTLD_NOLOAD),"taskbuf_get_consumer",(void*)&taskbuf_get_consumer);fn real;memcpy(&real,&p,sizeof p);
 if(!real){fprintf(stderr,"X2V_TOF_ROUTE missing consumer original\n");return -1;}
 const char *names[2]={0};if(desc)memcpy(names,desc,sizeof names);
 int rc=real(desc,out,channel);
 if(!rc&&out&&names[1]&&!strcmp(names[1],"tof_spot"))tof_consumer=*out;
 if(names[1]&&strstr(names[1],"tof"))fprintf(stderr,"X2V_TOF_ROUTE consumer namespace=%.48s name=%.48s ch=%d handle=%p rc=%d\n",names[0]?names[0]:"",names[1],channel,out?*out:NULL,rc);
 return rc;
}

/* Ask the original AF thread to re-register its original ToF statistic after
 * MODE21 is streaming. Native list: int count, padding, ten cfg pointers (0x58).
 * No direct access to AF internals, lens commands or measurement rewriting. */
int dcam_af_get_stat_cfglist(int channel,void *list)
{
 typedef int (*list_fn)(int,void*);
 typedef int (*cfg_fn)(int,unsigned,const void*,const void**);
 static list_fn real;static cfg_fn cfg;
 if(!real||!cfg){
  void *h=dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD);
  void *p=__loader_dlsym(h,"dcam_af_get_stat_cfglist",(void*)&dcam_af_get_stat_cfglist);memcpy(&real,&p,sizeof p);
  p=__loader_dlsym(h,"tof_lib_get_stat_cfg",(void*)&dcam_af_get_stat_cfglist);memcpy(&cfg,&p,sizeof p);
 }
 if(!real)return -1;
 int rc=real(channel,list);static int requested;
 if(!rc&&channel==0)tof_rebind();
 if(rc||!list||channel!=0||requested||!atomic_load(&target_streaming))return rc;
 int count;memcpy(&count,list,4);
 if(count<0||count>=10)return rc;
 for(int i=0;i<count;i++){
  const void *entry;unsigned id=0;memcpy(&entry,(char*)list+8+8*i,8);if(entry)memcpy(&id,entry,4);
  if(id==0x410605){requested=1;fprintf(stderr,"X2V_TOF_REQUEST existing count=%d\n",count);return rc;}
 }
 const void *entry=NULL;int cr=cfg?cfg(channel,0x410605,NULL,&entry):-1;
 unsigned id=0;if(entry)memcpy(&id,entry,4);
 fprintf(stderr,"X2V_TOF_REQUEST cfg rc=%d id=%x count=%d streaming=%d\n",cr,id,count,atomic_load(&target_streaming));
 if(!cr&&entry&&id==0x410605){
  memcpy((char*)list+8+8*count,&entry,8);count++;memcpy(list,&count,4);requested=1;
 }
 return rc;
}

int taskbuf_attach(void *handle,void *cb,void *ctx)
{
 typedef int (*fn)(void*,void*,void*);static fn real;
 if(!real){void *h=dlopen("/system/lib64/libdcam_base.so",RTLD_NOW|RTLD_NOLOAD);void *p=__loader_dlsym(h,"taskbuf_attach",(void*)&taskbuf_attach);memcpy(&real,&p,sizeof p);}
 if(!real)return -1;
 if(handle==tof_consumer){tof_capture_provider(cb,ctx);memcpy(&tof_observer_original,&cb,8);cb=(void*)&tof_observer;}
 int rc=real(handle,cb,ctx);
 if(handle==tof_consumer)fprintf(stderr,"X2V_TOF_ROUTE attach handle=%p cb=%p ctx=%p rc=%d\n",handle,cb,ctx,rc);
 return rc;
}

int taskbuf_detach(void *handle,void *cb,void *ctx)
{
 if(handle==tof_consumer&&cb==(void*)tof_observer_original)cb=(void*)&tof_observer;
 typedef int (*fn)(void*,void*,void*);static fn real;
 if(!real){void *h=dlopen("/system/lib64/libdcam_base.so",RTLD_NOW|RTLD_NOLOAD);void *p=__loader_dlsym(h,"taskbuf_detach",(void*)&taskbuf_detach);memcpy(&real,&p,sizeof p);}
 if(!real)return -1;
 int rc=real(handle,cb,ctx);
 if(handle==tof_consumer)fprintf(stderr,"X2V_TOF_ROUTE detach handle=%p cb=%p ctx=%p rc=%d\n",handle,cb,ctx,rc);
 return rc;
}

int dcam_af_run(int channel){
 typedef int(*fn)(int);static fn real;
 if(!real){void *h=dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD);void*p=__loader_dlsym(h,"dcam_af_run",(void*)&dcam_af_run);memcpy(&real,&p,8);}
 if(!real)return -1;int rc=real(channel);static unsigned n;
 if(++n<=3||!(n%24)){
  const char *names[]={"tof_get_output_conf","tof_get_output_depth","tof_get_output_peak","afc_ctrl_get_status","afc_ctrl_get_active_flag"};int values[5]={0};
  void *h=dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD);
  for(int i=0;i<5;i++){void *p=__loader_dlsym(h,names[i],(void*)&dcam_af_run);fn f;memcpy(&f,&p,8);if(f)values[i]=f(channel);}
  fprintf(stderr,"X2V_AF_RUN n=%u rc=%d conf=%d depth=%d peak=%d afc_status=%d active=%d\n",n,rc,values[0],values[1],values[2],values[3],values[4]);
 }
 return rc;
}
int tof_dtof_ads6401_run(int channel,int state){
 typedef int(*fn)(int,int);static fn real;
 typedef void(*subfn)(int,void*,void*);static subfn sub;
 if(!real){void *h=dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD);void*p=__loader_dlsym(h,"tof_dtof_ads6401_run",(void*)&tof_dtof_ads6401_run);memcpy(&real,&p,8);p=__loader_dlsym(h,"tof_dtof_ads6401_get_subtitle",(void*)&tof_dtof_ads6401_run);memcpy(&sub,&p,8);}
 if(!real)return -1;int rc=real(channel,state);static unsigned n;
 if(++n<=3||!(n%100)){
  unsigned words[6]={0};char subtitle[0x570]={0};if(sub)sub(channel,words,subtitle);
  fprintf(stderr,"X2V_TOF_RUN n=%u state=%d rc=%d result=%x,%x,%x,%x,%x,%x\n",n,state,rc,words[0],words[1],words[2],words[3],words[4],words[5]);
  /* Read only: matching ADS6401 context getter from this firmware's debug ELF.
   * This is distinct from the other identically named common ToF context. */
  if(channel==0){
   uintptr_t fp=0;memcpy(&fp,&real,8);uintptr_t hp=fp-0x590220+0x583ae0;
   void*(*getctx)(int)=NULL;memcpy(&getctx,&hp,8);unsigned char*c=getctx(channel);
   if(c){
    unsigned frame=0;memcpy(&frame,c+0x260,4);
    fprintf(stderr,"X2V_TOF_ROI n=%u frame_slot=%u sdk=%u,%u,%u,%u",n,frame,c[0x20c],c[0x20d],c[0x20e],c[0x20f]);
    unsigned off[]={0x210,0x228,0x240};
    for(unsigned k=0;k<3;k++){float v[4];memcpy(v,c+off[k],16);fprintf(stderr," %x=%.5f,%.5f,%.5f,%.5f",off[k],v[0],v[1],v[2],v[3]);}
    fprintf(stderr,"\n");
   }
  }

 }
 return rc;
}

static void *af_real(const char *name){
 void*h=dlopen("/system/lib64/libaaa.so",RTLD_NOW|RTLD_NOLOAD);
 return __loader_dlsym(h,name,(void*)&af_real);
}
float af_get_frame_rate(int channel){
 typedef float(*fn)(int);static fn real;if(!real){void*p=af_real("af_get_frame_rate");memcpy(&real,&p,8);}
 float fps=real?real(channel):30.0f;
 if(channel==0&&atomic_load(&target_streaming))return 30.0f;
 return fps;
}
void alg_reset_all_alg_output_info(int channel){
 typedef void(*fn)(int);static fn real;if(!real){void*p=af_real("alg_reset_all_alg_output_info");memcpy(&real,&p,8);}
 static unsigned n;if(channel==0&&atomic_load(&target_streaming)&&!(++n%24)){
  const char *names[]={"tof_get_output_conf","tof_get_output_depth","tof_get_output_peak","afc_ctrl_get_status","afc_ctrl_get_active_flag","af_get_body_focus_mode","af_get_half_press_status","af_get_is_record","af_get_afc_in_trigger_mode","af_get_is_afc_trigger","af_smart_roi_available","is_hybrid_af_idle","lens_ctrl_get_cur_focus_pos","lens_ctrl_get_mod_pos","lens_ctrl_get_inf_pos"};
  fprintf(stderr,"X2V_AF_GATE n=%u",n);
  for(unsigned i=0;i<sizeof(names)/sizeof(names[0]);i++){void*p=af_real(names[i]);int(*f)(int);memcpy(&f,&p,8);if(f)fprintf(stderr," %s=%d",names[i],f(channel));}

  typedef void*(*getfn)(int,int);getfn get=NULL;void*p=af_real("get_alg_output_handle");memcpy(&get,&p,8);
  if(get){unsigned char*out=get(channel,5);if(out){int conf=0,peak=0;memcpy(&conf,out+0x2c,4);memcpy(&peak,out+0x30,4);fprintf(stderr," tof_native_conf=%d tof_native_peak=%d",conf,peak);}}

 fprintf(stderr,"\n");
 }
 if(real)real(channel);
}

/* MODE21 has no live PD/CD statistics. In AF-C, select native continuous
 * controller instead of starting the still-image contrast scan. It keeps its
 * own confidence/limits/motor control and receives the real ToF stats. */
int hybrid_af_start(int channel,int retry){
 typedef int(*fn)(int,int);static fn real;
 if(!real){void*p=af_real("hybrid_af_start");memcpy(&real,&p,8);}
 int(*mode)(int)=NULL;void*p=af_real("af_get_body_focus_mode");memcpy(&mode,&p,8);
 if(channel==0&&atomic_load(&target_streaming)&&mode&&mode(channel)==2){
  void(*set)(int,int)=NULL;p=af_real("af_set_afc_in_trigger_mode");memcpy(&set,&p,8);
  if(set){set(channel,0);fprintf(stderr,"X2V_AF_CONT native-controller selected ch=%d retry=%d\n",channel,retry);return 0;}
 }
 return real?real(channel,retry):-1;
}

/* Bounded experiment: accept native ToF peak score60, keep super threshold95,
 * motor limits, confidence calculation and all other native AF settings.
 * Copy exactly AFC extent [0xb5f28,0xb63a8), determined by adjacent getters.
 * No persistent native config mutation; production version must not enable this
 * without independent optical acceptance across distance/lighting/lenses. */
void *af_get_afc_param(int channel){
 typedef void*(*fn)(int);static fn real;if(!real){void*p=af_real("af_get_afc_param");memcpy(&real,&p,8);}
 void *p=real?real(channel):NULL;
 if(p&&channel==0&&atomic_load(&target_streaming)){
  static unsigned char cfg[0x480];static _Atomic int copied;
  int expect=0;
  if(atomic_compare_exchange_strong(&copied,&expect,1)){
   memcpy(cfg,p,sizeof cfg);unsigned v=0;memcpy(&v,cfg+0x33c,4);
   fprintf(stderr,"X2V_AF_CFG flags=%u,%u,%u,%u threshold=%u all=",cfg[0x318],cfg[0x319],cfg[0x31a],cfg[0x31b],v);
   for(unsigned o=0x328;o<=0x35c;o+=4){unsigned z;memcpy(&z,cfg+o,4);fprintf(stderr," %x:%u",o,z);}fprintf(stderr,"\n");
   if(v==80){v=60;memcpy(cfg+0x33c,&v,4);}unsigned fusion=0;memcpy(cfg+0x3d0,&fusion,4);unsigned method=0;memcpy(cfg+0x3c4,&method,4);unsigned master=3,slave=0;memcpy(cfg+0x3d4,&master,4);memcpy(cfg+0x3d8,&slave,4);atomic_store(&copied,2);
  }else while(atomic_load(&copied)!=2){}
  /* Read-only snapshot for this short fixed-settings probe; no UI edits. */
  unsigned th=0;memcpy(&th,cfg+0x33c,4);
  if(th==60){static int logged;if(!logged++){fprintf(stderr,"X2V_AF_WEIGHT ToF threshold80->60 temporary; super95 unchanged\n");}return cfg;}
 }
 return p;
}

extern int x2v_af_recording(void);
int af_get_is_record(int ch){
 typedef int(*fn)(int);static fn real;if(!real){void*p=af_real("af_get_is_record");memcpy(&real,&p,8);}
 return ch==0&&atomic_load(&target_streaming)?1:(real?real(ch):0);
}
int af_get_is_in_recording(int ch){
 typedef int(*fn)(int);static fn real;if(!real){void*p=af_real("af_get_is_in_recording");memcpy(&real,&p,8);}
 return ch==0&&atomic_load(&target_streaming)?x2v_af_recording():(real?real(ch):0);
}
void afc_ctrl_process(int ch){
 typedef void(*fn)(int);static fn real;if(!real){void*p=af_real("afc_ctrl_process");memcpy(&real,&p,8);}
 if(real)real(ch);
 static unsigned n;if(ch==0&&atomic_load(&target_streaming)&&!(++n%24)){
  void *(*get)(int)=NULL;void*p=af_real("_get_afc_ctrl_ctx");memcpy(&get,&p,8);
  unsigned char*c=get?get(ch):NULL;if(c){fprintf(stderr,"X2V_AF_CTRL n=%u",n);unsigned ofs[]={8,0x1c,0x20,0x28,0x2c,0x30,0x34,0x4a78,0x4a80,0x4a88};for(unsigned i=0;i<sizeof(ofs)/sizeof(ofs[0]);i++){int v;memcpy(&v,c+ofs[i],4);fprintf(stderr," %x:%d",ofs[i],v);}fprintf(stderr,"\n");}
 }
}
