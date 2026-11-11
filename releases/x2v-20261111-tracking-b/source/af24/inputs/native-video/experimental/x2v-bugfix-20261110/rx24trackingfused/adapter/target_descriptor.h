#ifndef X2V_TARGET_DESCRIPTOR_H
#define X2V_TARGET_DESCRIPTOR_H
#include "owned_descriptor.h"
#include "hal_profile_adapter.h"
typedef struct {
    unsigned char descriptor[192];
    unsigned char modes[28][132];
    uintptr_t native_base;
    unsigned prepared;
} X2vMode21Descriptor;
/* Clones original24, appends exactly four own rows; selected driver17 at24fps, unselected18..20 at20fps.
 * Uses the original single native engine's Init, never sends MCU packets. */
int x2v_clone_mode21(X2vMode21Descriptor *,const void *native_descriptor,uintptr_t rcam_bias);
/* Bind only profile2 to HB24/driver17 and topology1; startup1/HB23 retained. */
int x2v_bind_mode21_c24(X2vOwnedHalProfiles *);
/* Exact metadata name callback ABI; added indices24..27 have own names. */
int x2v_hal_mode_name(const X2vOwnedHalProfiles *,int profile,unsigned name_bytes,int *hb_id,char *name);
/* True only after original Init of the cloned descriptor returns0; revoked
 * before original Deinit. It proves construction, not target frames or drain. */
int x2v_mode21_descriptor_ready(void);
#endif
