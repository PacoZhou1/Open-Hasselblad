#include "target_descriptor.h"
#include "target_rows.h"
#include "hal_pins.h"
extern void *memcpy(void *,const void *,size_t);
extern size_t strlen(const char *);
int x2v_clone_mode21(X2vMode21Descriptor *out,const void *native,uintptr_t base) {
    if(!out || out->prepared)return -1;
    X2vOwnedDescriptor baseline={0};
    int rc=x2v_clone_normal(&baseline,native,base);
    if(rc)return rc;
    memcpy(out->descriptor,baseline.descriptor,192);
    memcpy(out->modes,baseline.modes,sizeof(baseline.modes));
    memcpy(out->modes+24,target_hb_rows,sizeof(target_hb_rows));
    uintptr_t modes=(uintptr_t)out->modes;uint32_t count=28;
    memcpy(out->descriptor+0xb0,&modes,8);memcpy(out->descriptor+0xb8,&count,4);
    out->native_base=base;out->prepared=1;
    return 0;
}
int x2v_bind_mode21_c24(X2vOwnedHalProfiles *hal) {
    return x2v_bind_hal_sensor(hal,2,1,target_hal_sensors[0]);
}
int x2v_hal_mode_name(const X2vOwnedHalProfiles *o,int profile,unsigned bytes,int *hb_id,char *out) {
    if(!o || !o->ready || profile<0 || profile>=10 || !hb_id || !out || !bytes || bytes>4096)return -1003;
    uint32_t hb;memcpy(&hb,o->sensors[profile],4);
    if(hb>=28)return -1003;
    const char *name=hb<24?hal_hb_names[hb]:(const char *)target_hb_rows[hb-24];
    size_t size=strlen(name),copy=size<bytes-1?size:bytes-1;
    memcpy(out,name,copy);out[copy]=0;*hb_id=(int)hb;
    return 0;
}
