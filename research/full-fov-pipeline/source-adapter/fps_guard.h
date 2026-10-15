#ifndef X2V_FPS_GUARD_H
#define X2V_FPS_GUARD_H
#include <stdint.h>
#include <stddef.h>
typedef struct {
    unsigned char operations[0x210];
    void *context;
    const unsigned char *modes;
    uintptr_t bias;
    unsigned installed, ready;
} X2vFpsGuard;
/* Install before original Init. Owned data retained until process exit. */
int x2v_fps_guard_install(X2vFpsGuard *,void *descriptor,uintptr_t bias,const void *modes);
int x2v_fps_guard_commit(X2vFpsGuard *,void *context,int native_init_rc);
void x2v_fps_guard_revoke(X2vFpsGuard *);
int x2v_mode21_fps_guard_ready(void);
#endif
