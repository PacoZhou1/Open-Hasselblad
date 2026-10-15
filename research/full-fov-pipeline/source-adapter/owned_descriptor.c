#include "owned_descriptor.h"
#include "firmware_pins.h"
extern void *memcpy(void *,const void *,size_t);
extern int memcmp(const void *,const void *,size_t);
int x2v_clone_normal(X2vOwnedDescriptor *owned, const void *source, uintptr_t base) {
    unsigned char expected[X2V_DESCRIPTOR_BYTES];
    uintptr_t pointer;
    if (!owned || !source || !base) return -1;
    memcpy(&pointer,(const unsigned char *)source+0x18,8);
    /* Native candidate lists may contain another sensor. Do not replace it. */
    if (pointer != base + 0x3d468a) return 1;
    memcpy(expected,pinned_descriptor,sizeof(expected));
    for (unsigned i=0;i<sizeof(descriptor_fixups)/sizeof(descriptor_fixups[0]);i++) {
        unsigned offset=descriptor_fixups[i];
        memcpy(&pointer,expected+offset,8);
        pointer+=base;
        memcpy(expected+offset,&pointer,8);
    }
    if (memcmp(source,expected,sizeof(expected))) return -2;
    memcpy(&pointer,expected+0xb0,8);
    if (memcmp((void *)pointer,pinned_modes,sizeof(pinned_modes))) return -3;
    memcpy(owned->modes,(void *)pointer,sizeof(owned->modes));
    memcpy(owned->descriptor,source,sizeof(owned->descriptor));
    pointer=(uintptr_t)owned->modes;
    memcpy(owned->descriptor+0xb0,&pointer,8);
    owned->native_base=base;
    owned->prepared=1;
    return 0;
}
