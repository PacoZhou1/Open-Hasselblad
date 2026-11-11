#ifndef X2V_OWNED_DESCRIPTOR_H
#define X2V_OWNED_DESCRIPTOR_H
#include <stdint.h>
#include <stddef.h>
#define X2V_DESCRIPTOR_BYTES 192u
#define X2V_HB_ROWS 24u
#define X2V_HB_ROW_BYTES 132u
#define X2V_MAX_OBJECTS 8u
/* Pinning is exact bytes plus four rebased pointer slots, not name matching. */
typedef struct {
    unsigned char descriptor[X2V_DESCRIPTOR_BYTES];
    unsigned char modes[X2V_HB_ROWS * X2V_HB_ROW_BYTES];
    uintptr_t native_base;
    unsigned prepared;
} X2vOwnedDescriptor;
/* 0 cloned; 1 different native sensor descriptor; negative pin failure. */
int x2v_clone_normal(X2vOwnedDescriptor *, const void *, uintptr_t);
#endif
