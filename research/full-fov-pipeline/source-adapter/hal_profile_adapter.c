#include "hal_profile_adapter.h"
#include "hal_pins.h"
extern void *memcpy(void *,const void *,size_t);
extern int memcmp(const void *,const void *,size_t);
static uint32_t word(const unsigned char *p) { uint32_t n;memcpy(&n,p,4);return n; }
static uintptr_t pointer(const unsigned char *p) { uintptr_t n;memcpy(&n,p,8);return n; }
int x2v_clone_hal_profiles(X2vOwnedHalProfiles *o,const void *cam_info,uintptr_t base) {
    if(!o || !cam_info || !base || o->ready)return -1;
    uintptr_t header=pointer((const unsigned char *)cam_info+0x120);
    if(header!=base+0x289b0)return -2;
    const unsigned char *h=(void *)header;
    if(word(h)!=10 || word(h+4)!=0 || pointer(h+8)!=base+0x29f50)return -3;
    unsigned char expected[sizeof(hal_profile_pins)];
    memcpy(expected,hal_profile_pins,sizeof(expected));
    for(unsigned i=0;i<sizeof(hal_profile_fixups)/sizeof(hal_profile_fixups[0]);i++) {
        unsigned offset=hal_profile_fixups[i];uintptr_t p=pointer(expected+offset)+base;
        memcpy(expected+offset,&p,8);
    }
    const unsigned char *rows=(void *)pointer(h+8);
    if(memcmp(rows,expected,sizeof(expected)))return -4;
    memcpy(o->profiles,rows,sizeof(o->profiles));
    for(unsigned i=0;i<10;i++) {
        uintptr_t src=pointer(o->profiles[i]+0x28);
        if(src) {
            memcpy(o->sensors[i],(void *)src,132);
            uintptr_t child=(uintptr_t)o->sensors[i];memcpy(o->profiles[i]+0x28,&child,8);
        }
    }
    o->header=(X2vNativeArrayHeader){10,0,(uintptr_t)o->profiles};o->ready=1;
    return 0;
}
int x2v_bind_hal_sensor(X2vOwnedHalProfiles *o,unsigned profile,unsigned topology,const unsigned char *sensor) {
    if(!o || !o->ready || profile>=10 || topology>=7 || !sensor)return -1;
    uint32_t hb=word(sensor),w=word(sensor+0x44),h=word(sensor+0x48);
    uint16_t depth;memcpy(&depth,sensor+0x50,2);
    if(hb>=28 || !w || !h || w>12000 || h>10000 || !word(sensor+0x4c) ||
       !(depth==8 || depth==10 || depth==12 || depth==14 || depth==16))return -2;
    memcpy(o->sensors[profile],sensor,132);
    uintptr_t child=(uintptr_t)o->sensors[profile];uint32_t enabled=1;
    memcpy(o->profiles[profile]+0x10,&topology,4);
    memcpy(o->profiles[profile]+0x20,&enabled,4);
    memcpy(o->profiles[profile]+0x28,&child,8);
    return 0;
}
static const unsigned char *sensor_for(const X2vOwnedHalProfiles *o,int profile) {
    if(!o || !o->ready || profile<0 || profile>=10)return 0;
    if(word(o->profiles[profile]+0x20)<1)return 0;
    return o->sensors[profile];
}
int x2v_hal_bitdepth(const X2vOwnedHalProfiles *o,int profile,uint16_t *out) {
    if(!o || !o->ready || !out || profile<0 || profile>=10)return -1003;
    const unsigned char *s=sensor_for(o,profile);
    if(s)memcpy(out,s+0x50,2);else *out=16;
    return 0;
}
int x2v_hal_aux58(const X2vOwnedHalProfiles *o,int profile,uint32_t *out) {
    if(!o || !o->ready || !out || profile<0 || profile>=10)return -1003;
    const unsigned char *s=sensor_for(o,profile);*out=s?word(s+0x58):0;return 0;
}
