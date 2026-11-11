/* Target descriptor component: link together with HAL getter, receiver graph
 * and exact24fps guard. Standalone loading does NOT select target mode.
 * Single-owner copy-on-init shim. No sensor calls, mode switch, new engine,
 * producer restart, dump, filesystem output or teardown are initiated here.
 * Owned descriptor/modes intentionally live until process exit.
 */
#include "target_descriptor.h"
#include "fps_guard.h"
#include "firmware_pins.h"
#include <stdint.h>
#include <stddef.h>
extern void *memcpy(void *,const void *,size_t);
extern int memcmp(const void *,const void *,size_t);
extern int strcmp(const char *,const char *);
extern char *getenv(const char *);
extern void *calloc(size_t,size_t);
extern int snprintf(char *,size_t,const char *,...);
#ifdef X2V_HOST_TEST
#include "host_binding.h"
#else
/* Bionic ABI declarations. Avoid linking glibc/musl startup into Android. */
typedef struct { const char *dli_fname; void *dli_fbase; const char *dli_sname; void *dli_saddr; } X2vDlInfo;
extern void *dlsym(void *, const char *);
extern int dladdr(const void *, X2vDlInfo *);
typedef struct { uint32_t type,flags; uint64_t offset,vaddr,paddr,filesz,memsz,align; } X2vPhdr;
typedef struct { uintptr_t addr; const char *name; const X2vPhdr *phdr; uint16_t phnum; } X2vPhdrInfo;
extern int dl_iterate_phdr(int (*)(X2vPhdrInfo *,size_t,void *),void *);
extern long write(int,const void *,size_t);
extern void _exit(int);
#define X2V_NEXT ((void *)(intptr_t)-1)
#endif

void *rcam_imgsys_create(void);
typedef void *(*Factory)(void);
typedef int (*NativeInit)(void *);
typedef struct {
    void *handle;
    NativeInit original_init;
    NativeInit original_deinit;
    unsigned ready;
    X2vMode21Descriptor *owned;
    unsigned init_calls;
    X2vFpsGuard fps_guard;
} Entry;
static Entry entries[X2V_MAX_OBJECTS];
static unsigned char entry_lock;
static unsigned object_count;
static unsigned char bind_lock;
static Factory real_factory;
static uintptr_t base;
static uintptr_t mapping_base;
static int verify_loaded_image(X2vPhdrInfo *i,size_t size,void *unused) {
    (void)unused;
    if(size<offsetof(X2vPhdrInfo,phnum)+sizeof(i->phnum) || i->addr!=base)return 0;
    if(!i->phdr || !i->phnum || i->phnum>64)return 0;
    unsigned load0=0,factory_rx=0,init_rx=0;
    for(unsigned n=0;n<i->phnum;n++) {
        const X2vPhdr *p=&i->phdr[n];
        if(p->type!=1)continue;
        if(p->offset==0 && p->vaddr==0x2b000)load0=1;
        if((p->flags&5)==5 && p->vaddr<=0x24c678 && p->memsz>=64 && 0x24c678-p->vaddr<=p->memsz-64)factory_rx=1;
        if((p->flags&5)==5 && p->vaddr<=0x24cb90 && p->memsz>=64 && 0x24cb90-p->vaddr<=p->memsz-64)init_rx=1;
    }
    return load0 && factory_rx && init_rx;
}
static unsigned enabled;
static void fatal(const char *why) {
    char message[256];
    int n=snprintf(message,sizeof(message),"X2V_SOURCE_ADAPTER reject=%s; no vendor Init called\n",why);
    if(n>0)write(2,message,(size_t)n<sizeof(message)?(size_t)n:sizeof(message)-1);
    _exit(126);
}
static void lock(unsigned char *f) { while(__atomic_test_and_set(f,__ATOMIC_ACQUIRE)){} }
static void unlock(unsigned char *f) { __atomic_clear(f,__ATOMIC_RELEASE); }
static void bind(void) {
    lock(&bind_lock);
    if (!real_factory) {
        const char *setting=getenv("X2V_SOURCE_ADAPTER");
        enabled=setting && !strcmp(setting,"mode21-c-24fps");
        if(setting && *setting && !enabled && strcmp(setting,"off"))fatal("unknown_setting");
        real_factory=(Factory)dlsym(X2V_NEXT,"rcam_imgsys_create");
        if (!real_factory || (void *)real_factory==(void *)rcam_imgsys_create)fatal("factory_binding");
        if(enabled) {
            X2vDlInfo info={0};
            if(!dladdr((void *)real_factory,&info) || !info.dli_fbase)fatal("factory_base");
            mapping_base=(uintptr_t)info.dli_fbase;
            if((uintptr_t)real_factory<0x24c678)fatal("factory_address");
            base=(uintptr_t)real_factory-0x24c678; /* link VA bias, NOT dli_fbase */
            if(!dl_iterate_phdr(verify_loaded_image,NULL))fatal("loaded_phdr_bias");
            if(
               memcmp((void *)real_factory,pinned_factory,sizeof(pinned_factory)) ||
               memcmp((void *)(base+0x24cb90),pinned_init,sizeof(pinned_init)))fatal("fixed_firmware_pin");
        }
    }
    unlock(&bind_lock);
}
int x2v_mode21_descriptor_ready(void) {
    unsigned result=0;
    lock(&entry_lock);
    for(unsigned i=0;i<X2V_MAX_OBJECTS;i++)if(entries[i].ready)result=1;
    unlock(&entry_lock);
    return (int)result;
}
static int copy_deinit(void *handle) {
    Entry *entry=NULL;
    lock(&entry_lock);
    for(unsigned j=X2V_MAX_OBJECTS;j>0;j--)if(entries[j-1].handle==handle){entry=&entries[j-1];break;}
    if(!entry)fatal("untracked_deinit");
    entry->ready=0;
    x2v_fps_guard_revoke(&entry->fps_guard);
    NativeInit deinit=entry->original_deinit;
    unlock(&entry_lock);
    return deinit(handle); /* allocations retained even on failure */
}
static int copy_init(void *handle) {
    Entry *entry=NULL;
    lock(&entry_lock);
    for(unsigned j=X2V_MAX_OBJECTS;j>0;j--)if(entries[j-1].handle==handle){entry=&entries[j-1];break;}
    if(!entry)fatal("untracked_init");
    void **descriptor_slot=(void **)((unsigned char *)handle-0xd0);
    if(!entry->owned) {
        entry->owned=calloc(1,sizeof(*entry->owned));
        if(!entry->owned)fatal("clone_alloc");
        int rc=x2v_clone_mode21(entry->owned,*descriptor_slot,base);
        if(rc<0)fatal("descriptor_or_modes_pin");
        if(rc==1) {
            /* Preserve unrelated native sensor; allocation remains pinned. */
            NativeInit init=entry->original_init;
            unlock(&entry_lock);
            return init(handle);
        }
        if(x2v_fps_guard_install(&entry->fps_guard,entry->owned->descriptor,base,entry->owned->modes))fatal("private_ops_pin");
        *descriptor_slot=entry->owned->descriptor;
    } else if(entry->owned->prepared) {
        if(*descriptor_slot!=entry->owned->descriptor)fatal("descriptor_replaced_after_init");
    } else {
        NativeInit init=entry->original_init;
        unlock(&entry_lock);
        return init(handle);
    }
    entry->ready=0;
    entry->init_calls++;
    NativeInit init=entry->original_init;
    unsigned calls=entry->init_calls;
    unlock(&entry_lock);
    char message[512];
    int n=snprintf(message,sizeof(message),
        "X2V_SOURCE_ADAPTER clone_ready build=mode21-c24-direct load_bias=%p dladdr_mapping=%p descriptor_bytes=192 mode_count=28 startup_hb_index=23 startup_driver_index=52 candidate_hb_index=24 candidate_driver_index=17 calls=%u hardware_owner=native_init frame_evidence=false\n",
        (void *)base,(void *)mapping_base,calls);
    if(n>0)write(2,message,(size_t)n<sizeof(message)?(size_t)n:sizeof(message)-1);
    int result=init(handle);
    void *context;memcpy(&context,(unsigned char*)handle-0x28,8);
    int guard_result=x2v_fps_guard_commit(&entry->fps_guard,context,result);
    lock(&entry_lock);
    entry->ready=result==0 && guard_result==0;
    unlock(&entry_lock);
    n=snprintf(message,sizeof(message),"X2V_SOURCE_ADAPTER native_init_end rc=%d fps_guard_commit=%d clone_retained_until_exit=true\n",result,guard_result);
    if(n>0)write(2,message,(size_t)n<sizeof(message)?(size_t)n:sizeof(message)-1);
    return result;
}
void *rcam_imgsys_create(void) {
    bind();
    if(enabled && __atomic_fetch_add(&object_count,1,__ATOMIC_RELAXED)>=X2V_MAX_OBJECTS)fatal("object_bound");
    void *handle=real_factory();
    if(!enabled || !handle)return handle;
    uintptr_t init,deinit;
    memcpy(&init,(unsigned char *)handle+0x10,8);
    memcpy(&deinit,(unsigned char *)handle+0x18,8);
    if(init!=base+0x24cb90 || deinit!=base+0x24d1d0)fatal("object_init_deinit_slots");
    lock(&entry_lock);
    Entry *entry=NULL;
    for(unsigned i=0;i<X2V_MAX_OBJECTS;i++)if(!entries[i].handle){entry=&entries[i];break;}
    if(!entry)fatal("tracking_bound");
    entry->handle=handle;
    entry->original_init=(NativeInit)init;
    entry->original_deinit=(NativeInit)deinit;
    NativeInit wrapper=copy_init;
    memcpy((unsigned char *)handle+0x10,&wrapper,8);
    wrapper=copy_deinit;
    memcpy((unsigned char *)handle+0x18,&wrapper,8);
    unlock(&entry_lock);
    return handle;
}
