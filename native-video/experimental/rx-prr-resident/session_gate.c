#define _GNU_SOURCE 1
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdatomic.h>
#include <dlfcn.h>
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
static _Atomic(uintptr_t) known_engine;
static _Atomic(uintptr_t) scope_engine;
static _Atomic int applied_target, vendor_scope, uncertain, target_streaming;
static _Atomic unsigned absorbed;
static int target_stage(void){
 const char *s=getenv("X2V_OWNED_RAW_GRAPH"),*o=getenv("X2V_SOURCE_ADAPTER");
 return s&&o&&!strcmp(s,"mode21-c24")&&!strcmp(o,"mode21-c-24fps");
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
   if(guarded())return absorb("set_params",engine,name);
   return real(engine,params);
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
   if(guarded())return absorb("start_streaming",engine,NULL);
   return real(engine,consumers); /* Only proven native non-HB profile. */
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
 if(guarded())return absorb("stop_streaming",engine,NULL);
 int rc=real(engine);
 if(!rc&&target_stage()&&x2v_target_parser_class(engine)==1)atomic_store(&target_streaming,0);
 return rc;
}
/* Native start_stream/stop_stream forward x1.. untouched to the current group's ops. */
int cam_cap_eng_start_stream(void *engine,void *a,void *b,void *c){
 typedef int (*fn)(void*,void*,void*,void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_start_stream",(void*)&cam_cap_eng_start_stream);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(guarded())return absorb("start_stream",engine,NULL);
 return real(engine,a,b,c);
}
int cam_cap_eng_stop_stream(void *engine,void *a,void *b,void *c){
 typedef int (*fn)(void*,void*,void*,void*);void*p=__loader_dlsym(RTLD_NEXT,"cam_cap_eng_stop_stream",(void*)&cam_cap_eng_stop_stream);fn real;memcpy(&real,&p,sizeof p);if(!real)return -1003;
 if(guarded())return absorb("stop_stream",engine,NULL);
 return real(engine,a,b,c);
}
