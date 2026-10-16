/* Private callbacks are reached through native outer mutex wrappers. No direct
 * hardware call is initiated. MODE21 first prepare and later FPS updates share
 * exactly24/1. Normal requests retain original pointers/bytes/return codes. */
#include "fps_guard.h"
/* Combined adapter adds this closest-call scope gate; vendor original is never
 * invoked for HB24/current24 without the explicit audited group13 session. */
extern int x2v_mode21_vendor_allowed(void);
#include "fps_guard_pins.h"
extern void *memcpy(void *,const void *,size_t);
extern int memcmp(const void *,const void *,size_t);
extern int snprintf(char *,size_t,const char *,...);
extern long write(int,const void *,size_t);
typedef int (*Native)(void *,const void *);
static Native native_mode, native_fps;
static X2vFpsGuard *guards[8];
static unsigned char gate;
static void lock(void){while(__atomic_test_and_set(&gate,__ATOMIC_ACQUIRE)) {}}
static void unlock(void){__atomic_clear(&gate,__ATOMIC_RELEASE);}
static int valid_context(X2vFpsGuard *g,void *ctx){
    uintptr_t modes;uint32_t count;
    memcpy(&modes,(unsigned char*)ctx+0x1e0,8);
    memcpy(&count,(unsigned char*)ctx+0x1e8,4);
    return g->installed && modes==(uintptr_t)g->modes && count==28;
}
static int accepted(void *ctx){
    int result=0;lock();
    for(unsigned i=0;i<8;i++) if(guards[i] && guards[i]->context==ctx && guards[i]->ready && valid_context(guards[i],ctx))result=1;
    unlock();return result;
}
static void log_ratio(const char *kind,const uint64_t *old){
    char text[220];int n=snprintf(text,sizeof(text),"X2V_SOURCE_FPS kind=%s hb=24 driver=17 requested=%llu/%llu applied=25/1 frame_evidence=false\n",kind,(unsigned long long)old[0],(unsigned long long)old[1]);
    if(n>0)write(2,text,(size_t)n<sizeof(text)?(size_t)n:sizeof(text)-1);
}
static int guarded_mode(void *ctx,const void *request){
    if(!ctx||!request||!native_mode)return -1003;
    if(*(const unsigned char*)request!=24)return native_mode(ctx,request);
    if(!accepted(ctx)||!x2v_mode21_vendor_allowed())return -1003;
    /* Complete observed read contract: request0 hb,4 shutter,8/10 u64 ratio.
     * No request pointer escapes the original selected function. */
    unsigned char copy[24];uint64_t ratio[2]={25,1},old[2];
    memcpy(copy,request,sizeof(copy));memcpy(old,copy+8,16);memcpy(copy+8,ratio,16);
    log_ratio("prepare",old);return native_mode(ctx,copy);
}
static int guarded_fps(void *ctx,const void *request){
    if(!ctx||!native_fps)return -1003;
    /* byte39 is the current HB selection, not driver byte40 in a row. */
    if(*((const unsigned char*)ctx+0x39)!=24)return native_fps(ctx,request);
    if(!accepted(ctx)||!x2v_mode21_vendor_allowed())return -1003;
    uint64_t ratio[2]={25,1},old[2]={0,0};
    if(request)memcpy(old,request,16);
    log_ratio("update",old);return native_fps(ctx,ratio);
}
int x2v_fps_guard_install(X2vFpsGuard *g,void *descriptor,uintptr_t bias,const void *modes){
    if(!g||g->installed||!descriptor||!bias||!modes)return -1;
    uintptr_t source;memcpy(&source,descriptor,8);
    if(source!=bias+0x588000)return -2;
    unsigned char expected[0x210];memcpy(expected,pinned_private_ops,sizeof(expected));
    for(unsigned i=0;i<sizeof(private_ops_fixups)/sizeof(private_ops_fixups[0]);i++){
        uintptr_t p;unsigned offset=private_ops_fixups[i];memcpy(&p,expected+offset,8);p+=bias;memcpy(expected+offset,&p,8);
    }
    if(memcmp((void*)source,expected,sizeof(expected)) || memcmp((void*)(bias+0x29b050),pinned_mode_callback,64) || memcmp((void*)(bias+0x29e1d8),pinned_fps_callback,64) || memcmp((void*)(bias+0x250688),pinned_outer_fps,64))return -3;
    lock();
    if(native_mode && (uintptr_t)native_mode!=bias+0x29b050){unlock();return -4;}
    unsigned i;for(i=0;i<8;i++)if(!guards[i])break;
    if(i==8){unlock();return -5;}
    memcpy(g->operations,expected,sizeof(expected));
    native_mode=(Native)(bias+0x29b050);native_fps=(Native)(bias+0x29e1d8);
    Native callback=guarded_mode;memcpy(g->operations+0x28,&callback,8);
    callback=guarded_fps;memcpy(g->operations+0x1a0,&callback,8);
    g->bias=bias;g->modes=modes;g->installed=1;guards[i]=g;
    source=(uintptr_t)g->operations;memcpy(descriptor,&source,8);
    unlock();return 0;
}
int x2v_fps_guard_commit(X2vFpsGuard *g,void *ctx,int rc){
    if(!g)return -1;lock();g->ready=0;g->context=ctx;
    if(!rc && ctx && valid_context(g,ctx))g->ready=1;
    int result=g->ready?0:-1;unlock();return result;
}
void x2v_fps_guard_revoke(X2vFpsGuard *g){if(!g)return;lock();g->ready=0;unlock();}
int x2v_mode21_fps_guard_ready(void){int result=0;lock();for(unsigned i=0;i<8;i++)if(guards[i]&&guards[i]->ready)result=1;unlock();return result;}
